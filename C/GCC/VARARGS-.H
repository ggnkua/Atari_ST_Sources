/*  varargs.h for SPUR */

/* NB.  This is NOT the definition needed for the new ANSI proposed
   standard */
 

struct va_struct { char regs[20]; };

#define va_alist va_regs, va_stack

#define va_dcl struct va_struct va_regs; int va_stack;

typedef int va_list;

#define va_start(pvar) ((pvar) = 0)

#define va_arg(pvar,type)  \
    ({  type va_result; \
        if ((pvar) >= 20) { \
           va_result = *( (type *) (&va_stack + ((pvar) - 20)/4)); \
	   (pvar) += (sizeof(type) + 7) & ~7; \
	} \
	else if ((pvar) + sizeof(type) > 20) { \
	   va_result = * (type *) &va_stack; \
	   (pvar) = 20 + ( (sizeof(type) + 7) & ~7); \
	} \
	else if (sizeof(type) == 8) { \
	   union {double d; int i[2];} u; \
	   u.i[0] = *(int *) (va_regs.regs + (pvar)); \
	   u.i[1] = *(int *) (va_regs.regs + (pvar) + 4); \
	   va_result = * (type *) &u; \
	   (pvar) += (sizeof(type) + 3) & ~3; \
	} \
	else { \
	   va_result = * (type *) (va_regs.regs + (pvar)); \
	   (pvar) += (sizeof(type) + 3) & ~3; \
	} \
	va_result; })
