* 'C' source file for drawing shapes

	.text
	.globl	_main
	.globl	_crystal
	.globl	_ctrl_cnts
	.globl	_page_num
	.globl	_shap_draw
	.globl	_shap_erase
	.globl	_page_flip
	.globl	_clean_up
	.globl	_clr_scr
	.globl	_get_screen

dbaseh	equ	$ffff8201	* display base high
dbasel	equ	$ffff8203	* display base low

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
	
*
	jsr	_main		* go to program

	move.l	mem_ret,-(sp)	* return the block to gem
	move.w	#$49,-(sp)
	trap	#1		* go do it
	addq	#6,sp		* clean up
	
	move.l	#0,-(a7)	* back to gemdos
	trap	#1

*
* clean up the screens for exiting
*
_clean_up:
	jsr	super_mode		* into super mode
	move.b	page1_addr+1,d0		* get high byte of page
	move.b	d0,dbaseh
	move.b	page1_addr+2,d0		* get low byte of page
	move.b	d0,dbasel
	jsr	super_exit
	rts				* return to sender address unknown

*
* draw the shape specified
*

_shap_draw:
	jsr	save_regs	* save the registers
	jsr	super_mode	

	move.w	4(sp),x_loc	* get the x location
	move.w	6(sp),y_loc	* get the y location
	move.w	8(sp),shap_width	* get the shapes width
	move.w	10(sp),shap_height	* get shapes height
	movea.l	12(sp),a0	* get shapes address
	move.l	a0,shap_address
	movea.l	16(a7),a0	* get masks address
	move.l	a0,mask_address
	movea.l	20(a7),a0	* get background address
	move.l	a0,shap_back

	clr.l	d0		* for divide unsigned
	move.w	x_loc,d0	* get x cooridinate
	divs.w	#16,d0		* number of shifts
	swap	d0		* remainder into word location
	move.w	d0,shift_num	* save shift number
	clr.w	d0		* get rid of it
	swap	d0		* get byte number
	mulu.w	#8,d0		* for plane bypass
	move.w	d0,byte_num	* store the varialble
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

	jsr	super_exit	* no more super mode
	jsr	rest_regs	* restore registers

	rts			* return to caller

*
* erase the shape that is set up
*

_shap_erase:
	jsr	save_regs	* save the registers
	jsr	super_mode

	move.w	4(sp),x_loc	* get the x location
	move.w	6(sp),y_loc	* get the y location
	move.w	8(sp),shap_width	* get the shapes width
	move.w	10(sp),shap_height	* get shapes height
	movea.l	12(sp),a0	* get background address
	move.l	a0,shap_back

	clr.l	d0		* for divide unsigned
	move.w	x_loc,d0	* get x cooridinate
	divs.w	#16,d0		* number of shifts
	swap	d0		* remainder into word location
	clr.w	d0		* get rid of it
	swap	d0		* get byte number
	mulu.w	#8,d0		* for plane bypass
	move.w	d0,byte_num	* store the varialble

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

	jsr	super_exit	* no more super mode
	jsr	rest_regs	* restore the registers

	rts			* return to caller
	

*
* clear the screen to 0's
*
_clr_scr:
	jsr	super_mode	* not lois lane ok?
	movea.l	page1_addr,a0	* address of screen memory
	movea.l	page2_addr,a1
	move.w	#$1fff,d0	* number of longs to clear
clr_loop:
	move.l	#$ff0000ff,(a0)+	* move long in there
	move.l	#$ff0000ff,(a1)+
	dbra	d0,clr_loop	* until all finished

	jsr	super_exit	* back to clark kent.
	
	rts			* return to sender address unkown

	

*
* get_screen gets the screens and puts in locations
*
_get_screen:

	jsr	save_regs		* save the registers
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
	jsr	rest_regs		* restore the registers
	rts

*
* page_flip flips over to the other page operations are done on page not
* showing.
*
_page_flip:
	jsr	super_mode		* able to leep tall buildings

	eori.w	#1,_page_num		* next page
	move.w	_page_num,d0		* get the page number
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
	jsr	super_exit		* not even close anymore
	rts

*
* save registers saves the registers before anything happens
*
save_regs:
	movem.l	d0-d7/a0-a7,reg_area
	rts

*
* restore registers from registers area
*
rest_regs:
	movem.l	reg_area,d0-d7/a0-a7
	rts

*
*	For GEMAES calls from AESBIND.ARC or cryslib.o
*
_crystal:
	move.l	4(a7),d1
	move.w	#200,d0
	trap	#2
	rts
*
* enter supervisor mode 
*
super_mode:
	clr.l	-(sp)		* our own stack please
	move.w	#$20,-(sp)	* get/set super mode
	trap	#1
	addq	#6,sp		* clean up
	move.l	d0,save_ssp	* save stack pointer
	rts

*
* exit supervisor state
*
super_exit:
	move.l	save_ssp,-(sp)	* put back
	move.w	#$20,-(sp)	* you know
	trap	#1
	addq	#6,sp		* clean up
	rts

*
*	
	.bss
	.even
	.ds.l	256
ustk:	.ds.l	1
*
	.data
    	.even

save_ssp:
	ds.l	1		* save for super stack pointer


x_loc:	ds.w	1		* x and y storage for shapedraw
y_loc:	ds.w	1

shap_size:			* size into shape
	ds.w	1
shap_width:			* shapes width in bytes
	ds.w	1
shap_height:			* shapes height in bytes
	ds.w	1

shift_num:			* shift number of shape
	ds.w	1

byte_num:			* byte number we are on
	ds.w	1
temp_byte:			* temporary byte number
	ds.w	1

shap_address:			* shapes address
	ds.l	1
mask_address:
	ds.l	1
