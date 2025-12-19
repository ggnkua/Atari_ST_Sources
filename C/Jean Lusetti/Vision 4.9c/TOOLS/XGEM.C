/******************************************/
/*--------------- XGEM.C -----------------*/
/* Quelques fonctions qui ‚tendent le GEM */
/******************************************/
#include     <time.h>
#include    <stdio.h>
#include   <string.h>
#include   <stdlib.h>

#include   "..\tools\crc.h"
#include   "..\tools\xrsrc.h"
#include   "..\tools\xgem.h"
#include "..\tools\cookies.h"
#include "..\tools\rasterop.h"
#include "..\tools\logging.h"
#include "..\tools\xfile.h"
#include "..\tools\execv.h"

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
RVB_ORG FRVBOrg24 = {  0, 1, 2, 0 } ; /* Output from image_io drivers (24b)*/  
RVB_ORG FRVBOrg32 = {  0, 1, 2, 0 } ; /* Output from image_io drivers (32b)*/  


char init_path[PATH_MAX] ;                  /* R‚pertoire de lancement            */
char tmp_path[PATH_MAX] ;                  /* R‚pertoire de lancement            */

void cycling_ado(int sens, int nplanes) ;
long adr_palette ;                 /* Adresse palette de couleurs        */

unsigned char vdi2tos1[2] ;
unsigned char tos2vdi1[2] ;
unsigned char vdi2tos2[4] ;
unsigned char tos2vdi2[4] ;
unsigned char vdi2tos4[16] ;
unsigned char tos2vdi4[16] ;
unsigned char vdi2tos8[256] ;
unsigned char tos2vdi8[256] ;
int*          old_pal ;

/* MagiC specifique */
MAGX_COOKIE* MagXCookie = NULL ;

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

LOCAL WORD bidon_global[15] ;
char rsrcAES = -1 ; /* choix du mode d'affichage des ressources suivant le systŠme -1 pas encore choisi, 1 rsrc_load systeme, 0 xrsrc */
char form_mode = 0 ; /* form_... silent is non zero */

char* pkbshift ; /* Faster replacement for Kbshift() call (from Guillaume Tello/Olivier Landemarre) */

#ifndef __NO_XRSRC
int Xrsrc_load(char* rsc_name, int rsrc_choice)
{
  if ( rsrc_choice == -1 )
  {
  	if ( (AESVersion >= 0x0400) || (appl_find("?AGI\0\0\0\0") >= 0) )
  	{
      WORD ret, a1, a2, a3=0, a4=0 ;

  		ret = appl_getinfo( 2, &a1, &a2, &a3, &a4 ) ;
      LoggingDo(LL_DEBUG, "appl_getinfo ret=%d, a3=%d, a4=%d, SVersion:%x", ret, a3, a4, Sversion()) ;
  		if ( ret && a3 && a4&1 ) rsrcAES = 1 ; /* AES will load resource file */
  		else                     rsrcAES = 0 ; /* Interface routines (xrsrc.c) will load resource file */
  	}
  	else rsrcAES = 0 ;
  }
  else rsrcAES = rsrc_choice ;

  LoggingDo(LL_INFO, "Xrsrc_load: using %srsrc_load", (rsrcAES == 1) ? "":"x") ;
  if ( rsrcAES == 1 ) return rsrc_load( rsc_name ) ;
  else                return xrsrc_load( rsc_name, bidon_global/*_GemParBlk.global*/ ) ;
}

int Xrsrc_gaddr(int re_gtype, int re_gindex, void* gaddr)
{
  if ( rsrcAES == 1 ) return rsrc_gaddr( re_gtype, re_gindex, gaddr ) ;
  return( xrsrc_gaddr( re_gtype, re_gindex, gaddr, bidon_global/*_GemParBlk.global*/ ) ) ;
}

int Xrsrc_free(void)
{
  if ( rsrcAES == 1 ) return rsrc_free() ;
  return( xrsrc_free( bidon_global/*_GemParBlk.global*/ ) ) ;
}

int Xrsrc_obfix(OBJECT* re_otree, WORD re_oobject)
{
  if ( rsrcAES == 1 ) return rsrc_obfix( re_otree, re_oobject ) ;
  return( xrsrc_obfix( re_otree, re_oobject ) ) ;
}
#else
#pragma warn -par
int Xrsrc_load(char* rsc_name, int rsrc_choice)
{
  rsrcAES = 1 ;
  LoggingDo(LL_INFO, "Xrsrc_load: using %srsrc_load", (rsrcAES == 1) ? "":"x") ;
  return rsrc_load( rsc_name ) ;
}
#pragma warn +par

int Xrsrc_gaddr(int re_gtype, int re_gindex, void* gaddr)
{
  return rsrc_gaddr( re_gtype, re_gindex, gaddr ) ;
}

int Xrsrc_free(void)
{
  return rsrc_free() ;
}

int Xrsrc_obfix(OBJECT* re_otree, WORD re_oobject)
{
  return rsrc_obfix( re_otree, re_oobject ) ;
}
#endif

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

  return nplanes ;
}

unsigned char* get_pttos2vdi(int nplanes)
{
  switch( nplanes )
  {
    case 1  : return tos2vdi1 ;
    case 2  : return tos2vdi2 ;
    case 4  : return tos2vdi4 ;
    case 8  : return tos2vdi8 ;
    default : return NULL ;
  }
}

unsigned char* get_ptvdi2tos(int nplanes)
{
  switch( nplanes )
  {
    case 1  : return vdi2tos1 ;
    case 2  : return vdi2tos2 ;
    case 4  : return vdi2tos4 ;
    case 8  : return vdi2tos8 ;
    default : return NULL ;
  }
}

void set_tospalette(int* pal, int nb_col)
{
  int           i, *pt_pal ;
  unsigned char *tos2vdi ;

  if ( pal == NULL )
  {
    /* Restore original palette */
    pal    = old_pal ;
    nb_col = nb_colors ;
  }

  tos2vdi = get_pttos2vdi(nb_planes(nb_col)) ;
  if ( tos2vdi == NULL ) return ;
  pt_pal = pal ;
  for (i = 0; i < nb_col; i++)
  {
    svs_color( tos2vdi[i], pt_pal ) ;
    pt_pal += 3 ; /* 3 niveaux (RVB) */
  }
}

void set_stospalette(int* pal, int nb_col, int start)
{
  int            i, *pt_pal ;
  unsigned char* tos2vdi ;

  tos2vdi = get_pttos2vdi(screen.fd_nplanes) ;
  if ( tos2vdi == NULL ) return ;
  pt_pal  = pal+3*start ;
  for (i = 0; i < nb_col; i++)
  {
    svs_color( tos2vdi[start+i], pt_pal) ;
    pt_pal += 3 ; /* 3 niveaux (RVB) */
  }
}

void get_tospalette(int* pal)
{
  int            i, *pt_pal ;
  unsigned char* tos2vdi ;

  tos2vdi = get_pttos2vdi( screen.fd_nplanes ) ;
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
      svq_color( tos2vdi[i], 0, pt_pal ) ;
      pt_pal += 3 ;
    }
  }
}

void get_vdipalette(int* pal)
{
  int i, *pt_pal ;

  pt_pal = pal ;
  for (i = 0; i < nb_colors; i++)
  {
    svq_color( i, 0, pt_pal ) ;
    pt_pal += 3 ;
  }
}

