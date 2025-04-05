
		section	text

end_init:
		cmp.w	#1,monitor
		bne.s	.notrgb
		move.l	#72*500,end_ofs
.notrgb:
		lea.l	endenv_texture+20,a0
		lea.l	end_pal,a1
		bsr.w	conv_apxpal_to_falcpal

		lea.l	end_pal+64*4,a0
		lea.l	end_pal+128*4,a1
		lea.l	end_pal+192*4,a2
		lea.l	end_pal,a3
		move.w	#64-1,d7
.colfill:
		;move.l	#$22220022,(a0)+
		move.l	(a3)+,(a0)+
		move.l	#$99990099,(a1)+
		move.l	#$dddd00dd,(a2)+
		dbra	d7,.colfill
		move.l	#$22220022,end_pal+64*4
		rts


end_runtime_init:
		bsr.w	clear_all_screens
		bsr.w	endenv_runtime_init
		
		rts


end_timer:
		bsr.w	endenv_timer
		rts


end_vbl:
		subq.w	#1,.wait
		bne.s	.nofade
		move.w	#4,.wait
		
		lea.l	end_blackpal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal

		cmp.l	#1,vbl_param
		beq.s	.fadeout

		lea.l	end_blackpal,a0
		lea.l	end_pal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
		bra.s	.nofade
.fadeout:	lea.l	end_blackpal,a0
		lea.l	end_blackpal2,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
.nofade:
		bsr.w	end_scroller_update
		
		rts
.wait:		dc.w	4
		
end_main:
		bsr.w	real3d_chunkyclear_320x180
		bsr.w	endenv_main

		lea.l	chunky,a0
		move.l	screen_adr,a1
		add.l	#320*30,a1
		move.l	#320*180,BPLSIZE
		bsr.w	c2p_6pl

		rts

end_scroller_update:
		move.l	screen_adr1,a0
		lea.l	12+320*30+16(a0),a0
		lea.l	end_scroller,a1
		add.l	end_ofs,a1
		
		cmp.l	#(4500+1080)*72,end_ofs
		ble.s	.add
		clr.l	end_ofs
		bra.s	.noadd
.add:		add.l	#72,end_ofs
.noadd:
		move.l	#16,d0
		move.l	#32,d1
		move.l	#72,d2
		move.w	#180-1,d7
.y:		move.w	#18-1,d6
.x:
		move.l	(a1)+,(a0)
		add.l	d0,a0
		
		dbra	d6,.x
		add.l	d1,a0
		add.l	d2,a1
		dbra	d7,.y

		rts
end_ofs:	dc.l	0

		include	'end\endenv.s'


endlogo_runtime_init:
		lea.l	endlogo_data+20,a0
		lea.l	endlogo_pal,a1
		bsr.w	conv_apxpal_to_falcpal

		bsr.w	clear_all_screens

		lea.l	endlogo_data+788,a0
		move.l	screen_adr,a1
		add.l	#640*60,a1
		move.l	#640*360,BPLSIZE
		bsr.w	c2p_8pl

		lea.l	endlogo_whitepal,a0
		move.l	#$aaaa00aa,d0
		move.w	#256-1,d7
.loop:		move.l	d0,(a0)+
		dbra	d7,.loop


		rts

endlogo_vbl:
		subq.w	#1,.wait
		bne.s	.done
		move.w	#4,.wait
		
		lea.l	endlogo_whitepal,a0
		move.w	#256-1,d0
		bsr.w	falcon_setpal

		cmp.l	#1,vbl_param
		beq.s	.fadeout
				
		lea.l	endlogo_whitepal,a0
		lea.l	endlogo_pal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
		bra.s	.done
		
.fadeout:	lea.l	endlogo_whitepal,a0
		lea.l	endlogo_blackpal,a1
		move.w	#256-1,d0
		bsr.w	falcon_fade
.done:		rts
.wait:		dc.w	4


		section	data

endlogo_data:	incbin	'end\logo01.apx'

end_scroller:	ds.b	72*360*3
		incbin	'end\endscrol.2pl'
		ds.b	72*360
		even

		section	bss

endlogo_pal:	ds.l	256
endlogo_blackpal:ds.l	256
endlogo_whitepal:ds.l	256
end_pal:	ds.l	256
end_blackpal:	ds.l	256
end_blackpal2:	ds.l	256

		section	text