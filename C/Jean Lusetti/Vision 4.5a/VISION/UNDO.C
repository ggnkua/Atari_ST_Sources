/*******************/
/* Gestion du Undo */
/*******************/
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

#include     "..\tools\stdprog.h"
#include     "..\tools\stdinput.h"
#include     "..\tools\xgem.h"
#include  "..\tools\imgmodul.h"
#include  "..\tools\clipbrd.h"
#include "..\tools\rasterop.h"

#include            "undo.h"
#include          "gstenv.h"
#include         "actions.h"
#include        "visionio.h"
#include        "ldv\ldvcom.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

#define REDO     UREFAIRE

#define GET_UNDO_DEF_FROM_LIST_ENTRY(x) CONTAINING_RECORD((x), UNDO_DEF, ListEntry)
#define GET_LIST_ENTRY_FROM_UNDO_DEF(x) (&(x)->ListEntry)

UNDO_DEF clipboard ;  /* Buffer Couper/Coller ...             */
int      UndoNum ;   /* Pour identification du nom de fichier */


UNDO_DEF *AllocateNewUndoBuffer(GEM_WINDOW *gwnd)
{
  UNDO_DEF *undo ;
  VXIMAGE *vimage ;

  vimage = (VXIMAGE *) gwnd->Extension ;
  if ( ( vimage->NbUndoBuffers >= config.nb_undo ) && !IsListEmpty( &vimage->UndoListHead ) )
  {
    LIST_ENTRY *entry ;

    entry = RemoveTailList( &vimage->UndoListHead ) ;
    undo  = GET_UNDO_DEF_FROM_LIST_ENTRY( entry ) ;
    FreeUndoBuffer( undo ) ;
  }

  undo = (UNDO_DEF *) Xcalloc( 1, sizeof(UNDO_DEF) ) ;
  if ( undo )
  {
    undo->undo_num = UndoNum++ ;
    undo->gwindow  = gwnd ;
    vimage->NbUndoBuffers++ ;
  }

  return( undo ) ;
}

void set_modif(GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage ;

  if ( !GWIsWindowValid( gwnd ) ) return ;

  vimage = (VXIMAGE *) gwnd->Extension ;
  if ( vimage->modif == 0 )
  {
    char nom[60] ;
    
    vimage->modif = 1 ;
    sprintf( nom, "*%s", vimage->nom ) ;
    GWSetWindowCaption( gwnd, nom ) ;
  }
  if ( gwnd->window_icon.fd_addr )
  {
    Xfree( gwnd->window_icon.fd_addr ) ;
    memset( &gwnd->window_icon, 0, sizeof(MFDB) ) ;
  }
  if ( gwnd->is_icon ) iconify_picture( gwnd ) ;
}

int need_palette(int type_modif, void *spec)
{
  LDV_CAPS *caps ;
  int      ret = 0 ;

  if ( Truecolor ) return( ret ) ;

  switch( type_modif )
  {
    case UCONVERT :
    case ULUMIERE :
    case UGAMMA   :
    case REDO     :
                    ret = 1 ;
                    break ;

    case ULDV     : caps = (LDV_CAPS *) spec ;
                    if ( caps ) ret = ( caps->Flags & LDVF_AFFECTPALETTE ) ? 1 : 0 ;
                    break ;
  }

  return( ret ) ;
}

int size_has_changed(UNDO_DEF *undo, MFDB *current_img)
{
  int changed ;

  if ( ( undo->original_width != current_img->fd_w ) || (  undo->original_height != current_img->fd_h ) )
    changed = 1 ;
  else
    changed = 0 ;

  return( changed ) ;
}

int handle_changed_size(UNDO_DEF *undo, MFDB *current_img)
{
  int err = 0 ;

  if ( size_has_changed( undo, current_img ) )
  {
    /* Essaie de r‚allouer la taille d'origine */
    long taille ;
    void *pt ;

    taille = img_size( undo->w, undo->h, nb_plane ) ;
    pt = Xalloc( taille ) ;
    if ( pt == NULL ) err = 1 ;
    else
    {
      Xfree( current_img->fd_addr ) ;
      current_img->fd_addr = pt ;
      current_img->fd_w = undo->w ;
      current_img->fd_wdwidth = current_img->fd_w/16 ;
      if ( current_img->fd_w % 16 ) current_img->fd_wdwidth++ ;
      current_img->fd_h = undo->h ;
    }
  }

  return( err ) ;
}

void FreeClipboard(void)
{
  if ( clipboard.img.fd_addr ) Xfree( clipboard.img.fd_addr ) ;
  if ( clipboard.mask.fd_addr ) Xfree( clipboard.mask.fd_addr ) ;
  memset( &clipboard, 0, sizeof(clipboard) ) ;
}

