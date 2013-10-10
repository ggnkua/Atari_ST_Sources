 /*	RCSWRITE.C	1/28/85 - 1/28/85	Tim Oren		*/
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
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <dosbind.h>
#include <obdefs.h>
#include <gembind.h>
#endif
#include "rcsdefs.h"
#include "rcs.h"
#include "rcslib.h"
#include "rcsdata.h"
#include "rcsintf.h"
#include "rcsalert.h"
#include "rcsfiles.h"
#include "rcsvdi.h"
#include "rcswrite.h"

typedef	struct	outobj
{
	WORD	next;
	WORD	head;
	WORD	tail;
	BYTE	*type;
	BYTE	*flags;
	BYTE	*state;
	LONG	spec;
	UWORD	x;
	UWORD	y;
	UWORD	w;
	UWORD	h;
} OUTOBJ;

typedef struct 	h_out
{
	BYTE	*p0;
	WORD	p1;
	WORD	p2;
} HOUT;

LOCAL VOID do_tally(VOID)
{
	clr_tally();
	map_all((fkt_parm)tally_obj);
	tally_free();
	rcs_tally.nbytes += LWGET(RSH_NTREE(head)) * sizeof(LONG);
	rcs_tally.nbytes += sizeof(RSHDR);
}

LOCAL LONG get_dspace(WORD drv)
{
	LONG	dsk_avail;
#if GEMDOS
	DISKINFO dsk_free_buf;

	Dfree(&dsk_free_buf, drv);
	dsk_avail = dsk_free_buf.b_free *
		dsk_free_buf.b_secsiz *
		dsk_free_buf.b_clsiz;
#else
	LONG	dsk_tot;

	dos_space( drv, &dsk_tot, &dsk_avail);
#endif
	return ( dsk_avail );
}

LOCAL WORD dspace(WORD drv, UWORD nbytes)
{
	LONG	dsk_avail;
#if GEMDOS
	DISKINFO dsk_free_buf;

	Dfree(&dsk_free_buf, drv);
	dsk_avail = dsk_free_buf.b_free *
		dsk_free_buf.b_secsiz *
		dsk_free_buf.b_clsiz;
#else
	LONG	dsk_tot;

	dos_space( drv, &dsk_tot, &dsk_avail);
#endif
	if ( nbytes < (UWORD) dsk_avail )
		return (FALSE);
	else
		return (TRUE);
}

#if MC68K
/* the following two routines were written to simulate the */
/* ibm pc file structure for "*.def" files. */

UWORD swap_bytes(UWORD x)
{
	return ( ((UWORD) LLOBT(x) << 8 ) | (UWORD) LHIBT(x) );
}

LOCAL VOID wr_68kdef(VOID)
{
	UWORD	idx, wr_ndxno,wr_val, wr_kind;
	
	wr_ndxno = swap_bytes(rcs_ndxno);
	fwrite( &wr_ndxno, 1, 2, rcs_dhndl );
	for ( idx = 0; idx < rcs_ndxno; idx++ )
	{
		wr_val = swap_bytes( (UWORD) rcs_index[idx].val );
		fwrite( &wr_val, 1, 2, rcs_dhndl );
		wr_kind = swap_bytes( rcs_index[idx].kind );
		fwrite( &wr_kind, 1, 2, rcs_dhndl );
		fwrite( &rcs_index[idx].name[0], 1, 10, rcs_dhndl );
	}
}
#else
LOCAL VOID wr_i8086def(VOID)
{
	UWORD	idx, wr_ndxno,wr_val, wr_kind;

	wr_ndxno = rcs_ndxno;
	fwrite(&wr_ndxno, 1, 2, rcs_fdhndl);
	for ( idx = 0; idx < rcs_ndxno; idx++ )
	{
		wr_val =  (UWORD) rcs_index[idx].val;

		fwrite(&wr_val, 1, 2, rcs_fdhndl);
		wr_kind = rcs_index[idx].kind;
		fwrite(&wr_kind,                1,  2, rcs_fdhndl);
		fwrite(&rcs_index[idx].name[0], 1, 10, rcs_fdhndl);
	}
}
#endif

LOCAL WORD c_imgno(LONG addr)
{
	WORD	imgno;

	if (addr == NIL)
		return (NIL);
	else
	{
		for (imgno = 0; imgno < c_nimage; imgno++)
			if ( (WORD) addr == c_obndx[imgno + c_nstring])
				return (imgno);
		return (NIL);
  	}
}

LOCAL WORD c_strno(LONG addr)
{
	WORD	strno;

	if (addr == NIL)
		return (NIL);
	else
	{
		for (strno = 0; strno < c_nstring; strno++)
			if ( (WORD) addr == c_obndx[strno])
				return (strno);
		return (NIL);
	}
}

