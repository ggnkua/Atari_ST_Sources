******************************
*                            *
*  ROSETTE.TOS               *
*                            *
*  by Jochen Fischer         *
*                            *
*  (c) 1991 MAXON Computer   *
******************************

macro Cconws str
  movem.l   d1-d2/a0-a2,-(sp) ;Ausgabe des 
  pea       str               ;Strings str
  move.w    #9,-(sp)          ;unter Beachtung
  trap      #1                ;der ESC-Sequenzen
  addq.l    #6,sp
  movem.l   (sp)+,d1-d2/a0-a2
endm
macro Cconrs buf
  movem.l   d1-d2/a0-a2,-(sp) ;Lesen des 
  pea       buf               ;Strings str
  move.w    #10,-(sp)         ;unter Beachtung
  trap      #1                ;der ESC-Sequenzen
  addq.l    #6,sp
  movem.l   (sp)+,d1-d2/a0-a2
endm
macro Cconin
  movem.l   d1-d2/a0-a2,-(sp) ;Warten auf
  move.w    #1,-(sp)          ;einen
  trap      #1                ;Tastendruck
  addq.l    #2,sp             ;d0=Zeichen
  movem.l   (sp)+,d1-d2/a0-a2
endm
macro rd_int buf,frage,len,pos ;Read Integer
  pea       buf(pc)           ;Puffer fÅr Eingabe
  pea       frage(pc)         ;Zeiger auf Frage
  move.w    len,-(sp)         ;Max. EingabelÑnge
  move.w    pos,-(sp)         ;(X,Y)-Position
  bsr       lies_int
  adda.l    #12,sp
endm      
macro rd_card buf,frage,len,pos ;Read Cardinal
  pea       buf(pc)           ;s.o.
  pea       frage(pc)
  move.w    len,-(sp)
  move.w    pos,-(sp)
  bsr       lies_card
  adda.l    #12,sp
endm
* -----------------------------------------------
init        equ $0
maus_off    equ $a
maus_on     equ $9
a_line      equ $3
* -----------------------------------------------
*               Initialisierung
* -----------------------------------------------
  text
  movem.l   d0-d7/a0-a6,-(sp)     ;CPU Reg. und
  fmovem.l  fpcr/fpsr/fpiar,-(sp) ;alle FPU Reg.
  fmovem.x  fp0-fp7,-(sp)         ;sichern
  aline     init                  ;line_a init
  lea       a_zeiger,a1           ;Line_a Zeiger 
  move.l    a0,(a1)               ;sichern
  move.w    -$c(a0),d0            ;x_max
  lsr.w     #1,d0                 ;d0=x_halbe 
  move.w    -$4(a0),d1            ;y_max
  lsr.w     #1,d1                 ;d1=y_halbe
  lea       x_hlb(pc),a0          ;x und y_halbe
  move.w    d0,(a0)               ;sichern
  move.w    d1,2(a0)
  Cconws    clr_scr(pc)
* -----------------------------------------------
*           Eingabeteil
* -----------------------------------------------
  rd_card   Antwort,Frage1,#4,#$0202 ;Rad.1 lesen
  cmp.w     d1,d0         ;Radius 1<=y_halbe ?
  bge       e1
  move.w    d0,4(a0)      ;ja -> nehme Eingabe
  bra       w1
e1:
  move.w    2(a0),4(a0)   ;nein->nehme y_halbe/2
  lsr.w     4(a0)
w1:
  move.w    2(a0),d2      ;y_halbe
  sub.w     4(a0),d2      ;y_halbe-Radius 1
  rd_card   Antwort,Frage2,#4,#$0402 ;Rad.2 lesen
  cmp.w     d2,d0         ;Rad.2<=y_halbe-Rad.1 ?
  bge       e2
  move.w    d0,6(a0)      ;ja -> nehme Eingabe
  bra       w2
e2:
  move.w    d2,6(a0)  ;nein->nehme y_halbe-Rad.1
w2:
  rd_int    Antwort,Frage3,#5,#$0602 ;lese Freq.1
  move.w    d0,8(a0)
  rd_int    Antwort,Frage4,#5,#$0802 ;lese Freq.2
  move.w    d0,10(a0)
  rd_card   Antwort,Frage5,#3,#$0a02 ;lese Konst1
  move.w    d0,12(a0)
  rd_card   Antwort,Frage6,#3,#$0c02 ;lese Konst2
  move.w    d0,14(a0)          
  rd_card   Antwort,Frage7,#5,#$0e02 ;Genauigkeit
  move.w    d0,16(a0)
  Cconws    cur_off(pc)              ;Cursor aus
  Cconws    clr_scr(pc)
