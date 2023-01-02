#ifndef CG_UTILS_INCLUDED
#define CG_UTILS_INCLUDED

#define PI 3.141592653

// A struct containing all the data needed for bump-mapping
struct bumpMapData
{ 
    float3 normal;       // Mesh surface normal at the point
    float3 tangent;      // Mesh surface tangent at the point
    float2 uv;           // UV coordinates of the point
    sampler2D heightMap; // Heightmap texture to use for bump mapping
    float du;            // Increment size for u partial derivative approximation
    float dv;            // Increment size for v partial derivative approximation
    float bumpScale;     // Bump scaling factor
};


// Receives pos in 3D cartesian coordinates (x, y, z)
// Returns UV coordinates corresponding to pos using spherical texture mapping
float2 getSphericalUV(float3 pos)
{
    float r = sqrt(pow(pos.x,2) + pow(pos.y,2) + pow(pos.z,2));
    float teta = atan2(pos.z, pos.x);
    float gama = acos(pos.y/r);
    float2 uv = float2(0.5 + (teta/(2*UNITY_PI)), 1-(gama/UNITY_PI));
    return uv;
}

// Implements an adjusted version of the Blinn-Phong lighting model
fixed3 blinnPhong(float3 n, float3 v, float3 l, float shininess, fixed4 albedo, fixed4 specularity, float ambientIntensity)
{
    //TODO: check if v or h
    fixed4 ambient = ambientIntensity * albedo;
    fixed4 diffuse = max(0, dot(n,l)) * albedo;
    fixed4 specular = pow(max(0, dot(n,v)), shininess) * specularity;
    return ambient + diffuse + specular;
}

// Returns the world-space bump-mapped normal for the given bumpMapData
float3 getBumpMappedNormal(bumpMapData i)
{
    float fTagV = (tex2D(i.heightMap, i.uv+i.dv) - tex2D(i.heightMap, i.uv))/i.dv;
    float3 tv = float3(0,1,fTagV);
    float3 beforeBumpScale = cross(tv,i.tangent);
    float3 nh = UnityObjectToWorldDir
            (normalize(float3(beforeBumpScale.x * i.bumpScale, beforeBumpScale.y * i.bumpScale, beforeBumpScale.z)));
    i.normal = UnityObjectToWorldDir(i.normal);
    i.tangent = UnityObjectToWorldDir(i.tangent);
    float3 b = cross(i.normal, i.tangent);
    float3 nWorld = (i.tangent * nh.x) + (i.normal * nh.z) + (b * nh.y);
    return nWorld.xyz;
}


#endif // CG_UTILS_INCLUDED
