/* Dialog handling utilities */

#include "fracirc2.h"
#include "header.h"

int __stdargs __saveds andftalk(DIALOG *dialog,EVNT *events,WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(hftalk,&tree,&rect);
if(obj==ftexit){tree[ftexit].ob_state&=~SELECTED;return 0;}
if(obj==ftclose){
tree[ftclose].ob_state&=~SELECTED;
closeft();
wdlg_redraw(hftalk,&rect,ftclose,MAX_DEPTH);
return 1;
}
if(obj==ftinitiate){
tree[ftinitiate].ob_state&=~SELECTED;
wdlg_redraw(hftalk,&rect,ftinitiate,MAX_DEPTH);
if(!strlen(tree[ftremote].ob_spec.tedinfo->te_ptext)){
form_alert(1,"[1][Please specify|remote][Okay]");return 1;}
strcpy(ftalk.avec,tree[ftremote].ob_spec.tedinfo->te_ptext);
initftalk();
return 1;
}
}
return 1;
}

int __stdargs __saveds andtoolbox(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(htoolbox,&tree,&rect);
}
return 1;
}

int __stdargs __saveds anddccfform(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
char temps[2048];
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(hdccfform,&tree,&rect);
if(obj==dccfcancel){tree[dccfcancel].ob_state&=~SELECTED;return 0;}
if(obj==dccfaccept){
tree[dccfaccept].ob_state&=~SELECTED;
strcpy(temps,tree[dccfeditfield].ob_spec.tedinfo->te_ptext);
initiatedccchat(temps);
return 0;
}
}
return 1;
}

