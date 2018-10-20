;IFill: iteratives Fllen

.EQU debug,0


;<buf> mu genauso gro wie eine plane sein plus eine Zeile oben
;und unten die mit <15> gefllt werden und eine Spalte ganz rechts
;ebenfalls mit 15 gefllt

;buf=Pufferaddresse am Startpunkt
;cc,mm,yy=Planeadressen am Startpunkt
;line:Zeilenbreite einer Plane
;min/max: Minimale/Maximale erlaubte Farbwerte

;x und y: ABsolute Startkoordinaten in der Plane
;Rckgabe: buf=0 da nicht fllen, buf=1: da fllen
;minx/maxx: kleinster/gr”ter X-Wert an dem es was zu fllen gibt
;miny/maxy: kleinster/gr”ter Y-Wert an dem es was zu fllen gibt

.EXPORT	if_stack,	if_buf,	if_cc, if_mm,	if_yy
.EXPORT	if_cmin,if_cmax,if_mmin,if_mmax,if_ymin,if_ymax
.EXPORT if_line, if_mline;
.EXPORT if_x, if_y, if_minx, if_maxx, if_miny, if_maxy
.EXPORT as_iter_fill
.EXPORT if_debug, if_debug2

as_iter_fill:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a7,sav_sp
	
;Initialisieren:
	move.l	if_buf,a0
	move.l	if_cc,a1
	move.l	if_mm,a2
	move.l	if_yy,a3

	moveq.l	#0,d3
	moveq.l	#0,d4
	move.w	if_line,d3	;if_line holen
	move.w	if_mline,d4	;Negative Wert holen
	
	move.w	#0,d5				;went_to-Wert
	
	moveq.l	#0,d0				;Min und Max-Werte in d0-d2(unten min, oben max)
	moveq.l	#0,d1
	moveq.l	#0,d2

	move.b	if_cmax,d0
	swap		d0
	move.b	if_cmin,d0

	move.b	if_mmax,d1
	swap		d1
	move.b	if_mmin,d1

	move.b	if_ymax,d2
	swap		d2
	move.b	if_ymin,d2
	
	move.l	#0,a4				;X-Z„hler
	move.l	#0,a5				;Y-Z„hler
	move.w	if_x,a4
	move.w	if_y,a5
	move.w	a4,if_minx
	move.w	a4,if_maxx
	move.w	a5,if_miny
	move.w	a5,if_maxy
	moveq.l	#0,d6				;X-Compare
	moveq.l	#0,d7				;Y-Compare
	move.w	if_minx,d6	;minx
	swap		d6
	move.w	if_maxx,d6	;maxx
	swap		d6
	move.w	if_miny,d7
	swap		d7
	move.w	if_maxy,d7
	swap		d7
	


;Falls alle min/max-Werte gleich sind, Turbo-Mode benutzen:
	cmp.b		if_cmax,d0
	bne			compared_fill
	cmp.b		if_mmax,d1
	bne			compared_fill
	cmp.b		if_ymax,d2
	bne			compared_fill
;uncompared fill:
	bsr			turbo_fill_it
	bra			end_fill
;else:
compared_fill:
	bsr			fill_it

end_fill:
	move.w	d6,if_minx
	swap		d6
	move.w	d6,if_maxx
	move.w	d7,if_miny
	swap		d7
	move.w	d7,if_maxy
		
	move.l	sav_sp, a7
	movem.l	(sp)+,d0-d7/a0-a6
	
	rts
	

;Fll-Routine fr ein Pixel:
	
fill_it:
.IF debug = 1
move.l	a6,debug_buf
move.l	if_debug,a6
add.b		#1,(a6)
move.l	debug_buf,a6
.ENDIF
	
;Links prfen:
;Wurde links schon getestet?
	btst		#0,(a0)
	bne			end_left	;Ja->Ende
;Sonst links_getestet setzen
	ori.b		#1,(a0)
;War ich links schonmal?
	tst.b		-1(a0)
	bne			end_left	;Ja->Ende
;Sonst gucken, ob Farbe links ok ist
;Cyan
	cmp.b		-1(a1),d0			;Cmin testen
	bhi			end_left			;ist gr”er
	swap		d0						;Max-Wert holen
	cmp.b		-1(a1),d0			;Cmax testen
	bcs			sd0_end_left	;ist kleiner
;Magenta	
	cmp.b		-1(a2),d1			;Mmin testen
	bhi			sd0_end_left	;ist gr”er
	swap		d1
	cmp.b		-1(a2),d1			;Mmax testen
	bcs			sd1_end_left	;ist kleiner
