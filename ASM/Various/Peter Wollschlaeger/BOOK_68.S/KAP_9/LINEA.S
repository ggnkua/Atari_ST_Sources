* LINE_A  Line-A-Emulator des ST

         move.l   2(sp),a1          ;PC holen
         move     (a1),d2           ;$Axxx -> d2
         and      #$FFF,d2          ;das "A" ausblenden
         addq.l   #2,a1             ;zeigt nun auf Befehl
                                    ;nach $Axxx
         move.l   a1,2(sp)          ;wird Return-Adresse
         cmp      #$F,d2            ; > $A00F?
         bhi      exit              ;nur A-Traps 0-15 erlaubt
         lsl      #2,d2             ;Befehls-Nr * 4
         move.l   table+2(pc,d2),a1 ;Adresse der Routine
         movem.l  d3-d7/a3-a5,-(sp) ;Register retten
         jsr      (a1)              ;Routine aufrufen
         movem.l  (sp)+,d3-d7/a3-a5 ;Register zurueck
exit     rte                        ;das war's

* $A000 folgt direkt
* ------------------
A000     lea      $293A,a0          ;Start Line-A-Variable
         move.l   a0,d0
         lea      $FC9D20,a1        ;Tabelle mit Adressen der
                                    ;System-Font-Header
         lea      $FC0CE0,a2        ;Tabelle der Adressen der
                                    ;der Line-A-Routinen
         rts
         
table    dc.l     A000
;        dc.l     A001
;        u.s.w.

         end

