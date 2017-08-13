;-------------------------------------------------------------------------------
TEST            EQU 1
MUSIC_ON        EQU 1
;-------------------------------------------------------------------------------
                OUTPUT 'ENGE.PRG'
;-------------------------------------------------------------------------------
SIN_MASK        EQU $00000FFE   ; 2048*2-2
COS             EQU $00000400   ; 2048/4*2
;-------------------------------------------------------------------------------
;
;
; Fullscreen palette split fading
; (w)2014 defjam&lsl/checkpoint
;
;
;
; HBL-issue fixed??
;
;
; ENGE_72.SRC   ... VQ-decoder and sample replay
;
;
;-------------------------------------------------------------------------------
YW              EQU 270
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                >PART ' sys-struct '
; MUSIC - relative
                RSSET 0
__VQ_Init_All:  RS.L 1
__set_replay_mode:RS.L 1
__vq_decoder:   RS.L 1          ; in:  A1.samples_output
__get_sample_pointers:RS.L 1    ; out: A0.play A1.work
__get_codebook: RS.L 1          ; out: A0.codebook
__get_streampos:RS.L 1          ; out: A0.streampos
__set_streampos:RS.L 1          ; in:  A0.streampos
;-------------------------------

; replay mode setting
                RSSET 0
__set_replay_fast:RS.B 1
__set_replay_free:RS.B 1
__set_replay_ext_render:RS.B 1
;-------------------------------
                RSSET $00000038
MUSIC:          RS.L 1
                RSSET $000004CE
vbl_slot_first: RS.L 1          ; first executed vbl slot
vbl_slot0:      RS.L 1          ; fx vbl slot
script_slot:    RS.L 1
colors_ptr:     RS.L 1
EFFECT_TERMINATE_SIGNAL:RS.B 1
res0:           RS.B 1
res1:           RS.B 1
res2:           RS.B 1
__stream_pos:   RS.L 1
__codebook_currentPtr:RS.L 1
struct_end:     RS.L 0
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


__start__:
                OPT D-
                IFNE TEST
                OPT D+
                >PART ' init machine '
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
                ENDPART
;-------------------------------------------------------------------------------
                IFNE TEST
                >PART ' init machine '
                move    #$2700,SR
                lea     stack,SP
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w  ; auto eoi
                move.l  #count_vbl,$00000070.w
                move    #$2300,SR

                bsr     wait_vbl
                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w
                ENDPART
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


                bsr     wait_vbl

                lea     zero,A0
                movem.l (A0),D0-D6/A0
                movem.l D0-D6/A0,$FFFF8240.w

*    DC.L $4AFC4E71
                IFNE TEST
                jsr     VQ_PLAYER       ; Init VQ Audio all
                ENDC

                movea.l MUSIC.w,A0
                jsr     __get_codebook(A0) ; out: A0.codebook
                move.l  A0,codebook_currentPtr


                jsr     init_sintab

                lea     zero,A0
                lea     gfx,A1
                lea     pal0_gfx_fades,A2
                jsr     make_fades


                jsr     make_fade_blocks


                jsr     init_cfl_state_list


                jsr     copy_gfx_big

                moveq   #4,D0
*   jsr     shift_gfx

                lea     black,A0
*  lea     gfx,A0
                move.l  A0,top_colors+4

;-------------------------------------------------------------------------------
                bsr     wait_vbl

                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)


                bsr     wait_vbl

                move    #$2700,SR

                movea.l MUSIC.w,A1
                jsr     __get_streampos(A1) ; out: A0.streampos
                move.l  A0,stream_pos

                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                move.l  #vbl_fullscreen,$00000070.w
                move    #$2300,SR
;-------------------------------------------------------------------------------


loop:

                bsr     wait_vbl

                move.w  #20,D0          ; max.:22
*    bsr     wait_scanlines


                jsr     calc_fade_list


                move.l  $00000466.w,D0
                cmp.l   #1,D0
                beq.s   fok
*  DC.L $4AFC4E71
fok:

                move.b  $FFFFFC02.w,D0
                move.b  D0,key
                cmp.b   #$3B,D0
                bne.s   nf1_
                jsr     init_cfl_state_list
                bra     loop
nf1_:
                cmp.b   #$3C,D0
                bne.s   nf2_
                move.l  #count_vbl,$00000070.w
                move.l  #rte,$00000068.w
                move    #$2300,SR
                jsr     copy_gfx_big
                move.l  #vbl_fullscreen,$00000070.w
                bra     loop
nf2_:
                cmp.b   #$3D,D0
                bne.s   nf3_
                move.l  #count_vbl,$00000070.w
                move.l  #rte,$00000068.w
                jsr     copy_gfx_big
                moveq   #4,D0
                jsr     shift_gfx
                move.l  #vbl_fullscreen,$00000070.w
                bra     loop
nf3_:

** bsr     check_input

                cmp.b   #$62,D0
                bne.s   n62
                move.w  #$0007,$FFFF8240.w
n62:
                cmp.b   #$39,D0
                bne     loop
                DC.L $4AFC4E71
                bra     loop

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

wait_scanlines:
                subq.w  #1,D0
wsl:
                DS.W 128-3,$00004E71
                dbra    D0,wsl
                rts

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
sample_buffPtr: DC.L sound_buffer0,sound_buffer1
spl_play_ptr:   DC.L 0
spl_work_ptr:   DC.L 0
stream_pos:     DC.L 0
codebook_currentPtr:DC.L 0
;--------------------------------------------------------

vbl_fullscreen: >PART

;D7
;A4    ...sample_pointer
;A5/USP...ym_table
;A6    ...$FF8800


;***************************************************************************
;***************************************************************************
hbl_fix:
                move    #$2100,SR       ;without this, (hbl after overscan)
                stop    #$2100          ;double hbl-lines.  strange.
                move    #$2700,SR

**  lea     digit_buffer_test,A6 ; **TEST*****************

