/*************************************/
/* VCSCRIPT.C: VISION Command Script */
/*************************************/
#include <stdio.h>
#include <string.h>
#include "..\tools\logging.h"
#include "..\tools\gwindows.h"
#include "..\tools\frecurse.h"
#include "..\tools\rasterop.h"
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

typedef short (*VCS_CMD_FUNC)(VCMD_SCRIPT* vcmd_script) ;
typedef struct _COMMAND_LABEL_IDS
{
  char*        Label ;
  VCS_CMD_FUNC CmdFunc ;
}
COMMAND_LABEL_IDS, *PCOMMAND_LABEL_IDS ;

typedef struct _GLOBAL_FUNCTION
{
  char*   Name ;
  short   NameLength ;
  short (*FunctionCall)(VCMD_SCRIPT* vcmd_script, char* parameters, char* result) ; 
}
GLOBAL_FUNCTION, *PGLOBAL_FUNCTION ;

short GF_LFAdjustDest(VCMD_SCRIPT* vcmd_script, char* parameters, char* result) ;
GLOBAL_FUNCTION GlobalFunctions[] = {
                                      { "LFAdjustDest", sizeof("LFAdjustDest")-1, GF_LFAdjustDest }
                                    } ;

/* As GetParam and FunctionCallCheck are mutually recursive, need to prototype one in advance */
static short FunctionCallCheck(VCMD_SCRIPT* vcmd_script, char* param) ;


static void LoggingDoNoWindowID(char* id)
{
  LoggingDo(LL_WARNING, "Unable to find a window with ID %s", id) ;
}

static void FreeGlobalVariable(GLOBAL_VARIABLE* gv)
{
  if ( gv->Value ) Xfree( gv->Value ) ;
  gv->Value   = NULL ;
  gv->ValLen  = 0 ;
  gv->Name[0] = 0 ;
}

static GLOBAL_VARIABLE* GetGlobalVariable(VCMD_SCRIPT* vcmd_script, char* var_name)
{
  GLOBAL_VARIABLE* gv ;

  for ( gv = &vcmd_script->GlobalVariable[0]; gv < &vcmd_script->GlobalVariable[NB_GLOBAL_VARIABLE]; gv++ )
  {
    if ( strcmpi( gv->Name, var_name ) == 0 )
      return gv ;
  }

  return NULL ;
}

static void DeleteGlobalVariable(VCMD_SCRIPT* vcmd_script, char* var_name)
{
  GLOBAL_VARIABLE* gv = GetGlobalVariable( vcmd_script, var_name ) ;

  if ( gv ) FreeGlobalVariable( gv ) ;
}

static short ModifyGlobalVariable(VCMD_SCRIPT* vcmd_script, char* var_name, char* new_val)
{
  GLOBAL_VARIABLE* gv = GetGlobalVariable( vcmd_script, var_name ) ;
  short            len ;

  if ( gv == NULL ) return SVCS_UNKNOWNVARIABLE ;

  len = (short)strlen( new_val ) ;
  if ( len > gv->ValLen )
  {
    Xfree( gv->Value ) ;
    gv->Value = Xstrdup( new_val ) ;
    if ( gv->Value == NULL )
    {
      FreeGlobalVariable( gv ) ;
      return SVCS_NOMEMORY ;
    }
    gv->ValLen = len ;
  }
  else strcpy( gv->Value, new_val ) ;

  return SVCS_SUCCESS ;
}

static short AddGlobalVariable(VCMD_SCRIPT* vcmd_script, char* var_name, char* var_val)
{
  GLOBAL_VARIABLE* gv ;
  short            status = SVCS_VARARRAYFULL ;

  if ( strlen(var_name) > sizeof(vcmd_script->GlobalVariable[0].Name)-1 ) return SVCS_VARNAMETOOBIG ;

  for ( gv = &vcmd_script->GlobalVariable[0]; gv < &vcmd_script->GlobalVariable[NB_GLOBAL_VARIABLE]; gv++ )
  {
    if ( gv->Name[0] == 0 )
    {
      short len = (short) strlen(var_val) ;

      if ( len ) gv->Value = Xstrdup( var_val ) ;
      else       { len = 15 ; gv->Value = Xcalloc( 1, len+1 ) ; }
      if ( gv->Value )
      {
        gv->ValLen = len ;
        strcpy( gv->Name, var_name ) ;
        return SVCS_SUCCESS ;
      }
      else return SVCS_NOMEMORY ;
    }
  }

  return status ;
}

