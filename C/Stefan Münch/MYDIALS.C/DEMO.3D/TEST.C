#include <stdlib.h>
#include <portab.h>
#include <aes.h>
#include <vdi.h>
#include <nkcc.h>
#include <mglobal.h>
#include <mydial.h>
#include "test.h"

OBBLK usr_block[100];

main()
{
	OBJECT *test;

	rsrc_load("TEST.RSC");
	nkc_init(NKI_NO200HZ, 0);
	dial_init(malloc, free, NULL, NULL, NULL, TRUE, usr_block, 100);

	rsrc_gaddr(R_TREE, SETTINGS, &test);
	dial_fix(test, TRUE);
	dial_slinit(test, NIL, NIL, NIL, NIL, NIL, NIL, NIL, SPRDOWN, SPRUP);
	dial_slinit(test, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NUP, NDOWN);
	dial_slinit(test, CLOSE, HEAD, SLEDGE, VSBOX, UP, DOWN, HSBOX, LEFT, RIGHT);
	dial_slinit(test, C2, H2, E2, VB2, U2, D2, HB2, L2, R2);
	dial_slinit(test, NIL, NIL, NIL, VB3, U3, D3, NIL, NIL, NIL);
	dial_slinit(test, NIL, NIL, NIL, NIL, NIL, NIL, HB3, L3, R3);
	HndlDial(test, 0, 0, NULL, NULL);

	rsrc_gaddr(R_TREE, BOX, &test);
	dial_fix(test, TRUE);
	HndlDial(test, BONAME, 0, NULL, NULL);

	rsrc_gaddr(R_TREE, ALERT, &test);
	dial_fix(test, TRUE);
	HndlDial(test, ALZ1, 0, NULL, NULL);

	dial_exit();
	nkc_exit();
	rsrc_free();
	return(0);
}