LOCAL VOID c_wrlin(VOID)
{
	fputs( hline, rcs_hhndl );
}

LOCAL VOID c_comma(WORD yesno)
{
	if (yesno)
	{
		strcpy(hline, ",\n");
		c_wrlin();
	}
}

LOCAL VOID c_tail(WORD used)
{
	if (rcs_cflag)
	{
		if (!used)
			strcpy(hline, "0};\n");
		else
			strcpy(hline, "};\n");
		c_wrlin();
	}
}

LOCAL VOID wr_sync(VOID)
{
	if (rcs_wraddr & 0x1)
	{
		fwrite("", 1, 1, rcs_rhndl);
		rcs_wraddr++;
	}
}

LOCAL VOID wr_header(VOID)
{
	fseek(rcs_rhndl, 0, SEEK_SET);
	fwrite((void *)head, sizeof(RSHDR), 1, rcs_rhndl);
}

LOCAL VOID c_defline(BYTE *name, WORD val)
{
	sprintf(hline, "#define %s %hd\n", name, val);
	c_wrlin();
}

LOCAL VOID c_baseline(WORD num, BYTE *field, WORD val)
{
	BYTE	name[9];

	sprintf(name, "T%hd%s", num, field);
	c_defline(name, val);
}

LOCAL VOID c_bases(VOID)
{
	WORD	i;

	if (rcs_cflag)
	{
		clr_tally();
		for (i = 0; i < LWGET(RSH_NTREE(head)); i++)
		{
			c_baseline(i, "OBJ", rcs_tally.nobj);
/*			c_baseline(i, "IB", rcs_tally.nib);	*/
/*			c_baseline(i, "BB", rcs_tally.nbb);	*/
/*			c_baseline(i, "TI", rcs_tally.nti);	*/
/*			c_baseline(i, "IMG", rcs_tally.nimg);	*/
/*			c_baseline(i, "STR", rcs_tally.nstr);	*/
			map_tree( tree_addr(i), ROOT, NIL, (fkt_parm)tally_obj);
		}
		c_defline("FREEBB", rcs_tally.nbb);
		c_defline("FREEIMG", rcs_tally.nimg);
		c_defline("FREESTR", rcs_tally.nstr);
	}
}

LOCAL VOID c_strhead(VOID)
{
	if (rcs_cflag)
	{
		strcpy(hline, "\nBYTE *rs_strings[] = {\n");
		c_wrlin();
		c_nstring = 0;
	}
}

LOCAL VOID c_string(LONG addr)
{
	WORD	hsub;
	BYTE	hchar;

	if (rcs_cflag)
	{
		c_comma(c_nstring);

		hline[0] = '"';
		hsub = 1;

		do {
			hchar = LBGET(addr++);
			if (hchar == '"')
				hline[hsub++] = '\\';
			else if (hchar == '\\')
				hline[hsub++] = '\\';
			if (!hchar)
				hline[hsub++] = '"';
			hline[hsub++] = hchar;
			if (hchar && hsub == 70)
			{
				hline[hsub] = '\0';
				strcat(hline, "\\\n");
				c_wrlin();
				hsub = 0;
			}
		} while (hchar);

		c_wrlin();
		c_obndx[c_nstring++] = rcs_wraddr;
	}
}

LOCAL VOID wr_str(LONG where)
{
	LONG	staddr;
	WORD	stlen;

	staddr = LLGET(where);
	if ( staddr != -1L)
	{
		c_string(staddr);
		LLSET(where, (LONG) rcs_wraddr & 0xffff);
		stlen = 1 + (WORD)LSTRLEN(staddr);
		fwrite((void *)staddr, 1, stlen, rcs_rhndl);
		rcs_wraddr += stlen;
	}
}

LOCAL VOID wr_string(LONG tree, WORD which)
{
	LONG	iconblk, tedinfo;
	WORD	type;

	type = LLOBT(GET_TYPE(tree, which));
	if (type == G_BUTTON || type == G_STRING || type == G_TITLE)
		wr_str(OB_SPEC(which));
	else if (type == G_ICON)
	{
		if ( (iconblk = GET_SPEC(tree, which)) != -1L)
			wr_str(IB_PTEXT(iconblk));
	}
	else if (type == G_TEXT || type == G_BOXTEXT ||
		type == G_FTEXT || type == G_FBOXTEXT) 
	{
		tedinfo = GET_SPEC(tree, which);
		if (tedinfo != -1L)
		{
			wr_str(tedinfo);
			wr_str(TE_PTMPLT(tedinfo));
			wr_str(TE_PVALID(tedinfo));
		}
	}
}

