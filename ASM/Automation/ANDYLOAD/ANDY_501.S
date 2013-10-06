;               Andyload v1.0
;
; Copyright (c) 1990 Andy the Arfling productions
;
; Conceived 27/9/90
; Started 28/9/90
; Aborted 28/9/90
;
; Restarted 26/10/90

; Conversion to Automation v5.01 packer by MUG U.K(tm) 

flash	equ	0

begin	bra	start	

data	dc.b	'rippler.lmp',0	Data file (Chunk packed)
	even

prog	dc.b	'rippler.prg',0	Game prg file (within lump file)
	even

mess	dc.b	27,'E',27,'f'
	dc.b	'          MUG U.K presents....',10,13,10,13
	dc.b	'                Rippler',10,13,10,13
	dc.b	'               Featuring',10,13
	dc.b	'             AndyLoad v1.0',10,13
	dc.b	'          (Revision v5.01 !!)',10,13,10,13
	dc.b	'         Press any key to play'
	dc.b	0
	even

	
start	pea	mess		What have I packed now?
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	#7,-(a7)		Get key
	trap	#1
	addq.l	#2,a7

	clr.w	-(a7)		Open Data file
	pea	data
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	move.w	d0,d7

	lea	chunk_tab,a6	Load chunk info
	moveq	#12,d0
	bsr	load_data		
	cmp.l	#'AU5C',(a6)
	bne	exit
	move.l	8(a6),d0
	move.l	d0,chunk_len
	lsr.w	#2,d0
	move.w	d0,chunk_len4	Chunk_len/4 to fix for 32 & 64K chk

	moveq	#4,d0		Position of first chunk
	bsr	load_data
	move.l	(a6)+,d0
	moveq	#12,d1		12 bytes at beginning not wanted
	sub.l	d1,d0
	add.l	d0,buffer		Buffer at end of chunk table
	add.l	d0,chunk
	subq.l	#4,d0		First longword already loaded
	bsr	load_data		Load rest of chunk positions

	move.w	d7,-(a7)		Close data file
	move.w	#$3e,-(a7)	(All reading direct from now on!)
	trap	#1
	addq.l	#4,a7

	move.l	chunk,a0		Malloc call
	add.l	chunk_len,a0
	lea	$200(a0),a7	Move stack
	sub.l	#basepage-$200,a0	
	move.l	a0,-(a7)
	pea	basepage
	pea	$4a0000
	trap	#1
	lea	12(a7),a7

	pea	setup		Install stuff
	move.w	#38,-(a7)		
	trap	#14
	addq.l	#6,a7

	move.w	#3,-(a7)		Set Drive D
	move.w	#14,-(a7)
	trap	#1
	addq.l	#4,a7

	lea	-$180(a7),a0	Run game
	clr.l	(a0)
	move.l	a0,-(a7)
	move.l	a0,-(a7)
	pea	prog
	pea	$4b0000
	trap	#1
	lea	16(a7),a7

	pea	remove		Remove stuff
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7

exit	clr.w	-(a7)		Quit
	trap	#1


load_data	move.l	a6,-(a7)
	move.l	d0,-(a7)
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	rts
;
;
; No TRAP calls from here on !!
;
;

setup	lea	$ffff8606.w,a5
	st	$43e.w
	bsr	conv_file		Convert filename to dir format
	bsr	do_boot		Read boot sector & calc dir place
	bsr	do_dir		Read dir & calc file start
	sf	$43e.w
	bsr	do_chunk_tab	Build table of chunk starts
	move.l	$472.w,old472
	move.l	$476.w,old476
	move.l	$47e.w,old47e
	move.l	#new472,$472.w
	move.l	#new476,$476.w
	move.l	#new47e,$47e.w
	rts


remove	move.l	old472,$472.w
	move.l	old476,$476.w
	move.l	old47e,$47e.w
	rts


new472	cmp.w	#3,4(a7)		D?
	beq.s	.ram
	move.l	old472,a0
	jmp	(a0)
.ram	move.l	#ramdata,d0
	rts


new476	cmp.w	#3,14(a7)		D?
	beq.s	.ram
	move.l	old476,a0
	jmp	(a0)

.ram	move.w	4(a7),d0
	btst	#0,d0
	beq.s	.read
	moveq	#-1,d0		No writing here folks!
	rts

.read	move.w	12(a7),d0
	mulu	#$200,d0
	move.l	d0,l_start	Offset from start of disk
	move.w	10(a7),d0
	mulu	#$200,d0
	move.l	d0,l_amount	Amount to load
	move.l	6(a7),l_dest	Destination
	movem.l	d1-d7/a0-a6,-(a7)

