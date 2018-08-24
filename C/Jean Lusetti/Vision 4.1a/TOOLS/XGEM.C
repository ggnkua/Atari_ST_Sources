/******************************************/
/*--------------- XGEM.C -----------------*/
/* Quelques fonctions qui ‚tendent le GEM */
/******************************************/
#include     <time.h>
#include    <stdio.h>
#include   <string.h>
#include   <stdlib.h>

#include   "..\tools\xrsrc.h"
#include   "..\tools\xgem.h"
#include "..\tools\cookies.h"
#include "..\tools\rasterop.h"
#include "..\tools\logging.h"

AES_FEATURES AESFeatures ;            /* Trucs speciaux de l'AES           */
MACHINE_INFO MachineInfo ;            /* Informations sur la machine       */
DSP_INFO     DspInfo ;                /* Informations sur le DSP           */
LINE_TYPE    ltype ;                  /* D‚finition des paramŠtres lignes  */
MARKER_TYPE  mtype ;                  /* D‚finition des paramŠtres point   */
FILL_TYPE    ftype ;                  /* D‚finition du remplissage         */
TEXT_TYPE    ttype ;                  /* D‚finition des attributs texte    */
MOUSE_DEF    mouse ;                  /* Forme actuelle de la souris       */
MOUSE_DEF    msave ;                  /* Forme pr‚cedemment sauvegard‚e    */
MFDB         screen ;                 /* Bloc MFDB format ‚cran            */
float        aspectratio ;            /* Hauteur/largeur d'un pixel        */
int          ap_id ;                  /* Identificateur de l'application   */
int          handle ;                 /* Handle VDI                        */
int          xdesk, ydesk ;           /* Coordonn‚es et tailles de la      */
int          wdesk, hdesk ;           /* Zone graphique exploitable.       */
int          Xmax, Ymax ;             /* Coordonn‚es maximales de l'‚cran  */
int          h_car_max ;              /* Hauteur maximale d'un caractŠre   */
int          nb_colors ;              /* Nombre de couleurs simultan‚es    */
int          nb_plane ;               /* Nombre de plans de la r‚solution  */
int          num_sys_font ;           /* Indice de la fonte systŠme        */
int          num_fonts ;              /* Nombre de fontes suppl‚mentaires  */
int          Multitos ;               /* 1 si l'AES est multitache         */
int          Truecolor ;              /* 1 si le mode video est True Color */
int          Gdos ;                   /* 0 si Gdos est absent              */
int          AESVersion ;             /* Version de l'AES                  */ 
int          UseStdVDI ;              /* Utiliser le format Atari (0) ou   */
                                      /* Le format VDI Standard (1)        */
RVB_ORG RVBOrg ;                      /* Organisation TC de cette machine  */
RVB_ORG FRVBOrg16 = { 11, 6, 0, 0 } ; /* Organisation TC16 du FALCON       */  
RVB_ORG FRVBOrg24 = {  0, 1, 2, 0 } ; /* Organisation TC24 du FALCON       */  
RVB_ORG FRVBOrg32 = { 11, 6, 0, 0 } ; /* Organisation TC32 du FALCON       */  


char *init_path ;                  /* R‚pertoire de lancement            */

void cycling_ado(int sens) ;
long adr_palette ;                 /* Adresse palette de couleurs        */

unsigned char vdi2tos1[2] ;
unsigned char tos2vdi1[2] ;
unsigned char vdi2tos2[4] ;
unsigned char tos2vdi2[4] ;
unsigned char vdi2tos4[16] ;
unsigned char tos2vdi4[16] ;
unsigned char vdi2tos8[256] ;
unsigned char tos2vdi8[256] ;
int           *old_pal ;

/* MagiC specifique */
MAGX_COOKIE   *MagXCookie = NULL ;

/* Section XRessource */
int   vdi_handle;
GRECT desk;
int   gl_wbox = 0, gl_hbox = 0,
      gl_wattr = 0, gl_hattr = 0 ;

int vdi_sys_colors[3*16] = {
                             1000, 1000, 1000,
                                0,    0,    0,
                             1000,    0,    0,
                                0, 1000,    0,
                                0,    0, 1000,
                                0, 1000, 1000,
                             1000, 1000,    0,
                             1000,    0, 1000,
                              800,  800,  800,
                              500,  500,  500,
                              500,    0,    0,
                                0,  500,    0,
                                0,    0,  500,
                                0,  500,  500,
                              500,  500,    0,
                              500,    0,  500
                                
                           } ;
                           
LOCAL WORD bidon_global[15];
LOCAL int choix_rsrc=-1; /* choix du mode d'affichage des ressources suivant le systŠme -1 pas encore choisi, 1 rsrc_load systeme, 0 xrsrc */

int Xrsrc_load(char *rsc_name)
{
  if(choix_rsrc==-1)
  {
  	if ( (AESVersion >= 0x0400) || (appl_find("?AGI\0\0\0\0") >= 0) )
  	{ WORD a1,a2,a3=0,a4=0;
  		appl_getinfo(2,&a1,&a2,&a3,&a4);
  		if(a3 && a4&2) choix_rsrc=1;
  		else choix_rsrc=0;
  	}
  	else choix_rsrc=0;
  }

  if ( choix_rsrc == 1 ) return rsrc_load(rsc_name) ;
  return( xrsrc_load( rsc_name, bidon_global/*_GemParBlk.global*/ ) ) ;
}

int Xrsrc_gaddr(int re_gtype, int re_gindex, void *gaddr)
{
  if ( choix_rsrc == 1 ) return rsrc_gaddr( re_gtype, re_gindex, gaddr);
  return( xrsrc_gaddr( re_gtype, re_gindex, gaddr, bidon_global/*_GemParBlk.global*/ ) ) ;
}

int Xrsrc_free(void)
{
  if ( choix_rsrc == 1 ) return rsrc_free();
  return( xrsrc_free( bidon_global/*_GemParBlk.global*/ ) ) ;
}

int Xrsrc_obfix(OBJECT *re_otree, WORD re_oobject)
{
  if ( choix_rsrc == 1 ) return rsrc_obfix( re_otree, re_oobject );
  return( xrsrc_obfix( re_otree, re_oobject ) ) ;
}

int nb_planes(int nb_color)
{
  int nplanes ;

  switch( nb_color )
  {
    case   1 :
    case   2 : nplanes = 1 ;
               break ;
    case   4 : nplanes = 2 ;
               break ;
    case   8 : nplanes = 3 ;
               break ;
    case  16 : nplanes = 4 ;
               break ;
    case  32 : nplanes = 5 ;
               break ;
    case 256 : nplanes = 8 ;
               break ;
    default  : nplanes = -1 ;
               break ;
  }

  return( nplanes ) ;
}

unsigned char *get_pttos2vdi(int nplanes)
{
  switch( nplanes )
  {
    case 1  : return( tos2vdi1 ) ;
    case 2  : return( tos2vdi2 ) ;
    case 4  : return( tos2vdi4 ) ;
    case 8  : return( tos2vdi8 ) ;
    default : return( NULL ) ;
  }
}

