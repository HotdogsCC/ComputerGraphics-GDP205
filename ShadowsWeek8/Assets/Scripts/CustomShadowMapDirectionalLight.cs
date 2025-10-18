using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CustomShadowMapDirectionalLight : MonoBehaviour
{
    [SerializeField] private Camera _lightCamera;

    [Header("Light Camera Settings")] 
    public int OrthographicSize = 10;
    public int ShadowMapResolution = 1024;

    [SerializeField] private RenderTexture _CustomShadowMapTexture;
    
    //custom implementations of runtime functions so that we can do this in editor
    private void Start() => Init();
    private void OnEnable() => Init();
    private void OnValidate() => Init();
    private void OnDisable() => CleanUp();

    private void OnDestroy() => CleanUp();

    //custom Start function
    private void Init()
    {
        CreateLightCamera();
        ConfigureLightCameraProperties();
        CreateShadowMap();
    }

    private void LateUpdate()
    {
        MoveCameraToLight();
        SetCameraToRenderTarget();
        RenderShadowMap();
    }

    private void OnGUI()
    {
        GUILayout.Box(GUIContent.none, GUILayout.Width(400), GUILayout.Height(400));
        Rect lastRect = GUILayoutUtility.GetLastRect();
        GUI.DrawTexture(lastRect, _CustomShadowMapTexture, ScaleMode.StretchToFill, false);
    }

    //custom cleanup
    private void CleanUp()
    {
        //does the light camera exist?
        if (_lightCamera != null)
        {
            //destroy the light camera
            DestroyImmediate(_lightCamera.gameObject);
            _lightCamera = null;
        }
        
        //does the shadow map still exist?
        if (_CustomShadowMapTexture != null)
        {
            _CustomShadowMapTexture.Release();
            DestroyImmediate(_CustomShadowMapTexture);
            _CustomShadowMapTexture = null;
        }
    }

    private void CreateLightCamera()
    {
        //is the light camera null?
        if (!_lightCamera)
        {
            //try to find the light camera component
            _lightCamera = GameObject.Find("Light Camera " + this.gameObject.GetInstanceID())?.GetComponent<Camera>();
            
            //is it still null?
            if (!_lightCamera)
            {
                //create a new game object
                GameObject lightCameraObject = new GameObject("LightCamera " + this.gameObject.GetInstanceID());
                
                //set its transform to be where this is
                lightCameraObject.transform.SetParent(this.transform);
                
                //add a camera component to the game object and save a reference
                _lightCamera = lightCameraObject.AddComponent<Camera>();
            }
            
        }
        
        //is the camera a child of this object?
        if (_lightCamera.gameObject.transform.parent != this.transform)
        {
            //make it so it is a child
            _lightCamera.transform.SetParent(this.transform);
        }
    }

    private void ConfigureLightCameraProperties()
    {
        //do we have a light camera?
        if (_lightCamera == null)
        {
            //make one
            CreateLightCamera();
        }
        
        //set the camera properties
        _lightCamera.orthographic = true;
        _lightCamera.orthographicSize = OrthographicSize;
        _lightCamera.aspect = 1.0f;
        _lightCamera.nearClipPlane = 0.1f;
        _lightCamera.farClipPlane = 50.0f;
        
        //make sure the camera isnt edited in inspector
        _lightCamera.transform.SetParent(this.transform);
        _lightCamera.enabled = false;
        _lightCamera.transform.localScale = Vector3.one;
        _lightCamera.transform.hideFlags = HideFlags.NotEditable;
        _lightCamera.hideFlags = HideFlags.NotEditable;
    }

    private void MoveCameraToLight()
    {
        //is the light camera null
        if (!_lightCamera)
        {
            //make one
            CreateLightCamera();
        }
        
        //match cameras pos and rot with this object
        float depth = Mathf.Abs(_lightCamera.farClipPlane - _lightCamera.nearClipPlane);
        _lightCamera.transform.position = transform.position - transform.forward * (depth * 0.5f);
        _lightCamera.transform.rotation = transform.rotation;
    }

    private void CreateShadowMap()
    {
        //do we currently have a shadow map texture?
        if (_CustomShadowMapTexture != null)
        {
            //get rid of it
            _CustomShadowMapTexture.Release();
        }

        _CustomShadowMapTexture =
            new RenderTexture(ShadowMapResolution, ShadowMapResolution, 16, RenderTextureFormat.Depth);
        _CustomShadowMapTexture.wrapMode = TextureWrapMode.Clamp;
        _CustomShadowMapTexture.filterMode = FilterMode.Bilinear;
        _CustomShadowMapTexture.Create();
    }

    private void SetCameraToRenderTarget()
    {
        if (!_lightCamera)
        {
            Debug.LogError("light camera is not set");

            return;
        }

        if (!_CustomShadowMapTexture)
        {
            Debug.LogError("shadow map texture is not set");

            return;
        }
        
        //set target texture to shadow map render texture
        _lightCamera.targetTexture = _CustomShadowMapTexture;
        _lightCamera.clearFlags = CameraClearFlags.SolidColor;
        _lightCamera.backgroundColor = Color.white;
        _lightCamera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void RenderShadowMap()
    {
        if (!_lightCamera)
        {
            Debug.LogError("light camera is not set");

            return;
        }

        if (!_CustomShadowMapTexture)
        {
            Debug.LogError("shadow map texture is not set");

            return;
        }
        
        //render the shadow map
        _lightCamera.Render();
    }
}
