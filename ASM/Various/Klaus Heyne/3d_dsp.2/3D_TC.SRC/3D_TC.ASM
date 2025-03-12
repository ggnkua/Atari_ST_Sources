;------------------------------------------------
; DSP als Grafik-Koprozessor
; DSP-Listing 1 und 2
;                      (c) 1995 by MAXON-Computer
;                      Autor: Klaus Heyne         
;------------------------------------------------
M_BCR     equ   $FFFE      ; Bus-Control-Register
M_PBC     equ   $FFE0      ; Port B Ctrl-Register
HCR       equ   $FFE8      ; Host-Ctrl-Register  
HSR       equ   $FFE9      ; Host-Status-Register
HRX       equ   $FFEB      ; Host-Receive-Reg.   
HTX       equ   $FFEB      ; Host-Transmit-Reg.  
I_RESET   equ   $0000      ; Reset-Vektor        
MAIN      equ   $0070      ; Programm-Start      
;------------------------------------------------
   org   P:I_RESET         ; Reset-Vektor        
   jmp   START                                   
;------------------------------------------------
;  Programm-Code                                 
;------------------------------------------------
   org   P:MAIN                                  
START                                            
;------------------------------------------------
;  DSP-Initialisierung                           
;------------------------------------------------
   reset                                         
   movep #0,X:M_BCR        ; no wait states      
   movep #>1,X:M_PBC       ; port B = host       
;------------------------------------------------
; Hauptschleife                                  
;------------------------------------------------
mainloop                                         
   jclr  #0,X:<<HSR,mainloop  ; Kommando vom     
   movep X:<<HRX,X0           ; Host-Prozessor   
   jset  #0,X0,data_init      ; entgegennehmen   
   jset  #1,X0,transform      ; und ausfÅhren.   
   jset  #8,X0,data_out                          
   jmp   mainloop                                
