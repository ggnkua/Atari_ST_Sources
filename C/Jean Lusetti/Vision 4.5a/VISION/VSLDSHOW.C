#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "..\tools\stdprog.h"
#include "..\tools\stdinput.h"
#include "..\tools\xgem.h"
#include "..\tools\gwindows.h"
#include "..\tools\rasterop.h"
#include "..\tools\rzoom.h"
#include "..\tools\xfile.h"
#include "..\tools\image_io.h"
#include "..\tools\logging.h"
#include "touches.h"
#include "actions.h"
#include "vsldshow.h"
#include "visionio.h"

#define IGNORE_SPACES( c )  while ( ( *c == ' ' ) || ( *c == '\t' ) ) c++ 

#define TESC         0x011B    /* Escape */
#define TCTRL_C      0x2E03

#define STATUS_LOADING  0
#define STATUS_SCALING  1
#define STATUS_WAITING  2

typedef struct
{
  char *cmd_txt ;
  int  cmd_id ;
}
CMD_TXTID ;

CMD_TXTID cmds[] = {
                     { "rem", CMD_REMARK },
                     { "display", CMD_DISPLAY },
                     { NULL, CMD_NULL },
                   } ;

int nb_steps ;
int stop_sldshow ;
int num_courant, num_total ;
int txt_color ;
int back_color ;
int yprog ;

void aff_text(char *text, int x, int y, int color)
{
  TEXT_TYPE old_ttype ;

  memcpy( &old_ttype, &ttype, sizeof(TEXT_TYPE) ) ;
  ttype.angle     = 0 ;
  ttype.color     = color ;
  ttype.attribute = 0 ;
/*  ttype.font      = 1 ;  SystŠme */
/*  ttype.hcar      = 6 ;*/
  set_texttype( &ttype ) ;
  vswr_mode( handle, MD_TRANS ) ;
  v_gtext( handle, x, y, text ) ;
  memcpy( &ttype, &old_ttype, sizeof(TEXT_TYPE) ) ;
  set_texttype( &ttype ) ;
}

void display_status(int status)
{
  int x_align, y_align ;
  int xy[8] ;
  char txt[50] ;

  switch (status )
  {
    case STATUS_LOADING : strcpy( txt, "Loading..." ) ;
                          break ;

    case STATUS_SCALING : strcpy( txt, "Scaling..." ) ;
                          break ;

    case STATUS_WAITING : strcpy( txt, "Waiting..." ) ;
                          break ;

    default             : strcpy( txt, "          " ) ;
  }
  vsf_color( handle, back_color ) ;
  vsf_interior( handle, FIS_SOLID ) ;
  vqt_extent( handle, txt, xy ) ;
  xy[2] = xy[4] ; xy[3] = xy[5] ;
  yprog = xy[3] + ttype.hcar ;
  v_hide_c(handle) ;
  vr_recfl( handle, xy ) ;
  v_show_c(handle, 1) ;
  vst_alignment( handle, 0, 1, &x_align, &y_align ) ;
  aff_text( txt, 0, ttype.hcar, txt_color ) ;
  vst_alignment( handle, x_align, y_align, &x_align, &y_align ) ;
}

void vss_tronque(char *s, char *cmd, char *params)
{
  char *c ;
  char *d = cmd ;
  char *rem ;

  c = s ;  
  IGNORE_SPACES( c ) ;
  while ( ( *c != 0 ) && ( *c != ' ' ) && ( *c != '\t' ) )
    *d++ = *c++ ;
  *d = 0 ;

  /* Elimine un commentaire en fin de ligne */
  IGNORE_SPACES( c ) ;
  
  rem = strchr( c, ';' ) ;
  if ( rem != NULL ) *rem = 0 ;
  if ( *c != 0 ) strcpy( params, c ) ;
  c = params + strlen( params ) - 1 ;
  while ( ( *c == ' ' ) || ( *c == '\t' ) ) c-- ;
  *(1+c) = 0 ;
}

