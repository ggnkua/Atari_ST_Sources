; Sound Routine von TEX
; Ver”ffentlicht im ST-Magazin

geschwindigkeit EQU 2
vbivec          EQU $70

                move.w  #3,-(SP)
                trap    #14
                addq.l  #2,SP
                movea.l D0,A0
                move.w  #8000,D0
era_scr:        clr.l   (A0)+
                dbra    D0,era_scr

                pea     0
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,ssp

init:           move.w  #geschwindigkeit,speed
                move.w  speed,speed+2
                move.w  #1,sy
                moveq   #2,D0
                lea     stimme1(PC),A0
                lea     stimme2,A1
                movea.l A1,A2
                suba.l  A0,A2
                move.l  A2,D1
                lea     pointer(PC),A1
initloop:
                moveq   #1,D3
                clr.l   4(A0)
                move.l  (A1),(A0)
                clr.l   $08(A0)

                clr.l   $0C(A0)
                clr.l   $14(A0)
                clr.l   $18(A0)
                clr.w   $1C(A0)
                movea.l (A1)+,A2
get_next_byte:
                move.b  (A2)+,D2
                btst    #$07,D2
                beq.s   ino_transpose
                andi.b  #$7F,D2
                move.b  D2,$1D(A0)
                addq.l  #1,D3
                bra.s   get_next_byte
ino_transpose:
                andi.l  #$7F,D2

                add.l   D2,D2
                add.l   D2,D2
                lea     seqtab(PC),A2
                movea.l 0(A2,D2.w),A2
                move.l  A2,$10(A0)
                move.l  D3,$04(A0)
                adda.l  D1,A0

                dbra    D0,initloop
                move.b  #2,$0484        ; Tastaturklick aus
                move.l  vbivec,oldvbi+2
                move.l  #syn,vbivec
                clr.w   sy              ; Sound on

                move.l  #500000000,D0
wait:           subq.l  #1,D0
                bne.s   wait

                move.l  oldvbi+2,vbivec
                move.w  #1,sy           ; Sound off

                lea     ym2149(PC),A0   ; ----------- Anfang
                moveq   #9,D0
xx:             clr.b   (A0)+
                dbra    D0,xx
                move.b  #%11111000,ym2149+7 ; L”schen der Soundchip-Register
                moveq   #$0A,D0
                lea     ym2149+11(PC),A0
xx_write:       move.b  D0,$FFFF8800    ;.w
                move.b  -(A0),$FFFF8802 ;.w
                dbra    D0,xx_write     ; ----------- Ende

                move.l  ssp,-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

                clr.w   -(SP)
                trap    #1


syn:            movem.l D0-A6,savereg
                tst.w   sy
                beq.s   synein
                lea     ym2149(PC),A0
                moveq   #9,D0
regloeschloop:  clr.b   (A0)+
                dbra    D0,regloeschloop
                move.b  #%11111000,ym2149+7

                bra     write_soundchip

synein:         subq.w  #1,speed
                bpl.s   soundwork
                lea     stimme1(PC),A0
                bsr     bearbeiten

                lea     stimme2(PC),A0
                bsr     bearbeiten

                lea     stimme3(PC),A0
                bsr     bearbeiten

                move.w  speed+2(PC),speed


soundwork:      lea     stimme1(PC),A0
                bsr     soundbearbeiten
                move.w  D0,dummy
                move.b  D0,ym2149
                move.b  dummy,ym2149+1
                move.b  D1,ym2149+8

                lea     stimme2(PC),A0
                bsr     soundbearbeiten
                move.w  D0,dummy
                move.b  D0,ym2149+2
                move.b  dummy,ym2149+3
                move.b  D1,ym2149+9

                lea     stimme3(PC),A0
                bsr     soundbearbeiten
                move.w  D0,dummy
                move.b  D0,ym2149+4
                move.b  dummy,ym2149+5
                move.b  D1,ym2149+10

write_soundchip:moveq   #$0A,D0
                lea     ym2149+11(PC),A0
writeloop:      move.b  D0,$FFFF8800    ;.w
                move.b  -(A0),$FFFF8802 ;.w
                dbra    D0,writeloop
                movem.l savereg,D0-A6
oldvbi:         jmp     $FFFFFFFF


bearbeiten:     subq.b  #1,$0F(A0)
                bpl     return
