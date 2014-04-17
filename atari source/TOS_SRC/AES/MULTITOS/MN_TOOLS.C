/* MN_TOOLS.C
 * ======================================================================
 * DESCRIPTION: TOOLS for the menu.c file.
 * 		prototypes and defines are in tools.h
 *
 * 11/22/91 cjg	created from aesapi and aesalt
 * 01/30/92 cjg - Converted to Alcyon ( AES Version )
 *              - use internal AES calls
 * 02/19/92 cjg - merged into AES
 * 02/25/92 cjg - removed a heck of alot of code...
 * 03/24/92 cjg - removed WaitForUpButton()
 * 05/13/92 cjg - used binding calls
 * 05/15/92 cjg - Don't use binding calls - use internal AES calls
 * 
 * 02/11/93 cjg - Convert to Lattice C 5.51
 * 02/19/93 cjg - Force the use of Prototype Files
 */


/* INCLUDES
 * ======================================================================
 */
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "pdstruct.h"
#include "dispvars.h"
#include "objaddr.h"
#include "osbind.h"



/* EXTERNS
 * ======================================================================
 */


/* FUNCTIONS
 * ======================================================================
 */



/* ObjcDraw()
 * ======================================================================
 */
VOID
ObjcDraw( tree, obj, rect )
OBJECT *tree;
WORD   obj;
GRECT  *rect;
{
   gsx_sclip( rect );
   ob_draw( ( LONG )tree, obj, MAX_DEPTH );
}



/* rc_2xy()
 * ================================================================
 */
VOID
rc_2xy( r, pxy )
GRECT	*r;
WORD	*pxy;
{
	*(GRECT *)pxy = *r;
	pxy[2] += r->g_x - 1;
	pxy[3] += r->g_y - 1;
}