int __stdargs __saveds anddcinf0(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[0].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(0,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}
int __stdargs __saveds anddcinf1(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[1].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(1,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}
int __stdargs __saveds anddcinf2(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[2].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(2,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}
int __stdargs __saveds anddcinf3(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[3].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(3,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}
int __stdargs __saveds anddcinf4(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[4].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(4,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}
int __stdargs __saveds anddcinf5(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[5].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(5,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}
int __stdargs __saveds anddcinf6(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[6].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(6,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}
int __stdargs __saveds anddcinf7(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[7].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(7,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}
int __stdargs __saveds anddcinf8(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[8].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(8,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}
int __stdargs __saveds anddcinf9(DIALOG *dialog,EVNT *events,WORD obj,WORD clicks,void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
obj&=0x7fff;
wdlg_get_tree(dcc[9].dcw,&tree,&rect);
if(obj==dc0abort){
tree[dc0abort].ob_state&=~SELECTED;
resetadcc(9,1);
form_alert(1,"[1][DCC user aborted][Aye aye]");
return 0;
}
}
return 1;
}

int __stdargs __saveds  andopenchan(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
short junk2,mcto;
char temps[2048];
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hopenchan,&tree,&rect);
if(obj==ocfaccept && cwin>-1){
if(cn[wn[cwin].cnn].cn>0){
tree[ocfaccept].ob_state&=~SELECTED;
junk2=findfreechannel();
if(junk2==-1){form_alert(1,"[1][No free channels][ :-( ]");return 0;}
mcto=0;
while(mcto<30){
if(!stricmp(chan[mcto].name,tree[ocfchanname].ob_spec.tedinfo->te_ptext) && chan[mcto].win==cwin)
{
strcpy(temps,"++ Request for channel already sent ++");
sendout(temps,cwin,col[CSYSTEM]);
return 1;
}
mcto++;
}
chan[junk2].stat=1;
strcpy(chan[junk2].name,tree[ocfchanname].ob_spec.tedinfo->te_ptext);
chan[junk2].win=cwin;
sprintf(temps,":%s JOIN %s\r",cn[wn[cwin].cnn].nick,tree[ocfchanname].ob_spec.tedinfo->te_ptext);
srt(temps,cn[wn[cwin].cnn].cn);
sprintf(temps,"-- Attempting to join %s --",tree[ocfchanname].ob_spec.tedinfo->te_ptext);
sendout(temps,cwin,col[CSYSTEM]);
dowindinfo(cwin);
}
return 0;
}
if(obj==ocfcancel){
tree[ocfcancel].ob_state&=~SELECTED;
return 0;
}

}
return 1;
}

int __stdargs __saveds andautonotify(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hautonotify,&tree,&rect);
if(obj==anlaccept){
strcpy(ann[0],tree[anlnick1].ob_spec.tedinfo->te_ptext);
strcpy(ann[1],tree[anlnick2].ob_spec.tedinfo->te_ptext);
strcpy(ann[2],tree[anlnick3].ob_spec.tedinfo->te_ptext);
strcpy(ann[3],tree[anlnick4].ob_spec.tedinfo->te_ptext);
strcpy(ann[4],tree[anlnick5].ob_spec.tedinfo->te_ptext);
strcpy(ann[5],tree[anlnick6].ob_spec.tedinfo->te_ptext);
strcpy(ann[6],tree[anlnick7].ob_spec.tedinfo->te_ptext);
strcpy(ann[7],tree[anlnick8].ob_spec.tedinfo->te_ptext);
tree[anlaccept].ob_state&=~SELECTED;
addautonot();
return 0;
}
if(obj==anlcancel){
tree[anlcancel].ob_state&=~SELECTED;
return 0;
}


}
return 1;
}
int __stdargs __saveds andamacform(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hamacform,&tree,&rect);
if(obj==amdaccept){
strcpy(am[AMQUIT],tree[amdquit].ob_spec.tedinfo->te_ptext);
strcpy(am[AMAWAY],tree[amdaway].ob_spec.tedinfo->te_ptext);
strcpy(conf.amaj1,tree[amajchn1].ob_spec.tedinfo->te_ptext);
strcpy(conf.amaj2,tree[amajchn2].ob_spec.tedinfo->te_ptext);
tree[amdaccept].ob_state&=~SELECTED;
return 0;
}
if(obj==amdcancel){
tree[amdcancel].ob_state&=~SELECTED;
return 0;
}

}
return 1;
}
int __stdargs __saveds andgeneralform(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
short blah;
char temps[2048];
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hgeneralform,&tree,&rect);
if(obj==gsaccept){
if(tree[gsautodcd].ob_state&SELECTED){conf.autodcd=1;}else{conf.autodcd=0;}
if(tree[gsautoresume].ob_state&SELECTED){conf.autoresume=1;}else{conf.autoresume=0;}
if(tree[gsautodccrecv].ob_state&SELECTED){conf.autodccrecv=1;}else{conf.autodccrecv=0;}
if(tree[gsurlgrab].ob_state&SELECTED){conf.urlgrab=1;}else{conf.urlgrab=0;}
if(tree[gsautnewwin].ob_state&SELECTED){conf.autonewwindow=1;}else{conf.autonewwindow=0;}
if(tree[gsplaysound].ob_state&SELECTED){conf.playsounds=1;}else{conf.playsounds=0;}
if(tree[gsnickchan].ob_state&SELECTED){conf.nickchan=1;}else{conf.nickchan=0;}
strcpy(temps,tree[gsnotifydelay].ob_spec.tedinfo->te_ptext);
sscanf(temps,"%d",&ndelay);
strcpy(temps,tree[gfdcbufsel].ob_spec.tedinfo->te_ptext);
sscanf(temps,"%ud",&dctbufsize);
tree[gsaccept].ob_state&=~SELECTED;
return 0;
}
if(obj==gscancel){
tree[gscancel].ob_state&=~SELECTED;
return 0;
}
if(obj==gfdcbufsel){
tree[gfdcbufsel].ob_state&=~SELECTED;
blah=doapopup(gfdcbufsel,generalform,dccbufpopup);
if(blah==dbpop256){strcpy(tree[gfdcbufsel].ob_spec.tedinfo->te_ptext,"256 ");}
if(blah==dbpop512){strcpy(tree[gfdcbufsel].ob_spec.tedinfo->te_ptext,"512 ");}
if(blah==dbpop1024){strcpy(tree[gfdcbufsel].ob_spec.tedinfo->te_ptext,"1024");}
if(blah==dbpop2048){strcpy(tree[gfdcbufsel].ob_spec.tedinfo->te_ptext,"2048");}
if(blah==dbpop4096){strcpy(tree[gfdcbufsel].ob_spec.tedinfo->te_ptext,"4096");}
wdlg_redraw(hgeneralform,&rect,gfdcbufsel,MAX_DEPTH);
return 1;

}
}
return 1;
}
int __stdargs __saveds anddccsendform(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
char temps[2048];
char temps2[2048];
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hdccsend,&tree,&rect);
if(obj==dcsfname){
tree[dcsfname].ob_state&=~SELECTED;
if(fselector((char *)&dccsname,"DCC send a file",1)==1){
if(!strlen(fname)){
form_alert(1,"[1][Please specify|file][Okay]");strcpy(dccsname,"\0");
strcpy(tree[dcsfname].ob_spec.tedinfo->te_ptext,"\0");
wdlg_redraw(hdccsend,&rect,dcsfname,MAX_DEPTH);
return 1;
}
if(strlen(dccsname)>36){
stccpy(temps,dccsname,35);strcat(temps,">");
strcpy(tree[dcsfname].ob_spec.tedinfo->te_ptext,temps);
}
else{
strcpy(tree[dcsfname].ob_spec.tedinfo->te_ptext,dccsname);
}
}
wdlg_redraw(hdccsend,&rect,dcsfname,MAX_DEPTH);
return 1;
}
if(obj==dcsfaccept){
tree[dcsfaccept].ob_state&=~SELECTED;
strcpy(temps2,tree[dcsfsendto].ob_spec.tedinfo->te_ptext);
initiatedcc(temps2,&dccsname);
return 0;
}
if(obj==dcsfcancel){
tree[dcsfcancel].ob_state&=~SELECTED;
return 0;
}

}
return 1;
}
int __stdargs __saveds andfontform(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
short junk2,junk3;
char temps[2048];
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hfontform,&tree,&rect);
if(obj==ffaccept){
tree[ffaccept].ob_state&=~SELECTED;
return 0;
}
if(obj==ffcancel){
tree[ffcancel].ob_state&=~SELECTED;
return 0;
}
if(obj==ffwinfont){
dofontselector(0);
junk2=1;
while(junk2<999){
junk3=vqt_name(ws.handle,junk2,temps);
if(junk3==winfont)junk2=1000;
junk2++;
}
stccpy(tree[ffwinfont].ob_spec.tedinfo->te_ptext,temps,21);
sprintf(temps,"%d",winpoint);
stccpy(tree[ffwinpoint].ob_spec.tedinfo->te_ptext,temps,3);
tree[ffwinfont].ob_state&=~SELECTED;
wdlg_redraw(hfontform,&rect,ffwinfont,MAX_DEPTH);
wdlg_redraw(hfontform,&rect,ffwinpoint,MAX_DEPTH);
}
if(obj==ffinpfont){
dofontselector(1);
junk2=1;
while(junk2<999){
junk3=vqt_name(ws.handle,junk2,temps);
if(junk3==inpfont)junk2=1000;
junk2++;
}
stccpy(tree[ffinpfont].ob_spec.tedinfo->te_ptext,temps,21);
sprintf(temps,"%d",inppoint);
stccpy(tree[ffinppoint].ob_spec.tedinfo->te_ptext,temps,3);

tree[ffinpfont].ob_state&=~SELECTED;
wdlg_redraw(hfontform,&rect,ffinpfont,MAX_DEPTH);
wdlg_redraw(hfontform,&rect,ffinppoint,MAX_DEPTH);
}

}
return 1;
}

