********************************************************************************
**                                                                            **
** Fullscreen-Routine                                                         **
** ~~~~~~~~~~~~~~~~~~                               ***** **    ** ** **      **
**                                                  **    **    ** ** **      **
** Ω by Felix Brandt                                ****  **    **  ***       **
**      Jahnstr. 51                                 **    **    ** ** **      **
**      W-8130 Starnberg                            **    ***** ** ** **      **
**      Germany                                                               **
**                                                     of Delta Force         **
**                                                      of The Union          **
** Letzte énderung               : 11.11.1991                                 **
**                                                                            **
********************************************************************************

; Die Routine lÑuft NICHT in monochrom und auf TTs.

                TEXT

                pea     start(PC)
                move.w  #38,-(SP)            ; Supervisor
                trap    #14
                addq.l  #6,SP

                clr.w   -(SP)                ; Ende
                trap    #1

;-----------------------------------------------------------------------------

start:          bsr     install_all          ; alles initialisieren

                bsr     get_lines            ; Anzahl der Zeilen ermitteln

                movea.l screen(PC),A0        ; Graphikmuster zeichnen
                lea     160(A0),A0
                move.w  #276-1,D0
doit:           REPT 26/2
                move.w  #%101010101010101,(A0)+
                move.w  #%11001100110011,(A0)+
                move.w  #%111100001111,(A0)+
                move.w  #%11111111,(A0)+
                move.w  #%1010101010101010,(A0)+
                move.w  #%1100110011001100,(A0)+
                move.w  #%1111000011110000,(A0)+
                move.w  #%1111111100000000,(A0)+
                ENDR
                lea     2*8+6(A0),A0
                dbra    D0,doit

                move.l  #fullvbl,$70.w       ; Fullscreen-VBL-Routine

waiter:         cmpi.b  #$39,$fffffc02.w     ; Auf Space warten
                bne.s   waiter

;---
end:            bsr.s   restore_all          ; alles zurÅcksetzen

                rts

;-----------------------------------------------------------------------------

                >PART 'Install_All' ; alles installieren

install_all:
; Initialisiert alle Hardware-Register

                move    #$2700,SR            ; alle IRQs sperren

                move.b  $ffff820a.w,oldsync  ; Alte Synchronisation
                move.b  $ffff8260.w,oldres   ; Alte Auflîsung

                movem.l $ffff8240.w,D0-D7    ; Alte Palette
                movem.l D0-D7,oldpalette

                lea     $ffff8201.w,A0       ; Screenadresse holen
                movep.w 0(A0),D0
                move.w  D0,oldscreen

                move.l  #screen_base,D0
                clr.b   D0                   ; untere 8 Bits weg
                move.l  D0,screen

                lsr.l   #8,D0                ; Bildschirmadresse setzen
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)

                bsr     init_mfp

                move    #$2300,SR            ; IRQs an

                moveq   #$12,D0              ; Maus aus
                bsr.s   send_ikbd

                bsr     vsync
                move.b  #2,$ffff820a.w       ; 50 Hz

                bsr.s   vsync
                clr.b   $ffff8260.w          ; Lores

                movem.l palette(PC),D0-D7    ; Neue Palette
                movem.l D0-D7,$ffff8240.w

                rts

                ENDPART

                >PART 'Restore_All' ; alles zurÅcksetzen

restore_all:
; alle Hardware-Register werden wieder zurÅckgesetzt

                move.l  #vbl,$70.w
                bsr.s   vsync

                movem.l oldpalette,D0-D7     ; Alte Palette
                movem.l D0-D7,$ffff8240.w

                bsr.s   vsync
                move.b  #2,$ffff820a.w       ; 50Hz

                bsr.s   vsync
                move.b  #0,$ffff820a.w       ; 60Hz (um Syncerrors zu beheben)

                bsr.s   vsync
                move.b  oldsync(PC),$ffff820a.w ; Alte Synchronisation
                move.b  oldres(PC),$ffff8260.w ; Alte Auflîsung

                bsr     restore_mfp

                moveq   #$08,D0              ; Maus wieder an
                bsr.s   send_ikbd

                move.w  oldscreen(PC),D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)             ; alte Screenadresse setzen

                rts
                ENDPART

                >PART 'Send_IKBD'
send_ikbd:
; sendet d0 an IKBD
                lea     $fffffc00.w,A0