;-------------------------------------------------------
                movem.l sample_buffPtr(PC),A4/A6
                exg     A4,A6
                movem.l A4/A6,sample_buffPtr

                move.l  A4,spl_play_ptr
                move.l  A6,spl_work_ptr
                lea     $FFFF8800.w,A6
;-------------------------------------------------------

;***************************************************************************
;***************************************************************************

                move.w  hbl_start_lines(PC),HBL_LINE_COUNTER.w

                move.l  #hbl_start,$00000068.w

                move.l  #colors_list0,ColorsPtr.w

                move    #$2100,SR       ; enable hbl

;-----------------------------------------------------
                movem.l D0-D6/A0-A3,-(SP)

                movea.l MUSIC.w,A1
                jsr     __get_streampos(A1) ; out: A0.streampos
                move.l  A0,stream_pos

; vbl code here...
                movem.l (SP)+,D0-D6/A0-A3
;-----------------------------------------------------

                move.b  #$21,(SP)       ; hbl on
count_vbl:
                addq.l  #1,$00000466.w
rte:            rte
                ENDPART
hbl_start:      PART
;---------------------------------------------------
                move.b  (A4)+,D7        ; sample  0A|sample
                lsl.w   #3,D7           ; (0A|sample)*8
                move    USP,A5          ; ym_table
                adda.w  D7,A5
                move.l  (A5)+,(A6)
                move.l  (A5)+,D7
                movep.l D7,0(A6)
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

;;movem.l D0-A5,-(SP)     ; 30   SAVE REGISTERS

                movem.l D0-D6/A0-A3,-(SP) ; 24
                DS.W 6,$00004E71


top_colors:     movem.l 0,D0-D5/A0-A1   ;         21
                movem.l D0-D5/A0-A1,$FFFF8240.w ; 19

                movea.l stream_pos,A2   ;         5   Stream
                movea.l spl_work_ptr,A3 ;         5   sample output
                move.l  codebook_currentPtr,D5 ;  5   codebook

o               SET 14+21+19+16
o               SET o+3*5

                DS.W 89-o,$00004E71

;;;  DS.W 89-14-21-19-16,$00004E71

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

                movea.l ColorsPtr.w,A0  ;4
                movea.l (A0),A0         ;3
                addq.l  #4,ColorsPtr.w  ;6
                lea     $FFFF8240.w,A1  ;2
                move.l  (A0)+,(A1)+     ;5   0,1
                move.l  (A0)+,(A1)+     ;5   2,3
o               SET o+4+3+6+2
o               SET o+5+5

                move.l  SP,reload_stack+2 ;    5
                lea     $FFFF820A.w,SP  ;      2
                move.w  #$0100,D6       ;      2
o               SET o+5+2+2


                DS.W 37-o-3,$00004E71

border_einsprungA:jmp   border_code_oriA ; 3

*    move.w  #$0700,$FFFF8240.w
*    move.w  #$0000,$FFFF8240.w

Q:
border_code_oriA:

; REPT 5
;    move.w (a2)+,d1
;       REPT 8
;            decode block
;
a:
pos             SET 0
                REPT 40         ;  5*8
                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Links auf)
                move.l  (A0)+,(A1)+     ;5   4,5
                move.l  (A0)+,(A1)+     ;5   6,7
                move.l  (A0)+,(A1)+     ;5   8,9
                move.l  (A0)+,(A1)+     ;5   10,11
                move.l  (A0)+,(A1)+     ;5   12,13
                move.l  (A0)+,(A1)+     ;5   14,15
;-- sample -------------------------------------------------------
                move.b  (A4)+,D7        ; 2  sample  0A|sample
                lsl.w   #3,D7           ; 3  (0A|sample)*8
                move    USP,A5          ; 1  ym_table
                adda.w  D7,A5           ; 2
                move.l  (A5)+,(A6)      ; 6
                move.l  (A5)+,D7        ; 3
                movep.l D7,0(A6)        ; 7     (24)
;-----------------------------------------------------------------
                IF pos=0
                move.w  (A2)+,D1        ; 2  8 values (bits 10)
                ELSE
                nop
                nop
                ENDC
pos             SET pos+1
                IF pos=8
pos             SET 0
                ENDC
;-------------------------------------------------
; decode 8 samples
                moveq   #0,D0           ; 1
                move.b  (A2)+,D0        ; 2  bits 8765432
                add.w   D1,D1           ; 1  bit         1
                addx.w  D0,D0           ; 1
                add.w   D1,D1           ; 1  bit          0
                addx.w  D0,D0           ; 1
                lsl.w   #3,D0           ; 3
                movea.l D5,A0           ; 1
                adda.w  D0,A0           ; 2
                move.l  (A0)+,(A3)+     ; 5
                move.l  (A0)+,(A3)+     ; 5  ... 23+2(d1 fetch) = 25
;-------------------------------------------------

                DS.W 89-6*5-4-24-25,$00004E71

                movea.l ColorsPtr.w,A0  ;4
                move.b  D6,(SP)         ;2   60Hz
                move.w  SP,(SP)         ;2   50Hz (Rechts auf)
                movea.l (A0),A0         ;3
                addq.l  #4,ColorsPtr.w  ;6
                lea     $FFFF8240.w,A1  ;2
                DS.W 12-3-6-2,$00004E71
                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Rechts zu)
                move.l  (A0)+,(A1)+     ;5   0,1
                move.l  (A0)+,(A1)+     ;5   2,3
                DS.W 11-5-5,$00004E71
                ENDR
;-------------------------------------------------------------------

                REPT 227-40
                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Links auf)
                move.l  (A0)+,(A1)+     ;5   4,5
                move.l  (A0)+,(A1)+     ;5   6,7
                move.l  (A0)+,(A1)+     ;5   8,9
                move.l  (A0)+,(A1)+     ;5   10,11
                move.l  (A0)+,(A1)+     ;5   12,13
                move.l  (A0)+,(A1)+     ;5   14,15
