;
;   Dbug crap comeback to Atari coding
; for Creators participation in DHS compo
;            20 september 2005
;


;
; Screen Display
; $FFFF8201  r/w  |xxxxxxxx|          Video base high
; $FFFF8203  r/w  |xxxxxxxx|          Video base medium
; $FFFF8205  r    |..xxxxxx|          Video address counter high (r/w on STe)
; $FFFF8207  r    |xxxxxxxx|          Video address counter med (r/w on STe)
; $FFFF8209  r    |xxxxxxx.|          Video address counter low (r/w on STe)
; $FFFF820A  r/w  |......xx|          Sync mode (changing this value tends to cause issues on TT, like black screen and crash)
;                        ||__________ External/Internal sync
;                        |___________ 50/60Hz
; 
; $FFFF820D  r/w  |xxxxxxx.|          STe video base low
; $FFFF820F  r/w  |xxxxxxxx|          STe over-length line width
; $FFFF8240  r/w  |....xxxxxxxxxxxx|  Palette colour (1 word each, first of 16)
;                      ||  ||  ||____ Blue intensity (0-7)
;                      ||  ||  |_____ STe blue LSB
;                      ||  ||________ Green intensity (0-7)
;                      ||  |_________ STe green LSB
;                      ||____________ Red intensity (0-7)
;                      |_____________ STe red LSB
; 
; $FFFF8260  r/w  |......xx|          Screen resolution
;                        |___________ 0 - 320x200x4
;                                     1 - 640x200x2
;                                     2 - 640x400x1
;
; $FFFF8262  r/w  |....xxxxxxxxxxxx|  TT resolution
; 
; $FFFF8264  r/w  |....xxxx|          Undocumented STE pixel hard scroll
; $FFFF8265  r/w  |....xxxx|          STE pixel hard scroll
; 
; MEGA STE
; ========
; The Mega STE has a register to control speed and cach status:
;  $FFFF8E21  - - - -  - - X X
; Bit 0 controls the clockspeed (0 = 8 MHz, 1 = 16 MHz), the upper bit controls the cache (0 = Cache off, 1 = cache on). 
; Some docs say that all upper 15 bits of $FFFF8E20 need to be set to "1" to turn the cache on. 
; Writing to this register in anything but a Mega STE will most probably lead to a crash, so be sure to check the Cookie Jar for _MCH 
; to estimate wether this is a Mega STE or not (Upper word is 1 for STE, lower word is 0x0010 for Mega STE, 0x0000 for anything else).



; ST Overscan    =416*276
; Falcon Overscan=384*240

reroute_exceptions		equ 0			; Set to 1 to use internal exception handling
reroute_traps			equ 0			; Set to 1 to use internal traps handling
enable_fast_assembly	equ 1
enable_steembreak		equ 0
enable_boundschecker	equ 0
enable_colorhelpers		equ 0
enable_rasters			equ 1
enable_intro			equ 1
force_non_overscan		equ 0

 opt o+,w-

;
; Demo parameters
;
SCROLLER_HEIGHT	equ 24


; ================================
;         Machine detected
; ================================

MACHINE_ST 		equ 0
MACHINE_TT		equ 1
MACHINE_FALCON	equ 2
MACHINE_WEIRD	equ 3


; ================================
;         Utility macros
; ================================

 ifne enable_fast_assembly
pause macro		; Fast mode 
 dcb.w \1,$4e71
 endm
 elseif
pause macro		; Slow mode 
t6 set (\1)/6
t5 set (\1-t6*6)/5
t4 set (\1-t6*6-t5*5)/4
t3 set (\1-t6*6-t5*5-t4*4)/3
t2 set (\1-t6*6-t5*5-t4*4-t3*3)/2
t1 set (\1-t6*6-t5*5-t4*4-t3*3-t2*2)
 dcb.w t6,$e188  ; lsl.l #8,d0				<=== not neutral !!!
 dcb.w t5,$ed88  ; lsl.l #6,d0				<=== not neutral !!!
 dcb.w t4,$e988  ; lsl.l #4,d0				<=== not neutral !!!
 dcb.w t3,$1090  ; move.b (a0),(a0)
 dcb.w t2,$8080  ; move.b d0,d0
 dcb.w t1,$4e71  ; nop
 endm
 endc



BREAK macro
 dc.w $31fc	; move.w #..,$...w
 dc.w 1		; #1
 dc.w 1		; $1
 endm

STEEMBREAK macro
 ifne enable_steembreak
 move.b #1,$FFC123
 endc
 endm

COLORHELP macro
 ifne enable_colorhelpers
 move.w \1,$ffff8240.w
 endc
 endm

COLORSWAP macro
 ifne enable_colorhelpers
 neg.w $ffff8240.w
 endc
 endm

;
; Check if an adress register is between adequate boundaries
;
BOUNDCHECK macro
 ifne enable_boundschecker
 move.l \1,BCValue
 move.l \2,BCLow
 move.l \3,BCHigh
 jsr BoundChecks
 endc
 endm

; 
; Transforms a PC like RGB 24 bits colors
; in a STE color.
; \1 = red
; \2 = green
; \3 = blue
MAKERGB macro
var_r set (((\1)&255)>>4)
var_g set (((\2)&255)>>4)
var_b set (((\3)&255)>>4)
var_r set ((var_r>>1)+((var_r&1)<<3))
var_g set ((var_g>>1)+((var_g&1)<<3))
var_b set ((var_b>>1)+((var_b&1)<<3))
 dc.w (((var_r)&15)<<8)+(((var_g)&15)<<4)+((var_b)&15)
 endm
 
	 
 ;jmp MaskFontTest

 ;
 ; Call the main routine
 ;
 move.l #super_main,-(sp)
 move #$26,-(sp)
 trap #14
 addq #6,sp

 ;
 ; Quit
 ;
 clr -(sp)
 trap #1
	

BCValue	ds.l 1
BCLow	ds.l 1
BCHigh	ds.l 1

;
; d1<=d0<=d2
BoundChecks
 movem.l d0-d2,-(sp)
 movem.l BCValue,d0-d2 
 cmp.l d0,d1
 beq .exit
 bcc .crash
 cmp.l d0,d2
 bcc .exit

.crash
 move.w #$700,$ffff8240.w
 move.l a0,d1
 move.l #1,a0
 move.l #0,(a0)				; Provoke some error :)
 move.l d1,a0
 
.exit
 movem.l (sp)+,d0-d2
 rts

	
	
super_main
 ;
 ; This has to be done first, else we will lose data
 ; We need to start by clearing the BSS in case of some packer let some crap
 ;
 jsr ClearSectionBSS
 
 ;
 ; Can now safely save the stack pointer and allocate our own stack.
 ; This is practical to 
 ;
 move.l sp,save_ssp
 lea my_stack,sp 					
 
 ;
 ; We need to know on which machine we are running the intro
 ;
 jsr DetectMachine
 
 ;move.b #MACHINE_ST,machine_type		; Force Overscan
 ifne force_non_overscan
 move.b #MACHINE_WEIRD,machine_type	; Force non overscan
 endc
 
 jsr SetupMachineParameters
 jsr PatchPrecalTables
  
 
 ;
 ; Ignore all interrupt requests
 ; 
 jsr SaveSystem 					

 jsr SetSystemParameters
 jsr FlushKeyboardBuffer

 move.l #routine_vbl_nothing,$70.w
 jsr screen_choc				; Shake up baby !

 jsr main


;
; Restaure everything
;
fin_demo
 jsr WaitVbl
 move.l #routine_vbl_nothing,$70.w
 jsr screen_choc

 jsr FlushKeyboardBuffer
 jsr RestoreSystem 					
 
 move.l save_ssp,sp
 rts


  
