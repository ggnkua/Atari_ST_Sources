/* babel - News transport agent for STiK
 *
 * stik-interface.h - Header file to accompany stik-interface.c. See that
 *                    for more information on why it's needed
 *
 * (c)1996 Mark Baker. Distributable under the terms of the GNU
 *                     general public licence
 *
 * $Id$
 */

/* Routines in stik-interface.c */

char *_KRmalloc( long size ) ;
void _KRfree( char *ptr ) ;
long _KRgetfree( long flag ) ;
char *_KRrealloc( char *block, long newsize ) ;
char *_get_err_text( long code ) ;
char *_getvstr( char *var ) ;
long _carrier_detect( void ) ;
long _TCP_open( unsigned long rhost, long rport, long tos, long obsize ) ;
long _TCP_close( long cn, long timeout ) ;
long _TCP_send( long cn, char *buf, long len ) ;
long _TCP_wait_state( long cn, long state, long timeout ) ;
long _TCP_ack_wait( long cn, long timeout ) ;
long _UDP_open( unsigned long rhost, long rport ) ;
long _UDP_close( long cn ) ;
long _UDP_send( long cn, char *buf, long len ) ;
long _CNkick( long cn ) ;
long _CNbyte_count( long cn ) ;
long _CNget_char( long cn ) ;
NDB *_CNget_NDB( long cn ) ;
long _CNget_block( long cn, char *blk, long len ) ;
void _housekeep( void ) ;
long _resolve( char *dn, char **rdn, unsigned long *alist, long lsize ) ;
void _ser_disable( void ) ;
void _ser_enable( void ) ;
long _set_flag( long flag ) ;
void _clear_flag( long flag ) ;
CIB *_CNgetinfo( long cn ) ;
