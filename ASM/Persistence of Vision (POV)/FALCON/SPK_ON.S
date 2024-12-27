f030_skr_on	move.w	#%100000000000000,-(sp)	;internal speaker ON
		move.w	#$1d,-(sp)
		trap	#14
		addq.w	#4,sp
