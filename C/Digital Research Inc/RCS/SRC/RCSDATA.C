 /*	RCSDATA.C	12/21/84 - 1/25/85  	Tim Oren		*/
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#include <string.h>
#include <stdio.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <obdefs.h>
#include <gembind.h>
#endif
#include "rcsdefs.h"
#include "rcs.h"
#include "rcslib.h"
#include "rcsintf.h"
#include "rcsdata.h"

/* variables used in icon edit mode */
UWORD	loword, hiword;
GRECT	trans_area;
MFDB	trans_mfdb, tmp_mfdb, tmp2_mfdb, fat_mfdb;  
WORD	junk;	

GLOBAL  BOOLEAN icn_edited = FALSE, clipped = FALSE, paste_img = FALSE;
GLOBAL	BOOLEAN	iconedit_flag = FALSE, flags,pen_on, grid;
GLOBAL	BOOLEAN	selecton = FALSE, inverted;
GLOBAL	LONG	save_tree, gl_icnspec;
GLOBAL	WORD	save_obj, save_state, gl_wimage, gl_himage, gl_datasize;
GLOBAL	GRECT	scrn_area,hold_area,fat_area,src_img,icn_img,dat_img,mas_img;
GLOBAL	GRECT	scroll_fat, gridbx;
GLOBAL	GRECT	clip_area, selec_area, flash_area, dispc_area;
GLOBAL	MFDB	undo_mfdb,und2_mfdb,hold_mfdb,hld2_mfdb,disp_mfdb,scrn_mfdb;
GLOBAL	MFDB	clip_mfdb, clp2_mfdb, save_mfdb, sav2_mfdb;
GLOBAL	LONG	src_mp, dst_mp;
GLOBAL	LONG	ibuff_size;
GLOBAL	BOOLEAN	is_mask, gl_isicon;
GLOBAL  WORD	out1, xwait, ywait, wwait, hwait,out2;
GLOBAL  WORD	mousex, mousey, bstate, kstate,kreturn, bclicks;
GLOBAL  WORD    colour,fgcolor, bgcolor, old_fc, deltax, deltay;
GLOBAL	WORD	gridw = 8, gridh = 8;

#if	MC68K

UWORD	bit_mask[16] = { 0x8000, 0x4000, 0x2000, 0x1000,
			 0x0800, 0x0400, 0x0200, 0x0100,
			 0x0080, 0x0040, 0x0020, 0x0010,
			 0x0008, 0x0004, 0x0002, 0x0001 };
#else

UWORD	bit_mask[16] = { 0x0080, 0x0040, 0x0020, 0x0010,
			 0x0008, 0x0004, 0x0002, 0x0001,
			 0x8000, 0x4000, 0x2000, 0x1000,
			 0x0800, 0x0400, 0x0200, 0x0100 };
#endif

UWORD	color_map[16] = { 0x0000, 0x000f, 0x0001, 0x0002, 0x0004,
		          0x0006, 0x0003, 0x0005, 0x0007, 0x0008,
		          0x0009, 0x000a, 0x000c, 0x000e, 0x000b,
		          0x000d };
GLOBAL  WORD    invert3[8] = {BLACK,WHITE,CYAN,MAGENTA,YELLOW,RED,BLUE,GREEN};
GLOBAL  WORD	invert4[16]= {BLACK, WHITE, LCYAN, LMAGENTA, LYELLOW, LRED,
			      LBLUE, LGREEN, LBLACK, LWHITE, CYAN, MAGENTA,
			      YELLOW, RED, BLUE, GREEN};
GLOBAL	BYTE	sav_icnpath[80];
GLOBAL	BYTE	sav_rcspath[80];
GLOBAL	BYTE	rcs_rfile[80];
GLOBAL	BYTE	rcs_dfile[80];
GLOBAL  BYTE	rcs_app[80];
GLOBAL	BYTE	rcs_infile[80];
GLOBAL  BYTE    icn_file[80];
GLOBAL	FILE	*rcs_rhndl;
GLOBAL	FILE	*rcs_dhndl;     
GLOBAL  UWORD	hard_drive;	/* what is hard drive configuration? */
GLOBAL	WORD	partp;		/* are parts shown? */
GLOBAL	WORD	toolp;		/* are tools shown? */
GLOBAL  LONG	ad_menu;
GLOBAL	LONG	ad_tools;
GLOBAL  LONG	ad_view;
GLOBAL	LONG	ad_pbx;
GLOBAL	LONG	ad_clip;
GLOBAL  LONG    ad_itool;
GLOBAL  LONG    ad_idisp;
GLOBAL	WORD	rcs_clipkind;
GLOBAL	WORD	rcs_view;
GLOBAL	GRECT	full;
GLOBAL	GRECT	view;
GLOBAL	GRECT	pbx;
GLOBAL	GRECT	tools;
GLOBAL  GRECT   itool;
GLOBAL  GRECT   idisp;
GLOBAL	WORD	rcs_trpan;	/* Tree row offset in window	*/
GLOBAL	WORD	rcs_xpan;	/* (Positive) offset of root	*/
GLOBAL	WORD	rcs_ypan;
GLOBAL	WORD	rcs_xtsave;	/* Tree x,y before being opened */
GLOBAL	WORD	rcs_ytsave;
GLOBAL	WORD	rcs_mform;	/* Current mouse form */
GLOBAL	WORD	rcs_hot;	/* Currently active tools */
GLOBAL	GRECT	wait;		/* Current mouse wait rectangle */
GLOBAL	WORD	wait_io;	/* Waiting for in or out? */

