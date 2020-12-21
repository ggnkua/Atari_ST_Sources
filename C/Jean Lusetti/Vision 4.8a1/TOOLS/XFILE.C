#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <ctype.h>
#include <tos.h>
/* #include <atarierr.h> Conflicting with errno.h */

#include "xfile.h"
#include "stdprog.h"
#include "logging.h"

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(v)  sizeof(v)/sizeof((v)[0])
#endif

#define XF_CACHE_SIZE 2048

#ifndef __NO_XALLOC
typedef struct _IMGF_TRACKING
{
  int   fd ;
  char* filename ;
}
IMGF_TRACKING, *PIMGF_TRACKING ;

IMGF_TRACKING ImgFTracking[16] ;
#endif


int FileExist(char* file)
{
  FILE *stream ;
  int  exist = 1 ;

  stream = fopen( file, "rb" ) ;
  if ( stream == NULL ) exist = 0 ;
  else                  fclose( stream ) ;

  return exist ;
}

int CopyFile(char* src, char* dst)
{
  FILE          *sin, *sout ;
  unsigned long size_alloc = 64L * 1024L ;
  size_t        nb_read, nb_written ;
  int           err = 0 ;
  char          buf[512] ;
  void          *pt_alloc = NULL ;

  if ( src )
  {
    sin = fopen( src, "rb" ) ;
    if ( sin == NULL ) return ENOENT ;
  }

  sout = fopen( dst, "wb" ) ;
  if ( sout == NULL )
  {
    if ( sin ) fclose( sin ) ;
    return EINVAL ;
  }

  if ( src == NULL )
  {
    fclose( sout ) ;
    return 0 ; /* src is NULL, just create dst */
  }

  while ( (pt_alloc == NULL) && (size_alloc >= 1024) )
  {
    pt_alloc = Xalloc( size_alloc ) ;
    if ( pt_alloc == NULL ) size_alloc >>= 1 ;
  }
  if ( pt_alloc == NULL )
  {
    pt_alloc   = buf ;
    size_alloc = sizeof(buf) ;
  }

  do
  {
    nb_read = fread( pt_alloc, 1, size_alloc, sin ) ;
    if ( nb_read > 0 )
    {
      nb_written = fwrite( pt_alloc, 1, nb_read, sout ) ;
      err        = ( nb_written != nb_read ) ;
    }
  }
  while ( !err && (nb_read > 0) ) ;

  if ( err ) err = ENOSPC ;

  if ( pt_alloc != buf ) Xfree( pt_alloc ) ;
  fclose( sout ) ;
  fclose( sin ) ;

  return err ;
}

int CopyFileR(char* src, char* dst)
{
  int status = CopyFile( src, dst ) ;

  if ( status == EINVAL )
  {
    char* slash = strchr( dst, '\\' ) ;

    /* Create any sub-folder if copy failed and retry */
    while ( slash )
    {
      *slash = 0 ;
      LoggingDo(LL_DEBUG, "CopyFileR, creating folder %s", dst) ;
      Dcreate( dst ) ;
      *slash = '\\' ;
      slash  = strchr( 1+slash, '\\' ) ;
    }
    status = CopyFile( src, dst ) ;
  }

  return status ;
}

void* CreateFileR(char* name)
{
  FILE* stream = fopen( name, "wb" ) ;

  if ( stream == NULL )
  {
    char* slash = strchr( name, '\\' ) ;

    /* Create any sub-folder if creation failed and retry */
    while ( slash )
    {
      *slash = 0 ;
      LoggingDo(LL_DEBUG, "CreateFileR, creating folder %s", name) ;
      Dcreate( name ) ;
      *slash = '\\' ;
      slash  = strchr( 1+slash, '\\' ) ;
    }
    stream = fopen( name, "wb" ) ;
  }

  return stream ;
}


int MoveFile(char* src, char* dst)
{
  int err ;

  if ( tolower( src[0] ) == tolower( dst[0] ) ) err = rename( src, dst ) ;
  else
  {
    err = CopyFile( src, dst ) ;
    if ( !err ) err = unlink( src ) ;
  }

  return err ;
}

int CreateFolder(char* path)
{
  int err ;

  err = Dcreate( path ) ;
  if ( err == -36 ) err = 0 ; /* Le repertoire existe deja */

  return err ;
}