int add_cmd(VSS_INFO *vss_info,  int cmd_id, char *params)
{
  size_t plen = 1+strlen(params) ;

  if ( plen+vss_info->nbytes < vss_info->buffer_params_size )
  {
    vss_info->cmds[vss_info->ncmds].params = &vss_info->buffer_params[vss_info->nbytes] ;
    strcpy( &vss_info->buffer_params[vss_info->nbytes], params ) ;
    vss_info->buffer_params[vss_info->nbytes+plen-1] = 0 ;
    vss_info->nbytes += plen ;
  }
  else
  {
    LoggingDo(LL_ERROR, "Buffer for parameters overflow (#commands=%ld)", vss_info->ncmds);
    return VSSERR_MEMORY ;
  }

  if ( vss_info->ncmds < vss_info->nb_cmd )
  {
    vss_info->cmds[vss_info->ncmds].cmd_id = cmd_id ;
    vss_info->ncmds++ ;
  }
  else
  {
    LoggingDo(LL_ERROR, "Too many commands (%ld, expected %ld)", vss_info->ncmds, vss_info->nb_cmd);
    return VSSERR_MEMORY ;
  }

  return VSSERR_NOERROR ;
}

int vss_parse(char *string, VSS_INFO *vss_info)
{
  int  err = 0 ;
  int  cmd_reconnue = 0 ;
  int  num_cmd = 0 ;
  char *s, *c ;
  char cmd[50] ;
  char params[400] ;

  s = strlwr( string ) ;

  c = strchr( s, '\r' ) ;
  if ( c != NULL ) *c = 0 ;
  c = strchr( s, '\n' ) ;
  if ( c != NULL ) *c = 0 ;

  vss_tronque( s, cmd, params ) ;
  if ( cmd[0] != ID_REMARK )
  {
    while ( !cmd_reconnue && ( cmds[num_cmd].cmd_id != CMD_NULL ) )
    {
      if ( strcmp( cmds[num_cmd].cmd_txt, cmd ) == 0 )
      {
        cmd_reconnue = 1 ;
        err = add_cmd( vss_info, cmds[num_cmd].cmd_id, params ) ;
        if ( !err && ( cmds[num_cmd].cmd_id == CMD_DISPLAY ) ) num_total++ ;
      }
      else
        num_cmd++ ;
    }
    if ( !cmd_reconnue ) err = VSSERR_CMDUNKNOWN ;
  }

  return( err ) ;
}

int vss_load(char *name, VSS_INFO *vss_info)
{
  FILE* stream ;
  int   err = VSSERR_NOERROR ;

  num_total = 0 ;
  memset( vss_info, 0, sizeof(VSS_INFO) ) ;
  vss_info->nb_cmd = FileTxtStats( name, &vss_info->buffer_params_size ) ;
  if ( vss_info->nb_cmd <= 0 )
  {
    LoggingDo(LL_ERROR, "VSS file %s is invalid (status %ld)", name, vss_info->nb_cmd);
    return VSSERR_FILE ;
  }

  vss_info->buffer_params_size -= vss_info->nb_cmd * 8 ; /* Remove "Display " characters for each line to save memory */
  vss_info->buffer_params = Xalloc( vss_info->buffer_params_size ) ;
  if ( vss_info->buffer_params == NULL )
  {
    LoggingDo(LL_ERROR, "Unable to allocate %ld bytes to hold parameters", vss_info->buffer_params_size);
    return VSSERR_MEMORY ;
  }

  vss_info->cmds = Xcalloc( vss_info->nb_cmd, sizeof(CMD) ) ;
  if ( vss_info->cmds == NULL )
  {
    LoggingDo(LL_ERROR, "Unable to allocate %ld commands", vss_info->cmds);
    Xfree( vss_info->buffer_params ) ;
    return VSSERR_MEMORY ;
  }

  stream = fopen( name, "rb" ) ;
  if ( stream != NULL )
  {
    char s[400] ;

    while ( !err && fgets( s, (int)sizeof(s), stream ) )
    {
      vss_info->line_err++ ;
      err = vss_parse( s, vss_info ) ;
    }
    fclose( stream ) ;
    LoggingDo(LL_INFO, "%ld bytes used for parameters (%ld allocated)", vss_info->nbytes, vss_info->buffer_params_size);
    LoggingDo(LL_INFO, "%ld commands parsed (%ld allocated)", vss_info->ncmds, vss_info->nb_cmd);
  }
  else
    err = VSSERR_FILE ;

  vss_info->err = err ;
  
  return VSSERR_NOERROR ;
}

