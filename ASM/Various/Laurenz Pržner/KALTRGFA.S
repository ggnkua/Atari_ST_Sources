;*****************************************
;*        What's Bootsy doing II         *
;* Anpassung an GFA-Basic von L. PrÅûner *
;*                                       *
;* Aufruf: ~C:resrout% (mode%,L:Delay)   *
;*  Sprache: MC 680x0 - Assembler        *
;* Compiler: Turbo - Ass 1.36            *
;*****************************************

                OPT F+
memvalid        EQU $0420
Busfehler       EQU $08
Freie_Register  EQU $0E
_vblqueue       EQU $0456

                TEXT
Anfang:         movem.l D0-A6,Regsave
                move.w  $04(SP),D6
                move.l  $06(SP),VBI_Zaehler
                clr.l   -(SP)
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
                movem.l Regsave(PC),D0-A6
                rts

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
                moveq   #$00,D7
                rts

Found:          tst.l   D6              ;0=>Deinstallieren
                bne.s   Hops
                move.l  -$04(A6),(A4)   ;Oldadr rekonstruieren

Hops:           moveq   #-$01,D7
                rts

VBI_Zaehler:    DC.L 70*60
                DC.L 'XBRA'
                DC.L 'LPVR'
Old:            DS.L 1
VBI_Rout:       subq.l  #$01,VBI_Zaehler
                beq.s   RESET
                movea.l Old(PC),A0
                move.l  A0,D0
                beq.s   Weiter
                jsr     (A0)
Weiter:         rts

RESET:          clr.l   memvalid.w
                movea.l 4,A0
                jmp     (A0)
Regsave:        DS.L $0F
Abgang:         END
