
; Normal scanline:     		160 bytes
; STE Fullscreen scanline: 	208 bytes 
; STF Fullscreen scanline: 	230 bytes
; Extend scanline:     		256 bytes
;
; Panoramic modes:
; 160*200=32000
; 208*200=41600
; 230*200=46000
; 256*200=51200
;
; Fullscreen modes:
; 208*313=65104
;
; Subitles:
; 160*50=8000 (stored in subtitle.s)
;
; Size for 4 screens:
; 208*200*4=41600*4=166400


 SECTION TEXT
 
 even
 
FullStart
 


; 
; Display list related code
; 
; a0=screen adress (*256 + pixelshift in low byte)
; a1=palette adress
; a2=display list pointer
; d0=screen increment (*256)
; d1=palette increment
;
DisplayListInit200
 REPT 67
 move.l a0,(a2)+
 move.l a1,(a2)+
 add.l d0,a0
 add.l d1,a1
 ENDR
DisplayListInit133
 REPT 33
 move.l a0,(a2)+
 move.l a1,(a2)+
 add.l d0,a0
 add.l d1,a1
 ENDR
DisplayListInit100
 REPT 50
 move.l a0,(a2)+
 move.l a1,(a2)+
 add.l d0,a0
 add.l d1,a1
 ENDR
DisplayListInit50
 REPT 25
 move.l a0,(a2)+
 move.l a1,(a2)+
 add.l d0,a0
 add.l d1,a1
 ENDR
DisplayListInit25
 REPT 25
 move.l a0,(a2)+
 move.l a1,(a2)+
 add.l d0,a0
 add.l d1,a1
 ENDR
 rts

; a0=screen adress
; a1=palette 
DisplayListInitStatic
 lea DisplayList,a2
 REPT 200
 move.l a0,(a2)+
 move.l a1,(a2)+
 ENDR
 rts
 
DisplayListInitBlack
 move.l #empty_line,d0
 move.l d0,a1			; Palette
 lsl.l #8,d0
 move.l d0,a0			; Screen
 lea DisplayList,a2
 moveq #0,d0
 moveq #0,d1
 bsr DisplayListInit200
 rts
 


 
; Using the template data, we generate the fullscreen
; a0=template buffer
; a1=destination buffer
;
; Format of the template buffer:
; - Header
; .b timer A delay value
; .b timer A divider value
; .l Adress of the Timer routine
; - Scanline description
; .w count
; .w size
; .w adress
; Null count means that the generation is done
GenerateOverscan
 move.l a1,_AdrFullRoutine
  
 movem.l d0-a6,-(sp)
 move.b (a0)+,timera_delay
 move.b (a0)+,timera_div
 
 move #$2700,sr	; Disable interrupts
 move.l (a0)+,$134.w				; timer a vector
 bset #5,$fffffa07.w				; iera: enable timer A
 bset #5,$fffffa13.w				; imra: enable timer A
 bclr #3,$fffffa17.w				; vr: automatic end of interrupt

 clr.b	$fffffa19.w					; stop timer a
 move #$2300,sr	; Enable interrupts
 
.loop_entry
 move.w (a0)+,d0	; count
 beq.s .done
 subq #1,d0			; for the dbra
 move.w (a0)+,d1	; size (in word -1)
 move.l (a0)+,a2	; source adress
.loop_copy_count
 move d1,d2			; copy size
 move.l a2,a3		; copy adress
.loop_copy_line
 move.w (a3)+,(a1)+ 
 dbra d2,.loop_copy_line
 dbra d0,.loop_copy_count
  
 bra.s .loop_entry
.done 
 ; Force black display list
 bsr DisplayListInitBlack

 ; Setup the timers 
 move #$2700,sr	; Disable interrupts
 move.l #DummyHbl,$68.w				; Used in the timer to synchronize on the hbl interrupt
 move.l #FullTimerVbl,$70.w			; vbl vector
 move #$2300,sr	; Enable interrupts
 
 movem.l (sp)+,d0-a6
 rts

 
DummyHbl
 rte

 
 
