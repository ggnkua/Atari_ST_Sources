/*****************************************************************************/
/*                                                                           */
/* Modul: EXTOBFIX.C                                                         */
/* Datum: 17.02.91                                                           */
/*                                                                           */
/*****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <portab.h>
#include <aes.h>
#include <vdi.h>

#include <nkcc.h>
#include <mglobal.h>
#include <mydial.h>
#include "exthelp.rsh"
/*#include "exthp_us.rsh"*/

/****** DEFINES **************************************************************/

#define EXTOBFIX3DMODE	TRUE
#define BLOCKLEN        1000

/****** TYPES ****************************************************************/

/****** FUNCTIONS ************************************************************/

extern VOID    dial_3Dmode    (BOOLEAN do3D);

LOCAL  VOID    fix_objs      _((OBJECT *tree, BOOLEAN is_dialog));
LOCAL  VOID    (*get_name)   _((VOID *window, WORD obj, BYTE *txt));
LOCAL  VOID    free_userblk  _((OBJECT *tree));
GLOBAL LONG    pinit_obfix   _((BOOLEAN status));
LOCAL VOID     test_form     _((OBJECT *tree, WORD editobj, LONG get_n, VOID *window));

/****** VARIABLES ************************************************************/

LOCAL  WORD colors;
GLOBAL OBBLK block[BLOCKLEN];

LOCAL LONG routines[] =
{
	(LONG)fix_objs,
	(LONG)do_alert,
	(LONG)test_form,
	(LONG)&rs_object[0],
	'0610', '1965',				/* Magic */
	(LONG)pinit_obfix,
};

/*****************************************************************************/

LOCAL VOID fix_objs (tree, is_dialog)
OBJECT  *tree;
BOOLEAN is_dialog;

{
	dial_fix (tree, is_dialog);
}

/*****************************************************************************/

LOCAL VOID test_form (tree, editobj, get_n, window)
OBJECT *tree;
WORD   editobj;
LONG   get_n;
VOID   *window;

{	static BOOLEAN mode3D = EXTOBFIX3DMODE;
	WORD     but, zw, mode;
	BYTE     name[18], buf[200];
	DIALINFO di;

	*(LONG *)&get_name = get_n;
	
	dial_3Dmode (mode3D);
	fix_objs (tree, TRUE);
	tree->ob_x = tree->ob_y = 0;
	open_dial (tree, FALSE, NULL, &di);

	
	zw = 2;
	do
	{
		dial_3Dmode (mode3D);
		dial_draw (&di);
		but = dial_do (&di, ROOT) & 0x7fff;
		tree [but].ob_state &= ~SELECTED;

		(*get_name) (window, but, name);

		if (!mode3D)
			mode = MODE3D_ON;
		else
			mode = MODE3D_OFF;

		dial_3Dmode (EXTOBFIX3DMODE);
		if (colors >= 16)
			sprintf (buf, rs_frstr[EXITBUT3D], but, name, rs_frstr[mode]);
		else
			sprintf (buf, rs_frstr[EXITBUT], but, name);
		
		zw = dial_alert (NULL, buf, (colors >= 16) ? 3 : 2, 1, ALI_LEFT);
	}
	while (zw == ((colors >= 16) ? 3 : 2));

	if (zw == 2)	mode3D ^= 0x1;
	
	close_dial (FALSE, NULL, &di);
	free_userblk (tree);
}

/*****************************************************************************/

LOCAL VOID free_userblk (tree)
OBJECT *tree;

{	WORD obj = ROOT;

	do
	{
		if ((tree[obj].ob_type & 0x00ff) == G_USERDEF)
		{	if (((OBBLK *)tree[obj].ob_spec)->old_type != G_CICON && ((OBBLK *)tree[obj].ob_spec)->old_type != G_USERDEF)
				((OBBLK *)tree[obj].ob_spec)->ublk.ub_code = NULL;	/* USERBLK freigeben */
		}
	}
	while (!(tree[obj++].ob_flags & LASTOB));
}

/*****************************************************************************/

main()
{	LOCAL dummy;

	if (dial_init (Malloc, Mfree, NULL, NULL, NULL, EXTOBFIX3DMODE, block, BLOCKLEN))
	{
		nkc_init (NKI_NO200HZ, 0, _GemParBlk.global);	/* Initialisiere NKCC */
		nkc_set (0);
		dial_alert (NULL, "[0][This program can|only be started from|Interface !][[Cancel]", 1, 1, ALI_LEFT);
    nkc_exit ();																/* Terminiere NKCC */
	 	dial_exit ();
	}
	else
		dummy = routines[6];	/* Sonst wird die Struktur von Pure C wegoptimiert... */

	return (0);
}

/*****************************************************************************/

GLOBAL LONG pinit_obfix (status)
BOOLEAN status;

{	WORD i, work_out [57];

	if (status == TRUE)
	{	if (!dial_init (Malloc, Mfree, NULL, NULL, NULL, EXTOBFIX3DMODE, block, BLOCKLEN))
			return (0L);
		else
		{
			nkc_init (NKI_NO200HZ, 0, _GemParBlk.global);	/* Initialisiere NKCC */
			nkc_set (0);

			i = 0;
			do
				rsrc_obfix (&rs_object[i], ROOT);
			while (!(rs_object[i++].ob_flags & LASTOB));

			ascii_head (rs_frstr[ASCII_HEADER]);

			vq_extnd (vdi_myhandle, FALSE, work_out);     /* Hole Anzahl der Farben */
			colors = work_out [13];                       /* Anzahl der Farben */
			
			return ((LONG)routines);
		}
	}
	else
	{	nkc_exit ();																/* Terminiere NKCC */
  	dial_exit ();
  }
	
	return (0L);
}