GLOBAL	WORD	rcs_svfstat;
GLOBAL  WORD	rcs_state = 0;
GLOBAL  WORD	icn_state = 0;
GLOBAL	BYTE	rcs_title[80];
GLOBAL	WORD	rcs_nsel = 0;
GLOBAL	WORD	rcs_sel[MAXSEL];
GLOBAL	WORD	rcs_cflag = FALSE;	/* emit .c file or not?	   */
GLOBAL	WORD	rcs_hflag = TRUE;	/* emit .h file or not?	   */
GLOBAL	WORD	rcs_oflag = FALSE;	/* emit .o file or not?	   */
GLOBAL	WORD	rcs_cbflag = FALSE;	/* emit C-BASIC binding?   */
GLOBAL	WORD	rcs_f77flag = FALSE;	/* emit FORTRAN binding?   */
GLOBAL	WORD	rcs_fsrtflag = FALSE;   /* sort the binding file?  */
GLOBAL	WORD	rcs_lock = FALSE;	/* no tree changes? */
GLOBAL	WORD	rcs_xpert = FALSE;	/* omit warnings? */
GLOBAL	WORD	rcs_edited = FALSE;	/* quit without warning?  */
GLOBAL	WORD	rcs_low = FALSE;	/* low memory? */
GLOBAL	WORD	rcs_panic = FALSE;	/* in deep trouble! */ 
GLOBAL	WORD	rcs_menusel;		/* only used in MENU_STATE */
GLOBAL  WORD	rcs_rmsg[8];
GLOBAL  LONG	ad_rmsg;

GLOBAL	OBJECT	rcs_work[VIEWSIZE+1];	/* Space for workbench objects	*/
GLOBAL	ICONBLK	rcs_icons[VIEWSIZE];	/* Space for workbench iconblks */
GLOBAL	WORD	rcs_typ2icn[NUM_TYP] = {
	UNKNICON, PANLICON, MENUICON, DIALICON, ALRTICON, FREEICON};
/* Variables used in write_file */
GLOBAL	UWORD	rcs_wraddr;		/* Current offset in output file */
GLOBAL	UWORD	wr_obnum;		/* Count of obj in tree		*/
GLOBAL	WORD	wr_obndx[TRACESIZE];	/* Tree trace index is built here */

GLOBAL  UWORD	rcs_ndxno = 0;

GLOBAL	INDEX	rcs_index[NDXSIZE];
GLOBAL	DEFLTS	deflt_options[NOPTS];
GLOBAL  BYTE	rsc_path[80];

GLOBAL	WORD	OK_NOFILE[] = { OPENITEM, MERGITEM, QUITITEM, INFITEM, 
				OUTPITEM, SAFEITEM, SVOSITEM, PARTITEM, TOOLITEM, 0};

GLOBAL	WORD	OK_FILE[] = {NEWITEM, OPENITEM, MERGITEM, SVASITEM, 
			QUITITEM, INFITEM, OUTPITEM, SAFEITEM, SVOSITEM,
			PARTITEM, TOOLITEM, MERGITEM, CLOSITEM,	0};

GLOBAL	WORD	OK_TREES[] = {CLOSITEM, QUITITEM, INFITEM, OUTPITEM,SAFEITEM,
			SVOSITEM, PARTITEM, TOOLITEM, 0};
		  
GLOBAL  WORD	OK_NOICN[] = {NEWITEM, OPENITEM, CLOSITEM, SVASITEM, OUTPITEM,
			SAFEITEM, SVOSITEM,INVITEM,SOLIDIMG,SIZEITEM,0};

GLOBAL  WORD	OK_ICN[] =  {NEWITEM, OPENITEM, CLOSITEM, SVASITEM, OUTPITEM,
			SAFEITEM, SVOSITEM,INVITEM,SOLIDIMG,SIZEITEM, 0};

