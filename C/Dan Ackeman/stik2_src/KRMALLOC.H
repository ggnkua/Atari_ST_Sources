/*
/*#define MEMDEBUG 1*/


char * cdecl STiKextmalloc(long nbytes);
char * cdecl STiKextrealloc(char *ob, long bytes);
long cdecl STiKextgetfree(int flag);
#if MEMDEBUG
char * cdecl STiKintmalloc(unsigned long reqsize);
char * cdecl STiKmalloc(unsigned long nbytes, const char *file, int line);
char * cdecl STiKrealloc(char *ob, unsigned long newsize, const char *file, int line);
int cdecl STiKfree(char *ap, const char *file, int line);
#define STiKmalloc(s)	STiKmalloc(s, __FILE__, __LINE__ )
#define STiKrealloc(s,t) STiKrealloc(s,t,__FILE__,__LINE__)
#define STiKfree(s)	STiKfree(s,__FILE__,__LINE__)
#else
char * cdecl STiKrealloc(char *ob, unsigned long newsize);
#endif
