
;**************************************
;*
;* project
;*
;* 3d-engine-code (c) 1996 by 
;* tarzan boy
;*
;**************************************

; pistdata erzeugt saemtliche benoetigten daten
; (gfx and info) fuer einen pistolentyp.
; dabei werden vier animationsstufen unterstuetzt:
;
; (1) waffe in anschlag
; (2) feuerstoss aus waffe
; (3) rueckstoff der waffe
; (4) nachladen der waffe
;
; saemtliche fuer einen waffentyp benoetigten
; informationen und filenamen werden durch
; ein jeweiliges include-file angegeben.
; dieses include-file ist in diesem
; quelltext weiter unten dann jeweils anzugeben.

		
		clr.w	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,savesp

		bsr	load_pistol_pic
		bsr	correct_black_pixel
		bsr	make_pistol_data
		bsr	save_pistol_pic

		move.l	savesp,-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)
		trap	#1


;**************************************

; truepaint speichert auf einmal einen
; schwarzen pixel als %0000000000100000,
; d.h. das unterste gruen-bit ist gesetzt.
; dieses wird korrigiert.

correct_black_pixel:

		lea	pistol_pic,a0
		
		move.w	#399,d0
cbp_l1:		move.w	#999,d1
cbp_l2:		cmpi.w	#%100000,(a0)+
		bne.s	cbp_not_black
		clr.w	-2(a0)
cbp_not_black:
		dbra	d1,cbp_l2
		dbra	d0,cbp_l1
		
		rts

;**************************************

save_pistol_pic:
		clr.w	-(sp)
		pea	pistol_dfile
		move.w	#60,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7

		pea	pistol_off2
		move.l	pistol_data_len,d0
		addi.l	#pistol_header_end-pistol_header,d0
		move.l	d0,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		
		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp

		rts


;**************************************

load_pistol_pic
		clr.w	-(sp)
		pea	pistol_pfile
		move.w	#61,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7

		pea	pistol_pic
		move.l	#300000,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp

		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp

		rts
		

;**************************************

make_pistol_data

		lea	anim_dat(pc),a0
		lea	pistol_data,a2
		lea	pistol_off2,a3
		lea	pistol_dat1,a5

		moveq	#3,d7
mpd_loop:
		move.l	(a0)+,d0
		beq.s	mpd_skip

		movea.l	d0,a1
		movem.l	d7/a0-a1/a3/a5,-(sp)
		bsr	make_one_pistol_data
		movem.l	(sp)+,d7/a0-a1/a3/a5

mpd_skip:
		addq.l	#8,a5
		addq.l	#4,a3

		dbra	d7,mpd_loop

		bsr	mpd_add_offsets

		rts

;---------------

mpd_add_offsets:

		movem.l	pistol_off2,d0-d3
		
		add.l	d0,d1
		add.l	d1,d2
		add.l	d2,d3

		movem.l	d0-d3,pistol_off2

		rts


;---------------

; a1: anim_datx
; a2: pistol_data
; a3: pistol_offx
; a5: pistol_datx

make_one_pistol_data:

		bsr	mopd_gfx_copy
		bsr	mopd_calc_offx
		bsr	mopd_copy_datx

		rts

;---

mopd_copy_datx:
		move.w	4(a1),(a5)+	; breite
		move.w	6(a1),(a5)+	; hoehe
		move.w	8(a1),(a5)+	; sxoffi
		move.w	10(a1),(a5)+	; flags

		rts

;---

mopd_calc_offx:
		move.w	4(a1),d0		; breite
		add.w	d0,d0
		mulu	6(a1),d0		; breite * hoehe

		move.l	d0,(a3)+		; pistol_offx

		rts

;---

; a1: anim_datx
; a2: pistol_data
; a3: pistol_offx

; kopiert die grafik (rechteckform) nach pistol_data

mopd_gfx_copy:
		lea	pistol_pic+128,a0
		
		move.w	2(a1),d0		; yoffi
		addq.w	#1,d0
		sub.w	6(a1),d0		; hoehe
		mulu	pic_breite,d0
		adda.l	d0,a0
		move.w	0(a1),d0		; xoffi
		add.w	d0,d0
		adda.w	d0,a0			; a0 = linke obere ecke

		move.w	6(a1),d0		; hoehe
		subq.w	#1,d0
mopdgc_loop:
		move.w	4(a1),d1		; breite
		subq.w	#1,d1
		movea.l	a0,a4
mopdgc_loop2:
		move.w	(a4)+,(a2)+
		dbra	d1,mopdgc_loop2

		move.w	pic_breite,d1
		add.w	d1,d1
		adda.w	d1,a0
	
		dbra	d0,mopdgc_loop

		rts

;**************************************

;**************************************


		data


		include	"e:\running\include\pistols\flm.s"


;**************************************

		bss


savesp		ds.l	1


pistol_pic	ds.b	400000

pistol_header:

pistol_off2	ds.l	1
pistol_off3	ds.l	1
pistol_off4	ds.l	1
pistol_data_len	ds.l	1

pistol_dat1	ds.w	4
pistol_dat2	ds.w	4
pistol_dat3	ds.w	4
pistol_dat4	ds.w	4

pistol_header_end:

pistol_data	ds.b	400000

		