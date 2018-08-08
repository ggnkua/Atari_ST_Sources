#ifndef _RESOLVE_H_
#define _RESOLVE_H_

/* functions in resolve.c	*/
extern unsigned long dd_to_ip(char *);
extern int16 cdecl resolve(char *, char **, uint32 *, int16);
extern int16 resolveinit(void);
extern void do_resolve(void);

#define MAX_QUERY	40		/* Max number of DNS queries.				*/
#define MAXDOMAINLEN	255		/* Max length of domain names */

#endif
