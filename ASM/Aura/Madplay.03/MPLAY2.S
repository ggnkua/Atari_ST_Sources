; Player for Syntheticsounds in MadMax Format.
; Runs on any monitor, any machine (STE/E/TT/F030), uses Timer-A for proper
; 50Hz VBL-emulation (even can handle some SID voice tunes (e.g.
; BigAlecs ones).
; Can handle informations from an SNDH Header (name of composer, number of
; tunes).

; Doesnt use anything like XBRA, so your memory keeps shrinking if you run
; several tunes resident (normal play: no probs!).

; Coded at one afternoon (the code looks like that!): 15.2.1992
; Updates:    End of 92.
; F030-patch: 3.3.97

; By the way: Done by BDCannibal (knaus@ruf.uni-freiburg.de)

speed           EQU 246         ; 245.76 (Timer-Wert fuer 50Hz IRQ)
MAX_HEADER      EQU 200

                OPT D+,O+
                OUTPUT 'E:\MAD_PLAY.TTP','c:\swap\newtunes\sowatt5.snd'

; Commandozeile auslesen, restlichen Speicher freigeben und Tune laden.

                movea.l 4(SP),A0
                lea     $80(A0),A0      ; Commandline
                move.b  (A0)+,D7        ; leer ?
                beq     endend

                ext.w   D7              ; Anzahl Buchstaben
                subq.w  #1,D7
                lea     filename(PC),A1
loop:           move.b  (A0)+,(A1)+
                dbra    D7,loop

                clr.b   (A1)            ; Schlužbyte

                movea.l 4(SP),A6        ; Erst n”tig, nachdem man Filegr. kennt

                pea     dta(PC)         ; DTA-Buffer einrichten
                move.w  #$1A,-(SP)      ; Datei einlesen
                trap    #1
                addq.w  #6,SP

                clr.w   -(SP)           ; Nur normale Dateien
                pea     filename(PC)
                move.w  #$4E,-(SP)
                trap    #1
                addq.w  #8,SP

                tst.w   D0
                beq.s   found

                pea     fault1(PC)
fault_out:      move.w  #9,-(SP)
                trap    #1
                addq.w  #6,SP
                bra     ende

found:          move.l  $0C(A6),D0
                add.l   $14(A6),D0
                add.l   $1C(A6),D0
                add.l   #$0400,D0
                lea     dta(PC),A0
;                add.l   26(A0),D0       ; Gr”že des Files dazuaddieren
                move.l  D0,resident     ; wird gebraucht, wenn das Teil resident
; gemacht werden soll !
                move.l  D0,-(SP)
                move.l  A6,-(SP)
                clr.w   -(SP)
                move.w  #$4A,-(SP)
                trap    #1
                lea     12(SP),SP

                tst.w   D0
                beq.s   no_mem_f

suck_it:        pea     fault5(PC)
                bra     fault_out

no_mem_f:       move.l  dta+26(PC),-(SP) ; Speicher fr Sound allocieren.
                move.w  #$48,-(SP)
                trap    #1
                addq.l  #4,SP

                tst.l   D0
                ble.s   suck_it

                move.l  D0,sound

                clr.w   -(SP)           ; nur lesen
                pea     filename(PC)
                move.w  #$3D,-(SP)
                trap    #1
                addq.w  #6,SP

                tst.l   D0
                bpl.s   ok1

                pea     fault2(PC)
                bra.s   fault_out

ok1:            move.l  sound(PC),-(SP)
                move.l  dta+26(PC),-(SP) ; Dateigr”že
                move.w  D0,D7
                move.w  D7,-(SP)
                move.w  #$3F,-(SP)
                trap    #1
                lea     12(SP),SP

                tst.l   D0
                bpl.s   ok2

                pea     fault3(PC)
                bra     fault_out

ok2:            move.w  D7,-(SP)
                move.w  #$3E,-(SP)
                trap    #1
                addq.w  #4,SP

                lea     txt1(PC),A0     ; Text modifizieren
                lea     dta+30(PC),A1   ; Filenamen.
                moveq   #11,D0          ; max. 12 Buchstaben
loop2:          move.b  (A1)+,D1
                beq.s   clr_rest
                move.b  D1,(A0)+
                dbra    D0,loop2

clr_rest:       tst.w   D0
                bmi.s   noclrrest

clr_rest_lp:    move.b  #' ',(A0)+
                dbra    D0,clr_rest_lp

noclrrest:      lea     txt2(PC),A0
                move.l  dta+26(PC),D0   ; Dateil„nge
                move.w  #10000,D2
                REPT 4
                divu    D2,D0
                add.b   #'0',D0
                move.b  D0,(A0)+
                clr.w   D0
                swap    D0
                divu    #10,D2
                ENDR
                add.b   #'0',D0
                move.b  D0,(A0)

                pea     starttxt(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.w  #6,SP

                bsr     test_sndh       ; Testen, ob SNDH Header vorhanden.

; ****************************************************************************

                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.w  #6,SP

                move.l  D0,saver

                lea     saver+4(PC),A0  ; alle ben”tigten Vektoren retten
                move.w  $FFFF8242.w,(A0)+
                move    SR,(A0)+
                move.w  $0484.w,(A0)+
                move.b  $FFFFFA19.w,(A0)+
                move.b  $FFFFFA17.w,(A0)+
                move.b  $FFFFFA13.w,(A0)+
                move.b  $FFFFFA07.w,(A0)+
                move.b  $FFFFFA1F.w,(A0)+
                move.b  $FFFFFA19.w,(A0)+
                move.l  $0134.w,(A0)+

                clr.b   backgrd

                moveq   #1,D0
                movea.l sound(PC),A0
                jsr     (A0)            ; Soundinit

                move    #$2700,SR       ; Interrupts sperren und Timer A init.
                bclr    #0,$0484.w      ; Tastaturklick aus (nur bei Backgrd.)
                move.w  #$00,$FFFF8242.w ; fr alle Farbmonis !
                clr.b   $FFFFFA19.w     ; Timer A stoppen
                move.l  #timer_a,$0134.w
                bclr    #3,$FFFFFA17.w
                bset    #5,$FFFFFA13.w
                bset    #5,$FFFFFA07.w
                move.b  #speed,$FFFFFA1F.w
                move.b  #7,$FFFFFA19.w  ; Timer mit Vorteiler 1:200 starten
                stop    #$2300          ; ab geht's...

loopy:          move.w  #$0B,-(SP)      ; Tastaturbuffer leeren.
                trap    #1
                addq.l  #2,SP
                tst.w   D0
                beq.s   mainloop
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                bra.s   loopy

mainloop:       move.w  counter(PC),D0  ; Nur alle 50 Hz.
wait_timer_a:   cmp.w   counter(PC),D0
                beq.s   wait_timer_a

                bsr     volumeter       ; Frs Auge.

                move.w  #$0B,-(SP)      ; Tasten ???
                trap    #1
                addq.l  #2,SP

                tst.w   D0
                beq.s   mainloop

                move.w  #7,-(SP)
                trap    #1
                addq.w  #2,SP

                swap    D0              ; Scancode

                cmp.b   #$39,D0         ; Ende ? (Space)
                beq     end
                cmp.b   #$13,D0         ; Resident halrten ? (R)
                beq     resi
                cmp.b   #$0B,D0         ; 1-0 ?
                bgt.s   mainloop
                sub.b   #$02,D0
                bmi.s   mainloop

                ext.w   D0
                addq.w  #1,D0

                tst.w   anz_songs       ; Wenn kein SNDH Header vorh.: alles
                beq.s   all_keys        ; moeglich.

                cmp.w   anz_songs(PC),D0 ; Zu weit ?
                bgt.s   mainloop

all_keys:       movea.l sound(PC),A0
                jsr     (A0)            ; neuer Sound installieren
                bra.s   mainloop

; Volumeter: Code genauso l„cherlich wie das Ding aussieht...
volumeter:      movem.l D0-A6,-(SP)

                moveq   #2,D7
                moveq   #8,D6
out_loop:       moveq   #$0F,D0
                move.b  D6,$FFFF8800.w
                and.b   $FFFF8800.w,D0
                add.w   D0,D0
                add.w   D0,D0
                move.l  volm(PC,D0.w),D0
                move.l  D0,-(SP)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                addq.b  #1,D6
                dbra    D7,out_loop

                pea     curs_up(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                movem.l (SP)+,D0-A6
                rts

; Volumeterstrings (kein Stress bei Umwandlung...)
volm:           DC.L vol0,vol1,vol2,vol3
                DC.L vol4,vol5,vol6,vol7
                DC.L vol8,vol9,vola,volb
                DC.L volc,vold,vole,volf

resi:           st      backgrd

                clr.w   -(SP)           ; Programm beenden und resident halten
                move.l  resident(PC),-(SP)
                move.w  #$31,-(SP)
                trap    #1

vorspul:        move.w  #$0700,$FFFF8240.w
                movem.l D0-A6,-(SP)
spieler:        movea.l sound(PC),A0
                jsr     8(A0)           ; Sound playen

                move.w  #50,D0
lp1:            move.w  #5,D1
lp2:            dbra    D1,lp2
                dbra    D0,lp1

                move.w  #-1,-(SP)
                move.w  #11,-(SP)
                trap    #13
                addq.w  #4,SP

                btst    #0,D0
                bne.s   spieler

                movem.l (SP)+,D0-A6
                bra     mainloop

end:
;                moveq   #0,D0
;                movea.l sound(PC),A0
;                jsr     (A0)

                move.l  sound(PC),-(SP) ; Soundspeicher freigeben.
                move.w  #$49,-(SP)
                trap    #1
                addq.l  #6,SP

                pea     ping(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                move    #$2700,SR
                lea     saver(PC),A0
                move.l  (A0)+,-(SP)     ; alter Stack
                move.w  (A0)+,$FFFF8242.w
                move    (A0)+,SR
                move.w  (A0)+,$0484.w
                move.b  (A0)+,$FFFFFA19.w
                move.b  (A0)+,$FFFFFA17.w
                move.b  (A0)+,$FFFFFA13.w
                move.b  (A0)+,$FFFFFA07.w
                move.b  (A0)+,$FFFFFA1F.w
                move.b  (A0)+,$FFFFFA19.w
                move.l  (A0)+,$0134.w
                move.l  #$080000,$FFFF8800.w ; Ton aus Geppard !
                move.l  #$090000,$FFFF8800.w
                move.l  #$0A0000,$FFFF8800.w
                move    #$2300,SR

                move.w  #$20,-(SP)      ; zurck in den User-Mode
                trap    #1
                addq.w  #6,SP

endend:         clr.w   -(SP)
                trap    #1

ende:           move.w  #7,-(SP)        ; wird nach den Fehlermeldungen ange-
                trap    #1              ; sprungen
                addq.w  #2,SP
                clr.w   -(SP)
                trap    #1

timer_a:        movem.l D0-A6,-(SP)
                movea.l sound(PC),A0
                jsr     8(A0)           ; Sound spielen

;                tst.b   backgrd         ; L„uft Musik im Hauptprogramm ???
;                bne.s   end_tima

end_tima:       movem.l (SP)+,D0-A6
                move.b  #%11011111,$FFFFFA0F.w ; da SEI
                move.b  #speed,$FFFFFA1F.w

                addq.w  #1,counter
                rte

                >PART 'SNDH test und Infos ausgeben'
test_sndh:      move.l  #'COMM',D0
                bsr     search_sndh
                beq     no_sndh

                lea     composer(PC),A6
                bsr     print
                movea.l D0,A6
                bsr     print

                move.l  #'TITL',D0
                bsr     search_sndh
                beq     no_sndh

                lea     title(PC),A6
                bsr     print
                movea.l D0,A6
                bsr     print

                move.l  #'RIPP',D0
                bsr     search_sndh
                beq     no_sndh

                lea     ripp(PC),A6
                bsr     print
                movea.l D0,A6
                bsr     print

                move.l  #'CONV',D0
                bsr     search_sndh
                beq     no_sndh

                lea     conversion(PC),A6
                bsr     print
                movea.l D0,A6
                bsr     print

                move.w  #'##',D0
                bsr     search_sndh_w
                beq     no_sndh

                move.w  D0,anz

                move.w  #$FF,D1
                and.w   D0,D1           ; 10^0
                lsr.w   #8,D0           ; 10^1

                subi.b  #'0',D0
                subi.b  #'0',D1
                mulu    #10,D0
                add.w   D1,D0
                move.w  D0,anz_songs

                lea     songs(PC),A6
                bsr     print

                bra     no_sndh

search_sndh:    movea.l sound(PC),A5
                move.w  #MAX_HEADER-1,D7
                move.l  (A5)+,D1
_search_sndh:   cmp.l   D0,D1
                beq.s   wow2
                lsl.l   #8,D1
                move.b  (A5)+,D1
                dbra    D7,_search_sndh
                moveq   #0,D0
                rts
wow2:           move.l  A5,D0
                rts

search_sndh_w:  movea.l sound(PC),A5
                move.w  #MAX_HEADER-1,D7
                move.w  (A5)+,D1
_search_sndh_w: cmp.w   D0,D1
                beq.s   wow_w
                lsl.w   #8,D1
                move.b  (A5)+,D1
                dbra    D7,_search_sndh_w
                moveq   #0,D0
                rts
wow_w:          move.b  (A5)+,D0
                lsl.w   #8,D0
                move.b  (A5)+,D0
                rts


composer:       DC.B 'Composer:   ',0
title:          DC.B 13,10,'Title:      ',0
ripp:           DC.B 13,10,'Ripped:     ',0
conversion:     DC.B 13,10,'Conversion: ',0
songs:          DC.B 13,10,'Songs:      '
anz:            DC.B 'xx',13,10,13,10,0
                EVEN

print:          movem.l D0-D2/A0-A2,-(SP)
                pea     (A6)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                movem.l (SP)+,D0-D2/A0-A2
no_sndh:        rts
                ENDPART

starttxt:                               ;DC.B 27,'f',27,'E'
                DC.B 13,10
                DC.B 'Soundchipplayer v. 0.2 by BDCannibal/AURA (4.3.97).'
                DC.B 13,10,13,10
txt:            DC.B 'Playing File:   '
txt1:           DC.B 'XXXXXXXX.XXX',13,10
                DC.B 'Length:         '
txt2:           DC.B 'XXXXX',' Bytes',13,10,13,10,27,'f',27,'b9',0
                EVEN

vol0:           DC.B '[               ]',13,10,0
vol1:           DC.B '[*              ]',13,10,0
vol2:           DC.B '[**             ]',13,10,0
vol3:           DC.B '[***            ]',13,10,0
vol4:           DC.B '[****           ]',13,10,0
vol5:           DC.B '[*****          ]',13,10,0
vol6:           DC.B '[******         ]',13,10,0
vol7:           DC.B '[*******        ]',13,10,0
vol8:           DC.B '[********       ]',13,10,0
vol9:           DC.B '[*********      ]',13,10,0
vola:           DC.B '[**********     ]',13,10,0
volb:           DC.B '[***********    ]',13,10,0
volc:           DC.B '[************   ]',13,10,0
vold:           DC.B '[************',27,'b1','*  ',27,'b9',']',13,10,0
vole:           DC.B '[************',27,'b1','** ',27,'b9',']',13,10,0
volf:           DC.B '[************',27,'b1','***',27,'b9',']',13,10,0
curs_up:        DC.B 27,'A',27,'A',27,'A',0

fault1:         DC.B 27,'E','Datei nicht gefunden...',0
fault2:         DC.B 27,'E','Datei konnte nicht ge”ffnet werden...',0
fault3:         DC.B 27,'E','Datei konnte nicht korrekt gelesen werden...',0
fault5:         DC.B 27,'E','Fehler bei der Speicherreservierung...',0
ping:           DC.B 7,0
                EVEN
anz_songs:      DC.W 0

                BSS
                EVEN
counter:        DS.W 1
resident:       DS.L 1
backgrd:        DS.B 2
saver:          DS.B 40
filename:       DS.B 258
dta:            DS.B 44
graf:           DS.L 1
sound:          DS.L 1
                END
