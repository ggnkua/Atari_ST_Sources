
;--------------------------------------------------------------------
; XBIOS MACRO FUNCTIONS
;--------------------------------------------------------------------

X_INITMOUSE	macro	(mode.w,params.l,vector.l)
		move.l	\3,-(sp)
		move.l	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#1,-(sp)
		trap	#14
		lea	12(sp),sp
		endm

X_FLOPRD	macro	(buf.l,device.w,sector.w,track.w,side.w,numsecs.w)
		move.w	\6,-(sp)
		move.w	\5,-(sp)
		move.w	\4,-(sp)
		move.w	\3,-(sp)
		move.w	\2,-(sp)
		clr.l	-(sp)
		move.l	\1,-(sp)
		move.w	#8,-(sp)
		trap	#14
		lea	20(sp),sp
		endm

X_FLOPWR	macro	(buf.l,device.w,sector.w,track.w,side.w,numsecs.w)
		move.w	\6,-(sp)
		move.w	\5,-(sp)
		move.w	\4,-(sp)
		move.w	\3,-(sp)
		move.w	\2,-(sp)
		clr.l	-(sp)
		move.l	\1,-(sp)
		move.w	#9,-(sp)
		trap	#14
		lea	20(sp),sp
		endm

X_FLOPFMT	macro	(buf.l,skewtab.l,device.w,spt.w,
;			track.w,side.w,inter.w,magic.l,initial.w)
		move.w	\9,-(sp)
		move.l	\8,-(sp)
		move.w	\7,-(sp)
		move.w	\6,-(sp)
		move.w	\5,-(sp)
		move.w	\4,-(sp)
		move.w	\3,-(sp)
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#10,-(sp)
		trap	#14
		lea	26(sp),sp
		endm

X_MIDIWS	macro	(bytes.w,buffer.l)
		move.l	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#12,-(sp)
		trap	#14
		addq.w	#8,sp
		endm

X_RANDOM	macro
		move.w	#17,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

X_PROTOBT	macro	(buffer.l,serialnum.l,disktype.w,exexflag.w)
		move.w	\4,-(sp)
		move.w	\3,-(sp)
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#18,-(sp)
		trap	#14
		lea	14(sp),sp
		endm

X_FLOPVER	macro	(buf.l,device.w,sector.w,track.w,side.w,numsecs.w)
		move.w	\6,-(sp)
		move.w	\5,-(sp)
		move.w	\4,-(sp)
		move.w	\3,-(sp)
		move.w	\2,-(sp)
		clr.l	-(sp)
		move.l	\1,-(sp)
		move.w	#19,-(sp)
		trap	#14
		lea	20(sp),sp
		endm

X_IKBDWS	macro	(bytes.w,buffer.l)
		move.l	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#25,-(sp)
		trap	#14
		addq.w	#8,sp
		endm

X_KBDVBASE	macro
		move.w	#34,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

X_VSYNC		macro
		move.w	#37,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

X_SUPEXEC	macro	(sub.l)
		move.l	\1,-(sp)
		move.w	#38,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

X_BLITMODE	macro	(value.w)
		move.w	\1,-(sp)
		move.w	#64,-(sp)
		trap	#14
		addq.w	#4,sp
		endm
