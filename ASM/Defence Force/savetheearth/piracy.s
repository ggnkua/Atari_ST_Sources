
PIRACY_LETTER_A equ 24*0
PIRACY_LETTER_B equ 24*1
PIRACY_LETTER_C equ 24*2
PIRACY_LETTER_D equ 24*3
PIRACY_LETTER_E equ 24*4
PIRACY_LETTER_G equ 24*5
PIRACY_LETTER_H equ 24*6
PIRACY_LETTER_I equ 24*7
PIRACY_LETTER_L equ 24*8
PIRACY_LETTER_M equ 24*0+72*216
PIRACY_LETTER_O equ 24*1+72*216
PIRACY_LETTER_P equ 24*2+72*216
PIRACY_LETTER_R equ 24*3+72*216
PIRACY_LETTER_T equ 24*4+72*216
PIRACY_LETTER_U equ 24*5+72*216
PIRACY_LETTER_V equ 24*6+72*216
PIRACY_LETTER_W equ 24*7+72*216
PIRACY_LETTER_Y equ 24*8+72*216

 
 SECTION TEXT
 
 even
    
PiracyInit
 move.w #20,big_buffer_start+piracy_sync_speed
 move.w #0,big_buffer_start+piracy_sync_position
 move.l #DummyRoutine,_AdrPiracyPlayRoutine
 
 lea dmaplay_sequence,a0
 lea dmaplay_addresstable,a1
 bsr DmaSequencePlayerInit
  
 ; Using the template data, we generate the fullscreen
 lea PanoramicTemplate_DisplayList,a0
 lea big_buffer_start+piracy_fullscreen,a1
 bsr GenerateOverscan
 rts
 
PiracyPlay
 COLORHELP #$070
 bsr SequencerPlay
 COLORHELP #$707
_AdrPiracyPlayRoutine=*+2
 jsr DummyRoutine
 COLORHELP #$000
 
 DEBUG_START
 DEBUG_PRINT_VALUE dmaplay_sequence_index
 DEBUG_PRINT_STRING 32
 DEBUG_FINISH
 rts
  
 
PiracyTerminate
 ;bsr FadeAudioOut
 ;move.l #DummyRoutine,_AdrMusicVblRoutine
 bsr TerminateFullscreenTimer
 
 ;bsr WaitVbl
 
 ; Reset the volume 
 move.w	#LMC_MASTERVOL+%101000,d0	; -0db master volume
 bsr SetMixer
 rts
    
 
 

PiracyEffectDoNothing
 rts
 
  
PiracyEffectShakeIt
 bsr.s .shake
 
; a0=screen adress (*256 + pixelshift in low byte)
; a1=palette adress
; a2=display list pointer
; d0=screen increment (*256)
; d1=palette increment
;
 lea big_buffer_start+piracy_depacked_font,a1			; Palette
 move.l big_buffer_start+piracy_picture_1,d0
   
 move pos_scr_y,d1
 mulu #208,d1
 add.l d1,d0		; Vertical offset
 lsl.l #8,d0
 move.l d0,a0

 lea TableShifterShift,a2
 move.w pos_scr_x,d1
 add.w d1,d1
 add.w (a2,d1),a0
 
 lea DisplayList,a2										; Target display list
 move.l #208*256,d0
 moveq #0,d1
 bsr DisplayListInit200
 rts
 
.shake 
 ; Move the snow using random 
 ; position on the screen.
 not.b big_buffer_start+piracy_flipflop
 beq.s .y
 move pos_scr_x,d0
 addq #2,d0
 and #$0007,d0
 move d0,pos_scr_x
 rts
 
.y 
 move pos_scr_y,d0
 addq #1,d0
 and #$0003,d0
 move d0,pos_scr_y
 rts


  
PiracyEffectLostSync
 move big_buffer_start+piracy_sync_position,d2
 lsl.l #3,d2
 
 move.l big_buffer_start+piracy_picture_1,d0
 move.l d0,a1
 add.l #32*200,d0
 lsl.l #8,d0
 move.l d0,a0

 move.l #208*256,d0
 moveq #32,d1
    
 movem.l a0/a1,-(sp)
 
 lea DisplayList_Top,a2
 add d2,a2
 bsr DisplayListInit200

 movem.l (sp)+,a0/a1
  
 lea DisplayList,a2
 add d2,a2
 bsr DisplayListInit200
  
 ;
 lea sine_255,a0
 move big_buffer_start+piracy_sync_angle,d2
 addq #1,big_buffer_start+piracy_sync_angle
 and #255,d2
 add d2,d2
 move 0(a0,d2),d1	; 16 bits, between 00 and 127
 lsr #1,d1			; 0,64
 sub #32,d1			; -32,+31
 move.w d1,big_buffer_start+piracy_sync_speed
 
 move.w big_buffer_start+piracy_sync_position,d0
 sub.w big_buffer_start+piracy_sync_speed,d0
