; /////////////////////////////////////////////////////////////////////////
; Tranformationsroutine mit perspektivischer Projektion auf einen Fluchtpunkt
; und Drehung um einen beliebigen Punkt.
; EinschrÑnkungen:   persp. Proj.:  max.: X/Y/Z mÅssen sich im Raum
; -2000<n<2000 bewegen, um öberlÑufe bei den Integermultiplikationen zu ver-
; meiden.

; Version:           2.0b
; Date:              7.7.1993  First Date: Somewhen in April/Mai
; Last Update:       5.9.1993
; Updates:           5.9.: Einbau der Fluchtpunkt (0/0/Fz) Funktion
; Erweiterungen:     öbergabe der Speicheradressen und Konstanten durch das
;                    Hauptprogramm.

; Coder:             As ever, Jochen Knaus aka BDC/AURA

; The better ones said: NO-NO-NO-NO-NO-NOT ONE OF US !
; /////////////////////////////////////////////////////////////////////////

p_iadr      EQU      $40           ; Adresse Punkte im  internen RAM
p_xsin      EQU      $2400         ; Adresse Sinustabelle (X-Ram, 1024)
p_start     EQU      $800          ; Programmadresse, P-RAM

anz_sin     EQU      720           ; Anz.  EintrÑge in Sinustabelle
anz_punkte  EQU      50            ; Max.  Anzahl Punkte

sx_off      EQU      159
sy_off      EQU      99
r_flucht    EQU      1             ; 0 => (Fx/Fy/Fz) // 1 => (0/0/Fz)

            ORG      X:p_iadr
paras:      DS       9             ; Transformationsparameter
            ORG      Y:p_iadr
koo_buf:    DS       3

            ORG      X:p_xsin
sinus:                             ; Sinustabelle (0.5  Grad) einbinden
            INCLUDE "f:\system\routs\sin720.tab"

; /////////////////////////////////////////////////////////
; /// Vorberechnung der 9 Transformationsparameter.     ///
; /// Parameter:    r3  - Zeiger auf Winkel (a,b,c) (X) ///
; ///                                                   ///
; /// r0-r6 werden zerstîrt, Parameter nach: "paras"(X) ///
; /////////////////////////////////////////////////////////
            ORG      P:p_start
