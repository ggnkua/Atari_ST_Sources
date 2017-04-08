/* window routines */
#include "header.h"
#include "fracirc2.h"


int openwin(short x,short y,short w,short h,short swtch)
{
short ret;
short mcto=0;
int runk;
/* swtch details the mode in opening the window which can be :

		0 - Just open window, leave cnn as it is
		1 - Open window to cwin cnn
		2 - Ask
*/
GRECT tip;
runk=findfreewindow();
if(runk==-1){form_alert(1,"[1][No free windows!][Darn]");return -1;}

if(cwin!=-1){
if(swtch==2){
ret=form_alert(1,"[1][New window purpose?][New server|Copy current]");
if(ret==2 || swtch==0){wn[runk].cnn=wn[cwin].cnn;}
}
if(swtch==1)wn[runk].cnn=wn[cwin].cnn;
}
if(ret==1 || cwin==-1){
while(mcto<NOFWIN){
if(cn[mcto].cn==-1)wn[runk].cnn=mcto;
mcto++;
}
}
cwin=runk;

if(!w){
if(!wn[cwin].wwa.g_w){
wind_get(0,WF_WORKXYWH,&ms.g_x,&ms.g_y,&ms.g_w,&ms.g_h);
wn[cwin].hand=wind_create(NAME+INFO+MOVER+SIZER+CLOSER+FULLER+VSLIDE+UPARROW+DNARROW,&ms);
}
else{
wn[cwin].hand=wind_create(NAME+INFO+MOVER+SIZER+CLOSER+FULLER+VSLIDE+UPARROW+DNARROW,&wn[cwin].wwa);
}
}
else{tip.g_x=x;tip.g_y=y;tip.g_w=w;tip.g_h=h;
wn[cwin].hand=wind_create(NAME+INFO+MOVER+SIZER+CLOSER+FULLER+VSLIDE+UPARROW+DNARROW,&tip);
}
if(wn[cwin].hand<0){form_alert(1,"[1][System:|No more windows!][Darn]");return -1;}
if(!w){wind_open(wn[cwin].hand,&ms);}
else{wind_open(wn[cwin].hand,&tip);}
dowindinfo(cwin);
wind_get(wn[cwin].hand,WF_WORKXYWH,&wn[cwin].wwa.g_x,&wn[cwin].wwa.g_y,&wn[cwin].wwa.g_w,&wn[cwin].wwa.g_h);
wn[cwin].hght=(wn[cwin].wwa.g_h-ith*2-VT)/th;
wind_set(wn[cwin].hand,WF_VSLIDE,1000,0,0,0);
initiateredraw(cwin,wn[cwin].wwa.g_x,wn[cwin].wwa.g_y,wn[cwin].wwa.g_w,wn[cwin].wwa.g_h);
if(cwin==0)menu_ienable(mnu,mselwin1,1);
if(cwin==1)menu_ienable(mnu,mselwin2,1);
if(cwin==2)menu_ienable(mnu,mselwin3,1);
if(cwin==3)menu_ienable(mnu,mselwin4,1);
if(cwin==4)menu_ienable(mnu,mselwin5,1);
if(cwin==5)menu_ienable(mnu,mselwin6,1);
wn[cwin].chan=-1;
return 0;
}

void clearwin(int x,int y,int w,int h,int colr)
{
short xy[8];
xy[0]=x;xy[1]=y;xy[2]=x+w-1;xy[3]=y;
xy[4]=x+w-1;xy[5]=y+h-1;xy[6]=x;
xy[7]=y+h-1;
vsf_color(ws.handle,colr);
vswr_mode(ws.handle,MD_REPLACE);
v_fillarea(ws.handle,4,xy);
return;
}

int fullwin(int hand)
{
if(wn[hand].stat==2){
wind_get(wn[hand].hand,WF_PREVXYWH,&wn[hand].wwa.g_x,&wn[hand].wwa.g_y,&wn[hand].wwa.g_w,&wn[hand].wwa.g_h);
resizewindow(hand,wn[hand].wwa.g_x,wn[hand].wwa.g_y,wn[hand].wwa.g_w,wn[hand].wwa.g_h);
wn[hand].stat=0;
}
else{
wn[hand].stat=2;
wind_get(0,WF_WORKXYWH,&wn[hand].wwa.g_x,&wn[hand].wwa.g_y,&wn[hand].wwa.g_w,&wn[hand].wwa.g_h);
resizewindow(hand,wn[hand].wwa.g_x,wn[hand].wwa.g_y,wn[hand].wwa.g_w,wn[hand].wwa.g_h);
}
return 0;
}

int findusedwindow(short dir)
{
short cow=5;
if(dir==FORWARDS)wcount++;
if(wcount>5)wcount=0;
if(dir==BACKWARDS)wcount--;
if(wcount<0)wcount=5;
while(cow>-1){
if(wn[wcount].hand>-1)return wcount;
if(dir==FORWARDS)wcount++;
if(wcount>5)wcount=0;
if(dir==BACKWARDS)wcount--;
if(wcount<0)wcount=5;
cow--;
}
return -1;
}

