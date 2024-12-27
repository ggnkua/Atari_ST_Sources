	opt s-
start	move.l a7,a6
	move.l 4(a6),a6
	pea $2000
	pea (a6)
	pea $4a0000
	trap #1
	lea 12(sp),sp
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,$8.w
	lea $80000,sp
	lea $ffff8240.w,a0
	moveq #7,d0
clla	clr.l (a0)+
	dbf d0,clla
	lea text(pc),a0
	bsr print
	bsr fadeup
	bsr getkey
	bsr fadedn
	move.l #patch,$bc.w
	move.l $8.w,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	pea env
	pea com
	pea file
	clr.w -(sp)
	move.w #$4b,-(sp)
	trap #1
env	dc.l 0
com	dc.l 0
file	dc.b 'CYNIX.GO',0,0

patch	lea handler(pc),a6
	lea $140.w,a5
zz1	move.w (a6)+,(a5)+
	cmp.l #fadeup,a6
	ble zz1
	move.l #$60000,d0
	rte

handler	movem.l d0-a6,-(sp)
	move.l d0,a6
	move.l a0,a1
	lea name(pc),a0
	moveq #10,d0
.1	move.b #$20,(a0)+
	dbf d0,.1
	clr.b (a0)+
	lea -$c(a0),a0
ncl	move.b (a1)+,d0
	cmp.b #96,d0
	ble cok
	and.b #$df,d0
cok	move.b d0,(a0)+
	cmp.b #'.',(a1)
	bne ncl
	lea 1(a1),a1
	lea (name+8)(pc),a0
ncl2	move.b (a1)+,d0
	cmp.b #96,d0
	ble cok2
	and.b #$df,d0
cok2	move.b d0,(a0)+
	cmp.b #00,(a1)
	bne ncl2
	lea name(pc),a0
	move.l a6,a1
	bsr load
	movem.l (sp)+,d0-a6
	rts

name	dc.l 0,0,0

load	move.l a1,-(sp)
	lea	$ffff8606.w,a5
	lea	data(pc),a6
	move.l	a0,filename-data(a6)
	move.l	a1,loadaddr-data(a6)
	bsr	do_boot
	bsr	do_dir
	bsr	do_file
	move.l (sp)+,a0
	rts


do_boot	; Read boot sector and calculate dir/data posns

	moveq	#0,d0
	bsr	read_log	Read boot sector
		
	move.l	loadaddr-data(a6),a0
	
	moveq	#0,d0
	moveq	#0,d1
	move.b	$10(a0),d0
	move.b	$16(a0),d1
	mulu	d1,d0
	addq.w	#1,d0
	move.w	d0,dir_pos-data(a6)

	move.b	$11(a0),d1
	lsr.w	#4,d1
	move.w	d1,dir_len-data(a6)

	rts


do_dir	; Reads dir and get load_sec and load_len

	move.w	dir_pos-data(a6),d6
	move.w	dir_len-data(a6),d7
	add.w	d7,dir_pos-data(a6)	Posn of cluster 2

.1	move.w	d6,d0
	bsr	read_log
	
	moveq	#15,d0		16 file entries per sec
	move.l	loadaddr-data(a6),a0
	move.l	filename-data(a6),a1

.2	moveq	#10,d1		11 chars in filename

.3	move.b	0(a0,d1.w),d2
	cmp.b	0(a1,d1.w),d2
	bne	.4
	dbf	d1,.3
	lea	26(a0),a0		File found!
	lea	load_sec+2-data(a6),a1
	move.b	(a0)+,-(a1)
	move.b	(a0)+,-(a1)
	lea	load_len+4-data(a6),a1
	move.b	(a0)+,-(a1)
	move.b	(a0)+,-(a1)
	move.b	(a0)+,-(a1)
	move.b	(a0)+,-(a1)
	cmp.l #'CCBC',$7618.w
	bne.s .xx
	move.l (a1),$cbfa
.xx	move.w	load_sec-data(a6),d0
	subq.w	#2,d0
	add.w	d0,d0
	add.w	dir_pos-data(a6),d0
	move.w	d0,load_sec-data(a6)
	moveq	#0,d0
	rts

.4	lea	32(a0),a0		Next entry
	dbf	d0,.2

	addq.w	#1,d6		Next dir sector
	subq.w	#1,d7	
	bpl	.1
	rts			d0=-1,file not found error


do_file	; Read file in!

	move.w	load_sec-data(a6),d0
	ext.l	d0
	bsr	calc_sec		d0=trk,d1=sec
	move.w	d1,d2
	mulu	#$200,d2
	move.l	#$1600,d3
	sub.l	d2,d3		d3=max load amount of this track
	move.l	load_len-data(a6),d2
	cmp.l	d2,d3
	bge.s	.1
	move.l	d3,d2
.1	move.l	d2,-(a7)		d2=amount
	bsr	readdisk
	move.l	(a7)+,d2
	add.l	d2,loadaddr-data(a6)
	sub.l	d2,load_len-data(a6)
	divu	#$200,d2
	add.w	d2,load_sec-data(a6)
	tst.l	load_len-data(a6)
	bne.s	do_file		More to load?
	rts
	

; Little subbies (!)

