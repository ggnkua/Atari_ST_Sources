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

#include  "stdprog.h"
#include  "xgem.h"
#include  "dither.h"
#include  "cookies.h"
#include  "catalog.h"
#include "imgmodul.h"
#include "rasterop.h"
#include "frecurse.h"
#include "xfile.h"
#include "rzoom.h"
#include "ini.h"
#include "crc.h"
#include "logging.h"

#define MARKED_DELETED      '~'

#define CATALOG_VERSION  0x0102

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

#define INFO_DATA_RECORD (PATH_MAX+SIZE_COMMENT)


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

#define CAT_MAGIC 'VCAT'
typedef struct __CATALOG
{
  long           magic ;
  CATALOG_HEADER catalog_header ;
  CATALOG_FILTER catalog_filter ;
  INDEX_RECORD   *tab_index ;
  INDEX_RECORD   *item ;
  FILE           *catalog_stream ;
  long           max_records ;
  unsigned long  catalog_inspos ;
  unsigned long  cat_size ;
  char           catalog_name[PATH_MAX+16] ;
  char           save_changes ;
  HINI           IniCat ;
}
CATALOG, *PCATALOG ;

/* Shared data for all catalog instances */
int   spec2stdplanes[] = {1, 2, 4, 8, 16, 24 } ;
char* std_colors[] = { "Mono", "   4", "  16", " 256", " 64K", " 16M" } ; 
char* std_fmt[]    = {
                        "  ART", "  BMP", "DEGAS", "  GIF", "  IFF", "  IMG", " JPEG", "  MAC",
                        "  NEO", "  PCD", "  PNG", "TARGA", " TIFF", " TINY", "  XGA", "     "
                     } ;

CATALOG* alloc_catalog(void)
{
  CATALOG* cat = Xcalloc( 1, sizeof(CATALOG) ) ;

  if ( cat ) cat->magic = CAT_MAGIC ;

  return cat ;
}

void free_catalog(CATALOG* cat)
{
  cat->magic = 0 ;
  Xfree( cat ) ;
}

CATALOG* HCAT2CATALOG(HCAT hCat)
{
  CATALOG* cat = (CATALOG*) hCat ;

  if ( !cat || (cat->magic != CAT_MAGIC) ) cat = NULL ;

  return cat ;
}

CATALOG_HEADER* catalog_get_header(HCAT hCat)
{
  CATALOG*        cat = HCAT2CATALOG( hCat ) ;
  CATALOG_HEADER* header = NULL ;

  if ( cat ) header = &cat->catalog_header ;

  return header ;
}

CATALOG_FILTER* catalog_get_filter(HCAT hCat)
{
  CATALOG*        cat = HCAT2CATALOG( hCat ) ;
  CATALOG_FILTER* filter = NULL ;

  if ( cat ) filter = &cat->catalog_filter ;

  return filter ;
}

INDEX_RECORD* catalog_get_index_record(HCAT hCat)
{
  CATALOG*      cat = HCAT2CATALOG( hCat ) ;
  INDEX_RECORD* index_record = NULL ;

  if ( cat ) index_record = cat->tab_index ;

  return index_record ;
}

static int name_in_mask(char* name, char* mask, int tmask)
{
  int nchars = tmask & 0xF ;
  int is_in = 0 ;

  /* We assume nchars <= 8 */
  if ( tmask & 0x8000 )
  {
    /* name contains mask */
    int offset = 0 ;

    while ( !is_in && (offset+nchars <= 8) )
    {
      is_in = ( memcmp( name+offset, mask, nchars ) == 0 ) ;
      offset++ ;
    }
  }
  else
  {
    /* name starts with mask */
    is_in = ( memcmp( name, mask, nchars ) == 0 ) ;
  }

  return is_in ;
}

void compute_visibles(CATALOG* cat)
{
  INDEX_RECORD*   record ;
  CATALOG_FILTER* cfilter = &cat->catalog_filter ;
  long            i ;

  record               = cat->tab_index ;
  cfilter->nb_visibles = 0 ;
  if ( cfilter->show_all )
  {
    for ( i = 0; i < cat->catalog_header.nb_records+cat->catalog_header.nb_deleted; i++, record++ )
    {
      if ( record->name[0] != MARKED_DELETED )
      {
        record->is_visible = 1 ;
        cfilter->nb_visibles++;
      }
      else record->is_visible = 0 ;
    }
  }
  else
  {
    int visible ;
    int nchar_mask = cfilter->filter_on_name ? (int)strlen(cfilter->filter_name) : 0 ;

    if ( nchar_mask > 8 )         nchar_mask = 0 ; /* 8 characters max for name */
    else if ( cfilter->contains ) nchar_mask |= 0x8000 ; /* For name contains filter_name, use negative value */

    for ( i = 0; i < cat->catalog_header.nb_records+cat->catalog_header.nb_deleted; i++, record++ )
    {
      if ( record->name[0] != MARKED_DELETED )
      {
        visible = cfilter->planes & (1 << record->nbplanes) ;
        if ( visible )
        {
          visible = cfilter->format & (1 << record->format) ;
          if ( visible )
          {
            visible = cfilter->category & (1UL << record->category_1) ||
                      cfilter->category & (1UL << record->category_2) ||
                      cfilter->category & (1UL << record->category_3) ;
          }
        }
        if ( visible && nchar_mask )
          visible = name_in_mask( record->name, cfilter->filter_name, nchar_mask ) ; 
        if ( visible )
        {
          record->is_visible = 1 ;
          cfilter->nb_visibles++ ;
        }
        else record->is_visible = 0 ;
      }
    }
  }
}

int index_record_compare(const void *i, const void *j) ; /* In CATALOG.S */
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

void catalog_sort_index(HCAT hCat)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;

  if ( cat && cat->tab_index )
  {
    compute_visibles( cat ) ;
    qsort( cat->tab_index, cat->catalog_header.nb_records+cat->catalog_header.nb_deleted, sizeof(INDEX_RECORD), index_record_compare ) ;
  }
}

void catalog_setsaveindex(HCAT hCat, int flag_save)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;

  if ( cat && (flag_save != cat->catalog_header.save_index) )
  {
    cat->save_changes              = 1 ;
    cat->catalog_header.save_index = flag_save ;
  }
}

void init_catalog_header(CATALOG* cat, char *catalog_name)
{
  cat->catalog_header.header_size = (int) sizeof(CATALOG_HEADER) ;
  cat->catalog_header.version     = CATALOG_VERSION ;
  cat->catalog_header.index_record_size   = (int) sizeof(INDEX_RECORD) ;
  cat->catalog_header.width       = WIDTH ;
  cat->catalog_header.height      = HEIGHT ;
  cat->catalog_header.nb_records  = 0 ;
  strcpy(cat->catalog_header.catalog_name, catalog_name) ;
  memzero(cat->catalog_header.comment, sizeof(cat->catalog_header.comment)) ;
  memzero(cat->catalog_header.rfu, sizeof(cat->catalog_header.rfu)) ;
  memzero(cat->catalog_header.category_names, MAX_CATEGORY*CATEGORY_SIZE) ;
  strcpy(cat->catalog_header.category_names[0], "General") ;
  cat->max_records               = ADD_RECORDS ;
  cat->save_changes              = 0 ;
  cat->catalog_header.nb_deleted = 0 ;
  cat->catalog_header.save_index = 1 ;

  memset(&cat->catalog_filter, 0xFF, sizeof(CATALOG_FILTER)) ;
}

