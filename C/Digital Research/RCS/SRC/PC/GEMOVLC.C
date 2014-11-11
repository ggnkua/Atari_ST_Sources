/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
/* Historical Copyright: */
/************************************************************************/
/*	Copyright ( c ) 1985 Digital Research Inc.		        */
/*    The software contained in this listing is proprietary to       	*/
/*    Digital Research Inc., Pacific Grove, California and is        	*/
/*    covered by U.S. and other copyright protection.  Unauthorized  	*/
/*    copying, adaptation, distribution, use or display is prohibited	*/
/*    and may be subject to civil and criminal penalties.  Disclosure	*/
/*    to others is prohibited.  For the terms and conditions of soft-	*/
/*    ware code use refer to the appropriate Digital Research        	*/
/*    license agreement.						*/
/************************************************************************/


#include "portab.h"
#include "rcs.h"

EXTERN VOID	rsrc_gaddr() ;
EXTERN VOID	form_alert() ;

/*--------------------------------------------------------------*/
    WORD
_ovlerr()
{
LONG	al_addr ;

    rsrc_gaddr( 5, NOOVLERR, &al_addr ) ;
    form_alert( 1,al_addr ) ;
} /* _ovlerr */

