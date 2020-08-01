resp =	-16
www:	tstw	a0@(resp)
	bmi	www
ww:	cmpiw	#0x8900,a0@(resp)
	beq	ww
