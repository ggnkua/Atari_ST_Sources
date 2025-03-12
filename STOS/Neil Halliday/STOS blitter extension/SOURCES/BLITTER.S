* STORM STOS BLITTER EXTENSION - INTERPRETER VERSION 0.1(beta)
*
* WRITTEN BY NEIL HALLIDAY 17/03/1994
* (C) 1995 STORM Developments LTD.
* 
* FULL VERSION!
*
* USAGE:
*
* Blit sinc 		: Set source incs, x and y
* x = Blit pcls		: Clear a full screen, on a single bit plane
* Blit dinc 		: Set destination incs, x and y
* x = Blit fskopy 	: Copy an entire screen on a single bit plane
* Blit address 		: Set source address and destination address
* Blit mask 		: Set end mask values
* Blit count 		: Set count values  
* Blit hop 		: Set half tone operation
* Blit op 		: Set logical operation
* Blit skew 		: Set the skew value
* Blit nfsr 		: Set the No Final Source Read flag
* Blit fxsr 		: Set Force Extra Source Read flag 
* Blit line 		: Set the start line for the half tone
* Blit smudge 		: Set smudge
* Blit hog 		: Set Hog mode
* Blit it 		: Set the blitter going
* Blit fcopy 		: Copy an entire screen around
* Blit cls 		: Clear a screen
 
	bra	init
	dc.b	128
	
tokens:

	dc.b	"blit sinc",128
	dc.b	"blit clr",129
	dc.b	"blit dinc",130
	dc.b	"blit fskopy",131
	dc.b	"blit address",132
	dc.b	"blit mask",134
	dc.b	"blit count",136
	dc.b	"blit hop",138
	dc.b	"blit op",140
	dc.b	"blit skew",142
	dc.b	"blit nfsr",144
	dc.b	"blit fxsr",146
	dc.b	"blit line",148
	dc.b	"blit smudge",150
	dc.b	"blit hog",152
	dc.b	"blit it",154
	dc.b	"blit fcopy",156
	dc.b	"blit cls",158
	dc.b	0
	even
	
jump:
	dc.w	31
	dc.l	blit_sinc
	dc.l	blit_clr
	dc.l	blit_dinc
	dc.l	blit_fskopy
	dc.l	blit_address
	dc.l	dummy
	dc.l	blit_mask
	dc.l	dummy
	dc.l	blit_count
	dc.l	dummy
	dc.l	blit_hop
	dc.l	dummy
	dc.l	blit_op
	dc.l	dummy
	dc.l	blit_skew
	dc.l	dummy
	dc.l	blit_nfsr
	dc.l	dummy
	dc.l	blit_fxsr
	dc.l	dummy
	dc.l	blit_line
	dc.l	dummy
	dc.l	blit_smudge
	dc.l	dummy
	dc.l	blit_hog
	dc.l	dummy
	dc.l	blit_it
	dc.l	dummy
	dc.l	blit_fcopy
	dc.l	dummy
	dc.l	blit_cls

message:


	dc.b	10,$15,"** STORM Blitter Extension V0.1beta (c)STORM 1995 **",$12,0
	dc.b	10,$15,"** STORM Blitter Extension V0.1beta (c)STORM 1995 **",$12,0
	dc.b	0
	even
	
system:	dc.l	0
	
return:	dc.l	0
	
init:	
	lea	exit,a0
	lea	coldst,a1
	rts
	
coldst:
	move.l	a0,system
	lea 	message,a0
	lea	warm,a1
	lea	tokens,a2
	lea	jump,a3
	
warm:	rts

dummy:	rts



** Blit sinc, get the source increments
**
** IN  : x,y
** OUT : 
	
blit_sinc:
	
	move.l	(a7)+,return		; Save return

	cmp	#2,d0			; 2 variables?
	bne	syntax
	
	bsr	getint
	move.w	d3,$ff8a22		; Source y increment
	bsr	getint
	move.w	d3,$ff8a20		; Source x increment

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it



** Blit clr, Clear an entire screen on a single bit plane
**
** IN  : screen to clear
** OUT : 
	
