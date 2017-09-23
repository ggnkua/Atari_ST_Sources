/*******************************************/
/* Gestion de catalogues d'images          */
/* Structure du catalogue :                */
/* --------------------------------------- */
/* Header                                  */
/* [ Tag ]----------------------           */
/* [ Index_record ]            |           */
/* [ Info_Data_Record          |<-- Offset */
/* [ Eventuelle palette ]      |           */
/* [ Donn‚es Raster ]          |           */
/* [ Prochain Tag ] <-----------           */
/*******************************************/
#include  <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\stdprog.h"
#include     "..\tools\xgem.h"
#include   "..\tools\dither.h"
#include  "..\tools\cookies.h"
#include  "..\tools\catalog.h"
#include "..\tools\imgmodul.h"
#include "..\tools\rasterop.h"
#include "..\tools\frecurse.h"
#include "..\tools\xfile.h"
#include "..\tools\rzoom.h"
#include "..\tools\ini.h"

#define MARKED_DELETED      '~'

#define CATALOG_VERSION  0x0101

#define ADD_RECORDS         500

#define PLANE1   0
#define PLANE2   1
#define PLANE4   2
#define PLANE8   3
#define TC16     4
#define TC24     5

#define WIDTH  80
#define HEIGHT (WIDTH)

#define TAG_IMAGE            0

#define MAX_CATEGORY        32
#define CATEGORY_DIVERS      0
#define CATEGORY_SIZE       16


typedef struct
{
  int  type ;
  long next_tag ;
}
TAG ;


typedef struct
{
  int vcd_record_size ;
  int vcd_data_size ;
}
VCD_INFOS ;

typedef struct
{
  char rfu[1000] ;
}
CATALOG_INDEX ;


CATALOG_HEADER catalog_header ;         /* CATALOG_HEADER en cours       */
CATALOG_FILTER catalog_filter ;         /* Filtre sur ce catalogue       */
INDEX_RECORD   *tab_index      = NULL ; /* Pointe le 1 er enregistrement */
INDEX_RECORD   *item           = NULL ; /* Enregistrement en cours       */
FILE           *catalog_stream = NULL ;
long           max_records ;
unsigned long  catalog_inspos ;
unsigned long  cat_size ;
int            spec2stdplanes[] = {1, 2, 4, 8, 16, 24 } ;
char           catalog_name[PATH_MAX+16] ; /* Nom complet du catalogue en cours */
char           save_changes ;
char           *std_colors[] = { "Mono", "   4", "  16", " 256", " 64K", " 16M" } ; 
char           *std_fmt[]    = {
                                 "  ART", "  BMP", "DEGAS", "  GIF", "  IFF", "  IMG", " JPEG", "  MAC",
                                 "  NEO", "  PCD", "  PCX", "TARGA", " TIFF", " TINY", "  XGA", "     "
                               } ;
HINI           IniCat ;


void compute_visibles(void)
{
  INDEX_RECORD *record ;
  long i ;
  int  cresult, presult, fresult ;

  record                     = tab_index ;
  catalog_filter.nb_visibles = 0 ;
  if ( catalog_filter.show_all )
  {
    for ( i = 0; i < catalog_header.nb_records+catalog_header.nb_deleted; i++ )
    {
      if ( record->name[0] != MARKED_DELETED )
      {
        record->is_visible = 1 ;
        catalog_filter.nb_visibles++;
      }
      else record->is_visible = 0 ;
      record++ ;
    }
  }
  else
  {
    for ( i = 0; i < catalog_header.nb_records+catalog_header.nb_deleted; i++ )
    {
      record->is_visible = 0 ;
      cresult = fresult  = 0 ;
      if ( record->name[0] != MARKED_DELETED )
      {
        presult = catalog_filter.planes & (1 << record->nbplanes) ;
        if ( presult )
        {
          fresult = catalog_filter.format & (1 << record->format) ;
          if (fresult)
          {
            cresult = catalog_filter.category & (1UL << record->category_1) ||
                      catalog_filter.category & (1UL << record->category_2) ||
                      catalog_filter.category & (1UL << record->category_3) ;
          }
        }
        if ( cresult && presult && fresult )
        {
          record->is_visible = 1 ;
          catalog_filter.nb_visibles++;
        }
      }
      record++ ;
    }
  }
}

int index_record_compare(const void *i, const void *j) ; /* Dans CATALOG.S */
/*{
  INDEX_RECORD *one, *two ;
  int          result ;

  one = (INDEX_RECORD *) i ;
  two = (INDEX_RECORD *) j ;

  result = two->is_visible - one->is_visible ;
  if ( result != 0 ) return( result ) ;

  result = memcmp( one->name, two->name, 8 ) ;
  if ( result != 0 ) return( result ) ;

  result = one->format - two->format ;
  if ( result != 0 ) return( result ) ;

  result = one->nbplanes - two->nbplanes ;

  return( result ) ;
}
*/
void sort_index(void)
{
  long nb_elems = catalog_header.nb_records+catalog_header.nb_deleted ;

  if ( tab_index == NULL ) return ;

  compute_visibles() ;

  qsort( tab_index, nb_elems, sizeof(INDEX_RECORD), index_record_compare ) ;
}

void init_catalog_header(char *catalog_name)
{
  catalog_header.header_size = (int) sizeof(CATALOG_HEADER) ;
  catalog_header.version     = CATALOG_VERSION ;
  catalog_header.index_record_size   = (int) sizeof(INDEX_RECORD) ;
  catalog_header.width       = WIDTH ;
  catalog_header.height      = HEIGHT ;
  catalog_header.nb_records  = 0 ;
  strcpy(catalog_header.catalog_name, catalog_name) ;
  memset(catalog_header.comment, 0, sizeof(catalog_header.comment)) ;
  memset(catalog_header.rfu, 0, sizeof(catalog_header.rfu)) ;
  memset(catalog_header.category_names, 0, MAX_CATEGORY*CATEGORY_SIZE) ;
  strcpy(catalog_header.category_names[0], "General") ;
  max_records               = ADD_RECORDS ;
  save_changes              = 0 ;
  catalog_header.nb_deleted = 0 ;
  catalog_header.save_index = 0 ;

  memset(&catalog_filter, 0xFF, sizeof(CATALOG_FILTER)) ;
}

int build_index(FILE *stream, GEM_WINDOW *wprog)
{
  INDEX_RECORD *last_item ;
  TAG          tag ;
  long         total, nb ;
  int          err = ECAT_NOERR ;

  if (catalog_header.save_index)
  {
    FILE *index_stream ;
    int  len ;
    char index_name[200] ;

    strcpy(index_name, catalog_name) ;
    len = (int) strlen(index_name) ;
    index_name[len-1] = 'I' ;       /* .VCI -> .VII */
    index_stream = fopen(index_name, "rb") ;
    if ( index_stream != NULL )
    {
      if ( fseek(index_stream, sizeof(CATALOG_INDEX), SEEK_SET) != 0 )
        err = ECAT_SEEK ;
      else
      {
        total = catalog_header.nb_records+catalog_header.nb_deleted ;
        catalog_header.save_index = (fread(tab_index, sizeof(INDEX_RECORD), total, index_stream) == total) ;
        fclose(index_stream) ;
      }
    }
    else catalog_header.save_index = 0 ;
  }

  if ( !catalog_header.save_index )
  {
    int fini = 0 ;
  
    item                      = tab_index ;
    last_item                 = item+max_records-1 ;
    nb                        = 0 ;
    total                     = catalog_header.nb_records+catalog_header.nb_deleted ;
    catalog_header.nb_records = 0 ;
    catalog_header.nb_deleted = 0 ;
    if ( fseek( stream, catalog_header.header_size, SEEK_SET ) != 0 )
      err = ECAT_SEEK ;
    while ( !fini && !err )
    {
      if ( fread(&tag, sizeof(TAG), 1, stream ) == 1 )
      {
        if ( tag.type == TAG_IMAGE )
        {
          if ( fread( item, sizeof(INDEX_RECORD), 1, stream ) == 1 )
          {
            if (item->name[0] == MARKED_DELETED) catalog_header.nb_deleted++ ;
            else                                 catalog_header.nb_records++ ;
            item++ ;
          }
          else err = ECAT_READ ;
        }
        if ( tag.next_tag >= catalog_header.header_size )
        {
          if ( fseek( stream, tag.next_tag, SEEK_SET ) != 0 )
            err = ECAT_SEEK ;
        }
        else
          fini = 1 ;
      }
      else fini = 1 ;
      if ( !fini && !err )
      {
        nb++ ;
        fini = feof( stream ) ;
        if ( item >= last_item )
          fini = 1 ;
      }
      if ( MAY_UPDATE( wprog, nb ) )
        wprog->ProgPc( wprog, (int)( (100L*nb) / total), NULL ) ;
    }
  }

  return( err ) ;
}