.loop 
 bmi.s .underflow
 cmp.w #200,d0
 bge.s .overflow
 bra.s .end
 
.underflow
 add.w #200,d0
 bra.s .loop
 
.overflow
 sub.w #200,d0
 bra.s .loop
 

.end
 move.w d0,big_buffer_start+piracy_sync_position
 rts
 

  
; 5 pictures d0/d1/d2/d3/d4
; 5 palette  a0/a1/a2/a3/a4
; 1 target   a5
; 2 offsets  d5/d6
; 1 counter  d7
;
PiracyEffectSineBlendInit
 lea big_buffer_start+piracy_palette_table,a0
 lea big_buffer_start+piracy_picture_table,a1
 
 move.l #big_buffer_start+piracy_depacked_girl,d0
 move.l d0,(a0)+
 add.l #32*200,d0
 lsl.l #8,d0
 move.l d0,(a1)+
 
 move.l #big_buffer_start+piracy_depacked_bag,d0
 move.l d0,(a0)+
 add.l #32*200,d0
 lsl.l #8,d0
 move.l d0,(a1)+
 
 move.l #big_buffer_start+piracy_depacked_car,d0
 move.l d0,(a0)+
 add.l #32*200,d0
 lsl.l #8,d0
 move.l d0,(a1)+
 
 move.l #big_buffer_start+piracy_depacked_tv,d0
 move.l d0,(a0)+
 add.l #32*200,d0
 lsl.l #8,d0
 move.l d0,(a1)+
 
 move.l #big_buffer_start+piracy_depacked_film,d0
 move.l d0,(a0)+
 add.l #32*200,d0
 lsl.l #8,d0
 move.l d0,(a1)+
 
 ; Precalc sinus tables
 lea sine_255,a0			; 16 bits, unsigned between 00 and 127
 lea big_buffer_start+piracy_table_sine_16,a1
 lea big_buffer_start+piracy_table_sine_64,a2
 move #256-1,d7
.loop 
 move.w (a0)+,d0
 lsr #1,d0
 move.b d0,256(a2)
 move.b d0,(a2)+
 lsr #3,d0
 move.b d0,256(a1)
 move.b d0,(a1)+
 dbra d7,.loop
 

 rts

  
PiracyEffectSineBlend
 lea big_buffer_start+piracy_table_sine_64,a2
 move big_buffer_start+piracy_sync_angle,d2
 addq #1,big_buffer_start+piracy_sync_angle
 and #255,d2
 add d2,a2

 lea big_buffer_start+piracy_table_sine_64,a3
 move big_buffer_start+piracy_sync_angle2,d2
 subq #2,big_buffer_start+piracy_sync_angle2
 and #255,d2
 add d2,a3

 lea big_buffer_start+piracy_table_sine_16,a4
 move big_buffer_start+piracy_sync_angle3,d2
 subq #2,big_buffer_start+piracy_sync_angle3
 and #255,d2
 add d2,a4
  
 lea big_buffer_start+piracy_picture_table,a0	; The pictures
 lea big_buffer_start+piracy_palette_table,a1	; The palettes
 moveq.l #0,d0									; The screen offset
 moveq.l #0,d1									; The palette offset
 move.l #208*256,d2								; The screen increment
 move.l #32,d3									; The palette increment

 
 lea PictureGradientTable,a5
 
 lea DisplayList,a6			; Target display list
 moveq #0,d4
var set -127
 REPT 200
 move.b (a2)+,d4	; 0,64
 add.b (a3)+,d4
 move.b (a5,d4),d4	; Picture offset (0,4,8,12,16)
   
 move.l (a0,d4),d5	; Picture
 move.l (a1,d4),d6	; Palette
 
 move.b (a4)+,d5	; 0,15
  
 add.l d0,d5
 add.l d1,d6

 move.l d5,(a6)+
 move.l d6,(a6)+
  
 add.l d2,d0
 add.l d3,d1
