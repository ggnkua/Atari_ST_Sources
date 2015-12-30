
ZOOMER_BUFFER_WIDTH	equ (416+16+16)
ZOOMER_STEPS		equ 32
ZOOMER_WIDTH		equ 374
ZOOMER_HEIGHT		equ 85


 ; Background rectangle: 42,87 - 327,173  <- Theorical values
 
XCENTER equ 207
YCENTER equ 99
XSCALE equ 326	;310	;200 
YSCALE equ 213	;220	;300 
ZSCALE equ 512
; 336x120 -> 168x60
; Z0->639

;SPRITES_HEIGHT	equ 44		; Old ones
SPRITES_HEIGHT	equ 39		; New ones by crem

SPRITES_CURVE_SPEED		equ 4
SPRITES_CURVE_LENGHT	equ	128



 SECTION TEXT
 
 even
 
CinemaScopeInit
 ; Depack the logo
 lea PackInfoCinemascope,a0
 bsr DepackBlock

 lea PackInfoDefenceForceSprites,a0
 bsr DepackBlock
   
 move.l #big_buffer_start+cinemascope_screenbuffer,ptr_scr_1	
    
 move.w #0,ZoomerAngle 
   
 bsr ZoomerGenerate
  
 ; These two functions use the blitter, would corrupt the fullscreen
 bsr LogoPrepareScreens
 bsr DrawPlanScanLines
 
 bsr CreateDefaultZoomerDisplayList
 
 ; Generate the mask from the sprite data - if not done yet
 bsr DefenceForceGenerateMasks
 
 clr Scaler_Factor
  
 ;bsr DefenceForceLogoSetup 
 
 move.l #big_buffer_start+defenceforce_screen,ptr_scr_1
  
 ifne enable_music
 lea music,a0
 bsr StartMusicIfNotStarted
 endc

 ; Picture palette
 lea black_palette,a0
 lea big_buffer_start+cinemascope_logo_depacked,a1
 moveq #16,d7
 bsr ComputeGradient
  
 ; Using the template data, we generate the fullscreen
 lea PanoramicTemplate_DisplayList,a0
 lea big_buffer_start+cinemascope_fullscreen,a1
 bsr GenerateOverscan
 rts  

CinemaScopePlay
 COLORHELP #$777
_AdrCinemascopeVblRoutine=*+2
 jsr DummyRoutine
 COLORHELP #$000

 bsr SequencerPlay 
 rts
 
DefenceForceLogoSetup
 move #64,blue_plane_angle
 move #ZSCALE,blue_plane_zoom
 
 ; Compute the gradient color for the rotating plane
 move #$046,big_buffer_start+RotatingPlanPaletteEnd		; Clear blue
 move #$f70,big_buffer_start+RotatingPlanPaletteEnd+2	; Yellow
 lea big_buffer_start+RotatingPlanPaletteStart,a0
 lea big_buffer_start+RotatingPlanPaletteEnd,a1
 lea big_buffer_start+RotatingPlanPaletteFade,a2
 move #2,d7
 bsr ComputeFullGradient 
      
 ; Picture palette for the logo
 lea big_buffer_start+cinemascope_logo_depacked,a0
 lea big_buffer_start+cinemascope_sprites_depacked,a1
 move #$fff,(a1)					; Replace the purple by white
 moveq #16,d7
 bsr ComputeGradient
 rts 
 

 
CinemaScopeTerminate
 ; Fade to white 
 lea big_buffer_start+cinemascope_sprites_depacked,a0
 lea white_palette,a1
 moveq #16,d7
 bsr ComputeGradient
 
 move.l #DummyRoutine,_AdrCinemascopeVblRoutine
 move.l #LogoTwistAndShout,_AdrEndOfFadeRoutine 
 
 bsr WaitEndOfFade
 
 ; Fade to black
 lea white_palette,a0
 lea black_palette,a1
 moveq #16,d7
 bsr ComputeGradient
 
 move.l #DummyRoutine,_AdrEndOfFadeRoutine 
 bsr WaitEndOfFade
  
 bsr TerminateFullscreenTimer
 rts  


 
CinemaScopeAnimateSquish
 ; Reset screen positions
 bsr CreateDefaultZoomerDisplayList
 
 lea sine_255,a3
 move ZoomerAngle,d1
 and #255,d1
 add d1,d1
 move 0(a3,d1),d1	; 16 bits, between 00 and 127
 move d1,d0
 
 lsr #2,d0
 ; Get the correct rescale table
 and #ZOOMER_STEPS-1,d0
 add d0,d0
 add d0,d0

 lea big_buffer_start+cinemascope_scanlines,a3
 add d0,a3

 lea DisplayList+8*58,a1
     
 lea palette_vbl_fade,a2 
 moveq #ZOOMER_HEIGHT-1,d7
.loop
 move.l (a3),(a1)+
 move.l a2,(a1)+
 lea ZOOMER_STEPS*4(a3),a3
 dbra d7,.loop 
 
 move ZoomerAngle,d1
 addq #8,d1
 and #255,d1
 move d1,ZoomerAngle
 cmp #$50,d1
 bne.s .skip
 move.l #CinemaScopeAnimateZoom,_AdrCinemascopeVblRoutine
.skip 
 rts
  
 