GLOBAL  WORD    OK_EDITED[] = {NEWITEM, SVASITEM,RVRTITEM,0};
		
GLOBAL	WORD	ILL_LOCK[] = {MERGITEM, RNAMITEM, TYPEITEM, SRTITEM, 
			PASTITEM, CUTITEM, DELITEM, UNHDITEM, FLTITEM, 0};

GLOBAL	WORD	HOT_IBOX[] = {HOTBDCOL, HOTTHICK, 0};
GLOBAL	WORD	HOT_BOX[] = {HOTBDCOL, HOTTHICK, HOTBGCOL, HOTPATRN, 0};
GLOBAL	WORD	HOT_TEXT[] = {HOTFGCOL, HOTRULE, 0};
GLOBAL	WORD	HOT_IMAGE[] = {HOTFGCOL, 0};
GLOBAL	WORD	HOT_ICON[] = {HOTFGCOL, HOTBGCOL, 0};
GLOBAL	WORD	HOT_BTEXT[] = {HOTBDCOL, HOTTHICK, HOTBGCOL, HOTPATRN,
			HOTFGCOL, HOTRULE, 0};

GLOBAL	FILE	*rcs_hhndl;	/* used in write_files and c_ routines */
GLOBAL	BYTE	rcs_hfile[100], hline[80];

GLOBAL	struct tally rcs_tally;

GLOBAL	WORD	c_obndx[MAPSIZE]; /* maps from disk address to string/image # */
GLOBAL	WORD	c_nstring;
GLOBAL	WORD	c_frstr;	/* first string referenced by freestr */
GLOBAL	WORD	c_nfrstr;
GLOBAL	WORD	c_nimage;
GLOBAL	WORD	c_frimg;	/* first image referenced by freebits */
GLOBAL	WORD	c_nbb;
GLOBAL	WORD	c_nfrbit;
GLOBAL	WORD	c_nib;
GLOBAL	WORD	c_nted;
GLOBAL	WORD	c_nobs;
GLOBAL	WORD	c_ntree;

GLOBAL	struct obitmap rcs_bit2obj[] = {
	SELECTABLE, 0, SBLEPOP,
	DEFAULT, 0, DFLTPOP,
	EXIT, 0, EXITPOP,
	RBUTTON, 0, RDIOPOP,
	0, DISABLED, DSBLPOP,
	EDITABLE, 0, EDBLPOP,
	TOUCHEXIT, 0, TCHXPOP,
	HIDETREE, 0, HDDNPOP,
	0, CROSSED, CROSPOP,
	0, CHECKED, CHEKPOP,
	0, OUTLINED, OUTLPOP,
	0, SHADOWED, SHADPOP,
	0, SELECTED, SLCTPOP,
	ESCCANCEL, 0, ESCPOP,
	BITBUTTON, 0, BITBPOP,
	SCROLLER, 0, SCCTRPOP,
	FL3DIND, 0, D3INDPOP,
	USECOLOURCAT, 0, SYCOLPOP,
	FL3DBAK, 0, D3BAKPOP,
	SUBMENU, 0, SUBMPOP,
	0, WHITEBAK, WBAKPOP,
	0, DRAW3D, EXT3DPOP,
	0, HIGHLIGHTED, HIGHLPOP,
	0, UNHIGHLIGHTED, UHIGLPOP,
	0, 0, 0 };

GLOBAL	struct popmap rcs_ht2pop[] = {
	HOTBGCOL, POPCOLOR, TRUE,
	HOTPATRN, POPPATRN, TRUE,
	HOTBDCOL, POPCOLOR, TRUE,
	HOTTHICK, POPTHICK, TRUE,
	HOTFGCOL, POPCOLOR, TRUE,
	HOTRULE,  POPRULE,  TRUE,
	HOTPOSN,  POPPOSN,  FALSE,
	HOTSWTCH, POPSWTCH, FALSE,
	0, 0 };
GLOBAL	struct popmap icn_ht2pop[] = {
	FCLORBOX, POPCOLOR, TRUE,
	BCLORBOX, POPCOLOR, TRUE,
	0, 0 };

GLOBAL	struct map rcs_it2thk[] = {
	OUT3POP, -3,
	OUT2POP, -2,
	OUT1POP, -1,
	NONEPOP,  0,
	IN1POP,   1,
	IN2POP,	  2,
	IN3POP,   3,
	0, 0 };

GLOBAL	LOOKUP	c_types[N_TYPES] = {
	G_BOX, "G_BOX",
	G_TEXT, "G_TEXT",
	G_BOXTEXT, "G_BOXTEXT",
	G_IMAGE, "G_IMAGE",
	G_USERDEF, "G_USERDEF",
	G_IBOX, "G_IBOX",
	G_BUTTON, "G_BUTTON",
	G_BOXCHAR, "G_BOXCHAR",
	G_STRING, "G_STRING",
	G_FTEXT, "G_FTEXT",
	G_FBOXTEXT, "G_FBOXTEXT",
	G_ICON, "G_ICON",
	G_TITLE, "G_TITLE" };

