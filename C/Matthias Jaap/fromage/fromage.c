#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
int main(int g,char**h){int c;char*i,j,*b;FILE*w;ptrdiff_t a,d,e,f,k,l,o,p,s,t,u
,v,x,y;for(i=b=NULL,c=e=f=k=l=o=s=u=x=0,w=--g?fopen(h[1],"r"):stdin;c-EOF;){x<l?
(c=i[x]):(i=realloc(i,++l),i[l-1]=c=getc(w)),c-EOF&&(p=k+!(c-'(')-!(c-')'),v=u+!
(c-'}')-!(c-'{'),a=f-!(c-']'),y=c==';',(t=s+!(c-'>')-!(c-'<'))/8<o||(b=realloc(b
,++o),b[o-1]=0),d=!(b[t/8]&(j=1<<7-t%8)),c-'['||(y+=d,++a),d^=c!=':',u?(p=a=y=0)
:k?(v=a=y=0):e?(f=(a?a<0:y)?(e=0):a,v=p=0):(e=!!y),x+=(u=v*=v>0)?-1:(k=p*=p>0)?1
:e||(t==8&d?putchar(*b):t==9&d?*b=getchar():(b[t/8]=b[t/8]&~j|d*j),s=t,1));}g&&
fclose(w),exit(0);}
