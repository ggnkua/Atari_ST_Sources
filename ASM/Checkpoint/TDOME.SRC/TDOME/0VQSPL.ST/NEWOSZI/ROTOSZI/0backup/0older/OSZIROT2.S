;-------------------------------------------------------------------------------
; Audio-VQ-Decoder
; ----------------
; (w)2014 lsl/checkpoint
; based on the ideas by Algorithm/Onslaught (C-64)
;-------------------------------------------------------------------------------
;
; Plane30 - technique
; EOR-Filled Oszi
; New Oszi-effect - scrolling histrogramm!
;
; full bitstream implementation(codebook embedded in stream)
;
; fast ym-sample-replay
;
; max. optimized vq-decoding
;
; semi-adaptive, multi-codebooks
;
;-------------------------------------------------------------------------------
CODE_BOOKS      EQU 8
CBOOK           EQU 1024
BLOCK_SIZE      EQU 8
;-------------------------------------------------------------------------------
TEST            EQU 1
                OUTPUT 'VQOSZI.PRG'
;-------------------------------------------------------------------------------
                OPT D+
                >PART
                clr.l   -(SP)
                move.w  #$0020,-(SP)
                trap    #1

                move    #$2700,SR
                clr.l   $FFFFFA06.w
                clr.l   $FFFFFA12.w
                bclr    #3,$FFFFFA17.w

                lea     stack,SP

                movem.l zero,D0-D7
                movem.l D0-D7,$FFFF8240.w

                bsr     init_screens

                move.l  #cnt_vbl,$00000070.w
                move    #$2300,SR

                bsr     wait_vbl
                bsr     wait_vbl
                clr.b   $FFFF8260.w
                move.b  #2,$FFFF820A.w

                lea     rte(PC),A0
                move.l  A0,$00000060.w
                move.l  A0,$00000068.w

                clr.b   $FFFFFA19.w     ;TA Control
                move.b  #255,$FFFFFA1F.w ;TA Data

                clr.b   $FFFFFA1B.w     ;TB Control
                move.b  #255,$FFFFFA21.w ;TB Data

; enable Timer A IRQ
                bset    #5,$FFFFFA07.w
                bset    #5,$FFFFFA13.w

                ENDPART

*   jsr     instr_cycle     *********************

                bsr     Init_Oszi

;-------------------------------------------------------------------------------
                bsr     init_ym_table_optimum
                bsr     init_soundchip

                bsr     Init_VQ_Decoder
;-------------------------------------------------------------------------------

init_timer_b:
                move.l  #rte,$00000120.w
                clr.b   $FFFFFA1B.w
                bset    #0,$FFFFFA07.w  ;Timer B
                bset    #0,$FFFFFA13.w  ;Timer B


*   DC.L $4AFC4E71

                lea     bitstream,A0
                bsr     VQ_Init

                bsr     wait_vbl

                move.l  #vq_decoder,sub_vbl
;D7
;A4...sample_pointer
;A5...ym_table
;A6...$FF8800
                lea     sound_buffer0,A4
                lea     ym_table_optimum,A5
                lea     $FFFF8800.w,A6

                move.l  #vbl,$00000070.w

                lea     play_sample_8bit(PC),A0

                lea     play_sample_fast_HBL(PC),A0

                move.l  A0,$00000068.w

*    move.l  A0,$00000134.w
*    clr.b   $FFFFFA19.w
*    move.b  #32,$FFFFFA1F.w
*    move.b  #%00000001,$FFFFFA19.w

                move    #$2100,SR

                bsr     wait_vbl

                movem.l colors0,D0-D6/A0
                movem.l D0-D6/A0,$FFFF8240.w

*    movem.l regs,D0-A6

loop:
                bsr     swap_screens
                bsr     wait_vbl

                move.w  #$0110,$FFFF8240.w

                bsr     clear_eor_buffer
                bsr     oszi
                bsr     output_eor_buffer

                move.w  #$0007,$FFFF8240.w

                move.b  $FFFFFC02.w,D0
                cmp.b   #$62,D0
                bne.s   n62
                move.w  #$0007,$FFFF8240.w
n62:
                cmp.b   #$39,D0
                bne.s   loop
                DC.L $4AFC4E71
                bra.s   loop

