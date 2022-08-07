
overlay "player"



extern int *ainit();
asm 	{
ainit:
	move.l A2,-(A7)
	dc.w 0xa000
	move.l (A7)+,A2
	move.l A0,D0
	rts
	}

extern aput();
asm	{
aput:
	dc.w 0xa001
	rts
	}

extern aget();
asm	{
aget:
	dc.w 0xa002
	rts
	}


extern aaline();
asm	{
aaline:
	move.l A2,-(A7)
	dc.w 0xa003
	move.l (A7)+,A2
	rts
	}


extern ahline();
asm	{
ahline:
	move.l A2,-(A7)
	dc.w 0xa004
	move.l (A7)+,A2
	rts
	}


extern acblock();
asm	{
acblock:
	move.l A2,-(A7)
	dc.w 0xa005
	move.l (A7)+,A2
	rts
	}


extern apoly();
asm	{
apoly:
	move.l A2,-(A7)
	dc.w 0xa006
	move.l (A7)+,A2
	rts
	}


extern ablit();
asm	{
ablit:
	movem.l A2/A6,-(A7)
	move.l 12(A7),A6
	dc.w 0xa007
	movem.l (A7)+,A2/A6
	rts
	}




extern atextblt();
asm	{
atextblt:
	move.l A2,-(A7)
	dc.w 0xa008
	movem.l (A7)+,A2
	rts
	}


extern ashow_mouse();
asm	{
ashow_mouse:
	move.l A2,-(A7)
	dc.w 0xa009
	movem.l (A7)+,A2
	rts
	}


extern ahide_mouse();
asm	{
ahide_mouse:
	move.l A2,-(A7)
	dc.w 0xa00a
	movem.l (A7)+,A2
	rts
	}

extern atmouse();
asm	{
atmouse:
	move.l A2,-(A7)
	dc.w 0xa00b
	movem.l (A7)+,A2
	rts
	}
