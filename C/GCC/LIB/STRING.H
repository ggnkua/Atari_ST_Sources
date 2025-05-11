
/* don't know what cruft is supposed to go in here.  what string
   stuff needs to be defined?  Maybe this is just ext defs for
   common string hacking routines? */

#define	index(str, chr)	strchr(str, chr)
#define	rindex(str, chr)	strrchr(str, chr)

extern char * strchr();
extern char * strrchr();
extern char * strcat();
extern char * strncat();
extern char * strcpy();

