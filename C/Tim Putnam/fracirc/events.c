/* Event code */
extern short mdrag;

#include "header.h"
#include "fracirc2.h"

void event_loop( void )
	{
	 short fin;
	 quit = FALSE;

 	 while(!quit)
 		{
		 EVNT_multi(MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER,
					2, 1, (1-mdrag),
					NULL,						/* kein 1. Rechteck */
					NULL,						/* kein 2. Rechteck */
					50,
					&events);
		 fin = HandleDialoges();
		 HandleEvents(fin);
		}

	 qt();
	}

void	HandleEvents(short fin)
	{
	 if(events.mwhich&MU_KEYBD){HandleKeybd(events.key);}
	 if(events.mwhich&MU_MESAG){HandleMessage(events.msg);}
	 if(events.mwhich&MU_TIMER){HandleTimer();}
	 if(events.mwhich&MU_BUTTON){HandleButton();}
	return;
	}

void HandleMessage(WORD *msg)
{
int blunk;
switch(msg[0])
	{
	 case AP_DRAGDROP:
	 Handledragdrop(msg);
	 break;
	 case AP_TERM:
	 	qt();
	 	break;
	 case MN_SELECTED:
	 	HandleMenus(msg);
	 	break;
	}
	if(msg[0]==WM_VSLID)sbvslid(msg[4]);
	
	if(msg[0]==WM_SHADED){wn[findwhand(msg[3])].stat=WMDONTWRITE;}
	if(msg[0]==WM_UNSHADED){wn[findwhand(msg[3])].stat=WMCLEAR;initiateredraw(findwhand(msg[3]),wn[findwhand(msg[3])].wwa.g_x,wn[findwhand(msg[3])].wwa.g_y,wn[findwhand(msg[3])].wwa.g_w,wn[findwhand(msg[3])].wwa.g_h);}
	if(msg[0]==WM_ICONIFY){wind_set(msg[3],WF_ICONIFY,msg[4],msg[5],msg[6],msg[7]);wn[findwhand(msg[3])].stat=WMDONTWRITE;}
	if(msg[0]==WM_UNICONIFY){
	blunk=findwhand(msg[3]);
	wind_set(msg[3],WF_UNICONIFY,msg[4],msg[5],msg[6],msg[7]);
	wn[blunk].stat=WMCLEAR;}
	if(msg[0]==WM_ARROWED){
	if(msg[4]==WA_UPLINE){scrollback();}
	if(msg[4]==WA_DNLINE){scrollbbk();}
	}
	if(msg[0]==WM_TOPPED)topwindow(findwhand(msg[3]));
	if(msg[0]==WM_FULLED)fullwin(findwhand(msg[3]));
	if(msg[0]==WM_MOVED)resizewindow(findwhand(msg[3]),msg[4],msg[5],msg[6],msg[7],0);
	if(msg[0]==WM_SIZED)resizewindow(findwhand(msg[3]),msg[4],msg[5],msg[6],msg[7],1);
	if(msg[0]==WM_CLOSED){closewin(findwhand(msg[3]));}
	if(msg[0]==WM_REDRAW){sortredraw(msg[3],msg[4],msg[5],msg[6],msg[7]);}
	if(msg[0]==WM_BOTTOMED){wind_set(msg[3],WF_BOTTOM,msg[4],msg[5],msg[6],msg[7]);}
}


void HandleTimer(void)
{
if(oc)oc--;
if(oc==1){
oc=0;
openconnection();
}
blink--;
if(blink==2){docursor(cwin);}
if(blink==0){blink=6;docursor(cwin);}
if(lastnt>0)lastnt--;
check_carrier();
notcount++;
if(notcount==20*ndelay){notcount=0;sendison();}
identd_timer();
checkports();
dcc_recv();
dcc_send();
checkdccchat();
processftalk();
}

void HandleButton(void)
{

if(!mdrag){
if(events.mx>wn[cwin].wwa.g_x && events.mx<wn[cwin].wwa.g_x+wn[cwin].wwa.g_w){
if(events.my>wn[cwin].wwa.g_y && events.my<wn[cwin].wwa.g_y+wn[cwin].wwa.g_h-ith*3){
scx=events.mx;scy=events.my;
mdrag=1;
}
}
}
else{
mdrag=0;
}
}

void HandleKeybd(short blah)
{
	vst_color(ws.handle,1);
	flag=FALSE;
	kreturn=blah;
	if(checkformacs())flag=TRUE;
	
	if(!flag){inputprocess();}
	}

