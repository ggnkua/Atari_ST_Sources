;+
;  Scan for '\r\n' or '\n'
;
;  Synopsis:	int scannl(ptr, count)
;		char *ptr;	/* -> start of line */
;		int count;	/* #chars max */
;
;  Returns:	number of characters in line at 'ptr' (including null)
;		zero if the line doesn't complete
;		the line null-terminated if it completed
;
;  Uses:	D0-D2/A0-A2
;
;		D0	#chars in line
;		D1	temp
;		D2	#chars max
;		A0 ->	line
;		A1
;		A2
;
;-
_scannl:: .cargs .ptr.l, .count.w
	move.w	d3,.temp		; save D3
	move.l	.ptr(sp),a0		; A0 -> line
	move.w	.count(sp),d2		; D2 = max #chars

	moveq	#'\r',d0		; D0 = code for '\r'
	moveq	#'\n',d3		; D3 = code for '\n'
	bra.s	.lbot			; leap into loop

.loop:	move.b	(a0)+,d1		; get next char
	cmp.b	d0,d1			; carriage-return?
	beq.s	.cr			;
	cmp.b	d3,d1			; newline?
	beq.s	.nl			;
.lbot:	dbra	d2,.loop		; loop for more characters
.punt:	moveq	#0,d0			; line didn't complete
	move.w	.temp,d3		; restore D3
	rts				;    (return 0)

;
;  Got \r, so assume next character is \n (and eat it).
;  If \r occurs as the last character of the buffer, return 0 (we
;   need to check for a \n in the next quantum we read from disk).
;
.cr:	dbra	d2,.cr1			; any chars left?
	bra	.punt			; no --- need to eat \n, so punt
.cr1:	clr.b	-1(a0)			; replace \r with a null
	addq	#1,a0			; advance to next char
	move.l	a0,d0			;
	sub.l	.ptr(sp),d0		; D0 = #chars we used
	move.w	.temp,d3		; restore D3
	rts				;

;
;  Got \n.  Terminate the line and #characters eaten.
;
.nl:	clr.b	-1(a0)			; replace \n with a null
	move.l	a0,d0			;
	sub.l	.ptr(sp),d0		; D0 = #chars we used
	move.w	.temp,d3		; restore D3
	rts				;


    BSS
.temp:	ds.w	1
