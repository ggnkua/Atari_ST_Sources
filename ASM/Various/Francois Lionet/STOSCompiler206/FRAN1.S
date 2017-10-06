	
	
	INCLUDE "EQUATES.S"


******************************************
** STOS Maestro Compiler Extension File **
******************************************

*		Hi Jon
*
*	First, bravo for your source code! I am very impatient to see
*	Stos Maestro at work: it seem to be very powerfull!
*
*	Here is I hope the solution to your problems.
*	What I think is the simplest way to do, is to put the look-up
*	table in the param area, and ALSO in the same area the interrupt
*	routine: the interrupt routine will be allowed to have the addres
*	of the table by using (pc). What you did in the source code
*	you sent me was wrong: using LEA voldat2(pc),A3 in a library
*	routine is absolutely false! The distance between INIT and a
*	library routine is VERY different than in the source code!
*
*	What you have to keep in mind, is that you can refer to relative
*	addresses only INSIDE of certain block of code:
*		- PARAMS & INIT
*		- each library routine
*	The distance between each block IS NOT KNOWN! For example
*	here is the structure of a program:
*		10 PRINT "hello"
*		20 SAMINIT
*
*	-----------------------------------------------
*		INIT OF COMPILED PROGRAM
*	-----------------------------------------------
*		INIT OF STOS MAESTRO
*	-----------------------------------------------
*		COMPILED PROGRAM
*		jsr print (load variables first....)
*		jsr maestro
*		jsr end
*		error handling
*	-----------------------------------------------
*		END LIBRARY ROUTINES
*	-----------------------------------------------
*		PRINT LIBRARY ROUTINE
*	-----------------------------------------------
*		SAMINIT LIBRARY ROUTINE
*	-----------------------------------------------
*		"hello" string
*		relocation table
*		and all internal compiled program garbage
*	-----------------------------------------------
*	If you used samplay BEFORE saminit, it would be copied
*	before it in the program.
*
*	So I changed a little your program. Examine it,
*	It would work better now. Be carefull, you must have the
*	last version of the compiler to try it. There may be bug
*	in the extension handling in former versions. (I'm not
*	sure what version you have, so take the VERY LAST!
*
*	Before going into code, here the answer to your questions:
*	1) NONONONONO! you cannot use LEA voldat(pc),a3! See before!
*	2) & 3) cannot work because you do not refer to the table
*	properly!
*	4) Sorry, for compiled programs, you'll have only to give
*	intern basic's error messages (see manual for numbers)
*
*	PS: I also included the EQUATES.S file. Erase the one you have
*	I don't think so, but I might have changed something in it.
*	We never can be sure enough!
*
*	I don't know what assembler you are using, but for me
*	it DEVPAC II, which is fabulous, and allows PEA! The debugger
*	is extremely powerfull: you can hide it somewhere in memory
*	run your program in which you've hidden a ILLEGAL instruction
*	then you get the hand and step through the program! I did not
*	believe it the first time I made it work!
*
*		In case of problem, call me at night, it is NOT
*	EXPENSIVE!
*
*	I'll be at mandarin from TUESDAY 28th to THURSDAY march.
*	It would be good if we could see us there to make sure 
*	the compiler extention works perfectely. I am aware of how
*	hard it is to work on someone else's job. But sorry, I made my
*	best to make it simpler for you. Doing a compiler that accepts
*	new instructions is not an easy task!
*
*		Bye for now! 
*		
*			Francois
*
*	PS: I also found out that using a DATA label was everything
*	but intellingent: DATA is a reserved word for many
*	assemblers! So in this source, I changed all data to dataS so
*	that it doesnot interfier with the assembleur.
*	I check with my assembler all the relocations: it works perfecly!
*	I changed all adresses to $FFFFF to check that!
***************************************************************************


psg		equ $ff8800		; Sound chip reg

* I had to use reserve address's here, because I need absolute addressing
* They are for the start and end address of sampling.
* Is this O.k ?
*	MAY BE! but VERY dangerous!
*	See what I did after!
*startaddr	equ $30			; Pointer to Address to play		
*startaddr2	equ $34			; Back of above
*length		equ $40			; Length to play
*length2		equ $44			; Length to play

************************************************************************

Debu:           dc.l Para-Debu
                dc.l datas-Debu
                dc.l Libr-Debu

************************************************************************
*		NOTHING TO SAY HERE

Cata:   dc.w L2-L1,l3-l2,l4-l3		; 3 Commands so far

Para:   dc.w 3,3
        dc.w p1-Para,p2-para,p3-para
p1:     dc.b 0 			* Not used for instructions
        dc.b 1			* Sound Init
        dc.b 1,0			* Ends definition