void set_vdipalette(int* pal, int nb_col)
{
  int i, *pt_pal ;

  pt_pal = pal ;
  for (i = 0; i < nb_col; i++)
  {
    svs_color( i, pt_pal) ;
    pt_pal += 3 ; /* 3 niveaux (RVB) */
  }
}

void CopyMouseDef(MOUSE_DEF* out, MOUSE_DEF* in)
{
  memcpy( out, in, sizeof(MOUSE_DEF) ) ;
}

void CopyMForm(MFORM* out, MFORM* in)
{
  memcpy( out, in, sizeof(MFORM) ) ;
}

int set_mform(MOUSE_DEF* info)
{
  static MOUSE_DEF cminfo ;

  if ( memcmp( &cminfo, info, sizeof(MOUSE_DEF) ) != 0 )
  {
    if ( info->gr_monumber != USER_DEF ) graf_mouse( info->gr_monumber, NULL ) ;
    else                                 graf_mouse( info->gr_monumber, &info->gr_mof ) ;
    mouse.gr_monumber = info->gr_monumber ;
    CopyMForm( &mouse.gr_mof, &info->gr_mof ) ;

    CopyMouseDef( &cminfo, info ) ;
  }
  
  return info->gr_monumber ;
}

void mouse_busy(void)
{
  CopyMouseDef( &msave, &mouse ) ;
  mouse.gr_monumber = BUSYBEE ;
  set_mform( &mouse ) ;
}

void mouse_restore(void)
{
  set_mform( &msave ) ;
}

