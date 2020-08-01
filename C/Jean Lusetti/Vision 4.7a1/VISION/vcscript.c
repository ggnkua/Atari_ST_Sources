/*************************************/
/* VCSCRIPT.C: VISION Command Script */
/*************************************/
#include <stdio.h>
#include <string.h>
#include "..\tools\logging.h"
#include "..\tools\gwindows.h"
#include "..\tools\catalog.h"
#include "..\tools\xfile.h"
#include "..\tools\ini.h"

#include         "defs.h"
#include      "actions.h"
#include     "vcscript.h"
#include     "ibrowser.h"
#include "forms\fbconv.h"
#include "forms\falbum.h"
#include "forms\frfiles.h"

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(v)  sizeof(v)/sizeof((v)[0])
#endif

#define CMD_UNKNOWN    -1
#define CMD_COMMENT    0
#define CMD_OPEN       1
#define CMD_CLOSE      2
#define CMD_WAIT       3
#define CMD_LOOP       4
#define CMD_ENDLOOP    5
#define CMD_RSCRIPT    6
#define CMD_CATCRE     7
#define CMD_CATAFI     8
#define CMD_CATAFO     9
#define CMD_CATOICN    10
#define CMD_CATSINI    11
#define CMD_IBOPEN     12
#define CMD_IBNEXT     13
#define CMD_IBPREV     14
#define CMD_BCONV      15
#define CMD_IPSET      16
#define CMD_LDVDO      17
#define CMD_LDVDOIP    18
#define CMD_QUIT       100

typedef struct
{
  char* Label ;
  short Id ;
}
COMMAND_LABEL_IDS, *PCOMMAND_LABEL_IDS ;

COMMAND_LABEL_IDS CmdLabelIds[] = {
                                    { ";",              CMD_COMMENT },
                                    { "quit",           CMD_QUIT }, { "exit",  CMD_QUIT },
                                    { "open",           CMD_OPEN },
                                    { "close",          CMD_CLOSE },
                                    { "wait",           CMD_WAIT }, { "sleep", CMD_WAIT },
                                    { "loop",           CMD_LOOP },
                                    { "endloop",        CMD_ENDLOOP },
                                    { "run_script",     CMD_RSCRIPT },
                                    { "cat_create",     CMD_CATCRE },
                                    { "cat_addfile",    CMD_CATAFI },
                                    { "cat_addfolder",  CMD_CATAFO },
                                    { "cat_openwicon",  CMD_CATOICN },
                                    { "cat_setini",     CMD_CATSINI },
                                    { "ibrw_open",      CMD_IBOPEN },
                                    { "ibrw_next",      CMD_IBNEXT },
                                    { "ibrw_prev",      CMD_IBPREV },
                                    { "bconv_do",       CMD_BCONV },
                                    { "iprio_set",      CMD_IPSET },
                                    { "imgprio_set",    CMD_IPSET },
                                    { "ldv_do",         CMD_LDVDO },
                                    { "ldv_doip",       CMD_LDVDOIP },
                                  } ;


void FreeScript(VCMD_SCRIPT* vcmd_script)
{
  if ( vcmd_script->ChildScript )
  {
    FreeScript( vcmd_script->ChildScript ) ;
    Xfree( vcmd_script->ChildScript ) ;
  }
  if ( vcmd_script->Buffer ) Xfree( vcmd_script->Buffer ) ;
  if ( vcmd_script->PtrLines ) Xfree( vcmd_script->PtrLines ) ;
  memset( vcmd_script, 0, sizeof(VCMD_SCRIPT) ) ;
}

static short LoadLines(VCMD_SCRIPT* vcmd_script)
{
  short i, j ;

  vcmd_script->LastLineIndex = 0 ;
  for ( i = 0; i < (short)vcmd_script->BufferLength; i++ )
    if ( vcmd_script->Buffer[i] == '\r' )
    {
      vcmd_script->Buffer[i] = 0 ;
      vcmd_script->LastLineIndex++ ;
    }
    else if ( vcmd_script->Buffer[i] == '\n' ) vcmd_script->Buffer[i] = 0 ;

  vcmd_script->PtrLines = (char**) Xcalloc( 1+vcmd_script->LastLineIndex, sizeof(char*) ) ;
  if ( vcmd_script->PtrLines == NULL ) return SVCS_NOMEMORY ;

  i = j = 0 ;
  do
  {
    vcmd_script->PtrLines[j++] = &vcmd_script->Buffer[i] ;
    while ( vcmd_script->Buffer[i] ) i++ ;
    while ( (i < (short)vcmd_script->BufferLength) && (vcmd_script->Buffer[i] == 0) ) i++ ;
  }
  while ( i < (short)vcmd_script->BufferLength ) ;

  LoggingDo(LL_INFO, "Script has %d lines", vcmd_script->LastLineIndex) ;

  return SVCS_SUCCESS ;
}