CinemaScopeAnimateZoom
 ; Reset screen positions
 bsr CreateDefaultZoomerDisplayList
 
 lea DisplayList,a1
  
 lea sine_255,a3
 move ZoomerAngle,d1
 and #255,d1
 add d1,d1
 move 0(a3,d1),d1	; 16 bits, between 00 and 127
 move d1,d0
 
 lsr #2,d0
 ; Get the correct rescale table
 and #ZOOMER_STEPS-1,d0
 add d0,d0
 add d0,d0
 lea Scaler_Tables,a0  
 move.l (a0,d0),a0
  
 move.w 4+2*17(a0),d4		; Width in 16 pixels blocks
 move.w 4+2*17+2(a0),d5		; Width in pixels
 move.w 4+2*17+2+2(a0),d7	; Height
 move.l (a0),a0			    ; Start adress
 
 	lsl #4,d4
 	move d4,d5
 
 ; 416/16=26 blocks
 ; 26/2=13 blocks
 ; 13*8=104 bytes
 
 lea -104(a0),a0
 move d5,d0
 lsr #5,d0	; /2 /16
 lsl #3,d0
 add d0,a0
 
 move d7,d6
 lsr d6
 move #100,d0
 sub d6,d0
 lsl #3,d0
 add d0,a1
 
 lsr d5		; Width / 2
 and #15,d5
 move d5,d0
  
 move.l a0,d1
 lsl.l #8,d1
 add.b d0,d1
 move.l d1,d0
 
 lea palette_vbl_fade,a2 
 subq #1,d7
.loop
 move.l d0,(a1)+
 move.l a2,(a1)+
 add.l #208*256,d0
 dbra d7,.loop 
 
 move ZoomerAngle,d1
 addq #4,d1
 and #255,d1
 move d1,ZoomerAngle
 cmp #$50,d1
 bne.s .skip
 move.l #CinemaScopeAnimateSquish,_AdrCinemascopeVblRoutine
.skip 
 rts 
 
 
CreateDefaultZoomerDisplayList
 move.l #big_buffer_start+cinemascope_screenbuffer,d0
 lsl.l #8,d0
 move.l d0,a0
 lea palette_vbl_fade,a1
 bsr DisplayListInitStatic
 rts 
 
 
ZoomerGenerate
 ; Convert to chunky
 move.l #big_buffer_start+cinemascope_logo_depacked+32,Scaler_PtrSrc
 move.l #big_buffer_start+zoomer_buffer_chunky,Scaler_PtrDst
 move.w #26-1,Scaler_Width
 move.w #100-1,Scaler_Height
 move.w #208,Scaler_StrideSrc
 move.w #ZOOMER_BUFFER_WIDTH,Scaler_StrideDst
 bsr ZoomerPlannarToChunky
 
 ; Display the zoomed pictures
 move.l ptr_scr_1,Scaler_PtrDst 
 add.l #8+208,Scaler_PtrDst

 ; Display again using a zoom
 clr Scaler_Factor
 moveq #ZOOMER_STEPS-1,d7
.loop_generate_zoom 
 move.l #big_buffer_start+zoomer_buffer_chunky,Scaler_PtrSrc
 move.w #26,Scaler_Width
 move.w #100,Scaler_Height
 move.w #ZOOMER_BUFFER_WIDTH,Scaler_StrideSrc
 move.w #208,Scaler_StrideDst
 bsr ZoomerRescaledChunkyToPlannar
 
 addq #1,Scaler_Factor
 dbra d7,.loop_generate_zoom

 bsr GenerateScanlinePointers
 rts
 
 
GenerateScanlinePointers
 lea big_buffer_start+cinemascope_scanlines,a2
 move.w #0,Scaler_Factor
.loop_size 
 move.l a2,a3
 addq #4,a2
 
 ; Now we have to update the buffer with the right scanlines
 move Scaler_Factor,d0
 add d0,d0
 add d0,d0
 lea Scaler_Tables,a0  
 move.l (a0,d0),a0
  
 move.w 4+2*17(a0),d4		; Width in 16 pixels blocks
 move.w 4+2*17+2(a0),d5		; Width in pixels
 move.w 4+2*17+2+2(a0),d7	; Height
 move.l (a0),a0			    ; Start adress
 
 	lsl #4,d4
 	move d4,d5
 
 ; 416/16=26 blocks
 ; 26/2=13 blocks
 ; 13*8=104 bytes
 
 lea -104(a0),a0
 move d5,d0
 lsr #5,d0	; /2 /16
 lsl #3,d0
 add d0,a0
 
 move d7,d6
 lsr d6
 move #100,d0
 sub d6,d0
 lsl #3,d0	;*8
 add d0,a1
 
 lsr d5		; Width / 2
 and #15,d5
 move d5,d0
  
 move.l a0,d1
 lsl.l #8,d1
 add.b d0,d1
 move.l d1,d0
 
 ; d0=first line
 ; d7=number of lines
 moveq #0,d6
.loop_insert_lines
 move.l d6,d1
 mulu d7,d1
 divu #ZOOMER_HEIGHT,d1
 mulu #208*256,d1
 add.l d0,d1
 move.l d1,(a3)
 lea ZOOMER_STEPS*4(a3),a3
 addq #1,d6
 cmp #ZOOMER_HEIGHT,d6
 bne .loop_insert_lines
 
 addq #1,Scaler_Factor
 cmp #ZOOMER_STEPS,Scaler_Factor
 bne .loop_size 
 rts
 
 
 