;-- sample -------------------------------------------------------
                move.b  (A4)+,D7        ; 2  sample  0A|sample
                lsl.w   #3,D7           ; 3  (0A|sample)*8
                move    USP,A5          ; 1  ym_table
                adda.w  D7,A5           ; 2
                move.l  (A5)+,(A6)      ; 6
                move.l  (A5)+,D7        ; 3
                movep.l D7,0(A6)        ; 7     (24)
;-----------------------------------------------------------------
                DS.W 89-6*5-4-24,$00004E71

                movea.l ColorsPtr.w,A0  ;4
                move.b  D6,(SP)         ;2   60Hz
                move.w  SP,(SP)         ;2   50Hz (Rechts auf)
                movea.l (A0),A0         ;3
                addq.l  #4,ColorsPtr.w  ;6
                lea     $FFFF8240.w,A1  ;2
                DS.W 12-3-6-2,$00004E71
                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Rechts zu)
                move.l  (A0)+,(A1)+     ;5   0,1
                move.l  (A0)+,(A1)+     ;5   2,3
                DS.W 11-5-5,$00004E71
                ENDR
;-------------------------------------------------------------------
; open bottom border
* jmp     border_code_doneA

                move.w  SP,$0056(SP)    ;2   Highres
                move.b  D6,$0056(SP)    ;2   Lowres (Links auf)

                move.l  (A0)+,(A1)+     ;5   4,5
                move.l  (A0)+,(A1)+     ;5   6,7
                move.l  (A0)+,(A1)+     ;5   8,9
                move.l  (A0)+,(A1)+     ;5   10,11
                move.l  (A0)+,(A1)+     ;5   12,13
                move.l  (A0)+,(A1)+     ;5   14,15
;-- sample -------------------------------------------------------
                move.b  (A4)+,D7        ; 2  sample  0A|sample
                lsl.w   #3,D7           ; 3  (0A|sample)*8
                move    USP,A5          ; 1  ym_table
                adda.w  D7,A5           ; 2
                move.l  (A5)+,(A6)      ; 6
                move.l  (A5)+,D7        ; 3
                movep.l D7,0(A6)        ; 7     (24)
;-----------------------------------------------------------------

                DS.W 89-6*5-4-24,$00004E71

                movea.l ColorsPtr.w,A0  ;4

                move.b  D6,(SP)         ;2   60Hz
                move.w  SP,(SP)         ;2   50Hz (Rechts auf)

                movea.l (A0),A0         ;3
                addq.l  #4,ColorsPtr.w  ;6
                lea     $FFFF8240.w,A1  ;2

                DS.W 12-3-6-2,$00004E71

                move.w  SP,$0056(SP)    ;2   Highres
                move.b  D6,$0056(SP)    ;2   Lowres (Rechts zu)

;Unten ™ffnen
                move.b  D6,(SP)         ;2   60Hz

                move.l  (A0)+,(A1)+     ;5   0,1
*  move.l  (A0)+,(A1)+     ;5   2,3
                DS.W 9-5,$00004E71
* DS.W 9,$00004E71
;---------------------------------------------
                move.w  SP,$0056(SP)    ;2   Highres
                move.b  D6,$0056(SP)    ;2   Lowres (Links auf)

                move.w  SP,(SP)         ;2   50Hz

                move.l  (A0)+,(A1)+     ;5   2,3

                move.l  (A0)+,(A1)+     ;5   4,5
                move.l  (A0)+,(A1)+     ;5   6,7
                move.l  (A0)+,(A1)+     ;5   8,9
                move.l  (A0)+,(A1)+     ;5   10,11
                move.l  (A0)+,(A1)+     ;5   12,13
                move.l  (A0)+,(A1)+     ;5   14,15
;-- sample -------------------------------------------------------
                move.b  (A4)+,D7        ; 2  sample  0A|sample
                lsl.w   #3,D7           ; 3  (0A|sample)*8
                move    USP,A5          ; 1  ym_table
                adda.w  D7,A5           ; 2
                move.l  (A5)+,(A6)      ; 6
                move.l  (A5)+,D7        ; 3
                movep.l D7,0(A6)        ; 7     (24)
;-----------------------------------------------------------------

                DS.W 87-5-6*5-4-24,$00004E71
                movea.l ColorsPtr.w,A0  ;4
*   DS.W 87,$00004E71

                move.b  D6,(SP)         ;2   60Hz
                move.w  SP,(SP)         ;2   50Hz (Rechts auf)

                movea.l (A0),A0         ;3
                addq.l  #4,ColorsPtr.w  ;6
                lea     $FFFF8240.w,A1  ;2
                DS.W 12-3-6-2,$00004E71
*   DS.W 12,$00004E71

                move.w  SP,$0056(SP)    ;2   Highres
                move.b  D6,$0056(SP)    ;2   Lowres (Rechts zu)

                move.l  (A0)+,(A1)+     ;5   0,1
                move.l  (A0)+,(A1)+     ;5   2,3
                DS.W 11-5-5,$00004E71
;------------------------------------------------------
; open left/right bottom

                REPT 41         ; 37

                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Links auf)

                move.l  (A0)+,(A1)+     ;5   4,5
                move.l  (A0)+,(A1)+     ;5   6,7
                move.l  (A0)+,(A1)+     ;5   8,9
                move.l  (A0)+,(A1)+     ;5   10,11
                move.l  (A0)+,(A1)+     ;5   12,13
                move.l  (A0)+,(A1)+     ;5   14,15

;-- sample -------------------------------------------------------
                move.b  (A4)+,D7        ; 2  sample  0A|sample
                lsl.w   #3,D7           ; 3  (0A|sample)*8
                move    USP,A5          ; 1  ym_table
                adda.w  D7,A5           ; 2
                move.l  (A5)+,(A6)      ; 6
                move.l  (A5)+,D7        ; 3
                movep.l D7,0(A6)        ; 7     (24)
