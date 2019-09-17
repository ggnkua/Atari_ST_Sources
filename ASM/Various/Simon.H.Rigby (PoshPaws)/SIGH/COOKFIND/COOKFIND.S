	include macro_v1.i
	
	Prog_shrink 1024	;shrink program and setup 1K stack

	Cconout	#27		;clear screen
	Cconout	#VT_CLS
	
	move.l	Basepage,a0
	bsr	Read_cmdlin	;get cookie required from command line

; OFFENDING LINES - NOT NECESSARILY WORD ALIGNED
;	move.l	(a0),cookie
;	move.l	(a0),d0
; USE THE FOLLOWING INSTEAD!
	move.l	#cookie,a1
	move.b	(a0),(a1)+	;get cookie
	move.b	(a0),(a1)+
	move.b	(a0),(a1)+
	move.b	(a0),(a1)+

	move.l	cookie,d0		;get cookie value in d0
	bsr	Get_cookie
	tst.w	d0		;0 if successful
	beq.s	passed		;else print "cookie not found"
	Cconws	#fail_str
	bra	end
	
passed	move.l	d1,cookval	;safe from OS calls
	move.l	cookie,title_str+22
	Cconws	#title_str
	move.l	cookval,d0
	move.w	#32,d1			;bits to convert
	move.l	#title1_str+17,a0
	bsr	Bin_str			;long to binary string 
	Cconws	#title1_str
	move.l	cookval,d0
	move.w	#4,d1			;bytes to convert
	move.l	#title2_str+17,a0
	bsr	Hex_str
	Cconws	#title2_str
	Cconout	#CR
	Cconout	#LF
end	Cconin
	Prog_exit
	
	include	g_cookie.s
	include read_cmd.s	
	include bin_str.s
	include	hex_str.s
	
		DATA
		even
fail_str	dc.b	"Cookie not found!",13,10,0
title_str	dc.b	13,10,"Looking for Cookie: XXXX",0
title1_str	dc.b	13,10," Binary Value: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",0
title2_str	dc.b	13,10,"    Hex Value: XXXXXXXX",0
		
		BSS
		even
cookie		ds.l	1	;cookie looking for
cookval		ds.l	1	;value of cookie
