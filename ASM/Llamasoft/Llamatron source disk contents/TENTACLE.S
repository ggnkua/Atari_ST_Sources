*Greetings Earthcreature: it's 2.30 am, I've been down the pub
*and had three pints, but I din't forget about yer tentacle.

*This is the first attempt at this kinda thing I ever done, it
*seems to do tenticular-type stuff. I have assembled it into the
*pause mode on Llamatron. When the wave starts press P to pause
*and the tentacle will appear. It consists of 32 sprites.

*Using the joystick, you can change the four main parameters
*governing the tentacle:

*NO button:

*Joy Left/Right = Change value of r_inc
* "  Up/Down = Change value of a_inc

*WITH button held down:

*Joy Left/Right = Change value of sine2_amp
*Joy Up/Down = Change value of sine2_add

*The parameters tent_ang and sine2_base are updated
*with constant additions every frame, to give swing and
*wiggle respectively.

*To resume your game of LLAMATRON, press O.


*The way it worx is quite simple really. Y'start with
*an initial X,Y and angle. You draw a sprite, then calc
*an offset based on a given angle and radius, add that to
*yer X and Y, then plot yer next sprite, even unto the end
*of the tentacle, verily it is written. Another value is
*added to the radius and angle per step, and a second sine
*wave is used to perturb the angle at each step: this makes
*the tentie wavy, and plase-shifting it (sine2-base) makes it
*squirm! Ain't sine waves groovy?

*Anyway, I've documented this source code, eyeball it and
*transfer algorithm to the slimeware. You could change the
*DIVS instruxions with ASR.L by 7, to gain speed, but as it
*stands you could use ANY scaling value there.

*Have a good squirm, and enjoy th' blasting!


* -- Y a K 





* Draw an Ozric Tentacle
*
* Assumes a sprite routine hook such as THE_BUSINESS is in use.
* a0=sprite def, a1=screen to draw on, a2=undraw list ptr,
* you know, the usual sprite routine crap applies.

a_inc: dc.l $fff00000	;32-bit angle increment
r_inc: dc.l $4000	;32-bit radius increment

tent_ang: dc.l $00000000	;Add to this in int to rot8 whole tentacle


sine2_amp: dc.l $00140000	;amplitude of second wave
sine2_ptr: dc.l $00000000	;pointer to access it
sine2_add: dc.l $00020000	;add value to ptr.
sine2_base: dc.l $00000000	;moving this in int will make it ripple

draw_tentacle: move.l #$a00000,d0	;32-bit fixed-point values.
 move.l #$640000,d1		;X and Y position of tentacle origin
 lea saf1,a0			;The graphic used to draw it
 lea sine,a3	;Address of 8-bit sine table
 move.l a_inc,d3	;d3 is value to add per sprite
 move.l #$00020000,d4	;d4 is radius
 move.l r_inc,d5	;Value added to radius, per sprite
 move #20,d6	;Length of tentacle
 move.l sine2_base,sine2_ptr	;set second-sine pointer

* Draw sprite at origin

; move #-1,d2	;Parameter for my YAK sprite routine
; swap d0
; swap d1	;Get integer parts of xypos in low word
; bsr syak	;SYAK keeps d0-5/a0-a5 intact (except a2 of course)
; swap d0
; swap d1	;Restore these 32-bit values

 move.l tent_ang,d2	;d2 is start angle

tent_loop: move d6,-(a7)	;Free d6 for use in routine
 add.l d3,d2	;Add to angle
 add.l d5,d4	;Add to radius
 swap d2	;Get integer part of angle
 and #$ff,d2  	;Ensure it lies within sine table
 move.b 0(a3,d2.w),d7	;Get X offset as signed byte value
 ext d7		;Sign-extend to word
 move.l d4,d6	;Get working copy of radius
 swap d6	;Get integer part
 muls d6,d7	;Signed multiply - yields radius*sine(angle)
 divs #128,d7	;d7 now has scaled, 16-bit offset

 swap d7
 clr d7		;Make into 32-bit value
 add.l d7,d0	;Add to current x position

 add.b #$40,d2	;Add $40 to pointer to get cosine
 move.b 0(a3,d2.w),d7	;Y offset
 ext d7		;make signed word value
 sub.b #$40,d2	;Restore pointer to sine again
 swap d2	;Make back into 32bit and forget it
 muls d6,d7	;d6 still holds radius from before
 divs #128,d7	;scale d7, is now Y-offset
 swap d7
 clr d7		;force to 32 bit
 add.l d7,d1	;Add to current Y position

 swap d0
 swap d1	;get int parts of XY for sprite routine
 cmp #10,d0
 blt kklip	;Rudimentary clipping - this version of YAK isn't
 cmp #310,d0
 bge kklip
 cmp #10,d1
 blt kklip
 cmp #190,d1
 bge kklip
 move.l d2,-(a7)
 tst 4(a7)
 bne komplex
 lea thead,a0
 move d0,hedex
 move d1,hedey
 bra zoing
komplex: move freecount,d2
 asr #1,d2
 
 add d6,d2
 and #7,d2
 asl #2,d2
 lea tentims,a0
 move.l 0(a0,d2.w),a0
zoing: move #-1,d2	;my sprite rtn. neeeeds this man!
 bsr syak	;draw sprite, as before
 move.l (a7)+,d2
kklip: swap d0
 swap d1	;restore 32bit XY

 move sine2_ptr,d6	;get second wave ptr
 and #$ff,d6		;constrain to table
 move.b 0(a3,d6.w),d6	;get sine value
 ext d6		;make 16-bit signed
 muls sine2_amp,d6	;multiply by amplitude...
 divs #128,d6		;scale it
 swap d6
 clr d6			;force to 32bit
 add.l d6,d2		;update angle with value

 move.l sine2_add,d6
 add.l d6,sine2_ptr	;update pointer

 move (a7)+,d6	;unstak debbie...
 dbra d6,tent_loop	;iterate for whole tentacle..
 rts		;- and bob is your dingbat.


tentims: dc.l tseg1,tseg2,tseg3,tseg4,tseg5,tseg6,tseg7,tseg8