int CmpFiles(char* f1, char* f2)
{
#define RBLK_CMP 1024
  FILE   *s1, *s2 ;
  size_t l1, l2 ;
  size_t nb_read ;
  int    idem = 1 ;
  char   buf1[RBLK_CMP], buf2[RBLK_CMP] ;

  if ( strcmpi( f1, f2 ) == 0 ) return 1 ;

  l1 = file_size( f1 ) ;
  l2 = file_size( f2 ) ;
  if ( l1 != l2 ) return 0 ;

  s1 = fopen( f1, "rb" ) ;
  if ( s1 == NULL ) return 0 ;
  s2 = fopen( f2, "rb" ) ;
  if ( s2 == NULL )
  {
    fclose( s1 ) ;
    return 0 ;
  }

  if ( l1 == l2 )
  {
    do
    {
      nb_read = fread( buf1, 1, RBLK_CMP, s1 ) ;
      nb_read = fread( buf2, 1, nb_read, s2 ) ;
      idem    = ( memcmp( buf1, buf2, nb_read ) == 0 ) ;
    }
    while ( idem && (nb_read > 0) ) ;    
  }
  else idem = 0 ;

  fclose( s2 ) ;
  fclose( s1 ) ;

  return idem ;
}

int FolderExist(char* folder) /* Idea: G.Tello as we can't rely Fattrib on old TOSes */
{
  DTA    dta ;
  DTA*   old_dta ;
  char   bname[PATH_MAX] ;
  size_t folder_len = strlen(folder) ;
  int    folder_exists ;

  if ( folder[folder_len-1] != '\\' ) sprintf( bname, "%s\\*.*", folder ) ;
  else                                sprintf( bname, "%s*.*", folder ) ;
  old_dta = Fgetdta() ;
  Fsetdta( &dta ) ;

  folder_exists = ( Fsfirst( bname, -1 ) == 0 ) ;
  /* Some TOSes may fail here if folder is empty */
  /* Let's create a temporary file then          */
  if ( !folder_exists )
  {
    FILE* tmp_file ;

    LoggingDo(LL_DEBUG, "Folder %s looks non existing, trying to create a file under it to make sure...", folder) ;
    if ( folder[folder_len-1] != '\\' ) sprintf( bname, "%s\\tmp", folder ) ;
    else                                sprintf( bname, "%stmp", folder ) ;
    tmp_file = fopen( bname, "w" ) ;
    if ( tmp_file )
    {
      fclose( tmp_file ) ;
      unlink( bname ) ;
      folder_exists = 1 ;
    }
  }
  LoggingDo(LL_DEBUG, "FolderExist(%s)=%d", folder, folder_exists) ;

  Fsetdta( old_dta ) ;

  return folder_exists ;
}

long FileTxtStats(char* filename, long *nbytes)
{
  FILE* stream = fopen( filename, "rb" ) ;
  char  s[1024] ;
  long  nstrings = 0 ;

  *nbytes = 0 ;
  if ( stream )
  {
    while ( fgets( s, (int)sizeof(s), stream ) )
    {
      nstrings++ ;
      *nbytes += 1+strlen(s) ;
    }
    fclose( stream ) ;
  }
  else nstrings = -1 ;

  return nstrings ;
}

#ifndef __NO_XALLOC
static IMGF_TRACKING* ImgFAddTrack(int fd, char* filename)
{
  IMGF_TRACKING* t = ImgFTracking ;
  IMGF_TRACKING* tlast = &ImgFTracking[ARRAY_SIZE(ImgFTracking)-1] ;
  short          found = 0 ;

  while ( (t <= tlast) && !found )
  {
    if ( t->filename == NULL )
    {
      t->filename = Xstrdup( filename ) ;
      if ( t->filename )
      {
        t->fd = fd ;
        found = 1 ;
        LoggingDo(LL_DEBUG,"File descriptor %d for file %s being tracked", fd, filename) ;
      }
      else break ;
    }
    else t++ ;
  }

  if ( !found ) t = NULL ;

  return t ;
}

static short ImgFReleaseTrack(int fd)
{
  IMGF_TRACKING* t = ImgFTracking ;
  IMGF_TRACKING* tlast = &ImgFTracking[ARRAY_SIZE(ImgFTracking)-1] ;
  short          found = 0 ;

  while ( (t <= tlast ) && !found )
  {
    if ( t->fd == fd )
    {
      LoggingDo(LL_DEBUG,"File descriptor %d for file %s released", fd, t->filename) ;
      Xfree( t->filename ) ;
      t->filename = NULL ;
      t->fd       = -1 ;
      found       = 1 ;
    }
    else t++ ;
  }

  if ( !found ) LoggingDo(LL_WARNING, "File descriptor %d is not referenced", fd) ;
  return found ;
}