p2:     dc.b 0 			* Function 1
        dc.b 1			* =SAMPLE
        dc.b 1,0			* Ends definition
p3:     dc.b 0 			* Not used for instructions
        dc.b 0,1			* SAMPLE (n)
        dc.b 1,0			* Ends definition

************************************************************************

	even

datas:		bra Init

* Equates used from .EXD file

params:		equ 4    
snd_init		equ params 	; Sound chip init string
sparam		equ snd_init+28	; Param save
templ		equ sparam+4	; 
destc		equ templ+4	; Forgot ( not important )
endc		equ destc+4	; 
auto_on		equ endc+4	; Auto sample speed 
oknotm		equ auto_on+2	; Music command flag
type		equ oknotm+2	; Type of play, FWRD,BKWD etc..
speed		equ type+2	; Speed of play
sampbank:		equ speed+2	; Bank to get sounds from
SAVEREG1:		EQU SAMPBANK+2	; Register save
SAVEREG2:		EQU SAVEREG1+4	; Register save
hertz		equ SAVEREG2+4	; Hertz convertion table

		dc.b 0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,-1,8,0,9,0,10,0,11,0,12,0,-1,0
		dc.l 0,0,0,0
		dc.w 0,0,1
		dc.b 45,0
		dc.w 5
		dc.l 0,0
		dc.b 0,0,0,0,0,91,75,63,54,47,41,36,32,28,25,22,20,18,16
		dc.b 14,13,11,10,9,8,7,6,5,4,3,2,1,0,0

******************* Here I put the addresses!
startaddr		dc.l 0		; Pointer to Address to play		
startaddr2	dc.l 0		; Back of above
length		dc.l 0		; Length to play
length2		dc.l 0		; Length to play

