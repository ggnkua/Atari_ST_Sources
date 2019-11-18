/***********************************************************/
/* INI file management                                     */
/* Optimized for read access                               */
/* And memory usage (limted number of dynamic allocations) */
/* Typically memory consumption is INI text file in memory */
/* Plus a hundred bytes plus FILE* stuff                   */
/***********************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "ini.h"

#ifdef _WIN32
#define Xalloc   malloc
#define Xcalloc  calloc
#define Xrealloc realloc
#define Xfree    free
#define Xstrdup  _strdup
#define strcmpi  _strcmpi
#define unlink   _unlink
#else
#include "xalloc.h"
#include "logging.h"
#endif

typedef struct _SECTION
{
  char* ptr ;    /* Pointer to section right after '[' character (NOT NULL terminated) */
  short nbytes ; /* Number of characters for this section                              */
}
SECTION, *PSECTION ;

#define NSECTION_PACK 40
#define BUFFER_MIN   (2*1024)
#define INI_MAGIC    '_INI'
typedef struct _INI_FILE
{
  unsigned long  Magic ;
  SECTION*       Sections ;
  unsigned short nSections ;        
  unsigned short nMaxSections ;        
  char*          FileName ;
  char*          Buffer ;
  size_t         BufferLength ;
  size_t         BufferMaxLength ;
}
INI_FILE, *PINI_FILE ;

/*#define DEBUG_INI*/
#ifdef DEBUG_INI
/* Define DEBUG_INI to have extended checks during operations    */
/* This should be not necessary but will help in case of crashes */
/* Don't define this unless you have good reasons as this will   */
/* Slow down all processing                                      */
#define SYNC_CHAR ((char)0xdd)
static int dbg_check_ini_buffer(INI_FILE* ini_file)
{
  char* pt ;
  int   status = 1 ;

  for ( pt = ini_file->Buffer; (status == 1) && (pt < ini_file->Buffer + ini_file->BufferLength); pt++ )
    switch (*pt)
    {
      case SYNC_CHAR:
      case 0x00:       status = *pt ;
                       break ;
      case '\r':       if ( *(pt + 1) != '\n' )
                         status = *pt ;
                       break ;
      case '\n':       if ( *(pt - 1) != '\r' )
                         status = *pt ;
                       break ;
      default:         if ( *pt == (char)0xfe ) 
                         status = *pt ;
                       break ;
    }

  /* Our INI buffer shall end up with \0 to enable safe use of str... functions */
  if ( ini_file->Buffer[ini_file->BufferMaxLength] )
	  status = 0xFF ;

  return status ;
}
#define dbg_set_check(addr,size) memset(addr, SYNC_CHAR, size)
#else
#define dbg_check_ini_buffer(ini)
#define dbg_set_check(addr,fsize)
#endif

static char* ignore_spaces(char* c)
{
  while ( ( *c == ' ' ) || ( *c == '\t' ) ) c++ ;

  return c ;
}

static INI_FILE* GetIniHandle(char* filename)
{
  INI_FILE* ini_file ;

  ini_file = (INI_FILE*) Xcalloc( 1, sizeof(INI_FILE) ) ;
  if ( ini_file )
  {
    ini_file->Magic = INI_MAGIC ;
    /* Allocate some room for future sections */
    ini_file->nMaxSections = NSECTION_PACK ;
    ini_file->Sections     = (SECTION*) Xcalloc( ini_file->nMaxSections, sizeof(SECTION) ) ;
    if ( ini_file->Sections )
    {
      ini_file->FileName = Xstrdup( filename ) ;
      if ( ini_file->FileName == NULL )
      {
        Xfree( ini_file->Sections ) ;
        Xfree( ini_file ) ;
        ini_file = NULL ;
     }
    }
    else
    {
      Xfree( ini_file ) ;
      ini_file = NULL ;
    }
  }

  return ini_file ;
}

