; absolute file loader for Total Apathy
;

ramtop	equ $80000			; end of video RAM

	pea a(pc)
	move.w #$26,-(a7)
	trap #14
	addq.w #6,a7
	clr.l -(a7)
	trap #1

address	equ $3000

a	lea c(pc),a0
	lea $62000,a1
	move.l #20000,d0
.up	move.b (a0)+,(a1)+
	subq.l #1,d0
	bne.s .up
	jmp $62000

c	lea $800.w,a7			; stack safe
	move.w #$2700,sr
	lea code(pc),a0			; copy up to $address
	lea 20000(a0),a1
	lea address,a2
loop	move.l (a0)+,(a2)+
	cmp.l a0,a1
	bne.s loop
	move.w #$2300,sr
	moveq.l #1,d0
	jmp address			; and run

code
	org address
	move.l d0,-(a7)			; save screen number
	
	move.l #$31415926,$426.w
	move.l #.reset_load,$42a.w

	move.l #ramtop-$7d00,screen
	bra .next
.mfpbuf	dc.l $df040000
	dc.l $00000000
	dc.l $001e6448
	dc.l $000051fe
	dc.l $ce590100
	dc.l $880181ff
.reset_load
	move.l #$31415926,$426.w
	move.l #.reset_load,$42a.w
	lea $2000.w,a7
	move.w #$2700,sr
	move.b #0,$ffff8260.w
	move.b #2,$ffff820a.w
	moveq.l #0,d0
	move.l d0,d1
	move.l d0,d2
	move.l d0,d3
	move.l d0,d4
	move.l d0,d5
	move.l d0,d6
	move.l d0,d7
	movem.l d0-7,$ffff8240.w
	move.b #$7,$ffff8201.w
	move.b #$80,$ffff8203.w

	lea .mfpbuf(pc),a0
	lea $fffffa01.w,a1
	moveq.l #$17,d0
.loop	move.b (a0)+,(a1)
	add.l #2,a1
	dbra d7,.loop

	bset #6,$fffffa09.w
	lea $ffff8800.w,a0
	move.b #$7,(a0)
	move.b #$c0,2(a0)
	move.b #$e,(a0)
	move.b #$7,2(a0)

	lea print(pc),a0
	move.w #$4e75,(a0)

	lea scr4(pc),a0
	move.w (a0)+,sec_start
	move.w (a0)+,sec_count
	move.w (a0)+,sec_side
	move.l (a0)+,load_addr
	bsr calc
	bsr read_em
	move.l load_addr,a0
	bsr depack
	jmp $9000

.next	move.b $ffff8260.w,old_res
	move.b $ffff8201.w,old_scr

	move.b $ffff8203.w,old_scr+1
	move.l $70.w,old_vbl
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,old_pal
	moveq.l #0,d0
	move.l d0,d1
	move.l d0,d2
	move.l d0,d3
	move.l d0,d4
	move.l d0,d5
	move.l d0,d6
	move.l d0,d7
	movem.l d0-7,$ffff8240.w

	cmp.W #'LA',$80000
	beq.s .noload
	move.w #$2700,sr
	lea scr5(pc),a0
	move.w (a0)+,sec_start
	move.w (a0)+,sec_count
	move.w (a0)+,sec_side
	move.l (a0)+,load_addr
	bsr calc
	bsr read_em
	move.l #'LAW!',$80000
.noload	
	jsr music
	move.w #$2700,sr
	bsr set_picture
	move.w #$2300,sr
	move.b screen+1,$ffff8201.w
	move.b screen+2,$ffff8203.w
	
	lea l_text,a0
	lea ramtop-$7d00+(160*183)+$60,a1
	bsr print

	move.l (a7)+,d0
	lea files(pc),a0
	add d0,d0
	add d0,d0
	move.l 0(a0,d0),a0
	move.w (a0)+,sec_start		; set disk stuff
	move.w (a0)+,sec_count
	move.w (a0)+,sec_side
	move.l (a0)+,load_addr
	move.l a0,tpnt			; set scroller stuff
	move.l a0,tend
	bsr reset_scrl

	move.l #vbl,$70.w

	bsr calc			; think about file.....
	bsr read_em			; then dnk, dnk, dnk, load it!
	lea d_text1,a0
	lea ramtop-$7d00+(160*183)+$60,a1
	bsr print
	move.l load_addr,a0		; load address
	bsr depack			; decrunch the sucker!

	lea p_text1,a0
	lea ramtop-$7d00+(160*183)+$60,a1
	bsr print
	lea p_text2,a0
	lea ramtop-$7d00+(160*192)+$60,a1
	bsr print