;
; The Cookie Jar can be used to detect the type of machine.
; This feature was first implemented on the STE.
; So if the Cookie Jar is missing we can safely assume we are
; running on a STF machine.
; 
; http://leonard.oxg.free.fr/articles/multi_atari/multi_atari.html
; Cookie Value     Description 
; _MCH   $0000xxxx STf 
; _MCH   $00010000 STe 
; _MCH   $00010010 Mega-STe ( only bit 4 of the 32bits value tells it's a Mega-STE ) 
; _MCH   $0002xxxx TT 
; _MCH   $0003xxxx Falcon 
; CT60   $xxxxxxxx CT60 

DetectMachine 
 move.l	$5a0.w,d0
 bne.s .found_cookie
 bra.s .found_st 

 ; No cookie, this is a ST
.found_mste
 st.b machine_is_mste 
.found_ste 
.found_st 
 move.b #MACHINE_ST,machine_type
 rts

 ; Machine with a cookie jar pointer 
 ; but no valid data. That maybe a ST,
 ; but that also maybe a garbaged machine,
 ; so we better avoid overscan and stuff 
 ; like this => safe code path
.found_unknown
 move.b #MACHINE_WEIRD,machine_type
 rts

.found_tt
 st.b machine_is_tt
 move.b #MACHINE_TT,machine_type
 rts

.found_falcon_ct60 
 st.b machine_is_ct60
.found_falcon
 move.b #MACHINE_FALCON,machine_type
 rts
  
.found_cookie
 
 ; We found a cookie pointer, this is not a ST for sure
 move.l	d0,a0
.loop_cookie	
 move.l (a0)+,d0			; Cookie descriptor
 beq.s	.found_unknown
 move.l (a0)+,d1			; Cookie value
 
 cmp.l	#"CT60",d0
 beq.s	.found_falcon_ct60
 cmp.l	#"_MCH",d0
 beq.s	.found_machine
 bra.s	.loop_cookie
 
.found_machine	
 cmp.l #$00010000,d1
 beq.s .found_ste
 cmp.l #$00010010,d1
 beq.s .found_mste
 swap d1
 cmp.w #$0002,d1
 beq.s .found_tt
 cmp.w #$0003,d1
 beq.s .found_falcon
 bra.s .found_unknown

 
 ;
 ; Basicaly we allow overscan on ST, STE and MSTE
 ; Everything else will have to use standard hbl codepath
 ;
SetupMachineParameters 
 move.b machine_type,d0
 cmp.b #MACHINE_ST,d0
 beq.s .overscan_setup
  
.non_overscan_setup
 sf.b overscan_is_allowed
 
 move.w #0,base_screen_offset
 move.w #20-1,blocs_per_scanline
 move.w #40-1,bytesblocs_per_scanline
 move.w #160,overscan_line_width
 move.w #200-1,lines_per_screen
 move.w #32,offset_centering
 move.l #27<<2,scroller_buffer_offset
 move.w #160*10,screen_display_scroller_offset
 rts

.overscan_setup
 st.b overscan_is_allowed
 
 move.w #160,base_screen_offset
 move.w #28-1,blocs_per_scanline
 move.w #52-1,bytesblocs_per_scanline
 move.w #51-1,bytesblocs_per_scanline
 move.w #230,overscan_line_width
 move.w #199-1,lines_per_screen
 move.w #0,offset_centering
 move.l #16<<2,scroller_buffer_offset
 move.w #230*10,screen_display_scroller_offset
 rts

PatchPrecalTables
 lea table_sinus_160x40,a0
 lea table_sinus_160x176,a1
 move.w #256-1,d7
.loop_patch
 move (a0),d0
 mulu overscan_line_width,d0
 move d0,256*2(a0)
 move d0,(a0)+
 
 move (a1),d0
 mulu overscan_line_width,d0
 move d0,256*2(a1)
 move d0,(a1)+
 
 dbra d7,.loop_patch 
 rts
  

WaitVbl
 sf flag_vbl
.loop
 tst.b flag_vbl
 beq.s .loop
 rts

FlipScreen   
 move.l d0,-(sp)
 move.l d1,-(sp)
 move.l a0,-(sp)
 
 move.l ptr_scr_1,d0
 move.l ptr_scr_2,d1

 move.l d1,ptr_scr_1
 move.l d0,ptr_scr_2
 
 lsr.l #8,d0					; Allign adress on a byte boudary for STF compatibility
 lea $ffff8201.w,a0				; Screen base pointeur (STF/E)
 movep.w d0,(a0)				; Write new adress
 
 move.l (sp)+,a0
 move.l (sp)+,d1
 move.l (sp)+,d0
 rts

screen_choc
 jsr WaitVbl
 sf $ffff8260.w
 tst.b machine_is_tt
 bne.s .exit
 sf $ffff820a.w
 jsr WaitVbl
 jsr WaitVbl
 move.b #2,$ffff820a.w
 jsr WaitVbl
 jsr WaitVbl
 jsr WaitVbl
 sf $ffff820a.w
 jsr WaitVbl
 jsr WaitVbl
 jsr WaitVbl
 move.b #2,$ffff820a.w
.exit 
 rts 
 

main
 ;
 ; Do a clean fade out from wherever we come to black
 ;
 jsr FadeToBlack
 jsr FlipScreen
 
 ;
 ; Start the music
 ;
 lea music,a0
 jsr 0(a0)
 st.b music_is_initialised 
 
 ifne enable_intro
 ;
 ; Call the 1985-2005 intro code
 ;
 jsr FadeIntro19852005
 endc
 
 ;
 ; Display the scroller
 ;
 jsr MegaScroller
 
 ;
 ; Stop the music
 ;
 sf.b music_is_initialised
 lea music,a0
 jsr 4(a0)

 COLORHELP #$333
 rts


 
 
MegaScroller 
 jsr FadeToBlack
 move.l #routine_vbl_nothing,$70.w

 ;
 ; Some prerequired cleaning up before generating stuff
 ;
 jsr EraseScreen
 jsr EraseBufferScroll

 ;
 ; Precompute stuff
 ;
 lea font+34,a0
 jsr DisplayPicturePi1
 jsr MaskFontTest

 jsr DrawBackgroundPattern

 ifeq enable_intro
 ;
 ; This takes a LOT of time to generate.
 ; We compute it during the Atari logo display as a temporisation.
 ; But in case the intro is disabled, we need to computer the buffer somewhere else
 ;
 jsr GenerateMegaPalettes
 endc


 ;
 ; Initialise the scroller
 ;
 move.l #buffer_font,ptr_scroller_bitmap_prev
 move.l #black_palette,ptr_scroller_bitmap
 move.b #0,scroller_parameter_speed
 
 move.b #0,scroller_read_pixel
 move.b #0,scroller_write_pixel
 
 move.b #0,sinus_global_vertical_speed
 
 move.b #0,scroller_rotation_angle
 move.b #0,scroller_rotation_speed

 move.l #message_scroller,ptr_scroller_letter
 sf scroller_column_counter
 sf scroller_pause_counter


 ;
 ; Initialise the fade colors
 ;
 move.b #1,palette_speed
 move.b #0,palette_index
 move.b #15,palette_fade_index	; 15=>black 0=>full colors
 move.b #-1,palette_fade_flag

       
 sf flag_exit
 
 ;
 ; Depending of the machine we use the overscan or non overscan codepath
 ;
 tst.b overscan_is_allowed
 beq.s .simple_scroller
.overscan_scroller
 jsr TestScrollerOverscan		; Overscan scroller
 bra .end_scroller 
.simple_scroller
 jsr SimpleScroller			; Non overscan scroller
.end_scroller 
 rts
 
 

 
GenerateMegaPalettes
 lea gradient_picture_startup,a0	; The black default crap
GenerateMegaPalettesSub 
 lea buffer_palette,a1
 move.w #200*8,d7
 jsr RawToSt
 jsr GenerateMegaFade
 jsr GenerateMegaShift
 rts 
 

ManageParalaxColors
 ; ugly fade blink on background scroller
 move.b palette_fade_index,d0
 move.b palette_fade_flag,d1
 beq .end_background_fade
 cmp.b #1,d1
 beq .up_background_fade
 
 ;
 ; Fade to max palette intensity
 ; 
.down_background_fade 
 subq.b #1,d0
 bne .end_background_fade
 sf palette_fade_flag
 bra .end_background_fade
 
 ;
 ; Fade to black
 ; 
.up_background_fade
 addq.b #1,d0
 cmp.b #15,d0
 bne .end_background_fade
 ; Reached the black 
 sf palette_fade_flag
 move.b d0,palette_fade_index
 ; Test if we have a subpart to run
 move.l scroller_subpart_ptr,d0
 bne.s .run_subpart
 rts
  
.end_background_fade
 move.b d0,palette_fade_index
 rts
 
.run_subpart
 move.l d0,a0
 
 ;
 ; Save a context that can be painfull depending of the code path we have
 ;
 move.w sr,-(sp)
 move.l $70.w,-(sp)

 move.l a0,-(sp)
 ;
 ; Enable a "safe" display
 ;
 ; Fade to black
 move.l #routine_vbl_nothing,$70.w
 move #$2300,sr
 
 tst.b overscan_is_allowed
 bne.s .overscan
 jsr WaitVbl
 sf $fffffa1b.w				; TBCR Event mode => disable
.overscan 
 movem.l black_palette,d0-d7				; STF/STE Palette
 movem.l d0-d7,$ffff8240.w

 ;
 ; Run the subpart
 ;
 move.l (sp)+,a0
 jsr (a0)
 
 ;
 ; Restore a background display stuff
 ;
 jsr DrawBackgroundPattern
 
 ;
 ; Restore the palette of scroller
 ;
 move.l ptr_scroller_current_palette,a1
 jsr Effect_set_setpalette_Sub
 
 ;
 ; Set the fade flag again
 ;
 move.b #-1,palette_fade_flag
 
 ;
 ; Restore the context
 ;
 move.l (sp)+,$70.w
 move.w (sp)+,sr
 
 rts
  

ManageNextLetter
.new_letter_loop
 move.l scroller_write_pixel,d0
 sub.l scroller_read_pixel,d0
 cmp.l #24,d0
 bpl .far_enough
 ; New letter
 jsr ScrollerNextFrame
 addq.l #8,scroller_write_pixel
 bra .new_letter_loop
.far_enough 
 rts

ManageScrollerSpeed
 move.b scroller_pause_counter,d0
 beq .move_scroller
 subq #1,d0
 move.b d0,scroller_pause_counter 
 bra .end_move_scroller  
 
.move_scroller 
 moveq.l #1,d1
 add.b scroller_parameter_speed,d1
 add.l d1,scroller_read_pixel
.end_move_scroller  
 rts     

SimpleScroller
 move.l #routine_vbl_rasters_complex,$70.w
 ;move.l #routine_vbl_nothing,$70.w
 
.scroll_loop
 jsr ManageNextLetter
 COLORHELP #$030
 jsr BlitScrollBufferSinusPush
 COLORHELP #$003
 jsr BlitScrollBufferSinusPop
 COLORHELP #$300
 
 COLORHELP #$033
 jsr DisplayMirror
 COLORHELP #$000
  
  
 jsr ManageScrollerSpeed
 jsr ManageParalaxColors

 jsr FlipScreen
 jsr WaitVbl
 
 btst #0,$fffffc00.w			; Have we some keys to wait for ?
 beq.s .skip_key
 cmp.b #$39+128,$fffffc02.w
 beq.s .exit
.skip_key 
 move.b flag_exit,d0
 beq .scroll_loop
.exit
 rts


FlushKeyboardBuffer
 btst #0,$fffffc00.w			; Have we some keys to wait for ?
 beq.s .exit
 tst.b $fffffc02.w
 bra.s FlushKeyboardBuffer
.exit
 rts


 
SubPartSweaty
 ; Display the picture
 lea picture_sweaty+34,a0
 jsr DisplayPicturePi1
 jsr FlipScreen
 jsr WaitVbl
 
 ; Fade to colors
 lea $ffff8240.w,a0
 lea picture_sweaty+2,a1
 moveq #16,d7
 jsr ComputeGradient
 move.l #routine_vbl_fade,$70.w
 jsr WaitEndOfFade

 ; Wait a bit, fade to black 
 move #50*4,d0
 jsr WaitDelay
 jsr FadeToBlack
 
 ; Exit
 rts 

 
SubPartSetBackgroundMike
 lea gradient_picture_mike,a0
 jsr GenerateMegaPalettesSub
 rts 

SubPartSetBackgroundHanne
 lea gradient_picture_hanne,a0
 jsr GenerateMegaPalettesSub
 rts 
 
SubPartSetBackgroundTriplex
 lea gradient_picture_triplex,a0
 jsr GenerateMegaPalettesSub
 rts 

SubPartSetBackgroundMatrix
 lea gradient_picture_matrix,a0
 jsr GenerateMegaPalettesSub
 rts 
 
SubPartSetBackgroundNormal
 lea gradient_picture,a0
 jsr GenerateMegaPalettesSub
 rts 

SubPartSetBackgroundGreetings
 lea gradient_picture_greetings,a0
 jsr GenerateMegaPalettesSub
 rts 
 
SubPartSetBackgroundPtoing
 lea gradient_picture_ptoing,a0
 jsr GenerateMegaPalettesSub
 rts 
 
   
;
; Called once at the initialization.
; Simply fills the whole 8 buffers used for scrolling
; with a bit pattern that is equivalent to filling it 
; with pixels of color 8 to 15, repetitively.
;
EraseBufferScroll
 move.l #%01010101001100110000111111111111,d0	; Plans 0 and 1
 
 lea buffer_scroller,a0
  
 move #(buffer_scroller_end-buffer_scroller)/8-1,d7	; 256*24*8
.erase_loop
 move.l d0,(a0)+
 move.l d0,(a0)+
 dbra d7,.erase_loop
 rts


Effect_restart_scroller
 move.l #message_scroller,a0
 rts

Effect_set_speed
 move.b (a0)+,scroller_parameter_speed
 rts

Effect_set_stop
 move.b (a0)+,scroller_pause_counter
 rts
 
Effect_set_setpalette
 ;move.b (a0)+,d0		; Trash gradient speed for the moment
 move.l a0,d0
 addq.l #1,d0
 and.l #$FFFFFFFE,d0
 move.l d0,a0
 move.l (a0)+,a1
 move.l a1,ptr_scroller_current_palette
Effect_set_setpalette_Sub 
 movem.l d0-a6,-(sp)
 lea fade_vbl_palette,a0	; Current palette as source palette (should use a buffer of course)
 moveq #8,d7
 jsr ComputeGradient
 movem.l (sp)+,d0-a6
 rts

Effect_set_globalsinus_speed
 move.b (a0)+,sinus_global_vertical_speed
 rts
 
ZOB 
Effect_run_subpart
 move.l a0,d0
 addq.l #1,d0
 and.l #$FFFFFFFE,d0
 move.l d0,a0
 move.l (a0)+,scroller_subpart_ptr
 move.b #1,palette_fade_flag
 
 ;
 ; Force the scroller to black
 ;
 lea black_palette,a1
 jsr Effect_set_setpalette_Sub
 rts

Effect_set_rotation_speed
 move.b (a0)+,scroller_rotation_speed
 rts
   
Effect_set_rotation_angle
 move.b (a0)+,scroller_rotation_angle
 rts

Effect_set_background_speed
 move.b (a0)+,palette_speed
 rts
 
  
table_effects
 dc.l Effect_restart_scroller
 dc.l Effect_set_speed
 dc.l Effect_set_stop
 dc.l Effect_set_setpalette
 dc.l Effect_set_globalsinus_speed
 dc.l Effect_run_subpart
 dc.l Effect_set_rotation_speed
 dc.l Effect_set_rotation_angle
 dc.l Effect_set_background_speed

  
ScrollerNextFrame
 move.b scroller_column_counter,d0
 bne .draw_column

 ;
 ; We start displaying a new character on screen
 ;
 move.l ptr_scroller_letter,a0

 ; Get character:
 ; - 0 is end of message
 ; - 1 is an effect
 ;
.read_char
 moveq.l #0,d0
 move.b (a0)+,d0
 bne.s .new_char

 ; Read effect code
.set_effect
 move.b (a0)+,d0
 add d0,d0
 add d0,d0
 lea table_effects(pc),a1
 move.l (a1,d0),a1
 jsr (a1)
 jmp .read_char

.new_char
 move.l a0,ptr_scroller_letter

 ; d0 contains pointer on char to initialise
 ; Memorize the informations in the table
 ;lsl #2,d0
 add d0,d0
 add d0,d0
 lea font_array_ptr,a1
 move.l 0(a1,d0),ptr_scroller_bitmap

 lea font_array_info,a1
 move.l 0(a1,d0),a1
 ;move.b (a1)+,d1	 ; Skip Y 
 ;move.b (a1)+,d1	 ; Skip X
 move.b 2(a1),scroller_column_counter	; Get width
 ;move.b (a1)+,d1	 ; Skip height

.draw_column
 ;
 ; Using all set parameters, we start drawing things in buffer !
 ;
 ; Screen pointer
 moveq.l #0,d0
 move.b scroller_frame_counter,d0
 addq.b #4,scroller_frame_counter
 lea buffer_scroller,a2
 add d0,a2

 move.l ptr_scroller_bitmap,a0
 move.l ptr_scroller_bitmap_prev,a3
 move.l a0,ptr_scroller_bitmap_prev

 COLORHELP #$007

 lea TableMaskage_OR,a4

 move.l #%10000000100000001000000010000000,d5
 move.l #%01111111011111110111111101111111,d6
 
 moveq #SCROLLER_HEIGHT-1,d7
.loop_y
 ; Register usage:
 ; d0 =>
 ; d1 =>
 ; d2 =>
 ; d3 =>
 ; d4 => 
 ; d5 => mask AND 2
 ; d6 => mask AND 1
 ; d7 => line counter (from 23 to 0)
 ;
 ; a0 => pointer current column
 ; a1 => 
 ; a2 => base pointer destination buffer
 ; a3 => pointer previous column
 ; a4 => table OR masking
 ; a5 =>
 ; a6 =>
 ; a7 => xxxx stack 

 lea 256*8(a2),a2
 
 BOUNDCHECK a0,#buffer_font,#buffer_font_end

 move.l (a3)+,d1		;		Read prev column
 move.l (a0)+,d0		; 12	Read current column

 move.l d0,d3
 moveq.l #0,d2
 move.b d3,d2
 add d2,d2
 add d2,d2
 or.l 0(a4,d2),d3

 ; 0 [8-0]
var1 set 0 
 move.l d3,var1(a2)		; 16
var1 set var1+256

 rol.l #8,d1

 ; 1 [7-1]
 rept 7
 lsr.l #1,d0
 and.l d6,d0
 ror.l #1,d1
 move.l d1,d2
 and.l d5,d2
 or.l d2,d0

 move.l d0,d3
 moveq.l #0,d2
 move.b d3,d2
 add d2,d2
 add d2,d2
 or.l 0(a4,d2),d3

 move.l d3,var1(a2)		; 16
var1 set var1+256
 endr
 
 COLORSWAP

 dbra d7,.loop_y
 move.l a0,ptr_scroller_bitmap

 sub.b #1,scroller_column_counter
 rts

 
;
; Normal:
; - Start 0
; - Increment 1
; 
; Half normal:
; - Displayed size = 12   (24/2)
;
; Reversed:
; - Start 24
; - Increment -1
;

 
  

 
; 8 bits sinus scroller
BlitScrollBufferSinusPush
 ;
 ; First we need to blit the buffer to screen
 ; 160*
 ;
 COLORHELP #$300

 ;BREAK

 ;
 ; Read the scroller position
 ;
 moveq #0,d0
 move.l d0,d1
 move.l d0,d5
 move.l scroller_read_pixel,d0
 and.l #511,d0
 
 lea table_bits,a0
 add.w d0,d0
 add.w d0,d0
 add.w d0,a0
 move.w (a0)+,d1		; Offset in the right shifted buffer
 move.w (a0)+,d5		; Position in the buffer (multiple of 4)
 
 add.l scroller_buffer_offset,d5
 
  
 ; Table based rotation effect
 moveq.l #0,d2
 move.b scroller_rotation_angle,d2
 add.b scroller_rotation_speed,d2
 move.b d2,scroller_rotation_angle
 
 mulu #SCROLLER_HEIGHT*2,d2
 lea table_rotation_scroller,a1
 add d2,a1
 
 ; with dist
ZOBA 
 tst.b overscan_is_allowed
 bne.s .overscan_patch
.normal_patch  
 pea _base_ref_patch_3
 pea _base_ref_patch_2
 pea _base_ref_patch_1
 bra .do_patch 

.overscan_patch  
 pea _megapatch_3
 pea _megapatch_2
 pea _megapatch_1
  
.do_patch 
 ; Part 1
 move.l (sp)+,a2
var1 set 0
var set 2 
 REPT 8
 move.w (a1)+,d0
 add d1,d0
 move.w d0,var(a2)
var1 set var1+1
var set var+8
 ENDR
 ; Part 2
 move.l (sp)+,a2
var1 set 0
var set 2 
 REPT 8
 move.w (a1)+,d0
 add d1,d0
 move.w d0,var(a2)
var1 set var1+1
var set var+8
 ENDR
 ; Part 3
 move.l (sp)+,a2
var1 set 0
var set 2 
 REPT 8
 move.w (a1)+,d0
 add d1,d0
 move.w d0,var(a2)
var1 set var1+1
var set var+8
 ENDR
 
 lea buffer_scroller+32000,a0

 ;
 ; We compute the position of the scroller on screen.
 ; Take the screen base pointer, and add a vertical offset
 ; found in the premultiplied sinus table. This makes the
 ; whole scroller to bounce up and down.
 ;
 move.l ptr_scr_1,a1
 add.w base_screen_offset,a1
 
 sub.w screen_display_scroller_offset,a1 
 
 moveq.l #0,d0
 move.b sinus_global_vertical,d0
 add.b sinus_global_vertical_speed,d0
 move.b d0,sinus_global_vertical
 lea table_sinus_160x176,a3
 add d0,d0
 add d0,a3
 add (a3),a1
 
 
 lea table_plans_word,a4	; Plan table for screen
 
 lea table_sinus_160x40,a3

 moveq #0,d0
 move.l d0,d1
 move.l d0,d4

 moveq.l #0,d1
 move.b SinusValue,d1
 addq.b #2,SinusValue
 add.w d1,d1				; For word access

 moveq.l #0,d3
 move.b SinusValue2,d3
 addq.b #5,SinusValue2
 add.w d3,d3				; For word access


 lea scroller_pointer_stack,a2 
 
 move bytesblocs_per_scanline,d0
.loop_blit_x_push
 ; Register usage:
 ; d0 => column counter
 ; d1 => sinus angle 1
 ; d2 =>
 ; d3 => sinus angle 2
 ; d4 =>
 ; d5 =>
 ; d6 => - temp scratch -
 ; d7 => background mask bitfield
 ;
 ; a0 => base scroller buffer
 ; a1 => base screen pointer
 ; a2 => pointers
 ; a3 => sinus table pointer
 ; a4 => screen bitplan table
 ; a5 => 
 ; a6 =>
 ; a7 => xxxx stack 
 ; 

 ; Scroller adress
 move.l a0,a5
 and.l #63<<2,d5
 add.l d5,a5
 add.l #4,d5
 

 ; Screen adress
 move.l a1,a6
 add.w (a4)+,a6				; Plan
 add (a3,d1.w),a6			; +Sin(offset_0)
 add (a3,d3.w),a6			; +Sin(offset_1)
 addq.w #3*2,d1
 addq.w #4*2,d3
 
 move.l a6,(a2)+			; Destination
 move.l a5,(a2)+			; Source
 
 dbra d0,.loop_blit_x_push
 rts
 

  
BlitScrollBufferSinusPop
 move.l #%01010101001100110000111111111111,d7
 lea scroller_pointer_stack,a0 
 move bytesblocs_per_scanline,d0
loop_blit_x_pop
 move.l (a0)+,a6	; Destination
 move.l (a0)+,a5	; Source
 
 ; Register usage:
 ; d0 => column counter
 ; d7 => background mask bitfield
 ; a5 => 
 ; a6 =>

 ;
 ; Blit a complete column on four bitplans
 ;

var2 set 0

; movep.l d7,var2(a6)	; 24/6
;var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 ; 
 ; Eraser=
 ; 10 lines top + 10 lines bottom
 ; (10+10)*24=480 cycles=120 nops

var1 set -32000
_base_ref_patch_1
 REPT 8
 move.l var1(a5),d6		; 16/4
 movep.l d6,var2(a6)	; 24/6
var1 set var1+256*8
var2 set var2+160
 ENDR
_base_ref_patch_2
 REPT 8
 move.l var1(a5),d6		; 16/4
 movep.l d6,var2(a6)	; 24/6
var1 set var1+256*8
var2 set var2+160
 ENDR
_base_ref_patch_3
 REPT 8
 move.l var1(a5),d6		; 16/4
 movep.l d6,var2(a6)	; 24/6
var1 set var1+256*8
var2 set var2+160
 ENDR
 ;
 ; SCROLLER_HEIGHT=24
 ; 24*(16+24)=24*40=960 cycles=240 nops

 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 movep.l d7,var2(a6)
var2 set var2+160
 ;movep.l d7,var2(a6)
;var2 set var2+160

 ; Total display+erase time=
 ; 40*(240+120)=40*360=14400 cycles=3600 nops
 ;
 ; Standard fullscreen routine has
 ; 11+89+13 nops free for each scanline (113 nops=452 cycles)
 ; 
 ; at each line we need to change 8 colors
 ; Fastest way is:
 ;
 ; a0=source palette
 ; a1=screen
 ; move.l (a0)+,($ffff8240+2*8).w	; 24
 ; move.l (a0)+,($ffff8240+2*10).w	; 24
 ; move.l (a0)+,($ffff8240+2*12).w	; 24
 ; move.l (a0)+,($ffff8240+2*14).w	; 24
 ; =>96 cycles /4 => 24 nops
 ;
 ; Other possibility:
 ; movem.l (a0)+,d0-d3				; 12+8n => 12+8*4=44/11
 ; movem.l d0-d3,(a1)				;  8+8n =>  8+8*4=40/10
 ; =>84 cycles /4 => 21 nops
 ;
 ; With that one it is possible to change the palette in two times: 
 ; 1) load the registers in the 13 nops slots
 ; 2) change the colors in the 11 nops slots
 ;
 ; remains the 89 nops in the middle to play

 dbra d0,loop_blit_x_pop

 COLORHELP #$000

 rts


 
