/*
	These routines are the actual interface to the OS.  They save registers
	and perfrom the apporpriate trap
*/

long bios(), xbios(), gemdos();
long _saveA1, _saveA2, _savePC;	/* place to save registers */

#ifndef LINT
asm {
	bios:
		move.l	A1, _saveA1(A4)
		move.l	A2, _saveA2(A4)
		move.l	(A7)+, _savePC(A4)
		trap	#13
		move.l	_saveA1(A4), A1
		move.l	_saveA2(A4), A2
		move.l	_savePC(A4), -(A7)
		rts
	xbios:
		move.l	A1, _saveA1(A4)
		move.l	A2, _saveA2(A4)
		move.l	(A7)+, _savePC(A4)
		trap	#14
		move.l	_saveA1(A4), A1
		move.l	_saveA2(A4), A2
		move.l	_savePC(A4), -(A7)
		rts
	gemdos:
		move.l	A1, _saveA1(A4)
		move.l	A2, _saveA2(A4)
		move.l	(A7)+, _savePC(A4)
		trap	#1
		move.l	_saveA1(A4), A1
		move.l	_saveA2(A4), A2
		move.l	_savePC(A4), -(A7)
		rts
}
#endif