void ImgFTrackExit(void)
{
  IMGF_TRACKING* t ;
  IMGF_TRACKING* tlast = &ImgFTracking[ARRAY_SIZE(ImgFTracking)-1] ;

  for ( t = ImgFTracking; t <= tlast; t++ )
  {
    if ( t->filename ) LoggingDo(LL_ERROR, "File %s is still open", t->filename) ;
  }
}
#else
#define ImgFAddTrack(fd, filename)
#define ImgFReleaseTrack(fd)
void ImgFTrackExit(void)
{
}
#endif

static void InitXFileStr(XFILE* xfile)
{
  memzero( xfile, sizeof(XFILE) ) ;
  xfile->cache_start = xfile->cache_end = -1 ;
  xfile->file_size = -1 ;
}

int XFclose(XFILE* xfile)
{
  int ret = -37 ; /* EIHNDL conflicting with errno.h */

  if ( xfile->valid )
  {
    if ( xfile->cache_buffer ) Xfree( xfile->cache_buffer ) ;
    ret = Fclose( xfile->gdos_fd ) ;
    ImgFReleaseTrack( xfile->gdos_fd ) ;
    LoggingDo(LL_INFO, "%lu cache hits/%lu read requests", xfile->ncache_hits, xfile->nreads ) ;
    InitXFileStr( xfile ) ;
  }

  return ret ;
}

long XFseek(XFILE* xfile, long offset, short seek_mode)
{
  /* Need to align pos as bufferring makes this more complicated */
  LoggingDo(LL_DEBUG,"XFseek %ld, mode %d", offset, seek_mode) ;
  if ( seek_mode == SEEK_END )
  {
    if ( xfile->file_size == -1 ) xfile->file_size = Fseek( 0L, xfile->gdos_fd, SEEK_END ) ;
    offset = xfile->file_size - offset ;
  }
  else if ( seek_mode == SEEK_CUR ) offset = xfile->logical_seek_ptr + offset ;
  xfile->physical_seek_ptr = Fseek( offset, xfile->gdos_fd, SEEK_SET ) ;
  xfile->logical_seek_ptr  = xfile->physical_seek_ptr ;
  LoggingDo(LL_DEBUG,"XFseek %ld", xfile->logical_seek_ptr) ;

  return xfile->physical_seek_ptr ;
}

static long data_pos_cache(XFILE* xfile, long offset)
{
  if ( offset < xfile->cache_start ) return( offset-xfile->cache_start ) ;
  if ( offset > xfile->cache_end ) return( offset-xfile->cache_end ) ;
  
  return 0 ;
}

static long load_cache(XFILE* xfile, char* buf, long count)
{
  long local_count ;

  LoggingDo(LL_DEBUG,"load_cache: %lu bytes, phys %lu, log %lu cache %lu-%lu", count, xfile->physical_seek_ptr, xfile->logical_seek_ptr, xfile->cache_start, xfile->cache_end) ;
  if ( xfile->physical_seek_ptr != xfile->logical_seek_ptr )
     xfile->physical_seek_ptr = xfile->logical_seek_ptr = Fseek( xfile->logical_seek_ptr, xfile->gdos_fd, SEEK_SET ) ;
  if ( count > xfile->cache_size )
  {
    /* Cache smaller than data to read :     */
    /* Read data and copy last data to cache */
    long old_phy_seek = xfile->physical_seek_ptr ;
    long nbytes4cache ;

    local_count               = Fread( xfile->gdos_fd, count, buf ) ;
    xfile->physical_seek_ptr += local_count ;
    xfile->cache_end          = xfile->physical_seek_ptr - 1 ;
    xfile->cache_start        = xfile->cache_end - xfile->cache_size + 1 ;
    if ( xfile->cache_start < old_phy_seek ) xfile->cache_start = old_phy_seek ;
    nbytes4cache              = 1 + xfile->cache_end - xfile->cache_start ;
    memcpy( xfile->cache_buffer, buf+local_count-nbytes4cache, nbytes4cache ) ;
    xfile->logical_seek_ptr   = xfile->physical_seek_ptr ;
  }
  else
  {
    /* Cache bigger than data to read:       */
    /* Fill in cache and update data to read */
    local_count               = Fread( xfile->gdos_fd, xfile->cache_size, xfile->cache_buffer ) ;
    xfile->cache_start        = xfile->physical_seek_ptr ;
    xfile->physical_seek_ptr += local_count ;
    xfile->cache_end          = xfile->cache_start + local_count - 1 ;
    if ( local_count > count ) local_count = count ;
    memcpy( buf, xfile->cache_buffer, local_count ) ;
    xfile->logical_seek_ptr  += local_count ;
  }
  LoggingDo(LL_DEBUG,"load_cache: phys %lu, log %lu cache %lu-%lu(%lu)", xfile->physical_seek_ptr, xfile->logical_seek_ptr, xfile->cache_start, xfile->cache_end, 1+xfile->cache_end-xfile->cache_start) ;

  return local_count ;
}

