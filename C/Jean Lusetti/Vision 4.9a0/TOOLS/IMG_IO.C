/****************************/
/*-------- IMG_IO.C --------*/
/* Chargement et sauvegarde */
/* D'images au format IMG   */
/****************************/
#include <stdlib.h>
#include <string.h>

#include     "..\tools\xgem.h"
#include "..\tools\packbits.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"



typedef struct
{
  int version ;       /* Version du format IMG           */
  int header_length ; /* Taille du header en mots        */
  int nplanes ;       /* Nombre de plans de l'image      */
  int pattern_run ;   /* Taille du pattern_run en octets */
  int widthm ;        /* Largeur d'un pixel en microns   */
  int heigthm ;       /* Hauteur du pixel en microns     */
  int pixel_line ;    /* Nombre de pixels par ligne      */
  int nb_line ;       /* Nombre de lignes de l'image     */
}
IMG_HEADER ;


/* Structure shared with assembly routine img_dcmps */
typedef struct _IMGS_STR
{
  void* adr_src ;   /* Source address                  */
  void* adr_dest ;  /* Destination address             */
  int   nb_plan ;   /* Number of planes                */
  int   octet_run ; /* Number of bytes for pattern run */
  int   nb_pixel ;  /* Number of piwels per line       */
  int   nb_ligne ;  /* Number of lines                 */
  int   mot_larg ;  /* Number of words per line        */
}
IMGS_STR, *PIMGS_STR ;

extern void img_dcmps(IMGS_STR* data) ;


int img_identify(char *nom, INFO_IMAGE *inf)
{
  IMG_HEADER* header ;
  int         ret ;

  ret = ImgFOpen( inf, nom, &inf->file_size ) ;
  if ( ret != EIMG_SUCCESS ) return ret ;

  inf->specific = Xalloc( sizeof(IMG_HEADER) ) ;
  header = (IMG_HEADER*) inf->specific ;
  if ( header == NULL )
  {
    free_info( inf ) ;
    return EIMG_NOMEMORY ;
  }

  ImgFRead( inf, header, sizeof(IMG_HEADER) ) ;

  inf->compress = 1 ;
  inf->width    = header->pixel_line ;
  inf->height   = header->nb_line ;
  inf->nplanes  = header->nplanes ;
  if (inf->nplanes > 8)
  {
    free_info( inf ) ;
    return EIMG_OPTIONNOTSUPPORTED ;
  }
  inf->lpix     = header->widthm ;
  inf->hpix     = header->heigthm ;
  inf->palette  = NULL ;
  inf->nb_cpal  = 0 ;
  if ( 2*header->header_length != sizeof(IMG_HEADER) )
  {
    char buf[6] ;

    ImgFRead( inf, buf, 6 ) ;
    if ( memcmp(buf, "XIMG", 5) == 0 )
    {
      int    tmp[256*3] ;
      size_t nb ;
      long   tcol ;
      int    i, ind ;
      int*   pt ;

      nb           = 2*header->header_length-sizeof(IMG_HEADER)-6 ;
      nb           = 6*(nb/6) ;   /* Mˆme si ce n'est pas le cas, ce */
      inf->nb_cpal = nb/6 ;       /* Nombre DOIT ˆtre multiple de 6  */
      tcol         = nb_colors ;
      if (inf->nb_cpal > tcol) tcol = inf->nb_cpal ;
      inf->palette = Xalloc( 6*tcol ) ;
      if ( inf->palette )
      {
        ImgFRead( inf, tmp, nb ) ;
        get_tospalette( inf->palette ) ;
        pt = inf->palette ;
        for (i = 0; i < inf->nb_cpal; i++)
        {
          ind       = 3*i ;
          pt[ind]   = tmp[3*i] ;
          pt[1+ind] = tmp[1+3*i] ;
          pt[2+ind] = tmp[2+3*i] ;
        }
      }
      else ret = EIMG_NOMEMORY ;
    }
    else ret = EIMG_DATAINCONSISTENT ;
  }

  if ( ret != EIMG_SUCCESS ) free_info( inf ) ;

  return ret ;
}

