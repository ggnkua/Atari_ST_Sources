
; Optimieren der eigentlichen Malroutine, ohne Dithern:
; Schritt 1:

; R, G und B trennen, je einen Block als gesamtes.
; Vorteil: nur ein Tabellenzugriff, da Farbauftrag (Druck beim Artpad o.Ñ.)
;          Schon am Anfang berechnet werden muû und nicht in der Schleife
; Achtung: dazu muû allerdings die Tabelle "umgedreht" werden, d.h. daû es
;          fÅr jede der 256 "FarbstÑrken" eine Tabelle mit wieder 256
;          IntensitÑten gibt.

                moveq   #0,D4           ; wenn nicht schon vorher 0!
                lea     intensity(PC),A3
                moveq   #0,D0
                move.b  c_red,D0        ; intensitÑt
                lsl.w   #8,D0           ; mal 256
                adda.l  D0,A3           ; ein Long-Add ist schneller als ein
;                                         Word Add (nur bei Adressregistern)


x_rloop:        move.b  (A4)+,D4        ; Schleife fÅr Rot
                move.b  0(A3,D4.w),D4
                cmp.b   (A0),D4
                bls.s   las_r_weiter
                move.b  D4,(A0)
                dbra    D1,x_rloop

las_r_weiter:   addq.l  #1,A0           ; das kannman auch noch "umoptimieren"
                dbra    D1,x_rloop      ; siehe unten... :-)

; und zum Schluû die y-Schleife nicht vergessen!
; Danach A3 fÅr grÅn und blau neuberechnen und dort jeweis das gleiche machen


; Schritt 2:
; Jetzt haben wir 1. eine relativ kurze Schleife
; (dbra braucht beim 030er 6 Taktzyklen).
; Auûerdem sind die Speicherzugriffe querbeet durcheinander (a4, a3, a0)
; letzteres schluckt viiiel!
; Also, alles auseinander ziehen.
; Achtung: - da alle acht Datenregister gebraucht werden, muû als X-ZÑhler
;            ein Adressregister genommen werden ;-) (Oder im Speicher).
;          - Auf einen Rutsch werden nun 8 Pixel in der Breite Åbertragen,
;            also muû auch die Schleife kÅrzer sein.
;            Vorher also die unteren 3 Bits ausmaskieren, mit diesen die
;            Schleife von oben (Schritt 1) durchlaufen lassen und dann
;            den durch 8 Teilbaren Rest durchackern. Oder anders herum. :-)
;          - ganz zu Anfang sollten die Datenregs gelîascht werden...


x_r2loop:       move.b  (A4)+,D0        ; alle 8 Datenregister
                move.b  (A4)+,D1        ; mit Pixeln belegen
                move.b  (A4)+,D2        ; ===> lineare Speicherzugriffe sind
                move.b  (A4)+,D3        ;      weit schneller!
                move.b  (A4)+,D4
                move.b  (A4)+,D5
                move.b  (A4)+,D6
                move.b  (A4)+,D7
                move.b  0(A3,D0.w),D0   ; und nun Åber die Tabelle gehen...
                move.b  0(A3,D1.w),D1
                move.b  0(A3,D2.w),D2   ; dieses kînnte man sich
                move.b  0(A3,D3.w),D3   ; *komplett* sparen
                move.b  0(A3,D4.w),D4   ; (siehe unten)
                move.b  0(A3,D5.w),D5
                move.b  0(A3,D6.w),D6
                move.b  0(A3,D7.w),D7
                cmp.b   (A0)+,D0        ; Farbwert vergleichen, Zieh erhîhen
                bls.s   las_r_w0        ;   Erhîhung spart spÑter Add!
                move.b  D0,-1(A0)       ; Bei Bedarf schreiben, da erhîht mit -
las_r_w0:       cmp.b   (A0)+,D1        ; Label heiût: lasierend, rot, weiter 0
                bls.s   las_r_w1
                move.b  D1,-1(A0)
las_r_w1:       cmp.b   (A0)+,D2
                bls.s   las_r_w2
                move.b  D2,-1(A0)
las_r_w2:       cmp.b   (A0)+,D3
                bls.s   las_r_w4
                move.b  D3,-1(A0)
las_r_w3:       cmp.b   (A0)+,D4
                bls.s   las_r_w4
                move.b  D4,-1(A0)
las_r_w4:       cmp.b   (A0)+,D5
                bls.s   las_r_w5
                move.b  D5,-1(A0)
las_r_w5:       cmp.b   (A0)+,D6
                bls.s   las_r_w6
                move.b  D6,-1(A0)
las_r_w6:       cmp.b   (A0)+,D7
                bls.s   las_r_w7
                move.b  D7,-1(A0)
las_r_w7:

                subq.l  #1,A6           ; A6 ist der ZÑhler fÅr x... :-)
                bpl.s   x_r2loop

; y-Schleife und Restpixel noch hinzu!
; Åbrigens muû das ganze nicht fÅr jede Farbe extra geschrieben werden, es
; reicht wenn nur die Register umgelegt werden... :-)