.space	cmp.b #$39,$fffffc02.w
	bne.s .space

	move.l old_vbl,$70.w
	moveq.l #0,d0
	move.l d0,d1
	move.l d1,d2
	move.l d2,d3
	move.l d3,d4
	move.l d4,d5
	move.l d5,d6
	move.l d6,d7
	movem.l d0-7,$ffff8240.w
	move.b old_res,$ffff8260.w
	move.b old_scr,$ffff8201.w
	move.b old_scr+1,$ffff8203.w
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w

	move.w #$2300,sr

	move.w #49,d7
.del	stop #$2300
	dbra d7,.del

	move.l load_addr,a0
	jmp (a0)

_rte	rte

run_addr	dc.l 0
old_res	dc.b 0
old_scr	dc.w 0
old_vbl	dc.l 0
old_pal	ds.w 16
screen	dc.l ramtop-$7d00
counter	dc.l 0

vbl	movem.l d0-a6,-(a7)
	move.b #0,$ffff8260.w
	bsr scroll
	jsr music+8
	movem.l (a7)+,d0-a6
	rte

scroll	moveq.l #1,d4
.faster	subq.w #1,scrl
	bne .go_scrl

.get	move.w #10,scrl
	moveq.l #0,d1
	move.l tpnt,a0

.back	move.b (a0),d1
	move.b d1,d3
	sub.w #$20,d1
	cmp.b #$ff,d3
	bne.s .next

.wrap	move.l tend,tpnt
	bra.s .get

.next	addq.l #1,tpnt

.next_ch
	add d1,d1
	add d1,d1
	lea ptable,a1
	move.l (a1,d1),a0	
	lea chbuff(pc),a1
.fillbuf
xx	set 0
	rept 8
	movep.l xx(a0),d5
	movep.l d5,(a1)
	addq.l #8,a1
xx	set xx+160
	endr

.go_scrl
	lea chbuff(pc),a0
	lea ramtop-$7d00+(160*192),a1
	moveq.l #7,d2
.rows	moveq.w #3,d0
.planes	lsl.w (a0)+
	roxl.w $30(a1)
	roxl.w $28(a1)
	roxl.w $20(a1)
	roxl.w $18(a1)
	roxl.w $10(a1)
	roxl.w $8(A1)
	roxl.w (A1)+
	dbra d0,.planes
	lea 152(a1),a1
	dbra d2,.rows
	dbra d4,.faster
.outg	rts

; call with a0 pointing to text
;           a1 address to plot characters at

print	moveq.l #1,d6
	moveq.l #7,d7
	moveq.l #5,d4
.loop	moveq.l #0,d0
	move.b (a0)+,d0
;	cmp.b #$ff,d0
;	beq.s .done
	sub.b #$20,d0
	add d0,d0
	add d0,d0
	lea ptable,a2
	move.l (a2,d0),a2
	bsr .plot
	dbra d4,.loop
;	bra.s .loop
.done	rts
.plot
x	set 0
	rept 8
	movep.l x(a2),d5
	movep.l d5,x(a1)
x	set x+160
	endr
	add.l d6,a1
	move.l d7,-(a7)
	move.l d6,d7
	move.l (a7)+,d6
	rts

; call with long to convert in d1

hashing	moveq #0,d0
	lea .table(pc),a0
	lea ascii+8(pc),a2
	bsr.s .first
	moveq.w #5,d3
.loop	bsr.s .next
	dbra d3,.loop
.next	ror.l #4,d1
.first	move.b d1,d0
	and #$f,d0
	move.b (a0,d0),-(a2)
	rts

.table	dc.b "0123456789ABCDEF"
ascii	ds.l 2
	dc.l $ffffffff
	even
l_text	dc.b "LOAD....",$ff
d_text1	dc.b "UNPACK..",$ff
p_text1	dc.b "  BASH  ",$ff
p_text2	dc.b " SPACE! ",$ff
	even

set_picture
	CMP.L #'LAZY',$80000
	BEQ.S .INRAM

	lea print(pc),a0
	move.w (a0),-(a7)
	move.w #$4e75,(a0)

	lea picture,a0
	lea $60000,a1
	move.l #15000/4,d0
.up	move.l (a0)+,(a1)+
	dbra d0,.up
	lea $60000,a0
	bsr depack

	lea $60000,a0
	move.l screen,a1
	LEA -34(A1),A1
	LEA $80004,A2
	MOVE.L A1,-(A7)
	move.l #$7d00/4,d0
