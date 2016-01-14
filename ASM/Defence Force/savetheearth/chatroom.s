
IRC_LINE_HEIGHT			equ 7
IRC_LINE_COUNT			equ 20 
IRC_BOTTOM_POS_Y		equ 134
IRC_POS_X_TIMESTAMPS	equ 16
IRC_POS_X_NICKNAMES		equ 34
IRC_POS_X_MESSAGES		equ 88
IRC_POS_X_INPUTBOX		equ 48
IRC_POS_Y_INPUTBOX		equ 146
IRC_POS_X1_INPUTBOX		equ 396
IRC_POS_Y1_INPUTBOX		equ 153

IRC_MASK_RANDOM_INPUT	equ 3		; Power of two-1
IRC_MIN_DELAY_INPUT		equ 2

 
IRCNICK_SYSTEM		equ 0 
IRCNICK_BEETLEF060	equ 1
IRCNICK_DBUG		equ 2
IRCNICK_DEFJAM		equ 3
IRCNICK_EVL			equ 4
IRCNICK_GGN			equ 5
IRCNICK_GRAZEY		equ 6
IRCNICK_KEOPS		equ 7
IRCNICK_MTFELICE	equ 8
IRCNICK_PARANOID	equ 9
IRCNICK_PMDATA		equ 10
IRCNICK_RA			equ 11
IRCNICK_RAYTSCC		equ 12
IRCNICK_SSB			equ 13
IRCNICK_STINGRAY	equ 14
IRCNICK_XIA			equ 15


 SECTION TEXT
 
 even

ChatRoomInit
 ; Depack the chatroom picture
 lea PackInfoChatRoom,a0
 bsr DepackBlock

 ; Depack audio 
 lea packed_chatroom_sample_start,a0
 lea big_buffer_start+chatroom_sample_start,a1
 move.l #chatroom_sample_end-chatroom_sample_start,d0
 bsr DepackDelta
  
 bsr ChatRoomInitPalettes
 
 ; Using the template data, we generate the fullscreen
 lea PanoramicTemplate_DisplayList,a0
 lea big_buffer_start+chatroom_fullscreen,a1
 bsr GenerateOverscan
 rts

ChatRoomPlay
 bsr SequencerPlay
 bsr ChatRoomUpdateTyping
 bsr ChatRoomSetScreen
 rts
 
ChatRoomTerminate
 bsr TerminateFullscreenTimer
 rts
   
 
ChatRoomSetScreen
 ; Update the display list to point on the correct screen adress
 move.l #big_buffer_start+chatroom_depacked_picture+32*200,d1
 lsl.l #8,d1
 move.l d1,a0
 
 lea big_buffer_start+chatroom_depacked_picture,a1
 lea DisplayList,a2
 move.l #208*256,d0
 moveq #32,d1
 bsr DisplayListInit200
 rts 
 
 
; (372,173)-(398,183)
; 2 blocs wide
; 11 lines high
; 
; Seconds: colonne 385 (offset 192); pixels 176,177,179,180
; Color Index 4
ChatRoomUpdateClock
 ; Blinking pixel dots
 lea big_buffer_start+chatroom_depacked_picture+(32*200)+176*208+192,a0
 move.b time_seconds,d0
 and.b #1,d0
 beq.s .seconde_off 
.seconde_on
 ; 176
 or.w  #%0100000000000000,(a0)
 and.w #%1011111111111111,2(a0)
 and.w #%1011111111111111,4(a0)
 and.w #%1011111111111111,6(a0)
 ; 177
 lea 208(a0),a0
 or.w  #%0100000000000000,(a0)
 and.w #%1011111111111111,2(a0)
 and.w #%1011111111111111,4(a0)
 and.w #%1011111111111111,6(a0)
 ; 179
 lea 208*2(a0),a0
 or.w  #%0100000000000000,(a0)
 and.w #%1011111111111111,2(a0)
 and.w #%1011111111111111,4(a0)
 and.w #%1011111111111111,6(a0)
 ; 180
 lea 208(a0),a0
 or.w  #%0100000000000000,(a0)
 and.w #%1011111111111111,2(a0)
 and.w #%1011111111111111,4(a0)
 and.w #%1011111111111111,6(a0)
 bra.s .seconde_done 
 