int __stdargs __saveds andabout(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(habout,&tree,&rect);
if(obj==aboutexit){
tree[aboutexit].ob_state&=~SELECTED;
return 0;
}

}
return 1;
}
int __stdargs __saveds anddomacros(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
char temps[2048];
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hdomacros,&tree,&rect);
if(obj==macroaccept){
tree[macroaccept].ob_state&=~SELECTED;
strcpy(macs[0],tree[mf1].ob_spec.tedinfo->te_ptext);
strcpy(macs[1],tree[mf2].ob_spec.tedinfo->te_ptext);
strcpy(macs[2],tree[mf3].ob_spec.tedinfo->te_ptext);
strcpy(macs[3],tree[mf4].ob_spec.tedinfo->te_ptext);
strcpy(macs[4],tree[mf5].ob_spec.tedinfo->te_ptext);
strcpy(macs[5],tree[mf6].ob_spec.tedinfo->te_ptext);
strcpy(macs[6],tree[mf7].ob_spec.tedinfo->te_ptext);
strcpy(macs[7],tree[mf8].ob_spec.tedinfo->te_ptext);
strcpy(macs[8],tree[mf9].ob_spec.tedinfo->te_ptext);
strcpy(macs[9],tree[mf10].ob_spec.tedinfo->te_ptext);
return 0;
}
if(obj==macrocancel){
tree[macrocancel].ob_state&=~SELECTED;
return 0;
}
if(obj==macroload){
tree[macroload].ob_state&=~SELECTED;
if(fselector(temps,"Load Macro set",1)==1)loadmacs(temps);
strcpy(tree[mf1].ob_spec.tedinfo->te_ptext,macs[0]);
strcpy(tree[mf2].ob_spec.tedinfo->te_ptext,macs[1]);
strcpy(tree[mf3].ob_spec.tedinfo->te_ptext,macs[2]);
strcpy(tree[mf4].ob_spec.tedinfo->te_ptext,macs[3]);
strcpy(tree[mf5].ob_spec.tedinfo->te_ptext,macs[4]);
strcpy(tree[mf6].ob_spec.tedinfo->te_ptext,macs[5]);
strcpy(tree[mf7].ob_spec.tedinfo->te_ptext,macs[6]);
strcpy(tree[mf8].ob_spec.tedinfo->te_ptext,macs[7]);
strcpy(tree[mf9].ob_spec.tedinfo->te_ptext,macs[8]);
strcpy(tree[mf10].ob_spec.tedinfo->te_ptext,macs[9]);
wdlg_redraw(hdomacros,&rect,macroload,MAX_DEPTH);
wdlg_redraw(hdomacros,&rect,mf1,MAX_DEPTH);wdlg_redraw(hdomacros,&rect,mf2,MAX_DEPTH);
wdlg_redraw(hdomacros,&rect,mf3,MAX_DEPTH);wdlg_redraw(hdomacros,&rect,mf4,MAX_DEPTH);
wdlg_redraw(hdomacros,&rect,mf5,MAX_DEPTH);wdlg_redraw(hdomacros,&rect,mf6,MAX_DEPTH);
wdlg_redraw(hdomacros,&rect,mf7,MAX_DEPTH);wdlg_redraw(hdomacros,&rect,mf8,MAX_DEPTH);
wdlg_redraw(hdomacros,&rect,mf9,MAX_DEPTH);wdlg_redraw(hdomacros,&rect,mf10,MAX_DEPTH);
return 1;
}
if(obj==macrosave){
tree[macrosave].ob_state&=~SELECTED;
strcpy(macs[0],tree[mf1].ob_spec.tedinfo->te_ptext);
strcpy(macs[1],tree[mf2].ob_spec.tedinfo->te_ptext);
strcpy(macs[2],tree[mf3].ob_spec.tedinfo->te_ptext);
strcpy(macs[3],tree[mf4].ob_spec.tedinfo->te_ptext);
strcpy(macs[4],tree[mf5].ob_spec.tedinfo->te_ptext);
strcpy(macs[5],tree[mf6].ob_spec.tedinfo->te_ptext);
strcpy(macs[6],tree[mf7].ob_spec.tedinfo->te_ptext);
strcpy(macs[7],tree[mf8].ob_spec.tedinfo->te_ptext);
strcpy(macs[8],tree[mf9].ob_spec.tedinfo->te_ptext);
strcpy(macs[9],tree[mf10].ob_spec.tedinfo->te_ptext);
if(fselector(temps,"Save Macro set",1)==1)savmacs(temps);
wdlg_redraw(hdomacros,&rect,macrosave,MAX_DEPTH);
return 1;
}

}
return 1;
}
int __stdargs __saveds andsortconnect(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
OBJECT *stre;
GRECT rect;
int blah;
short mcto=0,rem=-1;
char temps[2048];
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hsortconnect,&tree,&rect);
if(obj==scaccept){
tree[scaccept].ob_state&=~SELECTED;
strcpy(oserver,tree[scserver].ob_spec.tedinfo->te_ptext);
strcpy(oport,tree[scport].ob_spec.tedinfo->te_ptext);
if(tree[scautojoin].ob_state&SELECTED){conf.autojoin=1;}else{conf.autojoin=0;}
while(mcto<NOFWIN){
if(cn[mcto].cn==-1)rem=mcto;
if(!stricmp(cn[mcto].server,oserver) && cn[mcto].cn>-1){
form_alert(1,"[1][Already connected|to server][Oops!]");
return 1;
}
mcto++;;
}
if(rem==-1){form_alert(1,"[1][No free connections][Fu..Damn!]");return 1;}
strcpy(cn[rem].nick,tree[scalias].ob_spec.tedinfo->te_ptext);
oc=5;
pfctcr=rem;
wn[cwin].cnn=rem;
return 0;
}
if(obj==sccancel){
tree[sccancel].ob_state&=~SELECTED;
return 0;
}
if(obj==scserver){
tree[scserver].ob_state&=~SELECTED;
rsrc_gaddr(R_TREE,serverpop,&stre);
if(strlen(irc_server[0])){
strcpy(temps,irc_server[0]);strcat(temps,":");strcat(temps,irc_port[0]);
strcpy(stre[sps1].ob_spec.tedinfo->te_ptext,temps);stre[sps1].ob_state&=~SELECTED;}
else{strcpy(stre[sps1].ob_spec.tedinfo->te_ptext,"Not defined");stre[sps1].ob_state=DISABLED;}
if(strlen(irc_server[1])){
strcpy(temps,irc_server[1]);strcat(temps,":");strcat(temps,irc_port[1]);
strcpy(stre[sps2].ob_spec.tedinfo->te_ptext,temps);stre[sps2].ob_state&=~SELECTED;}
else{strcpy(stre[sps2].ob_spec.tedinfo->te_ptext,"Not defined");stre[sps2].ob_state=DISABLED;}
if(strlen(irc_server[2])){
strcpy(temps,irc_server[2]);strcat(temps,":");strcat(temps,irc_port[2]);
strcpy(stre[sps3].ob_spec.tedinfo->te_ptext,temps);stre[sps3].ob_state&=~SELECTED;}
else{strcpy(stre[sps3].ob_spec.tedinfo->te_ptext,"Not defined");stre[sps3].ob_state=DISABLED;}
if(strlen(irc_server[3])){
strcpy(temps,irc_server[3]);strcat(temps,":");strcat(temps,irc_port[3]);
strcpy(stre[sps4].ob_spec.tedinfo->te_ptext,temps);stre[sps4].ob_state&=~SELECTED;}
else{strcpy(stre[sps4].ob_spec.tedinfo->te_ptext,"Not defined");stre[sps4].ob_state=DISABLED;}
blah=doapopup(scserver,sortconnect,serverpop);
if(blah){
strcpy(tree[scserver].ob_spec.tedinfo->te_ptext,irc_server[blah-1]);
strcpy(tree[scport].ob_spec.tedinfo->te_ptext,irc_port[blah-1]);
}
wdlg_redraw(hsortconnect,&rect,scserver,MAX_DEPTH);
wdlg_redraw(hsortconnect,&rect,scport,MAX_DEPTH);
wdlg_redraw(hsortconnect,&rect,scserver,MAX_DEPTH);
return 1;
}
}
return 1;
}