void update_raster(GEM_WINDOW *gwnd, int xmin, int ymin, int xmax, int ymax)
{
  VXIMAGE *vimage ;
  MFDB    zoom ;
  int     xy[8] ;
  int     cxy[4] ;
  int     xi, yi, wx, wy ;
  int     posx, posy ;
  int     zoom_level ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy ) ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;

  if (xmax > Xmax) xmax = Xmax ;
  if (ymax > Ymax) ymax = Ymax ;
  zoom_level = vimage->zoom_level ;
  xy[0]  = xmin ; xy[1] = ymin ;
  xy[2]  = xmax ; xy[3] = ymax ;
  xy[4]  = posx+(xmin-xi) ;
  xy[5]  = posy+(ymin-yi) ;
  xy[6]  = xy[4]+(1+xmax-xmin)/zoom_level-1 ;
  xy[7]  = xy[5]+(1+ymax-ymin)/zoom_level-1 ;
  cxy[0] = xdesk ;         cxy[1] = ydesk ;
  cxy[2] = xdesk+wdesk-1 ; cxy[3] = ydesk+hdesk-1 ;
  vs_clip( handle, 1, cxy ) ;
  v_hide_c( handle ) ;
  if ( zoom_level == 1 )
    vro_cpyfm( handle, S_ONLY, xy, &screen, &vimage->raster ) ;
  else
  {
    int xyarray[8] ;

    memcpy(xyarray, xy, 8) ;
    xyarray[4] = xmin-xi ;
    xyarray[5] = ymin-yi ;
    xyarray[6] = xmax-xi ;
    xyarray[7] = ymax-yi ;
    vro_cpyfm(handle, S_ONLY, xyarray, &screen, &vimage->zoom) ;
    if (raster_zoom(&screen, &zoom, xy, -zoom_level, -zoom_level) == 0)
    {
      xy[0] = 0 ; xy[1] = 0 ;
      xy[2] = (1+xmax-xmin)/zoom_level-1 ;
      xy[3] = (1+ymax-ymin)/zoom_level-1 ;
      vro_cpyfm(handle, S_ONLY, xy, &zoom, &vimage->raster) ;
      Xfree(zoom.fd_addr) ;
    }
  }
  v_show_c(handle, 0) ;
  vs_clip(handle, 0, cxy) ;
}

