; ACTIONS.S: top-level action and error words	16/04/90
; No user-available words.
; Copyright <C> John Redmond 1989, 1990
; Public domain for non-commercial use.
;
;*******************************************************;
;							;
; The main entry point for outer interpreter action	;
;							;
;*******************************************************;
;
	section	text
	even
;
action: bsr	stateat		;execute or compile?
	beq.s	.ex		;execute state
	move.l	(a6)+,d0	;flag for word type
	bpl.s	_atexec		;immediate word
	pop	a3		;cfa
	move.l	(a3),a0
	adda.l	a5,a0		;code address
	move.l	-(a3),d2	;length & macro flag
	bra	call
;execute:
.ex:	addq.l	#4,a6		;drop word type flag
_atexec: pop	a0
	move.l	(a0),a1		;get offset in cfa
	adda.l	a5,a1		;convert to an address
ex1:	jsr	(a1)
	bsr	chkstk
	rts
;
;user entry point:
;
_execute: pop	a1
	bra.s	ex1
;
;*******************************************************;
;							;
; The error routines					;
;							;
;*******************************************************;
;
chkstk: lea	dstack,a0
	move.l	(a0),a1
	cmpa.l	a6,a1
	bcs	.chkerr
	rts
.chkerr: lea	serror,a0
	bra	_error
;
_error:	push	a0		;message address
	lea	pocket,a0
	move.l	(a0),-(a6)
	bsr	_string
	bsr	_space
	bsr	_message	;print message passed on stack
	bsr	cfiles		;close all open files
	bsr	stateat
	bne	.e5
	lea	locsused,a0
	tst.w	(a0)
	bne	.e5
	bra	_abort
.e5:	lea	headmark,a0
	move.l	(a0),d0	 
	add.l	a5,d0		;start of colon header
	push	d0
	push	#1
	bsr	_traverse
	add.l	#5,(a6)
	bsr	discard
	bsr	_bra
	bra	_abort
;
cfiles: lea	src,a0		;close all files
	move.l	(a0),d0		;current source
	beq	.cfx
	push	d0
	bsr	popin
	bra	cfiles
.cfx:	rts
;
namerror: lea	nerror,a0
	bra	_error
;
lenerror: lea	lenerr,a0
	bra	_error
;
strerror: lea	strerr,a0
	bra	_error
;
regerror: lea	regerr,a0
	bra	_error
;
deferror: lea	deferr,a0
	bra	_error
;
apperror: lea	apperr,a0
	bra	_error
;
apperr: dc.b	18,'is too low to call'
clerror: dc.b	16,'file close error'
deferr:	dc.b	26,'is incorrect in definition'
exerr:	dc.b	26,'used in a colon definition'
fgerror: dc.b	12,'is protected'
inserr:	dc.b	26,'overflowed the input stack'
lenerr:	dc.b	22,'is too long for a name'
locerr: dc.b	30,'gives a local definition error'
nerror: dc.b	12,'needs a name'
operror: dc.b	15,'file open error'
prterr: dc.b	25,'printer is not responding'
regerr:	dc.b	12,'is a pointer'
serror: dc.b	19,'gives a stack error'
strerr: dc.b	23,'gives a structure error'
stterr: dc.b	19,'is a compiling word'
werror: dc.b	10,'is unknown'
wrerror: dc.b	16,'file write error'
xserror: dc.b	19,'too many files open'
;
	even