;------------------------------------------------
; Transformationszyklus                          
;------------------------------------------------
transform                                        
   jsr   data_in     ; Parameter empfangen       
   movep #$08,X:HCR  ; busy-flag setzen          
   jsr   mat_init    ; Rot.-Matrix erstellen     
   jsset #4,X:doflag,litemove                    
   move  #bbx,R0     ; Zeiger auf Beobachter-    
   move  X:weltx,R1  ; koordinaten, das Array    
   move  X:welty,R2  ; fÅr das transformierte    
   move  X:weltz,R3  ; System                    
   move  X:beo_x,R5  ; und die Weltkoordinaten   
   move  X:beo_y,R6  ; setzen, Punktanzahl       
   move  X:beo_z,R7  ; als SchleifenzÑhler       
   move  X:anzpkt,N0 ; in N0 Åbergeben und       
   jsr   translate   ; Weltsystem durch          
   move  X:beo_x,R5  ; Translation und...        
   move  X:beo_y,R6                              
   move  X:beo_z,R7  ; ...Rotation ins System    
   move  X:anzpkt,N0 ; des Beobachters           
   jsr   rotate      ; ÅberfÅhren. Sichtbare     
   jsr   hiddenline  ; FlÑchen u. deren Licht-   
   move  X:beo_x,R5  ; intensitÑten berechnen.   
   move  X:beo_y,R6                              
   move  X:beo_z,R7                              
   move  X:anzpkt,N0 ; Berechnung der Bild-      
   jsr   pers        ; schirmkoordinaten         
   jsr   movecalc    ; Bewegungsrichtungen be-   
   movep #$00,X:HCR  ; rechnen, busy-flag lîschen
   jmp   mainloop    ; und zur "Kommandozentrale"
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
;----------------------------------------------- 
; Lichtquelle auf Kreis um x- u. y-Achse bewegen 
;----------------------------------------------- 
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
;------------------------------------------------
; Rotationsmatrix erstellen                      
;------------------------------------------------
mat_init                ; Matrix A als           
   move  #matrix_A,R1   ; Einheitsmatrix         
   move  #0,X1          ; initialisieren.        
   move  #$7FFFFF,Y1    ; Y1=0.999999...         
   move  Y1,X:(R1)+     ; ("+1" ist im fraktion- 
   move  X1,X:(R1)+     ; len Zahlenformat nicht 
   move  X1,X:(R1)+     ; definiert!)            
   move  X1,X:(R1)+                              
   move  Y1,X:(R1)+                              
   move  X1,X:(R1)+     ; Einheitsmatrix:        
   move  X1,X:(R1)+     ;     1   0   0          
   move  X1,X:(R1)+     ; A = 0   1   0          
   move  Y1,X:(R1)+     ;     0   0   1          
                                                 
   move  #359,M4        ; MOD 360 fÅr Sinus-     
                        ; tabellenzugriff        
   move  #matrix_B,R7   ; Matrix B               
   move  X:ywinkel,X0   ; sin(yw) und            
   jsr   sincos         ; cos(yw) ermitteln      
                                                 
   move  B,Y:(R7)+      ; Matrix B fÅr die       
   neg   A  X1,Y:(R7)+     ; Rotation um die y-Ac
   move  A,Y:(R7)+      ; initialisieren:        
   move  X1,Y:(R7)+     ;     cos  0  -sin       
   move  Y1,Y:(R7)+     ; B = 0    1   0         
   neg   A  X1,Y:(R7)+  ;     sin  0   cos       
   move  A,Y:(R7)+                               
   move  X1,Y:(R7)+                              
   move  B,Y:(R7)                                
                        ; Matrixmultiplikation:  
   jsr   matmult        ; C = A * B. Ergebnis    
                        ; nach A kopieren        
   move  #matrix_B,R7   ; Matrix B               
   move  X:xwinkel,X0   ; sin(xw) und            
   jsr   sincos         ; cos(xw) ermitteln      
                                                 
   move  Y1,Y:(R7)+     ; Matrix B fÅr die       
   move  X1,Y:(R7)+     ; Rotation um die x-Achse
   move  X1,Y:(R7)+     ; initialisieren:        
   move  X1,Y:(R7)+     ;     1    0    0        
   move  B,Y:(R7)+   ; B = 0    cos  sin         
   move  A,Y:(R7)+      ;     0   -sin  cos      
   neg   A  X1,Y:(R7)+                           
   move  A,Y:(R7)+                               
   move  B,Y:(R7)                                
                        ; Matrixmultiplikation:  
   jsr   matmult        ; C = A * B. Ergebnis    
                        ; nach A kopieren        
   move  #matrix_B,R7   ; Matrix B               
   move  X:zwinkel,X0   ; sin(zw) und            
   jsr   sincos         ; cos(zw) ermitteln      
                                                 
   move  B,Y:(R7)+   ; Matrix B fÅr die          
   move  A,Y:(R7)+      ; Rotation um die z-Achse
   neg   A  X1,Y:(R7)+  ; initialisieren:        
   move  A,Y:(R7)+      ;      cos  sin  0       
   move  B,Y:(R7)+      ; B = -sin  cos  0       
   move  X1,Y:(R7)+     ;      0    0    1       
   move  X1,Y:(R7)+                              
   move  X1,Y:(R7)+                              
   move  Y1,Y:(R7)                               
                        ; Matrixmultiplikation:  
   jsr   matmult        ; C = A * B. Ergebnis    
   move  #$FFFF,M4      ; nach A kopieren        
   rts                  ; A=allg. Rotationsmatrix
;------------------------------------------------
; Translation: Ursprung des Weltsystems an die   
; Position des Beobachters verschieben           
;------------------------------------------------
translate                                        
   move  X:(R0)+,X0       ; bbx                  
   move  X:(R0)+,Y0       ; bby                  
   move  X:(R0),X1        ; bbz                  
   do    N0,trans                                
   move  Y:(R1)+,A        ; von allen Punkt-     
   sub   X0,A  Y:(R2)+,B  ; koordinaten die      
   sub   Y0,B  A1,Y:(R5)+ ; Koordinaten          
   move  B1,Y:(R6)+       ; des Beobachters      
   move  Y:(R3)+,A        ; subtrahieren         
   sub   X1,A                                    
   move  A1,Y:(R7)+                              
trans                                            
   rts                                           
