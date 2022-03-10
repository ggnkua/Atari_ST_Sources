#if __PROTO__
# define	P(s) s
#else
# define P(s) ()
#endif


/* patmat.c */
int patmat P((char *raw , char *pat ));

#undef P