blit_clr:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 2 parameters?
	bne	syntax
	
	bsr	getint			; Screen to clear
	move.l	d3,a0
	
	move.w	#8,$ff8a2e		; Destination x inc
	move.w	#2,$ff8a30		; Destination y inc
	move.l	a0,$ff8a32		; Destination address
	move.w	#8000,$ff8a36		; X count
	move.w	#1,$ff8a38		; Y count
	move.w	#$ffff,$ff8a28		; Endmask 1
	move.w	#$ffff,$ff8a2a		; Endmask 2
	move.w	#$ffff,$ff8a2c		; Endmask 3
	move.b	#0,$ff8a3a		; Blit hop
	move.b	#0,$ff8a3b		; Blit op
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Line,smudge,hog,busy	

	move.l	#0,d2
	move.l	#0,d3			
		
	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it




** Blit dinc, get the destination increments
**
** IN  : x,y
** OUT : 
	
blit_dinc:
	
	move.l	(a7)+,return		; Save return

	cmp	#2,d0			; 2 variables?
	bne	syntax
	
	bsr	getint
	move.w	d3,$ff8a30		; Destination y increment
	bsr	getint
	move.w	d3,$ff8a2e		; Destination x increment

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it


** Blit fskopy, Copy an entire screen on a single bitplane
**
** IN  : source screen, destination screen 
** OUT : 
	
blit_fskopy:
	
	move.l	(a7)+,return		; Save return

	cmp	#2,d0			; 2 parameters?
	bne	syntax
	
	bsr	getint			; Destination screen
	move.l	d3,a1
	
	bsr	getint			; Source screen
	move.l	d3,a0
	
	move.w	#8,$ff8a20		; Source x inc
	move.w	#8,$ff8a22		; Source y inc
	move.w	#8,$ff8a2e		; Destination x inc
	move.w	#8,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#20,$ff8a36		; X count
	move.w	#200,$ff8a38		; Y count
	move.w	#$ffff,$ff8a28		; Endmask 1
	move.w	#$ffff,$ff8a2a		; Endmask 2
	move.w	#$ffff,$ff8a2c		; Endmask 3
	move.b	#2,$ff8a3a		; Blit hop
	move.b	#3,$ff8a3b		; Blit op
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Line,smudge,hog,busy	
	
	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it


** Blit address, get the source and destination addresses
**
** IN  : source,desination
** OUT : 
	
blit_address:
	
	move.l	(a7)+,return		; Save return

	cmp	#2,d0			; 2 variables?
	bne	syntax
	
	bsr	getint
	move.l	d3,$ff8a32		; Destination address
	bsr	getint
	move.l	d3,$ff8a24		; Source address

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it



** Blit mask, Set the end mask values
**
** IN  : mask1,mask2,mask3
** OUT : 
	
blit_mask:
	
	move.l	(a7)+,return		; Save return

	cmp	#3,d0			; 3 variables?
	bne	syntax
	
	bsr	getint
	move.w	d3,$ff8a2c		; End mask 3
	bsr	getint
	move.w	d3,$ff8a2a		; End mask 2
	bsr	getint
	move.w	d3,$ff8a28		; End mask 1

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it



** Blit count, get the count line values
**
** IN  : x count,y count
** OUT : 
	
blit_count:
	
	move.l	(a7)+,return		; Save return

	cmp	#2,d0			; 2 variables?
	bne	syntax
	
	bsr	getint
	move.w	d3,$ff8a38		; Y count
	bsr	getint
	move.w	d3,$ff8a36		; X Count

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it



** Blit Hop, Set the Half tone operation
**
** IN  : Half Tone Operation
** OUT : 
	
blit_hop:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 1 variable?
	bne	syntax
	
	bsr	getint
	move.b	d3,$ff8a3a		; Blit Hop

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it



** Blit op, Set the logical operation
**
** IN  : Logical Operation
** OUT : 
	
blit_op:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 1 variable?
	bne	syntax
	
	bsr	getint
	move.b	d3,$ff8a3b		; Blit op

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it



** Blit skew, Set the Blitter skew value
**
** IN  : Skew Value 
** OUT : 
	
blit_skew:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 1 variable?
	bne	syntax
	
	bsr	getint
	move.b	d3,$ff8a3d		; Blit skew value

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it
	
	
	
	
** Blit nfsr, Set the Blitter No Final Source Read value
**
** IN  : Value 
** OUT : 
	
blit_nfsr:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 1 variable?
	bne	syntax
	
	bsr	getint
	cmp	#0,d3
	beq	.set_to_zero
	
	bset	#6,$ff8a3d		; Set bit
	bra	.out
	
.set_to_zero
	bclr	#6,$ff8a3d		; Clear bit	

.out	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it
	
	

