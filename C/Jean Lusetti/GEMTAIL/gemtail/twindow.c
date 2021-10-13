#include  <stdio.h>
#include <string.h>

#include       "..\tools\ini.h"
#include      "..\tools\xgem.h"
#include     "..\tools\xfile.h"
#include   "..\tools\logging.h"
#include   "..\tools\clipbrd.h"
#include  "..\tools\gwindows.h"
#include  "..\tools\spattern.h"

#include    "defs.h"
#include   "akeys.h"
#include "twindow.h"

#include   "forms\ffind.h"
#include "forms\fparams.h"

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(v)  sizeof(v)/sizeof((v)[0])
#endif

#define DEF_BUFFERSIZE    (128L*1024L)
#define DEF_MAXBUFFERSIZE (16L*DEF_BUFFERSIZE)
#define DEF_NBLINES       (1000L)

#define TWINDOW_WKIND (NAME|CLOSER|INFO|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|SMALLER)


static long GetOrSet(short get, HINI h_ini, char *section_name, char *key_name, char *key)
{
  if ( get ) return GetOrSetIniKey( h_ini, section_name, key_name, key ) ;
  else       return SetIniKey( h_ini, section_name, key_name, key ) ;
}

char* TWMultipleStringToCommaSep(char *s, char *d)
{
  return dzt_string2sep( s, ',', d ) ;
}

void TWGetOrSetParams(char* name, TWINDOW_PARAMS* tw_params)
{
  HIGHLIGHTDATA* hld ;
  HINI           h_ini ;
  long           save_ini = 0 ;
  short          i, hcar, font, get ;
  char           buf[PATH_MAX] ;
  char           section_name[64] ;
  char           local_name[64] ;
  char*          last_slash ;
  char*          last_dot ;

  get = ( name != NULL ) ;
  if ( get )
  {
    memset( tw_params, 0, sizeof(TWINDOW_PARAMS) ) ;
    strcpy( tw_params->FileName, name ) ;
  }
  else save_ini = 1 ;

  last_slash = strrchr( tw_params->FileName, '\\' ) ;
  if ( last_slash ) strcpy( local_name, 1+last_slash ) ;
  else              strcpy( local_name, tw_params->FileName ) ;
  last_dot = strrchr( local_name, '.' ) ;
  if ( last_dot ) *last_dot = 0 ;
  sprintf( buf, "%s\\TEMPLATE\\%s.GTT", init_path, local_name ) ;
  LoggingDo(LL_INFO,"Looking for template %s...", buf) ;
  h_ini = OpenIni( buf ) ;

  if ( get ) tw_params->MaxBufferSize = 2L*1024L*1024L ; /* 2 MB */
  sprintf( buf, "%ld", tw_params->MaxBufferSize ) ;
  save_ini |= GetOrSet( get, h_ini, "General", "MaxBufferSize", buf ) ;
  tw_params->MaxBufferSize = atol( buf ) ;

  if ( get ) tw_params->TimerMs = 200 ; /* 200 ms default */
  sprintf( buf, "%ld", tw_params->TimerMs ) ;
  save_ini |= GetOrSet( get, h_ini, "General", "TimerMs", buf ) ;
  tw_params->TimerMs = atol( buf ) ;

  if ( get ) tw_params->Font = 1 ;
  sprintf( buf, "%d", tw_params->Font ) ;
  save_ini |= GetOrSet( get, h_ini, "General", "Font", buf ) ;
  tw_params->Font = atoi( buf ) ;

  if ( get ) tw_params->HCar = 12 ;
  sprintf( buf, "%d", tw_params->HCar ) ;
  save_ini |= GetOrSet( get, h_ini, "General", "HCar", buf ) ;
  tw_params->HCar = atoi( buf ) ;

  if ( get ) tw_params->ExcludedKeywords[0] = 0 ;
  TWMultipleStringToCommaSep( tw_params->ExcludedKeywords, buf ) ;
  save_ini |= GetOrSet( get, h_ini, "General", "ExcludedKeywords", buf ) ;
  strcpy( tw_params->ExcludedKeywords, buf ) ;
  strrep( tw_params->ExcludedKeywords, ',', 0 ) ;

  for ( i = 0, hld = &tw_params->HighLightData[0]; i < ARRAY_SIZE(tw_params->HighLightData); i++, hld++ )
  {
    hld->TextType.font = tw_params->Font ;
    hld->TextType.hcar = tw_params->HCar ;
    sprintf( section_name, "HighLight%d", i ) ;

    if ( get ) hld->TextType.color = 1 ;
    sprintf( buf, "%d", hld->TextType.color ) ;
    save_ini |= GetOrSet( get, h_ini, section_name, "TextColor", buf ) ;
    hld->TextType.color = atoi( buf ) ;

    if ( get ) hld->TextType.fg_color = 0 ;
    sprintf( buf, "%d", hld->TextType.fg_color ) ;
    save_ini |= GetOrSet( get, h_ini, section_name, "FGColor", buf ) ;
    hld->TextType.fg_color = atoi( buf ) ;

    set_texttype( &hld->TextType ) ; /* To init hcell, used in TailFile */

    if ( get ) hld->Keywords[0] = 0 ;
    TWMultipleStringToCommaSep( hld->Keywords, buf ) ;
    save_ini |= GetOrSet( get, h_ini, section_name, "Keywords", buf ) ;
    strcpy( hld->Keywords, buf ) ;
    strrep( hld->Keywords, ',', 0 ) ;
  }

  if ( save_ini )  SaveAndCloseIni( h_ini, NULL ) ;
  else             CloseIni( h_ini ) ;
}

