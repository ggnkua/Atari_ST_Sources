
 SECTION TEXT
 
 even
 
LoadDoneInit 
 ; We have to set the display adress to something
 ; compatible to both STF/STE/MegaSTE/TT/ whatever
 move.l #big_buffer_start+loading_done_screen+255,d0
 clr.b d0
 move.l d0,ptr_scr_1
 bsr ComputeVideoParameters

 lsr.l #8,d0
 move.b d0,$ffff8203.w			; STF - Screen base adress (mid byte)
 lsr.w #8,d0
 move.b d0,$ffff8201.w			; STF - Screen base adress (high byte)
 
  
 ; Black palette
 movem.l black_palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 
 ; Display some random message in the subtitle area 
 lea message_loading_done,a0
 move.l ptr_scr_1,a1
 bsr SubtitleDrawTextPtr
 
 ; Subtitles palette
 movem.l font_subtitles,d0-d7
 movem.l d0-d7,$ffff8240.w
 
 move.l #LoadDoneKeyboardManager,_AdrKeyboardManager
 rts

LoadDonePlay
 rts
 
LoadDoneTerminate 
 ; Black palette
 movem.l black_palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 
 move.l #KeyboardDefaultManager,_AdrKeyboardManager
 rts
  

LoadDoneKeyboardManager
 KEYTEST_STATE_ANY
 bne.s .start_demo
 moveq #0,d0
 rts  
.start_demo
 moveq #1,d0
 rts 
 
  
 SECTION DATA
 
 even
    
message_loading_done
 dc.b 13,13
 dc.b "            Loading done",13
 dc.b "",13
 dc.b "        Please press any key",13
 dc.b "         to start the show.",13
 dc.b 0 

 
 SECTION BSS
  
 even
 
;
; The content of this buffer is going to be stored in
; the big common table.
; 
 rsreset

loading_done_screen 	rs.b 160*200+256			; Screen data
 
 update_buffer_size
 


 