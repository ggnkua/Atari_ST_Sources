*  start up program

	.text

dbaseh	equ	$ffff8201	* display base high
dbasel	equ	$ffff8203	* display base low
ainit	equ	$a000		* line-a initialize
ahide_mouse equ	$a00a		* hide the mouse
ashow_mouse equ	$a009		* show the mouse

*
*  Must be first object file in link statement
*
	move.l	a7,a5		* save a7 so we can get the base page address
	move.l	#ustk,a7	* set local stack
	move.l	4(a5),a5	* basepage address
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0	* skip los pageos baseos
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move	d0,-(sp)	* junk word
	move	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	clr.l	-(sp)		* our own stack please
	move.w	#$20,-(sp)	* get/set super mode
	trap	#1
	addq	#6,sp		* clean up
	move.l	d0,save_ssp	* save stack pointer
	
*
	jsr	main		* go to program
	move.l	save_ssp,-(sp)	* put back
	move.w	#$20,-(sp)	* you know
	trap	#1
	addq	#6,sp		* clean up

	move.l	mem_ret,-(sp)	* return the block to gem
	move.w	#$49,-(sp)
	trap	#1		* go do it
	addq	#6,sp		* clean up
	
	move.l	#0,-(a7)	* back to gemdos
	trap	#1


main:
	jsr	set_screen		* set up the screen
	jsr	get_screen		* go get the 2 screen locations
	move.w	#0,page_num		* set first page
	move.w	#0,path_num		* path number on
	jsr	page_flip		* for initial draw routine
	jsr	clr_scr			* clear the screens

	jsr	draw_init		* draw the shapes once
mloop1:
	jsr	ball_d_set		* set the params
	jsr	shap_draw		* go draw the new shape
	jsr	page_flip		* flip the page
	jsr	wait			* wait for a while
	jsr	ball_e_set		* set the params
	jsr	shap_erase		* go erase the old shape
	move.l	#s1xpath,a0		* address of x path
	move.l	#s1ypath,a1		* address of y path
	clr.l	d0			* long operation
	move.w	path_num,d0		* path offset
	move.w	d0,d1			* temp
	add.w	#1,d0			* next in path line
	move.w	d0,path_num		* put it back
	cmp.w	s1npath,d0		* end of path-follow yellow bricks
	blt	mpass1			* bypass if not
	move.w	#32,path_num		* only forward
mpass1:
	lsl.w	#1,d1			* times 2 for word operand
	add.l	d1,a0
	add.l	d1,a1			* get the word to add
	move.w	(a0),d1			* get it
	move.w	(a1),d2			* get y one also
	move.w	shap1_y,d0
	add.w	d2,d0			* some bits to y location
	move.w	d0,shap1_y		* do your stuff
	move.w	shap1_x,d0
	add.w	d1,d0
	move.w	d0,shap1_x		* do it this way for checking
	cmp.w	#300,d0			* close to end of screen
	ble	mloop1
	
	move.w	#2,-(sp)		* console
	move.w	#1,-(sp)		* status of above
	trap	#13
	addq	#4,sp
	tst.w	d0			* zero = no characters
	bne	main_exit
	move.w	#0,path_num		* go again
	move.w	#20,shap1_x		* reset x coridiante
	move.w	#100,shap1_y		* reset y
	bra	mloop1			* keep going

main_exit:
	jsr	key_in			* wait for a key
	move.b	page1_addr+1,d0
	move.b	d0,dbaseh		* set high byte back to normal
	move.b	page1_addr+2,d0
	move.b	d0,dbasel		* set screen back to original

	dc.w	ashow_mouse		* line-a call to show the mouse again

	move.w	rez_save,-(sp)		* get the resolution
	move.l	#-1,-(sp)		* don't set anything else
	move.l	#-1,-(sp)
	move.w	#5,-(sp)		* set screen call
	trap	#14			* do it
	add.l	#12,sp			* clean up
	rts				* return to caller

*
* draw the shape specified
*

shap_draw:
	clr.l	d0		* for divide unsigned
	move.w	x_loc,d0	* get x cooridinate
	divs.w	#16,d0		* number of shifts
	swap	d0		* remainder into word location
	move.w	d0,shift_num	* save shift number
	clr.w	d0		* get rid of it
	swap	d0		* get byte number
	mulu.w	#8,d0		* for plane bypass
	move.w	d0,byte_num	* store the varialble
	move.l	shap_address,a0	* get shapes address
	clr.l	d0		* long operation on it
	clr.l	d1		* ditto
	move.w	(a0)+,d1	* get byte of shapes width
	move.w	d1,shap_width	* get shapes width
	move.w	(a0)+,d0	* get shapes height
	move.w	d0,shap_height	* put shapes height
	mulu.w	d1,d0		* size of shape
	move.w	d0,shap_size	* save it
	move.l	a0,shap_address	* set the shapes new address past w & h
	move.l	mask_address,a1	* get mask pointer
	move.l	shap_address,a2	* get shape pointer
	move.l	shap_back,a3	* get shapes background save
