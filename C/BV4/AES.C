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

static void	_handleEvntKeybd(void);
static void	_handleEvntButton(void);
static void	_handleEvntBox1(void);
static void	_handleEvntBox2(void);
static void	_handleEvntMesag(void);
static void	_handleEvntTimer(void);
static void	_drawDeskIcon(OBJECT *tree,int n,int flag);
static void	_clicDesk(int mx,int my,int mk,int nmb,int kst);

/*******************************************************************************
	Gestion des Çvänements AES
*******************************************************************************/
void _gereAes()
{
	int	flag=0;

	/****************************************************************************
		Masque AES de base pour la gestion de la lib: MESAG|BUTTON|KEYBD|TIMER
	****************************************************************************/
	if	(!glb.aes.event.t1 && !glb.aes.event.t2)
		glb.aes.event.t1=1000;
	if (glb.aes.event.flag&MU_M1)
		flag|=MU_M1;
/*	if (glb.aes.event.flag&MU_M2)
		flag|=MU_M2;*/
	if (glb.aes.event.flag&MU_TIMER)
		flag|=MU_TIMER;
	flag|=MU_MESAG|MU_BUTTON|MU_KEYBD|MU_M2;

	glb.aes.evnt=evnt_multi(	flag,0x102,3,0,
										glb.aes.event.f1,glb.aes.event.x1,glb.aes.event.y1,glb.aes.event.w1,glb.aes.event.h1,
										glb.aes.event.f2,glb.aes.event.x2,glb.aes.event.y2,glb.aes.event.w2,glb.aes.event.h2,
										glb.aes.buf,glb.aes.event.t1,glb.aes.event.t2,
										&glb.aes.mx,&glb.aes.my,&glb.aes.mk,
										&glb.aes.kst,&glb.aes.key,&glb.aes.nmbClic
									);

	if (glb.aes.evnt & MU_MESAG)
	{
		_handleEvntMesag();
		glb.aes.evnt&=~MU_MESAG;
	}
	if (glb.aes.evnt & MU_BUTTON)
	{
		_handleEvntButton();
		glb.aes.evnt&=~MU_BUTTON;
	}
	if (glb.aes.evnt & MU_KEYBD)
	{
		_handleEvntKeybd();
		glb.aes.evnt&=~MU_KEYBD;
	}
	if (glb.aes.evnt & MU_M1)
	{
		_handleEvntBox1();	
		glb.aes.evnt&=~MU_M1;
	}
	if (glb.aes.evnt & MU_M2)
	{
		_handleEvntBox2();
		glb.aes.evnt&=~MU_M2;
	}
	if (glb.aes.evnt & MU_TIMER)
	{
		_handleEvntTimer();
		glb.aes.evnt&=~MU_TIMER;
	}
}


/*******************************************************************************
*******************************************************************************/
static void _handleEvntKeybd()
{
	int		child,type,bios,mask,i;
	int		ha,dum;
	OBJECT	*tree;
	char		*p;

	glb.aes.std=_StdKey(glb.aes.kst,glb.aes.key);
	if (glb.aes.type!=0)
	{
		if (glb.aes.tree.menu!=-1)
		{
			tree=glb.rsc.head.trindex[glb.aes.tree.menu];
			child=0;
			do
			{
				child+=1;
				if (glb.aes.std!=0 && (child<10 || child>15))
				{
					type=tree[child].ob_type>>8;
					if (tree[child].ob_type-type==G_STRING && !(tree[child].ob_state&DISABLED))
					{
						mask=0;
						if (type==0)
						{
							p=_obGetStr(tree,child);
							if (strlen(p)>4L)
							{
								p+=strlen(p)-4L;
								if (!strncmp(p,"[ ]",3))
									type=' ';
								else if (*p++==' ')
									for (i=0;i<3;i++)
									{
										if (*p==1)
											mask|=KF_SHIFT;
										else if (*p==7)
											mask|=KF_ALT;
										else if (*p=='^')
											mask|=KF_CTRL;
										else if (*p==9 || *p==13 || *p==27 || (*p>='A' && *p<='Z'))
											type=*p;
										p++;
									}
							}
						}
						else
						{
							if (tree[child].ob_state&0x2000)		mask+=KF_ALT;
							if (tree[child].ob_state&0x4000)		mask+=KF_CTRL;
							if (tree[child].ob_state&0x8000)		mask+=KF_SHIFT;
						}
						if (toupper(glb.aes.std&0xFF)==type)
						{
							bios=glb.aes.std & (KF_ALT|KF_CTRL|KF_SHIFT);
							if (bios&KF_RSH)
								bios|=KF_LSH;
							if (bios&KF_LSH)
								bios|=KF_RSH;
							if (bios==mask)
							{
								gereMenu(child);
								glb.aes.std=0;
							}
						}
					}
				}
			} while ( !(tree[child].ob_flags & LASTOB) );
		}
	}

	if (glb.aes.std!=0)
	{
		wind_get(0,WF_TOP,&ha,&dum,&dum,&dum);
		i=_winFindWin(ha);
		if (i!=-1)
			if (W[i].smallflag==0)
				if (W[i].keybd!=0)
					(*W[i].keybd)(i,glb.aes.std);
	}
}


