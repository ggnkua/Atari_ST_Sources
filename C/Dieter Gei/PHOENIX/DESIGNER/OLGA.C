/*****************************************************************************
 *
 * Module : OLGA.C
 * Author : Gerhard Stoll
 *
 * Creation date    : 20.12.02
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the olga protocol
 *
 * History:
 * 20.12.02: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"


#include "files.h"
#include "olga.h"
#include "ph_lib.h"

#include "export.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD msgbuff[8];

/****** FUNCTIONS ************************************************************/

LOCAL VOID ole_init ( VOID );
LOCAL VOID ole_exit ( VOID );


/*****************************************************************************/

LOCAL VOID ole_init ( VOID )
{
	msgbuff[0] = OLE_INIT;
	msgbuff[1] = gl_apid;
  msgbuff [2] = 0;
  msgbuff [3] = OL_CLIENT;
  msgbuff [4] = 0;
  msgbuff [5] = 0;
  msgbuff [6] = 0;
  msgbuff [7] = 0x4442;									/* "DP" */

	appl_write ( olga_apid, 16, msgbuff);
}

/*****************************************************************************/

LOCAL VOID ole_exit ( VOID )
{
  if (olga_apid >= 0)
  {
		msgbuff[0] = OLE_EXIT;
		msgbuff[1] = gl_apid;
	  msgbuff [2] = 0;
	  msgbuff [3] = 0;
	  msgbuff [4] = 0;
	  msgbuff [5] = 0;
	  msgbuff [6] = 0;
	  msgbuff [7] = 0;
	
		appl_write ( olga_apid, 16, msgbuff);
	} /* if */
}

/*****************************************************************************/

GLOBAL WORD hndl_olga ( WORD msg[16] )
{
	WORD ret;
	
	ret = FALSE;
	switch ( msg [0] )
	{
		case OLGA_INIT:
	    if (msg [7] == 0)
  	  	olga_apid = FAILURE;
   		ret = TRUE;
   	break;
   	case OLE_NEW:
   		olga_apid = msg [1];
			ole_init ();
   		ret = TRUE;
   	break;
  } /* switch */

	return ret;
} /* hndl_olga */


/*****************************************************************************/

GLOBAL VOID init_olga ( VOID )
{
  FULLNAME  act_path;
  WORD      act_drive, drive;
	FULLNAME	olga_path, olga_name;
	VOID			*p;

	olga_apid = appl_find("OLGA    ");
	if (olga_apid > 0)
		ole_init();
	else
	{
		p = getenv("OLGAMANAGER");
		if (p != NULL)
		{

			strcpy(olga_name, p);
			file_split ( olga_name, &drive, olga_path, NULL, NULL );

		  get_path (act_path);
  		act_drive = get_drive ();

		  set_drive (drive);
			set_path (olga_path); 


			if ( _GemParBlk.global[0] >= 0x400 )
				shel_write(1, 1, 1, olga_name, "");
			else
			{
				if ( get_magic () )
					shel_write(1, 1, 100, olga_name, "");
			} /* if */

		  set_drive (act_drive);
  		set_path (act_path);

		} /* if */
	} /* if */
}

/*****************************************************************************/

GLOBAL VOID term_olga ( VOID )
{
  if (olga_apid >= 0)
		ole_exit ();
}