; Scaler_PtrSrc=source buffer (chunky)
; Scaler_PtrDst=destination buffer (plannar)
; Scaler_Width
; Scaler_Height
ZoomerRescaledChunkyToPlannar
 movem.l d0-a6,-(sp)
  
 ; Get the correct rescale table
 move Scaler_Factor,d0
 and #ZOOMER_STEPS-1,d0
 add d0,d0
 add d0,d0
 lea Scaler_Tables,a0
 
 add d0,a0
 move.l (a0),a0
  
 ; Set the start adress
 move.l Scaler_PtrDst,(a0)+
 
 ; Then patch the code
var set 0 
 REPT 16
 move.w (a0)+,.patch_start+2+var*(.patch_end-.patch_start)/16
var set var+1 
 ENDR
 move.w (a0)+,.patch_end+2
 move.w (a0)+,Scaler_Width		; Nb blocs
 addq #2,a0						; Skip width in pixels
 move.w (a0)+,Scaler_Height		; Nb scanlines
 move.w (a0)+,Scaler_DestOffset	; Offset to add to the dest scanline start to center the picture
 move.l a0,a2					; Point on the vertical rescale table...
 moveq #0,d6					; Index in the table...
  
 move Scaler_Height,Scaler_CurHeight
.loop_y

 move.l Scaler_PtrSrc,a0
 add.l (a2,d6),a0
 addq #4,d6
 
 cmp #16*4,d6
 bne.s .skip
 move.l Scaler_PtrSrc,a0
 add.l (a2,d6),a0
 moveq #0,d6		; Index in the table...
 move.l a0,Scaler_PtrSrc 
.skip 

 move.l Scaler_PtrDst,a1
 
 move Scaler_Width,d5
.loop_x

 ; Shift until we get 16 bytes
.patch_start
 REPT 16
 move.b $1234(a0),d4	; 12/3
 addx.b d4,d4			; 4/1
 addx.w d0,d0
 addx.b d4,d4
 addx.w d1,d1
 addx.b d4,d4
 addx.w d2,d2
 addx.b d4,d4
 addx.w d3,d3
 ; 12/3 + 8*(4/1) = 3+8 = 44/11 per pixel
 ENDR
.patch_end
 ; 16*11=176 nops for 16 bytes
 lea $1234(a0),a0		; 8/2
 
 ; Write the four bitplans
 move.w d0,(a1)+		; 8/2
 move.w d1,(a1)+		; 8/2
 move.w d2,(a1)+		; 8/2
 move.w d3,(a1)+		; 8/2
 ; 32/8
 
 ; Grand total:
 ; 16*11+2+8 = 744/186
 
 ; movem.w d0/d1/d2/d3,-(a1) 	; 8+4n=8+4*4=24/6
 ; movep.l dn,16(an)			; 24/6
 
 dbra d5,.loop_x
 
 move.l Scaler_PtrDst,a1
 add.w Scaler_StrideDst,a1
 move.l a1,Scaler_PtrDst
  
 subq #1,Scaler_CurHeight
 bne .loop_y
 
 movem.l (sp)+,d0-a6
 rts
 
 
 
; a0=source buffer (plannar)
; a1=destination buffer (chunky)
; d0=size of the buffer
ZoomerPlannarToChunky
 move.l Scaler_PtrSrc,a2
 move.l Scaler_PtrDst,a3

 move.w Scaler_Height,d7
.loop_y
 move.l a2,a0
 add.w Scaler_StrideSrc,a2
 
 move.l a3,a1
 add.w Scaler_StrideDst,a3
 
 move.w Scaler_Width,d6
.loop_x
 movem.w (a0)+,d0/d1/d2/d3	; Read the four bitplans
 
 ; Shift until we get 16 bytes
 REPT 16
 moveq #0,d4
 lsl.w d0
 roxl.w d4
 lsl.w d1
 roxl.w d4
 lsl.w d2
 roxl.w d4
 lsl.w d3
 roxl.w d4
 
 move.b d4,d5		; Duplicate the low nibble
 lsl.b #4,d5
 or.b d5,d4
 
 move.b d4,(a1)+	; Write the chunky pixel
 ENDR
 dbra d6,.loop_x
 
 
 dbra d7,.loop_y
 rts
 
 
 
; ------------------
;   Rotating plan
; ------------------
 