int __stdargs __saveds andsetcols(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
short dodge;
short ad=0;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hsetcols,&tree,&rect);
if(obj==cfcancel){
tree[cfcancel].ob_state&=~SELECTED;
return 0;
}


if(obj==cfaccept){
tree[cfaccept].ob_state&=~SELECTED;
col[CPMSGSFROM]=tree[cfpmsgsfrom].ob_spec.obspec.interiorcol;
col[CPMSGSTO]=tree[cfpmsgsto].ob_spec.obspec.interiorcol;
col[CCURSOR]=tree[cfcursor].ob_spec.obspec.interiorcol;
col[CINPTEXT]=tree[cfinptext].ob_spec.obspec.interiorcol;
col[CSYSTEM]=tree[cfsystem].ob_spec.obspec.interiorcol;
col[CACTIONS]=tree[cfactions].ob_spec.obspec.interiorcol;
col[CDCCINFO]=tree[cfdccinfo].ob_spec.obspec.interiorcol;
col[CERRORS]=tree[cferrors].ob_spec.obspec.interiorcol;
col[CBODY]=tree[cfbody].ob_spec.obspec.interiorcol;
col[CBACK]=tree[cfback].ob_spec.obspec.interiorcol;
col[CDIVIDET]=tree[cfdividet].ob_spec.obspec.interiorcol;
col[CDIVIDEB]=tree[cfdivideb].ob_spec.obspec.interiorcol;
col[CINPINFO]=tree[cfinpinfo].ob_spec.obspec.interiorcol;
col[CNICKLIST]=tree[cfnicklist].ob_spec.obspec.interiorcol;
col[CNLBACK]=tree[cfnicklistback].ob_spec.obspec.interiorcol;
col[CINPBACK]=tree[cfinpback].ob_spec.obspec.interiorcol;
col[CNLDIVIDE]=tree[cfnldivide].ob_spec.obspec.interiorcol;
col[CINPINFO]=tree[cfinpinfo].ob_spec.obspec.interiorcol;

vsf_color(ws.handle,col[CBACK]);
while(ad<NOFWIN){
if(wn[ad].hand>-1){
initiateredraw(ad,wn[ad].wwa.g_x,wn[ad].wwa.g_y,wn[ad].wwa.g_w,wn[ad].wwa.g_h);
}
ad++;
}
return 0;
}
else{
dodge=doacolorpopup(obj,colourform);
if(dodge>-1){tree[obj].ob_spec.obspec.interiorcol=dodge;}
tree[obj].ob_state&=~SELECTED;
wdlg_redraw(hsetcols,&rect,obj,MAX_DEPTH);
return 1;
}


}
return 1;
}

