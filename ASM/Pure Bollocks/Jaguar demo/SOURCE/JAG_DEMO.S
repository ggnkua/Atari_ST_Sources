* THE JAGUAR DEMO!

; Code by Genie and EGB's Smelly Sox!
; Music by Metronome of Adrenalin!
; Mod replay by Bitmaster of BSW!
; This code is (c) 1994 PB Productions!

; Uses Devpac for the odd bit of 68030 code, uses tabs = 8


DEVPAC_RUN	equ	1	< 1 = run from Devpack!

SCANLINE_TEST	equ	0	< if 1, shows about of vbl time left

; A few system variables.

c256regs	equ	$ffff9800
vidhimid	equ	$ffff8200
vidlo		equ	$ffff820d
timer		equ	$468
keyclick	equ	$484

	IFNE	DEVPAC_RUN
FILED	equ	0
	ELSE
FILED	equ	1
	ENDC

	IFNE	FILED
	opt	d-
	output	jag_demo.prg
	ENDC

main	pea	0
	move	#$20,-(sp)
	trap	#1
	move.l	d0,oldstack
	addq.l	#6,sp
	lea	newstack,a7		< Use our own stack

	move.l	$44e.w,oldscr
	move	#4,-(sp)		< We now know this doesn't work!
	trap	#14			  (We thought it would give us
	addq.l	#2,sp			   the current video mode!)
	move	d0,oldmode
	andi	#%1111111111111000,d0	< Keep all the old values   : This was discovered by accident.
	ori	#%0000000000000100,d0	< Put into true-colour mode : We're much better at it now!
	movem.l	front,d6-d7		{ 
	clr.b	d6			{ --- Yes this is bad, but we didn't
	clr.b	d7			{     know about the "careful
	movem.l	d6-d7,front		{     boundry" trick!
	move.l	d6,a6
	move	d0,-(sp)		< Set screen
	move	#3,-(sp)
	pea	(a6)
	pea	(a6)
	move	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	clr.l	(c256regs).w		< Set border col to black

	bsr	swap_screen
	lea	start_screen,a0		< Convert Degas PI1 pic
	bsr	convert_to_true_colour	< to true colour screen
	bsr	swap_screen
	bsr	save_ints
	bsr	key_int_on		< Set up keyboard interrupt
	lea	module,a6		< Start the music.
	bsr	muson			<
	bsr	set_ints		< Start demo interrupts

* SLIDESHOW BIT

* The following loop just pulls out the address of a pic and displays
* it. This process repeats until there aren't any piccies left.

.loop	move.l	pic_ptr,a0		Get piccy pointer
	move.l	(a0)+,d0		Get address of piccy
	cmpi.l	#-1,d0			At end of list?
	beq.s	.wait
	move.l	a0,pic_ptr		 If not, save piccy pointer
	move.l	d0,a0			{
	move.l	back,a1			{-- Depack piccy to "back" screen.
	bsr	depack			{
	move	#250,(timer).w		Set 5 sec delay after fade
	move.b	#1,do_next		Set "fade in progress" flag on
	move.l	#start_fade_vbl,$70.w	Start fade
	clr.b	keybuff

.key	cmp.b	#$39,keybuff		{
	beq.s	.wait			{-- Tes for space bar or left
	tst.b	mouse_buttons		{   mouse button.
	bne.s	.wait			{
	tst.b	do_next			Ready for next pic?
	beq.s	.loop			 If so, do pic
	bra.s	.key			 Otherwise wait test keys again

* PLASMA BIT
; This just waits for either the space bar or left mouse button before
; exiting the program

.wait
	move.l	back,a0
	adda.l	#(35*640)+(95*2)+2,a0
	move.l	a0,old_pos
	bsr	clr_screen		Nice "wipe" effect.
	move.l	#plasma_vbl,$70.w	Start plasma.

	clr.b	mouse_buttons
	clr.b	keybuff

.key3	cmp.b	#$39,keybuff		{
	beq.s	.wait2			{-- Test for space bar or
	tst.b	mouse_buttons		{   Left mouse button.
	beq.s	.key3			{

.wait2	bsr	ret_ints		< Restore interrupts
	bsr	musoff			< Switch music off
	bsr	key_int_off		< Restore keyboard routines

	IFEQ	FILED
	move	oldmode,-(sp)		If running from Devpac
	move	#3,-(sp)		restore screen and exit.
	move.l	oldscr,-(sp)
	move.l	oldscr,-(sp)
	move	#5,-(sp)
	trap	#14
	lea	14(sp),sp

	move.l	oldstack,-(sp)
	move	#$20,-(sp)
	trap	#1
	move.l	d0,oldstack
	addq.l	#6,sp
	move	#34,-(sp)
	trap	#14
	addq.l	#2,sp
	clr	-(sp)
	trap	#1
	ELSE
	move.l	4,a0			< Otherwise, do warm reset!
	jmp	(a0)			  (Only because we couldn't restore mode properly!)
	ENDC

		ds.l	100
newstack	ds.l	1		< Our own stack
oldstack	ds.l	1		< The old stack

* Save interrupts

save_ints
	lea	ints,a0			< Not very much to save here!
	move.l	$70.w,(a0)+		  (All the other are saved by their own custom routines.)
	rts

ints
.old70	ds.l	1
.olda07	ds.b	1
.olda09	ds.b	1
	even

* Set interrupts

set_ints
	move	#$2700,sr
	bclr	#0,(keyclick).w 	Switch off keyclick
	move	#200,(timer).w		Wait 4 secs at start of demo. (For title page)
	move.l	#do_nothing_vbl,$70.w	Start off doing nothing.
	move	#$2300,sr		Start interrupts
	move.b	#1,do_next		{
.loop	tst.b	do_next			{-- Wait until 4 secs are up.
	bne.s	.loop			{
	rts

* Restore interrupts

ret_ints
	move	#$2700,sr
	bset	#0,(keyclick).w		Keyclick back on
	lea	ints,a0
	move.l	(a0)+,$70.w		Restore lone interrupt
	move	#$2300,sr
	rts

* Converts a PI1 picture to a true colour display
; In the first part, we get the pallete, and convert into it's trucol
; equivalent. Then we get each pixel from the picture (In plane mode-
; not very easy!) and use as an index to plot the right colour from
; the converted pallette onto the screen. Sounds harder than it
; actually is.

; a0 = the Degas PI1 file.

; First, we convert the colours.

convert_to_true_colour
	lea	2(a0),a1		< a1 = picture pallette
	lea	.tru_colours,a2		< a2 = converted trucol pallette
	moveq	#16-1,d0
.colours
	moveq	#0,d1			{
	move.l	d1,d2			{-- clear d1-d3
	move.l	d1,d3			{
	move	(a1)+,d1		Get colour from Degas pic
	move	d1,d2			{-- Copy into d2-d3
	move	d1,d3			{
	and	#$700,d1		Isolate R bits in d1 (%-----RRR--------)
	and	#$70,d2			"     " G "     " d2 (%---------GGG----)
	and	#$7,d3			"     " B "     " d3 (%-------------BBB)
	lsl	#5,d1			Convert to trucol R  (%RRRRR-----------)
	lsl	#4,d2			Convert to trucol G  (%-----GGGGGG-----)
	lsl	#2,d3			Convert to trucol B  (%-----------BBBBB)
	or	d2,d1			add G bits to R bits
	or	d3,d1			add B bits to R + G bits (Now d1 = trucol RGB value)
	move	d1,(a2)+		Save converted trucol value in new pallette
	dbf	d0,.colours		Repeat for other colours

; Now we convert the picture.

	lea	$22(a0),a1		< a1 = Degas lo-res pic data
	move.l	back,a2			< a2 = Address of trucol pic to draw.
	lea	.tru_colours,a3		< a3 = trucol "pallette"

; Each line of the pic is set out into 20 segments of 4 video planes.

	move.l	#(20*200)-1,d0
.planes	movem.w	(a1)+,d2-d5		< Get 1 segment of 4 planes
	move	#16-1,d1		< There's 16 pixels per segment.
.pixels	moveq	#0,d6			< d6 = resultant colour number.
	lsl.w	#1,d5			shift 4th plane 1 to left (Result bit in extend flag)
	roxl	#1,d6			shift extend flag into colour number			
	lsl.w	#1,d4			shift 3rd plane 1 to left (Result bit in extend flag)
	roxl	#1,d6			shift extend flag into colour number			
	lsl.w	#1,d3			shift 2nd plane 1 to left (Result bit in extend flag)
	roxl	#1,d6			shift extend flag into colour number			
	lsl.w	#1,d2			shift 1st plane 1 to left (Result bit in extend flag)
	roxl	#1,d6		        shift extend flag into colour number (now d6= colour number!)
	move	(a3,d6.w*2),(a2)+	Get colour from pallete, and plot on trucol screen
	dbf	d1,.pixels		Do for next pixel
	dbf	d0,.planes		Repeat for all segments.
	rts

.tru_colours
	ds.w	16			< trucolour pallete

* This vbl interrupt does nothing except count off a timer.

do_nothing_vbl
	bsr	next
	rte

next	subq.w	#1,(timer).w
	beq.s	.bye
	rts
.bye	clr.b	do_next
	rts
do_next	ds.b	1
	even

* This vbl rout starts the fading process.
; For each vbl coming up, increasing columns of trucolour RAM in the front
; picture are faded into the corresponding pixels in the back picture,
; until there are 32 columns being faded at once. Since it takes 32 fades
; maximum for a single pixel in the front screen to be faded into the
; back screen, then we should end up with a fading bar which can be
; dragged across the screen in the next vbl routine

start_fade_vbl
	clr	line_count			< Start with 1 line
	move.l	#fade1_vbl,$70.w		< Next vbl is slightly below
	movem.l	front,a0/a1			< a0 = front, a1 = back screen
	adda.l	#(319*2),a0			{-- Go to top right of screen
	adda.l	#(319*2),a1			{   (319 pixels * 2 bytes)
	movem.l	a0/a1,f_start			< fading starts there

fade1_vbl
	IFNE	SCANLINE_TEST
	eori.l	#$ffff00ff,(c256regs).w
	ENDC
	movem.l	d0-a6,-(sp)
	cmp	#32-1,line_count		Is there 32 lines being drawn?
	beq.s	.bye				 If so, install next vbl routine
	moveq	#0,d7
	movem.l	f_start,a0/a1			Get start of fading bar.
	move.l	a0,a2				{-- Save starts for later
	move.l	a1,a3				{
	move	line_count,d7			For d7= 1 to line_count
.loop	bsr	fade_line			 Fade a whol column of pixels.
	dbf	d7,.loop
	add	#1,line_count			Increase the no of columns for next time.
	subq.l	#2,a2				{-- Move fade bar 1 to the left
	subq.l	#2,a3				{
	movem.l	a2/a3,f_start			Save new start of fading bar.
	bsr	key				Check keys.
	bra.s	.ok
.bye	move.l	#fade2_vbl,$70.w		< If 32 lines, next vbl is a new routine
.ok	movem.l	(sp)+,d0-a6
	IFNE	SCANLINE_TEST
	eori.l	#$ffff00ff,(c256regs).w
	ENDC
	rte

f_start		ds.l	2

line_count	ds.w	1

* This vbl routine moves the 32 wide fade bar across the screen.
; There are 32X200 fade operations being carried out each time. This
; is why the fade is so slow!

fade2_vbl
	IFNE	SCANLINE_TEST
	eori.l	#$ff000000,(c256regs).w
	ENDC
	movem.l	d0-a6,-(sp)
	movem.l	f_start,a0/a1		Get the start of the fading bar.
	movem.l	front,a2		{-- Has it hit the left of the screen yet?
	cmpa.l	a0,a2			{
	beq.s	.bye			 If so, set the end-of-fade bit in motion.
	move.l	a0,a2			{-- save fade starts for later.
	move.l	a1,a3			{
	move.l	#32-1,d7		For d7= 1 to 37
.loop	bsr	fade_line		 Fade a column
	dbf	d7,.loop
	subq.l	#2,a2			{-- Move fade bar left 1 pixel
	subq.l	#2,a3			{
	movem.l	a2/a3,f_start		Save new fade bar start.
	bsr	key			Check keys
	bra.s	.ok
.bye	move.l	#fade3_vbl,$70.w	If at left hand side, next vbl is end-of-fade bit.
	sub	#1,line_count
.ok	movem.l	(sp)+,d0-a6
	IFNE	SCANLINE_TEST
	eori.l	#$ff000000,(c256regs).w
	ENDC
	rte

* This is the final part of the fade, when the fading bar hits the left
; hand side of the screen. The last 32 columns are faded off.

fade3_vbl
	IFNE	SCANLINE_TEST
	eori.l	#$ff0000,(c256regs).w
	ENDC
	movem.l	d0-a6,-(sp)
	tst	line_count			Are we at zero lines yet?
	bmi.s	.bye				 If so, fade is finished.
	movem.l	front,a0/a1			Fading always starts here at left of screen.
	move	line_count,d7			For d7= 1 to line_count	
.loop	bsr	fade_line			 Fade a column
	dbf	d7,.loop
	sub	#1,line_count			Decrease the number of lines to fade
	bsr	key				Check for keypress
	bra.s	.ok
.bye	move.l	#do_nothing_vbl,$70.w		If fade is finished, do nothing
.ok	movem.l	(sp)+,d0-a6
	IFNE	SCANLINE_TEST
	eori.l	#$ff0000,(c256regs).w
	ENDC
	rte

* This subroutine is used by the vbl to check if either the space bar
; the left hand mouse button has been pressed. This is used in case the
; vbl interrupt takes longer then it should!

key	tst.b	mouse_buttons
	bne.s	.pressed
	cmp.b	#$39,keybuff
	bne.s	.end
.pressed				; {-- If keys press, install
	move.l	#do_nothing_vbl,$70.w	  {   a less time consuming vbl!
.end
	rts

* This fades a whole column (200 pixels high) by basically calling
; the "fade pixel" subroutine for each of the pixels!

fade_line
	movem.l	a0/a1,-(sp)
	move.l	#200-1,d6
.loop	bsr	fade_tru_pix
	lea	638(a0),a0
	lea	638(a1),a1
	dbf	d6,.loop
	movem.l	(sp)+,a0/a1
	addq.l	#2,a0
	addq.l	#2,a1
	rts

* Fadeit - true colour versh, coded by <Genie!> of Network Trash.
; Obviously it only works on single pixels!
;
; a0 = pointer to colour to change
; a1 = pointer to target colour

fade_tru_pix
.red	moveq	#0,d1			{
	move.l	d1,d2			{ --- Clear regs d1-d4
	move.l	d1,d3			{
	move.l	d1,d4			{
	move	(a1)+,d1		Get target pixel
	move	(a0),d2			Get pixel to change
	cmp	d1,d2			If pixel colour the same?
	beq.s	.bye			 If so, don't bother- we've finished!
	move	d1,d3			{
	move	d2,d4			{ --- Isolate R bits
	andi	#%1111100000000000,d3	{
	andi	#%1111100000000000,d4	{
	cmp.l	d3,d4			Are the R bits the same?
	beq.s	.rok			 If so, try the G bits.
	bgt.s	.rsub			 If the target pixel has smaller amount of red-|
.radd	addi	#%0000100000000000,d2    Otherwise add an element of red.	       |
	bra.s	.rok								       |
.rsub	subi	#%0000100000000000,d2	 ... take away an element of red. <------------|
.rok
.green	move	d1,d3			{
	move	d2,d4			{ --- Isolate G bits
	andi	#%11111000000,d3	{
	andi	#%11111000000,d4	{
	cmp.l	d3,d4			Are the G bits the same?
	beq.s	.gok			 If so, try the B bits.
	bgt.s	.gsub			 If the target has smaller amount of green-----|
.gadd	add	#%00001000000,d2	 Otherwise add an element of green.	       |
	bra.s	.gok								       |
.gsub	subi	#%00001000000,d2	 ... take away an element of green. <----------|
.gok
.blue	move	d1,d3			{
	move	d2,d4			{ --- Isolate B bits
	andi	#%11111,d3		{
	andi	#%11111,d4		{
	cmp.l	d3,d4			Are the B bits the same?
	beq.s	.bok			 If so, finish.
	bgt.s	.bsub			 If the target has smaller amounts of blue-----|
.badd	addq.l	#1,d2			 Otherwise add an element of blue.	       |
	bra.s	.bok								       |
.bsub	subq.l	#1,d2			 ... take away an element of blue. <-----------|
.bok	move	d2,(a0)+		Put changed pixel on screen.
	rts
.bye	addq.l	#2,a0
	rts


* PLASMA VBL ROUTINE.
; Yes, this is the vbl routine for the plasma bit at the end.
; As you can guess, it's a trucolour plasma with scroller. It's not very
; good though, since it uses software scrolling, and so it only happens
; in a small square of the screen! Perhaps I should have used hardware
; scrolling?

plasma_vbl
	IFNE	SCANLINE_TEST
	eori.l	#$ff,(c256regs).w
	ENDC
	movem.l	d0-a6,-(sp)
	bsr	swap_screen			< Guess what?
	bsr	do_plasma			< Guess!
	bsr	scroller			< This is hard to understand!
	bsr	next
	movem.l	(sp)+,d0-a6
	IFNE	SCANLINE_TEST
	eori.l	#$ff,(c256regs).w
	ENDC
	rte


* Guess what- it swaps the front and back screen!

swap_screen
	move.l	back,d0			{
	move.l	front,back		{ --- Swap values "front" <-> "back"
	move.l	d0,front		{
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,(vidhimid).w		{ --- Set video base address of screen.
	move.b	d1,(vidlo).w		{
	rts
	

* Well, this does more than a clear screen! It clears it to a gradiated
; true-colour background!

clr_screen
	movem.l	front,a0-a1		< a0 = front screen, a1 = back screen
	add.l	#(199*640),a0		{ --- go to end of both screens
	add.l	#(199*640),a1		{
	move.l	#100-1,d0		For first 100 lines do
.loop	move.l	a0,a2			 
	move.l	a1,a3
	move.l	d0,d1			 Change d0 to G bits
	lsr	#2,d1
	lsl	#6,d1
	addi	#%1100100000011111,d1	 Add to R+B bits...
	move	#320-1,d2		 For 320 pixels do
.loop1	move	d1,(a2)+		  { --- stick on both screens
	move	d1,(a3)+		  {
	dbf	d2,.loop1
	move	(timer).w,d2		 {
.loop2	cmp	(timer).w,d2		 { --- Wait till next pixel
	beq.s	.loop2			
	lea	-640(a0),a0		 { --- Go back a line.
	lea	-640(a1),a1		 {
	dbf	d0,.loop
	move.l	#100-1,d0		For next 100 lines do
.loop3	move.l	a0,a2
	move.l	a1,a3
	move	#320-1,d2		 For 320 pixels do
.loop4	move	d1,(a2)+		  { --- put d1 as a pixel on screen.
	move	d1,(a3)+		  {
	dbf	d2,.loop4
	move	(timer).w,d2		 {
.loop5	cmp	(timer).w,d2	 	 { --- Wait for vbl
	beq.s	.loop5
	lea	-640(a0),a0		 { --- Go back a line
	lea	-640(a1),a1		 {
	dbf	d0,.loop3
	rts

	
* PLASMA ROUTINE.
; In this a lot of RGB values are mangled together at one side of the
; screen and scrolled across to the other side.
; Nice idea, but the routine is a bit lame really. Look, it was coded
; very quickly! At least I made it look reasonably designy!

do_plasma
	move.l	plas_y_r_ptr,a0		{
	move.l	plas_y_g_ptr,a1		{ --- Get sine pointers for R,G,B bits
	move.l	plas_y_b_ptr,a2		{
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
.rag	move.b	(a0)+,d5		Get vertical offset for R
	cmp.b	#-1,d5			At end of table?
	beq	.rr			 Reset table.
.gag	move.b	(a1)+,d6		Get vertical offset for G
	cmp.b	#-1,d6			At end of table?
	beq	.gr			 Reset table.
.bag	move.b	(a2)+,d7		Get vertical offset for B
	cmp.b	#-1,d7			At end of table?
	beq	.br			 Reset table.
	move.l	a0,plas_y_r_ptr		{
	move.l	a1,plas_y_g_ptr		{ --- save new postion of pointers
	move.l	a2,plas_y_b_ptr		{

; Now we scroll the old plasma along a bit. (By software scrolling- Aargh!)

	move.l	back,a0
	move.l	old_pos,a1		< "oldpos" is where we're copying from.
	adda.l	#(35*640)+(95*2)+2,a0	Go along to end of plasma "square"
	move.l	a0,old_pos		Save new "oldpos"
	subq.l	#2,a0
	move.l	a0,a2
	move	#130-1,d0		{
.loop1	move	#(130/2)-1,d1		{ --- Copy it along. (This is lame!)
.loop2	move.l	(a1)+,(a0)+		{
	dbf	d1,.loop2		
	lea	640-260(a0),a0		{ --- go for next line
	lea	640-260(a1),a1		{
	dbf	d0,.loop1
	
; Now the actual plasma bit.

	lea	130*2(a2),a0
	lea	plas_r_bit,a1		{
	lea	plas_g_bit,a2		{ --- load RGB value pointers
	lea	plas_b_bit,a3		{
	move.l	#130-1,d0		For 130 lines (lame!) do
.loop3	moveq	#0,d1
.red	add	(a1,d5.w*2),d1		 {
.green	add	(a2,d6.w*2),d1		 { --- add up RGB values to make pixel
.blue	add	(a3,d7.w*2),d1		 {
	addq.l	#1,d5			 Next R value
	cmp.b	#(plas_r_end-plas_r_bit)/2,d5	Reached end of R values?
	bne.s	.okr				 No, OK then...
	moveq	#0,d5				 Yes, then reset!
.okr	addq.l	#1,d6			 Next G value
	cmp.b	#(plas_g_end-plas_g_bit)/2,d6	Reached end of G values?
	bne.s	.okg				 No, OK then...
	moveq	#0,d6				 Yes, then reset!
.okg	addq.l	#1,d7			 Next B value
	cmp.b	#(plas_b_end-plas_b_bit)/2,d7	Reached end of B values?
	bne.s	.okb				 No, OK then...
	moveq	#0,d7				 Yes, then reset!
.okb	move	d1,(a0)			 Put pixel on screen
	lea	640(a0),a0		 Go to next line
	dbf	d0,.loop3
	rts
.rr	lea	plas_y_r_dat,a0		< Resetting R since pointer bit.
	bra	.rag
.gr	lea	plas_y_g_dat,a1		< Resetting G since pointer bit.
	bra	.gag
.br	lea	plas_y_b_dat,a2		< Resetting B since pointer bit.
	bra	.bag

old_pos	ds.l	1		< Old postion of plasma


* SCROLLER.
; Guess what- this is a scroller! This is a bit dister one as well!
; OK, you've probably guess by now that it's very easy to do a bit
; disting scroller, since you've don't really have to deal with bits
; in trucolour mode!

scroller:
	moveq	#0,d0
	move.b	scr_cnt,d0		< Get no of pixels of letter left to scroll.
	tst.b	d0			Any left? (ie next letter)
	beq.s	.new_letter		 If so, make up a new letter.
.sag	move.l	scr_dist_ptr,a0		Get scroller sine pointer
.dag	moveq	#0,d0
	move.b	(a0)+,d0		Get new vertical sine pos
	cmp.b	#-1,d0			At end of table yet?
	beq.s	.dr			 If so, reset table.
	move.l	a0,scr_dist_ptr		Save new sine pointer position
	move.l	back,a0				{ --- Get to top right of plasma "square"
	adda.l	#(36*640)+((95+129)*2)+2,a0	{
.loop1	lea	640(a0),a0		Down a line
	dbf	d0,.loop1		Repeat for height of sine value.
	lea	build,a1		Get current char. bitmap store
	moveq	#0,d1
	moveq	#16-1,d0		For each line of char. (16) do
.loop2	lsl.w	(a1)+			 Shift left (Leftmost pixel now in extend and carry flags.)
	bcc.s	.again			 If no carry flag set (ie no pixel), try next line.
	not	(a0)			  Otherwise NOT (ie invert) current pixel.
.again	lea	640(a0),a0		 Go to next line.
	dbf	d0,.loop2
	subq.b	#1,scr_cnt		Next pixel.
	rts
.dr	lea	scr_dist_dat,a0		< Reset scrolly sine pointer bit.
	bra.s	.dag

; This bit make up the next letter, which is 1 plane bitmap form and
; 16 X 16 pixels. (Yep, the old Omensoft one again!)

.new_letter
	move.l	scr_ptr,a0		Get scrolltext pointer.
.nag	move.b	(a0)+,d0		Get letter
	cmp.b	#-1,d0			At end of text?
	beq.s	.nr			 If so, wrap!
	subi.b	#' ',d0			Font starts at ' ' so take away #' ' from ASCII value.
	lsl	#5,d0			* 32 (Each char of font is 32 bytes in length.)
	move.l	a0,scr_ptr		Save new scrolltext pointer.
	lea	font,a0			Get font data
	lea	build,a1		Get character store.
	lea	(a0,d0.w),a0		Move to character in font.
	movem.l	(a0),d0-d7		{ --- copy charcter into character store.
	movem.l	d0-d7,(a1)		{
	move.b	#16,scr_cnt		Reset no of pixels to scroll
	bra	.sag			Go back to main scrolly rout.
.nr	lea	scr_text,a0		< Resetting scrolltext pointer bit.
	bra.s	.nag
	
	
; This is for the depacking of pictures.

	include depack35.s

; This is for the keyboard code.

MOUSE_Y	equ	1

	include	keyboard.s

; And this is for the module playing routine.

	include	a:\sound\dsplay2.s
	

* Module ("Ambient Dub Corruption (Extended Mix)")
; by Metronome of Adrenlin!


module	incbin	a:\sound\adrenl2a.mod

oldmode	ds.w	1			< old video mode
oldscr	ds.l	1			< Old screen base
front	dc.l	screen1			{ --- front/back screen addresses.
back	dc.l	screen2			{

* This is the list of piccy addresses.

pic_list	dc.l	pp1,pp2,pp3,pp4,pp5,pp6,pp7,pp8
		dc.l	pp9,pp10,pp11,pp12,pp13,pp14,pp15
		dc.l	-1		< end of table
pic_ptr		dc.l	pic_list	< Pointer to piccy list


* These are the plasma colour values.

; First RED

plas_r_bit
i	set	0
	REPT	32-1
	dc.w	i*%100000000000
i	set	i+1
	ENDR
	dc.w	i*%100000000000
	dc.w	i*%100000000000
	REPT	32-1
	dc.w	i*%100000000000
i	set	i-1
	ENDR
plas_r_end

; Now GREEN

plas_g_bit
i	set	0
	REPT	32-1
	dc.w	i*%1000000
i	set	i+1
	ENDR
	dc.w	i*%1000000
	dc.w	i*%1000000
	REPT	32-1
	dc.w	i*%1000000
i	set	i-1
	ENDR
plas_g_end

; Finally BLUE

plas_b_bit
i	set	0
	REPT	32-1
	dc.w	i
i	set	i+1
	ENDR
	dc.w	i
	dc.w	i
	REPT	32-1
	dc.w	i
i	set	i-1
	ENDR
plas_b_end


* Now all the sine tables

; First for the scroller

scr_dist_dat
	incbin	a:\graphics\jsd.dat
	dc.b	-1		< End of table
	even
	
; Now the plasma red bit

int_p_y_r
	dcb.b	130,0		< Intial bit of zilch
plas_y_r_dat
	incbin	a:\graphics\jpr.dat
	dc.b	-1		< End of table
	even
	
; Now the plasma green bit
	
int_p_y_g
	dcb.b	260,0		< Intial bit of zilch
plas_y_g_dat
	incbin	a:\graphics\jpg.dat
	dc.b	-1		< End of table
	even
	
; Now the plasma blue bit
	
int_p_y_b
	dcb.b	390,0		< Intial bit of zilch
plas_y_b_dat
	incbin	a:\graphics\jpb.dat
	dc.b	-1		< End of table
	even
	

* Now all the pointers for the plasma sine stuff.
	
plas_y_r_ptr
	dc.l	int_p_y_r		RED   sine pointer
plas_y_g_ptr
	dc.l	int_p_y_g		GREEN sine pointer
plas_y_b_ptr
	dc.l	int_p_y_b		BLUE  sine pointer
	

* Now the scrolltext- capital letters only.

scr_text
	dc.b	'                                        OK, NOT EXACTLY A BRAIN-BLASTING DEMO, BUT IT WAS KNOCKED TOGETHER AT SHORT NOTICE!  CODE BY GENIE AND EGB''S SMELLY SOX, EXCEPT FOR THE MOD REPLAY ROUTINE (WHICH- GASP! - IS *NOT* BY CHRIS '
	dc.b	'OF AURA, BUT "BITMASTER OF BSW" !). MUSIC IS BY METRONOME OF ADRENALIN.             '
	dc.b	'JAGUAR SCREEN-SHOTS ARE FROM THE FOLLOWING GAMES:     DINO/HUMANS    TINY TOONS    ALIEN VS PREDATOR    KASUMI NINJA    CRESCENT GALAXY      ....     '
	dc.b	'WHERE POSSIBLE, TARGA PICTURES HAVE BEEN USED TO GET A DECENT TRUE COLOUR IMAGE, RATHER THAN A 256 COLOUR ONE!        '
	dc.b	'WHAT DO YOU MEAN THAT THE FADE IS SLOW?!?!?!    DON''T YOU REALIZE THAT I''M DOING 3 BIT-COMPARE OPERATIONS ON '
	dc.b	'32 X 200 PIXELS AT A TIME!!!!         WELL, WE WERE THE FIRST TO DO A REALTIME TRUE-COLOUR FADE BETWEEN 2 PICTURES ON A FALCON DEMO, SO DON''T EXPECT TOO MUCH FOR OUR FIRST GO!         AH WELL, WAIT TILL WE GET OUR DSP MANUAL! '
	dc.b	'EVEN BETTER, WAIT TILL WE ACTUALLY UNDERSTAND IT!            '
	dc.b	'THIS IS ALSO PROBABLY THE FIRST DEMO ON THE FALCON TO USE A SCROLLER... GROAN!     SORRY ABOUT THAT!           '
	dc.b	'WE''RE ALSO STARTING TO ALLOW YOU TO EXIT BY PRESSING A '
	dc.b	'MOUSE BUTTON, LIKE ON AMIGA DEMOS!      YOU''D BETTER APPRECIATE THAT, OR WE''LL KILL YOU!!!         '
	dc.b	'COMING SOON FROM PB PRODUCTIONS ON THE FALCON..... '
	dc.b	'THE PERPETUAL DAWN DEMO PT 2 - LOADS OF NEW EFFECTS, MOST OF THEM MUCH BETTER THAN THE ONES ON THIS DEMO!        IT WILL ALSO HAVE LOADS OF DESIGNY EFFECTS, LIKE ON AMIGA DEMOS!       YES, IT''LL ALSO BE A MULTIPART!       OH, AND '
	dc.b	'WE MIGHT EVEN GET ROUND TO DOING AN ISSUE OF PB!!!!!              IF YOU WANT TO GET THE LATEST ISSUE OF OUR BRILLIANT FALCON COMPATIBLE DISKMAG, THEN WRITE TO:       PB MAGAZINE,         PO BOX 1083,         GLASGOW G14 9DG,      '
	dc.b	'BRITAIN.           YOU CAN ALSO GET IT BY ANONYMOUS FTP FROM     ARCHIVE.UMICH.EDU    IN THE DIRECTORY    "MAGAZINES/DISKMAGS/PB"     AND FROM     FTP.UNI-KL.DE    IN THE DIRECTORY "MAGAZINES" .        WE CAN BE EMAILED AT THE '
	dc.b	'ADDRESS     AN18359@ANON.PENET.FI          WELL, ENOUGH OF THIS SCROLLY BULL, LET''S WARP!!!!          (EGB''S SMELLY SOX!)                                                                                            '
	dc.b	-1			< End of scrolltext
	even
scr_ptr	dc.l	scr_text		< Pointer to scrolltext
scr_dist_ptr
	dc.l	scr_dist_dat		< Scrolly sine pointer
scr_cnt	ds.b	1			< No. of pixels left to scroll.
	even
build	ds.w	16			< Scrolley character bitmap store
font	incbin	a:\graphics\fontish.bin	< The font. (Yes, that old one again!)
	even
	
	
* Now all the pics. All of them have been packed using the Atomix packer v3.5.

start_screen
	incbin	a:\graphics\jaglog.pi1		< Initial crap PI1 screen
pp1	incbin	a:\graphics\jag_pic.tru		Jag machine shot
pp2	incbin	a:\graphics\caveman.tru		{ - Evolution Dino Dudes
pp3	incbin	a:\graphics\caveman2.tru	{
pp4	incbin	a:\graphics\raiden.tru		< Raiden
pp5	incbin	a:\graphics\tiny1.tru		{   "We're Tiny, we're
pp6	incbin	a:\graphics\tiny2.tru		{ -  Toony, we're all a 
pp7	incbin	a:\graphics\tiny3.tru		{    little loony..."
pp8	incbin	a:\graphics\tiny4.tru		{
pp9	incbin	a:\graphics\avp1.tru		[
pp10	incbin	a:\graphics\avp2.tru		[ - Alien Vs Predator
pp11	incbin	a:\graphics\avp3.tru		[
pp12	incbin	a:\graphics\ninja1.tru		{ - Kasumi Ninja (Very early pics
pp13	incbin	a:\graphics\ninja2.tru		{   though, a bit more like MK now.)
pp14	incbin	a:\graphics\cresc1.tru		[ - Crescent Galaxy (OK, OK, but
pp15	incbin	a:\graphics\cresc2.tru		[   the screenshots are nice.)

	section	bss

	ds.b	256			{
screen1	ds.w	320*200			{ --- Finally the two screens. Lo-res trucol
screen2	ds.w	320*200			{		(ie 320 X 200)
endscreen
	even

* End of code.

