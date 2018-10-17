/*****************************************************************************
*
* laser snapshot driver
*
*****************************************************************************/
#define MAINFILE
#include "gem.h"
#include "resourse.h"			/* resource header file 	*/
#include "resourse.c"			/* the resource file itself!	*/

extern int global[];
extern int gl_apid;

int menu_id;

char *msg[] =
{
	"     Software WriteProtect V1.0",
	"     Program by Timothy Purves",
	"    Placed in the Public Domain",
	"           MichTron Inc.",
	"",
	"Screen  will  flash when a  program", 
	"attempts   to  write  to   software", 
	"protected drive.",
	"",
	"Source code is avalable for $10.00",
	"and a blank disk."
};

char protect[16];

main()
{
	int loop,flags,first,state,objc;
	GRECT box;
	long tree,ted;

	appl_init();

	hookup();
	
	menu_id = menu_register(gl_apid,"  The Protector  ");
	phys_handle = graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);

	for(loop = 0;loop < 10;work_in[loop++] = 1)
		;
	work_in[10] = 2;
	handle = phys_handle;
	v_opnvwk(work_in,&handle,work_out);

	pics();
	form_center(tree = gl_tree[1],&box.g_x,&box.g_y,&box.g_w,&box.g_h);
	for(loop = 0;loop < 11;++loop)
		LLSET(LLGET(OB_SPEC(loop + TB1)),ADDR(msg[loop]));
	form_center(tree = gl_tree[0],&box.g_x,&box.g_y,&box.g_w,&box.g_h);

/* init drive tables */

	first = TRUE;
	flags = bios(10);		/* disk flags */
	for(loop = 0;loop < 16;++loop,flags >>= 1)
		{
		state = flags & 1;
		LWSET(OB_FLAGS(loop + OB1),(state) ? (SELECTABLE | TOUCHEXIT) : 0);
		LWSET(OB_STATE(loop + OB1),(!state) ? DISABLED : 0);
		protect[loop] = 0;
		}

	for(;;)
		{
		evnt_mesag(ADDR(msgbuff));
		wind_update(TRUE);
		if(msgbuff[0] == AC_OPEN && msgbuff[4] == menu_id)
			{
			
			for(loop = 0;loop <= 1;++loop)
				form_dial(loop,0,0,gl_wchar,gl_hchar,
					box.g_x,box.g_y,box.g_w,box.g_h);
			if(first)
				{
				tree = gl_tree[1];
				first = FALSE;
				objc_draw(tree,ROOT,MAX_DEPTH,box.g_x,box.g_y,box.g_w,box.g_h);
				loop = form_do(tree,0) & 0x7fff;
				LWSET(OB_STATE(loop),LWGET(OB_STATE(loop)) & ~SELECTED);
				}
			tree = gl_tree[0];
			objc = ROOT;
			for(;;)
				{
				objc_draw(tree,objc,MAX_DEPTH,box.g_x,box.g_y,box.g_w,box.g_h);
				if((objc = form_do(tree,0) & 0x7fff) == DONE)
					break;
				LWSET(OB_STATE(objc),(protect[objc - OB1] ^= 1) ? SELECTED : 0);

				}
			LWSET(OB_STATE(objc),LWGET(OB_STATE(objc)) & ~SELECTED);
			for(loop = 2;loop <= 3;++loop)
				form_dial(loop,0,0,gl_wchar,gl_hchar,
					box.g_x,box.g_y,box.g_w,box.g_h);
			}
		wind_update(FALSE);
		}
}

/*****************************************************************************
*
* picture init
*
*****************************************************************************/
pics()
{
	WORD	loop, value,objects,planes;
	LONG	ptr,tree;
	MFDB f1,f2;

	/* fix trees */

	vq_extnd(handle,1,work_out);
	planes = work_out[4];

	for (loop = 0; loop < NUM_TREE; loop++)
		{
		/* get tree address into global array */
		tree = rs_trindex[loop] = ADDR(&rs_object[rs_trindex[loop]]);

		objects = 0;
		}

	/* fix global array resource pointer */
	LLSET(ADDR(&global[5]), ADDR(rs_trindex));

	/* fix objects */
	for (loop = 0; loop < NUM_OBS; loop++)
		{
		/* fix x */
		value = rs_object[loop].ob_x;
		rs_object[loop].ob_x = LHIBT(value) + (LLOBT(value) * gl_wchar);

		/* fix y */
		value = rs_object[loop].ob_y;
		rs_object[loop].ob_y = LHIBT(value) + (LLOBT(value) * gl_hchar);

		/* fix width */
		value = rs_object[loop].ob_width;
		rs_object[loop].ob_width = LHIBT(value) + (LLOBT(value) * gl_wchar);

		/* fix height */
		value = rs_object[loop].ob_height;
		rs_object[loop].ob_height = LHIBT(value) + (LLOBT(value) * gl_hchar);

		/* switch on object type */
		switch (rs_object[loop].ob_type)
			{
		case G_TEXT:
		case G_BOXTEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			/* fix tedinfo pointer */
			ptr = rs_object[loop].ob_spec;
			rs_object[loop].ob_spec =
			    ADDR(&rs_tedinfo[ptr]);
			break;

		case G_BUTTON:
		case G_STRING:
		case G_TITLE:
			/* fix string pointer */
			ptr = rs_object[loop].ob_spec;
			rs_object[loop].ob_spec = ADDR(rs_strings[ptr]);
			break;

		case G_BOX:
		case G_IBOX:
			/* no additional fixup needed */
			break;

		case G_IMAGE:				/* obsec points to a bit block struct */
			ptr = rs_object[loop].ob_spec;			/* which bit bilt */
			rs_object[loop].ob_spec	= ADDR(&rs_bitblk[ptr]);	/* point to bit block */
			f1.mp = f2.mp = rs_bitblk[ptr].bi_pdata = ADDR(rs_imdope[rs_bitblk[ptr].bi_pdata].image);
			f1.fww = f2.fww = rs_bitblk[ptr].bi_wb >> 1;	/* widht bytes */
			f1.fh = f2.fh = rs_bitblk[ptr].bi_hl;	/* pixels high */
			f1.fwp = f2.fwp = f1.fww << 4;
			f1.ff = f1.np = 1; /* standard form 1 plane */
			f2.ff = 0;		/* to device */
			f2.np = planes;	/* number of device planes */
			vr_trnfm(handle,&f1,&f2);	/* wham it */
			break;

		case G_USERDEF:
		case G_ICON:
		default:
			/* we're screwed here if we get here */
			break;
			}
		}

	/* fix tedinfos */
	for (loop = 0; loop < NUM_TI; loop++)
		{
		/* fix text pointer */
		rs_tedinfo[loop].te_ptext = ADDR(rs_strings[rs_tedinfo[loop].te_ptext]);

		/* fix template pointer */
		rs_tedinfo[loop].te_ptmplt =
			ADDR(rs_strings[rs_tedinfo[loop].te_ptmplt]);

		/* fix validation string pointer */
		rs_tedinfo[loop].te_pvalid =
		    ADDR(rs_strings[rs_tedinfo[loop].te_pvalid]);
		}
}
RIMG 0
#define NUM_IB 0
#define NUM_TI 14
#define NUM_OBS 37
#define