DisplayMirror
 move.l ptr_scr_1,a5
 add.l #160*175,a5
 move.l a5,a6
 
 moveq #25-1,d7
.loop_y 
 ;7+5=12*4=48 bytes
 movem.l (a5),d0-d6/a0-a4
 movem.l d0-d6/a0-a4,(a6)

 ;7+5=12*4=48 bytes
 movem.l 48(a5),d0-d6/a0-a4
 movem.l d0-d6/a0-a4,48(a6)

 ;7+5=12*4=48 bytes
 movem.l 96(a5),d0-d6/a0-a4
 movem.l d0-d6/a0-a4,96(a6)

 ;4=4*4=16 bytes
 movem.l 144(a5),d0-d3
 movem.l d0-d3,144(a6)
 
 lea -320(a5),a5
 lea 160(a6),a6
 
 dbra d7,.loop_y 
 
 rts 
  
  


 
 
DrawBackgroundPattern
 move.l ptr_scr_1,a5
 move.l ptr_scr_2,a6

 ;
 ; Eventually erase the 160 first bytes
 ; 
 move.w base_screen_offset,d0
 beq.s .no_screen_offset
 moveq #0,d1
.screen_offset_erase_loop 
 move.l d1,(a5)+
 move.l d1,(a6)+
 subq.w #4,d0
 bne.s .screen_offset_erase_loop
.no_screen_offset

 move.l #%01010101010101010011001100110011,d0
 move.l #%00001111000011111111111111111111,d1

 move.w lines_per_screen,d7
.loop_y
 move.l a5,a3
 move.l a6,a4
 move.w blocs_per_scanline,d6		; 28-1 or 20-1
.loop_x 
 move.l d0,(a3)+
 move.l d1,(a3)+
 move.l d0,(a4)+
 move.l d1,(a4)+
 dbra d6,.loop_x
 add overscan_line_width,a5
 add overscan_line_width,a6
 dbra d7,.loop_y
 
 lea big_pattern,a0
 add offset_centering,a0			; 0 or 32
 move.l ptr_scr_1,a5
 add base_screen_offset,a5			; 160 or 0
 move.l ptr_scr_2,a6
 add base_screen_offset,a6			; 160 or 0

 ; 32000/8=4000
 move.w #50-1,d7
.loop_y_pattern
 move.l a0,a1
 move.l a5,a3
 move.l a6,a4
 move.w blocs_per_scanline,d6		; 28-1 or 20-1
.loop_x_pattern
 move.l (a1),(a3)+
 move.l (a1)+,(a4)+
 move.l (a1),(a3)+
 move.l (a1)+,(a4)+
 dbra d6,.loop_x_pattern
 add #224,a0
 add overscan_line_width,a5
 add overscan_line_width,a6
 dbra d7,.loop_y_pattern
 
 
 ;
 ; Then integrate the creators logo 
 ;
 lea creators_logo+32+160,a0
 
 move #160+230+16,d0
 tst.b overscan_is_allowed
 bne.s .overscan_ok
 move #160,d0
.overscan_ok 
 
 move.l ptr_scr_1,a5
 add d0,a5
 move.l ptr_scr_2,a6
 add d0,a6
 
 move #50-1,d7
.loop_line
 move.l a5,a1
 move.l a6,a2
 move.w #20-1,d6
.loop_col
 movem.w (a0)+,d0-d3
 
 move.w (a1),d4
 and d3,d4
 or d0,d4
 move.w d4,(a1)+
 move.w d4,(a2)+

 move.w (a1),d4
 and d3,d4
 or d1,d4
 move.w d4,(a1)+
 move.w d4,(a2)+

 move.w (a1),d4
 and d3,d4
 or d2,d4
 move.w d4,(a1)+
 move.w d4,(a2)+

 move.w d3,(a1)+
 move.w d3,(a2)+
 dbra d6,.loop_col
 add overscan_line_width,a5
 add overscan_line_width,a6
 dbra d7,.loop_line  
 rts

 
;
; Select the right color scroller
;
; Uses d0/d1/a0
SelectBackgroundPalette  
 moveq #0,d1
 move.b palette_fade_index,d1	; 0-15
 lsl #3,d1
 
 move.b palette_index,d0
 add.b palette_speed,d0
 and #7,d0
 move.b d0,palette_index	; 0-7
 or.b d0,d1
 
 mulu #200*16,d1
 ;moveq #12,d0
 ;lsl.l d0,d1
 
 lea buffer_palette,a0
 add.l d1,a0
 rts
 
 
TestScrollerOverscan
 sf $fffffa1b.w							; Disable HBL
 stop #$2300  

 move #$2300,sr
 
 move.w #$000,$ffff8240.w
 
 move #$2700,sr
restart_vbl 
 ;stop #$2300  

 jsr ManageNextLetter
 jsr BlitScrollBufferSinusPush

  
 ;
 ; Change the creators logo palette (8 colors)
 ;
 lea creators_logo,a0
 lea $ffff8240.w,a1
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 
 ; Returns palette in a0 (d0 and d1 are modified)
 bsr SelectBackgroundPalette 
 move.l a0,a3
 
  
 lea $ffff8260.w,a0    ; 8 resolution 
 lea $ffff820a.w,a1    ; 8 frequence
 lea $ffff8240+16.w,a2 ; 8 palette

 ; Set colors for the first overscan line
 movem.l (a3)+,d4-d7	; 12+8n => 12+8*4=44/11
 movem.l d4-d7,(a2)		;  8+8n =>  8+8*4=40/10
 
 moveq #2,d1		   ; 4
 
 ; Wait for the begining of screen
;===================================
.attend_syncro_first
 move.b $ffff8209.w,d0   ; syncro
 bne.s .attend_syncro_first
 move.b $ffff8209.w,d0   ; syncro
 bne.s .attend_syncro_first

 opt o-

 moveq #16,d2