;Yellow
	cmp.b		-1(a3),d2			;Ymin testen
	bhi			sd1_end_left	;ist gr”er
	swap		d2
	cmp.b		-1(a3),d2			;Ymax testen
	bcs			sd2_end_left	;ist kleiner
;Ok, fllen
	swap		d0
	swap		d1
	swap		d2
	or.b		d5,(a0)				;went_to vermerken
	subq.l	#1,a0
	subq.l	#1,a1
	subq.l	#1,a2
	subq.l	#1,a3
	subq.l	#1,a4		;X-Z„hler
.IF debug = 1
move.l	a6,debug_buf
move.l	if_debug,a6
subq.l	#1,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF

;X < Min_x?
	cmp.w		a4,d6
	bcs			x_not_smaller
	move.w	a4,d6				;Sonst min_x merken
x_not_smaller:
	moveq.l	#16,d5			;went_to auf 16 setzen
	bra			fill_it			;und das Spiel von vorne
	
sd2_end_left:
	swap		d2
sd1_end_left:
	swap		d1
sd0_end_left:
	swap		d0	
end_left:

;Oben prfen:
;Wurde oben schon getestet?
	btst		#1,(a0)
	bne			end_upper	;Ja->Ende
;Sonst oben_getestet setzen
	ori.b		#2,(a0)
;War ich oben schonmal?
	tst.b		(a0,d4) 	;d4=-lwidth
	bne			end_upper	;Ja->Ende
;Sonst gucken, ob Farbe oben ok ist
;Cyan
	cmp.b		(a1,d4),d0			;Cmin testen
	bhi			end_upper				;ist gr”er
	swap		d0							;Max-Wert holen
	cmp.b		(a1,d4),d0			;Cmax testen
	bcs			sd0_end_upper		;ist kleiner
;Magenta	
	cmp.b		(a2,d4),d1			;Mmin testen
	bhi			sd0_end_upper		;ist gr”er
	swap		d1
	cmp.b		(a2,d4),d1			;Mmax testen
	bcs			sd1_end_upper		;ist kleiner
;Yellow
	cmp.b		(a3,d4),d2			;Ymin testen
	bhi			sd1_end_upper		;ist gr”er
	swap		d2
	cmp.b		(a3,d4),d2			;Ymax testen
	bcs			sd2_end_upper		;ist kleiner
;Ok, fllen
	swap		d0
	swap		d1
	swap		d2
	or.b		d5,(a0)				;went_to vermerken
	sub.l		d3,a0
	sub.l		d3,a1
	sub.l		d3,a2
	sub.l		d3,a3
	subq.l	#1,a5		;Y-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
sub.l		if_debug2,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF

;Y < Min_y?
	cmp.w		a5,d7
	bcs			y_not_smaller
	move.w	a5,d7				;Sonst min_y merken
y_not_smaller:
	moveq.l	#32,d5			;went_to auf 32 setzen
	bra			fill_it			;und das Spiel von vorne
	
sd2_end_upper:
	swap		d2
sd1_end_upper:
	swap		d1
sd0_end_upper:
	swap		d0	
end_upper:

;Rechts prfen:
;Wurde rechts schon getestet?
	btst		#2,(a0)
	bne			end_right	;Ja->Ende
;Sonst rechts_getestet setzen
	ori.b		#4,(a0)
;War ich rechts schonmal?
	tst.b		1(a0)
	bne			end_right	;Ja->Ende
;Sonst gucken, ob Farbe rechts ok ist
;Cyan
	cmp.b		1(a1),d0			;Cmin testen
	bhi			end_right			;ist gr”er
	swap		d0						;Max-Wert holen
	cmp.b		1(a1),d0			;Cmax testen
	bcs			sd0_end_right	;ist kleiner
;Magenta	
	cmp.b		1(a2),d1			;Mmin testen
	bhi			sd0_end_right	;ist gr”er
	swap		d1
	cmp.b		1(a2),d1			;Mmax testen
	bcs			sd1_end_right	;ist kleiner
;Yellow
	cmp.b		1(a3),d2			;Ymin testen
	bhi			sd1_end_right	;ist gr”er
	swap		d2
	cmp.b		1(a3),d2			;Ymax testen
	bcs			sd2_end_right	;ist kleiner
;Ok, fllen
	swap		d0
	swap		d1
	swap		d2
	or.b		d5,(a0)				;went_to vermerken
	addq.l	#1,a0
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4		;X-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
addq.l	#1,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF

