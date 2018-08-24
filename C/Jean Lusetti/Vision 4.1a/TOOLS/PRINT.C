/**************************************/
/*---------- Module PRINT.C ----------*/
/*         Impression via GDOS        */
/* N‚cessite le formulaire FORM_PRINT */
/**************************************/
#include   <math.h>
#include  <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "defs.h"
#include "gwindows.h"
#include   "dither.h"
#include   "img_io.h"
#include  "vdibind.h"
#include "targa_io.h"
#include "rasterop.h"


#define PWRITERR  -1
#define PTIMEOUT  -2
#define PNOGDOS   -3
#define PNOHANDLE -4
#define PCANCEL   -5
#define PROTERR   -6
#define PNODRIVER -7

#define CM         0
#define POUCE      1

#define CM2INCH   0.3937
#define INCH2CM   2.54

#define PC_STEP   5

#define A3_INDEX          0
#define A4_INDEX          1
#define USLETTER_INDEX    2
#define USLEGAL_INDEX     3
#define USEXECUTIVE_INDEX 4
#define SPECIAL_INDEX     5
#define LAST_INDEX        USEXECUTIVE_INDEX

#define FRACTIONAL        0
#define INTEGER           1


typedef struct
{
  int   unite ;   /* CM, POUCE */
  char  nom[16] ; /* A3, A4, ..., Special */
  float largeur ; /* En cm */
  float hauteur ; /* En cm */
}
PAGE ;

typedef struct
{
  PAGE       page ;
  MFDB       raster ;
  INFO_IMAGE info ;

  char  filename[200] ;
  int   printer_index ;
  int   type_index ;
  int   page_index ;

  float sizex, sizey ;
  float posx, posy ;
  float sratio ;
  int   spx, spy ;

  int   rotate90 ;
  float xpc, ypc ;
}
DLGPRINTER_USER_DATA ;

typedef struct
{
  OBJECT *popup_page, *popup_printer, *popup_type ;
}
DLGPRINTER_WEXTENSION ;

PAGE A3          = {CM, "    A3    ", 29.7, 42.0 } ;
PAGE A4          = {CM, "    A4    ", 21.0, 29.7 } ;
PAGE USletter    = {CM, " USletter ", 23.02, 27.49 } ;
PAGE USlegal     = {CM, " USlegal  ", 20.32, 35.56 } ;
PAGE USexecutive = {CM, " USexec.  ", 18.4, 25.4 } ;
PAGE Special     = {CM, " Special  ", 21.0, 29.7 } ;
PAGE *tab_page[] = { &A3, &A4, &USletter, &USlegal, &USexecutive, &Special } ;

char  driver_path[128] ;
char  printer_names[10][20] ;
int   printer_init = 0 ;
int   nb_drivers = 0 ;
int   id[10] ;
int   printer_index ;
int   type_index ;
int   page_index ;

/* A d‚finir dans les modules externes */


int open_work(int prt_num)
{
  int i;
  int prt_handle ;

  for (i = 0; i < 10; _VDIParBlk.intin[i++] = 1) ;
  _VDIParBlk.intin[10] = 2;
  _VDIParBlk.intin[0]  = prt_num;
  v_opnwk(_VDIParBlk.intin, &prt_handle, _VDIParBlk.intout);
/*  Xres = (_VDIParBlk.intout[0]) ;
  Yres = (_VDIParBlk.intout[1]) ;*/

  return (prt_handle) ;
}

void scan_drivers(void)
{
  GEM_WINDOW *wprog ;
  char driver_name[128] ;
  char devstring[128] ;
  int  libr, driv, xplane, attrib ;
  int  devnum, devexist, prt_handle, new_driver ;

  mouse_busy() ;

  wprog = DisplayStdProg( MsgTxtGetMsg(hMsg, MSG_LOOKSPDDRV) , "", "", CLOSER ) ;

  for (devnum = 21 ; devnum < 31 ; devnum++) /* on va tester tous les No Gdos pour l'impression */
  {
    prt_handle = open_work(devnum) ; /* Ouverture de la station imprimante */
    if ( prt_handle )                /* driver dispo pour ce num‚ro        */
    {                                /* s'enquiŠre du nom de l'imprimante  */
       vqt_devinfo( prt_handle, devnum, &devexist, devstring ) ;
/*
       if ( devexist )
       { Test enleve depuis VISION 4.0 car sous NVDI 5, devexist vaut 0 pour gestion du multitache
*/
       id[nb_drivers] = devnum ;
       strcpy(driver_name, (char *)&_VDIParBlk.ptsout[1]) ;
       new_driver = vq_driver_info( prt_handle, &libr, &driv, &xplane,
                                    &attrib, devstring ) ;
       if ( new_driver )
       {
         if ( strlen( devstring ) >= 19) devstring[19] = 0 ;
           strcpy(&printer_names[nb_drivers][0], devstring) ;
       }
       else
         strcpy( &printer_names[nb_drivers][0], driver_name ) ;
       StdProgWText( wprog, 1, &printer_names[nb_drivers][0] ) ;
       nb_drivers++ ;
/*       }*/
       v_clswk(prt_handle) ; /* ferme la station de l'imprimante */
    }
    wprog->ProgPc( wprog, 10*(devnum-20), NULL ) ;
  }
  printer_init = 1 ;
  mouse_restore() ;
  GWDestroyWindow( wprog ) ;
}

