/* Parser module for Fracirc, version 2 */
#include "d:\fracirc\header.h"
#include "d:\fracirc\fracirc2.h"

void sortcmd(char *ps,short twin)
{
uint32 rip;int16 rport;
int16 piort;
long t;
short temp;
short lcount=0,offset=0,sln,ccnt=0;
char *dp,*jp;
short mcto;
struct FILEINFO finf;
char temps[2048],temps2[2048];
char temps3[2048];
short ret;
char otp[10][512],otemp[4096];

if(wn[cwin].cnn==wn[twin].cnn)twin=cwin;
bold=0;red=0;reversed=0;underlined=0;reset=0;
dp=ps;
strcpy(otp[0],"\0");strcpy(otp[1],"\0");strcpy(otp[2],"\0");
strcpy(otp[3],"\0");strcpy(otp[4],"\0");strcpy(otp[5],"\0");
strcpy(otp[6],"\0");strcpy(otp[7],"\0");strcpy(otp[8],"\0");
strcpy(otp[9],"\0");strcpy(otemp,"\0");
strcpy(temps,"\0");strcpy(temps2,"\0");

sln=(int16)strlen(ps)+1;
while(offset<sln && ccnt<10){
if(*(dp+lcount)==' '){
*(dp+lcount)=0;
if(ccnt==0){strcpy(otp[ccnt],dp+2);dp=dp+lcount+1;ccnt++;}
else{strcpy(otp[ccnt],dp);dp=dp+lcount+1;ccnt++;}
lcount=-1;
if(*dp==':'){
offset=sln+1;
strcpy(otemp,dp+1);
}
}
lcount++;
offset++;
}

/* 	otp[n]=parameters
	otemp=actual text (apres :)
	hence... 	otp[0]=sender
				otp[1]=command
				otp[2 -> 9]=parameters
*/

/* If its a server message, then parse appropriately */
if(!strstr(otp[0],"!")){
if(!stricmp(otp[0],"ING") || !stricmp(otp[0],"NG") || !stricmp(otp[0],"PING")){
sprintf(temps,"PONG :%s\n",otemp);
srt(&temps,cn[wn[twin].cnn].cn);
return;
}


/* Error codes.. */

if(!stricmp(otp[1],"502")){sendout(otemp,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"501")){sendout(otemp,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"465")){sendout(otemp,twin,col[CERRORS]);disnnect(wn[twin].cnn);return;}
if(!stricmp(otp[1],"464")){sendout(otemp,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"467")){sprintf(temps3,"%s :%s",otp[3],otemp);sendout(temps3,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"471")){sprintf(temps3,"**Cant join %s (Channel is full)",otp[3]);closchan(getchanhan(otp[3]));sendout(temps3,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"472")){sprintf(temps3,"**Unknown mode char: %s",otp[3]);sendout(temps3,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"473")){sprintf(temps3,"**%s is invite only",otp[3]);closchan(getchanhan(otp[3]));sendout(temps3,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"474")){sprintf(temps3,"**You're banned from %s",otp[3]);closchan(getchanhan(otp[3]));sendout(temps3,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"481")){sendout(otemp,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"482")){sprintf(temps3,"**You're not a channel operator (%s)",otp[3]);sendout(temps3,twin,col[CERRORS]);return;}
if(!stricmp(otp[1],"433")){
if(cn[wn[twin].cnn].nickflag==2){
sprintf(temps3,"**%s is not useable, use /nick to rechoose",otp[3]);
sendout(temps3,twin,col[CERRORS]);
cn[wn[twin].cnn].nickflag=1;
}
if(!cn[wn[twin].cnn].nickflag){
if(strlen(conf.snick2)){
sprintf(temps3,"**%s is not useable, attempting second choice nick..",otp[3]);
sendout(temps3,twin,col[CERRORS]);
sprintf(temps,":%s NICK %s\r",cn[wn[cwin].cnn].nick,conf.snick2);
srt(&temps,cn[wn[twin].cnn].cn);
strcpy(cn[wn[twin].cnn].nick,conf.snick2);
cn[wn[twin].cnn].nickflag=2;
info2redraw(twin);
}
else{
sprintf(temps3,"**%s is not useable, use /nick to rechoose",otp[3]);
sendout(temps3,twin,col[CERRORS]);
cn[wn[twin].cnn].nickflag=1;
}
}
return;}
if(!stricmp(otp[1],"401")){
sprintf(temps3,"**%s does not exist as a nick/channel",otp[3]);
sendout(temps3,twin,col[CERRORS]);
return;}



/* Responses */

/* ISON for notify */
if(!stricmp(otp[1],"303")){
lcount=0;offset=0;sln=0;
sln=(int16)strlen(otemp);
dp=otemp;
while(offset<sln){
if(*(dp+lcount)==' ')
{
*(dp+lcount)=0;checnotname(dp,wn[twin].cnn);dp=dp+lcount+1;lcount=-1;}
lcount++;
offset++;
}
mcto=127;
while(mcto>-1){
if(cn[wn[twin].cnn].noton[mcto]==1){
if(!conf.boldnicks)
sprintf(temps,"[Notify]: %s has left IRC",notlist[mcto]);
else
sprintf(temps,"[Notify]: %s has left IRC",notlist[mcto]);

sendout(temps,twin,col[CSYSTEM]);
cn[wn[twin].cnn].noton[mcto]=0;
}
if(cn[wn[twin].cnn].noton[mcto]==2)cn[wn[twin].cnn].noton[mcto]=1;
mcto--;
}
return;
}

if(!stricmp(otp[1],"251")){sendout(otemp,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"252")){sprintf(temps3,"%s %s",otp[3],otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"253")){sprintf(temps3,"%s %s",otp[3],otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"254")){sprintf(temps3,"%s %s",otp[3],otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"255")){sendout(otemp,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"381")){sendout("-+=You are now an IRC operator",twin,col[CBODY]);return;}
if(!stricmp(otp[1],"391")){sprintf(temps3,"[Time]: %s :%s",otp[3],otemp);sendout(temps3,twin,col[CSYSTEM]);return;}
if(!stricmp(otp[1],"375")){sprintf(temps3,"*** %s",otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"376")){
sendout("--Ready--",twin,col[CSYSTEM]);

if(conf.autojoin){
if(strlen(conf.amaj1)){
ret=findfreechannel();
if(ret==-1){sendout("**Auto-join failed",cwin,col[CSYSTEM]);return;}
mcto=0;
while(mcto<30){
if(!stricmp(chan[mcto].name,conf.amaj1) && chan[mcto].win==cwin)return;
mcto++;
}
chan[ret].stat=1;strcpy(chan[ret].name,conf.amaj1);chan[ret].win=cwin;
sprintf(temps,":%s JOIN %s\r",cn[wn[cwin].cnn].nick,conf.amaj1);
srt(&temps,cn[wn[cwin].cnn].cn);
sprintf(temps,"--Auto-join %s",conf.amaj1);
sendout(temps,cwin,col[CSYSTEM]);
dowindinfo(cwin);
}
if(strlen(conf.amaj2)){
ret=findfreechannel();
if(ret==-1){sendout("**Auto-join failed",cwin,col[CSYSTEM]);return;}
mcto=0;
while(mcto<30){
if(!stricmp(chan[mcto].name,conf.amaj2) && chan[mcto].win==cwin)return;
mcto++;
}
chan[ret].stat=1;strcpy(chan[ret].name,conf.amaj2);chan[ret].win=cwin;
sprintf(temps,":%s JOIN %s\r",cn[wn[cwin].cnn].nick,conf.amaj2);
srt(&temps,cn[wn[cwin].cnn].cn);
sprintf(temps,"--Auto-join %s",conf.amaj2);
sendout(temps,cwin,col[CSYSTEM]);
dowindinfo(cwin);
}
}
return;}
if(!stricmp(otp[1],"372")){sprintf(temps3,"** %s",otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"305")){sendout("++You are no longer marked as being away",twin,col[CSYSTEM]);away=0;dowindinfo(twin);return;}
if(!stricmp(otp[1],"306")){sendout("++You have been marked away",twin,col[CSYSTEM]);away=1;dowindinfo(twin);return;}
if(!stricmp(otp[1],"331")){sprintf(temps3,"++Topic in %s unchanged",otp[3]);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"332")){sprintf(temps3,"++Topic in %s set to: %s",otp[3],otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"341")){sprintf(temps3,"++%s invited into %s",otp[4],otp[3]);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"301")){sprintf(temps3,"++%s is away: %s",otp[3],otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"353")){
mcto=getchanhan(otp[4]);
jp=otemp;
jp=strtok(otemp," ");
while(jp){
temp=0;
while(temp<128){
if(!strlen(chan[mcto].nl[temp])){strcpy(chan[mcto].nl[temp],jp);chan[mcto].nn++;temp=128;}
temp++;
}
jp=strtok(NULL," ");
}
nicklistredraw(twin);
return;
}