bearbeiten2:    clr.b   $24(A0)
                movea.l $10(A0),A1
                move.b  (A1)+,D0
                cmpi.b  #$FF,D0
                bne     noend
                movea.l (A0),A2
                adda.l  4(A0),A2
                addq.l  #1,$04(A0)
                move.b  (A2)+,D0
                cmpi.b  #$FF,D0
                bne.s   noend2
                move.l  #1,$04(A0)
                movea.l (A0),A2
                btst    #$07,(A2)
                beq.s   notran2
                move.b  (A2)+,D0
                andi.b  #$7F,D0
                move.b  D0,$1D(A0)
                move.l  #2,$04(A0)
notran2:        move.b  (A2),D0
noend2:         btst    #$07,D0
                beq.s   notran
                andi.b  #$7F,D0
                move.b  D0,$1D(A0)
                move.b  (A2)+,D0
                addq.l  #1,$04(A0)
notran:         andi.l  #$7F,D0
                add.l   D0,D0
                add.l   D0,D0
                lea     seqtab(PC),A2
                adda.l  D0,A2
                move.l  (A2),$10(A0)
                bra     bearbeiten2
noend:          btst    #$05,D0
                beq     kein_anhaengen
                bset    #$01,$28(A0)
kein_anhaengen: btst    #$07,D0
                beq     nowave
                andi.b  #$1F,D0
                move.b  D0,$0F(A0)
                move.b  (A1)+,D0
                andi.l  #$1F,D0
                add.l   D0,D0
                add.l   D0,D0
                lea     wavetab(PC),A2
                movea.l 0(A2,D0.w),A2
                move.b  (A2)+,D0
                move.b  (A2),$0C(A0)
                move.b  (A2)+,$0D(A0)
                move.b  (A2)+,$26(A0)
                move.b  (A2),$25(A0)
                move.b  (A2)+,$27(A0)
                move.l  A2,$08(A0)
                move.l  A2,$1E(A0)
                andi.l  #$7F,D0
                add.l   D0,D0
                add.l   D0,D0
                lea     arpeggiotab(PC),A2
                movea.l 0(A2,D0.w),A2
                move.b  (A2),$1C(A0)
                move.b  (A2)+,$22(A0)
                move.l  A2,$14(A0)
                move.l  A2,$18(A0)
                move.b  (A1)+,$23(A0)
                bra.s   init_sounds
nowave:         btst    #$06,D0
                beq.s   nopause
                andi.b  #$1F,D0
                move.b  D0,$0F(A0)
                clr.b   $23(A0)
                move.b  #$01,$24(A0)
                bra.s   init_sounds
nopause:        andi.b  #$1F,D0
                move.b  D0,$0F(A0)
                move.b  (A1)+,$23(A0)
init_sounds:    bset    #6,$28(A0)
                move.l  A1,$10(A0)

                btst    #1,$28(A0)
                bne.s   return
                move.b  $0D(A0),$0C(A0)
                move.b  $22(A0),$1C(A0)
                move.l  $14(A0),$18(A0)
                move.l  $1E(A0),$08(A0)
return:         bclr    #1,$28(A0)
                rts

soundbearbeiten:clr.l   D0
                subq.b  #1,$1C(A0)
                bne.s   noendarp
                move.b  $22(A0),$1C(A0)
nochmalarp:     movea.l $18(A0),A2
                addq.l  #1,$18(A0)
                cmpi.b  #$FF,(A2)
                bne.s   noendarp2
                move.l  $14(A0),$18(A0)
                bra.s   nochmalarp
noendarp:       movea.l $18(A0),A2
noendarp2:      move.b  (A2),D0

                add.b   $23(A0),D0
                add.b   $1D(A0),D0
                subi.b  #$0C,D0

                bpl.s   noteok
                clr.l   D0
noteok:         lea     frequenztab(PC),A1
                andi.l  #$7F,D0
                add.l   D0,D0
                adda.l  D0,A1
                move.w  (A1),D0
                andi.l  #$FFFF,D0

                moveq   #0,D1
                move.b  $28(A0),D6
                btst    #6,D6
                beq     novibrato
                move.b  D1,D5
                move.b  $25(A0),D4
                move.b  $27(A0),D1
                btst    #7,D6
                bne.s   vibrato
                btst    #0,D6
                beq.s   second_time
vibrato:        btst    #5,D6
                bne.s   hochvib
                sub.b   $26(A0),D1
                bcc.s   write_back
                bset    #5,$28(A0)

                moveq   #0,D1
                bra.s   write_back
hochvib:        add.b   $26(A0),D1
                cmp.b   D4,D1
                bcs.s   write_back
                bclr    #5,$28(A0)

                move.b  D4,D1

