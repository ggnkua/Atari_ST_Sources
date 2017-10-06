*	Pure C  Binding for Vsetscreen (Call only if cookie '_VDO' >= 0x30000

*   void VsetScreen(void *phys, void *log, int mode, int modecode)
*                   a0          a1         d0        d1

globl VsetScreen
VsetScreen:
	move.w	d1,-(sp)
	move.w	d0,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.w	#$05,-(sp)
	trap	#14
	lea	14(sp),sp
	rts