AnimateRotatingPlan
 move.w blue_plane_angle,d0
 add.b blue_plane_speed,d0
 and.w #255,d0
 move.w d0,blue_plane_angle
  
 COLORHELP #$030
 
 ; First we reset the display list to point on an empty scanline
 move.l #big_buffer_start+defenceforce_screen+65535,d0
 clr.w d0
 lsl.l #8,d0
 move.l d0,a0
 
 lea big_buffer_start+cinemascope_sprites_depacked,a1
 bsr DisplayListInitStatic

 COLORHELP #$003
 
 ; Compute the 3D coordinates
 lea table_sine_16,a0		; 256*2
 lea table_sine_16+128,a1	; 256*2
  
 ; FFFFFFFFFFFF8001
 ; FFFFFFFFFFFF809f
 move blue_plane_angle,d0
 and #255,d0
 add d0,d0
 
 ; p0
 move #-32767,blue_plane_x0
 move (a0,d0),blue_plane_y0		; -32767,+32767
 move (a1,d0),blue_plane_z0		; -32767,+32767
  
 ; p1 
 add #256,d0	; +half circle 
 move #-32767,blue_plane_x1
 move (a0,d0),blue_plane_y1		; -32767,+32767
 move (a1,d0),blue_plane_z1		; -32767,+32767
  
 ; Compute projection Z0
 move blue_plane_z0,d7
 add #32767,d7				; z: 0,65535
 lsr #8,d7					; Z: 0,255 
 add blue_plane_zoom,d7		; z: 255,511
 move d7,blue_plane_z0

 ; Compute projection Z1
 move blue_plane_z1,d7
 add #32767,d7				; z: 0,65535
 lsr #8,d7					; Z: 0,255 
 add blue_plane_zoom,d7		; z: 255,511
 move d7,blue_plane_z1
   
 ; Compute 2D X0
 move blue_plane_x0,d0
 asr #8,d0					; -255,+255
 muls #XSCALE,d0			; DX
 divs blue_plane_z1,d0
 add #XCENTER,d0			; CX
 move d0,blue_plane_xx0 

 ; Compute 2D Y0
 move blue_plane_y0,d0
 asr #8,d0					; -255,+255
 muls #YSCALE,d0			; DY
 divs blue_plane_z0,d0		; /255-511
 add #YCENTER,d0			; CY
 move d0,blue_plane_yy0
 
 ; Compute 2D X1
 move blue_plane_x1,d0
 asr #8,d0					; -255,+255
 muls #XSCALE,d0			; DX
 divs blue_plane_z0,d0
 add #XCENTER,d0			; CX
 move d0,blue_plane_xx1
 
 ; Compute 2D Y1
 move blue_plane_y1,d0
 asr #8,d0				; -255,+255
 muls #YSCALE,d0			; DY
 divs blue_plane_z1,d0				; /255-511
 add #YCENTER,d0			; CY
 move d0,blue_plane_yy1
    
 COLORHELP #$303
 
 move blue_plane_xx0,d0
 move blue_plane_yy0,d1
 move blue_plane_xx1,d2
 move blue_plane_yy1,d3
 bsr.s DrawPolygoneLine
   
 ; Change the color of the plan depending of the angle and sign
 moveq #0,d0
 move blue_plane_y0,d0	; -32767,+32767
 bpl.s .not_neg
 neg d0					; 0,+32767
.not_neg
 lsr #8,d0
 lsr #3,d0

 lsl #2,d0 
 move blue_plane_yy0,d1
 move blue_plane_yy1,d3
 sub d1,d3
 bpl.s .no_flip_color
 addq #2,d0
.no_flip_color
 lea big_buffer_start+RotatingPlanPaletteFade,a0
 move (a0,d0),big_buffer_start+cinemascope_sprites_depacked+2*8
 rts
  
 
; d0.w=x0
; d1.w=y0 
; d2.w=x1
; d3.w=y1
DrawPolygoneLine
 moveq #1,d4	; ix
 sub.w d0,d2	; dx
 bpl.s .dx_positive
.dx_negative 
 neg.w d2		; abs(dx)
 moveq #-1,d4
.dx_positive 

 ; Compute scanline adress
 lea DisplayList+1,a1
 move d1,d5
 add d5,d5
 add d5,d5
 add d5,d5
 add d5,a1

 moveq.l #8,d5	; iy
 sub.w d1,d3	; dy
 bpl.s .dy_positive
.dy_negative 
 neg.w d3		; abs(dy)
 moveq.l #-8,d5
.dy_positive 
   
; d0=x0
; d1=x1
; d2=abs(dx)
; d3=abs(dy)
; d4=ix
; d5=iy
; d6=err
  
 cmp.w d2,d3
 bhi.s .draw_vertical

.draw_horizontal 
 move d2,d6
 
 move d3,d7
 add d3,d7
 sub d2,d7
 
 add d3,d3
 add d2,d2

.horizontal_loop
 move.b d0,(a1)
 
 tst.w d7
 bmi .skipa
 sub d2,d7
 add d5,a1
.skipa
 add d3,d7
 add.w d4,d0
 dbra d6,.horizontal_loop
 rts
 
.draw_vertical 
 move d3,d6
 
 move d2,d7
 add d2,d7
 sub d3,d7

 add d3,d3
 add d2,d2
  
.vertical_loop  
 move.b d0,(a1)

 tst.w d7
 bmi .skip
 add.w d4,d0
 sub d3,d7
.skip 
 add d5,a1
 add d2,d7
 dbra d6,.vertical_loop
 rts 
  


 
DrawPlanScanLines
 move blit_stride,-(sp)
 
 move #256,blit_stride

 move.l #big_buffer_start+defenceforce_screen+65535,d0
 clr.w d0
 move.l d0,a0
 
 move #208,d0	; x0
 move #0,d1		; y0
 move #208,d2	; x1
 move #1,d3		; y1
 
 move.l #$000f0008,d4
  
 move.w #208-1,d7
.next_line
 bsr BlitterDrawRectangle
 subq #1,d0
 addq #1,d2
 addq #1,d1
 addq #1,d3
 dbra d7,.next_line 
 
 move (sp)+,blit_stride
 rts

  