GLOBAL	LOOKUP	c_flags[N_FLAGS] = {
	NONE, "NONE",
	SELECTABLE, "SELECTABLE",
	DEFAULT, "DEFAULT",
	EXIT, "EXIT",
	EDITABLE, "EDITABLE",
	RBUTTON, "RBUTTON",
	LASTOB, "LASTOB",
	TOUCHEXIT, "TOUCHEXIT",
	HIDETREE, "HIDETREE",
	INDIRECT, "INDIRECT" };

GLOBAL	LOOKUP	c_states[N_STATES] = {
	NORMAL, "NORMAL",
	SELECTED, "SELECTED",
	CROSSED, "CROSSED",
	CHECKED, "CHECKED",
	DISABLED, "DISABLED",
	OUTLINED, "OUTLINED",
	SHADOWED, "SHADOWED" };

GLOBAL	WORD	str_types[] = {G_STRING, G_BUTTON};
GLOBAL	WORD	box_types[] = {G_BOX, G_IBOX, G_BOXCHAR};
GLOBAL	WORD	txt_types[] = {G_TEXT, G_FTEXT, G_BOXTEXT, G_FBOXTEXT};

GLOBAL	OBJECT	blank_obj = {
	-1, -1, -1, G_BOX, HIDETREE, NORMAL, 0x00FF1100L, 0, 0, 8, 1 };

GLOBAL	BYTE	*hptns[] = {
	"#define %s %hd  \t/* TREE */\n",
	"#define %s %hd  \t/* STRING */\n",
	"#define %s %hd  \t/* OBJECT in TREE #%hd */\n",
	"#define %s %hd	\t/* FREE STRING */\n",
	"#define %s %hd	\t/* FREE IMAGE */\n" };

GLOBAL	BYTE	*optns[] = {
	"      %s = %hd;  \t(* TREE *)\n",
	"      %s = %hd;  \t(* STRING *)\n",
	"      %s = %hd;  \t(* OBJECT in TREE #%hd *)\n",
	"      %s = %hd;  \t(* FREE STRING *)\n",
	"      %s = %hd;  \t(* FREE IMAGE *)\n" };

GLOBAL	BYTE	*bptns[] = {
	"      %s = %hd;  REM ---TREE---\n",
	"      %s = %hd;  REM ---STRING---\n",
	"      %s = %hd;  REM ---OBJECT in TREE #%hd---\n",
	"      %s = %hd;  REM ---FREE STRING---\n",
	"      %s = %hd;  REM ---FREE IMAGE---\n" };

GLOBAL	BYTE	*fptns[] = {
	"\tPARAMETER (%s = %hd)\n",
	"\tPARAMETER (%s = %hd)\n",
	"\tPARAMETER (%s = %hd)\n",
	"\tPARAMETER (%s = %hd)\n",
	"\tPARAMETER (%s = %hd)\n" };

GLOBAL	LONG	rs_hdr;
GLOBAL	LONG	head;
GLOBAL	LONG	buff_size;
GLOBAL	LONG	rcs_free;

MLOCAL	LONG	d_frstr;		/* These are local to dcomp_free */
MLOCAL	LONG	d_frimg;
MLOCAL	WORD	d_nfrstr;
MLOCAL	WORD	d_nfrimg;

VOID ini_buff(VOID)
{
	WORD	ii;

	for (ii = 0; ii < sizeof(RSHDR); ii++)
		LBSET(head + ii, '\0');
	rcs_low = FALSE;
	rcs_panic = FALSE;
	rcs_free = head + sizeof(RSHDR);
}

LONG tree_ptr(WORD n)
{
	return (head + LW( LWGET(RSH_TRINDEX(head)) ) + (LONG) (n * sizeof(LONG)));
}  

LONG str_ptr(WORD n)
{
	return (head + LW( LWGET(RSH_FRSTR(head)) ) + (LONG) (n * sizeof(LONG)));
}

LONG img_ptr(WORD n)
{
	return (head + LW( LWGET(RSH_FRIMG(head)) ) + (LONG) (n * sizeof(LONG)));
}

LONG tree_addr(WORD n)
{
	return LLGET(tree_ptr(n));
}  

LONG str_addr(WORD n)
{
	return LLGET(str_ptr(n));
}

LONG img_addr(WORD n)
{
	return LLGET(img_ptr(n));
}

