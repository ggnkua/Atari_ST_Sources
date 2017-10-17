****************************************************************************************************
*LOAD_FILE:	Loads a file into a buffer							   *
*	If a GEMDOS error occured, the carry is cleaed and d0 contains the GEMDOS		   *
*	error code on exit.									   *
*												   *
*	 A0 = Pointer to full path and filename						   *
*	 A1 = Address of buffer to load data into						   *
*	 D0 = Number of byte to read from the file						   *
*	 D1 = Access mode									   *
*												   *
*	 D0 = # of bytes actually loaded or error code if not successful			   *
*	CARRY set    = Successful								   *
*	CARRY clears = Unsuccesful (Error code in D0)					   	   *
*												   *
*SUBS:	Fopen, Fclose, Fread - "DISKCALL.S"							   *
****************************************************************************************************
lfreg:		reg d1-7/a0-4
load_file:	movem.l	lfreg,-(sp)

		move.l	d0,d6		;Size of file in D6

		moveq	#0,d0		;Mode for open (read only access)
		bsr	Fopen		;Open the file (A0 = address to path/file)
		move.l	d0,d7		;Put handle in D7
		bmi.s	.lf_error	;Negative return = error

		lea	(a1),a0		;Address of buffer to load file into
		move.l	d6,d1		;Size of file (bytes to load)
		bsr	Fread		;Read it
		move.l	d0,d6		;Number of bytes actually read
		bpl.s	.lf_readok	;A positive value = no error

	;GEMDOS delivered an error..
.lf_error:	or.b	#0,ccr
		bra.s	.lf_exit

.lf_readok:	move.l	d7,d0		;Handle back into D0
		bsr	Fclose		;Close the file

	;Load completed successfully, put size of file into D7, set carry and exit
		move.l	d6,d0
		ori.b	#1,ccr
.lf_exit:	movem.l	(sp)+,lfreg
		rts