;-----------------------------------------------------------------
                DS.W 89-6*5-4-24,$00004E71

                movea.l ColorsPtr.w,A0  ;4

                move.b  D6,(SP)         ;2   60Hz
                move.w  SP,(SP)         ;2   50Hz (Rechts auf)

                movea.l (A0),A0         ;3
                addq.l  #4,ColorsPtr.w  ;6
                lea     $FFFF8240.w,A1  ;2

                DS.W 12-3-6-2,$00004E71

                move.w  SP,$0056(SP)    ;3   Highres
                move.b  D6,$0056(SP)    ;3   Lowres (Rechts zu)

                move.l  (A0)+,(A1)+     ;5   0,1
                move.l  (A0)+,(A1)+     ;5   2,3
                DS.W 11-5-5,$00004E71

                ENDR

* jmp     border_code_doneA

                ENDPART
border_code_doneA:PART

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

; update streampos
                move.l  A2,stream_pos
                lea     (A2),A0
                movea.l MUSIC.w,A1
                jsr     __set_streampos(A1) ; in:  A0.streampos

;------------------------------------------------
; Protracker replay goes here
;------------------------------------------------

                movem.l (SP)+,D0-D6/A0-A3

                move.b  #$21,(SP)       ; hbl on
                rte
                ENDPART
hbl_end:        >PART
                move    #$2700,SR       ;****
                move.b  (A4)+,D7        ; sample  0A|sample
                lsl.w   #3,D7           ; (0A|sample)*8
                move    USP,A5          ; ym_table
                adda.w  D7,A5
                move.l  (A5)+,(A6)
                move.l  (A5)+,D7
                movep.l D7,0(A6)
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

colors_list0:
                REPT 274
                DC.L zero
                ENDR

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                IFNE TEST
instr_cycle:    PART
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

                move    A0,USP

                lea     $FFFF8800.w,A6

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

Z:
; rept 40/8
                move.w  (A2)+,D1        ; 2  8 values (bits 10)
_vq_decode_t1:
; rept 8
;-------------------------------------------------
; decode 8 samples
                moveq   #0,D0           ; 1
                move.b  (A2)+,D0        ; 2  bits 8765432
                add.w   D1,D1           ; 1  bit         1
                addx.w  D0,D0           ; 1
                add.w   D1,D1           ; 1  bit          0
                addx.w  D0,D0           ; 1
                lsl.w   #3,D0           ; 3
                movea.l D5,A0           ; 1
                adda.w  D0,A0           ; 2
                move.l  (A0)+,(A3)+     ; 5
                move.l  (A0)+,(A3)+     ; 5  ... 23
;-------------------------------------------------



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


                movea.l stream_pos,A2   ;         5   Stream
                movea.l spl_work_ptr,A3 ;         5   sample output
                move.l  codebook_currentPtr,D5 ;  5   codebook


; rept 40/8
                move.w  (A2)+,D1        ; 2  8 values (bits 10)
;_vq_decode_t1:
; rept 8
;-------------------------------------------------
; decode 8 samples
                moveq   #0,D0           ; 1
                move.b  (A2)+,D0        ; 2  bits 8765432
                add.w   D1,D1           ; 1  bit         1
                addx.w  D0,D0           ; 1
                add.w   D1,D1           ; 1  bit          0
                addx.w  D0,D0           ; 1
                lsl.w   #3,D0           ; 3
                movea.l D5,A0           ; 1
                adda.w  D0,A0           ; 2
                move.l  (A0)+,(A3)+     ; 5
                move.l  (A0)+,(A3)+     ; 5
;-------------------------------------------------







; rept 40/8
                move.w  (A0)+,D1        ; 2  8 values (bits 10)
__vq_decode_t1:
; rept 8
;-------------------------------------------------
; decode 8 samples
                moveq   #0,D0           ; 1
                move.b  (A0)+,D0        ; 2  bits 8765432
                add.w   D1,D1           ; 1  bit         1
                addx.w  D0,D0           ; 1
                add.w   D1,D1           ; 1  bit          0
                addx.w  D0,D0           ; 1
                lsl.w   #3,D0           ; 3
                lea     (A2),A3         ; 1
                adda.w  D0,A3           ; 2
                move.l  (A3)+,(A1)+     ; 5
                move.l  (A3)+,(A1)+     ; 5
;-------------------------------------------------




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
                move.w  #270-1,-(SP)
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
                subq.w  #1,(SP)
                bpl.s   sg_y
                addq.l  #2,SP
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

copy_gfx_big:   PART

                lea     gfx+32,A0

                movea.l screen1,A1
                lea     8+160(A1),A1

                move.w  #YW-1,D6
cgb_y:
; 384/2 = 192 bytes / 32 = 6
                movem.l (A0)+,D0-D5/A2-A3 ; 8*4 = 32 bytes
                movem.l D0-D5/A2-A3,(A1)
o               SET 32
                REPT 5
                movem.l (A0)+,D0-D5/A2-A3 ; 8*4 = 32 bytes
                movem.l D0-D5/A2-A3,o(A1)
o               SET o+32
                ENDR
                lea     230(A1),A1
                dbra    D6,cgb_y
                rts
                ENDPART

digit_buffer_test:
                DS.W 320,$00001000



;-------------------------------------------------------------------------------
; A0...colors
fix_st_palette: >PART
                moveq   #16-1,D0
fstp:
                andi.w  #$0777,(A0)+
                dbra    D0,fstp
                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0...pal0
; A1...pal1
; A2...output
make_fades:     >PART
*    DC.L $4AFC4E71

                movem.l A0-A1,pal0_mf

                clr.w   -(SP)           ; fade factor
mfl_fades:
                move.w  (SP),D7         ; fade1
                moveq   #8,D6
                sub.w   D7,D6           ; fade0

                movem.l pal0_mf(PC),A0-A1

                lea     $FFFF8240.w,A6  ; *** DEBUG ***

                move.w  #16-1,-(SP)     ; amount colors
mfl_colors:

; D0.r  D1.g  D2.b
                move.w  (A0)+,D0        ; rgb
                moveq   #7,D2
                and.w   D0,D2           ; b
                lsr.w   #4,D0
                moveq   #7,D1
                and.w   D0,D1           ; g
                lsr.w   #4,D0           ; r
; D0.r  D1.g  D2.b

; D3.r  D4.g  D5.b
                move.w  (A1)+,D3        ; rgb
                moveq   #7,D5
                and.w   D3,D5           ; b
                lsr.w   #4,D3
                moveq   #7,D4
                and.w   D3,D4           ; g
                lsr.w   #4,D3           ; r

                mulu    D6,D0           ; f0
                mulu    D6,D1           ; f0
                mulu    D6,D2           ; f0

                mulu    D7,D3           ; f1
                mulu    D7,D4           ; f1
                mulu    D7,D5           ; f1

                add.w   D3,D0           ; r mix
                add.w   D4,D1           ; g mix
                add.w   D5,D2           ; b mix

                lsr.w   #3,D0
                lsr.w   #3,D1
                lsr.w   #3,D2

                lsl.w   #4,D0
                or.w    D1,D0
                lsl.w   #4,D0
                or.w    D2,D0

                move.w  D0,(A2)+        ; output

***  move.w  D0,(A6)+        ; debug hwcols

                subq.w  #1,(SP)
                bpl.s   mfl_colors
                addq.l  #2,SP

                addq.w  #1,(SP)
                cmpi.w  #8,(SP)         ; 0...8
                ble.s   mfl_fades
                addq.l  #2,SP
                rts
pal0_mf:        DC.L 0
pal1_mf:        DC.L 0
                ENDPART
;-------------------------------------------------------------------------------

; 270/30 = 9

;-------------------------------------------------------------------------------
make_fade_blocks:>PART

*  DC.L $4AFC4E71


                lea     sintab,A0
                lea     mfb_sin,A1
                moveq   #30-1,D7
mfb_sinc:
                moveq   #30-1,D0
                sub.w   D7,D0
                mulu    #COS*2,D0
                divu    #30-1,D0
                and.w   #SIN_MASK,D0
                move.w  0(A0,D0.w),D0

                move.w  D0,D1

; sin^2 looks somehow better
                muls    D0,D0
                asl.l   #2,D0
                swap    D0

                add.w   #$1000,D0       ; 1000
                move.w  D0,(A1)+

                dbra    D7,mfb_sinc

                lea     mfb_list,A6
                moveq   #32-1,D7
mfb:
                moveq   #32-1,D5
                sub.w   D7,D5
                asl.w   #2,D5

                lea     mfb_sin,A0
                lea     fade_list,A1
                moveq   #30-1,D6
mfb2:
                move.w  (A0)+,D0
                muls    D5,D0
                swap    D0
                add.w   D0,D0
                add.w   D0,D0
                bpl.s   *+2
                moveq   #0,D0
                cmp.w   #8*4,D0
                ble.s   *+2
                moveq   #8*4,D0
                move.l  0(A1,D0.w),(A6)+
                dbra    D6,mfb2

                dbra    D7,mfb

                rts
                ENDPART
;-------------------------------------------------------------------------------

calc_fade_list: >PART

*    DC.L $4AFC4E71

                lea     cfl_state_list,A0

                lea     colors_list0,A2

                moveq   #9-1,D6
cfl_l:
                move.l  (A0)+,D0        ; value
                move.l  (A0)+,D1        ; inc
                move.l  D0,D2
                bpl.s   *+2
                moveq   #0,D2
                swap    D2
                cmp.w   #31,D2
                ble.s   *+2
                moveq   #31,D2

                add.w   D2,D2
                add.w   D2,D2
                lea     mfb_list_pointers(PC),A1
                movea.l 0(A1,D2.w),A1

                REPT 30
                move.l  (A1)+,(A2)+
                ENDR

                add.l   D1,D0           ; inc
                move.l  D0,-8(A0)       ; update value
                dbra    D6,cfl_l
                rts
                ENDPART

init_cfl_state_list:>PART

*     DC.L $4AFC4E71

                lea     cfl_state_list,A0
                lea     rnd(PC),A1
                moveq   #9-1,D6
icsl:
                bsr.s   rnd
                and.l   #$0007FFFF,D0
                sub.l   #$000A0000,D0
                move.l  D0,(A0)+        ; value

                jsr     (A1)
                jsr     (A1)
                jsr     (A1)
                jsr     (A1)

                and.l   #$00000FFF,D0
                add.l   #$00004000,D0   ; 5000
                move.l  D0,(A0)+        ; inc

                jsr     (A1)
                jsr     (A1)
                jsr     (A1)
                jsr     (A1)
                jsr     (A1)

                dbra    D6,icsl
                rts
                ENDPART

rnd:            >PART
                move.l  #$C001C0DE,D0
                addq.l  #5,D0
                rol.l   D0,D0
                move.l  D0,rnd+2
                rts
                ENDPART

; pal0_gfx_fades: DS.W 9*16
fade_list_cfl:
o               SET 0
                REPT 9
                DC.L pal0_gfx_fades+o
o               SET o+16*2
                ENDR

cfl_state_list:
; value, inc
                DS.L 9*2

mfb_list:
                DS.L 32*30
mfb_sin:
                DS.W 30

mfb_list_pointers:
o               SET 0
                REPT 32
                DC.L mfb_list+o
o               SET o+30*4
                ENDR
o               SET 31*30*4
                REPT 32
                DC.L mfb_list+o
o               SET o-30*4
                ENDR


; pal0_gfx_fades: DS.W 9*16
fade_list:
o               SET 16*2
                REPT 8
                DC.L pal0_gfx_fades+o
o               SET o+16*2
                ENDR
o               SET 8*16*2
                REPT 8
                DC.L pal0_gfx_fades+o
o               SET o-16*2
                ENDR



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
                move.w  D4,2048*2(A0)
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