draw_loop:
	move.w	byte_num,d0	* get byte number
	move.w	d0,temp_byte	* we are going to mess with it
	move.l	page_addr,d0	* get screen location
	move.l	d0,screen_ptr	* put in screen pointer
	clr.l	d0		* clear for long operation
	move.w	y_loc,d0	* get y location
	mulu.w	#$a0,d0		* number of bytes across screen
	add.l	d0,screen_ptr	* add to screen pointer
	clr.l	d1		* long operation
	move.w	shap_width,d1	* get shapes width
	subq.w	#1,d1		* actually minus one for dbra
	move.l	screen_ptr,a0	* get screen pointer
	clr.l	d0		* to get word work as long
	move.w	temp_byte,d0	* into register
	add.l	d0,a0		* into address register
draw_line:
	clr.l	d0
	clr.l	d3		* so shifts get zero if needed
	move.w	(a0),d0
	move.w	d0,(a3)+	* save background
	move.w	(a1)+,d0	* get mask byte
	move.w	(a2)+,d3	* get shapes byte
	move.l	#8,d2		* subtract from zero
	sub.l	d1,d2
	divs	#4,d2
	swap	d2		* get the remainder
	clr.w	d2		* don't care about remainder
	swap	d2		* get back divided by
	tst	d2
	beq.s	no_shift	* if zero then don't get previous word
	swap	d0
	swap	d3
	move.w	#-10(a1),d0	* get previous byte
	move.w	#-10(a2),d3	* get previous byte here also
	swap	d0
	swap	d3		* ok now to shift the shape
no_shift:
	move.w	shift_num,d2	* get which shift to shift
	lsr.l	d2,d0		* shift for offset
	lsr.l	d2,d3		* this one also
	and.w	d0,d3		* shapes data with and shape
	not.w	d0		* not for and operation
	and.w	(a0),d0		* and it in the screens memory
	or.w	d3,d0		* or it with
	move.w	d0,(a0)+	* move into screen memory
	dbra	d1,draw_line	* subtract 1 from width
	move.w	y_loc,d0	* get y location
	addq.w	#1,d0		* add 1 to y location
	move.w	d0,y_loc	* put back y location
	move.w	shap_height,d0	* get shapes height
	subq.w	#1,d0
	move.w	d0,shap_height	* decrement shapes height
	dbra	d0,draw_loop	* go back to next scan line

	rts			* return to caller

*
* erase the shape that is set up
*

shap_erase:
	clr.l	d0		* for divide unsigned
	move.w	x_loc,d0	* get x cooridinate
	divs.w	#16,d0		* number of shifts
	swap	d0		* remainder into word location
	clr.w	d0		* get rid of it
	swap	d0		* get byte number
	mulu.w	#8,d0		* for plane bypass
	move.w	d0,byte_num	* store the varialble
	move.l	shap_address,a0	* get shapes address
	clr.l	d0		* long operation on it
	clr.l	d1		* ditto
	move.w	(a0)+,d1	* get byte of shapes width
	move.w	d1,shap_width	* get shapes width
	move.w	(a0)+,d0	* get shapes height
	move.w	d0,shap_height	* put shapes height
	mulu.w	d1,d0		* size of shape
	move.w	d0,shap_size	* save it
	move.l	a0,shap_address	* set the shapes new address past w & h
	move.l	shap_address,a2	* get shape pointer
	move.l	shap_back,a3	* get shapes background save
eras_loop:
	move.w	byte_num,d0	* get byte number
	move.w	d0,temp_byte	* we are going to mess with it
	move.l	page_addr,d0	* get screen location
	move.l	d0,screen_ptr	* put in screen pointer
	clr.l	d0		* clear for long operation
	move.w	y_loc,d0	* get y location
	mulu.w	#$a0,d0		* number of bytes across screen
	add.l	d0,screen_ptr	* add to screen pointer
	clr.l	d1		* long operation
	move.w	shap_width,d1	* get shapes width
	subq.w	#1,d1		* actually minus one for dbra
	move.l	screen_ptr,a0	* get screen pointer
	clr.l	d0		* to get word work as long
	move.w	temp_byte,d0	* into register
	add.l	d0,a0		* into address register
