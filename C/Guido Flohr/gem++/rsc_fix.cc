/*  rsc_fix.cc   Tue 23 Feb 1993 17:36:42	  Warwick Allison
 *      Converted to C++,
 *      Propagated 'header' and 'offset' parameters to all functions.
 *
 *  Based loosely on:
 *		RSCFIX.C		09/16/86				Ric Clayton
 */

#include <aesbind.h>
#include "rsc_gobj.h"

// Convert a RSC pseudopointer into a real pointer.  Assumes "offset".
#define NIL (-1)
#define RSH(x) (long(x) == NIL ? 0 : ((typeof(x))(long(x)+offset)))

// Two different types of position adjustment.
//
// Proportion for forms...
//
#define adj(xywh, siz, scale) \
	((siz)*((xywh) & 0x00FF) + (((unsigned short)(xywh)) >> 8)*(siz)/(scale))
//
// Standard for menus...
//
#define adj_menu(xywh, siz, scale) \
	((siz)*((xywh) & 0x00FF) + (((unsigned short)(xywh)) >> 8))


static void map_tree(OBJECT* tree, int from, int last, int routine(OBJECT&))
// From ProGEM...
{
    /* Initialize to impossible value: */
	/* TAIL won't point to self!       */
	/* Look until final node, or off   */
	/* the end of tree		 */ 
	int tmp1=from;
 
	while (from != last && from != NIL) {
		/* Did we 'pop' into this node     */
		/* for the second time?	    */
		if (tree[from].ob_tail != tmp1) {
			tmp1 = from;    /* This is a new node       */
			from = NIL;

			/* Apply operation, testing  */
			/* for rejection of sub-tree */
			if (routine(tree[tmp1])) from = tree[tmp1].ob_head;

			/* Subtree path not taken,   */
			/* so traverse right	 */ 
			if (from == NIL) from = tree[tmp1].ob_next;
		} else {
		    /* Revisiting parent:	*/
			/* No operation, move right  */
			tmp1 = from;
			from = tree[tmp1].ob_next;
		}
	}
}

void fix_string(char* text)
// Strip trailing '@' characters from text.
{
	int i=0;
	while (text[i]) i++;
	i--;
	while (i>=0 && text[i]=='@') text[i--]=0;
}

static void fix_trindex(RSHDR* header, long offset)
{
	OBJECT** rs_trindex=(OBJECT**)(header->rsh_trindex+offset);

	int		i;
	
	for (i = 0; i < header->rsh_ntree; i++) {
		rs_trindex[i] = RSH(rs_trindex[i]);
	}
}

static void fix_objects(RSHDR* header, long offset)
{
	OBJECT* rs_object=(OBJECT*)(header->rsh_object+offset);

	int		 i;
	
	for (i = 0; i < header->rsh_nobs; i++) {
		// Mask off extended type
		switch (rs_object[i].ob_type&0xff) {
		  case G_BOX:
		  case G_IBOX:
		  case G_BOXCHAR:
		  case G_USERDEF:
		break;
		  case G_STRING:
		  case G_TITLE:
		  case G_BUTTON:
			rs_object[i].ob_spec.index = RSH(rs_object[i].ob_spec.index);
			fix_string(rs_object[i].ob_spec.free_string);
		break;
		  default:
			// XXX Assume that ALL new object types have a pseudopointer
			// XXX to object-specific data.
			// XXX This is a weakspot in this rsrc_load() reimplementation.
			rs_object[i].ob_spec.index = RSH(rs_object[i].ob_spec.index);
		}
	}
}

// Global variables for the map_tree routines
static int wchar,hchar,rscw,rsch;
static int titlefound;

static int findtitle(OBJECT& o)
{
	if ((o.ob_type&0xff) == G_TITLE) {
		titlefound=1;
		return 0;
	} else
		return 1;
}

static int pos_menu(OBJECT& o)
{
	o.ob_x = adj_menu(o.ob_x, wchar, rscw);
	o.ob_y = adj_menu(o.ob_y, hchar, rsch);
	o.ob_width = adj_menu(o.ob_width, wchar, rscw);
	o.ob_height = adj_menu(o.ob_height, hchar, rsch);
	return 1;
}