.seconde_off
 ; 176
 and.w #%1011111111111111,(a0)
 and.w #%1011111111111111,2(a0)
 and.w #%1011111111111111,4(a0)
 and.w #%1011111111111111,6(a0)
 ; 177
 lea 208(a0),a0
 and.w #%1011111111111111,(a0)
 and.w #%1011111111111111,2(a0)
 and.w #%1011111111111111,4(a0)
 and.w #%1011111111111111,6(a0)
 ; 179
 lea 208*2(a0),a0
 and.w #%1011111111111111,(a0)
 and.w #%1011111111111111,2(a0)
 and.w #%1011111111111111,4(a0)
 and.w #%1011111111111111,6(a0)
 ; 180
 lea 208(a0),a0
 and.w #%1011111111111111,(a0)
 and.w #%1011111111111111,2(a0)
 and.w #%1011111111111111,4(a0)
 and.w #%1011111111111111,6(a0)
.seconde_done
 
 ;
 ; Erase the old segments
 ;
 lea big_buffer_start+chatroom_depacked_picture+(32*200)+173*208+184,a2
 move.l #%11111100011100011111110001110001,d7	; Horizontal segments for hours - black
 move.l #%11111011101011101111101110101110,d6   ; Vertical segments for hours- black

 move.l #%11110001110001111111000111000111,d5	; Horizontal segments for minutes - black
 move.l #%11101110101110111110111010111011,d4   ; Vertical segments for minutes- black
  
 ; Top line
 and.l d7,(a2)
 and.l d7,4(a2)
 and.l d5,8+0(a2)
 and.l d5,8+4(a2)
 lea 208(a2),a2
 
 ; Top/bottom section
 moveq #4-1,d0
.loop 
 and.l d6,(a2)
 and.l d6,4(a2)
 and.l d6,208*5+0(a2)
 and.l d6,208*5+4(a2)
 and.l d4,8+0(a2)
 and.l d4,8+4(a2)
 and.l d4,208*5+8+0(a2)
 and.l d4,208*5+8+4(a2)
 lea 208(a2),a2
 dbra d0,.loop
   
 ; Mid line
 and.l d7,(a2)
 and.l d7,4(a2)
 and.l d5,8+0(a2)
 and.l d5,8+4(a2)
 lea 208*5(a2),a2
 
 ; End line
 and.l d7,(a2)
 and.l d7,4(a2)
 and.l d5,8+0(a2)
 and.l d5,8+4(a2)

 ;
 ; Draw the activated segments depending of time
 ;
 
 ; First digit of the minutes
 ; Colomn 384 (offset 192), line 173 
 move.b time_hours,d0
 lsl.w #8,d0
 move.b time_minutes,d0		; HHMM (16 bits)
 
 lea TableDigitShiftBit,a3
 lea TableDigitOffset,a4
 
 moveq #4-1,d7
.loop_digit
 move d0,d1
 lsr #4,d0		
 
 and #$0f,d1					; Get nibble for current digit

 moveq #0,d2
 move.b (a4,d7),d2				; Get screen offset
 lea big_buffer_start+chatroom_depacked_picture+(32*200)+173*208+184,a2
 add.w d2,a2					; Final screen adress
  
 moveq #0,d2
 move.b (a3,d7),d2				; Shift value
 
  
 lea TaskBarClockDigits,a0		; Real number for drawing, 5 entries
 lsl #3,d1
 add d1,a0  					; Segment description for this number

 ; Top segment  
 moveq #0,d3
 move.b (a0)+,d3
 lsl d2,d3						; Shift the segment value for the screen
 or.w d3,208*0(a2)				; Write the top segment value

 ; Top vertical segments
 moveq #0,d3
 move.b (a0)+,d3
 lsl d2,d3						; Shift the segment value for the screen
 or.w d3,208*1(a2)				; Write the top segment value
 or.w d3,208*2(a2)				; Write the top segment value
 or.w d3,208*3(a2)				; Write the top segment value
 or.w d3,208*4(a2)				; Write the top segment value

 ; Mid segment  
 moveq #0,d3
 move.b (a0)+,d3
 lsl d2,d3						; Shift the segment value for the screen
 or.w d3,208*5(a2)				; Write the middle segment value

 ; Bottom vertical segments
 moveq #0,d3
 move.b (a0)+,d3
 lsl d2,d3						; Shift the segment value for the screen
 or.w d3,208*6(a2)				; Write the top segment value
 or.w d3,208*7(a2)				; Write the top segment value
 or.w d3,208*8(a2)				; Write the top segment value
 or.w d3,208*9(a2)				; Write the top segment value

 ; Bottom segment  
 moveq #0,d3
 move.b (a0)+,d3
 lsl d2,d3						; Shift the segment value for the screen
 or.w d3,208*10(a2)				; Write the bottom segment value
     
 dbra d7,.loop_digit
 
 rts 
  
 
