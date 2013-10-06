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

/*******************************************************************************
	Ouvre une fenˆtre formulaire
*******************************************************************************/
int _winForm(int tree,char *name,char *sname,int ic_tree,int icon,int type,int xtype)
{
	int			x,y,w,h,i=-1;
	OBJECT		*adr;
	char			buf[sizeof(window)];
	window		*win;
	int			obj=-1;
	int			dum,edt=-1;

	win=(window *)buf;

	adr=glb.rsc.head.trindex[tree];

	strcpy(win->name,name);
	strcpy(win->sname,sname);

	win->gadget=type;
	win->xgadget=xtype;
	win->save_gadget=type;
	win->save_xgadget=xtype;

	if (xtype & W_MODAL)
		win->xgadget|=W_MODAL;

	if (!(type & W_MOVER))
		win->gadget|=W_MOVER;

	if (!(type & W_MOVER))
		win->gadget|=W_NAME;

	if (!(xtype & W_MODAL || type & W_CLOSER))
		win->gadget|=W_CLOSER;

	if (!(xtype & W_MODAL || type & W_SMALLER))
		win->gadget|=W_SMALLER;

	i=_winFindId(TW_FORM,tree,0);
	if (glb.aes.x!=-1)				/*	Dimensions impos‚es	*/
	{
		x=glb.aes.x;
		y=glb.aes.y;
	}
	else
	{
		if ((i==-1 && glb.opt.Mouse_Form) || (i!=-1 && glb.opt.Mouse_Form==2))
			form_center(adr,&x,&y,&w,&h);		/*	Centrage		*/
		else if (i==-1)							/*	A la souris	*/
		{
			graf_mkstate(&x,&y,&dum,&dum);
			w=adr->ob_width;
			h=adr->ob_height;
			x-=w/2;
			x=max(glb.aes.desk.x,x);
			x=min(glb.aes.desk.x+glb.aes.desk.w-w,x);
			y-=h/2;
			y=max(glb.aes.desk.y,y);
			y=min(glb.aes.desk.y+glb.aes.desk.h-h,y);
		}
		else											/*	Ancienne		*/
		{
			x=W[i].xwork;
			y=W[i].ywork;
		}
	}

	win->xwind=-1;
	win->xwork=x;
	win->ywork=y;
	win->wwork=adr->ob_width;
	win->hwork=adr->ob_height;
	win->wmini=adr->ob_width;
	win->hmini=adr->ob_height;

	win->icon		=	icon;
	win->ic_tree	=	ic_tree;
	win->type		=	TW_FORM;
	win->id			=	tree;
	win->in			=	NO_MEMORY;
	win->ipal		=	NO_MEMORY;

	win->top			=	0;
	win->full		=	0;
	win->arrow		=	0;
	win->hslid		=	0;
	win->vslid		=	0;
	win->size		=	0;
	win->ontop		=	0;
	win->small		=	0;
	win->nsmall		=	0;
	win->init		=	0;
	win->redraw		=	_redrawForm;
	win->keybd		=	_keybdForm;
	win->move		=	_moveForm;
	win->clic		=	_clicForm;
	win->askclose	=	0;
	win->close		=	0;
	win->untop		=	0;

	i=_winOpen(win);
	if (i!=-1)
	{
		W[i].str.wf.pos=0;
		W[i].str.wf.obj=-1;
		W[i].str.wf.tree=adr;
		do
		{
			obj+=1;
			if (edt==-1 && adr[obj].ob_flags&EDITABLE && !(adr[obj].ob_state&DISABLED))
			{
				dum=(adr[obj].ob_type)&0xFF;
				if (dum==G_FTEXT || dum==G_FBOXTEXT)
					edt=obj;
			}
		}	while (!(adr[obj].ob_flags&LASTOB));
		W[i].str.wf.obj=edt;
		if (W[i].str.wf.obj!=-1)
			W[i].str.wf.pos=(int)strlen(_obGetStr(adr,W[i].str.wf.obj));
		else
			W[i].str.wf.pos=-1;
	}

	if (xtype&W_MODAL && W[i].id!=FPRG)
	{
		while (_winFindId(TW_FORM,tree,TRUE)!=-1)
			_gereAes();

		i=-1;			/*	Recherche l'objet qui a servi … fermer la fenˆtre:		*/
		obj=-1;		/*	Il a le flag EXIT et l'‚tat SELECTED						*/
		do
		{
			obj+=1;

			if (adr[obj].ob_flags&EXIT && adr[obj].ob_state&SELECTED)
			{
				i=obj;
				adr[obj].ob_state&=~SELECTED;
			}
		}	while ( !(adr[obj].ob_flags & LASTOB) );

	}

	return i;
}


