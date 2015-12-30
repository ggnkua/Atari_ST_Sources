 
 SECTION TEXT
 
 even
      
SEQUENCER_END			equ 0 
SEQUENCER_PLAY_SAMPLE	equ 1
SEQUENCER_PLAY_SAMPLES	equ 2
SEQUENCER_CALLBACK		equ 3
SEQUENCER_TEMPORIZE		equ 4 
SEQUENCER_SUBTITLE		equ 5
SEQUENCER_SETPTR		equ 6
SEQUENCER_IRC_MESSAGE	equ 7
SEQUENCER_DEPACK_LZSS	equ 8
SEQUENCER_SETPICTURE	equ 9
SEQUENCER_GO_NEXT_PART	equ 10
SEQUENCER_SET_BYTE		equ 11
SEQUENCER_SET_WORD		equ 12
SEQUENCER_SET_LONG		equ 13
SEQUENCER_SETPICTURE_DISPLAYLIST equ 14
SEQUENCER_WAIT_BYTE		equ 15
SEQUENCER_WAIT_WORD		equ 16
SEQUENCER_WAIT_LONG		equ 17


SEQUENCE_END macro
 dc.w SEQUENCER_END
 endm


; 1=start adress
; 2=end adress
SEQUENCE_PLAYSAMPLE macro
 dc.w SEQUENCER_PLAY_SAMPLE
 dc.l (\1)			; Start adress
 dc.l (\2)			; End adress
 endm 

SEQUENCE_PLAYSAMPLES macro
 REPT \1
 dc.w SEQUENCER_PLAY_SAMPLES
 dc.w ((\3-\2)/4)/50	; Lenght
 dc.l (\4)+(\2)			; Start adress
 dc.l (\4)+(\3)			; End adress
 ENDR
 endm 
 
; 1=routine adress 
SEQUENCE_CALLBACK macro
 dc.w SEQUENCER_CALLBACK
 dc.l \1
 endm 

; 1=duration
SEQUENCE_TEMPORIZE macro
 dc.w SEQUENCER_TEMPORIZE
 dc.w \1
 endm 

; 1=zero terminated message string
; This function does nothing if the debugging mode is enabled
SEQUENCE_SUBTITLE macro
 ifeq enable_debug_text
 dc.w SEQUENCER_SUBTITLE
 dc.b \1
 dc.b 0
 endc
 endm 

; 1=destination address
; 2=pointer on the routine to set
SEQUENCE_SETPTR macro
 dc.w SEQUENCER_SETPTR
 dc.l \1
 dc.l \2
 endm 
 
; 1=irc nick id
; 2=zero terminated message string 
SEQUENCE_IRC_MESSAGE macro
 dc.w SEQUENCER_IRC_MESSAGE
 dc.w \1
 dc.b \2
 dc.b 0
 even
 endm
 
; 1=pointer on packed source
; 2=pointer on depack buffer
; 3=size of depacked data
SEQUENCE_DEPACK_LZSS macro
 dc.w SEQUENCER_DEPACK_LZSS
 dc.l \1
 dc.l \2
 dc.l \3
 endm

; 1=pointer on the picture to display
SEQUENCE_SETPICTURE macro
 dc.w SEQUENCER_SETPICTURE
 dc.l \1
 endm 

SEQUENCE_GO_NEXT_PART macro
 dc.w SEQUENCER_GO_NEXT_PART
 endm

; 1=pointer on the byte
; 2=value of the byte  
SEQUENCE_SET_BYTE macro
 dc.w SEQUENCER_SET_BYTE
 dc.l \1
 dc.w \2
 endm
  
; 1=pointer on the word
; 2=value of the word
SEQUENCE_SET_WORD macro
 dc.w SEQUENCER_SET_WORD
 dc.l \1
 dc.w \2
 endm

; 1=pointer on the long
; 2=value of the long
SEQUENCE_SET_LONG macro
 dc.w SEQUENCER_SET_LONG
 dc.l \1
 dc.l \2
 endm

; 1=0 if mono-palette 1 if multipalette 
; 1=pointer on the picture to display
SEQUENCE_SETPICTURE_DISPLAYLIST macro 
 dc.w SEQUENCER_SETPICTURE_DISPLAYLIST
 dc.w \1
 dc.l \2
 endm 
 
