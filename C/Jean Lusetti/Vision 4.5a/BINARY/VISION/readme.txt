*********************************
* readme.txt for VISION sources *
*********************************
In early 2005, I decided to make the source code of VISION freely available on my website http://vision.atari.org
VISION is an image editor/manager/album and more lotta stuff for all ATARI platforms.
This is the release 4.1a, with a lot of improvements compared to 4.0f, see http://vision.atari.org/vhistoe.htm for details.

**********************
* So, what's in it ? *
**********************
This archive contains the following objects:

xaes.h       Modified (compatible) version of AES.H for Falcon "new" features. Copy it to your INCLUDE folder
PCFLTLIB.LIB Modified floating point library for MAC emulator compatibility. Copy it to your LIB folder

TOOLS\      This is the main folder for my personal library
+-JPEG\     JPEG encoder/decoder source files

VISION\     Well, all the VISION specific stuff
+-DSP\      Contains the Brainstorm JPEG decoder for Falcon and nfjpeg.prg (native JPEG decoding for Aranym)
            And the 56001 binary I did for image filtering
+-FILTRES\  Convolution filters files
+-FORMS\    Source files for all VISION's dialog boxes
+-LANGUES\  Resource files for all languages currently supported by VISION:
            (one folder per language)
            DEUTSCH, ENGLISH, FRANCAIS, ITALIAN, SVENSKA
+-LDV\      Source files for VISION's modules based on LDGs

VISION is developped using PURE_C.


*************
* Copyright *
*************
See license.txt: MIT basically says: do whatever you want with sources.

Well, here we are, I really enjoyed developing VISION on ATARI, I hope someone will continue...

If you need more details on source code (I have to admit that it is not so well commented...),
you can contact me at: vision.support@free.fr

Have fun !