unsigned char *get_ptvdi2tos(int nplanes)
{
  switch( nplanes )
  {
    case 1  : return( vdi2tos1 ) ;
    case 2  : return( vdi2tos2 ) ;
    case 4  : return( vdi2tos4 ) ;
    case 8  : return( vdi2tos8 ) ;
    default : return( NULL ) ;
  }
}

void set_tospalette(int *pal, int nb_col)
{
  int           i, *pt_pal ;
  unsigned char *tos2vdi ;

  tos2vdi = get_pttos2vdi(nb_planes(nb_col)) ;
  if ( tos2vdi == NULL ) return ;
  pt_pal = pal ;
  for (i = 0; i < nb_col; i++)
  {
    vs_color( handle, tos2vdi[i], pt_pal ) ;
    pt_pal += 3 ; /* 3 niveaux (RVB) */
  }
}

void set_stospalette(int *pal, int nb_col, int start)
{
  int           i, *pt_pal ;
  unsigned char *tos2vdi ;

  tos2vdi = get_pttos2vdi(nb_plane) ;
  if ( tos2vdi == NULL ) return ;
  pt_pal  = pal+3*start ;
  for (i = 0; i < nb_col; i++)
  {
    vs_color(handle, tos2vdi[start+i], pt_pal) ;
    pt_pal += 3 ; /* 3 niveaux (RVB) */
  }
}

void get_tospalette(int *pal)
{
  int i, *pt_pal ;
  unsigned char *tos2vdi ;

  tos2vdi = get_pttos2vdi( nb_plane ) ;
  if ( tos2vdi == NULL )
  {
    *pal++ = 1000 ;
    *pal++ = 1000 ;
    *pal++ = 1000 ;
    for ( i = 3; i < nb_colors*3; i++ ) *pal++ = 0 ;
  }
  else
  {
    pt_pal  = pal ;
    for ( i = 0; i < nb_colors; i++ )
    {
      vq_color(handle, tos2vdi[i], 0, pt_pal) ;
      pt_pal += 3 ;
    }
  }
}

void get_vdipalette(int *pal)
{
  int i, *pt_pal ;

  pt_pal = pal ;
  for (i = 0; i < nb_colors; i++)
  {
    vq_color(handle, i, 0, pt_pal) ;
    pt_pal += 3 ;
  }
}

void set_vdipalette(int *pal, int nb_col)
{
  int i, *pt_pal ;

  pt_pal = pal ;
  for (i = 0; i < nb_col; i++)
  {
    vs_color(handle, i, pt_pal) ;
    pt_pal += 3 ; /* 3 niveaux (RVB) */
  }
}

int set_mform(MOUSE_DEF *info)
{
  static MOUSE_DEF cminfo ;

  if ( memcmp( &cminfo, info, sizeof(MOUSE_DEF) ) != 0 )
  {
    if ( info->gr_monumber != USER_DEF )
      graf_mouse( info->gr_monumber, NULL ) ;
    else
      graf_mouse( info->gr_monumber, &info->gr_mof ) ;
    mouse.gr_monumber = info->gr_monumber ;
    memcpy( &mouse.gr_mof, &info->gr_mof, sizeof(MFORM) ) ;

    memcpy( &cminfo, info, sizeof(MOUSE_DEF) ) ;
  }
  
  return( info->gr_monumber ) ;
}

void mouse_busy(void)
{
  memcpy(&msave, &mouse, sizeof(MOUSE_DEF)) ;
  mouse.gr_monumber = BUSYBEE ;
  set_mform(&mouse) ;
}

void mouse_restore(void)
{
  set_mform(&msave) ;
}

void fill_window(int w_handle, int color_index)
{
  int xy[4] ;
  int xi, yi, wi, hi ;

  v_hide_c(handle) ;
  wind_get(w_handle, WF_WORKXYWH, &xi, &yi, &wi, &hi) ;
  xy[0] = xi ;      xy[1] = yi ;
  xy[2] = xi+wi-1 ; xy[3] = yi+hi-1 ;
  if (xy[0] < 0)    xy[0] = 0 ;
  if (xy[0] > Xmax) xy[0] = Xmax ;
  if (xy[1] < 0)    xy[1] = 0 ;
  if (xy[1] > Ymax) xy[1] = Ymax ;
  if (xy[2] < 0)    xy[2] = 0 ;
  if (xy[2] > Xmax) xy[2] = Xmax ;
  if (xy[3] < 0)    xy[3] = 0 ;
  if (xy[3] > Ymax) xy[3] = Ymax ;

  vswr_mode(handle, MD_REPLACE) ;
  vsf_interior(handle, color_index) ;
  vsf_perimeter(handle, 0) ;  /* Pas de cadre                */
  v_bar(handle, xy) ;         /* Pav‚ rempli                 */
  vsf_perimeter(handle ,1) ;  /* Activer de nouveau le cadre */
  v_show_c(handle, 1) ;
}

void remove_accents(char *string)
{
  char *pt ;

  pt = string ;
  while (*pt != 0)
  {
    switch(*pt)
    {
      case '‰' :
      case 'ˆ' :
      case 'Š' :
      case '‚' : *pt = 'e' ;
                 break ;
      case '„' :
      case '†' :
      case 'ƒ' :
      case '…' : *pt = 'a' ;
                 break ;
      case '‡' : *pt = 'c' ;
                 break ;
      case '€' : *pt = 'C' ;
                 break ;
      case '' :
      case '—' : *pt = 'u' ;
                 break ;
      case '‹' :
      case '' :
      case 'Œ' : *pt = 'i' ;
                 break ;
    }

    pt++ ;
  }
}

int form_exclamation(int default_return, char *string)
{
  MOUSE_DEF save ;
  char      temp[200] ;
  int       ret ;

  memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;
  mouse.gr_monumber = ARROW ;
  set_mform(&mouse) ;
  strcpy(temp, "[1]") ;
  strcat(temp, string) ;
  v_show_c(handle, 1) ;
  ret = form_alert(default_return, temp) ;
  set_mform(&save) ;

  return(ret) ;
}

int form_interrogation(int default_return, char *string)
{
  MOUSE_DEF save ;
  char      temp[200] ;
  int       ret ;

  memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;
  mouse.gr_monumber = ARROW ;
  set_mform(&mouse) ;
  strcpy(temp, "[2]") ;
  strcat(temp, string) ;
  v_show_c(handle, 1) ;
  ret = form_alert(default_return, temp) ;
  set_mform(&save) ;
  
  return(ret) ;
}

int form_stop(int default_return, char *string)
{
  MOUSE_DEF save ;
  char temp[200] ;
  int  ret ;

  memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;
  mouse.gr_monumber = ARROW ;
  set_mform(&mouse) ;
  strcpy(temp, "[3]") ;
  strcat(temp, string) ;
  v_show_c(handle, 1) ;
  ret = form_alert(default_return, temp) ;
  set_mform(&save) ;

  return(ret) ;
}

int file_name(char *masque, char *def, char *name)
{
  char path[PATH_MAX], fnam[PATH_MAX] ;
  int  button ;

  strcpy( fnam, def ) ;
  strcpy( path, masque ) ;

  fsel_input( path, fnam, &button ) ;
  if ( button == 1 )
  {
    char *slash ;

    slash = strrchr( path, '\\' ) ;
    if ( slash ) *slash = 0 ;
    sprintf( name, "%s\\%s", path, fnam ) ;
  }

  return( button ) ;
}

