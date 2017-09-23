*********************************
* readme.txt for VISION sources *
*********************************
In early 2005, I decided to make the source code of VISION freely available on my website http://vision.atari.org
VISION is an image editor/manager/album and more lotta stuff for all ATARI platforms.
This is the release 4.0f, quite like the previous official release 4.0e.
Here are the differences:
* A new object the Hexa Viewer has been added, use it with a right-click on an image and select "Hexa-Dump"
  WARNING : this is a beta release and it may be not stable. Source code is located in VISION\HEXDUMP.C

* Source code relative to icon handling has been improved by Olivier Landemarre for better compliance regarding Aranym.


**********************
* So, what's in it ? *
**********************
This archive contains the following objects:
PUREC
+-INCLUDE\  Contains a modified (compatible) version of AES.H for Falcon "new" features
+-LIB\      Contains a modified floating point library for MAC emulator compatibility

TOOLS\      This is the main folder for my personal library
+-MEMDEBUG\ A public library to debug dynamic memory allocations

VISION\     Well, all the VISION specific stuff
+-DSP\      Contains the Brainstorm JPEG decoder for Falcon
            And the 56001 binary I did for image filtering
+-FILTRES\  Convolution filters files
+-FORMS\    Source files for all VISION's dialog boxes
+-LANGUES\  Resource files for all languages currently supported by VISION:
            (one folder per language)
            DEUTSCH, ENGLISH, FRANCAIS, ITALIAN, SVENSKA
+-LDV\      Source files for VISION's modules based on LDGs

+-GENKEY\   Little tool used to create a key for registration

VISION is developped using PURE_C.


*************
* Copyright *
*************
This source code is totally freely available, use it as you like.
It would be such a nice idea to inform me what you did with it, for VISION or any other thing.


Well, here we are, I really enjoyed developing VISION on ATARI, I hope someone will continue...

If you need more details on source code (I have to admit that it is not so well commented...),
you can contact me at: vision.support@free.fr

Have fun !
