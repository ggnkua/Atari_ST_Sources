/* Fracirc DCC modules (including both chat and file transfers) */
/* Started 22-1-97 (though some of the code is from previous versions */

#include "header.h"
#include "fracirc2.h"

int dcc_recv(void)
{
short count=0;
int16 tstat;
char temps[2048];
while(count<10){
if(dcc[count].dir==DCIN && dcc[count].stat==RAWAIT){
tstat=CNbyte_count(dcc[count].cn);

if(tstat>0){
CNget_block(dcc[count].cn,(char *)&dcctempbuffer,tstat);
Fwrite(dcc[count].dcfh,(long)tstat,(char *)&dcctempbuffer);
dcc[count].cnt=dcc[count].cnt+tstat;
dobar(dcc[count].dcw,(long)dcc[count].cnt,dcc[count].len,count);
TCP_send(dcc[count].cn,(char *)&dcc[count].cnt,4);
}

if(tstat<E_NODATA){
printf("%d",tstat);
if(dcc[count].cnt<dcc[count].len){
sprintf(temps,"**DCC: %s from %s incompleted",dcc[count].fname,dcc[count].avec);
sendout(temps,cwin,col[CERRORS]);
if(is_dw_open(dcc[count].dcw))wd_close(dcc[count].dcw);
resetadcc(count);
return 0;
}
sprintf(temps,"++DCC:%s received from %s",dcc[count].fname,dcc[count].avec);
sendout(temps,cwin,col[CDCCINFO]);
sprintf(temps,"++Bytes: %lu",dcc[count].cnt);
sendout(temps,cwin,col[CDCCINFO]);
if(is_dw_open(dcc[count].dcw))wd_close(dcc[count].dcw);
resetadcc(count);
return 0;
}

}
count++;
}
return 0;
}


int dcc_send(void)
{
short count=0;
int16 tstat;
long stat;
char temps[2048],temps2[2048];

while(count<10){
if(dcc[count].dir==DCOUT && dcc[count].stat){
tstat=CNbyte_count(dcc[count].cn);

if(tstat<E_NODATA && dcc[count].stat==SACTIVE){
sprintf(temps2,"**DCC: Error in send to %s",dcc[count].avec);
sendout(temps2,cwin,col[CERRORS]);
resetadcc(count);
if(is_dw_open(dcc[count].dcw))wd_close(dcc[count].dcw);
return 0;
}
if(dcc[count].stat==SAWAIT && tstat>=E_NODATA){
sprintf(temps,"--DCC send to %s connected",dcc[count].avec);
sendout(temps,cwin,col[CDCCINFO]);
dcc[count].stat=SACTIVE;
dcc[count].lack=dcc[count].cnt;
}

if(tstat>=4 && dcc[count].stat==SACTIVE){
CNget_block(dcc[count].cn,(char *)&dcc[count].lack,4);
}
if(dcc[count].lack==dcc[count].cnt && dcc[count].dcfh<0){
sprintf(temps,"--DCC send to %s completed",dcc[count].avec);
sendout(temps,cwin,col[CDCCINFO]);
resetadcc(count);
if(is_dw_open(dcc[count].dcw))wd_close(dcc[count].dcw);
return 0;
} 

if(dcc[count].stat==SACTIVE && dcc[count].lack==dcc[count].cnt){
stat=Fread(dcc[count].dcfh,(long)dctbufsize,(char *)&dcctempbuffer);
if(stat>0)TCP_send(dcc[count].cn,(char *)&dcctempbuffer,(int16)stat);
dobar(dcc[count].dcw,(long)dcc[count].cnt,dcc[count].len,count);
if(stat<dctbufsize){
Fclose(dcc[count].dcfh);
dcc[count].dcfh=-1;
}
dcc[count].cnt=dcc[count].cnt+stat;
}

}
count++;
}
return 0;
}

		
		
		

