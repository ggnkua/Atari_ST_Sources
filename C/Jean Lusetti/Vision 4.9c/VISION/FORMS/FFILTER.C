#include <string.h>
#include <stdlib.h>

#include "..\tools\gwindows.h"
#include "..\tools\frecurse.h"
#include "..\tools\convol.h"

#include "defs.h"
#include "actions.h"
#include "feditfxx.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  GEM_WINDOW* wnd ;

  CONVOLUTION_FILTRE* filtre ;
  float hf ;
  int   first ;
  int   sel ;
  char  convol_img ;
}
WEXTENSION_FILTER ;


#define NB_MAX_CAR_NOM_FILTRE    14
CONVOLUTION_FILTRE* tab_filtre = NULL ;
int                 nb_filtres = 0 ;
char*               names ;


int GetFilterPathForLanguage(char* path, short refresh)
{
  static char path_filter[PATH_MAX] ;

  if ( (path_filter[0] == 0) || refresh )
  {
    FR_DATA fr_data ;

    sprintf( path_filter, "%s\\%s", config.path_filter, config.language ) ; /* Les filtres ont peut etre ete traduits...  */
    fr_data.flags      = 0 ;
    fr_data.path       = path_filter ;
    fr_data.mask       = "*.VCF" ;
    fr_data.log_file   = NULL ;
    fr_data.user_func  = NULL ;
    fr_data.user_data  = NULL ;
    nb_filtres = (int)count_files( 0, &fr_data ) ;
    if ( nb_filtres <= 0 )
    {
      strcpy( path_filter, config.path_filter ) ;
      nb_filtres = (int)count_files( 0, &fr_data ) ;
    }
  }

  strcpy( path, path_filter ) ;

  return nb_filtres ;
}

void cleanup_filters(void)
{
  if ( tab_filtre ) Xfree( tab_filtre ) ;
  if ( names ) Xfree( names ) ;
}

static void get_filterinfos(char* path, CONVOLUTION_FILTRE* tab, int nb_filtres)
{
  DTA                dta, *old_dta ;
  GEM_WINDOW*        wprog ;
  CONVOLUTION_FILTRE filtre ;
  int                ret ;
  int                nb = 0 ;
  char               name[PATH_MAX] ;
  char               buffer[200] ;

  sprintf( name, "%s\\*.VCF", path ) ;
  old_dta = Fgetdta() ;
  Fsetdta( &dta ) ;
  ret = Fsfirst( name, FA_ARCHIVE ) ;
  if ( ret != 0 ) return ;
  sprintf( buffer, "%s\\%s", path, dta.d_fname ) ;
  wprog = DisplayStdProg( vMsgTxtGetMsg(MSG_LOOKFILTERS) , "", "", CLOSER ) ;
  if ( convolution_loadfilter( buffer, &filtre ) == 0 )
  {
    strcpy( names, dta.d_fname ) ;
    memcpy( &tab[nb++], &filtre, sizeof(CONVOLUTION_FILTRE) ) ;
    Xfree( filtre.data ) ;
  }
  while ( Fsnext() == 0 )
  {
    sprintf( buffer, "%s\\%s", path, dta.d_fname ) ;
    if ( convolution_loadfilter( buffer, &filtre ) == 0 )
    {
      strcpy( names+13*nb, dta.d_fname ) ;
      memcpy( &tab[nb++], &filtre, sizeof(CONVOLUTION_FILTRE) ) ;
      Xfree( filtre.data ) ;
    }
    (void)GWProgRange( wprog, nb, nb_filtres, NULL ) ;
  }
  GWDestroyWindow( wprog ) ;
  Fsetdta( old_dta ) ;
}

