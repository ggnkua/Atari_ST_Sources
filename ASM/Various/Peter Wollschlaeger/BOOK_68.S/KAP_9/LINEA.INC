* LINEA.INC

;Offsets in Tabelle der Line-A-Variablen
;---------------------------------------
v_planes equ        0   ;Anzahl Video-Planes
v_lin_wr equ        2   ;Bytes/Video-Zeile
fgbp1    equ       24   ;Die 4 Bit-Planes
fgbp2    equ       26   ;  fuer
fgbp3    equ       28   ;   die
fgbp4    equ       30   ;     Farbe
lstlin   equ       32   ;sollte -1 sein
ln_mask  equ       34   ;Linienmuster
wrt_mode equ       36   ;Schreibmodus
x1       equ       38   ;Ausgangspunkt
y1       equ       40
x2       equ       42   ;Endpunkt
y2       equ       44
patptr   equ       46   ;Zeiger -> Fuellmuster
patmsk   equ       50   ;Maske Fuellmuster
multifil equ       52   ;0/1: 1/alle Planes fuellen
clip     equ       54   ;0/1: Clipping aus/an


init   macro
       dc.w     $A000          ;Initialisierung
       move.l   a0,a5          ;Zeiger auf Line-A-Variable
       move     #-1,lstlin(a5) ;immer -1
       move     #0,clip(a5)    ;Clipping vorerst aus
       endm

color  macro    
       move     \1,fgbp1(a5)   ;s/w (ist massgebend)
       move     \2,fgbp2(a5) 
       move     \3,fgbp3(a5)
       move     \4,fgbp4(a5)
       endm

line   macro
       move     \1,x1(a5)      ;Zeichen einr Linie
       move     \2,y1(a5)      ;von x1/y1 -> x2/y2
       move     \3,x2(a5)
       move     \4,y2(a5)
       dc.w     $A003
       endm

rectf  macro
       move     \1,x1(a5)      ;Rechteck
       move     \2,y1(a5)      ;von x1/y1 -> x2/y2
       move     \3,x2(a5)      ;"gefuellt" zeichnen
       move     \4,y2(a5)
       dc.w     $A005
       endm

dsprite macro       
        move     \1,d0          ;X-Koordinate setzen
        move     \2,d1          ;und y
        lea      \3,a0          ;zeige auf Sprite
        lea      \4,a2          ;und auf Sicherungsbereich
        dc.w     $a00d          ;zeichne Sprite
        endm

usprite macro
        lea      \1,a2
        dc.w     $a00c          ;Sprite ausschalten
        endm


