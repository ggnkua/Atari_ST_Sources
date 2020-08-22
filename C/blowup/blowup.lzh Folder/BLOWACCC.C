/* BLOW UP ACCESSORY for FALCON 
(c) 22.3.93 Georg Acher */
#include <stdio.h>
#include <vdi.h>
#include <stdlib.h>
#include <tos.h>
#include <ext.h>
#include <string.h>
#include "blowacc.h"
#include "blowacc.c"
/* ^ RESOURCEN */

#define min(a,b) ((a)>(b)?(b):(a))
#define SMALLER 0x4000
#define WM_ICONIFY 34
#define WM_UNICONIFY 35
#define WM_ALLICONIFY 36

#define WF_ICONIFY 26
#define WF_UNICONIFY 27
#define WF_UNICONIFYXYWH 28

int planetab[5]={1,2,4,8,16};

int ap_id;
int vid;
int wid,open_f;
static char *windowname="BLOW UP";
char *boot_prg_name="C:\\AUTO\\BLOWBOOT.PRG";
char tmp[20];
OBJECT *tree1,*tree2;
int cx=160,cy=60,cw,ch;
int ret0,ret1,ret2,ret3;
int rets[10];
int saver_flag;
long saver_time;
volatile char *param;
void set_rsc1(int n,int bank);
void get_modes(int,int);
void open_w(void);
void quit_all(void);
void get_conf(void);
void init(void);
void event_handler(void);
void save (void);
/*---------------------------------------------------*/
void quit_all()
{
(void)wind_get(wid,WF_CURRXYWH,&cx,&cy,&cw,&ch);
wind_close(wid);
wind_delete(wid);
open_f=0;
if (!_app) 
	{/* ACCESSORY */ 
	return;
	}
(void)appl_exit();
exit(0);
}
/*---------------------------------------------------*/
void open_w()
{
wid=wind_create(NAME|MOVER|CLOSER|
(_GemParBlk.global[0]>0x400?SMALLER:0),0,0,cw,ch);
if (wid<0) {open_f=0;return;}
if (wind_open(wid,cx,cy,cw,ch)) open_f=1;
wind_set(wid,WF_NAME,(long) windowname);
wind_set(wid,24,1);
}
/*---------------------------------------------------*/
void alert(int nr)
{
form_alert(1,rs_frstr[nr]);
}
/*---------------------------------------------------*/
void get_conf()
{
int n,m;
int da=1;
	get_modes(0,-1);
	if ((ret3!=42))
	{
		for(n=0;n<5;n++)
		{
			strcpy(rs_object[COL2R1+5*n].ob_spec.free_string,"-----");
			strcpy(rs_object[COL2R2+5*n].ob_spec.free_string,"-----");
			
			rs_object[COL2R1+5*n].ob_state|=DISABLED;
			rs_object[COL2R2+5*n].ob_state|=DISABLED;
			rs_object[COL2OFF+5*n].ob_state|=SELECTED;
			
		}
			rs_object[SAVER].ob_state=DISABLED;
			rs_object[SAVE].ob_state=DISABLED;
			da=0;
	}
	else
	{
	for(m=0;m<2;m++)
		for(n=0;n<5;n++)
		{
			get_modes(n+m*8,-1);
			rets[n+5*m]=ret2&7;
			set_rsc1(n,m);
		}
	}

	for(n=0;n<5;n++)
	{
		rs_object[COL2R1+5*n].ob_state|=SELECTED*(rets[n]==0);
		rs_object[COL2R2+5*n].ob_state|=SELECTED*(rets[n+5]==0);
		rs_object[COL2OFF+5*n].ob_state=SELECTED*((rets[n]!=0)&&(rets[n+5]!=0));
	}
	
	if (da)
		{
		get_modes(0,-2); /* -2: Saver abfragen */
		saver_flag = ret0;
		saver_time = ret1<<16+ret2;
		rs_object[SAVER].ob_state=SELECTED*(ret0==1);
		rs_object[SAVER].ob_state|=DISABLED*(saver_time==-1);
		}
}
/*---------------------------------------------------*/
void save()
{
long file1;
int file;
int n,ba,colm,bank;
char *bootprg;
long bootlen;

if (!(bootprg=(char*)malloc(16384)))
	{
	alert(ERROR1);return;
	}
file1=Fopen(boot_prg_name,0);
if (file1<0)
{
	alert(ERROR1);free(bootprg);return;
}
file=(int)file1;
bootlen=Fread(file,16384,bootprg);
Fclose(file);

for (n=0;n<5;n++)
{
ba=(rs_object[COL2R1+5*n].ob_state==SELECTED)+
	2*(rs_object[COL2R2+5*n].ob_state==SELECTED);
	
if (ba==0)
		{ if (*(int*)(bootprg+0x20+n*2*128)!=2)
			*(int*)(bootprg+0x20+n*2*128)=1;
			if (*(int*)(bootprg+0x20+(n+5)*2*128)!=2)
			*(int*)(bootprg+0x20+(n+5)*2*128)=1;
		}
else
	if (ba==1)
		{
		*(int*)(bootprg+0x20+n*2*128)=0;
		*(char*)(bootprg+0x20+10*2*128+n)=0;
		if (*(int*)(bootprg+0x20+(n+5)*2*128)!=2)
			*(int*)(bootprg+0x20+(n+5)*2*128)=1;
		}
	else
		{
		*(int*)(bootprg+0x20+(n+5)*2*128)=0;
		*(char*)(bootprg+0x20+10*2*128+n)=1;
		if (*(int*)(bootprg+0x20+(n)*2*128)!=2)
			*(int*)(bootprg+0x20+(n)*2*128)=1;
		}
}
	for(n=0;(n<5)&&(_GemParBlk.global[10]!=planetab[n]);n++); /*nplanes */

	colm=n;
	bank=(rs_object[COL2R1+5*colm].ob_state==SELECTED?
		0:(rs_object[COL2R2+5*colm].ob_state==SELECTED?1:-1));
		
	if (bank!=-1)
	{
		*(int*)(bootprg+0x20+64+256*colm+bank*5*256+0x2a)=(rs_object[SAVER].ob_state&SELECTED?0x100:0);
		/*if (*(long*)(bootprg+0x20+64+256*colm+bank*5*256+0x26)<=(10L*200L))
			*(long*)(bootprg+0x20+64+256*colm+bank*5*256+0x26)=300L*200L;*/
	}
file1=Fcreate(boot_prg_name,0);
if (file1<0)
	{
	alert(ERROR1);free(bootprg);return;
	}
	file=(int)file1;
if (Fwrite(file,bootlen,bootprg)!=bootlen)
	{
	alert(ERROR1);
	}
	
Fclose(file);
free(bootprg);
 }
