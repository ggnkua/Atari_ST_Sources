max	equ	4	Number of digits reqd

;Enter hex number (1-8 digits)
;ENTRY Text cursor positioned
;      #max = number of hex digits required
;EXIT  d1.l = hex number
;      d0   = last hex value if all digits entered or last key pressed if not
;      d2   = actual number of digits entered

inp_hex	clr.l	d1	initialise d1
	clr.l	d2	initialise digit count
inp_hex2	bsr	hex_digit	get next hex digit
	bcs	inp_hex1	abort if not hex
	lsl.l	#4,d1	shift left * 4
	or.b	d0,d1	copy value to d1
	add	#1,d2	inc digit count
	cmp	#max,d2	all done (see text)
	bne	inp_hex2	loop if not
inp_hex1	rts

;Enter one hex digit
;ENTRY Text cursor positioned as required
;EXIT  if Cy flag = 0, d0=hex digit (00-0F) and chr displayed
;      if Cy flag = 1, d0 key value (01-7F) and no chr displayed

hex_digit	bsr	keybrd	fetch char
	cmp.b	#'0',d0	is it <'0'
	blt	hex_digit1	yep so branch
	cmp.b	#'9',d0	is it >'9'
	bgt	hex_digit2	yep so branch
	bsr	chr_out	display char if valid
hex_digit5	and	#$f,d0	mask off high bits
	and	#$fffe,ccr	clr C
hex_digit6	rts

hex_digit2	cmp.b	#'A',d0	is it <'A'
	blt	hex_digit1	yep so branch
	cmp.b	#'F',d0	is it >'F'
	bgt	hex_digit3	yep so branch
	sub.b	#'A'+6,d0	adjust value
	bra	hex_digit5	and exit

hex_digit3	cmp.b	#'a',d0	is it <'a'
	blt	hex_digit1	yep so branch
	cmp.b	#'f',d0	is it >'f'
	bgt	hex_digit1	yep so branch
	bsr	chr_out	display char if valid
	sub.b	#'a'+6+32,d0	adjust value
	bra	hex_digit5	and exit
	
hex_digit1	or	#1,ccr	set Cy
	bra	hex_digit6
