
 SECTION TEXT
 
 even

DesktopOfficeInit
 ; Depack test
 lea PackInfoOfficePicture,a0
 bsr DepackBlock
  
 move.w #0,pos_scr_x
  
 bsr GenerateAtariDemoScrollBuffer
 bsr CreateSkyGradient
 bsr UpdateAtariMonitorGradient
  
 ifne enable_music
 lea music,a0
 bsr StartMusicIfNotStarted
 endc
 
 ; Using the template data, we generate the fullscreen
 lea PanoramicTemplate_DisplayList,a0
 lea big_buffer_start+desktopoffice_fullscreen,a1
 bsr GenerateOverscan
 rts

DesktopOfficePlay
_AdrDesktopOfficePlay=*+2
 jsr DummyRoutine
 bsr SequencerPlay
 rts
 
 
DesktopOfficeScrollRight
 cmp.w #608-416,pos_scr_x
 beq.s .done
 addq.w #1,pos_scr_x
.done 
 rts 
 
DesktopOfficeScrollLeft
 tst.w pos_scr_x
 beq.s .done
 subq.w #1,pos_scr_x
.done 
 rts 
 
  
DesktopOfficeTerminate
 ; turn it off
 move.b #14,$ffff8800.w 
 or.b #%00000010,$ffff8802.w 
 bsr TerminateFullscreenTimer
 rts
 

   
  
DesktopOfficeVbl
 bsr UpdateBinaryClock
 bsr UpdateEthernetSwitch
 bsr UpdateAtariFloppyLed
 bsr UpdateAtariMonitorScroller
 bsr UpdateAtariMonitorGradient
 bsr DesktopOfficeSetScreen
 rts 
 
 
DesktopOfficeSetScreen
 moveq #0,d0
 move.w pos_scr_x,d0
 lsr.w #1,d0
 and.w #-8,d0
 add.l #big_buffer_start+desktopoffice_depacked_picture+32*200,d0	; Screen buffer
 lsl.l #8,d0
 move.b pos_scr_x+1,d0
 and.b #15,d0
 move.l d0,a0
 
 lea big_buffer_start+desktopoffice_depacked_picture,a1
 lea DisplayList,a2
 move.l #304*256,d0
 moveq #32,d1
 bsr DisplayListInit200
 rts 
 
     

; Line 134, index2
UpdateAtariFloppyLed
 lea big_buffer_start+desktopoffice_depacked_picture+32*134+4,a1
 bsr NextPRN
 and.w #1,d0
 bne.s .light_led
.off_led 
 move.w #$320,(a1)
 ; turn it off
 move.b #14,$ffff8800.w 
 or.b #%00000010,$ffff8802.w 
 rts
.light_led 
 move.w #$760,(a1)
 ; turn it on
 move.b #14,$ffff8800.w 
 and.b #%11111101,$ffff8802.w
 rts
 
  
 
 
; Monitor is from 144,49 to 223,101
;
; Scanline width=608/2=304 bytes
; Block starts at position 114=offset 72
; 5 Blocks wide
; Can host 5 characters
;
; Font at index 2 (2nd plan)
; Background raster at index 4 (3rd plan)
;
UpdateAtariMonitorScroller
 move.w big_buffer_start+desktopoffice_scrolltext_pos,d7
 addq.w #1,d7
 and.w #1023,d7					; 128 characters max
 move.w d7,big_buffer_start+desktopoffice_scrolltext_pos
 
 move.l #big_buffer_start+desktopoffice_demo_scroller,a0
 lea big_buffer_start+desktopoffice_depacked_picture+32*200+(304*50)+72,a1
          
 move.w d7,d6
 lsr.w #4,d6		; /16
 add.w d6,d6
 add.w d6,a0		; Current byte
 
 move.w d7,d6
 and.w #15,d6		; Modulo 15
 lsl.w #8,d6		; *256
 lsl.w #3,d6		; *8
 add.w d6,a0

 
