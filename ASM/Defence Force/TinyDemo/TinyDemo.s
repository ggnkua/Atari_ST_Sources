;
;                Big Border
;
;      Dbug's entry at the Sommarhack 2017 "Big Border Demo" compo
;
; Disclaimer: This whole shit has been done in less than a week, from scratch
; it's buggy, I did not have time to have a custom music, there are some glitches
; and there's some memory overwrite.
;
; Also the code structure is inexistant, there's some random stuff which is not used...
;
;
; http://dhs.nu/bbs-scene/index.php?request=19478
;
; --------------------------------------------------------
; Hi!
; 
; Just want to inform that this year at Sommarhack we will have an additional compo that is quite easy to participate in.
; It's a tribute to the Syntax Terror "Big Border demo" by the Delta Force.
; 
; The rules are easy
; - Demo should fit inside 96*54 pixels centered on the ST-LOW screen
; - No rasterbars outside the 96*54 window
; - Should work on a 520 ST(f/m/fm) machine without expansions (can use auto folder or bootsector loader to save memory if needed)
; 
; Anything goes, multipart, single part, assembler, basic..
; 
; Deadline is set to 17:00 CET, Saturday July 8.
; Please E-mail to: sommarhack@dhs.nu
; 
; We are greatful if entries are sent in earlier though, less stress at compo night.
; 
; Thanks and we hope you have a great summer :)
; 
; --
; Anders Eriksson
; ae@dhs.nu
; --------------------------------------------------------
;
; TOS memory usage from cold boot:
;  1.04    -> 448434 bytes free (from $a84e to $78000)
;  1.62uk  -> 413696 bytes free from GEM, 442368 from AUTO
;


stack_size				set 1500

KEY_SPACE	 			equ $39 
KEY_ARROW_LEFT	equ $4b
KEY_ARROW_RIGHT equ $4d

enable_intro      equ 1
enable_deltaforce equ 1
enable_midtro     equ 1
enable_title      equ 1
enable_level16    equ 1
enable_overlander equ 1
enable_greetings  equ 1

enable_music     equ 1

picture_height  equ 400
;picture_offset  equ 32*picture_height
;picture_has_multi_palettes equ 1


; ================================
;         Utility macros
; ================================

; 1=filename
; 2=start label
; 3=end label (optional)
FILE macro
 even
\2
 incbin \1
 ifne NARG-3
\3
 endc
 even
 endm
 

PRNLOOP macro 
 add.l d0,d0      ; shift left 1 bit
 bcc.s .\@        ; branch if bit 32 not set
 eor.b d1,d0      ; do galois LFSR feedback
.\@
 endm


 opt o+,w-
  
 SECTION TEXT
   
; ------------------
;   Program start
; ------------------
ProgStart 
 ; Call the main routine in supervisor mode
 move.l #SupervisorMain,-(sp)
 move.w #$26,-(sp)
 trap #14
 addq.w #6,sp

 ; Quit
 clr.w -(sp)
 trap #1
 

SupervisorMain
 move #$2700,sr

 ;
 ; This has to be done first, else we will lose data
 ; We need to start by clearing the BSS in case of some packer let some crap
 ;
 lea bss_start,a0					
 lea bss_end,a1 
 moveq #0,d0
.loop_clear_bss
 move.l d0,(a0)+
 cmp.l a1,a0
 ble.s .loop_clear_bss
 
 ;
 ; Can now safely save the stack pointer and allocate our own stack.
 ;
 move.l sp,save_ssp
 lea my_stack,sp 					
 
 ;
 ; Save all the hardware addresses we are going to modify
 ; 
 move.l usp,a0							; Need to save USP in case of a not totaly regular usage ;)
 move.l a0,save_usp

 move.b $fffffa07.w,save_iera
 sf $fffffa07.w	; iera

 move.b $fffffa09.w,save_ierb
 sf $fffffa09.w	; ierb

 move.b $fffffa13.w,save_imra
 sf $fffffa13.w ; imra

 move.b $fffffa15.w,save_imrb
 sf $fffffa15.w ; imrb

 move.b $ffff820a.w,save_freq
 move.b $ffff8260.w,save_rez

 move.b $ffff8201.w,save_screen_addr_1	; Screen base pointeur (STF/E)
 move.b $ffff8203.w,save_screen_addr_2	; Screen base pointeur (STF/E)
  
 movem.l $ffff8240.w,d0-d7				      ; STF/STE Palette
 movem.l d0-d7,save_palette
 move.w #1,$ffff8240.w

 move.l $70.w,save_70					          ; Save original VBL handler
 move.l #VblDoNothing,$70.w
 move.l $120.w,save_120

 
 ;
 ; Set the screen at the right adress
 ;
 lea $ffff8201.w,a0               ; Screen base pointeur (STF/E)
 move.l #screen_buffer+256,d0
 clr.b d0
 move.l d0,screen_phys_ptr       ; Save the aligned screen address
 move.l d0,d1
 lsr.l #8,d0					           ; Allign adress on a byte boudary for STF compatibility
 movep.w d0,0(a0) 
 sf.b 12(a0)					           ; For STE low byte to 0
 add.l #32000,d1
 move.l d1,screen_log_ptr
  
 bsr KeyboardFlushBuffer
 move #$2300,sr

 ; -----------------------------------------
 ;
 ;                 Main part
 ;
 ; -----------------------------------------
 move.l sp,RestoreAndQuitStack
 bsr ActualDemoLoop

RestoreAndQuit 
 jsr YmSilent


 move.l #VblDoNothing,$70.w

 ;
 ; Restore everything
 ;
 move #$2700,sr

 move.l save_usp,a0
 move.l a0,usp

 move.b save_iera,$fffffa07.w
 move.b save_ierb,$fffffa09.w
 move.b save_imra,$fffffa13.w
 move.b save_imrb,$fffffa15.w

 move.b save_freq,$ffff820a.w
 move.b save_rez,$ffff8260.w

 move.b save_screen_addr_1,$ffff8201.w
 move.b save_screen_addr_2,$ffff8203.w
 
 movem.l save_palette,d0-d7
 movem.l d0-d7,$ffff8240.w

 move.l save_70,$70.w

 move.l save_120,$120.w

 bsr KeyboardFlushBuffer

 move #$2300,sr
  
 move.l save_ssp,sp
 rts  