write_back:     move.b  D1,$27(A0)
second_time:    lsr.b   #1,D4
                sub.b   D4,D1

                bcc.s   gnull
                subi.w  #$0100,D1
gnull:          addi.b  #$A0,D5
                bcc.s   addiere
nochmal:        add.w   D1,D1
                addi.b  #$18,D5
                bcc.s   nochmal
addiere:        add.w   D1,D0
novibrato:      bchg    #0,$28(A0)

                clr.l   D1
                tst.b   $24(A0)
                bne.s   pauseok
                subq.b  #1,$0C(A0)
                bne.s   endadsr
                move.b  $0D(A0),$0C(A0)
                movea.l 8(A0),A1
                cmpi.b  #$FF,1(A1)
                beq.s   endadsr
                addq.l  #1,$08(A0)
endadsr:        movea.l 8(A0),A1
                move.b  (A1),D1
pauseok:        rts

                DATA
ssp:            DC.L 0
savereg:        DS.L 16

ym2149:         DC.B 0,0,0,0,0,0,0,%11111000,0,0,0
                EVEN
stimme1:        DC.L 0
                DC.L 0
                DC.L 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.L 0

                DC.L 0
                DC.L 0
                DC.B 0
                DC.B 0
                DC.L 0

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0

                EVEN

stimme2:        DC.L 0
                DC.L 0
                DC.L 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.L 0

                DC.L 0
                DC.L 0
                DC.B 0
                DC.B 0
                DC.L 0

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0

                EVEN

stimme3:        DC.L 0
                DC.L 0
                DC.L 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.L 0

                DC.L 0
                DC.L 0
                DC.B 0
                DC.B 0
                DC.L 0

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0

                EVEN

sy:             DC.W 1
dummy:          DC.W 0
speed:          DC.W 0,0

frequenztab:    DC.B $0E,$EE,$0E,$17,$0D,$4D,$0C,$8E
                DC.B $0B,$D9,$0B,$2F,$0A,$8E,$09,$F7
                DC.B $09,$67,$08,$E0,$08,$61,$07,$E8
                DC.B $07,$77,$07,$0B,$06,$A6,$06,$47
                DC.B $05,$EC,$05,$97,$05,$47,$04,$FB
                DC.B $04,$B3,$04,$70,$04,$30,$03,$F4
                DC.B $03,$BB,$03,$85,$03,$53,$03,$23
                DC.B $02,$F6,$02,$CB,$02,$A3,$02,$7D
                DC.B $02,$59,$02,$38,$02,$18,$01,$FA
                DC.B $01,$DD,$01,$C2,$01,$A9,$01,$91
                DC.B $01,$7B,$01,$65,$01,$51,$01,$3E
                DC.B $01,$2C,$01,$1C,$01,$0C,$00,$FD
                DC.B $00,$EE,$00,$E1,$00,$D4,$00,$C8
                DC.B $00,$BD,$00,$B2,$00,$A8,$00,$9F
                DC.B $00,$96,$00,$8E,$00,$86,$00,$7E
                DC.B $00,$77,$00,$70,$00,$6A,$00,$64
                DC.B $00,$5E,$00,$59,$00,$54,$00,$4F
                DC.B $00,$4B,$00,$47,$00,$43,$00,$3F
                DC.B $00,$3B,$00,$38,$00,$35,$00,$32
                DC.B $00,$2F,$00,$2C,$00,$2A,$00,$27
                DC.B $00,$25,$00,$23,$00,$21,$00,$1F
                DC.B $00,$1D,$00,$1C,$00,$1A,$00,$19
                DC.B $00,$17,$00,$16,$00,$15,$00,$13
                DC.B $00,$12,$00,$11,$00,$10,$00,$0F

                EVEN

arpeggiotab:    DC.L arp0,arp1,arp2,arp3,arp4,arp5,arp6,arp7

arp0:           DC.B $01,$00,$00,$00,$00,$FF
arp1:           DC.B $01,$00,$03,$07,$FF
arp2:           DC.B $01,$00,$04,$07,$FF
arp3:           DC.B $01,$00,$05,$08,$FF
arp4:           DC.B $01,$00,$05,$09,$FF
arp5:           DC.B $01,$00,$0C,$FF
arp6:           DC.B $01,$00,$05,$08,$FF
arp7:           DC.B $01,$00,$05,$07,$FF

                EVEN

wavetab:        DC.L wave0,wave1,wave2,wave3,wave4,wave5,wave6,wave7,wave8
                DC.L wave9,wave10,wave11,wave12,wave13,wave14,wave15,wave16