static int LoadIniIntoMemory(INI_FILE* ini_file)
{
  FILE*  stream ;
  size_t fsize ;
  int    ret = -1 ; /* Only reason to fail is no more memory here or read error but if file does not exist, that's fair */

  stream = fopen( ini_file->FileName, "rb" ) ;
  if ( stream )
  {
    fseek( stream, 0, SEEK_END ) ;
    fsize = ftell( stream ) ;
    fseek( stream, 0, SEEK_SET ) ;
    ini_file->Buffer = (char*) Xalloc( 1+fsize ) ;
    if ( ini_file->Buffer )
    {
      ini_file->Buffer[fsize]   = 0 ; /* Make sure we end up with a \0 */
      ini_file->BufferLength    = fsize ;
      ini_file->BufferMaxLength = fsize ;
      if ( fsize )
      {
        if ( fread(ini_file->Buffer, fsize, 1, stream) == 1 ) ret = 0 ;
        else
        {
          Xfree( ini_file->Buffer ) ;
          ini_file->Buffer = NULL ;
        }
      }
	    else ret = 0 ; /* File is empty */
    }
    fclose( stream ) ;
  }
  else
  {
    /* File does not exist, let's allocate some room as we are probably going to build it from scratch */
    fsize = BUFFER_MIN ;
    ini_file->Buffer = (char*) Xalloc( 1+fsize ) ;
    if ( ini_file->Buffer )
    {
      dbg_set_check( ini_file->Buffer, fsize ) ;
      ini_file->Buffer[fsize]   = 0 ; /* Make sure we end up with a \0 */
      ini_file->BufferMaxLength = fsize ;
      ret = 0 ;
    }
  }

  return ret ;
}

static SECTION* GetNewSection(INI_FILE* ini_file)
{
  SECTION* section = NULL ;

  if ( ini_file->nSections < ini_file->nMaxSections ) section = &ini_file->Sections[ini_file->nSections++] ;
  else
  {
    /* We have to re-allocate the section array */
    SECTION*       nsection_array ;
    unsigned short nsections = ini_file->nMaxSections + NSECTION_PACK ;

    nsection_array = (SECTION*) Xrealloc( ini_file->Sections, nsections*sizeof(SECTION) ) ;
    if ( nsection_array )
    {
      ini_file->Sections     = nsection_array ;
      ini_file->nMaxSections = nsections ;
      section                = &ini_file->Sections[ini_file->nSections++] ;
    }
  }

  return section ;
}

static int LoadIniSections(INI_FILE* ini_file)
{
  SECTION* section ;
  char*    line = ini_file->Buffer ;
  char*    cr ;
  char*    last_c = ini_file->Buffer + ini_file->BufferLength - 1 - 3 ; /* Last character in buffer is \0 + '[x]' string */
  char*    cs ;
  int      ret = 0 ;

  /* Our buffer is a text file with \r and/or \n line separator(s) with a \0 terminaison */
  /* So we can use str... functions                                                      */
  while ( (ret == 0) && (line < last_c) )
  {
    /* Temporarily change \n with \0 to isolate a line */
    cr = strchr( line, '\n' ) ;
    if ( cr == NULL ) break ; /* Last line */
    line = ignore_spaces( line ) ;
    if ( line[0] != ';' && (cr > line+2) ) /* Comment or empty line */
    {
      *cr = 0 ;
      cs = strchr( line, '[' ) ;
      if ( cs )
      {
        /* New section begins */
        section = GetNewSection( ini_file ) ;
        if ( section )
        {
          section->ptr = 1+cs ;
          cs = strchr( section->ptr, ']' ) ;
          if ( cs )
          {
            size_t nbytes = 1 + cs - section->ptr ;

            if ( nbytes < 256 ) section->nbytes = (short)(cs - section->ptr) ;
            else                ini_file->nSections-- ; /* Would be weird to have a section name longer than 256 characters */
          }
          else ini_file->nSections-- ; /* Section end marker not found */
        }
        else ret = -1 ; /* Out of memory */
      }
      *cr = '\n' ;
    }
    line = 1+cr ;
  }

  return ret ;
}

long CloseIni(HINI h_ini)
{
  INI_FILE* ini_file = (INI_FILE*) h_ini ;
  long      ret = -1 ;

  if ( ini_file && (ini_file->Magic == INI_MAGIC) )
  {
    if ( ini_file->Buffer ) Xfree( ini_file->Buffer ) ;
    if ( ini_file->FileName ) Xfree( ini_file->FileName ) ;
    if ( ini_file->Sections ) Xfree( ini_file->Sections ) ;
    Xfree( ini_file ) ;
    ret = 0 ;
  }
  
  return ret ;
}

