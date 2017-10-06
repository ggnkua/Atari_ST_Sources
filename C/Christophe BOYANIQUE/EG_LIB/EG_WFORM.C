/******************************************************************************/
/*	"Easy Gem" library Copyright (c)1994 by		Christophe BOYANIQUE				*/
/*																29 Rue RÇpublique					*/
/*																37230 FONDETTES					*/
/*																FRANCE								*/
/*						*small* mail at email adress:	cb@spia.univ-tours.fr			*/
/******************************************************************************/
/*	This program is free software; you can redistribute it and/or modify it		*/
/*	under the terms of the GNU General Public License as published by the Free	*/
/*	Software Foundation; either version 2 of the License, or any later version.*/
/*	This program is distributed in the hope that it will be useful, but WITHOUT*/
/*	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or		*/
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for	*/
/*	more details.																					*/
/*	You should have received a copy of the GNU General Public License along		*/
/*	with this program; if not, write to the Free Software Foundation, Inc.,		*/
/*	675 Mass Ave, Cambridge, MA 02139, USA.												*/
/******************************************************************************/
/*																										*/
/*	FORMULAR WINDOWS HANDLING																	*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	FUNCTIONS																						*/
/******************************************************************************/
static	void	_myInitFonte	(int n);
static	void	_myInitOptions	(int n);
static	void	_myInitMemoire	(int n);
static	void	_myInitSysteme	(int n);
static	void	_myClic			(int obj,int n,int nmb);
static	void	_myClicInfo		(int n,int nmb);
static	void	_myClicFonte	(int n,int nmb);
static	void	_myClicOptions	(int n,int nmb);
static	void	_myClicMemoire	(int n,int nmb);
static	void	_myClicSysteme	(int n,int nmb);


/******************************************************************************/
/*	uninits a Wform window: free memory														*/
/******************************************************************************/
void _closeForm(int i)
{
	_mFree(W[i].in);
	W[i].in=NO_MEMORY;
}


/******************************************************************************/
/*	Handle keyboard events for WForm window												*/
/******************************************************************************/
void _keybdForm(int i,int key)
{
	int			child,type;
	int			j,k;
	int			x,y;
	WFORM			*str;
	UBLK			*user;
	TEDINFO		*ted;
	uchar			*p,*q,*trait;

	if (i!=-1)
	{
		str=(WFORM *)mem.bloc[W[i].in].adr;
		child=0;
		do
		{
			child+=1;
			if (__std)
			{
				type=str->tree[child].ob_type;
				if ( !(str->tree[child].ob_state&DISABLED) )
				{
					if ( (str->tree[child].ob_flags&DEFAULT) && ( ((key&0xFF)==K_RET) ))
					{
						objc_offset(str->tree,child,&x,&y);
						_clicForm(i,x,y,-1,1);
						__std=0;
						if (W[i].in==NO_MEMORY)
							return;
					}
					else
					{
						p=NULL;
						switch	(type&0xFF)
						{
							case	G_BUTTON:
							case	G_STRING:
								p=(uchar *)str->tree[child].ob_spec.free_string;
								break;
							case	G_TEXT:
							case	G_FTEXT:
							case	G_BOXTEXT:
							case	G_FBOXTEXT:
								p=(uchar *)str->tree[child].ob_spec.tedinfo->te_ptext;
								break;
							case	G_USERDEF:
								user=(UBLK *)(str->tree[child].ob_spec.userblk->ub_parm);
								switch	(user->type)
								{
									case	G_BUTTON:
									case	G_STRING:
										p=(uchar *)user->spec;
										break;
									case	G_TEXT:
									case	G_FTEXT:
									case	G_BOXTEXT:
									case	G_FBOXTEXT:
									p=(uchar *)((TEDINFO *)user->spec)->te_ptext;
										break;
								}
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
									if ( toupper(key&0xFF)==toupper(*trait) )
									{
										if ( (str->obj==-1) || (key&KF_ALT) )
										{
											objc_offset(str->tree,child,&x,&y);
											_clicForm(i,x,y,-1,1);
											__std=0;
											if (W[i].in==NO_MEMORY)
												return;
										}
									}
								}
							}
						}
					}
				}
			}
		} while ( (!(str->tree[child].ob_flags&LASTOB)) && __std );
		key=__std;
		if ( str->obj!=-1 && __std )
		{
			if ( str->tree[str->obj].ob_flags&EDITABLE && !(str->tree[str->obj].ob_state&DISABLED) )
			{
				user=(UBLK *)str->tree[str->obj].ob_spec.userblk->ub_parm;
				ted=(TEDINFO *)user->spec;
				if (key&KF_FUNC)
				{
					switch	(key&0xFF)
					{
						case	K_ESC:
							if (strlen(ted->te_ptext))
							{
								ted->te_ptext[0]=0;
								str->pos=0;
								objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
								_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
							}
							__std=0;
							break;
						case	K_BS:
							if ( (str->pos>0) && (strlen(ted->te_ptext)) )
							{
								p=(uchar *)ted->te_ptext;
								p+=str->pos-1;
								*p=0;
								p+=1;
								while (*p!=0)
								{
									strncat(ted->te_ptext,(char *)p,1);
									p+=1;
								}
								str->pos-=1;
								objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
								_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
							}
							__std=0;
							break;
						case	K_DEL:
							if ( (str->pos<strlen(ted->te_ptext)) && (strlen(ted->te_ptext)) )
							{
								p=(uchar *)ted->te_ptext;
								p+=str->pos;
								*p=0;
								p+=1;
								while (*p!=0)
								{
									strncat(ted->te_ptext,(char *)p,1);
									p+=1;
								}
								objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
								_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
							}
							__std=0;
							break;
						case	K_LEFT:
							if (str->pos)
							{
								if (key&KF_SHIFT)
									str->pos=0;
								else if (key&KF_CTRL)
								{
									trait=(uchar *)((long)_obGetStr(str->tree,str->obj)+(long)str->pos);
									p=q=(uchar *)_obGetStr(str->tree,str->obj);
									while ( (long)p < (long) trait )
									{
										q=p;
										if (*p!=' ')
											while ( (*p!=0) && (*p!=' ') )
												p++;
										while ( (*p!=0) && (*p==' ') )
											p++;
									}
									str->pos+=(int)( (long)q - (long)_obGetStr(str->tree,str->obj)-(long)str->pos );
								}
								else
									str->pos-=1;
								objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
								_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
							}
							__std=0;
							break;
						case	K_RIGHT:
							if ( (str->pos<strlen(ted->te_ptext)) && (strlen(ted->te_ptext)) )
							{
								if (key&KF_SHIFT)
									str->pos=(int)strlen(_obGetStr(str->tree,str->obj));
								else if (key&KF_CTRL)
								{
									p=(uchar *)((long)_obGetStr(str->tree,str->obj)+(long)str->pos);
									if (*p!=' ')
										while ( (*p!=0) && (*p!=' ') )
											p++;
									while ( (*p!=0) && (*p==' ') )
										p++;
									str->pos+=(int)( (long)p-(long)_obGetStr(str->tree,str->obj)-(long)str->pos );
								}
								else
									str->pos+=1;
								objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
								_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
							}
							__std=0;
							break;
						case	K_UP:
							k=str->obj;
							j=str->obj;
							do
							{
								if ((str->tree[k].ob_type&0xFF)==G_USERDEF)
								{
									x=((UBLK *)str->tree[k].ob_spec.userblk->ub_parm)->type;
									if ( (x==G_FTEXT || x==G_FBOXTEXT) && str->tree[k].ob_flags&EDITABLE && !(str->tree[k].ob_state&DISABLED) )
										j=k;
								}
								if (str->tree[k].ob_flags&LASTOB)
									k=ROOT;
								else
									k++;
							}
							while (k!=str->obj);
							if (j!=str->obj)
							{
								objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
								str->obj=j;
								user=(UBLK *)str->tree[str->obj].ob_spec.userblk->ub_parm;
								ted=(TEDINFO *)user->spec;
								str->pos=(int)strlen(ted->te_ptext);
								_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
								__std=0;
							}
							break;
						case	K_TAB:
						case	K_DOWN:
						case	K_RET:
							if ( (key&0xFF) == K_RET )
							{
								if (W[i].id&FLAGS15)
									_myClic(W[i].id,str->obj,0);
								else if (glb.FclicF!=0)
									(*glb.FclicF)(W[i].id,str->obj,0);
							}
							str=(WFORM *)mem.bloc[W[i].in].adr;
							k=str->obj;
							j=-1;
							do
							{
								if (str->tree[k].ob_flags&LASTOB)
									k=ROOT;
								else
									k++;
								if ((str->tree[k].ob_type&0xFF)==G_USERDEF)
								{
									x=((UBLK *)str->tree[k].ob_spec.userblk->ub_parm)->type;
									if ( (x==G_FTEXT || x==G_FBOXTEXT) && str->tree[k].ob_flags&EDITABLE && !(str->tree[k].ob_state&DISABLED) )
										j=k;
								}
							}
							while (j==-1);
							if (j!=str->obj)
							{
								objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
								str->obj=j;
								user=(UBLK *)str->tree[str->obj].ob_spec.userblk->ub_parm;
								ted=(TEDINFO *)user->spec;
								str->pos=(int)strlen(ted->te_ptext);
								_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
								__std=0;
							}
							break;
					}
				}
				else if ((key&0xFF)>31)
				{
					_objcEdit(str->tree,str->obj,key&0xFF,&str->pos,ED_CLIP|ED_CHAR);
					objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
					_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
				}
			}
			else
			{
				k=str->obj;
				j=-1;
				do
				{
					if (str->tree[k].ob_flags&LASTOB)
						k=ROOT;
					else
						k++;
					if ((str->tree[k].ob_type&0xFF)==G_USERDEF)
					{
						x=((UBLK *)str->tree[k].ob_spec.userblk->ub_parm)->type;
						if ( (x==G_FTEXT || x==G_FBOXTEXT) && str->tree[k].ob_flags&EDITABLE && !(str->tree[k].ob_state&DISABLED) )
							j=k;
					}
				}	while (j==-1 && k!=str->obj);
				if (j!=str->obj)
				{
					objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
					str->obj=j;
					user=(UBLK *)str->tree[str->obj].ob_spec.userblk->ub_parm;
					ted=(TEDINFO *)user->spec;
						str->pos=(int)strlen(ted->te_ptext);
					_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
				}
				else
				{
					objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
					str->obj=-1;
					str->pos=-1;
				}
			}
		}
	}
}


