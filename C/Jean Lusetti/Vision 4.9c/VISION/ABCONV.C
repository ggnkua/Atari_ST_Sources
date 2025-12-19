/******************************/
/*--------- ABCONV.C ---------*/
/* Module des fonctions       */
/* Actions  batch conversion  */
/******************************/
#include <limits.h>
#include   <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdlib.h>


#include "..\tools\stdprog.h"
#include "..\tools\stdinput.h"
#include "..\tools\stdmline.h"
#include "..\tools\xgem.h"
#include "..\tools\xfile.h"
#include "..\tools\gwindows.h"
#include "..\tools\print.h"
#include "..\tools\dither.h"
#include "..\tools\img_io.h"
#include "..\tools\rzoom.h"
#include "..\tools\frecurse.h"
#include "..\tools\logging.h"
#include "..\tools\imgmodul.h"
#include "..\tools\rasterop.h"
#include "..\tools\frecurse.h"
#include  "..\tools\clipbrd.h"

#include     "defs.h"
#include     "undo.h"
#include   "rtzoom.h"
#include   "gstenv.h"
#include  "fullscr.h"
#include  "figures.h"
#include "visionio.h"
#include "vtoolbar.h"
#include "hexdump.h"
#include "forms\ftcwheel.h"
#include "forms\finfoimg.h"
#include "forms\fbconv.h"
#include "forms\fwpal.h"
#include "forms\frfiles.h"

#include "ldv\ldvcom.h"
#include "forms\fldv.h"
#include "forms\fappldv.h"


typedef struct
{
  BCONV_PARAMS* bconv ;
  FILE*         err_stream ;
  char          bconv_errfile[14] ;
  int           nb_bconv_fails ;

  GEM_WINDOW*   wconvprog ;
  long          total_nb_files_expected ;
  long          nb_files ;
  char          stop_conv ;
}
BATCH_CONV ;


void bconv_inform_error(char* name, int err, BATCH_CONV* batch_conv)
{
  char buf[200] ;

  batch_conv->nb_bconv_fails++ ;
  if ( batch_conv->err_stream == NULL )
  {
    batch_conv->err_stream = fopen( batch_conv->bconv_errfile, "wb+" ) ;
    sprintf( buf, vMsgTxtGetMsg(MSG_BCONVERR), batch_conv->bconv_errfile ) ;
    fwrite( buf, strlen(buf), 1, batch_conv->err_stream ) ;
  }
  if ( batch_conv->err_stream )
  {
    char msg_werr[50], *p ;

    sprintf( buf, vMsgTxtGetMsg(MSG_ERRCONV), name ) ;
    switch( err )
    {
      case EIMG_FILENOEXIST  :
      case EIMG_DATAINCONSISTENT  : strcpy( msg_werr, 1+vMsgTxtGetMsg(MSG_WRITEERROR) ) ;
                                    p = strchr( msg_werr, '.' ) ;
                                    if ( p ) *p = 0 ;
                                    sprintf( buf, "%s on %s\r\n", msg_werr, name ) ;
                                    break ;
      case EIMG_NOMEMORY  :         strcat( buf, vMsgTxtGetMsg(MSG_CATAMEM) ) ;
                                    break ;
      case EIMG_DECOMPRESERR  : 
      case -110 :                   strcat( buf, vMsgTxtGetMsg(MSG_BCONVOUTERR) ) ;
                                    break ;
      case -111 :                   sprintf( buf, vMsgTxtGetMsg(MSG_BCONVMOVERR), name ) ;
                                    break ;
      case -112 :                   sprintf( buf, vMsgTxtGetMsg(MSG_BCONVMOVERR), name ) ;
                                    break ;
      default  :                    sprintf( buf, "Error %d\r\n", err ) ;
                                    strcat( buf, msg_werr ) ;
                                    break ;
    }
    fwrite( buf, strlen(buf), 1, batch_conv->err_stream ) ;
  }
}