int resetadcc(short num,char swt){
if(dcc[num].dcfh){Fclose(dcc[num].dcfh);dcc[num].dcfh=-1;}
if(dcc[num].cn)TCP_close(dcc[num].cn,1);
if(is_dw_open(dcc[num].dcw) && !swt)wd_close(dcc[num].dcw);
dcc[num].cn=0;
dcc[num].dcfh=-1;
dcc[num].stat=0;
dcc[num].cnt=0;
dcc[num].lack=0;
dcc[num].dir=-1;
return 0;
}
int resetdccs(){
short temp=9;
while(temp>-1){
if(dcc[temp].dcfh){Fclose(dcc[temp].dcfh);dcc[temp].dcfh=-1;}
if(dcc[temp].cn)TCP_close(dcc[temp].cn,1);
strcpy(dcc[temp].avec,"\0");
strcpy(dcc[temp].fname,"\0");

dcc[temp].cn=0;
dcc[temp].dcfh=-1;
dcc[temp].stat=0;
dcc[temp].cnt=0;
dcc[temp].lack=0;
dcc[temp].dir=-1;
temp--;
}

return 0;
}


int checkdccchat()
{
short lcount=0,offset=0,sln;
short mcto=0;
char *dp;
char temps[2048];
	int16 stat;
while(mcto<30){
	if(chan[mcto].stat>2){
	stat = CNbyte_count(chan[mcto].cn);
	if (chan[mcto].stat == SAWAIT && stat >= E_NODATA)
		{chan[mcto].stat = SACTIVE;
		sendout("--DCC chat opened",cwin,col[CDCCINFO]);
		wn[chan[mcto].win].chan=mcto;
		dowindinfo(chan[mcto].win);}


	if (stat < E_NODATA && chan[mcto].stat !=SAWAIT) {
	sendout("--DCC chat terminated by remote",cwin,col[CDCCINFO]);
	closchan(mcto);
	}
	else{
	if (stat > 0){
	strcpy(dccp,"\0");

	CNget_block(chan[mcto].cn,(char *)dccp,stat);
*(dccp+stat)=0;
sln=(int16)strlen(dccp)+1;
dp=dccp;
while(offset<sln){
if(*(dp+lcount)==9){*(dp+lcount)=' ';}
if(*(dp+lcount)==10){
*(dp+lcount)=0;
sprintf(temps,"[DCC:%s] %s",chan[mcto].name,dp);
sendout(temps,chan[mcto].win,col[CDCCINFO]);dp=dp+lcount+1;
lcount=-1;
}
offset++;
lcount++;
}
if(offset!=sln){
if(!conf.boldnicks)
sprintf(temps,"[DCC:%s] ",chan[mcto].name);
else
sprintf(temps,"[DCC:%s] ",chan[mcto].name);
strncat(temps,dp,strlen(dp)-1);
sendout(temps,chan[mcto].win,col[CDCCINFO]);
}
}
}
}
mcto++;
}
return 0;
}



int initiatedccchat(char *usr){
short blah;
uint32 cip;
char temps2[2048];
blah=findfreedccchat();
if(blah==-1){form_alert(1,"[1][No free chats :(][Oh dear]");return 0;}
chan[blah].cn=TCP_open(0L,0,0,2048);
cb=CNgetinfo(cn[wn[cwin].cnn].cn);
cip=stik_cfg->client_ip;
if(cip==0 || cip==0x7F000001)cip=cb->lhost;
cb = CNgetinfo(chan[blah].cn);
sprintf(temps2,":%s PRIVMSG %s :\001DCC CHAT chat %lu %u\001\r",cn[wn[cwin].cnn].nick,usr,cip,cb->lport);
srt(temps2,cn[wn[cwin].cnn].cn);
chan[blah].stat=SAWAIT;
strcpy(chan[blah].name,usr);
chan[blah].win=cwin;
return 1;
}


