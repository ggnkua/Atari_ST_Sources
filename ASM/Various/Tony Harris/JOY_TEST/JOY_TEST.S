;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; JOYSTICK DEMO by Tony Harris
;
; Simply responds to the direction of the joystick by printing a message
; on the screen.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	opt	x+			Xdebug on

os_call	macro
	move.w	#\1,-(sp)
	trap	#\2
	lea	\3(sp),sp
	endm

; ^
; just a very simply macro to make life easy when doing
; TOS functions:

; 	\1..function number
;	\2..trap number (eg. 1,13,14)
;	\2..value to correct stack with


ptext	macro
	pea	\1
	os_call	9,1,6
	bra	joy_rout
	endm

; ^
; macro to print joystick directions
; bra's back to JOY_ROUT

j_up	equ	$1
j_down	equ	$2
j_right	equ	$8
j_left	equ	$4
j_ur	equ	$9
j_dr	equ	$a
j_ul	equ	$5
j_dl	equ	$6
j_blank	equ	$0
j_fire	equ	$80

; ^ equates for joystick directions (just to make life even easier)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; start program

	bsr	 init_joy	set up joystick routines

joy_rout	
	clr.w	joy_data	clear existing data, if any
	bsr	read_joy	read the joystick
	move.w	joy_data,d0	get data
	move.w	d0,d1		seperate - for ease of use

; d1 now contains the direction for the joystick !
; now we simply use CMP for our own little routines

	cmpi.w	#j_blank,d1		NO DIRECTION
	beq.s	joy_rout
	cmpi.w	#j_fire,d1		FIRE BUTTON
	beq	quit	 	
	cmp.w	#j_up,d1		UP
	beq.s	up		
	cmp.w	#j_down,d1		DOWN
	beq.s	down		
	cmp.w	#j_left,d1		LEFT
	beq.s	left		
	cmp.w	#j_right,d1		RIGHT
	beq.s	right		
	cmp.w	#j_ur,d1		UP - RIGHT
	beq.s	d_ur
	cmp.w	#j_dr,d1		DOWN - RIGHT
	beq.s	d_dr
	cmp.w	#j_dl,d1		DOWN - LEFT
	beq	d_dl
	cmp.w	#j_ul,d1		UP - LEFT
	beq.s	d_ul

; ^
; more could be added, ie

;	cmp.w	#$81,d0		$81 = fire button and pushed up
;	beq.s	fire_up

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ptext is a macro that simply display the joystick direction
; then bra's to JOY_ROUT

up	ptext	up_text
down	ptext	down_text
left	ptext	left_text
right	ptext	right_text
d_ur	ptext	d_ur_text
d_dr	ptext	d_dr_text
d_ul	ptext	d_ul_text
d_dl	ptext	d_dl_text

quit
	bsr.s	joy_term
	bsr.s	mouse_rel
	
	clr.l	-(sp)
	os_call	$4c,1,0
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; SUBROUTINES START HERE.

init_joy
	os_call	34,14,2			use kdvbase
	move.l	d0,a0			save result
	move.l	24(a0),gem_joy		save original
	lea	our_joy,a1		
	move.l	a1,24(a0)		replace with our own

; ^
; using xbios function #34, kbdvbase. We need to first save the vector
; table then re-route the existing joystick packet handler to our own
; so the next time our one will be used instead.
;
; GEM_JOY is the existing routine, now on the shelf.
; OUR_JOY is our new routine.

	pea	joy_off
	move.w	#0,-(sp)
	os_call	25,14,8		simply switches auto reporting off
	rts

; ^
; we need to end the automatic reporting for the joystick ($15)
; we used xbios function #25 (ikbdws)



mouse_rel
	pea	r_mouse
	move.w	#0,-(sp)
	os_call	25,14,8		switches mouse to relative mode
	rts

; ^
; just in case we will return the mouse to relative mode
; using xbios #25

read_joy
	pea	r_joy
	move.w	#0,-(sp)
	os_call	25,14,8		reads the joystick
	rts
; ^
; we need to read the joystick ($16)
	 		

our_joy
	clr.w	d0		clear and ready d0
	move.b	1(a0),d0	strip out required data
	move.w	d0,joy_data	load it into buffer
	rts			

; ^
; this is the routine that will replace the existing one
; this simply strips out the direction out of the packet
; and stuffs it in a buffer called joy_data


* When I've finished, put back the GEM handler as if nothing happened
joy_term
	os_call	34,14,2
	move.l	d0,a0
	move.l	gem_joy,a1
	move.l	a1,24(a0)	restore the original
	rts

; ^
; this does the reverse of the init routine.
; it simply replaces the existing routine (our own)
; with the original routine.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	section data

gem_joy		dc.l	1		used in init_joy
joy_data	dc.w	1		used in joy_rout

joy_off		dc.b	$15		used in init_joy
r_joy		dc.b	$16		used_in joy_rout
r_mouse		dc.b	$08		used in quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; the text for the screen

up_text
	dc.b	27,"H",27,'K'
	dc.b	"Joystick UP",0
down_text
	dc.b	27,"H",27,'K'
	dc.b	"Joystick DOWN",0
left_text
	dc.b	27,"H",27,'K'
	dc.b	"Joystick LEFT",0
right_text
	dc.b	27,"H",27,'K'
	dc.b	"Joystick RIGHT",0
d_ur_text
	dc.b	27,"H",27,'K'
	dc.b	"Joystick UP - RIGHT",0
d_dr_text
	dc.b	27,"H",27,'K'
	dc.b	"Joystick DOWN - RIGHT",0
d_ul_text
	dc.b	27,"H",27,'K'
	dc.b	"Joystick UP - LEFT",0
d_dl_text
	dc.b	27,"H",27,'K'
	dc.b	"Joystick DOWN - LEFT",0

	end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
