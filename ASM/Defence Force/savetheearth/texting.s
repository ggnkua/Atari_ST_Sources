 
;
; Font description
;
 rsreset
font_address	rs.l 1	; Location of the bitmap data containing the pixels of the font
font_charset	rs.l 1  ; Points to a table the the list of all characters used in the font
font_mapping	rs.l 1	; Points to a table with the adress of individual characters in the bitmap
font_width		rs.l 1	; Points to a table with the width in pixels of each characters
font_height		rs.w 1	; Height in pixel of one character
font_stride		rs.w 1  ; Width in bytes of a scanline
font_v_stride	rs.w 1	; How much to skip to go to the next line of characters
font_h_stride	rs.w 1	; How many bytes to skip to the next character in the same row
font_spacing	rs.w 1  ; How many pixels should be added between each character
font_space_size	rs.w 1	; Size in pixels of the default space
 
 SECTION TEXT
 
 even

; 
; This routine compute the adress of each character in a picture,
; and stores it in an array provided by the caller.
; 
; a6=pointer on the font description bloc
ComputeCharactersAdressMapFromBitmap
 movem.l d0/d1/d2/a0/a1/a2/a3,-(sp)
 
 ; a0=list of characters to map
 ; a1=destination buffer
 ; a2=adress of the font to map
 ; d0=bytes to skip to go to the next character on the same row
 ; d1=stride between two rows of characters
 move.l font_address(a6),a2
 move.w font_h_stride(a6),d0 
 move.w font_v_stride(a6),d1
 move.l font_mapping(a6),a1 
 move.l font_charset(a6),a0 

 ; Clear the existing mappings
 move.l a1,a3
 move.w #256-1,d2
.loop_erase
 clr.l (a3)+
 dbra d2,.loop_erase

 ; Compute the new mappings
 move.l a2,a3
.loop
 moveq.l #0,d2
 move.b (a0)+,d2
 beq.s .end
 cmp.b #13,d2
 beq.s .newline
 add d2,d2
 add d2,d2
 move.l a3,(a1,d2.w)
 add.w d0,a3
 bra.s .loop 
 
.newline
 add d1,a2 
 move.l a2,a3
 bra.s .loop 
 
.end 
 movem.l (sp)+,d0/d1/d2/a0/a1/a2/a3
 
 ; And get the table with the character width
 ; Todo: This could be computed at the same time the mapping is done instead of two passes
 move.w font_spacing(a6),d4
 move.w font_stride(a6),d3
 move.w font_height(a6),d0
 move.l font_width(a6),a1
 move.l font_mapping(a6),a0

; a0=table of character adresses
; a1=table where the computed width are stored
; d0=height of a character
.ComputeCharacterWidth
 movem.l d0-a6,-(sp)
 
 move d0,d6
 subq #1,d6
 
 move #256-1,d7
.loop_compute_width
 move font_space_size(a6),d0	; Default width = space
 move.l (a0)+,d1				; Get the adress
 beq.s .no_character
 
 ; Compute the bitmask vertically to find the printout of the character
 move.l d1,a2
 moveq #0,d1
 move d6,d5
.vertical_loop 
 or.l 0(a2),d1
 or.l 4(a2),d1
 add d3,a2
 dbra d5,.vertical_loop 
 
 move d1,d2
 swap d1
 or d2,d1
 beq.s .done
 
 ; Use the mask to find where the least significant bit is,
 ; for each zero found, we reduce the size of the character by one
 moveq #16,d0
.search_widtch
 lsr #1,d1
 bcs.s .done
 subq #1,d0
 bra.s .search_widtch
.done
 add d4,d0						; Additional inter-character spacing
 
.no_character
 move.w d0,(a1)+				; Store the width 
 dbra d7,.loop_compute_width
 
 movem.l (sp)+,d0-a6
 rts
  

  
; a0=message
; a1=screen location
; a6=pointer on the font description bloc
CharacterDrawText
.loop_draw
 moveq.l #0,d0
 move.b (a0)+,d0	; Get the current character
 beq.s .end
 cmp.b #13,d0
 beq.s .newline
 cmp.b #'_',d0
 beq.s .variable_space
 bsr CharacterDraw
 bra.s .loop_draw
 
.variable_space
 moveq #0,d0
 move.b (a0)+,d0
 add d0,d0				; x2
 add d0,character_xpos
 bra.s .loop_draw
  
.newline 
 move #0,character_xpos
 add #21,character_ypos
 bra.s .loop_draw
  
.end 
 rts
 

    
