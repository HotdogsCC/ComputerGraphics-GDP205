#ifndef SIMPLEXNOISE3D_INCLUDED
#define SIMPLEXNOISE3D_INCLUDED

inline float3 Mod289(float3 x)
{
    return x - floor(x / 289.0) * 289.0;
}

inline float4 Mod289(float4 x)
{
    return x - floor(x / 289.0) * 289.0;
}

inline float4 Permute(float4 x)
{
    return Mod289((x * 34.0 + 1.0) * x);
}

inline float4 TaylorInvSqrt(float4 r)
{
    return 1.79284291400159 - r * 0.85373472095314;
}

/// <summary>
/// Generates 3D Simplex noise and its gradient at a given position.
///
/// Returns a float4 where :
/// - xyz : the gradient vector of the noise field at the position
/// - w : the actual noise value (typically in the range [ - 1, 1])
/// </summary>
inline float4 SimplexNoiseWithGradient(float3 position)
{

    // Constants used for skewing and unskewing space (specific to 3D simplex geometry)
    float2 skewConstants = float2(1.0 / 6.0, 1.0 / 3.0); // skew = 1 / 3, unskew = 1 / 6

    // Skew the input space to determine which simplex cell (tetrahedron) we're in
    float3 cell = floor(position + dot(position, skewConstants.yyy)); // Skewed coordinates
    float3 localPos = position - cell + dot(cell, skewConstants.xxx); // Unskewed back into local simplex space

    // Determine the rank order of the axes to identify which tetrahedron configuration we're in
    float3 cornerOrder = step(localPos.yzx, localPos.xyz); // Compare components to rank them
    float3 lower = 1.0 - cornerOrder;
    float3 cornerOffset1 = min(cornerOrder.xyz, lower.zxy); // Offset to 2nd corner in simplex
    float3 cornerOffset2 = max(cornerOrder.xyz, lower.zxy); // Offset to 3rd corner in simplex

    // Compute relative positions for each of the remaining 3 corners of the tetrahedron
    float3 simplexCorner1 = localPos - cornerOffset1 + skewConstants.xxx;
    float3 simplexCorner2 = localPos - cornerOffset2 + skewConstants.yyy;
    float3 simplexCorner3 = localPos - 0.5; // Last corner (Farthest corner of the tetrahedron)

    // Wrap the integer cell coordinates using modulus (avoids overflow and creates repeatable permutations)
    cell = Mod289(cell);

    // Use a permutation function to hash the cell and generate pseudo - random gradient indices
    float4 perm = Permute(Permute(Permute(
    cell.z + float4(0.0, cornerOffset1.z, cornerOffset2.z, 1.0)) +
    cell.y + float4(0.0, cornerOffset1.y, cornerOffset2.y, 1.0)) +
    cell.x + float4(0.0, cornerOffset1.x, cornerOffset2.x, 1.0));

    // Convert hashed values into a unique index for gradient selection (modulo 49)
    // 49 is not arbitrary here it's because the implementation uses a 7×7 gradient grid (in 2D), giving 49 distinct base vectors.
    float4 j = perm - 49.0 * floor(perm / 49.0);
    float4 xBase = floor(j / 7.0);
    float4 yBase = j - 7.0 * xBase;

    // Map base values to a range of [ - 1, 1] to create directional gradient vectors
    float4 xGrad = (xBase * 2.0 + 0.5) / 7.0 - 1.0;
    float4 yGrad = (yBase * 2.0 + 0.5) / 7.0 - 1.0;
    float4 zGrad = 1.0 - abs(xGrad) - abs(yGrad);

    // Pack gradients into 2D vectors (we’ll reconstruct the Z component later)
    float4 grad2D_low = float4(xGrad.xy, yGrad.xy);
    float4 grad2D_high = float4(xGrad.zw, yGrad.zw);

    // Determine signs based on Z gradient this is used to disambiguate direction
    float4 signLow = sign(grad2D_low);
    float4 signHigh = sign(grad2D_high);
    float4 zMask = -step(zGrad, 0.0); // Indicates which Z values are negative

    // Apply sign and mask adjustments to reconstruct full 3D gradient vectors
    float4 adjustedLow = grad2D_low.xzyw + signLow.xzyw * zMask.xxyy;
    float4 adjustedHigh = grad2D_high.xzyw + signHigh.xzyw * zMask.zzww;

    // Compose final 3D gradients for each corner of the simplex
    float3 gradient0 = float3(adjustedLow.xy, zGrad.x);
    float3 gradient1 = float3(adjustedLow.zw, zGrad.y);
    float3 gradient2 = float3(adjustedHigh.xy, zGrad.z);
    float3 gradient3 = float3(adjustedHigh.zw, zGrad.w);

    // Normalize gradients using an approximation of inverse square root
    float4 invLengths = TaylorInvSqrt(float4(
    dot(gradient0, gradient0),
    dot(gradient1, gradient1),
    dot(gradient2, gradient2),
    dot(gradient3, gradient3)
    ));

    gradient0 *= invLengths.x;
    gradient1 *= invLengths.y;
    gradient2 *= invLengths.z;
    gradient3 *= invLengths.w;

    // Compute squared distance from the point to each corner
    float4 cornerDistancesSq = float4(
    dot(localPos, localPos),
    dot(simplexCorner1, simplexCorner1),
    dot(simplexCorner2, simplexCorner2),
    dot(simplexCorner3, simplexCorner3)
    );

    // Compute falloff weights using a polynomial kernel.
    // The constant 0.6 defines the radius of influence for each corner in 3D simplex space.
    // It's chosen empirically to ensure smooth blending while limiting each point's contribution
    // to only nearby corners
    float4 weights = max(0.6 - cornerDistancesSq, 0.0);
    float4 weights2 = weights * weights;
    float4 weights3 = weights2 * weights;
    float4 weights4 = weights2 * weights2;

    // Compute the gradient (derivative) of the noise
    float3 gradient =
    -6.0 * weights3.x * localPos * dot(localPos, gradient0) + weights4.x * gradient0 +
    -6.0 * weights3.y * simplexCorner1 * dot(simplexCorner1, gradient1) + weights4.y * gradient1 +
    -6.0 * weights3.z * simplexCorner2 * dot(simplexCorner2, gradient2) + weights4.z * gradient2 +
    -6.0 * weights3.w * simplexCorner3 * dot(simplexCorner3, gradient3) + weights4.w * gradient3;

    // Compute the final noise value as a weighted sum of dot products
    float noise = dot(weights4, float4(
    dot(localPos, gradient0),
    dot(simplexCorner1, gradient1),
    dot(simplexCorner2, gradient2),
    dot(simplexCorner3, gradient3)
    ));

    return float4(gradient, noise);
}

