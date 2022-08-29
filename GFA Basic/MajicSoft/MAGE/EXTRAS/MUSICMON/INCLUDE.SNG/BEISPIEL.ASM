; *************************************************************
; **** Beispiel fÅr die Einbindung eines mit "SAVE MODUL"  ****
; **** abgespeicherten Songs in Assembler.                 ****
; **** Es besteht die Wahl zwischen 'MUSIC_QU.INC' und     ****
; **** 'MUSICVBL.INC'. Der Unterschied besteht darin, daû  ****
; **** sich die erste Routine in einen freien Slot der     ****
; **** VBL-QUEUE einhÑngt und die zweite Routine direkt    ****
; **** den VBL-Vektor verbiegt ($70) und den alten Vektor  ****
; **** immer anspringt.                                    ****
; *************************************************************

          pea       mes1
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp

          ; *** die Soundroutine einladen:

          clr.w     -(sp)
          pea       routname
          move.w    #$3D,-(sp)
          trap      #1
          addq.l    #8,sp

          tst.l     d0
          bmi       error

          move.l    d0,d7
    
          pea       routine
          move.l    #10000,-(sp)
          move.w    d7,-(sp)
          move.w    #$3F,-(sp)
          trap      #1
          lea       12(sp),sp

          move.w    d7,-(sp)
          move.w    #$3E,-(sp)
          trap      #1
          addq.l    #4,sp

          ; das Songmodul einladen:

          clr.w     -(sp)
          pea       songname
          move.w    #$3D,-(sp)
          trap      #1
          addq.l    #8,sp

          tst.l     d0
          bmi       error

          move.l    d0,d7
    
          pea       modul
          move.l    #10000,-(sp)
          move.w    d7,-(sp)
          move.w    #$3F,-(sp)
          trap      #1
          lea       12(sp),sp

          move.w    d7,-(sp)
          move.w    #$3E,-(sp)
          trap      #1
          addq.l    #4,sp
          
          move.w    #1,-(sp)            ; 1 = Loop-Play Modus
          pea       modul               ; Adresse des Songs Åbergeben

          jsr       routine+6           ; Routine anspringen
                                        ; die Ansprungsadresse liegt
                                        ; 6 Bytes weiter, weil in den
                                        ; ersten 6 Bytes die Kontroll-
                                        ; Bytes liegen. NÑheres darÅber
                                        ; in der Anleitung.

          addq.l    #6,sp               ; Stack zurÅck

          move.w    #7,-(sp)
          trap      #1
          addq.l    #2,sp

          clr.w     -(sp)               ; 0 = Musik aus
          clr.l     -(sp)               ; die Adresse spielt keine Rolle

          jsr       routine+6           ; Routine nochmal anspringen

          addq.l    #6,sp               ; Stack zurÅck
          bra       noerror

error:    pea       mes2
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp

          move.w    #7,-(sp)
          trap      #1
          addq.l    #2,sp

noerror:  clr.w     -(sp)
          trap      #1

          ; ************************

          data

mes1:     dc.b      27,'E'
          dc.b      '*************************************',13,10
          dc.b      '* Beispiel fÅr die Einbindung eines *',13,10
          dc.b      '* Songmoduls in Assembler.          *',13,10
          dc.b      '*                                   *',13,10
          dc.b      '* Zum Abbrechen eine Taste drÅcken. *',13,10
          dc.b      '*************************************',13,10
          dc.b      13,10,0

mes2:     dc.b      'Ich kann die Dateien nicht finden !!!',13,10,0
 
routname: dc.b      '\include.sng\musicvbl.inc',0
songname: dc.b      '\include.sng\demo.mod',0

          bss

          ds.w      0
routine:  ds.b      3000
          ds.w      0
modul:    ds.b      3000

          END
