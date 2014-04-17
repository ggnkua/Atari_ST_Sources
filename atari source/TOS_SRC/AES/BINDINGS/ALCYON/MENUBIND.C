/*	CRYSIF	LIBRARY		04/05/85	Derek Mui	*/

#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>
#include <crysbind.h>
#include "struct.h"

EXTERN UWORD		control[C_SIZE];
EXTERN UWORD		global[G_SIZE];
EXTERN UWORD		int_in[I_SIZE];
EXTERN UWORD		int_out[O_SIZE];
EXTERN LONG		addr_in[AI_SIZE];
EXTERN LONG		addr_out[AO_SIZE];

					/* Menu Manager			*/
	WORD
menu_popup( Menu, xpos, ypos, MData )
	MENU	      *Menu;
	WORD	      xpos;
	WORD	      ypos;
	MENU	      *MData;
{
	M_MENU	      = Menu;
	M_XPOS	      = xpos;
        M_YPOS	      = ypos;
	M_MDATA	      = MData;

	crys_if( MN_POPUP );

	return( RET_CODE );
}



	WORD
menu_attach( flag, tree, item, Menu )
	WORD	      flag;
	OBJECT	      *tree;
	WORD	      item;
	MENU	      *Menu;
{
	M_FLAG	      = flag;
	M_TREE	      = tree;
	M_ITEM	      = item;
	M_MDATA	      = Menu;

	crys_if( MN_ATTACH );

	return( RET_CODE );
}



	WORD
menu_istart( flag, tree, menu, item )
	WORD	    flag;
	OBJECT	    *tree;
	WORD	    menu;
	WORD	    item;
{
	M_FLAG      = flag;
	M_TREE      = tree;
	M_MENU2     = menu;	
	M_ITEM2     = item;

	crys_if( MN_ISTART );

	return( RET_CODE );
}



	WORD
menu_settings( flag, Values )
	WORD	      flag;
	MN_SET	      *Values;
{
	M_FLAG	      = flag;
	M_MENU	      = Values;

	crys_if( MN_SETTING );

	return( RET_CODE );
}
