/* GEŽNDERTE FASSUNG!!! BRAUCHT MALLOC.H und MALLOC.O!
 *
 * drawcicn.c dated 10/14/98
 *
 * (c) 1995-97 by Thomas Binder (binder@rbg.informatik.th-darmstadt.de),
 * Johann-Valentin-May-Straže 7, 64665 Alsbach-H„hnlein, Germany
 *
 * Contains routines to draw color-icons under all versions of TOS.
 *
 * Permission is granted to spread this routine, but only the .c-, the
 * .s- and the .h-file together, *unchanged*. Permission is also granted
 * to use this routine in own productions, as long as it's mentioned
 * that the routine was used and that it was written by me.
 *
 * I can't be held responsible for the correct function of this routine,
 * nor for any damage that occurs after the correct or incorrect use of
 * this routine. USE IT AT YOUR OWN RISK!
 *
 * If you find any bugs or have suggestions, please contact me!
 *
 * History:
 * 02/05-
 * 04/01/95: Creation (not complete)
 * 08/13/95: Added use of single-plane-icons when available (instead
 *           of the mono-icons)
 * 08/14/95: Finished routines, 4-plane-icons are now re-used in
 *           resolutions with more than 4 planes
 * 08/15/95: Added use of a new member of the DRAW_CICON-structure to
 *           determine whether a CICONBLK has already been converted
 * 08/16/95: Removed bug that caused wrong display of icons when the
 *           icon-text was empty
 * 08/17/95: Improved performance of reuse_bitmap
 * 08/19/95: Changed handling of linked list, added free(copy) at
 *           the end of reuse_bitmap (no memory leak any more...)
 * 08/20/95: Removed unnecessary vs_clip-call (a remainder of the
 *           debugging-stage), changed accesses to the ICONBLK of
 *           a coverted icon because it's no longer member of the
 *           DRAW_CICON-structure, it can now be found in the
 *           CICONBLK original points to. Used temporary memory for
 *           vr_trnfm-calls wherever possible (means speedup).
 * 08/26/95: All changes of ob_type now preserve the upper byte,
 *           draw_coloricon now also clears the text effects before
 *           it prints the icon's text and char.
 * 09/16/96: Little optimisations in draw_coloricon
 * 02/02/97: Fixed memory leak in change_cicons when reusing the
 *           selected icon data failed.
 *           Better check for "true color" displays
 *           Noticable speedup of reuse_bitmap.
 * 02/09/97: Even faster reuse_bitmap with Pure C due to use of an
 *           external assembler routine (see convert.s)
 * 06/04/97: Fixed stupid bug and changed return code of
 *           draw_colorcion() to handle disabled color icons
 *           correctly.
 * 10/11/98: Imported improved truecolor-test from Thing's version of
 *           this file.
 *           Added NVDI5-support (if available, let NVDI5 do the
 *           conversion of the icon data)
 * 10/14/98: Added 256-color-palette support (in connection with
 *           NVDI5)
 */

#include "drawcicn.h"
#include <string.h>
#include <stddef.h>
#include <stdio.h>
#ifdef MEMDEBUG
#include <memdebug.h>
#endif
#ifdef WITH_NVDI5
#include "..\nvdi5\include\vdicol.h"
#endif
#include <dudolib.h>
#ifdef USE_PMALLOC
#include <malloc.h>

#define malloc(x) pmalloc(x)
#define free(x) pfree(x)
#endif

static	WORD tree_walk(OBJECT *tree, WORD start,
			WORD (*action)(OBJECT *tree, WORD obj, DCINFO *dinfo), DCINFO *dinfo);
static	WORD change_cicons(OBJECT *tree, WORD obj, DCINFO *dinfo);
static	WORD insert_data(DRAW_CICON *p, WORD *idata, WORD *mdata,
			WORD *sidata, WORD *smdata, WORD np);
static	WORD reuse_bitmap(WORD *source, WORD *dest, WORD w, WORD h,
			WORD snp, WORD dnp, void *ctab);
#ifdef WITH_NVDI5
static 	WORD reuse_bitmap_nvdi5(WORD *source, WORD *dest,
			WORD w, WORD h, WORD snp, WORD dnp, void *ctab);
#endif
static	WORD cdecl draw_coloricon(PARMBLK *parms);

/* static DRAW_CICON	*first; */
static WORD			handle;
static WORD			nplanes;
static WORD			truecolor;
static WORD			fonts_loaded;
static WORD			font_id;
static WORD			font_size;
#ifdef WITH_NVDI5
static WORD			has_vr_transfer_bits;
#endif
static void			*ctab;

/*
 * init_cicon, exit_cicon
 *
 * Globale Initialisierung/Exit
 */
