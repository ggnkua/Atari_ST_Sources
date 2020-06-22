************************************************ 
* DSP560001 ModPlay Library for HiSoft Basic.  * 
* Written for the Atari Falcon030 only.        * 
* Version1 19/5/94                             * 
************************************************ 
 
HiSoft Basic Interface by Data Uncertain. 
contact: craig.graham@newcastle.ac.uk 
address: 46 School Road, 
         Langold 
         Worksop 
         Notts, 
         S81 9PY 
         England. 
 
DSP MOD replay routine written by bITmASTER of BSW 
Additional code by Dusan. 
 
This library is placed in the PUBLIC DOMAIN, for the benifit of all who 
would use it. 
 
========================================================================== 
 
Summary 
------- 
This library provides a new library for HiSoft basic which provides 
support for using the DSP560001 to play mod files under interupt. 
 
You can load as many mods at once as you like, but only one mod may be played 
at a time. 
 
Installation 
------------ 
 
To use the MODPLAY library, you must first rebuild the Basic Library to include 
the MODPLAY library. 
1) Copy the contents of the libs directory (on disc 2 of the HBasic2 release 
   discs) onto your hard drive (or RAM drive, or another floppy). 
 
3) Copy the BUILDLIB.TTP file from the tools directory (on disc 2 of the HBasic2 release 
   discs) into the libs directory that you have created. 
 
4) Copy the file bas_mod.bin into the libs directory as well. 
 
5) Type (at a command line) 
      buildlib gemdos gemaes gemvdi bios xbios bas_mod 
 
6) This will build a new HiSoft Basic library file HBASIC.LIB. Copy this into 
   your HiSoft Basic Directory - this will replace your current library file. 
 
Usage 
------ 
 
The name of the library is MODPLAY, and it is used in the same way as the 
GEMAES, GEMVDI, XBIOS, etc libraries. 
 
ie. To use the modplay library in your program, add this line at the start of 
you code: 
 
   LIBRARY "MODPLAY" 
 
Four commands are provided to support the playing of MODS this: 
 
  InitMod dummy%() 
     InitMod initialises the modplay engine. 
     This routine should be called with a dummy integer 
     array parameter (any old integer array, it's not actually used). 
 
  PlayMod modfile%() 
     PlayMod actually starts a mod playing as a background task. 
     Usage: 
        dim a%(70000) 
        bload "mymusic.mod",varptr(a%(0)) 
        PlayMod a%() 
 
  StopMod modfile%() 
     StopMod will stop the currently playing mod - you should always 
     call this to stop a mod from playing before exiting a program 
     or before starting another modfile playing. 
 
  GetModName modfile%(),name$ 
     GetModName will return the title of the modfile (NOT the filename, 
     the actual mod title) in the string variable name$ 
 
The accompanying demo program MODTEST.BAS illustrates the use of the modplayer 
routines. It produces a simple .ttp program which will play any mod which is 
passed to it as a parameter. 
Sourcecode is provided for the HiSoft Basic interface routines, but the DSP 
modplay code itself is a binary (sorry).
 
===========================================================================
