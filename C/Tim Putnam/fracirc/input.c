/* Input box code commenced 12/2/97 */
#include "d:\fracirc\header.h"

int inputprocess(){
int junk,junk2,cellw,rfoff=0,lcount=0,wl;
char aflag=FALSE;
char *dp;
int sff=0;
char temps[2048];
	if(cwin==-1)return 0;
	wind_get(wn[cwin].hand,WF_TOP,&junk,&junk2,&junk2,&junk2);
	if(cwin!=-1 && wn[cwin].stat!=WMDONTWRITE && junk==wn[cwin].hand){
	strcpy(chinp,"\0");
	sprintf(chinp,"%c",kreturn);
	if(wn[cwin].scb){sbvslid(1000);wn[cwin].scb=0;}
	
	if(!strncmp("\b",chinp,1) && inpbcontents()){
	vst_font(ws.handle,(WORD)inpfont);
	vst_point(ws.handle,(WORD)inppoint,&junk2,&junk2,&junk2,&junk2);

	clcursor(cwin);
	junk2=findcurpos();
	stccpy(temps,wn[cwin].inp,junk2);
	strcat(temps,wn[cwin].inp+junk2);
	strcpy(wn[cwin].inp,temps);
	if(wn[cwin].cx>0){wn[cwin].cx--;}
	else{
	if(wn[cwin].cvof!=0){
	wn[cwin].cvof--;wn[cwin].cx=wn[cwin].ihc[wn[cwin].cvof]-1;}
	}
	
wl=wn[cwin].cvof;
junk2=wn[cwin].cvof-1;
while(junk2>-1){
rfoff=rfoff+wn[cwin].ihc[junk2];
junk2--;
}
dp=wn[cwin].inp+rfoff;
if(rfoff==strlen(wn[cwin].inp)){wn[cwin].ihc[wl]=0;
wn[cwin].iof[wl]=0;
}
else{
while(rfoff<strlen(wn[cwin].inp)){
vqt_width(ws.handle,*(dp+lcount),&cellw,&junk2,&junk2);
if(sff+cellw>wn[cwin].wwa.g_w){
wn[cwin].ihc[wl]=lcount;
wn[cwin].iof[wl]=sff;
dp=dp+lcount;
lcount=-1;
sff=0;
wl++;
cellw=0;
}
sff=sff+cellw;
lcount++;
rfoff++;
}

wn[cwin].ihc[wl]=lcount;
wn[cwin].iof[wl]=sff;
}
ipbredraw(cwin);
strcpy(chinp,"\0");
	aflag=TRUE;
	}

	if(!strncmp("\b",chinp,1) && !inpbcontents()){
	strcpy(chinp,"\0");
	aflag=TRUE;
	}
	
	if(strlen(wn[cwin].inp)>511){flag=TRUE;}
	
	if(!strncmp("\r",chinp,1)){
	aflag=TRUE;
	strcpy(chinp,"\0");
	gotcmd();
	clearipb(cwin);
	docursor(cwin);
	}
	
	if(!aflag){
	clcursor(cwin);
	wtib(chinp,aflag);
	docursor(cwin);
	strcpy(chinp,"\0");
	}
	
	}
	return 0;
}

int wtib(char *point,char aflag)
{
short junk2,blunk,blunk2,rfoff=0,cellw;
short soff=0,lcount=0,wl;
char *dp;
char temps[2048];
if(cwin==-1)return 0;
wl=wn[cwin].cvof;
if((strlen(wn[cwin].inp)+strlen(point))>511){*(point+(511-strlen(wn[cwin].inp)))=0;}
vst_font(ws.handle,(WORD)inpfont);
vst_point(ws.handle,(WORD)inppoint,&junk2,&junk2,&junk2,&junk2);
if(amatend()){
blunk=findcurpos();
strcat(wn[cwin].inp,point);
}else{
aflag=1;
blunk=findcurpos();
strcpy(temps,"\0");
if(blunk!=0){
stccpy(temps,wn[cwin].inp,blunk+1);
}
strcat(temps,point);
strcat(temps,wn[cwin].inp+blunk);
strcpy(wn[cwin].inp,temps);
}
junk2=wn[cwin].cvof-1;
while(junk2>-1){
rfoff=rfoff+wn[cwin].ihc[junk2];
junk2--;
}
dp=wn[cwin].inp+rfoff;
aflag=FALSE;
blunk2=wn[cwin].iof[wl];
while(rfoff<strlen(wn[cwin].inp)){
vqt_width(ws.handle,*(dp+lcount),&cellw,&junk2,&junk2);
if(soff+cellw>wn[cwin].wwa.g_w){
wn[cwin].ihc[wl]=lcount;
wn[cwin].iof[wl]=soff;
dp=dp+lcount-1;
lcount=0;
soff=0;
wl++;
soff=soff+cellw;
cellw=0;
aflag=TRUE;
}
soff=soff+cellw;
lcount++;
if(rfoff==blunk+strlen(point)-1){wn[cwin].cvof=wl;wn[cwin].cx=lcount;}
rfoff++;
}
if(lcount){
wn[cwin].ihc[wl]=lcount;
wn[cwin].iof[wl]=soff;
}
if(!aflag){
startupdate();
clchar();
clcursor();
vst_color(ws.handle,col[CINPTEXT]);
vswr_mode(ws.handle,MD_TRANS);
v_gtext(ws.handle,wn[cwin].wwa.g_x+blunk2,wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-1,point);
finishupdate();
}
if(aflag)ipbredraw(cwin);
return 0;
}

