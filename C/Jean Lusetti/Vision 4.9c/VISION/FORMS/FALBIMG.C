#include <string.h>
#include "..\tools\gwindows.h"
#include "..\tools\imgmodul.h"

#include "..\tools\catalog.h"
#include "..\tools\logging.h"

#include "defs.h"
#include "falbum.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  long  index ;
  char* img_comment ;
  HCAT  hCat ;
}
WEXTENSION_ALBIMGINFO ;


static void OnInitDialogAlbImg(void* w)
{
  GEM_WINDOW*            wnd = (GEM_WINDOW*) w ;
  WEXTENSION_ALBIMGINFO* wext = wnd->DlgData->UserData ;
  OBJECT*                adr_info = wnd->DlgData->BaseObject ;
  INDEX_RECORD           inf, *rec ;
  INDEX_RECORD*          tab_index = catalog_get_index_record(wext->hCat) ;
  CATALOG_HEADER*        catalog_header = catalog_get_header(wext->hCat) ;
  INFO_IMAGE             info ;
  DTA                    dta ;
  int                    exist ;
  char                   name[200] ;
  char                   buffer[100], buf[100] ;
  char                   na[] = "****" ;

  if ( !catalog_header || !tab_index )
  {
    LoggingDoInvalidhCat() ;
    return ;
  }

  mouse_busy() ;
  rec = &tab_index[wext->index] ;
  catalog_getfullname(wext->hCat, wext->index, name) ;
  exist = (file_getinfo(name, &dta) == 0) ;
  if ( exist )
  {
    catalog_encrypt_datetime(&dta, &inf) ;
    write_text(adr_info, ALMIMG_EXIST, vMsgTxtGetMsg(MSG_YES) ) ;
    if (inf.date_time != rec->date_time) write_text(adr_info, ALMIMG_UPDATE, vMsgTxtGetMsg(MSG_NO) ) ;
    else                                 write_text(adr_info, ALMIMG_UPDATE, vMsgTxtGetMsg(MSG_YES) ) ;
    write_text(adr_info, ALMIMG_NAME, name) ;
    write_text(adr_info, ALMIMG_REM, wext->img_comment) ;
    sprintf(buf, "%s", catalog_header->category_names[rec->category_1]) ;
    if (rec->category_2 != rec->category_1)
    {
      sprintf(buffer, ", %s",  catalog_header->category_names[rec->category_2]) ;
      strcat(buf, buffer) ;
    }
    if ((rec->category_3 != rec->category_2) && (rec->category_3 != rec->category_1))
    {
      sprintf(buffer, ", %s",  catalog_header->category_names[rec->category_3]) ;
      strcat(buf, buffer) ;
    }
    write_text(adr_info, ALMIMG_CATS, buf) ;
    catalog_getstdinfos(wext->hCat, wext->index, NULL, buf, NULL) ;
    write_text(adr_info, ALMIMG_FORMAT, buf) ;
    vimg_format( IID_UNKNOWN, -1, name, &info ) ;
    sprintf(buf, "%d x %d", info.width, info.height) ;
    write_text(adr_info, ALMIMG_SIZE, buf) ;
    sprintf(buf, "%ld", 1L << info.nplanes) ;
    write_text(adr_info, ALMIMG_COLORS, buf) ;
    if (dta.d_length < 1024*10) sprintf(buf, "%lu", dta.d_length) ;
    else if (dta.d_length < 1024L*1000L) sprintf(buf, "%.1f Ko", (float)dta.d_length/1024.0) ;
    else sprintf(buf, "%.1f Mo", (float)dta.d_length/1024.0/1024.0) ;
    write_text(adr_info, ALMIMG_BYTESIZE, buf) ;
    free_info( &info ) ;
  }
  else
  {
    char  objs[] = { ALMIMG_UPDATE, ALMIMG_NAME, ALMIMG_REM, ALMIMG_CATS, ALMIMG_FORMAT, ALMIMG_SIZE, ALMIMG_COLORS, ALMIMG_BYTESIZE } ;
    short i ;    

    write_text(adr_info, ALMIMG_EXIST, vMsgTxtGetMsg(MSG_NO) ) ;
    for ( i = 0; i < ARRAY_SIZE(objs); i++ )
      write_text( adr_info, objs[i], na) ;
  }
  mouse_restore() ;
}

#pragma warn -par
int OnObjectNotifyAlbImg(void *w, int obj)
{
  int code = -1 ;

  switch( obj )
  {
     case ALMIMG_OK : code = IDOK ;
                      break ;
  }

  if ( code == IDOK )
  {

  }

  return code ;
}
#pragma warn +par

int FGetAlbImgInfo(WEXTENSION_ALBIMGINFO* wext)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_ALMIMGINFO ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogAlbImg ;
  dlg_data.OnObjectNotify = OnObjectNotifyAlbImg ;

  return GWCreateAndDoModal( &dlg_data, 0 ) ;
}

void show_imginfo(HCAT hCat, long index, char *img_comment)
{
  WEXTENSION_ALBIMGINFO wext ;

  wext.index       = index ;
  wext.img_comment = img_comment ;
  wext.hCat        = hCat ;

  FGetAlbImgInfo( &wext ) ;
}

