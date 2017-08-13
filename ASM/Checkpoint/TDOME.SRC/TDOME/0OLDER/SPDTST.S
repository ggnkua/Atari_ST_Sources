;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
;-------------------------------------------------------------------------------
                RSSET $00000038
music_vbl:      RS.L 1
;-------------------------------------------------------------------------------
TEST            EQU 1
;-------------------------------------------------------------------------------
; Paula emulation speedtest
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
FREQ            EQU 15650
_32BLK          EQU (FREQ/50/32)+1
_64BLK          EQU (FREQ/50/64)+1
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

                move.l  #rts,music_vbl.w

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

                movem.l colors,D0-D7
                movem.l D0-D7,$FFFF8240.w

*  jsr     instr_cycle     ******************* measure instruction time

*   bsr     init_sintab

;-------------------------------------------------------------------------------
loop:
                bsr     wait_vbl
                clr.w   $FFFF8240.w

                bsr     render_32

                move.w  #$0007,$FFFF8240.w

                move.b  $FFFFFC02.w,D0
                cmp.b   #$39,D0
                bne     loop
                DC.L $4AFC4E71
                bra     loop
oldk:           DC.B 0
showp:          DC.B 0

rte:            rte
rts:            rts

; A0,A1,A2,USP samples
; D0,D1,D2,D3  volume tables
;
; D4.w digit out
;
; A3 ... output pointer

render_64:      >PART

                bsr     calc_steps_64_inner

                bsr     get_paula_regs  ; ***

                move    A3,USP          ; channel 3

                movea.l screen1,A3      ; *** output pointer ***

                move.l  SP,old_sp_render
                move    #$2700,SR

                moveq   #_64BLK-1,D6
r64l:
                REPT 64
                move.b  0(A0),D0        ; channel 0
                movea.l D0,SP
                move.w  (SP),D4

                move.b  0(A1),D1        ; channel 1
                movea.l D1,SP
                add.w   (SP),D4

                move.b  0(A2),D2        ; channel 2
                movea.l D2,SP
                add.w   (SP),D4

                move    USP,SP          ; channel 3 sample
                move.b  0(SP),D3        ; channel 3
                movea.l D3,SP
                add.w   (SP),D4

                move.w  D4,(A3)+        ; OUPUT DIGIT

                ENDR


; hier muss noch das 64er step increment rein


                dbra    D6,r64l
;----------------------------------------------------------------
                movea.l old_sp_render(PC),SP
                move    #$2300,SR

                rts

                ENDPART
calc_steps_64_inner:>PART

                bsr     cs64i           ; channel 0
                bsr     cs64i           ; channel 1
                bsr     cs64i           ; channel 2
                bsr     cs64i           ; channel 3
                rts
cs64i:
                movea.l screen0,A0
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3

                REPT 64
                move.w  D3,0(A0)
                add.w   D0,D1
                addx.w  D2,D3
                ENDR

                rts

                ENDPART

render_32:      >PART

                bsr     calc_steps_32_inner

                bsr     get_paula_regs  ; ***

                move    A3,USP          ; channel 3

                movea.l screen1,A3      ; *** output pointer ***

                move.l  SP,old_sp_render
                move    #$2700,SR

                moveq   #_32BLK-1,D6
r32l:
                REPT 32
                move.b  0(A0),D0        ; channel 0
                movea.l D0,SP
                move.w  (SP),D4

                move.b  0(A1),D1        ; channel 1
                movea.l D1,SP
                add.w   (SP),D4

                move.b  0(A2),D2        ; channel 2
                movea.l D2,SP
                add.w   (SP),D4

                move    USP,SP          ; channel 3 sample
                move.b  0(SP),D3        ; channel 3
                movea.l D3,SP
                add.w   (SP),D4

                move.w  D4,(A3)+        ; OUPUT DIGIT

                ENDR


; hier muss noch das 32er step increment rein


                dbra    D6,r32l
;----------------------------------------------------------------
                movea.l old_sp_render(PC),SP
                move    #$2300,SR

                rts

                ENDPART
calc_steps_32_inner:>PART

                bsr     cs32i           ; channel 0
                bsr     cs32i           ; channel 1
                bsr     cs32i           ; channel 2
                bsr     cs32i           ; channel 3
                rts
cs32i:
                movea.l screen0,A0
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3

                REPT 32
                move.w  D3,0(A0)
                add.w   D0,D1
                addx.w  D2,D3
                ENDR

                rts

                ENDPART


old_sp_render:  DC.L 0


get_paula_regs:
                movea.l screen0,A0
                movea.l screen0,A1
                movea.l screen0,A2
                movea.l screen0,A3
                move.l  screen0,D0
                move.l  screen0,D1
                move.l  screen0,D2
                move.l  screen0,D3
                rts

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

                movem.l D0-A6,-(SP)

                movea.l music_vbl.w,A0
                jsr     (A0)

                movem.l (SP)+,D0-A6

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
                move.w  #2048-1,D7
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
                dbra    D7,init_sin_
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

                DATA

c0              SET $0777
c1              SET $0700
c2              SET $0070
c3              SET $0007
colors:         >PART
                DC.W $0000      ;            0 ;

                DC.W c0         ;    0       1 ;

                DC.W c1         ;   1        2 ;
                DC.W c1         ;   10       3 ;

                DC.W c2         ;  2         4 ;
                DC.W c2         ;  2 0       5 ;
                DC.W c2         ;  21        6 ;
                DC.W c2         ;  210       7 ;

                DC.W c3         ; 3          8 ;
                DC.W c3         ; 3  0       0 ;
                DC.W c3         ; 3 1       10 ;
                DC.W c3         ; 3 10      11 ;
                DC.W c3         ; 32        12 ;
                DC.W c3         ; 32 0      13 ;
                DC.W c3         ; 321       14 ;
                DC.W c3         ; 3210      15 ;

                ENDPART
;-------------------------------------------------------------------------------
                BSS
                DS.B 512
stack:          DS.B 2

sintab:         DS.W 2*2048

                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000

                END