LOCAL VOID map_frstr(VOID)
{
	WORD	ifree, nfree;

	c_frstr = c_nstring;
	nfree = LWGET(RSH_NSTRING(head));
	if ( nfree )
	{
		for (ifree = 0; ifree < nfree; ifree++)
			wr_str(str_ptr(ifree));
	}
}

LOCAL VOID c_frshead(VOID)
{
	if (rcs_cflag)
	{
		strcpy(hline, "\nLONG rs_frstr[] = {\n");
		c_wrlin();
		c_nfrstr = 0;
	}
}

LOCAL VOID c_freestr(WORD which)
{
	if (rcs_cflag)
	{
		c_comma(c_nfrstr);
		which += c_frstr;
		sprintf(hline, "%hdL", which);
		c_wrlin();
		c_nfrstr++;
	}
}

LOCAL VOID wr_freestr(VOID)
{
	WORD	ifree, nfree;

	nfree = LWGET(RSH_NSTRING(head));
	if ( nfree )
	{
		for (ifree = 0; ifree < nfree; c_freestr(ifree++))
			;
		nfree *= (WORD)sizeof(LONG);
		fwrite((void *)str_ptr(0), 1, nfree, rcs_rhndl);
		LWSET(RSH_FRSTR(head), rcs_wraddr);
		rcs_wraddr += nfree;
	}
}

LOCAL VOID c_imdata(LONG addr, WORD size)
{
	WORD	iwd, vwd;

	if (rcs_cflag)
	{
		sprintf(hline, "\nWORD IMAG%hd[] = {", c_nimage);
		c_wrlin();

		for (iwd = 0; iwd < size; iwd += 2)
		{
			if (iwd)
			{
				strcpy(hline, ", ");
				c_wrlin();
			}
			if (iwd % 8 == 0)
			{
				strcpy(hline, "\n");
				c_wrlin();
			}
			vwd = LWGET(addr + iwd);
			sprintf(hline, "0x%hX", vwd);
			c_wrlin();
		}

		c_tail(TRUE);
		c_obndx[c_nstring + c_nimage++] = rcs_wraddr;
	}
}

LOCAL VOID wr_imdata(LONG where, WORD w, WORD h)
{
	WORD	size;
	LONG	imaddr;

	imaddr = LLGET(where);
	if ( imaddr != -1L)
	{
		size = w * h;
		gsx_untrans(imaddr, w, (LONG)ADDR(wr_obndx), w, h);
		imaddr = (LONG)ADDR(wr_obndx);
		c_imdata(imaddr, size);
		LLSET(where, (LONG) rcs_wraddr & 0xffff);
		fwrite((void *)imaddr, 1, size, rcs_rhndl);
		rcs_wraddr += size;
	}
}

LOCAL VOID wr_image(LONG tree, WORD which)
{
	LONG	iconblk, bitblk;
	WORD	type, w, h;

	type = LLOBT(GET_TYPE(tree, which));
	if (type == G_IMAGE)
	{
		bitblk = GET_SPEC(tree, which);
		if ( bitblk != -1L)
		{
			w = LWGET(BI_WB(bitblk));
			h = LWGET(BI_HL(bitblk));
			wr_imdata(BI_PDATA(bitblk), w, h);
		}
	}
	else if (type == G_ICON)
	{
		iconblk = GET_SPEC(tree, which);
		if ( iconblk != -1L)
		{
			w = (LWGET(IB_WICON(iconblk)) + 7) / 8;
			h = LWGET(IB_HICON(iconblk));
			wr_imdata(IB_PMASK(iconblk), w, h);
			wr_imdata(IB_PDATA(iconblk), w, h);
		}
	}
}

LOCAL VOID map_frimg(VOID)
{
	WORD	ifree, nfree, w, h;
	LONG	bitblk;

	nfree = LWGET(RSH_NIMAGES(head));
	if ( nfree )
	{
		for (ifree = 0; ifree < nfree; ifree++)
		{
			if ( (bitblk = img_addr(ifree)) == -1L)
				break;
			w = LWGET(BI_WB(bitblk));
			h = LWGET(BI_HL(bitblk));
			wr_imdata(bitblk, w, h);
		}
	}
}

LOCAL VOID c_foobar(VOID)
{
	WORD	img;

	if (rcs_cflag)
	{
		strcpy(hline, "\nstruct foobar {\n\tWORD\tdummy;");
		c_wrlin();
		strcpy(hline, "\n\tWORD\t*image;\n\t} rs_imdope[] = {\n");
		c_wrlin();

		for (img = 0; img < c_nimage; img++)
		{
			c_comma(img);
			sprintf(hline, "0, &IMAG%hd[0]", img);
			c_wrlin();
		}

		c_tail(img);
	}
}