int load_catalog_header(char *catalog_name, GEM_WINDOW *wprog)
{
  DTA  dta ;
  long total ;

  catalog_stream = fopen( catalog_name, "rb+" ) ;
  if ( catalog_stream == NULL ) catalog_stream = fopen( catalog_name, "rb" ) ; /* CD-ROM ... */
  if ( catalog_stream == NULL ) return( ECAT_FILENOTFOUND ) ;

  file_getinfo( catalog_name, &dta ) ;
  cat_size     = dta.d_length ;

  fread(&catalog_header, sizeof(CATALOG_HEADER), 1, catalog_stream) ;
  if (catalog_header.version > CATALOG_VERSION)
  {
    fclose(catalog_stream) ;
    return( ECAT_BADVERSION ) ;
  }

  rewind(catalog_stream) ;
  if ( fread(&catalog_header, catalog_header.header_size, 1, catalog_stream) != 1 )
    return( ECAT_READ ) ;;

  if (tab_index != NULL) free( tab_index ) ;
  total       = catalog_header.nb_records+catalog_header.nb_deleted ;
  max_records = ADD_RECORDS+(total/ADD_RECORDS)*ADD_RECORDS ;
  max_records += ADD_RECORDS ; /* Par s‚curit‚ */
  tab_index = calloc( max_records, catalog_header.index_record_size ) ;
  if ( tab_index == NULL )
  {
    fclose(catalog_stream) ;
    return( ECAT_NOMEMORY ) ;
  }

  memset(&catalog_filter, 0xFF, sizeof(CATALOG_FILTER)) ;

  return( build_index( catalog_stream, wprog ) ) ;
}

void catalog_setrem(char *rem)
{
  memcpy( &catalog_header.comment, rem, 80 ) ;
}

void compress_palette(INFO_IMAGE *inf, unsigned char *pal)
{
  long          i ;
  int           *pt ;
  unsigned char *cpt ;

  pt = inf->palette ;
  if (pt == NULL) return ;
  cpt = pal ;
  for (i = 0; i < inf->nb_cpal; i++)
  {
    *cpt++ = (unsigned char) (*pt++ >> 2) ; /* Rouge */
    *cpt++ = (unsigned char) (*pt++ >> 2) ; /* Vert  */
    *cpt++ = (unsigned char) (*pt++ >> 2) ; /* Bleu  */
  }
}

void vcd_infos(VCD_INFOS *vcd_infos, int nplanes)
{
  switch(nplanes)
  {
    case 1  : vcd_infos->vcd_data_size   = (catalog_header.width*catalog_header.height) >> 3 ; /* Raster       */
              vcd_infos->vcd_record_size = INFO_DATA_RECORD+vcd_infos->vcd_data_size ;         /* +Commentaire */
              break ;
    case 2  : vcd_infos->vcd_data_size    = (catalog_header.width*catalog_header.height) >> 2 ; /* Raster       */
              vcd_infos->vcd_record_size  = INFO_DATA_RECORD+vcd_infos->vcd_data_size ;         /* +Commentaire */
              vcd_infos->vcd_record_size += (1 << nplanes)*3 ;                                  /* +Palette     */
              break ;
    case 4  : vcd_infos->vcd_data_size   = (catalog_header.width*catalog_header.height) >> 1 ;  /* Raster       */
              vcd_infos->vcd_record_size  = INFO_DATA_RECORD+vcd_infos->vcd_data_size ;         /* +Commentaire */
              vcd_infos->vcd_record_size += (1 << nplanes)*3 ;                                  /* +Palette     */
              break ;
    case 8  : vcd_infos->vcd_data_size   = catalog_header.width*catalog_header.height ;         /* Raster       */
              vcd_infos->vcd_record_size  = INFO_DATA_RECORD+vcd_infos->vcd_data_size ;         /* +Commentaire */
              vcd_infos->vcd_record_size += (1 << nplanes)*3 ;                                  /* +Palette     */
              break ;
    case 16 : vcd_infos->vcd_data_size   = (catalog_header.width*catalog_header.height) << 1 ; /* Raster       */
              vcd_infos->vcd_record_size = INFO_DATA_RECORD+vcd_infos->vcd_data_size ;         /* +Commentaire */
              break ;
  }
}

int std2catimgfmt(long lformat)
{
  if ( lformat == IID_IMG )   return( F_IMG ) ;
  if ( lformat == IID_DEGAS ) return( F_DEGAS ) ;
  if ( lformat == IID_ART )   return( F_ART ) ;
  if ( lformat == IID_NEO )   return( F_NEO ) ;
  if ( lformat == IID_MAC )   return( F_MAC ) ;
  if ( lformat == IID_GIF )   return( F_GIF ) ;
  if ( lformat == IID_TIFF )  return( F_TIFF ) ;
  if ( lformat == IID_TARGA ) return( F_TARGA ) ;
  if ( lformat == IID_JPEG )  return( F_JPEG ) ;
  if ( lformat == IID_BMP )   return( F_BMP ) ;

  return( F_UNKNOWN ) ;
}

int index_add(FILE *stream)
{
  int err = ECAT_NOERR ;

  catalog_header.nb_records++ ;
  if (catalog_header.nb_records+catalog_header.nb_deleted >= max_records)
  {
    INDEX_RECORD *new_index ;

    max_records += ADD_RECORDS ;
    new_index = (INDEX_RECORD *) calloc( max_records, sizeof(INDEX_RECORD) ) ;
    if (new_index == NULL)
    {
      catalog_header.nb_records-- ;
      max_records -= ADD_RECORDS ;
      return( ECAT_NOMEMORY ) ;
    }
    memcpy(new_index, tab_index, (catalog_header.nb_records+catalog_header.nb_deleted-1L)*sizeof(INDEX_RECORD)) ;
    free(tab_index) ;
    tab_index = new_index ;
  }

  if ( fseek(stream, 0L, SEEK_END) != 0 ) err = ECAT_SEEK ;
  /* ftell ne marche plus au dela d'une certaine taille */
  catalog_inspos = cat_size ;
  item = &tab_index[catalog_header.nb_records+catalog_header.nb_deleted-1] ;

  return( err ) ;
}

int stdplanes2pcat(int planes)
{
  int np ;

  switch(planes)
  {
    case 1  : np = PLANE1 ;
              break ;
    case 2  : np = PLANE2 ;
              break ;
    case 4  : np = PLANE4 ;
              break ;
    case 8  : np = PLANE8 ;
              break ;
    case 16 : np = TC16 ;
              break ;
    case 24 : np = TC24 ;
              break ;
    default : np = 0 ;
              break ;
  }

  return(np) ;
}

int catalog_findplace(FILE *stream, int nplanes)
{
  int err = ECAT_NOERR ;
  int fini = 0 ;

  if ( catalog_header.nb_deleted > 0 )
  {
    INDEX_RECORD *current, *last_item ;
    int          same_nbplanes ;

    same_nbplanes = stdplanes2pcat(nplanes) ;
    current       = tab_index ;
    last_item     = current+catalog_header.nb_records+catalog_header.nb_deleted-1 ;
    while ( !fini && !err && ( current <= last_item ) )
    {
      if ((current->name[0] == MARKED_DELETED) && (current->nbplanes == same_nbplanes))
      {
        catalog_inspos = current->offset-sizeof(TAG)-sizeof(INDEX_RECORD) ;
        if ( fseek( stream, catalog_inspos, SEEK_SET ) != 0 )
          err = ECAT_SEEK ;
        else
        {
          item = current ;
          catalog_header.nb_records++ ;
          catalog_header.nb_deleted-- ;
          fini = 1 ;
        }
      }
      current++ ;
    }
  }
  else
  {
    /* On doit ajouter un nouvel ‚l‚ment d'index */

    err = index_add( stream ) ;
  }

  return( err ) ;
}