int page_compare(PAGE *p1, PAGE *p2)
{
  if (p1->unite == p2->unite)
  {
    if ((fabs(p1->largeur-p2->largeur) < 0.1) && (fabs(p1->hauteur-p2->hauteur) < 0.1)) return(0) ;
  }
  else
  {
    PAGE  *p ;
    float w, h ;

    if (p1->unite == POUCE)
    {
      w = p1->largeur*INCH2CM ;
      h = p1->hauteur*INCH2CM ;
      p = p2 ;
    }
    else
    {
      w = p2->largeur*INCH2CM ;
      h = p2->hauteur*INCH2CM ;
      p = p1 ;
    }
    if ((fabs(p->largeur-w) < 0.1) && (fabs(p->hauteur-h) < 0.1)) return(0) ;
  }

  return(1) ; /* Pages diff‚rentes */
}

void setup_pagename(PAGE *page)
{
  if (page_compare(page, &A3) == 0) strcpy(page->nom, A3.nom) ;
  else
    if (page_compare(page, &A4) == 0) strcpy(page->nom, A4.nom) ;
    else
      if (page_compare(page, &USletter) == 0) strcpy(page->nom, USletter.nom) ;
      else
        if (page_compare(page, &USlegal) == 0) strcpy(page->nom, USlegal.nom) ;
        else
          if (page_compare(page, &USexecutive) == 0) strcpy(page->nom, USexecutive.nom) ;
          else strcpy(page->nom, Special.nom) ;
}

int tab_page_index(PAGE *page)
{
  if (page_compare(page, &A3) == 0) return(A3_INDEX) ;
  else
    if (page_compare(page, &A4) == 0) return(A4_INDEX) ;
    else
      if (page_compare(page, &USletter) == 0) return(USLETTER_INDEX) ;
      else
        if (page_compare(page, &USlegal) == 0) return(USLEGAL_INDEX) ;
        else
          if (page_compare(page, &USexecutive) == 0) return(USEXECUTIVE_INDEX) ;
          else return(SPECIAL_INDEX) ;
}

int micron2dpi(int number)
{
  float x ;
  int   result ;

  x      = 10000.0/(float)number ; /* Nombre de pixels par cm */
  result = (int) (x*INCH2CM) ;

  return(result) ;
}

void button_center(GEM_WINDOW *wnd, OBJECT *adr_print, int axis, int click)
{
  int xc, yc ;

  if (axis == 0)
  {
    if (!click) deselect(adr_print, PRINT_CENTREX) ;
    inv_select(adr_print, PRINT_CENTREX) ;
    if (!selected(adr_print, PRINT_CENTREX) && click) return ;
    if (adr_print[PRINT_IMAGE].ob_width < adr_print[PRINT_PAGE].ob_width)
    {
      adr_print[PRINT_IMAGE].ob_x = (adr_print[PRINT_PAGE].ob_width-adr_print[PRINT_IMAGE].ob_width)/2 ;
      objc_offset( adr_print, PRINT_PAGE, &xc, &yc) ;
      xobjc_draw( wnd->window_handle, adr_print, PRINT_PAGE ) ;
    }
  }
  else
  {
    if (!click) deselect(adr_print, PRINT_CENTREY) ;
    inv_select(adr_print, PRINT_CENTREY) ;
    if (!selected(adr_print, PRINT_CENTREY) && click) return ;
    if (adr_print[PRINT_IMAGE].ob_height < adr_print[PRINT_PAGE].ob_height)
    {
      adr_print[PRINT_IMAGE].ob_y = (adr_print[PRINT_PAGE].ob_height-adr_print[PRINT_IMAGE].ob_height)/2 ;
      objc_offset(adr_print, PRINT_PAGE, &xc, &yc) ;
      xobjc_draw( wnd->window_handle, adr_print, PRINT_PAGE ) ;
    }
  }
}

void compute_page(DIALOG *dlg)
{
  DLGPRINTER_USER_DATA *dlg_user_data = dlg->UserData ;  
  OBJECT     *adr_print = dlg->BaseObject ;
  int l ;

  l      = adr_print[PRINT_GROUP].ob_width-2 ;
  dlg_user_data->spx    = l ;
  dlg_user_data->sratio = aspectratio*(dlg_user_data->page.hauteur/dlg_user_data->page.largeur) ;
  dlg_user_data->spy    = (int) ((float)dlg_user_data->spx*dlg_user_data->sratio) ;
  if (dlg_user_data->spy > dlg_user_data->spx)
  {
    dlg_user_data->spy = l ;
    dlg_user_data->spx = (int) ((float)dlg_user_data->spy/dlg_user_data->sratio) ;
  }

  adr_print[PRINT_PAGE].ob_width  = dlg_user_data->spx ;
  adr_print[PRINT_PAGE].ob_height = dlg_user_data->spy ;
  adr_print[PRINT_PAGE].ob_x      = (l-dlg_user_data->spx)/2 ;
  adr_print[PRINT_PAGE].ob_y      = (l-dlg_user_data->spy)/2 ;

  adr_print[PRINT_IMAGE].ob_x = 0 ;
  adr_print[PRINT_IMAGE].ob_y = 0 ;
  adr_print[PRINT_IMAGE].ob_width  = (int) (dlg_user_data->sizex*(float)dlg_user_data->spx/dlg_user_data->page.largeur) ;
  adr_print[PRINT_IMAGE].ob_height = (int) (dlg_user_data->sizey*(float)dlg_user_data->spy/dlg_user_data->page.hauteur) ;
  if (adr_print[PRINT_IMAGE].ob_width > adr_print[PRINT_PAGE].ob_width)
    adr_print[PRINT_IMAGE].ob_width = adr_print[PRINT_PAGE].ob_width ;
  if (adr_print[PRINT_IMAGE].ob_height > adr_print[PRINT_PAGE].ob_height)
    adr_print[PRINT_IMAGE].ob_height = adr_print[PRINT_PAGE].ob_height ;
}