/*******************************************************************************
*******************************************************************************/
static void _handleEvntButton()
{
	int		ha,i;

	ha=wind_find(glb.aes.mx,glb.aes.my);

	if (ha==0)
	{
		if (glb.aes.type!=0)
			if (glb.aes.event.flag&MU_BUTTON)
				_clicDesk(glb.aes.mx,glb.aes.my,glb.aes.mk,glb.aes.nmbClic,glb.aes.kst);
	}
	else
	{
		i=_winFindWin(ha);
		if (i!=-1)
			_winClic(i,glb.aes.mx,glb.aes.my,glb.aes.mk,glb.aes.nmbClic);
	}
}


/*******************************************************************************
*******************************************************************************/
static void _handleEvntBox1()
{
}

/*******************************************************************************
*******************************************************************************/
static void _handleEvntBox2()
{
	glb.aes.event.f2=!glb.aes.event.f2;
	glb.aes.top=-1;
	_winMakeTop();
}


/*******************************************************************************
*******************************************************************************/
static void _handleEvntMesag()
{
	int		i;
	char		*p;

	i=_winFindWin(glb.aes.buf[3]);

	switch (glb.aes.buf[0])
	{
		case	MN_SELECTED:
			if (glb.aes.buf[3]!=0)
				menu_tnormal(glb.rsc.head.trindex[glb.aes.tree.menu],glb.aes.buf[3],1);
			gereMenu(glb.aes.buf[4]);
			break;
		case	WM_REDRAW:
			_winRedraw(i,glb.aes.buf[4],glb.aes.buf[5],glb.aes.buf[6],glb.aes.buf[7]);
			break;
		case	WM_TOPPED:
			if (glb.aes.fmod && i!=glb.aes.wmod)
				i=glb.aes.wmod;
			_winTop(i);
			break;
		case	WM_CLOSED:
			if (glb.aes.kst&0x04)
			{
				if (W[i].gadget&W_SMALLER)
					_winSmall(i);
			}
			else
				_winClose(i);
			break;
		case	WM_FULLED:
			_winFull(i);
			break;
		case	WM_ARROWED:
			_winArrow(i,glb.aes.buf[4]);
			break;
		case	WM_HSLID:
			_winHslid(i,glb.aes.buf[4]);
			break;
		case	WM_VSLID:
			_winVslid(i,glb.aes.buf[4]);
			break;
		case	WM_SIZED:
		case	WM_MOVED:
			_winSize(i,glb.aes.buf[6],glb.aes.buf[7]);
			_winMove(i,glb.aes.buf[4],glb.aes.buf[5]);
			break;
		case	WM_UNTOPPED:
			_winUntop(i);
			break;
		case	WM_ONTOP:
			_winOntop(i);
			break;
		case	WM_BOTTOM:
			_winBottom(i);
			break;
		case	WM_ICONIFY:
			_winSmall(i);
			break;
		case	WM_UNICONIFY:
			break;
		case	WM_ALLICONIFY:
			break;
		case	WM_TOOLBAR:
			break;
		case	AP_TERM:
			glb.div.Exit=2;
			break;
		case	AP_DRAGDROP:
			break;
		case	VA_START:
			p=(char *)( (((long)glb.aes.buf[3])<<16) + (long)glb.aes.buf[4] );
			sprintf(glb.div.log,"VA_START: %lx %s\n",(long)p,p);
			_reportLog(LOG_RIM);
			wopen(p);
			break;
		default:
			break;
	}
}


/*******************************************************************************
*******************************************************************************/
static void _handleEvntTimer()
{
}