RestoreAndQuitStack dc.l 0
; RestoreAndQuit


WaitDelay 
 bsr WaitVbl
 dbra d0,WaitDelay
DoNothing
 rts


WaitVbl
 sf flag_vbl
SyncVbl
.loop
 tst.b flag_vbl
 beq.s .loop
 sf flag_vbl

 ; Check the keyboard status
 btst #0,$fffffc00.w
 beq .end_wait
 move.b $fffffc02.w,last_key
 cmp.b #KEY_ARROW_RIGHT,last_key
 bne .end_skip_sequence
 st.b skip_sequence
.end_skip_sequence
 cmp.b #KEY_SPACE,last_key
 bne .end_wait 

 ; Space pressed: Violent quit
 move.l RestoreAndQuitStack,sp
 jmp RestoreAndQuit

.end_wait
 rts
 
KeyboardFlushBuffer
 btst.b #0,$fffffc00.w      ; Have we some keys to wait for ?
 beq.s .exit
 tst.b $fffffc02.w
 bra.s KeyboardFlushBuffer
.exit
 rts
  

WaitSpace
 bsr KeyboardFlushBuffer
.loop_wait
 btst #0,$fffffc00.w
 beq .loop_wait
 cmp.b #KEY_SPACE,$fffffc02.w
 bne .loop_wait 
 rts

  
YmSilent
 move.b #8,$ffff8800.w    ; Volume register 0
 move.b #0,$ffff8802.w      ; Null volume
 move.b #9,$ffff8800.w    ; Volume register 1
 move.b #0,$ffff8802.w      ; Null volume
 move.b #10,$ffff8800.w   ; Volume register 2
 move.b #0,$ffff8802.w      ; Null volume
 rts
  
VblPlayMusic
 movem.l d0-a6,-(sp)
 lea music_level16,a0
 jsr 8(a0) 
 movem.l (sp)+,d0-a6
 rts

ActualDemoLoop
 ; Initialize musics
 lea music_level16,a0
 jsr (a0) 

 ifne enable_intro
 bsr IntroSequence
 endc

 ifne enable_deltaforce
 bsr DeltaForceSequence
 endc

 ifne enable_midtro
 bsr MidTroSequence
 endc

 ifne enable_level16
 bsr Level16Sequence
 endc

 ifne enable_midtro
 bsr MidTroSequence2
 endc

 ifne enable_overlander
 bsr OverlandersSequence
 endc

 ifne enable_greetings
 bsr GreetingsSequence
 endc
 rts



; -----------------------------------------------------------------------------
;
;                             Intro Sequence with text
;
; Text: Cyberfunk size 16
;
; -----------------------------------------------------------------------------

; http://d-bug.mooo.com/beyondbrown/post/MFP%2068901%20Interrupts%20Timer%20B/
IntroSequenceVbl
 movem.l d0-d7/a0-a6,-(sp)
 sf.b $ffff8260.w            ; Force to low resolution mode

 ; Setup the palette
 movem.l IntroPalette,d0-d7
 movem.l d0-d7,$ffff8240.w  

 jsr VblPlayMusic

 ; Force the background color to some grey
 ;move.w #$111,$ffff8240.w

 movem.l (sp)+,d0-d7/a0-a6
 st flag_vbl
 eor.b #1,flip_flop
 rte


IntroPalette
 dcb.w 16,$000

IntroPaletteFadeIn
 ; First set of colors
 dc.w $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$000,$000,$111,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$111,$111,$222,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$111,$222,$333,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$222,$333,$444,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$222,$444,$555,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$666,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

 dc.w $000,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

 ; Second set of colors
 dc.w $000,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$000,$000,$111,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$111,$111,$222,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$111,$222,$333,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$222,$333,$444,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$222,$444,$555,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$666,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000

 dc.w $000,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000

 ; Third set of colors
 dc.w $000,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$000,$000,$111,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$111,$111,$222,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$111,$222,$333,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$222,$333,$444,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$222,$444,$555,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$666,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000

 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000

 ; Fourth set of colors
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$111,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$111,$111,$222,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$111,$222,$333,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$222,$333,$444,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$222,$444,$555,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$333,$555,$666,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000

 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000

IntroPaletteFadeOut
 dc.w $000,$333,$555,$777,$333,$555,$777,$333,$555,$777,$333,$555,$777,$000,$000,$000
 dc.w $000,$333,$555,$666,$333,$555,$666,$333,$555,$666,$333,$555,$666,$000,$000,$000
 dc.w $000,$222,$444,$555,$222,$444,$555,$222,$444,$555,$222,$444,$555,$000,$000,$000
 dc.w $000,$222,$333,$444,$222,$333,$444,$222,$333,$444,$222,$333,$444,$000,$000,$000
 dc.w $000,$111,$222,$333,$111,$222,$333,$111,$222,$333,$111,$222,$333,$000,$000,$000
 dc.w $000,$111,$111,$222,$111,$111,$222,$111,$111,$222,$111,$111,$222,$000,$000,$000
 dc.w $000,$000,$000,$111,$000,$000,$111,$000,$000,$111,$000,$000,$111,$000,$000,$000
 dc.w $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000


IntroSequence
 move.l #IntroSequenceVbl,$70.w
 bsr WaitVbl

 ; After years of research
 lea intro_text+32+48*55*0,a0
 bsr IntroShowPicture

 ; and gallons of coffee
 lea intro_text+32+48*55*1,a0
 bsr IntroShowPicture

 ; Defence Force did it:
 lea intro_text+32+48*55*2,a0
 bsr IntroShowPicture

 ; Better Bigger Borders
 lea intro_text+32+48*55*3,a0
 bsr IntroShowPicture
 rts


