/* varargs declarations: */
/* you might have to hand force this  by doing #define HAVE_STDARG_H */

#include <stdarg.h>
#define VA_LOCAL_DECL   va_list ap;
#define VA_START(f)     va_start(ap, f)
#define VA_SHIFT(v,t)  ;   /* no-op for ANSI */
#define VA_END          va_end(ap)

/* you can have ANSI C definitions */
int plp_snprintf (char *str, size_t count, const char *fmt, ...);
int vplp_snprintf (char *str, size_t count, const char *fmt, va_list arg);

#define vsnprintf vplp_snprintf

