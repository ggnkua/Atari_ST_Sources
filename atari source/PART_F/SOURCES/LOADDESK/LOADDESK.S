* loaddesk.s - launch c:\ttdesk.sys via the exec_os vector
* 900804 kbad
* assemble with MadMac

* Base page structure

.ABS 0

TpaStart:	.DS.L	1
TpaEnd:		.DS.L	1
TextSegStart:	.DS.L	1
TextSegSize:	.DS.L	1
DataSegStart:	.DS.L	1
DataSegSize:	.DS.L	1
BssSegStart:	.DS.L	1
BssSegSize:	.DS.L	1
DtaPtr:		.DS.L	1
PntPrcPtr:	.DS.L	1
Reserved0:	.DS.L	1
EnvStrPtr:	.DS.L	1
Reserved1:	.DS.B	7
CurDrv:		.DS.B	1
Reserved2:	.DS.L	18
CmdLine:	.DS.B	128
BasePageSize:	.DS	0

.TEXT
*-- First, shrink loader down to size
	move.l  4(sp),a3		; Get bp pointer off the stack
	move.l	TextSegSize(a3),a0	; Text size +
	add.l	DataSegSize(a3),a0	; Data size +
	add.l	BssSegSize(a3),a0	; BSS size (includes stack) +
	add.l	#BasePageSize,a0	; Basepage size = memory to keep
	move.l	a3,d0			; Our basepage address +
	add.l	a0,d0			; our memory used
	and.b	#$fc,d0			; longword-aligned
	move.l	d0,sp			; is our new stack pointer
	move.l	a0,-(sp)		; amount to keep
	move.l	a3,-(sp)		; block start
	clr.w	-(sp)			; dummy word
	move.w	#$4a,-(sp)		; Mshrink
	trap	#1
	lea	12(sp),sp

*-- Next, set GEMDOS current process to the beginning of the universe
	pea	getroot(pc)		; Supexec(getroot)
	move.w	#38,-(sp)
	trap	#14
	addq	#6,sp
	move.l	root,a0
	move.l	a3,d0			; start with our basepage
nextbp:
	move.l	d0,a1			; save last basepage
	move.l	PntPrcPtr(a1),d0	; get parent basepage
	bne.b	nextbp			; until it's zero
	move.l	a1,(a0)			; trick GEMDOS

*-- Pexec 3 c:\ttdesk.sys
	clr.l	-(sp)			; environment
	pea	nullcmd(pc)		; cmdline
	pea	prgname(pc)		; prgname
	move.w	#3,-(sp)		; mode 3
	move.w	#$4b,-(sp)		; Pexec
	trap	#1
	lea	14(sp),sp
	move.l	root,a0			; restore GEMDOS current process
	move.l	a3,(a0)			; to loader's basepage

*-- on error, terminate silently
	move.l	d0,deskbp		; save ttdesk.sys basepage
	blt.b	exit

*-- Mshrink for ttdesk.sys
	move.l	d0,a4
	move.l	TextSegSize(a4),a5	; Text size +
	add.l	DataSegSize(a4),a5	; Data size +
	add.l	BssSegSize(a4),a5	; BSS size +
	add.l	#(2*BasePageSize),a5	; Basepage + initial stack
	move.l	a5,-(sp)		; = amount to keep
	move.l	a4,-(sp)		; block start
	clr.w	-(sp)			; dummy word
	move.w	#$4a,-(sp)		; Mshrink
	trap	#1
	lea	12(sp),sp
	move.l	a4,a0			; set hitpa for ttdesk.sys
	add.l	a5,a0
	move.l	a0,TpaEnd(a4)

*-- set exec_os pointer to text segment of ttdesk.sys
	pea	execos(pc)		; Supexec(execos)
	move.w	#38,-(sp)
	trap	#14
	addq	#6,sp

*-- stuff load address into message string
	move.l	deskbp,d0
	lea	endnum(pc),a0
	moveq	#7,d2			; 8 digits
nxdig:	moveq	#$f,d1			; nybble mask
	and.b	d0,d1
	cmp	#$A,d1			; if < $A, add 'A'
	blt.b	isnum			; else add '0'
	add.b	#('A'-10),d1
	bra.b	digit
isnum:	add.b	#'0',d1
digit:	move.b	d1,-(a0)		; stuff it in the string
	lsr.l	#4,d0			; get next nybble
	dbra	d2,nxdig		; until we're done

	pea	msg(pc)			; Cconws(msg)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

*-- go away
exit:
	clr	(sp)			; Pterm0
	trap	#1

*-- set exec_os pointer to text segment of ttdesk.sys
execos:
	move.l	deskbp,a0
	move.l	TextSegStart(a0),$4fe.w
	rts

*-- get _root from os header
getroot:
	move.l	$4f2.w,a0		; -> os header
	move.l	$28(a0),root		; -> _root
	rts

prgname:	.dc.b	"c:\\ttdesk.sys"
nullcmd:	.dc.b	0,0
msg:		.dc.b	$1b,"p TTDESK.SYS loaded at $00000000"
endnum:		.dc.b	" \r\n"
		.dc.b	$1b,"q  Copyright ",$bd," 1990, Atari Corp. \r\n",0

.BSS

root:		.ds.l	1
deskbp:		.ds.l	1
stack:		.ds.b	512

*the
.END