int build_index(CATALOG* cat, GEM_WINDOW* wprog)
{
  INDEX_RECORD *last_item ;
  TAG          tag ;
  long         total, nb ;
  int          err = ECAT_NOERR ;
  int          build_index = 1 ;

  cat->save_changes = 1 ; /* Assume index will be saved */
  if ( cat->catalog_header.save_index )
  {
    FILE *index_stream ;
    int  len ;
    char index_name[200] ;

    strcpy(index_name, cat->catalog_name) ;
    len = (int) strlen(index_name) ;
    index_name[len-1] = 'I' ;       /* .VCI -> .VII */
    index_stream = fopen(index_name, "rb") ;
    if ( index_stream != NULL )
    {
      if ( fseek(index_stream, sizeof(CATALOG_INDEX), SEEK_SET) != 0 )
        err = ECAT_SEEK ;
      else
      {
        size_t nread ;

        total = cat->catalog_header.nb_records+cat->catalog_header.nb_deleted ;
        nread = fread(cat->tab_index, sizeof(INDEX_RECORD), total, index_stream) ;
        cat->catalog_header.save_index = ( nread == total) ;
        if ( !cat->catalog_header.save_index )
          LoggingDo( LL_WARNING, "Incorrect size when reading VII file: %ld read, expecting %ld; index will be rebuilt", nread, total ) ;
        else
          build_index = cat->save_changes = 0 ;
      }
      fclose(index_stream) ;
    }
    else LoggingDo( LL_WARNING, "Impossible to open %s; index will be rebuilt", index_name ) ;
  }

  if ( build_index )
  {
    int fini = 0 ;
  
    cat->item = cat->tab_index ;
    last_item = cat->item+cat->max_records-1 ;
    nb        = 0 ;
    total     = cat->catalog_header.nb_records+cat->catalog_header.nb_deleted ;
    cat->catalog_header.nb_records = 0 ;
    cat->catalog_header.nb_deleted = 0 ;
    if ( fseek( cat->catalog_stream, cat->catalog_header.header_size, SEEK_SET ) != 0 )
      err = ECAT_SEEK ;
    while ( !fini && !err )
    {
      if ( fread( &tag, sizeof(TAG), 1, cat->catalog_stream ) == 1 )
      {
        if ( tag.type == TAG_IMAGE )
        {
          if ( fread( cat->item, sizeof(INDEX_RECORD), 1, cat->catalog_stream ) == 1 )
          {
            if (cat->item->name[0] == MARKED_DELETED) cat->catalog_header.nb_deleted++ ;
            else                                      cat->catalog_header.nb_records++ ;
            cat->item++ ;
          }
          else err = ECAT_READ ;
        }
        if ( tag.next_tag >= cat->catalog_header.header_size )
        {
          if ( fseek( cat->catalog_stream, tag.next_tag, SEEK_SET ) != 0 )
            err = ECAT_SEEK ;
        }
        else fini = 1 ;
      }
      else fini = 1 ;
      if ( !fini && !err )
      {
        nb++ ;
        fini = feof( cat->catalog_stream ) ;
        if ( cat->item >= last_item ) fini = 1 ;
      }
      (void)GWProgRange( wprog, nb, total, NULL ) ;
    }
  }

  return err ;
}

int load_catalog_header(CATALOG* cat, char *catalog_name, GEM_WINDOW* wprog)
{
  DTA  dta ;
  long total ;

  cat->catalog_stream = fopen( catalog_name, "rb+" ) ;
  if ( cat->catalog_stream == NULL ) cat->catalog_stream = fopen( catalog_name, "rb" ) ; /* CD-ROM ... */
  if ( cat->catalog_stream == NULL ) return( ECAT_FILENOTFOUND ) ;

  file_getinfo( catalog_name, &dta ) ;
  cat->cat_size = dta.d_length ;

  fread(&cat->catalog_header, sizeof(CATALOG_HEADER), 1, cat->catalog_stream) ;
  if (cat->catalog_header.version > CATALOG_VERSION)
  {
    fclose(cat->catalog_stream) ;
    cat->catalog_stream = NULL ;
    return ECAT_BADVERSION ;
  }
  else if (cat->catalog_header.version < CATALOG_VERSION)
  {
    fclose(cat->catalog_stream) ;
    cat->catalog_stream = NULL ;
    return ECAT_UPGRADEREQUIRED ;
  }

  cat->catalog_header.save_index = 1 ; /* Force index to be saved */
  rewind(cat->catalog_stream) ;
  if ( fread(&cat->catalog_header, cat->catalog_header.header_size, 1, cat->catalog_stream) != 1 )
    return ECAT_READ ;

  if (cat->tab_index != NULL) Xfree( cat->tab_index ) ;
  total       = cat->catalog_header.nb_records+cat->catalog_header.nb_deleted ;
  cat->max_records = ADD_RECORDS+(total/ADD_RECORDS)*ADD_RECORDS ;
  cat->max_records += ADD_RECORDS ; /* Par s‚curit‚ */
  cat->tab_index = Xcalloc( cat->max_records, cat->catalog_header.index_record_size ) ;
  if ( cat->tab_index == NULL )
  {
    fclose(cat->catalog_stream) ;
    cat->catalog_stream = NULL ;
    return( ECAT_NOMEMORY ) ;
  }

  memset(&cat->catalog_filter, 0xFF, sizeof(CATALOG_FILTER)) ;

  return( build_index( cat, wprog ) ) ;
}

void catalog_setrem(HCAT hCat, char *rem)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;

  if ( cat ) strncpy( cat->catalog_header.comment, rem, sizeof(cat->catalog_header.comment) ) ;
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

void vcd_infos(VCD_INFOS *vcd_infos, int nplanes, int wh)
{
  switch(nplanes)
  {
    case 1  : vcd_infos->vcd_data_size   = wh >> 3 ;                                   /* Raster       */
              vcd_infos->vcd_record_size = INFO_DATA_RECORD+vcd_infos->vcd_data_size ; /* +Commentaire */
              break ;
    case 2  : vcd_infos->vcd_data_size    = wh >> 2 ;                                   /* Raster       */
              vcd_infos->vcd_record_size  = INFO_DATA_RECORD+vcd_infos->vcd_data_size ; /* +Commentaire */
              vcd_infos->vcd_record_size += (1 << nplanes)*3 ;                          /* +Palette     */
              break ;
    case 4  : vcd_infos->vcd_data_size    = wh >> 1 ;                                   /* Raster       */
              vcd_infos->vcd_record_size  = INFO_DATA_RECORD+vcd_infos->vcd_data_size ; /* +Commentaire */
              vcd_infos->vcd_record_size += (1 << nplanes)*3 ;                          /* +Palette     */
              break ;
    case 8  : vcd_infos->vcd_data_size    = wh ;                                        /* Raster       */
              vcd_infos->vcd_record_size  = INFO_DATA_RECORD+vcd_infos->vcd_data_size ; /* +Commentaire */
              vcd_infos->vcd_record_size += (1 << nplanes)*3 ;                          /* +Palette     */
              break ;
    case 16 : vcd_infos->vcd_data_size   = wh << 1 ;                                    /* Raster       */
              vcd_infos->vcd_record_size = INFO_DATA_RECORD+vcd_infos->vcd_data_size ;  /* +Commentaire */
              break ;
  }
}

int std2catimgfmt(long lformat)
{
  if ( lformat == IID_IMG )   return F_IMG ;
  if ( lformat == IID_DEGAS ) return F_DEGAS ;
  if ( lformat == IID_ART )   return F_ART ;
  if ( lformat == IID_NEO )   return F_NEO ;
  if ( lformat == IID_MAC )   return F_MAC ;
  if ( lformat == IID_GIF )   return F_GIF ;
  if ( lformat == IID_TIFF )  return F_TIFF ;
  if ( lformat == IID_TARGA ) return F_TARGA ;
  if ( lformat == IID_JPEG )  return F_JPEG ;
  if ( lformat == IID_BMP )   return F_BMP ;
  if ( lformat == IID_PNG )   return F_PNG ;

  return F_UNKNOWN ;
}

int index_add(CATALOG* cat)
{
  int err = ECAT_NOERR ;

  cat->catalog_header.nb_records++ ;
  if (cat->catalog_header.nb_records+cat->catalog_header.nb_deleted >= cat->max_records)
  {
    INDEX_RECORD *new_index ;

    cat->max_records += ADD_RECORDS ;
    new_index = (INDEX_RECORD *) Xcalloc( cat->max_records, sizeof(INDEX_RECORD) ) ;
    if (new_index == NULL)
    {
      cat->catalog_header.nb_records-- ;
      cat->max_records -= ADD_RECORDS ;
      return( ECAT_NOMEMORY ) ;
    }
    memcpy(new_index, cat->tab_index, (cat->catalog_header.nb_records+cat->catalog_header.nb_deleted-1L)*sizeof(INDEX_RECORD)) ;
    Xfree(cat->tab_index) ;
    cat->tab_index = new_index ;
  }

  if ( fseek(cat->catalog_stream, 0L, SEEK_END) != 0 ) err = ECAT_SEEK ;
  /* ftell ne marche plus au dela d'une certaine taille */
  cat->catalog_inspos = cat->cat_size ;
  cat->item = &cat->tab_index[cat->catalog_header.nb_records+cat->catalog_header.nb_deleted-1] ;

  return err ;
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

  return np ;
}