VOLDAT2:
        dc.l $08000000,$09000000,$0a000000,0
        dc.l $08000000,$09000000,$0a000000,0
        dc.l $08000000,$09000000,$0a000100,0
        dc.l $08000000,$09000100,$0a000100,0
        dc.l $08000000,$09000000,$0a000200,0
        dc.l $08000100,$09000100,$0a000100,0
        dc.l $08000000,$09000100,$0a000200,0
        dc.l $08000000,$09000200,$0a000200,0
        dc.l $08000000,$09000000,$0a000300,0
        dc.l $08000000,$09000100,$0a000300,0
        dc.l $08000200,$09000000,$0a000300,0
        dc.l $08000100,$09000200,$0a000200,0
        dc.l $08000200,$09000200,$0a000200,0
        dc.l $08000300,$09000200,$0a000000,0
        dc.l $08000400,$09000100,$0a000000,0
        dc.l $08000400,$09000200,$0a000000,0
        dc.l $08000500,$09000000,$0a000000,0
        dc.l $08000500,$09000000,$0a000000,0
        dc.l $08000500,$09000100,$0a000000,0
        dc.l $08000500,$09000100,$0a000100,0
        dc.l $08000500,$09000200,$0a000000,0
        dc.l $08000500,$09000200,$0a000100,0
        dc.l $08000600,$09000000,$0a000000,0
        dc.l $08000600,$09000000,$0a000100,0
        dc.l $08000600,$09000100,$0a000000,0
        dc.l $08000600,$09000100,$0a000100,0
        dc.l $08000600,$09000100,$0a000100,0
        dc.l $08000600,$09000100,$0a000200,0
        dc.l $08000600,$09000200,$0a000100,0
        dc.l $08000600,$09000200,$0a000200,0
        dc.l $08000700,$09000000,$0a000000,0
        dc.l $08000700,$09000000,$0a000100,0
        dc.l $08000700,$09000100,$0a000000,0
        dc.l $08000700,$09000100,$0a000000,0
        dc.l $08000700,$09000100,$0a000100,0
        dc.l $08000700,$09000200,$0a000000,0
        dc.l $08000700,$09000200,$0a000000,0
        dc.l $08000700,$09000200,$0a000100,0
        dc.l $08000700,$09000300,$0a000000,0
        dc.l $08000700,$09000300,$0a000000,0
        dc.l $08000700,$09000300,$0a000100,0
        dc.l $08000700,$09000300,$0a000100,0
        dc.l $08000700,$09000300,$0a000200,0
        dc.l $08000700,$09000300,$0a000200,0
        dc.l $08000800,$09000000,$0a000000,0
        dc.l $08000800,$09000000,$0a000000,0
        dc.l $08000800,$09000100,$0a000000,0
        dc.l $08000800,$09000100,$0a000100,0
        dc.l $08000800,$09000200,$0a000000,0
        dc.l $08000800,$09000200,$0a000100,0
        dc.l $08000800,$09000300,$0a000000,0
        dc.l $08000800,$09000300,$0a000000,0
        dc.l $08000800,$09000300,$0a000100,0
        dc.l $08000800,$09000300,$0a000200,0
        dc.l $08000800,$09000400,$0a000000,0
        dc.l $08000800,$09000400,$0a000000,0
        dc.l $08000800,$09000400,$0a000100,0
        dc.l $08000800,$09000400,$0a000200,0
        dc.l $08000800,$09000400,$0a000200,0
        dc.l $08000900,$09000000,$0a000000,0
        dc.l $08000900,$09000000,$0a000000,0
        dc.l $08000900,$09000100,$0a000000,0
        dc.l $08000900,$09000100,$0a000100,0
        dc.l $08000900,$09000200,$0a000000,0
        dc.l $08000900,$09000200,$0a000100,0
        dc.l $08000900,$09000300,$0a000000,0
        dc.l $08000900,$09000300,$0a000000,0
        dc.l $08000900,$09000300,$0a000100,0
        dc.l $08000900,$09000300,$0a000100,0
        dc.l $08000900,$09000300,$0a000200,0
        dc.l $08000900,$09000400,$0a000000,0
        dc.l $08000900,$09000400,$0a000000,0
        dc.l $08000900,$09000400,$0a000100,0
        dc.l $08000900,$09000400,$0a000100,0
        dc.l $08000900,$09000400,$0a000200,0
        dc.l $08000900,$09000400,$0a000200,0
        dc.l $08000900,$09000500,$0a000000,0
        dc.l $08000900,$09000500,$0a000000,0
        dc.l $08000900,$09000500,$0a000100,0
        dc.l $08000900,$09000500,$0a000100,0
        dc.l $08000900,$09000500,$0a000200,0
        dc.l $08000900,$09000500,$0a000200,0
        dc.l $08000900,$09000500,$0a000300,0
        dc.l $08000900,$09000500,$0a000300,0
        dc.l $08000900,$09000600,$0a000000,0
        dc.l $08000900,$09000600,$0a000000,0
        dc.l $08000900,$09000600,$0a000100,0
        dc.l $08000900,$09000600,$0a000100,0
        dc.l $08000900,$09000600,$0a000200,0
        dc.l $08000a00,$09000000,$0a000000,0
        dc.l $08000a00,$09000100,$0a000000,0
        dc.l $08000a00,$09000100,$0a000100,0
        dc.l $08000a00,$09000200,$0a000000,0
        dc.l $08000a00,$09000200,$0a000000,0
        dc.l $08000a00,$09000200,$0a000100,0
        dc.l $08000a00,$09000200,$0a000100,0
        dc.l $08000a00,$09000200,$0a000200,0
        dc.l $08000a00,$09000300,$0a000100,0
        dc.l $08000a00,$09000300,$0a000100,0
        dc.l $08000a00,$09000300,$0a000200,0
        dc.l $08000a00,$09000400,$0a000100,0
        dc.l $08000a00,$09000400,$0a000100,0
        dc.l $08000a00,$09000400,$0a000200,0
        dc.l $08000a00,$09000400,$0a000200,0
        dc.l $08000a00,$09000500,$0a000000,0
        dc.l $08000a00,$09000500,$0a000100,0
        dc.l $08000a00,$09000500,$0a000100,0
        dc.l $08000a00,$09000500,$0a000200,0
        dc.l $08000a00,$09000500,$0a000200,0
        dc.l $08000a00,$09000500,$0a000300,0
        dc.l $08000a00,$09000600,$0a000000,0
        dc.l $08000a00,$09000600,$0a000000,0
        dc.l $08000a00,$09000600,$0a000100,0
        dc.l $08000a00,$09000600,$0a000100,0
        dc.l $08000a00,$09000600,$0a000200,0
        dc.l $08000a00,$09000700,$0a000200,0
        dc.l $08000a00,$09000600,$0a000300,0
        dc.l $08000a00,$09000600,$0a000300,0
        dc.l $08000b00,$09000000,$0a000000,0
        dc.l $08000b00,$09000000,$0a000000,0
        dc.l $08000b00,$09000100,$0a000000,0
        dc.l $08000b00,$09000000,$0a000100,0
        dc.l $08000b00,$09000100,$0a000100,0
        dc.l $08000b00,$09000100,$0a000100,0
        dc.l $08000b00,$09000200,$0a000000,0
        dc.l $08000b00,$09000200,$0a000000,0
        dc.l $08000b00,$09000200,$0a000100,0
        dc.l $08000b00,$09000300,$0a000000,0

        dc.l $08000b00,$09000300,$0a000100,0
        dc.l $08000b00,$09000300,$0a000100,0
        dc.l $08000b00,$09000300,$0a000200,0
        dc.l $08000b00,$09000300,$0a000200,0
        dc.l $08000b00,$09000400,$0a000100,0
        dc.l $08000b00,$09000400,$0a000200,0
        dc.l $08000b00,$09000500,$0a000000,0
        dc.l $08000b00,$09000500,$0a000000,0
        dc.l $08000b00,$09000500,$0a000100,0
        dc.l $08000b00,$09000500,$0a000100,0
        dc.l $08000b00,$09000500,$0a000200,0
        dc.l $08000b00,$09000500,$0a000200,0
        dc.l $08000b00,$09000600,$0a000000,0
        dc.l $08000b00,$09000600,$0a000100,0
        dc.l $08000b00,$09000600,$0a000100,0
        dc.l $08000b00,$09000600,$0a000200,0
        dc.l $08000b00,$09000600,$0a000200,0
        dc.l $08000b00,$09000600,$0a000300,0
        dc.l $08000b00,$09000600,$0a000300,0
        dc.l $08000b00,$09000600,$0a000400,0
        dc.l $08000b00,$09000700,$0a000000,0
        dc.l $08000b00,$09000700,$0a000000,0
        dc.l $08000b00,$09000700,$0a000000,0
        dc.l $08000b00,$09000700,$0a000100,0
        dc.l $08000b00,$09000700,$0a000100,0
        dc.l $08000b00,$09000700,$0a000100,0
        dc.l $08000b00,$09000700,$0a000200,0
        dc.l $08000b00,$09000700,$0a000200,0
        dc.l $08000b00,$09000700,$0a000300,0
        dc.l $08000b00,$09000700,$0a000300,0
        dc.l $08000b00,$09000700,$0a000300,0
        dc.l $08000b00,$09000700,$0a000400,0
        dc.l $08000b00,$09000700,$0a000400,0
        dc.l $08000b00,$09000700,$0a000400,0
        dc.l $08000b00,$09000800,$0a000000,0
        dc.l $08000b00,$09000800,$0a000000,0
        dc.l $08000b00,$09000800,$0a000100,0
        dc.l $08000b00,$09000800,$0a000100,0
        dc.l $08000b00,$09000800,$0a000200,0
        dc.l $08000b00,$09000800,$0a000200,0
        dc.l $08000b00,$09000800,$0a000200,0
        dc.l $08000b00,$09000800,$0a000300,0
        dc.l $08000b00,$09000800,$0a000300,0
        dc.l $08000b00,$09000800,$0a000300,0
        dc.l $08000b00,$09000800,$0a000400,0
        dc.l $08000b00,$09000800,$0a000400,0
        dc.l $08000b00,$09000800,$0a000400,0
        dc.l $08000b00,$09000800,$0a000400,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000b00,$09000800,$0a000500,0
        dc.l $08000c00,$09000100,$0a000000,0
        dc.l $08000c00,$09000100,$0a000100,0
        dc.l $08000c00,$09000200,$0a000000,0
        dc.l $08000c00,$09000200,$0a000000,0
        dc.l $08000c00,$09000200,$0a000100,0
        dc.l $08000c00,$09000200,$0a000100,0
        dc.l $08000c00,$09000200,$0a000200,0
        dc.l $08000c00,$09000200,$0a000200,0
        dc.l $08000c00,$09000300,$0a000100,0
        dc.l $08000c00,$09000300,$0a000200,0
        dc.l $08000c00,$09000400,$0a000100,0
        dc.l $08000c00,$09000400,$0a000100,0
        dc.l $08000c00,$09000400,$0a000100,0
        dc.l $08000c00,$09000400,$0a000200,0
        dc.l $08000c00,$09000500,$0a000000,0
        dc.l $08000c00,$09000500,$0a000100,0
        dc.l $08000c00,$09000500,$0a000200,0
        dc.l $08000c00,$09000500,$0a000200,0
        dc.l $08000c00,$09000500,$0a000300,0
        dc.l $08000c00,$09000500,$0a000300,0
        dc.l $08000c00,$09000500,$0a000400,0
        dc.l $08000c00,$09000500,$0a000400,0
        dc.l $08000c00,$09000600,$0a000000,0
        dc.l $08000c00,$09000600,$0a000100,0
        dc.l $08000c00,$09000600,$0a000100,0
        dc.l $08000c00,$09000600,$0a000200,0
        dc.l $08000c00,$09000600,$0a000200,0
        dc.l $08000c00,$09000600,$0a000300,0
        dc.l $08000c00,$09000600,$0a000300,0
        dc.l $08000c00,$09000600,$0a000400,0
        dc.l $08000c00,$09000700,$0a000000,0
        dc.l $08000c00,$09000700,$0a000100,0
        dc.l $08000c00,$09000700,$0a000200,0
        dc.l $08000c00,$09000700,$0a000200,0
        dc.l $08000c00,$09000700,$0a000300,0
        dc.l $08000c00,$09000700,$0a000300,0
        dc.l $08000c00,$09000700,$0a000300,0
        dc.l $08000c00,$09000700,$0a000400,0
        dc.l $08000c00,$09000700,$0a000400,0
        dc.l $08000c00,$09000700,$0a000400,0
        dc.l $08000c00,$09000700,$0a000400,0
        dc.l $08000c00,$09000700,$0a000400,0
        dc.l $08000c00,$09000800,$0a000000,0
        dc.l $08000c00,$09000800,$0a000100,0
        dc.l $08000c00,$09000800,$0a000200,0
        dc.l $08000c00,$09000800,$0a000200,0
        dc.l $08000c00,$09000800,$0a000300,0
        dc.l $08000c00,$09000800,$0a000300,0
        dc.l $08000c00,$09000800,$0a000300,0
        dc.l $08000c00,$09000800,$0a000400,0
        dc.l $08000c00,$09000800,$0a000400,0
        dc.l $08000c00,$09000800,$0a000400,0
        dc.l $08000c00,$09000800,$0a000400,0
        dc.l $08000c00,$09000800,$0a000500,0
        dc.l $08000c00,$09000800,$0a000500,0
        dc.l $08000c00,$09000800,$0a000500,0
        dc.l $08000c00,$09000800,$0a000500,0
        dc.l $08000c00,$09000800,$0a000500,0
        dc.l $08000c00,$09000900,$0a000000,0
        dc.l $08000c00,$09000900,$0a000100,0
        dc.l $08000c00,$09000900,$0a000200,0
        dc.l $08000c00,$09000900,$0a000200,0
        dc.l $08000c00,$09000900,$0a000300,0
        dc.l $08000c00,$09000900,$0a000300,0
        dc.l $08000c00,$09000900,$0a000300,0
        dc.l $08000c00,$09000900,$0a000300,0
        dc.l $08000c00,$09000900,$0a000400,0
        dc.l $08000c00,$09000900,$0a000400,0
        dc.l $08000c00,$09000900,$0a000400,0
        dc.l $08000c00,$09000900,$0a000400,0
        dc.l $08000c00,$09000900,$0a000500,0
        dc.l $08000c00,$09000900,$0a000500,0
        dc.l $08000c00,$09000900,$0a000500,0
        dc.l $08000c00,$09000900,$0a000500,0
        ds.b 16				; just in case !

