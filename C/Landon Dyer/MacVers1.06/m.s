	.title	"Quick Front End"
	.include atari			; get all our favorite equates

amac_info =	$3f8			; location of magic+pointer
AMAC_MAGIC =	$abacada		; magic number


;+
;  MADMAC Front End
;
;  This hack
;	1.  Finds MADMAC if it has been installed in memory
;	    with its `-q' option;
;	2.  Fills in its basepage with some information about
;	    the TPA limits and the commandline;
;	3.  Passes control to MADMAC.
;
;  We use locations $3f8 through $3ff to hold a magic number
;  and a pointer to MADMAC's basepage.  Presumably these two
;  longwords won't get clobbered somehow.
;
;-
	Super				; get into supervisor mode
	movem.l	amac_info,d3/a3		; get magic number and basepage pointer
	User				; back to user mode

	cmp.l	#AMAC_MAGIC,d3		; does the magic# match?
	bne.s	oops			; no -- so complain
	cmp.l	#AMAC_MAGIC,(a3)	; is there more magic where LOWTPA was?
	bne.s	oops			; no -- so complain
	move.l	8(a3),-(sp)		; jump to assembler's entry point
	rts


;+
;  MADMAC is not installed;
;  complain and terminate.
;
;-
oops:	Puts	#errmsg
	Pterm	#1

errmsg:	dc.b	'MADMAC not installed;\r\n'
	dc.b	'use "MADMAC -Q" to install it\r\n',0
	even
