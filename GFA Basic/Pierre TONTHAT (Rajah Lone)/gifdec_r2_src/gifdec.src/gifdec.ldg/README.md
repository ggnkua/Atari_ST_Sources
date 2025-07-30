# gifdec.ldg

Library using the LDG system and the GIF decoder functions from GIFLIB.
Instead of generating TC24 bitmap, the result is 2D width x height sized byte-array of colors indexes (ie chunky format).

Used by:

* P2SM to handle large GIF pictures.
* MAKE_MAP to slice large GIF into tiles and map array.

Other programs can use it, please read these sources and P2SM GFA source.

# installation for makefiles

- pre-requisite: different targets of libldg.a in /opt/cross-mint/m68k-atari-mint/lib/

- in an empty folder,  
   ```mkdir ./build/68000```  
   ```mkdir ./build/68020```  
   ```mkdir ./build/ColdFire```  

- get /gifdec.ldg/ from [gifdec_r2_src.zip](https://ptonthat.fr/files/gifdec/gifdec_r2_src.zip) and unpack the contents to ./

- gifdec.ldg.xcodeproj is for Xcode 16.3, you may not need it if you use something else.
