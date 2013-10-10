/* Scrolling code (includes scrollback functions)*/
#include "d:\fracirc\header.h"


int sbvslid(short newpos)
{
short bbb=0;
long blah,blah2;
if(wn[cwin].scb!=0)bbb=1;
wind_set(wn[cwin].hand,WF_VSLIDE,newpos,0,0,0);
blah2=1000-newpos;
blah=blah2*(149-wn[cwin].hght);blah=blah/1000;
wn[cwin].scb=(short)blah;
if(blah2!=0 && bbb==0)dowindinfo(cwin);
if(blah2==0 && bbb==1)dowindinfo(cwin);
initiateredraw(cwin,wn[cwin].wwa.g_x,wn[cwin].wwa.g_y,wn[cwin].wwa.g_w,wn[cwin].wwa.g_h-ith*2-VT);
return 0;
}

void drawvslid(void)
{
int32 blah;
blah=wn[cwin].scb;
blah=blah*1000;
blah=blah/(149-wn[cwin].hght);
blah=1000-blah;
wind_set(wn[cwin].hand,WF_VSLIDE,(short)blah,-1,-1,-1);
}

int scrollbbk(void)
{
if(wn[cwin].scb==0)return 0;
wn[cwin].scb--;
if(wn[cwin].scb==0)dowindinfo(cwin);
scrollup(cwin,1);
drawvslid();
return 0;
}

int scrollback(void)
{
if(wn[cwin].scb>147-wn[cwin].hght)return 0;
wn[cwin].scb++;
if(wn[cwin].scb==1)dowindinfo(cwin);
initiateredraw(cwin,wn[cwin].wwa.g_x,wn[cwin].wwa.g_y,wn[cwin].wwa.g_w,wn[cwin].wwa.g_h);
drawvslid();
return 0;
}

void scrolldown(void)
{
short xy[8];
startupdate();
xy[0]=wn[cwin].wwa.g_x;xy[1]=wn[cwin].wwa.g_y;
xy[2]=wn[cwin].wwa.g_x+wn[cwin].wwa.g_w-1;xy[3]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith*2-VT-th;
xy[4]=wn[cwin].wwa.g_x;xy[5]=wn[cwin].wwa.g_y+th;
xy[6]=wn[cwin].wwa.g_x+wn[cwin].wwa.g_w-1;xy[7]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith*2-VT;
vro_cpyfm(ws.handle,S_ONLY,xy,&scr,&scr);
xy[0]=wn[cwin].wwa.g_x;xy[1]=wn[cwin].wwa.g_y;
xy[2]=wn[cwin].wwa.g_x+wn[cwin].wwa.g_w-1;xy[3]=wn[cwin].wwa.g_y;
xy[6]=wn[cwin].wwa.g_x;xy[7]=wn[cwin].wwa.g_y+th;
xy[4]=wn[cwin].wwa.g_x+wn[cwin].wwa.g_w-1;xy[5]=wn[cwin].wwa.g_y+th;
v_fillarea(ws.handle,4,xy);
finishupdate();
}


void scrollup(int hand, short howmany)
{
GRECT box;
GRECT area;
int xy[8],temp;
area.g_x=wn[hand].wwa.g_x;
area.g_y=wn[hand].wwa.g_y;
area.g_w=wn[hand].wwa.g_w-NLW;
area.g_h=wn[hand].wwa.g_h-ith*2-VT+3;
if(wn[hand].stat==WMDONTWRITE)return;
startupdate();
wind_get(wn[hand].hand,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
while (box.g_w && box.g_h){
if(rc_intersect(&area,&box)){
temp=th*howmany;
if(temp>box.g_h)temp=box.g_h;
xy[0]=box.g_x;xy[1]=box.g_y+temp;
xy[2]=box.g_x+box.g_w-1;xy[3]=box.g_y+box.g_h-1;
xy[4]=box.g_x;xy[5]=box.g_y;
xy[6]=box.g_x+box.g_w-1;xy[7]=box.g_y+box.g_h-temp;
vro_cpyfm(ws.handle,S_ONLY,xy,&scr,&scr);
box.g_y=box.g_y+box.g_h-temp;
box.g_h=temp+1;
dodirty(hand,box);
}
wind_get(wn[hand].hand,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
}
finishupdate();
return;
}

void dodirty(int hand,GRECT box)
{
int xy[4];
int tpa,tpb,junk2,mcto=0;
int x,y,w,h;
x=box.g_x;y=box.g_y;w=box.g_w;h=box.g_h;
xy[0]=x;xy[1]=y;xy[2]=x+w-1;xy[3]=y+h-1;
vs_clip(ws.handle,1,xy);
clearwin(x,y,w,h,col[CBACK]);
tpa=(wn[hand].wwa.g_y+wn[hand].wwa.g_h-ith*2-VT-3)-(y+h-1);
tpb=tpa/th;
tpa=(h+th/2)/th;
junk2=wn[hand].clcnt-tpb-wn[hand].scb;
if(junk2<0)junk2=150+junk2;
vswr_mode(ws.handle,MD_TRANS);
while(tpa>-1){
writeoutput(hand,wn[hand].cl[junk2],tpb+mcto-1,wn[hand].clc[junk2]);
mcto++;tpa--;junk2--;
if(junk2<0)junk2=149;
}
vs_clip(ws.handle,0,NULL);
}
