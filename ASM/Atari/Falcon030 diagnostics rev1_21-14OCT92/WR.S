;	.include hardware
;	.include defs
;	.include nvram

	.text
	.globl	comlin
	.globl	testexp
	.globl	getcmd,hexchr	; used by rtc.s

*	Dec 4, 87  correct bug in read byte (it was reading word)
*	Feb 3, 87  edit for madmac
*	Nov 25, 86 -- subroutine, no absolute ref. Added separate getbuf
*		because of special characters in menu getbuf.
*	March 7, 1986
*	This procedure allows the operator to create simple command
*	lines to read and write specified locations in the ST.

*	Format is: operator,<delimiter>,address,delimiter,address,
*		delimiter,data
*		operator: W, R or RW
*		address: 1-6 Hexidecimal characters
*		delimiter: non-alphanumeric. In W cmd, = means data to follow.
*		data: 2-4 digits. >2 digits implies word access.
*	Example: R1000,10ff	read 1000--10ff
*		 RW 2345	read word from address 2345
*		 WFF8200=2	write $ff8200, data=2
*		 W2000,3000=0	write 2000-3000, data=0

wrmem:	bsr	clearsc
	lea	cmdhdr,a5
	bsr	dspinv
	
comlin:	lea	prompt,a5
	bsr	dspmsg
	bsr	getcmd		;get a buffer from the consol
*				;a4=last entry, keybuf=first entry
	lea	keybuf,a2	;point to start of line
	move.b	#$ff,wrflg	;set a flag so we can return here
*				;in case of a bus error
comln1:	cmpa.l	a2,a4
	beq.s	badcmd0		;br no cmd in buffer
	move.b	(a2)+,d0	;get a command operator (in order entered)
	cmpi.b	#esc,d0
	beq.s	comx
	cmpi.b	#'?',d0
	beq	comhelp
	cmpi.b	#'W',d0
	beq.s	wrtlin
	cmpi.b	#'R',d0
	beq	rdlin
	cmpi.b	#'X',d0
	beq	testexp0
	bne.s	comln1		;if still in buffer, keep looking for cmd

*	Bad command
badcmd0:
	lea	badcom0,a5	;must be W or R
badcmd:	bsr	crlf
	bsr	dspmsg	
	bra.s	comlin

badcmd1:
	lea	badcom1,a5	;bad address
	bra.s	badcmd
badcmd2:
	lea	badcom2,a5	;no = following addr2
	bra.s	badcmd
badcmd3:
	lea	badcom3,a5	;data is bad
	bra.s	badcmd

*	Return to calling sequence
comx:	clr.b	wrflg
	rts

testexp0:
	bsr	testexp
	bra	comlin

********************************
*	W command
*	Get start address
wrtlin:	bsr	getadd		;get an address
	bne.s	badcmd1		;br if address no good
	move.l	a0,addr1	;save end address
	move.l	a0,addr2
	add.l	#1,addr2	;default end address = start + 1
	cmpi.b	#'=',d0
	beq.s	wrtln1		;data to follow

*	Get end address
	bsr	getadd
	bne.s	badcmd1
	move.l	a0,addr2	;save end address
	cmpi.b	#'=',d0		;data to follow
	bne.s	badcmd2		;= must follow end address		

*	Get data to write
wrtln1:	bsr	getnum		;return data d1, size d3
	bne.s	badcmd3
	
	move.l	addr1,a4

*	Write data, byte or word
wrtl1:	cmpi.b	#2,d3		;how many digits (byte or word size)?
	bgt.s	wrtl2		;br word size
	move.b	d1,(a4)+	;fill memory until at end
	bra.s	wrtl3
wrtl2:	move.w	d1,(a4)+

wrtl3:	bsr	constat		;let key abort 
	tst	d0
	bne	comlin
	bsr	rsstat
	tst	d0
	bne	comlin	

	cmpa.l	addr2,a4
	ble.s	wrtl1
	bra	comlin

********************************
*	Read command
rdlin:	move.b	(a2)+,d3
	cmpi.b	#'W',d3		;word size?
	beq.s	rdln1
	move.b	-(a2),d3	;replace 	
rdln1:	bsr	getadd		;get start address
	bne	badcmd1
	move.l	a0,addr1
	move.l	a0,addr2	;default end address=start, if byte size
	cmpi.b	#'W',d3
	bne.s	rdlinb
	add.l	#1,addr2	;if word, end address=start+1
	bra.s	rdlin0		;br if read word