if(!stricmp(otp[1],"366"))return;
if(!stricmp(otp[1],"314")){sprintf(temps3,"[WHOWAS: %s]: %s %s %s :%s",otp[3],otp[4],otp[5],otp[6],otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"369")){sprintf(temps3,"[WHOWAS: %s]: *** End of WHOWAS list ***",otp[3]);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"311")){sprintf(temps3,"[%s]  User: %s %s %s :%s",otp[3],otp[4],otp[5],otp[6],otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"312")){sprintf(temps3,"[%s]Server: %s :%s",otp[3],otp[4],otemp);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"313")){sprintf(temps3,"[%s]    Op: %s is an IRC operator.",otp[3],otp[3]);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"317")){sprintf(temps3,"[%s]  Idle: %s seconds idle.",otp[3],otp[4]);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"318")){sprintf(temps3,"[%s]:End of WHOIS list",otp[3]);sendout(temps3,twin,col[CBODY]);return;}
if(!stricmp(otp[1],"319")){sprintf(temps3,"[%s]Chnls.: %s",otp[3],otemp);sendout(temps3,twin,col[CBODY]);return;}

strcpy(temps3,otp[3]);strcat(temps3," ");
if(strlen(otp[4])){strcat(temps3,otp[4]);strcat(temps3," ");}
if(strlen(otp[5])){strcat(temps3,otp[5]);strcat(temps3," ");}
if(strlen(otp[6])){strcat(temps3,otp[6]);strcat(temps3," ");}
if(strlen(otp[7])){strcat(temps3,otp[7]);strcat(temps3," ");}
if(strlen(otp[8])){strcat(temps3,otp[8]);strcat(temps3," ");}
if(strlen(otp[9])){strcat(temps3,otp[9]);strcat(temps3," ");}
strcat(temps3,otemp);
sendout(temps3,twin,col[CERRORS]);
return;
}	

