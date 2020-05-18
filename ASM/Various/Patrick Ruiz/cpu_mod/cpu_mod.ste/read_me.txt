~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~   CPU_MOD	 for ATARI STE	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	CPU_MOD is a *.MOD player for STE ,
	yes , but NOT ANOTHER *.MOD player ...	TRY IT !!!!

	I coded it because I haven't found NONE good player on ATARI
	     (i.e:
	      PROTRACKER
	      AUDIOSCULPTURE
	      ESION
	      PAULA
	      DESK-TRACKER
	      ULTIMATE TRACKER
	      50KHZPLAY
	      CRAZY MUSIC MACHINE
	      ... OUF )

	It sounds differently (NORMALLY IN FACT !!!) because it's my own code
	entirely rethinked , and not a code ripped on Amiga and badly converted.

	Of course it have all the sound effects (CIA timing , E-commands ...) ,
	the routine core length is lesser than 7000 bytes and
	need 70000 bytes free only.(You can use it in yours programs)


	This directory contains:

	READ_ME.TXT	:This file.
	CPU_MOD.BIN	:The routine usable in yours programs.
	CPU_MODX.TTP	:A TTP-shell , parameter : modulename
			 you can install it with the menu option of the Desktop.

	CPU_MODX.S	:The source in ASM of CPU_MODX.TTP
			 See it for using CPU_MOD.BIN
			 (Even if you are not a assembly programmer you
			  can use the routine also in BASIC , C , ... )




			 <<<<<<<<<>>>>>>>>>
			 <<< Some Hints >>>
			 <<<<<<<<<>>>>>>>>>


    _The Fast Forward mode respect the construction of the module and read
     all the commands ,
     the Song position Reverse Search and Song position Forward Search : NO
     (It permit to "pass" the levels for Game-module)


    _If the program return to the desktop then
	_The module is packed ... (Depacked it !)
	_The module is altered (ripped souce ?)
	 Load it with PROTRACKER , i.e. , save it with a DIFFERENT name and
	 exit PROTRACKER .
	 Take a look at the new length , you will see the amount of missing
	 bytes.
	 If this amount of bytes is too important (>8 bytes) the last sample(s)
	 is (are) altered , Sorry , try to repair it (them) .


    _The 50066 Hz mode works only on 16 MHz computer
     (It uses only the voices 1 and 2 on a 8 MHz computer , sorry ...)




	If you enjoy this player tell me it:



	Patrick RUIZ

	Quartier Le Clos

	ROQUEVAIRE 13360

	FRANCE