gfx:
                PATH 'C:\0NEW\TDOME\ENGE\'
                IBYTES 'ENGE.GFX'

                IFNE TEST
;-------------------------------------------------------------------------------
                jsr     VQ_PLAYER
VQ_PLAYER:
                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
                IBYTES 'VQAUDIO.PRG'
                EVEN
;-------------------------------------------------------------------------------
                ENDC

                BSS

sound_buffer0:  DS.B 330
sound_buffer1:  DS.B 330
sbuff_end:      DS.B 2

pal0_gfx_fades: DS.W 9*16

sintab:         DS.W 2048*2

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
E:

;-------------------------------------------------------------------------------

                moveq   #__set_replay_free,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
;;  jsr     __set_replay_mode(A0)


                bsr     set_replay_ext


loop:
                bsr     wait_vbl

                clr.w   $FFFF8240.w

                move.w  scol(PC),$FFFF8240.w

*   move.w  #196,D0

                move.w  #50,D0
                bsr     wait_scanlines

                move.w  #$0007,$FFFF8240.w

                move.b  $FFFFFC02.w,D0
                cmp.b   oldkey(PC),D0
                beq.s   loop
                move.b  D0,oldkey

                cmp.b   #$3B,D0
;  beq.s   f1
                cmp.b   #$3C,D0
;  beq.s   f2

                cmp.b   #$62,D0
                bne.s   n62
                move.w  #$0007,$FFFF8240.w
n62:
                cmp.b   #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                bra.s   loop
f1:
                moveq   #__set_replay_fast,D0
                bsr     set_replay_mode
                move.w  #$0070,scol
                bra     loop
f2:
                moveq   #__set_replay_free,D0
                bsr     set_replay_mode
                move.w  #$0700,scol
                bra     loop

oldkey:         DC.W 0
scol:           DC.W $0070


wait_scanlines: >PART
                DS.W 128-3,$00004E71
                dbra    D0,wait_scanlines
                rts
                ENDPART

regs:
                DS.L 32,$AAAAAAAA


set_replay_ext:
                moveq   #__set_replay_ext_render,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                move.l  #vbl_ext,$00000070.w

                move.l  #timer_play_ext,$00000068.w

                move    #$2100,SR

                rts


vbl_ext:        >PART

                move    #$2700,SR
;-------------------------------------------------------
                movem.l A4/A6,-(SP)
                movem.l sample_buffPtrE(PC),A4/A6
                exg     A4,A6
                movem.l A4/A6,sample_buffPtrE

                move.l  A4,sample_adr_ext+2

                move.l  A4,spl_play_ptrE
                move.l  A6,spl_work_ptrE
                movem.l (SP)+,A4/A6
;-------------------------------------------------------
                move    #$2100,SR

                movem.l D0-A6,-(SP)

                bsr     vbl_top_routine

                movea.l spl_work_ptrE(PC),A1 ; sample output

                movea.l MUSIC.w,A3
                jsr     __vq_decoder(A3)

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte

                ENDPART

spl_play_ptrE:  DC.L 0
spl_work_ptrE:  DC.L 0
sample_buffPtrE:DC.L sound_bufferX0,sound_bufferX1

timer_play_ext: >PART
                move    #$2700,SR

                move.l  D7,-(SP)
                pea     (A6)
                moveq   #0,D7
                lea     $FFFF8800.w,A6
sample_adr_ext: move.b  sound_bufferX0,D7
                lsl.w   #3,D7
                move.l  ym_table_optimum2(PC,D7.w),(A6)
                move.l  ym_table_optimum2+4(PC,D7.w),D7
                movep.l D7,0(A6)
                addq.l  #1,sample_adr_ext+2
                movea.l (SP)+,A6
                move.l  (SP)+,D7
                rte
                ENDPART
ym_table_optimum2:
                IBYTES 'YM_TAB.FIN'

sound_bufferX0: DS.B 330
sound_bufferX1: DS.B 330

                ENDC
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
VQ_Service:
                OPT O-,W-
                bra     VQ_Init_All
                bra     set_replay_mode
                bra     vq_decoder      ;     in:  A1.samples_output
                bra     get_sample_pointers ; out: A0.play A1.work
                OPT O+,W+
;-------------------------------------------------------------------------------
VQ_Init_All:    >PART

                lea     VQ_Service(PC),A0
                move.l  A0,MUSIC.w

;;; DC.L $4AFC4E71

                lea     vbl_slot_first.w,A0
                move.w  #struct_end-vbl_slot_first-1,D0
clrstr:         clr.b   (A0)+
                dbra    D0,clrstr


                bsr     relocate_VQ


                lea     rte(PC),A0
                move.l  A0,$00000134.w
                move.l  A0,$00000060.w
                move.l  A0,$00000068.w
                move.l  #cnt_vbl,$00000070.w

                lea     sound_buffer0,A0
                move.w  #sbuff_end-sound_buffer0-1,D0
clrsb:          clr.b   (A0)+
                dbra    D0,clrsb

                bsr     init_soundchip

                bsr     Init_VQ_Decoder

                lea     bitstream,A0
                lea     codebook,A1
                bsr     VQ_Init

                moveq   #__set_replay_free,D0
                bsr.s   set_replay_mode
                rts
                ENDPART
;-------------------------------------------------------------------------------
relocate_VQ:    >PART

                lea     program_start(PC),A0
                cmpa.l  #program_start,A0
                beq.s   relocated
                move.l  A0,D0

                adda.l  #relocation_table-program_start,A0

                move.l  (A0)+,D1        ;relocation info ??
                beq.s   end_relocation  ;nope...
                movea.l D0,A1           ; text start
                adda.l  D1,A1           ;1st adress - long offset
                moveq   #0,D1
relo_do:
                add.l   D0,(A1)         ;relocate!
RELO2:
                move.b  (A0)+,D1
                beq.s   end_relocation
                cmp.b   #1,D1
                bne.s   normal_distance
                lea     254(A1),A1
                bra.s   RELO2
