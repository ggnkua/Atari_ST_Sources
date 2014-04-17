/* FIXRSH.C
 *==========================================================================
 * DATE: February 19, 1990
 * DESCRIPTION: Resource RSH file fixup for CPXs
 * 
 * INCLUDE FILE: FIXRSH.H
 */
 

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>


/* PROTOTYPES
 *==========================================================================
 */
void cdecl fix_rsh( int num_obs, int num_frstr, int num_frimg, int num_tree,
              OBJECT *rs_object, TEDINFO *rs_tedinfo, BYTE *rs_strings[],
              ICONBLK *rs_iconblk, BITBLK *rs_bitblk, long *rs_frstr,
              long *rs_frimg, long *rs_trindex, struct foobar *rs_imdope );
              
void cdecl Rsrc_obfix( OBJECT *tree, int curob );
int  Fix_chpos( int pfix, int ifx );


/* EXTERNALS
 *==========================================================================
 */


/* GLOBAL
 *==========================================================================
 */
BOOLEAN Fix_As_Dialog = FALSE;


/* LOCAL
 *==========================================================================
 */
struct foobar {
	WORD	dummy;
	WORD	*image;
	};

/* FUNCTIONS
 *==========================================================================
 */

/* fix_rsh()
 *==========================================================================
 * Takes the resource rsh attributes and performs x,y fixups.
 * In conjunction with Rsrc_obfix(), objects are adjusted according
 * to 16 pixel high and 8 pixel wide characters.
 * By using rsrc_obfix(), objects are adjusted according to the
 * current workstation character height and width.
 *
 * IN:   ALL of the objects can be found in the RSH file.
 *	 Note that some might have renamed items in their RSH to avoid
 *	 duplicate symbols, therefore, before saving a new RSH file,
 *	 check if there are variables that have been renamed and take
 *	 note of them.
 * OUT:  void
 *
 * GLOBAL: BOOLEAN Fix_As_Dialog:   TRUE - adjust old way based upon
 *				    the current char height and width.
 * This was necessary because some trees, such as our alert box and
 * menus, (if we ever use them) must not be adjusted for
 * 8x16 only.
 */
void
cdecl
fix_rsh( int num_obs, int num_frstr, int num_frimg, int num_tree,
         OBJECT *rs_object, TEDINFO *rs_tedinfo, BYTE *rs_strings[],
         ICONBLK *rs_iconblk, BITBLK *rs_bitblk, long *rs_frstr,
         long *rs_frimg, long *rs_trindex, struct foobar *rs_imdope )
{
    int     i;
    long    index;
    int     ob_type;
    
    for( i = 0; i < num_obs; i++ ) {
	index = rs_object[i].ob_spec.index;
	ob_type = rs_object[i].ob_type & 0x00ff;
	
	switch( ob_type ) {
	/* ob_spec -> TEDINFO */
	case G_TEXT:
	case G_BOXTEXT:
	case G_FTEXT:
	case G_FBOXTEXT:
	    /* fix pointers in TEDINFO */
	    rs_tedinfo[index].te_ptext =
		rs_strings[(long)(rs_tedinfo[index].te_ptext)];
	    rs_tedinfo[index].te_ptmplt =
		rs_strings[(long)(rs_tedinfo[index].te_ptmplt)];
	    rs_tedinfo[index].te_pvalid =
		rs_strings[(long)(rs_tedinfo[index].te_pvalid)];
	    /* fix ob_spec */
	    rs_object[i].ob_spec.tedinfo = &rs_tedinfo[index];
	    break;
	/* ob_spec -> ICONBLK */
	case G_ICON:
	    /* fix pointers in ICONBLK */
	    #pragma warn -sus
	    rs_iconblk[index].ib_pmask =
		rs_imdope[(long)(rs_iconblk[index].ib_pmask)].image;
	    rs_iconblk[index].ib_pdata =
		rs_imdope[(long)(rs_iconblk[index].ib_pdata)].image;
	    #pragma warn .sus
	    rs_iconblk[index].ib_ptext =
		rs_strings[(long)(rs_iconblk[index].ib_ptext)];
	    rs_object[i].ob_spec.iconblk = &rs_iconblk[index];
	    break;
	/* ob_spec -> BITBLK */
	case G_IMAGE:
	    /* fix pointers in BITBLK */
	    #pragma warn -sus
	    rs_bitblk[index].bi_pdata =
		rs_imdope[(long)(rs_bitblk[index].bi_pdata)].image;
	    #pragma warn .sus
	    rs_object[i].ob_spec.bitblk = &rs_bitblk[index];
	    break;
	/* ob_spec -> string */
	case G_BUTTON:
	case G_STRING:
	case G_TITLE:
	    rs_object[i].ob_spec.free_string = rs_strings[index];
	    break;
	/* ob_specs not requiring fixups */
	case G_USERDEF:
	case G_BOX:
	case G_IBOX:
	case G_BOXCHAR:
	    break;
	}
	if( Fix_As_Dialog )
		rsrc_obfix( rs_object, i );
	else
		Rsrc_obfix( rs_object, i );
    }

    /* fix up free strings & images */
    for( i = 0; i < num_frstr; i++ )
	rs_frstr[i] = (long)(rs_strings[rs_frstr[i]]);
    for( i = 0; i < num_frimg; i++ ) {
	index = rs_frimg[i];
	#pragma warn -sus
	rs_bitblk[index].bi_pdata =
	    rs_imdope[(long)(rs_bitblk[index].bi_pdata)].image;
	#pragma warn .sus
	rs_frimg[i] = (long)(&rs_bitblk[rs_frimg[i]]);
    }
    /* fix up tree index references */
    for( i = 0; i < num_tree; i++ )
    	rs_trindex[i] = (long)(&rs_object[rs_trindex[i]]);
    Fix_As_Dialog = FALSE;
}



/* Rsrc_obfix()
 *==========================================================================
 * Custom Resource Fixup that always has horizontal characters as
 * multiples of 8 pixels and vertical characters as multiples of
 * 16 pixels.
 */
void
cdecl
Rsrc_obfix( OBJECT *tree, int curob)
{
	GRECT p;
	
	p = ObRect( curob );
	ObX(curob) = Fix_chpos(p.g_x,TRUE);
	ObY(curob) = Fix_chpos(p.g_y,FALSE);
	ObW(curob) = Fix_chpos(p.g_w,TRUE);
	ObH(curob) = Fix_chpos(p.g_h,FALSE);
}



/* Fix_chpos()
 *==========================================================================
 * Converts the characters to Pixel position offsets.
 * Horizontal characters are always multiples of 8 pixels.
 * Vertical characters are always multiples of 16 pixels.
 * IFX = flag for 0 - y value, 1 - x value
 */
int
Fix_chpos( int pfix, int ifx )
{
	int cpos,coffset;
	
	cpos = pfix;
	coffset = (cpos >> 8) & 0x00ff;
	cpos &= 0x00ff;
	cpos *= (ifx) ? 8 : 16;
	cpos += (coffset > 128) ? (coffset - 256): coffset;
	return(cpos);		
}