static void open_where(short wkind, short w, short h, short* xout, short* yout, short* wout, short* hout)
{
  short xopen, yopen ;
  int   xo, yo, wo, ho ;
  int   dummy ;

  xopen = xdesk ;
  yopen = ydesk ;
  wind_calc( WC_WORK, wkind, xopen, yopen, 16, 16, &xo, &yo, &dummy, &dummy ) ;
  wind_calc( WC_BORDER, wkind, xo, yo, w, h, &xo, &yo, &wo, &ho ) ;
  if ( xopen+wo > Xmax ) wo = w-(xopen+wo-Xmax) ;
  if ( yopen+ho > Ymax ) ho = h-(yopen+ho-Ymax) ;
  *xout = xo ; *yout = yo ;
  *wout = wo ; *hout = ho ;
}

static short InitTWData(TWINDOW_PARAMS* tw_params, TWINDOW_DATA* tw_data)
{
  memset( tw_data, 0, sizeof(TWINDOW_DATA) ) ;
  if ( tw_params->InitialBufferSize <= 0 ) tw_data->InitialBufferSize = DEF_BUFFERSIZE ;
  else                                     tw_data->InitialBufferSize = tw_params->InitialBufferSize ;

  if ( tw_params->MaxBufferSize <= 0 ) tw_params->MaxBufferSize = DEF_MAXBUFFERSIZE ;
  tw_data->MaxBufferSize = tw_params->MaxBufferSize ;

  if ( tw_params->InitialNbLines <= 0 ) tw_data->NbLines = DEF_NBLINES ;
  else                                  tw_data->NbLines = tw_params->InitialNbLines ;

  tw_data->BufferSize = tw_data->InitialBufferSize ;
  tw_data->Buffer = (char*) Xcalloc( 1, tw_data->BufferSize ) ;
  if ( tw_data->Buffer == NULL ) return -3 ;

  tw_data->Lines = (TWLINE*) Xcalloc( tw_data->NbLines, sizeof(TWLINE) ) ;
  if ( tw_data->Lines == NULL )
  {
    Xfree( tw_data->Buffer ) ;
    tw_data->Buffer = NULL ;
    return -3 ;
  }

  tw_data->BegNewLine   = 1 ;

  return 0 ;
}

#define TWRDF_FILE 0x01
#define TWRDF_MEM  0x02
#define TWRDF_ALL  0xFF
static void ReleaseTWData(TWINDOW* tw, short flags)
{
  TWINDOW_DATA* tw_data ;

  tw->UICurrentSel = -1 ;
  tw_data          = &tw->d ;

  if ( flags & TWRDF_FILE )
  {
    if ( tw_data->gdos_fd > 0 ) Fclose( tw_data->gdos_fd ) ;
    tw_data->gdos_fd      = 0 ;
    tw_data->fpos         = 0 ;
    tw_data->nopen_errors = 0 ;
  }
  if ( flags & TWRDF_MEM )
  {
    if ( tw_data->Lines ) Xfree( tw_data->Lines ) ;
    if ( tw_data->Buffer ) Xfree( tw_data->Buffer ) ;
    tw_data->Buffer       = NULL ;
    tw_data->BufferSize   = 0 ;
    tw_data->BufferOffset = 0 ;
    tw_data->Lines        = NULL ;
    tw_data->NbLines      = 0 ;
    tw_data->LastLine     = 0 ;
    tw_data->BegNewLine   = 0 ;
  }
  tw->UICurrentSel = -1 ;
}

static int OnClose(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  TWINDOW*    tw = (TWINDOW*) wnd->Extension ;

  ReleaseTWData( tw, TWRDF_ALL ) ;
  GWOnClose( wnd ) ;

  return GW_EVTCONTINUEROUTING ;
}

static char* SearchKeyword(char* string, char* keywords)
{
  char* keyword = keywords ;
  char* keyword_in_string = NULL ;

  while ( *keyword )
  {
    keyword_in_string = strstr( string, keyword ) ;
    if ( keyword_in_string ) return keyword_in_string ;
    keyword += 2+strlen(keyword) ;
  }

  return keyword_in_string ;
}

static TEXT_TYPE* GetTextType(TWINDOW_PARAMS* tw_params, char* text)
{
  HIGHLIGHTDATA* hld ;
  char*          keywords ;
  short          n ;

  if ( text == NULL ) return NULL ;

  for ( n = 1, hld = &tw_params->HighLightData[1]; n < ARRAY_SIZE(tw_params->HighLightData); n++, hld++ )
  {
    /* Search for keywords */
    if ( SearchKeyword( text, &hld->Keywords[0] ) ) return &hld->TextType ;
  }

  return &tw_params->HighLightData[0].TextType ;
}