VOID set_value(WORD key, BYTE *val)
{
	rcs_index[key].val = val;
}

VOID set_kind(WORD key, WORD kind)
{
	rcs_index[key].kind = kind;
}

LOCAL VOID set_name(WORD key, BYTE *name)
{
	if (name == NULL)
		rcs_index[key].name[0] = '\0';
	else
		strcpy(&(rcs_index[key].name[0]), name);
}

WORD new_index(BYTE *val, WORD kind, BYTE *name)
{
	if (rcs_ndxno >= NDXSIZE)
		return (NIL);
	else
	{
		set_value(rcs_ndxno, val);
		set_kind(rcs_ndxno, kind);
		set_name(rcs_ndxno, name);
		return (rcs_ndxno++);
	}
}

LOCAL VOID del_index(WORD key)
{
	rcs_ndxno--;
	if (key < rcs_ndxno)
		memcpy((BYTE *)&rcs_index[key],
			(BYTE *)&rcs_index[key+1],
			sizeof(INDEX) * (rcs_ndxno - key));
}

WORD get_kind(WORD key)
{
	return rcs_index[key].kind;
}

BYTE *get_value(WORD key)
{
	return rcs_index[key].val;
}

BYTE *get_name(WORD key)
{
	return &(rcs_index[key].name[0]);
}

WORD find_value(BYTE *val)
{
	WORD	entno;

	for (entno = 0; entno < rcs_ndxno; entno++)
		if (rcs_index[entno].val == val)
			return(entno);
	return (NIL);
}

WORD find_tree(WORD n)
{
	return find_value((BYTE *) tree_addr(n));
}

WORD find_obj(LONG tree, WORD obj)
{
	return find_value( (BYTE *) (tree + (UWORD) (obj * sizeof(OBJECT))) );
}

WORD find_name(BYTE *name)
{
	WORD	entno;

	for (entno = 0; entno < rcs_ndxno; entno++)
		if (strcmp(name, &rcs_index[entno].name[0]) == 0 )
			return (entno);
	return (NIL);
}

WORD tree_kind(WORD kind)
{
	switch (kind)
	{
		case UNKN:
		case PANL:
		case DIAL:
		case MENU:
		case ALRT:
		case FREE:
			return (TRUE);
		default:
			break;
	}
	return (FALSE);
}

VOID unique_name(BYTE *name, BYTE *ptn, WORD n)
{
	do {
		sprintf(name, ptn, n);
		n++;
	} while (find_name(name) != NIL);
}

LOCAL WORD blank_name(BYTE *name)
{
	WORD	blank, idx;

	blank = TRUE;	  
	for (idx = 0;name[idx] != 0; idx++)
		if (name[idx] != ' ')
		{
			blank = FALSE;
	  		break;
		} 
	return( blank );
}

WORD name_ok(BYTE *name, WORD ok, WORD nilok)
{
	WORD	hit;

	if (name[0] == '@' || !name[0] || blank_name(name) )
	{
		if (nilok)
			return (TRUE);
		else
		{
			hndl_alert(1, string_addr(STNONAM));
			return (FALSE);
		}
	}
	else
	{
		hit = find_name(name);
		if (hit == NIL || hit == ok)
			return (TRUE);
		else
		{
			hndl_alert(1, string_addr(STNMDUP));
			return (FALSE);
		}
	}
}

WORD set_obname(LONG tree, WORD obj, BYTE *name, LONG ntree, WORD nobj)
{
	LONG	taddr;
	WORD	where;

	taddr = GET_SPEC(tree, obj);
	LLSET(taddr, ADDR(name));
	LWSET(TE_TXTLEN(taddr), 9);
	LWSET(TE_TMPLEN(taddr), 9);

	where = find_value((BYTE *) (ntree + nobj * sizeof(OBJECT)) );
	if (where == NIL)
		strcpy(name, "@");
	else
		strcpy(name, get_name(where));
	return (where);
}

VOID get_obname(BYTE *name, LONG ntree, WORD nobj)
{
	WORD	where;
	LONG	addr;

	addr = ntree + nobj * sizeof(OBJECT);
	where = find_value((BYTE *) addr);
	if (where != NIL)
	{
		if (!name[0] || name[0] == '@')
			del_index(where);
		else
			strcpy(get_name(where), name);
	}
	else
	{
		if (name[0] && name[0] != '@')
		{
			where = new_index((BYTE *)addr, OBJKIND, name);
			if (where == NIL)
				hndl_alert(1, string_addr(STNFULL));
		}
	}
}

VOID del_objindex(LONG tree, WORD obj)
{
	WORD	where;

	where = find_obj(tree, obj);
	if (where != NIL)
		del_index(where);
}