LOCAL VOID c_iconhead(VOID)
{
	if (rcs_cflag)
	{
		strcpy(hline, "\nICONBLK rs_iconblk[] = {\n");
		c_wrlin();
		c_nib = 0;
	}
}

LOCAL VOID c_iconblk(LONG addr)
{
	ICONBLK	here;

	if (rcs_cflag)
	{
		LBCOPY(ADDR(&here), addr, sizeof(ICONBLK) );
		here.ib_pdata = (WORD FAR *) c_imgno((LONG)here.ib_pdata);
		here.ib_pmask = (WORD FAR *) c_imgno((LONG)here.ib_pmask);
		here.ib_ptext = (BYTE FAR *) c_strno((LONG)here.ib_ptext);
		c_comma(c_nib);
		sprintf(hline, "%ldL, %ldL, %ldL, %hd,%hd,%hd, %hd,%hd,%hd,%hd, %hd,%hd,%hd,%hd",
			(LONG)here.ib_pmask, (LONG)here.ib_pdata, (LONG)here.ib_ptext,
			here.ib_char, here.ib_xchar, here.ib_ychar,
			here.ib_xicon, here.ib_yicon, here.ib_wicon, here.ib_hicon,
			here.ib_xtext, here.ib_ytext, here.ib_wtext, here.ib_htext );
		c_wrlin();
		c_nib++;
	}
}

LOCAL VOID wr_iconblk(LONG tree, WORD which)
{
	LONG	iconblk;

	if (LLOBT(GET_TYPE(tree, which)) == G_ICON)
	{
		iconblk = GET_SPEC(tree, which);
		if ( iconblk != -1L)
		{
			SET_SPEC(tree, which, (LONG) rcs_wraddr & 0xffff);
			fwrite((void *)iconblk, sizeof(ICONBLK), 1, rcs_rhndl);
			rcs_wraddr += (WORD)sizeof(ICONBLK);
			LWINC(RSH_NIB(head));
			c_iconblk(iconblk);
		}
	}
}

LOCAL VOID c_bithead(VOID)
{
	if (rcs_cflag)
	{
		strcpy(hline, "\nBITBLK rs_bitblk[] = {\n");
		c_wrlin();
		c_nbb = 0;
	}
}

LOCAL VOID c_bitblk(LONG addr)
{
	BITBLK	here;

	if (rcs_cflag)
	{
		LBCOPY((LONG)ADDR(&here), addr, sizeof(BITBLK) );
		here.bi_pdata = (WORD *) c_imgno((LONG)here.bi_pdata);
		c_comma(c_nbb);
		sprintf(hline, "%ldL, %hd, %hd, %hd, %hd, %hd",
			(LONG)here.bi_pdata, here.bi_wb, here.bi_hl,
			here.bi_x, here.bi_y, here.bi_color );
		c_wrlin();
		c_nbb++;
	}
}

LOCAL VOID wr_bitblk(LONG tree, WORD which)
{
	LONG	bitblk;

	if (LLOBT(GET_TYPE(tree, which)) == G_IMAGE)
	{
		bitblk = GET_SPEC(tree, which);
		if ( bitblk != -1L)
		{
			SET_SPEC(tree, which, (LONG) rcs_wraddr & 0xffff);
			fwrite((void *)bitblk, sizeof(BITBLK), 1, rcs_rhndl);
			rcs_wraddr += (WORD)sizeof(BITBLK);
			LWINC(RSH_NBB(head));
			c_bitblk(bitblk);
		}
	}
}

LOCAL VOID map_frbit(VOID)
{
	WORD	ifree, nfree;
	LONG	bitblk;

	nfree = LWGET(RSH_NIMAGES(head));
	if ( nfree )
	{
		for (ifree = 0; ifree < nfree; ifree++)
		{
			if ( (bitblk = img_addr(ifree)) == -1L)
				break;
			LLSET(img_ptr(ifree), (LONG) rcs_wraddr & 0xffff);
			fwrite((void *)bitblk, sizeof(BITBLK), 1, rcs_rhndl);
			rcs_wraddr += (WORD)sizeof(BITBLK);
			LWINC(RSH_NBB(head));
			c_bitblk(bitblk);
		}
	}
} 

LOCAL VOID c_frbhead(VOID)
{
	if (rcs_cflag)
	{
		strcpy(hline, "\nLONG rs_frimg[] = {\n");
		c_wrlin();
		c_nfrbit = 0;
	}
}

