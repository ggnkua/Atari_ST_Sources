#ifndef __SLB_H
#define __SLB_H

typedef void* SLB_HANDLE;
typedef long cdecl (*SLB_EXEC)(SLB_HANDLE sl, long fn, short nargs, ... ) ;

typedef struct
{
  SLB_HANDLE handle ;
  SLB_EXEC   exec ;
}
SLB, *PSLB ;

#define SLB_MAGIC 0x70004AFCL
typedef struct
{
	long magic ;
	const char *name ;
	long version ;
	long flags ;
	void cdecl (*slb_init) (void) ;
	void cdecl (*slb_exit) (void) ;
	void cdecl (*slb_open) (void*) ;
	void cdecl (*slb_close) (void*) ;
	const char *const *procnames ;
	long next ;
	long reserved[7] ;
	long num_funcs ;
	/* long funcs_table[]; */
} SLB_HEADER, *PSLB_HEADER ;

/* Partial SHARED_LIB for debug purpose */
struct shared_lib
{
  SLB_HANDLE* slb_next ; /* Pointer to next element in list */
  SLB_HEADER* slb_head ; /* Pointer to library header */
  char        stuff[1] ;
} ;

extern long Slbopen(char* name, char* path, long min_ver, SLB_HANDLE* sl, SLB_EXEC* fn) ;
extern long Slbclose(SLB_HANDLE sl) ;

#endif