HINI OpenIni(char* file)
{
  INI_FILE* ini_file = GetIniHandle( file ) ;

  if ( ini_file )
  {
    if ( LoadIniIntoMemory( ini_file ) || LoadIniSections( ini_file ) )
    {
      CloseIni( ini_file ) ;
      ini_file = NULL ;
    }
  }

  return (HINI) ini_file ;
}

static int SaveIni(INI_FILE* ini_file, char *new_name)
{
  FILE*  stream ;
  size_t len ;
  int    err = 0 ;

  if ( new_name == NULL ) stream = fopen( ini_file->FileName, "wb+" ) ;
  else                    stream = fopen( new_name, "wb+" ) ;
  if ( stream == NULL ) return -1 ;

  /* Don't include possible tailing \0 */
  len = ini_file->BufferLength ;
  if ( len > 0 )
  {
    while ( ini_file->Buffer[len - 1] == 0 ) len-- ;
    err = ( fwrite( ini_file->Buffer, len, 1, stream ) != 1 ) ;
  }
  if ( !err ) err = fclose( stream ) ;
  else        fclose( stream ) ;

  return err ;
}

long SaveAndCloseIni(HINI h_ini, char *new_name)
{
  INI_FILE* ini_file = (INI_FILE*) h_ini ;
  long      ret = -1 ;

  if ( ini_file && (ini_file->Magic == INI_MAGIC) )
  {
    if ( new_name ) ret = SaveIni( ini_file, new_name ) ;
    else            ret = SaveIni( ini_file, ini_file->FileName ) ;
    if ( ret == 0 ) ret = CloseIni( h_ini ) ;
    else            CloseIni( h_ini ) ;
  }

  return ret ;
}

static SECTION* GetSection(INI_FILE* ini_file, char* section_name)
{
  SECTION* section ;
  SECTION* over_section = &ini_file->Sections[ini_file->nSections] ;
  size_t   len = strlen( section_name ) ;

  /* Locate the section */
  for ( section = ini_file->Sections; section < over_section; section++ )
    if ( (memcmp( section->ptr, section_name, len) == 0) && (section->ptr[len]) == ']') break ;

  return( section < over_section ? section : NULL ) ;
}

static char* GetItem(INI_FILE* ini_file, char* section_name, char* key)
{
  SECTION* section ;
  char*    val_key = NULL ;
  char*    cr ;
  char*    last_c = ini_file->Buffer + ini_file->BufferLength - 1 - 3 ; /* Last character in buffer is \0 + '[x]' string */
  char*    first_section_entry = NULL ;

  /* Locate the section */
  section = GetSection( ini_file, section_name ) ;
  if ( section )
  {
    /* Section name found, let's point to the first entry */
    first_section_entry = strchr( section->ptr, '\n' ) ;
    if ( first_section_entry )
    {
      first_section_entry++ ;
      first_section_entry = ignore_spaces( first_section_entry ) ;
    }
  }

  if ( first_section_entry )
  {
    /* Look for key in that section */
    char* line, *equal ;
    char  save_cr ;

    line = first_section_entry ;
    while ( (val_key == NULL) && (line < last_c) )
    {
      cr = strchr( line, '\r' ) ;
      if ( cr ) cr = strchr( line, '\n' ) ;
      if ( cr )
      {
        save_cr = *cr ;
        *cr     = 0 ;
      }
      line = ignore_spaces( line ) ;
      if ( line[0] != ';' ) /* Comment */
      {
        equal = strchr( line, '=' ) ;
        if ( equal )
        {
          char save ;

          val_key = 1 + equal ;
          while ( (*(equal-1) == ' ') || ((*(equal-1) == '\t')) ) equal-- ;
          save   = *equal ;
          *equal = 0 ;
          if ( strcmpi( line, key ) == 0 ) val_key = ignore_spaces( val_key ) ;
          else                             val_key = NULL ;
          *equal = save ;
        }
      }
      if ( cr )
      {
        *cr = save_cr ;
        line = 1 + cr ;
      }
      else line = last_c ;
    }
  }

  return val_key ;
}

