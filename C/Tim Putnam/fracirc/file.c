 /* Fracirc file operations module, 26/1/97 */

#include "header.h"
int writeanurl(char *ps)
{
long fh;
fh=Fopen(path.url,1);
if(fh)Fseek(0,fh,SEEK_END);
if(fh<0){
fh=Fcreate(path.url,0);
Fwrite(fh,29,"+= Fracirc URL-grab list =+\n");
}
if(fh<0){form_alert(1,"[1][Error opening URL file][Oooh!]");return 0;}
Fwrite(fh,(int16)strlen(ps),ps);
Fwrite(fh,2,"\n");
return 0;
}
int openlog()
{
lh=Fopen(path.log,1);
if(lh)Fseek(0,lh,SEEK_END);
if(lh<0){
lh=Fcreate(path.log,0);
logop=1;
tlog("*****Fracirc V1.10 Log file******");
}
if(lh<0){form_alert(1,"[1][Error opening log][Ooh!]");return 0;}
logop=1;
tlog("*****Session opened*****");
return 0;
}

int closelog()
{
tlog("*****Session closed*****");
Fclose(lh);
logop=0;
return 0;
}
int tlog(char *stw)
{
if(logop){
Fwrite(lh,(int16)strlen(stw),stw);
Fwrite(lh,2,"\n");
}
return 0;
}

int loadmacs(char *fn)
{
long th;
char *jp;
short lcount=0,offset=0,sln,ccnt=0;
char temps[2048];
if(fn!=NULL)th=Fopen(fn,0);
if(fn==NULL)th=Fopen("FRACIRC.MCR",0);
if(th<0 && fn!=NULL){form_alert(1,"[1][File error][Oooh!]");return 0;}
if(th<0 && fn==NULL){return 0;}
Fread(th,1500,temps);
jp=temps;
sln=(int16)strlen(temps)+1;

while(offset<sln){
if(*(jp+lcount)=='Ý'){
*(jp+lcount)=0;strcpy(macs[ccnt],jp);jp=jp+lcount+1;lcount=-1;ccnt++;
}
if(ccnt==10)offset=sln;
offset++;
lcount++;
}
Fclose(th);
return 0;
}

int loadwins(char *fn)
{
long th;
short mcto=0;
short x,no;
if(fn!=NULL)th=Fopen(fn,0);
if(fn==NULL)th=Fopen("FRACIRC.WIN",0);
if(th<0 && fn!=NULL){form_alert(1,"[1][Windows: File error][Oooh!]");return 0;}
if(th<0 && fn==NULL){return 0;}
mcto=0;
while(mcto<NOFWIN){
Fread(th,2,&no);
Fread(th,2,&wn[mcto].wwa.g_x);
Fread(th,2,&wn[mcto].wwa.g_y);
Fread(th,2,&wn[mcto].wwa.g_w);
Fread(th,2,&wn[mcto].wwa.g_h);
flag=FALSE;
if(wn[mcto].hand==-1 && no>-1){openwin(wn[mcto].wwa.g_x,wn[mcto].wwa.g_y,wn[mcto].wwa.g_w,wn[mcto].wwa.g_h,0);flag=TRUE;}
if(wn[mcto].hand>-1 && !flag && no>-1){resizewindow(mcto,wn[mcto].wwa.g_x,wn[mcto].wwa.g_y,wn[mcto].wwa.g_w,wn[mcto].wwa.g_h);}
mcto++;
}
Fread(th,2,&x);
topwindow(x);
Fclose(th);
return 0;
}

void gn(char *jp)
{
jp=jp+strlen(jp)+1;
}
void loadprefs(char *fn)
{
int counter;
long th;
char *jp;
char buf[4096];
short mcto=0;
if(fn!=NULL){th=Fopen(fn,0);}else{th=Fopen("FRACIRC.INF",0);}
if(th<0){
if(fn!=NULL){form_alert(1,"[1][Can't open|config file][Okay]");return;}
else{form_alert(1,"[1][Unable to find|FRACIRC.INF][Use defaults]");return;}
}
Fread(th,4095,&buf);
Fclose(th);
jp=buf;
printf("\r%s",jp);
strcpy(conf.snick,jp);
gn(jp);strcpy(conf.snick2,jp);
counter=3;
while(counter>-1){
gn(jp);strcpy(irc_server[counter],jp);
gn(jp);strcpy(irc_port[counter],jp);
counter--;
}
counter=0;
while(counter<25){
gn(jp);sscanf(jp,"%d",col[counter]);
counter++;
}
gn(jp);strcpy(path.dcc,jp);
gn(jp);strcpy(path.sound,jp);
gn(jp);strcpy(path.url,jp);
gn(jp);strcpy(path.log,jp);
gn(jp);strcpy(hostname,jp);
gn(jp);strcpy(realname,jp);
gn(jp);strcpy(username,jp);
counter=0;
while(counter<8){
gn(jp);strcpy(ann[counter],jp);
gn(jp);strcpy(am[counter],jp);
counter++;
}
gn(jp);sscanf(jp,"%d",winfont);
gn(jp);sscanf(jp,"%d",winpoint);
gn(jp);sscanf(jp,"%d",inpfont);
gn(jp);sscanf(jp,"%d",inppoint);
gn(jp);sscanf(jp,"%d",ndelay);
gn(jp);strcpy(conf.amaj1,jp);
gn(jp);strcpy(conf.amaj2,jp);
gn(jp);sscanf(jp,"%d",conf.boldnicks);
gn(jp);sscanf(jp,"%d",conf.autodcd);
gn(jp);sscanf(jp,"%d",conf.smothscrol);
gn(jp);sscanf(jp,"%d",conf.autodccrecv);
gn(jp);sscanf(jp,"%d",conf.smscrolspd);
gn(jp);sscanf(jp,"%d",conf.urlgrab);
gn(jp);sscanf(jp,"%d",conf.autonewwindow);
gn(jp);sscanf(jp,"%d",conf.playsounds);
gn(jp);sscanf(jp,"%d",conf.autoresume);
gn(jp);sscanf(jp,"%d",conf.typethru);
gn(jp);sscanf(jp,"%d",conf.autojoin);
gn(jp);sscanf(jp,"%d",conf.nickchan);
gn(jp);sscanf(jp,"%d",conf.dccav);
addautonot();
setwinfont();
setinpfont();
}

