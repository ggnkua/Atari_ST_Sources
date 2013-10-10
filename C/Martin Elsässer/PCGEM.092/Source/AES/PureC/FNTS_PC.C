/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - FNTS-Bibliothek kompatibel zu PureC							*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

/* Wir brauchen die KompatibilitÑts-Funktionen, keine Makro-Definitionen! */
#define __COMPATIBLE_FKT__

/******************************************************************************/

#include <AES.H>
#include <String.H>

/******************************************************************************/
/*																										*/
/* AES 185:	fnts_add																				*/
/*																										*/
/******************************************************************************/

int16 fnts_add( const FNT_DIALOG *fnt_dialog, const FNTS_ITEM *user_fonts )
{
	return mt_fnts_add(fnt_dialog, user_fonts, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 183:	fnts_close																			*/
/*																										*/
/******************************************************************************/

int16 fnts_close( const FNT_DIALOG *fnt_dialog, int16 *x, int16 *y )
{
	return mt_fnts_close(fnt_dialog, x, y, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 180:	fnts_create																			*/
/*																										*/
/******************************************************************************/

FNT_DIALOG *fnts_create( const int16 vdi_handle, const int16 no_fonts,
				const int16 font_flags, const int16 dialog_flags,
				const char *sample, const char *opt_button )
{
	return mt_fnts_create(vdi_handle, no_fonts, font_flags, dialog_flags, sample,
					opt_button, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 181:	fnts_delete																			*/
/*																										*/
/******************************************************************************/

int16 fnts_delete( const FNT_DIALOG *fnt_dialog, const int16 vdi_handle )
{
	return mt_fnts_delete(fnt_dialog, vdi_handle, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 187:	fnts_do																				*/
/*																										*/
/******************************************************************************/

int16 fnts_do( FNT_DIALOG *fnt_dialog, const int16 button_flags, const int32 id_in,
				const int32 pt_in, const int32 ratio_in, int16 *check_boxes, 
				int32 *id, fix31 *pt, int32 *ratio )
{
	return mt_fnts_do(fnt_dialog, button_flags, id_in, pt_in, ratio_in, check_boxes,
					id, pt, ratio, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 186:	fnts_evnt																			*/
/*																										*/
/******************************************************************************/

int16 fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, int16 *button,
				int16 *check_boxes, int32 *id, fix31 *pt, fix31 *ratio )
{
	return mt_fnts_evnt(fnt_dialog, events, button, check_boxes, id, pt, ratio, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 184:	fnts_get_info																		*/
/*																										*/
/******************************************************************************/

int16 fnts_get_info( FNT_DIALOG *fnt_dialog, const int32 id, int16 *mono,
				int16  *outline )
{
	return mt_fnts_get_info(fnt_dialog, id, mono, outline, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 184:	fnts_get_name																		*/
/*																										*/
/******************************************************************************/

int16 fnts_get_name( FNT_DIALOG *fnt_dialog, const int32 id, char *full_name,
				char *family_name, char *style_name )
{
	return mt_fnts_get_name(fnt_dialog, id, full_name, family_name, style_name, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 184:	fnts_get_no_styles																*/
/*																										*/
/******************************************************************************/

int16 fnts_get_no_styles( FNT_DIALOG *fnt_dialog, const int32 id )
{
	return mt_fnts_get_no_styles(fnt_dialog, id, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 184:	fnts_get_style																		*/
/*																										*/
/******************************************************************************/

int32 fnts_get_style( FNT_DIALOG *fnt_dialog, const int32 id, const int16 index )
{
	return mt_fnts_get_style(fnt_dialog, id, index, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 182:	fnts_open																			*/
/*																										*/
/******************************************************************************/

int16 fnts_open( FNT_DIALOG *fnt_dialog, const int16 button_flags, const int16 x,
				const int16 y, const int32 id, const fix31 pt, const fix31 ratio )
{
	return mt_fnts_open(fnt_dialog, button_flags, x, y, id, pt, ratio, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 185:	fnts_remove																			*/
/*																										*/
/******************************************************************************/

void fnts_remove( FNT_DIALOG *fnt_dialog )
{
	mt_fnts_remove(fnt_dialog, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 185:	fnts_update																			*/
/*																										*/
/******************************************************************************/

int16 fnts_update( FNT_DIALOG *fnt_dialog, const int16 button_flags,
				const int32 id, const fix31 pt, const int32 ratio )
{
	return mt_fnts_update(fnt_dialog, button_flags, id, pt, ratio, _globl);
}
