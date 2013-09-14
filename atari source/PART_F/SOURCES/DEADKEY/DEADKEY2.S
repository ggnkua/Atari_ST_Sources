;========================================================
;
;        Driver name :  deadkey.prg
;            version :  1.0
;               Date :  31 mar 1987
;                Use :  Dead keys (accents) from any keyboard
;
; version 2.0 for TT 900723 kbad
;
;========================================================
;
;
; macro definitions :
;
; to check if the character is an accent ...
;

	.macro	accent	lbl,sym
	cmp.w	#\sym,d0
	beq	\lbl
	.endm

;
; to convert the character ...
;
	.macro	conv	old,new
	cmp.w	#\old,d0
	bne	.x\~
	move.w	#\new,d0
	bra	exitkbd
.x\~:
	.endm

;
; return to .x\~ from a trap
;
	.macro	retrap
	move.l	#CONINCON,-(sp)
	tst	longframe		; using long stack frames?
	beq.s	.f\~
	clr	-(sp)			; fake a format word
.f\~:	pea	.x\~(pc)		; push our return address
	move	sr,-(sp)		; and status word
	bra	oldtrap			; go through old trap handler
.x\~:
	addq	#4,sp			; clean up the stack
	.endm

CONINCON	equ	$20002
vtrap13		equ	$b4
longframe	equ	$59e
svpt		equ	$4a2
conterm		equ	$484
_hz_200		equ	$4ba

cr	equ	$0d
lf	equ	$0a
space	equ	$20
esc	equ	$1b

ON	equ	1	;switch flag state deadkey is on
OFF	equ	0	;switch flag state deadkey is off

install:

; check if this driver has already been installed

	moveq	#$ff,d0
	move.l	d0,-(sp)	; request value of
	move.w	#45,-(sp)	; trap_13's vector
	move.w	#5,-(sp)	; by the Setexec function
	trap	#13		; trap to XBIOS
	addq	#8,sp
	move.l	d0,a0		; address of existing trap

checkit:
	cmp.l	#'XBRA',-12(a0)	; look for XBRA code
	bne.s	ok_to_install	; not there, go for it
	cmp.l	#'DKEY',-8(a0)	; see if we're in the chain
	bne.s	nextrap		; not us, check the next guy
	pea	deadkeys(pc)	; print dead keys
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	pea	delay(pc)	; Supexec it
	move.w	#38,-(sp)
	trap	#14
	addq	#6,sp
	clr	(sp)		; we're there, so Pterm0
	trap	#1
	illegal
nextrap:
	move.l	-4(a0),a0	; get next trap handler
	bra.s	checkit

ok_to_install:
	lea.l	mybp(pc),a1	; save basepage
	move.l	4(sp),(a1)

	pea	doinstall(pc)	; Supexec it
	move.w	#38,-(sp)
	trap	#14
	addq	#6,sp

	pea	title(pc)	;display install message
	move.w	#9,-(sp)	;Cconws function
	trap	#1		;trap to GEMDOS
	addq	#6,sp

	pea	delay(pc)	; Supexec it
	move.w	#38,-(sp)
	trap	#14
	addq	#6,sp


	clr	-(sp)		; terminate and stay resident
				; calculate memory to keep
	move.l	#title-install+$400,-(sp)
	move.w	#$31,-(sp)	;Ptermres
	trap	#1		;trap to GEMDOS
	illegal			;should never execute this
;
;--------------------------------------------------------
; Replacement Trap 13 exception handler

mybp:	.dc.b	'BPBP'
prgid:	.dc.b	'XBRADKEY'

memtrap:
	.dc.b	'TRAP'
trap13:
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
	cmp.b	#ON,switch	; is deadkey enabled ?
	bne	oldtrap		; no,jump thru old trap handler

	move	(sp),d0		; get status word
	btst	#$0d,d0		; trap from super mode?
	bne.s	suptrap		; yup, get super stack
	move.l	usp,a0		; args on user stack
	bra.s	chkdev
suptrap:
	tst	longframe	; are we using long stack frames?
	beq.s	.fsup
	lea	8(sp),a0	; args on super stack, after frame word
	bra.s	chkdev
.fsup:	lea	6(sp),a0	; args on super stack, after return PC
chkdev:
	cmp.l	#CONINCON,(a0)	; is it Bconin(CON) ?
	bne.s	oldtrap		; no, jump thru old trap handler

	or.b	#8,conterm	; for kbdstat in msb(msw) of D0
	retrap			; come back on return from conin

	accent	aigu,'\''	; look for dead keys
	accent	grave,'`'
	accent	circ,'^'
	accent	trema,$22
	accent	tilde,'~'
	accent	underbar,'_'
	accent	slash,'/'
	accent	degrees,'@'
exitkbd:
	rte

oldtrap:
	move.l	memtrap(pc),a0	; jump thru old trap handler
	jmp	(a0)

;dead key processing

aigu:
	retrap
	conv	"a",$a0
	conv	"e",$82
	conv	"E",$90
	conv	"i",$a1
	conv	"o",$a2
	conv	"u",$a3
	conv	space,$27
	bra	exitkbd

grave:
	retrap
	conv	"a",$85
	conv	"A",$b6
	conv	"e",$8a
	conv	"i",$8d
	conv	"o",$95
	conv	"u",$97
	conv	space,$60
	bra	exitkbd

circ:
	retrap
	conv	"a",$83
	conv	"e",$88
	conv	"i",$8c
	conv	"o",$93
	conv	"u",$96
	conv	space,$5e
	bra	exitkbd

trema:
	retrap
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
	retrap
	conv	"n",$a4
	conv	"N",$a5
	conv	"a",$b0
	conv	"A",$b7
	conv	"o",$b1
	conv	"O",$b8
	conv	space,$7e
	bra	exitkbd

underbar:
	retrap
	conv	space,$5f
	conv	"a",$a6
	conv	"o",$sp
	bra	exitkbd

degrees:
	retrap
	conv	space,$f8
	conv	"a",$86
	conv	"A",$8f
	bra	exitkbd

slash:
	retrap
	conv	space,$2f
	conv	"o",$b3
	conv	"O",$b2
	conv	"S",$9e
	bra	exitkbd

switch:		.dc.b	ON

title:
	dc.b	esc,'p    Deadkey V2.0 installed    \r\n',esc,'q'
	dc.b	' Copyright ',$bd,' 1990, Atari Corp.\r\n'
deadkeys:
	dc.b	esc,'p  Deadkeys: [\'] [`] [^] [\"]   \r\n',esc,'q'
	dc.b	     '                 …   ƒ   „    \r\n'
        dc.b    esc,'p            [~] [_] [/] [@]   \r\n',esc,'q'
	dc.b	     '             ¤   ¦   ³   †    \r\n',0
.even

doinstall:
	move	sr,-(sp)
	or	#$700,sr	; no interrupts, please
	move.l	$b4,memtrap
	move.l	#trap13,$b4
	move	(sp)+,sr
	rts

delay:				; wait 1 second for the message to sink in
	move.l	_hz_200.w,d0
	add.l	#200,d0
wait:	cmp.l	_hz_200.w,d0
	bge.b	wait
	rts
.end

