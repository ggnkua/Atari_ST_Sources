 /*	RCSREAD.C	1/28/85 - 1/28/85	Tim Oren		*/
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
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
#include "rcsdata.h"
#include "rcslib.h"
#include "rcsintf.h"
#include "rcsalert.h"
#include "rcsfiles.h"
#include "rcswrite.h"
#include "rcsread.h"

#define ROB_TYPE (psubstruct + 6)	/* Long pointer in OBJECT	*/
#define ROB_FLAGS (psubstruct + 8)	/* Long pointer in OBJECT	*/
#define ROB_SPEC (psubstruct + 12)	/* Long pointer in OBJECT	*/

#define RTE_PTEXT (psubstruct + 0)	/* Long pointers in TEDINFO	*/
#define RTE_PTMPLT (psubstruct + 4)
#define RTE_PVALID (psubstruct + 8)
#define RTE_TXTLEN (psubstruct + 24)
#define RTE_TMPLEN (psubstruct + 26)

#define RIB_PMASK (psubstruct + 0)	/* Long pointers in ICONBLK	*/
#define RIB_PDATA (psubstruct + 4)
#define RIB_PTEXT (psubstruct + 8)

#define RBI_PDATA (psubstruct + 0)	/* Long pointer in BITBLK	*/
#define RBI_WB (psubstruct + 4)
#define RBI_HL (psubstruct + 6)
/* in global array		*/
#define APP_LOPNAME (rs_global + 12)
#define APP_LO1RESV (rs_global + 16)
#define APP_LO2RESV (rs_global + 20)

#if MC68K
LOCAL WORD read_68k(BOOLEAN merge)
/* simulate IBM PC data storage in "*.def" files. */
{
	UWORD	idx, old_ndxno, rd_ndxno, rd_val, rd_kind;

	if ( merge )
		old_ndxno = rcs_ndxno;
	else
		old_ndxno = 0;

	if ( fseek( rcs_dhndl, 0, SEEK_SET) )
		return( rcs_ndxno = 0 );
	else if (fread( &rd_ndxno, 1, 2, rcs_dhndl ) != 2)
		return( rcs_ndxno = 0);
	else
	{
		rcs_ndxno = swap_bytes( rd_ndxno );
		rcs_ndxno = old_ndxno + rcs_ndxno;
		for ( idx = old_ndxno; idx < rcs_ndxno; idx++)
		{
			if (fread( &rd_val, 1, 2, rcs_dhndl ) != 2)
				return( rcs_ndxno = 0 );
			else
			{
				rcs_index[idx].val = (BYTE *) ( LW(swap_bytes(rd_val)) & 0xffffL );
				if (fread( &rd_kind, 1, 2, rcs_dhndl ) != 2)
					return( rcs_ndxno = 0 );
				else
				{
					rcs_index[idx].kind = swap_bytes( rd_kind );
					if (fread( &rcs_index[idx].name[0], 1, 10, rcs_dhndl ) != 10)
						return( rcs_ndxno = 0 );
				}
			}
		}
		return( rcs_ndxno );
	}
}
#else
/* Does not rely on internal representation of INDEX struct */
LOCAL WORD read_i8086( BOOLEAN merge )
{
	UWORD	idx, old_ndxno, rd_ndxno, rd_val, rd_kind;

	if ( merge )
		old_ndxno = rcs_ndxno;
	else
	     old_ndxno = 0;

	if (fseek( rcs_fdhndl, 0x0L, SEEK_SET))
		return( rcs_ndxno = 0 );
	else if (fread(&rd_ndxno, 1, 2, rcs_fdhndl) < 2)
		return( rcs_ndxno = 0 );
	else if (ferror(rcs_fdhndl))
		return ( rcs_ndxno = 0 );
	else
	{
		rcs_ndxno = rd_ndxno;
		rcs_ndxno = old_ndxno + rcs_ndxno;
		for ( idx = old_ndxno; idx < rcs_ndxno; idx++)
	    {
	    	if (fread( &rd_val, 1, 2, rcs_fdhndl) < 2 )
	    		return( rcs_ndxno = 0 );
			rcs_index[idx].val = (BYTE *) ( LW(rd_val) & 0xffffL );
			if (fread( &rd_kind, 1, 2, rcs_fdhndl) < 2 )
				return( rcs_ndxno = 0 );
			rcs_index[idx].kind = rd_kind;
			if (fread( rcs_index[idx].name, 1, 10, rcs_fdhndl) < 10)
				return( rcs_ndxno = 0 );
	    }
		return( rcs_ndxno );
	}
}
#endif