int init_cicon(void)
{
 int	work_in[11] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2},
		work_out[57],
		d,
		xy[12],
		buf[32],
		black[32];
 MFDB	src,
		dst;

	ctab = 0L;
 handle = graf_handle(&d, &d, &d, &d);
 _v_opnvwk(work_in, &handle, work_out);
 if(!handle) return 0;
 else
 {
  xy[0] = xy[8] = work_out[0] - 15;
  xy[1] = xy[3] = xy[9] = xy[11] = work_out[1];
  xy[2] = xy[10] = work_out[0];
  vq_extnd(handle, 1, work_out);
  nplanes = work_out[4];
#ifdef WITH_NVDI5
	has_vr_transfer_bits = !!(work_out[30] & 2);
#endif
/*
 * Check for a true-color-display. To be precise, check whether black
 * bitmaps have all bits set or all bits cleared.
 */
  src.fd_addr = 0L;
  src.fd_w = 16;
  src.fd_h = 1;
  src.fd_wdwidth = 1;
  dst = src;
  dst.fd_addr = buf;
  dst.fd_nplanes = nplanes;
  dst.fd_stand = 0;
  xy[4] = xy[5] = xy[7] = 0;
  xy[6] = 15;
  vro_cpyfm(handle, S_ONLY, xy, &src, &dst);
  v_pline(handle, 2, xy);
  src.fd_addr = 0L;
  dst.fd_addr = black;
  vro_cpyfm(handle, S_ONLY, xy, &src, &dst);
  src.fd_addr = 0L;
  dst.fd_addr = buf;
  vro_cpyfm(handle, S_ONLY, &xy[4], &dst, &src);
  dst.fd_addr = black;
  src = dst;
  src.fd_stand = 0;
  vr_trnfm(handle, &src, &dst);
  truecolor = black[0] == 0;
/* Get ID and size of the small system font */
  if (appl_xgetinfo(1, &font_size, &font_id, &d, &d) != 0)
  {
   if (vst_font(handle, font_id) != font_id)
   {
    vst_load_fonts(handle, 0);
    fonts_loaded = 1;
    if (vst_font(handle, font_id) != font_id)
    {
     font_id = 1;
     font_size = 6;
    }
   }
  }
  else
  {
   font_id = 1;
   font_size = 6;
  }
  return 1;
 }
}

/*
 * init_with_palette
 *
 * This is an alternate form of init_routines() which also gets a
 * pointer to a color palette with 256 rgb-entries in VDI order (i.e.
 * the same format NVDI's *.pal-files use). This palette is of course
 * only used for icons with 256 colors in modes with 256 or more
 * colors and if WITH_NVDI5 has been defined at compile time.
 *
 * Input:
 * vdi_handle: Handle to use, see init_routines() (Not for Thing)
 * pal: Pointer to palette, may be 0L
 */
#ifdef __PUREC__
#pragma warn -par
#endif
int init_cicon_with_palette(WORD *pal)
{
#ifdef WITH_NVDI5
	static COLOR_TAB256	table;
	WORD				i;
	int16				idx;

	if (!init_cicon())
		return(0);
	if ((pal != 0L) && (nplanes >= 8))
	{
/* Transfer the palette into NVDI5's COLOR_TAB format */
		table.magic = COLOR_TAB_MAGIC;
		table.length = sizeof(table);
		table.format = 0;
		table.reserved = 0;
		table.map_id = v_get_ctab_id(handle);
		table.color_space = CSPACE_RGB;
		table.flags = 0;
		table.no_colors = 256; /* Wird sp„ter angepažt */
		table.reserved1 = table.reserved2 = table.reserved3 =
			table.reserved4 = 0;
		for (i = 0; i < 256; i++)
		{
			idx = v_ctab_vdi2idx(handle, i);
			table.colors[idx].rgb.reserved = i;
			table.colors[idx].rgb.red =
				(unsigned int)(+((LONG)*pal++ * 65535L) / 1000L);
			table.colors[idx].rgb.green =
				(unsigned int)(+((LONG)*pal++ * 65535L) / 1000L);
			table.colors[idx].rgb.blue =
				(unsigned int)(+((LONG)*pal++ * 65535L) / 1000L);
		}
		ctab = &table;
	}
	return(1);
#else /* !WITH_NVDI5 */
	return init_cicon();
#endif
}
#ifdef __PUREC__
#pragma warn .par
#endif

void exit_cicon(void)
{
 if (handle)
 {
  if (fonts_loaded)
   vst_unload_fonts(handle, 0);
  v_clsvwk(handle);
 }
}

void init_routines(DCINFO *dinfo)
{
 dinfo->first=0L;
}

void deinit_routines(DCINFO *dinfo)
{
 DRAW_CICON	*i,*j;
 
 for (i = dinfo->first; i != NULL;) /* Not a smiley... */
 {
  j = i->next;
  if (i->free_icon)
  free(i->icon_data);
  if (i->free_sel)
  free(i->sel_idata);
  free(i);
  i = j;
 }
}

