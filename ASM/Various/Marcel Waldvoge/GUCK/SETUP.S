;
; SETUP - (c) 1987, 1988, 1989, 1990 by Marcel Waldvogel
;

            OUTPUT 'C:\AUTO\SETUP.PRG'  ;Optionen fÅr den Turboass
            DEFAULT 5
            OPT F+                      ;Fastloadbit setzen

sync        EQU $FFFF820A               ;Das Synchronisationsregister

psgsel      EQU $FFFF8800               ;Die Register des Soundchip
psgrd       EQU $FFFF8800
psgwd       EQU $FFFF8802

conterm     EQU $0484                   ;einige Systemvariablen
_shell_p    EQU $04F6


start:      movea.l 4(A7),A5            ;Hole Basepage
            lea     stack(PC),A7        ;Setze eigenen Stack
            movea.l 12(A5),A0           ;Berechne ProgrammlÑnge
            adda.l  20(A5),A0
            adda.l  28(A5),A0
            lea     256(A0),A0          ;A0 := A0 + 256 (LÑnge der Basepage)
            move.l  A0,-(A7)
            move.l  A5,-(A7)
            clr.w   -(A7)               ;Speicher verkleinern (wegen Pexec())
            move.w  #$4A,-(A7)          ;Mshrink()
            trap    #1                  ;GEMDOS
            lea     12(A7),A7

            pea     msg(PC)             ;Mitteilung ausgeben
            move.w  #9,-(A7)            ;Cconws()
            trap    #1                  ;GEMDOS
            addq.l  #6,A7

            move.w  #37,-(A7)           ;Vsync(), auf VSYNC warten
            trap    #14                 ;XBIOS
            addq.l  #2,A7

            pea     super(PC)           ;Einige Einstellungen vornehmen
            move.w  #38,-(A7)           ;Supexec()
            trap    #14                 ;XBIOS
            addq.l  #6,A7

            move.w  #4,-(A7)            ;Drucker auf EPSON (960 Punkte) stellen
            move.w  #33,-(A7)           ;Setprt()
            trap    #14                 ;XBIOS
            addq.l  #4,A7

            move.w  #1,-(A7)            ;Tastaturrepeat beschleunigen
            move.w  #$0D,-(A7)
            move.w  #35,-(A7)           ;Kbrate()
            trap    #14                 ;XBIOS
            addq.l  #6,A7

            move.w  #$FFFF,-(A7)        ;Ist CONTROL gedrÅckt?
            move.w  #$0B,-(A7)          ;Kbshift()
            trap    #13                 ;BIOS
            addq.l  #4,A7

            btst    #2,D0               ;Control?
            beq.s   term                ;Nein -> Ende

            clr.l   -(A7)               ;Dasselbe Environment
            pea     null(PC)            ;Keine Kommandozeile
            pea     prgname(PC)         ;Der Programmname
            clr.w   -(A7)               ;Laden & starten
            move.w  #$4B,-(A7)          ;Pexec(), Programm ausfÅhren
            trap    #1                  ;GEMDOS
            lea     14(A7),A7

            tst.l   D0                  ;War alles ok?
            bpl.s   term                ;Ja -> Ende

            move.w  #7,-(A7)            ;Sonst die Klingel betÑtigen
            move.w  #2,-(A7)            ;CON:
            move.w  #3,-(A7)            ;Bconout()
            trap    #13
            addq.l  #6,A7

term:       clr.w   -(A7)               ;Pterm0(), Programm beenden
            trap    #1                  ;GEMDOS



super:      bchg    #1,sync.w           ;50/60 Hz wechseln
            move.b  #6,conterm.w        ;Tastenklick ausschalten
            clr.l   _shell_p.w          ;_shell_p lîschen (bleibt bei RESET)
            move    SR,D1               ;Interrupts ausschalten
            move    #$2700,SR
            move.b  #14,psgsel.w        ;WÑhle PSG-Register 14 (Port A)
            move.b  psgrd.w,D0          ;Lies die Daten
            or.b    #%110,D0            ;Deselektiere die Laufwerke
            move.b  D0,psgwd.w          ;Schreibe Daten zurÅck
            move    D1,SR               ;Interrupts wieder einschalten
            rts

            DATA

msg:        DC.B 13,10                  ;Die Mitteilung
            DC.B ' Setup - <Ctrl> startet \COMMAND.TOS'
            DC.B 13,10,0

prgname:    DC.B '\COMMAND.TOS'         ;Das Programm
null:       DC.B 0                      ;Die Kommandozeile

copr:       DC.B '(c) 1987-90 Marcel Waldvogel (Release 17)',0


            EVEN
            BSS
            EVEN

            DS.L $80                    ;512 Bytes
stack:      DS.L 1                      ;Der Stack

            EVEN
            END
