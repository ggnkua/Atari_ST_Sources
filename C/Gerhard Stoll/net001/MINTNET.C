#include <aes.h>
#include <tos.h>
#include <sys\socket.h>

#define DEBUG	0

#if DEBUG
	#include <stdio.h>
#endif

#include "trapper.h"


int16 apid;
GlobalArray global;

const void (*old_etv_term)(void);
const void etv_term(void);

/*---------------------------------------------------------------------------*/
/* para[0] = Opcode                                                          */

/*---------------------------------------------------------------------------*/
/* Fsocket ( long domain, long type, long protocol)                          */
/* socket	 ( int  domain, int  type, int  protocol)                          */

int32 CDECL GemdosFsocket (int16 *para, int16 *call_original, int16 super_called)
{
	int16 ret;

	*call_original = FALSE;

	ret = socket ( para[2], para[4], para[6] );

	return (int32) ret;
}

/*----------------------------------------------------------------------------*/
/* Faccept (short fd, struct sockaddr *name, ulong *anamelen)									*/
/* accept  (int   fd, struct sockaddr *name, _SIZE_T *anamelen)								*/

int32 CDECL GemdosFaccept (int16 *para, int16 *call_original, int16 super_called)
{
	int16 ret;
	int32 parm2, parm3;

	*call_original = FALSE;

	parm2 = (int32) *((long *)(para + 2));
	parm3 = (int32) *((long *)(para + 4));

	ret = accept ( para[1], (struct sockaddr *)parm2, (_SIZE_T *)parm3 );
	
	return (int32) ret;
}

/*----------------------------------------------------------------------------*/
/* Fbind (int fd, struct sockaddr *addr, long addrlen)                       	*/
/* bind  (int fd, struct sockaddr *addr, _SIZE_T addrlen)                    	*/

int32 CDECL GemdosFbind (int16 *para, int16 *call_original, int16 super_called)
{
	int16 ret;
	int32 parm2, parm3;

	*call_original = FALSE;

	parm2 = (int32) *((long *)(para + 2));
	parm3 = (int32) *((long *)(para + 4));

 	ret = bind ( para[1], (struct sockaddr *)parm2, parm3 );
	
	return (int32) ret;
}

/*----------------------------------------------------------------------------*/
/* Fconnect (int fd, struct sockaddr *addr, long addrlen)                    	*/
/* connect  (int fd, struct sockaddr *addr, _SIZE_T addrlen )                	*/

int32 CDECL GemdosFconnect (int16 *para, int16 *call_original, int16 super_called)
{
	int16 ret;
	int32 parm2, parm3;

	*call_original = FALSE;

	parm2 = (int32) *((long *)(para + 2));
	parm3 = (int32) *((long *)(para + 4));

	ret = connect ( para[1], (struct sockaddr *)parm2, parm3 );

	return (int32) ret;
}

/*----------------------------------------------------------------------------*/
/* Flisten (int fd, long backlog)										                         	*/
/* listen  (int fd, int  backlog)	                         										*/

int32 CDECL GemdosFlisten (int16 *para, int16 *call_original, int16 super_called)
{
	int16 ret;
	int32 parm2;

	*call_original = FALSE;

	parm2 = (int32) *((long *)(para + 2));

#if DEBUG
	printf ("Flisten: fd = %i, backlog =%i\r\n", para[1], (int16) parm2 );
#endif

	ret = listen ( para[1], (int16) parm2 );

	return (int32) ret;
}

/*----------------------------------------------------------------------------*/
/* Fgetsockname (int fd, struct sockaddr *addr, long *addrlen)               	*/
/* getsockname	(int fd, struct sockaddr *addr,  _SIZE_T *addrlen)           	*/

int32 CDECL GemdosFgetsockname (int16 *para, int16 *call_original, int16 super_called)
{
	int16 ret;
	int32 parm2, parm3;

	*call_original = FALSE;

	parm2 = (int32) *((long *)(para + 2));
	parm3 = (int32) *((long *)(para + 4));

	ret = getsockname ( para[1], (struct sockaddr *)parm2, (_SIZE_T *)parm3 );

	return (int32) ret;	
}

/*----------------------------------------------------------------------------*/
/* Install 																																		*/

static int install_trace( void )
{
   if ( TrapperInstallGemdosCall( 352, GemdosFsocket ) == E_OK ) {
      if ( TrapperInstallGemdosCall( 354, GemdosFaccept) == E_OK) {
	      if ( TrapperInstallGemdosCall( 356, GemdosFbind) == E_OK) {
	         if ( TrapperInstallGemdosCall( 355, GemdosFconnect) == E_OK) {
		         if ( TrapperInstallGemdosCall( 357, GemdosFlisten) == E_OK) {
		            if ( TrapperInstallGemdosCall( 365, GemdosFgetsockname) == E_OK) {
		               old_etv_term = Setexc(0x102, etv_term);   /* etv_term setzen! */
		               return TRUE;
		            }
		            TrapperRemoveGemdosCall( 357, GemdosFlisten );
		          }
	            TrapperRemoveGemdosCall( 355, GemdosFconnect );
	         }
	         TrapperRemoveGemdosCall( 356, GemdosFbind );
	      }
	      TrapperRemoveGemdosCall( 354, GemdosFaccept );
	   }
      TrapperRemoveGemdosCall( 352, GemdosFsocket );
   }
   return FALSE;
}

/*-------------------------------------------------------------------*/
/* Deinstall																			*/

static void deinstall_trace( int is_super, int wait)
{
   Setexc(0x102, old_etv_term);
   TrapperRemoveGemdosCall( 365, GemdosFgetsockname);
   TrapperRemoveGemdosCall( 355, GemdosFconnect );
   TrapperRemoveGemdosCall( 356, GemdosFbind);
   TrapperRemoveGemdosCall( 352, GemdosFsocket);
}

/*-------------------------------------------------------------------*/
/* New etv_term                                                      */

const void etv_term(void)
{
   deinstall_trace( TRUE, FALSE );
}

/*-------------------------------------------------------------------*/
/* Main program																		*/

void main ( void )
{

   if ( TrapperCheck ( NULL ) != E_OK )
   {
      Cconws("MiNTNet Simu: Please install Trapper!\r\n");
   }


   if ((apid = mt_appl_init( &global ) ) >= 0)
   {
      if (install_trace())
      {
         int terminate = FALSE;
         int16 which;
         EVENT ev;

         ev.ev_mflags = MU_MESAG/* |MU_TIMER */;
         ev.ev_mtlocount = 300;
         ev.ev_mthicount = 0;
         while (!terminate)
         {
            which = mt_EvntMulti( &ev, &global );
            if (which & MU_MESAG)
            {
               switch (ev.ev_mmgpbuf[0])
               {
                  case AP_TERM:
                     terminate = TRUE;
                  break;
               }
            }
         }

         deinstall_trace(FALSE, TRUE);

      }

      mt_appl_exit ( &global ) ;

   }
}