; ------------------
;      Sprites
; ------------------
 
LogoSetUpSprites
 ;
 ; Force the palette to have only white and blue
 ;
 lea palette_vbl_fade,a0
 move.w #$046,2*10(a0)		; Blue shadow
 move.w #$fff,2*14(a0)		; Dark grey shadow
 move.w #$fff,2*15(a0)		; Black frame


 move.l #big_buffer_start+defenceforce_screen_1,d0
 lsl.l #8,d0
 move.l d0,a0
 
 move.l #SpritePos,ptr_current_sprite
 
 lea palette_vbl_fade,a1
 lea DisplayList,a2
 move.l #416*256,d0
 moveq #0,d1
 bsr DisplayListInit200
 
 ; Prepare fade to make details on the logo to appear
 lea palette_vbl_fade,a0
 lea big_buffer_start+cinemascope_sprites_depacked,a1
 moveq #16,d7
 bsr ComputeGradient
 
 
 move.l #LogoInitSprite,_AdrCinemascopeVblRoutine
 rts
  
 
 
LogoInitSprite
 move.l ptr_current_sprite,a0
 move.w (a0)+,d0
 bmi .done
 move.w (a0)+,d1
 move.w (a0)+,d2
 move.w (a0)+,d3
 move.l (a0)+,ptr_sprite_data
 move.l a0,ptr_current_sprite
 
 lea CurveData,a0
 move d2,curve_start_x(a0)
 move d3,curve_start_y(a0)
 move #90,curve_midle_x(a0)
 move #90,curve_midle_y(a0)
 move d0,curve_final_x(a0)
 move d1,curve_final_y(a0)
 move #SPRITES_CURVE_LENGHT,curve_lenght(a0)
 move #0,curve_offset(a0)
 move.l #416,sprite_screen_offset
 
 ; Need to precalculate the curve due to the damn music :-/
 lea CurveData,a0
 move #0,curve_offset(a0)
 lea big_buffer_start+defenceforce_sprite_curve,a1
 move.w #(SPRITES_CURVE_LENGHT/SPRITES_CURVE_SPEED),d7
.loop_precalc 
 bsr BezierInterpolate 	
 move.w d0,(a1)+
 move.w d1,(a1)+
 addq #4,curve_offset(a0) 
 dbra d7,.loop_precalc 
 move #SPRITES_CURVE_LENGHT,curve_offset(a0)
   
 move.l #LogoUpdateSprites,_AdrCinemascopeVblRoutine
 rts
.done  
 move.l #LogoTwistAndShoutInit,_AdrCinemascopeVblRoutine
 rts

 
LogoUpdateSprites
 move blit_stride,-(sp)
 move #416,blit_stride
 
 bsr LogoEraseSprites
 bsr SpritesMove
 
 move (sp)+,blit_stride
 rts  

 
SpritesMove
 lea CurveData,a0
 
 lea big_buffer_start+defenceforce_sprite_curve,a1
 move curve_offset(a0),d0
 add.w d0,a1
 move.w (a1)+,d0
 move.w (a1)+,d1
 
 move d0,d4

 mulu blit_stride,d1
  
 lsr.w #4,d0
 lsl.w #3,d0
 add.w d0,d1

 move.l d1,sprite_screen_offset
 lea big_buffer_start+defenceforce_screen_1,a1
 add.l d1,a1
    
 move.l ptr_sprite_data,a0
 move.l (a0)+,a3	; Sprite bitmap
 move.l (a0)+,a2	; Sprite mask
 move.w (a0)+,d0
 move.w d0,d1
 lsl #3,d1
 move #160+2+6,d2
 move #416+2+6,d3
 sub d1,d2
 sub d1,d3
 move #SPRITES_HEIGHT,d1
 and #15,d4
 move.l a3,a0
 bsr BlitterDrawSprite
 
 lea CurveData,a0
 subq #4,curve_offset(a0) 
 bmi.s .done
 rts
.done
 move.l #LogoFixSprite,_AdrCinemascopeVblRoutine
 rts 
 
LogoFixSprite
 lea big_buffer_start+defenceforce_screen_1,a0
 lea big_buffer_start+defenceforce_screen_2,a1
 bsr.s LogoDoBlit
 move.l #LogoInitSprite,_AdrCinemascopeVblRoutine
 rts
  
LogoEraseSprites
 lea big_buffer_start+defenceforce_screen_2,a0
 lea big_buffer_start+defenceforce_screen_1,a1
LogoDoBlit 

 move.l sprite_screen_offset,d2

 add.l d2,a0
 add.l d2,a1
      
 move #4*4,d0
 move #SPRITES_HEIGHT,d1
 move #416-(4*8)+2,d2
 move #416-(4*8)+2,d3
 and #15,d4
 
 bra BlitterCopyBlock
  

 
DefenceForceGenerateMasks
 lea big_buffer_start+cinemascope_sprites_depacked+32,a0
 lea big_buffer_start+masks_defenceforcelogo,a1
 move.w #20*SPRITES_HEIGHT,d1
.loop 
 move.w (a0)+,d0
 or.w (a0)+,d0 
 or.w (a0)+,d0 
 or.w (a0)+,d0 
 not.w d0
 move.w d0,(a1)+
 dbra d1,.loop
 rts 
  
  