int findcurpos()
{
short mcto=wn[cwin].cvof-1;
short blunk=0;
while(mcto>-1){
blunk=blunk+wn[cwin].ihc[mcto];
mcto--;
}
blunk=blunk+wn[cwin].cx;
return blunk;
}

int amatend()
{
if(wn[cwin].cx==wn[cwin].ihc[wn[cwin].cvof] && wn[cwin].ihc[wn[cwin].cvof+1]==0)return 1;
return 0;
}


void clcursor(short w)
{
short xy[8];
short blah;
vsl_color(ws.handle,col[CBACK]);
if(cwin==-1)return;
blah=fdtc();
xy[0]=wn[cwin].wwa.g_x+blah+1;xy[1]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith/8-1;
xy[2]=wn[cwin].wwa.g_x+blah+1;xy[3]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith+1;
v_pline(ws.handle,2,xy);
}

int fdtc()
{
short blah,ret;
short xy[8];
char temps[1024];
vst_font(ws.handle,(WORD)inpfont);
vst_point(ws.handle,(WORD)inppoint,&ret,&ret,&ret,&ret);
blah=findcurpos()-wn[cwin].cx;
strcpy(temps,"\0");
stccpy(temps,wn[cwin].inp+blah,wn[cwin].cx+1);
vqt_extent(ws.handle,temps,xy);
blah=xy[2]-xy[0];
return blah;
}

int docursor(short w)
{
short xy[8];
short blah;
vsl_color(ws.handle,col[CCURSOR]);
if(cwin==-1)return 0;
/* Remember to check that cursor output is applicable */
if(wn[cwin].stat==WMCLEAR){
if(blink>3){
blah=fdtc();
xy[0]=wn[cwin].wwa.g_x+blah+1;xy[1]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith/8-1;
xy[2]=wn[cwin].wwa.g_x+blah+1;xy[3]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith+1;
vswr_mode(ws.handle,MD_XOR);
v_pline(ws.handle,2,xy);
vswr_mode(ws.handle,MD_REPLACE);
}
}

return 0;
}

int clchar()
{
short xy[8],cellw,junk2,junk3=0;
short mcto;
if(cwin==-1)return 0;
junk3=findcurpos();
vqt_width(ws.handle,*(wn[cwin].inp+junk3-1),&cellw,&junk2,&junk2);
mcto=fdtc();
xy[0]=wn[cwin].wwa.g_x+mcto;xy[1]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith/8*7-1;
xy[2]=wn[cwin].wwa.g_x+mcto-cellw;xy[3]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith/8*7-1;
xy[4]=wn[cwin].wwa.g_x+mcto-cellw;xy[5]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith/4-1;
xy[6]=wn[cwin].wwa.g_x+mcto;xy[7]=wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith/4-1;
v_fillarea(ws.handle,4,xy);
return 0;
}


int updinpak()
{
char *point;
char temps[2048];
startupdate();
point=wn[cwin].inp+findcurpos()-1;
stccpy(temps,point,wn[cwin].ihc[wn[cwin].cvof]-wn[cwin].cx);
vswr_mode(ws.handle,MD_TRANS);
v_gtext(ws.handle,wn[cwin].wwa.g_x+fdtc(),wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-1,temps);
finishupdate();
return 0;
}

