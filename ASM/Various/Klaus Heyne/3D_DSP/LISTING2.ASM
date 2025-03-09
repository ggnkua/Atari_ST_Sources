;------------------------------------------------
; DSP als Grafik-Koprozessor
; DSP-Listing 2
;                      (c) 1995 by MAXON-Computer
;                      Autor: Klaus Heyne         
;------------------------------------------------
;------------------------------------------------
; Hidden-Line und Lichtberechnung                
;------------------------------------------------
hiddenline                                       
   clr   A     #wflach,R3  ; FlÑchenstruktur     
   move  X:fla_list,R2     ; Adr. d. Ausgabeliste
   move  X:beo_x,R5        ; Beobachtersystem    
   move  X:beo_y,R6                              
   move  X:beo_z,R7                              
   move  A1,X:flacount     ; FlÑchenzÑhler auf   
   move  A1,X:paintfla     ; null setzen         
   move  (R2)+             ; 1. Eintrag fÅr Anz. 
   do    X:anzfla,hideloop ; der FlÑchen         
   move  R3,N4             ; Adr. d. akt. FlÑche 
   move  X:(R3)+,X0        ; color|codes|Ecken   
   move  X0,X:fla_flag     ; enthÑlt auch evtl.  
   move  X:(R3)+,N1        ; Flags ; Punktindex 1
   move  N1,N5             ; als x-Offset        
   move  X:(R3)+,N2        ; Punktindex 2        
   move  Y:(R5+N5),Y1      ; x1 holen            
   move  N2,N5             ; Index 2 als x-Offset
   nop                     ; Vektor p bilden:    
   move  Y:(R5+N5),B       ; B=x2, Y1=x1         
   sub   Y1,B  N1,N6       ; px=x2-x1            
   move  B1,X:var_1        ; px speichern        
   move  Y:(R6+N6),Y1      ; Y1=y1               
   move  N2,N6             ; Index 2 als y-Offset
   move  N1,N7             ; Index 1 als z-Offset
   move  Y:(R6+N6),B       ; B=y2                
   sub   Y1,B  Y:(R7+N7),Y1 ; py=y2-y1, Y1=z1    
   move  N2,N7             ; Index 2 als z-Offset
   move  B1,X:var_2        ; py speichern        
   move  Y:(R7+N7),B       ; B=z2                
   sub   Y1,B  X:(R3)+,N3  ; pz=z2-z1; Index 3   
   move  N3,N5             ; Index 3 als x-Offset
   move  B1,X:var_3        ; pz speichern        
   move  Y:(R5+N5),B       ; Vektor q bilden:    
   move  N1,N5             ; B=x3, N5=x-Offset 1 
   move  N3,N6             ; N6=y-Offset 3       
   move  Y:(R5+N5),Y1      ; Y1=x1               
   sub   Y1,B  Y:(R6+N6),A ; qx=x3-x1, A=y3      
   move  N1,N6             ; N6=y-Offset 1       
   move  B1,X0             ; qx speichern in X0  
   move  N3,N7             ; N7=z-Offset 3       
   move  Y:(R6+N6),Y1      ; Y1=y1               
   sub   Y1,A  Y:(R7+N7),B ; qy=y3-y1, B=z3      
   move  N1,N7             ; N7=z-Offset 1       
   move  A1,Y0             ; qy speichern in Y0  
   move  Y:(R7+N7),Y1      ; Y1=z1               
   sub   Y1,B  X:var_2,Y1  ; qz=z3-z1, py holen  
   move  B1,X1             ; qz speichern in X1  
                                                 
; auf der FlÑche senkrechten Vektor r berechnen: 
   mpy   Y1,X1,A  X:var_3,Y1 ; rx=py*qz, pz holen
   mac   -Y1,Y0,A N1,N5      ; - pz*qy,N5=x-Offs1
   mpy   Y1,X0,B  X:var_1,Y1 ; ry=pz*qx, px holen
   mac   -Y1,X1,B A0,X:var_4 ; - px*qz, rx speich
   mpy   Y1,Y0,A  X:var_2,Y1 ; rz=px*qy, py holen
   mac   -Y1,X0,A B0,X:var_5 ; - py*qx, ry speich
                                                 
