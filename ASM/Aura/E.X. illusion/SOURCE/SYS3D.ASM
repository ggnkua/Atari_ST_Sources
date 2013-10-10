; This file contains the complete (small) DSP-3D-System.
; (C) Copyright 1995 by Jochen Knaus, AURA.

; ****************************************************************************
; Verschiedene Transformationeroutinen inkl. primitivem FlÑchenhandler.
; Hauptroutinen laufen im internen P-Ram.

; Transformationsrout:       - Rotation um bel. Punkt ohne Projektion.
;                            - Rotation um Ursprung ohne Projektion mit Trans-
;                              lation.
;                            - Rotation um bel. Punkt mit Projektion.
; FlÑchhandler:              - Berechnet mittleren z-Wert des transformierten
;                              zs.
;                            - Sortier Bubblesort, gibt FlÑchenidentifys,
;                              clippt an Beobachterebene.
; Bemerkungen:       ; *** Schlieûen noch nicht 100% geteste Komponenten ein.

; Version: 2.4
; (c) 1994 Thinx World
; (c) 1994 AURA

; ACHTUNG. Teilweise speziell fÅr "E.X Illusion" modifiziert.
; ****************************************************************************

; ============================================================================
; Tranformationsroutine mit perspektivischer Projektion auf einen Fluchtpunkt
; und Drehung um einen beliebigen Punkt.
; Allgemeine Routine, Anzahl, Art mÅssen vom Host Åbergeben werden.
; ============================================================================

; Version:           2.4
; Date:              7.7.1993  First Date: Somewhen in April/Mai
; Transformupdate:   31.7.1994
; Handlerupdate:     16.8.1994
; Coder:             Jochen Knaus aka BDC/AURA

; The better ones said: NO-NO-NO-NO-NO-NOT ONE OF US !
; ============================================================================

            OPT      CC

P_IADR      EQU      $0            ; Adresse Punkte im internen          [L]
P_XSIN      EQU      $1000         ; Adresse Sinustabelle          [X], 1024
P_START     EQU      $200          ; Programmadresse                     [P]
P_KOORDS    EQU      $300          ; Koordinatenbuffer                   [L]
ADS_END     EQU      $b0           ; Ende ADS.

ANZ_SIN     EQU      720           ; Anz. EintrÑge in Sinustabelle
ANZ_PUNKTE  EQU      400           ; Max. Anzahl Punkte
MAX_ANZ_FAC EQU      400           ; Max. Anzahl FlÑchen (max. 2*ANZ_PUNKTE!)

SX_OFF      EQU      159
SY_OFF      EQU      119
FLUCHT_Z    EQU      -512          ; Fluchtpunkt-z
PROJEKT     EQU      -256          ; Ausgleich der Zentralprojektion (*)
; (*) Projektion projeziert auch Objekte sichtbar, die eigentlich hinter
;     dem Beobachter liegen.

      INCLUDE        "f:\pool.dsp\defs\periphal.asm"
      INCLUDE        "f:\pool.dsp\macros\g_macros.asm"

      ORG   X:P_IADR
paras:      DS       9             ; Transformationsparameter
winkel:     DS       3             ; Winkel (vom Host)

      ORG   Y:P_IADR
visibles:   DS       1             ; Anzahl sichtbarer FlÑchen
koo_buf:    DS       3             ; Koordinatenbuffer
anz_faces:  DS       1             ; Anzahl sichtbare Polygone
tab_1_pro:  DC       0,0.999999999999,0.5,0.333333333333,0.25,0.2

      ORG   L:(P_IADR+40)
command:                           ; Kommando                           [x]
anz_koo:    DS       1             ; Anzahl zu transformierender Koords [y]
beo:        DS       2

      ORG   L:P_KOORDS
koords:     DS       ANZ_PUNKTE*2  ; 3D-Urkoordinaten
dest_koo:   DS       ANZ_PUNKTE    ; Zielpunkte x/y
tra_z:      DS       ANZ_PUNKTE+2  ; Transform. z, Farben
faces_sort: DS       MAX_ANZ_FAC

      ORG   X:P_XSIN               ; Sinustabelle (0.5  Grad) einbinden.