void pset(int x, int y)
{
  int xyarray[2] ;
  int *pt ;

  pt    = xyarray ;
  *pt++ = x ;
  *pt++ = y ;
  v_pmarker(handle, 1, xyarray) ;
}

void line(int x1, int y1, int x2, int y2)
{
  int xyarray[4] ;
  int *pt ;

  pt    = xyarray ;
  *pt++ = x1 ; *pt++ = y1 ;
  *pt++ = x2 ; *pt++ = y2 ;
  v_pline(handle, 2, xyarray) ;
}

void rectangle(int x1, int y1, int x2, int y2)
{
  int xyarray[10] ;
  int *pt ;

  pt    = xyarray ;
  *pt++ = x1 ; *pt++ = y1 ;
  *pt++ = x2 ; *pt++ = y1 ;
  *pt++ = x2 ; *pt++ = y2 ;
  *pt++ = x1 ; *pt++ = y2 ;
  *pt++ = x1 ; *pt++ = y1 ;

  v_pline(handle, 5, xyarray) ;
}

void get_linetype(LINE_TYPE *type)
{
  int att[6] ;
  
  vql_attributes(handle, att) ;
  type->style   = att[0] ;
  type->color   = att[1] ;
  type->st_kind = att[3] ;
  type->ed_kind = att[4] ;
  type->width   = att[5] ;
}

void get_markertype(MARKER_TYPE *type)
{
  int att[5] ;
  
  vqm_attributes(handle, att) ;
  type->style  = att[0] ;
  type->color  = att[1] ;
  type->height = att[4] ;
}

void get_filltype(FILL_TYPE *type)
{
  int att[5] ;
  
  vqf_attributes(handle, att) ;
  type->style     = att[0] ;
  type->color     = att[1] ;
  type->sindex    = att[2] ;
  type->perimeter = att[4] ;
}

void get_texttype(TEXT_TYPE *type)
{
  int att[10] ;
  
  vqt_attributes(handle, att) ;
  type->wcar       = att[6] ;
  type->hcar       = att[7] ;
  type->wcell      = att[8] ;
  type->hcell      = att[9] ;
  type->angle      = att[2] ;
  type->font       = att[0] ;
  type->color      = att[1] ;
  type->hdisp      = att[3] ;
  type->vdisp      = att[4] ;
}

void set_linetype(LINE_TYPE *type)
{
  vsl_type(handle, type->style) ;
  vsl_color(handle, type->color) ;
  vsl_ends(handle, type->st_kind, type->ed_kind) ;
  type->width = vsl_width(handle, type->width) ;
}

void set_markertype(MARKER_TYPE *type)
{
  vsm_type(handle, type->style) ;
  vsm_color(handle, type->color) ;
  type->height = vsm_height(handle, type->height) ;
}

void set_filltype(FILL_TYPE *type)
{
  vsf_interior(handle, type->style) ;
  vsf_color(handle, type->color) ;
  vsf_style(handle, type->sindex) ;
  vsf_perimeter(handle, type->perimeter) ;
}

void set_texttype(TEXT_TYPE *type)
{
  int  font_index ;
  int  dummy ;
  char font_name[33] ;
  char outline_font ;

  if (Gdos)
  {
    font_name[32] = 0 ;
    font_index    = vqt_name(handle, type->font, font_name) ;
    outline_font  = font_name[32] ;
    vst_font(handle , font_index) ;
    if (outline_font)
      vst_arbpt(handle, type->hcar, &type->wcar, &dummy, &type->wcell, &type->hcell) ;
    else
      vst_height(handle, type->hcar, &type->wcar, &dummy, &type->wcell, &type->hcell) ;
  }
  else
    vst_height(handle, type->hcar, &type->wcar, &dummy, &type->wcell, &type->hcell) ;
  type->angle     = vst_rotation(handle, type->angle) ;
  type->color     = vst_color(handle, type->color) ;
  type->attribute = vst_effects(handle, type->attribute) ;
  vst_alignment(handle, type->hdisp, type->vdisp, &type->hdisp, &type->vdisp) ;
}

int intersect(int x1, int y1, int w1, int h1,
			  int x2, int y2, int w2, int h2, int *pxyarray)
{
  int x, y, w, h ;

  w = (x2+w2 < x1+w1) ? x2+w2 : x1+w1 ;
  h = (y2+h2 < y1+h1) ? y2+h2 : y1+h1 ;
  x = (x2 > x1) ? x2:x1 ;
  y = (y2 > y1) ? y2:y1 ;

  pxyarray[0] = x ;
  pxyarray[1] = y ;
  pxyarray[2] = w -1 ;
  pxyarray[3] = h -1 ;

  return((w > x) && (h > y)) ;
}

int selected(OBJECT *arbre, int index)
{
  if (arbre[index].ob_state & SELECTED) return(1) ;
  
  return(0) ;
}

void select(OBJECT *arbre, int index)
{
  arbre[index].ob_state |= SELECTED ;
}

void deselect(OBJECT *arbre, int index)
{
  if (index >= 0) arbre[index].ob_state &= ~SELECTED ;
}

void inv_select(OBJECT *arbre, int index)
{
  if (index >= 0)
  {
    if (selected(arbre, index)) deselect(arbre, index) ;
    else                        select(arbre, index) ;
    objc_draw(arbre, index, 0, 0, 0 , wdesk, hdesk) ;
  }
}

void object_flag(OBJECT *arbre, int index, unsigned int flag)
{
  arbre[index].ob_flags = flag ;
}

void view_object(OBJECT *arbre, int index)
{
  arbre[index].ob_flags &= ~HIDETREE ;
}

void hide_object(OBJECT *arbre, int index)
{
  arbre[index].ob_flags |= HIDETREE ;
}

void read_text(OBJECT *arbre, int index, char *string)
{
  TEDINFO *ted ;

  ted = (TEDINFO *) arbre[index].ob_spec.tedinfo ;
  strcpy( string, ted->te_ptext ) ;
}

void write_text(OBJECT *arbre, int index, char *string)
{
  if ( !arbre || !string ) return ;

  if ( arbre[index].ob_type == G_BUTTON )
  {
    char*  ostring =  arbre[index].ob_spec.free_string ;
    size_t len = strlen(ostring) ;

    strncpy( ostring, string, len ) ;
  }
  else
  {
    TEDINFO *ted ;
    int     i = 0 ;
    char *pts, *ptd ;

    ted = (TEDINFO *) arbre[index].ob_spec.tedinfo ;
    pts = string ;
    ptd = ted->te_ptext ;
    while ( ( ++i <= ted->te_txtlen ) && *pts ) *ptd++ = *pts++ ;
    *ptd = 0 ;
  }
}

void write_template(OBJECT *arbre, int index, char *string)
{
  TEDINFO *ted ;

  ted = (TEDINFO *) arbre[index].ob_spec.tedinfo ;
  strcpy(ted->te_ptmplt, string) ;
}