var set 0 
 REPT 8
 ; source 10 bytes -> 5 words destination
 movem.w var*256(a0),d0/d1/d2/d3/d4
 
 move.w d0,2+8*0+var*304(a1)
 move.w d1,2+8*1+var*304(a1)
 move.w d2,2+8*2+var*304(a1)
 move.w d3,2+8*3+var*304(a1)
 move.w d4,2+8*4+var*304(a1)

 move.w d0,2+8*0+(var+21)*304(a1)
 move.w d1,2+8*1+(var+21)*304(a1)
 move.w d2,2+8*2+(var+21)*304(a1)
 move.w d3,2+8*3+(var+21)*304(a1)
 move.w d4,2+8*4+(var+21)*304(a1)

 move.w d0,2+8*0+(var+44)*304(a1)
 move.w d1,2+8*1+(var+44)*304(a1)
 move.w d2,2+8*2+(var+44)*304(a1)
 move.w d3,2+8*3+(var+44)*304(a1)
 move.w d4,2+8*4+(var+44)*304(a1)
   
 not d0
 not d1
 not d2
 not d3
 not d4
  
 move.w d0,4+8*0+var*304(a1)
 move.w d1,4+8*1+var*304(a1)
 move.w d2,4+8*2+var*304(a1)
 move.w d3,4+8*3+var*304(a1)
 move.w d4,4+8*4+var*304(a1)

 move.w d0,4+8*0+(var+21)*304(a1)
 move.w d1,4+8*1+(var+21)*304(a1)
 move.w d2,4+8*2+(var+21)*304(a1)
 move.w d3,4+8*3+(var+21)*304(a1)
 move.w d4,4+8*4+(var+21)*304(a1)

 move.w d0,4+8*0+(var+44)*304(a1)
 move.w d1,4+8*1+(var+44)*304(a1)
 move.w d2,4+8*2+(var+44)*304(a1)
 move.w d3,4+8*3+(var+44)*304(a1)
 move.w d4,4+8*4+(var+44)*304(a1)
 
var set var+1 
 ENDR

 ; Generate the palette
 lea DesktopOfficeRastersTextWhite,a0
 lea big_buffer_start+desktopoffice_depacked_picture+32*50+4,a1
 move.w (a0)+,0*32(a1)
 move.w (a0)+,1*32(a1)
 move.w (a0)+,2*32(a1)
 move.w (a0)+,3*32(a1)
 move.w (a0)+,4*32(a1)
 move.w (a0)+,5*32(a1)
 move.w (a0)+,6*32(a1)
 move.w (a0)+,7*32(a1)

 move.w (a0)+,(21+0)*32(a1)
 move.w (a0)+,(21+1)*32(a1)
 move.w (a0)+,(21+2)*32(a1)
 move.w (a0)+,(21+3)*32(a1)
 move.w (a0)+,(21+4)*32(a1)
 move.w (a0)+,(21+5)*32(a1)
 move.w (a0)+,(21+6)*32(a1)
 move.w (a0)+,(21+7)*32(a1)

 move.w (a0)+,(44+0)*32(a1)
 move.w (a0)+,(44+1)*32(a1)
 move.w (a0)+,(44+2)*32(a1)
 move.w (a0)+,(44+3)*32(a1)
 move.w (a0)+,(44+4)*32(a1)
 move.w (a0)+,(44+5)*32(a1)
 move.w (a0)+,(44+6)*32(a1)
 move.w (a0)+,(44+7)*32(a1)
 rts
 
  
UpdateAtariMonitorGradient
 addq #1,big_buffer_start+desktopoffice_rasters_pos
 
 ; The main rasters in the background
 lea AtariDemoRasters,a0
 moveq #0,d0
 move big_buffer_start+desktopoffice_rasters_pos,d0
 lsr d0
 add d0,d0 
  
 lea big_buffer_start+desktopoffice_depacked_picture+32*49+(4*2),a1
var set 0
 REPT 53
 and #127,d0
 move (a0,d0),var*32(a1)
 addq #2,d0
var set var+1 
 ENDR
 
 
 ; Then some small raster bars moving up and down
 lea AtariDemoBounceTable,a0
 
 move big_buffer_start+desktopoffice_rasters_pos,d0
 add d0,d0
 
 ; Red raster
 lea big_buffer_start+desktopoffice_depacked_picture+32*49+(4*2),a1
 and #127-1,d0
 add (a0,d0),a1

 move.w #$300,0*32(a1)
 move.w #$500,1*32(a1)
 move.w #$700,2*32(a1)
 move.w #$500,3*32(a1)
 move.w #$300,4*32(a1)
    
 ; Orange raster
 lea big_buffer_start+desktopoffice_depacked_picture+32*49+(4*2),a1
 addq #6,d0
 and #127-1,d0
 add (a0,d0),a1
  
 move.w #$310,0*32(a1)
 move.w #$530,1*32(a1)
 move.w #$750,2*32(a1)
 move.w #$530,3*32(a1)
 move.w #$310,4*32(a1)
 
 ; Yellow raster
 lea big_buffer_start+desktopoffice_depacked_picture+32*49+(4*2),a1
 add #32,d0
 and #127-1,d0
 add (a0,d0),a1
 
 move.w #$320,0*32(a1)
 move.w #$550,1*32(a1)
 move.w #$770,2*32(a1)
 move.w #$550,3*32(a1)
 move.w #$320,4*32(a1)

 move.w #$320,0*32-4(a1)
 move.w #$550,1*32-4(a1)
 move.w #$770,2*32-4(a1)
 move.w #$550,3*32-4(a1)
 move.w #$320,4*32-4(a1)
 
 ; Clear White raster
 lea big_buffer_start+desktopoffice_depacked_picture+32*49+(4*2),a1
 addq #6,d0
 and #127-1,d0
 add (a0,d0),a1
 
 move.w #$321,0*32(a1)
 move.w #$552,1*32(a1)
 move.w #$775,2*32(a1)
 move.w #$552,3*32(a1)
 move.w #$321,4*32(a1)

 move.w #$321,0*32-4(a1)
 move.w #$552,1*32-4(a1)
 move.w #$775,2*32-4(a1)
 move.w #$552,3*32-4(a1)
 move.w #$321,4*32-4(a1)
      
 rts 
  