; evtl. kannst Du Dir sogar den letzten Tabellenzugriff ersparen, kostet
; aber u.U. sehr viel Speicher:
; Du muût einfach fÅr jede IntensitÑt eine Pinselform anlegen, und dort
; dann gleich die intensitÑt mit hineinberechnen...
; macht bei einem 50x50-Pinsel dann 625 KByte, bei einem 100x100-Pinsel
; sind es schon 2500 KByte, also fast 2.5 MB. (uff)
; Aber wenn ich das richtig verstanden habe, machst Du das sowieso schon so?
; Dann muûte man das nur noch hereinrechnen...


; unten beim Dithern lassen sich wunderbar die 030er Adressierungsarten
; nutzen; also z.B. lsl.w #2,D4 weg, dafÅr danach ein
; move.l (a3,d4*4),a3. Der Tabellenzugriff braucht bei *4 genauso
; lange wie ohne, nÑmlich 8 Tyktzyklen wenn alles im Cach ist :-)

; Auûerdem muû dann D4 auch nicht immer gelîscht werden.


; So ein Mist, der TurboAss hat mir jetzt hier 'nen Teil verheizt :-(
; WBDAEMON muû raus...

; also, ich versuche es nochmal:


; In D6 steht die 8er-Position beim Start!
; In A3, A4 und A5 die Zeiger auf die Dithertabellen!
; In A6 steht hier schon der Zeiger auf die richtige Adresse
; im Bildschirmspeicher!
; In D6 steht der Offset fÅr die Y-Zeile.


                moveq   #16,D3          ; dann kann man sich unten den
;                                         immediate-Wert ersparen...

dither_y_loop:
                jmp ([jmp_tab,D6*4])


jmp_tab:        DC.L dither_7   ; Zeiger auf Start mit acht durchgÑngen
                DC.L dither_6
                DC.L dither_5
                DC.L dither_4
                DC.L dither_3
                DC.L dither_2
                DC.L dither_1
                DC.L dither_0


dither_x_loop:
dither_7:       move.b  (A0)+,D4        ;    Rot-wert holen
                move.b  ([A3,D4*4],7,D5),D7 ; Aus Ditherraster rausholen
                move.b  (A1)+,D4        ;    GrÅn
                add.b   ([A4,D4*4],7,D5),D7 ; Draufaddieren (oder via "or")
                move.b  (A2)+,D4        ;    Blau
                add.b   ([A5,D4*4],7,D5),D7
                add.b   D3,D7           ; 16 hinzu, Farboffset!
                move.b  D7,(A6)+        ; reinmalen in den Schirm


dither_6:       move.b  (A0)+,D4        ;    Und wieder das (fast) gleiche...
                move.b  ([A3,D4*4],6,D5),D7
                move.b  (A1)+,D4
                add.b   ([A4,D4*4],6,D5),D7 ; Draufaddieren (oder via "or")
                move.b  (A2)+,D4        ;     Blau
                add.b   ([A5,D4*4],6,D5),D7
                add.b   D3,D7           ; 16 hinzu, Farboffset!
                move.b  D7,(A6)+        ; in den Bildschirm


; [...]
; dither_5 bis dither_1


dither_0:       move.b  (A0)+,D4        ;    Rot-wert holen
                move.b  ([A3,D4*4],D5),D7 ; Aus Ditherraster rausholen
                move.b  (A1)+,D4        ;    GrÅn
                add.b   ([A4,D4*4],D5),D7 ; Draufaddieren (oder via "or")
                move.b  (A2)+,D4        ;    Blau
                add.b   ([A5,D4*4],D5),D7
                add.b   D3,D7           ; 16 hinzu, Farboffset!
                move.b  D7,(A6)+        ; in den Schirm


; Danach dann entweder eine Schleife zu dither_x_loop

                dbra    D0,dither_x_loop ; Breite teilen nicht vergessen

; nun y-Korrekturen und:
                dbra    D0,dither_y_loop ; ...


; oder noch schneller:
; wieder ein paar Datenregister "vollpumpen" und alles "en-block"schreiben.
; Da allerings ein Datenregister benîtigt wird und es drei Quelladressen gibt,
; kînnen nur zwei bzw. drei Pixel gelesen werden, da ja 6 Regs benîtigt werden.

; Allerdings gibt's da dann wieder Registerknappheit => irgendwo auslagern ;-)

; und noch eine Mîglichkeit:
; Die Tabelle vergrîûern, so daû man immer zwei Pixel auf einem mal durch-
; machen kann.
; Also etwa so:

dither__67:     move.w  (A0)+,D4        ;      rot, Pixel 6 und 7
                move.w  ([A3,D4*4],6,D5),D7
                move.w  (A1)+,D4        ;      g
                add.w   ([A4,D4*4],6,D5),D7
                move.w  (A2)+,D4        ;      b
                add.w   ([A5,D4*4],6,D5),D7
                add.w   D3,D7           ; in D3 steht 16 im low- und high-Byte!
;                                         also $1010
                move.w  D7,(A6)+