read_log	; Read logical sector in d0

	bsr	calc_sec
	move.l	#$200,d2		One sector only
	bsr.s	readdisk
	rts


readdisk	; Read d0=trk,d1=sec,d2=amount

	move.w	d1,d4			Sector to d4
	add.w	#$1ff,d2
	divu	#$200,d2
	move.w	d2,d3			Count to d3
	move.l	loadaddr-data(a6),a0	Load address

	move.w	#$86,(a5)		Move head to track d0
	move.w	d0,d1
	bsr	shove_fdc
	move.w	#$80,(a5)
	move.w	#$13,d1
	bsr	shove_fdc
	bsr	wait_fdc
	bmi	stat_bad
	move.w	#$82,(a5)		Set track register
	move.w	d0,d1		d0=track
	bsr	shove_fdc
.next_sec	moveq	#2,d5		3 tries
.err_loop	move.l	a0,d1
	move.b	d1,7(a5)
	lsr.l	#8,d1
	move.b	d1,5(a5)
	lsr.w	#8,d1
	move.b	d1,3(a5)
	move.w	#$84,(a5)
	move.w	d4,d1		d4=sec
	bsr	shove_fdc
	move.w	#$90,(a5)
	move.w	#$190,(a5)
	move.w	#$90,(a5)
	move.w	#$1,d1		1 sec
	bsr	shove_fdc
	move.w	#$80,(a5)
	move.w	#$80,d1
	bsr	shove_fdc
	bsr	wait_fdc		Read sec
	bmi	stat_bad
	move.w	-2(a5),d1
	and.w	#$70,d1
	beq.s	.ok
	dbf	d5,.err_loop
	bra	stat_bad
.ok	lea	$200(a0),a0
	addq.w	#1,d4
	subq.w	#1,d3
	bne	.next_sec
	rts

shove_fdc
	bsr.s	.1
	move.w	d1,-2(a5)
.1	moveq	#32,d2
.2	dbf	d2,.2
	rts

wait_fdc
	move.l	#$400000,d1
.1	btst	#5,$fffa01
	beq.s	.2
	subq.l	#1,d1
	bpl	.1
	rts
.2	moveq	#0,d1
	rts

stat_bad
	addq.l	#8,a7		Error
	bra	select_2
	

calc_sec	; Logical sector in d0,outputs trk,sec in d0,d1

	divu	#10,d0
	btst	#0,d0
	bne.s	.1
	bsr	select_0	Side 0
	bra.s	.2
.1	bsr	select_1	Side 1
.2	move.l	d0,d1
	lsr.w	#1,d0	Trk
	swap	d1
	addq.w	#1,d1	Sec
	rts

select_0
	movem.l	d0-d1,-(a7)	Select side 0
	moveq	#5,d0	
	bra.s	sel

select_1
	movem.l	d0-d1,-(a7)	Select side 1
	moveq	#4,d0	
	bra.s	sel

select_2
	movem.l	d0-d1,-(a7)	Select nothing
	moveq	#7,d0	

sel	move	sr,-(a7)
	or	#$700,sr
	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d1
	and.b	#$f8,d1
	or.b	d0,d1
	move.b	d1,$ffff8802.w
	move	(a7)+,sr
	movem.l	(a7)+,d0-d1
	rts


data	; All variables relative to this for pos-ind code

filename	dc.l	0	Address of filename
loadaddr	dc.l	0	Load address
load_sec	dc.w	0	Sector to load from
load_len	dc.l	0	File length left to load
dir_pos	dc.w	0	Start sec of directory (then data)
dir_len	dc.w	0	Directory length in secs	


fadeup	move.w #6,d0
ful	move.w #$1234,d2
	move.w #$2000,d1
paa	mulu d1,d2
	dbf d1,paa
	add.w #$111,$ffff825e.w
	dbf d0,ful
	rts

fadedn	move.w #6,d0
ful1	move.w #$1234,d2
	move.w #$2000,d1
paa1	mulu d1,d2
	dbf d1,paa1
	sub.w #$111,$ffff825e.w
	dbf d0,ful1
	rts

getkey	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	rts

print	pea (a0)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	rts

text		dc.b 27,'f',27,'E'
		dc.b "             Cynix Present",10,13
		DC.B "             ~~~~~~~~~~~~~",10,10,13
		dc.b "        Winter Super Sports '92",10,10,10,13
		dc.b "  Cracked 'n' Packed 1 disk version by",10,10,13
		dc.b "         >>>  Deadly Force  <<<",10,10,13
		dc.b "      Original Supplied by Humpty",10,10,10,13
		dc.b "The two skating events look corrupted",10,13
		dc.b "to me, but the original is the same so",10,13
		dc.b "it's probably just bugged !!",10,13
		dc.b "No room on the disk for a better intro,",10,13
		dc.b "so just enjoy the game......",10,10,13
		dc.b "Golden Regards are sent to:",10,13
		dc.b "The Replicants, Superior, Elite, D-Bug,",10,13
		dc.b "Bald Eagle, Hotline, MCA, Vectronix,",10,13
		dc.b "Wizpop, Derek MD, Mad Vision, Unity,",10,13
		dc.b "ACF, Aggression, Pompey Pirates, Hal",10,13
		dc.b "and all other friends and contacts."
	even
		dc.w 0
