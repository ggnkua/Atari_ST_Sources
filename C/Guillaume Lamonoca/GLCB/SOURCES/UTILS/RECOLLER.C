/*
cc -c x11.c
cc recoller.c x11.o -lX11 -s -o coupe
*/

#include "header.h"


main(n,p)
int n;
char *p[];
{
long l;
char *adr;
long LEN=700*1024L;
char s[80];
int no=0;
int f;
int existe=1;

if (n!=3)
{
printf("usage: recoller file generic_name \n");
printf("(will load generic_name0,generic_name1, etc... \n");
printf(" then DELETE them(dangerous!) while rebuilding file.)\n");
}
else
if ((f=bcreate(p[1]))<=0) printf("can't create %s\n",p[1]); else
if (!(adr=memalloc(LEN))) printf("not enough memory\n"); else
{

while(existe)
{
sprintf(s,"%s%d",p[2],no);
if (existe=bexist(s))
{
l=bsize(s);
if (l>LEN) { printf("%s is too long! (i truncate!)\n",s); l=LEN; } 
bload(s,adr,0L,l);
printf("%s loaded\n",s);
bmake(s,adr,0L);
printf("%s deleted (length:0)\n",s);
bwrite(f,adr,l);
printf("rebuilding %s (part %d)\n",p[1],no);
no++;
}
}

bclose(f);

memfree(&adr);
}

}
