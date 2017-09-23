/********************************************************/
/* Gestion des fichiers de configuration au format .INI */
/********************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "ini.h"

#define IGNORE_SPACES( c )  while ( ( *c == ' ' ) || ( *c == '\t' ) ) c++ 


typedef struct
{
  void *next ;
  char *name ;    /* Nom de la section ou de la cl‚                 */
  char *val ;     /* Valeur de la cl‚                               */
  char type ;     /* Section ('S'), Cl‚ ('C'), Propri‚taire ('P')   */
                  /* Ou (I)nvalide                                  */
}
INI_ITEM ;

typedef struct
{
  INI_ITEM *ItemList ;
  char     *FileName ;
  char     Busy ;
}
INI_FILE ;

#define NB_MAX_INI_FILES  3 /* Nomre max de fichiers INI accessibles simultanement */
INI_FILE  IniFile[NB_MAX_INI_FILES] ;

#ifdef MEMDEBUG
char *xstrdup(char *s)
{
  /* Remplace strdup pour l'utilisation de MEMDEBUG */
  char *dup ;

  dup = (char *) malloc( 1+strlen(s) ) ;
  if ( dup != NULL ) strcpy( dup, s ) ;

  return( dup ) ;
}
#else
#define xstrdup(s) strdup(s)
#endif

HINI GetIniHandle(void)
{
  HINI h_ini = -1 ;
  HINI index ;

  for ( index = 0; ( h_ini == -1 ) && (index < NB_MAX_INI_FILES); index++ )
    if ( !IniFile[index].Busy ) h_ini = index ;

  if ( h_ini != -1 ) IniFile[h_ini].Busy = 1 ;

  return( h_ini ) ;
}

int IsIniHandleValid(HINI h_ini)
{
  if ( ( h_ini < 0 ) || ( h_ini >= NB_MAX_INI_FILES ) || ( IniFile[h_ini].Busy == 0 ) )
    return( 0 ) ;
  else
    return( 1 ) ;
}

int LoadLine(char *line, HINI h_ini)
{
  INI_ITEM *item ;
  INI_ITEM *current_item ;
  int      ret = 0 ;
  char     *c ;

  IGNORE_SPACES( line ) ;

  item = (INI_ITEM *) calloc( 1, sizeof(INI_ITEM) ) ;
  if ( item == NULL ) return( -3 ) ;

  c = strchr( line, '\r' ) ;
  if ( c == NULL ) c = strchr( line, '\n' ) ;
  if ( c != NULL ) *c = 0 ;

  if ( *line == '[' )
  {
    /* Section */
    c = strchr( line, ']' ) ;
    if ( c != NULL )
    {
      *c = 0 ;
      line++ ;
      IGNORE_SPACES( line ) ;
      item->type = 'S' ;
      item->name = xstrdup( line ) ;
      if ( item->name == NULL ) ret = -3 ;
    }
  }
  else
  {
    /* Cl‚ */
    c  = strchr( line, '=' ) ;
    if ( c != NULL )
    {
      /* Oui ! */
      char *c1 ;

      c1 = c-1 ;
      if ( *c1 == ' ' )
      {
        while ( *c1 == ' ' ) c1-- ;
        *(1+c1) = 0 ;
      }
      *c++ = 0 ;
      item->type = 'C' ;
      item->name = xstrdup( line ) ;
      if ( item->name == NULL )
      {
        free( item ) ;
        ret = -3 ;
      }
      else
      {
        IGNORE_SPACES( c ) ;
        item->val = xstrdup( c ) ;
        if ( item->val == NULL )
        {
          free( item->name ) ;
          ret = -3 ;
        }
      }
    }
    else
    {
      /* On suppose que c'est une ligne propri‚taire … ne pas changer */
      /* On ne stocke pas les lignes vides */
      if ( ( line[0] != '\r' ) && ( line[0] != '\n' ) )
      {
        item->type = 'P' ;
        item->name = xstrdup( line ) ;
        if ( item->name == NULL )
        {
          free( item ) ;
          ret = -3 ;
        }
        else ret = 0 ;
      }
    }
  }

  if ( ret == 0 )
  {
    /* On insŠre cet item dans la liste */
    current_item = IniFile[h_ini].ItemList ;
    if ( current_item != NULL )
    {
      while ( current_item->next != NULL ) current_item = current_item->next ;

      current_item->next = item ;
    }
    else
      IniFile[h_ini].ItemList = item ;
  }
  else free( item ) ;

  return( ret < 0 ) ;
}

