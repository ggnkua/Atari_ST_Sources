#ifndef __VUPDATE_H

#ifndef __GWINDOWS_H
#include  "..\tools\gwindows.h"
#endif

#define AU_UPDATEDONE       0
#define AU_NOUPDATE         1
#define AU_UPDATEFOUND      2
#define AU_NOUPDATER        3
#define AU_UPDATERERR       4
#define AU_UPDATERUNKNOWN   5
#define AU_UPDATECMDTOOLONG 6

typedef struct _AU_CONTEXT
{
  /* Variables to be set by caller before calling AUCheckUpdate/AUPerformUpdate */
  GEM_WINDOW* wprog ;                             /* Progression window; only used by AUPerformUpdate                                                   */
  short       (*IsFileToUpdate)(char* filename) ; /* Tell updater if this file shall be updated from Internet, typically return 0 on configuration file */
  char        inet_app_fversion[16] ;             /* File that holds the current version on Internet, 1st line shall start with: Version = xxxx         */
  char        current_version[16] ;               /* Current local version of application                                                               */
  char        url_version[16] ;                   /* Version found on Internet                                                                          */
  char        url[PATH_MAX] ;                     /* URL to look for Internet update e.g. http://vision.atari.org/vupdate/staging/                      */
  char        updater[PATH_MAX] ;                 /* Full path to updater application (wget or curl) or shall be present in some folder from $PATH      */
  char        path_init[PATH_MAX] ;               /* Application local folder                                                                           */
  char        path_update[PATH_MAX] ;             /* Application local folder to hold backup of existing files before they get updated through Internet */

  /* Maintained by update mecanism towards AUCheckUpdate/AUPerformUpdate calls */
  char local_version_file[PATH_MAX] ;

  /* Trusted RootCA file (used for https with curl) */
  char  trusted_ca_file[PATH_MAX] ;

  /* Output statistics */
  short nfiles_to_update ;
  short nfiles_updated ;
  short nfiles_not_updated ;
}
AU_CONTEXT, *PAU_CONTEXT ;

short AUCheckUpdate(AU_CONTEXT* AUContext) ;
short AUPerformUpdate(AU_CONTEXT* AUContext) ;

#endif

