                 *********************************
                 *   A N D Y L O A D   V 2 . 0   *
                 *********************************

; Started some time in April '91
; Finished about 4 hours later
; Wiped about half an hour after that

; This version started 24/4/91
; Completed 25/4/91

; Now uses ice packer, loads faster and needs absolutely *no* buffer!
; Will corrupt memory after short loads though

; To Use:
;         move.w  #sector,d0
;         move.w  #count,d1
;         lea     address,a0
;         bsr     andyload

;You won't need to change these but it makes it look like good programming!
header_size equ	16		Size of chunky file header
chnk_size	equ	$2000		Size of chunks (8K)
no_secs	equ	10		Sectors per track (on file disk!)
pack_head	equ	'ICE!'		Longword to signify packed data
pack_pic	equ	0		Set to 1 for extra picture depacker
os	equ	1		If set uses $43e
fast_dir	equ	1		If set only reads boot/dir once

	opt	o+,p+,w-

andyload
	movem.l	d0-d7/a0-a6,-(a7)
	
	lea	$ffff8606.w,a5
	lea	data(pc),a6
	move.w	d0,sector-data(a6)
	move.w	d1,count-data(a6)
	move.l	a0,load_addr-data(a6)

	ifne	os
	st	$43e.w		Set disk in use flag
	endc

	ifne	fast_dir
	tst.w	file_sec-data(a6)	Already know file position
	bpl.s	.got_pos
	endc

	bsr	do_boot
	bsr	do_dir
	tst.w	d0
	bmi.s	.error
.got_pos
	bsr	do_header
	bsr	do_load
	bsr	do_depack
.error
	bsr	select_2

	ifne	os
	sf	$43e.w
	endc

	movem.l	(a7)+,d0-d7/a0-a6
	rts

filename	dc.b	'DISKDUMPDAT',0	Filename in directory format


do_boot ; Read boot sector and calculate dir/data posns

	bsr	reset_hd	Restore head to track 0

	moveq	#0,d0
	bsr	read_log	Read boot sector
		
	move.l	load_addr-data(a6),a0
	
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


do_dir ; Read dir and get file_sec

	move.w	dir_pos-data(a6),d6
	move.w	dir_len-data(a6),d7
	add.w	d7,dir_pos-data(a6)	Posn of cluster 2

.1	move.w	d6,d0
	bsr	read_log
	
	moveq	#15,d0		16 file entries per sec
	move.l	load_addr-data(a6),a0
	lea	filename-data(a6),a1

.2	moveq	#10,d1		11 chars in filename

.3	move.b	0(a0,d1.w),d2
	cmp.b	0(a1,d1.w),d2
	bne	.4
	dbf	d1,.3
	lea	26(a0),a0		File found!
	lea	file_sec+2-data(a6),a1
	move.b	(a0)+,-(a1)
	move.b	(a0)+,-(a1)
	move.w	file_sec-data(a6),d0
	subq.w	#2,d0
	add.w	d0,d0
	add.w	dir_pos-data(a6),d0
	move.w	d0,file_sec-data(a6)
	moveq	#0,d0
	rts

.4	lea	32(a0),a0		Next entry
	dbf	d0,.2

	addq.w	#1,d6		Next dir sector
	subq.w	#1,d7	
	bpl	.1
	rts			d0=-1,file not found error


do_header
	move.w	sector-data(a6),d0	Start sector
	mulu	#$200,d0
	divu	#chnk_size,d0	First chunk number in d0
	bsr	.get_off		Convert to offset
	move.l	d0,-(a7)
	move.w	sector-data(a6),d0
	add.w	count-data(a6),d0
	subq.w	#1,d0		End sector
	mulu	#$200,d0
	divu	#chnk_size,d0
	addq.w	#1,d0		End chunk number in d0
	bsr	.get_off		Convert to offset
	move.l	(a7)+,d1
	sub.l	d1,d0		Amount to load
	divu	#$200,d1
	add.w	file_sec-data(a6),d1
	move.w	d1,load_sec-data(a6) Sector to load from
	swap	d1
	move.w	d1,load_off-data(a6) Offset through sector
	ext.l	d1		Add offset to amount to load
	add.l	d1,d0		
	move.l	d0,load_len-data(a6)
	rts