void set_ext(char *name, char *ext)
{
  char *pt ;
  char pext[5] ;

  pt = name ;
  while ((*pt !=0) && (*pt != '.')) pt++ ;
  if (*pt == 0)
  {
    pext[0] = '.' ;
    strcpy(&pext[1], ext) ;
    strcat(name, pext) ;
  }
  else
  {
    pt++ ;
    strcpy(pt, ext) ;
  }
}

int get_ext(char *name, char *ext)
{
  char *slash ;
  char *point ;

  ext[0] = 0 ;
  slash = strrchr( name, '\\' ) ;
  if ( slash == NULL ) point = strrchr( name, '.' ) ;
  else                 point = strrchr( 1+slash, '.' ) ;
  if ( ( point == NULL ) || ( point[1] == 0 ) ) return( 0 ) ;
  
  strcpy( ext, 1+point ) ;

  return( 1 ) ;
}

void wait_for(int mask_event)
{
  EVENT evnt ;

  evnt.ev_mflags    = mask_event | MU_TIMER ;
  evnt.ev_mtlocount = 1 ;
  evnt.ev_mthicount = 0 ;
  evnt.ev_mbclicks  = 258 ;
  evnt.ev_bmask     = 3 ;
  evnt.ev_mbstate   = 0 ;
  evnt.ev_mm1flags  = 0 ;
  evnt.ev_mm1x      = 0 ;
  evnt.ev_mm1y      = 0 ;
  evnt.ev_mm1width  = 0 ;
  evnt.ev_mm1height = 0 ;
  evnt.ev_mm2flags  = 0 ;
  evnt.ev_mm2x      = 0 ;
  evnt.ev_mm2y      = 0 ;
  evnt.ev_mm2width  = 0 ;
  evnt.ev_mm2height = 0 ;
  while (EvntMulti(&evnt) == MU_TIMER) ;
}

void clear_buffers(int mask_event)
{
  EVENT evnt ;
  int   which ;

  evnt.ev_mflags    = mask_event | MU_TIMER ;
  evnt.ev_mtlocount = 50 ;
  evnt.ev_mthicount = 0 ;
  evnt.ev_mbclicks  = 1 ;
  evnt.ev_bmask     = 1 ;
  evnt.ev_mbstate   = 1 ;
  evnt.ev_mm1flags  = 0 ;
  evnt.ev_mm1x      = 0 ;
  evnt.ev_mm1y      = 0 ;
  evnt.ev_mm1width  = 0 ;
  evnt.ev_mm1height = 0 ;
  evnt.ev_mm2flags  = 0 ;
  evnt.ev_mm2x      = 0 ;
  evnt.ev_mm2y      = 0 ;
  evnt.ev_mm2width  = 0 ;
  evnt.ev_mm2height = 0 ;
  do
  {
    which = EvntMulti(&evnt) ;
  }
  while (which != MU_TIMER) ;
}

int GetMagicVersion(void)
{
  if ( MagXCookie ) return ( MagXCookie->aesvars->version ) ;
  else              return ( 0 ) ;
}

long get_fpu(void)
{
  long  fpu_type = TFPU_NONE ;
  short type = (short) (MachineInfo.fpu >> 16) ;

  if ( type & 0x07 ) /* If bit 0, 1 or 2 is set, assume 68881 */
    fpu_type = TFPU_68881 ;
  if ( (type & 0x06) == 0x06 )
    fpu_type = TFPU_68882 ;
  if ( type & 0x08 )
    fpu_type = TFPU_68040 ;
  if ( type & 0x10 )
    fpu_type = TFPU_68060 ;

  return fpu_type ;
}

void get_machineinformation(void)
{
  COOKIE *cookie ;

  cookie = cookie_find("_MCH") ;
  if (cookie == NULL) MachineInfo.machine = 0 ;
  else                MachineInfo.machine = cookie->data ;

  cookie = cookie_find("_CPU") ;
  if (cookie == NULL) MachineInfo.cpu = 0 ;
  else
  {
    MachineInfo.cpu = cookie->data ;
    if ( MachineInfo.cpu >= 30L )
      i2r_use030 = 1 ;
    else
      i2r_use030 = 0 ;
  }

  cookie = cookie_find("_FPU") ;
  if (cookie == NULL) MachineInfo.fpu = 0 ;
  else                MachineInfo.fpu = cookie->data ;

  cookie = cookie_find("_VDO") ;
  if (cookie == NULL) MachineInfo.video = 0 ;
  else                MachineInfo.video = cookie->data ;

  cookie = cookie_find("_SND") ;
  if (cookie == NULL) MachineInfo.sound = 0 ;
  else                MachineInfo.sound = cookie->data ;

  cookie = cookie_find( "MagX" ) ;
  if ( cookie ) MagXCookie = (MAGX_COOKIE*) cookie->data ;
}

