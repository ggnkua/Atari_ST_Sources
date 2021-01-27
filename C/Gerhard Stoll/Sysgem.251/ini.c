/* ------------------------------------------------------------------- *
 * Module Version       : 2.00                                         *
 * Author               : Andrea Pietsch                               *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 1995, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <stdio.h>
#include        <string.h>
#include        <tos.h>

/* ------------------------------------------------------------------- */

EXTERN  SYSGEM  sysgem;

/* ------------------------------------------------------------------- */

INI_CFG *get_ini ( BYTE *keyword )

{
  INI_CFG       *ini;

  ini = sysgem.pini;
  while ( ini != NULL )
    {
      if ( strcmp ( keyword, ini->keyword ) == 0 )
        {
          return ( ini );
        }
      ini = ini->next;
    }
  return ( NULL );
}

/* ------------------------------------------------------------------- */

UINT CountKeywords ( VOID )

{
  INI_CFG       *ini;
  UINT          i;

  ini = sysgem.pini;
  i   = 0U;
  forever
    {
      if ( ini == NULL ) break;
      i++;
      ini = ini->next;
    }
  return ( i );
}

/* ------------------------------------------------------------------- */

BOOL SetConfig ( BYTE *keyword, VOID *value, LONG len )

{
  INI_CFG       *ini;
  VOID          *new;

  if (( len <= 0L ) || ( keyword == NULL ) || ( length ( keyword ) == 0 ))
    {
      return ( FALSE );
    }

  if (( ini = get_ini ( keyword )) != NULL )
    {
      new = Allocate ( len );
      if ( new == NULL ) return ( FALSE );
      if ( value != NULL ) memcpy ( new, value, len );
      if ( ini->value != NULL )
        {
          Dispose ( ini->value );
        }
      ini->value = new;
      ini->len   = len;
      if ( sysgem.spy_ini != NULL ) sysgem.spy_ini ();
      return ( TRUE );
    }
  ini = (INI_CFG *) Allocate ( sizeof ( INI_CFG ));
  if ( ini == NULL ) return ( FALSE );

  new = Allocate ( len );
  if ( new == NULL ) return ( FALSE );

  ini->keyword = (BYTE *) Allocate ( strlen ( keyword ) + 1L );
  if ( ini->keyword == NULL )
    {
      Dispose ( new );
      Dispose ( ini );
      return ( FALSE );
    }

  if ( value != NULL ) memcpy ( new, value, len );
  strcpy  ( ini->keyword, keyword );
  ini->len      = len;
  ini->value    = new;
  InsertPtr ( &sysgem.pini, ini );
  if ( sysgem.spy_ini != NULL ) sysgem.spy_ini ();
  return ( TRUE );
}

/* ------------------------------------------------------------------- */

BOOL GetConfig ( BYTE *keyword, VOID *value )