/******************************************************************************/
/*	Redraws a Form in a window																	*/
/******************************************************************************/
void _redrawForm(int i,int x,int y,int w,int h)
{
	WFORM		*str;
	GRECT		obj,clip;

	if (i!=-1)
	{
		str=(WFORM *)mem.bloc[W[i].in].adr;
		str->tree->ob_x=W[i].xwork;
		str->tree->ob_y=W[i].ywork;
		objc_draw(str->tree,ROOT,MAX_DEPTH,x,y,w,h);
		if (str->obj!=-1)
		{
			_coord(str->tree,str->obj,FALSE,&obj.g_x,&obj.g_y,&obj.g_w,&obj.g_h);
			clip.g_x=x;
			clip.g_y=y;
			clip.g_w=w;
			clip.g_h=h;
			if (_rcIntersect(&obj,&clip))
			{
				_setClip(TRUE,&clip);
				_objcEdit(str->tree,str->obj,0,&str->pos,ED_INIT);
				_setClip(FALSE,&clip);
			}
		}
	}
}


/******************************************************************************/
/*	Move a WForm window																			*/
/******************************************************************************/
#pragma warn -par
void _moveForm(int i,int x,int y)
{
	WFORM		*str;

	if (i!=-1)
	{
		str=(WFORM *)mem.bloc[W[i].in].adr;
		str->tree->ob_x=W[i].xwork;
		str->tree->ob_y=W[i].ywork;
	}
}
#pragma warn +par