/*******************************************************************************
	Installation de la barre de menu
*******************************************************************************/
void _menuBar(int obj,int flag)
{
	if (glb.aes.type!=0 && obj!=-1)
		menu_bar(glb.rsc.head.trindex[obj],flag);
}


/*******************************************************************************
	Gestion du clic sur le bureau
	Non terminÇ: reste Ö faire la gestion d'objets sur le bureau
*******************************************************************************/
static void _drawDeskIcon(OBJECT *tree,int n,int flag)
{
	int	x,y,w,h;

	if (flag==FALSE)
		tree[n].ob_state&=~SELECTED;
	else
		tree[n].ob_state|=SELECTED;
	_coord(tree,n,FALSE,&x,&y,&w,&h);
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
}

static void _clicDesk(int mx,int my,int mk,int nmb,int kst)
{
	OBJECT	*tree;
	int		obj,type,xout,yout,xold,yold;

	wind_update(BEG_MCTRL);
	if (glb.aes.tree.desk!=-1)
	{
		tree=glb.rsc.head.trindex[glb.aes.tree.desk];
		obj=objc_find(tree,ROOT,MAX_DEPTH,mx,my);

		type=(tree[obj].ob_type)&0xFF;
		if (type==G_USERDEF)
			type=((UBLK *)tree[obj].ob_spec.userblk->ub_parm)->type;

		if ( (type==G_ICON || type==G_CICON) && tree[obj].ob_flags&TOUCHEXIT)
		{

			/**********************************************************************
				En cas de double-clic:
			**********************************************************************/
			if (nmb==2)
			{
				if (glb.aes.sel_icn!=0)
				{
					_drawDeskIcon(tree,glb.aes.sel_icn,FALSE);
					glb.aes.sel_icn=0;
				}

				_drawDeskIcon(tree,obj,TRUE);
				if (obj>=glb.aes.desk.first_icon && obj<glb.aes.desk.first_icon+glb.opt.Win_Num)
					_winUnSmall(obj-glb.aes.desk.first_icon);
				else
				{
					/*******************************************************************
						Evenement ?
					*******************************************************************/
				}
				_drawDeskIcon(tree,obj,FALSE);
			}
			/**********************************************************************
				Cas de simple-clic
			**********************************************************************/
			else if (nmb==1)
			{
				/*******************************************************************
					Clic sur une icìne
				*******************************************************************/
				if (glb.aes.sel_icn!=0)
				{
					_drawDeskIcon(tree,glb.aes.sel_icn,FALSE);
					glb.aes.sel_icn=0;
				}

				_drawDeskIcon(tree,obj,TRUE);

				graf_mkstate(&mx,&my,&mk,&kst);
				/*******************************************************************
					DÇplacement icìne
				*******************************************************************/
				if (mk==1)
				{
					graf_mouse(FLAT_HAND,0);
					graf_dragbox(tree[obj].ob_width,tree[obj].ob_height,tree[obj].ob_x+glb.aes.desk.x,
						tree[obj].ob_y+glb.aes.desk.y,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,
						glb.aes.desk.h,&xout,&yout);
					graf_mouse(ARROW,0);

					xold=tree[obj].ob_x+glb.aes.desk.x;
					yold=tree[obj].ob_y+glb.aes.desk.y;

					xout-=glb.aes.desk.x;
					yout-=glb.aes.desk.y;

					form_dial(FMD_FINISH,0,0,0,0,xold,yold,tree[obj].ob_width,tree[obj].ob_height);
					form_dial(FMD_FINISH,0,0,0,0,xout,yout,tree[obj].ob_width,tree[obj].ob_height);

					/*******************************************************************
						Evenement ?
					*******************************************************************/

					tree[obj].ob_x=xout;
					tree[obj].ob_y=yout;

					_drawDeskIcon(tree,obj,FALSE);
					glb.aes.sel_icn=0;
				}
				/**********************************************************************
					Clic sur une icìne
				**********************************************************************/
				else
				{
					if (glb.aes.sel_icn!=0)
						_drawDeskIcon(tree,glb.aes.sel_icn,FALSE);
					glb.aes.sel_icn=obj;
				}
			}
		}
		else if (obj==ROOT)
		{
			/**********************************************************************
				Clic sur le bureau -> icìne normale
			**********************************************************************/
			if (glb.aes.sel_icn!=0)
			{
				_drawDeskIcon(tree,glb.aes.sel_icn,FALSE);
				glb.aes.sel_icn=0;
			}
		}
	}
	wind_update(END_MCTRL);
}