void strech_img(MFDB *mfdb)
{
  MFDB  out ;
  float x_level , y_level, level ;

  display_status( STATUS_SCALING ) ;
  x_level = (float)(Xmax-2)/(float)mfdb->fd_w ;
  y_level = (float)(Ymax-2)/(float)mfdb->fd_h ;
  if (x_level > y_level) level = y_level ;
  else                   level = x_level ;
  out.fd_addr = NULL ;
  out.fd_w = (int) ( 0.5 + (float)mfdb->fd_w * level ) ;
  out.fd_h = (int) ( 0.5 + (float)mfdb->fd_h * level ) ;
  if ( RasterZoom( mfdb, &out, NULL ) == 0 )
  {
    Xfree( mfdb->fd_addr ) ;
    memcpy( mfdb, &out, sizeof(MFDB) ) ;
  }
}

int load_nextimg(char *name, MFDB *mfdb, INFO_IMAGE *inf, VSS_INFO *vss_info, GEM_WINDOW *wprog)
{
  int ret ;

  display_status( STATUS_LOADING ) ;
  ret = img_format( name, inf ) ;
  if ( ret != 0 )
  {
    if ( inf->palette ) Xfree( inf->palette ) ;
  }
  else
  {
    memset( mfdb, 0, sizeof(MFDB) ) ;
    mfdb->fd_nplanes = nb_plane ;
    if ( nb_plane == 16 ) Force16BitsLoad = 1 ;
    else                  Force16BitsLoad = 0 ;
    mouse_busy() ;
    ret = load_picture( name, mfdb, inf, wprog ) ;
    mouse_restore() ;
    mfdb->fd_w = inf->largeur ; /* Evite la bande sur la droite */
    if ( ( vss_info->display_type & DISPLAYTYPE_ZOOM ) &&
        ( ( mfdb->fd_w < 1+Xmax ) || ( mfdb->fd_h < 1+Ymax ) )
      )
     strech_img( mfdb ) ;
   else
    if ( ( vss_info->display_type & DISPLAYTYPE_REDUC ) &&
         ( ( mfdb->fd_w > 1+Xmax ) || ( mfdb->fd_h > 1+Ymax ) )
      )
     strech_img( mfdb ) ;
  }

  log_event( CMD_DISPLAY, name ) ;

  return( ret ) ;
}

int wait_for_event(VSS_INFO *vss_info)
{
  EVENT  event ;
  size_t load_time ;
  int    ret = 0 ;
  int    which ;

  display_status( STATUS_WAITING ) ;

  memset( &event, 0, sizeof(EVENT) ) ;
  event.ev_mflags     = MU_KEYBD | MU_TIMER | MU_BUTTON ;
  if ( vss_info->wait_mini_sec < 0 ) event.ev_mflags &= ~MU_TIMER ;
  event.ev_mbclicks   = 258 ;
  event.ev_bmask      = 3 ;
  event.ev_mtlocount  = 0 ;
  event.ev_mthicount  = 0 ;
  load_time           = PerfInfo.total_load_time ;
  if ( 100L*vss_info->wait_mini_sec > load_time )
    event.ev_mtlocount = (int) ( 1000L*vss_info->wait_mini_sec - 10L*load_time ) ;

  which = EvntMulti( &event ) ;
  if ( which & MU_KEYBD )
    if ( event.ev_mkreturn == TESC ) ret = -1 ;

  return( ret ) ;
}