*****************************************************************
*	On entry, A0---> start of usable buffer
*		A1---> end of usable buffer
*		A5---> basic's variable table
*****************************************************************
* The INIT routine will RELOCATE the interrution routines!
* I did all the boring job for you!
* It's a pity you cannot use (pc) code in a destination address!
*****************************************************************
Init:   	move.l a3,-(sp)
* Relocate STARTADDR
	lea StartAddr(pc),a2
	lea Sta1(pc),a3
	move.l a2,2(a3)
	lea Sta2(pc),a3
	move.l a2,2(a3)
	lea Sta3(pc),a3
	move.l a2,2(a3)
	lea Sta4(pc),a3
	move.l a2,2(a3)
	lea Sta5(pc),a3
	move.l a2,2(a3)
	lea Sta6(pc),a3
	move.l a2,2(a3)
	lea SSta1(pc),a3		*Be carefull here!
	move.l a2,4(a3)
	lea SSta2(pc),a3
	move.l a2,4(a3)
* Relocate LENGTH
	lea Length(pc),a2
	lea Len1(pc),a3
	move.l a2,2(a3)
	lea Len2(pc),a3
	move.l a2,2(a3)
	lea Len3(pc),a3
	move.l a2,2(a3)
	lea Len4(pc),a3
	move.l a2,2(a3)
	lea Len5(pc),a3
	move.l a2,2(a3)
	lea Len6(pc),a3
	move.l a2,2(a3)
	lea SLen1(pc),a3		*Same as before
	move.l a2,4(a3)
	lea SLen2(pc),a3
	move.l a2,4(a3)
	lea SLen3(pc),a3
	move.l a2,4(a3)
	lea SLen4(pc),a3
	move.l a2,4(a3)
	move.l (sp)+,a3