void catname(char *fname, char *filename)
{
  char *c ;
  int  i = 0 ;

  memset(fname, ' ', 8) ;
  c = strrchr(filename, '\\') ;
  if (c == NULL) return ;
  c++ ;
  while ( (i < 8) && (*c != '.') && (*c != 0))
  {
    if ( (*c >= 'a') && (*c <= 'z') ) fname[i++] = *c + 'A' - 'a' ;
    else                              fname[i++] = *c ;
    c++ ;
  }
}

int item_exist(char *filename)
{
  INDEX_RECORD *current, *last_item ;
  int          exist = 0 ;
  char         name[20] ;
  char         buffer[INFO_DATA_RECORD] ;

  catname(name, filename) ;
  current   = tab_index ;
  last_item = current+catalog_header.nb_records+catalog_header.nb_deleted-1 ;
  while (current <= last_item)
  {
    if (memcmp(current->name, name, 8) == 0)            /* Mˆme nom de r‚f‚rence ? */
    {
      fseek(catalog_stream, current->offset, SEEK_SET) ; /* V‚rifions alors le nom physique */
      fread(buffer, INFO_DATA_RECORD, 1, catalog_stream) ;
      if (strcmpi(buffer, filename) == 0)
      {
        exist = 1 ;
        item  = current ;
        break ;
      }
    }
    current++ ;
  }

  return( exist ) ;
}

size_t icon_size(MFDB *img)
{
  size_t nb ;

  switch(img->fd_nplanes)
  {
    case  1 : nb = (catalog_header.width*catalog_header.height) >> 3 ;
              break ;
    case  2 : nb = (catalog_header.width*catalog_header.height) >> 2 ;
              break ;
    case  4 : nb = (catalog_header.width*catalog_header.height) >> 1 ;
              break ;
    case  8 : nb = catalog_header.width*catalog_header.height ;
              break ;
    default : nb = (catalog_header.width*catalog_header.height) << 1 ;
              break ;
  }

  return(nb) ;
}

void encrypt_datetime(DTA *dta, INDEX_RECORD *rec)
{
  rec->date_time = 7*dta->d_time+2*dta->d_date ;
}

int catalog_setcatini(int cat_ini)
{
  if ( cat_ini )
  {
    IniCat = OpenIni( catalog_header.cat_inifile ) ;
  }
  else if ( IniCat != -1 )
  {
    CloseIni( IniCat ) ;
    IniCat = -1 ;
  }

  return( IniCat != -1 ) ;
}

void get_categories(char *filename, INDEX_RECORD *item)
{
  item->category_1 = catalog_header.default_categorie ;
  item->category_2 = catalog_header.default_categorie ;
  item->category_3 = catalog_header.default_categorie ;
  if ( IniCat != -1 )
  {
    int  i, index ;
    char section[30] ;
    char mask[128] ;
    char buf[50] ;
    char found = 0 ;

    for ( i = 0; ( i < 50 ) && !found; i++ )
    {
      sprintf( section, "Look%d", i ) ;
      if ( GetIniKey( IniCat, section, "Path", mask ) )
        found = file_in_mask( filename, mask ) ;
    }
    if ( found )
    {
      if ( GetIniKey( IniCat, section, "Cat1", buf ) )
      {
        index = catalog_addcategory( buf ) ;
        if ( index < MAX_CATEGORY ) item->category_1 = index ;
      }
      if ( GetIniKey( IniCat, section, "Cat2", buf ) )
      {
        index = catalog_addcategory( buf ) ;
        if ( index < MAX_CATEGORY ) item->category_2 = index ;
      }
      if ( GetIniKey( IniCat, section, "Cat3", buf ) )
      {
        index = catalog_addcategory( buf ) ;
        if ( index < MAX_CATEGORY ) item->category_3 = index ;
      }
    }
  }
}

int add_icon(char *filename, INFO_IMAGE *inf, MFDB *icon)
{
  TAG           tag ;
  DTA           dta ;
  size_t        size_icon ;
  long          pos ;
  int           err = ECAT_NOERR ;
  char          info[INFO_DATA_RECORD] ;
  unsigned char cpal[3*256] ;
  char          ajout = 1 ;

  memset( info, 0, INFO_DATA_RECORD ) ;
  strcpy( info, filename ) ;
  if ( catalog_stream == NULL ) return( ECAT_FILENOTFOUND ) ;
  err = catalog_findplace( catalog_stream, icon->fd_nplanes ) ;
  if ( err )  return( err ) ;

  pos = catalog_inspos ;
  if ( pos != cat_size )
    ajout = 0 ;

  size_icon    = icon_size(icon) ;
  tag.type     = TAG_IMAGE ;
  tag.next_tag = pos+sizeof(TAG)+sizeof(INDEX_RECORD)+INFO_DATA_RECORD+size_icon ;

  memset(item, 0, sizeof(INDEX_RECORD)) ;
  catname(item->name, filename) ;
  item->nbplanes   = stdplanes2pcat(icon->fd_nplanes) ;
  item->format     = std2catimgfmt( inf->lformat ) ;

  get_categories( filename, item ) ;

  item->offset     = pos+sizeof(TAG)+sizeof(INDEX_RECORD) ;
  file_getinfo(filename, &dta) ;
  encrypt_datetime(&dta, item) ;

  if ( ( icon->fd_nplanes != 1 ) && ( icon->fd_nplanes != 16 ) )
  {
    compress_palette( inf, cpal ) ;
    tag.next_tag += 3L*(long)(1 << icon->fd_nplanes) ;
    fwrite(&tag, sizeof(TAG), 1, catalog_stream) ;
    fwrite(item, sizeof(INDEX_RECORD), 1, catalog_stream) ;
    fwrite(info, 1, INFO_DATA_RECORD, catalog_stream) ;
    fwrite(cpal, 3, 1 << icon->fd_nplanes, catalog_stream) ;
    if ( ajout )
      cat_size += sizeof(TAG)+sizeof(INDEX_RECORD)+INFO_DATA_RECORD+3*(1 << icon->fd_nplanes) ;
  }
  else
  {
    fwrite(&tag, sizeof(TAG), 1, catalog_stream) ;
    fwrite(item, sizeof(INDEX_RECORD), 1, catalog_stream) ;
    fwrite(info, 1, INFO_DATA_RECORD, catalog_stream) ;
    if ( ajout )
      cat_size += sizeof(TAG)+sizeof(INDEX_RECORD)+INFO_DATA_RECORD ;
  }

  if ( fwrite(icon->fd_addr, size_icon, 1, catalog_stream) != 1 )
    err = ECAT_WRITE ;

  if ( ajout )
    cat_size += size_icon ;

  return( err ) ;
}

int fit_vignet_into_icon(MFDB *in, MFDB *out)
{
  int xy[8] ;

  out->fd_w       = catalog_header.width ;
  out->fd_h       = catalog_header.height ;
  out->fd_wdwidth = out->fd_w/16 ;
  if (out->fd_w % 16) out->fd_wdwidth++ ;
  out->fd_nplanes = in->fd_nplanes ;
  out->fd_stand   = in->fd_stand ;
  out->fd_addr    = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if (out->fd_addr == NULL) return(-3) ;
  img_raz(out) ;

  xy[0] = xy[1] = 0 ;
  xy[2] = in->fd_w-1 ; xy[3] = in->fd_h-1 ;
  xy[4] = (out->fd_w-in->fd_w)/2 ;
  xy[5] = (out->fd_h-in->fd_h)/2 ;
  xy[6] = xy[4]+in->fd_w-1 ;
  xy[7] = xy[5]+in->fd_h-1 ;
  /* Fonction vro_cpyfm ‚tendue : cas o— en mode non TrueColor, on traite une image TrueColor    */
  /* De plus, NVDI (2.5) est incapable de traiter des rasters ayant un nombre de plans diff‚rent */
  /* De celui de la r‚solution de l'‚cran.                                                       */
/*  if ( ( cookie_find( "NVDI" ) && ( in->fd_nplanes != nb_plane ) && ( in->fd_nplanes <= 8 ) ) ||
       ( Truecolor && (in->fd_nplanes <= 8) )
     )*/
  if ( !can_usevro( in->fd_nplanes ) && ( in->fd_nplanes != 16 ) )
    smart_fit( in, out, xy ) ;
  else
    xvro_cpyfm( handle, S_ONLY, xy, in, out ) ;

  return(0) ;
}