/*
 * init_tree
 *
 * This routine initialises an AES-object-tree that may contain
 * color-icons so that it can simply be drawn with objc_draw. To
 * achieve that, all color-icons are converted into G_USERDEF-objects,
 * where ub_parm points to the following structure:
 *
 * typedef struct draw_cicon
 * {
 *     struct draw_cicon *next;      pointer to next structure
 *     WORD              *icon_data; pointer to icon-data, this
 *                                    data is in the device-
 *                                    dependent format of the
 *                                    current resolution
 *     WORD              *sel_idata; pointer to data of the
 *                                    selected icon, same format as
 *                                    icon_data. Note that this
 *                                    data is always present, even
 *                                    if the corresponding icon
 *                                    didn't have explicit data for
 *                                    the state 'selected'
 *     WORD              *mask_data; pointer to mask, 1 plane in
 *                                    device-dependent-format
 *     WORD              *sel_mdata; pointer to mask of selected
 *                                    icon, format as mask_data
 *     WORD              planes;     number of planes used in icon-
 *                                    data (this is either 1 or the
 *                                    value of the active resolution)
 *     _CICONBLK         *original;  original CICONBLK, use this to
 *                                    get the ICONBLK of the icon,
 *                                    e.g. to change the text
 *     WORD              free_icon;  for internal use only
 *     WORD              free_sel;   dito
 *     USERBLK           attached;   dito
 * } DRAW_CICON;
 *
 * init_tree looks if the color-icon contains data that fits the
 * current resolution. If so, it is converted into device-dependent
 * format. If not, and the color-icon contains 4-plane-data, and the
 * current resolution has more than 4 planes, or 1-plane-data is
 * available, that data is converted and used. In all other cases, or
 * due to lack of memory, the icon will be converted into a simple
 * mono-icon (i.e., ob_type will be set to G_ICON and ob_spec will
 * point to the ICONBLK supplied with the color-icon).
 *
 * BUGS: Up to now, init_tree only re-uses color-icons with 1 or 4
 * planes in resolutions with more planes. Maybe that will change in
 * future, but I can't promise.
 *
 * Input:
 * tree: Pointer to the tree that should be initialised
 *
 * Output:
 * 0: One or more color-icons were only converted into mono-icons.
 * otherwise: All color-icons in tree have been converted into
 *            user-defined objects, or tree doesn't contain any
 *            color-icons at all.
 */
WORD init_tree(OBJECT *tree,DCINFO *dinfo)
{
	return(!tree_walk(tree, 0, change_cicons, dinfo));
}

/*
 * tree_walk
 *
 * Static function used by init_tree. Walks an AES-object-tree and
 * calls the function action for each object encountered.
 *
 * Input:
 * tree: Pointer to AES-object-tree that should be 'walked'
 * start: Startobject
 * action: Pointer to function that should be called for each object.
 *
 * Output:
 * 0: All calls to action returned 0
 * otherwise: One or more calls to action returned a value != 0
 */
static WORD tree_walk(OBJECT *tree, WORD start,
    WORD (*action)(OBJECT *tree, WORD obj, DCINFO *dinfo), DCINFO *dinfo)
{
    WORD    i,
            ret_code = 0;
    
    for (i = tree[start].ob_head; (i != start) && (i != -1);
		i = tree[i].ob_next)
    {
        ret_code = (*action)(tree, i, dinfo);
        ret_code |= tree_walk(tree, i, action, dinfo);
    }
    return(ret_code);
}

/*
 * change_cicons
 *
 * Static function used by init_tree as the 'action'-parameter for
 * a tree_walk-call. In this function, all work needed to achieve
 * what's described in the comments on init_tree is done.
 *
 * Input:
 * tree: Pointer to tree
 * obj: Current object in tree which should be converted into a
 *      user-defined object (if necessary and possible)
 *
 * Output:
 * 0: Object could successfully be converted or didn't need any
 *    conversion at all
 * 1: The color-icon was just transformed into a mono-icon
 */
