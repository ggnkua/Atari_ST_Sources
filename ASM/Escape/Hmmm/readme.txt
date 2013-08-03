                    
                    
                    
                                                           Dresden, 01.06.01
       
                    
                    
                   Hmmm... Sourcecode of the Demo by Escape
                    
                    
                    

General
=======
                    
This is the complete sourcecode of the Hmmm... demo. Every effect of the
demo is a module - very like a whip!-module. There is a test environment
to develop such modules. The test environment is included here, too.
It provides some useful routines and data to the effect modules.
The test environment can be used to create stand alone versions
of the effects. The main program of the demo links all effects together.
All modules can share some data like a sine table and textures. 
So the modules care just about the effect and nothing else. 
There are some hard wired path information included in the source code.
I used the path e:\demo\ when I coded the demo. If you dont want to
torment yourself with the path crap, just copy all the files into the
folder e:\demo\. The demo searches in e:\e3d\ for the 3d object files.
So it is the best to copy all *.e3d files into this location.
All CPU sources are in *.SRC format which can be handled by TurboAss.
All DSP sources are in *.S56 format which can be handled by DSPDit.

What are all those folders? What are all those files?
=====================================================

Tools and demo engine
---------------------

./3DCONV/
  This is a small conversion program which converts *.bdy 3D data files
  into something more useful for us. The *.bdy files contain 3D object
  data - points, faces, material. The points are stored in a floating
  point format which is bad when coding assembly and not owning a fpu.
  The resulting *.e3d files contain very simple structured data. The
  main thing is that the points are stored in a 32bit fixpoint format. 
  The upper 16bit are the integer part and the lower 16bit are the
  fractional part of a value.
./BDY/
  Here you can find all 3D objects I used in the demo.
./E3D/
  The converted versions of the 3D objects.
./TESTENV/
  This is the effect test environment. I used it to develop the single
  effects. It contains all needed initialisations, deinitialisations and
  some useful routines which are easy accessable by the effects. The 
  test environment is just a binary. An effect can use it by include
  it at the very first position in the sourcecode. Just take a look at
  a single effect... 
  MOD2RSP.TTP is a patched version of the original modfile conversion
  program by exa. The patches were needed to achive the effect sync
  functionality of the player. 
./LIGHTGEN/
  Here are some small tools that 'generate' light source textures. The
  program trpconv converts *.trp images into *.gry images. *.gry images
  are just grayscale images. The header contains the width and height
  of the image and the pixels are stored as bytes.
  The genlight program combines those *.gry images with *.epp palettes to
  create a single 'lightsource' and combines several of such 'lightsources'
  to create textures. There are some nice looking textures predefined
  which are used by the demo. The genlight program is not a stand alone
  program. It is a small binary which is used by the demo. - Just my way
  the encapsulate functions in assembly...
./ALL.SRC
  The main program of the demo. It uses all effect module binaries and
  link them together. The rest of the program is nearly the same as 
  the test environment. Some differences are the usage of fast ram (yes!
  big greetings to evil!) and the texture generating stuff.
  
The effects
-----------

Part 1:

./WEAPON.___/
  Intro effect - A cursor writes the letters hmmm... and transforms into
  a cube and a more dangerous (?) object. The effect features environment
  mapping and morphing.
./GLANZ.___/
  Plasma - 'water' effect. The plasma is some kind of smoother routine.
  The resulting values are not used directly as colors but they are
  used to distort a picture. The picture contains a growing number of
  lights.
./EILLOGO.___/
  Environment mapped Error In Line logo
./MORPHROT.___/
  A rotozoomer that uses morphing 3D objects as texture. The rotozoomer
  uses a combination of - pseudo-dithering-motionblur and real motionblur.
  
Part 2:

./MOBLUPLA.___/
  Motionblurred plasma with a real time generated distortion map. This
  effect is used at the beginning of part 2 and the end (hm? hmmm...).
./MBLUR.___/
  Motionblurred 3D objects.
./ATTRACT.___/
  Attraction effect - two stars like each other...
./DRUG.___/
  Extremely motionblurred environment mapped torus gets bigger and bigger
  until you sit in the middle of it. The motionblur routine is a bit tricky.
  It uses a timer based interlace fading routine.
./INCUBE.___/
  The viewer is inside a 3D object. The mixture of motionblur and 
  environment mapping leads to nice lighting effects. 
  
Part 3:

./MORPH.___/
  Morphing 3D objects. The routines of this effect are also used in
  other parts of the demo (mblurrot,weapon). The morphing is not
  linear. It works like a recursive filter which leads to nice
  dynamic movements.
./CENTER.___/
  Jumping shade 'pixels'.
./CORNERS.___/
  Transparent glass-3D object.
./FLIGHT.___/
  Transparent 3D objects in front of a rotozoomer. The two effects are
  not running independently. They have some paramers in common. The
  size of the 3D objects depends on the 'distance' of the rotozoomer. 
  The plasma effect in the second variation of this effect is also
  some kind of rotozoomer.

Part 4:
./WIRECUBE.___/
  Wirecube built out of polygons (???). I just liked the idea of such
  a 3D object.
./LIQUID.___/
  Liquid environment mapped transparent torus. 
./GROW.___/
  Growing tree. The whole 3D object is calculated every frame in realtime.
  The 'morphing' effect is just caused by variations of its parameters.
./ROTOBLUR.___/
  Plasma effect based on rotozoomer routines.
./STAIRS.___/
  Dots jumping on stairs.

What about the DSP? Didn't used you the DSP?
=============================================

Nearly all effects make intensive use of the DSP. A lot of effects are
based on a 3D engine which is implemented completely for the DSP. There
was the problem that the modplayer (by exa) used the DSP too. So I had
to patch the mod player a bit and included a small operating system for
the DSP. It allows me to transfer data and routines between CPU
and DSP and execute DSP routines while the exa-modplayer is playing a 
modfile. I have own routines to load standard *.P56 DSP programs to
the DSP. My operating system can call DSP routines directly. A DSP
program can consist of a number of routines. There exists a list
of the start adresses of the routines at ORG:P$55. The programmer at
the CPU side can tell the OS to call a specified (by index) routine.
This system allows a very flexible usage of the DSP.
Some parts of the 3D engine can be optimized a lot (for example by
using matrices). 

Syncronisation of the effects
=============================

The effects are controlled by the mod file. There exists a special modfile
command 8xx which is used to tell the effect commands. During the whole
demo there are two 'special effects' available - screen shaking and strobo.
These two 'special effects' are provided by the demo engine - do not
search in the effect modules for it .-)
I had to change the exa replayer and the exa mod conversion program a bit
to make the effect syncing possible. The source of the modified replayer
is not included here. I am not sure if exa would like it if I released 
it here. But you can ask me for it... 

Why releasing such crappy source?
=================================

When looking at the source code of the demo you will find a lot of crappy
things there. Some effects are very badly optimized. All routines were
written in a hurry (I began coding five weeks before the eil#2). Comments
are rare. But anyway - I hope some people get inspired by these source
codes. You can do with it what you want - but you are not allowed to sell
it. If you have any questions or comments - please contact me!

Contact
=======

Norman Feske
Dammweg 2
01097 Dresden
++49 351 471 68 75
nf2@inf.tu-dresden.de
http://escape.atari.org

Greetings
=========

Evil/DHS - Thanks for the inspiring screenshots of your demo! :-)
Modmate/Checkpoint - Wandertag einlegen?
Earx/FUN - I look forward to see you...
Sqward/MSB - What is coming next?
.tSCc. - DSPDit ruuuules!