; 1=pointer on the byte
; 2=value of the byte value to wait for 
SEQUENCE_WAIT_BYTE macro
 dc.w SEQUENCER_WAIT_BYTE
 dc.l \1
 dc.w \2
 endm
  
; 1=pointer on the word
; 2=value of the word value to wait for
SEQUENCE_WAIT_WORD macro
 dc.w SEQUENCER_WAIT_WORD
 dc.l \1
 dc.w \2
 endm

; 1=pointer on the long
; 2=value of the long value to wait for
SEQUENCE_WAIT_LONG macro
 dc.w SEQUENCER_WAIT_LONG
 dc.l \1
 dc.l \2
 endm
       
 
 
 

; a0=pointer on the sequence 
SequencerInit 
 move.l a0,sequencer_ptr
 clr.w sequencer_delay
 rts
 
  
SequencerPlay 
 tst.w sequencer_delay
 beq.s .next
 subq.w #1,sequencer_delay
 rts
  
.next
 move.l sequencer_ptr,a0
 move.w (a0)+,d0
 
 ; Dispatches on the correct function
 lea SequencerFunctionTable,a1
 add.w d0,d0
 add.w d0,d0
 move.l (a1,d0.w),a1
 jmp (a1)

 
SequencerFunction_done 
 rts

   
SequencerFunction_play_samples
 move.w (a0)+,sequencer_delay
SequencerFunction_play_sample 
 lea $ffff8900.w,a1
 
 move.b 3(a0),$7(a1)		; $ffff8907.w Dma start adress (low)
 move.b 2(a0),$5(a1)		; $ffff8905.w Dma start adress (mid)
 move.b 1(a0),$3(a1)		; $ffff8903.w Dma start adress (high)

 move.b 7(a0),$13(a1)		; $ffff8913.w Dma end adress (low)
 move.b 6(a0),$11(a1)		; $ffff8911.w Dma end adress (mid)
 move.b 5(a0),$f(a1)		; $ffff890f.w Dma end adress (high) 
 
 lea 8(a0),a0
 
 move.b #1+128,$21(a1)		; $ffff8921.w DMA mode (128=mono) (0=6258,1=12517,2=25033,3=50066)
 move.b #1,$1(a1)			; $ffff8901.w DMA control (0=stop, 1=play once, 2=loop)
 
 move.l a0,sequencer_ptr
 rts
   
SequencerFunction_run_callback
 move.l (a0)+,a1			; Callback adress

 movem.l d0-a6,-(sp)
 jsr (a1)
 movem.l (sp)+,d0-a6
 move.l a0,sequencer_ptr
 rts

SequencerFunction_temporize
 move.w (a0)+,sequencer_delay
 move.l a0,sequencer_ptr
 rts
   
SequencerFunction_subtitle
 ; a0 points on the message itself
 move.l a0,a1
 movem.l d0-a6,-(sp)
 bsr SubtitleClearBuffer
 move.l a1,a0
 st.b character_wait_vbl
 bsr SubtitleDrawText
 sf.b character_wait_vbl
 movem.l (sp)+,d0-a6
 bsr GetAlignedEndOfString
 move.l a0,sequencer_ptr
 rts 
  
SequencerFunction_set_ptr
 move.l (a0)+,a1
 move.l (a0)+,(a1)
 move.l a0,sequencer_ptr
 rts
  
SequencerFunction_irc_message
 ifne enable_part_chatroom 
 move.w (a0)+,d0	; irc nick
 ; takes a0 as input; and returns in a0 after the zero
 bsr ChatRoomIrcPrintMessage
 move.l a0,d0
 addq.l #1,d0
 and.l #-2,d0
 move.l d0,sequencer_ptr
 endc 
 rts

SequencerFunction_depack_lzss
 ; a0=depack block
 bsr DepackBlock
 lea 4*3(a0),a0
 move.l a0,sequencer_ptr
 rts
  
SequencerFunction_set_picture
 move.l (a0)+,a1
 move.l a0,sequencer_ptr
 move #0,pos_scr_x
 move #0,pos_scr_y
 
 lea $ffff8240.w,a0
 moveq #16,d7
 bsr ComputeGradient
 move.l a1,ptr_scr_1 
 rts
 