long GetIniKey(HINI h_ini, char *section_name, char *key_name, char *key_value)
{
  INI_FILE* ini_file = (INI_FILE*) h_ini ;
  char*     value ;
 
  if ( !ini_file || (ini_file->Magic != INI_MAGIC) ) return 0 ;
  value = GetItem( ini_file, section_name, key_name ) ;

  if ( value )
  {
    /* As value points to raw text file, line end up with \n, not \0 */
    char* last_c = ini_file->Buffer + ini_file->BufferLength - 1 ; /* Last character in buffer is \0 */
    char* s      = value ;
    char* d      = key_value ;

    while ( (*s == ' ') && (s < last_c) ) s++ ; /* Ignore spaces after '=' */
    while ( (*s != '\r') && (*s != '\t') && (*s != '\n') && (s < last_c) ) *d++ = *s++ ;
    *d = 0 ;
  }

  return( value != NULL ) ;
}

static int InsertKey(INI_FILE* ini_file, SECTION* section, char *key, char* val_key)
{
  char   tmp[BUFFER_MIN] ;
  char*  ini_buffer = ini_file->Buffer ;
  char*  ipos       = ini_file->Buffer + ini_file->BufferLength ; /* First available character in buffer */
  size_t len        = sprintf( tmp, "%s = %s\r\n", key, val_key ) ;
  size_t  n1 ;
  int    alloc_done = 0 ;
  int    ret        = 0 ;

  if ( section < &ini_file->Sections[ini_file->nSections-1] )
  {
    ipos = section[1].ptr-1 ; /* Back to '[' */
    while ( (ipos > ini_buffer) && ((*(ipos - 1) == ' ') || (*(ipos - 1) == '\t')) ) ipos-- ;
    if (*(ipos - 1) == '\n') ipos-- ;
    if (*(ipos - 1) == '\r') ipos-- ; /* Leave 1 line before next section */
  }
  n1 = 1+(size_t)(ipos - ini_file->Buffer) ;

  if ( ini_file->BufferLength + len >= ini_file->BufferMaxLength )
  {
    /* Need more room */
    size_t size = ini_file->BufferMaxLength + BUFFER_MIN ;

    ini_buffer = Xrealloc( ini_file->Buffer, 1+size ) ;
    if ( ini_buffer )
    {
      dbg_set_check( ini_buffer + ini_file->BufferMaxLength, size - ini_file->BufferMaxLength ) ;
      ini_buffer[size]          = 0 ;
      ini_file->BufferMaxLength = size ;
      alloc_done                = 1 ;
    }
  }
  if ( ini_buffer )
  {
    if ( 1+ini_file->BufferLength > n1 )
      memmove( ini_buffer + n1 + len - 1, ini_buffer+n1-1, 1+ini_file->BufferLength-n1 ) ;
    memcpy( ini_buffer+n1-1, tmp, len ) ;
    if ( alloc_done ) ini_file->Buffer = ini_buffer ;
    ini_file->BufferLength += len ;
    ini_file->nSections     = 0 ;
    LoadIniSections( ini_file ) ; /* Reload sections pointers */
  }
  else ret = -1 ;

  dbg_check_ini_buffer( ini_file ) ;

  return ret ;
}