MidTroSequence
 move.l #IntroSequenceVbl,$70.w
 bsr WaitVbl

 ; Yes indeed this was the original big borders
 lea intro_text+32+48*55*4,a0
 ;bsr IntroShowPicture

 ; By the Way this demo was inspired by...
 lea intro_text+32+48*55*5,a0
 bsr IntroShowPicture

 ifne enable_title
 bsr IntroShowTitlePicture
 endc

 ; What about mixing?
 lea intro_text+32+48*55*6,a0
 bsr IntroShowPicture

 rts 


MidTroSequence2
 move.l #IntroSequenceVbl,$70.w
 bsr WaitVbl

 ; What about hardscroll?
 lea intro_text+32+48*55*7,a0
 bsr IntroShowPicture
 rts 



; a0=picture base
IntroShowPicture
 ; Make sure the palette is black
 movem.l black_palette,d0-d7
 movem.l d0-d7,IntroPalette
 bsr WaitVbl

 ; Display the picture
 move.l screen_phys_ptr,a1
 lea 56+73*160(a1),a1

 move.w #54-1,d7
.copy_loop
 REPT 48/4
 move.l (a0)+,(a1)+
 ENDR
 lea 160-48(a1),a1
 dbra d7,.copy_loop 

 ; Show the palette
 lea IntroPaletteFadeIn,a0
 moveq #(8+4)*4-1,d7
.fade_in 
 movem.l (a0)+,d0-d6/a1
 movem.l d0-d6/a1,IntroPalette
 bsr WaitVbl
 bsr WaitVbl
 tst.b skip_sequence
 bne .end_sequence
 dbra d7,.fade_in

 ; Wait one second
 move #50*2,d0
 bsr WaitDelay

 ; Fade out
 lea IntroPaletteFadeOut,a0
 moveq #8-1,d7
.fade_out
 movem.l (a0)+,d0-d6/a1
 movem.l d0-d6/a1,IntroPalette
 bsr WaitVbl
 bsr WaitVbl
 tst.b skip_sequence
 bne .end_sequence
 dbra d7,.fade_out

.end_sequence
 sf.b skip_sequence
 rts


IntroShowTitlePicture
 move.l #intro_title_picture,palette_base_ptr
 move.l #intro_title_picture+32*54,picture_start_pointer
 bsr CopyBitmap96x54

 move.l #VblFlipFlop,$70.w
 bsr WaitVbl

 bsr KeyboardFlushBuffer

 ; Wait a bit
 move #50*3-1,effect_loop_counter
.animate_loop 
 bsr WaitVbl
 tst.b skip_sequence
 bne .end_sequence
 subq #1,effect_loop_counter
 bne .animate_loop

.end_sequence
 sf.b skip_sequence

 move.l #IntroSequenceVbl,$70.w
 bsr WaitVbl
 rts



intro_text
 incbin "exported\intro_text.pi1"

intro_title_picture
 incbin "exported\breaking_the_borders_96x54.pi1"


; -----------------------------------------------------------------------------
;
;                                 Level 16 fullscreen mini screen
;
; Color allocation:
; 0 -> Black
; 1 -> From lines 16 to 22: RGB Gradient over the 16 number
; 2 -> From lines 18 to 26: Color cycling over the waterfall
;
;
; -----------------------------------------------------------------------------

Level16Sequence
 move.w #3,cycling_counter
 move.l #level_16_base_screen,palette_base_ptr
 move.l #level_16_base_screen+32*54,picture_start_pointer
 bsr CopyBitmap96x54

 move.l #VblFlipFlop,$70.w              ; New VBL handler
 bsr WaitVbl

 bsr KeyboardFlushBuffer

 ; Wait a bit
 ; Show the palette
 ;move #50*20,effect_loop_counter
 move #50*30,effect_loop_counter
.animate_loop 
 bsr WaitVbl
 bsr Level16Animate
 tst.b skip_sequence
 bne .end_sequence
 ;bra .animate_loop
 subq #1,effect_loop_counter
 bne .animate_loop

.end_sequence
 sf.b skip_sequence

 move.l #IntroSequenceVbl,$70.w
 bsr WaitVbl
 rts

Level16Animate 
 subq #1,cycling_counter
 bne .skip_animation
 move.w #3,cycling_counter

 lea level_16_base_screen,a0

 ; Animate the "16" gradient
 move.l level_16_gradient_position,a1
 lea 2(a1),a1
 cmp.w #$fff,7*2(a1)
 bne .skip
 lea level_16_gradient,a1
.skip 
 move.l a1,level_16_gradient_position

 move (a1)+,32*16+2(a0)
 move (a1)+,32*17+2(a0)
 move (a1)+,32*18+2(a0)
 move (a1)+,32*19+2(a0)
 move (a1)+,32*20+2(a0)
 move (a1)+,32*21+2(a0)
 move (a1)+,32*22+2(a0)


 ; Color cycle the water falling
 ;bra .skip_animation
 move.l level_16_waterfall_position,a1
 lea -2(a1),a1
 cmp.l #level_16_waterfall,a1
 bne .skip2
 lea level_16_waterfall_end,a1
.skip2
 move.l a1,level_16_waterfall_position

 move (a1)+,32*18+4(a0)
 move (a1)+,32*19+4(a0)
 move (a1)+,32*20+4(a0)
 move (a1)+,32*21+4(a0)
 move (a1)+,32*22+4(a0)
 move (a1)+,32*23+4(a0)
 move (a1)+,32*24+4(a0)
 move (a1)+,32*25+4(a0)
 move (a1)+,32*26+4(a0)

 ; Colors for the scrolltext
 lea level_16_scroller_gradient,a1
 move.l a0,a2
 moveq #38-1,d7
.loop_scroller_gradient
 move.w (a1)+,15*2(a2)
 lea 32(a2),a2
 dbra d7,.loop_scroller_gradient 


 ; Add the scroll text
 move.l level_16_scroller_position,a0
 lea 8(a0),a0
 move.l a0,level_16_scroller_position

 move.l screen_phys_ptr,a1
 lea 56+73*160+8*5(a1),a1

 move.l #level_16_base_screen+32*54+8*5,a2

 moveq #18-1,d7