int redoinpb(short hand,GRECT box)
{
int xy[4];
char *point;
short junk2;
char temps[2048];
if(hand==-1)return 0;
xy[0]=box.g_x;xy[1]=box.g_y;xy[2]=box.g_x+box.g_w-1;xy[3]=box.g_y+box.g_h-1;
vs_clip(ws.handle,1,xy);
clearwin(box.g_x,box.g_y,box.g_w,box.g_h,col[CINPBACK]);
writeinpinfo(hand);
point=wn[hand].inp+strlen(wn[hand].inp);
vst_font(ws.handle,(WORD)inpfont);
vst_point(ws.handle,(WORD)inppoint,&junk2,&junk2,&junk2,&junk2);
vst_color(ws.handle,col[CINPTEXT]);
point=point-wn[hand].ihc[wn[hand].cvof];
stccpy(temps,point,wn[hand].ihc[wn[hand].cvof]+1);
vswr_mode(ws.handle,MD_TRANS);
v_gtext(ws.handle,wn[hand].wwa.g_x,wn[hand].wwa.g_y+wn[hand].wwa.g_h-1,temps);
if(wn[hand].cvof>0){
point=point-wn[hand].ihc[wn[hand].cvof-1];
stccpy(temps,point,wn[hand].ihc[wn[hand].cvof-1]+1);
v_gtext(ws.handle,wn[hand].wwa.g_x,wn[hand].wwa.g_y+wn[hand].wwa.g_h-ith-1,temps);
}
docursor(hand);
vs_clip(ws.handle,0,NULL);
return 0;
}

void clearipb(short w)
{
short mcto;
if(w==-1)return;
strcpy(wn[w].inp,"\0");
	mcto=79;
	while(mcto>-1){
	wn[w].ihc[mcto]=0;wn[w].iof[mcto]=0;
	mcto--;
	}
	wn[w].cvof=0;
	wn[w].cx=0;
	ipbredraw(w);
}

int checkformacs(){
	short mcto=0;
	char temps[2048];

	if(kreturn==11779){
	if(wn[cwin].chan>-1)closchan(wn[cwin].chan);
	return 1;
	}
	
	if(kreturn==19200){
	if(wn[cwin].cx>0){wn[cwin].cx--;return 1;}
	else{
	if(wn[cwin].cvof==0)return 1;
	if(wn[cwin].cvof!=0){wn[cwin].cvof--;wn[cwin].cx=wn[cwin].ihc[wn[cwin].cvof];ipbredraw(cwin);return 1;}
	}
	return 1;
	}
	if(kreturn==19712){
	if(wn[cwin].cx<wn[cwin].ihc[wn[cwin].cvof]){wn[cwin].cx++;return 1;}
	else{
	if(wn[cwin].cx==wn[cwin].ihc[wn[cwin].cvof]){
	if(wn[cwin].ihc[wn[cwin].cvof+1]){wn[cwin].cvof++;wn[cwin].cx=0;ipbredraw(cwin);return 1;}
	else{
	return 1;
	}
	}
	}
	return 1;
	}
	
	if(kreturn==283){
	clearipb(cwin);
	return 1;
	}
	if(kreturn==3849){
	clearipb(cwin);
	strcpy(temps,"/msg ");
	if(lastnt){
	mcto=0;
	lastnc++;
	while(!strlen(lastn[lastnc]) && mcto!=50){
	lastnc++;
	if(lastnc==20)lastnc=0;
	mcto++;
	if(mcto==21)mcto=50;
	}
	}
	if(strlen(lastn[lastnc])){strcat(temps,lastn[lastnc]);strcat(temps," ");wtib(temps,1);}
	lastnt=20;
	return 1;
	}
	
	if(kreturn==15104){doms(0);return 1;}
	if(kreturn==15360){doms(1);return 1;}
	if(kreturn==15616){doms(2);return 1;}
	if(kreturn==15872){doms(3);return 1;}
	if(kreturn==16128){doms(4);return 1;}
	if(kreturn==16384){doms(5);return 1;}
	if(kreturn==16640){doms(6);return 1;}
	if(kreturn==16896){doms(7);return 1;}
	if(kreturn==17152){doms(8);return 1;}
	if(kreturn==17408){doms(9);return 1;}
	
	if(kreturn==30720 && wn[0].hand>-1){topwindow(0);return 1;}
	if(kreturn==30976 && wn[1].hand>-1){topwindow(1);return 1;}
	if(kreturn==31232 && wn[2].hand>-1){topwindow(2);return 1;}
	if(kreturn==31488 && wn[3].hand>-1){topwindow(3);return 1;}
	if(kreturn==31744 && wn[4].hand>-1){topwindow(4);return 1;}
	if(kreturn==32000 && wn[5].hand>-1){topwindow(5);return 1;}
	if(kreturn==3103){
	wtib("",0);
	return 1;
	}
	if(kreturn==3357){
	wtib("",0);
	return 1;
	}
	if(kreturn==10496){
	wtib("",0);
	return 1;
	}
	if(kreturn==2832){
	wtib("",0);
	return 1;
	}
	
	if(kreturn==4096){
	mcto=0;
	while(mcto<NOFWIN)
	{
	if(cn[mcto].cn>-1){
	if(form_alert(2,"[1][Still connected!|Are you sure?][No!][Yes!]")==1)return 1;
	mcto=NOFWIN;
	}
	mcto++;
	}
	mcto=0;
	while(mcto<10)
	{
	if(dcc[mcto].stat){
	if(form_alert(2,"[1][DCC transfer open!|Are you sure?][No!][Yes!]")==1)return 1;
	mcto=10;
	}
	mcto++;
	}
	qt();
	}
	if(kreturn==19252){
	cycchan(BACKWARDS);
	return 1;
	}
	if(kreturn==19766){
	cycchan(FORWARDS);
	return 1;
	}
	if(kreturn==29440){
	cycwin(BACKWARDS);
	return 1;
	}
	if(kreturn==29696){
	cycwin(FORWARDS);
	return 1;
	}
	if(kreturn==4375){
	openwin(0,0,0,0,2);
	return 1;
	}
	if(kreturn==5653){
	dodccsend();
	return 1;
	}
	if(kreturn==4113){
	disnnect(wn[cwin].cnn);
	return 1;
	}
	if(kreturn==12813 && cwin>-1){
	closewin(cwin);
	return 1;
	}
	if(kreturn==6159){
	sortconnection();
	return 1;
	}
	return 0;
	}

