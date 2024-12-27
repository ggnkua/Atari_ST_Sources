	opt s-
start	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	clr.w -(sp)
	pea $78000
	pea $78000
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	lea $80000,sp
	lea $ffff8240.w,a0
	moveq #7,d0
clla	clr.l (a0)+
	dbf d0,clla
	move.l $70.w,$8.w
	moveq #4,d0
	bsr music
	move.l #int,$70.w
	lea text(pc),a0
	bsr print
	bsr fadeup
	bsr getkey
	cmp.b #'1',d0
	bne.s dr2
	move.w #1,$4a6.w
dr2	bsr fadedn
	lea text1(pc),a0
	bsr print
	bsr fadeup
	bsr getkey
	bsr fadedn
	lea text2(pc),a0
	bsr print
	move.w $4a6.w,d0
	and.l #$ff,d0
	add.b #'0',d0
	move.w d0,-(sp)
	move.w #2,-(sp)
	trap #1
	addq.l #4,sp
	lea text3(pc),a0
	cmp.l #$80000,$42e.w
	ble.s pexr
	lea text4(pc),a0
	bsr print
	bsr fadeup
	move.w #0,-(sp)
	pea file(pc)
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,d7
	move.w #0,-(sp)
	move.w d7,-(sp)
	move.l #$90e00,-(sp)
	move.w #$42,-(sp)
	trap #1
	add.l #10,sp
	pea $b0000
	pea $7ffff
	move.w d7,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	move.w d7,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	move.l #$fffff,d0
ap	subq.l #1,d0
	bne.s ap
	move.w #1,ram
	bra moff
pexr	bsr print
	bsr fadeup
moff	move.l $8.w,$70.w
	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0a0a0000,$ffff8800.w
	cmp.w #2,$4a6.w
	bne.s no_ex
	move.w #1,extern
no_ex	move.w #1,$43e.w
	move.w #1,$4a6.w
	lea handler(pc),a0
	lea init(pc),a2
	lea (go+$756)(pc),a1
zq	move.w (a0)+,(a1)+
	cmp.l a2,a0
	blt.s zq
	lea init(pc),a0
	lea fadeup(pc),a2
	lea $146a0,a1
zz	move.w (a0)+,(a1)+
	cmp.l a2,a0
	blt.s zz
	move.l #$4eb90001,(go+$48c)
	move.w #$4f1e,(go+$490)
	move.l #$4278003a,(go+$990)
	move.l #$33fc0001,(go+$994)
	move.l #$00014f3a,(go+$998)
	move.w #$4e75,(go+$99c)
	move.l #$4bf88606,(go+$4be)
	move.l #$4eb90001,(go+$4c2)
	move.l #$46a44e75,(go+$4c6)
	move.w #0,(go+$4a)
go	incbin g:\go

handler	movem.l d0-a6,-(sp)
	lea	$ffff8606.w,a5
	lea	data(pc),a6
	tst.w	ram-data(a6)
	beq.s	no_ram
	move.l	$149c6,a3
	cmp.l	#$108493,a3
	bge.s	no_ram
	cmp.l	#$e4340,a3
	blt.s	no_ram
	sub.l	#$34340,a3
	add.l	$149ca,a3
	move.l	$149da,a4
	move.l	$149ce,d5
	bsr	rdl1
	bra	fin
no_ram	tst.w	$14f3a
	beq.s	noinr
	clr.w	$14f3a
	bsr	(init-$82e)
	move.w	check-data(a6),d6
	bra.s	(dsk2+4)
noinr	moveq	#0,d6
	cmp.l 	#$108493,$149c6
	blt.s	dsk1
	moveq	#1,d6
dsk1	cmp.w	check-data(a6),d6
	beq.s	right
	bra.s	wrong
dsk2	bsr	(init-$82e)
	move.l	#$16000,loadaddr-data(a6)
	moveq 	#15,d0
	bsr	(read_log-$82e)
	cmp.w	#0,d6
	bne.s	wd2
	cmp.l	#$01bf9018,$16000
	beq.s	right
	bra.s	wrong
wd2	cmp.l	#$01df3408,$16000
	beq.s	right
wrong	tst.w	extern-data(a6)
	beq.s	no_b
	lea	(select_0+4-$82e)(pc),a0
	eor.w	#6,(a0)
	eor.w	#6,8(a0)
	bra.s	dsk2
no_b	lea 	$ffff8240.w,a0
	move.w	(a0),d1
	move.l	#$140000,d0
flash	eor.w	#$777,(a0)
	subq.l	#1,d0
	bne.s	flash
	move.w	d1,(a0)
	bra.s	dsk2
right	move.w	d6,check-data(a6)
	move.l	$149c6,d0
	add.l	$149ca,d0
	sub.l	#$16d2,d0
	cmp.l	#$721a0,$149c6
	blt.s	s0
	sub.l	#$1ace,d0
	cmp.l	#$e4340,$149c6
	blt.s	s0
	sub.l	#$503a0,d0
	cmp.l	#$108493,$149c6
	blt.s	s0
	sub.l	#$b4f53,d0
	cmp.l	#$1564e0,$149c6
	blt.s	s0	
	sub.l	#$5a0,d0