wave0:          DC.B $05,$03,$50,$02,$0F,$0F,$0E,$0E,$0D,$0D,$0D,$0C,$0C,$0C,$0C,$0B,$0B,$0B,$0B,$0B,$FF
wave1:          DC.B $05,$01,$50,$03,$0E,$0F,$0F,$0E,$0D,$0D,$0C,$0C,$0B,$0B,$0A,$0A,$09,$FF
wave2:          DC.B $05,$03,$46,$02,$0F,$0E,$0E,$0D,$0D,$0C,$0C,$0C,$0B,$0B,$0B,$0A,$0A,$0A,$09,$08,$07,$FF
wave3:          DC.B $06,$03,$02,$03,$0F,$0F,$0E,$0E,$0D,$0D,$0C,$0C,$0C,$0B,$0B,$0A,$0A,$FF
wave4:          DC.B $07,$03,$02,$03,$0F,$0F,$0E,$0E,$0D,$0D,$0C,$0C,$0B,$0B,$0A,$0A,$FF
wave5:          DC.B $00,$02,$14,$08,$0E,$0F,$0E,$0D,$0C,$0B,$0A,$08,$FF
wave6:          DC.B $05,$04,$46,$02,$0F,$0F,$0E,$0E,$0D,$0D,$0D,$0C,$0C,$0C,$0B,$0B,$0B,$0B,$0A,$0A,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00,$FF
wave7:          DC.B $00,$03,$28,$06,$0F,$0F,$0E,$0E,$0D,$0D,$0C,$0C,$0C,$0B,$0A,$FF
wave8:          DC.B $03,$03,$00,$00,$0D,$0E,$0E,$0E,$0D,$0D,$0C,$0C,$0B,$0A,$FF
wave9:          DC.B $04,$03,$00,$00,$0D,$0E,$0E,$0E,$0D,$0D,$0C,$0C,$0B,$0A,$FF
wave10:         DC.B $01,$03,$00,$00,$0D,$0E,$0E,$0E,$0D,$0D,$0C,$0C,$0B,$0A,$FF
wave11:         DC.B $02,$03,$00,$00,$0D,$0E,$0E,$0E,$0D,$0D,$0C,$0C,$0B,$0A,$FF
wave12:         DC.B $01,$03,$00,$00,$0F,$0E,$0C,$0B,$0A,$09,$FF
wave13:         DC.B $02,$03,$00,$00,$0F,$0E,$0C,$0B,$0A,$09,$FF
wave14:         DC.B $04,$03,$00,$00,$0F,$0E,$0C,$0B,$0A,$09,$FF
wave15:         DC.B $00,$04,$00,$00,$0F,$0E,$0E,$0D,$0C,$0B,$0B,$0A,$09,$08,$FF
wave16:         DC.B $03,$03,$00,$00,$0F,$0E,$0C,$0B,$0A,$09,$FF

                EVEN

pointer:        DC.L seqst1,seqst2,seqst3

seqst1:         DC.B $8C,$01,$01,$02,$02,$03,$03,$0B,$0B,$02,$FF

seqst2:         DC.B $80,$06,$06,$09,$09,$80,$0C,$85,$0C
                DC.B $80,$0C,$85,$0C,$80,$0C,$85,$0C,$80,$0C,$85,$0C
                DC.B $80,$09,$09,$09,$FF

seqst3:         DC.B $8C,$07,$98,$08,$8C,$0A,$0A,$8C,$0D,$91,$0D
                DC.B $8C,$0D,$91,$0D,$8C,$0D,$91,$0D,$8C,$0D,$91,$0D
                DC.B $8C,$0A,$0A,$0A,$FF


                EVEN
seqtab:         DC.L seg1,seg1,seg2,seg3,seg4,seg4,seg4
                DC.L seg5,seg6,seg7,seg8,seg9,seg10,seg11


seg1:           DC.W $8301,$2D03,$2803,$3003,$2803,$2F01,$2803,$2D01
                DC.W $2D03,$2803,$2B03,$2603,$2F03,$2603,$2D01,$2603
                DC.W $2B01,$2B03,$2603,$2903,$2403,$2D03,$2403,$2B01
                DC.W $2403,$2901,$2903,$2403,$2B03,$2603,$2F03,$2603
                DC.W $2D01,$2603,$2B01,$2B03,$26FF

