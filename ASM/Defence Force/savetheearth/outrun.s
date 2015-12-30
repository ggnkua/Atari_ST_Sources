 
OUTRUN_TRUCK_X		equ 8*8
OUTRUN_TRUCK_Y		equ 77

OUTRUN_TRUCK_HEIGHT	equ 113

OUTRUN_POS_SKY		equ 100+10

OUTRUN_COLOR_SKY	equ $137	; 0
OUTRUN_COLOR_GROUND	equ $471	; 0
OUTRUN_COLOR_STRIPE	equ $777	; 1
OUTRUN_COLOR_ROAD	equ $333	; 2

 
 SECTION TEXT
 
 even
   
OutrunInit
 ; Depack the truck
 lea PackInfoTruck,a0
 bsr DepackBlock
  
 move.l #big_buffer_start+outrun_screen,ptr_scr_1		; For DrawLine/DrawPixel to work 
    
 bsr OutrunDrawRoad
        
 bsr OutrunComputeMasterpalette
 
 ; Generate the mask from the sprite data - if not done yet
 bsr OutrunGenerateMasks
 
 ; Draw the scene !  
 bsr DrawTruck
 
 ; Using the template data, we generate the fullscreen
 lea PanoramicTemplate_DisplayList,a0
 lea big_buffer_start+outrun_fullscreen,a1
 bsr GenerateOverscan
 rts
 
 
OutrunPlay
 bsr SequencerPlay
 rts
 
OutrunTerminate
 bsr TerminateFullscreenTimer
 rts  

 
 
OutrunComputeMasterpalette
 ; Init the truck
 lea big_buffer_start+outrun_depacked_truck_facing,a0
 lea big_buffer_start+OutrunPalettes+(OUTRUN_TRUCK_Y*32),a1
 move #OUTRUN_TRUCK_HEIGHT-1,d0
.loop_init_truck
 REPT 16
 move (a0)+,(a1)+
 ENDR
 dbra d0,.loop_init_truck 
 
 
 tst.b Outrun_flag_master_generated
 bne .skip_master_palette
 ; a0 - Source buffer (r,g,b components)
 ; a1 - Target buffer (16 bits colors, STE interleaved format)
 ; d7 - Number of colors
 lea SkyColors,a0
 lea SkyColors,a1
 moveq #OUTRUN_POS_SKY,d7
 bsr RawToSt
 st.b Outrun_flag_master_generated
.skip_master_palette 
 
 ; Init the sky
 lea SkyColors,a0
 lea big_buffer_start+OutrunPalettes,a1
 move #OUTRUN_POS_SKY-1,d7
.loop_init_sky
 move (a0)+,(a1)
 
 lea 32(a1),a1
 dbra d7,.loop_init_sky 
 
 ; Init the road
 move #(200-OUTRUN_POS_SKY)-1,d0
.loop_init_ground
 move #OUTRUN_COLOR_GROUND,0(a1)
 move #OUTRUN_COLOR_STRIPE,2(a1)
 move #OUTRUN_COLOR_ROAD,4(a1)
 lea 32(a1),a1
 dbra d0,.loop_init_ground 
  
 move.l #$000000,d0	; Black
 move.l #$6ca83c,d1	; Green
 lea big_buffer_start+OutrunGradientGrass,a2
 move #200-OUTRUN_POS_SKY,d7
 bsr CreateBackgroundGradient

 move.l #$000000,d0	; Black
 move.l #$c0c0c0,d1	; Light grey
 lea big_buffer_start+OutrunGradientStripes,a2
 move #200-OUTRUN_POS_SKY,d7
 bsr CreateBackgroundGradient

 move.l #$000000,d0	; Black
 move.l #$404040,d1	; Dark grey
 lea big_buffer_start+OutrunGradientRoad,a2
 move #200-OUTRUN_POS_SKY,d7
 bsr CreateBackgroundGradient
 
 rts
  
