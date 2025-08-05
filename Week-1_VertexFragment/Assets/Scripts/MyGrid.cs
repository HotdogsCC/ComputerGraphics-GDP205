using System.Collections;
using System.Collections.Generic;
using System.Xml.Schema;
using UnityEngine;

// Requirning MeshFilter
[RequireComponent(typeof(MeshFilter))]

public class MyGrid : MonoBehaviour
{
    Mesh mesh;
    Vector3[] vertices;
    int[] triangles;
    private Vector2[] uv;

    public int xSize, zSize;
    public int width, depth;

    public float maxHeight;

    private void Start()
    {
        GenerateMesh();
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
                float y = 4.0f * (Mathf.Sin(0.5f * x) + Mathf.Cos(0.5f * z));
                
                if(maxHeight < y)
                {
                    maxHeight = y;
                }

                //save the pos
                vertices[vertex] = new Vector3(a, 0, b);
                
                //save texture coordinate
                uv[vertex] = new Vector2(x * du, z * dv);
                
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


        // clear and set verticies and triangle properties
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uv;

        mesh.RecalculateNormals();
    }
}
