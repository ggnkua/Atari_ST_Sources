	export do_devc_e44
	export do_devc_e22
	export do_devc_i48
	export do_devc_i32
	export do_devc_i24
	export do_devc_i16

do_devc_e44:
	move.l	#$63b42080,$ffff8930.w
	move.w	#$0101,$ffff8934.w
	rts
do_devc_e22:
	move.l	#$63b42080,$ffff8930.w
	move.w	#$0301,$ffff8934.w
	rts

do_devc_i48:
	move.l	#$01942080,$ffff8930.w
	move.w	#$0001,$ffff8934.w
	rts
do_devc_i32:
	move.l	#$01942080,$ffff8930.w
	move.w	#$0002,$ffff8934.w
	rts
do_devc_i24:
	move.l	#$01942080,$ffff8930.w
	move.w	#$0003,$ffff8934.w
	rts
do_devc_i16:
	move.l	#$01942080,$ffff8930.w
	move.w	#$0005,$ffff8934.w
	rts


