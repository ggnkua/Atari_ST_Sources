;-------------------------------------------------------------------------------
TEST            SET 1
;-------------------------------------------------------------------------------
                OUTPUT 'FULLTEST.PRG'
;-------------------------------------------------------------------------------
;
; 15650 Hz Protracker Overscan, 10 colors rastersplit/line
;
; (w)2014 defjam&lsl/checkpoint
;
; **TODO: Protracker stuff!**
;
;
; HBL-issue fixed??
;
;
;-------------------------------------------------------------------------------
music_vbl       EQU $00000038
;-------------------------------------------------------------------------------
__start__:
                OPT D-
                IFNE TEST
                OPT D+
                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1
                addq.l  #6,SP
                ENDC

                move.l  $00000068.w,-(SP)
                move.l  $00000070.w,-(SP)
                move.l  SP,old_sp
                bra.s   __crt0__
__END__:
                move    #$2700,SR
                movea.l old_sp(PC),SP
                move.l  (SP)+,$00000070.w
                move.l  (SP)+,$00000068.w
                bset    #5,$FFFFFA13.w  ; enable timer a
                move    #$2300,SR
                rts
old_sp:         DC.L 0
__crt0__:
;-------------------------------------------------------------------------------
                IFNE TEST
                >PART ' init machine '
                move    #$2700,SR
                lea     stack,SP
                clr.b   $FFFFFA07.w
                clr.b   $FFFFFA09.w
                clr.b   $FFFFFA13.w
                clr.b   $FFFFFA15.w
                bclr    #3,$FFFFFA17.w  ; auto eoi
                move.l  #count_vbl,$00000070.w
                move    #$2300,SR

                bsr     wait_vbl
                clr.b   $FFFF8260.w
                ENDPART
                lea     $00000034.w,A0
                move.l  #$4E754E73,(A0) ; rts rte
                move.l  A0,music_vbl.w
                move.b  #15,$FFFF8800.w
                ENDC
;-------------------------------------------------------------------------------
                >PART
                move.l  #count_vbl,$00000070.w
                bsr     wait_vbl

                move.l  #scr_ram,D0
                clr.b   D0
                move.l  D0,screen0
                add.l   #$0000F000,D0
                move.l  D0,screen1
                movea.l D0,A0
                lea     160(A0),A0
                move.l  A0,draw_screen
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
;-------------------------------------------------------------------------------
                lea     sscr,A0
                lea     escr,A1
                jsr     memclr

                ENDPART

*    jsr     instr_cycle     ******************************

*    jsr     copy_gfx_big

*  jsr     copy_gfx_test

                jsr     copy_pi1_test


;; moveq   #4,D0
;; jsr     shift_gfx

;;  lea     black,A0
                lea     pi1+2,A0
                move.l  A0,top_colors+4

;-------------------------------------------------------------------------------
                bsr     wait_vbl

                move.l  #vbl_fullscreen_mod,$00000070.w
;-------------------------------------------------------------------------------
loop:
                lea     digit_buffer_test,A6 ; **TEST**

                bsr     wait_vbl

                move.b  $FFFFFC02.w,D0
                move.b  D0,key

** bsr     check_input

                cmp.b   #$62,D0
                bne.s   n62
                move.w  #$0007,$FFFF8240.w
n62:
                cmp.b   #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                bra.s   loop

key:            DC.B 0
oldk:           DC.B 0

check_input:    >PART

                movem.l D0/A0,-(SP)

                moveq   #0,D0
                move.b  key(PC),D0

                lea     hbl_start_lines(PC),A0

                cmp.b   oldk(PC),D0
                beq.s   samek
                move.b  D0,oldk

                cmp.b   #$3B,D0
                bne.s   nf1
                subq.w  #1,(A0)
                bpl.s   *+2
                clr.w   (A0)
nf1:
                cmp.b   #$3C,D0
                bne.s   nf2
                addq.w  #1,(A0)
