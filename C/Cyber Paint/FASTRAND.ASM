
	public	_FastRand
_FastRand:
	move.w	randseed,d0
	add.w	d0,d0		; shift seed left (add dn,dn is faster)
	bhi.s	L5		; carry? (using bhi instead of bcc unlocks 0s)
	eor.w	#$2B41,d0	; magic number for 16 bit seed
L5:
	move.w	d0,randseed
	and.w	#$3ff,d0	; mask down to 0 to 1023
	rts

	dseg
randseed dc.w	0
