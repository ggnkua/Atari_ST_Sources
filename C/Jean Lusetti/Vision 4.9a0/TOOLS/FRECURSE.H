/**************************/
/* FRECURSE.C Header file */
/**************************/
#if !defined(__FRECURSE_H)
#define __FRECURSE_H


typedef struct __FR_CDATA
{
  char*          filename ;
  unsigned long  size ;
  unsigned short date ;
  unsigned short time ;
  void*          user_data ;
  long           nfiles ;
}
FR_CDATA, *PFR_CDATA ;

#define FFR_LONGNAMES           0x01 /* Use long file names                                        */
#define FFR_NOLONGNAMESDETAILS  0x02 /* Don't fill in size, date and time for long names (avoid a Fxattr call) */
                                     /* Note that on 8.3 names, size, date and time are always reported        */

typedef struct __FR_DATA
{
  short flags ; /* FFR_... */
  char* path ;
  char* mask ;
  char* log_file ;
  short (*user_func)(FR_CDATA* fr_cdata) ;
  void* user_data ;
}
FR_DATA, *PFR_DATA ;

short file_in_mask(char *fname, char *mask) ;
void  find_files(FR_DATA* fr_data) ;
void  folder_recurse(FR_DATA* fr_data) ;
long  count_files(short recurse, FR_DATA* fr_data) ;

#endif