/******************************************************************************/
/*	Handles button events on a WForm window												*/
/******************************************************************************/
#pragma warn -par
void _clicForm(int i,int x,int y,int k,int nmb)
{
	int			n,pop,rpop,mx=0,my=0,mk,sel,sel1,sel2,a,b;
	int			flags,state;
	int			top;
	int			obx,oby,obw,obh,dum;
	uchar			*p;
	OBJECT		*obj;
	WFORM			*str;
	UBLK			*user=NULL;

	if (k==-1)
		mk=0;
	else
		mk=k;

	if (i!=-1)
	{
		str=(WFORM *)mem.bloc[W[i].in].adr;
		str->tree->ob_x=W[i].xwork;
		str->tree->ob_y=W[i].ywork;		
		n=objc_find(str->tree,ROOT,MAX_DEPTH,x,y);
		if (n!=-1)
		{
			flags=str->tree[n].ob_flags;
			state=str->tree[n].ob_state;
			if ((str->tree[n].ob_type&0xFF)==G_USERDEF)
				user=(UBLK *)(str->tree[n].ob_spec.userblk->ub_parm);

			/*	Cas d'un POP UP MENU	*/
			if ( ((str->tree[n].ob_type&0xFF00)==USD_POPUP) && !(state&DISABLED) )
			{
				pop	=	user->user1;
				rpop	=	user->user4;
				if ( (k!=-1) && (pop!=-1) )
				{
					str->tree[n].ob_state|=SELECTED;
					wind_update(BEG_MCTRL);
					_coord(str->tree,n,TRUE,&obx,&oby,&obw,&obh);
					_winObdraw(i,str->tree,n,MAX_DEPTH,obx,oby,obw,obh);
					if (pop&FLAGS15)
						rpop=_formMenu(str->tree,n,__rsc.head.trindex[pop-FLAGS15],1,-rpop,0)-1;
					else
						rpop=_formMenu(str->tree,n,glb.rsc.head.trindex[pop],1,-rpop,0)-1;
					str=(WFORM *)mem.bloc[W[i].in].adr;
					str->tree[n].ob_state&=~SELECTED;
					_coord(str->tree,n,TRUE,&obx,&oby,&obw,&obh);
					_winObdraw(i,str->tree,n,MAX_DEPTH,obx,oby,obw,obh);
					wind_update(END_MCTRL);
					if (rpop!=-2)
					{
						user->user4=rpop;
						if (pop&FLAGS15)
							obj=__rsc.head.trindex[pop-FLAGS15];
						else
							obj=glb.rsc.head.trindex[pop];
						p=(uchar *)_obGetStr(obj,rpop+1);
						if (!(str->tree[n].ob_state&STATE8))
							_obPutStr(str->tree,n,(char *)p);
						if (W[i].id&FLAGS15)
							_myClic(W[i].id,n,nmb);
						else if (glb.FclicF!=0)
							(*glb.FclicF)(W[i].id,n,nmb);
					}
					wind_update(BEG_UPDATE);
					graf_mouse(M_OFF,0);
					str->tree[n].ob_state&=~SELECTED;
					_coord(str->tree,n,TRUE,&obx,&oby,&obw,&obh);
					_winObdraw(i,str->tree,n,MAX_DEPTH,obx,oby,obw,obh);
					graf_mouse(M_ON,0);
					wind_update(END_UPDATE);
				}
			}

			/*	Cas d'un EXTENDED POP UP MENU	*/
			else if ( ((str->tree[n].ob_type&0xFF00)==USD_XPOPUP) && !(state&DISABLED) )
			{
				rpop=user->user4;
				if ( (k!=-1) && (pop!=-1) )
				{
					str->tree[n].ob_state|=SELECTED;
					wind_update(BEG_MCTRL);
					_coord(str->tree,n,TRUE,&obx,&oby,&obw,&obh);
					_winObdraw(i,str->tree,n,MAX_DEPTH,obx,oby,obw,obh);
					if (pop&FLAGS15)
						rpop=_formXmenu(str->tree,n,(char *)user->userl,user->user1,user->user2,user->user3,user->user4);
					else
						rpop=_formXmenu(str->tree,n,(char *)user->userl,user->user1,user->user2,user->user3,user->user4);
					str=(WFORM *)mem.bloc[W[i].in].adr;
					str->tree[n].ob_state&=~SELECTED;
					_coord(str->tree,n,TRUE,&obx,&oby,&obw,&obh);
					_winObdraw(i,str->tree,n,MAX_DEPTH,obx,oby,obw,obh);
					wind_update(END_MCTRL);
					if (rpop!=-1)
					{
						user->user4=rpop;
						p=(uchar *)((long)user->userl+(long)rpop*(long)(user->user2+user->user3)+user->user3);
						pop=(int)*p;
						*p=0;
						if (!(str->tree[n].ob_state&STATE8))
							_obPutStr(str->tree,n,(char *)(user->userl+(long)rpop*(long)(user->user2+user->user3)));
						*p=(char)pop;
						if (W[i].id&FLAGS15)
							_myClic(W[i].id,n,nmb);
						else if (glb.FclicF!=0)
							(*glb.FclicF)(W[i].id,n,nmb);
					}
					wind_update(BEG_UPDATE);
					graf_mouse(M_OFF,0);
					str->tree[n].ob_state&=~SELECTED;
					_coord(str->tree,n,TRUE,&obx,&oby,&obw,&obh);
					_winObdraw(i,str->tree,n,MAX_DEPTH,obx,oby,obw,obh);
					graf_mouse(M_ON,0);
					wind_update(END_UPDATE);
				}
			}

			/*	Cas d'un EDITABLE	*/
			else if ( (flags&EDITABLE) && !(state&DISABLED) )
			{
				wind_get(0,WF_TOP,&top);
				if (top==W[i].handle)
				{
					wind_update(BEG_MCTRL);
					graf_mouse(M_OFF,0);
					a=str->obj;
					if (str->obj!=n)
						str->pos=(int)strlen(((TEDINFO *)user->spec)->te_ptext);
					str->obj=n;
					_coord(str->tree,a,FALSE,&obx,&oby,&obw,&obh);
					_winObdraw(i,str->tree,a,MAX_DEPTH,obx,oby,obw,obh);
					_coord(str->tree,str->obj,FALSE,&obx,&oby,&obw,&obh);
					a=_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
					b=0;
					graf_mkstate(&x,&y,&k,&dum);
					if (a>x)
					{
						while ( (k) && (a>x) && (a!=b) )
						{
							b=a;
							str->pos=max(0,str->pos-1);
							a=_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
							graf_mkstate(&x,&y,&k,&dum);
						}
					}
					else
					{
						while ( (k) && (a<x) && (a!=b) )
						{
							b=a;
							str->pos=min((int)strlen(((TEDINFO *)user->spec)->te_ptext),str->pos+1);
							a=_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
							graf_mkstate(&x,&y,&k,&dum);
						}
					}
					_winObdraw(i,str->tree,str->obj,MAX_DEPTH,obx,oby,obw,obh);
					do
						graf_mkstate(&dum,&dum,&k,&dum);
					while (k);
					graf_mouse(M_ON,0);
					wind_update(END_MCTRL);
				}
			}

			/*	Cas d'un bouton SELECTABLE et NON RADIO BUTTON	*/
			else if ( (flags&SELECTABLE) && !(state&DISABLED) && !(flags&RBUTTON) )
			{
				sel1=str->tree[n].ob_state;
				str->tree[n].ob_state^=SELECTED;
				sel2=str->tree[n].ob_state;
				graf_mouse(M_OFF,0);
				wind_update(BEG_UPDATE);
				_coord(str->tree,n,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,str->tree,n,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_UPDATE);
				graf_mouse(M_ON,0);
				if (mk>0)
					graf_mkstate(&mx,&my,&mk,&dum);
				while (mk>0)
				{
					sel=str->tree[n].ob_state;
					graf_mkstate(&mx,&my,&mk,&dum);
					if (objc_find(str->tree,ROOT,MAX_DEPTH,mx,my)==n)
						sel=sel2;
					else
						sel=sel1;
					if (str->tree[n].ob_state!=sel)
					{
						str->tree[n].ob_state=sel;
						_coord(str->tree,n,TRUE,&obx,&oby,&obw,&obh);
						graf_mouse(M_OFF,0);
						wind_update(BEG_UPDATE);
						_winObdraw(i,str->tree,n,MAX_DEPTH,obx,oby,obw,obh);
						wind_update(END_UPDATE);
						graf_mouse(M_ON,0);
					}
				}
				if (W[i].id&FLAGS15)
					_myClic(W[i].id,n,nmb);
				else if (glb.FclicF!=0)
					(*glb.FclicF)(W[i].id,n,nmb);
			}

			/*	Cas d'un bouton SELECTABLE et RADIO BUTTON	*/
			else if ( (flags&(SELECTABLE|RBUTTON)) && !(state&DISABLED) )
			{
				while (mk>0)
					graf_mkstate(&dum,&dum,&mk,&dum);
				a=_father(str->tree,n);
				b=str->tree[a].ob_head;
				a=str->tree[a].ob_tail;
				do
				{
					if ((str->tree[b].ob_flags & RBUTTON) && (b!=n) && (str->tree[b].ob_state & SELECTED))
					{
						str->tree[b].ob_state&=~SELECTED;
						_coord(str->tree,b,TRUE,&obx,&oby,&obw,&obh);
						graf_mouse(M_OFF,0);
						wind_update(BEG_UPDATE);
						_winObdraw(i,str->tree,b,MAX_DEPTH,obx,oby,obw,obh);
						wind_update(END_UPDATE);
						graf_mouse(M_ON,0);
					}
					b=str->tree[b].ob_next;
				} while ((b<=a) && (b>str->tree[a].ob_next));

				if ( !(str->tree[n].ob_state&SELECTED) )
				{
					str->tree[n].ob_state^=SELECTED;
					_coord(str->tree,n,TRUE,&obx,&oby,&obw,&obh);
					graf_mouse(M_OFF,0);
					wind_update(BEG_UPDATE);
					_winObdraw(i,str->tree,n,MAX_DEPTH,obx,oby,obw,obh);
					wind_update(END_UPDATE);
					graf_mouse(M_ON,0);
				}
				if (W[i].id&FLAGS15)
					_myClic(W[i].id,n,nmb);
				else if (glb.FclicF!=0)
					(*glb.FclicF)(W[i].id,n,nmb);
			}

			/*	Cas d'un bouton TOUCHEXIT	*/
			else if ( (flags&TOUCHEXIT) && !(flags&SELECTABLE) )
			{
				pop=0;
				do
				{
					graf_mkstate(&dum,&dum,&mk,&dum);
					if (W[i].id&FLAGS15)
						_myClic(W[i].id,n,nmb);
					else if (glb.FclicF!=0)
						(*glb.FclicF)(W[i].id,n,nmb);
					pop+=1;
					switch (mk)
					{
						case	1:	evnt_timer(100,0);	break;
						case	2:	evnt_timer(50,0);		break;
						case	3:	evnt_timer(25,0);		break;
					}
				}	while ( (mk>0) && (objc_find(str->tree,ROOT,MAX_DEPTH,mx,my)==n) );
			}

			if ( (flags&EXIT) && (str->tree[n].ob_state&SELECTED) )
			{
				str->tree[n].ob_state^=SELECTED;
				_closed(i);
			}
		}
	}
}
#pragma warn +par


