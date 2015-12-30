

TVSNOW_WIDTH	equ 416
TVSNOW_HEIGHT	equ (273+16) 

PRNLOOP macro 
 add.l d0,d0			; shift left 1 bit
 bcc.s .\@				; branch if bit 32 not set
 eor.b d1,d0			; do galois LFSR feedback
.\@
 endm
 
 SECTION TEXT
 
 even
 
TvSnowInit 
 ifne enable_music
 bsr StopMusic
 endc

 bsr GenerateWhiteNoisePicture
                
 ; Set the volume down
 move.w #LMC_MASTERVOL+%100010,d0 ; volume -12dB
 bsr SetMixer
 
 ; Static noise
 lea big_buffer_start+tvsnow_picture,a0
 lea big_buffer_start+tvsnow_picture_end,a1
 bsr StartReplay
 move.l d0,big_buffer_start+tvsnow_counter
 
 ; Set the screen information (static fullscreen picture)
 lea big_buffer_start+tvsnow_picture,a0
 move.l a0,ptr_scr_1

 ; Picture palette
 lea black_palette,a0
 lea GreyPalette,a1
 moveq #16,d7
 bsr ComputeGradient
 
 ; Using the template data, we generate the fullscreen
 lea FullTemplateList_Fullscreen,a0
 lea big_buffer_start+tvsnow_fullscreen,a1
 bsr GenerateOverscan
 rts
 
TvSnowPlay
 subq.l #1,big_buffer_start+tvsnow_counter
 bpl.s TvSnowShake
 ; We are done with this part
 st.b flag_end_part
 rts
 
TvSnowShakeFadeOut 
 ; Set the volume down
 subq.w #2,big_buffer_start+tvsnow_master_volume
 move.w big_buffer_start+tvsnow_master_volume,d0
 add.w #LMC_MASTERVOL,d0
 bsr SetMixer
TvSnowShake
 move pos_scr_x,d0
 add #47,d0
 and #$00ff,d0
 move d0,pos_scr_x
 
 move pos_scr_y,d0
 addq #7,d0
 and #$000f,d0
 move d0,pos_scr_y
 rts
 
TvSnowTerminate 
 ; Picture palette
 lea GreyPalette,a0
 lea black_palette,a1
 moveq #16,d7
 bsr ComputeGradient
 
 move.w #%100010,big_buffer_start+tvsnow_master_volume
 move.l #TvSnowShakeFadeOut,_AdrEndOfFadeRoutine 
 bsr WaitEndOfFade

 bsr TerminateFullscreenTimer
 
 ; Cut the sample playing 
 bsr EndReplay
 
 ; Reset the volume 
 move.w	#LMC_MASTERVOL+%101000,d0	; -0db master volume
 bsr SetMixer
    
 rts
  
 
 
GenerateWhiteNoisePicture
 COLORHELP #$700
  
 ;
 ; Noise picture generation - chunky
 ;
 moveq #$AF-$100,d1		; set EOR value
 move.l Prng32,d0		; get current 
 
 lea big_buffer_start+tvsnow_chunky_buffer,a0	; 113568 bytes
 move.w #TVSNOW_WIDTH*TVSNOW_HEIGHT/8-1,d7
.loop_generate
 
 REPT 19
 PRNLOOP
 ENDR
 
 move.l d0,d3 
 and.l #$0f0f0f0f,d3
 move.l d3,(a0)+

 move.l d0,d3 
 lsr.l #4,d3
 and.l #$0f0f0f0f,d3
 move.l d3,(a0)+
  
 dbra d7,.loop_generate  
 
 move.l	d0,Prng32		; save back to seed word
 
 COLORHELP #$007

 ;
 ; 2x2 matrix blur
 ;
 lea big_buffer_start+tvsnow_chunky_buffer,a0	; 113568 bytes
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 move #TVSNOW_HEIGHT-1-1,d7
.loop_blur_y

 move.l a0,a1
 lea TVSNOW_WIDTH(a1),a2
 
 move.b (a1)+,d0
 move.b (a2)+,d1
 
 move #TVSNOW_WIDTH/4-1,d6
.loop_blur_x 

 REPT 4
 move.b (a1),d2
 move.b (a2)+,d3
 add d2,d0
 add d3,d1
 add d1,d0
 lsr #2,d0
 move.b d0,(a1)+
 move d2,d0
 move d3,d1
 ENDR
 
 dbra d6,.loop_blur_x
 
 lea TVSNOW_WIDTH(a0),a0 
 dbra d7,.loop_blur_y

 COLORHELP #$707
   
 ;
 ; Motion blur
 ;
 lea big_buffer_start+tvsnow_chunky_buffer,a0	; 113568 bytes
 moveq #0,d0
 move.b (a0),d0
 moveq #0,d1
 move.w #TVSNOW_WIDTH*TVSNOW_HEIGHT/4-1,d7 
.loop_blur
 REPT 4
 move.b (a0),d1
 add.w d1,d0
 lsr.w d0
 move.b d0,(a0)+
 ENDR
 dbra d7,.loop_blur  
 
 COLORHELP #$770

 ; Chunky to planar conversion
 ; a0=source buffer (chunky)
 ; a1=destination buffer (plannar)
 ; d0=size of the buffer in 16 pixels blocs
 lea big_buffer_start+tvsnow_chunky_buffer,a0
 lea big_buffer_start+tvsnow_picture,a1
 move.l #TVSNOW_WIDTH*TVSNOW_HEIGHT/16,d0
 bsr.s ZoomerChunkyToPlannar
 
 COLORHELP #$000
 
 rts

; a0=source buffer (chunky)
; a1=destination buffer (plannar)
; d0=size of the buffer in 16 pixels blocs
ZoomerChunkyToPlannar
 move.l d0,d7
.loop
 moveq #0,d0
 move d0,d1
 move d0,d2
 move d0,d3

 ; Shift until we get 16 bytes
 REPT 16
 moveq #0,d4
 move.b (a0)+,d4
 lsr.w d4
 roxl.w d3
 lsr.w d4
 roxl.w d2
 lsr.w d4
 roxl.w d1
 lsr.w d4
 roxl.w d0
 ENDR
 ; Write the four bitplans
 move.w d3,(a1)+
 move.w d2,(a1)+
 move.w d1,(a1)+
 move.w d0,(a1)+
 
 subq.l #1,d7
 bne .loop
 rts
 

   
 SECTION DATA
 
 even
  
  
 SECTION BSS
  
 even
 
;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset
 
tvsnow_counter			rs.l 1 
tvsnow_fullscreen		rs.b Size_Fullscreen

tvsnow_picture			rs.b (TVSNOW_WIDTH/2)*TVSNOW_HEIGHT		; Plannar buffer
tvsnow_picture_end		rs.b 0

tvsnow_chunky_buffer	rs.b TVSNOW_WIDTH*TVSNOW_HEIGHT			; Chunky buffer
tvsnow_master_volume	rs.w 1

 update_buffer_size
 


 