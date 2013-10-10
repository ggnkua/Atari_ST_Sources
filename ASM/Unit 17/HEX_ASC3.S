* Convert value to hex-ascii string.
* By Niclas Pennskog (Jason/Unit #17)
*
* Another example of the suuper-mega-multi-cool-mini source...
*

	clr.l	-(a7)		* Supervisor mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,save_usp

	lea	num,a0		* Pointer to the string
	move.l	$4f2.w,d0		* Value to convert
	moveq	#8-1,d1		* Digits in value-1
	bsr	hex_conv

	move.l	save_usp,-(a7)	* User mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	pea	string		* Print string
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	#7,-(a7)		* Wait for key
	trap	#1
	addq.l	#2,a7

	clr.w	-(a7)		* Exit
	trap	#1

* The convert-rout:

hex_conv	lea	hex_chrs,A1	* a0=pointer to ascii
next_hex	move.b	D0,D2		* d0=value
	and.w	#$0F,D2		* d1=how many digits-1
	move.b	0(A1,D2.w),0(A0,D1.w)
	lsr.l	#4,D0
	dbra	D1,next_hex
	rts

***

save_usp	ds.l	1
hex_chrs	dc.b	'0123456789ABCDEF'
string	dc.b	'ROM adress: $'
num	dc.b	'00000000'
	dc.b	$d,$a,0
	end