* Ends the routine
	lea End(pc),a2
End:	rts

* FORWARD NORMAL PLAY ROUTINE *

PLAYIRQ1:
	MOVEM.L D7/A3,-(SP)		; Save reg
**********************************************************************
* RELATIVE PC NOW: YOU CAN and IT IS FASTER!
	MOVEA.L STARTADDR(PC),A3	; Address to play
	MOVE.B (A3),D7		; in D7
**********************************************************************
* LABELS TO RELOCATE!
Len1:	SUBQ.L #1,$FFFFFF	; length -1
	BEQ OUTOFIT		; End of play, exit
Sta1:	ADDQ.L #1,$FFFFFF	; address to play +1
	ANDI.W #$FF,D7		; isolate datas
********************************************************************** 
* NOW you can do it, because it is in the same code block!
	LEA voldat2(pc),A3		; get vol table address
	LSL.W #4,D7		; *16
	MOVE.L 0(A3,D7.W),PSG	; datas TO SOUND CHIP VOL1	
	MOVE.L 4(A3,D7.W),PSG	; datas TO SOUND CHIP VOL2
	MOVE.L 8(A3,D7.W),PSG	; datas TO SOUND CHIP VOL3
	MOVEM.L (SP)+,D7/A3		; GET REG
	RTE			; END INTERUPT