long XFread(XFILE* xfile, void* buf, long count)
{
  long pos_req_start = data_pos_cache( xfile, xfile->logical_seek_ptr ) ;
  long pos_req_end   = data_pos_cache( xfile, xfile->logical_seek_ptr+count-1 ) ;

  xfile->nreads++ ;
  LoggingDo(LL_DEBUG, "XFread: %ld bytes from %ld", count, xfile->logical_seek_ptr) ;
  if ( (pos_req_start == 0) && (pos_req_end == 0) )
  {
    /* All requested data is already cached */
    memcpy( buf, xfile->cache_buffer+xfile->logical_seek_ptr-xfile->cache_start, count ) ;
    xfile->logical_seek_ptr += count ;
    xfile->ncache_hits++ ;
  }
  else count = load_cache( xfile, buf, count ) ;

  return count ;
}

long XFopen(XFILE* xfile, char* name, short mode, long cache_size)
{
  InitXFileStr( xfile ) ;
  xfile->gdos_fd = (int)Fopen( name, mode ) ;
  if ( xfile->gdos_fd < 0 ) return xfile->gdos_fd ;

  xfile->valid      = 1 ;
  xfile->cache_size = XF_CACHE_SIZE ;
  LoggingDo(LL_DEBUG,"cache_size=%ld",cache_size);
  if ( cache_size < 0 )
  {
    xfile->file_size = Fseek( 0L, xfile->gdos_fd, SEEK_END ) ;
    LoggingDo(LL_DEBUG,"file_size=%ld",xfile->file_size);
    Fseek( 0L, xfile->gdos_fd, SEEK_SET ) ;
    if ( cache_size == -1 ) xfile->cache_size = xfile->file_size ; /* else keep defaut cache size */
  }
  else if ( cache_size ) xfile->cache_size = cache_size ;
  xfile->cache_buffer = Xalloc( xfile->cache_size ) ;
  if ( xfile->cache_buffer )
  {
    if ( cache_size == -1 ) XFread( xfile, xfile->cache_buffer, xfile->cache_size ) ;
    ImgFAddTrack( xfile->gdos_fd, name ) ;
  }
  else
  {
    XFclose( xfile ) ;
    xfile->gdos_fd = -39 ; /* ENSMEM in atarierr.h conflicting with errno.h */
  }

  return xfile->gdos_fd ;
}

static int XFTCreateFile(char* name, size_t size)
{
  FILE* stream = fopen( name, "wb" ) ;
  char  buffer[1024] ;
  size_t size2write = sizeof(buffer) ;
  long   i ;

  if ( !stream ) return -1 ;

  /* Create a simple test file of size bytes,    */
  /* Each byte value is its offset in file % 256 */
  for ( i=0; i < sizeof(buffer); i++ ) buffer[i] = (unsigned char)i ;

  for (i=0; i < size; i += sizeof(buffer))
  {
    if ( i+size2write > size ) size2write = size-i ;
    fwrite( buffer, size2write, 1, stream ) ;
  }

  fclose( stream ) ;

  return 0 ;
}

static int SeqReads(XFILE* xfile, long size2read)
{
  char* buffer ;
  long  size_read, size_to_read ;
  int   done, err=0 ;
  long  i, offset ;

  if ( size2read < 0 ) buffer = (char*)Xalloc(1024L*64L) ;
  else                 buffer = (char*)Xalloc(size2read) ;
  if ( buffer == NULL ) return 0 ;
  /* Sequential reads of various sizes */
  offset       = 0 ;
  XFseek( xfile, offset, SEEK_SET ) ;
  done         = 0 ;
  size_to_read = size2read ;
  while ( !done )
  {
    if ( size2read < 0 ) size_to_read = rand() % (1024L*64L) ;
    size_read = XFread( xfile, buffer, size_to_read) ;
    done      = (size_read != size_to_read) ;
    for ( i = 0; i < size_read; i++ )
    if ( buffer[i] != (char)((offset+i) & 0xFF) )
    {
      LoggingDo(LL_ERROR," SeqReads:Expected byte at offset $%lx:%X, read:%X", offset+i, (char)(offset+i) & 0xFF, buffer[i]) ;
      err = done = 1 ;
    }
    offset += size_read ;
  }
  if ( !err ) LoggingDo(LL_INFO," Sequential reading file by chunks of %ld bytes...OK", size2read) ;

  Xfree( buffer ) ;

  return err ;
}