/* From now on it must be a client message */
jp=strtok(otp[0],"!");

if(!stricmp(otp[1],"PRIVMSG")){

if(!strnicmp(otemp,"\001PING",5)){
if(conf.boldnicks)
sprintf(temps3,"++%s just pinged you");
else
sprintf(temps3,"++%s just pinged you");
sprintf(temps,":%s NOTICE %s :%s\r",cn[wn[twin].cnn].nick,otp[0],otemp);
srt(&temps,cn[wn[twin].cnn].cn);
sendout(temps3,citw(otp[2],twin),col[CSYSTEM]);
return;
}

if(!strnicmp(otemp,"\001ACTION",7)){
strcpy(temps3,"\0");
if(!stricmp(otp[2],chan[wn[twin].chan].name)){
}
else{
strcpy(temps3,"[");strcat(temps3,otp[2]);strcat(temps3,"] ");
}
if(conf.boldnicks){
strcat(temps3,"");strcat(temps3,otp[0]);strcat(temps3,"");
}
else{strcpy(temps3,otp[0]);}
strcat(temps3," ");strncat(temps3,otemp+8,strlen(otemp)-9);
sendout(temps3,citw(otp[2],twin),col[CACTIONS]);
return;
}

if(!strnicmp(otemp,"\001FRACTALK",9)){
if(ftalk.stat){form_alert(1,"[1][FracTALK in use|New request refused][Okay]");return;}

sprintf(temps,"[1][FracTALK request|from %s|Accept?][No|Yes]",otp[0]);
if(form_alert(2,temps)==1){return;}
strcpy(temps,otemp+10);
sscanf(temps,"%lu %u %u",&ftalk.rip,&ftalk.rportb,&ftalk.rporta);
/* rport and rport[1] are backwards as remote initiated so we need to have it that way (??) :) */
ftalk.cna=TCP_open(ftalk.rip,ftalk.rporta,0,4096);
if(ftalk.cna<0){form_alert(1,"[1][Unable to open|FracTALK connection][Damn]");return;}
ftalk.cnb=TCP_open(ftalk.rip,ftalk.rportb,0,4096);
if(ftalk.cnb<0){form_alert(1,"[1][Unable to open|FracTALK connection][Damn]");return;}
ftalk.stat=SACTIVE;strcpy(ftalk.avec,otp[0]);
doftalk();
return;
}
if(!strnicmp(otemp,"\001DCC CHAT chat",14)){
temp=findfreedccchat();
if(temp==-1){
sendout("**DCC chat: All ports in use",cwin,col[CDCCINFO]);
sprintf(temps,"**Unable to accept from %s",otp[0]);
sendout(temps,cwin,col[CDCCINFO]);
return;
}

sprintf(temps,"[1][DCC chat request|from %s|Accept?][No|Yes]",otp[0]);
if(form_alert(2,temps)==1){return;}

strcpy(temps,otemp+15);
sscanf(temps,"%lu %u",&rip,&rport);
chan[temp].cn=TCP_open(rip,rport,0,4096);
chan[temp].stat=3;strcpy(chan[temp].name,otp[0]);
chan[temp].win=cwin;
wn[cwin].chan=temp;
sprintf(temps3,"++DCC chat with %s initiated",chan[temp].name);
dowindinfo(cwin);
sendout(temps3,citw(otp[2],cwin),col[CDCCINFO]);
return;
}

if(!strnicmp(otemp,"\001SOUND",6)){
if(strlen(otemp)==7){
getsoundlist(&temps2);
sprintf(temps,":%s NOTICE %s :Sounds available: %s\r",cn[wn[twin].cnn].nick,otp[0],temps2);
srt(&temps,cn[wn[twin].cnn].cn);
sprintf(temps3,"++%s requested sound list",otp[0]);
sendout(temps3,twin,col[CSYSTEM]);
return;
}
strcpy(temps3,"++ ");strcat(temps3,otp[0]);
strcat(temps3," played ");
*(otemp+strlen(otemp)-1)=0;
strcpy(temps,otemp+7);
strcat(temps3,temps);strcat(temps3," ++");

playsound(temps);
sendout(temps3,twin,col[CSYSTEM]);
return;
}

if(!strnicmp(otemp,"\001DCC ACCEPT",11)){
strcpy(temps,otemp+12);
jp=strtok(temps," ");
temp=findresmdc(otp[0]);
if(temp==-1){form_alert(1,"[1][Error in DCC|resumption][Damn]");return;}
dcc[temp].stat=RAWAIT;
dcc[temp].dir=DCIN;
dcc[temp].cn=TCP_open(dcc[temp].rip,dcc[temp].rport,0,4096);
sprintf(temps3,"++DCC receive from %s resumed",otp[0]);
strcpy(temps,dcc[temp].fname);
basename(temps);
if(conf.autodcd)opendccrecvdialog(temp,temps);
sendout(temps3,citw(otp[2],twin),col[CSYSTEM]);
return;
}

if(!strnicmp(otemp,"\001DCC SEND",9)){
if(!conf.autodccrecv){
sprintf(temps,"[1][%s initiated|DCC file send|Accept?][No|Yes]",otp[0]);

if(form_alert(0,temps)==1){return;}

}
strcpy(temps,otemp+10);
jp=strtok(temps," ");
basename(jp);
temp=findfreedc();
if(temp<0){form_alert(1,"[1][DCC Error:|No free ports!][Damn]");return;}
strcpy(dcc[temp].fname,path.dcc);
strcat(dcc[temp].fname,jp);
strcpy(temps,otemp+11+strlen(jp));
sscanf(temps,"%lu %u %lu",&dcc[temp].rip,&dcc[temp].rport,&dcc[temp].len);
Fsetdta(&finf);
if(!Fsfirst(dcc[temp].fname,0) && finf.size){
if(!conf.autoresume){
sprintf(temps,"[1][DCC receive: temp|File exists!][Resume|Restart|Abort]");
ret=form_alert(1,temps);
if(ret==3)return;
}
else{
if(ret!=2){
sprintf(temps,":%s PRIVMSG %s :\001DCC RESUME %s %u %lu\001\n",cn[wn[twin].cnn].nick,otp[0],jp,dcc[temp].rport,finf.size);
srt(&temps,cn[wn[twin].cnn].cn);
dcc[temp].dcfh=Fopen(dcc[temp].fname,2);
Fseek(0,dcc[temp].dcfh,SEEK_END);
dcc[temp].stat=RESUME;
dcc[temp].lack=finf.size;
dcc[temp].cnt=finf.size;
dcc[temp].dir=DCIN;
strcpy(dcc[temp].avec,otp[0]);
sendout("--Requesting DCC resume",twin,col[CDCCINFO]);
return;
}
}
}
dcc[temp].dcfh=Fcreate(dcc[temp].fname,0);
if(dcc[temp].dcfh<0){form_alert(1,"[1][Can't create file!|Check the path?][Ok]");return;}
dcc[temp].stat=RAWAIT;
dcc[temp].lack=0;
dcc[temp].cnt=0;
dcc[temp].dir=DCIN;
strcpy(dcc[temp].avec,otp[0]);
dcc[temp].cn=TCP_open(dcc[temp].rip,dcc[temp].rport,0,2048);
sprintf(temps3,"--DCC from %s commenced",otp[0]);
strcpy(temps,dcc[temp].fname);
basename(temps);
if(conf.autodcd)opendccrecvdialog(temp,temps);
sendout(temps3,twin,col[CDCCINFO]);
return;
}

if(!strnicmp(otemp,"\001DCC RESUME",11)){
jp=strtok(otemp+12," ");
strcpy(temps,otemp+12+strlen(jp));
sscanf(temps, "%u %lu",&piort,&dcc[temp].cnt);
temp=findsawaitdc(piort,otp[0]);
dcc[temp].lack=dcc[temp].cnt;
sprintf(temps,":%s PRIVMSG %s :\0001DCC ACCEPT %s %u %lu\001\n",cn[wn[twin].cnn].nick,otp[0],jp,dcc[temp].rport,dcc[temp].cnt);
srt(temps,cn[wn[twin].cnn].cn);
Fseek(dcc[temp].cnt,dcc[temp].dcfh,SEEK_SET);
sendout("++DCC resume granted",twin,col[CDCCINFO]);
dobar(dcc[temp].dcw,(long)dcc[temp].cnt,dcc[temp].len,temp);
return;
}

if(!strnicmp(otemp,"\001VERSION",8)){
sprintf(temps3,":%s NOTICE %s :VERSION :FracIRC V2 - The best GEM client for the Atari (may we live forever)\0\0\0\0\0",cn[wn[twin].cnn].nick,otp[0]);
srt(temps3,cn[wn[twin].cnn].cn);
if(conf.boldnicks)
sprintf(temps3,"++You were versioned by %s",otp[0]);
else
sprintf(temps3,"++You were versioned by %s",otp[0]);
sendout(temps3,twin,col[CSYSTEM]);
return;
}

if(!stricmp(otp[2],cn[wn[twin].cnn].nick)){
if(conf.boldnicks)
sprintf(temps3,"[Pmsg from %s] ",otp[0]);
else
sprintf(temps3,"[Pmsg from %s] ");
strcat(temps3,otemp);
addtotablist(otp[0]);
sendout(temps3,twin,col[CPMSGSFROM]);
return;
}
if(citw(otp[2],twin)!=-1)twin=citw(otp[2],twin);
if(!stricmp(otp[2],chan[wn[twin].chan].name)){
strcpy(temps3,"<");
if(conf.boldnicks){strcat(temps3,"");strcat(temps3,otp[0]);strcat(temps3,"");}
else{strcat(temps3,otp[0]);}
strcat(temps3,"> ");strcat(temps3,otemp);sendout(temps3,twin,col[CBODY]);return;
}
else{
strcpy(temps3,"[");strcat(temps3,otp[2]);strcat(temps3,"] ");
strcat(temps3,"<");
if(conf.boldnicks){strcat(temps3,"");strcat(temps3,otp[0]);strcat(temps3,"");}
else{strcat(temps3,otp[0]);}
strcat(temps3,"> ");strcat(temps3,otemp);
sendout(temps3,twin,col[CBODY]);
return;
}

}