OutrunScrollColors 
 lea DivTable,a0
 lea big_buffer_start+OutrunPalettes+(OUTRUN_POS_SKY*32),a1
 
 lea big_buffer_start+OutrunGradientStripes,a4
 lea big_buffer_start+OutrunGradientGrass,a5
 lea big_buffer_start+OutrunGradientRoad,a6

 move #(200-OUTRUN_POS_SKY)-1,d7
.loop_init_truck
 
 moveq #0,d2
 
 move (a0)+,d0
 add RoadPosition,d0
 lsr #3,d0
 and #1,d0
 beq.s .skip
 move #$111,d2
.skip 
 add d0,d0
  
 ; Grass/ground
 move (a5)+,d1
 add d2,d1
 move d1,0(a1)

 ; Stripes
 move #$222,d1
 sub d2,d1
 sub d2,d1
 add (a4)+,d1
 move d1,2(a1)
  
 ; Road
 move (a6)+,d1
 add d2,d1
 move d1,4(a1)
   
 lea 32(a1),a1
 dbra d7,.loop_init_truck 
 
 subq #1,RoadPosition
 
 bsr OutRunSetScreen
 rts
     
 
OutRunSetScreen
 move pos_scr_x,d0
 addq #2,d0
 and #$0003,d0
 move d0,pos_scr_x

 ; Update the display list to point on the correct screen adress
 move.l #big_buffer_start+outrun_screen,d1
 lsl.l #8,d1
 move.b d0,d1
 move.l d1,a0
 
 lea big_buffer_start+OutrunPalettes,a1
 lea DisplayList,a2
 move.l #208*256,d0
 moveq #32,d1
 bsr DisplayListInit200
 rts 
 
    
DrawTruck
 lea big_buffer_start+outrun_depacked_truck_facing+(32*113),a0
 lea big_buffer_start+outrun_screen,a1
 add.l #OUTRUN_TRUCK_X+(OUTRUN_TRUCK_Y*208),a1
 lea big_buffer_start+Outrun_mask_truck,a2
 move.w #6,d0
 move.w #OUTRUN_TRUCK_HEIGHT,d1
 ;move #48+2+6,d2
 move #2+6,d2
 move #208-8*5,d3
 moveq #0,d4
 
; a0=source
; a1=destination
; a2=mask
; d0=width in words
; d1=height 
; d2=skip line source
; d3=skip line dest
; d4=pixel offset
 
 bsr BlitterDrawSprite

 rts 
  
OutrunDrawRoad
 ;
 ; Draw the main part of the road (tarmac)
 ; Uses index 2
 ;
 lea big_buffer_start+outrun_screen,a0 
 
 move #206,d0				; x0
 move #OUTRUN_POS_SKY,d1	; y0
 move #210,d2				; x1
 move #OUTRUN_POS_SKY+1,d3	; y1
 
 move.l #$000f0002,d4
  
 move.w #(200-OUTRUN_POS_SKY)-1,d7
.next_line
 bsr BlitterDrawRectangle
 subq.w #2,d0
 addq.w #2,d2
 addq.w #1,d1
 addq.w #1,d3
 dbra d7,.next_line 
 
 ; 
 ; Stripes on the road uses index 1
 ;
 move #1,d0
 bsr SetPixelColor

 move.w #OUTRUN_POS_SKY,d1
 move.w #200,d3

 move.w #10,d6
 
 moveq #20,d7
.loop_thick

 ; Left line
 movem.l d0-a6,-(sp)
 move.w #206,d0
 move d6,d2
 bsr DrawLine
 movem.l (sp)+,d0-a6

 ; Right line
 movem.l d0-a6,-(sp)
 move.w #210,d0
 move d6,d2
 add #400-20,d2
 bsr DrawLine
 movem.l (sp)+,d0-a6
 
 addq #1,d6
  
 dbra d7,.loop_thick

 rts

 
OutrunGenerateMasks
 lea big_buffer_start+outrun_depacked_truck_facing+(32*113),a0
 lea big_buffer_start+Outrun_mask_truck,a1
 move.w #(16*OUTRUN_TRUCK_HEIGHT)/2-1,d1
.loop 
 move.w (a0)+,d0
 or.w (a0)+,d0 
 or.w (a0)+,d0 
 or.w (a0)+,d0 
 not.w d0
 move.w d0,(a1)+
 dbra d1,.loop
 rts 

    
 SECTION DATA

 even 
	
