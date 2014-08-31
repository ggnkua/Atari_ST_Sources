;-----------------------------------------------------------------------------
;File name:	X_KBUF.S			Revision date:	1993.06.04
;Disassembler:	Ulf Ronald Andersson		Disassembled:	1993.05.28
;-----------------------------------------------------------------------------
;
	include	URAn_DOS.S
;
buffsize	=	8192
;
	text
;
start:
	move.l	#buffsize,d5
	move.l	4(sp),a5		;a5-> basepage
	move.l	#$100,d6		;d6 = basepage size
	add.l	bp_textlen(a5),d6
	add.l	bp_datalen(a5),d6
	add.l	bp_bss_len(a5),d6
	add.l	d5,d6
	add.l	d5,d6
	addi.l	#64,d6			;safety bump
	lea	(a5,d6.l),sp		;temp sp in future buffer
	gemdos	Mshrink,!,(a5),d6	;release unneeded memory
	tst.l	d0
	bmi	error_exit		;refuse installation on error
;
	xbios	Iorec,!
	move.l	d0,a4			;a4-> Iorec structure for modem
	move	#256,d3			;d3 = 256 = low mark
	move	d5,d4
	add	d4,d4
	add	d5,d4
	lsr	#2,d4
	bclr	#0,d4			;d4 = even((buffsize * 3) / 4) = high mark
;
	gemdos	Super,!			;Supervisor mode
	move.l	d0,d7			;d7-> entry SSP
	move	SR,-(sp)		;push status with interrupt mask
	or	#$0700,SR		;disable all interrupts
;
;fix Iorec with disabled interrupts
	move	d5,d0			;d0 = buffer size
	clr	d1			;d1 = cleared head value
	clr	d2			;d2 = cleared tail value
	lea	buffbase(pc),a1		;a1-> Buffer 0
	move.l	a1,(a4)+		;store buffer 0 base
	movem	d0-d4,(a4)		;store buffer 0 size,head,tail,lomark,himark
	lea	2*5(a4),a4		;a4-> Iorec of Buffer 1
	lea	(a1,d5),a1		;a1-> Buffer 1
	move.l	a1,(a4)+		;store buffer 1 base
	movem	d0-d4,(a4)		;store buffer 0 size,head,tail,lomark,himark
;Iorec is fixed, ready for use
;
	move	(sp)+,SR		;pull status with interrupt mask
	gemdos	Super|_ind,d7		;restore entry SSP
;
	xbios	Rsconf,#4,!,#$90,?,?,?	;configure RS232 for 2400 bps
	gemdos	Ptermres,d6,!		;exit with buffer resident
;
error_exit:
	gemdos	Pterm,?
;
;
buffbase:
;
;-----------------------------------------------------------------------------
;End of file:	X_KBUF.S
