/* Sound code (treat CAREFULLY!) */

#define MGLOBAL	0x20
#define VA_START	0x4711
#define AV_STARTED 0x4738
#define GEMJING_RETURN	0x7407
#define MagX_COOKIE	0x4D616758L
#define MiNT_COOKIE	0x4D694E54L

extern BASEPAGE *gjbp;
BOOLEAN MagiC, MultiTOS,MiNT;

#include "header.h"

int getsoundlist(char *ps)
{
char temp[500];
struct FILEINFO info;
strcpy(ps,"\0");
strcpy(temp,path.sound);
strcat(temp,"*.WAV");
if(strlen(temp)){
if(!dfind(&info,temp,0))
do{
strcat(ps,info.name);strcat(ps," ");
} while (!dnext(&info));
}
return 1;
}



int playsound(char *ps)
{
BYTE *playbuf;
long val;
short mcto=0;
WORD msg[8],i;
if(conf.playsounds){

if((getcookie(MiNT_COOKIE,&val) == TRUE))
{
MiNT = TRUE;
	if(GemParBlk.global[1] > 1 || GemParBlk.global[1]==-1)
	MultiTOS = TRUE;
}
if(getcookie(MagX_COOKIE,&val)==TRUE)
MagiC=TRUE;

if(MagiC == TRUE || MiNT==TRUE)
playbuf=(BYTE *)Mxalloc (150,0|MGLOBAL);
else
playbuf=(BYTE *)Malloc(150);

strcpy(playbuf,"-q ");strcat(playbuf,path.sound);strcat(playbuf,ps);
checkgemjingpresent();
i=-1;
while(mcto<10 && i<0){
if((i=appl_find("GEMJING ")) >= 0)
{
msg[0]=VA_START;
msg[1]=appl_id;
msg[2]=0;
msg[3]=(WORD)(((LONG)playbuf>>16)&0x0000ffff);
msg[4]=(WORD)((LONG)playbuf & 0x0000ffff);
msg[5]=0;
msg[6]=0;
msg[7]=0;
appl_write(i,16,msg);
}
mcto++;
}

Mfree(playbuf);
}
return 0;
}

void checkgemjingpresent()
{
char *PathofGEMJing;
if(appl_find("GEMJING ")>=0)return;
PathofGEMJing=getenv("GEMJINGPATH");
if(PathofGEMJing && strlen(PathofGEMJing) >0){
if(MultiTOS == TRUE)
shel_write(0,1,1,PathofGEMJing,NULL);
else if (MagiC==TRUE)
shel_write(1,1,100,PathofGEMJing,NULL);
}

return;
}