LOCAL VOID c_frb(LONG addr)
{
	WORD	blkno;

	if (rcs_cflag)
	{
		blkno = (WORD) ((addr - LWGET(RSH_BITBLK(head))) / sizeof(BITBLK));
		c_comma(c_nfrbit);
		sprintf(hline, "%hdL", blkno);
		c_wrlin();
		c_nfrbit++;
	}
}

LOCAL VOID wr_frbit(VOID)
{
	WORD	ifree, nfree;

	nfree = LWGET(RSH_NIMAGES(head));
	if ( nfree )
	{
		for (ifree = 0; ifree < nfree; ifree++)
			c_frb(img_addr(ifree));
		nfree *= (WORD)sizeof(LONG);
		fwrite((void *)img_ptr(0), 1, nfree, rcs_rhndl);
		LWSET(RSH_FRIMG(head), rcs_wraddr);
		rcs_wraddr += nfree;
	}
} 

LOCAL VOID c_tedhead(VOID)
{
	if (rcs_cflag)
	{
		strcpy(hline, "\nTEDINFO rs_tedinfo[] = {\n");
		c_wrlin();
		c_nted = 0;
	}
}

LOCAL VOID c_tedinfo(LONG addr)
{
	TEDINFO	here;

	if (rcs_cflag)
	{
		LBCOPY(ADDR(&here), addr, sizeof(TEDINFO));
		here.te_ptext = (BYTE *) c_strno((LONG)here.te_ptext);
		here.te_pvalid = (BYTE *) c_strno((LONG)here.te_pvalid);
		here.te_ptmplt = (BYTE *) c_strno((LONG)here.te_ptmplt);
		c_comma(c_nted);
		sprintf(hline, "%ldL, %ldL, %ldL, %hd, %hd, %hd, 0x%hX, 0x%hX, %hd, %hd,%hd",
			(LONG)here.te_ptext, (LONG)here.te_ptmplt, (LONG)here.te_pvalid,
			here.te_font, here.te_junk1, here.te_just, here.te_color,
			here.te_junk2, here.te_thickness, here.te_txtlen, here.te_tmplen );
		c_wrlin();
		c_nted++;
	}
}
	
LOCAL VOID wr_tedinfo(LONG tree, WORD which)
{
	LONG	tedinfo;
	WORD	type;

	type = LLOBT(GET_TYPE(tree, which));
	if ( type == G_TEXT || type == G_BOXTEXT || 
		type == G_FTEXT || type == G_FBOXTEXT )
	{
		tedinfo = GET_SPEC(tree, which);
		if ( tedinfo != -1L)
		{
			SET_SPEC(tree, which, (LONG) rcs_wraddr & 0xffff);
			fwrite((void *)tedinfo, sizeof(TEDINFO), 1, rcs_rhndl);
			rcs_wraddr += (WORD)sizeof(TEDINFO);
			LWINC(RSH_NTED(head));
			c_tedinfo(tedinfo);
		}
	}
}

LOCAL VOID c_objhead(VOID)
{
	if (rcs_cflag)
	{
		strcpy(hline, "\nOBJECT rs_object[] = {\n");
		c_wrlin();
		c_nobs = 0;
	}
}

LOCAL VOID c_object(LONG tree)
{
	OUTOBJ	here;
	BYTE	type[10], state[10], flags[10];

	if (rcs_cflag)
	{
		LBCOPY(ADDR(&here.next), OB_NEXT(ROOT), 3 * sizeof(WORD) );
		LBCOPY(ADDR(&here.spec), OB_SPEC(ROOT), sizeof(LONG) + 4 * sizeof(UWORD) );

		switch (LLOBT(GET_TYPE(tree, ROOT)))
		{
			case G_STRING:
			case G_BUTTON:
			case G_TITLE:
				here.spec = (LONG) c_strno(here.spec);
				break;
			case G_TEXT:
			case G_FTEXT:
			case G_BOXTEXT:
			case G_FBOXTEXT:
				here.spec = ( (WORD) here.spec - LWGET(RSH_TEDINFO(head)) )
					/ sizeof(TEDINFO);
				break;
			case G_IMAGE:
				here.spec = ( (WORD) here.spec - LWGET(RSH_BITBLK(head)) )
					/ sizeof(BITBLK);
				break;
			case G_ICON:
				here.spec = ( (WORD) here.spec - LWGET(RSH_ICONBLK(head)) )
					/ sizeof(ICONBLK);
				break;
			default:
				break;
		}

		c_comma(c_nobs);
		here.type = c_lookup(LLOBT(GET_TYPE(tree, ROOT)), c_types, N_TYPES, type);
		here.flags = c_lookup(GET_FLAGS(tree, ROOT), c_flags, 
			N_FLAGS, flags);
		here.state = c_lookup(GET_STATE(tree, ROOT), c_states, 
			N_STATES, state);
		sprintf(hline, "%hd, %hd, %hd, %s, %s, %s, 0x%lX, %hd,%hd, %hd, %hd",
			here.next, here.head, here.tail,
			here.type, here.flags, here.state,
			here.spec, here.x, here.y, here.w, here.h );
		c_wrlin();
		c_nobs++;
	}
}

