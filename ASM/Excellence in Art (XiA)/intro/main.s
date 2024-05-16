;  
; 
;
; ToDo
; -----
; # There is a bug in the linebreaking code that causes it not to respect
;   null-termination; it continues parsing, adding linebreaks in strings
;   placed after it in memory. CAN. NOT. BE. ARSED. TO. FIX. NOW.
;   (did horrible fugly workaround)
;
;
; Done
; -----
; # Lightpath_xa: choose slightly darker color for text
; # Lots of stuff
;

  .text

;print ""

macro fail errorstring
  print "---[ FATAL ERROR ]---------------------------------------------"
  print \{errorstring}
  print ""
  .error
endm

;//////////////////////////////////////////////////////////////////////////////////////////////
;// In the name of all that is holy and just, don't change these!!

CPU_MODEL_68030=0
CPU_MODEL_68000=1

;// In the name of all that is holy and just, don't change these!!
;//////////////////////////////////////////////////////////////////////////////////////////////

STEEM_DEBUG_ENABLE equ 1

PRINTVAL_ENABLE equ 0

MUSIC_ENABLE equ 1
SPEED_UP_SYSTEM_TEST equ 0

DO_SYSTEM_TEST equ 1
SYSTEM_TEST_USE_PROPFONT equ 1 ; requires propfont, obviously

if PRINTVAL_ENABLE
  PRINTVAL_VALUEBUFFER_SIZE set 5
  PRINTVAL_VALUEBUFFER_SIZE_MAX set 16
endif

if SYSTEM_TEST_USE_PROPFONT
  f set 0
  PROPFONT_FONT_PER02=f
  f set f+1
  PROPFONT_FONT_PER=f
  f set f+1
  PROPFONT_FONT_MV_BOLI=f
  f set f+1
  PROPFONT_FONT_PALATINO=f
  f set f+1
  PROPFONT_FONT_CALIBRI_LIGHT=f
  f set f+1
  PROPFONT_FONT_MACINTOSH_1984=f
  f set f+1
  PROPFONT_FONT_ZX_SPECTRUM=f
  f set f+1
  PROPFONT_FONT_MSX=f
  f set f+1
  PROPFONT_FONT_ATARI_8BIT=f
  f set f+1
  
  PROPFONT_FONT_SELECT=PROPFONT_FONT_CALIBRI_LIGHT ;PROPFONT_FONT_ZX_SPECTRUM
endif

RASTERS_ENABLE equ 1
ICE_ENABLE	equ 0
ARJ_ENABLE	equ 0
XA_ENABLE equ 1
PIXELS_ENABLE equ 0
MATH_ENABLE equ 0
PALETTE_FADING_ENABLE equ 1
PROPFONT_ENABLE equ 1
DMA_SOUND_ENABLE equ 1

FILE_LOAD_ENABLE equ 1

HBL_ENABLE equ 0
MEGASTE_ENABLE equ 1
TIMER_C_DISABLE_ON_STARTUP equ 0  ; This places a blank RTE on $114, disabling timer C safely.
                                  ; To re-enable at runtime, use macros "timerc_on" and "timerc_off"


BLITOP_OR  equ %00000111
BLITOP_XOR equ %00000110
BLITOP_AND equ %00000001
BLITOP_NOT equ %00000100

;///////////////////////////////////////////////////////////////
;// system test

SYSPRINT_ENABLE set 0
PROPFONT_ENABLE set 0

if DO_SYSTEM_TEST
  SYSPRINT_ENABLE set 1
  if SYSTEM_TEST_USE_PROPFONT
    PROPFONT_ENABLE set 1
  endif
endif

;// system test
;///////////////////////////////////////////////////////////////
;// propfont
if PROPFONT_ENABLE

  PROPFONT_FONTHEIGHT equ 14 ; pixels per line in font
  PROPFONT_FONTSPACEWIDTH equ 4 ; width of space char
  PROPFONT_FONTCHARSLINES equ 11 ; 13 ; lines of chars in font
  PROPFONT_FONTCHARSPERLINE equ 10 ; chars per line in font
  PROPFONT_FONTWIDTHCONVERTERTABLESIZE equ 17 ; value pairs in table

endif
;// propfont
;///////////////////////////////////////////////////////////////
;// DMA sound
if DMA_SOUND_ENABLE

  ; $ffff8921.b:
  DMA_RATE_ADDRESS equ $ffff8921
  DMA_6KHZ_STEREO  equ 0
  DMA_6KHZ_MONO    equ 128
  DMA_12KHZ_STEREO equ 1
  DMA_12KHZ_MONO   equ 129
  DMA_25KHZ_STEREO equ 2
  DMA_25KHZ_MONO   equ 130
  DMA_50KHZ_STEREO equ 3
  DMA_50KHZ_MONO   equ 131
  
  ; $ffff8900.w:
  DMA_PLAY_ADDRESS   equ $ffff8901
  DMA_START_LOOP_ON  equ 3
  DMA_START_LOOP_OFF equ 1
  DMA_STOP           equ 0
  
  DMA_SAMPLE_START_ADDRESS equ $ffff8901 ; must be movep.l
  DMA_SAMPLE_END_ADDRESS   equ $ffff890d ; must be movep.l
  
  
  macro dma_play ratecode, startcode, start, end
  ; Usage: dma_play ratecode startcode start end
    pushd0
    pusha0
    pusha1
    lea \{start},a0
    move.l a0,d0
    move.l #DMA_SAMPLE_START_ADDRESS,a1
    movep.l d0,(0,a1)
    lea \{end},a0
    move.l a0,d0
    move.l #DMA_SAMPLE_END_ADDRESS,a1
    movep.l d0,(0,a1)
    move.b #\{ratecode},DMA_RATE_ADDRESS
    move.b #\{startcode},DMA_PLAY_ADDRESS
    popa1
    popa0
    popd0
  endm
  
  
  macro dma_set_start start
  ; Usage: dma_set_start start
    pushd0
    pushd1
    pusha0
    pusha1
    move.b DMA_PLAY_ADDRESS,d1
    swap d1
    lsl.l #8,d1
    and.l #$ff000000,d1
    lea \{start},a0
    move.l a0,d0
    or.l d1,d0
    move.l #DMA_SAMPLE_START_ADDRESS,a1
    movep.l d0,(0,a1)
    popa1
    popa0
    popd1
    popd0
  endm
  
  
  macro dma_stop
    move.b #DMA_STOP,DMA_PLAY_ADDRESS
  endm

endif
;// DMA sound
;///////////////////////////////////////////////////////////////
;// File loading
if FILE_LOAD_ENABLE

  macro loadfile file
  ; Usage: loadfile [label]
  ; Requires: label: [label]_filename - address to zero-terminated string
  ;                                     containing filename with full path
    lea \{file}_filename,a0
    lea \{file},a1
    jsr file_load_loadfile
    tst.l d0
    beq .noerror\~
    jmp file_load_error
  .noerror\~:
  endm
  
  macro file_load_addpath
    dc.b "xmas2015.d8a\\\\"
  endm
  
  macro file_load_place_filename file
  ; Usage: file_load_place_filename macro macro [filename in quotes]
    file_load_addpath
    dc.b \{file}
    dc.b 0
    even
  endm

endif
;// File loading
;///////////////////////////////////////////////////////////////
;// ARJ mode 7
if ARJ_ENABLE

  macro dearjlealea
  	pushall
  	move.l #\1size,d0
  	lea \1,a1
  	lea \2,a0
  	jsr dearj
  	popall
  endm
  
  macro dearjleascreen
  	pushall
  	move.l #\1size,d0
  	lea \1,a1
  	move.l screenaddress,a0
  	jsr dearj
  	popall
  endm

endif
;// ARJ mode 7
;///////////////////////////////////////////////////////////////

if SYSPRINT_ENABLE

  macro sysprint_a1
    move.l screenaddress,a0
    if PROPFONT_ENABLE
      bsr propfont_draw_string
    else
      bsr sysprint_print_string
    endif
  endm
  
  
  macro sysprint_a1_linebreak
    move.l screenaddress,a0
    if PROPFONT_ENABLE
      bsr propfont_draw_string_with_linebreak
    else
      bsr sysprint_print_string
    endif
  endm
  
  
  macro sysprint string
    lea \{string},a1
    sysprint_a1_linebreak
  endm

  macro sysprint2 string
    lea \{string},a1
    sysprint_a1
  endm


  macro sysprint_with_linebreak string
    lea \{string},a1
    sysprint_a1
  endm


  if PRINTVAL_ENABLE

    macro sysprint_dec number
      pushall
      move.l \{number},d0
      bsr printval_d0_dec
      popall
    endm
    
    macro sysprint_hex number
      pushall
      move.l \{number},d0
      bsr printval_d0_hex
      popall
    endm

  endif ; if PRINTVAL_ENABLE

endif ; if SYSPRINT_ENABLE


macro megaste_on
  if MEGASTE_ENABLE
    jsr turn_megaste_features_on
  endif
endm


macro megaste_off
  if MEGASTE_ENABLE
    jsr turn_megaste_features_off
  endif
endm


macro timerc_on
	move.w sr,-(sp)
	or.w #$0700,sr
  move.l save_timer_c,$114.w	
	move.w (sp)+,sr
endm


macro timerc_off
	move.w sr,-(sp)
	or.w #$0700,sr
	move.l #timer_c,$114
	move.w (sp)+,sr
endm


macro break
  iif STEEM_DEBUG_ENABLE, clr.b $ffffc123
endm


macro markcurrentscanline
  pushd7
  ;eor.w #$ffff,$ffff8240
  not.w $ffff8240
  move.l #30,d7
  .loopalittle\~:
    nop
  dbra d7,.loopalittle\~
  ;eor.w #$ffff,$ffff8240
  not.w $ffff8240
  popd7
endm


macro swap_screens
  jsr swapscreens
endm


macro clear_screen
  jsr clearscreen
endm


macro clear_screen_no_blitter
  jsr clearscreennoblitter
endm


macro clear_smokescreen
  jsr clearsmokescreen
endm


macro clear_smokescreen_no_blitter
  jsr clearsmokescreennoblitter
endm


macro clear_1bpl
; In: a0.l - pointer to bitplane to clear
  jsr clear1bpl
endm


macro clear_1bpl_no_blitter
; In: a0.l - pointer to bitplane to clear
  jsr clear1bplnoblitter
endm


macro nops number
  dcb.w \number{},$4e71
endm


if ICE_ENABLE
  macro deicelealea
  	movem.l a0/a1,-(sp)
  	lea \1,a0
  	lea \2,a1
  	jsr deice
  	movem.l (sp)+,a0/a1
  endm
endif


macro backcol
	move.w #\1,currentpalette
	move.w #\1,$ffff8240
endm


macro vblwait frames
; Usage: vblwait [number of frames to wait, minimum 1]
	if \{frames}<1 ; disallow values lower than 1
	  fail "Macro vblwait needs parameter"
	endif
	pushd0
	move.l #\{frames}-1,d0
	bsr wait4vbld0
	popd0
endm


macro setpalette palette
	pusha0
	lea \{palette},a0
	bsr setpalettenextframe
	popa0
endm


if PALETTE_FADING_ENABLE
  macro fade2palette palette, frames
  ; Usage: fade2palette [address to palette] [number of frames between steps, minimum 1]
  	if \{frames}<1 ; disallow values lower than 1
    	fail "Macro fade2palette: Second parameter cant be lower than 1"
  	endif
  	movem.l a0/d0,-(sp)
  	lea \{palette},a0
  	move.l #\{frames}-1,d0
  	bsr fadepalettesaesthetic
  	movem.l (sp)+,a0/d0
 	endm
endif


macro copy32klealeanoblit source, dest
	pusha0
	pusha1
	lea \{source},a0
	lea \{dest},a1
	bsr copy32000noblitter
	popa1
	popa0
endm


macro copy32ktoscreenleanoblit source
	pusha0
	pusha1
	lea \{source},a0
	move.l screenaddress,a1
	bsr copy32000noblitter
	popa1
	popa0
endm


macro cleartimer
	move.w #0,vblwaiter
endm


macro waitfortimer time
	pushd0
	move.w #\{time},d0
	bsr waitforvblwaiter
	popd0
endm


macro putstring string
  dc.b \{string}
  dc.b 0
  even
endm


macro putstring_with_cr string
  dc.b \{string}
  dc.b 13,0
  even
endm


macro putstring_with_2cr string
  dc.b \{string}
  dc.b 13,13,0
  even
endm


macro putstring_no_null string
  dc.b \{string}
  even
endm


macro vblinstall
  pusha0
  lea \1,a0
  move.l a0,vblextra
  popa0
endm


macro vbluninstall
  vblinstall blank_vbl
endm



;----------------------------------------------------------------------------------------------

;///////////////////////////////////////////////////////////////
;// Snowflake stuffs

NUM_SNOWFLAKES equ 12

SNOWFLAKE_LARGE equ 0
SNOWFLAKE_MEDIUM equ 1
SNOWFLAKE_SMALL equ 2
SNOWFLAKE_EXTRA_SMALL equ 3

  .abs
; snowflake struct
  size: ds.w 1
  frame: ds.l 1 ; shifted up 4 steps
  framestep: ds.l 1  ; shifted up 4 steps
  xpos: ds.l 1 ; shifted up 4 steps
  ypos: ds.l 1 ; shifted up 4 steps
  xstep: ds.l 1 ; shifted up 4 steps
  ystep: ds.l 1 ; shifted up 4 steps
  .text
  SNOWFLAKE_STRUCT_SIZE equ ^^abscount