static short SetLineAttr(TWINDOW* tw, char* p, long line)
{
  if ( p == NULL ) p = tw->d.Lines[line].Text ;

  if ( SearchKeyword( p, &tw->p.ExcludedKeywords[0] ) == NULL )
  {
    tw->d.Lines[line].Text     = p ;
    tw->d.Lines[line].TextType = GetTextType( &tw->p, p ) ;
    return 0 ;
  }

  return 1 ;
}

static short AddLine(TWINDOW* tw, char* p)
{
  short ret ;

  if ( tw->d.LastLine >= tw->d.NbLines )
  {
    void* new_alloc ;
    long  inc = DEF_NBLINES/2 ;

    new_alloc = Xrealloc( tw->d.Lines, (tw->d.NbLines+inc)*sizeof(TWLINE) ) ;
    if ( new_alloc == NULL )
    {
      LoggingDo(LL_WARNING, "Can't allocate memory for increasing number of lines to be logged for %s", tw->p.FileName) ;
      return -3 ;
    }
    tw->d.Lines    = new_alloc ;
    tw->d.NbLines += inc ;
  }

  ret = SetLineAttr( tw, p, tw->d.LastLine ) ;
  if ( ret == 0 ) tw->d.LastLine++ ;

  return 0 ;
}

static void BuildLinesPtrs(TWINDOW* tw, long nb_bytes)
{
  TWINDOW_DATA* tw_data = &tw->d ;
  char*         p = &tw_data->Buffer[tw_data->BufferOffset] ;
  char*         last_p = p + nb_bytes-1 ;

  while ( p <= last_p )
  {
    if ( (*p == '\r') || (*p == '\n' ) ) *p = 0 ;
    p++ ;
  }

  p = &tw_data->Buffer[tw_data->BufferOffset] ;
  if ( tw_data->BegNewLine && (AddLine( tw, p ) == 0) ) tw_data->BegNewLine = 0 ;

  while ( p <= last_p )
  {
    while ( (p <= last_p) && (*p == 0) ) { p++ ; tw_data->BegNewLine = 1 ; }
    if ( tw_data->BegNewLine && (p <= last_p) && (AddLine( tw, p ) == 0) )
      tw_data->BegNewLine = 0 ;
    p++ ;
  }
}

static long TFinstat(TWINDOW_DATA* tw_data, short use_finstat) /* Because Finstat fails on Magic */
{
  long  r = -3 ; /* Command not supported */

  if ( use_finstat )
  {
    r = XFinstat( tw_data->gdos_fd ) ;
    if ( r > 0 ) tw_data->fpos += r ;
  }
  else
  {
    /* Finstat (Mint only) does not report anything in case file is regenerated (returns no bytes available) */
    /* So use FSTAT control even for Mint except for console as it does require Finstat                      */
    XATTR xattr ;
    long  last_fpos = tw_data->fpos ;

    if ( Fcntl( tw_data->gdos_fd, (long)&xattr, 0x4600 ) >= 0 ) /* FSTAT */
    {
      r             = xattr.size-last_fpos ;
      tw_data->fpos = xattr.size ;
    }
  }

  return r ;
}

static void UpdateInfos(TWINDOW* tw)
{
  char  buf[128] ;
  char  tpause[] = "(paused)" ;
  char  tnohighlight[] = "(no highlight)" ;
  char* str_pause = "" ;
  char* str_highlight = "" ;  

  if ( tw->sf_pause )       str_pause     = tpause ;
  if ( tw->sf_nohighlight ) str_highlight = tnohighlight ;
  
  if ( tw->d.gdos_fd <= 0 ) sprintf( buf, "File does not exist (%d tries) %s %s", tw->d.nopen_errors, str_pause, str_highlight ) ;
  else                      sprintf( buf, "%ld lines, %ld bytes %s %s", tw->d.LastLine, tw->d.fpos, str_pause, str_highlight ) ;
  GWSetWindowInfo( tw->wnd, buf ) ;
}

static void UIUpdateFirstAndLastLine(TWINDOW* tw)
{
  tw->UILastLine = tw->d.LastLine-1 ;
  if ( tw->UILastLine < 0 ) tw->UILastLine = 0 ;
  tw->UIFirstLine = 1 + tw->UILastLine - tw->UINbLines ;
  if ( tw->UIFirstLine < 0 ) tw->UIFirstLine = 0 ;
}

static void UpdateVSlider(GEM_WINDOW* wnd)
{
  TWINDOW* tw = (TWINDOW*) wnd->Extension ;
  short    pos, size ;

  if ( (tw->d.LastLine-tw->UINbLines != 1) && (tw->d.LastLine != 0) )
  {
    pos  = (short) ((1000L*tw->UIFirstLine)/(tw->d.LastLine-tw->UINbLines-1)) ;
    GWSetVSlider( wnd, pos ) ;
    size = (short) ((1000L*tw->UINbLines)/tw->d.LastLine) ;
    GWSetVSliderSize( wnd, size ) ;
  }
}

