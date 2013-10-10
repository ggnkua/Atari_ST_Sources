DRV_LIST *drivers=(DRV_LIST *)NULL;
TPL *tpl=(TPL *)NULL;


#include "mintbind.h"
#include "fracirc2.h"
#include "adaptrsc.h"
#include "icons.c"
#include "header.h"

#define PDOM_MINT 1

int main(void)
{
short attr[10],junk;
if((appl_id = appl_init())== -1)
exit(0);
if(!OpenVwork(&ws))
{
form_alert(1,"[1][No VDI workstation!][Damn]");
appl_exit();
exit(0);
}
if(!checkstik())return 0;
Pdomain(PDOM_MINT);
loadmacs(NULL);
sw=ws.xres;sh=ws.yres;
vst_alignment(ws.handle,0,3,&junk,&junk);
vqt_attributes(ws.handle,attr);
tw=attr[8];th=attr[9];ith=attr[9];
scr.fd_addr=NULL;
if(!get_rsc()){appl_exit();exit(0);}
fnt_dialog=fnts_create(ws.handle,0,FONT_FLAGS,FNTS_3D,"Please select font\0",0L);
initdialogs();
rsrc_gaddr(R_TREE,mainmenu,&mnu);
if(ws.xres < 639)
{
form_alert(1,"[1][Please be in at least|ST med res.!][Ok]");
qt();
}
initvariables();
if(GemParBlk.global[1] == -1)
{
menu_register(appl_id, MenuTitle);
}
menu_bar(mnu,1);
menu_ienable(mnu,mselwin1,0);
menu_ienable(mnu,mselwin2,0);
menu_ienable(mnu,mselwin3,0);
menu_ienable(mnu,mselwin4,0);
menu_ienable(mnu,mselwin5,0);
menu_ienable(mnu,mselwin6,0);
loadprefs(NULL);
vsf_color(ws.handle,col[CBACK]);
vswr_mode(ws.handle,MD_TRANS);
loadwins(NULL);
if(cwin==-1)openwin(0,0,0,0,0);
if(vq_gdos())vst_load_fonts(ws.handle,0);
graf_mouse(ARROW,NULL);
event_loop();
return 0;
}




int qt(void)
{
short mcto=0;
while(mcto<NOFWIN){
disnnect(mcto);
mcto++;
}
closelog();
resetdccs();
if(gjbp)Mfree((void *)gjbp);
while(mcto<6){
closewin(mcto);
mcto++;
}
mcto=0;
while(mcto<128){
if(dials[mcto])wd_close(dials[mcto]);
mcto++;}
fnts_delete(fnt_dialog,ws.handle);
finishdialogs();
rsrc_free();
if(vq_gdos())vst_unload_fonts(ws.handle,0);
v_clsvwk(ws.handle);
appl_exit();
menu_bar(mnu,0);
exit(0);
return 0;
}



static long Init_drivers(void)
{
	long i=0;
	ck_entry *jar = *((ck_entry **) 0x5a0);
	
	flag=FALSE;
	while(jar[i].cktag){
	if(!strncmp((char *)&jar[i].cktag,CJTAG,4)){
		drivers = (DRV_LIST *)jar[i].ckvalue;
	}
	if(!strncmp((char *)&jar[i].cktag,MGTAG,4))mnormg=1;
	if(!strncmp((char *)&jar[i].cktag,MITAG,4))mnormg=1;
	++i;
	}
	return 0;
}

int checkstik(void)
{
Supexec(Init_drivers);
if(drivers==(DRV_LIST *)NULL){
form_alert(1,"[1][STiK is not enabled!][Sorry]");
return FALSE;
}
tpl=(TPL *)get_dftab(TRANSPORT_DRIVER);
if(tpl==(TPL *)NULL){
form_alert(1,"[1][Unable to load|Transport Layer][Ouch]");
return FALSE;
}
return TRUE;
}