.more	move.l	l_start,d0
	lsr.l	#2,d0
	divu	chunk_len4,d0	Calc chunk
	cmp.w	chunk_no,d0
	beq	.loaded		Already in mem?
	move.w	d0,chunk_no

	bsr	load_chunk

	move.l	chunk,a1
	cmp.l	#'AU5!',(a1)	Packed?
	bne.s	.2

	move.l	buffer,a0	
	move.l	a0,a3
	move.l	a1,a2	
	move.w	chunk_len4,d0
.1	move.l	(a2)+,(a3)+
	subq.w	#1,d0
	bne.s	.1
	bsr	depack
.2	bsr	select_2

.loaded	move.w	chunk_no,d0
	add.w	d0,d0
	add.w	d0,d0
	mulu	chunk_len4,d0
	move.l	l_start,a0
	sub.l	d0,a0
	add.l	chunk,a0		Start of data
	move.l	chunk,d0
	add.l	chunk_len,d0
	sub.l	a0,d0		Max amount in buffer to be loaded
	cmp.l	l_amount,d0
	ble.s	.enough
	move.l	l_amount,d0	Too much
.enough	sub.l	d0,l_amount
	add.l	d0,l_start
	move.l	l_dest,a1
.copy	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.copy
	move.l	a1,l_dest
	tst.l	l_amount
	bne	.more

	movem.l	(a7)+,d1-d7/a0-a6
	rts
		

new47e	cmp.w	#3,4(a7)		D?
	beq	.ram
	move.l	old47e,a0
	jmp	(a0)
.ram	moveq	#0,d0		Disk changed? No way!
	rts


*********************************
;
;---------------------------------------
; Ice Depacker Routine by Axe of Delight
;---------------------------------------
;
;depack	addq.l	#4,a0		; skip past header
depack	bsr.s	getinfo		; ein Langwort holen
	cmpi.l	#'AU5!',d0	; Kennung gefunden?
	bne	not_packed	; nein: nicht gepackt
	addq.l	#4,d0
	bsr.s	getinfo		; gepackte LÑnge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	getinfo		; ungepackte LÑnge holen (original)
;	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	move.l	a1,a4		; a4 = Zielpuffer
	move.l	a1,a6
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a3		; merken fÅr Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr	normal_bytes

	bsr	get_1_bit 	;; Picture decrunch!
	bcc.s	not_packed	;; These marked lines may be
	move.w	#$0f9f,d7 	;; removed in your own sources
ice_00:	moveq	#3,d6		;; if you do not use the
ice_01:	move.w	-(a3),d4		;; additional algorithm.
	moveq	#3,d5		;;
ice_02:	add.w	d4,d4		;;
	addx.w	d0,d0		;;
	add.w	d4,d4		;;
	addx.w	d1,d1		;;
	add.w	d4,d4		;;
	addx.w	d2,d2		;;
	add.w	d4,d4		;;
	addx.w	d3,d3		;;
	dbra	d5,ice_02 	;;
	dbra	d6,ice_01 	;;
	movem.w	d0-d3,(a3)	;;
	dbra	d7,ice_00 	;;

not_packed:
	rts

getinfo:	moveq	#3,d1		; ein Langwort vom Anfang
getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,getbytes
	rts

normal_bytes:	
	bsr.s	get_1_bit
	bcc.s	test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	get_1_bit
	bcc.s	copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	direkt_tab+20(pc),a1
	moveq.l	#4,d3
nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,nextgb 	; ja: dann weiter Bits lesen
no_more:	add.l	20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
copy_direkt:	

;	ifne	flash		; flash colours if required !!
;	move.w	d0,$ffff8240.w	; Standard Auto v5.01 flash
;	move.w	d7,$ffff8240.w	; Greenies (not the nasal variety !!)
;	not.w	$ffff8240.w	; Black & White Minstrels !!
;	move.b	(a6),$ffff8240.w	; Medway Boys F/X
;	eori.w	#$201,$ffff8240.w	; Dream Warriors F/X
;	endc

	move.b	-(a5),-(a6)	; Daten direkt kopieren
	move.b	(a6),$ffff8240.w	; Flashen die kolors (sic!)
	dbf	d1,copy_direkt	; noch ein Byte
test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	strings		; Weiter wenn Ende nicht erreicht
	move.l	d7,d5
	move.l	(a7)+,d0
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schluû

get_1_bit:add.b	d7,d7		; hole ein bit
	bne.s	bitfound		; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
bitfound:	rts	

get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


strings:	lea.l	length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
get_length_bit:	
	bsr.s	get_1_bit
	dbcc	d2,get_length_bit	; nÑchstes Bit holen
no_length_bit:	
	moveq.l	#0,d4		; d4 = öberschuû-LÑnge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	no_Åber		; kein öberschuû nîtig
