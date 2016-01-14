  
 SECTION TEXT
 
 even
  
SubtitleClearBuffer
 movem.l a0/a1,-(sp)
 lea buffer_subtitles,a0					
 lea buffer_subtitles_end,a1 
 bsr MemoryClear					
 movem.l (sp)+,a0/a1
 rts

  
; a0=input text 
; a1=buffer destination
SubtitleDrawTextPtr
 move.l a1,character_buffer_base
 bra.s SubtitleDrawTextMain
; a0=input text 
SubtitleDrawText
 move.l #buffer_subtitles+160,character_buffer_base
SubtitleDrawTextMain 
 move #0,character_xpos
 move #0,character_ypos

 move blit_stride,-(sp)
 move #160,blit_stride
 lea FontSubtitles,a6
 bsr CharacterDrawText
 move (sp)+,blit_stride
 rts
  
  
SubtitleMapFont
 ; Depack fonts
 lea PackInfoFontSmall,a0
 moveq #3,d0
 bsr DepackBlockMulti
 
 ; Compute the pointers to fonts+width
 lea FontSubtitles,a6
 bsr ComputeCharactersAdressMapFromBitmap

 ; Install 6x6 font  
 lea FontSmall,a6
 bsr ComputeCharactersAdressMapFromBitmap
 rts 
   
 
SubtitleInit
 move #0,character_xpos
 move #0,character_ypos
 rts
 
 
 ifne enable_debug_text
 
; d0=value to display 
DebugPrintValue
 lea ValueBufferEnd,a0
 lea HexDigits,a1
 move.b #0,-(a0)		; Null terminator for the string
.loop
 move.b d0,d1
 and #15,d1
 move.b (a1,d1),-(a0)
 lsr.l #4,d0
 bne.s .loop  
 bsr DebugPrintString
 rts 
  
ValueBuffer		ds.b 20
ValueBufferEnd	ds.b 1
 
 even
  
; a0=zero terminated string 
DebugPrintString
 moveq #0,d0
.loop_next_car 
 move.b (a0)+,d0
 beq.s .done
 cmp.b #13,d0
 beq.s .carriage_return
 bsr DebugPrintChar
 bra.s .loop_next_car 
 
.carriage_return
 move #0,character_xpos
 add #1,character_ypos
 bra.s .loop_next_car 

.done 
 rts 
 
 
; d0=current character 
DebugPrintChar
 ; Character adress
 lea depacked_font_8x8+32,a1
 ; Y
 move d0,d1
 lsr #4,d1
 mulu #64*8,d1
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
 
 
 ; Y
 lea buffer_subtitles+160,a2		; Skip the first line of the buffer
 move character_ypos,d1
 mulu #160*8,d1
 add d1,a2
 
 ; X
 move character_xpos,d1
 lsr #1,d1
 lsl #3,d1
 add d1,a2
 move character_xpos,d1
 and #1,d1
 add d1,a2

var set 0 
 REPT 8
 move.b var*64(a1),var*160(a2)
var set var+1 
 ENDR
  
 add #1,character_xpos
 rts
  
 endc
 
 
 SECTION DATA
	
; Unpacked: 15320
; Packed:    7578
 FILE "font_sub.pik",font_subtitles_packed
  
; Unpacked:  6304
; Packed:    1362
; 256x49 pixels 
 FILE "font_6x6.pik",font_6x6_packed
  
; Unpacked:  4128
; Packed:    1049
 FILE "font_8x8.pik",font_8x8_packed
 
 
FontSubtitles
 dc.l font_subtitles+32
 dc.l CommonCharacterList
 dc.l font_subtitles_mapping
 dc.l font_subtitles_width
 dc.w 21
 dc.w 104
 dc.w 104*21
 dc.w 8
 dc.w 0		; No extra pixel between characters
 dc.w 8		; 8 pixels for the space
  
FontSmall
 dc.l font_6x6+32
 dc.l AtasciiCharacterList
 dc.l font_6x6_mapping
 dc.l font_6x6_width
 dc.w 7
 dc.w 128
 dc.w 128*7
 dc.w 8
 dc.w 1		; Add one extra pixel to separate characters
 dc.w 3		; 4 pixels for the space

; These 3 should stick together, depacked using multidepack 
PackInfoFontSmall
 dc.l font_6x6_packed
 dc.l font_6x6
 dc.l 6304 
PackInfoFontSubtitles
 dc.l font_subtitles_packed
 dc.l font_subtitles
 dc.l 15320 
PackInfoFontSystem
 dc.l font_8x8_packed
 dc.l depacked_font_8x8
 dc.l 4128 
   
 SECTION BSS
  
 even

buffer_subtitles 			ds.l (160*50)/4	; 50 lines - about 8000 bytes
buffer_subtitles_end

font_subtitles				ds.l 15320/4	; Not a part of the big BSS buffer because used in all parts
font_subtitles_mapping		ds.l 256		; Each entry points to the bitmap for this character (or 0 for non existing characters)
font_subtitles_width		ds.w 256		; Width in pixels for each character

font_6x6					ds.l 6304/4
font_6x6_mapping			ds.l 256		; Each entry points to the bitmap for this character (or 0 for non existing characters)
font_6x6_width				ds.w 256		; Width in pixels for each character

 
depacked_font_8x8			ds.b 4128

 even
 
 
 