
;--------------------------------------------------------------------
; GEMDOS MACRO FUNCTIONS
;--------------------------------------------------------------------

G_PTERM0	macro
		clr.w	-(sp)
		trap	#1
		endm

G_WAITCHARECHO	macro
		move.w	#1,-(sp)
		trap	#1
		addq.w	#2,sp
		endm

G_SENDCHAR	macro	(char.w)
		move.w	\1,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.w	#4,sp
		endm

G_GETCHAR	macro	(char.w) (255=receive)
		move.w	\1,-(sp)
		move.w	#6,-(sp)
		trap	#1
		addq.w	#4,sp
		endm

G_WAITCHAR	macro
		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp
		endm

G_WRITESTRING	macro	(string.l)
		move.l	\1,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_READSTRING	macro	(buffer.l)
		move.l	\1,-(sp)
		move.w	#$a,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_SETDRV	macro	(drive.w)
		move.w	\1,-(sp)
		move.w	#$e,-(sp)
		trap	#1
		addq.w	#4,sp
		endm

G_GETDRV	macro	
		move.w	#$19,-(sp)
		trap	#1
		addq.w	#2,sp
		endm

G_SETDTA	macro	(dta.l)
		move.l	\1,-(sp)
		move.w	#$1a,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_SUPER		macro	(stack.l)
		move.l	\1,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_GETDTA	macro
		move.w	#$2f,-(sp)
		trap	#1
		addq.w	#2,sp
		endm

G_PTERMRES	macro	(keepsize.l,retcode.w)
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#$31,-(sp)
		trap	#1
		addq.w	#8,sp
		endm

G_DFREE		macro	(buffer.l,drive.w)
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#$36,-(sp)
		trap	#1
		addq.w	#8,sp
		endm

G_MKDIR		macro	(pathname.l)
		move.l	\1,-(sp)
		move.w	#$39,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_RMDIR		macro	(pathname.l)
		move.l	\1,-(sp)
		move.w	#$3a,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_SETPATH	macro	(pathname.l)
		move.l	\1,-(sp)
		move.w	#$3b,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_FCREATE	macro	(fname.l,attr.w)
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#$3c,-(sp)
		trap	#1
		addq.w	#8,sp
		endm

G_FOPEN		macro	(fname.l,mode.w)
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.w	#8,sp
		endm

G_FCLOSE	macro	(handle.w)
		move.w	\1,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.w	#4,sp
		endm

G_FREAD		macro	(handle.w,count.l,buffer.l)
		move.l	\3,-(sp)
		move.l	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp
		endm

G_FWRITE	macro	(handle.w,count.l,buffer.l)
		move.l	\3,-(sp)
		move.l	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea	12(sp),sp
		endm

G_FDELETE	macro	(fname.l)
		move.l	\1,-(sp)
		move.w	#$41,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_FSEEK		macro	(offset.l,handle.w,seekmode.w)
		move.w	\3,-(sp)
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#$42,-(sp)
		trap	#1
		lea	10(sp),sp
		endm

G_FATTRIB	macro	(fname.l,mode.w,newattr.w)
		move.w	\3,-(sp)
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#$43,-(sp)
		trap	#1
		lea	10(sp),sp
		endm

G_GETPATH	macro	(buffer.l,drive.w)
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#$47,-(sp)
		trap	#1
		addq.w	#8,sp
		endm

G_MALLOC	macro	(bytes.l)
		move.l	\1,-(sp)
		move.w	#$48,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_MFREE		macro	(address.l)
		move.l	\1,-(sp)
		move.w	#$49,-(sp)
		trap	#1
		addq.w	#6,sp
		endm

G_MSHRINK	macro	(address.l,size.l)
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp
		endm

G_PEXEC		macro	(mode.w,file.l,command.l,env.l)
		move.l	\4,-(sp)
		move.l	\3,-(sp)
		move.l	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		endm

G_PTERM		macro	(retcode.w)
		move.w	\1,-(sp)
		move.w	#$4c,-(sp)
		trap	#1
		endm

G_FSFIRST	macro	(filespec.l,attribs.w)
		move.w	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#$4e,-(sp)
		trap	#1
		addq.w	#8,sp
		endm

G_FSNEXT	macro	
		move.w	#$4f,-(sp)
		trap	#1
		addq.w	#2,sp
		endm

G_FRENAME	macro	(oldfile.l,newfile.l)
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		clr.w	-(sp)
		move.w	#$56,-(sp)
		trap	#1
		lea	12(sp),sp
		endm