; 2 lines: 116/117
; 8 colonnes: 304/306/308/...
; Scanline width=608/2=304 bytes
; Block starts at position 304=offset 152
UpdateEthernetSwitch
 lea big_buffer_start+desktopoffice_depacked_picture+32*116,a1
 move #$272,2(a1)
 move #$050,2+32(a1)

 move.b time_frame,d0
 and #%111,d0
 bne.s .skip_switch_update
 
 lea big_buffer_start+desktopoffice_depacked_picture+32*200+(304*116)+152,a1
 ; First we force the switch to all black pixels
var set 0 
 REPT 4
 and #%0101010101010101,var+304*0(a1)
 and #%0101010101010101,var+304*1(a1)
var set var+2 
 ENDR
 
 bsr NextPRN
 and #%1010101010101010,d0
 or d0,304*0(a1)
 or d0,304*1(a1)
 
.skip_switch_update
 rts 
 

 
 
; value, mask, destination 
TIMEBIT macro
 lsr.b \1
 bcc.s \@
 or #\2,\3
\@
 endm
 	
; 4 lines: 37/35/33/31 
; 6 colonnes: 530/532/535/537/540/542
; Scanline width=608/2=304 bytes
; Block starts at position 528=offset 264
; Global time is updated by the game-engine, "more or less" accurate :)
UpdateBinaryClock
 lea big_buffer_start+desktopoffice_depacked_picture+32*200+(304*31)+264,a1
 ; First we force the clock to all black pixels
var set 0 
 REPT 4
 and #%1111011110111101,var+608*0(a1)	;  .  .  .
 and #%1111011010110101,var+608*1(a1)	;  . .. ..
 and #%1101011010110101,var+608*2(a1)	; .. .. ..
 and #%1101011010110101,var+608*3(a1)	; .. .. ..
var set var+2 
 ENDR
 
 moveq #0,d4
 move.l d4,d5
 move.l d4,d6
 move.l d4,d7
   
 ; Seconds
 move.b time_seconds,d1
 TIMEBIT d1,%0000000000000010,d7
 TIMEBIT d1,%0000000000000010,d6
 TIMEBIT d1,%0000000000000010,d5
 TIMEBIT d1,%0000000000000010,d4
 TIMEBIT d1,%0000000000001000,d7
 TIMEBIT d1,%0000000000001000,d6
 TIMEBIT d1,%0000000000001000,d5
 
 ; Minutes
 move.b time_minutes,d2
 TIMEBIT d2,%0000000001000000,d7
 TIMEBIT d2,%0000000001000000,d6
 TIMEBIT d2,%0000000001000000,d5
 TIMEBIT d2,%0000000001000000,d4
 TIMEBIT d2,%0000000100000000,d7
 TIMEBIT d2,%0000000100000000,d6
 TIMEBIT d2,%0000000100000000,d5

 ; Hours
 move.b time_hours,d3
 TIMEBIT d3,%0000100000000000,d7
 TIMEBIT d3,%0000100000000000,d6
 TIMEBIT d3,%0000100000000000,d5
 TIMEBIT d3,%0000100000000000,d4
 TIMEBIT d3,%0010000000000000,d7
 TIMEBIT d3,%0010000000000000,d6
 
 ; Then we put then in blue :)
 or.w d4,2+608*0(a1)	;  .  .  .
 or.w d5,2+608*1(a1)	;  . .. ..
 or.w d6,2+608*2(a1)	; .. .. ..
 or.w d7,2+608*3(a1)	; .. .. ..
  
 rts

 
GenerateAtariDemoScrollBuffer  
 ; Generate the scroller 
 lea AtariDemoScroller,a0
 move.l #big_buffer_start+desktopoffice_demo_scroller,a2