static WORD change_cicons(OBJECT *tree, WORD obj, DCINFO *dinfo)
{
	_CICONBLK	*block;
	_CICON		*i;
	DRAW_CICON	*act,
				*last;
	MFDB		source,
				dest;
	WORD		*new_icon,
				*new_sel,
				*temp,
				col[2],
				xy[8],
				ptu,
				wdw,
				w,
				h;
	LONG		psize;
	WORD		(*reuse)(WORD *, WORD *, WORD, WORD, WORD, WORD,
					void *);

	if ((tree[obj].ob_type & 0x00ff) != _G_CICON)
		return(0);
	block = (_CICONBLK *)tree[obj].ob_spec.free_string;
/*
 * Check if the current CICONBLK has already been converted; if so,
 * we just have to create a USERDEF that points to the existing
 * USERBLK
 */
	for (act = dinfo->first; act != NULL; act = act->next)
	{
		if (act->original == block)
		{
			tree[obj].ob_type &= 0xff00U;
			tree[obj].ob_type |= G_USERDEF;
			tree[obj].ob_spec.userblk = &act->attached;
			return(0);
		}
	}
/* If not, try to convert the icon */
	w = block->monoblk.ib_wicon;
	wdw = (w + 15) / 16;
	h = block->monoblk.ib_hicon;
	psize = (LONG)wdw * (LONG)h * 2L;
	last = dinfo->first;
/* First try to allocate memory for a new DRAW_CICON-structure */
	if ((act = malloc(sizeof(DRAW_CICON))) == NULL)
		goto make_monoicon;
	dinfo->first = act;
	act->next = last;
	act->original = block;
	ptu = nplanes;
/* Check if we can find icon-data that fits the current resolution */
	for (i = block->mainlist; (i != NULL) && (i->num_planes !=
		nplanes); i = i->next_res);
#ifdef WITH_NVDI5
	if ((i == NULL) || (has_vr_transfer_bits  && (nplanes == 8)))
#else
	if (i == NULL)
#endif
	{
#ifdef WITH_NVDI5
		int		min_planes,
				max_planes;
		_CICON	*j;

/*
 * If NVDI5 (or better: vr_transfer_bits()) is available, search icon
 * data with 2, 4 or 8 planes (and less than the current resolution)
 */
		if (has_vr_transfer_bits)
		{
			min_planes = 1;
			if (nplanes > 8)
				max_planes = 8;
			else
				max_planes = nplanes;
			j = NULL;
			for (i = block->mainlist; i != NULL; i = i->next_res)
			{
				switch (i->num_planes)
				{
					case 2:
					case 4:
					case 8:
						if ((i->num_planes > min_planes) &&
							(i->num_planes <= max_planes))
						{
							min_planes = i->num_planes;
							j = i;
						}
						break;
				}
			}
			i = j;
			reuse = reuse_bitmap_nvdi5;
		}
		else
		{
#endif /* WITH_NVDI5 */
/*
 * If not, check if the current resolution has more than four planes,
 * and, if so, there's icon-data for four planes that could be
 * converted
 */
		if (nplanes <= 4)
			goto check_oneplane;
		for (i = block->mainlist; (i != NULL) && (i->num_planes != 4);
			i = i->next_res);
		reuse = reuse_bitmap;
#ifdef WITH_NVDI5
		}
#endif
		if (i == NULL)
			goto check_oneplane;
/*
 * We've found 4-plane-data, now extract the sixteen colors and create
 * an icon for the current resolution via vrt_cpyfm
 */
#ifdef WITH_NVDI5
		if (reuse == reuse_bitmap_nvdi5)
			new_icon = malloc(psize * (LONG)nplanes);
		else
#endif
		new_icon = malloc(psize * (LONG)nplanes);
		if (new_icon == NULL)
		{
			goto make_monoicon;
		}
		act->free_icon = 1;
		if (!(reuse)(i->col_data, new_icon, w, h, i->num_planes,
			nplanes, ctab))
		{
			free(new_icon);
			goto make_monoicon;
		}
		if (i->sel_data)
		{
#ifdef WITH_NVDI5
			if (reuse == reuse_bitmap_nvdi5)
				new_sel = malloc(psize * (LONG)nplanes);
			else
#endif
			new_sel = malloc(psize * (LONG)nplanes);
			if (new_sel == NULL)
			{
				free(new_icon);
				goto make_monoicon;
			}
			act->free_sel = 1;
			if (!(reuse)(i->sel_data, new_sel, w, h, i->num_planes,
				nplanes, ctab))
			{
				free(new_icon);
				free(new_sel);
				goto make_monoicon;
			}
			i->sel_data = new_sel;
		}
		temp = malloc(psize);
		source.fd_addr = i->col_mask;
		source.fd_w = w;
		source.fd_h = h;
		source.fd_wdwidth = wdw;
		source.fd_stand = 1;
		source.fd_nplanes = 1;
		dest = source;
		if (temp != NULL)
			dest.fd_addr = temp;
		vr_trnfm(handle, &source, &dest);
		if (temp != NULL)
			memcpy(i->col_mask, temp, psize);
		if (i->sel_mask)
		{
			source.fd_addr = i->sel_mask;
			source.fd_stand = 1;
			dest = source;
			if (temp != NULL)
				dest.fd_addr = temp;
			vr_trnfm(handle, &source, &dest);
			if (temp != NULL)
				memcpy(i->sel_mask, temp, psize);
		}
		if (temp != NULL)
			free(temp);
		if (truecolor)
		{
			xy[0] = xy[1] = xy[4] = xy[5] = 0;
			xy[2] = xy[6] = w - 1;
			xy[3] = xy[7] = h - 1;
			source.fd_addr = i->col_mask;
			source.fd_stand = 0;
			dest.fd_addr = new_icon;
			dest.fd_stand = 0;
			dest.fd_nplanes = nplanes;
			col[0] = col[1] = BLACK;
			vrt_cpyfm(handle, MD_ERASE, xy, &source, &dest, col);
			if (i->sel_data)
			{
				source.fd_addr = i->sel_mask;
				dest.fd_addr = i->sel_data;
				vrt_cpyfm(handle, MD_ERASE, xy, &source, &dest, col);
			}
		}
		if (!insert_data(act, new_icon, i->col_mask,
			i->sel_data, i->sel_mask, nplanes))
		{
			free(new_icon);
			if (act->free_sel)
				free(new_sel);
			goto make_monoicon;
		}
		tree[obj].ob_type &= 0xff00U;
		tree[obj].ob_type |= G_USERDEF;
		tree[obj].ob_spec.userblk = &act->attached;
		return(0);
/*
 * If there's no data matching the current plane-depth and no 4-
 * plane-data usable, check if there's one-plane-data (which can
 * be used in any color-depth).
 */
check_oneplane:
		for (i = block->mainlist; (i != NULL) && (i->num_planes != 1);
			i = i->next_res);
		if (i == NULL)
			goto make_monoicon;
		ptu = 1;
		goto fill_struct;
	}
	else
	{
fill_struct:
		temp = malloc(psize * ptu);
		source.fd_addr = i->col_data;
		source.fd_w = w;
		source.fd_wdwidth = wdw;
		source.fd_h = h;
		source.fd_nplanes = ptu;
		source.fd_stand = 1;
		dest = source;
		if (temp != NULL)
			dest.fd_addr = temp;
		dest.fd_stand = 0;
		vr_trnfm(handle, &source, &dest);
		if (temp != NULL)
			memcpy(i->col_data, temp, psize * ptu);
		if (i->sel_data)
		{
			source.fd_addr = i->sel_data;
			if (temp == NULL)
				dest.fd_addr = i->sel_data;
			vr_trnfm(handle, &source, &dest);
			if (temp != NULL)
				memcpy(i->sel_data, temp, psize * ptu);
		}
		source.fd_addr = i->col_mask;
		if (temp == NULL)
			dest.fd_addr = i->col_mask;
		source.fd_nplanes = dest.fd_nplanes = 1;
		vr_trnfm(handle, &source, &dest);
		if (temp != NULL)
			memcpy(i->col_mask, temp, psize);
		if (i->sel_mask)
		{
			source.fd_addr = i->sel_mask;
			if (temp == NULL)
				dest.fd_addr = i->sel_mask;
			vr_trnfm(handle, &source, &dest);
			if (temp != NULL)
				memcpy(i->sel_mask, temp, psize);
		}
		if (temp != NULL)
			free(temp);
		act->free_icon = act->free_sel = 0;
		if (!insert_data(act, i->col_data, i->col_mask,
			i->sel_data, i->sel_mask, ptu))
		{
			goto make_monoicon;
		}
		tree[obj].ob_type &= 0xff00U;
		tree[obj].ob_type |= G_USERDEF;
		tree[obj].ob_spec.userblk = &act->attached;
		return(0);
	}
make_monoicon:
	if (act)
	{
		dinfo->first = last;
		free(act);
	}
/*
 * To convert into a mono-icon, change object-type into G_ICON and
 * let ob_spec point to the mono-iconblock of the color-icon.
 * Additionally, the data for icon and mask must be transformed into
 * device-dependent format.
 */
	tree[obj].ob_type &= 0xff00U;
	tree[obj].ob_type |= G_ICON;
	tree[obj].ob_spec.iconblk = &(block->monoblk);
	temp = malloc(psize);
	source.fd_addr = block->monoblk.ib_pdata;
	source.fd_w = w;
	source.fd_h = h;
	source.fd_wdwidth = wdw;
	source.fd_nplanes = 1;
	source.fd_stand = 1;
	dest = source;
	if (temp != NULL)
		dest.fd_addr = temp;
	dest.fd_stand = 0;
	vr_trnfm(handle, &source, &dest);
	if (temp != NULL)
		memcpy(source.fd_addr, temp, psize);
	source.fd_addr = block->monoblk.ib_pmask;
	if (temp == NULL)
		dest.fd_addr = source.fd_addr;
	vr_trnfm(handle, &source, &dest);
	if (temp != NULL)
	{
		memcpy(source.fd_addr, temp, psize);
		free(temp);
	}
	return(1);
}

