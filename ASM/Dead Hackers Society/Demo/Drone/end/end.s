; endscroller with ten spec4096 pics

		section	text

end_init:	rts

end_runtime_init:
		run_once
		init_finish_red

		jsr	black_pal
		jsr	clear_screens
		bsr	end_load_data
		;bsr	end_clear_background_colours

		init_finish_green

		rts





end_vbl:
		move.l	screen_adr,d0			;set screen
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		move.l	empty_adr,d0
		lea	$ffff8203.w,a0
		movep.l	d0,0(a0)

		movem.l	.pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

.pal:		dcb.w	16,$0000

end_main:	bsr	end_scroll
		rts


end_ta:

		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		dcb.w	67-29-18,$4e71			;Time for user to set up registers etc

		moveq	#2,d7				;1

		move.l	end_paladr,a0			;5
		lea	$ffff8240.w,a4			;2
		move.l	a4,a1				;1

		lea	$ffff8203.w,a6			;2
		move.l	end_gfxadr,d0			;5
		move.l	screen_adr,d1			;5
		movep.l	d0,0(a6)			;6

		move.w	#227-1,d5			;2

		rept	8				;set first palette
		move.l	(a0)+,(a1)+			;40
		endr

.speclines:	dcb.w	2,$4e71		;2
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dbra	d5,.speclines	;3 (4 when exit)
		
;special case line for preparing lower border
		;dcb.w	1,$4e71		;1
		move.l	a4,a5		;1 special case for next line
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		move.w	d7,$ffff820a.w	;3 60Hz Kill lower border
		move.l	(a0)+,(a3)+	;5
		move.b	d7,$ffff820a.w	;3 50Hz
		move.l	(a0)+,(a3)+	;5
		move.l	(a0)+,(a3)+	;5
		;dcb.w	3,$4e71
;lower border line
		;dcb.w	2,$4e71		;2
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a5)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dcb.w	3-2,$4e71
		move.w	#45,d5	;2
		

.speclines2:	dcb.w	2,$4e71		;2
		move.l	a4,a1		;1
		move.l	a4,a2		;1
		move.l	a4,a3		;1
		rept	8
		move.l	(a0)+,(a1)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a2)+	;5*8
		endr
		rept	8
		move.l	(a0)+,(a3)+	;5*8
		endr
		dbra	d5,.speclines2	;3 (4 when exit)

		moveq	#0,d0
		rept	8
		move.l	d0,(a4)+
		endr
	
		move.w	#$2300,sr
		rts
		


end_load_data:
		move.l	#end_fn,filename
		move.l	end_fl,filelength
		move.l	#buf+end_pic,filebuffer
		jsr	loader

		rts

	ifne	0
end_clear_background_colours:

		move.l	end_col1,a0
		move.l	end_col2,a1

		move.w	#273*3-1,d7
.clrbg:		clr.w	(a0)
		clr.w	(a1)
		lea	32(a0),a0
		lea	32(a1),a1
		dbra	d7,.clrbg

		rts
	endc

end_scroll:

		add.l	#160,end_gfxadr
		add.l	#96,end_paladr

		rts

		section	data

end_gfxadr:	dc.l	buf+end_pic
end_paladr:	dc.l	buf+end_pic+160*1990

end_fn:		dc.b	'data\end.4k',0
		even
end_fl:		dc.l	160*1990+(96*1990)

		rsreset
end_pic:	rs.b	160*1990+(96*1990)


		section	text


		
