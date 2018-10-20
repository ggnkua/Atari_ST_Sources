;Speed-Fill: rekursives FÅllen

;<buf> muû genauso groû wie eine plane sein plus eine Zeile oben
;und unten die mit <1> gefÅllt werden und eine Spalte ganz rechts
;ebenfalls mit 1 gefÅllt

;stack muû vier mal so groû wie eine Plane sein

;buf=Pufferaddresse am Startpunkt
;cc,mm,yy=Planeadressen am Startpunkt
;line:Zeilenbreite einer Plane
;min/max: Minimale/Maximale erlaubte Farbwerte

;x und y: ABsolute Startkoordinaten in der Plane
;RÅckgabe: buf=0 da nicht fÅllen, buf=1: da fÅllen
;minx/maxx: kleinster/grîûter X-Wert an dem es was zu fÅllen gibt
;miny/maxy: kleinster/grîûter Y-Wert an dem es was zu fÅllen gibt

.EXPORT	sf_stack,	sf_buf,	sf_cc, sf_mm,	sf_yy
.EXPORT	sf_cmin,sf_cmax,sf_mmin,sf_mmax,sf_ymin,sf_ymax
.EXPORT sf_line
.EXPORT sf_x, sf_y, sf_minx, sf_maxx, sf_miny, sf_maxy
.EXPORT as_speed_fill
.EXPORT sf_debug, sf_debug2

as_speed_fill:
	movem.l	d0-d7/a0-a6,-(sp)
	
;Initialisieren:
	move.l	sf_buf,a0
	move.l	sf_cc,a1
	move.l	sf_mm,a2
	move.l	sf_yy,a3
	moveq.l	#0,d0
	move.w	sf_line,d0	;sf_line holen
	move.l	d0,a6				;Einfachen Wert in a4 sichern
	
	move.b	sf_cmin,d0
	move.b	sf_cmax,d1
	move.b	sf_mmin,d2
	move.b	sf_mmax,d3
	move.b	sf_ymin,d4
	move.b	sf_ymax,d5
	
	move.l	#0,a4				;X-ZÑhler
	move.l	#0,a5				;Y-ZÑhler
	move.w	sf_x,a4
	move.w	sf_y,a5
	move.w	a4,sf_minx
	move.w	a4,sf_maxx
	move.w	a5,sf_miny
	move.w	a5,sf_maxy
	moveq.l	#0,d6				;X-Compare
	moveq.l	#0,d7				;Y-Compare
	move.w	sf_minx,d6	;minx
	swap		d6
	move.w	sf_maxx,d6	;maxx
	swap		d6
	move.w	sf_miny,d7
	swap		d7
	move.w	sf_maxy,d7
	swap		d7
	
	move.l	a7,sav_sp
	move.l	sf_stack,a7

;Falls alle min/max-Werte gleich sind, Turbo-Mode benutzen:
	cmp.b		d0,d1
	bne			compared_fill
	cmp.b		d2,d3
	bne			compared_fill
	cmp.b		d4,d5
	bne			compared_fill
;uncompared fill:
	bsr			turbo_fill_it
	bra			end_fill
;else:
compared_fill:
	bsr			fill_it

end_fill:
	move.w	d6,sf_minx
	swap		d6
	move.w	d6,sf_maxx
	move.w	d7,sf_miny
	swap		d7
	move.w	d7,sf_maxy
		
	move.l	sav_sp, a7
	movem.l	(sp)+,d0-d7/a0-a6
	
	rts
	

;FÅll-Routine fÅr ein Pixel:
	
fill_it:
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;move.b	#1,(a6)
;move.l	debug_buf,a6

;Eins in Puffer schreiben:
	move.b	#1,(a0)

;Mit Minx/Maxx vergleichen:
	cmp.w		a4,d6
	bcs			x_not_smaller
	move.w	a4,d6				;Sonst min_x merken
x_not_smaller:
	swap		d6
	cmp.w		a4,d6
	bhi			x_not_higher
	move.w	a4,d6				;Sonst max_x merken
x_not_higher:
	swap		d6
	
;Mit Miny/Maxy vergleichen:
	cmp.w		a5,d7	
	bcs			y_not_smaller
	move.w	a5,d7				;Sonst min_y merken
y_not_smaller:
	swap		d7
	cmp.w		a5,d7
	bhi			y_not_higher
	move.w	a5,d7				;Sonst max_y merken
y_not_higher:
	swap		d7
	
;Links prÅfen:
	subq.l	#1,a0
	subq.l	#1,a1
	subq.l	#1,a2
	subq.l	#1,a3
	subq.l	#1,a4		;X-ZÑhler
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;subq.l	#1,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6
	