.loop
 moveq #0,d0
 move.b (a0)+,d0
 beq .end

 lea depacked_font_8x8+32,a1
  
 ; Y
 move d0,d1
 lsr #4,d1
 mulu #64*8,d1	; *512
 add d1,a1
 
 ; X
 move d0,d1
 and #15,d1
 lsr #1,d1
 lsl #3,d1
 add d1,a1
 move d0,d1
 and #1,d1
 add d1,a1
 
var set 0 
 REPT 8
 move.b var*64(a1),var*256(a2)
var set var+1 
 ENDR
 
 addq #1,a2
 
 bra.s .loop
.end

 ; Then generate 16 shifted copies so we can do a fast distort
 ; (faster than using the blitter... by far)
 lea big_buffer_start+desktopoffice_demo_scroller,a0	; Source
 lea 256*8(a0),a1										; Destination
 moveq #16,d7
.loop_buffer 
 ; Start at the end of each buffer
 lea 256*8(a0),a0
 lea 256*8(a1),a1

 move.w #256*8/4,d6
.loop_bytes
 move.l -(a0),d0
 addx.l d0,d0
 move.l d0,-(a1)
 dbra d6,.loop_bytes

 lea 256*8(a0),a0
 lea 256*8(a1),a1
  
 dbra d7,.loop_buffer 
 rts
   
 
CreateSkyGradient
 ; Background gradient
 lea big_buffer_start+desktopoffice_buffer_gradient,a2
 move #25,d7
 
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

 lea big_buffer_start+desktopoffice_buffer_gradient,a0
 lea big_buffer_start+desktopoffice_depacked_picture,a1
 move #106-1,d0
.loop 
 move (a0)+,5*2(a1)
 lea 32(a1),a1
 dbra d0,.loop
 rts 
 
 
 SECTION DATA

 even
 
; Unpacked: 67200 (was 89600)
; Packed:   42552 
 FILE "deskofic.pik",picture_desktopoffice
  
 even

  
PackInfoOfficePicture 
 dc.l picture_desktopoffice
 dc.l big_buffer_start+desktopoffice_depacked_picture
 dc.l 67200

  
DesktopOfficeSequencer 
 SEQUENCE_SETPTR _AdrPartVblRoutine,DesktopOfficeVbl

 SEQUENCE_SUBTITLE <"So many colors at once, it nearly",13,"looks like an Amiga! Impressive no?">

 SEQUENCE_TEMPORIZE 50*4

 SEQUENCE_SUBTITLE <"">
 SEQUENCE_SETPTR _AdrDesktopOfficePlay,DesktopOfficeScrollRight

 SEQUENCE_TEMPORIZE 50*5

 SEQUENCE_SUBTITLE <"Nowadays, things are not that",13,"colorful anymore. Signs of maturity?">
 
 SEQUENCE_TEMPORIZE 50*4
  
 SEQUENCE_SUBTITLE <"">
 SEQUENCE_SETPTR _AdrDesktopOfficePlay,DesktopOfficeScrollLeft

 SEQUENCE_TEMPORIZE 50*5

 SEQUENCE_SUBTITLE <"But obviously some people still love",13,"the oldschool style.">
 
 SEQUENCE_TEMPORIZE 50*4
 SEQUENCE_SUBTITLE <"">


 SEQUENCE_SUBTITLE <"">
 SEQUENCE_SETPTR _AdrDesktopOfficePlay,DesktopOfficeScrollRight

 SEQUENCE_TEMPORIZE 50*5
  
 ifne enable_auto_skip
 SEQUENCE_GO_NEXT_PART	; And leave
 endc
 SEQUENCE_END
 
 even
 
 
AtariDemoScroller
 dc.b "           TIBS IS BACK WITH A NEW EFFECT: BACKGROUND GRADIENT-BOUNCING RASTERS-3 SCROLLING TEXTS-MAD MAX MUSIC. LET'S WRAP..."
 dc.b 0
 
 even

 