WORD open_files(WORD def)
{
	WORD	ii;

	if (!def)
		if (!get_file(STLDRES))
			return (FALSE);
	FOREVER
	{
		rcs_rhndl = fopen(rcs_rfile, "rb");
		if (rcs_rhndl != NULL)
			break;
		if (!form_error(errno))
			return(FALSE);
	}
	FOREVER
	{
		rcs_dhndl = fopen(rcs_dfile, "rb");
		if (rcs_dhndl != NULL)
			return (TRUE);
		else
		{
			ii = hndl_alert(2, string_addr(STNODEF));
			if (ii == 1)
			{
				fclose( rcs_rhndl );
				return (FALSE);
			}
			if (ii == 2)
			{
				rcs_dhndl = NULL;
				return (TRUE);
			}
		}
	}
}

LOCAL LONG get_sub(UWORD rsindex, WORD rtype, WORD rsize)
{
	UWORD		offset;

	offset = LWGET( rs_hdr + LW(rtype*2) );
	/* get base of objects	*/
	/*   and then index in	*/
	return( rs_hdr + LW(offset) + LW(rsize * rsindex) );
}

/* return address of given type and index, INTERNAL ROUTINE */
LOCAL LONG get_addr(WORD rstype, WORD rsindex)
{
	LONG		psubstruct;
	WORD		size;
	WORD		rt;
	WORD		valid;

	valid = TRUE;
	switch(rstype)
	{
		case R_OBJECT:
			rt = RT_OB;
			size = (WORD)sizeof(OBJECT);
			break;
		case R_TEDINFO:
		case R_TEPTEXT:
			rt = RT_TEDINFO;
			size = (WORD)sizeof(TEDINFO);
			break;
		case R_ICONBLK:
		case R_IBPMASK:
			rt = RT_ICONBLK;
			size = (WORD)sizeof(ICONBLK);
			break;
		case R_BITBLK:
		case R_BIPDATA:
			rt = RT_BITBLK;
			size = (WORD)sizeof(BITBLK);
			break;
		case R_OBSPEC:
			psubstruct = get_addr(R_OBJECT, rsindex);
			return( ROB_SPEC );
		case R_TEPTMPLT:
		case R_TEPVALID:
			psubstruct = get_addr(R_TEDINFO, rsindex);
	  		if (rstype == R_TEPTMPLT)
				return( RTE_PTMPLT );
			else
				return( RTE_PVALID );
		case R_IBPDATA:
		case R_IBPTEXT:
			psubstruct = get_addr(R_ICONBLK, rsindex);
			if (rstype == R_IBPDATA)
				return( RIB_PDATA );
			else
				return( RIB_PTEXT );
		case R_STRING:
			return( LLGET( get_sub(rsindex, RT_FREESTR, (WORD)sizeof(LONG)) ) );
		case R_IMAGEDATA:
			return( LLGET( get_sub(rsindex, RT_FREEIMG, (WORD)sizeof(LONG)) ) );
		case R_FRSTR:
			rt = RT_FREESTR;
			size = (WORD)sizeof(LONG);
			break;
		case R_FRIMG:
			rt = RT_FREEIMG;
			size = (WORD)sizeof(LONG);
			break;
		default:
			valid = FALSE;
			break;
	}
	if (valid)
		return( get_sub(rsindex, rt, size) );
	else
		return(-1L);
} /* get_addr() */

LOCAL WORD fix_long(LONG plong)
{
	LONG		lngval;

	lngval = LLGET(plong);
	if (lngval != -1L)
	{
		LLSET(plong, rs_hdr + lngval);
		return(TRUE);
	}
	else
		return(FALSE);
}

