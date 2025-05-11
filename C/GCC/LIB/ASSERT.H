#undef assert

#ifdef NDEBUG
#define assert(ignore)
#else

#define assert(expression)  \
  do { if (!(expression)) __assert ((expression), __FILE__, __LINE__); } while (0)

#define __assert(expression, file, line)  \
  { _eprintf ("Failed assertion " #expression		\
	      " at line %d of `" file "'.\n", line);	\
    abort (); }

void _eprintf ();		/* Defined in gnulib */

#endif
