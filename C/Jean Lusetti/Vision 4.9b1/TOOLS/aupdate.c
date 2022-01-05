#include    <stdio.h>
#include   <stdlib.h>
#include   <string.h>
#include <atarierr.h>

#include "..\tools\sha256.h"
#include "..\tools\logging.h"
#include "..\tools\stdprog.h"
#include "..\tools\aupdate.h"
#include "..\tools\xfile.h"


static short AUGetCmdLine4PExec(char* updater, char* url, char* cmd_line, char* url_file, char* local_file, char* trusted_ca_file)
{
  char  buf[256] ;
  short cmd_len ; 
  
  /* If URL does not end with /, add it */
  strcpy( buf, url ) ;
  if ( buf[strlen(buf)-1] != '/' ) strcat( buf, "/" ) ;

  if ( strstr( updater, "curl" ) )
  {
    char tls_param[256] ; /* Trusted RootCA file or insecure mode */

    if ( !FileExist( trusted_ca_file ) ) LoggingDo(LL_WARNING, "AUCheckUpdate: %s does not exist", trusted_ca_file) ;
    if ( trusted_ca_file && *trusted_ca_file ) sprintf( tls_param, "--cacert %s", trusted_ca_file ) ;
    else                                       strcpy( tls_param, "-k" ) ; /* -k for client to not check server certificate as let's encrypt CA may not be trusted by curl */
    sprintf( &cmd_line[1], "-L %s --get %s%s --output %s", tls_param, buf, url_file, local_file ) ;
  }
  else if ( strstr( updater, "wget" ) ) sprintf( &cmd_line[1], "%s%s -O %s", buf, url_file, local_file ) ;
  else                                  return AU_UPDATERUNKNOWN ;

  cmd_len = (short) strlen( &cmd_line[1] ) ;
  if ( cmd_len <= 124 )
  {
    /* Max 124 bytes, see https://freemint.github.io/tos.hyp/en/gemdos_process.html#Pexec */
    cmd_line[0] = (char)cmd_len ; /* Pascal convention */
    return 0 ;
  }
  else
  {
    LoggingDo(LL_ERROR, "AUCheckUpdate: command line too long (%d>124)", cmd_len) ;
    return AU_UPDATECMDTOOLONG ;
  }
}

short AUCheckUpdate(AU_CONTEXT* AUContext)
{
  FILE* stream ;
  long  cmd_status ;
  short maj, min, build ;
  char  buf[256], rev ;
  char  cmd_line[256] ;
  short status_cmdline, status = AU_UPDATERERR ;

  LoggingDo(LL_INFO, "AUCheckUpdate: current_version:%s, path_update:%s, updater:%s, URL=%s", AUContext->current_version, AUContext->path_update, AUContext->updater, AUContext->url) ;

  /* Make sure we delete any local version file */
  sprintf( AUContext->local_version_file, "%s\\%s", AUContext->path_update, AUContext->inet_app_fversion ) ;
  unlink( AUContext->local_version_file ) ;

  status_cmdline = AUGetCmdLine4PExec( AUContext->updater, AUContext->url, cmd_line, AUContext->inet_app_fversion, AUContext->local_version_file, AUContext->trusted_ca_file ) ;
  if ( status_cmdline != 0 ) return status_cmdline ;
  LoggingDo(LL_DEBUG, "AUCheckUpdate: request update with %s %s", AUContext->updater, &cmd_line[1]) ;
  cmd_status = XPexec( 0, AUContext->updater, cmd_line, NULL ) ;
  if ( cmd_status != 0 )
  {
    if ( cmd_status == EFILNF ) return AU_NOUPDATER ;
    LoggingDo(LL_ERROR, "AUCheckUpdate: command line %s %s returned error %ld", AUContext->updater, &cmd_line[1], cmd_status) ;
    if ( cmd_status < 0 ) return status ;
    else                  return AU_UPDATERERR ;
  }

  stream = fopen( AUContext->local_version_file, "rb" ) ;
  if ( stream )
  {
    if ( fgets( buf, (int)sizeof(buf), stream ) != NULL )
    {
      char fmt_version[] = "%d.%d%c%d" ;
      char str_fmt[32] ;

      sprintf( str_fmt, "Version = %s", fmt_version ) ;
      if ( sscanf( buf, str_fmt, &maj, &min, &rev, &build ) == 4 )
      {
        sprintf( buf, fmt_version, maj, min, rev, build ) ;
        LoggingDo(LL_DEBUG, "AUCheckUpdate: last version on Internet: %s, current version: %s", buf, AUContext->current_version) ;
        if ( strcmpi( buf, AUContext->current_version ) )
        {
          LoggingDo(LL_DEBUG, "AUCheckUpdate: new version available from Internet: %s", buf) ;
          strcpy( AUContext->url_version, buf ) ;
          status = AU_UPDATEFOUND ;
        }
        else status = AU_NOUPDATE ;
      }
      else LoggingDo(LL_DEBUG, "AUCheckUpdate: inconsistent first line %s", buf) ;
    }
    else LoggingDo(LL_ERROR, "AUCheckUpdate: Can't read first line of %s", AUContext->local_version_file) ;
    fclose (stream ) ;
  }
  else LoggingDo(LL_ERROR, "AUCheckUpdate: %s has NOT been created", AUContext->local_version_file) ;

  return status ;
}

