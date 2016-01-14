;
; Assuming the credits are stored in two bitplans, we have a buffer that takes
; 208 bytes per line /2 -> 104 bytes (52 half words)
;
; The largest nop sequence is 91 nops per scanline
;
; 

FONT_HEIGHT			set 21
LINE_COUNT			set 10
MAX_CHAR_PER_FRAME	set 4

FONT_LEFT_OFFSET	set 20
FONT_LINE_WIDTH		set 380	; 416-20-20

 
 SECTION TEXT
 
 even

     
CreditsInit
 ifne enable_music
 lea music,a0
 bsr StartMusicIfNotStarted
 endc

 ; Depack the OCR font
 lea PackInfoCreditFont,a0
 bsr DepackBlock
 
 lea PackInfoAtari,a0
 bsr DepackBlock
 
 move.l #big_buffer_start+credits_screen,ptr_scr_1
 
 bsr CreditsMapFont

 ; Compute the justification for the scroller 
 lea CreditsMessage,a0
 lea big_buffer_start+credits_character_width,a1
 move #FONT_LINE_WIDTH,d0
 bsr ComputeCharacterJustification
  
 move.l #big_buffer_start+credits_screen+((LINE_COUNT*FONT_HEIGHT)+0)*208,character_buffer_base
 move.l #big_buffer_start+credits_screen,big_buffer_start+credits_top_line
 
 move.l #CreditsMessage,big_buffer_start+credits_current_position
 
 move #0,pos_scr_y						; Set the screen to the top line of the first buffer
 move #FONT_LEFT_OFFSET,character_xpos
 move #0,character_ypos					; We use the buffer adress instead of Y pos
 move #0,big_buffer_start+credits_sub_ypos				; From 0 to 21, allows to know when to go to next text line
 move #0,big_buffer_start+credits_sub_line_count			; From 0 to 
 
 move.l #CreditsPlayScroller,_AdrPartCredits
  
 ; Picture palette
 lea black_palette,a0
 lea big_buffer_start+credits_depacked_font,a1
 moveq #16,d7
 bsr ComputeGradient

 ; Using the template data, we generate the fullscreen
 lea PanoramicTemplate_DisplayList,a0
 lea big_buffer_start+credits_fullscreen,a1
 bsr GenerateOverscan
 rts
 
 
CreditsPlay
_AdrPartCredits=*+2
 jsr DummyRoutine
 rts
  

CreditsTerminate
 bsr TerminateFullscreenTimer

 ; Stops the music 
 ifne enable_music
 bsr StopMusic
 endc
 
 ; 3 seconds of black at the very end before quitting.
 move.w #50*3,d0
 bsr WaitDelay
 rts
 
 
CreditsPlayAtariLogo
 move.l #big_buffer_start+credits_depacked_atari,d0
 move.l d0,a1
 add.l #32*200,d0
 lsl.l #8,d0
 move.l d0,a0

 lea DisplayList,a2										; Target display list
 move pos_scr_y,d0
 lsl #3,d0
 add d0,a2
  
 move.l #208*256,d0
 move.l #32,d1 
 bsr DisplayListInit200

 subq.w #1,pos_scr_y
 bne.s .continue
 move.l #CreditsPlayAtariLogoWait,_AdrPartCredits
 move.w #50*8,big_buffer_start+credits_delay
.continue 
 rts
   
 
CreditsPlayAtariLogoWait
 subq.w #1,big_buffer_start+credits_delay
 bne.s .continue
 
 lea DisplayList,a0
 lea big_buffer_start+credits_displaylist,a1
 move.w #200-1,d7
.loop
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 dbra d7,.loop
  
 move.l #CreditsPlayAtariLogoShrink,_AdrPartCredits 
 move.w #200,big_buffer_start+credits_logo_size
 
.continue
 rts 
 
 
 
 
