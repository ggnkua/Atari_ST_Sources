********** Source: Zeichnen der Spalten ***********

scan_nibble_high:

;**** Registerbelegung innerhalb der Schleifen ****

; d0= x+y Position
; d1= Neue Hoehe
; d2= Alte Hoehe
; d3= Spaltenpunkte Zähler
; d4= pers adr + work byte
; d5= perts adder
; d6= Offset einer Zeile innerhalb des Junk Puffers
; d7= And Maske für Bleiben innerhalb der Landschaft 

* a0= Delta-xy-offset Tabelle eines Strahls
* a1= Zugriff auf die Höhendaten der Landschaft
* a2= Zugriff auf die Farbdaten der Landschaft
* a3= Für Direkteinsprung in die Turmzeichenbefehlsfolge
* a4= Perspektiven Tabelle
* a5= Aktuelle Screen Adresse
* a6= Alte Screen Adresse

                lea     byte_code_1(PC),A3	* Adresse für Code (Direkteinsprung)

                moveq   #0,D1           * Neue Höhe init
                moveq   #0,D2           * Alte Höhe init
                move.w  #punkte-1,D3    * Anzahl der Voxel, die Richtung Horizont 
					   * ausgewertet werden sollen
                moveq   #0,D4		   * Perspektiventabelle Start ganz vorne beim Betrachter
                move.w  #perspektiven*punkte,D5	* Offset für Schritt Richtung Horizont

do_row_byte_1:
                add.w   D5,D4		   * In der Perspektiventabelle einen Schritt
   * Richtung Horizont machen ...

                add.l   (A0)+,D0        * actual x-y-position
                and.l   D7,D0           * mask raender

                move.b  0(A1,D0.l),D4   * Höhe auslesen
                move.b  0(A4,D4.l),D1   * Höhe perspektivisch anpassen ...
   * Ergebnis: Höhe * 4

                sub.w   D1,D2           * Alte Höhe - neue Höhe < 0 ?
* damit ist der neue Punkt nicht sichtbar !
   * also nichts zeichnen

                bmi.s   scan_me_byte_1
                add.w   D1,D2		   * Operation rückgängig machen -> alte Höhe bleibt
					   * der Maßstab !
                dbra    D3,do_row_byte_1 	* Nächster Punkt
                rts

scan_me_byte_1:
                move.b  0(A2,D0.l),D4   * Farbinformation holen (Byte)

                jmp     0(A3,D2.w)	   * Direkteinsprung (abh. von neu zu zeichnendem
					   * Turmdelta)

********* Farbwerte eintragen ***********

                REPT max_y
                move.b  D4,(A5)		* Farbe in Junk Puffer schreiben
                suba.w  D6,A5			* vorherige Zeile im Junk Puffer adressieren
                ENDR

byte_code_1:    move.w  D1,D2			* neue Höhe wird zur alten Höhe
                dbra    D3,do_row_byte_1	* nächstes Voxel
                rts
                

Die selbe Prozedur für jede 2.Spalte - hier werden die niedrigen Nibbles des Junk
Puffers gefüllt.

scan_nibble_low:

                lea     byte_code_2(PC),A3

                moveq   #0,D1           
                moveq   #0,D2           
                move.w  #punkte-1,D3    
                moveq   #0,D4
                move.w  #perspektiven*punkte,D5

do_row_byte_2:
                add.w   D5,D4

                add.l   (A0)+,D0        
                and.l   D7,D0           

                move.b  0(A1,D0.l),D4   
                move.b  0(A4,D4.l),D1   

                sub.w   D1,D2          
                bmi.s   scan_me_byte_2
                add.w   D1,D2
                dbra    D3,do_row_byte_2
                rts

scan_me_byte_2:
                move.b  0(A2,D0.l),D4   

                lsr.b   #4,D4			; Farbinformation ins untere Nibble

                jmp     0(A3,D2.w)

                REPT max_y
                or.b    D4,(A5)		; unteres Nibble füllen
                suba.w  D6,A5
                ENDR

byte_code_2:    move.w  D1,D2
                dbra    D3,do_row_byte_2
                rts
