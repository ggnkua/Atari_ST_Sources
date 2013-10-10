*************************************************
*
* Jagpad Extension for STOS
*
* V0.1
*
*

        OUTPUT  JOYPAD.EXZ

* Jump header
        bra     INIT

***********************************************
*
* Header
*

* Start of token list
        dc.b    128

TOKENS  
	dc.b	"jagpd",129

* The end of the token list
        dc.b    0

	even
	
* Now the jump table

JUMPS   dc.w    2
	dc.l	dummy
	dc.l	joypad

* The welcome mesages in English and French

WELCOME dc.b    10,13,"                            The Jagpad Extension v0.1",0
        dc.b    10,13,"                             le Extension Jagpad v0.1",0
        even

* Some system variables

RETURN	dc.l	0
SYSTEM	dc.l	0

* The routine that is called on start-up

INIT    lea     END,a0
        lea     COLDST,a1
        rts

COLDST  lea     WELCOME,a0      ; vital stuff
        lea     WARMST,a1
        lea     TOKENS,a2
        lea     JUMPS,a3
        rts

* Executed on UNDO in editor

WARMST  rts


*************************
*
* Our commands
*
*

* function returns the current values of jagpad
joypad	move.l	(sp)+,RETURN

	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	cmpi.l	#1,d3
	bgt	ntdne

	move.l	d3,-(sp)

	bsr	jpd

	move.l	(sp)+,d0

	tst.l	d0
	beq	prt0

	move.l	d6,d3
prt0	move.l	d3,d4
	andi.l	#%1111000000000000000000000,d4
	lsr.l	#4,d4
	andi.l	#%11111111111111111,d3
	or.l	d4,d3

	clr.l	d2
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)

* Function performs joypad read.
* Returns :-
* d3.l contains c1numpad,c1midbuts,c1firebuts,c1joypad
* d6.l = c2numpad,c2midbuts,c2firebuts,c2joypad


jpd	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	move.l	#0,a0
	move.l	#0,c1numpad
	move.l	#0,c2numpad

* read row 1

	move.w	#$ffee,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#1,d0
	move.b	d0,d3

	move.w	d1,d0
	andi.w	#2,d0
	lsr.w	#1,d0
	move.b	d0,d4

	move.w	d1,d0
	andi.w	#4,d0
	lsr.w	#2,d0
	move.b	d0,d6

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#3,d0
	move.b	d0,d7

	move.w	d2,d0
	andi.w	#$f00,d0
	lsr.w	#8,d0
	move.b	d0,d5

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	move.l	d0,a0

* read row 2

	move.w	#$ffdd,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#2,d0
	or.b	d0,d4

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#2,d0
	or.b	d0,d7

	move.w	d2,d0
	andi.w	#$f00,d0
	lsr.w	#8,d0
	move.w	d0,c1numpad

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	move.w	d0,c2numpad

* read row 3

	move.w	#$ffbb,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#2,d0
	lsl.w	#1,d0
	or.b	d0,d4

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#1,d0
	or.b	d0,d7

	move.w	d2,d0
	andi.w	#$f00,d0
	lsr.w	#4,d0
	or.l	d0,c1numpad

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	or.l	d0,c2numpad

* read row 4

	move.w	#$ff77,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#2,d0
	or.b	d0,d3

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#2,d0
	or.b	d0,d6

	move.w	d2,d0
	andi.w	#$f00,d0
	or.l	d0,c1numpad

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#4,d0
	or.l	d0,c2numpad

	lsl.l	#7,d3	; d3 contains xxxx,c1midbuts,c1firebuts,c1joypad
	lsl.l	#4,d4
	or.l	d4,d3
	or.l	d5,d3	

	lsl.l	#7,d6	; d6 = xxxx,c2midbuts,c2firebuts,c2joypad
	lsl.l	#4,d7
	or.l	d7,d6
	move.l	a0,d2
	or.l	d2,d6

	move.l	c1numpad,d2	; d2 = c1numpad
	lsl.l	#5,d2
	move.l	c2numpad,d5	; d5 = c2numpad
	lsl.l	#5,d5

	or.l	d2,d3
	or.l	d5,d6

	rts

read_controller
	move.w	d0,$ff9202
	move.w	$ff9200,d1
	move.w	$ff9202,d2

	andi.w	#$f,d1
	andi.w	#$ff00,d2

	not.w	d1
	not.w	d2

	rts


*************************
*
* Odds and sods...
*

dummy	move.l	(sp)+,RETURN
	bra	ntdne

SYNTAX	moveq	#12,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

TYPEMIS	moveq	#19,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

ntdne	moveq	#0,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)


*************************
*
* Data space
*

c1numpad	ds.l	1
c2numpad	ds.l	1	
	
*************************
*
* End of code

	dc.l	0
END