int catalog_findplace(CATALOG* cat, int nplanes)
{
  int err = ECAT_NOERR ;
  int fini = 0 ;

  if ( cat->catalog_header.nb_deleted > 0 )
  {
    INDEX_RECORD *current, *last_item ;
    int          same_nbplanes ;

    same_nbplanes = stdplanes2pcat(nplanes) ;
    current       = cat->tab_index ;
    last_item     = current+cat->catalog_header.nb_records+cat->catalog_header.nb_deleted-1 ;
    while ( !fini && !err && ( current <= last_item ) )
    {
      if ((current->name[0] == MARKED_DELETED) && (current->nbplanes == same_nbplanes))
      {
        cat->catalog_inspos = current->offset-sizeof(TAG)-sizeof(INDEX_RECORD) ;
        if ( fseek( cat->catalog_stream, cat->catalog_inspos, SEEK_SET ) != 0 )
          err = ECAT_SEEK ;
        else
        {
          cat->item = current ;
          cat->catalog_header.nb_records++ ;
          cat->catalog_header.nb_deleted-- ;
          fini = 1 ;
        }
      }
      current++ ;
    }
  }
  else
  {
    /* On doit ajouter un nouvel ‚l‚ment d'index */

    err = index_add( cat ) ;
  }

  return err ;
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

int item_exist(CATALOG* cat, char *filename)
{
  INDEX_RECORD *current, *last_item ;
  int          exist = 0 ;
  char         name[20] ;
  char         buffer[INFO_DATA_RECORD] ;

  catname(name, filename) ;
  current   = cat->tab_index ;
  last_item = current+cat->catalog_header.nb_records+cat->catalog_header.nb_deleted-1 ;
  while (current <= last_item)
  {
    if (memcmp(current->name, name, 8) == 0)            /* Same short name ? */
    {
      fseek(cat->catalog_stream, current->offset, SEEK_SET) ; /* Then check physical filename */
      fread(buffer, INFO_DATA_RECORD, 1, cat->catalog_stream) ;
      if (strcmpi(buffer, filename) == 0)
      {
        exist = 1 ;
        cat->item  = current ;
        break ;
      }
    }
    current++ ;
  }

  return exist ;
}

size_t icon_size(CATALOG* cat, MFDB *img)
{
  size_t nb ;

  switch(img->fd_nplanes)
  {
    case  1 : nb = (cat->catalog_header.width*cat->catalog_header.height) >> 3 ;
              break ;
    case  2 : nb = (cat->catalog_header.width*cat->catalog_header.height) >> 2 ;
              break ;
    case  4 : nb = (cat->catalog_header.width*cat->catalog_header.height) >> 1 ;
              break ;
    case  8 : nb = cat->catalog_header.width*cat->catalog_header.height ;
              break ;
    default : nb = (cat->catalog_header.width*cat->catalog_header.height) << 1 ;
              break ;
  }

  return nb ;
}

void encrypt_datetime101(DTA *dta, INDEX_RECORD_101 *rec) /* Old one, useless to sort by date/time */
{
  rec->date_time = 7*dta->d_time+2*dta->d_date ;
}

void catalog_encrypt_datetime(DTA *dta, INDEX_RECORD *rec)
{
  rec->date_time = ((long)dta->d_date << 16) + dta->d_time ;
}

int catalog_setcatini(HCAT hCat, int cat_ini)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;

  if ( cat_ini )
  {
    if ( cat->IniCat ) CloseIni( cat->IniCat ) ;
    cat->IniCat = OpenIni( cat->catalog_header.cat_inifile ) ;
  }
  else if ( cat->IniCat )
  {
    CloseIni( cat->IniCat ) ;
    cat->IniCat = NULL ;
  }

  return( cat->IniCat != NULL ) ;
}

void get_categories(CATALOG* cat, char *filename, INDEX_RECORD *item)
{
  item->category_1 = cat->catalog_header.default_categorie ;
  item->category_2 = cat->catalog_header.default_categorie ;
  item->category_3 = cat->catalog_header.default_categorie ;
  if ( cat->IniCat )
  {
    int  i, index ;
    char section[30] ;
    char mask[128] ;
    char buf[50] ;
    char cont = 1 ;
    char found ;

    for ( i = 0; ( i < 50 ) && cont; i++ )
    {
      sprintf( section, "Look%d", i ) ;
      found = 0 ;
      if ( GetIniKey( cat->IniCat, section, "Path", mask ) )
        found = file_in_mask( filename, mask ) ;
      if ( found )
      {
        if ( GetIniKey( cat->IniCat, section, "Cat1", buf ) )
        {
          index = catalog_addcategory( (HCAT)cat, buf ) ;
          if ( index < MAX_CATEGORY ) item->category_1 = index ;
        }
        if ( GetIniKey( cat->IniCat, section, "Cat2", buf ) )
        {
          index = catalog_addcategory( (HCAT)cat, buf ) ;
          if ( index < MAX_CATEGORY ) item->category_2 = index ;
        }
        if ( GetIniKey( cat->IniCat, section, "Cat3", buf ) )
        {
          index = catalog_addcategory( (HCAT)cat, buf ) ;
          if ( index < MAX_CATEGORY ) item->category_3 = index ;
        }
        if ( GetIniKey( cat->IniCat, section, "Continue", buf ) ) cont = atoi( buf ) ;
        else                                                      cont = 0 ;
      }
    }
  }
}

int catalog_applyini(HCAT hCat, char* msg)
{
  CATALOG*      cat = HCAT2CATALOG( hCat ) ;
  GEM_WINDOW*   wprog ;
  INDEX_RECORD  orec, *rec ;
  long          i ;
  char          filename[PATH_MAX+16] ;

  if ( cat == NULL ) return -1 ;

  if ( cat->IniCat ) CloseIni( cat->IniCat ) ;
  cat->IniCat = OpenIni( cat->catalog_header.cat_inifile ) ;

  rec = cat->tab_index ;
  if ( rec == NULL ) return -1 ;
  wprog = DisplayStdProg( msg, "", "", CLOSER ) ;
  for ( i = 0; i < cat->catalog_header.nb_records+cat->catalog_header.nb_deleted; i++, rec++ )
  {
    catalog_getfullname( hCat, i, filename ) ;
    StdProgWText( wprog, 2, filename ) ;
    memcpy( &orec, rec, sizeof(INDEX_RECORD) ) ;
    get_categories( cat, filename, rec ) ;
    if ( memcmp( &orec, rec, sizeof(INDEX_RECORD) ) )
    {
      fseek( cat->catalog_stream, rec->offset-cat->catalog_header.index_record_size, SEEK_SET ) ;
      fwrite( rec, cat->catalog_header.index_record_size, 1, cat->catalog_stream ) ;
    }
    (void)GWProgRange( wprog, 1+i, cat->catalog_header.nb_records+cat->catalog_header.nb_deleted, NULL ) ;
  }
  GWDestroyWindow( wprog ) ;

  return 0 ;
}

int add_icon(CATALOG* cat, char *filename, INFO_IMAGE *inf, MFDB *icon)
{
  TAG           tag ;
  DTA           dta ;
  size_t        size_icon ;
  long          pos ;
  int           err = ECAT_NOERR ;
  char          info[INFO_DATA_RECORD] ;
  unsigned char cpal[3*256] ;
  char          ajout = 1 ;

  memzero( info, INFO_DATA_RECORD ) ;
  strcpy( info, filename ) ;
  if ( cat->catalog_stream == NULL ) return( ECAT_FILENOTFOUND ) ;
  err = catalog_findplace( cat, icon->fd_nplanes ) ;
  if ( err )  return( err ) ;

  pos = cat->catalog_inspos ;
  if ( pos != cat->cat_size )
    ajout = 0 ;

  size_icon    = icon_size(cat, icon) ;
  tag.type     = TAG_IMAGE ;
  tag.next_tag = pos+sizeof(TAG)+sizeof(INDEX_RECORD)+INFO_DATA_RECORD+size_icon ;

  memzero(cat->item, sizeof(INDEX_RECORD)) ;
  catname(cat->item->name, filename) ;
  cat->item->nbplanes   = stdplanes2pcat(icon->fd_nplanes) ;
  cat->item->format     = std2catimgfmt( inf->lformat ) ;

  get_categories( cat, filename, cat->item ) ;

  cat->item->offset     = pos+sizeof(TAG)+sizeof(INDEX_RECORD) ;
  file_getinfo(filename, &dta) ;
  catalog_encrypt_datetime(&dta, cat->item) ;

  if ( ( icon->fd_nplanes != 1 ) && ( icon->fd_nplanes != 16 ) )
  {
    compress_palette( inf, cpal ) ;
    tag.next_tag += 3L*(long)(1 << icon->fd_nplanes) ;
    fwrite(&tag, sizeof(TAG), 1, cat->catalog_stream) ;
    fwrite(cat->item, sizeof(INDEX_RECORD), 1, cat->catalog_stream) ;
    fwrite(info, 1, INFO_DATA_RECORD, cat->catalog_stream) ;
    fwrite(cpal, 3, 1 << icon->fd_nplanes, cat->catalog_stream) ;
    if ( ajout )
      cat->cat_size += sizeof(TAG)+sizeof(INDEX_RECORD)+INFO_DATA_RECORD+3*(1 << icon->fd_nplanes) ;
  }
  else
  {
    fwrite(&tag, sizeof(TAG), 1, cat->catalog_stream) ;
    fwrite(cat->item, sizeof(INDEX_RECORD), 1, cat->catalog_stream) ;
    fwrite(info, 1, INFO_DATA_RECORD, cat->catalog_stream) ;
    if ( ajout )
      cat->cat_size += sizeof(TAG)+sizeof(INDEX_RECORD)+INFO_DATA_RECORD ;
  }

  if ( fwrite(icon->fd_addr, size_icon, 1, cat->catalog_stream) != 1 )
    err = ECAT_WRITE ;

  if ( ajout )
    cat->cat_size += size_icon ;

  return err ;
}