if(!stricmp(otp[1],"JOIN")){
if(!stricmp(otp[0],cn[wn[twin].cnn].nick)){
mcto=findthechannel(otemp);
chan[mcto].stat=2;
if(mcto!=-1){
twin=chan[mcto].win;
sprintf(temps3,"++Joined %s",otemp);
wn[twin].chan=mcto;
dowindinfo(twin);
sendout(temps3,twin,col[CSYSTEM]);
return;
}
else{
sprintf(temps,":%s PART %s\r",cn[wn[twin].cnn].nick,otemp);
srt(&temps,cn[wn[twin].cnn].cn);
return;
}
}
if(conf.boldnicks)
sprintf(temps3,"++%s has joined %s",otp[0],otemp);
else
sprintf(temps3,"++%s has joined %s",otp[0],otemp);
sendout(temps3,citw(otp[2],twin),col[CBODY]);
mcto=getchanhan(otemp);
if(mcto==-1)return;
ret=0;
while(ret<128)
{
if(!strlen(chan[mcto].nl[ret])){strcpy(chan[mcto].nl[ret],otp[0]);ret=128;chan[mcto].nn++;}
ret++;
}
nicklistredraw(citw(otp[2],twin));
return;
}

if(!stricmp(otp[1],"QUIT")){
if(conf.boldnicks)
sprintf(temps3,"++%s quits IRC: %s",otp[0],otemp);
else
sprintf(temps3,"++%s quits IRC: %s",otp[0],otemp);
sendout(temps3,twin,col[CBODY]);
alternickto(otp[0],"\0");
nicklistredraw(twin);
return;
}

