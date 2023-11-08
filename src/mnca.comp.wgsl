struct SimParams {
    seedRadius : f32,
    nstates : f32,
    rez : f32,
    rowPitch : f32,
    mousex : f32,
    mousey : f32,
    mouse : f32
};

struct Cells {
    data : array<f32>
};

@binding(0) @group(0) var<uniform> params : SimParams;
@binding(1) @group(0) var<storage, read> currentCells : Cells;
@binding(2) @group(0) var<storage, read_write> cells : Cells;
@binding(3) @group(0) var outputTex : texture_storage_2d<rgba8unorm, write>;

// via "The Art of Code" on Youtube
fn Random(p : vec2<f32>) -> vec2<f32> {
    var a : vec3<f32> = fract(p.xyx * vec3<f32>(123.34, 234.34, 345.65));
    a = a + dot(a, a + 34.45);
    return fract(vec2<f32>(a.x * a.y, a.y * a.z));
}

fn toCellIndex(coords : vec2<i32> ) -> u32 {
   return u32(coords.y * i32(params.rez) + coords.x); 
}

fn S(coords : vec2<i32>, offset : vec2<i32>, next : i32) -> i32 {
    var cellIdx : u32 = toCellIndex(coords + offset);
    return i32(currentCells.data[cellIdx] > 0.0);
}

fn renderColor(state : f32, statesNum : f32) -> vec4<f32> {
    var v = state / statesNum;
    return vec4<f32>(v, v, v, 1.0);
}

fn brightness_(color : vec3<f32>) -> f32 {
  var fold = vec3<f32>(0.299, 0.587 , 0.114) * color * color;
  return sqrt(fold.x + fold.y + fold.z);
}

fn sRGBtoLin(colorChannel : f32) -> f32 {
  // Send this function a decimal sRGB gamma encoded color value
  // between 0.0 and 1.0, and it returns a linearized value.

  if ( colorChannel <= 0.04045 ) {
    return colorChannel / 12.92;
  } else {
    return pow((( colorChannel + 0.055)/1.055),2.4);
  }
}

fn luminance(color : vec3<f32>) -> f32 {
  var lin = vec3<f32>(sRGBtoLin(color.x), sRGBtoLin(color.y), sRGBtoLin(color.z));
  var coef = vec3<f32>(0.2126, 0.7152, 0.0722);
  //var coef = vec3<f32>(0.299 , 0.587 , 0.114);
  var rng = lin * coef;
  return rng.x + rng.y + rng.z;
}

fn YtoLstar(Y : f32) -> f32 {
  // Send this function a luminance value between 0.0 and 1.0,
  // and it returns L* which is "perceptual lightness"

  if ( Y <= (216.0/24389.0)) {       // The CIE standard states 0.008856 but 216/24389 is the intent for 0.008856451679036
    return Y * (24389.0/27.0);  // The CIE standard states 903.3, but 24389/27 is the intent, making 903.296296296296296
  } else {
    return pow(Y,(1.0/3.0)) * 116.0 - 16.0;
  }
}

fn brightness(color : vec3<f32>) -> f32 {
 //return YtoLstar(luminance(color));
 return luminance(color);
}

@compute @workgroup_size(64, 1, 1)
fn main(@builtin(global_invocation_id) GlobalInvocationID : vec3<u32>) {
    // var index : u32 = u32(GlobalInvocationID.x);
    var coords : vec2<i32> = vec2<i32>(GlobalInvocationID.xy);
    var ray = vec2<f32>(coords) - vec2<f32>(256, 256);
    var sat = clamp(length(ray)/200.0, 0.0, 1.0);
    var theta = atan2(ray.x, ray.y);
    if (theta < 0) {
      theta += 6.283185307179586;
    }
    var mf = modf(theta / 2.0943951023931953);
    var hue : vec3<f32>;
    if (mf.whole == 0) {
      hue = vec3<f32>(0,1,0) * mf.fract + (1 - mf.fract) * vec3<f32>(1,0,0);
    } else if (mf.whole == 1) {
      hue = vec3<f32>(0,0,1) * mf.fract + (1 - mf.fract) * vec3<f32>(0,1,0);
    } else if (mf.whole == 2) {
      hue = vec3<f32>(1,0,0) * mf.fract + (1 - mf.fract) * vec3<f32>(0,0,1);
    }
    var color = sat * hue + (1-sat) * vec3<f32>(1,1,1);
    
    var target_color = vec3<f32>(1,0,0);
    //color *= (brightness_(vec3<f32>(0,0,1))/brightness_(color));
    //textureStore(outputTex, coords, vec4<f32>(color, 1.0));
    //return;

    
    var target_brightness = brightness(target_color);
    var max_component = max(color.x, max(color.y, color.z));
    var xi = color * 1.5;
    var xim = color / 1.5;

    for (var i = 0u; i < 10; i++) {
      var bxi = brightness(xi);
      var bxim = brightness(xim);
      var xip = xi - (bxi - target_brightness) * (xi - xim) / (bxi - bxim);
      if (distance(bxi, bxim) > 0.0000000001)
      {
        xim = xi;
        xi = xip;
      }
    }
    //var b = brightness(xi) / 100;
    textureStore(outputTex, coords, vec4<f32>(xi, 1.0));
    
    
}