int gem_init(void)
{
  int  work_in[11], work_out[57] ;
  int  out[57] ;
  int  smenus, popups, popscroll, mnsel ;
  int  i, j, is_falcon = 0 ;
  char path[PATH_MAX] ;
  
  ap_id = appl_init() ;
  if ( ap_id < 0 ) return( ap_id ) ;

  get_machineinformation() ;
  if ( ( MachineInfo.machine == 0x00010100L ) || ( MachineInfo.machine == 0x00030000L ) ) /* FALCON ! */
  {
    DspInfo.type             = DSP_56001 ;
    DspInfo.use              = 1 ;
    DspInfo.WhatToDoIfLocked = DSPLOCK_IGNORE ;
    is_falcon                = 1 ;
  }
  else
    DspInfo.type = DspInfo.use = 0 ;

  AESVersion = _GemParBlk.global[0] ;
  Multitos   = (_GemParBlk.global[1] < 0) || ( _GemParBlk.global[1] >= 10 )  ;
  smenus = popups = popscroll = mnsel = 0 ;
  if ( (AESVersion >= 0x0400) || (appl_find("?AGI\0\0\0\0") >= 0) )
    appl_getinfo( 9, &smenus, &popups, &popscroll, &mnsel ) ;
  else
  {
    if ( is_falcon ) /* cas special car appl_getinfo non dispo et AESVersion = 0x0330 */
      smenus = popups = popscroll = 1 ;
    else
    {
      int vers ;

      /* Magic renvoie une version AES $0399 mais peut */
      /* Gerer les popups apres la version 5.04        */
      vers = GetMagicVersion() ;
      if ( vers > 0x0504 ) popups = popscroll = 1 ;
    }
  }
  AESFeatures.SubMenus       = smenus ;
  AESFeatures.Popups         = popups ;
  AESFeatures.PopupsScroll   = popscroll ;
  AESFeatures.MNSelAdr       = mnsel ;

  Gdos = vq_gdos() ;

  strcpy( path, " :" ) ;
  path[0] = 'A' + Dgetdrv() ;
  Dgetpath( &path[2], 0 ) ;
  init_path = (char *) Xalloc( 1 + strlen( path ) ) ;
  if ( init_path ) strcpy( init_path, path ) ;

  handle     = graf_handle(&i, &i, &i, &i) ;
  work_in[0] = Getrez()+2 ;
  for (i = 1; i < 10; i++) work_in[i++] = 1 ;
  work_in[10] = 2 ; /* Coordonn‚es raster */
  v_opnvwk(work_in, &handle, work_out) ;
  Xmax         = work_out[0] ;
  Ymax         = work_out[1] ;
  num_sys_font = work_out[10] ;
  nb_colors    = work_out[13] ;
  h_car_max    = work_out[48] ;
  aspectratio  = (double)work_out[4]/(double)work_out[3] ;

  vdi_handle = handle ;
  graf_handle( &gl_wbox, &gl_hbox, &gl_wattr, &gl_hattr ) ;
  wind_get( 0, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h ) ;
  init_xrsrc ( vdi_handle, &desk, gl_wbox, gl_hbox ) ;

  get_linetype( &ltype ) ;
  get_markertype( &mtype ) ;
  get_filltype( &ftype ) ;
  get_texttype( &ttype ) ;

  vq_extnd( handle, 1, out ) ;
  nb_plane = out[4] ;
  Truecolor = (nb_plane > 8) ;
  
  wind_get( 0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk ) ;

  memset( &screen, 0, sizeof(MFDB) ) ;
  screen.fd_addr    = NULL ; /* D‚finit en destination ‚cran le MFDB screen */
  screen.fd_nplanes = nb_plane ;
  screen.fd_w       = 1 + Xmax ;
  screen.fd_wdwidth = screen.fd_w / 16 ;
  if ( screen.fd_w % 16 ) screen.fd_wdwidth++ ;
  screen.fd_h       = 1 + Ymax ;

  for (j = 0; j < 2; j++) vdi2tos1[j] = tos2vdi1[j] = j ;
  for (j = 0; j < 4; j++) vdi2tos2[j] = tos2vdi2[j] = j ;
  for (j = 0; j < 16; j++) vdi2tos4[j] = tos2vdi4[j] = j ;
  for (j = 0; j < 256; j++) vdi2tos8[j] = tos2vdi8[j] = j ;

  vdi2tos2[1] = 3 ; vdi2tos2[2] = 1 ; vdi2tos2[3] = 2 ;
  tos2vdi2[3] = 1 ; tos2vdi2[1] = 2 ; tos2vdi2[2] = 3 ;

  vdi2tos4[1]  = 15 ; vdi2tos4[2]  = 1 ;  vdi2tos4[3]   = 2 ;
  vdi2tos4[5]  = 6 ;  vdi2tos4[6]  = 3 ;  vdi2tos4[7]   = 5 ;
  vdi2tos4[8]  = 7 ;  vdi2tos4[9]  = 8 ;  vdi2tos4[10]  = 9 ;
  vdi2tos4[11] = 10 ; vdi2tos4[13] = 14 ; vdi2tos4[14]  = 11 ;
  vdi2tos4[15] = 13 ;
  tos2vdi4[15] = 1 ;  tos2vdi4[1]  = 2 ;  tos2vdi4[2]   = 3 ;
  tos2vdi4[6]  = 5 ;  tos2vdi4[3]  = 6 ;  tos2vdi4[5]   = 7 ;
  tos2vdi4[7]  = 8 ;  tos2vdi4[8]  = 9 ;  tos2vdi4[9]   = 10 ;
  tos2vdi4[10] = 11 ; tos2vdi4[14] = 13 ; tos2vdi4[11]  = 14 ;
  tos2vdi4[13] = 15 ;

  vdi2tos8[1]   = 255 ; vdi2tos8[15] = 13 ;
  vdi2tos8[255] = 15 ;
  vdi2tos8[2]   = 1 ;  vdi2tos8[3]  = 2 ;
  vdi2tos8[5]   = 6 ;  vdi2tos8[6]  = 3 ;  vdi2tos8[7]  = 5 ;
  vdi2tos8[8]   = 7 ;  vdi2tos8[9]  = 8 ;  vdi2tos8[10] = 9 ;
  vdi2tos8[11]  = 10 ; vdi2tos8[13] = 14 ; vdi2tos8[14] = 11 ;
  tos2vdi8[1]   = 2 ;  tos2vdi8[15] = 255 ;
  tos2vdi8[255] = 1 ;
  tos2vdi8[13]  = 15 ; tos2vdi8[2]  = 3 ;
  tos2vdi8[6]   = 5 ;  tos2vdi8[3]  = 6 ;  tos2vdi8[5]  = 7 ;
  tos2vdi8[7]   = 8 ;  tos2vdi8[8]  = 9 ;  tos2vdi8[9]  = 10 ;
  tos2vdi8[10]  = 11 ; tos2vdi8[14] = 13 ; tos2vdi8[11] = 14 ;

  FindScreenOrg( &RVBOrg ) ;
  if ( !Truecolor )
  {
    if ( nb_plane < 4 ) old_pal = (int *) Xcalloc( 16, 3 * sizeof(int) ) ;
    else                old_pal = (int *) Xcalloc( 1 << nb_plane, 3 * sizeof(int) ) ;
    get_tospalette( old_pal ) ;
  }
  graf_mouse( ARROW, 0L ) ;

  rasterop_init() ;

  return( ap_id ) ;
}

int gem_exit(void)
{
  rasterop_exit() ;
  if ( old_pal )
  {
    set_tospalette( old_pal, nb_colors ) ;
    Xfree( old_pal ) ;
  }
  if ( init_path ) Xfree( init_path ) ;
  v_clsvwk( handle ) ;

  if ( appl_exit() == 0 ) return( 0 ) ;

  return( 1 ) ;
}

void my_dragbox(int w, int h, int ix, int iy, int lx, int ly, int lw, int lh,
                int *fx, int *fy)
{
  MOUSE_DEF save ;
  int       x1, y1, x2, y2 ;
  int       xi1, yi1, xi2, yi2 ;
  int       xm, ym, xm1, ym1, button, dummy ;

  memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;
  mouse.gr_monumber = FLAT_HAND ;
  set_mform(&mouse) ;
  *fx = *fy = 0 ;
  vswr_mode(handle, MD_XOR) ;
  vsl_color(handle, 1) ;
  vsl_type(handle, 1) ;
  vsl_width(handle, 1) ;
  vsl_ends(handle, 0, 0) ;
  x1 = ix ;     y1 = iy ;
  x2 = ix+w-1 ; y2 = iy+h-1 ;
  v_hide_c(handle) ;
  rectangle(x1, y1, x2, y2) ;
  v_show_c(handle, 1) ;
  graf_mkstate(&xm1, &ym1, &button, &dummy) ;
  do
  {
    graf_mkstate(&xm, &ym, &button, &dummy) ;
    if ((xm1 != xm) || (ym1 != ym))
    {
      xi1 = x1-xm1+xm ;
      yi1 = y1-ym1+ym ;
      xi2 = x2-xm1+xm ;
      yi2 = y2-ym1+ym ;
      if (xi1 < lx)
      {
        xi1 = lx ;
        xi2 = lx+w-1 ;
      }
      if (yi1 < ly)
      {
        yi1 = ly ;
        yi2 = ly+h-1 ;
      }
      if (xi2 > lx+lw-1)
      {
        xi2 = lx+lw-1 ;
        xi1 = lx+lw-1-w ;
      }
      if (yi2 > ly+lh-1)
      {
        yi2 = ly+lh-1 ;
        yi1 = ly+lh-1-h ;
      }
      v_hide_c(handle) ;
      rectangle(x1, y1, x2, y2) ;
      rectangle(xi1, yi1, xi2, yi2) ;
      v_show_c(handle, 1) ;
      x1  = xi1 ; y1  = yi1 ;
      x2  = xi2 ; y2  = yi2 ;
      xm1 = xm ;  ym1 = ym ;
    }
  }
  while (button == 1) ;
  v_hide_c(handle) ;
  rectangle(x1, y1, x2, y2) ;
  v_show_c(handle, 1) ;
  *fx = x1 ;
  *fy = y1 ;
  memcpy(&mouse, &save, sizeof(MOUSE_DEF)) ;
  set_mform(&mouse) ;
}