void remove_accents(char* string)
{
  char* pt ;

  pt = string ;
  while ( *pt != 0 )
  {
    switch( *pt )
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

char form_set_mode(char silent)
{
  char prev_mode = form_mode ;

  form_mode = silent ;

  return prev_mode ;
}

static int form_sign(int default_return, int sign_no, char* string)
{
  MOUSE_DEF save ;
  char      temp[200] ;
  int       ret ;

  CopyMouseDef( &save, &mouse ) ;
  mouse.gr_monumber = ARROW ;
  set_mform( &mouse ) ;
  sprintf( temp, "[%d]%s", sign_no, string ) ;
  GWShowCursor() ;
  if ( form_mode && (sign_no != 2) )
  {
    /* If silent mode and user has no choice on feedback */
    LoggingDo(LL_INFO, "This form has been silenced:%s", temp ) ;
    ret = default_return ;
  }
  else ret = form_alert( default_return, temp ) ;
  set_mform( &save ) ;

  return ret ;
}

int form_exclamation(char* string)
{
  return form_sign( 1, 1, string ) ;
}

int form_interrogation(int default_return, char* string)
{
  return form_sign( default_return, 2, string ) ;
}

int form_stop(char* string)
{
  return form_sign( 1, 3, string ) ;
}

static void remove_double_aslash(char* string)
{
  char* pin = string ;
  char* pout = string ;
  int   n_aslash ;

  while ( *pin )
  {
    n_aslash = 0 ;
    while ( *pin == '\\' ) { pin++ ; n_aslash++ ; }
    if ( n_aslash ) *pout++ = '\\' ;
    if ( *pin ) *pout++ = *pin++ ;
  }
  *pout = 0 ;
}

int filefolder_name(char* masque, char* def, int want_folder, char* name)
{
  char path[PATH_MAX], fnam[PATH_MAX] ;
  int  ret, button = 0 ;

  strcpy( path, masque ) ;
  /* Remove annoying double \ in case of X:\\*.* */
  remove_double_aslash( path ) ;
  if ( def ) strcpy( fnam, def ) ;
  else       fnam[0] = 0 ;

  LoggingDo(LL_DEBUG, "fsel_input(%s) for %s, %s", want_folder ? "folder":"file", path, fnam) ;
  ret = fsel_input( path, fnam, &button ) ;
  if ( ret && (button == 1) )
  {
    char* last_aslash = strrchr( path, '\\' ) ;

    if ( last_aslash ) *last_aslash = 0 ;
    LoggingDo(LL_DEBUG, "fsel_input returns %s, %s", path, fnam) ;
    if ( want_folder ) strcpy( name, path) ;
    else               sprintf( name, "%s\\%s", path, fnam ) ;
    LoggingDo(LL_DEBUG, "fsel_input user selected %s", name) ;
  }

  return button ;
}

void pset(int x, int y)
{
  int xyarray[2] ;

  xyarray[0] = x ;
  xyarray[1] = y ;
  v_pmarker( handle, 1, xyarray ) ;
}

void line(int x1, int y1, int x2, int y2)
{
  int xyarray[4] ;
  int* pt = xyarray ;

  *pt++ = x1 ; *pt++ = y1 ;
  *pt++ = x2 ; *pt++ = y2 ;
  sv_pline( 2, xyarray ) ;
}

void rectangle(int x1, int y1, int x2, int y2)
{
  int  xyarray[10] ;
  int* pt = xyarray ;

  *pt++ = x1 ; *pt++ = y1 ;
  *pt++ = x2 ; *pt++ = y1 ;
  *pt++ = x2 ; *pt++ = y2 ;
  *pt++ = x1 ; *pt++ = y2 ;
  *pt++ = x1 ; *pt++ = y1 ;

  sv_pline( 5, xyarray ) ;
}

void get_linetype(LINE_TYPE* type)
{
  int att[6] ;
  
  vql_attributes( handle, att ) ;
  type->style   = att[0] ;
  type->color   = att[1] ;
  type->st_kind = att[3] ;
  type->ed_kind = att[4] ;
  type->width   = att[5] ;
}

void get_markertype(MARKER_TYPE* type)
{
  int att[5] ;
  
  vqm_attributes( handle, att ) ;
  type->style  = att[0] ;
  type->color  = att[1] ;
  type->height = att[4] ;
}

void get_filltype(FILL_TYPE* type)
{
  int att[5] ;
  
  vqf_attributes( handle, att ) ;
  type->style     = att[0] ;
  type->color     = att[1] ;
  type->sindex    = att[2] ;
  type->perimeter = att[4] ;
}

void get_texttype(TEXT_TYPE* type)
{
  int att[10] ;
  
  vqt_attributes( handle, att ) ;
  type->wcar  = att[6] ;
  type->hcar  = att[7] ;
  type->wcell = att[8] ;
  type->hcell = att[9] ;
  type->angle = att[2] ;
  type->font  = att[0] ;
  type->color = att[1] ;
  type->hdisp = att[3] ;
  type->vdisp = att[4] ;
}

void set_linetype(LINE_TYPE* type)
{
  svsl_type( type->style ) ;
  (void)svsl_color( type->color ) ;
  svsl_ends( type->st_kind, type->ed_kind ) ;
  type->width = svsl_width( type->width ) ;
}

void set_markertype(MARKER_TYPE* type)
{
  vsm_type( handle, type->style ) ;
  vsm_color( handle, type->color ) ;
  type->height = vsm_height( handle, type->height ) ;
}

void set_filltype(FILL_TYPE* type)
{
  svsf_interior( type->style ) ;
  svsf_color( type->color ) ;
  vsf_style( handle, type->sindex ) ;
  svsf_perimeter( type->perimeter ) ;
}

void set_texttype(TEXT_TYPE* type)
{
  int  font_index ;
  int  dummy ;
  char font_name[33] ;
  char outline_font ;

  if ( Gdos )
  {
    font_name[32] = 0 ;
    font_index    = vqt_name( handle, type->font, font_name ) ;
    outline_font  = font_name[32] ;
    vst_font( handle, font_index ) ;
    if ( outline_font ) vst_arbpt( handle, type->hcar, &type->wcar, &dummy, &type->wcell, &type->hcell ) ;
    else                vst_height( handle, type->hcar, &type->wcar, &dummy, &type->wcell, &type->hcell ) ;
  }
  else vst_height( handle, type->hcar, &type->wcar, &dummy, &type->wcell, &type->hcell ) ;
  type->angle     = vst_rotation( handle, type->angle ) ;
  type->color     = vst_color( handle, type->color ) ;
  type->attribute = vst_effects( handle, type->attribute ) ;
  svst_alignment( type->hdisp, type->vdisp, &type->hdisp, &type->vdisp ) ;
}

int intersect(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2, int* pxyarray)
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

  return( (w > x) && (h > y) ) ;
}

int selected(OBJECT* arbre, int index)
{
  return( arbre[index].ob_state & SELECTED ) ;
}

void select(OBJECT* arbre, int index)
{
  arbre[index].ob_state |= SELECTED ;
}

void deselect(OBJECT* arbre, int index)
{
  if ( index >= 0 ) arbre[index].ob_state &= ~SELECTED ;
}

void inv_select(OBJECT* arbre, int index)
{
  if ( index >= 0 )
  {
    if ( selected(arbre, index) ) deselect( arbre, index ) ;
    else                          select( arbre, index ) ;
    (void)objc_draw( arbre, index, 0, 0, 0 , wdesk, hdesk ) ;
  }
}

void inv_select_ifsel(OBJECT* arbre, int index)
{
  if ( selected(arbre, index) ) inv_select( arbre, index ) ;
}

void object_flag(OBJECT* arbre, int index, unsigned int flag)
{
  arbre[index].ob_flags = flag ;
}

void view_object(OBJECT* arbre, int index)
{
  arbre[index].ob_flags &= ~HIDETREE ;
}

void hide_object(OBJECT* arbre, int index)
{
  arbre[index].ob_flags |= HIDETREE ;
}

void read_text(OBJECT* arbre, int index, char* string)
{
  TEDINFO* ted ;

  ted = (TEDINFO*) arbre[index].ob_spec.tedinfo ;
  strcpy( string, ted->te_ptext ) ;
}

char* reduce_string_if_required(char* string, char* buffer, size_t dst_len)
{
  size_t string_len = strlen(string) ;
  char*  new_string = string ;

  /* Assuming buffer is len long at least */
  if ( (string_len > dst_len) && (dst_len > 5) && (string_len - dst_len > 3) )
  {
    size_t nchars_to_copy_per_side = (dst_len-3) >> 1 ;

    /* Let's build a 'best shown' string in buffer */
    /* e.g.: d:\images\samples\TIFF\aprettylongfilename.tif (46 bytes) */
    /*       d:\images\samples...tylongfilename.tif         (38 bytes) */
    buffer[dst_len-1] = 0 ;
    memcpy( buffer, string, nchars_to_copy_per_side ) ;
    buffer[nchars_to_copy_per_side]   = '.' ;
    buffer[nchars_to_copy_per_side+1] = '.' ;
    buffer[nchars_to_copy_per_side+2] = '.' ;
    memcpy( &buffer[nchars_to_copy_per_side+3], string+string_len-nchars_to_copy_per_side, nchars_to_copy_per_side ) ;
    new_string = buffer ;
  }

  return new_string ;
}

void write_text(OBJECT* arbre, int index, char* string)
{
  char   buffer[PATH_MAX] ;
  char*  dst ;
  size_t len ;
  int    show_best = 0 ;

  if ( !arbre || !string ) return ;

  if ( index < 0 )
  {
    /* If index < 0, we want string to show as better as possible in object */
    /* e.g. display filename with start/end not truncated in the middle     */
    index     = -index ;
    show_best = 1 ;
  }

  if ( arbre[index].ob_type == G_BUTTON )
  {
    dst = arbre[index].ob_spec.free_string ;
    len = strlen(dst) ;
  }
  else
  {
    TEDINFO* ted = (TEDINFO*) arbre[index].ob_spec.tedinfo ;

    dst = ted->te_ptext ;
    len = ted->te_txtlen-1 ;
  }

  if ( show_best ) string = reduce_string_if_required( string, buffer, len ) ;

  strncpy( dst, string, len ) ;
}

void write_template(OBJECT* arbre, int index, char* string)
{
  TEDINFO* ted ;

  ted = (TEDINFO*) arbre[index].ob_spec.tedinfo ;
  strcpy( ted->te_ptmplt, string ) ;
}

void set_ext(char* name, char* ext)
{
  char* pt ;
  char  pext[5] ;

  pt = name ;
  while ( (*pt !=0) && (*pt != '.') ) pt++ ;
  if ( *pt == 0 )
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

int get_ext(char* name, char* ext)
{
  char* slash ;
  char* point ;

  ext[0] = 0 ;
  slash = strrchr( name, '\\' ) ;
  if ( slash == NULL ) point = strrchr( name, '.' ) ;
  else                 point = strrchr( 1+slash, '.' ) ;
  if ( ( point == NULL ) || ( point[1] == 0 ) ) return 0 ;
  
  strcpy( ext, 1+point ) ;

  return 1 ;
}

void wait_for(int mask_event)
{
  EVENT evnt ;

  memzero( &evnt, sizeof(evnt) ) ;
  evnt.ev_mflags    = mask_event | MU_TIMER ;
  if ( mask_event ) evnt.ev_mtlocount = 1 ;
  else              { evnt.ev_mtlocount = 300 ; mask_event = MU_TIMER ; } /* If no event is passed, wait 300ms */
  evnt.ev_mbclicks  = 258 ;
  evnt.ev_bmask     = 3 ;
  while ( (EvntMulti(&evnt) & mask_event) == 0 ) ;
}

void clear_buffers(int mask_event)
{
  EVENT evnt ;

  memzero( &evnt, sizeof(evnt) ) ;
  evnt.ev_mflags    = mask_event | MU_TIMER ;
  evnt.ev_mtlocount = 50 ;
  evnt.ev_mbclicks  = 1 ;
  evnt.ev_bmask     = 1 ;
  evnt.ev_mbstate   = 1 ;
  while ( EvntMulti( &evnt ) != MU_TIMER ) ;
}

int GetMagicVersion(void)
{
  if ( MagXCookie ) return MagXCookie->aesvars->version ;
  else              return 0 ;
}

long get_fpu(void)
{
  long  fpu_type = TFPU_NONE ;
  short type = (short) (MachineInfo.fpu >> 16) ;

  if ( type & 0x07 ) fpu_type = TFPU_68881 ; /* If bit 0, 1 or 2 is set, assume 68881 */
  if ( (type & 0x06) == 0x06 ) fpu_type = TFPU_68882 ;
  if ( type & 0x08 ) fpu_type = TFPU_68040 ;
  if ( type & 0x10 ) fpu_type = TFPU_68060 ;

  return fpu_type ;
}

static long get_cookie_data(char ident[4])
{
  COOKIE* cookie = cookie_find( ident ) ;

  if ( cookie ) return cookie->data ;

  return 0L ;
}

void get_machineinformation(void)
{
  memzero( &MachineInfo, sizeof(MachineInfo) ) ;

  MachineInfo.machine = get_cookie_data( "_MCH" ) ;
  MachineInfo.cpu     = get_cookie_data( "_CPU" ) ;
  MachineInfo.fpu     = get_cookie_data( "_FPU" ) ;
  MachineInfo.video   = get_cookie_data( "_VDO" ) ;
  MachineInfo.sound   = get_cookie_data( "_SND" ) ;
  MagXCookie          = (MAGX_COOKIE*) get_cookie_data( "MagX" ) ;
}

#ifdef B1_mono
/* Means we included tstscr.h from Guillaume Tello */
static void GTScreenOrg(int *glob, int handle, long DirectAccess)
{
	long code, bpp, type;

	code=ScreenEncoding(glob, handle, DirectAccess);
	type=code & 0xFFFF;	/* low word */
	if(type & errorbit)
		{LoggingDo(LL_INFO,"VDI error, direct access was required") ;
		 type = type & errorclear;
		 }
	else
		LoggingDo(LL_INFO,"VDI Ok");

		
	bpp=(code>>16) & 0xFFFF;		/* high word */
	code = code & errorclear;
	if(bpp & errorbit)
		{LoggingDo(LL_INFO,"Unknown screen encoding...");
		 bpp = bpp & errorclear;
		 }
	else
		{
		LoggingDo(LL_INFO,"Bits/pixel %ld Sub type %ld",bpp,type);
		if(code == B1_mono) LoggingDo(LL_INFO,"Monochrome");
		if(code == B2_inter) LoggingDo(LL_INFO,"4 colors, interlaced planes");
		if(code == B2_ninter) LoggingDo(LL_INFO,"4 colors, planes");
		if(code == B4_inter) LoggingDo(LL_INFO,"16 colors, interlaced planes");
		if(code == B4_ninter) LoggingDo(LL_INFO,"16 colors, planes");
		if(code == B4_packed) LoggingDo(LL_INFO,"16 colors, packed pixels");
		if(code == B8_inter) LoggingDo(LL_INFO,"256 colors, interlaced planes");
		if(code == B8_ninter) LoggingDo(LL_INFO,"256 colors, planes");
		if(code == B8_packed) LoggingDo(LL_INFO,"256 colors, one byte per pixel");
		if(code == B8_packedM) LoggingDo(LL_INFO,"256 colors, one byte per pixel (Matrix)");
		if(code == B16_motor) LoggingDo(LL_INFO,"High Color rrrrrggg gggbbbbb");
		if(code == B16_intel) LoggingDo(LL_INFO,"High Color gggbbbbb rrrrrggg");
		if(code == B15_motor) LoggingDo(LL_INFO,"High Color xrrrrrgg gggbbbbb");
		if(code == B15_intel) LoggingDo(LL_INFO,"High Color gggbbbbb xrrrrrgg");
		if(code == B24_rgb) LoggingDo(LL_INFO,"True Color RGB");
		if(code == B24_bgr) LoggingDo(LL_INFO,"True Color BGR");
		if(code == B32_xrgb) LoggingDo(LL_INFO,"True Color xRGB");
		if(code == B32_xbgr) LoggingDo(LL_INFO,"True Color xBGR");
		if(code == B32_bgrx) LoggingDo(LL_INFO,"True Color BGRx");
		if(code == B32_rgbx) LoggingDo(LL_INFO,"True Color RGBx");
		}
 }
#endif

static void init_index_tosvdi(void)
{
  /* Checked OK */
  unsigned char vt2[] = { 1, 3,                    2, 1, 3, 2 } ;
  unsigned char vt4[] = { 1, 15,                   2, 1, 3, 2, 5, 6, 6, 3, 7, 5, 8, 7, 9, 8, 10, 9, 11, 10, 13, 14, 14, 11, 15, 13 } ;
  unsigned char vt8[] = { 1, 255, 15, 13, 255, 15, 2, 1, 3, 2, 5, 6, 6, 3, 7, 5, 8, 7, 9, 8, 10, 9, 11, 10, 13, 14, 14, 11 } ;
  int           j ;

  for ( j = 0; j < 2; j++ )   vdi2tos1[j] = tos2vdi1[j] = j ;
  for ( j = 0; j < 4; j++ )   vdi2tos2[j] = tos2vdi2[j] = j ;
  for ( j = 0; j < 16; j++ )  vdi2tos4[j] = tos2vdi4[j] = j ;
  for ( j = 0; j < 256; j++ ) vdi2tos8[j] = tos2vdi8[j] = j ;

  for ( j = 0; j < ARRAY_SIZE(vt2); j += 2 )
  {
    vdi2tos2[vt2[j]]   = vt2[j+1] ;
    tos2vdi2[vt2[j+1]] = vt2[j] ;
  }

  for ( j = 0; j < ARRAY_SIZE(vt4); j += 2 )
  {
    vdi2tos4[vt4[j]]   = vt4[j+1] ;
    tos2vdi4[vt4[j+1]] = vt4[j] ;
  }

  for ( j = 0; j < ARRAY_SIZE(vt8); j += 2 )
  {
    vdi2tos8[vt8[j]]   = vt8[j+1] ;
    tos2vdi8[vt8[j+1]] = vt8[j] ;
  }

/*
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
  tos2vdi8[10]  = 11 ; tos2vdi8[14] = 13 ; tos2vdi8[11] = 14 ;*/
}

int gem_init(void)
{
  SYSHDR* syshdr ;
  long    stack ;
  int     wbox, hbox ;
  int     work_in[16], work_out[57] ;
  int     out[57] ;
  int     smenus, popups, popscroll, mnsel ;
  int     i, is_falcon = 0 ;
  
  ap_id = appl_init() ;
  if ( ap_id < 0 ) return ap_id ;

  stack    = Super(NULL) ;
  syshdr   = *(SYSHDR**) 0x4F2 ;
  pkbshift = (char*) syshdr->kbshift ;
/*  val_kbshift = (unsigned char**) ( (*(unsigned long *)0x4F2 ) + 0x24L ) ;*/
  Super((void*)stack) ;
  LoggingDo(LL_DEBUG, "kbshift=$%p",pkbshift);
  get_machineinformation() ;
  if ( MachineInfo.cpu >= 30L ) i2r_use030 = 1 ;
  else                          i2r_use030 = 0 ;

  if ( (MachineInfo.machine == 0x00010100L) || (MachineInfo.machine == 0x00030000L) ) /* FALCON ! */
  {
    DspInfo.type             = DSP_56001 ;
    DspInfo.use              = 1 ;
    DspInfo.WhatToDoIfLocked = DSPLOCK_IGNORE ;
    is_falcon                = 1 ;
  }
  else DspInfo.type = DspInfo.use = 0 ;

  AESVersion = _GemParBlk.global[0] ;
  Multitos   = (_GemParBlk.global[1] < 0) || (_GemParBlk.global[1] >= 10)  ;
  smenus = popups = popscroll = mnsel = 0 ;
  if ( (AESVersion >= 0x0400) || (appl_find("?AGI\0\0\0\0") >= 0) )
    appl_getinfo( 9, &smenus, &popups, &popscroll, &mnsel ) ;
  else
  {
    /* appl_getinfo only available for AES >= 4.00 but stock AES Falcon is 3.30                         */
    /* However it is possible to install EmuTOS on a Falcon but in this case no popup support           */
    /* In this case AES version is something like 2.xx so let's make 3.30 the trigger for popup support */
    if ( is_falcon && (AESVersion >= 0x0330) )
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
  LoggingDo(LL_DEBUG, "%s popups feature will be used", (popups && popscroll) ? "AES":"Internal") ;
  AESFeatures.SubMenus     = smenus ;
  AESFeatures.Popups       = popups ;
  AESFeatures.PopupsScroll = popscroll ;
  AESFeatures.MNSelAdr     = mnsel ;

  Gdos = vq_gdos() ;

  /* init_path may have been setup by application before calling gem_init() */
  if ( init_path[0] == 0 )
  {
    init_path[0] = 'A' + Dgetdrv() ;
    init_path[1] = ':' ;
    Dgetpath( &init_path[2], 0 ) ;
  }
  strcpy( tmp_path, init_path ) ;

  memzero( work_in, sizeof(work_in) ) ;
  handle     = graf_handle( &wbox, &hbox, &i, &i ) ;
  work_in[0] = 2+Getrez() ;
  for ( i = 1; i < 10; i++ ) work_in[i] = 1 ;
  work_in[10] = 2 ; 

  v_opnvwk( work_in, &handle, work_out ) ;
  Xmax         = work_out[0] ;
  Ymax         = work_out[1] ;
  num_sys_font = work_out[10] ;
  nb_colors    = work_out[13] ;
  h_car_max    = work_out[48] ;
  aspectratio  = (float)work_out[4]/(float)work_out[3] ;

  get_linetype( &ltype ) ;
  get_markertype( &mtype ) ;
  get_filltype( &ftype ) ;
  get_texttype( &ttype ) ;

  vq_extnd( handle, 1, out ) ;
  ZeroMFDB( &screen ) ; /* Most important is that fd_addr = NULL for VDI to assume this is the screen */
  screen.fd_nplanes = out[4] ;
  screen.fd_w       = 1 + Xmax ;
  screen.fd_wdwidth = W2WDWIDTH( screen.fd_w ) ;
  screen.fd_h       = 1 + Ymax ;

  Truecolor = (screen.fd_nplanes > 8) ;

  init_index_tosvdi() ;

  GWHideCursor() ;
  FindScreenOrg( &RVBOrg ) ;
  if ( !Truecolor )
  {
    old_pal = (int*) Xcalloc( (screen.fd_nplanes < 4) ? 16:(1 << screen.fd_nplanes), 3*sizeof(int) ) ;
    get_tospalette( old_pal ) ;
  }

  wind_get( 0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk ) ;
#ifndef __NO_XRSRC
  {
    GRECT desk ;

    desk.g_x = xdesk ; desk.g_y = ydesk ;
    desk.g_w = wdesk ; desk.g_h = hdesk ;
    init_xrsrc( handle, &desk, wbox, hbox ) ;
  }
#endif
  GWShowCursor() ;
  rasterop_init() ;
  graf_mouse( ARROW, 0L ) ;

  return ap_id ;
}

int gem_exit(void)
{
  rasterop_exit() ;
  if ( old_pal )
  {
    set_tospalette( old_pal, nb_colors ) ;
    Xfree( old_pal ) ;
  }
  v_clsvwk( handle ) ;

  if ( appl_exit() == 0 ) return 0 ;

  return 1 ;
}

void my_dragbox(int w, int h, int ix, int iy, int lx, int ly, int lw, int lh, int* fx, int* fy)
{
  MOUSE_DEF save ;
  int       x1, y1, x2, y2 ;
  int       xi1, yi1, xi2, yi2 ;
  int       xm, ym, xm1, ym1, button, dummy ;

  CopyMouseDef( &save, &mouse ) ;
  mouse.gr_monumber = FLAT_HAND ;
  set_mform( &mouse ) ;
  *fx = *fy = 0 ;
  (void)svswr_mode( MD_XOR ) ;
  (void)svsl_color( 1 ) ;
  svsl_type( 1 ) ;
  svsl_width( 1 ) ;
  svsl_ends( 0, 0) ;
  x1 = ix ;     y1 = iy ;
  x2 = ix+w-1 ; y2 = iy+h-1 ;
  GWHideCursor() ;
  rectangle( x1, y1, x2, y2 ) ;
  GWShowCursor() ;
  graf_mkstate( &xm1, &ym1, &button, &dummy ) ;
  do
  {
    graf_mkstate( &xm, &ym, &button, &dummy ) ;
    if ( (xm1 != xm) || (ym1 != ym) )
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
      GWHideCursor() ;
      rectangle(x1, y1, x2, y2) ;
      rectangle(xi1, yi1, xi2, yi2) ;
      GWShowCursor() ;
      x1  = xi1 ; y1  = yi1 ;
      x2  = xi2 ; y2  = yi2 ;
      xm1 = xm ;  ym1 = ym ;
    }
  }
  while (button == 1) ;
  GWHideCursor() ;
  rectangle(x1, y1, x2, y2) ;
  GWShowCursor() ;
  *fx = x1 ;
  *fy = y1 ;
  CopyMouseDef( &mouse, &save ) ;
  set_mform(&mouse) ;
}

int file_getinfo(char* filename, DTA* info)
{
  DTA* old_dta ;
  int  ret ;

  old_dta = Fgetdta() ;
  Fsetdta( info ) ;
  ret = Fsfirst( filename, FA_ARCHIVE ) ;
  Fsetdta( old_dta ) ;

  return ret ;
}

long file_size(char* name)
{
  DTA dta ;

  if ( file_getinfo( name, &dta ) != 0 ) return -1 ;

  return dta.d_length ;
}

int popup_formdo(OBJECT** arbre, int x, int y, int item, int scroll)
{
  MENU pp_menu1, pp_menu2 ;
  int  w, h ;
  int  retour, resultat ;
  int  use_aespopup = AESFeatures.Popups ;

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

    (void)sform_dial( FMD_START, x-1, y-1, w+4, h+4 ) ;
    (void)objc_draw( arbre[0], 0, 100, x-1, y-1, w+4, h+4 ) ;
    resultat = form_do( arbre[0], 0 ) ;
    if ( resultat > 0 )
      if ( arbre[0][resultat].ob_state & DISABLED ) resultat = -1 ;
    if ( resultat > 0 )
      objc_change( arbre[0], resultat, 0, x-1, y-1, w+4, h+4, NORMAL, 1 ) ;
    (void)sform_dial( FMD_FINISH, x-1, y-1, w+4, h+4 ) ;
  }

  return resultat ;
}

OBJECT* popup_make(int nb_objets, int nb_cara)
{
  OBJECT* pop_up ;
  int     i ;

  if ( nb_objets <= 0 ) return NULL ;

  pop_up = (OBJECT*) Xcalloc( 1+nb_objets, sizeof(OBJECT) );
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

int popup_formdo_menu(int m_id, int n_items)
{
  OBJECT* popup ;
  int     result, mx, my, dummy ;
  short   m_ids[32] ;
  short   i, n = 0 ;
  short   len, max_len = 0 ;

  if ( n_items < 0 ) n_items = (int)ARRAY_SIZE(m_ids) ;

  while ( n < n_items )
  {
    m_ids[n++] = m_id ;
    len      = strlen( GemApp.Menu[m_id].ob_spec.free_string ) ;
    if ( len > max_len ) max_len = len ;
    if ( GemApp.Menu[m_id].ob_flags & LASTOB ) break ;
    m_id     = GemApp.Menu[m_id].ob_next ;
  }

  n_items = n ;
  popup   = popup_make( n_items, max_len ) ;
  if ( popup == NULL ) return -3 ;

  for ( i = 1; i <= n_items; i++ )
  {
    memset( popup[i].ob_spec.free_string, ' ', max_len ) ;
    strncpy( popup[i].ob_spec.free_string, GemApp.Menu[m_ids[i-1]].ob_spec.free_string, strlen(GemApp.Menu[m_ids[i-1]].ob_spec.free_string ) ) ;
    if ( GemApp.Menu[m_ids[i-1]].ob_state & CHECKED ) menu_icheck( popup, i, 1 ) ;
  }

  graf_mkstate( &mx, &my, &dummy, &dummy ) ;
  result = popup_formdo( &popup, mx-16, my, 1, 0 ) ;
  popup_kill( popup, n_items ) ;

  if ( result >= 1 )
  {
    result = m_ids[result-1] ;
    if ( memcmp( GemApp.Menu[result].ob_spec.free_string, "---", 3 ) == 0 ) result = -1 ; /* Invalid item */
  }
  else result = -1 ;

  return result ;
}

static void justify_text(OBJECT* obj, char* string)
{
  TEDINFO* ted = (TEDINFO*) obj->ob_spec.tedinfo ;
  short    str_len = (short) strlen(string) ;
  short    gui_str_len = ted->te_txtlen-1 ;
  int      pos ;

  /* We should normally just copy string to ted->te_ptext */
  /* But on old AESes, AES just draws the area of string  */
  /* And if string is shorter than previous one, some     */
  /* Artefacts are present on left/right (TT TOS)         */
  /* So let's justify sting ourselves                     */
  memset( ted->te_ptext, ' ', gui_str_len ) ;
  if ( str_len > gui_str_len ) str_len = gui_str_len ;
  switch ( ted->te_just )
  {
    case TE_LEFT:  pos = 0 ;
                   break ;
    case TE_RIGHT: pos = gui_str_len-str_len ;
                   break ;
    default :      pos = (gui_str_len-str_len) >> 1 ; /* Center */
                   break ;
  }
  memcpy( ted->te_ptext+pos, string, str_len ) ;
  ted->te_ptext[gui_str_len] = 0 ;
}

void xobjc_draw(int w_handle, OBJECT* obj, int num)
{
  TEDINFO* ted = NULL ;
  char*    save_tted = NULL ;
  int      x, y, w, h ;
  int      rx, ry, rw, rh ;
  int      xy[4] ;
  int      border = 5 ;
  int      num_to_draw ;
  char     text_buffer[256] ;

  wind_update( BEG_UPDATE ) ;
  objc_offset( obj, num, &x, &y ) ;
  w = obj[num].ob_width ;
  h = obj[num].ob_height ;
  x -= border ;
  y -= border ;
  w += 2*border ;
  h += 2*border ;
  /* Si l'objet est cache, il faut redessiner le parent, son parent, etc.. En ce */
  /* Cas, il est plus simple (mais moins rapide) de redessiner depuis la racine  */
  if ( obj[num].ob_flags & HIDETREE ) num_to_draw = 0 ;
  else                                num_to_draw = num ;
  if ( obj[num_to_draw].ob_type == G_TEXT )
  {
    ted = (TEDINFO*) obj[num_to_draw].ob_spec.tedinfo ;
    if ( ted->te_txtlen < sizeof(text_buffer) )
    {
      save_tted     = ted->te_ptext ;
      ted->te_ptext = text_buffer ;
      justify_text( &obj[num_to_draw], save_tted ) ;
    }
  }
  wind_get( w_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh ) ;
  while ( rw > 0 )
  {
    if ( intersect( x, y, w, h, rx, ry, rw, rh, xy ) )
      (void)objc_draw( obj, num_to_draw, MAX_DEPTH, xy[0], xy[1], 1+xy[2]-xy[0], 1+xy[3]-xy[1] ) ;
 	  wind_get( w_handle, WF_NEXTXYWH, &rx, &ry, &rw, &rh ) ;
  }
  wind_update( END_UPDATE ) ;
  if ( save_tted ) ted->te_ptext = save_tted ;
}

void cls_gemscreen(void)
{
  int xy[4] ;

  (void)svswr_mode( MD_REPLACE ) ;
  (void)sform_dial( FMD_START, 0, 0, screen.fd_w, screen.fd_h ) ;
  svsf_perimeter( 0 ) ;
  svsf_interior( FIS_SOLID ) ;
  xy[0] = xy[1] = 0 ;
  xy[2] = Xmax ;
  xy[3] = Ymax ;
  GWHideCursor() ;
  svr_recfl( xy ) ;
  GWShowCursor() ;
}

void restore_gemscreen(OBJECT *menu)
{
  (void)sform_dial( FMD_FINISH, 0, 0, screen.fd_w, screen.fd_h ) ;
  menu_bar( menu, 1 ) ;
}

void get_time_date(char *time, char *date)
{
  unsigned int ti, di ;
  TOS_TIME*    t = (TOS_TIME*) &ti ;
  TOS_DATE*    d = (TOS_DATE*) &di ;

  di = Tgetdate() ;
  ti = Tgettime() ;
  sprintf( time, "%.2u:%.2u:%.2u", t->hour, t->minute, t->second * 2 ) ;
  sprintf( date, "%.2u/%.2u/%.4u", d->day, d->month, 1980 + d->year ) ;
}

void get_england_time_date(char* time, char* date)
{
  unsigned int ti, di ;
  TOS_TIME*    t = (TOS_TIME*) &ti ;
  TOS_DATE*    d = (TOS_DATE*) &di ;

  di = Tgetdate() ;
  ti = Tgettime() ;
  sprintf( time, "%.2u:%.2u:%.2u", t->hour, t->minute, t->second * 2 ) ;
  sprintf( date, "%.2u/%.2u/%.4u", 1980 + d->year, d->month, d->day ) ;
}

void vro_cpyfmtc16(int* xy, MFDB* in, MFDB* out)
{
  long size ;
  int  *s, *d ;
  int  s_add, d_add ;
  int  l ;

  if ( (in->fd_nplanes != 16) || (out->fd_nplanes != 16) ) return ;

  s_add = in->fd_wdwidth << 4 ;
  d_add = out->fd_wdwidth << 4 ;
  s     = (int *)in->fd_addr ;
  s    += (long)s_add*(long)xy[1] ;
  s    += xy[0] ;
  d     = (int *)out->fd_addr ;
  d    += (long)d_add*(long)xy[5] ;
  d    += xy[4] ;
  size  = (1+xy[2]-xy[0]) << 1 ;
  for ( l = xy[1]; l <= xy[3]; l++ )
  {
    memcpy( d, s, size ) ;
    s += s_add ;
    d += d_add ;
  }
}

void vro_cpyfmtc24(int* xy, MFDB* in, MFDB* out)
{
  long          size ;
  unsigned char *s, *d ;
  long          s_add, d_add ;
  int           l ;

  if ( (in->fd_nplanes != 24) || (out->fd_nplanes != 24) ) return ;

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
    memcpy( d, s, size ) ;
    s += s_add ;
    d += d_add ;
  }
}

void xvro_cpyfm(int* xy, MFDB* src, MFDB* dest)
{
  if ( (src->fd_nplanes == 16) && (src->fd_nplanes != screen.fd_nplanes) )
    vro_cpyfmtc16( xy, src, dest ) ;
  else
    svro_cpyfmSO( xy, src, dest ) ;
}

int* cycling_init(void)
{
  int* save_pal ;

  save_pal = (int*) Xcalloc( nb_colors, 3*sizeof(short) ) ;
  if ( save_pal == NULL ) return NULL ;

  get_vdipalette( save_pal ) ;
  if ( (MachineInfo.machine == 0x00010100L) || (MachineInfo.machine > 0x00030000L) ) /* FALCON ou mieux ! */
    adr_palette = 0xFF9800L ;
  else if ( MachineInfo.machine == 0x00030000L ) /* TT */
    adr_palette = 0xFF8400L ;
  else
    adr_palette = 0xFF8240L ; /* ST, STE */

  return save_pal ;
}

void cycling_do(int sens)
{
  long cycling_ustack ;

  /* Passe en mode Superviseur pour acc‚der aux registres palettes */
  if ( (MachineInfo.machine != 0x00010100L) && (MachineInfo.machine < 0x00030000L) )
    sens |= 0x02 ; /* Palette en Words */
  cycling_ustack = Super( NULL ) ;
  cycling_ado( sens, screen.fd_nplanes ) ;
  Super( (void*)cycling_ustack ) ;
}

void cycling_terminate(int* save_pal)
{
  set_vdipalette( save_pal, nb_colors ) ;
  if ( save_pal ) Xfree( save_pal ) ;
}

int can_usevro(int nb_planes)
{
  int can_use = 1 ;

  if ( nb_planes != screen.fd_nplanes ) can_use = 0 ;

  return can_use ;
}

int xobjc_hasflag(OBJECT* tree, int index, int flag)
{
  if ( tree[index].ob_state & DISABLED ) return 0 ;

  if ( tree[index].ob_flags & flag ) return 1 ;

  return 0 ;
}

OBJECT* xobjc_copy(OBJECT* tree)
{ /* From Eric REBOUX */
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

	if ((new = (OBJECT *) Xcalloc(1, size + strsize)) != 0)
	{
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

	return new ;
}

void Xrsrc_fix(OBJECT* obj)
{
  int index ;

  for( index = 0; (obj[index].ob_flags & LASTOB) == 0; index++ ) Xrsrc_obfix( obj, index ) ;

  Xrsrc_obfix( obj, index ) ;
}

int Icon2MFDB(ICONBLK* icn, MFDB* out)
{
  MFDB icn_mfdb ;
  int  nplanes = out->fd_nplanes ;
  int  err = 0 ;

  ZeroMFDB( &icn_mfdb ) ;
  icn_mfdb.fd_addr    = icn->ib_pdata ;
  icn_mfdb.fd_w       = icn->ib_wicon ;
  icn_mfdb.fd_h       = icn->ib_hicon ;
  icn_mfdb.fd_wdwidth = W2WDWIDTH( icn_mfdb.fd_w ) ;
  icn_mfdb.fd_nplanes = 1 ;
  out->fd_addr        = NULL ;
  err = raster_duplicate( &icn_mfdb, out ) ;
  if ( !err && (nplanes != out->fd_nplanes) ) err = incnbplanes( out, nplanes, NULL ) ;

  return err ;
}

int Cicon2MFDB(CICONBLK* icnblk, MFDB* out)
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
    while ( icn && (icn->num_planes <= nplanes) )
    {
      best_icn = icn ;
      icn      = icn->next_res ;
    }
    if ( best_icn ) icn = best_icn ;
    else            err = -1 ;
  }

  if ( (best_icn == NULL) || (best_icn->num_planes != nplanes) ) err = 1 ; /* Don't return a MFDB with another number of planes than the one requested */

  if ( !err )
  {
    ZeroMFDB( &icn_mfdb ) ;
    icn_mfdb.fd_addr    = icn->col_data ;
    icn_mfdb.fd_w       = icnblk->monoblk.ib_wicon ;
    icn_mfdb.fd_h       = icnblk->monoblk.ib_hicon ;
    icn_mfdb.fd_wdwidth = W2WDWIDTH( icn_mfdb.fd_w ) ;
    icn_mfdb.fd_nplanes = icn->num_planes ;
    out->fd_addr        = NULL ;
    err = raster_duplicate( &icn_mfdb, out ) ;
    if ( !err && (nplanes != out->fd_nplanes) ) incnbplanes( out, nplanes, NULL ) ; /* Note that TC is not handled */
/*    {
      if ( nplanes <= 8 ) err = incnbplanes( out, nplanes, NULL ) ;
      else
      {
        MFDB temp ;

        temp.fd_nplanes = nplanes ;
        err = index2truecolor( out, NULL, &temp, NULL ) ;
        Xfree( out->fd_addr ) ;
        CopyMFDB( out, &temp ) ;
      }
    }*/
  }

  return err ;
}

