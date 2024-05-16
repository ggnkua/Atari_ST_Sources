; convert a .prg file into a fixed address binary
; so that it can be patched.

start_address	equ	$70000

start	move.l	4(a7),a0
	move.l	a0,a6
	move.l	$c(a0),d0
	add.l	$14(a0),d0
	add.l	$1c(a0),d0
	add.l	#$500,d0
	
	clr.w	-(sp)
	pea	in_name
	move.w	#$3d,-(sp)	; open
	trap	#1
	addq.l	#8,sp
	
	move.w	d0,d7
	
	pea	data_table
	move.l	#$1d174,-(sp)	; near enough
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	
; relocate program to run at fixed address

relocate	lea	data_table,a0
	lea	28(a0),a6
	
	add.l	$2(a0),a6
	move.l	$2(a0),d0	; save for later

	add.l	$6(a0),a6
	add.l	$6(a0),d0
	
	add.l	$a(a0),d0
	move.l	d0,text_length
	
	add.l	$e(a0),a6
	
	lea	28(a0),a0	; pointer to text
	
	add.l	(a6)+,a0	; initial offset

	move.l	#start_address,d7; add base
	add.l	d7,(a0)
	
.1	tst.b	(a6)
	beq	.end	; no more
	
	cmpi.b	#1,(a6)	; greater then 254?
	bne	.2	; nooop!
	
	clr.l	d0

.4	addi.l	#254,d0
	
	tst.b	(a6)+
	cmpi.b	#1,(a6)
	beq	.4

	clr.l	d1
	move.b	(a6)+,d1
	add.l	d1,d0
	add.l	d0,a0
	add.l	d7,(a0)
	tst.b	d1
	beq	.end
	bra	.1
		
.2	clr.l	d0

	move.b	(a6)+,d0
	add.l	d0,a0
	
	add.l	d7,(a0)
	bra	.1
	
.end	clr.w	-(sp)
	pea	out_name
	move.w	#$3c,-(sp)	; creat
	trap	#1
	addq.l	#8,sp
	move.w	d0,d7
	
	pea	data_table+28
	move.l	text_length,-(sp)	; near enough
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	
	clr.w	-(sp)
	trap	#1
	
; data and storage

text_length	ds.l	1
	
in_name	dc.b	'power.dat',0
out_name	dc.b	'power.bin',0

null	dc.b	0

	even
	
data_table	end
	