static short IncreaseTailBuffer(TWINDOW* tw, long requested_bytes)
{
  long  new_requirement = tw->d.BufferOffset+requested_bytes ;
  short err = 0 ;

  LoggingDo(LL_INFO, "Request to have %ld bytes (at least) for tail buffer %s (%ld now)", new_requirement, tw->p.FileName, tw->d.BufferSize) ;
  if ( new_requirement > tw->d.MaxBufferSize )
  {
    LoggingDo(LL_WARNING,"Too much data requested (%ld vs %ld bytes)", new_requirement, tw->d.MaxBufferSize);
    err = -1 ;
  }
  else
  {
    void* new_alloc ;
    long  size = tw->d.BufferSize ;

    while ( size < new_requirement ) size += tw->d.InitialBufferSize ;
    new_alloc = Xrealloc( tw->d.Buffer, size ) ;
    if ( new_alloc )
    {
      long offset = (long)new_alloc - (long)tw->d.Buffer ;

      tw->d.Buffer     = new_alloc ;
      tw->d.BufferSize = size ;
      LoggingDo(LL_INFO, "Tail buffer is now %ld bytes big", size) ;
      /* Now update all pointers to text which were pointing to previously allocated buffer */
      if ( offset != 0 )
      {
        TWLINE* twline ;

        for ( twline = &tw->d.Lines[0]; twline < &tw->d.Lines[tw->d.LastLine]; twline++ )
          twline->Text += offset ;
      }
    }
    else err = -2 ;
  }

  return err ;  
}

static short TailFile(TWINDOW* tw)
{
  TWINDOW_DATA* tw_data = &tw->d ;
  long          nb_bytes_available ;

  if ( tw_data->gdos_fd <= 0 )
  {
    short gdos_fd = (short)Fopen( tw->p.FileName, 0 ) ;

    if ( gdos_fd > 0 )
    {
      if ( InitTWData( &tw->p, tw_data ) != 0 )
      {
        LoggingDo(LL_ERROR, "Can't allocate TWINDOW data for %s", tw->p.FileName) ;
        Fclose( gdos_fd ) ;
        return -2 ;
      }
      else
      {
        tw_data->gdos_fd = gdos_fd ;
        if ( strcmpi(tw->p.FileName, "u:\\dev\\xconout2") == 0 ) tw->sf_finstat = 1 ;
        LoggingDo(LL_INFO,"File %s open for tailing", tw->p.FileName) ;
        UpdateVSlider( tw->wnd ) ;
        UpdateInfos( tw ) ;
      }
    }
    else
    {
      if ( (++tw_data->nopen_errors & 0x0F) == 0 )
      {
        LoggingDo(LL_INFO,"Fail to open tailed file %s %d times", tw->p.FileName, tw->d.nopen_errors) ;
        UpdateInfos( tw ) ;
      }
    }
  }
  if ( tw_data->gdos_fd <= 0 ) return -1 ; /* File cannot still be open */


  nb_bytes_available = TFinstat( tw_data, tw->sf_finstat ) ;
  if ( nb_bytes_available == -37 )
  {
    /* Bad handle, file has been deleted/reset in the meantime */
    LoggingDo(LL_INFO,"Tailed file %s is invalid, will be reopen", tw->p.FileName) ;
    ReleaseTWData( tw, TWRDF_ALL ) ;
    return 0 ;
  }
  else if ( nb_bytes_available <= 1 ) return 0 ; /* 1 means returned value is not certain, skip it */

  /* Some data is available */
  if ( tw_data->BufferOffset+nb_bytes_available >= tw_data->BufferSize )
  {
    if ( IncreaseTailBuffer( tw, nb_bytes_available ) == -1 )
    {
      if ( tw_data->fpos < tw_data->MaxBufferSize )
      {
        /* Maximum buffer already allocated, just restart tailing, discarding what we have */
        LoggingDo(LL_INFO,"Tail buffer for %s has been reset as it reached its maximum", tw->p.FileName) ;
        ReleaseTWData( tw, TWRDF_ALL ) ;
        return 0 ;
      }
      else LoggingDo(LL_WARNING,"Tail file %s is now too big (%ld bytes)", tw->p.FileName, tw_data->fpos) ;
    }
  }
  if ( tw_data->BufferOffset+nb_bytes_available < tw_data->BufferSize )
  {
    int dummy, h ;

    if ( Fread( tw_data->gdos_fd, nb_bytes_available, &tw_data->Buffer[tw_data->BufferOffset] ) == nb_bytes_available )
    {
      BuildLinesPtrs( tw, nb_bytes_available ) ;
      tw_data->BufferOffset += nb_bytes_available ;
      GWGetWorkXYWH( tw->wnd, &dummy, &dummy, &dummy, &h ) ;
      tw->UINbLines = h/tw->p.HighLightData[0].TextType.hcell ;
      UIUpdateFirstAndLastLine( tw ) ;
      GWInvalidate( tw->wnd ) ;
    }
    else
    {
      /* Bad handle, file has been deleted/reset in the meantime */
      LoggingDo(LL_INFO,"Read error on file %s, will be reopen", tw->p.FileName) ;
      ReleaseTWData( tw, TWRDF_ALL ) ;
    }
    UpdateVSlider( tw->wnd ) ;
    UpdateInfos( tw ) ;
  }

  return 0 ;
}

