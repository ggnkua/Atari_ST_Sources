;ZIP LOAD V2.01
;Please Note: The Disk must be 80 Trks, 10 Sectors and 2 Sides !!!

	opt s-
	clr.l -(sp)			;super mode
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	lea $80000,sp			;setup stack
	lea $ffff8240.w,a0		;black screen
	moveq #7,d0
clla	clr.l (a0)+
	dbf d0,clla
	clr.w ram			;clear ram flag
	cmp.l #$80000,$42e.w		;check for >=1 Meg
	ble halfmeg
	move.w #1,ram			;set ram flag
halfmeg	lea text(pc),a0			;show text
	bsr print
	bsr fadeup			;fade colours up
	bsr getkey			;wait for key
	cmp.b #'/',d0
	bne notsp
	clr.w ram
notsp	bsr fadedn
	move.w #1,$43e.w		;disable disk int
	lea handler(pc),a0		;copy handler
	lea $6e000,a1			;address of handler
chl	move.l (a0)+,(a1)+		;copy data
	cmp.l #fadeup,a0		;end ?
	ble chl
	tst.w ram			;check ram flag
	beq norl
	bsr rload			;load whole disk
norl	lea go,a0
	lea $70000,a1
gl	move.l (a0)+,(a1)+
	cmp.l #rload,a0
	ble gl
	jmp $70000
go	move.w #0,d0
	move.w #$A,d1			;sector in D0
	move.w #$A,d2			;count in D1
	lea $10000,a0			;address in A0
	jsr $6e000			;call handler
	move.l #$4eb90006,$100be
	move.l #$e0004e75,$100c2
	move.l #$380,$100ba
	lea fch(pc),a0
	lea $380.w,a1
fla	move.l (a0)+,(a1)+
	cmp.l #$3a8,a1
	ble fla
	jmp $10000
fch	move.l #$4eb90006,$121e2
	move.l #$e0004e75,$121e6
	jmp $800

rload	pea ramess			;>=1 Meg found message
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	bsr fadeup			;fade up colours
	move.w #0,-(sp)			;open disk file
	pea name
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,d7
	pea $80100			;read disk file
	pea $fffff
	move.w d7,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	move.w d7,-(sp)			;close disk file
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	bsr fadedn			;fade down colours
	rts				;return to main

handler	movem.l d1-a6,-(sp)		;lump handler
	lea (bots+2)(pc),a6
	clr.l (a6)
	tst.w d0
	beq tops
	add.w #800,d1
	move.l #204084,(a6)
tops	move.w	d1,d0			;start sector in D0
	move.w	d2,d1			;Length in D1
					;Address in A0
	lea	data(pc),a6		;offset for relative vars
	move.w	d0,start_sec-data(a6)	;save parameters
	move.w	d1,length_sec-data(a6)
	move.l	a0,load_adds-data(a6)
	lea	ram(pc),a0		;ram flag
	tst.w	(a0)			;check for >=1 Meg
	bne	lram
	lea	$ffff8606.w,a5		;No, so must disk load
	lea	trackbuff(pc),a1	;track buffer
	move.l	a1,loadaddr-data(a6)
	move.l	a1,offset-data(a6)
	lea	name(pc),a0		;filename
	move.l	a0,filename-data(a6)
	bsr	do_boot			;get boot details
	bsr	do_dir			;open file
	move.w	load_sec-data(a6),old_sec-data(a6)	;save file start

readl	move.w	old_sec-data(a6),load_sec-data(a6)	;restor file start
lram	lea	trackbuff(pc),a1	;track buffer
	move.l	a1,loadaddr-data(a6)
	move.l	a1,offset-data(a6)
	move.w	start_sec-data(a6),d0	;get required sec
	divu	#10,d0			;which track ? (Note: SS)
	swap 	d0			;which sector ?
	move.w	d0,sector-data(a6)	;store sector
	swap 	d0			;track
	and.l	#$ffff,d0		;mask
	lsl.l	#2,d0			;offset for table
	lea	table(pc),a0		;get table
	move.l	$0(a0,d0.l),d0		;get offset into file