regs:
                DS.L 32,$AAAAAAAA

; A0-->A1
convert_to_ym_values:>PART

; evtl. langt 1 LONG pointer aus?  (Spectrum cycles!!!)
; ist schneller!

                lea     ym_table_optimum,A2
                REPT 314
                moveq   #0,D0
                move.b  (A0)+,D0
                lsl.w   #3,D0
                lea     (A2),A3
                adda.w  D0,A3
                move.l  A3,(A1)+        ; pointer

*     move.l  (A3)+,(A1)+
*     move.l  (A3)+,(A1)+
                ENDR

                rts
                ENDPART


swap_screens:   >PART
                movem.l screen0(PC),D0-D1
                exg     D0,D1
                movem.l D0-D1,screen0
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts
                ENDPART

sample_buffPtr: DC.L sound_buffer0,sound_buffer1


stream_pos:
                DC.L bitstream

spl_play_ptr:   DC.L 0
spl_work_ptr:   DC.L 0

vq_decoder:     PART

                movea.l spl_work_ptr(PC),A1
                bsr.s   vqd_main
                rts
; A1...dest
vqd_main:       >PART

*  DC.L $4AFC4E71

                movea.l stream_pos(PC),A0
                movea.l codebook_currentPtr(PC),A2
                bsr     vq_decode_40

                subq.w  #1,codebook_new_counter
                bcc.s   no_new_codebook
                bsr.s   get_new_codebook
no_new_codebook:
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
; A0...stream
get_new_codebook:>PART

*   DC.L $4AFC4E71

                move.w  current_codebook(PC),D0
                addq.w  #1,D0

                cmp.w   #CODE_BOOKS,D0
                blt.s   gnc_next_book
                move.w  codebook_new_freq(PC),D2
                move.w  D2,codebook_new_counter
                rts
gnc_next_book:
                move.w  D0,current_codebook

                bsr.s   init_stream

                move.w  codebook_new_freq(PC),D2
                move.w  D2,codebook_new_counter
                rts
                ENDPART
;-------------------------------------------------------------------------------
current_codebook:DC.W 0
codebook_new_counter:DC.W 0
codebook_new_freq:DC.W 0
codebook_currentPtr:DC.L 0
;-------------------------------------------------------------------------------
; A0...stream
init_stream:    >PART

                move.l  (A0)+,D0        ; ID  "BLCK"
                move.l  (A0)+,D0        ; codebook_new_counter
                subq.w  #1,D0
                move.w  D0,codebook_new_counter
                move.w  D0,codebook_new_freq

                move.l  A0,codebook_currentPtr
                lea     (A0),A2
                lea     CBOOK*BLOCK_SIZE(A0),A0

                move.l  (A0)+,D0        ; ID  "MAP!"
                move.l  A0,stream_pos
                rts
                ENDPART
;-------------------------------------------------------------------------------
; A0...stream
VQ_Init:        >PART

*  DC.L $4AFC4E71

                bsr.s   init_stream

                clr.w   current_codebook
                rts
                ENDPART
;-------------------------------------------------------------------------------
VQ_Restart:     >PART
                lea     bitstream,A0
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
                rts
                ENDPART
vq_decode_t0:   >PART ' decoder template '

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
vq_decode_40:   DS.B 1024
;-------------------------------------------------------------------------------



;-------------------------------------------------------------------------------
wait_vbl:       >PART
                clr.l   $00000466.w
wv:             tst.l   $00000466.w
                beq.s   wv
                rts
                ENDPART
;-------------------------------------------------------------------------------

rand_col_oben:  DC.W $0011
rand_col_unten: DC.W $0011
col_mitte:      DC.W $0000

                move    #$2100,SR
                move.w  D0,-(SP)
                move.w  A4,D0
whbl:
                cmp.w   A4,D0
                beq.s   whbl
                move    #$2700,SR
                move.w  (SP)+,D0

vbl:            PART

                tas.b   vblsem
                bne.s   vbl_locked
                move    #$2700,SR