;X > Maxx prfen
	swap		d6
	cmp.w		a4,d6
	bhi			x_not_higher
	move.w	a4,d6				;Sonst max_x merken
x_not_higher:
	swap		d6
	moveq.l	#64,d5			;went_to auf 16 setzen
	bra			fill_it			;und das Spiel von vorne
	
sd2_end_right:
	swap		d2
sd1_end_right:
	swap		d1
sd0_end_right:
	swap		d0	
end_right:

;Unten prfen:
;Wurde unten schon getestet?
	btst		#3,(a0)
	bne			end_lower	;Ja->Ende
;Sonst unten_getestet setzen
	ori.b		#8,(a0)
;War ich unten schonmal?
	tst.b		(a0,d3) 	;d3=+lwidth
	bne			end_lower	;Ja->Ende
;Sonst gucken, ob Farbe unten ok ist
;Cyan
	cmp.b		(a1,d3),d0			;Cmin testen
	bhi			end_lower				;ist gr”er
	swap		d0							;Max-Wert holen
	cmp.b		(a1,d3),d0			;Cmax testen
	bcs			sd0_end_lower		;ist kleiner
;Magenta	
	cmp.b		(a2,d3),d1			;Mmin testen
	bhi			sd0_end_lower		;ist gr”er
	swap		d1
	cmp.b		(a2,d3),d1			;Mmax testen
	bcs			sd1_end_lower		;ist kleiner
;Yellow
	cmp.b		(a3,d3),d2			;Ymin testen
	bhi			sd1_end_lower		;ist gr”er
	swap		d2
	cmp.b		(a3,d3),d2			;Ymax testen
	bcs			sd2_end_lower		;ist kleiner
;Ok, fllen
	swap		d0
	swap		d1
	swap		d2
	or.b		d5,(a0)				;went_to vermerken
	add.l		d3,a0
	add.l		d3,a1
	add.l		d3,a2
	add.l		d3,a3
	addq.l	#1,a5		;Y-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
add.l		if_debug2,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF

;Y > Max_y?
	swap		d7
	cmp.w		a5,d7
	bhi			y_not_higher
	move.w	a5,d7				;Sonst max_y merken
y_not_higher:
	swap		d7
	move.w	#128,d5			;went_to auf 128 setzen
	bra			fill_it			;und das Spiel von vorne
	
sd2_end_lower:
	swap		d2
sd1_end_lower:
	swap		d1
sd0_end_lower:
	swap		d0	
end_lower:
	
;Ich kann nirgends hin
;Ist das eine Sackgasse oder bin ich auf dem Rckweg?
	swap		d5
	move.b	(a0),d5
	andi.b	#240,d5			;Steht hier was in went_to?
	bne			no_went_to	;Ja, damit steht der Rckweg jetzt in d5
	swap		d5					;Ansonsten hole ich ihn mir wieder aus dem Hi-Byte
no_went_to:
;Jetzt mal schauen, wo es hingeht
	btst		#4,d5				;zurck nach rechts?
	beq			t_back_u		;Nein->
	addq.l	#1,a0
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4		;X-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
addq.l	#1,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF
	moveq.l	#0,d5
	bra			fill_it		
	
t_back_u:
	btst		#5,d5				;zurck nach unten?
	beq			t_back_l		;Nein->
	add.l		d3,a0
	add.l		d3,a1
	add.l		d3,a2
	add.l		d3,a3
	addq.l	#1,a5		;Y-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
add.l		if_debug2,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF
	moveq.l	#0,d5
	bra			fill_it		

t_back_l:
	btst		#6,d5				;zurck nach links?
	beq			t_back_o		;Nein->
	subq.l	#1,a0
	subq.l	#1,a1
	subq.l	#1,a2
	subq.l	#1,a3
	subq.l	#1,a4		;X-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
subq.l	#1,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF
	moveq.l	#0,d5
	bra			fill_it		

t_back_o:
	btst		#7,d5				;zurck nach oben?
	beq			no_back			;Auch nicht, also sowas...
	sub.l		d3,a0
	sub.l		d3,a1
	sub.l		d3,a2
	sub.l		d3,a3
	subq.l	#1,a5		;Y-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
sub.l		if_debug2,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF
	moveq.l	#0,d5
	bra			fill_it		

no_back:
;Tja, nix geht mehr, da bin ich wohl am Startpunkt...
;Hab ich da schon alle Richtungen durch?
	cmpi.b	#15,(a0)
	bne			fill_it		;Ne->dann grad mal von vorne...
	rts
	