; 7*20=140
ChatRoomInitPalettes
 lea ChatColors+IRCNICK_DBUG*8,a0
 lea big_buffer_start+chatroom_depacked_picture+IRC_POS_Y_INPUTBOX*32,a1
 move #7-1,d6
.loop_scanline 
 move.l (a0),(a1)
 move.l 4(a0),4(a1)
 lea 32(a1),a1
 dbra d6,.loop_scanline
 rts
  
EraseTopOfTheChat
 lea big_buffer_start+chatroom_depacked_picture+32*200,a0
 move.l a0,a1
 add.l #208*142,a1
 bsr MemoryClear
 rts 

  
ChatRoomEraseTypeBox
 lea big_buffer_start+chatroom_depacked_picture+(32*200)+24+IRC_POS_Y_INPUTBOX*208,a0
 move #7-1,d0
.loop_erase 
 lea 168(a0),a1
 bsr MemoryClear
 lea 208(a0),a0
 dbra d0,.loop_erase
 rts
 
; a0=message adress 
; a1=buffer
ChatRoomPrintMessage
 move #8,character_xpos
 move #1,character_ypos
 move.l #big_buffer_start+chatroom_depacked_picture+32*200+8,character_buffer_base

.loop
 moveq #0,d0
 move.b (a0)+,d0	; Get the current character
 beq.s .done
 cmp.b #13,d0
 beq.s .next_line
   
 ; d0=character index
 ; a6=pointer on the font description bloc
 lea FontSmall,a6
 bsr CharacterDraw
 bra.s .loop
.done
 rts
.next_line 
 move #8,character_xpos
 add #7,character_ypos
 bra.s .loop 

 

ChatRoomScrollUp
 ; Scrollup text
 lea big_buffer_start+chatroom_depacked_picture+32*200+8,a0
 lea 208*7(a0),a1
 move.w #135-1,d0
.loop_scroll_lines 
 move.w #200/4-1,d1
 move.l a0,a2
 move.l a1,a3
.loop_scroll
 move.l (a3)+,(a2)+
 dbra d1,.loop_scroll
 lea 208(a0),a0
 lea 208(a1),a1
 dbra d0,.loop_scroll_lines
 
 ; Erase the old line
 lea big_buffer_start+chatroom_depacked_picture+32*200+8+IRC_BOTTOM_POS_Y*208,a0
 move #7-1,d0
.loop_erase 
 lea 184(a0),a1
 bsr MemoryClear
 lea 208(a0),a0
 dbra d0,.loop_erase
 
 ; Scrollup colors
 lea big_buffer_start+chatroom_depacked_picture,a0
 move #135-1,d7
.loop_scroll_palettes
 move.l 32*7(a0),(a0)
 move.l 32*7+4(a0),4(a0)
 lea 32(a0),a0
 dbra d7,.loop_scroll_palettes 
 rts


; Type one character at a type 
ChatRoomUpdateTyping
 lea big_buffer_start,a6
 move.l chatroom_type_start_ptr(a6),a0
 cmp.l #0,a0
 beq.s .done				; No current message
 tst.b chatroom_type_delay(a6)
 beq.s .new_character
 subq.b #1,chatroom_type_delay(a6)
.done 
 rts 
 
