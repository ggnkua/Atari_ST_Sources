*~~~~~~~~~~	GEM Macros ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*
*	CyberState	921005
*

gem	MACRO
	move.w	#\1,-(sp)
	trap	#1
	stk_cor	\2
	ENDM

bios	MACRO
	move.w	#\1,-(sp)
	trap	#13
	stk_cor	\2
	ENDM

xbios	MACRO
	move.w	#\1,-(sp)
	trap	#14
	stk_cor	\2
	ENDM

stk_cor	MACRO
	IFEQ	NARG
	MEXIT
	ENDC
	IFGT	\1-8
	lea	\1(sp),sp
	ELSEIF
	addq.l	#\1,sp
	ENDC
	ENDM

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