static short AUUpdateFile(char* filename, AU_CONTEXT* AUContext)
{
  char src[PATH_MAX] ;
  char dst[PATH_MAX] ;
  char cmd_line[256] ;
  long cmd_status ;
  int  status ;
  int  src_exists = 1 ;

  /* First backup the existing file */
  sprintf( src, "%s\\%s", AUContext->path_init, filename ) ;
  sprintf( dst, "%s\\%s\\%s", AUContext->path_update, AUContext->current_version, filename ) ;
  LoggingDo(LL_DEBUG, "AUUpdateFile: backup %s to %s...", src, dst) ;
  status = CopyFileR( src, dst ) ;
  if ( status != 0 )
  {
    src_exists = FileExist(src) ; /* Make sure src exists, else it's not an error */
    if ( src_exists )
    {
      LoggingDo(LL_ERROR, "AUUpdateFile failed with %d", status) ;
      return status ;
    }
  }

  /* Then get updated file for Internet */
  strrep( filename, '\\', '/' ) ; /* URL format */
  if ( AUGetCmdLine4PExec( AUContext->updater, AUContext->url, cmd_line, filename, src, AUContext->trusted_ca_file ) != 0 ) return -1 ;
  status = CopyFileR( NULL, src ) ;
  if ( status != 0 )
  {
    /* Can't create sub folders/file for updater */
    LoggingDo(LL_ERROR, "AUCheckUpdate: can't create local folder/file %s for updater, error %d", src, status) ;
    return status ;
  }
  LoggingDo(LL_DEBUG, "AUUpdateFile: fetching file from Internet with %s %s", AUContext->updater, &cmd_line[1]) ;
  cmd_status = XPexec( 0, AUContext->updater, cmd_line, NULL ) ;
  LoggingDo(LL_DEBUG, "AUUpdateFile: Pexec returned %ld", cmd_status) ;
  if ( (cmd_status != 0) && src_exists )
  {
    LoggingDo(LL_ERROR, "AUCheckUpdate: command line returned error %ld, restoring backup...", cmd_status) ;
    MoveFile( dst, src ) ;
    if ( cmd_status < 0 ) return (int)status ;
    else                  return AU_UPDATERERR ;
  }

  return status ;
}

