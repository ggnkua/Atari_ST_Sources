;************************************************
;*            What's Bootsy doing II            *
;* FÅhrt entweder nach einer angegebenen Anzahl *
;*  von VBlanks einen Kaltstart durch oder de-  *
;*   installiert sich bei einem zweiten Start.  *
;*  Dank an Fronti und Rainer Zufall (Prost!),  *
;*    schîne GrÅûe an Elephant und Dreizack.    *
;*                                              *
;* Geschrieben im MÑrz 1990 von Laurenz PrÅûner *
;*                                              *
;* Turbo-Ass 1.36 - Source fÅr 680x0-Assembler  *
;************************************************

                OPT F+

memvalid        EQU $0420
Busfehler       EQU $08
Freie_Register  EQU $0E
_vblqueue       EQU $0456

                TEXT
Anfang:         clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #$01
                addq.l  #$06,SP
                move.l  D0,-(SP)        ;Super
                movea.l _vblqueue.w,A4
                addq.l  #$04,A4         ;VBI 1 anfordern
                lea     VBI_Rout(PC),A5 ;Routine
                bsr.s   XBRA
                move.w  #$20,-(SP)
                trap    #$01
                addq.l  #$06,SP
                tst.l   D7
                bne.s   De
                pea     Meldung(PC)
                move.w  #$09,-(SP)
                trap    #$01
                addq.l  #$06,SP
                clr.w   -(SP)
                move.l  #Ende-Anfang+$0100,-(SP)
                move.w  #$31,-(SP)
Schultz:        pea     LP(PC)
                move.w  #$09,-(SP)
                trap    #$01
                addq.l  #$06,SP
                trap    #1
De:             pea     Notmeld(PC)
                move.w  #$09,-(SP)
                trap    #$01
                addq.l  #$06,SP
                clr.w   -(SP)
                bra.s   Schultz

XBRA:           movea.l (A4),A6         ;Startadresse der Routine holen
                move.l  A4,D0           ;Ursprungsvektor merken

Kette:          cmpa.w  #$0C,A6
                ble.s   Install         ;a6<=12 -> Kettenende.
                cmpi.l  #'XBRA',-$0C(A6) ;XBRA-Struktur gefunden?
                bne.s   Install         ;Wenn nicht, dann gleich installieren
                move.l  -$08(A5),D7     ;Ist es die gleiche Routine?
                cmp.l   -$08(A6),D7
                beq.s   Found           ;Ja!
                lea     -4(A6),A4
                movea.l -4(A6),A6
                bra.s   Kette

Install:        movea.l D0,A4
                move.l  (A4),-4(A5)     ;Routine Installieren
                move.l  A5,(A4)
                moveq   #$00,D7         ;Flag in d7 setzen
                rts

Found:          move.l  -$04(A6),(A4)   ;Oldadr rekonstruieren
                moveq   #-$01,D7        ;Flag in d7 auf #-1 setzen
                rts

VBI_Zaehler:    DC.L 70*60      ;0=Reset angefordert, anzahl der VBLs
                DC.L 'XBRA'     ;bis zum auszufÅhrenden RESET.
                DC.L 'LPVR'
Old:            DS.L 1
VBI_Rout:       subq.l  #$01,VBI_Zaehler
                beq.s   RESET
                movea.l Old(PC),A0
                move.l  A0,D0
                beq.s   Weiter
                jsr     (A0)
Weiter:         rts

RESET:          clr.w   memvalid.w
                movea.l 4,A0
                jmp     (A0)

                DATA
Meldung:        DC.B $1B,'EKaltstart von L. PrÅûner'
                DC.B $20,'ist installiert.',$00
                EVEN
Notmeld:        DC.B $1B,'EKaltstart wurde entfernt',$00
                EVEN
LP:             DC.B $0A,$0D,$BD,' PrÅûco Prod. 1990'
                DC.B $00
Ende:           END