void LogMFDB(MFDB* mfdb)
{
  unsigned long crc = simple_crc( mfdb->fd_addr, img_size(mfdb->fd_w, mfdb->fd_h, mfdb->fd_nplanes) ) ;

  LoggingDo(LL_DEBUG, "fd_addr    = %p, CRC=%lx", mfdb->fd_addr, crc) ;
  LoggingDo(LL_DEBUG, "fd_w       = %d", mfdb->fd_w) ;
  LoggingDo(LL_DEBUG, "fd_h       = %d", mfdb->fd_h) ;
  LoggingDo(LL_DEBUG, "fd_nplanes = %d", mfdb->fd_nplanes) ;
  LoggingDo(LL_DEBUG, "fd_wdwidth = %d", mfdb->fd_wdwidth) ;
}

short InternetAvailable(void)
{
  short internet_may_be_here = 0 ;

  if ( Multitos || cookie_find("STiK") ) internet_may_be_here = 1 ;

  return internet_may_be_here ;
}

void memrep(void* mem, size_t size, char old_char, char new_char)
{
  char*  pt = (char*) mem ;
  size_t i ;

  for ( i=0; i < size; i++, pt++ )
    if ( *pt == old_char ) *pt = new_char ;
}

void strrep(char* string, char old_char, char new_char)
{
  char* pt = string ;

  while ( *pt )
  {
    if ( *pt == old_char ) *pt = new_char ;
    pt++ ;
  }
}