/*
 * insert_data
 *
 * With this routine, all necessary parts of the DRAW_CICON-structure
 * are filled with data. If no data for the selected icon is given,
 * a 'darkened' version of the original icon is created, with the
 * same mask. If no mask for the selected icon is given, the selected
 * icon will have the same mask as the non-selected one.
 *
 * Input:
 * p: Pointer to DRAW_CICON-structure that should be filled (original
 *    and next have to be initialised!)
 * idata: Pointer to icon-data in device-dependent format
 * mdata: Pointer to icon-mask in device-dependent format
 * sidata: Pointer to data for the selected icon, or NULL
 * smdata: Pointer to data for the mask of the selected icon, or NULL
 * np: Number of planes used by the icon (1 or current value)
 *
 * Output:
 * 0: Memory allocation for the selected icon failed
 * 1: Everything OK
 */
static WORD insert_data(DRAW_CICON *p, WORD *idata, WORD *mdata,
	WORD *sidata, WORD *smdata, WORD np)
{
	WORD	w,
			wdw,
			h,
			i,
			j,
			d,
			xy[8],
			col[2],
			*darken,
			*temp;
	LONG	psize;
	MFDB	source,
			dest;

/*
 * First get the attributes of the icon and calculate the size in
 * bytes for one plane of it
 */
	w = p->original->monoblk.ib_wicon;
	wdw = (w + 15) / 16;
	h = p->original->monoblk.ib_hicon;
	psize = (LONG)wdw * (LONG)h * 2L;
/*
 * If there's no mask for the selected icon, use the mask for the
 * unselected one
 */
	if (smdata == NULL)
		smdata = mdata;
/*
 * If there's no data for the selected icon, we must now create a
 * "darkened" version of the unselected icon (with 1-plane-icons,
 * it's actually only an inverted version)
 */
	if (sidata == NULL)
	{
		smdata = mdata;
/* Allocate memory for the selected bitmap + 2 temporary planes */
		if ((sidata = malloc(psize * (np + 2))) == NULL)
			return(0);
		p->free_sel = 1;
/* Copy the unselected icon into the new area */
		memcpy(sidata, idata, psize * np);
/*
 * If the icon has only one plane, it has to be inverted. This is
 * done in the draw-routine.
 */
		if (np != 1)
		{
/*
 * For multi-plane-icons, fill the temporary plane with a dot pattern
 */
			darken = (WORD *)((LONG)sidata + psize * np);
			temp = (WORD *)((LONG)darken + psize);
			for (i = 0; i < h; i++)
			{
				d = (i & 1) ? 0x5555 : 0xaaaa;
				for (j = 0; j < wdw; j++)
					darken[(LONG)i * wdw + (LONG)j] = d;
			}
/* Transform it into device-dependent format */
			source.fd_addr = darken;
			source.fd_w = w;
			source.fd_h = h;
			source.fd_wdwidth = wdw;
			source.fd_stand = 1;
			source.fd_nplanes = 1;
			dest = source;
			dest.fd_addr = temp;
			vr_trnfm(handle, &source, &dest);
			memcpy(darken, temp, psize);
/*
 * Now copy this dot-pattern over the unselected icon, creating the
 * "darkened" version
 */
			source.fd_addr = darken;
			source.fd_stand = 0;
			source.fd_nplanes = 1;
			dest = source;
			dest.fd_addr = sidata;
			dest.fd_nplanes = np;
			xy[0] = xy[1] = xy[4] = xy[5] = 0;
			xy[2] = xy[6] = w - 1;
			xy[3] = xy[7] = h - 1;
			col[0] = col[1] = BLACK;
			vrt_cpyfm(handle, MD_TRANS, xy, &source, &dest, col);
/*
 * Remove all pixels from the new icon that do not belong to the
 * selected mask
 */
			source.fd_addr = smdata;
			dest = source;
			dest.fd_addr = sidata;
			dest.fd_nplanes = np;
			if (truecolor)
				col[0] = col[1] = BLACK;
			else
				col[0] = col[1] = WHITE;
			vrt_cpyfm(handle, MD_ERASE, xy, &source, &dest, col);
		}
	}
	p->icon_data = idata;
	p->mask_data = mdata;
	p->sel_idata = sidata;
	p->sel_mdata = smdata;
	p->planes = np;
	p->attached.ub_parm = (LONG)p;
	p->attached.ub_code = draw_coloricon;
	return(1);
}