; Turbo-Funktion. Wie oben aber mit nur einem Compare pro Farbe
; Aufrufen wenn alle min/max gleich sind
;Fll-Routine fr ein Pixel:
	
turbo_fill_it:
t_fill_it:
.IF debug = 1
move.l	a6,debug_buf
move.l	if_debug,a6
add.b		#1,(a6)
move.l	debug_buf,a6
.ENDIF
	
;Links prfen:
;Wurde links schon getestet?
	btst		#0,(a0)
	bne			t_end_left	;Ja->Ende
;Sonst links_getestet setzen
	ori.b		#1,(a0)
;War ich links schonmal?
	tst.b		-1(a0)
	bne			t_end_left	;Ja->Ende
;Sonst gucken, ob Farbe links ok ist
;Cyan
	cmp.b		-1(a1),d0			;Cmin testen
	bne			t_end_left			;ist gr”er
;Magenta	
	cmp.b		-1(a2),d1			;Mmin testen
	bne			t_end_left	;ist gr”er
;Yellow
	cmp.b		-1(a3),d2			;Ymin testen
	bne			t_end_left	;ist gr”er
;Ok, fllen
	or.b		d5,(a0)				;went_to vermerken
	subq.l	#1,a0
	subq.l	#1,a1
	subq.l	#1,a2
	subq.l	#1,a3
	subq.l	#1,a4		;X-Z„hler
.IF debug = 1
move.l	a6,debug_buf
move.l	if_debug,a6
subq.l	#1,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF

;X < Min_x?
	cmp.w		a4,d6
	bcs			t_x_not_smaller
	move.w	a4,d6				;Sonst min_x merken
t_x_not_smaller:
	moveq.l	#16,d5			;went_to auf 16 setzen
	bra			t_fill_it			;und das Spiel von vorne
	
t_end_left:

;Oben prfen:
;Wurde oben schon getestet?
	btst		#1,(a0)
	bne			t_end_upper	;Ja->Ende
;Sonst oben_getestet setzen
	ori.b		#2,(a0)
;War ich oben schonmal?
	tst.b		(a0,d4) 	;d4=-lwidth
	bne			t_end_upper	;Ja->Ende
;Sonst gucken, ob Farbe oben ok ist
;Cyan
	cmp.b		(a1,d4),d0			;Cmin testen
	bne			t_end_upper				;ist gr”er
;Magenta	
	cmp.b		(a2,d4),d1			;Mmin testen
	bne			t_end_upper		;ist gr”er
;Yellow
	cmp.b		(a3,d4),d2			;Ymin testen
	bne			t_end_upper		;ist gr”er
;Ok, fllen
	or.b		d5,(a0)				;went_to vermerken
	sub.l		d3,a0
	sub.l		d3,a1
	sub.l		d3,a2
	sub.l		d3,a3
	subq.l	#1,a5		;Y-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
sub.l		if_debug2,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF

;Y < Min_y?
	cmp.w		a5,d7
	bcs			t_y_not_smaller
	move.w	a5,d7				;Sonst min_y merken
t_y_not_smaller:
	moveq.l	#32,d5			;went_to auf 32 setzen
	bra			t_fill_it			;und das Spiel von vorne
	
t_end_upper:

;Rechts prfen:
;Wurde rechts schon getestet?
	btst		#2,(a0)
	bne			t_end_right	;Ja->Ende
;Sonst rechts_getestet setzen
	ori.b		#4,(a0)
;War ich rechts schonmal?
	tst.b		1(a0)
	bne			t_end_right	;Ja->Ende
;Sonst gucken, ob Farbe rechts ok ist
;Cyan
	cmp.b		1(a1),d0			;Cmin testen
	bne			t_end_right			;ist gr”er
;Magenta	
	cmp.b		1(a2),d1			;Mmin testen
	bne			t_end_right	;ist gr”er
;Yellow
	cmp.b		1(a3),d2			;Ymin testen
	bne			t_end_right	;ist gr”er
;Ok, fllen
	or.b		d5,(a0)				;went_to vermerken
	addq.l	#1,a0
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4		;X-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
addq.l	#1,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF

;X > Maxx prfen
	swap		d6
	cmp.w		a4,d6
	bhi			t_x_not_higher
	move.w	a4,d6				;Sonst max_x merken
t_x_not_higher:
	swap		d6
	moveq.l	#64,d5			;went_to auf 16 setzen
	bra			t_fill_it			;und das Spiel von vorne
	
t_end_right:

;Unten prfen:
;Wurde unten schon getestet?
	btst		#3,(a0)
	bne			t_end_lower	;Ja->Ende
