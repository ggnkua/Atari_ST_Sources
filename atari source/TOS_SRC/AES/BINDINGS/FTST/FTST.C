/*
 *	Example for new TEDINFO objects using SPEEDO GDOS FONTS.
 *	Copyright 1993, ATARI Corp.
 *
 *	ATARI SPEEDO GDOS Version 4.11 or higher has to be installed 
 */

#include <portab.h>	/* WORD, BYTE, etc.		*/
#include <vdi.h>	/* vdi defines	 		*/
#include <aes.h>	/* aes defines 			*/
#include "ftst.h"	/* recources stuff		*/

/* 
 *	CAUTION: TEDINFO STRUCT HAS CHANGED:
 *
 *	typedef struct text_edinfo
 *	{
 *		char *te_ptext;
 *		char *te_ptmplt;
 *		char *te_pvalid;
 *		short te_font;
 *		short te_fontid;     // was te_rsvd1; now SPEEDO FONT ID
 *		short te_just;
 *		short te_color;
 *		short te_fontsize;  // was te_rsvd2; now font size in points
 *		short te_thickness;
 *		short te_txtlen;
 *		short te_tmplen;
 *	} TEDINFO;
 */

/*
 *	new TEDINFO defines for te_font
 *	(existing ones are: 	IBM   == 3 (std. system font)
 *				SMALL == 5 (small system font )
 */
#define	GDOS_PROP	0
#define GDOS_MONO	1
#define GDOS_BITM	2



/*
 *	Name of resource file
 */
#define RSCNAME		"FTST.RSC"

WORD	ap_id;		/* Application ID 	*/
WORD	v_handle;	/* VDI Handle		*/

	VOID 
main()
{
	OBJECT	*tree;		/* Sample dialog box */
	WORD	i;
	WORD	dummy;
	WORD	work_in[12];
	WORD	work_out[57];

	if ((ap_id = appl_init()) < 0)
		exit(1);

	graf_mouse(HOURGLASS, 0L);

	if (rsrc_load(RSCNAME) == 0) {	/* load resource file */
		graf_mouse(ARROW, 0L);
		form_alert(1, "[1][Can't load resource!][Abort]");
		appl_exit();
		exit(2);
	}

	rsrc_gaddr(R_TREE, BOX, &tree); /* get address of dialiog box */

	/* open VDI workstation */

	v_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
	for (i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk(work_in, &v_handle, work_out);

	init_tedinfos(tree);	/* init TEDINFOS for GDOS */
	
	graf_mouse(ARROW, 0L);

	do_form(tree, FTEXT1); /* display dialog box */

	v_clsvwk(v_handle);
	appl_exit();
	exit(0);
}

	VOID
init_tedinfos(tree)	/* init TEDINFOS for using SPEEDO GDOS */
	OBJECT	*tree;
{
	TEDINFO	*ted;

	/*
	 *	Set up font information for TEXT objects
	 */
     	ted = (TEDINFO*) tree[TEXT1].ob_spec;
	ted->te_font = GDOS_PROP;	/* Use proportional SPEEDO font */
	ted->te_just = TE_LEFT;
 	ted->te_fontid = 6; 		/* SWISS Itaclics, SPEEDO FONT ID */ 
	ted->te_fontsize = 10;		/* Size in points		  */

	ted = (TEDINFO*) tree[TEXT0].ob_spec;
	ted->te_font = GDOS_PROP;	/* Use proportional SPEEDO font */
 	ted->te_fontid = 5;		/* SWISS */
	ted->te_fontsize = 14;

	ted = (TEDINFO*) tree[TEXT4].ob_spec;
	ted->te_font = GDOS_MONO;	/* Use monospaced SPEEDO font */
 	ted->te_fontid = 5;		/* SWISS */
	ted->te_fontsize = 12;

	/*
	 *	Set up font information for FTEXT objects
	 */

	ted = (TEDINFO*) tree[FTEXT1].ob_spec;
	ted->te_font = GDOS_PROP;	/* Use proportional SPEEDO font */
	ted->te_just = TE_LEFT;
 	ted->te_fontid = 5;		/* SWISS */
	ted->te_fontsize = 10;

	ted = (TEDINFO*) tree[FTEXT2].ob_spec;
	ted->te_font = GDOS_PROP;
	ted->te_just = TE_CNTR;
 	ted->te_fontid = 5;		/* SWISS */
	ted->te_fontsize = 10;

	ted = (TEDINFO*) tree[FTEXT4].ob_spec;
	ted->te_font = GDOS_PROP;
	ted->te_just = TE_LEFT;
 	ted->te_fontid = 5;		/* SWISS */
	ted->te_fontsize = 10;
}


	VOID
do_form(tree, frsttxt)	/* display dialog box */
	OBJECT	*tree;
	WORD 	frsttxt;
{
	GRECT	size;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	form_center(tree, &size.g_x, &size.g_y, &size.g_w, &size.g_h);
	form_dial(FMD_START, 
		size.g_x, size.g_y, size.g_w, size.g_h,
		size.g_x, size.g_y, size.g_w, size.g_h );

	objc_draw(tree, ROOT, MAX_DEPTH, 
		size.g_x, size.g_y, size.g_w, size.g_h);

	form_do(tree, frsttxt);

	form_dial(FMD_FINISH, 
		size.g_x, size.g_y, size.g_w, size.g_h,
		size.g_x, size.g_y, size.g_w, size.g_h );

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

