; xa STE code

; For more information, see xa.txt

;##############################################################################################
;## xa03

;--------------------------------------------------------------
;-- File format
;
;--[ Header ]---------------------------------
;offset 00 - 03  [4 bytes] "xa03" text, 4 bytes
;offset 04       [1 byte] Number of bitplanes in image data
;offset 05       [1 byte] Palette size as 2^x: 4=16 colors, 8=256 colors, 0=truecolor (unused)
;offset 06       [1 byte] Color format: 0=ST/STe, 1=TT, 2=Falcon 6-bit
;offset 07       [1 byte] reserved
;offset 08- 09   [1 word] Offset to directory from absolute 00 of file
;offset 10-      [0, 16, 256 or 512 words] (true color, 4bpl, 8bpl TT and 8bpl Falcon respectively)
;
;--[ Directory ]------------------------------
;offset X - X+1    [1 word] Number of frames (0-65535)
;offset X+2 - X+3  For each frame:
;                    [1 longword] offset from absolute 00 of file
;
;--[ Frame data ]-----------------------------
;offset 00 - 01 [1 word] block id
;offset 02 -    block data


XA_FRAME_RAW_MODE equ $BEEF
XA_FRAME_GGN_MODE equ $6600
XA_FRAME_GGN_PLUS_MODE equ $660D
XA_FRAME_DEFJAM_MODE equ $DEFF
XA_FRAME_PFT_MODE equ $DF70

XA_CMD_GGN_PLUS_CLEAR_LIST equ $FADE
XA_CMD_GGN_PLUS_AREA_END equ $EDED
XA_CMD_GGN_PLUS_BACKGROUND_LIST equ $BACC
XA_CMD_GGN_PLUS_DATA_LIST equ $DA7A

XA_CMD_PFT_SKIP equ $F000 ; actually $F0nn, where nn is number of chunks, nn=0 means read next longword as nn
XA_CMD_PFT_DATA equ $F100
XA_CMD_PFT_CLEAR equ $F200
XA_CMD_PFT_BACKGROUND equ $F300
XA_CMD_PFT_END equ $FF00

COLOR_FORMAT_NUMERIC_STE equ 0
COLOR_FORMAT_NUMERIC_TT equ 1
COLOR_FORMAT_NUMERIC_FALCON equ 2

;##
;##############################################################################################

; 03
xa_image_bitplanes:     dc.w 0
xa_screen_bitplanes:    dc.w 0
xa_image_words:         dc.w 0
xa_screen_words_adder:  dc.w 0
xa_shift_for_skip:      dc.w 0


;###############################################################

; 03
xa_set_params:
; In: d0.l - number of bitplanes in screen mode
;     a0.l - pointer to XA file

  move.w d0,xa_screen_bitplanes
  cmp.b #8,d0
  beq .xa_set_params_8bpl
  cmp.b #4,d0
  beq .xa_set_params_4bpl
  cmp.b #2,d0
  beq .xa_set_params_2bpl
  bra .xa_set_params_1bpl

.xa_set_params_8bpl:
  move.w #4,xa_shift_for_skip
  bra .xa_set_params_bitplanes_done

.xa_set_params_4bpl:
  move.w #3,xa_shift_for_skip
  bra .xa_set_params_bitplanes_done

.xa_set_params_2bpl:
  move.w #2,xa_shift_for_skip
  bra .xa_set_params_bitplanes_done

.xa_set_params_1bpl:
  move.w #1,xa_shift_for_skip
  ;bra .xa_set_params_bitplanes_done

.xa_set_params_bitplanes_done:
  cmp.l #"xa03",(a0)
  bne .xa_set_params_exit
  move.l #0,d1
  move.b 4(a0),d1
  move.w d1,xa_image_bitplanes
  move.w d1,xa_image_words
  sub.w d1,d0
  lsl.w #1,d0
  move.w d0,xa_screen_words_adder

.xa_set_params_exit:
  rts

;###############################################################

; 03
xa_get_number_of_frames:
; In:  a0.l - xa03 data
; Out: d0.l - number of frames

  move.w 8(a0),d0 ; get offset to directory
  move.w (a0,d0),d0 ; get number of frames
  ext.l d0
  sub.l #1,d0
  rts