int catalog_remove(long index)
{
  if ((index < 0) || (index >= catalog_header.nb_records+catalog_header.nb_deleted) ||
     (tab_index[index].name[0] == MARKED_DELETED)) return(-1) ;

  tab_index[index].name[0] = MARKED_DELETED ;
  fseek(catalog_stream, tab_index[index].offset-sizeof(INDEX_RECORD), SEEK_SET) ;
  fwrite(&tab_index[index], sizeof(INDEX_RECORD), 1, catalog_stream) ;
  sort_index() ;
  catalog_header.nb_records-- ;
  catalog_header.nb_deleted++ ;
  save_changes = 1 ;

  return(0) ;
}

int catalog_add(char *filename, GEM_WINDOW *wprog)
{
  INFO_IMAGE inf ;
  MFDB       img, vignette, icon ;
  float      pcx, pcy ;
  int        err ;
  int        analyse ;
  int        old_force = Force16BitsLoad ;
  int        old_stdvdi = UseStdVDI ;

  if ( item_exist( filename ) ) return( ECAT_ITEMEXIST ) ;

  analyse     = img_analyse ;
  img_analyse = 1 ;
  err = img_format( filename, &inf ) ;
  if ( err )
  {
    img_analyse = analyse ;
    if ( inf.palette ) free( inf.palette ) ;
    return( err ) ;
  }

  memset( &img, 0, sizeof(MFDB) ) ;
  img.fd_nplanes = -1 ;
  Force16BitsLoad = 1 ;
  UseStdVDI       = UseStdVDI & can_usevro( inf.nplans ) ;
  err             = load_picture( filename, &img, &inf, wprog ) ;
  Force16BitsLoad = old_force ;
  if (err)
  {
    img_analyse = analyse ;
    UseStdVDI   = old_stdvdi ;
    return( err ) ;
  }

  img_analyse = analyse ;
  pcx = (float)catalog_header.width/(float)img.fd_w ;
  pcy = (float)catalog_header.height/(float)img.fd_h ;
  if ( pcx > pcy ) pcx = pcy ;
  else             pcy = pcx ;
  /* R‚duit la taille de l'image … une vignette */
  vignette.fd_addr = NULL ;
  vignette.fd_w    = (int) ( 0.5 + (float)img.fd_w * pcx ) ;
  vignette.fd_h    = (int) ( 0.5 + (float)img.fd_h * pcy ) ;
/*  if ( raster_pczoom( &img, &vignette, pcx, pcy, NULL) != 0 )*/
  if ( RasterZoom( &img, &vignette, NULL ) != 0 )
  {
    free( img.fd_addr ) ;
    if ( inf.palette ) free( inf.palette ) ;
    UseStdVDI = old_stdvdi ;

    return( ECAT_NOMEMORY ) ; /* M‚moire insuffisante */
  }

  free( img.fd_addr ) ;

  /* Centre la vignette dans l'icone */
  err = fit_vignet_into_icon( &vignette, &icon ) ;
  if (err)
  {
    free( vignette.fd_addr ) ;
    free( img.fd_addr ) ;
    if ( inf.palette ) free( inf.palette ) ;
    UseStdVDI = old_stdvdi ;
  
    return( ECAT_NOMEMORY ) ;
  }
  free(vignette.fd_addr) ;

  if ( icon.fd_nplanes <= 8 ) MakeMFDBClassicAtari( &icon, NULL ) ; /* Effectue si UseStdVDI = 1 */
  else if ( UseStdVDI ) tc_invconvert( &icon ) ;
  err = add_icon(filename, &inf, &icon) ;
  free(icon.fd_addr) ;
  if (inf.palette != NULL) free(inf.palette) ;

  UseStdVDI    = old_stdvdi ;
  save_changes = 1 ;
  sort_index() ;

  return( err ) ;
}

int catalog_saveindex(void)
{
  CATALOG_INDEX header ;
  FILE          *index_stream ;
  long          total ;
  int           len ;
  char          index_name[200] ;

  strcpy(index_name, catalog_name) ;
  len = (int) strlen(index_name) ;
  index_name[len-1] = 'I' ;       /* .VCI -> .VII */
  index_stream = fopen(index_name, "wb") ;
  if (index_stream == NULL) return(0) ;

  memset(&header, 0, sizeof(CATALOG_INDEX)) ;
  fwrite(&header, sizeof(CATALOG_INDEX), 1, index_stream) ;
  catalog_filter.show_all = 1 ;
  sort_index() ;
  total = catalog_header.nb_records+catalog_header.nb_deleted ;
  if ( fwrite(tab_index, sizeof(INDEX_RECORD), total, index_stream) != total )
  {
    fclose(index_stream) ;
    return(0) ;
  }

  return( fclose(index_stream) == 0 ) ;
}

int catalog_close(void)
{
  unsigned int di ;
  TOS_DATE     *d = (TOS_DATE *) &di ;

  if (tab_index == NULL) return(-1) ;

  if (save_changes)
  {
    rewind(catalog_stream) ;
    di = Tgetdate() ;
    sprintf(catalog_header.date, "%.2d/%.2d/%.4d", d->day, d->month, 1980 + d->year) ;
    if (catalog_header.save_index)
      catalog_header.save_index = catalog_saveindex() ;
    fwrite(&catalog_header, catalog_header.header_size, 1, catalog_stream) ;
  }
  fclose(catalog_stream) ;
  free(tab_index) ;
  tab_index = NULL ;
  memset(&catalog_header, 0, sizeof(CATALOG_HEADER)) ;
  catalog_name[0]     = 0 ;
  save_changes        = 0 ;
  max_records         = 0 ;
  item                = NULL ;

  return(0) ;
}

/**********************************************************************/
/* Cr‚ation d'un nouveau catalogue                                    */
/* access_path d‚signe le r‚pertoire o— sera cr‚e le sous r‚pertoire  */
/* Catalogue et ses fichiers 1_PLANE.VCD, 2_PLANES.VCD, 4_PLANES.VCD, */
/* 8_PLANES.VCD, TRUECOL.VCD et INDEX.VCI                             */
/* En retour :  0 : OK                                                */
/*             -1 : Impossible de cr‚er le r‚pertoire                 */
/*             -2 : Impossible de cr‚er les fichiers                  */
/*             -3 : M‚moire insuffisante                              */
/**********************************************************************/
int catalog_new(char *access_path, char *cat_name)
{
  unsigned int di ;
  TOS_DATE     *d = (TOS_DATE *) &di;

  if (catalog_name[0] != 0) catalog_close() ;

  sprintf( catalog_name, "%s\\%s.VIC", access_path, cat_name ) ;
  catalog_stream = fopen(catalog_name, "wb+") ;
  if (catalog_stream == NULL) return( ECAT_FILENOTFOUND ) ;

  init_catalog_header(cat_name) ;
  fwrite(&catalog_header, sizeof(CATALOG_HEADER), 1, catalog_stream) ;
  max_records = ADD_RECORDS ;
  if (tab_index != NULL) free(tab_index) ;
  tab_index = calloc(max_records, sizeof(INDEX_RECORD)) ;
  if (tab_index == NULL) return( ECAT_NOMEMORY ) ;

  di = Tgetdate() ;
  sprintf(catalog_header.date, "%.2d/%.2d/%.4d", d->day, d->month, 1980 + d->year) ;
  save_changes = 1 ;
  cat_size     = sizeof(CATALOG_HEADER) ;

  return( ECAT_NOERR ) ;
}