LOCAL VOID fix_trindex(VOID)
{
	WORD		ii;
	LONG		ptreebase;

	ptreebase = get_sub(0, RT_TRINDEX, (WORD)sizeof(LONG));

	for (ii = NUM_TREE-1; ii >= 0; ii--)
		fix_long(ptreebase + LW(ii*4));
}

LOCAL WORD fix_ptr(WORD type, WORD index)
{
	return( fix_long( get_addr(type, index) ) );
}

LOCAL VOID fix_objects(VOID)
{
	WORD		ii;
	WORD		obtype, obflags;
	LONG		psubstruct;

	for (ii = NUM_OBS-1; ii >= 0; ii--)
	{
		psubstruct = get_addr(R_OBJECT, ii);
		rs_obfix(psubstruct, 0);
		obtype = LLOBT( LWGET( ROB_TYPE ) );
		switch (obtype)
		{
			case G_TEXT:
			case G_BOXTEXT:
			case G_FTEXT:
			case G_FBOXTEXT:
			case G_TITLE:
			case G_ICON:
			case G_IMAGE:
			case G_STRING:
			case G_BUTTON:
				fix_long(ROB_SPEC);
				break;
			default:
				break;
		}
		obflags = LWGET(ROB_FLAGS);	/* zap LASTOB's */
		LWSET(ROB_FLAGS, obflags & ~LASTOB);
	}
}

LOCAL VOID fix_tedinfo(VOID)
{
	WORD		ii, i;
	LONG		psubstruct, tl[2], ls[2];

	for (ii = NUM_TI-1; ii >= 0; ii--)
	{
		psubstruct = get_addr(R_TEDINFO, ii);
		tl[0] = tl[1] = 0x0L;
		if (fix_ptr(R_TEPTEXT, ii) )
		{
			tl[0] = RTE_TXTLEN;
			ls[0] = RTE_PTEXT;
		}
		if (fix_ptr(R_TEPTMPLT, ii) )
		{
			tl[1] = RTE_TMPLEN;
			ls[1] = RTE_PTMPLT;
		}
		for(i=0; i<2; i++)
		{
			if (tl[i])
				LWSET( tl[i], LSTRLEN( LLGET(ls[i]) ) + 1 );
		}
		fix_ptr(R_TEPVALID, ii);
	}
}

LOCAL VOID fix_iconblk(VOID)
{
	WORD		ii;

	for (ii = NUM_IB-1; ii >= 0; ii--)
	{
		fix_ptr(R_IBPMASK, ii);
		fix_ptr(R_IBPDATA, ii);
		fix_ptr(R_IBPTEXT, ii);
	}
}

LOCAL VOID fix_bitblk(VOID)
{
	WORD	ii;

	for (ii = NUM_BB-1; ii >= 0; ii--)
		fix_ptr(R_BIPDATA, ii);
}

LOCAL VOID fix_frstr(VOID)
{
	WORD	ii;

	for (ii = NUM_FRSTR-1; ii >= 0; ii--)
		fix_ptr(R_FRSTR, ii);
}

LOCAL VOID fix_frimg(VOID)
{
	WORD	ii;

	for (ii = NUM_FRIMG-1; ii >= 0; ii--)
		fix_ptr(R_FRIMG, ii);
}

LOCAL VOID fix_all(VOID)
{
	fix_trindex();
	fix_objects();
	fix_tedinfo();
	fix_iconblk();
	fix_bitblk();
	fix_frstr();
	fix_frimg();
}   

