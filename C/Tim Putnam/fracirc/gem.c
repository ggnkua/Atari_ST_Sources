#include "d:\fracirc\fracirc2.h"
#include "d:\fracirc\header.h"


int dofontset(void)
{
OBJECT *tree;
GRECT rect;
short junk2,junk3;
char fntnam[512];
menu_tnormal(mnu,optionm,1);
wdlg_get_tree(hfontform,&tree,&rect);
if(vq_gdos()!=0)tree[ffgdosloaded].ob_state|=CHECKED;
junk2=1;
while(junk2<999){
junk3=vqt_name(ws.handle,junk2,fntnam);
if(junk3==winfont)junk2=1000;
junk2++;
}
stccpy(tree[ffwinfont].ob_spec.tedinfo->te_ptext,fntnam,21);
junk2=1;
while(junk2<999){
junk3=vqt_name(ws.handle,junk2,fntnam);
if(junk3==inpfont)junk2=1000;
junk2++;
}
stccpy(tree[ffinpfont].ob_spec.tedinfo->te_ptext,fntnam,21);
sprintf(fntnam,"%dl",winpoint);
stccpy(tree[ffwinpoint].ob_spec.tedinfo->te_ptext,fntnam,3);
sprintf(fntnam,"%dl",inppoint);
stccpy(tree[ffinppoint].ob_spec.tedinfo->te_ptext,fntnam,3);
junk2=dw_open(hfontform,"Font selection",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk2==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}

int dodccsend(char *file)
{
OBJECT *tree;
GRECT rect;
int junk;
menu_tnormal(mnu,dccm,1);
wdlg_get_tree(hdccsend,&tree,&rect);
if(file){
if(*(file+strlen(file)-1)<40)*(file+strlen(file)-1)=0;
strncpy(tree[dcsfname].ob_spec.tedinfo->te_ptext,file,36);
strcpy(dccsname,file);
}
strcpy(tree[dcsfsendto].ob_spec.tedinfo->te_ptext,"\0");
junk=dw_open(hdccsend,"DCC send",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}


int doftalk(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(hftalk,&tree,&rect);
strcpy(tree[ftremote].ob_spec.tedinfo->te_ptext,ftalk.avec);
if(ftalk.stat==SAWAIT)strcpy(tree[ftstatus].ob_spec.tedinfo->te_ptext,"Wait for remote response");
if(ftalk.stat==0)strcpy(tree[ftstatus].ob_spec.tedinfo->te_ptext,"Not in use");
if(ftalk.stat==SACTIVE)strcpy(tree[ftstatus].ob_spec.tedinfo->te_ptext,"Connected");
junk=dw_open(hftalk,"FracTALK",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}

int domacros(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(hdomacros,&tree,&rect);
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
junk=dw_open(hdomacros,"Macro definition",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");

return 0;
}

int dopathset(void)
{
OBJECT *tree;
GRECT rect;
int junk;
char temps[1024];
wdlg_get_tree(hpathset,&tree,&rect);
strcpy(path.olddcc,path.dcc);
strcpy(path.oldlog,path.log);
strcpy(path.oldurl,path.url);
strcpy(path.oldsound,path.sound);
if(strlen(path.sound)<36)strcpy(tree[pssounddir].ob_spec.tedinfo->te_ptext,path.sound);
else{
stccpy(temps,path.sound,35);strcat(temps,">");
strcpy(tree[pssounddir].ob_spec.tedinfo->te_ptext,temps);
}
if(strlen(path.url)<36)strcpy(tree[psurlfile].ob_spec.tedinfo->te_ptext,path.url);
else{
stccpy(temps,path.url,35);strcat(temps,">");
strcpy(tree[psurlfile].ob_spec.tedinfo->te_ptext,temps);
}
if(strlen(path.dcc)<36)strcpy(tree[psdccrecv].ob_spec.tedinfo->te_ptext,path.dcc);
else{
stccpy(temps,path.dcc,35);strcat(temps,">");
strcpy(tree[psdccrecv].ob_spec.tedinfo->te_ptext,temps);
}
if(strlen(path.log)<36)strcpy(tree[pslogfile].ob_spec.tedinfo->te_ptext,path.log);
else{
stccpy(temps,path.log,35);strcat(temps,">");
strcpy(tree[pslogfile].ob_spec.tedinfo->te_ptext,temps);
}
junk=dw_open(hpathset,"Path settings",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Blah]");
return 0;
}


int	dotheabout(void)
{
OBJECT *tree;
GRECT rect;
int junk;

wdlg_get_tree(habout,&tree,&rect);
junk=dw_open(habout,"Fracirc V2.00",NAME+MOVER+CLOSER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Blah]");
return 0;
}

int sortconnection(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(hsortconnect,&tree,&rect);
strcpy(tree[scserver].ob_spec.tedinfo->te_ptext,irc_server[serv]);
strcpy(tree[scport].ob_spec.tedinfo->te_ptext,irc_port[serv]);
strcpy(tree[scalias].ob_spec.tedinfo->te_ptext,conf.snick);
if(conf.autojoin)tree[scautojoin].ob_state|=SELECTED;
junk=dw_open(hsortconnect,"Open connection",NAME+MOVER+CLOSER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}


int openautonotify(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(hautonotify,&tree,&rect);
strcpy(tree[anlnick1].ob_spec.tedinfo->te_ptext,ann[0]);
strcpy(tree[anlnick2].ob_spec.tedinfo->te_ptext,ann[1]);
strcpy(tree[anlnick3].ob_spec.tedinfo->te_ptext,ann[2]);
strcpy(tree[anlnick4].ob_spec.tedinfo->te_ptext,ann[3]);
strcpy(tree[anlnick5].ob_spec.tedinfo->te_ptext,ann[4]);
strcpy(tree[anlnick6].ob_spec.tedinfo->te_ptext,ann[5]);
strcpy(tree[anlnick7].ob_spec.tedinfo->te_ptext,ann[6]);
strcpy(tree[anlnick8].ob_spec.tedinfo->te_ptext,ann[7]);
junk=dw_open(hautonotify,"Auto-notify list",NAME+MOVER+CLOSER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open |auto notify list][Ok]");
return 0;
}

int openamacs(void)
{
GRECT rect;
OBJECT *tree;
int junk;
wdlg_get_tree(hamacform,&tree,&rect);
strcpy(tree[amdquit].ob_spec.tedinfo->te_ptext,am[AMQUIT]);
strcpy(tree[amdaway].ob_spec.tedinfo->te_ptext,am[AMAWAY]);
strcpy(tree[amajchn1].ob_spec.tedinfo->te_ptext,conf.amaj1);
strcpy(tree[amajchn2].ob_spec.tedinfo->te_ptext,conf.amaj2);
junk=dw_open(hamacform,"Auto Macro settings",NAME+MOVER+CLOSER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open |Auto macro settings][Ok]");
return 0;
}


int opengeneral(void)
{
OBJECT *tree;
GRECT rect;
int junk;
char temps[512];
wdlg_get_tree(hgeneralform,&tree,&rect);
if(conf.autodcd)tree[gsautodcd].ob_state|=SELECTED;
if(conf.autoresume)tree[gsautoresume].ob_state|=SELECTED;
if(conf.autodccrecv)tree[gsautodccrecv].ob_state|=SELECTED;
if(conf.urlgrab)tree[gsurlgrab].ob_state|=SELECTED;
if(conf.autonewwindow)tree[gsautnewwin].ob_state|=SELECTED;
if(conf.playsounds)tree[gsplaysound].ob_state|=SELECTED;
if(conf.nickchan)tree[gsnickchan].ob_state|=SELECTED;
sprintf(temps,"%d",dctbufsize);
strcpy(tree[gfdcbufsel].ob_spec.tedinfo->te_ptext,temps);
strcpy(temps,"\0");
sprintf(temps,"%d",ndelay);
strcpy(tree[gsnotifydelay].ob_spec.tedinfo->te_ptext,temps);
junk=dw_open(hgeneralform,"General settings",NAME+MOVER+CLOSER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open |general settings][Ok]");
return 0;
}

int openchan(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(hopenchan,&tree,&rect);
strcpy(tree[ocfchanname].ob_spec.tedinfo->te_ptext,"\0");
junk=dw_open(hopenchan,"Open a channel",NAME+MOVER+CLOSER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}

int dodccchatform(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(hdccfform,&tree,&rect);
strcpy(tree[dccfeditfield].ob_spec.tedinfo->te_ptext,"\0");
junk=dw_open(hdccfform,"Initiate chat",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}


int stoolbox(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(htoolbox,&tree,&rect);
strcpy(tree[tbnick].ob_spec.tedinfo->te_ptext,"\0");
junk=dw_open(htoolbox,"Toolbox",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}

int setcols(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(hsetcols,&tree,&rect);

tree[cfpmsgsfrom].ob_spec.obspec.interiorcol=col[CPMSGSFROM];
tree[cfpmsgsto].ob_spec.obspec.interiorcol=col[CPMSGSTO];
tree[cfcursor].ob_spec.obspec.interiorcol=col[CCURSOR];
tree[cfinptext].ob_spec.obspec.interiorcol=col[CINPTEXT];
tree[cfsystem].ob_spec.obspec.interiorcol=col[CSYSTEM];
tree[cfactions].ob_spec.obspec.interiorcol=col[CACTIONS];
tree[cfdccinfo].ob_spec.obspec.interiorcol=col[CDCCINFO];
tree[cferrors].ob_spec.obspec.interiorcol=col[CERRORS];
tree[cfbody].ob_spec.obspec.interiorcol=col[CBODY];
tree[cfback].ob_spec.obspec.interiorcol=col[CBACK];
tree[cfdividet].ob_spec.obspec.interiorcol=col[CDIVIDET];
tree[cfdivideb].ob_spec.obspec.interiorcol=col[CDIVIDEB];
tree[cfnicklist].ob_spec.obspec.interiorcol=col[CNICKLIST];
tree[cfnicklistback].ob_spec.obspec.interiorcol=col[CNLBACK];
tree[cfinpback].ob_spec.obspec.interiorcol=col[CINPBACK];
tree[cfnldivide].ob_spec.obspec.interiorcol=col[CNLDIVIDE];
tree[cfinpinfo].ob_spec.obspec.interiorcol=col[CINPINFO];

junk=dw_open(hsetcols,"Assign colours",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}

int dispoptions(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(hdisplay,&tree,&rect);
if(conf.boldnicks)tree[dsboldnicks].ob_state|=SELECTED;
if(conf.smothscrol){strcpy(tree[dfscrolsel].ob_spec.tedinfo->te_ptext,"Smooth");}
else{strcpy(tree[dfscrolsel].ob_spec.tedinfo->te_ptext," Fast ");}
if(conf.smscrolspd==1)strcpy(tree[dfscrolspeed].ob_spec.tedinfo->te_ptext,"Slow  ");
if(conf.smscrolspd==2)strcpy(tree[dfscrolspeed].ob_spec.tedinfo->te_ptext,"Normal");
if(conf.smscrolspd==4)strcpy(tree[dfscrolspeed].ob_spec.tedinfo->te_ptext,"Fast  ");
junk=dw_open(hdisplay,"Display settings",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}

int useroptions(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(huserset,&tree,&rect);
strcpy(tree[usalias].ob_spec.tedinfo->te_ptext,conf.snick);
strcpy(tree[usalias2].ob_spec.tedinfo->te_ptext,conf.snick2);
strcpy(tree[usrealname].ob_spec.tedinfo->te_ptext,realname);
strcpy(tree[ushostname].ob_spec.tedinfo->te_ptext,hostname);
strcpy(tree[ususername].ob_spec.tedinfo->te_ptext,username);
junk=dw_open(huserset,"User settings",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}

int serveroptions(void)
{
OBJECT *tree;
GRECT rect;
int junk;
wdlg_get_tree(hserverset,&tree,&rect);
strcpy(tree[ssserver1].ob_spec.tedinfo->te_ptext,irc_server[0]);
strcpy(tree[ssserver2].ob_spec.tedinfo->te_ptext,irc_server[1]);
strcpy(tree[ssserver3].ob_spec.tedinfo->te_ptext,irc_server[2]);
strcpy(tree[ssserver4].ob_spec.tedinfo->te_ptext,irc_server[3]);
strcpy(tree[ssport1].ob_spec.tedinfo->te_ptext,irc_port[0]);
strcpy(tree[ssport2].ob_spec.tedinfo->te_ptext,irc_port[1]);
strcpy(tree[ssport3].ob_spec.tedinfo->te_ptext,irc_port[2]);
strcpy(tree[ssport4].ob_spec.tedinfo->te_ptext,irc_port[3]);
junk=dw_open(hserverset,"Server settings",NAME+CLOSER+MOVER,-1,-1,0,0L);
if(junk==0)form_alert(1,"[1][Unable to open dialogue][Ok]");
return 0;
}

int dw_open(DIALOG *dialog, BYTE *title, WORD kind, WORD x, WORD y, WORD code, void *data)
	{
	 short i,handle;
	 	{
		 for(i=0;i <= 127; i++)
		 	if(dials[i] == dialog)
		 		{
		 		 handle = wdlg_get_handle(dialog);
		 		 wind_set(handle, WF_TOP,0,0,0,0);
		 		 return(handle);
		 		}
		}

	 add_dial(dialog);
	 return(wdlg_open(dialog, title, kind, x, y, code, data));
	}

int fselector(char *buf,char *strg,short f)
{
char *pp;
short count=0;
int junk;

strcpy(buf,"\0");
fsel_exinput(fpath,fname,&junk,strg);
if(!junk)return -1;
pp=fpath+strlen(fpath);
while(pp>fpath){
pp--;count++;
if(!strncmp(pp,"\\",1)){
strncpy(buf,fpath,strlen(fpath)-count+1);
pp=buf+strlen(fpath)-count+1;*pp=0;
if(f)strcat(buf,fname);

return 1;
}
}
return -1;
}

int basename(char *s)
{

	char news[80], *p;
	p = &s[strlen(s)-1];
	while (p > s) {
		if (*p == '\\' || *p == '/' || *p == ':' || *p == ']') {
			++p;
			break;
		}
		--p;
	}
	strcpy(news, p);
	strcpy(s, news);
	return ((int)strlen(s));
}


int opendccrecvdialog(short temp,char *name){
OBJECT *tree;
int junk;
rsrc_gaddr(R_TREE,dcinf0+temp,&tree);
tree[dc0bar].ob_width=1;
sprintf(tree[dc0tbytes].ob_spec.tedinfo->te_ptext,"%ld",dcc[temp].len);
sprintf(tree[dc0bytes].ob_spec.tedinfo->te_ptext,"%ld",dcc[temp].cnt);
strcpy(tree[dc0fname].ob_spec.tedinfo->te_ptext,name);
strcpy(tree[dc0avec].ob_spec.tedinfo->te_ptext,dcc[temp].avec);
sprintf(dcc[temp].dtit,"DCC Receive %d",temp);
junk=dw_open(dcc[temp].dcw,dcc[temp].dtit,NAME+MOVER+CLOSER,-1,-1,0,0L);
if(junk==0){form_alert(1,"[1][Unable to open dialogue][Ok]");return 0;}
dobar(dcc[temp].dcw,(long)dcc[temp].cnt,dcc[temp].len,temp);
return 0;
}

int opendccsenddialog(short temp,char *name){
OBJECT *tree;
int junk;
rsrc_gaddr(R_TREE,dcinf0+temp,&tree);
tree[dc0bar].ob_width=1;
sprintf(tree[dc0tbytes].ob_spec.tedinfo->te_ptext,"%ld",dcc[temp].len);
sprintf(tree[dc0bytes].ob_spec.tedinfo->te_ptext,"%ld",dcc[temp].cnt);
strcpy(tree[dc0fname].ob_spec.tedinfo->te_ptext,name);
strcpy(tree[dc0avec].ob_spec.tedinfo->te_ptext,dcc[temp].avec);
sprintf(dcc[temp].dtit,"DCC send %d",temp);
junk=dw_open(dcc[temp].dcw,dcc[temp].dtit,NAME+MOVER+CLOSER,-1,-1,0,0L);
if(junk==0){form_alert(1,"[1][Unable to open dialogue][Ok]");return 0;}
dobar(dcc[temp].dcw,(long)dcc[temp].cnt,dcc[temp].len,temp);
return 0;
}