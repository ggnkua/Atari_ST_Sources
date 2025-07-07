; Aufruf ~C:mcode(L:screen%,L:V:string,W:LEN(string),W:x%,W:y%)

          .DC.w $a000

          move.l    -$16(a0),d4

          movem.l   4(sp),a0/a2
          movem.w   12(sp),d1-d3


          tst.w     d1        ;ist der String lÑnger als Null?
          beq       abbruch   ;Nein, =0 also aufhîren
          moveq.l   #1,d6     ;eine 1 braucht man immer
          move.w    #81,d5    ;Maximale StringlÑnge
          sub.w     d2,d5     ;davon die X-pos abziehen
          cmp.w     d5,d1     ;immer noch nicht zu lang?
          ble.s     anfang    ;Nein
          move.w    d5,d1     ;Doch, dann genau Anz(d5) Zeichen ausgeben
          moveq.l   #-1,d5    ;d5 auf True

anfang:   sub.w     d6,d1     ;StringlÑnge eins kleiner
          sub.w     d6,d2     ;Spalte 1 ist 0
          sub.w     d6,d3     ;Zeile 1 ist 0
          mulu.w    #1280,d3  ;Umrechnungen von Zeile in Screen-Adr
          adda.w    d3,a0
          move.l    a0,d3     ;Screen-Adr in Zwischenspeicher
          adda.w    d2,a0     ;X-pos in Screen-Adr umrechnen

          sub.l     d0,d0     ;Sauber machen
ausgabe:  movea.l   d4,a1     ;Line-A-Adr holen
          move.b    (a2)+,d0  ;Zeichen holen
          adda.l    d0,a1     ;ASCII-Wert als Offset zu Zeichensatzdaten

          move.b    (a1),(a0) ;16 Zeilen des Zeichens ausgeben
          move.b    256(a1),80(a0)
          move.b    512(a1),160(a0)
          move.b    768(a1),240(a0)
          move.b    1024(a1),320(a0)
          move.b    1280(a1),400(a0)
          move.b    1536(a1),480(a0)
          move.b    1792(a1),560(a0)
          move.b    2048(a1),640(a0)
          move.b    2304(a1),720(a0)
          move.b    2560(a1),800(a0)
          move.b    2816(a1),880(a0)
          move.b    3072(a1),960(a0)
          move.b    3328(a1),1040(a0)
          move.b    3584(a1),1120(a0)
          move.b    3840(a1),1200(a0)

          adda.w    d6,a0     ;Screen-Adr auf nÑchste Spalte
          dbra      d1,ausgabe
          cmp.w     d6,d5
          bmi       arrow
abbruch:  rts       

arrow:    movea.l   d4,a1
          movea.l   d3,a0
          move.b    3(a1),79(a0)        ; Offset von 3 auf a1 fÅr ASCII 3
          move.b    259(a1),159(a0)
          move.b    515(a1),239(a0)
          move.b    771(a1),319(a0)
          move.b    1027(a1),399(a0)
          move.b    1283(a1),479(a0)
          move.b    1539(a1),559(a0)
          move.b    1795(a1),639(a0)
          move.b    2051(a1),719(a0)
          move.b    2307(a1),799(a0)
          move.b    2563(a1),879(a0)
          move.b    2819(a1),959(a0)
          move.b    3075(a1),1039(a0)
          move.b    3331(a1),1119(a0)
          move.b    3587(a1),1199(a0)
          move.b    3843(a1),1279(a0)
          rts       

          .END 