OutrunSequencer 
 SEQUENCE_SETPTR _AdrPartVblRoutine,OutrunScrollColors
 
 SEQUENCE_TEMPORIZE 50*1
 
 SEQUENCE_SUBTITLE <"Your new Atari Sixteen/Thirty-two",13,"enhanced computer is arriving soon.">

 ; Wait a bit
 SEQUENCE_TEMPORIZE 50*3

 SEQUENCE_SUBTITLE <"">
 
 SEQUENCE_TEMPORIZE 50*1
   
 ; And leave
 SEQUENCE_GO_NEXT_PART	
 SEQUENCE_END
 
 
 
PackInfoTruck 
 dc.l packed_truck_facing
 dc.l big_buffer_start+outrun_depacked_truck_facing
 dc.l 9040
 
; Unpacked: 9040
; Packed:   1892 
 FILE "truckfrt.pik",packed_truck_facing
  
 even
 
SkyColors
	dc.b 5,139,234,6,140,234,7,140,234,8,141,234,9,141,235,10
	dc.b 142,235,10,142,235,11,143,235,12,143,235,13,144,235,14,145
	dc.b 235,15,145,236,16,146,236,17,146,236,18,147,236,19,147,236
	dc.b 20,148,236,20,148,236,21,149,236,22,149,237,23,150,237,24
	dc.b 151,237,25,151,237,26,152,237,27,152,237,28,153,237,28,153
	dc.b 238,30,154,238,30,154,238,31,155,238,32,155,238,33,156,238
	dc.b 34,157,238,35,157,239,36,158,239,37,158,239,38,159,239,38
	dc.b 159,239,40,160,239,40,160,239,41,161,240,42,162,240,43,162
	dc.b 240,44,163,240,45,163,240,46,164,240,47,164,240,48,165,240
	dc.b 48,165,241,49,166,241,50,167,241,51,167,241,52,168,241,53
	dc.b 168,241,54,169,241,55,169,242,56,170,242,57,170,242,58,171
	dc.b 242,58,171,242,59,172,242,60,173,242,61,173,243,62,174,243
	dc.b 63,174,243,64,175,243,65,175,243,66,176,243,67,176,243,68
	dc.b 177,243,68,178,244,69,178,244,70,179,244,71,179,244,72,180
	dc.b 244,73,180,244,74,181,244,75,181,245,76,182,245,77,183,245
	dc.b 78,183,245,78,184,245,79,184,245,80,185,245,81,185,246,82
	dc.b 186,246,83,186,246,84,187,246,86,187,246,89,188,245,91,189
	dc.b 245,95,189,245,97,190,244,100,190,244,103,191,244,105,192,243
	dc.b 108,192,243,111,193,242,114,194,242,117,194,242,119,195,241,122
	dc.b 195,241,125,196,241,128,197,240,131,197,240,133,198,240,136,198
	dc.b 239,139,199,239,142,200,238,144,200,238  

 even
 
DivTable
var set 0
 REPT 200-OUTRUN_POS_SKY
 dc.w 4096/(var+16)
var set var+1
 ENDR 
  
 SECTION BSS
  
 even

RoadPosition					ds.w 1
Outrun_flag_master_generated	ds.b 1
 
 even
 
;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset
outrun_fullscreen				rs.b Size_PanoramicRoutine_DisplayList
OutrunPalettes					rs.w 16*200		; 3200 bytes 

OutrunGradientGrass				rs.w 200-OUTRUN_POS_SKY
OutrunGradientStripes			rs.w 200-OUTRUN_POS_SKY
OutrunGradientRoad				rs.w 200-OUTRUN_POS_SKY

; 20*48*2=1920
; 16*113=1808
Outrun_mask_truck				rs.b 16*OUTRUN_TRUCK_HEIGHT	; Mike, not correct (12*113 is wrong)

outrun_screen 					rs.b 208*200			; Screen data
outrun_depacked_truck_facing	rs.b 9040

 update_buffer_size
 

 
 