int get_rsc(void)
{
short arse;
OBJECT *objs,*deslct,*slct;
UWORD no_objs;
short hor_3d, ver_3d;

arse=rsrc_load("FRACIRC2.RSC");
if(!arse)form_alert(1,"[1][I can't find the RSC file!][Oh dear..]");
if(arse){
aes_flags = get_aes_info( &aes_font, &aes_height, &hor_3d, &ver_3d );
init_icons();

rsh = *((RSHDR **)(&GemParBlk.global[7]));
tree_addr = (OBJECT **)(((UBYTE *)rsh) + rsh->rsh_trindex);
tree_count = rsh->rsh_ntree;
fstring_addr = (BYTE **)((UBYTE *)rsh + rsh->rsh_frstr);
objs = (OBJECT *) (((BYTE *) rsh ) + rsh->rsh_object );
no_objs = rsh->rsh_nobs;


if(aes_flags & GAI_3D)
adapt3d_rsrc( objs, no_objs, hor_3d, ver_3d );
else																		/* 3D-Flags l”schen */
no3d_rsrc( objs, no_objs, 1 );	

if((aes_flags & GAI_MAGIC) == 0)
{
if(ws.wchar < 15) 
{	
slct = &IMAGE_DIALOG[1];
deslct =&IMAGE_DIALOG[2];
}
else
{
slct = &IMAGE_DIALOG[3];
deslct = &IMAGE_DIALOG[4];
}
substitute_objects( objs, no_objs, aes_flags, slct, deslct );
}
else
substitute_objects( objs, no_objs, aes_flags, 0L, 0L );

if((aes_flags & GAI_WDLG) != GAI_WDLG)
{
form_alert(1,"[1][No WDIALOG.PRG!!][Oooops!]");
arse=0;
}
}
return arse;
}


void check_carrier(void)
{
short mcto=0;
if(carrier_detect()<0){
while(mcto<NOFWIN){
disnnect(mcto);
mcto++;
}
form_alert(1,"[1][Lost carrier!][<steam>]");
dowindinfo(cwin);
}
}