; Vektor s vom 1.Punkt d. FlÑche zum Proj-zentrum
   move  Y:(R5+N5),B       ; bilden: B=x1        
   neg   B     N1,N6       ; sx=-x1,da projektx=0
   move  B1,X1             ; sx speichern in X1  
   move  Y:(R6+N6),B       ; B=y1                
   neg   B     N1,N7       ; sy=-y1,da projekty=0
   move  B1,Y0             ; sy speichern in Y0  
   move  X:projektz,B      ; B=projektz          
   move  Y:(R7+N7),Y1      ; Y1=z1               
   sub   Y1,B  X:var_4,X0  ; sz=projektz-z1,X0=rx
   move  B1,Y1             ; sz speichern in Y1  
                                                 
   jset  #5,X:fla_flag,dosicht ; FlÑche v. beiden
                           ; Seiten sichtbar!    
; Skalarprodukt bilden: Vektor s * Vektor r:     
   mpy   X1,X0,B  X:var_5,X0 ; sx*rx, ry holen   
   mac   Y0,X0,B  A0,X0    ; + sy*ry, rz holen   
   mac   Y1,X0,B  N4,R3    ; + sz*rz, R3=FlÑ-Adr.
   jpl   hidden      ; Skalar >=0: nicht sichtbar
                                                 
dosicht                         ; FlÑche mit     
   jset  #6,X:fla_flag,maxlight ; Eigenleuchten  
                                                 
; Vektor l von Lichtquelle zum 1.Punkt der FlÑche
   move  Y:(R5),B         ; B=lichtx,X1=sx=-x1   
   add   X1,B             ; lx=lichtx-x1         
   move  B1,X1            ; lx speichern in X1   
   move  Y:(R6),B         ; B=lichty, Y0=sy=-y1  
   add   Y0,B  N4,R3      ; ly=lichty-y1         
   move  B1,Y0            ; ly speichern in Y0   
   move  Y:(R7),B         ; B=lichtz             
   move  Y:(R7+N7),Y1     ; Y1=z1                
   sub   Y1,B  X:var_4,X0 ; lz=lichtz-z1,rx holen
   move  B1,Y1            ; lz speichern in Y1   
                                                 
; Skalarprodukt bilden: Vektor l * Vektor r      
   mpy   X1,X0,B  X:var_5,X0 ; lx*rx, ry holen   
   mac   Y0,X0,B  A0,X0      ; + ly*ry, rz holen 
   mac   Y1,X0,B  A0,X:var_6 ; + lz*rz, rz speich
   jpl   dark  ;Skalar>=0:FlÑche nicht beleuchtet
                                                 
; Einheitsvektoren von l und r (el,er) berechnen:
   jsr   vector_1                                
   move  X1,X:var_1        ; elx                 
   move  Y0,X:var_2        ; ely                 
   move  Y1,X:var_3        ; elz speichern       
   move  X:var_4,X1        ; rx holen            
   move  X:var_5,Y0        ; ry holen            
   move  X:var_6,Y1        ; rz holen            
   jsr   vector_1                                
                                                 
; Skalarprodukt der Einheitsvektoren: el * er    
; zur Bestimmung des Schattierungsfaktors:       
   clr   B           X:var_1,X0 ; elx holen      
   mpy   X0,X1,A     X:var_2,X0 ; elx*erx,X0=ely 
   mac   X0,Y0,A     X:var_3,X0 ;+ely*ery,X0=elz 
   mac   X0,Y1,A     #$800000,X0 ;+elz*erz       
   cmp   X0,A        X:(R3),B1 ; Skalarprodukt   
   tle   X0,A            ; darf nicht kleiner als
dark_ret                 ; -1 sein!              
   abs   A  X:litefak,X0 ; A mit Lichtfaktor ska-
   move  A,X1            ; lieren und mit L-offs.
   mpy   X0,X1,A  X:liteoffs,X0 ; in den hellen  
   add   X0,A     #$FFDF00,X0   ; Bereich heben. 
                                                 
