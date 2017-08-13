;-------------------------------------------------------------------------------
TEST            EQU 1
;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
;-------------------------------------------------------------------------------
;
; Thunderdome - Big logo test
;
;
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
XW              EQU 752
YW              EQU 132
;-------------------------------------------------------------------------------


                OPT D+

                >PART ' init '

                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                move    #$2700,SR
                lea     stack,SP
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w  ; auto eoi

                move.l  #vbl,$00000070.w
                move    #$2300,SR
                bsr     wait_vbl

                move.l  #screen_ram,D0
                clr.b   D0
                lea     screen0(PC),A0
                move.l  D0,(A0)+
                add.l   #32000,D0
                move.l  D0,(A0)+
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                bsr     wait_vbl
                clr.b   $FFFF8260.w

                ENDPART

                lea     td_big,A0
                movem.l (A0),D0-D6/A0
                movem.l D0-D6/A0,$FFFF8240.w

*  jsr     instr_cycle     ******************* measure instruction time

*    bsr     init_sintab

*    bsr     copy_test

                bsr     wait_vbl


                bsr     preshift_gfx


;-------------------------------------------------------------------------------
loop:
                bra.s   no_swap_l
                bsr     swap_screens
no_swap_l:
                bsr     wait_vbl
                clr.w   $FFFF8240.w


                bsr     output_x_test

                move.w  #2000,D0
wp:
                dbra    D0,wp

                move.w  #$0700,$FFFF8240.w

*      bsr     test_insert_code

                move.w  #$0000,$FFFF8240.w


                bsr     inc_w

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne     loop
                DC.L $4AFC4E71
                bra     loop
rte:            rte
rts:            rts

;-------------------------------------------------------------------------------
inc_w:          >PART
                moveq   #4-1,D0
                lea     w0(PC),A0
                lea     w0_inc(PC),A1
iwl:
                move.w  (A0),D1
                add.w   (A1)+,D1
                and.w   #SIN_MASK,D1
                move.w  D1,(A0)+
                dbra    D0,iwl
                rts
                ENDPART
                >PART 'angles'
w0:             DC.W 0
w1:             DC.W 0
w2:             DC.W 0
w3:             DC.W 0
w0_inc:         DC.W 11*2
w1_inc:         DC.W 13*2
w2_inc:         DC.W -14*2
w3_inc:         DC.W -7*2
                ENDPART
;-------------------------------------------------------------------------------
swap_screens:   >PART
                move.l  screen1(PC),D0
                move.l  screen0(PC),screen1
                move.l  D0,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts

screen0:        DC.L 0
screen1:        DC.L 0

                ENDPART
vbl:            >PART
                addq.l  #1,$00000466.w
                rte
                ENDPART
wait_vbl:       >PART
                clr.l   $00000466.w
wv:
                tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------
