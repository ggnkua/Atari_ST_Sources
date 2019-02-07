*			 Reboot   					*
*			 Dave Small 					*
*                                                                       * 
*		   START, the ST Quarterly				*
*		   Issue 4, Spring 1987 				*
*                 Copyright (c) 1987 by ANTIC Publishing                *
*									*
*									*
*
* Zaps memvalid.l (at $420) to 0.
* This makes the ST think that its memory has never been sized &
* initialized, and forces a chain of actions that clears the first
* 64K of RAM (at least). This causes a true coldstart.
*
* Also zap $444.w to 0. This turns off write verify.
*
* This *MUST* have a .PRG extension to work in AUTO folder!
*
* Dave Small / June 1986.  
*
*  Dedicated to: Steve Dallas.
*
**********************
* Batch file to get this ready to use: 
*
* as68 -l %1.s				(assembles source -> .o file)
* lo68 -r -o %1.68k %1.o		(links .o file -> .68k file)
* relmod %1.68k %1.tos			(twiddles .68k file to .tos file)
* rename %1.tos %1.prg			(make into .PRG so AUTO uses it)
*
* Then, copy it into your AUTO folder.
*
* Application startup..
* (Code from SID dump of an empty TOS application in C (main {}).)
*
	move.l	a7,a5		* code from linked output..pretty short.
	move.l	#$70000,a7 	* set stack in cool place
	move.l	4(a5),a5	* setup params for "release memory" call
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move	d0,-(a7)
	move	#$4a,-(a7)	* release memory call
	trap	#1		* do it
	adda.l	#12,a7		* repair stack
**********
* $420 patch. Must call from supervisor mode,  since it affects 
* memory below $800, which is supervisor-only.
*
* Kick into supervior mode..
	move.l	#0,-(sp)	* set supervisor mode parameter: use USP
	move.w	#$20,-(sp)	* $20: set supervisor mode call
	trap	#1		* ring up GEMDOS
* Note: d0 now contains old SSP, which we must restore shortly (before exit..)
* Now twiddle $420..
	move.w	#0,$420		* clobber memvalid at 420.
	move.w	#0,$444		* clobber floppy write verify flag
* Now restore SSP and go back to user mode (required).
	move.l	d0,-(sp)	* old SSP
	move.w	#$20,-(sp)	* swap super mode call. (Note: trashes USP).
	trap	#1		* ring up GEMDOS
* Exit to GEM desktop:
	 move.w	#0,-(sp)	* "terminate application back to GEM desktop"
	trap	#1		* call; doesn't return back to us.
***********
	end
