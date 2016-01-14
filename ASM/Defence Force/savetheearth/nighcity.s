
 SECTION TEXT
 
 even

NIGHTCITY_TOTAL_HEIGHT	equ 400		; Two screen high 
NIGHTCITY_POS_Y_MOON	equ 0
NIGHTCITY_POS_Y_CITY	equ 200
NIGHTCITY_POS_Y_MIRROR	equ 364 

NIGHTCITY_HEIGHT_MOON	equ 76
NIGHTCITY_HEIGHT_CITY	equ 200
NIGHTCITY_HEIGHT_MIRROR	equ 35

DisplayNightCityInit
 ; Depack the night city picture
 lea PackInfoNightCity,a0
 bsr DepackBlock
 
 lea PackInfoMoon,a0
 bsr DepackBlock

 ifne enable_music
 lea music,a0
 bsr StartMusicIfNotStarted
 endc
  
 ; Set the screen information (static fullscreen picture)
 move.l #big_buffer_start+depacked_nightcity+32,ptr_scr_1
 
 move #0,pos_scr_y
 ;move #NIGHTCITY_TOTAL_HEIGHT-200-1,pos_scr_y
 
 ; Picture palette
 lea black_palette,a0
 lea big_buffer_start+depacked_nightcity,a1
 moveq #16,d7
 bsr ComputeGradient

 ; Background gradient
 lea big_buffer_start+nightcity_gradient,a2

 move #200,d7
  
 move.l #$000000,d0	; Black
 move.l #$000000,d1	; Black
 bsr CreateBackgroundGradient
 
 move #50,d7
 
 move.l #$000000,d0	; Black
 move.l #$000a51,d1	; Dark blue
 bsr CreateBackgroundGradient

 move #35,d7
  
 move.l #$000a51,d0	; Dark blue
 move.l #$76ccff,d1	; Light blue
 bsr CreateBackgroundGradient

 move #35,d7
 
 move.l #$76ccff,d0
 move.l #$ff00b0,d1
 bsr CreateBackgroundGradient

 move #30,d7

 move.l #$ff00b0,d0
 move.l #$700000,d1
 bsr CreateBackgroundGradient

 move #50,d7
 
 move.l #$000000,d0	; Black
 move.l #$001070,d1	; Black
 bsr CreateBackgroundGradient
     
 bsr NightCityCreateMasterPicture
 bsr NightCityUpdateDisplayList
   
 ; Using the template data, we generate the fullscreen
 lea PanoramicTemplate_DisplayList,a0
 lea big_buffer_start+nightcity_fullscreen,a1
 bsr GenerateOverscan
 rts

DisplayNightCityPlay
 COLORHELP #$700
 bsr SequencerPlay
 COLORHELP #$070
 ;bsr NightCityUpdateDisplayList
 COLORHELP #$007
  
_AdrNightCityRoutine=*+2
 jsr DummyRoutine
 COLORHELP #$000
 rts
 
DisplayNightCityTerminate
 bsr TerminateFullscreenTimer
 rts
 
 
NightCityScrollDown 
 add #1,pos_scr_y
 cmp #NIGHTCITY_TOTAL_HEIGHT-200,pos_scr_y
 bne.s .keep_scrolling_y
 move.l #DummyRoutine,_AdrNightCityRoutine
.keep_scrolling_y
 rts 
 
 
NightCityCreateMasterPicture
 ; First makes every scanline point on the empty line
 lea empty_line,a0
 movem.l (a0),d1/d2/d3/d4/d5/d6/a4/a5		; Black palette
 move.l a0,d0
 lsl.l #8,d0
 
 lea big_buffer_start+nightcity_screen,a1
 lea big_buffer_start+nightcity_palettes,a2
 move #NIGHTCITY_TOTAL_HEIGHT-1,d7