;Sonst unten_getestet setzen
	ori.b		#8,(a0)
;War ich unten schonmal?
	tst.b		(a0,d3) 	;d3=+lwidth
	bne			t_end_lower	;Ja->Ende
;Sonst gucken, ob Farbe unten ok ist
;Cyan
	cmp.b		(a1,d3),d0			;Cmin testen
	bne			t_end_lower				;ist gr”er
;Magenta	
	cmp.b		(a2,d3),d1			;Mmin testen
	bne			t_end_lower		;ist gr”er
;Yellow
	cmp.b		(a3,d3),d2			;Ymin testen
	bne			t_end_lower		;ist gr”er
;Ok, fllen
	or.b		d5,(a0)				;went_to vermerken
	add.l		d3,a0
	add.l		d3,a1
	add.l		d3,a2
	add.l		d3,a3
	addq.l	#1,a5		;Y-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
add.l		if_debug2,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF

;Y > Max_y?
	swap		d7
	cmp.w		a5,d7
	bhi			t_y_not_higher
	move.w	a5,d7				;Sonst max_y merken
t_y_not_higher:
	swap		d7
	move.w	#128,d5			;went_to auf 128 setzen
	bra			t_fill_it			;und das Spiel von vorne
	
t_end_lower:
	
;Ich kann nirgends hin
;Ist das eine Sackgasse oder bin ich auf dem Rckweg?
	swap		d5
	move.b	(a0),d5
	andi.b	#240,d5			;Steht hier was in went_to?
	bne			t_no_went_to	;Ja, damit steht der Rckweg jetzt in d5
	swap		d5					;Ansonsten hole ich ihn mir wieder aus dem Hi-Byte
t_no_went_to:
;Jetzt mal schauen, wo es hingeht
	btst		#4,d5				;zurck nach rechts?
	beq			tt_back_u		;Nein->
	addq.l	#1,a0
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4		;X-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
addq.l	#1,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF
	moveq.l	#0,d5
	bra			t_fill_it		
	
tt_back_u:
	btst		#5,d5				;zurck nach unten?
	beq			tt_back_l		;Nein->
	add.l		d3,a0
	add.l		d3,a1
	add.l		d3,a2
	add.l		d3,a3
	addq.l	#1,a5		;Y-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
add.l		if_debug2,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF
	moveq.l	#0,d5
	bra			t_fill_it		

tt_back_l:
	btst		#6,d5				;zurck nach links?
	beq			tt_back_o		;Nein->
	subq.l	#1,a0
	subq.l	#1,a1
	subq.l	#1,a2
	subq.l	#1,a3
	subq.l	#1,a4		;X-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
subq.l	#1,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF
	moveq.l	#0,d5
	bra			t_fill_it		

tt_back_o:
	btst		#7,d5				;zurck nach oben?
	beq			t_no_back			;Auch nicht, also sowas...
	sub.l		d3,a0
	sub.l		d3,a1
	sub.l		d3,a2
	sub.l		d3,a3
	subq.l	#1,a5		;Y-Z„hler
.IF debug=1
move.l	a6,debug_buf
move.l	if_debug,a6
sub.l		if_debug2,a6
move.l	a6,if_debug
move.l	debug_buf,a6
.ENDIF
	moveq.l	#0,d5
	bra			t_fill_it		

t_no_back:
;Tja, nix geht mehr, da bin ich wohl am Startpunkt...
;Hab ich da schon alle Richtungen durch?
	cmpi.b	#15,(a0)
	bne			t_fill_it		;Ne->dann grad mal von vorne...
	rts



if_stack:
	.DS.L	1
if_buf:
	.DS.L	1
if_cc:
	.DS.L	1
if_mm:
	.DS.L	1
if_yy:
	.DS.L	1

if_cmin:
	.DS.B	1
if_cmax:
	.DS.B	1
if_mmin:
	.DS.B	1
if_mmax:
	.DS.B	1
if_ymin:
	.DS.B	1
if_ymax:
	.DS.B	1
	
if_line:
	.DS.W	1
if_mline:
	.DS.W 1
	
if_x:
	.DS.W 1
if_y:
	.DS.W 1
if_minx:
	.DS.W 1
if_maxx:
	.DS.W 1
if_miny:
	.DS.W 1
if_maxy:
	.DS.W 1
	

if_debug:
	.DS.L	1
if_debug2:
	.DS.L	1
debug_buf:
	.DS.L	1
		
sav_sp:
	.DS.L	1