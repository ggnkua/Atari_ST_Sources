* Convert value to hex-ascii string.
* By Niclas Pennskog (Jason/Unit #17)
*
* An example of the suuper-mega-multi-cool-mini source...
*

	lea	string,a0	* Pointer to the string
	move.w	#$c8f3,d0	* Value to convert
	moveq	#4-1,d1	* Digits in value-1
	bsr	hex_conv

	pea	string	* Print string
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	#7,-(a7)	* Wait for key
	trap	#1
	addq.l	#2,a7

	clr.w	-(a7)	* Exit
	trap	#1

* The convert-rout:

hex_conv	lea	hex_chrs,A1	* a0=pointer to ascii
next_hex	move.b	D0,D2	* d0=value
	and.w	#$0F,D2	* d1=how many digits-1
	move.b	0(A1,D2.w),0(A0,D1.w)
	lsr.l	#4,D0
	dbra	D1,next_hex
	rts

***

hex_chrs	dc.b	'0123456789ABCDEF'
string	dc.b	'0000',0

	end
