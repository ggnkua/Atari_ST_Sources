
save_vecteur	macro
	move.b	$fffffa07.w,(\1)+ 	
	move.b	$fffffa09.w,(\1)+
	move.b	$fffffa13.w,(\1)+
	move.b	$fffffa15.w,(\1)+
	move.b	$fffffa19.w,(\1)+
	move.b	$fffffa1f.w,(\1)+
	move.l	$134,(\1)+
	move.l	$70.w,(\1)+
	move.b	$ff8201,(\1)+
	move.b	$ff8203,(\1)+
	move.b	$ff820d,(\1)+
	move.b	$ff8265,(\1)+
	move.b	$ff820f,(\1)+
	endm

clear_vecteur	macro	
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w		
	clr.b	$fffffa15.w
	clr.b	$fffffa13.w
	endm

load_vecteur	macro	
	move.b	(\1)+,$fffffa07.w
	move.b	(\1)+,$fffffa09.w
	move.b	(\1)+,$fffffa13.w
	move.b	(\1)+,$fffffa15.w
	move.b	(\1)+,$fffffa19.w
	move.b	(\1)+,$fffffa1f.w
	move.l	(\1)+,$134
	move.l	(\1)+,$70.w
	move.b	(\1)+,$ff8201
	move.b	(\1)+,$ff8203
	move.b	(\1)+,$ff820d
	move.b	(\1)+,$ff8265
	move.b	(\1)+,$ff820f
	endm

vbl	macro
	move.l	#\1,$70.w
	endm
