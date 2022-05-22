*
* CONVPAL1.S
*
*	@convert_stpal
*
*	Convert an old st colour value to a new falcon one
*
* In	d0.w=old st colour
* Out	d0.l=falcon colour
*	(destroys d1-d3)
*

@convert_stpal
	move	d0,d1
	move	d1,d2
	and.l	#$0007,d0
	lsl.l	#5,d0		Blue ready
	and.l	#$0070,d1
	move	#17,d3
	lsl.l	d3,d1
	or.l	d1,d0		Green ready
	and.l	#$0700,d2
	move	#21,d1
	lsl.l	d1,d2
	or.l	d2,d0		Green ready
	rts