static int InsertSectionAndKey(INI_FILE* ini_file, char *section_name, char *key_name, char* val_key)
{
  char   tmp[BUFFER_MIN] ;
  char*  ini_buffer = ini_file->Buffer ;
  size_t len ;
  int    alloc_done = 0 ;
  int    ret        = 0 ;

  if ( ini_file->nSections ) len = sprintf( tmp, "\r\n[%s]\r\n", section_name ) ;
  else                       len = sprintf( tmp, "[%s]\r\n", section_name ) ;

  /* Insert section at the end */
  if ( ini_file->BufferLength + len >= ini_file->BufferMaxLength )
  {
    size_t size = ini_file->BufferMaxLength + BUFFER_MIN ;

    ini_buffer = Xrealloc( ini_file->Buffer, 1+size ) ;
    if ( ini_buffer )
    {
      dbg_set_check(ini_buffer + ini_file->BufferMaxLength, size - ini_file->BufferMaxLength) ;
	  ini_buffer[size]          = 0 ;
	  ini_file->BufferMaxLength = size ;
	  alloc_done                = 1 ;
	}
  }
  if ( ini_buffer )
  {
    if (ini_file->BufferLength > 0 ) memcpy( ini_buffer+ini_file->BufferLength, tmp, len ) ;
    else                             memcpy( ini_buffer, tmp, len ) ;
    if ( alloc_done ) ini_file->Buffer = ini_buffer ;
    ini_file->BufferLength += len ;
    ini_file->nSections     = 0 ;
    LoadIniSections( ini_file ) ; /* Reload sections pointers */
  }
  else ret = -1 ;

  if ( ret == 0 )
    ret = InsertKey( ini_file, &ini_file->Sections[ini_file->nSections-1], key_name, val_key ) ;

  dbg_check_ini_buffer( ini_file ) ;

  return ret ;
}

static int InsertKeyValue(INI_FILE* ini_file, char* ptr_value, char* key_value )
{
  char*  c ;
  size_t len_to_insert = strlen( key_value ) ;
  size_t len_actual, len ;
  int    ret = 0 ;

  c = strchr( ptr_value, '\n' ) ;
  if ( c == NULL ) c = strchr( ptr_value, '\r' ) ;
  if ( c == NULL ) len_actual = strlen( ptr_value ) ;
  else
  {
/*    while ( (*c == '\r') || (*c == '\n') || (*c == '\t') || (*c == ' ') ) c-- ;*/
    while ( (*c == '\r') || (*c == '\n') ) c-- ;
    if ( *c == '=' ) len_actual = 0 ;
    else
    {
      char save = *++c ;

      *c         = 0 ;
      len_actual = strlen( ptr_value ) ;
      *c         = save ;
    }
  }

  if ( len_to_insert == len_actual ) memcpy( ptr_value, key_value, len_to_insert ) ; /* Lucky, just overwrite existing data */
  else if ( len_to_insert < len_actual )
  {
    /* Need to move, enough room */
    len = ini_file->BufferLength - (size_t)(ptr_value + len_actual - ini_file->Buffer) ;
    memmove( ptr_value+len_to_insert, ptr_value+len_actual, len ) ;
    memcpy( ptr_value, key_value, len_to_insert ) ;
    ini_file->BufferLength -= len_actual - len_to_insert ;
  }
  else
  {
    /* Need more room */
    char*  ini_buffer = ini_file->Buffer ;
    int    alloc_done = 0 ;

    if ( ini_file->BufferLength + len_to_insert - len_actual >= ini_file->BufferMaxLength )
    {
      /* Have to allocate */
      size_t size = ini_file->BufferMaxLength + BUFFER_MIN ;

      ini_buffer = Xrealloc( ini_file->Buffer, 1 + size ) ;
      if ( ini_buffer )
      {
        dbg_set_check(ini_buffer + ini_file->BufferMaxLength, size - ini_file->BufferMaxLength) ;
        ini_buffer[size]          = 0 ;
        ini_file->BufferMaxLength = size ;
        alloc_done                = 1 ;
        ptr_value = ini_buffer + (size_t)(ptr_value - ini_file->Buffer) ;
      }
	  else ret = -1 ;
    }
    if ( ini_buffer )
    {
      /* We have enough room in our buffer */
      len = ini_file->BufferLength - (size_t)(ptr_value + len_actual - ini_buffer) ;
      memmove( ptr_value + len_to_insert, ptr_value + len_actual, len ) ;
      memcpy( ptr_value, key_value, len_to_insert ) ;
      ini_file->BufferLength += len_to_insert-len_actual ;
      if ( alloc_done ) ini_file->Buffer = ini_buffer ;
    }
  }

  if ( (ret == 0) && (len_to_insert != len_actual) )
  {
    ini_file->nSections = 0 ;
    LoadIniSections( ini_file ) ; /* Reload sections pointers */
  }

  dbg_check_ini_buffer( ini_file ) ;

  return ret ;
}

