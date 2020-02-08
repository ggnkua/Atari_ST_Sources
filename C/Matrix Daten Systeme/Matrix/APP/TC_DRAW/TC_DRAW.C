/*	tc_draw	/	23.7.91	/	MATRIX	/WA	*/

#include <vdi.h>
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <global.h>

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\files.h"
# include "\pc\cxxsetup\dialog.h"
# include "\pc\cxxsetup\poti.h"
# include "\pc\cxxsetup\main.h"

# include <windows.h>

# include "draw_wnd.h"
# include "tc_dra.h"
# include "tc_draw.h"

char rsc_filename[]	  = "tc_draw.rsc" ;
char acc_menu_title[] = "  "TITEL ;

extern int  menu_num_tree = TR_MENU ;

/*------------------------------------------------- open_application_window -----*/
bool open_application_window(int argc,char *argv[])
{
	return ( open_tcdraw_window ( argc, argv ) ) ;
}

/*------------------------------------------------- init_application -*/
bool init_application(void)
{
	return (	init_dialog ( MESGBOX )
			 && init_poti ( EDITJINT )

			 && init_tcdraw() ) ;
}

/*------------------------------------------------- term_application -*/
void term_application(void)
{
	term_poti() ;

	term_tcdraw() ;
}