int fit_vignet_into_icon(MFDB *in, MFDB *out)
{
  int xy[8] ;

  out->fd_wdwidth = w2wdwidth( out->fd_w ) ;
  out->fd_nplanes = in->fd_nplanes ;
  out->fd_stand   = in->fd_stand ;
  out->fd_addr    = img_alloc(out->fd_w, out->fd_h, out->fd_nplanes) ;
  if (out->fd_addr == NULL) return(-3) ;
  img_raz(out) ;

  xy[0] = xy[1] = 0 ;
  xy[2] = in->fd_w-1 ; xy[3] = in->fd_h-1 ;
  xy[4] = (out->fd_w-in->fd_w)>> 1 ;
  xy[5] = (out->fd_h-in->fd_h)>> 1 ;
  xy[6] = xy[4]+in->fd_w-1 ;
  xy[7] = xy[5]+in->fd_h-1 ;
  /* Fonction vro_cpyfm ‚tendue : cas o— en mode non TrueColor, on traite une image TrueColor    */
  /* De plus, NVDI (2.5) est incapable de traiter des rasters ayant un nombre de plans diff‚rent */
  /* De celui de la r‚solution de l'‚cran.                                                       */
/*  if ( ( cookie_find( "NVDI" ) && ( in->fd_nplanes != screen.fd_nplanes ) && ( in->fd_nplanes <= 8 ) ) ||
       ( Truecolor && (in->fd_nplanes <= 8) )
     )*/
/*  if ( !can_usevro( in->fd_nplanes ) && (in->fd_nplanes != 16) )*/
  if ( !can_usevro( in->fd_nplanes ) )
  {
    LoggingDo(LL_DEBUG, "fit_vignet_into_icon(%d,%d,%d,%d,%d,%d,%d,%d):smart_fit for nplanes=%d", xy[0], xy[1], xy[2], xy[3], xy[4], xy[5], xy[6], xy[7], in->fd_nplanes) ;
    smart_fit( in, out, xy ) ;
  }
  else
  {
    LoggingDo(LL_DEBUG, "fit_vignet_into_icon(%d,%d,%d,%d,%d,%d,%d,%d):xvro_cpyfm for nplanes=%d", xy[0], xy[1], xy[2], xy[3], xy[4], xy[5], xy[6], xy[7], in->fd_nplanes) ;
    xvro_cpyfm( handle, S_ONLY, xy, in, out ) ;
  }

  return 0 ;
}

void catalog_getfullname(HCAT hCat, long num_index, char *name)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;
  char     buffer[INFO_DATA_RECORD] ;

  if ( !cat ) return ;
  name[0] = 0 ;
  if ((cat->tab_index == NULL) || (num_index > cat->catalog_header.nb_records)) return ;

  fseek(cat->catalog_stream, cat->tab_index[num_index].offset, SEEK_SET) ;
  fread(buffer, INFO_DATA_RECORD, 1, cat->catalog_stream) ;
  strcpy(name, buffer) ;
  if (name[0]+'A' >= cat->catalog_header.shift_start) name[0] += cat->catalog_header.shift_value ;
}

static int icatalog_remove(CATALOG* cat, INDEX_RECORD* rec, int file)
{
  int err = 0 ;

  rec->name[0]  = MARKED_DELETED ;
  rec->selected = 0 ;
  fseek(cat->catalog_stream, rec->offset-sizeof(INDEX_RECORD), SEEK_SET) ;
  fwrite(rec, sizeof(INDEX_RECORD), 1, cat->catalog_stream) ;
  if ( file )
  {
    char name[INFO_DATA_RECORD] ;

    /* We are located at Info_Data_Record which starts with filename of image   */
    /* But better make sure as a fwrite/fread sequence behavior is undetermined */
    fseek(cat->catalog_stream, rec->offset, SEEK_SET) ;
    /* Copy/Paste from catalog_getfullname */
    fread( name, INFO_DATA_RECORD, 1, cat->catalog_stream ) ;
    if ( name[0]+'A' >= cat->catalog_header.shift_start) name[0] += cat->catalog_header.shift_value ;
    err = unlink( name ) ;
  }
  cat->catalog_header.nb_records-- ;
  cat->catalog_header.nb_deleted++ ;
  cat->save_changes = 1 ;

  return err ;
}

int catalog_remove(HCAT hCat, long index)
{
  CATALOG*  cat = HCAT2CATALOG( hCat ) ;
  int       err ;
  
  if ( !cat ) return -1 ;
  if ( (index < 0) || (index >= cat->catalog_header.nb_records+cat->catalog_header.nb_deleted) ||
       (cat->tab_index[index].name[0] == MARKED_DELETED) ) return -1 ;

  err = icatalog_remove( cat, &cat->tab_index[index], 0 ) ;

  catalog_sort_index( hCat ) ;

  return err ;
}

int catalog_removesel(HCAT hCat, int files, GEM_WINDOW* wprog)
{
  CATALOG*      cat = HCAT2CATALOG( hCat ) ;
  INDEX_RECORD* rec ;
  long          n, total ;

  if ( !cat ) return -1 ;
  rec = cat->tab_index ;
  if ( !rec ) return -1 ;

  total = cat->catalog_header.nb_records+cat->catalog_header.nb_deleted ;
  for ( n = 0; n < total; n++, rec++ )
  {
    if ( rec->selected )
    {
      char buf[10] ;

      icatalog_remove( cat, rec, files ) ;
      memcpy( buf, rec->name, 8 ) ;
      buf[8] = 0 ;
      (void)GWProgRange( wprog, 1+n, total, buf ) ;
    }
  }

  catalog_sort_index( hCat ) ;

  return 0 ;
}

long catalog_getnsel(HCAT hCat)
{
  CATALOG*      cat = HCAT2CATALOG( hCat ) ;
  INDEX_RECORD* rec ;
  long          n ;
  long          nsel = -1 ;

  if ( !cat ) return nsel ;
  rec = cat->tab_index ;
  if ( !rec ) return nsel ;

  nsel = 0 ;
  for ( n = 0; n < cat->catalog_header.nb_records+cat->catalog_header.nb_deleted; n++, rec++ )
    if ( rec->selected ) nsel++ ;

  return nsel ;
}

int catalog_add(HCAT hCat, char* filename, GEM_WINDOW* wprog)
{
  CATALOG*   cat = HCAT2CATALOG( hCat ) ;
  INFO_IMAGE inf ;
  MFDB*      img = &inf.mfdb ;
  MFDB       vignette, icon ;
  float      pcx, pcy ;
  int        err ;
  int        old_stdvdi = UseStdVDI ;

  LoggingDo(LL_INFO,"catalog_add: %s", filename);
  if ( cat == NULL ) return ECAT_FILENOTFOUND ;
  if ( item_exist( cat, filename ) ) return ECAT_ITEMEXIST ;

  inf.img_analyse = 1 ;
  inf.lformat     = IID_UNKNOWN ;
  err = img_format( filename, &inf ) ;
  if ( err )
  {
    free_info( &inf ) ;
    return err ;
  }

  inf.prog           = wprog ;
  img->fd_nplanes    = -1 ;
  inf.force_16b_load = 1 ;
  UseStdVDI          = 0 ;
  err                = load_picture( &inf ) ;
  if ( err )
  {
    UseStdVDI = old_stdvdi ;
    return err ;
  }

  pcx = (float)cat->catalog_header.width/(float)img->fd_w ;
  pcy = (float)cat->catalog_header.height/(float)img->fd_h ;
  if ( pcx > pcy ) pcx = pcy ;
  else             pcy = pcx ;

  ZeroMFDB( &vignette ) ;
  vignette.fd_w = (int) ( 0.5 + (float)img->fd_w * pcx ) ;
  vignette.fd_h = (int) ( 0.5 + (float)img->fd_h * pcy ) ;
  if ( RasterZoom( img, &vignette, NULL ) != 0 )
  {
    free_info( &inf ) ;
    UseStdVDI = old_stdvdi ;

    return ECAT_NOMEMORY ;
  }

  /* Centre la vignette dans l'icone */
  icon.fd_w = cat->catalog_header.width ;
  icon.fd_h = cat->catalog_header.height ;
  err = fit_vignet_into_icon( &vignette, &icon ) ;
  if ( err )
  {
    Xfree( vignette.fd_addr ) ;
    free_info( &inf ) ;
    UseStdVDI = old_stdvdi ;
  
    return ECAT_NOMEMORY ;
  }
  Xfree( vignette.fd_addr ) ;

  if ( icon.fd_nplanes <= 8 ) MakeMFDBClassicAtari( &icon, NULL ) ; /* Effectue si UseStdVDI = 1 */
  else if ( UseStdVDI ) tc_invconvert( &icon ) ;
  err = add_icon(cat, filename, &inf, &icon) ;
  Xfree(icon.fd_addr) ;
  free_info( &inf ) ;

  UseStdVDI         = old_stdvdi ;
  cat->save_changes = 1 ;
  catalog_sort_index(hCat) ;

  return err ;
}