LOCAL VOID wr_obj(WORD itree, LONG tree, WORD iobj)
/* refers to position in the preorder 	*/
/* trace stored in wr_obndx[]		*/
{
	WORD	entno, where, link, obtype;
	LONG	object;

	where = wr_obndx[iobj];		/* the actual object #	*/

	entno = find_obj(tree, where);
	if (entno != NIL)
		set_value(entno, (BYTE *) ( 
			((itree & 0xFF) << 8) | (iobj & 0xFF) ) );
	if ( (link = GET_NEXT(tree, where)) != -1)
		SET_NEXT(tree, where, fnd_ob(link));
	if ( (link = GET_HEAD(tree, where)) != -1)
		SET_HEAD(tree, where, fnd_ob(link));
	if ( (link = GET_TAIL(tree, where)) != -1)
		SET_TAIL(tree, where, fnd_ob(link));
	obtype = GET_TYPE(tree, where) & 0x00ff; /*low byte*/
	if(obtype == G_ICON || obtype == G_IMAGE) /*0 hi byte*/
		LWSET(OB_TYPE(where), obtype);
	unfix_chpos(OB_X(where), 0);
	unfix_chpos(OB_WIDTH(where), 0);
	unfix_chpos(OB_Y(where), 1);
	unfix_chpos(OB_HEIGHT(where), 1);
	object = tree + (UWORD) (where * sizeof(OBJECT));
	fwrite((void *)object, sizeof(OBJECT), 1, rcs_rhndl);
	rcs_wraddr += (WORD)sizeof(OBJECT);
	c_object(object);
}

LOCAL VOID wr_trees(VOID)
{
	LONG	tree;
	WORD	ntree, itree, iobj, where, flags;

	ntree = LWGET(RSH_NTREE(head));

	for (itree = 0; itree < ntree; itree++)
	{
		where = find_tree(itree);
		set_value(where, (BYTE *) itree);
		tree = tree_addr(itree);
		LLSET(tree_ptr(itree), (LONG) rcs_wraddr & 0xffff);
		wr_obnum = 0;
		map_tree(tree, 0, -1, (fkt_parm)indx_obs);
		LWSET(RSH_NOBS(head), wr_obnum + LWGET(RSH_NOBS(head)));
		iobj = wr_obndx[wr_obnum - 1];
		flags = GET_FLAGS(tree, iobj);
		SET_FLAGS(tree, iobj, flags | LASTOB);
		for (iobj = 0; iobj < wr_obnum; iobj++)
			wr_obj(itree, tree, iobj);
	}
}

LOCAL VOID c_treehead(VOID)
{
	if (rcs_cflag)
	{
		strcpy(hline, "\nLONG rs_trindex[] = {\n");
		c_wrlin();
		c_ntree = 0;
	}
}

LOCAL VOID c_tree(LONG addr)
{
	WORD	objno;

	if (rcs_cflag)
	{
		objno = (WORD) (addr - LWGET(RSH_OBJECT(head)) / sizeof(OBJECT));
		c_comma(c_ntree);
		sprintf(hline, "%hdL", objno);
		c_wrlin();
		c_ntree++;
	}
}

LOCAL VOID wr_trindex(VOID)
{
	WORD	ntree, itree;

	ntree = LWGET(RSH_NTREE(head));
	fwrite((void *)tree_ptr(0), sizeof(LONG), ntree, rcs_rhndl);

	for (itree = 0; itree < ntree; itree++)
		c_tree(tree_addr(itree));

	LWSET(RSH_TRINDEX(head), rcs_wraddr);	/* Don't move this line! */
	rcs_wraddr += ntree * (WORD)sizeof(LONG);
}