;-------------------------------------------------------
                movem.l sample_buffPtr(PC),A4/A6
                exg     A4,A6
                movem.l A4/A6,sample_buffPtr
                move.l  A4,sample_replay_address
                move.l  A4,spl_play_ptr
                move.l  A6,spl_work_ptr
                lea     $FFFF8800.w,A6
;-------------------------------------------------------
                bra     no_tb

                move.l  #tb0,$00000120.w
                clr.b   $FFFFFA1B.w
                move.b  #1,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
no_tb:

                move    #$2100,SR

                move.w  rand_col_oben(PC),$FFFF8240.w


                movem.l D0-D6/A0-A3,-(SP)

                move.l  sub_vbl(PC),D0
                beq.s   nos
                movea.l D0,A0
                jsr     (A0)
nos:
                movem.l (SP)+,D0-D6/A0-A3
                clr.b   vblsem
cnt_vbl:
vbl_locked:
                addq.l  #1,$00000466.w
rte:            rte

vblsem:         DC.W 0
sub_vbl:        DC.L 0,0,0,0
                ENDPART

tb0:            PART
                move.w  col_mitte(PC),$FFFF8240.w
                clr.b   $FFFFFA1B.w
                move.b  #199,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                move.l  #tb1,$00000120.w
                rte
                ENDPART
tb1:            >PART
                move.w  rand_col_unten(PC),$FFFF8240.w
                clr.b   $FFFFFA1B.w
                rte
                ENDPART

;D7
;A4...sample_pointer
;A5...ym_table
;A6...$FF8800
play_sample_fast_HBL:
                move    #$2700,SR       ;<-- needed in hbl-code!!
                moveq   #0,D7
                move.b  (A4)+,D7
                lsl.w   #3,D7
                move.l  0(A5,D7.w),(A6)
                move.l  4(A5,D7.w),D7
                movep.l D7,0(A6)
                rte
ps2:
                moveq   #0,D7
                move.b  (A4)+,D7
                lsl.w   #3,D7
                move    USP,A5          ; ym_table
                adda.w  D7,A5
                move.l  (A5)+,(A6)
                move.l  (A5)+,D7
                movep.l D7,0(A6)
                rte


play_sample_8bit:>PART

;; einfach ... UND langsam!!

                move.l  D7,-(SP)
                pea     (A6)
                moveq   #0,D7
sample_replay_address EQU *+2
                move.b  sound_buffer0,D7 ;get sample byte
                lsl.w   #3,D7

                lea     $FFFF8800.w,A6
                move.l  ym_table_optimum(PC,D7.w),(A6)
                move.l  ym_table_optimum+4(PC,D7.w),D7
                movep.l D7,0(A6)
                addq.l  #1,sample_replay_address ; CODE-MODIFIKATION!!

                movea.l (SP)+,A6
                move.l  (SP)+,D7
                rte
                ENDPART
ym_table_optimum:DS.B 256*8


init_ym_table_optimum:>PART
; ym_table:
;   08xx
;   09xx
;   0axx
;   0000      8byte

; umsortieren nach:
;   0808xxxx
;   090AxxXX  8byte
;          DC.L $4AFC4E71

                lea     ym_table,A0
                lea     ym_table_optimum,A1
                moveq   #0,D6
                move.w  #256-1,D7
iyt:
                lea     ym_table,A0
                move.w  D6,D0
*   eori.b  #$80,D0
                sub.b   #$80,D0
                lsl.w   #3,D0
                adda.w  D0,A0


                move.b  (A0)+,D0
                move.b  (A0)+,D1
                move.b  D0,(A1)+
                move.b  D0,(A1)+
                move.b  D1,(A1)+
                move.b  D1,(A1)+

; 09xx 0aXX  --> 09xx0aXX    ... bleigt folglich so.  ha.
                move.b  (A0)+,(A1)+     ;09
                move.b  (A0)+,(A1)+     ;xx
                move.b  (A0)+,(A1)+     ;0a
                move.b  (A0)+,(A1)+     ;XX
                addq.l  #2,A0

                addq.w  #1,D6
                dbra    D7,iyt
                rts
                ENDPART

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
init_screens:   >PART
                move.l  #screen_ram,D0
                clr.b   D0
                move.l  D0,screen0
                add.l   #32000,D0
                move.l  D0,screen1
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                rts
                ENDPART
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;A0 start  A1 end
clear_memory:   >PART
                move.l  A1,D0
                sub.l   A0,D0           ;L„nge
                bmi.s   dont_cm0
                lea     (A1),A6
                movem.l zero,D1-A5      ;13*4 = 52 Bytes

                divu    #52*4,D0
                subq.w  #1,D0
                bmi.s   dont_ml