static short LoadScriptInMemory(char* name, VCMD_SCRIPT* vcmd_script)
{
  FILE*  stream ;
  size_t fsize ;
  short  ret ;

  stream = fopen( name, "rb" ) ;
  if ( stream == NULL ) return SVCS_FILENOEXIST ;

  fseek( stream, 0, SEEK_END ) ;
  fsize = ftell( stream ) ;
  fseek( stream, 0, SEEK_SET ) ;
  memset( vcmd_script, 0, sizeof(VCMD_SCRIPT) ) ;
  vcmd_script->Buffer = (char*) Xalloc( 1+fsize ) ;
  if ( vcmd_script->Buffer )
  {
    vcmd_script->Buffer[fsize] = 0 ; /* Make sure we end up with a \0 */
    vcmd_script->BufferLength  = fsize ;
    if ( fsize )
    {
      if ( fread( vcmd_script->Buffer, fsize, 1, stream ) == 1 ) ret = LoadLines( vcmd_script ) ;
      else                                                       ret = SVCS_NOMORECMD ;
    }
    else ret = SVCS_NOMORECMD ; /* File is empty */
  }
  else ret = SVCS_NOMEMORY ;
  fclose( stream ) ;

  if ( ret != SVCS_SUCCESS ) FreeScript( vcmd_script ) ;
  else 
  {
    strncpy( vcmd_script->FileName, name, sizeof(vcmd_script->FileName)-1 ) ;
    vcmd_script->LoopDepth = -1 ;
    vcmd_script->Magic     = VCS_MAGIC ;
  }

  return ret ;
}

static short GetCmd(char* command_line)
{
  char* space = strchr( command_line, ' ' ) ;
  short cmd = CMD_UNKNOWN ;
  short i ;

  if ( space ) *space = 0 ;

  for ( i = 0; (cmd == CMD_UNKNOWN) && (i < ARRAY_SIZE(CmdLabelIds)); i++ )
    if ( strcmpi( CmdLabelIds[i].Label, command_line ) == 0 ) cmd = CmdLabelIds[i].Id ;

  if ( space ) *space = ' ' ;

  return cmd ;
}

static short GetParam(char* command_line, short param_no, char* param)
{
  char* pc1, *pc2 ;
  char* c ;
  char* last_char = command_line + strlen(command_line)-1 ;
  short status = -1 ;
  short pno = 0 ;

  param[0] = 0 ;
  do
  {
    pc2 = NULL ;
    c = strchr( command_line, ' ' ) ;
    if ( c == NULL ) break ;
    while ( *c == ' ' ) c++ ; /* Continue until no more space */
    pc1 = c ; /* First character of param */
    if ( *c == '"' )
    {
      char* other_quote = strchr( 1+c, '"' ) ;

      if ( other_quote == NULL ) break ;
      pc1++ ; /* Go right after " */
      pc2 = other_quote ;
    }
    else pc2 = strchr( 1+c, ' ' ) ;
    if ( pc2 ) pc2-- ;
    else       pc2 = last_char ;
    command_line = 1+pc2 ;
    pno++ ;
  }
  while ( (pno < param_no) && (command_line < last_char) ) ;

  if ( pc1 && pc2 && (pc2 >= pc1) && (pno == param_no) )
  {
    size_t len = 1+pc2-pc1 ;

    memcpy( param, pc1, len ) ;
    param[len] = 0 ;
    status     = 0 ;
  }

  LoggingDo(LL_DEBUG, "GetParam(%d) returns %d, param=%s", param_no, status, param) ;
  return status ;
}

#pragma warn -par
static int OnVScriptTimer(int mx, int my, void* context)
{
  int mesg[4] ;

  *((VCMD_SCRIPT**)mesg) = context ;
  LoggingDo(LL_INFO, "Script resumes...") ;
  GemApp.OnTimer = NULL ;
  GWKillTimer( NULL ) ;
  PostMessage( NULL, WM_CMDSCRIPT_EXELINE, mesg ) ;

  return 0 ;
}
#pragma warn +par

static short GetNextLine(VCMD_SCRIPT* vcmd_script, char* buffer, size_t buffer_size)
{
  short status = SVCS_SUCCESS ;

  memset( buffer, 0, buffer_size ) ;
  if ( (vcmd_script->LineIndex <= vcmd_script->LastLineIndex) && vcmd_script->PtrLines[vcmd_script->LineIndex] )
    strncpy( buffer, vcmd_script->PtrLines[vcmd_script->LineIndex++], buffer_size-1 ) ;
  else
    status = SVCS_NOMORECMD ;

  return status ;
}

short LoadCommandScript(char* name, VCMD_SCRIPT* vcmd_script)
{
  return LoadScriptInMemory( name, vcmd_script ) ;
}