void compute_colors(VSS_INFO *vss_info, INFO_IMAGE *inf)
{
  int rvb[3] ;

  /* Prend la couleur inverse du fond */
  if ( vss_info->back == BACK_WHITE )
  {
    rvb[0] = rvb[1] = rvb[2] = 0 ;
    txt_color = 20 ;
  }
  else
  {
    rvb[0] = rvb[1] = rvb[2] = 1000 ;
    txt_color = 21 ;
  }
  if ( !Truecolor && ( inf->palette != NULL ) )
  {
    txt_color = get_nearest_vdi_index( rvb, inf->palette, inf->nb_cpal ) ;
  }
  else
  {
    txt_color = 18 ;
    vs_color( handle, txt_color, rvb ) ;
  }

  if ( vss_info->back == BACK_WHITE )
  {
    rvb[0] = rvb[1] = rvb[2] = 1000 ;
    back_color = 20 ;
  }
  else
  {
    rvb[0] = rvb[1] = rvb[2] = 0 ;
    back_color = 21 ;
  }
  if ( !Truecolor )
  {
    if ( inf->palette != NULL )
      back_color = get_nearest_vdi_index( rvb, inf->palette, inf->nb_cpal ) ;
    else
      back_color = 0 ;
  }
  else
  {
    back_color = 20 ;
    vs_color( handle, back_color, rvb ) ;
  }
}

void sldcls_screen(VSS_INFO *vss_info, INFO_IMAGE *inf)
{
  int xyarray[4] ;

  compute_colors( vss_info, inf ) ;

  if ( !vss_info->do_not_cls_scr )
  {
    xyarray[0] = 0 ; xyarray[1] = 0 ;
    xyarray[2] = Xmax ; xyarray[3] = Ymax ;
    vsf_color( handle, back_color ) ;
    vsf_interior( handle, FIS_SOLID ) ;
    if ( !vss_info->do_not_show_mouse )
      v_hide_c(handle) ;
    vr_recfl(handle, xyarray) ;
    if ( !vss_info->do_not_show_mouse )
      v_show_c(handle, 1) ;
  }
}

void show_img(MFDB *mfdb, int xy[8], int type_transition)
{
  int     pxy[8] ;
/*  int     xyc[8] ;*/
  int     passe, x, y, step ;
/*  int     x1, y1, x2, y2, w, h ;
  int     m_x = 32 ;
  int     m_y = 32 ;*/
/*  clock_t t ;*/

  memcpy( pxy, xy, 8*sizeof(int) ) ;
  step = 10 ;
  switch( type_transition )
  {
    case TRANSITION_VLINES  : for ( passe = 0; passe < step; passe++ )
                              {
                                pxy[1] = xy[1]+passe ;
                                pxy[5] = xy[5]+passe ;
                                for ( y = passe; y < xy[3]-xy[1]; y += step )
                                {
                                  pxy[3] = pxy[1] ;
                                  pxy[7] = pxy[5] ;
/*                                  t = clock() ;*/
                                  vro_cpyfm( handle, S_ONLY, pxy, mfdb, &screen ) ;
/*                                  if ( clock()-t < 10 ) evnt_timer( 1, 0 ) ;*/
                                  pxy[1] += step ;
                                  pxy[5] += step ;
                                }
                              }
                              break ;
    case TRANSITION_HLINES  : for ( passe = 0; passe < step; passe++ )
                              {
                                pxy[0] = xy[0]+passe ;
                                pxy[4] = xy[4]+passe ;
                                for ( x = passe; x < xy[2]-xy[0]; x += step )
                                {
                                  pxy[2] = pxy[0] ;
                                  pxy[6] = pxy[4] ;
/*                                  t = clock() ;*/
                                  vro_cpyfm( handle, S_ONLY, pxy, mfdb, &screen ) ;
/*                                  if ( clock()-t < 2 ) evnt_timer( 1, 0 ) ;*/
                                  pxy[0] += step ;
                                  pxy[4] += step ;
                                }
                              }
                              break ;
/*    case TRANSITION_MOSAIC  : w = 1+pxy[6]-pxy[4] ;
                              h = 1+pxy[7]-pxy[5] ;
                              memcpy( xyc, pxy, 8*sizeof(int) ) ;
                              x1 = pxy[4] ; y1 = pxy[5] ;
                              x2 = pxy[6] ; y2 = pxy[7] ;
                              while ( ( w > 0 ) || ( h > 0 ) )
                              {
                                for ( x = x1; x < x1+w; x += m_x )
                                {
                                  xyc[0] = x1-pxy[4] ;    xyc[4] = x ;
                                  xyc[1] = y1-pxy[5] ;    xyc[5] = y1 ;
                                  xyc[2] = xyc[0]+m_x-1 ; xyc[6] = xyc[4]+m_x-1 ;
                                  xyc[3] = xyc[1]+m_y-1 ; xyc[7] = xyc[5]+m_y-1 ;
                                  vro_cpyfm( handle, S_ONLY, xyc, mfdb, &screen ) ;
                                }
                                y1 += m_y ;
                                
                                for ( y = y1; y < y1+h; y += m_y )
                                {
                                  xyc[0] = 1+x2-pxy[4]-m_x ; xyc[4] = x2 ;
                                  xyc[1] = y-pxy[5] ;        xyc[5] = y1 ;
                                  xyc[2] = xyc[0]+m_x-1 ;    xyc[6] = xyc[4]+m_x-1 ;
                                  xyc[3] = xyc[1]+m_y-1 ;    xyc[7] = xyc[5]+m_y-1 ;
                                  vro_cpyfm( handle, S_ONLY, xyc, mfdb, &screen ) ;
                                }
                                x2 -= m_x ;
                                
                              }
                              break ;*/
    default                 : vro_cpyfm( handle, S_ONLY, xy, mfdb, &screen ) ;
                              break ;
  }
}