short AUPerformUpdate(AU_CONTEXT* AUContext)
{
  FILE*  stream ;
  char   url_str_sha256[1+2*SHA256_DIGEST_LENGTH] ;
  char   local_filename[PATH_MAX] ;
  char   filename[64], buf[512] ;
  size_t local_filesize ;
  size_t url_filesize ;
  long   pc = 0 ;
  short  update_file ;

  LoggingDo(LL_DEBUG, "AUPerformUpdate: path_init:%s, path_update:%s, updater:%s, URL:%s", AUContext->path_init, AUContext->path_update, AUContext->updater, AUContext->url) ;

  stream = fopen( AUContext->local_version_file, "rb" ) ;
  if ( stream == NULL ) return AU_UPDATERERR ;

  AUContext->nfiles_updated = AUContext->nfiles_not_updated = AUContext->nfiles_to_update = 0 ;
  fgets( buf, (int)sizeof(buf), stream ) ; /* Ignore version line */
  (void)GWProgRange( AUContext->wprog, pc, -100L, NULL ) ;
  while ( fgets( buf, (int)sizeof(buf), stream ) != NULL )
  {
    if ( sscanf( buf, "%s %lu %s", filename, &url_filesize, url_str_sha256 ) == 3 )
    {
      if ( AUContext->IsFileToUpdate( filename ) )
      {
        LoggingDo(LL_DEBUG, "AUPerformUpdate: file %s%s", AUContext->url, filename) ;
        sprintf( local_filename, "%s\\%s", AUContext->path_init, filename ) ;
        update_file    = 1 ;
        local_filesize = file_size( local_filename ) ;
        if ( local_filesize == url_filesize )
        {
          uint8_t local_sha256[SHA256_DIGEST_LENGTH] ;
        	char    local_str_sha256[1+2*SHA256_DIGEST_LENGTH] ;
          long    err ;

          /* Same sizes, must compare SHA256 */
          LoggingDo(LL_DEBUG, "AUPerformUpdate: local and URL files have same size %lu bytes", local_filesize) ;
          err = sha256_file( local_filename, local_sha256 ) ;
          if ( err == 0 )
          {
            sha_digest( local_str_sha256, local_sha256, SHA256_DIGEST_LENGTH ) ;
            if ( memcmp( local_str_sha256, url_str_sha256, SHA256_DIGEST_LENGTH ) == 0 )
            {
              LoggingDo(LL_DEBUG, "AUPerformUpdate: local and URL files have same sha256 %s, won't update", local_str_sha256) ;
              update_file = 0 ; /* No change of file */
            }
            else LoggingDo(LL_DEBUG, "AUPerformUpdate: local file sha256=%s, URL file sha256=%s, will update", local_str_sha256, url_str_sha256) ;
          }
          else LoggingDo(LL_WARNING, "AUPerformUpdate: unexpected error %ld on SHA256 calculation of local file %s", err, local_filename) ;
        }
        else LoggingDo(LL_DEBUG, "AUPerformUpdate: local file size=%lu, URL file size=%lu, will update", local_filesize, url_filesize) ;
        if ( update_file )
        {
          StdProgWText( AUContext->wprog, 1, local_filename ) ;
          pc += 10 ;
          if ( pc > 100 ) pc = 0 ;
          (void)GWProgRange( AUContext->wprog, pc, -100L, NULL ) ;
          AUContext->nfiles_to_update++ ;
          LoggingDo(LL_INFO, "AUPerformUpdate: updating file %s...", local_filename) ;
          if ( AUUpdateFile( filename, AUContext ) == 0 ) AUContext->nfiles_updated++ ;
          else                                            AUContext->nfiles_not_updated++ ;
        }
      }
      else LoggingDo(LL_DEBUG, "AUPerformUpdate: file %s is marked as not to update", filename) ;
    }
    else LoggingDo(LL_WARNING, "AUPerformUpdate: inconsistent line %s", buf) ;
  }
  fclose( stream ) ;

  unlink( AUContext->local_version_file ) ;
  LoggingDo(LL_INFO, "AUPerformUpdate: %d/%d files updated", AUContext->nfiles_updated, AUContext->nfiles_to_update) ;

  return AUContext->nfiles_not_updated ? AU_UPDATERERR : AU_UPDATEDONE ;
}