.new_character 
 bsr NextPRN
 and #IRC_MASK_RANDOM_INPUT,d0
 add #IRC_MIN_DELAY_INPUT,d0
 	;moveq #0,d0
 move.b d0,chatroom_type_delay(a6)	; Save the delay before the next character
 
 moveq #0,d0
 move.b chatroom_type_offset(a6),d0	; Character offset
 move.b (a0,d0),d0					; Next character to display
 beq.s .typing_done
 
 addq.b #1,chatroom_type_offset(a6)
 
 ; Display the new character
 move.l #big_buffer_start+chatroom_depacked_picture+32*200,character_buffer_base
 move.w chatroom_type_pos_x(a6),character_xpos
 move.w #IRC_POS_Y_INPUTBOX,character_ypos
 
 bsr PlayRandomClickSound
 
 ; d0=character index
 ; a6=pointer on the font description bloc
 lea FontSmall,a6
 bsr CharacterDraw
 move.w character_xpos,big_buffer_start+chatroom_type_pos_x
 ;bra ChatRoomUpdateTyping
 rts
 
; Reached the zero, need to display the text 
.typing_done
 clr.l chatroom_type_start_ptr(a6)	; Clear the type pointer
 move.w #IRCNICK_DBUG,d0
 bsr ChatRoomIrcPrintMessageReal	; Display the message in the chat room
 
 bsr ChatRoomEraseTypeBox			; Erase the message in the box
 rts 
 
 
PlayRandomClickSound
 movem.l d0-a6,-(sp)
 
 bsr NextPRN
 and #3,d0
 add d0,d0
 add d0,d0
 lea TableKeyboardSounds,a2
 add d0,a2
 
 lea big_buffer_start+chatroom_sample_start,a0
 move.l a0,a1
 add (a2)+,a0
 add (a2)+,a1
 
 bsr StartReplay 
 
 movem.l (sp)+,d0-a6
 rts 
 
 
; d0=nickname index
; a0=message string 
;
; returns a0 pointing on the byte after the 0
ChatRoomIrcPrintMessage 
 cmp.w #IRCNICK_DBUG,d0
 bne.s ChatRoomIrcPrintMessageReal

 ; This is Dbug typing
 ; Set this as the real message to print
 lea big_buffer_start,a1
 move.l a0,chatroom_type_start_ptr(a1)
 move.w #IRC_POS_X_INPUTBOX,chatroom_type_pos_x(a1)
 sf.b chatroom_type_offset(a1)
 sf.b chatroom_type_delay(a1)
 bsr GetAlignedEndOfString
;.loop_find_end
; tst.b (a0)+
; bne.s .loop_find_end
 ; return a0 pointing on the last character
 rts
 
ChatRoomIrcPrintMessageReal
 movem.l d0/a0,-(sp)
 bsr ChatRoomScrollUp
 movem.l (sp)+,d0/a0
 
 ; Positions:
 ; - 24 -> time stamp
 ; - xx -> Nicknames
 ; - yy -> Messages
 ; Need a vertical separator line between the nick names and the messages
 move.l #big_buffer_start+chatroom_depacked_picture+32*200,character_buffer_base
 move #IRC_BOTTOM_POS_Y,character_ypos


 ; Set the colors depending of the NickName
 lea big_buffer_start+chatroom_depacked_picture+(IRC_BOTTOM_POS_Y*32),a1
 lea ChatColors,a2
 move d0,d1
 and #7,d1
 lsl #3,d1
 add d1,a2
 move #7-1,d6