var set var+1 
 ENDR

 rts

  
 
PiracyDrawText_CopyACar
 lea PiracyMessage_CopyACar,a0
 bra.s PiracyDrawText_Common

PiracyDrawText_MoveATv
 lea PiracyMessage_MoveATv,a0
 bra.s PiracyDrawText_Common
 
PiracyDrawText_HideAMovie 
 lea PiracyMessage_HideAMovie,a0
 bra.s PiracyDrawText_Common
  
PiracyDrawText_TouchABag
 lea PiracyMessage_TouchABag,a0
 bra.s PiracyDrawText_Common

; a0=pointer on second text 
PiracyDrawText_Common
 movem.l a0/a1,-(sp)
 lea big_buffer_start+piracy_screen_buffer,a0					
 lea big_buffer_start+piracy_screen_buffer_end,a1 
 bsr MemoryClear					
 movem.l (sp)+,a0/a1

 bsr PiracyDrawTextString
 lea PiracyMessage_WouldYou,a0
 bsr PiracyDrawTextString
 
 bsr SubtitleClearBuffer

 move.l #big_buffer_start+piracy_screen_buffer,big_buffer_start+piracy_picture_1
 move.l #PiracyEffectShakeIt,_AdrPartVblRoutine
 
 move.w #0,pos_scr_x
 move.w #0,pos_scr_y
 rts
 
  
PiracyDrawTextString 
.loop
 move.w (a0)+,d2	; Font offset
 bmi .done
 
 move.w (a0)+,d0	; x
 move.w (a0)+,d1	; y
 
 move.l a0,-(sp)

 lea big_buffer_start+piracy_depacked_font+32,a0
 add.w d2,a0	
  
 bsr ComputeScreenOffset
 move.l character_buffer_base,a1	; Destination
 
 lea big_buffer_start+piracy_screen_buffer,a1
 add.l d2,a1						; +actual offset
 
 lea 0,a2			; No mask
 move.w #3,d0
 move.w #72,d1
 move #216-8-8,d2
 move #208-8-8,d3
 moveq #0,d4
 
; a0=source
; a1=destination
; a2=mask
; d0=width in words
; d1=height 
; d2=skip line source
; d3=skip line dest
; d4=pixel offset
 
 bsr WaitVbl
 bsr BlitterDrawSprite
 
 move.l (sp)+,a0
 bra .loop
.done 
 rts

 SECTION DATA
 
 even

; Unpacked: 41632 (each picture) / 48000 with multi-palette
; Packed:   11-39 kb 
 FILE "pir_girl.pik",picture_piracy_girl

 FILE "pir_tv.pik",picture_piracy_tv
 FILE "pir_film.pik",picture_piracy_film			
 FILE "pir_car.pik",picture_piracy_car			
 FILE "pir_bag.pik",picture_piracy_bag			
                     
 FILE "copydemo.pik",picture_copy_demo
 
 
; Unpacked: 31136
; Packed:   10278
 FILE "font_pir.pik",font_piracy

   
piracy_force_unpack				equ 0
piracy_force_test_sine_blend	equ 0
 

current_wait_delay set 0

WAITSEQUENCER macro
current_wait_delay set current_wait_delay+\1
 SEQUENCE_WAIT_WORD dmaplay_sequence_index,current_wait_delay
 endm
 
