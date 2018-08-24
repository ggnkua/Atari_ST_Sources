#ifndef __XALLOC_H
#define __XALLOC_H

#include <stdlib.h>
#include <string.h>

#define TA_AUTO   -1 /* Let library decide                     */
#define TA_STRAM   0 /* Standard 'C' lib mallocs (ST-RAM only) */
#define TA_TTRAM   1 /* Allocations to TT-RAM only             */
#define TA_STPREF  2 /* Allocations either, ST-RAM preferred   */
#define TA_TTPREF  3 /* Allocations either, TT-RAM preferred   */

typedef struct __XALLOC_CONFIG
{
  int           AllocType ;
  int           MaxSimultaneousAllocs ;
  int           MaxReferencedSrcFilesSize ;
  size_t        TTRamThreshold ;
  int           FailRatePM ; /* Failling rate every 1000 allocations */
  int           StatsEverynSec ;
}
XALLOC_CONFIG, *PXALLOC_CONFIG ;

/* Memory allocation eXtensions    */
/* Used to decide ST-RAM or TT-RAM */
/* And bounduary checks            */
void XallocGetDefaultConfig(XALLOC_CONFIG* config) ;
int  XallocInit(XALLOC_CONFIG* config) ;
void XallocExit(void) ;
void XMemAvailable(size_t* st_ram, size_t* tt_ram) ;
void XallocStats(void) ;

#define Xalloc(size)                  __Xalloc(size,__FILE__,__LINE__)
#define Xfree(ptr)                    __Xfree(ptr,__FILE__,__LINE__)
#define Xcalloc(num_elems, elem_size) __Xcalloc(num_elems, elem_size,__FILE__,__LINE__)
#define Xstrdup(s)                    __Xstrdup(s,__FILE__,__LINE__)

/* Internal calls; don't use them, use defines above */
void* __Xalloc(size_t size, char* filename, long linenumber);
void  __Xfree(void* ptr, char* filename, long linenumber);
void* __Xcalloc(size_t num_elems, size_t elem_size, char* filename, long linenumber);
char* __Xstrdup(const char* s, char* filename, long linenumber);

#endif
