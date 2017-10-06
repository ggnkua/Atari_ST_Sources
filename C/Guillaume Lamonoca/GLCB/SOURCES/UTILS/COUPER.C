/*
cc -c x11.c
cc couper.c x11.o -lX11 -s -o coupe
*/

#include "header.h"


main(n,p)
int n;
char *p[];
{
long l;
char *adr;
long LEN=700*1024L;
long offset=0L;
char s[80];
int no=0;
long ln;

if (n!=3)
{
printf("usage: couper file generic_name \n");
printf("(will load file, DELETE it (dangerous!), then create\n");
printf("generic_name0,generic_name1, etc...(up to 700ko each) )\n");
}
else
if (!bexist(p[1])) printf("%s not found\n",p[1]); else
{
l=bsize(p[1]);
if (l<=LEN) printf("file already small!"); else
if (!(adr=memalloc(l))) printf("not enough memory\n"); else
{

bload(p[1],adr,0L,l);
printf("%s loaded\n",p[1]);
bmake(p[1],adr,0L);
printf("%s deleted (length:0)\n",p[1]);

ln=LEN;
while(offset<l)
{
if (offset+LEN>l) ln=l-offset;
sprintf(s,"%s%d",p[2],no);
bmake(s,adr+offset,ln);
printf("%s saved\n",s);
offset+=LEN;
no++;
}


memfree(&adr);
}
}

}