normal_distance:
                adda.l  D1,A1
                bra.s   relo_do
end_relocation:
relocated:
                rts
                ENDPART
;-------------------------------------------------------------------------------
init_soundchip: >PART
                lea     $FFFF8800.w,A0
                move.w  #$0D00,D0
clr_ym:
                movep.w D0,0(A0)
                sub.w   #$0100,D0
                bpl.s   clr_ym
                move.w  #$07FF,D0
                movep.w D0,0(A0)
                rts
                ENDPART
;-------------------------------------------------------------------------------
get_sample_pointers:                    ; out: A0.play A1.work
                movea.l spl_play_ptr(PC),A0
                movea.l spl_work_ptr(PC),A1
                rts

set_replay_mode:
                bsr     wait_vbl

                move    #$2700,SR
                lsl.w   #2,D0
                jsr     srm(PC,D0.w)

                bsr     wait_vbl
                rts
srm:
                OPT O-,W-
                bra     set_replay_fast
                bra     set_replay_free
                bra     set_replay_ext_render
                OPT O+,W+

;-------------------------------------------------------------------------------
A:
set_replay_fast:PART
;D7
;A4    ...sample_pointer
;A5/USP...ym_table
;A6    ...$FF8800

                lea     sound_buffer0,A4

                lea     ym_table_optimum(PC),A5
                lea     -$00000A00*8(A5),A5 ; 1337 trick
                move    A5,USP
                lea     $FFFF8800.w,A6
                move.w  #$0A00,D7       ;     1337 trick

                move.l  #timer_play_fast,$00000134.w

                bsr.s   set_timer_data

                move.l  #vbl_play_fast,$00000070.w
                move    #$2300,SR
                rts
                ENDPART
set_replay_free:>PART
                lea     sound_buffer0,A4
                move.l  A4,sample_adr0+2

                move.l  #timer_play_free,$00000134.w

                bsr.s   set_timer_data

                move.l  #vbl_play_free,$00000070.w
                move    #$2300,SR
                rts
                ENDPART
set_replay_ext_render:

                move.l  stream_pos(PC),__stream_pos.w
                move.l  codebook_currentPtr(PC),__codebook_currentPtr.w

                move.l  #vbl_empty,$00000070.w
                bsr     disable_timer_a

                move    #$2300,SR
                rts
;-------------------------------------------------------------------------------
set_timer_data: >PART

                bclr    #3,$FFFFFA17.w  ; auto eoi

                clr.b   $FFFFFA19.w
                move.b  #Timer_Data,$FFFFFA1F.w ; ta_data
                move.b  #Timer_Ctrl,$FFFFFA19.w ; ta_ctrl

; enable Timer A IRQ
                bset    #5,$FFFFFA07.w
                bset    #5,$FFFFFA13.w

                rts
                ENDPART
disable_timer_a:>PART
                clr.b   $FFFFFA19.w
                bclr    #5,$FFFFFA07.w
                bclr    #5,$FFFFFA13.w
                rts
                ENDPART
;-------------------------------------------------------------------------------


vbl_play_fast:  PART
                move    #$2700,SR
;-------------------------------------------------------
                movem.l sample_buffPtr(PC),A4/A6
                exg     A4,A6
                movem.l A4/A6,sample_buffPtr

                move.l  A4,spl_play_ptr
                move.l  A6,spl_work_ptr
                lea     $FFFF8800.w,A6
;-------------------------------------------------------

                movem.l D0-D6/A0-A3,-(SP)

                bsr     vbl_top_routine
                move    #$2400,SR

                movea.l spl_work_ptr(PC),A1 ; sample output
                bsr     vq_decoder

                movem.l (SP)+,D0-D6/A0-A3

                addq.l  #1,$00000466.w
                rte

                ENDPART

vbl_play_free:  >PART

                move    #$2700,SR
;-------------------------------------------------------
                movem.l A4/A6,-(SP)
                movem.l sample_buffPtr(PC),A4/A6
                exg     A4,A6
                movem.l A4/A6,sample_buffPtr

                move.l  A4,sample_adr0+2

                move.l  A4,spl_play_ptr
                move.l  A6,spl_work_ptr
                movem.l (SP)+,A4/A6
;-------------------------------------------------------

                movem.l D0-A6,-(SP)

                bsr     vbl_top_routine
                move    #$2400,SR

                movea.l spl_work_ptr(PC),A1 ; sample output
                bsr     vq_decoder

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte

                ENDPART


vbl_empty:      >PART

                movem.l D0-A6,-(SP)

                bsr     vbl_top_routine

                movem.l (SP)+,D0-A6

                addq.l  #1,$00000466.w
                rte

                ENDPART


;-------------------------------------------------------------------------------
vbl_top_routine:>PART

; timer-b setup etc.
                move.l  vbl_slot_first.w,D0 ; first executed vbl slot
                beq.s   *+4
                movea.l D0,A0
                jsr     (A0)

; set palette
                move.l  colors_ptr.w,D0
                beq.s   no_colors_set
                movea.l D0,A1
                movem.l (A1),D0-D6/A1
                movem.l D0-D6/A1,$FFFF8240.w
;; clr.l   colors_ptr.w
no_colors_set:
                rts
                ENDPART
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;D7
;A4...sample_pointer
;A5...ym_table
;A6...$FF8800
;-----------------------
timer_play_fast:PART
                move.b  (A4)+,D7        ; sample  0A|sample
                lsl.w   #3,D7           ; (0A|sample)*8
                move    USP,A5          ; ym_table
                adda.w  D7,A5
                move.l  (A5)+,(A6)
                move.l  (A5)+,D7
                movep.l D7,0(A6)
                rte
                ENDPART

timer_play_free:>PART
                move.l  D7,-(SP)
                pea     (A6)
                moveq   #0,D7
                lea     $FFFF8800.w,A6