/******************************************************************************/
/*	Redraw an object in a WForm 																*/
/******************************************************************************/
void _winObdraw(int i,OBJECT *tree,int obj, int dept, int x,int y,int w,int h)
{
	GRECT		rd,r;
	WFORM		*str=NULL;
	int		ha=W[i].handle;

	if (i!=-1)
	if (W[i].type==TW_FORM)
	{
		str=(WFORM *)mem.bloc[W[i].in].adr;
		rd.g_x=x;
		rd.g_y=y;
		rd.g_w=w;
		rd.g_h=h;

		wind_get(ha,WF_FIRSTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
		while (r.g_w && r.g_h)
		{
			if (_rcIntersect(&rd,&r))
			{
				if ( ((tree[obj].ob_type&0xFF)==G_CICON) || ( ((tree[obj].ob_type&0xFF)==G_USERDEF) &&
					((UBLK *)tree[obj].ob_spec.userblk->ub_parm)->type==G_CICON) )
					objc_draw(tree,ROOT,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
				else
					objc_draw(tree,obj,dept,r.g_x,r.g_y,r.g_w,r.g_h);

				if (str!=NULL)
					if (str->obj!=-1)
					{
						_setClip(TRUE,&r);
						_objcEdit(str->tree,str->obj,0,&str->pos,ED_INIT);
						_setClip(FALSE,&r);
					}
			}
			wind_get(ha,WF_NEXTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
		}
	}
}


/******************************************************************************/
/*	objc_edit clone: draw the | on an EDITABLE or handle key							*/
/******************************************************************************/
int _objcEdit(OBJECT *tree,int obj,int kc,int *idx,int mode)
{
	UBLK		*user;
	TEDINFO	*ted;
	GRECT		clip;
	uchar		*p,*q,*r,car[2];
	int		X,ret=0,dum,state,type,pnt,vect,ind,extent[8],pxy[4],lattr[6],tattr[10],x,y,w,h;

	_coord(tree,obj,FALSE,&clip.g_x,&clip.g_y,&clip.g_w,&clip.g_h);
	_coord(tree,obj,FALSE,&x,&y,&w,&h);
   vql_attributes(glb.hvdi,lattr);
	vsl_type(glb.hvdi,SOLID);
	vsl_width(glb.hvdi,1);
	vsl_color(glb.hvdi,BLACK);
   vqt_attributes(glb.hvdi,tattr);
	vswr_mode(glb.hvdi,MD_REPLACE);
	state=tree[obj].ob_state;
	type=tree[obj].ob_type>>8;
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dum,&dum);
	user=(UBLK *)tree[obj].ob_spec.userblk->ub_parm;
	ted=(TEDINFO *)user->spec;
	if (ted->te_font==3)
		pnt=10-2*glb.low;
	else
		pnt=8-glb.low;
	if (state&STATE10)
	{
		ind=glb.opt.GDfnt;
		if (type!=0)		pnt=type;
		if (pnt<12)			pnt=10-glb.low;
		else if (pnt<18)	pnt=12;
		else if (pnt<24)	pnt=18;
		else if (pnt<36)	pnt=24;
		else if (pnt<48)	pnt=36;
		else if (pnt<72)	pnt=48;
		else if (pnt<96)	pnt=72;
		else					pnt=96;
	}
	else if (state&STATE8)
	{
		ind=glb.opt.GIfnt;
		if (type!=0)		pnt=type;
		if (pnt<12)			pnt=10-glb.low;
		else if (pnt<18)	pnt=12;
		else if (pnt<24)	pnt=18;
		else if (pnt<36)	pnt=24;
		else if (pnt<48)	pnt=36;
		else if (pnt<72)	pnt=48;
		else if (pnt<96)	pnt=72;
		else					pnt=96;
	}
	else if (state&STATE11)
	{
		ind=glb.opt.HIfnt;
		if (type!=0)		pnt=type;
		if (pnt<12)			pnt=10-glb.low;
		else if (pnt<18)	pnt=12;
		else if (pnt<24)	pnt=18;
		else if (pnt<36)	pnt=24;
		else if (pnt<48)	pnt=36;
		else if (pnt<72)	pnt=48;
		else if (pnt<96)	pnt=72;
		else					pnt=96;
	}
	else if (state&STATE9)
		ind=1;
	else
		ind=glb.opt.Gfnt;
	if (glb.gdos)
		vst_font(glb.hvdi,font[ind].index);
	vect=font[ind].name[32];
	if (vect)
		vst_arbpt(glb.hvdi,pnt,&dum,&dum,&dum,&dum);
	else
		vst_point(glb.hvdi,pnt,&dum,&dum,&dum,&dum);
	car[1]=0;

	if (mode&ED_CLIP)
		_setClip(TRUE,&clip);

	switch	(mode&0xFF)
	{
		case	ED_INIT:
			p=(uchar *)ted->te_ptmplt;
			q=(uchar *)ted->te_ptext;
			*idx=min(*idx,(int)strlen((char *)q));
			w=0;
			do
			{
				if (*p=='_')
				{
					if (w==*idx)
					{
						pxy[0]=x;
						pxy[1]=y;
						pxy[2]=x;
						pxy[3]=y+h-1;
						v_pline(glb.hvdi,2,pxy);
						pxy[0]+=1;
						pxy[2]+=1;
						v_pline(glb.hvdi,2,pxy);
						ret=x;
					}
					if (*q==0)
						car[0]='_';
					else
						car[0]=*q;
					q++;
					w++;
				}
				else
					car[0]=*p;
				if (vect)
					vqt_f_extent(glb.hvdi,(char *)car,extent);
				else
					vqt_extent(glb.hvdi,(char *)car,extent);
				x+=extent[2]-extent[6];
				if (*p=='_')
					X=x;
				p++;
				if (*p==0)
					dum=1;
			}
			while ( (*p!=0) && (!ret) );
			if ( (!ret) && (w==*idx) )
			{
				pxy[0]=X;
				pxy[1]=y;
				pxy[2]=X;
				pxy[3]=y+h-1;
				v_pline(glb.hvdi,2,pxy);
				pxy[0]+=1;
				pxy[2]+=1;
				v_pline(glb.hvdi,2,pxy);
				ret=X;
			}
			break;
		case	ED_CHAR:
			dum=0;
			if ( strlen(ted->te_ptext) == ted->te_txtlen-1 )
				*idx-=1;
			switch	(ted->te_pvalid[*idx])
			{
				case	'9':
					if ( (kc>='0') && (kc<='9') )
						dum=1;
					break;
				case	'A':
					if ( (kc==' ') ||( (kc>='A') && (kc<='Z') ))
						dum=1;
					break;
				case	'a':
					if ( (kc==' ') || ((kc>='A')&&(kc<='Z')) || ((kc>='a')&&(kc<='z')) )
						dum=1;
					break;
				case	'N':
					if ( (kc==' ') || ((kc>='A')&&(kc<='Z')) || ((kc>='0')&&(kc<='9')) )
						dum=1;
					break;
				case	'n':
					if ( (kc==' ') || ((kc>='A')&&(kc<='Z')) || ((kc>='a')&&(kc<='z')) || ((kc>='0')&&(kc<='9')) )
						dum=1;
					break;
				case	'F':
					if ( (kc==' ') || ((kc>='0')&&(kc<='9')) || ((kc>='A')&&(kc<='Z'))
						|| (kc=='_') || (kc=='?') || (kc=='*') || (kc=='.') )
							dum=1;
					break;
				case	'f':
					if ( (kc==' ') || ((kc>='0')&&(kc<='9')) || ((kc>='A')&&(kc<='Z')) || (kc=='_') || (kc=='.') )
							dum=1;
					break;
				case	'P':
					if ( (kc==' ') || ((kc>='0')&&(kc<='9')) || ((kc>='A')&&(kc<='Z'))
						|| (kc=='_') || (kc=='?') || (kc=='*') || (kc=='\\') || (kc=='/') || (kc=='.') )
							dum=1;
					break;
				case	'p':
					if ( (kc==' ') || ((kc>='0')&&(kc<='9')) || ((kc>='A')&&(kc<='Z'))
						|| (kc=='_') || (kc=='\\') || (kc=='/') || (kc=='.') )
							dum=1;
					break;
				case	'X':
					dum=1;
			}
			if ( strlen(ted->te_ptext) == ted->te_txtlen-1 )
				if (dum)
					ted->te_ptext[ted->te_txtlen-2]=0;
				else
					*idx+=1;
			if (kc=='.')
			{
				p=(uchar *)ted->te_ptmplt;
				q=(uchar *)ted->te_ptext;
				w=0;
				do
				{
					if (*p=='_')
					{
						q++;
						w++;
					}
					p++;
				}	while ( (*p!=0) && (w<*idx) );
				r=(uchar *)strchr((char *)p,'.');
				if (r!=NULL)
				{
					ret=1;
					do
					{
						if (*p=='_')
						{
							*q++=' ';
							*q=0;
							w++;
							(*idx)+=1;
						}
						p++;
					}	while ( (*p!=0) && (p!=r) );
				}
			}

			if ( (dum) && (!ret) )
			{
				p=(uchar *)ted->te_ptext;
				p+=*idx;
				q=(uchar *)ted->te_ptext;
				q+=strlen((char *)q)+1;
				r=(uchar *)ted->te_ptext;
				r+=strlen((char *)r);
				while (p<q)
				{
					*q=*r;
					q--;
					r--;
				}
				*q=kc&0xFF;
				*idx+=1;
			}
			break;
	}

	if (mode&ED_CLIP)
		_setClip(FALSE,&clip);

	vswr_mode(glb.hvdi,tattr[5]);
	vsl_type(glb.hvdi,lattr[0]);
	vsl_color(glb.hvdi,lattr[1]);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment(glb.hvdi,tattr[3],tattr[4],&dum,&dum);
	if (glb.gdos)
		vst_font(glb.hvdi,tattr[0]);
	return ret;
}


/******************************************************************************/
/******************************************************************************/
int _winForm(int tree,char *name,char *sname,char *help,int popup,int icon)
{
	int			x,y,w,h,i=-1;
	OBJECT		*adr;
	char			buf[sizeof(window)];
	window		*win;
	WFORM			*str;
	int			obj=-1;
	int			dum,edt=-1;

	win=(window *)buf;

	if (tree&FLAGS15)
		adr=__rsc.head.trindex[tree&~FLAGS15];
	else
		adr=glb.rsc.head.trindex[tree];

	strcpy(win->name,name);
	strcpy(win->sname,sname);
	strcpy(win->help,help);

	win->gadget=	wNAME+wMOVE+wCLOSE+wCYCLE+wICON;

	for (dum=0;dum<glb.NMB_WDW;dum++)
		if ( (W[dum].type==TW_FORM) && (W[dum].id==tree) )
		{
			i=dum;
			dum=glb.NMB_WDW;
		}

	if (__x!=-1)
	{
		x=__x;
		y=__y;
		w=__w;
		h=__h;
	}
	else if (!glb.opt.mfrm)
		form_center(adr,&x,&y,&w,&h);
	else
	{
		if ( (i==-1) || (glb.opt.mfrm==2) )
		{
			graf_mkstate(&x,&y,&dum,&dum);
			w=adr->ob_width;
			h=adr->ob_height;
			x-=w/2;
			x=max(glb.xdesk,x);
			x=min(glb.xdesk+glb.wdesk-w,x);
			y-=h/2;
			y=max(glb.ydesk,y);
			y=min(glb.ydesk+glb.hdesk-h,y);
		}
		else
		{
			x=W[i].xwork;
			y=W[i].ywork;
			w=W[i].wwork;
			h=W[i].hwork;
		}
	}
	win->xwind=-1;
	win->xwork=win->xfull=x;
	win->ywork=win->yfull=y;
	win->wwork=win->wfull=adr->ob_width;
	win->hwork=win->hfull=adr->ob_height;

	win->popup		=	popup;
	win->icon		=	icon;
	win->type		=	TW_FORM;
	win->id			=	tree;

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
	win->closed		=	_closeForm;
	win->untop		=	0;

	if (tree&FLAGS15)
		win->pop=0;
	else
		win->pop=glb.fpop;

	if (popup!=-1)
		win->gadget+=wMENU;

	i=_winOpen(win);
	if (i!=-1)
	{
		W[i].in=_mAlloc((long)sizeof(WFORM),MB_NORM,0);
		if (W[i].in!=NO_MEMORY)
		{
			str=(WFORM *)mem.bloc[W[i].in].adr;
			str->pos=0;
			str->obj=-1;
			str->tree=adr;
			do
			{
				obj+=1;

				if ( (edt==-1) && (adr[obj].ob_flags&EDITABLE) && ((adr[obj].ob_type&0xFF)==G_USERDEF) )
				{
					dum=((UBLK *)adr[obj].ob_spec.userblk->ub_parm)->type;
					if ( (dum==G_FTEXT) || (dum==G_FBOXTEXT) )
						edt=obj;
				}
			}	while (!(adr[obj].ob_flags&LASTOB));
			str->obj		=	edt;
			if (str->obj!=-1)
				str->pos=(int)strlen(_obGetStr(adr,str->obj));
		}
		else
			_closed(i);
	}
	return i;
}


/******************************************************************************/
/*	Init lib windows																				*/
/******************************************************************************/
void _myInitForm(int obj,int n)
{
	switch	(obj&~FLAGS15)
	{
		case	FFNT:		_myInitFonte(n);		break;
		case	FOPT:		_myInitOptions(n);	break;
		case	FMEM:		_myInitMemoire(n);	break;
		case	FSYS:		_myInitSysteme(n);	break;
	}
}
static void _myInitFonte(int n)
{
	OBJECT	*tree=__rsc.head.trindex[FFNT];
	char		txt[4];

	switch	(n)
	{
		case	FFNTGPOP:
			if ( (glb.gdos) && (glb.nfont>1) )
				_initXPopUp(tree,n,(char *)font[1].name,glb.nfont,4,32,glb.opt.GIfnt-1);
			else
			{
				tree[n].ob_state|=DISABLED;
				_obPutStr(tree,n,"System Font");
			}
			break;
		case	FFNTGTYP:
			tree[n].ob_flags|=HIDETREE;
			if ( (glb.gdos) && (glb.nfont>1) )
				if (font[glb.opt.GIfnt].name[32])
					tree[n].ob_flags&=~HIDETREE;
			break;
		case	FFNTGNOM:
			if ( (!glb.gdos) || (glb.nfont<=1) )
				tree[n].ob_state|=DISABLED;
			((TEDINFO*)((UBLK *)tree[n].ob_spec.userblk->ub_parm)->spec)->te_font=3;
			break;
		case	FFNTHPOP:
			if ( (glb.gdos) && (glb.nfont>1) )
				_initXPopUp(tree,n,(char *)font[1].name,glb.nfont,4,32,glb.opt.HIfnt-1);
			else
			{
				tree[n].ob_state|=DISABLED;
				_obPutStr(tree,n,"System Font");
			}
			break;
		case	FFNTHTYP:
			tree[n].ob_flags|=HIDETREE;
			if ( (glb.gdos) && (glb.nfont>1) )
				if (font[glb.opt.HIfnt].name[32])
					tree[n].ob_flags&=~HIDETREE;
			break;
		case	FFNTHNOM:
			if ( (!glb.gdos) || (glb.nfont<=1) )
				tree[n].ob_state|=DISABLED;
			((TEDINFO*)((UBLK *)tree[n].ob_spec.userblk->ub_parm)->spec)->te_font=3;
			break;
		case	FFNTCTXT:
			_initPopUp(tree,n,PCOUL|FLAGS15,glb.opt.chlpt);
			break;
		case	FFNTCFON:
			_initPopUp(tree,n,PCOUL|FLAGS15,glb.opt.chlpf);
			break;
		case	FFNTHSIZ:
			sprintf(txt,"%i",glb.opt.hsiz);
			_obPutStr(tree,n,txt);
			break;
	}
}
static void _myInitOptions(int n)
{
	OBJECT	*tree=__rsc.head.trindex[FOPT];

	switch	(n)
	{
		case	FOPTFNT:
			if (glb.gdos)
			{
				if (glb.opt.font)
				{
					tree[n].ob_state|=SELECTED;
					glb.opt.Gfnt=glb.opt.GDfnt;
					glb.opt.GIfnt=glb.opt.GDfnt;
				}
				else
					tree[n].ob_state&=~SELECTED;
			}
			else
			{
				tree[n].ob_state|=DISABLED;
				glb.opt.GIfnt=1;
				glb.opt.Gfnt=1;
			}
			break;
		case	FOPTHLP:
			if (glb.gdos)
			{
				if (glb.opt.help)
					tree[n].ob_state|=SELECTED;
				else
					tree[n].ob_state&=~SELECTED;
			}
			else
			{
				tree[n].ob_state|=DISABLED;
				glb.opt.HIfnt=1;
				glb.opt.Hfnt=1;
			}
			break;
		case	FOPTPOP:
			if (glb.opt.popf)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTFUL:
			if (glb.opt.full)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTSAV:
			if (glb.opt.save)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTFRM1:
			if (glb.opt.mfrm==0)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTFRM2:
			if (glb.opt.mfrm==1)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTFRM3:
			if (glb.opt.mfrm==2)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTPHLP:
			_putPath(tree,n,34,glb.opt.phelp);
			break;
		case	FOPTFR:
			if (glb.opt.lang==L_FRENCH)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			_switchLang();
			if (glb.FLang!=0)
				(*glb.FLang)();
			break;
		case	FOPTEN:
			if (glb.opt.lang==L_ENGLISH)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			_switchLang();
			if (glb.FLang!=0)
				(*glb.FLang)();
			break;
	}
}
static void _myInitMemoire(int n)
{
	OBJECT	*tree=__rsc.head.trindex[FMEM];
	int		i;
	long		m;
	char		txt[30];

	switch	(n)
	{
		case	FMEMSYS:
			m=_freeSys()/1024L;
			if (glb.opt.lang==L_FRENCH)
				sprintf(txt,"Systäme:  %6li K",m);
			else
				sprintf(txt,"System:   %6li K",m);
			_obPutStr(tree,n,txt);
			break;
		case	FMEMLEN:
			m=0;
			for (i=0;i<MEM_NMB;i++)
				m+=mem.Blen[i];
			m/=1024L;
			sprintf(txt,"%li",m);
			_obPutStr(tree,n,txt);
			break;
		case	FMEMFRE:
			m=0;
			for (i=0;i<mem.n;i++)
				if (mem.bloc[i].type!=MB_IGNORE) m+=mem.bloc[i].len;
			m/=1024L;
			if (glb.opt.lang==L_FRENCH)
				sprintf(txt,"UtilisÇe: %6li K",m);
			else
				sprintf(txt,"Used:     %6li K",m);
			_obPutStr(tree,n,txt);
			break;
	}
}
static void _myInitSysteme(int n)
{
	OBJECT	*tree=__rsc.head.trindex[FSYS];
	char		txt[30];
	long		adr;
	int		dum;

	switch	(n)
	{
		case	FSYSMCH:
			switch	(glb.MCH)
			{
				case	0:		_obPutStr(tree,n,"ST");				break;
				case	1:		_obPutStr(tree,n,"STE");				break;
				case	2:		_obPutStr(tree,n,"MegaSTE");		break;
				case	3:		_obPutStr(tree,n,"TT");				break;
				case	4:		_obPutStr(tree,n,"Falcon030");		break;
				default:		_obPutStr(tree,n,"Inconnue");		break;
			}
			break;
		case	FSYSPROC:
			sprintf(txt,"%li",68000L+_cookie('_CPU'));
			switch	((int)_cookie('_FPU'))
			{
				case	1:		strcat(txt,"/SFP004");				break;
				case	2:		strcat(txt,"/6888?");				break;
				case	3:		strcat(txt,"/6888?/SFP004");		break;
				case	4:		strcat(txt,"/68881");				break;
				case	5:		strcat(txt,"/68881/SFP004");		break;
				case	6:		strcat(txt,"/68882");				break;
				case	7:		strcat(txt,"/68882/SFP004");		break;
				case	8:		strcat(txt,"/68040");				break;
				case	9:		strcat(txt,"/68040/SFP004");		break;
			}
			_obPutStr(tree,n,txt);
			break;
		case	FSYSREZ:
			if (glb.extnd[5])
				sprintf(txt,"%lix%lix%lic",(long)(1+glb.wscr),(long)(1+glb.hscr),1L<<min(24,glb.extnd[4]));
			else
				sprintf(txt,"%lix%li TRUE COLOR",(long)(1+glb.wscr),(long)(1+glb.hscr));
			_obPutStr(tree,n,txt);
			break;
		case	FSYSTOS:
			if ( (glb.vTOS&0xFF)<10 )
				sprintf(txt,"%x.0%x",glb.vTOS>>8,glb.vTOS&0xFF);
			else
				sprintf(txt,"%x.%x" ,glb.vTOS>>8,glb.vTOS&0xFF);
			_obPutStr(tree,n,txt);
			break;
		case	FSYSGDOS:
			switch	(glb.gdos)
			{
				case	0:		strcpy(txt,"No");			break;
				case	1:		strcpy(txt,"Yes");		break;
				case	2:		strcpy(txt,"Font");		break;
				case	3:		strcpy(txt,"FSM");		break;
				case	4:		strcpy(txt,"Speedo");	break;
				default:		strcpy(txt,"???");		break;
			}
			_obPutStr(tree,n,txt);
			break;
		case	FSYSAES:
			if ( (glb.vAES&0xFF)<10 )
				sprintf(txt,"%x.0%x",glb.vAES>>8,glb.vAES&0xFF);
			else
				sprintf(txt,"%x.%x" ,glb.vAES>>8,glb.vAES&0xFF);
			_obPutStr(tree,n,txt);
			break;
		case	FSYSMINT:
			dum=(int)_cookie('MiNT');
			if (dum==0)
				strcpy(txt,"No");
			else if ((dum&0xFF)<10)
				sprintf(txt,"%1x.0%1x",dum>>8,dum&0xFF);
			else
				sprintf(txt,"%1x.%2x" ,dum>>8,dum&0xFF);
			_obPutStr(tree,n,txt);
			break;
		case	FSYSNVDI:
			adr=_cookie('NVDI');
			if (adr)
				sprintf(txt,"%x.%02x" ,_CARD(adr)>>8,_CARD(adr)&0xFF);
			else
				strcpy(txt,"");
			_obPutStr(tree,n,txt);
			break;
		case	FSYSLET:
			adr=_cookie('LTMF');
			if (adr)
				sprintf(txt,"%x.%02x" ,_CARD(adr)>>8,_CARD(adr)&0xFF);
			else
				strcpy(txt,"");
			_obPutStr(tree,n,txt);
			break;
	}
}


/******************************************************************************/
/*	Handles lib windows clic																	*/
/******************************************************************************/
#pragma warn -par
static void _myClic(int obj,int n,int nmb)
{
	switch	(obj&~FLAGS15)
	{
		case	FFNT:		_myClicFonte(n,nmb);		break;
		case	FOPT:		_myClicOptions(n,nmb);	break;
		case	FMEM:		_myClicMemoire(n,nmb);	break;
		case	FSYS:		_myClicSysteme(n,nmb);	break;
	}
}
static void _myClicFonte(int n,int nmb)
{
	OBJECT	*tree;
	int		i;
	int		obx,oby,obw,obh;

	tree=__rsc.head.trindex[FFNT];
	switch	(n)
	{
		case	FFNTCTXT:
			i=_getPopUp(tree,n);
			if (i!=glb.opt.chlpt)
			{
				glb.opt.chlpt=i;
				i=_winFindId(TW_HELP,0,TRUE);
				_redraw(i,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			}
			break;
		case	FFNTCFON:
			i=_getPopUp(tree,n);
			if (i!=glb.opt.chlpf)
			{
				glb.opt.chlpf=i;
				i=_winFindId(TW_HELP,0,TRUE);
				_redraw(i,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			}
			break;

		case	FFNTGPOP:
			i=_getPopUp(tree,n)+1;
			if (i!=glb.opt.GIfnt)
			{
				glb.opt.GIfnt=i;
				tree[FFNTGTYP].ob_flags|=HIDETREE;
				if ( (glb.gdos) && (glb.nfont>1) )
					if (font[glb.opt.GIfnt].name[32])
						tree[FFNTGTYP].ob_flags&=~HIDETREE;
				i=_winFindId(TW_FORM,FFNT|FLAGS15,TRUE);
				wind_update(BEG_UPDATE);
				_coord(tree,FFNTGNOM,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,tree,FFNTGNOM,MAX_DEPTH,obx,oby,obw,obh);
				_coord(tree,FFNTGTYP,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,tree,ROOT,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_UPDATE);
			}
			break;
		case	FFNTGNOM:
			wind_update(BEG_UPDATE);
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FFNT|FLAGS15,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_UPDATE);
			tree[n].ob_state&=~SELECTED;
			if (glb.opt.font)
				glb.opt.Gfnt=glb.opt.GIfnt;
			glb.opt.GDfnt=glb.opt.GIfnt;
				for (i=0;i<glb.NMB_WDW;i++)
					if (W[i].handle>0)
						_redraw(i,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			break;
		case	FFNTHPOP:
			i=_getPopUp(tree,n)+1;
			if (i!=glb.opt.HIfnt)
			{
				glb.opt.HIfnt=i;
				tree[FFNTHTYP].ob_flags|=HIDETREE;
				if ( (glb.gdos) && (glb.nfont>1) )
					if (font[glb.opt.HIfnt].name[32])
						tree[FFNTHTYP].ob_flags&=~HIDETREE;
				i=_winFindId(TW_FORM,FFNT|FLAGS15,TRUE);
				wind_update(BEG_UPDATE);
				_coord(tree,FFNTHNOM,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,tree,FFNTHNOM,MAX_DEPTH,obx,oby,obw,obh);
				_coord(tree,FFNTHTYP,TRUE,&obx,&oby,&obw,&obh);
				_winObdraw(i,tree,ROOT,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_UPDATE);
			}
			break;
		case	FFNTHNOM:
			if (glb.opt.font)
				glb.opt.Hfnt=glb.opt.HIfnt;
			glb.opt.HDfnt=glb.opt.HIfnt;
			_initHelp();
			i=_winFindId(TW_HELP,0,TRUE);
			_redraw(i,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			tree[n].ob_state&=~SELECTED;
			wind_update(BEG_UPDATE);
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FFNT|FLAGS15,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_UPDATE);
			break;
		case	FFNTHSET:
			i=atoi(_obGetStr(tree,FFNTHSIZ));
			if ( (i>0) && (i!=glb.opt.hsiz) )
			{
				glb.opt.hsiz=i;
				_initHelp();
				i=_winFindId(TW_HELP,0,TRUE);
				_redraw(_winFindId(TW_HELP,0,TRUE),W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			}
			tree[n].ob_state&=~SELECTED;
			wind_update(BEG_UPDATE);
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FFNT|FLAGS15,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_UPDATE);
			break;
	}
}
static void _myClicOptions(int n,int nmb)
{
	OBJECT	*tree;
	int		i;
	int		obx,oby,obw,obh;

	tree=__rsc.head.trindex[FOPT];
	switch	(n)
	{
		case	FOPTPOP:
			glb.opt.popf=tree[n].ob_state&SELECTED;
			break;
		case	FOPTFNT:
			if (tree[n].ob_state&SELECTED)
			{
				glb.opt.font=1;
				glb.opt.Gfnt=glb.opt.GDfnt;
			}
			else
			{
				glb.opt.font=0;
				glb.opt.Gfnt=1;
			}
			for (i=0;i<glb.NMB_WDW;i++)
				if (W[i].handle>0)
					_redraw(i,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			break;
		case	FOPTHLP:
			if (tree[n].ob_state&SELECTED)
			{
				glb.opt.help=1;
				glb.opt.Hfnt=glb.opt.HDfnt;
			}
			else
			{
				glb.opt.help=0;
				glb.opt.Hfnt=1;
			}
			i=_winFindId(TW_HELP,0,TRUE);
			_redraw(_winFindId(TW_HELP,0,TRUE),W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			break;
		case	FOPTFUL:
			glb.opt.full=tree[n].ob_state&SELECTED;
			break;
		case	FOPTSAV:
			glb.opt.save=tree[n].ob_state&SELECTED;
			break;
		case	FOPTFRM1:
			if (tree[n].ob_state&SELECTED)
				glb.opt.mfrm=0;
			break;
		case	FOPTFRM2:
			if (tree[n].ob_state&SELECTED)
				glb.opt.mfrm=1;
			break;
		case	FOPTFRM3:
			if (tree[n].ob_state&SELECTED)
				glb.opt.mfrm=2;
			break;
		case	FOPTPHLP:
			if (tree[n].ob_state&SELECTED)
			{
				strcpy(pname,"");
				strcpy(fname,"");
				strcpy(pfname,glb.opt.phelp);
				if (glb.opt.lang==L_FRENCH)
					strcpy(ext,"*.H_F");
				else
					strcpy(ext,"*.H_E");
				strcpy(tit,"Help files directory:");
				wind_update(BEG_MCTRL);
				if (_fselect(pfname,pname,fname,ext,tit))
				{
					strcpy(glb.opt.phelp,pname);
					strcat(glb.opt.phelp,"\\");
				}
				_putPath(tree,n,34,glb.opt.phelp);
				tree[n].ob_state&=~SELECTED;
				wind_update(END_MCTRL);
				_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
				_winRedraw(_winFindId(TW_FORM,FOPT|FLAGS15,TRUE),obx,oby,obw,obh);
			}
			break;
		case	FOPTFR:
			if (glb.opt.lang!=L_FRENCH)
			{
				glb.opt.lang=L_FRENCH;
				_switchLang();
				if (glb.FLang!=0)
					(*glb.FLang)();
				for (i=0;i<glb.NMB_WDW;i++)
					if (W[i].handle>0)
						_redraw(i,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			}
			break;
		case	FOPTEN:
			if (glb.opt.lang!=L_ENGLISH)
			{
				glb.opt.lang=L_ENGLISH;
				_switchLang();
				if (glb.FLang!=0)
					(*glb.FLang)();
				for (i=0;i<glb.NMB_WDW;i++)
					if (W[i].handle>0)
						_redraw(i,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			}
			break;
	}
}
static void _myClicMemoire(int n,int nmb)
{
	OBJECT	*tree;
	long		len;
	int		obx,oby,obw,obh,dum;
	WFORM		*str;

	tree=__rsc.head.trindex[FMEM];
	switch	(n)
	{
		case	FMEMMOD:
		case	FMEMMIN:
		case	FMEMMAX:
			if (tree[n].ob_state&SELECTED)
			{
				tree[n].ob_state&=~SELECTED;
				wind_update(BEG_UPDATE);
				len=atol(_obGetStr(tree,FMEMLEN));
				len*=1024L;
				if (n==FMEMMOD)
					_pDim(len);
				else if (n==FMEMMIN)
					_pDim(0L);
				else
					_pDim(-1L);
				_myInitForm(FMEM,FMEMSYS);
				_myInitForm(FMEM,FMEMLEN);
				_myInitForm(FMEM,FMEMFRE);
				dum=_winFindId(TW_FORM,FMEM|FLAGS15,TRUE);
				if (dum!=-1)
				{
					str=(WFORM *)mem.bloc[W[dum].in].adr;
					if (str->obj==FMEMLEN)
						str->pos=(int)strlen(_obGetStr(tree,str->obj));
					_coord(tree,FMEMSYS,FALSE,&obx,&oby,&obw,&obh);
					_winObdraw(dum,tree,FMEMSYS,0,obx,oby,obw,obh);
					_coord(tree,FMEMLEN,FALSE,&obx,&oby,&obw,&obh);
					_winObdraw(dum,tree,FMEMLEN,0,obx,oby,obw,obh);
					_coord(tree,FMEMFRE,FALSE,&obx,&oby,&obw,&obh);
					_winObdraw(dum,tree,FMEMFRE,0,obx,oby,obw,obh);
					_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
					_winObdraw(dum,tree,n,0,obx,oby,obw,obh);
				}
				wind_update(END_UPDATE);
			}
			break;
	}
}
static void _myClicSysteme(int n,int nmb)
{
	OBJECT	*tree;
	int		obx,oby,obw,obh;

	tree=__rsc.head.trindex[FSYS];
	switch	(n)
	{
		case	FSYSFILE:
			if (tree[n].ob_state&SELECTED)
			{
				strcpy(pname,"");
				strcpy(fname,"");
				strcpy(pfname,glb.path);
				strcpy(ext,"*.TXT");
				strcpy(tit,"File to save debug infos:");
				wind_update(BEG_MCTRL);
				if (_fselect(pfname,pname,fname,ext,tit))
					_saveSys();
				tree[n].ob_state&=~SELECTED;
				_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
				_winRedraw(_winFindId(TW_FORM,FSYS|FLAGS15,TRUE),obx,oby,obw,obh);
				wind_update(END_MCTRL);
			}
			break;
	}
}
#pragma warn +par
