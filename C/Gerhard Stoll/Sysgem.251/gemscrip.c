/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1994, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <string.h>
#include        <stdlib.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

VOID RegisterGemScript ( GS_PROC p )

{
  sysgem.gs_proc = p;
}

/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/*
VOID SendGSRequest

{
  INT	msg [8];
  
  msg [0] =
  msg [1] =
  msg [2] =
  msg [3] =
  msg [4] =
  msg [5] =
  msg [6] =
  msg [7] =

  appl_write ( appl_id, 16, msg );
  evnt_timer ( 20, 0 );
}
*/
/* ------------------------------------------------------------------- */

VOID SendGSReply ( INT appl_id, INT gs_id )

{
  INT	msg [8];
  
  msg [0] = GS_REPLY;
  msg [1] = sysgem.appl_id;
  msg [2] = 0;
  msg [3] = (INT)((LONG)( sysgem.gs_info ) >> 16 );
  msg [4] = (INT)((LONG)( sysgem.gs_info ) >>  0 );
  msg [5] = 0;
  msg [6] = 0;
  msg [7] = gs_id;

  appl_write ( appl_id, 16, msg );
  evnt_timer ( 20, 0 );
}

/* ------------------------------------------------------------------- */
/*
VOID SendGSCommand

{
  INT	msg [8];
  
  msg [0] =
  msg [1] =
  msg [2] =
  msg [3] =
  msg [4] =
  msg [5] =
  msg [6] =
  msg [7] =

  appl_write ( appl_id, 16, msg );
  evnt_timer ( 20, 0 );
}
*/
/* ------------------------------------------------------------------- */

VOID SendGSAck ( INT appl_id, ULONG arg, BOOL ascii, INT ret )

{
  INT	msg [8];
  
  msg [0] = GS_ACK;
  msg [1] = sysgem.appl_id;
  msg [2] = 0;
  msg [3] = (INT)( arg >> 16 );
  msg [4] = (INT)( arg >>  0 );
  msg [5] = ( ascii == TRUE ) ? (INT)((ULONG)( sysgem.gs_buffer ) >> 16 ) : 0;
  msg [6] = ( ascii == TRUE ) ? (INT)((ULONG)( sysgem.gs_buffer ) >>  0 ) : 0;
  msg [7] = ret;

  appl_write ( appl_id, 16, msg );
  evnt_timer ( 20, 0 );
}

/* ------------------------------------------------------------------- */
/*
VOID SendGSQuit

{
  INT	msg [8];
  
  msg [0] =
  msg [1] =
  msg [2] =
  msg [3] =
  msg [4] =
  msg [5] =
  msg [6] =
  msg [7] =

  appl_write ( appl_id, 16, msg );
  evnt_timer ( 20, 0 );
}
*/
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */
/* ------------------------------------------------------------------- */

VOID sgHandleGemScript ( INT *xmsg )

{
  ULONG		arg;
  INT		appl_id;
  INT		id;
  INT		ret;
  
  switch ( xmsg [0] )
    {
      case GS_REQUEST	: SendGSReply ( xmsg [1], xmsg [7] );
                          break;
      case GS_REPLY	: break;
      case GS_COMMAND	: arg = *(ULONG *) &xmsg [3];
                          /*
                          memcpy ( &arg, &xmsg [3], sizeof ( ULONG ));
                          */
                          if (( sysgem.gs_proc != NULL ) && ( arg != 0L ))
                            {
                              appl_id = xmsg [1];
                              id      = xmsg [7];
                              ret     = sysgem.gs_proc ( GS_COMMAND, (BYTE *) arg, sysgem.gs_buffer, appl_id, id );
                              if ( ret <= 0 )		/* [GS] */
                                {
                                  SendGSAck ( appl_id, arg, TRUE, ret * ( -1 ));
                                }
                              else
                                {
                                  SendGSAck ( appl_id, arg, FALSE, ret );
                                }
                            }
                          break;
      case GS_ACK	: break;
      case GS_QUIT	: break;
    }
}

/* ------------------------------------------------------------------- */

