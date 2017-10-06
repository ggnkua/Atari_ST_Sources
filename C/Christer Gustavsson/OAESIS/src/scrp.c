/****************************************************************************

 Module
  scrp.c
  
 Description
  Clipboard directory routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	
 Revision history
 
  960101 cg
   Implemented basic version of scrp_read() and scrp_write().
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <mintbind.h>
#include <stdio.h>
#include <string.h>

#include "scrp.h"
#include "types.h"

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static WORD path_isset = 0;
static BYTE scrp_path[500];

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/


/****************************************************************************
 * Scrp_read                                                                *
 *  0x0050 scrp_read()                                                      *
 ****************************************************************************/
void              /*                                                        */
Scrp_read(        /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	if(path_isset) {
		strcpy((BYTE *)apb->addr_in[0],scrp_path);
	
		apb->int_out[0] = 1;
	}
	else {
		((BYTE *)apb->addr_in[0])[0] = 0;
	
		apb->int_out[0] = 0;
	};
}

/****************************************************************************
 * Scrp_write                                                               *
 *  0x0051 scrp_write()                                                     *
 ****************************************************************************/
void              /*                                                        */
Scrp_write(       /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	XATTR xa;
	
	if(Fxattr(0,(BYTE *)apb->addr_in[0],&xa) == 0) {
		strcpy(scrp_path,(BYTE *)apb->addr_in[0]);
		apb->int_out[0] = 1;
	}
	else {
		apb->int_out[0] = 0;
	};
}
