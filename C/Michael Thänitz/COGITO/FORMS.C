#include <portab.h>
#include <stdio.h>
#include <aes.h>
#include <tos.h>

#define Objc_edit(a,b,c,d,e,f) objc_edit(a,b,c,f,e)

#define FMD_FORWARD  1
#define FMD_BACKWARD 2
#define FMD_DEFLT    0

#define BACKDROP			0x2000  /* Fensterelement */
#define WM_BACKDROPPED	31		/* Message vom Eventhandler */
#define WF_BACKDROP		100	  /* Fenster setzen */

#define UNDO  0x6100
#define HELP  0x6200

int wi_handle=-1;

typedef struct
{
	WORD packer, ordner, alles, taste, merken, pein, paus, pinhalt, x, y;
	char source[PATH_MAX], dest[PATH_MAX], pattern[13];
}SHELL;
extern SHELL shell;

extern OBJECT *packmenu;

/* ------------------------------------------------------------------------- */
/* ----- VSCR von BIGSCREEN 2 ---------------------------------------------- */
/* ------------------------------------------------------------------------- */

typedef struct
{
	LONG cookie;	/* muž `VSCR' sein */
	LONG product;  /* Analog zur XBRA-Kennung */
	WORD version;  /* Version des VSCR-Protokolls, zun„chst 0x100 */
	WORD x,y,w,h;  /* Sichtbarer Ausschnitt des Bildschirms */
} INFOVSCR;

/* ------------------------------------------------------------------------- */

SYSHDR		*sys_header;

/* ----- Cookie Jar -------------------------------------------------------- */

typedef struct
{
	long	id,
		*ptr;
} COOKJAR;

/* ------------------------------------------------------------------------- */
/* ----- get_cookie -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

long *get_cookie(long cookie)
{
	long	sav;
	COOKJAR	*cookiejar;
	int	i = 0;

	sav = Super((void *)1L);
	if(sav == 0L)
		sav = Super(0L);
	cookiejar = *((COOKJAR **)0x05a0l);
	sys_header = *((SYSHDR **)0x04f2L);	/* ... wenn wir schonmal
							super drauf sind */
	if(sav != -1L)
		Super((void *)sav);
	if(cookiejar)
	{
		while(cookiejar[i].id)
		{
			if(cookiejar[i].id == cookie)
				return(cookiejar[i].ptr);
			i++;
		}
	}
	return(0l);
}