/**********************************************************************/
/* Ouverture d'un nouveau catalogue                                   */
/* En retour :  0 : OK                                                */
/*             -1 : Catalogue introuvable                             */
/*             -2 : Mauvaise version                                  */
/*             -3 : M‚moire insuffisante                              */
/**********************************************************************/
int catalog_open(char *cat_name, GEM_WINDOW *wprog)
{
  int  err ;

  if (catalog_name[0] != 0) catalog_close() ;

  strcpy(catalog_name, cat_name) ;

  mouse_busy() ;
  err = load_catalog_header(catalog_name, wprog) ;
  if (err)
  {
    mouse_restore() ;
    return( err ) ;
  }

  sort_index() ;
  save_changes = 0 ;
  mouse_restore() ;

  return( ECAT_NOERR ) ;
}

void catalog_getstdinfos(long ind, char *nom, char *fmt, char *nplanes)
{
  INDEX_RECORD *pt ;

  if ((tab_index == NULL) || (ind < 0) || (ind >= catalog_header.nb_records+catalog_header.nb_deleted) || !tab_index[ind].is_visible)
  {
    strcpy(nom, "        ") ;
    strcpy(fmt, "     ") ;
    strcpy(nplanes, "    ") ;
  }
  else
  {
    pt = &tab_index[ind] ;
    memset(nom, 0, 9) ;
    memcpy(nom, pt->name, 8) ;
    strcpy(fmt, std_fmt[pt->format]) ;
    strcpy(nplanes, std_colors[pt->nbplanes]) ;
  }
}

void decompress_palette(unsigned char *cpal, int nplanes, int *pal)
{
  int           i ;
  int           *pt ;
  unsigned char *cpt ;

  pt = pal ;
  if (pt == NULL) return ;
  cpt = cpal ;
  for (i = 0; i < (1 << nplanes); i++)
  {
    *pt++ = *cpt++ << 2 ; /* Rouge */
    *pt++ = *cpt++ << 2 ; /* Vert  */
    *pt++ = *cpt++ << 2 ; /* Bleu  */
  }
}

/* Chargement sans adaptation du nombre de couleurs */
int catalog_ncloadicon(long index, MFDB *out, INFO_IMAGE *inf, char *comment)
{
  VCD_INFOS     vcd ;
  int           nplanes, err ;
  unsigned char cpal[3*256] ;

  err = ECAT_NOERR ;
  comment[0] = 0 ;
  memset(out, 0, sizeof(MFDB)) ;
  memset(inf, 0, sizeof(INFO_IMAGE)) ;
  if ((index >= catalog_header.nb_records+catalog_header.nb_deleted) || (tab_index[index].name[0] == MARKED_DELETED) ||
      (index >= catalog_filter.nb_visibles))
  {
    out->fd_w = catalog_header.width ;
    out->fd_h = catalog_header.height ;
    out->fd_wdwidth = out->fd_w/16 ;
    if (out->fd_w% 16) out->fd_wdwidth++ ;
    out->fd_nplanes = nb_plane ;
    out->fd_stand   = 0 ;
    out->fd_addr    = img_alloc(out->fd_w, out->fd_h, nb_plane) ;
    if (out->fd_addr == NULL) return( ECAT_NOMEMORY ) ;
    img_raz(out) ;
    return( ECAT_BADINDEX ) ;
  }
  nplanes = spec2stdplanes[tab_index[index].nbplanes] ;
  vcd_infos(&vcd, nplanes) ;
  out->fd_w = catalog_header.width ;
  out->fd_h = catalog_header.height ;
  out->fd_wdwidth = out->fd_w/16 ;
  if (out->fd_w% 16) out->fd_wdwidth++ ;
  out->fd_nplanes = nplanes ;
  out->fd_stand   = 0 ;
  out->fd_addr    = img_alloc(out->fd_w, out->fd_h, nplanes) ;
  if (out->fd_addr == NULL) return( ECAT_NOMEMORY ) ;

  if ( fseek(catalog_stream, tab_index[index].offset+PATH_MAX, SEEK_SET) != 0 ) 
    err = ECAT_SEEK ;
  else
    fread( comment, SIZE_COMMENT, 1, catalog_stream ) ;

  if ( ( nplanes <= 8 ) && ( nplanes > 1 ) )
  {
    inf->nb_cpal = 1 << out->fd_nplanes ;
    inf->palette = malloc( 6*inf->nb_cpal ) ;
    if (inf->palette == NULL)
    {
      free(out->fd_addr) ;
      return( ECAT_NOMEMORY ) ;
    }
    if ( fseek(catalog_stream, tab_index[index].offset+INFO_DATA_RECORD, SEEK_SET) != 0 )
      err = ECAT_SEEK ;
    else
    {
      fread( cpal, 3, inf->nb_cpal, catalog_stream ) ;
      decompress_palette( cpal, nplanes, inf->palette ) ;
    }
  }
  else
    if ( fseek(catalog_stream, tab_index[index].offset+vcd.vcd_record_size-vcd.vcd_data_size, SEEK_SET) != 0 )
      err = ECAT_SEEK ;

  fread(out->fd_addr, vcd.vcd_data_size, 1, catalog_stream) ;

  return( err ) ;
}

