
/*                 varg.h                     */
/* Verwaltung variabel langer Argumentlisten  */
/*             (c) Roman Hodek                */

typedef char *va_list; 

#define va_start(p,l) ( p=(va_list)(&(l)+1) )
#define va_arg(p,t)   (*((t *)(p+=sizeof(t))-1))
#define va_end(p)     p


