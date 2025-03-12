* This code is 100% original, and was written by Edd Deegan
* Freely distribute it, but it must bear my name....
* -- Edd Deegan

* \This is the tube scroller. The letters scroll around a tube of rasters

* \Header for Assembler programs. It basically puts all the available
*  memory at my disposal....
*

setblock:       movea.l A7,A5           * Save stack pointer
                move.l  #my_stack,A7    * Set up my own stack
                movea.l 4(A5),A5        * A5 now points to BasePage
                move.l  $C(A5),D0       * $C(A5) = program area length
                add.l   $14(A5),D0      * $14(A5) = data area length
                add.l   $1C(A5),D0
                add.l   #$100,D0        * Reserve $100 bytes BasePage
                move.l  D0,-(sp)        * D0 = length to be reserved
                move.l  A5,-(sp)        * A5 = start address to reserve
                move.w  #$00,-(sp)      * No meaning
                move.w  #$4A,-(sp)
                trap    #1
                add.l   #12,sp          * Correct the stack
                jmp     end_set         * Jump over my stack!
                ds.l    200             * Space for my stack
my_stack:       ds.l    2               * Stacks go backwards....
                EVEN

end_set:        nop
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,save_stack	

		move.l  #moff,-(sp)     * Disable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A00A	

load_scrn:	move.w	#2,-(sp)	* Get video RAM
		trap	#14
		addq.l	#2,sp
		
		move.l	D0,physic
		move.l	D0,real_phys	* Remember original address
		sub.l	#32256,D0
		move.l	D0,logic	* Point to screens
		
		move.w	#3,-(sp)	* Get logical RAM
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_log	* Remember original address		

		move.w	#4,-(sp)	* Get rez
		trap	#14
		addq.l	#2,sp
		move.w	D0,old_rez

		clr.l	D0
		move.l	#$FF8240,A0	* Store colors
		move.l	#old_pal,A1
		move.w	#15,D0
colstor:	move.w	(A0)+,(A1)+
		dbf	D0,colstor


		move.l	#33000,-(sp)	* Reserve a buffer
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,fnt_buf

		move.w	#$00,-(sp)	* Open the file
		move.l	#pic_name,-(sp)
		move.w	#$3D,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	D0,handle
		
		move.l	fnt_buf,-(sp)	* Load the file
		move.l	#32032,-(sp)
		move.w	handle,-(sp)
		move.w	#$3F,-(sp)
		trap	#1
		add.l	#12,sp

		move.w	handle,-(sp)	* Close the file
		move.w	#$3E,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	#$00,-(sp)	* Set the screens....
		move.l	physic,-(sp)
		move.l	logic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	#7999,D0
		move.l	physic,A0
clearl:		clr.l	(A0)+
		dbf	D0,clearl

		move.l	#13440,A5	* Start point for copy routine
		jsr	rasters		* Initialise interrupts
	
**************************************
* \Uses A6 (Point to text)
* \Changes D0,D1,D2
* \Changes A1,A2,A3

		clr.l	D0
		move.l	#text,A6
call_rout:	move.w	#$00,count	* Reset counter
		move.b	(A6)+,D0	* D0 = Character
		cmp.b	#$00,(A6)
		beq	reset
		cmp.b	#$20,D0	
		beq	scroll_loop	* Ingore spaces

call_put:	move.l	#19,D1		* D1 = X-Coord
		move.l	#100,D2		* D2 = Y-Coord	
		jsr	put_char
		jmp	scroll_loop
reset:		move.l	#text,A6	* Repoint A6 to text
		jmp	call_put

scroll_loop:	move.l	#100,D1		* 100 pixels down
		jsr	scroll
		addq.w	#$01,count
		cmp.w	#17,count
		beq	call_rout	* If 20 scrolls - next character
		jmp	scroll_loop

*\ A routine to scroll a 16 pixel deep section of the screen, in
*  one plane. Distance down the screen in D1

scroll:		movea.l	logic,A1	* Screen to scroll
		mulu.w	#160,D1		* D1 = vertical offset
		adda.l	D1,A1		* A1 = Scroll area
		move.l	A1,A2		* A2 points to last byte scrolled
		move.l	A1,A3		* A3 points to last LINE
		adda.l	#$01,A2		* Told ya'
		adda.l	#$01,A3		* A3 stops overflow off left
		jsr	wait_vbl
		move.w	#19,D1		* D1 now = line counter