int sortredraw(int hand,short a,short b,short c,short d)
{
GRECT box,area;
area.g_x=a;area.g_y=b;area.g_w=c;area.g_h=d;
startupdate();
wind_get(hand,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
while (box.g_w && box.g_h){
if(rc_intersect(&area,&box))redrawwindow(findwhand(hand),box);
wind_get(hand,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
}
finishupdate();
return 0;
}


int redrawwindow(int hand,GRECT box)
{
GRECT bbox;
GRECT area1,area2,area3;
if(wn[hand].stat==WMDONTWRITE)return 0;

area1.g_x=wn[hand].wwa.g_x;
area1.g_y=wn[hand].wwa.g_y;
area1.g_w=wn[hand].wwa.g_w-NLW;
area1.g_h=wn[hand].wwa.g_h-ith*2-VT+4;

area2.g_x=wn[hand].wwa.g_x;
area2.g_y=wn[hand].wwa.g_y+wn[hand].wwa.g_h-ith*2-VT+4;
area2.g_w=wn[hand].wwa.g_w;
area2.g_h=ith*2+VT-4;

area3.g_x=wn[hand].wwa.g_x+wn[hand].wwa.g_w-NLW;
area3.g_y=wn[hand].wwa.g_y;
area3.g_w=NLW;
area3.g_h=wn[hand].wwa.g_h-ith*2-VT+4;
bbox=box;
wind_get(wn[hand].hand,WF_WORKXYWH,&wn[hand].wwa.g_x,&wn[hand].wwa.g_y,&wn[hand].wwa.g_w,&wn[hand].wwa.g_h);
if(rc_intersect(&area2,&box))redoinpb(hand,box);
box=bbox;
if(rc_intersect(&area3,&box))drawnicklist(hand,box);
box=bbox;
if(rc_intersect(&area1,&box))dodirty(hand,box);
return 0;
}

int disnnect(short whcn)
{
short mcto=0,mcto2=0;
char temps[2048];
if(whcn==-1)return 0;
if(cn[whcn].cn>-1){
strcpy(temps,"****** Connection terminated ******");
sendout(temps,cwin,col[CSYSTEM]);
sprintf(temps,":%s QUIT :",cn[whcn].nick);
if(strlen(am[AMQUIT])){strcat(temps,am[AMQUIT]);strcat(temps,"\r");}
srt(&temps,cn[whcn].cn);
TCP_close(cn[whcn].cn,1);
cn[whcn].cn=-1;
strcpy(cn[whcn].server,"\0");
cn[whcn].nickflag=0;
exit_identd(whcn);
while(mcto2<NOFWIN){
if(wn[mcto2].cnn==whcn){
mcto=29;
while(mcto>-1){
if(chan[mcto].stat>0 && chan[mcto].stat<3 && chan[mcto].win==mcto2){closchan(mcto);}
if(chan[mcto].stat>2 && chan[mcto].win==mcto2){closedccchat(mcto);}
mcto--;
}
wn[mcto2].chan=-1;
wn[mcto2].cnn=0;
dowindinfo(mcto2);
cycwin(FORWARDS);
}
mcto2++;
}

}
return 0;
}

int init_identd()
{
cn[wn[cwin].cnn].auth=TCP_open(0,113,0,512);
if(cn[wn[cwin].cnn].auth<0)return -1;
return 0;
}

int exit_identd(short win)
{
if(cn[win].auth>=0)
TCP_close(cn[win].auth,1);
return 0;
}

int identd_timer(void)
{
char answer[512];
int i;
uint16 lp,rp;
short mcto=0;
while(mcto<NOFWIN){
if(cn[mcto].auth>-1){
if(CNbyte_count(cn[mcto].auth)>0)
{
i=0;
while(CNbyte_count(cn[mcto].auth)>0){
answer[i]=CNget_char(cn[mcto].auth);
i++;
}
answer[i]='\x00';
sscanf(answer,"%u , %u",&lp,&rp);
if(rp==port)
sprintf(answer,"%u , %u: USERID : UNIX :%s\r\n",lp,rp,cn[mcto].nick);
else{
sprintf(answer,"%u , %u: ERROR : INVALID-PORT\r\n",lp,rp);
form_alert(1,"[1][Invalid identd port][hmmm..]");
}
srt(&answer,cn[mcto].auth);
TCP_close(cn[mcto].auth,1);
cn[mcto].auth=-1;
}
}
mcto++;
}

return 0;
}



int openconnection(void)
{
int16 x,tstat;
uint32 rhost=0;
short rem;
char temps[2048],temps2[2048];

rem=pfctcr;
port=(int16)atol(oport);
if(cwin==-1){
if(openwin(0,0,0,0,0)==-1)return 0;
}
if(wn[cwin].cnn<0)form_alert(1,"[1][Aghast!|Mail TIM! ERROR!][b]");
if(cn[wn[cwin].cnn].cn>-1){form_alert(1,"[1][Connection already open|in this window][Darnit]");return 0;}
sendout(">>Resolving.. [Esc aborts]",cwin,col[CSYSTEM]);
sendout(oserver,cwin,col[CSYSTEM]);
x=resolve(oserver,(char **)NULL,&rhost,1);
if(x<0){form_alert(1,"[1][Unable to resolve!][Darn]");return -1;}
sendout(">>Attempting to open connection..",cwin,col[CSYSTEM]);
cn[rem].cn=TCP_open(rhost,port,0,4096);
if(cn[rem].cn<0){form_alert(1,"[1][Unable to connect!][Darn]");cn[rem].cn=-1;return -1;}
tstat=TCP_wait_state(cn[rem].cn,TESTABLISH,100);
if(tstat<0){form_alert(1,"[1][Timeout waiting][Darn]");disnnect(rem);return -1;}
wn[cwin].cnn=rem;
strcpy(temps2,">>Connection established");sendout(temps2,cwin,col[CSYSTEM]);
sendout(">>Registering with server",cwin,col[CSYSTEM]);
sprintf(temps,"NICK %s\n",cn[rem].nick);
srt(&temps,cn[rem].cn);
sprintf(temps,"USER %s %s * :%s\n\0",username,hostname,realname);
srt(&temps,cn[rem].cn);
sendout(">>Initiating Identd",cwin,col[CSYSTEM]);
strcpy(cn[rem].server,oserver);
strcpy(oserver,"\0");
dowindinfo(cwin);
if(init_identd(rem)==-1)form_alert(1,"[1][Unable to open Identd|socket][Dodgy!]");
return 0;
}

int checkports(void)
{
int bcnt;
short lcount=0,offset=0,stln;
char *jp;
short mcto=0,mcto2=0;

while(mcto<NOFWIN){
if(cn[mcto].cn>-1){
bcnt=CNbyte_count(cn[mcto].cn);
if(bcnt<E_NODATA){
form_alert(1,"[1][Connection lost!][Ok]");
disnnect(mcto);
}
else{
if(bcnt){
if(bcnt>1024)bcnt=1024;
if(strlen(cn[mcto].cpbuff)){strcpy(cn[mcto].outp,cn[mcto].cpbuff);}
else{strcpy(cn[mcto].outp,"\0");}
strcpy(cn[mcto].cpbuff,"\0");
CNget_block(cn[mcto].cn,(char *)cn[mcto].cpbuff,bcnt);
*(cn[mcto].cpbuff+bcnt)=0;
strcat(cn[mcto].outp,cn[mcto].cpbuff);strcpy(cn[mcto].cpbuff,"\0");
jp=cn[mcto].outp;stln=(int16)strlen(cn[mcto].outp);
while(offset<stln){
if(*(jp+lcount)=='\r'){
*(jp+lcount)=0;
strcpy(cn[mcto].cpbuff,jp);
mcto2=0;
while(mcto2<NOFWIN){
if(wn[mcto2].cnn==mcto){sortcmd(cn[mcto].cpbuff,mcto2);mcto2=NOFWIN+2;}
mcto2++;
}
jp=jp+lcount+1;
lcount=-1;
}
lcount++;
offset++;
}
strcpy(cn[mcto].cpbuff,"\0");
if(lcount){strcpy(cn[mcto].cpbuff,jp);}
strcpy(cn[mcto].outp,"\0");
}
}
}
mcto++;
}
return 0;
}


int checnotname(char *jp,short whcn)
{
short mcto=127;
char temps[2048];
while(mcto>-1){
if(!stricmp(notlist[mcto],jp) && cn[whcn].noton[mcto]==0){
strcpy(temps,"[Notify]:");strcat(temps,jp);strcat(temps," has joined IRC");
sendout(temps,cwin,col[CSYSTEM]);
cn[whcn].noton[mcto]=2;
return 0;
}
if(!stricmp(notlist[mcto],jp) && cn[whcn].noton[mcto]==1){cn[whcn].noton[mcto]=2;return 0;}
mcto--;
}
return 0;
}

int addautonot()
{
short mcto=7;
while(mcto>-1){
if(strlen(ann[mcto]))addnot(ann[mcto],1);
mcto--;
}
return 0;
}

int addnot(char *jp,short reperr)
{
short mcto=127;
char temps[2048];
while(mcto>-1){
if(!stricmp(notlist[mcto],jp)){
if(!reperr)sprintf(temps,"++ %s already on list ++",jp);
sendout(temps,cwin,col[CERRORS]);
return -1;
}
if(!strlen(notlist[mcto])){strcpy(notlist[mcto],jp);return 0;}
mcto--;
}
form_alert(1,"[1][No free notifies!][Okey]");
return 0;
}

int sendison()
{
short mcto=0,fff=0,mcto2;
char temps2[2048];
char temps[2048];
strcpy(temps,"\0");strcpy(temps2,"\0");
while(mcto<NOFWIN){
if(cn[mcto].cn>-1){
sprintf(temps,":%s ISON ",cn[mcto].nick);
mcto2=127;
while(mcto2>-1){
if(strlen(notlist[mcto2])){strcat(temps,notlist[mcto2]);strcat(temps," ");fff=1;}
mcto2--;
}
strcat(temps,"\r");
if(fff==1)srt(&temps,cn[mcto].cn);
}
mcto++;
}

strcpy(temps,"\0");
return 0;
}

void startupdate()
{
wind_update(BEG_UPDATE);
graf_mouse(M_OFF,NULL);
}

void finishupdate()
{
graf_mouse(M_ON,NULL);
wind_update(END_UPDATE);	
}

int srt(char *ps,int16 cnct)
{
if(cnct>-1)TCP_send(cnct,ps,(int16)strlen(ps));
return 0;
}

void addtotablist(char *ps)
{
short mcto;
mcto=19;
while(mcto>-1){
if(!stricmp(lastn[mcto],ps)){lastnc=mcto;return;}
mcto--;
}
lastnc++;
if(lastnc>19)lastnc=0;
strcpy(lastn[lastnc],ps);
}