.get_off
	ext.l	d0
	lsl.w	#2,d0		Multiply d0 by 4 (longword)
	add.w	#header_size,d0	Add on header size
	divu	#$200,d0		Get sector offset
	move.l	d0,-(a7)
	add.w	file_sec-data(a6),d0
	bsr	read_log
	move.l	(a7)+,d0
	swap	d0		Get byte offset
	move.l	load_addr-data(a6),a0
	add.w	d0,a0
	move.l	(a0),d0		Get chunk offset
	rts


do_load ; Loads chunks into memory
	move.l	load_addr-data(a6),-(a7)
	move.l	load_len-data(a6),data_end-data(a6)
	bsr	read_disk
	move.l	(a7)+,a0
	move.l	a0,load_addr-data(a6)
	move.l	data_end-data(a6),d0
	move.w	load_off-data(a6),d1	Take off offset from len
	ext.l	d1
	sub.l	d1,d0
	move.l	d0,d2
	add.l	a0,d2			Add start of data
	move.l	d2,data_end-data(a6)	Store in data_end
	move.l	a0,a1
	lea	0(a0,d1.w),a1
.copy	move.b	(a1)+,(a0)+
	subq.l	#1,d0
	bpl.s	.copy
	rts


do_depack ; Depack all chunks with minimum possible memory usage

; Handle first chunk
	move.l	load_addr-data(a6),a0
	cmp.l	#pack_head,(a0)		Packed?
	bne.s	.move_1
	move.l	#chnk_size,d0
	sub.l	4(a0),d0			Length difference
	move.l	data_end-data(a6),a1	End of load
	lea	0(a1,d0.l),a2		New end of load
	move.l	a2,data_end-data(a6)
	move.l	4(a0),d0
	add.l	a0,d0
.copy_up	move.b	-(a1),-(a2)		Copy up so chunk has 8K
	cmp.l	d0,a1
	bgt.s	.copy_up
	bsr	depack
.move_1	move.w	sector-data(a6),d0
	ext.l	d0
	divu	#chnk_size/$200,d0
	swap	d0			d0 number of sec in chnk
	move.w	#chnk_size/$200,d1
	sub.w	d0,d1			d1 is max count
	add.w	d1,sector-data(a6)
	sub.w	d1,count-data(a6)
	mulu	#$200,d1
	add.l	d1,load_addr-data(a6)
	mulu	#$200,d0
	lea	0(a0,d0.l),a1
	move.l	data_end-data(a6),a2 	Copy over wasted secs
.copy_dn	move.b	(a1)+,(a0)+
	cmp.l	a1,a2
	bgt.s	.copy_dn
	move.l	a0,data_end-data(a6)

; Set up reggies for loop
	move.l	load_addr-data(a6),a0
	move.w	count-data(a6),d0	
	move.w	d0,-(a7)
	mulu	#$200,d0
	lea	0(a0,d0.l),a5		a5 is end of load
	move.w	(a7)+,d0
	add.w	sector-data(a6),d0
	subq.w	#1,d0
	ext.l	d0
	divu	#chnk_size/$200,d0
	swap	d0
	addq.w	#1,d0
	muls	#-$200,d0
	lea	0(a5,d0.l),a4		a4 is dest. of last chunk

; Depack chunks in reverse order
.loop	tst.w	count-data(a6)		More to go?
	ble	.all_done

	move.l	data_end-data(a6),a3	Find posn of last chunk
	move.b	(a3)+,d1			Read first longword
	lsl.w	#8,d1
	move.b	(a3)+,d1
	lsl.l	#8,d1
	move.b	(a3)+,d1
	lsl.l	#8,d1
	subq.w	#3,a3
	move.w	#chnk_size-1,d0
.find	move.b	-(a3),d1			Read next longword
	ror.l	#8,d1
	cmp.l	#pack_head,d1
	bne.s	.not_fnd
	lea	4(a3),a0			Check real chunk
	move.b	(a0)+,d2
	lsl.w	#8,d2
	move.b	(a0)+,d2
	lsl.l	#8,d2
	move.b	(a0)+,d2
	lsl.l	#8,d2
	move.b	(a0)+,d2
	lea	0(a3,d2.l),a0		Should point to data_end
	cmp.l	data_end-data(a6),a0
	bne.s	.not_fnd
	move.l	a3,a0			Depack
	bsr	depack
	bra.s	.fnd