.loop_scroller
 ; Part over the tube
 movep.l 0(a0),d0   ; Scroller
 movep.l 1(a2),d1   ; Original background
 or.l d1,d0         ; Mask in
 movep.l d0,1(a1)   ; Blitt

 ; Part under the tube
 movep.l 21*8+0(a0),d0    ; Scroller
 movep.l 21*48+1(a2),d1   ; Original background
 or.l d1,d0               ; Mask in
 movep.l d0,21*160+1(a1)  ; Blitt

 lea 8(a0),a0
 lea 160(a1),a1
 lea 48(a2),a2
 dbra d7,.loop_scroller 

.skip_animation

 rts


level_16_base_screen
 incbin "exported\fullscreen_union_level16.pi1"

level_16_scroller
  incbin "exported\fullscreen_union_level16_scroller.pi1"

level_16_scroller_position dc.l level_16_scroller+32 ; +38*8


level_16_gradient
 dc.w $007,$017,$027,$037,$047,$057,$067,$077
 dc.w $177,$277,$377,$477,$577,$677,$777
 dc.w $676,$575,$474,$373,$272,$171,$070
 dc.w $170,$270,$370,$470,$570,$670,$770
 dc.w $771,$772,$773,$774,$775,$776,$777
 dc.w $766,$755,$744,$733,$722,$711,$700
 dc.w $701,$702,$703,$704,$705,$706,$707
 dc.w $607,$507,$407,$307,$207,$107

 dc.w $007,$017,$027,$037,$047,$057,$067,$077,$fff

level_16_gradient_position dc.l level_16_gradient


level_16_waterfall
 dc.w $007,$017,$027,$037,$047,$057,$067,$077,$177,$277,$377,$477,$577,$677,$777
 dc.w $677,$577,$477,$377,$277,$177,$077,$067,$057,$047,$037,$027,$017
level_16_waterfall_end
 dc.w $007,$017,$027,$037,$047,$057,$067,$077,$177,$277,$377,$477,$577,$677,$777

level_16_waterfall_position dc.l level_16_waterfall+2


level_16_scroller_gradient
 REPT 20
 dc.w $237,$553,$362,$631,$316
 ENDR


; -----------------------------------------------------------------------------
;
;                                 Overlander mini screen
;
; Color 15 -> Background rasters
;
; -----------------------------------------------------------------------------

OverlandersSequence
 bsr OverlandersInitialize

 move.w #3,cycling_counter
 move.l #overlander_base_screen,palette_base_ptr
 bsr CopyPalettes
 move.l #overlander_base_screen+32*74,picture_start_pointer
 bsr CopyBitmap96x54_Skip8

 move.l #VblFlipFlop,$70.w              ; New VBL handler
 bsr WaitVbl

 bsr KeyboardFlushBuffer

 ; Wait a bit
 ; Show the palette
 move #50*50,effect_loop_counter
.animate_loop 
 bsr WaitVbl
 bsr OverlandersAnimate
 ;move.w #$000,$ffff8240.w
 tst.b skip_sequence
 bne .end_sequence
 subq #1,effect_loop_counter
 bne .animate_loop

.end_sequence
 sf.b skip_sequence

 move.l #IntroSequenceVbl,$70.w
 bsr WaitVbl
 rts



OverlandersAnimate
 move.w #0,overlander_update_tick
 subq #1,cycling_counter
 bne .skip_animation
 move.w #3,cycling_counter
 move.w #1,overlander_update_tick
.skip_animation

 ; Start by copying the original fixed rasters
 lea overlander_base_screen,a4  ; Original of the colors
 lea palettes,a5                ; Current screen copy
var set 0 
 REPT 54
 move.w 30+var*32(a4),30+var*32(a5)
 ;move.w #var,30+var*32(a5)
var set var+1 
 ENDR

 ; Then copy the scroller
 bsr OverlanderScroll

 ; Show the rotating rasters 
 lea overlander_raster_offsets,a3
 move.l #overlander_base_screen,a4  ; Original of the colors
 move.l palette_base_ptr,a5         ; Current screen copy
 lea sine_255,a6

 add.w #6,overlander_rasters_angle
 move.w overlander_rasters_angle,d0

 moveq #20-5,d7
.loop_rasters
 add.w #8,d0
 and.w #510,d0
 move.w (a6,d0),d1   ; 16 bits, unsigned between 00 and 127
 add.w d1,d1
 move (a3,d1),d1

 move.w #$232,30+32*2(a5,d1)
 move.w #$343,30+32*0(a5,d1)
 move.w #$565,30+32*1(a5,d1)
 move.w #$232,30+32*2(a5,d1)
 move.w #$121,30+32*2(a5,d1)
 dbra d7,.loop_rasters

 ;
 ; Then add the boucing wizball head
 ; Ball is 60x44 (80x44 box)
 ;
 ;move.w #$070,$ffff8240.w

 lea overlander_wizball+32,a0
 lea overlander_wizball_mask,a1
 move.l screen_phys_ptr,a2
 lea 56+73*160+0+160*10(a2),a2

 tst.w overlander_update_tick
 beq .slow_bounce
 add.w #1,overlander_bounce_angle
.slow_bounce 
 move.w overlander_bounce_angle,d0
 and.w #15,d0
 add.w d0,d0

 lea overlanders_bounce_table,a5
 sub (a5,d0),a2

 move.w overlander_horizontal_position,d0
 tst.w overlander_update_tick
 beq .slow_horizontal_bounce

 tst.w overlander_horizontal_direction
 beq .increment

.decrement
 sub.w #1,d0
 cmp.w #0,d0
 bne .end_move
 move.w #0,overlander_horizontal_direction
 bra .end_move

.increment 
 add.w #1,d0
 cmp.w #35,d0
 bne .end_move
 move.w #1,overlander_horizontal_direction

.end_move
 move.w d0,overlander_horizontal_position