int savprefs(char *fn)
{
long th;
int counter;
char buf[4096],buf2[2048];
th=Fcreate(fn,0);
if(th<0){form_alert(1,"[1][File error][Okay]");return 0;}
sprintf(buf2,"%s\0%s",conf.snick,conf.snick2);Fwrite(th,strlen(buf2),&buf2);
counter=3;
while(counter>-1){
sprintf(buf2,"%s\0%s",irc_server[counter],irc_port[counter]);Fwrite(th,strlen(buf2),&buf2);
counter--;
}
counter=0;
while(counter<25){
sprintf(buf2,"%d",col[counter]);Fwrite(th,strlen(buf2),&buf2);
counter++;
}
sprintf(buf2,"%s\0%s\0%s\0%s",path.dcc,path.sound,path.url,path.log);Fwrite(th,strlen(buf2),&buf2);
sprintf(buf2,"%s\0%s\0%s",hostname,realname,username);Fwrite(th,strlen(buf2),&buf2);
counter=0;
while(counter<8){
sprintf(buf2,"%s\0%s",ann[counter],am[counter]);Fwrite(th,strlen(buf2),&buf2);
counter++;
}
sprintf(buf2,"%d\0%d\0%d\0%d\0%d",&winfont,&winpoint,&inpfont,&inppoint,&ndelay);Fwrite(th,strlen(buf2),&buf2);
sprintf(buf2,"%s\0%s",conf.amaj1,conf.amaj2);Fwrite(th,strlen(buf2),&buf2);
sprintf(buf2,"%d\0%d\0%d\0%d\0%d",&conf.boldnicks,&conf.autodcd,&conf.smothscrol,&conf.autodccrecv,&conf.smscrolspd);Fwrite(th,strlen(buf2),&buf2);
sprintf(buf2,"%d\0%d\0%d\0%d\0%d",&conf.urlgrab,&conf.autonewwindow,&conf.playsounds,&conf.autoresume,&conf.typethru);Fwrite(th,strlen(buf2),&buf2);
sprintf(buf2,"%d\0%d\0%d",&conf.autojoin,&conf.nickchan,&conf.dccav);Fwrite(th,strlen(buf2),&buf2);


Fwrite(th,strlen(buf2),&buf2);
Fclose(th);
return 0;
}



int savmacs(char *fn)
{
long th;
char temps[2048];
th=Fcreate(fn,0);
if(th<0){form_alert(1,"[1][File error][Oooee!]");return 0;}
strcpy(temps,"\0");
strcpy(temps,macs[0]);strcat(temps,"Ý");
strcat(temps,macs[1]);strcat(temps,"Ý");
strcat(temps,macs[2]);strcat(temps,"Ý");
strcat(temps,macs[3]);strcat(temps,"Ý");
strcat(temps,macs[4]);strcat(temps,"Ý");
strcat(temps,macs[5]);strcat(temps,"Ý");
strcat(temps,macs[6]);strcat(temps,"Ý");
strcat(temps,macs[7]);strcat(temps,"Ý");
strcat(temps,macs[8]);strcat(temps,"Ý");
strcat(temps,macs[9]);strcat(temps,"Ý");
Fwrite(th,strlen(temps),temps);
Fclose(th);
return 0;
}

int savwins(char *fn)
{
long th;
GRECT ws;
short mcto=0;
th=Fcreate(fn,0);
if(th<0){form_alert(1,"[1][File error][Oooee!]");return 0;}
while(mcto<6){
wind_get(wn[mcto].hand,WF_CURRXYWH,&ws.g_x,&ws.g_y,&ws.g_w,&ws.g_h);
Fwrite(th,2,&wn[mcto].hand);
Fwrite(th,2,&ws.g_x);
Fwrite(th,2,&ws.g_y);
Fwrite(th,2,&ws.g_w);
Fwrite(th,2,&ws.g_h);
mcto++;
}
Fwrite(th,2,&cwin);
Fclose(th);
return 0;
}

