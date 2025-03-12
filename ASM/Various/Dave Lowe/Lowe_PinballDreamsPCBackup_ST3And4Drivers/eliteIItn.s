




	;	 	ELITEII/FRONTIERS TEST SOURCE


	; DAVID
	;The place to insert your call for a new song
	; is called song_select
	; all the tunes branch there on ending except
	; The title tune now has a section tagged on the front
	; that runs straight into the main piece....song 10
	; it fades itself in
	; and plays for app. 23 seconds......

	; you can still run tune 2 on its own if you wish
	; using song 2
	; An fx that is retriggered before it ends a previous
	; call is now only turned off in the interrupt section
	; so it should cure the click problem on the lazers etc.

	;the wind fx requires you to kill it using kill_fx
	;and the duplicate one will now be out of sync.



	;there is now a fade_up routine and a fade_out routine
	;they require the fade  rate (1 to 50)to be held in
	;d0 when calling..(this is the number of frames before
	;increasing or decreasing the value in FADE by #1)


	; the fxjump table now contains 2 more fx
	;ship_to_ship and camera


	; It must be assembled with SYMBOLS CASE independent.

	; dont hesitate to ring with any problems

	;		DAVE LOWE.....0723  870648

;		**************************

	section issA,code_c	;must be in low memory for dma access
				;DEVPAC PSEUDO OP ..CAN BE DELETED


;*****************************************

		;  ALL EQUs

a00  equ  508*2
bb00  equ  480*2
b00  equ  453*2
c01  equ  428*2
db01  equ  404*2
d01 equ  381*2
eb01  equ  360*2
e01  equ  339*2
f01  equ  320*2
gb01  equ  302*2
g01  equ  285*2
ab01 equ 269*2
a01  equ  508
bb01  equ  480
b01  equ  453

c02  equ  428
db02  equ  404
d02  equ  381
eb02  equ  360
e02  equ  339
f02  equ  320
gb02  equ  302
g02  equ  285
ab02 equ 269
a02  equ  254
bb02  equ  240
b02  equ  226

c03  equ  214
db03  equ  202
d03  equ  190
eb03  equ  180
e03  equ  170
f03  equ  160
gb03  equ  151
g03  equ  143
ab03 equ 135
a03  equ  127

bb03  equ  480*2
b03  equ  453*2

c04  equ  428*2
db04  equ  404*2
d04 equ  381*2
eb04  equ  360*2
e04  equ  339*2
f04  equ  320*2
gb04  equ  302*2
g04  equ  285*2
ab04 equ 269*2
a04  equ  508
bb04  equ  480
b04  equ  453

c05  equ  428
db05  equ  404
d05  equ  381
eb05  equ  360
e05  equ  339
f05  equ  320
gb05  equ  302
g05  equ  285
ab05 equ 269
a05  equ  254
bb05  equ  240
b05  equ  226

c06  equ  214
db06  equ  202
d06  equ  190
eb06  equ  180
e06  equ  170
f06  equ  160
gb06  equ  151
g06  equ  143
ab06 equ 135
a06  equ  127
bb06  equ  480*2
b06  equ  453*2

c07  equ  428*2
db07  equ  404*2
d07 equ  381*2
eb07  equ  360*2
e07  equ  339*2
f07  equ  320*2
gb07  equ  302*2
g07  equ  285*2
ab07 equ 269*2
a07  equ  508
bb07  equ  480
b07  equ  453

c08  equ  428
db08  equ  404
d08  equ  381
eb08  equ  360
e08  equ  339
f08  equ  320
gb08  equ  302
g08  equ  285
ab08 equ 269
a08  equ  254
bb08  equ  240
b08  equ  226


v equ 0

no_loop equ 0
loop equ 0
chann1reg   equ $dff0a0    
chann2reg   equ $dff0b0
chann3reg   equ $dff0c0
chann4reg   equ $dff0d0
dmacon     equ $dff096
int_bf_int   equ   $dff01e
int_bf_w    equ   $dff09a
vhposr     equ   $dff006
in_line    equ   0
new_snd    equ   4
end_song     equ   1
end_patt    equ   8
new_env    equ   12
pbend     equ   16



hi: equ 223
lo:  equ 446

r22	equ 134
r20	equ 179		;correctum
r19	equ 150
r18	equ 178
r17	equ 200
r16:	equ 227		;correctum
r15:	equ 249
r14	equ 280
r13:	equ 305
r12:	equ 333
r11:	equ 361
r10:	equ 389
r9:	equ 419
r8:	equ 446
r7:	equ 446+112
r6:	equ 446+223
r5:	equ 446+223+112
r4:	equ 446*2
r3:	equ 446*3
r2:	equ 446*4
r1:	equ 446*8


filter: equ $bfe001
filter_on equ 44
filter_off equ 48

modon     equ   20
pboff     equ   24
modoff     equ   28
rest     equ 32
end_fxp  equ 36
end_fx3  equ 36
end_fx4  equ 40
acc	equ 52
repeat	equ 56
play_new_tune  equ 60  
down      equ   1
up       equ   2

;***************************************************************


 ;    THIS IS THE CONTROL SECTION FOR TESTING AS A STAND ALONE PRG. 

	;	   AND CAN BE DELETED WHEN NOT REQUIRED

	;bra test_engine
	jsr select_new_song	;select first song and initiliase

testloop:
	jsr delay	;wait for scan line  at 50hz on pal


	;move.l #10,fx_number		 every frame lazer test
	;move.w #64,d1
	;jsr set_up_fx


	;jsr test_fade
	;jsr en2	;a test engine call
	jsr driver	;call music every interrupt


	;move.l #10,fx_number
	;move.w #64,d1
	;jsr set_up_fx	

        bra testloop    ;loop back

;**************************************

				;dff00c  joystick port 1
			; bit1 right switch
			; bit9 left
			; bit 1 xor bit 0 for pulled back
			; 9 xor 8 for forward




delay:
	tst.w fxtimer
	;bne no_test
	clr.l d0
	move.b $bfe001,d0		;
	btst #6,d0
	bne no_test1
	move.w #10,fxtimer
	bra testfx4
no_test
	subq #1,fxtimer
no_test1
	clr.l d0
        move.w vhposr,d0
        andi.w #%1111111100000000,d0
        cmpi.w #%1111111100000000,d0

	bne no_test1
	rts

testfx4:  

	;jsr	kill_chip
	;move.w #1,int_disable
	clr.l d0
	move.b $bfe001,d0
	btst #6,d0
	beq testfx4

	move.l song_buffer,d0
	addq.l #1,d0
	cmp.l	#11,d0			; 10 tunes in this test
					; 8 = silence
	bne nores	
	move.l #1,d0

;*******************************        HOW TO PLAY A NEW TUNE

nores	move.l d0,song_buffer

	;jsr	select_new_song		;this call sets up the tune
					;number in the song buffer
					;make sure music is enabled (see below)
					;call is currently commented off
					;so you can play fx over one tune


;*******************************    HOW TO KILL ANY LOOPED FX

	move.l fx_last,d0
	move.l d0,fx_kill	;  used on this demo

	;jsr kill_loopfx	; used to kill any  fx..not engines


no_k
        move.l fx_no,fx_number
	move.l fx_no,fx_last
	addq.l #1,fx_no
	move.l	max_fx,d0
        cmp.l fx_no,d0
	bne noreset
	move.l #39,fx_no	
noreset: 

;;**********************************  HOW TO PLAY AN FX ON THE
				    ; NEXT 50th
				    ; place fx number required in fx_no
				    ; and do this call
				    ; fx must be enabled...(see below)

;test_fade
 	move.w #64,d1
	;sub.w #1,d1
	;cmp #0,d1
	;bgt novr	
	;move #64,testv
	;move.w #64,d1
;novr	;move.w d1,testv
	;move.w d1,fade
	
			; test vol for variable vol fx


	;cmp.l #31,fx_number
	;bne no_kill
	;jsr kill_all_fx
	;rts

no_kill

	cmp.l #37,fx_number
	beq nof			;duplicate infinite wind


	cmp.l #14,fx_number
	beq twinfx
	jsr set_up_fx
	;jsr en2

	;jsr kill_engine

nof	rts

twinfx  jsr set_up_fx
	move.l #37,fx_number
	jsr set_up_fx
	rts



testv	dc.w 64

;***************************************************************
		

		;;TEST ROUTINES SETTING UP AND UPDATING
		;; TWO DIFFERENT ENGINES

				;d0 = engine type 1 to 3
				;d1 = engine vol
				;d2 = engine rate
				;d3 = engine seed (ident number)
				;  up to word value 


test_engines

	tst.w ref
	beq doe1
	rts

ref	dc.w 0

doe1
	move.w #1,ref
	move.w #1,d0
	move.w test_vol,d1
	tst.w d1
	beq nosub
	;sub.w #1,d1
nosub	move.w d1,test_vol
	move.w test_rate,d2
	cmp.w #130,d2
	blt nosubx
	sub.w #20,d2
nosubx	
	;move.w d2,test_rate
	move.w #101,d3

jjj1	jsr engines
	rts

en2	

test_fade

	tst.w tek
	bne fo

	add.w #1,en2x
	cmp.w #10,en2x
	blt fo

	clr.w en2x
	move.w #3,d0		;run 2nd engine
	move.w #20,d1
	move.w #400,d2
	move.w #50,d3

;test_fade


 	;move.w testv,d1
	;sub.w #1,d1
	;cmp #0,d1
	;bgt novr	
	;move #0,testv
	;move.w #0,d1
novr	;move.w d1,testv
	;move.w d1,fade

	jsr engines
fo	rts



kill_engine

	move.w #1,tek
	move.w #3,d0		
	move.w #1,d1	;vol to 1
	move.w #400,d2
	move.w #50,d3
	jsr engines
	rts



en2x		dc.w 0
test_rate	dc.w 500
test_vol	dc.w 60
tek		dc.w 0

;***********************************

				; variables used by the test section
tflag		dc.w 0
fxtc:  		dc.w 10		; ignore them !!!!!
fx_no:	 	dc.l  5
fx_last		dc.l  5


;		END OF CONTROL (DELETABLE) SECTION

;**********************************************************

; --------------------------------------------------------------

;    MAIN VARIABLES TO BE ACCESSED BY PROGRAMMER DURING RUNTIME


fx_number: 	dc.l 0 ;     number of fx required here...
fx_kill		dc.l 0 ;     number of fx to kill/only needed for looped fx

song_buffer 	dc.l 10;     number of piece of music required here ie.1 to 10

music_disable:  dc.w 0 ;     1 = disable music
fx_disable:     dc.w 0 ;     1 = disable fx  (currently disabled)

fade 		dc.w 0;      to fade music/fx out increase the
			; value in this location from 0 to 64
			; 0 = normal vol 64= silent.

;    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;  THESE VARIABLES ARE USED INTERNALLY BY THE DRIVER
fxr1 		dc.l 0  
fxr2 		dc.l 0  
fxr3 		dc.l 0  
fxr4 		dc.l 0  
fxc1		dc.l 0
fxc2	  	dc.l 0
fxc3		dc.l 0
fxc4  		dc.l 0
fxce1		dc.w 0
fxce2		dc.w 0
fxce3		dc.w 0
fxce4		dc.w 0
fx1_flag	dc.w 0
fx2_flag	dc.w 0
fx3_flag	dc.w 0
fx4_flag	dc.w 0
fx_c_used	dc.w 0
fxtimer		dc.w 0
gen		dc.w 0
int_disable	dc.w 0
altpf     	dc.w 0
kill_flag	dc.w 0
fx_mode		dc.w 0
existing_fx	dc.w 0
channel_to_use  dc.w 0
fflag		dc.w 0
ftimer		dc.w 0		;temp counter
frate		dc.w 0
mode		dc.w 0

;  *******************************************************

;  CALL THIS SUBROUTINE TO SET UP THE REQUIRED FX
;  on entry it requires the fx number to be in "fx_number"(see above)

;********************
;        move.w #204,d0
;        lea gvars,a0
;clloop: clr.w (a0)+        
;        dbra  d0,clloop
;************************
set_up_fx
				;d1 holds vol for certain fx
	move.w #1,int_disable

	movem.l d0/d1/d2/d5/a0/a2,-(a7)	;save used registers
	clr.w existing_fx		;flag
	clr.w channel_to_use		;channel to use

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				;test for fx already running on a channel
				;and if so then store which channel
	move.l fxc4,d0
	move.w #4,channel_to_use
	cmp.l fx_number,d0
	beq set_e_flag			

	move.l fxc3,d0
	move.w #3,channel_to_use
	cmp.l fx_number,d0
	beq set_e_flag			

	move.l fxc2,d0
	move.w #2,channel_to_use
	cmp.l fx_number,d0
	beq set_e_flag			

	move.l fxc1,d0
	move.w #1,channel_to_use
	cmp.l fx_number,d0
	beq set_e_flag			

	bra new_fx

		;  fx already on a channel
set_e_flag
	move.w #1,existing_fx

	cmp.l #35,fx_number
	beq check35

	cmp.l #36,fx_number
	beq check36

	cmp.l #5,fx_number		;vv test
	blt fixed_vol			;engine
	cmp.l #13,fx_number
	bgt test_for_loop
				;this is a variable vol existing fx			
				;is it louder than the existing fx ??
		
	move.l fx_number,d2
	cmp.l #5,d2
	bne isevv6
	cmp.w vv1,d1
	blt no_fx		;too quiet so drop it
	bra new_fx

isevv6
	cmp.l #6,d2
	bne isevv7
	cmp.w vv2,d1
	blt no_fx		;too quiet so drop it
	bra new_fx

isevv7
	cmp.l #7,d2
	bne isevv8
	cmp.w vv3,d1
	blt no_fx		;too quiet so drop it
	bra new_fx

isevv8
	cmp.l #8,d2
	bne isevv9
	cmp.w vv4,d1
	blt no_fx		;too quiet so drop it
	bra new_fx


isevv9	cmp.l #9,d2
	bne isevv10
	cmp.w vv5,d1
	blt no_fx		;too quiet so drop it
	bra new_fx
	
isevv10
	cmp.l #10,d2
	bne isevv11
	cmp.w vv6,d1
	blt no_fx		;too quiet so drop it
	bra new_fx

isevv11
	cmp.l #11,d2
	bne isevv12
	cmp.w vv7,d1
	blt no_fx		;too quiet so drop it
	bra new_fx

isevv12
	cmp.l #12,d2
	bne isevv13
	cmp.w vv8,d1
	blt no_fx		;too quiet so drop it
	bra new_fx

isevv13
	cmp.w vv8,d1
	blt no_fx		;too quiet so drop it
	bra new_fx

check35
	cmp.w vv10,d1
	blt no_fx
	bra new_fx

check36

	cmp.w vv11,d1
	blt no_fx

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
new_fx
	cmp.l #35,fx_number
	beq write35

	cmp.l #36,fx_number
	beq write36

	cmp.l #5,fx_number
	blt fixed_vol
	cmp.l #13,fx_number
	bgt test_for_loop
				;variable vol fx
	move.l fx_number,d2
	cmp.l #5,d2
	beq writevv1
	cmp.l #6,d2
	beq writevv2
	cmp.l #7,d2
	beq writevv3
	cmp.l #8,d2
	beq writevv4
	cmp.l #9,d2
	beq writevv5
	cmp.l #10,d2
	beq writevv6
	cmp.l #11,d2
	beq writevv7

	lea vv8,a0	;write12 and 13
	bra wv

writevv7
	lea vv7,a0
	bra wv
writevv6
	lea vv6,a0
	bra wv
writevv5
	lea vv5,a0
	bra wv
writevv4
	lea vv4,a0
	bra wv
writevv3
	lea vv3,a0
	bra wv
writevv2
	lea vv2,a0
	bra wv
writevv1
	lea vv1,a0

wv	move.w d1,(a0)	
	bra fixed_vol

write35
	lea vv10,a0
	bra wv

write36
	lea vv11,a0
	bra wv



; ............................
test_for_loop
	cmp.l #17,fx_number
	bgt fixed_vol

	move.l fx_number,d2
				;is this fx already running
	cmp.l fxc4,d2
	beq is_on
	cmp.l fxc3,d2
	beq is_on
	cmp.l fxc2,d2
	beq is_on
	cmp.l fxc1,d2
	beq is_on
				;fx not already on
	bra set_loop_counters	;so set it up and run it

is_on
	cmp.l #14,d2		;wind ?
	bne cl2
	move.w #2,loopc1	;reset timer
	bra no_fx

cl2
	cmp.l #15,d2		;space_stat ?
	bne cl3
	move.w #1,loopc2	;reset timer
	bra no_fx

cl3
	cmp.l #16,d2		;factories?
	bne cl4
	move.w #2,loopc3	;reset timer
	bra no_fx

cl4
	cmp.l #17,d2		;fuelscoop?
	bne fixed_vol
	move.w #2,loopc4	;reset timer
	bra no_fx

set_loop_counters

	cmp.l #14,d2		;wind ?
	bne cl2x
	move.w #1,loopc1	;reset timer
	bra fixed_vol

cl2x
	cmp.l #15,d2		;space_stat ?
	bne cl3x
	move.w #1,loopc2	;reset timer
	bra fixed_vol

cl3x
	cmp.l #16,d2		;factories?
	bne cl4x
	move.w #2,loopc3	;reset timer
	bra fixed_vol

cl4x
	cmp.l #17,d2		;fuelscoop?
	bne no_fx
	move.w #2,loopc4	;reset timer


;..............................
fixed_vol


	cmp.l #31,fx_number
	beq use4		;ship die to 4


	tst.w existing_fx
	beq sort_channel
				;find channel to overwrite existing fx on

	cmp.w #4,channel_to_use
	beq	use4
	cmp.w #3,channel_to_use
	beq	use3
	cmp.w #2,channel_to_use
	beq	use2
	bra 	use1
;     ****************


sort_channel
	tst.l fxc4
	bne check3
	tst.w fxce4
	bne check3

use4:	
	move.w #%0000000000001000,d5
	lea chann4reg,a2
	;jsr end_fx4p
	;move.l #0,fxc4

ch4xx	move.w #32,d0
	lea fxintc4,a0
cfx4l:  clr.w (a0)+	
	dbra d0,cfx4l


	move.l fx_number,fxr4
	move.l fx_number,fxc4
	move.l #0,fx_number
	move.w #4,fx_c_used		;channel used
	bra no_fx


check3:	tst.l fxc3
	bne check2
	tst.w fxce3
	bne check2
use3:
	move.w #%0000000000000100,d5
	lea chann3reg,a2
	;jsr end_fx3p
	;move.l #0,fxc3

ch3xx	move.w #32,d0
	lea fxintc3,a0
cfx3l:  clr.w (a0)+	
	dbra d0,cfx3l
	move.l fx_number,fxr3
	move.l fx_number,fxc3
	move.l #0,fx_number
	move.w #3,fx_c_used		;channel used
	bra no_fx




check2:	tst.l fxc2
	bne check1
	tst.w fxce2
	bne check1
use2:
	move.w #%0000000000000010,d5
	lea chann2reg,a2
	;jsr end_fx2p
	;move.l #0,fxc2

ch2xx	move.w #32,d0
	lea fxintc2,a0
cfx2l:  clr.w (a0)+	
	dbra d0,cfx2l

	move.l fx_number,fxr2
	move.l fx_number,fxc2
	move.l #0,fx_number
	move.w #2,fx_c_used		;channel used
	bra no_fx
check1:	tst.l fxc1
	bne  no_room
	tst.w fxce1
	bne no_room


use1
	move.w #%0000000000000001,d5
	lea chann1reg,a2
	;jsr end_fx1p
	;move.l #0,fxc1

ch1xx	move.w #32,d0
	lea fxintc1,a0
cfx1l:  clr.w (a0)+	
	dbra d0,cfx1l

	move.l fx_number,fxr1
	move.l fx_number,fxc1
	move.l #0,fx_number
	move.w #1,fx_c_used		;channel used

no_fx
	clr.w int_disable
	movem.l (a7)+,d5/d2/d1/d0/a2/a0	;restore registers
	rts
no_room
	tst.w fx_mode
	beq  overwrite			;actual fx

	move.w #255,fx_c_used		; no channel used
	bra no_fx



overwrite
	tst.w fxce4
	bne oc3
	bra use4
oc3	tst.w fxce3
	bne oc2
	bra use3
oc2	tst.w fxce2
	bne oc1
	bra use2
oc1	tst.w fxce1
	bne use1
	bra use1

;*************************************************
; 		 CALL HERE TO KILL ANY FX...
;       after putting the number of the fx you want to kill
;			into fx_kill

kill_loopfx

	movem.l d5/a2,-(a7)	;save used registers
	move.l fx_kill,d5
	cmp.l fxc1,d5
	bne k2
	move.w #%0000000000000001,d5
	lea chann1reg,a2
	jsr end_fx1p
	bra error
k2	cmp.l fxc2,d5
	bne k3
	move.w #%0000000000000010,d5
	lea chann2reg,a2
	jsr end_fx2p
	bra error
k3	cmp.l fxc3,d5
	bne k4
	move.w #%0000000000000100,d5
	lea chann3reg,a2
	jsr end_fx3p
	bra error
k4	cmp.l fxc4,d5
	bne error
	move.w #%0000000000001000,d5
	lea chann4reg,a2
	jsr end_fx4p
error
	clr.l fx_kill
	movem.l (a7)+,d5/a2	;restore registers
	rts
;************************************************

	;CALL HERE TO KILL ALL FX

kill_all_fx:

	movem.l d5/a0,-(a7)	;save used registers

	move.w #%0000000000001000,d5
	lea chann4reg,a2
	jsr end_fx4p
	move.w #32,d0
	lea fxintc4,a0
cfx4lx:  clr.w (a0)+	
	dbra d0,cfx4lx

	move.w #%0000000000000100,d5
	lea chann3reg,a2
	jsr end_fx3p
	move.w #32,d0
	lea fxintc3,a0
cfx3lx:  clr.w (a0)+	
	dbra d0,cfx3lx

	move.w #%0000000000000010,d5
	lea chann2reg,a2
	jsr end_fx2p
	move.w #32,d0
	lea fxintc2,a0
cfx2lx:  clr.w (a0)+	
	dbra d0,cfx2lx

	move.w #%0000000000000001,d5
	lea chann1reg,a2
	jsr end_fx1p
	move.w #32,d0
	lea fxintc1,a0
cfx1lx:  clr.w (a0)+	
	dbra d0,cfx1lx

	movem.l (a7)+,d5/a0	;restore registers
	rts


;*************************************************

	; CALL HERE TO KILL ANY SOUND for whatever reason

kill_chip:
	move.w #%0000000000001111,dmacon
	move.l rest_data,chann1reg
	move.l rest_data,chann2reg
	move.l rest_data,chann3reg
	move.l rest_data,chann4reg
	move.w #16,chann1reg+4	
	move.w #16,chann2reg+4	
	move.w #16,chann3reg+4	
	move.w #16,chann4reg+4	
	move.w #0,chann1reg+8
	move.w #0,chann2reg+8
	move.w #0,chann3reg+8
	move.w #0,chann4reg+8
	move.w #1,chann1reg+6
	move.w #1,chann2reg+6
	move.w #1,chann3reg+6
	move.w #1,chann4reg+6
	move.l #0,fxr1
	move.l #0,fxr2
	move.l #0,fxr3
	move.l #0,fxr4
	move.w #0,fx1_flag
	move.w #0,fx2_flag
	move.w #0,fx3_flag
	move.w #0,fx4_flag
	move.l #0,fxc1
	move.l #0,fxc2
	move.l #0,fxc3
	move.l #0,fxc4
	clr.w fx_mode
	rts

;*******************************

			;d0 holds fade rate value 0 to 50
fade_up	
	move.w #1,fflag	;set flag for up
	move.w d0,frate
	move.w #64,fade		;fade value to max
	rts

fade_out
fade_down
	move.w #2,fflag	;set flag for up
	move.w d0,frate
	move.w #0,fade		;fade value to max
	rts


;*****************************
engines
	movem.l d4/d5/d6/a2/a0/a1,-(a7)	;save used registers

	;ENGINE RUNTIME ROUTINES

				;d0 = engine type 1 to 3
				;d1 = engine vol
				;d2 = engine rate
				;d3 = engine seed (ident number)

				;check engine has legal volume
	tst.w d1
	beq end_engine		;drop it
	cmp.w #64,d1
	bgt end_engine


		;decide if engine is new
	lea engine1_vars,a1
	tst.w (a1)
	beq ten2
	cmp.w engine1_seed,d3

	beq existing_engine  
ten2
	lea engine2_vars,a1
	tst.w (a1)
	beq ten3
	cmp.w engine2_seed,d3
	beq existing_engine  
ten3
	lea engine3_vars,a1
	tst.w (a1)
	beq ten4
	cmp.w engine3_seed,d3
	beq existing_engine  
ten4
	lea engine4_vars,a1
	tst.w (a1)
	beq setup_engine
	cmp.w engine4_seed,d3
	beq existing_engine  
				;engine not already in range
				;so find if spare channel available

setup_engine
	cmp.w #1,d0 					
	bne sej1
	lea engine1p,a0
	bra set_p
sej1	cmp.w #2,d0 	
	bne sej3				
	lea engine2p,a0
	bra set_p
sej3	lea engine3p,a0
set_p
				;a0 = engine type address	
	tst engine1_vars	
	bne te2
ue1	lea engine1_vars,a1
	lea current_engine1_fx,a2
	move.l #1,d6
	bra do_set_up
te2
	tst engine2_vars	
	bne te3
ue2	lea engine2_vars,a1
	lea current_engine2_fx,a2
	move.l #2,d6
	bra do_set_up
te3
	tst engine3_vars	
	bne te4
ue3	lea engine3_vars,a1
	lea current_engine3_fx,a2
	move.l #3,d6
	bra do_set_up
te4
	tst engine4_vars	
	bne test_vols
ue4	lea engine4_vars,a1
	lea current_engine4_fx,a2
	move.l #4,d6
	bra do_set_up

test_vols			;all channels running so
				;find current smallest vol
	move.w #1,d5
	move.w engine1_vol,d4
	cmp engine2_vol,d4
	blt test3		;1 is smaller than 2
	move.w #2,d5
	move.w engine2_vol,d4
test3
	cmp engine3_vol,d4	
	blt test4		;1 or 2 is smaller
	move.w #3,d5
	move.w engine3_vol,d4
test4
	cmp engine4_vol,d4
	blt vol_test_d
	move.w #4,d5
	move.w engine4_vol,d4
vol_test_d			;smallest vol engine number in d5
				;its volume in d4
      	cmp.w d1,d4 		;cmp new vol
	bgt end_engine		;drop new engine fx.......	
	cmp.w #1,d5		
	beq ue1
	cmp.w #2,d5		
	beq ue2
	cmp.w #3,d5		
	beq ue3
	bra ue4

do_set_up
	jsr pass_p		;write paramters to vars


				; write parameters to fx pattern
	move.l a0,8(a2)
	move.w d2,12(a2)				
	move.w #200,14(a2)	;2 second min	
	move.w d1,20(a2)

	move.l d6,(fx_number)

	move.w #1,(fx_mode)
	jsr set_up_fx
	clr.w (fx_mode)	
				;d0 = amiga channel used
	cmp #255,fx_c_used
	beq end_engine		;no free channels
	move.w fx_c_used,14(a1)	;channel to vars
	move.w fx_c_used,d0
	cmp.w #4,d0
	bne re3	
	clr.l fxc4
	move.w #1,fxce4
	bra end_engine

re3
	cmp.w #3,d0
	bne re2	
	clr.l fxc3
	move.w #1,fxce3
	bra end_engine

re2
	cmp.w #2,d0
	bne re1	
	clr.l fxc2
	move.w #1,fxce2
	bra end_engine

re1
	clr.l fxc1
	move.w #1,fxce1

end_engine
	movem.l (a7)+,d5/d4/d6/a2/a1/a0	;restore registers
	rts

;                        """"""""""""""""""""""""""""""
existing_engine
	jsr passpj1
	jsr update_engine
	bra end_engine

pass_p				;a1 = which engine vars to use/d5=1 to 4
				;a0 = address of type parameters

	move.w #1,(a1)		;reset flag/count to 1

			;first turn off the engine already on this channel
	move.w 14(a1),d4
	cmp.w #4,d4
	bne pj1
	clr.w fxce4	
	bra passpj1
pj1	cmp.w #3,d4
	bne pj2
	clr.w fxce3	
	bra passpj1
pj2	cmp.l #2,d4
	bne pj3
	clr.w fxce2	
	bra passpj1
pj3	clr.w fxce1	

passpj1	

		;pass engine parameters to engine vars	
	move.w #1,(a1)		;set on/off flag
	move.w d0,2(a1)
	move.w d1,4(a1)
	move.w d2,6(a1)
	move.w d3,8(a1)
	move.l a0,10(a1)
	clr.w 16(a1)
	rts

update_engine		; (a0)= engine vars
			;only used after driver has set sample running
		
	move.l a1,a0
	clr.w 16(a0)		;timer to 0
update2
	move.w 14(a0),d0	;amiga channel
	cmp.w #4,d0
	bne uej1
	tst.l fxc4
	bne off_engine
	lea chann4reg,a1
	bra write_engine

uej1	cmp.w #3,d0
	bne uej2
	tst.l fxc3
	bne off_engine
	lea chann3reg,a1
	bra write_engine

uej2	cmp.w #2,d0
	bne uej3
	tst.l fxc2
	bne off_engine
	lea chann2reg,a1
	bra write_engine
uej3
	tst.l fxc1
	bne off_engine
	lea chann1reg,a1
	bra write_engine

off_engine
	clr.w (a0)		;flag to off
	clr.w 8(a0)		;seed to 0
	rts

write_engine		;a1 points to registers
	move.w 4(a0),8(a1)	;vol to chip
	move.w 6(a0),6(a1)	;rate to chip
	rts



;@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			;current engine pattern buffer

current_engine1_fx
  	        dc.w new_env
  	 	dc.l current_engine1_env
  	        dc.w new_snd
	  	dc.l 0			;+8	;paramters

		dc.w	0		;+12   rate
		dc.w	0		;+ 14 duration
		

  	dc.w end_fxp

current_engine1_env:	dc.w 0,0,255	;+20 vol


current_engine2_fx
  	dc.w new_env
  	dc.l current_engine2_env
  	dc.w new_snd
  	dc.l 0

ce2_rate	dc.w	0
ce2_time	dc.w	0		;1 sec max without refresh	
		

  	dc.w end_fxp

current_engine2_env:	dc.w 0,0,255


current_engine3_fx
  	dc.w new_env
   	dc.l current_engine3_env
  	dc.w new_snd
  	dc.l 0

ce3_rate	dc.w	0
ce3_time	dc.w	0		;1 sec max without refresh	
		

  	dc.w end_fxp

current_engine3_env:	dc.w 0,0,255


current_engine4_fx
  	dc.w new_env
  	dc.l current_engine4_env
  	dc.w new_snd
  	dc.l 0

ce4_rate	dc.w	0
ce4_time	dc.w	0		;1 sec max without refresh	
		

  	dc.w end_fxp

current_engine4_env:	dc.w 0,0,255


engine1_vars	dc.w 0		;on off flag
engine1_type	dc.w 0
engine1_vol	dc.w 0
engine1_rate	dc.w 0
engine1_seed	dc.w 0		;+8
engine1_type_p	dc.l 0		;address of type 1 to 3
acu1		dc.w 0		;amiga channel used
e1timer		dc.w 0


engine2_vars	dc.w 0
engine2_type	dc.w 0
engine2_vol	dc.w 0
engine2_rate	dc.w 0
engine2_seed	dc.w 0
engine2_type_p	dc.l 0
acu2		dc.w 0		;amiga channel used
e2timer		dc.w 0


engine3_vars	dc.w 0
engine3_type	dc.w 0
engine3_vol	dc.w 0
engine3_rate	dc.w 0
engine3_seed	dc.w 0
engine3_type_p	dc.l 0
acu3		dc.w 0		;amiga channel used
e3timer		dc.w 0


engine4_vars	dc.w 0
engine4_type	dc.w 0
engine4_vol	dc.w 0
engine4_rate	dc.w 0
engine4_seed	dc.w 0
engine4_type_p	dc.l 0
acu4		dc.w 0		;amiga channel used
e4timer		dc.w 0


;****************************************

;  CALL HERE TO SELECT WHICH PIECE OF MUSIC TO PLAY
;  AFTER PLACING NUMBER (1 to ?) IN "SONG_BUFFER"..see above
;  a call to this routine will initiliase the driver/kill any sound etc.	  
;  make sure this routine has been called before running the interrupt
;  driven section....see below

start_timer	dc.w 0

select_new_song:

	move.w #1,int_disable
	movem.l d0/d1/a0/a1,-(a7)	;save used registers
	move.w music_disable,gen
	move.w #1,music_disable
        jsr kill_chip           
	clr.l d0
        move.w #204,d0
        lea gvars,a0
clloop: clr.w (a0)+        
        dbra  d0,clloop
	tst.l song_buffer
	beq no_song
        move.l song_buffer,d1
	add.l d1,d1
 	add.l d1,d1
 	add.l d1,d1
 	add.l d1,d1
        LEA  SONG_TABLE-16,A1
        add.l d1,a1      
        MOVE.L (A1)+,WSONG1    
        move.l (a1)+,wsong2    
        move.l (a1)+,wsong3
	move.l (a1),wsong4
        MOVE.L #pstart,PATTR1
        MOVE.L #pstart,PATTR2
        MOVE.L #pstart,PATTR3
	move.l #pstart,pattr4
        move.l #sstart,songr1
        MOVE.L #sstart,SONGR2
        MOVE.L #sstart,SONGR3
	move.l #sstart,songr4
no_song
	move.w #1,ch1vars
	move.w #2,ch2vars
	move.w #3,ch3vars
	move.w #4,ch4vars
	move.w #6,ch4fxvars
	move.w #5,ch3fxvars
	move.w #7,ch2fxvars
	move.w #8,ch1fxvars
	move.w gen,music_disable
	clr.w int_disable
	clr.w fade
	clr.w fflag
	clr.w engine1_vars
	clr.w engine2_vars
	clr.w engine3_vars
	clr.w engine4_vars
	clr.w fxce1
	clr.w fxce2
	clr.w fxce3
	clr.w fxce4

	cmp.l #10,song_buffer		;intro tagged piece
	bne no_sps
	move.w #12,d0 	
	jsr fade_up
no_sps
	movem.l (a7)+,d0/d1/a0/a1	;restore registers
        rts

;**************************************************

;  CALL HERE ON A 50hz INTERRUPT DURING RUNTIME
;  TO PLAY FX AND TUNES

driver:  

	tst.w int_disable
	beq process_data
	rts		
process_data
	movem.l d0-d6/a0-a6,-(a7)	;save used registers

;******************************
				;fade section
	tst.w fflag
	beq proj1
	cmp.w #1,fflag
	bne tfo
	move.w ftimer,d0
	add.w #1,d0
	move.w d0,ftimer
	cmp.w frate,d0
	bne proj1
	sub.w #1,fade
	clr.w ftimer
	tst.w fade
	bne proj1
	clr.w fflag
	bra proj1
tfo
	move.w ftimer,d0
	add.w #1,d0
	move.w d0,ftimer
	cmp.w frate,d0
	bne proj1
	add.w #1,fade
	clr.w ftimer
	cmp.w #64,fade
	bne proj1
	clr.w fflag

;*******************************
proj1
	lea engine1_vars,a0
	tst.w (a0)
	beq tt2
	add.w #1,16(a0)
	cmp.w #51,16(a0)
	blt tt2
	sub.w #1,4(a0)
	jsr update2

tt2

	lea engine2_vars,a0
	tst.w (a0)
	beq tt3
	add.w #1,16(a0)
	cmp.w #51,16(a0)
	blt tt3
	sub.w #1,4(a0)
	jsr update2

tt3
	lea engine3_vars,a0
	tst.w (a0)
	beq tt4
	add.w #1,16(a0)
	cmp.w #51,16(a0)
	blt tt4
	sub.w #1,4(a0)
	jsr update2
tt4
	lea engine4_vars,a0
	tst.w (a0)
	beq etf
	add.w #1,16(a0)
	cmp.w #51,16(a0)
	blt etf
	sub.w #1,4(a0)
	jsr update2

etf

;^^^^^^^^^^^^^^^^^^^^^^^^^^^
		;service engine vars
		; if an engine volume is at 0 then turn it off

	lea engine1_vars,a0
	tst.w (a0)
	beq tev2		;no engine here
	cmp.w #1,4(a0)		;vol at 0
	bgt tev2
rb	clr.w (a0)
	clr.w 8(a0)
	clr.w 16(a0)
	move.w acu1,d0
	jsr clear_amiga_channel


tev2
	lea engine2_vars,a0
	tst.w (a0)
	beq tev3		;no engine here

	cmp.w #1,4(a0)		;vol at 0
	bgt tev3
	clr.w (a0)
	clr.w 8(a0)
	clr.w 16(a0)
	move.w acu2,d0
	jsr clear_amiga_channel

tev3
	lea engine3_vars,a0
	tst.w (a0)
	beq tev4		;no engine here
	cmp.w #1,4(a0)		;vol at 0
	bgt tev4
	clr.w (a0)
	clr.w 8(a0)
	clr.w 16(a0)
	move.w acu3,d0
	jsr clear_amiga_channel
tev4
	lea engine4_vars,a0
	tst.w (a0)
	beq ch1			;no engine here
	cmp.w #1,4(a0)		;vol at 0
	bne ch1
	clr.w (a0)
	clr.w 8(a0)
	clr.w 16(a0)
	move.w acu4,d0
	jsr clear_amiga_channel
	bra ch1

clear_amiga_channel
	cmp.w #4,d0
	bne cac2
	clr.w fxce4
  	move.w #%0000000000001000,d5 
	lea chann4reg,a2
	jsr end_fx4p

	rts
cac2	cmp.w #3,d0
	bne cac3
	clr.w fxce3
  	move.w #%0000000000000100,d5 
	lea chann3reg,a2
	jsr end_fx3p

	rts
cac3	cmp.w #2,d0
	bne cac4
	clr.w fxce2
  	move.w #%0000000000000010,d5 
	lea chann2reg,a2
	jsr end_fx2p
	rts

cac4	cmp.w #1,d0
	bne cac5
	clr.w fxce1
  	move.w #%0000000000000001,d5 
	lea chann1reg,a2
	jsr end_fx1p
cac5	rts



;^^^^^^^^^^^^^^^^^^^^^^^^^^^

ch1:
	tst.w fx_disable
	bne test_music1
	tst.l fxr1
	bne   ch1j1

	tst.l fxc1
	beq test_music1
	bra ch1j3
ch1j2	jsr run_dummy1
	jsr run_fx1
	bra ch2
ch1j1
	jsr set_up1
ch1j3	tst.w music_disable	
	beq ch1j2
	jsr run_fx1
	bra ch2
test_music1

	tst.w fxce1
	beq noe1
	jsr run_dummy1
	bra ch2


noe1
	tst.w music_disable
	bne ch2
	jsr run_music1
	bra ch2
	;***********************

	; channel 1 subroutines

run_dummy1	
	move.w #1,mode
 	lea ch1vars,a0
 	lea dummy_reg,a2 
 	move.w #0,d5 
 	move.w #0,d1
 	jsr sect1	
	rts

set_up1	

    	jsr endc_fx1p

         move.l fxr1,d0
         add d0,d0
         add d0,d0
         lea  fxjump_table-4,A1
	 add.l d0,a1
         move.l (a1),currfx1
 	 clr.l fxr1
	 clr.w fxintc1
 	 rts
  
 	
run_fx1
	move.w #0,mode

	lea ch1fxvars,a0
   	lea chann1reg,a2
  	move.w #%0000000000000001,d5 
 	move.w #%1000001000000001,d1 
 	jsr sect1
	rts

run_music1
	move.w #1,mode

	lea ch1vars,a0
   	lea chann1reg,a2
  	move.w #%0000000000000001,d5 
  	move.w #%1000001000000001,d1 
  	jsr sect1     
	rts

	;  **************************
ch2
	tst.w fx_disable
	bne test_music2
	tst.l fxr2
	bne   ch2j1
	tst.l fxc2
	beq test_music2
	bra ch2j3

ch2j2	jsr run_dummy2
	jsr run_fx2
	bra ch3
ch2j1
	jsr set_up2
ch2j3	tst.w music_disable	
	beq ch2j2
	jsr run_fx2
	bra ch3

test_music2


	tst.w fxce2
	beq noe2
	jsr run_dummy2
	bra ch3


noe2


	tst.w music_disable
	bne ch3
	jsr run_music2
	bra ch3
	;***********************
	; channel 2 subroutines
run_dummy2	
	move.w #1,mode

 	lea ch2vars,a0
 	lea dummy_reg,a2 
 	move.w #0,d5 
 	move.w #0,d1
 	jsr sect1	
	rts

set_up2	

	jsr endc_fx2p


         move.l fxr2,d0
         add d0,d0
         add d0,d0
         lea  fxjump_table-4,A1
	 add.l d0,a1
         move.l (a1),currfx2
 	 clr.l fxr2
	 clr.w fxintc2
 	 rts
  
 	
run_fx2
	move.w #0,mode

	lea ch2fxvars,a0
   	lea chann2reg,a2
  	move.w #%0000000000000010,d5 
 	move.w #%1000001000000010,d1 
 	jsr sect1
	rts

run_music2
	move.w #1,mode

	lea ch2vars,a0
   	lea chann2reg,a2
  	move.w #%0000000000000010,d5 
  	move.w #%1000001000000010,d1 
  	jsr sect1     
	rts

	;  **************************

ch3:
	tst.w fx_disable
	bne test_music3
	tst.l fxr3
	bne   ch3j1
	tst.l fxc3
	beq test_music3
	bra ch3j3
ch3j2	jsr run_dummy3
	jsr run_fx3
	bra ch4
ch3j1
	jsr set_up3
ch3j3	tst.w music_disable	
	beq ch3j2
	jsr run_fx3
	bra ch4

test_music3


	tst.w fxce3
	beq noe3
	jsr run_dummy3
	bra ch4


noe3



	tst.w music_disable
	bne ch4
	jsr run_music3
	bra ch4

	;***********************

	; channel 3 subroutines

run_dummy3	
	move.w #1,mode

 	lea ch3vars,a0
 	lea dummy_reg,a2 
 	move.w #0,d5 
 	move.w #0,d1
 	jsr sect1	
	rts

set_up3	

	jsr endc_fx3p


         move.l fxr3,d0
         add d0,d0
         add d0,d0
         lea  fxjump_table-4,A1
	 add.l d0,a1
         move.l (a1),currfx3
 	 clr.l fxr3
	 clr.w fxintc3
 	 rts
  
 	
run_fx3
	move.w #0,mode

	lea ch3fxvars,a0
   	lea chann3reg,a2
  	move.w #%0000000000000100,d5 
 	move.w #%1000001000000100,d1 
 	jsr sect1
	rts

run_music3
	move.w #1,mode

	lea ch3vars,a0
   	lea chann3reg,a2
  	move.w #%0000000000000100,d5 
  	move.w #%1000001000000100,d1 
  	jsr sect1     
	rts

	;  **************************

ch4:
	tst.w fx_disable
	bne test_music4
	tst.l fxr4
	bne   ch4j1
	tst.l fxc4
	beq test_music4
	bra ch4j3
ch4j2	jsr run_dummy4
	jsr run_fx4
	bra no4
ch4j1
	jsr set_up4
ch4j3	tst.w music_disable	
	beq ch4j2
	jsr run_fx4
	bra no4

test_music4


	tst.w fxce4
	beq noe4
	jsr run_dummy4
	bra no4


noe4
	tst.w music_disable
	bne no4
	jsr run_music4
no4	
	movem.l (a7)+,d0-d6/a0-a6	;restore registers
	rts

	;***********************

	; channel 4 subroutines

run_dummy4	
	move.w #1,mode

 	lea ch4vars,a0
 	lea dummy_reg,a2 
 	move.w #0,d5 
 	move.w #0,d1
 	jsr sect1	
	rts

set_up4	

	jsr endc_fx4p


         move.l fxr4,d0
         add d0,d0
         add d0,d0
         lea  fxjump_table-4,A1
	 add.l d0,a1
         move.l (a1),currfx4
 	 clr.l fxr4
	 clr.w fxintc4
 	 rts
  
 	
run_fx4

	move.w #0,mode

	lea ch4fxvars,a0
   	lea chann4reg,a2
  	move.w #%0000000000001000,d5 
 	move.w #%1000001000001000,d1 
 	jsr sect1
	rts

run_music4

	move.w #1,mode

	lea ch4vars,a0
   	lea chann4reg,a2
  	move.w #%0000000000001000,d5 
  	move.w #%1000001000001000,d1 
  	jsr sect1     
	rts
	;  **************************

sect1: 
	;tst.w 0(a0)
	;bne s1j1
	;rts

s1j1:	tst.w 2(a0)
        beq sect3       
        cmpi.w #1,2(a0)
        beq sect4

        cmpi.w #3,4(a0)    
        beq part2       
    
mode_switch:  subq.w #1,2(a0)     

check_effects: clr.w altpf      
        move.w 6(a0),d2    
        tst.w 8(a0)      
        beq check_mod
        tst.w 14(a0)      
        beq cont_bend
        subq.w #1,14(a0)
        bra check_mod
cont_bend:   addq.w #1,altpf    
        move.w 10(a0),d3    
        move.w 12(a0),d4    
        cmpi.w #1,8(a0)
        beq pbup
    
        sub.w d3,d2
        cmp.w d2,d4
        bcs check_mod
        bra fbend

pbup:     add.w d3,d2
        cmp.w d2,d4
        bcc check_mod
fbend:     move.w d4,d2
        clr.w 8(a0)      
check_mod:   tst.w 16(a0)
        beq send_alt_pitch
   

	tst.w  58(a0)
	beq st_ok
	subq.w #1,58(a0)
	bra send_alt_pitch
st_ok:
        tst.w 50(a0)
        beq cont_mod
        subq #1,50(a0)
        bra send_alt_pitch
cont_mod:    move.w 52(a0),50(a0)  
        addq #1,altpf
        cmpi #3,16(a0)
        bcc addmod
    
        move.w 56(a0),d3 
        sub.w d3,d2
        addq.w #1,16(a0)  
        bra send_alt_pitch
addmod:

        move.w 54(a0),d3 
        add.w d3,d2
        addq.w #1,16(a0)
        cmpi.w #5,16(a0)
       bne send_alt_pitch
        move.w #1,16(a0)  

send_alt_pitch: tst.w altpf
        beq send_env
        move.w d2,6(a0)  
        move.w d2,6(a2)  

send_env: 

do_env_check:

norm_env:
	tst.w mode
	beq fxenv

	move.l 18(a0),a1    
        cmpi.w #255,(a1)
        beq env_finished

resu	clr.l d0
	move.w (a1)+,d0
	sub.w fade,d0
	bcc sete
	move.w #0,d0
sete	move.w d0,8(a2)	
	move.l a1,18(a0)
	rts		

env_finished:
	subq.l #2,a1	
	bra resu

fxenv
	move.l 18(a0),a1    
        cmpi.w #255,(a1)
        beq env_finishedx

resux	clr.l d0
	move.w (a1)+,d0
	move.w d0,8(a2)	
	move.l a1,18(a0)
	rts		

env_finishedx:
	subq.l #2,a1	
	bra resux






one_shot_note: move.w #3,4(a0)     
        move.l 38(a0),(a2)
        move.w 42(a0),4(a2)
        move.w d1,dmacon     
        bra send_env

 
part2:                         
        move.l 44(a0),(a2)
        move.w 48(a0),4(a2)
        subq.w #1,2(a0)      
        move.w #1,4(a0)
        bra check_effects

sect3:
	move.w 0,66(a0)	

    move.l 22(a0),a1  
control_ret: move.w (a1)+,d0  
    cmpi.w #100,d0   
    bls sect5   
  
acc_note:
    move.w d0,6(a0)  
    move.w d0,6(a2)  
    move.w (a1)+,2(a0) 
    subq.w #1,2(a0)  
    move.l a1,22(a0)  
    move.l 34(a0),18(a0) 
    move.w 60(a0),58(a0) 


	tst.w 16(a0)
	beq no_mod_res
	move.w #1,16(a0)
no_mod_res:
    cmpi.w #0,4(a0)
    beq do_loop
    bra one_shot_note    

 
do_loop:    move.w d1,dmacon   
        bra send_env

do_rest:
    move.w (a1)+,2(a0) 
    subq.w #1,2(a0)  
    move.l a1,22(a0)  
    move.l  #rest_env,18(a0)

        move.w #0,8(a2)
        bra send_env
   
sect4:
        cmpi.w #0,4(a0)
        beq noof
        move.w d5,dmacon   
noof:     subq.w #1,2(a0)
        bra check_effects
   
sect5:     move.l #jump_table,a3
        move.l (a3,d0),a4
        jmp (a4)

jump_table: 
	dc.l  in_line_data
        dc.l  nsound
        dc.l  patt_end
        dc.l  get_env
        dc.l  check_pbend
        dc.l  do_mod
        dc.l  bend_off
        dc.l  mod_off
        dc.l  do_rest
        dc.l  end_fx
        dc.l  end_fx
	dc.l  s_f_on
	dc.l  s_f_off
	dc.l  set_acc
	dc.l  rept
	dc.l  song_select


in_line_data:

        nop
        rts

rept:

	tst.w (a1)
	bne round_again

	add.l #6,a1
	move.l (a1),a1
	bra control_ret

round_again
	subq.w #1,(a1)	;decrease counter
	add.l #2,a1
	move.l (a1),a1
	bra control_ret

s_f_on: 
	bclr #1,filter
	bra control_ret
s_f_off:
	bset #1,filter
	bra control_ret

nsound:    move.l (a1)+,a3     
        cmpi.w #0,(a3)
        bne one_shot_sound
        move.w (a3)+,4(a0)    
        move.l (a3)+,(a2)     
        move.w (a3),4(a2)    
        jmp control_ret

one_shot_sound:
        move.w (a3)+,4(a0)
        move.l (a3)+,38(a0)   
        move.l (a3)+,42(a0)
        move.l (a3),46(a0)
        jmp control_ret

patt_end:
        move.l 26(a0),a1    
        cmpi.l #0,(a1)     
        beq song_control
        addq.l #4,26(a0)    
        move.l (a1),a1     
        jmp control_ret
get_env: 
	move.l (a1)+,a4 

	move.l (a4)+,62(a0)	
	
	move.l  a4,34(a0)	
	
        bra control_ret

check_pbend:
	 move.l (a1)+,8(a0)
        move.l (a1)+,12(a0)
        bra control_ret

do_mod:    move.w #1,16(a0)  
        move.l (a1)+,50(a0)
        move.l (a1)+,54(a0)
        move.l (a1)+,58(a0)
        bra control_ret

bend_off:   clr.w 8(a0)
        bra control_ret

mod_off:    clr.w 16(a0)
        bra control_ret


end_fx:	
	cmpi.w #6,(a0)
	beq end_fx4p

	cmpi.w #5,(a0)
	beq end_fx3p

	cmpi.w #7,(a0)
	beq end_fx2p

	cmpi.w #8,(a0)
	beq end_fx1p
	rts

end_fx1p:
        move.w #%0000000000000001,dmacon   
	move.w  #1,chann1reg+6
	move.w #0,chann1reg+8
	move.l #0,fxc1
	rts

end_fx2p:
	move.w #%0000000000000010,dmacon 
	move.w  #1,chann2reg+6
        move.w #0,chann2reg+8 
	move.l #0,fxc2
        rts


end_fx3p:
        move.w #%0000000000000100,dmacon   
	move.w  #1,chann3reg+6
	move.w #0,chann3reg+8
	move.l #0,fxc3
	rts

end_fx4p:

	move.w #%0000000000001000,dmacon 
	move.w  #1,chann4reg+6
        move.w #0,chann4reg+8
	move.l #0,fxc4
        rts


endc_fx1p:
        move.w #%0000000000000001,dmacon   
	move.w  #1,chann1reg+6
	move.w #0,chann1reg+8
	;move.l #0,fxc1
	rts

endc_fx2p:
	move.w #%0000000000000010,dmacon 
	move.w  #1,chann2reg+6
        move.w #0,chann2reg+8 
	;move.l #0,fxc2
        rts


endc_fx3p:
        move.w #%0000000000000100,dmacon   
	move.w  #1,chann3reg+6
	move.w #0,chann3reg+8
	;move.l #0,fxc3
	rts

endc_fx4p:

	move.w #%0000000000001000,dmacon 
	move.w  #1,chann4reg+6
        move.w #0,chann4reg+8
	;move.l #0,fxc4
        rts







set_acc: move.w #1,66(a0) 
	bra control_ret

song_control:			;these instructions reset the
        addq.l #4,a1
        move.l 30(a0),26(a0)	;song pointers to the start for looping
        move.l 26(a0),a1
        addq.l #4,26(a0)
        move.l (a1),a1
        jmp control_ret			;dont change this


	;"""""""""""""""""""""""""""""""""""""""""""""""""
song_select:

			;A CALL HERE TO A ROUTINE THAT SELECTED
			;A NEW TUNE/PLACED THE NUMBER IN SONG_BUFFER
			;AND CALLED select_new_song WOULD START
 			;A DIFFERENT TUNE
			
			;test code only..replace with your own


	move.l song_buffer,d0
	addq.l #1,d0
	cmp.l	#10,d0			; 9 tunes in this test
	bne noresx	
	move.l #1,d0
noresx	move.l d0,song_buffer

	jsr	select_new_song		;this call sets up the new tune

	rts


;-----------------------------------------------










	;;; DATA

song_table:

	dc.l 	s1,s2,s3,s4			;hall of m kings
	dc.l 	s5,s6,s7,s8			;title tune
	dc.l	sbaba1,sbaba2,sbaba3,sbaba4	;baba yaga
	dc.l	sgg1,sgg2,sgg3,sgg4		;great gates
	dc.l	bds1,bds2,bds3,bds4		;blue danube
	dc.l	jalt1,jalt2,jalt3,jalt4		;alternative to jupiter
	dc.l	rvs1,rvs2,rvs3,rvs4		;ride valkries
	dc.l 	ssilent,ssilent,ssilent,ssilent ;silent	
	dc.l	bm1,bm2,bm3,bm4			;b mountain
	dc.l	intro5,intro6,intro7,intro8

;************************************************************
gvars:
ch1vars     
	dc.w 0     
        dc.w 0,0,0,0,0,0,0,0,0,0     
pattr1: dc.l 0    
songr1: dc.l 0    
wsong1: dc.l 0   
        dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   

ch2vars     
	dc.w 0     
        dc.w 0,0,0,0,0,0,0,0,0,0     
pattr2: dc.l 0    
songr2: dc.l 0    
wsong2: dc.l 0    
        dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   

ch3vars 
	dc.w 0     
        dc.w 0,0,0,0,0,0,0,0,0,0     
pattr3: dc.l 0    
songr3: dc.l 0    
wsong3: dc.l 0    
        dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   

ch4vars 
	dc.w 0     
        dc.w 0,0,0,0,0,0,0,0,0,0     
pattr4: dc.l 0    
songr4: dc.l 0    
wsong4: dc.l 0    
        dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   

	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


ch1fxvars 
	dc.w 0     
fxintc1:
	dc.w 0,0,0,0,0,0,0,0,0,0     
currfx1:
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    

ch2fxvars 
	dc.w 0     
fxintc2:
	dc.w 0,0,0,0,0,0,0,0,0,0     
currfx2:
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    


ch3fxvars
	dc.w 0     
fxintc3:
	dc.w 0,0,0,0,0,0,0,0,0,0     
currfx3:
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    

ch4fxvars 
	dc.w 0     
fxintc4:
	dc.w 0,0,0,0,0,0,0,0,0,0     
currfx4:
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0    
;************************************************************

dummy_reg dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


;************************************************************

;       THESE ARE THE FX PATTERNS................

; The interrupt counter in these patterns is dependent on the
; playback speed.The figure is calculated as follows
; (length/playback speed) *50
; the figure then needs rounding up to give a clear finish
; if you have the count longer than needed it will cut
; out the music on the relevent channel for longer than
; neccessary and make it sound jerky
; The fx table is below the patterns


fuelscoopfx
  	dc.w new_env
  	dc.l fs_env
  	dc.w new_snd
  	dc.l rumblep
fsr	dc.w pbend,up,5,r20,1
	dc.w	r12,48

	dc.w repeat
loopc4	dc.w 2
	dc.l fsr,fsend
fsend  	dc.w new_env
  	dc.l fs_env2
	dc.w pbend,down,10,r6,1
	dc.w r12,40

  	dc.w end_fxp

fs_env:		dc.w 0,64,64,64,255
fs_env2		dc.w 0,64,60,57,55,52
		dc.w 0,50,47,45,43,40
		dc.w 40,37,35,33,30
		dc.w 30,27,25,23,20
		dc.w 20,17,15,13,10
		dc.w 10,7,5,3,0,255


;***************
damagefx
  	dc.w new_snd
  	dc.l snarep
  	dc.w new_env
  	dc.l damage_env
	dc.w modon,1,1,2,5,1,1
	dc.w r1,50
  	dc.w end_fxp

damage_env:			dc.w 0,64,64,64,64,64,64,64,64,64,64,64,64,64,64
				dc.w 60,58,55,53,40,45,44,42,40,38,35,34,33
				dc.w 32,30,28,25,22,20,18,15,12,10,7,5,4,0,255
;******************

shieldfx
  	dc.w new_snd
  	dc.l hissp
  	dc.w new_env
  	dc.l shield_env
	;dc.w modon,2,2,30,30,1,1
	dc.w r20,50
  	dc.w end_fxp

shield_env:			dc.w 0,64,64,64,64,64,60,57,53,50,47,45,40,37
				dc.w 35,31,28,25,22,20,18,15,12,10,7,5,4,0,255
;******************

clunckfx
  	dc.w new_snd
  	dc.l doorclosp
  	dc.w new_env
  	dc.l clunk_env
	dc.w r5,10
  	dc.w end_fxp

clunk_env:			dc.w 0,64,64,64,255
;******************


missile_launch

	dc.w pbend,up,10,r12,1
  	dc.w new_snd
  	dc.l hisslp
  	dc.w new_env
  	dc.l hiss2_env
	dc.w r4,80
	dc.w pboff
  	dc.w end_fxp

ml_env:			dc.w 0,64,64,64,255
;******************


hyper_space
  	dc.w new_snd
  	dc.l hyperp
  	dc.w new_env
  	dc.l h_env
	dc.w r3,130
  	dc.w end_fxp

h_env:			dc.w 0,64,64,64,255
;******************





factroarfx
  	dc.w new_env
  	dc.l roar_env
  	dc.w new_snd
  	dc.l rumblep
fr	dc.w	r1,72

	dc.w repeat
loopc3	dc.w 2
	dc.l fr,frend

frend
  	dc.w new_env
  	dc.l roar_env2

	dc.w	r1,40

  	dc.w end_fxp

roar_env:			dc.w 0,64,64,64,255
roar_env2:
		dc.w 0,64,60,57,55,52
		dc.w 0,50,47,45,43,40
		dc.w 40,37,35,33,30
		dc.w 30,27,25,23,20
		dc.w 20,17,15,13,10
		dc.w 10,7,5,3,0,255


;*******************************


undercfx_up:
  	dc.w new_env
  	dc.l underc_env
  	dc.w new_snd
  	dc.l hissp
	dc.w pbend,up,20,r6,1
	dc.w	r4,112
  	dc.w new_snd
  	dc.l doorclosp
	dc.w r10,4,r4,24
  	dc.w end_fxp

underc_env:			dc.w 0,0
vv8				dc.w 44,255

;*************
undercfx_down:
  	dc.w new_env
  	dc.l underc_env
  	dc.w new_snd
  	dc.l hissp
	dc.w pbend,down,10,r4,1
	dc.w	r6,112
  	dc.w new_snd
  	dc.l doorclosp
	dc.w r6,4,r6,24
  	dc.w end_fxp

;*************

airlock1fx:
  	dc.w new_env
  	dc.l hiss_env
  	dc.w new_snd
  	dc.l hissp
	dc.w r3,140

  	dc.w new_env
  	dc.l doorclos_env
  	dc.w new_snd
  	dc.l airlockp
	dc.w	r3,47
  	dc.w end_fxp

doorclos_env:			dc.w 0,64,64,64,255
hiss_env:
	dc.w 0,64,64,64,255

;*************************
airlock2fx:

  	dc.w new_env
  	dc.l hiss_env
  	dc.w new_snd
  	dc.l hissp
	dc.w r3,140

  	dc.w new_env
  	dc.l doorclos_env
  	dc.w new_snd
  	dc.l airlockp
	dc.w	r3,47
  	dc.w end_fxp

  	dc.w end_fxp

;*********************








space_station_backfx:

  	dc.w new_env
  	dc.l stb_env
  	dc.w new_snd
  	dc.l hissp
ssr	dc.w r1,127
	dc.w	repeat
loopc2	dc.w	1
	dc.l	ssr,ssend

ssend  	dc.w new_env
  	dc.l stb1_env
	dc.w r1,30
  	dc.w end_fxp

stb_env:	dc.w 0,50,50,50,255
stb1_env
		dc.w 0,50,47,45,43,40
		dc.w 40,37,35,33,30
		dc.w 30,27,25,23,20
		dc.w 20,17,15,13,10
		dc.w 10,7,5,3,0,255


;***********************

bongfx
	dc.w pboff
  	dc.w new_env
  	dc.l bong_env
  	dc.w new_snd
  	dc.l bongp

	dc.w r3,20
  	dc.w end_fxp

bong_env:	dc.w 0,64,64,64,255

;***********************

bellfx
	dc.w pboff
  	dc.w new_env
  	dc.l bell_env
  	dc.w new_snd
  	dc.l bongp
	dc.w modon,2,2,30,30,1,1

	dc.w r2,30
  	dc.w end_fxp

bell_env:	dc.w 0,64,64,64,255

;***********************

target_confirmedfx
	dc.w pboff
  	dc.w new_env
  	dc.l tg_env
  	dc.w new_snd
  	dc.l bongp

	dc.w r16,2,r8,2,r16,2,r8,2
	dc.w r16,2,r8,2,r16,2,r8,2
  	dc.w end_fxp

tg_env:	dc.w 0,64,64,64,255

;***********************


lazer2_pr1fx
  	dc.w new_env
  	dc.l lazer2_env
  	dc.w new_snd
  	dc.l lazer2p
	dc.w r3,25

  	dc.w end_fxp

lazer2_env:	dc.w 0,0
vv6		dc.w 64,255

;***********************

lazer1_pr1fx
  	dc.w new_env
  	dc.l lazer1_env
  	dc.w new_snd
  	dc.l lazer1p
	dc.w r2,25

  	dc.w end_fxp

lazer1_env:	dc.w 0,0
vv7		dc.w 64,255



;***********************


;***********************


lazer4_pr1fx
  	dc.w new_env
  	dc.l lazer4_env
  	dc.w new_snd
  	dc.l lazer2p
	dc.w r3,25

  	dc.w end_fxp

lazer4_env:		dc.w 0,0
vv10		dc.w 64,255

;***********************

lazer3_pr1fx
  	dc.w new_env
  	dc.l lazer3_env
  	dc.w new_snd
  	dc.l lazer1p
	dc.w r2,25

  	dc.w end_fxp

lazer3_env:	dc.w 0,0
vv11		dc.w 64,255



;***********************

wind2
  	dc.w new_snd
  	dc.l windp

wr2	

  	dc.w new_env
  	dc.l wind_env1
	dc.w pbend,up,2,r3-40,1
	dc.w	r2,100

	dc.w	pboff
  	dc.w new_env
  	dc.l wind_env2
	dc.w	r3-40,50

  	dc.w new_env
  	dc.l wind_env3
	dc.w pbend,down,10,r2,1
	dc.w	r3-40,100


  	dc.w new_env
  	dc.l wind_env1
	dc.w pbend,up,20,r3-30,1
	dc.w	r2,50

	dc.w	pboff
  	dc.w new_env
  	dc.l wind_env4
	dc.w	r3-30,100

  	dc.w new_env
  	dc.l wind_env2
	dc.w pbend,down,8,r2-10,1
	dc.w	r3-30,80

  	dc.w new_env
  	dc.l wind_env3

	dc.w r2-4,120,r2-5,130
  	dc.w new_env
  	dc.l wind_env5
	dc.w r2,120


	dc.w repeat
	dc.w 2
	dc.l wr2,wr2
 	dc.w end_fxp




windfx
  	dc.w new_snd
  	dc.l windp

wr	

  	dc.w new_env
  	dc.l wind_env1
	dc.w pbend,up,2,r3-40,1
	dc.w	r2,100

	dc.w	pboff
  	dc.w new_env
  	dc.l wind_env2
	dc.w	r3-40,50

  	dc.w new_env
  	dc.l wind_env3
	dc.w pbend,down,10,r2,1
	dc.w	r3-40,100


  	dc.w new_env
  	dc.l wind_env1
	dc.w pbend,up,20,r3-30,1
	dc.w	r2,100

	dc.w	pboff
  	dc.w new_env
  	dc.l wind_env4
	dc.w	r3-30,100

  	dc.w new_env
  	dc.l wind_env2
	dc.w pbend,down,8,r2-10,1
	dc.w	r3-30,80


  	dc.w new_env
  	dc.l wind_env3

	dc.w r2-4,120,r2-5,130
  	dc.w new_env
  	dc.l wind_env5
	dc.w r2,120


	dc.w repeat
loopc1	dc.w 2
	dc.l wr,wr

wend  	dc.w end_fxp

wind_env1:	dc.w 0,0,10,12,15,17,20,21,22,24,25,26,29,32,34,37,38,40,42,43,44,44,40,40,38
		dc.w 40,45,255
wind_env2:	dc.w 0,0,44,42,40,48,46,44,43,40,45,43,40,37,36,35,33,30,25,28,26,25
		dc.w 20,18,15,12,255
wind_env3:	dc.w 0,0,12,255

wind_env4:	dc.w 0,0,40,255

wind_env5:	dc.w 0,15,15,15,14,14,14,13,12,11,10,9,10,255


;***********************



ship_diefx
  	dc.w new_env
  	dc.l sd_env
  	dc.w new_snd
  	dc.l exp1p
	dc.w r1,160

  	dc.w end_fxp


sd_env:	dc.w 0,0,0,64,255

;***********************


;***********************


exp1fx
  	dc.w new_env
  	dc.l exp1_env
  	dc.w new_snd
  	dc.l exp1p
	dc.w r4,40

  	dc.w end_fxp


exp1_env:	dc.w 0,0
vv4		dc.w 64,255

;***********************



exp2fx
  	dc.w new_env
  	dc.l exp2_env
  	dc.w new_snd
  	dc.l exp1p
	dc.w r2,65

  	dc.w end_fxp


exp2_env:	dc.w 0,0
vv5		dc.w 64,255

;***********************

beepfx
	dc.w pboff
  	dc.w new_env
  	dc.l beep_env
  	dc.w new_snd
  	dc.l bongp
	dc.w r12,30

  	dc.w end_fxp

beep_env:	dc.w 0,64,64,64,255

;***********************


ecm1fx
	dc.w pboff
  	dc.w new_env
  	dc.l xbomb2_env
  	dc.w new_snd
  	dc.l alarmp
	dc.w pbend,up,1,r2,1
	dc.w	r1,100

  	dc.w end_fxp

xbomb2_env:	dc.w 0,64,64,64,255

;***********************

ecm2fx
	dc.w pboff
  	dc.w new_env
  	dc.l xbomb2_env
  	dc.w new_snd
  	dc.l alarmp
	dc.w pbend,up,1,r2,1
	dc.w	r4,100

  	dc.w end_fxp


;***********************

alarm2fx
	dc.w pboff
  	dc.w new_env
  	dc.l alarm_env
  	dc.w new_snd
  	dc.l alarmp
	dc.w pbend,up,50,r9,1
	dc.w	r6,14
	dc.w pbend,up,50,r9,1
	dc.w	r6,14
	dc.w pbend,up,50,r9,1
	dc.w	r6,14
	dc.w pbend,up,50,r9,1
	dc.w	r6,14
	dc.w pbend,up,50,r9,1
	dc.w	r6,14
	dc.w pbend,up,50,r9,1
	dc.w	r6,14
	dc.w pbend,up,50,r9,1
	dc.w	r6,14
	dc.w pbend,up,50,r9,1
	dc.w	r6,14
  	dc.w end_fxp

alarm_env:	dc.w 0,64,64,64,255

;***********************


energy_bombfx
	dc.w pboff
  	dc.w new_env
  	dc.l xbomb2_env
  	dc.w new_snd
  	dc.l alarmp
	dc.w modon,1,1,100,100,1,1
	dc.w	r16,50*7
  	dc.w end_fxp


xbomb_env:	dc.w 0,64,64,64,255




expbig1_fx
	dc.w pboff
  	dc.w new_env
  	dc.l eb1_env
  	dc.w new_snd
  	dc.l expbigp
	dc.w	r4,86
  	dc.w end_fxp



eb1_env:	dc.w 0,0
vv1		dc.w 64,255


expbig2_fx
	dc.w pboff
  	dc.w new_env
  	dc.l eb2_env
  	dc.w new_snd
  	dc.l expbigp
	dc.w	r6,58
  	dc.w end_fxp


eb2_env:	dc.w 0,0
vv2		dc.w 64,255


expbig3_fx
	dc.w pboff
  	dc.w new_env
  	dc.l eb3_env
  	dc.w new_snd
  	dc.l expbigp
	dc.w	r3,172
  	dc.w end_fxp


eb3_env:   dc.w 0,0
vv3	   dc.w 64,255

hiss_fx
	dc.w pboff
  	dc.w new_env
  	dc.l hiss2_env
  	dc.w new_snd
  	dc.l hisslp
	dc.w	r8,68
  	dc.w end_fxp


hiss2_env:	dc.w 64,64,64,63,60,60,60
	   dc.w 60,59,58,57,56,55,54,53,52,51
	   dc.w 50,49,48,47,46,45,44,43,42,41
	   dc.w 40,39,38,37,36,35,34,33,32,31
	   dc.w 30,29,28,27,26,25,24,23,22,21
	   dc.w 20,19,18,17,16,15,14,13,12,11
	   dc.w 10,9,8,7,6,5,4,3,2,1,0,255



ship_to_ship_fx
	dc.w pboff
  	dc.w new_env
  	dc.l stse_env
  	dc.w new_snd
  	dc.l sinep
	dc.w	c03,3,e03,3,b02,3,a02,3
	dc.w	e03,3,g03,3,f02,3,bb02,3
	dc.w	gb03,3,b02,3,c02,3,db03,3
	dc.w	a03,3,gb03,3,b02,3,ab02,3
  	dc.w end_fxp

stse_env dc.w 0,64,64,64,255



camera
	dc.w pboff
  	dc.w new_env
  	dc.l c_env
  	dc.w new_snd
  	dc.l airlockp
	dc.w  r20,8
  	dc.w end_fxp

c_env dc.w 0,64,64,64,255

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


;***********************

fxjump_table:  
				    ;engines are triggered via the engine
				    ;routine only
	dc.l	current_engine1_fx	
	dc.l	current_engine2_fx
	dc.l	current_engine3_fx
	dc.l	current_engine4_fx
	;-----------------------------
					;variable volume fx 5 to 13
	dc.l	expbig1_fx	;(5)
	dc.l	expbig2_fx	;(6)
	dc.l	expbig3_fx	;(7)
	dc.l	exp1fx		;(8)
	dc.l	exp2fx		;(9)
	dc.l	lazer2_pr1fx	;(10)
	dc.l	lazer1_pr1fx	;(11)
	dc.l	undercfx_up	;(12)	2.8 seconds..140 frames at 50hz
	dc.l	undercfx_down	;(13)   2.8 seconds..     ""

	;---------------------------
				;    looping fx 14 to 17
	dc.l	windfx		;(14) infinite run with wind2 for two channels(37)
	dc.l	space_station_backfx	;(15)
	dc.l	factroarfx	;(16)
	dc.l	fuelscoopfx	;(17)
	;----------------------------
				; fixed vol non looping 18-30
	dc.l	airlock1fx	;(18)  2.8 sec
	dc.l	airlock2fx	;(19)  2.8 sec
	dc.l	beepfx		;(20)
	dc.l	target_confirmedfx	;(21)
	dc.l	bongfx		;(22)
	dc.l	bellfx		;(23)
	dc.l	clunckfx	;(24)
	dc.l	ecm1fx		;(25)
	dc.l	ecm2fx		;(26)
	dc.l	energy_bombfx	;(27)  7 seconds....350 frames at 50hz
	dc.l	shieldfx	;(28)
	dc.l	damagefx	;(29)
	dc.l	alarm2fx	;(30)
	dc.l	ship_diefx	;(31)  explosion to 4 (not overwritten)
	dc.l	missile_launch  ;(32)
	dc.l	hyper_space	;(33)
	dc.l	hiss_fx		;(34) 

	dc.l	lazer4_pr1fx	;(35) variable vol for alien lazers
	dc.l	lazer3_pr1fx	;(36) variable vol for alien lazers 
	dc.l	wind2		;(37) copy of windfx for twin channel

	dc.l	ship_to_ship_fx	;(38) message send/recieve
	dc.l	camera		;(39) ????



max_fx	dc.l	40		;number + 1 for testing only
;______________________________________________________________________


;myfile                     empty rwed Today     22:38:40
;UNDERC.FON                   768 rwed Today     22:37:09
;HISS.FON                    1560 rwed Today     22:37:08
;DOORCLOS.FON                1386 rwed Today     22:37:07
;AIRLOCK.FON                 2800 rwed Today     22:37:06
;RUMBLE.FON                  1440 rwed Today     22:37:06
;BONG.FON                    1296 rwed Today     22:37:05
;LAZER2.FON                  1950 rwed Today     22:37:04
;LAZER1.FON                  2832 rwed Today     22:37:04
;ENGINE2.FON                 2124 rwed Today     22:37:03
;EXP1.FON                    2346 rwed Today     22:37:02
;WIND.FON                    3272 rwed Today     22:37:00
;ENGINE1.FON                 1764 rwed Today     22:37:00
;EXPLOSIO.CON                2440 rwed Today     22:36:38
;ALARM1.CON                   586 rwed Today     22:36:37
;WHEELS.CON                  1808 rwed Today     22:36:36
;HISS.CON                    2545 rwed Today     22:36:35
;17 files - 86 blocks used
;





sstart: dc.l 0,end_song

pstart: dc.w end_patt

;****************************

cr  set   16
q set  cr/2
sq set q/2
dsq set   sq/2


tcr1 set 11
tcr2 set 10
tq1 set	  5
tq2 set   6
tsq1 set  3
tsq2 set 2


bm1:

	dc.l	pizpiano_sound_very_quiet
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt2
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt3
	dc.l	bmpatt1
	dc.l	brass_sound
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt6
	dc.l	bmpatt4			;break after repeat
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	orch_hit_sound
	dc.l	bmpatt9

;bm1:
	dc.l	pizpiano_sound
	dc.l	bmpatt10

	dc.l	flute_sound
	dc.l	bmpatt11

	dc.l	bmpatt12flute
				;;;;;REAPEAT HERE
			
	dc.l	pizpiano_sound_very_quiet
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt2
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt3
	dc.l	bmpatt1
	dc.l	brass_sound
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt6
	dc.l	bmpatt4			;break after repeat
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	bmpatt4
	dc.l	orch_hit_sound
	dc.l	bmpatt9

	dc.l	bass_sound
	dc.l	bmpatt13

	dc.l	flute_sound
	dc.l	bmpatt14flute

	dc.l	bmpatt15flute

	dc.l	pizpiano_sound
	dc.l	bmpatt16


	dc.l	bmpatt17tune
	dc.l	bmpatt17tune

	dc.l	bmend
	dc.l	pri

  	dc.l 	0,end_song


bm2:
	dc.l	trumpet_sound
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt2
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt3
	dc.l	bmpatt1
	dc.l	brass_sound
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt6h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt9h


;bm2:
	dc.l	pizpiano_sound
	dc.l	bmpatt10h1
	dc.l	flute_sound

	dc.l	bmpatt11h1

	dc.l	orch_hit_sound
	dc.l	bmpatt12stab
				;;;;;REAPEAT HERE

	dc.l	trumpet_sound
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt2
	dc.l	bmpatt1
	dc.l	bmpatt1
	dc.l	bmpatt3
	dc.l	bmpatt1
	dc.l	brass_sound
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt6h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt4h
	dc.l	bmpatt9h



	dc.l	pizpiano_sound
	dc.l	bmpatt13h1

	dc.l	flute_sound
	dc.l	bmpatt14flute2


	dc.l	orch_hit_sound
	dc.l	bmpatt15stab

	dc.l	trumpet_sound
	dc.l	bmpatt16h1

	dc.l	bass_sound
	dc.l	bmpatt17bass
	dc.l	bmpatt17bass

	dc.l	bmendbass

	dc.l	pri

  	dc.l 	0,end_song



bm3:

	dc.l	bm2br
	dc.l	bass_sound
	dc.l	bmpatt5
	dc.l 	bmpatt2
	dc.l	bmpatt5
	dc.l	bmpatt3
	dc.l	bmpatt1
	dc.l	bm2br
	dc.l	trumpet_sound
	dc.l	bmpatt7
	dc.l	orch_hit_sound
	dc.l	bmpatt8

	dc.l	orch_hit_sound

	dc.l	bmpatt9


;bm3:
	dc.l	pizpiano_sound
	dc.l	bmpatt10h2

	dc.l	flute_sound

	dc.l	bmpatt11h2

	dc.l	bass_sound
	dc.l	bmpatt12b1

				;;;;;REAPEAT HERE


	dc.l	bm2br
	dc.l	bass_sound
	dc.l	bmpatt5
	dc.l 	bmpatt2
	dc.l	bmpatt5
	dc.l	bmpatt3
	dc.l	bmpatt1
	dc.l	bm2br
	dc.l	trumpet_sound
	dc.l	bmpatt7
	dc.l	orch_hit_sound
	dc.l	bmpatt8

	dc.l	orch_hit_sound

	dc.l	bmpatt9




	dc.l	pizpiano_sound
	dc.l	bmpatt13h2

	dc.l	orch_hit_sound
	dc.l	bmpatt14stab

	dc.l	bass_sound
	dc.l	bmpatt15flute

	dc.l	trumpet_sound
	dc.l	bmpatt16h2


	dc.l	orch_hit_sound
	dc.l	bmpatt17stab
	dc.l	bmpatt17stab

	dc.l	bmendstab

	dc.l	pri

  	dc.l 	0,end_song


bm4:

	dc.l	bm2br
	dc.l	string_sound
	dc.l	bmpatt5o
	dc.l 	bmpatt2
	dc.l	bmpatt5o
	dc.l	bmpatt3
	dc.l	bmpatt1

	dc.l	flute_sound
	dc.l	bmpatt1
	dc.l	bmpatt1
	

	dc.l	bass_sound
	dc.l	bmpatt7
	dc.l	bmpatt8
	dc.l	bass_sound
	dc.l	bmpatt9hb


;bm4:


	dc.l	trumpet_sound
	dc.l	bmpatt10b

	dc.l	orch_hit_sound
	dc.l	bmp11stab

	dc.l	bass_sound
	dc.l	bmpatt12b2
	
				;;;;;REAPEAT HERE



	dc.l	bm2br
	dc.l	string_sound
	dc.l	bmpatt5o
	dc.l 	bmpatt2
	dc.l	bmpatt5o
	dc.l	bmpatt3
	dc.l	bmpatt1

	dc.l	flute_sound
	dc.l	bmpatt1
	dc.l	bmpatt1
	

	dc.l	bass_sound
	dc.l	bmpatt7
	dc.l	bmpatt8
	dc.l	bass_sound
	dc.l	bmpatt9hb




	dc.l	snare_sound
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare

	dc.l	bass_sound
	dc.l	bmpatt14bass

	dc.l	bmpatt15bass


	dc.l	trumpet_sound
	dc.l	bmpatt16h3

	dc.l	snare_sound
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare

	dc.l	bmpatt13snare
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare
	dc.l	bmpatt13snare

	dc.l	bmendsnare
	dc.l pri_new_tune

  	dc.l 	0,end_song





bm2br
	dc.w rest,cr*8
	dc.w end_patt

bm1br
	dc.w rest,cr*4
	dc.w end_patt

bmib
	dc.w rest,cr*100
	dc.w end_patt

;**************************

bmendstab
	dc.w bb02,cr,bb02,cr
	dc.w rest,cr*2,bb02,cr*4

	dc.w end_patt

bmendbass
	dc.w bb01,cr,bb01,cr
	dc.w rest,cr*2,bb01,cr*4
	dc.w end_patt

bmend
	dc.w bb02,cr,bb02,cr
	dc.w rest,cr,f02,tq1,gb02,tq2,ab02,tq1,bb02,cr*4
	dc.w end_patt

bmendsnare
	dc.w r16,cr,r16,cr
	dc.w rest,cr,r16,tq1,r16,tq2,r16,tq1,r16,cr*4
	dc.w end_patt



bmpatt17tune
	dc.w bb02,q,a02,q,bb02,q,a02,q,ab02,q,g02,q,ab02,q,g02,q
	dc.w gb02,q,f02,q,e02,q,db02,q,c02,q,eb02,q,gb02,q,a02,q

	dc.w bb02,q,a02,q,bb02,q,a02,q,ab02,q,g02,q,ab02,q,g02,q
	dc.w gb02,q,f02,q,e02,q,db02,q,c02,q,eb02,q,gb02,q,a02,q
	dc.w end_patt

bmpatt17bass
	dc.w bb02,cr,f03,cr,bb02,cr,f03,cr
	dc.w bb02,cr,gb03,cr,bb02,cr,g03,cr

	dc.w bb02,cr,f03,cr,bb02,cr,f03,cr
	dc.w bb02,cr,gb03,cr,bb02,cr,g03,cr
	dc.w end_patt

bmpatt17stab
	dc.w rest,cr,f03,cr*2,f03,cr*2
	dc.w gb03,cr*2,g03,cr*2
	dc.w f03,cr*2,f03,cr*2
	dc.w gb03,cr*2,g03,cr
	dc.w end_patt

bmpatt16

	dc.w a02,sq,a03,sq,ab02,sq,ab03,sq
	dc.w a02,sq,a03,sq,ab02,sq,ab03,sq
	dc.w a02,sq,a03,sq,e02,sq,e03,sq
	dc.w eb02,sq,eb03,sq,d02,sq,d03,sq

	dc.w db02,sq,db03,sq,c02,sq,c03,sq
	dc.w b01,sq,b02,sq,bb01,sq,bb02,sq
	dc.w a01,sq,a02,sq,ab01,sq,ab02,sq
	dc.w g01,sq,g02,sq,gb01,sq,gb02,sq

	dc.w f01,sq,f02,sq,gb01,sq,gb02,sq
	dc.w g01,sq,g02,sq,ab01,sq,ab02,sq
	dc.w a01,sq,a02,sq,bb01,sq,bb02,sq
	dc.w b01,sq,b02,sq,c02,sq,c03,sq

	dc.w db02,sq,db03,sq,d02,sq,d03,sq
	dc.w eb02,sq,eb03,sq,e02,sq,e03,sq
	dc.w f02,sq,f03,sq,g02,sq,g03,sq
	dc.w ab02,sq,ab03,sq,a02,sq,a03,sq

	dc.w end_patt

bmpatt16h1
	dc.w b01,cr*16
	dc.w end_patt

bmpatt16h2
	dc.w eb02,cr*16
	dc.w end_patt

bmpatt16h3
	dc.w f02,cr*16
	dc.w end_patt


bmpatt15flute
	dc.w a02,q,gb02,q,a02,q,e02,q,f02,q,e02,q,f02,q
	dc.w ab02,q
	dc.w a02,q,ab02,q,a02,q,e02,q,f02,q,e02,q,f02,q,g02,q
	dc.w a02,q,ab02,q,a02,q,e02,q,f02,q,e02,q,f02,q,g02,q
	dc.w a02,q,ab02,q,a02,q,e02,q,f02,q,e02,q,f02,q,g02,q
	dc.w a02,q,ab02,q,a02,q,e02,q,f02,q,e02,q,f02,q,g02,q
	dc.w a02,q,ab02,q,a02,q,e02,q,f02,q,e02,q,f02,q,g02,q
	dc.w end_patt

bmpatt15stab
	dc.w a03,cr*8,f03,cr*10,f03,tcr1,f03,tcr2,f03,tcr1
	dc.w f03,cr*2,f03,cr*2
	dc.w end_patt


bmpatt15bass
	dc.w a02,cr*8,f02,cr*10,f02,tcr1,f02,tcr2,f02,tcr1
	dc.w f02,cr*2,f02,cr*2
	dc.w end_patt

bmpatt15trumpet
	dc.w rest,cr*6,f03,cr*10,f03,tcr1,f03,tcr2,f03,tcr1
	dc.w f03,cr*2,f03,cr*2
	dc.w end_patt


bmpatt14stab
	dc.w	a03,cr*6,a03,cr*2,d03,cr*6
	dc.w	d03,cr*2+q,a03,cr*5+q,a03,cr*2
	dc.w	d03,cr*6,d03,cr*2
	dc.w end_patt
	
bmpatt14bass
	dc.w	a02,cr*6,a03,cr*2,d02,cr*6
	dc.w	c03,cr*2+q,a02,cr*5+q,a03,cr*2
	dc.w	d02,cr*6,c03,cr*2
	dc.w end_patt


bmpatt14flute
	dc.w	e02,q,e02,cr,f02,q,e02,q,d02,q,e02,q,f02,q
	dc.w	g02,cr,a02,cr
	dc.w	e03,q,e02,tsq1,f02,tsq2,g02,tsq1
	dc.w	a02,q,a02,dsq,g02,dsq,f02,dsq,e02,dsq
	dc.w	d02,q,a02,cr,bb02,q,a02,q,g02,q,a02,q,bb02,q
	dc.w	c03,cr,d03,cr,a02,q,d03,dsq,e03,dsq,f03,dsq
	dc.w	g03,dsq,a03,q,a03,tsq1,g03,tsq2,f03,tsq1
	dc.w	e03,q

	dc.w	e02,cr,f02,q,e02,q,d02,q,e02,q,f02,q
	dc.w	g02,cr,a02,cr
	dc.w	e03,q,e02,tsq1,f02,tsq2,g02,tsq1
	dc.w	a02,q,a02,dsq,g02,dsq,f02,dsq,e02,dsq
	dc.w	d02,q,a02,cr,bb02,q,a02,q,g02,q,a02,q,bb02,q
	dc.w	c03,cr,d03,cr,a02,q,d03,dsq,e03,dsq,f03,dsq
	dc.w	g03,dsq,a03,q,a03,tsq1,g03,tsq2,f03,tsq1
	dc.w end_patt

bmpatt14flute2
	dc.w	a02,q,a02,cr,a02,q,a02,q,a02,q,a02,q,a02,q
	dc.w	a02,cr,a02,cr
	dc.w	rest,cr*2+q
	dc.w	d02,cr,d02,q,d02,q,d02,q,d02,q,d02,q
	dc.w	d02,cr,d02,cr
	dc.w	rest,cr*2+q

	dc.w	a02,cr,a02,q,a02,q,a02,q,a02,q,a02,q
	dc.w	a02,cr,a02,cr
	dc.w	rest,cr*2+q
	dc.w	d02,cr,d02,q,d02,q,d02,q,d02,q,d02,q
	dc.w	d02,cr,d02,cr
	dc.w	rest,cr*2
	dc.w end_patt




bmpatt13snare

	dc.w	r16,q,r16,tsq1,r16,tsq2,r16,tsq1,r16,q,r16,q
	dc.w	r16,q,r16,q,r16,q,r16,q

	dc.w end_patt


bmpatt13
	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	

	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	

	dc.w c02,sq,c02,q+sq	
	dc.w b01,sq,b01,q+sq	
	dc.w c02,sq,c02,q+sq	
	dc.w b01,sq,b01,q+sq	


	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	


	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	
	dc.w d02,sq,d02,q+sq	


	dc.w c02,sq,c02,q+sq	
	dc.w b01,sq,b01,q+sq	
	dc.w c02,sq,c02,q+sq	
	dc.w b01,sq,b01,q+sq	
	dc.w end_patt

bmpatt13h1

	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq

	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq

	dc.w eb02,sq,eb02,q+sq	
	dc.w eb02,sq,eb02,q+sq	
	dc.w eb02,sq,eb02,q+sq	
	dc.w eb02,sq,eb02,q+sq	

	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq
	dc.w f02,sq,f02,q+sq

	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq
	dc.w gb02,sq,gb02,q+sq
	dc.w f02,sq,f02,q+sq


	dc.w eb02,sq,eb02,q+sq	
	dc.w eb02,sq,eb02,q+sq	
	dc.w eb02,sq,eb02,q+sq	
	dc.w eb02,sq,eb02,q+sq	

	dc.w end_patt


bmpatt13h2

	dc.w c03,sq,c03,q+sq
	dc.w c03,sq,c03,q+sq
	dc.w c03,sq,c03,q+sq
	dc.w bb02,sq,bb02,q+sq

	dc.w c03,sq,c03,q+sq
	dc.w c03,sq,c03,q+sq
	dc.w c03,sq,c03,q+sq
	dc.w bb02,sq,bb02,q+sq

	dc.w a02,sq,a02,q+sq	
	dc.w g02,sq,g02,q+sq	
	dc.w a02,sq,a02,q+sq	
	dc.w g02,sq,g02,q+sq	

	dc.w c03,sq,c03,q+sq
	dc.w c03,sq,c03,q+sq
	dc.w c03,sq,c03,q+sq
	dc.w bb02,sq,bb02,q+sq

	dc.w c03,sq,c03,q+sq
	dc.w c03,sq,c03,q+sq
	dc.w c03,sq,c03,q+sq
	dc.w bb02,sq,bb02,q+sq

	dc.w a02,sq,a02,q+sq	
	dc.w g02,sq,g02,q+sq	
	dc.w a02,sq,a02,q+sq	
	dc.w g02,sq,g02,q+sq	

	dc.w end_patt






bmpatt12stab
	dc.w rest,cr
	dc.w g03,cr*4,f03,cr*2,e03,cr*4,a03,cr*4
	dc.w end_patt
		
bmpatt12b1
	dc.w g02,cr,eb02,cr*2,d03,cr,ab02,cr,d02,cr*2
	dc.w g02,cr*4,g02,cr*4 
	dc.w end_patt

bmpatt12b2
	dc.w g01,cr,g02,cr*2,f03,cr,ab01,cr,f02,cr*2
	dc.w e02,cr*4,e02,cr*4 
	dc.w end_patt

bmpatt12flute
	dc.w rest,cr-dsq-dsq-dsq,d03,dsq,eb03,dsq,f03,dsq
	dc.w g03,q,rest,q+cr*3-dsq-dsq-dsq
	dc.w db03,dsq,d03,dsq,e03,dsq,f03,q,rest,q+cr
	dc.w a02,sq,bb02,sq
	dc.w a02,sq,bb02,sq
	dc.w a02,sq,bb02,sq
	dc.w a02,sq,bb02,sq
	dc.w a02,sq,bb02,sq
	dc.w a02,sq,bb02,sq
	dc.w a02,sq,bb02,sq
	dc.w a02,sq,bb02,sq
	dc.w a03,q,rest,cr*3+q
	dc.w end_patt


bmp11stab
	dc.w  gb03,cr*8
	dc.w rest,cr
	dc.w end_patt


bmpatt11

	dc.w gb02,q,gb02,q,gb02,q,gb02,q
	dc.w g02,q,g02,q,a02,q,a02,q
	dc.w bb02,q,bb02,q,bb02,q,bb02,q
	dc.w a02,q,a02,q,a02,q,a02,q
	dc.w g02,cr
	dc.w end_patt


bmpatt11h1

	dc.w d02,q,d02,q,d02,q,d02,q
	dc.w e02,q,e02,q,f02,q,f02,q
	dc.w g02,q,g02,q,g02,q,g02,q
	dc.w gb02,q,gb02,q,gb02,q,gb02,q
	dc.w eb02,cr
	dc.w end_patt

bmpatt11h2

	dc.w rest,cr*2
	dc.w d02,q,d02,q,d02,q,d02,q
	dc.w d02,q,d02,q,d02,q,d02,q
	dc.w d02,q,d02,q,d02,q,d02,q
	dc.w rest,cr
	dc.w end_patt

bmpatt10
	dc.w	gb02,tq1,gb02,tq2,gb02,tq1
	dc.w	e02,tq1,e02,tq2,e02,tq1
	dc.w	gb02,tq1,gb02,tq2,gb02,tq1
	dc.w	bb02,tq1,bb02,tq2,bb02,tq1

	dc.w	gb02,tq1,gb02,tq2,gb02,tq1
	dc.w	a02,tq1,a02,tq2,a02,tq1
	dc.w	d02,tq1,d02,tq2,d02,tq1
	dc.w	gb02,tq1,gb02,tq2,gb02,tq1

	dc.w	gb02,q,gb02,q
	dc.w	e02,q,e02,q
	dc.w	gb02,q,gb02,q
	dc.w	bb02,q,bb02,q
	dc.w	gb02,q,gb02,q
	dc.w	a02,q,a02,q
	dc.w	d02,q,d02,q
	dc.w	gb02,q,gb02,q
	dc.w end_patt

bmpatt10h1
	dc.w	d02,tq1,d02,tq2,d02,tq1
	dc.w	c02,tq1,c02,tq2,c02,tq1
	dc.w	d02,tq1,d02,tq2,d02,tq1
	dc.w	d02,tq1,d02,tq2,d02,tq1

	dc.w	d02,tq1,d02,tq2,d02,tq1
	dc.w	c02,tq1,c02,tq2,c02,tq1
	dc.w	d02,tq1,d02,tq2,d02,tq1
	dc.w	a01,tq1,a01,tq2,a01,tq1

	dc.w	d02,q,d02,q
	dc.w	c02,q,c02,q
	dc.w	d02,q,d02,q
	dc.w	d02,q,d02,q
	dc.w	d02,q,d02,q
	dc.w	c02,q,c02,q
	dc.w	d02,q,d02,q
	dc.w	a01,q,a01,q
	;dc.w	a01,cr*4
	dc.w end_patt

bmpatt10h2
	dc.w	rest,cr
	dc.w	a01,tq1,a01,tq2,a01,tq1
	dc.w	rest,cr
	dc.w	b01,tq1,b01,tq2,b01,tq1

	dc.w	rest,cr
	dc.w	a01,tq1,a01,tq2,a01,tq1
	dc.w	rest,cr
	dc.w	gb01,tq1,gb01,tq2,gb01,tq1

	dc.w	rest,cr
	dc.w	a01,q,a01,q
	dc.w	rest,cr
	dc.w	bb01,q,bb01,q
	dc.w	rest,cr
	dc.w	a01,q,a01,q
	dc.w	rest,cr
	dc.w	gb01,q,gb01,q
	;dc.w	gb01,cr*4
	dc.w end_patt


bmpatt10b
	dc.w	d02,cr*16
	dc.w end_patt


bmpatt1
	dc.w a02,tq1,ab02,tq2,a02,tq1
	dc.w bb02,tq1,a02,tq2,g02,tq1
	dc.w a02,tq1,ab02,tq2,a02,tq1
	dc.w bb02,tq1,a02,tq2,g02,tq1
	dc.w end_patt

bmpatt2
	dc.w a02,cr*2-dsq-dsq-dsq
	dc.w bb02,dsq,c03,dsq,d03,dsq
	dc.w eb03,cr*2-dsq-dsq-dsq
	dc.w d03,dsq,c03,dsq,b02,dsq
	dc.w a02,cr*2-dsq-dsq-dsq
	dc.w b02,dsq,c03,dsq,d03,dsq,e03,cr*2
	dc.w end_patt

bmpatt3
	dc.w a02,cr*2-dsq-dsq
	dc.w bb02,dsq,c03,dsq,d03,dsq,e03,dsq
	dc.w f03,cr*2-dsq-dsq
	dc.w e03,dsq,d03,dsq,c03,dsq,b02,dsq
	dc.w a02,cr*2-dsq-dsq
	dc.w b02,dsq,c03,dsq,d03,dsq,e03,dsq,gb03,cr*2
	dc.w end_patt

bmpatt4

	dc.w	a02,q,ab02,q,ab02,q,a02,q
	dc.w	a02,q,ab02,q,ab02,q,a02,q

	dc.w end_patt

bmpatt4h

	dc.w	f02,q,f02,q,f02,q,f02,q
	dc.w	f02,q,f02,q,f02,q,f02,q

	dc.w end_patt

bmpatt6

	dc.w	c03,q,b02,q,b02,q,c03,q
	dc.w	c03,q,b02,q,b02,q,c03,q
	dc.w 	b02,q,bb02,q,bb02,q,b02,q
	dc.w 	b02,q,bb02,q,bb02,q,b02,q
	dc.w 	b02,q,bb02,q,bb02,q,b02,q
	dc.w	c03,q,b02,q,b02,q,c03,q

	dc.w end_patt

bmpatt6h

	dc.w	a02,q,a02,q,a02,q,a02,q
	dc.w	a02,q,a02,q,a02,q,a02,q
	dc.w	f02,q,f02,q,f02,q,f02,q
	dc.w	f02,q,f02,q,f02,q,f02,q
	dc.w	f02,q,f02,q,f02,q,f02,q
	dc.w	f02,q,f02,q,f02,q,f02,q

	dc.w end_patt

bmpatt7
	dc.w	f02,cr*4,e02,cr*6
	dc.w	d02,cr*2,e02,cr*2,f02,cr*2,ab02,cr*6
	dc.w	a02,cr*2,c02,cr*6
	dc.w end_patt

;bmpatt7a
	;dc.w c02,cr*2
	;dc.w end_patt


bmpatt8
	dc.w	c03,tcr1,c03,tcr2,c03,tcr1
	dc.w	d03,cr*6,d03,tcr1,d03,tcr2,d03,tcr1

	dc.w end_patt



bmpatt5
	dc.w a01,cr,ab01,cr,bb01,cr,a01,cr
	dc.w a01,cr,ab01,cr,bb01,cr,a01,cr
	dc.w end_patt


bmpatt5o
	dc.w a02,cr,ab02,cr,bb02,cr,a02,cr
	dc.w a02,cr,ab02,cr,bb02,cr,a02,cr
	dc.w end_patt


clickbm
	dc.w r16,cr,r16,cr,r16,cr,r16,cr
	dc.w end_patt


bmpatt9
	dc.w d03,cr*4,e03,cr*4
	dc.w end_patt

bmpatt9h
	dc.w g03,cr*4,g03,cr*4
	dc.w end_patt

bmpatt9hb
	dc.w bb02,cr*4,bb02,cr*4
	dc.w end_patt
bmpatt9hbo
	dc.w bb01,cr*4,bb01,cr*4
	dc.w end_patt





;----------------------------------

;;;;;;;;;;;;;;;;;;;;;   Music Data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cr  set   20
q set  cr/2
sq set q/2

tcr1 set 7
tcr2 set 6
tq1 set	  7
tq2 set   6
tsq1 set  3
tsq2 set 4


ssilent:
	dc.l	pr
  	dc.l 	0,end_song

ssilent4:
	dc.l	pr
  	dc.l 	0,end_song

;ssilent4:
	dc.l pri_new_tune
  	dc.l 	0,end_song



;************************************************

s1:		;main tunes

	dc.l	p1strg,p1o1,p1fh,p1o1,p2synbras1,p2,p2pizzo2,p2
	dc.l	p1violin1,p1o1,p3flute2,p3



;s1
	dc.l	dll

				;cp1
	dc.l	p3flute2l,p2,p2synbras1l,p2

;s1
	dc.l pbasstrip

;s1
	dc.l runbass,endrunbass,runbass2

;s1	
	dc.l synbral,loudtune

	;dc.l pr4,pr4

	dc.l synbral,p1o1,ptunex

;s1
	dc.l flutel,endtune,endtune2,endtune,endtune2
	dc.l endtune,endtune

	dc.l pr1beat,tr,tr,tr,tr,tr,tr,tr

	dc.l tympre1

	dc.l pr1beat,tr,pr1beat,pr1beat
	dc.l pr4

	dc.l pri

  	dc.l 	0,end_song
;---------------

s2:		;bass

	dc.l	p1bass,p1bass_end,lastbarb,pbasstrip

;s2
	dc.l	pizpiano,p1o1,p1o1
					;cp2

	dc.l	pbassq

;s2
	dc.l p3flute2,pflute_trip


;s2	
	dc.l	p1strgll,p1o1,p1o1
	dc.l	p2synbras1l,p2

;s2
	dc.l	loudbass,loudtune
	dc.l flutel,trills,pr1bar

;s2	
	dc.l endtymp,endtymp2,pr1bar,pr1bar
	dc.l endtymp,endtymp2,pr1bar,pr1bar
	dc.l endtymp,endtymp2

	dc.l pr1beat,rs,rs,rs,rs,rs,rs,rs

	dc.l tympre2

	dc.l es1
	dc.l pr4
	dc.l pri

        DC.L    0,end_song

;---------------

s3:
		;accomp
	dc.l	p1rest,p1rest,p1strgl,p2,flutebit
	dc.l	pvacc
;s3	
	dc.l	orchhitp1,snarerollgb,snarerollgb,snarerolld,snarerollgb
	dc.l	snarerollgb,snarerollgb,snarerolld,snarerollgb

	dc.l	snarerollgb,snarerollgb,snarerolld,snarerollgb
	dc.l	snarerollgb,snarerollgb,snarerolld,snarerollgb

;s3
	dc.l    pizpiano,p1o1,ptunex

;s3
	dc.l	p1strgl,pstrgnote
	dc.l	orch1note

;s3
	dc.l	orchitsnd,orchloud
	dc.l	loudbass,p1bassd,pr1bar		;,endbass,pr1bar

;s3
	dc.l	endstab,endstab2,endbass_bit2
	dc.l	endstab,endstab2,endbass_bit2

	dc.l	endstab,endstab2

	dc.l tymp1b,rs1,rs1,rs1,rs1,rs1,rs1,rs1

	dc.l tympre1x

	dc.l es2
	dc.l pr4
	dc.l pri

  	dc.l 	0,end_song
;---------------
		; any thing else we can think of
s4:
	dc.l	p1rest,p1rest,p1rest,pizzo2q,p2delay


	dc.l	p1synbras1,p1o1,tymproll

;s4	
	dc.l	bassstabs,p1rest,p3flute2l,orchitp2

;s4
	dc.l snareroll

;s4
	dc.l snarebeat
	dc.l p2pizzo2,runbass2

;s4
	dc.l tympsnd_loud,tymploud


	dc.l snarerollb,snarerollb,snarerollb,snarerollb
	dc.l snarerollb,snarerollb,snarerolld,snarerolld
	dc.l snarerollb,snarerollb,snarerollb,snarerollb
	dc.l snarerollb,snarerollb

	dc.l pr1bar

;s4
	dc.l endbass_bit
	dc.l endbass_bit


	dc.l pr1bar,pr1bar
	dc.l pr1bar,pr1bar

	dc.l tympre2x

	dc.l pr1beat,tr,pr1beat,pr1beat
	dc.l pr4
	dc.l pri_new_tune

  	dc.l 	0,end_song


;---------------

pr:
	dc.w rest,cr*4
	dc.w end_patt

pr1bar:
	dc.w rest,cr*4
	dc.w end_patt

pr1beat:
	dc.w rest,cr
	dc.w end_patt

p1rest:
	dc.w rest,cr*16
	dc.w end_patt
pr1:
	dc.w rest,cr*16
	dc.w end_patt

pr4:
	dc.w rest,cr*16
	dc.w end_patt


prp:
	dc.w rest,cr*1000
	dc.w end_patt
prza:
	dc.w rest,q*7
	dc.w end_patt


p1strg:
  	dc.w new_env
  	dc.l strings1e
  	dc.w new_snd
  	dc.l strings2p
  	dc.w end_patt

p1strgl:
  	dc.w new_env
  	dc.l strings1el
  	dc.w new_snd
  	dc.l strings2p
  	dc.w end_patt

p1strgll:
  	dc.w new_env
  	dc.l strings1ell
  	dc.w new_snd
  	dc.l strings2p

  	dc.w end_patt

french_kiss_sound
p1fh:
  	dc.w new_env
  	dc.l frehorne
  	dc.w new_snd
  	dc.l frehornp
  	dc.w end_patt

p1synbra:
  	dc.w new_env
  	dc.l synbras1e
  	dc.w new_snd
  	dc.l synbras1p
  	dc.w end_patt

synbral
  	dc.w new_env
  	dc.l synbras1el
  	dc.w new_snd
  	dc.l synbras1p
  	dc.w end_patt

tympsnd_loud
  	dc.w new_env
  	dc.l tympel 
  	dc.w new_snd
  	dc.l newtympp
  	dc.w end_patt

flute_loud_sound
flutel
  	dc.w new_env
  	dc.l flute2el
  	dc.w new_snd
  	dc.l newflutep
  	dc.w end_patt

flute_loop
  	dc.w new_env
  	dc.l flute2el
  	dc.w new_snd
  	dc.l newflutelp
  	dc.w end_patt



p1violin1:
  	dc.w new_env
  	dc.l violin1e
  	dc.w new_snd
  	dc.l violin1p
  	dc.w end_patt

pizpiano:
  	dc.w new_env
  	dc.l pizpianoe
  	dc.w new_snd
  	dc.l pizpianop
  	dc.w end_patt 

pizpiano_sound_very_quiet:
  	dc.w new_env
  	dc.l pizpianoevq
  	dc.w new_snd
  	dc.l pizpianop
  	dc.w end_patt 




endtune
	dc.w rest,cr-9,ab02,3,a02,3,bb02,3,b02,cr,rest,cr*2
	dc.w end_patt

tr
  	dc.w new_env
  	dc.l flute2el
  	dc.w new_snd
  	dc.l newflutep

	dc.w ab02,3,a02,3,bb02,3,b02,20-9
	dc.w end_patt


endtune2
	dc.w rest,cr-9,ab02,3,a02,3,bb02,3,b02,cr,rest,cr*2
	dc.w b01,q,db02,q,d02,q,e02,q,gb02,q,d02,q,gb02,q,b02,q
	dc.w bb02,q,gb02,q,bb02,q,db03,q,b02,cr*2
	dc.w end_patt

tymp1b
  	dc.w new_env
  	dc.l tympel 
  	dc.w new_snd
  	dc.l newtympp
	dc.w b02,cr
	dc.w end_patt

tympre1
  	dc.w new_env
  	dc.l tympel 
  	dc.w new_snd
  	dc.l newtympp
	dc.w b02,cr,b02,cr,b02,cr,b02,cr
	dc.w b02,cr,b02,cr,b02,cr,b02,cr
	dc.w end_patt

tympre1x
  	dc.w new_env
  	dc.l tympel 
  	dc.w new_snd
  	dc.l newtympp
	dc.w rest,sq,b02,cr,b02,cr,b02,cr,b02,cr
	dc.w b02,cr,b02,cr,b02,cr,b02,cr-sq
	dc.w end_patt



tympre2
  	dc.w new_env
  	dc.l tympel 
  	dc.w new_snd
  	dc.l newtympp
	dc.w rest,q,b02,cr,b02,cr,b02,cr,b02,cr
	dc.w b02,cr,b02,cr,b02,cr,b02,cr-q

	dc.w end_patt

tympre2x
  	dc.w new_env
  	dc.l tympel 
  	dc.w new_snd
  	dc.l newtympp
	dc.w rest,q+sq,b02,cr,b02,cr,b02,cr,b02,cr
	dc.w b02,cr,b02,cr,b02,cr,b02,sq

	dc.w end_patt




endtymp
  	dc.w new_env
  	dc.l tympel 
  	dc.w new_snd
  	dc.l newtympp
	dc.w b02,cr

  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp

	dc.w g03,cr*3
	dc.w end_patt
endtymp2
  	dc.w new_env
  	dc.l tympel 
  	dc.w new_snd
  	dc.l newtympp
	dc.w b02,cr

  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp

	dc.w d03,cr*3

	dc.w end_patt

endstab
	dc.w rest,cr

  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w b02,cr*3
	dc.w end_patt

es1
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w b01,cr,b02,cr*3
	dc.w end_patt

es2
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w b02,cr,d03,cr*3
	dc.w end_patt





rs
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w b02,cr
	dc.w end_patt

rs1
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w d02,cr
	dc.w end_patt




endstab2
	dc.w rest,cr
	dc.w b02,cr*3
	dc.w end_patt

endbass_bit

  	dc.w new_env
  	dc.l pizzo1el
  	dc.w new_snd
  	dc.l pizzo1p
	dc.w rest,cr
	dc.w g03,cr,rest,cr*2
	dc.w rest,cr
	dc.w g03,cr,rest,cr*2

  	dc.w new_env
  	dc.l strings1eq
  	dc.w new_snd
  	dc.l strings2p


	dc.w g03,cr,d03,cr,gb02,cr,d03,cr
	dc.w gb02,cr,db03,cr,b02,cr,d03,cr

	dc.w end_patt

endbass_bit2

  	dc.w new_env
  	dc.l pizzo1el
  	dc.w new_snd
  	dc.l pizzo1p
	dc.w g03,cr,d03,cr,gb02,cr,d03,cr
	dc.w gb02,cr,db03,cr,b02,cr,d03,cr
	dc.w end_patt


loudtune
	dc.w gb02,q,ab02,q,bb02,q,b02,q,db03,q,bb02,q,db03,cr
	dc.w eb03,q,bb02,q,eb03,cr,db03,q,bb02,q,db03,cr
	dc.w gb02,q,ab02,q,bb02,q,b02,q,db03,q,bb02,q,db03,cr
	dc.w eb03,q,bb02,q,eb03,cr,db03,cr*2
  	dc.w end_patt

orchloud
	dc.w gb02,cr*2,db03,cr,db03,cr
	dc.w eb03,cr,eb03,cr,db03,q,bb02,q,db03,cr
	dc.w gb02,cr*2,db03,cr,db03,cr
	dc.w eb03,q,bb02,q,eb03,cr,db03,cr*2

  	dc.w end_patt

trills
	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4
	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4

	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4
	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4

	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4
	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4

	dc.w rest,cr,gb02,4,ab02,4,b02,4,d03,4,rest,4
	dc.w rest,cr,gb02,4,ab02,4,b02,4,b03,4,rest,4

	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4
	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4

	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4
	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4

	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4
	dc.w rest,cr,gb02,4,ab02,4,bb02,4,b02,4,rest,4

  	dc.w end_patt


tymploud

	dc.w gb02,q,ab02,q,bb02,q,b02,q,db03,q,bb02,q,db03,cr
	dc.w eb03,q,bb02,q,eb03,cr,db03,q,bb02,q,db03,cr
	dc.w gb02,q,ab02,q,bb02,q,b02,q,db03,q,bb02,q,db03,cr
	dc.w eb03,q,bb02,q,eb03,cr,db03,cr*2



	;dc.w gb02,cr*2,gb02,cr,gb02,cr
	;dc.w gb02,cr,gb02,cr,gb02,q,gb02,q,gb02,cr
	;dc.w gb02,cr*2,gb02,cr,gb02,cr
	;dc.w gb02,q,gb02,q,gb02,cr,gb02,cr*2
  	dc.w end_patt


pstrgnote

	dc.w b02,cr*2,b02,cr*2,b02,cr*2,b02,cr*2,b02,cr*2,b02,cr*2
	dc.w d03,cr*2,d03,cr*2
	dc.w b02,cr*2,b02,cr*2,b02,cr*2,b02,cr*2,b02,cr*2,b02,cr*2
	dc.w d03,cr*2,d03,cr*2
  	dc.w end_patt



p1o0	dc.w b00,q,db01,q,d01,q,e01,q,gb01,q,d01,q,gb01,cr
	dc.w f01,q,db01,q,f01,cr,e01,q,c01,q,e01,cr
	dc.w b00,q,db01,q,d01,q,e01,q,gb01,q,d01,q,gb01,q,b01,q
	dc.w a01,q,gb01,q,d01,q,gb01,q,a01,cr+q,rest,q
  	dc.w end_patt


p1o1	dc.w b01,q,db02,q,d02,q,e02,q,gb02,q,d02,q,gb02,cr
	dc.w f02,q,db02,q,f02,cr,e02,q,c02,q,e02,cr
	dc.w b01,q,db02,q,d02,q,e02,q,gb02,q,d02,q,gb02,q,b02,q
	dc.w a02,q,gb02,q,d02,q,gb02,q,a02,cr+q,rest,q
  	dc.w end_patt


ptunex	dc.w b01,q,db02,q,d02,q,e02,q,gb02,q,d02,q,gb02,cr
	dc.w f02,q,db02,q,f02,cr,e02,q,c02,q,e02,cr
	dc.w b01,q,db02,q,d02,q,e02,q,gb02,q,d02,q,gb02,q,b02,q
	dc.w gb02,q,d02,q,gb02,q,b02,q,b01,cr+q+q
  	dc.w end_patt


flutebit
  	dc.w new_env
  	dc.l flute2eq
  	dc.w new_snd
  	dc.l newflutep
	dc.w rest,cr*2,db03,q,bb02,q,db03,cr
	dc.w rest,cr*2,db03,q,bb02,q,db03,cr
	dc.w gb02,q,ab02,q,bb02,q,b02,q,db03,q,bb02,q,db03,cr
	dc.w d03,q,bb02,q,d03,cr,db03,cr*2


  	dc.w end_patt

p1synbras1:
  	dc.w new_env
  	dc.l synbras1eq
  	dc.w new_snd
  	dc.l synbras1p
  	dc.w end_patt



p2synbras1:
  	dc.w new_env
  	dc.l synbras1e_s1
  	dc.w new_snd
  	dc.l synbras1p
  	dc.w end_patt


orchitsnd
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
  	dc.w end_patt




p2synbras1l:
  	dc.w new_env
  	dc.l synbras1el
  	dc.w new_snd
  	dc.l synbras1p
  	dc.w end_patt

loudbass
  	dc.w new_env
  	dc.l pizzo1el
  	dc.w new_snd
  	dc.l pizzo1p
  	dc.w end_patt


p2pizzo2:
  	dc.w new_env
  	dc.l pizzo2e
  	dc.w new_snd
  	dc.l pizzo2p
  	dc.w end_patt

p2pizzo2l:
  	dc.w new_env
  	dc.l pizzo2el
  	dc.w end_patt


pizzo2q:
  	dc.w new_env
  	dc.l pizzo2eq
  	dc.w new_snd
  	dc.l pizzo2p
  	dc.w end_patt


p2
	dc.w gb02,q,ab02,q,bb02,q,b02,q,db03,q,bb02,q,db03,cr
	dc.w d03,q,bb02,q,d03,cr,db03,q,bb02,q,db03,cr
	dc.w gb02,q,ab02,q,bb02,q,b02,q,db03,q,bb02,q,db03,cr
	dc.w d03,q,bb02,q,d03,cr,db03,cr*2
  	dc.w end_patt

p2delay
	dc.w rest,sq,gb02,q,ab02,q,bb02,q,b02,q,db03,q,bb02,q,db03,cr
	dc.w d03,q,bb02,q,d03,cr,db03,q,bb02,q,db03,cr
	dc.w gb02,q,ab02,q,bb02,q,b02,q,db03,q,bb02,q,db03,cr
	dc.w d03,q,bb02,q,d03,cr,db03,cr*2-sq
  	dc.w end_patt

pflute_trip

	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,d03,tcr1,f02,tcr2,gb02,tcr1
	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,d03,tcr1,f02,tcr2,gb02,tcr1

	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,db03,tcr1,f02,tcr2,gb02,tcr1
	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,c03,tcr1,f02,tcr2,gb02,tcr1

	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,d03,tcr1,f02,tcr2,gb02,tcr1
	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,d03,tcr1,f02,tcr2,gb02,tcr1

	dc.w d02,tcr1,ab02,tcr2,a02,tcr1,gb03,tcr1,ab02,tcr2,a02,tcr1
	dc.w d02,tcr1,ab02,tcr2,a02,tcr1,gb03,tcr1,ab02,tcr2,a02,tcr1


	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,d03,tcr1,f02,tcr2,gb02,tcr1
	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,d03,tcr1,f02,tcr2,gb02,tcr1

	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,db03,tcr1,f02,tcr2,gb02,tcr1
	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,c03,tcr1,f02,tcr2,gb02,tcr1

	dc.w b01,tcr1,f02,tcr2,gb02,tcr1,b02,cr,a02,cr,g02,cr
	
	dc.w gb02,cr,e02,cr,d02,cr,db02,cr
  	dc.w end_patt


p3flute2:
  	dc.w new_env
  	dc.l flute2e
  	dc.w new_snd
  	dc.l newflutep
  	dc.w end_patt

flute_sound_loud
p3flute2l:
  	dc.w new_env
  	dc.l flute2el
  	dc.w new_snd
  	dc.l newflutep
  	dc.w end_patt

p3	dc.w b01,q,db02,q,d02,q,e02,q,gb02,sq-1,e02,sq,d02,sq,rest,sq,gb02,sq,rest,sq*3+1
	dc.w f02,q,db02,q,f02,cr,e02,sq-1,db02,sq,c02,sq,rest,sq,e02,sq,rest,sq*3+1
	dc.w b01,q,db02,q,d02,q,e02,q,gb02,q,d02,q,gb02,q,b02,q
	dc.w gb02,q,d02,q,gb02,q,b02,q,b01,cr,rest,cr
  	dc.w end_patt

pvacc

  	dc.w new_env
  	dc.l violin1eq
  	dc.w new_snd
  	dc.l violin1p
	dc.w gb02,q,b01,q,gb02,q,b01,q,gb02,cr,gb02,q,b01,q
	dc.w gb02,q,b01,q,gb02,q,b01,q,gb02,cr,gb02,q,b01,q
	dc.w gb02,q,b01,q,gb02,q,b01,q,gb02,cr,gb02,q,b01,q
	dc.w gb02,q,b01,q,d02,q,b01,q,d02,q,b01,q,d02,q,b01,q

	dc.w gb02,q,b01,q,gb02,q,b01,q,gb02,cr,gb02,q,b01,q
	dc.w gb02,q,b01,q,gb02,q,b01,q,gb02,cr,gb02,q,b01,q

  	;dc.w new_env
  	;dc.l strings1e
  	;dc.w new_snd
  	;dc.l strings2p

	dc.w rest,2,b01,cr,bb02,cr,a02,cr,g02,cr
	dc.w gb02,cr,e02,cr,d02,cr,db02,cr-2
  	dc.w end_patt


dll


  	dc.w new_env
  	dc.l synbras1e
  	dc.w new_snd
  	dc.l synbras1p

	dc.w rest,cr,gb03,sq,f03,sq,gb03,q,rest,cr,gb03,sq,f03,sq,gb03,q
	dc.w rest,cr,gb03,sq,f03,sq,gb03,q,rest,cr,gb03,sq,f03,sq,gb03,q
	dc.w rest,cr,gb03,sq,f03,sq,gb03,q,rest,cr,gb03,sq,f03,sq,gb03,q
	dc.w d03,cr,a03,sq,ab03,sq,a03,q,d03,cr,a03,sq,ab03,sq,a03,q

	dc.w b02,cr,gb02,sq,f02,sq,gb02,q,b02,cr,gb02,sq,f02,sq,gb02,q
	dc.w b02,cr,gb02,sq,f02,sq,gb02,q,b02,cr,gb02,sq,f02,sq,gb02,q
	dc.w b02,cr,gb02,sq,f02,sq,gb02,q,b02,cr,gb02,sq,f02,sq,gb02,q
	dc.w d02,cr,a02,sq,ab02,sq,a02,q,d02,cr,a02,sq,ab02,sq,a02,sq,rest,sq
  	dc.w end_patt



stabs
	dc.w b02,cr*4,b02,cr*4,b02,cr*4,d03,cr*4
	dc.w b02,cr*4,b02,cr*4,b02,cr*4,d03,cr*4

  	dc.w end_patt


orchhitp1
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w b02,cr*4,b02,cr*4,b02,cr*4,d03,cr*4
	dc.w b02,cr*4,b02,cr*4,b02,cr*4,d03,cr*4
  	dc.w end_patt

orch1note
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w gb02,cr,rest,cr,gb02,cr,rest,cr
	dc.w gb02,cr,rest,cr,gb02,cr,rest,cr
	dc.w gb02,cr,rest,cr,gb02,cr,rest,cr
	dc.w gb02,cr,rest,cr,gb02,cr,rest,cr
  	dc.w end_patt

orchitp2
	dc.w gb02,q,bb02,q,db03,cr,rest,cr,gb02,q,bb02,q
	dc.w db03,cr,rest,cr,gb02,q,bb02,q,db03,cr
	dc.w gb02,q,bb02,q,db03,cr,rest,cr,gb02,q,bb02,q
	dc.w d03,q,gb02,q,d03,cr,db03,cr,rest,cr

  	dc.w end_patt



bassstabs
  	dc.w new_env
  	dc.l pizzo1el
  	dc.w new_snd
  	dc.l pizzo1p
	dc.w b01,cr*4,b01,cr*4,b01,cr*4,d02,cr*4

	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w d02,cr,a02,cr,d02,cr,a02,cr

  	dc.w end_patt

tymproll

  	dc.w new_env
  	dc.l tympe 
  	dc.w new_snd
  	dc.l newtympp
	dc.w rest,cr*14,r16,q,r14,q,r16,q,r14,q
  	dc.w end_patt



snarerollgb

  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w gb02,cr
  	dc.w new_env
  	dc.l snaree 
  	dc.w new_snd
  	dc.l snarep
	dc.w r16,sq,r16,sq,r16,q
  	dc.w end_patt

snarerollb

  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w b02,cr
  	dc.w new_env
  	dc.l snaree 
  	dc.w new_snd
  	dc.l snarep
	dc.w r16,sq,r16,sq,r16,q
  	dc.w end_patt

snarerolla

  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w ab03,cr
  	dc.w new_env
  	dc.l snaree 
  	dc.w new_snd
  	dc.l snarep
	dc.w r16,sq,r16,sq,r16,q
  	dc.w end_patt



snarerolld

  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w d02,cr
  	dc.w new_env
  	dc.l snaree 
  	dc.w new_snd
  	dc.l snarep
	dc.w r16,sq,r16,sq,r16,q
  	dc.w end_patt

snareroll

  	dc.w new_env
  	dc.l snareeq 
  	dc.w new_snd
  	dc.l snarep
	dc.w r4,cr+q,r16,sq,r16,sq,r16,q,r16,q,r16,cr
	dc.w rest,cr*4
	dc.w rest,cr+q,r16,sq,r16,sq,r16,q,r16,q,r16,cr
	dc.w rest,cr*4
	dc.w rest,cr+q,r16,sq,r16,sq,r16,q,r16,q,r16,cr
	dc.w rest,cr*4
	dc.w rest,q+sq,r16,sq,r16,q,r16,q,r16,q,r16,sq,r16,sq
	dc.w r16,q,r16,q
	dc.w r16,q,r16,q,r16,q,r16,q,r16,q,r16,q,r16,cr
  	dc.w end_patt

snarebeat

  	dc.w new_env
  	dc.l snareeq 
  	dc.w new_snd
  	dc.l snarep
	dc.w r16,cr,rest,cr*16,rest,cr*15
  	dc.w end_patt




p1bass:
  	dc.w new_env
  	dc.l basseq
  	dc.w new_snd
  	dc.l pizzo1p
p1bassd	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w d02,cr,a02,cr,d02,cr,a02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
  	dc.w end_patt

p1bass_end
	dc.w d02,cr,a02,cr,d02,cr,a02,cr
endbass
	dc.w gb02,cr,db03,cr,gb02,cr,db03,cr
	dc.w d02,cr,bb02,cr,gb02,cr,db03,cr
	dc.w gb02,cr,db03,cr,gb02,cr,db03,cr
	dc.w d02,cr,bb02,cr,gb02,cr,db03,cr
	dc.w gb02,cr,db03,cr,gb02,cr,db03,cr
	dc.w d02,cr,bb02,cr,gb02,cr,db03,cr
	dc.w gb02,cr,db03,cr,gb02,cr,db03,cr
  	dc.w end_patt
lastbarb
	dc.w d02,cr,bb02,cr,gb02,cr,db03,cr
  	dc.w end_patt


pbasstrip
  	dc.w new_env
  	dc.l basse
  	dc.w new_snd
  	dc.l pizzo1p

	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w d02,cr,a02,cr,d02,cr,a02,cr
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr			;bar 21
	dc.w b01,cr,gb02,cr,b01,cr,gb02,cr
	dc.w b01,cr,bb02,cr,a02,cr,g02,cr
	dc.w gb02,cr,e02,cr,d02,cr,db02,cr


  	dc.w end_patt

runbass
  	dc.w new_env
  	dc.l strings1el
  	dc.w new_snd
  	dc.l strings2p

bassrun
	dc.w b01,q,a01,q,g01,q,gb01,q
	dc.w b01,q,a01,q,g01,q,gb01,q

	dc.w b01,q,a01,q,g01,q,gb01,q
	dc.w b01,q,a01,q,g01,q,gb01,q

	dc.w b01,q,a01,q,g01,q,gb01,q
	dc.w b01,q,a01,q,g01,q,gb01,q

	dc.w d02,q,db02,q,b01,q,a01,q
	dc.w d02,q,db02,q,b01,q,a01,q

	dc.w b01,q,a01,q,g01,q,gb01,q
	dc.w b01,q,a01,q,g01,q,gb01,q

	dc.w b01,q,a01,q,g01,q,gb01,q
	dc.w b01,q,a01,q,g01,q,gb01,q

	dc.w b01,q,a01,q,g01,q,gb01,q
	dc.w b01,q,a01,q,g01,q,gb01,q

  	dc.w end_patt
endrunbass
	dc.w d02,q,db02,q,b01,q,a01,q
	dc.w d02,q,db02,q,b01,q,a01,q

  	dc.w end_patt

runbass2

	dc.w gb02,q,e02,q,d02,q,db02,q
	dc.w gb02,q,e02,q,d02,q,db02,q

	dc.w d02,q,db02,q,d02,q,e02,q
	dc.w gb02,q,e02,q,d02,q,db02,q

	dc.w gb02,q,e02,q,d02,q,db02,q
	dc.w gb02,q,e02,q,d02,q,db02,q

	dc.w d02,q,db02,q,d02,q,e02,q
	dc.w gb02,q,e02,q,d02,q,db02,q


  	dc.w end_patt


runbass2_end
	dc.w gb02,q,e02,q,d02,q,db02,q
	dc.w gb02,q,e02,q,d02,q,db02,q

	dc.w d02,q,db02,q,d02,q,e02,q
	dc.w gb02,q,e02,q,d02,q,db02,q

	dc.w gb02,q,e02,q,d02,q,db02,q
	dc.w gb02,q,e02,q,d02,q,db02,q

	dc.w rest,cr*4

  	dc.w end_patt






pbassq:
  	dc.w new_env
  	dc.l basse
  	dc.w new_snd
  	dc.l pizzo1p

	dc.w gb02,q,gb02,q
	dc.w db03,q,db03,q
	dc.w gb02,q,gb02,q
	dc.w db03,q,db03,q

	dc.w d02,q,d02,q
	dc.w bb02,q,bb02,q
	dc.w gb02,q,gb02,q
	dc.w db03,q,db03,q

	dc.w gb02,q,gb02,q
	dc.w db03,q,db03,q
	dc.w gb02,q,gb02,q
	dc.w db03,q,db03,q

	dc.w d02,q,d02,q
	dc.w bb02,q,bb02,q
	dc.w gb02,q,gb02,q
	dc.w db03,q,db03,q

	dc.w gb02,cr,db03,cr,gb02,cr,db03,cr
	dc.w d02,cr,bb02,cr,gb02,cr,db03,cr
	dc.w gb02,cr,db03,cr,gb02,cr,db03,cr
	dc.w d02,cr,bb02,cr,gb02,cr,db03,cr

  	dc.w end_patt





;------------

cr  set   24
q set  cr/2
sq set q/2

tcr1 set 16
tcr2 set 16
tq1 set	  8
tq2 set   8
tsq1 set 4
tsq2 set 4

**************************************************************

intro5
	dc.l	pizpiano_sound

	dc.l	intro1
	dc.l	intro1
	dc.l	intro1
	dc.l	intro1
	dc.l	intro1x
	dc.l	flute_sound
	dc.l	intro1x
	dc.l	orch_hit_sound
	dc.l	intro1


;  	dc.l 	0,end_song



s5:
	dc.l	trumpet_sound,main_tune,main_tune_end
	dc.l	brass_sound,dsect

;s5
	dc.l	trumpet_sound,main_tune,main_tune_end
	dc.l	brass_sound,dsect

;s5
	dc.l	mid_tune		;sounds defined

;s5
	dc.l	string_sound_loud,bridge_tune

	dc.l	trumpet_sound,main_tune,main_tune_end
;s5
	dc.l	trumpet_sound,main_tune,short_tune_end

	dc.l	mid_tune		;sounds defined

	dc.l	string_sound_loud,bridge_tune

	dc.l	trumpet_sound,main_tune,main_tune_end

	dc.l	brass_sound,dsect,dsect,dsect
	dc.l	one_stab

  	dc.l 	0,end_song
;---------------

intro8
	dc.l	bass_sound
	dc.l	intro2
	dc.l	intro2
	dc.l	intro2
	dc.l	intro2
	dc.l	intro2
	dc.l	intro2
	dc.l	intro2
	dc.l	intro2
	dc.l	intro2
	dc.l	intro2
	dc.l	intro4
	dc.l	intro2a
  	;dc.l 	0,end_song

s8:	
	dc.l	orch_hit_sound,orchhit_intro
	dc.l	string_sound_louder,string_run

;s6	
	dc.l 	histrg_sound,verse_bass			;this is strgs		
	dc.l	verse_bass
	dc.l	snare_sound_loud,dsnare

;s6
	dc.l	bass_sound_quiet,mid_bass

	dc.l	bass_sound,bridge_bass

	dc.l 	histrg_sound,verse_bass			;this is strgs		
	dc.l	verse_bass

;s6
	dc.l 	histrg_sound			;this is strgs		

	dc.l	verse_bass
	dc.l	verse_bass


	dc.l	pr241bar

	dc.l	bass_sound_quiet,mid_bass

	dc.l	bass_sound,bridge_bass

	dc.l 	histrg_sound,verse_bass			;this is strgs		
	dc.l	verse_bass
	dc.l	snare_sound_loud,dsnare,dsnare,dsnare

	dc.l	one_stab

	dc.l    pri_new_tune

        dc.l    0,end_song

;---------------

intro7

	dc.l	snare_sound
	dc.l	intro3
	dc.l	intro3
	dc.l	intro3
	dc.l	intro3
	dc.l	intro3
	dc.l	intro3
	dc.l	intro3
	dc.l	intro3
	;dc.l	orch_hit_sound
	;dc.l	intro3_crash
	;dc.l	snare_sound
	dc.l	intro3x
	dc.l	intro3x
	dc.l	intro3
	dc.l	intro3
	dc.l	intro3x
	dc.l	tymp_sound
	dc.l	intro3xx
;  	dc.l 	0,end_song




s7:
	dc.l	string_sound_loud,main_tune,main_tune_end
	dc.l	brass_sound,dsecth

;s7
	dc.l	snare_sound,verse_roll,verse_roll
	dc.l	orch_hit_soundq,phrase_d

;s7
	dc.l	trumpet_sound_quiet,mid_chord1

;s7
	dc.l	string_sound_loud,bridge_tuneh
	dc.l	snare_sound,verse_roll,verse_roll
;s7
	dc.l	main_tune_stabs

	dc.l	orch_hit_sound,short_run

	dc.l	trumpet_sound_quiet,mid_chord1

;s7
	dc.l	string_sound_loud,bridge_tuneh
	dc.l	snare_sound,verse_roll,verse_roll

	dc.l	orch_hit_soundq,phrase_d,phrase_d,phrase_d

	dc.l	one_stab

  	dc.l 	0,end_song
;---------------

intro6
	dc.l	histrg_sound
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
	dc.l	intro4
;  	dc.l 	0,end_song



s6:
	dc.l	bass_sound,intro_bass1,snare_sound,intro_roll
	dc.l	bass_sound,intro_bass2
	dc.l	snare_sound,roll2

;s8	
	dc.l	bass_soundvq,verse_bass
	dc.l	verse_bass,phrase_d_low

;s8
	dc.l	trumpet_sound_quiet,mid_chord2

;s8	

	dc.l	tymp_sound,mid_tymp

	dc.l	snare_sound,sfill
	dc.l	orch_hit_sound,two_stabs
	dc.l	string_sound_louder,string_run

	dc.l	bass_soundvq,verse_bass
	dc.l	verse_bass

;s8
	dc.l	bass_soundvq
	dc.l	verse_bass,verse_bass

	dc.l	bass_sound,short_run

	dc.l	trumpet_sound_quiet,mid_chord2

;s8	

	dc.l	tymp_sound,mid_tymp

	dc.l	snare_sound,sfill
	dc.l	orch_hit_sound,two_stabs
	dc.l	string_sound_louder,string_run

	dc.l	bass_soundvq,verse_bass
	dc.l	verse_bass
	dc.l	phrase_d_low,phrase_d_low,phrase_d_low

	dc.l	one_stab

  	dc.l 	0,end_song

;***************  RESTS  ***************


;cr  set   48
;q set  cr/2
;sq set q/2

;tcr1 set 32
;tcr2 set 32
;tq1 set	 16
;tq2 set  16
;tsq1 set 8
;tsq2 set 8


intro1
	dc.w rest,tq1+tq2,a02,tq1,d03,tq1,a02,tq2,d03,tq1,a03,cr*2
	dc.w rest,cr*4
	dc.w end_patt

intro1x
	dc.w rest,tq1+tq2,a02,tq1,d03,tq1,a02,tq2,d03,tq1,a03,cr*2
	dc.w end_patt



intro2
	dc.w  a02,cr,a02,cr,a02,cr,a02,cr
	dc.w end_patt
intro2o
	dc.w  a01,cr,a01,cr,a01,cr,a01,cr
	dc.w end_patt


intro2x
	dc.w  a02,cr,a03,cr,a02,cr,a03,cr
	dc.w end_patt


intro2a
	dc.w a03,tq1,d03,tq2,a02,tq1,d02,tq1,a02,tq2,d03,tq1
	dc.w a02,tq1,bb02,tq2,b02,tq1
	dc.w c03,tq1,db03,tq2,d03,tq1
	dc.w end_patt

intro3
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w end_patt

intro3_crash
	dc.w r2,cr*4
	dc.w end_patt


intro3x
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w end_patt


intro3xx
	dc.w r16,tq1,r15,tq2,r14,tq1
	dc.w r16,tq1,r15,tq2,r14,tq1
	dc.w end_patt



intro4	
	dc.w a03,tq1,d03,tq2,a02,tq1,d02,tq1,a02,tq2,d03,tq1
	dc.w a03,tq1,d03,tq2,a02,tq1,d02,tq1,a02,tq2,d03,tq1
	dc.w end_patt


cr  set   24
q set  cr/2
sq set q/2

tcr1 set 16
tcr2 set 16
tq1 set	  8
tq2 set   8
tsq1 set 4
tsq2 set 4

pr241bar:
	dc.w rest,cr*4
	dc.w end_patt

pr242bar:
	dc.w rest,cr*8
	dc.w end_patt

pr244bar:
	dc.w rest,cr*16
	dc.w end_patt


pr247bar:
	dc.w rest,cr*28
	dc.w end_patt

pr248bar:
	dc.w rest,cr*32
	dc.w end_patt



pr242beats:
	dc.w rest,cr*2
	dc.w end_patt


;**************  SOUNDS ****************

violin_sound_loud
  	dc.w new_env
  	dc.l violin1el
  	dc.w new_snd
  	dc.l violin1p
  	dc.w end_patt

sine_sound
  	dc.w new_env
  	dc.l sine_env
  	dc.w new_snd
  	dc.l sinep
  	dc.w end_patt

sine_sound_short
  	dc.w new_env
  	dc.l sine_env_short
  	dc.w new_snd
  	dc.l sinep
  	dc.w end_patt

sine_sound_slow
  	dc.w new_env
  	dc.l sine_env_slow
  	dc.w new_snd
  	dc.l sinep
  	dc.w end_patt

flute_sound
  	dc.w new_env
  	dc.l flute2e
  	dc.w new_snd
  	dc.l newflutep
  	dc.w end_patt

flute_sound_quiet
  	dc.w new_env
  	dc.l flute2eq
  	dc.w new_snd
  	dc.l newflutep
  	dc.w end_patt

bass_sound
  	dc.w new_env
  	dc.l basse
  	dc.w new_snd
  	dc.l pizzo1p
  	dc.w end_patt

bass_sound_quiet
  	dc.w new_env
  	dc.l bassqe
  	dc.w new_snd
  	dc.l pizzo1p
  	dc.w end_patt


bass_soundvq
  	dc.w new_env
  	dc.l bassevq
  	dc.w new_snd
  	dc.l pizzo1p
  	dc.w end_patt




;flute_sound
  	dc.w new_env
  	dc.l flute2eq
  	dc.w new_snd
  	dc.l newflutep
  	dc.w end_patt

histrg_sound
  	dc.w new_env
  	dc.l histrge
  	dc.w new_snd
  	dc.l histrgp
  	dc.w end_patt


snare_sound
  	dc.w new_env
  	dc.l snareeq 
  	dc.w new_snd
  	dc.l snarep
  	dc.w end_patt

snare_sound_mid
  	dc.w new_env
  	dc.l snareemid 
  	dc.w new_snd
  	dc.l snarep
  	dc.w end_patt



snare_sound_loud
  	dc.w new_env
  	dc.l snaree 
  	dc.w new_snd
  	dc.l snarep
  	dc.w end_patt




trumpet_sound
  	dc.w new_env
  	dc.l trumpete
  	dc.w new_snd
  	dc.l trumpet_loopp
  	dc.w end_patt

trumpet_sound_quiet
  	dc.w new_env
  	dc.l trumpeteq
  	dc.w new_snd
  	dc.l trumpet_loopp
  	dc.w end_patt


brass_sound
  	dc.w new_env
  	dc.l brasse
  	dc.w new_snd
  	dc.l brasssecp
  	dc.w end_patt

string_sound
  	dc.w new_env
  	dc.l strings1e
  	dc.w new_snd
  	dc.l strings2p
  	dc.w end_patt


string_sound_loud
  	dc.w new_env
  	dc.l strings1el
  	dc.w new_snd
  	dc.l strings2p
  	dc.w end_patt

string_sound_short
  	dc.w new_env
  	dc.l string_short_env
  	dc.w new_snd
  	dc.l strings2p
  	dc.w end_patt

string_sound_shorter
  	dc.w new_env
  	dc.l string_pizz_env
  	dc.w new_snd
  	dc.l strings2p
  	dc.w end_patt



string_sound_louder
  	dc.w new_env
  	dc.l strings1eler
  	dc.w new_snd
  	dc.l strings2p
  	dc.w end_patt


tymp_sound
  	dc.w new_env
  	dc.l tympe 
  	dc.w new_snd
  	dc.l newtympp
  	dc.w end_patt

pizpiano_sound
  	dc.w new_env
  	dc.l pizpianoe 
  	dc.w new_snd
  	dc.l pizpianop
  	dc.w end_patt

pizpiano_sound_short
  	dc.w new_env
  	dc.l sine_env_short 
  	dc.w new_snd
  	dc.l pizpianop
  	dc.w end_patt


pizpiano_sound_quiet
  	dc.w new_env
  	dc.l pizpianoevrq 
  	dc.w new_snd
  	dc.l pizpianop
  	dc.w end_patt


orch_hit_sound
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
  	dc.w end_patt

orch_hit_soundq
  	dc.w new_env
  	dc.l orchhiteq 
  	dc.w new_snd
  	dc.l orchhitpp
  	dc.w end_patt

;***********    TRUMPET PATTERNS LEAD TUNES *********


main_tune
	dc.w rest,tq1+tq2,a01,tq1,d02,tq1,a01,tq2,d02,tq1,a02,cr+tq1+tq2
	dc.w g02,tq1+tq2+tq1,g02,tq1,c03,cr*3

	dc.w rest,tq1+tq2,a01,tq1,d02,tq1,a01,tq2,d02,tq1,a02,cr+tq1+tq2
	dc.w g02,tq1+tq2+tq1,g02,tq1,e02,cr+tq1+tq2,c02,tq1+cr

	dc.w rest,tq1+tq2,a01,tq1,d02,tq1,a01,tq2,d02,tq1,a02,cr+tq1+tq2
	dc.w g02,tq1+tq2+tq1,g02,tq1,c03,cr+tq1+tq2,e03,tq1+cr
  	dc.w end_patt

main_tune_end
	dc.w d03,cr,d03,tq1,d03,tq2,d03,tq1
	dc.w f03,cr+tq1+tq2,e03,tq1+tq2+tq1
	dc.w e03,tq1,g03,cr*2
	dc.w c03,cr
  	dc.w end_patt

short_tune_end
	dc.w d03,cr,d03,tq1,d03,tq2,d03,tq1
	dc.w f03,cr+tq1+tq2,e03,tq1+tq2+tq1
	dc.w e03,tq1,g03,cr*2
	dc.w c03,cr,d03,cr*2,rest,cr*2
  	dc.w end_patt





dsect	dc.w d03,tq1,d03,tq2,d03,tq1
	dc.w d03,tq1,d03,tq2,d03,tq1
	dc.w d03,tq1,d03,tq2,d03,tq1
	dc.w d03,tq1,d03,tq2,d03,tq1
	dc.w d03,tq1,d03,tq2,d03,tq1
	dc.w d03,tq1,d03,tq2,d03,tq1
	dc.w d03,tq1,d03,tq2,d03,tq1
	dc.w d03,tq1,d03,tq2,d03,tq1
  	dc.w end_patt

dsecth
	dc.w a02,tq1,a02,tq2,a02,tq1
	dc.w a02,tq1,a02,tq2,a02,tq1
	dc.w a02,tq1,a02,tq2,a02,tq1
	dc.w a02,tq1,a02,tq2,a02,tq1
	dc.w a02,tq1,a02,tq2,a02,tq1
	dc.w a02,tq1,a02,tq2,a02,tq1
	dc.w a02,tq1,a02,tq2,a02,tq1
	dc.w a02,tq1,a02,tq2,a02,tq1
  	dc.w end_patt

mid_tune

  	dc.w new_env
  	dc.l strings1el
  	dc.w new_snd
  	dc.l strings2p

	dc.w bb02,cr*3,bb02,tq1,a02,tq2,g02,tq1
	dc.w f02,cr

  	dc.w new_env
  	dc.l pizpianoeq 
  	dc.w new_snd
  	dc.l pizpianop

	dc.w bb02,tq1,a02,tq2,g02,tq1
	dc.w f02,cr

   	dc.w new_env
  	dc.l strings1el
  	dc.w new_snd
  	dc.l strings2p

	dc.w g02,cr
	dc.w ab02,tq1,bb02,tq2,ab02,tq1,f02,cr
							;6 crot
  	dc.w new_env
  	dc.l pizpianoeq 
  	dc.w new_snd
  	dc.l pizpianop

	dc.w ab02,tq1,bb02,tq2,ab02,tq1,f02,cr
	dc.w rest,cr*2

	dc.w ab01,tq1,bb01,tq2,ab01,tq1,f01,cr

   	dc.w new_env
  	dc.l strings1el
  	dc.w new_snd
  	dc.l strings2p

	dc.w f02,tq1,g02,tq2,f02,tq1,eb02,cr*6
	dc.w g02,cr,f02,cr

  	dc.w new_env
  	dc.l pizpianoeq 
  	dc.w new_snd
  	dc.l pizpianop

	dc.w db02,tq1,db03,tq1,db02,tq1,db03,cr
	dc.w db02,tq1,db03,tq1,db02,tq1,db03,cr
	dc.w db02,tq1,db03,tq1,db02,tq1,db03,cr
	dc.w rest,cr

  	dc.w end_patt


bridge_tune
	dc.w eb02,tq1,eb02,tq2,eb02,tq1,d02,cr*3-tq1,c02,tq1
	dc.w eb02,tq1,eb02,tq2,eb02,tq1,d02,cr*3-tq1,c02,tq1

	dc.w f02,tq1,f02,tq2,f02,tq1,eb02,cr*3-tq1,c02,tq1
	dc.w f02,tq1,f02,tq2,f02,tq1,eb02,cr*3-tq1,c02,tq1

	dc.w ab02,tq1,ab02,tq2,ab02,tq1,g02,cr*3-tq1,c02,tq1
	dc.w bb02,tq1,bb02,tq2,bb02,tq1,ab02,cr*3-tq1,c02,tq1

	dc.w db03,cr,db03,tq1,db03,tq2,db03,tq1
	dc.w b02,cr,b02,tq1,b02,tq2,b02,tq1

	dc.w db03,cr,db03,tq1,db03,tq2,db03,tq1
	dc.w db03,cr,db03,tq1,db03,tq2,db03,tq1
	dc.w db03,cr,db03,tq1,db03,tq2,db03,tq1
	dc.w db03,tq1,db03,tq2,db03,tq1
	dc.w db03,tq1,db03,tq2,db03,tq1

  	dc.w end_patt

bridge_tuneh
	dc.w c02,tq1,c02,tq2,c02,tq1,c02,cr*3-tq1,g01,tq1
	dc.w c02,tq1,c02,tq2,c02,tq1,c02,cr*3-tq1,g01,tq1

	dc.w eb02,tq1,eb02,tq2,eb02,tq1,c02,cr*3-tq1,eb02,tq1
	dc.w eb02,tq1,eb02,tq2,eb02,tq1,c02,cr*3-tq1,eb02,tq1

	dc.w f02,tq1,f02,tq2,f02,tq1,f02,cr*3-tq1,f02,tq1
	dc.w ab02,tq1,ab02,tq2,ab02,tq1,ab02,cr*3-tq1,ab02,tq1

	dc.w bb02,cr,bb02,tq1,bb02,tq2,bb02,tq1
	dc.w ab02,cr,ab02,tq1,ab02,tq2,ab02,tq1

	dc.w a02,cr,a02,cr
	dc.w g02,cr,g02,cr
	dc.w gb02,cr,gb02,cr
	dc.w e02,cr,e02,cr

  	dc.w end_patt


;*******   ORCH HIT PATTERNS *******************

short_run

	dc.w d03,cr,rest,cr
	dc.w g03,tq1,f03,tq2,e03,tq1
	dc.w d03,tq1,c03,tq1,c03,tq1
  	dc.w end_patt




orchhit_intro
	dc.w d03,cr,rest,cr*7,bb02,cr,rest,cr*6
	dc.w c03,cr,d03,cr,rest,cr*7,bb02,cr,rest,cr*3
	dc.w c03,cr,rest,cr*2,c03,cr,d03,cr,rest,cr*5
  	dc.w end_patt

phrase_d
	dc.w d03,cr,d03,tq1,d03,tq2,d03,tq1
	dc.w d03,cr,d03,tq1,d03,tq2,d03,tq1
	dc.w d03,cr,d03,tq1,d03,tq2,d03,tq1
	dc.w d03,tq1,d03,tq2,d03,tq1,d03,tq1,d03,tq2,d03,tq1
  	dc.w end_patt

phrase_d_low
	dc.w d02,cr,d02,tq1,d02,tq2,d02,tq1
	dc.w d02,cr,d02,tq1,d02,tq2,d02,tq1
	dc.w d02,cr,d02,tq1,d02,tq2,d02,tq1
	dc.w d02,tq1,d02,tq2,d02,tq1,d02,tq1,d02,tq2,d02,tq1
  	dc.w end_patt

two_stabs
	dc.w a02,cr,a02,cr
  	dc.w end_patt

one_stab
	dc.w d03,cr,rest,cr*8
  	dc.w end_patt


; *********  SNARE     PATTERNS ***********


dsnare
	dc.w r16,cr,r16,tq1,r16,tq2,r16,tq1
	dc.w r16,cr,r16,tq1,r16,tq2,r16,tq1
sfill	dc.w r16,cr,r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1,r16,tq1,r16,tq2,r16,tq1
  	dc.w end_patt





intro_roll

	dc.w r16,tsq1,r16,tsq2,r16,tsq1
	dc.w r16,tsq1,r16,tsq2,r16,tsq1
	dc.w r16,tsq1,r16,tsq2,r16,tsq1
	dc.w r16,tsq1,r16,tsq2,r16,tsq1

	;dc.w rest cr*2
	dc.w r4,cr*7
  	dc.w end_patt

roll2
	dc.w r16,tq1,r16,tq2,r16,tq1,r16,cr
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
  	dc.w end_patt

verse_roll
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w	d03,cr

	;dc.w r16,tq1+tq2,r16,tq1,

  	dc.w new_env
  	dc.l snareeq 
  	dc.w new_snd
  	dc.l snarep



	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1/2,r16,tq1/2
	dc.w r16,tq1,r16,tq2,r16,tq1

	dc.w r16,tq1+tq2,r16,tq1,r16,tq1,r16,tq2,r16,tq1/2,r16,tq1/2
	dc.w r16,tq1/2,r16,tq1/2,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1

	dc.w r16,tq1+tq2,r16,tq1,r16,tq1/2,r16,tq1/2,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1/2,r16,tq1/2


	dc.w r16,tq1+tq2,r16,tq1,r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1/2,r16,tq1/2
	dc.w r16,tq1,r16,tq2,r16,tq1
  	dc.w end_patt

main_tune_stabs


  	dc.w new_env
  	dc.l snareeq 
  	dc.w new_snd
  	dc.l snarep

	dc.w r16,tq1+tq2

  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp

	dc.w a02,tq1,d03,tq1,a02,tq2,d03,tq1,a01,cr+tq1+tq2
	dc.w g02,tq1+tq2+tq1,g02,tq1,c03,cr


  	dc.w new_env
  	dc.l snareeq 
  	dc.w new_snd
  	dc.l snarep

	dc.w r16,tq1+tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2


  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp

	dc.w a02,tq1,d03,tq1,a02,tq2,d03,tq1,a03,cr+tq1+tq2
	dc.w g03,tq1+tq2+tq1,g03,tq1,e03,cr


  	dc.w new_env
  	dc.l snareeq 
  	dc.w new_snd
  	dc.l snarep

	dc.w r16,tq1+tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2

  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp


	dc.w a02,tq1,d03,tq1,a02,tq2,d03,tq1,a03,cr+tq1+tq2
	dc.w g02,tq1+tq2+tq1,g02,tq1,c03,cr+tq1+tq2,e03,tq1+cr


  	dc.w new_env
  	dc.l snareeq 
  	dc.w new_snd
  	dc.l snarep

	dc.w r16,tq1+tq2,r16,tq1,r16,tq1/2,r16,tq1/2,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1/2,r16,tq1/2

	dc.w r16,tq1+tq2,r16,tq1,r16,tq1/2,r16,tq1/2,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1
	dc.w r16,tq1,r16,tq2,r16,tq1/2,r16,tq1/2

  	dc.w end_patt






;*************   BASS PATTERNS


intro_bass1
	dc.w d03,cr,rest,cr*5
  	dc.w end_patt


intro_bass2
	dc.w c03,cr,d03,cr,rest,cr*7,bb02,cr,rest,cr*3
	dc.w c03,cr,rest,cr*2,c03,cr,d03,cr,rest,cr*3
  	dc.w end_patt

verse_bass
	dc.w d03,tq1,a02,tq2,d02,tq1
	dc.w d03,tq1,a02,tq2,d02,tq1
	dc.w d03,tq1,a02,tq2,d02,tq1
	dc.w d03,tq1,a02,tq2,d02,tq1

	dc.w c03,tq1,g02,tq2,c02,tq1
	dc.w c03,tq1,g02,tq2,c02,tq1
	dc.w c03,tq1,g02,tq2,c02,tq1
	dc.w c03,tq1,g02,tq2,c02,tq1

	dc.w bb02,tq1,f02,tq2,bb01,tq1
	dc.w bb02,tq1,f02,tq2,bb01,tq1
	dc.w bb02,tq1,f02,tq2,bb01,tq1
	dc.w bb02,tq1,f02,tq2,bb01,tq1

	dc.w c03,tq1,g02,tq2,c02,tq1
	dc.w c03,tq1,g02,tq2,c02,tq1
	dc.w c03,tq1,g02,tq2,c02,tq1
	dc.w c03,tq1,g02,tq2,c02,tq1

  	dc.w end_patt

mid_bass
	dc.w bb02,cr*2,f02,cr*2
	dc.w bb02,cr*2,f02,cr*2
	dc.w ab02,cr*2,f02,cr*2
	dc.w ab02,cr*2,f02,cr*2
	dc.w eb02,cr*2,db02,cr*2,bb01,cr*2,g01,cr*2
	dc.w db01,cr*8
  	dc.w end_patt

bridge_bass
	dc.w c02,cr,c02,cr,c02,cr,c02,cr
	dc.w c02,cr,c02,cr,c02,cr,c02,cr

	dc.w eb02,cr,eb02,cr,eb02,cr,eb02,cr
	dc.w eb02,cr,eb02,cr,eb02,cr,eb02,cr

	dc.w f02,cr,f02,cr,f02,cr,f02,cr
	dc.w ab02,cr,ab02,cr,ab02,cr,ab02,cr

	dc.w e02,cr,e02,cr,e02,cr,e02,cr

	dc.w a02,cr,a02,cr,g02,cr,g02,cr
	dc.w gb02,cr,gb02,cr,e02,cr,e02,cr

  	dc.w end_patt



****************************************************
;  **********   STRING PATTERNS  *************


string_run
	dc.w d02,tsq1,eb02,tsq2,e02,tsq1
	dc.w f02,tsq1,gb02,tsq2,g02,tsq1
	dc.w ab02,tsq1,a02,tsq2,bb02,tsq1
	dc.w b02,tsq1,c03,tsq2,db03,tsq1

  	dc.w end_patt

mid_chord1
  	dc.w new_env
  	dc.l tympe 
  	dc.w new_snd
  	dc.l newtympp

	dc.w r2,cr*4

  	dc.w new_env
  	dc.l trumpeteq
  	dc.w new_snd
  	dc.l trumpet_loopp



	dc.w bb02,cr*4
	dc.w c03,cr*8
	dc.w eb02,cr*8
	dc.w f03,cr*8
  	dc.w end_patt

mid_chord2
	dc.w f02,cr*8
	dc.w ab02,cr*8
	dc.w bb02,cr*8
	dc.w db03,cr*8
  	dc.w end_patt

;*******************   TYMP PATTERNS *****************

mid_tymp
	dc.w c03,cr*2,c03,cr*2,c03,cr*2,c03,cr*2
	dc.w c03,cr*2,c03,cr*2,c03,cr*2,c03,cr*2
	dc.w c03,cr*2,c03,cr*2
	dc.w c03,cr*2,c03,cr*2
	dc.w c03,cr,g02,cr,c03,cr,g02,cr

  	dc.w end_patt

	; sample parameters

;************************************************************

		;BABA YAGA


cr  set   8
q set  cr/2
sq set q/2

tcr1 set 16
tcr2 set 16
tq1 set	  8
tq2 set   8
tsq1 set 4
tsq2 set 4



sbaba1:		;main tunes

	dc.l	string_sound_loud,pbaba1
	dc.l	pverse_bass1
	dc.l	bass_sound
	dc.l	pverse_bass2
	dc.l	histrg_sound
	dc.l	btune7,btune7o
	dc.l	pizpiano_sound
	dc.l	btune8l
	dc.l	violin_sound_loud
	dc.l	btune8o
	dc.l	flute_loud_sound
	dc.l	trill

	dc.l	pbrestq
	dc.l	pizpiano_sound
	dc.l	fast_violin1
	dc.l	violin_sound_loud
	dc.l	fast_violin2
	dc.l	bass_sound
	dc.l	fast_violin3
	dc.l	violin_sound_loud
	dc.l	fast_violin4

	dc.l	pizpiano_sound
	dc.l	fast_violin5

	dc.l	orch_hit_sound
	dc.l	endbaba1

	dc.l	pri

  	dc.l 	0,end_song
;---------------

sbaba2:		;bass

	dc.l	orch_hit_sound,pbaba2
	dc.l	pbr1,pbr1,flute_sound,plings1
	dc.l	pizpiano,plings2
	dc.l	snare_sound_loud,proll1
	dc.l	btune1_stab
	dc.l	brass_sound,btune1,btune1_stab
	dc.l	brass_sound,btune1
	dc.l	btune4
	dc.l	string_sound_loud
	dc.l	btune7
	dc.l	violin_sound_loud
	dc.l	btune7o
	dc.l	pizpiano_sound
	dc.l	btune8
	dc.l	bass_sound,btune8o
	dc.l	pbr1

;sbaba2
	dc.l	pizpiano_sound
	dc.l	fast_violin1o
	dc.l	violin_sound_loud
	dc.l	fast_violin2
	dc.l	bass_sound
	dc.l	fast_violin3o
	dc.l	violin_sound_loud
	dc.l	fast_violin4

	dc.l	pizpiano_sound
	dc.l	fast_violin5o

	dc.l	endbaba2


	dc.l	pri

        DC.L    0,end_song

;---------------

sbaba3:

	dc.l	bass_sound,pbaba2o
	dc.l	pbr1,pbr1,flute_sound,plings3
	dc.l	pizpiano,plings4
	dc.l	orch_hit_sound,pstab1
	dc.l	bass_sound,gbass
	dc.l	brass_sound,btune2
	dc.l	bass_sound,gbass
	dc.l	brass_sound,btune2
	dc.l	btune5
	dc.l	orch_hit_sound
	dc.l	stab_section

	dc.l	pr10,pr10,pr10,pr10,pr10
	dc.l	pr10,pr10,pr10,pr10,pr10

	dc.l	endbaba3


	dc.l	pri

  	dc.l 	0,end_song
;---------------
		; anything else we can think of
sbaba4:

	dc.l	tymp_sound,pbaba2o
	dc.l	pbr1,pbr1,flute_sound,plings5
	dc.l	pizpiano,plings6
	dc.l	bass_sound,pstab1o
	dc.l	brass_sound,btune3,btune3
	dc.l	trumpet_sound
	dc.l	btune6
	dc.l	orch_hit_sound,pstabg
	dc.l	bass_sound
	dc.l	stab_section_bass

	dc.l	pr10,pr10,pr10,pr10,pr10
	dc.l	pr10,pr10,pr10,pr10,pr10

	dc.l	bass_sound
	dc.l	endbababass


	dc.l pri_new_tune


  	dc.l 	0,end_song


;---------------

pbr1:
	dc.w rest,cr*4
	dc.w end_patt

pri_new_tune
	dc.w play_new_tune
	dc.w end_patt


pri
pbr25
prb25:
	dc.w play_new_tune
	dc.w rest,cr*4
	dc.w end_patt
pr10:
	dc.w rest,cr*10
	dc.w end_patt

pbrestq	dc.w rest,q
	dc.w end_patt

endbaba1
	dc.w eb03,cr*6
	dc.w end_patt

endbaba2
	dc.w rest,cr*6
	dc.w end_patt

endbaba3
	dc.w rest,cr*6
	dc.w end_patt

endbababass
	dc.w eb03,cr*2,eb02,cr*4
	dc.w end_patt



;******************************************

			;string/cello lines etc.

gbass	dc.w	g01,cr*2
	dc.w end_patt

fast_violin1
	dc.w	g03,cr,d03,cr,eb03,cr,b02,cr
fast_violin2
	dc.w	c03,cr,g02,cr,ab02,cr,d02,cr
	dc.w	eb03,cr,b02,cr,c03,cr,g02,cr
	dc.w	ab02,cr,d02,cr,eb02,cr,b02,cr
	dc.w end_patt

fast_violin3
	dc.w	c03,cr,g02,cr,ab02,cr,g02,cr
	dc.w	ab02,cr,g02,cr,b02,cr,g02,cr
	dc.w	ab02,cr,g02,cr,b02,cr,g02,cr
	dc.w	ab02,cr,g02,cr,ab02,cr,bb02,cr
	dc.w	b02,cr,d03,cr,eb03,cr,f03,cr

	dc.w	g02,cr,ab02,cr,bb02,cr,b02,cr
	dc.w	d03,cr,eb03,cr,f03,cr,g03,cr


	dc.w end_patt


fast_violin1o
	dc.w	g02,cr,d02,cr,eb02,cr,b01,cr
fast_violin2o
	dc.w	c02,cr,g01,cr,ab01,cr,d01,cr
	dc.w	eb02,cr,b01,cr,c02,cr,g01,cr
	dc.w	ab01,cr,d01,cr,eb01,cr,b01,cr
	dc.w end_patt

fast_violin3o
	dc.w	c02,cr,g01,cr,ab01,cr,g01,cr
	dc.w	ab01,cr,g01,cr,b01,cr,g01,cr
	dc.w	ab01,cr,g01,cr,b01,cr,g01,cr
	dc.w	ab01,cr,g01,cr,ab01,cr,bb01,cr
	dc.w	b01,cr,d02,cr,eb02,cr,f02,cr

	dc.w	g01,cr,ab01,cr,bb01,cr,b01,cr
	dc.w	d02,cr,eb02,cr,f02,cr,g02,cr
	dc.w end_patt


fast_violin4
	dc.w	ab02,cr,bb02,cr,b02,cr,d03,cr
	dc.w	eb03,cr,f03,cr,g03,cr,ab03,cr
	dc.w	b02,cr,d02,cr,eb02,cr,f02,cr

	dc.w end_patt

fast_violin5
	dc.w	g02,cr,ab02,cr,bb02,cr,b02,cr
	dc.w	d03,cr,eb03,cr,f03,cr,g03,cr
	dc.w	eb03,cr,f03,cr,b02,cr,d03,cr
	dc.w	eb03,cr,f03,cr,b02,cr,d03,cr
	dc.w	eb03,cr,f03,cr,f02,cr,gb02,cr
	dc.w	g02,cr,ab02,cr,a02,cr,bb02,cr
	dc.w	b02,cr,c03,cr,db03,cr,d03,cr
	dc.w	eb03,cr,f03,cr,gb03,cr,g03,cr-q
	dc.w end_patt

fast_violin5o
	dc.w	g01,cr,ab01,cr,bb01,cr,b01,cr
	dc.w	d02,cr,eb02,cr,f02,cr,g02,cr
	dc.w	eb02,cr,f02,cr,b01,cr,d02,cr
	dc.w	eb02,cr,f02,cr,b01,cr,d02,cr
	dc.w	eb02,cr,f02,cr,f01,cr,gb01,cr
	dc.w	g01,cr,ab01,cr,a01,cr,bb01,cr
	dc.w	b01,cr,c02,cr,db02,cr,d02,cr
	dc.w	eb02,cr,f02,cr,gb02,cr,g02,cr
	dc.w end_patt



pbaba1
	dc.w	g01,cr,rest,cr*7,g01,cr*2,g01,cr*2
	dc.w	rest,cr*4,g01,cr*2,g01,cr*2
	dc.w	g01,cr,ab01,cr,g01,cr,f02,cr
	dc.w	g01,cr*2,g01,cr*2,g01,cr,ab01,cr
	dc.w	g01,cr,db02,cr,g01,cr*2,g01,cr*2
	dc.w	g01,cr*2,g01,cr*2,g01,cr,c02,cr
	dc.w	ab01,cr,db02,cr,a01,cr,d02,cr
	dc.w	bb01,cr,eb02,cr,g01,cr,c02,cr
	dc.w	ab01,cr,db02,cr,a01,cr,d02,cr
	dc.w	bb01,cr,eb02,cr
	dc.w	g01,cr,c02,cr,ab01,cr,db02,cr
	dc.w	a01,cr,d02,cr,bb01,cr,eb02,cr
	dc.w	g01,cr,c02,cr,ab01,cr,db02,cr
	dc.w	a01,cr,d02,cr,bb01,cr,eb02,cr
	
	dc.w	g01,cr,c02,cr,ab01,cr,db02,cr
	dc.w	a01,cr,d02,cr,bb01,cr,eb02,cr
	dc.w	g01,cr,c02,cr,ab01,cr,db02,cr
	dc.w	a01,cr,d02,cr,bb01,cr,eb02,cr

	dc.w end_patt

pverse_bass1
	dc.w	g01,cr,gb01,cr,g01,cr,gb01,cr
	dc.w	g01,cr,gb01,cr,g01,cr,gb01,cr
	dc.w	g01,cr,gb01,cr,g01,cr,gb01,cr
	dc.w	c02,cr,bb01,cr,a01,cr,ab01,cr
	dc.w	g01,cr,gb01,cr,g01,cr,gb01,cr
	dc.w	g01,cr,gb01,cr,g01,cr,gb01,cr
	dc.w	g01,cr,gb01,cr,g01,cr,gb01,cr
	dc.w	c02,cr,bb01,cr,a01,cr,ab01,cr
	dc.w end_patt

pverse_bass2
	dc.w	rest,cr*2,c03,cr*2
	dc.w	c02,cr*2,c03,cr*2
	dc.w	rest,cr*2,g03,cr*2
	dc.w	g02,cr*2,g03,cr*2
	dc.w	rest,cr*2,c03,cr*2
	dc.w	c02,cr*2,c03,cr*2
	dc.w	rest,cr*2,g03,cr*2
	dc.w	g02,cr*2,g03,cr*2

	dc.w	rest,cr*2,a03,cr*2
	dc.w	a02,cr*2,a03,cr*2

	dc.w	rest,cr*2,e03,cr*2
	dc.w	e02,cr*2,e03,cr*2

	dc.w	rest,cr*2,a03,cr*2
	dc.w	a02,cr*2,a03,cr*2

	dc.w	rest,cr*2,e03,cr*2
	dc.w	e02,cr*2,e03,cr*2

	dc.w	g01,cr*2
	dc.w end_patt


btune1_stab
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w c03,cr*2
	dc.w end_patt

btune1
	dc.w  g03,cr*2,g03,cr*2,g03,cr*2,g03,cr*2
	dc.w  c03,cr*2,d03,cr*4
	dc.w end_patt

btune2

	dc.w  e03,cr*2,e03,cr*2,e03,cr*2,e03,cr*2
	dc.w  g02,cr*2,ab02,cr*4
	dc.w end_patt

btune3
	dc.w rest,cr*2
	dc.w  c03,cr*2,c03,cr*2,c03,cr*2,c03,cr*2
	dc.w  e02,cr*2,f02,cr*4
	dc.w end_patt


btune4
	dc.w eb03,cr*2,eb03,cr*2,eb03,cr*2,eb03,cr*2
	dc.w g03,cr,d03,cr,eb03,cr,bb02,cr
	dc.w g03,cr,d03,cr,eb03,cr,bb02,cr
	dc.w eb03,cr*2,eb03,cr*2,eb03,cr*2,eb03,cr*2
	dc.w bb02,cr*2,bb02,cr,f02,cr
	dc.w g02,cr,eb02,cr,d03,cr,bb02,cr
	dc.w a02,cr*2,b02,cr*2,b02,cr*2,b02,cr*2
	dc.w g03,cr,d03,cr,e03,cr,c03,cr
	dc.w g03,cr,d03,cr,e03,cr,c03,cr

	dc.w a02,cr*2,b02,cr*2,b02,cr*2,b02,cr*2
	dc.w c03,cr*2,c03,cr,g02,cr,a02,cr,f02,cr
	dc.w e02,cr,c02,cr,g02,cr*2


	dc.w end_patt

btune5
	dc.w gb03,cr*2,a03,cr*2,a03,cr*2,a03,cr*2

	dc.w g02,cr,d02,cr,eb02,cr,bb01,cr
	dc.w g02,cr,d02,cr,eb02,cr,bb01,cr

	dc.w gb03,cr*2,a03,cr*2,a03,cr*2,a03,cr*2

	dc.w bb01,cr*2,bb01,cr,f01,cr
	dc.w g01,cr,eb01,cr,d02,cr,bb01,cr

	dc.w b02,cr*2,eb03,cr*2,eb03,cr*2,eb03,cr*2
	dc.w g02,cr,d02,cr,e02,cr,c02,cr
	dc.w g02,cr,d02,cr,e02,cr,c02,cr

	dc.w b02,cr*2,eb03,cr*2,eb03,cr*2,eb03,cr*2

	dc.w c02,cr*2,c02,cr,g01,cr,a01,cr,f01,cr
	dc.w e01,cr,c01,cr,g01,cr*2


	dc.w end_patt

btune6
	dc.w 	gb02,cr*8,bb02,cr*8
	dc.w 	gb02,cr*8,bb02,cr*8
	dc.w 	gb02,cr*8,bb02,cr*8
	dc.w 	gb02,cr*8,c03,cr*8
	
	dc.w end_patt

btune7
	dc.w	g03,cr,d03,cr,eb03,cr,d03,cr,bb02,cr,g02,cr
	dc.w	ab02,cr,eb03,cr,b02,cr,eb03,cr,d03,cr*2
	dc.w	b02,cr*2
	dc.w end_patt

btune7o
	dc.w	g03,cr*2,g03,cr,d03,cr,eb03,cr,d03,cr
	dc.w	bb02,cr,g02,cr
	dc.w	ab02,cr,eb03,cr,b02,cr,eb03,cr,d03,cr*2
	dc.w	g02,cr*2
	dc.w end_patt


btune8
	dc.w	g03,cr*2,g03,cr,d03,cr,eb03,cr,d03,cr
	dc.w	bb02,cr,g02,cr
	dc.w	rest,cr*2
	dc.w	g03,cr,d03,cr,eb03,cr,d03,cr
	dc.w	bb02,cr,g02,cr
	dc.w	rest,cr*2
	dc.w end_patt

btune8l
	dc.w	g02,cr*2,g02,cr,d02,cr,eb02,cr,d02,cr
	dc.w	bb01,cr,g01,cr
	dc.w	rest,cr*2
	dc.w	g02,cr,d02,cr,eb02,cr,d02,cr
	dc.w	bb01,cr,g01,cr
	dc.w	rest,cr*2
	dc.w end_patt



btune8o
	dc.w	g03,cr,d03,cr,eb03,cr,d03,cr
	dc.w	bb02,cr,g02,cr
	dc.w	rest,cr*2
	dc.w	g03,cr,d03,cr,eb03,cr,d03,cr
	dc.w	bb02,cr,g02,cr
	dc.w	rest,cr*4
	dc.w end_patt

trill
	dc.w	b02,cr
	dc.w	d03,sq,eb03,sq,f03,sq,g03,sq,ab03,cr*2
	dc.w end_patt



;******************************

		;orch hit patterns

pbaba2
	dc.w	g03,cr+cr*7,g03,cr*2,g03,cr*6
	dc.w	g03,cr*2,g03,cr*2,g03,cr*2,rest,cr*2
	dc.w	g03,cr*2,g03,cr*2,g03,cr*2,rest,cr*2
	dc.w	g03,cr*2,g03,cr*2,g03,cr*2,rest,cr*2
	dc.w	g03,cr*2,g03,cr*2,g03,cr*2,rest,cr*2
	dc.w end_patt

pbaba2o
	dc.w	g02,cr+cr*7,g02,cr*2,g02,cr*6
	dc.w	g02,cr*2,g02,cr*2,g02,cr*2,rest,cr*2
	dc.w	g02,cr*2,g02,cr*2,g02,cr*2,rest,cr*2
	dc.w	g02,cr*2,g02,cr*2,g02,cr*2,rest,cr*2
	dc.w	g02,cr*2,g02,cr*2,g02,cr*2,rest,cr*2
	dc.w end_patt

pstab1
	dc.w	g03,cr*8
	dc.w end_patt

pstab1o
	dc.w	g01,cr*8
	dc.w end_patt

pstabg
	dc.w	g03,cr*2
	dc.w end_patt

pstabc
	dc.w	c03,cr*2
	dc.w end_patt

stab_section
	dc.w	rest,cr*12
	dc.w	g03,cr*2
	dc.w	rest,cr*14
	dc.w	g03,cr*2
	dc.w	rest,cr*8
	dc.w	gb03,cr*2
	dc.w	rest,cr*6
	dc.w	f03,cr*2
	dc.w	rest,cr*6
	dc.w	e03,cr*2

  	dc.w new_env
  	dc.l snaree 
  	dc.w new_snd
  	dc.l snarep
	dc.w	r16,cr,r16,cr,r16,cr
	dc.w	r16,cr,r16,cr,r16,cr
	
  	dc.w new_env
  	dc.l orchhite 
  	dc.w new_snd
  	dc.l orchhitpp
	dc.w	eb03,cr*2,d03,cr*2
	dc.w	b02,cr*2,ab03,cr*2

	dc.w end_patt

stab_section_bass
	dc.w	rest,cr*12
	dc.w	g01,cr*2
	dc.w	rest,cr*14
	dc.w	g01,cr*2
	dc.w	rest,cr*8
	dc.w	gb01,cr*2
	dc.w	rest,cr*6
	dc.w	f01,cr*2
	dc.w	rest,cr*6
	dc.w	e01,cr*2
	dc.w	rest,cr*6
	dc.w	eb01,cr*2,d01,cr*2
	dc.w	b01,cr*2,ab02,cr*2
	dc.w end_patt



;*****************************

			;flute bits

plings1
	dc.w	e03,cr*2,db03,cr*2,c03,cr*2,bb02,cr*2
	dc.w	e02,cr*2,db02,cr*2,c02,cr*2,bb01,cr*2
	dc.w end_patt

plings2
	dc.w	e03,cr*2,db03,cr*2,c03,cr*2,bb02,cr*2
	dc.w end_patt

plings3
	dc.w	c03,cr*2,ab02,cr*2,gb02,cr*2,g02,cr*2
	dc.w	c02,cr*2,ab01,cr*2,gb01,cr*2,g01,cr*2
	dc.w end_patt

plings4
	dc.w	c03,cr*2,ab02,cr*2,gb02,cr*2,g02,cr*2
	dc.w end_patt


plings5
	dc.w	e02,cr*2,f02,cr*2,d02,cr*2,bb01,cr*2
	dc.w	e01,cr*2,f01,cr*2,d01,cr*2,bb00,cr*2
	dc.w end_patt

plings6
	dc.w	e02,cr*2,f02,cr*2,d02,cr*2,bb01,cr*2
	dc.w end_patt

;******************************

			;snare drums etc

proll1
	dc.w	rest,cr*4,r16,cr,r16,cr,r16,cr,r16,cr
	dc.w end_patt

;&&&&&&&&&&&&&&&&&&&&&&&

cr  set   24
q set  cr/2
sq set q/2

tcr1 set 16
tcr2 set 16
tq1 set	  8
tq2 set   8
tsq1 set 4
tsq2 set 4

sgg1
	dc.l	brass_sound
	dc.l	ggtune1,ggtune2,ggtune1,ggend
	dc.l	pri

  	dc.l 	0,end_song


sgg2

	dc.l	trumpet_sound
	dc.l	ggharm1,ggharm2,ggharm1,ggend2
	dc.l	pri

  	dc.l 	0,end_song

sgg3

	dc.l	bass_sound
	dc.l	ggbass1,ggbass2,ggbass1,ggend3
	dc.l	pri


  	dc.l 	0,end_song

sgg4

	dc.l	trumpet_sound
	dc.l	ggtune1,ggtune2,ggtune1,ggend
	dc.l pri_new_tune


  	dc.l 	0,end_song



ggtune1
	dc.w	eb02,cr*4,f02,cr*4,g02,cr*2
	dc.w	eb02,cr,g02,cr,f02,cr*2,bb01,cr*2
	dc.w	g02,cr,bb02,cr,f02,cr,eb02,cr
	dc.w	d02,cr*2,bb01,cr*2
	dc.w	g02,cr,bb02,cr,f02,cr,eb02,cr
	dc.w	d02,cr*2,bb01,cr*2

	dc.w end_patt
ggtune2
	dc.w	eb02,cr*4,f02,cr*4,g02,cr*2
	dc.w	eb02,cr,g02,cr,f02,cr*2,bb01,cr*2

	dc.w	eb03,cr,eb03,cr,d03,cr,bb02,cr
	dc.w	c03,cr,c03,cr,ab02,cr,c03,cr
	dc.w	bb02,cr*2,ab02,cr,g02,cr
	dc.w	f02,cr*4,bb02,cr*2,c03,cr*2
	dc.w	eb02,cr,eb02,cr,d02,cr,c02,cr
	dc.w	bb01,cr*2,ab01,cr,g01,cr,f01,cr*4
	dc.w	bb01,cr*4

	dc.w end_patt

ggend
	dc.w	eb02,cr*8	
	dc.w end_patt

ggharm1
	dc.w	bb01,cr*4,d02,cr*4,eb02,cr*2
	dc.w	c02,cr,c02,cr,d02,cr*2,g01,cr*2
	dc.w	eb02,cr,g02,cr,bb01,cr*2
	dc.w	bb01,cr*2,g01,cr*2
	dc.w	eb02,cr,g02,cr,bb01,cr*2
	dc.w	bb01,cr*2,g01,cr*2

	dc.w end_patt
ggharm2
	dc.w	bb01,cr*4,d02,cr*4,eb02,cr*2
	dc.w	c02,cr*2,d02,cr*2,g01,cr*2

	dc.w	ab02,cr*2,ab02,cr*2
	dc.w	eb02,cr*4
	dc.w	eb02,cr*4
	dc.w	c02,cr*4,f02,cr*2,g02,cr*2
	dc.w	c02,cr*2,ab01,cr*2
	dc.w	eb01,cr*4,c01,cr*4,g01,cr*4

	dc.w end_patt

ggend2
	dc.w	g02,cr*8	
	dc.w end_patt


ggbass1
	dc.w	g02,cr*4,f02,cr*4,eb02,cr*2
	dc.w	c02,cr*2,d02,cr*2,bb02,cr*2
	dc.w	eb02,cr*2,d02,cr,c02,cr
	dc.w	bb01,cr*2,g01,cr*2
	dc.w	eb02,cr*2,d02,cr,c02,cr
	dc.w	bb01,cr*2,g01,cr*2

	dc.w end_patt
ggbass2
	dc.w	g02,cr*4,f02,cr*4,eb02,cr*2
	dc.w	c02,cr*2,d02,cr*2,bb01,cr*2

	dc.w	c03,cr,c03,cr,bb02,cr,g02,cr
	dc.w	ab02,cr,ab02,cr,f02,cr,ab02,cr
	dc.w	g02,cr*2,ab02,cr,eb02,cr
	dc.w	f03,cr*4,d03,cr*2,c03,cr*2
	dc.w	c03,cr,c03,cr,bb02,cr,ab02,cr
	dc.w	g01,cr*2,f01,cr,eb01,cr,ab01,cr*4
	dc.w	g01,cr*4

	dc.w end_patt

ggend3
	dc.w	eb01,cr*8	
	dc.w end_patt



;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


cr  set   12
q set  cr/2
sq set q/2

tcr1 set 16
tcr2 set 16
tq1 set	  8
tq2 set   8
tsq1 set 4
tsq2 set 4

rvs1

	;dc.l	rvr6
	dc.l	trumpet_sound
	dc.l	sus_start


	dc.l	trumpet_sound
	dc.l	rvtune1
	dc.l	orch_hit_sound
	dc.l	rvstabs1
				;rpt1
	dc.l	trumpet_sound
	dc.l	rvtune1
	dc.l	orch_hit_sound
	dc.l	rvstabs1


	dc.l	brass_sound
	dc.l	end_tune_brass

	dc.l	pri


  	dc.l 	0,end_song

rvs2

	dc.l	string_sound_loud
	dc.l	trill_intro


	;dc.l	rvr3
	dc.l	pizpiano_sound_quiet
	dc.l	rvhivi1_start
	dc.l	rvhivi1
	dc.l	rvhivi2
	dc.l	rvhivi2
	dc.l	rvhivi2
	dc.l	rvhivi2
	dc.l	rvhivi2
	dc.l	rvhivi3
	dc.l	rvhivi4
	dc.l	rvhivi4
	dc.l	rvhivi4
	dc.l	rvhivi4a
	dc.l	rvhivi5
	dc.l	rvhivi6
	dc.l	rvhivi5
	dc.l	rvhivi7
	dc.l	rvhivi8
			;rpt 1



	dc.l	rvhivi1
	dc.l	rvhivi2
	dc.l	rvhivi2
	dc.l	rvhivi2
	dc.l	rvhivi2
	dc.l	rvhivi2
	dc.l	rvhivi3
	dc.l	rvhivi4
	dc.l	rvhivi4
	dc.l	rvhivi4
	dc.l	rvhivi4a
	dc.l	rvhivi5
	dc.l	rvhivi6
	dc.l	rvhivi5
	dc.l	rvhivi7
	dc.l	rvhivi8


	dc.l	pizpiano_sound

	dc.l	end_tune_vi
	dc.l	pri

  	dc.l 	0,end_song

rvs3


	dc.l	string_sound_loud
	dc.l	rvtune1_acc_start
	dc.l	rvtune1_acc
				;rpt 1
	dc.l	bass_sound
	dc.l	rvtune1_acc


	dc.l	bass_sound

	dc.l	end_tuneo
	dc.l	pri

  	dc.l 	0,end_song

rvs4

	dc.l	snare_sound
	dc.l	snare_patt_rests
	dc.l	tymp_sound
	dc.l	rvtymp1
	dc.l	snare_sound
	dc.l	tick,tick,tick,tick,tick,tick,tick
	dc.l	tick1
	dc.l	orch_hit_sound
	dc.l	end_tune_stabs
	dc.l pri_new_tune
  	dc.l 	0,end_song

rvr6
	dc.w rest,cr*18
	dc.w end_patt

rvr3
	dc.w rest,cr*9
	dc.w end_patt

clock
	dc.w	r16,cr*3
	dc.w end_patt



tick

	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
tick1	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q

	dc.w end_patt

snare_patt_rests

	dc.w	rest,cr*48*3+cr+cr
	dc.w end_patt

rvtymp1
	dc.w	r16,cr,r16,cr+q,r16,q
	dc.w	r16,cr,r16,cr*5

	dc.w	r16,cr,r16,cr+q,r16,q
	dc.w	r16,cr,r16,cr*5

	dc.w	r16,cr,r16,cr+q,r16,q
	dc.w	r16,cr,r16,cr*3,r16,cr*3

	dc.w	rest,cr*3*5+cr+cr
	dc.w	r16,cr,r16,cr+q,r16,q
	dc.w	r16,cr,r16,cr*5

	dc.w	r16,cr,r16,cr+q,r16,q
	dc.w	r16,cr,r16,cr*5

	dc.w	r16,cr,r16,cr+q,r16,q
	dc.w	r16,cr,r16,cr*3,r16,cr*3,r16,cr
	dc.w	r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q
	dc.w	r16,cr,r16,q,r16,q,r16,q,r16,q

	dc.w	r12,cr*3
	dc.w	rest,cr*3

	dc.w end_patt

end_tune
	dc.w	rest,cr,d02,cr,g02,cr+q,d02,q,g02,cr,c03,cr*3
	dc.w	f03,cr*3,bb03,cr*3
	dc.w end_patt

end_tune_brass
	dc.w	rest,cr*2,d02,cr,g02,cr+q,d02,q,g02,cr,c03,cr*3
	dc.w	f03,cr*3,bb03,cr*3
	dc.w end_patt

end_tune_vi
	dc.w	d02,cr,g02,cr+q,d02,q,g02,cr,c03,cr*3
	dc.w	f03,cr*3,bb03,cr*3
	dc.w end_patt


end_tuneo
	dc.w	rest,cr,d01,cr,g01,cr+q,d01,q,g01,cr,c02,cr*3
	dc.w	f01,cr*3,bb01,cr*3
	dc.w end_patt

end_tune_stabs
	dc.w	rest,cr*3,c03,cr*3,f02,cr*3,bb02,cr*3
	dc.w end_patt





trill_intro
	dc.w	rest,cr
	dc.w	g02,q,a02,q,bb02,q,c03,q
	dc.w	d03,sq,eb03,sq,d03,sq,eb03,sq
	dc.w	d03,sq,eb03,sq,d03,sq,eb03,sq
	dc.w    d03,sq,eb03,sq,d03,sq,eb03,sq
	dc.w	d03,sq,eb03,sq,d03,sq,eb03,sq
	dc.w 	d03,sq,eb03,sq,d03,sq,eb03,sq
	dc.w	d03,sq,eb03,sq,d03,sq,eb03,sq
	dc.w	d03,sq,eb03,sq,d03,sq,eb03,sq
	dc.w end_patt

sus_start
	dc.w	rest,cr,g02,q,a02,q,bb02,q,c03,q
	dc.w d03,cr*15
	dc.w end_patt



rvstabs1
	dc.w	a03,cr*3,d03,cr*3,g03,cr*9
	dc.w	g03,cr*3,rest,cr*3

	dc.w end_patt


rvtune1_acc_start
	dc.w	rest,cr*6
	dc.w	g01,cr+q,g02,q,d02,cr
	dc.w	d02,cr+q,d03,q,g02,cr,d03,cr*3

	dc.w	g01,cr+q,g02,q,d02,cr,d03,cr
	dc.w end_patt

rvtune1_acc
	dc.w	rest,cr
	dc.w	d02,cr,g02,cr+q
	dc.w	d02,q,g02,cr,bb02,cr+q,g02,q,d02,cr
	dc.w	g02,cr+q,d02,q,g01,cr

	dc.w	bb02,cr+q,g02,q,bb02,cr,d03,cr+q,g02,q,d02,cr
	dc.w	bb02,cr+q,d02,q,g02,cr,d03,cr+q,bb02,q
	dc.w	d03,cr,f03,cr+q,bb02,q,f02,cr,f02,cr+q,c02,q
	dc.w	f01,cr,bb02,cr+q

	dc.w	f02,q,bb02,cr,bb01,cr+q,bb02,q,f02,cr,f02,cr
	dc.w	f03,cr,bb02,cr,d02,cr*3
;end of page 1


	dc.w	bb01,cr+q,bb02,q,f02,cr,f02,cr+q,d03,q,bb02,cr
	dc.w	d03,cr*3
	dc.w	bb01,cr+q,bb02,q,f02,cr,f02,cr+q,d02,q,bb01,cr
	dc.w	d02,cr*3
	dc.w	bb01,cr+q,bb02,q,f02,cr,f03,cr*2


	dc.w	f02,cr
	dc.w	bb02,cr+q,f02,q,bb02,cr,d03,cr+q
	dc.w	bb02,q,f02,cr

	dc.w	bb02,cr+q,f02,q,bb01,cr,d03,cr+q,bb02,q
	dc.w	d03,cr,f03,cr+q,bb02,q,f02,cr
	dc.w	d03,cr+q,f02,q,bb01,cr,f03,cr+q,d03,q
	dc.w	f03,cr
	dc.w	a02,cr+q,d03,q
	dc.w	a02,cr,a01,cr+q,e02,q,a01,cr,d03,cr+q
	dc.w	a02,q,d03,cr
	
	dc.w	gb03,cr+q,a02,q,d02,cr,d02,cr+q,d03,q,a02,cr
	dc.w	gb03,cr*3


	dc.w	d02,cr+q,a02,q,d02,cr,d02,cr+q,d03,q,a02,cr
	dc.w	gb03,cr*3

	dc.w	d02,cr+q,a02,q,d02,cr,d02,cr+q,d03,q,a02,cr
	dc.w	gb03,cr*3
;end of page 2

	dc.w	d02,cr+q,a02,q,d02,cr,d03,cr,rest,cr

	dc.w	d02,cr
	dc.w	eb02,cr+q,c02,q,eb02,cr
	dc.w	g01,cr+q,d02,q,g01,cr,g01,cr*2,rest,q


	dc.w	d02,q
	dc.w	eb02,cr+q,c02,q,eb02,cr,g03,cr+q,d03,q,g03,cr,g03,cr*2
	dc.w	rest,q,d02,q
	dc.w	eb02,cr+q,c02,q,eb02,cr,ab03,cr+q
	dc.w	eb03,q,ab02,cr
	dc.w	d03,cr+q,a02,q,d03,cr,bb01,cr+q,g02,q,bb02,cr


	dc.w	g01,cr+q,g02,q,d02,cr,d02,cr+q,d03,q,g02,cr
	dc.w	d03,cr*3
	dc.w	g01,cr+q,g02,q,d02,cr,d02,cr*2


	dc.w	d03,cr
	dc.w	eb03,cr+q,c03,q,eb03,cr,g02,cr+q
	dc.w	d02,q,g02,cr,g03,q,rest,q+cr

	dc.w	d03,cr
	dc.w	eb03,cr+q,c03,q,eb03,cr,g03,cr+q
	dc.w	d03,q,g02,cr,g03,q,rest,q+cr
	dc.w	d03,cr
	dc.w	eb03,cr+q,c03,q,eb03,cr
			;;;;;stab section

	dc.w	c02,cr+q,e02,q,c02,cr
	dc.w	d02,cr+q,a02,q,d02,cr
	dc.w	g02,cr+q,g01,q,b01,cr

			;;;;end of main bit
	dc.w	g01,cr+q,g02,q,d02,cr,d03,cr+q
	dc.w	g02,q,d03,cr,d03,cr*3
	dc.w	g01,cr+q,g02,q,d02,cr,d03,cr

	dc.w end_patt


rvhivi1_start
	dc.w	g02,q,a02,q,bb02,q,c03,q,d03,q
	dc.w	eb03,q,d03,q,bb02,q,g02,cr
	dc.w	d02,q,eb02,q,d02,q,bb01,q,g01,cr

	dc.w	rest,q,d02,q,g02,q,a02,q
	dc.w end_patt
rvhivi1
	dc.w	bb02,q,c03,q,d03,q
	dc.w	eb03,q,d03,q,bb02,q,g02,cr
	dc.w	d02,q,eb02,q,d02,q,bb01,q,g01,cr

	dc.w	rest,q,d02,q,g02,q,a02,q,bb02,q,c03,q,d03,q
	dc.w	eb03,q,d03,q,bb02,q,g02,cr
	dc.w	d02,q,eb02,q,d02,q,bb01,q,g01,cr

	dc.w	rest,q,g02,q,bb02,q,c03,q,d03,q
	dc.w	eb03,q,f03,q,g03,q,f03,q,d03,q
	dc.w	bb02,cr,f02,q,g02,q,f02,q,d02,q,bb01,cr

	dc.w	rest,q,f02,q,a02,q,c03,q,d03,q
	dc.w	eb03,q,f03,q,g03,q,f03,q,d03,q
	dc.w	bb02,cr,f02,q,g02,q,f02,q,d02,q,bb01,cr
	dc.w end_patt
	
rvhivi2

	dc.w	rest,q,f02,q,bb02,q,c03,q,d03,q
	dc.w	eb03,q,f03,q,g03,q,f03,q,d03,q
	dc.w	bb02,cr,f02,q,g02,q,f02,q,d02,q,bb01,cr
	dc.w end_patt

rvhivi3
	dc.w	rest,q,bb01,q,d02,q,e02,q,f02,q
	dc.w	g02,q,a02,q,bb02,q,a02,q,f02,q
	dc.w	d02,cr
	dc.w	a02,q,bb02,q,a02,q,f02,q
	dc.w	d02,cr
	dc.w	rest,q,e02,q,a02,q,bb02,q,b02,q
	dc.w	db03,q,d03,q,db03,q,d03,q,a02,q
	dc.w	f02,cr
	dc.w end_patt

rvhivi4

	dc.w	d02,q,db02,q,d02,q,a01,q,gb01,cr
	dc.w	rest,q,d02,q,gb02,q,a02,q,b02,q
	dc.w	db03,q,d03,q,db03,q,d03,q
	dc.w	a02,q,f02,cr
	dc.w end_patt

rvhivi4a
	dc.w	d02,q,db02,q,d02,q,a01,q,gb01,cr
	dc.w end_patt


rvhivi5
	dc.w	rest,cr,d03,q,c03,q,bb02,q,a02,q
	dc.w	c03,q,ab02,q,g02,q,eb02,q
	dc.w	c02,cr
	dc.w	g02,q,a02,q,g02,q,d02,q,bb01,cr

	dc.w	rest,q,d02,q,d03,q,c03,q,bb02,q,a02,q
	dc.w	g03,q,ab02,q,g02,q,eb02,q
	dc.w	c02,cr
	dc.w	g02,q,a02,q,g02,q,d02,q,bb01,cr

	dc.w	rest,q,d02,q,d03,q,c03,q,bb02,q,a02,q
	dc.w	c03,q,d02,q,c03,q,g02,q
	dc.w	eb02,cr
	dc.w end_patt

rvhivi6
	dc.w	ab02,q,bb02,q,ab02,q,eb02,q,c02,cr
	dc.w	d02,q,e02,q,d02,q,a01,q,f01,cr
	dc.w	d03,q,e03,q,d03,q,bb02,q,g02,cr
	dc.w	d02,q,eb02,q,d02,q,bb01,q,g01,cr

	dc.w	rest,q,d02,q,g02,q,a02,q,bb02,q,c03,q,d03,q
	dc.w	eb03,q,d03,q,bb02,q,g02,cr
	dc.w	d02,q,eb02,q,d02,q,bb01,q,g01,cr

	
	dc.w end_patt

rvhivi7					;stab section
	dc.w	a02,q,bb02,q,a02,q,eb02,q,c02,cr
	dc.w	d02,q,eb02,q,c02,q,a01,q
	dc.w	gb01,cr
	dc.w	d03,q,e03,q,d03,q,b02,q,g02,cr

	dc.w end_patt

rvhivi8
	dc.w	d02,q,e02,q,d02,q,b01,q,g01,cr
	dc.w	rest,q,d02,q,g02,q,a02,q,b02,q,c03,q
	dc.w	d03,q,e03,q,d03,q,b02,q,g02,cr
	dc.w	d02,q,e02,q,d02,q,b01,q,g01,cr
	dc.w	rest,q,d02,q,g02,q,a02,q

	dc.w end_patt



rvtune1

	dc.w	rest,cr*2,d02,cr,g02,cr+q
	dc.w	d02,q,g02,cr,bb02,cr*3,g02,cr*3
	dc.w	bb02,cr+q,g02,q,bb02,cr,d03,cr*3
	dc.w	bb02,cr*3,d03,cr+q,bb02,q
	dc.w	d03,cr,f03,cr*3,f02,cr*3,bb02,cr+q
	dc.w	f02,q,bb02,cr,d03,cr*9

	dc.w	rest,cr*21,rest,cr*2,f02,cr
	dc.w	bb02,cr+q,f02,q,bb02,cr,d03,cr*3
	dc.w	bb02,cr*3,d03,cr+q,bb02,q
	dc.w	d03,cr,f03,cr*3,d03,cr*3,f03,cr+q,d03,q
	dc.w	f03,cr
	dc.w	a03,cr*3,a02,cr*3,d03,cr+q
	dc.w	a02,q,d03,cr,gb03,cr*9
	
	dc.w	rest,cr*21,rest,cr*2
	dc.w	d02,cr
	dc.w	eb02,cr+q,c02,q,eb02,cr,g02,cr*5
	dc.w	d02,cr
	dc.w	eb02,cr+q,c02,q,eb02,cr,g02,cr*5
	dc.w	d02,cr
	dc.w	eb02,cr+q,c02,q,eb02,cr,ab02,cr*3	
	dc.w	d02,cr*3,rest,cr*3
	dc.w	rest,cr*12,rest,cr*2

	dc.w	d03,cr
	dc.w	eb03,cr+q,c03,q,eb03,cr,g03,cr*5
	dc.w	d03,cr
	dc.w	eb03,cr+q,c03,q,eb03,cr,g03,cr*5
	dc.w	d03,cr
	dc.w	eb03,cr+q,c03,q,eb03,cr	

	dc.w end_patt
;{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{



cr  set   24
q set  cr/2
sq set q/2

tcr1 set 13
tcr2 set 14
tq set	  8
tsq1 set 3
tsq2 set 4


jalt1
	dc.l	pizpiano_sound_short
	dc.l	trip_start
	dc.l	trip_start
	dc.l	trip_start
	dc.l	trip_start
	dc.l	flute_sound,intro_tune1
	dc.l	brass_sound,brass_intro
	dc.l	flute_sound,intro_tune1

	dc.l	string_sound_loud
	dc.l	string_run4



	dc.l	string_sound_loud
	dc.l	main_tune1
	dc.l	brass_sound
	dc.l	main_tune2
	dc.l	string_sound_louder
	dc.l	main_tune3
	dc.l	main_tune4

	dc.l	string_sound_loud
	dc.l	main_tune1
	dc.l	brass_sound
	dc.l	main_tune2
	dc.l	string_sound_louder
	dc.l	main_tune3
	dc.l	main_tune4

	dc.l	trumpet_sound

	dc.l	middle_tune

	dc.l	string_sound_loud
	dc.l	string_run4

		
	dc.l	string_sound_loud
	dc.l	main_tune1
	dc.l	brass_sound
	dc.l	main_tune2
	dc.l	string_sound_louder
	dc.l	main_tune3
	dc.l	main_tune4

	dc.l	string_sound_loud
	dc.l	main_tune1
	dc.l	brass_sound
	dc.l	main_tune2
	dc.l	string_sound_louder
	dc.l	main_tune3
	dc.l	main_tune4

	dc.l	trumpet_sound

	dc.l	middle_tune

	dc.l	string_sound_loud
	dc.l	string_run4



	dc.l	brass_sound
	dc.l	end1
	dc.l	final1


	dc.l	pri

	dc.l	0,end_song


jalt2

	dc.l	orch_hit_sound
	dc.l	ja_stab_intro

	dc.l	histrg_sound
	dc.l	ja_gstrings1
	dc.l	ja_gstrings1
	dc.l	ja_gstrings1

	dc.l	snare_sound
	dc.l	snare_roll4


	dc.l	pizpiano_sound_quiet
	dc.l	main_tune_acc1
	dc.l	main_tune_acc4
	dc.l	histrg_sound
	dc.l	main_tune_acc5a
	dc.l	orch_hit_sound
	dc.l	main_tune_end_stabs

	dc.l	snare_sound_mid
	dc.l	verse_snare
	dc.l	verse_snare
	dc.l	verse_snare

	dc.l	orch_hit_sound
	dc.l	main_tune_end_stabs

	dc.l	pizpiano_sound_quiet
	dc.l	mid_acc1
	dc.l	mid_acc1_ext
	dc.l	mid_acc1

	dc.l	snare_sound
	dc.l	snare_roll4

	dc.l	pizpiano_sound_quiet
	dc.l	main_tune_acc1
	dc.l	main_tune_acc4
	dc.l	histrg_sound
	dc.l	main_tune_acc5a
	dc.l	orch_hit_sound
	dc.l	main_tune_end_stabs

	dc.l	snare_sound_mid
	dc.l	verse_snare
	dc.l	verse_snare
	dc.l	verse_snare

	dc.l	orch_hit_sound
	dc.l	main_tune_end_stabs

	dc.l	pizpiano_sound_quiet
	dc.l	mid_acc1
	dc.l	mid_acc1_ext
	dc.l	mid_acc1

	dc.l	snare_sound
	dc.l	snare_roll4

	dc.l	brass_sound
	dc.l	end2
	dc.l	orch_hit_sound
	dc.l	final1_hits

	dc.l	pri
	dc.l	0,end_song

jalt3
	dc.l	bass_sound
	dc.l	ja_stab_introo

	dc.l	histrg_sound

	dc.l	ja_gstrings2
	dc.l	ja_gstrings2
	dc.l	ja_gstrings2

	dc.l	orch_hit_sound
	dc.l	four_stabs

	dc.l	bass_sound
	dc.l	main_tune_stabo
	dc.l	pizpiano_sound_quiet
	dc.l	main_tune_acc2
	dc.l	bass_sound
	dc.l	main_tune_bass_run1

	dc.l	histrg_sound
	dc.l	main_tune_acc5b

	dc.l	bass_sound
	dc.l	main_tune_end_stabs_bass_long


	dc.l	bass_sound
	dc.l	main_tune_stabo
	dc.l	pizpiano_sound_quiet
	dc.l	main_tune_acc2
	dc.l	bass_sound
	dc.l	main_tune_bass_run1

	dc.l	histrg_sound
	dc.l	main_tune_acc5b

	dc.l	bass_sound
	dc.l	main_tune_end_stabs_bass
	dc.l	tymp_sound
	dc.l	jacrash


	dc.l	flute_sound_quiet
	dc.l	mid_flute_ext
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute_ext

	dc.l	orch_hit_sound
	dc.l	four_stabs

	dc.l	bass_sound
	dc.l	main_tune_stabo
	dc.l	pizpiano_sound_quiet
	dc.l	main_tune_acc2
	dc.l	bass_sound
	dc.l	main_tune_bass_run1

	dc.l	histrg_sound
	dc.l	main_tune_acc5b

	dc.l	bass_sound
	dc.l	main_tune_end_stabs_bass_long


	dc.l	bass_sound
	dc.l	main_tune_stabo
	dc.l	pizpiano_sound_quiet
	dc.l	main_tune_acc2
	dc.l	bass_sound
	dc.l	main_tune_bass_run1

	dc.l	histrg_sound
	dc.l	main_tune_acc5b

	dc.l	bass_sound
	dc.l	main_tune_end_stabs_bass
	dc.l	tymp_sound
	dc.l	jacrash
	dc.l	flute_sound_quiet
	dc.l	mid_flute_ext
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute
	dc.l	mid_flute_ext

	dc.l	orch_hit_sound
	dc.l	four_stabs


	dc.l	bass_sound
	dc.l	end3
	dc.l	brass_sound
	dc.l	end3_ext
	dc.l	bass_sound
	dc.l	final1o



	dc.l	pri

	dc.l	0,end_song

jalt4

	dc.l	tymp_sound
	dc.l	ja_stab_intro

	dc.l	histrg_sound

	dc.l	ja_gstrings3
	dc.l	ja_gstrings3
	dc.l	ja_gstrings3

	dc.l	bass_sound
	dc.l	four_stabso

	dc.l	orch_hit_sound
	dc.l	main_tune_stab
	dc.l	pizpiano_sound_quiet
	dc.l	main_tune_acc3
	dc.l	string_sound_loud
	dc.l	main_tune_bass_run1

	dc.l	histrg_sound
	dc.l	main_tune_acc5c

	dc.l	snare_sound
	dc.l	main_tune_end_snare

	dc.l	bass_sound
	dc.l	moving_bass
	dc.l	main_tune_end_stabs_bass_long

	dc.l	bass_sound
	dc.l	ja_mid_bass

	dc.l	bass_sound
	dc.l	four_stabso


	dc.l	orch_hit_sound
	dc.l	main_tune_stab
	dc.l	pizpiano_sound_quiet
	dc.l	main_tune_acc3
	dc.l	string_sound_loud
	dc.l	main_tune_bass_run1

	dc.l	histrg_sound
	dc.l	main_tune_acc5c

	dc.l	snare_sound
	dc.l	main_tune_end_snare

	dc.l	bass_sound
	dc.l	moving_bass
	dc.l	main_tune_end_stabs_bass_long

	dc.l	bass_sound
	dc.l	ja_mid_bass

	dc.l	bass_sound
	dc.l	four_stabso


	dc.l	snare_sound_mid
	dc.l	snare_end
	dc.l	orch_hit_sound
	dc.l	end4

	dc.l	snare_sound_mid
	dc.l	final_snare



	dc.l pri_new_tune

	dc.l	0,end_song

;$$$$$$$$$$$$$$$$$$$$$$$$

jaltr2
	dc.w	rest,cr*8
	dc.w	end_patt


jaltr1
	dc.w	rest,cr*8
	dc.w	end_patt

final1
	dc.w	eb02,tq,gb02,tq,bb02,tq,ab02,tq
	dc.w	bb02,tq,db03,tq,bb02,tq,gb02,tq
	dc.w	ab02,tq,gb02,tq,eb02,tq,f02,tq
	dc.w	db02,cr*4
	dc.w	end_patt
final1_hits
	dc.w	eb03,cr,ab03,cr
	dc.w	bb02,cr
	dc.w	gb03,cr
	dc.w	db03,cr*4
	dc.w	end_patt
final1o
	dc.w	eb01,tq,gb01,tq,bb01,tq,ab01,tq
	dc.w	bb01,tq,db01,tq,bb01,tq,gb01,tq
	dc.w	ab01,tq,gb02,tq,eb01,tq,f01,tq
	dc.w	db01,cr*4
	dc.w	end_patt

final_snare
	dc.w	r16,tq,r16,tq,r16,tq,r16,tq
	dc.w	r16,tq,r16,tq,r16,tq,r16,tq
	dc.w	r16,tq,r16,tq,r16,tq,r16,tq
	dc.w	r16,cr*4
	dc.w	end_patt






end1
	dc.w	bb02,tq,bb02,tq,bb02,tq,a02,cr*3
	dc.w	bb02,tq,bb02,tq,bb02,tq,a02,cr*3
	dc.w	db03,tq,db03,tq,db03,tq,c03,cr*3
	dc.w	db03,tq,db03,tq,db03,tq,c03,cr*3
	dc.w	eb03,tq,eb03,tq,eb03,tq,d03,cr*3
	dc.w	eb03,tq,eb03,tq,eb03,tq,d03,cr*3
	dc.w 	f03,tq,f03,tq,f03,tq
	dc.w	eb03,tq,eb03,tq,eb03,tq
	dc.w 	f03,tq,f03,tq,f03,tq
	dc.w	eb03,tq,eb03,tq,eb03,tq

	dc.w 	f03,tq,f03,tq,f03,tq,gb03,cr*2
	dc.w 	gb03,tq,gb03,tq,gb03,tq,ab03,cr
	dc.w	ab03,tq,ab03,tq,ab03,tq,ab03,cr
	dc.w	ab03,tq,ab03,tq,ab03,tq
	dc.w	end_patt


end2
	dc.w	f02,tq,f02,tq,f02,tq,f02,cr*3
	dc.w	f02,tq,f02,tq,f02,tq,f02,cr*3
	dc.w	ab02,tq,ab02,tq,ab02,tq,ab02,cr*3
	dc.w	ab02,tq,ab02,tq,ab02,tq,ab02,cr*3
	dc.w	bb02,tq,bb02,tq,bb02,tq,bb02,cr*3
	dc.w	bb02,tq,bb02,tq,bb02,tq,bb02,cr*3
	dc.w 	bb02,tq,bb02,tq,bb02,tq
	dc.w 	bb02,tq,bb02,tq,bb02,tq
	dc.w 	bb02,tq,bb02,tq,bb02,tq
	dc.w 	bb02,tq,bb02,tq,bb02,tq

	dc.w 	db03,tq,db03,tq,db03,tq,db03,cr*2
	dc.w 	db03,tq,db03,tq,db03,tq,db03,cr
	dc.w	db03,tq,db03,tq,db03,tq,db03,cr
	dc.w	db03,tq,db03,tq,db03,tq
	dc.w	end_patt

end3
	dc.w	f02,cr,f02,cr,f02,cr,f02,cr
	dc.w	f02,cr,f02,cr,f02,cr,f02,cr
	dc.w	gb02,cr,gb02,cr,gb02,cr,gb02,cr
	dc.w	gb02,cr,gb02,cr,gb02,cr,gb02,cr
	dc.w	g02,cr,g02,cr,g02,cr,g02,cr
	dc.w	g02,cr,g02,cr,g02,cr,g02,cr
	dc.w	ab02,cr,ab02,cr,ab02,cr
	dc.w	ab02,cr,ab02,cr,gb02,cr*2
	dc.w	end_patt
end3_ext
	dc.w	gb02,tq,gb02,tq,gb02,tq
	dc.w	gb02,cr,gb02,tq,gb02,tq,gb02,tq
	dc.w	gb02,cr,gb02,tq,gb02,tq,gb02,tq
	dc.w	end_patt


snare_end
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr

	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr

	dc.w	end_patt

end4
	dc.w	ab03,cr,gb03,cr*3
	dc.w	rest,cr*4

	dc.w	end_patt






ja_mid_bass
	dc.w	e02,cr*2,e01,cr*4
	dc.w	b01,cr*2
	dc.w	f02,cr*2,f01,cr*4
	dc.w	c02,cr*2
	dc.w	bb02,cr*2,bb01,cr*4
	dc.w	bb02,cr*2
	dc.w	c02,cr*2,c03,cr*2
	dc.w	e03,cr,d03,cr,c03,cr,bb02,cr
	dc.w	e02,cr*2,e01,cr*4
	dc.w	b01,cr*2
	dc.w	f02,cr*2,f01,cr*4
	dc.w	c02,cr*2
	dc.w	bb02,cr*2,bb01,cr*4
	dc.w	bb02,cr*2
	dc.w	c02,cr*2,c03,cr*2

	dc.w	end_patt




mid_acc1
	dc.w	e03,cr-tq,e03,tq,c03,tq,a02,tq,c03,tq
	dc.w	e03,tq,c03,tq,a02,tq
	dc.w	e03,tq,c03,tq,a02,tq

	dc.w	e03,cr-tq,e03,tq,c03,tq,a02,tq,c03,tq
	dc.w	e03,tq,c03,tq,a02,tq
	dc.w	e03,tq,c03,tq,a02,tq


	dc.w	f03,cr-tq,f03,tq,d03,tq,c03,tq,a02,tq
	dc.w	d03,tq,c03,tq,a02,tq
	dc.w	d03,tq,c03,tq,a02,tq

	dc.w	f03,cr-tq,f03,tq,d03,tq,c03,tq,a02,tq
	dc.w	d03,tq,c03,tq,a02,tq
	dc.w	d03,tq,c03,tq,a02,tq


	dc.w	bb02,cr-tq,bb02,tq,bb02,tq,g02,tq,f02,tq
	dc.w	bb02,tq,g02,tq,f02,tq
	dc.w	bb02,tq,g02,tq,f02,tq

	dc.w	bb02,cr-tq,bb02,tq,d03,tq,d02,tq,f02,tq
	dc.w	bb02,tq,bb02,tq,d02,tq
	dc.w	f03,tq,f03,tq,bb02,tq


	dc.w	c03,cr-tq,c03,tq,e03,tq,c03,tq,g03,tq
	dc.w	e03,tq,c03,tq,g02,tq
	dc.w	e03,tq,c03,tq,g02,tq
	dc.w	end_patt

mid_acc1_ext
	dc.w	c03,cr-tq,c03,tq,e03,tq,c03,tq,g03,tq
	dc.w	e03,tq,c03,tq,g02,tq
	dc.w	e03,tq,c03,tq,g02,tq

	dc.w	end_patt

mid_flute
	dc.w	a02,tq,c03,tq,e03,tq
	dc.w	d03,tq,e03,tq,g03,tq
	dc.w	a02,tq,c03,tq,e03,tq
	dc.w	d03,tq,e03,tq,g03,tq
mid_flute_ext
	dc.w	a02,tq,c03,tq,e03,tq
	dc.w	d03,tq,e03,tq,g03,tq
	dc.w	a02,tq,c03,tq,e03,tq
	dc.w	d03,tq,e03,tq,g03,tq
	dc.w	end_patt
	

trip_start
	dc.w	a02,tq,c03,tq,e03,tq
	dc.w	d03,tq,e03,tq,g03,tq
	dc.w	a02,tq,c03,tq,e03,tq
	dc.w	d03,tq,e03,tq,g03,tq

	dc.w	a02,tq,c03,tq,e03,tq
	dc.w	d03,tq,e03,tq,g03,tq
	dc.w	a02,tq,c03,tq,e03,tq
	dc.w	d03,tq,e03,tq,g03,tq
	dc.w	end_patt

ja_flute1_trill
	dc.w	rest,cr*7*4
	dc.w	rest,cr,g02,q,d03,2,f03,2,g03,2,a03,30
	dc.w	rest,cr
	dc.w	end_patt

ja_gstrings1
	dc.w	d02,cr,d02,cr,d02,cr,d02,q,g02,q
	dc.w	end_patt

ja_gstrings2
	dc.w	g02,cr,g02,cr,g02,cr,g02,q,g02,q
	dc.w	end_patt

ja_gstrings3
	dc.w	b02,cr,b02,cr,b02,cr,b02,q,d03,q
	dc.w	end_patt



intro_tune1
	dc.w	a02,tq,c03,tq,e03,tq
	dc.w	d03,tq,e03,tq,g03,tq+cr*2
	dc.w	end_patt

brass_intro
	dc.w	a03,tq,a03,tq,a03,tq,g03,tq,g03,tq,g03,tq,a03,tq,a03,tq
	dc.w	a03,tq,g03,cr
	dc.w	end_patt



ja_stab_intro
	dc.w	a03,tq,a03,tq,a03,tq,g03,cr*3
	dc.w	rest,cr*4
	dc.w	g03,tq,g03,tq,g03,tq,f03,cr*3
	dc.w	rest,cr*4
	dc.w	a03,tq,a03,tq,a03,tq,g03,cr*3
	dc.w	rest,cr*4
	dc.w	g03,tq,g03,tq,g03,tq,f03,cr*3
	dc.w	rest,cr*4
	dc.w	end_patt

ja_stab_introo
	dc.w	bb01,tq,bb01,tq,bb01,tq,bb01,cr*3
	dc.w	rest,cr*4
	dc.w	f01,tq,f01,tq,f01,tq,f01,cr*3
	dc.w	rest,cr*4
	dc.w	bb01,tq,bb01,tq,bb01,tq,bb01,cr*3
	dc.w	rest,cr*4
	dc.w	f01,tq,f01,tq,f01,tq,f01,cr*3
	dc.w	rest,cr*4
	dc.w	end_patt
;&&&&&&&&&
string_run4
	dc.w	b02,tq,db02,tq,eb02,tq,e02,tq,gb02,tq,ab02,tq
	dc.w	gb02,cr,f02,cr
	dc.w	end_patt
four_stabs
	dc.w	b02,cr,e03,cr,d03,cr,g02,cr
	dc.w	end_patt
four_stabso
	dc.w	b01,cr,e01,cr,d02,cr,g01,cr
	dc.w	end_patt

snare_roll4
	dc.w	r16,tq,r16,tq,r16,tq,r16,tq,r16,tq,r16,tq
	dc.w	r16,cr,r16,cr
	dc.w	end_patt

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main_tune1
	dc.w	a02,tq,c03,tq,e03,tq,d03,tq,e03,tq,g03,tq
	dc.w	a03,tq,d03,tq,e03,tq,c03,tq,a02,tq,b02,tq
	dc.w	a02,tq,f02,tq,g02,tq,e02,tq,c02,tq,d02,tq
	dc.w	b01,cr*2
	dc.w	f02,cr,a02,cr,c03,cr,d03,tq,c03,tq,d03,tq
	dc.w	f03,cr,g03,tq,f03,tq,g03,tq,ab03,cr*2
	dc.w	end_patt

main_tune2
	dc.w	a03,tq,a03,tq,a03,tq
	dc.w	g03,tq,g03,tq,g03,tq
	dc.w	a03,tq,a03,tq,a03,tq
	dc.w	g03,tq,g03,tq,g03,tq
	dc.w	a03,tq,a03,tq,a03,tq
	dc.w	g03,tq,g03,tq,g03,tq
	dc.w	f03,cr*2
	dc.w	end_patt

main_tune3
	dc.w	a03,tq,a03,tq,a03,tq,g03,cr
	dc.w	g03,tq,g03,tq,g03,tq,f03,cr
	dc.w	end_patt

main_tune4
	dc.w	b02,tq,b02,4,b02,4,b02,tq,db03,tq,b02,tq,eb03,tq
	dc.w	e03,cr*2
	dc.w	end_patt

main_tune_stab
	dc.w	a03,cr
	dc.w	end_patt
main_tune_stabo
	dc.w	a01,cr
	dc.w	end_patt

main_tune_acc1
	dc.w	e03,tq,a02,tq,e02,tq,c03,tq,e03,tq,e02,tq
	dc.w	e03,tq,c03,tq,e02,tq,c03,tq,e03,tq,e02,tq
	dc.w	c03,cr,g02,cr,b02,cr*2			
	dc.w	end_patt

main_tune_acc2
	dc.w	a02,tq,c03,tq,rest,tq
	dc.w	a02,tq,a02,tq,rest,tq,a02,tq,c03,tq,rest,tq
	dc.w	a02,cr,e02,cr,ab02,cr*2			
	dc.w	end_patt

main_tune_acc3
	dc.w	rest,tq,a02,tq,rest,tq*5,a02,tq,rest,tq
	dc.w	f02,cr,c02,cr,e02,cr*2
	dc.w	end_patt

main_tune_bass_run1
	dc.w	f01,cr,a01,cr,bb01,cr,c02,cr
	dc.w	d02,cr,f02,cr,ab02,cr*2
	dc.w	end_patt



main_tune_acc4
	dc.w	a02,tq,g02,tq,f02,tq
	dc.w	a02,tq,g02,tq,f02,tq
	dc.w	a02,tq,g02,tq,f02,tq
	dc.w	a02,tq,g02,tq,f02,tq
	dc.w	bb02,tq,g02,tq,f02,tq
	dc.w	bb02,tq,g02,tq,f02,tq
	dc.w	b02,tq,a02,tq,ab02,tq
	dc.w	b02,tq,a02,tq,ab02,tq
	dc.w	end_patt

main_tune_acc5a
	dc.w	c03,cr,b02,cr,c03,cr,b02,cr	
	dc.w	c03,cr,b02,cr,a02,cr*2
	dc.w	end_patt

main_tune_acc5b
	dc.w	a02,cr,g02,cr,a02,cr,g02,cr	
	dc.w	a02,cr,g02,cr,f02,cr*2
	dc.w	end_patt

main_tune_acc5c
	dc.w	e02,cr,e02,cr,e02,cr,e02,cr	
	dc.w	e02,cr,e02,cr,c02,cr*2
	dc.w	end_patt

main_tune_end_stabs
	dc.w	a03,tq,a03,tq,a03,tq,g03,cr
	dc.w	g03,tq,g03,tq,g03,tq,f03,cr
	dc.w	rest,cr*4

	dc.w	end_patt

jacrash
	dc.w	r2,cr*4
	dc.w	end_patt



main_tune_end_stabs_bass
	dc.w	bb01,tq,bb01,tq,bb01,tq,bb01,cr
	dc.w	f01,tq,f01,tq,f01,tq,f01,cr

	dc.w	gb01,cr,b01,cr,e02,cr*2
	dc.w	end_patt

main_tune_end_stabs_bass_long
	dc.w	bb01,tq,bb01,tq,bb01,tq,bb01,cr
	dc.w	f01,tq,f01,tq,f01,tq,f01,cr

	dc.w	gb01,cr,b01,cr,e02,cr*2
	dc.w	end_patt




main_tune_end_snare
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr
	dc.w	r16,tq,r16,tq,r16,tq,r16,cr

	dc.w	r16,tq,r16,4,r16,4,r16,tq,r16,tq,r16,tq,r16,tq
	dc.w	r16,cr*2
	dc.w	end_patt

	dc.w	end_patt

moving_bass
	dc.w	a02,cr,e02,cr,g02,cr,d02,cr
	dc.w	f02,cr,c02,cr,e02,cr*2
	dc.w	f01,cr,a01,cr,bb01,cr,c02,cr
	dc.w	d02,cr,f02,cr,ab02,cr*2
	dc.w	e02,cr,g02,cr,a02,cr,g02,cr
	dc.w	a02,cr,g02,cr,f02,cr*2
	dc.w	end_patt

verse_snare
	dc.w	r16,tq,r16,tq,r16,tq	
	dc.w	r16,tq,r16,tq,r16,4,r16,4	
	dc.w	r16,tq,r16,tq,r16,tq	
	dc.w	r16,tq,r16,4,r16,4,r16,tq	
	dc.w	r16,tq,r16,tq,r16,tq	
	dc.w	r16,tq,r16,tq,r16,tq	
	dc.w	r16,tq,r16,tq,r16,tq	
	dc.w	r16,tq,r16,tq,r16,4,r16,4
	
	dc.w	end_patt
middle_tune
	dc.w 	modon,2,2,2,2,6,6
	dc.w	e02,cr*4+cr+cr+cr,g02,cr
	dc.w	f02,cr*6,g02,cr,a02,cr
	dc.w	bb02,cr*6,d03,cr*2
	dc.w	c03,cr*4
	dc.w	e03,cr,d03,cr,c03,cr,bb02,cr

	dc.w	e02,cr*4+cr+cr+cr,g02,cr
	dc.w	f02,cr*6,g02,cr,a02,cr
	dc.w	bb02,cr*6,d03,cr*2
	dc.w	c03,cr*4
	dc.w	modoff

	dc.w	end_patt

;**************************************


cr  set   16
q set  cr/2
sq set q/2

tcr1 set 13
tcr2 set 14
tq set	  8
tsq1 set 3
tsq2 set 4



bds1
	dc.l	string_sound_loud
	dc.l	bdtune1
;bds1	

	dc.l	flute_sound			;pizpiano_sound
	dc.l	bdmid_tune1
	dc.l	bdmid_tune2
	dc.l	bdmid_tune3
	dc.l	pizpiano_sound
	dc.l	bdlink_trill
;bds1
	dc.l	trumpet_sound
	dc.l	bdtune2
	dc.l	bdtune2_ext
	dc.l	pizpiano
	dc.l	bdtune2
	dc.l	end_note_tune
	dc.l	pri
	dc.l	0,end_song

bds2
	dc.l	pizpiano_sound_quiet		;string_sound_loud

	;dc.l	string_sound_loud
	dc.l	bd_acc1
	dc.l	pizpiano_sound
	dc.l	bd_acc1_ext
;bds2
	;dc.l	string_sound
	dc.l	pizpiano_sound_quiet

	dc.l	bdmid_tune_acc1
	dc.l	ex1
	dc.l	ex2
	dc.l	trumpet_sound
	dc.l	bdlink1


;bds2
	dc.l	bass_sound
	dc.l	bdbass2
	dc.l	bdbass2_ext
	dc.l	bdbass2
	dc.l	end_note_bass
	dc.l	pri
	dc.l	0,end_song

bds3



	dc.l	pizpiano_sound_quiet		;string_sound_loud
	dc.l	bd_acc2
	dc.l	pizpiano_sound
	dc.l	bd_acc2_ext
	dc.l	orch_hit_sound
	dc.l	bdverse_end_stab
;bds3
	dc.l	pizpiano_sound_quiet
	;dc.l	string_sound
	dc.l	bdmid_tune_acc2
	dc.l	trumpet_sound
	dc.l	bdlink2

;bds3	
	;dc.l	bdr1c
	dc.l	flute_sound
	dc.l	bdflute
	dc.l	histrg_sound
	dc.l	bdflute_ext
	dc.l	orch_hit_soundq
	dc.l	bdfluteo
	dc.l	end_note_stab
	dc.l	pri
	dc.l	0,end_song

bds4
	dc.l	trumpet_sound
	dc.l	bdverse_bass
	dc.l	flute_sound
	dc.l	flute_run
;bds4
	dc.l	pizpiano_sound_quiet				;string_sound
	dc.l	bdmid_tune_acc3
	dc.l	bdlink_rest

	dc.l	flute_sound
	dc.l	bdlink_trill



;bds4
	dc.l	orch_hit_soundq
	dc.l	bdstabs_tune2

	dc.l	pizpiano_sound
	dc.l	bdtune2_ext


	dc.l	snare_sound
	dc.l	bdsnare
	dc.l	end_note_snare

	dc.l pri_new_tune

	dc.l	0,end_song


bdr1
	dc.w	rest,cr*4
	dc.w	end_patt


bdr1c
	dc.w	rest,cr
	dc.w	end_patt

end_note_stab
	dc.w	d03,cr*3
	dc.w	end_patt

end_note_bass
	dc.w	d01,cr*3
	dc.w	end_patt

end_note_snare
	dc.w	r16,cr*3
	dc.w	end_patt

end_note_tune
	dc.w	rest,cr,d02,cr*3
	dc.w	end_patt


bdlink_rest
	dc.w	rest,cr*6
	dc.w	end_patt

bdflute
	dc.w	rest,cr,gb02,q,g02,q,a02,cr
	dc.w	rest,cr,gb02,q,g02,q,a02,cr
	dc.w	rest,cr,gb02,q,g02,q,a02,cr,a02,cr*3

	dc.w	rest,cr,gb02,q,g02,q,a02,cr
	dc.w	rest,cr,gb02,q,g02,q,a02,cr
	dc.w	rest,cr,gb02,q,g02,q,a02,cr,a02,cr*3

	dc.w	rest,cr,gb02,q,g02,q,a02,cr
	dc.w	rest,cr,gb02,q,g02,q,a02,cr
	dc.w	rest,cr,gb02,q,g02,q,a02,cr,a02,cr*3


	dc.w	d03,cr,e03,cr,gb03,cr,a03,cr*2,g03,cr
	dc.w	gb03,q,gb03,q,gb03,cr,e03,cr,d03,cr*3
	dc.w	end_patt

bdfluteo
	dc.w	rest,cr,gb03,q,g03,q,a03,cr
	dc.w	rest,cr,gb03,q,g03,q,a03,cr
	dc.w	rest,cr,gb03,q,g03,q,a03,cr,a03,cr*3

	dc.w	rest,cr,gb03,q,g03,q,a03,cr
	dc.w	rest,cr,gb03,q,g03,q,a03,cr
	dc.w	rest,cr,gb03,q,g03,q,a03,cr,a03,cr*3

	dc.w	rest,cr,gb03,q,g03,q,a03,cr
	dc.w	rest,cr,gb03,q,g03,q,a03,cr
	dc.w	rest,cr,gb03,q,g03,q,a03,cr,a03,cr*3


	dc.w	d03,cr,e03,cr,gb03,cr,a03,cr*2,g03,cr
	dc.w	gb03,q,gb03,q,gb03,cr,e03,cr,d03,cr*3
	dc.w	end_patt



bdflute_ext

	dc.w	d03,q,f02,q,bb02,q,d03,q,f02,q,bb02,q
	dc.w	d03,q,f02,q,bb02,q,d03,q,f02,q,bb02,q

	dc.w	eb03,q,g02,q,bb02,q,eb03,q,g02,q,bb02,q
	dc.w	eb03,q,g02,q,bb02,q,eb03,q,g02,q,bb02,q

	dc.w	f02,q,c03,q,f02,q,a02,q,f02,q,a02,q
	dc.w	c03,q,f02,q,a02,q,c03,q,f02,q,a02,q

	dc.w	d03,q,g02,q,bb02,q,f02,q,bb02,q,f02,q
	dc.w	d03,q,g02,q,bb02,q,f02,q,a02,q,f02,q

	dc.w	c03,q,f02,q,bb02,q,f02,q,d03,q,f02,q
	dc.w	bb02,q,f02,q,d03,q,f02,q,bb02,q,f02,q

	dc.w	g02,q,bb02,q,eb03,q,g02,q,bb02,q,g02,q
	dc.w	e03,q,g02,q,bb02,q,g02,q,e03,q,g02,q

	dc.w	a02,q,d03,q,gb03,q,a02,q,d03,q,f03,q
	dc.w	a02,q,d03,q,gb03,q,a02,q,d03,q,f03,q

	dc.w	d02,cr,d02,cr,d02,cr
	dc.w	d02,cr,d02,cr,d02,cr
	dc.w	end_patt

bdstabs_tune2

	dc.w	e03,cr
	dc.w	a03,cr,rest,cr*2,e03,cr,rest,cr*2
	dc.w	a03,cr,rest,cr*2,e03,cr,rest,cr*2
	dc.w	d03,cr,rest,cr*2,d03,cr,rest,cr*2
	dc.w	d03,cr,rest,cr*2,d03,cr
	dc.w	e03,cr,a03,cr
	dc.w	a03,cr,rest,cr*2,e03,cr,rest,cr*2,a03,cr,rest,cr*2,e03,cr,rest,cr*2
	dc.w	d03,cr,e03,cr,gb03,cr,rest,cr*2,g03,cr
	dc.w	rest,cr*2,d03,cr,a03,cr,d03,cr

	dc.w	end_patt

bdsnare
	dc.w	rest,cr*2
	dc.w	r16,q,r16,q,r16,cr

	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,cr

	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,q
	dc.w	r16,q,r16,cr*3

	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,cr

	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,cr

	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,q
	dc.w	r16,q,r16,cr*3



	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,cr

	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,cr

	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,q
	dc.w	r16,q,r16,cr*3


	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,cr

	dc.w	rest,cr
	dc.w	r16,q,r16,q,r16,cr

	dc.w	r16,cr

	dc.w	end_patt


bdtune2
	dc.w	a02,cr,g02,cr*2,a02,cr,g02,cr*2,a02,cr
	dc.w	gb03,cr*4
	dc.w	e03,cr,a02,cr,gb02,cr*2,a02,cr,gb02,cr*2
	dc.w	a02,cr,e03,cr*4,d03,cr
	dc.w	a02,cr,g02,cr*2,a02,cr,g02,cr*2,a02,cr
	dc.w	gb03,cr*4
	dc.w	e03,cr,a02,cr,d03,cr,e03,cr,gb03,cr,a03,cr*2,g03,cr
	dc.w	gb03,q,gb03,q,gb03,cr,e03,cr,d03,cr*2
	dc.w	end_patt
bdtune2_ext
	dc.w	d03,cr,d03,cr*4,eb03,cr,d03,cr
	dc.w	c03,cr,bb02,cr,a02,cr,g02,cr,rest,cr*2
	dc.w	c03,cr*2,c03,cr*2,g02,cr+q,f02,q,f02,cr*2
	dc.w	f03,cr,eb03,cr,d03,cr,c03,cr

	dc.w	d03,cr*2,d03,cr*2,eb03,cr,d03,cr
	dc.w	c03,cr,bb02,cr,a02,cr,g02,cr*3

	dc.w	gb02,cr*2,gb02,cr,rest,cr,g02,cr+q,bb02,q
	dc.w	a02,cr*5

	dc.w	end_patt

bdbass2 
	dc.w	e02,cr*3,a01,cr*3
	dc.w	a02,cr,b02,cr,db03,cr,e03,cr*3
	dc.w	d02,cr*3,a01,cr*3
	dc.w	a02,cr,d03,cr,gb03,cr,a03,cr*3
	dc.w	e02,cr*3,a01,cr*3
	dc.w	e02,cr,gb02,cr,a02,cr,db03,cr*3
	dc.w	d02,cr*3,a02,cr*3,a02,cr*3,d03,cr*3

	dc.w	end_patt

bdbass2_ext 
	dc.w	bb02,cr*3,bb02,cr*3
	dc.w	eb02,cr*3,eb02,cr*3
	dc.w	a03,cr*3,f03,cr*3
	dc.w	bb02,cr*3,f03,cr*3
	dc.w	bb02,cr*3,bb02,cr*3
	dc.w	eb02,cr*3,e02,cr*3
	dc.w	d02,cr*3,d02,cr*3,d02,cr*6
	dc.w	end_patt





	dc.w	end_patt




bdlink_trill
	dc.w	a02,sq,b02,sq,a02,sq,b02,sq
	dc.w	a02,sq,b02,sq,a02,sq,b02,sq
	dc.w	a02,sq,b02,sq,a02,sq,b02,sq

	dc.w	a02,sq,b02,sq,a02,sq,b02,sq
	dc.w	a02,sq,b02,sq,a02,sq,b02,sq
	dc.w	a02,sq,b02,sq,a02,sq,b02,sq

	dc.w	a02,sq,b02,sq,a02,sq,b02,sq
	dc.w	a02,sq,b02,sq,a02,sq,b02,sq
	dc.w	a02,sq,b02,sq,a02,sq,b02,sq

	dc.w	a02,cr*2
	dc.w	end_patt




bdlink1
	dc.w	rest,cr*6
	dc.w	e02,cr*3,g02,cr*3
	dc.w	e02,cr*3,g02,cr*3
	dc.w	end_patt

bdlink2
	dc.w	rest,cr*7
	dc.w	a02,cr*3,e02,cr*3
	dc.w	a02,cr*3,e02,cr*3
	dc.w	end_patt









bdtune1
;	dc.w modon,1,1,2,2,6,6
	dc.w	d02,cr,gb02,cr,a02,cr
	dc.w	a02,cr*8

	dc.w	d02,cr,d02,cr,gb02,cr,a02,cr
	dc.w	a02,cr*8

	dc.w	db02,cr,db02,cr,e02,cr,b02,cr
	dc.w	b02,cr*8

	dc.w	db02,cr,db02,cr,e02,cr,b02,cr
	dc.w	b02,cr*8


	dc.w	d02,cr,d02,cr,gb02,cr,a02,cr
	dc.w	d03,cr*8


	dc.w	d02,cr,d02,cr,gb02,cr,a02,cr
	dc.w	d03,cr*8

	dc.w	e02,cr,e02,cr,g02,cr,b02,cr
	dc.w	b02,cr*4
	dc.w	ab02,cr,a02,cr,gb03,cr*4
	dc.w	d03,cr,gb02,cr,gb02,cr*2
	dc.w	e02,cr,b02,cr*2,a02,cr
	dc.w	d02,cr+q,d02,q,d02,cr,d02,cr

	dc.w	end_patt

bdmid_tune1
	dc.w	d02,cr,db02,cr,db02,cr,b01,cr,b01,cr
	dc.w	rest,cr,b01,cr,bb01,cr,bb01,cr,b01,cr,b01,cr
	dc.w	end_patt

bdmid_tune2
	dc.w	rest,cr,e02,cr,e02,cr,gb02,cr*2,e02,cr,rest,cr
	dc.w	e02,cr,e02,cr,b02,cr*2,a02,cr,rest,cr
	dc.w	end_patt
bdmid_tune3
	dc.w	d02,cr,db02,cr,db02,cr,b01,cr,b01,cr
	dc.w	rest,cr,b01,cr,db02,cr,e02,cr,d02,cr,d02,cr

	dc.w	rest,cr,ab02,cr,b02,cr,b02,cr*2,a02,cr
	dc.w	ab02,cr+q,gb02,q,d02,q,b01,q

	dc.w	gb02,q,gb02,q,gb02,cr,e02,cr

	dc.w	a01,cr*3	

	dc.w	end_patt

bdmid_tune_acc1
	;dc.w	rest,cr*2
	dc.w	e02,cr,ab02,cr,ab02,cr
	dc.w	e02,cr,ab02,cr,g02,cr
	dc.w	e02,cr,ab02,cr,ab02,cr
	dc.w	e02,cr,ab02,cr,ab02,cr
	dc.w	end_patt
ex1
	dc.w	e02,cr*3,gb02,cr*3,g02,cr*3,gb02,cr*3
	dc.w	end_patt
ex2
	dc.w	e02,cr,ab02,cr,ab02,cr
	dc.w	e02,cr,ab02,cr,g02,cr
	dc.w	e02,cr,ab02,cr,ab02,cr
	dc.w	e02,cr,b02,cr,b02,cr
	dc.w	gb02,cr*2,a02,cr,d02,cr*3
	dc.w	end_patt

bdmid_tune_acc2
	;dc.w	rest,cr*2
	dc.w	rest,cr,d03,cr,d03,cr
	dc.w	rest,cr,d03,cr,db03,cr
	dc.w	rest,cr,d03,cr,d03,cr
	dc.w	rest,cr,d03,cr,d03,cr

	dc.w	rest,cr,db03,cr,db03,cr
	dc.w	rest,cr,db03,cr,db03,cr
	dc.w	rest,cr,db03,cr,db03,cr
	dc.w	rest,cr,db03,cr,db03,cr

	dc.w	rest,cr,d03,cr,d03,cr
	dc.w	rest,cr,d03,cr,db03,cr
	dc.w	rest,cr,d03,cr,d03,cr
	dc.w	rest,cr,d03,cr,d03,cr

	dc.w	b02,cr*2,rest,cr,gb02,cr*3
	dc.w	end_patt

bdmid_tune_acc3
	;dc.w	rest,cr*2
	dc.w	rest,cr,e03,cr,e03,cr
	dc.w	rest,cr,e03,cr,e03,cr
	dc.w	rest,cr,e03,cr,e03,cr
	dc.w	rest,cr,e03,cr,e03,cr

	dc.w	rest,cr,e03,cr,e03,cr
	dc.w	rest,cr,e03,cr,e03,cr
	dc.w	rest,cr,e03,cr,e03,cr
	dc.w	rest,cr,e03,cr,e03,cr

	dc.w	rest,cr,e03,cr,e03,cr
	dc.w	rest,cr,e03,cr,e03,cr
	dc.w	rest,cr,e03,cr,e03,cr
	dc.w	rest,cr,e03,cr,rest,cr

	dc.w	db03,cr*2,rest,cr,b02,cr*3
	dc.w	end_patt





bd_acc1
	dc.w	rest,cr*5
	dc.w	a02,cr,a02,cr*2,gb02,cr
	dc.w	gb02,cr*2

	dc.w	rest,cr*6
	dc.w	a02,cr,a02,cr*2,g02,cr
	dc.w	g02,cr*2

	dc.w	rest,cr*6
	dc.w	b02,cr,b02,cr*2,g02,cr,g02,cr*2

	dc.w	rest,cr*6
	dc.w	b02,cr,b02,cr*2,gb02,cr,gb02,cr*2


	dc.w	rest,cr*6
	dc.w	d03,cr,d03,cr*2,a02,cr
	dc.w	a02,cr*2


	dc.w	rest,cr*6
	dc.w	d03,cr,d03,cr*2,b02,cr
	dc.w	b02,cr*2
	dc.w	end_patt

bd_acc1_ext

		;end bit
	dc.w	e02,cr,e02,cr,g02,cr,b02,cr
	dc.w	e02,cr,a02,cr,a02,cr
	dc.w	a01,cr,a02,cr,a02,cr
	dc.w	d02,cr,a02,cr,a02,cr
	dc.w	gb02,cr,a02,cr,a02,cr
	dc.w	b02,cr*3,e02,cr*3
	dc.w	d02,cr*6

	dc.w	end_patt


bd_acc2
	dc.w	rest,cr*5
	dc.w	gb02,cr,gb02,cr*2,d02,cr
	dc.w	d02,cr*2

	dc.w	rest,cr*6
	dc.w	g02,cr,g02,cr*2,db02,cr
	dc.w	db02,cr*2

	dc.w	rest,cr*6
	dc.w	g02,cr,g02,cr*2,db02,cr,db02,cr*2

	dc.w	rest,cr*6
	dc.w	d02,cr,d02,cr*2,d02,cr,d02,cr*2


	dc.w	rest,cr*6
	dc.w	a03,cr,a03,cr*2,gb02,cr
	dc.w	gb02,cr*2


	dc.w	rest,cr*6
	dc.w	b02,cr,b02,cr*2,b01,cr
	dc.w	b01,cr*2
	dc.w	end_patt

bd_acc2_ext

	;end bit
	dc.w	rest,cr*4
	dc.w	rest,cr,db02,cr,db02,cr
	dc.w	rest,cr,db02,cr,db02,cr
	dc.w	rest,cr,d02,cr,d02,cr
	dc.w	rest,cr,d02,cr,d02,cr
	dc.w	d02,cr*3,g02,cr*5
	dc.w	end_patt
bdverse_end_stab
	dc.w	a02,cr,d03,cr*2
	dc.w	end_patt



bdverse_bass

	dc.w modon,1,1,4,4,6,6

	dc.w	rest,cr*3
	dc.w	d02,cr*3,db02,cr*3
	dc.w	b01,cr*3,a01,cr*6
	dc.w	g01,cr*3,gb01,cr*3
	dc.w	e01,cr*6,d01,cr*3
	dc.w	db01,cr*3,b01,cr*6
	dc.w	a01,cr*3,gb01,cr*3
	dc.w	d01,cr*6,d02,cr*3
	dc.w	c02,cr*6,g02,cr*6
	dc.w	rest,cr*6
	dc.w	a01,cr*2,a02,cr*4
	dc.w	d02,cr*6
	dc.w	g01,cr*3
	dc.w	a01,cr*3
	;dc.w	d02,cr,a01,cr,d01,cr,d01,cr
	;dc.w	rest,cr*2

	dc.w	end_patt

flute_run
	dc.w	d03,sq,db03,sq,c03,sq,b02,sq,bb02,sq
	dc.w	a02,sq,ab02,sq,g02,sq,gb02,sq,f02,sq,e02,sq
	dc.w	eb02,sq,d02,cr*2+q+sq+sq
	
	dc.w	end_patt



;**************************************


sinel
sinep
		dc.w 1  
    	 	dc.l sined
     		dc.w 16/2  
    	 	dc.l restd
     		dc.w 16/2

acbass1p
		dc.w 1  
    	 	dc.l acbass1d
     		dc.w 3478/2  
    	 	dc.l restd
     		dc.w 16/2

flute2p
		dc.w 1  
    	 	;dc.l flute2d
     		dc.w 4426/2  
    	 	dc.l restd
     		dc.w 16/2

newflutep
		dc.w 1  
    	 	dc.l newfluted
     		dc.w 3636/2  
    	 	dc.l restd
     		dc.w 16/2

newflutelp
		dc.w 1  
    	 	dc.l newfluted
     		dc.w 3636/2  
    	 	dc.l sined
     		dc.w 16/2

frehornp
		dc.w 1  
    	 	dc.l frehornd
     		dc.w 7020/2  
    	 	dc.l restd
     		dc.w 16/2

pizzo1p
		dc.w 1  
    	 	dc.l pizzo1d
     		dc.w 5550/2  
    	 	dc.l restd
     		dc.w 16/2

pizzo2p
		dc.w 1  
    	 	dc.l pizzo2d
     		dc.w 3796/2  
    	 	dc.l restd
     		dc.w 16/2

strings1p
		dc.w 1  
    	 	dc.l strings1d
     		dc.w 8448/2  
    	 	dc.l restd
     		dc.w 16/2

strings2p
		dc.w 1  
    	 	dc.l strings2d
     		dc.w 8668/2  
    	 	dc.l restd
     		dc.w 16/2

brasssecp
synbras1p
		dc.w 1  
    	 	dc.l brasssecd
     		dc.w 6360/2  
    	 	dc.l restd
     		dc.w 16/2

trumpet_loopp
		dc.w 1  
    	 	dc.l synbras1d
     		dc.w 3338/2  
    	 	dc.l synbras1d
     		dc.w 3338/2  


violin1p
		dc.w 1  
    	 	dc.l violin1d
     		dc.w 6350/2  
    	 	dc.l restd
     		dc.w 16/2

newtympp
		dc.w 1  
    	 	dc.l tymp1d
     		dc.w 5052/2  
    	 	dc.l restd
     		dc.w 16/2

orchhitpp
		dc.w 1  
    	 	dc.l orchhitpd
     		dc.w 10594/2  
    	 	dc.l restd
     		dc.w 16/2

pizpianop
		dc.w 1  
    	 	dc.l pizpianod
     		dc.w 4032/2  
    	 	dc.l restd
     		dc.w 16/2

histrgp
		dc.w 1  
    	 	dc.l histrgd
     		dc.w 2960/2  
    	 	dc.l restd
     		dc.w 16/2




snarep
		dc.w 1  
    	 	dc.l snared
     		dc.w 2240/2  
    	 	dc.l restd
     		dc.w 16/2



;****************************


;;;fx parameters

UNDERCp
		dc.w 1  
    	 	dc.l UNDERCd
     		dc.w 768/2  
    	 	dc.l restd
     		dc.w 16/2

alarmp
		dc.w 1  
    	 	dc.l alarmd
     		dc.w 586/2  
    	 	dc.l alarmd
     		dc.w 586/2  

engine3p	
		dc.w 1  
    	 	dc.l hissd
     		dc.w 2545/2  
    	 	dc.l hissd
     		dc.w 2545/2  

HISSp
		dc.w 1  
    	 	dc.l HISSd
     		dc.w 2545/2  
    	 	dc.l HISSd
     		dc.w 2545/2  

DOORCLOSp
		dc.w 1  
    	 	dc.l DOORCLOSd
     		dc.w 1386/2  
    	 	dc.l restd
     		dc.w 16/2


AIRLOCKp
		dc.w 1  
    	 	dc.l AIRLOCKd
     		dc.w 2800/2  
    	 	dc.l restd
     		dc.w 16/2

RUMBLEp
		dc.w 1  
    	 	dc.l RUMBLEd
     		dc.w 1440/2  
    	 	dc.l RUMBLEd
     		dc.w 1440/2  

BONGp
		dc.w 1  
    	 	dc.l BONGd
     		dc.w 1296/2  
    	 	dc.l restd
     		dc.w 16/2

LAZER2p
		dc.w 1  
    	 	dc.l LAZER2d
     		dc.w 1950/2  
    	 	dc.l restd
     		dc.w 16/2
LAZER1p
		dc.w 1  
    	 	dc.l LAZER1d
     		dc.w 2832/2  
    	 	dc.l restd
     		dc.w 16/2

ENGINE2p
		dc.w 1  
    	 	dc.l ENGINE2d
     		dc.w 2124/2  
    	 	dc.l ENGINE2d
     		dc.w 2124/2  

EXP1p
		dc.w 1  
    	 	dc.l EXP1d
     		dc.w 2440/2  
    	 	dc.l restd
     		dc.w 16/2

EXP1lp
		dc.w 1  
    	 	dc.l UNDERCd
     		dc.w 768/2  
    	 	dc.l UNDERCd
     		dc.w 768/2  




WHEELSp
		dc.w 1  
    	 	dc.l WHEELSd
     		dc.w 1808/2  
    	 	dc.l WHEELSd
     		dc.w 1808/2  


WINDp
		dc.w 1  
    	 	dc.l WINDd
     		dc.w 3272/2  
    	 	dc.l WINDd
     		dc.w 3272/2  


ENGINE1p
		dc.w 1  
    	 	dc.l ENGINE1d
     		dc.w 1764/2  
    	 	dc.l ENGINE1d
     		dc.w 1764/2  


expbigp
		dc.w 1  
    	 	dc.l expbigd
     		dc.w 6876/2  
    	 	dc.l restd
     		dc.w 16/2

hisslp
		dc.w 1  
    	 	dc.l hissld
     		dc.w 7182/2  
    	 	dc.l hissld
     		dc.w 7182/2

misslp
		dc.w 1  
    	 	dc.l missld
     		dc.w 6426/2  
    	 	dc.l restd
     		dc.w 16/2

hyperp
		dc.w 1  
    	 	dc.l hyperd
     		dc.w 7818/2  
    	 	dc.l restd
     		dc.w 16/2


;**************************************************

acbass1d		
histrgd			incbin ram:histrg.con
snared:			incbin ram:snare.con
frehornd		incbin ram:frehornl.con
pizzo1d			incbin ram:pizzo1.con
pizzo2d			incbin ram:pizzo2.con
strings1d		
strings2d		incbin ram:strings2.con
synbras1d		incbin ram:hbrass3l.con		;synbras1.con
brasssecd		incbin ram:brasssec.con		;synbras1.con
violin1d		incbin ram:violin1.con
tymp1d			incbin ram:newtymp.con
orchhitpd		incbin ram:orchhitp.con
pizpianod		incbin ram:pizpiano.con

newfluted		incbin ram:newflute.con


;********************************************

;;THE FX SAMPLES ARE PULLED IN HERE...THis section can be anywhere
;; in lower memory,and in any order

UNDERCd		;;;;;;;;;;;;;;;;;;;;;incbin ram:UNDERC.fon		
expbigd		incbin ram:expbig.fon
HISSd		incbin ram:HISS.fon		
DOORCLOSd	incbin ram:DOORCLOS.fon	
AIRLOCKd	incbin ram:AIRLOCK.fon	
RUMBLEd		incbin ram:RUMBLE.fon		
BONGd		incbin ram:BONG.fon		
LAZER2d		incbin ram:LAZER2.fon		
LAZER1d		incbin ram:LAZER1.fon		
ENGINE2d	incbin ram:ENGINE2.fon	
EXP1d		incbin ram:EXPLOSIO.fon		
WINDd		incbin ram:WIND.fon		
ENGINE1d	incbin ram:ENGINE1.fon	
WHEELSd		;;;;;;;;;;;;;;;;;;;;;incbin ram:WHEELS.fon
alarmd		incbin ram:alarm.fon

hissld		incbin ram:hissl.fon
missld		;incbin ram:missl.fon
hyperd		incbin ram:hyper.fon





;myfile                     empty rwed Today     22:38:40
;UNDERC.FON                   768 rwed Today     22:37:09
;HISS.FON                    1560 rwed Today     22:37:08
;DOORCLOS.FON                1386 rwed Today     22:37:07
;AIRLOCK.FON                 2800 rwed Today     22:37:06
;RUMBLE.FON                  1440 rwed Today     22:37:06
;BONG.FON                    1296 rwed Today     22:37:05
;LAZER2.FON                  1950 rwed Today     22:37:04
;LAZER1.FON                  2832 rwed Today     22:37:04
;ENGINE2.FON                 2124 rwed Today     22:37:03
;EXP1.FON                    2346 rwed Today     22:37:02
;WIND.FON                    3272 rwed Today     22:37:00
;ENGINE1.FON                 1764 rwed Today     22:37:00
;EXPLOSIO.CON                2440 rwed Today     22:36:38
;ALARM1.CON                   586 rwed Today     22:36:37
;WHEELS.CON                  1808 rwed Today     22:36:36
;HISS.CON                    2545 rwed Today     22:36:35
;17 files - 86 blocks used


;***********************
ev	equ 0			

rest_env:			dc.w 0,0,255



wholeorce:			dc.w 15,50,255
flute2e:			dc.w 15,28,255
flute2eq:			dc.w 0,15,255
flute2el:			dc.w 15,40,255
histrge:			dc.w 0,15,255
orchhite:			dc.w 15,50,255
orchhiteq:			dc.w 0,20,255

bassqe				dc.w 0,20,255

pizzo1e:			dc.w 15,50,255
basse:				dc.w 0,55,255
basseq:				dc.w 0,40,255
bassevq:			dc.w 0,40,255

snaree:				dc.w 0,50,255
snareeq:			dc.w 0,23,255
snareemid:			dc.w 0,33,255


pizzo1el:			dc.w 15,64,255

pizzo2e:			dc.w 15,50,255
pizzo2el:			dc.w 15,60,255

pizzo2eq:			dc.w 15,30,255

pizpianoe:			dc.w 15,50,255
pizpianoeq:			dc.w 0,10,255
pizpianoevrq:			dc.w 0,25,255
pizpianoevq:			dc.w 0,25,255

strings1e:			dc.w 15,30,255
strings1eq:			dc.w 15,25,255

strings1el:			dc.w 15,50,255
strings1eler:			dc.w 0,50,255

strings1ell:			dc.w 15,55,255

frehorne:			dc.w 15,35,255
synbras1e:			dc.w 0,25,255
synbras1e_s1:			dc.w 0,15,255

brasse:				dc.w 0,32,255
trumpete:			dc.w 0,45,255
trumpeteq:			dc.w 0,10,255

synbras1el:			dc.w 15,43,255

synbras1eq:			dc.w 15,23,255
acbass1e:			dc.w 15,30,255
violin1e:			dc.w 15,40,255
violin1el:			dc.w 0,60,255

violin1eq:			dc.w 15,30,255
tympe:				dc.w 15,35,255
tympel:				dc.w 15,45,255

orchhit2e:			dc.w 15,64,255
string_short_env	dc.w	0,35,35,35,30,28,25,23,20,10,6,3,0,255
string_pizz_env		dc.w	0,35,35,35,30,28,25,25,0,255

sine_env2:			dc.w 20,34-ev,33-ev,32-ev,5
			dc.w 39-ev,38-ev,37-ev,36-ev,35-ev,34-ev,33-ev,32-ev,4
			dc.w 19-ev,28-ev,37-ev,16-ev,25-ev,24-ev,27-ev,39-ev,28-ev
			dc.w 255
sine_env:			dc.w 0,50,255
sine_env_short:			dc.w 0,15,14,12,0,15,13,12,0,0,255
sine_env_slow:			dc.w 0,10,15,20,22,25,27,30,33,35,37,255

restd:
rest_data:
     		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
     		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
sined:
sine_datad:
     		dc.w 127,80,70,60,50,40,30,0,-25,-50,-100,-127
     		dc.w -127,-100,-50,-35,0,35,50,80,127






;*************************************************

	end



	;			dc.w modon,1,1,8,8,6,6
	;dc.w pbend,down,20,60000,1
	;dc.w	c01,cr*32









