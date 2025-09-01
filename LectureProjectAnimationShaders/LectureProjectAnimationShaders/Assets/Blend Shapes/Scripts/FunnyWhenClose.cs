using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FunnyWhenClose : MonoBehaviour
{
    [SerializeField]
    float pixelRadius = 800;

    [SerializeField]
    float maxBlendShapeWeight = 100;

    SkinnedMeshRenderer skinnedMeshRenderer;
    int ohIndex = 0;
    int eyebrowUpIndex = 0;


    // Start is called before the first frame update
    void Start()
    {
        skinnedMeshRenderer = GetComponent<SkinnedMeshRenderer>();
        ohIndex = skinnedMeshRenderer.sharedMesh.GetBlendShapeIndex("HeadMouthShape_O");
        eyebrowUpIndex = skinnedMeshRenderer.sharedMesh.GetBlendShapeIndex("HeadEyebrowsUp");
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 screenPos = Camera.main.WorldToScreenPoint(transform.position);
        Vector3 cursorPos = Input.mousePosition;

        float distance = Vector2.Distance(screenPos, cursorPos);
        float factor = 1 - Mathf.Clamp01(distance / pixelRadius);

        skinnedMeshRenderer.SetBlendShapeWeight(ohIndex, maxBlendShapeWeight * factor);
        skinnedMeshRenderer.SetBlendShapeWeight(eyebrowUpIndex, maxBlendShapeWeight * factor);
    }
}
