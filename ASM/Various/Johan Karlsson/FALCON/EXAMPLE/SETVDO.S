*
* Drop a .FV file on this program.
*

	include	releasem.s
	include	getpar.s

	move.l	a0,paradr
	bra	main
	
	include	shrtones.s
	include	loadfile.s
	include	gem.s
	include	setfv.s
	
	
main	move.l	paradr,a5
	move.l	#buffer,a6
	move.l	#48,d7
	bsr	@loadfile
	bsr	@super
	lea	buffer,a0
	bsr	@setfv
	cmp.l	#-1,d0
	beq	error
		
	bsr	@user
	bra	@quit
		
error	move.l	#errortext,-(sp)
	@gemdos	9,6
	bsr	@waitkey
	bra	@quit
		
vbl	addq.l	#1,$466
	rte
		
		
errortext	dc.b	'Not a Falcon Video (.FV) file.',10,13,0
	
	section	bss
	
	even
paradr	ds.l	1
buffer	ds.w	22