LOCAL VOID comp_str(LONG hdr)
{
	LONG	frstr, where, tree, maddr;
	WORD	istr, nstr, lstr, w, h, obj, ndex;
	BYTE	name[9];

	nstr = LWGET(RSH_NSTRING(hdr));
	if ( nstr )
	{
		frstr = hdr + LW( LWGET(RSH_FRSTR(hdr)) );

		ini_tree(&maddr, NEWPANEL);
		tree = copy_tree(maddr, ROOT, TRUE);
		add_trindex(tree);
		ini_tree(&maddr, FREEPBX);

		for (istr = 0; istr < nstr; istr++)
		{
			where = LLGET(frstr + (LONG) (istr * sizeof(LONG)));
			if (where != -1L)
			{
				lstr = (WORD)LSTRLEN(where);
				obj = copy_objs(maddr, PBXSTR, tree, FALSE);
				objc_add((OBJECT FAR *)tree, ROOT, obj);
				SET_SPEC(tree, obj, where);
				SET_WIDTH(tree, obj, gl_wchar * lstr);
				if ((ndex = find_value((BYTE *) where)) != NIL)
				{
					set_value(ndex, (BYTE *) (tree + 
						(LONG) (obj * sizeof(OBJECT))));
					set_kind(ndex, OBJKIND);
				}
			}
		}
		SET_WIDTH(tree, ROOT, 1);	/* fool arrange_tree into putting */
		arrange_tree(tree, 2 * gl_wchar, gl_hchar, &w, &h);
		SET_HEIGHT(tree, ROOT, h);	/* each on a different line */
		SET_WIDTH(tree, ROOT, max(w, 20 * gl_wchar));
		unique_name(&name[0], "FRSTR%hd", 1);	/* make up a name */
		new_index((BYTE *)tree, FREE, name);
		LWSET(RSH_NSTRING(hdr), 0);
	}
}

LOCAL VOID comp_img(LONG hdr)
{
	LONG	frimg, where, tree, maddr;
	WORD	iimg, nimg, w, h, obj, ndex;
	BYTE	name[9];

	nimg = LWGET(RSH_NIMAGES(hdr));
	if ( nimg )
	{
		frimg = hdr + LW( LWGET(RSH_FRIMG(hdr)) );

		ini_tree(&maddr, NEWPANEL);
		tree = copy_tree(maddr, ROOT, TRUE);
		add_trindex(tree);
		ini_tree(&maddr, FREEPBX);

		for (iimg = 0; iimg < nimg; iimg++)
		{
			where = LLGET(frimg + (UWORD) (iimg * sizeof(LONG)));
			obj = copy_objs(maddr, PBXIMG, tree, FALSE);
			objc_add((OBJECT FAR *)tree, ROOT, obj);
			SET_SPEC(tree, obj, where);
			SET_HEIGHT(tree, obj, LWGET(BI_HL(where)));
			SET_WIDTH(tree, obj, LWGET(BI_WB(where)) << 3);
			if ((ndex = find_value((BYTE *) where)) != NIL)
			{
				set_value(ndex, (BYTE *) (tree + 
					(UWORD) (obj * sizeof(OBJECT))));
				set_kind(ndex, OBJKIND);
			}
		}
		SET_WIDTH(tree, ROOT, full.g_w);	
		arrange_tree(tree, 2 * gl_wchar, gl_hchar, &w, &h);
		SET_HEIGHT(tree, ROOT, h);	
		SET_WIDTH(tree, ROOT, w);
		map_tree(tree, ROOT, NIL, (fkt_parm)trans_obj);
		unique_name(&name[0], "FRIMG%hd", 1);	/* make up a name */
		new_index((BYTE *)tree, FREE, name);
		LWSET(RSH_NIMAGES(hdr), 0);
	}
}