TerminateFullscreenTimer
 move #$2700,sr						; Disable interrupts
 move.l #routine_vbl_nothing,$70.w
 clr.b $fffffa19.w					; stop timer a
 
 movem.l black_palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 movem.l d0-d7,palette_vbl_fade

 move.l #DummyRoutine,_AdrPartVblRoutine
  
 move #$2300,sr						; Enable interrupts
 rts

 
; 0-200 
; 245/7 for 50hz interrupt (7=prediv 200) 
; 150/5 for normal screen sync
;  99/4 for top border (4=prediv 50)
FullTimerVbl
 clr.b	$fffffa19.w					; timer-a setup
 move.b	timera_delay,$fffffa1f.w	; tadr: delay
 move.b	timera_div,$fffffa19.w		; tacr: divider
 
;_AdrFullTimerDelay=*+2 
; move.b	#123,$fffffa1f.w			; tadr: delay
; nop
;_AdrFullTimerDiv=*+2 
; move.b	#123,$fffffa19.w			; tacr: divider
; nop

 ifne enable_music
 COLORHELP #$730
_AdrMusicVblRoutine=*+2
 jsr DummyRoutine
 ;bsr PlayMusic
 COLORHELP #$000
 endc

  ifne enable_colorhelpers
 move.w #$200,$ffff8240.w			; Dark red
  else
 move.w #$000,$ffff8240.w			; Black (4)
  endc
 rte 
  
 
FullOverscanTimer
 opt o-
 
 pause 41
 
 move.w	#$2100,sr			; Wait for the next hardware HBL
 stop #$2100
 
 move.w	#$2700,sr			; Disable interrupts
 clr.b $fffffa19.w			; stop timer a
  
 movem.l d0-a6,-(sp)
 pause 52-2-2-3-3-4
 
 lea $ffff8260.w,a0    		; 8/2 resolution 
 lea $ffff820a.w,a1    		; 8/2 frequence
 
 lea shifter_data,a4		; 12/3
 move.l (a4)+,d4			; 12/3 screen adress
 move.l (a4)+,d6			; 12/3 screen stride
  
 move.b	#0,$ffff820a.w		; remove top border
 pause 9
 move.b	#2,$ffff820a.w
 
 bra.s SyncOverscan			; 12/3
 
PanoramicTimer
 clr.b	$fffffa19.w			; stop timer a
 move #$2700,sr				; Disable interrupts
  ifne enable_colorhelpers
 move.w #$070,$ffff8240.w	; Green
  endc
 movem.l d0-a6,-(sp)
 
 lea $ffff8260.w,a0    		; 8/2 resolution 
 lea $ffff820a.w,a1    		; 8/2 frequence
 
 bra.s SyncOverscan		; 12/3

 nop
 
SyncOverscan 
  opt o-

 ; STE hardware compatible synchronization code
 move.b #0,$ffff8209.w
 
 moveq #16,d2
.wait_sync
 move.b $ffff8209.w,d0
 beq.s .wait_sync
 sub.b d0,d2
 lsl.b d2,d0
 
 ; Fullscreen routine
 pause 96-11-5-64
  
 ; jsr=20/5
_AdrFullRoutine=*+2
 jsr $12345678
  
 ; Put back the border in black at the end (cinemascope effect)
 move.w #$000,$ffff8240.w 
  
 ; Finished :)
 opt o+

 ; Set the correct palette for the subtitle area
 movem.l font_subtitles,d0-d7
 movem.l d0-d7,$ffff8240.w
 
 bsr ComputeVideoParameters
 bsr CommonVblSubRoutine
  
 
  ifne enable_colorhelpers
 move.w #$002,$ffff8240.w	; Dark Blue
  endc
 movem.l (sp)+,d0-a6
 rte 
 

  

; Code generation part --------------------------



; *1
; Used registers:
; - a0 = fullscreen
; - a1 = fullscreen
; - a2 = display list pointer
; - a3 = palette pointer
; - a6 = hardware palette ($ffff8240)
; - d0 = fullscreen
; - d1 = screen adress parameters
PanoramicRoutine_DisplayList_Prolog
 lea $ffff8240.w,a6			; 8/2
 pause 64-2-9-19-7
 
 lea DisplayList,a2			; 12/3
 move.l (a2)+,d1			; 12/3 (adress + offset)
 move.l (a2)+,a3			; 12/3
 ; -> 3+3+3=9
 
 ; Load the first palette
 movem.l (a3)+,d2/d3/d4/d5/d6/d7/a4/a5		; 12+8*8=12+64=76/19
 movem.l a4/a5,24(a6)						; 12+8*2=12+16=28/7
 