void	HandleMenus(short *msg)
{
int junk;
char temps[2048];
	if(msg[4]==mabout)dotheabout();
	
	
	if(msg[4]==mquit)qt();
	if(msg[4]==mconnect)sortconnection();
	if(msg[4]==mdisconnect)disnnect(wn[cwin].cnn);
	if(msg[4]==fopenwins){
	strcpy(fname,"FRACIRC.WIN");
	if(fselector(temps,"Open a window file..\0",1)==1)loadwins(temps);
	}
	if(msg[4]==mopenset){
	strcpy(fname,"FRACIRC.DAT");
	if(fselector(temps,"Open a setup file..\0",1)==1){
	loadprefs(temps);dowindinfo(cwin);}
	vsf_color(ws.handle,col[CBACK]);
	}
	if(msg[4]==fsavewins){
	strcpy(fname,"FRACIRC.WIN");
	if(fselector(temps,"Save a window file..\0",1)==1)savwins(temps);
	}
	if(msg[4]==msaveset || msg[4]==msaveset2){
	strcpy(fname,"FRACIRC.DAT");
	if(fselector(temps,"Save a setup file..\0",1)==1)savprefs(temps);
	}
	if(msg[4]==mfontset)dofontset();
	if(msg[4]==mpathset)dopathset();
	if(msg[4]==mgenset)opengeneral();
	if(msg[4]==mservset)serveroptions();
	if(msg[4]==muserset)useroptions();
	if(msg[4]==mmacset)domacros();
	if(msg[4]==mdispset)dispoptions();
	if(msg[4]==mfractalk)doftalk();
	if(msg[4]==mcloschan)closchan(wn[cwin].chan);
	if(msg[4]==mselwin1)topwindow(0);
	if(msg[4]==mselwin2)topwindow(1);
	if(msg[4]==mselwin3)topwindow(2);
	if(msg[4]==mselwin4)topwindow(3);
	if(msg[4]==mselwin5)topwindow(4);
	if(msg[4]==mselwin6)topwindow(5);
	if(msg[4]==mlogging){
	junk=0;
	if(logop==1){closelog();junk=1;menu_icheck(mnu,mlogging,0);}
	if(logop==0 && junk==0){openlog();menu_icheck(mnu,mlogging,1);}
	}
	if(msg[4]==mopchan)openchan();
	if(msg[4]==mcycchan){cycchan(FORWARDS);}
	if(msg[4]==mopenwin){openwin(0,0,0,0,2);}
	if(msg[4]==mcloswin && cwin>-1){closewin(cwin);}
	if(msg[4]==mcycwin){cycwin(FORWARDS);}
	if(msg[4]==mautonotify){openautonotify();}
	if(msg[4]==mamacset){openamacs();}
	if(msg[4]==mcolset){setcols();}
	if(msg[4]==minitdcc){dodccsend((char *)NULL);}
	if(msg[4]==minitchat){dodccchatform();}
	menu_tnormal(mnu,msg[3],1);
}
	

int HandleDialoges(void)
	{
	 short fin = TRUE;
	short i=0;
	while(i<128){
	if(dials[i])fin = wdlg_evnt(dials[i], &events);
	if(fin==0){wd_close(dials[i]);return fin;}
	i++;}
	 return fin;
	}


void Handledragdrop(WORD *msg)
{

 BOOLEAN dd_finished=FALSE;
 long handle;
 char pipename[]="U:\\PIPE\\DRAGDROP.xx\0";
 char filename[FMSIZE];
 char buffer[40];
 long *buff2;
 short i;

 pipename[17]=msg[7] >> 8;
 pipename[18]=msg[7] & 0xff;

 handle=Fopen(pipename,2); // read+write
 if (handle < 0)
     return;
     
 handle &= 0xffff; // handle is only actually a word

 buffer[0]=DD_OK;
 Fwrite(handle,1,buffer);
 
 for (i=0; i<32; i++)
     buffer[i]=0;
 strcpy(buffer,"ARGS");  // formats understood. Append 4 letter code to string...
 Fwrite(handle,32,buffer);
 do {
     Fread(handle,2,&i);
     if (!i)
        {
         dd_finished=TRUE;
         break;
        }

     buff2=(long *)Malloc(i);
     if (buff2==NULL)
        {
         form_alert(1,"[1][DD Error:|out of memory][Ok]");
         Fclose(handle);
         return;
        }
     Fread(handle,i,buff2);
    
     switch (buff2[0])
        {
         case 0x41524753: // 'ARGS'
              if (buff2[1] > FMSIZE)
                 {
                  buffer[0]=DD_NAK;
                  Fwrite(handle,1,buffer);
                 }
               else 
                 {
                  buffer[0]=DD_OK;
                  Fwrite(handle,1,buffer);
                  Fread(handle,buff2[1],filename);
              	if(oneofours(msg[3])){
              	topwindow(findwhand(msg[3]));
              	dodccsend(&filename);
              	}
              dd_finished=TRUE;
              }
              break;
         default:
              buffer[0]=DD_EXT;
              Fwrite(handle,1,buffer);
              break;
        }
     Mfree(buff2);
    } while (!dd_finished);
 Fclose(handle);
}
