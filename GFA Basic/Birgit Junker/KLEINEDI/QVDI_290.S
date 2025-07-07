
          movea.l   4(sp),a0  ; String-Adr /Parameter vom Stack holen...
          movem.w   8(sp),d1/d2

          subq.w    #1,d2     ; Zeile 1 ist hier 0
          mulu.w    #1280,d2
          movea.l   screen(pc),a2       ; Screen-Adr aus INLINE
          adda.w    d2,a2     ; Zeilen-Offset dazu
          move.l    a2,d6     ; in Zwischenspeicher

          moveq.l   #0,d7
          move.w    #31,d0    ;Clearloopz„hler
clrloop:  move.l    d7,(a2)+  ;Der Bildschirmspeicher wird genullt
          move.l    d7,(a2)+
          move.l    d7,(a2)+
          move.l    d7,(a2)+
          move.l    d7,(a2)+
          move.l    d7,(a2)+
          move.l    d7,(a2)+
          move.l    d7,(a2)+
          move.l    d7,(a2)+
          move.l    d7,(a2)+
          dbra      d0,clrloop

          tst.w     d1        ; ist der String l„nger als 0 ?
          beq       abbruch   ; wenn nicht dann ist hier Schlu
          move.l    linea(pc),d5        ;sonst die Zeichensatz-Adr holen
          movea.l   d6,a2     ; Screen-Adr aus dem Zwischenspeicher
          moveq.l   #1,d2     ; Schrittweite fr Bildschirmadresse
          sub.w     d2,d1     ; Stringl„nge -1
          cmpi.w    #80,d1    ; immer noch >79 ?
          blt.s     ausgabe   ; nein, <= 79
          moveq.l   #78,d1    ; doch, dann genau 79,78+1 fr den Pfeil

          movea.l   d5,a1     ; Line A Adr aus D5

          move.b    3(a1),79(a2)        ; Offset von 3 auf a1 fr ASCII 3
          move.b    259(a1),159(a2)     ; Offset Zeichenspalte 80 auf a2
          move.b    515(a1),239(a2)
          move.b    771(a1),319(a2)
          move.b    1027(a1),399(a2)
          move.b    1283(a1),479(a2)
          move.b    1539(a1),559(a2)
          move.b    1795(a1),639(a2)
          move.b    2051(a1),719(a2)
          move.b    2307(a1),799(a2)
          move.b    2563(a1),879(a2)
          move.b    2819(a1),959(a2)
          move.b    3075(a1),1039(a2)
          move.b    3331(a1),1119(a2)
          move.b    3587(a1),1199(a2)
          move.b    3843(a1),1279(a2)

ausgabe:  movea.l   d5,a1     ; Line A Adr aus D5
          move.b    (a0)+,d7
          adda.w    d7,a1

          move.b    (a1),(a2)
          move.b    256(a1),80(a2)
          move.b    512(a1),160(a2)
          move.b    768(a1),240(a2)
          move.b    1024(a1),320(a2)
          move.b    1280(a1),400(a2)
          move.b    1536(a1),480(a2)
          move.b    1792(a1),560(a2)
          move.b    2048(a1),640(a2)
          move.b    2304(a1),720(a2)
          move.b    2560(a1),800(a2)
          move.b    2816(a1),880(a2)
          move.b    3072(a1),960(a2)
          move.b    3328(a1),1040(a2)
          move.b    3584(a1),1120(a2)
          move.b    3840(a1),1200(a2)

          adda.w    d2,a2
          dbra      d1,ausgabe
abbruch:  rts       

          .EVEN 
          .DATA 
linea:    .DS.l 1
screen:   .DS.l 1
          .END 