static int pos_form(OBJECT& o)
{
	o.ob_x = adj(o.ob_x, wchar, rscw);
	o.ob_y = adj(o.ob_y, hchar, rsch);
	o.ob_width = adj(o.ob_width, wchar, rscw);
	o.ob_height = adj(o.ob_height, hchar, rsch);
	return 1;
}

static void pos_objects(RSHDR* header, long offset, int rscW, int rscH)
{
	rscw=rscW;
	rsch=rscH;

	int i;

	graf_handle( &wchar, &hchar, &i, &i );

	OBJECT* tree;

	for (i=0; (tree=(OBJECT*)rsc_gobj(header,offset,R_TREE,i)); i++) {
		titlefound=0;
		map_tree(tree,0,-1,findtitle);

		if (titlefound)
			map_tree(tree,0,-1,pos_menu);
		else
			map_tree(tree,0,-1,pos_form);
	}
}
		
static void fix_tedinfo(RSHDR* header, long offset)
{
	TEDINFO* rs_tedinfo=(TEDINFO*)(header->rsh_tedinfo+offset);

	int		i;

	for (i = 0; i < header->rsh_nted; i++) {
		rs_tedinfo[i].te_ptext=RSH(rs_tedinfo[i].te_ptext);
		rs_tedinfo[i].te_ptmplt=RSH(rs_tedinfo[i].te_ptmplt);
		rs_tedinfo[i].te_pvalid=RSH(rs_tedinfo[i].te_pvalid);
		fix_string(rs_tedinfo[i].te_ptext);
	}
}

static void fix_frstr(RSHDR* header, long offset)
{
	char** rs_frstr=(char**)(header->rsh_frstr+offset);

	int		i;
	
	for (i = 0; i < header->rsh_nstring; i++) {
		rs_frstr[i]=RSH(rs_frstr[i]);
		fix_string(rs_frstr[i]);
	}
}

static void fix_iconblk(RSHDR* header, long offset)
{
#ifdef ICONBLK_PLUS_2_BUG
	// ICONBLKs in the RSC file are 2 bytes shorter than those defined in gemfast.h
#	define RSHiconblk(x) (*((ICONBLK*)(header->rsh_iconblk+offset+x*(sizeof(ICONBLK)-2))))
#else
	// ICONBLKs are the right size now.
#	define RSHiconblk(x) (*((ICONBLK*)(header->rsh_iconblk+offset+x*(sizeof(ICONBLK)))))
#endif
	int		i;
	
	for (i = 0; i < header->rsh_nib; i++)
	{
		RSHiconblk(i).ib_pmask=RSH(RSHiconblk(i).ib_pmask);
		RSHiconblk(i).ib_pdata=RSH(RSHiconblk(i).ib_pdata);
		RSHiconblk(i).ib_ptext=RSH(RSHiconblk(i).ib_ptext);
		fix_string(RSHiconblk(i).ib_ptext);
	}
}

static void fix_bitblk(RSHDR* header, long offset)
{
	BITBLK* rs_bitblk=(BITBLK*)(header->rsh_bitblk+offset);

	int		i;
	
	for (i = 0; i < header->rsh_nbb; i++)
		rs_bitblk[i].bi_pdata=RSH(rs_bitblk[i].bi_pdata);
}

static void fix_frimg(RSHDR* header, long offset)
{
	char** rs_frimg=(char**)(header->rsh_frimg+offset);

	int		i;
	
	for (i = 0; i < header->rsh_nimages; i++)
		rs_frimg[i]=RSH(rs_frimg[i]);
}


/* this is the only 'exported' function in
 * this module.
 */
void rsc_fix(RSHDR* header, long offset, int rscw, int rsch)
{
	fix_trindex(header,offset);
	fix_objects(header,offset);
	fix_tedinfo(header,offset);
	fix_iconblk(header,offset);
	fix_bitblk(header,offset);
	fix_frstr(header,offset);
	fix_frimg(header,offset);
	pos_objects(header,offset,rscw,rsch);
}

#undef adj
#undef adj_menu
