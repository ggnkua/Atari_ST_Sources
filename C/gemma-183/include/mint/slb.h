/* SLB defs */

# ifndef _slb_h
# define _slb_h

typedef void *SLB_HANDLE;
typedef long (*SLB_EXEC)(SLB_HANDLE sl, long fn, short nargs, ...);

typedef struct {
	SLB_HANDLE	handle;
	SLB_EXEC	exec;
} SLB;

extern long _slbopen(char *fname, char *path, long ver, void *hnd, void *exec);

# endif

/* EOF */