bots	add.l	#0,d0
	lea	ram(pc),a0		;ram flag
	tst.w	(a0)			;check for >=1 Meg
	beq	cdl			;no, so disk load
	add.l	#$80100,d0		;start of disk
	move.l	d0,a0			;address of required track
	move.l	loadaddr-data(a6),a1	;copy into track buffer
	move.w	#319,d0			;320*16 bytes
rdl	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	dbf	d0,rdl			;loop
	bra conl			;continue with handler
cdl	divu	#$200,d0		;which sector
	add.w	d0,load_sec-data(a6)	;add to start
	swap	d0			;get extra bytes
	and.l	#$ffff,d0		;mask
	add.l	d0,offset-data(a6)	;add to buffer start
	move.l	#$1600,load_len-data(a6);must read extra sector in case
					;track starts at +510 bytes !!
	bsr	do_file			;read file
conl	move.l	offset-data(a6),a0	;start of track
	bsr	decrunch		;depack
	move.w	sector-data(a6),d0	;sector in track
	move.w	d0,d1			;save sector
	mulu	#$200,d0		;sector length
	add.l	d0,a0			;sector address
	move.l	load_adds-data(a6),a1	;destination address
notes	move.l	#31,d0			;32*16 bytes long
copl	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	dbf	d0,copl			;loop
	subq.w	#1,length_sec-data(a6)	;1 sector copied
	beq	endh			;last sector
	addq.w	#1,d1			;1 sector copied
	cmp.w	#10,d1			;finished this track
	bne	notes			;no ?
	sub.w	sector-data(a6),d1	;how many sectors ?
	add.w 	d1,start_sec-data(a6)	;add sectors read
	mulu	#$200,d1		;length read
	add.l	d1,load_adds-data(a6)	;add length
	bra	readl			;round loop again
endh	movem.l (sp)+,d1-a6		;exit
	moveq #0,d0			;no errors
	rts				;return

name	dc.b 'ZOMBIE     ',0		;filename of lump

table	incbin 'g:\table'		;get track table

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
	move.w	load_sec-data(a6),d0
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

filename	dc.l	0	;Address of filename
loadaddr	dc.l	0	;Load address for buffer
load_sec	dc.w	0	;Sector to load from
load_len	dc.l	0	;File length left to load
dir_pos	dc.w	0		;Start sec of directory (then data)
dir_len	dc.w	0		;Directory length in secs	
start_sec	dc.w 	0	;Sector to load from
length_sec	dc.w	0	;Length of sectors to load
load_adds	dc.l	0	;Address to load to
offset		dc.l	0	;Address of sector in buffer
sector		dc.w	0	;Which sector in track
old_sec		dc.w	0	;Temp storage for start of file
ram		dc.w	0	;Flag for ram disk

decrunch:	move.w $ffff8240.w,$8.w
		movem.l d0/a0/a5/a6,-(sp)	; save registers
		cmpi.l	#'Ice!',(a0)+		; Data packed?
		bne.s	ice2_07			; no!
		move.l	(a0)+,d0
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		lea	108(a0),a4
		movea.l a4,a6
		adda.l	(sp),a6
		movea.l a6,a3
		movea.l a6,a1			; save 120 bytes
		lea	ice2_21+120(pc),a2	; at the end of the
		moveq	#$77,d0			; unpacked data
ice2_00:	move.b	-(a1),-(a2)
		dbra	d0,ice2_00
		bsr	ice2_0c
		bsr.s	ice2_08
ice2_04:	move.l	(sp),d0			; move all data to
		lea	-120(a4),a1		; 120 bytes lower
ice2_05:	move.b	(a4)+,(a1)+
		dbra	d0,ice2_05
		subi.l	#$010000,d0
		bpl.s	ice2_05
		moveq	#$77,d0			; restore saved data
		lea	ice2_21+120(pc),a2