int file_getinfo(char *filename, DTA *info)
{
  DTA *old_dta ;
  int ret ;

  old_dta = Fgetdta() ;
  Fsetdta(info) ;
  ret = Fsfirst(filename, FA_ARCHIVE) ;
  Fsetdta(old_dta) ;

  return(ret) ;
}

long file_size(char *name)
{
  DTA  dta ;
  int  ret ;

  ret = file_getinfo( name, &dta ) ;

  if ( ret != 0 ) return( -1 ) ;

  return( dta.d_length ) ;
}

int popup_formdo(OBJECT **arbre, int x, int y, int item, int scroll)
{
  MENU pp_menu1, pp_menu2 ;
  int  w, h ;
  int  retour, resultat ;
  int  use_aespopup = AESFeatures.Popups ;

  /*
  use_aespopup = (AESVersion >= 0x330) && (cookie_find("MagX") == NULL) &&
                 (cookie_find("MgMc") == NULL) ;*/
  if ( AESFeatures.PopupsScroll == 0 ) scroll = 0 ;
  if ( use_aespopup )
  {
    pp_menu1.mn_tree   = arbre[0] ;
    pp_menu1.mn_menu   = ROOT ;
    pp_menu1.mn_item   = item ;
    pp_menu1.mn_scroll = scroll ;

    retour = menu_popup( &pp_menu1, x, y, &pp_menu2 ) ;
    if ( retour == 0 ) resultat = 0 ;
    else               resultat = pp_menu2.mn_item ;
  }
  else
  {
    if ( x + arbre[0]->ob_width > Xmax )  x = Xmax-arbre[0]->ob_width-5 ;
    if ( y + arbre[0]->ob_height > Ymax ) y = Ymax-arbre[0]->ob_height-5 ;

    arbre[0]->ob_x = x ;
    y             -= 16*(item-1) ;
    if ( y < ydesk + 3 ) y = ydesk + 3 ;
    arbre[0]->ob_y = y ;
    w              = arbre[0]->ob_width+2 ;
    h              = arbre[0]->ob_height+2 ;

    form_dial( FMD_START, x-1, y-1, w+4, h+4, x-1, y-1, w+4, h+4 ) ;
    objc_draw( arbre[0], 0, 100, x-1, y-1, w+4, h+4 ) ;
    resultat = form_do( arbre[0], 0 ) ;
    if ( resultat > 0 )
      if ( arbre[0][resultat].ob_state & DISABLED ) resultat = -1 ;
    if ( resultat > 0 )
      objc_change( arbre[0], resultat, 0, x-1, y-1, w+4, h+4, NORMAL, 1 ) ;
    form_dial( FMD_FINISH, x-1, y-1, w+4, h+4, x-1, y-1, w+4, h+4 ) ;
  }

  return( resultat ) ;
}

OBJECT *popup_make(int nb_objets, int nb_cara)
{
  OBJECT *pop_up ;
  int    i ;
	
  pop_up = (OBJECT *) Xcalloc( 1+nb_objets, sizeof(OBJECT) );
  if ( pop_up )
  {
    /* D‚finition du pŠre ([0]) */
    pop_up->ob_next                    = -1 ;
    pop_up->ob_head                    = 1 ;
    pop_up->ob_tail                    = nb_objets ;
    pop_up->ob_type                    = G_BOX ;
    pop_up->ob_flags                   = NONE ;
    pop_up->ob_state                   = SHADOWED ;
    pop_up->ob_spec.obspec.framesize   = -1 ;
    pop_up->ob_spec.obspec.framecol    = 1 ;
    pop_up->ob_spec.obspec.textcol     = 1 ;
    pop_up->ob_spec.obspec.fillpattern = 0 ;
    pop_up->ob_x                       = 0 ;
    pop_up->ob_y                       = 0 ;
    pop_up->ob_width                   = nb_cara*8 ;
    pop_up->ob_height                  = nb_objets*16 ;

	/*D‚finition du premier fils */
    pop_up[1].ob_next             = 0 ;
    pop_up[1].ob_head             = -1 ;
    pop_up[1].ob_tail             = -1 ;
    pop_up[1].ob_type             = G_STRING ;
    pop_up[1].ob_flags            = TOUCHEXIT | LASTOB ;
    pop_up[1].ob_state            = NORMAL ;
    pop_up[1].ob_spec.free_string = Xcalloc( 1+nb_cara, sizeof(char) ) ;
    pop_up[1].ob_x                = 0 ;
    pop_up[1].ob_y                = 0 ;
    pop_up[1].ob_width            = nb_cara*8 ;
    pop_up[1].ob_height           = 16 ;

	/* Definition des autres fils */
    for (i = 2; i <= nb_objets; i++)
    {
      pop_up[i-1].ob_next           = i ;
      pop_up[i].ob_next             = 0 ;
      pop_up[i].ob_head             = -1 ;
      pop_up[i].ob_tail             = -1 ;
      pop_up[i].ob_type             = G_STRING ;
      pop_up[i-1].ob_flags          = TOUCHEXIT | NONE ;
      pop_up[i].ob_flags            = TOUCHEXIT | LASTOB ;
      pop_up[i].ob_state            = NORMAL ;
      pop_up[i].ob_spec.free_string = Xcalloc( 1+nb_cara, sizeof(char) ) ;
      pop_up[i].ob_x                = 0 ;
      pop_up[i].ob_y                = (i-1)*16 ;
      pop_up[i].ob_width            = nb_cara*8 ;
      pop_up[i].ob_height           = 16 ;
    }
  }

  return pop_up ;
}

void popup_kill(OBJECT *pop_up, int nb_objets)
{
  int i ;

  if ( pop_up == NULL ) return ;

  for ( i = 1; i <= nb_objets; i++ )
    if ( pop_up[i].ob_spec.free_string ) Xfree( pop_up[i].ob_spec.free_string ) ;

  Xfree( pop_up ) ;
}

