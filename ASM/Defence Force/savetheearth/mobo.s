
 SECTION TEXT
 
 even
 
MotherBoardInit
 ; Depack the ste motherboard picture
 lea PackInfoMotherboard,a0
 bsr DepackBlock

 ; Depack the ste case side picture
 lea PackInfoSteSide,a0
 bsr DepackBlock

 ; Depack the ste box picture
 lea PackInfoSteBox,a0
 bsr DepackBlock
 
 ; Depack the ste box picture
 lea PackInfoTruckSide,a0
 bsr DepackBlock
 

 ; Picture palette
 lea black_palette,a0
 lea big_buffer_start+depacked_stemotherboard,a1
 moveq #16,d7
 bsr ComputeGradient

 ; Duplicate some of the graphics for smooth wrapping of the buffers
 bsr MotherBoardDuplicateSte
 bsr MotherBoardDuplicateBox

 sf.b flag_mobo_pingpong_x
 sf.b flag_mobo_pingpong_y
 
 sf.b flag_show_mobo
 sf.b flag_show_stecase
 sf.b flag_show_box
 sf.b flag_show_truck
 
 move #0,pos_scr_x
 move #0,pos_scr_y
 move #0,raster_pos
 
 move #200,ste_pos_y
 move #0,ste_pos_x
 move #0,big_buffer_start+ste_angle
 
 move #0,box_pos_x
 move #200,box_pos_y
 move #0,big_buffer_start+box_angle

 move #368,truck_pos_x
 move #200,truck_pos_y

 move #50,mobo_pos_x 
 move #0,mobo_pos_y
 move #200,mobo_vertical_start
  
 ; Set new screen parameters 
 ; On STE, LineWidth value in $ff820f is added to the shifter counter 
 ;lea picture_stemotherboard+32-160+6,a0
 lea big_buffer_start+depacked_stemotherboard+32,a0
 move.l a0,ptr_scr_1
 move #424,screen_stride		; Default in 320x200 is 160 bytes

 ; Non overscan: 160 - 160 / 0
 ; Overscan:     224 - 230 / 0
 ; Moboverscan:  424 - 230 / 97 <- linewidth=(totalsize-screensize)/2
   
 bsr AtariBuildingResetDisplayList
 
 ; Using the template data, we generate the fullscreen
 lea PanoramicTemplate_DisplayList,a0
 lea big_buffer_start+motherboard_fullscreen,a1
 bsr GenerateOverscan
 
 move.l #AtariBuildingVbl,_AdrPartVblRoutine
 rts

 
MotherBoardPlay
 bsr SequencerPlay
 rts

  
MotherBoardTerminate
 bsr TerminateFullscreenTimer
 rts


 
 
  
AtariBuildingVbl
 move.b flag_show_mobo,d0
 beq.s .skip_motherboard
 COLORHELP #$020
 bsr MoveMobo
 COLORHELP #$040
 bsr AtariBuildingDrawMotherboard
.skip_motherboard
 
 tst.b flag_show_stecase
 beq.s .skip_case
 COLORHELP #$006
 bsr AtariBuildingDrawScrollingCase
.skip_case 

 tst.b flag_show_box
 beq.s .skip_box
 COLORHELP #$600
 bsr AtariBuildingDrawScrollingBox
.skip_box

 tst.b flag_show_truck
 beq.s .skip_truck
 COLORHELP #$600
 bsr AtariBuildingDrawScrollingTruck
.skip_truck

 rts 
 
 

MoveMobo
 subq.b #1,d0
 beq.s .vertical_scroll
 subq.b #1,d0
 beq.s .multi_scroll
 rts 
 
.vertical_scroll 
 tst.w mobo_vertical_start
 beq.s .done
 subq.w #1,mobo_vertical_start
.done 
 rts
    
;848x506
;848-416=432
;506-200=306 
.multi_scroll
 tst.b flag_mobo_pingpong_x
 beq.s .scroll_right
.scroll_left
 subq #2,mobo_pos_x
 bne.s .keep_scrolling_x
 not.b flag_mobo_pingpong_x
 rts
   
.scroll_right 
 addq #2,mobo_pos_x
 cmp #432+16,mobo_pos_x
 bne.s .keep_scrolling_x
 not.b flag_mobo_pingpong_x
