;
;                                 MonoSlide
;
; 256 bytes monochrome mode intro by Dbug for Sommarhack 2022 (8th to 10 July)
;
;        - Idea came from the 2020 MindBender and the Monochrome compo -
;               Thanks to Tat for the 64bit rotation suggestion
;
; 268 bytes

enable_proper_setup		equ 0    ; Enables the tabbed out code for easier testing

 opt o+,w+

 	section TEXT
     
 clr.l -(sp)        
 move.w #$20,-(sp)           ; Switch to Supervisor mode
 trap #1
 ifne enable_proper_setup
	 addq.l #6,sp            ; We switch to supervisor, but never come back so no need to correct the stack pointer
	 move.l d0,-(sp)         ; Except during development process when it's nice to be able to go back to the editor
 endc
	
 dc.w $a00a                  ; Hide the mouse cursor

 pea Message(pc)             ; Print the "Dbug @ Sommarhack 2022" message (which also erases the screen)
 move.w #9,-(sp)
 trap #1
 ifne enable_proper_setup
 	addq.l #6,sp
 endc

loop_patterns
 addq.w #1,a6                ; Evolve the pattern

 moveq #1,d7                 ; By default we only wait one frame

 move.w a6,d4
 move.w d4,d5
 and.w #7,d5
 bne.s .end_pause
 moveq #71,d7                ; We are in Monochrome the screen is not at 50hz
.end_pause

 moveq.l #62,d5
 sub.w a6,d5

.delay_loop
 move.w #37,-(sp)       	 ; Vertical Synchronization (adds a 1/71th of a second delay)
 trap #14
 addq.l #2,sp

 ifne enable_proper_setup
	cmp.b #$39,$fffffc02.w   ; Keyboard check
	bne.s .no_key_pressed
	dc.w $a009               ; Show the mouse cursor
	move.w #$20,-(sp)  		 ; Return to user mode (using the stack value stored earlier)
 	trap #1
    addq.l #6,sp
	clr.w -(sp)              ; Back to the caller (Called Gemdos Pterm0)
	trap #1
.no_key_pressed  	
 endc

 dbra d7,.delay_loop

 ; Do some weird noise with the YM using the current shift registers
 lea YmData(pc),a0
 move.b d4,1(a0)
 move.b d5,3(a0)
 moveq #4-1,d0
.loop_ym
 move.b (a0)+,$ffff8800.w
 move.b (a0)+,$ffff8802.w
 dbra d0,.loop_ym 

 move.l $44e.w,a0            ; screenpt
 lea 160*11(a0),a0 

 moveq #0,d6                 ; Define a 64bit alternating pattern from black to white
 moveq #-1,d7

 moveq #5-1,d2
loop_alternate

 moveq #2-1,d1
loop_band
 
 bsr.s DrawGrayLine           ; Draw one separating gray line
 
 move.w #32*10-1,d0           ; Draw one row of alternated white and black blocks
loop_black_white_blocks
 move.l d6,(a0)+
 move.l d7,(a0)+
 dbra d0,loop_black_white_blocks 

 move.l d4,d3
 moveq #0,d0
 and #63,d3
.loop                         ; Rotates D6-D7 by D4 amount 
 add.l d6,d6
 addx.l d7,d7
 addx.l d0,d6
 dbra d3,.loop

 dbra d1,loop_band

 exg d4,d5                    ; Change the direction of patterns

 dbra d2,loop_alternate
 
 bsr.s DrawGrayLine           ; Draw one final gray line

 ifne enable_proper_setup
 bra loop_patterns
 else
 bra.s loop_patterns
 endc

DrawGrayLine                  ; Draw gray line - two pixels thick at a0
 moveq #80-1,d0
loop_separator_x 
 move.b #%01010101,80(a0)
 move.b #%10101010,(a0)+
 dbra d0,loop_separator_x 
 lea 80(a0),a0 
 rts

YmData
 dc.b 1,0              ; Channel A frequency (high byte)
 dc.b 6,0              ; Noise generator frequency
 dc.b 7,%11110110      ; Enable Channel A tone and noise
 dc.b 8,15             ; Channel A volume

Message
 dc.b 27,"E"                                             ; Erase the screen
 dc.b 174,"MonoSlide",175                                ; Write MonoSlide at the top left
 dc.b 27,"Y",32+23,32+0,"256 bytes"                      ; Write 256 bytes at the bottom left

 dc.b 27,"Y",32+23,32+58,"Dbug @ Sommarhack 2022"        ; And finally the signature at the bottom right
 dc.b 0

 end
