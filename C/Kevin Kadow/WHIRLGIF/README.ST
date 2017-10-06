Hello gif animators!

                * latest changes at the bottom of the document *

This program was compiled by Tommy Andersen (tommya@post3.tele.dk) on a 
TT030. It should work on any Atari ST/TT Falcon computer.

Please read the whirlgif.doc.

Whirlgif is a TTP program, and you must type all parameters on the 
command line. So how do I get started?

First, you must create some gif images. After this sort of art exercise, 
create a list file, plain ascii, with all images listed. Doubleclick on 
whirlgif.ttp, and enter:

 -o myfirst.gif -loop -trans #000000 -time 1 -i mylist.txt

After a while, whirlgif quits, and you should now have created an 
animated gif. Check it with Cab. For a more in depth explanation of the 
parameters, read the whirlgif.doc!

If you are using a cli (as I do) cd into your gif folder, and enter the 
command line. Warning! Some cli will change #000000 into something 
different. Use '#000000' (quoted).

What the doc did not tell:

 -trans index,  index is a color index. You can use transgif to list the 
                color table and the RGB values for each entry. Transgif 
                is included with Cab.
 -trans #value, value is a hex number, example FFFFFF (white) FF0000 
                (red). It should be read as RRGGBB. If you want to make 
                black transparent, use -trans '#000000'.



IMPORTANT
---------

This program was written by Kevin Kadow (kadokev@msg.net), I (Tommy 
Andersen) just picked it up and compiled it.

If you have any comments about the Atari version, you should contact me.

Here's some small adjustments in this version made by me, tommya.

7. September 1997.
-------------------

Changed: Gif Comment bug corrected.

Changed: If a frame has the exactly same colormap and size as the 
colormap from the very first frame, a local colormap will not be saved. 
The result is a smaller gif.
Netscape has troubles with local colormaps, the transparent color will 
not be transparent from frame 2. You can avoid this by using the same 
colormap in all your gif images.

Changed: One reserved bit was set, now cleared.

This version was compiled with GCC 2.7.2.2 and Mintlibs pl 47.

Tips: Don't use interlaced frames. Use plain GIF87a images.

--------------------

Happy animation.

CU Tommy 

 +------------------------------------------------------------------+
 \   Tommy Andersen              email: tommya@post3.tele.dk        /
 /   Rydevaenget 1, 2tv        Netmail: 45:100/2.5@viking.ftn       \
 \   DK 8210 Aarhus V                   90:1500/102.5@nest.ftn      /
 /   Denmark                            51:1301/102.5@atarinet.ftn  \
 \  http://home3.inet.tele.dk/tommya/   2:236/84.5@fidonet.org      /
 +------------------------------------------------------------------+

*  "The Graphics Interchange Format(c) is the Copyright property of
*  CompuServe Incorporated. GIF(sm) is a Service Mark property of
*  CompuServe Incorporated."