#ifdef __PUREC__
#pragma warn -use
#pragma warn -par
extern void convert_data(WORD *dest, WORD *plane_use, WORD *source,
	LONG *pixel_mult, LONG wdwxh);
#endif

/*
 * reuse_bitmap
 *
 * This function splits a 4-plane-bitmap into its 16 colors and
 * builds a new bitmap with the current number of planes. This method
 * allows us to use 4-plane-coloricons in any greater color-depth,
 * even with true-color displays (when the VDI has a correct
 * implementation of vrt_cpyfm).
 *
 * Input:
 * source: Pointer to source-bitmap (in device-independent format!)
 * dest: Pointer to destination area, which must have space for
 *       the bitmap with the current number of planes. The
 *       destination bitmap will be in device-dependent format!
 * w, h: Dimensions of the bitmap
 * snp: Number of planes for the destination bitmap (always 4 here)
 * dnp: Number of planes for the destination bitmap
 * ctab: Pointer to NVDI5 COLOR_TAB with 256 entries, may be 0L
 *       (unused here)
 *
 * Output:
 * 0: Memory allocation for temporary buffer failed, bitmap not
 *    converted
 * 1: Everything OK
 */
static WORD reuse_bitmap(WORD *source, WORD *dest, WORD w, WORD h,
	WORD snp, WORD dnp, void *ctab)
{
	WORD	s1,	s2, s3, s4,
			pixel;
	UWORD	k;
	WORD	i,
			wdw,
			*temp,
			*spos1, *spos2, *spos3, *spos4,
			*dpos,
			*copy,
			xy[8],
			col[2],
			pixel_to_index[16] = {WHITE, RED, GREEN, YELLOW,
				BLUE, MAGENTA, CYAN, LWHITE, LBLACK, LRED,
				LGREEN, LYELLOW, LBLUE, LMAGENTA, LCYAN,
				BLACK},
			plane_used[16];
	LONG	psize,
			j,
			wdwxh;
	LONG	pixel_mult[16];
	MFDB	src, dst;

/*
 * Calculate the size of one plane, allocate temporary buffer and
 * initialise the destination area
 */
	wdw = (w + 15) / 16;
	psize = (LONG)wdw * (LONG)h * 2L;
	if ((copy = malloc(psize * 17)) == NULL)
		return(0);
	temp = (WORD *)((LONG)copy + psize * 16);
	if (truecolor)
		memset(dest, 255, psize * dnp);
	else
		memset(dest, 0, psize * dnp);
/*
 * Extract the pixel-values of the source bitmap and create 16
 * single-plane-bitmaps where each represents one specific pixel-
 * value (i.e. one color)
 */
	src.fd_w = w;
	src.fd_h = h;
	src.fd_wdwidth = wdw;
	dst = src;
	xy[0] = xy[1] = xy[4] = xy[5] = 0;
	xy[2] = xy[6] = w - 1;
	xy[3] = xy[7] = h - 1;
	memset(copy, 0, psize * 16);
	wdwxh = (LONG)wdw * h;
#ifdef __PUREC__
	convert_data(copy, plane_used, source, pixel_mult, wdwxh);
#else
	dpos = copy;
	for (i = 0; i < 16; i++)
	{
		plane_used[i] = 0;
		pixel_mult[i] = (LONG)i * wdwxh;
	}
	spos1 = source;
	spos2 = &spos1[wdwxh];
	spos3 = &spos2[wdwxh];
	spos4 = &spos3[wdwxh];
	for (j = 0; j < wdwxh; j++)
	{
		s1 = *spos1++;
		s2 = *spos2++;
		s3 = *spos3++;
		s4 = *spos4++;
		for (k = 32768U; k > 0; k >>= 1)
		{
			pixel = 0;
			if (s1 & k)
				pixel += 1;
			if (s2 & k)
				pixel += 2;
			if (s3 & k)
				pixel += 4;
			if (s4 & k)
				pixel += 8;
			dpos[pixel_mult[pixel]] |= k;
			plane_used[pixel] = 1;
		}
		dpos++;
	}
#endif
/*
 * After that conversion, the single-plane-bitmaps are transformed
 * into device-dependent format and copied into the destination-area
 * via vrt_cpyfm, resulting in the color-icon in the current color-
 * depth
 */
	for (i = 0; i < 16; i++)
	{
		if (plane_used[i])
		{
			src.fd_addr = &copy[pixel_mult[i]];
			src.fd_nplanes = src.fd_stand = 1;
			dst.fd_addr = temp;
			dst.fd_nplanes = 1;
			dst.fd_stand = 0;
			vr_trnfm(handle, &src, &dst);
			src.fd_addr = temp;
			src.fd_stand = 1;
			dst.fd_addr = dest;
			dst.fd_nplanes = dnp;
			dst.fd_stand = 0;
/*
 * Since pixel-values are not the same as VDI-indixes, we have to
 * use a little table that gives the VDI-index to a specific pixel-
 * value
 */
			col[0] = pixel_to_index[i];
			col[1] = 0;
			vrt_cpyfm(handle, MD_TRANS, xy, &src, &dst, col);
		}
	}
	free(copy);
	return(1);
}
#ifdef __PUREC__
#pragma warn .par
#pragma warn .use
#endif