/* Remember to check if this is home nick and close channel if it is*/
if(!stricmp(otp[1],"KICK")){
if(conf.boldnicks)
sprintf(temps3,"++%s kicks %s off %s : %s",otp[0],otp[3],otp[2],otemp);
else
sprintf(temps3,"++%s kicks %s off %s : %s",otp[0],otp[3],otp[2],otemp);
sendout(temps3,citw(otp[2],twin),col[CBODY]);
mcto=getchanhan(otp[2]);
if(mcto==-1)return;
ret=0;
while(ret<128)
{
if(!stricmp(chan[mcto].nl[ret],otp[3])){strcpy(chan[mcto].nl[ret],"\0");ret=128;chan[mcto].nn--;}
ret++;
}
nicklistredraw(citw(otp[2],twin));

return;
}
if(!stricmp(otp[1],"MODE")){
if(conf.boldnicks)
sprintf(temps3,"++%s changes mode of %s to: %s%s%s%s%s%s",otp[0],otp[2],otp[3],otp[4],otp[5],otp[6],otp[7],otemp);
else
sprintf(temps3,"++%s changes mode of %s to: %s%s%s%s%s%s",otp[0],otp[2],otp[3],otp[4],otp[5],otp[6],otp[7],otemp);
sendout(temps3,citw(otp[2],twin),col[CBODY]);
return;
}
if(!stricmp(otp[1],"INVITE")){
if(conf.boldnicks)
sprintf(temps3,"++%s has invited you into %s",otp[0],otemp);
else
sprintf(temps3,"++%s has invited you into %s",otp[0],otemp);
sendout(temps3,citw(otp[2],twin),col[CBODY]);
return;
}