/*******************************************************************************
	Gestion du clavier dans une fenˆtre formulaire
*******************************************************************************/
void cdecl _keybdForm(int i,int key)
{
	int			child,type;
	int			j,k;
	int			x,y;
	UBLK			*user;
	TEDINFO		*ted;
	uchar			*p,*q,*trait;

	child=0;
	do
	{
		child+=1;
		if (glb.aes.std)
		{
			type=W[i].str.wf.tree[child].ob_type;
			if (!(W[i].str.wf.tree[child].ob_state&DISABLED))
			{
				if (W[i].str.wf.tree[child].ob_flags&DEFAULT && (key&0xFF)==K_RETURN)
				{
					objc_offset(W[i].str.wf.tree,child,&x,&y);
					_clicForm(i,x,y,-1,1);
					glb.aes.std=0;
				}
				else
				{
					p=NULL;
					switch (type&0xFF)
					{
						case	G_BUTTON:
						case	G_STRING:
							p=(uchar *)W[i].str.wf.tree[child].ob_spec.free_string;
							break;
						case	G_TEXT:
						case	G_FTEXT:
						case	G_BOXTEXT:
						case	G_FBOXTEXT:
							p=(uchar *)W[i].str.wf.tree[child].ob_spec.tedinfo->te_ptext;
							break;
						case	G_USERDEF:
							user=(UBLK *)(W[i].str.wf.tree[child].ob_spec.userblk->ub_parm);
							if (user->type==G_BUTTON)
								p=(uchar *)user->spec;
							break;
					}
					if (p!=NULL)
					{
						trait=(uchar *)strchr((char *)p,0x5B);
						if (trait!=NULL)
						{
							trait++;
							if (*trait!=0)
							{
								if (toupper(key&0xFF)==toupper(*trait))
								{
									if (W[i].str.wf.obj==-1 || key&KF_ALT)
									{
										objc_offset(W[i].str.wf.tree,child,&x,&y);
										_clicForm(i,x,y,-1,1);
										glb.aes.std=0;
									}
								}
							}
						}
					}
				}
			}
		}
	} while ( (!(W[i].str.wf.tree[child].ob_flags&LASTOB)) && glb.aes.std );
	key=glb.aes.std;
	if (W[i].str.wf.obj!=-1 && glb.aes.std)
	{
		if (W[i].str.wf.tree[W[i].str.wf.obj].ob_flags&EDITABLE && !(W[i].str.wf.tree[W[i].str.wf.obj].ob_state&DISABLED))
		{
			ted=(TEDINFO *)W[i].str.wf.tree[W[i].str.wf.obj].ob_spec.tedinfo;
			if (key&KF_FUNC)
			{
				switch (key&0xFF)
				{
					case	K_ESC:
						if (strlen(ted->te_ptext))
						{
							ted->te_ptext[0]=0;
							W[i].str.wf.pos=0;
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_END);
							objc_draw(W[i].str.wf.tree,W[i].str.wf.obj,0,W[i].str.wf.tree->ob_x,W[i].str.wf.tree->ob_y,W[i].str.wf.tree->ob_width,W[i].str.wf.tree->ob_height);
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
						}
						glb.aes.std=0;
						break;
					case	K_BS:
						if (W[i].str.wf.pos>0 && strlen(ted->te_ptext))
						{
							p=(uchar *)ted->te_ptext;
							p+=W[i].str.wf.pos-1;
							*p=0;
							p+=1;
							while (*p!=0)
							{
								strncat(ted->te_ptext,(char *)p,1);
								p+=1;
							}
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_END);
							W[i].str.wf.pos-=1;
							objc_draw(W[i].str.wf.tree,W[i].str.wf.obj,0,W[i].str.wf.tree->ob_x,W[i].str.wf.tree->ob_y,W[i].str.wf.tree->ob_width,W[i].str.wf.tree->ob_height);
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
						}
						glb.aes.std=0;
						break;
					case	K_DEL:
						if (W[i].str.wf.pos<strlen(ted->te_ptext) && strlen(ted->te_ptext))
						{
							p=(uchar *)ted->te_ptext;
							p+=W[i].str.wf.pos;
							*p=0;
							p+=1;
							while (*p!=0)
							{
								strncat(ted->te_ptext,(char *)p,1);
								p+=1;
							}
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_END);
							objc_draw(W[i].str.wf.tree,W[i].str.wf.obj,0,W[i].str.wf.tree->ob_x,W[i].str.wf.tree->ob_y,W[i].str.wf.tree->ob_width,W[i].str.wf.tree->ob_height);
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
						}
						glb.aes.std=0;
						break;
					case	K_LEFT:
						if (W[i].str.wf.pos)
						{
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_END);
							if (key&KF_SHIFT)
								W[i].str.wf.pos=0;
							else if (key&KF_CTRL)
							{
								trait=(uchar *)((long)_obGetStr(W[i].str.wf.tree,W[i].str.wf.obj)+(long)W[i].str.wf.pos);
								p=q=(uchar *)_obGetStr(W[i].str.wf.tree,W[i].str.wf.obj);
								while ( (long)p < (long) trait )
								{
									q=p;
									if (*p!=' ')
										while ( (*p!=0) && (*p!=' ') )
											p++;
									while ( (*p!=0) && (*p==' ') )
										p++;
								}
								W[i].str.wf.pos+=(int)( (long)q - (long)_obGetStr(W[i].str.wf.tree,W[i].str.wf.obj)-(long)W[i].str.wf.pos );
							}
							else
								W[i].str.wf.pos-=1;
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
						}
						glb.aes.std=0;
						break;
					case	K_RIGHT:
						if ( (W[i].str.wf.pos<strlen(ted->te_ptext)) && (strlen(ted->te_ptext)) )
						{
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_END);
							if (key&KF_SHIFT)
								W[i].str.wf.pos=(int)strlen(_obGetStr(W[i].str.wf.tree,W[i].str.wf.obj));
							else if (key&KF_CTRL)
							{
								p=(uchar *)((long)_obGetStr(W[i].str.wf.tree,W[i].str.wf.obj)+(long)W[i].str.wf.pos);
								if (*p!=' ')
									while ( (*p!=0) && (*p!=' ') )
										p++;
								while ( (*p!=0) && (*p==' ') )
									p++;
								W[i].str.wf.pos+=(int)( (long)p-(long)_obGetStr(W[i].str.wf.tree,W[i].str.wf.obj)-(long)W[i].str.wf.pos );
							}
							else
								W[i].str.wf.pos+=1;
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
						}
						glb.aes.std=0;
						break;
					case	K_UP:
						k=W[i].str.wf.obj;
						j=W[i].str.wf.obj;
						do
						{
							x=(W[i].str.wf.tree[k].ob_type)&0xFF;
							if ((x==G_FTEXT || x==G_FBOXTEXT) && W[i].str.wf.tree[k].ob_flags&EDITABLE && !(W[i].str.wf.tree[k].ob_state&DISABLED))
								j=k;
							if (W[i].str.wf.tree[k].ob_flags&LASTOB)
								k=ROOT;
							else
								k++;
						}
						while (k!=W[i].str.wf.obj);
						if (j!=W[i].str.wf.obj)
						{
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_END);
							W[i].str.wf.obj=j;
							ted=(TEDINFO *)W[i].str.wf.tree[W[i].str.wf.obj].ob_spec.tedinfo;
							W[i].str.wf.pos=(int)strlen(ted->te_ptext);
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
							glb.aes.std=0;
						}
						break;
					case	K_TAB:
					case	K_DOWN:
					case	K_RETURN:
						if ((key&0xFF)==K_RETURN)
							_clicRSC(W[i].id,W[i].str.wf.obj,0);
						k=W[i].str.wf.obj;
						j=-1;
						do
						{
							if (W[i].str.wf.tree[k].ob_flags&LASTOB)
								k=ROOT;
							else
								k++;
							x=(W[i].str.wf.tree[k].ob_type)&0xFF;
							if ((x==G_FTEXT || x==G_FBOXTEXT) && W[i].str.wf.tree[k].ob_flags&EDITABLE && !(W[i].str.wf.tree[k].ob_state&DISABLED))
								j=k;
						}
						while (j==-1);
						if (j!=W[i].str.wf.obj)
						{
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_END);
							W[i].str.wf.obj=j;
							ted=(TEDINFO *)W[i].str.wf.tree[W[i].str.wf.obj].ob_spec.tedinfo;
							W[i].str.wf.pos=(int)strlen(ted->te_ptext);
							objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
							glb.aes.std=0;
						}
						break;
				}
			}
			else if ((key&0xFF)>31)
				objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,key&0xFF,&W[i].str.wf.pos,ED_CHAR);
		}
		else
		{
			k=W[i].str.wf.obj;
			j=-1;
			do
			{
				if (W[i].str.wf.tree[k].ob_flags&LASTOB)
					k=ROOT;
				else
					k++;
				x=(W[i].str.wf.tree[k].ob_type)&0xFF;
				if ((x==G_FTEXT || x==G_FBOXTEXT) && W[i].str.wf.tree[k].ob_flags&EDITABLE && !(W[i].str.wf.tree[k].ob_state&DISABLED))
					j=k;
			}	while (j==-1 && k!=W[i].str.wf.obj);
			if (j!=W[i].str.wf.obj)
			{
				objc_draw(W[i].str.wf.tree,W[i].str.wf.obj,0,W[i].str.wf.tree->ob_x,W[i].str.wf.tree->ob_y,W[i].str.wf.tree->ob_width,W[i].str.wf.tree->ob_height);
				W[i].str.wf.obj=j;
				ted=(TEDINFO *)W[i].str.wf.tree[W[i].str.wf.obj].ob_spec.tedinfo;
				W[i].str.wf.pos=(int)strlen(ted->te_ptext);
				objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
			}
			else
			{
				W[i].str.wf.obj=-1;
				W[i].str.wf.pos=-1;
			}
		}
	}
}


