/* Memory allocation eXtensions    */
/* Used to decide ST-RAM or TT-RAM */
/* And bounduary checks            */
#include <stddef.h>
#include <stdio.h>
#include <time.h>
#include <tos.h>

#include "xalloc.h"
#include "logging.h"

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(v)  sizeof(v)/sizeof((v)[0])
#endif

static char* MType[] = { "ST", "TT", "STPref", "TTPref" } ;
#define DEFAULT_MAX_SIMULTANEOUS_ALLOCS      512
#define DEFAULT_MAX_REFERENCED_SRCFILES_SIZE 512
#define DEFAULT_ALLOC_TYPE                   MT_ST
#define DEFAULT_TTRAM_THRESHOLD              (10*1024)

static long XAllocMagicTailer = '_XAT' ;

typedef struct __ABLOCK_HEADER
{
  size_t        UsableSize ;
  int           Flags ;
  int           FileIndex ;
  unsigned int  FileLine ;
  unsigned long Crc ;
}
ABLOCK_HEADER, *PABLOCK_HEADER ;

typedef struct __ABLOCK_TAILER
{
  long Magic ;
}
ABLOCK_TAILER, *PABLOCK_TAILER ;

typedef struct __XALLOC_STATS
{
  unsigned long NbAllocs ;
  unsigned long NbAllocsFailed ;
  unsigned long NbCorruptedAllocs ;
  unsigned long NbFrees ;
  unsigned long NbAllocsSpike ;
  unsigned long NbBytesAllocatedNow ;
  unsigned long NbMaxBytesAllocated ;
  unsigned int  NbAllocListOverflow ;
  unsigned int  NbAttempsFreeUnref ;
  clock_t       LastStatsTime ;
}
XALLOC_STATS, *PXALLOC_STATS ;

typedef struct __XALLOC_DATA
{
  XALLOC_CONFIG Config ;
  XALLOC_STATS  Stats ;
  int           OMaxSimultaneousAllocs ;    /* Original MaxSimultaneousAllocs pass to XallocInit                             */
  int           VeryMaxSimultaneousAllocs ; /* We don't want to reserve more allocations references than this for our stuff  */
  void**        pUser ;                     /* Array of usable allocated pointers, aray size is Config.MaxSimultaneousAllocs */
  char*         FileNameBuffer ;
  int           FileNameBufferSize ;
}
XALLOC_DATA, *PXALLOC_DATA ;

static XALLOC_DATA XAllocData ;

/* Every allocation is structured as this :               */
/*   __p --> |ABLOCK_HEADER|Usable Memory|ABLOCK_TAILER|  */
/* #Bytes    |   14        |     Size    |      4      |  */
#define GET_PUSER(__p)      ((void*)((char*)__p + sizeof(ABLOCK_HEADER) ))
#define GET_PSIZE(__puser)  ((size_t*)((char*)__puser - sizeof(ABLOCK_HEADER)))
#define GET_TAILER(__puser) ((ABLOCK_TAILER*)((char*)__puser + *GET_PSIZE(__puser)))
#define GET_HEADER(__puser) ((ABLOCK_HEADER*)((char*)__puser - sizeof(ABLOCK_HEADER)))
#define GET_ALLOCP(__puser) ((void*)((char*)__puser - sizeof(ABLOCK_HEADER)))

#define GET_XSIZE(__usize) (sizeof(ABLOCK_HEADER) + __usize + sizeof(ABLOCK_TAILER))
#define GET_USIZE(__xsize) (__xsize - sizeof(ABLOCK_HEADER) - sizeof(ABLOCK_TAILER))

static size_t sizeof_filenamebuffer(void)
{
  return(XAllocData.Config.MaxReferencedSrcFilesSize*sizeof(char)) ;
}

static int get_file_index(char* filename)
{
  int i=0 ;
  int index = -1 ;

  while ( (index == -1) && (i < XAllocData.FileNameBufferSize) )
  {
    if (strcmp(filename, &XAllocData.FileNameBuffer[i]) == 0)
      index = i ; /* This filename is already referenced in our buffer */
    else
      i += 1+(int)strlen(&XAllocData.FileNameBuffer[i]) ;
  }

  if (index == -1)
  {
    size_t len = strlen(filename) ;

    if ( 1+len+XAllocData.FileNameBufferSize < sizeof_filenamebuffer() )
    {
      strcpy(&XAllocData.FileNameBuffer[XAllocData.FileNameBufferSize], filename) ;
      XAllocData.FileNameBufferSize += 1+(int)len ;
      index = XAllocData.FileNameBufferSize ;
    }
  }
  
  return index ;
}