float4 EvaluateLayeredNoise(
float3 position,
float3 offset, // Position offset (can animate or randomize)
int octaves, // Number of noise layers to blend
float baseFrequency, // Starting frequency for the first octave
float frequencyMultiplier, // Multiplier for frequency per octave (aka lacunarity)
float persistence, // Amplitude falloff per octave (aka gain)
float outputScale // Final scale applied to the combined result
)
{
    float4 total = 0.0;
    float amplitude = 1.0;
    float frequency = baseFrequency;

    for (int i = 0; i < octaves; i++)
    {
        float4 noise = SimplexNoiseWithGradient(position * frequency + offset);
        total += noise * amplitude;
        frequency *= frequencyMultiplier;
        amplitude *= persistence;
    }

    // Scale the final result
    total *= outputScale;

    return total;
}

void SimplexNoise3DLayered_float(
float3 Position,
float3 Offset,
int Octaves,
float BaseFrequency,
float FrequencyMultiplier,
float Persistence,
float OutputScale, // Final scale applied to the combined result
out float Noise,
out float3 Gradient)
{
    float4 n = EvaluateLayeredNoise(Position, Offset, Octaves, BaseFrequency, FrequencyMultiplier, Persistence, OutputScale);
    Noise = n.w;
    Gradient = n.xyz;
}

void SimplexNoise3DLayered_half(
float3 Position,
float3 Offset,
int Octaves,
float BaseFrequency,
float FrequencyMultiplier,
float Persistence,
float OutputScale, // Final scale applied to the combined result
out float Noise,
out float3 Gradient)
{
    float4 n = EvaluateLayeredNoise(Position, Offset, Octaves, BaseFrequency, FrequencyMultiplier, Persistence, OutputScale);
    Noise = n.w;
    Gradient = n.xyz;
}
#endif // SIMPLEXNOISE3D_INCLUDED
