/**************************/
/* FRECURSE.C Header file */
/**************************/
#if !defined(__FRECURSE)
#define __FRECURSE

typedef struct __FR_CDATA
{
  char* filename ;
  DTA*  dta ;
  void* user_data ;
  long  nfiles ;
}
FR_CDATA, *PFR_CDATA ;

typedef struct __FR_DATA
{
  int   long_names ;
  char* path ;
  char* mask ;
  char* log_file ;
  int  (*user_func)(FR_CDATA* fr_cdata) ;
  void* user_data ;
}
FR_DATA, *PFR_DATA ;

int  file_in_mask(char *fname, char *mask) ;
void find_files(FR_DATA* fr_data) ;
void folder_recurse(FR_DATA* fr_data) ;
long count_files(int recurse, FR_DATA* fr_data) ;

#endif