static short LoadChildScript(VCMD_SCRIPT* vcmd_script, char* name)
{
  VCMD_SCRIPT* child_script = Xcalloc( 1, sizeof(VCMD_SCRIPT) ) ;
  char         full_name[PATH_MAX] ;
  short        ret ;

  if ( child_script == NULL ) return SVCS_NOMEMORY ;

  if ( name[1] == ':' ) strncpy( full_name, name, sizeof(full_name)-1 ) ;
  else
  {
    char* last_slash = strrchr( vcmd_script->FileName, '\\' ) ;

    if ( last_slash )
    {
      *last_slash = 0 ;
      sprintf( full_name, "%s\\%s", vcmd_script->FileName, name ) ;
      *last_slash = '\\' ;
    }
    else
      strncpy( full_name, name, sizeof(full_name)-1 ) ;
  }

  ret = LoadScriptInMemory( full_name, child_script ) ;
  if ( ret != SVCS_SUCCESS ) Xfree( child_script) ;
  else                       vcmd_script->ChildScript = child_script ;

  return ret ;
}

static short CmdOpen(char* command_line)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    GemApp.OnOpenFile( param ) ;
    status = SVCS_SUCCESS ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdClose(char* command_line)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

    if ( wnd )
    {
      PostMessage( wnd, WM_CLOSED, NULL ) ;
      status = SVCS_SUCCESS ;
    }
    else
    {
      LoggingDo(LL_WARNING, "Unable to find a window with ID %s", param) ;
      status = SVCS_CMDFAILED ;
    }
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdWait(VCMD_SCRIPT* vcmd_script, char* command_line)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    if ( GemApp.OnTimer )
    {
      LoggingDo(LL_ERROR, "Application timer expected to be NULL" ) ;
      status = SVCS_CMDFAILED ;
    }
    else
    {
      GemApp.OnTimer = OnVScriptTimer ;
      GWSetTimer( NULL, atol(param), vcmd_script->ScriptContext ) ;
      status = SVCS_WAIT ;
    }
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdLoop(VCMD_SCRIPT* vcmd_script, char* command_line)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    if ( vcmd_script->LoopDepth < ARRAY_SIZE(vcmd_script->LoopData)-1 )
    {
      LOOP_DATA* loop_data ;

      vcmd_script->LoopDepth++ ;
      loop_data = &vcmd_script->LoopData[vcmd_script->LoopDepth] ;
      loop_data->NbLoopsToGo = atoi( param ) ;
      if ( loop_data->NbLoopsToGo > 0 )
      {
        loop_data->StartLoopIndex = vcmd_script->LineIndex ; /* Next line for LinePtr array */
        loop_data->LoopIndex      = 0 ;
        status                     = SVCS_SUCCESS ;
      }
      else
      {
        loop_data->NbLoopsToGo = 0 ;
        status                  = SVCS_LOOPINVALID ;
      }
    }
    else status = SVCS_LOOPINVALID ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdEndLoop(VCMD_SCRIPT* vcmd_script)
{
  short status ;

  if ( vcmd_script->LoopDepth >= 0 )
  {
    LOOP_DATA* loop_data = &vcmd_script->LoopData[vcmd_script->LoopDepth] ;

    if ( loop_data->NbLoopsToGo > 0 )
    {
      loop_data->LoopIndex++ ;
      LoggingDo(LL_DEBUG, "Loop status: %d/%d", loop_data->LoopIndex, loop_data->NbLoopsToGo) ;
      if ( loop_data->LoopIndex < loop_data->NbLoopsToGo )
        vcmd_script->LineIndex = loop_data->StartLoopIndex ;
      else
      {
        loop_data->NbLoopsToGo = 0 ; /* Loop is done */
        vcmd_script->LoopDepth-- ;
      }
      status = SVCS_SUCCESS ;
    }
    else status = SVCS_LOOPINVALID ;
  }
  else status = SVCS_LOOPINVALID ;

  return status ;
}