SNOWFLAKE_LARGE_WORDWIDTH equ 13+1
SNOWFLAKE_LARGE_PIXELWIDTH equ 196
SNOWFLAKE_LARGE_HEIGHT equ 198

SNOWFLAKE_MEDIUM_WORDWIDTH equ 8+1
SNOWFLAKE_MEDIUM_PIXELWIDTH equ 121
SNOWFLAKE_MEDIUM_HEIGHT equ 116

SNOWFLAKE_SMALL_WORDWIDTH equ 4+1
SNOWFLAKE_SMALL_PIXELWIDTH equ 57
SNOWFLAKE_SMALL_HEIGHT equ 57

SNOWFLAKE_EXTRA_SMALL_WORDWIDTH equ 3
SNOWFLAKE_EXTRA_SMALL_PIXELWIDTH equ 30
SNOWFLAKE_EXTRA_SMALL_HEIGHT equ 30

SNOWFLAKE_LARGE_BYTESIZE equ 2*SNOWFLAKE_LARGE_WORDWIDTH*SNOWFLAKE_LARGE_HEIGHT ; 196x198, 13+1 words wide
SNOWFLAKE_MEDIUM_BYTESIZE equ 2*SNOWFLAKE_MEDIUM_WORDWIDTH*SNOWFLAKE_MEDIUM_HEIGHT ; 121x116, 8+1 words wide
SNOWFLAKE_SMALL_BYTESIZE equ 2*SNOWFLAKE_SMALL_WORDWIDTH*SNOWFLAKE_SMALL_HEIGHT ; 57x57, 2+1 words wide
SNOWFLAKE_EXTRA_SMALL_BYTESIZE equ 2*SNOWFLAKE_EXTRA_SMALL_WORDWIDTH*SNOWFLAKE_EXTRA_SMALL_HEIGHT ; 30x30, 2+1 words wide

;// Snowflake stuffs
;///////////////////////////////////////////////////////////////

hugescreenlinewidth equ (208+320+208)/2


macro do_anim_huge markers
  pusha0
  move.l timing_marker_pos,a0
  move.l #\{markers}-1,d7
.marker\~:
  move.w (a0)+,d0
  move.l a0,timing_marker_pos
  ext.l d0
  cmp.l #-1,d0
  beq .done\~
  bsr waitforframe
  bsr flip_hugebuffer
  ;add.w #111,currentpalette
  dbra d7,.marker\~
.done\~:
  popa0
endm



macro wait_then_replace_santa_buffers wait, buffer0, buffer1
  move.l #\{wait},d0
  bsr wait4vbld0
  setpalette allgreenpal
  vblwait 1
  vbluninstall
  ;setup_huge_buffers santa_2a, santa_2b
    lea \{buffer0},a0
    bsr copy_to_huge_buffer
    bsr flip_hugebuffer
    lea \{buffer1},a0
    bsr copy_to_huge_buffer
    bsr flip_hugebuffer  
  vblinstall snowflakes_vbl_wrapper
  setpalette santapal_grafx2
endm


macro setup_huge_buffers buffer0, buffer1
  lea \{buffer0},a0
  bsr copy_to_huge_buffer
  bsr flip_hugebuffer
  lea \{buffer1},a0
  bsr copy_to_huge_buffer
  bsr flip_hugebuffer
endm


macro setup_santa_buffers buffer0, buffer1
  pushall
  lea \{buffer0},a0
  lea \{buffer1},a1
  bsr setup_santa_buffers_subroutine
  popall
endm

macro setup_snowflake_buffers buffer0, buffer1
  pushall
  lea \{buffer0},a0
  lea \{buffer1},a1
  bsr setup_snowflake_buffers_subroutine
  popall
endm


macro unpack_snowflakes xa, dest, wordwidth, height
  lea \{xa},a0
  lea \{dest},a1
  move.l #\{wordwidth},d4
  move.l #\{height},d5
  bsr unpacksnowflakes  
endm



macro flipscreens screen0, screen1
  pusha0
  eor.w #$ffff,.screennumber\~
  tst.w .screennumber\~
  bne .not0\~
  lea \{screen0},a0
  bra .goon\~
.not0\~:
  lea \{screen1},a0
.goon\~:
  move.l a0,screenaddress
  popa0
  bra .past\~
.screennumber\~:
  dc.w 0
.past\~:
endm


macro unpack_image xafile, buffer0, buffer1
  lea \{xafile},a0
  lea \{buffer0},a1
  bsr xa_unpack_one_frame
  pusha0
  copy32klealeanoblit \{buffer0}, \{buffer1}
  popa0
  lea \{buffer1},a1
  bsr xa_unpack_one_frame
endm


macro do_anim markers, palette, screen0, screen1
  move.l #\{markers}-1,d7
.marker\~:
  move.w (a0)+,d0
  ext.l d0
  cmp.l #-1,d0
  beq .done\~
  bsr waitforframe
  setpalette \{palette}
  flipscreens \{screen0}, \{screen1}
  dbra d7,.marker\~
.done\~:
endm


;///////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////
;  Start of code

	include "_inc/pushpop.s"

	jmp gogogoforitgogogo
	dc.b "  Per Almered/Excellence In Art 2015  "
	dc.b "--  Based in part on the DHS demosystem  "
	even
gogogoforitgogogo:

	lea smokescreen1,a0
	move.l a0,d0
	clr.b d0
	move.l d0,a0
	move.l a0,screenaddress
	add.l #32000,a0
	move.l a0,smokescreenaddress
	bsr clearsmokescreennoblitter
	bsr swapscreens
	bsr clearsmokescreennoblitter

  ; supervisor mode
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,oldusp

	lea blank_vbl,a0
	move.l a0,vblextra

  if DO_SYSTEM_TEST
    bsr systemtest
  endif

	include "_inc/start.s"

  megaste_on
	
	bsr resetblitter

;///////////////////////////////////////////////////////////
;//
;// Let`s go!

  bsr initall
  
  if DO_SYSTEM_TEST
    ; show bios logo
    lea bios_logo_xa,a0
    move.l screenaddress,a1
    bsr xa_unpack_one_frame    
    ; print
    bsr systemtest_print

    ; load assets
    ;break
    sysprint txt_loading_music
    loadfile music0
    loadfile music1
    ;sysprint txt_done
    ;iif SPEED_UP_SYSTEM_TEST=0, vblwait 10

    ;sysprint txt_loading_pixels
    loadfile snowflake_large_xa
    loadfile snowflake_medium_xa
    loadfile snowflake_small_xa
    loadfile snowflake_extra_small_xa
    loadfile snowflake_tilt_xa
    sysprint txt_done
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 10
    
    ; generate snowflakes
    ;sysprint txt_precalc1
    sysprint txt_loading_pixels
    unpack_snowflakes snowflake_large_xa, snowflake_large_all, SNOWFLAKE_LARGE_WORDWIDTH, SNOWFLAKE_LARGE_HEIGHT
    sysprint2 txt_done
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 10

    ;sysprint2 txt_precalc2
    sysprint2 txt_precalc1
    unpack_snowflakes snowflake_medium_xa, snowflake_medium_all, SNOWFLAKE_MEDIUM_WORDWIDTH, SNOWFLAKE_MEDIUM_HEIGHT
    unpack_snowflakes snowflake_small_xa, snowflake_small_all, SNOWFLAKE_SMALL_WORDWIDTH, SNOWFLAKE_SMALL_HEIGHT
    unpack_snowflakes snowflake_extra_small_xa, snowflake_extra_small_all, SNOWFLAKE_EXTRA_SMALL_WORDWIDTH, SNOWFLAKE_EXTRA_SMALL_HEIGHT
    sysprint txt_done
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 10
    
    ; blank out screen
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 35
    if SPEED_UP_SYSTEM_TEST
      setpalette allgreenpal
    else
      fade2palette allgreenpal, 2
    endif
    bsr clearscreen
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 25
    iif PROPFONT_ENABLE, bsr propfont_reset_cursor
  endif

  megaste_off

  ;fade2palette allgreenpal, 2
  ;setpalette testpal
  ;setpalette allblackpal
  ;vblwait 1

  bsr snowflakes_init

  ; set screen width
  move.b $ffff820f,old_820f
  move.b #((272-160)/2),$ff820f
  
  ; Unpack images
  unpack_image santa1_xa, santa_1a, santa_1b
  unpack_image santa2_xa, santa_2a, santa_2b
  unpack_image santa3_xa, santa_3a, santa_3b
  unpack_image santa4_xa, santa_4a, santa_4b

  ;lea santa1_xa,a0
  ;lea santapal,a1
  ;bsr xa_get_palette
  
  ;setpalette santapal
  ;setpalette santapal_grafx2

  bsr flip_hugebuffer

  setup_huge_buffers santa_1a, santa_1b



;//////////////////////////////////////////////////////////////
;// Set up flipscreen stuff

  setup_santa_buffers hugescreenbuffer0, hugescreenbuffer1

  setup_snowflake_buffers hugescreenbuffer0, hugescreenbuffer1

  ;extra flip
  bsr swapscreens_snowflakes_only
  
;// Set up flipscreen stuff
;//////////////////////////////////////////////////////////////

  setpalette santapal_grafx2

  ; start audio
  if MUSIC_ENABLE
    dma_play DMA_25KHZ_STEREO, DMA_START_LOOP_ON, music_start, music_end  
  endif
  move.l #0,framecounter

  vblinstall snowflakes_vbl_wrapper

  ;break
  lea timing_markers,a0
  move.l a0,timing_marker_pos

  do_anim_huge 16

  wait_then_replace_santa_buffers 28, santa_2a, santa_2b  
  move.w #1,render_medium_snowflakes

  do_anim_huge 18

  wait_then_replace_santa_buffers 28, santa_1a, santa_1b

  do_anim_huge 8

  wait_then_replace_santa_buffers 28, santa_3a, santa_3b
  move.w #1,render_large_snowflakes

  do_anim_huge 8

  wait_then_replace_santa_buffers 28, santa_4a, santa_4b

  do_anim_huge 8

  wait_then_replace_santa_buffers 3, santa_2a, santa_2b

  do_anim_huge 10
  
  vblwait 40

  fade2palette santapal_only_snowflakes,4
  
  move.l screenaddress,a0
  bsr clear1bpl_hugescreen  
  move.l screenaddress,a0
  add.l #2,a0
  bsr clear1bpl_hugescreen  
  move.l screenaddress,a0
  add.l #4,a0
  bsr clear1bpl_hugescreen  
  
  vblwait 120
  
  fade2palette nightly_snowflakespal,4

  vblwait 150

  fade2palette allblackpal,4
  
; all black screen

  vbluninstall

  move.b old_820f,$ffff820f
  
	lea smokescreen1,a0
	move.l a0,d0
	clr.b d0
	move.l d0,a0
	move.l a0,screenaddress
	add.l #32000,a0
	move.l a0,smokescreenaddress
	clear_screen
	swap_screens
	clear_screen
  
  bsr propfont_reset_cursor
  xstart set 120
  move.w #xstart,propfont_x_min
  move.w #xstart,propfont_x

  sysprint text1
  sysprint text2
  sysprint text3

  lea lightpath_xa,a0  
  lea currentpalette,a1
  bsr xa_get_palette


macro play_lightpath loops
  move.l #\{loops}-1,d7
  .oneloop\~:
    pushd7
    lea lightpath_xa,a0
    move.l #28-1,d6
    .onetree\~:
      pushd6
      vblwait 5
      move.l screenaddress,a1
      bsr xa_unpack_one_frame
      popd6
    dbra d6,.onetree\~
    vblwait 5
    popd7
  dbra d7,.oneloop\~
endm

  play_lightpath 4

	setpalette allblackpal
	vblwait 1
	clear_screen

  bsr propfont_reset_cursor
  xstart set 0
  move.w #xstart,propfont_x_min
  move.w #xstart,propfont_x
  xend set 220
  move.w #xstart,propfont_x_max

  ;break

macro outputtext_because_fuck_you_thats_why string
  move.l screenaddress,a0
  lea \{string},a1
  move.l #0,d1
  move.l #0,d2
  bsr propfont_draw_string
endm

  outputtext_because_fuck_you_thats_why text4
  outputtext_because_fuck_you_thats_why text5

more_christmas::

  lea lit_tree_xa,a0  
  lea currentpalette,a1
  bsr xa_get_palette

macro play_lit_tree loops
  lea lit_tree_xa,a0  
  move.l screenaddress,a1
  bsr xa_unpack_one_frame
  move.l a0,templong

  move.l #\{loops}-1,d7
  .oneloop\~:
    pushd7
    move.l templong,a0
    move.l #10-1,d6
    .onetree\~:
      pushd6
      vblwait 5
      move.l screenaddress,a1
      bsr xa_unpack_one_frame
      popd6
    dbra d6,.onetree\~
    vblwait 5
    popd7
  dbra d7,.oneloop\~