.attend_syncro
 move.b $ffff8209.w,d0   ; syncro
 beq.s .attend_syncro
 sub.b d0,d2
 lsl.b d2,d0
 
 pause 96
 
 ; We have 52 blocs that are made of 
 ; 24x10 nops 4+6 nops
 ; One scanline has 89 nops
 ; dbra=3 nops if looping, 4 nops for last iteration
 ;
 ; So for practical resons we use 3 nops in the 89 to get the loop
 ; remains 86 nops
 ; We can split the display of one bloc on 3 scanlines:
 ; 24/3 => 8 blocs
 ; 8 blocs x 10 cycles = 80 cycles, remains 9 for bookeeping and loop
 ;
 ; Considering we 52 blocs, this means 52x3 = 156 scanlines for the scroller
 ;
 ; Then we need to add the erasing of all that crap:
 ; To erase 9 scanlines over and under the logo, means calling 18 times:
 ; movep.l d7,var2(a6)  => 6 nops
 ; 18*6=108 nops
 ; with 7 scanlines over and under the logo, we haev 14 times, so that's
 ; 14*6=84 nops. It all fits in one scanline !
 ;
 ; Considering we 52 blocs, this means we now have 52x(3+1) = 208 scanlines for the scroller
 ;
 ; Register map:
 ; d0 - Fullscreen 0
 ; d1 - Scanline counter
 ; d2 - Background bitmap pattern
 ; d3 - 
 ; d4 - xxx trashed by background palette change
 ; d5 - xxx trashed by background palette change
 ; d6 - xxx trashed by background palette change
 ; d7 - xxx trashed by background palette change
 ; 
 ; a0 - $ffff8260
 ; a1 - $ffff820a
 ; a2 - $ffff8240+16
 ; a3 - background palette ptr
 ; a4 - scroller pointer list
 ; a5 - target pointer (screen)
 ; a6 - source pointer (scroller buffer)
 ; a7 - 
 ; 
 
 ; **** Left ****
 move.w a0,(a0)   ;8/2
 pause 2
 move.b d0,(a0)   ;8/2

 move.l #%01010101001100110000111111111111,d2	; 12/3
 lea scroller_pointer_stack,a4 					; 12/3
 ; jsr abslong => 20/5

 pause 89-6-3-3-1-5
    
 ; One sequence with 13 the other with 38, total = 51
 moveq #13-1,d1									; 4/1
 jsr OverscanSequence	; 20/5

 ;
 ; Now one scanline with a palette change before continuing with the text
 ; 
 move.b d0,(a1)   ;8/2
 move.w a0,(a1)   ;8/2
 movem.l (a3)+,d4-d7	; 12+8n => 12+8*4=44/11
 pause 13-11			; 2=13-11
 move.w a0,(a0)   ;8/2
 nop 
 move.b d0,(a0)   ;8/2
 movem.l d4-d7,(a2)		;  8+8n =>  8+8*4=40/10
 pause 11-10			; 1=11-10
  
 ; **** Left ****
 move.w a0,(a0)   		;8/2
 pause 2
 move.b d0,(a0)   		;8/2

 
 lea fade_vbl_palette,a6				; 12/3
 move.l (a6)+,($ffff8240+2*0).w		; 24/6
 move.l (a6)+,($ffff8240+2*2).w		; 24/6
 move.l (a6)+,($ffff8240+2*4).w		; 24/6
 move.l (a6)+,($ffff8240+2*6).w		; 24/6 => 3+4*6=27
 
 pause 89-6-1-5-27	; 77=89-6-1-5
 
 moveq #38-1,d1									; 4/1
 jsr OverscanSequence	; 20/5
 
 ;
 ; Cleanly finish the right border to avoid glitches
 ; 
 move.b d0,(a1)   ;8/2
 move.w a0,(a1)   ;8/2
 movem.l (a3)+,d4-d7	; 12+8n => 12+8*4=44/11
 pause 13-11			; 2=13-11
 move.w a0,(a0)   ;8/2
 nop 
 move.b d0,(a0)   ;8/2

 ;moveq #38-1,d1									; 4/1
 ;jsr OverscanSequence
  
end_blabla

 
 opt o+,w-

 
 ;jsr BlitScrollBufferSinusPop

 jsr FlipScreen
  
 jsr CommonVblSubRoutine

 jsr ManageScrollerSpeed
 
 jsr ManageParalaxColors

 ; Check if keys are waiting
 btst #0,$fffffc00.w
 beq .skip

 cmp.b #$39+128,$fffffc02.w
 beq.s .exit
.skip 
 jmp restart_vbl

.exit
 ;move.w #$444,$ffff8240.w
 move.l #routine_vbl_nothing,$70.w
 move #$2300,sr
 rts


OverscanSequence
loop_overscan_bloc 
 pause 6				; 6=89-80-3
 
 ; LINE 0
 move.b d0,(a1)   		;8/2
 move.w a0,(a1)   		;8/2
 movem.l (a3)+,d4-d7	; 12+8n => 12+8*4=44/11
 pause 13-11			; 2=13-11
 move.w a0,(a0)   		;8/2
 nop 
 move.b d0,(a0)   		;8/2
 movem.l d4-d7,(a2)		;  8+8n =>  8+8*4=40/10
 pause 11-10			; 1=11-10

 ; **** Left ****
 move.w a0,(a0)   		;8/2
 pause 2
 move.b d0,(a0)   		;8/2

 move.l (a4)+,a6		; 12/3
  
var2 set 230*0
 REPT 7
 movep.l d2,var2(a6)	; 24/6
var2 set var2+230
 ENDR					; 7*6=42
  
var2 set 230*(7+24)
 REPT 7
 movep.l d2,var2(a6)	; 24/6
var2 set var2+230
 ENDR					; 7*6=42
 pause 5-3				; 5=89-42-42=89-84
 
 ; LINE 1
 move.b d0,(a1)   		;8/2
 move.w a0,(a1)   		;8/2
 movem.l (a3)+,d4-d7	; 12+8n => 12+8*4=44/11
 pause 13-11			; 2=13-11
 move.w a0,(a0)   		;8/2
 nop 
 move.b d0,(a0)   		;8/2
 movem.l d4-d7,(a2)		;  8+8n =>  8+8*4=40/10
 pause 1				; 1=11-10 
 
 ; **** Left ****
 move.w a0,(a0)   		;8/2
 pause 2
 move.b d0,(a0)   		;8/2

 move.l (a4)+,a5		; 12/3
  
var2 set 230*7
_megapatch_1
 REPT 8
 move.l 160(a5),d6		; 16/4
 movep.l d6,var2(a6)	; 24/6
var2 set var2+230
 ENDR					; 8*(4+6)=80 
 pause 9-3				; 9=89-80

 ; LINE 2
 move.b d0,(a1)   		;8/2
 move.w a0,(a1)   		;8/2
 movem.l (a3)+,d4-d7	; 12+8n => 12+8*4=44/11
 pause 13-11			; 2=13-11
 move.w a0,(a0)   		;8/2
 nop 
 move.b d0,(a0)   		;8/2
 movem.l d4-d7,(a2)		;  8+8n =>  8+8*4=40/10
 pause 11-10			; 1=11-10
 move.w a0,(a0)   		;8/2
 pause 2
 move.b d0,(a0)   		;8/2
_megapatch_2
 REPT 8
 move.l var1(a5),d6		; 16/4
 movep.l d6,var2(a6)	; 24/6
var2 set var2+230
 ENDR					; 8*(4+6)=80 
 pause 9				; 9=89-80
 
 ; LINE 3
 move.b d0,(a1)   		;8/2
 move.w a0,(a1)   		;8/2
 movem.l (a3)+,d4-d7	; 12+8n => 12+8*4=44/11
 pause 13-11			; 2=13-11
 move.w a0,(a0)   		;8/2
 nop 
 move.b d0,(a0)   		;8/2
 movem.l d4-d7,(a2)		;  8+8n =>  8+8*4=40/10
 pause 1				; 1=11-10
 move.w a0,(a0)   		;8/2
 pause 2
 move.b d0,(a0)   		;8/2
_megapatch_3
 REPT 8
 move.l var1(a5),d6		; 16/4
 movep.l d6,var2(a6)	; 24/6
var2 set var2+230
 ENDR					; 8*(4+6)=80 
 
 dbra d1,loop_overscan_bloc
 
 ; rts 		   => 16/4
 pause 5-4				; 6=89-80-4-4
 rts  

  

EraseScreen
 movem.l black_palette,d0-d6/a0-a5
 move.l ptr_scr_1,a6
 add.l #46336,a6

 ; 32000 bytes to erase
 ; Free registers: d0-d6/a0-a5 => 7+6 => 13*4=52 bytes
 ; 46336/52=891 reste	4	(1 register)
 move.w #891-1,d7
.loop
 BOUNDCHECK a6,#buffer_screens,#buffer_screens_end

 movem.l d0-d6/a0-a5,-(a6)	; 7+6=13*4=52
 dbra d7,.loop
 move.l d0,-(a6)
 rts


;
; Copy the picture to the screen
;
DisplayPicturePi1
 move.l ptr_scr_1,a1

 move.w #32000/4-1,d0
.loop
 move.l (a0)+,(a1)+
 dbra d0,.loop
 rts



;
; This simple routine will just try to draw each character shape
; and store the positions in a big table
; Format is simple:
; - .b ASCII code of character
; - .b Y coordinate (scanline)
; - .b X coordinate (in bytes)
; - .b Width of character (number of bytes)
; - .b Height of character (number of scanlines)
;
; Each located character is then transformed in something else:
; 
;
MaskFontTest
 STEEMBREAK

 lea font_info,a0
 lea buffer_font+(4*2*24),a5

.loop_letter
 ; Get character, 0 is end of table
 moveq.l #0,d0
 move.b (a0)+,d0
 beq .end

 ; Memorize the informations in the table
 move d0,d6
 lsl #2,d6
 lea font_array_info,a6
 move.l a0,0(a6,d6) 

 ; Get Y 
 moveq.l #0,d1
 move.l d1,d2
 move.b (a0)+,d1
 BOUNDCHECK d1,#0,#200
 mulu #160,d1

 ; Get X
 move.b (a0)+,d2
 BOUNDCHECK d2,#0,#320
 add d2,d1

 ; Store the bitmap position in the table
 ; (Skip the space character area)
 lea font_array_ptr,a6
 move.l a5,0(a6,d6) 
 BOUNDCHECK a5,#buffer_font,#buffer_font_end

 ; Compute the screen adress
 move.l ptr_scr_1,a1
 add d1,a1
 BOUNDCHECK a1,#buffer_screens,#buffer_screens_end

 ; Get width
 moveq.l #0,d2
 move.b (a0)+,d2
 BOUNDCHECK d2,#0,#5
 subq #1,d2

 ; Get height
 moveq.l #0,d3
 move.b (a0)+,d3
 BOUNDCHECK d3,#1,#24

 ; Get vertical offset
 moveq.l #0,d4
 move.b (a0)+,d4
 ext.w d4
 
 
 ; Copy the data
.loop_x
 move.l a1,a2
 
 ;
 ;
 ; Copy the column
 ;
 move d3,d7
.loop_y
 BOUNDCHECK a2,#buffer_screens,#buffer_screens_end
 BOUNDCHECK a5,#buffer_font,#buffer_font_end

 ; Copy the letters data to the buffer
 move.b 0(a2),(a5)+
 move.b 2(a2),(a5)+
 move.b 4(a2),(a5)+

 ; And then create the inverted mask of the three first planes
 move.b 0(a2),d0
 or.b 2(a2),d0
 or.b 4(a2),d0
 eor.b #$ff,d0
 move.b d0,(a5)+

 lea 160(a2),a2
 dbra d7,.loop_y

 ; Eventually pad with black if letter is too short
 move #SCROLLER_HEIGHT-2,d7
 sub d3,d7
 beq .skip_erase_y
 move.l #$000000ff,d0
.loop_erase_y
 BOUNDCHECK a5,#buffer_font,#buffer_font_end

 move.l d0,(a5)+
 dbra d7,.loop_erase_y
.skip_erase_y

 move.l a1,d7
 and #1,d7
 beq .even1
 lea 6(a1),a1
.even1
 lea 1(a1),a1

 dbra d2,.loop_x

 ;jsr WaitVbl   ; Uncomment to make it slower

 jmp .loop_letter

.end

 ;BREAK

 ; Hardcode the space bitmap
 lea buffer_font,a0
 move.l a0,font_array_ptr+32*4
 move.w #(4*2*24)/4-1,d0
.format_space
 move.l #$000000ff,(a0)+
 dbra d0,.format_space
 rts

 

routine_vbl_nothing
 movem.l d0-a6,-(sp)

 sf $fffffa1b.w							; Disable HBL
 
 st flag_vbl
 
 ;
 ; Replay music if initialised
 ;
 tst.b music_is_initialised
 beq.s .skip_zic
 lea music,a0
 COLORHELP #$700
 jsr 8(a0)
 COLORHELP #$000
.skip_zic
 
 movem.l (sp)+,d0-a6
 rte

routine_vbl_fade
 movem.l d0-a6,-(sp)

 jsr CommonVblSubRoutine  ; <= Not a good idea for a "do nothing' vbl
 
 movem.l (sp)+,d0-a6
 rte



; Simple rasters
routine_vbl_rasters_complex
 movem.l d0-a6,-(sp)

 ;jsr CommonVblSubRoutine
 st flag_vbl

 ;
 ; Replay music if initialised
 ;
 tst.b music_is_initialised
 beq.s .skip_zic
 lea music,a0
 COLORHELP #$700
 jsr 8(a0)
 COLORHELP #$000 
.skip_zic
 
 ;
 ; Compute new palette
 ;
 lea fade_vbl_palette,a0
 jsr ApplyGradient
 
  
 move.l #routine_hbl_complex,$120.w

 sf $fffffa1b.w				; TBCR Event mode => disable

 lea creators_logo,a0
 lea $ffff8240.w,a1
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+

 ; Returns palette in a0 (d0 and d1 are modified)
 jsr SelectBackgroundPalette
 
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move a0,usp
 
 move.b #51,counter_split_raster

 bset #0,$fffffa07.w		; iera
 bset #0,$fffffa13.w		; imra
 move.b	#1,$fffffa21.w		; TBDR Number of lines to wait before HBL
 move.b #8,$fffffa1b.w		; TBCR Event mode

 movem.l (sp)+,d0-a6
 rte

counter_split_raster	ds.b 1
 even
 
routine_hbl_complex:
 move.l a0,-(sp)					; 12

 move usp,a0						; 4
 move.l (a0)+,($ffff8240+2*8).w		; 24
 move.l (a0)+,($ffff8240+2*10).w	; 24
 move.l (a0)+,($ffff8240+2*12).w	; 24
 move.l (a0)+,($ffff8240+2*14).w	; 24
 move a0,usp						; 4

 subq.b #1,counter_split_raster
 beq.s .split_raster
 bclr.b #0,$fffffa0f.w				; 12

 move.l (sp)+,a0					; 12
 rte								; 20+44 => 204*200 lines => 40800 cycles in total soit environ 25% de temps cpu