void show_dimpage(GEM_WINDOW *wnd, PAGE *page, OBJECT *adr_print)
{
  char buf[20] ;

  sprintf(buf, "%.1f", page->largeur) ;
  write_text(adr_print, PRINT_SIZEPAGEW, buf) ;
  xobjc_draw( wnd->window_handle, adr_print, PRINT_SIZEPAGEW ) ;
  sprintf(buf, "%.1f", page->hauteur) ;
  write_text(adr_print, PRINT_SIZEPAGEH, buf) ;
  xobjc_draw( wnd->window_handle, adr_print, PRINT_SIZEPAGEH ) ;
}

void OnInitPrinterDialog(void *w)
{
  static int printer_index ;
  static int type_index = 0 ;
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  DIALOG     *dlg = (DIALOG *) wnd->DlgData ;
  DLGPRINTER_USER_DATA *dlg_user_data = dlg->UserData ;  
  DLGPRINTER_WEXTENSION *wext ;
  OBJECT     *adr_print = dlg->BaseObject ;
  int        i ;
  char       buffer[200] ;

  wnd->Extension = Xcalloc( 1, sizeof(DLGPRINTER_WEXTENSION) ) ;
  wext = (DLGPRINTER_WEXTENSION *) wnd->Extension ;

  read_text( adr_print,  PRINT_FILE, buffer  ) ;
  if ( dlg_user_data->filename[0] ) write_text( adr_print, PRINT_FILE, dlg_user_data->filename ) ;
  else                              write_text( adr_print, PRINT_FILE, buffer ) ;

  wext->popup_page = popup_make(1+LAST_INDEX, 11) ;
  for (i = 0; i <= LAST_INDEX; i++)
    strcpy(wext->popup_page[1+i].ob_spec.free_string, tab_page[i]->nom) ;

  wext->popup_printer = popup_make(nb_drivers, 20) ;
  for (i = 0; i < nb_drivers; i++)
    sprintf(wext->popup_printer[1+i].ob_spec.free_string, " %s", &printer_names[i][0]) ;

  dlg_user_data->printer_index = printer_index ;

  wext->popup_type = popup_make(2, 20) ;
  strcpy(wext->popup_type[1].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_PRINTCOLOR) ) ;
  strcpy(wext->popup_type[2].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_PRINTBW) ) ;

  dlg_user_data->sizex = (float)dlg_user_data->raster.fd_w*(float)dlg_user_data->info.lpix/10000.0 ; /* En cm */
  sprintf(buffer, "%.1f", dlg_user_data->sizex) ;
  write_text(adr_print, PRINT_SIZEX, buffer) ;
  dlg_user_data->sizey = (float)dlg_user_data->raster.fd_h*(float)dlg_user_data->info.hpix/10000.0 ; /* En cm */
  sprintf(buffer, "%.1f", dlg_user_data->sizey) ;
  write_text(adr_print, PRINT_SIZEY, buffer) ;
  write_text(adr_print, PRINT_XPC, "100") ;
  write_text(adr_print, PRINT_YPC, "100") ;

  dlg_user_data->page.unite = CM ;
  read_text(adr_print, PRINT_SIZEPAGEW, buffer) ;
  dlg_user_data->page.largeur = atof(buffer) ;
  read_text(adr_print, PRINT_SIZEPAGEH, buffer) ;
  dlg_user_data->page.hauteur = atof(buffer) ;
  setup_pagename(&dlg_user_data->page) ;

  deselect(adr_print, PRINT_R90) ;
  deselect(adr_print, PRINT_CENTREX) ;
  deselect(adr_print, PRINT_CENTREY) ;

  if (dlg_user_data->info.nplans == 1)
  {
    adr_print[PRINT_TYPE].ob_state |= DISABLED ;
    dlg_user_data->type_index = 1 ;
  }
  else
  {
    adr_print[PRINT_TYPE].ob_state &= ~DISABLED ;
    dlg_user_data->type_index = type_index ;
  }

  write_text(adr_print, PRINT_CONFIGPAGE, dlg_user_data->page.nom) ;
  write_text(adr_print, PRINT_PRINTER, wext->popup_printer[1+dlg_user_data->printer_index].ob_spec.free_string) ;
  write_text(adr_print, PRINT_TYPE, wext->popup_type[1+dlg_user_data->type_index].ob_spec.free_string) ;

  sprintf(buffer, "%.4d/%.4d", micron2dpi(dlg_user_data->info.lpix), micron2dpi(dlg_user_data->info.hpix)) ;
  write_text(adr_print, PRINT_RESOL, buffer) ;

  compute_page( dlg ) ;
}