AtariDemoBounceTable
 dc.w 32*0
 dc.w 32*0
 dc.w 32*1
 dc.w 32*1
 dc.w 32*2
 dc.w 32*2
 dc.w 32*3
 dc.w 32*3
 dc.w 32*4
 dc.w 32*4
 dc.w 32*5
 dc.w 32*5
 dc.w 32*6
 dc.w 32*7
 dc.w 32*8
 dc.w 32*9
 dc.w 32*10
 dc.w 32*11
 dc.w 32*13
 dc.w 32*15
 dc.w 32*17
 dc.w 32*19
 dc.w 32*21
 dc.w 32*23
 dc.w 32*25
 dc.w 32*30
 dc.w 32*34
 dc.w 32*36
 dc.w 32*38
 dc.w 32*40
 dc.w 32*43
 dc.w 32*45
 dc.w 32*48
 dc.w 32*45
 dc.w 32*43
 dc.w 32*40
 dc.w 32*38
 dc.w 32*36
 dc.w 32*34
 dc.w 32*30
 dc.w 32*25
 dc.w 32*23
 dc.w 32*21
 dc.w 32*19
 dc.w 32*17
 dc.w 32*15
 dc.w 32*13
 dc.w 32*11
 dc.w 32*10
 dc.w 32*9
 dc.w 32*8
 dc.w 32*7
 dc.w 32*6
 dc.w 32*5
 dc.w 32*4
 dc.w 32*3
 dc.w 32*2
 dc.w 32*2
 dc.w 32*1
 dc.w 32*1
 dc.w 32*0
 dc.w 32*0
 dc.w 32*0
 dc.w 32*0
  
 
; 52 entries 
AtariDemoRasters
red   set 0
green set 0
blue  set 16

 MAKECOLOR 0,0,15
 MAKECOLOR 1,0,14
 MAKECOLOR 2,0,13
 MAKECOLOR 3,0,12
 MAKECOLOR 4,0,11
 MAKECOLOR 5,0,10
 MAKECOLOR 6,0,9
 MAKECOLOR 7,0,8
 MAKECOLOR 8,0,7
 MAKECOLOR 9,0,6
 MAKECOLOR 10,0,5
 MAKECOLOR 11,0,4
 MAKECOLOR 12,0,3
 MAKECOLOR 13,0,2
 MAKECOLOR 14,0,1
 MAKECOLOR 15,0,0
 
 MAKECOLOR 15,0,0
 MAKECOLOR 15,0,0
 MAKECOLOR 15,0,0
 MAKECOLOR 15,0,0
 MAKECOLOR 15,0,0
 MAKECOLOR 15,0,0

 MAKECOLOR 15,0,0
 MAKECOLOR 14,1,0
 MAKECOLOR 13,2,0
 MAKECOLOR 12,3,0
 MAKECOLOR 11,4,0
 MAKECOLOR 10,5,0
 MAKECOLOR 9,6,0
 MAKECOLOR 8,7,0
 MAKECOLOR 7,8,0
 MAKECOLOR 6,9,0
 MAKECOLOR 5,10,0
 MAKECOLOR 4,11,0
 MAKECOLOR 3,12,0
 MAKECOLOR 2,13,0
 MAKECOLOR 1,14,0
 MAKECOLOR 0,15,0
   
 MAKECOLOR 0,15,0
 MAKECOLOR 0,15,0
 MAKECOLOR 0,15,0
 MAKECOLOR 0,15,0
 MAKECOLOR 0,15,0
 
 MAKECOLOR 0,15,0
 MAKECOLOR 0,14,1
 MAKECOLOR 0,13,2
 MAKECOLOR 0,12,3
 MAKECOLOR 0,11,4
 MAKECOLOR 0,10,5
 MAKECOLOR 0,9,6
 MAKECOLOR 0,8,7
 MAKECOLOR 0,7,8
 MAKECOLOR 0,6,9
 MAKECOLOR 0,5,10
 MAKECOLOR 0,4,11
 MAKECOLOR 0,3,12
 MAKECOLOR 0,2,13
 MAKECOLOR 0,1,14
 MAKECOLOR 0,0,15
  
 MAKECOLOR 0,0,15
 MAKECOLOR 0,0,15
 MAKECOLOR 0,0,15
 MAKECOLOR 0,0,15
 MAKECOLOR 0,0,15
  
DesktopOfficeRastersTextWhite		dc.w $444,$555,$666,$777,$666,$555,$444,$333
DesktopOfficeRastersTextYellow		dc.w $440,$550,$660,$770,$660,$550,$440,$330
DesktopOfficeRastersTextCyan		dc.w $044,$055,$066,$077,$066,$055,$044,$033
  

 even
  
 SECTION BSS
 
   
 even

;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset
desktopoffice_fullscreen			rs.b Size_PanoramicRoutine_DisplayList
desktopoffice_depacked_picture		rs.b 67200
desktopoffice_demo_scroller			rs.b 256*8*16
desktopoffice_buffer_gradient		rs.w 200*16		; 200 scanlines, 2 bytes per color entry, 16 intensities (for the fade)
desktopoffice_scrolltext_pos 		rs.w 1
desktopoffice_rasters_pos			rs.w 1

 update_buffer_size
 