static short CmdCatCre(char* command_line)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    HCAT*  hcat ;
    size_t len ;
    int    cat_status ;
    char*  path ;
    char*  name ;

    len = strlen( param ) ;
    /* Remove extension if present as catalog_new does not expect it */
    if ( (len > 4) && (param[len-4] == '.') ) param[len-4] = 0 ;
    name = strrchr( param, '\\' ) ;
    if ( name ) { *name = 0 ; name++ ; path = param ; }
    else        { name = param ; path = "." ; }
    hcat = catalog_new( path, name, &cat_status ) ;
    if ( name ) *(name-1) = '\\' ;
    status = SVCS_CMDFAILED ;
    if ( hcat && (catalog_close( hcat ) == 0) )
    {
      strcat( param, ".VIC" ) ; /* Now we must have .VIC extension */
      GemApp.OnOpenFile( param ) ;
      status = SVCS_SUCCESS ;
    }
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdCatAfi(char* command_line)
{
  char  param[PATH_MAX] ;
  char  param2[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    status = GetParam( command_line, 2, param2 ) ;
    if ( status == 0 )
    {
      GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

      if ( wnd ) { ObjectNotifyAlb( wnd, ALBUM_ADDIMG, param2 ) ; status = SVCS_SUCCESS ; }
      else
      {
        LoggingDo(LL_WARNING, "Unable to find a window with ID %s", param) ;
        status = SVCS_CMDFAILED ;
      }
    }
    else status = SVCS_MISSINGP2 ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdCatAfo(char* command_line)
{
  char  param[PATH_MAX] ;
  char  param2[PATH_MAX] ;
  char  param3[32] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    status = GetParam( command_line, 2, param2 ) ;
    if ( status == 0 )
    {
      GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

      if ( wnd )
      {
        RFILE rfiles[NB_MAX_RFILES] ; /* We will use only first one but ObjectNotifyAlb assumes NB_MAX_RFILES */
        char* last_slash ;

        memset( rfiles, 0, NB_MAX_RFILES*sizeof(RFILE) ) ;
        status = GetParam( command_line, 3, param3 ) ;
        if ( (status == 0) && (strcmpi(param3, "recurse") == 0 ) ) rfiles[0].recurse = 1 ;
        last_slash = strrchr( param2, '\\' ) ;
        if ( last_slash && (last_slash != &param2[strlen(param2)-1]) ) strncpy( rfiles[0].mask, 1+last_slash, sizeof(rfiles[0].mask)-1 ) ;
        else                                                           strcpy( rfiles[0].mask, "*.*" ) ;
        if ( last_slash ) *last_slash = 0 ;
        strncpy( rfiles[0].path, param2, sizeof(rfiles[0].path)-1 ) ;
        ObjectNotifyAlb( wnd, ALBUM_ADDFOLDER, rfiles ) ;
        status = SVCS_SUCCESS ;
      }
      else
      {
        LoggingDo(LL_WARNING, "Unable to find a window with ID %s", param) ;
        status = SVCS_CMDFAILED ;
      }
    }
    else status = SVCS_MISSINGP2 ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdCatOIcn(char* command_line)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

    if ( wnd )
    {
      ObjectNotifyAlb( wnd, ALBUM_WINDOW, NULL ) ;
      status = SVCS_SUCCESS ;
    }
    else
    {
      LoggingDo(LL_WARNING, "Unable to find a window with ID %s", param) ;
      status = SVCS_CMDFAILED ;
    }
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdCatSIni(char* command_line)
{
  char  param[PATH_MAX] ;
  char  param2[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    status = GetParam( command_line, 2, param2 ) ;
    if ( status == 0 )
    {
      if ( FileExist(param2) )
      {
        GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

        if ( wnd )
        {
          HCAT* hcat = GethCatFromAlbumWindow(wnd) ;

          if ( hcat )
          {
            CATALOG_HEADER* catalog_header = catalog_get_header(hcat) ;
            int             ret ;

            if ( catalog_header )
            {
              memset( catalog_header->cat_inifile, 0, sizeof(catalog_header->cat_inifile) ) ;
              strncpy( catalog_header->cat_inifile, param2, sizeof(catalog_header->cat_inifile)-1 ) ;
              ret = catalog_applyini( hcat, MsgTxtGetMsg(hMsg, MSG_CATUPTINI) ) ;
              if ( ret == 0 ) status = SVCS_SUCCESS ;
              else            { LoggingDo(LL_WARNING, "catalog_applyini failed with %d", ret) ; status = SVCS_CMDFAILED ; }
            }
            else
            {
              LoggingDo(LL_WARNING, "Invalid catalog header") ;
              status = SVCS_CMDFAILED ;
            }
          }
          else
          {
            LoggingDo(LL_WARNING, "Invalid catalog handle") ;
            status = SVCS_CMDFAILED ;
          }
        }
        else
        {
          LoggingDo(LL_WARNING, "Unable to find a window with ID %s", param) ;
          status = SVCS_CMDFAILED ;
        }
      }
      else
      {
        LoggingDo(LL_WARNING, "File %s does not exist", param2) ;
        status = SVCS_CMDFAILED ;
      }
    }
    else status = SVCS_MISSINGP2 ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdRScript(VCMD_SCRIPT* vcmd_script, char* command_line)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 ) status = LoadChildScript( vcmd_script, param ) ;
  else               status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdIBOpen(char* command_line)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    GEM_WINDOW* wnd = GWGetWindowByID( "IBrowser" ) ;

    if ( wnd )
    {
      ObjectNotifyIBrowser( wnd, IMGB_OPEN, param ) ;
      status = SVCS_SUCCESS ;
    }
    else
    {
      LoggingDo(LL_WARNING, "Unable to find a window with ID IBrowser") ;
      status = SVCS_CMDFAILED ;
    }
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdIBMove(int command)
{
  GEM_WINDOW* wnd = GWGetWindowByID( "IBrowser" ) ;
  short       status ;

  if ( wnd )
  {
    ObjectNotifyIBrowser( wnd, command, "FromScript" ) ;
    status = SVCS_SUCCESS ;
  }
  else
  {
    LoggingDo(LL_WARNING, "Unable to find a window with ID IBrowser") ;
    status = SVCS_CMDFAILED ;
  }

  return status ;
}

static short BConvGetData(HINI h_ini, BCONV_PARAMS* bconv_data)
{
  char  err_log[] = "Error on %s in Batch Conv ini file" ;
  char  sname[] = "BatchConv" ;
  char* key ;
  char  buffer[32] ;
  long  status ;

  key = "SrcPath" ;
  status = GetIniKey( h_ini, sname, key, bconv_data->rfile[0].path ) ;
  if ( status == 0 ) { LoggingDo(LL_WARNING, err_log, key) ; return SVCS_INVALIDPARAM ; }

  key = "SrcMask" ;
  status = GetIniKey( h_ini, sname, key, bconv_data->rfile[0].mask ) ;
  if ( status == 0 ) { LoggingDo(LL_WARNING, err_log, key) ; return SVCS_INVALIDPARAM ; }

  key = "SrcRecurse" ;
  strcpy( buffer, "0" ) ; /* Not an error if this key does not exist */
  (void)GetIniKey( h_ini, sname, key, buffer ) ;
  bconv_data->rfile[0].recurse = atoi( buffer ) ;

  key = "OutputFormat" ;
  status = GetIniKey( h_ini, sname, key, buffer ) ;
  if ( status == 0 ) { LoggingDo(LL_WARNING, err_log, key) ; return SVCS_INVALIDPARAM ; }
  bconv_data->inf.lformat = *((IID*)buffer) ;
  LoggingDo(LL_INFO, "BConv outputformat=$%lX (%c%c%c)", bconv_data->inf.lformat, buffer[0], buffer[1], buffer[2]) ;

  if ( bconv_data->inf.lformat == IID_JPEG )
  {
    /* Get quality */
    key = "JPEGQuality" ;
    strcpy( buffer, "90" ) ; /* Default value, not an error if this key does not exist */
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    bconv_data->inf.c.f.jpg.quality = atoi( buffer ) ;
    LoggingDo(LL_INFO, "JPEG quality=%d", bconv_data->inf.c.f.jpg.quality ) ;
  }
  else if ( bconv_data->inf.lformat == IID_TIFF )
  {
    /* Get compression algorithm                         */
    /* Note that for other formats such as GIF, JPG, PNG */
    /* Compression is mandatory and there is no choice   */
    key = "TIFFCompression" ;
    strcpy( buffer, "None" ) ; /* Default value no compression, not an error if this key does not exist */
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    if ( strcmpi(buffer, "lzw") == 0 ) bconv_data->inf.compress = 5 ; /* LZW Compression (TIFF value) */
    else                               bconv_data->inf.compress = 1 ; /* No Compression (TIFF value)  */
    LoggingDo(LL_INFO, "TIFF compression=%s", (bconv_data->inf.compress == 5) ? "LZW":"None" ) ;
  }

  key = "DstPath" ;
  status = GetIniKey( h_ini, sname, key, bconv_data->dst_path ) ;
  if ( status == 0 ) { LoggingDo(LL_WARNING, err_log, key) ; return SVCS_INVALIDPARAM ; }

  key = "ManageSrc" ;
  sprintf( buffer, "%d", MS_DONOTHING ) ;
  (void)GetIniKey( h_ini, sname, key, buffer ) ;
  bconv_data->manage_src = atoi( buffer ) ;
  if ( (bconv_data->manage_src < MS_DONOTHING) || (bconv_data->manage_src > MS_MOVESRC) ) { LoggingDo(LL_WARNING, err_log, key) ; return SVCS_INVALIDPARAM ; }

  if ( bconv_data->manage_src == MS_MOVESRC )
  {
    key = "DstMovePath" ; /* Only if manage_src = MS_MOVESRC */
    status = GetIniKey( h_ini, sname, key, bconv_data->dst_movepath ) ;
    if ( status == 0 ) { LoggingDo(LL_WARNING, err_log, key) ; return SVCS_INVALIDPARAM ; }
  }

  key = "ManageDst" ;
  sprintf( buffer, "%d", MS_DONOTHING ) ;
  (void)GetIniKey( h_ini, sname, key, buffer ) ;
  bconv_data->manage_dst = atoi( buffer ) ;
  if ( (bconv_data->manage_dst < MD_ERASEDST) || (bconv_data->manage_dst > MD_CANCELOPE) ) { LoggingDo(LL_WARNING, err_log, key) ; return SVCS_INVALIDPARAM ; }

  key = "NotCompatibleBehavior" ;
  (void)GetIniKey( h_ini, sname, key, buffer ) ;
  bconv_data->bconv_handle_imcomp = atoi( buffer ) ;
  if ( (bconv_data->bconv_handle_imcomp < 0) || (bconv_data->bconv_handle_imcomp > 1) ) bconv_data->bconv_handle_imcomp = 0 ; /* Dither */

  key = "Resize" ;
  strcpy( buffer, "0" ) ; /* Don't resize by default */
  (void)GetIniKey( h_ini, sname, key, buffer ) ;
  bconv_data->resize = atoi( buffer ) ;

  if ( bconv_data->resize )
  {
    key = "ResizeWidth" ;
    strcpy( buffer, "0" ) ;
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    bconv_data->rwidth = atoi( buffer ) ;
    key = "ResizeHeight" ;
    strcpy( buffer, "0" ) ;
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    bconv_data->rheight = atoi( buffer ) ;
  }


  return SVCS_SUCCESS ;
}

static short CmdBConv(VCMD_SCRIPT* vcmd_script, char* command_line)
{
  char  param[PATH_MAX] ;
  char  inifile[PATH_MAX] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    if ( param[1] != ':' )
    {
      char* last_slash = strrchr( vcmd_script->FileName, '\\' ) ;

      if ( last_slash ) *last_slash = 0 ;
      sprintf( inifile, "%s\\%s", vcmd_script->FileName, param ) ;
      if ( last_slash ) *last_slash = '\\' ;
    }
    else strcpy( inifile, param ) ;
    LoggingDo(LL_DEBUG, "INI file=%s", inifile) ;
    if ( FileExist( inifile ) )
    {
      HINI h_ini = OpenIni( inifile ) ;

      if ( h_ini )
      {
        BCONV_PARAMS bconv_data ;

        memset( &bconv_data, 0, sizeof(BCONV_PARAMS) ) ;
        status = BConvGetData( h_ini, &bconv_data ) ;
        CloseIni( h_ini ) ;
        if ( status == SVCS_SUCCESS ) traite_batch_conversion( &bconv_data ) ;
      }
    }
    else status = SVCS_FILENOEXIST ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdIPSet(char* command_line)
{
  char  param[32] ;
  short status ;

  status = GetParam( command_line, 1, param ) ;
  if ( status == 0 )
  {
    char img_prio[32] ;
    int  i, j ;

    memset( img_prio, 0, sizeof(img_prio) ) ;
    /* Remove characters other than available MST_xxx */
    i = j = 0 ;
    while ( param[i] && (j < sizeof(img_prio) ) )
    {
      if ( (param[i] >= MST_LDI) && (param[i] < (MST_LDI+NB_MST_MAX)) ) img_prio[j++] = param[i] ;
      i++ ;
    }
    DImgSetPriorities( img_prio ) ;
    status = SVCS_SUCCESS ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short get_val_or_pc(char* buf, short ref)
{
  char* pc = strchr( buf, '%' ) ;
  short val ;

  if ( pc )
  {
    *pc = 0 ;
    val = (short) (((long)ref * (long)atoi(buf))/ 100L) ;
    *pc = '%' ;
  }
  else val = atoi( buf ) ;

  return val ;
}

static short LoadLDVParams(char* script_filename, char* inifile, VXIMAGE* vimage, LDV_PARAMS* ldv_params)
{
  HINI  h_ini ;
  short status ;
  int   i, w, h ;
  char  sname[] = "LDVParams" ;
  char  kname[] = "Parameter0" ;
  char* key ;
  char* last_slash ;
  char  buffer[PATH_MAX] ;

  w = vimage->inf_img.mfdb.fd_w ;
  h = vimage->inf_img.mfdb.fd_h ;
  strcpy( buffer, inifile ) ;
  if ( !FileExist( buffer ) )
  {
    last_slash = strrchr( script_filename, '\\' ) ;
    if ( last_slash ) *last_slash = 0 ;
    sprintf( buffer, "%s\\%s", script_filename, inifile ) ; /* Let's try file local to script */
    if ( last_slash ) *last_slash = '\\' ;
  }
  if ( !FileExist( buffer ) ) return SVCS_FILENOEXIST ;

  h_ini = OpenIni( buffer ) ;
  if ( h_ini )
  {
    strcpy( buffer, "0" ) ;
    key = "x1" ;
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    ldv_params->x1 = get_val_or_pc(buffer, w) ;

    sprintf( buffer, "%d", w-1 ) ;
    key = "x2" ;
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    ldv_params->x2 = get_val_or_pc(buffer, w) ;

    strcpy( buffer, "0" ) ;
    key = "y1" ;
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    ldv_params->y1 = get_val_or_pc(buffer, h) ;

    sprintf( buffer, "%d", h-1 ) ;
    key = "y2" ;
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    ldv_params->y2 = get_val_or_pc(buffer, h) ;

    /* Read parameters as long as there are */
	  for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
    {
      kname[sizeof(kname)-2] = '1'+i ;
      status = GetIniKey( h_ini, sname, kname, buffer ) ;
      LoggingDo(LL_DEBUG, "(%s,%s) P%d=%s (ret %d)", sname, kname, i+1, buffer, status) ;
      if ( status == 0 ) break ;
      ldv_params->Param[i].s = atoi(buffer) ;
      ldv_params->NbParams++ ;
    }

    CloseIni( h_ini ) ;
  }
  else return SVCS_INVALIDPARAM ;

  return SVCS_SUCCESS ;
}

static void check_blockbounds(short* val, short max)
{
  if ( *val < 0 ) *val = 0 ;
  if ( *val > max ) *val = max ;
}

static short CmdLDVDo(VCMD_SCRIPT* vcmd_script, char* command_line, int parameters_from_ini)
{
  GEM_WINDOW* wnd ;
  VXIMAGE*    vimage ;
  LDV_PARAMS  ldv_params ;
  LDV_MODULE  ldv_module ;
  LDV_STATUS  ldv_status ;
  char        ldvparams_fname[PATH_MAX] ;
  char        ldv_fname[PATH_MAX] ;
  char        buffer[PATH_MAX] ;
  char        filename[PATH_MAX] ;
  short       i, status ;

  status = GetParam( command_line, 1, filename ) ;
  if ( status != 0 ) return SVCS_MISSINGP1 ;
  wnd = GWGetWindowByID( filename ) ;
  if ( !wnd ) { LoggingDo(LL_WARNING, "Unable to find a window with ID %s", filename) ; return SVCS_CMDFAILED ; }
  vimage = wnd->Extension ;
  if ( vimage == NULL ) { LoggingDo(LL_WARNING, "Invalid image data in window $%p", wnd) ; return SVCS_CMDFAILED ; }

  status = GetParam( command_line, 2, ldv_fname ) ;
  if ( status != 0 ) return SVCS_MISSINGP2 ;

  memset( &ldv_params, 0, sizeof(LDV_PARAMS) ) ;
  LoggingDo(LL_DEBUG, "Loading LDV parameters from %s", parameters_from_ini ? "INI file":"command line") ;
  if ( parameters_from_ini )
  {
    status = GetParam( command_line, 3, ldvparams_fname ) ;
    if ( status != 0 ) return SVCS_MISSINGP3 ;

    status = LoadLDVParams( vcmd_script->FileName, ldvparams_fname, vimage, &ldv_params ) ;
    if ( status != SVCS_SUCCESS ) return status ;
  }
  else
  {
    /* Full image to be processed */
    ldv_params.x1 = 0 ;
    ldv_params.x2 = vimage->inf_img.mfdb.fd_w-1 ;
    ldv_params.y1 = 0 ;
    ldv_params.y2 = vimage->inf_img.mfdb.fd_h-1 ;
    for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
    {
      status = GetParam( command_line, 3+i, buffer ) ;
      if ( status != 0 ) break ;
      if ( sscanf( buffer, "%d", &ldv_params.Param[i].s ) != 1 )
      {
        ldv_params.ParamType[i] = LDVT_FILE ; /* Assume passed parameter is a file name */
        ldv_params.Param[i].str = Xstrdup( buffer ) ; /* Parameter is not a number */
      }
      ldv_params.NbParams++ ;
    }
  }

  memset( &ldv_module, 0, sizeof(LDV_MODULE) ) ;
  ldv_module.FileName = ldv_fname ;
  /* Check block data before passing them */
  check_blockbounds( &ldv_params.x1, (short)vimage->inf_img.mfdb.fd_w-1 ) ; check_blockbounds( &ldv_params.x2, (short)vimage->inf_img.mfdb.fd_w-1 ) ;
  check_blockbounds( &ldv_params.y1, (short)vimage->inf_img.mfdb.fd_h-1 ) ; check_blockbounds( &ldv_params.y2, (short)vimage->inf_img.mfdb.fd_h-1 ) ;
  ldv_status = LDVLoadFunctions( config.path_ldv, &ldv_module ) ;
  if ( LDV_SUCCESS( ldv_status ) )
  {
    ldv_status = do_ldv( &ldv_module, wnd, &ldv_params ) ;
    status     = LDV_SUCCESS(ldv_status) ? SVCS_SUCCESS:SVCS_CMDFAILED ;
    LoggingDo(LL_DEBUG, "LDV operation returned %ld", ldv_status) ;
    LDVUnloadFunctions( &ldv_module ) ;
  }
  else { LoggingDo(LL_WARNING, "Can't init LDV %s, error %ld", ldv_status) ; status = SVCS_CMDFAILED ; }

  LDVFreeDynParams( &ldv_params ) ;

  return status ;
}

static short ExeCommandLine(VCMD_SCRIPT* vcmd_script, char* command_line)
{
  short status ;

  status = GetCmd( command_line ) ;
  switch( status )
  {
    case CMD_QUIT:    status = SVCS_EXITREQUEST ;
                      break ;
    case CMD_COMMENT: status = SVCS_SUCCESS ;
                      break ;
    case CMD_OPEN:    status = CmdOpen( command_line ) ;
                      break ;
    case CMD_CLOSE:   status = CmdClose( command_line ) ;
                      break ;
    case CMD_WAIT:    status = CmdWait( vcmd_script, command_line ) ;
                      break ;
    case CMD_LOOP:    status = CmdLoop( vcmd_script, command_line ) ;
                      break ;
    case CMD_ENDLOOP: status = CmdEndLoop( vcmd_script ) ;
                      break ;
    case CMD_RSCRIPT: status = CmdRScript( vcmd_script, command_line ) ;
                      break ;
    case CMD_CATCRE:  status = CmdCatCre( command_line ) ;
                      break ;
    case CMD_CATAFI:  status = CmdCatAfi( command_line ) ;
                      break ;
    case CMD_CATAFO:  status = CmdCatAfo( command_line ) ;
                      break ;
    case CMD_CATOICN: status = CmdCatOIcn( command_line ) ;
                      break ;
    case CMD_CATSINI: status = CmdCatSIni( command_line ) ;
                      break ;
    case CMD_IBOPEN:  status = CmdIBOpen( command_line ) ;
                      break ;
    case CMD_IBNEXT:  status = CmdIBMove( IMGB_NEXT ) ;
                      break ;
    case CMD_IBPREV:  status = CmdIBMove( IMGB_PREVIOUS ) ;
                      break ;
    case CMD_BCONV:   status = CmdBConv( vcmd_script, command_line ) ;
                      break ;
    case CMD_IPSET:   status = CmdIPSet( command_line ) ;
                      break ;
    case CMD_LDVDO:   status = CmdLDVDo( vcmd_script, command_line, 0 ) ; /* LDV parameters from command line */
                      break ;
    case CMD_LDVDOIP: status = CmdLDVDo( vcmd_script, command_line, 1 ) ; /* LDV Parameters from INI */
                      break ;
    default:          status = SVCS_UNKNOWNCMD ;
                      break ;
  }

  return status ;
}

short ExeNextCommandLine(VCMD_SCRIPT* vcmd_script)
{
  VCMD_SCRIPT* parent_script = NULL ;
  VCMD_SCRIPT* original_vcmd_script = vcmd_script ;
  short        ret = SVCS_SUCCESS ;

  /* Find the child being ran */
  while ( (vcmd_script->Magic == VCS_MAGIC) && vcmd_script->ChildScript )
  {
    parent_script = vcmd_script ;
    vcmd_script   = vcmd_script->ChildScript ;
  }

  if ( vcmd_script->Magic != VCS_MAGIC ) return SVCS_CMDFAILED ;

  if ( vcmd_script->Buffer )
  {
    char buffer[768] ;

    vcmd_script->ScriptContext = original_vcmd_script ;
    ret = GetNextLine( vcmd_script, buffer, sizeof(buffer) ) ; 
    if ( ret != SVCS_SUCCESS )
    {
      LoggingDo(LL_INFO, "Script %s returned with %d, parent=%p", vcmd_script->FileName, ret, parent_script ) ;
      FreeScript( vcmd_script ) ;
      if ( parent_script )
      {
        Xfree( parent_script->ChildScript ) ;
        parent_script->ChildScript = NULL ;
        ret                        = SVCS_SUCCESS ;
      }
    }
    else
    {
      char* ln = buffer ;
      char* c ;

      /* Filter out spaces and tabulations at start */
      while ( (*ln == ' ') || (*ln == '\t') ) ln++ ;

      /* Remove CR/LF */
      c = ln ;
      while ( *c )
        if ( (*c == '\r') || (*c == '\n') ) *c = 0 ;
        else                                 c++ ;
      if ( strlen(ln) >= 4 )
      {
        LoggingDo(LL_INFO, "Executing Command line: %s", ln) ;
        ret = ExeCommandLine( vcmd_script, ln ) ;
        if ( ret == SVCS_EXITREQUEST ) FreeScript( original_vcmd_script ) ;
      }
      else ret = SVCS_SUCCESS ; /* Probably dummy characters, just ignore */
    }
  }
  else ret = SVCS_FILENOEXIST ;

  return ret ;
}
