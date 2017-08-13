;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
;-------------------------------------------------------------------------------
                RSSET $00000038
music_vbl:      RS.L 1
;-------------------------------------------------------------------------------
TEST            EQU 1
;-------------------------------------------------------------------------------
; EOR-POLY      (w)defjam/checkpoint
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

*   jsr     instr_cycle     ******************* measure instruction time

                bsr     init_sintab

;-------------------------------------------------------------------------------
loop:
                bra.s   no_swap_l
                bsr     swap_screens
no_swap_l:
                bsr     wait_vbl
                clr.w   $FFFF8240.w

                move.w  #1500,D0
wp:
                dbra    D0,wp

                move.w  #$0700,$FFFF8240.w

*  bsr     set_line_simple

*  DC.L $4AFC4E71

*  bsr     draw_faster_v2

                DC.L $4AFC4E71

                bsr     clear_eor_buffer

                bsr     test_object_simple


                clr.w   $FFFF8240.w

                bsr     output_eor_buffer

                move.w  #$0007,$FFFF8240.w


                bsr     inc_w

                move.b  showp(PC),D0
                beq.s   nproc
                move.w  #$0007,$FFFF8240.w
nproc:
                move.b  $FFFFFC02.w,D0
                cmp.b   oldk(PC),D0
                beq.s   samekey
                move.b  D0,oldk
                cmp.b   #$62,D0
                bne.s   n62
                not.b   showp
n62:
samekey:
                cmp.b   #$39,D0
                bne     loop
                DC.L $4AFC4E71
                bra     loop
oldk:           DC.B 0
showp:          DC.B 0

rte:            rte
rts:            rts


x0:             DC.W 0
y0:             DC.W 0          ; 199
x1:             DC.W 319
y1:             DC.W 199        ; 199

set_line_simple:>PART

*   DC.L $4AFC4E71

                lea     eor_buffer,A0

*   movem.w x0(PC),D0-D3

; von links-->rechts
                cmp.w   D0,D2
                beq     lr_dx_zero
                bge.s   lr_ok
                exg     D0,D2
                exg     D1,D3
lr_ok:
                sub.w   D0,D2           ; dx
                sub.w   D1,D3           ; dy
; x pix
                moveq   #15,D6
                and.w   D0,D6
                move.w  #$8000,D4
                lsr.w   D6,D4

                add.w   D1,D1           ; y0
                adda.w  D1,A0

                lsr.w   #4,D0           ; x0/16
                mulu    #200*2,D0       ; x offset
                adda.w  D0,A0

                ext.l   D3              ; dy
                smi     D5              ;
                bpl.s   *+2             ;
                neg.l   D3              ; abs(dy)


                divu    D2,D3           ; /dx
                movea.w D3,A1           ; int
                clr.w   D3
                divu    D2,D3           ; /dx fract
                swap    D3
                move.w  A1,D3           ;     int
                swap    D3              ; int|fract

                tst.b   D5
                bpl.s   dy_is_pos
                neg.l   D3
dy_is_pos:

                move.l  #$00008000,D1   ; 0.5
sls:
                move.l  D1,D5
                swap    D5
                add.w   D5,D5
                or.w    D4,0(A0,D5.w)
                add.l   D3,D1

                ror.w   #1,D4
                bcc.s   sls_nxo

                lea     200*2(A0),A0
sls_nxo:
                dbra    D2,sls

                rts

                ENDPART

set_line_simple2:PART

*    DC.L $4AFC4E71

                lea     eor_buffer,A0

; von links-->rechts
                cmp.w   D0,D2
                beq     lr_dx_zero
                bge.s   lr_ok3
                exg     D0,D2
                exg     D1,D3
lr_ok3:
                sub.w   D0,D2           ; dx
                sub.w   D1,D3           ; dy
; x pix
                moveq   #15,D6
                and.w   D0,D6
                move.w  #$8000,D4
                lsr.w   D6,D4

                add.w   D1,D1           ; y0
                adda.w  D1,A0

                lsr.w   #4,D0           ; x0/16
                mulu    #200*2,D0       ; x offset
                adda.w  D0,A0

                ext.l   D3              ; dy
                smi     D5              ;
                bpl.s   *+2             ;
                neg.l   D3              ; abs(dy)

*   DC.L $4AFC4E71

                move.w  #1,dld
                cmp.w   D2,D3
                ble.s   dx_le_dy
                move.w  #0,dld
dx_le_dy:

                divu    D2,D3           ; /dx
                movea.w D3,A1           ; int
                clr.w   D3
                divu    D2,D3           ; /dx fract
                swap    D3
                move.w  A1,D3           ;     int
                swap    D3              ; int|fract

                tst.b   D5
                bpl.s   dy_is_pos2
                neg.l   D3