VOID zap_objindex(LONG tree, WORD obj)
{
	map_tree(tree, obj, GET_NEXT(tree, obj), (fkt_parm)del_objindex);
}

LONG avail_mem(VOID)
{
	return (head + buff_size - rcs_free);
}

LONG get_mem(UWORD bytes)
{
	LONG	ret;
	LONG	left;

	ret = rcs_free;
#if	MC68K
	if (bytes & 0x1)
		bytes++;
#endif
	rcs_free += bytes;
	left = avail_mem();
	if (left < 1000 && !rcs_low)
	{
		hndl_alert(1, string_addr(STLOMEM));
		rcs_low = TRUE;
	}
	if (left <= 0 && !rcs_panic)
	{
		hndl_alert(1, string_addr(STPANIC));
		rcs_panic = TRUE;
	}
	return (ret);
}

LONG  get_obmem(VOID)
{
	UWORD	foo;

	foo = (UWORD) (rcs_free - ( head + LW( LWGET(RSH_OBJECT(head)) )));
	
	foo %= (UWORD) sizeof(OBJECT);
 	/* synchronize to even OBJECT	*/
	/* boundary w.r.t. first OBJECT */
	if (foo)
		rcs_free += (UWORD) sizeof(OBJECT) - foo;
	return get_mem((UWORD) sizeof(OBJECT));
}

VOID update_if(LONG taddr, BYTE *naddr)
{
	if (!LLSTRCMP(LLGET(taddr), (LONG)ADDR(naddr)))
	{
		LLSET(taddr, get_mem( (UWORD) strlen(naddr)+1));
		LLSTRCPY((LONG)ADDR(naddr), LLGET(taddr));
	}
}

LOCAL LONG copy_ti(LONG source)
{
	LONG	dest;

	dest = get_mem((UWORD) sizeof(TEDINFO));
	LBCOPY(dest, source, sizeof(TEDINFO) );
	return (dest);
}

LOCAL LONG copy_ib(LONG source)
{
	LONG	dest;

	dest = get_mem((UWORD) sizeof(ICONBLK));
	LBCOPY(dest, source, sizeof(ICONBLK) );
	return (dest);
}

LOCAL LONG copy_bb(LONG source)
{
	LONG	dest;

	dest = get_mem((UWORD) sizeof(BITBLK));
	LBCOPY(dest, source, sizeof(BITBLK) );
	return (dest);
}

VOID copy_spec(LONG tree, WORD obj)
{
	WORD	type;
	LONG	obspec;

	type = LLOBT(GET_TYPE(tree, obj));
	obspec = GET_SPEC(tree, obj);
	switch (type)
	{
		case G_TEXT:
		case G_BOXTEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			obspec = copy_ti(obspec);
			break;
		case G_ICON:
			obspec = copy_ib(obspec);
			break;
		case G_IMAGE:
			obspec = copy_bb(obspec);
			break;
		default:
			return;
	}
	SET_SPEC(tree, obj, obspec);
}

VOID indx_obs(LONG tree, WORD which)
{
	wr_obndx[wr_obnum++] = which;
}

WORD fnd_ob(WORD old)
{
	WORD	new;
	
	for (new = 0; new < wr_obnum && wr_obndx[new] != old; new++)
		;
	return (new);
}

WORD copy_objs(LONG stree, WORD obj, LONG dtree, WORD specopy)
{
	WORD	iobj, root, link;
	LONG	here, tree;
	UWORD	thisobj;

	tree = stree;
	wr_obnum = 0;
	map_tree(tree, obj, GET_NEXT(tree, obj), (fkt_parm)indx_obs);

	tree = dtree;
	for (iobj = 0; iobj < wr_obnum; iobj++)
	{
		here = get_obmem();
		LBCOPY(here, stree + (UWORD) (wr_obndx[iobj] * sizeof(OBJECT)),
			sizeof(OBJECT) );
		thisobj = (UWORD) ((here - tree) / sizeof(OBJECT));
		if (!iobj)
		{
			root = thisobj;
			SET_NEXT(tree, thisobj, NIL);
		}
		else
			if ( (link = GET_NEXT(tree, thisobj)) != -1L)
				SET_NEXT(tree, thisobj, fnd_ob(link) + root); 
		if ( (link = GET_HEAD(tree, thisobj)) != -1L)
			SET_HEAD(tree, thisobj, fnd_ob(link) + root); 
		if ( (link = GET_TAIL(tree, thisobj)) != -1L)
			SET_TAIL(tree, thisobj, fnd_ob(link) + root); 
	}
	if (specopy)
		map_tree(tree, root, NIL, (fkt_parm)copy_spec);
	return (root);
}