.not_fnd	dbf	d0,.find
.fnd	
	move.l	a3,data_end-data(a6)	End of previous chunk
	move.l	a5,d0
	sub.l	a4,d0			d0 is bytes to move
	lea	0(a3,d0.w),a3		a3 now end of data
.copy	move.b	-(a3),-(a5)		Copy upwards
	cmp.l	a4,a5
	bgt.s	.copy
	divu	#$200,d0			d0 now in secs
	sub.w	d0,count-data(a6)		Decrement count
	sub.l	#chnk_size,a4		Update pointers
	bra	.loop	
.all_done	rts


; Little subbies (!)

reset_hd	; Restores head to track 0

	bsr	select_0		Turn busy light on
	move.w	#$80,(a5)		Set command register
	move.w	#$f,d1		Restore head command
	bsr	shove_fdc
	bra	wait_fdc


read_log	; Read logical sector in d0

	bsr	calc_sec
	move.l	#$200,d2		One sector only
	bsr.s	readdisk
	rts


read_disk
	move.w	load_sec-data(a6),d0
	bsr	calc_sec		d0=trk,d1=sec
	move.w	d1,d2
	mulu	#$200,d2
	move.l	#(no_secs+1)*$200,d3
	sub.l	d2,d3		d3=max load amount of this track
	move.l	load_len-data(a6),d2
	cmp.l	d2,d3
	bge.s	.1
	move.l	d3,d2
.1	move.l	d2,-(a7)		d2=amount
	bsr	readdisk
	move.l	(a7)+,d2
	add.l	d2,load_addr-data(a6)
	sub.l	d2,load_len-data(a6)
	divu	#$200,d2
	add.w	d2,load_sec-data(a6)
	tst.l	load_len-data(a6)
	bne.s	read_disk		More to load?
	rts
	


readdisk	; Read d0=trk,d1=sec,d2=amount

	move.w	d1,d4			Sector to d4
	add.w	#$1ff,d2
	divu	#$200,d2
	move.w	d2,d3			Count to d3
	move.l	load_addr-data(a6),a0	Load address

	move.w	#$86,(a5)		Set data register (used in seek)
	move.w	d0,d1
	bsr	shove_fdc
	move.w	#$80,(a5)		Set command register
	move.w	#$13,d1		Seek command (3 is the step rate)
	bsr	shove_fdc
	bsr	wait_fdc
	bmi	stat_bad
	move.w	#$82,(a5)		Set track register
	move.w	d0,d1		d0=track
	bsr	shove_fdc
.next_sec	moveq	#2,d5		3 tries
.err_loop	move.l	a0,d1
	move.b	d1,7(a5)		Set up DMA
	lsr.l	#8,d1
	move.b	d1,5(a5)
	lsr.w	#8,d1
	move.b	d1,3(a5)
	move.w	#$84,(a5)		Set sector register
	move.w	d4,d1		d4=sec
	bsr	shove_fdc
	move.w	#$90,(a5)		Flip flag for read operation
	move.w	#$190,(a5)
	move.w	#$90,(a5)
	move.w	#$1,d1		Read 1 sector only
	bsr	shove_fdc
	move.w	#$80,(a5)		Set command register
	move.w	#$80,d1		Read sector command
	bsr	shove_fdc
	bsr	wait_fdc
	bmi	stat_bad
	move.w	-2(a5),d1		Read FDC status register
	and.w	#$70,d1
	beq.s	.ok
	dbf	d5,.err_loop	Error, retry
	bra	stat_bad
.ok	lea	$200(a0),a0	Increment load address
	addq.w	#1,d4		Increment sector
	subq.w	#1,d3		Decrement count
	bne	.next_sec
	rts

shove_fdc
	bsr.s	.1		Send word to FDC
	move.w	d1,-2(a5)
.1	moveq	#32,d2
.2	dbf	d2,.2
	rts

wait_fdc
	moveq	#4,d1		Wait for FDC to finish current op.
	swap	d1