int catalog_saveindex(CATALOG* cat)
{
  CATALOG_INDEX header ;
  FILE          *index_stream ;
  long          total ;
  int           len ;
  char          index_name[PATH_MAX] ;

  strcpy(index_name, cat->catalog_name) ;
  len = (int) strlen(index_name) ;
  index_name[len-1] = 'I' ;       /* .VIC -> .VII */
  index_stream = CreateFileR( index_name ) ;
  if (index_stream == NULL) return(0) ;

  memzero(&header, sizeof(CATALOG_INDEX)) ;
  fwrite(&header, sizeof(CATALOG_INDEX), 1, index_stream) ;
  cat->catalog_filter.show_all = 1 ;
  catalog_sort_index((HCAT)cat) ;
  total = cat->catalog_header.nb_records+cat->catalog_header.nb_deleted ;
  if ( fwrite(cat->tab_index, sizeof(INDEX_RECORD), total, index_stream) != total )
  {
    fclose(index_stream) ;
    return(0) ;
  }

  return( fclose(index_stream) == 0 ) ;
}

int catalog_close(HCAT hCat)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;

  if ( cat == NULL ) return -1 ;
  if ( cat->tab_index == NULL ) return -1 ;

  if ( cat->save_changes )
  {
    time_t    s ;
    struct tm n ;

    LoggingDo(LL_INFO, "Saving changes for catalog %s", cat->catalog_name ) ;
    rewind(cat->catalog_stream) ;
    time(&s) ;
    n=*localtime(&s) ;
    sprintf(cat->catalog_header.date, "%.2d/%.2d/%.4d", n.tm_mday, n.tm_mon+1, n.tm_year+1900) ;
    if ( cat->catalog_header.save_index )
    {
      LoggingDo(LL_INFO, "Saving index for catalog %s", cat->catalog_name ) ;
      cat->catalog_header.save_index = catalog_saveindex(cat) ;
    }
    fwrite(&cat->catalog_header, cat->catalog_header.header_size, 1, cat->catalog_stream) ;
  }
  fclose(cat->catalog_stream) ;
  Xfree(cat->tab_index) ;
  if ( cat->IniCat ) CloseIni( cat->IniCat ) ;
  LoggingDo(LL_INFO, "Catalog %s closed", cat->catalog_name ) ;
  free_catalog(cat) ;

  return 0 ;
}

/**********************************************************************/
/* Cr‚ation d'un nouveau catalogue                                    */
/* En retour :  0 : OK                                                */
/*             -1 : Impossible de cr‚er le r‚pertoire                 */
/*             -2 : Impossible de cr‚er les fichiers                  */
/*             -3 : M‚moire insuffisante                              */
/**********************************************************************/
HCAT catalog_new(char *access_path, char *cat_name, int* status)
{
  CATALOG*  cat = alloc_catalog() ;
  time_t    s ;
  struct tm n ;

  if ( !cat || !status )
  {
    if ( status ) *status = ECAT_NOMEMORY ;
    return NULL ;
  }

  sprintf( cat->catalog_name, "%s\\%s.VIC", access_path, cat_name ) ;
  cat->catalog_stream = CreateFileR( cat->catalog_name ) ;
  if (cat->catalog_stream == NULL)
  {
    *status = ECAT_FILENOTFOUND ;
    return NULL ;
  }

  init_catalog_header(cat, cat_name) ;
  fwrite(&cat->catalog_header, sizeof(CATALOG_HEADER), 1, cat->catalog_stream) ;
  cat->max_records = ADD_RECORDS ;
  cat->tab_index = Xcalloc(cat->max_records, sizeof(INDEX_RECORD)) ;
  if (cat->tab_index == NULL)
  {
    free_catalog(cat) ;
    *status = ECAT_NOMEMORY ;
    return NULL ;
  }

  time(&s) ;
  n=*localtime(&s) ;
  sprintf(cat->catalog_header.date, "%.2d/%.2d/%.4d", n.tm_mday, n.tm_mon+1, n.tm_year+1900) ;
  cat->save_changes = 1 ;
  cat->cat_size     = sizeof(CATALOG_HEADER) ;

  *status = ECAT_NOERR ;
  return (HCAT)cat ;
}

/**********************************************************************/
/* Ouverture d'un nouveau catalogue                                   */
/* En retour :  0 : OK                                                */
/*             -1 : Catalogue introuvable                             */
/*             -2 : Mauvaise version                                  */
/*             -3 : M‚moire insuffisante                              */
/**********************************************************************/
HCAT catalog_open(char *cat_name, GEM_WINDOW* wprog, int* status)
{
  CATALOG* cat = alloc_catalog() ;

  if ( !cat || !status )
  {
    if ( status ) *status = ECAT_NOMEMORY ;
    return NULL ;
  }

  strcpy(cat->catalog_name, cat_name) ;

  mouse_busy() ;
  *status = load_catalog_header(cat, cat->catalog_name, wprog) ;
  if (*status)
  {
    free_catalog( cat ) ;
    mouse_restore() ;
    return NULL ;
  }

  catalog_sort_index((HCAT)cat) ;
  mouse_restore() ;

  LoggingDo(LL_INFO, "Catalog %s loaded", cat->catalog_name) ;
  
  *status = ECAT_NOERR ;
  return (HCAT)cat ;
}

