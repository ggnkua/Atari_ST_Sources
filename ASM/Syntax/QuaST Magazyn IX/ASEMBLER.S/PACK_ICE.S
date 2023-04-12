;*------------------------------------------------------------------------*
;*  QuaST Magazyn IX (C) 28.12.1975 QuaST Club / dysk #C - procedury *.S  *
;*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
;|																		  |
;|		Depack Pack Ice - rozpakowywanie danych spakowanych Pack Icem	  |
;|  																	  |
;| autor: ???		    											      |
;| uwagi: -	Pod adresem etykiety DATA powinny sie znajdowac dane		  |
;|          spakowanie Pack Icem										  |
;*------------------------------------------------------------------------*

DEPAKOWANIE:	lea		DATA,a0
				link 	a3,#-120
				movem.l	d0-a6,-(sp)
				lea 	120(a0),a4
				move.l 	a4,a6
				bsr.s 	.getinfo
				cmpi.l 	#'ICE!',d0
				bne 	.not_packed
				bsr.s 	.getinfo
				lea.l 	-8(a0,d0.l),a5
				bsr.s 	.getinfo
				move.l 	d0,(sp)
				adda.l 	d0,a6
				move.l 	a6,a1
				moveq 	#119,d0
.save:			move.b 	-(a1),-(a3)
				dbf 	d0,.save
				move.l 	a6,a3
				move.b 	-(a5),d7
				bsr.s 	.normal_bytes
				move.l 	a3,a5
.no_picture		movem.l	(sp),d0-a3
.move			move.b 	(a4)+,(a0)+
				subq.l 	#1,d0
				bne.s 	.move
				moveq 	#119,d0
.rest			move.b 	-(a3),-(a5)
				dbf 	d0,.rest
.not_packed:	movem.l	(sp)+,d0-a6
				unlk 	a3
				rts
.getinfo:	 	moveq 	#3,d1
.getbytes: 		lsl.l 	#8,d0
				move.b 	(a0)+,d0
				dbf 	d1,.getbytes
				rts
.normal_bytes:	bsr.s 	.get_1_bit
				bcc.s 	.test_if_end
				moveq.l	#0,d1
				bsr.s 	.get_1_bit
				bcc.s 	.copy_direkt
				lea.l 	.direkt_tab+20(pc),a1
				moveq.l	#4,d3
.nextgb:		move.l 	-(a1),d0
				bsr.s 	.get_d0_bits
				swap.w 	d0
				cmp.w 	d0,d1
				dbne 	d3,.nextgb
.no_more: 		add.l 	20(a1),d1
.copy_direkt:	move.b 	-(a5),-(a6)
				dbf 	d1,.copy_direkt
.test_if_end:	cmpa.l	a4,a6
				bgt.s 	.strings
				rts	
.get_1_bit:		add.b 	d7,d7
				bne.s 	.bitfound
				move.b 	-(a5),d7
				addx.b 	d7,d7
.bitfound:		rts	
.get_d0_bits:	moveq.l	#0,d1
.hole_bit_loop:	add.b 	d7,d7
				bne.s 	.on_d0
				move.b 	-(a5),d7
				addx.b 	d7,d7
.on_d0:			addx.w 	d1,d1
				dbf 	d0,.hole_bit_loop
				rts	
.strings: 		lea.l 	.length_tab(pc),a1
				moveq.l	#3,d2
.get_length_bit:bsr.s 	.get_1_bit
				dbcc 	d2,.get_length_bit
.no_length_bit:	moveq.l	#0,d4
				moveq.l	#0,d1
				move.b 	1(a1,d2.w),d0
				ext.w 	d0
				bmi.s 	.no_Åber
.get_Åber:		bsr.s 	.get_d0_bits
.no_Åber:		move.b 	6(a1,d2.w),d4
				add.w 	d1,d4
				beq.s 	.get_offset_2
				lea.l 	.more_offset(pc),a1
				moveq.l	#1,d2
.getoffs: 		bsr.s 	.get_1_bit
				dbcc 	d2,.getoffs
				moveq.l	#0,d1
				move.b 	1(a1,d2.w),d0
				ext.w 	d0
				bsr.s 	.get_d0_bits
				add.w 	d2,d2
				add.w 	6(a1,d2.w),d1
				bpl.s 	.depack_bytes
				sub.w 	d4,d1
				bra.s 	.depack_bytes
.get_offset_2:	moveq.l	#0,d1
				moveq.l	#5,d0
				moveq.l	#-1,d2
				bsr.s 	.get_1_bit
				bcc.s 	.less_40
				moveq.l	#8,d0
				moveq.l	#$3f,d2
.less_40: 		bsr.s 	.get_d0_bits
				add.w 	d2,d1
.depack_bytes:	lea.l 	2(a6,d4.w),a1
				adda.w	d1,a1
				move.b	-(a1),-(a6)
.dep_b:			move.b	-(a1),-(a6)
				dbf 	d4,.dep_b
				bra 	.normal_bytes
.direkt_tab:	dc.l 	$7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
				dc.l 	270-1,15-1,8-1,5-1,2-1	; Anz. Bytes
.length_tab:	dc.b 	9,1,0,-1,-1
				dc.b 	8,4,2,1,0
.more_offset:	dc.b 	11,4,7,0
				dc.w 	$11f,-1,$1f

*-+---------------------------------------------------------------------+-*

DATA:			* tu musza byc umieszczone dane do rozpakowania