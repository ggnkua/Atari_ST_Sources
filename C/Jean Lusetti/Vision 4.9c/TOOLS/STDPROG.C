#include <string.h>
#include <stdio.h>
#include "xgem.h"
#include "gwindows.h"
#include "std.h"
#include "std.rsh"
#include "logging.h"
#include "keys.h"

typedef struct
{
  short   LastRatio ;
  clock_t tStart ;
  clock_t tLast ;
}
STDPROG_EXTENSION ;

static int  xypos[2] ;
static char prog_mode = 0 ; /* StdProg... silent is non zero */

#define CL_STDPROG   "StdProg"

static void OnStdProgMove(void* w, int xywh[4])
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  int         dummy ;

  if ( wnd == NULL ) return ;

  GWOnMoveDlg( w, xywh ) ;

  wnd->GetWorkXYWH( wnd, &xypos[0], &xypos[1], &dummy, &dummy ) ;
}

void StdProgWText(GEM_WINDOW* wnd, int num, char* text)
{
  DIALOG* dlg ;

  if ( wnd == NULL ) return ;

  dlg = (DIALOG*) wnd->DlgData ;
  if ( strcmp( wnd->ClassName, CL_STDPROG ) == 0 )
  {
    write_text( dlg->BaseObject, -num-PROG_TITRE1, text ) ; /* Negative to ask for show_best */
    GWObjcDraw( wnd, dlg->BaseObject, num + PROG_TITRE1 ) ;
  }
}

static int OnStdProgKeyPressed(void* w, int key)
{
  GEM_WINDOW* wnd = w ;

  if ( wnd == NULL ) return 0 ;

  if ( wnd->window_kind & CLOSER )
    if ( (key == KBD_ESCAPE) || (key == KBD_CTRL_C) ) GWDestroyWindow( wnd ) ;
  
  return( GWOnKeyPressedDlg( wnd, key ) ) ;
}

static int StdProgRange(void* w, long current, long max)
{
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  DIALOG*            dlg ;
  OBJECT*            obj ;
  STDPROG_EXTENSION* ext ;
  clock_t            t ;
  long               abs_max ;
  short              pc = 0 ;
  short              ratio ;
  int                status = SPROG_GUINOTUPDATED ;
  char               buf[20] ;

  if ( (wnd == NULL) || ((wnd->flags & FLG_ISVISIBLE) == 0) ) return status ;

  dlg     = (DIALOG*) wnd->DlgData ;
  obj     = dlg->BaseObject ;
  ext     = (STDPROG_EXTENSION*) wnd->Extension ;
  abs_max = (max >= 0) ? max:-max ;

  LoggingDo(LL_DEBUG, "StdProgRange current %ld, max %ld", current, max );
  if ( current < 0 )  current = 0 ;
  if ( current > abs_max ) current = abs_max ;
  pc = cal_pc( current, abs_max ) ;
  ratio = (short) ( ((long)(obj[PROG_TOTALPC].ob_width)*(long)pc)/100L ) ;
  if ( ext->LastRatio > ratio ) GWObjcDraw( wnd, obj, PROG_TOTALPC ) ;
  if ( ext->LastRatio != ratio )
  {
    obj[PROG_PC].ob_width = ratio ;
    GWObjcDraw( wnd, obj, PROG_PC ) ;
    sprintf( buf, "%d", pc ) ;
    write_text( obj, PROG_TPC, buf ) ;
    GWObjcDraw( wnd, obj, PROG_TPC ) ;
    ext->LastRatio = ratio ;
    status         = SPROG_GUIUPDATED ;
  }

  if ( wnd->pr_currentT ) t = wnd->pr_currentT ;
  else                    t = clock() ;
  wnd->pr_currentT = 0 ;
  if ( wnd->pr_force_cancel_check || (t - ext->tLast > 2*CLK_TCK) )
  {
    /* At least 2s later especially because GWBasicModalHandler can be very time consuming if called too often */
    if ( pc && (max > 0) ) /* Don't estimate Time Of Arrival if % is still zero or max is unknown */
    {
      struct tm* time_comp ;
      time_t     dt, s ;
      int        h, m ;
      int        dt_h, dt_m ;

      s  = (t-ext->tStart)*(100UL-pc) ;
      s /= (CLK_TCK*pc) ;               /* Remains this time (s) */

      time( &dt ) ;
      dt += s+30 ;
      time_comp = localtime( &dt ) ;
      dt_h = time_comp->tm_hour ;
      dt_m = time_comp->tm_min ;
      LoggingDo(LL_INFO, "Prog:%d%% complete, remains %lds, should be done at %02d:%02d", pc, s, dt_h, dt_m );
      m = (int) (s / 60) ;
      if ( m )
      {
        s = s % 60 ;
        h = m / 60 ;
        if ( h )
        {
          m = m % 60 ;
          sprintf( buf, "%02d:%02d(%dh%dm)", dt_h, dt_m, h, m ) ;
        }
        else sprintf( buf, "%02d:%02d(%dm%lds)", dt_h, dt_m, m, s ) ;
      }
      else sprintf( buf, "(%lds)", s ) ;
      write_text( obj, PROG_REMAIN, buf ) ;
      GWObjcDraw( wnd, obj, PROG_REMAIN ) ;
      status = SPROG_GUIUPDATED ;
    }
    ext->tLast = t ;
    GWBasicModalHandler() ;
    wnd->pr_force_cancel_check = 0 ;
  }
  /* Update status:                                       */
  /* SPROG_CANCEL: Cancel requested by user               */
  /* SPROG_GUIUPDATED: Progress updated on screen         */
  /* SPROG_GUINOTUPDATED: Progress not updated on screen  */
  if ( GWIsWindowValid( wnd ) == 0 ) status = SPROG_CANCEL ;

  return status ;
}