** Blit fxsr, Set the Blitter Force Extra Source Read value
**
** IN  : Value 
** OUT : 
	
blit_fxsr:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 1 variable?
	bne	syntax
	
	bsr	getint
	cmp	#0,d3
	beq	.set_to_zero
	
	bset	#7,$ff8a3d		; Set bit
	bra	.out
	
.set_to_zero
	bclr	#7,$ff8a3d		; Clear bit	

.out	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it


	
** Blit line, Set the Blitter halftone start line
**
** IN  : Line number 
** OUT : 
	
blit_line:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 1 variable?
	bne	syntax
	
	bsr	getint
	move.b	d3,$ff8a3c		; Blit line start

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it
	
	
	
	
** Blit smudge, Set the smudge value
**
** IN  : Value 
** OUT : 
	
blit_smudge:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 1 variable?
	bne	syntax
	
	bsr	getint
	cmp	#0,d3
	beq	.set_to_zero
	
	bset	#5,$ff8a3c		; Set bit
	bra	.out
	
.set_to_zero
	bclr	#5,$ff8a3c		; Clear bit	

.out	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it


	
** Blit hog, Set the blitter to hog mode
**
** IN  : Value 
** OUT : 
	
blit_hog:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 1 variable?
	bne	syntax
	
	bsr	getint
	cmp	#0,d3
	beq	.set_to_zero
	
	bset	#6,$ff8a3c		; Set bit
	bra	.out
	
.set_to_zero
	bclr	#6,$ff8a3c		; Clear bit	

.out	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it


	
** Blit it, Set the Blitter going
**
** IN  : 
** OUT : 
	
blit_it:
	
	move.l	(a7)+,return		; Save return

	bset	#7,$ff8a3c		; Set bit

	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it



** Blit fcopy, Copy an entire screen around
**
** IN  : source screen, destination screen 
** OUT : 
	
blit_fcopy:
	
	move.l	(a7)+,return		; Save return

	cmp	#2,d0			; 2 parameters?
	bne	syntax
	
	bsr	getint			; Destination screen
	move.l	d3,a1
	
	bsr	getint			; Source screen
	move.l	d3,a0
	
	move.w	#2,$ff8a20		; Source x inc
	move.w	#2,$ff8a22		; Source y inc
	move.w	#2,$ff8a2e		; Destination x inc
	move.w	#2,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#80,$ff8a36		; X count
	move.w	#200,$ff8a38		; Y count
	move.w	#$ffff,$ff8a28		; Endmask 1
	move.w	#$ffff,$ff8a2a		; Endmask 2
	move.w	#$ffff,$ff8a2c		; Endmask 3
	move.b	#2,$ff8a3a		; Blit hop
	move.b	#3,$ff8a3b		; Blit op
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Line,smudge,hog,busy	
	
	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it



** Blit cls, Clear an entire screen
**
** IN  : screen to clear
** OUT : 
	
blit_cls:
	
	move.l	(a7)+,return		; Save return

	cmp	#1,d0			; 2 parameters?
	bne	syntax
	
	bsr	getint			; Screen to clear
	move.l	d3,a0
	
	move.w	#2,$ff8a2e		; Destination x inc
	move.w	#2,$ff8a30		; Destination y inc
	move.l	a0,$ff8a32		; Destination address
	move.w	#32000,$ff8a36		; X count
	move.w	#1,$ff8a38		; Y count
	move.w	#$ffff,$ff8a28		; Endmask 1
	move.w	#$ffff,$ff8a2a		; Endmask 2
	move.w	#$ffff,$ff8a2c		; Endmask 3
	move.b	#0,$ff8a3a		; Blit hop
	move.b	#0,$ff8a3b		; Blit op
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Line,smudge,hog,busy	
	
	move.l	return,a0		; Restore return
	jmp	(a0)			; jump to it

*** Essential STOS library routines

getint:

	move.l	(a7)+,a0		; Save return
	movem.l	(a7)+,d2-d4		; Get parameter
	tst.b	d2			; Is it an integer?
	bne	typemis			; No, type mismatch
	jmp	(a0)			; Return


* Error values


syntax:

	moveq	#12,d0			; Error 12 (Syntax error)
	bra.s	error

typemis:

	moveq	#19,d0			; Error 19 (Type Mismatch)
;	bra.s	error

error:

	move.l	system(pc),a0
	move.l	$14(a0),a0
	jmp	(a0)

exit	equ	*

