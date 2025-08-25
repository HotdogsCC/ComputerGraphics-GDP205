using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PerlinNoiseTexture : MonoBehaviour
{
    [Header("Texture Properties")]
    //used to scale and offset the noise
    public float scale = 4.0f;
    public Vector2 offset = new(0.0f, 0.0f);

    [Header("Noise Properties")]
    public float persistance = 0.5f;
    public float lacunarity = 2.0f;
    public int octave = 4;

    private float maxHeight;

    private float[,] heightMap;

    public Texture2D GenTexture(int width, int height)
    {
        heightMap = new float[width, height];

        Color[] colorMap = new Color[width * height];

        //generate the perlin noise 
        //for each pixel row
        for (int w = 0; w < width; w++)
        {
            //for each pixel column
            for (int h = 0; h < height; h++)
            {
                float amp = 1.0f;
                float freq = 1.0f;
                float finalValue = 0.0f;

                //for each octave
                for (int k = 0; k < octave; k++)
                {
                    //for each pixel location, get noise
                    float perlinValue = GenValue(w, h, width, height, freq);

                    //add to value per octave
                    finalValue += perlinValue * amp;

                    //apply new amp and freq
                    amp *= persistance;
                    freq *= lacunarity;
                }

                //store final noise in heightmap
                heightMap[w, h] = finalValue;

                if (finalValue > maxHeight)
                {
                    maxHeight = finalValue;
                }
            }
        }

        //generate the colour data from the perlin noise
        //then again, for each pixel, normalise the height
        for (int w = 0; w < width; w++)
        {
            for (int h = 0; h < height; h++)
            {
                //normalises our height between 0 and 1
                heightMap[w, h] /= maxHeight;

                //makes a colour map between black (0) and white (1)
                colorMap[h * width + w] = Color.Lerp(Color.black, Color.white, heightMap[w, h]);


            }
        }

        Texture2D tex = new Texture2D(width, height);
        tex.SetPixels(colorMap);
        tex.Apply();

        //SaveTextureAsPNG(tex, "Assets/Textures/heightMap.png");

        return tex;
    }

    private float GenValue(int x, int y, int width, int height, float frequency)
    {
        float xCoord = (float)x / width * scale * frequency + offset.x;
        float yCoord = (float)y / height * scale * frequency + offset.y;

        float value = Mathf.PerlinNoise(xCoord, yCoord);

        return value;
    }

    public float GetHeight(int x, int y)
    {
        return heightMap[x, y];
    }

    public static void SaveTextureAsPNG(Texture2D _texture, string _fullPath)
    {
        byte[] _bytes = _texture.EncodeToPNG();
        System.IO.File.WriteAllBytes(_fullPath, _bytes);
    }
}