/*---------------------------------------------------*/
void set_rsc1(int n,int bank)
{
char tmp1[20],tmp2[20];
if (ret2&2)
	{
	rs_object[COL2R1+5*n+bank].ob_state=DISABLED;
	strcpy(rs_object[COL2R1+5*n+bank].ob_spec.free_string,"---");
	if ((bank==1)&&(rs_object[COL2R1+5*n].ob_state&DISABLED))
			rs_object[COL2OFF+5*n].ob_state|=SELECTED;
	}
else
	{
	rs_object[COL2R1+5*n+bank].ob_state&=~(DISABLED|SELECTED);
	(void)itoa(ret0+1,tmp1,10);
	(void)itoa(ret1+1,tmp2,10);
	strcat(tmp1,"*");
	strcat(tmp1,tmp2);
	strcpy(rs_object[COL2R1+5*n+bank].ob_spec.free_string,tmp1);
	}
}
/*---------------------------------------------------*/
void init()
{
	int n,xs,ys; 
	int bootdev;
	long old_stack;

	ap_id=appl_init();
	if (!_app)
		(void)menu_register(ap_id,"  BlowUP030");
	if (ap_id==-1) 
	{
		puts("ERROR: ap_id=-1 !");
		exit(1);
	}
	for (n=0;n<rs_numobs;n++)
		/*rsrc_obfix(rs_object,n);*/
	{
		rs_object[n].ob_x=(rs_object[n].ob_x&255)*8+
					(rs_object[n].ob_x>>8);
		rs_object[n].ob_y=(rs_object[n].ob_y&255)*16+
					(rs_object[n].ob_y>>8);
		rs_object[n].ob_width=(rs_object[n].ob_width&255)*8+
					(rs_object[n].ob_width>>8);
		rs_object[n].ob_height=(rs_object[n].ob_height&255)*16+
					(rs_object[n].ob_height>>8);
		}			
		
	wind_calc(WC_BORDER,NAME|MOVER|CLOSER,0,0,rs_object[TREE1].ob_width,rs_object[TREE1].ob_height,
		&xs,&ys,&cw,&ch);
	open_f=0;
	if (_app)
	{
		open_w();
		if (!open_f)
			quit_all();
	}
	get_conf(); 
	
	if (mon_type()==0) rs_object[SAVER].ob_state|=DISABLED;
	
	(void)graf_mouse(ARROW,0);
 
	old_stack=Super(0L);
	bootdev=*(int*)(0x446);
	boot_prg_name[0]=(char)(bootdev+65);
	(void)Super((void*)old_stack);
}
/*---------------------------------------------------*/
int intersect(int *x1,int *x2,int *xr) 
{
	if (((x1[0]>=x2[0])&&(x1[1]>=x2[1]))||
		((x2[0]>=x1[0])&&(x2[1]>=x1[1])))
	{
		if (x1[0]>x2[0])
		{
			xr[0]=x1[0];
			xr[2]=min(x2[0]+x2[2]-x1[0],x1[2]);
		}
	 	else 
	 	{
	 		xr[0]=x2[0];
	 		xr[2]=min(x1[0]+x1[2]-x2[0],x2[2]);
	 	}
	
		if (x1[1]>x2[1]) 
		{
			xr[1]=x1[1];
			xr[3]=min(x2[1]+x2[3]-x1[1],x1[3]);
		}
	 	else
	 	{
	 		xr[1]=x2[1];
	 		xr[3]=min(x1[1]+x1[3]-x2[1],x2[3]);
	 	} 
		/*printf(" %i %i %i %i:%i %i %i %i->%i %i %i %i  \n",
			x1[0],x1[1],x1[2],x1[3],x2[0],x2[1],x2[2],x2[3],
			xr[0],xr[1],xr[2],xr[3]);*/
		 return 1;
    }
	return 0;
}
/*---------------------------------------------------*/
void redraw(int obn)
{
	int x[4],xs[4], /* xw[4], xy[4],*/ xc[4];

	(void)wind_get(wid,WF_WORKXYWH,&xs[0],&xs[1],&xs[2],&xs[3]);
	(void)wind_get(wid,WF_FIRSTXYWH,&x[0],&x[1],&x[2],&x[3]);
	(void)wind_get(wid,WF_CURRXYWH,&xc[0],&xc[1],&xc[2],&xc[3]);
	rs_object[TREE1].ob_x=xs[0];
	rs_object[TREE1].ob_y=xs[1];

/*	objc_offset(rs_object,obn,&xw[0],&xw[1]);
	xw[2]=rs_object[obn].ob_width;
	xw[3]=rs_object[obn].ob_height; */
	/* Warum???????????? Funktioniert nicht mit 3D-Objs (da
		wird zu wenig neu gezeichnet, weil die Objekte gr”žer sind,
		als ob_width und ob_height angeben...!
		
		In Wirklichkeit muž man mit dem Redraw-Rechteck clippen,
		welches man mit der Redraw-Message bekommt!
		
		Bei der komischen (aber effizienten!) Methode, die Du
		verwendest (nicht Koordinaten, sonder Objekte werden
		neu gezeichnet, sehr interessant!) lass ich am besten das
		intersect-ionieren weg. objc_draw selber weiž schliesslich
		am besten, wie grož seine Objekte sind, oder?!?
	*/
	
	wind_update(BEG_UPDATE);
	while((x[2]!=0)||(x[3]!=0))
	{
/*		if ((intersect(xw,x,xs))) */
		objc_draw(rs_object,obn,42,x[0],x[1],x[2],x[3]);
		(void)wind_get(wid,WF_NEXTXYWH,&x[0],&x[1],&x[2],&x[3]);
	}
	wind_update(END_UPDATE);
}
/*---------------------------------------------------*/
void radio(int sel,int from, int to)
{
	int n;
	for(n=from;n<=to;n++)
	{
		if (n!=sel) 
		{
			if (rs_object[n].ob_state&SELECTED) 
			{
				rs_object[n].ob_state&=~SELECTED;
			}
			else
				rs_object[n].ob_state&=~SELECTED;
		}
		else 
		{
			rs_object[n].ob_state|=SELECTED;
		}		
	}
}
/*---------------------------------------------------*/
void event_handler()
{
	int dummy,ev_bkstate,ev_bkreturn,ev_bbutton,ev_breturn,ev_bmx,ev_bmy;
	int mbuff[8]/*,xs[4]*/;
	int mwhich,obn;
	int col,ba;

	while(1)
	{
		mwhich=evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG,1,1,
			1,0,0,
			0,0,0,
			0,0,0,0,
			0,mbuff,0,
			0,&ev_bmx,&ev_bmy,
			&ev_bbutton,&ev_bkstate,
			&ev_bkreturn,&ev_breturn);
		
		if (mwhich&MU_KEYBD);
		
		
		if (mwhich&MU_BUTTON)
		{
			obn=objc_find(rs_object,0,10,ev_bmx,ev_bmy);
			if ((obn==SAVE)&!(rs_object[SAVE].ob_state&DISABLED))

			{
				rs_object[SAVE].ob_state=SELECTED;
				redraw(SAVE);
				save();
				rs_object[SAVE].ob_state=0;
				redraw(SAVE);
			}
			else
			if ((obn==SAVER)&!(rs_object[SAVER].ob_state&DISABLED))
			{
				saver_flag=!saver_flag;
				rs_object[SAVER].ob_state=SELECTED*saver_flag;
				redraw(SAVER);
				get_modes(saver_flag,-3); /* Saver setzten */
			}
			else
			{
				col=(obn-COL2R1)/5;
				ba=obn-5*col-COL2R1;
				if ((col>=0)&&(col<5)&&(ba>=0)&&(ba<=2)&&
					!(rs_object[COL2R1+5*col+ba].ob_state&DISABLED))
				{
					radio(COL2R1+5*col+ba,COL2R1+5*col,COL2R1+5*col+2);
					if (ba==2)
					{
						get_modes(col,0);
					}
					else  
					{
						get_modes(col,1+ba);
					}
					redraw(COL2BOX+5*col);
				}
			}
			(void)evnt_button(1,1,0,&dummy,&dummy,&dummy,&dummy);	
		}
		
		if (mwhich&MU_MESAG)
		{
			if (mbuff[0]==WM_REDRAW)
			{	
				get_conf();
				redraw(TREE1);
			}
			if (mbuff[0]==WM_MOVED)
			{	
				wind_set(wid,WF_CURRXYWH,
		 			mbuff[4],mbuff[5],mbuff[6],mbuff[7]);
		 		(void)wind_get(wid,WF_WORKXYWH,
					&rs_object[TREE1].ob_x,&rs_object[TREE1].ob_y,
					&dummy,&dummy);
			}
			if ((mbuff[0]==WM_TOPPED)||(mbuff[0]==WM_NEWTOP))
				wind_set(wid,WF_TOP);
			if (mbuff[0]==WM_CLOSED)
				quit_all();
			if ((mbuff[0]==AC_OPEN)&&(!open_f))
			{
				open_w();
			}
			if ((mbuff[0]==AC_CLOSE)&(open_f))
			{
				open_f=0;
			}
			if ((mbuff[0]==WM_ICONIFY)||(mbuff[0]==WM_ALLICONIFY))
			{
				wind_set(wid,WF_ICONIFY,mbuff[4],mbuff[5],82,32+24);
			}
			if ((mbuff[0]==WM_UNICONIFY))
			{
				wind_set(wid,WF_UNICONIFY,mbuff[4],mbuff[5],mbuff[6],mbuff[7]);
			}
		}
	}
}
/*---------------------------------------------------*/
int main()
{	/* Wow! SO sollte ein main aussehen! Note 1+ mit Stern! */
	init();
	event_handler();
}