WORD read_files(VOID)
{
	WORD	ii;
	WORD	ntree, nobj;
	BYTE	name[9];

	if ( ad_clip ) 
		clr_clip();
	ini_buff();
	if ( !dmcopy(rcs_rhndl, 0x0L, head, (WORD)sizeof(RSHDR)))
	{
		fclose(rcs_rhndl);
		ini_buff();
		return (FALSE);
	}
	else if (avail_mem() < LW( LWGET(RSH_RSSIZE(head)) )) 
	{
		hndl_alert(1, string_addr(STNROOM) );
		ini_buff();
		return (FALSE);
	}
	else
	{
		if (!dmcopy(rcs_rhndl, (LONG)sizeof(RSHDR),
				head + sizeof(RSHDR),
				LWGET(RSH_RSSIZE(head)) - (WORD)sizeof(RSHDR)))
		{
			fclose(rcs_rhndl);
			ini_buff();
			return(FALSE);
		}
		else
		{
			fclose(rcs_rhndl);
			rcs_free = (head + LW( LWGET(RSH_RSSIZE(head)) ) );

#if	  MC68K   /* memory can only be written on even boundary */
			if (rcs_free & 0x1) 
	    		rcs_free++;
#endif

			rs_hdr = head;
			fix_all();
			map_all((fkt_parm)trans_obj);

			if (!rcs_dhndl)
				rcs_ndxno = 0;
			else
			{
#if	MC68K
				read_68k( FALSE );
#else
				read_i8086( FALSE );
#endif
				fclose(rcs_dhndl);
			}
			/* convert stored values to addresses */
			for (ii = 0; ii < rcs_ndxno; ii++)
			{
				switch ( get_kind(ii) )
				{
					case UNKN:
					case PANL:
					case DIAL:
					case MENU:
						set_value(ii, (BYTE *) tree_addr(
							(WORD) get_value(ii)) );
						break;
					case ALRT:
					case FRSTR:
						set_value(ii, (BYTE *) str_addr(
							(WORD) get_value(ii)) );
						break;
					case FRIMG:
						set_value(ii, (BYTE *) img_addr(
							(WORD) get_value(ii)) );
						break;
					case OBJKIND:
						nobj = (WORD) LLOBT( (UWORD) get_value(ii) ) & 0xff;
						ntree = (WORD) LHIBT( (UWORD) get_value (ii) ) & 0xff;
						set_value(ii, (BYTE *) (tree_addr(ntree) + 
							(UWORD) (nobj * sizeof(OBJECT))));
						break;
					default:
						break;
				}
			}

			comp_alerts(head);	/* convert freestrs into alert trees */
			comp_str(head);	/* scavenge all other freestrs	*/
			comp_img(head);	/* and likewise for free images */
			/* make sure all trees are indexed */
			for (ii = 0; ii < LWGET(RSH_NTREE(head)); ii++)
				if (find_tree(ii) == NIL)
				{
					unique_name(name, "TREE%hd", ii + 1);
					new_index((BYTE *) tree_addr(ii), UNKN, name);
				}

			return LWGET(RSH_RSSIZE(head));
		}
	}
}

