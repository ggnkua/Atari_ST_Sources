global_settings { assumed_gamma 2.2 }

#declare Yellow = rgb <0.95,0.95,0.75>;
#declare Green = rgb <0.65,0.95,0.65>;
#declare Blue = rgb <0,0,1>;
#declare Red = rgb <0.95,0.25,0.25>;
#declare Orange = rgb <0.99,0.65,0.15>;
#declare Grey70 = rgb <0.7,0.7,0.7>;
#declare Grey = rgb <0.8,0.8,1>;
#declare metal = finish{ambient 0.3 diffuse 0.3 specular 1 roughness 0.01 reflection 0.2}
#declare sqrt2 = 1.41421356237309504880168872420969;


camera {
  location<-8,-3,10>
  //location<0,0,10>
  look_at<0,0,0>
  angle 80
}

light_source { <-10, 10, 5> colour Grey70 fade_distance 100 fade_power 1 }
light_source { <10, -10, 20> colour Grey70 fade_distance 100 fade_power 1 }

background {color rgb<1,1,1>}

//fog{distance 15 color rgb<0.7, 0.7, 0.9>}

  //le panneau
  union{
    box{ < 3.9, 0.9,-0.9> <-3.9, -0.9,-0.05> }
    box{ <0,0,-0.05> <sqrt2, sqrt2,-1.0> rotate<0,0,225> translate <-4.0, 1.0, 0.0>}
    box{ <0,0,-0.05> <sqrt2,-sqrt2,-1.0> rotate<0,0,135> translate <-4.0,-1.0, 0.0>}
    texture{ pigment{color <1,1,1>} }
  }
  union{
    box{ < 4.0, 0.8,-1.0> <-4.0, 1.0, 0.0> }
    box{ < 4.0,-0.8,-1.0> <-4.0,-1.0, 0.0> }
    box{ < 4.0, 1.0, 0.0> < 3.8,-1.0,-1.0> }
    box{ <0,0,0> <sqrt2, 0.2,-1.0> rotate<0,0,225> translate <-4.0, 1.0, 0.0>}
    box{ <0,0,0> <sqrt2,-0.2,-1.0> rotate<0,0,135> translate <-4.0,-1.0, 0.0>}
    texture{ pigment{color <0,0,0>} }
  }
  // le poteau
  union{
    box{ < 0.4,-8.0,-0.9> <-0.4,1.5,-0.1> }
    texture{ pigment{color <1,1,1>} }
  }
  
  union{
    box{ < 0.45,-8.0,-0.95> < 0.35,1.5,-0.85>}
    box{ <-0.45,-8.0,-0.95> <-0.35,1.5,-0.85>}
    box{ < 0.45,-8.0,-0.05> < 0.35,1.5,-0.15>}
    box{ <-0.45,-8.0,-0.05> <-0.35,1.5,-0.15>}
    
    box{ <-0.45,1.45,-0.05> < 0.45,1.55,-0.15>}
    box{ <-0.45,1.45,-0.05> <-0.35,1.55,-0.95>}
    
    texture{ pigment{color <0,0,0>} }
  }
    
//OUTLINE LOGO
text {
  ttf "c:\Windows\Fonts\verdanab.ttf" "OUTLINE" 0.2, 0
  rotate <0,180,0>
  scale <1.5,1.3,0.7>
  translate <3.5,-0.5,0>
  texture{
    pigment{color <0,0,0>}
    normal{
     agate 0.4
     scale 0.2
    }
//    finish{diffuse 0.4 phong 0.8 phong_size 10 reflection 0.2}
  }
}