void xobjc_draw(int w_handle, OBJECT *obj, int num)
{
  int x, y, w, h ;
  int rx, ry, rw, rh ;
  int xy[4] ;
  int border = 5 ;
  int num_to_draw ;

  wind_update( BEG_UPDATE ) ;
  objc_offset( obj, num, &x, &y ) ;
  w = obj[num].ob_width ;
  h = obj[num].ob_height ;
  x -= border ;
  y -= border ;
  w += border ;
  h += border ;
  /* Si l'objet est cache, il faut redessiner le parent, son parent, etc.. En ce */
  /* Cas, il est plus simple (mais moins rapide) de redessiner depuis la racine  */
  if ( obj[num].ob_flags & HIDETREE ) num_to_draw = 0 ;
  else                                num_to_draw = num ;
  wind_get( w_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh ) ;
  while ( rw > 0 )
  {
    if ( intersect( x, y, w, h, rx, ry, rw, rh, xy ) )
      objc_draw( obj, num_to_draw, MAX_DEPTH, xy[0], xy[1], 1+xy[2]-xy[0], 1+xy[3]-xy[1] ) ;
 	  wind_get( w_handle, WF_NEXTXYWH, &rx, &ry, &rw, &rh ) ;
  }
  wind_update( END_UPDATE ) ;
}

void cls_gemscreen(void)
{
  int xy[8] ;

  vswr_mode( handle, MD_REPLACE ) ;
  form_dial( FMD_START, 0, 0, 1+Xmax, 1+Ymax, 0, 0, 1+Xmax, 1+Ymax ) ;
  vsf_perimeter( handle, 0 ) ;
  vsf_interior( handle, FIS_SOLID ) ;
  xy[0] = xy[1] = 0 ;
  xy[2] = Xmax ;
  xy[3] = Ymax ;
  v_hide_c( handle) ;
  vr_recfl( handle, xy ) ;
  v_show_c( handle, 1 ) ;
}

void restore_gemscreen(OBJECT *menu)
{
  form_dial( FMD_FINISH, 0, 0, 1+Xmax, 1+Ymax, 0, 0, 1+Xmax, 1+Ymax ) ;
  menu_bar( menu, 1 ) ;
}

unsigned int int_reverse(unsigned int nb)
{
  unsigned int  result ;
  unsigned char intel[2] ;

  intel[0] = (unsigned char) nb ;
  intel[1] = (unsigned char) (nb >> 8) ;

  memcpy(&result, intel, 2) ;
  return(result) ;  
}

unsigned long long_reverse(unsigned long nb)
{
  unsigned long result ;
  unsigned char intel[4] ;

  intel[0] = (unsigned char) nb ;
  intel[1] = (unsigned char) (nb >> 8) ;
  intel[2] = (unsigned char) (nb >> 16) ;
  intel[3] = (unsigned char) (nb >> 24) ;

  memcpy(&result, intel, 4) ;
  return(result) ;  
}

void get_time_date(char *time, char *date)
{
  unsigned int ti, di ;
  TOS_TIME     *t = (TOS_TIME *) &ti ;
  TOS_DATE     *d = (TOS_DATE *) &di ;

  di = Tgetdate() ; 
  ti = Tgettime() ; 
  sprintf( time, "%.2d:%.2d:%.2d", t->hour, t->minute, t->second * 2 ) ;
  sprintf( date, "%.2d/%.2d/%.4d", d->day, d->month, 1980 + d->year ) ;
}

void get_england_time_date(char *time, char *date)
{
  unsigned int ti, di ;
  TOS_TIME     *t = (TOS_TIME *) &ti ;
  TOS_DATE     *d = (TOS_DATE *) &di ;

  di = Tgetdate() ; 
  ti = Tgettime() ; 
  sprintf( time, "%.2d:%.2d:%.2d", t->hour, t->minute, t->second * 2 ) ;
  sprintf( date, "%.2d/%.2d/%.4d", 1980 + d->year, d->month, d->day ) ;
}

void vro_cpyfmtc16(int *xy, MFDB *in, MFDB *out)
{
  long size ;
  int  *s, *d ;
  int  s_add, d_add ;
  int  l ;

  if ((in->fd_nplanes != 16) || (out->fd_nplanes != 16)) return ;

  s_add = in->fd_wdwidth << 4 ;
  d_add = out->fd_wdwidth << 4 ;
  s     = (int *)in->fd_addr ;
  s    += (long)s_add*(long)xy[1] ;
  s    += xy[0] ;
  d     = (int *)out->fd_addr ;
  d    += (long)d_add*(long)xy[5] ;
  d    += xy[4] ;
  size  = (1+xy[2]-xy[0]) << 1 ;
  for (l = xy[1]; l <= xy[3]; l++)
  {
    memcpy(d, s, size) ;
    s += s_add ;
    d += d_add ;
  }
}

void vro_cpyfmtc24(int *xy, MFDB *in, MFDB *out)
{
  long          size ;
  unsigned char *s, *d ;
  long          s_add, d_add ;
  int           l ;

  if ((in->fd_nplanes != 24) || (out->fd_nplanes != 24)) return ;

  s_add = (in->fd_wdwidth << 4) * 3 ;
  d_add = (out->fd_wdwidth << 4) * 3 ;
  s     = (unsigned char *)in->fd_addr ;
  s    += s_add*(long)xy[1] ;
  s    += xy[0]*3 ;
  d     = (unsigned char *)out->fd_addr ;
  d    += d_add*(long)xy[5] ;
  d    += xy[4]*3 ;
  size  = (1+xy[2]-xy[0]) * 3 ;
  for ( l = xy[1]; l <= xy[3]; l++ )
  {
    memcpy(d, s, size) ;
    s += s_add ;
    d += d_add ;
  }
}

void xvro_cpyfm(int handle, int vr_mode, int *xy, MFDB *src, MFDB *dest)
{
  if ( ( src->fd_nplanes == 16 ) && ( src->fd_nplanes != nb_plane ) )
    vro_cpyfmtc16( xy, src, dest ) ;
  else
    vro_cpyfm( handle, vr_mode, xy, src, dest ) ;
}

int *cycling_init(void)
{
  int *save_pal ;

  save_pal = (int *) Xalloc( 3 * nb_colors * sizeof(int) ) ;
  if ( save_pal == NULL ) return( NULL ) ;

  get_vdipalette( save_pal ) ;
  if ( ( MachineInfo.machine == 0x00010100L ) || ( MachineInfo.machine >= 0x00030000L ) ) /* FALCON ou mieux ! */
    adr_palette = 0xFF9800L ;
  else
    if ( MachineInfo.machine == 0x00030000L ) /* TT */
      adr_palette = 0xFF8400L ;
    else
      adr_palette = 0xFF8240L ; /* ST, STE */

  return( save_pal ) ;
}

void cycling_do(int sens)
{
  long cycling_ustack ;

  /* Passe en mode Superviseur pour acc‚der aux registres palettes */
  if ( ( MachineInfo.machine != 0x00010100L ) && ( MachineInfo.machine < 0x00030000L ) )
    sens |= 0x02 ; /* Palette en Words */
  cycling_ustack = Super( NULL ) ;
  cycling_ado( sens ) ;
  Super( (void*) cycling_ustack ) ;
}

void cycling_terminate(int *save_pal)
{
  set_vdipalette( save_pal, nb_colors ) ;
  if ( save_pal ) Xfree( save_pal ) ;
}

int can_usevro(int nb_planes)
{
  int can_use = 1 ;

  if ( nb_planes != nb_plane ) can_use = 0 ;

  return( can_use ) ;
}

