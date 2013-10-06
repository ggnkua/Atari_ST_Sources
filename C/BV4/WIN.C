/*******************************************************************************
	Bitmap view Copyright (c) 1995 by	Christophe BOYANIQUE
													http://www.raceme.org
													tof@raceme.org
********************************************************************************
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or any later version.
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
	more details.
	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	59 Temple Place - Suite 330, Boston, MA 02111, USA.
********************************************************************************
	TABULATION: 3 CARACTERES
*******************************************************************************/

#include		"PROTO.H"

static void _initModal(void);
static void _exitModal(void);
static void _moveDeskIcon(OBJECT *tree,int i,int nx,int ny);

/*******************************************************************************
	Ouverture d'une fenˆtre
*******************************************************************************/
int _winOpen(window *win)
{
	int		top,dum;
	int		x=-1;
	int		handle=-1;
	int		i;

	/****************************************************************************
		Chaque fenˆtre contient un 'type' et un 'id' qui permet de la retrouver
		par la suite.
		1Šre ‚tape: trouver une ‚ventuelle fenˆtre ferm‚e avec ce type/id ou
		ic“nifi‚e.
	****************************************************************************/
	for (i=0;i<glb.opt.Win_Num;i++)
		if (W[i].type==win->type && W[i].id==win->id)
		{
			x=i;
			i=glb.opt.Win_Num;
		}

	if (x==-1)
	{
		/*************************************************************************
			Bon pas de fenˆtre existante puis referm‚e.
			On cherche donc une fenˆtre de handle -1 et si possible avec xwind -1
			pour ne pas ‚craser une fenˆtre referm‚e que l'on devra peut-ˆtre
			r‚ouvrir plus tard.
		*************************************************************************/
		for (i=0;i<glb.opt.Win_Num;i++)
		{
			if (W[i].handle<0 && W[i].xwind==-1)
			{
				x=i;
				i=glb.opt.Win_Num;
			}
			if (x==-1)
				/*******************************************************************
					Pas de chance; on va donc devoir ‚craser une fenˆtre referm‚e.
				*******************************************************************/
				if (W[i].handle<0 && W[i].xwind!=-1)
				{
					x=i;
					W[x].xwind=-1;
					i=glb.opt.Win_Num;
				}
		}
	}

	if (x!=-1)
	{
		/*************************************************************************
			Si le handle est … 0 la fenˆtre est ic“nifi‚e
		*************************************************************************/
		if (W[x].handle==0 && W[x].smallflag)
			_winUnSmall(x);
		/*************************************************************************
			Si le handle est … -1 on cr‚e la fenˆtre sinon on se contente de la
			mettre en avant-plan
		*************************************************************************/
		else if (W[x].handle>0)
		{
			wind_get(0,WF_TOP,&top);
			if (top!=W[x].handle || W[x].smallflag==1)
			{
				if (W[x].smallflag==1)
					_winUnSmall(x);
				_winTop(x);
			}
			handle=W[x].handle;
		}
		else
		{
			W[x].gadget=win->gadget;
			W[x].xgadget=win->xgadget;
			W[x].save_gadget=win->gadget;
			W[x].save_xgadget=win->xgadget;
			W[x].smallflag=0;
			W[x].type=win->type;
			W[x].id=win->id;
			W[x].xslidlen=100;
			W[x].xslidpos=0;
			W[x].yslidlen=100;
			W[x].yslidpos=0;

			W[x].wmini=win->wmini;
			W[x].hmini=win->hmini;
			W[x].xwork=win->xwork;
			W[x].ywork=win->ywork;
			W[x].wwork=max(W[x].wmini,win->wwork);
			W[x].hwork=max(W[x].hmini,win->hwork);
			W[x].xwind=win->xwind;
			W[x].ywind=win->ywind;
			W[x].wwind=win->wwind;
			W[x].hwind=win->hwind;
			W[x].xfull=win->xfull;
			W[x].yfull=win->yfull;
			W[x].wfull=win->wfull;
			W[x].hfull=win->hfull;

			if (win->xwork!=-1)
			{
				wind_calc(WC_BORDER,W[x].gadget,W[x].xwork,W[x].ywork,W[x].wwork,W[x].hwork,
					&W[x].xfull,&W[x].yfull,&W[x].wfull,&W[x].hfull);
				wind_calc(WC_BORDER,W[x].gadget,W[x].xwork,W[x].ywork,W[x].wwork,W[x].hwork,
					&W[x].xwind,&W[x].ywind,&W[x].wwind,&W[x].hwind);
			}

			W[x].wfull=min( W[x].wfull , glb.aes.desk.w );
			W[x].hfull=min( W[x].hfull , glb.aes.desk.h );
			W[x].xfull=max( W[x].xfull , glb.aes.desk.x );
			W[x].yfull=max( W[x].yfull , glb.aes.desk.y );
			W[x].xfull=min( W[x].xfull , glb.aes.desk.x+glb.aes.desk.w-W[x].wfull );
			W[x].yfull=min( W[x].yfull , glb.aes.desk.y+glb.aes.desk.h-W[x].hfull );

			W[x].wwind=min( W[x].wwind , glb.aes.desk.w );
			W[x].hwind=min( W[x].hwind , glb.aes.desk.h );
			W[x].xwind=max( W[x].xwind , glb.aes.desk.x );
			W[x].ywind=max( W[x].ywind , glb.aes.desk.y );
			W[x].xwind=min( W[x].xwind , glb.aes.desk.x+glb.aes.desk.w-W[x].wwind );
			W[x].ywind=min( W[x].ywind , glb.aes.desk.y+glb.aes.desk.h-W[x].hwind );

			if (W[x].xwork%16 && W[x].gadget&W_XALIGN)
			{
				dum=16-W[x].xwork%16;
				W[x].xwork+=dum;
				W[x].xwind+=dum;
			}

			W[x].xold	=	W[x].xwind;
			W[x].yold	=	W[x].ywind;
			W[x].wold	=	W[x].wwind;
			W[x].hold	=	W[x].hwind;

			handle=wind_create(W[x].gadget,W[x].xfull,W[x].yfull,W[x].wfull,W[x].hfull);
			if (handle>0)
			{
				W[x].handle		=	handle;
				W[x].redraw		=	win->redraw;	/*	Pointeur routine redraw			*/
				W[x].top			=	win->top;		/*	Pointeur routine top				*/
				W[x].askclose	=	win->askclose;	/*	Pointeur routine close			*/
				W[x].close		=	win->close;		/*	Pointeur routine close			*/
				W[x].full		=	win->full;		/*	Pointeur routine full			*/
				W[x].arrow		=	win->arrow;		/*	Pointeur routine arrow			*/
				W[x].hslid		=	win->hslid;		/*	Pointeur routine h slider		*/
				W[x].vslid		=	win->vslid;		/*	Pointeur routine v slider		*/
				W[x].size		=	win->size;		/*	Pointeur routine size			*/
				W[x].move		=	win->move;		/*	Pointeur routine move			*/
				W[x].untop		=	win->untop;		/*	Pointeur routine untop			*/
				W[x].ontop		=	win->ontop;		/*	Pointeur routine ontop			*/
				W[x].small		=	win->small;		/*	Pointeur routine small			*/
				W[x].nsmall		=	win->nsmall;	/*	Pointeur routine unsmall		*/
				W[x].clic		=	win->clic;		/*	Pointeur routine de clic		*/
				W[x].keybd		=	win->keybd;		/*	Pointeur routine de clavier	*/
				W[x].init		=	win->init;		/*	Pointeur routine d'init			*/
				W[x].in			=	win->in;
				W[x].ipal		=	win->ipal;
				
				if (W[x].ipal<0)
					W[x].ipal=NO_MEMORY;

				if (win->ic_tree==-1)
					switch (win->icon)
					{
						case	WIC_INF:
							W[x].icon=ICNINF;
							W[x].ic_tree=ICONE;
							break;
						case	WIC_MOD:
							W[x].icon=ICNMOD;
							W[x].ic_tree=ICONE;
							break;
						case	WIC_MEM:
							W[x].icon=ICNMEM;
							W[x].ic_tree=ICONE;
							break;
						case	WIC_OPT:
							W[x].icon=ICNOPT;
							W[x].ic_tree=ICONE;
							break;
						case	WIC_SYS:
							W[x].icon=ICNSYS;
							W[x].ic_tree=ICONE;
							break;
						case	WIC_DEF:
						default:
							W[x].icon=ICNDEF;
							W[x].ic_tree=ICONE;
							break;
					}
				else
				{
					W[x].ic_tree	=	win->ic_tree;
					W[x].icon		=	win->icon;
				}
				_winName(x,win->name,win->sname);

				if (glb.aes.info.sys.bevent)
					wind_set(W[x].handle,WF_BEVENT,1,0,0,0);
				wind_open(W[x].handle,W[x].xwind,W[x].ywind,W[x].wwind,W[x].hwind);

				wind_update(BEG_MCTRL);
				wind_get(W[x].handle,WF_WORKXYWH,&W[x].xwork,&W[x].ywork,&W[x].wwork,&W[x].hwork);
				if (W[x].xgadget&W_MODAL)
				{
					dum=0;									/*	Mets … jour la liste des propri‚t‚s	*/
					for (i=0;i<glb.opt.Win_Num;i++)	/*	des fenˆtres modales						*/
						if (W[i].xgadget&W_MODAL)
							dum=max(dum,W[i].modal);
					W[x].modal=dum+1;
					_initModal();
				}
				wind_update(END_MCTRL);
				glb.aes.top=-1;
				_winMakeTop();

				if (W[x].init!=0)
					(*W[x].init)(x);

				if (W[x].gadget&W_HSLIDE)
				{
					wind_set(W[x].handle,WF_HSLIDE,W[x].xslidpos);
					wind_set(W[x].handle,WF_HSLSIZE,W[x].xslidlen);
				}
				if (W[x].gadget&W_VSLIDE)
				{
					wind_set(W[x].handle,WF_VSLIDE,W[x].yslidpos);
					wind_set(W[x].handle,WF_VSLSIZE,W[x].yslidlen);
				}

			}
			else
				form_alert(1,glb.rsc.head.frstr[NOWIN]);
		}
	}
	else
		form_alert(1,glb.rsc.head.frstr[NOWIN]);
	return x;
}