long SetIniKey(HINI h_ini, char *section_name, char *key_name, char *key_value)
{
  INI_FILE* ini_file = (INI_FILE*) h_ini ;
  SECTION*  section ;
  int       ret = 0 ;

  if ( !ini_file || (ini_file->Magic != INI_MAGIC) ) return 0 ;
  section = GetSection( ini_file, section_name ) ;
  if ( section == NULL )
    ret = InsertSectionAndKey( ini_file, section_name, key_name, key_value ) ;
  else
  {
    char* value = GetItem( ini_file, section_name, key_name ) ;

    if ( value ) ret = InsertKeyValue( ini_file, value, key_value ) ;
    else         ret = InsertKey( ini_file, section, key_name, key_value ) ;
  }

  return( ret == 0 ) ;
}

long GetOrSetIniKey(HINI h_ini, char *section_name, char *key_name, char *key_value)
{
  INI_FILE* ini_file = (INI_FILE*) h_ini ;
  long      ret = 0 ;

  if ( !ini_file || (ini_file->Magic != INI_MAGIC) ) return ret ;
  if ( GetIniKey( h_ini, section_name, key_name, key_value ) == 0 )
  {
    SetIniKey( h_ini, section_name, key_name, key_value ) ;
    ret = 1 ;
  }

  return ret ;
}

void static remove_spaces(char* string)
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

/* To be used just to retrieve a single or couple of values */
/* As file will be parsed every time */
long GetIniKeyFromFile(char *file, char *section, char *key, char *val_key)
{
  FILE* stream ;
  int   found = 0 ;

  stream = fopen( file, "rb" ) ;
  if ( stream != NULL )
  {
    char* line, buf[256] ;
    int   section_match = 0 ;
    int   end_of_stream = 0 ;

    line = buf ;
    while ( !end_of_stream && !found )
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
    fclose( stream ) ;
  }

  return found ;
}