endm

  play_lit_tree 10

	setpalette allblackpal
	vblwait 1
  clear_screen

  bsr propfont_reset_cursor
  xstart set 120
  move.w #xstart,propfont_x_min
  move.w #xstart,propfont_x

  outputtext_because_fuck_you_thats_why text6
  outputtext_because_fuck_you_thats_why text7
  outputtext_because_fuck_you_thats_why text8
  outputtext_because_fuck_you_thats_why text9

  outputtext_because_fuck_you_thats_why text10
  outputtext_because_fuck_you_thats_why text11
  ;break

  lea lightpath_xa,a0  
  lea currentpalette,a1
  bsr xa_get_palette

  play_lightpath 4



	setpalette allblackpal
	vblwait 1
	clear_screen

  bsr propfont_reset_cursor
  xstart set 0
  move.w #xstart,propfont_x_min
  move.w #xstart,propfont_x
  xend set 220
  move.w #xstart,propfont_x_max

  outputtext_because_fuck_you_thats_why text12
  outputtext_because_fuck_you_thats_why text13

  lea lit_tree_xa,a0  
  lea currentpalette,a1
  bsr xa_get_palette

  play_lit_tree 10

	setpalette allblackpal

	vblwait 1
	clear_screen



  lea testpal,a0
  bsr fadepalettessetup
    	

tiltloop::
  move.l #8,d7
  .oneloop:
    pushd7

    vblwait 1
    lea snowflake_tilt_xa,a0
    move.l screenaddress,a1
    bsr xa_unpack_one_frame
    move.l a0,templong
  
    move.l templong,a0
    move.l #64-1,d6
    .oneframe:
      pushd6
      vblwait 1
      move.l screenaddress,a1
      bsr xa_unpack_one_frame
      pushall
      bsr fadepalettesdoonefade
      popall
      popd6
    dbra d6,.oneframe

    popd7
  dbra d7,.oneloop

  

  bra exitall




templong: dc.l 0


text1:
  dc.b 13
  putstring_with_2cr "Merry Christmas!"
text2:
  putstring_with_2cr "From GGN, Acca and Excellence in Art: All the best to you and your loved ones!"
text3:
  putstring_with_2cr "Welcome to rmac, an assembler built from the ground up to be convenient for the programmer."

text4:
  dc.b 13
  putstring_with_2cr "The codebase is approximately 30 years old, having started in the mid-1980s on VAX machines running 4.2 BSD UNIX, and it has evolved from the original madmac via smac to rmac today."
text5:
  putstring_with_2cr "But what are some famous projects assembled with this assembler? Glad you asked!"

text6:
  dc.b 13
  putstring_with_cr "Well, there's TOS, and there's this"
text7:
  putstring_with_cr "demo! ...oh, and practically"
text8:
  putstring_with_cr "everything the Reboot team has"
text9:
  putstring_with_cr "made for the Jaguar!"
text10:
  dc.b 13,13
  putstring_with_cr "That's right! Good old rmac even"
text11:
  putstring_with_cr "supports the Atari Jaguar!"

text12:
  dc.b 13,13,13,13
  putstring_with_2cr "This release is dedicated to LN, wishing her a fantastic christmas!"

text13:
  putstring_with_2cr "We love you! :-)"



swapscreens_huge:
  pusha0
  bsr swapscreens_santa_and_snowflakes
  bsr swapscreens_snowflakes_only
  popa0
  rts


swapscreens_santa_and_snowflakes:
  move.l screenaddress,a0
  move.l smokescreenaddress,screenaddress
  move.l a0,smokescreenaddress
  rts


swapscreens_snowflakes_only:
  move.l snowflake_screen_address,a0
  move.l snowflake_smokescreen_address,snowflake_screen_address
  move.l a0,snowflake_smokescreen_address
  rts

macro testd0
  cmp.b #1,d0
endm

flip_hugebuffer::
  pusha0
  pushd0
  move.b framecounter,d0
  and.b #1,d0
  move.b #0,d0
  tst.w hugebuffer_select
  bne .not0

  setup_snowflake_buffers hugescreenbuffer0, hugescreenbuffer1
  vblwait 1
  testd0
  beq .even1
  .odd1:
    setup_santa_buffers hugescreenbuffer1, hugescreenbuffer0
    bra .done1
  .even1:
    setup_santa_buffers hugescreenbuffer0, hugescreenbuffer1
  .done1:

  bra .alldone
.not0:

  setup_snowflake_buffers hugescreenbuffer2, hugescreenbuffer3
  vblwait 1
  testd0
  beq .even2
  .odd2:
    setup_santa_buffers hugescreenbuffer3, hugescreenbuffer2
    bra .done2
  .even2:
    setup_santa_buffers hugescreenbuffer2, hugescreenbuffer3
  .done2:

.alldone:
  popd0
  popa0
  not.w hugebuffer_select
  rts

hugebuffer_select:  dc.w 0


setup_santa_buffers_subroutine:
  add.l #visible_screen_start,a0
  move.l a0,screenaddress
  move.l a0,screenbuffer0
  add.l #visible_screen_start,a1
  move.l a1,smokescreenaddress  
  move.l a1,screenbuffer1
  rts

screenbuffer0:    dc.l 0
screenbuffer1:    dc.l 0

setup_snowflake_buffers_subroutine:
  add.l #visible_screen_start,a0
  add.l #6,a0
  move.l a0,snowflake_screen_address
  add.l #visible_screen_start,a1
  add.l #6,a1
  move.l a1,snowflake_smokescreen_address
  rts


copy_to_huge_buffer:
; In:  a0.l - pointer to image
  ;lea santa_1a,a0
  move.l screenaddress,a2
  move.l smokescreenaddress,a3
  move.l #200-1,d7
  .lines:
    rept 20
      move.l (a0),(a2)+
      move.l (a0)+,(a3)+
      move.l (a0),(a2)+
      move.l (a0)+,(a3)+
    endr
    add.l #(272-160),a2
    add.l #(272-160),a3
  dbra d7,.lines
  rts



clear1bpl_hugescreen:
; In: a0 - address to clear, bitplane offset already added
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
	rept 16/2
	  clr.l (a6)+
	endr
	move.w #0,$ffff8a20 ;source x inc
	move.w #0,$ffff8a22 ;source y inc
	move.l blanklongword,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #8,$ffff8a2e ;dest x inc
  val set hugescreenlinewidth-160
  val set val/2
  val set val+(8*2)
  move.w #val,$ffff8a30 ;dest y inc ; 8*15=120, 8*14=112
	move.l a0,$ffff8a32 ;destination address
	move.w #20,$ffff8a36 ;x count (n words per line to copy)
	move.w #200,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000001,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000000,$ffff8a3b ;blit op (logic op)
	move.b #0,$ffff8a3d ; skew
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts




;-----

endloop:
	bra endloop

;//
;///////////////////////////////////////////////////////////
	
exitall:
	include "_inc/end.s"
	even

;///////////////////////////////////////////////////////////
;//
;// Subroutines


initall:
	bsr init_ytable

  ; sysprint
  if SYSPRINT_ENABLE  
    bsr sysprint_init
  endif

  ; propfont
  if PROPFONT_ENABLE
    bsr propfont_init
  endif

  ; default palette
	setpalette bwpal

  ;fix timing
  lea timing_markers,a0
  .loop:
    cmp.w #-1,(a0)
    beq .done
    sub.w #1,(a0)+
  bra .loop
  .done:

  rts


fatal_error:
  backcol $700
  backcol $300
  backcol $000
  bra fatal_error


;///////////////////////////////////////////////////////////////
;// Snowflakes

snowflakes_vbl_wrapper:
  move.l snowflake_smokescreen_address,a0
  bsr clear1bpl_hugescreen
  bsr snowflakes_vbl
  bsr snowflakes_test_if_out
  bsr swapscreens_huge
  rts

snowflake_screen_address:       dc.l 0
snowflake_smokescreen_address:  dc.l 0

snowflakes_vbl:
  pushall
  lea snowflake_structs,a6
  move.l #NUM_SNOWFLAKES-1,d7
  .oneflake:
    cmp.w #-1,size(a6)
    beq .allflakesdone
    move.l xpos(a6),d0
    move.l ypos(a6),d1
    move.l xstep(a6),d2
    move.l ystep(a6),d3
    ; add to x
    add.l d2,d0
    move.l d0,xpos(a6)
    asr.l #4,d0
    ; add to y
    add.l d3,d1
    move.l d1,ypos(a6)
    asr.l #4,d1
    ; frame
    move.l frame(a6),d2
    move.l framestep(a6),d3
    add.l d3,d2
    move.l d2,frame(a6)
    asr.l #4,d2
    ; render
    move.l snowflake_smokescreen_address,a0
    cmp.w #SNOWFLAKE_EXTRA_SMALL,size(a6)
    beq .renderextrasmall
    cmp.w #SNOWFLAKE_SMALL,size(a6)
    beq .rendersmall
    cmp.w #SNOWFLAKE_MEDIUM,size(a6)
    beq .rendermedium
    cmp.w #SNOWFLAKE_LARGE,size(a6)
    beq .renderlarge
    ; no flake chosen = error
    jmp fatal_error
    .renderlarge:
    bsr blit_large_snowflake
    bra .nextflake
    .rendermedium:
    bsr blit_medium_snowflake
    bra .nextflake
    .rendersmall:
    bsr blit_small_snowflake
    bra .nextflake
    .renderextrasmall:
    bsr blit_extra_small_snowflake
    bra .nextflake
    .nextflake:
    add.l #SNOWFLAKE_STRUCT_SIZE,a6
  dbra d7,.oneflake
  .allflakesdone:
  popall
  rts


snowflakes_init:
  lea snowflake_structs,a6

; flake 4
  move.w #SNOWFLAKE_LARGE,size(a6)
  move.l #0,frame(a6)
  move.l #-1<<4,framestep(a6)
  move.l #20<<4,xpos(a6)
  move.l #-(SNOWFLAKE_EXTRA_SMALL_HEIGHT-80)<<4,ypos(a6)
  move.l #1<<5,xstep(a6)
  move.l #1<<5,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 12
  move.w #SNOWFLAKE_LARGE,size(a6)
  move.l #34,frame(a6)
  move.l #1<<4,framestep(a6)
  move.l #-50<<4,xpos(a6)
  move.l #-(SNOWFLAKE_LARGE_HEIGHT-8)<<4,ypos(a6)
  move.l #1<<3,xstep(a6)
  move.l #1<<5,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 1
  move.w #SNOWFLAKE_EXTRA_SMALL,size(a6)
  move.l #0,frame(a6)
  move.l #-1<<2,framestep(a6)
  move.l #40<<4,xpos(a6)
  move.l #-SNOWFLAKE_EXTRA_SMALL_HEIGHT<<4,ypos(a6)
  move.l #1<<2,xstep(a6)
  move.l #1<<3,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 5
  move.w #SNOWFLAKE_EXTRA_SMALL,size(a6)
  move.l #25,frame(a6)
  move.l #1<<2,framestep(a6)
  move.l #180<<4,xpos(a6)
  move.l #-(SNOWFLAKE_EXTRA_SMALL_HEIGHT-50)<<4,ypos(a6)
  move.l #1<<2,xstep(a6)
  move.l #1<<3,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 6
  move.w #SNOWFLAKE_EXTRA_SMALL,size(a6)
  move.l #44,frame(a6)
  move.l #-1<<4,framestep(a6)
  move.l #300<<4,xpos(a6)
  move.l #-SNOWFLAKE_EXTRA_SMALL_HEIGHT<<4,ypos(a6)
  move.l #1<<3,xstep(a6)
  move.l #1<<3,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 2
  move.w #SNOWFLAKE_SMALL,size(a6)
  move.l #0,frame(a6)
  move.l #1<<3,framestep(a6)
  move.l #280<<4,xpos(a6)
  move.l #-SNOWFLAKE_SMALL_HEIGHT<<4,ypos(a6)
  move.l #-1<<3,xstep(a6)
  move.l #1<<3,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 7
  move.w #SNOWFLAKE_SMALL,size(a6)
  move.l #20,frame(a6)
  move.l #1<<3,framestep(a6)
  move.l #15<<4,xpos(a6)
  move.l #-(SNOWFLAKE_SMALL_HEIGHT-90)<<4,ypos(a6)
  move.l #1<<3,xstep(a6)
  move.l #1<<3,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 8
  move.w #SNOWFLAKE_SMALL,size(a6)
  move.l #39,frame(a6)
  move.l #1<<3,framestep(a6)
  move.l #300<<4,xpos(a6)
  move.l #-(SNOWFLAKE_SMALL_HEIGHT-45)<<4,ypos(a6)
  move.l #-1<<4,xstep(a6)
  move.l #1<<3,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 9
  move.w #SNOWFLAKE_SMALL,size(a6)
  move.l #55,frame(a6)
  move.l #1<<3,framestep(a6)
  move.l #80<<4,xpos(a6)
  move.l #-(SNOWFLAKE_SMALL_HEIGHT-30)<<4,ypos(a6)
  move.l #-1<<3,xstep(a6)
  move.l #1<<3,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 3
  move.w #SNOWFLAKE_MEDIUM,size(a6)
  move.l #0,frame(a6)
  move.l #1<<4,framestep(a6)
  move.l #120<<4,xpos(a6)
  move.l #-SNOWFLAKE_MEDIUM_HEIGHT<<4,ypos(a6)
  move.l #-1<<4,xstep(a6)
  move.l #1<<4,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 10
  move.w #SNOWFLAKE_MEDIUM,size(a6)
  move.l #0,frame(a6)
  move.l #-1<<4,framestep(a6)
  move.l #10<<4,xpos(a6)
  move.l #-(SNOWFLAKE_MEDIUM_HEIGHT-30)<<4,ypos(a6)
  move.l #-1<<3,xstep(a6)
  move.l #1<<4,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

