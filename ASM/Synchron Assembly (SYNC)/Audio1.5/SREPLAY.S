\
* Simple to use replay routine in assembly language
* To be assembled with DevPac2 from HiSoft or any similar...
* 
* Copyright 1991 Synchron Assembly 
*
* This routine and the included binary file could be used by anyone
* in any kind of program for personal or commercial use as long as
* AudioSculpture is mentioned as the source of the replay routines
* in the program.
*
* A list of the entire variable table could be found in the file replay.txt


	pea	turn_of_mouse
	move.w	#38,-(a7)	
	trap	#14	Turn of mouse
	addq.l	#6,a7

	lea VariableOffset,a6
	move.l #Module,20(a6)	Pointer to start of module
	move.l #ModuleEnd,24(a6)	Pointer to end of module
	move #0,36(a6)		Output Mode
	move.b #1,38(a6)	Volume On/Off
	move.b #2,39(a6)	STE replay frequency
	move.b #49,40(a6)	Internal replay frequency
	jsr (a6)		Relocation call
	lea VariableOffset,a6
	jsr 12(a6)		Install
	
	move #7,-(a7)
	trap #1
	addq #2,a7
	
	lea VariableOffset,a6	DeInstall
	jsr 16(a6)

	pea	turn_on_mouse
	move.w	#38,-(a7)	
	trap	#14	Turn on mouse
	addq.l	#6,a7
	
	clr -(a7)
	trap #1

turn_of_mouse:	
	move.b	#$12,$fffffc02.w
	rts

turn_on_mouse:	
	move.b	#$8,$fffffc02.w
	rts


__NB_SAMPLES	equ 31

Module	incbin d:\mod\war.mod	The Module Itself
ModuleEnd	ds 512*__NB_SAMPLES	Free space for buffers in between samples
ReplayCode	incbin a:\replay\cyber.b	The ReplayCode
VariableOffset	equ ReplayCode+28	Pointer to variable basepage