horiz_loop1:	move.l	A3,A2
		move.w	(A1),D0		* Get 16 pixels
		asl.w	#1,D0		* Shift 'em
		move.w	D0,(A1)		* Put 'em back
		add.l	#8,A1		* Point to next word in plane

* \19 words left in this line....
* \A2 still pointing to second byte in first word of plane 

		move.w	#18,D2		* D2 = word counter
horiz_loop2:	lsl.w	(A1)		* Shift byte
		bcc	clr_bit		* Do byte

set_bit:	bset	#0,(A2)		* Clear bit
		add.l	#$08,A2		* Point to next affected byte
		jmp	after_set		
clr_bit:	bclr	#0,(A2)		* Set the bit
		add.l	#$08,A2		* Point to next affected byte
		
after_set:	add.l	#$08,A1		* Point to next word in plane
		dbf	D2,horiz_loop2	* Repeat for whole line
		add.l	#160,A3		* Add line pointer
		dbf	D1,horiz_loop1	* Repeat for 16 lines
		rts			* End of scroll

to_gem:		jsr	rasters_off
		move.l	#$FF8240,A0
		move.l	#old_pal,A1	* Restore colours
		move.w	#15,D0
putcols:	move.w	(A1)+,(A0)+
		dbf	D0,putcols

		move.l	save_stack,-(sp)
		move.w	#$20,-(sp)	* User mode
		trap	#1	
		addq.l	#6,sp
		
		move.w	old_rez,-(sp)	* Reset screens
		move.l	real_phys,-(sp)
		move.l	real_log,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		clr.l	-(sp)
		trap	#1		* Back to O.S.

* \A routine to extract and place a 1 bitplane font character 
*  (16x16) at x,y on a specified screen...

* \D0.L = ASCII Character
*  D1.W = X pixel/16
*  D2.W = Y pixel
* \Places character on LOGICAL screen, whose address is in logic

put_char:	cmp.b	#"A",D0
		blt	end_put
		cmp.b	#"Z",D0
		bgt	end_put
		mulu.w	#160,D2		* Calculate vertical offset
		mulu.w	#8,D1		* Calculate horizontal offset
		add.l	D1,D2		* D2 = Offset
		add.l	logic,D2
		move.l	D2,A1		* A1 = dest addr


find_line:	cmp.b	#$4D,D0		* Compare to M
		bgt	line_two

line_one:	sub.b	#65,D0		* Now represented by 0,1,2,3,4....
		mulu.w	#8,D0		* Calculate offset
		add.l	fnt_buf,D0
		add.l	#32,D0		* Offset for palette
		move.l	D0,A2		* A2 = Source Addr	
		jsr	do_char		
		jmp	end_put

line_two:	sub.b	#$4E,D0		* Now represtented by 0,1,2,3,4....
		mulu.w	#8,D0
		add.l	#3360,D0	* Add for 21 lines
		add.l	fnt_buf,D0
		add.l	#32,D0
		move.l	D0,A2		* A2 =  Source addr
		jsr	do_char
		jmp	end_put
end_put:	rts

do_char:	move.w	#15,D7		* Line counter
do_loop:	move.w	(A2),(A1)
		add.l	#160,A1
		add.l	#160,A2
end_do:		dbf	D7,do_loop
		rts


wait_vbl:	move.w	physic2,A0	* To wait for...
wait_vbl2:	move.b	$FF8207,temp	* Construct word
		move.b	$FF8209,temp2	
		cmp.w	temp,A0		* Top of screen?
		beq	debug
		jmp	wait_vbl2
debug:		move.b	$FFFC02,D0	* Look at keyboard
		cmp.b	#$39,D0		* SPACE?
		beq	to_gem

* \Copy moved area to physical screen

* \Logic+8000 = source image
* \Physic+8000 = dest addr
* \Use D3,D4,D5,D6,D7
* \Use A0,A4,A5

* \A5 points to current source address

end_vbl:	move.l	A5,t_store5
		add.l	logic,A5	* Point to actual source address
		move.l	#tube_flags,A4
		move.l	physic,A0
		add.l	#16000,A0	* A0 --> Dest addr
		move.l	#15,D3		* Counter