/*******************************************************************************
	Redessin d'une fenˆtre fomulaire
*******************************************************************************/
void cdecl _redrawForm(int i,int x,int y,int w,int h)
{
	GRECT		obj,clip;
	int		dum,flag;

	W[i].str.wf.tree->ob_x=W[i].xwork;
	W[i].str.wf.tree->ob_y=W[i].ywork;
	if (W[i].str.wf.obj!=-1)
	{
		_coord(W[i].str.wf.tree,W[i].str.wf.obj,FALSE,&obj.g_x,&obj.g_y,&obj.g_w,&obj.g_h);
		clip.g_x=x;
		clip.g_y=y;
		clip.g_w=w;
		clip.g_h=h;
		flag=_rcIntersect(&obj,&clip);
		if (flag && glb.aes.top==W[i].handle)
		{
			dum=W[i].str.wf.pos;
			objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&dum,ED_CLIP|ED_END);
		}
	}
	objc_draw(W[i].str.wf.tree,ROOT,MAX_DEPTH,x,y,w,h);
	if (W[i].str.wf.obj!=-1 && flag && glb.aes.top==W[i].handle)
		objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
}


/*******************************************************************************
	D‚placement d'une fenˆtre formulaire
*******************************************************************************/
#pragma warn -par
void cdecl _moveForm(int i,int x,int y)
{
	W[i].str.wf.tree->ob_x=W[i].xwork;
	W[i].str.wf.tree->ob_y=W[i].ywork;
}
#pragma warn +par