waitkeyready:   btst    #1,(A0)              ; Tastaturprozessor bereit?
                beq.s   waitkeyready
                move.b  D0,2(A0)
                rts

                ENDPART

                >PART 'Vsync'
vsync:          sf      vblflag
waitforsync:    tst.b   vblflag
                beq.s   waitforsync
                rts
                ENDPART

                >PART 'MFP-Install+DeInstall'
init_mfp:
; rettet und setzt alle IRQ's

                move.l  $0120.w,oldtimerb
                move.l  $70.w,oldvbl
                lea     $fffffa00.w,A0       ; MFP
                move.b  $07(A0),oldmfp07
                move.b  $09(A0),oldmfp09
                move.b  $11(A0),oldmfp11
                move.b  $13(A0),oldmfp13
                move.b  $15(A0),oldmfp15
                move.b  $17(A0),oldmfp17
                move.b  $1b(A0),oldmfp1b
                move.b  $21(A0),oldmfp21
                clr.b   $07(A0)              ; alle IRQs aus
                clr.b   $09(A0)
                clr.b   $13(A0)
                clr.b   $15(A0)
                bset    #0,$07(A0)           ; Timer B erlauben
                bset    #0,$13(A0)
                bclr    #3,$17(A0)           ; Automatic End Of Interrupt

                move.l  #vbl,$70.w           ; am Anfang (zum Initialisieren)
                move.l  #timer_b,$0120.w

                rts

restore_mfp:
; setzt alle MFP-Register wieder zurÅck

                move    #$2700,SR
                move.l  oldtimerb(PC),$0120.w
                move.l  oldvbl(PC),$70.w
                lea     $fffffa00.w,A0       ; MFP
                move.b  oldmfp07(PC),$07(A0)
                move.b  oldmfp09(PC),$09(A0)
                move.b  oldmfp11(PC),$11(A0)
                move.b  oldmfp13(PC),$13(A0)
                move.b  oldmfp15(PC),$15(A0)
                move.b  oldmfp17(PC),$17(A0)
                move.b  oldmfp1b(PC),$1b(A0)
                move.b  oldmfp21(PC),$21(A0)
                move    #$2300,SR
                rts

                ENDPART

;------------------------------------------------------------------------------

vbl:            st      vblflag              ; VBL-Flag setzen
                rte

timer_b:        rte

                >PART 'Zeilen ermitteln'

get_lines:
; Es wird ermittelt wieviel Zeilen, die MMU bei geîffnetem oberen Border
; darstellt.

                move.l  $70.w,-(SP)

                move.l  #testvbl1,$70.w

                bsr     vsync
                bsr     vsync

                subq.w  #3,scanlines         ; Wert benutzbar machen

                cmpi.w  #216,scanlines       ; wegen bestimmten STEs notwendig
                blt.s   itsok
                move.w  #226,scanlines
itsok:

                move.l  (SP)+,$70.w
                rts

testvbl1:       clr.b   $fffffa1b.w
                move.b  #1,$fffffa21.w
                move.l  #testb1,$0120.w
                move.b  #8,$fffffa1b.w

                move.l  #testvbl2,$70.w

                clr.b   $ffff820a.w          ; 60 Hz
                st      vblflag
                rte

testvbl2:       clr.b   $fffffa1b.w
                st      vblflag
                rte

testb1:         addq.w  #1,scanlines
                move.b  #2,$ffff820a.w       ; 50 Hz
                move.l  #testb2,$0120.w
                rte

testb2:         addq.w  #1,scanlines
                rte

                ENDPART

                >PART 'Fullscreen-Routinen'

fullvbl:        move.l  #open_top,$68.w      ; HBL fÅr den oberen Border
                move.w  #33,hblcount         ; ZeilenzÑhler setzen
                move    #$2100,SR            ; Los geht's

                st      vblflag
                move.w  #$2100,(SP)          ; SR setzen
                rte

open_top:       subq.w  #1,hblcount          ; ZÑhlen
                beq.s   openit
                rte

openit:         move.l  #open_top2,$68.w
                stop    #$2100
; Der Prozessor kann nur noch durch einen HBL wieder zum Leben erweckt werden.