int initiatedcc(char *usr,char *ftg){
short temp;
struct FILEINFO finf;
uint32 length;
uint32 cip;
char temps2[2048];

if(!strlen(ftg)){form_alert(1,"[1][DCC Error:|Please specify a file][Okay]");return 0;}
if(!strlen(usr)){form_alert(1,"[1][DCC Error:|Please specify recipient][Okay]");return 0;}
temp=findfreedc();
if(temp==-1){form_alert(1,"[1][DCC Error:|No free channels!][Okay]");return 0;}
dcc[temp].dcfh=Fopen(ftg,0);
if(dcc[temp].dcfh<0){form_alert(1,"[DCC Error:|Unable to open file][Okay]");return 0;}
dcc[temp].cn=TCP_open(0L,0,0,4096);
if(dcc[temp].cn<0){form_alert(1,"[1][DCC Error:|Unable to open socket][Okay]");return 0;}
dcc[temp].stat=SAWAIT;
dcc[temp].dir=DCOUT;
Fsetdta(&finf);
Fsfirst(ftg,0);
length=finf.size;
strcpy(dname,ftg);
basename(dname);
cb=CNgetinfo(cn[wn[cwin].cnn].cn);
cip=stik_cfg->client_ip;
if(cip==0||cip==0x7F000001)
cip=cb->lhost;
cb=CNgetinfo(dcc[temp].cn);
sprintf(temps2,":%s PRIVMSG %s :\001DCC SEND %s %lu %u %lu\001\n",cn[wn[cwin].cnn].nick,usr,dname,cip,cb->lport,length);
TCP_send(cn[wn[cwin].cnn].cn,(char *)&temps2,(int16)strlen(temps2));
dcc[temp].rport=cb->lport;
dcc[temp].rip=cip;
strcpy(dcc[temp].fname,dname);
dcc[temp].len=length;
strcpy(dcc[temp].avec,usr);
if(!conf.boldnicks)
sprintf(temps2,"--Initiating DCC send to %s: %s",usr,dname);
else
sprintf(temps2,"--Initiating DCC send to %s: %s",usr,dname);

sendout(temps2,cwin,col[CDCCINFO]);
if(conf.autodcd)opendccsenddialog(temp,dname);
return 0;
}

int dobar(DIALOG *wdh,long bytes,long dclen,short temp){
OBJECT *tree;
GRECT rect;
long r;
char temps[2048];
if(is_dw_open(wdh)){
wdlg_get_tree(wdh,&tree,&rect);
strcpy(temps,"\0");sprintf(temps,"%lu",bytes);
strcpy(tree[dc0bytes].ob_spec.tedinfo->te_ptext,temps);
r=(200*bytes)/dclen;
tree[dc0bar].ob_width=(short)r;
vswr_mode(ws.handle,MD_REPLACE);
wdlg_redraw(wdh,&rect,dc0bar,MAX_DEPTH);
wdlg_redraw(wdh,&rect,dc0bytes,MAX_DEPTH);
vswr_mode(ws.handle,MD_TRANS);
}
return 0;
}

int findresmdc(char *sndr)
{
short mcto;
mcto=0;
while(mcto<10){
if(dcc[mcto].dir==DCIN && dcc[mcto].stat==RESUME && !stricmp(dcc[mcto].avec,sndr))return mcto;
mcto++;
}
return -1;
}

int findsawaitdc(int16 piort,char *sndr)
{
short mcto=0;
while(mcto<10){
if(dcc[mcto].dir==DCOUT && dcc[mcto].rport==piort && !stricmp(dcc[mcto].avec,sndr))return mcto;
mcto++;
}
return -1;
}
int findfreedc(void)
{
short mcto=0;
while(mcto<10){
if(!dcc[mcto].stat)return mcto;
mcto++;
}
return -1;
}

int findfreedccchat(void)
{
short mcto;
mcto=0;
while(mcto<30){
if(!chan[mcto].stat)return mcto;
mcto++;
}
return -1;
}

void closedccchat(short temp)
{
if(chan[temp].stat>2){
TCP_close(chan[temp].cn,1);
chan[temp].stat=0;
chan[temp].cn=0;
dowindinfo(chan[temp].win);
chan[temp].win=-1;
strcpy(chan[temp].name,"\0");
}
}