using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode] // ExecuteInEditMode allows the script to run in the editor. be careful this is a double edged sword.
public class MyEffector : MonoBehaviour
{
    [SerializeField]
    GameObject _Plant; // The plant to be affected
    List<Material> _materials = new List<Material>(); // a cache of the materials used by the plant
    [SerializeField]
    [Range(0, 100)]
    float _EffectorRadius = 1.0f; // The radius of the effector 
    [SerializeField]
    [Range(0, 100)]
    float _EffectorStrength = 1.0f; // The strength of the effector

    void Start()
    {
        if (_Plant == null)
        {
            Debug.LogError("Effector: No plant assigned.");
            return;
        }

        _materials = GetSharedMaterials(_Plant); // cache the materials used by the plant
    }

#if UNITY_EDITOR // this macro removes the code from the build and only includes it in the editor
    void OnValidate() // OnValidate is called when a change is made to a script in the editor
    {
        if (_Plant == null)
        {
            Debug.LogError("Effector: No plant assigned.");
            return;
        }

        _materials = GetSharedMaterials(_Plant);
        SetMaterialProperties();
    }
#endif

    void Update()
    {
        Vector3 Offset = new Vector3(0, 0, 0);
        Offset.x += Input.GetAxis("Horizontal");
        Offset.z += Input.GetAxis("Vertical");

        transform.position += (Offset * Time.deltaTime);

        SetMaterialProperties();// we are going to update the material properties every frame. usually you would only want to do this only when the properties change
    }

    void SetMaterialProperties()
    {
        if (_materials == null || _materials.Count == 0) // early exit if the cache is empty
        {
            Debug.LogError("Effector: No materials found.");
            return;
        }

        foreach (var material in _materials) // loop through the materials and set the properties
        {
            if (material != null)
            {
                material.SetFloat("_EffectorStrength", _EffectorStrength);
                material.SetVector("_EffectorSource", new Vector4(transform.position.x, transform.position.y, transform.position.z, _EffectorRadius));
            }
        }
    }


    List<Material> GetSharedMaterials(GameObject obj) // gets all the shared materials from the object and its children
    {
        var materials = new List<Material>();
        var renderers = obj.GetComponentsInChildren<MeshRenderer>();

        foreach (var renderer in renderers)
        {
            if (renderer == null || renderer.sharedMaterials == null)
                continue;

            foreach (var material in renderer.sharedMaterials)
            {
                if (material != null && !materials.Contains(material))
                {
                    materials.Add(material);
                }
            }
        }

        return materials;
    }

#if UNITY_EDITOR
    void OnDrawGizmos() // OnDrawGizmos is a render call within the editor that allows you to draw gizmos in the scene view
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, _EffectorRadius);
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, _EffectorStrength);

    }
#endif
}
