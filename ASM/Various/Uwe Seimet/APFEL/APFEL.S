*****************************************
*                                       *
*               APFEL.TOS               *
*                                       *
* ApfelmÑnnchen mit 68882-UnterstÅtzung *
*                                       *
*  fÅr Atari TT, mittlere TT-Auflîsung  *
*                                       *
*     September 1990 by Uwe Seimet      *
*                                       *
*****************************************


GEMDOS  = 1

LOGBASE = 3
XBIOS   = 14


  text

*Man verzeihe mir die LINEA-Befehle ...

  dc.w $a00a          ;die Maus stîrt

*Ohne Bildschirmadresse
*lÑuft natÅrlich nichts

  move #LOGBASE,-(sp)
  trap #XBIOS
  addq.l #2,sp
  move.l d0,a0

*Koordinaten vorbesetzen

  fmove.x #-1,fp6     ;xmin
  fmove.x #-1,fp7     ;ymin
  fmove.x #1,fp4      ;xmax
  fmove.x #1,fp5      ;ymax
  fsub.x fp6,fp4      ;xmax=xmax-xmin
  fdiv.x #640,fp4     ;ergibt dx
  fsub.x fp7,fp5      ;ymax=ymax-ymin
  fdiv.x #480,fp5     ;ergibt dy

  fsub.x fp5,fp7      ;b=b-dy
  fmove.x fp5,-(sp)
  moveq #4,d2
  clr d7              ;fÅr Schleife 1
loopi:
  fadd.x (sp),fp7     ;b=b+dy
  fmove.x #-1,fp6     ;a=xmin
  fsub.x fp4,fp6      ;a=a-dx
  clr d6              ;fÅr Schleife 2
loopk:
  moveq #0,d0
  moveq #0,d1
  clr d5              ;fÅr Schleife 3
loopj:
  fadd.x fp4,fp6      ;a=a+dx
  fmovecr.x #$0f,fp0  ;x=0
  fmovecr.x #$0f,fp1  ;y=0
  moveq #0,d4         ;Farbcode
  moveq #0,d3         ;Iterationstiefe
looph:
  fmove.x fp0,fp2
  fmul.x fp0,fp2      ;x2=x*x
  fmove.x fp1,fp3
  fmul.x fp1,fp3      ;y2=y*y
  fmove.x fp3,fp5
  fadd.x fp2,fp5      ;y2=y2+x2
  fcmp d2,fp5         ;Divergenz?
  fblt else           ;nein-
  move.l d3,d4
  bra cont
else:
  fmul.x fp0,fp1      ;y=x*y
  fadd.x fp1,fp1      ;y=y+y
  fadd.x fp7,fp1      ;y=y+b
  fmove.x fp2,fp0     ;x=x2
  fsub.x fp3,fp0      ;x=x-y2
  fadd.x fp6,fp0      ;x=x+a
  addq #1,d3          ;Iterationstiefe

*Standard-Iterationstiefe ist 50,
*dieser Wert kann jedoch geÑndert werden

  cmp #50,d3          ;Iterationsende?
  bne looph           ;nein-
cont:
  lsr #1,d4
  roxl #1,d0
  swap d0
  lsr #1,d4
  roxl #1,d0
  swap d0
  lsr #1,d4
  roxl #1,d1
  swap d1
  lsr #1,d4
  roxl #1,d1
  swap d1
  addq #1,d5
  cmp #16,d5          ;16 Pixel berechnet?
  bne loopj           ;noch nicht-
  move.l d0,(a0)+     ;Pixelgruppe
  move.l d1,(a0)+     ;ausgeben
  add #16,d6          ;nÑchstes Wort
  cmp #640,d6         ;neue Rasterzeile?
  bne loopk           ;nein-
  addq #1,d7
  cmp #480,d7         ;Bildschirmende?
  bne loopi           ;nein-
  fmove (sp)+,fp5     ;Stack aufrÑumen
  dc.w $a009          ;Maus anzeigen
  clr -(sp)
  trap #GEMDOS        ;und tschÅû
