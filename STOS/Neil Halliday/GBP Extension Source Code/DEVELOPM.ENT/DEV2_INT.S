* STORM Development Extension (Part 2) - INTERPRETER VERSION 0.4(Beta)
*
* WRITTEN BY NEIL HALLIDAY 1995
* (C)1995 STORM Developments.
* 
* FULL VERSION!

*
* USAGE:
*
* auxin..	x=auxin..		Get a byte from the AUX port
*
* pcdeek..	x=pcdeek..		Get a word from a PC file
* pcleek..	x=pcleek..		Get a long word from a PC file
*
* cline$..	x$=cline$..		Get the command line parameters


	bra	init
	dc.b	128
	
tokens:

	dc.b	"nrh",128			; 
	dc.b	"auxin",129			; Auxin 
	dc.b	"nrh",130			; 
	dc.b	"pcdeek",131			; Pcdeek 
	dc.b	"nrh",132			; 
	dc.b	"pcleek",133			; Pcleek 
	dc.b	"nrh",134			; 
	dc.b	"cline$",135			; Cline$
	dc.b	"nrh",136			; 
	dc.b	"nrh",137			; 
	dc.b	"nrh",138			; 
	dc.b	"nrh",139			; 
	dc.b	"nrh",140			; 
	dc.b	"nrh",141			; 
	dc.b	"nrh",142			; 			
	dc.b	"nrh",143			; 
	dc.b	"nrh",144			; 
	dc.b	"nrh",145			; 
	dc.b	"nrh",146			; 
	dc.b	"nrh",147			; 
	dc.b	"nrh",148			; 
	dc.b	"nrh",149			; 
	dc.b	"nrh",150			;
	dc.b	"nrh",151			; 
	dc.b	"nrh",152			;
	dc.b	"nrh",153			; 
	dc.b	"nrh",154			;
	dc.b	"nrh",155			; 
	dc.b	"nrh",156			;
	dc.b	"nrh",157			; 
	dc.b	"nrh",158			;
	dc.b	"nrh",159			; 
	dc.b	0
	even
	
jump:	dc.w	32 
	dc.l	dummy
	dc.l	auxin
	dc.l	dummy
	dc.l	pcdeek
	dc.l	dummy
	dc.l	pcleek
	dc.l	dummy
	dc.l	cline
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy
	dc.l	dummy

message:


	dc.b	10,$15,"** V0.4(beta) STORM Development Extension (Part II) (c)STORM '95 **",$12,0
	dc.b	10,$15,"** V0.4(beta) STORM Development Extension (Part II) (c)STORM '95 **",$12,0
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


** ASK STOS FOR SOME STRING SPACE

ASK:	move.l	system(pc),a0
	move.l	$1c(a0),a0
	jsr	(a0)
	rts
	
	
**     COMMAND:	AUXIN
**  	SYNTAX:	x=AUXIN
**
** DESCRIPTION:	Get a byte that is waiting in the AUX buffer

auxin:
	move.l	(a7)+,return		; Save return
	move.w	#1,-(sp)		; Bconin
	move.w	#2,-(sp)
	trap	#13
	lea	4(sp),sp
	move.l	d0,d3
	move.w	#0,d2			; Tell STOS to expect a number
	move.l	return,a0		; Load return
	jmp	(a0)




**     COMMAND:	PCDEEK
**  	SYNTAX:	x=PCDEEK
**
** DESCRIPTION:	Get a low bit word, and convert it into a highbit word

pcdeek:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 param?
	bne	syntax
	bsr	getint			; Address
	move.l	d3,a0			
	clr.l	.wrk
	move.l	#.wrk,a1		; Work address
	move.b	(a0)+,3(a1)		; Swap data around
	move.b	(a0),2(a1)
	move.l	.wrk,d3		
	move.w	#0,d2			; Tell STOS to expect a number
	move.l	return,a0		; Load return
	jmp	(a0)

.wrk	dc.l	0




**     COMMAND:	PCLEEK
**  	SYNTAX:	x=PCLEEK
**
** DESCRIPTION:	Get a low bit long word, and convert it into a highbit

pcleek:
	move.l	(a7)+,return		; Save return
	cmp	#1,d0			; 1 param?
	bne	syntax
	bsr	getint			; Address
	move.l	d3,a0			
	clr.l	.wrk
	move.l	#.wrk,a1		; Work address
	move.b	3(a0),(a1)
	move.b	2(a0),1(a1)
	move.b	1(a0),2(a1)
	move.b	(a0),3(a1)
	move.l	.wrk,d3		
	move.w	#0,d2			; Tell STOS to expect a number
	move.l	return,a0		; Load return
	jmp	(a0)

.wrk	dc.l	0



**     COMMAND:	CLINE$
**  	SYNTAX:	x$=CLINE$
**
** DESCRIPTION:	Get the command line parameters passed

cline:
	move.l	(a7)+,return		; Save return
	bsr	ASK			; Ask for some string space
	move.w	#0,(a0)			; Set default length to 0
	move.l	a0,a2
		
	move.l	$380,a1
	move.b	(a1)+,d0		; Length
	tst	d0			; 0?
	beq	.out
	
	ext.w	d0			; d0 as a word
	move.w	#0,(a0)+		; Store length of string
	sub.w	#1,d0
	
.getst:	move.b	(a1)+,(a0)+		; Copy bytes
	dbra	d0,.getst		; Loop for complete string		

.out:	move.l	a2,d3			; Address of string
	move.w	#$80,d2			; Expect a string	
	move.l	return,a0		; Load return
	jmp	(a0)

**** STOS SUPPORT ROUTINES ****

** Convert a STOS string to a GEM/TOS string.. adds null pointer
** to the end of the string

conv2tos: 
	movem.l	a1-a2,-(a7)		; Save registers
	move.l	d3,a1
	move.w	(a1)+,d2		; Get length of string
	move.w	d2,d1			; Save in d1
	move.l	d3,a2
strl1:	move.b	(a1)+,(a2)+		; Create space for chr$(0)
	dbra	d2,strl1		; Loop through string
	move.w	#0,(a2)+		; Copy 0 to end
	movem.l	(a7)+,a1-a2		; Restore registers
	rts


** Get a string argument

getstring:

	move.l	(a7)+,a0		; Save return
	movem.l	(a7)+,d2-d4		; Get parameter
	tst.b	d2			; Is the argument a string?
	bpl	illegal			; No!
	jmp	(a0)			; Return from routine


** Get an integer argument
	
getint:

	move.l	(a7)+,a0		; Save return
	movem.l	(a7)+,d2-d4		; Get parameter
	tst.b	d2			; Is it an integer?
	bne	typemis			; No, type mismatch
	jmp	(a0)			; Return


* Errors

notdone:

	moveq	#0,d0			; Error 0 (Not done)
	bra.s	error

syntax:

	moveq	#12,d0			; Error 12 (Syntax error)
	bra.s	error

typemis:

	moveq	#19,d0			; Error 19 (Type Mismatch)
	bra.s	error

illegal:

	moveq	#13,d0			; Error 13 (Illegal function call)
	
error:

	move.l	system(pc),a0
	move.l	$14(a0),a0
	jmp	(a0)

exit	equ	*