static void TryGetFullExec(char* name, char* full_name)
{
  if ( name[1] != ':' )
  {
    /* Full path not specified; let's go through $PATH options */
    char* path = getenv("PATH") ;
    char  found = 0 ;

    if ( path )
    {
      char   tmp[PATH_MAX] ;
      char*  cp = path ;
      char*  c = strchr( cp, ',' ) ;
      size_t size ; 

      LoggingDo(LL_DEBUG, "PATH=%s", path) ;
      while ( c && !found )
      {
        size = (size_t) (c-cp) ;
        strncpy( tmp, cp, size ) ;
        tmp[size] = 0 ;
        sprintf( full_name, "%s\\%s", tmp, name ) ;
        LoggingDo(LL_DEBUG, "Testing presence of %s", full_name) ;
        found = FileExist( full_name ) ;
        if ( !found )
        {
          cp = 1+c ;
          c  = strchr( cp, ',' ) ;
        }
      }
    }
    if ( !found ) strcpy( full_name, name ) ; /* In case we don't have a better match */
    else          strcpy( name, full_name ) ; /* Update name to optimize next call and not look for file location in $PATH */
  }
  else strcpy( full_name, name ) ;
}

static void clr_argv(void)
{
  /* From Thorsten Otto, https://www.atari-forum.com/viewtopic.php?p=416753#p416753 */
	char* p = getenv("ARGV") ;

  if ( p ) p[-5] = 0 ;
}

