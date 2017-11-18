/*	STCREATE.c	04/20/85		ATARI		*/
/*	RSCREATE.C	05/18/84 - 11/01/84	LKW		*/
/*	Fix something	12/10/84 - 12/10/84	Derek Mui	*/
/*	Fix the  size	12/17/84				*/
/*	For ST		04/20/85		Derek Mui	*/


#include <portab.h>
#include <machine.h>
#include <obdefs.h>
#include <rsrclib.h>

EXTERN WORD	dos_create();
EXTERN WORD	dos_write();
EXTERN VOID	dos_close();


BYTE	*beg_file;

RSHDR starthdr = 
{
	0,		/* rsh_vrsn	*/
	0,		/* rsh_object	*/
	0, 		/* rsh_tedinfo	*/
	0,		/* rsh_iconblk	*/
	0,		/* rsh_bitblk	*/
	0,		/* rsh_frstr	*/
	0,		/* rsh_string	string data		*/
	0,		/* rsh_imdata	image data		*/
	0,		/* rsh_frimg	*/
	0,		/* rsh_trindex	*/
	0,		/* rsh_nobs	*/
	0,		/* rsh_ntree	*/
	0,		/* rsh_nted	*/
	0,		/* rsh_nib	*/
	0,		/* rsh_nbb	*/
	0,		/* rsh_nstring	*/
	0,		/* rsh_nimages	*/
	0		/* rsh_rssize	*/
};

#include <dummy.h>	/* put your include file at here	*/

WORD  endfile = 1;

main()
{
	BYTE		*jnk1;
	WORD		handle, ret;
	WORD		size, cnt;			/* in bytes	*/	

	starthdr.rsh_vrsn = 0;

	beg_file = &starthdr;
	jnk1 = &rs_object;
	starthdr.rsh_object = (WORD)(jnk1 - beg_file);
	jnk1 = &rs_tedinfo;
	starthdr.rsh_tedinfo = (WORD)(jnk1 - beg_file);
	jnk1 = &rs_iconblk;
	starthdr.rsh_iconblk = (WORD)(jnk1 - beg_file);
	jnk1 = &rs_bitblk;
	starthdr.rsh_bitblk = (WORD)(jnk1 - beg_file);
	jnk1 = &rs_frstr;
	starthdr.rsh_frstr = (WORD)(jnk1 - beg_file);
	jnk1 = &rs_string[0];
	starthdr.rsh_string = (WORD)(jnk1 - beg_file);
	jnk1 = rs_imdope[0].image;
	starthdr.rsh_imdata = (WORD)(jnk1 - beg_file);
	jnk1 = &rs_frimg;
	starthdr.rsh_frimg = (WORD)(jnk1 - beg_file);
	jnk1 = &rs_trindex;
	starthdr.rsh_trindex = (WORD)(jnk1 - beg_file);

	starthdr.rsh_nobs = NUM_OBS;
	starthdr.rsh_ntree = NUM_TREE;
	starthdr.rsh_nted = NUM_TI;
	starthdr.rsh_nib = NUM_IB;
	starthdr.rsh_nbb = NUM_BB;
	starthdr.rsh_nimages = NUM_FRIMG;
	starthdr.rsh_nstring = NUM_FRSTR;

	fix_trindex();
	fix_objects();
	fix_tedinfo();
	fix_iconblk();
	fix_bitblk();
	fix_frstr();
	fix_frimg();

	/* calculate the real size of the file  */
	/* i.e. include the data string		*/


	size = LSTRLEN(rs_string[NUM_STRING - 1]) + 1;
	
	handle = dos_create( ADDR(&pname), F_ATTR);
	cnt =  rs_string[NUM_STRING - 1]  - ((BYTE *)&starthdr) + size;
	starthdr.rsh_rssize = cnt;
	ret = dos_write(handle, cnt, ADDR(&starthdr) );
	dos_close(handle);
}

fix_trindex()
	{
	WORD	test, ii;

	for (ii = 0; ii < NUM_TREE; ii++)
		{
		test = (WORD) rs_trindex[ii];
		rs_trindex[ii] = (BYTE *) &rs_object[test] - beg_file;
		}
	}

fix_objects()
	{
	WORD	test, ii;

	for (ii = 0; ii < NUM_OBS; ii++)
		{
		test = (WORD) rs_object[ii].ob_spec;
		switch (rs_object[ii].ob_type) {
			case G_TITLE:
			case G_STRING:
			case G_BUTTON:
				fix_str(&rs_object[ii].ob_spec);
				break;
			case G_TEXT:
			case G_BOXTEXT:
			case G_FTEXT:
			case G_FBOXTEXT:
				if (test != NIL)
				   rs_object[ii].ob_spec = 
					(BYTE *) &rs_tedinfo[test] - beg_file;
				break;
			case G_ICON:
				if (test != NIL)
				   rs_object[ii].ob_spec =
					(BYTE *) &rs_iconblk[test] - beg_file;
				break;
			case G_IMAGE:
				if (test != NIL)
				   rs_object[ii].ob_spec =
					(BYTE *) &rs_bitblk[test] - beg_file;
				break;
			default:
			}
		}
	}

fix_tedinfo()
	{
	WORD	ii;

	for (ii = 0; ii < NUM_TI; ii++)
		{
		fix_str(&rs_tedinfo[ii].te_ptext);
		fix_str(&rs_tedinfo[ii].te_ptmplt);
		fix_str(&rs_tedinfo[ii].te_pvalid);
		}
	}

fix_frstr()
	{
	WORD	ii;

	for (ii = 0; ii < NUM_FRSTR; ii++)
		fix_str(&rs_frstr[ii]);
	}

fix_str(where)
	LONG	*where;
	{
	if (*where != NIL)
  	  *where = (LONG)(rs_strings[(WORD) *where] - (BYTE *)beg_file);
	}

fix_iconblk()
	{
	WORD	ii;

	for (ii = 0; ii < NUM_IB; ii++)
		{
		fix_img(&rs_iconblk[ii].ib_pmask);
		fix_img(&rs_iconblk[ii].ib_pdata);
		fix_str(&rs_iconblk[ii].ib_ptext);
		}
	}

fix_bitblk()
	{
	WORD	ii;

	for (ii = 0; ii < NUM_BB; ii++)
		fix_img(&rs_bitblk[ii].bi_pdata);
	}

fix_frimg()
	{
	WORD	ii;

	for (ii = 0; ii < NUM_FRIMG; ii++)
		fix_bb(&rs_frimg[ii]);
	}

fix_bb(where)
	LONG	*where;
	{
	if (*where != NIL)
  	  *where = (LONG)( (BYTE *) &rs_bitblk[(BYTE) *where] - (BYTE *)beg_file);
	}
	
fix_img(where)
	LONG	*where;
{
	if (*where != NIL)
	 *where = (LONG)( (BYTE *) rs_imdope[(WORD) *where].image - (BYTE *)beg_file);
}
