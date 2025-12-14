;Demo 2 zum Bootsektor-Lader.
;Eine Startmeldung ausgeben und die Steprate von Laufwerk A: einstellen.
;Bei sektoren/track>=15 wird die Steprate auf 6ms gestellt.
;Achtung! Funktioniert nur ab der offiziellen TOS 1.4 Version!
;Dies dient nur als Beispiel, wie man an die Bootsektor-Daten kommt.
;Da HD-FORMAT als Accessory die Steprate mit den eingestellten Default-
;Werten Åberschreibt, sollte man dort die Steprate fÅr A: ausschalten.
;Beim GFA-Assembler muû auch dies erst in Assembler-Source gewandelt werden!

start:          pea       start_text(pc)   ;Startmeldung ausgeben
                move.w    #9,-(sp)      ;Cconws
                trap      #1            ;Gemdos
                addq.w    #6,sp         ;Stack sÑubern
                pea       version(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.w    #6,sp
                pea       mid_text(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.w    #6,sp
                pea       datum(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.w    #6,sp
                pea       end_text(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.w    #6,sp
;start-46 ist der Anfang des Rootsektors und 24/25 die Position von Spt
                lea.l     start-46+24(pc),a0
                move.b    1(a0),d0      ;in 68000er Format wandeln
                lsl.w     #8,d0
                move.b    (a0),d0
                cmpi.w    #15,d0        ;weniger als 15 Sektoren ?
                bcs       ende          ;ja, alles so lassen wie es war
                movea.l   $4f2,a0       ;Zeiger auf Betriebssystem-Header
                movea.l   8(a0),a0      ;Zeiger auf Start
                move.w    $1a(a0),d0    ;Erstellungsjahr
                cmpi.w    #$1989,d0     ;>= TOS 1.4 ?
                bcs       tos10_12      ;nein
                pea       0             ;Drive A: / 6 ms
                move.w    #41,-(sp)     ;Floprate
                trap      #14           ;Xbios
                addq.w    #6,sp
                bra       all_tos

tos10_12:       move.w    2(a0),d0      ;TOS Version holen
                lea.l     $a08,a0       ;Seek fÅr TOS 1.0
                cmpi.w    #$100,d0      ;TOS 1.0 ?
                beq       tos10         ;ja
                lea.l     $a4e,a0       ;Seek fÅr TOS 1.2
tos10:          clr.w     (a0)          ;Seekrate 6 ms setzen
all_tos:        pea       seek_text(pc)
                move.w    #9,-(sp)
                trap      #1
                addq.w    #6,sp
;Return wird schon ausgefÅhrt

                .data 
start_text:     .dc.b 13,10,27,'J',27,'p'
                .dc.b ' Bootsektor-Lader fÅr HD-FORMAT '
                .dc.b 27,'q',13,10,' V',0
mid_text:       .dc.b ' (C) T. Muthmann ',0
end_text:       .dc.b 13,10,10,0
seek_text:      .dc.b ' Seekrate A: auf 6 ms gesetzt',13,10,10,0

