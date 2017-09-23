#include <string.h>
#include <stdio.h>
#include "xgem.h"
#include "gwindows.h"
#include "std.h"
#include "std.rsh"

typedef struct
{
  int LastRatio ;
}
STDPROG_EXTENSION ;

static int  xypos[2] ;

#define TESC         0x011B    /* Escape */
#define TCTRL_C      0x2E03

#define CL_STDPROG   "StdProg"

void OnStdProgMove(void *w, int xywh[4])
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  int        dummy ;

  if ( wnd == NULL ) return ;

  GWOnMoveDlg( w, xywh ) ;

  wnd->GetWorkXYWH( wnd, &xypos[0], &xypos[1], &dummy, &dummy ) ;
}

void StdProgWText(GEM_WINDOW *wnd, int num, char *text)
{
  DIALOG *dlg ;

  if ( wnd == NULL ) return ;

  dlg = (DIALOG *) wnd->DlgData ;
  if ( strcmp( wnd->ClassName, CL_STDPROG ) == 0 )
  {
    write_text( dlg->BaseObject, num + PROG_TITRE1, text ) ;
    xobjc_draw( wnd->window_handle, dlg->BaseObject, num + PROG_TITRE1 ) ;
  }
}

int OnStdProgKeyPressed(void *w, int key)
{
  GEM_WINDOW *wnd = w ;

  if ( wnd->window_kind & CLOSER )
    if ( ( key == TESC ) || ( key == TCTRL_C ) ) GWDestroyWindow( wnd ) ;
  
  return( GWOnKeyPressedDlg( wnd, key ) ) ;
}

int StdProgPc(void *w, int pc)
{
  GEM_WINDOW        *wnd ;
  DIALOG            *dlg ;
  OBJECT            *obj ;
  STDPROG_EXTENSION *ext ;
  int               ratio ;
  int               stop = 0 ;
  char              buf[10] ;

  wnd = (GEM_WINDOW *) w ;
  dlg = (DIALOG *) wnd->DlgData ;
  obj = dlg->BaseObject ;
  ext = (STDPROG_EXTENSION *) wnd->Extension ;
  if ( pc < 0 )   pc = 0 ;
  if ( pc > 100 ) pc = 100 ;
  ratio = (int) ( ((long)(obj[PROG_TOTALPC].ob_width)*(long)pc)/100L ) ;
  obj[PROG_PC].ob_width = ratio ;
  if ( ( wnd->flags & FLG_ISVISIBLE ) && ( ext->LastRatio > ratio ) ) xobjc_draw( wnd->window_handle, obj, PROG_TOTALPC ) ;
  if ( ext->LastRatio != ratio )
  {
    if ( wnd->flags & FLG_ISVISIBLE )
    {
      xobjc_draw( wnd->window_handle, obj, PROG_PC ) ;
      sprintf( buf, "%d", pc ) ;
      write_text( obj, PROG_TPC, buf ) ;
      xobjc_draw( wnd->window_handle, obj, PROG_TPC ) ;
    }
    ext->LastRatio = ratio ;
  }
  GWBasicModalHandler() ;
  stop = ( GWIsWindowValid( wnd ) == 0 ) ;

  return( stop ) ;
}

int StdProgPcEx(void *w, int pc, char *txt)
{
  GEM_WINDOW        *wnd ;
  DIALOG            *dlg ;
  OBJECT            *obj ;

  wnd = (GEM_WINDOW *) w ;
  dlg = (DIALOG *) wnd->DlgData ;
  obj = dlg->BaseObject ;

  if ( txt )
  {
    write_text( obj, PROG_TPCTXT, txt ) ;
    xobjc_draw( wnd->window_handle, obj, PROG_TPCTXT ) ;
  }

  return( StdProgPc( w, pc ) ) ;
}

GEM_WINDOW *DisplayStdProg(char *t1, char *t2, char *t3, int nflags)
{
  GEM_WINDOW  *wnd ;
  DLGDATA     dlg_data ;
  OBJECT      *prog ;
  static char fix_done = 0 ;
  char        buf[10] ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;

  if ( !fix_done )
  {
    Xrsrc_fix( rs_trindex[FORM_PROG] ) ;
    fix_done = 1 ;
  }

  prog = xobjc_copy( rs_trindex[FORM_PROG] ) ;
  if ( prog == NULL ) return( NULL ) ;

  prog[PROG_PC].ob_width = 0 ;
  write_text( prog, PROG_TITRE1, t1 ) ;
  write_text( prog, PROG_TITRE2, t2 ) ;
  write_text( prog, PROG_TITRE3, t3 ) ;
  sprintf( buf, "%d", 0 ) ;
  write_text( prog, PROG_TPC, buf ) ;

  prog[PROG_DSPON].ob_flags |= HIDETREE ,
  prog[PROG_030].ob_flags   |= HIDETREE ,
  write_text( prog, PROG_TPCTXT, "" ) ;
  dlg_data.RsrcId = -1 ;
  dlg_data.Object = prog ;
  dlg_data.Parent = NULL ;
  if ( xypos[1] != 0 )
  {
    dlg_data.XPos   = xypos[0] ;
    dlg_data.YPos   = xypos[1] ;
  }
  dlg_data.NWKind = nflags ;
  dlg_data.ExtensionSize = sizeof(STDPROG_EXTENSION) ;
  strcpy( dlg_data.ClassName, CL_STDPROG ) ;
  wnd = GWCreateDialog( &dlg_data ) ;
  if ( wnd )
  {
     wnd->OnKeyPressed = OnStdProgKeyPressed ;
     wnd->OnMove       = OnStdProgMove ;
     wnd->ProgPc       = StdProgPcEx ;
  }

  return( wnd ) ;
}
void StdProgDisplayDSP(GEM_WINDOW *wnd, int display)
{
  DIALOG *dlg ;
  int    flags ;

  if ( wnd == NULL ) return ;

  if ( strcmp( wnd->ClassName, CL_STDPROG ) == 0 )
  {
    dlg = (DIALOG *) wnd->DlgData ;

    flags = dlg->BaseObject[PROG_DSPON].ob_flags ;
    if ( display ) dlg->BaseObject[PROG_DSPON].ob_flags &= ~HIDETREE ;
    else           dlg->BaseObject[PROG_DSPON].ob_flags |= HIDETREE ;
    if ( flags != dlg->BaseObject[PROG_DSPON].ob_flags )
      xobjc_draw( wnd->window_handle, dlg->BaseObject, PROG_DSPON ) ;
  }
}

void StdProgDisplay030(GEM_WINDOW *wnd, int display)
{
  DIALOG *dlg ;
  int    flags ;

  if ( wnd == NULL ) return ;

  if ( strcmp( wnd->ClassName, CL_STDPROG ) == 0 )
  {
    dlg = (DIALOG *) wnd->DlgData ;

    flags = dlg->BaseObject[PROG_030].ob_flags ;
    if ( display ) dlg->BaseObject[PROG_030].ob_flags &= ~HIDETREE ;
    else           dlg->BaseObject[PROG_030].ob_flags |= HIDETREE ;
    if ( flags != dlg->BaseObject[PROG_030].ob_flags )
      xobjc_draw( wnd->window_handle, dlg->BaseObject, PROG_030 ) ;
  }
}
