/*=============================================================================

                              HydraCom Version 1.00

                         A sample implementation of the
                   HYDRA Bi-Directional File Transfer Protocol

                             HydraCom was written by
                   Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED

                       The HYDRA protocol was designed by
                 Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT and
                             Joaquim H. Homrighausen
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED


  Revision history:
  06 Sep 1991 - (AGL) First tryout
  .. ... .... - Internal development
  11 Jan 1993 - HydraCom version 1.00, Hydra revision 001 (01 Dec 1992)


  For complete details of the Hydra and HydraCom licensing restrictions,
  please refer to the license agreements which are published in their entirety
  in HYDRACOM.C and LICENSE.DOC, and also contained in the documentation file
  HYDRACOM.DOC

  Use of this file is subject to the restrictions contained in the Hydra and
  HydraCom licensing agreements. If you do not find the text of this agreement
  in any of the aforementioned files, or if you do not have these files, you
  should immediately contact LENTZ SOFTWARE-DEVELOPMENT and/or Joaquim
  Homrighausen at one of the addresses listed below. In no event should you
  proceed to use this file without having accepted the terms of the Hydra and
  HydraCom licensing agreements, or such other agreement as you are able to
  reach with LENTZ SOFTWARE-DEVELOMENT and Joaquim Homrighausen.


  Hydra protocol design and HydraCom driver:         Hydra protocol design:
  Arjen G. Lentz                                     Joaquim H. Homrighausen
  LENTZ SOFTWARE-DEVELOPMENT                         389, route d'Arlon
  Langegracht 7B                                     L-8011 Strassen
  3811 BT  Amersfoort                                Luxembourg
  The Netherlands
  FidoNet 2:283/512, AINEX-BBS +31-33-633916         FidoNet 2:270/17
  arjen_lentz@f512.n283.z2.fidonet.org               joho@ae.lu

  Please feel free to contact us at any time to share your comments about our
  software and/or licensing policies.

=============================================================================*/

#ifndef _ASYNC_H_
#define _ASYNC_H_

/* HJW Changes for Topspeed to force C type stackframe. To make the
   program faster we should use the JPI calling conventions, but that
   means a lot of work to change the async.asm file. Maybe later. This
   is as fast as the original
*/


#ifdef _JPI_
  #pragma save
  #pragma call(c_conv => on)
#endif

int             AsyncInit( int Port);
void            AsyncStop( void),
                AsyncDump( void),
                AsyncPurge( void),
                AsyncOut( int c),
                AsyncHand( int handshake),
                AsyncSet( word Baud, int Control);
int             AsyncIn( void),
                AsyncInStat( void),
                AsyncOutStat( void);
unsigned        AsyncStat( void);
                AsyncCTS( int enable);
                AsyncFifo( void);

/* HJW reset Topspeed to use the JPI calling conventions */

#ifdef _JPI_
  #pragma restore
#endif

#define COM1            0
#define COM2            1
#define COM3            2
#define COM4            3

/* Defines for Com Port Paramaters, the second paramater to AsyncSet() */
#define BITS_8          0x03
#define BITS_7          0x02
#define STOP_1          0x00
#define STOP_2          0x04
#define EVEN_PARITY     0x18
#define ODD_PARITY      0x08
#define NO_PARITY       0x00

/* Defines for AsyncHand() */
#define DTR             0x01
#define RTS             0x02
#define USER            0x04
#define LOOPBACK        0x10

/* Defines for AsyncStat() */
#define D_CTS   0x0100
#define D_DSR   0x0200
#define D_RI            0x0400
#define D_DCD   0x0800
#define CTS             0x1000
#define DSR             0x2000
#define RI              0x4000
#define DCD             0x8000
#define PARITY  0x0004
#define THREMPTY        0x0020
#define BREAKDET        0x1000

#endif

/* end of async.h */