.loop_erase_line
 move.l d0,(a1)+
 movem.l d1/d2/d3/d4/d5/d6/a4/a5,(a2)
 lea 32(a2),a2
 dbra d7,.loop_erase_line
 
 ; Then add the moon with associated palettes
 lea big_buffer_start+depacked_moon,a0		; Palette
 movem.l (a0)+,d1/d2/d3/d4/d5/d6/a4/a5		; Moon palette
 move.l a0,d0
 lsl.l #8,d0 
 lea big_buffer_start+nightcity_screen+(NIGHTCITY_POS_Y_MOON*4),a2
 lea big_buffer_start+nightcity_palettes+(NIGHTCITY_POS_Y_MOON*32),a3
 move #NIGHTCITY_HEIGHT_MOON-1,d7
.loop_draw_moon
 move.l d0,(a2)+
 movem.l d1/d2/d3/d4/d5/d6/a4/a5,(a3)
 add.l #208*256,d0
 lea 32(a3),a3
 dbra d7,.loop_draw_moon
 
 ; Then add the city
 lea big_buffer_start+depacked_nightcity,a0		; Palette
 movem.l (a0)+,d1/d2/d3/d4/d5/d6/a4/a5			; City palette
 move.l a0,d0
 lsl.l #8,d0 
 addq.l #8,d0
 lea big_buffer_start+nightcity_screen+(NIGHTCITY_POS_Y_CITY*4),a2
 lea big_buffer_start+nightcity_palettes+(NIGHTCITY_POS_Y_CITY*32),a3
 move #NIGHTCITY_HEIGHT_CITY-1,d7
.loop_draw_city
 move.l d0,(a2)+
 movem.l d1/d2/d3/d4/d5/d6/a4/a5,(a3)
 add.l #208*256,d0
 lea 32(a3),a3
 dbra d7,.loop_draw_city
 
 ; Then add the mirror of the city
 lea big_buffer_start+depacked_nightcity,a0		; Palette
 movem.l (a0)+,d1/d2/d3/d4/d5/d6/a4/a5			; City palette
 move.l a0,d0
 add.l #208*164,d0
 lsl.l #8,d0 
 addq.l #8,d0
 lea big_buffer_start+nightcity_screen+(NIGHTCITY_POS_Y_MIRROR*4),a2
 lea big_buffer_start+nightcity_palettes+(NIGHTCITY_POS_Y_MIRROR*32),a3
 move #NIGHTCITY_HEIGHT_MIRROR-1,d7
.loop_draw_city_mirror
 move.l d0,(a2)+
 movem.l d1/d2/d3/d4/d5/d6/a4/a5,(a3)
 sub.l #208*256*2,d0
 lea 32(a3),a3
 dbra d7,.loop_draw_city_mirror
 
 
 ; Then patch the palettes to insert the background color
 lea big_buffer_start+nightcity_gradient,a0
 lea big_buffer_start+nightcity_palettes,a1
 move #NIGHTCITY_TOTAL_HEIGHT-1,d0
.loop_copy_background
 move (a0)+,(a1)
 lea 32(a1),a1
 dbra d0,.loop_copy_background
 rts 

  
NightCityUpdateDisplayList
 COLORHELP #$030
 bsr.s NightCityMirror

 COLORHELP #$040
 lea big_buffer_start+nightcity_screen,a0				; Scanlines list
 lea big_buffer_start+nightcity_palettes,a1 			; Palette list 
 
 move pos_scr_y,d0
 add d0,d0				; x2
 add d0,d0				; x4
 add d0,a0
 lsl #3,d0
 add d0,a1
  
 lea DisplayList,a2										; Target display list
 move #200-1,d7
.loop_side
 move.l (a0)+,(a2)+
 move.l a1,(a2)+
 lea 32(a1),a1
 dbra d7,.loop_side
 
 rts
 