char* set_tmp_folder(char* tmp_folder)
{
  if ( tmp_folder && tmp_folder[0] ) strcpy( tmp_path, tmp_folder ) ;

  return tmp_path ;
}

char* get_tmp_folder(void)
{
  return tmp_path ;
}

long XPexec_sh(int mode, char* full_name, void* cmdline)
{
  /* Less satisfying solution using shell/temporary script file */
  FILE*                stream ;
  char                 script_name[256] ;
  static unsigned char cnt ;
  long  ret ;

  sprintf( script_name, "%s\\pes%03d.sh", get_tmp_folder(), cnt++ ) ;
  stream = fopen( script_name, "w+b" ) ;
  if ( stream )
  {
    char cmd[280] ;

    memrep( full_name, strlen(full_name), '\\', '/' ) ;
    memrep( cmdline, strlen(cmdline), '\\', '/' ) ;
    fprintf( stream, "%s %s", full_name, cmdline ) ;
    fclose( stream ) ;
    memrep( script_name, strlen(script_name), '\\', '/' ) ;
    sprintf( 1+cmd, "-c %s", script_name ) ;
    cmd[0] = (char) strlen(1+cmd) ;
    LoggingDo(LL_INFO, "XPexec(ARGV) calling /bin/sh %s (%d bytes)", 1+cmd, cmd[0]) ;
    ret = Pexec( mode, "u:/bin/sh", cmd, NULL ) ;
    unlink( script_name ) ;
  }
  else
  {
    LoggingDo(LL_ERROR, "XPexec(ARGV) can't create script file %s", script_name) ;
    ret = -1 ;
  }

  return ret ;
}