LONG copy_tree(LONG stree, WORD obj, WORD specopy)
{
	LONG	dtree;

	get_obmem();
	dtree = (rcs_free -= (UWORD) sizeof(OBJECT) );	/* a hack which */
	copy_objs(stree, obj, dtree, specopy);			/* saves memory */
	return (dtree);
}

LONG mak_trindex(WORD nentry)
{
	LONG	trindex;
	WORD	nobj, iobj;
	UWORD	indoff;

	nobj = LWGET(RSH_NTREE(head));
	LWSET(RSH_NTREE(head), nobj + nentry);

	trindex = get_mem((UWORD) sizeof(LONG) * (nobj + nentry));
	indoff = (UWORD) (trindex - head);

	for (iobj = 0; iobj < nobj; iobj++)
	{
		LLSET(trindex, tree_addr(iobj));
		trindex += (UWORD) sizeof(LONG);
	}

	LWSET(RSH_TRINDEX(head), indoff);
	return (trindex);
}

VOID add_trindex(LONG tree)
{
	LONG	trindex;

	trindex = mak_trindex(1);
	LLSET(trindex, tree);
}

LONG mak_frstr(WORD nentry)
{
	LONG	frstr;
	WORD	nobj, iobj;
	UWORD	indoff;

	nobj = LWGET(RSH_NSTRING(head));
	LWSET(RSH_NSTRING(head), nobj + nentry);

	frstr = get_mem((UWORD) sizeof(LONG) * (nobj + nentry));
	indoff = (UWORD) (frstr - head);

	for (iobj = 0; iobj < nobj; iobj++)
	{		
		LLSET(frstr, str_addr(iobj));
		frstr += (UWORD) sizeof(LONG);
	}

	LWSET(RSH_FRSTR(head), indoff);
	return (frstr);
}

LOCAL LONG mak_frimg(WORD nentry)
{
	LONG	frimg;
	WORD	nobj, iobj;
	UWORD	indoff;

	nobj = LWGET(RSH_NIMAGES(head));
	LWSET(RSH_NIMAGES(head), nobj + nentry);

	frimg = get_mem((UWORD) sizeof(LONG) * (nobj + nentry));
	indoff = (UWORD) (frimg - head);

	for (iobj = 0; iobj < nobj; iobj++)
	{
		LLSET(frimg, img_addr(iobj));
		frimg += (UWORD) sizeof(LONG);
	}

	LWSET(RSH_FRIMG(head), indoff);
	return (frimg);
}

VOID count_free(LONG tree, WORD obj)
{
	switch (GET_TYPE(tree, obj) & 0xff)
	{
		case G_STRING:
			d_nfrstr++;
			break;
		case G_IMAGE:
			d_nfrimg++;
			break;
		default:
			break;
	}
}

VOID dcomp_tree(LONG tree, WORD obj)
{
	WORD	ndex;
	LONG	taddr;

	taddr = GET_SPEC(tree, obj);
	ndex = find_obj(tree, obj);

	switch (GET_TYPE(tree, obj) & 0xff)
	{
		case G_STRING:
			LLSET(d_frstr, taddr);
			d_frstr += (UWORD) sizeof(LONG);
			d_nfrstr++;
			if (ndex == NIL)
				break;
			set_kind(ndex, FRSTR);
			set_value(ndex, (BYTE *) (d_nfrstr - 1));
			break;
		case G_IMAGE:
			LLSET(d_frimg, taddr);
			d_frimg += (UWORD) sizeof(LONG);
			d_nfrimg++;
			if (ndex == NIL)
				break;
			set_kind(ndex, FRIMG);
			set_value(ndex, (BYTE *) (d_nfrimg - 1));
			break;
		default:
			break;
	}
}

VOID dcomp_free(VOID)
{
	LONG	tree;
	WORD	ntrind, nfrstr, nfrimg, itree, ndex, ntree;

	ntrind = LWGET(RSH_NTREE(head));
	for (d_nfrimg = d_nfrstr = itree = 0; itree < ntrind; itree++ )
	{
		tree = tree_addr(itree);
		ndex = find_value( (BYTE *) tree);
		if ( get_kind(ndex) == FREE )
			map_tree(tree, ROOT, NIL, (fkt_parm)count_free);
	}
	if (d_nfrstr)
	{
		nfrstr = LWGET(RSH_NSTRING(head));
		d_frstr = mak_frstr(d_nfrstr);
		d_nfrstr = nfrstr;
	}
	if (d_nfrimg)
	{
		nfrimg = LWGET(RSH_NIMAGES(head));
		d_frimg = mak_frimg(d_nfrimg);
		d_nfrimg = nfrimg;
	} 
	for (ntree = itree = 0; itree < ntrind; itree++ )
	{
		tree = tree_addr(itree);
		ndex = find_value( (BYTE *) tree);
		if ( get_kind(ndex) == FREE )
		{
			map_tree(tree, ROOT, NIL, (fkt_parm)dcomp_tree);
			del_objindex(tree, ROOT);
		}
		else
		{
			if (ntree != itree)
				LLSET(tree_ptr(ntree), tree_addr(itree));
			ntree++;
		}
	}

	LWSET(RSH_NTREE(head), ntree);
}

