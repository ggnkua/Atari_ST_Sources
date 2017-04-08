unsigned long _STACK=16384;

#define extern
#include "header.h"
#undef extern


void initvariables(void)
{
short mcto=0;
strcpy(fpath,"\0");
Dgetpath(fpath,0);
strcat(fpath,"\\*.*");

ftalk.cna=-1;
ftalk.cnb=-1;

while(mcto<20){
strcpy(macs[mcto],"\0");
mcto++;
}
mcto=0;
while(mcto<5){
strcpy(am[mcto],"\0");
mcto++;
}

mcto=0;
while(mcto<NOFWIN){
wn[mcto].hand=-1;
wn[mcto].chan=-1;
cn[mcto].auth=-1;
cn[mcto].cn=-1;
strcpy(cn[mcto].nick,conf.snick);
mcto++;
}
dctbufsize=1024; /*DCC file - transfer block size */
soff=0;serv=0;
winfont=1;winpoint=10;inpfont=1;inppoint=10;
mnormg=0;
mdrag=0;
conf.boldnicks=1;
conf.autodcd=1;
conf.smothscrol=0;
conf.autodccrecv=1;
conf.smscrolspd=2;
conf.urlgrab=0;
conf.autonewwindow=0;
conf.playsounds=0;
conf.autoresume=0;
conf.typethru=0;

pfctcr=0;
fversion=1200; /* here the 1 signifies beta and the rest the version */
ndelay=5;
logop=0;
cwin=-1;
wcount=0;
blink=2;
col[0]=1;col[1]=1;col[2]=1;col[3]=1;col[4]=1;col[5]=1;col[6]=1;
col[7]=1;col[8]=1;col[9]=0;col[10]=1;col[11]=1;col[12]=1;col[13]=1;

notcount=0;
strcpy(conf.snick,"Joeblogg");
strcpy(conf.snick2,"Joeblog2");
strcpy(MenuTitle,"  FracIRC");
}