int catalog_loadicon(long index, MFDB *out, INFO_IMAGE *inf, char *comment)
{
  MFDB virtuel ;
  int  err ;
  int  cancel_stdvdi = 0 ;

  err = catalog_ncloadicon( index, out, inf, comment ) ;
  if ( err != ECAT_NOERR ) return( err ) ;
/*
  err = ECAT_NOERR ;
  comment[0] = 0 ;
  memset(out, 0, sizeof(MFDB)) ;
  memset(inf, 0, sizeof(INFO_IMAGE)) ;
  if ((index >= catalog_header.nb_records+catalog_header.nb_deleted) || (tab_index[index].name[0] == MARKED_DELETED) ||
      (index >= catalog_filter.nb_visibles))
  {
    out->fd_w = catalog_header.width ;
    out->fd_h = catalog_header.height ;
    out->fd_wdwidth = out->fd_w/16 ;
    if (out->fd_w% 16) out->fd_wdwidth++ ;
    out->fd_nplanes = nb_plane ;
    out->fd_stand   = 0 ;
    out->fd_addr    = img_alloc(out->fd_w, out->fd_h, nb_plane) ;
    if (out->fd_addr == NULL) return( ECAT_NOMEMORY ) ;
    img_raz(out) ;
    return( ECAT_BADINDEX ) ;
  }
  nplanes = spec2stdplanes[tab_index[index].nbplanes] ;
  vcd_infos(&vcd, nplanes) ;
  out->fd_w = catalog_header.width ;
  out->fd_h = catalog_header.height ;
  out->fd_wdwidth = out->fd_w/16 ;
  if (out->fd_w% 16) out->fd_wdwidth++ ;
  out->fd_nplanes = nplanes ;
  out->fd_stand   = 0 ;
  out->fd_addr    = img_alloc(out->fd_w, out->fd_h, nplanes) ;
  if (out->fd_addr == NULL) return( ECAT_NOMEMORY ) ;

  if ( fseek(catalog_stream, tab_index[index].offset+PATH_MAX, SEEK_SET) != 0 ) 
    err = ECAT_SEEK ;
  else
    fread( comment, SIZE_COMMENT, 1, catalog_stream ) ;

  if ( ( nplanes <= 8 ) && ( nplanes > 1 ) )
  {
    inf->nb_cpal = 1 << out->fd_nplanes ;
    inf->palette = malloc( 6*inf->nb_cpal ) ;
    if (inf->palette == NULL)
    {
      free(out->fd_addr) ;
      return( ECAT_NOMEMORY ) ;
    }
    if ( fseek(catalog_stream, tab_index[index].offset+INFO_DATA_RECORD, SEEK_SET) != 0 )
      err = ECAT_SEEK ;
    else
    {
      fread( cpal, 3, inf->nb_cpal, catalog_stream ) ;
      decompress_palette( cpal, nplanes, inf->palette ) ;
    }
  }
  else
    if ( fseek(catalog_stream, tab_index[index].offset+vcd.vcd_record_size-vcd.vcd_data_size, SEEK_SET) != 0 )
      err = ECAT_SEEK ;

  fread(out->fd_addr, vcd.vcd_data_size, 1, catalog_stream) ;
*/
  if ( out->fd_nplanes < nb_plane )
  {
    memcpy( &virtuel, out, sizeof(MFDB) ) ;
    virtuel.fd_nplanes = nb_plane ;
    if ( Truecolor && ( out->fd_nplanes <= 8 ) )
    {
      err = index2truecolor( out, inf, &virtuel, NULL ) ;
      free(out->fd_addr) ;
      memcpy(out, &virtuel, sizeof(MFDB)) ;
    }
    if ( Truecolor && ( out->fd_nplanes == 16 ) )
    {
      unsigned char *buffer ;

      switch( nb_plane )
      {
        case 16 : 
                  break ;
        case 24 : buffer = (unsigned char *) malloc( 3L*(long)out->fd_w*(long)out->fd_h ) ;
                  if ( buffer != NULL )
                  {
                    tc16to24( out->fd_addr, buffer, (long)out->fd_w*(long)out->fd_h ) ;
                    free( out->fd_addr ) ;
                    out->fd_addr = buffer ;
                    out->fd_nplanes = nb_plane ;
                  }
                  else err = ECAT_NOMEMORY ;
                  break ;
        case 32 : buffer = (unsigned char *) malloc( 4L*(long)out->fd_w*(long)out->fd_h ) ;
                  if ( buffer != NULL )
                  {
                    tc16to32( out->fd_addr, buffer, (long)out->fd_w*(long)out->fd_h ) ;
                    free( out->fd_addr ) ;
                    out->fd_addr = buffer ;
                    out->fd_nplanes = nb_plane ;
                  }
                  else err = ECAT_NOMEMORY ;
                  break ;
      }
    }
    else
    {
      if ( out->fd_nplanes == 1 ) cancel_stdvdi = 1 ;
      err = incnbplanes( out, nb_plane ) ;
    }
  }
  else if ( out->fd_nplanes > nb_plane )
  {
    memcpy( &virtuel, out, sizeof(MFDB) ) ;
    virtuel.fd_nplanes = nb_plane ;
    err = dither( DITHER_AUTO, out, inf, &virtuel, NULL ) ;
    if ( err == 0 )
    {
      free(out->fd_addr) ;
      memcpy(out, &virtuel, sizeof(MFDB)) ;
    }
    else
    {
      free(out->fd_addr) ;
      out->fd_addr = img_alloc(out->fd_w, out->fd_h, nb_plane) ;
      if (out->fd_addr != NULL) img_raz(out) ;
      else                      err = ECAT_NOMEMORY ;
    }
  }

  if ( err == ECAT_NOERR )
  {
    if ( UseStdVDI && !cancel_stdvdi )
    {
      if ( nb_plane <= 8 )
      {
        MFDB std_img ;

        memcpy(&std_img, out, sizeof(MFDB)) ;
        std_img.fd_addr = img_alloc(std_img.fd_w, std_img.fd_h, std_img.fd_nplanes) ;
        if (std_img.fd_addr != NULL)
        {
          std_img.fd_stand = 1 ;
          ClassicAtari2StdVDI(out, &std_img) ;
          vr_trnfm(handle, &std_img, out) ;
          free(std_img.fd_addr) ;
        }
        else err = ECAT_NOMEMORY ;
      }
      else tc_convert( out ) ;
    }
 }

  return( err ) ;
}

void catalog_getfullname(long num_index, char *name)
{
  char buffer[INFO_DATA_RECORD] ;

  name[0] = 0 ;
  if ((tab_index == NULL) || (num_index > catalog_header.nb_records)) return ;

  fseek(catalog_stream, tab_index[num_index].offset, SEEK_SET) ;
  fread(buffer, INFO_DATA_RECORD, 1, catalog_stream) ;
  strcpy(name, buffer) ;
  if (name[0]+'A' >= catalog_header.shift_start) name[0] += catalog_header.shift_value ;
}

void catalog_stats(CATALOG_STATS *stats)
{
  INDEX_RECORD *rec ;
  long         i, s1p, s2p, s4p, s8p, stc ;
  char         *c ;

  memset(stats, 0, sizeof(CATALOG_STATS)) ;
  c = strrchr(catalog_name, '\\') ;
  if (c != NULL) strcpy(stats->name, ++c) ;
  memcpy(stats->comment, catalog_header.comment, 80) ;
  stats->nb_records = catalog_header.nb_records ;
  stats->nb_deleted = catalog_header.nb_deleted ;
  strcpy(stats->date, catalog_header.date) ;

  stats->nb_1plane = stats->nb_2plane = stats->nb_4plane = stats->nb_8plane = stats->nb_tc   = 0L ;
  stats->size_1p   = stats->size_2p   = stats->size_4p   = stats->size_8p   = stats->size_tc = 0L ;
  rec = tab_index ;
  s1p = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(catalog_header.width, catalog_header.height, 1) ;
  s2p = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(catalog_header.width, catalog_header.height, 2)+(long)(4*3) ;
  s4p = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(catalog_header.width, catalog_header.height, 4)+(long)(16*3) ;
  s8p = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(catalog_header.width, catalog_header.height, 8)+(long)(256*3) ;
  stc = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(catalog_header.width, catalog_header.height, 16) ;
  for (i = 0; i < catalog_header.nb_records+catalog_header.nb_deleted; i++)
  {
    if (rec->name[0] != MARKED_DELETED)
    {
      switch(rec->nbplanes)
      {
        case PLANE1 : stats->nb_1plane++ ;
                      stats->size_1p += s1p ;
                      break ;
        case PLANE2 : stats->nb_2plane++ ;
                      stats->size_2p += s2p ;
                      break ;
        case PLANE4 : stats->nb_4plane++ ;
                      stats->size_4p += s4p ;
                      break ;
        case PLANE8 : stats->nb_8plane++ ;
                      stats->size_8p += s8p ;
                      break ;
        case TC16   :
        case TC24   : stats->nb_tc++ ;
                      stats->size_tc += stc ;
                      break ;
      }
    }
    rec++ ;
  }

  stats->size_1p >>= 10 ;
  stats->size_2p >>= 10 ;
  stats->size_4p >>= 10 ;
  stats->size_8p >>= 10 ;
  stats->size_tc >>= 10 ;
}

int catalog_addcategory(char *category)
{
  int i = 0 ;
  int found = 0 ;

  category[CATEGORY_SIZE-1] = 0 ;
  while ( !found && ( i < MAX_CATEGORY ) )
  {
    if ( strcmpi( category, catalog_header.category_names[i] ) == 0 ) found = 1 ;
    else
    {
      if ( catalog_header.category_names[i][0] ) i++ ;
      else                                       found = 1 ;
    }
  }
  if ( found ) strcpy( catalog_header.category_names[i], category ) ;

  save_changes = 1 ;

  return( i ) ;
}

void catalog_setimgcomment(long index, char *comment)
{
  long len = strlen(comment) ;

  if (tab_index == NULL) return ;
  if ((index < 0) || (index >= catalog_header.nb_records+catalog_header.nb_deleted)) return ;

  if (len >= SIZE_COMMENT-1) comment[SIZE_COMMENT-1] = 0 ;
  fseek(catalog_stream, tab_index[index].offset+PATH_MAX, SEEK_SET) ;
  fwrite(comment, 1+strlen(comment), 1, catalog_stream) ;
}

void catalog_getimgcomment(long index, char *comment)
{
  *comment = 0 ;
  if (tab_index == NULL) return ;
  if ((index < 0) || (index >= catalog_header.nb_records+catalog_header.nb_deleted)) return ;

  fseek(catalog_stream, tab_index[index].offset+PATH_MAX, SEEK_SET) ;
  fread(comment, SIZE_COMMENT, 1, catalog_stream) ;
}