.end 
PanoramicRoutine_DisplayList_Prolog_Size equ .end-PanoramicRoutine_DisplayList_Prolog

  
; *199
PanoramicRoutine_DisplayList_Line
 ; **** Left ****
 pause 11-3-6
 movep.l d1,-5(a1)		; (6) $ffff8205/07/09/0B
 move.b d1,91(a1)		; (3)
 
 ; Left Border
 move.w a0,(a0)   		; 8/2 (Resolution=high [a0=$ffff8|2|60])
 move.b d0,(a0)   		; 8/2 (Resolution=low [d0=0] )
 
 ; Change the colors
 movem.l d2/d3/d4/d5/d6/d7,(a6)	; 8+8*6=8+48=56/14
 
 move.l (a2)+,d1		; 12/3
 move.l (a2)+,a3		; 12/3
 
 ; Load the next palette
 movem.l (a3)+,d2/d3/d4/d5/d6/d7/a4/a5		; 12+8*8=12+64=76/19
 
 pause 91-14-3-3-19
  
 ; Right border
 move.b d0,(a1)   		; 8/2 (Frequence=60hz [d0=0])
 move.w a0,(a1)   		; 8/2 (Frequence=50hz [a0=$ffff8|2|60])
 
 pause 18-7
 movem.l a4/a5,24(a6)	; 12+8*2=12+16=28/7
.end 
PanoramicRoutine_DisplayList_Line_Size equ .end-PanoramicRoutine_DisplayList_Line
 
; Free time per scanline:
; 
; pause 11-3-6      =2
; pause 91-14-3-3-19=52
; pause 18-7        =11
; ->65 nops
; 65*200=13000 nops = 52000 cycles = 32.44% of cpu time free


  
; *1
Panoramic_DisplayList_Epilog
 ; Bottom border switch
 move.b d0,(a1)   			;8/2 Low border start
 move.w #$000,$ffff8240.w	;16/4
 pause 10-4
 move.w a0,(a1)   			;8/2 Low border end
 
 move.l #buffer_subtitles,d4
 moveq #0,d5
 move.b d5,91(a1)		; (3)
 movep.l d4,-7(a1)		; (6) $ffff8203/05/07/09
 rts  
.end 
Panoramic_DisplayList_Epilog_Size equ .end-Panoramic_DisplayList_Epilog


    

    

; Prolog routine
; *1
FullTemplate_NoColorChange_Prolog
 pause 64-48
 
 ; Change the entire palette before the screen starts, finishing by the color 0
 lea palette_vbl_fade+4,a4	; 12/3
 lea ($ffff8240+4).w,a5	    ; 8/2
 move.l (a4)+,(a5)+    		; 20/5
 move.l (a4)+,(a5)+    		; 20/5
 move.l (a4)+,(a5)+    		; 20/5
 move.l (a4)+,(a5)+    		; 20/5
 move.l (a4)+,(a5)+    		; 20/5
 move.l (a4)+,(a5)+    		; 20/5
 move.l (a4)+,(a5)+    		; 20/5
 move.l palette_vbl_fade,$ffff8240.w	; 32/8
 ; -> 3+2+(5*7)+8=3+2+35+8=48
.end 
FullTemplate_NoColorChange_Prolog_Size equ .end-FullTemplate_NoColorChange_Prolog
 

; Standard fullscreen routine
; *228
FullTemplate_NoColorChange_Line
 pause 11-3-6
 movep.l d4,-5(a1)		; (6) $ffff8205/07/09/0B
 move.b d4,91(a1)		; (3)
 
 ; Left Border
 move.w a0,(a0)   		;8/2
 move.b d0,(a0)   		;8/2
 
 add.l d6,d4			; 2
 pause 91-2
  
 ;  Right border
 move.b d0,(a1)   		;8/2
 move.w a0,(a1)   		;8/2
 
 pause 18
.end
FullTemplate_NoColorChange_Size equ .end-FullTemplate_NoColorChange_Line
  