sample_adr0:    move.b  sound_buffer0,D7
                lsl.w   #3,D7
                move.l  ym_table_optimum(PC,D7.w),(A6)
                move.l  ym_table_optimum+4(PC,D7.w),D7
                movep.l D7,0(A6)
                addq.l  #1,sample_adr0+2
                movea.l (SP)+,A6
                move.l  (SP)+,D7
                rte
                ENDPART

ym_table_optimum:
                IBYTES 'YM_TAB.FIN'


hbl_play_fast:  >PART
                move    #$2700,SR       ; Wichtig!!! hbl interrupts itself in border!!
                move.b  (A4)+,D7        ; sample
                lsl.w   #3,D7
                move    USP,A5          ; ym_table
                adda.w  D7,A5
                move.l  (A5)+,(A6)
                move.l  (A5)+,D7
                movep.l D7,0(A6)
                rte
                ENDPART

;-------------------------------------------------------------------------------


stream_pos:
                DC.L bitstream


;-------------------------------------------------------------------------------

vq_decoder:     PART

*  DC.L $4AFC4E71

;;; movea.l spl_work_ptr(PC),A1 ; sample output

                movea.l stream_pos(PC),A0
                movea.l codebook_currentPtr(PC),A2

                bsr     vq_decode_40

                bsr.s   vq_check_stream_end

                rts

                ENDPART

vq_check_stream_end:>PART
                cmpa.l  #bitstream_end,A0
                blt.s   map_not_end
                bsr     VQ_Restart
map_not_end:
                move.l  A0,stream_pos
                move.l  A2,codebook_currentPtr
                addq.l  #1,f
                rts

f:              DC.L 0

                ENDPART

;-------------------------------------------------------------------------------
codebook_currentPtr:DC.L 0
;-------------------------------------------------------------------------------
; A0...stream
; A1...codebook
init_stream:    >PART

;  move.l  (A0)+,D0        ; ID  "BLCK"
;  move.l  (A0)+,D0        ; codebook_new_counter
;  subq.w  #1,D0
;  move.w  D0,codebook_new_counter
;  move.w  D0,codebook_new_freq

*   DC.L $4AFC4E71

                move.l  A1,codebook_currentPtr
                lea     (A1),A2

;  lea     CBOOK*BLOCK_SIZE(A0),A0
;  move.l  (A0)+,D0        ; ID  "MAP!"

                move.l  A0,stream_pos
                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0...stream
; A1...codebook
VQ_Init:        >PART

*  DC.L $4AFC4E71

                bsr.s   init_stream

                rts
                ENDPART
;-------------------------------------------------------------------------------
VQ_Restart:     >PART
                lea     bitstream,A0
                lea     codebook,A1
                bsr.s   VQ_Init
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Init_VQ_Decoder:>PART

*    DC.L $4AFC4E71

                lea     vq_decode_40(PC),A1
                moveq   #40/8-1,D0
ivqd_0:
                lea     vq_decode_t0(PC),A0
                move.w  (A0)+,(A1)+     ; fetch bits 10
                moveq   #8-1,D1         ; decode 8 samples
ivqd_1:
                lea     (A0),A2
                moveq   #(vq_decode_t1_e-vq_decode_t1)/2-1,D2
copy_code:
                move.w  (A2)+,(A1)+
                dbra    D2,copy_code
                dbra    D1,ivqd_1
                dbra    D0,ivqd_0

                move.w  #$4E75,(A1)+

;  suba.l  #vq_decode_40,A1

                rts
                ENDPART
vq_decode_t0:   PART ' decoder template '

; rept 40/8
                move.w  (A0)+,D1        ; 8 values (bits 10)
vq_decode_t1:
; rept 8
;-------------------------------------------------
; decode 8 samples
                moveq   #0,D0
                move.b  (A0)+,D0        ; bits 8765432
                add.w   D1,D1           ; bit         1
                addx.w  D0,D0           ;
                add.w   D1,D1           ; bit          0
                addx.w  D0,D0           ;
                lsl.w   #3,D0
                lea     (A2),A3
                adda.w  D0,A3
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
;-------------------------------------------------
; endr
; endr
vq_decode_t1_e:
                DC.L 0,0
                ENDPART
;-------------------------------------------------------------------------------
vq_decode_40:   DS.B $037C
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
wait_vbl:       >PART
                clr.l   $00000466.w
wv:             tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------

cnt_vbl:
                addq.l  #1,$00000466.w
rte:            rte
rts:            rts


;-------------------------------------------------------------------------------

                IFNE TEST
;-------------------------------------------------------------------------------
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

;;   movea.l screen1,A0

                lea     bss_end,A0

                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                lea     (A0),A4
                lea     (A0),A5
                lea     (A0),A6

                lea     $FFFF8800.w,A6


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

; pea     (A6)
                movea.l (SP)+,A6

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
;-------------------------------------------------------------------------------
                ENDC

;¯DATA


codebook:
                IBYTES 'CODEBOOK.DAT'

bitstream:
                IBYTES 'VQST_0.STR'
bitstream_end:
                EVEN

relocation_table:
;-------------------------------------------------------------------------------
;¯BSS

                IFNE TEST
                DS.B 1024
stack:          DS.B 4
bss_end:
                ENDC

                END
;-------------------------------------------------------------------------------
                END

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; init
                jsr     VQ_PLAYER       ; Init VQ Audio all


                moveq   #__set_replay_free,D0
                movea.l MUSIC.w,A0
                jsr     __set_replay_mode(A0)

                moveq   #__set_replay_fast,D0
                movea.l MUSIC.w,A0
;;  jsr     __set_replay_mode(A0)


                bsr     set_replay_ext

                ENDC
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

                IFNE TEST
;-------------------------------------------------------------------------------
                jsr     VQ_PLAYER
VQ_PLAYER:
                PATH 'C:\0NEW\TDOME\0VQSPL.ST\'
;;  IBYTES 'VQAUDIO.PRG'
                EVEN
;-------------------------------------------------------------------------------
                ENDC
                END