.slow_horizontal_bounce

 lea overlander_horizontal_offset,a5
 add.w d0,d0
 add.w d0,d0
 add.w d0,a5
 move.w (a5)+,d0       ; Screen offset
 move.w (a5)+,d1       ; Source sprite offset

 add.w d0,a2           ; Screen position

 ;add.w d1,d0
 add.w d1,a0           ; Bitmap
 lsr.w #2,d1
 add.w d1,a1           ; Mask



 move.w #44-1,d7
.loop_copy_ball 
var set 0
 REPT 5
 move.w (a1)+,d6              ; Mask
 movem.w var*8(a2),d0/d1/d2/d3
 and.w d6,d0
 or.w (a0)+,d0
 and.w d6,d1
 or.w (a0)+,d1
 and.w d6,d2
 or.w (a0)+,d2
 and.w d6,d3
 or.w (a0)+,d3
 movem.w d0/d1/d2/d3,var*8(a2)
var set var+1 
 ENDR

 ;lea 40(a0),a0
 lea 160(a2),a2

 dbra d7,.loop_copy_ball

 rts



OverlandersInitialize
 ; Need to create the mask...
 lea overlander_wizball+32,a0
 lea overlander_wizball_mask,a1

 move.w #(40*44*16)/8-1,d7
.loop_generate_mask 
 move.w (a0)+,d0
 or.w (a0)+,d0
 or.w (a0)+,d0
 or.w (a0)+,d0
 not.w d0
 move.w d0,(a1)+
 ;move.w d0,(a1)+

 dbra d7,.loop_generate_mask
 rts


OverlanderScroll
 ;move.w #$700,$ffff8240.w

 ; Scroll the buffer
 ; Copy the scroll buffer to the screen
 move.l #overlander_base_screen+32*74,a0
 move.l screen_phys_ptr,a1
 lea 56+73*160(a1),a1

 move.w #53-1,d7
.loop_y_scroll
 ; 4 bit plans to scroll
 roxl.w 0+8*6(a0)
 roxl.w 0+8*5(a0)
 roxl.w 0+8*4(a0)
 roxl.w 0+8*3(a0)
 roxl.w 0+8*2(a0)
 roxl.w 0+8*1(a0)
 roxl.w 0+8*0(a0)

 roxl.w 2+8*6(a0)
 roxl.w 2+8*5(a0)
 roxl.w 2+8*4(a0)
 roxl.w 2+8*3(a0)
 roxl.w 2+8*2(a0)
 roxl.w 2+8*1(a0)
 roxl.w 2+8*0(a0)

 roxl.w 4+8*6(a0)
 roxl.w 4+8*5(a0)
 roxl.w 4+8*4(a0)
 roxl.w 4+8*3(a0)
 roxl.w 4+8*2(a0)
 roxl.w 4+8*1(a0)
 roxl.w 4+8*0(a0)

 roxl.w 6+8*6(a0)
 roxl.w 6+8*5(a0)
 roxl.w 6+8*4(a0)
 roxl.w 6+8*3(a0)
 roxl.w 6+8*2(a0)
 roxl.w 6+8*1(a0)
 roxl.w 6+8*0(a0)

 movem.l (a0),d0-d5
 movem.l d0-d5,(a1)

 movem.l 24(a0),d0-d5
 movem.l d0-d5,24(a1)

 lea 48+8(a0),a0
 lea 160(a1),a1

 dbra d7,.loop_y_scroll

 ;rts

 ; Check if done
 subq.w #1,overlander_scroller_counter
 bne .no_reset
 move.w #16,overlander_scroller_counter


 ; Copy the scroll buffer to the screen
 move.l overlander_scroller_position,a0
 add.l #8,overlander_scroller_position
 move.l #overlander_base_screen+32*74+48,a1

 move.w #53-1,d7
.loop_y_copy
 move.l (a0),(a1)
 move.l 4(a0),4(a1)

 lea 1272(a0),a0
 lea 48+8(a1),a1

 dbra d7,.loop_y_copy

 move.l #$fff,(a1)
 move.l #$fff,4(a1)

.no_reset
 rts


; Sprite is 60 pixels wide, screen is 96 pixel wide: 36 pixels movement horizontally
overlander_horizontal_offset
var set 0
 REPT 36
block set var/16
image set var&15 
 dc.w (block*8)
 dc.w (image*40*44)
var set var+1 
 ENDR
overlander_horizontal_position    dc.w 0
overlander_horizontal_direction   dc.w 0



; Sprite is 44 pixels tall, screen is 54 pixels talls: 10 pixels bounce
overlanders_bounce_table
 dc.w 160*0
 ;
 dc.w 160*2
 dc.w 160*4
 dc.w 160*5
 dc.w 160*6
 dc.w 160*7
 dc.w 160*8

 dc.w 160*9
 dc.w 160*9
 dc.w 160*9

 dc.w 160*8
 dc.w 160*7
 dc.w 160*6
 dc.w 160*5
 dc.w 160*4
 dc.w 160*2
 ;
 dc.w 160*0

var set 0
 REPT 256
 dc.w ((var*10)/128)*160
var set var+1 
 ENDR
overlander_bounce_angle   dc.w 0
overlander_update_tick    dc.w 0

overlander_rasters_angle   dc.w 0

overlander_wizball_mask
 ds.w 10*44*16

overlander_raster_offsets
var set 0
 REPT 256
 dc.w ((var*50)/128)*32
var set var+1 
 ENDR

overlander_base_screen
 incbin "exported\overlander_dim_bigscreen.pi1"

; 2544x53
; 1272 bytes * 53 lines = 67416 bytes
overlander_scroller
 incbin "exported\big_scroller_font.pi1"

overlander_wizball
 incbin "exported\wizball.pi1"

overlander_scroller_position
 dc.l overlander_scroller+32

overlander_scroller_counter
 dc.w 1 



; -----------------------------------------------------------------------------
;
;                                 Delta Force mini screen
;
; -----------------------------------------------------------------------------

DeltaForceSequence
 move.l #VblFlipFlop,$70.w              ; New VBL handler
 bsr DeltaForceScreenInitialize

 bsr KeyboardFlushBuffer

 ; Make it appear
 move.w #54,effect_loop_counter
