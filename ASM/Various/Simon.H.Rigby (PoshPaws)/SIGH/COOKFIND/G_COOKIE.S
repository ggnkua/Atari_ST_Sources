;Get the value of a Cookie, if Cookie Jar exists
;ENTRY:	D0 = Cookie to look for (e.g. #"_SND")
;EXIT:	D0 = 0 if found, -1 if not found
;	D1 = Value of cookie (or zero if not found)
;USES:	Registers d0-d1/a0

		TEXT
Get_cookie	move.l	d0,Get_cook_cook
		move.l	#Get_cookie_sub,-(sp)
		move.w	#38,-(sp)
		trap	#14		;execute in supervisor mode
		addq.w	#6,sp
		movem.l	Get_cook_cook,d0-d1
		rts

Get_cookie_sub	move.w	#$5a0,a0	;cookie pointer
		move.l	Get_cook_cook,d0
		clr.l	d1		;empty value
		tst.l	(a0)		;any cookie jar?
		beq.s	Get_cookie_fail
		move.l	(a0),a0		;cookie_jar
Get_cookie_lp	move.l	(a0)+,d1	;cookie val
		cmp.l	d0,d1		;one we want?
		beq.s	Get_cookie_ok
		tst.l	d1
		beq.s	Get_cookie_fail	;end of list
		addq.w	#4,a0		;next cookie
		bra.s	Get_cookie_lp
Get_cookie_ok	move.l	(a0)+,Get_cook_data	;cookie value
		clr.l	Get_cook_cook		;value valid
		rts		
Get_cookie_fail	move.l	#-1,Get_cook_cook
		rts

		BSS
Get_cook_cook	ds.l	1	
Get_cook_data	ds.l	1
