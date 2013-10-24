*** make standard cookie jar
***

_p_cookies	equ	$5a0

dos		equ	1
xbios		equ	14

pterm0		equ	0
Cconws		equ	9
Ptermres	equ	$31

Supexec		equ	38

stat		bra	go

standard_jar
	dc.l	'_CPU',0
	dc.l	'_VDO',0
	dc.l	'_SND',0
	dc.l	'_MCH',0
	dc.l	0,8
	dc.l	0,0
	dc.l	0,0
	dc.l	0,0

go	move.l	a7,a5
	move.l	#stack,sp
	move.l	4(a5),basepage
	pea	inst_jar
	move.w	#Supexec,-(sp)
	trap	#xbios
	addq.l	#6,sp

	tst.w	success
	beq	TSR

	move.w	#pterm0,-(sp)
	trap	#dos

TSR	move.l	basepage,d0
	move.l	#go,d1
	sub.l	d0,d1
	move.l	d1,-(sp)
	move.w	#Ptermres,-(sp)
	trap	#dos

inst_jar
	move.l	_p_cookies,d0
	bne	already_jar
	move.l	#standard_jar,_p_cookies
	clr.w	success
	rts

already_jar
	lea	already_jarm,a1
	bsr	print_stg
	move.l	#1,success
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

print_stg
	move.l	a1,-(sp)
	move.w	#Cconws,-(sp)
	trap	#dos
	addq.l	#6,sp
	rts

	cnop	0,4

basepage
	ds.l	1
success	ds.w	1

already_jarm
	dc.b	'Cookie jar already installed.',13,10,0

	ds.l	99
stack	ds.l	1