static int RandReads(XFILE* xfile, long filesize, long size2read)
{
  char* buffer ;
  long  size_read, size_to_read ;
  int   err=0 ;
  long  n, i, offset ;

  if ( size2read < 0 ) buffer = (char*)Xalloc(1024L*64L) ;
  else                 buffer = (char*)Xalloc(size2read) ;
  if ( buffer == NULL ) return 0 ;
  /* Sequential reads of various sizes */
  offset       = 0 ;
  XFseek( xfile, offset, SEEK_SET ) ;
  size_to_read = size2read ;
  for ( n=0; !err && (n < 128); n++ )
  {
    if ( size2read < 0 ) size_to_read = rand() % (1024L*64L) ;
    if ( (rand() & 0x3) == 0 )
    {
      offset = rand() % filesize ;
      offset = XFseek( xfile, offset, SEEK_SET ) ;
    }
    size_read = XFread( xfile, buffer, size_to_read) ;
    for ( i = 0; !err && (i < size_read); i++ )
      if ( buffer[i] != (char)((offset+i) & 0xFF) )
      {
        LoggingDo(LL_ERROR," RandReads: Expected byte at offset $%lx:%X, read:%X", offset+i, (unsigned char)(offset+i) & 0xFF, (unsigned char)buffer[i]) ;
        err = 1 ;
      }
    offset += size_read ;
  }
  if ( !err ) LoggingDo(LL_INFO," Random reading file by chunks of %ld bytes...OK", size2read) ;

  Xfree( buffer ) ;

  return err ;
}

static long FTest(char* name, size_t file_size, long cache_size)
{
  XFILE xfile ;
  long  read_size ;
  int   i ;
  long  result = 0 ;

  result = XFopen( &xfile, name, 0, cache_size ) ;
  if ( result < 0 )
  {
    LoggingDo(LL_ERROR,"FTest: can't open %s, error %ld", name, xfile.file_size) ;
    return -1 ;
  }

  result = 0 ;
  /* Check file size if requested */
  if ( cache_size < 0 )
  {
    if ( xfile.file_size != file_size) LoggingDo(LL_ERROR," Expected file size:%ld, reported value:%ld", file_size, xfile.file_size) ;
    else                               LoggingDo(LL_INFO," File size %ld bytes...OK", xfile.file_size) ;
  }

  /* Sequential reads of various sizes */
  for ( i=0; i < 4; i++)
  {
    if ( i==0 )       read_size = 1 ;
    else if ( i== 1 ) read_size = -1 ;
    else              read_size = 1 + (rand() % 128) ;
    result += SeqReads( &xfile, read_size ) ;
  }

  /* Random reads of various sizes */
  for ( i=0; i < 4; i++)
  {
    if ( i==0 )       read_size = 1 ;
    else if ( i== 1 ) read_size = -1 ;
    else              read_size = 1 + (rand() % 128) ;
    result += RandReads( &xfile, file_size, read_size ) ;
  }

  /* TODO: test against seek modes */

  XFclose( &xfile ) ;

  return result ;
}

void XFileTest(void)
{
  size_t file_sizes[] = { 7, 1024, 2048, 4096, 32000, 65233UL, 452365UL, 1024UL*1024UL*3UL } ;
  long   cache_sizes[] = { 0, -2, -1, 1024, 32768L } ;
  char   fname[256] ;
  int    s, c ;

  for ( s = 0; s < ARRAY_SIZE(file_sizes); s++ )
    for ( c = 0; c < ARRAY_SIZE(cache_sizes); c++ )
    {
      sprintf( fname, "%ld.tst", file_sizes[s] ) ;
      if ( XFTCreateFile( fname, file_sizes[s] ) == 0 )
      {
        LoggingDo(LL_INFO, "Testing file %s with cache size %ld", fname, cache_sizes[c]);
        FTest( fname, file_sizes[s], cache_sizes[c] ) ;
        unlink( fname ) ;
      }
      else LoggingDo(LL_ERROR, "Can't create test file %s", fname);
    }
}