nf2:
samek:
                movem.l (SP)+,D0/A0
                rts
                ENDPART
;-------------------------------------------------------------------------------
e:
                IFNE TEST
                >PART
                move    #$2700,SR
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                move.w  #$0700,$FFFF8240.w
                move.l  #rte,$00000068.w
                move.l  #rte,$00000070.w
                lea     stack,SP
                move.w  #$0070,$FFFF8240.w
                DC.L $4AFC4E71
                ENDPART
                ENDC
;-------------------------------------------------------------------------------
wait_vbl:       >PART
                clr.l   $00000466.w
wv:             tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------
draw_screen:    DC.L 0
screen0:        DC.L 0
screen1:        DC.L 0
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;--------------------------------------------------------
                RSSET $00000140
HBL_LINE_COUNTER:RS.W 1
ColorsPtr:      RS.L 1
;--------------------------------------------------------
hbl_start_lines:DC.W 32-2       ; 32 without hbl_fix
;--------------------------------------------------------
vbl_fullscreen_mod:>PART

;***************************************************************************
;***************************************************************************
hbl_fix:
                move    #$2100,SR       ;without this, (hbl after overscan)
                stop    #$2100          ;double hbl-lines.  strange.
                move    #$2700,SR
;***************************************************************************
;***************************************************************************

                move.w  hbl_start_lines(PC),HBL_LINE_COUNTER.w

                move.l  #hbl_start,$00000068.w

                move.l  #colors_list,ColorsPtr.w

                move    #$2100,SR       ; enable hbl

;-----------------------------------------------------
                movem.l D0-D6/A0-A3,-(SP)
; vbl code here...
                movem.l (SP)+,D0-D6/A0-A3
;-----------------------------------------------------

                move.b  #$21,(SP)       ; hbl on
count_vbl:
                addq.l  #1,$00000466.w
rte:            rte
                ENDPART
hbl_start:      >PART
;---------------------------------------------------
; D7,A6
                move    A4,USP          ;   1
                movea.w (A6)+,A4        ;   2 sample
                move.l  (A4)+,D7        ;   3
                move.l  (A4)+,$FFFF8800.w ; 7
                lea     $FFFF8800.w,A4  ;   2
                movep.l D7,0(A4)        ;   7
                move    USP,A4          ;   1
;---------------------------------------------------
                subq.w  #1,HBL_LINE_COUNTER.w
                bmi.s   hbl_is_da
hbl_rte_:       rte
;------------------------------------------------------------
hbl_is_da:
                move.l  #open_top_2_,$00000068.w
                move.l  SP,hbl_reload_SP+2
waithere:       stop    #$2100
                bra.s   waithere
;------------------------------------------------------------
open_top_2_:
                move    #$2700,SR
hbl_reload_SP:  lea     0,SP            ; Stack korrigieren

                movem.l D0-A5,-(SP)     ; SAVE REGISTERS

top_colors:     movem.l 0,D0-D5/A0-A1   ;         21
                movem.l D0-D5/A0-A1,$FFFF8240.w ; 19

                DS.W 89-14-21-19-16,$00004E71
; open top
                move.b  #0,$FFFF820A.w  ; 60 Hz
                DS.W 11,$00004E71
                move.b  #2,$FFFF820A.w  ; 50 Hz

                lea     $FFFF8209.w,A0  ;   2
                moveq   #0,D0           ;   1
wait_syncA:
                move.b  (A0),D0
                cmp.w   #$0040,D0       ;  $40 + $A0  = $E0
                blt.s   wait_syncA
                sub.w   #$0040,D0
                not.w   D0
                lsr.w   D0,D0

o               SET 0

                movea.l ColorsPtr.w,A4  ;4
                lea     $FFFF8240.w,A5  ;2
o               SET o+4+2

                move.l  (A4)+,(A5)+     ;5   2 farben...2
                move.l  (A4)+,(A5)+     ;5   2 farben...4
                move.l  (A4)+,(A5)+     ;5   2 farben...6