int doapopup(short bobj,short popform,short frm)
{
GRECT popup;
OBJECT *tree, *tree2;
short bugger;
rsrc_gaddr(R_TREE,popform,&tree);
objc_xywh(tree,bobj,&popup);
rsrc_gaddr(R_TREE,frm,&tree2);
tree2[ROOT].ob_x=popup.g_x;
tree2[ROOT].ob_y=popup.g_y;
bugger=form_popup(tree2,0,0);
return (bugger);
}

int doacolorpopup(short bobj,short popform)
{
GRECT popup;
OBJECT *tree,*tree2;
short bugger;
short frm=colourpop;
if(ws.planes>=4)frm=colourpop;
rsrc_gaddr(R_TREE,popform,&tree);
objc_xywh(tree,bobj,&popup);
rsrc_gaddr(R_TREE,frm,&tree2);
tree2[ROOT].ob_x=popup.g_x;
tree2[ROOT].ob_y=popup.g_y;
bugger=form_popup(tree2,0,0);
return (bugger-2);
}

int __stdargs __saveds anddisplay(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
short blah;
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hdisplay,&tree,&rect);
if(obj==dscancel){
tree[dscancel].ob_state&=~SELECTED;
return 0;
}
if(obj==dsaccept){
tree[dsaccept].ob_state&=~SELECTED;
if(tree[dsboldnicks].ob_state&SELECTED){conf.boldnicks=1;}else{conf.boldnicks=0;}

if(!strnicmp(tree[dfscrolsel].ob_spec.tedinfo->te_ptext,"S",1)){
conf.smothscrol=1;}
else{conf.smothscrol=0;}
if(!strnicmp(tree[dfscrolspeed].ob_spec.tedinfo->te_ptext,"S",1))conf.smscrolspd=1;
if(!strnicmp(tree[dfscrolspeed].ob_spec.tedinfo->te_ptext,"N",1))conf.smscrolspd=2;
if(!strnicmp(tree[dfscrolspeed].ob_spec.tedinfo->te_ptext,"F",1))conf.smscrolspd=4;
return 0;
}
if(obj==dfscrolsel){
tree[dfscrolsel].ob_state&=~SELECTED;
blah=doapopup(dfscrolsel,displayform,scrolpopup);
if(blah==spopfast){strcpy(tree[dfscrolsel].ob_spec.tedinfo->te_ptext,"Fast  ");}
else{strcpy(tree[dfscrolsel].ob_spec.tedinfo->te_ptext,"Smooth");}
wdlg_redraw(hdisplay,&rect,dfscrolsel,MAX_DEPTH);
return 1;
}
if(obj==dfscrolspeed){
tree[dfscrolspeed].ob_state&=~SELECTED;
blah=doapopup(dfscrolspeed,displayform,scrolspdpop);
if(blah==sspslow)strcpy(tree[dfscrolspeed].ob_spec.tedinfo->te_ptext,"Slow  ");
if(blah==sspnormal)strcpy(tree[dfscrolspeed].ob_spec.tedinfo->te_ptext,"Normal");
if(blah==sspfast)strcpy(tree[dfscrolspeed].ob_spec.tedinfo->te_ptext,"Fast  ");
wdlg_redraw(hdisplay,&rect,dfscrolspeed,MAX_DEPTH);
return 1;
}

}
return 1;
}
int __stdargs __saveds andpathset(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
char temps[2048];
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hpathset,&tree,&rect);
if(obj==psaccept){
tree[psaccept].ob_state&=~SELECTED;
return 0;
}
if(obj==pscancel){
tree[pscancel].ob_state&=~SELECTED;
strcpy(path.url,path.oldurl);
strcpy(path.dcc,path.olddcc);
strcpy(path.log,path.oldlog);
strcpy(path.sound,path.oldsound);
return 0;
}
if(obj==pssounddir){
tree[pssounddir].ob_state&=~SELECTED;
wd_close(hpathset);
if(fselector(temps,"Sound directory",0)==1){
strcpy(path.sound,temps);
if(strlen(path.sound)<36)strcpy(tree[pssounddir].ob_spec.tedinfo->te_ptext,path.sound);
else{
stccpy(temps,path.sound,35);strcat(temps,">");
strcpy(tree[pssounddir].ob_spec.tedinfo->te_ptext,temps);
}
dw_open(hpathset,"Path settings",NAME+CLOSER+MOVER,-1,-1,0,0L);
wdlg_redraw(hpathset,&rect,pssounddir,MAX_DEPTH);
}
return 1;
}
if(obj==psurlfile){
tree[psurlfile].ob_state&=~SELECTED;
if(fselector(temps,"URL record file",1)==1){
strcpy(path.url,temps);
if(strlen(path.url)<36)strcpy(tree[psurlfile].ob_spec.tedinfo->te_ptext,path.url);
else{
stccpy(temps,path.url,35);strcat(temps,">");
strcpy(tree[psurlfile].ob_spec.tedinfo->te_ptext,temps);
}
wdlg_redraw(hpathset,&rect,psurlfile,MAX_DEPTH);
}
return 1;
}
if(obj==psdccrecv){
tree[psdccrecv].ob_state&=~SELECTED;
if(fselector(temps,"DCC Receive path",0)==1){
strcpy(path.dcc,temps);
if(strlen(path.dcc)<36)strcpy(tree[psdccrecv].ob_spec.tedinfo->te_ptext,path.dcc);
else{
stccpy(temps,path.dcc,35);strcat(temps,">");
strcpy(tree[psdccrecv].ob_spec.tedinfo->te_ptext,temps);
}
wdlg_redraw(hpathset,&rect,psdccrecv,MAX_DEPTH);
}
return 1;
}