calc_paras:
      move           #sinus,x0                    ; Pointer auf Sinustab.
      move           #>anz_sin/4,n0               ; Off. sin=>cos
      movec          #>anz_sin-1,m0               ; Ringbuffer aufbauen

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
      move           X:(r1),a      Y:(r6),y1      ; sin(b) //   cos(c)

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
; /// Ur-Koordinaten um beliebigen Punkt drehen und auf einen Fluchtpunkt   ///
; /// projezieren.                                                          ///
; /// Parameter:    r0  - Urpunktarray (0.w->Anzahl Punkte!)    (eL)        ///
; ///               r1  - Beobachterstandpunkt                  (iL)        ///
; ///               r2  - [Fluchtpunkt] (optional)              (iL)        ///
; ///               r5  - transformierte Urpunkte (3D; Buffer)  (eL)        ///
; ///               r6  - Punktbuffer (3 Words)                 (iY)        ///
; ///               r7  - Buffer projezierte Punkte             (eL)        ///
; /////////////////////////////////////////////////////////////////////////////
trans:
      move  r1,r4                                 ; Beo.standpunktpointer
      move  #paras,r3
      move  #-8,n3                                ; RÅckoffset Parameter
      move  #2,n5                                 ; Offset nÑchster Punkt
      move  #-2,n6                                ; Offset auf X (X/Y/Z)
      move           X:(r0)+,x0                   ; Anzahl Punkte

      do    x0,end_trans                          ; Alle Punkte transformieren

      move           L:(r0)+,ab                   ; Urpunkt x/y
      move           X:(r1)+,x1    Y:(r4),y1      ; Beobachterkoo. x // y
      sub   x1,a     X:(r1),x0                    ; x-=bx   // bz
      sub   y1,b     X:(r0)+,a     a,Y:(r6)+      ; y-=by   // z // s. tx
      sub   x0,a     X:(r2)+,x0    b,Y:(r6)+      ; z-=bz   // r2++ // s.ty
      move                         a,Y:(r6)+n6    ; s. tz

      move           X:(r3)+,x0    Y:(r6)+,y0     ;              P. A // x
      mpy   x0,y0,a  X:(r3)+,x0    Y:(r6)+,y0     ; x' =A*x   // P. B // y
      mac   x0,y0,a  X:(r3)+,x0    Y:(r6)+n6,y0   ; x'+=B*y   // P. C // z
      macr  x0,y0,a  X:(r3)+,x0    Y:(r6)+,y0     ; x'+=C*z   // P. D // x
      add   x1,a     X:(r1)-,x1                   ; x'+=Beo_x // beo_z

      mpy   x0,y0,b  X:(r3)+,x0    Y:(r6)+,y0     ; y' =D*x   // P. E // y
      mac   x0,y0,b  X:(r3)+,x0    Y:(r6)+n6,y0   ; y'+=E*y   // P. F // z
      macr  x0,y0,b  X:(r3)+,x0    Y:(r6)+,y0     ; y'+=F*z   // P. G // x
      add   y1,b     a,X:(r5)                     ; y'+=Beo_y // s. x'

      mpy   x0,y0,a  X:(r3)+,x0    Y:(r6)+,y0     ; z' =G*x   // P. H // y
      mac   x0,y0,a  X:(r3)+n3,x0  Y:(r6)+n6,y0   ; z'+=H*y   // P. I // z
      macr  x0,y0,a  X:(r2)-,x0    b,Y:(r5)+      ; z'+=I*z   // Fz // s. y'
      add   x1,a     X:(r2),x1                    ; z'+=Beo_y // Fx

      sub   x0,a     a,X:(r5)-     a,y1           ; z'-=Fz // s. z' // s.   z'
      move           a,y0          #>1,a          ; Nenner // a=1

      andi  #$fe,ccr                              ; 1/(z'-Fz) berechnen !
      rep   #24
      div   y0,a                                  ; (FUCK YA SLOW !!!)

   IF r_flucht==1                                 ; Fluchtpunkt:(0/0/Fz) ?
      move                         a0,y0          ; Faktor 1/(z'-Fz)
      mpy  -x0,y0,a  X:(r5),x0                    ; ZE = -Fz/(z'-Fz) // x
      clr   a                      a,y0           ; a1=0 // y0 = ZE
      clr   b        #>sx_off*2,a0                ; b1=0 // a0 = Scr.offset<<1
      mac   x0,y0,a                Y:(r5)+n5,y1   ; Px = 2*(x'*ZE+Scr.Off) // y
      asr   a        #>sy_off*2,b0                ; Px/=2 // b0 = Scr.off. * 2
      mac   y1,y0,b                a0,X:(r7)      ; Py = 2*(y'*ZE+Scr.Off) // s. Px
      asr   b                                     ; Py/=2
      move                         b0,Y:(r7)+     ; s. Py
   ELSE                                           ; Fluchtpunkt:(Fx/Fy/Fz)
      mpy   x1,y1,b  X:(r5),x1                    ; Px =z'*Fx   // x'
      mac  -x0,x1,b  a0,y0                        ; Px-=x'*Fz   // 1/(z'-Fz)
      move           b0,x0                        ; Integer-Multiplikation
      mpy   x0,y0,b                Y:(r2)+,x1     ; Px/=z'-Fz   // Fy

      mpy   x1,y1,a  X:(r2)-,x0    Y:(r5)+n5,y1   ; Py =Fy*z' // Fz // y'
      mac  -x0,y1,a                               ; Py-=y'*Fz
      asr   b        a0,x1                        ; Px/2,   da Integermul.
      mpy   x1,y0,a                               ; Py/=(z'-Fz)
      asr   a        #>sy_off,x0                  ; Integermul. // Scr.off. y
      add   x0,a     #>sx_off,x0                  ; Py+Scr.Off. // Scr.off. x
      add   x0,b                                  ; Px+Scr.Off.
      move           ba,L:(r7)+                   ; s. x''/y''
   ENDIF
end_trans:
      rts