int LoadIniFile(FILE *stream, HINI h_ini)
{
  int  fini, err ;
  char buf[256] ;

  if ( !IsIniHandleValid( h_ini ) ) return( -1 ) ;

  fini = 0 ;
  err  = 1 ;
  do
  {
    if ( fgets( buf, 256, stream ) == NULL ) fini = 1 ;
    else                                     err  = LoadLine( buf, h_ini ) ;
  }
  while ( !fini && !err ) ;

  return( err ) ;
}

HINI OpenIni(char *file)
{
  FILE *stream ;
  HINI h_ini = -1 ;

  h_ini  = GetIniHandle() ;
  if ( h_ini < 0 ) return( -1 ) ;

  stream = fopen( file, "rb" ) ;
  if ( stream != NULL )
  {
    if ( LoadIniFile( stream, h_ini ) != 0 )
    {
      CloseIni( h_ini ) ;
      h_ini = - 1 ;
    }
    fclose( stream ) ;
  }
  else CloseIni( h_ini ) ;

  if ( h_ini != -1 ) 
  {
    IniFile[h_ini].FileName = xstrdup( file ) ;
    if ( IniFile[h_ini].FileName == NULL )
    {
      CloseIni( h_ini ) ;
      h_ini = -1 ;
    }
  }

  return( h_ini ) ;
}

void FreeIniItems(HINI h_ini)
{
  INI_ITEM *item ;
  void     *next ;

  if ( !IsIniHandleValid( h_ini ) ) return ;

  item = IniFile[h_ini].ItemList ;
  while ( item != NULL )
  {
    if ( item->val != NULL ) free( item->val ) ;
    if ( item->name != NULL ) free( item->name ) ;
    next = item->next ;
    free( item ) ;
    item = next ;
  }
  IniFile[h_ini].ItemList = NULL ;
}

long CloseIni(HINI h_ini)
{
  if ( !IsIniHandleValid( h_ini ) ) return( -1 ) ;

  FreeIniItems( h_ini ) ;
  free( IniFile[h_ini].FileName ) ;
  memset( &IniFile[h_ini], 0, sizeof(INI_FILE) ) ;

  return( 0 ) ;
}

int SaveIni(HINI h_ini, char *new_name)
{
  INI_ITEM *item ;
  FILE     *stream ;
  char     buf[256] ;

  if ( !IsIniHandleValid( h_ini ) ) return( -1 ) ;
  item = IniFile[h_ini].ItemList ;
  if ( new_name == NULL ) stream = fopen( IniFile[h_ini].FileName, "wb+" ) ;
  else                    stream = fopen( new_name, "wb+" ) ;
  if ( stream == NULL ) return( -1 ) ;

  while ( item != NULL )
  {
    if ( item->type == 'S' )
      sprintf( buf, "[%s]\r\n", item->name ) ;
    else if ( item->type == 'C' )
      sprintf( buf, "%s = %s\r\n", item->name, item->val ) ;
    else if ( item->type == 'P' )
      sprintf( buf, "%s\r\n", item->name ) ;
    if ( item->type != 'I' ) fwrite( buf, strlen(buf), 1, stream ) ;
    item = (INI_ITEM *) item->next ;
  }

  return( fclose( stream ) ) ;
}

long SaveAndCloseIni(HINI h_ini, char *new_name)
{
  long ret ;

  ret = SaveIni( h_ini, new_name ) ;
  if ( ret == 0 ) ret = CloseIni( h_ini ) ;
  else            CloseIni( h_ini ) ;

  return( ret ) ;
}