WORD merge_files(VOID)
{
	UWORD	foo, indoff;
	WORD	total, i, ii;
	WORD	nobj, ntree, old_ntree;
	LONG	merge, oldndx, newndx, old_ndxno, frstr, frimg, here;

	merge = get_mem((WORD)sizeof(RSHDR));
	if (!dmcopy(rcs_rhndl, 0x0L, merge, (WORD)sizeof(RSHDR) ))
	{ 
		fclose(rcs_rhndl);
		return(FALSE);
	}
	else
	{
		if (rcs_low || avail_mem() < (UWORD) LWGET(RSH_RSSIZE(merge)) - 
			(UWORD) sizeof(RSHDR) )
		{
			hndl_alert(1, string_addr(STNROOM));
			return(FALSE);
		}
		else
		{
			/* synchronize objects */
			foo = (UWORD) (( merge + LW( LWGET(RSH_OBJECT(merge)) ) ) -
				( head + LW( LWGET(RSH_OBJECT(head)) ) ));
			foo %= (WORD)sizeof(OBJECT);
			if (foo) 
			{
				get_mem(foo = (WORD)(sizeof(OBJECT) - foo));
				merge = merge + foo;
				dmcopy(rcs_rhndl, 0x0L, merge, (WORD)sizeof(RSHDR));
			}

			here = get_mem((UWORD) LWGET(RSH_RSSIZE(merge)) - 
				(UWORD) sizeof(RSHDR));
			if (!dmcopy (rcs_rhndl, (LONG) sizeof(RSHDR), 
				here, LWGET(RSH_RSSIZE(merge))))
			{
				fclose(rcs_rhndl);
				return(FALSE);
			}
			else
			{
				fclose(rcs_rhndl);
				rs_hdr = merge;
				fix_all();

				old_ntree = LWGET(RSH_NTREE(head));
				if (LWGET(RSH_NTREE(merge)))
				{
					total = LWGET(RSH_NTREE(head)) + LWGET(RSH_NTREE(merge));
					newndx = get_mem((WORD)(sizeof(LONG) * total));
					indoff = (UWORD) (newndx - head);		
					for (i = 0; i < LWGET(RSH_NTREE(head)); i++)
					{
						LLSET(newndx, tree_addr(i));
						newndx += sizeof(LONG);
					}
					oldndx = merge + LW( LWGET(RSH_TRINDEX(merge)) );
					for (i = 0; i < LWGET(RSH_NTREE(merge)); i++)
					{
						LLSET(newndx, LLGET(oldndx));
						newndx += sizeof(LONG);
						oldndx += sizeof(LONG);
					}
					LWSET(RSH_NTREE(head), total);
					LWSET(RSH_TRINDEX(head), indoff);
				}

				if (rcs_dhndl)
				{  
#if	MC68K				      
					{	
						old_ndxno = rcs_ndxno;
						read_68k( TRUE );
						total = rcs_ndxno;
						rcs_ndxno = (WORD)old_ndxno;
					}
#else
					{
						old_ndxno = rcs_ndxno;		
						if (!dmcopy(rcs_dhndl, 0x0L, ADDR(&total), sizeof(WORD) ))
							total = 0;
						else
						{
							if (!dmcopy(rcs_dhndl, 0x02L, ADDR(&rcs_index[old_ndxno]),
								sizeof(INDEX) * total))
								total = 0;
							else
								total = total + old_ndxno;
						}
					}
#endif
					for ( ii = (WORD)old_ndxno; ii < total; ii++ )				
					{	
						if (find_name(&rcs_index[ii].name[0]) != NIL)
							if (tree_kind(rcs_index[ii].kind))
								unique_name(&rcs_index[ii].name[0], "TREE%hd", old_ntree);
							else
								unique_name(&rcs_index[ii].name[0], "OBJ%hd", 0);
						switch (rcs_index[ii].kind)
						{
							case UNKN:
							case PANL:
							case DIAL:
							case MENU:
								rcs_index[ii].val = (BYTE *) tree_addr(
									(WORD) rcs_index[ii].val + old_ntree);
								break;
							case ALRT:
							case FRSTR:
								frstr = merge +	LW( LWGET(RSH_FRSTR(merge)) );
								rcs_index[ii].val = (BYTE *) LLGET(frstr + 
								(UWORD) (sizeof(LONG) * (WORD) rcs_index[ii].val));
								break;
							case FRIMG:
								frimg = merge + LW( LWGET(RSH_FRIMG(merge)) );
								rcs_index[ii].val = (BYTE *) LLGET(frimg +
									(UWORD) (sizeof(LONG) * (WORD)rcs_index[ii].val));
								break;
							case OBJKIND:
								nobj = (WORD) LLOBT( (UWORD) rcs_index[ii].val) & 0xff;
								ntree = (WORD) LHIBT( (UWORD) rcs_index[ii].val) & 0xff;
								rcs_index[ii].val = (BYTE *) (tree_addr(ntree + old_ntree) 
									+ (UWORD) (nobj * sizeof(OBJECT))); 
								break;
							default:
								break;
						}
						if (new_index(rcs_index[ii].val, rcs_index[ii].kind, &rcs_index[ii].name[0]) == NIL)
							break;
					}
					fclose(rcs_dhndl);
				}

				for (i = old_ntree; i < LWGET(RSH_NTREE(head)); i++)
				{
					map_tree(tree_addr(i), ROOT, NIL, (fkt_parm)trans_obj); 
					if (find_tree(i) == NIL)
					{
						unique_name(&rcs_index[i].name[0], "TREE%hd", i + 1);
						if (new_index((BYTE *) tree_addr(i), UNKN, &rcs_index[i].name[0]) == NIL)
							break;
					}
				}

				comp_alerts(merge);
				comp_str(merge);
				comp_img(merge);
				return (TRUE);
			}
		}
	}
}
