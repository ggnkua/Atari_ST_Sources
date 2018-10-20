;GREYDITH
;Funktionen zum Dithern in Graustufen
;Parameter mÅssen alle vorher gesezt werden:
;d0=ZeilenzÑhler
;dif_x=zu dithernde Zeilenbreite
;d2=Planes Zeilendiff
;add_screen=Screen Zeilendiff
;scr_buf=Startadresse auf Screen
;a0-a2=Startadressen in Planes
;zoomout=0-n
;d0-d7/a0-a6 auf Stack

		.MC68030

.IMPORT add_screen, dif_x, screen_width, p_width, scr_buf

.EXPORT grey_dither, r_mul_table, g_mul_table, b_mul_table
.EXPORT zoomout, zoomin, first_zix, first_ziy, add_x, add_y, harmless

grey_dither:
		tst.w		harmless					;Userdef zeichnen?
		bne			no_zoom						;Ja->Zoomparameter ignorieren
		
		tst.w		zoomout
		bne			zo_grey_dither

		tst.w		zoomin
		bne			zi_grey_dither
		
no_zoom:
		move.l	scr_buf,a6				;Screenadresse
		move.l	add_screen,d6
		moveq.l	#16,d3

		lea			r_mul_table,a3
		lea			g_mul_table,a4
		lea			b_mul_table,a5
		
		moveq.l	#0,d5
		moveq.l	#0,d4
		
d_yloop:
		move.l	dif_x,d1

d_xloop:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.w	(a3,d4*2), d7					;mul

		move.b	(a1)+,d4							;GrÅn-Wert holen
		add.w		(a4, d4*2), d7				;mul

		move.b	(a2)+,d4							;Blau-Wert holen
		add.w		(a5, d4*2), d7				;mul

		lsr.w		#8,d7									;/256


;256 Graustufen
;		cmp.b		d3,d7									;d7 im AES-Bereich (16)?
;		bhs			no_offset							;Ne, drÅber
;		move.b	d3,d7									;Sonst auf 16 setzen
;no_offset:

;128 Graustufen
		lsr.w		#1,d7
		add.w		d3,d7


		move.b	d7,(a6)+		;Und ab in den Screen
		dbra		d1,d_xloop

;end_x
		adda.l	d2,a0
		adda.l	d2,a1
		adda.l	d2,a2
		adda.l	d6,a6
		dbra		d0,d_yloop
;end_all
		movem.l	(sp)+,d0-d7/a0-a6
		rts

;***********
;ZOOM-OUT-GREY
;***********

zo_grey_dither:
;Werte Ñndern:
;d0=ZeilenzÑhler -> /=(zoomout+1)
;dif_x=zu dithernde Zeilenbreite-1 -> /=(zoomout+1)
;d2=Planes Zeilendiff -> =word_width-(dif_x+1)*(zoomout+1)(Zeilenrest)
;													+word_width*zoomout             (Leerzeilen)
;add_screen=Screen Zeilendiff -> +=dif_x-dif_x/(zoomout+1)
		moveq.l	#0,d4
		move.w	zoomout,d4
		addq.w	#1,d4				;d4=zoomout+1

		divu.w	d4,d0				;d0/=(zoomout+1)

		move.l	dif_x,d5		;d5=dif_x
		move.l	d5,d1				;Merken fÅr nachher
		divu.w	d4,d5				;d5/=(zoomout+1)
		andi.l	#$0000ffff,d5	;Rest ausmakieren
		move.l	d5,dif_x		;dif_x neu

		sub.w		d5,d1				;d1=old_dif-new_dif
		add.l		d1,add_screen	;add_screen+=d1
		
		move.l	p_width,d2	;d2=plane_width
		move.l	dif_x,d5		;d5=dif_x
		addq.l	#1,d5				;d5++
		mulu.w	d4,d5				;d5=dif_x*(zoomout+1)
		sub.l		d5,d2				;d2=Zeilenrest

		move.l	p_width,d5	;d5=plane_width
		subq.w	#1,d4				;d4=zoomout
		mulu.w	d4,d5				;d5=plane_width*zoomout
		add.l		d5,d2				;d2+=plane_width*zoomout
		
		clr.l		d6
		move.w	zoomout,d6
		move.l	scr_buf,a6				;Screenadresse
		moveq.l	#16,d3

		lea			r_mul_table,a3
		lea			g_mul_table,a4
		lea			b_mul_table,a5
		
		moveq.l	#0,d5
		moveq.l	#0,d4
		
