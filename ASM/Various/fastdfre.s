; ***********************************************************
; * Fast-Dfree() - beschleunigt die Dfree-Funktion des      *
; * GEMDOS bei 16-Bit-FATS. Bei einer SH205 um Faktor 14 !!!*
; * die neue Dfree-Funktion wird ins GEMDOS eingesetzt und  *
; * ersetzt bei 16-Bit-FATS(Harddisk, Ramdisk) die original *
; * Dfree-Routine vollst„ndig !                             *
; ***********************************************************
anfang:      bra       init
; ===========================================================
; = Der neue Gemdos-Vektor                                  =
; ===========================================================
             .DC.b "XBRA"
             .DC.b "äDFR"
old_vektor:  .DS.l 1
new_gemdos:  move.l    usp,a0
             btst      #5,(sp)          ; Aufruf aus dem USER-Mode ?
             beq.s     new_gemdos1      ; Ja!
             movea.l   sp,a0
             addq.w    #6,a0
new_gemdos1: cmpi.w    #$36,(a0)        ; Dfree()
             beq.s     dfree            ; eigene Routine testen
new_gemdos_exit:       
             movea.l   old_vektor(pc),a0
             jmp       (a0)             ; Originale GEMDOS-Routine

; ===========================================================
; = Bei einer 12-Bit-FAT ( Diskette ) ist die interne       =
; = Routine schnell genug.                                  =
; ===========================================================
dfree_12bit_fat:       movem.l          (sp)+,d1-d7/a0-a6
             bra.s     new_gemdos_exit  ; Originalroutine aufrufen

; ===========================================================
; = Die neue Dfree()-Funktion fr 16-Bit-FATs               =
; = Es werden einfach alle Null-Words in der 2.FAT gez„hlt, =
; = das ist alles. Zu beachten ist nur, daž die ersten 3    =
; = Words nicht mitgez„hlt werden !                         =
; ===========================================================
dfree:       movem.l   d1-d7/a0-a6,-(sp)
             movea.l   2(a0),a4         ; Bufferadr
             lea       12(a4),a4        ; fr Predecrement (s.u.)
             move.w    6(a0),d7         ; Drive
             subq.w    #1,d7
             bpl.s     dfree3           ; aktuelles LW ?

             move.w    #$19,-(sp)
             trap      #1               ; Dgetdrv()
             addq.w    #2,sp
             move.w    d0,d7            ; aktuelles LW
dfree3:      cmpi.w    #1,d7            ; Disk ?
             ble.s     dfree_12bit_fat  ; dann GEMDOS-Dfree()
; Wenn obige Abfrage fehlt, wird nach dem Formatieren einer einseitigen
; Disk von einer 16-Bit-FAT ausgegangen (fehlendes Media-Change)
             move.w    d7,-(sp)         ; drive
             move.w    #7,-(sp)
             trap      #13              ; Getbpb( drive )
             addq.w    #4,sp
             tst.l     d0
             bmi.s     dfree_error      ; Ger„t nicht da, Fehler
             movea.l   d0,a6            ; Adresse merken
             btst      #0,17(a6)        ; Flagsb testen nach 16 oder 12-Bit-FAT
             beq.s     dfree_12bit_fat  ; 12-Bit-FAT => Original anspringen
             move.w    10(a6),d6        ; fatrec - Startsektor der 2.FAT
             moveq     #0,d5
             move.w    2(a6),d5
             move.l    d5,(a4)          ; Sektoren pro Cluster einsetzen
             move.w    (a6),d5
             move.l    d5,-(a4)         ; Bytes pro Sektor einsetzen
             move.w    14(a6),d5        ; numcl-Gesamtanzahl der Cluster merken
             move.l    d5,-(a4)         ; und einsetzen
             moveq     #0,d4            ; Anzahl der freien Cluster=0
             moveq     #0,d3            ; Flag f. den Startsektor d. FAT l”schen
dfree0:      movea.l   $4c6,a5          ; Bufferadresse holen (_dskbuf)
             move.w    d7,-(sp)         ; Drive
             move.w    d6,-(sp)         ; fatrec
             move.w    #2,-(sp)         ; 2 Sektoren einlesen
             move.l    a5,-(sp)         ; Buffer fr die Sektoren
             clr.w     -(sp)            ; normales Lesen
             move.w    #4,-(sp)
             trap      #13              ; Rwabs()
             lea       14(sp),sp
             tst.l     d0
             bmi.s     dfree_error      ; Lesefehler, Fehlermeldung zurckgeben
             addq.w    #2,d6            ; fatrec+2
             move.w    #$1ff,d0         ; 512 Cluster pro 2 Sektoren der FAT
             tas.b     d3               ; 1.Sektor mit den ersten drei Clustern?
             bne.s     dfree1           ; Nein! =>
             addq.w    #6,a5            ; die ersten der Cluster werden
             subq.w    #3,d0            ; nicht mitgez„hlt
             subq.w    #3,d5            ; 3 Cluster bereits abziehen
dfree1:      tst.w     (a5)+            ; freien Cluster gefunden ?
             bne.s     dfree2           ; Nein =>
             addq.w    #1,d4            ; einen freien Cluster gefunden
dfree2:      subq.w    #1,d5            ; numcl-1
             dbeq      d0,dfree1
             bne.s     dfree0           ; Ende noch nicht erreicht, weiter gehts
             move.l    d4,-(a4)         ; Anzahl der freien Cluster einsetzen
             moveq     #0,d0            ; alles ok, kein Fehler
dfree_error: movem.l   (sp)+,d1-d7/a0-a6
             rte                        ; Das war's schon

init:        pea       new_gemdos(pc)
             move.l    #$00050021,-(sp)
             trap      #13              ; Setexc(33,new_gemdos)
             addq.w    #8,sp
             move.l    d0,old_vektor    ; Original-Vektor merken
             pea       init_text(pc)
             move.w    #9,-(sp)
             trap      #1               ; eine Meldung am Anfang
             addq.w    #6,sp
             clr.w     -(sp)            ; Kein Fehler aufgetreten
             pea       init-anfang+$100 ; residentes Programm < 500 Bytes
             move.w    #$31,-(sp)
             trap      #1               ; Ptermres()
init_text:   .DC.b "Fast-Dfree",13,10
             .DC.b " ",13,10,0

