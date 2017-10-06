-----------------------------------------------------------------------------

                   AMS - Atari Machine Specific C++ Library

                                Version 0.8
                              October 12, 1993

                   by Warwick Allison (warwick@cs.uq.oz.au)

-----------------------------------------------------------------------------

WARNING:  Falcon resolutions are not correctly supported.  If you have a
          Falcon and knowledge of the Vsetmode, etc. XBIOS calls, please
          get this working and forward fixes to the author.  The code
          dealing with this is all in "src/resoluti.cc" - there is code
          there already, but it doesn't work due to my limited knowledge
          of the Falcon OS (and no testing ability!)


This library is intended for use in programs that CANNOT be written using
simply AES/VDI.  Remember that anything you write with AMS will only work
on hardware which AMS supports.  Of course, that is better than writing
machine-dependent code directly (since someone else may implement AMS
routines for alternative hardware).

If you want to write GEM (AES/VDI) applications, I suggest you use GEM++,
my C++ GEM class library.

-----------------------------------------------------------------------------