;------------------------------------------------
; Rotation: Das System durch Multiplikation aller
; Punkte mit der Rotationsmatrix um die drei     
; Blickwinkel des Beobachters rotieren           
;------------------------------------------------
rotate                                           
   move  #matrix_A,R3      ; Rotationsmatrix A   
   move  #>3,N3            ; spaltenweise mit    
   do    N0,rotit          ; jedem Punkt(vektor) 
   move  Y:(R5),Y0         ; multiplizieren      
   move  Y:(R6),Y1                               
   move  Y:(R7),X0                               
   move  X:(R3)+N3,X1                            
   mpy   X1,Y0,A     X:(R3)+N3,X1                
   mac   X1,Y1,A     X:(R3),X1                   
   macr  X1,X0,A     #matrix_A+1,R3              
   move  A1,Y:(R5)+                              
   move  X:(R3)+N3,X1                            
   mpy   X1,Y0,A     X:(R3)+N3,X1                
   mac   X1,Y1,A     X:(R3),X1                   
   macr  X1,X0,A     #matrix_A+2,R3              
   move  A1,Y:(R6)+                              
   move  X:(R3)+N3,X1                            
   mpy   X1,Y0,A     X:(R3)+N3,X1                
   mac   X1,Y1,A     X:(R3),X1                   
   macr  X1,X0,A     #matrix_A,R3                
   move  A1,Y:(R7)+                              
rotit                                            
   rts                                           
;------------------------------------------------
; Perspektive-Transformation: öbertragung aller  
; Punktkoordinaten ins zweidimensionale Bild-    
; schirmsystem durch Zentralprojektion.          
;------------------------------------------------
pers                                             
   do    N0,persloop     ; Projektionsfaktor:    
   move  Y:(R7)+,Y1      ;      ebenez - z       
   move  X:ebenez,A      ; t = ------------      
   move  X:projektz,B    ;      projektz - z     
   sub   Y1,B  Y:(R5),X1 ; X1 = x-Koordinate     
   sub   Y1,A  Y:(R6),Y0 ; Y0 = y-Koordinate     
   tst   B     B,X0      ; Spezialfall abfangen: 
   jle   pers_2          ; (projektz - z)=<0     
   move  #0,R0           ; Flag: fract. Division 
   jsr   divide          ; Faktor t ermitteln    
   tfr   X1,B  A1,X0     ; x nach B, t nach X0   
   mac   -X0,X1,B Y0,A       ; x'= x - x*t ; A=y 
   mac   -X0,Y0,A X:xmit,X1  ; y'= y - y*t       
   neg   A        X:ymit,Y0                      
   add   X1,B            ; Bildmitte addieren    
   add   Y0,A            ; Schirmkoordinaten im                               
   move  B,Y:(R5)+       ; beo_x- und beo_y-
ret_2                    ; Array speichern              
   move  A,Y:(R6)+           
persloop                                
   rts                                       
pers_2                   ; Hinter dem Brennpunkt
   tfr   X1,B   #$7FFF,A ; liegenden Punkten -
   tst   B      #$FF8000,X0 ; abhÑngig vom Vor-
   tmi   X0,A               ; zeichen - den
   tfr   Y0,B   A,Y:(R5)+   ; grîûten bzw.
   tst   B      #$7FFF,A    ; kleinsten 16-Bit-
   tgt   X0,A               ; Wert zuweisen.
   jmp   ret_2                  