o               SET o+3*5

                move.l  SP,reload_stack+2 ;    5
                lea     $FFFF820A.w,SP  ;      2
                move.w  #$0100,D6       ;      2
o               SET o+5+2+2

                DS.W 37-o-3,$00004E71

border_einsprungA:jmp   border_code_oriA ; 3

border_code_oriA:
                REPT 227

                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Links auf)

                move.l  (A4)+,(A5)+     ;5   2 farben...8
                move.l  (A4)+,(A5)+     ;5   2 farben...10
                move.l  A4,ColorsPtr.w  ;4

                DS.W 89-5-5-4,$00004E71 ; <-- *** PAULA GOES HERE ***

                move.b  D6,(SP)         ;2   60Hz
                move.w  SP,(SP)         ;2   50Hz (Rechts auf)

                DS.W 12-4-2-5,$00004E71

                movea.l ColorsPtr.w,A4  ;4
                lea     $FFFF8240.w,A5  ;2
                move.l  (A4)+,(A5)+     ;5   2 farben...2

                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Rechts zu)

                move.l  (A4)+,(A5)+     ;5   2 farben...4
                move.l  (A4)+,(A5)+     ;5   2 farben...6

                DS.W 11-5-5,$00004E71
                ENDR
;-------------------------------------------------------------------
; open bottom border
* jmp     border_code_doneA

                move.w  SP,$0056(SP)    ;2   Highres
                move.b  D6,$0056(SP)    ;2   Lowres (Links auf)

                DS.W 89,$00004E71

                move.b  D6,(SP)         ;2   60Hz
                move.w  SP,(SP)         ;2   50Hz (Rechts auf)

                DS.W 12,$00004E71

                move.w  SP,$0056(SP)    ;2   Highres
                move.b  D6,$0056(SP)    ;2   Lowres (Rechts zu)

;Unten ™ffnen
                move.b  D6,(SP)         ;2   60Hz
                DS.W 9,$00004E71
;---------------------------------------------
                move.w  SP,$0056(SP)    ;2   Highres
                move.b  D6,$0056(SP)    ;2   Lowres (Links auf)

                move.w  SP,(SP)         ;2   50Hz

                DS.W 87,$00004E71

                move.b  D6,(SP)         ;2   60Hz
                move.w  SP,(SP)         ;2   50Hz (Rechts auf)

                DS.W 12,$00004E71

                move.w  SP,$0056(SP)    ;2   Highres
                move.b  D6,$0056(SP)    ;2   Lowres (Rechts zu)

                DS.W 11,$00004E71
;------------------------------------------------------
; open left/right bottom

                REPT 37

                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Links auf)

                DS.W 89,$00004E71

                move.b  D6,(SP)         ;2   60Hz
                move.w  SP,(SP)         ;2   50Hz (Rechts auf)

                DS.W 12,$00004E71

                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Rechts zu)

                DS.W 11,$00004E71

                ENDR

* jmp     border_code_doneA

                ENDPART
border_code_doneA:>PART

                lea     $FFFF8240.w,A0
                moveq   #0,D0
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)+
                move.l  D0,(A0)+

reload_stack:   lea     0,SP

                move.l  #hbl_end,$00000068.w
                move    #$2100,SR

;------------------------------------------------
; Protracker replay goes here
;------------------------------------------------

                movem.l (SP)+,D0-A5

                move.b  #$21,(SP)       ; hbl on
                rte
                ENDPART
hbl_end:        >PART
                move    A4,USP          ;   1
                movea.w (A6)+,A4        ;   2 sample
                move.l  (A4)+,D7        ;   3
                move.l  (A4)+,$FFFF8800.w ; 7
                lea     $FFFF8800.w,A4  ;   2
                movep.l D7,0(A4)        ;   7
                move    USP,A4          ;   1
                rte
                ENDPART