.split_raster
 lea fade_vbl_palette,a0
 move.l (a0)+,($ffff8240+2*0).w		; 24
 move.l (a0)+,($ffff8240+2*2).w		; 24
 move.l (a0)+,($ffff8240+2*4).w		; 24
 move.l (a0)+,($ffff8240+2*6).w		; 24
 
 bclr.b #0,$fffffa0f.w				; 12
 
 move.l (sp)+,a0					; 12
 rte
 
 
; In full screen, no more interrupts, no more register save,
; assuming register "a6" is fixed for all the effect, that become:
; 24*4 => 96 cycles *200 => 19200 (11%)
;
 
 
 
 
RawToSt 
 ;
 ; First generate the 16 bits picture from the 24 bits
 ;
 lea table_to_ste,a2

 ;move.w #170*8,d7
.loop
 move.b (a0)+,d0	; R 111xxxxx
 move.b (a0)+,d1	; G
 move.b (a0)+,d2	; B

	 ; Let's get it a bit darker for the visibility
	 ;lsr.b #1,d0
	 ;lsr.b #1,d1
	 ;lsr.b #1,d2
 
 lsr.b #4,d0
 and #15,d0
 move.b (a2,d0),d0

 lsr.b #4,d1
 and.w #15,d1
 move.b (a2,d1),d1

 lsr.b #4,d2
 and.w #15,d2
 move.b (a2,d2),d2

 lsl.w #8,d0
 lsl.w #4,d1
 or.w d1,d0
 or.w d2,d0

 move d0,(a1)+

 dbra d7,.loop
 rts
 
 
GenerateMegaShift 
 ;
 ; Then copy and shift it in the 7 other buffers
 ;
 lea buffer_palette,a0
 moveq #16-1,d5
.loop_gradient
 moveq #7-1,d6
.loop_buffer 
 move.w #200-1,d7
.loop_line 
 move.w (a0),d0
 move.l 2(a0),200*8*2(a0)
 move.l 6(a0),200*8*2+4(a0)
 move.l 10(a0),200*8*2+8(a0)
 move.w 14(a0),200*8*2+12(a0)
 move.w d0,200*8*2+14(a0)
 lea 2*8(a0),a0 
 dbra d7,.loop_line 
 ;lea 2*8*56(a0),a0 	;; Only when changing the size of buffer from 200 to 256
 dbra d6,.loop_buffer
 add.l #200*8*2,a0 
 dbra d5,.loop_gradient
 
 rts

 
 
SourceRedBase	dc.l $00000000
SourceGreenBase	dc.l $00000000
SourceBlueBase	dc.l $00000000
 
GenerateMegaFade
 ;
 ; Then copy and fade it in the 16 other buffers !
 ;
 lea buffer_palette,a0				; Source colors
 lea table_to_stf,a1				; Conversion table from STE encoding to linear
 lea table_to_ste,a2				; Conversion table from STF encoding to STE non linear
 
 move.w #200*8-1,d7
.loop_color
 move.l d7,-(sp)

 moveq #0,d7
 move.w (a0),d7		; Color to fade in source buffer
 
 move.l SourceRedBase,d0
 move.l SourceGreenBase,d1
 move.l SourceBlueBase,d2
 
 ; Blue component
 move d7,d5
 and #%1111,d5
 move.b (a1,d5.w),d5	; Destination BLUE STE to linear conversion
 swap d5
 sub.l d2,d5
 asr.l #4,d5

 ; Green component
 lsr #4,d7
 move d7,d4
 and #%1111,d4
 move.b (a1,d4.w),d4
 swap d4
 sub.l d1,d4
 asr.l #4,d4

 ; Red component
 lsr #4,d7
 move d7,d3
 and #%1111,d3
 move.b (a1,d3.w),d3
 swap d3
 sub.l d0,d3
 asr.l #4,d3
 
 move.l a0,a3
 add.l #2*8*200*8*16,a3
 addq #2,a0
 
 ;
 ; d0=current red
 ; d1=current green
 ; d2=current blue
 ; d3=increment red
 ; d4=increment green
 ; d5=increment blue
 ; d6=temp
 ; d7=loop counter
 ;
 ; a0=source palette
 ; a1=STE to STF table
 ; a2=STF to STE table
 ; a3=destination palette
 ;
 moveq #15-1,d7
.loop_gradient 
 add.l d3,d0		; Update Red
 add.l d4,d1		; Update Green
 add.l d5,d2		; Update Blue

 swap d0
 swap d1
 swap d2

 moveq #0,d6
 move.b (a2,d0.w),d6 ; Red linear to STE conversion
 lsl #4,d6
 or.b (a2,d1.w),d6   ; Green linear to STE conversion
 lsl #4,d6
 or.b (a2,d2.w),d6   ; Blue linear to STE conversion
 
 sub.l #2*8*200*8,a3
 move.w d6,(a3)      ; Write final color
 
 swap d0
 swap d1
 swap d2

 dbra d7,.loop_gradient

 move.l (sp)+,d7
 dbra d7,.loop_color 
 rts
 

;
; a0 -> start palette
; a1 -> end palette
; d7 -> number of colors
;
ComputeGradient
 ;
 ; Compute fixed point increment values
 ;
 lea source_rgb,a2  	; Source palette and increments stored as separated components
 lea table_to_stf,a3	; Conversion table from STE encoding to linear
 subq.l #1,d7
 move.w d7,fade_color_count
.loop_color
 ; Read source and destination colors
 move.w (a0)+,d0			
 move.w (a1)+,d1
 
 ; Blue component
 move d0,d2
 and #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5	; Source BLUE STE to linear conversion
 swap d5
 
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6	; Destination BLUE STE to linear conversion
 swap d6
 sub.l d5,d6
 asr.l #4,d6
 move.l d6,(a2)+		; Store increment
 move.l d5,(a2)+		; Store base color

 ; Green component
 lsr #4,d0
 move d0,d2
 and.w #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5
 swap d5
 
 lsr #4,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6
 swap d6
 sub.l d5,d6
 asr.l #4,d6
 move.l d6,(a2)+		; Store increment
 move.l d5,(a2)+		; Store base color

 ; Red component
 lsr #4,d0
 move d0,d2
 and #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5
 swap d5
 
 lsr #4,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6
 swap d6
 sub.l d5,d6
 asr.l #4,d6
 move.l d6,(a2)+		; Store increment
 move.l d5,(a2)+		; Store base color

 dbra d7,.loop_color
 
 move.b #16,fade_counter
 rts

 
WaitEndOfFade 
.wait_end_of_fadeid
 jsr WaitVbl
 move.b fade_counter,d0
 bne .wait_end_of_fadeid
 jsr WaitVbl
 ;jmp WaitEndOfFade
 rts
  
;
; Then do the fade
; a0=adress of destination palette
ApplyGradient
 move.b fade_counter,d0
 bne .continue_gradient
 rts
 
.continue_gradient
 subq #1,d0
 move.b d0,fade_counter
 
 lea source_rgb,a1
 lea table_to_ste,a2
 move.w fade_color_count,d7
.loop_color
 move.l (a1)+,d0    ; Blue increment
 add.l (a1),d0		; + Blue base color
 move.l d0,(a1)+	; Store new Blue

 move.l (a1)+,d1    ; Green increment
 add.l (a1),d1		; + Green base color
 move.l d1,(a1)+	; Store new Green

 move.l (a1)+,d2    ; Red increment
 add.l (a1),d2		; + Red base color
 move.l d2,(a1)+	; Store new Red

 swap d0
 swap d1
 swap d2

 moveq #0,d6
 move.b (a2,d2.w),d6 ; Rouge converti en STE
 lsl #4,d6
 or.b (a2,d1.w),d6   ; Vert converti en STE
 lsl #4,d6
 or.b (a2,d0.w),d6   ; Bleu converti en STE
 move.w d6,(a0)+     ; Write final color

 dbra d7,.loop_color
 
 rts



CommonVblSubRoutine
 st flag_vbl

 ;
 ; Replay music if initialised
 ;
 tst.b music_is_initialised
 beq.s .skip_zic
 lea music,a0
 COLORHELP #$700
 jsr 8(a0)
 COLORHELP #$000 
.skip_zic
 
 ;
 ; Compute new palette
 ;
 lea fade_vbl_palette,a0
 jsr ApplyGradient
 
 ;
 ; Recopie palette
 ;
 lea fade_vbl_palette,a0
 lea $ffff8240.w,a1
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+ 
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 rts
  
 
 
 
 


SetBlackPalette
 rts
  

FadeToBlack 
 lea $ffff8240.w,a0
 lea black_palette,a1
 moveq #16,d7
 jsr ComputeGradient
 move.l #routine_vbl_fade,$70.w
 jsr WaitEndOfFade
 rts
 

 

 
FadeToIntro1985
 lea $ffff8240.w,a0
 lea picture_1985_2005,a1
 moveq #16,d7
 jsr ComputeGradient
 move.l #routine_vbl_fade,$70.w
 jsr WaitEndOfFade
 rts

 
WaitDelay 
 jsr WaitVbl
 dbra d0,WaitDelay
 rts
   
FadeIntro19852005
 jsr FlipScreen
 jsr WaitVbl
 
 ;jmp tototest
 ; 1985
 jsr EraseScreen
 lea picture_1985_2005+32+(8*0)+(160*0),a0
 moveq #9,d0
 moveq #47,d1
 move.l ptr_scr_1,a1
 jsr DrawBlocAutoCentered
 jsr FlipScreen
 jsr FadeToIntro1985
 move #50*2,d0
 jsr WaitDelay
 jsr FadeToBlack

 ; Birth of a legend
 jsr EraseScreen
 lea picture_1985_2005+32+(8*0)+(160*109),a0
 moveq #8,d0
 moveq #36,d1
 move.l ptr_scr_1,a1
 jsr DrawBlocAutoCentered
 jsr FlipScreen
 jsr FadeToIntro1985
 move #50*2,d0
 jsr WaitDelay
 jsr FadeToBlack

 
 ; 2005
 jsr EraseScreen
 lea picture_1985_2005+32+(8*0)+(160*49),a0
 move.l ptr_scr_1,a1
 moveq #9,d0
 moveq #53,d1
 jsr DrawBlocAutoCentered
 jsr FlipScreen
 jsr FadeToIntro1985
 move #50*2,d0
 jsr WaitDelay
 jsr FadeToBlack

 ; Still alive an kicking !
 jsr EraseScreen
 lea picture_1985_2005+32+(8*0)+(160*157),a0
 moveq #8,d0
 moveq #40,d1
 move.l ptr_scr_1,a1
 jsr DrawBlocAutoCentered
 jsr FlipScreen
 jsr FadeToIntro1985
 move #50*2,d0
 jsr WaitDelay
 jsr FadeToBlack

 ; 2025
 jsr EraseScreen
 lea picture_1985_2005+32+(8*0)+(160*198),a0
 move.l ptr_scr_1,a1
 moveq #12,d0
 moveq #45,d1
 jsr DrawBlocAutoCentered
 jsr FlipScreen
 jsr FadeToIntro1985
 move #50*2,d0
 jsr WaitDelay
 jsr FadeToBlack

 ; Creators celebrating...
 jsr EraseScreen
 lea picture_1985_2005+32+(8*0)+(160*246),a0
 moveq #15,d0
 moveq #58,d1
 move.l ptr_scr_1,a1
 jsr DrawBlocAutoCentered
 jsr FlipScreen
 jsr FadeToIntro1985
 move #50*2,d0
 jsr WaitDelay
 jsr FadeToBlack

tototest
 ; Logo Atari
 jsr EraseScreen
 lea picture_1985_2005+32+(8*9)+(160*4),a0
 move #11,d0
 move.w #186,d1
 move.l ptr_scr_1,a1 
 jsr DrawBlocAutoCentered
 jsr FlipScreen
 jsr GenerateGradientPalette
 move.l #RoutineVbl_FullPaletteChanges,$70.w
 ;jsr FadeToIntro1985
 
 ;
 ; This takes a LOT of time to generate.
 ; We compute it during the Atari logo display as a temporisation.
 ; But in case the intro is disabled, we need to computer the buffer somewhere else
 ;
 jsr GenerateMegaPalettes

 move #50*2,d0
 jsr WaitDelay
 
 jsr EraseScreen
 jsr FlipScreen
 jsr EraseScreen
 jsr FlipScreen
 move.l #routine_vbl_nothing,$70.w
 
 ;jsr FadeToBlack
 
;bla
 ;jmp bla 
 ;jmp tototest
 rts

 
 
; a0 - source bitmaps
; a1 - destination
; d0 - width in '16 pixels blocs'-1
; d1 - height -1
DrawBlocAutoCentered
 move #200,d2
 sub d1,d2
 lsr #1,d2
 mulu #160,d2
 add d2,a1
 move #20,d2
 sub d0,d2
 lsr #1,d2
 lsl #3,d2
 add d2,a1
 
DrawBloc
 subq #1,d0 
 subq #1,d1
.loop_y
 move.l a0,a2
 move.l a1,a3
 move d0,d2
.loop_x
 move.l (a2)+,(a3)+
 move.l (a2)+,(a3)+
 dbra d2,.loop_x
 lea 160(a0),a0
 lea 160(a1),a1
 dbra d1,.loop_y 
 rts
   
GenerateGradientPalette
 ; rainbow_palette
 lea rainbow_palette,a0
 lea rainbow_palette,a1
 move.w #200,d7
 jsr RawToSt
	
 lea buffer_raster_atari_logo,a1
 lea rainbow_palette,a2
 ;move.w #$111,d0
 move.w #200-1,d7