CreditsPlayAtariLogoShrink
 ; Black picture
 bsr DisplayListInitBlack
  
 ; Start of display list around the middle line
 lea DisplayList+100*8,a2
 move.w big_buffer_start+credits_logo_size,d0
 lsr.w d0
 lsl.w #3,d0
 sub.w d0,a2

 ; Zoom factor 
 move.l #$00000,d0 	; Start value
 move.l #1,d1		; increment
 mulu #200,d1
 lsl.l #8,d1
 divu big_buffer_start+credits_logo_size,d1
 ext.l d1		; Flush the top word
 lsl.l #8,d1
  
 ; Draw from d1 to d2
 lea big_buffer_start+credits_displaylist,a0
 move.w big_buffer_start+credits_logo_size,d7
 subq #1,d7
.loop
 swap d0
 move d0,d2
 swap d0
 add.l d1,d0
 
 lsl #3,d2
 lea (a0,d2.w),a1
 move.l 0(a1),(a2)+
 move.l 4(a1),(a2)+
 dbra d7,.loop
 
 subq #4,big_buffer_start+credits_logo_size
 beq.s .done
 rts
.done 
 st.b flag_end_part 
 rts
  

   
 
CreditsPlayScroller
 bsr.s CreditsUpdate
 bsr.s CreditsSetScreen
 rts 
 
CreditsSetScreen
 ; Update the display list to point on the correct screen adress
 move pos_scr_y,d1
 mulu #208,d1
 add.l #big_buffer_start+credits_screen,d1
 lsl.l #8,d1
 move.l d1,a0
 
 lea palette_vbl_fade,a1
 lea DisplayList,a2
 move.l #208*256,d0
 moveq #0,d1
 bsr DisplayListInit200
 rts 
   
CreditsUpdate
 addq #1,pos_scr_y
 addq #1,big_buffer_start+credits_sub_ypos

 ; On first call, erase the 21 lines
 cmp #1,big_buffer_start+credits_sub_ypos
 bne .print_line

  
 ; Clear the 21 lines after that one...
 move.l character_buffer_base,a0
 lea (FONT_HEIGHT)*208(a0),a0
 ; 208*21=4368 bytes to erase
 movem.l black_palette,d0-d7/a2-a6		; 8+5=13*4=52 bytes with 0's inside
 REPT 4*FONT_HEIGHT
 movem.l d0-d7/a2-a6,-(a0)
 ENDR
 
 rts
 
.print_line

 moveq #MAX_CHAR_PER_FRAME,d1
.loop
 move.l big_buffer_start+credits_current_position,a0
 move.b (a0)+,d0	; Get the current character
 beq.s .done
 cmp.b #13,d0
 beq.s .new_line
 cmp.b #'_',d0
 beq.s .variable_space
 
 ; d0=character index
 ; a6=pointer on the font description bloc
 lea FontCredits,a6
 bsr CharacterDraw
 move.l a0,big_buffer_start+credits_current_position
 dbra d1,.loop
 rts
 
.done 
 ; Reached the end of the scroller,
 ; start the logo
 move.l #CreditsPlayAtariLogo,_AdrPartCredits
 move.w #200,pos_scr_y
 rts 

.variable_space  
 moveq #0,d0
 move.b (a0)+,d0
 add d0,d0				; x2
 add d0,character_xpos
 move.l a0,big_buffer_start+credits_current_position
 bra.s .loop
 
.new_line
 cmp #FONT_HEIGHT,big_buffer_start+credits_sub_ypos
 bne .no_end_line

 move.l a0,big_buffer_start+credits_current_position
   
 ; First copy the line
 move.l character_buffer_base,a0
 move.l big_buffer_start+credits_top_line,a1
var set 0 
 REPT 4*FONT_HEIGHT
 movem.l (a0)+,d0-d7/a2-a6		; 8+5=13*4=52 bytes
 movem.l d0-d7/a2-a6,var(a1)