void catalog_getstdinfos(HCAT hCat, long ind, char *nom, char *fmt, char *nplanes)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;

  if (!cat || (cat->tab_index == NULL) || (ind < 0) || (ind >= cat->catalog_header.nb_records+cat->catalog_header.nb_deleted) || !cat->tab_index[ind].is_visible)
  {
    strcpy(nom, "        ") ;
    strcpy(fmt, "     ") ;
    strcpy(nplanes, "    ") ;
  }
  else
  {
    INDEX_RECORD* pt ;

    pt = &cat->tab_index[ind] ;
    if (nom)
    {
      memzero(nom, 9) ;
      memcpy(nom, pt->name, 8) ;
    }
    if (fmt) strcpy(fmt, std_fmt[pt->format]) ;
    if ( nplanes) strcpy(nplanes, std_colors[pt->nbplanes]) ;
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
int catalog_ncloadicon(CATALOG* cat, long index, MFDB *out, INFO_IMAGE *inf, char *comment)
{
  VCD_INFOS     vcd ;
  int           nplanes, err ;
  unsigned char cpal[3*256] ;

  err = ECAT_NOERR ;
  comment[0] = 0 ;
  ZeroMFDB( out ) ;
  memzero(inf, sizeof(INFO_IMAGE)) ;
  if ((index >= cat->catalog_header.nb_records+cat->catalog_header.nb_deleted) ||
      (cat->tab_index[index].name[0] == MARKED_DELETED) ||
      (index >= cat->catalog_filter.nb_visibles) )
    return ECAT_BADINDEX ;

  nplanes = spec2stdplanes[cat->tab_index[index].nbplanes] ;
  vcd_infos(&vcd, nplanes, cat->catalog_header.width*cat->catalog_header.height) ;
  out->fd_w       = cat->catalog_header.width ;
  out->fd_h       = cat->catalog_header.height ;
  out->fd_wdwidth = w2wdwidth( out->fd_w ) ;
  out->fd_nplanes = nplanes ;
  out->fd_stand   = 0 ;
  out->fd_addr    = img_alloc(out->fd_w, out->fd_h, nplanes) ;
  if ( out->fd_addr == NULL ) return ECAT_NOMEMORY ;

  if ( fseek(cat->catalog_stream, cat->tab_index[index].offset+PATH_MAX, SEEK_SET) != 0 ) 
    err = ECAT_SEEK ;
  else
    fread( comment, SIZE_COMMENT, 1, cat->catalog_stream ) ;

  if ( ( nplanes <= 8 ) && ( nplanes > 1 ) )
  {
    inf->nb_cpal = 1 << out->fd_nplanes ;
    inf->palette = Xalloc( 6*inf->nb_cpal ) ;
    if (inf->palette == NULL)
    {
      Xfree(out->fd_addr) ;
      return ECAT_NOMEMORY ;
    }
    if ( fseek(cat->catalog_stream, cat->tab_index[index].offset+INFO_DATA_RECORD, SEEK_SET) != 0 )
      err = ECAT_SEEK ;
    else
    {
      fread( cpal, 3, inf->nb_cpal, cat->catalog_stream ) ;
      decompress_palette( cpal, nplanes, inf->palette ) ;
    }
  }
  else if ( fseek(cat->catalog_stream, cat->tab_index[index].offset+vcd.vcd_record_size-vcd.vcd_data_size, SEEK_SET) != 0 )
    err = ECAT_SEEK ;

  fread(out->fd_addr, vcd.vcd_data_size, 1, cat->catalog_stream) ;

  return err ;
}

int catalog_loadicon(HCAT hCat, long index, INFO_IMAGE* inf, char* comment)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;
  MFDB*    out = &inf->mfdb ;
  int      err ;
  int      cancel_stdvdi = 0 ;

  if ( !cat ) return -1 ;
  err = catalog_ncloadicon( cat, index, out, inf, comment ) ;
  if ( err != ECAT_NOERR ) return( err ) ;

  if ( out->fd_nplanes < screen.fd_nplanes )
  {
    MFDB virtuel ;

    CopyMFDB( &virtuel, out ) ;
    virtuel.fd_nplanes = screen.fd_nplanes ;
    if ( Truecolor && (out->fd_nplanes <= 8) )
    {
      LoggingDo(LL_DEBUG, "catalog_loadicon, calling index2truecolor, fd_nplanes=%d, %ld palette colors, palette=%p", out->fd_nplanes, inf->nb_cpal, inf->palette) ;
      err = index2truecolor( out, inf, &virtuel, NULL ) ;
      Xfree(out->fd_addr) ;
      CopyMFDB( out, &virtuel ) ;
    }
    if ( Truecolor && ( out->fd_nplanes == 16 ) )
    {
      unsigned char* bufferc ;
      unsigned long* bufferl ;

      switch( screen.fd_nplanes )
      {
        case 16 : 
                  break ;
        case 24 : bufferc = (unsigned char *) Xalloc( 3L*(long)out->fd_w*(long)out->fd_h ) ;
                  if ( bufferc != NULL )
                  {
                    tc16to24( out->fd_addr, bufferc, (long)out->fd_w*(long)out->fd_h ) ;
                    Xfree( out->fd_addr ) ;
                    out->fd_addr = bufferc ;
                    out->fd_nplanes = screen.fd_nplanes ;
                  }
                  else err = ECAT_NOMEMORY ;
                  break ;
        case 32 : bufferl = (unsigned long *) Xalloc( 4L*(long)out->fd_w*(long)out->fd_h ) ;
                  if ( bufferl != NULL )
                  {
                    tc16to32( out->fd_addr, bufferl, (long)out->fd_w*(long)out->fd_h ) ;
                    Xfree( out->fd_addr ) ;
                    out->fd_addr = bufferl ;
                    out->fd_nplanes = screen.fd_nplanes ;
                  }
                  else err = ECAT_NOMEMORY ;
                  break ;
      }
    }
    else
    {
      LoggingDo(LL_DEBUG, "catalog_loadicon, calling incnbplanes") ;
      err = incnbplanes( out, screen.fd_nplanes, &cancel_stdvdi ) ;
    }
  }
  else if ( out->fd_nplanes > screen.fd_nplanes )
  {
    INFO_IMAGE inf2 ;

    CopyMFDB( &inf2.mfdb, out ) ;
    inf2.mfdb.fd_nplanes = screen.fd_nplanes ;
    err = dither( DITHER_AUTO, inf, &inf2, NULL ) ;
    if ( err == EIMG_SUCCESS )
    {
      Xfree(out->fd_addr) ;
      if ( inf->palette ) Xfree( inf->palette ) ;
      memcpy( inf, &inf2, sizeof(INFO_IMAGE) ) ;
    }
    else
    {
      Xfree(out->fd_addr) ;
      out->fd_addr = img_alloc(out->fd_w, out->fd_h, screen.fd_nplanes) ;
      if (out->fd_addr != NULL) img_raz(out) ;
      else                      err = ECAT_NOMEMORY ;
    }
  }

  if ( err == ECAT_NOERR )
  {
    if ( UseStdVDI && !cancel_stdvdi )
    {
      if ( screen.fd_nplanes <= 8 )
      {
        MFDB std_img ;

        CopyMFDB( &std_img, out ) ;
        std_img.fd_addr = img_alloc(std_img.fd_w, std_img.fd_h, std_img.fd_nplanes) ;
        if (std_img.fd_addr != NULL)
        {
          std_img.fd_stand = 1 ;
          ClassicAtari2StdVDI(out, &std_img) ;
          vr_trnfm(handle, &std_img, out) ;
          Xfree(std_img.fd_addr) ;
        }
        else err = ECAT_NOMEMORY ;
      }
      else tc_convert( out ) ;
    }
 }

  return err ;
}

void catalog_stats(HCAT hCat, CATALOG_STATS *stats)
{
  CATALOG*      cat = HCAT2CATALOG( hCat ) ;
  INDEX_RECORD* rec ;
  long          i, s1p, s2p, s4p, s8p, stc ;
  char          *c, *cp ;

  if ( !cat ) return ;
  memzero(stats, sizeof(CATALOG_STATS)) ;
  cp = strrchr(cat->catalog_name, '.') ;
  if ( cp ) *cp = 0 ; /* Remove extension */
  c = strrchr(cat->catalog_name, '\\') ;
  if (c != NULL) strcpy(stats->name, ++c) ;
  if ( cp ) *cp = '.' ; /* Restore extension */
  memcpy(stats->comment, cat->catalog_header.comment, 80) ;
  stats->nb_records = cat->catalog_header.nb_records ;
  stats->nb_deleted = cat->catalog_header.nb_deleted ;
  strcpy(stats->date, cat->catalog_header.date) ;

  stats->nb_1plane = stats->nb_2plane = stats->nb_4plane = stats->nb_8plane = stats->nb_tc   = 0L ;
  stats->size_1p   = stats->size_2p   = stats->size_4p   = stats->size_8p   = stats->size_tc = 0L ;
  rec = cat->tab_index ;
  s1p = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(cat->catalog_header.width, cat->catalog_header.height, 1) ;
  s2p = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(cat->catalog_header.width, cat->catalog_header.height, 2)+(long)(4*3) ;
  s4p = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(cat->catalog_header.width, cat->catalog_header.height, 4)+(long)(16*3) ;
  s8p = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(cat->catalog_header.width, cat->catalog_header.height, 8)+(long)(256*3) ;
  stc = sizeof(INDEX_RECORD)+INFO_DATA_RECORD+img_size(cat->catalog_header.width, cat->catalog_header.height, 16) ;
  for (i = 0; i < cat->catalog_header.nb_records+cat->catalog_header.nb_deleted; i++)
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

int catalog_addcategory(HCAT hCat, char *category)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;
  int      i = 0 ;
  int      found = 0 ;

  if ( !cat ) return -1 ;
  category[CATEGORY_SIZE-1] = 0 ;
  while ( !found && ( i < MAX_CATEGORY ) )
  {
    if ( strcmpi( category, cat->catalog_header.category_names[i] ) == 0 ) found = 1 ;
    else
    {
      if ( cat->catalog_header.category_names[i][0] ) i++ ;
      else                                            found = 1 ;
    }
  }
  if ( found ) strcpy( cat->catalog_header.category_names[i], category ) ;

  cat->save_changes = 1 ;

  return i ;
}

void catalog_setimgcomment(HCAT hCat, long index, char *comment)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;
  long     len = strlen(comment) ;

  if ( !cat || !cat->tab_index ) return ;
  if ((index < 0) || (index >= cat->catalog_header.nb_records+cat->catalog_header.nb_deleted)) return ;

  if (len >= SIZE_COMMENT-1) comment[SIZE_COMMENT-1] = 0 ;
  fseek(cat->catalog_stream, cat->tab_index[index].offset+PATH_MAX, SEEK_SET) ;
  fwrite(comment, 1+strlen(comment), 1, cat->catalog_stream) ;
}

void catalog_getimgcomment(HCAT hCat, long index, char *comment)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;

  if ( comment ) *comment = 0 ;
  if ( !cat || !cat->tab_index ) return ;
  if ((index < 0) || (index >= cat->catalog_header.nb_records+cat->catalog_header.nb_deleted)) return ;

  fseek(cat->catalog_stream, cat->tab_index[index].offset+PATH_MAX, SEEK_SET) ;
  if ( comment) fread(comment, SIZE_COMMENT, 1, cat->catalog_stream) ;
}

