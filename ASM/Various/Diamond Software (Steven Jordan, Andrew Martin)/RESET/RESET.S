***************************************************************************
*							    *
* 		    The Reset Picture Demo			    *
*							    *
*              Written By Steven Jordan & Andrew Martin                   *
*							    *
*                   (c) Diamond Software! 1993	                        *
*							    *
***************************************************************************


start	bsr	super		;set in supervisor mode
	bsr	checkres		;check for high res
	bsr	setres		;set the res to low
	bsr	put_reset		;pset the reset demo 
	bsr	setpal		;set the palette

loop	bra	loop		;keep looping

*******************************************
* CHECK TO SEE IF HIGH RES                *
*******************************************

checkres	move.w	#4,-(sp)		;get res
	trap	#14		;call XBOIS
	addq.l	#2,sp		;adjust the stack
	
	cmp.b	#2,d0		;is it high?
	rts			;no, the return

	clr.l	-(sp)		;yes, then I think
	trap	#1		;we better quit

	rts

*******************************************
* SET THE RES TO LOW		  *
*******************************************

setres	move.w	#0,-(sp)		;set low
	move.l	#-1,-(sp)		;don't change
	move.l	#-1,-(sp)		; "     "
	move.w	#5,-(sp)		;call set-screen
	trap	#14		;call XBOIS
	add.l	#12,sp		;adjust the stack
	rts			;return

*******************************************
* PUT THE COMPUTER IN SUPERVISOR MODE     *
*******************************************

super	clr.l 	-(sp)		;don't change
	move.w 	#$20,-(sp)	;call super
	trap	#1		;call GEMDOS
	addq.l 	#6,sp		;adjust stack
	rts

*******************************************
* SET THE PALETTE		            *
*******************************************

setpal

	move.l	pic+2,-(sp)	;add 2 to get the palette
	move.w	#6,-(sp)		;set the colours
	trap	#14		;call XBOIS
	addq.l	#6,sp		;adjust the stack
	rts

*******************************************
* PUT THE RESET DEMO IN THE RESET VECTOR  *
*******************************************

put_reset
	move.b 	#4,$484		;we have something
	move.l 	#$31415926,$426  	;put the magic number in 'resvalid'
	move.l 	#reset,$42a	;put the demo in the reset vector
	rts	

reset 	move.w 	#$2700,sr		;all systems go!
	move.b 	#$2,$ff820a        	;call the colours
	lea 	$23de6,a7		;set logical screen
	move.w 	#2,-(sp)		;set logical
	trap 	#14		;call XBOIS
	addq.l 	#2,sp		;adjust the stack

	move.l 	d0,a1		;display pic
	lea 	pic+34,a0		;go strait to the pic
	move.w 	#$fa0,d6		;repeat         >----
loop1	move.l 	(a0)+,(a1)+	;put pic on screen  |
	move.l 	(a0)+,(a1)+	;and again          |
	dbf 	d6,loop1		;until finished <----

 	move.w 	#-1,-(sp)		;don't change res
 	move.l 	d0,-(sp)		;stay the same
 	move.l 	d0,-(sp)		;stay the same
 	move.w 	#5,-(sp)		;call set-screen
 	trap	#14		;call XBOIS (Again. Sigh)
 	add.l 	#12,SP		;adjust the stack

	move.l 	#$07770000,$ff8240	;set the colours
	move.l 	#$07000555,$ff8244	
	move.l 	#$06660222,$ff8248
	move.l 	#$01170227,$ff824c
	move.l 	#$04440532,$ff8250
	move.l 	#$06430654,$ff8254
	move.l 	#$07540765,$ff8258
	move.l 	#$07210000,$ff825c

resloop
	bra.s 	resloop		;keep looping

pic	incbin	"a:\assembly\borders\address.pi1"