PiracySequencer
 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPICTURE_DISPLAYLIST 0,big_buffer_start+piracy_depacked_copy_demo	; Not yet depacked, so all black
 SEQUENCE_CALLBACK PiracyEffectSineBlendInit
  
 ifne piracy_force_unpack
	; Debugging
	SEQUENCE_DEPACK_LZSS picture_piracy_girl,big_buffer_start+piracy_depacked_girl,48000
	SEQUENCE_DEPACK_LZSS font_piracy,big_buffer_start+piracy_depacked_font,31136
	SEQUENCE_DEPACK_LZSS picture_piracy_car,big_buffer_start+piracy_depacked_car,48000
	SEQUENCE_DEPACK_LZSS picture_piracy_tv,big_buffer_start+piracy_depacked_tv,48000
	SEQUENCE_DEPACK_LZSS picture_piracy_film,big_buffer_start+piracy_depacked_film,48000
	SEQUENCE_DEPACK_LZSS picture_piracy_bag,big_buffer_start+piracy_depacked_bag,48000
 endc
 
 ifne piracy_force_test_sine_blend
	; Debugging
	SEQUENCE_CALLBACK PiracyEffectSineBlendInit
 	SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 	SEQUENCE_SETPTR _AdrPiracyPlayRoutine,PiracyEffectSineBlend
	SEQUENCE_END
 endc
 
 
 ; Girl on her computer
 ; Depack
 SEQUENCE_DEPACK_LZSS picture_piracy_girl,big_buffer_start+piracy_depacked_girl,48000
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_girl
 
 ; Start music and real sequencing
 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPTR _AdrMusicVblRoutine,DmaSequencePlayerVbl
 SEQUENCE_SUBTITLE <"Does she count as a",13,"   RANDOM GIRL WITH HARDWARE?"> 
 SEQUENCE_DEPACK_LZSS font_piracy,big_buffer_start+piracy_depacked_font,31136
 WAITSEQUENCER 8
  
 ;
 ; Would you copy a car 
 SEQUENCE_CALLBACK PiracyDrawText_CopyACar
 SEQUENCE_DEPACK_LZSS picture_piracy_car,big_buffer_start+piracy_depacked_car,48000
 WAITSEQUENCER 4
  
 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_car
 SEQUENCE_SUBTITLE <"Yes, but only if it is energy efficient.",13,"Not like this old one there.">
 WAITSEQUENCER 8
 
 ;
 ; Would you move a tv
 SEQUENCE_CALLBACK PiracyDrawText_MoveATv
 SEQUENCE_DEPACK_LZSS picture_piracy_tv,big_buffer_start+piracy_depacked_tv,48000
 WAITSEQUENCER 4
   
 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_tv
 SEQUENCE_SUBTITLE <"If it still working fine I'm not going",13,"to throw it away. Would you?">
 WAITSEQUENCER 8

 ;
 ; Would you hide a movie 
 SEQUENCE_CALLBACK PiracyDrawText_HideAMovie
 SEQUENCE_DEPACK_LZSS picture_piracy_film,big_buffer_start+piracy_depacked_film,48000
 WAITSEQUENCER 4

 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_film
 SEQUENCE_SUBTITLE <"Definitely not that one! Everybody",13,"should watch it, it's great!">
 WAITSEQUENCER 8
   
 ;  
 ; Would you touch a bag
 SEQUENCE_CALLBACK PiracyDrawText_TouchABag
 SEQUENCE_DEPACK_LZSS picture_piracy_bag,big_buffer_start+piracy_depacked_bag,48000
 WAITSEQUENCER 4 
  
 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_bag
 SEQUENCE_SUBTITLE <"Possibly, but only if it's made of ",13,"easily recyclable materials!">
 WAITSEQUENCER 8
    
 ; Now set all the picture fast in some kind of random order
 SEQUENCE_SUBTITLE <"">

 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPTR _AdrPiracyPlayRoutine,PiracyEffectDoNothing
 REPT 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_car
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_tv
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_film
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_bag
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_girl
 WAITSEQUENCER 1
 ENDR
  
 SEQUENCE_SETPTR big_buffer_start+piracy_picture_1,big_buffer_start+piracy_depacked_girl
 SEQUENCE_SETPTR _AdrPiracyPlayRoutine,PiracyEffectLostSync
 WAITSEQUENCER 6

 SEQUENCE_SETPTR _AdrPiracyPlayRoutine,PiracyEffectSineBlend
 WAITSEQUENCER 14

 
 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPTR _AdrPiracyPlayRoutine,PiracyEffectDoNothing
 REPT 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_car
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_tv
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_film
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_bag
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_girl
 WAITSEQUENCER 1
 ENDR

 SEQUENCE_SETPTR _AdrPiracyPlayRoutine,PiracyEffectSineBlend
 WAITSEQUENCER 10

 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPTR _AdrPiracyPlayRoutine,PiracyEffectDoNothing
 REPT 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_car
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_tv
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_film
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_bag
 WAITSEQUENCER 1
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_girl
 WAITSEQUENCER 1
 ENDR
   

 ; Finally the "copy this demo" message
 SEQUENCE_SETPTR _AdrPiracyPlayRoutine,PiracyEffectDoNothing
 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing
 
 SEQUENCE_DEPACK_LZSS picture_copy_demo,big_buffer_start+piracy_depacked_copy_demo,48000
 SEQUENCE_SETPICTURE_DISPLAYLIST 1,big_buffer_start+piracy_depacked_copy_demo
 SEQUENCE_SETPTR _AdrPartVblRoutine,PiracyEffectDoNothing

 WAITSEQUENCER 16
 
 ; Fades the music out
 SEQUENCE_CALLBACK FadeAudioOut
 ; Stop the player (but the dma stuff can still play for a fraction of a second)
 SEQUENCE_SETPTR _AdrMusicVblRoutine,DummyRoutine
 SEQUENCE_TEMPORIZE 50*2
  
 ; And leave
 SEQUENCE_GO_NEXT_PART	
 
 SEQUENCE_END

 
 even

 