void FreeScript(VCMD_SCRIPT* vcmd_script)
{
  GLOBAL_VARIABLE* gv ;

  if ( vcmd_script->ChildScript )
  {
    FreeScript( vcmd_script->ChildScript ) ;
    Xfree( vcmd_script->ChildScript ) ;
  }
  if ( vcmd_script->Buffer ) Xfree( vcmd_script->Buffer ) ;
  if ( vcmd_script->PtrLines ) Xfree( vcmd_script->PtrLines ) ;

  for ( gv = &vcmd_script->GlobalVariable[0]; gv < &vcmd_script->GlobalVariable[NB_GLOBAL_VARIABLE]; gv++ )
    FreeGlobalVariable( gv ) ;

  memzero( vcmd_script, sizeof(VCMD_SCRIPT) ) ;
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
  memzero( vcmd_script, sizeof(VCMD_SCRIPT) ) ;
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

static short GetParams(char* str, char separator, char** pparams, short nb_pparams)
{
  char* sep ;
  short nb_params = 0 ;

  str = ignore_spaces( str ) ;
  if ( *str == 0 ) return nb_params ;

  do
  {
    pparams[nb_params++] = str ;
    sep = strchr( str, separator ) ;
    if ( sep )
    {
      *sep = 0 ;
      str  = ignore_spaces( 1+sep ) ;
    }
  }
  while ( *str && sep && (nb_params < nb_pparams) ) ;
  
  return nb_params ;
}

static short GetGlobalVariableValue(VCMD_SCRIPT* vcmd_script, char* param)
{
  /* Input parameter param starts with $ and return value will contain global variable value */
  GLOBAL_VARIABLE* gv ;
  short            status = SVCS_UNKNOWNVARIABLE ;

  for ( gv = &vcmd_script->GlobalVariable[0]; gv < &vcmd_script->GlobalVariable[NB_GLOBAL_VARIABLE]; gv++ )
  {
    if ( strcmpi( &param[1], gv->Name ) == 0 )
      if ( gv->Value )
      {
        strcpy( param, gv->Value ) ;
        status = SVCS_SUCCESS ;
      }
  }

  return status ;
}

static short GetParamT(VCMD_SCRIPT* vcmd_script, char* in_param, char* out_param)
{
  short status ;

  out_param[0] = 0 ;
  strcpy( out_param, in_param ) ;
  if ( out_param[0] == '$' ) status = GetGlobalVariableValue( vcmd_script, out_param ) ;
  else                       status = FunctionCallCheck( vcmd_script, out_param ) ;

  LoggingDo(LL_DEBUG, "GetParam(%s) returns %d, param=%s", in_param, status, out_param) ;
  return status ;
}

static short GF_LFAdjustDest(VCMD_SCRIPT* vcmd_script, char* parameters, char* result)
{
  char  local_params[PATH_MAX] ;
  char* pparams[3] ;
  short nb_params ;
  short err ;

  strcpy( local_params, parameters ) ;
  nb_params = GetParams( local_params, ',', pparams, ARRAY_SIZE(pparams) ) ;
  if ( nb_params == 3 )
  {
    /* Adjust destination file to allow copy with the same structure as the original, e.g.: */
    /* StartFolder(param1): H:\PURE_C\PROJECTS\VISION\IMGTEST                               */
    /* CurrentFile(param2): H:\PURE_C\PROJECTS\VISION\IMGTEST\TGA\MARBLES.TIF               */
    /* DestPath(param3):    H:\PURE_C\PROJECTS\VISION\TEMP                                  */
    /* Result:              H:\PURE_C\PROJECTS\VISION\TEMP\TGA\MARBLES.TIF                  */
    char p0[PATH_MAX], p1[PATH_MAX] ;
    char *s, *d ;

    if ( (GetParamT( vcmd_script, pparams[0], p0 ) == 0) && (GetParamT( vcmd_script, pparams[1], p1 ) == 0) )
    {
      s = p0 ;
      d = p1 ;
      while ( *s == *d ) { s++; d++; } ;
      sprintf( result, "%s%s", pparams[2], d ) ;
      err = 0 ;
    }
    else err = -2 ;
  }
  else err = -1 ;

  return err ;
}

static short FunctionCallCheck(VCMD_SCRIPT* vcmd_script, char* param)
{
  short status = 0 ; /* This is not a function call */
  short i ;

  for ( i = 0; i < ARRAY_SIZE(GlobalFunctions); i++ )
  {
    if ( memcmp( param, GlobalFunctions[i].Name, GlobalFunctions[i].NameLength ) == 0 )
    {
      char* start_parenthesis = &param[GlobalFunctions[i].NameLength] ;

      if ( *start_parenthesis == '(' )
      {
        char* end_parenthesis = strchr( start_parenthesis, ')' ) ;

        if ( end_parenthesis )
        {
          char result[PATH_MAX] ;

          *end_parenthesis = 0 ;
          result[0]        = 0 ;
          LoggingDo(LL_DEBUG, "Run VCS function %s with %s...", GlobalFunctions[i].Name, 1+start_parenthesis) ;
          status = GlobalFunctions[i].FunctionCall( vcmd_script, 1+start_parenthesis, result ) ;
          LoggingDo(LL_DEBUG, "VCS Function returned %d, result %s", status, result) ;
          if ( status == 0 ) strcpy( param, result ) ;
          else               *end_parenthesis = ')' ; /* Restore original parameter line */
        }
      }
    }
  }

  return status ;
}

static short GetParam(VCMD_SCRIPT* vcmd_script, short param_no, char* param)
{
  short status ;

  param_no-- ;
  if ( param_no < vcmd_script->nparams ) status = GetParamT( vcmd_script, vcmd_script->params[param_no], param ) ;
  else                                   status = -1 ;

  LoggingDo(LL_DEBUG, "GetParam(%d) returns %d, param=%s", param_no, status, status ? "":param) ;
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

  memzero( buffer, buffer_size ) ;
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
    else strncpy( full_name, name, sizeof(full_name)-1 ) ;
  }

  ret = LoadScriptInMemory( full_name, child_script ) ;
  if ( ret != SVCS_SUCCESS ) Xfree( child_script ) ;
  else                       vcmd_script->ChildScript = child_script ;

  return ret ;
}