#pragma warn -par
static void OnDraw(void *ww, int xywh[4])
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) ww ;
  TWINDOW*    tw = (TWINDOW*) wnd->Extension ;
  TWLINE*     tw_line ;
  TEXT_TYPE*  highlighted_tt ;
  TEXT_TYPE*  text_type = NULL ;
  int         extent[8] ;
  int         xyarray[4] ;
  int         x, y, cy, w, h, hcell, delta ;
  long        line ;

  GWGetWorkXYWH( wnd, &x, &y, &w, &h ) ;
  vsf_interior( handle, FIS_SOLID ) ;
  vsf_perimeter( handle, 0 ) ;
  cy    = y ;
  hcell = tw->p.HighLightData[0].TextType.hcell ;
  delta = hcell - tw->p.HighLightData[0].TextType.hcar ;
  if ( tw->d.Lines )
  {
    for ( tw_line = &tw->d.Lines[tw->UIFirstLine]; tw_line <= &tw->d.Lines[tw->UILastLine]; tw_line++ )
    {
      xyarray[0] = x ;
      xyarray[1] = cy ;
      xyarray[2] = x+w-1 ;
      cy        += hcell ;
      xyarray[3] = cy-1 ;
      if ( tw_line->lf_search || tw_line->lf_selected )
      {
        vsl_color( handle, tw_line->lf_selected ? 15:14 ) ;
        rectangle( xyarray[0], xyarray[1], xyarray[2], xyarray[3] ) ;
        xyarray[0]++ ; xyarray[1]++ ;
        xyarray[2]-- ; xyarray[3]-- ;
      }
      if ( tw->sf_nohighlight || (tw_line->TextType == NULL) ) highlighted_tt = &tw->p.HighLightData[0].TextType ;
      else                                                     highlighted_tt = tw_line->TextType ;
      if ( text_type != highlighted_tt )
      {
        text_type = highlighted_tt ;
        set_texttype( text_type ) ;
      }
      vsf_color( handle, text_type->fg_color ) ;
      vswr_mode( handle, MD_REPLACE ) ;
      v_bar( handle, xyarray ) ;
      vswr_mode( handle, MD_TRANS ) ;
      if ( tw_line->Text ) v_gtext( handle, x, cy-delta, tw_line->Text ) ;
    }
  }
  xyarray[0] = x ;     xyarray[1] = cy ;
  xyarray[2] = x+w-1 ; xyarray[3] = y+h-1 ;
  vsf_color( handle, tw->p.HighLightData[0].TextType.fg_color ) ;
  v_bar( handle, xyarray ) ;
}

static int OnTimer(void* w, int mx, int my)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  TWINDOW*    tw = (TWINDOW*) wnd->Extension ;

  if ( !wnd->is_icon && !tw->sf_pause ) TailFile( tw ) ;

  return 0 ;
}
#pragma warn +par

static long ValidateUILine(long uiline, long last_line)
{
  if ( uiline >= last_line ) uiline = last_line-1 ;
  if ( uiline < 0 ) uiline = 0 ;

  return uiline ;
}

static short UIMoveFirstLastLine(TWINDOW* tw, long nb_elems)
{
  long first_line = tw->UIFirstLine ;
  long last_line  = tw->UILastLine ;
  long delta ;

  tw->UILastLine += nb_elems ;
  if ( tw->UILastLine < tw->UINbLines-1 ) tw->UILastLine = tw->UINbLines-1 ;
  tw->UILastLine = ValidateUILine( tw->UILastLine, tw->d.LastLine ) ;
  delta = tw->UILastLine - last_line ;
  tw->UIFirstLine += delta ;
  tw->UIFirstLine = ValidateUILine( tw->UIFirstLine, tw->d.LastLine ) ;

  return (first_line != tw->UIFirstLine) && (last_line != tw->UILastLine) ;
}

static void OnArrow(void* w, int action)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  TWINDOW*    tw = (TWINDOW*) wnd->Extension ;
  short       update_gui = 0 ;

  switch( action )
  {
    case WA_UPPAGE : update_gui = UIMoveFirstLastLine( tw, -tw->UINbLines ) ;
                     break ;

    case WA_DNPAGE : update_gui = UIMoveFirstLastLine( tw, tw->UINbLines ) ;
                     break ;

    case WA_UPLINE : update_gui = UIMoveFirstLastLine( tw, -1 ) ;
                     break ;

    case WA_DNLINE : update_gui = UIMoveFirstLastLine( tw, 1 ) ;
                     break ;
  }

  if ( update_gui )
  {
    GWInvalidate( wnd ) ;
    UpdateVSlider( wnd ) ;
  }
}

static void OnVSlider(void* w, int pos)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  TWINDOW*    tw = (TWINDOW*) wnd->Extension ;

  tw->UIFirstLine = ValidateUILine( ((long)pos * (tw->d.LastLine-tw->UINbLines)) / 1000L, tw->d.LastLine ) ;
  tw->UILastLine  = ValidateUILine( tw->UIFirstLine+tw->UINbLines-1, tw->d.LastLine ) ;
  GWInvalidate( wnd ) ;
  UpdateVSlider( wnd ) ;
}