static char* human_readable_alloc_size(size_t size, char* string)
{
  char*  unit[4] = { "bytes", "KB", "MB", "GB" } ;
  size_t nbytes = size ;
  int    i = 0 ;

  while ((size > 10L*1024L) && (i < ARRAY_SIZE(unit)))
  {
    size = size / 1024 ;
    i++ ;
  }

  if ( i != 0 ) sprintf(string, "%ld%s (%ld bytes)", size, unit[i], nbytes) ;
  else          sprintf(string, "%ld bytes", nbytes) ;

  return string ;
}

static char* short_filename(char* filename)
{
  char* slash1 = strrchr(filename, '\\') ;
  char* sfn = filename ;

  if (slash1)
  {
    char* slash2 ;

    *slash1 = 0 ;
    slash2 = strrchr(filename, '\\') ;
    *slash1 = '\\' ;
    if (slash2) sfn = 1+slash2 ;
  }

  return sfn ;
}

static unsigned long CRC(void* bytes, size_t size)
{
  unsigned long v, crc = 0 ;
  size_t        n ;
  int           shift = 0 ;
  char*         pt = (char*)bytes ;

  for (n=0; n < size; n++)
  {
    v    = (unsigned long) *pt++ ;
    v  <<= shift++ ;
    if (shift == 4) shift=0 ;
    crc += v ;
  }

  return crc ;
}

static void add_checks(ABLOCK_HEADER* h, ABLOCK_TAILER* t)
{
  h->Crc   = CRC(h, sizeof(ABLOCK_HEADER)-sizeof(long)) ;
  t->Magic = XAllocMagicTailer ;
}

static int get_index_for_puser(void* puser)
{
  int index = -1 ;
  int i ;

  for (i=0; (index == -1) && (i < XAllocData.Config.MaxSimultaneousAllocs); i++)
    if ( XAllocData.pUser[i] == puser )
      index = i ;

  return index ;
}

static int perform_checks(void* puser)
{
  int index ;
  int check_mask = 0 ;

  index = get_index_for_puser(puser) ;
  if ( index != -1 )
  {
    ABLOCK_HEADER* pheader = GET_HEADER(XAllocData.pUser[index]) ;
    ABLOCK_TAILER* ptailer = GET_TAILER(XAllocData.pUser[index]) ;

    /* Check header */
    if (pheader->Crc != CRC(pheader, sizeof(ABLOCK_HEADER)-sizeof(long))) check_mask |= 0x02 ;

    /* Check tailer */
    if (ptailer->Magic != XAllocMagicTailer) check_mask |= 0x04 ;
  }
  else check_mask |= 0x01 ;

  return check_mask ;
}

static int get_new_index(void* puser)
{
  int index = -1 ;
  int i ;

  for ( i=0; (index == -1) && (i < XAllocData.Config.MaxSimultaneousAllocs); i++)
  {
    if (XAllocData.pUser[i] == NULL)
    {
      XAllocData.pUser[i] = puser ;
      index               = i ;
    }
  }

  return index ;
}

static int add_ref(void* puser)
{
  int index ;
  int end = 0 ;
  
  do
  {
    index = get_new_index(puser) ;
    if (index == -1)
    {
      if (XAllocData.Config.MaxSimultaneousAllocs+XAllocData.OMaxSimultaneousAllocs <= XAllocData.VeryMaxSimultaneousAllocs)
      {
         /* Let try to extend our storage */
         int    nSimAllocs = XAllocData.Config.MaxSimultaneousAllocs+XAllocData.OMaxSimultaneousAllocs ;
         void** npUser = realloc(XAllocData.pUser, nSimAllocs*sizeof(void*)) ;

         if (npUser)
         {
           /* We have now more storage for our stuff */
           memset(&npUser[XAllocData.Config.MaxSimultaneousAllocs], 0, XAllocData.OMaxSimultaneousAllocs*sizeof(void*)) ;
           XAllocData.pUser                        = npUser ;
           XAllocData.Config.MaxSimultaneousAllocs = nSimAllocs ;
           LoggingDo(LL_INFO, "Maximum number referenced pointers increased to %d", nSimAllocs) ;
         }
         else
         {
           /* Can't get more storage, we have to deal with that */
           LoggingDo(LL_INFO, "Failed to increase maximum number referenced pointers to %d", nSimAllocs) ;
           end = 1 ;
         }
      }
      else
      {
        static int mal ;

        if ( ( mal++ & 0xFF) == 0) LoggingDo(LL_INFO, "%d maximum number referenced pointers is the very limit, won't increase it", XAllocData.Config.MaxSimultaneousAllocs) ;
        end = 1 ;
      }
    }
    else end = 1 ;
  }
  while ( !end ) ;

  if ( index == -1 )
    XAllocData.Stats.NbAllocListOverflow++ ;

  XAllocData.Stats.NbAllocs++ ;
  if ( XAllocData.Stats.NbAllocs-XAllocData.Stats.NbFrees > XAllocData.Stats.NbAllocsSpike )
    XAllocData.Stats.NbAllocsSpike = XAllocData.Stats.NbAllocs-XAllocData.Stats.NbFrees ;

  return index ;
}