PiracyMessage_WouldYou
 dc.w PIRACY_LETTER_W,66,34
 dc.w PIRACY_LETTER_O,110,33
 dc.w PIRACY_LETTER_U,141,31
 dc.w PIRACY_LETTER_L,172,40
 dc.w PIRACY_LETTER_D,189,26
 
 dc.w PIRACY_LETTER_Y,243,37
 dc.w PIRACY_LETTER_O,278,42
 dc.w PIRACY_LETTER_U,312,38
 dc.w -1,0,0

PiracyMessage_CopyACar
 dc.w PIRACY_LETTER_C,56,107
 dc.w PIRACY_LETTER_O,83,106
 dc.w PIRACY_LETTER_P,117,116
 dc.w PIRACY_LETTER_Y,151,111
 
 dc.w PIRACY_LETTER_A,208,107
 
 dc.w PIRACY_LETTER_C,276,113
 dc.w PIRACY_LETTER_A,306,118
 dc.w PIRACY_LETTER_R,343,108
 dc.w -1,0,0
    
PiracyMessage_MoveATv 
 dc.w PIRACY_LETTER_M,61,102
 dc.w PIRACY_LETTER_O,103,104
 dc.w PIRACY_LETTER_V,137,104
 dc.w PIRACY_LETTER_E,171,106
 
 dc.w PIRACY_LETTER_A,238,107
 
 dc.w PIRACY_LETTER_T,301,110
 dc.w PIRACY_LETTER_V,324,120
 dc.w -1,0,0

PiracyMessage_HideAMovie
 dc.w PIRACY_LETTER_H,33,106
 dc.w PIRACY_LETTER_I,67,99
 dc.w PIRACY_LETTER_D,80,110
 dc.w PIRACY_LETTER_E,121,117
 
 dc.w PIRACY_LETTER_A,182,104
 
 dc.w PIRACY_LETTER_M,237,111
 dc.w PIRACY_LETTER_O,274,120
 dc.w PIRACY_LETTER_V,306,120
 dc.w PIRACY_LETTER_I,337,114
 dc.w PIRACY_LETTER_E,353,120
 dc.w -1,0,0
  
PiracyMessage_TouchABag
 dc.w PIRACY_LETTER_T,30,107
 dc.w PIRACY_LETTER_O,61,115
 dc.w PIRACY_LETTER_U,90,112
 dc.w PIRACY_LETTER_C,122,116
 dc.w PIRACY_LETTER_H,154,112
 
 dc.w PIRACY_LETTER_A,208,109
 
 dc.w PIRACY_LETTER_B,282,114
 dc.w PIRACY_LETTER_A,318,115
 dc.w PIRACY_LETTER_G,352,114
 dc.w -1,0,0
 
 