.loop_appear
 add.l #32,palette_base_ptr
 add.l #48,picture_start_pointer

 bsr WaitVbl
 bsr AnimateDeltaForceBigBordersScreen

 tst.b skip_sequence
 bne .end_sequence
 subq #1,effect_loop_counter
 bne .loop_appear

 ;bra .tada
 ; Animate for 2 seconds
 move.w #50*3,effect_loop_counter
.loop_wait
 bsr WaitVbl
 bsr AnimateDeltaForceBigBordersScreen
 tst.b skip_sequence
 bne .end_sequence
 subq #1,effect_loop_counter
 bne .loop_wait

 ; Show the for dimensions
 move.w #16*4-1,effect_loop_counter
.loop_wait_dimensions_1
 bsr WaitVbl
 bsr AnimateDeltaForceBigBordersScreen
 bsr AnimateDeltaForce96x54
 tst.b skip_sequence
 bne .end_sequence
 subq #1,effect_loop_counter
 bne .loop_wait_dimensions_1

 ; Animate for 2 seconds
 move.w #50*2,effect_loop_counter
.loop_wait2
 bsr WaitVbl
 bsr AnimateDeltaForceBigBordersScreen
 tst.b skip_sequence
 bne .end_sequence
 subq #1,effect_loop_counter
 bne .loop_wait2

 ; Show the for dimensions
 move.w #16*4-1,effect_loop_counter
.loop_wait_dimensions_2
 bsr WaitVbl
 bsr AnimateDeltaForceBigBordersScreen
 bsr AnimateDeltaForce48x27
 tst.b skip_sequence
 bne .end_sequence
 subq #1,effect_loop_counter
 bne .loop_wait_dimensions_2

 ; Animate for 2 seconds
 move.w #50*2,effect_loop_counter
.loop_wait3
 bsr WaitVbl
 bsr AnimateDeltaForceBigBordersScreen
 tst.b skip_sequence
 bne .end_sequence
 subq #1,effect_loop_counter
 bne .loop_wait3

 ; Make it disappear
 move.w #54,effect_loop_counter
.loop_disappear
 sub.l #32,palette_base_ptr
 sub.l #48,picture_start_pointer

 bsr WaitVbl
 bsr AnimateDeltaForceBigBordersScreen

 tst.b skip_sequence
 bne .end_sequence
 subq #1,effect_loop_counter
 bne .loop_disappear

.end_sequence
 sf.b skip_sequence
 rts


AnimateDeltaForce96x54
 ; Initialize the palettes
 add.w #1,flashing_colors_96x54_counter
 move.w flashing_colors_96x54_counter,d0
 and #15,d0
 add d0,d0
 lea flashing_colors_96x54,a0
 move.w (a0,d0),d0

 lea palettes+32*54,a1
 move.w #picture_height-1,d7
.loop_copy_palette 
 move.w d0,2(a1)
 lea 32(a1),a1
 dbra d7,.loop_copy_palette 
 rts

AnimateDeltaForce48x27
 ; Initialize the palettes
 add.w #1,flashing_colors_48x27_counter
 move.w flashing_colors_48x27_counter,d0
 and #15,d0
 add d0,d0
 lea flashing_colors_96x54,a0
 move.w (a0,d0),d0

 lea palettes+32*54,a1
 move.w #picture_height-1,d7
.loop_copy_palette 
 move.w d0,4(a1)
 lea 32(a1),a1
 dbra d7,.loop_copy_palette 
 rts



DeltaForceScreenInitialize
 ; Initialize the palettes
 movem.l delta_force_base_screen,d1-d7/a2
 moveq.l #0,d1   ; Force colors 0 and 1 to black
 moveq.l #0,d2   ; Force colors 2 and 3 to black
 lea palettes,a1
 move.w #picture_height-1,d0
.loop_copy_palette 
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.loop_copy_palette 

 ; Start pointers
 move.l #palettes+32*54,palette_base_ptr
 move.l #delta_force_base_screen+32+48*54,picture_start_pointer
 move.l #palettes,palette_base_ptr
 move.l #delta_force_base_screen+32,picture_start_pointer
 rts


; Screen colors:
; 0 -> Black background
; 1 -> Mini-Screen background
; 2 -> Border rasters
; 3 -> red ?
; 4/5/6/7/8/9/10/11/12 -> Diagonal gray rasters (9 colors)
;
; Screen is 27 lines high
;
AnimateDeltaForceBigBordersScreen
 subq #1,cycling_counter
 bne .skip
 move.w #5,cycling_counter

 ; Scroll the background palette
 lea cycling_colors,a0
 movem.w (a0),d0/d1/d2/d3/d4/d5/d6/a1/a2
 move.w a2,(a0)
 movem.w d0/d1/d2/d3/d4/d5/d6/a1,2(a0)

 lea palettes+32*54+32*13+4*2,a0
 moveq #27-1,d7
.loop
 move.w a2,(a0)
 movem.w d0/d1/d2/d3/d4/d5/d6/a1,2(a0)
 lea 32(a0),a0
 dbra d7,.loop 

 ; Small rasters:
 lea palettes+32*54+32*13,a0

 ; Delta Force logo
 lea deltaforce_logo_gradient,a1
 move (a1)+,32*1+3*2(a0)
 move (a1)+,32*2+3*2(a0)
 move (a1)+,32*3+3*2(a0)
 move (a1)+,32*4+3*2(a0)
 move (a1)+,32*5+3*2(a0)
 move (a1)+,32*6+3*2(a0)

 ; Flash offset
 move.w big_border_flash_counter,d0
 add.w #1,d0
 move.w d0,big_border_flash_counter
 and #15,d0
 lsl.w #3,d0

 ; BIG BORDER
 lea big_border_gradient,a1
 add.w d0,a1
 move (a1)+,32*11+3*2(a0)
 move (a1)+,32*12+3*2(a0)
 move (a1)+,32*13+3*2(a0)
 move (a1)+,32*14+3*2(a0)

 ; By Chaos Inc
 lea by_chaos_inc_gradient,a1
 add.w d0,a1
 move (a1)+,32*16+3*2(a0)
 move (a1)+,32*17+3*2(a0)
 move (a1)+,32*18+3*2(a0)

 ; Scroll text
 move #$666,32*24+3*2(a0)
 move #$600,32*25+3*2(a0)
