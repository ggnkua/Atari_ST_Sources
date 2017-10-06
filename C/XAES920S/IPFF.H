/* HR: Input Parameters in Free Format */
#ifndef PRELUDE_H
#include "prelude.h"
#endif
char *ipff_init	(int m, int p, int f, char *t,char *l,char **tt);
void ipff_in(char *p);
char *ipff_line(long *);
char *ipff_getp(void);
void ipff_putp (char *s),nstr(char *),
     ipff_trail(char *);
int sk(void),skc(void),sk1(void),
    idec(void),str(char *),
    lstr(char *, unsigned long),
    fstr(char *,int);
long dec(void),hex(void),oct(void),bin(void);
char *Fload(const char *name, int *fh, long *l);