dy_is_pos2:

                move.l  #$00008000,D1   ; 0.5


                move.w  dld(PC),D5
                beq.s   no_dld

                subq.w  #1,D2
                bpl.s   *+2
                moveq   #0,D2
                add.l   D3,D1
no_dld:


sls2:
                move.l  D1,D5
                swap    D5
                add.w   D5,D5
                or.w    D4,0(A0,D5.w)
                add.l   D3,D1

                ror.w   #1,D4
                bcc.s   sls_nxo2
                lea     200*2(A0),A0
sls_nxo2:
                dbra    D2,sls2

                rts

                ENDPART

dld:            DC.W 0

lr_dx_zero:     >PART
; x pix
                moveq   #15,D6
                and.w   D0,D6
                move.w  #$8000,D4
                lsr.w   D6,D4

                add.w   D1,D1           ; y0
                add.w   D3,D3           ; y1

                lsr.w   #4,D0           ; x0/16
                mulu    #200*2,D0       ; x offset
                adda.w  D0,A0

                or.w    D4,0(A0,D1.w)
                or.w    D4,0(A0,D3.w)
                rts
                ENDPART

lr_dx_zero_2:
                bra     lr_dx_zero

draw_faster_v2: PART

                bra     set_line_simple2


                lea     eor_buffer,A0

;; movem.w x0(PC),D0-D3

; von links-->rechts
                cmp.w   D0,D2
                beq.s   lr_dx_zero_2
                bge.s   lr_ok2
                exg     D0,D2
                exg     D1,D3
lr_ok2:
                sub.w   D0,D2           ; dx
                sub.w   D1,D3           ; dy
; x pix
                moveq   #15,D6
                and.w   D0,D6

                lsr.w   #4,D0           ; x0/16
                mulu    #200*2,D0       ; x offset
                adda.w  D0,A0

                ext.l   D3              ; dy
                smi     D5              ;
                bpl.s   *+2             ;
                neg.l   D3              ; abs(dy)

                divu    D2,D3           ; /dx
                movea.w D3,A1           ; int
                clr.w   D3
                divu    D2,D3           ; /dx fract
                swap    D3
                move.w  A1,D3           ;     int
                swap    D3              ; int|fract

                tst.b   D5
                bpl.s   dy_is_pos_v2
                neg.l   D3
dy_is_pos_v2:
                swap    D1              ; y0
                move.w  #$8000,D1       ; 0.5
; D2...dx
; D6...x shift start

                add.w   D2,D2           ; dx
                add.w   D6,D6           ; x shift start
                lea     df_v2_code(PC),A1
                lea     (A1),A2

                adda.w  df_v2_code_list(PC,D6.w),A1 ; start = x shift start
                add.w   D6,D2
                adda.w  df_v2_code_list(PC,D2.w),A2 ; end

                move.w  #$4E75,(A2)     ; rts end
                jsr     (A1)
                move.w  #$2A01,(A2)     ; restore

                rts
                ENDPART
df_v2_code_list:>PART
x               SET 0
o               SET 0
                REPT 320+1
                DC.W o
o               SET o+14
x               SET x+1
                IF x=16
o               SET o+4+12      ; lea 200*2(a0),a0
x               SET 0
                ENDC
                ENDR
                ENDPART
df_v2_code:     >PART

pix             SET $8000
x               SET 0
                REPT 320+1
                move.l  D1,D5           ; 2b    2A01
                swap    D5              ; 2b
                add.w   D5,D5           ; 2b
                ori.w   #pix,0(A0,D5.w) ; 6b
                add.l   D3,D1           ; 2b ... 14 bytes

pix             SET pix>>1

x               SET x+1
                IF x=16

                move.l  D1,D5           ; 2b    2A01
                swap    D5              ; 2b
                add.w   D5,D5           ; 2b
                ori.w   #pix,0(A0,D5.w) ; 6b ... 12 bytes

                lea     200*2(A0),A0    ; 4b
pix             SET $8000
x               SET 0
                ENDC
                ENDR

                rts

                ENDPART

test_object_simple:

*  DC.L $4AFC4E71

                bsr     tos_calc

                lea     _3d_result,A0
                move.l  (A0),4*4(A0)

                REPT 4
                pea     2*2(A0)
                movem.w (A0),D0-D3
                bsr     draw_faster_v2
                movea.l (SP)+,A0
                ENDR

                rts

tos_calc:       >PART

                lea     sintab,A0
                adda.w  zr,A0
                move.w  (A0),zr_sin
                move.w  COS(A0),zr_cos

                lea     obj0_simple,A0
                lea     _3d_result,A1

                moveq   #4-1,D6
