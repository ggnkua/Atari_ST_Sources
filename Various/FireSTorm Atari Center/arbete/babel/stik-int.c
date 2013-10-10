/* babel - News transport agent for STiK
 *
 * stik-interface.c - Interface to STiK
 *
 * (c)1996 Mark Baker. Distributable under the terms of the GNU
 *                     general public licence
 *
 * $Id: stik-interface.c,v 1.1 1996/07/20 09:57:52 mnb20 Exp $
 */
/* Programs compiled in long ints will always put things on the stack
 * as four bytes - even shorts. So they cannot directly call STiK which
 * expects arguments as shorts that only take up two bytes of stack.
 * These routines, compiled as short ints and taking explicitly long
 * arguments, should let me call STiK from a long int program.
 */

/* STiK headers */
#define cdecl /* We get loads of errors without this */
#include "include/transprt.h"

#include "stik-int.h"

/* Imported from socket.c */
extern DRV_LIST *drivers ;
extern TPL *tpl ;

/*
 * STiK routines. My versions have the same names but prefixed with
 *    underscores
 */

char *_KRmalloc( long size )
{
  return KRmalloc( size ) ;
}

void _KRfree( char *ptr )
{
  KRfree( ptr ) ;
}

long _KRgetfree( long flag )
{
  return KRgetfree( flag ) ;
}

char *_KRrealloc( char *block, long newsize )
{
  return KRrealloc( block, newsize ) ;
}

char *_get_err_text( long code )
{
  return get_err_text( code ) ;
}

char *_getvstr( char *var )
{
  return getvstr( var ) ;
}

long _carrier_detect( void )
{
  return carrier_detect() ;
}

long _TCP_open( unsigned long rhost, long rport, long tos, long obsize )
{
  return TCP_open( rhost, rport, tos, obsize ) ;
}

long _TCP_close( long cn, long timeout )
{
  return TCP_close( cn, timeout ) ;
}

long _TCP_send( long cn, char *buf, long len )
{
  return TCP_send( cn, buf, len ) ;
}

long _TCP_wait_state( long cn, long state, long timeout )
{
  return TCP_wait_state( cn, state, timeout ) ;
}

long _TCP_ack_wait( long cn, long timeout )
{
  return _TCP_ack_wait( cn, timeout ) ;
}

long _UDP_open( unsigned long rhost, long rport )
{
  return UDP_open( rhost, rport ) ;
}

long _UDP_close( long cn )
{
  return UDP_close( cn ) ;
}

long _UDP_send( long cn, char *buf, long len )
{
  return UDP_send( cn, buf, len ) ;
}

long _CNkick( long cn )
{
  return CNkick( cn ) ;
}

long _CNbyte_count( long cn )
{
  return CNbyte_count( cn ) ;
}

long _CNget_char( long cn )
{
  return CNget_char( cn ) ;
}

NDB *_CNget_NDB( long cn )
{
  return CNget_NDB( cn ) ;
}

long _CNget_block( long cn, char *blk, long len )
{
  return CNget_block( cn, blk, len ) ;
}

void _housekeep( void )
{
  housekeep() ;
}

long _resolve( char *dn, char **rdn, unsigned long *alist, long lsize )
{
  return resolve( dn, rdn, alist, lsize ) ;
}

void _ser_disable( void )
{
  ser_disable() ;
}

void _ser_enable( void )
{
  ser_enable() ;
}

long _set_flag( long flag )
{
  return set_flag( flag ) ;
}

void _clear_flag( long flag )
{
  clear_flag( flag ) ;
}

CIB *_CNgetinfo( long cn )
{
  return CNgetinfo( cn ) ;
}