var set var+52 
 ENDR
 lea 208*FONT_HEIGHT(a1),a1
 move.l a1,big_buffer_start+credits_top_line
 
 
 move #0,big_buffer_start+credits_sub_ypos				; From 0 to 21, allows to know when to go to next text line 
 move #FONT_LEFT_OFFSET,character_xpos
 add.l #(FONT_HEIGHT)*208,character_buffer_base
 
 addq #1,big_buffer_start+credits_sub_line_count
 cmp #LINE_COUNT,big_buffer_start+credits_sub_line_count
 bne.s .no_end_page
 
 move #0,big_buffer_start+credits_sub_line_count
 move #0,pos_scr_y						; Set the screen to the top line of the first buffer
 move.l #big_buffer_start+credits_screen+((LINE_COUNT*FONT_HEIGHT)+0)*208,character_buffer_base
 move.l #big_buffer_start+credits_screen,big_buffer_start+credits_top_line
 
.no_end_page 
  
.no_end_line 
 rts
   
 
CreditsMapFont
 ; Compute the pointers to fonts
 lea FontCredits,a6
 bsr ComputeCharactersAdressMapFromBitmap
 rts 
    
    
 SECTION DATA
 
 even

FontCredits
 dc.l big_buffer_start+credits_depacked_font+32
 dc.l CommonCharacterList
 dc.l big_buffer_start+credits_mapping_font
 dc.l big_buffer_start+credits_character_width
 dc.w FONT_HEIGHT
 dc.w 104
 dc.w 104*FONT_HEIGHT
 dc.w 8
 dc.w 0		; No extra pixel between characters
 dc.w 8		; 8 pixels for the space


PackInfoCreditFont 
 dc.l font_ocr
 dc.l big_buffer_start+credits_depacked_font
 dc.l 15320

PackInfoAtari
 dc.l packed_picture_atari
 dc.l big_buffer_start+credits_depacked_atari
 dc.l 48000
 
 
; Unpacked: 15320
; Packed:    8059
 FILE "font_ocr.pik",font_ocr
 
; Unpacked: 48000
; Packed:   16384
 FILE "atari.pik",packed_picture_atari
 
 