int xobjc_hasflag(OBJECT *tree, int index, int flag)
{
  if ( tree[index].ob_state & DISABLED ) return( 0 ) ;

  if ( tree[index].ob_flags & flag ) return( 1 ) ;

  return( 0 ) ;
}

OBJECT *xobjc_copy(OBJECT *tree)
{ /* Par Eric REBOUX */
	register char *d, *s;
	register int i;
	register long size = 0, strsize = 0;
	register OBJECT *obj = tree, *new;
	USERBLK *ublk;
	TEDINFO *nted;
	register TEDINFO *ted;

	for (;;)
	{
		size += sizeof (OBJECT);
		switch ((unsigned char)obj->ob_type)
		{
			case G_TEXT:
			case G_FTEXT:
			case G_BOXTEXT:
			case G_FBOXTEXT:
				ted = obj->ob_spec.tedinfo;
				strsize += sizeof (TEDINFO);
				if ((obj->ob_type >> 8) == 32)		/* ‚ditable ‚tendu */
					strsize += ted->te_txtlen * 3 + ted->te_tmplen + 6;
				else
					strsize += ted->te_txtlen * 2 + ted->te_tmplen + 4;
				strsize &= ~1;
			break;
			case G_USERDEF:
				if ((obj->ob_type != G_USERDEF) && (obj->ob_spec.userblk->ub_parm))
					strsize += strlen ((char *)obj->ob_spec.userblk->ub_parm) + sizeof (USERBLK) + 2;
				else
					strsize += sizeof (USERBLK) + 1;
				strsize &= ~1;
			break;
			case G_STRING:
			case G_TITLE:
			case G_BUTTON:
				strsize += strlen (obj->ob_spec.free_string) + 2;
				strsize &= ~1;
			break;
		}
		if (obj->ob_flags & LASTOB)
			break;
		obj ++;
	}

	if ((new = (OBJECT *) Xalloc(size + strsize)) != 0)
	{
		memset (new, 0, size + strsize);

		for (memcpy (obj = new, tree, size), nted = (TEDINFO *) (((char *) new) + size);;)
		{
			switch ((unsigned char)obj->ob_type)
			{
				case G_TEXT:
				case G_FTEXT:
				case G_BOXTEXT:
				case G_FBOXTEXT:
					ted = obj->ob_spec.tedinfo;
					obj->ob_spec.tedinfo = nted;
					*nted = *ted;
					nted->te_ptext = d = (char *)&nted[1];
					if ((obj->ob_type >> 8) == 32)		/* ‚ditable ‚tendu */
						for (s = ted->te_ptext, i = (ted->te_txtlen << 1) + 3; -- i >= 0; *d ++ = *s ++);
					else
						for (s = ted->te_ptext, i = ted->te_txtlen; -- i >= 0; *d ++ = *s ++);
					nted->te_ptmplt = d;
					for (s = ted->te_ptmplt, i = ted->te_tmplen; -- i >= 0; *d ++ = *s ++);
					nted->te_pvalid = d;
					for (s = ted->te_pvalid, i = ted->te_txtlen; -- i >= 0; *d ++ = *s ++);
					nted = (TEDINFO *)((long)(d + 1) & ~1);
				break;
				case G_USERDEF:
					ublk = obj->ob_spec.userblk;
					*(USERBLK *)nted = *ublk;
					obj->ob_spec.userblk = (USERBLK *)nted;
					if ((obj->ob_type != G_USERDEF) && (obj->ob_spec.userblk->ub_parm))
					{
						(char *)obj->ob_spec.userblk->ub_parm = d = strcpy ((char *)nted + sizeof (USERBLK), (char *)ublk->ub_parm);
						nted = (TEDINFO *)((long)(d + strlen (d) + 2) & ~1);
					}
					else
					{
						d = (char *)nted + sizeof (USERBLK);
						nted = (TEDINFO *)((long)(d + 1) & ~1);
					}
				break;
				case G_STRING:
				case G_TITLE:
				case G_BUTTON:
					obj->ob_spec.free_string = d = strcpy ((char *)nted, obj->ob_spec.free_string);
					nted = (TEDINFO *)((long)(d + strlen (d) + 2) & ~1);
			}
			if (obj->ob_flags & LASTOB)
				break;
			obj ++;
		}
	}

	return (new);
}

void Xrsrc_fix(OBJECT *obj)
{
  int index ;

  for( index = 0; (obj[index].ob_flags & LASTOB) == 0; index++ ) Xrsrc_obfix( obj, index ) ;

  Xrsrc_obfix( obj, index ) ;
}

int Icon2MFDB(ICONBLK *icn, MFDB *out)
{
  MFDB icn_mfdb ;
  int  nplanes = out->fd_nplanes ;
  int  err = 0 ;

  memset( &icn_mfdb, 0, sizeof(MFDB) ) ;
  icn_mfdb.fd_addr = icn->ib_pdata ;
  icn_mfdb.fd_w    = icn->ib_wicon ;
  icn_mfdb.fd_h    = icn->ib_hicon ;
  icn_mfdb.fd_wdwidth = icn_mfdb.fd_w / 16 ;
  if ( icn_mfdb.fd_w % 16 ) icn_mfdb.fd_wdwidth++ ;
  icn_mfdb.fd_nplanes = 1 ;
  out->fd_addr = NULL ;
  err = raster_duplicate( &icn_mfdb, out ) ;
  if ( !err && ( nplanes != out->fd_nplanes ) ) err = incnbplanes( out, nplanes ) ;

  return( err ) ;
}

int Cicon2MFDB(CICONBLK *icnblk, MFDB *out)
{
  CICON *icn, *best_icn ;
  MFDB  icn_mfdb ;
  int   nplanes = out->fd_nplanes ;
  int   err = 0 ;

  if ( nplanes == 1 ) return( Icon2MFDB( &icnblk->monoblk, out ) ) ;
  else
  {
    /* Recherche la resolution courante ou la meilleure */
    icn      = icnblk->mainlist ;
    best_icn = NULL ;
    while ( icn && ( icn->num_planes <= nplanes ) )
    {
      best_icn = icn ;
      icn      = icn->next_res ;
    }
    if ( best_icn ) icn = best_icn ;
    else            err = -1 ;
  }

  if ( !err )
  {
    memset( &icn_mfdb, 0, sizeof(MFDB) ) ;
    icn_mfdb.fd_addr = icn->col_data ;
    icn_mfdb.fd_w    = icnblk->monoblk.ib_wicon ;
    icn_mfdb.fd_h    = icnblk->monoblk.ib_hicon ;
    icn_mfdb.fd_wdwidth = icn_mfdb.fd_w / 16 ;
    if ( icn_mfdb.fd_w % 16 ) icn_mfdb.fd_wdwidth++ ;
    icn_mfdb.fd_nplanes = icn->num_planes ;
    out->fd_addr = NULL ;
    err = raster_duplicate( &icn_mfdb, out ) ;
    if ( !err && ( nplanes != out->fd_nplanes ) ) err = incnbplanes( out, nplanes ) ;
  }

  return( err ) ;
}