open_top2:      move    #$2700,SR            ; [16] Keine Stîrung bitte
                addq.l  #6,SP                ; [8]  Stack reparieren

                REPT 86
                nop
                ENDR

                move.b  #0,$ffff820a.w       ; [16]  60 Hz

                REPT 17
                nop
                ENDR

                move.b  #2,$ffff820a.w       ; [16]  50 Hz

                lea     $ffff820a.w,A0       ; Sync-Register
                lea     $ffff8260.w,A1       ; Auflîsungsregister

                moveq   #0,D0
waitsync:       move.b  $ffff8209.w,D0       ; Screen-Low-Byte
                beq.s   waitsync
                not.w   D0                   ; Wert negieren
                lsr.w   D0,D0                ; Synchronisation mit dem Strahl

; Ab hier ist der Code synchron zum Rasterstrahl:

                REPT 70         ; Auf die richtige Stelle warten
                nop
                ENDR

                move.w  scanlines(PC),D7     ; [8]  Zeilen

lines:          nop

                move.w  A1,(A1)              ; [8]  Linker Rand
                nop                          ; [4]
                move.b  D0,(A1)              ; [8]

                REPT 89
                nop
                ENDR

                move.b  D0,(A0)              ; [8]  Rechter Rand
                move.w  A0,(A0)              ; [8]

                REPT 13
                nop
                ENDR

                move.w  A1,(A1)              ; [8]  Stabilisator
                nop                          ; [4]
                move.b  D0,(A1)              ; [8]

                REPT 11-3
                nop
                ENDR

                dbra    D7,lines             ; [12/16]

                move.w  A1,(A1)              ; [8]  Linker Rand
                nop                          ; [4]
                move.b  D0,(A1)              ; [8]

                REPT 89
                nop
                ENDR

                move.b  D0,(A0)              ; [8]  Rechter Rand
                move.w  A0,(A0)              ; [8]

                REPT 10
                nop
                ENDR

                move.w  D0,(A0)              ; [8]  Unterer Rand 1
                nop
                move.w  A1,(A1)              ; [8]  Stabilisator
                nop                          ; [4]
                move.b  D0,(A1)              ; [8]

                REPT 11
                nop
                ENDR

                move.w  A1,(A1)              ; [8]  Linker Rand
                move.w  A0,(A0)              ; [8]  Unterer Rand 2
                move.b  D0,(A1)              ; [8]

                REPT 89
                nop
                ENDR

                move.b  D0,(A0)              ; [8]  Rechter Rand
                move.w  A0,(A0)              ; [8]

                REPT 13
                nop
                ENDR

                move.w  A1,(A1)              ; [8]  Stabilisator
                nop                          ; [4]
                move.b  D0,(A1)              ; [8]

                REPT 11-2
                nop
                ENDR

                move.w  #48-1,D7             ; [8]  Zeilen

lines2:         nop

                move.w  A1,(A1)              ; [8]  Linker Rand
                nop                          ; [4]
                move.b  D0,(A1)              ; [8]

                REPT 89
                nop
                ENDR

                move.b  D0,(A0)              ; [8]  Rechter Rand
                move.w  A0,(A0)              ; [8]

                REPT 13
                nop
                ENDR

                move.w  A1,(A1)              ; [8]  Stabilisator
                nop                          ; [4]
                move.b  D0,(A1)              ; [8]

                REPT 11-3
                nop
                ENDR

                dbra    D7,lines2            ; [12/16]

                move.w  #$2300,(SP)          ; SR setzen
                rte

                ENDPART

;------------------------------------------------------------------------------

                DATA

palette:        DC.W $00,$01,$02,$03,$04,$05,$06,$07
                DC.W $17,$0117,$0227,$0337,$0447,$0557,$0667,$0777

hblcount:       DC.W -1

;------------------------------------------------------------------------------

                BSS

screen:         DS.L 1
oldvbl:         DS.L 1
oldtimerb:      DS.L 1
oldpalette:     DS.W 16
oldscreen:      DS.W 1
scanlines:      DS.W 1
oldmfp07:       DS.B 1
oldmfp09:       DS.B 1
oldmfp11:       DS.B 1
oldmfp13:       DS.B 1
oldmfp15:       DS.B 1
oldmfp17:       DS.B 1
oldmfp1b:       DS.B 1
oldmfp21:       DS.B 1
oldres:         DS.B 1
oldsync:        DS.B 1
vblflag:        DS.B 1

                DS.B 256        ; wegen unteren 8 Bits des Screens
screen_base:    DS.B 230*277    ; Bildschirmspeicher

                END