.loop_line
 move (a2)+,d0
 lea picture_1985_2005,a0
 move.w #16-1,d6
.loop_color 
 move d0,d1
 and.w (a0)+,d1
 move d1,(a1)+
 dbra d6,.loop_color
 ;add.w #$123,d0
 dbra d7,.loop_line 
 rts

 
; VBL+HBL based routines that can 
; change 200 palettes in 16 intensity level
; That makes for a grand total of 
; 200*32*16=102400 bytes
RoutineVbl_FullPaletteChanges
 movem.l d0-a6,-(sp)

 st flag_vbl
 
 move.l #RoutineHbl_FullPaletteChange,$120.w

 sf $fffffa1b.w				; TBCR Event mode => disable

 tst.b music_is_initialised
 beq.s .skip_zic
 lea music,a0
 COLORHELP #$700
 jsr 8(a0)
 COLORHELP #$000
.skip_zic
 
 lea buffer_raster_atari_logo,a0
 
 lea ($ffff8240).w,a1
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move a0,usp

 bset #0,$fffffa07.w		; iera
 bset #0,$fffffa13.w		; imra
 move.b	#1,$fffffa21.w		; TBDR Number of lines to wait before HBL
 move.b #8,$fffffa1b.w		; TBCR Event mode

 movem.l (sp)+,d0-a6
 rte


RoutineHbl_FullPaletteChange:
 move.l a0,-(sp)					; 12

 move usp,a0						; 4
 move.l (a0)+,($ffff8240+2*0).w		; 24
 move.l (a0)+,($ffff8240+2*2).w		; 24
 move.l (a0)+,($ffff8240+2*4).w		; 24
 move.l (a0)+,($ffff8240+2*6).w		; 24
 move.l (a0)+,($ffff8240+2*8).w		; 24
 move.l (a0)+,($ffff8240+2*10).w	; 24
 move.l (a0)+,($ffff8240+2*12).w	; 24
 move.l (a0)+,($ffff8240+2*14).w	; 24
 move a0,usp						; 4

 bclr.b #0,$fffffa0f.w				; 12

 move.l (sp)+,a0					; 12
 rte								; 20+44 => 204*200 lines => 40800 cycles in total soit environ 25% de temps cpu
 
 
 
SaveSystem 
 move #$2700,sr
 
 move.l usp,a0							; Need to save USP in case of a not totaly regular usage ;)
 move.l a0,save_usp

 move.b $fffffa07.w,save_iera
 move.b $fffffa09.w,save_ierb
 move.b $fffffa13.w,save_imra
 move.b $fffffa15.w,save_imrb
 move.b $fffffa17.w,save_vr
 move.b $fffffa1b.w,save_tbcr
 move.b $fffffa21.w,save_tbdr

 move.b $ffff820a.w,save_freq
 move.b $ffff8260.w,save_rez
 move.b $ffff8265.w,save_pixl

 move.b $ffff8201.w,save_screen_addr_1	; Screen base pointeur (STF/E)
 move.b $ffff8203.w,save_screen_addr_2	; Screen base pointeur (STF/E)
 move.b $ffff820d.w,save_vbaselo		; Save low byte (STE only)
  
 movem.l $ffff8240.w,d0-d7				; STF/STE Palette
 movem.l d0-d7,save_palette

 move.l $70.w,save_70					; VBL
 move.l $120.w,save_120					; MFP Timer B (aka HBL)
 
 ;
 ; System specific saves
 ;
 tst.b machine_is_mste
 beq.s .end_megaste 
.megaste 
 move.b $ffff8e21.w,save_mste_cache
.end_megaste

 tst.b machine_is_tt
 beq.s .end_tt 
.tt 
 move.w $ffff8262.w,save_tt_rez
.end_tt 
 
 move #$2300,sr
 rts

 
 
RestoreSystem 
 move #$2700,sr

 move.l save_usp,a0
 move.l a0,usp

 move.b save_iera,$fffffa07.w
 move.b save_ierb,$fffffa09.w
 move.b save_imra,$fffffa13.w
 move.b save_imrb,$fffffa15.w
 move.b save_vr,$fffffa17.w
 move.b save_tbcr,$fffffa1b.w
 move.b save_tbdr,$fffffa21.w

 move.b save_freq,$ffff820a.w
 move.b save_rez,$ffff8260.w
 move.b save_pixl,$ffff8265.w

 move.b save_screen_addr_1,$ffff8201.w
 move.b save_screen_addr_2,$ffff8203.w
 move.b save_vbaselo,$ffff820d.w
 
 movem.l save_palette,d0-d7
 movem.l d0-d7,$ffff8240.w

 move.l save_70,$70.w
 move.l save_120,$120.w

 ;
 ; System specific load
 ;
 tst.b machine_is_mste
 beq.s .end_megaste 
.megaste 
 move.b save_mste_cache,$ffff8e21.w
.end_megaste
 
 tst.b machine_is_tt
 beq.s .end_tt
.tt 
 move.w save_tt_rez,$ffff8262.w
.end_tt

 move #$2300,sr
 rts
 

SetSystemParameters
 ;
 ; Disable every MFP interruption
 ;
 sf $fffffa07.w	; iera
 sf $fffffa09.w	; ierb
 sf $fffffa13.w ; imra
 sf $fffffa15.w ; imrb
 
 ;
 ; Set the screen at the right adress
 ;
 lea $ffff8201.w,a0				; Screen base pointeur (STF/E)
 move.l #buffer_screens+256,d0
 clr.b d0
 move.l d0,d1
 lsr.l #8,d0					; Allign adress on a byte boudary for STF compatibility
 movep.w (a0),d2				; Save old screen adress
 sf.b 12(a0)				; For STE low byte to 0

 move.l d1,ptr_scr_1
 add.l #46336,d1
 move.l d1,ptr_scr_2
 
 ;
 ; System specific setup
 ;
 tst.b machine_is_mste
 beq.s .end_specific 
.megaste 
 move.b #%00,$ffff8e21.w	; 8mhz without cache
.end_specific
 
 rts
 
 
ClearSectionBSS
 lea debut_bss,a0					
 lea fin_bss,a1 					
 moveq #0,d0
.loop_clear_bss
 move.l d0,(a0)+
 cmpa.l a1,a0
 blt.s .loop_clear_bss
 rts

    
 SECTION DATA

; ===========================================================================
;
;					Files and stuff that are included
;
; ===========================================================================
 even 
font
buffer_font
	incbin "font.pi1"
font_end
buffer_font_end

table_sinus_160x40	  
	incbin "sine_160.bin"
	incbin "sine_160.bin"

table_sinus_160x176
	incbin "160x176.sin"
	incbin "160x176.sin"
	
gradient_picture
	incbin "gradient.raw"

gradient_picture_mike
	incbin "bck_mike.raw"

gradient_picture_hanne
	incbin "bck_hann.raw"

gradient_picture_triplex
	incbin "bck_tplx.raw"

gradient_picture_matrix
	incbin "bck_mtrx.raw"

gradient_picture_greetings
	incbin "bck_grtz.raw"
	
gradient_picture_ptoing
	incbin "bck_ptng.raw"
						
big_pattern	
	incbin "backptrn.bin"
	
picture_1985_2005
 	incbin "85-2005.pi1"

picture_sweaty
	incbin "sweaty3.pi1"
	
rainbow_palette
	incbin "rainbow.raw"
	 	
creators_logo
	incbin "creators.pi1"
	
table_rotation_scroller
 	incbin "rotate.bin"
 
music
	incbin "PARALLAX.SND"
	;incbin "GHETTO.SND"
	 	
 even
 
table_bits 
 incbin "tbl_bit.bin"
 
 even

; ===========================================================================
;
;					Tables, palettes, and other dc.x thingies
;
; ===========================================================================


TableMaskage_OR
var set 0
 rept 256
 dc.b (%01010101&var)
 dc.b (%00110011&var)
 dc.b (%00001111&var)
 dc.b (%11111111&var)
var set var+1
 endr

table_to_stf
 dc.b 0
 dc.b 2
 dc.b 4
 dc.b 6
 dc.b 8
 dc.b 10
 dc.b 12
 dc.b 14
 dc.b 1
 dc.b 3
 dc.b 5
 dc.b 7
 dc.b 9
 dc.b 11
 dc.b 13
 dc.b 15

table_to_ste
 dc.b 0
 dc.b 8
 dc.b 1
 dc.b 9
 dc.b 2
 dc.b 10
 dc.b 3
 dc.b 11
 dc.b 4
 dc.b 12
 dc.b 5
 dc.b 13
 dc.b 6
 dc.b 14
 dc.b 7
 dc.b 15

 even



 ; Palette purple
palette_scroller_purple
 MAKERGB 0,0,0
 MAKERGB 224,224,224
 MAKERGB 224,160,160
 MAKERGB 160,96,128
 MAKERGB 128,32,96
 MAKERGB 96,0,96
 MAKERGB 32,0,32
 MAKERGB 0,0,0

 ; Palette greenish  
palette_scroller_greenish
 MAKERGB 0,0,0
 MAKERGB 224,224,224
 MAKERGB 192,192,0
 MAKERGB 128,160,0
 MAKERGB 96,96,0
 MAKERGB 64,64,0
 MAKERGB 0,32,0
 MAKERGB 0,0,0

 ; Palette orange
palette_scroller_orange
 MAKERGB 0,0,0
 MAKERGB 224,224,224
 MAKERGB 224,192,0
 MAKERGB 224,128,0
 MAKERGB 160,0,0  
 MAKERGB 96,0,0   
 MAKERGB 64,0,0   
 MAKERGB 0,0,0

 ; Palette blue 
palette_scroller_blue
 MAKERGB 0,0,0
 MAKERGB 224,224,224
 MAKERGB 0,224,224
 MAKERGB 0,160,160
 MAKERGB 0,96,128
 MAKERGB 0,64,96
 MAKERGB 0,32,96
 MAKERGB 0,0,0

palette_scroller_allwhite
 MAKERGB 0,0,0
 MAKERGB 255,255,255
 MAKERGB 255,255,255
 MAKERGB 255,255,255
 MAKERGB 255,255,255
 MAKERGB 255,255,255
 MAKERGB 255,255,255
 MAKERGB 255,255,255

palette_scroller_allDarkGreen
 MAKERGB 0,0,0
 MAKERGB 0,224,224
 MAKERGB 0,192,0
 MAKERGB 0,160,0
 MAKERGB 0,96,0
 MAKERGB 0,64,0
 MAKERGB 0,32,0
 MAKERGB 0,0,0
 
    
palette
 dc.w $111,$222,$333,$444,$555,$666,$777,$888
 dc.w $111,$222,$333,$444,$555,$666,$777,$888
 dc.w $111,$222,$333,$444,$555,$666,$777,$888
 dc.w $111,$222,$333,$444,$555,$666,$777,$888
 dc.w $111,$222,$333,$444,$555,$666,$777,$888

FancyPaletteBlack
 dc.w $000,$000,$000,$000,$000,$000,$000,$000
 
FancyPaletteWhite
 dc.w $777,$777,$777,$777,$777,$777,$777,$777

FancyGradient
 dc.w $700,$770,$070,$077,$777,$077,$007,$707
 


 even											

;
; Takes the following parameters:
; \1=X
; \2=Y
; \3=ASCII code
; \4=width
; \5=height
; \6=vertical offset
;
LETTER macro
 dc.b (\3)							; ASCII code
 dc.b (\2)							; Y pos
 dc.b (((\1)/16)*8)+(((\1)/8)&1)	; X pos
 dc.b (\4)/8						; Width
 dc.b (\5)-1						; Height
 ifc '','\6'
 dc.b 0
 endc
 ifnc '','\6'
 dc.b (\6)							; Vertical offset
 endc
 endm

; Letters are in average 16x24
font_info
 ;    X  Y      WIDTH
 ;LETTER  16,16,"A",56
 ;dc.b 0	; -End-
 LETTER   0,0,32,16,16	; Space is to be patched...

 LETTER   0,0,"A",16,16
 LETTER  16,0,"B",16,16
 LETTER  32,0,"C",16,16
 LETTER  48,0,"D",16,16
 LETTER  64,0,"E",16,16
 LETTER  80,0,"F",16,16
 LETTER  96,0,"G",16,16
 LETTER 112,0,"H",16,16
 LETTER 128,0,"I",8,16
 LETTER 136,0,"J",16,16
 LETTER 152,0,"K",16,16
 LETTER 168,0,"L",16,16
 LETTER 184,0,"M",16,16
 LETTER 200,0,"N",16,16
 LETTER 216,0,"O",16,16
 LETTER 232,0,"P",16,16
 LETTER 248,0,"Q",16,16
 LETTER 264,0,"R",16,16
 LETTER 280,0,"S",16,16
 LETTER 296,0,"T",16,16


 LETTER   0,16,"U",16,16
 LETTER  16,16,"V",16,16
 LETTER  32,16,"W",16,16
 LETTER  48,16,"X",16,16
 LETTER  64,16,"Y",16,16
 LETTER  80,16,"Z",16,16
 LETTER  96,16,"0",16,16
 LETTER 112,16,"1",16,16
 LETTER 128,16,"2",16,16
 LETTER 144,16,"3",16,16
 LETTER 160,16,"4",16,16
 LETTER 176,16,"5",16,16
 LETTER 192,16,"6",16,16
 LETTER 208,16,"7",16,16
 LETTER 224,16,"8",16,16
 LETTER 240,16,"9",16,16

 LETTER   0,32,"?",16,16
 LETTER  16,32,"!",8,16
 LETTER  24,32,".",8,16
 LETTER  32,32,44,8,16,4		; "," <= Devpac bug
 LETTER  40,32,":",8,16
 LETTER  48,32,";",8,16,8
 LETTER  56,32,"'",8,16
 LETTER  64,32,"(",8,16
 LETTER  72,32,")",8,16
 LETTER  80,32,34,16,16		; <">
 LETTER  96,32,"-",16,16
 LETTER 112,32,"/",16,16
 LETTER 128,32,"\",16,16
 LETTER 144,32,"#",24,16	; ATARI logo

 LETTER   0,48,"a",16,22
 LETTER  16,48,"b",16,22
 LETTER  32,48,"c",16,22
 LETTER  48,48,"d",16,22
 LETTER  64,48,"e",16,22
 LETTER  80,48,"f",8,22
 LETTER  88,48,"g",16,22
 LETTER 104,48,"h",16,22
 LETTER 120,48,"i",8,22
 LETTER 128,48,"j",8,22
 LETTER 136,48,"k",16,22
 LETTER 152,48,"l",8,22
 LETTER 160,48,"m",16,22
 LETTER 176,48,"n",16,22
 LETTER 192,48,"o",16,22
 LETTER 208,48,"p",16,22
 LETTER 224,48,"q",16,22
 LETTER 240,48,"r",8,22
 LETTER 248,48,"s",16,22
 LETTER 264,48,"t",8,22
 LETTER 272,48,"u",16,22
 LETTER 288,48,"v",16,22
 LETTER 304,48,"w",16,22

 LETTER   0,72,"x",16,22
 LETTER  16,72,"y",16,22
 LETTER  32,72,"z",16,22

 dc.b 0	; -End-

 even