; d0=character index
; a6=pointer on the font description bloc
CharacterDraw
 movem.l d0-a6,-(sp)
 ; a2=mapping table
 ; a3=width mapping
 move.l font_mapping(a6),a2 
 move.l font_width(a6),a3
 
 and #255,d0
 add d0,d0
 move.w (a3,d0.w),d5				; Character width
 add d0,d0
 move.l (a2,d0.w),a0				; Sprite adress
 cmp.l #0,a0
 beq.s .end
  
 move character_xpos,d0
 move character_ypos,d1
 bsr ComputeScreenOffset
 move.l character_buffer_base,a1	; Destination
 add.l d2,a1						; +actual offset
    
 move.l #0,a2						; No mask
 move.w #1,d0						; Width (Letters are 16 pixels wide=1 word)
 move.w font_height(a6),d1			; Height (7 or 21 pixels high)
 move font_stride(a6),d2			; Source offset
 move blit_stride,d3				; Destination offset
 move character_xpos,d4				; Pixel offset
 and #15,d4
 
 tst.b character_wait_vbl
 beq.s .no_vbl_test
 bsr WaitVbl
.no_vbl_test 
 bsr BlitterDrawSprite

.end 
 add d5,character_xpos
 movem.l (sp)+,d0-a6
 rts 

;
; the _ characters are followed by the number of pixels to skip.
; We search the ones with a null number, and we use that to compute
; the "padding" value to get the full line lenght
;
; a0=pointer on text 
; a1=mapping table for width
; d0=max size of a line
ComputeCharacterJustification
 movem.l d0-a6,-(sp)
 
 move.l sp,a6
 
 move.l d0,d7			; Max size for a line
.restart_line 
 move.l a0,a2
 move.l a0,a3
.next_line 
 moveq #0,d6			; Computed width for this line
 moveq #0,d5			; Number of wide characters found so far
.loop_line 
 cmp.l d6,d7
 blt.s .line_too_long
 moveq #0,d0
 move.b (a2)+,d0		; Get the character
 beq.s .endoftext		; End of text ?
 cmp.b #13,d0			; End of line ?
 beq.s .newline
 cmp.b #' ',d0			; Space ?
 beq.s .fixe_space
 cmp.b #'_',d0			; Variable space ?
 beq.s .variable_space
 
 ; Normal character
.compute_width 
 add d0,d0
 add.w (a1,d0.w),d6		; Add to this line's width
 
 bra.s .loop_line 
 
.done 
 move.l a6,sp
 movem.l (sp)+,d0-a6
 rts 
 
.line_too_long
 move.b #13,(a3)	; Replace the space by a carriage return
 bra.s .restart_line 
  
.fixe_space
 move.l a2,a3		; Store the current space adress to be able to patch it later on
 subq #1,a3
 bra.s .compute_width
 
.variable_space
 move.b (a2)+,d0	; Get the width
 cmp.b #'_',d0		; Variable space ?
 beq.s .free_slot
 add.w d0,d0		; x2
 add.w d0,d6		; Add to this line's width
 bra.s .loop_line 

.free_slot
 addq #1,d5			; One more free slot for this line
 add.w 32*2(a1),d6	; Add the default size of the space to this line
 move.l a2,-(sp)	; Store the pointer
 bra.s .loop_line 
    
; If d0=0 means end of text
.endoftext 
.newline
 tst d5
 beq.s .no_variable_space
 
 move.l d7,d4
 sub.l d6,d4	; Number of missing pixels
 lsr d4
 move.l d4,d3
 divu d5,d3		; Number of missing pixels to add to each entry
.loop_patch_spaces
 subq #1,d5
 beq.s .last_patch 
 move.l (sp)+,a4
 move.b d3,-1(a4)
 sub d3,d4
 bra.s .loop_patch_spaces
.last_patch 
 move.l (sp)+,a4
 move.b d4,-1(a4)
 
.no_variable_space 
 tst.b d0
 beq.s .done
 move.l a2,a0		; Point on the next line
 move.l a2,a3
 subq #1,a3
 bra .next_line 
 
 
 SECTION DATA

AtasciiCharacterList
 dc.b " !",34,"#$%&'()*+,-./",13
 dc.b "0123456789:;<=>?",13
 dc.b "@ABCDEFGHIJKLMNO",13
 dc.b "PQRSTUVWXYZ[\]^_",13
 dc.b "`abcdefghijklmno",13
 dc.b "pqrstuvwxyz{|}~",13
 dc.b 128,129,130,131		; arrow up, down, right, left
 dc.b 132,133,134,135		; close, expand, maximize, check
 dc.b 136,137,138			; time, bell, note
 dc.b 139,140				; FF, CR
 dc.b 141					; Fuji
 dc.b 142,143				; Smoker
 dc.b 0
  
CommonCharacterList
 dc.b "ABCDEFGHIJKLM",13
 dc.b "NOPQRSTUVWXYZ",13
 dc.b "abcdefghijklm",13
 dc.b "nopqrstuvwxyz",13
 dc.b "ÅÆØåæøéèëêçà:",13
 dc.b ".,;?!©&@ ()-/",13
 dc.b "0123456789'",34,13	; 34=double quote
 dc.b 0
 
 even 
	

 SECTION BSS
  
 even

character_buffer_base 		ds.l 1
character_xpos				ds.w 1
character_ypos				ds.w 1
character_wait_vbl			ds.b 1

 even
 


 