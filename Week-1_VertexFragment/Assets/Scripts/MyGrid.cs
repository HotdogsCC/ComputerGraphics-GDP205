using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Requirning MeshFilter
[RequireComponent(typeof(MeshFilter))]

public class MyGrid : MonoBehaviour
{
    private PerlinNoiseTexture noiseTexture;

    Mesh mesh;
    Vector3[] vertices;
    int[] triangles;
    private Vector2[] uv;
    private Vector3[] normals;

    public int xSize, zSize;
    public int width, depth;

    public float maxHeight;
    private readonly int height = Shader.PropertyToID("_height");

    private void Start()
    {
        noiseTexture = GetComponent<PerlinNoiseTexture>();

        Renderer renderer = GetComponent<Renderer>();
        renderer.material.mainTexture = noiseTexture.GenTexture(width, depth);
        renderer.material.SetFloat("_height", 1.0f);
        
        GenerateMesh();
    }

    private void Update()
    {
        PerlinNoiseTexture noiseTexture = GetComponent<PerlinNoiseTexture>();

        Renderer renderer = GetComponent<Renderer>();
        renderer.material.mainTexture = noiseTexture.GenTexture(width, depth);
        renderer.material.SetFloat(height, 100.0f);
    }

    private void GenerateMesh()
    {
        // create new Mesh()
        mesh = new Mesh();

        // get mesh property of Mesh Filter Component
        // and Assign our mesh variable to it
        GetComponent<MeshFilter>().mesh = mesh;

        // calculate the total number of vertices
        vertices = new Vector3[(xSize + 1) * (zSize + 1)];
        
        //vec2 array to store texture coordinates
        uv = new Vector2[vertices.Length];

        //vec2 to store normals
        normals = new Vector3[vertices.Length];

        // we want grid to be centered around the origin
        float halfWidth = 0.5f * width;
        float halfDepth = 0.5f * depth;

        //calc distance between verts
        float dx = width / (xSize - 1.0f);
        float dz = depth / (zSize - 1.0f);

        //calculate distance between each texture coordinate
        float du = 1.0f / (xSize - 1);
        float dv = 1.0f / (zSize - 1);

        int vertex = 0;
        for(int x = 0; x <= xSize; x++)
        {
            //calculate new pos in x
            float a = halfWidth - x * dx;

            for (int z = 0; z <= zSize; z++)
            {
                //calc new pos in z
                float b = -halfDepth + z * dz;

                //generate height for the vertext
                //float y = 4.0f * (Mathf.Sin(0.5f * x) + Mathf.Cos(0.5f * z));
                float y = noiseTexture.GetHeight(x, z) * 100;

                if (maxHeight < y)
                {
                    maxHeight = y;
                }

                

                //save the pos
                vertices[vertex] = new Vector3(a, y, b);
                
                //save texture coordinate
                uv[vertex] = new Vector2(x * du, z * dv);

                //init the normal
                normals[vertex] = new Vector3(0.0f, 1.0f, 0.0f);
                
                vertex++;
            }
        }

        Debug.Log(maxHeight);

        //total indices to be genrated
        triangles = new int[xSize * zSize * 6];

        //variables to increment
        //verticies and indicies to count
        int vert = 0;
        int quad = 0;

        for(int z = 0; z < zSize; z++)
        {
            for (int x = 0; x < xSize; x++)
            {
                triangles[quad + 0] = vert + 0;
                triangles[quad + 1] = vert + xSize + 1;
                triangles[quad + 2] = vert + 1;

                triangles[quad + 3] = vert + 1;
                triangles[quad + 4] = vert + xSize + 1;
                triangles[quad + 5] = vert + xSize + 2;

                vert++;
                quad += 6;
            }

            vert++;
        }

        //generate normals
        vert = 0;
        int triCount = triangles.Length / 3;

        for (int i = 0; i < triCount; i++)
        {
            //vertices of the triangle
            int i0 = triangles[vert + 0];
            int i1 = triangles[vert + 1];
            int i2 = triangles[vert + 2];

            //points of the vertices
            Vector3 p0 = vertices[i0];
            Vector3 p1 = vertices[i1];
            Vector3 p2 = vertices[i2];

            //lines forming the triangle
            Vector3 e1 = p1 - p0;
            Vector3 e2 = p2 - p0;

            //get the normal
            Vector3 norm = Vector3.Cross(e1, e2);
            norm = Vector3.Normalize(norm);

            //add the normals
            normals[i0] = norm;
            normals[i1] += norm;
            normals[i2] += norm;

            vert += 3;
        }

        for (int i = 0; i < normals.Length; i++)
        {
            normals[i].Normalize();
        }


        // clear and set verticies and triangle properties
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uv;
        mesh.normals = normals;

        //mesh.RecalculateNormals();
    }
}