int catalog_setcategory(HCAT hCat, long index, int category_id, int category_no)
{
  CATALOG* cat = HCAT2CATALOG( hCat ) ;
  int      err = ECAT_NOERR ;

  if (!cat || (index < 0) || (index >= cat->catalog_header.nb_records+cat->catalog_header.nb_deleted)) return( ECAT_BADINDEX ) ;

  switch(category_no)
  {
    case 1 : if (category_id != cat->tab_index[index].category_1)
             {
               cat->tab_index[index].category_1 = category_id ;
               if (cat->tab_index[index].category_2 == CATEGORY_DIVERS) cat->tab_index[index].category_2 = category_id ;
               if (cat->tab_index[index].category_3 == CATEGORY_DIVERS) cat->tab_index[index].category_3 = category_id ;
               if ( fseek(cat->catalog_stream, cat->tab_index[index].offset-sizeof(INDEX_RECORD), SEEK_SET) != 0 )
                 err = ECAT_SEEK ;
               else
                 fwrite(&cat->tab_index[index], sizeof(INDEX_RECORD), 1, cat->catalog_stream) ;
             }
             break ;
    case 2 : if (category_id != cat->tab_index[index].category_2)
             {
               cat->tab_index[index].category_2 = category_id ;
               if (cat->tab_index[index].category_3 == CATEGORY_DIVERS) cat->tab_index[index].category_3 = category_id ;
               if ( fseek(cat->catalog_stream, cat->tab_index[index].offset-sizeof(INDEX_RECORD), SEEK_SET) != 0 )
                 err = ECAT_SEEK ;
               else
                 fwrite(&cat->tab_index[index], sizeof(INDEX_RECORD), 1, cat->catalog_stream) ;
             }
             break ;
    case 3 : if (category_id != cat->tab_index[index].category_3)
             {
               cat->tab_index[index].category_3 = category_id ;
               if ( fseek(cat->catalog_stream, cat->tab_index[index].offset-sizeof(INDEX_RECORD), SEEK_SET) != 0 )
                 err = ECAT_SEEK ;
               else
                 fwrite(&cat->tab_index[index], sizeof(INDEX_RECORD), 1, cat->catalog_stream) ;
             }
             break ;
  }
  cat->save_changes = 1 ;

  return err ;
}

void catalog_update(HCAT hCat, char *text)
{
  CATALOG*     cat = HCAT2CATALOG( hCat ) ;
  GEM_WINDOW   *wprog ;
  INDEX_RECORD inf, *rec ; 
  DTA          dta ;
  long         i ;
  int          exist ;
  int          c1, c2, c3 ;
  char         filename[PATH_MAX+16] ;

  if ( !cat ) return ;
  rec = cat->tab_index ;
  if ( rec == NULL ) return ;
  wprog = DisplayStdProg( text, "", "", CLOSER ) ;
  for ( i = 0; i < cat->catalog_header.nb_records+cat->catalog_header.nb_deleted; i++ )
  {
    if ( rec->name[0] != MARKED_DELETED )
    {
      catalog_getfullname( hCat, i, filename ) ;
      StdProgWText( wprog, 2, filename ) ;
      exist = ( file_getinfo(filename, &dta) == 0 ) ;
      if ( !exist )
      {
        catalog_remove( hCat, i-- ) ;
        rec-- ;
      }
      else
      {
        catalog_encrypt_datetime( &dta, &inf ) ;
        if ( inf.date_time != rec->date_time )
        {
          c1 = rec->category_1 ;
          c2 = rec->category_2 ;
          c3 = rec->category_3 ;
          catalog_remove( hCat, i ) ;
          catalog_add( hCat, filename, NULL ) ;
          if ( item_exist( cat, filename ) )
          {
            cat->item->category_1 = c1 ;
            cat->item->category_2 = c2 ;
            cat->item->category_3 = c3 ;
            fseek( cat->catalog_stream, cat->item->offset-cat->catalog_header.index_record_size, SEEK_SET ) ;
            fwrite( cat->item, cat->catalog_header.index_record_size, 1, cat->catalog_stream ) ;
          }
        }
      }
    }
    (void)GWProgRange( wprog, 1+i, cat->catalog_header.nb_records+cat->catalog_header.nb_deleted, NULL ) ;
    rec++ ;
  }
  GWDestroyWindow( wprog ) ;
}

void GetTxtCategories(CATALOG* cat, long num, char *buf)
{
  INDEX_RECORD* r ;
  char          buffer[80] ;

  r = &cat->tab_index[num] ;
  memzero( buffer, sizeof(buffer) ) ;
  memcpy( buffer, r->name, sizeof(r->name) ) ;
  sprintf(buf, "%s, %s", buffer,  cat->catalog_header.category_names[r->category_1]) ;
  if (r->category_2 != r->category_1)
  {
    sprintf(buffer, ", %s",  cat->catalog_header.category_names[r->category_2]) ;
    strcat(buf, buffer) ;
  }

  if ((r->category_3 != r->category_2) && (r->category_3 != r->category_1))
  {
    sprintf(buffer, ", %s",  cat->catalog_header.category_names[r->category_3]) ;
    strcat(buf, buffer) ;
  }
}

int ConvImg(char *file, char *dest_path, char *out_name)
{
  INFO_IMAGE inf_conv ;
  MFDB*      mfdb_conv = &inf_conv.mfdb ;
  int        err ;
  char       *point, *slash ;
  char       ext[10], name[40] ;
  char       name_out[PATH_MAX] ;

  get_ext( file, ext ) ;
  point = strrchr( file, '.' ) ;
  if ( point )
  {
    *point = 0 ;
    slash = strrchr( file, '\\' ) ;
    if ( slash ) *slash = 0 ;
    else         slash = file ;
    strcpy( name, 1+ slash ) ;
    *slash = '\\' ;
    *point = '.' ;
  }
  else strcpy( name, file ) ;

  if ( strcmpi( ext, "gif" ) && strcmpi( ext, "jpg" ) && strcmpi( ext, "jpeg" ) )
  {
    IMG_MODULE* img_module = NULL ;

    /* Conversion vers GIF ou JPEG */
    inf_conv.lformat = IID_UNKNOWN ;
    err = img_format( file, &inf_conv ) ;
    mfdb_conv->fd_nplanes = -1 ; /* Conserver le nombre de plans */
    if ( !err ) err = load_picture( &inf_conv ) ;
    if ( !err )
    {
      if ( mfdb_conv->fd_nplanes > 8 ) inf_conv.lformat = IID_JPEG ;
      else                             inf_conv.lformat = IID_GIF ;
      inf_conv.c.f.jpg.quality     = 75 ;
      inf_conv.c.f.jpg.progressive = 0 ;
      inf_conv.nplanes             = mfdb_conv->fd_nplanes ;
      img_module = DImgGetModuleFromIID( inf_conv.lformat ) ;
      if ( img_module )
      {
        sprintf( name_out, "%s\\%s.%s", dest_path, name, img_module->Capabilities.file_extension ) ;
        err = save_picture( name_out, mfdb_conv, &inf_conv, NULL ) ;
      }
      else err = -5 ;
    }
    free_info( &inf_conv ) ;
    if ( !err && img_module ) sprintf( out_name, "%s.%s", name, img_module->Capabilities.file_extension ) ;
  }
  else
  {
    sprintf( name_out, "%s\\%s.%s", dest_path, name, ext ) ;
    err = CopyFile( file, name_out ) ;
    if ( !err ) sprintf( out_name, "%s.%s", name, ext ) ;
  }

  return err ;
}

FILE *create_ehtml(CHTML_EXPORT *exp)
{
  FILE *stream ;
  char buf[PATH_MAX] ;

  exp->num++ ;
  sprintf( buf, "%s\\%s%d.HTM", exp->path, exp->base_name, exp->num ) ;

  stream = CreateFileR( buf ) ;
  if ( stream == NULL ) return( stream ) ;
  
  fprintf( stream,
  "<html>\r\n\
   <head>\r\n\
   <meta http-equiv=\"Content-Type\"\r\n\
   content=""text/html; charset=iso-8859-1"">\r\n\
   <meta name=\"GENERATOR\" content=\"%s\">\r\n\
   <title>%s</title>\r\n\
   </head>\r\n\
   <body bgcolor=\"#%02X%02X%02X\"",
   exp->app_name, exp->page_title, exp->back_color[0], exp->back_color[1], exp->back_color[2] ) ;

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

  return stream ;
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

  fclose( stream ) ;
}