* SAME AS ABOVE BUT REVERSE PLAY, SWEEP ETC...

* BACKWARD NORMAL PLAY ROUTINE *

PLAYIRQ2:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR(PC),A3
	MOVE.B (A3),D7
Len2:	SUBQ.L #1,$FFFFFF
	BEQ OUTOFIT
Sta2:	SUBQ.L #1,$FFFFFF
	ANDI.W #$FF,D7
************************************************************
* THERE WAS A BUG HERE! YOU FORGOT TO LOAD A3!
	LEA VOLDAT2(PC),A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE

* FORWARD LOOP PLAY ROUTINE *

PLAYIRQ3:
	MOVEM.L D7/A3,-(SP)
	ANDI.W #$FF,D7
	MOVEA.L STARTADDR(PC),A3
	MOVE.B (A3),D7
Len3:	SUBQ.L #1,$FFFFFF
	BEQ.S OUTOFIT2
Sta3:	ADDQ.L #1,$FFFFFF
INTOIT2:ANDI.W #$FF,D7
	LEA voldat2(pc),A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE
OUTOFIT2:
SLen1:	MOVE.L LENGTH2(pc),$FFFFFF
SSta1:	MOVE.L STARTADDR2(pc),$FFFFFF
	BRA.s INTOIT2

* BACKWARD LOOP PLAY ROUTINE *

PLAYIRQ4:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR(pc),A3
	MOVE.B (A3),D7
Len4:	SUBQ.L #1,$FFFFFF
	BEQ.S OUTOFIT3
Sta4:	SUBQ.L #1,$FFFFFF
INTOIT3:ANDI.W #$FF,D7
	LEA voldat2(pc),A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE
OUTOFIT3:
SLen2:	MOVE.L LENGTH2(pc),$FFFFFF
SSta2:	MOVE.L STARTADDR2(pc),$FFFFFF
	BRA.s INTOIT3


* SWEEP PLAY ROUTINE *

PLAYIRQ5:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR(pc),A3
	MOVE.B (A3),D7
Len5:	SUBQ.L #1,$FFFFFF
	BEQ.S OUTOFIT4
Sta5:	ADDQ.L #1,$FFFFFF
INTOIT4:ANDI.W #$FF,D7
	LEA voldat2(pc),A3
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE
OUTOFIT4:
SLen3:	MOVE.L LENGTH2(pc),$FFFFFF
********* BUGBUGUBUG
*	MOVE.L #PLAYIRQ6,$134
	lea PLAYIRQ6(pc),a3
	move.l a3,$134
	BRA.s INTOIT4

PLAYIRQ6:
	MOVEM.L D7/A3,-(SP)
	MOVEA.L STARTADDR(pc),A3
	MOVE.B (A3),D7
Len6:	SUBQ.L #1,$FFFFFF
	BEQ.S OUTOFIT5
Sta6:	SUBQ.L #1,$FFFFFF
INTOIT5:ANDI.W #$FF,D7
	LEA VOLDAT2(pc),A3
	MOVE.B #8,PSG
	LSL.W #4,D7
	MOVE.L 0(A3,D7.W),PSG
	MOVE.L 4(A3,D7.W),PSG
	MOVE.L 8(A3,D7.W),PSG
	MOVEM.L (SP)+,D7/A3
	RTE