INI_ITEM *GetItem(HINI h_ini, char *section, char *key)
{
  INI_ITEM *item ;
  int      trouve = 0 ;

  if ( !IsIniHandleValid( h_ini ) ) return( NULL ) ;

  item = IniFile[h_ini].ItemList ;
  /* Recherche la section */
  while ( !trouve && ( item != NULL ) )
  {
    if ( ( item->type == 'S' ) && ( strcmpi( item->name, section ) == 0 ) )
      trouve = 1 ;
    else
      item = (INI_ITEM *) item->next ;
  }

  /* Recherche de la cl‚ dans cette section */
  if ( ( key != NULL ) && trouve )
  {
    INI_ITEM *item_section ;

    item_section = item ;
    trouve       = 0 ;
    item         = (INI_ITEM *) item->next ;
    while ( !trouve && item && ( ( item->type == 'C' ) || ( item->type == 'P' ) ) )
    {
      if ( strcmpi( item->name, key ) == 0 ) trouve = 1 ;
      else                                   item   = (INI_ITEM *) item->next ;
    }
    if ( !trouve ) item = item_section ;
  }

  return( item ) ;
}

long GetIniKey(HINI h_ini, char *section, char *key, char *val_key)
{
  INI_ITEM *item ;

  item = GetItem( h_ini, section, key ) ;

  if ( ( item != NULL ) && ( item->type == 'C' ) )
    strcpy( val_key, item->val ) ;

  return( ( item != NULL ) && ( item->type == 'C' ) ) ;
}

INI_ITEM *InsertKey(INI_ITEM *item_section, char *key)
{
  INI_ITEM *item_key, *item_tmp ;

  item_key = (INI_ITEM *) calloc( 1, sizeof(INI_ITEM) ) ;
  if ( item_key != NULL )
  {
    item_key->type = 'C' ;
    item_key->name = xstrdup( key ) ;
    if ( item_key->name == NULL )
    {
      free( item_key ) ;
      item_key = NULL ;
    }
    /* Chainage */
    item_tmp           = item_section->next ;
    item_section->next = item_key ;
    item_key->next     = item_tmp ;
  }

  return( item_key ) ;
}

INI_ITEM *InsertSectionAndKey(HINI h_ini, char *section, char *key)
{
  INI_ITEM *item_section, *item_key ;

  if ( !IsIniHandleValid( h_ini ) ) return( NULL ) ;

  item_section = (INI_ITEM *) calloc( 1, sizeof(INI_ITEM) ) ;
  if ( item_section != NULL )
  {
    item_section->type = 'S' ;
    item_section->name = xstrdup( section ) ;
    if ( item_section->name == NULL )
    {
      free( item_section ) ;
      item_section = NULL ;
    }
    /* Chainage */
    item_section->next      = IniFile[h_ini].ItemList ;
    IniFile[h_ini].ItemList = item_section ;
  }

  item_key = InsertKey( item_section, key ) ;

  return( item_key ) ;
}

long SetIniKey(HINI h_ini, char *section, char *key, char *val_key)
{
  INI_ITEM *item ;
  long     succes = 1 ;

  item = GetItem( h_ini, section, key ) ;

  if ( item == NULL ) item = InsertSectionAndKey( h_ini, section, key ) ;
  else if ( item->type == 'S' )
  {
    /* Seule la section existe */
    /* Il faut cr‚er la cl‚    */
    item = InsertKey( item, key ) ;
  }

  if ( item != NULL )
  {
    if ( item->val != NULL ) free( item->val ) ;
    item->val = xstrdup( val_key ) ;
    if ( item->val == NULL ) succes = 0 ;
  }
  else succes = 0 ;

  return( succes ) ;
}

long GetOrSetIniKey(HINI h_ini, char *section, char *key, char *val)
{
  long ret = 0 ;

  if ( GetIniKey( h_ini, section, key, val ) == 0 )
  {
    SetIniKey( h_ini, section, key, val ) ;
    ret = 1 ;
  }

  return( ret ) ;
}