int doms(short mnum)
{
short lcount=0,offset=0;
short sln;
char *ps,temp[100];
if(wn[cwin].cnn==-1)return 0;
sln=(int16)strlen(macs[mnum])+1;
strcpy(temp,macs[mnum]);
ps=(char *)&temp;
while(offset<sln){
if(*(ps+lcount)=='\r'){
*(ps+lcount)=0;
wtib(ps,0);
gotcmd();
clearipb(cwin);
ps=ps+lcount+1;
lcount=-1;
}
lcount++;
offset++;
}
if(strlen(ps))wtib(ps,0);
return 0;
}

void writeinpinfo(short w)
{
short junk2;
short xy[8];
vsl_color(ws.handle,col[CDIVIDEB]);
xy[0]=wn[w].wwa.g_x;
xy[1]=wn[w].wwa.g_y+wn[w].wwa.g_h-ith*2-1;
xy[2]=wn[w].wwa.g_x+wn[w].wwa.g_w-1;
xy[3]=wn[w].wwa.g_y+wn[w].wwa.g_h-ith*2-1;
v_pline(ws.handle,2,xy);
xy[1]=xy[1]-10;xy[3]=xy[3]-10;
vsl_color(ws.handle,col[CDIVIDET]);
v_pline(ws.handle,2,xy);
vst_font(ws.handle,1);
vst_point(ws.handle,8,&junk2,&junk2,&junk2,&junk2);
vst_color(ws.handle,col[CINPINFO]);
vst_effects(ws.handle,THICKENED);
vswr_mode(ws.handle,MD_TRANS);
v_gtext(ws.handle,wn[w].wwa.g_x,wn[w].wwa.g_y+wn[w].wwa.g_h-ith*2-3,wn[w].info2);
vst_effects(ws.handle,0);
vst_font(ws.handle,inpfont);
vst_point(ws.handle,inppoint,&junk2,&junk2,&junk2,&junk2);
}


int inpbcontents()
{
if(wn[cwin].cvof>0 || wn[cwin].cx>0)return 1;
return 0;
}

int ipbredraw(short w)
{
initiateredraw(w,wn[w].wwa.g_x,wn[w].wwa.g_y+wn[w].wwa.g_h-ith*2,wn[w].wwa.g_w,ith*2);
return 0;
}

int info2redraw(short w)
{
initiateredraw(w,wn[w].wwa.g_x,wn[w].wwa.g_y+wn[w].wwa.g_h-ith*2-VT,wn[w].wwa.g_w,VT);
return 0;
}
