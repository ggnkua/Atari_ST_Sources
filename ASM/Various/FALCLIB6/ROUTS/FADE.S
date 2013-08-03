*This routine is from:

* THE JAGUAR DEMO!
; Code by Genie and EGB's Smelly Sox!
; Music by Metronome of Adrenalin!
; Mod replay by Bitmaster of BSW!
; This code is (c) 1994 PB Productions!
; Uses Devpac for the odd bit of 68030 code, uses tabs = 8


* Fadeit - true colour versh, coded by <Genie!> of Network Trash.
; Obviously it only works on single pixels!
;
; a0 = pointer to colour to change
; a1 = pointer to target colour
*(destroys d1-d4; adds 2 to a0-a1)

*
* Code optimized by Johan Karlsson
*


@fadetrupix
.red
	move	(a1)+,d1		Get target pixel
	move	(a0),d2			Get pixel to change
	cmp	d1,d2			Is pixel colour the same?
	beq.s	.bye			 If so, don't bother- we've finished!

	move	d1,d3			{
	move	d2,d4			{ --- Isolate R bits
	andi	#%1111100000000000,d3	{
	andi	#%1111100000000000,d4	{
	cmp	d3,d4			Are the R bits the same?
	beq.s	.rok			 If so, try the G bits.
	bhi.s	.rsub			 If the target pixel has smaller amount of red-|
.radd	addi	#%0000100000000000,d2    Otherwise add an element of red.	       |
	bra.s	.rok								       |
.rsub	subi	#%0000100000000000,d2	 ... take away an element of red. <------------|
.rok
.green	move	d1,d3			{
	move	d2,d4			{ --- Isolate G bits
	andi	#%11111000000,d3	{
	andi	#%11111000000,d4	{
	cmp	d3,d4			Are the G bits the same?
	beq.s	.gok			 If so, try the B bits.
	bhi.s	.gsub			 If the target has smaller amount of green-----|
.gadd	add	#%00001000000,d2	 Otherwise add an element of green.	       |
	bra.s	.gok								       |
.gsub	subi	#%00001000000,d2	 ... take away an element of green. <----------|
.gok
.blue	move	d1,d3			{
	move	d2,d4			{ --- Isolate B bits
	andi	#%11111,d3		{
	andi	#%11111,d4		{
	cmp	d3,d4			Are the B bits the same?
	beq.s	.bok			 If so, finish.
	bhi.s	.bsub			 If the target has smaller amounts of blue-----|
.badd	addq.l	#1,d2			 Otherwise add an element of blue.	       |
	bra.s	.bok								       |
.bsub	subq.l	#1,d2			 ... take away an element of blue. <-----------|
.bok	move	d2,(a0)+		Put changed pixel on screen.
	rts
.bye	addq.l	#2,a0
	rts
	