int catalog_setcategory(long index, int category_id, int category_no)
{
  int err = ECAT_NOERR ;

  if ((index < 0) || (index >= catalog_header.nb_records+catalog_header.nb_deleted)) return( ECAT_BADINDEX ) ;

  switch(category_no)
  {
    case 1 : if (category_id != tab_index[index].category_1)
             {
               tab_index[index].category_1 = category_id ;
               if (tab_index[index].category_2 == CATEGORY_DIVERS) tab_index[index].category_2 = category_id ;
               if (tab_index[index].category_3 == CATEGORY_DIVERS) tab_index[index].category_3 = category_id ;
               if ( fseek(catalog_stream, tab_index[index].offset-sizeof(INDEX_RECORD), SEEK_SET) != 0 )
                 err = ECAT_SEEK ;
               else
                 fwrite(&tab_index[index], sizeof(INDEX_RECORD), 1, catalog_stream) ;
             }
             break ;
    case 2 : if (category_id != tab_index[index].category_2)
             {
               tab_index[index].category_2 = category_id ;
               if (tab_index[index].category_3 == CATEGORY_DIVERS) tab_index[index].category_3 = category_id ;
               if ( fseek(catalog_stream, tab_index[index].offset-sizeof(INDEX_RECORD), SEEK_SET) != 0 )
                 err = ECAT_SEEK ;
               else
                 fwrite(&tab_index[index], sizeof(INDEX_RECORD), 1, catalog_stream) ;
             }
             break ;
    case 3 : if (category_id != tab_index[index].category_3)
             {
               tab_index[index].category_3 = category_id ;
               if ( fseek(catalog_stream, tab_index[index].offset-sizeof(INDEX_RECORD), SEEK_SET) != 0 )
                 err = ECAT_SEEK ;
               else
                 fwrite(&tab_index[index], sizeof(INDEX_RECORD), 1, catalog_stream) ;
             }
             break ;
  }
  save_changes = 1 ;

  return( err ) ;
}

void catalog_setsaveindex(int flag_save)
{
  if (flag_save != catalog_header.save_index)
  {
    save_changes              = 1 ;
    catalog_header.save_index = flag_save ;
  }
}

void catalog_update(char *text)
{
  GEM_WINDOW   *wprog ;
  INDEX_RECORD inf, *rec ; 
  DTA          dta ;
  long         i ;
  int          exist ;
  int          pc ;
  int          c1, c2, c3 ;
  char         filename[PATH_MAX+16] ;

  rec = tab_index ;
  if ( rec == NULL ) return ;
  wprog = DisplayStdProg( text, "", "", CLOSER ) ;
  for ( i = 0; i < catalog_header.nb_records+catalog_header.nb_deleted; i++ )
  {
    if ( rec->name[0] != MARKED_DELETED )
    {
      catalog_getfullname( i, filename ) ;
      StdProgWText( wprog, 2, filename ) ;
      exist = ( file_getinfo(filename, &dta) == 0 ) ;
      if ( !exist )
      {
        catalog_remove( i-- ) ;
        rec-- ;
      }
      else
      {
        encrypt_datetime( &dta, &inf ) ;
        if ( inf.date_time != rec->date_time )
        {
          c1 = rec->category_1 ;
          c2 = rec->category_2 ;
          c3 = rec->category_3 ;
          catalog_remove( i ) ;
          catalog_add( filename, NULL ) ;
          if ( item_exist( filename ) )
          {
            item->category_1 = c1 ;
            item->category_2 = c2 ;
            item->category_3 = c3 ;
            fseek( catalog_stream, item->offset-catalog_header.index_record_size, SEEK_SET ) ;
            fwrite( item, catalog_header.index_record_size, 1, catalog_stream ) ;
          }
        }
      }
    }
      if ( MAY_UPDATE( wprog, i ) )
    {
      pc = (int) (((long)(1+i)*100L)/(catalog_header.nb_records+catalog_header.nb_deleted)) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }
    rec++ ;
  }
  GWDestroyWindow( wprog ) ;
}

void GetTxtCategories(long num, char *buf)
{
  INDEX_RECORD *r ;
  char         buffer[80] ;

  r = &tab_index[num] ;
  memset( buffer, 0, sizeof(buffer) ) ;
  memcpy( buffer, r->name, sizeof(r->name) ) ;
  sprintf(buf, "%s, %s", buffer,  catalog_header.category_names[r->category_1]) ;
  if (r->category_2 != r->category_1)
  {
    sprintf(buffer, ", %s",  catalog_header.category_names[r->category_2]) ;
    strcat(buf, buffer) ;
  }

  if ((r->category_3 != r->category_2) && (r->category_3 != r->category_1))
  {
    sprintf(buffer, ", %s",  catalog_header.category_names[r->category_3]) ;
    strcat(buf, buffer) ;
  }
}

int ConvImg(char *file, char *dest_path, char *out_name)
{
  XFILE_OPTIONS xf_options ;
  MFDB          mfdb_conv ;
  INFO_IMAGE    inf_conv ;
  int           err ;
  char          *point, *slash ;
  char          ext[10], name[40] ;
  char          name_out[PATH_MAX] ;

  get_ext( file, ext ) ;
  point = strrchr( file, '.' ) ;
  if ( point )
  {
    *point = 0 ;
    slash = strrchr( file, '\\' ) ;
    if ( slash ) *slash = 0 ;
    else         slash = file ;
    strcpy( name, 1+ slash ) ;
    if ( slash ) *slash = '\\' ;
    *point = '.' ;
  }
  else strcpy( name, file ) ;

  if ( strcmpi( ext, "gif" ) && strcmpi( ext, "jpg" ) && strcmpi( ext, "jpeg" ) )
  {
    IMG_MODULE *img_module ;

    /* Conversion vers GIF ou JPEG */
    memset( &mfdb_conv, 0, sizeof(MFDB) ) ;
    memset( &inf_conv, 0, sizeof(INFO_IMAGE) ) ;
    mfdb_conv.fd_nplanes = -1 ; /* Conserver le nombre de plans */
    err = img_format( file, &inf_conv ) ;
    if ( !err ) err = load_picture( file, &mfdb_conv, &inf_conv, NULL ) ;
    if ( !err )
    {
      if ( mfdb_conv.fd_nplanes > 8 ) inf_conv.lformat = 'JPG' ;
      else                            inf_conv.lformat = 'GIF' ;
      inf_conv.quality     = 75 ;
      inf_conv.progressive = 0 ;
      inf_conv.nplans      = mfdb_conv.fd_nplanes ;
      img_module = DImgGetModuleFromIID( inf_conv.lformat ) ;
      if ( img_module )
      {
        sprintf( name_out, "%s\\%s.%s", dest_path, name, img_module->Capabilities.file_extension ) ;
        err = save_picture( name_out, &mfdb_conv, &inf_conv, NULL ) ;
      }
      else err = -5 ;
    }
    if ( mfdb_conv.fd_addr ) free( mfdb_conv.fd_addr ) ;
    if ( inf_conv.palette ) free( inf_conv.palette ) ;
    if ( !err ) sprintf( out_name, "%s.%s", name, img_module->Capabilities.file_extension ) ;
  }
  else
  {
    /* Recopie du fichier */
    memset( &xf_options, 0, sizeof(xf_options) ) ;
    SetXFileOptions( &xf_options ) ;
    sprintf( name_out, "%s\\%s.%s", dest_path, name, ext ) ;
    err = CopyFile( file, name_out ) ;
    if ( !err ) sprintf( out_name, "%s.%s", name, ext ) ;
  }

  return( err ) ;
}

FILE *create_ehtml(CHTML_EXPORT *exp)
{
  FILE *stream ;
  char buf[PATH_MAX] ;

  exp->num++ ;
  sprintf( buf, "%s\\%s%d.HTM", exp->path, exp->base_name, exp->num ) ;

  stream = fopen( buf, "wb" ) ;
  if ( stream == NULL ) return( stream ) ;
  
  fprintf( stream,
  "<html>\r\n\
   <head>\r\n\
   <meta http-equiv=\"Content-Type\"\r\n\
   content=""text/html; charset=iso-8859-1"">\r\n\
   <meta name=\"GENERATOR\" content=\"VISION\">\r\n\
   <title>%s</title>\r\n\
   </head>\r\n\
   <body bgcolor=\"#%02X%02X%02X\"",
   exp->page_title, exp->back_color[0], exp->back_color[1], exp->back_color[2] ) ;

  if ( exp->back_file[0] )
  {
    if ( ConvImg( exp->back_file, exp->path, buf ) == 0 )
      fprintf( stream, " background=\"%s\"", buf ) ;
  }

  fprintf( stream,
  ">\r\n<p align=\"center\"><font size=\"4\"><strong>%s</strong></font></p>\r\n\
   <div align=\"center\"><center>\r\n",
   exp->page_title
   ) ;

  fprintf( stream,
  "<table border=\"%d\" width=\"%d%%\">\r\n", exp->border_width, exp->pc ) ;

  return( stream ) ;
}

