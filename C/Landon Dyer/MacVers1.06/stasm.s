	.title	'MADMAC Atari ST Assembly Support'
	.include atari

	.globl	__bp
	.globl	_version


amac_info =	$3f8			; location of magic+pointer
AMAC_MAGIC =	$abacada		; magic number


;----------------
;
;  Make AMAC resident, like a RAMdisk.
;
_termres::
	Supexec #install		; install magic cookie
	Puts	#insmsg1		; say we're installing...
	Puts	#_version
	Puts	#insmsg2
	move.l	__bp,a0			; a0 -> basepage
	move.l	#$100,d0		; compute bp+text+data+bss size
	add.l	$c(a0),d0
	add.l	$14(a0),d0
	add.l	$1c(a0),d0
	clr.w	-(sp)			; = terminate code
	move.l	d0,-(sp)		; = amount to keep
	move.w	#$31,-(sp)		; Ptermres()
	trap	#1			; "cannot return"

;---
;  Terminate-and-stay-resident failed.
;  Complain.  Loudly.
;
	Supexec #deinstall		; de-install magic cookie (oops!)
	Puts	#badmsg
	Pterm	#1

insmsg1:	dc.b	'MADMAC version ',0
insmsg2:	dc.b	' installed.',13,10,0
badmsg:		dc.b	'Terminate error: cannot install.',13,10,0
	even


;---
;  Install information for A.PRG to read later
;
install:
	move.l	#AMAC_MAGIC,d0		; d0 = magic cookie
	move.l	__bp,a0			; a0 -> basepage
	move.l	d0,amac_info		; install magic cookie in low memory
	move.l	a0,amac_info+4		; install ptr to basepage
	move.l	d0,(a0)			; clobber LOWTPA with magic cookie
	rts


;---
;  Clobber stuff that `install' tried to install.
;
deinstall:
	clr.l	amac_info		; clobber magic leftovers
	rts


	.subttl	'getenv()'
;----------------
;
;  Return enviroment variable '.name'
;
ENV	=	$2c

	.extern __bp

_getenv:: .cargs .name

	moveq	#0,d0			; assume not found (NULL)
	move.l	.name(sp),a2		; a2 -> target string
	move.l	__bp,a1			; a1 -> env string
	move.l	ENV(a1),a1

.loop:	tst.b	(a1)
	beq.s	.ret
	moveq	#0,d1			; d1 = char index
.1:	move.b	(a1,d1.w),d2		; get next char from env string
	addq.w	#1,d1
	cmp.b	#'=',d2			; if (char is '=')
	beq.s	.2			;	then check for EOS on .name
	cmp.b	-1(a2,d1.w),d2		; chars match?
	beq.s	.1			; (yes --- continue)

.3:	tst.b	(a1)+			; while (*a1++ != EOS)
	bne	.3			;	;
	bra	.loop			; try next env variable

.2:	tst.b	-1(a2,d1.w)		; matched entire name?
	bne.s	.3			; (no --- give up on string)
	lea	(a1,d1.w),a1		; d0 = start of value part
	move.l	a1,d0

.ret:	rts


    .if 0
;+
;  Get 200 hz timer value
;
;-
_get_tick::
	Supexec #.1
	move.l	.temp,d0
	rts

.1:	move.l	$4ba,.temp
	rts

    bss
.temp:	ds.l	1			; temp for 200hz counter

    text
    .endif