void clip_put(GEM_WINDOW *gwnd, int x1, int y1, int x2, int y2)
{
  VXIMAGE *vimage ;
  int     xy[8] ;
  int     temp ;
  int     larg ;
  int     w, h ;

  if ( !GWIsWindowValid( gwnd ) ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  if (x2 < x1)
  {
    temp = x1 ;
    x1   = x2 ;
    x2   = temp ;
  }
  if (y2 < y1)
  {
    temp = y1 ;
    y1   = y2 ;
    y2   = temp ;
  }

  FreeClipboard() ;

  w = 1+x2-x1 ; h = 1+y2-y1 ;
  if (w % 16) larg = (16+w) & 0xFFF0 ;
  else        larg = w ;
  if (larg < MINIW) larg = MINIW ;
  if (h < MINIH)       h = MINIH ;
  clipboard.img.fd_addr = img_alloc(larg, h, nb_plane) ;
  if (clipboard.img.fd_addr == NULL)
  {
    form_error(8) ;
    return ;
  }

  clipboard.img.fd_w       = larg ;
  clipboard.img.fd_h       = h ;
  clipboard.img.fd_wdwidth = larg/16 ;
  clipboard.img.fd_nplanes = nb_plane ;
  clipboard.img.fd_stand   = 0 ;
  clipboard.gwindow        = gwnd ;
  clipboard.x              = x1 ;
  clipboard.y              = y1 ;
  clipboard.w              = 1+x2-x1 ;
  clipboard.h              = 1+y2-y1 ;

  img_raz(&clipboard.img) ;
  xy[0] = x1 ;    xy[1] = y1 ;
  xy[2] = x2 ;    xy[3] = y2 ;
  xy[4] = 0 ;     xy[5] = 0 ;
  xy[6] = x2-x1 ; xy[7] = y2-y1 ;
  vro_cpyfm(handle, S_ONLY, xy, &vimage->raster, &clipboard.img) ;

  if ( config.clip_gem == 1 )
  {
    char name[PATH_MAX] ;

    mouse_busy() ;
    if ( clbd_getpath( name ) == 0 )
    {
      INFO_IMAGE info ;
      IMG_MODULE *img_module ;

      memcpy( &info, &vimage->inf_img, sizeof(INFO_IMAGE) ) ;
      info.largeur  = clipboard.img.fd_w ;
      info.hauteur  = clipboard.img.fd_h ;
      info.compress = 1 ;
      strcat( name, "SCRAP." ) ;
      if ( Truecolor ) info.lformat = IID_TIFF ;
      else             info.lformat = IID_IMG ;
      img_module = DImgGetModuleFromIID( info.lformat ) ;
      if ( img_module )
      {
        strcat( name, img_module->Capabilities.file_extension ) ;
        save_picture( name, &clipboard.img, &info, NULL ) ;
      }
    }
    mouse_restore() ;
  }
}

void clip_putlasso(GEM_WINDOW *gwnd, int x1, int y1, int x2, int y2, MFDB *mask, MFDB *masked_img)
{
  VXIMAGE *vimage ;

  if ( !GWIsWindowValid( gwnd ) ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  FreeClipboard() ;

  memcpy(&clipboard.img, masked_img, sizeof(MFDB)) ;
  memcpy(&clipboard.mask, mask, sizeof(MFDB)) ;
  clipboard.gwindow = gwnd ;
  clipboard.x   = x1 ;
  clipboard.y   = y1 ;
  clipboard.w   = 1+x2-x1 ;
  clipboard.h   = 1+y2-y1 ;

  if (config.clip_gem == 1)
  {
    char name[200] ;

    mouse_busy() ;
    if ( clbd_getpath( name ) == 0 )
    {
      INFO_IMAGE info ;

      memcpy( &info, &vimage->inf_img, sizeof(INFO_IMAGE) ) ;
      info.largeur  = clipboard.img.fd_w ;
      info.hauteur  = clipboard.img.fd_h ;
      if ( Truecolor )
      {
        strcat(name, "SCRAP.TIF") ;
        info.compress = 1 ;
        info.lformat  = IID_TIFF ;
      }
      else
      {
        strcat(name, "SCRAP.IMG") ;
        info.lformat  = IID_IMG ;
      }
      save_picture( name, &clipboard.img, &vimage->inf_img, NULL ) ;
    }
    mouse_restore() ;
  }
}

int must_alloc(int modif, long taille, void *spec)
{
  LDV_CAPS *caps ;
  size_t   memory_left ;
  size_t   limit_bytes ;
  int      type_alloc = 1 ; /* M‚moire RAM */
  void     *pt_alloc ;

  if ( taille == 0 ) return( 0 ) ;

  limit_bytes = (size_t)config.ko_undo*1024UL ;
  switch( modif )
  {
    case UNEGATIF :
    case USYMX    :
    case USYMY    :
    case USYMXY   : type_alloc = 0 ; /* Pas besoin de m‚moire */
                    break ;

    case UCONVERT :
    case ULUMIERE :
    case UGAMMA   : 
    case ULDV     : if ( !Truecolor && ( modif == ULDV ) )
                    {
                      caps = (LDV_CAPS *) spec ;
                      if ( caps && ( caps->Flags & LDVF_AFFECTPALETTE ) )
                      {
                        type_alloc = 1 ;
                        break ;
                      }
                    }
                    else if ( !Truecolor )
                    {
                      type_alloc = 1 ;
                      break ;
                    }
    default       :
                    switch( config.type_undo )
                    {
                      case TUNDO_MEMORY : type_alloc = 1 ;
                                          break ;
                      case TUNDO_KO :     memory_left = (size_t) Xalloc( -1L ) ;
                                          if ( memory_left < limit_bytes )
                                            type_alloc = 2 ;
                                          else
                                            type_alloc = 1 ;
                                          break ;
                      case TUNDO_SMART :  pt_alloc = Xalloc( taille ) ;
                                          if ( pt_alloc == NULL ) type_alloc = 2 ;
                                          else
                                          {
                                            Xfree( pt_alloc ) ;
                                            type_alloc = 1 ;
                                          }
                                          break ;
                      case TUNDO_DISK :   type_alloc = 2 ;
                                          break ;
                             
                    }
  }

  return( type_alloc ) ;
}

void FreeUndoBuffer(UNDO_DEF *undo)
{
  VXIMAGE *vimage ;

  if ( undo == NULL ) return ;
  vimage = (VXIMAGE *) undo->gwindow->Extension ;
  vimage->NbUndoBuffers-- ;
  if ( undo->img.fd_addr ) Xfree( undo->img.fd_addr ) ;
  if ( undo->spec ) Xfree( undo->spec ) ;
  if ( undo->palette ) Xfree( undo->palette ) ;
  if ( undo->disk )
  {
    char name[200] ;

    sprintf( name, "%s\\~%02d~.TMP", config.path_temp, undo->undo_num ) ;
    unlink( name ) ;
  }
  Xfree( undo ) ;
/*  memset( undo, 0, sizeof(UNDO_DEF) ) ;*/
}

int undo_disk(GEM_WINDOW *wnd, UNDO_DEF *undo, int *xy, MFDB *raster)
{
  MFDB img ;
  long taille ;
  int  ret = 0 ;
  char name[200] ;

  memset( &img, 0,sizeof(MFDB) ) ;
  sprintf( name, "%s\\~%02d~.TMP", config.path_temp, undo->undo_num ) ;
  img.fd_w = 1+xy[2]-xy[0] ;
  img.fd_wdwidth = img.fd_w / 16 ;
  if ( img.fd_w % 16 ) img.fd_wdwidth++ ;
  img.fd_h = 1 ;
  img.fd_nplanes = raster->fd_nplanes ;
  taille = img_size( img.fd_w, 1, img.fd_nplanes ) ;
  img.fd_addr = Xalloc ( taille ) ;
  if ( img.fd_addr == NULL )
  {
    form_stop( 1, MsgTxtGetMsg(hMsg, MSG_UNDOERROR)  ) ;
    ret = -3 ;
  }
  else
  {
    FILE *stream ;

    stream = fopen( name, "wb" ) ;
    if ( stream == NULL )
    {
      form_stop( 1, MsgTxtGetMsg(hMsg, MSG_UNDOERROR)  ) ;
      ret = - 1 ;
    }
    else
    {
      int txy[8] ;
      int y ;
      int pc, err = 0 ;

      txy[0] = xy[0] ; txy[2] = xy[2] ;
      txy[4] = txy[5] = 0 ;
      txy[6] = img.fd_w - 1 ;
      txy[7] = 0 ;
      fwrite( &img, sizeof(MFDB), 1, stream ) ;
      for ( y = xy[1]; !err && ( y <= xy[3] ); y++ )
      {
        txy[1] = txy[3] = y ;
        vro_cpyfm( handle, S_ONLY, txy, raster, &img ) ;
        if ( fwrite( img.fd_addr, taille, 1, stream ) != 1 ) err = 1 ;
        if ( wnd && wnd->ProgPc && ( ( y & 0x0F ) == 0x0F ) )
        {
          pc = (int) ( (100L * (long)(y - xy[1])) / (long)(xy[3]- xy[1]) ) ;
          if ( undo->mitem == REDO ) wnd->ProgPc( wnd, pc, "Redo" ) ;
          else                       wnd->ProgPc( wnd, pc, "Undo" ) ;
        }
      }
      fclose( stream ) ;
      if ( wnd && wnd->ProgPc ) wnd->ProgPc( wnd, 100, NULL ) ;
      if ( err )
      {
        unlink( name ) ;
        form_stop(1, MsgTxtGetMsg(hMsg, MSG_UNDOERROR) ) ;
      }
      else undo->disk = 1 ;
    }
    Xfree( img.fd_addr ) ;
  }

  return( ret ) ;
}

void restore_undo_disk(GEM_WINDOW *wnd, UNDO_DEF *undo, int *xy, MFDB *raster)
{
  MFDB img ;
  long taille ;
  char name[200] ;

  memset( &img, 0,sizeof(MFDB) ) ;
  sprintf( name, "%s\\~%02d~.TMP", config.path_temp, undo->undo_num ) ;
  img.fd_w = 1+xy[2]-xy[0] ;
  img.fd_wdwidth = img.fd_w / 16 ;
  if ( img.fd_w % 16 ) img.fd_wdwidth++ ;
  img.fd_h = 1 ;
  img.fd_nplanes = raster->fd_nplanes ;
  taille = img_size( img.fd_w, 1, img.fd_nplanes ) ;
  img.fd_addr = Xalloc ( taille ) ;
  if ( img.fd_addr == NULL )
  {
    form_stop( 1, MsgTxtGetMsg(hMsg, MSG_UNDOERROR)  ) ;
    return ;
  }
  else
  {
    FILE *stream ;

    stream = fopen( name, "rb" ) ;
    if ( stream == NULL )
    {
      form_stop(1, MsgTxtGetMsg(hMsg, MSG_UNDOERROR) ) ;
      return ;
    }
    else
    {
      MFDB timg ;
      int txy[8] ;
      int y ;
      int pc, err = 0 ;

      fread( &timg, sizeof(MFDB), 1, stream) ;
      txy[0] = 0 ; txy[2] = img.fd_w-1 ;
      txy[1] = txy[3] = 0 ;
      txy[4] = xy[4] ;
      txy[6] = xy[6] ;
      for ( y = xy[5]; !err && ( y <= xy[7] ); y++ )
      {
        txy[5] = txy[7] = y ;
        if ( fread( img.fd_addr, taille, 1, stream ) != 1 ) err = 1 ;
        vro_cpyfm( handle, S_ONLY, txy, &img, raster ) ;
        if ( wnd && wnd->ProgPc && ( ( ( (y - xy[5]) & 0x0F ) == 0x0F ) ) )
        {
          pc = (int) ( (100L * (long)(y - xy[5])) / (long)(xy[7]- xy[5]) ) ;
          if ( undo->mitem == REDO ) wnd->ProgPc( wnd, pc, "Redo" ) ;
          else                       wnd->ProgPc( wnd, pc, "Undo" ) ;
        }
      }
      fclose( stream ) ;
      if ( wnd && wnd->ProgPc ) wnd->ProgPc( wnd, 100, NULL ) ;
      if ( err )
      {
        form_stop(1, MsgTxtGetMsg(hMsg, MSG_UNDOERROR) ) ;
      }
    }
    Xfree( img.fd_addr ) ;
  }
}

void FreeUUndoBuffer(GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage ;

  vimage = (VXIMAGE *) gwnd->Extension ;
  FreeUndoBuffer( vimage->Redo ) ;
  vimage->Redo = NULL ;
}

UNDO_DEF *AllocateUUndoBuffer(GEM_WINDOW *gwnd)
{
  UNDO_DEF *redo ;

  redo = (UNDO_DEF *) Xcalloc( 1, sizeof(UNDO_DEF) ) ;
  if ( redo )
  {
    VXIMAGE *vimage ;

    vimage = (VXIMAGE *) gwnd->Extension ;
    vimage->NbUndoBuffers++ ;
    redo->undo_num = UndoNum++ ;
    redo->gwindow  = gwnd ;
  }

  return( redo ) ;  
}

int undo_put(GEM_WINDOW *gwnd, int x1, int y1, int x2, int y2, int type_modif, XUNDO *xundo)
{
  LIST_ENTRY* entry ;
  VXIMAGE*    vimage ;
  UNDO_DEF*   undo_buf ;
  void*       spec = NULL ;
  long        taille = 0 ;
  int         xy[8] ;
  int         wx, wy ;
  int         larg, temp ;
  int         type_alloc ;

  if ( config.nb_undo == 0 ) return( -1 ) ;
  if ( !GWIsWindowValid( gwnd ) ) return( -1 ) ;
  undo_buf = AllocateNewUndoBuffer( gwnd ) ;
  if ( undo_buf == NULL ) return( -3 ) ;

  vimage = (VXIMAGE *) gwnd->Extension ;
/*  if ( type_modif & REDO ) redo = 1 ;
  type_modif &= ~REDO ;
*/
  if ( xundo )
  {
    if ( xundo->nb_bytes_to_allocate_and_copy > 0 )
    {
      spec = Xalloc( xundo->nb_bytes_to_allocate_and_copy ) ;
      if ( spec ) memcpy( spec, xundo->spec, xundo->nb_bytes_to_allocate_and_copy ) ;
      else
      {
        FreeUndoBuffer( undo_buf ) ;
        return( -3 ) ;
      }
    }
  }

  if ( x1 > x2 )
  {
    temp = x1 ;
    x1   = x2 ;
    x2   = temp ;
  }

  if ( y1 > y2 )
  {
    temp = y1 ;
    y1   = y2 ;
    y2   = temp ;
  }

  wx = x2 - x1 + 1 ;
  wy = y2 - y1 + 1 ;

  larg = ALIGN16( wx ) ;

  if ( need_palette( type_modif, spec ) )
  {
    size_t size ;

    undo_buf->nb_cpal = (int) vimage->inf_img.nb_cpal ;
    size              = undo_buf->nb_cpal * 3 * sizeof(int) ;
    undo_buf->palette = (int *) Xalloc( size ) ;
    if ( undo_buf->palette == NULL )
    {
      if ( spec ) Xfree( spec ) ;
      FreeUndoBuffer( undo_buf ) ;
      return( -3 ) ;
    }
    else
      memcpy( undo_buf->palette, vimage->inf_img.palette, size ) ;
  }

  if ( x1 < 0 ) taille = 0 ; /* Pas de modif sur l'image (palette sans doute) */
  else          taille = img_size( larg, wy, nb_plane ) ;

  undo_buf->original_width  = vimage->raster.fd_w ;
  undo_buf->original_height = vimage->raster.fd_h ;

  type_alloc = must_alloc( type_modif, taille, spec ) ;
  if ( type_alloc == 0 ) /* Est-il n‚cessaire d'allouer de la m‚moire ? */
  {
    undo_buf->img.fd_addr = NULL ;
    undo_buf->x           = x1 ;
    undo_buf->y           = y1 ;
    undo_buf->w           = wx ;
    undo_buf->h           = wy ;
    undo_buf->mitem       = type_modif ;
    undo_buf->spec        = spec ;
  }
  else
  {
    if ( type_alloc == 2 ) undo_buf->disk = 1 ;
    else
    {
      undo_buf->img.fd_addr = Xalloc( taille ) ;
      if ( undo_buf->img.fd_addr == NULL )
      {
        if ( spec ) Xfree( spec ) ;
        if ( undo_buf->palette ) Xfree( undo_buf->palette ) ;
        FreeUndoBuffer( undo_buf ) ;
        return -3 ;
      }
    }
    if ( undo_buf->disk || ( undo_buf->img.fd_addr != NULL ) )
    {
      undo_buf->img.fd_w       = larg ; /* Si possible, on m‚morise */
      undo_buf->img.fd_h       = wy ;   /* Les nouvelles donn‚es    */
      undo_buf->img.fd_wdwidth = larg/16 ;
      undo_buf->img.fd_nplanes = nb_plane ;
      undo_buf->img.fd_stand   = 0 ;
      undo_buf->gwindow        = gwnd ;
      undo_buf->x              = x1 ;
      undo_buf->y              = y1 ;
      undo_buf->w              = wx ;
      undo_buf->h              = wy ;
      undo_buf->mitem          = type_modif ;
      undo_buf->spec           = spec ;

      xy[0] = x1 ;   xy[1] = y1 ;
      xy[2] = x2 ;   xy[3] = y2 ;
      xy[4] = 0 ;    xy[5] = 0 ;
      xy[6] = wx-1 ; xy[7] = wy-1 ;
      if ( undo_buf->disk ) undo_disk( gwnd, undo_buf, xy, &vimage->raster ) ;
      else                  vro_cpyfm( handle, S_ONLY, xy, &vimage->raster, &undo_buf->img ) ;
    }
  }

  entry = GET_LIST_ENTRY_FROM_UNDO_DEF( undo_buf ) ;
  InsertHeadList( &vimage->UndoListHead, entry ) ;
  if ( type_modif != REDO ) FreeUUndoBuffer( gwnd ) ;

  return 0 ;
}

int uundo_put(GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage ;
  long    taille ;
  int     xy[8] ;
  int     type_alloc ;

  if ( gwnd == NULL) return( -1 ) ;
  if ( config.use_redo == 0 ) return( 0 ) ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  FreeUUndoBuffer( gwnd ) ;
  vimage->Redo = AllocateUUndoBuffer( gwnd ) ;
  if ( vimage->Redo == NULL ) return( -3 ) ;

  vimage->Redo->w     = vimage->raster.fd_w ;
  vimage->Redo->h     = vimage->raster.fd_h ;
  vimage->Redo->mitem = REDO ;

  if ( !Truecolor && vimage->inf_img.nb_cpal && vimage->inf_img.palette )
  {
    size_t size ;

    vimage->Redo->nb_cpal = (int) vimage->inf_img.nb_cpal ;
    size                  = vimage->Redo->nb_cpal * 3 * sizeof(int) ;
    vimage->Redo->palette = (int *) Xalloc( size ) ;
    if ( vimage->Redo->palette == NULL )
    {
      FreeUndoBuffer( vimage->Redo ) ;
      vimage->Redo = NULL ;
      return( -1 ) ;
    }
    memcpy( vimage->Redo->palette, vimage->inf_img.palette, size ) ;
  }
  taille = img_size( vimage->Redo->w, vimage->Redo->h, nb_plane ) ;

  vimage->Redo->original_width  = vimage->raster.fd_w ;
  vimage->Redo->original_height = vimage->raster.fd_h ;

  type_alloc = must_alloc( vimage->Redo->mitem, taille, vimage->Redo->spec ) ;
  if ( type_alloc )
  {
    xy[0] = vimage->Redo->x ; xy[1] = vimage->Redo->y ;
    xy[2] = vimage->Redo->x + vimage->Redo->w-1 ;
    xy[3] = vimage->Redo->y + vimage->Redo->h-1 ;
    xy[4] = 0 ;         xy[5] = 0 ;
    xy[6] = vimage->Redo->w-1 ; xy[7] = vimage->Redo->h-1 ;
    if ( type_alloc == 1 )
    {
      vimage->Redo->img.fd_w       = vimage->Redo->w ;
      vimage->Redo->img.fd_w       = vimage->Redo->h ;
      vimage->Redo->img.fd_wdwidth = vimage->Redo->w / 16 ;
      if ( vimage->Redo->w % 16 ) vimage->Redo->img.fd_wdwidth++ ;
      vimage->Redo->img.fd_nplanes = nb_plane ;

      vimage->Redo->img.fd_addr = Xalloc( taille ) ;
      if ( vimage->Redo->img.fd_addr == NULL ) return( -1 ) ;
      vro_cpyfm( handle, S_ONLY, xy, &vimage->raster, &vimage->Redo->img ) ;
    }
    else undo_disk( gwnd, vimage->Redo, xy, &vimage->raster ) ;
  }

  return( 0 ) ;
}

void handle_new_size(MFDB *original, GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage ;
  int xe, ye, wxe, whe ;
  int xo, yo, wo, ho ;
  int ww, wh, dummy ;

  if ( gwnd == NULL) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;
  if ( ( original->fd_w == vimage->raster.fd_w ) && ( original->fd_h == vimage->raster.fd_h ) ) return ;

  wind_calc( WC_WORK, gwnd->window_kind, xopen, yopen, wdesk-(xopen-xdesk),
             hdesk-(yopen-ydesk), &xe, &ye, &wxe, &whe ) ;
  if ( wxe >= vimage->raster.fd_w ) wxe = vimage->raster.fd_w-1 ;
  if ( whe >= vimage->raster.fd_h ) whe = vimage->raster.fd_h-1 ;
  wind_calc( WC_BORDER, gwnd->window_kind, xe, ye, wxe, whe, &xo, &yo, &wo, &ho ) ;
  if ( gwnd->is_icon ) GWOnUnIconify( gwnd, gwnd->xywh_bicon ) ;
  else                 GWSetCurrXYWH( gwnd, xo, yo, wo, ho ) ; 

  gwnd->GetWorkXYWH( gwnd, &dummy, &dummy, &wo, &ho ) ;
  ww = (int) ( 1000.0*(double)wo / (double)vimage->raster.fd_w ) ;
  wh = (int) ( 1000.0*(double)ho / (double)vimage->raster.fd_h ) ;
  GWSetHSlider( gwnd, 1 ) ;
  GWSetVSlider( gwnd, 1 ) ;
  GWSetHSliderSize( gwnd, ww ) ;
  GWSetVSliderSize( gwnd, wh ) ;
  set_modif( gwnd ) ;
  update_view( gwnd ) ;
  update_zview( gwnd ) ;
  GWRePaint( gwnd ) ;
}

void undo_restore(GEM_WINDOW *gwnd)
{
  LIST_ENTRY *entry ;
  UNDO_DEF   *undo ;
  VXIMAGE    *vimage ;
  MFDB       original_img ;
  int        xy[8] ;
  int        rep ;
  int        resize = 1 ;

  if ( !GWIsWindowValid( gwnd ) ) return ;
  if ( config.nb_undo == 0 ) return ;

  vimage = (VXIMAGE *) gwnd->Extension ;
  if ( IsListEmpty( &vimage->UndoListHead ) ) return ;
  entry = RemoveHeadList( &vimage->UndoListHead ) ;
  undo  = GET_UNDO_DEF_FROM_LIST_ENTRY( entry ) ;
  if ( gwnd != undo->gwindow )
  {
    rep = form_stop(1, MsgTxtGetMsg(hMsg, MSG_UNDOIMG) ) ;
    if ( rep == 2 ) return ;
  }

  memcpy( &original_img, &vimage->raster, sizeof(MFDB) )  ;
  mouse_busy() ;

  if ( uundo_put( gwnd ) ) form_stop( 1, MsgTxtGetMsg(hMsg, MSG_UUNDO)  ) ;

  if ( need_palette( undo->mitem, undo->spec ) )
  {
    memcpy( vimage->inf_img.palette, undo->palette, undo->nb_cpal * 3 * sizeof(int) ) ;
    set_imgpalette( vimage ) ;
  }

  if ( undo->img.fd_addr || undo->disk )
  {
    if ( handle_changed_size( undo, &vimage->raster ) != 0 ) form_error( 8 ) ;
    else
    {
      xy[0] = 0 ;         xy[1] = 0 ;
      xy[2] = undo->w-1 ; xy[3] = undo->h-1 ;
      xy[4] = undo->x ;   xy[5] = undo->y ;
      xy[6] = undo->x+undo->w-1 ;
      xy[7] = undo->y+undo->h-1 ;
      if ( undo->disk ) restore_undo_disk( gwnd, undo, xy, &vimage->raster ) ;
      else              vro_cpyfm( handle, S_ONLY, xy, &undo->img, &vimage->raster ) ;
    }
  }
  else
  {
    resize = 0 ;
    switch( undo->mitem )
    {
      case UNEGATIF : xy[0] = undo->x ;
                      xy[1] = undo->y ;
                      xy[2] = xy[0]+undo->w-1 ;
                      xy[3] = xy[1]+undo->h-1 ;
                      memcpy(&xy[4], xy, 8) ;
                      vro_cpyfm(handle, D_INVERT, xy, &vimage->raster, &vimage->raster) ;
                      break ;
      case USYMX    : xy[0] = undo->x ;
                      xy[1] = undo->y ;
                      xy[2] = xy[0]+undo->w-1 ;
                      xy[3] = xy[1]+undo->h-1 ;
                      raster_hsym( &vimage->raster, xy ) ;
                      if ((vclip.gwindow == gwnd) && (xy[0] == 0) && (xy[1] == 0) &&
                          (xy[2] == vimage->raster.fd_w-1) && (xy[3] == vimage->raster.fd_h-1))
                      {
                        vclip.y1 = vimage->raster.fd_h-1-vclip.y1 ;
                        vclip.y2 = vimage->raster.fd_h-1-vclip.y2 ;
                        if (vclip.y1 > vclip.y2)
                        {
                          int temp ;

                          temp     = vclip.y1 ; 
                          vclip.y1 = vclip.y2 ;
                          vclip.y2 = temp ;
                        }
                      }
                      break ;
      case USYMY    : xy[0] = undo->x ;
                      xy[1] = undo->y ;
                      xy[2] = xy[0]+undo->w-1 ;
                      xy[3] = xy[1]+undo->h-1 ;
                      raster_vsym( &vimage->raster, xy ) ;
                      if ((vclip.gwindow == gwnd) && (xy[0] == 0) && (xy[1] == 0) &&
                          (xy[2] == vimage->raster.fd_w-1) && (xy[3] == vimage->raster.fd_h-1))
                      {
                        vclip.x1 = vimage->raster.fd_w-1-vclip.x1 ;
                        vclip.x2 = vimage->raster.fd_w-1-vclip.x2 ;
                        if (vclip.x1 > vclip.x2)
                        {
                          int temp ;

                          temp     = vclip.x1 ; 
                          vclip.x1 = vclip.x2 ;
                          vclip.x2 = temp ;
                        }
                      }
                      break ;
      case USYMXY   : xy[0] = undo->x ;
                      xy[1] = undo->y ;
                      xy[2] = xy[0]+undo->w-1 ;
                      xy[3] = xy[1]+undo->h-1 ;
                      raster_vsym( &vimage->raster, xy ) ;
                      if ((vclip.gwindow == gwnd) && (xy[0] == 0) && (xy[1] == 0) &&
                          (xy[2] == vimage->raster.fd_w-1) && (xy[3] == vimage->raster.fd_h-1))
                      {
                        vclip.x1 = vimage->raster.fd_w-1-vclip.x1 ;
                        vclip.x2 = vimage->raster.fd_w-1-vclip.x2 ;
                        if (vclip.x1 > vclip.x2)
                        {
                          int temp ;

                          temp     = vclip.x1 ; 
                          vclip.x1 = vclip.x2 ;
                          vclip.x2 = temp ;
                        }
                      }
                      xy[0] = undo->x ;
                      xy[1] = undo->y ;
                      xy[2] = xy[0]+undo->w-1 ;
                      xy[3] = xy[1]+undo->h-1 ;
                      raster_hsym( &vimage->raster, xy ) ;
                      if ((vclip.gwindow == gwnd) && (xy[0] == 0) && (xy[1] == 0) &&
                          (xy[2] == vimage->raster.fd_w-1) && (xy[3] == vimage->raster.fd_h-1))
                      {
                        vclip.y1 = vimage->raster.fd_h-1-vclip.y1 ;
                        vclip.y2 = vimage->raster.fd_h-1-vclip.y2 ;
                        if (vclip.y1 > vclip.y2)
                        {
                          int temp ;

                          temp     = vclip.y1 ; 
                          vclip.y1 = vclip.y2 ;
                          vclip.y2 = temp ;
                        }
                      }
                      break ;
    }
  }

  mouse_restore() ;

  handle_new_size( &original_img, gwnd ) ;

  if ( resize && ( vimage->zoom_level != 1 ) )
  {
    int xy[4] ;

    xy[0] = vimage->x1 ; xy[1] = vimage->y1 ;
    xy[2] = vimage->x2 ; xy[3] = vimage->y2 ;
    if ( vimage->zoom.fd_addr ) Xfree( vimage->zoom.fd_addr ) ;
    if ( raster_zoom( &vimage->raster, &vimage->zoom, xy, vimage->zoom_level, vimage->zoom_level ) == -1 )
      form_error( 8 ) ;
  }
  
  if ( gwnd->window_icon.fd_addr != NULL ) Xfree( gwnd->window_icon.fd_addr) ;
  memset( &gwnd->window_icon, 0, sizeof(MFDB) ) ;
  if ( gwnd->is_icon ) iconify_picture( gwnd ) ;
  GWRePaint( gwnd ) ;

  FreeUndoBuffer( undo ) ;
}

void traite_refaire(GEM_WINDOW *gw)
{
  VXIMAGE *vimage ;
  MFDB    original_img ;
  int     xy[8] ;

  if ( config.use_redo == 0 ) return ;
  if ( config.nb_undo == 0 ) return ;
  if ( !GWIsWindowValid( gw ) ) return ;
  vimage = (VXIMAGE *) gw->Extension ;
  if ( vimage->Redo == NULL ) return ;

  memcpy( &original_img, &vimage->raster, sizeof(MFDB) )  ;
  mouse_busy() ;
  vimage->Redo->mitem = REDO ;

  if ( ( vimage->Redo->w != vimage->raster.fd_w ) || ( vimage->Redo->h != vimage->raster.fd_h ) )
    undo_put( gw, 0, 0, vimage->raster.fd_w-1, vimage->raster.fd_h-1, vimage->Redo->mitem, NULL ) ;
  else
    undo_put( gw, vimage->Redo->x, vimage->Redo->y, vimage->Redo->x+vimage->Redo->w-1, vimage->Redo->y+vimage->Redo->h-1, vimage->Redo->mitem, NULL ) ;

  if ( vimage->Redo->palette )
  {
    memcpy( vimage->inf_img.palette, vimage->Redo->palette, vimage->Redo->nb_cpal * 3 * sizeof(int) ) ;
    set_imgpalette( vimage ) ;
  }

  if ( vimage->Redo->disk || vimage->Redo->img.fd_addr )
  {
    if ( handle_changed_size( vimage->Redo, &vimage->raster ) != 0 ) form_error( 8 ) ;
    else
    {
      xy[0] = 0 ;                 xy[1] = 0 ;
      xy[2] = vimage->Redo->w-1 ; xy[3] = vimage->Redo->h-1 ;
      xy[4] = vimage->Redo->x ;   xy[5] = vimage->Redo->y ;
      xy[6] = vimage->Redo->x+vimage->Redo->w-1 ;
      xy[7] = vimage->Redo->y+vimage->Redo->h-1 ;
      if ( vimage->Redo->disk ) restore_undo_disk( gw, vimage->Redo, xy, &vimage->raster ) ;
      else                      vro_cpyfm(handle, S_ONLY, xy, &vimage->Redo->img, &vimage->raster) ;
    }
  }

  handle_new_size( &original_img, gw ) ;

  if ( vimage->zoom_level != 1 )
  {
    int xy[4] ;

    xy[0] = vimage->x1 ; xy[1] = vimage->y1 ;
    xy[2] = vimage->x2 ; xy[3] = vimage->y2 ;
    if ( vimage->zoom.fd_addr ) Xfree( vimage->zoom.fd_addr ) ;
    if ( raster_zoom( &vimage->raster, &vimage->zoom, xy, vimage->zoom_level, vimage->zoom_level ) == -1 )
        form_error(8) ;     
  }

  if ( gw->window_icon.fd_addr ) Xfree( gw->window_icon.fd_addr ) ;
  memset( &gw->window_icon, 0, sizeof(MFDB) ) ;
  if ( gw->is_icon ) iconify_picture( gw ) ;
  GWRePaint( gw ) ;

  FreeUUndoBuffer( gw ) ;
  mouse_restore() ;

  set_modif( gw ) ;
}

void traite_effbuffers(GEM_WINDOW *gwnd)
{
  VXIMAGE    *vimage ;
  UNDO_DEF   *undo ;
  LIST_ENTRY *entry ;

  if ( !GWIsWindowValid( gwnd ) ) return ;

  vimage = (VXIMAGE *) gwnd->Extension ;
  while ( !IsListEmpty( &vimage->UndoListHead ) )
  {
    entry = RemoveHeadList( &vimage->UndoListHead ) ;
    undo  = GET_UNDO_DEF_FROM_LIST_ENTRY( entry ) ;
    FreeUndoBuffer( undo ) ;
  }

  FreeUUndoBuffer( gwnd ) ;
}

void free_lastundo(GEM_WINDOW *gwnd)
{
  UNDO_DEF   *undo ;
  VXIMAGE    *vimage ;
  LIST_ENTRY *entry ;

  if ( !GWIsWindowValid( gwnd ) ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;
  if ( IsListEmpty( &vimage->UndoListHead ) ) return ;

  entry  = RemoveHeadList( &vimage->UndoListHead ) ;
  undo   = GET_UNDO_DEF_FROM_LIST_ENTRY( entry ) ;
  FreeUndoBuffer( undo ) ;
}

UNDO_DEF* GetUndoBuffer(VXIMAGE *vimage)
{
  LIST_ENTRY *entry ;

  if ( IsListEmpty( &vimage->UndoListHead ) ) return( NULL ) ;

  entry = GetHeadList( &vimage->UndoListHead ) ;

  return( GET_UNDO_DEF_FROM_LIST_ENTRY( entry ) ) ;
}