zo_d_yloop:
		move.l	dif_x,d1

zo_d_xloop:
		move.b	(a0)+,d4							;Rot-Wert holen
		move.w	(a3,d4*2), d7					;mul

		move.b	(a1)+,d4							;GrÅn-Wert holen
		add.w		(a4, d4*2), d7				;mul

		move.b	(a2)+,d4							;Blau-Wert holen
		add.w		(a5, d4*2), d7				;mul

		lsr.w		#8,d7									;/256


;256 Graustufen
;		cmp.b		d3,d7									;d7 im AES-Bereich (16)?
;		bhs			no_offset							;Ne, drÅber
;		move.b	d3,d7									;Sonst auf 16 setzen
;no_offset:

;128 Graustufen
		lsr.w		#1,d7
		add.w		d3,d7


		move.b	d7,(a6)+		;Und ab in den Screen
		adda.l	d6,a0				;Zoomverschiebung
		adda.l	d6,a1
		adda.l	d6,a2
		dbra		d1,zo_d_xloop

;end_x
		adda.l	d2,a0
		adda.l	d2,a1
		adda.l	d2,a2
		adda.l	add_screen,a6
		dbra		d0,zo_d_yloop
;end_all:
		movem.l	(sp)+,d0-d7/a0-a6
		rts


;***********
;ZOOM-IN-GREY
;***********

zi_grey_dither:
;Werte Ñndern:
;d0=ZeilenzÑhler -> *=(zoomin+1) +=add_y
;dif_x=zu dithernde Zeilenbreite-1 -> *=(zoomin+1)
;d2=Planes Zeilendiff -> =word_width (weil in x-loop nix addiert wird)
;add_screen=Screen Zeilendiff -> =screen_width-dif_x
		moveq.l	#0,d4
		move.w	zoomin,d4
		addq.w	#1,d4				;d4=zoomin+1

		mulu.w	d4,d0				;d0*=(zoomin+1)
		add.w		add_y,d0
		
		move.l	dif_x,d5		;d5=dif_x
		mulu.w	d4,d5				;d5*=(zoomin+1)
		add.w		add_x,d5
		move.l	d5,dif_x		;dif_x neu

		move.l	screen_width,d1
		sub.l		d5,d1				;d1=screen_width-new_dif
		subq.l	#1,d1
		move.l	d1,add_screen	;add_screen=d1
		
		move.l	p_width,d2	;d2=plane_width

		move.l	scr_buf,a6				;Screenadresse

		lea			r_mul_table,a3
		lea			g_mul_table,a4
		lea			b_mul_table,a5
		
		moveq.l	#0,d5
		moveq.l	#0,d4
		
		move.w	first_ziy,d6
		swap		d6
zi_d_yloop:
		move.l	dif_x,d1
		move.w	first_zix,d6
		moveq.l	#0,d3
zi_d_xloop:
		move.b	(a0,d3.w),d4							;Rot-Wert holen
		move.w	(a3,d4*2), d7					;mul

		move.b	(a1,d3.w),d4							;GrÅn-Wert holen
		add.w		(a4, d4*2), d7				;mul

		move.b	(a2,d3.w),d4							;Blau-Wert holen
		add.w		(a5, d4*2), d7				;mul

		lsr.w		#8,d7									;/256

		lsr.w		#1,d7
		add.w		#16,d7

		move.b	d7,(a6)+		;Und ab in den Screen
		dbra		d6,zi_cont_x		;Zoomverschiebung?
		addq.l	#1,d3						;Zoomverschiebung
		move.w	zoomin,d6
zi_cont_x:
		dbra		d1,zi_d_xloop

;end_x
		swap		d6
		dbra		d6,zi_cont_y	;Zoomverschiebung?
		adda.l	d2,a0					;Ja
		adda.l	d2,a1
		adda.l	d2,a2
		move.w	zoomin,d6
zi_cont_y:
		swap		d6
		adda.l	add_screen,a6
		dbra		d0,zi_d_yloop
;end_all:
		movem.l	(sp)+,d0-d7/a0-a6
		rts


r_mul_table:
	.DS.W	256
g_mul_table:
	.DS.W	256
b_mul_table:
	.DS.W	256
	
zoomout:
	.DS.W 1
zoomin:
	.DS.W 1
first_zix:
	.DS.W 1
first_ziy:
	.DS.W 1
add_x:
	.DS.W 1
add_y:
	.DS.W 1
harmless:
	.DS.W 1