* -----------------------------------------------
*      Hauptprogramm (hier wird gerechnet)
* -----------------------------------------------
  lea       x_pos(pc),a1    ;1.Position berechnen
  move.w    (x_hlb,pc),d0   ;x  Position
  add.w     (rad1,pc),d0    ;rad.1 addieren
  add.w     (rad2,pc),d0    ;rad.2 addieren
  move.w    d0,(a1)         ;sichern
  move.w    y_hlb(pc),4(a1) ;y position
  fmove.x   #0,fp0          ;Bei 0 anfangen
  fmove.x   #1,fp1
  fdiv.w    step(pc),fp1    ;fp1=1/step
  move.w    x_hlb(pc),d0    ;d0=x_hlb
  move.w    y_hlb(pc),d1    ;d1=y_hlb
  move.w    rad1(pc),d2     ;d2=rad1
  move.w    rad2(pc),d3     ;d3=rad2
  fmove.w   freq1(pc),fp6   ;fp6=freq1
  fmove.w   freq2(pc),fp7   ;fp7=freq2
rloop:
  fmove.x   fp0,fp2         ;x=w
  fmul.x    fp6,fp2         ;x=x*f1
  fcos.x    fp2             ;x=cos(x)
  fmul.w    d2,fp2          ;x=x*rad1
  fadd.w    d0,fp2          ;x=x+x_hlb
  fmove.x   fp0,fp3         ;y=w
  fmul.x    fp6,fp3         ;y=y*freq1
  fmul.w    ry1(pc),fp3     ;y=y*ry1
  fsin.x    fp3             ;y=sin(y)
  fmul.w    d2,fp3          ;y=y*rad1
  fadd.w    d1,fp3          ;y=y+y_hlb
  fmove.x   fp0,fp4         ;x1=w
  fmul.x    fp7,fp4         ;x1=x1*freq2
  fcos.x    fp4             ;x1=cos(x1)
  fmul.w    d3,fp4          ;x1=x1*rad2
  fmove.x   fp0,fp5         ;y1=w
  fmul.x    fp7,fp5         ;y1=y1*freq2
  fmul.w    ry2(pc),fp5     ;y1=y1*ry2
  fsin.x    fp5             ;y1=sin(y1)
  fmul.w    d3,fp5          ;y1=y1*rad2
  fadd.x    fp4,fp2         ;x=x+x1
  fadd.x    fp5,fp3         ;y=y+y1
  bsr       line            ;linie zeichnen
  fadd.x    fp1,fp0         ;w=w+step
  fcmp.p    max(pc),fp0     ;schluû ?
  fble      rloop
  Cconin                    ;auf Taste warten
  fmovem.x  (sp)+,fp0-fp7   ;alle Register zurÅck
  fmovem.l  (sp)+,fpcr/fpsr/fpiar
  movem.l   (sp)+,d0-d7/a0-a6
  clr.w     -(sp)
  trap      #1              ;zurÅck zu GEM
* -----------------------------------------------
*           Unterprogramme
* -----------------------------------------------
* Unterprogramm fÅr Linien
line: 
  movem.l   d0-d2/a2-a3,-(sp)
  lea       a_zeiger,a3
  movea.l   (a3),a3
  lea       x_pos,a2
  move.w    #1,$18(a3)      ;farbe =1
  move.w    #-1,$20(a3)
  move.w    #$ffff,$22(a3)  ;linienstil
  clr.w     $1a(a3)         ;die restlichen
  clr.w     $1c(a3)         ;Bitplanes sind
  clr.w     $1e(a3)         ;gleich null
  fmove.w   fp2,$26(a3)     ;x neu
  fmove.w   fp3,$28(a3)     ;y neu
  move.w    (a2),$2a(a3)    ;x alt
  move.w    4(a2),$2c(a3)   ;y alt
  move.w    #0,$24(a3)      ;replace
  fmove.w   fp2,(a2)        ;neue x_pos sichern
  fmove.w   fp3,4(a2)       ;neue y_pos sichern
  aline     a_line          ;linie zeichnen
  movem.l   (sp)+,d0-d2/a2-a3
  rts
* ----------------------------------
* Unterprogramm fÅr cardinal Eingabe
lies_card:
  movem.l   d1-d3/a0-a2,-(sp)
  movea.l   36(sp),a0       ;Bufferadr in A0
  move.w    #$1b59,(a0)     ;ESC Y in Buffer
  move.w    28(sp),2(a0)    ;Koord. in Buffer
  addi.w    #$2020,2(a0)    ;jeweils 32 addieren
  move.b    #0,4(a0)        ;Stringende
  Cconws    (a0)            ;String ausgeben  
  Cconws    clr_line(pc)    ;Zeile lîschen
  movea.l   32(sp),a1       ;Textadr in A1
  Cconws    (a1)            ;Text ausgeben
  move.b    31(sp),(a0)     ;LÑnge in Buffer
  Cconrs    (a0)            ;String einlesen
  move.b    1(a0),d1        ;Anzahl Zeichen in D1
  beq       lcl_exit        ;Anzahl=0 -> exit
  ext.w     d1
  subq.w    #1,d1
  clr.w     d2
  clr.w     d0
