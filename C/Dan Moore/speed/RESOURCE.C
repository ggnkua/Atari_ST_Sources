/*
 * 
 * Internal resource setup.
 *
 * by Daniel L. Moore
 *
 * this file supplies the code to include the resource data file internal
 * to the program.  This is done by including the .rsh file produced by
 * the RSC into the program.  The three routines in this file then take
 * care of actually getting the resource data that was loaded ready to 
 * use.  The routines are:
 *
 *       rsrc_load()       --- does a rsrc_obfix on all objects and puts
 *                             all the trees/strings together.  
 *
 *       rsrc_gaddr()      --- returns the address of the loaded resoruce 
 *                             object tree.
 *
 *       rsrc_free()       --- a dummy, just to catch the "real" call.
 *
 */
 
#include <portab.h>
#include <obdefs.h>
#include <gemdefs.h>

#include "speed.rsh"   /* C source to resource data */

int
rsrc_load(name)
char *name;			/* passed param, ignored here */
{
	/*
	 * loads the resource.  This really means it just hooks all the objects
	 * together and does rsrc_obfix() calls for all of them.
	 */
	register int i, j;
	register long sum = 0L;
	extern long cksum();

	/* first loop the rs_index array and locate the trees */
	for (i = 0; i < NUM_TREE; i++)
		rs_trindex[i] = (long) &(rs_object[(int)rs_trindex[i]]);    

	/* now go thru the rs_object array and take care of the objects */
	for (i = 0; i < NUM_OBS; i++) {
		rsrc_obfix(rs_object, i);   /* fix coordinates */
		j = (int) rs_object[i].spec;
		switch (rs_object[i].type) {
		case G_STRING :
		case G_BUTTON : 
		case G_TITLE  :
			rs_object[i].spec = rs_strings[j];
			break;
		case G_TEXT     :
		case G_BOXTEXT  :
		case G_FBOXTEXT :
		case G_FTEXT    :
			rs_object[i].spec    = (BYTE *) &rs_tedinfo[j];
			rs_tedinfo[j].ptext  = rs_strings[(int)rs_tedinfo[j].ptext];
			rs_tedinfo[j].ptmplt = rs_strings[(int)rs_tedinfo[j].ptmplt];
			rs_tedinfo[j].pvalid = rs_strings[(int)rs_tedinfo[j].pvalid];
			break;
		case G_IMAGE    :
			rs_object[i].spec  = (BYTE *) &rs_bitblk[j];
			rs_bitblk[j].pdata = rs_imdope[(int)rs_bitblk[j].pdata].image;
			break;
		case G_ICON     :
			rs_object[i].spec   = (BYTE *) &rs_iconblk[j];
			rs_iconblk[j].pmask = rs_imdope[(int)rs_iconblk[j].pmask].image;
			rs_iconblk[j].pdata = rs_imdope[(int)rs_iconblk[j].pdata].image;
			rs_iconblk[j].ptext = rs_strings[(int)rs_iconblk[j].ptext];
			break;
		}
	}

	/*
	 * in theory we could compare the resource name to the passed name
	 * to make sure the right .rsh file is included.  but why bother,
	 * as soon as the program is run it will be obvious if the wrong
	 * file is included.
	 */

	return(1);      /* return a success flag, we never fail */
}

void
rsrc_gaddr(type, which, tree_ptr)
       int type, which;
OBJECT_PTR *tree_ptr;
{
	/*
	 * get the address of the start of the tree
	 */
	if (type == R_TREE) {   /* do we understand the command? */
		*tree_ptr = (OBJECT_PTR) rs_trindex[which];
	}
}
 
void
rsrc_free()
{
	;       /* don't do much of anything */
}