void close_ehtml(FILE *stream, CHTML_EXPORT *exp)
{
  int  nb_pages, nb_img, nb_img_per_page, num_page ;
  char prev[30] ;
  char next[30] ;

  if ( exp->nb_img_per_row > 0 )
  {
    nb_img          = (int) (1 + exp->last - exp->first) ;
    nb_img_per_page = exp->nb_img_per_row * exp->nb_img_per_line ;
    nb_pages = nb_img / nb_img_per_page ;
    if ( nb_img % nb_img_per_page ) nb_pages++ ;
  }
  else nb_pages = 1 ;

  fprintf( stream,
  "</table>\r\n\
   </center></div>\r\n" ) ;

  if ( nb_pages > 1 )
  {
    fprintf( stream, "<tr><td align=center><br><b>%s</b>&nbsp;&nbsp;\r\n", exp->page_label ) ;
    for ( num_page = 1; num_page <= nb_pages; num_page++ )
    {
      if ( num_page == exp->num ) /* Pas de lien */
        fprintf( stream, "<b>%d</b>&nbsp;\r\n", num_page ) ;
      else
        fprintf( stream, "<a href=\"%s%d.HTM\">%d</a>&nbsp;\r\n", exp->base_name, num_page, num_page ) ;
    }
    fprintf( stream, "</td></tr>\r\n" ) ;
    fprintf( stream, "<p><tr><td align=center><tr><td align=center>" ) ;
    sprintf( prev, "%s%d.HTM", exp->base_name, exp->num - 1 ) ;
    sprintf( next, "%s%d.HTM", exp->base_name, exp->num + 1 ) ;
    if ( exp->num == 1 )
      fprintf( stream, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"%s\">%s</a>", next, exp->next_label ) ;
    else if ( exp->num == nb_pages )
      fprintf( stream, "<a href=\"%s\">%s</a>", prev, exp->previous_label ) ;
    else
      fprintf( stream, "<a href=\"%s\">%s</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"%s\">%s</a>",
               prev, exp->previous_label, next, exp->next_label ) ;
    fprintf( stream, "</td></td>\r\n" ) ;
  }

  fprintf( stream,
  "</body>\r\n\
   </html>" ) ;

  fclose ( stream ) ;
}

int catalog_ehtml(CHTML_EXPORT *exp, GEM_WINDOW *wprog)
{
  MFDB       vignette ;
  INFO_IMAGE inf_img ;
  FILE       *stream ;
  long       num ;
  int        pc, wpc ;
  int        nline, nrow ;
  int        link_img, err = 0, cancel = 0 ;
  int        name_conflict = 0 ;
  int        old_stdvdi = UseStdVDI ;
  char       *slash, *point ;
  char       ext[10] ;
  char       comment[SIZE_COMMENT] ;
  char       name[PATH_MAX] ;
  char       buf[PATH_MAX] ;
  char       full_name[PATH_MAX] ;

  sprintf( buf, "%s\\mini", exp->path ) ;
  if ( CreateFolder( buf ) ) return( -1 ) ;
  if ( exp->flags & EH_LINKIMG )
  {
    sprintf( buf, "%s\\images", exp->path ) ;
    if ( CreateFolder( buf ) ) return( -1 ) ;
  }

  stream = create_ehtml( exp ) ;
  if ( stream == NULL ) return( -1 ) ;

  UseStdVDI = 0 ;
  nline     = 0 ;
  nrow      = 0 ;
  wpc       = exp->pc / exp->nb_img_per_line ;
  mouse_busy() ;
  for ( num = exp->first; !cancel && !err && ( num <= exp->last ); num++ )
  {
    if ( ( nline % exp->nb_img_per_line ) == 0 ) fprintf( stream, "  <tr>\r\n" ) ;
    nline++ ;
    fprintf( stream, "    <td align=\"center\" width=\"%d%%\">", wpc ) ;
    memset( &vignette, 0, sizeof(MFDB) ) ;
    memset( &inf_img, 0, sizeof(INFO_IMAGE) ) ;
    if ( catalog_ncloadicon( num, &vignette, &inf_img, comment ) == ECAT_NOERR )
    {
      inf_img.quality     = 75 ;
      inf_img.progressive = 0 ;
      catalog_getfullname( num, full_name ) ;
      slash = strrchr( full_name, '\\' ) ;
      if ( slash )
      {
        long lfmt ;

        if ( vignette.fd_nplanes > 8 ) { strcpy( ext, ".JPG" ) ; lfmt = 'JPG' ; }
        else                           { strcpy( ext, ".GIF" ) ; lfmt = 'GIF' ; }
        sprintf( name, "%s\\mini\\%s", exp->path, 1 + slash ) ;
        point = strrchr( name, '.' ) ;
        if ( point ) *point = 0 ;
        strcat( name, ext ) ; /* Force l'extension */
        sprintf( buf, "... %s ...", 1 + slash ) ;
        StdProgWText( wprog, 1, buf ) ;
        inf_img.lformat = lfmt ;
        if ( FileExist( name ) ) sprintf( name, "%s\\mini\\_V%04d_%s", exp->path, name_conflict++, ext ) ;
        err = save_picture( name,  &vignette, &inf_img, NULL ) ;
        if ( !err )
        {
          link_img = exp->flags & EH_LINKIMG ;
          if ( link_img )
          {
            sprintf( buf, "%s\\images", exp->path ) ;
            link_img = ( ConvImg( full_name, buf, buf ) == 0 ) ;
            if ( link_img ) fprintf( stream, "<a href=\"images/%s\">", buf ) ;
          }
          GetTxtCategories( num, buf ) ;
          if ( comment[0] )
          {
            strcat( buf, ", " ) ;
            strcat( buf, comment ) ;
          }
          slash = strrchr( name, '\\' ) ;
          fprintf( stream, "<img src=\"mini/%s\" alt = \"%s\" border=\"0\" width=\"%d\" height=\"%d\">",
                   1 + slash, buf, vignette.fd_w, vignette.fd_h ) ;

          if ( exp->flags & EH_SHOWNAMES )
          {
            strcpy( buf, 1 + slash ) ;
            strlwr( buf ) ;
            fprintf( stream, "<br>%s", buf ) ;
          }

          if ( link_img ) fprintf( stream, "</a>" ) ;
        }
      }
      else err = -3 ;
    }
    else err = -3 ;

    if ( inf_img.palette ) free( inf_img.palette ) ;
    if ( vignette.fd_addr ) free( vignette.fd_addr ) ;

    if ( err ) fprintf( stream, "&nbsp;" ) ;
    fprintf( stream, "</td>\r\n" ) ;
    if ( ( nline % exp->nb_img_per_line ) == 0 )
    {
      fprintf( stream, "  </tr>\r\n" ) ;
      nrow++ ;
    }

    if ( ( exp->nb_img_per_row > 0 ) && ( nrow >= exp->nb_img_per_row ) )
    {
      close_ehtml( stream, exp ) ;
      if ( num < exp->last )
      {
        stream = create_ehtml( exp ) ;
        if ( stream == NULL ) err = -1 ;
      }
      else stream = NULL ;
      nrow = nline = 0 ;
    }

    if ( wprog )
    {
      pc = (int) ( ( (num - exp->first)*100L ) / (exp->last - exp->first) ) ;
      cancel = wprog->ProgPc( wprog, pc, NULL ) ;
    }
  }

  if ( stream ) close_ehtml( stream, exp ) ;

  UseStdVDI = old_stdvdi ;
  mouse_restore() ;

  return( err ) ;
}
