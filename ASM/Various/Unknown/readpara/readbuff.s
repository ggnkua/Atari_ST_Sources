	include	includes\start_up.s

main	move.l	__command,a3
	clr	d0
	move.b	(a3)+,d0
	tst	d0
	beq.s	exit
	move.l	a3,a0

	bsr.s	open_file
	tst	d0
	bmi.s	exit
	move	d0,handle

	bsr.s	write_file

oops
	bsr.s	close_file

exit
	Pterm

	bss
handle	ds.w	1
	text

* creates the file using the name specified on the command line 
*
open_file
	Fcreate	a3,#0
	rts

* closes the opened file
*
close_file
	Fclose	handle
	rts

* reads from the printer buffer and writes to the file
*
*  writes either when there is 1kB in our buffer or 30 seconds has elapsed
*  returns after 30 seconds with nothing available
*
write_file
	move.l	#1024,d5
	lea	buffer(pc),a4
	moveq	#30,d7
.loop2
	move.l	a4,a3
	move.l	d5,d6
.loop
	Bconstat	#0
	tst	d0
	beq.s	.pause
	moveq	#30,d7
	Bconin	#0
	tst.l	d0
	bmi.s	.pause	* this should never happen but it's here just in case
	subq	#1,d6
	move.b	d0,(a3)+
	tst	d6
	bne.s	.loop
	Fwrite	handle,d5,a4
	tst	d0
	bmi.s	oops	* error while writing the buffer
	bra.s	.loop2
.pause
	bsr.s	pause
	subq	#1,d7
	tst	d7
	bne.s	.loop
.exit
	rts

* waits for 1 second
*
pause
	movem.l	d5-7/a3-4,-(sp)
	Supexec	#get_200hz
	move.l	d0,d4
	add.l	#200,d4
.loop
	Supexec	#get_200hz
	cmp.l	d0,d4
	bge.s	.loop	
.exit
	movem.l	(sp)+,d5-7/a3-4
	rts

* reads the 200hz counter
*
get_200hz
	move.l	$4ba.w,d0
	rts

	bss
buffer	ds.l	256