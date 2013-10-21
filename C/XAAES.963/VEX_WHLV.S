*	Created by TT-Digger v6.2
*	Fri Oct 11 22:02:44 2002

	globl vex_whlv
module vex_whlv
	 pea	 (a1)
	 move.l	 #134,d1
	 moveq	 #0,d2
	 move.l	 a0,VDI_blk+14
	 bsr	 _vdi
	 movea.l (a7)+,a1
	 move.l	 -278(a0),(a1)
	 rts