;###############################################################

; 03
xa_get_palette:
; In: a0.l - xa03 data
;     a1.l - palette destination
  pushall
  move.b 5(a0),d0 ; palette size
  move.b 6(a0),d1 ; color format
  add.l #10,a0
  cmp.b #4,d0
  beq .palette16

  cmp.b #COLOR_FORMAT_NUMERIC_FALCON,d1
  bne .palette256_word
  
.palette256_long:
  move.l #256-1,d7
  bra .copy
.palette256_word:
  move.l #256/2-1,d7
.copy:
  move.l (a0)+,(a1)+
  dbra d7,.copy
  bra .done

.palette16: ; 68000 code, but so small it won't matter on 68030
  movem.l (a0),d0-d7
  movem.l d0-d7,(a1)

.done:
  popall
  rts

;###############################################################

; 03
xa_unpack_one_frame:
; In: a0.l - xa03 data
;     a1.l - screen address
;     a2.l - background screen

  cmp.l #"xa03",(a0)
  bne .skipheader

  move.w 8(a0),d0 ; get offset to directory
  move.l 2(a0,d0),d0 ; get first offset from directory
  add.l d0,a0 ; a0 now points to first frame

.skipheader:
  move.w (a0)+,d0

  cmp.w #XA_FRAME_GGN_PLUS_MODE,d0
  beq .xa_mode_ggn_plus
  
  cmp.w #XA_FRAME_GGN_MODE,d0
  beq .xa_mode_ggn
  
  cmp.w #XA_FRAME_PFT_MODE,d0
  beq .xa_mode_pft

  cmp.w #XA_FRAME_RAW_MODE,d0
  beq .xa_mode_raw

  ;cmp.w #XA_FRAME_DEFJAM_MODE,d0
  ;beq .xa_mode_defjam
  
.unpack_frame_error:
  move.w #$700,$ffff8240
  move.w #$070,$ffff8240
  bra .unpack_frame_error
  
  rts  
  
;###############################################################

.xa_mode_ggn:
; In: a0.l - xa03 data
;     a1.l - screen address

  add.l #32768,a1 ; largest signed word-aligned offset
  move.w (a0)+,d7 ; number of 64K areas
  sub.l #1,d7
.ggn_arealoop:

  if CPU_MODEL_68030 ; if cpu is 030
    move.w (a0)+,d6
    sub.w #1,d6 ; ***** test
.ggn_chunkloop:
      move.w (a0)+,d0
      move.w (a0)+,(a1,d0)
    dbra d6,.ggn_chunkloop
  endif

  if CPU_MODEL_68000 ; if cpu is 000
  ; ***** This is 030 code, unroll for 000! *****
    move.w (a0)+,d6
    sub.w #1,d6
    bmi .ggn_chunkloop_exit
.ggn_chunkloop:
      move.w (a0)+,d0
      ext.l d0
      move.w (a0)+,(a1,d0.l)
    dbra d6,.ggn_chunkloop
    .ggn_chunkloop_exit:
  endif

    add.l #65536,a1

  dbra d7,.ggn_arealoop
  rts

;###############################################################

.xa_mode_ggn_plus:
; In: a0.l - xa03 data
;     a1.l - screen address
;     a2.l - address to background unpacked

  move.l #0,d2
  add.l #32768,a1 ; largest signed word-aligned offset
  add.l #32768,a2
  move.w (a0)+,d7 ; number of 64K areas
  sub.l #1,d7
.ggn_plus_arealoop:

.ggn_plus_get_command:
  move.w (a0)+,d0

  cmp.w #XA_CMD_GGN_PLUS_DATA_LIST,d0
  beq .ggn_plus_data_list

  cmp.w #XA_CMD_GGN_PLUS_CLEAR_LIST,d0
  beq .ggn_plus_clear_list

  cmp.w #XA_CMD_GGN_PLUS_BACKGROUND_LIST,d0
  beq .ggn_plus_background_list

  cmp.w #XA_CMD_GGN_PLUS_AREA_END,d0
  beq .ggn_plus_next_area

  ; ERROR - no valid command
