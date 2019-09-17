/*	$Id: GENERAL.H,v 1.23 1994/06/12 22:00:00 SCR Exp SCR $ */

void rc_adjust(GRECT *, int);
void gtovrect(GRECT *, short *);
int objc_parent(OBJECT *, int);

#if defined(LATTICE) && defined(M68000)
	#pragma inline rc_adjust(a0, d0) \
		{ "d158"; "d158"; "d040"; "9158"; "9150"; }
#endif