rdlinb:	tst.b	(a2)		;more in buffer?
	beq.s	rdlin0
	bsr	getadd		;get end address
	bne	badcmd1
	move.l	a0,addr2

*	Read bytes
rdlin0:	movea.l	addr1,a4

rdlin1:	moveq	#15,d0		;start a new line
	bsr	crlf

*	Loop to display 16 bytes on a line
rd16:	move.l	a4,d1		;page boundary?
	tst.b	d1
	bne.s	rd16a

*	Display address at page boundary
	bsr	crlf
	movea.l	a4,a0
	bsr	dspadd		;display address
	bsr	crlf

*	Read byte or word
rd16a:	cmpi.b	#'W',d3
	bne.s	rd16b
	move.w	(a4)+,d1	;read a word
	bsr	dspwrd
	bra.s	rd16c
rd16b:	move.b	(a4)+,d1	;read a byte
	bsr	dspbyt		;and display it
rd16c:	bsr	dspspc
	cmpa.l	addr2,a4	;until at end
	bgt.s	rdlin2

	dbra	d0,rd16		;br this line (8 bytes)

*	End of line (8 bytes)
	bsr	constat		;let key abort it
	tst	d0
	bne.s	rdkey
	bsr	rsstat
	tst	d0
	bne.s	rdkey
	bra.s	rdlin1

rdlin2:	bsr	crlf
	bra	comlin

*	Got a key. escape or pause
rdkey:	movea.l	a4,a0
	suba.l	#1,a0	
	bsr	dspadd		;display last address
	bsr	conin
	cmpi.b	#esc,d0		;esc?
	beq	comlin		;quit
	bsr	conin		;pause
	bra.s	rdlin1		;continue

********************************
*	Display help
comhelp:
	bsr	clearsc
	lea	chelpm,a5
	bsr	dspmsg
	bra	comlin
********************************

*-------------------------------
*	Get and save keystrokes in KEYBUF until RETURN key.	
*	Buffer is 32 characters max. BS erases previous key.
*	Video 50/60 and HELP are immediate action (no cr).
*	Exit:	a4=pointer to key buffer +1
*		d0 eq if buffer full or empty
getcmd:	lea	keybuf,a4
	moveq	#63,d0		;clear keybuf,tstbuf, and numbuf
getcd0:	clr.b	(a4)+		;clear buffers
	dbra	d0,getcd0
	lea	keybuf,a4
	bsr	kbempty		;clear keystrokes

getcm0:	bsr	conin		;get some input
	cmpi.b	#esc,d0
	bne.s	getcm1
	move.b	d0,(a4)+	;save esc
	rts			;ret immed.
	
getcm1:	cmpi.b	#8,d0		;backspace?
	bne.s	getcm2

*	Process backspace
	cmpa.l	#keybuf,a4
	beq.s	getcm0		;all backed up 
	bsr	bckspc		;erase screen char.
	clr.b	-(a4)		;backup ptr and write term. char.
	bra.s	getcm0

getcm2:	cmpi.b	#$d,d0		;return?
	beq.s	getcm6
	
*	Save character and display
getcm3:	move.b	d0,(a4)+	;save key in buffer
	move.b	d0,d1
	bsr	ascii_out	;display character
	cmpa.l	#keybuf+31,a4
	ble.s	getcm0		;get more or, if full, quit
	lea	fullbuf,a5
	bsr	dspmsg
getcm4:	moveq	#0,d0		;empty (cr only)
	rts

*	Got return key
getcm6:	cmpa.l	#keybuf,a4	;anything in buffer?
	beq.s	getcm4
	tst.b	d1		;key or RS232?
	beq.s	getcm7		;br if RS232
	cmpi.b	#$9c,brkcod	;wait for return break
	beq.s	getcm7
	cmpi.b	#$f2,brkcod	;or enter break
	bne.s	getcm6
getcm7:	rts			
	
*-------------------------------
*	Get an address
*	First character may or not be a number
*	Entry:	(a2)=next character (must be 0-9/a-f)
*	Exit:	a0=address, d0=next character (delimiter)
*		ret ne on error
*	Alters:	d0,d1,d2,d7,a2
getadd:	clr.l	d0
	clr.l	d1
	clr.l	d2
	move.b	(a2)+,d0	;read first one
	bsr	hexchr		
	beq.s	getad2		;save it if digit, else waste it
getad1:	move.b	(a2)+,d0	;next character
	beq.s	gadd1		;nothing, end
	bsr	hexchr		;test range and do conversion
	bne.s	gadd1		;br if delimiter	