.1	btst	#5,$fffffa01.w
	beq.s	.2
	subq.l	#1,d1
	bpl	.1
	rts
.2	moveq	#0,d1
	rts

stat_bad
	addq.l	#8,a7		Disk error
	moveq	#-1,d0
.1	move.w	d0,$ffff8240.w
	dbf	d0,.1
	bra	select_2
	

calc_sec	; Logical sector in d0,outputs trk,sec in d0,d1

	ext.l	d0
	divu	#no_secs,d0
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

********************************************** Unpackroutine von ICE-PACK
; Eingabe: a0 = Adresse gepackter Daten
depack
	link	a3,#-120
	movem.l	d0-d7/a0-a6,-(sp)
	lea	120(a0),a4	; a4 = Anfang entpackte Daten
	move.l	a4,a6		; a6 = Ende entpackte Daten
	bsr.s	.getinfo
	cmpi.l	#'ICE!',d0	; Kennung gefunden?
	bne	.not_packed
	bsr.s	.getinfo		; gepackte LÑnge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	.getinfo		; ungepackte LÑnge holen (original)
	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a1

	moveq	#119,d0		; 120 Bytes hinter entpackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d0,.save
	move.l	a6,a3		; merken fÅr Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr.s	.normal_bytes
	move.l	a3,a5		; fÅr 120 Bytes restore

	ifne	pack_pic
	bsr.s	.get_1_bit	;; Picture decrunch!
	bcc.s	.no_picture	;; These marked lines may be
	move.w	#$0f9f,d7 	;; removed in your own sources
.ice_00:	moveq	#3,d6		;; if you do not use the
.ice_01:	move.w	-(a3),d4		;; additional algorithm.
	moveq	#3,d5		;;
.ice_02:	add.w	d4,d4		;;
	addx.w	d0,d0		;;
	add.w	d4,d4		;;
	addx.w	d1,d1		;;
	add.w	d4,d4		;;
	addx.w	d2,d2		;;
	add.w	d4,d4		;;
	addx.w	d3,d3		;;
	dbra	d5,.ice_02	;;
	dbra	d6,.ice_01	;;
	movem.w	d0-d3,(a3)	;;
	dbra	d7,.ice_00	;;
.no_picture
	endc

	movem.l	(sp),d0-d7/a0-a3	; hole nîtige Register

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		; um Åberschriebenen Bereich
.rest	move.b	-(a3),-(a5)	; wieder herzustellen
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-d7/a0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1		; ein Langwort vom Anfang
.getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
.copy_direkt:	
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schluû

.get_1_bit:
	add.b	d7,d7		; hole ein bit
	bne.s	.bitfound 	; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	.on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


.strings: lea.l	.length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit	; nÑchstes Bit holen
.no_length_bit:	
	moveq.l	#0,d4		; d4 = öberschuû-LÑnge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	.no_Åber		; kein öberschuû nîtig
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:	move.b	6(a1,d2.w),d4	; Standard-LÑnge zu öberschuû add.
	add.w	d1,d4		; d4 = String-LÑnge-2
	beq.s	.get_offset_2	; LÑnge = 2: Spezielle Offset-Routine


	lea.l	.more_offset(pc),a1 ; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		; Offset-öberschuû
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	.get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu öberschuû add.
	bpl.s	.depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		; öberschuû-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	.get_1_bit
	bcc.s	.less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1		; Standard-Offset + öber-Offset

.depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,.dep_b 	; und noch ein Mal
	bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

.length_tab:
	dc.b 9,1,0,-1,-1		; Bits lesen
	dc.b 8,4,2,1,0		; Standard-LÑnge - 2 (!!!)

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

*************************************************** Ende der Unpackroutine


data	; All variables relative to this for pos-ind code

dir_pos	dc.w	0	Start sec of directory (then data)
dir_len	dc.w	0	Directory length in secs	
file_sec	dc.w	-1	Start sector of data file

load_sec	dc.w	0	Sector to load from
load_off	dc.w	0	Offset through sector
load_len	dc.l	0	Length left to load
load_addr	dc.l	0	Address to load to

sector	dc.w	0	Sector it wants to load
count	dc.w	0	Amount it wants to load
data_end	dc.l	0	End of loaded data