int OnObjectNotifyPrinterDialog(void *wi, int obj) /* >=0 : sortie de la fenetre, code IDOK ou IDCANCEL */
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) wi ;
  DIALOG     *dlg = (DIALOG *) wnd->DlgData ;
  OBJECT     *adr_print = dlg->BaseObject ;
  DLGPRINTER_USER_DATA *dlg_user_data = dlg->UserData ;
  DLGPRINTER_WEXTENSION *wext = wnd->Extension ;
  float      number ;
  static int pc ;
  int        rx, ry ;
  int        xc, yc ;
  int        w, h ;
  int        clicked ;
  int        ix, iy ;
  int        xr, yr ;
  int        lx, ly, lw, lh ;
  int        code = -1 ;
  char       *c, buffer[100], buf[100] ;

  switch( obj )
  {
    case PRINT_XPCMOINS   :
    case PRINT_XPCPLUS    : read_text(adr_print, PRINT_XPC, buffer) ;
                            pc = atoi(buffer) ;
                            if (obj == PRINT_XPCPLUS) pc += PC_STEP ;
                            else                      pc -= PC_STEP ;
                            if (pc < 2) pc = 2 ;
                            if (pc > 999) pc = 999 ;
                            sprintf(buffer, "%d", pc) ;
                            write_text(adr_print, PRINT_XPC, buffer) ;
                            number = dlg_user_data->sizex*(float)pc/100.0 ;
                            adr_print[PRINT_IMAGE].ob_width  = (int) (number*(float)dlg_user_data->spx/dlg_user_data->page.largeur) ;
                            sprintf(buffer, "%.1f", number) ;
                            write_text(adr_print, PRINT_SIZEX, buffer) ;
                            if (selected(adr_print, PRINT_KEEPRATIO))
                            {
                              sprintf(buffer, "%d", pc) ;
                              write_text(adr_print, PRINT_YPC, buffer) ;
                              number = dlg_user_data->sizey*(float)pc/100.0 ;
                              adr_print[PRINT_IMAGE].ob_height = (int) (number*(float)dlg_user_data->spy/dlg_user_data->page.hauteur) ;
                              sprintf(buffer, "%.1f", number) ;
                              write_text(adr_print, PRINT_SIZEY, buffer) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_YPC ) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_SIZEY ) ;
                            }
                            rx = (int) ((float)dlg_user_data->info.lpix*(float)pc/100.0) ;
                            ry = (int) ((float)dlg_user_data->info.hpix*(float)pc/100.0) ;
                            sprintf(buffer, "%.4d/%.4d", micron2dpi(rx), micron2dpi(ry)) ;
                            write_text(adr_print, PRINT_RESOL, buffer) ;
                            deselect(adr_print, obj) ;
                            xobjc_draw( wnd->window_handle, adr_print, PRINT_XPC ) ;
                            xobjc_draw( wnd->window_handle, adr_print, PRINT_SIZEX ) ;
                            xobjc_draw( wnd->window_handle, adr_print, obj ) ;
                            xobjc_draw( wnd->window_handle, adr_print, PRINT_PAGE ) ;
                            xobjc_draw( wnd->window_handle, adr_print, PRINT_RESOL ) ;
                            if (selected(adr_print, PRINT_CENTREX)) button_center( wnd, adr_print, 0, 0 ) ;
                            if (selected(adr_print, PRINT_CENTREY)) button_center( wnd, adr_print, 1, 0 ) ;
                            break ;
      case PRINT_YPCMOINS   :
      case PRINT_YPCPLUS    : read_text(adr_print, PRINT_YPC, buffer) ;
                              pc = atoi(buffer) ;
                              if (obj == PRINT_YPCPLUS) pc += PC_STEP ;
                              else                      pc -= PC_STEP ;
                              if (pc < 2) pc = 2 ;
                              if (pc > 999) pc = 999 ;
                              sprintf(buffer, "%d", pc) ;
                              write_text(adr_print, PRINT_YPC, buffer) ;
                              number = dlg_user_data->sizey*(float)pc/100.0 ;
                              adr_print[PRINT_IMAGE].ob_height  = (int) (number*(float)dlg_user_data->spy/dlg_user_data->page.hauteur) ;
                              sprintf(buffer, "%.1f", number) ;
                              write_text(adr_print, PRINT_SIZEY, buffer) ;
                              if (selected(adr_print, PRINT_KEEPRATIO))
                              {
                                sprintf(buffer, "%d", pc) ;
                                write_text(adr_print, PRINT_XPC, buffer) ;
                                number = dlg_user_data->sizex*(float)pc/100.0 ;
                                adr_print[PRINT_IMAGE].ob_width  = (int) (number*(float)dlg_user_data->spx/dlg_user_data->page.largeur) ;
                                sprintf(buffer, "%.1f", number) ;
                                write_text(adr_print, PRINT_SIZEX, buffer) ;
                                xobjc_draw( wnd->window_handle, adr_print, PRINT_XPC ) ;
                                xobjc_draw( wnd->window_handle, adr_print, PRINT_SIZEX ) ;
                              }
                              rx = (int) ((float)dlg_user_data->info.lpix*(float)pc/100.0) ;
                              ry = (int) ((float)dlg_user_data->info.hpix*(float)pc/100.0) ;
                              sprintf(buffer, "%.4d/%.4d", micron2dpi(rx), micron2dpi(ry)) ;
                              write_text(adr_print, PRINT_RESOL, buffer) ;
                              deselect(adr_print, obj) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_YPC ) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_SIZEY ) ;
                              xobjc_draw( wnd->window_handle, adr_print, obj ) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_PAGE ) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_RESOL ) ;
                              if (selected(adr_print, PRINT_CENTREX)) button_center( wnd, adr_print, 0, 0 ) ;
                              if (selected(adr_print, PRINT_CENTREY)) button_center( wnd, adr_print, 1, 0 ) ;
                              break ;
      case PRINT_R90        :
      case PRINT_TR90       : inv_select(adr_print, PRINT_R90) ;
                              xc = adr_print[PRINT_IMAGE].ob_width ;
                              adr_print[PRINT_IMAGE].ob_width = adr_print[PRINT_IMAGE].ob_height ;
                              adr_print[PRINT_IMAGE].ob_height = xc ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_PAGE ) ;
                              number = dlg_user_data->sizex ;
                              dlg_user_data->sizex  = dlg_user_data->sizey ;
                              dlg_user_data->sizey  = number ;
                              read_text(adr_print, PRINT_SIZEX, buf) ;
                              read_text(adr_print, PRINT_SIZEY, buffer) ;
                              write_text(adr_print, PRINT_SIZEX, buffer) ;
                              write_text(adr_print, PRINT_SIZEY, buf) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_SIZEX ) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_SIZEY ) ;
                              read_text(adr_print, PRINT_XPC, buf) ;
                              read_text(adr_print, PRINT_YPC, buffer) ;
                              write_text(adr_print, PRINT_XPC, buffer) ;
                              write_text(adr_print, PRINT_YPC, buf) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_XPC ) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_YPC ) ;
                              if (selected(adr_print, PRINT_CENTREX)) button_center( wnd, adr_print, 0, 0 ) ;
                              if (selected(adr_print, PRINT_CENTREY)) button_center( wnd, adr_print, 1, 0 ) ;
                              break ;
      case PRINT_CENTREX    :
      case PRINT_TCENTREX   : button_center( wnd, adr_print, 0, 1 ) ;
                              break ;
      case PRINT_CENTREY    :
      case PRINT_TCENTREY   : button_center( wnd, adr_print, 1, 1 ) ;
                              break ;
      case PRINT_KEEPRATIO  :
      case PRINT_TKEEPRATIO : inv_select(adr_print, PRINT_KEEPRATIO) ;
                              break ;
      case PRINT_IMAGE      : w = adr_print[PRINT_IMAGE].ob_width ;
                              h = adr_print[PRINT_IMAGE].ob_height ;
                              objc_offset(adr_print, PRINT_IMAGE, &ix, &iy) ;
                              objc_offset(adr_print, PRINT_PAGE, &lx, &ly) ;
                              lw = adr_print[PRINT_PAGE].ob_width ;
                              lh = adr_print[PRINT_PAGE].ob_height ;
                              my_dragbox(w, h, ix, iy, lx, ly, lw, lh, &xr, &yr) ;
                              adr_print[PRINT_IMAGE].ob_x = xr-lx ;
                              adr_print[PRINT_IMAGE].ob_y = yr-ly ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_PAGE ) ;
                              if (selected(adr_print, PRINT_CENTREX)) inv_select(adr_print, PRINT_CENTREX) ;
                              if (selected(adr_print, PRINT_CENTREY)) inv_select(adr_print, PRINT_CENTREY) ;
                              break ;
      case PRINT_CONFIGPAGE : deselect(adr_print, PRINT_CONFIGPAGE) ;
                              dlg_user_data->page_index = tab_page_index(&dlg_user_data->page) ;
                              objc_offset(adr_print, PRINT_CONFIGPAGE, &xc, &yc) ;
                              clicked  = popup_formdo(&wext->popup_page, xc, yc, 1+dlg_user_data->page_index, 0) ;
                              if (clicked > 0)
                              {
                                write_text(adr_print, PRINT_CONFIGPAGE, tab_page[clicked-1]->nom) ;
                                memcpy(&dlg_user_data->page, tab_page[clicked-1], sizeof(PAGE)) ;
                                compute_page( dlg ) ;
                                xobjc_draw( wnd->window_handle, adr_print, PRINT_GROUP ) ;
                              }
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_CONFIGPAGE ) ;
                              show_dimpage( wnd, &dlg_user_data->page, adr_print ) ;

                              read_text(adr_print, PRINT_XPC, buffer) ;
                              pc = atoi(buffer) ;
                              sprintf(buffer, "%d", pc) ;
                              number = dlg_user_data->sizex*(float)pc/100.0 ;
                              adr_print[PRINT_IMAGE].ob_width = (int) (number*(float)dlg_user_data->spy/dlg_user_data->page.hauteur) ;
                              sprintf(buffer, "%.1f", number) ;
                              write_text(adr_print, PRINT_SIZEY, buffer) ;
                              read_text(adr_print, PRINT_YPC, buffer) ;
                              pc = atoi(buffer) ;
                              sprintf(buffer, "%d", pc) ;
                              number = dlg_user_data->sizey*(float)pc/100.0 ;
                              adr_print[PRINT_IMAGE].ob_height = (int) (number*(float)dlg_user_data->spx/dlg_user_data->page.largeur) ;
                              sprintf(buffer, "%.1f", number) ;
                              write_text(adr_print, PRINT_SIZEY, buffer) ;
                              rx = (int) ((float)dlg_user_data->info.lpix*(float)pc/100.0) ;
                              ry = (int) ((float)dlg_user_data->info.hpix*(float)pc/100.0) ;
                              sprintf(buffer, "%.4d/%.4d", micron2dpi(rx), micron2dpi(ry)) ;
                              write_text(adr_print, PRINT_RESOL, buffer) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_SIZEY ) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_PAGE ) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_RESOL ) ;
                              if (selected(adr_print, PRINT_CENTREX)) button_center( wnd, adr_print, 0, 0 ) ;
                              if (selected(adr_print, PRINT_CENTREY)) button_center( wnd, adr_print, 1, 0 ) ;
                              break ;
      case PRINT_PRINTER    : deselect(adr_print, PRINT_PRINTER) ;
                              objc_offset(adr_print, PRINT_PRINTER, &xc, &yc) ;
                              clicked  = popup_formdo(&wext->popup_printer, xc, yc, 1+dlg_user_data->printer_index, 0) ;
                              if (clicked > 0)
                              {
                                dlg_user_data->printer_index = clicked-1 ;
                                write_text(adr_print, PRINT_PRINTER, wext->popup_printer[1+dlg_user_data->printer_index].ob_spec.free_string) ;
                              }
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_PRINTER ) ;
                              sprintf(buffer, "%d", id[dlg_user_data->printer_index]) ;
                              write_text(adr_print, PRINT_ID, buffer) ;
                              xobjc_draw( wnd->window_handle, adr_print, PRINT_ID ) ;
                              break ;
      case PRINT_TYPE       : if (!(adr_print[PRINT_TYPE].ob_state & DISABLED))
                              {
                                deselect(adr_print, PRINT_TYPE) ;
                                objc_offset(adr_print, PRINT_TYPE, &xc, &yc) ;
                                clicked  = popup_formdo(&wext->popup_type, xc, yc, 1+dlg_user_data->type_index, 0) ;
                                if (clicked > 0)
                                {
                                  dlg_user_data->type_index = clicked-1 ;
                                  write_text(adr_print, PRINT_TYPE, wext->popup_type[1+dlg_user_data->type_index].ob_spec.free_string) ;
                                }
                                xobjc_draw( wnd->window_handle, adr_print, PRINT_TYPE ) ;
                              }
                              break ;
      case PRINT_FILE       : strcpy(buffer, dlg_user_data->filename) ;
                              c = strrchr(buffer, '\\') ;
                              if (c != NULL) *c = 0 ;
                              strcat(buffer, "\\*.*") ;

                              if ( file_name(buffer, "", buffer) == 1 )
                              {
                                INFO_IMAGE inf ;

                                strcpy(dlg_user_data->filename, buffer) ;
                                write_text(adr_print, PRINT_FILE, dlg_user_data->filename) ;

                                if ( img_format( dlg_user_data->filename, &inf ) == 0 )
                                {
                                  memcpy( &dlg_user_data->info, &inf, sizeof(INFO_IMAGE) ) ;
                                  deselect(adr_print, PRINT_R90) ;
                                  deselect(adr_print, PRINT_CENTREX) ;
                                  deselect(adr_print, PRINT_CENTREY) ;
                                  memset(&dlg_user_data->raster, 0, sizeof(MFDB)) ;
                                  dlg_user_data->raster.fd_w       = dlg_user_data->info.largeur ;
                                  dlg_user_data->raster.fd_h       = dlg_user_data->info.hauteur ;
                                  dlg_user_data->raster.fd_nplanes = dlg_user_data->info.nplans ;
                                  dlg_user_data->raster.fd_wdwidth = dlg_user_data->raster.fd_w/16 ;
                                  if (dlg_user_data->raster.fd_w % 16) dlg_user_data->raster.fd_wdwidth++ ;
                                  dlg_user_data->sizex = (float)dlg_user_data->raster.fd_w*(float)dlg_user_data->info.lpix/10000.0 ; /* En cm */
                                  sprintf(buffer, "%.1f", dlg_user_data->sizex) ;
                                  write_text(adr_print, PRINT_SIZEX, buffer) ;
                                  dlg_user_data->sizey = (float)dlg_user_data->raster.fd_h*(float)dlg_user_data->info.hpix/10000.0 ; /* En cm */
                                  sprintf(buffer, "%.1f", dlg_user_data->sizey) ;
                                  write_text(adr_print, PRINT_SIZEY, buffer) ;
                                  write_text(adr_print, PRINT_XPC, "100") ;
                                  write_text(adr_print, PRINT_YPC, "100") ;
                                  compute_page( dlg ) ;
                                }
                              }
                              deselect(adr_print, obj) ;
                              break ;
      case PRINT_OK         : code = IDOK ;
                              break ;
      case PRINT_CANCEL     : code = IDCANCEL ;
                              break ;
    }

  if ( code == IDOK )
  {
    /* Mise a jour de UserData */
    dlg_user_data->rotate90 = selected( adr_print, PRINT_R90 ) ;
    read_text( adr_print, PRINT_XPC, buffer ) ;
    dlg_user_data->xpc = atof( buffer ) ;
    read_text( adr_print, PRINT_YPC, buffer ) ;
    dlg_user_data->ypc = atof( buffer ) ;
    dlg_user_data->posx = dlg_user_data->page.largeur*(float)adr_print[PRINT_IMAGE].ob_x/(float)adr_print[PRINT_PAGE].ob_width ;
    dlg_user_data->posy = dlg_user_data->page.hauteur*(float)adr_print[PRINT_IMAGE].ob_y/(float)adr_print[PRINT_PAGE].ob_height ;
  }

  return( code ) ;
}
 