LogoTwistAndShoutInit
 move.w #192,ZoomerAngle
 move.w #0,defenceforce_pos_x
 move.w #0,defenceforce_offset_y
 lea big_buffer_start+defenceforce_offsets,a0
 move #128-1,d7
.loop
 move.w #0,(a0)+
 dbra d7,.loop
  
 move.l #LogoTwistAndShout,_AdrCinemascopeVblRoutine 
 rts 
 
LogoTwistAndShout
 move.l #big_buffer_start+defenceforce_screen_1+(49*416),d0
 lsl.l #8,d0
 move.l d0,a0
   
 ; Global offset
 move.w defenceforce_pos_x,d4
 addq.w #1,d4
 cmp.w #416,d4
 blt.s .continue
 ; Done with the whole intro
 st.b flag_end_part
.continue 
 move.w d4,defenceforce_pos_x
  
 move.w ZoomerAngle,d0
 addq.w #1,d0
 and.w #255,d0
 move.w d0,ZoomerAngle
 add.w d0,d0
 lea sine_255,a5			; 16 bits, unsigned between 00 and 127
 add.w (a5,d0.w),d4
  
 cmp.w #416,d4
 blt.s .skip
 move.w #416,d4
.skip 

 lea TableShifterShift,a3	; Dist table
 add.w d4,d4
 
 lea big_buffer_start+defenceforce_offsets,a2
 move defenceforce_offset_y,d5
 add #1,defenceforce_offset_y
 add d5,d5
 and.w #255-1,d5
 
 move (a3,d4.w),(a2,d5.w)
 
 move.l #416*256,d7			; Offset
 lea DisplayList+(49*8),a6	; Target display list
 lea sine_255,a5			; 16 bits, unsigned between 00 and 127
 moveq #0,d6
 
var set 0 
 REPT 103
 move.l a0,a1
 add.l d7,a0
 
 add.w #2,d5
 and.w #255-1,d5
 move.w (a2,d5.w),d6
 add.l d6,a1
  
 move.l a1,var*8(a6)
 
var set var+1 
 ENDR
 
 rts
   
 
LogoPrepareScreens 
 move blit_stride,-(sp)
 move #416,blit_stride
 
 lea big_buffer_start+cinemascope_sprites_depacked+(2*16),a1	; Palette
 
 move #62+4+3,d0	; x0
 move #56+4,d1		; y0
 move #349+4+2,d2	; x1
 move #143+4,d3		; y1
 move.l #$000f000e,d4
 move.w #$111,big_buffer_start+cinemascope_sprites_depacked+(2*14)
 
 lea big_buffer_start+defenceforce_screen_1,a0
 bsr BlitterDrawRectangle

 lea big_buffer_start+defenceforce_screen_2,a0
 bsr BlitterDrawRectangle

  
 ; Black frame one
 subq #4,d0
 subq #4,d1
 subq #4,d2
 subq #4,d3
 move.l #$000f000f,d4
 move.w #$000,big_buffer_start+cinemascope_sprites_depacked+(2*15)
 
 lea big_buffer_start+defenceforce_screen_1,a0
 bsr BlitterDrawRectangle

 lea big_buffer_start+defenceforce_screen_2,a0
 bsr BlitterDrawRectangle

 
 ; Blue one - dark
 addq #1,d0
 addq #1,d1
 subq #1,d2
 subq #1,d3
 move.l #$000f000a,d4
 move.w #$035,big_buffer_start+cinemascope_sprites_depacked+(2*10)
 
 lea big_buffer_start+defenceforce_screen_1,a0
 bsr BlitterDrawRectangle

 lea big_buffer_start+defenceforce_screen_2,a0
 bsr BlitterDrawRectangle

 
 ; Blue one
 addq #1,d0
 addq #1,d1
 move.l #$000f0008,d4
 move.w #$046,big_buffer_start+cinemascope_sprites_depacked+(2*8)
 
 lea big_buffer_start+defenceforce_screen_1,a0
 bsr BlitterDrawRectangle

 lea big_buffer_start+defenceforce_screen_2,a0
 bsr BlitterDrawRectangle
    
 move (sp)+,blit_stride
 
 rts
 

 
 
  
 
 SECTION DATA

 even
 	
enable_zoomer	equ 1
enable_rotation equ 1

enable_test_size equ 0
 