.skip 

 ; Distorter
 lea sine_255,a6
 lea preshifted_delta_force+32,a0
 lea delta_force_base_screen+32+48*54+48*14,a1

 lea delta_force_offset_table,a2

 add.w #6,delta_force_logo_angle
 move.w delta_force_logo_angle,d0

 add.w #4,delta_force_logo_angle2
 move.w delta_force_logo_angle2,d2


 moveq #6-1,d7
.copy_logo
 move.l a0,a3
 lea 48(a0),a0

 add.w #4,d0
 and.w #510,d0
 move.w (a6,d0),d1   ; 16 bits, unsigned between 00 and 127
 lsr.w #5,d1         ; 0-7

 add.w #6,d2
 and.w #510,d2
 move.w (a6,d2),d3   ; 16 bits, unsigned between 00 and 127
 lsr.w #5,d3         ; 0-3
 add.w d3,d1

 lsl.w #1,d1         ; x2
 add.w (a2,d1),a3

 REPT 48/4
 move.l (a3)+,(a1)+
 ENDR
 dbra d7,.copy_logo 

 ; Scroll text
 move.l delta_force_scroll_position,a0
 lea -48*2(a0),a0
 cmp.l #preshifted_delta_force_scroller+32,a0
 bne .skip_reset_scroller
 lea preshifted_delta_force_scroller+32+48*94,a0
.skip_reset_scroller 
 move.l a0,delta_force_scroll_position

 lea delta_force_base_screen+32+48*54+48*37,a1

 REPT 48*2/4
 move.l (a0)+,(a1)+
 ENDR

; Screen structure design:
; Color 0 is used by the border background (black at the moment)
; Color 1 is the mini screen background
; Color 2 is the small outline around the screen
; a0=source
; Copy the picture
 bsr CopyBitmap96x54
 rts



delta_force_base_screen
 incbin "exported\delta_force_base_screen.pi1"

preshifted_delta_force
 incbin "exported\preshifted_delta_force.pi1"

preshifted_delta_force_scroller
 incbin "exported\preshifted_delta_force_scroller.pi1"


; sine_255        ; 16 bits, unsigned between 00 and 127

delta_force_offset_table
 dc.w 48*6*0
 dc.w 48*6*1
 dc.w 48*6*2
 dc.w 48*6*3
 dc.w 48*6*4
 dc.w 48*6*5
 dc.w 48*6*6
 dc.w 48*6*7
delta_force_logo_counter dc.w 1
delta_force_logo_angle   dc.w 0
delta_force_logo_angle2  dc.w 0

delta_force_scroll_position dc.l preshifted_delta_force_scroller+32+48*2


flashing_colors_96x54         dc.w $000,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000
flashing_colors_96x54_counter dc.w 0    

flashing_colors_48x27         dc.w $000,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111,$000,$000
flashing_colors_48x27_counter dc.w 0    

cycling_colors dc.w $555,$444,$333,$222,$111,$222,$333,$444,$555
cycling_counter dc.w 1

; blue/red/orange/yellow 6 pixels tall
deltaforce_logo_gradient
  dc.w $007,$507,$703,$700,$730,$750



big_border_gradient
  dc.w $777,$557,$337,$007
  dc.w $666,$446,$336,$006
  dc.w $555,$335,$225,$005
  dc.w $444,$224,$224,$004
  dc.w $333,$113,$113,$003
  dc.w $222,$112,$112,$002
  dc.w $111,$001,$001,$001
  dc.w $000,$000,$000,$000
  dc.w $111,$001,$001,$001
  dc.w $222,$112,$112,$002
  dc.w $333,$113,$113,$003
  dc.w $444,$224,$224,$004
  dc.w $555,$335,$225,$005
  dc.w $666,$446,$336,$006
  dc.w $777,$557,$337,$007
  dc.w $777,$667,$447,$117
big_border_flash_counter dc.w 0

by_chaos_inc_gradient
  dc.w $777,$757,$737,$000
  dc.w $666,$656,$636,$000
  dc.w $555,$545,$525,$000
  dc.w $444,$444,$424,$000
  dc.w $333,$333,$313,$000
  dc.w $222,$222,$212,$000
  dc.w $111,$111,$101,$000
  dc.w $000,$000,$000,$000
  dc.w $111,$111,$101,$000
  dc.w $222,$222,$212,$000
  dc.w $333,$333,$313,$000
  dc.w $444,$444,$424,$000
  dc.w $555,$545,$525,$000
  dc.w $666,$656,$636,$000
  dc.w $777,$757,$737,$000
  dc.w $777,$767,$747,$000





; -----------------------------------------------------------------------------
;
;                                 Main Sequence
;
; -----------------------------------------------------------------------------



; http://d-bug.mooo.com/beyondbrown/post/MFP%2068901%20Interrupts%20Timer%20B/
VblFlipFlop
 movem.l d0-d7/a0-a6,-(sp)
 sf.b $ffff8260.w            ; Force to low resolution mode

 ; Forces the palette to black again
 bsr SetBlackPalette

 jsr VblPlayMusic

 move.l palette_base_ptr,palette_ptr

 ; Setup the rasters
 clr.b $fffffa1b          ; Stop Timer B

 move.l #HblRoutine,$120.w              ; New HBL handler
 move.b #8,$fffffa1b .w                 ; Timer B in "Event Count" mode
 move.b #%00000001,$fffffa07.w          ; Interrupt Enable
 move.b #%00000001,$fffffa13.w          ; Interrupt Unmasked
 bclr #3,$fffffa17                      ; Set Automatic End-Interrupt
 move.b #73-1,$fffffa21.w               ; Wait 73 scanlines

 movem.l (sp)+,d0-d7/a0-a6
VblDoNothing
 st flag_vbl
 eor.b #1,flip_flop
 rte
       
 