SequencerFunction_go_next_part
 st.b flag_end_part 
 rts
  
SequencerFunction_set_byte
 move.l (a0)+,a1
 move.w (a0)+,d0
 move.b d0,(a1)
 move.l a0,sequencer_ptr
 rts 

SequencerFunction_set_word
 move.l (a0)+,a1
 move.w (a0)+,d0
 move.w d0,(a1)
 move.l a0,sequencer_ptr
 rts 

SequencerFunction_set_long
 move.l (a0)+,a1
 move.l (a0)+,d0
 move.l d0,(a1)
 move.l a0,sequencer_ptr
 rts 
   
SequencerFunction_set_picture_dlist
 move.w (a0)+,d0			; Flag palettes
 beq.s .mono_palette 
.multi_palette
 move.l #32*200,d0 
 moveq #32,d1
 bra.s .continue
.mono_palette 
 move.l #32,d0 
 moveq #0,d1
.continue 
 move.l (a0)+,a1			; Base picture
 move.l a0,sequencer_ptr
 
 add.l a1,d0
 lsl.l #8,d0
 move.l d0,a0
 
 move.l #208*256,d0
 
 lea DisplayList,a2										; Target display list
 bsr DisplayListInit200
 rts 
 
SequencerFunction_wait_byte
 move.l (a0)+,a1
 move.w (a0)+,d0
 cmp.b (a1),d0
 bgt.s .not_yet
 move.l a0,sequencer_ptr
.not_yet 
 rts 

SequencerFunction_wait_word
 move.l (a0)+,a1
 move.w (a0)+,d0
 cmp.w (a1),d0
 bgt.s .not_yet
 move.l a0,sequencer_ptr
.not_yet  
 rts 

SequencerFunction_wait_long
 move.l (a0)+,a1
 move.l (a0)+,d0
 cmp.l (a1),d0
 bgt.s .not_yet
 move.l a0,sequencer_ptr
.not_yet  
 rts 
 
 
; a0=pointer on string
; return a0=pointer on the first aligned adress after the null terminator
GetAlignedEndOfString
.loop_find_end
 tst.b (a0)+
 bne.s .loop_find_end
 move.l d0,-(sp)
 move.l a0,d0
 addq.l #1,d0
 and.l #-2,d0
 move.l d0,a0
 move.l (sp)+,d0
 rts
 
  
 SECTION DATA
 
 even

SequencerFunctionTable
 dc.l SequencerFunction_done				; SEQUENCER_END
 dc.l SequencerFunction_play_sample			; SEQUENCER_PLAY_SAMPLE
 dc.l SequencerFunction_play_samples		; SEQUENCER_PLAY_SAMPLES
 dc.l SequencerFunction_run_callback		; SEQUENCER_CALLBACK
 dc.l SequencerFunction_temporize			; SEQUENCER_TEMPORIZE
 dc.l SequencerFunction_subtitle			; SEQUENCER_SUBTITLE
 dc.l SequencerFunction_set_ptr				; SEQUENCER_SETPTR
 dc.l SequencerFunction_irc_message			; SEQUENCER_IRC_MESSAGE
 dc.l SequencerFunction_depack_lzss			; SEQUENCER_DEPACK_LZSS
 dc.l SequencerFunction_set_picture			; SEQUENCER_SETPICTURE
 dc.l SequencerFunction_go_next_part		; SEQUENCER_GO_NEXT_PART
 dc.l SequencerFunction_set_byte			; SEQUENCER_SET_BYTE
 dc.l SequencerFunction_set_word			; SEQUENCER_SET_WORD
 dc.l SequencerFunction_set_long			; SEQUENCER_SET_LONG
 dc.l SequencerFunction_set_picture_dlist	; SEQUENCER_SETPICTURE_DISPLAYLIST
 dc.l SequencerFunction_wait_byte			; SEQUENCER_WAIT_BYTE
 dc.l SequencerFunction_wait_word			; SEQUENCER_WAIT_WORD
 dc.l SequencerFunction_wait_long			; SEQUENCER_WAIT_LONG
  
 SECTION BSS
 
 even
 
sequencer_ptr		ds.l 1
sequencer_delay		ds.w 1

 

 