PictureGradientTable
 REPT 13
 dc.b 0*4
 ENDR

 dc.b 1*4
 dc.b 0*4
 dc.b 0*4
 dc.b 0*4
 dc.b 1*4
 dc.b 1*4
 dc.b 0*4
 dc.b 0*4
 dc.b 1*4
 dc.b 1*4
 dc.b 1*4
 dc.b 0*4 ; 12
  
 REPT 13
 dc.b 1*4
 ENDR

 dc.b 2*4
 dc.b 1*4
 dc.b 1*4
 dc.b 1*4
 dc.b 2*4
 dc.b 2*4
 dc.b 1*4
 dc.b 1*4
 dc.b 2*4
 dc.b 2*4
 dc.b 2*4
 dc.b 1*4
  
 REPT 13
 dc.b 2*4
 ENDR

 dc.b 3*4
 dc.b 2*4
 dc.b 2*4
 dc.b 2*4
 dc.b 3*4
 dc.b 3*4
 dc.b 2*4
 dc.b 2*4
 dc.b 3*4
 dc.b 3*4
 dc.b 3*4
 dc.b 2*4
  
 REPT 13
 dc.b 3*4
 ENDR

 dc.b 4*4
 dc.b 3*4
 dc.b 3*4
 dc.b 3*4
 dc.b 4*4
 dc.b 4*4
 dc.b 3*4
 dc.b 3*4
 dc.b 4*4
 dc.b 4*4
 dc.b 4*4
 dc.b 3*4
  
 REPT 13
 dc.b 4*4
 ENDR

 dc.b 0*4
 dc.b 4*4
 dc.b 4*4
 dc.b 4*4
 dc.b 0*4
 dc.b 0*4
 dc.b 4*4
 dc.b 4*4
 dc.b 0*4
 dc.b 0*4
 dc.b 0*4
 dc.b 4*4
 
 ;
 REPT 50
 dc.b 0*4
 dc.b 0*4
 ENDR
 
 
var set 0
 REPT 128
 dc.b ((var*5)/128)*4
var set var+1 
 ENDR
 
 


dmaplay_sequence
	rept 1
	dc.b 00,01,02,03
	dc.b 00,01,04,05
	endr

	rept 1
	dc.b 17,01,02,03
	dc.b 00,01,04,05
	endr

	rept 1
	dc.b 00,01,02,03
	dc.b 00,01,04,05
	endr
	
	rept 0
	dc.b 17,01,02,03
	dc.b 00,01,04,21-1
	dc.b 21-1,01,02,03
	dc.b 00,01,18,19
	endr

	rept 1
	dc.b 17,01,19-1,20-1
	dc.b 21-1,01,22-1,23-1
	dc.b 17,01,19-1,20-1
	dc.b 15,15,16,16
	endr

	rept 1
	dc.b 00,01,02,03
	dc.b 00,01,04,05
	endr

	rept 2
	dc.b 08,09,10,11
	dc.b 12,09,13,14
	dc.b 08,09,10,11
	dc.b 06,06,07,07
	endr

	rept 4
	dc.b 17,01,19-1,20-1
	dc.b 21-1,01,22-1,23-1
	dc.b 17,01,19-1,20-1
	dc.b 15,15,16,16

	dc.b 08,09,10,11
	dc.b 12,09,13,14
	dc.b 08,09,10,11
	dc.b 06,06,07,07
	endr

	dc.b -1

	even


dmaplay_addresstable
var set 0
	REPT 24
	dc.l dmaplay_sample+var
var set var+11000
	ENDR

	even
dmaplay_sample	
	incbin "xia.raw"		; copy /b da1.r+da2.r+da3.r+da4.r+db3.r+db4.r+ea1.r+ea3.r+fa1.r+fa2.r+fa3.r+fa4.r+fb1.r+fb3.r+fb4.r+nea1.r+nea3.r+nfa1.r+nfa3.r+nfa4.r+nfb1.r+nfb3.r+nfb4.r xia.raw	
  
	
 SECTION BSS
 
 even
 
;
; The content of this buffer is going to be stored in
; the big common table.
; 41632
 rsreset
piracy_fullscreen			rs.b Size_PanoramicRoutine_DisplayList
piracy_depacked_girl		rs.b 48000
piracy_depacked_tv			rs.b 48000
piracy_depacked_film		rs.b 48000
piracy_depacked_car			rs.b 48000
piracy_depacked_bag			rs.b 48000
piracy_depacked_copy_demo 	rs.b 48000
piracy_screen_buffer		rs.b 208*203
piracy_screen_buffer_end	rs.b 0

piracy_picture_1			rs.l 1

piracy_picture_table		rs.l 5
piracy_palette_table		rs.l 5

piracy_depacked_font		rs.b 31136

piracy_table_sine_16		rs.b 256*2				; Doubled sine table with values in the 0-15 range
piracy_table_sine_64		rs.b 256*2				; Doubled sine table with values in the 0-63 range

piracy_sync_position		rs.w 1
piracy_sync_speed			rs.w 1
piracy_sync_angle			rs.w 1
piracy_sync_angle2			rs.w 1
piracy_sync_angle3			rs.w 1
piracy_sync_angle4			rs.w 1
piracy_flipflop 			rs.b 1

 update_buffer_size
 