; flake 11
  move.w #SNOWFLAKE_MEDIUM,size(a6)
  move.l #0,frame(a6)
  move.l #1<<4,framestep(a6)
  move.l #290<<4,xpos(a6)
  move.l #-(SNOWFLAKE_MEDIUM_HEIGHT-90)<<4,ypos(a6)
  move.l #1<<3,xstep(a6)
  move.l #1<<4,ystep(a6)
  add.l #SNOWFLAKE_STRUCT_SIZE,a6

  ;no more flakes
  move.w #-1,size(a6)
  rts


snowflakes_test_if_out:
; test if snowflake has left screen (and won't return)
; if so, regenerate coords
  pushall
  lea snowflake_structs,a6
  move.l #NUM_SNOWFLAKES-1,d7
  .oneflake:
    cmp.w #-1,size(a6)
    beq .allflakesdone
    ; outside screen?
    move.w size(a6),d6
    cmp.w #SNOWFLAKE_LARGE,d6
    beq .large_flake
    cmp.w #SNOWFLAKE_MEDIUM,d6
    beq .medium_flake
    cmp.w #SNOWFLAKE_SMALL,d6
    beq .small_flake
    cmp.w #SNOWFLAKE_EXTRA_SMALL,d6
    beq .extra_small_flake
    jmp fatal_error
    .large_flake:
    move.l #SNOWFLAKE_LARGE_PIXELWIDTH,d4
    move.l #SNOWFLAKE_LARGE_HEIGHT,d5
    bra .goon
    .medium_flake:
    move.l #SNOWFLAKE_MEDIUM_PIXELWIDTH,d4
    move.l #SNOWFLAKE_MEDIUM_HEIGHT,d5
    bra .goon
    .small_flake:
    move.l #SNOWFLAKE_SMALL_PIXELWIDTH,d4
    move.l #SNOWFLAKE_SMALL_HEIGHT,d5
    bra .goon
    .extra_small_flake:
    move.l #SNOWFLAKE_EXTRA_SMALL_PIXELWIDTH,d4
    move.l #SNOWFLAKE_EXTRA_SMALL_HEIGHT,d5
    bra .goon
    .goon:
    ; check y
    ;break
    move.l ypos(a6),d0
    asr.l #4,d0
    cmp.w #199,d0
    bgt .makenew
    ; check x
    ;break
    move.l xpos(a6),d0
    asr.l #4,d0
    tst.w xstep(a6)
    bmi .negxstep
    ; pos xstep
    cmp.w #319,d0
    bgt .makenew
    .negxstep:
    neg.l d4
    cmp.l d4,d0
    blt .makenew
    bra .nextflake
    
    .makenew:
    ; make x
    bsr getrnd
    and.l #$fff,d0
    move.l d0,xpos(a6)
    ; make y
    neg.l d5
    asl.l #4,d5
    move.l d5,ypos(a6)

    .nextflake:
    add.l #SNOWFLAKE_STRUCT_SIZE,a6
  dbra d7,.oneflake
  .allflakesdone:
  popall
  rts


macro get_y_huge
; In:  d1.l - Y (-199 to 400)
;      a0.l - pointer to dest
; Out: a0.l - adjusted for Y
; Destroys:
;      d1.l
;      a6.l
  add.l #200,d1
  lea ytablehuge,a6
  add.l d1,d1
  add.l d1,d1
  add.l (a6,d1.w),a0
endm


blit_medium_snowflake:
; In: d0.l - X position
;     d1.l - Y position
;     d2.l - Frame (0-63)
;     d3.l - Screen width
;     a0.l - pointer to screen
  tst.w render_medium_snowflakes
  bne .go
  rts
.go:
  pushall

  ; y
  get_y_huge
  ;add.l d1,a0

  ; fix for negative x
  sub.l #104,a0
  add.l #208,d0
  
  ; skew
  move.w d0,d6
  and.w #$f,d6 ; skew
  
  ; x
  and.w #$fff0,d0
  lsr.w #1,d0
  add.w d0,a0 ; x

  lea snowflake_medium_all,a1
  ; frame
  and.l #$3f,d2
  mulu #SNOWFLAKE_MEDIUM_BYTESIZE,d2
  add.l d2,a1
  
  move.w #8*26,d7
  move.w #SNOWFLAKE_MEDIUM_WORDWIDTH,d1
  move.w #SNOWFLAKE_MEDIUM_HEIGHT,d2
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a1,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #8,$ffff8a2e ;dest x inc
	move.w d7,$ffff8a30 ;dest y inc
	move.l a0,$ffff8a32 ;destination address
	move.w d1,$ffff8a36 ;x count (n words per line to copy)
	move.w d2,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000010,$ffff8a3a ;blit hop (halftone mix)
	move.b #BLITOP_OR,$ffff8a3b ;blit op (logic op)
	move.b d6,$ffff8a3d ; skew
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter in hog mode
  popall
  rts


blit_small_snowflake:
; In: d0.l - X position
;     d1.l - Y position
;     d2.l - Frame (0-63)
;     d3.l - Screen width
;     a0.l - pointer to screen
  pushall

  ; y
  get_y_huge

  ; fix for negative x
  sub.l #104,a0
  add.l #208,d0
  
  ; skew
  move.w d0,d6
  and.w #$f,d6 ; skew
  
  ; x
  and.w #$fff0,d0
  lsr.w #1,d0
  add.w d0,a0 ; x

  lea snowflake_small_all,a1
  ; frame
  and.l #$3f,d2
  mulu #SNOWFLAKE_SMALL_BYTESIZE,d2
  add.l d2,a1
  
  move.w #8*30,d7
  move.w #SNOWFLAKE_SMALL_WORDWIDTH,d1
  move.w #SNOWFLAKE_SMALL_HEIGHT,d2
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a1,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #8,$ffff8a2e ;dest x inc
	move.w d7,$ffff8a30 ;dest y inc
	move.l a0,$ffff8a32 ;destination address
	move.w d1,$ffff8a36 ;x count (n words per line to copy)
	move.w d2,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000010,$ffff8a3a ;blit hop (halftone mix)
	move.b #BLITOP_OR,$ffff8a3b ;blit op (logic op)
	move.b d6,$ffff8a3d ; skew
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter in hog mode
  popall
  rts


blit_extra_small_snowflake:
; In: d0.l - X position
;     d1.l - Y position
;     d2.l - Frame (0-63)
;     d3.l - Screen width
;     a0.l - pointer to screen
  pushall

  ; y
  get_y_huge

  ; fix for negative x
  sub.l #104,a0
  add.l #208,d0
  
  ; skew
  move.w d0,d6
  and.w #$f,d6 ; skew
  
  ; x
  and.w #$fff0,d0
  lsr.w #1,d0
  add.w d0,a0 ; x

  lea snowflake_extra_small_all,a1
  ; frame
  and.l #$3f,d2
  mulu #SNOWFLAKE_EXTRA_SMALL_BYTESIZE,d2
  add.l d2,a1
  
  move.w #8*32,d7
  move.w #SNOWFLAKE_EXTRA_SMALL_WORDWIDTH,d1
  move.w #SNOWFLAKE_EXTRA_SMALL_HEIGHT,d2
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a1,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #8,$ffff8a2e ;dest x inc
	move.w d7,$ffff8a30 ;dest y inc
	move.l a0,$ffff8a32 ;destination address
	move.w d1,$ffff8a36 ;x count (n words per line to copy)
	move.w d2,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000010,$ffff8a3a ;blit hop (halftone mix)
	move.b #BLITOP_OR,$ffff8a3b ;blit op (logic op)
	move.b d6,$ffff8a3d ; skew
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter in hog mode
  popall
  rts


blit_large_snowflake:
; In: d0.l - X position
;     d1.l - Y position
;     d2.l - Frame (0-63)
;     d3.l - Screen width
;     a0.l - pointer to screen

;render_large_snowflakes:    dc.w 0
;render_medium_snowflakes:   dc.w 0
  tst.w render_large_snowflakes
  bne .go
  rts
.go:
  pushall

  ; y
  get_y_huge

  ; fix for negative x
  sub.l #104,a0
  add.l #208,d0
  
  ; skew
  move.w d0,d6
  and.w #$f,d6 ; skew
  
  ; x
  and.w #$fff0,d0
  lsr.w #1,d0
  add.w d0,a0 ; x

  lea snowflake_large_all,a1
  ; frame
  and.l #$3f,d2
  mulu #SNOWFLAKE_LARGE_BYTESIZE,d2
  add.l d2,a1
  
  move.w #hugescreenlinewidth-160-(8*5),d7
  move.w #SNOWFLAKE_LARGE_WORDWIDTH,d1
  move.w #SNOWFLAKE_LARGE_HEIGHT,d2
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a1,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #8,$ffff8a2e ;dest x inc
	move.w d7,$ffff8a30 ;dest y inc
	move.l a0,$ffff8a32 ;destination address
	move.w d1,$ffff8a36 ;x count (n words per line to copy)
	move.w d2,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000010,$ffff8a3a ;blit hop (halftone mix)
	move.b #BLITOP_OR,$ffff8a3b ;blit op (logic op)
	move.b d6,$ffff8a3d ; skew
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter in hog mode
  popall
  rts


;//////////////////////////////
;// Generate snowflakes

unpacksnowflakes::
  move.l a0,snowflake_xa_address
  move.l a1,snowflake_dest_address
  move.l d4,snowflake_width
  move.l d5,snowflake_lines
  lea unpackbuffer,a0
  clear_1bpl

  move.l snowflake_xa_address,a0
  lea unpackbuffer,a1
  bsr xa_unpack_one_frame
  move.l a0,snowflake_xa_address
  ; copy to buffer
  move.l snowflake_dest_address,a6
  bsr unpacksnowflakes_copytobuffer
  move.l a6,snowflake_dest_address

  move.l #63-1,d7
  .oneframe:
    pushd7
    move.l snowflake_xa_address,a0
    lea unpackbuffer,a1
    bsr xa_unpack_one_frame
    move.l a0,snowflake_xa_address
    move.l snowflake_dest_address,a6
    bsr unpacksnowflakes_copytobuffer
    move.l a6,snowflake_dest_address
    popd7
  dbra d7,.oneframe
  rts

snowflake_xa_address:     dc.l 0
snowflake_dest_address:   dc.l 0
snowflake_width:          dc.l 0
snowflake_lines:          dc.l 0

unpacksnowflakes_copytobuffer::
  pushd7
  pushd6
  lea unpackbuffer,a5
  move.l snowflake_lines,d7
  sub.l #1,d7
  .line:
    move.l snowflake_width,d6
    sub.l #1,d6
    .word:
      move.w (a5),(a6)+
      ;move.w #%1010101010101010,(a6)+
      add.l #8,a5
    dbra d6,.word
    ;break
    move.l snowflake_width,d0
    ;sub.l #1,d0
    lsl.l #3,d0
    move.l #160,d1
    sub.l d0,d1
    add.l d1,a5
    ;add.l #160-(\{wordwidth}*2*8),a5
  dbra d7,.line
  popd6
  popd7
  rts

;// Generate snowflakes
;//////////////////////////////

render_large_snowflakes:    dc.w 0
render_medium_snowflakes:   dc.w 0

;// Snowflakes
;///////////////////////////////////////////////////////////////
;// Printval - converting num to string

if PRINTVAL_ENABLE

  printval_d0_dec:
    bsr printval_makeval_dec_tass
    lea printval_valuebuffer,a1
    bsr printval_remove_leading_zeroes
    sysprint_a1
    rts
  
  
  printval_d0_hex:
    bsr printval_makeval_hex
    lea printval_valuebuffer,a1
    bsr printval_remove_leading_zeroes
    sysprint_a1
    rts
  
  
  printval_remove_leading_zeroes:
  ; In:  a1.l - pointer to string with numbers
  ; Out: a1.l - same pointer, adjusted
    .loop:
      cmp.b #"0",(a1)
      bne .done
      add.w #1,a1
    bra .loop
  .done:
    rts
  
  
  printval_makeval_dec_tass:
  ; Originally from Turbo Assembler
  
  ; In:  d0.l - value to convert to decimal
  ; Out: printval_valuebuffer - null-terminated string with output
  ;               move.l  #12345,D1       ;number to output
  ;                moveq   #5-1,D4         ;no of digits-1
  ;                lea     out,A0          ;buffer
    move.l d0,d1
    move.l #9,d4
    lea printval_valuebuffer,a0
  ;************************************************************************
  ;* Dezimal-Zahl in D1 ausgeben                                          *
  ;* Anzahl der Stellen in D4                                             *
  ;************************************************************************
  ;                PART 'dezw_out'
  dezw_out:
    movem.l D0-D5/A3,-(SP)
    lea dez_tab(PC),A3
    move.w  D4,D5
    lsl.w   #2,D5
    lea     4(A3,D5.w),A3
    moveq   #'0',D5
  dez_loop:
    move.l  -(A3),D3
    moveq   #$D0,D2
  subtr:
    sub.l   D3,D1
    dbcs    D2,subtr
    neg.b   D2
    move.b  D2,D0
    cmp.b   #'0',D0
    beq.s   dez_zero
    moveq   #'0',D5
  dez_zero2:                              ;bsr     chrout
    move.b  D0,(A0)+
    add.l   D3,D1
    dbra    D4,dez_loop
    move.b #0,(a0)+
    movem.l (SP)+,D0-D5/A3
    rts
  dez_zero:
    move.w  D5,D0
    tst.w   D4
    bne.s   dez_zero2
    moveq   #'0',D0
    bra.s   dez_zero2
  dez_tab:
    DC.L 1,10,100,1000,10000,100000
    DC.L 1000000,10000000,100000000,1000000000
  ;                ENDPART
  ;out:            DS.B 16
  
  
  printval_makeval_dec:
  ; In:  d0.l - value to convert to decimal
  ; Out: printval_valuebuffer - null-terminated string with output
  ; IMPORTANT: this only works for d0 in range 0-34463 (Why it isn't 0-32767 is a mystery at this time)
    lea printval_valuebuffer,a6
    lea printval_pow10,a5
    move.l #0,d2 ; m
  
    move.l #PRINTVAL_VALUEBUFFER_SIZE-1+1,d7
    .loop:
      move.l (a5)+,d6
      move.l d0,d1 ; d1=n
      sub.l d2,d1 ; d1=n-m
      divu d6,d1 ; d1 is value
      ext.l d1
      move.l d1,d5
      add.b #48,d5
      move.b d5,(a6)+
      mulu d6,d1
      add.l d1,d2
    dbra d7,.loop
    move.b #0,(a6)+
    rts
  
  
  printval_makeval_hex:
  ; In:  d0.l - value to convert to decimal
  ; Out: printval_valuebuffer - null-terminated string with output
    lea printval_valuebuffer,a6
    lea printval_hextable,a5
    move.l #8-1,d7
    .loop:
      move.l d0,d1
      move.l (a5)+,d2
      and.l d2,d1
      move.l (a5)+,d3
      beq .noshifting
      sub.l #1,d3
      .shiftloop:
        asr.l #4,d1
      dbra d3,.shiftloop
    .noshifting:
      add.b #48,d1
      cmp.b #"9",d1
      ble .nofixforchars
      add.b #39,d1
    .nofixforchars:
      move.b d1,(a6)+
    dbra d7,.loop
    move.b #0,(a6)+
    rts
  
  
  printval_init::
    lea printval_valuebuffer,a0
    move.l #"0",d6
    move.l #0,d6
    move.l #PRINTVAL_VALUEBUFFER_SIZE_MAX-1,d7
    .loop:
      move.b d6,(a0)+
    dbra d7,.loop
    rts
  
  
  printval_hextable:
    dc.l $f0000000, 7
    dc.l $0f000000, 6
    dc.l $00f00000, 5
    dc.l $000f0000, 4
    dc.l $0000f000, 3
    dc.l $00000f00, 2
    dc.l $000000f0, 1
    dc.l $0000000f, 0
  
  
  printval_pow10:
    ; Nasty but fun solution for powers of 10
    z set PRINTVAL_VALUEBUFFER_SIZE
    ;z set 5
    v set 1
    rept z
      v set v*10
    endr
    rept z+1
      dc.l v
      v set v/10
    endr
  
  
  printval_valuebuffer:
    dcb.b PRINTVAL_VALUEBUFFER_SIZE_MAX+1,0
    even

endif

;// Printval - converting num to string
;///////////////////////////////////////////////////////////////
;// File loading
if FILE_LOAD_ENABLE

  file_load_loadfile:
  ; In: a0.l - address of zero-terminated filename string
  ;     a1.l - address to load data at
  ; Out: d0 - 0=ok, all other values means error
  	move.l #0,d0
  	move.w #0,-(sp)
  	move.l a0,-(sp)
  	move.w #$3d,-(sp)
  	trap #1
  	add.l #8,sp
  	tst.l d0
  	bmi	.fail
  	move.w d0,file_load_handle
  	bra .filefoundgoon
  .fail:
  	move.l #-1,d0
  	rts
  
  .filefoundgoon:
  	move.l a1,-(sp)
  	move.l #1024*1024*4,-(sp)
  	move.w file_load_handle,-(sp)
  	move.w #$3f,-(sp)
  	trap #1
  	add.l #12,sp
  	tst.l d0
  	bmi	.fail
  	move.w file_load_handle,-(sp)
  	move.w #$3e,-(sp)
  	trap #1
  	add.l #4,sp
  	move.l #0,d0
  	rts
  
  
  file_load_error:
    vblwait 1
    setpalette allblackpal
  .meow:
    move.w #0,$ffff8240
    move.w #$700,$ffff8240
    bra .meow
    rts ; will never be reached

endif
;// File loading
;///////////////////////////////////////////////////////////////
; // MegaSTE
if MEGASTE_ENABLE

  turn_megaste_features_off:
    if DO_SYSTEM_TEST
      tst.w systemtest_machine_type_mste
      beq .done
  ;	move.l $8,-(sp)
  ;	move.l #ggntrap1,$8
  	clr.b $ffff8e21
  ;ggntrap1
  ;	move.l (sp)+,$8
  .done:
    endif
  	rts
  
  turn_megaste_features_on:
    if DO_SYSTEM_TEST
      tst.w systemtest_machine_type_mste
      beq .done
  ;	move.l $8,-(sp)
  ;	move.l #ggntrap2,$8
  	move.b #$ff,$ffff8e21
  ;ggntrap2
  ;	move.l (sp)+,$8
  .done:
    endif
  	rts

endif
; // MegaSTE
;///////////////////////////////////////////////////////////////


init_ytable:
  lea ytable,a0
  clr.l d0
  move.l #200-1,d7
  .loop:
    move.l d0,(a0)+
    add.l #160,d0
  dbra d7,.loop

  lea ytablehuge,a0
  move.l #(-200)*272,d0
  ;clr.l d0
  move.l #600-1,d7
  .loop2:
    move.l d0,(a0)+
    add.l #272,d0
  dbra d7,.loop2
  rts


;///////////////////////////////////////////////////////////////
;// propfont

if PROPFONT_ENABLE

  propfont_init:
    bsr propfont_init_fonttempchar
    bsr propfont_build_fontpostable
    bsr propfont_build_fontwidthconvertertable
    bsr propfont_build_fontwidthtable
  
    bsr propfont_reset_cursor
    rts
  
  
  propfont_reset_cursor:
    clr.w propfont_x
    clr.w propfont_y
    move.w #0,propfont_x_min
    move.w #319,propfont_x_max
    rts
  
  
  propfont_draw_string_with_linebreak:
  ; In: a0.l - pointer to screen
  ;     a1.l - pointer to null-terminated string
  ;     d1.w - X pos
  ;     d2.w - Y pos
    pusha0
    move.l a1,a0
    bsr propfont_font_linebreak_string
    popa0
    bsr propfont_draw_string
    rts
  
  
  propfont_font_linebreak_string:
  ; Uses propfont_x_max and propfont_x_min to add in linebreaks in a text string
  ; In: a0.l - pointer to null-terminated string
  ; Out: nothing, this modifies the string in-place.
    pushall
    
    move.l #0,d5 ; d5 is line starting position into string
    move.l #0,d4 ; d4 is last space position into string
    move.l #0,d3 ; d3 is current char position
    
    lea propfont_fontwidthtable,a1
    move.l #0,d0
    move.l d0,d1
    move.l d0,d7
    move.w propfont_x_max,d7
    move.w propfont_x_min,d1
    sub.l d1,d7 ; d7 now contains max width
    move.l #0,d6 ; d6 is line width
  .onechar:
    move.l #0,d0
    move.b (a0,d3),d0 ; d0 is char
    cmp.b #0,d0
    if 1=0
      beq .done
    else
      beq .nowidth
    endif
    cmp.b #32,d0
    beq .nowidth_space
    cmp.b #13,d0
    beq .nowidth_linebreak
    sub.l #33,d0
    move.l d0,d1
    add.l d1,d1 ; (a1,d1) now points to char width
    move.w (a1,d1),d1
    bra .widthdone
  .nowidth_linebreak:
    cmp.w d7,d6 ; (d7=max width) if numLineWidth>=numMaxLineWidth: 
    blt .notlower00
    move.b #13,(a0,d4) ; linebreak at numLastSpacePosition
  .notlower00:
    move.l #0,d6
    bra .widthdone
  .nowidth_space:
    move.l #PROPFONT_FONTSPACEWIDTH,d1
    bra .widthdone
  .nowidth:
    move.l #-1,d1
    bra .widthdone
  .widthdone: ; d1 now contains char width, or -1 if no width
  
    cmp.b #0,d0
    bne .notend01
    cmp.w d7,d6 ; (d7=max width) if numLineWidth>=numMaxLineWidth: 
    blt .notlower01
    move.b #13,(a0,d4) ; linebreak at numLastSpacePosition
    bra .done
  .notlower01:
  .notend01:
  
    move.l #0,d2
    cmp.b #32,d0
    bne .notspace02
    move.l #1,d2
  .notspace02:
    cmp.b #13,d0
    bne .notenter02
    move.l #1,d2
  .notenter02:
    cmp.b #0,d2
    beq .done01
    move.l #PROPFONT_FONTSPACEWIDTH,d1 ; space char width
    cmp.w d7,d6
    blt .notlower02
    move.b #13,(a0,d4)
    move.l #0,d6
    move.l d4,d5
    ;find next non-space char
  .finderloop:
    cmp.b #32,(a0,d5)
    bne .finderdone
    add.l #1,d5
    bra .finderloop
  .finderdone:
    move.l d5,d4 ; numLastSpacePos=numLineStartPos
    move.l d5,d3 ; numCharPos=numLineStartPos
    bra .done01
  .notlower02:
    move.l d3,d4 ; numLastSpacePos=numCharPos
  .done01:
  
    add.w #1,d6
    add.w d1,d6 ; add char width to line width
  
    if 1=0
      tst.b d0
      beq .done
    endif
  
  .nextchar:
    add.l #1,d3
    bra .onechar
  
  .done:
    popall
    rts
  
  
  propfont_draw_string_one_at_a_time:
  ; In: a0.l - pointer to screen
  ;     a1.l - pointer to null-terminated string
  ;     d1.w - X pos
  ;     d2.w - Y pos
  ; Out: Nothing
  ; Destroys: Nothing
  ; Updates propfont_x
    add.w d1,propfont_x_min
    move.w d2,propfont_y
    move.l #0,d0
    .onechar:
      cmp.b #0,(a1)
      beq .done
      move.b (a1)+,d0
      cmp.b #13,d0
      bne .notenter
      move.w propfont_x_min,propfont_x
      add.w #PROPFONT_FONTHEIGHT,propfont_y
    bra .onechar
  .notenter:
    move.w propfont_x,d1
    move.w propfont_y,d2
    bsr propfont_draw_char
    vblwait 1
    bra .onechar
  .done:
    rts
  
  
  propfont_draw_string:
  ; In: a0.l - pointer to screen
  ;     a1.l - pointer to null-terminated string
  ;     d1.w - X pos
  ;     d2.w - Y pos
  ; Out: Nothing
  ; Destroys: Nothing
  ; Updates propfont_x
    move.l #0,d0
    .onechar:
      cmp.b #0,(a1)
      beq .done
      move.b (a1)+,d0
      cmp.b #13,d0
      bne .notenter
      move.w propfont_x_min,propfont_x
      add.w #PROPFONT_FONTHEIGHT,propfont_y
    bra .onechar
  .notenter:
    bsr propfont_draw_char
    bra .onechar
  .done:
    rts


  propfont_draw_char:
  ; In: a0.l - pointer to screen
  ;     d0.b - char
  ;     propfont_x.w - X pos
  ;     propfont_y.w - Y pos
  ; Out: Nothing
  ; Destroys: Nothing
  ; Updates propfont_x
    cmp.b #32,d0
    bne .regularchar
    add.w #1+PROPFONT_FONTSPACEWIDTH,propfont_x
    rts
  .regularchar:
    pushall
    lea propfont_font,a2
    lea propfont_fontpostable,a1
    and.l #$ff,d0
    sub.l #33,d0
    
    add.l d0,d0
    add.w (a1,d0),a2 ; a2 points to char in font
  
    ; copy char to temp char
    lea propfont_fonttempchar,a6
    move.l #PROPFONT_FONTHEIGHT-1,d7
    .fontcopy:
      move.l (a2),(a6)+
      add.l #40,a2
    dbra d7,.fontcopy
  
    lea ytable,a1
    move.w propfont_y,d2
    add.w d2,d2
    add.w d2,d2
    add.l (a1,d2.w),a0 ; a0 now points to the correct line
  
    move.w propfont_x,d1
    ext.l d1
    move.l d1,d2
    and.l #$000f,d2 ; d2 is now x "in-word" position (= loop counter)
    and.l #$fffffff0,d1
    lsr.l #4,d1
    lsl.l #3,d1 ; d1 is now offset into line
    add.l d1,a0 ; a0 now point to correct word
    cmp.w #0,d2
    beq .norotate
    ;rotate char
    lea propfont_fonttempchar,a6
    sub.l #1,d2
  .rotatechar:
    pusha6
    move.l #PROPFONT_FONTHEIGHT,d6
    sub.l #1,d6
    .height_loop1:
      move.w #0,ccr
      roxr.w (a6)+
      roxr.w (a6)+
    dbra d6,.height_loop1
    popa6
    dbra d2,.rotatechar
  .norotate:
    ; OR char onto screen
    lea propfont_fonttempchar,a6
    move.l #PROPFONT_FONTHEIGHT,d6
    sub.l #1,d6
    .height_loop2:
      move.w (a6)+,d7
      or.w d7,(a0)
      add.l #8,a0
      move.w (a6)+,d7
      or.w d7,(a0)
      add.l #160-8,a0
    dbra d6,.height_loop2
    lea propfont_fontwidthtable,a1
    move.w (a1,d0),d0
    add.w d0,propfont_x
    add.w #1,propfont_x ; space between chars
    popall
    rts


  propfont_build_fontwidthtable:
    pushall
    lea propfont_font,a0
    lea propfont_fontpostable,a1
    lea propfont_fontwidthconvertertable,a2
    lea propfont_fontwidthtable,a6
  
    move.l #(PROPFONT_FONTCHARSLINES*PROPFONT_FONTCHARSPERLINE)-1,d7
    .onechar:
      move.w (a1)+,d0
      ext.l d0 ; d0 = offset into a0 - so (a0,d0) is now start of char
      add.l #(PROPFONT_FONTHEIGHT)*40,d0 ; (a0,d0) now points to width in graphics
      lea propfont_fontwidthconvertertable,a2
      move.w #0,d2 ; final width
      move.w (a0,d0),d1
      move.l #PROPFONT_FONTWIDTHCONVERTERTABLESIZE-1,d6
      .convloop:
        cmp.w (a2),d1
        beq .convmatch
        add.l #4,a2
      dbra d6,.convloop
      bra .convgoon ; no match found
    .convmatch:
      move.w 2(a2),d2 ; final width
    .convgoon:
      move.w d2,(a6)+
    dbra d7,.onechar
    move.l #4-1,d7
    .endloop:
      move.l #-1,(a6)+
    dbra d7,.endloop
    popall
    rts
  
  
  propfont_build_fontpostable:
  ;o set 0
  ;  rept PROPFONT_FONTCHARSLINES
  ;  dc.w o+0, o+4, o+8, o+12, o+16, o+20, o+24, o+28, o+32, o+36
  ;o set o+((PROPFONT_FONTHEIGHT+1)*40)
  ;  endr
    lea propfont_fontpostable,a0
    clr.l d4
    move.l #PROPFONT_FONTCHARSLINES-1,d7
    .outer:
      move.l d4,d5
      move.l #10-1,d6
      .inner:
        move.w d5,(a0)+
        add.l #4,d5
      dbra d6,.inner
      add.l #((PROPFONT_FONTHEIGHT+1)*40),d4
    dbra d7,.outer
    rts
  
  
  propfont_build_fontwidthconvertertable:
  ;  dc.w %0000000000000000, 0
  ;  dc.w %1000000000000000, 1
  ;  dc.w %1100000000000000, 2
  ;  dc.w %1110000000000000, 3
  ;  dc.w %1111000000000000, 4
  ;  dc.w %1111100000000000, 5
  ;  dc.w %1111110000000000, 6
  ;  dc.w %1111111000000000, 7
  ;  dc.w %1111111100000000, 8
  ;  dc.w %1111111110000000, 9
  ;  dc.w %1111111111000000, 10
  ;  dc.w %1111111111100000, 11
  ;  dc.w %1111111111110000, 12
  ;  dc.w %1111111111111000, 13
  ;  dc.w %1111111111111100, 14
  ;  dc.w %1111111111111110, 15
  ;  dc.w %1111111111111111, 16
    lea propfont_fontwidthconvertertable,a0
    clr.l d0
    move.l d0,d1
    move.l #17-1,d7
    .loop:
      move.w d0,(a0)+
      move.w d1,(a0)+
      lsr.l #1,d0
      or.w #%1000000000000000,d0
      add.w #1,d1
    dbra d7,.loop
    rts
  
  
  propfont_init_fonttempchar:
    lea propfont_fonttempchar,a0
    move.l #PROPFONT_FONTHEIGHT-1,d7
    .loop:
      clr.l (a0)+
    dbra d7,.loop
    rts


endif
;// propfont
;///////////////////////////////////////////////////////////////
;// systemtest
if DO_SYSTEM_TEST

  systemtest:
  
  ;-- from DHS:
  ; Atari ST/e synclock demosystem
  ; September 2, 2011
  ;
  ; sys/cookie.s
  
  maxcookie	equ	128				;Maximum cookie entries to search
  
  
  ;cookie_check:
  		move.l	$5a0.w,d0
  		beq.s	.st				;Null pointer = ST
  		move.l	d0,a0
  
  		moveq	#maxcookie-1,d7
  .search_mch:
    	tst.l	(a0)
  		beq.s	.st				;Null termination of cookiejar, no _MCH found = ST
  
  		cmp.l	#"_MCH",(a0)
  		beq.s	.mch_found
  		addq.l	#8,a0
  		dbra	d7,.search_mch
  		bra.s	.st				;Default to ST
  
  .mch_found:
    	move.l	4(a0),d0
  		cmp.l	#$00010000,d0
  		beq.s	.ste
  		cmp.l	#$00010010,d0
  		beq.s	.megaste
  		cmp.l	#$00020000,d0
  		beq.s	.tt
  		cmp.l	#$00030000,d0
  		beq.s	.falcon
  
  .st:
    move.l	#"ST  ",systemtest_computer_type
    move.w #1,systemtest_machine_type_st
  		bra.s	.cookie_done
  
  .ste:
  	move.l	#"STe ",systemtest_computer_type
    move.w #1,systemtest_machine_type_ste
  		bra.s	.cookie_done
  
  .megaste:
  	move.l	#"MSTe",systemtest_computer_type
    move.w #1,systemtest_machine_type_mste
  		bra.s	.cookie_done
  
  .tt:
  	move.l	#"TT  ",systemtest_computer_type
    move.w #1,systemtest_machine_type_tt
  		bra.s	.cookie_done
  
  
  .falcon:
    	;Check if we are on CT60/3
  		move.l	$5a0.w,a0
  		moveq	#maxcookie-1,d7
  .search_ct60:
  		cmp.l	#"CT60",(a0)
  		beq.s	.f060
  		addq.l	#8,a0
  		dbra	d7,.search_ct60
  
  .f030:
  	move.l	#"F030",systemtest_computer_type
    move.w #-1,systemtest_machine_type_f030
  		bra.s	.cookie_done
  .f060:
  	move.l	#"F060",systemtest_computer_type
    move.w #-1,systemtest_machine_type_f060
  
  .cookie_done:
  
  
    ; RAM
    move.l $42e,d0
    ; $0008 0000 - 0.5 MB
    ; $0010 0000 - 1 MB
    ; $0020 0000 - 2 MB
    ; $0028 0000 - 2.5 MB
    ; $0040 0000 - 4 MB
    ; $00e0 0000 - 14 MB
    swap d0
  
    cmp.l #$8,d0
    bne .not_0_5
    lea systemtest_string_ram_512k,a6
    bra .ram_detect_done
  .not_0_5:
    cmp.l #$10,d0
    bne .not_1
    lea systemtest_string_ram_1M,a6
    bra .ram_detect_done
  .not_1:
    cmp.l #$20,d0
    bne .not_2
    lea systemtest_string_ram_2M,a6
    bra .ram_detect_done
  .not_2:
    cmp.l #$28,d0
    bne .not_2_5
    lea systemtest_string_ram_2_5M,a6
    bra .ram_detect_done
  .not_2_5:
    cmp.l #$40,d0
    bne .not_4
    lea systemtest_string_ram_4M,a6
    bra .ram_detect_done
  .not_4:
    cmp.l #$e0,d0
    bne .not_14
    lea systemtest_string_ram_14M,a6
    bra .ram_detect_done
  .not_14:
    lea systemtest_string_ram_unknown,a6
  
  .ram_detect_done:
    move.l a6,systemtest_ram_string_pointer
  
    ;TOS version
    move.l 4,d0
    clr.b d0
    move.l d0,a0
    clr.l d0
    clr.l d1
    move.b 2(a0),d0
    move.b 3(a0),d1
    move.l d1,d2
    lea systemtest_tos_string,a6
    clr.l d7
    move.b #"0",d7
    move.l d7,d6
    add.b d0,d6
    move.b d6,0(a6) ;X.xx
    move.l d7,d6
    lsr #4,d1
    add.b d1,d6
    move.b d6,2(a6) ;x.Xx
    move.l d7,d6
    and.b #$f,d2
    add.b d2,d6
    move.b d6,3(a6) ;x.xX
  
    rts
  
  
  
  systemtest_print:
    setpalette systemtest_palette
  
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 10
    sysprint systemtest_string_starting
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 25
    sysprint systemtest_string_cookie
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 25
    sysprint systemtest_string_system_detected
    sysprint systemtest_computer_type
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 15
    sysprint systemtest_string_ram
    move.l systemtest_ram_string_pointer,a1
    ;bsr sysprint_print_string
    sysprint_a1 
    sysprint systemtest_line_break
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 15
  
    sysprint systemtest_tos_header
    sysprint systemtest_tos_string
    iif SPEED_UP_SYSTEM_TEST=0, vblwait 35
    rts
  
  
  music0_filename:
    file_load_place_filename "xms15_00.d8a"
  
  music1_filename:
    file_load_place_filename "xms15_01.d8a"

  snowflake_large_xa_filename:
    file_load_place_filename "xms15_02.d8a"
  
  snowflake_medium_xa_filename:
    file_load_place_filename "xms15_03.d8a"
  
  snowflake_small_xa_filename:
    file_load_place_filename "xms15_04.d8a"
  
  snowflake_extra_small_xa_filename:
    file_load_place_filename "xms15_05.d8a"

  snowflake_tilt_xa_filename:
    file_load_place_filename "xms15_06.d8a"
  
    even
  txt_loading_music:
    dc.b 13,13
    ;putstring "Loading music... "
    putstring "Loading greetings database... "
  
  txt_done:
    putstring_with_cr "Done! "

  txt_loading_pixels:
    ;putstring "Loading pixels... "
    putstring "Transsubstantiating... "

  txt_precalc1:
    putstring "Reticulating splines... "
  
  txt_precalc2:
    putstring "Eating humble pie... "
  
  systemtest_palette:
    dc.w $002, $666
    dcb.w 14,0
  
  systemtest_computer_type:
  	dcb.b 4," "				;"ST  ", "STe ", "MSTe", "TT  ", "F030", "F060"
    dc.b 13,0
    even
  
  systemtest_machine_type_st:     dc.w 0
  systemtest_machine_type_ste:    dc.w 0
  systemtest_machine_type_mste:   dc.w 0
  systemtest_machine_type_tt:     dc.w 0
  systemtest_machine_type_f030:   dc.w 0
  systemtest_machine_type_f060:   dc.w 0
  systemtest_ram_string_pointer:  dc.l 0
  systemtest_ram_tosver_major:    dc.b 0
  systemtest_ram_tosver_minor:    dc.b 0
  
  systemtest_string_starting:
    dc.b "Starting XiA demosystem",13
  
    if PROPFONT_ENABLE
      iif PROPFONT_FONT_SELECT=PROPFONT_FONT_PER02, dc.b "-----------------------",13
      iif PROPFONT_FONT_SELECT=PROPFONT_FONT_PER, dc.b "----------------------------",13
      iif PROPFONT_FONT_SELECT=PROPFONT_FONT_MV_BOLI, dc.b "-----------------------------",13
      iif PROPFONT_FONT_SELECT=PROPFONT_FONT_PALATINO, dc.b "-----------------------------------",13
      iif PROPFONT_FONT_SELECT=PROPFONT_FONT_CALIBRI_LIGHT, dc.b "----------------------------------",13
      iif PROPFONT_FONT_SELECT=PROPFONT_FONT_MACINTOSH_1984, dc.b "--------------------------",13
      iif PROPFONT_FONT_SELECT=PROPFONT_FONT_ZX_SPECTRUM, dc.b "-----------------------",13
      iif PROPFONT_FONT_SELECT=PROPFONT_FONT_MSX, dc.b "-----------------------",13
      iif PROPFONT_FONT_SELECT=PROPFONT_FONT_ATARI_8BIT, dc.b "-----------------------",13
    else
      dc.b "------------------------",13
    endif
    dc.b 0
    even
  
  systemtest_string_cookie:
    putstring_with_cr "Requesting system cookie..."
  systemtest_string_system_detected:
    putstring "  Machine: "
  systemtest_string_ram:
    putstring "  RAM: "
  systemtest_string_ram_512k:
    putstring "512Kb"
  systemtest_string_ram_1M:
    putstring "1Mb"
  systemtest_string_ram_2M:
    putstring "2Mb"
  systemtest_string_ram_2_5M:
    putstring "2.5Mb"
  systemtest_string_ram_4M:
    putstring "4Mb"
  systemtest_string_ram_14M:
    putstring "14Mb"
  systemtest_string_ram_unknown:
    putstring "? Detection failure"
  systemtest_line_break:
    putstring 13
  systemtest_tos_header:
    putstring "  TOS version: "
  systemtest_tos_string:
    putstring_with_cr "x.xx"

endif
;// systemtest
;///////////////////////////////////////////////////////////////
;// sysprint code

if SYSPRINT_ENABLE

  sysprint_print_string:
  ; In:  a0.l - pointer to start of screen address
  ;      a1.l - address to null-terminated string
  ;      sysprint_x.w - x position for output (0-39)
  ;      sysprint_y.w - y position for output (0-25)
  ;  ifne SYSTEM_TEST_USE_PROPFONT
  ;    bsr propfont_draw_string_with_linebreak
  ;    rts
  ;  endif
  .getchar:
    move.b (a1)+,d0
    beq .alldone ; 0=exit
    cmp.b #13,d0
    bne .nolinebreak
  
    ; linebreak
  .linebreak:
    clr.w sysprint_x
    add.w #1,sysprint_y
    bra .getchar
  .nolinebreak:
  
    ; regular char
    bsr sysprint_print_char
    add.w #1,sysprint_x
    cmp #40,sysprint_x
    bge .linebreak ; force linebreak if x>40
    bra .getchar
    
  .alldone:
    rts
  
  
  sysprint_print_char:
  ; In:  d0.b - char
  ;      a0.l - pointer to start of screen address
  ;      sysprint_x.w - x position for output (0-39)
  ;      sysprint_y.w - y position for output (0-25)
    pusha0
    and.w #$00ff,d0
    lea sysprint_charmap,a5
    move.b (a5,d0.w),d0
  
    sub.b #32,d0 ; font starts at char 32
    
    mulu.w #5,d0
    lea sysprint_font,a6
    
    ; adjust for y
    move.w sysprint_y,d1
  sysprint_line_height equ 9
    mulu.w #160*sysprint_line_height,d1
    add.w d1,a0
    
    ; adjust for x
    move.w sysprint_x,d1
    move.w d1,d2
    and.w #1,d2 ; mask out lowest bit
    ;and.w #$fffe,d1
    lsr.w #1,d1
    lsl.w #3,d1
    add.w d1,a0
    add.w d2,a0
  
    ; draw char  
    move.b (a6,d0.w),(a0)
  lineoffs set 160
  fontoffs set 1
    rept 4
      move.b fontoffs(a6,d0),lineoffs(a0)
      lineoffs set lineoffs+160
      fontoffs set fontoffs+1
    endr
    popa0
    rts
  
  
  sysprint_init:
    lea sysprint_charmap,a0
    move.l a0,a1
    ; first map everything 1:1
    clr.b d0
    move.w #256-1,d7
    .onechar:
      move.b d0,(a0)+
      add.b #1,d0
    dbra d7,.onechar
  
    ; map back lower case to upper case
    move.b #33+32,d0
    add.w #64+32,a1
    move.b #7+32,(a1)+ ; apostrophe
    move.w #26-1,d7
    .fixlowercase:
      move.b d0,(a1)+
      add.b #1,d0
    dbra d7,.fixlowercase
    rts

endif

;// sysprint code
;///////////////////////////////////////////////////////////////


waitforfirstline:
	pushd0
  .sync:
  	move.b $FFFF8209.w,d0
	beq.s .sync
	not.b d0
	lsr.b d0,d0
	popd0
	rts


waitforvblwaiter:
; In: d0.w - frame number to wait for
	pushd1
  .wait:
  	move.w vblwaiter,d1
  	cmp.w d0,d1
  	bge .done
  	bsr wait4vbl
	bra .wait
.done:
	popd1
	rts


waitforframe:
; In: d0.w - frame number to wait for
	pushd1
  .wait:
  	move.l framecounter,d1
  	cmp.l d0,d1
  	bge .done
  	bsr wait4vbl
	bra .wait
.done:
	popd1
	rts


if PALETTE_FADING_ENABLE
  fadepalettesaesthetic:
  ; In: a0 - address of target palette
  ;     d0 - number of vbls to wait between steps (routine will take this amount * 15 frames)
  	pushd7
  	bsr fadepalettessetup
  	move.l #16-1,d7
    .onefade:
    	bsr fadepalettesdoonefade
    	pushd0
    	bsr wait4vbld0
    	popd0
  	dbra d7,.onefade
  	popd7
  	rts
  
  
  fadepalettessetup:
  ; In: a0 - address of target palette
  	pushall
  	lea currentpalette,a1
  	lea fadecomponents,a2
  	move.l #16-1,d7
    .onecolor:
    	move.l #0,d0
    	move.w (a1)+,d0
    	bsr fadeconvertste2normal
    	bsr fadecolorsplit
    	move.l d1,d4 ; R
    	move.l d2,d5 ; G
    	move.l d3,d6 ; B
    	move.w (a0)+,d0
    	bsr fadeconvertste2normal
    	bsr fadecolorsplit
    	; Now we have source RGB in d4/d5/d6 and target RGB in d0/d1/d2
    	; R
    	sub.l d4,d1
    	tst.l d1
    	bmi .Rneg
    .Rpos:
    	lea fadetableadd,a3
    	bra .Rgoon
    .Rneg:
    	lea fadetablesub,a3
    	neg.l d1
    .Rgoon:
    	lsl #4,d1
    	add.l d1,a3
    	move.l a3,(a2)+
    	move.w d4,(a2)+
    	; G
    	sub.l d5,d2
    	tst.l d2
    	bmi .Gneg
    .Gpos:
    	lea fadetableadd,a3
    	bra .Ggoon
    .Gneg:
    	lea fadetablesub,a3
    	neg.l d2
    .Ggoon:
    	lsl #4,d2
    	add.l d2,a3
    	move.l a3,(a2)+
    	move.w d5,(a2)+
    	; B
    	sub.l d6,d3
    	tst.l d3
    	bmi .Bneg
    .Bpos:
    	lea fadetableadd,a3
    	bra .Bgoon
    .Bneg:
    	lea fadetablesub,a3
    	neg.l d3
    .Bgoon:
    	lsl #4,d3
    	add.l d3,a3
    	move.l a3,(a2)+
    	move.w d6,(a2)+
  	dbra d7,.onecolor
  	move.w #0,fadetablepos
  	popall
  	rts
  
  
  fadepalettesdoonefade:
  	cmp.w #16,fadetablepos
  	bge .alldone
  	pushall
  	lea fadecomponents,a0
  	lea currentpalette,a1
  	move.l #16-1,d7
    .onecomponent:
    	move.l #0,d0
    	; R
    	move.l (a0),a2
    	add.l #1,(a0)
    	add.l #4,a0
    	move.w (a0)+,d1
    	add.b (a2),d1
    	; G
    	move.l (a0),a2
    	add.l #1,(a0)
    	add.l #4,a0
    	move.w (a0)+,d2
    	add.b (a2),d2
    	; B
    	move.l (a0),a2
    	add.l #1,(a0)
    	add.l #4,a0
    	move.w (a0)+,d3
    	add.b (a2),d3
    	; Put it all together
    	bsr fadecolormerge
    	bsr fadeconvertnormal2ste
    	move.w d0,(a1)+
  	dbra d7,.onecomponent
  	add.w #1,fadetablepos
  	popall
  .alldone:
  	rts
  
  
  fadecolorsplit:
  ; In: d0 - RGB word (normal)
  ; Out: d1 - R
  ;      d2 - G
  ;      d3 - B
  ; Destroys: nothing
  	move.l d0,d1
  	move.l d0,d2
  	move.l d0,d3
  	and.l #$f00,d1
  	lsr.l #8,d1
  	and.l #$0f0,d2
  	lsr.l #4,d2
  	and.l #$00f,d3
  	rts
  
  
  fadecolormerge:
  ; In: d1 - R
  ;     d2 - G
  ;     d3 - B
  ; Out: d0 - RGB word (normal)
  ; Destroys: d1, d2, d3
  	lsl.l #8,d1
  	move.l d1,d0
  	lsl.l #4,d2
  	add.l d2,d0
  	add.l d3,d0
  	rts
  
  
  fadeconvertnormal2ste:
  ; In: d0 - RGB word (normal)
  ; Out: d0 - RGB word (STE)
  ; Destroys: nothing
  	pushd1
  	move.w	d0,d1
  	and.w	#%0000000100010001,d1
  	and.w	#%0000111011101110,d0
  	lsl.w	#3,d1
  	lsr.w	#1,d0
  	add.w	d1,d0
  	popd1
  	rts
  
  
  fadeconvertste2normal:
  ; In: d0 - RGB word (STE)
  ; Out: d0 - RGB word (normal)
  ; Destroys: nothing
  	pushd1
  	move.w	d0,d1
  	and.w	#%0000100010001000,d1
  	and.w	#%0000011101110111,d0
  	lsr.w	#3,d1
  	lsl.w	#1,d0
  	add.w	d1,d0
  	popd1
  	rts
endif


setpalettenextframe:
; In: a0 - point to address of palette
	movem.l a1/d0-d7,-(sp)
	movem.l (a0),d0-d7
	lea currentpalette,a1
	movem.l	d0-d7,(a1)
	movem.l (sp)+,a1/d0-d7
	rts


getrnd: ; random32
; Can't remember where I found this snippet
; In:  nothing
; Out: d0.l - pseudo-random number
  move.l  getrnd_seed(pc),d0
  add.l   D0,D0
  bcc.s   .done
  eori.b  #$AF,D0
.done:
  move.l  D0,getrnd_seed
  rts
getrnd_seed:
  dc.b "XiA!"


clear1bplnoblitter:
; In: a0 - address to bitplane to clear
  pushd0
  pushd7
  pusha0
  move.l #0,d0
  move.l #200-1,d7
  .oneline:
    move.w d0,(a0)
    offs set 8
    rept 19
      move.w d0,offs(a0)
      offs set offs+8
    endr
    add.l #160,a0
  dbra d7,.oneline
  popa0
  popd7
  popd0
  rts


clear1bpl:
; In: a0 - address to clear, bitplane offset already added
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
	rept 16/2
	  clr.l (a6)+
	endr
	move.w #0,$ffff8a20 ;source x inc
	move.w #0,$ffff8a22 ;source y inc
	move.l blanklongword,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #8,$ffff8a2e ;dest x inc
	move.w #8,$ffff8a30 ;dest y inc
	move.l a0,$ffff8a32 ;destination address
	move.w #20,$ffff8a36 ;x count (n words per line to copy)
	move.w #200,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000001,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000000,$ffff8a3b ;blit op (logic op)
	move.b #0,$ffff8a3d ; skew
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts


copy32000noblitter:
; In: a0 - address of image
;     a1 - address of destination
	movem.l d0-d7,-(sp)
	move.l #80-1,d0
  .loop:
  	rept 100
  	  move.l (a0)+,(a1)+
  	endr
	dbra d0,.loop
	movem.l (sp)+,d0-d7
	rts


clearsmokescreennoblitter:
	movem.l a0/d0-d1,-(sp)
	move.l smokescreenaddress,a0
	move.l #0,d1
	move.l #200-1,d0
  .loop:
  	rept 40
  	  move.l d1,(a0)+
  	endr
	dbra d0,.loop
	movem.l (sp)+,a0/d0-d1
	rts


clearscreennoblitter:
	movem.l a0/d0-d1,-(sp)
;	move.l physscreen,a0
  move.l screenaddress,a0
	move.l #0,d1
	move.l #200-1,d0
  .loop:
  	rept 40
  	  move.l d1,(a0)+
  	endr
	dbra d0,.loop
	movem.l (sp)+,a0/d0-d1
	rts


resetblitter:
	pusha0
	pushd7
	move.l #$ffff8a00,a0
	move.l #$3d,d7
  .loop:
  	move.b #0,(a0)+
	dbra d7,.loop
	popd7
	popa0
	rts


copy32000:
; In: a0 - source address
;     a1 - destination address
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
	rept 16/2
	  clr.l (a6)+
	endr
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a0,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #2,$ffff8a30 ;dest y inc
	move.l a1,$ffff8a32 ;destination address
	move.w #80,$ffff8a36 ;x count (n words per line to copy)
	move.w #200,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000010,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000011,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts


clear32000:
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
	rept 16/2
	  clr.l (a6)+
	endr
	move.w #0,$ffff8a20 ;source x inc
	move.w #0,$ffff8a22 ;source y inc
	move.l blanklongword,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #2,$ffff8a30 ;dest y inc
	move.l a0,$ffff8a32 ;destination address
	move.w #80,$ffff8a36 ;x count (n words per line to copy)
	move.w #200,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000001,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000000,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts


clearscreen:
	pusha0
	move.l screenaddress,a0
	bsr clear32000
	popa0
	rts


clearsmokescreen:
	pusha0
	move.l smokescreenaddress,a0
	bsr clear32000
	popa0
	rts


swapscreens:
	move.l a0,-(sp)
;	tst.w whichscreen
;	bne .not1
;	.not0:
;	.not1:
	move.l screenaddress,a0
	move.l smokescreenaddress,screenaddress
	move.l a0,smokescreenaddress
	move.l (sp)+,a0
	rts


wait4vbld0:
; In: d0 - number of vbls to wait-1 (i e prepared for dbra)
; Destroys: d0
  .onevbl:
  	bsr wait4vbl
	dbra d0,.onevbl
	rts


wait4vbl:
	move.w #$1,vblflag
  .loop:
  	cmp.w #0,vblflag
	bne .loop
	rts


;///////////////////////////////////////////////////////////////////////////////////////////////
;// Interrupts

vbl:
	movem.l a0/d0-d7,-(sp)
	move.w #$0,vblflag
	lea currentpalette,a0
	movem.l (a0),d0-d7
	movem.l d0-d7,$ffff8240

	move.l #$ffff8203,a0
	move.l screenaddress,d0
	movep.l d0,(0,a0)

	movem.l (sp)+,a0/d0-d7
	add.l #1,framecounter
	add.w #1,vblwaiter
	pusha0
	move.l vblextra,a0
	jsr (a0)
	popa0
	cmp.b #$2a,$fffffc02
	beq exitall
	rte


hbl:
timer_a:
timer_b:
timer_c:
timer_d:
acia:
  rte

blank_vbl:
  rts

;// Interrupts
;///////////////////////////////////////////////////////////////////////////////////////////////



if ICE_ENABLE
  deice:
  ; In: a0 - address of packed data
  ;     a1 - address to unpack to
  	include "_inc/ice.s"
endif


if XA_ENABLE
  	include "_inc/xa03.s"
endif


if PIXELS_ENABLE
  ;putpixel
  ; In: d0 - x
  ;     d1 - y
  ;     d2 - color
  ;     a0 - address to screen
  ;
  ;putpixeldontdark
  ; In: same as putpixel, but this one doesn't set pixel if color is lower than existing pixel
  ;
  ;getpixel
  ; In: d0 - x
  ;     d1 - y
  ;     a0 - address to screen
  ; Out:d2 - color
	include "_inc\\putpixel.s"
endif


if MATH_ENABLE
  include "_inc/mth68000.s"
endif

;///////////////////////////////////////////////////////////////
;// ARJ mode 7
if ARJ_ENABLE

  dearj:
  ; In: a0 - address of packed data
  ;     a1 - address to unpack to
  	include "_inc/arjmode7.s"

endif
;// ARJ mode 7
;///////////////////////////////////////////////////////////////


;//
;///////////////////////////////////////////////////////////

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

	.data



if PALETTE_FADING_ENABLE
  fadecomponents: ; 288 bytes
  	rept 16
  	dc.l 0 ; address of fadetable
  	dc.w 0 ; R
  	dc.l 0 ; address of fadetable
  	dc.w 0 ; G
  	dc.l 0 ; address of fadetable
  	dc.w 0 ; B
  	endr
  
  
  fadetableadd: ; 272 bytes
  ; fadetable positive values
   dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
   dc.b 0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1
   dc.b 0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2
   dc.b 0,0,1,1,1,1,1,2,2,2,2,2,2,3,3,3
   dc.b 0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4
   dc.b 0,1,1,1,2,2,2,3,3,3,3,4,4,4,5,5
   dc.b 0,1,1,2,2,2,3,3,3,4,4,5,5,5,6,6
   dc.b 0,1,1,2,2,3,3,4,4,4,5,5,6,6,7,7
   dc.b 1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8
   dc.b 1,1,2,2,3,3,4,5,5,6,6,7,7,8,8,9
   dc.b 1,1,2,3,3,4,4,5,6,6,7,8,8,9,9,10
   dc.b 1,1,2,3,3,4,5,6,6,7,8,8,9,10,10,11
   dc.b 1,2,2,3,4,5,5,6,7,8,8,9,10,11,11,12
   dc.b 1,2,2,3,4,5,6,7,7,8,9,10,11,11,12,13
   dc.b 1,2,3,4,4,5,6,7,8,9,10,11,11,12,13,14
   dc.b 1,2,3,4,5,6,7,8,8,9,10,11,12,13,14,15
   dc.b 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
  	even
  
  
  fadetablesub: ; 272 bytes
  ; fadetable negative values
   dc.b -0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,0
   dc.b -0,-0,-0,-0,-0,-0,-0,-1,-1,-1,-1,-1,-1,-1,-1,-1
   dc.b -0,-0,-0,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2
   dc.b -0,-0,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-3,-3,-3
   dc.b -0,-1,-1,-1,-1,-2,-2,-2,-2,-3,-3,-3,-3,-4,-4,-4
   dc.b -0,-1,-1,-1,-2,-2,-2,-3,-3,-3,-3,-4,-4,-4,-5,-5
   dc.b -0,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-5,-5,-5,-6,-6
   dc.b -0,-1,-1,-2,-2,-3,-3,-4,-4,-4,-5,-5,-6,-6,-7,-7
   dc.b -1,-1,-2,-2,-3,-3,-4,-4,-5,-5,-6,-6,-7,-7,-8,-8
   dc.b -1,-1,-2,-2,-3,-3,-4,-5,-5,-6,-6,-7,-7,-8,-8,-9
   dc.b -1,-1,-2,-3,-3,-4,-4,-5,-6,-6,-7,-8,-8,-9,-9,-10
   dc.b -1,-1,-2,-3,-3,-4,-5,-6,-6,-7,-8,-8,-9,-10,-10,-11
   dc.b -1,-2,-2,-3,-4,-5,-5,-6,-7,-8,-8,-9,-10,-11,-11,-12
   dc.b -1,-2,-2,-3,-4,-5,-6,-7,-7,-8,-9,-10,-11,-11,-12,-13
   dc.b -1,-2,-3,-4,-4,-5,-6,-7,-8,-9,-10,-11,-11,-12,-13,-14
   dc.b -1,-2,-3,-4,-5,-6,-7,-8,-8,-9,-10,-11,-12,-13,-14,-15
   dc.b -1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16
  	even
  
  
  fadetablepos:
  	dc.w 0
endif



allwhitepal:
	dc.w $0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff
	dc.w $0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff

allblackpal:
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

bwpal:
	dc.w	$0000,$0888,$0111,$0999,$0222,$0AAA,$0333,$0BBB
	dc.w	$0444,$0CCC,$0555,$0DDD,$0666,$0EEE,$0777,$0FFF

testpal:
  dc.w 0
  dcb.w 15,$fff

santapal_grafx2:
;Palette of SANTAP~1.NEO: Saved by NEOchrome V2.27 by Chaos, Inc.
		dc.w	$00F0,$0FFF,$0700,$0880,$0555,$0050,$0030,$0333
		dc.w	$04F4,$0FFF,$0F44,$0CC4,$0FFF,$04F4,$0474,$0777

santapal_only_snowflakes:
  dcb.w 8,$0f0
  dcb.w 8,$4f4

santapal:
  dcb.w 16,0

allgreenpal:
  dcb.w 16,$0f0

nightly_snowflakespal:
  dcb.w 8,$000
  dcb.w 8,$fff

blanklongword:
	dc.l 0 

testlongword:
  dcb.b 4,$aa

;///////////////////////////////////////////////////////////////
;// sysprint DATA
if SYSPRINT_ENABLE
  sysprint_font:
      if !PROPFONT_ENABLE
        incbin "sysprint_font.bin" ; 295 bytes
        even
      endif
endif
;// sysprint DATA
;///////////////////////////////////////////////////////////////
;// propfont data
if PROPFONT_ENABLE

  propfont_font:  
    iif PROPFONT_FONT_SELECT=PROPFONT_FONT_PER02, include "_inc/propfont/propfont_font02.s" ; Per02
    iif PROPFONT_FONT_SELECT=PROPFONT_FONT_PER, include "_inc/propfont/propfont_font03.s" ; Per
    iif PROPFONT_FONT_SELECT=PROPFONT_FONT_MV_BOLI, include "_inc/propfont/propfont_font04.s" ; MV Boli
    iif PROPFONT_FONT_SELECT=PROPFONT_FONT_PALATINO, include "_inc/propfont/propfont_font05.s" ; Palatino Linotype
    iif PROPFONT_FONT_SELECT=PROPFONT_FONT_CALIBRI_LIGHT, include "_inc/propfont/propfont_font06.s" ; Calibri Light
    iif PROPFONT_FONT_SELECT=PROPFONT_FONT_MACINTOSH_1984, include "_inc/propfont/propfont_font07.s" ; Macintosh 1984
    iif PROPFONT_FONT_SELECT=PROPFONT_FONT_ZX_SPECTRUM, include "_inc/propfont/propfont_font08.s" ; ZX Spectrum
    iif PROPFONT_FONT_SELECT=PROPFONT_FONT_MSX, include "_inc/propfont/propfont_font09.s" ; MSX
    iif PROPFONT_FONT_SELECT=PROPFONT_FONT_ATARI_8BIT, include "_inc/propfont/propfont_font10.s" ; Atari 8-bit
  
endif
;// propfont data
;///////////////////////////////////////////////////////////////
;// timing markers

timing_markers:
  dc.w 2,35,69,101,135,168,202,234
  dc.w 268,301,335,368,401,434,467,501
  dc.w 534,567,600,634,667,700,734,767
  dc.w 785,818,835,868,902,935,968,1001
  dc.w 1018,1035,1067,1101,1134,1167,1201,1234
  dc.w 1267,1300,1334,1367,1401,1434,1467,1499
  dc.w 1533,1566,1599,1633,1666,1699,1733,1766
  dc.w 1799,1833,1850,1884,1900,1934,1968,2001
  dc.w 2034,2067,2084,2100,2133,2166,2200,2233
  dc.w 2266,2300,2333,2366,2400,2432,2466,2500
  dc.w 2533,2565,2598,2632,2665,2699,2732,2765
  dc.w 2798,2832,2865,2899,2916,2950,2966,2999
  dc.w 3033,3066,3100,3133,3150,3166
  dc.w -1

timing_marker_pos:  dc.l 0

;// timing markers
;///////////////////////////////////////////////////////////////


bios_logo_xa:
  incbin "bios_logo.xa"
  even

santa1_xa:
  incbin "santa1.xa"
  even

santa2_xa:
  incbin "santa2.xa"
  even

santa3_xa:
  incbin "santa3.xa"
  even

santa4_xa:
  incbin "santa4.xa"
  even
  
lit_tree_xa:
  incbin "lit_tree_xa.xa"
  even

lightpath_xa:
  incbin "lightpath_xa.xa"
  even


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

	.bss

;-- system stuff...
  include "_inc/endbss.s"

old_820f: ds.b 1
  even

;physscreen ds.l 1
framecounter:         ds.l 1
currentpalette:	      ds.w 16
vblflag:	            ds.w 1
vblwaiter:            ds.w 1
vblextra:             ds.l 1
whichscreen:          ds.w 1
screenaddress:        ds.l 1
smokescreenaddress:   ds.l 1
	ds.b 256
smokescreen1:         ds.b 32000
smokescreen2:         ds.b 32000

ytable:               ds.l 200


;///////////////////////////////////////////////////////////////
;// ARJ mode 7
if ARJ_ENABLE

  arjbuffer:
  	ds.b 11312

endif
;// ARJ mode 7
;///////////////////////////////////////////////////////////////
;// sysprint BSS
if SYSPRINT_ENABLE

  sysprint_x:         ds.w 1
  sysprint_y:         ds.w 1
  sysprint_charmap:   ds.b 256

endif
;// sysprint
;///////////////////////////////////////////////////////////////
;// propfont BSS
if PROPFONT_ENABLE

  propfont_x:        ds.w 1
  propfont_x_min:    ds.w 1
  propfont_x_max:    ds.w 1
  propfont_y:        ds.w 1
  
  propfont_fontpostable:
    ds.w PROPFONT_FONTCHARSLINES*10
  
  propfont_fontwidthtable:
    ds.w PROPFONT_FONTCHARSLINES*PROPFONT_FONTCHARSPERLINE
  
  propfont_fontwidthconvertertable:
    ds.w 17*2
  
  propfont_fonttempchar:
    ds.l PROPFONT_FONTHEIGHT

endif
;// propfont BSS
;///////////////////////////////////////////////////////////////
;// File loading
if FILE_LOAD_ENABLE
  
  file_load_handle:
    ds.w 1
  
endif
;// File loading
;///////////////////////////////////////////////////////////////
;// Music

music_start:
music0:     ds.b 720000
music1:     ds.b 348096
music_end:

;// Music
;///////////////////////////////////////////////////////////////
;// Screens - old

santa_1a:     ds.b 32000
santa_1b:     ds.b 32000
santa_2a:     ds.b 32000
santa_2b:     ds.b 32000
santa_3a:     ds.b 32000
santa_3b:     ds.b 32000
santa_4a:     ds.b 32000
santa_4b:     ds.b 32000

;// Screens - old
;///////////////////////////////////////////////////////////////
;// Snowflakes

snowflake_large_all:
  ds.b 64*SNOWFLAKE_LARGE_BYTESIZE ; 64 frames

snowflake_medium_all:
  ds.b 64*SNOWFLAKE_MEDIUM_BYTESIZE ; 64 frames

snowflake_small_all:
  ds.b 64*SNOWFLAKE_SMALL_BYTESIZE ; 64 frames

snowflake_extra_small_all:
  ds.b 64*SNOWFLAKE_EXTRA_SMALL_BYTESIZE ; 64 frames

snowflake_structs:
  ds.b NUM_SNOWFLAKES*SNOWFLAKE_STRUCT_SIZE
  ds.l 1 ; for final endmarker

;------------------------------
;-- snowflake area
; total size: 356368

junkarea:

snowflake_large_xa:
  ds.b 232400

snowflake_medium_xa:
  ds.b 95508

snowflake_small_xa:
  ds.b 21884

snowflake_extra_small_xa:
  ds.b 6576

;-- snowflake area
;------------------------------

snowflake_tilt_xa:
  ds.b 176182
;  incbin "snowflake_tilt_1bpl.xa"
;  even

;// Snowflakes
;///////////////////////////////////////////////////////////////
;// Screens

ytablehuge:   ds.l 600

visible_screen_start equ (200*hugescreenlinewidth)+104
hugescreenbuffer:
  center_screen_size equ (320*200)/2
  side_screen_size equ (208*200)/2
  sides_size equ side_screen_size*6
  centers_size equ center_screen_size*3
  buffer_size set sides_size+centers_size
  hugescreenbuffer0:
    ds.b buffer_size
  hugescreenbuffer1:
    ds.b buffer_size
  hugescreenbuffer2:
    ds.b buffer_size
  hugescreenbuffer3:
    ds.b buffer_size
;    +--------+----------+--------+
;    |208x200 |320x200   |208x200 |
;    |        |          |        |
;    +--------+----------+--------+
;    |208x200 |320x200   |208x200 |
;    |        |          |        |
;    +--------+----------+--------+
;    |208x200 |320x200   |208x200 |
;    |        |          |        |
;    +--------+----------+--------+

unpackbuffer:
  ds.b 32000
;    +----------+
;    |320x200   |
;    |          |
;    +----------+

;// Screens
;///////////////////////////////////////////////////////////////