HblRoutine
 move.l #HblRoutineRasters,$120.w      ; New HBL handler
 move.b #1,$fffffa21.w                 ; Wait 1 scanline
 move.b #54,hbl_counter
 rte 

HblRoutineRasters
 move.l a0,-(sp)
 move.l palette_ptr,a0
 addq #2,a0
 move.w (a0)+,$ffff8242.w
var set 4
 REPT 7
 move.l (a0)+,var+$ffff8240.w
var set var+4
 ENDR
 move.l a0,palette_ptr
 move.l (sp)+,a0

 ;add.w #1,$ffff8240.w

 subq.b #1,hbl_counter
 beq.s HblRoutineRastersStop
 rte 

HblRoutineRastersStop
 REPT 20
 nop
 ENDR
 ; Forces the palette to black again
 bsr SetBlackPalette

 ; Force the background color to some grey
 ;move.w #$111,$ffff8240.w

 clr.b $fffffa1b          ; Stop Timer B
 move.b #%00000000,$fffffa07.w          ; Interrupt disabled
 rte 

SetBlackPalette
var set 0 
 REPT 8
 clr.l var+$ffff8240.w
var set var+4
 ENDR
 rts


CopyPalettes
 move.l palette_base_ptr,a0
 lea palettes,a1
 move.l a1,palette_base_ptr

 move.w #54-1,d7
.loop_y
 movem.l (a0)+,d0-d6/a2
 movem.l d0-d6/a2,(a1)
 lea 32(a1),a1
 dbra d7,.loop_y
 rts



CopyBitmap96x54
 move.l picture_start_pointer,a0
 move.l screen_phys_ptr,a1
 lea 56+73*160(a1),a1

 move.w #54-1,d7
.loop_y
 movem.l (a0)+,d0-d5
 movem.l d0-d5,(a1)

 movem.l (a0)+,d0-d5
 movem.l d0-d5,24(a1)

 lea 160(a1),a1

 dbra d7,.loop_y
 rts

;
CopyBitmap96x54_Skip8
 move.l picture_start_pointer,a0
 move.l screen_phys_ptr,a1
 lea 56+73*160(a1),a1

 move.w #54-1,d7
.loop_y
 movem.l (a0)+,d0-d5
 movem.l d0-d5,(a1)

 movem.l (a0)+,d0-d5
 movem.l d0-d5,24(a1)

 lea 8(a0),a0
 lea 160(a1),a1

 dbra d7,.loop_y
 rts


; -----------------------------------------------------------------------------
;
;                   Greetings Sequence with the long logo scroller
;
; -----------------------------------------------------------------------------

GreetingsSequence
 move.l #VblFlipFlop,$70.w              ; New VBL handler
 bsr WaitVbl

 move.l #demoscene_greetings_screen,palette_base_ptr
 move.l #demoscene_greetings_screen+32*706,picture_start_pointer

 bsr KeyboardFlushBuffer

 ; Make it appear
 move.w #706-54,demoscene_scroll_counter
.loop_appear
 bsr WaitVbl
 add.l #32,palette_base_ptr
 add.l #48,picture_start_pointer
 bsr WaitVbl
 bsr CopyBitmap96x54

 tst.b skip_sequence
 bne .end_sequence
 subq #1,demoscene_scroll_counter
 bne .loop_appear

 ; Wait 10 seconds
 move.w #50*10,demoscene_scroll_counter
.wait 
 bsr WaitVbl
 tst.b skip_sequence
 bne .end_sequence
 subq #1,demoscene_scroll_counter
 bne .wait


.end_sequence
 sf.b skip_sequence
 rts

; 96x706
demoscene_greetings_screen
 incbin "exported\demoscene_greetings.pi1"

demoscene_scroll_counter dc.w 0


 SECTION DATA

 even

; ===========================================================================
;
;					Tables, palettes, and other dc.x thingies
;
; ===========================================================================


white_palette   dcb.b 80,255	; 80 bytes with ones
black_palette   dcb.b 80*10,0  	; 80 bytes with zero (10 lines long)


 even 

 ;+$0 =init
 ;+$4 =deinit
 ;+$8 =interrupt
 ;+$C.b =zync code
music_level16
 ;incbin "exported\monty.snd"
 incbin "exported\Level_16.snd" 

 even	
 
sine_255				; 16 bits, unsigned between 00 and 127
 incbin "exported\sine_255.bin"
 incbin "exported\sine_255.bin"
 incbin "exported\sine_255.bin"
 incbin "exported\sine_255.bin"
 
 even



 even 
    
 SECTION BSS
 
bss_start

 even 

save_iera			ds.b 1	; Interrupt enable register A
save_ierb			ds.b 1	; Interrupt enable register B
save_imra			ds.b 1	; Interrupt mask register A
save_imrb			ds.b 1  ; Interrupt mask register B

save_freq    		ds.b 1
save_rez     		ds.b 1

save_screen_addr_1 	ds.b 1
save_screen_addr_2 	ds.b 1

flag_vbl	 		ds.b 1	; Set to true at the end of the main screen handling interupt
flip_flop           ds.b 1
skip_sequence ds.b 1
last_key      ds.b 1
hbl_counter   ds.b 1

 even
   
save_ssp     		ds.l 1	; Supervisor Stack Pointer
save_usp     		ds.l 1  ; User Stack Pointer

save_70      		ds.l 1	; VBL handler
save_120        ds.l 1  ; HBL handler

save_palette	 	ds.w 16


                  ds.l stack_size
my_stack      		ds.l 1
   
effect_loop_counter dc.w 0

picture_start_pointer   ds.l 1
palette_base_ptr        ds.l 1
palette_ptr             ds.l 1

palettes            ds.l (54+picture_height)*16             ; One palette for each line of the screen (+some overflow in case of bugs :p)

screen_phys_ptr     ds.l 1
screen_log_ptr      ds.l 1
screen_buffer       ds.l (256+32000*2)/4

 
bss_end       		ds.l 1 						; One final long so we can clear stuff without checking for overflows


 end

