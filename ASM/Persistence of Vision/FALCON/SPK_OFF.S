f030_skr_off	move.w	#%1000000,-(sp)	;internal speaker OFF
		move.w	#$1e,-(sp)
		trap	#14
		addq.w	#4,sp
