/* Screenmanager fÅr BLOWCONF */
/* Abnabelung von BlowCONF.C am 
	28.10.93 vorgenommen durch den Meister persînlich */

#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <math.h>
#include <string.h>
#include "blowconf.h" 

#define min(a,b) (a>b?b:a)
#define max(a,b) (b>a?b:a)

int alert(int);

long old_hardcopy;

extern xres,yres;
extern vdi_x,vdi_y;
extern char tmp[20];
extern OBJECT *tree1,*tree2,*tree3;
extern int cx,cy,cw,ch;
extern int mcx,mcy,mcw,mch;
extern int last_slider;
#define slider_count 10
extern int slider_tab[slider_count];
extern int last_x,last_y;
extern int ap_id;
extern int w_id, handle;
/*---------------------------------------------------*/
int alert(int nr)
{
char **tree_alert;
(void)rsrc_gaddr(R_FRSTR,nr,&tree_alert);
return(form_alert(1,*tree_alert));
}
/*---------------------------------------------------*/
void show_dialog(int nr, int start,int how,int center_ob)
{
OBJECT *info_ob,*info_ob1;
int x=0,y=0,w,h;
int x1,y1,w1,h1;
rsrc_gaddr(R_TREE,nr,&info_ob);
rsrc_gaddr(R_TREE,center_ob,&info_ob1);
if (how) 
	(void)wind_get(0,WF_WORKXYWH,&info_ob[0].ob_x,&info_ob[0].ob_y,&w,&h);
(void)wind_get(0,WF_WORKXYWH,&x1,&y1,&w1,&h1);
if (-1==center_ob)
	{
	x=info_ob[0].ob_x;
	y=info_ob[0].ob_y;
	w=info_ob[0].ob_width;
	h=info_ob[0].ob_height;
	mcx=x;mcy=y;mcw=w;mch=h;
	cx=x;cy=y;cw=w;ch=h;
	}
else
if (-2==center_ob)	
	{
	x=mcx;w=mcw;
	cx=mcx;cy=mcy;cw=mcw;ch=mch;
	cy=max(mcy,y1);
	if (mcy<y1) ch=ch-y1+mcy;
	y=cy;h=ch;
	}
else		/* Zentrieren im Hauptfenster mit clipping*/
	{
	info_ob[0].ob_x=info_ob1[0].ob_x+(info_ob1[0].ob_width/2)-(info_ob[0].ob_width/2);
	info_ob[0].ob_y=info_ob1[0].ob_y+(info_ob1[0].ob_height/2)-(info_ob[0].ob_height/2);

	x=info_ob[0].ob_x;
	y=max(y1,info_ob[0].ob_y);
	w=info_ob[0].ob_width;
	if (info_ob[0].ob_y<y1)
		h=info_ob[0].ob_height+info_ob[0].ob_y-y1;
	else
		h=info_ob[0].ob_height;	
	cx=x;cy=y;cw=w;ch=h;
	}

if (w_id==-1)
	{
	w_id=wind_create(0,x,y,w,h);
	wind_open(w_id,x,y,w,h);
	}
/*info_ob[0].ob_x=x;info_ob[0].ob_y=y;*/
objc_draw(info_ob,start,100,x,y,w,h);

}
/*--------------------------------------------------*/
void find_slider(int nr,int* last_slider)
{
int n;

	for (n=0;n<slider_count;n++)
	{
		if ((nr>=slider_tab[n])&&(nr<=slider_tab[n]+3))
		{
			*last_slider=n;
			break;
		}
	}
}
/*--------------------------------------------------*/
#define FMD_BACKWARD	-1
#define FMD_FORWARD		-2
#define FMD_DEFLT		-3
int find_object( OBJECT *tree, int start_object, int which )
{
	int	object, flag, theflag, increment;
	
	object=0;
	flag=EDITABLE;
	increment=1;
	
	switch(which)
	{
		case FMD_BACKWARD:
			increment=-1;
		case FMD_FORWARD:
			object = start_object + increment;
			break;
		case FMD_DEFLT:
			flag=DEFAULT;
			break;
	}
	
	while (object>=0)
	{
		theflag = tree[object].ob_flags;
		
		if (theflag & flag)
			return (object);
		if (theflag & LASTOB)
			object = -1;
		else
			object += increment;
	}
	
	return start_object;
}
/*--------------------------------------------------*/
int ini_field( OBJECT *tree, int start_field )
{
	if (start_field == 0)
		start_field = find_object( tree, 0, FMD_FORWARD );
	return start_field;
}
/*--------------------------------------------------*/
 int do_old_dialog(int nr,int start)
{OBJECT *info_ob;
int s_ob;
rsrc_gaddr(R_TREE,nr,&info_ob);
s_ob=form_do(info_ob,start)&32767;
if (!(info_ob[s_ob].ob_flags&RBUTTON))
		info_ob[s_ob].ob_state=info_ob[s_ob].ob_state&0xfffe;
return s_ob;
}
/*--------------------------------------------------*/
void reset_key_buffer()
{
int evnt=MU_KEYBD,dummy,n;
for(n=0; ((evnt&MU_KEYBD)!=0)&&(n<10);n++)
		evnt = evnt_multi( MU_KEYBD|MU_TIMER, 2, 1, 1,
		0, 0,
		0, 0, 
		0, 0,
		0, 0,
		0, 0,
		0L, 50,
		0, &dummy,
		&dummy, &dummy,
		&dummy, &dummy,
		&dummy );
}
/*--------------------------------------------------*/
void mtet_main( void );
void cheat_mode( void )
{
	mtet_main();
}
/*--------------------------------------------------*/
int do_dialog( int nr, int start )
{
	OBJECT *info_ob;
	int evnt, cont, button, x, y, key, dummy, n_ob, e_ob;
	static int ed_idx=0;
	int mesag[8];
	void *old_stack;
	volatile int* paddle=(volatile int*)0xff9210;
	int pa;
	int px[4];
	char cheatstring[64]={/*67,10,93,75,68,94,10,94,69,10,*/90,70,75,83};
	int cheatpos=0;
			
	rsrc_gaddr( R_TREE,nr,&info_ob);

	n_ob=ini_field( info_ob, start );
	e_ob=0;

	cont=1;
	while (cont!=0) {
#if DEMO_VERSION
		if (pl_idx!=2) {exit(0);}
#endif
	/*
		old_stack=Super(0L);
		pa=*paddle;
		printf("\033H%i  ",*(paddle+2)&255);
	
		(void)Super((long)old_stack);
	*/
		if ((n_ob!=0)&&(e_ob!=n_ob))
		{
			e_ob = n_ob;
			n_ob = 0;
			objc_edit( info_ob, e_ob, 0, &ed_idx, ED_INIT );
		}
	
		evnt = evnt_multi( MU_KEYBD|MU_BUTTON|MU_MESAG/*|MU_TIMER*/, 2, 1, 1,
			0, 0,
			0, 0, 
			0, 0,
			0, 0,
			0, 0,
			mesag, 50,
			0, &x,
			&y, &dummy,
			&dummy, &key,
			&button );
		last_x=x;
		last_y=y;
		if ((evnt&MU_KEYBD)!=0)
		{
			cont=form_keybd(info_ob,e_ob,n_ob,key,&n_ob,&key);
			if (nr==TREE1)
			{
				if ((key&255)=='+') {
					n_ob=slider_tab[last_slider]+3;
					cont=0;
					reset_key_buffer();
				}
				else if ((key&255)=='-') {
					n_ob=slider_tab[last_slider];
					cont=0;
					reset_key_buffer();
				}
				else if ((key&255)=='q' || (key&255)=='Q' || 
					(key&255)==0x11) {
					n_ob=QUIT;
					cont = form_button( info_ob, n_ob, 1, &n_ob );
				}
				else if ((key>>8)==97) {
					n_ob=UNDO;
					cont = form_button( info_ob, n_ob, 1, &n_ob );
				}
				else if (((key&255)^42)==cheatstring[cheatpos]) {
					cheatpos+=1;
	/*				printf("Zack %i\n",cheatpos);*/
					if (4==cheatpos) {
						cheat_mode();
						cheatpos=0;
					show_dialog(TREE1,0,1,-1);
					n_ob=UNDO;
					cont = form_button( info_ob, n_ob, 1, &n_ob );
					}
				}
				else
					cheatpos=0;
			}
			if (key)
				objc_edit(info_ob,e_ob,key,&ed_idx,ED_CHAR);
		}
			
		if ((evnt&MU_BUTTON)!=0)	/* Maustaste gedrÅckt */
		{
			n_ob = objc_find( info_ob, start, 42, x, y );
			
			(void)find_slider(n_ob,&last_slider);
			
			if (n_ob!=-1)
				{
			
				cont = form_button( info_ob, n_ob, button, &n_ob );
				}
		}
		
	/*	if ((!cont&&((n_ob!=-1)&&(n_ob!=VSRES)))&&ed_flag) */
		if (!cont || ((n_ob != 0) &&
			(n_ob != e_ob)))
				objc_edit(info_ob,e_ob,0,&ed_idx, ED_END);
	}

	if (!(info_ob[n_ob&32767].ob_flags&RBUTTON))
		info_ob[n_ob&32767].ob_state=info_ob[n_ob&32767].ob_state&0xfffe;
	return n_ob&32767;
}
/*---------------------------------------------------*/
void clean_up(void)
{
	wind_close(w_id);
	wind_delete(w_id);
}
/*---------------------------------------------------*/
void move_slider(OBJECT *tree,
			int parent,int child,int *xl,int *yl)
{
int xs1,ys1,xr,yr;
graf_mouse(FLAT_HAND,0);
objc_offset(tree,parent,&xs1,&ys1);
(void)graf_dragbox(
	tree[child].ob_width,tree[child].ob_height,
	tree1[child].ob_x+xs1,tree[child].ob_y+ys1,
	xs1,ys1,tree[parent].ob_width,tree[parent].ob_height,&xr,&yr);
	xr=xr-xs1;yr=yr-ys1;
	*xl=xr;*yl=yr;
	graf_mouse(ARROW,0);
}	
/*---------------------------------------------------*/
int handle_slider(int pd_ob, OBJECT *tree,
		int parent, int child, int xplus, int xminus,
		int yplus,int yminus, int xss_add,int xms_add,
		int yss_add, int yms_add, int flag,int *xl, int *yl)
{
int retval=0;
if (flag&1)
{
	if	(pd_ob==xplus) 
	{ 
		*xl+=xss_add;
		retval= 1;
	}
		
	if	(pd_ob==xminus) 
	{
		 *xl-=xss_add;
		if ((*xl)<0)
			*xl=0;
	retval= 1;
	}
}
if (pd_ob==parent)
	{
	int chilx,chily;
	
	objc_offset( tree, child, &chilx, &chily );
	if (chilx>last_x) /* Slider nach links */
	{
		*xl-=xms_add;
		if ((*xl)<0)
			*xl=0;
		retval= 1;
	}
	else
	{
		*xl+=xms_add;
		retval= 1;
	}
	if (chily<last_y) /* Slider nach unten */
	{
		*yl+=yms_add;
		retval= 1;	
	}
	else
	{
		*yl-=yms_add;
		retval= 1;
	}

	}

if (flag&2)
{if	(pd_ob==yplus) { *yl+=yss_add;retval= 1;}
if	(pd_ob==yminus) { *yl-=yss_add;retval= 1;}}
#if !DEMO_VERSION
if (pd_ob==child)
{move_slider(tree,parent,child,xl,yl);retval= 1;}
#endif
return retval;
}	
/*---------------------------------------------------*/	
int handle_resize(int pd_ob,OBJECT *tree,
	int parent,int child,
	int maxw, int maxh, int minw, int minh,int  *ww,int *hh)
{
int xs,ys, wr,hr;
if (pd_ob!=child) return 0;
objc_offset(tree,parent,&xs,&ys);
(void)graf_mouse(POINT_HAND,0);
(void)graf_rubberbox(xs,ys,minw,minh,&wr,&hr);
(void)graf_mouse(ARROW,0);
if (wr>maxw) wr=maxw;
if (hr>maxh) hr=maxh;
*ww=wr;*hh=hr;
return 1;
}
/*---------------------------------------------------*/
void move_box(OBJECT *tree,
	int parent,int ob_x,int ob_y,int ob_w,int ob_h)
{
	int xz,yz;
	int minx,miny;
	
	(void)wind_get(0,WF_WORKXYWH,&minx,&miny,&xz,&xz);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	graf_mouse(FLAT_HAND,0L);
	graf_dragbox(ob_w,ob_h,ob_x,ob_y,-320,-240,vdi_x+640,vdi_y+480,&xz,&yz);
	graf_mouse(ARROW,0L);
	if ((xz==mcx)&&(yz==mcy)) {wind_update(BEG_UPDATE);wind_update(BEG_MCTRL);return;}
	form_dial(FMD_FINISH,ob_x,ob_y,ob_w,ob_h,ob_x,ob_y,ob_w,ob_h);

/*	printf("wc:%i \n",wind_close(w_id));
*/	
	mcx=tree[parent].ob_x=xz;
	mcy=tree[parent].ob_y=yz;
	cx=max(xz,0);
	cw=ob_w+min(0,xz);
	

	cy=max(yz,miny);
	if (yz<miny) ch=ob_h-miny+yz;
		else
		ch=ob_h;
		
	wind_set(w_id,WF_CURRXYWH,cx,cy,cw,ch);
/*	wind_set(w_id,WF_CURRXYWH,cx,cy,cw,ch);*/

/*	printf("\033H%i %i %i %i %i\n",w_id,cx,cy,cw,ch);	
	wind_open(w_id,cx,cy,cw,ch);
*/

	evnt_timer(50,0);
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	form_dial(FMD_START,cx,cy,cw,ch,cx,cy,cw,ch);
	objc_draw(tree,parent,100,cx,cy,cw,ch);
}