;-------------------------------------------------------------------------------
sample_FAST:    >PART           ; D7,A4,A5,A6

                movea.w (A6)+,A4        ; 2  digit
                move.l  (A4)+,D7        ; 3
                movep.l D7,0(A5)        ; 7
                move.l  (A4)+,(A5)      ; 6

                rte

                ENDPART
sample_SLOW:    >PART           ; D7,A6

                move    A4,USP          ;   1
                movea.w (A6)+,A4        ;   2 sample
                move.l  (A4)+,D7        ;   3
                move.l  (A4)+,$FFFF8800.w ; 7
                lea     $FFFF8800.w,A4  ;   2
                movep.l D7,0(A4)        ;   7
                move    USP,A4          ;   1

                rte

                ENDPART
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
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

                jsr     wait_vbl
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

                lea     $FFFF8240.w,A1  ; 2

;get synced
sts:            move.b  $FFFF8209.w,D0
                beq.s   sts
                not.w   D0
                lsl.l   D0,D0

;sync to $0 - $A0 Position!
w:              move.b  $FFFF8209.w,D0
                bne.s   w
*   DS.W 40,$00004E71
uzi:
***          DS.W 128+9,$00004E71
;Sync_Pos should be Zero now!!   (1 nop before --> Sync_pos=2 !)
                move.b  $FFFF8209.w,_1st+3 ;3

*    move.l  (A0)+,(A1)+     ; 5

                movea.l ColorsPtr.w,A4  ; 4
                move.l  A4,ColorsPtr.w  ; 4

es:
                move.b  $FFFF8209.w,_2nd+3 ;3            move.b (a3),d4 [2]

;Maximum_Count_Cycles = (160 - 6)/2 = 77 Nops!

_2nd:           move.b  #0,D0
_1st:           sub.b   #0,D0
                sub.b   #12,D0
                lsr.b   #1,D0           ;/2 = nop's

                lea     stack,SP
                illegal
                nop

                move.w  #$0700,$FFFF8240.w
                move.w  #$0000,$FFFF8240.w
                bra     sloop
svbl:           addq.l  #1,$00000466.w
                rte

                ENDPART
                ENDC
;-------------------------------------------------------------------------------
; A0-->A1
memclr:         >PART

                move.l  A1,D0
                sub.l   A0,D0           ; block length

                movem.l zero,D1-A0/A2-A6 ; 13*4 = 52

                divu    #4*(13*4),D0
                bra.s   mc0_C
mc0C:
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
                movem.l D1-A0/A2-A6,-(A1)
mc0_C:          dbra    D0,mc0C

                clr.w   D0
                swap    D0
                divu    #4,D0
                bra.s   mc1_C
mc1C:
                move.l  D1,-(A1)
mc1_C:          dbra    D0,mc1C

                swap    D0
                bra.s   mc2_C
mc2C:           move.b  D1,-(A1)
mc2_C:          dbra    D0,mc2C
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; D0...shift
shift_gfx:      >PART
;   DC.L $4AFC4E71

                movea.l screen1,A0
                lea     160(A0),A0
                move.w  #266-1,D7
sg_y:
                pea     230(A0)

                bsr.s   sg_shift
                addq.l  #2,A0
                bsr.s   sg_shift
                addq.l  #2,A0
                bsr.s   sg_shift
                addq.l  #2,A0
                bsr.s   sg_shift

                movea.l (SP)+,A0
                dbra    D7,sg_y
                rts

sg_shift:
                lea     (A0),A1

                moveq   #0,D2

                moveq   #(384+32)/16-1,D6
sg_x:
                swap    D2              ; previous 16pix
                move.w  (A1),D2         ; current 16pix
                move.w  D2,D3           ; save current

                lsr.l   D0,D2           ; shift
                move.w  D2,(A1)         ;writeback

                move.w  D3,D2           ; previous=current

                addq.l  #8,A1
                dbra    D6,sg_x
                rts
                ENDPART
;-------------------------------------------------------------------------------
copy_gfx_test:  >PART