copy_tube:	tst.b	(A4)+
		beq	no_tube
		move.l	#18,D4		* Words per line to copy
tube_loop:	move.w	(A5),(A0)	* Copy word
		add.l	#$08,A5
		add.l	#$08,A0		* Next word in plane
		dbf	D4,tube_loop	* Copy whole line
		sub.l	#152,A5		* back to start of source line
		add.l	#$08,A0		* Down a line
		move.w	#18,D4		* Copy it twice
tube_loop2:	move.w	(A5),(A0)
		add.l	#$08,A5
		add.l	#$08,A0
		dbf	D4,tube_loop2
		jmp	tubeline

no_tube:	add.l	#152,A5		* Skip a line of source
		sub.l	#$08,A0		* Cos it'll get added on again!
		jmp	tubeline

tubeline:	add.l	#$08,A5		* Point to next line
		add.l	#$08,A0
		dbf	D3,copy_tube
		move.l	t_store5,A5	* Restore old value
		add.l	#160,A5		* Down a line
		cmp.l	#21120,A5	* Time to reset A5?
		beq	reset_tube
		jmp	tube_shadow

reset_tube:	move.l	#10880,A5
		jmp	tube_shadow
**************
* \Now create shadow in plane 3

tube_shadow:	move.l	A1,t_store1
		move.l	A2,t_store2	* Save old values

		move.l	shad_off,A1
		add.l	logic,A1	* Point to actual source address
		move.l	#tube_flags2,A4
		move.l	physic,A0
		add.l	#19842,A0	* A0 --> Dest addr
		move.l	#15,D3		* Counter

shad_tube:	tst.b	(A4)+
		beq	no_shad
		move.l	#18,D4		* Words per line to copy
shad_loop:	move.w	(A1),(A0)	* Copy word
		add.l	#$08,A1
		add.l	#$08,A0		* Next word in plane
		dbf	D4,shad_loop	* Copy whole line
		sub.l	#152,A1		* Back to start of source line
		sub.l	#312,A0		* Up two lines
		move.w	#18,D4		* Copy it twice
shad_loop2:	move.w	(A1),(A0)
		add.l	#$08,A1
		add.l	#$08,A0
		dbf	D4,shad_loop2
		jmp	shadline

no_shad:	add.l	#152,A1		* Skip a line of source
		sub.l	#$08,A0
		add.l	#320,A0		* To cancel addition
		jmp	shadline

shadline:	sub.l	#312,A0		* Point up two lines 
		add.l	#$08,A1		* Point to next line of source
		dbf	D3,shad_tube
		
		add.l	#160,shad_off	* Up a line
		move.l	shad_off,D7
		cmp.l	#18720,D7
		beq	shad_reset
		move.l	t_store2,A2
		move.l	t_store1,A1	* Restore old values
		rts
shad_reset:	move.l	#8480,shad_off
		move.l	t_store2,A2
		move.l	t_store1,A1
		rts

tube_flags:	dc.b	1,0,1,0,1,1,1,1,1,1,1,1,0,1,0,1
tube_flags2:	dc.b	1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,1
t_store5:	ds.l	1		* Storage for A5
t_store1:	ds.l	1
t_store2:	ds.l	1
shad_off:	dc.l	8480

rasters:        bsr     hblon           * Enable interrupts
		rts			* Back to scroller

rasters_off:    bsr     hbloff          * Disable interrupts
                move.l  #mon,-(sp)      * Re-enable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A009
		rts

mon:            dc.b    $08
moff:           dc.b    $12

                EVEN

hblon:          move.l  $120,oldtb              * Old TimerB Vector
                move.l  $70,old4                * Old VBL vector
                move.l  $70,new4b+2             * New VBL will jump to old
                move.b  $FFFFFA07,old07         * Timer B enable
                move.b  $FFFFFA09,old09         * Timer C enable
                move.b  $FFFFFA0f,old0f         * Timer B in-service
                move.b  $FFFFFA11,old11         * Timer C in-service
                move.b  $FFFFFA1b,old1b         * Timer B control
                and.b   #$DF,$FFFA09            * Disable Timer C
                and.b   #$FE,$FFFA07            * Disable Timer B
                move.l  #newtb2,$120            * New Timer B vector
                move.l  #new4,$70               * New VBL vector
                or.b    #1,$FFFFFA07            * Enable Timer B
                or.b    #1,$FFFFFA13            * Set Timer B mask
                rts

