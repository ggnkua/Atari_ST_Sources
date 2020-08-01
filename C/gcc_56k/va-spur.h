/*  varargs.h for SPUR */

/* NB.  This is NOT the definition needed for the new ANSI proposed
   standard */
 

struct __va_struct { char regs[20]; };

#define va_alist __va_regs, __va_stack

#define va_dcl struct __va_struct __va_regs; int __va_stack;

typedef struct {
    int pnt;
    char *regs;
    char *stack;
} va_list;

#define va_start(pvar) \
     ((pvar).pnt = 0, (pvar).regs = __va_regs.regs, \
      (pvar).stack = (char *) &__va_stack)
#define va_end(pvar)

#define va_arg(pvar,type)  \
    ({  type __va_result; \
        if ((pvar).pnt >= 20) { \
           __va_result = *( (type *) ((pvar).stack + (pvar).pnt - 20)); \
	   (pvar).pnt += (sizeof(type) + 7) & ~7; \
	} \
	else if ((pvar).pnt + sizeof(type) > 20) { \
	   __va_result = * (type *) (pvar).stack; \
	   (pvar).pnt = 20 + ( (sizeof(type) + 7) & ~7); \
	} \
	else if (sizeof(type) == 8) { \
	   union {double d; int i[2];} __u; \
	   __u.i[0] = *(int *) ((pvar).regs + (pvar).pnt); \
	   __u.i[1] = *(int *) ((pvar).regs + (pvar).pnt + 4); \
	   __va_result = * (type *) &__u; \
	   (pvar).pnt += 8; \
	} \
	else { \
	   __va_result = * (type *) ((pvar).regs + (pvar).pnt); \
	   (pvar).pnt += (sizeof(type) + 3) & ~3; \
	} \
	__va_result; })