; A1 enthÑlt jetzt einen Helligkeitswert V im Be-
; reich von 0 bis 0.9999. Durch Multiplikation   
; mit allen RGB-Komponenten errechnet sich die   
; neue Farbe (16-Bit-Falcon-True-Color):         
   and   X0,B     A,X1   ; RGB ausfiltern, X1=V  
   move  B1,Y1           ; RGB merken            
   rep   #13             ; Blau-Anteil nach B0   
   asr   B               ; shiften               
   asr   B      #>$1F,Y0 ; Y0=Maske f. GRöN-Ant. 
   move  B0,X0           ; X0=B-Anteil fractional
   mpyr  X1,X0,A  #0,B0  ; BLAU * V, B0 lîschen! 
   and   Y0,B     A,X0   ; BLAU in X0 speichern. 
   rep   #6              ; GRöN-Anteil ausfiltern
   asr   B               ; und nach B0 shiften.  
   move  B0,Y0           ; Y0=G-Anteil fractional
   mpyr  X1,Y0,A  #0,B0  ; mit V multiplizieren  
   move  A,Y0            ; und in Y0 speichern.  
   move  Y1,A1           ; Original RGB holen,   
   lsr   A   #$7C0000,Y1 ; shiften und ROT-Anteil
   and   Y1,A            ; ausfiltern:           
   move  A1,Y1           ; Y1=R-Anteil fractional
   mpyr  X1,Y1,A         ; mit V multiplizieren, 
   lsl   A   #$F80000,X1 ; in Bits 23-19 shiften 
   and   X1,A    Y0,B    ; und maskieren, GRöN   
   rep   #3              ; holen und in die Bits 
   lsr   B                  ; 18-14 shiften,     
   lsr   B       #$7C000,X1 ; die relevanten     
   and   X1,B    #$1F00,X1  ; 5 Bits ausfiltern  
   move  B1,Y0              ; und zu             
   or    Y0,A    X0,B       ; ROT odern. BLAU    
   rep   #10         ; holen und in die Bits     
   lsr   B           ; 12-8 shiften,             
   and   X1,B        ; die relevanten 5 Bits     
   move  B1,Y0       ; ausfiltern und zu         
   or    Y0,A        ; ROT und GRöN odern.       
max_ret              ; RÅcksprung aus "max_light"
   rep   #8          ; RGB-Wert in die unteren   
   lsr   A           ; 16 Bit shiften (Falcon-TC)
   move  A1,N6       ; und zwischenspeichern.    
                                                 
; mittlere z-Koordinate der FlÑche berechnen:    
   move  R3,R0       ; FlÑchenadresse Åbergeben  
   move  #>$F,B      ; Maske fÅr Eckenanzahl     
   clr   A  X:(R0)+,X0                           
   and   X0,B        ; Eckenanzahl ausfiltern    
   do    B1,mittel_z ; arithm. Mittel bilden:    
   move  X:(R0)+,N7  ; z-Koordinaten aller       
   nop                                           
   move  Y:(R7+N7),X0 ; Eckpunkte addieren       
   add   X0,A                                    
mittel_z              ; und durch die Anzahl     
   move  B1,X0        ; der Eckpunkte teilen     
   move  #2,R0        ; Flag: Integerdivision    
   jsr   divide                                  
   move  X:zmax,X0    ; z-Clipping               
   cmp   X0,A  #>1,Y1                            
   jpl   hidden                                  
                                                 
   move  X:flacount,B ; aktuelle FlÑchennummer   
   move  A1,X:(R2)+   ; z-mittel, Farbe          
   move  N6,X:(R2)+   ; und FlÑchennummer in     
   move  B1,X:(R2)+   ; Ausgabeliste eintragen   
   move  X:paintfla,A ; Anz. der zu zeichnenden  
   add   Y1,A         ; FlÑchen mitzÑhlen        
   move  A1,X:paintfla                           
hidden                                           
   move  X:(R3)+,X0   ; Eckenanzahl aus FlÑchen- 
   move  #>$F,A       ; struktur ausfiltern      
   and   X0,A  (R3)+  ; Adresse erhîhen          
   move  X:flacount,B ; aktuelle FlÑchennummer   
   move  #>1,Y1       ; um 1 erhîhen             
   add   Y1,B  A1,N3  ; Eckenanz. ins Offsetreg. 
   move  B1,X:flacount  ; FlÑchennr. speichern   
   lua   (R3)+N3,R3   ; Adr. auf nÑchste FlÑche  
hideloop                                         
                                                 
   move  X:fla_list,R2 ; Anz. d. sichtb. FlÑchen 
   move  X:paintfla,A  ; in ersten Listeneintrag 
   move  A1,X:(R2)+    ; Listenzeiger auf Daten- 
   move  #>2,Y0        ; anfang setzen           
   cmp   Y0,A          ; SpezialfÑlle abfangen:  
   jeq   sort2         ; 2 FlÑchen extra sort.   
   jgt   sortz         ; >2: zur Sortierroutine  
   rts                 ; sonst wars das...       