ml_clr:
                movem.l D1-A5,-(A6)
                movem.l D1-A5,-(A6)
                movem.l D1-A5,-(A6)
                movem.l D1-A5,-(A6)
                dbra    D0,ml_clr
dont_ml:
                swap    D0
                subq.w  #1,D0
                bmi.s   dont_cm0
bt_clr:
                clr.b   -(A6)
                dbra    D0,bt_clr
dont_cm0:
                rts
                ENDPART
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

                movea.l screen1,A0

                lea     (A0),A1
                lea     (A0),A2
                lea     (A0),A3
                lea     (A0),A4
                lea     (A0),A5
                lea     (A0),A6

                moveq   #10,D7

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

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;----------------------------------------- little oszilloscope -----------------
OszY            SET 50          ; height

EOR_BUFFER_OFFSET SET 50*4      ;((100-OszY))*2
;---------------------------------------
OI              SET 1
OSZI_MAX        EQU 4096*OI

INSERT_POS      EQU 512

x0_oszi:        DC.W 0          ; start
x1_oszi:        DC.W 319        ; end

;---------------------------------------
copy_oszi:      >PART

*    movea.l spl_play_ptr(PC),A0
                movea.l spl_work_ptr(PC),A0

                lea     oszi_hist,A1

                move.w  o_pos(PC),D0
*  add.w   #319,D0
*  add.w   #OI*320-1,D0

                add.w   #INSERT_POS,D0

                move.w  #OSZI_MAX-1,D1

                and.w   D1,D0
                adda.w  D0,A1           ; dest offset

                lea     ocopy_320+320*2(PC),A2

                sub.w   D0,D1           ; rest length
                cmp.w   #320,D1         ; exceeds bound?
                ble.s   oc_le
                move.w  #320,D1
oc_le:
; end size(wrap)
                move.w  #320,D2
                sub.w   D1,D2

                add.w   D1,D1
                add.w   D2,D2
                neg.w   D1
                neg.w   D2
                jsr     0(A2,D1.w)

                lea     oszi_hist,A1    ; wrap!
                jmp     0(A2,D2.w)
ocopy_320:
                REPT 320
                move.b  (A0)+,(A1)+
                ENDR
                rts
                ENDPART
;---------------------------------------
oszi:           >PART

                bsr.s   do_oszi

* addi.w  #23,o_pos       ; 23

                addi.w  #10,o_pos

                rts

o_pos:          DC.W 0

do_oszi:
                bsr     copy_oszi

                lea     oszi_hist,A0
                move.l  A0,D5

                move.w  o_pos(PC),D2
                move.w  #OSZI_MAX-1,D3
                and.w   D3,D2

*   DC.L $4AFC4E71

                lea     values,A3       ; ZZ, Oszi values
                bsr.s   oszi_set_values
                rts
oszi_set_values:
                lea     eor_buffer+100*4,A2

di0             SET 2
di1             SET -2+200*4
                move.l  #(di1<<16)|di0,D4

                move.w  x0_oszi(PC),D0
                lsl.w   #3,D0
                lea     x_table_eor,A1
                adda.w  D0,A1
                move.w  (A1)+,D1        ; pixel
                adda.w  (A1)+,A2        ; Offset eor_buffer
                move.l  (A1)+,D4        ; X_INC eor_buffer

                lea     oszi_code_pointers,A1
                movem.w x0_oszi(PC),D5-D6
                sub.w   D5,D6           ; length
                lsl.w   #2,D6
                move.l  0(A1,D6.w),-(SP)

                lea     y_tab_scaled,A1
                rts                     ; start filling!
oszi_set_x_start:
                REPT 320
