; In: D0.w - x1
;     D1.w - y1
;     D2.w - x2
;     D3.w - y2
;     D4.w - Farbe

tc_line:
		cmp.w   D2,D0					;always left to right
		ble.s   noother
		exg     D0,D2
		exg     D1,D3
noother:
		move.l  #SCR_W*SCR_D,D7				;Y-Inc (Length of a Scanline)

		movea.l screen_buffer,A2			;get Screenadr.
		sub.w   D0,D2					;dx
		add.w   D0,D0					;*2
		adda.w  D0,A2					;X-Screenadr.
 
		sub.w   D1,D3					;dy
		bpl.s   noabs2					;positve?
		neg.w   D3
		neg.l   D7					;then Y-Inc must be Y-Dec
noabs2:

;		muls    #640,D1
;		adda.l  D1,A2					;Pixel-Screenadr.
;								;alt. you could use
;								;add.l (multab.l,pc,d1*4),a2
		adda.l	(mul_y,PC,d1.w*4),A2

 
		cmp.w   D2,D3					;dy>dx?
		bgt.s   moredy

moredx:
		move.w  D3,D1					;d = 2*dy-dx
		add.w   D1,D1
		move.w  D1,D5					;inc1=2*dy
		sub.w   D2,D1
		move.w  D1,D6					;inc2=2*(dy-dx)
		sub.w   D2,D6
 
		tst.w   D1					;init flags in the first run
setline_mdx:
		bpl.s   incy
incx:
		move.w  D4,(A2)+				;SetPix & X-Add
		add.w   D5,D1					;d=d+inc1
		dbra    D2,setline_mdx				;doesn't change flags
		rts
incy:
		move.w  D4,(A2)+				;SetPix & X-Add
		adda.l  D7,A2					;Y-Add
		add.w   D6,D1					;d=d+inc2
		dbra    D2,setline_mdx				;doesn't change flags
		rts

moredy:
		move.w  D2,D1					;d = 2*dx-dy
		add.w   D1,D1
		move.w  D1,D5					;inc1=2*dx
		sub.w   D3,D1
		move.w  D1,D6					;inc2=2*(dx-dy)
		sub.w   D3,D6
 
		tst.w   D1
setline_mdy:
		bpl.s   incy2
incx2:
		move.w  D4,(A2)					;SetPix
		adda.l  D7,A2					;Y-Add
		add.w   D5,D1					;d=d+inc1
		dbra    D3,setline_mdy				;doesn't change flags
		rts
incy2:
		move.w  D4,(A2)+				;SetPix & X-Add
		adda.l  D7,A2					;Y-Add
		add.w   D6,D1					;d=d+inc2
		dbra    D3,setline_mdy				;doesn't change flags
		rts