tosc_l:
                movem.w (A0)+,D0-D2     ; x,y,z

*  bra     sux

                asl.w   #2,D0
                asl.w   #2,D1

                move.w  D0,D3           ; x
                move.w  D1,D4           ; y

                muls    zr_cos(PC),D0   ; x*cos
                muls    zr_sin(PC),D4   ; y*sin
                add.l   D4,D0

                muls    zr_cos(PC),D1   ; y*cos
                muls    zr_sin(PC),D3   ; x*sin
                sub.l   D3,D1

                swap    D0
                swap    D1

sux:
                add.w   #320/2,D0
                add.w   #200/2,D1

                move.w  D0,(A1)+
                move.w  D1,(A1)+

                dbra    D6,tosc_l
                rts
                ENDPART

zr_sin:         DC.W 0
zr_cos:         DC.W 0

obj0_simple:    >PART
M               SET 50
MZ              SET 0
                DC.W -M,-M,MZ
                DC.W -M,M,MZ
                DC.W M,M,MZ
                DC.W M,-M,MZ
                ENDPART

;-------------------------------------------------------------------------------
inc_w:          >PART
                moveq   #7-1,D0
                lea     xr(PC),A0
                lea     xr_inc(PC),A1
iwl:
                move.w  (A0),D1
                add.w   (A1)+,D1
                and.w   #SIN_MASK,D1
                move.w  D1,(A0)+
                dbra    D0,iwl
                rts
                ENDPART
                >PART 'angles'
xr:             DC.W 0
yr:             DC.W 0
zr:             DC.W 0
w0:             DC.W 0
w1:             DC.W 0
w2:             DC.W 0
w3:             DC.W 0

w0_inc:         DC.W 11*2
w1_inc:         DC.W 13*2
w2_inc:         DC.W -14*2
w3_inc:         DC.W -7*2
xr_inc:         DC.W 0
yr_inc:         DC.W 0
zr_inc:         DC.W 16*2

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

*   bset    D0,0(A0)        ; 4
*   ori.w   #1234,0(A0)     ; 5

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

output_eor_buffer:>PART

                lea     eor_buffer,A0
                movea.l screen1,A1

                move.w  #320/16-1,-(SP)
oeb_x:
                movem.w (A0)+,D0-D6
o               SET 0
                move.w  D0,(A1)         ; 1
o               SET o+160
                eor.w   D1,D0
                move.w  D0,o(A1)        ; 2
o               SET o+160
                eor.w   D2,D0
                move.w  D0,o(A1)        ; 3
o               SET o+160
                eor.w   D3,D0
                move.w  D0,o(A1)        ; 4
o               SET o+160
                eor.w   D4,D0
                move.w  D0,o(A1)        ; 5
o               SET o+160
                eor.w   D5,D0
                move.w  D0,o(A1)        ; 6
o               SET o+160
                eor.w   D6,D0
                move.w  D0,o(A1)        ; 7
o               SET o+160

; 200-7 = 193
;-----------------------
; 193/6 = 32  rest: 1
                REPT 32

                movem.w (A0)+,D1-D6
                eor.w   D1,D0
                move.w  D0,o(A1)        ; 1
o               SET o+160
                eor.w   D2,D0
                move.w  D0,o(A1)        ; 2
o               SET o+160
                eor.w   D3,D0
                move.w  D0,o(A1)        ; 3
o               SET o+160
                eor.w   D4,D0
                move.w  D0,o(A1)        ; 4
o               SET o+160
                eor.w   D5,D0
                move.w  D0,o(A1)        ; 5
o               SET o+160
                eor.w   D6,D0
                move.w  D0,o(A1)        ; 6
o               SET o+160
                ENDR

                move.w  (A0)+,D1
                eor.w   D1,D0
                move.w  D0,o(A1)        ; 1

                addq.l  #8,A1           ; screen_x++

                subq.w  #1,(SP)
                bpl     oeb_x
                addq.l  #2,SP
                rts

                ENDPART

clear_eor_buffer:PART

                lea     eor_buffer+200*20*2,A3

                movem.l zero(PC),D0-D6/A0-A2 ;10*4 = 40
; 200*20*2 = 8000
; 8000/40  = 200
                REPT 200
                movem.l D0-D6/A0-A2,-(A3)
                ENDR
                rts

                ENDPART

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

black:
zero:           DS.L 16
;-------------------------------------------------------------------------------
                BSS

_3d_result:     DS.W 4096


                DS.B 512
stack:          DS.B 2

sintab:         DS.W 2*2048

eor_buffer:     DS.W 200*20

                DS.B 256
screen_ram:
                DS.B 32000
                DS.B 32000

                END