/*******************************************************************************
	Gestion du clic sur une fenˆtre formulaire
*******************************************************************************/
#pragma warn -par
void cdecl _clicForm(int i,int x,int y,int k,int nmb)
{
	uint			c,d;
	int			n,pop,rpop,mx=0,my=0,mk,sel,sel1,sel2,a,b;
	int			flags,state;
	int			top;
	int			obx,oby,obw,obh,dum;
	uchar			*p,*q;
	OBJECT		*obj;
	UBLK			*user=NULL;

	if (k==-1)
		mk=0;
	else
		mk=k;

	W[i].str.wf.tree->ob_x=W[i].xwork;
	W[i].str.wf.tree->ob_y=W[i].ywork;		
	n=objc_find(W[i].str.wf.tree,ROOT,MAX_DEPTH,x,y);
	if (n!=-1)
	{
		flags=W[i].str.wf.tree[n].ob_flags;
		state=W[i].str.wf.tree[n].ob_state;
		if ((W[i].str.wf.tree[n].ob_type&0xFF)==G_USERDEF)
			user=(UBLK *)(W[i].str.wf.tree[n].ob_spec.userblk->ub_parm);

		/*	Cas d'un POP UP MENU	*/
		if ((W[i].str.wf.tree[n].ob_type&0xFF00)==USD_POPUP && !(state&DISABLED))
		{
			pop	=	user->user1;
			rpop	=	user->user4;
			if (k!=-1 && pop!=-1)
			{
				W[i].str.wf.tree[n].ob_state|=SELECTED;
				wind_update(BEG_MCTRL);
				_coord(W[i].str.wf.tree,n,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,W[i].str.wf.tree,n,MAX_DEPTH,obx,oby,obw,obh);
				rpop=_formMenu(W[i].str.wf.tree,n)-1;
				W[i].str.wf.tree[n].ob_state&=~SELECTED;
				_coord(W[i].str.wf.tree,n,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,W[i].str.wf.tree,n,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_MCTRL);
				if (rpop!=-2)
				{
					user->user4=rpop;
					obj=glb.rsc.head.trindex[pop];
					p=(uchar *)_obGetStr(obj,rpop+1);
					if (!(W[i].str.wf.tree[n].ob_state&STATE8))
						_obPutStr(W[i].str.wf.tree,n,(char *)p);
					_clicRSC(W[i].id,n,nmb);
				}
				wind_update(BEG_UPDATE);
				W[i].str.wf.tree[n].ob_state&=~SELECTED;
				_coord(W[i].str.wf.tree,n,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,W[i].str.wf.tree,n,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_UPDATE);
			}
		}

		/*	Cas d'un EXTENDED POP UP MENU	*/
		else if ((W[i].str.wf.tree[n].ob_type&0xFF00)==USD_XPOPUP && !(state&DISABLED))
		{
			rpop=user->user4;
			if (k!=-1 && pop!=-1)
			{
				W[i].str.wf.tree[n].ob_state|=SELECTED;
				wind_update(BEG_MCTRL);
				_coord(W[i].str.wf.tree,n,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,W[i].str.wf.tree,n,MAX_DEPTH,obx,oby,obw,obh);
				rpop=_formXmenu(W[i].str.wf.tree,n,(char *)user->userl1,user->userl2,user->user1,user->user2,user->user5,user->user3,user->user4);
				W[i].str.wf.tree[n].ob_state&=~SELECTED;
				_coord(W[i].str.wf.tree,n,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,W[i].str.wf.tree,n,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_MCTRL);
				if (rpop!=-1)
				{
					user->user4=rpop;
					if (!(W[i].str.wf.tree[n].ob_state&STATE8))
					{
						if (((user->userl1)>>16)==0x7FFFL)
							p=(uchar *)(glb.mem.adr[(int)((user->userl1)&0xFFFFL)]);
						else
							p=(uchar *)(user->userl1);
						p+=user->userl2+(long)user->user2+(long)user->user4*(long)(user->user3+user->user2+user->user5);
						q=p;
						p+=user->user3;
						pop=(int)*p;
						*p=0;
							_obPutStr(W[i].str.wf.tree,n,(char *)q);
						*p=(char)pop;
					}
					_clicRSC(W[i].id,n,nmb);
				}
				wind_update(BEG_UPDATE);
				W[i].str.wf.tree[n].ob_state&=~SELECTED;
				_coord(W[i].str.wf.tree,n,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,W[i].str.wf.tree,n,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_UPDATE);
			}
		}

		/*	Cas d'un EDITABLE	*/
		else if (flags&EDITABLE && !(state&DISABLED))
		{
			wind_get(0,WF_TOP,&top);
			if (top==W[i].handle)
			{
				wind_update(BEG_MCTRL);
				if (W[i].str.wf.obj!=n)
				{
					objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_END);
					W[i].str.wf.pos=(int)strlen(((TEDINFO *)W[i].str.wf.tree[n].ob_spec.tedinfo)->te_ptext);
					W[i].str.wf.obj=n;
					objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
				}
				do
					graf_mkstate(&dum,&dum,&k,&dum);
				while (k);
				wind_update(END_MCTRL);
			}
		}

		/*	Cas d'un bouton SELECTABLE et NON RADIO BUTTON	*/
		else if (flags&SELECTABLE && !(state&DISABLED) && !(flags&RBUTTON))
		{
			sel1=W[i].str.wf.tree[n].ob_state;
			W[i].str.wf.tree[n].ob_state^=SELECTED;
			sel2=W[i].str.wf.tree[n].ob_state;
			wind_update(BEG_UPDATE);
			_coord(W[i].str.wf.tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(i,W[i].str.wf.tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_UPDATE);
			if (mk>0)
				graf_mkstate(&mx,&my,&mk,&dum);
			while (mk>0)
			{
				sel=W[i].str.wf.tree[n].ob_state;
				graf_mkstate(&mx,&my,&mk,&dum);
				if (objc_find(W[i].str.wf.tree,ROOT,MAX_DEPTH,mx,my)==n)
					sel=sel2;
				else
					sel=sel1;
				if (W[i].str.wf.tree[n].ob_state!=sel)
				{
					W[i].str.wf.tree[n].ob_state=sel;
					_coord(W[i].str.wf.tree,n,TRUE,&obx,&oby,&obw,&obh);
					wind_update(BEG_UPDATE);
					_winObdraw(i,W[i].str.wf.tree,n,MAX_DEPTH,obx,oby,obw,obh);
					wind_update(END_UPDATE);
				}
			}
			_clicRSC(W[i].id,n,nmb);
			if (flags&EXIT && W[i].str.wf.tree[n].ob_state&SELECTED)
	/*		{
				W[i].str.wf.tree[n].ob_state&=~SELECTED;*/
				_winClose(i);
/*			}*/
		}

		/*	Cas d'un bouton SELECTABLE et RADIO BUTTON	*/
		else if (flags&SELECTABLE && flags&RBUTTON && !(state&DISABLED))
		{
			while (mk>0)
				graf_mkstate(&dum,&dum,&mk,&dum);
			a=_father(W[i].str.wf.tree,n);
			b=W[i].str.wf.tree[a].ob_head;
			a=W[i].str.wf.tree[a].ob_tail;
			do
			{
				if (W[i].str.wf.tree[b].ob_flags&RBUTTON && b!=n && W[i].str.wf.tree[b].ob_state&SELECTED)
				{
					W[i].str.wf.tree[b].ob_state&=~SELECTED;
					_coord(W[i].str.wf.tree,b,TRUE,&obx,&oby,&obw,&obh);
					wind_update(BEG_UPDATE);
					_winObdraw(i,W[i].str.wf.tree,b,MAX_DEPTH,obx,oby,obw,obh);
					wind_update(END_UPDATE);
				}
				b=W[i].str.wf.tree[b].ob_next;
			} while (b<=a && b>W[i].str.wf.tree[a].ob_next);
			if (!(W[i].str.wf.tree[n].ob_state&SELECTED))
			{
				W[i].str.wf.tree[n].ob_state^=SELECTED;
				_coord(W[i].str.wf.tree,n,TRUE,&obx,&oby,&obw,&obh);
				wind_update(BEG_UPDATE);
				_winObdraw(i,W[i].str.wf.tree,n,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_UPDATE);
			}
			_clicRSC(W[i].id,n,nmb);
		}

		/*	Cas d'un bouton TOUCHEXIT	*/
		else if (flags&TOUCHEXIT && !(flags&SELECTABLE))
		{
			do
			{
				obj=W[i].str.wf.tree;
				graf_mkstate(&mx,&my,&mk,&dum);
				if ((obj[n].ob_type&0xFF00)==USD_NUM)
				{
					if (mk&2)
						d=10*user->user3;
					else
						d=user->user3;
					c=user->user4;
					_coord(obj,n,FALSE,&obx,&oby,&obw,&obh);
					if (mx<=obx+glb.rsc.head.trindex[FUSER][FUSDLAR].ob_width)
					{
						if (user->user4>=user->user1+d)
							c=user->user4-d;
						else
							c=user->user1;
					}
					if (mx>=obx+obw-glb.rsc.head.trindex[FUSER][FUSDRAR].ob_width)
					{
						if (user->user4<=user->user2-d)
							c=user->user4+d;
						else
							c=user->user2;
					}
					if (c!=user->user4)
					{
						user->user4=c;
						c=1;
						sprintf((char *)(user->spec),"%u",user->user4);
						wind_update(BEG_UPDATE);
						_winObdraw(i,obj,n,MAX_DEPTH,obx,oby,obw,obh);
						wind_update(END_UPDATE);
					}
					else
						c=0;
				}
				else
					c=1;
				if (c)
				{
					_clicRSC(W[i].id,n,nmb);
					switch (mk)
					{
						case	2:
						case	3:
							evnt_timer(75,0);
							break;
						case	1:
							evnt_timer(40,0);
							break;
					}
				}
			}	while (mk>0 && objc_find(W[i].str.wf.tree,ROOT,MAX_DEPTH,mx,my)==n);
		}

		if (flags&EXIT && W[i].str.wf.tree[n].ob_state&SELECTED && !(W[i].xgadget&W_MODAL))
			W[i].str.wf.tree[n].ob_state&=~SELECTED;
	}
}
#pragma warn +par