static int rc_intersect(register int p1[], register int p2[])
{
  register int tw = min(p1[0] + p1[2], p2[0] + p2[2]);
  register int th = min(p1[1] + p1[3], p2[1] + p2[3]);
  register int tx = max(p1[0], p2[0]);
  register int ty = max(p1[1], p2[1]);

  p2[0] = tx;
  p2[1] = ty;
  p2[2] = tw - tx;
  p2[3] = th - ty;

  return ((tw > tx) && (th > ty));
}
/*------------------------------------------------------------------------*/
/*																								*/
/*------------------------------------------------------------------------*/
void fwind_redraw(OBJECT *tree, int wh, int pxyarray[])
{
	int full[4],area[4],array[4],ret;

	wind_update(BEG_UPDATE);
	wind_get( 0, WF_WORKXYWH,  &full[0], &full[1], &full[2], &full[3]);
	wind_get(wh, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
	while( area[2] && area[3] )
	{
		if(rc_intersect(full,area))
		{
			if(rc_intersect(pxyarray,area))
			{
				objc_draw(tree,ROOT,MAX_DEPTH,area[0],area[1],area[2],area[3]);
			}
		}
		wind_get(wh, WF_NEXTXYWH,&area[0],&area[1],&area[2],&area[3]);
	}
	wind_update(END_UPDATE);
}

static void fwind_move(OBJECT *tree, int wh, int buf[])
{
	int xwork,ywork,wwork,hwork;

	wind_set(wh,WF_CURRXYWH,buf[0],buf[1],buf[2],buf[3]);
	wind_get(wh,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	shell.x=tree->ob_x=xwork;
	shell.y=tree->ob_y=ywork;
}
char *strstr(char *, char *);

static int find_button(OBJECT *tree, char *string)
{
	register int i;
	for(i=ROOT+1; !(tree[i].ob_flags & LASTOB); i++)
	{
		if(!(tree[i].ob_flags&HIDETREE) && !(tree[i].ob_state&DISABLED))
		{
  			if(tree[i].ob_type == G_BOXTEXT)
  	   		if(strstr(tree[i].ob_spec.tedinfo->te_ptext,string))
   	   		return(i);
		}
	}
	if(!(tree[i].ob_flags&HIDETREE) && !(tree[i].ob_state&DISABLED))
	{
		if(tree[i].ob_type == G_BOXTEXT)
  			if(strstr(tree[i].ob_spec.tedinfo->te_ptext,string))
     			return(i);
	}
	return(-1);
}
/*------------------------------------------------------------------------*/
/*                                                                        */
/*------------------------------------------------------------------------*/
static WORD find_obj(OBJECT *fm_tree, WORD fm_start_obj, WORD fm_which)
{
   WORD fm_obj,fm_flag,fm_theflag,fm_inc;
   fm_obj=0;
   fm_flag=EDITABLE;
   fm_inc=1;
   switch(fm_which)
   {
      case FMD_BACKWARD: fm_inc=-1;
      case FMD_FORWARD:  fm_obj=fm_start_obj+fm_inc;break;
      case FMD_DEFLT:    fm_flag=2;
         break;
   }
   while(fm_obj>=0)
   {
      fm_theflag=fm_tree[fm_obj].ob_flags;
      if(fm_theflag&fm_flag) 
         return(fm_obj);
      if(fm_theflag&LASTOB) 
         fm_obj=-1;
      else
         fm_obj+=fm_inc;
   }
   return(fm_start_obj);
}
/*------------------------------------------------------------------------*/
/*                                                                        */
/*------------------------------------------------------------------------*/
static WORD fm_inifld(OBJECT *fm_tree, WORD fm_start_fld)
{
   if(fm_start_fld==0)
      fm_start_fld=find_obj(fm_tree,0,FMD_FORWARD);
   return(fm_start_fld);
}
/*------------------------------------------------------------------------*/
/*                                                                        */
/*------------------------------------------------------------------------*/
WORD form_exdo(OBJECT *fm_tree, WORD fm_start_fld, WORD *key, WORD *cakey)
{
   WORD fm_edit_obj,fm_next_obj,fm_which,fm_cont,fm_idx;
   WORD fm_flags,fm_mx,fm_my,fm_mb,fm_ks,fm_kr,fm_kr2,fm_br;
   WORD ret,fm_msg[8];

   fm_flags=MU_KEYBD|MU_BUTTON|MU_MESAG;

   fm_next_obj=fm_inifld(fm_tree,fm_start_fld);
   fm_edit_obj=0;
   fm_cont=TRUE;
   while(fm_cont)
   {
      if((fm_next_obj!=0)&&(fm_edit_obj!=fm_next_obj))
      {
         fm_edit_obj=fm_next_obj;
         fm_next_obj=0;
         Objc_edit(fm_tree,fm_edit_obj,0,fm_idx,ED_INIT,&fm_idx);
      }
      fm_which=evnt_multi(fm_flags,0x02,0x01,0x01,0,0,0,0,
                          0,0,0,0,0,0,fm_msg,0,0,
                          &fm_mx, &fm_my, &fm_mb, &fm_ks, &fm_kr, &fm_br);

      AVProcessMsg(fm_msg);
/*
		wind_update(BEG_UPDATE);
*/
      if(fm_which&MU_MESAG)
      {
			if(fm_msg[0] != MN_SELECTED)
			{
				switch(fm_msg[0])
				{
               case AC_OPEN:
					case WM_TOPPED:
						wind_set(wi_handle,WF_TOP,0,0,0,0);
                  break;
               case AC_CLOSE:
                  wi_handle=-1;
                  fm_next_obj = 0;/*find_obj(fm_tree,0,FMD_DEFLT)-1;*/
                  fm_cont = FALSE;
                  break;
               case WM_CLOSED:
						fm_next_obj = 0;
						fm_cont = FALSE;
                  break;
					case WM_BACKDROPPED:
						break;
					case WM_REDRAW:
						Objc_edit(fm_tree,fm_edit_obj,0,fm_idx,ED_END,&fm_idx);
						fwind_redraw(fm_tree,fm_msg[3],&fm_msg[4]);
						Objc_edit(fm_tree,fm_edit_obj,0,fm_idx,ED_INIT,&fm_idx);
						break;
					case WM_MOVED:
						Objc_edit(fm_tree,fm_edit_obj,0,fm_idx,ED_END,&fm_idx);
						fwind_move(fm_tree,fm_msg[3],&fm_msg[4]);
						Objc_edit(fm_tree,fm_edit_obj,0,fm_idx,ED_INIT,&fm_idx);
						break;
				}
			}
			else
			   if((fm_cont = hndl_menu(packmenu,fm_msg))==FALSE)
               fm_next_obj = 0;
      }
      if(fm_which&MU_KEYBD)
      {
				switch(fm_kr)
				{
					case HELP:
						fm_next_obj=find_button(fm_tree,"Info");
						goto WEITER;
					case UNDO:
						fm_next_obj=find_button(fm_tree,"Abbruch");
WEITER:
						switch(fm_next_obj)
						{
							case ROOT:
								break;
							case (-1):
								Bconout(2,7);
								fm_next_obj=0;
								break;
							default:
								fm_cont=form_button(fm_tree,fm_next_obj,fm_br,&fm_next_obj);
								break;
						}
						break;
					default:
						MapKey(&fm_ks, &fm_kr);
					   if(!menu_ikey(packmenu,fm_ks,fm_kr,&ret,&ret))
					   {
							fm_cont=form_keybd(fm_tree, fm_edit_obj, fm_next_obj, fm_kr, &fm_next_obj, &fm_kr2);
							fm_kr=fm_kr2;
				         if(fm_kr)
				            Objc_edit(fm_tree,fm_edit_obj,fm_kr,fm_idx,ED_CHAR,&fm_idx);
			         }
					   break;
				}
      }
      if(fm_which&MU_BUTTON)
      {
         fm_next_obj=objc_find(fm_tree,ROOT,MAX_DEPTH,fm_mx,fm_my);
         if(fm_next_obj==-1)
            fm_next_obj=0;
         else
            fm_cont=form_button(fm_tree,fm_next_obj,fm_br,&fm_next_obj);
      }
      if((!fm_cont)||((fm_next_obj!=0)&&(fm_next_obj!=fm_edit_obj)))
         Objc_edit(fm_tree,fm_edit_obj,0,fm_idx,ED_END,&fm_idx);
/*
		wind_update(END_UPDATE);
*/
   }
   return(fm_next_obj);
}

void form_open(OBJECT *tree,int modus)
{
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	form_dial(FMD_START,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);
	if(modus)
		form_dial(FMD_GROW,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);
	objc_draw(tree,ROOT,MAX_DEPTH,tree->ob_x-3,tree->ob_y-3,
											tree->ob_width+6,tree->ob_height+6);
}

int form_close(OBJECT *tree, int exit_obj,int modus)
{
	if(modus)
		form_dial(FMD_SHRINK,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);
	form_dial(FMD_FINISH,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);
	if(exit_obj > -1)
		tree[exit_obj].ob_state &= ~SELECTED;
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	return(exit_obj);
}

int form_hndl(OBJECT *tree, int start)
{
	form_open(tree,start);
	return(form_close(tree,form_do(tree,0),0));
}

int form_exopen(OBJECT *tree, int modus)
{
	static char infostr[31];
	int x,y,w,h,xdesk,ydesk,wdesk,hdesk;
	INFOVSCR *infovscr;

	if((infovscr=(INFOVSCR *)get_cookie('VSCR'))!=NULL) /* BigScreen 2 */
	{
		if(infovscr->cookie=='VSCR')
		{
			tree->ob_x=infovscr->x+(infovscr->w-tree->ob_width)/2;
			tree->ob_y=infovscr->y+(infovscr->h-tree->ob_height)/2+ydesk;
		}
	}
	wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
	if((wi_handle=wind_create(CLOSER|NAME/*|INFO*/|MOVER,xdesk,ydesk,wdesk,hdesk))>0)
	{
      if((shell.x > 0) && (shell.y > 0))
      {
        tree->ob_x=x=shell.x;
        tree->ob_y=y=shell.y;
      }
		wind_calc(WC_BORDER,CLOSER|NAME/*|INFO*/|MOVER,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,&x,&y,&w,&h);
      wind_set(wi_handle,WF_NAME," Cogito ");
/*
		__DATE__[3]=__DATE__[6]=0;
		sprintf(infostr,
			" V.1.0 %s. %s %s",
			&__DATE__[4],&__DATE__[0],&__DATE__[7]);

      wind_set(wi_handle,WF_INFO,infostr/*" Version 1.0 vom __DATE__"*/);
*/
		wind_open(wi_handle,x,y,w,h);
	}
	return(wi_handle);
}

int form_exclose(OBJECT *tree, int exit_obj, int modus)
{
	if(wi_handle>0)
	{
		wind_close(wi_handle);
		wind_delete(wi_handle);
		if(exit_obj > -1)
			tree[exit_obj].ob_state &= ~SELECTED;
		wi_handle=-1;
	}
	return(exit_obj);
}

void pop_excenter(OBJECT *tree, int mx, int my, int *x, int *y, int *w, int *h)
{
	int xdesk,ydesk,wdesk,hdesk;

	wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk);
	tree->ob_x = mx-tree->ob_width/2;
	if(tree->ob_x<xdesk+3)
		tree->ob_x=xdesk+3;
	tree->ob_y = my-tree->ob_height/2;
	if(tree->ob_y<ydesk+3)
		tree->ob_y=ydesk+3;
	if(tree->ob_x+tree->ob_width > wdesk-3)
		tree->ob_x=wdesk-tree->ob_width-3;
	if(tree->ob_y+tree->ob_height > ydesk+hdesk-3)
		tree->ob_y=ydesk+hdesk-tree->ob_height-3;
	*x=tree->ob_x;
	*y=tree->ob_y;
	*w=tree->ob_width;
	*h=tree->ob_height;
}