static void StdProgPcTxt(void* w, char* txt)
{
  if ( w && txt )
  {
    GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
    DIALOG*     dlg = (DIALOG*) wnd->DlgData;
    OBJECT*     obj = dlg->BaseObject ;

    write_text( obj, PROG_TPCTXT, txt ) ;
    GWObjcDraw( wnd, obj, PROG_TPCTXT ) ;
  }
}

static int StdProgPcEx(void* w, int pc, char* txt)
{
  StdProgPcTxt( w, txt ) ;

  return StdProgRange( w, pc, 100 ) ;
}

static int StdProgRangeEx(void* w, long current, long max, char* txt)
{
  StdProgPcTxt( w, txt ) ;

  return StdProgRange( w, current, max ) ;
}

GEM_WINDOW* DisplayStdProg(char* t1, char* t2, char* t3, int nflags)
{
  GEM_WINDOW* wnd ;
  DLGDATA     dlg_data ;
  OBJECT*     prog ;
  static char fix_done = 0 ;
  char        buf[10] ;

  if ( prog_mode ) return NULL ;

  GWZeroDlgData( &dlg_data ) ;

  if ( !fix_done )
  {
    Xrsrc_fix( rs_trindex[FORM_PROG] ) ;
    fix_done = 1 ;
  }

  prog = xobjc_copy( rs_trindex[FORM_PROG] ) ;
  if ( prog == NULL ) return NULL ;

  prog[PROG_PC].ob_width = 0 ;
  write_text( prog, PROG_TITRE1, t1 ) ;
  write_text( prog, PROG_TITRE2, t2 ) ;
  write_text( prog, PROG_TITRE3, t3 ) ;
  sprintf( buf, "%d", 0 ) ;
  write_text( prog, PROG_TPC, buf ) ;
  write_text( prog, PROG_REMAIN, "" ) ;

  prog[PROG_DSPON].ob_flags |= HIDETREE ,
  prog[PROG_030].ob_flags   |= HIDETREE ,
  prog[PROG_FPU].ob_flags   |= HIDETREE ,
  write_text( prog, PROG_TPCTXT, "" ) ;
  dlg_data.RsrcId = -1 ;
  dlg_data.Object = prog ;
  dlg_data.Parent = NULL ;
  if ( xypos[1] != 0 )
  {
    dlg_data.XPos = xypos[0] ;
    dlg_data.YPos = xypos[1] ;
  }
  dlg_data.NWKind = nflags ;
  dlg_data.ExtensionSize = sizeof(STDPROG_EXTENSION) ;
  strcpy( dlg_data.ClassName, CL_STDPROG ) ;
  wnd = GWCreateDialog( &dlg_data ) ;
  if ( wnd )
  {
     STDPROG_EXTENSION* ext = (STDPROG_EXTENSION*) wnd->Extension ;

     wnd->OnKeyPressed = OnStdProgKeyPressed ;
     wnd->OnMove       = OnStdProgMove ;
     wnd->ProgRange    = StdProgRangeEx ;
     ext->tStart       = ext->tLast = clock() ;
     GWObjcDraw( wnd, prog, FORM_PROG ) ;
  }
  else Xfree( prog ) ;

  return wnd ;
}

void StdProgDisplayItem(GEM_WINDOW* wnd, int display, int item)
{
  DIALOG* dlg ;
  int     flags ;

  if ( wnd == NULL ) return ;

  if ( strcmp( wnd->ClassName, CL_STDPROG ) == 0 )
  {
    dlg = (DIALOG*) wnd->DlgData ;

    flags = dlg->BaseObject[item].ob_flags ;
    if ( display ) dlg->BaseObject[item].ob_flags &= ~HIDETREE ;
    else           dlg->BaseObject[item].ob_flags |= HIDETREE ;
    if ( flags != dlg->BaseObject[item].ob_flags )
      GWObjcDraw( wnd, dlg->BaseObject, item ) ;
  }
}

void StdProgDisplay030(GEM_WINDOW* wnd, int display)
{
  StdProgDisplayItem( wnd, display, PROG_030 ) ;
}

void StdProgDisplayDSP(GEM_WINDOW* wnd, int display)
{
  StdProgDisplayItem( wnd, display, PROG_DSPON ) ;
}

void StdProgDisplayFPU(GEM_WINDOW* wnd, int display)
{
  StdProgDisplayItem( wnd, display, PROG_FPU ) ;
}

char StdProgMode(char silent)
{
  char prev_mode = prog_mode ;

  prog_mode = silent ;

  return prev_mode ;
}