static int get_alloc_type(int pref_alloc_type, size_t size)
{
  if ( (pref_alloc_type < TA_STRAM) || (pref_alloc_type > TA_TTPREF) )
    pref_alloc_type = TA_STRAM ;

  if (size < XAllocData.Config.TTRamThreshold)
    pref_alloc_type = TA_STRAM ;

  return pref_alloc_type ;
}

static void* mallocWithType(size_t xsize, int* flags)
{
  void* p = NULL ;
  int   allocType = get_alloc_type(XAllocData.Config.AllocType, xsize) ;

  *flags = allocType ;
  switch(allocType)
  {
    case TA_STRAM:  p = (long*) malloc(xsize) ;
                    break ;
    case TA_TTRAM: 
    case TA_STPREF:
    case TA_TTPREF: p = Mxalloc(xsize, XAllocData.Config.AllocType) ; /* mode=0; default from PRGFLAGS */
                    break ;
    default:        LoggingDo(LL_ERROR, "Unknown allocation type %d for allocating memory", allocType) ;
                    break ;
  }

  return p ;
}

static void freeWithType(void* p, int allocType)
{
  switch(allocType)
  {
    case TA_STRAM:  free(p) ;
                    break ;
    case TA_TTRAM:
    case TA_STPREF:
    case TA_TTPREF: Mfree(p) ;
                    break ;
    default:        LoggingDo(LL_ERROR, "Unknown allocation type %d for freeing memory", allocType) ;
                    break ;
  }
}

static int remove_ref_and_free(void* puser)
{
  int index = get_index_for_puser(puser) ;
  int free_it = 1 ;

  if (index < 0)
  {
    if (XAllocData.Stats.NbAllocListOverflow)
      { LoggingDo(LL_WARNING, "$%p NOT found in referenced table, however %d overflows occured in allocation list, taking risk to free it", puser, XAllocData.Stats.NbAllocListOverflow) ; }
    else
    {
      LoggingDo(LL_WARNING, "$%p NOT found in referenced table, NOT freeing it", puser) ;
      XAllocData.Stats.NbAttempsFreeUnref++ ;
      free_it = 0 ;
    }
  }

  if (free_it)
  {
    ABLOCK_HEADER* h = GET_HEADER(puser) ;

    freeWithType(GET_ALLOCP(puser), h->Flags & 0x03) ;
    XAllocData.Stats.NbBytesAllocatedNow -= h->UsableSize ;
    if (index >= 0) XAllocData.pUser[index] = NULL ;
    XAllocData.Stats.NbFrees++ ;
  }

  return index ;
}

void XMemAvailable(size_t* st_ram, size_t* tt_ram)
{
  if (Sversion() < 0x1900)
  {
    *st_ram = (size_t) Malloc(-1) ;
    *tt_ram = 0 ;
  }
  else
  {
    *st_ram = (size_t) Mxalloc(-1, TA_STRAM) ;
    *tt_ram = (size_t) Mxalloc(-1, TA_TTRAM) ;
  }
}
static int get_nb_sim_allocs(void)
{
  int i ;
  int n = 0 ;

  for (i=0; i<XAllocData.Config.MaxSimultaneousAllocs;i++)
    if (XAllocData.pUser[i]) n++ ;

  return n ;
}

