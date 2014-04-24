extern vdi();
extern unsigned contrl[];
extern long _saveA1, _saveA2;

long pooff, iooff, pioff, iioff, pblock;	/* globals grow negative !! */

i_ptr(addr)
long addr;
{
	contrl[7] = addr >> 16;
	contrl[8] = addr & 0xffff;
}

i_ptr2(addr)
long addr;
{
	contrl[9] = addr >> 16;
	contrl[10] = addr & 0xffff;
}

m_lptr2(addr)
long *addr;
{
	*addr = ((long)contrl[9] << 16) | contrl[10];
}

#ifndef LINT
asm {
	vdi:
		move.l	A1, _saveA1(A4)
		move.l	A2, _saveA2(A4)
		pea		contrl(A4)
		move.l	(A7)+, pblock(A4)
		pea		pblock(A4)
		move.l	(A7)+, D1
		move.l	#115, D0 
		trap	#2
		move.l	_saveA1(A4), A1
		move.l	_saveA2(A4), A2
		rts
}
#endif