.xa_ggn_plus_bang: ; Code should never end up here
  move.w #$f00,$ffff8240
  move.w #$400,$ffff8240
  bra .xa_ggn_plus_bang


.ggn_plus_data_list:
  if 1=0
  ;ifne 0
    move.l (a0)+,d6
    sub.l #1,d6
    swap d6
.ggn_plus_data_chunkloop_outer:
      swap d6
.ggn_plus_data_chunkloop_inner:
        move.w (a0)+,d0
        move.w (a0)+,(a1,d0.w)
      dbra d6,.ggn_plus_data_chunkloop_inner
      swap d6
    dbra d6,.ggn_plus_data_chunkloop_outer
    bra .ggn_plus_get_command
  endif

  if CPU_MODEL_68030 ; if cpu is 030
  move.w (a0)+,d6
  sub.w #1,d6
.ggn_plus_data_chunkloop:
    move.w (a0)+,d0
    move.w (a0)+,(a1,d0)
  dbra d6,.ggn_plus_data_chunkloop
  endif

  if CPU_MODEL_68000 ; if cpu is 000
  ; ***** This is 030 code, unroll for 000! *****
  move.w (a0)+,d6
  sub.w #1,d6
.ggn_plus_data_chunkloop:
    move.w (a0)+,d0
    move.w (a0)+,(a1,d0)
  dbra d6,.ggn_plus_data_chunkloop
  endif

  bra .ggn_plus_get_command


.ggn_plus_clear_list:
  if 1=0
    move.l (a0)+,d6
    sub.l #1,d6
    swap d6
.ggn_plus_clear_chunkloop_outer:
      swap d6
.ggn_plus_clear_chunkloop_inner:
        move.w (a0)+,d0
        move.w d2,(a1,d0)
      dbra d6,.ggn_plus_clear_chunkloop_inner
      swap d6
    dbra d6,.ggn_plus_clear_chunkloop_outer
    bra .ggn_plus_get_command
  endif


  if CPU_MODEL_68030 ; if cpu is 030
  move.w (a0)+,d6
  sub.w #1,d6
.ggn_plus_clear_chunkloop:
    move.w (a0)+,d0
    move.w d2,(a1,d0)
  dbra d6,.ggn_plus_clear_chunkloop
  endif

  if CPU_MODEL_68000 ; if cpu is 000
  ; ***** This is 030 code, unroll for 000! *****
  move.w (a0)+,d6
  sub.w #1,d6
.ggn_plus_clear_chunkloop:
    move.w (a0)+,d0
    move.w d2,(a1,d0)
  dbra d6,.ggn_plus_clear_chunkloop
  endif


  bra .ggn_plus_get_command


.ggn_plus_background_list:
  if 1=0
    move.l (a0)+,d6
    sub.l #1,d6
    swap d6
.ggn_plus_background_chunkloop_outer:
      swap d6
.ggn_plus_background_chunkloop_inner:
        move.w (a0)+,d0
        move.w (a2,d0),(a1,d0)
      dbra d6,.ggn_plus_background_chunkloop_inner
      swap d6
    dbra d6,.ggn_plus_background_chunkloop_outer
    bra .ggn_plus_get_command
  endif


  if CPU_MODEL_68030 ; if cpu is 030
  move.w (a0)+,d6
  sub.w #1,d6
.ggn_plus_background_chunkloop:
    move.w (a0)+,d0
    move.w (a2,d0),(a1,d0)
  dbra d6,.ggn_plus_background_chunkloop
  endif

  if CPU_MODEL_68000 ; if cpu is 000
  ; ***** This is 030 code, unroll for 000! *****
  move.w (a0)+,d6
  sub.w #1,d6
.ggn_plus_background_chunkloop:
    move.w (a0)+,d0
    move.w (a2,d0),(a1,d0)
  dbra d6,.ggn_plus_background_chunkloop
  endif

    bra .ggn_plus_get_command


