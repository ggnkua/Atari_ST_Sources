/********************************************************************
 *																1.00*
 *	XAES: Extra Routines											*
 *	Code by Ken Hollis, GNU C Extensions by Sascha Blank			*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	What else was I supposed to call this code segment?!			*
 *																	*
 ********************************************************************/

#include <string.h>
#include "xaes.h"

GLOBAL BOOL CheckMultitask(void)
{
	if (locate_cookie('MiNT'))
		return TRUE;

	return FALSE;
}

GLOBAL BOOL	CheckSpeedup(void)
{
	if (locate_cookie('NVDI'))
		return TRUE;

	return FALSE;
}

GLOBAL BOOL CheckPowerDOS(void)
{
	if (locate_cookie('PDOS'))
		return TRUE;

	return FALSE;
}

GLOBAL BOOL CheckWinX(void)
{
	if (locate_cookie('WINX'))
		return TRUE;

	return FALSE;
}

GLOBAL void WObjFixPosition(OBJECT *obj)
{
	int i;

	i = -1;

	do {
		i++;
		rsrc_obfix(obj, i);
	} while(!(obj[i].ob_flags & LASTOB));
}

GLOBAL void ChangeObjectText(OBJECT *obj, int idx, char *txt, int fnt, int just)
{
	UNUSED(fnt);

	switch(obj[idx].ob_type & 0xFF) {
		case G_USERDEF:
			{
				EXTINFO *exinf = (EXTINFO *)(obj[idx].ob_spec.userblk->ub_parm);

				exinf->te_ptext = txt;
				exinf->te_txtlen = (int) strlen(txt);
				exinf->te_just = just;
			}
			break;

		default:
			obj[idx].ob_spec.tedinfo->te_ptext = (char *) txt;
			obj[idx].ob_spec.tedinfo->te_txtlen = (int) strlen(txt);
			if (just>0)
				obj[idx].ob_spec.tedinfo->te_just = just;
			break;
	}
}