get_Åber: bsr.s	get_d0_bits
no_Åber:	move.b	6(a1,d2.w),d4	; Standard-LÑnge zu öberschuû add.
	add.w	d1,d4		; d4 = String-LÑnge-2
	beq.s	get_offset_2	; LÑnge = 2: Spezielle Offset-Routine


	lea.l	more_offset(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
getoffs:	bsr.s	get_1_bit
	dbcc	d2,getoffs
	moveq.l	#0,d1		; Offset-öberschuû
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu öberschuû add.
	bpl.s	depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	depack_bytes


get_offset_2:	
	moveq.l	#0,d1		; öberschuû-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	get_1_bit
	bcc.s	less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
less_40:	bsr.s	get_d0_bits
	add.w	d2,d1		; Standard-Offset + öber-Offset

depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,dep_b	; und noch ein Mal
	bra	normal_bytes	; Jetzt kommen wieder normale Bytes


direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

length_tab:
	dc.b 9,1,0,-1,-1	; Bits lesen
	dc.b 8,4,2,1,0		; Standard-LÑnge - 2 (!!!)

more_offset:
	dc.b	  11,4,7,0	; Bits lesen
	dc.w	$11f,-1,$1f	; Standard Offset
	dc.b	0

	even		

*************************************

do_chunk_tab ; Calculates table of positions of chunks on disk

	lea	chunk_tab,a0
	move.l	buffer,a1
	move.w	load_sec,d1
.loop
	move.l	(a0),d0
	divu	#$200,d0
	add.w	d1,d0
	swap	d0
	move.l	d0,(a0)+
	cmp.l	a0,a1
	bne.s	.loop
	rts


load_chunk ; Takes chunk number in chunk_no and loads it to chunk

	lea	$ffff8606.w,a5
	move.w	chunk_no,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	chunk_tab,a0
	lea	0(a0,d0.w),a0
	move.l	a0,-(a7)
	move.w	(a0),load_sec
	move.l	#$400,load_len	Just two sects.
	move.l	buffer,load_addr	Always load to buffer
	st	$43e.w
	bsr	do_file
	move.l	(a7)+,a0
	move.w	(a0)+,load_sec
	move.l	buffer,a1
	move.l	a1,load_addr	Always load to buffer
	add.w	(a0),a1		a1=start of file in mem
	move.l	a1,-(a7)
	cmp.l	#'AU5!',(a1)
	beq.s	.packed
	move.l	chunk_len,d0	Not packed so load whole chunk
	bra.s	.load_it
.packed	moveq	#12,d0		Packed so only load packed length
	add.l	8(a1),d0
.load_it	add.l	#$200,d0
	move.l	d0,load_len
	bsr	do_file
	sf	$43e.w
	move.l	(a7)+,a0
	move.l	chunk,a1		Move chunk to correct place
	move.l	chunk_len,d0
	add.l	d0,a0
	add.l	d0,a1
.copy	move.l	-(a0),-(a1)
	subq.l	#4,d0
	bne.s	.copy
	rts


*************************************

conv_file ; Converts GEMDOS filename to DIR format

	lea	data,a0
	lea	filename,a1
	move.l	#$20202020,(a1)
	move.l	#$20202020,4(a1)
	move.l	#$20202000,8(a1)
	moveq	#0,d0
.1	move.b	(a0)+,d1
	beq.s	.4
	cmp.b	#'.',d1
	bne.s	.2
	cmp.b	#8,d0
	bgt.s	.3
	moveq	#8,d0
	bra.s	.1
.2	cmp.b	#'a',d1
	blt.s	.3
	cmp.b	#'z',d1
	bgt.s	.3
	and.w	#$5f,d1
.3	move.b	d1,0(a1,d0.w)
	addq.w	#1,d0
	bra.s	.1
.4	rts


do_boot	; Read boot sector and calculate dir/data posns

	bsr	reset_hd

	moveq	#0,d0
	bsr	read_log		Read boot sector
		
	move.l	buffer,a0
	
	moveq	#0,d0
	moveq	#0,d1
	move.b	$10(a0),d0
	move.b	$16(a0),d1
	mulu	d1,d0
	addq.w	#1,d0
	move.w	d0,dir_pos

	move.b	$11(a0),d1
	lsr.w	#4,d1
	move.w	d1,dir_len

	rts


do_dir	; Reads dir and get load_sec and load_len

	move.w	dir_pos,d6
	move.w	dir_len,d7
	add.w	d7,dir_pos	Posn of cluster 2

.1	move.w	d6,d0
	bsr	read_log
	
	moveq	#15,d0		16 file entries per sec
	move.l	buffer,a0
	lea	filename,a1

.2	moveq	#10,d1		11 chars in filename

.3	move.b	0(a0,d1.w),d2
	cmp.b	0(a1,d1.w),d2
	bne	.4
	dbf	d1,.3
	lea	26(a0),a0		File found!
	lea	load_sec+2,a1
	move.b	(a0)+,-(a1)
	move.b	(a0)+,-(a1)
	move.w	load_sec,d0
	subq.w	#2,d0
	add.w	d0,d0
	add.w	dir_pos,d0
	move.w	d0,load_sec
	moveq	#0,d0
	rts

.4	lea	32(a0),a0		Next entry
	dbf	d0,.2

	addq.w	#1,d6		Next dir sector
	subq.w	#1,d7	
	bpl	.1
	rts			d0=-1,file not found error


do_file	; Read file in!

	move.w	load_sec,d0
	ext.l	d0
	bsr	calc_sec		d0=trk,d1=sec
	move.w	d1,d2
	mulu	#$200,d2
	move.l	#$1600,d3
	sub.l	d2,d3		d3=max load amount of this track
	move.l	load_len,d2
	cmp.l	d2,d3
	bge.s	.1
	move.l	d3,d2
.1	move.l	d2,-(a7)		d2=amount
	bsr	readdisk
	move.l	(a7)+,d2
	add.l	d2,load_addr
	sub.l	d2,load_len
	divu	#$200,d2
	add.w	d2,load_sec
	tst.l	load_len
	bne.s	do_file		More to load?
	bsr	kill_drive
	rts
	

; Little subbies (!)

reset_hd	; Restores head to track 0

	bsr	select_0
	move.w	#$80,(a5)
	move.w	#$f,d1
	bsr	shove_fdc
	bra	wait_fdc


read_log	; Read logical sector in d0

	move.l	buffer,load_addr	Always load to buffer
	bsr	calc_sec
	move.l	#$200,d2		One sector only
	bsr.s	readdisk
	rts


kill_drive ; Turn it off

	move.w	#$80,(a5)
	move.w	#$d0,d1
	bsr	shove_fdc
	rts


readdisk	; Read d0=trk,d1=sec,d2=amount

	move.w	d1,d4		Sector to d4
	add.w	#$1ff,d2
	divu	#$200,d2
	move.w	d2,d3		Count to d3
	move.l	load_addr,a0	Load address

	move.w	#$86,(a5)		Move head to track d0
	move.w	d0,d1
	bsr	shove_fdc
	move.w	#$80,(a5)
	move.w	#$1f,d1
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

shove_fdc	; Yeah man,take that!

	bsr.s	.1
	move.w	d1,-2(a5)
.1	moveq	#32,d2
.2	dbf	d2,.2
	rts

wait_fdc	; Yawn,come on floppy!

	moveq	#$20,d1
	swap	d1
.1	btst	#5,$fffffa01.w
	beq.s	.2
	subq.l	#1,d1
	bpl	.1
	rts
.2	moveq	#0,d1
	rts


stat_bad	; Errr... What's up doc?

	moveq	#-1,d0
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

select_0	; Selects side 0

	movem.l	d0-d1,-(a7)
	moveq	#5,d0	
	bra.s	sel

select_1	; Selects side 1

	movem.l	d0-d1,-(a7)
	moveq	#4,d0	
	bra.s	sel

select_2	; Selects nothing

	movem.l	d0-d1,-(a7)
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


filename	dcb.b	12,' '	Directory format of filename
load_addr	dc.l	0	Address to load to
load_sec	dc.w	0	Sector to load from
load_len	dc.l	0	File length left to load
dir_pos	dc.w	0	Start sec of directory (then data)
dir_len	dc.w	0	Directory length in secs	

*************************************

old472	dc.l	0
old476	dc.l	0
old47e	dc.l	0

chunk_no	dc.w	-1		Chunk in memory (none at start)
l_start	dc.l	0		Start of bit to be loaded
l_dest	dc.l	0		Destination for loading
l_amount	dc.l	0		Amount to be loaded

buffer	dc.l	chunk_tab		Depack buffer space
chunk	dc.l	chunk_tab+$200	Chunk posn itself
chunk_len	dc.l	0		Chunk length
chunk_len4 dc.w	0		(Chunk length)/4

ramdata	dc.w	$200		Sec length
	dc.w	2		Secs per clust
	dc.w	$400		Clust length
	dc.w	7		Secs in dir
	dc.w	5		Sec no. of FAT 2
	dc.w	6		Sec no. of first data clust
	dc.w	18		Misc.		
	dc.w	800		Number of K in ram disk (irrelevant)

chunk_tab	ds.w	0		Start of buffers...

basepage	equ	begin-$100