long XPexec_eas(int mode, char* full_name, char* cmdline)
{
  /* A BIG thank to Olivier Landemarre ! */
  char   eas_cmd[128] ;
  char*  buffer ; /* Need to be dynamic here as we can't really asume how big the environment string will be */
  char*  pt_env ;
  char*  oenvp = _BasPag->p_env ;
  char*  envp ;
  size_t size ;
  long   ret ;

  LoggingDo(LL_INFO, "XPexec_eas %s %s", full_name, cmdline) ;
  /* First parse of environement string to get its size */
  envp = oenvp ;
  while ( *envp )
  {
    while ( *envp ) envp++ ;
    envp++ ;
  }
  size   = (size_t)(envp-oenvp) + strlen(cmdline) + 20 ; /* Env + cmd line + ARGV= and a bit more */
  buffer = Xalloc( size ) ;
  if ( buffer == NULL ) return -39 ; /* ENSMEM */

  /* Program Environment is required else it fails (e.g. err 27 with curl) */
  pt_env = buffer ;
  envp   = oenvp ;
  while ( *envp )
  {
    while ( *envp ) *pt_env++ = *envp++ ;
    *pt_env++ = 0 ;
    envp++ ;
  }

  *pt_env++='A' ;
  *pt_env++='R' ;
  *pt_env++='G' ;
  *pt_env++='V' ;
  *pt_env++='=' ;
  *pt_env++ = 0 ;
  *pt_env++ = ' ' ; /* These 2 are important else */
  *pt_env++ = 0 ;   /* First parameter is ignored ! */
  /* Simplified version: not taking care of potential spaces in filepaths 
     And assumption that \ is only used for filepaths */
  while ( *cmdline )
  {
    if ( *cmdline == ' ' )       *pt_env++ = 0 ;        /* New parameter/value */
    else if ( *cmdline == '\\' ) *pt_env++ = '/' ;      /* Change \ to / */
    else                         *pt_env++ = *cmdline ; /* Next char of parameter/value */
    cmdline++ ;
  }

  *pt_env++  = 0 ;
  *pt_env    = 0 ;
  eas_cmd[0] = 127 ;

  ret = Pexec( mode, full_name, eas_cmd, buffer ) ;
  Xfree( buffer ) ;

  return ret ;
}