#ifdef WITH_NVDI5
/*
 * reuse_bitmap_nvdi5
 *
 * Just like reuse_bitmap, but for one, two, four and eight planes in
 * the source bitmap. This function will only work if the current
 * VDI supports vr_transfer_bits(), which was introduced by NVDI5.
 * Also uses the color palette, if supplied.
 */
static WORD reuse_bitmap_nvdi5(WORD *source, WORD *dest,
	WORD w, WORD h, WORD snp, WORD dnp, void *ctab)
{
	GCBITMAP	src,
				dst;
	int16		xy[8];

/* Fill the source and destination bitmap structure */
	src.magic = CBITMAP_MAGIC;
	src.length = 64;
	src.format = 0;
	src.reserved = 0;
	src.addr = (uint8 *)source;
	src.width = ((int32)w * snp) >> 3;
	src.bits = snp;
	src.px_format = PX_PLANES + PX_1COMP;
	switch (snp)
	{
		case 2:
			src.px_format += PX_USES2 + PX_2BIT;
			break;
		case 4:
			src.px_format += PX_USES4 + PX_4BIT;
			break;
		case 8:
			src.px_format += PX_USES8 + PX_8BIT;
			break;
		default:
/* This is not a possible bit depth for an Atari coloricon */
			return(0);
	}
	src.xmin = src.ymin = 0;
	src.xmax = w;
	src.ymax = h;
	if (snp >= 8)
		src.ctab = ctab;
	else
		src.ctab = 0L;
	src.itab = 0L;
	src.reserved0 = src.reserved1 = 0;
	dst = src;
	dst.addr = (uint8 *)dest;
	dst.width = ((int32)w * dnp) >> 3;
	dst.bits = dnp;
	vq_px_format(handle, &dst.px_format);
	dst.ctab = 0L;
	dst.itab = 0L;
	xy[0] = xy[1] = xy[4] = xy[5] = 0;
	xy[2] = xy[6] = w - 1;
	xy[3] = xy[7] = h - 1;
/* Transform the source bitmap; with dithering, if necessary */
#if 1
	vr_transfer_bits(handle, &src, &dst, xy, xy + 4, T_DRAW_MODE);
#endif
	return(1);
}
#endif /* WITH_NVDI5 */

/*
 * draw_coloricon
 *
 * This is the routine that actually draws the color-icons. It is
 * called by the AES when it encounters one of the USERDEFs installed
 * by init_tree, therefore it has to have standard-C-parameters,
 * hence the CDECL (you may have to adapt it for your compiler).
 *
 * Input:
 * parms: Pointer to the PARMBLK-structure of the current USERDEF
 */