.up1	move.l (a0),(a1)+
	MOVE.L (A0)+,(A2)+
	dbra d0,.up1
	MOVE.L #'LAZY',$80000
	MOVE.L (A7)+,A1
	movem.l 2(A1),d0-7
	movem.l d0-7,$ffff8240.w

	lea print(pc),a0
	move.w (a7)+,(a0)
	rts

.INRAM	LEA $80004+34,A0
	MOVE.L screen,A1
	MOVE.L #($7D00/4)-1,D0
.DOWN	MOVE.L (A0)+,(A1)+
	DBRA D0,.DOWN
	MOVEM.L $80006,D0-7
	MOVEM.L D0-7,$FFFF8240.W
	RTS

calc	moveq.l #0,d0
	move.w sec_start,d0
	divu #10,d0
	move.w d0,track		; save track start
	moveq.l #0,d0
	move.w track,d0
	mulu #10,d0
	move.w sec_start,d1
	sub.w d0,d1
	move.w d1,sector	; sectors till end of track remaining
	addq.w #1,sector
	rts

read_em	move.l load_addr,a0	; load address
	bsr side		; select disk side
	bsr sec_track		; select start track
readlop	movem.l d0-a6,-(a7)
	moveq.l #0,d1
	move.w sec_count,d1
	bsr hashing
	lea ascii+2,a0
	lea ramtop-$7d00+(160*192)+$60,a1
	bsr print
	movem.l (a7)+,d0-a6
	bsr sec_load		; read 1 sector
	addq.w #1,sector		
	cmp.w #11,sector	; end of track?
	bne.s .next
	move.w #1,sector
	addq.w #1,track
	bsr sec_track
.next	lea $200(a0),a0
	subq.w #1,sec_count
	bne.s readlop
	rts

sec_start	ds.w 1
sec_count	ds.w 1
sec_side	ds.w 1
load_addr	ds.l 1

; Small code to read/write one sector
; On entry,a0=load/save address

track	dc.w 0
sector	dc.w 0

sec_track
	move.w	#$86,$ffff8606.w	Move head to track
	move.w	track,d1
	bsr	shove_fdc
	move.w	#$80,$ffff8606.w
	move.w	#$13,d1		
	bsr	shove_fdc
	bsr	wait_fdc
	bmi	error
	move.w	#$82,$ffff8606.w	Set track register
	move.w	track,d1
	bsr	shove_fdc
	rts

sec_load moveq	#2,d5		3 tries
err_loop	move.l	a0,d1
	move.b	d1,$ffff860d.w
	lsr.l	#8,d1
	move.b	d1,$ffff860b.w
	lsr.w	#8,d1
	move.b	d1,$ffff8609.w
	move.w	#$84,$ffff8606.w
	move.w	sector,d1	
	bsr	shove_fdc
	move.w	#$90,$ffff8606.w		Read sector
	move.w	#$190,$ffff8606.w
	move.w	#$90,$ffff8606.w
	move.w	#$1,d1		
	bsr	shove_fdc
	move.w	#$80,$ffff8606.w
	move.w	#$80,d1
	bsr	shove_fdc
	bsr	wait_fdc
	bmi	error
	move.w	$ffff8604.w,d1
	and.w	#$70,d1
	beq.s	ok
	dbf	d5,err_loop
	bra	error
ok	moveq	#0,d0
	rts
error	
	moveq	#-1,d0
	rts

shove_fdc
	bsr.s	.1
	move.w	d1,$ffff8604.w
.1	moveq	#32,d2
.2	dbf	d2,.2
	rts

wait_fdc
	moveq	#$4,d1
	swap	d1
.3	btst	#5,$fffffa01.w
	beq.s	.4
	subq.l	#1,d1
	bpl.s	.3
	rts
.4	moveq	#0,d1
	rts

side	tst.w sec_side
	bne select_1

select_0
	movem.l	d0-d1,-(a7)	Select side 0
	moveq	#5,d0	
	bra.s	sel

select_1
	movem.l	d0-d1,-(a7)	Select side 1
	moveq	#4,d0	

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

pak_st	dc.l 0

update_dep
	movem.l d0-a6,-(a7)
	move.l a6,d1
	sub.l pak_st,d1
	bsr hashing
	lea ascii+2,a0
	lea ramtop-$7d00+(160*192)+$60,a1
	bsr print
	movem.l (a7)+,d0-a6
	rts

reggies	ds.l 16