long XPexec(int mode, char* name, void* cmdline)
{
  char  full_name[PATH_MAX] ;
  short cmd_len ;
  long  ret ;

  TryGetFullExec( name, full_name ) ;
  clr_argv() ; /* Else TeraDesk will pass it to full_name and command_line will be ignored, see https://www.atari-forum.com/viewtopic.php?p=416649#p416649 */

  cmd_len = strlen(cmdline) ;
  if ( cmd_len <= 124 )
  {
    /* Max 124 bytes, see https://freemint.github.io/tos.hyp/en/gemdos_process.html#Pexec */
    char buf[128] ;

    buf[0] = (char)cmd_len ; /* Pascal convention */
    strcpy( &buf[1], cmdline ) ;
    LoggingDo(LL_INFO, "XPexec(legacy) %s %s", full_name, &buf[1]) ;
    ret = Pexec( mode, full_name, buf, NULL ) ;
  }
  else ret = XPexec_eas( mode, name, cmdline ) ;

  return ret ;
}

/* 'Smart' computation of percentage taking into account the 32bit range limit */
short cal_pc(long current, long max)
{
  short pc = 0 ;

  if ( max )
  {
    /* Make sure to not overflow 32bit range */
    if ( current < (1L << 30)/100L ) pc = (short) ((100L*current)/max) ;
    else
    {
      max = max >> 7 ;
      if ( max ) pc = (short) ((100L*(current >> 7))/max) ;
    }
/*    else                             pc = (short) (current/(max/100L)) ; 2 divisions to make, so lower precision by >> 7 */
  }

  return pc ;
}

int sform_dial(int fo_diflag, int fo_dilx, int fo_dily, int fo_dilw, int fo_dilh)
{
  return form_dial( fo_diflag, fo_dilx, fo_dily, fo_dilw, fo_dilh, fo_dilx, fo_dily, fo_dilw, fo_dilh ) ;
}

void removeCRCF(char* string)
{
  size_t len = strlen( string ) ;
  char*  c = string+len-1 ;

  while ( (c > string) && ((*c == '\r') || (*c == '\n')) ) *c-- = 0 ;
}

char* ignore_spaces(char* c)
{
  while ( (*c == ' ') || (*c == '\t') ) c++ ;

  return c ;
}

void checkbox_setstate(int state, OBJECT* tree, int index)
{
  if ( state ) select( tree, index ) ;
  else         deselect( tree, index ) ;
}

void radio_select(OBJECT* tree, int* indexes, int nb_index, int sel)
{
  int i ;

  for ( i = 0; i < nb_index; i++ )
    deselect( tree, indexes[i] ) ;

  select( tree, sel ) ;
}

char* long2ASC(long val)
{
  static char asc[5] ;

  *((long*)asc) = val ;
  asc[4] = 0 ;

  return asc ;
}

short count_char(char* s, char c)
{
  short count = 0 ;

  while ( *s )
  {
    if ( *s == c ) count++ ;
    s++ ;
  }

  return count ;
}

char* dzt_string2sep(char* string, char sep, char* output)
{
  char* s = string ;
  char* o = output ;

  for (;;)
  {
    if ( *s == 0 )
    {
      if ( *(s+1) == 0 ) break ;
      *o = sep ;
    }
    else *o = *s ;
    o++ ;
    s++ ;
  }
  *o = 0 ;

  return output ;
}

void form_error_mem(void)
{
  form_error( 8 ) ;
}