/*******************************************************************************
	Gestion du clavier. La fonction retourne un code de caractäre normalisÇ
	Ö partir du code ASCII et scan suivant le clavier et le pays
*******************************************************************************/
int _StdKey(int shift,int key)
{
	KEYTAB	*kt;
	int		scan,asc;
	int		std=0;

	asc=key&0xFF;
	scan=key>>8;

	if (asc!=0 && scan==0 && shift==0)	/* Gestion de ALT+ASCII par le */
		std=asc;									/* TOS ou un TSR comme ACCENT */
	else
	{
		if (shift&0x01)			std|=KF_RSH;
		if (shift&0x02)			std|=KF_LSH;
		if (shift&0x04)			std|=KF_CTRL;
		if (shift&0x08)			std|=KF_ALT;
		if (Kbshift(-1)&0x10)	std|=KF_CAPS;

		switch (scan)
		{
			case	0x3b:		case	0x54:		std|=K_F1|KF_FUNC;		break;
			case	0x3c:		case	0x55:		std|=K_F2|KF_FUNC;		break;
			case	0x3d:		case	0x56:		std|=K_F3|KF_FUNC;		break;
			case	0x3e:		case	0x57:		std|=K_F4|KF_FUNC;		break;
			case	0x3f:		case	0x58:		std|=K_F5|KF_FUNC;		break;
			case	0x40:		case	0x59:		std|=K_F6|KF_FUNC;		break;
			case	0x41:		case	0x5A:		std|=K_F7|KF_FUNC;		break;
			case	0x42:		case	0x5B:		std|=K_F8|KF_FUNC;		break;
			case	0x43:		case	0x5C:		std|=K_F9|KF_FUNC;		break;
			case	0x44:		case	0x5D:		std|=K_F10|KF_FUNC;		break;
			case	0x62:		std|=K_HELP|KF_FUNC;							break;
			case	0x61:		std|=K_UNDO|KF_FUNC;							break;
			case	0x52:		std|=K_INS|KF_FUNC;							break;
			case	0x77:
			case	0x47:		std|=K_CLRHOME|KF_FUNC;						break;
			case	0x48:		std|=K_UP|KF_FUNC;							break;
			case	0x50:		std|=K_DOWN|KF_FUNC;							break;
			case	0x74:
			case	0x4D:		std|=K_RIGHT|KF_FUNC;						break;
			case	0x73:
			case	0x4B:		std|=K_LEFT|KF_FUNC;							break;
		}
		if ((scan>=0x63 && scan<=0x71) || scan==0x4A || scan==0x4E || scan==0x72)
			std|=KF_NUM;
		if ((std&0xFF)==0)
		{
			kt=Keytbl((void *)-1,(void *)-1,(void *)-1);
			if (std&KF_ALT && asc!=0)
				std|=asc;
			else if (std&KF_SHIFT)
				std|=(int)(kt->shift[scan])&0xFF;
			else if (std&KF_CAPS)
				std|=(int)(kt->capslock[scan])&0xFF;
			else
				std|=(int)(kt->unshift[scan])&0xFF;
		}
		switch (std&0xFF)
		{
			case	K_BS:
			case	K_TAB:
			case	K_RETURN:
			case	K_ESC:
				case	K_DEL:
				std|=KF_FUNC;
				break;
		}
	}
	return std;
}


/*******************************************************************************
	Vide le buffer AES
*******************************************************************************/
void _clearAesBuffer(void)
{
	int		buf[8];

	buf[0]=-1;
	buf[1]=glb.aes.id;
	buf[2]=0;
	buf[3]=0;
	buf[4]=0;
	buf[5]=0;
	buf[6]=0;
	buf[7]=0;
	appl_write(glb.aes.id,16,buf);
	do
	{
		evnt_mesag(glb.aes.buf);
		if (glb.aes.buf[0]!=-1)
			_handleEvntMesag();
	} while (glb.aes.buf[0]!=-1);
}


/*******************************************************************************
	Active la souris "busy"
*******************************************************************************/
void _mousework()
{
	glb.div.mouse+=1;
	if (glb.div.mouse>FMOULST)
		glb.div.mouse=FMOUWHEEL;
	graf_mouse(USER_DEF,&glb.aes.s[glb.div.mouse]);
}