;Puffer schon beschrieben?
	tst.b		(a0)
	bne			end_left	;Ja->Ende		
	cmp.b		(a1),d0		;Cmin testen
	bhi			end_left	;d0 ist grîûer
	cmp.b		(a1),d1		;Cmax testen
	bcs			end_left	;d1 ist kleiner
	cmp.b		(a2),d2		;Mmin testen
	bhi			end_left	;d2 ist grîûer
	cmp.b		(a2),d3		;Mmax testen
	bcs			end_left	;d3 ist kleiner
	cmp.b		(a3),d4		;Ymin testen
	bhi			end_left	;d4 ist grîûer
	cmp.b		(a3),d5		;Ymax testen
	bcs			end_left	;d5 ist kleiner
;Ok, fÅllen
	bsr			fill_it

end_left:
;Alte Position wieder herstellen
	addq.l	#1,a0
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;addq.l	#1,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Oben prÅfen:
	suba.l	a6,a0
	suba.l	a6,a1
	suba.l	a6,a2
	suba.l	a6,a3
	subq.l	#1,a5	;Y-ZÑhler
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;suba.l	sf_debug2,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Puffer schon beschrieben?
	tst.b		(a0)
	bne			end_upper	;Ja->Ende		
	cmp.b		(a1),d0		;Cmin testen
	bhi			end_upper	;d0 ist grîûer
	cmp.b		(a1),d1		;Cmax testen
	bcs			end_upper	;d1 ist kleiner
	cmp.b		(a2),d2		;Mmin testen
	bhi			end_upper	;d2 ist grîûer
	cmp.b		(a2),d3		;Mmax testen
	bcs			end_upper	;d3 ist kleiner
	cmp.b		(a3),d4		;Ymin testen
	bhi			end_upper	;d4 ist grîûer
	cmp.b		(a3),d5		;Ymax testen
	bcs			end_upper	;d5 ist kleiner
;Ok, fÅllen
	bsr			fill_it

end_upper:
	adda.l	a6,a0
	adda.l	a6,a1
	adda.l	a6,a2
	adda.l	a6,a3
	addq.l	#1,a5
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;adda.l	sf_debug2,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Rechts prÅfen:

	addq.l	#1,a0
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;addq.l	#1,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Puffer schon beschrieben?
	tst.b		(a0)
	bne			end_right	;Ja->Ende		
	cmp.b		(a1),d0		;Cmin testen
	bhi			end_right	;d0 ist grîûer
	cmp.b		(a1),d1		;Cmax testen
	bcs			end_right	;d1 ist kleiner
	cmp.b		(a2),d2		;Mmin testen
	bhi			end_right	;d2 ist grîûer
	cmp.b		(a2),d3		;Mmax testen
	bcs			end_right	;d3 ist kleiner
	cmp.b		(a3),d4		;Ymin testen
	bhi			end_right	;d4 ist grîûer
	cmp.b		(a3),d5		;Ymax testen
	bcs			end_right	;d5 ist kleiner
;Ok, fÅllen
	bsr			fill_it

end_right:
;Alte Position wieder herstellen

	subq.l	#1,a0
	subq.l	#1,a1
	subq.l	#1,a2
	subq.l	#1,a3
	subq.l	#1,a4
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;subq.l	#1,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;unten prÅfen:

	adda.l	a6,a0
	adda.l	a6,a1
	adda.l	a6,a2
	adda.l	a6,a3
	addq.l	#1,a5
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;adda.l	sf_debug2,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Puffer schon beshrieben?
	tst.b		(a0)
	bne			end_lower	;Ja->Ende		
	cmp.b		(a1),d0		;Cmin testen
	bhi			end_lower	;d0 ist grîûer
	cmp.b		(a1),d1		;Cmax testen
	bcs			end_lower	;d1 ist kleiner
	cmp.b		(a2),d2		;Mmin testen
	bhi			end_lower	;d2 ist grîûer
	cmp.b		(a2),d3		;Mmax testen
	bcs			end_lower	;d3 ist kleiner
	cmp.b		(a3),d4		;Ymin testen
	bhi			end_lower	;d4 ist grîûer
	cmp.b		(a3),d5		;Ymax testen
	bcs			end_lower	;d5 ist kleiner
;Ok, fÅllen
	bsr			fill_it

end_lower:
;Alte Position wieder herstellen
	suba.l	a6,a0
	suba.l	a6,a1
	suba.l	a6,a2
	suba.l	a6,a3
	subq.l	#1,a5
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;suba.l	sf_debug2,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

	rts
	

; Turbo-Funktion. Wie oben aber mit nur einem Compare pro Farbe
; Aufrufen wenn alle min/max gleich sind
;FÅll-Routine fÅr ein Pixel:
	
turbo_fill_it:
t_fill_it:
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;move.b	#1,(a6)
;move.l	debug_buf,a6

;Eins in Puffer schreiben:
	move.b	#1,(a0)

;Mit Minx/Maxx vergleichen:
	cmp.w		a4,d6
	bcs			t_x_not_smaller
	move.w	a4,d6				;Sonst min_x merken
t_x_not_smaller:
	swap		d6
	cmp.w		a4,d6
	bhi			t_x_not_higher
	move.w	a4,d6				;Sonst max_x merken
t_x_not_higher:
	swap		d6
	