getad2:	lsl.l	#4,d1		;shift to make room for new digit
	or.l	d0,d1		;save new digit
	addq	#1,d2
	bra.s	getad1

gadd1:	tst.l	d2		;what did we get?
	beq.s	gadder		;nothing, error
	move.l	d1,a0
	moveq	#0,d7
	rts			;ret eq

gadder:	moveq	#$ff,d7
	rts			;ret ne

*-------------------------------
*	Get valid number from key buffer
*	Get bytes until got 0
*	Entry:	a2=pointer
*	Exit:	d1.w=number
*		d3=# of digits
*		a2 is advanced to delimiter +1
*		ret eq if good
*	Alters:	d0,d1,d3,d7,a2
getnum:	clr.l	d3		;digit counter
	clr.l	d1
gtnum1:	move.b	(a2)+,d0	;get a character (digit)
	bsr	hexchr		;return low nibble if ok
	bne.s	gtnum2		;br not valid
	lsl.l	#4,d1		;make room for new digit
	or.b	d0,d1		;combine 2 nibbles
	addq	#1,d3
	bra.s	gtnum1

gtnum2:	tst.b	d3
	bne.s	gtnum3
	moveq	#$ff,d7		;no valid characters
	rts
gtnum3:	moveq	#0,d7
	rts

*-------------------------------
*	Check for valid ascii hex character
*	Convert to hex. Note: must preserve upper data
*	Entry:	d0=ascii
*	Exit:	d0(nibble)=hex, eq if good
*		high nibble is cleared
*	Alters:	d0,d7
hexchr:	
	cmpi.b	#$30,d0
	blt.s	hexch1
	cmpi.b	#$39,d0
	bgt.s	hexch2		;$30<=d0<=$39 is ok
	andi.b	#$ffffff0f,d0
	moveq	#0,d7		;ret eq
	rts

hexch2:	cmpi.b	#$41,d0
	blt.s	hexch1		;$41<=d0<=$46 is ok ($A-F)
	cmpi.b	#$46,d0
	bgt.s	hexch1
	andi.b	#$ffffff0f,d0
	addi.b	#1,d0		;convert to hex
	ori.b	#8,d0
	moveq	#0,d7		;ret eq
	rts
hexch1:	moveq	#$ff,d7		;ret ne
	rts

*********************************
	.data

*		 0123456789012345678901234567890123456789
cmdhdr:	dc.b	tab,invtog,'Write/Read Memory Utility',invtog,cr,lf
	dc.b	tab,'Type ? for help, hit ESC key to exit.',cr,lf
	dc.b	tab,'Altering system memory ($8-$400), or system stack ($1ff00-20000)',cr,lf 
	dc.b	tab,'may cause a crash or unusual behavior.',cr,lf
	dc.b	tab,'Byte access of a word-size register will cause a bus error.',cr,lf,eot

prompt:	dc.b	cr,lf,'>',eot
badcom0: dc.b	'Not a valid command: W,R,RW,?,<esc>',cr,lf,eot
badcom1: dc.b	'Invalid address given.',cr,lf,eot
badcom2: dc.b	'No "=" in write command',cr,lf,eot
badcom3: dc.b	'Invalid data in write command',cr,lf,eot

*		 0123456789012345678901234567890123456789
chelpm:	dc.b	'Commands are: W-write memory, R-read byte, RW-read word.',cr,lf
	dc.b	'Syntax:',cr,lf
	dc.b	'W (address)<,address>=(data).',cr,lf
	dc.b	'  Second address is optional.',cr,lf
	dc.b	'  Data Size determines Byte/Word write',cr,lf
	dc.b	'R (address)<,address>',cr,lf
	dc.b	'RW (address)',cr,lf
	dc.b	'Address can be 1-6 hexadecimal digits',cr,lf
	dc.b	'Data can be 1-4 hexadecimal digits',cr,lf
	dc.b	cr,lf
	dc.b	'Examples:',cr,lf
	dc.b	'  W 200=3 writes 3 into location 200',cr,lf
	dc.b	'  W7000,7FFF=0 writes 0 into 7000-7FFF',cr,lf 
	dc.b	'  W500=377 writes 0377 into 500 (word)',cr,lf
	dc.b	'  RW FF8200  reads a word from FF8200',cr,lf	
	dc.b	'  R2000 3000 reads locations 2000 through 3000',cr,lf,eot