eras_line:
	clr.l	d0
	move.w	(a3)+,d0
	move.w	d0,(a0)+	* restore background
	dbra	d1,eras_line	* subtract 1 from width
	move.w	y_loc,d0	* get y location
	addq.w	#1,d0		* add 1 to y location
	move.w	d0,y_loc	* put back y location
	move.w	shap_height,d0	* get shapes height
	subq.w	#1,d0
	move.w	d0,shap_height	* decrement shapes height
	dbra	d0,eras_loop	* go back to next scan line

	rts			* return to caller
	
key_in:
	move.w	#1,-(sp)	* console input
	trap	#1		* get keyboard input
	addq	#2,sp		* clean up
	rts


*
* clear the screen to 0's
*
clr_scr:
	movea.l	page1_addr,a0	* address of screen memory
	movea.l	page2_addr,a1
	move.w	#$1fff,d0	* number of longs to clear
clr_loop:
	move.l	#$ff0000ff,(a0)+	* move long in there
	move.l	#$ff0000ff,(a1)+
	dbra	d0,clr_loop	* until all finished
	
	rts			* return to sender address unkown

	
*
* draw_init initializes the shapes on the screen for page-flipping
*
draw_init:
	move.w	#20,shap1_x		* x cooridinate
	move.w	#100,shap1_y		* y cooridinate
	move.w	#20,shap1_ox		* x old cooridinate
	move.w	#100,shap1_oy		* y old cooridinate
	move.l	#swh,shap_address	* shapes address
	move.l	#msd,mask_address	* masks address -> variable
	move.l	#sbk1,shap_back		* shapes background storage
	move.w	shap1_x,x_loc		* x cooridinate
	move.w	shap1_y,y_loc		* y cooridinate
	jsr	shap_draw		* draw the shape
	jsr	page_flip		* flip the page number
	rts

*
* get_screen gets the screens and puts in locations
*
get_screen:

	move.w	#2,-(sp)		* get physical base of screen
	trap	#14			* trap routine
	addq	#2,sp			* clean up
	move.l	d0,page1_addr		* save address
	move.l	#$8100,-(sp)		* want 8000 bytes of memory
	move.w	#$48,-(sp)		* Malloc memory
	trap	#1			* give it to me
	addq	#6,sp			* clean up
	move.l	d0,mem_ret		* save for clean up
	move.l	d0,d1			* into temporary variable
	and.l	#$ff,d1			* get rid of rest
	move.l	#0,d2			* what to subtract from
	sub.l	d1,d2			* do it now
	and.l	#$ff,d2			* only want the byte 
	add.l	d2,d0			* now we are on 512 byte boundary
	move.l	d0,page2_addr		* set it to that
	rts

*
* set_screen sets the screen locations
*
set_screen:
	dc.w	ainit			* initialize a line
	dc.w	ahide_mouse		* hide the sucker
	move.w	#4,-(sp)		* get rez call
	trap	#14			* get the sucker
	addq	#2,sp
	move.w	d0,rez_save		* save the resolution
	clr.w	-(sp)			* low rez
	move.l	#-1,-(sp)		* don't set anything else
	move.l	#-1,-(sp)
	move.w	#5,-(sp)		* set screen call
	trap	#14			* do it
	add.l	#12,sp			* clean up
	rts
*
* page_flip flips over to the other page operations are done on page not
* showing.
*
page_flip:
	eori.w	#1,page_num		* next page
	move.w	page_num,d0		* get the page number
	tst.w	d0			* zero or one?
	beq	page1_sel
	move.l	page1_addr,d0		* get address of page number 1
	move.l	d0,page_addr		* move into the base page number
	move.b	page2_addr+1,d0		* high byte of page
	move.b	d0,dbaseh		* move into display base high
	move.b	page2_addr+2,d0		* get next byte
	move.b	d0,dbasel		* actually middle
	bra	page_rt
page1_sel:
	move.l	page2_addr,d0		* get address of page number 2
	move.l	d0,page_addr		* move into the base page number
	move.b	page1_addr+1,d0		* high byte of page
	move.b	d0,dbaseh		* move into display base high
	move.b	page1_addr+2,d0		* get next byte
	move.b	d0,dbasel		* actually middle
page_rt:
	rts

*
* ball_d_set sets up the ball parameters for draw
*
ball_d_set:
	move.l	#swh,shap_address	* shapes address
	move.l	#msd,mask_address	* masks address -> variable
	tst.w	page_num		* is page number zero
	bne	db_p2on
	move.l	#sbk1,shap_back		* shapes background storage
	bra	db_p1on
db_p2on:
	move.l	#sbk2,shap_back		* shapes background storage
db_p1on:
	move.w	shap1_x,x_loc		* x cooridinate
	move.w	shap1_y,y_loc		* y cooridinate
	rts