int OnClosePrinterDialog(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  DLGPRINTER_WEXTENSION *wext = wnd->Extension ;
 
  popup_kill( wext->popup_type, 2 ) ;
  popup_kill( wext->popup_printer, nb_drivers ) ;
  popup_kill( wext->popup_page, 1+LAST_INDEX ) ;

  return( GWCloseDlg( wnd ) ) ;
}

int print_image(MFDB *raster, INFO_IMAGE *in_info)
{
  GEM_WINDOW *wprog = NULL ;
  DLGDATA    dlg_data ;
  DLGPRINTER_USER_DATA dlg_user_data ;
  GEM_WINDOW *dlg ;
  MFDB       src ;
  float      sizex, sizey ;
  float      ptpx, ptpy ;
  int        pintin[256], pintout[256] ;
  int        xyarray[4] ;
  int        print_handle ;
  int        i, xoffset, yoffset ;
  int        bouton ;
  int        dither_mono, print_color ;
  char       *filename = dlg_user_data.filename ;
  char       *c ;
  char       buffer[200] ;
  char       nom[30] ;

  if ( !Gdos ) return(PNOGDOS) ;
  if ( !printer_init ) scan_drivers() ;
  if ( nb_drivers <= 0 ) return( PNODRIVER ) ;

  memset( &dlg_user_data, 0, sizeof(DLGPRINTER_USER_DATA) ) ;
  if ( raster ) memcpy( &dlg_user_data.raster, raster, sizeof(MFDB) ) ;
  if ( in_info ) memcpy( &dlg_user_data.info, in_info, sizeof(INFO_IMAGE) ) ;

  while ( dlg_user_data.raster.fd_w == 0 )
  {
    strcpy( buffer, filename ) ;
    c = strrchr( buffer, '\\' ) ;
    if ( c ) *c = 0 ;
    strcat( buffer, "\\*.*" ) ;
    if ( file_name( buffer, "", buffer ) == 1 )
    {
      INFO_IMAGE inf ;

      strcpy( dlg_user_data.filename, buffer ) ;
      if ( img_format(dlg_user_data.filename, &inf) == 0 )
      {
        memcpy(&dlg_user_data.info, &inf, sizeof(INFO_IMAGE)) ;
        memset(&dlg_user_data.raster, 0, sizeof(MFDB)) ;
        dlg_user_data.raster.fd_w       = inf.largeur ;
        dlg_user_data.raster.fd_h       = inf.hauteur ;
        dlg_user_data.raster.fd_nplanes = inf.nplans ;
        dlg_user_data.raster.fd_wdwidth = dlg_user_data.raster.fd_w/16 ;
        if (dlg_user_data.raster.fd_w % 16) dlg_user_data.raster.fd_wdwidth++ ;
      }
    }
    else return(PCANCEL) ;
  }

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId         = FORM_PRINT ;
  dlg_data.UserData       = &dlg_user_data ;
  dlg_data.ExtensionSize  = 0 ; /* Sera alloue par OnInitPrinterDialog */
  dlg_data.OnInitDialog   = OnInitPrinterDialog ;
  dlg_data.OnObjectNotify = OnObjectNotifyPrinterDialog ;
  dlg_data.OnCloseDialog  = OnClosePrinterDialog ;

  dlg    = GWCreateDialog( &dlg_data ) ;
  bouton = GWDoModal( dlg, PRINT_XPC ) ;
  if ( bouton == IDCANCEL ) return( PCANCEL ) ;

  printer_index = dlg_user_data.printer_index ;
  type_index    = dlg_user_data.type_index ;

  if ( dlg_user_data.filename[0] )
  {
    INFO_IMAGE inf ;
    int        analyse = img_analyse ;

    img_analyse = 0 ;
    if ( img_format( dlg_user_data.filename, &inf ) == 0 )
    {
      memcpy(&dlg_user_data.info, &inf, sizeof(INFO_IMAGE)) ;
      src.fd_nplanes = -1 ; /* Conserver le nombre de plans */
      Force16BitsLoad = 0 ;
      wprog = DisplayStdProg( MsgTxtGetMsg(hMsg, MSG_LOADINGIMG) , "", dlg_user_data.filename, 0 ) ;
      if ( load_picture( dlg_user_data.filename, &src, &inf, wprog ) != 0 )
      {
        GWDestroyWindow( wprog ) ;
        img_analyse = analyse ;
        return(PCANCEL) ;
      }
      StdProgWText( wprog, 1, "" ) ;
    }
    else
    {
      img_analyse = analyse ;
      return( PCANCEL ) ;
    }

    img_analyse = analyse ;
    GWDestroyWindow( wprog ) ;
    wprog = NULL ;
  }
  else
    memcpy( &src, &dlg_user_data.raster, sizeof(MFDB) ) ;

  pintin[0] = id[dlg_user_data.printer_index] ;
  if ((pintin[0] < 21) || (pintin[0] > 30)) return( PNOHANDLE ) ;
  for (i = 1; i < 10; i++) pintin[i] = 1 ;
  pintin[10] = 2 ;
  v_opnwk( pintin, &print_handle, pintout ) ;
  if ( print_handle <= 0 ) return(PNOHANDLE) ;

  ptpx = (float)pintout[3] ; /* Largeur d'un point imprimante en microns */
  ptpy = (float)pintout[4] ; /* Hauteur d'un point imprimante en microns */
  wprog = DisplayStdProg( "", "", "", CLOSER ) ;

  dither_mono = (dlg_user_data.type_index == 1) && (src.fd_nplanes > 1) ;
  print_color = (dlg_user_data.type_index == 0) ;
  if ( dither_mono ) /* Mode noir et blanc */
  {
    MFDB virtuel ;
    int  pc_x, pc_y ;

    StdProgWText( wprog, 0, MsgTxtGetMsg(hMsg, MSG_DITHER)  ) ;
    virtuel.fd_nplanes = 1 ;
    if ( dlg_user_data.rotate90 )
      pc_x = (int) (dlg_user_data.xpc*(float)dlg_user_data.info.lpix/ptpy) ;
    else
      pc_x = (int) (dlg_user_data.xpc*(float)dlg_user_data.info.lpix/ptpx) ;
    if ( dlg_user_data.rotate90 )
      pc_y = (int) (dlg_user_data.ypc*(float)dlg_user_data.info.hpix/ptpx) ;
    else
      pc_y = (int) (dlg_user_data.ypc*(float)dlg_user_data.info.hpix/ptpy) ;
    mouse_busy() ;
    if ( dither_ratio(&src, &dlg_user_data.info, &virtuel, pc_x, pc_y, wprog ) == -1 )
    {
      if ( dlg_user_data.filename[0] )
      {
        Xfree( src.fd_addr ) ;
        if ( dlg_user_data.filename[0] && dlg_user_data.info.palette ) Xfree( dlg_user_data.info.palette ) ;
      }
      mouse_restore() ;
      GWDestroyWindow( wprog ) ;
      v_clswk( print_handle ) ;
      return( PROTERR ) ;
    }
    wprog->ProgPc( wprog, 0, NULL ) ;
    mouse_restore() ;
    if ( dlg_user_data.filename[0] ) Xfree( src.fd_addr ) ;
    memcpy( &src, &virtuel, sizeof(MFDB) ) ;
  }

  if ( dlg_user_data.rotate90 )
  {
    MFDB virtuel ;
 
    StdProgWText( wprog, 0, MsgTxtGetMsg(hMsg, MSG_ROTATING)  ) ;
    mouse_busy() ;
    if ( raster_r90( &src, &virtuel, wprog ) != 0 )
    {
      if ( dither_mono || dlg_user_data.filename[0] ) Xfree( src.fd_addr ) ;
      if ( dlg_user_data.filename[0] && dlg_user_data.info.palette ) Xfree( dlg_user_data.info.palette ) ;
      mouse_restore() ;
      GWDestroyWindow( wprog ) ;
      v_clswk( print_handle ) ;
      return( PROTERR ) ;
    }
    mouse_restore() ;
    if ( dither_mono || dlg_user_data.filename[0] ) Xfree(src.fd_addr ) ;
    memcpy( &src, &virtuel, sizeof(MFDB) ) ;
  }

  sizex = (float)src.fd_w*(float)dlg_user_data.info.lpix*dlg_user_data.xpc/100.0 ;
  sizey = (float)src.fd_h*(float)dlg_user_data.info.hpix*dlg_user_data.ypc/100.0 ;
  sizex /= 10000.0 ;
  sizey /= 10000.0 ;
  if ( !print_color )
  {
    StdProgWText( wprog, 0, MsgTxtGetMsg(hMsg, MSG_DOGDOSIMG)  ) ;
    strcpy(nom, "VSCRAP.IMG") ;
    if ( img_sauve( nom, &src, &dlg_user_data.info, wprog ) )
    {
      if ( dither_mono || dlg_user_data.filename[0] || dlg_user_data.rotate90 ) Xfree( src.fd_addr ) ;
      if ( dlg_user_data.filename[0] && dlg_user_data.info.palette ) Xfree( dlg_user_data.info.palette ) ;
      GWDestroyWindow( wprog ) ;
      v_clswk( print_handle ) ;
      return( PWRITERR ) ;
    }
  }
  else
  {
    INFO_IMAGE new_info ;
    MFDB       new_img ;

    memcpy( &new_info, &dlg_user_data.info, sizeof(INFO_IMAGE) ) ;
    memcpy( &new_img, &src, sizeof(MFDB) ) ;
    if ( new_img.fd_nplanes <= 8 )
    {
      new_info.nb_cpal   = 0 ;
      new_info.palette   = NULL ;
      new_info.nplans    = 16 ;
      new_img.fd_addr    = NULL ;
      new_img.fd_nplanes = 16 ;
      StdProgWText( wprog, 0, MsgTxtGetMsg(hMsg, MSG_DOGDOSIMG)  ) ;
      if ( index2truecolor( &src, &dlg_user_data.info, &new_img, wprog ) != 0 )
      {
        if ( dither_mono || dlg_user_data.filename[0] || dlg_user_data.rotate90 ) Xfree( src.fd_addr ) ;
        if ( dlg_user_data.filename[0] && dlg_user_data.info.palette ) Xfree( dlg_user_data.info.palette ) ;
        v_clswk( print_handle ) ;
        GWDestroyWindow( wprog ) ;
        return( PWRITERR ) ;
      }
    }
    strcpy( nom, "VSCRAP.TGA" ) ;
    if ( targa_sauve( nom, &new_img, &new_info, wprog ) )
    {
      if ( dither_mono || dlg_user_data.filename[0] || dlg_user_data.rotate90 ) Xfree( src.fd_addr ) ;
      if ( dlg_user_data.filename[0] && dlg_user_data.info.palette ) Xfree( dlg_user_data.info.palette ) ;
      v_clswk( print_handle ) ;
      GWDestroyWindow( wprog ) ;
      return( PWRITERR ) ;
    }
    if ( src.fd_nplanes <= 8 ) Xfree( new_img.fd_addr ) ;
  }

  if ( dither_mono || dlg_user_data.filename[0] || dlg_user_data.rotate90 ) Xfree( src.fd_addr ) ;
  if ( dlg_user_data.filename[0] && dlg_user_data.info.palette ) Xfree( dlg_user_data.info.palette ) ;

  StdProgWText( wprog, 0, MsgTxtGetMsg(hMsg, MSG_PRINTING)  ) ;
  vst_unload_fonts( handle, 0 ) ;
  xoffset = (int) (10000.0*dlg_user_data.posx/ptpx) ;
  yoffset = (int) (10000.0*dlg_user_data.posy/ptpy) ;
  xyarray[0] = xoffset ;
  xyarray[1] = yoffset ;
  xyarray[2] = xoffset+(int) (10000.0*sizex/ptpx) ;
  xyarray[3] = yoffset+(int) (10000.0*sizey/ptpy) ;

  mouse_busy() ;
  vs_page_info(print_handle, APPL,	MENU_NAME) ;
  vs_page_info(print_handle, DOC,	nom) ;
  vs_page_info(print_handle, CREAT,	"") ;
  vs_page_info(print_handle, REM,	"Thanks to Thierry Rodolfo !" ) ;

  if (dither_mono)
    v_bit_image(print_handle, nom, 0, INTEGER, INTEGER, 0, 0, xyarray) ;
  else
    v_bit_image(print_handle, nom, 0, FRACTIONAL, FRACTIONAL, 0, 0, xyarray) ;
  v_updwk(print_handle) ;
  v_clrwk(print_handle) ;
  v_clswk(print_handle) ;
  vst_load_fonts(handle, 0) ;
  mouse_restore() ;
  unlink(nom) ;
  GWDestroyWindow( wprog ) ;

  return( 0 ) ;
}