/*******************************************************************************
	Retourne l'index d'une fenˆtre … partir de son handle GEM
*******************************************************************************/
int _winFindWin(int handle)
{
	int		i,num=-1;

	if (handle>0)
		for (i=0;i<glb.opt.Win_Num;i++)
			if (W[i].handle==handle)
				num=i;
	return num;
}


/*******************************************************************************
	Retourne l'index d'une fenˆtre … partir de son type/id
	open pr‚cise si la fenˆtre doit ˆtre ouverte
*******************************************************************************/
int _winFindId(int type,int id,int open)
{
	int		j;

	for (j=0;j<glb.opt.Win_Num;j++)
		if (W[j].id==id && W[j].type==type)
			if (!open || (open && W[j].handle>0))
				return j;
	return -1;
}


/*******************************************************************************
	Modifie le nom d'une fenˆtre
*******************************************************************************/
void _winName(int i,char *name,char *sname)
{
	if (i!=-1)
		if (W[i].gadget & W_NAME)
		{
			if (W[i].name!=name)
				strncpy(W[i].name,name,wNAMEMAX);
			if (W[i].sname!=sname)
				strncpy(W[i].sname,sname,wSNAMEMAX);
			wind_set(W[i].handle,WF_NAME,W[i].name);
		}
}


/*******************************************************************************
	Envoie un message de redessin pour une fenˆtre
*******************************************************************************/
void _winRedraw(int i,int x,int y,int w,int h)
{
	GRECT		r,rd,my;
	int		ha;

	if (i!=-1)
		if (W[i].handle>0)
		{
			if (!w || !h)
			{
				x=W[i].xwork;
				y=W[i].ywork;
				w=W[i].wwork;
				h=W[i].hwork;
			}
			ha=W[i].handle;
			w=min(w,1+glb.vdi.out[0]-x);
			h=min(h,1+glb.vdi.out[1]-y);
			rd.g_x=x;
			rd.g_y=y;
			rd.g_w=w;
			rd.g_h=h;

			graf_mouse(M_OFF,0);
			wind_update(BEG_UPDATE);

			wind_get(ha,WF_FIRSTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
			while (r.g_w && r.g_h)
			{
				if (_rcIntersect(&rd,&r))
				{
					if (!W[i].smallflag)
					{
						my.g_x=W[i].xwork;
						my.g_y=W[i].ywork;
						my.g_w=W[i].wwork;
						my.g_h=W[i].hwork;
						if (_rcIntersect(&r,&my))
							if (W[i].redraw!=0)
								(*W[i].redraw)(i,my.g_x,my.g_y,my.g_w,my.g_h);
					}
				}
				wind_get(ha,WF_NEXTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
			}
			wind_update(END_UPDATE);
			graf_mouse(M_ON,0);
		}
}


/*******************************************************************************
	Gestion des ‚venements d'avant et arriŠre plan d'une fenˆtre
*******************************************************************************/
void _winTop(int i)
{
	if (i!=-1)
	{
		wind_set(W[i].handle,WF_TOP);
		glb.aes.top=-1;
		_winMakeTop();
		if (W[i].top!=0)
			(*W[i].top)(i);
	}
}
void _winUntop(int i)
{
	if (i!=-1)
		if (W[i].untop!=0)
			(*W[i].untop)(i);
}
void _winOntop(int i)
{
	if (i!=-1)
		if (W[i].ontop!=0)
			(*W[i].ontop)(i);
}
void _winBottom(int i)
{
	if (i!=-1)
	{
		wind_set(W[i].handle,WF_BOTTOM);
		glb.aes.top=-1;
		_winMakeTop();
	}
}


/*******************************************************************************
	Mets … jour les barres avant/arriŠre plan des fenˆtres
*******************************************************************************/
void _winMakeTop()
{
	int		mx,my,dum;
	int		n,i;
	int		top;
	int		*p;

	wind_get(0,WF_TOP,&top);
	if (top!=glb.aes.top)
	{
		i=_winFindWin(top);
		if (i!=-1 && W[i].ipal>0)
		{
			if (glb.vdi.extnd[4]<=8 && glb.mem.len[W[i].ipal]/6L==(1L<<glb.vdi.extnd[4]))
			{
				graf_mkstate(&mx,&my,&dum,&dum);
				glb.aes.event.x2=W[i].xwind;
				glb.aes.event.y2=W[i].ywind;
				glb.aes.event.w2=W[i].wwind;
				glb.aes.event.h2=W[i].hwind;
				if (_winFindWin(wind_find(mx,my))==i)
				{
					glb.aes.event.f2=1;
					p=(int *)glb.mem.adr[W[i].ipal];
					for (n=0;n<(int)(glb.mem.len[W[i].ipal]/6L);n++)
					{
						vs_color(glb.vdi.ha,n,p);
						p+=3;
					}
				}
				else
				{
					glb.aes.event.f2=0;
					_loadPal(glb.vdi.out[13]);
				}
			}
			else
				_loadPal(glb.vdi.out[13]);
		}
		else
			_loadPal(glb.vdi.out[13]);
	}
	glb.aes.top=top;
}


/*******************************************************************************
	Fermeture d'une fenˆtre
*******************************************************************************/
void _winClose(int i)
{
	int	ha;
	int	out=0;

	if (i!=-1)
	{
		if (W[i].askclose!=0 && !glb.div.Exit)
			out=(*W[i].askclose)(i);
		if (!out)
		{
			ha=W[i].handle;
			wind_close(ha);
			wind_delete(ha);
			W[i].handle=-1;
			_mFree(W[i].in);
			_mFree(W[i].ipal);
			if (W[i].close!=0)
				(*W[i].close)(i);
			wind_update(BEG_MCTRL);
			if (W[i].xgadget&W_MODAL)
			{
				W[i].modal=0;
				_exitModal();
			}
			wind_update(END_MCTRL);
			glb.aes.top=-1;
			_winMakeTop();
		}
	}
}


/*******************************************************************************
	Change la position d'une fenˆtre
*******************************************************************************/
void _winMove(int i,int xx,int yy)
{
	int		ha,dum,oldx,x,y,w,h;

	if (i!=-1)
		if (W[i].gadget & W_MOVER)
		{
			ha=W[i].handle;
			wind_get(ha,WF_CURRXYWH,&x,&y,&w,&h);
			x=xx;
			y=yy;

			x=max(glb.aes.desk.x,x);
			y=max(glb.aes.desk.y,y);

			if (W[i].smallflag)
			{
			}
			else
			{
				oldx=W[i].xwind;
				W[i].xwind=x;
				W[i].ywind=y;

				wind_calc(WC_WORK,W[i].gadget,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind,&W[i].xwork,&W[i].ywork,&W[i].wwork,&W[i].hwork);
				if ((oldx-x)%16 && W[i].xgadget & W_XALIGN)
				{
					dum=16-(W[i].xwork%16);
					W[i].xwind+=dum;
					W[i].xwork+=dum;
				}
				wind_set(ha,WF_CURRXYWH,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
				wind_get(ha,WF_WORKXYWH,&W[i].xwork,&W[i].ywork,&W[i].wwork,&W[i].hwork);
				glb.aes.top=-1;
				_winMakeTop();
				if (W[i].move!=0 && (oldx!=W[i].xwind || yy!=y))
					(*W[i].move)(i,W[i].xwind,W[i].ywind);
			}
		}
}


/*******************************************************************************
	Change la taille d'une fenˆtre
*******************************************************************************/
void _winSize(int i,int w,int h)
{
	int	oldw,oldh;
	int	xslidpos,xslidlen;
	int	yslidpos,yslidlen;

	if (i!=-1)
	{
		if (W[i].wwind!=w || W[i].hwind!=h)
		{
			wind_update(BEG_MCTRL);

			xslidpos=W[i].xslidpos;
			xslidlen=W[i].xslidlen;
			yslidpos=W[i].yslidpos;
			yslidlen=W[i].yslidlen;
			oldw=W[i].wwind;
			oldh=W[i].hwind;

			W[i].wwind=min(w,W[i].wfull);
			W[i].hwind=min(h,W[i].hfull);

			wind_calc(WC_WORK,W[i].gadget,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind,&W[i].xwork,&W[i].ywork,&W[i].wwork,&W[i].hwork);
			W[i].wwork=max(W[i].wmini,W[i].wwork);
			W[i].hwork=max(W[i].hmini,W[i].hwork);
			wind_calc(WC_BORDER,W[i].gadget,W[i].xwork,W[i].ywork,W[i].wwork,W[i].hwork,&W[i].xwind,&W[i].ywind,&W[i].wwind,&W[i].hwind);
			wind_set(W[i].handle,WF_CURRXYWH,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			wind_get(W[i].handle,WF_WORKXYWH,&W[i].xwork,&W[i].ywork,&W[i].wwork,&W[i].hwork);

			if (W[i].size!=0)
				(*W[i].size)(i,W[i].wwind,W[i].hwind);

			if (W[i].xslidpos!=xslidpos || W[i].xslidlen!=xslidlen)
			{
				wind_set(W[i].handle,WF_HSLIDE,W[i].xslidpos);
				wind_set(W[i].handle,WF_HSLSIZE,W[i].xslidlen);
			}

			if (W[i].yslidpos!=yslidpos || W[i].yslidlen!=yslidlen)
			{
				wind_set(W[i].handle,WF_VSLIDE,W[i].yslidpos);
				wind_set(W[i].handle,WF_VSLSIZE,W[i].yslidlen);
			}
			glb.aes.top=-1;
			_winMakeTop();

			if (oldw<W[i].wwind || oldh<W[i].hwind)
				_winRedraw(i,0,0,0,0);

			wind_update(END_MCTRL);
		}
	}
}


/*******************************************************************************
	Gestion de l'ouverture maximum d'une fenˆtre
*******************************************************************************/
void _winFull(int i)
{
	int	flag=FALSE;
	int	xslidpos,xslidlen;
	int	yslidpos,yslidlen;
	int	oldw,oldh;
	int	dum,ha;

	if (i!=-1)
	{
		wind_update(BEG_MCTRL);

		xslidpos=W[i].xslidpos;
		xslidlen=W[i].xslidlen;
		yslidpos=W[i].yslidpos;
		yslidlen=W[i].yslidlen;
		oldw=W[i].wwind;
		oldh=W[i].hwind;

		ha=W[i].handle;
		if (W[i].wwind!=W[i].wfull || W[i].hwind!=W[i].hfull)
		{
			W[i].xold	=	W[i].xwind;
			W[i].yold	=	W[i].ywind;
			W[i].wold	=	W[i].wwind;
			W[i].hold	=	W[i].hwind;
			W[i].xwind	=	W[i].xfull;
			W[i].ywind	=	W[i].yfull;
			W[i].wwind	=	W[i].wfull;
			W[i].hwind	=	W[i].hfull;
		}
		else
		{
			W[i].xfull=W[i].xwind;
			W[i].yfull=W[i].ywind;
			W[i].xwind=W[i].xold;
			W[i].ywind=W[i].yold;
			W[i].wwind=W[i].wold;
			W[i].hwind=W[i].hold;
		}
		wind_calc(WC_WORK,W[i].gadget,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind,&W[i].xwork,&W[i].ywork,&W[i].wwork,&W[i].hwork);
		if ((W[i].xold-W[i].xwind)%16 && W[i].xgadget&W_XALIGN)
		{
			dum=16-W[i].xwork%16;
			W[i].xwind+=dum;
		}
		W[i].wwork=max(W[i].wmini,W[i].wwork);
		W[i].hwork=max(W[i].hmini,W[i].hwork);
		wind_calc(WC_BORDER,W[i].gadget,W[i].xwork,W[i].ywork,W[i].wwork,W[i].hwork,&W[i].xwind,&W[i].ywind,&W[i].wwind,&W[i].hwind);
		wind_set(ha,WF_CURRXYWH,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
		wind_get(ha,WF_WORKXYWH,&W[i].xwork,&W[i].ywork,&W[i].wwork,&W[i].hwork);

		glb.aes.top=-1;
		_winMakeTop();

		if (W[i].full!=0)
			(*W[i].full)(i);

		if (W[i].xslidpos!=xslidpos || W[i].xslidlen!=xslidlen)
		{
			wind_set(W[i].handle,WF_HSLIDE,W[i].xslidpos);
			wind_set(W[i].handle,WF_HSLSIZE,W[i].xslidlen);
			flag=TRUE;
		}

		if (W[i].yslidpos!=yslidpos || W[i].yslidlen!=yslidlen)
		{
			wind_set(W[i].handle,WF_VSLIDE,W[i].yslidpos);
			wind_set(W[i].handle,WF_VSLSIZE,W[i].yslidlen);
			flag=TRUE;
		}

		if (oldw<W[i].wwind || oldh<W[i].hwind || flag)
			_winRedraw(i,0,0,0,0);

		wind_update(END_MCTRL);
	}
}


/*******************************************************************************
	Change la taille d'une fenˆtre
*******************************************************************************/
void _winArrow(int i,int type)
{
	int	flag=FALSE;
	int	xslidpos,xslidlen;
	int	yslidpos,yslidlen;

	if (i!=-1)
	{
		wind_update(BEG_MCTRL);

		xslidpos=W[i].xslidpos;
		xslidlen=W[i].xslidlen;
		yslidpos=W[i].yslidpos;
		yslidlen=W[i].yslidlen;

		if (W[i].arrow!=0)
			(*W[i].arrow)(i,type);

		if (W[i].xslidpos!=xslidpos || W[i].xslidlen!=xslidlen)
		{
			wind_set(W[i].handle,WF_HSLIDE,W[i].xslidpos);
			wind_set(W[i].handle,WF_HSLSIZE,W[i].xslidlen);
			flag=TRUE;
		}

		if (W[i].yslidpos!=yslidpos || W[i].yslidlen!=yslidlen)
		{
			wind_set(W[i].handle,WF_VSLIDE,W[i].yslidpos);
			wind_set(W[i].handle,WF_VSLSIZE,W[i].yslidlen);
			flag=TRUE;
		}

		if (flag)
			_winRedraw(i,0,0,0,0);

		wind_update(END_MCTRL);
	}
}


/*******************************************************************************
	Change la taille d'une fenˆtre
*******************************************************************************/
void _winHslid(int i,int pos)
{
	int	xslidpos,xslidlen;

	if (i!=-1)
	{
		wind_update(BEG_MCTRL);

		xslidpos=W[i].xslidpos;
		xslidlen=W[i].xslidlen;

		if (W[i].hslid!=0)
			(*W[i].hslid)(i,pos);

		if (W[i].xslidpos!=xslidpos || W[i].xslidlen!=xslidlen)
		{
			wind_set(W[i].handle,WF_HSLIDE,W[i].xslidpos);
			wind_set(W[i].handle,WF_HSLSIZE,W[i].xslidlen);
			_winRedraw(i,0,0,0,0);
		}

		wind_update(END_MCTRL);
	}
}


/*******************************************************************************
	Change la taille d'une fenˆtre
*******************************************************************************/
void _winVslid(int i,int pos)
{
	int	yslidpos,yslidlen;

	if (i!=-1)
	{
		wind_update(BEG_MCTRL);

		yslidpos=W[i].yslidpos;
		yslidlen=W[i].yslidlen;

		if (W[i].vslid!=0)
			(*W[i].vslid)(i,pos);

		if (W[i].yslidpos!=yslidpos || W[i].yslidlen!=yslidlen)
		{
			wind_set(W[i].handle,WF_VSLIDE,W[i].yslidpos);
			wind_set(W[i].handle,WF_VSLSIZE,W[i].yslidlen);
			_winRedraw(i,0,0,0,0);
		}

		wind_update(END_MCTRL);
	}
}


/*******************************************************************************
	Initialise la liste des fenˆtres modales
*******************************************************************************/
static void _initModal()
{
	OBJECT	*tree;
	int		n,f=0;

	glb.aes.fmod=0;
	glb.aes.wmod=-1;
	for (n=0;n<glb.opt.Win_Num;n++)
		if (W[n].xgadget&W_MODAL && W[n].modal>f)
		{
			f=W[n].modal;
			glb.aes.wmod=n;
			glb.aes.fmod=1;
		}

	if (glb.aes.tree.menu!=-1 && f==1)
	{
		tree=glb.rsc.head.trindex[glb.aes.tree.menu];
		f=0;
		n=-1;
		do
		{
			n+=1;
			if ((tree[n].ob_type&0xFF)==G_STRING && !(tree[n].ob_state&DISABLED) && f!=1)
				tree[n].ob_state|=DISABLED|STATE8;
			if (f==0 && tree[n].ob_type==G_STRING)
				f=1;
			if (f==1 && tree[n].ob_type==G_BOX)
				f=2;
		}	while (!(tree[n].ob_flags&LASTOB));
		_menuBar(glb.aes.tree.menu,FALSE);
		_menuBar(glb.aes.tree.menu,TRUE);
	}
}


/*******************************************************************************
	Ferme la premiŠre fenˆtre modale et mets … jour la liste
*******************************************************************************/
static void _exitModal()
{
	OBJECT	*tree;
	int		n,f=0;

	glb.aes.fmod=0;
	glb.aes.wmod=-1;
	for (n=0;n<glb.opt.Win_Num;n++)
		if (W[n].xgadget&W_MODAL && W[n].modal>f)
		{
			f=W[n].modal;
			glb.aes.wmod=n;
			glb.aes.fmod=1;
		}

	if (glb.aes.tree.menu!=-1 && f==0)
	{
		tree=glb.rsc.head.trindex[glb.aes.tree.menu];
		n=-1;
		do
		{
			n+=1;
			if ((tree[n].ob_type&0xFF)==G_STRING && tree[n].ob_state&STATE8)
				tree[n].ob_state&=~(DISABLED|STATE8);
		}	while (!(tree[n].ob_flags&LASTOB));
		_menuBar(glb.aes.tree.menu,FALSE);
		_menuBar(glb.aes.tree.menu,TRUE);
	}
}


/*******************************************************************************
	Gestion du clic souris sur une fenˆtre
*******************************************************************************/
void _winClic(int i,int x,int y,int k,int nmb)
{
	int		mk=k;
	int		dum;

	if (i!=-1)
	{
		if (k==2)
		{
			do
			{
				graf_mkstate(&dum,&dum,&mk,&dum);
			}	while (mk);
			if (!glb.aes.fmod || glb.aes.wmod==i)
				_winTop(i);
		}
		else if (!W[i].smallflag && W[i].clic!=0 && glb.aes.event.flag&MU_BUTTON)
			if (!glb.aes.fmod || (glb.aes.fmod && i==glb.aes.wmod))
				(*W[i].clic)(i,x,y,k,nmb);
	}
}


/*******************************************************************************
	Gestion des ‚v‚nements d'ic“nification d'une fenˆtre
*******************************************************************************/
void _winSmall(int i)
{
	char		file[FILENAME_MAX];
	OBJECT	*tree;
	OBJECT	*icon;
	int		x,y,w,h;
	int		ha,ok;

	if (!W[i].smallflag)
	{
		ok=TRUE;
		if (W[i].xgadget&W_SWAP)
		{
			sprintf(file,"%sBV4__%03i.%03i",glb.div.SWP_Path,glb.aes.id,i);
			ha=(int)Fcreate(file,0);
			if (ha>0)
			{
				if (Fwrite(ha,glb.mem.len[W[i].in],(void *)glb.mem.adr[W[i].in])!=glb.mem.len[W[i].in])
				{
					Fclose(ha);
					ok=FALSE;
				}
				else
					ok=!Fclose(ha);
			}
			else
				ok=FALSE;
			if (ok)
			{
				_mFree(W[i].in);
				W[i].in=SWP_MEMORY;
			}
			else
				Fdelete(file);
		}

		if (ok)
		{
			tree=glb.rsc.head.trindex[glb.aes.tree.desk];
			tree[glb.aes.desk.first_icon+i].ob_flags&=~HIDETREE;

			icon=glb.rsc.head.trindex[W[i].ic_tree];

			tree[glb.aes.desk.first_icon+i].ob_spec=icon[W[i].icon].ob_spec;

			x=tree[glb.aes.desk.first_icon+i].ob_x;
			y=tree[glb.aes.desk.first_icon+i].ob_y;
			w=tree[glb.aes.desk.first_icon+i].ob_width;
			h=tree[glb.aes.desk.first_icon+i].ob_height;
			wind_close(W[i].handle);
			wind_delete(W[i].handle);
			W[i].handle=0;
			W[i].smallflag=1;
			graf_shrinkbox(x,y,w,h,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x+x,glb.aes.desk.y+y,w,h);
			glb.aes.top=-1;
			_winMakeTop();
			_winAlign();
		}
	}
}

void _winUnSmall(int i)
{
	char		file[FILENAME_MAX];
	OBJECT	*tree;
	long		len;
	int		x,y,w,h;
	int		in,ha,handle,ok;

	if (W[i].smallflag)
	{
		handle=wind_create(W[i].gadget,W[i].xfull,W[i].yfull,W[i].wfull,W[i].hfull);
		if (handle>0)
		{

			ok=TRUE;
			if (W[i].xgadget&W_SWAP && W[i].in==SWP_MEMORY)
			{
				sprintf(file,"%sBV4__%03i.%03i",glb.div.SWP_Path,glb.aes.id,i);
				ha=(int)Fopen(file,FO_READ);
				if (ha>0)
				{
					len=Fseek(0L,ha,2);
					Fseek(0L,ha,0);
					in=_mAlloc(len,MM_NOFILL);
					if (in!=NO_MEMORY)
					{
						if (Fread(ha,len,(void *)glb.mem.adr[in])!=len)
							ok=FALSE;
					}
					else
						ok=FALSE;
					ok=!Fclose(ha) && in!=NO_MEMORY;
				}
				else
					ok=FALSE;
				if (ok)
				{
					W[i].in=in;
					Fdelete(file);
				}
			}

			if (ok)
			{
				W[i].smallflag=0;
				W[i].handle=handle;
				_winName(i,W[i].name,W[i].sname);
				wind_set(W[i].handle,WF_BEVENT,1,0,0,0);

				tree=glb.rsc.head.trindex[glb.aes.tree.desk];
				tree[glb.aes.desk.first_icon+i].ob_flags|=HIDETREE;
				x=tree[glb.aes.desk.first_icon+i].ob_x;
				y=tree[glb.aes.desk.first_icon+i].ob_y;
				w=tree[glb.aes.desk.first_icon+i].ob_width;
				h=tree[glb.aes.desk.first_icon+i].ob_height;
				form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x+x,glb.aes.desk.y+y,w,h);
				graf_growbox(x,y,w,h,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
				wind_open(W[i].handle,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);

				if (W[i].gadget&W_HSLIDE)
				{
					wind_set(W[i].handle,WF_HSLIDE,W[i].xslidpos);
					wind_set(W[i].handle,WF_HSLSIZE,W[i].xslidlen);
				}
				if (W[i].gadget&W_VSLIDE)
				{
					wind_set(W[i].handle,WF_VSLIDE,W[i].yslidpos);
					wind_set(W[i].handle,WF_VSLSIZE,W[i].yslidlen);
				}

				glb.aes.top=-1;
				_winMakeTop();
				_winAlign();
			}
			else
				wind_delete(handle);
		}
	}
}


static void _moveDeskIcon(OBJECT *tree,int i,int nx,int ny)
{
	int	x,y,w,h;

	_coord(tree,i,FALSE,&x,&y,&w,&h);
	tree[i].ob_x=nx;
	tree[i].ob_y=ny;
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	_coord(tree,i,FALSE,&nx,&ny,&w,&h);
	graf_movebox(w,h,x,y,nx,ny);
	form_dial(FMD_FINISH,0,0,0,0,nx,ny,w,h);
}
/*******************************************************************************
	Aligne les fenˆtres ic“nifi‚es
*******************************************************************************/
void _winAlign(void)
{
	OBJECT	*tree;
	int		x,y,w=0,h=0,n=0,ch;

	if (glb.opt.Auto_Icon)
	{
		tree=glb.rsc.head.trindex[glb.aes.tree.desk];

		ch=0;
		do
		{
			ch+=1;
			if (!(tree[ch].ob_flags&HIDETREE))
			{
				w=max(w,tree[ch].ob_width);
				h=max(h,tree[ch].ob_height);
				n+=1;
			}
		}	while ( !(tree[ch].ob_flags&LASTOB) );

		if (n)
		{
			w+=2;
			h+=2;
			if (!glb.opt.Rev_Verti)
			{
				if (!glb.opt.Rev_Horiz)
				{
					x=0;
					y=0;
					ch=0;
					do
					{
						ch+=1;
						if (!(tree[ch].ob_flags&HIDETREE))
						{
							if (tree[ch].ob_x!=x || tree[ch].ob_y!=y)
								_moveDeskIcon(tree,ch,x,y);
							y+=h;
							if (y+h>glb.aes.desk.h)
							{
								x=min(0+glb.aes.desk.w-w,x+w);
								y=0;
							}
						}
					}	while ( !(tree[ch].ob_flags&LASTOB) );
				}
				else
				{
					x=0;
					y=0+glb.aes.desk.h-h;
					ch=0;
					do
					{
						ch+=1;
						if (!(tree[ch].ob_flags&HIDETREE))
						{
							if (tree[ch].ob_x!=x || tree[ch].ob_y!=y)
								_moveDeskIcon(tree,ch,x,y);
							y-=h;
							if (y<0)
							{
								x=min(glb.aes.desk.w-w,x+w);
								y=glb.aes.desk.h-h;
							}
						}
					}	while ( !(tree[ch].ob_flags&LASTOB) );
				}
			}
			else
			{
				if (!glb.opt.Rev_Horiz)
				{
					x=0+glb.aes.desk.w-w;
					y=0;
					ch=0;
					do
					{
						ch+=1;
						if (!(tree[ch].ob_flags&HIDETREE))
						{
							if (tree[ch].ob_x!=x || tree[ch].ob_y!=y)
								_moveDeskIcon(tree,ch,x,y);
							y+=h;
							if (y+h>0+glb.aes.desk.h)
							{
								x=max(0,x-w);
								y=0;
							}
						}
					}	while ( !(tree[ch].ob_flags&LASTOB) );
				}
				else
				{
					x=0+glb.aes.desk.w-w;
					y=0+glb.aes.desk.h-h;
					ch=0;
					do
					{
						ch+=1;
						if (!(tree[ch].ob_flags&HIDETREE))
						{
							if (tree[ch].ob_x!=x || tree[ch].ob_y!=y)
								_moveDeskIcon(tree,ch,x,y);
							y-=h;
							if (y<0)
							{
								x=max(0,x-w);
								y=0+glb.aes.desk.h-h;
							}
						}
					}	while ( !(tree[ch].ob_flags&LASTOB) );
				}
			}
		}
	}
}