;----------------------------------------------- 
dark                   ; FlÑche von der Licht-   
   clr   B   N4,R3     ; quelle abgewandt:       
   nop                 ; mit V=0 in A und RGB-   
   clr   A   X:(R3),B1 ; Color in B1 zurÅck zur  
   jmp   dark_ret      ; weiteren Berechnung     
                                                 
maxlight               ; FlÑche mit max. Hellig- 
   clr   B   N4,R3     ; keit bzw. Eigenleuchten 
   nop                 ; mit der Originalfarbe   
   move  X:(R3),A1     ; in A1 zurÅck zur        
   jmp   max_ret       ; weiteren Berechnung     
;------------------------------------------------
; Einheitsvektor berechnen                       
; -> V(X1,Y0,Y1)                  Ve(X1,Y0,Y1) ->
;------------------------------------------------
vector_1                                         
   clr   B  X1,X0       ; Vektorbetrag berechnen:
   mpy   X1,X0,A  Y1,X0 ; vx^2                   
   mac   Y0,Y0,A        ; + vy^2                 
   mac   Y1,X0,A        ; + vz^2  
   asr   A  #$400000,X0 ; Ergebnis = A/2, X0=0.5           
v_scale                                          
   move  A1,B1          ; Vektor skalieren, bis  
   tst   B  X1,X:workmemo ; die Quadratsumme in  
   jeq   v_betrag       ; 24 Bit paût. Damit das 
   mpy   X0,X1,B        ; VerhÑltnis stimmt, muû 
   asr   A        B,X1  ; die Quadratsumme mit
   mpy   X0,Y0,B        ; jeder Halbierung der  
   asr   A        B,Y0  ; Komponenten geviertelt
   mpy   X0,Y1,B        ; werden!               
   clr   B        B,Y1  ; B wird VOR dem Lîschen
   jmp   v_scale        ; nach Y1 kopiert.      
v_betrag                                         
   jsr   sqrt           ; Wurzel aus 24-Bit-Wert 
   move  A1,X0          ; ziehen, Betrag nach X0 
   move  X:workmemo,A   ; vx zurÅckholen         
   move  #0,R0          ; Flag: fract. Division  
   jsr   divide         ; Alle Vektorkomponenten 
   move  A1,X1          ; durch Vektorbetrag     
   move  Y0,A           ; dividieren             
   move  #0,R0          ; Flag: fract. Division  
   jsr   divide                                  
   move  A1,Y0          ; Komponenten des        
   move  Y1,A           ; Einheitsvektors        
   move  #0,R0          ; Flag: fract. Division  
   jsr   divide         ; in X1,Y0,Y1            
   move  A1,Y1          ; zurÅckgeben            
   rts                                           
;----------------------------------------------- 
; FlÑchenausgabeliste nach z-Koord. sortieren.   
; (Quelle: DSP-Source-Codes des ATARI Falcon030  
; Toolkit, auf 3 Dimensionen erweitert)          
;----------------------------------------------- 
sortz                                            
   move  #-6,N1         ; Offset f. RÅck-Zugriff 
   move  A1,R4          ; Anzahl der EintrÑge    
   move  #>3,N2         ; 3 Werte pro Eintrag    
   move  #>1,X1         ; Anz. d. EintrÑge -1    
   sub   X1,A  N2,N0    ; fÅr Ñuûere Schleife    
                                                 
   do    A1,sloop2                               
   lua   (R2)+N2,R0                              
   move  X:(R2),A     Y:(R4)-,B                  
   move  X:(R0)+N0,B                             
   move  R0,R1                                   
                                                 
   do    R4,sloop1                               
   cmp   B,A     X:(R0)+N0,B  B,Y0               
   tge   Y0,A    R0,R1                           
sloop1                                           
   move  X:(R2),Y0      ; 1. word tauschen       
   move  A,X:(R2)+                               
   move  Y0,X:(R1+N1)                            
                                                 
   move  #-5,N1         ; 2. word tauschen       
   move  X:(R2),Y0                               
   move  X:(R1+N1),B                             
   move  B,X:(R2)+                               
   move  Y0,X:(R1+N1)                            
                                                 
   move  #-4,N1         ; 3. word tauschen       
   move  X:(R2),Y0                               
   move  X:(R1+N1),B                             
   move  B,X:(R2)+                               
   move  Y0,X:(R1+N1)                            
   move  #-6,N1                                  
sloop2                                           
   rts                                           
                                                 