lc_loop:
  mulu      #10,d0          ;Zahl mal 10
  move.b    2(a0,d2.w),d3   ;Zeichen in D3
  subi.b    #$30,d3         ;ASCII - 48
  bmi       lcl_exit        ;keine Ziffer -> exit
  cmpi.b    #9,d3           ;Wert>9 ?
  bgt       lcl_exit        ;keine Ziffer -> exit
  ext.w     d3
  add.w     d3,d0           ;d0=d0+Ziffer
  addq.b    #1,d2           ;nÑchste Ziffer
  dbf       d1,lc_loop      ;bis zur letzten Z.
  bra       lc_ende
lcl_exit:
  moveq.l   #0,d0           ;Fehler aufgetreten
lc_ende:
  movem.l   (sp)+,d1-d3/a0-a2
  rts     
* Unterprogramm fÅr integer Eingabe
lies_int: 
  movem.l   d1-d3/a0-a2,-(sp)
  movea.l   36(sp),a0       ;Bufferadr in A0
  move.w    #$1b59,(a0)     ;ESC Y in Buffer
  move.w    28(sp),2(a0)    ;Koord. in Buffer
  addi.w    #$2020,2(a0)    ;jeweils 32 addieren
  move.b    #0,4(a0)        ;Stringende
  Cconws    (a0)            ;String ausgeben  
  Cconws    clr_line(pc)    ;Zeile lîschen
  movea.l   32(sp),a1       ;Textadr in A1
  Cconws    (a1)            ;Text ausgeben
  move.b    31(sp),(a0)     ;LÑnge in Buffer
  Cconrs    (a0)            ;String eingeben
  move.b    1(a0),d1        ;Zeichen gelesen ?
  beq       lil_exit        ;nein -> exit
  ext.w     d1
  move.b    2(a0),d0        ;erstes Zeichen in D0
  clr.l     d3              ;Zahl positiv
  cmp.b     #'+',d0         ;'+' erstes Zeichen ?
  beq       li_plus
  cmp.b     #'-',d0         ;'-' erstes Zeichen ?
  beq       li_minus
  bra       li_ziffer       ;1.Zeichen ist Ziffer
li_minus:
  or.l      #$10000,d3      ;Zahl negativ
li_plus:
  moveq     #1,d2           ;1.Zeichen fÑllt weg
  subq.b    #2,d1           ;ein Zeichen weniger
  bra       li_pl_mi
li_ziffer:
  subq.w    #1,d1
  clr.w     d2
li_pl_mi:
  clr.w     d0
li_loop:
  mulu      #10,d0          ;Zahl mal 10
  move.b    2(a0,d2.w),d3   ;Zeichen in D3
  subi.b    #$30,d3         ;ASCII - 48
  bmi       lil_exit        ;keine Ziffer -> exit
  cmpi.b    #9,d3           ;Wert>9 ?
  bgt       lil_exit        ;keine Ziffer -> exit
  ext.w     d3
  add.w     d3,d0           ;d0=d0+Ziffer
  addq.b    #1,d2           ;nÑchste Ziffer
  dbf       d1,li_loop      ;bis zur letzten Z.
  swap      d3
  btst      #0,d3           ;Zahl negativ ?
  beq       li_ende         ;nein -> ende
  neg.w     d0              ;sonst negieren
  bra       li_ende         ;-> ende
lil_exit:
  moveq.l   #0,d0           ;Fehler aufgetreten
li_ende:
  movem.l   (sp)+,d1-d3/a0-a2
  rts
* -----------------------------------------------
*           Daten
* -----------------------------------------------
x_hlb:      dc.w  0
y_hlb:      dc.w  0
* Hier werden die Eingaben eingetragen
rad1:       dc.w  0         ;Radius 1
rad2:       dc.w  0         ;Radius 2
freq1:      dc.w  0         ;Frequenz 1
freq2:      dc.w  0         ;Frequenz 2
ry1:        dc.w  0         ;Konstante 1
ry2:        dc.w  0         ;Konstante 2
step:       dc.w  0         ;Genauigkeit
*
max:        dc.p  6.283185
a_zeiger:   dc.l  0
x_pos:      dc.w  0
y_pos:      dc.w  0
*
Frage1: asciiz  'Radius  1 :'
Frage2: asciiz  'Radius  2 :'
Frage3: asciiz  'Frequenz  1 :'
Frage4: asciiz  'Frequenz  2 :'
Frage5: asciiz  'Konstante 1 (1-3) :'
Frage6: asciiz  'Konstante 2 (1-3) :'
Frage7: asciiz  'Genauigkeit (>200):'
Antwort:  dc.b  0,0,0,0,0,0,0,0,0,0
clr_scr:  dc.b  27,'E',0
cur_off:  dc.b  27,'f',0
cur_on:   dc.b  27,'e',0
clr_line: dc.b  27,'K',0