s0	move.l	$149da,a0
	move.l	a0,dest-data(a6)
	clr.w	si-data(a6)
	divu	#$200,d0
	add.w	#15,d0
	move.w	d0,load_sec-data(a6)
	swap	d0
	and.l	#$ffff,d0
	move.l	d0,d7
fl	move.l	#$16000,loadaddr-data(a6)
	move.l	#$1600,load_len-data(a6)
	bsr	(do_file-$82e)
	bsr	raw				;d7=offset from $16000
	move.l	#$1600,d6
	sub.l	d7,d6
	sub.l	d6,$149ce
	bmi.s	fin
	moveq	#0,d7
	bra.s	fl
fin	movem.l (sp)+,d0-a6
	rts

raw	lea	$16000,a3
	move.l	dest-data(a6),a4
	move.l	#$1600,d5
	add.l	d7,a3
	sub.l	d7,d5
	tst.w	si-data(a6)
	bne.s	rdl2
rdl1	move.b	(a3)+,d0
	cmp.b	#7,d0
	bne.s	strip
	subq.w	#1,d5
	beq.s	ret
rdl2	move.b	(a3)+,d0
strip	move.b	d0,(a4)+
	addq.l	#1,dest-data(a6)
	subq.w	#1,d5
	bne.s	rdl1
	clr.w	si-data(a6)
	rts
ret	move.w	#1,si-data(a6)
	rts

data	; All variables relative to this for pos-ind code

filename	dc.l	0	Address of filename
loadaddr	dc.l	0	Load address
load_sec	dc.w	0	Sector to load from
load_len	dc.l	0	File length left to load
file_len	dc.l	0
check		dc.w	0
ram		dc.w	0
si		dc.w	0
extern		dc.w	0
dest		dc.l	0


;This bit goes to $146a0

init	bsr	select_1
	move.w	#$80,(a5)
	moveq	#15,d1
	bsr	shove_fdc
	bsr	wait_fdc
	rts

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
	lea $ffff8240.w,a0
	move.w (a0),d1
	move.w #$ffff,d0
.1	addq.w	#1,(a0)
	dbf d0,.1
	move.w d1,(a0)
	rts

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
int	movem.l d0-a6,-(sp)
	bsr (music+8)
	movem.l (sp)+,d0-a6
	move.l $8.w,-(sp)
	rts
music	incbin g:\tune.mus

file		dc.b 'maupiti1',0,0
text		dc.b 27,'f',27,'E'
		dc.b "        The Medway Boys Present",10,13
		DC.B "        ~~~~~~~~~~~~~~~~~~~~~~~",10,10,13
		DC.B "             MAUPITI ISLAND",10,10,10,13
		dc.b "       Cracked and Filed by ZIPPY",10,13
		dc.b "       Original Supplied by GINO",10,10,10,13
		dc.b "This game has been out for over 3 weeks",10,13
		dc.b "and no-one else looked like cracking",10,13
		dc.b "it, so I thought I'd better do it !!",10,13
		dc.b "Each track was $16d2 bytes long, and",10,13
		dc.b "there were over 450 files over both of",10,13
		dc.b "the disks. As well as this format, they",10,13
		dc.b "also included checksums, self-modifying",10,13
		dc.b "code and a few other nasty little anti-",10,13
		dc.b "hacker routines !!",10,13
		dc.b "Of course this version is now in files,",10,13
		dc.b "on 10 sector format disks.",10,10,13
		dc.b "If your other drive is single-sided,",10,13
		dc.b "then press '1' now, to force access to",10,13
		dc.b "this boot (Double-Sided) drive only..."
	even
		dc.w 0
text1		dc.b 27,'f',27,'E'
		dc.b "Read all this text !!",10,13
		dc.b "~~~~~~~~~~~~~~~~~~~~~",10,10,13
		dc.b "This version will use any extra ram or",10,13
		dc.b "drives that you may have, but if you've",10,13
		dc.b "only got 1 drive and half meg then be",10,13
		dc.b "prepared for a lot of disk swapping !!",10,10,13
		dc.b "If you have a second Drive, then please",10,13
		dc.b "insert disk 2 in Drive B NOW !!",10,10,13
		dc.b "If the screen flashes then insert the",10,13
		dc.b "other disk in any connected drive, but",10,13
		dc.b "otherwise ignore any request to change",10,13
		dc.b "disks. (Except during save games).",10,10,13
		dc.b "To create a saved game disk format a",10,13
		dc.b "blank disk single-sided and name it",10,13
		dc.b "'MAUPITI'",10,10,13
		dc.b "Greets go to all other guys who didn't",10,13
		dc.b "manage to crack this great protection !",10,10,13
		dc.b "Press any key to load......"
	even
		dc.w 0
text2		dc.b 27,'f',27,'E'
		dc.b "Number of Drives found: ",0
text3		dc.b 10,13,"Extra ram detected: No",10,10,13
		dc.b "Please wait, loading....",0
text4		dc.b 10,13,"Extra ram detected: Yes",10,10,13
		dc.b "Please wait, Creating ram disk....",0
	even
		dc.w 0