*   DC.L $4AFC4E71

                movea.l screen1,A1
                lea     8+160(A1),A1

                movem.l gfxpatt_a(PC),D0-D1

                move.w  #266-1,D7
cgb_y2:
                movem.l D0-D1,(A1)

                movem.l D0-D1,384/2(A1)

                lea     230(A1),A1

                dbra    D7,cgb_y2
                rts

gfxpatt_a:
                DC.W -1         ; p0
                DC.W -1         ; p1
                DC.W -1         ; p2
                DC.W 0          ; p3

                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
copy_pi1_test:  >PART

*   DC.L $4AFC4E71

                lea     pi1+34,A0
                movea.l screen1,A1
                lea     8+160(A1),A1
                move.w  #200,D6
                bsr     do_pi1_lines

                lea     pi1+34,A0
                movea.l screen1,A1
                lea     8+160(A1),A1
                adda.l  #200*230,A1
                move.w  #70,D6
                bsr     do_pi1_lines

                bsr     init_colorlist_pi1

                rts
                ENDPART
do_pi1_lines:   >PART
                movem.l D6/A0-A1,-(SP)
                subq.w  #1,D6
dpi1l:
                movem.l A0-A1,-(SP)

                moveq   #160/8-1,D5
dpi1l_x0:
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D5,dpi1l_x0
;--------------------------------------
                movem.l (SP),A0-A1
                lea     160(A1),A1
                moveq   #40/8-1,D5
dpi1l_x1:
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D5,dpi1l_x1
;--------------------------------------
                movem.l (SP)+,A0-A1
                lea     160(A0),A0
                lea     230(A1),A1
                dbra    D6,dpi1l

                movem.l (SP)+,D6/A0-A1
                rts

                ENDPART
;------------------------------------------
init_colorlist_pi1:>PART
; 10 colors
                lea     pi1+2,A0
                lea     colors_list,A1

                movem.l (A0),D0-D4
                move.w  #270-1,D6
icll:
                movem.l D0-D4,(A1)
                lea     10*2(A1),A1
                dbra    D6,icll
                rts
                ENDPART
;-------------------------------------------------------------------------------

colors_list:
                REPT 270
                DC.W $0000      ; 0  ....
                DC.W $0111      ; 1  ...x
                DC.W $0222      ; 2  ..x.
                DC.W $0333      ; 3  ..xx
                DC.W $0444      ; 4  .x..
                DC.W $0555      ; 5  .x.x
                DC.W $0666      ; 6  .xx.
                DC.W $0777      ; 7  .xxx
                DC.W $0300      ; 8  x...
                DC.W $0700      ; 9  x..x
                ENDR

digit_buffer_test:
                DS.W 320,$00001000

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                DATA
black:
zero:           DS.L 16

c0              SET $0700
c1              SET $0070
c2              SET $0007
c3              SET $0777
colors:         >PART

                DC.W $0000      ;0   ....
                DC.W c0         ;1   0...  <---PLANE1
                DC.W c1         ;2   .1..  <---PLANE2
                DC.W c1         ;3   01..

                DC.W c2         ;4   ..2.  <---PLANE3
                DC.W c0         ;5   0.2.
                DC.W c1         ;6   .12.
                DC.W c2         ;7   012.

                DC.W c3         ;8   ...3  <---PLANE4
                DC.W c0         ;9   0..3
                DC.W c1         ;10  .1.3
                DC.W c1         ;11  01.3
                DC.W c2         ;12  ..23
                DC.W c0         ;13  0.23
                DC.W c1         ;14  .123
                DC.W c3         ;15  0123

                ENDPART
;-------------------------------------------------------------------------------
pi1:
                IBYTES 'MODGIRL0.PI1'
;-------------------------------------------------------------------------------
                BSS

                IFNE TEST
                DS.B 1024
stack:          DS.B 2
                ENDC

sscr:
                DS.B 256
scr_ram:        DS.B $F000*2
escr:
BSS_END:
                END