CinemascopeSequencer

 ifne enable_zoomer
 SEQUENCE_SETPTR _AdrCinemascopeVblRoutine,CinemaScopeAnimateZoom
 
 SEQUENCE_TEMPORIZE 50*2
 endc
 
 SEQUENCE_SETPTR _AdrCinemascopeVblRoutine,DummyRoutine
 SEQUENCE_CALLBACK DefenceForceLogoSetup
 
 ifne enable_rotation
 SEQUENCE_SET_WORD blue_plane_angle,0
 SEQUENCE_SETPTR _AdrCinemascopeVblRoutine,AnimateRotatingPlan
  
 SEQUENCE_SET_BYTE blue_plane_speed,10
 
 
 SEQUENCE_TEMPORIZE 5
 SEQUENCE_SET_BYTE blue_plane_speed,9
 SEQUENCE_TEMPORIZE 10
 SEQUENCE_SET_BYTE blue_plane_speed,8
 SEQUENCE_TEMPORIZE 15
 SEQUENCE_SET_BYTE blue_plane_speed,7
 SEQUENCE_TEMPORIZE 20
 SEQUENCE_SET_BYTE blue_plane_speed,6
 SEQUENCE_TEMPORIZE 25
 SEQUENCE_SET_BYTE blue_plane_speed,5
 SEQUENCE_TEMPORIZE 30
 SEQUENCE_SET_BYTE blue_plane_speed,4
 SEQUENCE_TEMPORIZE 35
 SEQUENCE_SET_BYTE blue_plane_speed,3
 SEQUENCE_TEMPORIZE 40
 SEQUENCE_SET_BYTE blue_plane_speed,2
 SEQUENCE_TEMPORIZE 45
 SEQUENCE_SET_BYTE blue_plane_speed,1
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_SET_BYTE blue_plane_speed,0
 endc

 	ifne enable_test_size 
 SEQUENCE_SET_WORD blue_plane_angle,192
 SEQUENCE_SETPTR _AdrCinemascopeVblRoutine,AnimateRotatingPlan
 SEQUENCE_TEMPORIZE 50*5
 	endc
 
 
 SEQUENCE_SETPTR _AdrCinemascopeVblRoutine,DummyRoutine
 SEQUENCE_CALLBACK LogoSetUpSprites
 SEQUENCE_TEMPORIZE 50*3
 
 SEQUENCE_TEMPORIZE 50*10
  
 ifne enable_auto_skip 
 SEQUENCE_GO_NEXT_PART	; And leave
 endc
 SEQUENCE_END


 
 
 even
 
 
; Unpacked: 20832
; Packed:    8386
 FILE "cinescop.pik",packed_cinemascope

; Unpacked: 7712
; Packed:   4206
 FILE "dfncfrce.pik",packed_defenceforce_sprites
 
 even
 
PackInfoCinemascope 
 dc.l packed_cinemascope
 dc.l big_buffer_start+cinemascope_logo_depacked
 dc.l 20832
  
PackInfoDefenceForceSprites
 dc.l packed_defenceforce_sprites
 dc.l big_buffer_start+cinemascope_sprites_depacked
 dc.l 7712
   

 rsreset
zoomer_ptr_start 	rs.l 1
zoomer_x_offsets	rs.w 16+1
zoomer_width_blocs	rs.w 1
zoomer_width_pixels	rs.w 1
zoomer_height		rs.w 1
zoomer_start_offset	rs.w 1
zoomer_y_offsets	rs.l 16+1

zoomer_size	equ __RS
  
