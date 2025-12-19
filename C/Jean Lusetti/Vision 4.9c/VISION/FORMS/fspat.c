#include "..\tools\xgem.h"
#include "..\tools\gwindows.h"
#include "..\tools\std.h"
#include "..\tools\logging.h"
#include "..\tools\msgtxt.h"
#include "..\defs.h"

/* Pour eviter #include "std.rsh" */
extern OBJECT* rs_trindex[] ;
#include "fspat.h"

#define CL_SPATTERN   "SPattern"

static char lp_strsel ;
static char lp_casesel ;
static char lp_countsel ;
static char lp_waround ;
static char lp_hex[30] ;
static char lp_str[30] ;


static size_t NormalizeHex(char* pattern)
{
  size_t i = 0 ;
  size_t j = 0 ;
  int    val, hex ;
  char   c, nibble=0 ;

  do
  {
    c = pattern[i++] ;
    val = -1 ;
    if ( (c >= '0') && (c <= '9') ) val = c-'0' ;
    else if ( (c >= 'A') && (c <= 'F') ) val = 10+c-'A' ;
    else if ( (c >= 'a') && (c <= 'f') ) val = 10+c-'f' ;
    if ( val != -1 )
    {
      if ( nibble == 0 )
      {
        hex = val << 4 ;
        nibble++ ;
      }
      else if ( nibble == 1 )
      {
        hex += val ;
        pattern[j++] = (char) hex ;
        nibble = 0 ;
      }
    }
    else nibble = 0 ;
  }
  while (c) ;

  return j ;
}

static int OnObjectNotify(void* w, int obj)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     fspat = wnd->DlgData->BaseObject ;
  int         code = -1 ;

  switch( obj )
  {
    case SP_HEX:        inv_select( fspat, obj ) ;
    case SP_HEXLABEL:   if ( !selected( fspat, SP_HEX ) )
                        {
                          select( fspat, SP_HEX ) ;
                          deselect( fspat, SP_STRING ) ;
                        }
                        GWObjcDraw( wnd, fspat, SP_HEX ) ;
                        GWObjcDraw( wnd, fspat, SP_STRING ) ;
                        break ;
    case SP_STRING:     inv_select( fspat, obj ) ;
    case SP_STRLABEL:   if ( !selected( fspat, SP_STRING ) )
                        {
                          select( fspat, SP_STRING ) ;
                          deselect( fspat, SP_HEX ) ;
                        }
                        GWObjcDraw( wnd, fspat, SP_HEX ) ;
                        GWObjcDraw( wnd, fspat, SP_STRING ) ;
                        break ;
    case SP_STRCAPS:    inv_select( fspat, SP_BSTRCAPS ) ;
                        break ;
    case SP_COUNT:      inv_select( fspat, SP_BCOUNT ) ;
                        break ;
    case SP_WRAPAROUND: inv_select( fspat, SP_BWRAPAROUND ) ;
                        break ;
    case SP_OK:         code = IDOK ;
                        break ;
    case SP_CANCEL:     code = IDCANCEL ;
                        break ;
  }

  if ( code == IDOK )
  {
    SPAT_PARMS* params = (SPAT_PARMS*) wnd->DlgData->UserData ;

    if ( selected( fspat, SP_HEX ) )
    {
      params->type = SPT_BIN ;
      read_text( fspat, SP_HEXT, params->pattern ) ;
      params->pattern_size = NormalizeHex( params->pattern ) ;
    }
    else
    {
      if ( selected( fspat, SP_BSTRCAPS ) ) params->type = SPT_STRINGCASE ;
      else                                  params->type = SPT_STRINGNOCASE ;
      read_text( fspat, SP_STRT, params->pattern ) ;
      params->pattern_size = strlen( params->pattern ) ;
    }
    params->count_them  = selected( fspat, SP_BCOUNT ) ;
    params->wrap_around = selected( fspat, SP_BWRAPAROUND ) ;
  }

  lp_strsel   = selected( fspat, SP_STRING ) ;
  lp_casesel  = selected( fspat, SP_BSTRCAPS ) ;
  lp_countsel = selected( fspat, SP_BCOUNT ) ;
  lp_waround  = selected( fspat, SP_BWRAPAROUND ) ;
  read_text( fspat, SP_HEXT, lp_hex ) ;
  read_text( fspat, SP_STRT, lp_str ) ;

  return code ;
}

static void OnInitDialog(void *w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     fspat = wnd->DlgData->BaseObject ;
  char        objs[] = { SP_TITLE,    SP_HEXLABEL,    SP_STRLABEL,    SP_STRCAPS,    SP_COUNT,    SP_WRAPAROUND,  SP_CANCEL } ;
  int         msgs[] = { MSG_SPTITLE, MSG_SPHEXLABEL, MSG_SPSTRLABEL, MSG_SPSTRCAPS, MSG_SPCOUNT, MSG_WRAPAROUND, MSG_CANCEL } ;
  int         i ;

  for ( i = 0; i < ARRAY_SIZE(objs); i++ )
    write_text( fspat, objs[i], vMsgTxtGetMsg( msgs[i] ) ) ;

  if ( lp_strsel )
  {
    deselect( fspat, SP_HEX ) ;
    select( fspat, SP_STRING ) ;
  }
  else
  {
    select( fspat, SP_HEX ) ;
    deselect( fspat, SP_STRING ) ;
  }
  if ( lp_casesel )  select( fspat, SP_BSTRCAPS ) ;
  else               deselect( fspat, SP_BSTRCAPS ) ;
  if ( lp_countsel ) select( fspat, SP_BCOUNT ) ;
  else               deselect( fspat, SP_BCOUNT ) ;
  if ( lp_waround )  select( fspat, SP_BWRAPAROUND ) ;
  else               deselect( fspat, SP_WRAPAROUND ) ;

  write_text( fspat, SP_HEXT, lp_hex ) ;
  write_text( fspat, SP_STRT, lp_str ) ;
}

int FormGetSPattern(SPAT_PARMS* params)
{
  DLGDATA     dlg_data ;
  OBJECT*     fspat ;
  static char fix_done = 0 ;

  GWZeroDlgData( &dlg_data ) ;

  if ( !fix_done )
  {
    Xrsrc_fix( rs_trindex[FORM_SPATTERN] ) ;
    fix_done = 1 ;
  }

  fspat = xobjc_copy( rs_trindex[FORM_SPATTERN] ) ;
  if ( fspat == NULL ) return -1 ;

  params->type       = SPT_BIN ;
  params->count_them = 0 ;
  
  dlg_data.RsrcId       = -1 ;
  dlg_data.Object       = fspat ;
  dlg_data.UserData     = params ;
  strcpy( dlg_data.ClassName, CL_SPATTERN ) ;
  dlg_data.OnObjectNotify = OnObjectNotify ;
  dlg_data.OnInitDialog = OnInitDialog ;

  return( (GWCreateAndDoModal( &dlg_data, 0 ) == IDOK) ? 0:1 ) ;
}
