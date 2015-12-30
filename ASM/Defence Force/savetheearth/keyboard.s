

KEYTEST_STATE macro
key set \1
keybit set key&7
keybyte set key>>3
 btst.b #keybit,keyboard_matrix+keyboard_state+keybyte
 endm

KEYTEST_PRESSED macro
key set \1
keybit set key&7
keybyte set key>>3
 btst.b #keybit,keyboard_matrix+keyboard_pressed+keybyte
 endm

KEYTEST_RELEASED macro
key set \1
keybit set key&7
keybyte set key>>3
 btst.b #keybit,keyboard_matrix+keyboard_released+keybyte
 endm
 
KEYTEST_STATE_ANY macro
 lea keyboard_matrix+keyboard_state,a0	; 16 bytes
 move.l (a0)+,d0
 or.l (a0)+,d0
 or.l (a0)+,d0
 or.l (a0)+,d0
 endm 
 

; Main keyboard 
KEY_SPACE	 	equ $39 

; Arrows
KEY_ARROW_LEFT	equ $4b
KEY_ARROW_RIGHT equ $4d

; Numeric pad
KEY_NUMPAD_1	equ $6d
KEY_NUMPAD_2 	equ $6e
KEY_NUMPAD_3 	equ $6f
KEY_NUMPAD_4 	equ $6a
KEY_NUMPAD_5 	equ $6b
KEY_NUMPAD_6 	equ $6c
KEY_NUMPAD_7 	equ $67
KEY_NUMPAD_8 	equ $68
KEY_NUMPAD_9 	equ $69
KEY_NUMPAD_ENTER equ $72
 
 
 SECTION TEXT
 
 even
  
KeyboardManage
 ; Clear the existing press/release states
 lea keyboard_matrix,a0
 movem.l empty_line,d0-d7			; 32 bytes
 movem.l d0-d7,keyboard_pressed(a0)	; Erase both keyboard_pressed and keyboard_released tables

.loop 
 btst #0,$fffffc00.w
 beq.s .exit
 
 lea keyboard_matrix,a0
 
 moveq #0,d0
 move.b $fffffc02.w,d0
 
 move.b d0,d1
 and.w #%01111111,d1
 lsr.w #3,d1						; Which byte
 
 tst.b d0
 bmi.s .released
.pressed
 bset.b d0,keyboard_state(a0,d1)	; Key is pressed
 bset.b d0,keyboard_pressed(a0,d1)	; Key is pressed
 bra.s .loop
  
.released 
 bclr.b d0,keyboard_state(a0,d1)	; Key is no more pressed
 bset.b d0,keyboard_released(a0,d1)	; Key is released
 bra.s .loop
 
.exit
 rts
  
 
KeyboardFlushBuffer
 btst.b #0,$fffffc00.w			; Have we some keys to wait for ?
 beq.s .exit
 tst.b $fffffc02.w
 bra.s KeyboardFlushBuffer
.exit
 rts
  
 
KeyboardDefaultManager 
 KEYTEST_RELEASED KEY_SPACE
 bne.s .end_demo

 ifne enable_navigation
 KEYTEST_RELEASED KEY_ARROW_RIGHT
 bne.s .end_part 

 KEYTEST_RELEASED KEY_ARROW_LEFT
 bne.s .previous_part
 endc
 
 moveq #0,d0
 rts
 
.previous_part 
 sub.l #3*4*2,PtrSequencer
 bra.s .end_part 

.end_demo 
 st.b flag_end_program
.end_part 
 moveq #1,d0
 rts 
 
 
 
 SECTION BSS

 even

 rsreset
keyboard_state		rs.b 128/8		; 16 bytes
keyboard_pressed	rs.b 128/8		; 16 bytes
keyboard_released	rs.b 128/8		; 16 bytes
keyboard_size		rs.b 0
 
keyboard_matrix		ds.b keyboard_size

 even
 