seg2:           DC.W $8100,$2D01,$2F01,$3001,$2F07,$2D03,$2D01,$2B05
                DC.W $2D03,$2805,$3005,$2F03,$2B0F,$2D01,$2901,$2B01
                DC.W $2D01,$2B07,$2903,$2901,$2805,$2903,$2405,$2D05
                DC.W $2B03,$280F,$2901,$2601,$2801,$2901,$2807,$2603
                DC.W $2601,$2405,$2603,$2105,$2905,$2803,$240F,$2601
                DC.W $2B01,$2D01,$2F01,$2D07,$2B03,$2B01,$2605,$2B03
                DC.W $2605,$2F05,$2D03,$260F,$2BFF

seg3:           DC.W $8102,$3001,$2F03,$2D03,$2D01,$2B11,$2D01,$3001
                DC.W $2F03,$2D03,$2D01,$2B05,$2D03,$3003,$2F03,$2B05
                DC.W $3005,$2F03,$2B0F,$2D3F,$2D01,$2D01,$2803,$2403
                DC.W $2101,$2D11,$2101,$2D01,$2803,$2403,$2101,$2D03
                DC.W $2105,$2D05,$2D41,$012D,$0128,$0324,$0321,$012D
                DC.W $1121,$012D,$0128,$0324,$0321,$012D,$0321,$052D
                DC.W $052D,$41FF

seg4:           DC.W $8507,$2105,$2103,$1F07,$2107,$2805,$1F05,$1F03
                DC.W $1D07,$1F07,$2605,$1D05,$1D03,$1C07,$1D07,$2405
                DC.W $1F05,$1F03,$1D07,$1F07,$26FF

seg5:           DC.W $8B0A,$2D03,$2D0F,$2D8B,$0B2B,$032B,$0F2B,$0B29
                DC.B $03,$29,$0F,$29,$0B,$2B,$03,$2B,$0F,$2B,$FF

seg6:           DC.B $8B,$08,$28,$03,$28,$0F,$28,$8B,$09,$26,$03,$26,$0F,$26,$0B
                DC.B $24,$03,$24,$0F,$24,$0B,$26,$03,$26,$0F,$26,$FF

seg7:           DC.W $850F,$2D05,$2D03,$2B0B,$2D01,$2801,$2B05,$2D05
                DC.W $2D03,$2B07,$2D47,$0529,$0529,$0328,$0B29,$0124
                DC.W $0128,$0529,$0529,$0328,$0729,$4705,$2605,$2603
                DC.W $240B,$2601,$2101,$2405,$2605,$2603,$2407,$2647
                DC.W $052B,$052B,$0329,$0B2B,$0126,$0129,$052B,$052B
                DC.W $0329,$072B,$47FF

seg8:           DC.W $830C,$2D03,$2D03,$2D03,$2D01,$2D01,$2D03,$2D03
                DC.W $2D03,$2D83,$0C2D,$032D,$032D,$032D,$012D,$012D
                DC.W $032D,$032D,$032D,$830D,$2903,$2903,$2903,$2901
                DC.W $2901,$2903,$2903,$2903,$2983,$0D29,$0329,$0329
                DC.W $0329,$0129,$0129,$0329,$0329,$0329,$830C,$2603
                DC.W $2603,$2603,$2601,$2601,$2603,$2603,$2603,$2683
                DC.W $0C26,$0326,$0326,$0326,$0126,$0126,$0326,$0326
                DC.W $0326,$830E,$2603,$2603,$2603,$2601,$2601,$2603
                DC.W $2603,$2603,$2683,$0E26,$0326,$0326,$0326,$0126
                DC.W $0126,$0326,$0326,$0326
                DC.B $FF

seg9:           DC.B $85
                DC.W $0630,$052F,$0F28,$2328,$0330,$032F,$0328,$0130
                DC.W $032F,$0528,$0329,$032B,$052D,$052B,$0F24,$2324
                DC.W $032D,$032B,$0324,$012D,$032B,$0524,$0326,$0328
                DC.W $0529,$0528,$0F21,$2321,$0329,$0328,$0321,$0129
                DC.W $0328,$0521,$032B,$032D,$052F,$052D,$0F26,$2326
                DC.W $032F,$032D,$0326,$012F,$032D,$0526,$032D,$032F
                DC.B $FF

seg10:          DC.B $83
                DC.W $0521,$0121,$0121,$0321,$0121,$0121,$0321,$0121
                DC.W $0121,$0121,$0121,$0121,$0121,$0321,$0121,$0121
                DC.W $0321,$0121,$0121,$0321,$0121,$0121,$0121,$0121
                DC.W $0121,$0121
                DC.B $FF

seg11:          DC.B $85
                DC.W $0328,$9904,$2885,$0328,$8504,$2883,$0328,$0528
                DC.W $8504,$2883,$0328,$FF00

                EVEN

                END
