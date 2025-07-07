; Aufruf: len%=C:code%(L:LEN(string$),L:V:string$)

          movem.l   4(sp),d0/a0

          tst.w     d0        ; Stringl„nge l„nger als Null ?
          beq.s     abbruch   ; Nein, dann Abbruch
          moveq.l   #0,d1     ; eine Null in D1
          moveq.l   #32,d2    ; Space in D2 laden
          adda.w    d0,a0     ; Adr Stringende
          subq.w    #1,d0     ; Z„hler l„uft bis -1
loop:     move.b    -(a0),d1  ; Suchschleife
          cmp.w     d2,d1     ; das Zeichen mit Space vergleichen
          dbne      d0,loop
          addq.w    #1,d0     ; Z„hler korrigieren
abbruch:  rts       

          .END 

