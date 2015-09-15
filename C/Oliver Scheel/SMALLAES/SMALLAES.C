/* ------------------------------------------------------------------------- */
/* ----- The smaller AES-Binding V1.2 --- (c) 1991-93 by Oliver Scheel ----- */
/* ------------------------------------------------------------------------- */
/* ----- SMALLAES.C -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
/* Dieses Binding ist Public Domain. Žnderungen sind genau zu dokumentieren! */
/* ------------------------------------------------------------------------- */
/* This Binding is public domain. Changes have to be documented!	     */
/* ------------------------------------------------------------------------- */
/*	Autor:	Oliver Scheel						     */
/*		Rothehausstr. 28					     */
/*		W-5000 K”ln 30 (West-Geramny)				     */
/*	Net: 	Oliver_Scheel@k2.maus.de				     */
/* ------------------------------------------------------------------------- */

#include <stdarg.h>
#include <portab.h>

/* ------------------------------------------------------------------------- */

typedef struct
{
	WORD	*control;
	WORD	*global;
	WORD	*int_in;
	WORD	*int_out;
	LONG	*addr_in;
	LONG	*addr_out;
} AESPB;

WORD	control[5];
WORD	global[15];
WORD	int_in[16];
WORD	int_out[7];
LONG	addr_in[2];
LONG	addr_out[1];

AESPB	aespb = {	control,
			global,
			int_in,
			int_out,
			addr_in,
			addr_out };

