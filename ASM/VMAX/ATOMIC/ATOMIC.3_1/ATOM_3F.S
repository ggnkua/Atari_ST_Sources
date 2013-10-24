;
; Atomic v3.1 Trap #1 Loader v2.0 by IWWWTTI - 30/9/1991
;
; Updated coz Ruthless couldn't get it working
;
; Portions borrowed from Automations' '3FONLY.S' !!!
;
; Set TABS to 10 for readable source

		opt c+

lowres	equ	0	; low resolution 
text	equ	1	; text printed
wait	equ	1	; wait for key
flash	equ	1	; colour flashes whilst depacking
res84	equ	0	; restore $84 on exit of packed program

main	MOVEA.L	4(A7),A5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #$100,d0
	move.l d0,-(sp)
	move.l a5,-(sp)
	move.l #$4a0000,-(sp)
	trap #1
	lea $c(a7),a7

	bsr.s	super
	move.l	$84.w,tr1
	move.l	#T1,$84.w
	bsr.s	user

	ifne	lowres
	clr.w 	-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	$c(a7),a7
	endc
	
print	ifne text
	pea message(pc)
	move.w #9,-(sp)
	trap #1
	addq.l #6,-(sp)
	endc

waitkey	ifne wait
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endc

stkk	clr.l $60000

exec	pea $60000
	move.l (a7),-(sp)
	move.l #prog,-(sp)
	move.l #$4b0000,-(sp)
	trap #1
	lea $10(a7),a7

exit	ifne	res84
	bsr.s	super		; clear Trap #1 Loader
	move.l	tr1(pc),$84.w	; replace with old ROM address
	bsr.s	user
	endc

	clr.w -(sp)
	trap #1

old_sp	dc.l	0

super	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_sp
	rts

user	move.l	old_sp(pc),-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

T1	movem.l	a0-a6/d0-d7,reg
	movea.l	a7,a1
	addq.l 	#6,a1
	move.w 	(a7),d0
	btst 	#$d,d0
	bne.s 	ok1
	move.l 	usp,a1
ok1	cmpi.w 	#$3f,(a1)
	beq.s 	read
open	movem.l reg(pc),a0-a6/d0-d7
bye	dc.w 	$4ef9
tr1	dc.l 	$0
read	move.l 	$8(a1),loadadd
	move.l $2(a7),ex3f
	move.l #cls,$2(a7)
	bra.s open
loadadd	dc.l 0
siz2	dc.l 0

cls	movem.l d0-d7/a0-a6,-(sp)
	move.l d0,siz2
	pea close(pc)
	move.w #$26,-(sp)
	trap #14
	addq.l #6,sp
	movem.l (a7)+,d0-d7/a0-a6
	move.l siz2(pc),d0
	dc.w $4ef9
ex3f	dc.l 0

close	move.l loadadd(pc),a0
	bsr depack
	rts

reg	dc.l $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0

message	dc.b 27,69
	dc.b 'MAZE from ST User',13,10
	DC.B 'PACKED BY IWWWTTI !!!',0
	EVEN

prog	dc.b 'maze.exe',0
	even


;decrunch source code of ATOMIK by ALTAIR	;je tiens a preciser
;A0=packed code		;que j'ai entierement
;call it by bsr		;ecris ce compacteur
			;environnement compris.
DEC_MARGE:	equ	$10	;min=0 , max=126 (pair!)
RESTORE_M:	equ	1	;argh j'ai plant‚ pendant
			;10 jours sur TOTAL RECALL
			;a cause de ca!!!!!
PIC_ALGO:	equ	1	;PIC_ALGO=1,RESTORE_M=0 ; lenght=$18e
				;PIC_ALGO=0,RESTORE_M=0	; length=$146
				;RESTORE_M=1 ; length=length+DEC_MARGE+$32
depack:	movem.l	d0-a6,-(a7)
	cmp.l	#"ATOM",(a0)+
	bne	no_crunched
	move.l	(a0)+,d0
	move.l	d0,-(a7)
	lea	DEC_MARGE(a0,d0.l),a5
	ifne	RESTORE_M
	move.l	a5,a4
	lea	buff_marg(pc),a3
	moveq	#DEC_MARGE+9,d0
.save_m:	move.b	-(a4),(a3)+
	dbf	d0,.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.l	(a0)+,d0	
	lea	0(a0,d0.l),a6
	bsr	get_word
	bra	make_jnk
decrunch:	moveq	#6,d6
take_lenght:	add	d7,d7
	beq.s	.empty1
.cont_copy:	dbcc	d6,take_lenght
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.empty1:	bsr.s	get_word
	addx	d7,d7
	bra.s	.cont_copy
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15+6,d5
.do_copy:	move	d5,-(a7)
	bne.s	bigger
	lea	decrun_table2(pc),a4
	bra.s	cont
get_bit2:	clr	d5
.get_bits:	add	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	bsr.s	get_word
	addx	d7,d7
	bra.s	.cont
bigger:	lea	decrun_table(pc),a4
cont:	moveq	#2,d6
	bsr.s	get_bit2
	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move	(a7)+,d5
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)

	ifne	flash
	eori.w	#$777,$ffff8240
	endc

	dbf	d5,.copy_same
make_jnk:	moveq	#11,d6
	moveq	#11,d5
take_jnk:	add	d7,d7
	beq.s	empty
cont_jnk:	dbcc	d6,take_jnk
	bcs.s	next_cod
	sub	d6,d5
	bra.s	copy_jnk1
get_word:	move.b	-(a6),-(a7)
	move	(a7)+,d7
	move.b	-(a6),d7
	rts
next_cod:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#8,d5
	addq	#3,d5
	bra.s	copy_jnk1
.next_cod1:	moveq	#2,d6
	bsr.s	get_bit2
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2
	addq.l	#8,d5
	addq.l	#3,d5	
copy_jnk1:	subq	#1,d5
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk:	move.b	-(a6),-(a5)
	dbf	d5,.copy_jnk
	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word:	cmp.l	a6,a0
.decrunch:	bne	decrunch
	cmp	#$8000,d7
	bne.s	.decrunch
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	bsr	decod_picture
	endc
	ifne	RESTORE_M
	movem.l	(a7)+,a3-a4
	endc
	move.l	(a7)+,d0
	bsr	copy_decrun
	ifne	RESTORE_M
	moveq	#DEC_MARGE+9,d0
.restore_m:	move.b	-(a3),(a4)+

	ifne	flash
	eori.w	#$700,$ffff8240
	endc

	dbf	d0,.restore_m
	endc
no_crunched:	movem.l	(a7)+,d0-a6
 	rts
empty:	bsr.s	get_word
	addx	d7,d7
	bra.s	cont_jnk
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2:	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8,8,8	
	ifne	PIC_ALGO
decod_picture:	move	-(a0),d7
	clr	(a0)
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	clr.l	(a0)
	lea	0(a5,d0.l),a1
	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	ifne	RESTORE_M
buff_marg:	dcb.b	DEC_MARGE+10,0
	endc