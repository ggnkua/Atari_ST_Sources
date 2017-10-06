
/* Lines (PRG):
	Animierte farbige Liniengrafik (Gr”že wird an Fenstergr”že angepažt,
	l„uft in ikonifizierter Darstellung weiter) */

#include <e_gem.h>
#include <float.h>
#include <math.h>
#include <time.h>

#define UPDATE		2
#define LINES		25

typedef struct
{
	int color;
	double xs,ys,xe,ye;
} Line;

WIN *win;
int idx,col=BLACK,crcw,crch,lw,lh,cw,ch;
long last;

double freq[4],wi[4];
Line Lines[LINES];

void DrawLines(int cnt,int f,GRECT *r,GRECT *wo,Line *l)
{
	int xo=wo->g_x,yo=wo->g_y;
	double w=(double) (lw/2),h=(double) (lh/2);

	if (f)
		cw = ch = 0;
	cw ^= r->g_w;ch ^= r->g_h;

	for (;--cnt>=0;l++)
		if (l->color)
		{
			v_set_line(l->color,FAIL,FAIL,FAIL,FAIL);
			v_line(xo+(int)(l->xs*w),yo+(int)(l->ys*h),xo+(int)(l->xe*w),yo+(int)(l->ye*h));
		}
}

void DrawNew(int f,WIN *w,GRECT *r,GRECT *wo,void *p)
{
	DrawLines(UPDATE*2,f,r,wo,p);
}

void Draw(int f,WIN *w,GRECT *r,GRECT *wo,void *p)
{
	lw = wo->g_w;lh = wo->g_h;
	rc_sc_copy(r,r->g_x,r->g_y,15);
	DrawLines(LINES,f,r,wo,p);
}

long LinesTimer(long p,long time,MKSTATE *m)
{
	double *ko;
	Line l,new[UPDATE*2],*n=new;
	int i,j=UPDATE;

	while (--j>=0)
	{
		for (ko=&l.xs,i=4;--i>=0;)
			*ko++ = sin(wi[i]+=freq[i])+1;

		l.color = col++;
		if (col>=colors)
			col = BLACK;

		*n++ = l;
		*n++ = Lines[idx];
		Lines[idx++] = l;
		idx %= LINES;
	}

	draw_window(win,NULL,new,MOUSE_TEST,DrawNew);
	if (cw!=crcw || ch!=crch)
	{
		last = time;
		crcw = cw;
		crch = ch;
	}
	return(CONT_TIMER);
}

int Init(XEVENT *ev,int a)
{
	int fl=MU_MESAG;
	if (last>0)
	{
		ev->ev_mt4last = last;
		ev->ev_mt4count = 30;
		fl |= MU_TIMER4;
	}
	return(fl);
}

int Event(XEVENT *ev)
{
	int wi=ev->ev_mwich;

	if (wi&MU_MESAG)
		switch (ev->ev_mmgpbuf[0])
		{
		case AP_TERM:
		case WM_CLOSED:
			exit_gem(TRUE,0);break;
		case WM_REDRAW:
			last = clock()*5;break;
		default:
			wi ^= MU_MESAG;
		}

	if (wi&MU_TIMER4)
	{
		draw_window(win,NULL,Lines,MOUSE_TEST,Draw);
		crcw = cw;
		crch = ch;
		last = 0;
	}
	return(wi);
}

void main()
{
	if (init_gem(NULL,NULL,"Lines","LINES",0,0,0)==TRUE)
	{
		GRECT curr=desk;
		curr.g_x += (curr.g_w>>=1);
		curr.g_h >>= 1;
		if ((win=open_window("Lines",NULL,NULL,NIL,NAME|CLOSER|FULLER|SIZER|MOVER|SMALLER,FALSE,0,0,NULL,&curr,NULL,0l,NULL,XM_TOP|XM_BOTTOM|XM_SIZE))!=NULL)
		{
			int i=4;
			while (--i>=0)
				freq[i] = 0.03+(0.03/32767.00)*(double) rand();
			v_set_mode(MD_XOR);
			v_set_line(FAIL,1,1,0,0);
			NewTimer(10,0l,LinesTimer);
			Event_Handler(Init,Event);
			Event_Multi(NULL);
		}
	}
	exit_gem(TRUE,-1);
}