int findfreewindow(void)
{
int mcto=0;
while(mcto<6){
if(wn[mcto].hand<0)return mcto;
mcto++;
}
return -1;
}

int findwhand(int hand)
{
short mcto=0;
while(mcto<6){
if(hand==wn[mcto].hand)return mcto;
mcto++;
}
return -1;
}

int oneofours(int hand)
{
short mcto=0;
while(mcto<NOFWIN){
if(wn[mcto].hand==hand)return 1;
mcto++;
}
return 0;
}

int topwindow(int hand)
{
int junk=0;
wind_set(wn[hand].hand,WF_TOP,junk,junk,junk,junk);
cwin=hand;
dowindinfo(hand);
return 0;
}

int cycwin(short dir)
{
int junkwh,junk;
junkwh=wn[cwin].hand;
wn[cwin].hand=-1;
junk=findusedwindow(dir);
wn[cwin].hand=junkwh;
if(junk==-1)return 0;
topwindow(junk);
return 0;
}

int closewin(int hand)
{
int blong,mcto,super;
if(wn[hand].hand==-1)return 0;
blong=wn[hand].hand;
wn[hand].hand=-1;
if(hand==0)menu_ienable(mnu,mselwin1,0);
if(hand==1)menu_ienable(mnu,mselwin2,0);
if(hand==2)menu_ienable(mnu,mselwin3,0);
if(hand==3)menu_ienable(mnu,mselwin4,0);
if(hand==4)menu_ienable(mnu,mselwin5,0);
if(hand==5)menu_ienable(mnu,mselwin6,0);
mcto=29;
while(mcto>-1){
if(chan[mcto].stat>0 && chan[mcto].win==blong){closchan(mcto);}
mcto--;
}
mcto=149;
while(mcto>-1){
strcpy(wn[hand].cl[mcto],"\0");
wn[hand].clc[mcto]=1;
mcto--;
}
wind_close(blong);
wind_delete(blong);
wn[hand].chan=-1;
mcto=0;
super=0;
while(mcto<NOFWIN){
if(wn[mcto].cnn==wn[hand].cnn && hand!=mcto)super=1;
mcto++;
}
wn[hand].hand=-1;
if(cwin==hand)cwin=findusedwindow(FORWARDS);
if(!super)disnnect(wn[hand].cnn);
wn[hand].cnn=0;
dowindinfo(hand);
return 0;
}

int resizewindow(int hand,short x,short y,short w,short h,char flip)
{
wind_set(wn[hand].hand,WF_CURRXYWH,x,y,w,h);
wind_get(wn[hand].hand,WF_WORKXYWH,&wn[hand].wwa.g_x,&wn[hand].wwa.g_y,&wn[hand].wwa.g_w,&wn[hand].wwa.g_h);
wn[hand].hght=(wn[hand].wwa.g_h-2*ith-VT)/th;
if(flip)initiateredraw(hand,x,y,w,h);
return 0;
}

void dowindinfo(int hand)
{
short mcto;
char aflag=0;
if(hand==-1)return;
mcto=0;aflag=0;
strcpy(wn[hand].info,"\0");
while(mcto<30){
if(chan[mcto].win==hand){
if(chan[mcto].stat==2 || chan[mcto].stat==4){
strcat(wn[hand].info,chan[mcto].name);
strcat(wn[hand].info," ");aflag=1;
}
if(chan[mcto].stat==1 || chan[mcto].stat==3){
strcat(wn[hand].info,"ó");strcat(wn[hand].info,chan[mcto].name);
strcat(wn[hand].info,"ò ");aflag=1;
}
}
mcto++;
}
if(!aflag)strcat(wn[hand].info,"No channels");
wind_info(wn[hand].hand,wn[hand].info);
strcpy(wn[hand].title,"FracIRC: ");
if(hand==0)strcat(wn[hand].title," ");
if(hand==1)strcat(wn[hand].title," ");
if(hand==2)strcat(wn[hand].title," ");
if(hand==3)strcat(wn[hand].title," ");
if(hand==4)strcat(wn[hand].title," ");
if(hand==5)strcat(wn[hand].title," ");
if(hand==6)strcat(wn[hand].title," ");
if(hand==7)strcat(wn[hand].title," ");
if(cn[wn[hand].cnn].cn>0){
strcat(wn[hand].title,cn[wn[hand].cnn].server);
}
else{
strcat(wn[hand].title,"No server");
}
wind_title(wn[hand].hand,wn[hand].title);
sprintf(wn[hand].info2,"  Nick: %s  | Current channel : %s",cn[wn[hand].cnn].nick,chan[wn[hand].chan].name);
if(!strlen(chan[wn[hand].chan].name)strcat(wn[hand].info2,"None");
info2redraw(hand);
nicklistredraw(hand);
return;
}

/* Remember to include scrollback and away information */