;
; Bytes in the scroller text:
; 0 -> End of scroller
; 1 -> Special effect
; Other => Character to display
;
; Description of special effects:
; 0 -> SetSpeed
;      - 0/1/2/3 for speed from SLOW to TURBO
;
; 1 -> Scroll pause
;      - byte -> Delay to wait in number of frames before inserting a new character (max=255vbls => 5 seconds) 
;
; 2 -> Set palette
;      - byte -> Number of VBL to produce the color fade
;      - long -> Pointer on the new palette :D

CODE_EFFECT_RESTART_SCROLLER		equ 0
CODE_EFFECT_SPEED 					equ 1
CODE_EFFECT_STOP  					equ 2
CODE_EFFECT_SETPALETTE				equ 3
CODE_EFFECT_SETGLOBALSINUS_SPEED	equ 4
CODE_EFFECT_RUN_SUBPART				equ 5
CODE_EFFECT_SETROTATION_SPEED		equ 6
CODE_EFFECT_SETROTATION_ANGLE		equ 7
CODE_EFFECT_SETBACKGROUND_SPEED		equ 8

;
; Restart 'effect'
;
EFFECT_RESTART_SCROLLER macro
 dc.b 0,CODE_EFFECT_RESTART_SCROLLER
 endm


;
; Speed effects
;
EFFECT_SPEED_SLOW macro
 dc.b 0,CODE_EFFECT_SPEED
 dc.b 0
 endm

EFFECT_SPEED_NORMAL macro
 dc.b 0,CODE_EFFECT_SPEED
 dc.b 1
 endm

EFFECT_SPEED_FAST macro
 dc.b 0,CODE_EFFECT_SPEED
 dc.b 2
 endm

EFFECT_SPEED_TURBO macro
 dc.b 0,CODE_EFFECT_SPEED
 dc.b 3
 endm

EFFECT_SPEED_TURBOx2 macro
 dc.b 0,CODE_EFFECT_SPEED
 dc.b 4
 endm

EFFECT_SPEED_TURBOx3 macro
 dc.b 0,CODE_EFFECT_SPEED
 dc.b 5
 endm

EFFECT_SPEED_TURBOx4 macro
 dc.b 0,CODE_EFFECT_SPEED
 dc.b 6
 endm

;
; Pause effects
;
EFFECT_SCROLL_PAUSE_VBL macro
 dc.b 0,CODE_EFFECT_STOP
 dc.b \1
 endm

EFFECT_SCROLL_PAUSE_SECONDS macro
 dc.b 0,CODE_EFFECT_STOP
 dc.b (\1)*50
 endm

;
; Set palette effects
;
EFFECT_SET_SCROLLER_PALETTE macro
 dc.b 0,CODE_EFFECT_SETPALETTE
 even
 dc.l (\1)
 endm

;
; Global sinus effects
;
EFFECT_SET_SCROLLER_GLOBALSINUS_SPEED macro
 dc.b 0,CODE_EFFECT_SETGLOBALSINUS_SPEED
 dc.b (\1)
 endm
 
;
; Effect that quits the intro to run something else
; 
EFFECT_RUN_SUBPART macro
 dc.b 0,CODE_EFFECT_RUN_SUBPART
 even
 dc.l (\1)
 endm 

;
; Global rotation effects
;
CODE_EFFECT_SETROTATION_SPEED macro
 dc.b 0,CODE_EFFECT_SETROTATION_SPEED
 dc.b (\1)
 endm

EFFECT_SETROTATION_ANGLE macro
 dc.b 0,CODE_EFFECT_SETROTATION_ANGLE
 dc.b (\1)
 endm

 
;
; Global paralax background effects
;
EFFECT_SETBACKGROUND_SPEED macro
 dc.b 0,CODE_EFFECT_SETBACKGROUND_SPEED
 dc.b (\1)
 endm
 

 
message_scroller
 ;
 ; Start by a sequence with a all white scroller
 ; That just moves slowly with Creators message,
 ; and with just a very plain background with just rasters
 ;
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_allwhite
 EFFECT_SET_SCROLLER_GLOBALSINUS_SPEED 0
 EFFECT_SETBACKGROUND_SPEED 1
 EFFECT_SPEED_SLOW

 dc.b "Creators        "
 EFFECT_SCROLL_PAUSE_SECONDS 2
 dc.b "presents a new demo "
 EFFECT_SPEED_FAST
 dc.b "on the       ## Atari ST ##      "
 EFFECT_SCROLL_PAUSE_SECONDS 2
 
 ;
 ; Then announce that it's missing colors
 ;
 EFFECT_SPEED_NORMAL
 dc.b "Even if a dist scroller is cool, it's lacking colors...   "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_greenish
 dc.b "Definitively better...   "
 
 ;
 ; Then modify the background
 ;
 dc.b "What about improving the background too ???       "
 EFFECT_RUN_SUBPART SubPartSetBackgroundMike
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_blue
 EFFECT_SPEED_TURBO
 
 dc.b "Hum... that's what I call 'violent coders colors' !!!     "
 dc.b "We will not be able to tolerate that for a much longer time...    "
 EFFECT_RUN_SUBPART SubPartSetBackgroundNormal
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_orange

 EFFECT_SPEED_FAST
 dc.b "Yeah baby, that's it :)   Thanks Nerve, that's definitively better ;-)    "
 EFFECT_SET_SCROLLER_GLOBALSINUS_SPEED 0

 EFFECT_SPEED_TURBO
 EFFECT_SETBACKGROUND_SPEED 0
 dc.b "Ok, it was the usual Atari ST intro "
 EFFECT_SETBACKGROUND_SPEED -1
 dc.b "scroller crap that shows you how good the "
 EFFECT_SETBACKGROUND_SPEED -2
 dc.b "coder is, and how he can do a lot of things "
 EFFECT_SETBACKGROUND_SPEED -3
 dc.b "with the effect like changing the speed "
 EFFECT_SETBACKGROUND_SPEED -0
 dc.b "and direction of the background effect !!! "
 EFFECT_SETBACKGROUND_SPEED 1

 ;
 ; Credits
 ;
 EFFECT_SPEED_FAST
 dc.b "Anyway, here are the credits (yeah, original too, I know) for this little incomplete intro:         "
 EFFECT_SPEED_NORMAL

 ;
 ; Ptoing
 ; 
 EFFECT_SETBACKGROUND_SPEED -1
 EFFECT_RUN_SUBPART SubPartSetBackgroundPtoing 
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_greenish
 dc.b "Ptoing      "
 EFFECT_SCROLL_PAUSE_SECONDS 2
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_blue
 dc.b "He has been drawing the font, and also the cool picture with the yellow dudes. "
 dc.b "You don't remember having seen it ? Well, probably because it was not shown. "
 dc.b "Let's correct this...  "    
 EFFECT_RUN_SUBPART SubPartSweaty
 dc.b "    Sweet isn't it ?      "
 
 ;
 ; Crazy Q
 ;
 dc.b "       "
 EFFECT_SETBACKGROUND_SPEED 1
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_purple
 dc.b "       "
 EFFECT_RUN_SUBPART SubPartSetBackgroundTriplex
 dc.b "Crazy Q      "
 EFFECT_SCROLL_PAUSE_SECONDS 2
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_greenish
 dc.b "He composed the music for this intro. "
 dc.b "Actually technicaly he made more than one music, but we ran out of memory. "
 dc.b "Too bad, because you are missing the Crazyiest 1 chanel YM experiment ever made ! "
 dc.b "He also painted the Triplex and Matrix backgrounds ;-)      "
 
 ;
 ; Nerve
 ;
 dc.b "       "
 EFFECT_SETBACKGROUND_SPEED 1
 EFFECT_RUN_SUBPART SubPartSetBackgroundNormal
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_orange
 EFFECT_SPEED_NORMAL
 dc.b "       "
 dc.b "Nerve      "
 EFFECT_SCROLL_PAUSE_SECONDS 2
 dc.b "In theory we should have had his 3D part, but for technical reasons we were unable to "
 dc.b "make it due to memory and time reasons. It will be released later ! So well he took in charge the "
 dc.b "painting of nicelooking background pattern and logo.     "
 
 ;
 ; Dbug
 ;
 dc.b "       "
 EFFECT_SETBACKGROUND_SPEED -1
 EFFECT_RUN_SUBPART SubPartSetBackgroundMike
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_blue
 EFFECT_SPEED_TURBO
 dc.b "       "
 dc.b "Dbug      "
 EFFECT_SCROLL_PAUSE_SECONDS 2
 dc.b "Responsible for basicaly the code of this intro.   "
 dc.b "And also some of the most terrible pixel butcherizing done in the history of Atari ST demo making ....        "
 
 ;
 ; Additional credits
 ; 
 dc.b "       "
 EFFECT_SETBACKGROUND_SPEED 0
 EFFECT_RUN_SUBPART SubPartSetBackgroundNormal
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_blue
 EFFECT_SPEED_TURBO
 dc.b "       "
 dc.b "Additional credits goes to Proteque and Tero that started some pictures we  "
 dc.b "could not include for memory/delay reasons...    "

 ;
 ; Greetings
 ;
 dc.b "       "
 EFFECT_SETBACKGROUND_SPEED 1
 EFFECT_RUN_SUBPART SubPartSetBackgroundGreetings
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_purple
 EFFECT_SPEED_TURBO
 dc.b "       "
 dc.b "Here are the greetings ! (Have you noticed the small logos behind ?)  "
 EFFECT_SETBACKGROUND_SPEED -1
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_orange
 dc.b "Atari scene Greetings goes to: "
 dc.b "Aggression, "
 dc.b "Alive Team, "
 dc.b "Checkpoint, "
 dc.b "Cream, "
 dc.b "DHS, "
 dc.b "Evolution, "
 dc.b "Gwem, "
 dc.b "Paradize, "
 dc.b "Paradox, "
 dc.b "Lineout, "
 dc.b "Loud, "
 dc.b "MJJ Prod "
 dc.b "New Beat, "
 dc.b "P.H.F., "
 dc.b "Reservoir Gods, "
 dc.b "Stax, "
 dc.b "St Knights, "
 dc.b "Stu, "
 dc.b "The Sirius Cybernetics Corporation, "
 dc.b "Yescrew, "
 dc.b "YM-Rockerz, "
 dc.b "      "
 
 EFFECT_SETBACKGROUND_SPEED 1
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_blue
 dc.b "Amiga scene Greetings goes to: "
 dc.b "Scoopex, "
 dc.b "Ephidrena, "
 dc.b "Spaceballs, "
 dc.b "Uprough, "
 dc.b "Razor 1911, "
 dc.b "      "

 EFFECT_SETBACKGROUND_SPEED -1
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_greenish
 dc.b "C-64 Scene : "
 dc.b "Fairlight, "
 dc.b "Hack n Trade, "
 dc.b "Triad. "
 dc.b "      "

 EFFECT_SETBACKGROUND_SPEED 1
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_purple
 dc.b "Oric greetings : "
 dc.b "Defence-Force, "
 dc.b "TetraKnight Squad 348, "
 dc.b "CEO and all oric fans... "
 dc.b "      "
 
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_allwhite
 dc.b "No Greetings to The Bits Club because releasing crap after crap is pointless....      "
 
 
 ;
 ; Personal messages
 ;
 EFFECT_RUN_SUBPART SubPartSetBackgroundNormal
 EFFECT_SPEED_TURBO
 dc.b "And now some personal messages:       "
 EFFECT_SPEED_NORMAL
 
 ;
 ; Proteque message
 ;
 EFFECT_SETBACKGROUND_SPEED 2
 dc.b "       "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_blue
 EFFECT_SPEED_FAST
 dc.b " Proteque is on the keyboard .... "
 EFFECT_SCROLL_PAUSE_SECONDS 2
 dc.b "I am happy to be able to congratulate the ATARI with its"
 dc.b " 40. birthday!"
 EFFECT_SCROLL_PAUSE_SECONDS 2
 dc.b " Kindergarden is coming up and I am glad that so many"
 dc.b " of the Creators members are comming. I hope and think"
 dc.b " it will be a smashing party."
 EFFECT_SCROLL_PAUSE_SECONDS 2
 dc.b " I will also like to welcome our new members StingRay and Ptoing. "
 dc.b " They are most likely joining us at kindergarden and the preparty aswell. "
 dc.b " Thats it. I have nothing more to say. Signing off. Bye! "
 
 ;
 ; Nerve message
 ;
 dc.b	"nerve hitting keyz. yoyo! And gratz peeps! 40!?"
 dc.b	"Anyway, spent lots of time coding a part for this "
 dc.b	"prod, and then in the end i wasnt able to "
 dc.b	"finish my shizzle. Aw, how typical me. Well, mad props "
 dc.b	"to Dbug the almighty for coming thru with his code! "
 dc.b	"No space left for my part anyway i've been told. "
 dc.b	"And so i'm sitting here trying to bust some pixels "
 dc.b	"instead. Hahaaa. Yea yea. Thanks to my lovely wife " 
 dc.b	"Hanne for letting me be myself as always! "
 dc.b	"Also many thanks to Dbug, Ptoing, Crazy Q and Stingray "
 dc.b	"for all their support, moral, artistic and tecnical... "
 dc.b	"Life will only get better from this point. Peace Out!    " 
 dc.b "Personal greetings too: "
 dc.b "keyboarders, "
 dc.b "portal process, "
 dc.b "spaceballs, "
 dc.b "contraz, "
 dc.b "excess, "
 dc.b "nocturnal, "
 dc.b "outracks, "
 dc.b "kvasigen, "
 dc.b "scarab, "
 dc.b "effect, "
 dc.b "dual crew shining, "
 dc.b "the black lotus, "
 dc.b "inf, "
 dc.b "asm soft, "
 dc.b "evolution... "
 

 ;
 ; Blind IO message
 ;
 EFFECT_SETBACKGROUND_SPEED 1
 dc.b "       "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_purple
 EFFECT_SPEED_FAST
 dc.b "Hi there, this is Blind Io behind the keys. "
 dc.b "It has been a long "
 dc.b "time since I was visible on the scene, so I thought "
 dc.b "I would take this opportunity to say hello.    "
 dc.b "Regretfully, my schedule has been quite full the "
 dc.b "last months, so I have not made anything for "
 dc.b "the anniversary.       "
 dc.b "My respect goes to all who have taken time to "
 dc.b "participate in the compo, especially to my fellow "
 dc.b "Creators for making this great contribution...      "
 dc.b " Take care!   "

 ;
 ; Crazy Q message
 ;
 dc.b "       "
 EFFECT_SETBACKGROUND_SPEED -1
 EFFECT_RUN_SUBPART SubPartSetBackgroundTriplex
 dc.b "       "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_orange
 EFFECT_SPEED_FAST
 dc.b "Hello fellow ATARI loverz !! This is Crazy Q at the keyboard, "
 dc.b "I hope you all like this retro oldchool screen. I know I do. "
 dc.b "This is like a dream come true for me, I always liked to be a "
 dc.b "part in the old demos , like Cuddly Demos for example. "
 dc.b "Since this screen uses overscan I was forced to make a non sid tune "
 dc.b "and that made me look at the Cuddly demos agin, just so I could get "
 dc.b "the right retro vibe for my tune. I know this tune is quite minimal "
 dc.b "(like al my tune), but I hope you all like it any way. "
 dc.b "I must say that the ATARI ST is one hell of a computer !!!! "
 dc.b "My amiga 1200 have crashed on me twice (damm HD driver), and one of my C-64's "
 dc.b "died on me last night. But my ST/STE/Falcon still works like a charm !!! "
 dc.b "I have not been active in the scene as long as most of you folks "
 dc.b "(at least not in serious crews)!!! "
 dc.b "I'm really glad to see the ATARI get 20 years old with Pride, and also to "
 dc.b "been able to takeing apart of celebreting it. "
 dc.b "Also personal greetings to: "
 dc.b "The rest of the Creators Crew, "
 dc.b "Sam Tramiel for the ST, "
 dc.b "DHS, "
 dc.b "My girlfriend Maja, "
 dc.b "Gwen, "
 dc.b "Stu, "
 dc.b "Marcer, "
 dc.b "Dubmood, "
 dc.b "Damo, "
 dc.b "All at Paris HQ, "
 dc.b "YM-Rockerz, "
 dc.b "Sh3, "
 dc.b "Cxt, "
 dc.b "everyone at #atariscne, "
 dc.b "and everyone i forgot..."
 dc.b "Well this is all I have to say for now... "
 dc.b "(I need to get back to my misstres lady YM-2149)     "
 dc.b "Blip Blop - YM non STOP ................................... " 

 ;
 ; Hanne's message
 ;
 dc.b "       "
 EFFECT_RUN_SUBPART SubPartSetBackgroundHanne
 dc.b "       "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_allDarkGreen
 EFFECT_SPEED_FAST
 dc.b "Hi! This is Hanne, Dbug's girlfriend. "
 dc.b "During the past weeks I have been -lucky- enough "
 dc.b "to see this demo evolve. I can assure that a lot of blood, sweat and time have gone into making this demo. "
 dc.b "But I guess that comes with the package of having a coder as boyfriend ;) "
 dc.b "I am impressed with this demo and the effort everyone has been putting into it. "
 dc.b "I would like to congratulate Creators with the result and the Atari ST 20th anniversary :) "

 ;
 ; Dbug's message
 ;
 dc.b "       "
 EFFECT_RUN_SUBPART SubPartSetBackgroundMatrix
 dc.b "       "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_orange
 EFFECT_SPEED_TURBO
 dc.b "Ok, Dbug at the keyboard now to bore you even more after all that long text stuff !!! "
 dc.b "So well some technical infos. In theory this code should work on STF,STE,MSTE, non accelerated FALCON and STEEM "
 dc.b "since it has been tested on these various machines. In theory it should also work on other more esoteric machines "
 dc.b "like TT, or accelerated Falcons, but you never know :) "
 dc.b "You cannot imagine how hard it is to get back to 68000 coding after 10 years coding nothing on this machine.     "
 dc.b "Anyway I tried to do something clean and compatible, so please if there are problems just forgive me :)    "
 dc.b "And some last words:    "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_allwhite
 dc.b "NEVER GIVE UP ! NEVER SURRENDER !    "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_orange
 dc.b "There is no spoon...     "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_blue
 dc.b "The truth is out there...     "
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_orange
 dc.b "Mega big hugs to Hanne for her patience....       "
 dc.b "Ok let's wrap now :)   "
  
 
 ;
 ; back to normal background thingy
 ;
 dc.b "       "
 EFFECT_RUN_SUBPART SubPartSetBackgroundNormal
  
  
 
 EFFECT_SPEED_NORMAL
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_orange
 EFFECT_SET_SCROLLER_GLOBALSINUS_SPEED 1
 dc.b "In the Atari ST history, numerous have been the demos "
 dc.b "trying to beat the record of the longest possible scroller; "
 dc.b "unfortunately most of them were quite boring to read. "
 dc.b "This one will most probably not be much more interesting, but "
 dc.b "considering the size restiction of this screen it will certainly "
 dc.b "not be the longest: "
 EFFECT_SPEED_SLOW
 EFFECT_SET_SCROLLER_PALETTE palette_scroller_greenish,0	
 dc.b "What a relief !!! "
 dc.b "    "
 EFFECT_SPEED_NORMAL
 dc.b "Let's wrap now !!!!!!!!!" 
 EFFECT_SPEED_FAST
 dc.b "9999999999999999999                    "
 dc.b "8888888888888888888                    "
 EFFECT_SPEED_TURBO
 dc.b "7777777777777777777                    "
 dc.b "6666666666666666666                    "
 EFFECT_SPEED_TURBOx2
 dc.b "5555555555555555555                    "
 dc.b "4444444444444444444                    "
 EFFECT_SPEED_TURBOx3
 dc.b "3333333333333333333                    "
 dc.b "2222222222222222222                    "
 EFFECT_SPEED_TURBOx4
 dc.b "1111111111111111111                    "
 dc.b "0000000000000000000                    "
 dc.b "!!!!!!!!!!!!!!!!!!!                    "
 dc.b "                              "
 dc.b "                              "
 dc.b "                              "
 EFFECT_RESTART_SCROLLER
 
 even
 