int IniTest(int nsections, int nkeys_start, int nkeys_add)
{
  HINI hini;
  char ini_name[] = "test.ini" ;
  char section_name[16] ;
  char key_name[16] ;
  char buffer[256] ;
  char buffer2[256] ;
  int  ntestpass = 0 ;
  int  i, j ;
  int  nkeys = (nkeys_start > 0) ? nkeys_start:1;
  int  nkeystotal = (nkeys_add >= 0) ? nkeys + nkeys_add : nkeys + 5;

  if ( nsections < 0 ) nsections = 120 ;

  unlink( ini_name ) ;
  ini_name[0] = 'x' ;
  unlink( ini_name ) ;
  ini_name[0] = 't' ;
  /* Test 1: Open non existing INI file to create it */
  ntestpass++ ;
  hini = OpenIni( ini_name ) ;
  if ( !hini ) return ntestpass ;

  /* Test 2: Create sections/keys */
  printf("Test %d passed\r\n", ntestpass++) ;
  for ( i = 0; i < nsections; i++ )
  {
    sprintf( section_name, "SectionName%d", i ) ;
    for ( j = 0; j < nkeys; j++ )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "KeyVal%02d_%02d", i, j) ;
      GetOrSetIniKey( hini, section_name, key_name, buffer ) ;
    }
  }

  /* Test 3: Reload sections/keys from memory */
  printf("Test %d passed\r\n", ntestpass++) ;
  for ( i = nsections - 1; i >= 0; i-- )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = 0; j < nkeys; j++ )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "KeyVal%02d_%02d", i, j) ;
      if ( GetIniKey( hini, section_name, key_name, buffer2 ) == 1 )
      {
        if ( strcmp( buffer, buffer2 ) != 0 ) 
          return ntestpass ;
      }
      else
        return ntestpass ;
    }
  }

  /* Test 4: Save file */
  printf("Test %d passed\r\n", ntestpass++) ;
  if ( SaveAndCloseIni( hini, NULL ) != 0 ) return ntestpass ;

  /* Test 5: Open existing INI file & reload sections/keys */
  printf("Test %d passed\r\n", ntestpass++) ;
  hini = OpenIni(ini_name) ;
  if ( !hini ) return ntestpass ;
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for (j = nkeys-1; j >= 0; j--)
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "KeyVal%02d_%02d", i, j) ;
      if ( GetIniKey( hini, section_name, key_name, buffer2 ) == 1 )
      {
        if (strcmp(buffer, buffer2) != 0)
          return ntestpass ;
      }
      else
        return ntestpass ;
    }
  }

  /* Test 6: Add more keys to sections */
  printf("Test %d passed\r\n", ntestpass++) ;
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = nkeys; j < nkeystotal; j++ )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "KeyVal%02d_%02d", i, j) ;
      SetIniKey( hini, section_name, key_name, buffer ) ;
    }
  }
  /* And check */
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = nkeystotal-1; j >= 0; j-- )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "KeyVal%02d_%02d", i, j) ;
      if ( GetIniKey( hini, section_name, key_name, buffer2 ) == 1 )
      {
        if ( strcmp( buffer, buffer2 ) != 0 )
          return ntestpass;
      }
      else
        return ntestpass;
    }
  }

  /* Test 7: Modify existing keys (same storage) */
  printf("Test %d passed\r\n", ntestpass++) ;
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = 0; j < nkeystotal; j++ )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "Sec%02d_Key%02d", i, j) ;
      SetIniKey( hini, section_name, key_name, buffer ) ;
    }
  }

  /* Check modifications */
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = nkeystotal-1; j >= 0; j-- )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "Sec%02d_Key%02d", i, j) ;
      if ( GetIniKey( hini, section_name, key_name, buffer2 ) == 1 )
      {
        if ( strcmp( buffer, buffer2 ) != 0 )
          return ntestpass ;
      }
      else
        return ntestpass ;
    }
  }

  /* Test 8: Modify existing keys (less storage) */
  printf("Test %d passed\r\n", ntestpass++) ;
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = 0; j < nkeystotal; j++ )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "KV%02d_%02d", i, j) ;
      SetIniKey( hini, section_name, key_name, buffer ) ;
    }
  }

  /* Check modifications */
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = nkeystotal-1; j >= 0; j-- )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "KV%02d_%02d", i, j) ;
      if ( GetIniKey( hini, section_name, key_name, buffer2 ) == 1 )
      {
        if ( strcmp( buffer, buffer2 ) != 0 )
          return ntestpass ;
      }
      else
        return ntestpass ;
    }
  }

  /* Test 9: Modify existing keys (more storage) */
  printf("Test %d passed\r\n", ntestpass++) ;
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = 0; j < nkeystotal; j++ )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "More data for KeyVal%02d_%02d", i, j) ;
      SetIniKey( hini, section_name, key_name, buffer ) ;
    }
  }

	/* Check modifications */
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = nkeystotal-1; j >= 0; j-- )
    {
      sprintf(key_name, "KeyName%d", j) ;
      sprintf(buffer, "More data for KeyVal%02d_%02d", i, j) ;
      if ( GetIniKey( hini, section_name, key_name, buffer2 ) == 1 )
      {
        if ( strcmp( buffer, buffer2 ) != 0 )
          return ntestpass ;
      }
      else
        return ntestpass ;
    }
  }

  /* Test 10: Modify existing keys (no value) */
  printf("Test %d passed\r\n", ntestpass++);
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i) ;
    for ( j = 0; j < nkeystotal; j++ )
    {
      sprintf(key_name, "KeyName%d", j) ;
      buffer[0] = 0 ;
      SetIniKey( hini, section_name, key_name, buffer ) ;
    }
  }

  /* Check modifications */
  for ( i = 0; i < nsections; i++ )
  {
    sprintf(section_name, "SectionName%d", i);
    for ( j = nkeystotal-1; j >= 0; j-- )
    {
      sprintf(key_name, "KeyName%d", j) ;
      buffer[0] = 0 ;
      if ( GetIniKey( hini, section_name, key_name, buffer2 ) == 1 )
      {
        if ( strcmp( buffer, buffer2 ) != 0 )
          return ntestpass ;
      }
      else
        return ntestpass ;
    }
  }

  /* Test 11: Save under a new name */
  printf("Test %d passed\r\n", ntestpass++) ;
  ini_name[0] = 'x';
  if ( SaveAndCloseIni( hini, ini_name ) != 0 ) return ntestpass ;
  
  return 0 ;
}