/*******************************************************************************
	Redessin d'une objet RSC dans une fenˆtre formulaire
*******************************************************************************/
void _winObdraw(int i,OBJECT *tree,int obj, int dept, int x,int y,int w,int h)
{
	GRECT		rd,r;
	int		dum,f=FALSE,ha=W[i].handle;

	if (i!=-1)
		if (W[i].type==TW_FORM)
		{
			graf_mouse(M_OFF,0);
			rd.g_x=x;
			rd.g_y=y;
			rd.g_w=w;
			rd.g_h=h;

			wind_get(ha,WF_FIRSTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
			while (r.g_w && r.g_h)
			{
				if (_rcIntersect(&rd,&r))
				{
					if (W[i].str.wf.obj!=-1 && glb.aes.top==W[i].handle && !f)
					{
						dum=W[i].str.wf.pos;
						objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&dum,ED_CLIP|ED_END);
					}

					if ( (tree[obj].ob_type&0xFF)==G_CICON || ( (tree[obj].ob_type&0xFF)==G_USERDEF &&
						((UBLK *)tree[obj].ob_spec.userblk->ub_parm)->type==G_CICON) )
						objc_draw(tree,ROOT,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					else
						objc_draw(tree,obj,dept,r.g_x,r.g_y,r.g_w,r.g_h);

					if (W[i].str.wf.obj!=-1 && glb.aes.top==W[i].handle && !f)
					{
						objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
						f=TRUE;
					}
				}
				wind_get(ha,WF_NEXTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
			}
			graf_mouse(M_ON,0);
		}
}


/*******************************************************************************
	This function returns the object number & cursor pos in EDITABLE obj
*******************************************************************************/
void _whichEdit(int i,int *obj,int *pos)
{
	*obj=*pos=-1;
	if (i!=-1)
		if (W[i].type==TW_FORM)
		{
			*pos=W[i].str.wf.pos;
			*obj=W[i].str.wf.obj;
		}
}

void _setEdit(int i,int obj,int pos)
{
	int		type;

	if (i!=-1)
		if (W[i].type==TW_FORM)
		{
			type=((UBLK *)W[i].str.wf.tree[obj].ob_spec.userblk->ub_parm)->type;
			if (W[i].str.wf.obj!=obj || W[i].str.wf.pos!=pos)
				if ((type==G_FTEXT || type==G_FBOXTEXT) && W[i].str.wf.tree[obj].ob_flags&EDITABLE && !(W[i].str.wf.tree[obj].ob_state&DISABLED))
				{
					objc_draw(W[i].str.wf.tree,W[i].str.wf.obj,0,W[i].str.wf.tree->ob_x,W[i].str.wf.tree->ob_y,W[i].str.wf.tree->ob_width,W[i].str.wf.tree->ob_height);
					W[i].str.wf.obj=obj;
					W[i].str.wf.pos=min(pos,(int)strlen(((TEDINFO *)W[i].str.wf.tree[W[i].str.wf.obj].ob_spec.tedinfo)->te_ptext));
					objc_edit(W[i].str.wf.tree,W[i].str.wf.obj,0,&W[i].str.wf.pos,ED_CLIP|ED_INIT);
				}
		}
}