static short CmdOpen(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 )
  {
    GemApp.OnOpenFile( param ) ;
    status = SVCS_SUCCESS ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdClose(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 )
  {
    GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

    if ( wnd )
    {
      char param2[PATH_MAX] ;

      if ( (GetParam( vcmd_script, 2, param2 ) == 0) &&
           (strcmpi(param2, "nosave") == 0) )
      {
        VXIMAGE* vimage = (VXIMAGE*) wnd->Extension ;

        vimage->modif = 0 ;
      }
      PostMessage( wnd, WM_CLOSED, NULL ) ;
      status = SVCS_SUCCESS ;
    }
    else
    {
      LoggingDoNoWindowID( param ) ;
      status = SVCS_CMDFAILED ;
    }
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdWait(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
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

static short CmdLoop(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
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
        status                    = SVCS_SUCCESS ;
      }
      else
      {
        loop_data->NbLoopsToGo = 0 ;
        status                 = SVCS_LOOPINVALID ;
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

static short CmdCatCre(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
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

static short CmdCatAfi(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  char  param2[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 )
  {
    status = GetParam( vcmd_script, 2, param2 ) ;
    if ( status == 0 )
    {
      GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

      if ( wnd ) { ObjectNotifyAlb( wnd, ALBUM_ADDIMG, param2 ) ; status = SVCS_SUCCESS ; }
      else
      {
        LoggingDoNoWindowID( param ) ;
        status = SVCS_CMDFAILED ;
      }
    }
    else status = SVCS_MISSINGP2 ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdCatAfo(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  char  param2[PATH_MAX] ;
  char  param3[32] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 )
  {
    status = GetParam( vcmd_script, 2, param2 ) ;
    if ( status == 0 )
    {
      GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

      if ( wnd )
      {
        RFILE rfiles[NB_MAX_RFILES] ; /* We will use only first one but ObjectNotifyAlb assumes NB_MAX_RFILES */
        char* last_slash ;

        memzero( rfiles, NB_MAX_RFILES*sizeof(RFILE) ) ;
        status = GetParam( vcmd_script, 3, param3 ) ;
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
        LoggingDoNoWindowID( param ) ;
        status = SVCS_CMDFAILED ;
      }
    }
    else status = SVCS_MISSINGP2 ;
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdCatOIcn(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
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
      LoggingDoNoWindowID( param ) ;
      status = SVCS_CMDFAILED ;
    }
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdCatSIni(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  char  param2[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 )
  {
    status = GetParam( vcmd_script, 2, param2 ) ;
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
              memzero( catalog_header->cat_inifile, sizeof(catalog_header->cat_inifile) ) ;
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
          LoggingDoNoWindowID( param ) ;
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

static short CmdRScript(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 ) status = LoadChildScript( vcmd_script, param ) ;
  else               status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdIBOpen(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
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
      LoggingDoNoWindowID( "IBrowser" ) ;
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
    LoggingDoNoWindowID( "IBrowser" ) ;
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

static short CmdBConv(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  char  inifile[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
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
    LoggingDo(LL_DEBUG, "CmdBConv INI file=%s", inifile) ;
    if ( FileExist( inifile ) )
    {
      HINI h_ini = OpenIni( inifile ) ;

      if ( h_ini )
      {
        BCONV_PARAMS bconv_data ;

        memzero( &bconv_data, sizeof(BCONV_PARAMS) ) ;
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

static short CmdIPSet(VCMD_SCRIPT* vcmd_script)
{
  char  param[32] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 )
  {
    char img_prio[32] ;
    int  i, j ;

    memzero( img_prio, sizeof(img_prio) ) ;
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
    val = (short) (((long)ref * (long)atoi(buf))/100L) ;
    *pc = '%' ;
  }
  else val = atoi( buf ) ;

  return val ;
}

static short LoadLDVParams(char* script_filename, char* inifile, MFDB* mfdb, LDV_PARAMS* ldv_params)
{
  HINI  h_ini ;
  short status ;
  int   i, w, h ;
  char  sname[] = "LDVParams" ;
  char  kname[] = "Parameter0" ;
  char* key ;
  char* last_slash ;
  char  buffer[PATH_MAX] ;

  w = mfdb->fd_w ;
  h = mfdb->fd_h ;
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
    ldv_params->x1 = get_val_or_pc( buffer, w ) ;

    sprintf( buffer, "%d", w-1 ) ;
    key = "x2" ;
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    ldv_params->x2 = get_val_or_pc( buffer, w ) ;

    strcpy( buffer, "0" ) ;
    key = "y1" ;
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    ldv_params->y1 = get_val_or_pc( buffer, h ) ;

    sprintf( buffer, "%d", h-1 ) ;
    key = "y2" ;
    (void)GetIniKey( h_ini, sname, key, buffer ) ;
    ldv_params->y2 = get_val_or_pc( buffer, h ) ;

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

static short CmdLDVDo(VCMD_SCRIPT* vcmd_script, int parameters_from_ini)
{
  GEM_WINDOW* wnd = NULL ;
  MFDB*       mfdb = NULL ;
  LDV_CAPS*   caps ;
  LDV_IMAGE   ldv_img ;
  LDV_PARAMS  ldv_params ;
  LDV_MODULE  ldv_module ;
  LDV_STATUS  ldv_status ;
  char        ldvparams_fname[PATH_MAX] ;
  char        ldv_fname[PATH_MAX] ;
  char        buffer[PATH_MAX] ;
  char        filename[PATH_MAX] ;
  short       i, status ;

  status = GetParam( vcmd_script, 1, filename ) ;
  if ( status != 0 ) return SVCS_MISSINGP1 ;

  if ( memcmp( filename, "-f:", 3 ) )
  {
    /* We want to work from the window with this name */
    wnd = GWGetWindowByID( filename ) ;
    if ( !wnd ) { LoggingDoNoWindowID( filename ) ; return SVCS_CMDFAILED ; }
    else
    {
      VXIMAGE* vimage = wnd->Extension ;

      if ( vimage == NULL ) { LoggingDo(LL_WARNING, "Invalid image data in window $%p", wnd) ; return SVCS_CMDFAILED ; }
      mfdb = &vimage->inf_img.mfdb ;
    }
  }

  status = GetParam( vcmd_script, 2, ldv_fname ) ;
  if ( status != 0 ) return SVCS_MISSINGP2 ;

  memzero( &ldv_module, sizeof(LDV_MODULE) ) ;
  ldv_module.FileName = ldv_fname ;
  ldv_status          = LDVLoadFunctions( config.path_ldv, &ldv_module ) ;
  if ( !LDV_SUCCESS( ldv_status ) ) { LoggingDo(LL_ERROR, "Can't init LDV %s, error %ld", ldv_status) ; return SVCS_CMDFAILED ; }

  caps = LDVGetNPlanesCaps( &ldv_module, screen.fd_nplanes ) ;
  if ( wnd == NULL )
  {
    strcpy( buffer, &filename[3] ) ;
    if ( buffer[0] == '$' ) GetGlobalVariableValue( vcmd_script, buffer ) ;
    /* We need to know image information for checking against parameters */
    status = (short)ImGetInf( buffer, &ldv_img ) ;
    if ( status == EIMG_SUCCESS )
    {
      caps = LDVGetNPlanesCaps( &ldv_module, ldv_img.Raster.fd_nplanes ) ;
      if ( caps == NULL )
      {
        ImFree( &ldv_img ) ;
        status = SVCS_CMDFAILED ;
      }
      else
      {
        ldv_img.RasterFormat = (caps->Flags & LDVF_ATARIFORMAT) ? LDVF_ATARIFORMAT:LDVF_SPECFORMAT ;
        mfdb                 = &ldv_img.Raster ;
        /* Information reported by ImGetInf may be changed when loading image */
        /* To fit into the minimum size, so better adjust now else DoLDV will */
        /* Think we want to work on a selection                               */
        if ( mfdb->fd_w < MINIW ) mfdb->fd_w = MINIW ;
        if ( mfdb->fd_h < MINIH ) mfdb->fd_h = MINIH ;
      }
    }
    else
    {
      if ( status == EIMG_FILENOEXIST ) status = SVCS_FILENOEXIST ;
      else                              status = SVCS_IMGLOADERROR ;
    }
    if ( status != SVCS_SUCCESS )
    {
      LDVUnloadFunctions( &ldv_module ) ;
      return status ;
    }
  }

  memzero( &ldv_params, sizeof(LDV_PARAMS) ) ;
  LoggingDo(LL_DEBUG, "Loading LDV parameters from %s", parameters_from_ini ? "INI file":"command line") ;
  if ( parameters_from_ini )
  {
    status = GetParam( vcmd_script, 3, ldvparams_fname ) ;
    if ( status != 0 )
    {
      LDVUnloadFunctions( &ldv_module ) ;
      if ( wnd == NULL ) ImFree( &ldv_img ) ;
      return SVCS_MISSINGP3 ;
    }

    status = LoadLDVParams( vcmd_script->FileName, ldvparams_fname, mfdb, &ldv_params ) ;
    if ( status != SVCS_SUCCESS )
    {
      LDVUnloadFunctions( &ldv_module ) ;
      if ( wnd == NULL ) ImFree( &ldv_img ) ;
      return status ;
    }
  }
  else
  {
    /* Full image to be processed */
    ldv_params.x1 = 0 ;
    ldv_params.x2 = mfdb->fd_w-1 ;
    ldv_params.y1 = 0 ;
    ldv_params.y2 = mfdb->fd_h-1 ;
    for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
    {
      status = GetParam( vcmd_script, 3+i, buffer ) ;
      if ( status != 0 ) break ;
      if ( sscanf( buffer, "%d", &ldv_params.Param[i].s ) != 1 )
      {
        ldv_params.ParamType[i] = LDVT_FILE ; /* Assume passed parameter is a file name */
        ldv_params.Param[i].str = Xstrdup( buffer ) ; /* Parameter is not a number */
      }
      ldv_params.NbParams++ ;
    }
  }

  /* Check block data before passing them */
  check_blockbounds( &ldv_params.x1, (short)mfdb->fd_w-1 ) ; check_blockbounds( &ldv_params.x2, (short)mfdb->fd_w-1 ) ;
  check_blockbounds( &ldv_params.y1, (short)mfdb->fd_h-1 ) ; check_blockbounds( &ldv_params.y2, (short)mfdb->fd_h-1 ) ;
  (void)LDVCreateProgWindow( caps->Flags ) ;
  if ( wnd )
  {
    /* Image source comes from an open window                               */
    /* Number of planes of the image is same number of planes of the screen */
    ldv_status = do_ldv( &ldv_module, wnd, &ldv_params, LDVDOF_PROGLFOUT ) ;
    status     = LDV_SUCCESS(ldv_status) ? SVCS_SUCCESS:SVCS_CMDFAILED ;
  }
  else
  {
    /* Image source comes from a file                    */
    /* Number of planes of the image comes from the file */
    status = ImLoad( &ldv_img ) ;
    if ( status == EIMG_SUCCESS )
    {
      ldv_status = LDVDo( &ldv_module, &ldv_params, &ldv_img, LDVDOF_PROGLFOUT ) ;
      if ( LDV_SUCCESS(ldv_status) )
      {
        INFO_IMAGE* inf = (INFO_IMAGE*) ldv_img.Context ;

        if ( inf )
        {
          /* Old INFO_IMAGE raster no longer exists as LDVDo freed it, let's unreference it */
          ZeroMFDB( &inf->mfdb ) ;
          inf->palette = NULL ;
        }
        /* And free LDV raster memory and palette if any */
        if ( ldv_img.Raster.fd_addr ) Xfree( ldv_img.Raster.fd_addr ) ;
        if ( ldv_img.Palette.Pal ) Xfree( ldv_img.Palette.Pal ) ;
        status = SVCS_SUCCESS ;
      }
      else if ( ldv_status == ELDV_CANCELLED) status = SVCS_NOMORECMD ;
      else                                    status = SVCS_CMDFAILED ;
    }
    else if ( status == EIMG_USERCANCELLED) status = SVCS_NOMORECMD ;
    else                                    status = SVCS_CMDFAILED ;
    ImFree( &ldv_img ) ;
  }
  LoggingDo(LL_DEBUG, "LDV operation returned %ld", ldv_status) ;
  LDVUnloadFunctions( &ldv_module ) ;

  LDVFreeDynParams( &ldv_params ) ;
  vcmd_script->LastCmdLDVDoCall = clock() ;

  return status ;
}

static char* GetLFLogFileName(void)
{
  static char log_file[PATH_MAX] ;

  if ( log_file[0] == 0 ) sprintf( log_file, "%s\\vcsldir.txt", config.path_temp ) ;

  return log_file ;
}

static short LFGetNextEntry(VCMD_SCRIPT* vcmd_script, char* entry )
{
  short status ;

  entry[0] = 0 ;
  status = ( fgets( entry, PATH_MAX, vcmd_script->LoopFolderData.FileList ) == NULL ) ? SVCS_NOMOREDATA:SVCS_SUCCESS ;
  if ( status == SVCS_SUCCESS ) removeCRCF( entry ) ;

  return status ;
}

static short CmdLoopFolder(VCMD_SCRIPT* vcmd_script)
{
  char  path[PATH_MAX] ;
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, path ) ;
  if ( status == 0 )
  {
    char       entry[PATH_MAX] ;
    LOOP_DATA* loop_data = &vcmd_script->LoopFolderData.Loop ;
    FR_DATA    fr_data ;
    char       mask[32] = { '*', '.', '*', 0 } ; /* All files by default */
    short      i, recurse = 0 ;

    for ( i = 2; i <= 3; i++ )
    {
      status = GetParam( vcmd_script, i, param ) ;
      if ( status == 0 )
      {
        if ( strcmpi( param, "recurse" ) == 0 ) recurse = 1 ;
        else                                    strcpy( mask, param ) ;
      }
    }

    fr_data.flags     = GetLongFileNamesStatus() ;
    fr_data.path      = path ;
    fr_data.mask      = mask ;
    fr_data.log_file  = GetLFLogFileName() ;
    fr_data.user_func = NULL ;
    fr_data.user_data = 0;

    /* Build the file list */
    mouse_busy() ;
    if ( recurse ) LoggingDo(LL_INFO, "CmdLoopFolder: building file list in %s...", path) ;
    loop_data->NbLoopsToGo = (short)count_files( recurse, &fr_data ) ;
    mouse_restore() ;
    if ( loop_data->NbLoopsToGo > 0 )
    {
      loop_data->StartLoopIndex            = vcmd_script->LineIndex ; /* Next line for LinePtr array */
      loop_data->LoopIndex                 = 0 ;
      vcmd_script->LoopFolderData.FileList = fopen( GetLFLogFileName(), "rb" ) ;
      if ( vcmd_script->LoopFolderData.FileList && (AddGlobalVariable( vcmd_script, "LFStartFolder", path ) == 0) )
      {
        if ( AddGlobalVariable( vcmd_script, "LFCurrentFile", "" ) == 0 )
        {
          status = LFGetNextEntry( vcmd_script, entry ) ;
          if ( status == SVCS_SUCCESS ) status = ModifyGlobalVariable( vcmd_script, "LFCurrentFile", entry ) ;
          if ( status == 0 ) status = SVCS_SUCCESS ;
          else
          {
            LoggingDo(LL_WARNING, "CmdLoopFolder: no entry in file list") ;
            loop_data->NbLoopsToGo = 0 ;
          }
        }
        else LoggingDo(LL_WARNING, "CmdLoopFolder: can't add/modify global variable") ;
      }
      else
      {
        LoggingDo(LL_WARNING, "CmdLoopFolder: can't load file list or add global variable") ;
        loop_data->NbLoopsToGo = 0 ;
        status                 = SVCS_FILENOEXIST ;
      }
    }
    else
    {
      loop_data->NbLoopsToGo = 0 ;
      status                 = SVCS_LOOPINVALID ;
      LoggingDo(LL_WARNING, "CmdLoopFolder: no file to process") ;
    }
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short CmdEndLoopFolder(VCMD_SCRIPT* vcmd_script)
{
  LOOP_DATA* loop_data = &vcmd_script->LoopFolderData.Loop ;
  char       entry[PATH_MAX] ;
  short      status = SVCS_SUCCESS ;

  if ( loop_data->NbLoopsToGo > 0 )
  {
    loop_data->LoopIndex++ ;
    LoggingDo(LL_DEBUG, "LoopFolder status: %d/%d", loop_data->LoopIndex, loop_data->NbLoopsToGo) ;
    if ( loop_data->LoopIndex < loop_data->NbLoopsToGo )
    {
      vcmd_script->LineIndex = loop_data->StartLoopIndex ;
      status = LFGetNextEntry( vcmd_script, entry ) ;
      if ( status == SVCS_SUCCESS ) status = ModifyGlobalVariable( vcmd_script, "LFCurrentFile", entry ) ;
    }
    else loop_data->NbLoopsToGo = 0 ; /* Loop is done */
  }

  if ( (status != SVCS_SUCCESS) || (loop_data->LoopIndex >= loop_data->NbLoopsToGo) )
  {
    if ( vcmd_script->LoopFolderData.FileList ) fclose( vcmd_script->LoopFolderData.FileList ) ;
    DeleteGlobalVariable( vcmd_script, "LFCurrentFile" ) ;
    DeleteGlobalVariable( vcmd_script, "LFStartFolder" ) ;
    unlink( GetLFLogFileName() ) ;
    memzero( &vcmd_script->LoopFolderData, sizeof(vcmd_script->LoopFolderData) ) ;
  }

  return status ;
}

static short CmdSave(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 )
  {
    GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

    if ( wnd )
    {
      char param2[PATH_MAX] ; /* Filename to save */

      if ( GetParam( vcmd_script, 2, param2 ) == 0 )
      {
        INFO_IMAGE inf ;
        char       param3[PATH_MAX] ; /* Optional save options */
        VXIMAGE*   vimage = (VXIMAGE*) wnd->Extension ;
 
        memset( param3, 0, sizeof(param3) ) ;
        memcpy( &inf, &vimage->inf_img, sizeof(INFO_IMAGE) ) ;
        inf.lformat = DImgGetIIDFromFile( param2 ) ;
        if ( GetParam( vcmd_script, 3, param3 ) == 0 )
        {
          /* Replace all ';' by \0 as imagelib expects each option to be a string */
          strrep( param3, ';', 0 ) ;
          inf.save_options = param3 ;
        }
        else inf.save_options = NULL ;
        if ( vsave_picture( param2, &inf.mfdb, &inf, NULL ) != EIMG_SUCCESS ) status = SVCS_CMDFAILED ;
        else                                                                  status = SVCS_SUCCESS ;
      }
      else status = SVCS_MISSINGP2 ;
    }
    else
    {
      LoggingDoNoWindowID( param ) ;
      status = SVCS_CMDFAILED ;
    }
  }
  else status = SVCS_MISSINGP1 ;

  return status ;
}

static short GetParamXYWH(VCMD_SCRIPT* vcmd_script, short index, short* p, short nb)
{
  char  txywh[4] = { 'x', 'y', 'w', 'h' } ;
  char  param[PATH_MAX] ;
  short i, status ;

  for ( i = 0; i < nb; i++ )
  {
    status = GetParam( vcmd_script, index+i, param ) ;
    if ( status == 0 ) p[i] = atoi( param ) ;
    else               break ;
  }
  if ( i != nb )
  {
    LoggingDo(LL_INFO, "GetParamXYWH: Fail to extract %c", txywh[i] ) ;
    return SVCS_MISSINGP1-index-i ;
  }

  return SVCS_SUCCESS ;
}

static short CmdClipSel(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 )
  {
    GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

    if ( wnd )
    {
      short p[4] ; /* x,y,w,h */

      status = GetParamXYWH( vcmd_script, 2, p, 4 ) ;
      if ( status == 0 )
      {
        vclip.form = BLOC_RECTANGLE ;
        vclip_sel( wnd, p[0], p[1], p[0]+p[2]-1, p[1]+p[3]-1 ) ;
        GWInvalidate( wnd ) ;
      }
    }
    else
    {
      LoggingDoNoWindowID( param ) ;
      status = SVCS_CMDFAILED ;
    }
  }

  return status ;
}

static short CmdClipPaste(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 )
  {
    GEM_WINDOW* wnd = GWGetWindowByID( param ) ;

    if ( wnd )
    {
      short p[2] ; /* x,y */

      status = GetParamXYWH( vcmd_script, 2, p, 2 ) ;
      if ( status == 0 ) traite_colle( wnd, p[0], p[1] ) ;
    }
    else
    {
      LoggingDoNoWindowID( param ) ;
      status = SVCS_CMDFAILED ;
    }
  }

  return status ;
}

static short CmdClipPasteN(VCMD_SCRIPT* vcmd_script)
{
  char  param[PATH_MAX] ;
  short status ;

  status = GetParam( vcmd_script, 1, param ) ;
  if ( status == 0 ) traite_ncolle( param ) ;

  return status ;
}

#pragma warn -par
static short CmdClipCopy(VCMD_SCRIPT* vcmd_script)
{
  traite_copie() ;
  return SVCS_SUCCESS ;
}

static short CmdClipCut(VCMD_SCRIPT* vcmd_script)
{
  traite_coupe() ;
  return SVCS_SUCCESS ;
}

static short CmdComment(VCMD_SCRIPT* vcmd_script)
{
  return SVCS_SUCCESS ;
}

static short CmdUnknown(VCMD_SCRIPT* vcmd_script)
{
  return SVCS_UNKNOWNCMD ;
}

static short CmdQuit(VCMD_SCRIPT* vcmd_script)
{
  return SVCS_EXITREQUEST ;
}

static short CmdIBPrev(VCMD_SCRIPT* vcmd_script)
{
  return CmdIBMove( IMGB_PREVIOUS ) ;
}

static short CmdIBNext(VCMD_SCRIPT* vcmd_script)
{
  return CmdIBMove( IMGB_NEXT ) ;
}
#pragma warn +par

static short CmdLDVDocl(VCMD_SCRIPT* vcmd_script)
{
  return CmdLDVDo( vcmd_script, 0 ) ;
}

static short CmdLDVDoip(VCMD_SCRIPT* vcmd_script)
{
  return CmdLDVDo( vcmd_script, 1 ) ;
}

static short CmdSilent(VCMD_SCRIPT* vcmd_script, short item)
{
  char param[PATH_MAX] ;
  char silent = 1 ;

  if ( GetParam( vcmd_script, 1, param ) == 0 ) silent = (char)atoi( param ) ;
  if ( item == 0 )      form_set_mode( silent ) ;
  else if ( item == 1 ) StdProgMode( silent ) ;

  return SVCS_SUCCESS ;
}

static short CmdFormSilent(VCMD_SCRIPT* vcmd_script)
{
  return CmdSilent( vcmd_script, 0 ) ;
}

static short CmdProgSilent(VCMD_SCRIPT* vcmd_script)
{
  return CmdSilent( vcmd_script, 1 ) ;
}

static VCS_CMD_FUNC GetCmdFuncAndParams(VCMD_SCRIPT* vcmd_script, char* command_line)
{
  COMMAND_LABEL_IDS CmdLabelFuncs[] = {
                                        { ";",              CmdComment },
                                        { "quit",           CmdQuit },          { "exit",  CmdQuit },
                                        { "open",           CmdOpen },
                                        { "close",          CmdClose },
                                        { "wait",           CmdWait },          { "sleep", CmdWait },
                                        { "loop",           CmdLoop },
                                        { "endloop",        CmdEndLoop },
                                        { "run_script",     CmdRScript },
                                        { "cat_create",     CmdCatCre },
                                        { "cat_addfile",    CmdCatAfi },
                                        { "cat_addfolder",  CmdCatAfo },
                                        { "cat_openwicon",  CmdCatOIcn },
                                        { "cat_setini",     CmdCatSIni },
                                        { "ibrw_open",      CmdIBOpen },
                                        { "ibrw_next",      CmdIBNext },
                                        { "ibrw_prev",      CmdIBPrev },
                                        { "bconv_do",       CmdBConv },
                                        { "iprio_set",      CmdIPSet },         { "imgprio_set",    CmdIPSet },
                                        { "ldv_do",         CmdLDVDocl },
                                        { "ldv_doip",       CmdLDVDoip },
                                        { "loop_folder",    CmdLoopFolder },
                                        { "endloop_folder", CmdEndLoopFolder },
                                        { "save",           CmdSave },
                                        { "clip_sel",       CmdClipSel },
                                        { "clip_copy",      CmdClipCopy },
                                        { "clip_cut",       CmdClipCut },
                                        { "clip_paste",     CmdClipPaste },
                                        { "clip_pasteN",    CmdClipPasteN },
                                        { "form_silent",    CmdFormSilent },
                                        { "prog_silent",    CmdProgSilent },
                                      } ;
  VCS_CMD_FUNC CmdFunc = CmdUnknown ;
  char*        space = strchr( command_line, ' ' ) ;
  short        i ;

  if ( space ) *space++ = 0 ;

  for ( i = 0; (CmdFunc == CmdUnknown) && (i < ARRAY_SIZE(CmdLabelFuncs)); i++ )
    if ( strcmpi( CmdLabelFuncs[i].Label, command_line ) == 0 ) CmdFunc = CmdLabelFuncs[i].CmdFunc ;

  /* Prepare pointers to command line parameters */
  vcmd_script->nparams = 0 ;
  if ( (CmdFunc != CmdUnknown) && space ) vcmd_script->nparams = GetParams( space, ' ', vcmd_script->params, ARRAY_SIZE(vcmd_script->params) ) ;

  return CmdFunc ;
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
    char  buffer[768] ;
    short destroy_ldvprog = 0 ;

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
      else if ( (ret == SVCS_NOMORECMD) || (ret == SVCS_EXITREQUEST) ) destroy_ldvprog = 1 ;
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
        VCS_CMD_FUNC CmdFunc ;

        LoggingDo(LL_INFO, "Executing Command line: %s", ln) ;
        CmdFunc = GetCmdFuncAndParams( vcmd_script, ln ) ;
        ret     = CmdFunc( vcmd_script ) ;
        if ( ret == SVCS_EXITREQUEST ) FreeScript( original_vcmd_script ) ;
      }
      else ret = SVCS_SUCCESS ; /* Probably dummy characters, just ignore */
    }
    /* Check if script used CmdLDVDo recently */
    if ( clock() - vcmd_script->LastCmdLDVDoCall > CLK_TCK*5 ) destroy_ldvprog = 1 ;
    if ( destroy_ldvprog ) LDVDestroyProgWindow() ;
  }
  else ret = SVCS_FILENOEXIST ;

  return ret ;
}