void XallocStats(void)
{
  char   tmp1[64], tmp2[64] ;
  size_t st_ram, tt_ram ;
  size_t sfnb = sizeof_filenamebuffer() ;
  int    nb_simultaneous_allocs = get_nb_sim_allocs() ;

  XMemAvailable(&st_ram, &tt_ram) ;
  human_readable_alloc_size(st_ram, tmp1) ;
  human_readable_alloc_size(tt_ram, tmp2) ;
  LoggingDo(LL_INFO, "XallocStats:") ;
  LoggingDo(LL_INFO, "  ST-RAM available: %s", tmp1) ;
  LoggingDo(LL_INFO, "  TT-RAM available: %s", tmp2) ;
  LoggingDo(LL_INFO, "  Buffer for filenames used at %ld%% (%d/%ld)", (100L*XAllocData.FileNameBufferSize)/sfnb, XAllocData.FileNameBufferSize, sfnb) ;
  LoggingDo(LL_INFO, "  Buffer for referenced allocations used at %ld%% (%d/%d)", (100L*nb_simultaneous_allocs)/XAllocData.Config.MaxSimultaneousAllocs, nb_simultaneous_allocs, XAllocData.Config.MaxSimultaneousAllocs) ;
  LoggingDo(LL_INFO, "  %ld allocations", XAllocData.Stats.NbAllocs) ;
  LoggingDo(LL_INFO, "  %ld frees", XAllocData.Stats.NbFrees) ;
  LoggingDo(LL_INFO, "  %ld allocation failures", XAllocData.Stats.NbAllocsFailed) ;
  LoggingDo(LL_INFO, "  %ld corrupted blocks", XAllocData.Stats.NbCorruptedAllocs) ;
  LoggingDo(LL_INFO, "  %d attempts to free unreferenced memory", XAllocData.Stats.NbAttempsFreeUnref) ;
  LoggingDo(LL_INFO, "  %d overflows to track allocations", XAllocData.Stats.NbAllocListOverflow) ;
  LoggingDo(LL_INFO, "  %ld pointers currently allocated (max %ld)", XAllocData.Stats.NbAllocs-XAllocData.Stats.NbFrees, XAllocData.Stats.NbAllocsSpike) ;
  human_readable_alloc_size(XAllocData.Stats.NbBytesAllocatedNow, tmp1) ;
  human_readable_alloc_size(XAllocData.Stats.NbMaxBytesAllocated, tmp2) ;
  LoggingDo(LL_INFO, "  %s currently allocated (max %s)", tmp1, tmp2) ;
}

/* Allocation depending on memory type */
/* And prepare bounds checking         */
static void* smart_malloc(size_t xsize, char* filename, long linenumber, int* flags)
{
  void* puser = NULL ;
  long* p ;

  if (xsize & 0x01) xsize++ ; /* Make sure every field is even aligned */
  if ( (XAllocData.Config.FailRatePM > 0) && (rand() < (1000L*RAND_MAX)/XAllocData.Config.FailRatePM) )
  {
    LoggingDo(LL_MEM, "Simulating allocation error (Failing rate=%dpm)", XAllocData.Config.FailRatePM) ;
    p = NULL ;
  }
  else
    p = (long*) mallocWithType(xsize, flags) ;
  if ( p )
  {
    ABLOCK_HEADER* h ;
    ABLOCK_TAILER* t ;
    size_t         usize = GET_USIZE(xsize) ;
 
    puser         = GET_PUSER(p) ;
    h             = GET_HEADER(puser) ;
    h->UsableSize = usize ;
    h->Flags      = *flags ;
    h->FileIndex  = get_file_index(filename) ;
    h->FileLine   = (unsigned int) linenumber ;
    t             = GET_TAILER(puser) ; /* Needs UsableSize to be setup */
    add_checks(h, t) ;
    XAllocData.Stats.NbBytesAllocatedNow += usize ;
    if ( XAllocData.Stats.NbBytesAllocatedNow >  XAllocData.Stats.NbMaxBytesAllocated)
      XAllocData.Stats.NbMaxBytesAllocated = XAllocData.Stats.NbBytesAllocatedNow ;
    LoggingDo(LL_DEBUG, "smart_alloc header=$%p, puser=$%p, xsize=%ld, tail=$%p at %s, line %ld", h, puser, xsize, t, filename, linenumber) ;
    if (add_ref(puser) < 0)
    {
       static int mad ;

       if ( ( mad++ & 0xFF) == 0) LoggingDo(LL_WARNING, "Impossible to add $%p in referenced table, checkings may not be accurate", puser) ;
    }
  }
  else
    XAllocData.Stats.NbAllocsFailed++ ;

  if (XAllocData.Config.StatsEverynSec > 0)
  {
    clock_t dt_ms = (1000L * (clock() - XAllocData.Stats.LastStatsTime) ) / CLK_TCK ;

    if (dt_ms > (1000L*XAllocData.Config.StatsEverynSec) )
    {
      XallocStats() ;
      XAllocData.Stats.LastStatsTime = clock() ;
    }
  }

  return puser ;
}