hbloff:         move.w  sr,-(sp)
                move.w  #$2700,sr
                move.b  old07(pc),$FFFFFA07
                move.b  old09(pc),$FFFFFA09
                move.b  old0f(pc),$FFFFFA0F
                move.b  old11(pc),$FFFFFA11
                move.b  old1b(pc),$FFFFFA1B
                move.l  oldtb,$120
                move.l  old4,$70
                move.w  (sp)+,sr
                rts

* \Storage for old Timer values....
old4:           dc.l    0
oldtb:          dc.l    0
old07:          dc.b    0
old09:          dc.b    0
old0f:          dc.b    0
old11:          dc.b    0
old1b:          dc.b    0

                EVEN

*\ This is the new VBL handler

new4:           clr.b   $FFFFFA1B.w     * Disable Timer B
                move.b  #96,$FFFFFA21   * Time for interrupt

* \EG: At line 40 - TimerB interrupt occurs, and jump to vector at $120

                move.b  #8,$FFFFFA1B    * Enable Timer B again
                move.w  #$0,$FF8240     * Index 0 - BLACK
                move.l  #newtb2,$120    * Change vector for next interrupt
new4b:          jmp     $12345678       * JMP to old routine....

* \The JMP $12345678 will have been replaced with the old address,
*  with move.l  old,new4b+2!

newtb2:         clr.b   $FFFFFA1B.w             * Disable TimerB
                movem.l D0-D7/A0-A3,-(sp)       * Store Registers
                move.w  #$FA21,A1               * A1 = FFFFFA21
                move.b  #200,(A1)        

*\ Place the new vector address

                move.b  #8,$FFFFFA1B.w  * Enable Timer
                move.w  #31,D1          * Raster in scanlines
                move.l  #pal1,A0        * Point to palette
		move.l	#pal2,A2
		move.l	#pal3,A3
loop2           move.b  (A1),D0         * Read TimerB into D0
wait2           cmp.b   (A1),D0
                beq     wait2           * Wait 1 scanline
                move.w  (A0)+,$FF8240   * Colours over black only
                move.w	(A2)+,$FF8242
		move.w	(A3)+,$FF8244	* Over plane 2
		dbra    D1,loop2

                movem.l (sp)+,D0-D7/A0-A3       * Restore registers
                bclr    #0,$FFFFFA0f.w          * Disable interrupt
                rte

* The above 'newtb's set the bars.


pal1:		dc.w    $001,$001,$002,$002,$003,$003
		dc.w	$004,$004,$005,$005,$006,$006,$007,$007
                dc.w    $007,$007,$007,$007,$006,$006,$005,$005
		dc.w	$004,$004,$003,$003,$002,$002,$001,$001
		dc.w	$000,$000

pal2:		dc.w    $110,$110,$220,$220,$330,$330
		dc.w	$440,$440,$550,$550,$660,$660,$770,$770
                dc.w    $770,$770,$770,$770,$660,$660,$550,$550
		dc.w	$440,$440,$330,$330,$220,$220,$110,$110
		dc.w	$700,$700

pal3:		dc.w    $000,$000,$001,$001,$001,$001
		dc.w	$002,$002,$003,$003,$004,$004,$005,$005
                dc.w    $005,$005,$005,$005,$004,$004,$003,$003
		dc.w	$002,$002,$001,$001,$001,$001,$001,$001
		dc.w	$000,$000

**********************************************************************

save_stack:	ds.l	1		* Space for old sp
count:		ds.w	1		* Scroll counter
fnt_buf:	ds.l	1		* Pointer to reserved memory
handle:		ds.w	1		* Storage for filehandle
physic:		ds.w	1
physic2:	ds.w	1
logic:		ds.l	1
real_log:	ds.l	1		* Address of logical screen
real_phys:	ds.l	1		* Address of physical screen
old_rez:	ds.w	1
old_pal:	ds.w	16
temp:		ds.b	1
temp2:		ds.b	1
pic_buf:	ds.l	1

		EVEN

text:		dc.b	"ROUND AND ROUND WE GO    SORRY NO PUNCTUATION "
		dc.b	"BUT YOU CAN ADD THAT YOURSELF IF YOU WANT     ",0
		EVEN
pic_name:	dc.b	"BITPLANE.FNT",0