;Mit Miny/Maxy vergleichen:
	cmp.w		a5,d7	
	bcs			t_y_not_smaller
	move.w	a5,d7				;Sonst min_y merken
t_y_not_smaller:
	swap		d7
	cmp.w		a5,d7
	bhi			t_y_not_higher
	move.w	a5,d7				;Sonst max_y merken
t_y_not_higher:
	swap		d7
	
;Links prÅfen:
	subq.l	#1,a0
	subq.l	#1,a1
	subq.l	#1,a2
	subq.l	#1,a3
	subq.l	#1,a4		;X-ZÑhler
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;subq.l	#1,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6
	
;Puffer schon beschrieben?
	tst.b		(a0)
	bne			t_end_left	;Ja->Ende		
	cmp.b		(a1),d0		;Cmin testen
	bne			t_end_left	;d0 ist grîûer
	cmp.b		(a2),d2		;Mmin testen
	bne			t_end_left	;d2 ist grîûer
	cmp.b		(a3),d4		;Ymin testen
	bne			t_end_left	;d4 ist grîûer
;Ok, fÅllen
	bsr			t_fill_it

t_end_left:
;Alte Position wieder herstellen
	addq.l	#1,a0
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;addq.l	#1,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Oben prÅfen:
	suba.l	a6,a0
	suba.l	a6,a1
	suba.l	a6,a2
	suba.l	a6,a3
	subq.l	#1,a5	;Y-ZÑhler
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;suba.l	sf_debug2,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Puffer schon beschrieben?
	tst.b		(a0)
	bne			t_end_upper	;Ja->Ende		
	cmp.b		(a1),d0		;Cmin testen
	bne			t_end_upper	;d0 ist grîûer
	cmp.b		(a2),d2		;Mmin testen
	bne			t_end_upper	;d2 ist grîûer
	cmp.b		(a3),d4		;Ymin testen
	bne			t_end_upper	;d4 ist grîûer
;Ok, fÅllen
	bsr			t_fill_it

t_end_upper:
	adda.l	a6,a0
	adda.l	a6,a1
	adda.l	a6,a2
	adda.l	a6,a3
	addq.l	#1,a5
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;adda.l	sf_debug2,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Rechts prÅfen:

	addq.l	#1,a0
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;addq.l	#1,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Puffer schon beschrieben?
	tst.b		(a0)
	bne			t_end_right	;Ja->Ende		
	cmp.b		(a1),d0		;Cmin testen
	bne			t_end_right	;d0 ist grîûer
	cmp.b		(a2),d2		;Mmin testen
	bne			t_end_right	;d2 ist grîûer
	cmp.b		(a3),d4		;Ymin testen
	bne			t_end_right	;d4 ist grîûer
;Ok, fÅllen
	bsr			t_fill_it

t_end_right:
;Alte Position wieder herstellen

	subq.l	#1,a0
	subq.l	#1,a1
	subq.l	#1,a2
	subq.l	#1,a3
	subq.l	#1,a4
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;subq.l	#1,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;unten prÅfen:

	adda.l	a6,a0
	adda.l	a6,a1
	adda.l	a6,a2
	adda.l	a6,a3
	addq.l	#1,a5
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;adda.l	sf_debug2,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

;Puffer schon beshrieben?
	tst.b		(a0)
	bne			t_end_lower	;Ja->Ende		
	cmp.b		(a1),d0		;Cmin testen
	bne			t_end_lower	;d0 ist grîûer
	cmp.b		(a2),d2		;Mmin testen
	bne			t_end_lower	;d2 ist grîûer
	cmp.b		(a3),d4		;Ymin testen
	bne			t_end_lower	;d4 ist grîûer
;Ok, fÅllen
	bsr			t_fill_it

t_end_lower:
;Alte Position wieder herstellen
	suba.l	a6,a0
	suba.l	a6,a1
	suba.l	a6,a2
	suba.l	a6,a3
	subq.l	#1,a5
	
;move.l	a6,debug_buf
;move.l	sf_debug,a6
;suba.l	sf_debug2,a6
;move.l	a6,sf_debug
;move.l	debug_buf,a6

	rts



sf_stack:
	.DS.L	1
sf_buf:
	.DS.L	1
sf_cc:
	.DS.L	1
sf_mm:
	.DS.L	1
sf_yy:
	.DS.L	1

sf_cmin:
	.DS.B	1
sf_cmax:
	.DS.B	1
sf_mmin:
	.DS.B	1
sf_mmax:
	.DS.B	1
sf_ymin:
	.DS.B	1
sf_ymax:
	.DS.B	1
	
sf_line:
	.DS.W	1

sf_x:
	.DS.W 1
sf_y:
	.DS.W 1
sf_minx:
	.DS.W 1
sf_maxx:
	.DS.W 1
sf_miny:
	.DS.W 1
sf_maxy:
	.DS.W 1
	

sf_debug:
	.DS.L	1
sf_debug2:
	.DS.L	1
debug_buf:
	.DS.L	1
		
sav_sp:
	.DS.L	1