;
; We just get this bitplan access table duplicated
; because we will be using (an)+ access mode, and we
; certainly do not want it to be boundchecked at runtime.
;
table_plans_word
var set 0
 rept 256
 dc.w ((((var)/16)*8)+(((var)/8)&1))&255	; Buffer X pos
var set var+8
 endr
var set 0
 rept 256
 dc.w ((((var)/16)*8)+(((var)/8)&1))&255	; Buffer X pos
var set var+8
 endr
 
 even

 
 even

 SECTION BSS

debut_bss

save_palette	 	ds.w 16
fade_vbl_palette	ds.w 16


; Some black area that Will always contains 000,
; can be used for erasing, and space character definition
; Required space is:
; - 32 bytes for a palette (16 words)
; - 64 bytes for a fullregister clearing (16 long words)
; - 128 bytes for a space character: 16 lines by 4 bytes by 2 columns
black_palette	 	ds.l 32

ptr_scr_1   		ds.l 1
ptr_scr_2			ds.l 1

scroller_subpart_ptr	ds.l 1

overscan_line_width		ds.w 1
base_screen_offset		ds.w 1
blocs_per_scanline		ds.w 1
lines_per_screen		ds.w 1
offset_centering		ds.w 1
bytesblocs_per_scanline	ds.w 1
scroller_buffer_offset			ds.l 1
screen_display_scroller_offset	ds.w 1

save_ssp     		ds.l 1	; Supervisor Stack Pointer
save_usp     		ds.l 1 ; User Stack Pointer
save_70      		ds.l 1	; VBL handler
save_120	 		ds.l 1	; HBL handler

save_tt_rez			ds.w 1

save_iera			ds.b 1
save_ierb			ds.b 1
save_imra			ds.b 1
save_imrb			ds.b 1
save_vr				ds.b 1
save_tbcr			ds.b 1	; Timer B control register
save_tbdr			ds.b 1  ; Timer B data register

machine_type		ds.b 1
machine_is_ct60		ds.b 1
machine_is_tt		ds.b 1
machine_is_mste 	ds.b 1
overscan_is_allowed	ds.b 1


 even
			  		ds.l 1000	;400
my_stack      		ds.l 1

save_screen_addr_1 	ds.b 1
save_screen_addr_2 	ds.b 1

save_freq    		ds.b 1
save_rez     		ds.b 1
save_pixl    		ds.b 1
save_vbaselo 		ds.b 1
save_mste_cache		ds.b 1

flag_vbl	 		ds.b 1
flag_exit	 		ds.b 1

music_is_initialised		ds.b 1

scroller_column_counter		ds.b 1	; How many columns remains to be drawn
scroller_frame_counter		ds.b 1	; How many pixels have been set (buffer selection)
scroller_parameter_speed	ds.b 1	; 0/1/2 => Defines the speed
scroller_pause_counter		ds.b 1	; Number of VBL's to wait
scroller_rotation_angle		ds.b 1  ; Current rotation angle for the scroller
scroller_rotation_speed		ds.b 1	; The speed of rotation of the scroller => 0=stop


SinusValue					ds.b 1
SinusValue2					ds.b 1
sinus_global_vertical		ds.b 1	;// The global vertical movement of the scroller
sinus_global_vertical_speed ds.b 1


 even
 
fade_color_count 			ds.w 1			; How many colors do we want to fade (max 256)
source_rgb	 				ds.l 16*6		; RGB components of palettes about to be faded
fade_counter				ds.b 1


palette_index				ds.b 1
palette_fade_index			ds.b 1
palette_speed				ds.b 1			; 0=stopped / 1=moving forward / -1=moving backward
palette_fade_flag			ds.b 1			; 0=stopped / 1=darkening / -1=showing

 even

scroller_read_pixel			ds.l 1	; Let's have fun with a LONG position (3 bits for buffer, other for column)
scroller_write_pixel		ds.l 1
 
ptr_scroller_letter			ds.l 1	; The adress of the current letter to be drawn
ptr_scroller_bitmap			ds.l 1	; Points on the bitmap definition of character
ptr_scroller_bitmap_prev	ds.l 1
ptr_scroller_current_palette	ds.l 1

font_array_info				ds.l 256	; Points on the font definition data
font_array_ptr				ds.l 256	; Points on the bitmap data


scroller_pointer_stack		ds.l (52*2)	; 40 for non overscan, 52 for overscan
;
; 32000 is too short
; Let's hope that 64000 will be enough
;
;buffer_font			ds.l 92000/4	; Realsize to evaluate later
;buffer_font_end

; 230*200+160=46160 => 46336 (rounded to 256 upper)
buffer_screens		ds.l (46336*2+256)/4
buffer_screens_end

;
; For scroller, I need 8 (or 16 ?) buffers.
; Each buffer has to be large enough to accomodate two time the width
; (to act like a rotating buffer).
; Considering the screen is 160 bytes large, for practical reason we allign
; at 256. Multiplied by the maximum
; height of the buffer: 24 (in the current status)
; -> 256*24=6144 per buffer
; If I have 8 of them, it makes a total of 6144*8 (49152 k)
;
buffer_scroller	
buffer_raster_atari_logo
					ds.l (256*SCROLLER_HEIGHT*8)/4
buffer_scroller_end
					ds.l (256*SCROLLER_HEIGHT*8)/4

;
; Buffer for the paralax background colors
;   2 bytes per color
;	8 colors
;   8 animation phases
; 200 scanlines
;  16 fade levels
; 2*8*200*8*16 => 409600 bytes
; 2*8*256*8*16 => 524288 bytes
;
buffer_palette				ds.w 8*200*8*16		; WARNING THIS TAKES HALF A MEG !

gradient_picture_startup	ds.l (200*8*3)/4	; all black -> 4800 bytes
	


;buffer_scroller_size equ buffer_scroller_1-buffer_scroller_0
 
 even

fin_bss       ds.l 1

 end