BYTE *c_lookup(UWORD what, LOOKUP *where, UWORD n, BYTE *punt)
{
	UWORD	i;

	for (i = 0; i < n; i++)
		if (what == where->l_val)
			return (&where->l_name[0]);
		else
			where++;
	sprintf(punt, "0x%hX", &what);
	return (punt);
}

VOID map_all(WORD (*routine)())
{
	WORD	ntree, itree;

	ntree = LWGET(RSH_NTREE(head));

	for (itree = 0; itree < ntree; itree++)
		map_tree( tree_addr(itree), 0, -1, routine);
}

VOID clr_tally(VOID)
{
	rcs_tally.nobj = 0;
	rcs_tally.nib = 0;
	rcs_tally.nbb = 0;
	rcs_tally.nti = 0;
	rcs_tally.nimg = 0;
	rcs_tally.nstr = 0;
	rcs_tally.nbytes = 0;
}

LOCAL VOID tally_str(LONG addr)
{
	if (addr != -1L)
	{
		rcs_tally.nstr++;
		rcs_tally.nbytes += (UWORD) (LSTRLEN(addr) + 1);
	}
}

LOCAL VOID tally_bb(LONG addr)
{
	rcs_tally.nbb++;
	rcs_tally.nbytes += (UWORD) sizeof(BITBLK);
	if (LLGET(BI_PDATA(addr)) != -1L)
	{
		rcs_tally.nimg++;
		rcs_tally.nbytes += (UWORD) (LWGET(BI_WB(addr)) * LWGET(BI_HL(addr)));
	}
}

VOID tally_free(VOID)
{
	LONG	*free;
	WORD	i;

	rcs_tally.nstr += LWGET(RSH_NSTRING(head));
	rcs_tally.nbytes += (UWORD) (LWGET(RSH_NSTRING(head)) * sizeof(LONG));
	free = (LONG *) ( head + LW( LWGET(RSH_FRSTR(head)) ) );
	for (i = 0; i < LWGET(RSH_NSTRING(head)); i++)
		tally_str( *(free + i));

	rcs_tally.nbb += LWGET(RSH_NIMAGES(head));
	rcs_tally.nbytes += (UWORD) (LWGET(RSH_NIMAGES(head)) * 
		(sizeof(LONG) + sizeof(BITBLK)));
  	free = (LONG *) ( head + LW( LWGET(RSH_FRIMG(head)) ) );
	for (i = 0; i < LWGET(RSH_NIMAGES(head)); i++)
		tally_bb( *(free + i));
}

VOID tally_obj(LONG tree, WORD obj)
{
	LONG 	taddr; 
	WORD	size;

	rcs_tally.nobj++;
	rcs_tally.nbytes += (UWORD) sizeof(OBJECT);
	taddr = GET_SPEC(tree, obj);
	switch (LLOBT(GET_TYPE(tree, obj)))
	{
		case G_STRING:
		case G_BUTTON:
		case G_TITLE:
			if (taddr == -1L)
				return;
			tally_str(taddr);
			return;
		case G_TEXT:
		case G_BOXTEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			if (taddr == -1L)
				return;
			rcs_tally.nti++;
			rcs_tally.nbytes += (UWORD) sizeof(TEDINFO);
			tally_str(LLGET(TE_PTEXT(taddr)));
			tally_str(LLGET(TE_PVALID(taddr)));
			tally_str(LLGET(TE_PTMPLT(taddr)));
			return;
		case G_IMAGE:
			if (taddr == -1L)
				return;
			tally_bb(taddr);
			return;
		case G_ICON:
			if (taddr == -1L)
				return;
			rcs_tally.nib++;
			rcs_tally.nbytes += (UWORD) sizeof(ICONBLK);
			size = (LWGET(IB_WICON(taddr)) + 7) / 8;
			size *= LWGET(IB_HICON(taddr));
			if (LLGET(IB_PDATA(taddr)) != -1L)
			{
				rcs_tally.nimg++;
				rcs_tally.nbytes += (UWORD) size;
			}
			if (LLGET(IB_PMASK(taddr)) != -1L)
			{
				rcs_tally.nimg++;
				rcs_tally.nbytes += (UWORD) size;
			}
			tally_str(LLGET(IB_PTEXT(taddr)));
			return;
		default:
			return;
	}
}