OUTOFIT5:
SLen4:	MOVE.L LENGTH2(pc),$FFFFFF
********* BUGBUGBUGUBUGBUGUBUGUBUG!!!!! ****************************
*	MOVE.L #PLAYIRQ5,$134
	lea PLAYIRQ5(pc),a3
	move.l a3,$134
	BRA INTOIT5

**************************************************************************

ADOUBANK:	EQU 214

************************ LIBRARY *****************************************
Libr:

L1:     dc.w 0

	move.l Debut(a5),a3		* defined in EQUATES.S
	move.l 0(a3,d1.w),a3          * adress datas label (params=4!)

* P.S. My assembler can't do PEA instructions, It crashes.

	lea snd_init(a3),a2		; sound chip init
	move.l a2,-(sp)
	move.w #32,-(sp)		; do_sound
	trap #14			; X-bios
	addq.l #6,sp
	rts

* =SAMPLE function, simply returns the value at the cartridge port

l2:	dc.w 0

	MOVE.B $FB0001,D0		; Get byte from port
	SUBI.B #$80,D0		; Sign it
	EXT.W D0			; Turn into Word Sign
	EXT.L D0			; Turn into Long Sign
	MOVE.L D0,-(A6)		; Push it to PILE
	RTS			; End

* This is the samplay function
* Just one parameter, which is the sample number to play in bank

l3:	dc.w L3A-L3,0

	move.l Debut(a5),a3		
	move.l 0(a3,d1.w),a3 
 
********* NO NEED TO DO THAT!          
*	MOVE.L A0,SAVEREG1(A3)		; save A0 
*	MOVE.L A1,SAVEREG2(A3)		; and A1

	move.w #0,oknotm(A3)		; Clear Music Flag
access2:
	MOVE.L (A6)+,D3			; Get param
	MOVE.L D3,SPARAM(A3)		; Save it
	move.w sampbank(A3),d3		; Get default sample bank number
	and.l #$ffff,d3			; Long word it
	move.l d3,-(a6)			; Push onto pile
L3A:	jsr ADOUBANK			; Get start address
 
* What I just did was pushed the sample bank number ( default 5 ) onto
* the pile, then called the adoubank routine to get the address of it
* Is that O.K ?? Or should I not do that.
************************************************** PERFECT MAN!

	MOVEA.L D3,A1			; A1 = start of bank

* Check if start of bank is "MAESTRO!"
* the bank header.

	cmpi.b #'M',(a1)	
	bne notsbank
	cmpi.b #'A',1(a1)
	bne notsbank
	cmpi.b #'E',2(a1)
	bne notsbank
	cmpi.b #'S',3(a1)
	bne notsbank
	cmpi.b #'T',4(a1)
	bne notsbank
	cmpi.b #'R',5(a1)
	bne notsbank
	cmpi.b #'O',6(a1)
	bne notsbank
	cmpi.b #'!',7(a1)
	bne notsbank

	move.l a1,-(sp)

* a1=start of memory bank

* Get the number of samples in the bank

	CLR.W D7		; d7=sample counter
LOOPPO:	ADDQ.L #8,A1		; a1=offset to sample X
	ADDQ.W #1,D7		; increment counter
	CMPI.L #0,(A1)		; is offset 0 ( no more samples )
	BNE LOOPPO		; No, more samples to count
	SUBQ.W #1,D7		; Number Samples in d7
	MOVE.L (SP)+,A1		; get a1 back
	MOVEA.L A1,A0		; put in a0

	MOVE.L SPARAM(a3),D3	; Param back in d3

	CMPI.B #0,D3		; sample number < 0
	BEQ SAMPNFOUND		; yes, error
	CMP.B D7,D3		; sample number > total samples in bank
	BGT SAMPNFOUND		; yes, error

	ANDI.L #$FF,D3		; ISOLATE SAMPLE NUMBER 0-32
	LSL.W #3,D3             	; NUMBER=NUMBER * 8
	ADDA.L D3,A1		; ADD TO START OF BANK 
	ADDA.L (A1),A0          	; OFFSET TO START OF SAMPLE + BASE
	MOVE.L 4(A1),A1		; LENGTH
	
	
* A0.L = start address
* A1.L = LENGTH OF SAMPLE + 8

	SUBA.L #20,A1		; length-20
	ADDA.L #8,A0		; start+8
