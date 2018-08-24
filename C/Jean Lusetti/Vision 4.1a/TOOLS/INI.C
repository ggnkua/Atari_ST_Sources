/********************************************************/
/* Gestion des fichiers de configuration au format .INI */
/********************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "ini.h"
#include "xalloc.h"

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

#define NB_MAX_INI_FILES  3 /* Nombre max de fichiers INI accessibles simultanement */
INI_FILE  IniFile[NB_MAX_INI_FILES] ;

void remove_spaces(char* string)
{
  char* src = string ;
  char* dest = string ;

  while ( *src )
  {
    if ( ( *src != ' ' ) && ( *src != '\t' ) )
      *dest++ = *src ;
    src++ ;
  }
  *dest = 0 ;
}

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

  item = (INI_ITEM *) Xcalloc( 1, sizeof(INI_ITEM) ) ;
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
      item->name = Xstrdup( line ) ;
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
      item->name = Xstrdup( line ) ;
      if ( item->name == NULL )
      {
        Xfree( item ) ;
        ret = -3 ;
      }
      else
      {
        IGNORE_SPACES( c ) ;
        item->val = Xstrdup( c ) ;
        if ( item->val == NULL )
        {
          Xfree( item->name ) ;
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
        item->name = Xstrdup( line ) ;
        if ( item->name == NULL )
        {
          Xfree( item ) ;
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
  else Xfree( item ) ;

  return( ret < 0 ) ;
}

int LoadIniFile(FILE *stream, HINI h_ini)
{
  int  fini, err ;
  char buf[256] ;

  if ( !IsIniHandleValid( h_ini ) ) return( -1 ) ;

  fini = 0 ;
  err  = 0 ;
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

  if ( h_ini != -1 ) 
  {
    IniFile[h_ini].FileName = Xstrdup( file ) ;
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
    if ( item->val != NULL ) Xfree( item->val ) ;
    if ( item->name != NULL ) Xfree( item->name ) ;
    next = item->next ;
    Xfree( item ) ;
    item = next ;
  }
  IniFile[h_ini].ItemList = NULL ;
}

long CloseIni(HINI h_ini)
{
  if ( ( h_ini >= 0 ) && ( h_ini < NB_MAX_INI_FILES ) )
  {
    FreeIniItems( h_ini ) ;
    Xfree( IniFile[h_ini].FileName ) ;
    memset( &IniFile[h_ini], 0, sizeof(INI_FILE) ) ;
    return 0 ;
  }
  
  return -1 ;
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

/* To be used just to retrieve a single or couple of values */
/* As file will be parsed every time */
long GetIniKeyFromFile(char *file, char *section, char *key, char *val_key)
{
  FILE* stream ;
  int   found = 0 ;

  stream = fopen( file, "rb" ) ;
  if ( stream != NULL )
  {
    char *line, buf[256] ;
    int  section_match = 0 ;
    int  end_of_stream = 0 ;

    line = buf ;
    while (!end_of_stream && !found)
    {
      if ( fgets( line, (int)sizeof(buf), stream ) == NULL ) end_of_stream = 1 ;
      else
      {
        char* c ;

        remove_spaces(line) ;
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
            if ( strcmpi(1+line, section) == 0 ) section_match = 1 ;
            else
            {
              if ( section_match == 1 ) end_of_stream = 1 ; /* We won't find it as section is finished */
              section_match = 0 ;
            }
          }
        }
        else if ( section_match )
        {
          c = strchr( line, '=' ) ;
          if ( c )
          {
            *c++ = 0 ;
            if ( strcmpi(line, key) == 0 )
            {
              strcpy(val_key, c) ;
              found = 1 ;
            }
          }
        }
      }
    }
    fclose(stream) ;
  }

  return found ;
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

  item_key = (INI_ITEM *) Xcalloc( 1, sizeof(INI_ITEM) ) ;
  if ( item_key != NULL )
  {
    item_key->type = 'C' ;
    item_key->name = Xstrdup( key ) ;
    if ( item_key->name == NULL )
    {
      Xfree( item_key ) ;
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

  item_section = (INI_ITEM *) Xcalloc( 1, sizeof(INI_ITEM) ) ;
  if ( item_section != NULL )
  {
    item_section->type = 'S' ;
    item_section->name = Xstrdup( section ) ;
    if ( item_section->name == NULL )
    {
      Xfree( item_section ) ;
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
    if ( item->val != NULL ) Xfree( item->val ) ;
    item->val = Xstrdup( val_key ) ;
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