*
* ball_e_set sets up the ball parameters for erase
*
ball_e_set:
	move.l	#swh,shap_address	* shapes address
	move.l	#msd,mask_address	* masks address -> variable
	tst.w	page_num		* is page number zero
	bne	eb_p1on
	move.l	#sbk2,shap_back		* shapes background storage
	bra	eb_p2on
eb_p1on:
	move.l	#sbk1,shap_back		* shapes background storage
eb_p2on:
	move.w	shap1_ox,x_loc		* x cooridinate
	move.w	shap1_oy,y_loc		* y cooridinate
	move.w	shap1_x,shap1_ox	* new x to old x pointer
	move.w	shap1_y,shap1_oy	* same here
	rts

*
* wait for a while and do nothing
*
wait:
	move.l	#$2000,d0			* 50 full containers
wloop1:
	dbra	d0,wloop1		* empty container slowly
	rts
	
	.bss
	.even
	.ds.l	256
ustk:	.ds.l	1
*
	.data
    	.even

save_ssp:
	ds.l	1		* save for super stack pointer

ret_save:
	ds.l	1		* return address save

shap1_x:
	ds.w	1
shap1_y:
	ds.w	1		* shape 1's x and y storage

shap1_ox:
	ds.w	1
shap1_oy:
	ds.w	1		* shape 1's x and y storage

x_loc:	ds.w	1		* x and y storage for shapedraw
y_loc:	ds.w	1

shap_size:			* size into shape
	ds.w	1
shap_width:			* shapes width in bytes
	ds.w	1
shap_height:			* shapes height in bytes
	ds.w	1

shift_num:			* which shift we need
	ds.w	1
o_e_test:			* odd-even test bit
	ds.w	1
byte_num:			* byte number we are on
	ds.w	1
temp_byte:			* temporary byte number
	ds.w	1
temp_o_e:			* temporary odd even test
	ds.w	1

shap_address:			* shapes address
	ds.l	1
mask_address:
	ds.l	1
shap_back:			* shapes background address
	ds.l	1

screen_ptr:			* ptr to screen memory
	ds.l	1

page_num:			* current page number
	ds.w	1

page_addr:			* page ptr to screen memory
	ds.l	1

page1_addr:			* page 1's location
	ds.l	1

page2_addr:
	ds.l	1		* page 2's location

mem_ret:			* memory unallocate save
	ds.l	1

path_num:			* path number
	ds.w	1

rez_save:			* resoultion save 
	ds.w	1

* ShIcEd Form Definition Block 

     swh:
	dc.w	$0008,$000F

     ssd:
	dc.w	$07F0,$07F0,$07F0,$07F0
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$180C,$180C,$1FFC,$180C
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$2002,$2002,$3FFE,$2002
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$4001,$4001,$7D5F,$4001
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$4001,$4001,$7D5F,$4001
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$8000,$8000,$FD5F,$8000
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$8000,$8000,$FD5F,$8000
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$8000,$8000,$FD5F,$8000
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$8000,$8000,$FD5F,$8000
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$8000,$8000,$FB6F,$8000
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$4001,$4001,$6773,$4001
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$4001,$4001,$7FFF,$4001
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$2002,$2002,$3FFE,$2002
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$180C,$180C,$1FFC,$180C
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$07F0,$07F0,$07F0,$07F0
	dc.w	$0000,$0000,$0000,$0000

* ShIcEd Form Definition Block 

     msd:
	dc.w	$07F0,$07F0,$07F0,$07F0
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$1FFC,$1FFC,$1FFC,$1FFC
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$3FFE,$3FFE,$3FFE,$3FFE
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$8000,$8000,$8000,$8000
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$7FFF,$7FFF,$7FFF,$7FFF
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$3FFE,$3FFE,$3FFE,$3FFE
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$1FFC,$1FFC,$1FFC,$1FFC
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$07F0,$07F0,$07F0,$07F0
	dc.w	$0000,$0000,$0000,$0000


    sbk1:
	ds.w	$8*$F		; shapes storage page 1

    sbk2:
	ds.w	$8*$F		; shape storage page 2

s1npath:
	dc.w	48		* number of path cells

s1xpath:			* path of bouncing ball x locations
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1

s1ypath:			* "                   " y "
	dc.w	-2,-2,-2,-2,-2,-2,-2,-2,2,2,2,2,2,2,2,2
	dc.w	-2,-2,-2,-2,-2,-2,-2,-2,2,2,2,2,2,2,2,2
	dc.w	0,-3,-3,-2,-2,-2,-2,-1,0,0,2,2,2,3,3,3


	.end
