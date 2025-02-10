;--------------------------------------------------------------------
; BIOS FUNCTION MACROS
;--------------------------------------------------------------------

B_GETMPB	macro	(buffer.l)
		move.l	\1,-(sp)
		clr.w	-(sp)
		trap	#13
		addq.l	#6,sp
		endm

B_BCONSTAT	macro	(devnum.w)
		move.w	\1,-(sp)
		move.w	#1,-(sp)
		trap	#13
		addq.w	#4,sp
		endm

B_BCONIN	macro	(devnum.w)
		move.w	\1,-(sp)
		move.w	#2,-(sp)
		trap	#13
		addq.w	#4,sp
		endm

B_BCONOUT	macro	(char.w,devnum.w)
		move.w	\1,-(sp)
		move.w	\2,-(sp)
		move.w	#3,-(sp)
		trap	#13
		addq.w	#6,sp
		endm
		
B_RWABS		macro	(drive.w,startsec.w,sectors.w,buffer.l,mode.w)
		move.w	\1,-(sp)
		move.w	\2,-(sp)
		move.w	\3,-(sp)
		move.l	\4,-(sp)
		move.w	\5,-(sp)
		move.w	#4,-(sp)
		trap	#13
		lea	14(sp),sp
		endm

B_SETEXEC	macro	(vecaddr,vecnum)
		move.l	\1,-(sp)
		move.w	\2,-(sp)
		move.w	#5,-(sp)
		trap	#13
		addq.w	#8,sp
		endm

B_TICKCAL	macro	()
		move.w	#6,-(sp)
		trap	#13
		addq.w	#2,sp
		endm

B_GETBPB	macro	(drive.w)
		move.w	\1,-(sp)
		move.w	#7,-(sp)
		trap	#13
		addq.w	#4,sp
		endm

B_BCOSTAT	macro	(device.w)
		move.w	\1,-(sp)
		move.w	#8,-(sp)
		trap	#13
		addq.w	#4,sp
		endm

B_MEDIACH	macro	(drive.w)
		move.w	\1,-(sp)
		move.w	#9,-(sp)
		trap	#13
		addq.w	#4,sp
		endm

B_DRVMAP	macro	()
		move.w	#10,-(sp)
		trap	#13
		addq.w	#2,sp
		endm

B_KBSHIFT	macro	(mode.w)
		move.w	\1,-(sp)
		move.w	#11,-(sp)
		trap	#13
		addq.w	#4,sp
		endm