NightCityMirror
 lea sine_255,a1
 move MirrorAngle,d2
 addq #1,MirrorAngle
 and #255,d2
 add d2,d2

 move MirrorAngle2,d3
 subq #3,MirrorAngle2
 and #255,d3
 add d3,d3
  
 ; Then add the mirror of the city
 lea big_buffer_start+depacked_nightcity+32,a0		; Palette
 move.l a0,d0
 add.l #208*164,d0
 lsl.l #8,d0 
 addq.l #8,d0
 lea big_buffer_start+nightcity_screen+(NIGHTCITY_POS_Y_MIRROR*4),a2
 lea big_buffer_start+nightcity_palettes+(NIGHTCITY_POS_Y_MIRROR*32),a3
 move #NIGHTCITY_HEIGHT_MIRROR-1,d7
.loop_draw_city_mirror

 moveq #0,d1
 move 0(a1,d2),d1	; 16 bits, between 00 and 127
 move d1,d5
 addq #4,d2
 lsr #5,d1

 moveq #0,d4
 move 0(a1,d3),d4	; 16 bits, between 00 and 127
 addq #6,d3
 lsr #2,d4
 
 add d4,d1  
 
 lsr #3,d1
 
 mulu #208*256,d1
 move.l d0,d6
 add.l d1,d6
 
 lsr #5,d5
 add d5,d6
 
 move.l d6,(a2)+
 sub.l #208*256*2,d0

 ;moveq #0,d1
 ;move 0(a1,d2),d1	; 16 bits, between 00 and 127
 ;add #2,d2
 ;;lsr #8,d1
 ;lsr #4,d1
 ;add.l d0,d1
 ;move.l d1,(a2)+
 ;sub.l #208*256*2,d0
 lea 32(a3),a3
 dbra d7,.loop_draw_city_mirror
 rts 
 
MirrorAngle	dc.w 0
MirrorAngle2	dc.w 0
 
 SECTION DATA

 even
  
PackInfoNightCity 
 dc.l picture_nightcity
 dc.l big_buffer_start+depacked_nightcity
 dc.l 41632
 
PackInfoMoon
 dc.l picture_moon
 dc.l big_buffer_start+depacked_moon
 dc.l 15840
 
; Unpacked: 41632
; Packed:   12447 
; 416x200
 FILE "nghtcity.pik",picture_nightcity

; Unpacked: 15840
; Packed:    3278
; 416x76 
 FILE "moon.pik",picture_moon

 
NightCitySequencer 
 SEQUENCE_SETPTR _AdrPartVblRoutine,NightCityUpdateDisplayList
 SEQUENCE_SUBTITLE <"1989. Another warm summer night",13,"in California.">
 
 SEQUENCE_TEMPORIZE 50*3
 SEQUENCE_SETPTR _AdrNightCityRoutine,NightCityScrollDown

 SEQUENCE_TEMPORIZE 50
 SEQUENCE_SUBTITLE <""> 
  

 SEQUENCE_TEMPORIZE 50*5
 
 SEQUENCE_SUBTITLE <"In San Francisco inhabitants are",13,"relaxing after a hard day at work.">
 ;It's sleep time for the citizens",13,"of San Francisco."> 

 SEQUENCE_TEMPORIZE 50*3
 
 SEQUENCE_SUBTITLE <""> 

 SEQUENCE_TEMPORIZE 50*3

 SEQUENCE_SUBTITLE <"But in the nearby city of Sunnyvale,",13,"Atari is preparing the STe launch.">

 SEQUENCE_TEMPORIZE 50*3

 SEQUENCE_SUBTITLE <""> 
   
 SEQUENCE_GO_NEXT_PART	; And leave
 SEQUENCE_END
 
   

 SECTION BSS
  
 even

;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset
nightcity_fullscreen		rs.b Size_PanoramicRoutine_DisplayList
depacked_nightcity			rs.b 41632
depacked_moon				rs.b 15840

nightcity_screen			rs.l NIGHTCITY_TOTAL_HEIGHT			; Pointers on lines
nightcity_palettes			rs.b 32*NIGHTCITY_TOTAL_HEIGHT		; One palette per line
nightcity_gradient			rs.w NIGHTCITY_TOTAL_HEIGHT			; One background entry per line

 update_buffer_size
 

 