LOCAL VOID c_defs(VOID)
{
	BYTE	*rptr, *sptr;

	if (rcs_cflag)
	{
		strcpy(hline, "\n");
		c_wrlin();
		c_defline("NUM_STRINGS", c_nstring);
		c_defline("NUM_FRSTR", LWGET(RSH_NSTRING(head)));
		c_defline("NUM_IMAGES", c_nimage);
		c_defline("NUM_BB", LWGET(RSH_NBB(head)));
		c_defline("NUM_FRIMG", LWGET(RSH_NIMAGES(head)));
		c_defline("NUM_IB", LWGET(RSH_NIB(head)));
		c_defline("NUM_TI", LWGET(RSH_NTED(head)));
		c_defline("NUM_OBS", LWGET(RSH_NOBS(head)));
		c_defline("NUM_TREE", LWGET(RSH_NTREE(head)));
		for (sptr = rptr = &rcs_rfile[0]; *sptr; sptr++)
			if (*sptr == '\\' || *sptr == '\:')
				rptr = sptr + 1;
		sprintf(hline, "\nBYTE pname[] = \"%s\";", rptr);
		c_wrlin();
		hline[0] = '\032';
		hline[1] = '\0';
		c_wrlin();
	}
}

LOCAL VOID wr_include(WORD deftype, WORD ndx, WORD ndef, BYTE *ptns[], WORD trflag)
{
	WORD	idx, ii;
	HOUT	h;

	for ( idx = 0; idx < ndx; idx++ )
	{
		for ( ii = 0; ii < rcs_ndxno; ii++)
		{
			if((trflag && get_kind(ii) < 4)	|| ( get_kind(ii) == deftype ))
			{
				if ( (WORD) get_value(ii) == idx)
				{
					strup(h.p0 = get_name(ii));
					h.p1 = idx;	
					sprintf(hline, ptns[ndef], h.p0, h.p1);
					fputs(hline, rcs_hhndl);
					break;
				}
			}
		}
	}
}

LOCAL VOID obj_include(WORD ntree, WORD nobs, BYTE *ptns[])
{
	WORD	itree,  iobs, ii;
	HOUT	h;
	
	for ( itree = 0; itree < ntree; itree++ )
	{
		for ( iobs = 0; iobs < nobs; iobs++)
		{
	    	for ( ii = 0; ii < rcs_ndxno; ii++ )
	    	{
				if ( get_kind(ii) == OBJKIND)
				{
					h.p1 = (WORD) get_value(ii);
					h.p2 = (WORD) LHIBT(h.p1) & 0xff;
					h.p1 = (WORD) LLOBT(h.p1) & 0xff;
					if ( h.p2 == itree && h.p1 == iobs)
					{
						strup(h.p0 = get_name(ii));
						sprintf(hline, ptns[2], h.p0, h.p1, h.p2);
						fputs(hline, rcs_hhndl);
						break;
					}
				}
			}
		}
	}
}

LOCAL VOID wrsrt_inclfile(BYTE *ext, BYTE *ptns[])
{
	r_to_xfile(rcs_hfile, ext);

	FOREVER
	{
		rcs_hhndl = fopen(rcs_hfile, "w");
		if (rcs_hhndl != NULL)
			break;
		else if (!form_error(errno))
			return;
	}
	wr_include( UNKN,  LWGET(RSH_NTREE(head)), 0, ptns,TRUE );
	obj_include( LWGET(RSH_NTREE(head)), LWGET(RSH_NOBS(head)), ptns );
	wr_include(ALRT, LWGET(RSH_NSTRING(head)), 1, ptns, FALSE);
	wr_include(FRSTR,LWGET(RSH_NSTRING(head)), 3, ptns, FALSE);
	wr_include(FRIMG,LWGET(RSH_NIMAGES(head)), 4, ptns, FALSE);
	fclose(rcs_hhndl);
}

LOCAL VOID write_inclfile(BYTE *ext, BYTE *ptns[])
{
	WORD	ii;
	HOUT	h;

	r_to_xfile(rcs_hfile, ext);

	FOREVER
	{
		rcs_hhndl = fopen(rcs_hfile, "w");
		if (rcs_hhndl != NULL)
			break;
		else if (!form_error(errno))
			return;
	}

	for (ii = 0; ii < rcs_ndxno; ii++)
	{
		strup(h.p0 = get_name(ii));
		h.p1 = (WORD) get_value(ii);
		switch ( get_kind(ii) )
		{
			case UNKN:
			case PANL:
			case DIAL:
			case MENU:
				sprintf(hline, ptns[0], h.p0, h.p1);
				break;
			case ALRT:
				sprintf(hline, ptns[1], h.p0, h.p1);
				break;
			case OBJKIND:
				h.p2 = (WORD) LHIBT(h.p1) & 0xff;
				h.p1 = (WORD) LLOBT(h.p1) & 0xff;
				sprintf(hline, ptns[2], h.p0, h.p1, h.p2);
				break;
			case FRSTR:
				sprintf(hline, ptns[3], h.p0, h.p1);
				break;
			case FRIMG:
				sprintf(hline, ptns[4], h.p0, h.p1);
				break;
			default:
				break;
		}
		fputs(hline, rcs_hhndl);
	}
	fclose(rcs_hhndl);
}

