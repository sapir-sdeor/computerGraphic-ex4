#ifndef CG_RANDOM_INCLUDED
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
#define CG_RANDOM_INCLUDED

// Returns a psuedo-random float between -1 and 1 for a given float c
float random(float c)
{
    return -1.0 + 2.0 * frac(43758.5453123 * sin(c));
}

// Returns a psuedo-random float2 with componenets between -1 and 1 for a given float2 c 
float2 random2(float2 c)
{
    c = float2(dot(c, float2(127.1, 311.7)), dot(c, float2(269.5, 183.3)));

    float2 v = -1.0 + 2.0 * frac(43758.5453123 * sin(c));
    return v;
}

// Returns a psuedo-random float3 with componenets between -1 and 1 for a given float3 c 
float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0*j);
    j *= .125;
    r.x = frac(512.0*j);
    j *= .125;
    r.y = frac(512.0*j);
    r = -1.0 + 2.0 * r;
    return r.yzx;
}

// Interpolates a given array v of 4 float values using bicubic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
//
// [0]=====o==[1]
//         |
//         t
//         |
// [2]=====o==[3]
//
float bicubicInterpolation(float v[4], float2 t)
{
    float2 u = t * t * (3.0 - 2.0 * t); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 4 float values using biquintic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
float biquinticInterpolation(float v[4], float2 t)
{
    float2 u = 6.0 * pow(t,5) - 15.0 * pow(t,4) + 10.0 * pow(t,3); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 8 float values using triquintic interpolation
// at the given ratio t (a float3 with components between 0 and 1)
float triquinticInterpolation(float v[8], float3 t)
{
    // Your implementation
    return 0;
}

// Returns the value of a 2D value noise function at the given coordinates c
float value2d(float2 c)
{
    float p0 = random2(float2(floor(c.x), floor(c.y))).x;
    float p1 = random2(float2(ceil(c.x), floor(c.y))).x;
    float p2 = random2(float2(floor(c.x), ceil(c.y))).x;
    float p3 = random2(float2(ceil(c.x), ceil(c.y))).x;
    float v[4] = {p0,p1,p2,p3};
    return bicubicInterpolation(v, float2(c.x - floor(c.x), c.y - floor(c.y)));
}

// Returns the value of a 2D Perlin noise function at the given coordinates c
float perlin2d(float2 c)
{
    float2 g0 = random2(float2(floor(c.x), floor(c.y)));
    float2 g1 = random2(float2(ceil(c.x), floor(c.y)));
    float2 g2 = random2(float2(floor(c.x), ceil(c.y)));
    float2 g3 = random2(float2(ceil(c.x), ceil(c.y)));
    float2 d0 = float2(floor(c.x), floor(c.y)) - c;
    float2 d1 = float2(ceil(c.x), floor(c.y)) - c;
    float2 d2 = float2(floor(c.x), ceil(c.y)) - c;
    float2 d3 = float2(ceil(c.x), ceil(c.y)) - c;
    float v[4] = {dot(g0,d0),dot(g1,d1),dot(g2,d2),dot(g3,d3)};
    return biquinticInterpolation(v, float2(c.x - floor(c.x), c.y - floor(c.y)));
}

// Returns the value of a 3D Perlin noise function at the given coordinates c
float perlin3d(float3 c)
{                    
    // Your implementation
    return 0;
}


#endif // CG_RANDOM_INCLUDED
