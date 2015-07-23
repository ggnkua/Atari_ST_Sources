;
; The MindBomb-Loader
;
; MindBomb-Loader was released on 2-Jun-90
; by Ford Perfect of the Black Monolith Team / Alliance
;
; Please do _NOT_ copy this source around like demos or games or things
; like that; only to reliable persons who really _KNOW_ what to do with it !!!
; I'd not like to see it in everyone's source code collection !!!
;
;
; 1 Minute Menu make by Gaston

                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                addq.l  #6,SP

                move.w  #0,-(SP)
                move.l  #-1,-(SP)
                move.l  #-1,-(SP)
                move.w  #5,-(SP)
                trap    #14
                adda.l  #12,SP

                move.w  #$0000,$FFFF8240.w

                pea     info_text(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP

                move.b  #3,puffer       ;max 2 zeichen + cr
                pea     puffer(PC)
                move.w  #10,-(SP)
                trap    #1
                addq.l  #6,SP

                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3

                lea     puffer(PC),A6
                move.b  1(A6),D1
                sub.b   #1,D1
                addq.l  #2,A6

convert:
                move.b  (A6)+,D2
                subi.b  #$30,D2
                mulu    #10,D3
                add.l   D2,D3
                dbra    D1,convert

                move.b  D3,screen

                lea     L0026(PC),A0
                move.b  screen(PC),D0
                mulu    #10,D0
                adda.l  D0,A0

                move.w  (A0)+,D4        ; Start
                move.w  (A0)+,D5        ; Count
                move.w  (A0)+,D6        ; Side
                move.l  (A0)+,D7        ; XOR

                lea     mindbomb(PC),A6

                movea.l A6,A5
                move.w  D5,D3

load:
                move.w  #10,-(SP)
                move.w  D6,-(SP)
                move.w  D4,-(SP)
                move.w  #1,-(SP)
                clr.w   -(SP)
                clr.l   -(SP)
                pea     (A6)
                move.w  #8,-(SP)
                trap    #14
                lea     20(SP),SP

                addq.w  #1,D4
                lea     5120(A6),A6

                dbra    D5,load

                addq.w  #1,D3
                mulu    #5120/4,D3
                subq.w  #1,D3
xor:            eor.l   D7,(A5)+
                dbra    D3,xor

                lea     mindbomb(PC),A0
                lea     m(PC),A1
                bsr     L003D

                lea     m(PC),A1
                bsr     L005E

                move.l  #nix,$00000070.w
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w

                clr.l   $00000010       ; fÅr main menu, x-coordinate

                move    #$2300,SR

                bra     m

                clr.w   -(SP)
                trap    #1

nix:            rte


; Track infos ...  10 bytes entry
L0026:          PART

                DC.W $001C,$0002,0 ; reset 0
                DC.L $65FDE345

                DC.W $0004,$000A,0 ; intro 1
                DC.L $4F5D6E78

                DC.W $004A,7,0  ; main menu 2
                DC.L $5D6C3E8B

                DC.W $000F,$0009,$0000 ; red sector 3
                DC.L $F67D89E3

                DC.W $0029,$000C,$0000 ; landscape 4
                DC.L $123456AC

                DC.W $0024,$0004,$0000 ; di guest 5
                DC.L $8F2DCBA4

                DC.W $000E,$0006,$0001 ; moving back 6
                DC.L $3787A4EB

                DC.W $0036,$0005,$0000 ; 2layer 7
                DC.L $63FBE2A8

                DC.W $003C,$0008,$0000 ; mega 8
                DC.L $9FBC4DEF

                DC.W $001E,$0003,$0001 ;pd 9
                DC.L $5F8A2CBE

                DC.W $001F,$0004,$0000 ; matrix 10
                DC.L $3FE567DE

                DC.W $004B,$0005,$0001 ; bigsprite 11
                DC.L $26FCD453

                DC.W $0015,$0008,$0001 ; foxx 12
                DC.L $63DCB3E4

                DC.W $0019,$0002,$0000 ; dottie 13
                DC.L $876FD34E

                DC.W $0045,$0004,$0000 ; digi 14
                DC.L $4FC73DA6

                DC.W $0031,$0011,$0001 ; massacre 15   ?
                DC.L $87AD1E27

                DC.W $0022,$0006,1 ; bbc 16            ?
                DC.L $4D8FB3C2

                DC.W $0000,$0005,$0001 ; vector 17       ?
                DC.L $5DF36EDC

                DC.W $0047,$0003,$0001 ; 4th di 18
                DC.B "FUCK"

                DC.W $0006,$0003,$0001 ; ah yeah 19
                DC.L $42EBCDE7

                DC.W $000A,$0003,$0001 ; 3rd di 20
                DC.B 'STEF'

                ENDPART


; Entpacker !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; von A0 nach A1
L003D:          PART
                lea     4(A0),A0
                lea     (A0),A4
                move.l  (A0)+,D5
                adda.l  D5,A1
                adda.l  (A0),A0
                lea     -4(A0),A0
                tst.w   -(A0)
                bpl.s   L003E
                lea     -1(A0),A0
L003E:          move.b  -(A0),D0
L003F:          lsl.b   #1,D0
                bne.s   L0040
                move.b  -(A0),D0
                roxl.b  #1,D0
L0040:          bcc.s   L0048
                clr.w   D1
                lsl.b   #1,D0
                bne.s   L0041
                move.b  -(A0),D0
                roxl.b  #1,D0
L0041:          bcc.s   L0047
                lea     L0046(PC),A3
                moveq   #3,D3
L0042:          clr.w   D1
                move.b  0(A3,D3.w),D2
                ext.w   D2
                moveq   #-1,D4
                lsl.w   D2,D4
                not.w   D4
                subq.w  #1,D2
L0043:          lsl.b   #1,D0
                bne.s   L0044
                move.b  -(A0),D0
                roxl.b  #1,D0
L0044:          roxl.w  #1,D1
                dbra    D2,L0043
                tst.w   D3
                beq.s   L0045
                cmp.w   D1,D4
                dbne    D3,L0042
L0045:          move.b  4(A3,D3.w),D2
                ext.w   D2
                add.w   D2,D1
                bra.s   L0047

L0046:          DC.B $0A,$03,$02,$02,$0E,$07,$04,$01

L0047:          move.b  -(A0),-(A1)
                dbra    D1,L0047

L0048:          movea.l A4,A3
                addq.l  #8,A3
                cmpa.l  A3,A0
                ble     L005D
                lea     L004F(PC),A3
                moveq   #3,D2
L0049:          lsl.b   #1,D0
                bne.s   L004A
                move.b  -(A0),D0
                roxl.b  #1,D0
L004A:          bcc.s   L004B
                dbra    D2,L0049
L004B:          clr.w   D1
                addq.w  #1,D2
                move.b  0(A3,D2.w),D3
                beq.s   L004E
                ext.w   D3
                subq.w  #1,D3
L004C:          lsl.b   #1,D0
                bne.s   L004D
                move.b  -(A0),D0
                roxl.b  #1,D0
L004D:          roxl.w  #1,D1
                dbra    D3,L004C
L004E:          move.b  5(A3,D2.w),D3
                ext.w   D3
                add.w   D3,D1
                bra.s   L0050

L004F:          DC.W $0A02,$0100,$000A,$0604,$0302

L0050:          cmpi.w  #2,D1
                beq.s   L0057
                lea     L0056(PC),A3
                moveq   #1,D3
L0051:          lsl.b   #1,D0
                bne.s   L0052
                move.b  -(A0),D0
                roxl.b  #1,D0
L0052:          bcc.s   L0053
                dbra    D3,L0051
L0053:          addq.w  #1,D3
                clr.w   D2
                move.b  0(A3,D3.w),D4
                ext.w   D4
L0054:          lsl.b   #1,D0
                bne.s   L0055
                move.b  -(A0),D0
                roxl.b  #1,D0
L0055:          roxl.w  #1,D2
                dbra    D4,L0054
                lsl.w   #1,D3
                add.w   4(A3,D3.w),D2
                bra.s   L005B

L0056:          DC.W $0B04,$0700,$0120,$0000,$0020,$0000

L0057:          clr.w   D2
                moveq   #5,D3
                clr.w   D4
                lsl.b   #1,D0
                bne.s   L0058
                move.b  -(A0),D0
                roxl.b  #1,D0
L0058:          bcc.s   L0059
                moveq   #8,D3
                moveq   #$40,D4
L0059:          lsl.b   #1,D0
                bne.s   L005A
                move.b  -(A0),D0
                roxl.b  #1,D0
L005A:          roxl.w  #1,D2
                dbra    D3,L0059
                add.w   D4,D2
L005B:          lea     0(A1,D2.w),A2
                ext.l   D1
                adda.l  D1,A2
                subq.w  #1,D1
L005C:          move.b  -(A2),-(A1)
                dbra    D1,L005C
                bra     L003F
L005D:          rts
                ENDPART

; reloc A1
L005E:          PART
                movea.l A1,A0
                move.l  2(A0),D0
                add.l   6(A0),D0
                add.l   14(A0),D0
                lea     28(A0),A1
                lea     (A1),A2
                moveq   #1,D2
                move.l  A1,D1
                adda.l  D0,A1
                move.l  (A1)+,D0
                adda.l  D0,A2
                add.l   D1,(A2)
                clr.l   D0
L005F:          move.b  (A1)+,D0
                beq.s   L0061
                cmp.b   D2,D0
                beq.s   L0060
                adda.l  D0,A2
                add.l   D1,(A2)
                bra.s   L005F
L0060:          lea     254(A2),A2
                bra.s   L005F
L0061:          rts
                ENDPART

                DATA
info_text:
                DC.B 'Mind Bomb Loader by Ford Porfect'
                DC.B $0D,$0A
                DC.B 'Do not copy this Programm, I wont travel'
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B '0- Reset Demo, 1- Intro, 2- Main Menu'
                DC.B $0D,$0A
                DC.B '3- Red Sector, 4- Landscape, 5- DI 1'
                DC.B $0D,$0A
                DC.B '6- Moving back, 7- 2 layer, 8- Sprite'
                DC.B $0D,$0A
                DC.B '9- PD, 10- DI 2, 11- Spirale Scroller'
                DC.B $0D,$0A
                DC.B '12- Bigsprite, 13- FOXX, 14- Dots'
                DC.B $0D,$0A
                DC.B '15- Digi, 16- Massacre, 17- BBC'
                DC.B $0D,$0A
                DC.B '18- Vector, 19- Ah yeah, 20- DI 3'
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B 'Please put your Original MB Demo in A:'
                DC.B $0D,$0A
                DC.B 'and choose your screen (0-20): ',0

                BSS
puffer:         DS.B 5
screen:         DS.B 1

mindbomb:       DS.B $0100
m:                                      ;DS.L 50000

                END
