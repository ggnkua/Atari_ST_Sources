
***************************
*    UPPRCAS, LOWRCAS	Convert string to upper/lower case
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A0 -> null-ended string to convert
*     D0: Number of characters to convert
*	or -1 for conversion until a null character is encountered
*     A1 -> destination (can be same as source)

UPPRCAS	movem.l	D0-D5/A0-A1,-(SP)
	clr.w	D1
	moveq	#'a',D2
	moveq	#'z',D3
	moveq.l	#upprcas6-upprcas5+'{',D4
	moveq.l	#$DF,D5
	bra.s	upprcas4

upprcas1	move.b	(A0)+,D1
	cmp.b	D2,D1
	bcs.s	upprcas3	Write char. below 'a' unchanged
	cmp.b	D3,D1
	bls.s	upprcas2	Standard modification of a-z
	cmp.b	D4,D1
	bcc.s	upprcas3	Write char. above table unchanged
	move.b	upprcas5-'{'(PC,D1.W),(A1)+
	bra.s	upprcas4
upprcas2	and.b	D5,D1
upprcas3	move.b	D1,(A1)+
upprcas4	dbeq	D0,upprcas1
	movem.l	(SP)+,D0-D5/A0-A1
	rts

upprcas5	dc.b '{|}~',127
	dc.b '€šƒ…€ˆ‰Š‹Œ’’“™•–—˜™š',157,'œ',157,158,159,' ¡¢£¥'
upprcas6	equ *
* Change first 157 to 155 if you don't use it for o slash like in Protext

* If you use all Atari letters, including those that clash with the IBM
* graphics characters, then uncomment this table (and remove the above one)
*upprcas5	dc.b '{|}~',127
* dc.b '€šƒ',182,'€ˆ‰Š‹Œ’’“™•–—˜™š',155,'œ',157,158,159
* dc.b ' ¡¢£¥¥¦§¨©ª«¬­®¯'
* dc.b 183,184,178,178,180,181,182,183,184,185,186,187,188,189,190,191,193
*upprcas6 equ *

*ğğğğğğğğğğğğğğğğğğğğğğğğğğ
LOWRCAS	movem.l	D0-D6/A0-A1,-(SP)
	clr.w	D1
	moveq	#'A',D2
	moveq	#'Z',D3
	moveq.l	#'€',D6
	moveq.l	#lowrcas6-lowrcas5+'€',D4
	moveq	#$20,D5
	bra.s	lowrcas4

lowrcas1	move.b	(A0)+,D1
	cmp.b	D2,D1
	bcs.s	lowrcas3	Write char. below 'A' unchanged
	cmp.b	D3,D1
	bls.s	lowrcas2	Standard modification of A-Z
	cmp.b	D6,D1
	bcs.s	lowrcas3	Write char. below '€' unchanged
	cmp.b	D4,D1
	bcc.s	lowrcas3	Write char. above table unchanged

	move.b	lowrcas5-'€'(PC,D1.W),(A1)+
	bra.s	lowrcas4
lowrcas2	or.b	D5,D1
lowrcas3	move.b	D1,(A1)+
lowrcas4	dbeq	D0,lowrcas1
	movem.l	(SP)+,D0-D6/A0-A1
	rts

lowrcas5	dc.b '‡‚ƒ„…†‡ˆ‰Š‹Œ„†‚‘‘“”•–—˜”',155,'œ',155,158,159,' ¡¢£¤¤'
lowrcas6	equ *
* Change second 155 to 157 if you don't use it for O slash like in Protext

* If you use all Atari letters, including those that clash with the IBM
* graphics characters, then uncomment this table (and remove the above one)
*lowrcas5
* dc.b '‡‚ƒ„…†‡ˆ‰Š‹Œ„†‚‘‘“”•–—˜”',155,'œ',157,158,159,' ¡¢£¤¤¦§¨©ª«¬­®¯'
* dc.b 176,177,179,179,180,181,'…',176,177,185,186,187,188,189,190,191,192,192
*lowrcas6 equ *
