v2600, Atari port
=====================================


What the heck?

  v2600 is a VCS emulator originally created by Alex Hornby.
  This is a very basic port, and I don't intend to maintain it.

  The emulator itself has some shortcomings which I haven't adressed,
  some of which results in bad behavior (see Known Issues).

  This is a command line application. You'll have to enter parameters and stuff.
  If you don't like this, don't use the application.

  Type 'v2600.ttp --help' to list the available parameters.

System Requirements:
  
  The 2600 is pretty hard to emulate, which means it needs a fast machine.


Known issues

  - Don't start the emulator without a ROM file (it will crash your computer)
  - Some games work, some don't
  - Sound is not very accurate
  - No joypad support
  - When the emulated machine crashes, it usually crashes the real machine too


Sourcecode

  I've included the source code of this port. You'll need the original v0.82 sources
  to be able to compile it. I used GCC, other compilers will probably require some work.

  1. Copy the atari source directory to the 0.82 sources as follows:

	  /v2600-source-dir

		... v2600 source files

		/atari
	
			... atari port source files

  2. Copy 'config.h' from the atari source dir to the v2600 source dir (..)

  3. Run make from the atari source dir


Links

  http://www.hornby.dsl.pipex.com/v2600/
  http://www.atariage.com/
  

Thanks

  Patrice Mandin, for your nice Ikbd routines.
  Mikael Kalms, for your nice c2p routines.

Legal

  Don't use this software. If you do use it, don't blame me when bad stuff happen.


-- Peter Persson (pedda_pirat@hotmail.com)