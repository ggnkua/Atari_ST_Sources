#ifndef __XALLOC_H
#define __XALLOC_H

#include <stdlib.h>
#include <string.h>

#define TA_AUTO   -1 /* Let library decide                     */
#define TA_STRAM   0 /* Standard 'C' lib mallocs (ST-RAM only) */
#define TA_TTRAM   1 /* Allocations to TT-RAM only             */
#define TA_STPREF  2 /* Allocations either, ST-RAM preferred   */
#define TA_TTPREF  3 /* Allocations either, TT-RAM preferred   */

#define FA_RESET_MEM_ON_FREE 0x01
typedef struct __XALLOC_CONFIG
{
  int    AllocType ;
  int    MaxSimultaneousAllocs ;
  int    MaxReferencedSrcFilesSize ;
  size_t TTRamThreshold ;
  int    FailRatePM ; /* Failling rate every 1000 allocations */
  int    StatsEverynSec ;
  short  Flags ; /* FA_... */
}
XALLOC_CONFIG, *PXALLOC_CONFIG ;

#ifndef __NO_XALLOC
/* Memory allocation eXtensions    */
/* Used to decide ST-RAM or TT-RAM */
/* And bounduary checks            */
void   XallocGetDefaultConfig(XALLOC_CONFIG* config) ;
int    XallocInit(XALLOC_CONFIG* config) ;
void   XallocExit(void) ;
void   XMemAvailable(size_t* st_ram, size_t* tt_ram) ; /* Largest block available for ST/TT RAM */
size_t XmemAvailableG(void) ; /* Global memory available */
void   XallocStats(void) ;
#define Xalloc(size)                  __Xalloc(size,__FILE__,__LINE__)
#define Xrealloc(ptr,size)            __Xrealloc(ptr,size,__FILE__,__LINE__)
#define Xfree(ptr)                    __Xfree(ptr,__FILE__,__LINE__)
#define Xcalloc(num_elems, elem_size) __Xcalloc(num_elems, elem_size,__FILE__,__LINE__)
#define Xstrdup(s)                    __Xstrdup(s,__FILE__,__LINE__)

/* Internal calls; don't use them, use defines above */
void* __Xalloc(size_t size, char* filename, long linenumber);
void* __Xrealloc(void* ptr, size_t size, char* filename, long linenumber);
void  __Xfree(void* ptr, char* filename, long linenumber);
void* __Xcalloc(size_t num_elems, size_t elem_size, char* filename, long linenumber);
char* __Xstrdup(const char* s, char* filename, long linenumber);

#else

/* Memory allocation eXtensions    */
/* Used to decide ST-RAM or TT-RAM */
/* And bounduary checks            */
#define XallocGetDefaultConfig(c)
int     XallocInit(XALLOC_CONFIG* config) ;
#define XallocExit()
void    XMemAvailable(size_t* st_ram, size_t* tt_ram) ; /* Largest block available for ST/TT RAM */
size_t  XmemAvailableG(void) ; /* Global memory available */
#define XallocStats()

#define Xalloc(size)                  malloc(size)
#define Xrealloc(ptr,size)            realloc(ptr,size)
#define Xfree(ptr)                    free(ptr)
#define Xcalloc(num_elems, elem_size) calloc(num_elems, elem_size)
#define Xstrdup(s)                    strdup(s)
#endif

#endif