sort2:                  ; Kurzform bei nur       
   move  R2,R1          ; zwei ListeneintrÑgen   
   move  X:(R2)+,A      ; z-mittel 1             
   move  X:(R2)+,X0     ; index 1                
   move  X:(R2)+,Y1     ; color 1                
   move  X:(R2)+,X1     ; z-mittel 2             
   cmp   X1,A                                    
   jmi   sortend        ; schon richtig          
   move  X:(R2)+,Y0     ; index 2                
   move  X:(R2)+,B      ; color 2                
   move  X1,X:(R1)+     ; EintrÑge vertauschen   
   move  Y0,X:(R1)+                              
   move  B1,X:(R1)+                              
   move  A1,X:(R1)+                              
   move  X0,X:(R1)+                              
   move  Y1,X:(R1)                               
sortend                                          
   rts                                           
;----------------------------------------------- 
; Integer Quadratwurzel ziehen                   
; -> A0 (24 Bit)                  A1 (24 Bit) -> 
; (Quelle: DSP-Source-Codes des ATARI Falcon030  
; Toolkit)                                       
;----------------------------------------------- 
sqrt                                             
   clr   B  #>1,X1                               
   move  B,R0           ; R0 wird sqrt(A1) * 2   
   move  A0,B0                                   
   move  #<2,N1                                  
   do    #12,endsqrt ; 2 Bits pro Loop = 24 Bits 
   asl   B  R0,N0                                
   asl   B                                       
   tfr   B,A   (R0)+N0  ; B -> A       ; R0=R0*2 
   sub   X1,A  R0,R1                             
   move  R0,X0                                   
   sub   X0,A  (R1)+N1  ; A1=B1-R0-1 ; R1=R0+2   
   tpl   A,B   R1,R0    ; Wenn (B1>=R0+1) dann   
endsqrt                 ; B1=B1-R0-1 und R0=R0+2 
   move  R0,A                                    
   asr   A              ; Ergebnis: A1=R0/2      
   rts                                           
;------------------------------------------------
; Absolute, fÅr d. Weltsystem gÅltige Komponenten
; fÅr die zur Blickrichtung relativen Bewegungen 
; "seitwÑrts","aufwÑrts" und "vorwÑrts" berechnen
;------------------------------------------------
movecalc                                         
   move  X:xwinkel,A        ; Gegenwinkel fÅr die
   neg   A     #>360,X0     ; RÅcktransformation:
   add   X0,A  X:ywinkel,B  ; xwinkel=360-xwinkel
   neg   B     A1,X:xwinkel ; ywinkel=360-ywinkel
   add   X0,B  X:zwinkel,A  ; zwinkel=360-zwinkel
   neg   A     B1,X:ywinkel                      
   add   X0,A                                    
   move  A1,X:zwinkel                            
   jsr   mat_init        ; Rot.-Matrix erstellen.
   move  #move_rel,R0    ; Die im Beobachter-    
   move  #move_abs,R1    ; system definierten    
   do    #9,copy_rel     ; Zielpunkte fÅr die    
   move  Y:(R0)+,X0      ; o.g. Grundbewegungs-  
   move  X0,Y:(R1)+      ; richtungen kopieren.  
copy_rel                                         
   move  #move_abs,R5    ; Zeiger auf die x-,    
   move  #move_abs+3,R6  ; y- und z-Koordinaten  
   move  #move_abs+6,R7  ; dieser Punkte setzen. 
   move  #3,N0           ; N0=SchleifenzÑhler    
   jsr   rotate          ; 3 Punkte rotieren     
   rts                                           
;------------------------------------------------ 
; Lichtquelle auf Kreis um x- u. y-Achse bewegen 
;------------------------------------------------ 
litemove                                         
   move  X:litewink,A                            
   move  #>1,X0                                  
   add   X0,A     #>360,X1                       
   cmp   X1,A                                    
   jmi   lite_ok                                 
   sub   X1,A                                    
lite_ok                                          
   move  A1,X:litewink                           
   move  A,X0                                    
   move  #359,M4                                 
   jsr   sincos                                  
   rep   #9             ; fractionale Sinus-     
   asr   A              ; und Cosinuswerte       
   asr   A        X:weltz,R0 ; 10 Bits nach      
   rep   #9             ; rechts shiften fÅr     
   asr   B              ; Radius = 8192          
   asr   B        X:welty,R1                     
   move  A1,Y:(R0)                               
   move  X:weltx,R0                              
   move  B1,Y:(R1)                               
   move  B1,Y:(R0)                               
   move  #$FFFF,M4                               
   rts                                           