.loop_scanline 
 move.l (a2),(a1)
 move.l 4(a2),4(a1)
 lea 32(a1),a1
 dbra d6,.loop_scanline

 move.l a0,-(sp)
 ; Display the nickname
 lea ListNickNames,a0
 add d0,d0
 add d0,d0
 move.l (a0,d0),a0
 move #IRC_POS_X_NICKNAMES,d0
 add.b (a0)+,d0
 move d0,character_xpos
 bsr ChatRoomIrcOutputLine
 move.l (sp)+,a0
   
 ; Display the message 
 move #IRC_POS_X_MESSAGES,character_xpos
 ; ! a0 comes from the caller, don't get it erased 
 bsr ChatRoomIrcOutputLine
 move.l a0,-(sp)
  
 ; Display the time stamp
 moveq #0,d0
 lea IrcTimeStamp,a0
 lea HexDigits,a1
 
 move.b time_minutes,d0
 move.b d0,d1
 and #7,d0
 move.b (a1,d0),4(a0)
 move.b d1,d0
 lsr.b #4,d0
 move.b (a1,d0),3(a0)

 move.b time_hours,d0
 move.b d0,d1
 and #7,d0
 move.b (a1,d0),1(a0)
 move.b d1,d0
 lsr.b #4,d0
 move.b (a1,d0),0(a0)
  
 move #IRC_POS_X_TIMESTAMPS,character_xpos
 bsr ChatRoomIrcOutputLine
 
 ; Restore the chat position
 move.l (sp)+,a0
 rts
 

ChatRoomIrcOutputLine
.loop
 moveq #0,d0
 move.b (a0)+,d0	; Get the current character
 beq.s .done
 cmp.b #13,d0
 beq.s .done
  
 ; d0=character index
 ; a6=pointer on the font description bloc
 lea FontSmall,a6
 bsr CharacterDraw
 bra.s .loop
.done
 rts
.next_line 
 move #8,character_xpos
 add #7,character_ypos
 bra.s .loop 
 
 
 SECTION DATA

IrcTimeStamp
 ;     01234
 dc.b "00:00",0
  
 even
 
 
