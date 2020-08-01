struct __va_struct { int fixed[12]; int floating[8]; };

typedef struct __va_ctl
{
  struct __va_struct *regs;
  void *stack;
  int nfixed, nfloating;
} va_list;

#define va_alist

#define va_dcl

#define va_start(pvar) \
 (memcpy (&(pvar), (struct __va_ctl *) __builtin_saveregs (), 80))
#define va_end(pvar)

#define va_arg(pvar,type)					\
({ type __va_temp;						\
   *((__builtin_classify_type (__va_temp) < 8			\
      && sizeof __va_temp < 8)					\
     ? ((pvar).nfixed < 12					\
	? (type *) &(pvar).regs->fixed[(pvar).nfixed++]		\
	: ({							\
	     int temp						\
	       = ((int) ((pvar).stack + __alignof__ (type) - 1)	\
		  & ~(__alignof__ (type) - 1));			\
	     (pvar).stack = (void *) (temp + sizeof (type));	\
	     (type *) temp; 					\
	   }))							\
     : __builtin_classify_type (__va_temp) < 9			\
     ? ((pvar).nfloating < 8					\
	? ((pvar).nfloating					\
	     = (((pvar).nfloating + 2 * (sizeof __va_temp / 4) - 1) \
		& ~(sizeof __va_temp / 4 - 1)),			\
	   (type *) &(pvar).regs->floating[(pvar).nfloating - (sizeof __va_temp / 4)]) \
	: ({							\
	     int temp						\
	       = ((int) ((pvar).stack + __alignof__ (type) - 1)	\
		  & ~(__alignof__ (type) - 1));			\
	     (pvar).stack = (void *) (temp + sizeof (type));	\
	     (type *) temp; 					\
	   }))							\
     : ({							\
	  int temp						\
	    = ((int) ((pvar).stack + __alignof__ (type) - 1)	\
	       & ~(__alignof__ (type) - 1));			\
	  (pvar).stack = (void *) (temp + sizeof (type));	\
	  (type *) temp; 					\
	})); })
