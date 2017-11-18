;========================================================
;
;        Driver name :  deadkey.prg
;            version :  1.0
;               Date :  31 mar 1987
;                Use :  Dead keys (accents) from any keyboard
;
;========================================================
;
;
; macro definitions :
;
; to check if the character is an accent ...
;

	.macro	accent	lbl,sym
	cmp.w    #\sym,d0
	beq      \lbl
	.endm

;
; to convert the character ...
;
	.macro	conv	old,new
	cmp.w	#\old,d0
	bne	.\~
	move.w	#\new,d0
	bra	exitkbd
.\~:
	.endm

;
; to do some TRAP 13 when already there ...
;
	.macro	psdotrap
	lea.l	.\~(pc),a1
	move.l	memtrap(pc),a0
	move.l	a1,-(a7)		; push return address and ccr
	move	sr,-(a7)		; ...to return properly
	jmp	(a0)
.\~:
	.endm

svpt	equ	$4a2
conterm	equ	$484

cr	equ	$0d
lf	equ	$0a
space	equ	$20

ON	equ	1	;switch flag state deadkey is on
OFF	equ	0	;switch flag state deadkey is off

install:

; check if this driver has already been installed

	move.l	#$ffffffff,-(a7)	; request value of
	move.w	#45,-(a7)		; trap_13's vector
	move.w	#5,-(a7)		; by the Setexec function
	trap	#13			; trap to XBIOS
	add.l	#8,a7

	move.l	d0,a0			;address of existing trap
	add.l	#title_msg-trap13,a0	;offset to message (maybe)
	lea.l	title_msg(pc),a1	;address of title message

check:
	cmp.b	(a0)+,(a1)+	;compare title strings
	bne.s	ok_to_install	;mis-match character
	tst.b	(a1)		;check for end
	bne.s	check		;no...continue check

	move.w	#0,-(a7)	;return fail code
	move.w	#$4c,-(a7)	;Pterm
	trap	#1		;trap to GEMDOS
	illegal			;should never execute this

ok_to_install:
	lea.l	trap13(pc),a1	; address of new handler
	move.l	a1,-(a7)	; set value of
	move.w	#45,-(a7)	; trap_13's vector
	move.w	#5,-(a7)	; by the Setexec function
	trap	#13		; trap to XBIOS
	add.l	#8,a7

	lea.l	memtrap(pc),a1	; save original
	move.l	d0,0(a1)	; vector value

	pea	title_msg(pc)	;display install message
	move.w	#9,-(a7)	;Cconws function
	trap	#1		;trap to GEMDOS
	addq.l	#6,a7

	move.w	#0,-(a7)	; terminate and stay resident
				; calculate memory to keep
	move.l	#etrap13-install+$400,-(A7)
	move.w	#$31,-(a7)	;Ptermres
	trap	#1		;trap to GEMDOS
	illegal			;should never execute this
;
;--------------------------------------------------------
; Replacement Trap 13 exception handler

trap13:
	bra.s	check_on

title_msg:
	dc.b	cr,lf,'ATARI DEADKEY FUNCTION',cr,lf
	dc.b	'Version 1.0 installed',cr,lf,0
	.even

check_on:
	cmp.l	#$87654321,d0	; turn deadkey on ?
	bne.s	check_off	; no ...

	move.b	#ON,switch
	rte

check_off:
	cmp.l	#$12345678,d0	;turn deadkey off ?
	bne.s	around		;no ...

	move.b	#OFF,switch
	rte

around:
	move.l	svpt,a1		; save biz ...
	move.w	(a7)+,d0
	move.w	d0,-(a1)
	move.l	(a7)+,-(a1)
	move.l	a7,-(a1)
	move.l	a1,svpt

	btst	#$0d,d0		; ssp/usp switch
	bne	chkdev
	move	usp,a7
         
chkdev:	
	cmp.b	#ON,switch	; is deadkey enabled ?
	bne.s	no_dead		; no ...

	cmp.l	#$20002,0(a7)	; is it Bconin(CON) ?
	bne.s	no_dead		; no ...

	or.b	#8,conterm	; for kbdstat in msb(msw) of D0
	psdotrap
	move.l	#$20002,0(a7)	; refresh function's params

	accent	aigu,$27	;look for dead keys
	accent	grave,$60
	accent	circ,$5e
	accent	trema,$22
	accent	tilde,$7e
	accent	underbar,$5f
	accent	slash,$2f
	accent	degrees,$f8
	bra.s	exitkbd

no_dead:
	psdotrap		; else trap asap ...

exitkbd:
	move.l	svpt,a1		; and exit
	move.l	(a1)+,a7
	move.l	(a1)+,-(a7)
	move.w	(a1)+,-(a7)
	move.l	a1,svpt
	rte

;dead key processing

aigu:
	psdotrap
	conv	"a",$a0
	conv	"e",$82
	conv	"E",$90
	conv	"i",$a1
	conv	"o",$a2
	conv	"u",$a3
	conv	space,$27
	bra	exitkbd

grave:
	psdotrap
	conv	"a",$85
	conv	"A",$b6
	conv	"e",$8a
	conv	"i",$8d
	conv	"o",$95
	conv	"u",$97
	conv	space,$60
	bra	exitkbd

circ:
	psdotrap
	conv	"a",$83
	conv	"e",$88
	conv	"i",$8c
	conv	"o",$93
	conv	"u",$96
	conv	space,$5e
	bra	exitkbd

trema:
	psdotrap
	conv	"a",$84
	conv	"e",$89
	conv	"i",$8b
	conv	"o",$94
	conv	"u",$81
	conv	"y",$98
	conv	space,$22
	conv	"A",$8e
	conv	"O",$99
	conv	"U",$9a
	bra	exitkbd

tilde:
	psdotrap
	conv	"n",$a4
	conv	"N",$a5
	conv	"a",$b0
	conv	"A",$b7
	conv	"o",$b1
	conv	"O",$b8
	conv	space,$7e
	bra	exitkbd

underbar:
	psdotrap
	conv	space,$5f
	conv	"a",$a6
	conv	"o",$a7
	bra	exitkbd

degrees:
	psdotrap
	conv	space,$f8
	conv	"a",$86
	conv	"A",$8f
	bra	exitkbd

slash:
	psdotrap
	conv	space,$2f
	conv	"o",$b3
	conv	"O",$b2
	bra	exitkbd

memtrap:	.dc.b	"1234"

switch:		.dc.b	ON

		.even
etrap13:

	  
