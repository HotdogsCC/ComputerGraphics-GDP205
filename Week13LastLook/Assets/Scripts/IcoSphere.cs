using System.Collections;
using System.Collections.Generic;
using UnityEditor.ShaderGraph.Internal;
using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class IcoSphere : MonoBehaviour
{
    private struct Triangle
    {
        public Triangle(int a, int b, int c) { v1 = a; v2 = b; v3 = c; }

        public int v1, v2, v3;
    }

    [Header("Icosphere Settings")]
    [Range(0, 6)] public int subdivisions = 2;
    [Min(0.01f)] public float radius = 1.0f;

    private int lastSubdivisions;
    private float lastRadius;

    private MeshFilter meshFilter;
    private Mesh generatedMesh;

    private bool IsChangeMade()
    {
        bool change = lastSubdivisions != subdivisions || lastRadius != radius;
        if(change)
        {
            lastSubdivisions = subdivisions;
            lastRadius = radius;
        }
        return change;
    }

    public void Start()
    {
        meshFilter = GetComponent<MeshFilter>();
    }

    public void Update()
    {
        if(IsChangeMade())
        {
            GenerateMesh();
        }
    }

    private void GenerateMesh()
    {
        generatedMesh = GenerateIcosphere(subdivisions, radius);
        generatedMesh.name = $"Icosphere Sub{subdivisions}_R{radius:F2}";
        meshFilter.sharedMesh = generatedMesh;
    }

    private Mesh GenerateIcosphere(int subdivisions, float radius)
    {
        //golden ratio constant used to define the base icosahedron shape
        float t = (1.0f + Mathf.Sqrt(5.0f)) / 2.0f;

        //crate the 12 initial verts of an icosahedron
        var verts = new List<Vector3>
        {
            new Vector3(-1,  t, 0), new Vector3( 1,  t, 0), 
            new Vector3(-1, -t, 0), new Vector3( 1, -t, 0),
            
            new Vector3(0, -1,  t), new Vector3(0,  1,  t), 
            new Vector3(0, -1, -t), new Vector3(0,  1, -t),
            
            new Vector3( t, 0, -1), new Vector3( t, 0,  1), 
            new Vector3(-t, 0, -1), new Vector3(-t, 0,  1)

        };

        //normalize each vertex so they lie on the surface of a unit sphere,
        //then scale by desired radius
        for (int i = 0; i < verts.Count; i++)
        {
            verts[i] = verts[i].normalized * radius;
        }

        //define the 20 triangular faces that make up the base icosahedron
        var triangles = new List<Triangle>
        {
            new Triangle(0,11,5), new Triangle(0,5,1), new Triangle(0,1,7), new Triangle(0,7,10), new Triangle(0,10,11),
            new Triangle(1,5,9), new Triangle(5,11,4), new Triangle(11,10,2), new Triangle(10,7,6), new Triangle(7,1,8),
            new Triangle(3,9,4), new Triangle(3,4,2), new Triangle(3,2,6), new Triangle(3,6,8), new Triangle(3,8,9),
            new Triangle(4,9,5), new Triangle(2,4,11), new Triangle(6,2,10), new Triangle(8,6,7), new Triangle(9,8,1)

        };

        //helper function to create a midpoint between two verts
        Dictionary<long, int> midpointCache = new Dictionary<long, int>();
        int GetMidpoint(int a, int b)
        {
            //ensure consistent key regardless of triangle winding
            long key = ((long)Mathf.Min(a, b) << 32) + Mathf.Max(a, b);

            if(midpointCache.TryGetValue(key, out int index))
            {
                return index;
            }

            Vector3 midpoint = ((verts[a] + verts[b]) * 0.5f).normalized * radius;

            verts.Add(midpoint);
            int newIndex = verts.Count - 1;
            midpointCache[key] = newIndex;
            return newIndex;
        }

        //subdivide each triangle to create a smoother better more awesome sphere
        for (int i = 0; i < subdivisions; i++)
        {
            var newTriangles = new List<Triangle>();
            foreach (var tri in triangles)
            {
                //create new vertices at the midpoints of each triangle edge
                int a = GetMidpoint(tri.v1, tri.v2);
                int b = GetMidpoint(tri.v2, tri.v3);
                int c = GetMidpoint(tri.v3, tri.v1);

                //split the triangle into 4 smaller triangles
                newTriangles.Add(new Triangle(tri.v1, a, c));
                newTriangles.Add(new Triangle(tri.v2, b, a));
                newTriangles.Add(new Triangle(tri.v3, c, b));
                newTriangles.Add(new Triangle(a, b, c));
            }

            triangles = newTriangles;
        }

        //flatten the triangle list into a simple index array
        var indices = new List<int>();
        foreach (var tri in triangles)
        {
            indices.Add(tri.v1);
            indices.Add(tri.v2);
            indices.Add(tri.v3);
        }

        //create the UVs for the mesh
        var uvs = new List<Vector2>();
        foreach (var vertex in verts)
        {
            //map each vertex to a uv coord based on its normalized position
            Vector2 uv = new Vector2(
                Mathf.Atan2(vertex.z, vertex.x) / (2 * Mathf.PI) + 0.5f,
                Mathf.Acos(vertex.y / radius) / Mathf.PI
            );
            uvs.Add(uv);
        };

        //create a unity mesh
        var mesh = new Mesh();

        mesh.indexFormat = (verts.Count > 65535) ?
            UnityEngine.Rendering.IndexFormat.UInt32 :
            UnityEngine.Rendering.IndexFormat.UInt16;

        mesh.SetVertices(verts);
        mesh.SetTriangles(indices, 0);
        mesh.SetUVs(0, uvs);

        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        return mesh;
    }

}