int img_load(INFO_IMAGE* inf)
{
  IMGS_STR    imgs_str ;
  IMG_HEADER* header = (IMG_HEADER*) inf->specific ;
  MFDB*       out = &inf->mfdb ;

  if ( header == NULL ) return EIMG_NOMEMORY ;
  if ( !inf->xfile.valid || (inf->file_size <= header->header_length*2) ) return EIMG_FILENOEXIST ;
  
  imgs_str.adr_src = Xalloc( inf->file_size-header->header_length*2 ) ;
  if ( imgs_str.adr_src == NULL ) return EIMG_NOMEMORY ;
  
  perf_start( PERF_DISK, &inf->perf_info ) ;
  ImgFSeek( inf, header->header_length*2, SEEK_SET ) ;
  ImgFRead( inf, imgs_str.adr_src, inf->file_size-header->header_length*2 ) ;
  ImgFClose( inf ) ;
  perf_stop( PERF_DISK, &inf->perf_info ) ;

  /* Initialize data for assembly routine */
  imgs_str.nb_plan   = header->nplanes ;
  imgs_str.octet_run = header->pattern_run ;
  imgs_str.nb_pixel  = header->pixel_line ;
  imgs_str.nb_ligne  = header->nb_line ;
  imgs_str.mot_larg  = w2wdwidth( imgs_str.nb_pixel ) ;
  imgs_str.mot_larg *= imgs_str.nb_plan ;
  imgs_str.adr_dest  = img_alloc( imgs_str.nb_pixel, 1+imgs_str.nb_ligne, imgs_str.nb_plan ) ;
  if ( imgs_str.adr_dest == NULL )
  {
    Xfree( imgs_str.adr_src ) ;
    return EIMG_NOMEMORY ;
  }

  out->fd_addr    = imgs_str.adr_dest ;
  out->fd_w       = align16( imgs_str.nb_pixel ) ;
  out->fd_h       = imgs_str.nb_ligne ;
  out->fd_wdwidth = imgs_str.mot_larg/imgs_str.nb_plan ;
  out->fd_stand   = 0 ;
  out->fd_nplanes = imgs_str.nb_plan ;
  
  img_raz( out ) ;

  perf_start( PERF_COMPRESS, &inf->perf_info ) ;
  img_dcmps( &imgs_str ) ;
  perf_stop( PERF_COMPRESS, &inf->perf_info ) ;

  Xfree( imgs_str.adr_src ) ;
  img_post_loading( EIMG_SUCCESS, inf ) ;

  return EIMG_SUCCESS ;
}

