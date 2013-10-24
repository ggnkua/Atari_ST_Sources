	opt	o+,ow-,a+		; Optimierung einschalten

FLASH_COLOUR	equ	0
start:	movea.l	#stackend,sp
	move.l	sp,d0
	subi.l	#start-$120,d0
	move.l	d0,-(sp)
	pea	start-$100(pc)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	adda.w	#$c,sp

	pea	mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	bsr	super
	move.b	#$12,$fffffc02.w
	move.l	$84.w,old_trap1+2	;store & change TRAP #1 vector
	move.l	#my_trap1,$84.w
	bsr	user
	pea	null(pc)
	pea	null(pc)
	pea	file_name(pc)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea.l	16(sp),sp
	bsr	super
	move.l	old_trap1+2(pc),$84.w
	bsr	user
	clr.w	-(sp)
	trap	#1

null:	dc.l 0,0

file_name:	dc.b 'P_BASE.EXE',0	; nachgeladenes Programm (pexec)
	EVEN 

mess	dc.b	27,'E'
	dc.b	27,'Y',32+10,32+(40-31)/2,"SLAYTANIC CULTS POWER BASS DEMO"
	dc.b	27,'Y',32+12,32+(40-9)/2,"Packed by"
	dc.b	27,'Y',32+14,32+14,"MAC SYS DATA"
	dc.b	27,'Y',32+16,32+16,"31-8-91"
 dc.b	27,'Y',32+19,32+(40-33)/2,"What can I say.. simply BRILLIANT"
	dc.b	0
	even

super:	clr.l	-(sp)		;supervisor state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7
	rts	
user:	move.l	d7,-(sp)		;user state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts	

my_trap1: 
	movea.l	sp,a0
	btst	#$d,(sp)
	bne.s	supervisor
	move.l	usp,a0
	subq.l	#6,a0
supervisor:	
	addq.l	#6,a0
	cmpi.w	#$3f,(a0) 	; read
	beq.s	func_3f

******** HISOFT BASIC FRIG
;;	cmpi.w	#$42,(a0)
;;	bne.s	old_trap1
;frig for seek to end of file (for file length to load)
;;	cmp.w	#2,8(a0)	;seek to end of file
;;	bne.s	old_trap1
;;	move.l	8(a0),loadadr
;;	move.l	2(sp),frig_jmp+2
;;	move.l	#seek_frig,2(sp)


old_trap1
	jmp	0.l

;;seek_frig
;;	move.l	a0,-(sp)
;;	move.l	length_table_pos,a0
;;	move.l	(a0)+,d0		;put new length in D0.L
;;	move.l	a0,length_table_pos
;;	move.l	(sp)+,a0
;;frig_jmp
;;	jmp	0.l

;;length_table_pos	dc.l	length_table
;;length_table
;;	dc.l	32000	;JARRE.PIC
;;	dc.l	2757	;JARRE.EXE
;;	dc.l	74725	;JARRE_01.SPL
;;	dc.l	135480	;JARRE_02.SPL
;;	dc.l	109086	;JARRE_03.SPL


func_3f

************* MASTERSOUND xtra bit ************
;	cmp.l	#4,6(a0)	;is 4 bytes load for MASTERSOUND?
;	beq.s	old_trap1	;YES!

***********************************************


	move.l	8(a0),puffer
	move.l	2(sp),ret_addr5+2	; Returnadresse
	move.l	#read,2(sp)
	bra.s	old_trap1

read:	tst.w	2(sp)
	bmi.s	ret_addr5 	; device handle->do nothing
	movem.l	d1-d7/a0-a6,-(sp)

	move.w	#-1,-(sp)	;get old colour
	move.w	#FLASH_COLOUR,-(sp)	;colour number
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	d0,old_colour+2

	movea.l	puffer(pc),a0	; Puffer
	bsr	decrunch

old_colour
	move.w	#0,-(sp)
	move.w	#FLASH_COLOUR,-(sp)	;colour number
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp

	movem.l	(sp)+,d1-d7/a0-a6
ret_addr5
	jmp	0.l

;********************************************* Unpackroutine von ICE-PACK
; Eingabe: a0 = Adresse gepackter Daten
decrunch
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	; a4 = Anfang entpackte Daten
	move.l	a4,a6		; a6 = Ende entpackte Daten
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

	bsr.s	.get_1_bit	;; Picture decrunch!
	bcc.s	.no_picture	;; These marked lines may be
	move.w	#$0f9f,d7 	;; removed in your own sources
.ice_00	moveq	#3,d6		;; if you do not use the
.ice_01	move.w	-(a3),d4	;; additional algorithm.
	moveq	#3,d5		;;
.ice_02	add.w	d4,d4	;;
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

.getinfo
	moveq	#3,d1		; ein Langwort vom Anfang
.getbytes
	lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb	move.l	-(a1),d0	; d0.w Bytes lesen
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
	bgt.s	.strings	; Weiter wenn Ende nicht erreicht
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schluû

.get_1_bit
	add.b	d7,d7		; hole ein bit
	bne.s	.bitfound 	; quellfeld leer
	move.b	-(a5),d7	; hole Informationsbyte
	addx.b	d7,d7
.bitfound
	rts	

.get_d0_bits	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop	
	add.b	d7,d7		; hole ein bit
	bne.s	.on_d0		; in d7 steht noch Information
	move.b	-(a5),d7	; hole Informationsbyte

	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d7,-(sp)
	move.w	#FLASH_COLOUR,-(sp)
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-d7/a0-a6

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

ende_ice_decrunch_2:
;*************************************************** Ende der Unpackroutine

	section	bss
puffer:		ds.l 1
		ds.b 500
stackend: 	ds.b 20