; D0    value
; D1    pix
; D2,D3 pos
; D4    X_INC eor_buffer
;
; A0    oszi
; A1    y_tab
; A2    eor_buffer
; A3    values
                move.w  (A3)+,D0        ; ZZ|FE
                add.w   (A3)+,D2        ; Oszi Pos increment

                and.w   D3,D2
                and.b   0(A0,D2.w),D0   ; read sample & MASK $FE !

                move.w  0(A1,D0.w),D0   ; y scale

                eor.w   D1,0(A2,D0.w)   ; set pixel
                neg.w   D0
                eor.w   D1,0(A2,D0.w)   ; set pixel

                ror.w   #1,D1           ; next pix
                bcc.s   *+4
                adda.w  D4,A2           ; X_INC eor_buffer
                swap    D4
                ENDR
oszi_set_x_end:
oszi_code_size  SET (oszi_set_x_end-oszi_set_x_start)/320
                rts


xinc:           DC.L 0
xi2:            DC.L 0

                ENDPART

; ZZxx               (Y)
; Oszi Pos increment (U)
values:         DS.W 320*2

set_values:     >PART

*   DC.L $4AFC4E71

                lea     values,A3

*   move.w  #0,D0           ;  ZZ
*   movea.w #(48*256)/320,A0 ; ZZ_inc

                move.w  #0,D0
                movea.w #0,A0

                moveq   #$FE,D5
                move.w  #320-1,D6
svl:
                move.w  D0,(A3)+
                move.b  D5,-1(A3)       ; masker Y

                move.w  #1,(A3)+        ; Oszi Pos increment

                add.w   A0,D0           ; ZZ inc
                dbra    D6,svl
                rts


                moveq   #0,D5           ;  Z
                movea.w #(48*256)/320,A3 ; Z_inc

                move.w  D2,D6           ; X
                swap    D6
                clr.w   D6

                move.l  #32768,xinc
                move.l  #512,xi2

                rts
                ENDPART

;---------------------------------------
init_x_table_eor:>PART

*   DC.L $4AFC4E71

; .w pixel
; .w Offset eor_buffer
; .l X_INC eor_buffer

                lea     x_table_eor,A0
di0             SET 2
di1             SET -2+200*4
                move.l  #(di1<<16)|di0,D4
                moveq   #0,D0
                move.w  #$8000,D1
                move.w  #320-1,D6
ixte:
                move.w  D1,(A0)+        ; pixel
                move.w  D0,(A0)+        ; Offset eor_buffer
                move.l  D4,(A0)+        ; X_INC eor_buffer
                ror.w   #1,D1
                bcc.s   ixte2
                add.w   D4,D0           ; eor_buffer X inc
                swap    D4
ixte2:
                dbra    D6,ixte
                rts
                ENDPART
;---------------------------------------
init_oszi_code_pointers:>PART
                lea     oszi_code_pointers,A0
                lea     oszi_set_x_end(PC),A1
                move.w  #321-1,D6
soop:
                lea     -oszi_code_size(A1),A1
                move.l  A1,(A0)+
                dbra    D6,soop
                rts
                ENDPART
;---------------------------------------
init_y_tab:     >PART
; -128...+127

*   DC.L $4AFC4E71

                lea     y_tab_scaled,A0

                moveq   #-4,D1
                move.w  #$00FE,D5

yscaleO         SET (256*(OszY-1))/128

                moveq   #64,D3
iytab_scales:
                move.w  #yscaleO,D4
                muls    D3,D4
                asr.l   #6,D4

                move.w  #256-1,D6
iytab2:
                moveq   #127,D0
                sub.w   D6,D0
                move.w  D0,D2           ; for index

                muls    D4,D0           ; *yscale
                asr.l   #8-2,D0
                bpl.s   y_is_pos
                neg.w   D0
y_is_pos:
                cmp.w   #2*4,D0
                bge.s   notMin
                moveq   #1*4,D0
notMin:
                and.w   D1,D0           ; -4 mask
                and.w   D5,D2           ; $00FE  index
                move.w  D0,0(A0,D2.w)   ;

                subq.w  #2,D6
                bpl.s   iytab2

                lea     256(A0),A0
                dbra    D3,iytab_scales

                rts

                ENDPART
;-------------------------------------------------------------------------------
clear_eor_buffer:>PART