shap_back:			* shapes background address
	ds.l	1

screen_ptr:			* ptr to screen memory
	ds.l	1

_page_num:			* current page number
	ds.w	1

page_addr:			* page ptr to screen memory
	ds.l	1

page1_addr:			* page 1's location
	ds.l	1

page2_addr:
	ds.l	1		* page 2's location

mem_ret:			* memory unallocate save
	ds.l	1

reg_area:
	ds.l	16		* register save area


_ctrl_cnts:			 	*	Application Manager
	.dc.b	0, 1, 0			* func 010		
    	.dc.b	2, 1, 1			* func 011		
    	.dc.b	2, 1, 1 		* func 012		
	.dc.b	0, 1, 1			* func 013		
	.dc.b	2, 1, 1			* func 014		
	.dc.b	1, 1, 1			* func 015		
	.dc.b	0, 0, 0			* func 016		
	.dc.b	0, 0, 0			* func 017		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 1, 0			* func 019		
*							 Event Manager
	.dc.b	0, 1, 0			* func 020		
	.dc.b	3, 5, 0			* func 021		
	.dc.b	5, 5, 0			* func 022		
	.dc.b	0, 1, 1			* func 023		
	.dc.b	2, 1, 0			* func 024		
	.dc.b	16, 7, 1 		* func 025		
	.dc.b	2, 1, 0			* func 026		
	.dc.b	0, 0, 0			* func 027		
	.dc.b	0, 0, 0			* func 028		
	.dc.b	0, 0, 0			* func 009		
*							 Menu Manager
	.dc.b	1, 1, 1			* func 030		
	.dc.b	2, 1, 1			* func 031		
	.dc.b	2, 1, 1			* func 032		
	.dc.b	2, 1, 1			* func 033		
	.dc.b	1, 1, 2			* func 034		
	.dc.b	1, 1, 1			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							 Object Manager
	.dc.b	2, 1, 1			* func 040		
	.dc.b	1, 1, 1			* func 041		
  	.dc.b	6, 1, 1			* func 042		
	.dc.b	4, 1, 1			* func 043		
	.dc.b	1, 3, 1			* func 044		
	.dc.b	2, 1, 1			* func 045		
	.dc.b	4, 2, 1			* func 046		
	.dc.b	8, 1, 1			* func 047		
	.dc.b	0, 0, 0			* func 048		
	.dc.b	0, 0, 0			* func 049		
*							 Form Manager
	.dc.b	1, 1, 1			* func 050		
	.dc.b	9, 1, 1			* func 051		
	.dc.b	1, 1, 1			* func 002		
	.dc.b	1, 1, 0			* func 003		
	.dc.b	0, 5, 1			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							 Dialog Manager
	.dc.b	0, 0, 0			* func 060		
	.dc.b	0, 0, 0			* func 061		
	.dc.b	0, 0, 0			* func 062		
	.dc.b	0, 0, 0			* func 003		
	.dc.b	0, 0, 0			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							Graphics Manager
	.dc.b	4, 3, 0			* func 070		
	.dc.b	8, 3, 0			* func 071		
	.dc.b	6, 1, 0			* func 072		
	.dc.b	8, 1, 0			* func 073		
	.dc.b	8, 1, 0			* func 074		
	.dc.b	4, 1, 1			* func 075		
	.dc.b	3, 1, 1			* func 076		
	.dc.b	0, 5, 0			* func 077		
	.dc.b	1, 1, 1			* func 078		
	.dc.b	0, 5, 0			* func 009		
*							Scrap Manager
	.dc.b	0, 1, 1			* func 080		
	.dc.b	0, 1, 1			* func 081		
	.dc.b	0, 0, 0			* func 082		
	.dc.b	0, 0, 0			* func 083		
	.dc.b	0, 0, 0			* func 084		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0			* func 009		
*							fseler Manager
	.dc.b	0, 2, 2			* func 090		
	.dc.b	0, 0, 0			* func 091		
	.dc.b	0, 0, 0			* func 092		
	.dc.b	0, 0, 0			* func 003		
	.dc.b	0, 0, 0			* func 004		
	.dc.b	0, 0, 0			* func 005		
	.dc.b	0, 0, 0			* func 006		
	.dc.b	0, 0, 0			* func 007		
	.dc.b	0, 0, 0			* func 008		
	.dc.b	0, 0, 0 		* func 009		
*							Window Manager
	.dc.b	5, 1, 0			* func 100		
	.dc.b	5, 1, 0			* func 101		
	.dc.b	1, 1, 0			* func 102		
	.dc.b	1, 1, 0			* func 103		
	.dc.b	2, 5, 0			* func 104		
	.dc.b	6, 1, 0			* func 105		
	.dc.b	2, 1, 0			* func 106		
	.dc.b	1, 1, 0			* func 107		
	.dc.b	6, 5, 0			* func 108		
	.dc.b	0, 0, 0 		* func 009		
*							Resource Manger
	.dc.b	0, 1, 1			* func 110		
	.dc.b	0, 1, 0			* func 111		
	.dc.b	2, 1, 0			* func 112		
	.dc.b	2, 1, 1			* func 113		
	.dc.b	1, 1, 1			* func 114		
	.dc.b	0, 0, 0			* func 115		
	.dc.b	0, 0, 0			* func 006
	.dc.b	0, 0, 0			* func 007
	.dc.b	0, 0, 0			* func 008
	.dc.b	0, 0, 0			* func 009
*							Shell Manager
	.dc.b	0, 1, 2			* func 120
	.dc.b	3, 1, 2			* func 121
	.dc.b	1, 1, 1			* func 122
	.dc.b	1, 1, 1			* func 123
	.dc.b	0, 1, 1			* func 124
	.dc.b	0, 1, 2			* func 125

	.end