int pop_do(OBJECT *tree, int close_at_once)
{
	int mx,my,mouse_click;
	int oum,noum,ret;
	int x,y,w,h,event;
	int leave,mobutton,bmsk=1;
	GRECT r;

	x=tree->ob_x;
	y=tree->ob_y;
	w=tree->ob_width;
	h=tree->ob_height;

	graf_mkstate (&mx, &my, &mobutton, &ret);

	noum=oum=objc_find(tree,0,8,mx,my);
	if(oum != -1)
		if((tree[oum].ob_flags & SELECTABLE) && !(tree[oum].ob_state & DISABLED))
			objc_change(tree,oum,0,x,y,w,h,tree[oum].ob_state|SELECTED,1);

	do
	{
		if(noum != -1)							  /* In Meneintrag */
		{
			objc_offset(tree,noum,&r.g_x,&r.g_y);
			r.g_w=tree[noum].ob_width;
			r.g_h=tree[noum].ob_height;
			leave = TRUE;
		} /* if */
		else										  /* Aužerhalb Pop-Up-Men */
		{
			objc_offset(tree,ROOT,&r.g_x,&r.g_y);
			r.g_w=w;
			r.g_h=h;
			leave = FALSE;
		} /* else */

		event=evnt_multi (MU_BUTTON | MU_M1,
								1, bmsk, ~ mobutton & bmsk,
								leave, r.g_x, r.g_y, r.g_w, r.g_h,
								0, 0, 0, 0, 0,
								NULL, 0, 0,
								&mx, &my, &ret, &ret, &ret, &ret);

		noum=objc_find(tree,0,MAX_DEPTH,mx,my);

		if(oum>0)
			objc_change(tree, oum,0,x,y,w,h,tree[ oum].ob_state&~SELECTED,1);
		if(noum>0)
			objc_change(tree,noum,0,x,y,w,h,tree[noum].ob_state| SELECTED,1);
		oum=noum;
	}
	while(!(event & MU_BUTTON));

	if (~ mobutton & bmsk) evnt_button (1, bmsk, 0x0000, &ret, &ret, &ret, &ret); /* Warte auf Mausknopf */

	if(oum>0)
		tree[oum].ob_state&=~SELECTED;
	return(oum);
}

int pop_exhndl(OBJECT *tree,int mx,int my,int modus)
{
	int exit_obj,ret;

	wind_update(BEG_MCTRL);
	pop_excenter(tree,mx,my,&ret,&ret,&ret,&ret);
	form_open(tree,0);
	exit_obj=pop_do(tree,modus);
	form_close(tree,-1,0);
	evnt_button(1,1,0,&ret,&ret,&ret,&ret);
	wind_update(END_MCTRL);
	return(exit_obj);
}

void objc_update(OBJECT *tree, int obj, int depth)
{
	int obx,oby;
	objc_offset(tree,obj,&obx,&oby);
	objc_draw(tree,obj,depth,obx,oby,
		tree[obj].ob_width,tree[obj].ob_height);
}

void form_write(OBJECT *tree, int item, char *string, int modus)
{
	strcpy(tree[item].ob_spec.tedinfo->te_ptext,string);
	if(modus)
		objc_update(tree,item,0);
}

char *form_read(OBJECT *tree,int item, char *string)
{
	return(strcpy(string,tree[item].ob_spec.tedinfo->te_ptext));
}