; Und das ganze dann noch so kombiniert, daû mehrere regs auf einmal gelsen
; werden kînnen... :-)
; D5 kînnte durch Adressregister ersetzt werden, D3 zur Not als
; immediate-Wert. Das wÅrde dann 4 Taktzyklen anstatt 2 brauchen (030er)
; wÅrde aber evtl. egal sein, da zwischen zwei "entfernten" Speicherzugriffen
; meist zehn Taktzyklen ohne Geschwindigkeitsverlust untergebracht werden
; kînnen!

; Den SP kann man ruhig mitnutzen -- vorher in absoluter Adresse retten
; nicht vergessen ;-)

; Es kînnte etwa so aussehen:
dither_xx:      move.w  (A0)+,D0        ; rot, Pixel 6 und 7
                move.w  (A0)+,D1        ; via movem.w (a0)+,d0-d3
                move.w  (A0)+,D2        ; wÑre es deutlich langsamer!
                move.w  (A0)+,D3        ; Pixel 0 und 1
                move.w  ([A3,D0*4],6,SP),D0
                move.w  ([A3,D1*4],4,SP),D1
                move.w  ([A3,D2*4],2,SP),D2
                move.w  ([A3,D3*4],SP),D3
                move.w  (A1)+,D4        ; GrÅn
                move.w  (A1)+,D5
                move.w  (A1)+,D6
                move.w  (A1)+,D7
                add.w   ([A4,D4*4],6,SP),D0
                add.w   ([A4,D5*4],4,SP),D1
                add.w   ([A4,D6*4],2,SP),D2
                add.w   ([A4,D7*4],SP),D3
                move.w  (A2)+,D4        ; Blau
                move.w  (A2)+,D5
                move.w  (A2)+,D6
                move.w  (A2)+,D7
                add.w   ([A5,D4*4],6,SP),D0
                add.w   #$1010,D0       ; Dazwischenpacken, kostet keine Zeit
                add.w   ([A5,D5*4],4,SP),D1
                add.w   #$1010,D1
                add.w   ([A5,D6*4],2,SP),D2
                add.w   #$1010,D2
                add.w   ([A5,D7*4],SP),D3
                add.w   #$1010,D3
                move.w  D0,(A6)+
                move.w  D1,(A6)+
                move.w  D2,(A6)+
                move.w  D3,(A6)+

; So, das waren dann 8 Pixel!
; Schleife etc. wie gehabt...

; evtl. kînnte man fÅr jede Dithermatrix-Zeile einen eigenen Code schreiben
; und sich dadurch den SP ersparen (direkt in den Offset rein); ich weiû
; jetzt nur nicht, ob das schneller ist, glaube aber schon!

;
; Aber es wird also auf jeden Fall auch der gesamte Block auf einmal gedithert.
; Kann also auch zum Bilddarstellen benutzt werden... :-)
; aus GeschwindigkeitsgrÅnden am besten alles gleich *direkt*
; in den Schirm, ohne erst Åbers VDI zu gehen.
; wenns ins Fenster geht und vorher alles getestet ist, dann ist
; es genauso sauber wie VDI


; Aber ich glaube, wenn alles klappt und ich keine totalen Denkfehler drin
; hab', daû dann das ganze doch um einiges schneller wird... :-)
; Hoffentlich!

; ** GRöN **

		move.l	d0,-(sp)
		move.l	a1,-(sp)

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_green,d5			;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen
		
g_byploop:
		move.l	dif_x,d1
g_bxploop:
		move.b	(a5)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),d4		;Farbwert holen
		cmp.b		(a1)+,d4				;Farbwert zu groû?
		bls			las_1
		move.b	d4,-1(a1)				;In vorhandenes Byte schreiben
las_1:
		dbra		d1,g_bxploop
		
		adda.l	d2,a1						;Zeilenoffset fÅr Plane
		adda.l	d3,a5						;Zeilenoffset fÅr Pinsel
		dbra		d0,g_byploop
;end_green
		move.l	(sp)+,a1
		move.l	(sp)+,d0

; ** BLAU **

		move.l	d0,-(sp)
		move.l	a2,-(sp)

		moveq.l	#0,d4
		lea			intensity,a3		;Tabellenadresse
		moveq.l	#0,d5
		move.b	c_blue,d5			;Zeichenfarbe
		lsl.w		#8,d5						;Tabelle fÅr diese Farbe
		adda.l	d5,a3						;berechnen
		
b_byploop:
		move.l	dif_x,d1
b_bxploop:
		move.b	(a6)+,d4				;Pinseldurchlaû
		move.b	0(a3,d4.l),d4		;Farbwert holen
		cmp.b		(a2)+,d4				;Farbwert zu groû?
		bls			las_2
		move.b	d4,-1(a2)				;In vorhandenes Byte schreiben
las_2:
		dbra		d1,b_bxploop
		
		adda.l	d2,a2						;Zeilenoffset fÅr Plane
		adda.l	d3,a6						;Zeilenoffset fÅr Pinsel
		dbra		d0,b_byploop
;end_blue
		move.l	(sp)+,a2
		move.l	(sp)+,d0

;************************************************