; Percentage,Width,height
SCALE_TABLE macro
percent 		set \1
source_width 	set \2
source_height	set \3
dest_width		set (source_width*percent)/100
dest_height		set (source_height*percent)/100
bloc_count		set dest_width/16

 ; Start adress (patched by the scaler code)
 dc.l 0
 
 ; X-Offset
 dc.w (0*source_width)/dest_width
 dc.w (1*source_width)/dest_width
 dc.w (2*source_width)/dest_width
 dc.w (3*source_width)/dest_width
 dc.w (4*source_width)/dest_width
 dc.w (5*source_width)/dest_width
 dc.w (6*source_width)/dest_width
 dc.w (7*source_width)/dest_width
 dc.w (8*source_width)/dest_width
 dc.w (9*source_width)/dest_width
 dc.w (10*source_width)/dest_width
 dc.w (11*source_width)/dest_width
 dc.w (12*source_width)/dest_width
 dc.w (13*source_width)/dest_width
 dc.w (14*source_width)/dest_width
 dc.w (15*source_width)/dest_width

 dc.w (16*source_width)/dest_width
 
 ;dc.w bloc_count
 dc.w (source_width)/((16*source_width)/dest_width)
 
 dc.w dest_width
 dc.w dest_height
 dc.w (((source_width/2)-(dest_width/2))/16)*8		; Start offset
 
 ; Y-Offset
 dc.l ((0*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((1*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((2*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((3*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((4*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((5*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((6*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((7*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((8*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((9*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((10*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((11*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((12*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((13*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((14*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 dc.l ((15*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH

 dc.l ((16*source_height)/dest_height)*ZOOMER_BUFFER_WIDTH
 
cinemascope_buffer_size set cinemascope_buffer_size+(dest_height*ZOOMER_BUFFER_WIDTH) 
 endm
 
 
; Initialize with a first line containing neutral values 
cinemascope_buffer_size	set ZOOMER_BUFFER_WIDTH
 
Scaler_Table_Start
var set 0
 REPT ZOOMER_STEPS
var set var+1 
percentage set (var*100)/ZOOMER_STEPS 
 SCALE_TABLE percentage,ZOOMER_WIDTH,ZOOMER_HEIGHT
 ENDR
        
Scaler_Tables 
var set 0
 REPT ZOOMER_STEPS
 dc.l Scaler_Table_Start+var*zoomer_size
var set var+1 
 ENDR
 

SpriteData_D
 ;0
 dc.l big_buffer_start+cinemascope_sprites_depacked+32+(0*8)		; D 
 dc.l big_buffer_start+masks_defenceforcelogo+(0*2)
 dc.w 2
 
SpriteData_C
 ;1
 dc.l big_buffer_start+cinemascope_sprites_depacked+32+(3*8)		; C 
 dc.l big_buffer_start+masks_defenceforcelogo+(3*2)
 dc.w 2
 
SpriteData_O
 ;2
 dc.l big_buffer_start+cinemascope_sprites_depacked+32+(6*8)		; O 
 dc.l big_buffer_start+masks_defenceforcelogo+(6*2)
 dc.w 2
 
SpriteData_N
 ;3
 dc.l big_buffer_start+cinemascope_sprites_depacked+32+(9*8)		; N 
 dc.l big_buffer_start+masks_defenceforcelogo+(9*2)
 dc.w 2
 
SpriteData_E
 ;4
 dc.l big_buffer_start+cinemascope_sprites_depacked+32+(12*8)	; E 
 dc.l big_buffer_start+masks_defenceforcelogo+(12*2)
 dc.w 2
 
SpriteData_F
 ;5
 dc.l big_buffer_start+cinemascope_sprites_depacked+32+(15*8)	; F 
 dc.l big_buffer_start+masks_defenceforcelogo+(15*2)
 dc.w 2
 
SpriteData_R
 ;6
 dc.l big_buffer_start+cinemascope_sprites_depacked+32+(18*8)	; R 
 dc.l big_buffer_start+masks_defenceforcelogo+(18*2)
 dc.w 2
 
 
sprite_offset_x equ 20
sprite_offset_y equ -31
 
SpritePos
 dc.w 0,150
 dc.w 76,49 ; D 
 dc.l SpriteData_D
 dc.w 416,0
 dc.w 114,49 ; E 
 dc.l SpriteData_E
 dc.w 416,100
 dc.w 152,49 ; F
 dc.l SpriteData_F
 dc.w 0,150
 dc.w 190,49 ; E 
 dc.l SpriteData_E
 dc.w 416,30
 dc.w 228,49 ; N 
 dc.l SpriteData_N
 dc.w 416,160
 dc.w 266,49 ; C 
 dc.l SpriteData_C
 dc.w 0,30
 dc.w 304,49 ; E 
 dc.l SpriteData_E
 
 dc.w 416,200
 dc.w 114,113 ; F
 dc.l SpriteData_F
 dc.w 0,40
 dc.w 152,113 ; O 
 dc.l SpriteData_O
 dc.w 0,150
 dc.w 190,113 ; R 
 dc.l SpriteData_R
 dc.w 416,20
 dc.w 228,113 ; C 
 dc.l SpriteData_C
 dc.w 0,0
 dc.w 266,113 ; E 
 dc.l SpriteData_E
 
 dc.w -1,-1
 dc.w -1,-1
 dc.l 0

; Background rectangle: 42,87 - 327,173 
  
   
 SECTION BSS
  
 even

Scaler_Factor		ds.w 1
  
Scaler_Width		ds.w 1
Scaler_Height		ds.w 1
 
Scaler_CurWidth		ds.w 1
Scaler_CurHeight	ds.w 1

Scaler_StrideSrc	ds.w 1
Scaler_StrideDst	ds.w 1

Scaler_PtrSrc		ds.l 1
Scaler_PtrDst		ds.l 1

Scaler_DestOffset	ds.w 1

 even

defenceforce_pos_x		ds.w 1
defenceforce_offset_y	ds.w 1
 
ZoomerAngle 			ds.w 1
 
ptr_sprite_data			ds.l 1
ptr_current_sprite		ds.l 1
sprite_screen_offset	ds.l 1
blue_plane_speed		ds.b 1

 even
  
blue_plane_angle		ds.w 1
blue_plane_zoom			ds.w 1

blue_plane_x0			ds.w 1
blue_plane_y0			ds.w 1
blue_plane_z0			ds.w 1
blue_plane_x1			ds.w 1
blue_plane_y1			ds.w 1
blue_plane_z1			ds.w 1

blue_plane_xx0			ds.w 1
blue_plane_yy0			ds.w 1

blue_plane_xx1			ds.w 1
blue_plane_yy1			ds.w 1

blue_plane_light		ds.w 1	; +0,+15
 
;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset
cinemascope_screenbuffer		rs.b cinemascope_buffer_size	; about 616448 bytes for 32 levels
 
cinemascope_fullscreen			rs.b Size_PanoramicRoutine_DisplayList
zoomer_buffer_chunky			rs.b ZOOMER_BUFFER_WIDTH*100
cinemascope_logo_depacked		rs.b 20832
cinemascope_sprites_depacked	rs.b 7712
cinemascope_scanlines			rs.l ZOOMER_HEIGHT*ZOOMER_STEPS	; 85*32 - interlaced

defenceforce_offsets			rs.w 128					; Line offsets

defenceforce_sprite_curve		rs.w ((SPRITES_CURVE_LENGHT/SPRITES_CURVE_SPEED)+1)*2

RotatingPlanPaletteStart		rs.w 2		; Black, Black
RotatingPlanPaletteEnd			rs.w 2		; Blue, Orange
RotatingPlanPaletteFade			rs.w 2*16	; All the gradient colors

masks_defenceforcelogo			rs.b 160*SPRITES_HEIGHT
defenceforce_screen 			rs.b 256*200+65536			; Screen data for the scanlines
defenceforce_screen_1			rs.b 416*200				; Screen data for the sprites (front buffer)
defenceforce_screen_2			rs.b 416*200				; Screen data for the sprites (back buffer)



 update_buffer_size
 