static void setup_filters(GEM_WINDOW* wnd, CONVOLUTION_FILTRE* tab_filtre, int nb_filtres, int flag_show)
{
  WEXTENSION_FILTER* wext = wnd->DlgData->UserData ;
  OBJECT*            adr_convol = wnd->DlgData->BaseObject ;
  int                i, j, first ;
  char               buf[50] ;

  first = wext->first ;
  for ( i = CONVOL_INFO1; i <= CONVOL_INFOLAST; i++ )
  {
    memset( buf, ' ', sizeof(buf) ) ;
    if ( i-CONVOL_INFO1+first < nb_filtres )
    {
      j = (int) strlen( tab_filtre[i-CONVOL_INFO1+first].name ) ;
      if ( j > 15 ) j = 15 ;
      memcpy( buf, tab_filtre[i-CONVOL_INFO1+first].name, j ) ;
      j = (int) strlen( tab_filtre[i-CONVOL_INFO1+first].description ) ;
      if ( j > 21 ) j = 21 ;   
      memcpy( &buf[16], tab_filtre[i-CONVOL_INFO1+first].description, j ) ;
    }
    buf[37] = 0 ;
    write_text( adr_convol, i, buf ) ;
  }

  if ( flag_show )
  {
    float h ;

    for ( i = CONVOL_INFO1; i <= CONVOL_INFOLAST; i++ )
      GWObjcDraw( wnd, adr_convol, i ) ;

    h = (float) (adr_convol[CONVOL_BOX].ob_height-adr_convol[CONVOL_SLIDER].ob_height) ;
    adr_convol[CONVOL_SLIDER].ob_y = (int) (h*(float)first/(float)(nb_filtres-1-CONVOL_INFOLAST+CONVOL_INFO1)) ;
    GWObjcDraw( wnd, adr_convol, CONVOL_BOX ) ;
  }
}

static int reload_filters(void)
{
  char path[PATH_MAX] ;

  mouse_busy() ;
  nb_filtres = GetFilterPathForLanguage( path, 1 ) ;
  if ( nb_filtres < 0 ) return 0 ;
  if ( nb_filtres > 0 )
  {
    if ( names ) Xfree( names ) ;
    names = NULL ;
    if ( tab_filtre ) Xfree( tab_filtre ) ;
    tab_filtre = (CONVOLUTION_FILTRE*) Xcalloc( 4+nb_filtres, sizeof(CONVOLUTION_FILTRE) ) ; /* +4 for safety in case new files show up */
    if ( tab_filtre == NULL )
    {
      mouse_restore() ;
      form_error_mem() ;
      return -1 ;
    }
    names = (char*) Xcalloc( 4+nb_filtres, NB_MAX_CAR_NOM_FILTRE ) ;
    if ( names == NULL )
    {
      Xfree( tab_filtre ) ;
      tab_filtre = NULL ;
      mouse_restore() ;
      form_error_mem() ;
      return -1 ;
    }
  }

  get_filterinfos( path, tab_filtre, nb_filtres ) ;
  mouse_restore() ;
  
  return 0 ;
}

static void OnInitDialogFilter(void* w)
{
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FILTER* wext = wnd->DlgData->UserData ;
  OBJECT*            adr_convol = wnd->DlgData->BaseObject ;

  if ( tab_filtre == NULL )
    if ( reload_filters() < 0 ) return ;

  wext->first = 0 ;
  if ( vclip.gwindow == wext->wnd )
  {
    adr_convol[CONVOL_OBJSEL].ob_state  &= ~DISABLED ;
    adr_convol[CONVOL_TOBJSEL].ob_state &= ~DISABLED ;
    deselect(adr_convol, CONVOL_OBJIMG) ;
    select(adr_convol, CONVOL_OBJSEL) ;
  }
  else
  {
    adr_convol[CONVOL_OBJSEL].ob_state  |= DISABLED ;
    adr_convol[CONVOL_TOBJSEL].ob_state |= DISABLED ;
    select(adr_convol, CONVOL_OBJIMG) ;
    deselect(adr_convol, CONVOL_OBJSEL) ;
  }

  wext->hf =(float) (adr_convol[CONVOL_BOX].ob_height-adr_convol[CONVOL_SLIDER].ob_height) ;
  setup_filters( wnd, tab_filtre, nb_filtres, 0 ) ;
  adr_convol[CONVOL_SLIDER].ob_y = 0 ;
  if ( nb_filtres > 0 )
    adr_convol[CONVOL_SLIDER].ob_height = (int) ((float)adr_convol[CONVOL_BOX].ob_height*(float)(1+CONVOL_INFOLAST-CONVOL_INFO1)/(float)nb_filtres) ;
  else
    adr_convol[CONVOL_SLIDER].ob_height = adr_convol[CONVOL_BOX].ob_height ;
  if (adr_convol[CONVOL_SLIDER].ob_height > adr_convol[CONVOL_BOX].ob_height)
    adr_convol[CONVOL_SLIDER].ob_height = adr_convol[CONVOL_BOX].ob_height ;
}