if(obj==pslogfile){
tree[pslogfile].ob_state&=~SELECTED;
if(fselector(temps,"Fracirc Log file",1)==1){
strcpy(path.log,temps);
if(strlen(path.log)<36)strcpy(tree[pslogfile].ob_spec.tedinfo->te_ptext,path.log);
else{
stccpy(temps,path.log,35);strcat(temps,">");
strcpy(tree[pslogfile].ob_spec.tedinfo->te_ptext,temps);
}
wdlg_redraw(hpathset,&rect,pslogfile,MAX_DEPTH);
}
return 1;
}
}
return 1;
}

int __stdargs __saveds anduserset(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(huserset,&tree,&rect);
if(obj==usaccept){
tree[usaccept].ob_state&=~SELECTED;
strcpy(conf.snick,tree[usalias].ob_spec.tedinfo->te_ptext);
strcpy(conf.snick2,tree[usalias2].ob_spec.tedinfo->te_ptext);
strcpy(username,tree[ususername].ob_spec.tedinfo->te_ptext);
strcpy(realname,tree[usrealname].ob_spec.tedinfo->te_ptext);
strcpy(hostname,tree[ushostname].ob_spec.tedinfo->te_ptext);
dowindinfo(cwin);
return 0;
}
if(obj==uscancel){
tree[uscancel].ob_state&=~SELECTED;
strcpy(tree[usalias].ob_spec.tedinfo->te_ptext,"\0");
return 0;
}

}
return 1;
}
int __stdargs __saveds andserverset(DIALOG *dialog,EVNT *events, WORD obj, WORD clicks, void *data)
{
OBJECT *tree;
GRECT rect;
if(obj<0){
if(obj==HNDL_CLSD){return 0;}
}
else{
		 obj &= 0x7fff;
wdlg_get_tree(hserverset,&tree,&rect);
if(obj==ssaccept){
tree[ssaccept].ob_state&=~SELECTED;
strcpy(irc_server[0],tree[ssserver1].ob_spec.tedinfo->te_ptext);
strcpy(irc_server[1],tree[ssserver2].ob_spec.tedinfo->te_ptext);
strcpy(irc_server[2],tree[ssserver3].ob_spec.tedinfo->te_ptext);
strcpy(irc_server[3],tree[ssserver4].ob_spec.tedinfo->te_ptext);
strcpy(irc_port[0],tree[ssport1].ob_spec.tedinfo->te_ptext);
strcpy(irc_port[1],tree[ssport2].ob_spec.tedinfo->te_ptext);
strcpy(irc_port[2],tree[ssport3].ob_spec.tedinfo->te_ptext);
strcpy(irc_port[3],tree[ssport4].ob_spec.tedinfo->te_ptext);
return 0;
}
if(obj==sscancel){
tree[sscancel].ob_state&=~SELECTED;
return 0;
}

}
return 1;
}