void* __Xalloc(size_t usize, char* filename, long linenumber)
{
  char*  sfn = short_filename(filename) ;
  char   tmp[64] ;
  void*  p ;
  size_t xsize ;
  int    flags ;

  xsize = GET_XSIZE(usize) ;
  human_readable_alloc_size(usize, tmp) ;
  p = smart_malloc(xsize, sfn, linenumber, &flags) ;
  if ( p == NULL ) { LoggingDo(LL_ERROR, "Failed to allocate %s of %s-RAM from %s, line %ld", tmp, MType[flags & 0x03], sfn, linenumber) ; }
  else             { LoggingDo(LL_MEM, "At $%p, %s of %s-RAM allocated from %s, line %ld", p, tmp, MType[flags & 0x03], sfn, linenumber) ; }

  return p ;
}

void __Xfree(void* puser, char* filename, long linenumber)
{
  char* sfn = short_filename(filename) ;
  int   cm ;

  LoggingDo(LL_DEBUG, "About to free $%p at %s line %ld", puser, sfn, linenumber) ;
  cm = perform_checks(puser) ;
  if (cm & 0x01)
    LoggingDo(LL_ERROR, "$%p to be freed from %s, line %ld is NOT referenced", puser, sfn, linenumber) ;

  if (cm & 0x02)
    LoggingDo(LL_ERROR, "Allocated memory at $%p has been corrupted at start ($%p)", puser, GET_HEADER(puser)) ;

  if (cm & 0x04)
  {
    ABLOCK_TAILER* t = GET_TAILER(puser) ;

    LoggingDo(LL_ERROR, "Allocated memory at $%p has been corrupted at end ($%p): %lX", puser, t, t->Magic) ;
  }

  if (cm & 0x06)
    XAllocData.Stats.NbCorruptedAllocs++ ;

  if (remove_ref_and_free(puser) >= 0 )
    LoggingDo(LL_MEM, "$%p has been freed from %s, line %ld", puser, sfn, linenumber) ;
}

void* __Xcalloc(size_t num_elems, size_t elem_size, char* filename, long linenumber)
{
  void* p ;

  p = __Xalloc(num_elems*elem_size, filename, linenumber) ;
  if ( p ) memset(p, 0, num_elems*elem_size) ;

  return p ;
}

char* __Xstrdup(const char* s, char* filename, long linenumber)
{
  char* dup = __Xalloc(1+strlen(s), filename, linenumber) ;

  if (dup) strcpy(dup, s) ;

  return dup ;
}

int XallocTest(void)
{
  /* Allocation corrupted at end */
  char* ptr = Xalloc(128) ;

  if (ptr)
  {
    ptr[128] = '*' ;
    Xfree(ptr);
  }

  /* Allocation corrupted at start */
  ptr = Xalloc(256) ;
  if (ptr)
  {
    ptr-- ;
    *ptr = '*' ;
    Xfree(++ptr) ;
  }

  return 0 ;
}