int catalog_ehtml(CHTML_EXPORT *exp, GEM_WINDOW* wprog)
{
  CATALOG*   cat = HCAT2CATALOG( exp->hCat ) ;
  MFDB       vignette ;
  INFO_IMAGE inf_img ;
  FILE       *stream ;
  long       num ;
  int        wpc ;
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

  if ( !cat ) return -1 ;
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
    ZeroMFDB( &vignette ) ;
    memzero( &inf_img, sizeof(INFO_IMAGE) ) ;
    if ( catalog_ncloadicon( cat, num, &vignette, &inf_img, comment ) == ECAT_NOERR )
    {
      inf_img.c.f.jpg.quality     = 75 ;
      inf_img.c.f.jpg.progressive = 0 ;
      catalog_getfullname( exp->hCat, num, full_name ) ;
      slash = strrchr( full_name, '\\' ) ;
      if ( slash )
      {
        long lfmt ;

        if ( vignette.fd_nplanes > 8 ) { strcpy( ext, ".JPG" ) ; lfmt = IID_JPEG ; }
        else                           { strcpy( ext, ".GIF" ) ; lfmt = IID_GIF ; }
        sprintf( name, "%s\\mini\\%s", exp->path, 1 + slash ) ;
        point = strrchr( name, '.' ) ;
        if ( point ) *point = 0 ;
        strcat( name, ext ) ; /* Force l'extension */
        sprintf( buf, "... %s ...", 1 + slash ) ;
        StdProgWText( wprog, 1, buf ) ;
        inf_img.lformat = lfmt ;
        if ( FileExist( name ) ) sprintf( name, "%s\\mini\\_V%04d_%s", exp->path, name_conflict++, ext ) ;
        err = save_picture( name, &vignette, &inf_img, NULL ) ;
        if ( !err )
        {
          link_img = exp->flags & EH_LINKIMG ;
          if ( link_img )
          {
            sprintf( buf, "%s\\images", exp->path ) ;
            link_img = ( ConvImg( full_name, buf, buf ) == 0 ) ;
            if ( link_img ) fprintf( stream, "<a href=\"images/%s\">", buf ) ;
          }
          GetTxtCategories( cat, num, buf ) ;
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

    if ( inf_img.palette ) Xfree( inf_img.palette ) ;
    if ( vignette.fd_addr ) Xfree( vignette.fd_addr ) ;

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
    cancel = PROG_CANCEL_CODE( GWProgRange( wprog, num - exp->first, exp->last - exp->first, NULL ) ) ;
  }

  if ( stream ) close_ehtml( stream, exp ) ;

  UseStdVDI = old_stdvdi ;
  mouse_restore() ;

  return err ;
}

int migrate_from0101(FILE* in, size_t in_size, CATALOG_HEADER* ch, char* cat_name, GEM_WINDOW* wprog)
{
  FILE*  out ;
  TAG    tag ;
  size_t pos = sizeof(CATALOG_HEADER) ;
  size_t opos = sizeof(CATALOG_HEADER) ;
  char*  record_buffer ; /* Max record holding TAG, INDEX_RECORD, Info_Data_Record, palette, raster */
  long   total ;
  long   nb = 0 ;
  int    done = 0 ;
  int    err = 0 ;

  if ( ch->version != 0x0101 ) return ECAT_BADVERSION ;

  record_buffer = Xalloc( sizeof(TAG) + sizeof(INDEX_RECORD) + INFO_DATA_RECORD + (6*256) + img_size(ch->width, ch->height, 16) ) ;
  if ( record_buffer == NULL ) return ECAT_NOMEMORY ;

  out = CreateFileR( cat_name ) ;
  /* Version without date/time in INDEX_RECORD */
  if ( !out )
  {
    Xfree( record_buffer ) ;
    return ECAT_FILENOTFOUND ;
  }

  total = ch->nb_deleted + ch->nb_records ;
  /* Write header */
  ch->version           = CATALOG_VERSION ;
  ch->index_record_size = (int) sizeof(INDEX_RECORD) ;
  if ( fwrite( ch, ch->header_size, 1, out ) != 1 ) err = ECAT_WRITE ;

  LoggingDo(LL_INFO, "Catalog upgrade might take a while; will update regularly...") ;
  /* Update contents with new INDEX_RECORD */
  while ( !done && !err )
  {
    LoggingDo(LL_DEBUG, "Upgrading record at offset %ld...", pos) ;
    if ( fread( &tag, sizeof(TAG), 1, in ) == 1 )
    {
      memcpy( record_buffer, &tag, sizeof(TAG) ) ;
      if ( fread( &record_buffer[sizeof(TAG)], tag.next_tag-pos-sizeof(TAG), 1, in ) == 1 )
      {
        if ( tag.type == TAG_IMAGE )
        {
          TAG*          otag = (TAG*) &record_buffer[0] ;
          INDEX_RECORD* ir = (INDEX_RECORD*) &record_buffer[sizeof(TAG)] ;
          char*         fname ;
          DTA           dta ;
          long          o101, o, len ;

          o101 = sizeof(TAG)+sizeof(INDEX_RECORD_101) ;
          o    = sizeof(TAG)+sizeof(INDEX_RECORD) ;
          len  = tag.next_tag - pos - sizeof(TAG) - sizeof(INDEX_RECORD_101) + o - o101 ;
          memmove( &record_buffer[o], &record_buffer[o101], len ) ; /* Move data after INDEX_RECORD101 after INDEX_RECORD */
          fname = &record_buffer[sizeof(TAG)+sizeof(INDEX_RECORD)] ; /* filename is there now */
          /* Update INDEX_RECORD accoding to changes */
          ir->rfu_1 = 0 ; /* Reset old room for date_time */
          ir->date_time = 0 ; /* In case file does not exist */
          ir->offset = opos + sizeof(TAG) + sizeof(INDEX_RECORD) ; /* Update offset field */
          if ( file_getinfo(fname, &dta) == 0 ) catalog_encrypt_datetime( &dta, ir ) ; /* And set real date/time */
          else
          {
            LoggingDo(LL_WARNING, "Image file %s not found, marking it as deleted", fname) ;
            ir->name[0] = MARKED_DELETED ;
          }
          opos += sizeof(TAG) + sizeof(INDEX_RECORD) + len ; /* Update next offset location as we increased record size */
          otag->next_tag = opos ;
			    if ( fwrite( record_buffer, sizeof(TAG)+sizeof(INDEX_RECORD)+len, 1, out ) != 1 ) err = ECAT_WRITE ;
			    nb++ ;
        }
        if ( tag.next_tag >= ch->header_size )
        {
          if ( fseek( in, tag.next_tag, SEEK_SET ) != 0 ) err = ECAT_SEEK ;
			    else                                            pos = tag.next_tag ;
        }
        else done = 1 ;
      }
      else err = ECAT_READ ;
    }
		else err = ECAT_READ ;
    if ( err && ( pos == in_size ) )
    {
      done = 1 ;
      err  = 0 ;
      LoggingDo(LL_INFO, "Catalog has been successfully parsed") ;
    }
    (void)GWProgRange( wprog, nb, total, NULL ) ;
  }
  fclose( out ) ;
  Xfree( record_buffer ) ;

  return err ;
}

int catalog_upgrade(char *cat_name, GEM_WINDOW* wprog)
{
  char rcat_name[PATH_MAX] ;
  int  err ;

  cat_name[strlen(cat_name)-1] = 'I' ;   /* Change .VIC to .VII */
  strcpy( rcat_name, cat_name)  ;
  rcat_name[strlen(rcat_name)-3] = '_' ; /* Change VII extension to _II */
  MoveFile( cat_name, rcat_name ) ;      /* Don't care about error as index file may not be there */
  cat_name[strlen(cat_name)-1] = 'C' ;   /* Change back to .VIC */
  strcpy( rcat_name, cat_name)  ;
  rcat_name[strlen(rcat_name)-3] = '_' ; /* Change VIC extension to _IC */
  err = MoveFile( cat_name, rcat_name ) ;
  if ( err == 0 )
  {
    CATALOG_HEADER ch ;
    FILE*          in ;
    size_t         in_size = file_size( rcat_name ) ;

	  in = fopen( rcat_name, "rb" ) ;
    if ( in == NULL ) return( ECAT_FILENOTFOUND ) ;
    fread( &ch, sizeof(CATALOG_HEADER), 1, in ) ;
    if ( ch.version >= CATALOG_VERSION )
	  {
	    fclose( in ) ;
	    MoveFile( rcat_name, cat_name ) ;
	    return ECAT_NOERR ;
	  }

    switch( ch.version )
    {
      case 0x0101: mouse_busy() ;
                   err = migrate_from0101( in, in_size, &ch, cat_name, wprog ) ;
                   mouse_restore() ;
                   break ;
      default:     LoggingDo(LL_WARNING, "Unknown version to upgrade: %x", ch.version) ;
                   err = ECAT_BADVERSION ;
                   break ;
    }

    fclose( in ) ;
  }

  if ( err )
  {
    /* Restore original file */
    unlink( cat_name ) ;
    MoveFile( rcat_name, cat_name ) ;
  }

  return err ;
}