static int OnObjectNotifyFilter(void* w, int obj)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FILTER*  wext = wnd->DlgData->UserData ;
  OBJECT*             adr_convol = wnd->DlgData->BaseObject ;
  CONVOLUTION_FILTRE* filtre = wext->filtre ;
  float               pc ;
  int                 i, code = -1 ;
  int                 mx, my, dummy, y ;
  char                buf[200] ;
  char                path_filter[PATH_MAX] ;

  GetFilterPathForLanguage( path_filter, 0 ) ;
  switch( obj )
  {
    case CONVOL_EDITTHIS : for ( i = CONVOL_INFO1; i <= CONVOL_INFOLAST; i++ )
                             if ( selected(adr_convol, i) ) break ;
                           sprintf( buf, "%s\\%s", path_filter, names+13*(wext->first+i-CONVOL_INFO1) ) ;
                           if ( convolution_loadfilter( buf, filtre ) ) vform_stop( MSG_BADFILTER ) ;
                           else                                         { edit_filterxx( filtre, filtre->w ) ; Xfree( filtre->data ) ; }
                           deselect( adr_convol, obj ) ;
                           break ;
    case CONVOL_EDIT33   : deselect( adr_convol, obj ) ;
                           edit_filterxx( NULL, 3 ) ;
                           break ;
    case CONVOL_EDIT55   : deselect( adr_convol, obj ) ;
                           edit_filterxx( NULL, 5 ) ;
                           break ;
    case CONVOL_TOBJSEL  : if ( adr_convol[CONVOL_TOBJSEL].ob_state & DISABLED ) break ;
                           if ( !selected(adr_convol, CONVOL_OBJSEL) )
                           {
                             adr_convol[CONVOL_OBJSEL].ob_state |= SELECTED ;
                             adr_convol[CONVOL_OBJIMG].ob_state &= ~SELECTED ;
                             GWObjcDraw( wnd, adr_convol, CONVOL_OBJSEL ) ;
                             GWObjcDraw( wnd, adr_convol, CONVOL_OBJIMG ) ;
                           }
                           break ;
    case CONVOL_TOBJIMG  : if ( !selected(adr_convol, CONVOL_OBJIMG) )
                           {
                             adr_convol[CONVOL_OBJIMG].ob_state |= SELECTED ;
                             adr_convol[CONVOL_OBJSEL].ob_state &= ~SELECTED ;
                             GWObjcDraw( wnd, adr_convol, CONVOL_OBJSEL ) ;
                             GWObjcDraw( wnd, adr_convol, CONVOL_OBJIMG ) ;
                           }
                           break ;
    case CONVOL_MOINS    : if ( wext->first > 0 )
                           {
                             for ( i = CONVOL_INFO1; i <= CONVOL_INFOLAST; i++ )
                               if ( selected(adr_convol, i) ) break ;
                             if ( i != CONVOL_INFOLAST )
                             {
                               deselect( adr_convol, i ) ;
                               select( adr_convol, i+1 ) ;
                             }
                             wext->first-- ;
                             setup_filters( wnd, tab_filtre, nb_filtres, 1 ) ;
                           }
                           break ;
    case CONVOL_PLUS     : if ( wext->first+1+CONVOL_INFOLAST-CONVOL_INFO1 < nb_filtres )
                           {
                             for ( i = CONVOL_INFO1; i <= CONVOL_INFOLAST; i++ )
                               if ( selected(adr_convol, i) ) break ;
                             if ( i != CONVOL_INFO1 )
                             {
                               deselect( adr_convol, i ) ;
                               select( adr_convol, i-1 ) ;
                             }
                             wext->first++ ;
                             setup_filters( wnd, tab_filtre, nb_filtres, 1 ) ;
                           }
                           break ;
    case CONVOL_BOX      : graf_mkstate( &mx, &my, &dummy, &dummy ) ;
                           objc_offset( adr_convol, CONVOL_SLIDER, &dummy, &mx ) ;
                           if ( my > mx ) wext->first += 1+CONVOL_INFOLAST-CONVOL_INFO1 ;
                           else           wext->first -= 1+CONVOL_INFOLAST-CONVOL_INFO1 ;
                           if ( wext->first < 0 ) wext->first = 0 ;
                           if ( wext->first+1+CONVOL_INFOLAST-CONVOL_INFO1 > nb_filtres )
                             wext->first = nb_filtres-1-CONVOL_INFOLAST+CONVOL_INFO1 ;
                           setup_filters( wnd, tab_filtre, nb_filtres, 1 ) ;
                           break ;
    case CONVOL_SLIDER   : pc = (float)graf_slidebox( adr_convol, CONVOL_BOX, CONVOL_SLIDER, 1 ) ;
                           pc = (1000.0-pc)/10.0 ;
                           y  = (int) ((100.0-pc)*(float)wext->hf/100.0) ;
                           adr_convol[CONVOL_SLIDER].ob_y = y ;
                           wext->first = (int) ((float)y*(float)(nb_filtres-1-CONVOL_INFOLAST+CONVOL_INFO1)/wext->hf) ;
                           setup_filters( wnd, tab_filtre, nb_filtres, 1 ) ;
                           break ;
    case CONVOL_RELOAD   : wext->hf =(float)(adr_convol[CONVOL_BOX].ob_height-adr_convol[CONVOL_SLIDER].ob_height) ;
                           if ( reload_filters() == 0 )
                           {
                             wext->first = 0 ;
                             setup_filters( wnd, tab_filtre, nb_filtres, 0 ) ;
                             adr_convol[CONVOL_SLIDER].ob_y = 0 ;
                             if ( nb_filtres > 0 )
                               adr_convol[CONVOL_SLIDER].ob_height = (int) ((float)adr_convol[CONVOL_BOX].ob_height*(float)(1+CONVOL_INFOLAST-CONVOL_INFO1)/(float)nb_filtres) ;
                             else
                               adr_convol[CONVOL_SLIDER].ob_height = adr_convol[CONVOL_BOX].ob_height ;
                             if ( adr_convol[CONVOL_SLIDER].ob_height > adr_convol[CONVOL_BOX].ob_height )
                               adr_convol[CONVOL_SLIDER].ob_height = adr_convol[CONVOL_BOX].ob_height ;
                           }
                           deselect( adr_convol, obj ) ;
                           break ;
     case CONVOL_OK      : code = IDOK ;
                           break ;
     case CONVOL_CANCEL  : code = IDCANCEL ;
                           break ;
  }

  if ( code == IDOK )
  {
    wext->sel = 0 ;
    for ( i = CONVOL_INFO1; i <= CONVOL_INFOLAST; i++ )
      if ( selected(adr_convol, i) ) wext->sel = i ;

    wext->convol_img = selected( adr_convol, CONVOL_OBJIMG ) ;
  }

  return code ;
}

int FGetFilter(WEXTENSION_FILTER* wext)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_CONVOLUTION ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogFilter ;
  dlg_data.OnObjectNotify = OnObjectNotifyFilter ;

  return GWCreateAndDoModal( &dlg_data, 0 ) ;
}

int choose_filter(CONVOLUTION_FILTRE* filtre, GEM_WINDOW* gwnd)
{
  WEXTENSION_FILTER wext ;
  char              buf[PATH_MAX] ;
  char              path_filter[PATH_MAX] ;

  if ( gwnd == NULL ) return 0 ;
  wext.wnd    = gwnd ;
  wext.filtre = filtre ;

  if ( FGetFilter( &wext ) != IDOK ) return 0 ;

  GetFilterPathForLanguage( path_filter, 0 ) ;
  sprintf( buf, "%s\\%s", path_filter, names+13*(wext.first+wext.sel-CONVOL_INFO1) ) ;
  if ( convolution_loadfilter( buf, filtre ) )
  {
    vform_stop( MSG_BADFILTER ) ;
    return 0 ;
  }

  if ( wext.convol_img ) return 1 ;
  else                   return 2 ;
}