init_sintab:    >PART           ;; 36 bytes!   (and the quality fit's !!)

;
; 36bytes Sine-generator   MC68000!!  (no 030 muls.l!) (w)`99 defjam/checkpoint!
;   * BUT a bit erroranous
;   * this version a bit corrected !?

size            SET 2048

;; Erweiterungsfaktor ist 65536*16384

sin_inc         SET 3294198     ;GENAU: 3294198     ;; 2*PI / size
cos_inc         SET -20212      ;   10106*2     ;; ((2*PI)^2) / (size^2)


                lea     sintab,A0
                moveq   #0,D0           ;oe

                move.l  #1*sin_inc,D3
                move.w  #2048-1,D6
init_sin_:
                move.l  D0,D4
                swap    D4

                move.w  D4,1*2048*2(A0)
                move.w  D4,(A0)+

                muls    #cos_inc,D4

                add.l   D4,D4
                swap    D4
                ext.l   D4

                add.l   D4,D3           ;sin_inc - erg1
                add.l   D3,D0           ;oe + sin_inc

                dbra    D6,init_sin_
                rts

                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                IFNE TEST
instr_cycle:    >PART
                move.l  #svbl,$00000070.w
                move    #$2300,SR
sloop:
                lea     stack,SP
                move    #$2300,SR
                clr.b   $FFFF8201.w
                clr.b   $FFFF8203.w

                bsr     wait_vbl_cc
                move    #$2700,SR

                moveq   #0,D0
                moveq   #0,D1

                movea.l screen1,A0

                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                lea     (A0),A4
                lea     (A0),A5
                lea     (A0),A6

                lea     $FFFF8800.w,A6

                lea     es(PC),A2

                move.w  #$0123,D0
                move.w  #$0023,D1

;get synced
                move.l  D0,resd0+2
sts:            move.b  $FFFF8209.w,D0
                beq.s   sts
                not.w   D0
                lsl.w   D0,D0

;sync to $0 - $A0 Position!
w:              move.b  $FFFF8209.w,D0
                bne.s   w

resd0:          move.l  #$00000000,D0
                DS.W 40,$00004E71

uzi:
;Sync_Pos should be Zero now!!   (1 nop before --> Sync_pos=2 !)
                move.b  $FFFF8209.w,_1st+3 ;3
;--------------------------------------------------------------------
your_code_here:

                mulu    D1,D0           ; 11

es:
;--------------------------------------------------------------------
                move.b  $FFFF8209.w,_2nd+3 ;3            move.b (a3),d4 [2]
;Maximum_Count_Cycles = (160 - 6)/2 = 77 Nops!

_2nd:           move.b  #0,D0
_1st:           sub.b   #0,D0
                sub.b   #12,D0
                lsr.b   #1,D0           ;/2 = nop's
                and.l   #$000000FF,D0

                lea     stack,SP
                DC.L $4AFC4E71

                move.w  #$0700,$FFFF8240.w
                move.w  #$0000,$FFFF8240.w
                jmp     sloop

svbl:           addq.l  #1,$00000466.w
                rte
wait_vbl_cc:
                clr.l   $00000466.w
wv_cc:          tst.l   $00000466.w
                beq.s   wv_cc
                rts

                ENDPART
                ENDC
;-------------------------------------------------------------------------------



;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
preshift_gfx:   >PART

*     DC.L $4AFC4E71

                lea     td_big+32,A0    ;      SRC
                lea     td_big_preshifted,A1 ; DEST

                lea     preshift_list+4,A2

                moveq   #4,D5           ; bits to shift

                move.w  #3-1,-(SP)
pg_shifts:

*   DC.L $4AFC4E71
*   bsr     output_gfx_test

                move.l  A1,(A2)         ; list

                move.w  #YW-1,D6
pg_y:
                movem.w (A0),D0-D3
                lsr.w   D5,D0
                lsr.w   D5,D1
                lsr.w   D5,D2
                lsr.w   D5,D3
                movem.w D0-D3,(A1)

o               SET 8
                REPT (XW/16)-1-1
                movem.w (A0)+,D0-D3
                swap    D0
                swap    D1
                swap    D2
                swap    D3
                lea     (A0),A3
                move.w  (A3)+,D0
                move.w  (A3)+,D1
                move.w  (A3)+,D2
                move.w  (A3)+,D3
                lsr.l   D5,D0
                lsr.l   D5,D1
                lsr.l   D5,D2
                lsr.l   D5,D3
                movem.w D0-D3,o(A1)
o               SET o+8
                ENDR

                lea     16(A0),A0
                lea     o+8(A1),A1
                dbra    D6,pg_y

                movea.l (A2)+,A0        ; new source

                subq.w  #1,(SP)
                bpl     pg_shifts
                addq.l  #2,SP

; make copy of the shift addresses
                lea     preshift_list,A2
                movem.l (A2)+,D0-D3
                movem.l D0-D3,(A2)

                rts
                ENDPART

preshift_list:
                DC.L td_big+32
                DC.L 0
                DC.L 0
                DC.L 0
                DS.L 4          ; copy of the 4 shift pointers
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------



copy_test:
                DC.L $4AFC4E71

                lea     td_big+32,A0
                bsr     output_gfx_test
                rts


x:              DC.W 0

output_x_test:  >PART

                move.w  x,D0

                moveq   #3,D1
                and.w   D0,D1
                add.w   D0,D0

                tst.w   D1
                beq.s   x_zero
                add.w   #8,D0
                neg.w   D1
                and.w   #3,D1
x_zero:

                lsl.w   #2,D1
                lea     preshift_list,A0
                movea.l 0(A0,D1.w),A0

                and.w   #-8,D0
                adda.w  D0,A0

                bsr     output_gfx_test

                addq.w  #1,x

                rts
                ENDPART

output_gfx_test:>PART
                movem.l D6/A0-A1,-(SP)
                movea.l screen1,A1
                move.w  #YW-1,D6
cty:
                pea     XW/2(A0)
                REPT 160/4
                move.l  (A0)+,(A1)+
                ENDR
                movea.l (SP)+,A0
                dbra    D6,cty
                movem.l (SP)+,D6/A0-A1
                rts
                ENDPART

test_insert_code:>PART

                moveq   #4-1,D6
tic:
                lea     screen_ram,A0
                lea     screen_ram,A1
                movea.w #0,A2
                movea.w #0,A3
o               SET 0
o2              SET 0
                REPT YW
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                adda.w  A2,A0
                adda.w  A3,A1
                ENDR

                dbra    D6,tic

                rts
                ENDPART

                DATA

td_big:
                PATH 'C:\0NEW\TDOME\TD_BIG\'
                PATH 'PC\'
                IBYTES 'TD_BIG.GFX'
tdbe:
;-------------------------------------------------------------------------------
                BSS
                DS.B 512
stack:          DS.B 2

sintab:         DS.W 2*2048

                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000
                DS.B 32000
                DS.B 32000
                DS.B 32000

td_big_preshifted:
                DS.B 3*YW*XW/2
pe:
                END