ChatRoomSequencer 
 SEQUENCE_SETPTR _AdrPartVblRoutine,ChatRoomUpdateClock

 SEQUENCE_TEMPORIZE 5
 SEQUENCE_IRC_MESSAGE IRCNICK_SYSTEM,<"Topic for #atariscne is: Outline results: http://www.dhs.nu">
 SEQUENCE_IRC_MESSAGE IRCNICK_SYSTEM,<"Topic for #atariscne set by evl~an@yada.se">
 SEQUENCE_SUBTITLE <"Welcome to the modern demoscene!">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_EVL,<"Hi _Dbug_ :)  How's the demo going?">
 SEQUENCE_TEMPORIZE 90
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_DBUG,<"Not that well I fear...">
 SEQUENCE_TEMPORIZE 70
 SEQUENCE_IRC_MESSAGE IRCNICK_BEETLEF060,<"Hi Dbg">
 SEQUENCE_TEMPORIZE 80
 SEQUENCE_IRC_MESSAGE IRCNICK_SYSTEM,<"CyranoJ has joined #atariscne">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_EVL,<"Oh?">
 SEQUENCE_TEMPORIZE 60
 SEQUENCE_IRC_MESSAGE IRCNICK_SYSTEM,<"Malodix has quit (EOF From client)">
 SEQUENCE_TEMPORIZE 40
 SEQUENCE_IRC_MESSAGE IRCNICK_PMDATA,<"Dbug can't debug ?">
 SEQUENCE_TEMPORIZE 40
 SEQUENCE_IRC_MESSAGE IRCNICK_SYSTEM,<"MT-Felice has joined #atariscne">
 SEQUENCE_TEMPORIZE 40
 SEQUENCE_IRC_MESSAGE IRCNICK_DBUG,<"Trying to find ideas by watching old demos :-/">
 SEQUENCE_TEMPORIZE 60
 SEQUENCE_IRC_MESSAGE IRCNICK_STINGRAY,<"full pixel? full screen I meant ;D">
 SEQUENCE_TEMPORIZE 80
 SEQUENCE_IRC_MESSAGE IRCNICK_SYSTEM,<"_Paranoid can do a full single pixel plarma, too! :-D">
 SEQUENCE_TEMPORIZE 40
 SEQUENCE_IRC_MESSAGE IRCNICK_PARANOID,<"plasma">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_STINGRAY,<"haha">
 SEQUENCE_TEMPORIZE 80
 SEQUENCE_IRC_MESSAGE IRCNICK_SYSTEM,<"StingRay deserves that">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_KEOPS,<"No too old I hope, one BITS is enough!">
 SEQUENCE_TEMPORIZE 60
 SEQUENCE_IRC_MESSAGE IRCNICK_GGN,<"lol">
 SEQUENCE_TEMPORIZE 30
 SEQUENCE_IRC_MESSAGE IRCNICK_XIA,<"You know, possibly Bits are just misunderstood Genius :)">
 SEQUENCE_TEMPORIZE 50 
 SEQUENCE_IRC_MESSAGE IRCNICK_DBUG,<"Had some ideas, but would be either too boring or too complicated">
 SEQUENCE_TEMPORIZE 60
 SEQUENCE_IRC_MESSAGE IRCNICK_EVL,<"I see. Well, good luck!">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_KEOPS,<142>
 SEQUENCE_TEMPORIZE 20
 SEQUENCE_IRC_MESSAGE IRCNICK_KEOPS,<143>
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_XIA,<"ASCII Art !">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_TEMPORIZE 40
 SEQUENCE_IRC_MESSAGE IRCNICK_STINGRAY,<"indeed ;D">
  
 SEQUENCE_TEMPORIZE 20
 SEQUENCE_IRC_MESSAGE IRCNICK_STINGRAY,<"rather lame demo tho">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_STINGRAY,<"except for that part">
 
 SEQUENCE_IRC_MESSAGE IRCNICK_MTFELICE,<"Hi everybody.">
 SEQUENCE_IRC_MESSAGE IRCNICK_DBUG,<":)">
 
 SEQUENCE_TEMPORIZE 20
 SEQUENCE_IRC_MESSAGE IRCNICK_STINGRAY,<":D">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_SSB,<"StingRay, you shouldnt slag off your old work like that!">
 SEQUENCE_TEMPORIZE 10
 SEQUENCE_IRC_MESSAGE IRCNICK_SSB,<":)">
 SEQUENCE_TEMPORIZE 50
 SEQUENCE_IRC_MESSAGE IRCNICK_SYSTEM,<"Paranoid has quit ('Plantsch!')">
 SEQUENCE_TEMPORIZE 30
 SEQUENCE_IRC_MESSAGE IRCNICK_STINGRAY,<"haha">
 SEQUENCE_SUBTITLE <"IRC, forums, videos, internet, trolls &",13,"glops, but not much demomaking :(">
 SEQUENCE_IRC_MESSAGE IRCNICK_DBUG,<"Anyway, sleep time for me. Good night everybody.">

 SEQUENCE_TEMPORIZE 50*6
 
 SEQUENCE_IRC_MESSAGE IRCNICK_STINGRAY,<"Night bug">
 SEQUENCE_TEMPORIZE 30
 SEQUENCE_IRC_MESSAGE IRCNICK_XIA,<"Good night as well.">
 SEQUENCE_IRC_MESSAGE IRCNICK_GGN,<"cu">

 ; Wait a bit
 SEQUENCE_TEMPORIZE 50*1
  
 ; And leave
 SEQUENCE_GO_NEXT_PART	
 
 SEQUENCE_END

   
PackInfoChatRoom
 dc.l packed_picture_chatroom
 dc.l big_buffer_start+chatroom_depacked_picture
 dc.l 48000 

 
; Unpacked: 48000
; Packed:   13032 
 FILE "chatroom.pik",packed_picture_chatroom
 
; Unpacked:  9536
; Packed:    4769
 FILE "keyboard.dlt",packed_chatroom_sample_start,packed_chatroom_sample_end
 
 even
 

; 2*4=8 bytes per entry 
ChatColors 
 dc.w $777,$666,$555,$333	; Grey
 dc.w $777,$766,$655,$533	; Red
 dc.w $777,$676,$565,$353	; Green
 dc.w $777,$667,$556,$335	; Blue
 
 dc.w $777,$776,$665,$553	; Yellow
 dc.w $777,$677,$566,$355	; Cyan
 dc.w $777,$767,$656,$535	; Magenta
 dc.w $777,$666,$555,$333	; 
  
 