*   DC.L $4AFC4E71

                lea     eor_buffer,A3
                lea     EOR_BUFFER_OFFSET(A3),A3
                lea     (20)*200*2(A3),A3

                lea     -100*4(A3),A3   ; adjust

                movem.l zero(PC),D0-D6/A0-A2 ; 10*4 = 40 bytes
                move.w  #320/32-1,-(SP)
ceb3:
; 100 lines * 4 = 400 bytes
                REPT 10         ; 400 bytes
                movem.l D0-D6/A0-A2,-(A3)
                ENDR
                lea     -100*4(A3),A3   ; skip!
                subq.w  #1,(SP)
                bpl.s   ceb3
                addq.l  #2,SP
                rts

                ENDPART
;-------------------------------------------------------------------------------
output_eor_buffer:>PART

*    DC.L $4AFC4E71

*    movea.l spl_work_ptr(PC),A0
*    lea     eor_buffer,A0
*    move.w  #$0FF0,3*2(A0)
*    move.w  #$0FF0,7*2(A0)

                lea     eor_buffer,A0
                lea     EOR_BUFFER_OFFSET(A0),A0

                movea.l screen1(PC),A1
                lea     50*160(A1),A1
                addq.l  #6,A1           ; plane3,0

                move.w  #320/32-1,-(SP)
oeb:
o               SET 0
                movem.l (A0)+,D0-D6
                move.l  D0,(A1)
o               SET o+160
                eor.l   D1,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D2,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D3,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D4,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D5,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D6,D0
                move.l  D0,o(A1)
o               SET o+160
; 7 lines
;--------------------------------------------------
; 100 - 7 = 93
;  93 / 6 = 15, rest 3

                REPT 15
; 6 lines
                movem.l (A0)+,D1-D6
                eor.l   D1,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D2,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D3,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D4,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D5,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D6,D0
                move.l  D0,o(A1)
o               SET o+160
                ENDR
;----------------------------------------------------
                movem.l (A0)+,D1-D3
                eor.l   D1,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D2,D0
                move.l  D0,o(A1)
o               SET o+160
                eor.l   D3,D0
                move.l  D0,o(A1)
o               SET o+160

                lea     100*4(A0),A0    ; skip

                lea     16(A1),A1

                subq.w  #1,(SP)
                bpl     oeb
                addq.l  #2,SP

                rts
                ENDPART
;-------------------------------------------------------------------------------
Init_Oszi:      >PART

                bsr     set_values

                bsr     init_oszi_code_pointers
                bsr     init_x_table_eor
                bsr     init_y_tab      ;y_tab (fr oszi)
                rts
                ENDPART
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                DATA
zero:           DS.L 16

screen0:        DC.L 0
screen1:        DC.L 0

colors0:        >PART

c0              SET $0777
c1              SET $0002
c2              SET $0004

                DC.W $0000

                DC.W c0         ;0
                DC.W c1         ; 1
                DC.W c0         ;01

                DC.W c2         ;  2
                DC.W c0         ;0 2
                DC.W c1         ; 12
                DC.W c0         ;012
                DC.W c0         ;   3

                DC.W c0         ;0  3
                DC.W c0         ; 1 3
                DC.W c0         ;01 3
                DC.W c0         ;  23
                DC.W c0         ;0 23
                DC.W c0         ; 123
                DC.W c0         ;0123
                ENDPART
;----------------------------------------

                PATH 'C:\0NEW\0VQ.SPL\'
                PATH 'ST.BST\'

ym_table:       IBYTES 'YM_TAB.DAT'

bitstream:
                IBYTES 'STR_ALL.DAT'
bitstream_end:
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
                BSS

                >PART ' oszi bss'

x_table_eor:    DS.B 321*8
oszi_code_pointers:DS.L 321
y_tab_scaled:   DS.B (64+1)*256 ; -128...+127, step 2

oszi_hist:      DS.B OSZI_MAX

eor_buffer:     DS.B 200*(320/8) ; 8000 bytes

                ENDPART

sound_buffer0:  DS.B 330
sound_buffer1:  DS.B 330

ym_buffer0:     DS.L 330*2
ym_buffer1:     DS.L 330*2

                DS.B 256
screen_ram:     DS.B 2*32000

                DS.B 512
stack:          DS.B 4
                END