.keep_scrolling_x

 tst.b flag_mobo_pingpong_y
 beq.s .scroll_bottom
.scroll_top
 subq #4,raster_pos
 subq #2,mobo_pos_y
 bpl.s .keep_scrolling_y
 not.b flag_mobo_pingpong_y
 rts
   
.scroll_bottom 
 addq #2,mobo_pos_y
 addq #4,raster_pos
 cmp #306+2,mobo_pos_y
 bne.s .keep_scrolling_y
 not.b flag_mobo_pingpong_y
.keep_scrolling_y
 rts
  
  

AtariBuildingDrawMotherboard
 ; First part with the scrolling motherboard
 moveq #0,d0
 move mobo_pos_y,d0
 muls #424,d0
 add.l #big_buffer_start+depacked_stemotherboard+(32*506),d0
 
 moveq #0,d1
 move.w mobo_pos_x,d1
 lsr.w #1,d1
 and.w #-8,d1
 add.l d1,d0
 
 lsl.l #8,d0
 
 move.b mobo_pos_x+1,d0
 and.b #15,d0
 move.l d0,a0

 lea big_buffer_start+depacked_stemotherboard,a1
 move mobo_pos_y,d1
 lsl #5,d1
 add d1,a1
   
 lea DisplayList,a2
 move.w mobo_vertical_start,d2
 lsl #3,d2
 add d2,a2
 move.l #424*256,d0
 moveq #32,d1
 bsr DisplayListInit200
.done
 rts
 

  
;
; Second part with the ste side picture
;
AtariBuildingDrawScrollingCase
 ; Move
 add #1,ste_pos_x
 cmp #416,ste_pos_x
 bne.s .no_wrap_case
 move #0,ste_pos_x
.no_wrap_case

 cmp.w #100,ste_pos_y
 beq.s .no_mid
 subq #1,ste_pos_y
.no_mid 

 ; Display
 move.l #big_buffer_start+depacked_steside+(32*100),d0
 lsl.l #8,d0
 move.l d0,a0
 
 moveq #0,d1
 lea TableShifterShift,a2
 move.w ste_pos_x,d1
 add.w d1,d1
 move.w (a2,d1.w),d1
 add.l d1,a0
  
 move ste_pos_y,d1
 
 cmp.b #2,flag_show_stecase
 bne.s .skip_wobble
 lea sine_255,a2
 move big_buffer_start+ste_angle,d0
 addq #1,big_buffer_start+ste_angle
 and #255,d0
 add d0,d0
 move 0(a2,d0),d0	; 16 bits, between 00 and 127
 lsr #1,d0			; 00 to 64
 sub #32,d0			; -32 to 32
 add d0,d1
.skip_wobble
 
 lea DisplayList,a2
 lsl #3,d1
 add d1,a2
 
 move.l #416*256,d0
 moveq #32,d1
 lea big_buffer_start+depacked_steside,a1
 bsr DisplayListInit100
 
 ; The separating 'raster'
 ;move.l #empty_line,d0
 ;lsl.l #8,d0
 ;move.l #empty_line,a0
 ;lea DisplayList+(100*8),a1
 ;move.l d0,(a1)+
 ;move.l a0,(a1)+
 rts

  
;
; third part with the ste box picture
;
AtariBuildingDrawScrollingBox
 ; Move
 add #2,box_pos_x
 cmp #144,box_pos_x
 bne.s .no_wrap_box
 move #0,box_pos_x
.no_wrap_box

 cmp.w #0,box_pos_y
 beq.s .no_mid
 subq #1,box_pos_y
.no_mid 

 ; Display
 moveq #0,d0
 move.w box_pos_x,d0
 lsr.w #1,d0
 and.w #-8,d0
 add.l #big_buffer_start+buffer_stebox,d0	; Screen buffer
 ;add.l #(32*506)
 lsl.l #8,d0
 move.b box_pos_x+1,d0
 and.b #15,d0
 move.l d0,a0
 
 move box_pos_y,d1
 
 cmp.b #2,flag_show_box
 bne.s .skip_wobble
 lea sine_255,a2
 move big_buffer_start+box_angle,d0
 addq #1,big_buffer_start+box_angle
 and #255,d0
 add d0,d0
 move 0(a2,d0),d0	; 16 bits, between 00 and 127
 lsr #1,d0			; 00 to 64
 sub #32,d0			; -32 to 32
 add d0,d1