CreditsMessage
 dc.b " ",13
 dc.b "__Save The Earth__",13
 dc.b " ",13
 dc.b " ",13
 dc.b "__An Environmentally Aware Demo__",13
 dc.b "__For the 20th Birthday of the STE__",13
 dc.b "__at Kindergarden 2009__",13
 dc.b " ",13
 dc.b " ",13
 dc.b "Credits:",13
 dc.b " ",13
 dc.b " Dbug__(code & graphics)",13
 ;dc.b " XiA__(music)",13
 dc.b " Excellence in Art__(music)",13
 dc.b " Crem__(revamped logo)",13
 dc.b " ",13
 dc.b " ",13
 dc.b "Additional credits:",13
 dc.b " ",13
 dc.b " Mircha__(moral support)",13
 dc.b " Dad__(1040 STe)",13
 dc.b " GGN__(SIMMs)",13
 dc.b " Gloky__(new keyboard)",13
 dc.b " Jookie & MiKRO__(Ultra Satan)",13
 dc.b " Nerve__(transportation)",13
 dc.b " Evl__(many small things)",13
 dc.b " gwEm__(maxYMiser)",13
 dc.b " Elitar__(pixel-art trucks)",13
 dc.b " ",13
 dc.b " ",13
 dc.b "Borrowed material credits:",13
 dc.b " ",13
 dc.b "__The Industry Trust for__",13
 dc.b "__Intellectual Property Awareness__",13
 dc.b " ",13
 dc.b "__Google Image__",13
 dc.b " ",13
 dc.b "__Elitar__",13
 dc.b "__(@ www.pixelcarart.com)__",13
 dc.b " ",13
 dc.b " ",13
 dc.b "Atari greetings:",13
 dc.b " ",13
 dc.b "__Nolan Bushnell__",13
 dc.b "__Jay Miner__",13
 dc.b "__Shirav Shivji__",13 
 dc.b "__Jack & Sam Tramiel__",13 
 dc.b "__Pradip K Fatehpuria__",13
 dc.b " ",13
 dc.b " ",13
 dc.b "Classic atari game greeting:",13
 dc.b " ",13
 dc.b "__Faster Than Light__",13
 dc.b "__The Bitmap Brothers__",13
 dc.b "__Psygnosis__",13
 dc.b "__Steve Bak__",13
 dc.b "__David Whittaker__",13 
 dc.b "__Archer MacLean__",13
 dc.b " ",13
 dc.b " ",13
 dc.b "Demo scene greetings:",13
 dc.b " ",13
 dc.b "Accession, "
 dc.b "Aggression, "
 dc.b "Alive Team, "
 dc.b "Andromeda, "
 dc.b "ASD, "
 dc.b "Ate Bit, "
 dc.b "BitFlavour, "
 dc.b "BlockoS, "
 dc.b "Booze Design, "
 dc.b "Boozoholics, "
 dc.b "Byterapers, "
 dc.b "Brainstorm, "
 dc.b "CEO, "
 dc.b "Checkpoint, "
 dc.b "Chema, "
 dc.b "Cream, "
 dc.b "Crest, "
 dc.b "d-Bug, "
 dc.b "DHS, "
 dc.b "Darklite, "
 dc.b "Dekadence, "
 dc.b "Drifters, "
 dc.b "Ephidrena, "
 dc.b "Equinox, "
 dc.b "Evolution, "
 dc.b "Excess, "
 dc.b "Fairlight, "
 dc.b "Gwem, "
 dc.b "IRIS, "
 dc.b "Keyboarders, "
 dc.b "Kvasigen, "
 dc.b "Limp ninja, "
 dc.b "Lineout, "
 dc.b "Loonies, "
 dc.b "Loud, "
 dc.b "MJJ Prod, "
 dc.b "New Beat, "
 dc.b "No Extra, "
 dc.b "Noon, "
 dc.b "Odd, "
 dc.b "ORB, "
 dc.b "Outracks, "
 dc.b "Oxygene, "
 dc.b "Oxyron, "
 dc.b "Paradize, "
 dc.b "Paradox, "
 dc.b "PHF, "
 dc.b "PlayPsyCo, "
 dc.b "Portal Process, "
 dc.b "Reservoir Gods, "
 dc.b "Rgba, "
 dc.b "Spaceballs, "
 dc.b "Speckdrumm, "
 dc.b "Stax, "
 dc.b "St Knights, "
 dc.b "Stu, "
 dc.b "Synestetics, "
 dc.b "TetraKnight Squad 348, "
 dc.b "TBC, "
 dc.b "TBL, "
 dc.b "TSCC, "
 dc.b "Tufs, "
 dc.b "Twilighte, "
 dc.b "Yescrew, "
 dc.b "YM-Rockerz...",13
 dc.b " ",13
 dc.b "__...and you as well",13
 dc.b "since you took the time to watch this scroller :)",13
 dc.b " ",13
 REPT LINE_COUNT 
 dc.b " ",13
 ENDR
 
 dc.b 0
  
 even
 
 SECTION BSS
 
 even

;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset
credits_fullscreen			rs.b Size_PanoramicRoutine_DisplayList
credits_depacked_font		rs.b 15320

credits_screen 				rs.b 208*(LINE_COUNT*FONT_HEIGHT*2)+256			; Screen data

credits_depacked_atari		rs.b 48000

credits_mapping_font		rs.l 256
credits_character_width		rs.w 256	; Width in pixels for each character
credits_current_position	rs.l 1
credits_top_line			rs.l 1
credits_sub_ypos			rs.w 1
credits_sub_line_count		rs.w 1

credits_delay				rs.w 1

credits_displaylist			rs.l 200*2
credits_logo_size			rs.w 1

 update_buffer_size
 

 
 