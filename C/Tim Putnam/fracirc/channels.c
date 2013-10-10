/* Channel routines (incorporating parts of DCC chat) */

#include "header.h"

void drawnicklist(int hand,GRECT box)
{
short mcto=0,junk=1,junk2;
short maxj;
short xy[4];
if(hand==-1)return;
xy[0]=box.g_x;xy[1]=box.g_y;xy[2]=box.g_x+box.g_w-1;xy[3]=box.g_y+box.g_h-1;
vs_clip(ws.handle,1,xy);
clearwin(box.g_x,box.g_y,box.g_w,box.g_h,col[CNLBACK]);
xy[0]=wn[hand].wwa.g_x+wn[hand].wwa.g_w-NLW;
xy[1]=wn[hand].wwa.g_y;
xy[2]=wn[hand].wwa.g_x+wn[hand].wwa.g_w-NLW;
xy[3]=wn[hand].wwa.g_y+wn[hand].wwa.g_h-ith*2-VT+4;
vsl_color(ws.handle,col[CNLDIVIDE]);
v_pline(ws.handle,2,xy);
xy[0]+=1;
xy[2]+=1;
v_pline(ws.handle,2,xy);
if(wn[hand].chan==-1)return;
vst_font(ws.handle,1);
vst_point(ws.handle,8,&junk2,&junk2,&junk2,&junk2);
maxj=(wn[hand].wwa.g_h-ith*2-VT)/8;
vst_color(ws.handle,col[CNICKLIST]);
vswr_mode(ws.handle,MD_TRANS);
while(mcto<128){
if(strlen(chan[wn[hand].chan].nl[mcto])){
v_gtext(ws.handle,wn[hand].wwa.g_x+wn[hand].wwa.g_w-NLW+4,wn[hand].wwa.g_y+junk*8,chan[wn[hand].chan].nl[mcto]);
junk++;
if(junk>maxj){
mcto=128;
v_gtext(ws.handle,wn[hand].wwa.g_x+wn[hand].wwa.g_w-NLW+4,wn[hand].wwa.g_y+junk*8,"    ");
}
}
mcto++;
}
vs_clip(ws.handle,0,NULL);
return;
}

void nicklistredraw(int hand)
{
initiateredraw(hand,wn[hand].wwa.g_x+wn[hand].wwa.g_w-NLW,wn[hand].wwa.g_y,wn[hand].wwa.g_x+wn[hand].wwa.g_w-NLW,wn[hand].wwa.g_y+wn[hand].wwa.g_h-ith*2-VT);
}

void alternickto(char *nick,char *newnick)
{
short mcto=0,mcto2=0;
while(mcto<30){
if(chan[mcto].stat==2){
while(mcto2<128){
if(!stricmp(chan[mcto].nl[mcto2],nick)){strcpy(chan[mcto].nl[mcto2],newnick);mcto2=0;}
mcto2++;
}
mcto2=0;
}
mcto++;
}

}
void closchan(short cnum)
{
BOOLEAN aflag=FALSE;
short mcto=0;
char temps[2048];
if(chan<0){
form_alert(1,"[1][You're not in|a channel!][ooops!]");
return;
}
while(mcto<30 && !aflag){
if(cnum!=mcto && chan[mcto].win==chan[cnum].win){wn[chan[cnum].win].chan=mcto;aflag=TRUE;}
mcto++;
}
if(!aflag){
wn[chan[cnum].win].chan=-1;
dowindinfo(chan[cnum].win);
cycchan(FORWARDS);
}
if(chan[cnum].stat==2){
sprintf(temps,":%s PART %s\r",cn[wn[chan[cnum].win].cnn].nick,chan[cnum].name);
srt(temps,cn[wn[chan[cnum].win].cnn].cn);
}
if(chan[cnum].stat>2)closedccchat(cnum);
chan[cnum].stat=0;
if(aflag)dowindinfo(chan[cnum].win);
chan[cnum].win=-1;
return;
}



int findfreechannel(void)
{
short mcto=0;
if(cwin==-1)return -1;
while(mcto<30){
if(!chan[mcto].stat){return mcto;}
mcto++;
}
return -1;
}
int findthechannel(char *nch)
{
short mcto=0;
if(cwin==-1)return -1;
while(mcto<30){
if(chan[mcto].stat==1 && !stricmp(chan[mcto].name,nch)){return mcto;}
mcto++;
}
return -1;
}

int getchanhan(char *p)
{
short mcto=29;
while(mcto>-1){
if(!stricmp(chan[mcto].name,p) && chan[mcto].stat)return mcto;
mcto--;
}
return -1;
}

int citw(char *p, short twin)
{
short mcto=0;
while(mcto<30){
if(!stricmp(p,chan[mcto].name)){
if(wn[chan[mcto].win].hand>-1 && wn[twin].cnn==wn[chan[mcto].win].cnn){return chan[mcto].win;}
}
mcto++;
}
return -1;
}

int findlastchannel(void)
{
short counter=0;
short se;
se=wn[cwin].chan-1;
if(se<0 || se>29)se=29;
if(chan[se].stat>1)return se;
while(chan[se].stat<2 ){
se--;
counter++;
if(counter==31)return -1;
if(se<0)se=29;
}
return se;
}

int findnextchannel(void)
{
short counter=0;
short se;
se=wn[cwin].chan+1;
if(se<0 || se>29)se=0;
if(chan[se].stat>1)return se;
while(chan[se].stat<2){
se++;
counter++;
if(counter==31)return -1;
if(se>29){se=0;}
}
return se;
}	

int cycchan(short dri)
{
short ret;
int junk=0;
if(dri==FORWARDS){
ret=findnextchannel();
if(ret==-1)return -1;
}
if(dri==BACKWARDS){
ret=findlastchannel();
if(ret==-1)return -1;
}
if(ret>-1 && chan[ret].win!=cwin){
wind_set(wn[chan[ret].win].hand,WF_TOP,junk,junk,junk,junk);
cwin=chan[ret].win;
}
wn[cwin].chan=ret;
dowindinfo(cwin);
return 0;
}