.skip_wobble
 
 lea DisplayList,a2
 lsl #3,d1
 add d1,a2
 
 move.l #288*256,d0
 moveq #32,d1
 lea big_buffer_start+depacked_stebox,a1 	; Palettes
 bsr DisplayListInit100
 
 ; The separating 'raster'
 ;move.l #empty_line,d0
 ;lsl.l #8,d0
 ;move.l #empty_line,a0
 ;lea DisplayList+(50*8),a1
 ;move.l d0,(a1)+
 ;move.l a0,(a1)+
 ;lea DisplayList+(150*8),a1
 ;move.l d0,(a1)+
 ;move.l a0,(a1)+
 rts 
 
 
AtariBuildingDrawScrollingTruck
 ; Move
 cmp.b #2,flag_show_truck
 bne.s .done
 cmp #0,truck_pos_x
 beq.s .done
 sub #2,truck_pos_x
.done

 cmp.w #33,truck_pos_y
 beq.s .no_mid
 subq #1,truck_pos_y
.no_mid 

 ; Display
 moveq #0,d0
 move.w truck_pos_x,d0
 lsr.w #1,d0
 and.w #-8,d0
 add.l #big_buffer_start+depacked_truckside+(32*133),d0	; Screen buffer
 lsl.l #8,d0
 move.b truck_pos_x+1,d0
 and.b #15,d0
 move.l d0,a0
 
 lea DisplayList,a2
 move truck_pos_y,d1
 lsl #3,d1
 add d1,a2
 
 move.l #392*256,d0
 moveq #32,d1
 lea big_buffer_start+depacked_truckside,a1 	; Palettes
 bsr DisplayListInit133
 rts 
 
 
 
; 832x100 pixels
; Need to duplicate the 416 first 
; 208/4=52
; 208/52=4
MotherBoardDuplicateSte
 lea big_buffer_start+depacked_steside+(32*100),a0
 move #100-1,d0
.loop_copy 
 REPT 4
 movem.l (a0)+,d1/d2/d3/d4/d5/d7/d6/a1/a2/a3/a4/a5/a6		; 13*4=52 bytes
 movem.l d1/d2/d3/d4/d5/d6/d7/a1/a2/a3/a4/a5/a6,208-52(a0)
 ENDR
 lea 208(a0),a0
 dbra d0,.loop_copy 
 rts

 
; 832x100 pixels
; 832/16=52
; One box is 9 blocks large (144x100 pixels)
; 9*8=72 bytes
; 72/4=18
; 18/2=9
MotherBoardDuplicateBox
 lea big_buffer_start+depacked_stebox+(32*100),a0	; Source picture
 lea big_buffer_start+buffer_stebox,a1				; Destination Screen buffer
 move #100-1,d7
.loop_copy 
var set 0
 REPT 2
 movem.l (a0)+,d0/d1/d2/d3/d4/d5/d6/a2/a3		; 9*4=36 bytes
 movem.l d0/d1/d2/d3/d4/d5/d6/a2/a3,var*36+72*0(a1)
 movem.l d0/d1/d2/d3/d4/d5/d6/a2/a3,var*36+72*1(a1)
 movem.l d0/d1/d2/d3/d4/d5/d6/a2/a3,var*36+72*2(a1)
 movem.l d0/d1/d2/d3/d4/d5/d6/a2/a3,var*36+72*3(a1)
var set var+1 
 ENDR
 lea 288(a1),a1
 dbra d7,.loop_copy 
 rts
 
 
AtariBuildingResetDisplayList
 ; First makes every scanline point on the empty line
 move.l #empty_line,d0
 lsl.l #8,d0

 lea big_buffer_start+depacked_stemotherboard,a0
 
 COLORSWAP
 lea DisplayList,a1
 move #200-1,d7
.loop
 move.l d0,(a1)+
 move.l a0,(a1)+
 clr.w (a0)			; Clear the first color
 lea 32(a0),a0
 dbra d7,.loop 
 COLORSWAP
 rts
 
 
 
     
 SECTION DATA
 
 even
 