if(!stricmp(otp[1],"NICK")){
if(!stricmp(otp[0],cn[wn[twin].cnn].nick)){
if(conf.boldnicks)
sprintf(temps3,"++Nick changed to %s",otemp);
else
sprintf(temps3,"++Nick changed to %s",otemp);

strcpy(cn[wn[twin].cnn].nick,otemp);
dowindinfo(twin);
sendout(temps3,twin,col[CSYSTEM]);
return;
}
if(conf.boldnicks)
sprintf(temps3,"++%s has changed nick to %s",otp[0],otemp);
else
sprintf(temps3,"++%s has changed nick to %s",otp[0],otemp);
sendout(temps3,twin,col[CBODY]);
alternickto(otp[0],otemp);
nicklistredraw(twin);
return;
}

if(!stricmp(otp[1],"PART")){
if(conf.boldnicks)
sprintf(temps3,"++%s has just left %s",otp[0],otp[2]);
else
sprintf(temps3,"++%s has just left %s",otp[0],otp[2]);
sendout(temps3,citw(otp[2],twin),col[CBODY]);
mcto=getchanhan(otp[2]);
if(mcto==-1)return;
ret=0;
while(ret<128)
{
if(!stricmp(chan[mcto].nl[ret],otp[0])){strcpy(chan[mcto].nl[ret],"\0");ret=128;chan[mcto].nn++;}
ret++;
}
nicklistredraw(citw(otp[2],twin));
return;
}