int XallocInit(XALLOC_CONFIG* config)
{
  char    tmp1[64], tmp2[64] ;
  clock_t t ;
  size_t  st_ram, tt_ram ;
  int     ret = 0 ;

  XMemAvailable(&st_ram, &tt_ram) ;
  human_readable_alloc_size(st_ram, tmp1) ;
  human_readable_alloc_size(tt_ram, tmp2) ;
  LoggingDo(LL_INFO, "ST-RAM available: %s", tmp1) ;
  LoggingDo(LL_INFO, "TT-RAM available: %s", tmp2) ;

  memset(&XAllocData, 0, sizeof(XAllocData)) ;
  memcpy(&XAllocData.Config, config, sizeof(XALLOC_CONFIG)) ;
  XAllocData.OMaxSimultaneousAllocs    = config->MaxSimultaneousAllocs ;
  XAllocData.VeryMaxSimultaneousAllocs = 4*config->MaxSimultaneousAllocs ;
  XAllocData.pUser = malloc(config->MaxSimultaneousAllocs*sizeof(void*)) ;
  if (XAllocData.pUser)
  {
    memset(XAllocData.pUser, 0, config->MaxSimultaneousAllocs*sizeof(void*)) ;
    XAllocData.FileNameBuffer = malloc(config->MaxReferencedSrcFilesSize*sizeof(char)) ;
    if (XAllocData.FileNameBuffer)
    {
      int allocType = config->AllocType ;

      memset(XAllocData.FileNameBuffer, 0, config->MaxReferencedSrcFilesSize*sizeof(char)) ;
      XAllocData.FileNameBufferSize = 0 ;
      if ( (Sversion() < 0x1900) || (tt_ram == 0) ) 
        allocType = TA_STRAM ;
      else if (allocType == TA_AUTO)
        allocType = TA_TTPREF ;
      XAllocData.Config.AllocType    =  allocType ;
      XAllocData.Stats.LastStatsTime = clock() ;

      if (XAllocData.Config.FailRatePM) srand((unsigned int)time(&t)) ;
      LoggingDo(LL_INFO, "Memory allocations will use %s type", MType[allocType]) ;
    }
    else
    {
      LoggingDo(LL_ERROR, "XAllocInit unable to allocate %ld bytes of memory for holding source filenames", config->MaxReferencedSrcFilesSize*sizeof(char)) ;
      free(XAllocData.pUser) ;
      memset(&XAllocData, 0, sizeof(XAllocData)) ;
      ret = -1 ;
    }
  }
  else
  {
    LoggingDo(LL_ERROR, "XAllocInit unable to allocate %ld bytes of memory for internal checks", config->MaxSimultaneousAllocs*sizeof(void*)) ;
    memset(&XAllocData, 0, sizeof(XAllocData)) ;
    ret = -2 ;
  }

/*  XallocTest() ;*/

  return ret ;
}

void XallocExit(void)
{
  XallocStats() ;
  if (XAllocData.Stats.NbAllocs != XAllocData.Stats.NbFrees)
  {
    void*  puser ;
    size_t nbytes_pending = 0 ;
    int    i ;

    LoggingDo(LL_ERROR, "Still %ld pointers allocated", XAllocData.Stats.NbAllocs-XAllocData.Stats.NbFrees) ;
    if (XAllocData.Stats.NbAllocListOverflow > 0 )
      LoggingDo(LL_ERROR, "Attention: %d allocations were not referenced as too many of them, be careful with following list.", XAllocData.Stats.NbAllocListOverflow) ;
    for ( i=0; i < XAllocData.Config.MaxSimultaneousAllocs; i++)
    {
      puser = XAllocData.pUser[i] ;
      if ( puser != NULL )
      {
        ABLOCK_HEADER* h = GET_HEADER(puser) ;

        if (h->FileIndex >= 0) { LoggingDo(LL_ERROR, "At $%p, %ld bytes allocated from %s line %d have NOT been freed, freeing them now...", puser, h->UsableSize, &XAllocData.FileNameBuffer[h->FileIndex], h->FileLine) ; }
        else                   { LoggingDo(LL_ERROR, "At $%p, %ld bytes allocated from ??? line %d have NOT been freed, freeing them now...", puser, h->UsableSize, h->FileLine) ; }
        Xfree(puser) ;
        nbytes_pending += h->UsableSize ;
      }
    }
    LoggingDo(LL_ERROR, "%ld bytes were still allocated", nbytes_pending) ;
  }
  if (XAllocData.FileNameBuffer) free(XAllocData.FileNameBuffer) ;
  if (XAllocData.pUser) free(XAllocData.pUser) ;
  memset(&XAllocData, 0, sizeof(XAllocData)) ;
}

void XallocGetDefaultConfig(XALLOC_CONFIG* config)
{
  config->AllocType                 = TA_AUTO ;
  config->MaxSimultaneousAllocs     = DEFAULT_MAX_SIMULTANEOUS_ALLOCS ;
  config->MaxReferencedSrcFilesSize = DEFAULT_MAX_REFERENCED_SRCFILES_SIZE ;
  config->TTRamThreshold            = DEFAULT_TTRAM_THRESHOLD ;
  config->FailRatePM                = 0 ;
  config->StatsEverynSec            = 0 ;
}