ice2_06:	move.b	-(a2),-(a3)
		dbra	d0,ice2_06
ice2_07:	movem.l (sp)+,d0/a0/a5/a6	; restore registers
		move.w $8.w,$ffff8240.w
		rts
ice2_08:	bsr.s	ice2_10
		bcc.s	ice2_0b
		moveq	#0,d1
		bsr.s	ice2_10
		bcc.s	ice2_0a
		lea	ice2_1e(pc),a1
		moveq	#4,d3
ice2_09:	move.l	-(a1),d0
		bsr.s	ice2_13
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice2_09
		add.l	20(a1),d1
ice2_0a:	move.b	-(a5),-(a6)
		move.w d7,$a.w
		move.b (a6),d7
		eor.w d7,$ffff8240.w
		move.w $a.w,d7
		dbra	d1,ice2_0a
		move.w $8.w,$ffff8240.w
ice2_0b:	cmpa.l	a4,a6
		bgt.s	ice2_16
		rts
ice2_0c:	moveq	#3,d0
ice2_0d:	move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice2_0d
		rts
ice2_0e:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_0f
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice2_15
ice2_0f:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice2_15
ice2_10:	add.l	d7,d7
		beq.s	ice2_11
		rts
ice2_11:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_12
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice2_12:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice2_13:	moveq	#0,d1
ice2_14:	add.l	d7,d7
		beq.s	ice2_0e
ice2_15:	addx.w	d1,d1
		dbra	d0,ice2_14
		rts
ice2_16:	lea	ice2_1f(pc),a1
		moveq	#3,d2
ice2_17:	bsr.s	ice2_10
		dbcc	d2,ice2_17
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice2_18
		bsr.s	ice2_13
ice2_18:	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice2_1a
		lea	ice2_20(pc),a1
		moveq	#1,d2
ice2_19:	bsr.s	ice2_10
		dbcc	d2,ice2_19
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice2_13
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice2_1c
ice2_1a:	moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice2_10
		bcc.s	ice2_1b
		moveq	#8,d0
		moveq	#$40,d2
ice2_1b:	bsr.s	ice2_13
		add.w	d2,d1
ice2_1c:	lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice2_1d:	move.b	-(a1),-(a6)
		dbra	d4,ice2_1d
		bra	ice2_08
		dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
		dc.b $00,$07,$00,$02,$00,$03,$00,$01
		dc.b $00,$03,$00,$01
ice2_1e:	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
		dc.b $00,$00,$00,$07,$00,$00,$00,$04
		dc.b $00,$00,$00,$01
ice2_1f:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
		dc.b $01,$00
ice2_20:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
		dc.b $00,$20
ice2_21:	ds.w 60			; free space (can be put in BSS)

trackbuff	ds.l 1408

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

ramess		dc.b 27,'f',27,'E'
		dc.b "ZIP-LOAD V2.01",10,10,13
		dc.b "1 Meg (or more) of Ram Detected.",10,10,13
		dc.b "Creating Ram Disk, Please wait....",0
		
text		dc.b 27,'f',27,'E'
		dc.b "The Medway Boys Present",10,13
		DC.B "~~~~~~~~~~~~~~~~~~~~~~~",10,10,13
		DC.B "HORROR ZOMBIES (Zip-Load File)",10,10,13
		dc.b "Packed and Filed by ZIPPY",10,13
		dc.b "Original Crack by Yoda (Empire)",10,10,13
		dc.b "This game was packed with ZIP-LOAD V2.01",10,10,10,13
		dc.b "Level codes are:",10,10,13
		dc.b "2 - Wolfman",10,13
		dc.b "3 - Hammer",10,13
		dc.b "4 - Lugosi",10,13
		dc.b "5 - Nosferatu",10,13
		dc.b "6 - Garlic",10,10,13
		dc.b "For Infinite Lives type 'Bogeyeater'",10,13
		dc.b "as the level code."
	even
		dc.w 0
