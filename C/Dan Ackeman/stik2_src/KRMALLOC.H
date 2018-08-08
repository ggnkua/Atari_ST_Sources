/* *  Header file for my version of malloc from K&R */#ifndef _KRMALLOC_H_#define _KRMALLOC_H_
/*#define MEMDEBUG 1*/
/*  K&R p174    */struct header {    unsigned long size;              struct header *ptr;};typedef struct header HEADER;
int STiKmeminit(unsigned long nbytes);
char * cdecl STiKextmalloc(long nbytes);
char * cdecl STiKextrealloc(char *ob, long bytes);void cdecl STiKextfree(char *ap);
long cdecl STiKextgetfree(int flag);unsigned long cdecl STiKgetfree(int flag);
#if MEMDEBUG
char * cdecl STiKintmalloc(unsigned long reqsize);
char * cdecl STiKmalloc(unsigned long nbytes, const char *file, int line);
char * cdecl STiKrealloc(char *ob, unsigned long newsize, const char *file, int line);
int cdecl STiKfree(char *ap, const char *file, int line);
#define STiKmalloc(s)	STiKmalloc(s, __FILE__, __LINE__ )
#define STiKrealloc(s,t) STiKrealloc(s,t,__FILE__,__LINE__)
#define STiKfree(s)	STiKfree(s,__FILE__,__LINE__)
#elsechar * cdecl STiKmalloc(unsigned long nbytes);
char * cdecl STiKrealloc(char *ob, unsigned long newsize);int cdecl STiKfree(char *ap);
#endif
#endif /* _KRMALLOC_H_ */