static void OnSize(void* wnd, int xywh[4])
{
  GEM_WINDOW* gwnd = (GEM_WINDOW*) wnd ;
  TWINDOW*    tw = (TWINDOW*) gwnd->Extension ;
  int         x, y, w, h, w_max ;

  if ( gwnd->is_icon ) return ;

  GWGetCurrXYWH( gwnd, &x, &y, &w, &h ) ;
  wind_calc( WC_WORK, gwnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &x, &y, &w, &h ) ;
  tw->UINbLines = h/tw->p.HighLightData[0].TextType.hcell ;
  UIUpdateFirstAndLastLine( tw ) ;

  wind_calc( WC_BORDER, gwnd->window_kind, x, y, w, h, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  GWOnSize( gwnd, xywh ) ;
  UpdateVSlider( gwnd ) ;
}

static void ReleaseAndUpdate(TWINDOW* tw, short rd_flag)
{
  if ( rd_flag != -1 ) ReleaseTWData( tw, rd_flag ) ;
  UIUpdateFirstAndLastLine( tw ) ;
  UpdateVSlider( tw->wnd ) ;
  UpdateInfos( tw ) ;
  GWInvalidate( tw->wnd ) ;
}

#define TWMSG_INVPAUSE 0
#define TWMSG_CLEAR    1
#define TWMSG_RELOAD   2
#pragma warn -par
void TWMsg(TWINDOW* tw, short msg, void* param)
{
  switch( msg )
  {
    case TWMSG_INVPAUSE: tw->sf_pause = 1-tw->sf_pause ;
                         UpdateInfos( tw ) ;
                         break ;
    case TWMSG_CLEAR:    LoggingDo(LL_INFO, "Releasing memory for %s", tw->p.FileName ) ;
                         ReleaseAndUpdate( tw, TWRDF_MEM ) ;
                         break ;
    case TWMSG_RELOAD:   LoggingDo(LL_INFO, "Reloading tail %s", tw->p.FileName ) ;
                         ReleaseAndUpdate( tw, TWRDF_ALL ) ;
                         break ;
  }
}
#pragma warn +par

static void TWParams(TWINDOW_PARAMS* sel_params)
{
  TWINDOW_PARAMS* tmp_params = Xcalloc( GemApp.NbGemWindows, sizeof(TWINDOW_PARAMS) ) ;
  TWINDOW**       cur_tws ;
  GEM_WINDOW*     wnd ;
  short           n, sel ;

  if ( tmp_params == NULL ) return ;

  cur_tws = Xcalloc( GemApp.NbGemWindows, sizeof(TWINDOW*) ) ;
  if ( cur_tws == NULL )
  {
    Xfree( tmp_params ) ;
    return ;
  }

  wnd = GWGetNextWindow( NULL ) ;
  sel = n = 0 ;
  while ( wnd  )
  {
    if ( strcmp( wnd->ClassName, TWINDOW_CLASSNAME ) == 0 )
    {
      TWINDOW* tw = (TWINDOW*) wnd->Extension ;

      memcpy( &tmp_params[n], &tw->p, sizeof(TWINDOW_PARAMS) ) ;
      cur_tws[n] = tw ;
      if ( sel_params == &tw->p ) sel = n ;
      n++ ;
    }
    wnd = GWGetNextWindow( wnd ) ;
  }

  if ( form_twparams( tmp_params, n, sel ) == 1 )
  {
    short i ;

    for ( i = 0; i < n; i++ )
    {
      if ( memcmp( &cur_tws[i]->p, &tmp_params[i], sizeof(TWINDOW_PARAMS) ) != 0 )
      {
        LoggingDo(LL_INFO, "Updating line attributes for tail %s...", cur_tws[i]->p.FileName ) ;
        memcpy( &cur_tws[i]->p, &tmp_params[i], sizeof(TWINDOW_PARAMS) ) ;
        ReleaseTWData( cur_tws[i], TWRDF_ALL ) ;
        TWGetOrSetParams( NULL, &cur_tws[i]->p ) ;
      }
    }
  }

  Xfree( cur_tws ) ;
  Xfree( tmp_params ) ;
}

static void TWCopy2Clip(TWINDOW* tw)
{
  char path[PATH_MAX] ;

  mouse_busy() ;
  if ( clbd_getpath( path ) == 0 )
  {
    TWLINE* tw_line ;
    long    nout, nto_write ;
    short   fid ;
    char    buffer[768] ;

    strcat( path, "SCRAP.TXT" ) ;
    fid = Fcreate( path, 0 ) ;
    if ( fid >= 0 )
    {
      for ( tw_line = &tw->d.Lines[0]; tw_line < &tw->d.Lines[tw->d.NbLines]; tw_line++ )
      {
        if ( tw_line->lf_selected && tw_line->Text )
        {
          sprintf( buffer, "%s\r\n", tw_line->Text ) ;
          nto_write = strlen(buffer) ;
          nout      = Fwrite( fid, nto_write, buffer ) ;
          if ( nout != nto_write )
          {
            LoggingDo(LL_WARNING, "Can't write %d bytes to %s, error %ld", nto_write, path, nout ) ;
            break ;
          }
        }
      }
      Fclose( fid ) ;
    }
    else LoggingDo(LL_WARNING, "Can't create clipboard file %s, error %d", path, fid ) ;
  }
  mouse_restore() ;
}

static void TWSelectAll(TWINDOW* tw)
{
  TWLINE* tw_line ;

  for ( tw_line = &tw->d.Lines[0]; tw_line < &tw->d.Lines[tw->d.NbLines]; tw_line++ )
    tw_line->lf_selected = 1 ;

  GWInvalidate( tw->wnd ) ;
}

static void TWFindText(TWINDOW* tw)
{
  char*  (*str_search)(const char*, const char*) ;
  TWLINE* tw_line ;
  char*   string = NULL ;
  long    line ;
  short   another_run = tw->d.fparams.wrap ;

  if ( tw->d.NbLines == 0 ) return ;

  if ( tw->d.fparams.case_insensitive ) str_search = strstri ;
  else                                  str_search = strstr ;

  if ( tw->d.fparams.search_line == NULL )
  {
    if ( tw->d.fparams.reverse ) tw->d.fparams.search_line = &tw->d.Lines[tw->d.NbLines-1] ;
    else                         tw->d.fparams.search_line = &tw->d.Lines[0] ;
  }

  while ( (string == NULL) && (another_run >= 0) )
  {
    tw_line = tw->d.fparams.search_line ;
    if ( tw->d.fparams.reverse ) tw_line-- ;
    else                         tw_line++ ;
    line = (long) (tw_line-&tw->d.Lines[0]) ;
    LoggingDo(LL_INFO, "TWFindText: search for %s from line %ld (case %s, %swrap%s)", tw->d.fparams.string, line, tw->d.fparams.case_insensitive ? "insensitive":"sensitive", tw->d.fparams.wrap ? "":"no ", tw->d.fparams.reverse ? ", reverse":"") ;
    while ( (tw_line >= &tw->d.Lines[0]) && (tw_line < &tw->d.Lines[tw->d.NbLines]) )
    {
      if ( tw_line->Text )
      {
        string = str_search( tw_line->Text, tw->d.fparams.string ) ;
        if ( string ) break ;
      }
      if ( tw->d.fparams.reverse ) tw_line-- ;
      else                         tw_line++ ;
    }
    another_run-- ;
    if ( (string == NULL) && (another_run >=0) ) tw->d.fparams.reverse = 1-tw->d.fparams.reverse ;
    tw->d.fparams.search_line->lf_search = 0 ;
    tw->d.fparams.search_line = tw_line ;
    tw->d.fparams.search_line->lf_search = 1 ;
  }

  if ( string )
  {
    line = (long) (tw_line - &tw->d.Lines[0]) ;
    LoggingDo(LL_INFO, "TWFindText: found %s at line %ld", tw->d.fparams.string, line) ;
    line = ValidateUILine( line, tw->d.LastLine ) ;
    if ( line+tw->UINbLines-1 >= tw->d.LastLine ) line = tw->d.LastLine-tw->UINbLines+1 ;
    tw->UIFirstLine = ValidateUILine( line, tw->d.LastLine ) ;
    tw->UILastLine  = ValidateUILine( tw->UIFirstLine+tw->UINbLines-1, tw->d.LastLine ) ;
    GWInvalidate( tw->wnd ) ;
    UpdateVSlider( tw->wnd ) ;
  }
  else LoggingDo(LL_INFO, "TWFindText: %s NOT found", tw->d.fparams.string) ;
}

static int OnKeyPressed(void* wnd, int key)
{
  GEM_WINDOW* gwnd = (GEM_WINDOW*) wnd ;
  TWINDOW*    tw = (TWINDOW*) gwnd->Extension ;

  if ( tw )
  {
    switch( key )
    {
      case K_COPY:     TWCopy2Clip( tw ) ;
                       break ;
      case K_S_ALL:    TWSelectAll( tw ) ;
                       break ;
      case K_FIND:     if ( form_find( &tw->d.fparams ) == 1 ) TWFindText( tw ) ;
                       break ;
      case K_FINDNEXT: TWFindText( tw ) ;
                       break ;
      case K_PAUSE:    TWMsg( tw, TWMSG_INVPAUSE, NULL ) ;
                       menu_icheck( GemApp.Menu, M_PAUSE, tw->sf_pause ) ;
                       break ;
      case K_CLEAR:    TWMsg( tw, TWMSG_CLEAR, NULL ) ;
                       break ;
      case K_RELOAD:   TWMsg( tw, TWMSG_RELOAD, NULL ) ;
                       break ;
      case K_PARAMS:   TWParams( &tw->p ) ;
                       break ;
    }
  }

  return GW_EVTCONTINUEROUTING ;
}

int OnMenuSelected(void* wnd, int t_id, int m_id)
{
  int   code = GW_EVTCONTINUEROUTING ;
  short mids[] = { M_COPY, M_S_ALL, M_FIND, M_FINDNEXT, M_PARAMS, M_CLEAR, M_RELOAD, M_PAUSE } ;
  short keys[] = { K_COPY, K_S_ALL, K_FIND, K_FINDNEXT, K_PARAMS, K_CLEAR, K_RELOAD, K_PAUSE } ;
  short n, key = 0 ;

  for ( n = 0; n < ARRAY_SIZE(mids); n++ )
    if ( mids[n] == m_id ) { key = keys[n] ; break ; }

  if ( key ) code = OnKeyPressed( wnd, key ) ;

  GWOnMenuSelected( t_id, m_id ) ;

  return code ;
}

#pragma warn -par
static int OnRButtonDown(void* wnd, int mk_state, int mx, int my)
{
  int m_id ;

  m_id = popup_formdo_menu( M_COPY, -1 ) ;
  if ( m_id >= 0 ) OnMenuSelected( wnd, M_EDIT, m_id ) ;
  else if ( m_id == -3 ) LoggingDo(LL_WARNING,"Not enough memory for context popup") ;

  return GW_EVTSTOPROUTING ;
}

static int OnLButtonDown(void* wnd, int mk_state, int mx, int my)
{
  GEM_WINDOW* gwnd = (GEM_WINDOW*) wnd ;
  TWINDOW*    tw = (TWINDOW*) gwnd->Extension ;
  int         hcell = tw->p.HighLightData[0].TextType.hcell ;

  if ( hcell )
  {
    long nsel ;

    nsel = tw->UIFirstLine + my/hcell ;
    if ( nsel <= tw->UILastLine )
    {
      TWLINE* tw_line ;

      if ( mk_state & K_CTRL )
      {
        /* Control: add/remove to selection */
        tw->d.Lines[nsel].lf_selected = 1 - tw->d.Lines[nsel].lf_selected ;
      }

      if ( mk_state & (K_LSHIFT|K_RSHIFT) )
      {
        /* Right or Left Shift: extend selection */
        long s, e, tmp ;

        s = tw->UICurrentSel ;
        if ( s < 0 ) s = 0 ;
        e = nsel ;
        if ( s > e ) { s--; tmp = s ; s = e; e = tmp ; }
        else         s++ ;
        for ( tw_line = &tw->d.Lines[s]; tw_line <= &tw->d.Lines[e]; tw_line++ ) tw_line->lf_selected = 1 - tw_line->lf_selected ;
      }

      if ( mk_state == 0 )
      {
        char old_sel_state = tw->d.Lines[nsel].lf_selected ;

        /* No special key: remove all selected lines and invert current one */
        for ( tw_line = &tw->d.Lines[0]; tw_line < &tw->d.Lines[0]+tw->d.NbLines; tw_line++ )
          tw_line->lf_selected = 0 ;

        /* And invert current selection */
        tw->d.Lines[nsel].lf_selected = 1 - old_sel_state ;
      }
      tw->UICurrentSel = nsel ;
      GWInvalidate( gwnd ) ;
    }
  }

  return GW_EVTSTOPROUTING ;
}
#pragma warn +par

short TWCreate(TWINDOW_PARAMS* tw_params)
{
  GEM_WINDOW* wnd = GWCreateWindow( TWINDOW_WKIND, sizeof(TWINDOW), TWINDOW_CLASSNAME ) ;

  if ( wnd )
  {
    TWINDOW* tw = (TWINDOW*) wnd->Extension ;
    short    xo, yo, wo, ho ;

    memcpy( &tw->p, tw_params, sizeof(TWINDOW_PARAMS) ) ;
    if ( (tw_params->w == 0) || (tw_params->h == 0) ) open_where( wnd->window_kind, screen.fd_w >> 1, 8*16, &xo, &yo, &wo, &ho ) ;
    else
    {
      xo = tw_params->x ; yo = tw_params->y ;
      wo = tw_params->w ; ho = tw_params->h ;
    }
    if ( GWOpenWindow( wnd, xo, yo, wo, ho ) == 0 )
    {
      wnd->OnClose         = OnClose ;
      wnd->OnDraw          = OnDraw ;
      wnd->OnArrow         = OnArrow ;
      wnd->OnSize          = OnSize ;
      wnd->OnVSlider       = OnVSlider ;
      wnd->OnKeyPressed    = OnKeyPressed ;
      wnd->OnMenuSelected  = OnMenuSelected ;
      wnd->OnLButtonDown   = OnLButtonDown ;
      wnd->OnRButtonDown   = OnRButtonDown ;
      wnd->flags          |= FLG_MUSTCLIP ;

      GWSetWindowCaption( wnd, tw_params->FileName ) ;
      GWSetHSlider( wnd, 0 ) ;
      GWSetHSliderSize( wnd, 1000 ) ;
      if ( tw_params->TimerMs > 0 )
      {
        wnd->OnTimer = OnTimer ;
        GWSetTimer( wnd, tw_params->TimerMs, NULL ) ;
      }
      tw->wnd          = wnd ;
      tw->UICurrentSel = -1 ;
    }
    else
    {
      LoggingDo(LL_ERROR, "Can't open TWINDOW for %s", tw_params->FileName) ;
      GWDestroyWindow( wnd ) ;
      return -4 ;
    }
  }
  else
  {
    LoggingDo(LL_ERROR, "Can't create TWINDOW for %s", tw_params->FileName) ;
    return -3 ;
  }

  return 0 ;
}