; Bottom border switch
; *1
FullTemplate_NoColorChange_BottomSwitch
 pause 11-3-6-2
 movep.l d4,-5(a1)		; (6) $ffff8205/07/09/0B
 move.b d4,91(a1)		; (3)
 
 ; Left Border
 move.b d0,(a1)   		;8/2 Low border start
 move.w a0,(a0)   		;8/2
 move.b d0,(a0)   		;8/2
 move.w a0,(a1)   		;8/2 Low border end
 
 add.l d6,d4			; 2
 pause 91-2-2
  
 ; Right border
 move.b d0,(a1)   		;8/2
 move.w a0,(a1)   		;8/2
 
 pause 18
.end
FullTemplate_NoColorChange_BottomSwitch_Size equ .end-FullTemplate_NoColorChange_BottomSwitch
 


; Set the buffer to the subtitles to avoid glitches 
; *1
FullTemplate_NoColorChange_Epilog
 move.l #buffer_subtitles,d0
 movep.l d0,-7(a1)				; 24/6 $ffff8203/05/07/09
 move.b #0,91(a1)				; 12/3 $ffff8265 (Pixel skip)
 rts
.end  
FullTemplate_NoColorChange_Epilog_Size equ .end-FullTemplate_NoColorChange_Epilog
 
 

      

FullEnd 
 
 SECTION DATA

 even
  
; Count, Start Adress, Size
FULLTEMPLATE macro
count set \1 
size  set \3
 dc.w count,(size/2)-1
 dc.l \2
fullroutinesize set fullroutinesize+(count*size)
 endm
 
fullroutinesize set 0
 
;
; The full full routine, no color change, used by:
; - TV Snow effect
;
FullTemplateList_Fullscreen
 dc.b 99,4
 dc.l FullOverscanTimer
 FULLTEMPLATE 1,FullTemplate_NoColorChange_Prolog,FullTemplate_NoColorChange_Prolog_Size
 FULLTEMPLATE 228,FullTemplate_NoColorChange_Line,FullTemplate_NoColorChange_Size
 FULLTEMPLATE 1,FullTemplate_NoColorChange_BottomSwitch,FullTemplate_NoColorChange_BottomSwitch_Size
 FULLTEMPLATE 38,FullTemplate_NoColorChange_Line,FullTemplate_NoColorChange_Size
 FULLTEMPLATE 1,FullTemplate_NoColorChange_Epilog,FullTemplate_NoColorChange_Epilog_Size
 dc.w 0	; End marker
Size_Fullscreen equ fullroutinesize

 
;
; The panoramic routine, using advanced display list, used by:
; - Piracy
; - Cinemascope display
; - Defence Force logo
; - Night city
; - Insert Disk
; - Desktop Office
; - Motherboard
; - Chatroom
; - Out Run
; - Credits
;
fullroutinesize set 0
PanoramicTemplate_DisplayList
 dc.b 150,5
 dc.l PanoramicTimer
 FULLTEMPLATE 1,PanoramicRoutine_DisplayList_Prolog,PanoramicRoutine_DisplayList_Prolog_Size 
 FULLTEMPLATE 199,PanoramicRoutine_DisplayList_Line,PanoramicRoutine_DisplayList_Line_Size
 FULLTEMPLATE 1,Panoramic_DisplayList_Epilog,Panoramic_DisplayList_Epilog_Size
 dc.w 0	; End marker
Size_PanoramicRoutine_DisplayList equ fullroutinesize


 even
  

TableShifterShift
var set 0
 REPT 512
 dc.b (var>>4)<<3	; Adress 
 dc.b var&15		; Pixelshift
var set var+1 
 ENDR


 
 SECTION BSS
 
 even

timera_delay	ds.b 1
timera_div 		ds.b 1
 
; Various types of contents in a Display List:
; - Line adress (4) + pixel shift (1->2)
; - Palette pointer (4)

  
DisplayList_Top	ds.b 200*(4+4)	; Security crap
DisplayList		ds.b 200*(4+4)	; Screen Pointer + Pixel offset + Palette adress, for each line
 				ds.b 200*(4+4)	; Security crap
	 
 even
 
 ;
 ; Restore compiler optimizations
 ;
 opt o+

  
  