**************************************************************************
* You have to use A3 as an offset in the datas area
* I just found it is very simple to have the offset of a DC in the
* datas area by doing AD-datas(a3)! Why didn't think to it before, instead
* of making a list of equates and counting the length in bytes!
* You can do that to the rest of your program! It makes it so much 
* clearer!
* Sorry!
**************************************************************************
ACCESS:	MOVE.L A0,STARTADDR-datas(a3)	; store start address
	MOVE.L A1,LENGTH-datas(a3)	; and length
	MOVE.L A0,STARTADDR2-datas(a3)	; backup
	MOVE.L A1,LENGTH2-datas(a3)	; backup

	MOVE.W SR,D7		; save status reg
	MOVE.W #$2700,SR		; interrupts off
	CLR.B $FFFA19		; timer off
	MOVE.B #1,$FFFA19		; timer mode 1 subdivide by 4
	CMP.W #1,AUTO_ON(a3)	; Auto sample rate on
	BNE NOTON			; no, skip

* Check if start of sample contains 'JON' code, if so then get the
* sample rate, else flag an error

	CMP.B #'J',(A0)		; Check for J
	BNE NOTRATE
	CMP.B #'O',1(A0)	; 'O'
	BNE NOTRATE
	CMP.B #'N',2(A0)	; 'N'
	BNE NOTRATE
	MOVE.B 3(A0),D3		; Jon found, get sample rate
	AND.W #$FF,D3		; Isolate word
	LEA HERTZ(a3),A0		; Rate convertion table
	MOVE.B 0(A0,D3.W),D3	; GET TIMER A datas FOR SAMRATE
	ADD.B #19,D3		; add 19 offset to rate
	MOVE.B D3,$FFFA1F		; timer a datas register
	BRA SKIPNXT		; skip next bit

NOTON: 	CMP.W #0,OKNOTM(a3)	; Music mode ?
	BEQ OKNOTM1		; no, skip
	MOVE.B SPEED(a3),$FFFA1F	; get music speed
	BRA SKIPNXT		; skip next bit
OKNOTM1:	MOVE.B SPEED(a3),d3		; get speed
	ADD.B #19,d3		; add 19
	move.b d3,$FFFA1F		; store it
SKIPNXT:
	OR.B #$20,$FFFA13		; Enable Timer A mask
	OR.B #$20,$FFFA07		; Enable Timer A
	BCLR.B #3,$FFFA17		; Vector register
	CMP.W #1,TYPE(a3)	; Type ? Forward play, Back,Loop, Sweep
	BEQ TYPE1	
	CMP.W #2,TYPE(a3)	 
	BEQ TYPE2
	CMP.W #3,TYPE(a3)	
	BEQ TYPE3
	CMP.W #4,TYPE(a3)
	BEQ TYPE4
	CMP.W #5,TYPE(a3)
	BEQ TYPE5
TYPE1:	
********* To get the address of the routine, you must use A3 now!
*	And so to store all the params! (it is faster anyway)

	lea playirq1-datas(a3),a0
	move.l a0,$134		; store address
	MOVE.W D7,SR		; status back
	BRA PLAYEND		; end
TYPE2:
	lea playirq2-datas(a3),a0	; same as above
	move.l a0,$134
	MOVE.L LENGTH-datas(a3),D0
	ADD.L D0,STARTADDR-datas(a3)
	ADD.L D0,STARTADDR2-datas(a3)
	MOVE.W D7,SR
	BRA PLAYEND
TYPE3:
	lea PLAYIRQ3-datas(a3),a0
	move.l a0,$134
	MOVE.W D7,SR
	BRA PLAYEND
TYPE4:
	lea PLAYIRQ4-datas(a3),a0
	move.l a0,$134
	MOVE.L LENGTH-datas(a3),D0
	ADD.L D0,STARTADDR-datas(a3)
	ADD.L D0,STARTADDR2-datas(a3)
	MOVE.W D7,SR
	BRA PLAYEND
TYPE5:
	lea PLAYIRQ5-datas(a3),a0
	move.l a0,$134
	MOVE.W D7,SR
	BRA PLAYEND
OUTOFIT:	BCLR #5,$FFFA07		; clear interupt
	MOVEM.L (SP)+,D7/A3	; exit interupt
	RTE

* Errors

NOTRATE:
	MOVE.W D7,SR
	MOVEQ.W #3,D0
	BRA DOERR2
notsbank:
	clr.w d0
	bra playend
	moveQ.w #0,d0
	bra doerr2
SAMPNFOUND:
	MOVEQ.W #1,D0
	bra doerr2
doerr2	
*	NO NEED TO DO THAT!
*	MOVE.L SAVEREG1(A3),A0
*	MOVE.L SAVEREG2(A3),A1

        	move.l error(a5),a0
        	jmp (a0) 
	BRA DOERR2
	
PLAYEND:
*	MOVE.L SAVEREG1(A3),A0
*	MOVE.L SAVEREG2(A3),A1
	clr.l d0
	RTS


***********************************************************************
*	END OF THE library routine
l4:	dc.w 0
***********************************************************************
	END