#pragma warn -par
int img_sauve(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW* wprog)
{
  IMG_HEADER inf ;
  FILE       *stream ;
  long       long_lplan ; /* Longueur en octets d'un plan par ligne */
  long       long_ligne ; /* Longueur en octets d'une ligne */   
  int        num_ligne ;
  int        dif_line ;
  int        i, j ;
  int        *pt1, *pt2 ;
  int        *cl1, *cl2 ;
  int        *img_ligne ;
  int        *pt_img ;
  int        nb ;
  int        nb_ligne ;
  char       *buf ;
  
  if ( img->fd_nplanes > 8 ) return EIMG_OPTIONNOTSUPPORTED ;

  long_ligne = 2*img->fd_wdwidth*img->fd_nplanes ;
  long_lplan = long_ligne/img->fd_nplanes ;
  img_ligne  = (int *) Xcalloc( 1, long_ligne ) ;
  if ( img_ligne == NULL ) return EIMG_NOMEMORY ;

  buf = (char *) Xcalloc( 1, 16+long_ligne ) ;
  if ( buf == NULL )
  {
    Xfree(img_ligne) ;
    return EIMG_NOMEMORY ;
  }

  stream = CreateFileR( name ) ;
  if ( stream == NULL )
  {
    Xfree(buf) ;
    Xfree(img_ligne) ;
    return EIMG_FILENOEXIST ;
  }

  inf.version       = 1 ;
  inf.header_length = 8 ;
  if ((info->palette != NULL) && (info->nplanes > 1))
    inf.header_length += 3+3*(int)info->nb_cpal ;
  inf.nplanes      = img->fd_nplanes ;
  inf.pattern_run   = 2 ;
  inf.widthm        = info->lpix;
  inf.heigthm       = info->hpix ;
  inf.pixel_line    = img->fd_w;
  inf.nb_line       = img->fd_h;
  fwrite(&inf, sizeof(IMG_HEADER), 1, stream) ;
  if ((info->palette != NULL) && (info->nplanes > 1))
  {
    int  pal[256*3] ;
    int  ind ;
    int  *pt ;
    char tmp[6] ;

    strcpy(tmp, "XIMG") ;
    tmp[4] = tmp[5] = 0 ;
    fwrite(tmp, 6, 1, stream) ;
    pt = (int *) info->palette ;
    for (i = 0; i < info->nb_cpal; i++)
    {
      ind        = 3*i ;
      pal[ind]   = pt[3*i] ;
      pal[1+ind] = pt[1+3*i] ;
      pal[2+ind] = pt[2+3*i] ;
    }
    fwrite(pal, 6, info->nb_cpal, stream) ;
  }
  pt1 = (int *) img->fd_addr ;
  for (num_ligne = 0; num_ligne < img->fd_h;)
  {
    nb_ligne  = 1 ;
    dif_line  = 0 ;
    pt2       = pt1 ;
    pt2      += long_ligne>> 1 ;
    while (!dif_line)
    {
      dif_line = memcmp(pt1, pt2, long_ligne) ;
      if (!dif_line) nb_ligne++ ;
      pt2 += long_ligne>> 1 ;
      if (nb_ligne == 255)      break ;
      if (nb_ligne > img->fd_h) break ;
    }
    
    if (nb_ligne > 1)
    {
      buf[0] = 0 ;    buf[1] = 0 ;
      buf[2] = 0xFF ; buf[3] = nb_ligne ;
      if (fwrite(buf, 4, 1, stream) != 1)
      {
        fclose(stream) ;
        Xfree(buf) ;
        Xfree(img_ligne) ;
        return EIMG_DATAINCONSISTENT ;
      }
    }
    
    raster2imgline(pt1, img_ligne, long_ligne, img->fd_nplanes) ;
    
    for (j = 0; j < img->fd_nplanes; j++)
    {
      pt_img = img_ligne + ((j*long_lplan)>> 1) ;
      i      = 0 ;
      while (i < long_lplan) /* Tant que la ligne du plan j */
                             /* N'est pas entiŠrement cod‚e */
      {
        /* On recherche d'abord si au moins 2 mots se r‚pŠtent */
        cl1 = pt_img ;
        cl2 = pt_img + 1 ;
        nb  = 0 ;
        while ((*cl1 == *cl2) && (i+nb < long_lplan))
        {
          cl1++;
          cl2++;
          nb += 2 ;
          if (nb == 124) break ;
        }
    
        if (nb > 0)   /* 2 mots se r‚pŠtent : on d‚cide alors d'un compactage */
        {
          if (*pt_img == 0)
          {
            buf[0] = 2+nb ;             /* SOLID_RUN */
            if (fwrite(buf, 1, 1, stream) != 1)
            {
              fclose(stream) ;
              Xfree(buf) ;
              Xfree(img_ligne) ;
              return EIMG_DATAINCONSISTENT ;
            }
          }
          else
          {
            if (*pt_img == -1)
            {
              buf[0] = (2+nb) | 0x80 ; /* SOLID_RUN */
              if (fwrite(buf, 1, 1, stream) != 1)
              {
                fclose(stream) ;
                Xfree(buf) ;
                Xfree(img_ligne) ;
                return EIMG_DATAINCONSISTENT ;
              }
            }
            else
            {
              buf[0] = 0 ;
              buf[1] = (2+nb)>> 1 ;
              memcpy(&buf[2], pt_img, 2) ;  /* PATTERN_RUN */
              if (fwrite(buf, 4, 1, stream) != 1)
              {
                fclose(stream) ;
                Xfree(buf) ;
                Xfree(img_ligne) ;
                return EIMG_DATAINCONSISTENT ;
              }
            }
          }
        }
        else       /* Il n'y a r‚p‚tition : on ne peut pas compacter */
        {
          buf[0] = 0x80 ; /* BIT_STRING */
          cl1 = pt_img ;
          cl2 = pt_img + 1 ;
          nb  = 0 ;
          /* On cherche alors l'‚ventuelle prochaine r‚p‚tition */
          while ((*cl1 != *cl2) && (i+nb < long_lplan))
          {
            cl1++;
            cl2++;
            nb += 2 ;
            if (nb == 254) break ;
          }
          buf[1] = nb ;
          memcpy(&buf[2], pt_img, nb) ;
          if (fwrite(buf, nb+2, 1, stream) != 1)
          {
            fclose(stream) ;
            Xfree(buf) ;
            Xfree(img_ligne) ;
            return EIMG_DATAINCONSISTENT ;
          }
          nb -= 2 ;
        }
    
        pt_img += nb>> 1 ;
        pt_img++ ;
        i += nb ;
        i += 2 ;
      
        if (i == long_lplan-2)
        {
          buf[0] = 0x80 ; /* BIT_STRING */
          buf[1] = 2 ;
          memcpy(&buf[2], pt_img, 2) ;
          if (fwrite(buf, 4, 1, stream) != 1)
          {
            fclose(stream) ;
            Xfree(buf) ;
            Xfree(img_ligne) ;
            return EIMG_DATAINCONSISTENT ;
          }
          i += 2 ;
          pt_img++ ;
        }
      }
    }
    
    pt1       += nb_ligne*(long_ligne>>1) ;  
    num_ligne += nb_ligne ;    
  }
  
  Xfree(buf) ;
  Xfree(img_ligne) ;
  if (fclose(stream)) return EIMG_DATAINCONSISTENT ;

  return EIMG_SUCCESS ;
}
#pragma warn +par

void img_getdrvcaps(INFO_IMAGE_DRIVER *caps)
{
  char kext[] = "IMG\0\0" ;

  caps->iid = IID_IMG ;
  strcpy( caps->short_name, "(X)-IMG" ) ;
  strcpy( caps->file_extension, "IMG" ) ;
  strcpy( caps->name, "Standard GEM IMG" ) ;
  caps->version = 0x0405 ;

  caps->import = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_PBIT ; 
  caps->export = IEF_P1 | IEF_P2 | IEF_P4 | IEF_P8 | IEF_PBIT ;
  
  memcpy( caps->known_extensions, kext, sizeof(kext) ) ;
}