sinus:
            INCLUDE  "f:\pool.dsp\transpro.20b\sin720.tab"

      ORG   Y:P_XSIN
faces:      DS       MAX_ANZ_FAC*(2+3+2)

      ORG   P:ADS_END              ; Direkt hinter ADS ins I-Ram.
; /////////////////////////////////////////////////////////////////////////////
; /// Ur-Koordinaten transformieren (nach gewÑhltem Modus).                 ///
; /////////////////////////////////////////////////////////////////////////////
trans:
      move  #koords,r0                            ; Urkoordinaten
      move  #beo,r1                               ; Beobachter od. Skalierung
      move  #dest_koo,r2                          ; Buffer projezierte Punkte
      move  #paras,r3                             ; Transformationsparameter
      move  #tra_z,r5                             ; z-Buffer
      move  #koo_buf,r6                           ; Koordinatenbuffer i-Ram
      move  r1,r4                                 ; Beo.standpunktpointer

      move  #-8,n3                                ; RÅckoffset Parameter
      move  #SX_OFF,n4                            ; Screenoffset x
      move  #2,n5                                 ; Offset nÑchster Punkt
      move  #-2,n6                                ; Offset auf X (X/Y/Z)

      move           L:command,x                  ; Commando // Anzahl Punkte.
      jset  #0,x1,tra_sans_pro                    ; Mode != 0 --> mit Projekt.

      do    x0,end_trans                          ; Alle Punkte transformieren

      move           L:(r0)+,ab                   ; Urpunkt x/y
      move           X:(r1)+,x1    Y:(r4),y1      ; Beobachterkoo. x // y
      sub   x1,a     X:(r1)-,x0                   ; x-=bx   // bz
      sub   y1,b     X:(r0)+,a     a,Y:(r6)+      ; y-=by   // z // s. tx
      sub   x0,a                   b,Y:(r6)+      ; z-=bz   // r2++ // s.ty
      move                         a,Y:(r6)+n6    ; s. tz

      move           X:(r3)+,x0    Y:(r6)+,y0     ;              P. A // x
      mpy   x0,y0,a  X:(r3)+,x0    Y:(r6)+,y0     ; x' =A*x   // P. B // y
      mac   x0,y0,a  X:(r3)+,x0    Y:(r6)+n6,y0   ; x'+=B*y   // P. C // z
      macr  x0,y0,a  X:(r3)+,x0    Y:(r6)+,y0     ; x'+=C*z   // P. D // x

      mpy   x0,y0,b  X:(r3)+,x0    Y:(r6)+,y0     ; y' =D*x   // P. E // y
      mac   x0,y0,b  X:(r3)+,x0    Y:(r6)+n6,y0   ; y'+=E*y   // P. F // z
      macr  x0,y0,b  X:(r3)+,x0    Y:(r6)+,y0     ; y'+=F*z   // P. G // x
      move           a,X:(r5)                     ; s. x'

      mpy   x0,y0,a  X:(r3)+,x0    Y:(r6)+,y0     ; z' =G*x   // P. H // y
      mac   x0,y0,a  X:(r3)+n3,x0  Y:(r6)+n6,y0   ; z'+=H*y   // P. I // z
      macr  x0,y0,a                b,Y:(r5)+      ; z'+=I*z   // s. y'
      clr   b        #>FLUCHT_Z,x0                ; Fz

      sub   x0,a     a,X:(r5)-     a,y1           ; z'-=Fz // s. z' // s. z'
      move           a,y0          #>1,a          ; Nenner // a=1

      andi  #$fe,ccr                              ; 1/(z'-Fz) berechnen !
      rep   #24
      div   y0,a                                  ; (der DSP mag das nicht...)

      move                         a0,y0          ; Faktor 1/(z'-Fz)
      move           X:(r5),x1                    ; x'
      mpy  -x0,x1,a                Y:(r5),x1      ; xe  = -Fz*x'  // y'
      mpy  -x0,x1,a  a0,x0                        ; ye  = -Fz*y'  // s. xe
      mpyr  x0,y0,a  a0,x0                        ; xe /= (z'-Fz) // s. ye
      mpyr  x0,y0,a  a,x0          #>SY_OFF,b     ; ye /= (z'-Fz) // s. xe // so
      addr  b,a                    n4,b           ; ye  = ye/2+so // sox
      tfr   x0,a                   a,Y:(r2)       ; xe // s. ye
      addr  b,a      y1,X:(r5)+                   ; xe  = xe/2+sox // s. z'
      move           a,X:(r2)+                    ; s. xe
end_trans:
      rts                                         ; Transformationsende.

tra_sans_pro:                                     ; Punkte ohne Projektion
      do    x0,_rts                               ; transformieren.

      move           L:(r0)+,ab                   ; Urpunkt x/y
      move           X:(r1)+,x1    Y:(r4),y1      ; move_x // move_y
      move                         a,Y:(r6)+
      move           X:(r0)+,x0    b,Y:(r6)+
      move                         x0,Y:(r6)+n6

      move           X:(r3)+,x0    Y:(r6)+,y0     ;              P. A // x
      mpy   x0,y0,a  X:(r3)+,x0    Y:(r6)+,y0     ; x' =A*x   // P. B // y
      mac   x0,y0,a  X:(r3)+,x0    Y:(r6)+n6,y0   ; x'+=B*y   // P. C // z
      macr  x0,y0,a  X:(r3)+,x0    Y:(r6)+,y0     ; x'+=C*z   // P. D // x
      add   x1,a     X:(r1)-,x1                   ; x'+=move_x // move_z

      mpy   x0,y0,b  X:(r3)+,x0    Y:(r6)+,y0     ; y' =D*x   // P. E // y
      mac   x0,y0,b  X:(r3)+,x0    Y:(r6)+n6,y0   ; y'+=E*y   // P. F // z
      macr  x0,y0,b  X:(r3)+,x0    Y:(r6)+,y0     ; y'+=F*z   // P. G // x
      add   y1,b     a,X:(r2)                     ; y'+=move_y // s. x'

      mpy   x0,y0,a  X:(r3)+,x0    Y:(r6)+,y0     ; z' =G*x   // P. H // y
      mac   x0,y0,a  X:(r3)+n3,x0  Y:(r6)+n6,y0   ; z'+=H*y   // P. I // z
      macr  x0,y0,a                b,Y:(r2)+      ; z'+=I*z   // s. y'
      add   x1,a                                  ; z'+=move_z
      move           a,X:(r5)+                    ;              s. z'
_rts: 
      rts

; +-------------------------------------------------------------------------+
; | Bubblesortroutine sollte im P-I-Ram liegen !                            |
; +-------------------------------------------------------------------------+
      INCLUDE        "F:\POOL.DSP\B_SORT\SORT.ASM"

      ORG   P:P_START                      ; Transrout sollte im I-Ram liegen.

; /////////////////////////////////////////////////////////
; /// Vorberechnung der 9 Transformationsparameter.     ///
; ///                                                   ///
; /// r0-r6 werden zerstîrt, Parameter nach: "paras"(X) ///
; /////////////////////////////////////////////////////////
calc_paras:
      move           #winkel,r3
      move           #sinus,x0                    ; Pointer auf Sinustab.
      move           #>ANZ_SIN/4,n0               ; Off. sin=>cos
      movec          #>ANZ_SIN-1,m0               ; Ringbuffer aufbauen

      move           X:(r3)+,a                    ; Winkel a
      add   x0,a     X:(r3)+,b                    ; Poi. sin(a) // Win. b
      add   x0,b     a,r0                         ; Poi. sin(b) // s.   Poi.
      move           X:(r3)+,a                    ; Winkel c
      add   x0,a     b,r1                         ; Poi. sin(c) // s.   Poi.
      move           a,r2                         ;                  s. Poi.

      move  n0,n1                                 ; Ringbuffer und COS-
      move  n0,n2                                 ; Offsets auf alle 3
      movec m0,m1                                 ; Register.
      movec m0,m2

      move  #koo_buf+0,r4                         ; Cosinuswerte im y-Ram
      move  #koo_buf+1,r5                         ; "zwischenlagern"
      move  #koo_buf+2,r6
      move           X:(r0+n0),x0                 ; cos(a)
      move           X:(r1+n1),x1                 ; cos(b)
      move           X:(r2+n2),y1                 ; cos(c)
      move                         x0,Y:(r4)
      move                         x1,Y:(r5)
      move                         y1,Y:(r6)

; Parameter:    A = cos(b)*cos(c)
;               B = cos(b)*sin(c)
;               C = -sin(b)
;               D = sin(a)*sin(b)*cos(c) - cos(a)*sin(c)
;               E = sin(a)*sin(b)*sin(c) + cos(a)*cos(c)
;               F = sin(a)*cos(b)
;               G = cos(a)*sin(b)*cos(c) + sin(a)*sin(c)
;               H = cos(a)*sin(b)*sin(c) - sin(a)*cos(c)
;               I = cos(a)*cos(b)

      move           #paras,r3                    ; Parameterbuffer

      move           X:(r2),x0     Y:(r5),y0      ; sin(c) //   cos(b)
      move           X:(r1),a      ;Y:(r6),y1     ; sin(b) //   cos(c)

      mpyr  y0,y1,b  X:(r0),x1                    ; A   // sin(a)
      mpyr  x0,y0,b  b,X:(r3)+     a,y0           ; B   // s. A // y0=sin(b)

      neg   a        b,X:(r3)+                    ; C   // s. B
      mpyr  x1,y0,b  a,X:(r3)+                    ; D1 //   s. C
      move                         b,y0           ; sin(a)*sin(b)
      mpy   y0,y1,b                Y:(r4),x1      ; D2 //   cos(a)
      macr -x0,x1,b                               ; D

      mpy   x0,y0,a  b,X:(r3)+     Y:(r5),y0      ; E1 //   s. D // cos(b)
      macr  x1,y1,a  X:(r0),x1                    ; E   // sin(a)

      mpyr  x1,y0,a  a,X:(r3)+                    ; F   // s. E

      mpy   x0,x1,b  X:(r1),x0     Y:(r4),y0      ; G1 //   sin(b) // cos(a)
      mpyr  x0,y0,a  a,X:(r3)+     Y:(r6),y1      ; G2 //   s. F // cos(c)
      move           a,x0                         ; x0=cos(a)*sin(b)
      macr  x0,y1,b  X:(r2),y0                    ; G   // sin(c)

      mpy   x0,y0,a  b,X:(r3)+     Y:(r4),y0      ; H1 //   s. G // cos(a)
      macr -x1,y1,a                Y:(r5),y1      ; H   // cos(b)

      mpyr  y0,y1,b  a,X:(r3)+                    ; I   // s. H
      move           b,X:(r3)

      movec m7,m0                                 ; Ringbuffer auflîsen
      movec m7,m1                                 ; und wieder auf lineare
      movec m7,m2                                 ; Zugriffe
      rts                                         ; Ende Parametervorber.

; /////////////////////////////////////////////////////////////////////////////
; ///                                                                       ///
; /// Holt Parameter und Koordinaten vom Host und gibt transformierte Werte ///
; /// zurÅck.                                                               ///
; /// öbertragungsformat:    0.w   - Kommando                       Return  ///
; ///                                 1 : Ohne Projektion / Beo.        3D  ///
; ///                                 2 : Projektion, Beo               2D  ///
; ///                                 4 : Projektion, Beo            2D, z  ///
; ///                                 Bit 7 gesetzt: Punkte/FlÑchen wie     ///
; ///                                                bisher.                ///
; ///                        1.w   - Anzahl Koordinaten                     ///
; ///                        2.w   - Beobachter x oder Skalierung x (*)     ///
; ///                        3.w   - Beobachter y                           ///
; ///                        4.w   - Beobachter z                           ///
; ///                        5.w   - Winkel a                               ///
; ///                        6.w   - Winkel b                               ///
; ///                        7.w   - Winkel c                               ///
; ///                        8.w   - P[0].x                                 ///
; ///                        9.w   - P[0].y                                 ///
; ///                       10.w   - P[0].z   (Alle Punkte durchgeben)      ///
; ///                                                                       ///
; ///                        0.w   - Anzahl FlÑchen: 0 = KEINE              ///
; ///                        2.w   - FlÑche 1: Anzahl Eckpunkte             ///
; ///                        4.w   - FlÑche 1: Eckpunkt[0]                  ///
; ///                        ...                                            ///
; ///                                                                       ///
; /// (*) Im Mode 1 Translation ansondsten Beobachter.                      ///
; ///                                                                       ///
; /////////////////////////////////////////////////////////////////////////////
versorge_host:
      move  #koords,r0                            ; Koordinatenbuffer
      move  #winkel,r1                            ; Winkel
      move  #beo,r2                               ; Beobachter oder Skalierung

      RX_HOST        y1                           ; Commando
      RX_HOST        y0                           ; Anzahl Koordinaten
      RX_HOST        X:(r1)+                      ; Winkel holen
      RX_HOST        X:(r1)+
      RX_HOST        X:(r1)+
      RX_PNT3D       r2                           ; Beobachter oder Translation.

; Sollen komplette Daten der letzten Trans. benutzt werden ?
      jset  #4,y1,keine_flaechen

      do    y0,get_koords                         ; Alle Koordinaten holen.
      RX_PNT3Di      r0
get_koords:
      move                         y,L:command    ; Kommando und Anzahl global

; +---------------------------------+
; | FlÑchenstruktur vom Host holen. |
; +---------------------------------+
      clr   a                      #faces,r4
      RX_HOST        x0                           ; Anzahl FlÑchen holen.
      tfr   x0,a     a,r3          
      tst   a                      x0,Y:anz_faces
      jeq   keine_flaechen

      do    a,get_face                            ; FlÑchen
      RX_HOST                      Y:(r4)+        ; Off. Weltkoorarray
      move                         r3,Y:(r4)+     ; FlÑchenidentify
      RX_HOST                      Y:(r4)         ; Anzahl Eckpunkte
      do    Y:(r4)+,get_ecks                      ; Eckpunkte holen
      RX_HOST                      Y:(r4)+
get_ecks:
      move  (r3)+                                 ; FlÑchenid.++
get_face:

keine_flaechen:
      jsr   calc_paras                            ; Tranformationsparameter
      jsr   trans                                 ; berechnen und transf.

; +-----------------------------------------------------------------+
; | Sollten einige FlÑchen zu behandeln sein, werden sie das nun... |
; +-----------------------------------------------------------------+
      move  #dest_koo,r0                          ; projezierte Punkte
      move  #tra_z,r1                             ; transformierte zs
      move  #faces,r6                             ; Polygonarrays
      move                         Y:anz_faces,a
      tst   a                      a,y1
      jsgt  do_faces                              ; FlÑchen sortieren etc...

      move  #dest_koo,r0
      move  #tra_z,r1
      move                         L:command,y    ; Kommando und Anzahl Pu.
      
      jset  #1,y1,send_2                          ; Mode 1: Nur x/y schicken

      do    y0,send_all_1                         ; 3D-Koordinate oder 2D & z
      TX_PNT2Di      r0                           ; schicken.
      TX_HOST        X:(r1)+
send_all_1:
      rts                                         ; <return>

send_2:                                           ; Nur projezierte Koordinaten
      do    y0,send_all_2                         ; schicken.
      TX_PNT2Di      r0
send_all_2:
      rts

; 
;  FlÑchenhandler. UnterdrÅckt, sortiert und sendet Host die               
;  sichtbaren FlÑchen als ID.                                              
;                                                                          
;  Version:         0.1                                                    
;  Started Mai 1994, Update: 28.6.1994                                     
;  Update:          6.7.1994                                               
;                                                                          
;  y1 - Anzahl FlÑchen.                                                    
;  r0 - Adresse projezierte Punkte (X/Y)                                   
;  r1 - transformierte zs                                                  
;  r6 - Adresse FlÑchenarray (Y-Ram).                                      
; 
do_faces:
      clr   a        r0,n3                        ; Basis-punkteadr.
      clr   b        #faces_sort,r4
      move  r1,n4                                 ; Basis-zadr.
      move  a,r3                                  ; Anz. sichtbare FlÑchen = 0

      do    y1,all_faces                          ; Alle Polygone durchgehen.

      move  n3,a                                  ; Punktebase
      move  n4,b                                  ; z-Base
      move                         Y:(r6)+,y0     ; Punktebase // Punkteoffset
      add   y0,a                   Y:(r6)+,y1     ; Punktadr. // Polyidentify
      add   y0,b     a,r0                         ; Adressregs mit Punktadr.
      move           b,r1                         ; laden.
      move           a,r2
      move                         y1,Y:(r4)      ; Polyid. add. Wert bei Sort

      lua   (r6)+,r5                              ; Anz. Punkt z. nicht
      move                         Y:(r6)+,n5     ; Anz. Punkte...
      move                         Y:(r6)+,n0     ; P1
      move                         Y:(r6)+,n2     ; P2
      move           L:(r0+n0),x                  ; P1.x // P1.y
      move                         Y:(r6),n0      ; P3
      move           L:(r2+n2),ab                 ; P2.x // P2.y
      sub   x1,a                                  ; a = P2.x-P1.x
      sub   x0,b     X:(r0+n0),a   a,y0           ; b = P2.y-P1.y // P3.x // s. a
      sub   x1,a                   b,y1           ; c = P3.x-P1.x // s. b
      move                         Y:(r0+n0),b    ; P3.y
      sub   x0,b     a,x0                         ; d = P3.y-P1.y // s. c
      mpy  -x0,y1,a  b,x1                         ; -b*c // s. d
      mac   x1,y0,a                r5,r6          ; +a*d // Punkte
      jlt   invisible

      move           #>PROJEKT,x0
      clr   a                      n5,n6          ; dadd = 0 // Anz. Punkte
      tfr   x0,b                   a,y0           ; Bx = z[0] = 0

      move                         Y:(r6)+,n1     ; P0
      do    n5,calc_dz                            ; z
      add   y0,a     X:(r1+n1),y0                 ; z += z[n]
      cmp   y0,b                   Y:(r6)+,n1     ; Punkt vor Viewer ?
      tlt   y0,b
calc_dz:
      add   y0,a                   #tab_1_pro,r6  ; Letzter Add // 1/x-Tabelle
      cmp   x0,b     a,x1                         ; Vor Beo ? // dz
      jeq   invisible                             ; Kein Punkt vor Beo.

      move                         Y:(r6+n6),y0   ; 1/Anz.Pu.
      mpy   x1,y0,a  (r3)+                        ; FlÑchencount++
      move           a,X:(r4)+                    ; Zu sortierender Wert

invisible:
      lua   (r5)+n5,r6                            ; NÑchste FlÑche.
      nop                                         ; r6-access direkt hinter do
all_faces:

      move  r3,x0                                 ; Anzahl sichtbare Polys.
      move                         x0,Y:visibles
      tfr   x0,a     #faces_sort,r0               ; Mehr als eine sicht. Fl.:
      tst   a
      jsgt  sort                                  ; Sortieren...

      move                         Y:visibles,a
      TX_HOST        a                            ; Anzahl sichtb. FlÑchen
      tst   a        #faces_sort,r0
      jle   send_faces

      do    a,send_faces
      TX_HOST                      Y:(r0)+        ; FlÑchenid. senden.
send_faces:
      rts

; +-------------------------------------------------------------------------+
; | Hauptprogramm.                                                          |
; +-------------------------------------------------------------------------+
main:
      ; Das ist gegen ein Trackerproblem !
      bclr  #3,X:<<$ffe8

      jsr   versorge_host
      jmp   main

      DC    'Transrout, DSP-System by Jochen Knaus, Version 2, universal. '
      DC    'Date: April 1993. Last Update: March 1995.'
      END   main