;------------------------------------------------
; Sinus und Cosinus ermitteln ( M4 = #359 !)     
; -> winkel in X0           A=sinus, B=cosinus ->
;------------------------------------------------
sincos                                           
   move  #sintab,A      ; Zeiger auf Sinustabelle
   add   X0,A  #>90,N4  ; Winkel addieren        
   move  A1,R4          ; N4=Offset auf Cosinus  
   nop                                           
   move  Y:(R4)+N4,A    ; sin holen, Adr. erhîhen
   move  Y:(R4),B       ; cos holen              
   rts                                           
;------------------------------------------------
; Matrixmultiplikation: A * B = C                
; Ergebnis wieder nach Matrix A kopieren.        
; (Quelle: DSP-Source-Codes des ATARI Falcon030  
; Toolkit, geringfÅgig modifiziert)              
;------------------------------------------------
matmult                                          
   move  #matrix_A,R0   ; Zeiger auf Matrix A    
   move  #matrix_B,R4   ; Zeiger auf Matrix B    
   move  #matrix_C,R6   ; Zeiger auf Matrix C    
   move  #3,N0          ; 2. Dimension von A     
   move  N0,N5          ; 2. Dimension von B     
   do    #3,_ew         ; Zeilenanzahl           
   do    #3,_ez         ; Spaltenanzahl          
   move  R0,R1          ; Zeiger kopieren        
   move  R4,R5                                   
   clr   A                                       
   move  X:(R1)+,X0  Y:(R5)+N5,Y0                
   rep   #2                                      
   mac   X0,Y0,A  X:(R1)+,X0  Y:(R5)+N5,Y0       
   macr  X0,Y0,A  (R4)+ ; nÑchste Spalte in B    
   move  A,Y:(R6)+      ; Ergebnis speichern     
_ez                                              
   move  (R0)+N0        ; nÑchste Reihe in A     
   move  #matrix_B,R4   ; Zeiger wieder auf      
_ew                     ; 1. Spalte in B         
   move  #matrix_C,R6   ; Ergebnismatrix C       
   move  #matrix_A,R0   ; nach Matrix A          
   do    #9,copymat     ; kopieren               
   move  Y:(R6)+,X0                              
   move  X0,X:(R0)+                              
copymat                                          
   rts                                           
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
   clr   B        B,Y1  ; B wird VOR dem Lîsche
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
; Division: A1=A/X0    mit X0 > 0;               
; -> A = Dividend, X0=Divisor (>0!)              
;    R0 = 0 fÅr fractionale Division             
;    R0 = 2 fÅr Integer-Division                 
;------------------------------------------------
divide                                           
   tst   A         ; Vorzeichen des Dividenden   
   jeq   div_rts   ; prÅfen: A=0 => A/X0=0       
   jgt   divide2                                 
   neg   A   (R0)+ ; Negationsflag setzen,       
divide2            ; Divident positiv machen     
   jclr  #1,R0,divide3                           
   move  A1,A0     ; FÅr Integerdivision mit     
   move  #0,A1     ; Integerergebnis Divident in 
divide3            ; A0 Åbergeben                
   and   #$FE,CCR  ; Vereinfachter Divisions-    
   rep   #24       ; algorithmus fÅr positive    
   div   X0,A      ; Zahlen                      
   move  A0,A1     ; 24-Bit-Ergebnis nach A1     
   move  #0,A0     ; A0 lîschen                  
   move  #0,A2     ; A2 lîschen                  
   jsset #0,R0,divneg                            
   jsset #1,R0,divcorr                           
div_rts                                          
   rts                                           
divcorr                                          
   lsl   A         ; Ergebnis verdoppeln         
   rts             ; ("Integerkorrektur")        
divneg                                           
   neg   A         ; Ergebnis negieren           
   rts             ; (Vorzeichenkorrektur)       
;------------------------------------------------
; Host-I/O                                       
; Die öbertragung erfolgt im 030-CPU-freundlichen
; 16-Bit-Format (Dsp_BlkWords), daher mÅssen     
; einige Werte nach 24-Bit gewandelt werden.     
;------------------------------------------------
data_init                                        
   move  #sintab,R0      ; Sinustabelle empfangen
   do    #360,sin_loop                           
get_sin                                          
   jclr  #0,X:HSR,get_sin                        
   movep X:<<HRX,Y:(R0)+                         
sin_loop                                         
   move  #const,R0    ; Objektweltdaten einlesen:
   do    #16,init_loop   ; 16 konstante Parameter
get_const                                        
   jclr  #0,X:HSR,get_const                      
   movep X:<<HRX,X:(R0)+                         
init_loop                                        
   move  #wflach,R0       ; Zeiger auf FlÑchen-  
   do    X:anzfla,flaloop ; strukturen           
get_fla                                          
   jclr  #0,X:HSR,get_fla ; FlÑchendaten einlesen
   movep X:<<HRX,A        ; 16-Bit True-Color    
   rep   #8                                      
   lsl   A                 ; in Bit 23-8 shiften 
get_fla2                   ; und mit Anzahl der  
   jclr  #0,X:HSR,get_fla2 ; Eckpunkte zusammen  
   movep X:<<HRX,X0        ; in einem Word spei- 
   or    X0,A     #>$0F,X0 ; chern, so spart man 
   move  A1,X:(R0)+        ; pro FlÑche ein Word.
   and   X0,A     #>1,X0   ; Eckenanz. ausfiltern
   add   X0,A              ; +1 als Schleifen-   
   do    A1,flaloop2       ; zÑhler              
get_fla3                                         
   jclr  #0,X:HSR,get_fla3 ; Punktindize         
   movep X:<<HRX,X:(R0)+   ; einlesen            
flaloop2                                         
   nop                                           
flaloop                 ; Adresse d. FlÑchen-    
   move  R0,X:fla_list  ; Ausgabeliste speichern 
   move  #welt,R0      ; Weltkoordinaten einlesen
   do    X:p_size,coordloop ; p_size =           
get_coord                   ; Punktanzahl * 3    
   jclr  #0,X:HSR,get_coord ; (x,y,z)            
   movep X:<<HRX,Y:(R0)+                         
coordloop                                        
   move  #>weltx,R0         ; Adressen setzen    
   move  #>welt,A1                               
   move  X:anzpkt,X0        ; Weltkoordinaten:   
   move  A1,X:(R0)+         ; weltx              
   add   X0,A                                    
   move  A1,X:(R0)+         ; welty              
   add   X0,A                                    
   move  A1,X:(R0)+         ; weltz              
   add   X0,A               ; Beobachtersystem:  
   move  A1,X:(R0)+         ; beo_x              
   add   X0,A                                    
   move  A1,X:(R0)+         ; beo_y              
   add   X0,A                                    
   move  A1,X:(R0)          ; beo_z              
   jsr   litemove     ; Lichtquelle positionieren
   jmp   mainloop                                
;------------------------------------------------
data_in                                          
   move  #vars,R0      ; die vom Anwender        
   do    #16,varsloop  ; verÑnderbaren Parameter 
get_vars               ; einlesen                
   jclr  #0,X:HSR,get_vars                       
   movep X:<<HRX,X:(R0)+                         
varsloop                                         
   move  X:litefak,A   ; Lichtfaktor und Licht-  
   rep   #8            ; offset ins 24-Bit-Format
   lsl   A             ; wandeln.                
   move  A1,X:litefak  ; Der Lichtfaktor bestimmt
   move  X:liteoffs,A  ; den Helligkeitsunter-   
   rep   #8            ; schied zwischen direkt  
   lsl   A             ; angestrahlten und im    
   move  A1,X:liteoffs ; Schatten liegenden      
   rts                 ; FlÑchen.                
;------------------------------------------------
data_out                                         
   move  X:anzpkt,A       ; Bildschirmkoordinaten
   lsl   A     X:beo_x,R5 ; ausgeben             
   do    A1,outloop       ; ZÑhler = Punktanz.*2 
p_out                                            
   jclr  #1,X:<<HSR,p_out                        
   movep Y:(R5)+,X:<<HTX                         
outloop                                          
   move  #move_abs,R5     ; Richtungskomponenten 
   do    #9,outloop1      ; ausgeben             
w_out1                                           
   jclr  #1,X:<<HSR,w_out1                       
   movep Y:(R5)+,X:<<HTX                         
outloop1                                         
   nop                                           
fla_out                   ; FlÑchenliste ausgeben
   move  X:anzfla,A       ; Anzahl aller FlÑchen 
   move  A,X1             ; auch nach X1         
   lsl   A     #>1,X0     ; Anzahl der Werte =   
   add   X1,A             ; anzfla * 3 + 1       
   add   X0,A  X:fla_list,R0 ; (3 EintrÑge pro   
   do    A1,outloop2      ; FlÑche plus 1 Wert   
f_out                     ; fÅr die Anzahl der   
   jclr  #1,X:<<HSR,f_out ; sichtbaren FlÑchen   
   movep X:(R0)+,X:<<HTX                         
outloop2                  ; zurÅck zur           
   jmp     mainloop       ; "Kommandozentrale"   
                                                 
;------------------------------------------------
; DATA   X-memory                                
;------------------------------------------------
   org   X:$0     ; interne Variablen:           
weltx    ds 1     ; Adresse der x-Koordinaten    
welty    ds 1     ; Adresse der y-Koordinaten    
weltz    ds 1     ; Adresse der z-Koordinaten    
beo_x    ds 1     ; Adressen der Koordinaten des 
beo_y    ds 1     ; transformierten Systems      
beo_z    ds 1                                    
fla_list ds 1     ; Adr. der FlÑchenausgabeliste 
flacount dc 0     ; FlÑchenzÑhler                
paintfla dc 0     ; dto fÅr sichtbare FlÑchen    
fla_flag dc 0     ; Zwischenspeicher Attribute   
var_1    dc 0     ; Zwischenspeicher             
var_2    dc 0     ; dto                          
var_3    dc 0     ; dto                          
var_4    dc 0     ; dto                          
var_5    dc 0     ; dto                          
var_6    dc 0     ; dto                          
workmemo dc 0     ; Zwischenspeicher             
litewink dc 44    ; Startwinkel der Lichtquelle  
matrix_A dc 0.9999999   ; allgemeine             
         dc 0           ; Rotationsmatrix,       
         dc 0           ; initialisiert als      
         dc 0           ; Einheitsmatrix         
         dc 0.9999999                            
         dc 0                                    
         dc 0                                    
         dc 0                                    
         dc 0.9999999                            
;------------------------------------------------
   org   X:$20    ; Objektwelt-Konstanten        
const                                            
; Dieser Bereich wird einmalig bei der           
; Initialisierung belegt.                        
anzpkt   ds 1     ; Anzahl der Punkte            
anzfla   ds 1     ; Anzahl der FlÑchen           
         ds 2     ; ungenutzt                    
zmax     ds 1     ; Clipping der z-Dimension     
xmit     ds 1     ; Bildschirmmittelpunkt        
ymit     ds 1                                    
p_size   ds 1     ; DatenlÑnge d. Koordinaten    
f_size   ds 1     ; DatenlÑnge d. FlÑchenstruktur
         ds 7     ; ungenutzt                    
;------------------------------------------------
   org   X:$30    ; Objektwelt-Variablen         
vars                                             
; Dieser Bereich wird mit jedem neuen            
; Transformationszyklus neu belegt.              
bbx      ds 1     ; Beobachterkoordinaten        
bby      ds 1                                    
bbz      ds 1                                    
xwinkel  ds 1     ; Beobachter-Blickwinkel       
ywinkel  ds 1                                    
zwinkel  ds 1                                    
projektz ds 1     ; Lage d. Projektionszentrums  
ebenez   ds 1     ; Lage d. Projektionsebene     
litefak  ds 1     ; Lichtfaktor (hier 0.75)      
liteoffs ds 1     ; Lichtoffset = 1-Lichtfaktor  
         ds 5     ; ungenutzt                    
doflag   ds 1     ; Flags fÅr besondere Aufgaben 
;------------------------------------------------
   org   X:$40    ; FlÑchenspeicher              
wflach   ds $4000-$40                            
;------------------------------------------------
; DATA   Y-memory                                
;------------------------------------------------
   org   Y:$40    ; weitere interne Variablen:   
matrix_B ds 9     ; Platz fÅr Matrix B           
matrix_C ds 9     ; Platz fÅr Matrix C           
move_rel dc 32    ; drei im Beobachtersystem     
         dc 0     ; definierte Punkte zur Be-    
         dc 0     ; rechnung der fÅr das Welt-   
         dc 0     ; system gÅltigen x-, y- und   
         dc 32    ; z-Komponenten fÅr die Bewe-  
         dc 0     ; gungen "seitwÑrts", "auf-    
         dc 0     ; wÑrts" und "vorwÑrts", die   
         dc 0     ; ja relativ zur aktuellen     
         dc -32   ; Blickrichtung sein sollen.   
move_abs ds 9     ; Platz fÅr o.g. Komponenten   
;----------------------------------------------- 
   org   Y:$400                                  
;----------------------------------------------- 
sintab   ds 360   ; Platz fÅr Sinustabelle       
         dc 0     ; Sinus (360)                  
;----------------------------------------------- 
   org   Y:$570            ; Koordinatenspeicher 
welt     ds $3C00-$570     ; fÅr 2412 Punkte     
                                                 
                                                 
                                                 