depack	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	; a4 = Anfang entpackte Daten
	move.l	a4,a6		; a6 = Ende entpackte Daten
	move.l a4,pak_st
	bsr.s	.getinfo
	cmpi.l	#'ICE!',d0	; Kennung gefunden?
	bne	.not_packed
	bsr.s	.getinfo	; gepackte LÑnge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	.getinfo	; ungepackte LÑnge holen (original)
	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a1

	moveq	#119,d0		; 120 Bytes hinter entpackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d0,.save
	move.l	a6,a3		; merken fÅr Picture decrunch
	move.b	-(a5),d7	; erstes Informationsbyte
	bsr.s	.normal_bytes
	move.l	a3,a5		; fÅr 120 Bytes restore

.no_picture
	movem.l	(sp),d0-a3	; hole nîtige Register

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		; um Åberschriebenen Bereich
.rest	move.b	-(a3),-(a5)	; wieder herzustellen
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1		; ein Langwort vom Anfang
.getbytes: lsl.l	#8,d0	; der Daten lesen
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
.nextgb:	move.l	-(a1),d0	; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
.copy_direkt:	
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,.copy_direkt	; noch ein Byte
	bsr update_dep
.test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht
	lea ascii,a0
	move.l #'0000',d1
	move.l d1,(a0)
	move.l d1,4(a0)
	lea ramtop-$7d00+(160*192)+$60,a1
	bsr print
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
	bsr update_dep
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
	even
ende_ice_decrunch_2:
	
files	dc.l 0
	dc.l scr1,scr2,scr3,scr4

tpoint	dc.l 0
tend	dc.l 0

; table format is:-
;
; word: start sector (0-800)
; word: number of sectors to load
; word: side number of file on disk (0/1)
; long: depack address
; bytes.... start of text
; byte -1 end of text
; all text padded on both ends by 10 spaces
;
; diskformat:-
; 10 sectors 80-tracks 2 sides
; first track is 0
; first sector is 1

; screen 1 - main menu
; screen 2 - reset demo
; screen 3 - beebris
; screen 4 - cycles

scr1	dc.w 11,42000/512
	dc.w 0
	dc.l $9000
	DC.B "           "
	DC.B "IT LOOKS LIKE THE APATHETIC GAMES MENU IS LOADING AND "
	DC.B "DECRUNCHING....  THERE WILL BE A SHORT DELAY AND THE "
	DC.B "SCREEN WILL GO BLACK.  "
	DC.B "THE QUIT TO THE DESKTOP OPTION WILL NOT WORK!!!   "
	DC.B "RESET IS NOW INSTALLED SO PUSH IT AT YOUR PERIL!   "
	DC.B "SORRY ABOUT NOT RELEASING TOTAL APATHY, "
	DC.B "BUT YOU KNOW HOW IT GOES....."
	DC.B "  ALL MENU CODING BY THE LAW... ALL MENU GFX BY XERUD...   "
	DC.B "           "
	dc.b -1
scr4	dc.w 93,11000/512
	dc.w 0
	dc.l $9000
scr2	dc.w 143,134000/512
	dc.w 0
	dc.l $9000
	DC.B "           "
	DC.B "BEEBRIS 2.71 IS LOADING....   HAVE FUN AND READ THE DOX    "
	DC.B "ALL CODE BY THE LAW....   GRAFIX BY VARIOUS....   PROTRACKER "
	DC.B "REPLAY BY GRIFF OF INNER CIRCLE....   "
	DC.B "           "
	dc.b -1
scr3	dc.w 403,28000/512
	dc.w 0
	dc.l $9000
	DC.B "           "	
	DC.B "LIGHT CYCLES....  IT'S OVER 14 MONTHS OLD, BUT WHAT THE HELL....   "
	DC.B "READ THE DOX....   ALL CODE BY THE LAW.... MUSIC BY NOODLE.... GFX BY XERUD....   "
	DC.B "           "
	dc.b -1
	even
scr5	dc.w 115,15000/512
	dc.w 0
	dc.l picture

reset_scrl
	move.w #1,scrl
	lea chbuff(pc),a0
	moveq.l #15,d0
.wipe	clr.l (a0)+
	dbra d0,.wipe
	rts

scrl	dc.w 1
tpnt	dc.l 0
chbuff	ds.l 16
scrladd	dc.l 0
stchar	dc.l 0
ststart	dc.l 0
	even

font	incbin font2.bin
music	incbin JETSET.MAX
	even

ptable	
adr	set font
	rept 20
	dc.l adr
	dc.l adr+1
adr	set adr+8
	endr
adr	set font+(160*8)
	rept 20
	dc.l adr
	dc.l adr+1
adr	set adr+8
	endr
picture	dc.l 0

freeram	dc.l 0