UBYTE	ctrl_cnts[122][4] = {
				0, 1, 0, 0,	/* appl_init		*/
    				2, 1, 1, 0,	/* appl_read		*/
    				2, 1, 1, 0,	/* appl_write		*/
				0, 1, 1, 0,	/* appl_find		*/
				2, 1, 1, 0,	/* appl_tplay		*/
				1, 1, 1, 0,	/* appl_trecord		*/
				2, 1, 0, 0,	/* appl_bvset (GEM/2)	*/
				0, 1, 0, 0,	/* appl_yield (GEM/2)	*/
				1, 3, 1, 0,	/* appl_search (AES 4.0) */
				0, 1, 0, 0,	/* appl_exit		*/
				0, 1, 0, 0,	/* evnt_keybd		*/
				3, 5, 0, 0,	/* evnt_button		*/
				5, 5, 0, 0,	/* evnt_mouse		*/
				0, 1, 1, 0,	/* evnt_mesag		*/
				2, 1, 0, 0,	/* evnt_timer		*/
				16, 7, 1, 0,	/* evnt_multi		*/
				2, 1, 0, 0,	/* evnt_dclicks		*/
				0, 0, 0, 0,	/* AES 27		*/
				0, 0, 0, 0,	/* AES 28		*/
				0, 0, 0, 0,	/* AES 29		*/
				1, 1, 1, 0,	/* menu_bar		*/
				2, 1, 1, 0,	/* menu_icheck		*/
				2, 1, 1, 0,	/* menu_ienable		*/
				2, 1, 1, 0,	/* menu_tnormal		*/
				1, 1, 2, 0,	/* menu_text		*/
				1, 1, 1, 0,	/* menu_register	*/
				2, 1, 2, 0,	/* menu_popup (AES 3.3) */
				2, 1, 2, 0,	/* menu_attach (AES 3.3) */
				3, 1, 1, 0,	/* menu_istart (AES 3.3) */
				1, 1, 1, 0,	/* menu_settings (AES 3.3) */
				2, 1, 1, 0,	/* objc_add		*/
				1, 1, 1, 0,	/* objc_delete		*/
  				6, 1, 1, 0,	/* objc_draw		*/
				4, 1, 1, 0,	/* objc_find		*/
				1, 3, 1, 0,	/* objc_offset		*/
				2, 1, 1, 0,	/* objc_order		*/
				4, 2, 1, 0,	/* objc_edit		*/
				8, 1, 1, 0,	/* objc_change		*/
				4, 3, 0, 0,	/* objc_sysvar (AES 3.4) */
				0, 0, 0, 0,	/* AES 49		*/
				1, 1, 1, 0,	/* form_do		*/
				9, 1, 0, 0,	/* form_dial		*/
				1, 1, 1, 0,	/* form_alert		*/
				1, 1, 0, 0,	/* form_error		*/
				0, 5, 1, 0,	/* form_center		*/
				3, 3, 1, 0,	/* form_keybd		*/
				2, 2, 1, 0,	/* form_button		*/
				0, 0, 0, 0,	/* AES 57		*/
				0, 0, 0, 0,	/* AES 58		*/
				0, 0, 0, 0,	/* AES 59		*/
				0, 0, 0, 0,	/* AES 60		*/
				0, 0, 0, 0,	/* AES 61		*/
				0, 0, 0, 0,	/* AES 62		*/
				0, 0, 0, 0,	/* AES 63		*/
				0, 0, 0, 0,	/* AES 64		*/
				0, 0, 0, 0,	/* AES 65		*/
				0, 0, 0, 0,	/* AES 66		*/
				0, 0, 0, 0,	/* AES 67		*/
				0, 0, 0, 0,	/* AES 68		*/
				0, 0, 0, 0,	/* AES 69		*/
				4, 3, 0, 0,	/* graf_rubberbox	*/
				8, 3, 0, 0,	/* graf_dragbox		*/
				6, 1, 0, 0,	/* graf_movebox		*/
				8, 1, 0, 0,	/* graf_growbox		*/
				8, 1, 0, 0,	/* graf_shrinkbox	*/
				4, 1, 1, 0,	/* graf_watchbox	*/
				3, 1, 1, 0,	/* graf_slidebox	*/
				0, 5, 0, 0,	/* graf_handle		*/
				1, 1, 1, 0,	/* graf_mouse		*/
				0, 5, 0, 0,	/* graf_mkstate		*/
				0, 1, 1, 0,	/* scrp_read		*/
				0, 1, 1, 0,	/* scrp_write		*/
				0, 1, 0, 0,	/* scrp_clear (GEM/2)	*/
				0, 0, 0, 0,	/* AES 83		*/
				0, 0, 0, 0,	/* AES 84		*/
				0, 0, 0, 0,	/* AES 85		*/
				0, 0, 0, 0,	/* AES 86		*/
				0, 0, 0, 0,	/* AES 87		*/
				0, 0, 0, 0,	/* AES 88		*/
				0, 0, 0, 0,	/* AES 89		*/
				0, 2, 2, 0,	/* fsel_input		*/
				0, 2, 3, 0,	/* fsel_exinput (TOS 1.04) */
				0, 0, 0, 0,	/* AES 92		*/
				0, 0, 0, 0,	/* AES 93		*/
				0, 0, 0, 0,	/* AES 94		*/
				0, 0, 0, 0,	/* AES 95		*/
				0, 0, 0, 0,	/* AES 96		*/
				0, 0, 0, 0,	/* AES 97		*/
				0, 0, 0, 0,	/* AES 98		*/
				0, 0, 0, 0,	/* AES 99		*/
				5, 1, 0, 0,	/* wind_create		*/
				5, 1, 0, 0,	/* wind_open		*/
				1, 1, 0, 0,	/* wind_close		*/
				1, 1, 0, 0,	/* wind_delete		*/
				2, 5, 0, 0,	/* wind_get		*/
				6, 1, 0, 0,	/* wind_set		*/
				2, 1, 0, 0,	/* wind_find		*/
				1, 1, 0, 0,	/* wind_update		*/
				6, 5, 0, 0,	/* wind_calc		*/
				0, 0, 0, 0,	/* wind_new (TOS 1.04)	*/
				0, 1, 1, 0,	/* rsrc_load		*/
				0, 1, 0, 0,	/* rsrc_free		*/
				2, 1, 0, 1,	/* rsrc_gaddr		*/
				2, 1, 1, 0,	/* rsrc_saddr		*/
				1, 1, 1, 0,	/* rsrc_obfix		*/
				0, 1, 1, 0,	/* rsrc_rcfix (AES 4.0)  */
				0, 0, 0, 0,	/* AES 116		*/
				0, 0, 0, 0,	/* AES 117		*/
				0, 0, 0, 0,	/* AES 118		*/
				0, 0, 0, 0,	/* AES 119		*/
				0, 1, 2, 0,	/* shel_read		*/
				3, 1, 2, 0,	/* shel_write		*/
				1, 1, 1, 0,	/* shel_get		*/
				1, 1, 1, 0,	/* shel_put		*/
				0, 1, 1, 0,	/* shel_find		*/
				0, 1, 2, 0,	/* shel_envrn		*/
				0, 1, 2, 0,	/* shel_rdef (GEM/2)	*/
				0, 0, 2, 0,	/* shel_wdef (GEM/2)	*/
				0, 0, 0, 0,	/* AES 128		*/
				0, 0, 0, 0,	/* AES 129		*/
				1, 5, 0, 0,	/* appl_getinfo (AES 4.0) */
				0, 0, 0, 0	/* AES 131	*/
				};

/* ------------------------------------------------------------------------- */

VOID _crystal(AESPB *aesbpb);

/* ------------------------------------------------------------------------- */
/* ----- AES - Call -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

WORD aes(WORD args, ...)
{
	REG WORD 	i;
	UBYTE		*c;
	va_list	vargs;

	va_start(vargs, args);
	control[0] = args;
	c = ctrl_cnts[args-10];
	for(i = 1; i <= 4; )
		control[i++] = *c++;
	for(i = 0; i < control[1]; )
		int_in[i++] = va_arg(vargs, WORD);
	for(i = 0; i < control[3]; )
		addr_in[i++] = va_arg(vargs, LONG);

	_crystal(&aespb);

	for(i = 1; i < control[2]; )
		*(WORD *)(va_arg(vargs, LONG)) = int_out[i++];
	for(i = 0; i < control[4]; )
		*(LONG *)(va_arg(vargs, LONG)) = addr_out[i++];
	va_end(vargs);
	return(int_out[0]);
}

/* ----- end of SMALLAES.C ------------------------------------------------- */
