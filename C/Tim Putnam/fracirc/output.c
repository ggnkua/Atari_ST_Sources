/* Output module for Fracirc, version 2 */
#include "header.h"

void sendout(char *ps,int hand,short coll)
{
int junk;
char *dp;
int dolen=(int)strlen(ps);
int lcount=0,offset=0;
long effects=0;
int eff[3],dist[5],cellw;
int chof=0,howmany=0;
BOOLEAN bd=FALSE;
if(hand==-1)return;
vst_font(ws.handle,(WORD)winfont);
vst_point(ws.handle,(WORD)winpoint,&junk,&junk,&junk,&junk);

dp=ps;
dolen=(int)strlen(ps);
eff[0]=0;
vst_effects(ws.handle,0);
while(offset<dolen){
vqt_width(ws.handle,*(dp+lcount),&cellw,&junk,&junk);
cellw=cellw+eff[0];

if(*(dp+lcount)==2){
cellw=0;
if(bd){bd=FALSE;eff[0]=0;}
else{bd=TRUE;
effects=THICKENED;
vst_effects(ws.handle,effects);
vqt_fontinfo(ws.handle,&junk,&junk,&dist[0],&junk,&eff[0]);
}
}
if(*(dp+lcount)==3)cellw=0;
if(*(dp+lcount)==15){cellw=0;bd=FALSE;eff[0]=0;}
if(*(dp+lcount)==22)cellw=0;
if(*(dp+lcount)==31)cellw=0;

chof=chof+cellw;

if(chof>wn[hand].wwa.g_w-NLW-1 || lcount>148){
wn[hand].clc[wn[hand].clcnt]=coll;
stccpy(wn[hand].cl[wn[hand].clcnt++],dp,lcount+1);
tlog(wn[hand].cl[wn[hand].clcnt-1]);
if(wn[hand].clcnt==150)wn[hand].clcnt=0;
cellw=0;chof=0;offset--;
dp=dp+lcount;
lcount=-1;
howmany++;
}
offset++;
lcount++;
}

if(strlen(dp)){
wn[hand].clc[wn[hand].clcnt]=coll;
stccpy(wn[hand].cl[wn[hand].clcnt++],dp,lcount+1);
tlog(wn[hand].cl[wn[hand].clcnt-1]);
if(wn[hand].clcnt==150)wn[hand].clcnt=0;
howmany++;
}

scrollup(hand,howmany);
}


int writeoutput(short hand,char *ps,short vof,short coll)
{
short lcount=0,offset=0,chof=0,cellw,dolen,junk2,ochof=0;
char *dp;
vst_font(ws.handle,(WORD)winfont);
vst_point(ws.handle,(WORD)winpoint,&junk2,&junk2,&junk2,&junk2);
dp=ps;
dolen=(short)strlen(dp);
while(offset<dolen){
flag=FALSE;
if(*(dp+lcount)==2){
if(lcount)ochof=ochof+writeblock(dp,lcount-1,ochof,vof,coll,hand);
ochof=ochof+chof;chof=0;cellw=0;
dp=dp+lcount+1;lcount=-1;flag=TRUE;
if(bold==1){bold=0;}else{bold=1;}
}
if(*(dp+lcount)==3 && !flag){
if(lcount)ochof=ochof+writeblock(dp,lcount-1,ochof,vof,coll,hand);
dp=dp+lcount+1;lcount=-1;flag=TRUE;
if(red==1){red=0;}else{red=1;}
}
if(*(dp+lcount)==15 && !flag){
if(lcount)ochof=ochof+writeblock(dp,lcount-1,ochof,vof,coll,hand);
dp=dp+lcount+1;lcount=-1;flag=TRUE;
if(reset==1){reset=0;}else{reset=1;}
}
if(*(dp+lcount)==22 && !flag){
if(lcount)ochof=ochof+writeblock(dp,lcount-1,ochof,vof,coll,hand);
dp=dp+lcount+1;lcount=-1;flag=TRUE;
if(reversed==1){reversed=0;}else{reversed=1;}
}
if(*(dp+lcount)==31 && !flag){
if(lcount)ochof=ochof+writeblock(dp,lcount-1,ochof,vof,coll,hand);
dp=dp+lcount+1;lcount=-1;flag=TRUE;
if(underlined==1){underlined=0;}else{underlined=1;}
}
offset++;
lcount++;
}
if(lcount)ochof=ochof+writeblock(dp,lcount-1,ochof,vof,coll,hand);
return 0;
}

int writeblock(char *dp,short nchar,short hof,short vof,short coll,short hand){
long effects=0;
char a;
short chof;
short pts[8];
if(bold)effects=effects+THICKENED;
if(reversed)vswr_mode(ws.handle,MD_ERASE);
else{vswr_mode(ws.handle,MD_TRANS);}
if(underlined)effects=effects+UNDERLINED;
if(reset){effects=0;red=0;underlined=0;bold=0;reversed=0;reset=0;vswr_mode(ws.handle,MD_TRANS);}
vst_effects(ws.handle,effects);
if(red)vst_color(ws.handle,2);
else
vst_color(ws.handle,coll);
a=*(dp+nchar+1);
*(dp+nchar+1)=0;
vqt_extent(ws.handle,dp,pts);
chof=pts[2]-pts[0];
v_gtext(ws.handle,wn[hand].wwa.g_x+hof,wn[hand].wwa.g_y+wn[hand].wwa.g_h-ith*2-VT-vof*th,dp);
vswr_mode(ws.handle,MD_TRANS);
*(dp+nchar+1)=a;
return chof;
}

void initiateredraw(int hand,short x,short y,short w,short h){
int msg[8];
msg[0]=WM_REDRAW;msg[1]=GemParBlk.global[2];
msg[2]=0;msg[3]=wn[hand].hand;
msg[4]=x;msg[5]=y;
msg[6]=w;msg[7]=h;
appl_write(msg[1],sizeof(msg),msg);
}

