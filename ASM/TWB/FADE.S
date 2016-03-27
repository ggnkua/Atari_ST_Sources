
** Fade in and out routines 
** Black fades the colours from black to white
** where as white fades from white to black.

black
	move.l	#7,d0
	move	#$000,d7
bloop	jsr	waitvbl
	jsr	waitvbl
	jsr	waitvbl
	jsr	waitvbl
	move	d7,$ffff8240.w		; background colour register
	addi.w	#$111,d7
	dbf	d0,bloop
	rts

white
	move.l	#7,d0
	move	#$777,d7	; white into background
wloop	jsr	waitvbl
	jsr	waitvbl	
	jsr	waitvbl
	jsr	waitvbl
	move	d7,$ffff8240.w
	subi.w	#$111,d7
	dbf	d0,wloop	
	rts