void display_img(MFDB *mfdb, INFO_IMAGE *inf, VSS_INFO *vss_info,  char *name)
{
  int yt ;
  int xy[8] ;
  int off_x, off_y ;
  int x_align, y_align ;

  off_x = off_y = 0 ;
  xy[0] = xy[1] = 0 ;
  xy[2] = mfdb->fd_w - 1 ;
  if ( xy[2] > Xmax ) xy[2] = Xmax ;
  xy[3] = mfdb->fd_h - 1 ;
  if ( xy[3] > Ymax ) xy[3] = Ymax ;

  if ( Xmax > mfdb->fd_w )
    off_x = (Xmax-mfdb->fd_w)/2 ;
  if ( Ymax > mfdb->fd_h )
    off_y = (Ymax-mfdb->fd_h)/2 ;

  xy[4] = off_x ;
  xy[5] = off_y ;
  xy[6] = off_x + xy[2] ;
  xy[7] = off_y + xy[3] ;

  if ( !Truecolor && ( inf->palette != NULL ) )
    set_tospalette( inf->palette, (int) (inf->nb_cpal) ) ;

  if ( !vss_info->do_not_show_mouse )
    v_hide_c(handle) ;
    
  show_img( mfdb, xy, vss_info->transition ) ;
  if ( vss_info->aff_name )
  {
    yt = ttype.hcar ;
    vst_alignment( handle, 1, 1, &x_align, &y_align ) ;
    vqt_extent( handle, name, xy ) ;  
    aff_text( name, ( Xmax - xy[0] - xy[2] ) /2, yt, txt_color ) ;
    vst_alignment( handle, x_align, y_align, &x_align, &y_align ) ;
  }

  if ( vss_info->aff_prog )
  {
    char txt_prog[20] ;
  
    sprintf( txt_prog, "%d/%d", 1+num_courant, num_total ) ;
    vst_alignment( handle, 0, 2, &x_align, &y_align ) ;
    aff_text( txt_prog, 0, yprog, txt_color ) ;
    vst_alignment( handle, x_align, y_align, &x_align, &y_align ) ;
  }

  if ( !vss_info->do_not_show_mouse )
    v_show_c(handle, 1) ;
}

int OnKeyPressedSldShow(int key)
{
  int code ;

  switch( key )
  {
    case CURSOR_RT :
    case TCTRL_C   :
                     code = GW_EVTQUITAPP ;
                     break ;
    case TESC      : code = GW_EVTQUITAPP ;
                     stop_sldshow = 1 ;
                     break ;
  }

  return( code ) ;
}

