//---------------------------------------------------------
// BLOB.POV : faked raytracing effect
//---------------------------------------------------------
// TOBE / MJJPROD

// offset-map generator

// -- setup -----------------------------------------------

global_settings {
   max_trace_level 16
} 

// 1 = render reflection
// 2 = render refraction
// 3 = render lightning
#declare debug_mode=1;

#switch (clock)
   #case (0)
      #switch (debug_mode)
         #case (1)
            #declare render_reflec=1;
            #break
         #case (2)
            #declare render_refrac=1;
            #break
         #case (3)
            #declare render_lights=1;
            #break
      #end
      #break
   #case (1)
      #declare render_reflec=1;
      #break
   #case (2)
      #declare render_refrac=1;
      #break
   #case (3)
      #declare render_lights=1;
      #break
#end


// -- pigment ---------------------------------------------

#declare pigment_xoffset = pigment {
   gradient x
   color_map {
      [0.00, rgb <0.0,0.0,0.0>]
      [1.00, rgb <0.0,0.0,2.0>]
   }
}

#declare pigment_yoffset = pigment {
   gradient -y
   color_map {
      [0.00, rgb <0.0,0.0,0.0>]
      [1.00, rgb <2.0,0.0,0.0>]
   }
}

#declare pigment_offset  = pigment {
   average
   pigment_map {
      [1.0, pigment_xoffset]
      [1.0, pigment_yoffset]
   }
   scale 10.0
   translate <1000.0,1000.0,0.0>
}

#declare pigment_reflec = pigment {
   color rgb  <1.0,1.0,1.0>
}

#declare pigment_refrac = pigment {
   color rgbf <1.0,1.0,1.0,1.0>
}

#declare pigment_lights = pigment {
   color rgb  <1.0,1.0,1.0>
}

#declare pigment_glass  = pigment {
   color rgbf <1.0,1.0,1.0,1.0>
}

// -- finish ----------------------------------------------

#declare finish_offset = finish {
   ambient    1.0
   diffuse    0.0
   reflection 0.0   
}

#declare finish_reflec = finish {
   ambient    0.0
   diffuse    0.0
   reflection 1.0   
}

#declare finish_refrac = finish {
   ambient    0.0
   diffuse    0.0
   reflection 0.0
}

#declare finish_lights = finish {
   ambient    0.0
   diffuse    0.3
   reflection 0.0
}

#declare finish_glass  = finish {
   ambient    0.20
   diffuse    0.0
   reflection 0.4
   phong      1.0
   phong_size 50
}

// -- texture ---------------------------------------------

#declare texture_offset = texture {
   pigment { pigment_offset }
   finish  { finish_offset  }
}

#declare texture_reflec = texture {
   pigment { pigment_reflec }
   finish  { finish_reflec  }
}

#declare texture_refrac = texture {
   pigment { pigment_refrac }
   finish  { finish_refrac  }
}

#declare texture_lights = texture {
   pigment { pigment_lights }
   finish  { finish_lights  }
}

#declare texture_glass  = texture {
   pigment { pigment_glass  }
   finish  { finish_glass   }
}

// -- interior --------------------------------------------

#declare interior_offset = interior {
}

#declare interior_reflec = interior {
}

#declare interior_refrac = interior {
   ior           1.3
}

#declare interior_lights = interior {
}

#declare interior_glass  = interior {
   ior           1.3
   fade_power    1.0
   fade_distance 4.0
}

// -- object ----------------------------------------------

sphere { 0.0, 10.0
   
#ifdef (render_reflec)
   texture  { texture_offset  }
   interior { interior_offset }
#end

#ifdef (render_refrac)
   texture  { texture_offset  }
   interior { interior_offset }
#end

#ifdef (render_lights)
   texture  { texture_lights  }
   interior { interior_lights }
#end

   no_shadow
   hollow
}

#declare object_spheres = blob {
  threshold 0.6
  component 1.0, 1.0, <0.75, 0, 0>
  component 1.0, 1.0, <-0.375, 0.64952, 0>
  component 1.0, 1.0, <-0.375, -0.64952, 0>
  no_shadow
  rotate <-20.0,20.0,10.0>
}

#ifdef (render_reflec)
object { object_spheres
   texture  { texture_reflec  }
   interior { interior_reflec }
}
#end

#ifdef (render_refrac)
object { object_spheres
   texture  { texture_refrac  }
   interior { interior_refrac }
}
#end

#ifdef (render_lights)
object { object_spheres
   texture  { texture_glass   }
   interior { interior_glass  }
}
#end

// -- lights ----------------------------------------------

#ifdef (render_lights)
light_source { <100.0,-50.0,-50.0>
   rgb 1.0
}
light_source { <50.0,100.0,50.0>
   rgb 1.0
}
light_source { <-50.0,50.0,-50.0>
   rgb 1.0
}
#end

// -- camera ----------------------------------------------

camera {
   right x*1.333
   up y
   location <0.0,1.0,-1.9>
   look_at <0.08,0.20,0.0>
}