static void ManageSrc(BATCH_CONV* batch_conv, char* name)
{
  char  dst[PATH_MAX] ;
  char* slash ;

  switch( batch_conv->bconv->manage_src )
  {
    case MS_DONOTHING :
                        break ;

    case MS_REMOVESRC : if ( unlink( name ) ) bconv_inform_error( name, -111, batch_conv ) ;
                        break ;

    case MS_MOVESRC   : slash = strrchr( name, '\\' ) ;
                        if ( slash ) sprintf( dst, "%s\\%s", batch_conv->bconv->dst_movepath, 1+slash ) ;
                        else         sprintf( dst, "%s\%s", batch_conv->bconv->dst_movepath, name ) ;
                        if ( MoveFile( name, dst ) ) bconv_inform_error( name, -112, batch_conv ) ;
                        break ;
  }
}

static int get_resized(int resize, int rwidth, int rheight, int* rw, int* rh)
{
  float ratio ;

  if ( !resize || !rw || !rh || ( (rwidth < 16) && (rheight < 16) ) ) return 0 ;

  if ( rwidth == 0 )
  {
    /* Set height to rheight */
    if ( *rh > rheight ) ratio = (float)rheight/(float)*rh ;
    else                 resize = 0 ;
  }
  else if ( rheight == 0 )
  {
    /* Set width to rwidth */
    if ( *rw > rwidth ) ratio = (float)rwidth/(float)*rw ;
    else                resize = 0 ;
  }
  else
  {
    if ( (*rw > rwidth) || (*rh > rheight) )
    {
      float ratio2 = (float)rheight/(float)*rh ;

      ratio = (float)rwidth/(float)*rw ;
      if ( ratio > ratio2 ) ratio = ratio2 ;
    }
    else resize = 0 ;
  }

  if ( resize )
  {
    *rw = (int) (0.5+ratio*(float)*rw) ;
    *rh = (int) (0.5+ratio*(float)*rh) ;
  }
  
  return resize ;
}