.ggn_plus_next_area:
    add.l #65536,a1
    add.l #65536,a2

  dbra d7,.ggn_plus_arealoop
  rts

;###############################################################

; 03
.xa_mode_raw:
; In: a0.l - xa03 data
;     a1.l - screen address

  move.l (a0)+,d7
  ;lsr.l #2,d7
  sub.l #1,d7
  swap d7
.raw_outer_loop:
  swap d7
.raw_inner_loop:
  ;move.l (a0)+,(a1)+
  move.b (a0)+,(a1)+
  dbra d7,.raw_inner_loop
  swap d7
  dbra d7,.raw_outer_loop

  rts

;###############################################################

; 03
.xa_mode_pft:
; In: a0.l - xa03 data
;     a1.l - screen address

.xa_pft_get_block:
  move.w (a0),d0
  cmp.w #XA_CMD_PFT_END,d0
  bne .xa_pft_no_exit
  add.l #2,a0
  bra .xa_pft_exit
.xa_pft_no_exit:

  move.l #0,d7
  move.b 1(a0),d7
  cmp.b #0,d7
  bne .xa_pft_short_form
  bra .xa_pft_long_form
.xa_pft_short_form:
  clr.b d0
  bra .xa_pft_go_on
.xa_pft_long_form:
  ;break
  add.l #2,a0
  move.w (a0),d7
  ext.l d7
  ; At this point, length is in d7
  
.xa_pft_go_on:
  add.l #2,a0
  cmp.w #XA_CMD_PFT_SKIP,d0
  beq .xa_pft_skip
  cmp.w #XA_CMD_PFT_DATA,d0
  beq .xa_pft_data
  cmp.w #XA_CMD_PFT_CLEAR,d0
  beq .xa_pft_clear


.xa_pft_bang: ; Code should never end up here
  move.w #$f00,$ffff8240
  move.w #$400,$ffff8240
  bra .xa_pft_bang


.xa_pft_skip:
  move.w xa_shift_for_skip,d6
  ext.l d6
  lsl.w d6,d7
  add.l d7,a1
  bra .xa_pft_get_block

.xa_pft_data:
  move.w xa_image_bitplanes,d5
  move.w xa_screen_words_adder,d4
  ext.l d5
  sub.l #1,d5
  sub.l #1,d7
.xa_pft_data_loop_outer:
  move.l d5,d6
.xa_pft_data_loop_inner:
  move.w (a0)+,(a1)+
  dbra d6,.xa_pft_data_loop_inner
  add.w d4,a1
  dbra d7,.xa_pft_data_loop_outer
  bra .xa_pft_get_block

.xa_pft_clear:
  move.w xa_screen_bitplanes,d5
  move.w xa_screen_words_adder,d4
  move.l #0,d3
  ext.l d5
  sub.l #1,d5
  sub.l #1,d7
.xa_pft_clear_loop_outer:
  move.l d5,d6
.xa_pft_clear_loop_inner:
  move.w d3,(a1)+
  dbra d6,.xa_pft_clear_loop_inner
  add.w d4,a1
  dbra d7,.xa_pft_clear_loop_outer
  bra .xa_pft_get_block

;.xa_pft_background
;  bra .xa_pft_get_block


.xa_pft_block_done:
  bra .xa_pft_get_block


.xa_pft_exit:
  ;add.l #2,a0 ; go past END marker
  rts


  move.w (a0)+,d7
.pft_block_loop:
  move.w (a0)+,d0

  cmp.w #XA_CMD_PFT_SKIP,d0
  beq .pft_skip

  cmp.w #XA_CMD_PFT_DATA,d0
  beq .pft_data
  
  ; ERROR - bad command word
.xa_pft_bang_2: ; Code should never end up here
  move.w #$f00,$ffff8240
  move.w #$400,$ffff8240
  bra .xa_pft_bang_2

.pft_skip:
  add.w (a0)+,a1
  bra .pft_done

.pft_data:
  move.w (a0)+,d6
.pft_data_loop:
  move.w (a0)+,(a1)+
  dbra d6,.pft_data_loop

.pft_done:
  dbra d7,.pft_block_loop
  rts

;###############################################################