void vss_doslideshow(VSS_INFO *vss_info)
{
  GEM_WINDOW *wprog ;
  int        (*OnKeyPressed)(int key) ;
  INFO_IMAGE inf ;
  MFDB       mfdb ;
  CMD        *cmd ;
  int        fini = 0 ;
  int        current_pal[256*3] ;
  int        load_ret ;

  OnKeyPressed        = GemApp.OnKeyPressed ;
  GemApp.OnKeyPressed = OnKeyPressedSldShow ;
  get_tospalette( current_pal ) ;
  cmd = vss_info->cmds ;
  if ( cmd == NULL ) fini = 1 ;
  if ( vss_info->do_not_show_mouse )
    v_hide_c( handle ) ;

  /* Prend la configuration courante */
  vss_info->wait_mini_sec     = config.wait_mini_sec ;
  vss_info->do_not_show_mouse = config.do_not_show_mouse ;
  vss_info->do_not_cls_scr    = config.do_not_cls_scr ;
  vss_info->back              = config.back ;
  vss_info->display_type      = config.display_type ;
  vss_info->transition        = config.transition ;
  vss_info->cycle             = config.cycle ;
  vss_info->ignore_vss        = config.ignore_vss ;
  vss_info->aff_name          = config.aff_name ;
  vss_info->aff_prog          = config.aff_prog ;

  if ( Truecolor )
  {
    int rvb_blanc[3] = { 1000, 1000, 1000 } ;
    int rvb_noir[3]  = {    0,    0,    0 } ;
  
    vs_color(handle, 20, rvb_blanc) ;
    vs_color(handle, 21, rvb_noir) ;
  }  
  stop_sldshow = 0 ;
  num_courant  = 0 ;
  wprog = DisplayStdProg( "", "", "", 0 ) ;
  GWShowWindow( wprog, 0 ) ;
  while ( !fini )
  {
    nb_steps = 0 ;
    switch( cmd->cmd_id )
    {
      case CMD_DISPLAY     : LoggingDo(LL_INFO, "Slide-show: loading %s...", cmd->params);
                             load_ret = load_nextimg( cmd->params, &mfdb, &inf, vss_info, wprog ) ;
                             if ( load_ret == 0 )
                             {
                               compute_colors( vss_info, &inf ) ;
                               if ( ( num_courant > 0 ) && ( wait_for_event( vss_info ) < 0 ) )
                                 fini = 1 ;
                               else
                               {
                                 sldcls_screen( vss_info, &inf ) ;
                                 display_img( &mfdb, &inf, vss_info, cmd->params ) ;
                               }
                             }
                             if ( load_ret == 0 )
                             {
                               if ( inf.palette != NULL ) Xfree( inf.palette ) ;
                               memset( &inf, 0, sizeof(INFO_IMAGE) ) ;
                               if ( mfdb.fd_addr != NULL ) Xfree( mfdb.fd_addr ) ;
                             }
                             nb_steps++ ;
                             break ;
      default              : /* Impossible */
                             break ;
    }

    num_courant += nb_steps ;
    if ( num_courant < vss_info->ncmds ) cmd += nb_steps ;
    else if ( vss_info->cycle )
    {
      cmd = vss_info->cmds ;
      num_courant = 0 ;
    }
    else cmd = NULL ;

    if ( stop_sldshow || !cmd ) fini = 1 ;
  }

  if ( !cmd )
  {
    PerfInfo.total_load_time = 0 ;
    wait_for_event( vss_info ) ;
  }
  restore_gemscreen( GemApp.Menu ) ;
  set_tospalette( current_pal, nb_colors ) ;
  if ( vss_info->do_not_show_mouse )
    v_show_c( handle, 1 ) ;

  GWDestroyWindow( wprog ) ;
  GemApp.OnKeyPressed = OnKeyPressed ;
}

void vss_free(VSS_INFO *vss_info)
{
  Xfree( vss_info->buffer_params ) ;
  Xfree( vss_info->cmds ) ;
}