static short conv_img(FR_CDATA* fr_cdata)
{
  BATCH_CONV* batch_conv = (BATCH_CONV*) fr_cdata->user_data ;
  IMG_MODULE* img_module ;
  INFO_IMAGE  inf ;
  MFDB*       out = &inf.mfdb ;
  long        loutfmt = batch_conv->bconv->inf.lformat ;
  int         old_std_vdi = UseStdVDI ;
  int         do_it ;
  char        name_out[200] ;
  char*       nom ;
  char*       c ;

  if ( batch_conv->stop_conv ) return 1 ;

  img_module = DImgGetModuleFromIID( loutfmt ) ;
  if ( img_module == NULL ) return -110 ;

  UseStdVDI = 0 ;
  if ( DImgGetIIDFromFile( fr_cdata->filename ) != 0 )
  {
    int err = vimg_format( IID_UNKNOWN, 0, fr_cdata->filename, &inf ) ;

    if ( !err )
    {
      out->fd_nplanes = -1 ; /* Garder le meme nombre de plans */
      do_it           = 1 ;

      if ( loutfmt == IID_GIF )
      {
        if ( inf.nplanes > 8 )
        {
          if ( batch_conv->bconv->bconv_handle_imcomp == 1 ) do_it           = 0 ;
          else                                               out->fd_nplanes = 8 ;
        }
      }
      else if ( loutfmt == IID_TARGA )
      {
        if ( inf.nplanes <= 8 )
        {
          if ( batch_conv->bconv->bconv_handle_imcomp == 1 ) do_it           = 0 ;
          else                                               out->fd_nplanes = 24 ;
        }
      }
      else if ( loutfmt == IID_JPEG )
      {
        if ( inf.nplanes <= 8 )
        {
          if ( batch_conv->bconv->bconv_handle_imcomp == 1 ) do_it           = 0 ;
          else                                               out->fd_nplanes = 24 ;
        }
      }
      else if ( loutfmt == IID_IMG )
      {
        if ( inf.nplanes > 8 )
        {
          if ( batch_conv->bconv->bconv_handle_imcomp == 1 ) do_it           = 0 ;
          else                                               out->fd_nplanes = 8 ;
        }
      }

      if ( out->fd_nplanes == 24 ) out->fd_nplanes = 32 ; /* RasterZoom can't operate on 24bit */
      
      nom = strrchr( fr_cdata->filename, '\\' ) ;
      if ( do_it && nom )
      {
        nom++ ;
        c = strrchr( nom, '.' ) ;
        if ( c ) *c = 0 ;
        sprintf( name_out, "%s\\%s.%s", batch_conv->bconv->dst_path, nom, img_module->Capabilities.file_extension ) ;
        if ( c != NULL ) *c = '.' ;
        if ( FileExist( name_out ) && (batch_conv->bconv->manage_dst == MD_CANCELOPE) )
        {
          do_it = 0 ;
          err   = -2 ;
        }
      }
      if ( do_it )
      {
        char buf[50] ;

        inf.force_16b_load = ( inf.nplanes == 16 ) ;
        if ( batch_conv->wconvprog && (batch_conv->total_nb_files_expected >= 0) )
        {
          batch_conv->nb_files++ ;
          StdProgWText( batch_conv->wconvprog, 0, vMsgTxtGetMsg(MSG_LOADINGIMG) ) ;
          StdProgWText( batch_conv->wconvprog, 1, fr_cdata->filename ) ;
          sprintf( buf, "%ld/%ld", batch_conv->nb_files, batch_conv->total_nb_files_expected ) ;
          batch_conv->stop_conv = PROG_CANCEL_CODE( GWProgRange( batch_conv->wconvprog, batch_conv->nb_files, batch_conv->total_nb_files_expected, buf ) ) ;
        }
        if ( !batch_conv->stop_conv )
        {
          err = load_picture( &inf ) ;
          if ( !err )
          {
            int rw, rh ;

            inf.compress        = batch_conv->bconv->inf.compress ;
            inf.c.f.jpg.quality = batch_conv->bconv->inf.c.f.jpg.quality ;
            inf.nplanes         = out->fd_nplanes ;
            StdProgWText( batch_conv->wconvprog, 0, vMsgTxtGetMsg(MSG_SAVINGIMG) ) ;
            StdProgWText( batch_conv->wconvprog, 1, name_out ) ;
            inf.lformat = loutfmt ;
            rw = out->fd_w ;
            rh = out->fd_h ;
            if ( get_resized( batch_conv->bconv->resize, batch_conv->bconv->rwidth, batch_conv->bconv->rheight, &rw, &rh ) )
            {
              MFDB sout ;

              ZeroMFDB( &sout ) ;
              sout.fd_w = rw ;
              sout.fd_h = rh ;
              LoggingDo(LL_INFO, "Resizing image %dx%d to %dx%d (%d planes)", out->fd_w, out->fd_h, sout.fd_w, sout.fd_h, out->fd_nplanes) ;
              if ( RasterZoom( out, &sout, NULL ) )
              {
                LoggingDo(LL_INFO, "Failed to resize, saving original image" ) ;
                err = vsave_picture( name_out, out, &inf, NULL ) ;
              }
              else
              {
                if ( out->fd_addr ) Xfree( out->fd_addr ) ; /* Better free it now to save resources for save_picture */
                out->fd_addr = NULL ;
                inf.width  = sout.fd_w ;
                inf.height = sout.fd_h ;
                err = vsave_picture( name_out, &sout, &inf, NULL ) ;
                if ( sout.fd_addr ) Xfree( sout.fd_addr ) ;
              }
            }
            else err = vsave_picture( name_out, out, &inf, NULL ) ;
          }
        }
      }
      else if ( err == 0 ) err = -110 ;
    }
    free_info( &inf ) ;
    if ( err ) bconv_inform_error( fr_cdata->filename, err, batch_conv ) ;
    else       ManageSrc( batch_conv, fr_cdata->filename ) ;
  }
  UseStdVDI = old_std_vdi ;

  return 0 ;
}