TaskBarClockDigits
 ; 0
 dc.b %01110 
 dc.b %10001 
 dc.b %00000  
 dc.b %10001 
 dc.b %01110 
 dc.b 0,0,0

 ; 1
 dc.b %00000 
 dc.b %00001 
 dc.b %00000  
 dc.b %00001 
 dc.b %00000 
 dc.b 0,0,0

 ; 2
 dc.b %01110 
 dc.b %00001 
 dc.b %01110  
 dc.b %10000 
 dc.b %01110 
 dc.b 0,0,0

 ; 3
 dc.b %01110 
 dc.b %00001 
 dc.b %01110  
 dc.b %00001 
 dc.b %01110 
 dc.b 0,0,0

 ; 4
 dc.b %00000 
 dc.b %10001 
 dc.b %01110  
 dc.b %00001 
 dc.b %00000 
 dc.b 0,0,0
 
 ; 5
 dc.b %01110 
 dc.b %10000 
 dc.b %01110  
 dc.b %00001 
 dc.b %01110 
 dc.b 0,0,0

 ; 6
 dc.b %01110 
 dc.b %10000 
 dc.b %01110  
 dc.b %10001 
 dc.b %01110 
 dc.b 0,0,0

 ; 7
 dc.b %01110 
 dc.b %00001 
 dc.b %00000  
 dc.b %00001 
 dc.b %00000 
 dc.b 0,0,0

 ; 8
 dc.b %01110 
 dc.b %10001 
 dc.b %01110  
 dc.b %10001 
 dc.b %01110 
 dc.b 0,0,0

 ; 9
 dc.b %01110 
 dc.b %10001 
 dc.b %01110  
 dc.b %00001 
 dc.b %01110 
 dc.b 0,0,0
  
TableDigitShiftBit 	
 dc.b 6,0,8,2
 
TableDigitOffset	
 dc.b 0,0,8,8
 

TableKeyboardSounds
 dc.w 0,1598
 dc.w 1598,2696
 dc.w 2696,3922
 dc.w 3922,5221
 dc.w 5001,5889
 dc.w 5861,7041
 dc.w 6989,8293
 dc.w 8281,9533

   
ListNickNames
 dc.l NickName_system
 dc.l NickName_beetlef060
 dc.l NickName_dbug
 dc.l NickName_defjam
 dc.l NickName_evl
 dc.l NickName_ggn
 dc.l NickName_grazey
 dc.l NickName_keops
 dc.l NickName_mtfelice
 dc.l NickName_paranoid
 dc.l NickName_pmdata
 dc.l NickName_ra
 dc.l NickName_raytscc
 dc.l NickName_ssb
 dc.l NickName_stingray
 dc.l NickName_xia
 
NickName_system		    dc.b 43,"*",0
NickName_beetlef060	    dc.b 22,"Beetle",0
NickName_dbug		    dc.b 15,"_Dbug_",0
NickName_defjam		    dc.b 10,"defjam",0	   
NickName_evl		    dc.b 35,"evl",0
NickName_ggn		    dc.b 33,"ggn",0
NickName_grazey		    dc.b 10,"Grazey",0
NickName_keops		    dc.b 22,"Keops",0
NickName_mtfelice	    dc.b 12,"MTFelice",0
NickName_paranoid	    dc.b 12,"Paranoid",0
NickName_pmdata		    dc.b 18,"pmdata",0
NickName_ra			    dc.b 30,"RQ",0
NickName_raytscc	    dc.b 10,"raytscc",0
NickName_ssb		    dc.b 33,"ssb",0
NickName_stingray	    dc.b 12,"StingRay",0
NickName_xia		    dc.b 34,"XiA",0

 
 SECTION BSS
  
 even


 
;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset
chatroom_type_start_ptr		rs.l 1			; Pointer on the message to type
chatroom_type_pos_x			rs.w 1			; Pïxel position of the next character
chatroom_type_offset		rs.b 1			; Offset in the message
chatroom_type_delay			rs.b 1			; Random delay to wait betwen characters
chatroom_fullscreen			rs.b Size_PanoramicRoutine_DisplayList
chatroom_depacked_picture	rs.b 48000

chatroom_sample_start		rs.b 9536
chatroom_sample_end			rs.b 16				; Some padding to handle the alignment issues

 update_buffer_size
 

 
