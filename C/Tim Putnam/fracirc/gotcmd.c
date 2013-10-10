/* Input parser module for Fracirc 21/1/97 V1.00 */
#include "d:\fracirc\header.h"
#include "d:\fracirc\fracirc2.h"

void gotcmd(void)
{
long t;
short junk2,junk3;
short mcto;
char *ds;
short sln,offset=0,lcount=0,ccnt=0;
char temps[2048],temps2[2048];
char lip[5][512],rip[5][512];
char ipall[512];
BOOLEAN gflg=FALSE;

if(!strlen(wn[cwin].inp))return;
strcpy(lip[0],"\0");strcpy(lip[1],"\0");
strcpy(lip[2],"\0");strcpy(lip[3],"\0");
strcpy(lip[4],"\0");strcpy(rip[0],"\0");
strcpy(rip[1],"\0");strcpy(rip[2],"\0");
strcpy(rip[3],"\0");strcpy(rip[4],"\0");


ds=(char *)&wn[cwin].inp;
strcpy(ipall,wn[cwin].inp);
sln=(int16)strlen(ds);
while(offset<=sln){
if(*(ds+lcount)==' '){
if(lcount>99){offset=offset-(lcount-99);lcount=99;}
*(ds+lcount)=0;
strcpy(lip[ccnt],ds);ds=ds+lcount+1;lcount=-1;strcpy(rip[ccnt],ds);
ccnt++;
}
if(ccnt==5)offset=sln+1;
lcount++;
offset++;
}
if(ccnt<5)strcpy(lip[ccnt],ds);
strcpy(wn[cwin].inp,"\0");
/* Template for output of input parser

	1111 2222 3333 4444 5555 6666 7777 8888 
ipall=everything
lip[0]=1111 rip[0]=2222 3333 etc
lip[1]=2222 rip[1]=3333 4444 etc
lip[4]=5555 rip[4]=6666 7777 etc

*/

if(!stricmp(lip[0],"/quit") || !stricmp(lip[0],"/bye") || !stricmp(lip[0],"/exit") || !stricmp(lip[0],"\q")){
disnnect(wn[cwin].cnn);
return;
}

if(!stricmp(lip[0],"/ftalk")){
if(ftalk.stat){
sendout("**FracTALK already in operation",cwin,col[CERRORS]);return;}
if(!strlen(lip[1])){
sendout("**Please specify remote: /ftalk <remote>",cwin,col[CERRORS]);return;}
initftalk(lip[1]);
return;
}

if(!stricmp(lip[0],"/leave") || !stricmp(lip[0],"/leav") || !stricmp(lip[0],"/lea")){
if(strlen(lip[1]) && getchanhan(lip[1])!=-1){closchan(getchanhan(lip[1]));return;}
closchan(wn[cwin].chan);
return;
}

if(!stricmp(lip[0],"/away") || !stricmp(lip[0],"/awa") || !stricmp(lip[0],"/aw")){
sprintf(temps,":%s AWAY",cn[wn[cwin].cnn].nick);
if(strlen(am[AMAWAY])){
strcat(temps," :");
strcat(temps,am[AMAWAY]);strcat(temps,"\r");}
else{
if(strlen(rip[0])){
strcat(temps,rip[0]);strcat(temps,"\r");}
}
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/unaway") || !stricmp(lip[0],"/unaw") || !stricmp(lip[0],"/back")){
sprintf(temps,":%s AWAY\r",cn[wn[cwin].cnn].nick);
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/fsel")){
fselector(temps,"File selector",1);
return;
}

if(!stricmp(lip[0],"/time")){
sprintf(temps,":%s TIME %s\r",cn[wn[cwin].cnn].nick,rip[0]);
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}


if(!stricmp(lip[0],"/topic") || !stricmp(lip[0],"/top")){
sprintf(temps,":%s TOPIC ",cn[wn[cwin].cnn].nick);
if(wn[cwin].chan>-1 && chan[wn[cwin].chan].stat==2){
strcat(temps,chan[wn[cwin].chan].name);
if(strlen(rip[0])){strcat(temps," :");strcat(temps,rip[0]);strcat(temps,"\r");}
else{strcat(temps,"\r");}
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}
else{
sendout("**You're not in a channel",cwin,col[CERRORS]);
return;
}
}

if(!stricmp(lip[0],"/join") || !stricmp(lip[0],"/j")){
junk2=findfreechannel();
if(junk2==-1){sendout("**No more free channels",cwin,col[CERRORS]);return;}
mcto=0;
while(mcto<30){
if(!stricmp(chan[mcto].name,lip[1]) && chan[mcto].win==cwin && chan[mcto].stat)
{
sendout("**Channel already joined",cwin,col[CERRORS]);
return;
}
mcto++;
}
chan[junk2].stat=1;
if(!strlen(lip[1])){sendout("**Syntax: /join <channel>",cwin,col[CERRORS]);return;}
strcpy(chan[junk2].name,lip[1]);
if(conf.autonewwindow && wn[cwin].chan!=-1)openwin(0,0,0,0,1);
chan[junk2].win=cwin;
sprintf(temps,":%s JOIN %s\r",cn[wn[cwin].cnn].nick,lip[1]);
srt(&temps,cn[wn[cwin].cnn].cn);
sprintf(temps,"--Sending request to join %s",lip[1]);
sendout(temps,cwin,col[CSYSTEM]);
dowindinfo(cwin);
return;
}

if(!stricmp(lip[0],"/log")){
if(!stricmp(lip[1],"off")){closelog();menu_icheck(mnu,mlogging,0);return;}
if(!stricmp(lip[1],"on")){openlog();menu_icheck(mnu,mlogging,1);return;}
if(!stricmp(lip[1],"write")){
sendout("--String sent to logfile",cwin,col[CSYSTEM]);
if(strlen(rip[1]))tlog(rip[1]);
return;}
sendout("**Syntax: /log [off][on][write [message]]",cwin,col[CERRORS]);
return;
}

if(!stricmp(lip[0],"/nick") || !stricmp(lip[0],"/n")){
if(strlen(lip[1])>9){
sendout("**Nick is 9 characters maximum",cwin,col[CERRORS]);
return;}
if(!strlen(lip[1])){
sendout("**Syntax: /nick <new nick>",cwin,col[CERRORS]);
return;}
sprintf(temps,":%s NICK %s\r",cn[wn[cwin].cnn].nick,lip[1]);
srt(&temps,cn[wn[cwin].cnn].cn);
if(cn[wn[cwin].cnn].nickflag){
strcpy(cn[wn[cwin].cnn].nick,lip[1]);
cn[wn[cwin].cnn].nickflag=0;
dowindinfo(cwin);
}
return;
}

if(!stricmp(lip[0],"/lsound")){
if(strlen(lip[1])){playsound(lip[1]);}
else{
getsoundlist(&temps2);
sprintf(temps,"++Sounds available: %s",temps2);
sendout(temps,cwin,col[CSYSTEM]);
}
return;
}

if(!stricmp(lip[0],"/sound")){
if(!strlen(lip[1])){
sendout("**Syntax: /sound <remote> [sound name]",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s PRIVMSG %s :\001SOUND",cn[wn[cwin].cnn].nick,lip[1]);
if(strlen(lip[2])){
strcat(temps," ");
strcat(temps,lip[2]);
}
strcat(temps,"\001\r");
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/me")){
sprintf(temps,":%s PRIVMSG ",cn[wn[cwin].cnn].nick);
if(wn[cwin].chan>-1 && chan[wn[cwin].chan].stat==2){strcat(temps,chan[wn[cwin].chan].name);}
else{
sendout("**Not in a channel",cwin,col[CERRORS]);
return;
}
strcat(temps," :\001ACTION ");
strcat(temps,rip[0]);strcat(temps,"\001\r");
srt(&temps,cn[wn[cwin].cnn].cn);
sprintf(temps,"%s %s",cn[wn[cwin].cnn].nick,rip[0]);
sendout(temps,cwin,col[CACTIONS]);
return;
}

if(!stricmp(lip[0],"/msg") || !stricmp(lip[0],"/m")){
if(!strlen(lip[1])){
sendout("**Syntax: /msg <remote> <message>",cwin,col[CERRORS]);
return;
}
if(!strlen(rip[1])){
sendout("**Syntax: /msg <remote> <message>",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s PRIVMSG %s :%s\r",cn[wn[cwin].cnn].nick,lip[1],rip[1]);
srt(&temps,cn[wn[cwin].cnn].cn);
if(!conf.boldnicks)
sprintf(temps,"{Pmsg to %s} %s",lip[1],rip[1]);
else
sprintf(temps,"{Pmsg to %s} %s",lip[1],rip[1]);
sendout(temps,cwin,col[CPMSGSFROM]);
addtotablist(lip[1]);
return;
}

if(!stricmp(lip[0],"/invite")){
if(!strlen(lip[1])){
sendout("**Syntax: /invite <remote> [channel]",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s INVITE %s ",cn[wn[cwin].cnn].nick,lip[1]);
if(wn[cwin].chan>-1 && chan[wn[cwin].chan].stat==2){strcat(temps,chan[wn[cwin].chan].name);}
else{
if(!strlen(lip[2])){
sendout("**Syntax: /invite <remote> [channel]",cwin,col[CERRORS]);
return;
}
strcat(temps,lip[2]);
}
strcat(temps,"\r");
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/notice")){
if(!strlen(lip[1])){
sendout("**Syntax: /notice <remote> <m e s s a g e>",cwin,col[CERRORS]);
return;
}
if(!strlen(rip[1])){
sendout("**Syntax: Please specify a message",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s NOTICE %s :%s\r",cn[wn[cwin].cnn].nick,lip[1],rip[1]);
srt(&temps,cn[wn[cwin].cnn].cn);
sprintf(temps,"{Notice to %s} %s",lip[1],rip[1]);
sendout(temps,cwin,col[CPMSGSFROM]);
return;
}

if(!stricmp(lip[0],"/whois")){
if(!strlen(rip[0])){
sendout("**Syntax: /whois <remotes>");
return;
}
sprintf(temps,":%s WHOIS %s\r",cn[wn[cwin].cnn].nick,rip[0]);
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/mode")){
if(!strlen(rip[0])){
sendout("**Syntax: Error",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s MODE %s\r",cn[wn[cwin].cnn].nick,rip[0]);
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/kick")){
if(!strlen(lip[1])){
sendout("**Syntax: /kick <remote> [message]",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s KICK %s",cn[wn[cwin].cnn].nick,lip[1]);
if(strlen(rip[1])){strcat(temps," :");strcat(temps,rip[1]);}
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/whowas")){
if(!strlen(rip[0])){
sendout("**Syntax: /whowas <remotes>");
return;
}
sprintf(temps,":%s WHOWAS %s\r",cn[wn[cwin].cnn].nick,rip[0]);
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/who")){
if(!strlen(rip[0])){
sendout("**Syntax: Error",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s WHO %s\r",cn[wn[cwin].cnn].nick,rip[0]);
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/list")){
if(!strlen(rip[0])){
sendout("**Syntax: Error",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s LIST %s\r",cn[wn[cwin].cnn].nick,rip[0]);
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/version")){
if(!strlen(lip[1])){
sendout("**Syntax: /version <remote>",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s PRIVMSG %s :\001VERSION\001\r",cn[wn[cwin].cnn].nick,lip[1]);
srt(&temps,cn[wn[cwin].cnn].cn);
sprintf(temps,"--CTCP version query sent to %s",lip[1]);
sendout(temps,cwin,col[CSYSTEM]);
return;
}

if(!stricmp(lip[0],"/names")){
if(!strlen(rip[0])){
sendout("**Syntax: Error",cwin,col[CERRORS]);
return;
}
sprintf(temps,":%s NAMES %s\r",cn[wn[cwin].cnn].nick,rip[0]);
srt(&temps,cn[wn[cwin].cnn].cn);
return;
}

if(!stricmp(lip[0],"/ping")){
if(!strlen(lip[1])){
sendout("**Syntax: /ping <remote>",cwin,col[CERRORS]);
return;
}
time(&t);stcl_d(temps2,t);
sprintf(temps,":%s PRIVMSG %s :\001PING %s\001\r",cn[wn[cwin].cnn].nick,lip[1],temps2);
srt(&temps,cn[wn[cwin].cnn].cn);
sprintf(temps,"--CTCP ping sent to %s",lip[1]);
sendout(temps,cwin,col[CSYSTEM]);
return;
}

if(!stricmp(lip[0],"/notify")){
if(!strlen(lip[1])){
junk2=0;
mcto=127;
strcpy(temps,"++Members of notify list : ");
while(mcto>-1){
if(strlen(notlist[mcto])){
strcat(temps,notlist[mcto]);
if(cn[wn[cwin].cnn].noton[mcto]==0)strcat(temps," ");
if(cn[wn[cwin].cnn].noton[mcto]==1)strcat(temps,"[ON] ");
junk2=TRUE;}
mcto--;
}
if(junk2)sendout(temps,cwin,col[CSYSTEM]);
if(!junk2)sendout("--Nobody on Notify list",cwin,col[CSYSTEM]);
return;
}
mcto=1;
while(mcto<5){
if(strlen(lip[mcto])){
if(!addnot(lip[mcto],0)){sprintf(temps,"--%s added to notify list",lip[mcto]);
sendout(temps,cwin,col[CSYSTEM]);
}
}
mcto++;
}
return;
}

if(!stricmp(lip[0],"/unnotify")){
ccnt=1;
while(ccnt<5){
if(strlen(lip[ccnt])){
mcto=127;
while(mcto>-1){
if(strlen(notlist[mcto]) && !stricmp(notlist[mcto],lip[ccnt])){
strcpy(notlist[mcto],"\0");cn[wn[cwin].cnn].noton[mcto]=0;
sprintf(temps,"--%s removed from notify list",lip[ccnt]);
sendout(temps,cwin,col[CSYSTEM]);
}
mcto--;
}
}
ccnt++;
}
return;
}

if(!stricmp(lip[0],"/dcc")){

if(!strlen(lip[1])){
junk2=0;
gflg=FALSE;
while(junk2<10){
if(dcc[junk2].stat){
sprintf(temps,"%d.%s ",junk2,dcc[junk2].avec);
if(dcc[junk2].dir==DCIN)strcat(temps,"Receiving ");
if(dcc[junk2].dir==DCOUT)strcat(temps,"Sending ");
strcat(temps,dcc[junk2].fname);
sprintf(temps2,"%lu",dcc[junk2].cnt);
strcat(temps," Bytes:");strcat(temps,temps2);
sprintf(temps2,"%lu",dcc[junk2].len);
strcat(temps,"/");strcat(temps,temps2);
sendout(temps,cwin,col[CDCCINFO]);
gflg=TRUE;
}
junk2++;
}
if(!gflg)sendout("--No DCC transfers in operation",cwin,col[CDCCINFO]);
return;
}

if(!stricmp(lip[1],"send")){
if(!strlen(lip[2])){
sendout("**Syntax: /dcc send <recipient> <filename>",cwin,col[CERRORS]);
return;}
if(!strlen(lip[3])){
sendout("**Syntax: /dcc send <recipient> <filename>",cwin,col[CERRORS]);
return;}
initiatedcc(lip[2],lip[3]);
return;
}

if(!stricmp(lip[1],"chat")){
if(!strlen(lip[2])){
sendout("**Syntax: /dcc chat <recipient>",cwin,col[CERRORS]);
return;}
if(initiatedccchat(lip[2]))sendout("--DCC chat request sent",cwin,col[CDCCINFO]);
return;
}


}

if(!stricmp(lip[0],"/reset")){

if(!strlen(lip[1])){
if(form_alert(1,"[1][Confirm reset|/all/ DCC transfers?][No][Yes]")==2){
resetdccs();
sendout("++All DCC transfers have been reset",cwin,col[CDCCINFO]);
}
else
sendout("++DCC transfer reset aborted",cwin,col[CDCCINFO]);
return;
}

sscanf(lip[1],"%d",&junk3);
if(junk3<0 || junk3>9){
sendout("**DCC channels 0-9 only",cwin,col[CERRORS]);
return;
}
resetadcc(junk3);
sprintf(temps,"--Reset DCC channel %s",lip[1]);
sendout(temps,cwin,col[CDCCINFO]);
return;
}

if(!stricmp(lip[0],"/mon") || !stricmp(lip[0],"/monitor")){
if(!strlen(lip[1])){
sendout("**Syntax: /mon <channel number>",cwin,col[CERRORS]);
return;
}
sscanf(lip[1],"%d",&junk3);
if(junk3<0 || junk3>9){
sendout("**DCC channels 0-9 only",cwin,col[CERRORS]);
return;
}
if(!dcc[junk3].stat){
sendout("**DCC channel not in use",cwin,col[CERRORS]);
return;
}
strcpy(temps,dcc[junk3].fname);
basename(temps);
if(dcc[junk3].dir==DCIN)opendccrecvdialog(junk3,temps);
if(dcc[junk3].dir==DCOUT)opendccsenddialog(junk3,temps);
return;
}

if(!strnicmp(lip[0],"/",1)){
sendout("**Command not recognised",cwin,col[CERRORS]);
return;
}

/* End of command parsing */

if(wn[cwin].chan>-1 && chan[wn[cwin].chan].stat>2){
if(!conf.boldnicks)
sprintf(temps,"{DCC:%s} %s",chan[wn[cwin].chan].name,ipall);
else
sprintf(temps,"{DCC:%s} %s",chan[wn[cwin].chan].name,ipall);
sendout(temps,cwin,col[CDCCINFO]);
strcat(ipall,"\n");
srt(&ipall,chan[wn[cwin].chan].cn);
return;
}

if(wn[cwin].chan>-1 && chan[wn[cwin].chan].stat==2){
sprintf(temps,":%s PRIVMSG %s :%s\r",cn[wn[cwin].cnn].nick,chan[wn[cwin].chan].name,ipall);
srt(&temps,cn[wn[cwin].cnn].cn);
if(!conf.boldnicks)sprintf(temps,"<%s> %s",cn[wn[cwin].cnn].nick,ipall);
else{sprintf(temps,"<%s> %s",cn[wn[cwin].cnn].nick,ipall);}
sendout(temps,cwin,col[CINPTEXT]);
return;
}

if(wn[cwin].chan==-1){
sendout("**Not in a channel",cwin,col[CERRORS]);
return;}

/* Phew! :) */
return;
}

