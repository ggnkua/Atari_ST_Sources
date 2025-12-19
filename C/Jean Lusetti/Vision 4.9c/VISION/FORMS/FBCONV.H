#ifndef __FCONV_H
#define __FCONV_H

#ifndef __FRFILES
#include "forms\frfiles.h"
#endif

#ifndef __XFILE
#include "..\tools\xfile.h"
#endif

#define MS_DONOTHING   0
#define MS_REMOVESRC   1
#define MS_MOVESRC     2

#define MD_ERASEDST   0
#define MD_CANCELOPE  1

typedef struct
{
  RFILE rfile[NB_MAX_RFILES] ;

  INFO_IMAGE inf ;

  char dst_path[PATH_MAX] ;
  int  bconv_handle_imcomp ;

  int manage_src ; /* MS_... */
  int manage_dst ; /* MD_... */
  char dst_movepath[PATH_MAX] ;

  long total_nb_files_expected ;
  char log_file[PATH_MAX] ;

  int  resize ; /* Resize if picture is bigger than width * height below */
  int  rwidth ;
  int  rheight ;
}
BCONV_PARAMS, *PBCONV_PARMS ;

int FBConv(BCONV_PARAMS* p) ;

#endif