{
  INI_CFG       *ini;

  ini = get_ini ( keyword );
  if ( ini != NULL )
    {
      if ( value == NULL ) return ( TRUE );
      memcpy ( value, ini->value, ini->len );
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL GetConfigPtr ( BYTE *keyword, VOID *ptr, LONG *len )

{
  INI_CFG       *ini;
  LONG          *p;

  ini = get_ini ( keyword );
  if ( ini != NULL )
    {
      p = (LONG *) ptr;
      if ( ptr != NULL ) *p = (LONG)( ini->value );
      if ( len != NULL ) *len = ini->len;
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

BOOL DelConfig ( BYTE *keyword )

{
  INI_CFG       *ini;

  ini = get_ini ( keyword );
  if ( ini != NULL )
    {
      Dispose ( ini->keyword );
      Dispose ( ini->value );
      DeletePtr ( &sysgem.pini, ini );
      if ( sysgem.spy_ini != NULL ) sysgem.spy_ini ();
      return ( TRUE );
    }
  return ( FALSE );
}

/* ------------------------------------------------------------------- */

LONG SaveConfig ( BYTE *file_name )

{
  INI_CF0       h1;
  INI_CF1       h2;
  INI_CFG       *ini;
  LONG          fh;
  INT           h;

  if ( CountKeywords () == 0U ) return ( 0L );

  fh = Fcreate ( file_name, 0 );
  if ( fh < 0L ) return ( fh );
  h = (INT)( fh );

  h1.magic      = 'SGEM';
  h1.version    = '2.02';
  h1.anz        = (LONG) CountKeywords ();
  h1.crc        = 0U;
  h1.crc        = crc_32 ((BYTE *) &h1, (UINT)( sizeof ( h1 )));
  if ( Fwrite ( h, sizeof ( h1 ), &h1 ) != sizeof ( h1 )) goto ende;

  ini = sysgem.pini;
  while ( ini != NULL )
    {
      h2.crc_all        = 0UL;
      h2.crc_key        = crc_32 ( ini->keyword, strlen ( ini->keyword ));
      h2.crc_val        = crc_32 ( ini->value,   ini->len );
      h2.len_key        = strlen ( ini->keyword );
      h2.len_val        = ini->len;
      h2.crc_all        = crc_32 ((BYTE *) &h2, sizeof ( h2 ));

      if ( Fwrite ( h, sizeof ( h2 ), &h2 ) != sizeof ( h2 )) goto ende;
      if ( Fwrite ( h, strlen ( ini->keyword ), ini->keyword ) != strlen ( ini->keyword )) goto ende;
      if ( Fwrite ( h, ini->len, ini->value ) != ini->len ) goto ende;

      ini = ini->next;
    }

  Fclose ( h );
  return ( h1.anz );

  ende:
  Fclose ( h );
  return ( 0L );
}

/* ------------------------------------------------------------------- */

LONG LoadConfig ( BYTE *file_name )

{
  INI_CF0       h1;
  INI_CF1       h2;
  LONG          fh;
  ULONG         crc;
  LONG          i;
  BYTE          *n1;
  BYTE          *n2;
  BOOL          del;
  LONG		ret;
  INT           h;

  del = FALSE;
  ret = 0L;

  fh = Fopen ( file_name, FO_READ );
  if ( fh < 0L ) return ( fh );
  h = (INT)( fh );

  if ( Fread ( h, sizeof ( h1 ), &h1 ) != sizeof ( h1 )) goto ende;

  if ( h1.magic   != 'SGEM' ) goto ende;		/* Header testen  				 */
  if ( h1.version != '2.02' ) goto ende;

  crc = h1.crc;
  h1.crc = 0UL;
  if ( crc_32 ((BYTE *) &h1, sizeof ( h1 )) != crc )
    {
      ret = -4711L;
      goto ende;
    }

  if ( CountKeywords () != 0U )
    {
      do_delete:
      if ( sysgem.pini != NULL )
        {
          while ( sysgem.pini != NULL )
            {
              DelConfig ( sysgem.pini->keyword );
            }
          if ( sysgem.spy_ini != NULL ) sysgem.spy_ini ();
        }
    }
  if ( del ) return ( ret );

  for ( i = 0L; i < h1.anz; i++ )
    {
      if ( Fread ( h, sizeof ( h2 ), &h2 ) != sizeof ( h2 )) goto ende;
      crc = h2.crc_all;
      h2.crc_all = 0UL;
      if ( crc_32 ((BYTE *) &h2, sizeof ( h2 )) != crc ) goto ende;

      n1 = (BYTE *) Allocate ( h2.len_key + 1L );
      if ( n1 == NULL )
        {
          ret = -39L;
          del = TRUE;
          goto ende;
        }
      n2 = (BYTE *) Allocate ( h2.len_val );
      if ( n2 == NULL )
        {
          ret = -39L;
          del = TRUE;
          goto ende;
        }

      if ( Fread ( h, h2.len_key, n1 ) != h2.len_key )
        {
          Dispose ( n1 );
          Dispose ( n2 );
          ret = -4711L;
          del = TRUE;
          goto ende;
        }
      if ( crc_32 ( n1, h2.len_key ) != h2.crc_key )
        {
          ret = -4711L;
          del = TRUE;
          goto ende;
        }
      if ( Fread ( h, h2.len_val, n2 ) != h2.len_val )
        {
          Dispose ( n1 );
          Dispose ( n2 );
          ret = -4711L;
          del = TRUE;
          goto ende;
        }
      if ( crc_32 ( n2, h2.len_val ) != h2.crc_val )
        {
          del = TRUE;
          ret = -4711L;
          goto ende;
        }
      if ( SetConfig ( n1, n2, h2.len_val ) == FALSE )
        {
          Dispose ( n1 );
          Dispose ( n2 );
          del = TRUE;
          ret = -4711L;
          goto ende;
        }
      Dispose ( n1 );
      Dispose ( n2 );
    }

  Fclose ( h );
  if ( sysgem.spy_ini != NULL ) sysgem.spy_ini ();
  return ( h1.anz );

  ende:
  Fclose ( h );
  if ( del ) goto do_delete;
  if ( sysgem.spy_ini != NULL ) sysgem.spy_ini ();
  return ( ret );
}

/* ------------------------------------------------------------------- */

VOID SetIniDebug ( ZPROC proc )

{
  sysgem.spy_ini = proc;
}

/* ------------------------------------------------------------------- */
