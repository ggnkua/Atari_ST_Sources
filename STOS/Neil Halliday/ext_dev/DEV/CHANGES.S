CHANGES.S


	This file details changes made to the DEVELOPMENT Extension from
28th November 1995.  The DEVELOPMENT extension is (C) STORM Developments,
and may not be used without prior permission from the author: Neil 
Halliday.



Date		Description
--------------------------------------------------------------------------

28/11/1995	Added the first blitter graphics routine to the extension.
		Had a bit of trouble with the command name, so ended up
		having to call it BFCOPY. It is a full screen, four plane
		screen copying routine. Needs adding into the compiler
		program. Added to extension DEV1_INT.S
		
		
28/11/1995	Added the BFCOPY command to the compiler extension. All
		working fine, although running just under a VBL to copy
		the screen.
		
		
28/11/1995	Added the BFSKOPY command to DEV1_INT.S   This command
                is a single plane full screen copying command, using
                the STE Blitter Chip.
		

28/11/1995	Added the BFSKOPY command to the compiler.  Running ok,
                at around 20% processor time for a full screen.
		
		
28/11/1995	Added the BSCANCOPY command to DEV1_INT.S  This command
		is a four plan scanline copier. Pass source screen, start
		scanline, length, destscreen and destscanline.
		
		BSCANCOPY physic,0,32,physic,100
		
		Needs adding to the compiler extension.
	
		
29/11/1995	Added the BSCANCOPY command to the compiler code. All
		running ok, and quite fast.
		
		
29/11/1995	Added the BSCANSKOPY command to DEV1_INT.S  This is a
		single plane version of the BSCANCOPY command. This is
		a bloody fast routine, averaging about 0.5 of a scanline
		to copy a 320x32 block!
		
		******* NOTE: No more commands left in DEVELOP1 *******
		
		
29/11/1995	Finished off the DEVELOP1 Compiler extension by adding the
		BSCANSKOPY command.
		
		
***************************************************************************
* Neil Halliday 29/11/95..    PART ONE OF THE EXTENSION IS COMPLETE!!!!!! *
***************************************************************************
