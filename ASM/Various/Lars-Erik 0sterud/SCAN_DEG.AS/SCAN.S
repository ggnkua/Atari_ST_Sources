	 	opt o+

start:		bra inst_scan			;Jump to main routine
		dc.b 'XBRA','SCAN'		;Xbra identification
old_vector:	ds.l 1

resident:	move.l old_vector(pc),a1	;get old_vector adress
		jsr (a1)			;execute normal bconin
get_shift:	btst #3,$000.W			;get shift status
		beq.s end_rout			;No - Return from call
		cmp.b #27,d0			;ESC pressed
		beq.s scan_image		;Yes - Goto scan mode
end_rout:	rts				;No - Return from call

scan_image:	movem.l	d0-7/a0-6,-(sp)		;Save regs
		dc.w	$A00A			;Hide Mouse
		bsr.s	print_text		;Copyright info
		movea.l $44E.w,a0		;Screen adress

		move.b	#8,d5			;For btst of roller
		move.b	#1,d3			;For btst of data
		move.w	#399,d7			;400 lines/screen

		lea	$FB0000,a1		;Status & Roller pos
		lea	$FB1000,a2		;Data request
		lea	$FB2001,a3		;Data receive

		move.b	#$13,$FFFFFC02.W	;Shut off keyboard
		move.w	#$2700,sr		;Interrupts off
		tst.w	$FB4000			;Scanner light on
		
scan_line:	moveq	#79,d6			;80 bytes/line
wait_roller:	move.w	(a1),d2			;Get roller status
		btst.l	d5,d2			;Has roller moved
		bne.s	wait_roller		;No, wait for move
get_blank:	tst.w	(a2)			:Ask for data
wait_blank:	btst.b	d3,(a1)			;Data ready ?
		beq.s	wait_blank		;No, wait for blank
get_data:	tst.w	(a2)			;Ask for data
wait_data:	btst.b	d3,(a1)			;Data ready ?
		beq.s	wait_data		;No, wait for data
		move.b	(a3),(a0)+		;Move data to screen
		dbf.w	d6,get_data		;Ask for more data
		dbf.w	d7,scan_line		;Wait for next line
		
end_scan:	tst.w	$FB3000			;Scanner light off
		move.w	#$2300,sr		;Interrupts on
		move.b	#$11,$FFFFFC02.W	;Keyboard on again
		dc.w	$A009			;Show Mouse
		movem.l	(a7)+,d0-7/a0-6		;Restore regs
		move.l  #$390000,d0		;Clear char/scan
		rts				;Return to program

print_text:	lea	tekst2(pc),a6		;Info text
		clr.w	d7
next_char:	move.b	(a6)+,d7		;End of text ?
		beq.s	end_text		;Yes, stop
		move.w	d7,-(sp)		;Char to print
		move.l	#$030002,-(sp)		;Bconout 2
		trap	#13			;Bios
		addq.l	#6,sp
		bra.s	next_char		;Next char
end_text:	rts

tekst2:		dc.b	27,'j',27,'H',27,'b'
inv:		dc.b	'1',27,'c0'
		dc.b	27,'J',10,'  GeniScan¿ scanner interface',13,10,10
		dc.b	'  ',$BD, ' Lars-Erik ²sterud 02/1991'
		dc.b	27,'b1',27,'c0',27,'k'
tekst:		dc.b	27,'Y%   Press ALT-ESC to scan image',13,10,10,10,0
 
super_rout:	move.l	$4F2.W,A0		;Get _sysbase
		move.w	$26(A0),get_shift+4	;Set kbshift adress
		move.l	$53E+2*4.W,old_vector	;Save old bconin(2) vector
		move.l	#resident,$53E+2*4.W	;Set new bconin(2) vector
		rts
						 
inst_scan:	pea	super_rout(pc)		;Things to do in supervisor
		move.w	#38,-(sp)		;Super
		trap	#14			;Xbios
		addq.l	#6,sp 

		bsr	print_text		;Print text
		move.l	#$301B6331,inv		;Set negative colors
		clr.b	tekst			;New end of text

		clr.w	-(sp)
		move.l	#$101+tekst-start,-(sp)	;Protect resident & tables
		move.w	#$31,-(sp)
		trap	#1