void traite_batch_conversion(void* external_call)
{
  BATCH_CONV batch_conv ;
  int        i ;
  char       buffer[PATH_MAX] ;

  memzero( &batch_conv, sizeof(batch_conv) ) ;
  strcpy( batch_conv.bconv_errfile, "CONVERT.ERR" ) ;
  if ( !external_call )
  {
    batch_conv.bconv = (BCONV_PARAMS*) Xcalloc( 1, sizeof(BCONV_PARAMS) ) ;
    if ( batch_conv.bconv == NULL )
    {
      form_error_mem() ;
      return ;
    }
    sprintf( batch_conv.bconv->log_file, "%s\\RFILES.LOG", config.path_temp ) ;
  }
  else
  {
    batch_conv.bconv = (BCONV_PARAMS*) external_call ; /* BCONV_PARAMS provided by caller, don't ask */
    sprintf( batch_conv.bconv->log_file, "%s\\RFILES.LOG", config.path_temp ) ;
    batch_conv.bconv->total_nb_files_expected = GetRFiles( batch_conv.bconv->rfile, 1, 1, batch_conv.bconv->log_file ) ;
  }
  if ( external_call || (FBConv( batch_conv.bconv ) == 1) )
  {
    batch_conv.total_nb_files_expected = batch_conv.bconv->total_nb_files_expected ;
    if ( batch_conv.total_nb_files_expected > 0 )
    {
      batch_conv.wconvprog = DisplayStdProg( vMsgTxtGetMsg(MSG_LOADINGIMG) , "", "", 0 ) ;
      GWSetWindowCaption( batch_conv.wconvprog, vMsgTxtGetMsg(MSG_BCONV)  ) ;
      mouse_busy() ;
      batch_conv.stop_conv = 0 ;
      if ( batch_conv.bconv->rfile[0].recurse )
      {
        FILE *stream = fopen( batch_conv.bconv->log_file, "rb" ) ;

        if ( stream )
        {
          while ( fgets( buffer, PATH_MAX, stream ) )
          {
            FR_CDATA fr_cdata ;

            removeCRCF( buffer ) ;
            memzero( &fr_cdata, sizeof(FR_CDATA) ) ;
            fr_cdata.filename  = buffer ;
            fr_cdata.user_data = &batch_conv ;
            conv_img( &fr_cdata ) ;
          }
          fclose( stream ) ;
        }
      }
      else
      {
        for ( i = 0; i < NB_MAX_RFILES; i++ )
          if ( batch_conv.bconv->rfile[i].path[0] != 0 )
          {
            FR_DATA fr_data ;

            fr_data.flags      = GetLongFileNamesStatus() ;
            fr_data.path       = batch_conv.bconv->rfile[i].path ;
            fr_data.mask       = batch_conv.bconv->rfile[i].mask ;
            fr_data.log_file   = NULL ;
            fr_data.user_func  = conv_img ;
            fr_data.user_data  = &batch_conv ;
            find_files( &fr_data ) ;
          }
      }
      mouse_restore() ;
      if ( batch_conv.err_stream )
      {
        sprintf( buffer, vMsgTxtGetMsg(MSG_CATAEND) , batch_conv.nb_bconv_fails ) ;
        fwrite( buffer, strlen(buffer), 1, batch_conv.err_stream ) ;
        fclose( batch_conv.err_stream ) ;
        batch_conv.err_stream = NULL ;
        sprintf( buffer, vMsgTxtGetMsg(MSG_ERRSEEFILE) , batch_conv.bconv_errfile ) ;
        form_stop( buffer ) ;
      }
      GWDestroyWindow( batch_conv.wconvprog ) ;
    }
  }
  unlink( batch_conv.bconv->log_file ) ;
  if ( !external_call ) Xfree( batch_conv.bconv ) ;
}
