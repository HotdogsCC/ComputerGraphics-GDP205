using UnityEngine;

public class HappyWhenClose : MonoBehaviour
{
    [SerializeField]
    float _PixelRadius = 800; // The radius of the pixel area around the object
    [SerializeField]
    float _MaxBlendShapeWeight = 100; // The maximum blend shape weight
    SkinnedMeshRenderer _skinnedMeshRenderer; // The skinned mesh renderer component of the object
    int _happyIndex; // The index of the blend shape named "HeadHappy"
    void Start()
    {
        _skinnedMeshRenderer = GetComponent<SkinnedMeshRenderer>(); // Get the skinned mesh renderer component
        _happyIndex = _skinnedMeshRenderer.sharedMesh.GetBlendShapeIndex("HeadHappy"); // Get the index of the blend shape named "HeadHappy"
    }
    void Update()
    {
        if (_skinnedMeshRenderer == null) // If the skinned mesh renderer is not assigned
            return;
        Vector3 screenPos = Camera.main.WorldToScreenPoint(transform.position); // Object position in screen space
        Vector3 cursorPos = Input.mousePosition; // Cursor position in screen space

        float distance = Vector2.Distance(new Vector2(screenPos.x, screenPos.y), new Vector2(cursorPos.x, cursorPos.y)); // Calculate the distance between the object and the cursor
        float factor = 1 - Mathf.Clamp01(distance / _PixelRadius); // Calculate the factor based on the distance between the object and the cursor

        _skinnedMeshRenderer.SetBlendShapeWeight(_happyIndex, _MaxBlendShapeWeight * factor); // Set the blend shape weight to a value between 0 and _MaxBlendShapeWeight

    }
}