; 865x506 
; Unpacked: 230736
; Packed:    99576 
 FILE "stemobo.pik",picture_stemotherboard

; 832x100 
; Unpacked:  44800
; Packed:     8886
 FILE "steside.pik",picture_steside
 
; 144x100 
; Unpacked:  10400
; Packed:     3940
 FILE "stebox.pik",picture_stebox

; 784x133
; Unpacked:  56392
; Packed:    19802
 FILE "trucksde.pik",picture_truckside
  
PackInfoMotherboard 
 dc.l picture_stemotherboard
 dc.l big_buffer_start+depacked_stemotherboard
 dc.l 230736

PackInfoSteSide
 dc.l picture_steside
 dc.l big_buffer_start+depacked_steside
 dc.l 44800

PackInfoSteBox
 dc.l picture_stebox
 dc.l big_buffer_start+depacked_stebox
 dc.l 10400
 
PackInfoTruckSide
 dc.l picture_truckside
 dc.l big_buffer_start+depacked_truckside
 dc.l 56392

  
AtariBuildingSequencer
 SEQUENCE_SUBTITLE <"Your STE computer is assembled in",13,"an ultra-modern factory.">
 SEQUENCE_TEMPORIZE 50*3
 
 SEQUENCE_SUBTITLE <"First the motherboards are moved to",13,"the automated conveyor belt...."> 
 SEQUENCE_SET_BYTE flag_show_mobo,1
 SEQUENCE_TEMPORIZE 50*5
 SEQUENCE_SUBTITLE <"...where first grade components are",13,"installed (cpu, memory, connectors)"> 
 SEQUENCE_SET_BYTE flag_show_mobo,2
 SEQUENCE_TEMPORIZE 50*5

 SEQUENCE_SUBTITLE <"Then the motherboard is solidly fixed",13,"in the computer case"> 
 SEQUENCE_SET_BYTE flag_show_stecase,1
 SEQUENCE_TEMPORIZE 50*5

 SEQUENCE_SUBTITLE <"After being tested, each unit is",13,"boxed and ready for shipping"> 
 SEQUENCE_SET_BYTE flag_show_box,1
 SEQUENCE_SET_BYTE flag_show_stecase,2
 SEQUENCE_TEMPORIZE 50*5

 SEQUENCE_SUBTITLE <"Boxes are sent by truck",13,"to your local shop"> 
 SEQUENCE_SET_BYTE flag_show_truck,1	; Move up
 SEQUENCE_SET_BYTE flag_show_box,2
 SEQUENCE_TEMPORIZE 50*4
 SEQUENCE_SET_BYTE flag_show_truck,2	; Move left
 SEQUENCE_TEMPORIZE 50*3

 SEQUENCE_SUBTITLE <"Your Atari will soon be delivered",13,"for hours of enjoyment!"> 
 SEQUENCE_TEMPORIZE 50*2
    
 SEQUENCE_SUBTITLE <""> 
  
 SEQUENCE_GO_NEXT_PART	; And leave 
 SEQUENCE_END
 
 even
 
  	
 SECTION BSS
 
 even
  
raster_pos				ds.w 1
flag_mobo_pingpong_x	ds.b 1
flag_mobo_pingpong_y	ds.b 1

ste_pos_x				ds.w 1
ste_pos_y				ds.w 1

box_pos_x				ds.w 1
box_pos_y				ds.w 1

truck_pos_x				ds.w 1
truck_pos_y				ds.w 1

mobo_pos_x				ds.w 1	; Horizontal offset in the mobo window
mobo_pos_y				ds.w 1	; Vertical offset in the mobo window
mobo_vertical_start		ds.w 1

flag_show_mobo			ds.b 1	; 0=invisible / 1=vertical scroll / 2=multiscroll
flag_show_stecase		ds.b 1
flag_show_box			ds.b 1
flag_show_truck			ds.b 1
 
 even
   
;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset
motherboard_fullscreen		rs.b Size_PanoramicRoutine_DisplayList
depacked_stemotherboard		rs.b 230736
depacked_steside			rs.b 44800
depacked_stebox				rs.b 10400
depacked_truckside          rs.b 56392

buffer_stebox				rs.b 288*100	; 576 pixel=144*4

box_angle					rs.w 1
ste_angle					rs.w 1

 update_buffer_size
 

 