WORD write_files(VOID)
{
	LONG	mem_needs;
	
	do_tally();			 
	if (rcs_cflag)
		mem_needs = 3 * rcs_tally.nbytes;
	else
		mem_needs = (rcs_tally.nbytes >> 1) + rcs_tally.nbytes;

	if( mem_needs > get_dspace( rcs_rfile[0] - 'A' + 1 ) )
	{
		hndl_alert(1, string_addr(SNDSPACE));
		return(FALSE);
	}

	FOREVER
	{
		rcs_rhndl = fopen(rcs_rfile,"wb");
		if (rcs_rhndl != NULL)
			break;
		if (!form_error(errno))
			return (FALSE);
	}

	if (rcs_cflag)
	{
		r_to_xfile(rcs_hfile, "RSH");
		FOREVER
		{
			rcs_hhndl = fopen(rcs_hfile, "w");
			if (rcs_hhndl != NULL)
				break;
			if (!form_error(errno))
			{
				fclose(rcs_rhndl);
				return (FALSE);
			}
		}
	}		       
	dcomp_free();
	dcomp_alerts();

	ini_prog();
	show_prog(STHDR);
	wr_header();
	rcs_wraddr = (WORD)sizeof(RSHDR);
	LWSET(RSH_STRING(head), rcs_wraddr);
	c_bases();

	show_prog(STSTR);
	c_strhead();
	map_all((fkt_parm)wr_string);
	map_frstr();		/* handles strings not ref'ed in objects */
	c_tail(c_nstring);
	wr_sync();

	show_prog(STIMG);
	LWSET(RSH_IMDATA(head), rcs_wraddr);
	c_nimage = 0;
	map_all((fkt_parm)wr_image);
	c_frimg = c_nimage;
	map_frimg();

	show_prog(STFRSTR);
	c_frshead();
	wr_freestr();
	c_tail(c_nfrstr);

	show_prog(STBB);
	LWSET(RSH_BITBLK(head), rcs_wraddr);
	LWSET(RSH_NBB(head), 0);
	c_bithead();
	map_all((fkt_parm)wr_bitblk);
	map_frbit();	
	c_tail(c_nbb);

	show_prog(STFRIMG);
	c_frbhead();
	wr_frbit();
	c_tail(c_nfrbit);

	show_prog(STIB);
	LWSET(RSH_ICONBLK(head), rcs_wraddr);
	LWSET(RSH_NIB(head), 0);
	c_iconhead();
	map_all((fkt_parm)wr_iconblk);
	c_tail(c_nib);

	show_prog(STTI);
	LWSET(RSH_TEDINFO(head), rcs_wraddr);
	LWSET(RSH_NTED(head), 0);
	c_tedhead();
	map_all((fkt_parm)wr_tedinfo);
	c_tail(c_nted);

	show_prog(STOBJ);
	LWSET(RSH_OBJECT(head), rcs_wraddr);
	LWSET(RSH_NOBS(head), 0);
	c_objhead();
	wr_trees();
	c_tail(c_nobs);

	show_prog(STTRIND);
	c_treehead();
	wr_trindex();		/* also handles RSH_TRINDEX(head) */
	c_tail(c_ntree);

	show_prog(STHDR);
	LWSET(RSH_RSSIZE(head), rcs_wraddr);
	wr_header();		/* rewrite updated header	  */
	fclose(rcs_rhndl);
	c_foobar();
	c_defs();
	if (rcs_cflag)
		fclose(rcs_hhndl);

	FOREVER
	{
		rcs_dhndl = fopen(rcs_dfile, "wb");
		if (rcs_dhndl != NULL)
			break;
		if (!form_error(errno))
			return (FALSE);
	}

	show_prog(STNAME);
#if	MC68K
   	wr_68kdef();
#else
	wr_i8086def();
#endif
	fclose(rcs_dhndl);

	if (rcs_hflag)
		if ( rcs_fsrtflag )
			wrsrt_inclfile("H", hptns);
		else
			write_inclfile("H", hptns);
	if (rcs_oflag)
		if (rcs_fsrtflag )
			wrsrt_inclfile("I", optns);
		else
			write_inclfile("I", optns);
	if (rcs_cbflag)
		if ( rcs_fsrtflag )
			wrsrt_inclfile("B", bptns);
		else
			write_inclfile("B", bptns);
	if (rcs_f77flag)
		if ( rcs_fsrtflag )
			wrsrt_inclfile("F", fptns);
		else
			write_inclfile("F", fptns);

	return (TRUE);
}