static WORD cdecl draw_coloricon(PARMBLK *parms)
{
	WORD		d,
				dim[8],
				x, y,
				*icon,
				*mask,
				selected,
				col[2],
				xy[8];
	DRAW_CICON	*block;
	MFDB		source,
				dest;
	char		out[2];

/* Get the pointer to the DRAW_CICON-structure */
	block = (DRAW_CICON *)parms->pb_parm;
/*
 * Determine if we need the bitmaps for the selected or the
 * unselected icon
 */
	if ((selected = !!(parms->pb_currstate & SELECTED)) != 0)
	{
		icon = block->sel_idata;
		mask = block->sel_mdata;
	}
	else
	{
		icon = block->icon_data;
		mask = block->mask_data;
	}
/* Set the correct clipping rectangle */
	xy[0] = parms->pb_xc;
	xy[1] = parms->pb_yc;
	xy[2] = xy[0] + parms->pb_wc - 1;
	xy[3] = xy[1] + parms->pb_hc - 1;
	vs_clip(handle, 1, xy);
/* Draw the icon mask */
	source.fd_addr = mask;
	source.fd_w = block->original->monoblk.ib_wicon;
	source.fd_wdwidth = (source.fd_w + 15) / 16;
	source.fd_h = block->original->monoblk.ib_hicon;
	source.fd_nplanes = 1;
	source.fd_stand = 0;
	dest.fd_addr = 0L;
	xy[0] = xy[1] = 0;
	xy[2] = source.fd_w - 1;
	xy[3] = source.fd_h - 1;
	xy[4] = parms->pb_x + block->original->monoblk.ib_xicon;
	xy[5] = parms->pb_y + block->original->monoblk.ib_yicon;
	xy[6] = xy[4] + source.fd_w - 1;
	xy[7] = xy[5] + source.fd_h - 1;
	col[0] = (block->original->monoblk.ib_char >> 8) & 15;
	col[1] = ((UWORD)block->original->monoblk.ib_char >> 12);
/*
 * The colors of the mask have to be inverted if we have to draw the
 * mask of a selected one-plane icon which didn't have its own
 * bitmap, or if we have to draw a multi-plane icon in true-color-
 * mode
 */
	if (((block->planes == 1) && selected && block->free_sel) ||
		((block->planes > 1) && truecolor))
	{
		col[0] ^= col[1];
		col[1] ^= col[0];
		col[0] ^= col[1];
	}
	vrt_cpyfm(handle, MD_TRANS, xy, &source, &dest, col);
	if (((block->planes == 1) && selected && block->free_sel) ||
		((block->planes > 1) && truecolor))
	{
		col[0] ^= col[1];
		col[1] ^= col[0];
		col[0] ^= col[1];
	}
/*
 * Now draw the icon itself, using vrt_cpyfm for one-plane-icons
 * (this allows us to use them in any color-depth) or vro_cpyfm for
 * all others (which then have to have the same number of planes as
 * the current resolution)
 */
	source.fd_addr = icon;
	dest.fd_addr = 0L;
	if (block->planes == 1)
	{
		if (!selected || !block->free_sel)
		{
			col[0] ^= col[1];
			col[1] ^= col[0];
			col[0] ^= col[1];
		}
		source.fd_nplanes = 1;
		vrt_cpyfm(handle, MD_TRANS, xy, &source, &dest, col);
		if (!selected || !block->free_sel)
		{
			col[0] ^= col[1];
			col[1] ^= col[0];
			col[0] ^= col[1];
		}
	}
	else
	{
		source.fd_nplanes = nplanes;
		vro_cpyfm(handle, S_OR_D, xy, &source, &dest);
	}
/* Finally, draw the icon text and char */
	xy[0] = parms->pb_x + block->original->monoblk.ib_xtext;
	xy[1] = parms->pb_y + block->original->monoblk.ib_ytext;
	xy[2] = xy[0] + block->original->monoblk.ib_wtext - 1;
	xy[3] = xy[1] + block->original->monoblk.ib_htext - 1;	
	vsf_color(handle, col[selected]);
	vsf_interior(handle, SOLID);
	vst_font(handle, font_id);
	vst_height(handle, font_size, &d, &d, &d, &d);
	vst_alignment(handle, 0, 5, &d, &d);
	vst_color(handle, col[!selected]);
	vst_effects(handle, 0);
	if (block->original->monoblk.ib_wtext)
	{
		vswr_mode(handle, MD_REPLACE);
		vr_recfl(handle, xy);
	}
	vswr_mode(handle, MD_TRANS);
	if (strlen(block->original->monoblk.ib_ptext))
	{
		vqt_extent(handle, block->original->monoblk.ib_ptext, dim);
		x = (block->original->monoblk.ib_wtext - (dim[2] - dim[0])) / 2;
		x += parms->pb_x + block->original->monoblk.ib_xtext;
		y = (block->original->monoblk.ib_htext - (dim[7] - dim[1])) / 2;
		y += parms->pb_y + block->original->monoblk.ib_ytext;
		v_gtext(handle, x, y, block->original->monoblk.ib_ptext);
	}
	out[0] = block->original->monoblk.ib_char & 0xff;
	out[1] = 0;
	v_gtext(handle, parms->pb_x + block->original->monoblk.ib_xicon +
		block->original->monoblk.ib_xchar,
		parms->pb_y + block->original->monoblk.ib_yicon +
		block->original->monoblk.ib_ychar, out);
	/* Let the AES handle all states but SELECTED */
	return(parms->pb_currstate & ~SELECTED);
}

/* EOF */
