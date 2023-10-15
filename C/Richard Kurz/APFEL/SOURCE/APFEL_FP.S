; APFEL_FP.S
;
; Schnelle FPU-Assembler-Routine zur Berechnung einer Zeile
; des ApfelmÑnnchens bei 80 Bit Genauigkeit!
;
; (c) April 1993 by Richard Kurz, Vogelherdbogen 62, 7992 Tettnang
; Fido 2:241/7232.5
; Maus UN
; CompuServe 100025,2263
;
; Erstellt mit Pure Assembler
; Vertrieb nur durch das TOS-Magazin!

export mandel_line

mandel_line:
; C-Prototyp:
; int mandel_line(double r_cons,double i_cons,double r_delta, long t, long x, long g, int *erg);
; ACHTUNG! Die Parameter werden nach PURE-C-Art, in den Registern
; Åbergeben!
;
; r_cons    =fp0
; i_cons    =fp1
; r_delta   =fp2 
; t         =d0 (Rechentiefe)
; x         =d1 (Anzahl der Punkte einer Zeile)
; g         =d2 (Grenze fÅr das ApfelmÑnchen) 
; erg       =a0 (Zeilenpuffer) 

    fmovem  fp3-fp7,-(sp)   ; FPU-Register sichern
    
    fmove.x fp2,fp6         ; r_delta nach fp6
    fmove.l d2,fp7          ; g nach fp7
    move.w  d0,d2           ; t nach d2

loopx:  
    fmove.x fp1,fp3         ; i_zahl=i_cons
    fmove.x fp0,fp2         ; r_zahl=r_cons
    move.w  d2,d0           ; SchleifenzÑhler nach  d0

loopz:
    fmove.x fp3,fp4         ; i_quad=i_zahl*i_zahl
    fmul.x  fp3,fp4 
    fmul.x  fp2,fp3         ; i_zahl*=r_zahl
    fmul.x  fp2,fp2         ; r_zahl=r_quad
    fadd.x  fp3,fp3         ; i_zahl*=2

    fmove.x fp2,fp5         ; if((r_quad+i_quad)>g) break
    fadd.x  fp4,fp5 
    fcmp.x  fp7,fp5
    fbgt.w  no_apple

    fadd.x  fp0,fp2         ; r_zahl+=r_cons
    fadd.x  fp1,fp3         ; i_zahl+=i_cons
    fsub.x  fp4,fp2         ; r_zahl-=i_quad

    dbra.w  d0,loopz        ; noch tiefer?

no_apple:
    fadd.x  fp6,fp0         ; r_cons+=r_delta
    move.w  d0,(a0)+        ; das Ergebnis in erg ablegen
    dbra.w  d1,loopx        ; das nÑchste Pixel?
    
    fmovem  (sp)+,fp3-fp7   ; FPU-Register holen
    rts                     ; und TschÅû