if(!stricmp(otp[1],"TOPIC")){
if(conf.boldnicks)
sprintf(temps3,"++%s changes topic of %s to :%s",otp[0],otp[2],otemp);
else
sprintf(temps3,"++%s changes topic of %s to :%s",otp[0],otp[2],otemp);
sendout(temps3,citw(otp[2],twin),col[CBODY]);
return;
}

if(!stricmp(otp[1],"NOTICE")){
if(!strnicmp(otemp,"\001PING",5)){
strcpy(temps3,"++");
if(conf.boldnicks){strcat(temps3,"");strcat(temps3,otp[0]);strcat(temps3,"");}
else{strcat(temps3,otp[0]);}
strcat(temps3," ponged you: ");
stccpy(temps,otemp+6,strlen(otemp)-1);
time(&t);
t=t-atol(temps);
stcl_d(temps,t);
strcat(temps3,temps);strcat(temps3," seconds");
sendout(temps3,twin,col[CBODY]);
return;
}
if(!strnicmp(otemp,"\001VERSION",5)){
stccpy(temps2,otemp+9,strlen(otemp)-10);
sprintf(temps3,"[%s Version :] %s",otp[0],temps2);
sendout(temps3,twin,col[CBODY]);
return;
}

strcpy(temps3,"[Note from ");
if(conf.boldnicks){strcat(temps3,"");strcat(temps3,otp[0]);strcat(temps3,"");}
else{strcat(temps3,otp[0]);}
strcat(temps3,"] ");strcat(temps3,otemp);
sendout(temps3,twin,col[CPMSGSFROM]);
return;
}

strcpy(temps3,otp[0]);strcat(temps3,"|");strcat(temps3,otp[1]);strcat(temps3,"|");
strcat(temps3,otp[2]);strcat(temps3,"|");strcat(temps3,otp[3]);strcat(temps3,"|");
strcat(temps3,otp[4]);strcat(temps3,"|");strcat(temps3,otp[5]);strcat(temps3,"|");
strcat(temps3,otemp);strcat(temps3,"|");
sendout(temps3,twin,col[CERRORS]);
return;
}

