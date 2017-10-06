/******************************************************************************/
/*	"Easy Gem" library Copyright (c)1994 by		Christophe BOYANIQUE				*/
/*																29 Rue R‚publique					*/
/*																37230 FONDETTES					*/
/*																FRANCE								*/
/*						*small* mail at email adress:	cb@spia.freenix.fr				*/
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
/*	MAIN SOURCE.																					*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

/******************************************************************************/
/*	Release version & date; and modifications author									*/
/******************************************************************************/
#define		RELEASE	"v1.21 from %s"
#define		PATCH1	"nobody"
#define		PATCH2	"(official release)"

/******************************************************************************/
/*	This is to prevent from using Let'em Fly with EGlib...							*/
/*	I think that it won't be usefull in the futur										*/
/******************************************************************************/
/*#define		NOLETEMFLY*/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	RSC file must be linked to the lib for a normal use								*/
/******************************************************************************/
#define	RSC_RELLOC
#ifdef RSC_RELLOC
	#include		"EG_RSC.RSH"						/*	Files created by Interface		*/
	#include		"EG_RSC.RH"			/*	You can remove rgb_palette from RSH file	*/
#else
	#include		"EG_RSC.H"
#endif

/******************************************************************************/
/*	Intern variables of the lib																*/
/******************************************************************************/
OBJECT		*mytree;						/*	RSC window tree)								*/
RSC			__rsc;						/*	RSC lib header)								*/
int			__x,__y,__w,__h;
int			__TOP;
int			__buf[8],__evnt,__kst,__key,__std,__mx,__my,__mk,__nmbClic,__adrW;
MFORM			__s[14];						/*	Mouse forms										*/
GRECT			__r;							/*	Clipping rectangle							*/
__window		*__W;							/*	internal win struct							*/
char			histoire[MAX_HIST+1][MAX_LEN_HIST+1];		/*	For Online Help		*/
char			histoire2[MAX_HIST+1][MAX_LEN_HIST+1];		/*			""					*/
int			cu_hist,cp_hist;									/*			""					*/


/******************************************************************************/
/*	Global variables																				*/
/******************************************************************************/
GLB			glb;							/*	main struct										*/
window		*W;							/*	win struct										*/
SLCT_STR		*slct=NULL;					/*	For use with Slectric (see GLB_FSEL)	*/
long			*fsel=NULL;					/*	------------------------------------	*/
FONT			*font;
char			pname[FILENAME_MAX],pfname[FILENAME_MAX],fname[14],ext[14],tit[30];


/******************************************************************************/
/*	main procedure of the lib																	*/
/******************************************************************************/
void _EGlib()
{
	int	i;

	glb.Exit=-1;
	if (!_initMEM())
		goto exitMEM;
	_initAES();
	if (!_windowInit())
		goto exitAES;
	if (!_initVDI())
		goto exitVDI;
	_mousework();
	_initFont();
	_mousework();
	_initAide();
	_mousework();
	_savePal();
	_mousework();
	if (glb.Finit!=0)
		(*glb.Finit)();
	_mousework();
	_initDIV();
	_mousework();
	_initSIG();
	_mousework();
	if (!_loadRSC())
		goto exitFONT;
	_mousework();
	if (!_initMyRSC())
		goto exitFONT;
	_mousework();
	if (!_initRSC())
		goto exitRSC;
	_mousework();
	_initDesk();
	_mousework();
	_menuBar(glb.menu,1);
	graf_mouse(ARROW,0);
	if (glb.FiLast!=0)
		(*glb.FiLast)();
	_loadConfig();
	glb.Exit=0;
	while (!glb.Exit)
	{
		_gereAES();
		if ( glb.Exit && glb.type!=1 && !glb.Multi )
		{
			glb.Exit=0;								/*	if ACC: no exit !		*/
			for (i=0;i<glb.NMB_WDW;i++)
				if (W[i].handle>0)
				{
					_closed(i);
					_clearAesBuffer();
				}
			if (glb.opt.save)
				_saveConfig();
		}
	}
	if (glb.opt.save)
		_saveConfig();
	if (glb.FeFirst!=0)
		(*glb.FeFirst)();
	_menuBar(glb.menu,FALSE);
	_exitDesk();
	_mousework();
exitRSC:
	_exitRSC();
	_mousework();
	_exitDIV();
	_mousework();
	_loadPal(TRUE);
	_mousework();
	graf_mouse(ARROW,0);
exitFONT:
	_exitFont();
exitVDI:
	_exitVDI();
exitAES:
	_exitAES();
	_exitMEM();
exitMEM:
	return;
}


/******************************************************************************/
/*	init of memory																					*/
/******************************************************************************/
void _clearGLB()
{
	_cls((long)&glb,sizeof(GLB));
	glb.menu	=	-1;
	glb.desk	=	-1;
	glb.icon	=	-1;
}

int _initMEM()
{
	long		len,Max,sys;

	glb.opt.help=1;				/*	inits the default EGlib params	*/
	glb.opt.hsiz=12-3*glb.low;
	glb.opt.popf=1;
	glb.opt.full=0;
	glb.opt.chlpt=1;
	glb.opt.chlpf=0;
	glb.opt.save=1;
	glb.opt.mfrm=1;

	glb.NMB_WDW+=8;							/*	intern lib windows		*/
	glb.opt.mnmb+=100;						/*	for color icon				*/
	glb.opt.mnmb+=glb.NMB_WDW*4;			/*	fo windows					*/

	len=glb.opt.mlen;
	sys=_freeSys();
	Max=(long)Malloc(-1L);
	glb.opt.mlen=0;
	glb.vTOS=_vTOS();

	if (Max>=100L*1024L)				/*	EGlib need at least 100 Kb !	*/
	{
		if (len<0)
			glb.opt.mlen=sys+len;
		else if ( (len>0) && (len<100) )
			glb.opt.mlen=(long)( (double)sys*(double)len/(double)100 );
		else
			glb.opt.mlen=len;
		Max=min(Max,sys);
		glb.opt.mlen=max(100L*1024L,glb.opt.mlen);
		glb.opt.mlen=min(Max,glb.opt.mlen);
		if ( _pAlloc(glb.opt.mnmb,glb.opt.mlen) == OK_MEM )
			return TRUE;
	}
	return FALSE;
}


/******************************************************************************/
/*	uninit of memory																				*/
/******************************************************************************/
void _exitMEM()
{
	_pFree();
}


/******************************************************************************/
/*	Init AES																							*/
/******************************************************************************/
void _initAES()
{
	__TOP=0;
	glb.app_id	=	appl_init();
	glb.vAES		=	Gem_pb.global[0];
	glb.Multi	=	(Gem_pb.global[1]==-1) ? TRUE : FALSE;
	glb.type		=	_app;
	glb.AccOp	=	glb.type;

	if (! ((glb.type==1)&&(glb.Multi==FALSE)) )
		menu_register(glb.app_id,glb.name);
	if (glb.vAES>=0x400)
		shel_write(9,1,0,0,0);				/*	for AES v4.0	*/

	wind_get(0,WF_WORKXYWH,&glb.xdesk,&glb.ydesk,&glb.wdesk,&glb.hdesk);
	if (glb.FiAES!=0)
		(*glb.FiAES)();
}


/******************************************************************************/
/*	Init VDI																							*/
/******************************************************************************/
int _initVDI()
{
	int		i,j,work_in[11];
	OBJECT	*tree;
	#ifndef RSC_RELLOC
	long		len;
	#endif

	glb.opt.GDfnt=1;
	glb.hvdi=graf_handle(&glb.wcell,&glb.hcell,&glb.wbox,&glb.hbox);
	for(i=0;i<10;work_in[i++]=1);
	work_in[0]=Getrez()+2;
	work_in[10]=2;
	v_opnvwk(work_in,&glb.hvdi,glb.out);		/*	opens a virtual workstation	*/
	vq_extnd(glb.hvdi,1,glb.extnd);
	if (glb.hcell<16)										/*	inits the glb.low flag !	*/
		glb.low=1;
	else
		glb.low=0;
	glb.xscr	=	0;
	glb.yscr	=	0;
	glb.wscr	=	glb.out[0];
	glb.hscr	=	glb.out[1];
	if (glb.FiVDI!=0)
		(*glb.FiVDI)();

	#ifdef RSC_RELLOC
		__rsc.head.nobs		=	NUM_OBS;
		__rsc.head.ntree		=	NUM_TREE;
		__rsc.head.nted		=	NUM_TI;
		__rsc.head.ncib		=	NUM_CIB;
		__rsc.head.nib			=	NUM_IB;
		__rsc.head.nbb			=	NUM_BB;
		__rsc.head.nfstr		=	NUM_FRSTR;
		__rsc.head.nfimg		=	NUM_FRIMG;
		#if NUM_OBS>0
		__rsc.head.object		=	rs_object;
		#endif
		#if NUM_TREE>0
		__rsc.head.trindex	=	rs_trindex;
		#endif
		#if NUM_TI>0
		__rsc.head.tedinfo	=	rs_tedinfo;
		#endif
		#if NUM_IB>0
		__rsc.head.iconblk	=	rs_iconblk;
		#endif
		#if NUM_BB>0
		__rsc.head.bitblk		=	rs_bitblk;
		#endif
		#if NUM_CIB>0
		__rsc.head.cicon		=	rs_cicon;
		__rsc.head.ciconblk	=	rs_ciconblk;
		#endif
		#if NUM_FRSTR>0
		__rsc.head.frstr		=	rs_frstr;
		#endif
		#if NUM_FRIMG>0
		__rsc.head.frimg		=	rs_frimg;
		#endif
		for (i=0;i<__rsc.head.nobs;i++)
			rsrc_obfix(&__rsc.head.object[i],0);
	#else
		i=(int)Fopen("EG_RSC.RSC",FO_READ);
		if (i<0)
			return FALSE;
		len=Fseek(0L,i,2);
		Fseek(0L,i,0);
		__rsc.in=_mAlloc(len,MB_NOMOVE,0);
		if (__rsc.in==NO_MEMORY)
		{
			Fclose(i);
			return FALSE;
		}
		if ( Fread(i,len,(void *)mem.bloc[__rsc.in].adr) != len )
			return FALSE;
		Fclose(i);
		_relocRSC(mem.bloc[__rsc.in].adr,&__rsc.head);
	#endif
	_initLang();

	tree=__rsc.head.trindex[FMOUSE];
	for (i=1;i<=FSOUFNT;i++)
	{
		__s[i].mf_xhot		=	8;
		__s[i].mf_yhot		=	8;
		__s[i].mf_nplanes	=	1;
		__s[i].mf_fg		=	0;
		__s[i].mf_bg		=	1;

		for (j=0;j<16;j++)
		{
			__s[i].mf_mask[j]	=	tree[i].ob_spec.iconblk->ib_pmask[j];
			__s[i].mf_data[j]	=	tree[i].ob_spec.iconblk->ib_pdata[j];
		}
	}
	return TRUE;
}


/******************************************************************************/
/*	Init divers																						*/
/******************************************************************************/
void _initDIV()
{
	long		Cook;
	int		i;

	if (glb.icon==-1)
		glb.icon=ICONE|FLAGS15;
	Dgetpath(pname,0);
	if (pname[1]!=':')
	{
		glb.path[0]=65+Dgetdrv();
		glb.path[1]=':';
		glb.path[2]=0;
		strcat(glb.path,pname);
		strcat(glb.path,"\\");				/*	this is the working and real path	*/
	}
	strcpy(glb.opt.phelp,glb.path);							/*	the help files path	*/
	strcat(glb.opt.phelp,"HELP\\");
	strcpy(glb.opt.path,glb.path);	/*	the executable path to load/save .CNF	*/
	glb.vTOS=(int)_vTOS();

	i=_AKP();
	if (i>=0x7F)		/*	Soft loaded table: -> _AKP cookie	*/
		i=(int)( ( _cookie('_AKP') & 0xFF00L )>>8 );
	switch	(i)
	{
		case	2:
		case	7:
			glb.opt.lang=L_FRENCH;
			break;
		default:
			glb.opt.lang=L_ENGLISH;
			break;
	}

	Cook=_cookie('_MCH');
	glb.MCH	=	(int)(Cook>>16);						/*	machine type		*/
	switch (glb.MCH)										/*	0:	STF				*/
	{															/*	1:	STE				*/
		case	2:		glb.MCH=3;							/*	2:	MegaSTE			*/
						break;								/*	3:	TT					*/
		case	3:		glb.MCH=4;							/*	4:	Falcon030		*/
						break;								/*	5:	???				*/
		case	1:		if ( (int)(Cook&0xFF)==16 )
						glb.MCH=2;
						break;
		default:		glb.MCH=5;
						break;
	}
	if (glb.FiDIV!=0)
		(*glb.FiDIV)();	/*	extern init		*/
}


/******************************************************************************/
/*	RSC loading																						*/
/******************************************************************************/
int _loadRSC()
{
	int		ha;
	long		len;

	if (glb.rsc.type==EXT_RSC)
	{
		ha=(int)Fopen(glb.rsc.name,FO_READ);
		if (ha<0)
			return FALSE;
		len=Fseek(0L,ha,2);
		Fseek(0L,ha,0);
		glb.rsc.in=_mAlloc(len,MB_NOMOVE,0);
		if (glb.rsc.in==NO_MEMORY)
		{
			Fclose(ha);
			return FALSE;
		}
		if ( Fread(ha,len,(void *)mem.bloc[glb.rsc.in].adr) != len )
			return FALSE;
		Fclose(ha);
		_relocRSC(mem.bloc[glb.rsc.in].adr,&glb.rsc.head);
	}
	if (glb.Fcut!=0)
		(*glb.Fcut)();
	return TRUE;
}


/******************************************************************************/
/*	Init RSC																							*/
/******************************************************************************/
int _initRSC()
{
	int		i,child;
	OBJECT	*tree;

	if (!_initUserdef(&glb.rsc))
		return FALSE;

	if (glb.FiObRSC!=0)
		for (i=0;i<glb.rsc.head.ntree;i++)
		{
			tree=glb.rsc.head.trindex[i];
			child=-1;
			do
			{
				child+=1;
				(*glb.FiObRSC)(i,child);
			}	while ( !(tree[child].ob_flags & LASTOB) );
		}
	return TRUE;
}


/******************************************************************************/
/*	Init lib RSC																					*/
/******************************************************************************/
int _initMyRSC()
{
	OBJECT	*tree;
	int		i,child;
	char		txt[40];

	#ifdef NOLETEMFLY
	typedef struct					/*	This is the Let'em Fly cookie struct!	*/
	{
		int	version;
		int	on0			:1;
		int	niceline		:1;
		int	jumpdial		:1;
		int	gflight		:1;
		int	VSCR			:1;
		int	savepos		:1;
		int	keydials		:1;
		int	editor		:1;
		int	redraw		:1;
		int	flytype		:1;
		int	flydial		:1;
		int	alertbox		:1;
		int	dial2mouse	:1;
		int	form			:1;
		int	graf			:1;
		int	active		:1;
	}	LET;
	LET	*let;
	#endif

	if (!_initUserdef(&__rsc))
		return FALSE;
	if (glb.low)
		mytree=__rsc.head.trindex[LWIN];
	else
		mytree=__rsc.head.trindex[HWIN];

	for (i=0;i<__rsc.head.ntree;i++)
	{
		tree=__rsc.head.trindex[i];
		child=-1;
		do
		{
			child+=1;
			_myInitForm(i,child);
		}	while ( !(tree[child].ob_flags & LASTOB) );
	}

	sprintf(txt,RELEASE,__DATE__);
	_obPutStr(__rsc.head.trindex[FINF],FINFVER,txt);
	_obPutStr(__rsc.head.trindex[FINF],FINFPT1,PATCH1);
	_obPutStr(__rsc.head.trindex[FINF],FINFPT2,PATCH2);
	#ifdef NOLETEMFLY
	let=(LET *)_cookie('LTMF');
	if (let!=0)
		if ( (let->niceline) || (let->alertbox) )
		{
			if (glb.opt.lang==L_FRENCH)
				form_alert(1,__rsc.head.frstr[_0LETFLY]);
			else
				form_alert(1,__rsc.head.frstr[_1LETFLY]);
			return FALSE;
		}
	#endif
	return TRUE;
}


/******************************************************************************/
/*	Init Desk																						*/
/******************************************************************************/
void _initDesk()
{
	OBJECT		*tree;

	if ( (glb.type!=0) && (glb.desk!=-1) )
	{
		tree=glb.rsc.head.trindex[glb.desk];
		tree->ob_x			=	glb.xdesk;
		tree->ob_y			=	glb.ydesk;
		tree->ob_width		=	glb.wdesk;
		tree->ob_height	=	glb.hdesk;

		if (glb.FiDesk!=0)
			(*glb.FiDesk)();

		wind_set(0,WF_NEWDESK,tree,0);
		form_dial(FMD_FINISH,0,0,0,0,glb.xdesk,glb.ydesk,glb.wdesk,glb.hdesk);
	}
}


/******************************************************************************/
/*	[Des]installation de la barre de menu													*/
/******************************************************************************/
void _menuBar(int obj,int flag)
{
	if ( (glb.type!=0) && (obj!=-1) )
	{
		if (obj&FLAGS15)
			menu_bar(__rsc.head.trindex[obj&~FLAGS15],flag);
		else
			menu_bar(glb.rsc.head.trindex[obj],flag);
	}
}


/******************************************************************************/
/*	Uninit du Bureau																				*/
/******************************************************************************/
void _exitDesk()
{
	if ( (glb.type!=0) && (glb.desk!=-1) )
	{
		wind_set (0,WF_NEWDESK,0,0,0,0);
		form_dial(FMD_FINISH,0,0,0,0,glb.xdesk,glb.ydesk,glb.wdesk,glb.hdesk);
	}
}


/******************************************************************************/
/*	Uninit du RSC																					*/
/******************************************************************************/
void _exitRSC()
{
	int	i;

	for (i=0;i<glb.NMB_WDW;i++)
		if (W[i].handle>0)
		{
			_closed(i);
			_clearAesBuffer();
		}
	_exitUserdef(&glb.rsc);
	if (glb.rsc.type==EXT_RSC)
		_mFree(glb.rsc.in);
}


/******************************************************************************/
/*	Uninit divers																					*/
/******************************************************************************/
void _exitDIV()
{
	if (glb.FeDIV!=0)
		(*glb.FeDIV)();
}


/******************************************************************************/
/*	Uninit VDI																						*/
/******************************************************************************/
void _exitVDI()
{
	_exitUserdef(&__rsc);
	if (glb.FeVDI!=0)
		(*glb.FeVDI)();
	v_clsvwk(glb.hvdi);
}


/******************************************************************************/
/*	Uninit AES																						*/
/******************************************************************************/
void _exitAES()
{
	if (glb.FeAES!=0)
		(*glb.FeAES)();
	_clearAesBuffer();
	if (glb.Exit==2 && glb.vAES>=0x400)
		shel_write(10,SHUT_COMPLETED,0,0,0);
	appl_exit();
}


/******************************************************************************/
/*	Init the window struct																		*/
/******************************************************************************/
int _windowInit()
{
	int		i;

	__adrW=_mAlloc( (long)glb.NMB_WDW * ((long)sizeof(window)+(long)sizeof(__window)) ,MB_NOMOVE,TRUE);

	if ( __adrW!=NO_MEMORY )
	{
		W=(window *)( mem.bloc[__adrW].adr );
		__W=(__window *)( mem.bloc[__adrW].adr+(long)glb.NMB_WDW*(long)sizeof(window) );
		for (i=0;i<glb.NMB_WDW;i++)
		{
			W[i].id			=	-1;
			W[i].type		=	-1;
			W[i].handle		=	-1;
			W[i].xwind		=	-1;
			W[i].in			=	NO_MEMORY;
		}
		return TRUE;
	}
	else
		return FALSE;
}


/******************************************************************************/
/*	This function can be called to handle GEM event										*/
/******************************************************************************/
void _gereAES()
{
	int	flag=0;

	if	( (glb.timer1==0) && (glb.timer2==0) )	/*	This is to construct a correct*/
		glb.timer1=1000;								/*	event mask:							*/
	if (glb.flag&MU_M1)								/*	MESAG+BUTTON+KEYBD+TIMER are	*/
		flag|=MU_M1;									/*	always used !						*/
	if (glb.flag&MU_M2)
		flag|=MU_M2;
	flag|=MU_MESAG|MU_BUTTON|MU_KEYBD|MU_TIMER;

	__evnt	=	evnt_multi	(	flag,0x102,3,0,
										glb.f1,glb.x1,glb.y1,glb.w1,glb.h1,
										glb.f2,glb.x2,glb.y2,glb.w2,glb.h2,
										__buf,glb.timer1,glb.timer2,
										&__mx,&__my,&__mk,&__kst,&__key,&__nmbClic
									);

	if (__evnt & MU_MESAG)	{	_traiteEvntMesag();	__evnt&=~MU_MESAG;	}
	if (__evnt & MU_BUTTON)	{	_traiteEvntButton();	__evnt&=~MU_BUTTON;	}
	if (__evnt & MU_KEYBD)	{	_traiteEvntKeybd();	__evnt&=~MU_KEYBD;	}
	if (__evnt & MU_M1)		{	_traiteEvntBox1();	__evnt&=~MU_M1;		}
	if (__evnt & MU_M2)		{	_traiteEvntBox2();	__evnt&=~MU_M2;		}
	if (__evnt & MU_TIMER)	{	_traiteEvntTimer();	__evnt&=~MU_TIMER;	}
}


/******************************************************************************/
/*	Handle keyboard events																		*/
/******************************************************************************/
void _traiteEvntKeybd()
{
	int		child,type,bios,mask,i;
	int		ha,dum;
	OBJECT	*tree;
	char		*p;

	__std=_traiteKey(__kst,__key);
	if (glb.type!=0)
	{
		if ((__std&0xFF)==K_HELP)
		{
			__std=0;
			_Aide();
		}

		if (glb.menu!=-1)
		{
			tree=glb.rsc.head.trindex[glb.menu];
			child=0;
			do
			{
				child+=1;
				if ( __std!=0 && (child<10 || child>15) )
				{
					type=tree[child].ob_type>>8;
					if ( tree[child].ob_type-type==G_STRING && !(tree[child].ob_state&DISABLED) )
					{
						mask=0;
						if (type==0)
						{
							p=_obGetStr(tree,child);
							p+=strlen(p)-4L;
							for (i=0;i<3;i++,p++)
							{
								if (*p==1)
									mask|=KF_SHIFT;
								else if (*p==7)
									mask|=KF_ALT;
								else if (*p=='^')
									mask|=KF_CTRL;
								else if ( *p==9 || *p==13 || *p==27 || (*p>='A' && *p<='Z') )
									type=*p;
							}
						}
						else
						{
							if (tree[child].ob_state&0x2000)		mask+=KF_ALT;
							if (tree[child].ob_state&0x4000)		mask+=KF_CTRL;
							if (tree[child].ob_state&0x8000)		mask+=KF_SHIFT;
						}
						if (toupper(__std&0xFF)==type)
						{
							bios=__std & (KF_ALT|KF_CTRL|KF_SHIFT);
							if (bios&KF_RSH)
								bios|=KF_LSH;
							if (bios&KF_LSH)
								bios|=KF_RSH;
							if (bios==mask)
							{
								_gereMenu(0,child);
								__std=0;
							}
						}
					}
				}
			} while ( !(tree[child].ob_flags & LASTOB) );
		}
	}

	if (__std!=0)
	{
		wind_get(0,WF_TOP,&ha,&dum,&dum,&dum);
		i=_winFindWin(ha);
		if (i!=-1)
			if (W[i].smallflag==0)
				if (W[i].keybd!=0)
				{
					_makeform(i);
					(*W[i].keybd)(i,__std);
				}
	}
	if ( (__std!=0) && (glb.Fkey!=0) && (glb.flag&MU_KEYBD) )
		(glb.Fkey)(__std);
}


/******************************************************************************/
/*	Handle button event																			*/
/******************************************************************************/
void _traiteEvntButton()
{
	int		ha,i;

	ha=wind_find(__mx,__my);

	if (ha==0)
	{
		if (glb.type!=0)
			if (glb.flag&MU_BUTTON)
				_clicBureau(__mx,__my,__mk,__nmbClic);
	}
	else
	{
		i=_winFindWin(ha);
		if (i!=-1)
			_clicWin(i,__mx,__my,__mk,__nmbClic);
	}
}


/******************************************************************************/
/*	Handle Box 1 event																			*/
/******************************************************************************/
void _traiteEvntBox1()
{
	if (glb.Fbox1!=0)
		(*glb.Fbox1)();
}

/******************************************************************************/
/*	Handle Box 2 event																			*/
/******************************************************************************/
void _traiteEvntBox2()
{
	if (glb.Fbox2!=0)
		(*glb.Fbox2)();
}


/******************************************************************************/
/*	Handle mesag event																			*/
/******************************************************************************/
void _traiteEvntMesag()
{
	int		i;

	switch (__buf[0])
	{
		case	AC_OPEN:
			_AcOpen();
			break;
		case	AC_CLOSE:
			_AcClose();
			break;
		case	AP_TERM:
			glb.Exit=2;
			break;
		case	MN_SELECTED:
			_gereMenu(__buf[3],__buf[4]);
			break;
		case	WM_REDRAW:
			i=_winFindWin(__buf[3]);
			_redraw(i,__buf[4],__buf[5],__buf[6],__buf[7]);
			break;
		case	WM_TOPPED:
			i=_winFindWin(__buf[3]);
			_top(i);
			_ontop(i);
			break;
		case	WM_UNTOPPED:
			i=_winFindWin(__buf[3]);
			_untop(i);
			break;
		case	WM_ONTOP:
			i=_winFindWin(__buf[3]);
			_ontop(i);
			break;
		default:
			if ( glb.Fmesag!=0 && glb.flag&MU_MESAG )
				(*glb.Fmesag)(__buf);
			break;
	}
}


/******************************************************************************/
/*	Handle timer event																			*/
/******************************************************************************/
void _traiteEvntTimer()
{
	if ( (glb.Ftimer!=0) && (glb.flag&MU_TIMER) )
		(*glb.Ftimer)();
}


/******************************************************************************/
/*	Handle menu event																				*/
/******************************************************************************/
void _gereMenu(int titre,int option)
{
	OBJECT		*tree;

	tree=glb.rsc.head.trindex[glb.menu];
	if (glb.FgereMenu!=0)
		(*glb.FgereMenu)(option);
	if (titre!=0)
		menu_tnormal(tree,titre,1);
}


/******************************************************************************/
/*	Handle iconification event																	*/
/******************************************************************************/
void _small(int i)
{
	OBJECT	*tree;
	int		x,y,w,h;
	int		ok,j,ha=W[i].handle;

	if (i!=-1)
	{
		wind_get(ha,WF_WORKXYWH,&x,&y,&w,&h);

		if (W[i].icon&FLAGS15)
			tree=__rsc.head.trindex[W[i].icon&~FLAGS15];
		else
			tree=glb.rsc.head.trindex[W[i].icon];
		tree->ob_x=x+(w-tree->ob_width)/2;
		tree->ob_y=y+(h-tree->ob_height)/2;

		__W[i].xwsmall=tree->ob_x;
		__W[i].ywsmall=tree->ob_y;
		__W[i].wwsmall=tree->ob_width;
		__W[i].hwsmall=tree->ob_height;
		wind_calc(WC_BORDER,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,&x,&y,&w,&h);
		__W[i].wsmall=w;
		__W[i].hsmall=h;

		x=glb.xdesk;
		y=glb.ydesk;
		do
		{
			ok=1;
			for (j=0;j<glb.NMB_WDW;j++)
				if (W[j].smallflag)
					if ( (__W[j].xsmall==x) && (__W[j].ysmall==y) )
					{
						y+=h;
						if (y+h>glb.ydesk+glb.hdesk)
						{
							x+=w;
							y=glb.ydesk;
						}
						j=glb.NMB_WDW;
						ok=0;
					}
		}	while (!ok);
		__W[i].xsmall=x;
		__W[i].ysmall=y;

		wind_set(ha,WF_CURRXYWH,__W[i].xsmall,__W[i].ysmall,__W[i].wsmall,__W[i].hsmall);
		wind_get(ha,WF_WORKXYWH,&__W[i].xwsmall,&__W[i].ywsmall,&__W[i].wwsmall,&__W[i].hwsmall);
		tree[2].ob_state&=~SELECTED;
		__W[i].params._smstate=tree[2].ob_state;
		W[i].smallflag=1;
		_winRedraw(i,0,0,0,0);
		if (W[i].small!=0)
			(*W[i].small)(i);
	}
}
void _allsmall(int i)
{
	OBJECT	*tree;
	int	j,ha,x,y,w,h;

	if (i!=-1)
	{
		if (glb.icon&FLAGS15)
			tree=__rsc.head.trindex[glb.icon&~FLAGS15];
		else
			tree=glb.rsc.head.trindex[glb.icon];

		ha=W[i].handle;
		for (j=0;j<glb.NMB_WDW;j++)
			if ( (W[j].handle>0) && (j!=i) )
			{
				if (W[j].small!=0) (*W[j].small)(j);
				wind_close(W[j].handle);
				wind_delete(W[j].handle);
				W[j].handle=-2;
			}

		wind_get(ha,WF_WORKXYWH,&x,&y,&w,&h);
		tree->ob_x=x+(w-tree->ob_width)/2;
		tree->ob_y=y+(h-tree->ob_height)/2;
		__W[i].xwsmall=tree->ob_x;
		__W[i].ywsmall=tree->ob_y;
		__W[i].wwsmall=tree->ob_width;
		__W[i].hwsmall=tree->ob_height;
		wind_calc(WC_BORDER,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,&x,&y,&w,&h);
		__W[i].xsmall=glb.xdesk;
		__W[i].ysmall=glb.ydesk;
		__W[i].wsmall=w;
		__W[i].hsmall=h;
		wind_set(ha,WF_CURRXYWH,__W[i].xsmall,__W[i].ysmall,__W[i].wsmall,__W[i].hsmall);
		wind_get(ha,WF_WORKXYWH,&__W[i].xwsmall,&__W[i].ywsmall,&__W[i].wwsmall,&__W[i].hwsmall);
		tree[2].ob_state&=~SELECTED;
		__W[i].params._smstate=tree[2].ob_state;
		W[i].smallflag=2;
		_winRedraw(i,0,0,0,0);
		if (W[i].small!=0)
			(*W[i].small)(i);
	}
}
void _unsmall(int i)
{
	if (i!=-1)
		if (W[i].smallflag==1)
		{
			wind_set(W[i].handle,WF_CURRXYWH,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			W[i].smallflag=0;
			if (W[i].nsmall!=0)
				(*W[i].nsmall)(i);
			_winRedraw(i,0,0,0,0);
			_clearAesBuffer();
		}
}
void _allunsmall(int i)
{
	int		t;
	window	win;

	if (i!=-1)
	{
		wind_set(W[i].handle,WF_CURRXYWH,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
		W[i].smallflag=0;
		if (W[i].nsmall!=0)
			(*W[i].nsmall)(i);
		_winRedraw(i,0,0,0,0);
		for (t=0;t<glb.NMB_WDW;t++)
			if ( (W[t].handle==-2) && (t!=i) )
			{
				win=W[t];
				W[t].handle=-1;
				_winOpen(&win);
				if (W[t].nsmall!=0)
					(*W[t].nsmall)(t);
			}
	}
}


/******************************************************************************/
/*	Handle AC_OPEN mesag																			*/
/******************************************************************************/
void _AcOpen()
{
	int		t;
	window	win;

	_initDesk();
	if (!glb.AccOp)
		glb.AccOp=1;
	for (t=0;t<glb.NMB_WDW;t++)
		if (W[t].handle==-2)
		{
			win=W[t];
			W[t].handle=-1;
			_winOpen(&win);
		}
	if (glb.FacOpen!=0)
		(*glb.FacOpen)();
}


/******************************************************************************/
/*	Handle AC_CLOSE event																		*/
/******************************************************************************/
void _AcClose()
{
	int		x;

	for (x=0;x<glb.NMB_WDW;x++)
		if (W[x].handle>0)
		{
			wind_close(W[x].handle);
			wind_delete(W[x].handle);
			W[x].handle=-2;
		}
	if (glb.FacClose!=0)
		(*glb.FacClose)();
	_exitDesk();
	_clearAesBuffer();
}


/******************************************************************************/
/*	This function is used to open a window													*/
/******************************************************************************/
int _winOpen(window *win)
{
	int		top,dum;
	int		x=-1;
	int		handle=-1;
	int		i;
	int		X,Y,WW,HH;
	int		nH=0,nD=0,nB=0,isB=0,isD=0;

	for (i=0;i<glb.NMB_WDW;i++)
		if (W[i].smallflag==2)							/*	Application iconified ?		*/
			_allunsmall(i);								/*	Open all windows				*/
	/***************************************************************************/
	/*	Each window contains a 'type' (for example form) and an 'id' (the tree	*/
	/*	number for example)
	/***************************************************************************/

	/***************************************************************************/
	/*	1st step: is there a closed window with same type/id ?						*/
	/***************************************************************************/
	for (i=0;i<glb.NMB_WDW;i++)
		if ( (W[i].type==win->type) && (W[i].id==win->id) )
		{
			x=i;
			i=glb.NMB_WDW;
		}

	if (x==-1)
	{
		/************************************************************************/
		/*	Here, there is not a previously closed window.								*/
		/*	We must search a free handle to create a new one, and as possible		*/
		/*	one with xwind=1																		*/
		/************************************************************************/
		for (i=0;i<glb.NMB_WDW;i++)
		{
			if ( (W[i].handle<0) && (W[i].xwind==-1) )
			{
				x=i;
				i=glb.NMB_WDW;
			}
			if (x==-1)
				/******************************************************************/
				/*	There is no free handle with xwind=1, so we take the first one	*/
				/*	and force xwind to -1														*/
				/******************************************************************/
				if ( (W[i].handle<0) && (W[i].xwind!=-1) )
				{
					x=i;
					W[x].xwind=-1;
					i=glb.NMB_WDW;
				}
		}
	}

	if (x!=-1)
	{
		/************************************************************************/
		/*	if handle=-1 then create the window, else top it !							*/
		/************************************************************************/
		if (W[x].handle>0)
		{
			wind_get(0,WF_TOP,&top);
			if ( (top!=W[x].handle) || (W[x].smallflag==1) )
			{
				if (W[x].smallflag==1) _unsmall(x);
				_top(x);
				_ontop(x);
			}
			handle=W[x].handle;
		}
		else
		{
			strncpy(W[x].name,win->name,wNAMEMAX);
			strncpy(W[x].sname,win->sname,wSNAMEMAX);
			strncpy(W[x].help,win->help,14);
			W[x].gadget=win->gadget;
			W[x].smallflag=0;
			W[x].type=win->type;
			W[x].id=win->id;
			W[x].xslidlen=100;
			W[x].xslidpos=0;
			W[x].yslidlen=100;
			W[x].yslidpos=0;

			if ( (W[x].gadget & wNAME) )
				_obPutStr(mytree,FWINAME,W[x].name);
			else
				_obPutStr(mytree,FWINAME,"");

			WW=mytree[wCLOSE].ob_width;
			HH=mytree[wCLOSE].ob_height;
			mytree[FWINCLS].ob_flags&=~HIDETREE;
			mytree[FWINPOP].ob_flags&=~HIDETREE;
			mytree[FWINCYC].ob_flags&=~HIDETREE;
			mytree[FWINICO].ob_flags&=~HIDETREE;
			mytree[FWINFUL].ob_flags&=~HIDETREE;
			mytree[FWINVSF].ob_flags&=~HIDETREE;
			mytree[FWINVSP].ob_flags&=~HIDETREE;
			mytree[FWINUAR].ob_flags&=~HIDETREE;
			mytree[FWINDAR].ob_flags&=~HIDETREE;
			mytree[FWINSIZ].ob_state&=~DISABLED;
			mytree[FWINSIZ].ob_flags&=~HIDETREE;
			mytree[FWINRAR].ob_flags&=~HIDETREE;
			mytree[FWINLAR].ob_flags&=~HIDETREE;
			mytree[FWINHSF].ob_flags&=~HIDETREE;
			mytree[FWINHSP].ob_flags&=~HIDETREE;

			if (!(W[x].gadget & wCLOSE))	mytree[FWINCLS].ob_flags|=HIDETREE;	else	{	nH++;	}
			if (!(W[x].gadget & wMENU))	mytree[FWINPOP].ob_flags|=HIDETREE;	else	{	nH++;	}
			if (!(W[x].gadget & wCYCLE))	mytree[FWINCYC].ob_flags|=HIDETREE;	else	{	nH++;	}
			if (!(W[x].gadget & wICON))	mytree[FWINICO].ob_flags|=HIDETREE;	else	{	nH++;	}
			if (!(W[x].gadget & wFULL))	mytree[FWINFUL].ob_flags|=HIDETREE;	else	{	nH++;	}
			if (!(W[x].gadget & wUARROW))	mytree[FWINUAR].ob_flags|=HIDETREE;	else	{	nD++;	isD=1;	}
			if (!(W[x].gadget & wDARROW))	mytree[FWINDAR].ob_flags|=HIDETREE;	else	{	nD++;	isD=1;	}
			if (!(W[x].gadget & wRARROW))	mytree[FWINRAR].ob_flags|=HIDETREE;	else	{	nB++;	isB=1;	}
			if (!(W[x].gadget & wLARROW))	mytree[FWINLAR].ob_flags|=HIDETREE;	else	{	nB++;	isB=1;	}

			if (W[x].gadget & wVSLIDE)
				isD=1;
			else
			{
				mytree[FWINVSP].ob_flags|=HIDETREE;
				if (!isD)
					mytree[FWINVSF].ob_flags|=HIDETREE;
			}
			if (W[x].gadget & wHSLIDE)
				isB=1;
			else
			{
				mytree[FWINHSP].ob_flags|=HIDETREE;
				if (!isB)
					mytree[FWINHSF].ob_flags|=HIDETREE;
			}
			if (W[x].gadget & wSIZE)
			{
				if ( !isD && !isB )
				{
					isD=1;
					mytree[FWINVSF].ob_flags&=~HIDETREE;
				}
			}
			else
			{
				if ( isB || isD )
					mytree[FWINSIZ].ob_state|=DISABLED;
				else
					mytree[FWINSIZ].ob_flags|=HIDETREE;
			}

			W[x].xwork=win->xwork;
			W[x].ywork=win->ywork;
			W[x].wwork=win->wwork;
			W[x].hwork=win->hwork;
			W[x].xwind=win->xwind;
			W[x].ywind=win->ywind;
			W[x].wwind=win->wwind;
			W[x].hwind=win->hwind;
			W[x].xfull=win->xfull;
			W[x].yfull=win->yfull;
			W[x].wfull=win->wfull;
			W[x].hfull=win->hfull;

			if ( win->xwork != -1 )
			{
				__W[x].mwwork=W[x].wfull+isD*(1+WW);
				__W[x].mhwork=W[x].hfull+(1+isB)*(1+HH);
				__W[x].mxwork=W[x].xfull;
				__W[x].mywork=W[x].yfull-1-HH;
				wind_calc(WC_BORDER,0,__W[x].mxwork,__W[x].mywork,__W[x].mwwork,__W[x].mhwork,
					&W[x].xfull,&W[x].yfull,&W[x].wfull,&W[x].hfull);
				if (glb.opt.full)
				{
					W[x].wfull=min( W[x].wfull , (int)(0.9*(float)glb.wdesk) );
					W[x].hfull=min( W[x].hfull , (int)(0.9*(float)glb.hdesk) );
					W[x].xfull=max( W[x].xfull , glb.xdesk+(int)(0.05*(float)glb.wdesk) );
					W[x].yfull=max( W[x].yfull , glb.ydesk+(int)(0.05*(float)glb.hdesk) );
					W[x].xfull=min( W[x].xfull , glb.xdesk+(int)(0.95*(float)glb.wdesk)-W[x].wfull );
					W[x].yfull=min( W[x].yfull , glb.ydesk+(int)(0.95*(float)glb.hdesk)-W[x].hfull );
				}
				else
				{
					W[x].wfull=min( W[x].wfull , glb.wdesk );
					W[x].hfull=min( W[x].hfull , glb.hdesk );
					W[x].xfull=max( W[x].xfull , glb.xdesk );
					W[x].yfull=max( W[x].yfull , glb.ydesk );
					W[x].xfull=min( W[x].xfull , glb.xdesk+glb.wdesk-W[x].wfull );
					W[x].yfull=min( W[x].yfull , glb.ydesk+glb.hdesk-W[x].hfull );
				}
			}
			else
			{
				if (glb.opt.full)
				{
					W[x].wfull=min( W[x].wfull , (int)(0.9*(float)glb.wdesk) );
					W[x].hfull=min( W[x].hfull , (int)(0.9*(float)glb.hdesk) );
					W[x].xfull=max( W[x].xfull , glb.xdesk+(int)(0.05*(float)glb.wdesk) );
					W[x].yfull=max( W[x].yfull , glb.ydesk+(int)(0.05*(float)glb.hdesk) );
					W[x].xfull=min( W[x].xfull , glb.xdesk+(int)(0.95*(float)glb.wdesk)-W[x].wfull );
					W[x].yfull=min( W[x].yfull , glb.ydesk+(int)(0.95*(float)glb.hdesk)-W[x].hfull );

					W[x].wwind=min( W[x].wwind , (int)(0.9*(float)glb.wdesk) );
					W[x].hwind=min( W[x].hwind , (int)(0.9*(float)glb.hdesk) );
					W[x].xwind=max( W[x].xwind , glb.xdesk+(int)(0.05*(float)glb.wdesk) );
					W[x].ywind=max( W[x].ywind , glb.ydesk+(int)(0.05*(float)glb.hdesk) );
					W[x].xwind=min( W[x].xwind , glb.xdesk+(int)(0.95*(float)glb.wdesk)-W[x].wwind );
					W[x].ywind=min( W[x].ywind , glb.ydesk+(int)(0.95*(float)glb.hdesk)-W[x].hwind );
				}
				else
				{
					W[x].wfull=min( W[x].wfull , glb.wdesk );
					W[x].hfull=min( W[x].hfull , glb.hdesk );
					W[x].xfull=max( W[x].xfull , glb.xdesk );
					W[x].yfull=max( W[x].yfull , glb.ydesk );
					W[x].xfull=min( W[x].xfull , glb.xdesk+glb.wdesk-W[x].wfull );
					W[x].yfull=min( W[x].yfull , glb.ydesk+glb.hdesk-W[x].hfull );

					W[x].wwind=min( W[x].wwind , glb.wdesk );
					W[x].hwind=min( W[x].hwind , glb.hdesk );
					W[x].xwind=max( W[x].xwind , glb.xdesk );
					W[x].ywind=max( W[x].ywind , glb.ydesk );
					W[x].xwind=min( W[x].xwind , glb.xdesk+glb.wdesk-W[x].wwind );
					W[x].ywind=min( W[x].ywind , glb.ydesk+glb.hdesk-W[x].hwind );
				}
			}

			if (win->xwork!=-1)
			{
				__W[x].mwwork=W[x].wwork+isD*(1+WW);
				__W[x].mhwork=W[x].hwork+(1+isB)*(1+HH);
				__W[x].mxwork=W[x].xwork;
				__W[x].mywork=W[x].ywork-1-HH;
				wind_calc(WC_BORDER,0,__W[x].mxwork,__W[x].mywork,__W[x].mwwork,__W[x].mhwork,
					&W[x].xwind,&W[x].ywind,&W[x].wwind,&W[x].hwind);
			}
			else
			{
				wind_calc(WC_BORDER,0,W[x].xwind,W[x].ywind,W[x].wwind,W[x].hwind,
					&__W[x].mxwork,&__W[x].mywork,&__W[x].mwwork,&__W[x].mhwork);
				W[x].wwork=__W[x].mwwork-isD*(1+WW);
				W[x].hwork=__W[x].mhwork-(1+isB)*(1+HH);
				W[x].xwork=__W[x].mxwork;
				W[x].ywork=__W[x].mywork+1+HH;
			}

			if	(W[x].wwind>W[x].wfull)
			{
				W[x].wwind=W[x].wfull;
				wind_calc(WC_WORK,0,W[x].xwind,W[x].ywind,W[x].wwind,W[x].hwind,
					&__W[x].mxwork,&__W[x].mywork,&__W[x].mwwork,&__W[x].mhwork);
				W[x].hwork	=	__W[x].mhwork-(1+isB)*(1+HH);
			}
			if	(W[x].hwind>W[x].hfull)
			{
				W[x].hwind=W[x].hfull;
				wind_calc(WC_WORK,0,W[x].xwind,W[x].ywind,W[x].wwind,W[x].hwind,
					&__W[x].mxwork,&__W[x].mywork,&__W[x].mwwork,&__W[x].mhwork);
				W[x].wwork	=	__W[x].mwwork-isD*(1+WW);
			}
			if ( (W[x].xwind+W[x].wwind>W[x].xfull+W[x].wfull-1) || (W[x].xwind<W[x].xfull+1)
					|| (W[x].ywind+W[x].hwind>W[x].yfull+W[x].hfull-1) || (W[x].ywind<W[x].yfull+1) )
			{
				W[x].xwind=min(W[x].xwind,W[x].xfull+W[x].wfull);
				W[x].ywind=min(W[x].ywind,W[x].yfull+W[x].hfull);
				W[x].xwind=max(W[x].xwind,W[x].xfull);
				W[x].ywind=max(W[x].ywind,W[x].yfull);
				wind_calc(WC_WORK,0,W[x].xwind,W[x].ywind,W[x].wwind,W[x].hwind,
					&__W[x].mxwork,&__W[x].mywork,&__W[x].mwwork,&__W[x].mhwork);
			}

			if ( __W[x].mxwork%16 && W[x].gadget&wXWORK16 )
			{
				dum=16-__W[x].mxwork%16;
				W[x].xwork+=dum;
				W[x].xwind+=dum;
				__W[x].mxwork+=dum;
			}

			if (W[x].gadget & wCLOSE)		mytree[FWINCLS].ob_x=0;
			mytree[FWINAME].ob_width=__W[x].mwwork-nH*WW-2;
			mytree[FWINAME].ob_height=HH-2;
			mytree[FWINAME].ob_state|=SELECTED;
			if (W[x].gadget & wCLOSE)		mytree[FWINAME].ob_x=WW+1;
			else									mytree[FWINAME].ob_x=1;
			mytree[FWINAME].ob_y=1;

			X=__W[x].mwwork-WW;
			if (W[x].gadget & wFULL)		{	mytree[FWINFUL].ob_x=X;		X-=WW;	}
			if (W[x].gadget & wMENU)		{	mytree[FWINPOP].ob_x=X;		X-=WW;	}
			if (W[x].gadget & wICON)		{	mytree[FWINICO].ob_x=X;		X-=WW;	}
			if (W[x].gadget & wCYCLE)		{	mytree[FWINCYC].ob_x=X;		X-=WW;	}

			mytree[FWINUAR].ob_x	=	__W[x].mwwork-WW;
			mytree[FWINDAR].ob_x	=	__W[x].mwwork-WW;
			mytree[FWINSIZ].ob_x	=	__W[x].mwwork-WW;

			Y=__W[x].mhwork-HH;
			mytree[FWINSIZ].ob_y=Y;	Y-=HH;
			if (W[x].gadget & wDARROW)		{	mytree[FWINDAR].ob_y=Y;	Y-=HH;	}
			if	(W[x].gadget & wUARROW)		{	mytree[FWINUAR].ob_y=Y;	Y-=HH;	}

			mytree[FWINVSF].ob_x			=	__W[x].mwwork-WW;
			mytree[FWINVSF].ob_y			=	HH+1;
			mytree[FWINVSF].ob_height	=	__W[x].mhwork-(1+nD)*HH-1;
			mytree[FWINVSF].ob_width	=	WW;
			mytree[FWINVSP].ob_x			=	0;
			mytree[FWINVSP].ob_width	=	WW;

			mytree[FWINHSF].ob_x			=	0;
			mytree[FWINHSF].ob_y			=	__W[x].mhwork-HH;
			mytree[FWINHSF].ob_width	=	__W[x].mwwork-nB*WW;
			mytree[FWINHSF].ob_height	=	HH;
			mytree[FWINHSP].ob_y			=	0;
			mytree[FWINHSP].ob_height	=	HH;

			mytree[FWINLAR].ob_y=mytree[FWINHSF].ob_y;
			mytree[FWINRAR].ob_y=mytree[FWINHSF].ob_y;
			mytree[FWINSIZ].ob_y=mytree[FWINHSF].ob_y;

			X=__W[x].mwwork-WW;
			mytree[FWINSIZ].ob_x=X;	X-=WW;
			if (W[x].gadget & wRARROW)		{	mytree[FWINRAR].ob_x=X;	X-=WW;	}
			if (W[x].gadget & wLARROW)		{	mytree[FWINLAR].ob_x=X;	X-=WW;	}

			W[x].xslidlen=100;
			W[x].yslidlen=100;
			W[x].xslidpos=0;
			W[x].yslidpos=0;

			mytree->ob_width=__W[x].mwwork;
			mytree->ob_height=__W[x].mhwork;

			__W[x].xold	=	W[x].xwind;
			__W[x].yold	=	W[x].ywind;
			__W[x].wold	=	W[x].wwind;
			__W[x].hold	=	W[x].hwind;

			handle=wind_create(0,W[x].xfull,W[x].yfull,W[x].wfull,W[x].hfull);
			if (handle>0)
			{
				W[x].handle						=	handle;
				__W[x].params.x				=	0;
				__W[x].params.y				=	HH;
				__W[x].params.w				=	isD*WW;
				__W[x].params.h				=	isB*HH;
				__W[x].params._box.x			=	mytree->ob_x;
				__W[x].params._box.y			=	mytree->ob_y;
				__W[x].params._box.w			=	mytree->ob_width;
				__W[x].params._box.h			=	mytree->ob_height;
				__W[x].params._box.flags	=	mytree->ob_flags;
				__W[x].params._name.x		=	mytree[FWINAME].ob_x;
				__W[x].params._name.y		=	mytree[FWINAME].ob_y;
				__W[x].params._name.w		=	mytree[FWINAME].ob_width;
				__W[x].params._name.h		=	mytree[FWINAME].ob_height;
				__W[x].params._name.flags	=	mytree[FWINAME].ob_flags;
				__W[x].params._close.x		=	mytree[FWINCLS].ob_x;
				__W[x].params._close.y		=	mytree[FWINCLS].ob_y;
				__W[x].params._close.flags	=	mytree[FWINCLS].ob_flags;
				__W[x].params._menu.x		=	mytree[FWINPOP].ob_x;
				__W[x].params._menu.y		=	mytree[FWINPOP].ob_y;
				__W[x].params._menu.flags	=	mytree[FWINPOP].ob_flags;
				__W[x].params._cycle.x		=	mytree[FWINCYC].ob_x;
				__W[x].params._cycle.y		=	mytree[FWINCYC].ob_y;
				__W[x].params._cycle.flags	=	mytree[FWINCYC].ob_flags;
				__W[x].params._icon.x		=	mytree[FWINICO].ob_x;
				__W[x].params._icon.y		=	mytree[FWINICO].ob_y;
				__W[x].params._icon.flags	=	mytree[FWINICO].ob_flags;
				__W[x].params._full.x		=	mytree[FWINFUL].ob_x;
				__W[x].params._full.y		=	mytree[FWINFUL].ob_y;
				__W[x].params._full.flags	=	mytree[FWINFUL].ob_flags;
				__W[x].params._vslf.x		=	mytree[FWINVSF].ob_x;
				__W[x].params._vslf.y		=	mytree[FWINVSF].ob_y;
				__W[x].params._vslf.w		=	mytree[FWINVSF].ob_width;
				__W[x].params._vslf.h		=	mytree[FWINVSF].ob_height;
				__W[x].params._vslf.flags	=	mytree[FWINVSF].ob_flags;
				__W[x].params._vslp.x		=	mytree[FWINVSP].ob_x;
				__W[x].params._vslp.y		=	mytree[FWINVSP].ob_y;
				__W[x].params._vslp.w		=	mytree[FWINVSP].ob_width;
				__W[x].params._vslp.h		=	mytree[FWINVSP].ob_height;
				__W[x].params._vslp.flags	=	mytree[FWINVSP].ob_flags;
				__W[x].params._vsli.x		=	mytree[FWINVSI].ob_x;
				__W[x].params._vsli.y		=	mytree[FWINVSI].ob_y;
				__W[x].params._vsli.w		=	mytree[FWINVSI].ob_width;
				__W[x].params._vsli.h		=	mytree[FWINVSI].ob_height;
				__W[x].params._vsli.flags	=	mytree[FWINVSI].ob_flags;
				__W[x].params._uarr.x		=	mytree[FWINUAR].ob_x;
				__W[x].params._uarr.y		=	mytree[FWINUAR].ob_y;
				__W[x].params._uarr.flags	=	mytree[FWINUAR].ob_flags;
				__W[x].params._darr.x		=	mytree[FWINDAR].ob_x;
				__W[x].params._darr.y		=	mytree[FWINDAR].ob_y;
				__W[x].params._darr.flags	=	mytree[FWINDAR].ob_flags;
				__W[x].params._size.x		=	mytree[FWINSIZ].ob_x;
				__W[x].params._size.y		=	mytree[FWINSIZ].ob_y;
				__W[x].params._size.flags	=	mytree[FWINSIZ].ob_flags;
				__W[x].params._rarr.x		=	mytree[FWINRAR].ob_x;
				__W[x].params._rarr.y		=	mytree[FWINRAR].ob_y;
				__W[x].params._rarr.flags	=	mytree[FWINRAR].ob_flags;
				__W[x].params._larr.x		=	mytree[FWINLAR].ob_x;
				__W[x].params._larr.y		=	mytree[FWINLAR].ob_y;
				__W[x].params._larr.flags	=	mytree[FWINLAR].ob_flags;
				__W[x].params._hslf.x		=	mytree[FWINHSF].ob_x;
				__W[x].params._hslf.y		=	mytree[FWINHSF].ob_y;
				__W[x].params._hslf.w		=	mytree[FWINHSF].ob_width;
				__W[x].params._hslf.h		=	mytree[FWINHSF].ob_height;
				__W[x].params._hslf.flags	=	mytree[FWINHSF].ob_flags;
				__W[x].params._hslp.x		=	mytree[FWINHSP].ob_x;
				__W[x].params._hslp.y		=	mytree[FWINHSP].ob_y;
				__W[x].params._hslp.w		=	mytree[FWINHSP].ob_width;
				__W[x].params._hslp.h		=	mytree[FWINHSP].ob_height;
				__W[x].params._hslp.flags	=	mytree[FWINHSP].ob_flags;
				__W[x].params._hsli.x		=	mytree[FWINHSI].ob_x;
				__W[x].params._hsli.y		=	mytree[FWINHSI].ob_y;
				__W[x].params._hsli.w		=	mytree[FWINHSI].ob_width;
				__W[x].params._hsli.h		=	mytree[FWINHSI].ob_height;
				__W[x].params._hsli.flags	=	mytree[FWINHSI].ob_flags;

				__W[x].wmini	=	WW*10;
				__W[x].hmini	=	HH*7;
				W[x].redraw		=	win->redraw;	/*	Pointeur routine redraw			*/
				W[x].pop			=	win->pop;		/*	Pointeur routine popup			*/
				W[x].top			=	win->top;		/*	Pointeur routine top				*/
				W[x].closed		=	win->closed;	/*	Pointeur routine close			*/
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
				W[x].popup		=	win->popup;
				if (win->icon==-1)
					W[x].icon		=	ICONE|FLAGS15;
				else
					W[x].icon		=	win->icon;
				wind_set(W[x].handle,WF_BEVENT,1,0,0,0);
				wind_open(W[x].handle,W[x].xwind,W[x].ywind,W[x].wwind,W[x].hwind);
				wind_get(W[x].handle,WF_WORKXYWH,&__W[x].mxwork,&__W[x].mywork,&__W[x].mwwork,&__W[x].mhwork);
				W[x].xwork=__W[x].mxwork+__W[x].params.x;
				W[x].ywork=__W[x].mywork+__W[x].params.y+1;
				_setWindow(x);
				if (W[x].init!=0)
					(*W[x].init)(x);
			}
			else
			{
				if (glb.opt.lang==L_FRENCH)
					form_alert(1,__rsc.head.frstr[_0NOWIN]);
				else
					form_alert(1,__rsc.head.frstr[_1NOWIN]);
			}
		}
	}
	else
	{
		if (glb.opt.lang==L_FRENCH)
			form_alert(1,__rsc.head.frstr[_0NOWIN]);
		else
			form_alert(1,__rsc.head.frstr[_1NOWIN]);
	}
	return x;
}


/******************************************************************************/
/*	This functions simply close a window !													*/
/******************************************************************************/
void _winClose(int i)
{
	if (i!=-1)
		_closed(i);
}

/******************************************************************************/
/*	This function adapts the RSC tree to a window										*/
/******************************************************************************/
void _setWindow(int i)
{
	int		X,Y,WW,HH;
	int		/*dum,*/nH=0,nD=0,nB=0,isB=0,isD=0;

	if (i!=-1)
	{
		WW=mytree[wCLOSE].ob_width;
		HH=mytree[wCLOSE].ob_height;

		if (W[i].gadget & wCLOSE)	{	nH++;	}
		if (W[i].gadget & wMENU)	{	nH++;	}
		if (W[i].gadget & wCYCLE)	{	nH++;	}
		if (W[i].gadget & wICON)	{	nH++;	}
		if (W[i].gadget & wFULL)	{	nH++;	}
		if (W[i].gadget & wUARROW)	{	nD++;	isD=1;	}
		if (W[i].gadget & wDARROW)	{	nD++;	isD=1;	}
		if (W[i].gadget & wRARROW)	{	nB++;	isB=1;	}
		if (W[i].gadget & wLARROW)	{	nB++;	isB=1;	}

		if (W[i].gadget & wVSLIDE)
			isD=1;
		else
		{
			mytree[FWINVSP].ob_flags|=HIDETREE;
			if (!isD)
				mytree[FWINVSF].ob_flags|=HIDETREE;
		}
		if (W[i].gadget & wHSLIDE)
			isB=1;
		else
		{
			mytree[FWINHSP].ob_flags|=HIDETREE;
			if (!isB)
				mytree[FWINHSF].ob_flags|=HIDETREE;
		}
		if (W[i].gadget & wSIZE)
		{
			if ( !isD && !isB )
			{
				isD=1;
				mytree[FWINVSF].ob_flags&=~HIDETREE;
			}
		}
		else
		{
			if ( isB || isD )
				mytree[FWINSIZ].ob_state|=DISABLED;
			else
				mytree[FWINSIZ].ob_flags|=HIDETREE;
		}

		wind_calc(WC_WORK,0,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind,
			&__W[i].mxwork,&__W[i].mywork,&__W[i].mwwork,&__W[i].mhwork);

		W[i].wwork	=	__W[i].mwwork-isD*(1+WW);
		W[i].hwork	=	__W[i].mhwork-(1+isB)*(1+HH);

		if (W[i].gadget & wCLOSE)		mytree[FWINCLS].ob_x=0;
		mytree[FWINAME].ob_width=__W[i].mwwork-nH*WW-2;
		mytree[FWINAME].ob_height=HH-2;
		mytree[FWINAME].ob_state|=SELECTED;
		if (W[i].gadget & wCLOSE)		mytree[FWINAME].ob_x=WW+1;
		else									mytree[FWINAME].ob_x=1;
		mytree[FWINAME].ob_y=1;
		X=__W[i].mwwork-WW;
		if (W[i].gadget & wFULL)		{	mytree[FWINFUL].ob_x=X;		X-=WW;	}
		if (W[i].gadget & wMENU)		{	mytree[FWINPOP].ob_x=X;		X-=WW;	}
		if (W[i].gadget & wICON)		{	mytree[FWINICO].ob_x=X;		X-=WW;	}
		if (W[i].gadget & wCYCLE)		{	mytree[FWINCYC].ob_x=X;		X-=WW;	}

		mytree[FWINUAR].ob_x	=	__W[i].mwwork-WW;
		mytree[FWINDAR].ob_x	=	__W[i].mwwork-WW;
		mytree[FWINSIZ].ob_x	=	__W[i].mwwork-WW;

		Y=__W[i].mhwork-HH;
		mytree[FWINSIZ].ob_y=Y;	Y-=HH;
		if (W[i].gadget & wDARROW)		{	mytree[FWINDAR].ob_y=Y;	Y-=HH;	}
		if	(W[i].gadget & wUARROW)		{	mytree[FWINUAR].ob_y=Y;	Y-=HH;	}

		mytree[FWINVSF].ob_x			=	__W[i].mwwork-WW;
		mytree[FWINVSF].ob_y			=	HH+1;
		mytree[FWINVSF].ob_height	=	__W[i].mhwork-(1+nD)*HH-1;
		mytree[FWINVSF].ob_width	=	WW;
		mytree[FWINVSP].ob_x			=	0;
		mytree[FWINVSP].ob_width	=	WW;

		mytree[FWINHSF].ob_x			=	0;
		mytree[FWINHSF].ob_y			=	__W[i].mhwork-HH;
		mytree[FWINHSF].ob_width	=	__W[i].mwwork-nB*WW;
		mytree[FWINHSF].ob_height	=	HH;
		mytree[FWINHSP].ob_y			=	0;
		mytree[FWINHSP].ob_height	=	HH;

		mytree[FWINLAR].ob_y=mytree[FWINHSF].ob_y;
		mytree[FWINRAR].ob_y=mytree[FWINHSF].ob_y;
		mytree[FWINSIZ].ob_y=mytree[FWINHSF].ob_y;

		X=__W[i].mwwork-WW;
		mytree[FWINSIZ].ob_x=X;	X-=WW;
		if (W[i].gadget & wRARROW)		{	mytree[FWINRAR].ob_x=X;	X-=WW;	}
		if (W[i].gadget & wLARROW)		{	mytree[FWINLAR].ob_x=X;	X-=WW;	}

		mytree->ob_width=__W[i].mwwork;
		mytree->ob_height=__W[i].mhwork;

		mytree[FWINHSP].ob_width	=	(int)((double)mytree[FWINHSF].ob_width*(double)W[i].xslidlen/1000.0);
		mytree[FWINHSP].ob_width	=	max(mytree[FWINHSI].ob_width,mytree[FWINHSP].ob_width);
		mytree[FWINHSP].ob_width	=	min(mytree[FWINHSF].ob_width,mytree[FWINHSP].ob_width);
		mytree[FWINHSP].ob_x	=	(int)((double)(mytree[FWINHSF].ob_width-mytree[FWINHSP].ob_width)*(double)W[i].xslidpos/1000.0);
		mytree[FWINHSP].ob_x	=	max(0,mytree[FWINHSP].ob_x);
		mytree[FWINHSP].ob_x	=	min(mytree[FWINHSF].ob_width-mytree[FWINHSP].ob_width,mytree[FWINHSP].ob_x);
		mytree[FWINHSI].ob_x	=	(mytree[FWINHSP].ob_width-mytree[FWINHSI].ob_width)/2;
		mytree[FWINHSI].ob_x	=	max(0,mytree[FWINHSI].ob_x);

		mytree[FWINVSP].ob_height=	(int)((double)mytree[FWINVSF].ob_height*(double)W[i].yslidlen/1000.0);
		mytree[FWINVSP].ob_height=	max(mytree[FWINVSI].ob_height,mytree[FWINVSP].ob_height);
		mytree[FWINVSP].ob_height=	min(mytree[FWINVSF].ob_height,mytree[FWINVSP].ob_height);
		mytree[FWINVSP].ob_y	=	(int)((double)(mytree[FWINVSF].ob_height-mytree[FWINVSP].ob_height)*(double)W[i].yslidpos/1000.0);
		mytree[FWINVSP].ob_y	=	max(0,mytree[FWINVSP].ob_y);
		mytree[FWINVSP].ob_y	=	min(mytree[FWINVSF].ob_height-mytree[FWINVSP].ob_height,mytree[FWINVSP].ob_y);
		mytree[FWINVSI].ob_y	=	(mytree[FWINVSP].ob_height-mytree[FWINVSI].ob_height)/2;
		mytree[FWINVSI].ob_y	=	max(0,mytree[FWINVSI].ob_y);

		__W[i].params.x		=	0;
		__W[i].params.y		=	HH;
		__W[i].params.w		=	isD*WW;
		__W[i].params.h		=	isB*HH;
		__W[i].params._box.x			=	mytree->ob_x;
		__W[i].params._box.y			=	mytree->ob_y;
		__W[i].params._box.w			=	mytree->ob_width;
		__W[i].params._box.h			=	mytree->ob_height;
		__W[i].params._box.flags	=	mytree->ob_flags;
		__W[i].params._name.x		=	mytree[FWINAME].ob_x;
		__W[i].params._name.y		=	mytree[FWINAME].ob_y;
		__W[i].params._name.w		=	mytree[FWINAME].ob_width;
		__W[i].params._name.h		=	mytree[FWINAME].ob_height;
		__W[i].params._name.flags	=	mytree[FWINAME].ob_flags;
		__W[i].params._close.x		=	mytree[FWINCLS].ob_x;
		__W[i].params._close.y		=	mytree[FWINCLS].ob_y;
		__W[i].params._close.flags	=	mytree[FWINCLS].ob_flags;
		__W[i].params._menu.x		=	mytree[FWINPOP].ob_x;
		__W[i].params._menu.y		=	mytree[FWINPOP].ob_y;
		__W[i].params._menu.flags	=	mytree[FWINPOP].ob_flags;
		__W[i].params._cycle.x		=	mytree[FWINCYC].ob_x;
		__W[i].params._cycle.y		=	mytree[FWINCYC].ob_y;
		__W[i].params._cycle.flags	=	mytree[FWINCYC].ob_flags;
		__W[i].params._icon.x		=	mytree[FWINICO].ob_x;
		__W[i].params._icon.y		=	mytree[FWINICO].ob_y;
		__W[i].params._icon.flags	=	mytree[FWINICO].ob_flags;
		__W[i].params._full.x		=	mytree[FWINFUL].ob_x;
		__W[i].params._full.y		=	mytree[FWINFUL].ob_y;
		__W[i].params._full.flags	=	mytree[FWINFUL].ob_flags;
		__W[i].params._vslf.x		=	mytree[FWINVSF].ob_x;
		__W[i].params._vslf.y		=	mytree[FWINVSF].ob_y;
		__W[i].params._vslf.w		=	mytree[FWINVSF].ob_width;
		__W[i].params._vslf.h		=	mytree[FWINVSF].ob_height;
		__W[i].params._vslf.flags	=	mytree[FWINVSF].ob_flags;
		__W[i].params._vslp.x		=	mytree[FWINVSP].ob_x;
		__W[i].params._vslp.y		=	mytree[FWINVSP].ob_y;
		__W[i].params._vslp.w		=	mytree[FWINVSP].ob_width;
		__W[i].params._vslp.h		=	mytree[FWINVSP].ob_height;
		__W[i].params._vslp.flags	=	mytree[FWINVSP].ob_flags;
		__W[i].params._vsli.x		=	mytree[FWINVSI].ob_x;
		__W[i].params._vsli.y		=	mytree[FWINVSI].ob_y;
		__W[i].params._vsli.w		=	mytree[FWINVSI].ob_width;
		__W[i].params._vsli.h		=	mytree[FWINVSI].ob_height;
		__W[i].params._vsli.flags	=	mytree[FWINVSI].ob_flags;
		__W[i].params._uarr.x		=	mytree[FWINUAR].ob_x;
		__W[i].params._uarr.y		=	mytree[FWINUAR].ob_y;
		__W[i].params._uarr.flags	=	mytree[FWINUAR].ob_flags;
		__W[i].params._darr.x		=	mytree[FWINDAR].ob_x;
		__W[i].params._darr.y		=	mytree[FWINDAR].ob_y;
		__W[i].params._darr.flags	=	mytree[FWINDAR].ob_flags;
		__W[i].params._size.x		=	mytree[FWINSIZ].ob_x;
		__W[i].params._size.y		=	mytree[FWINSIZ].ob_y;
		__W[i].params._size.flags	=	mytree[FWINSIZ].ob_flags;
		__W[i].params._rarr.x		=	mytree[FWINRAR].ob_x;
		__W[i].params._rarr.y		=	mytree[FWINRAR].ob_y;
		__W[i].params._rarr.flags	=	mytree[FWINRAR].ob_flags;
		__W[i].params._larr.x		=	mytree[FWINLAR].ob_x;
		__W[i].params._larr.y		=	mytree[FWINLAR].ob_y;
		__W[i].params._larr.flags	=	mytree[FWINLAR].ob_flags;
		__W[i].params._hslf.x		=	mytree[FWINHSF].ob_x;
		__W[i].params._hslf.y		=	mytree[FWINHSF].ob_y;
		__W[i].params._hslf.w		=	mytree[FWINHSF].ob_width;
		__W[i].params._hslf.h		=	mytree[FWINHSF].ob_height;
		__W[i].params._hslf.flags	=	mytree[FWINHSF].ob_flags;
		__W[i].params._hslp.x		=	mytree[FWINHSP].ob_x;
		__W[i].params._hslp.y		=	mytree[FWINHSP].ob_y;
		__W[i].params._hslp.w		=	mytree[FWINHSP].ob_width;
		__W[i].params._hslp.h		=	mytree[FWINHSP].ob_height;
		__W[i].params._hslp.flags	=	mytree[FWINHSP].ob_flags;
		__W[i].params._hsli.x		=	mytree[FWINHSI].ob_x;
		__W[i].params._hsli.y		=	mytree[FWINHSI].ob_y;
		__W[i].params._hsli.w		=	mytree[FWINHSI].ob_width;
		__W[i].params._hsli.h		=	mytree[FWINHSI].ob_height;
		__W[i].params._hsli.flags	=	mytree[FWINHSI].ob_flags;

		W[i].xwork=__W[i].mxwork+__W[i].params.x;
		W[i].ywork=__W[i].mywork+__W[i].params.y+1;
		_redrawWindow(i);
	}
}


/******************************************************************************/
/*	Set the Vertical slider pos & len														*/
/******************************************************************************/
void _winVslid(int i)
{
	GRECT		rd,r;
	int		lattr[6],pxy[4];
	int		WW,HH,nD=0;

	if (i!=-1)
	{
		WW=mytree[wCLOSE].ob_width;
		HH=mytree[wCLOSE].ob_height;

		if (W[i].gadget & wUARROW)	nD++;
		if (W[i].gadget & wDARROW)	nD++;
		if (W[i].gadget & wSIZE)		nD++;

		mytree[FWINVSF].ob_x			=	__W[i].mwwork-WW;
		mytree[FWINVSF].ob_y			=	HH+1;
		mytree[FWINVSF].ob_height	=	__W[i].mhwork-(1+nD)*HH-1;
		mytree[FWINVSF].ob_width	=	WW;
		mytree[FWINVSP].ob_x			=	0;
		mytree[FWINVSP].ob_width	=	WW;

		mytree[FWINVSF].ob_flags	=	__W[i].params._vslf.flags;
		mytree[FWINVSP].ob_flags	=	__W[i].params._vslp.flags;
		mytree[FWINVSI].ob_flags	=	__W[i].params._vsli.flags;

		mytree[FWINVSP].ob_height=	(int)((double)mytree[FWINVSF].ob_height*(double)W[i].yslidlen/1000.0);
		mytree[FWINVSP].ob_height=	max(mytree[FWINVSI].ob_height,mytree[FWINVSP].ob_height);
		mytree[FWINVSP].ob_height=	min(mytree[FWINVSF].ob_height,mytree[FWINVSP].ob_height);
		mytree[FWINVSP].ob_y		=	(int)((double)(mytree[FWINVSF].ob_height-mytree[FWINVSP].ob_height)*(double)W[i].yslidpos/1000.0);
		mytree[FWINVSP].ob_y		=	max(0,mytree[FWINVSP].ob_y);
		mytree[FWINVSP].ob_y		=	min(mytree[FWINVSF].ob_height-mytree[FWINVSP].ob_height,mytree[FWINVSP].ob_y);
		mytree[FWINVSI].ob_y		=	(mytree[FWINVSP].ob_height-mytree[FWINVSI].ob_height)/2;
		mytree[FWINVSI].ob_y		=	max(0,mytree[FWINVSI].ob_y);

		__W[i].params._vslf.x	=	mytree[FWINVSF].ob_x;
		__W[i].params._vslf.y	=	mytree[FWINVSF].ob_y;
		__W[i].params._vslf.w	=	mytree[FWINVSF].ob_width;
		__W[i].params._vslf.h	=	mytree[FWINVSF].ob_height;
		__W[i].params._vslp.x	=	mytree[FWINVSP].ob_x;
		__W[i].params._vslp.y	=	mytree[FWINVSP].ob_y;
		__W[i].params._vslp.w	=	mytree[FWINVSP].ob_width;
		__W[i].params._vslp.h	=	mytree[FWINVSP].ob_height;
		__W[i].params._vsli.x	=	mytree[FWINVSI].ob_x;
		__W[i].params._vsli.y	=	mytree[FWINVSI].ob_y;
		__W[i].params._vsli.w	=	mytree[FWINVSI].ob_width;
		__W[i].params._vsli.h	=	mytree[FWINVSI].ob_height;

		rd.g_x=W[i].xwind;
		rd.g_y=W[i].ywind;
		rd.g_w=W[i].wwind;
		rd.g_h=W[i].hwind;

		wind_get(W[i].handle,WF_FIRSTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
		while (r.g_w && r.g_h)
		{
			if (_rcIntersect(&rd,&r))
			{
				objc_draw(mytree,FWINVSF,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
				_setClip(TRUE,&r);
				vql_attributes(glb.hvdi,lattr);
				vsl_color(glb.hvdi,1);
				vsl_type(glb.hvdi,SOLID);
				vsl_width(glb.hvdi,1);
				pxy[0]=__W[i].mxwork+__W[i].params.x;
				pxy[1]=__W[i].mywork+__W[i].params.y;
				pxy[2]=__W[i].mxwork+__W[i].mwwork;
				pxy[3]=pxy[1];
				v_pline(glb.hvdi,2,pxy);
				if (__W[i].params.w)
				{
					pxy[0]=__W[i].mxwork+__W[i].mwwork-__W[i].params.w-1;
					pxy[1]=__W[i].mywork+__W[i].params.y;
					pxy[2]=pxy[0];
					pxy[3]=__W[i].mywork+__W[i].mhwork-__W[i].params.h-1;
					v_pline(glb.hvdi,2,pxy);
				}
				vsl_type(glb.hvdi,lattr[0]);
				vsl_color(glb.hvdi,lattr[1]);
				_setClip(FALSE,&r);
			}
			wind_get(W[i].handle,WF_NEXTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
		}
	}
}


/******************************************************************************/
/*	Set the Horinzontal slider pos & len													*/
/******************************************************************************/
void _winHslid(int i)
{
	GRECT		rd,r;
	int		lattr[6],pxy[4];
	int		WW,HH,nB=0;

	if (i!=-1)
	{
		WW=mytree[wCLOSE].ob_width;
		HH=mytree[wCLOSE].ob_height;

		if (W[i].gadget & wRARROW)	nB++;
		if (W[i].gadget & wLARROW)	nB++;
		if (W[i].gadget & wSIZE)		nB++;

		mytree[FWINHSF].ob_x			=	0;
		mytree[FWINHSF].ob_y			=	__W[i].mhwork-HH;
		mytree[FWINHSF].ob_width	=	__W[i].mwwork-nB*WW;
		mytree[FWINHSF].ob_height	=	HH;
		mytree[FWINHSP].ob_y			=	0;
		mytree[FWINHSP].ob_height	=	HH;

		mytree[FWINHSF].ob_flags	=	__W[i].params._hslf.flags;
		mytree[FWINHSP].ob_flags	=	__W[i].params._hslp.flags;
		mytree[FWINHSI].ob_flags	=	__W[i].params._hsli.flags;

		mytree[FWINHSP].ob_width	=	(int)((double)mytree[FWINHSF].ob_width*(double)W[i].xslidlen/1000.0);
		mytree[FWINHSP].ob_width	=	max(mytree[FWINHSI].ob_width,mytree[FWINHSP].ob_width);
		mytree[FWINHSP].ob_width	=	min(mytree[FWINHSF].ob_width,mytree[FWINHSP].ob_width);
		mytree[FWINHSP].ob_x		=	(int)((double)(mytree[FWINHSF].ob_width-mytree[FWINHSP].ob_width)*(double)W[i].xslidpos/1000.0);
		mytree[FWINHSP].ob_x		=	max(0,mytree[FWINHSP].ob_x);
		mytree[FWINHSP].ob_x		=	min(mytree[FWINHSF].ob_width-mytree[FWINHSP].ob_width,mytree[FWINHSP].ob_x);
		mytree[FWINHSI].ob_x		=	(mytree[FWINHSP].ob_width-mytree[FWINHSI].ob_width)/2;
		mytree[FWINHSI].ob_x		=	max(0,mytree[FWINHSI].ob_x);

		__W[i].params._hslf.x	=	mytree[FWINHSF].ob_x;
		__W[i].params._hslf.y	=	mytree[FWINHSF].ob_y;
		__W[i].params._hslf.w	=	mytree[FWINHSF].ob_width;
		__W[i].params._hslf.h	=	mytree[FWINHSF].ob_height;
		__W[i].params._hslp.x	=	mytree[FWINHSP].ob_x;
		__W[i].params._hslp.y	=	mytree[FWINHSP].ob_y;
		__W[i].params._hslp.w	=	mytree[FWINHSP].ob_width;
		__W[i].params._hslp.h	=	mytree[FWINHSP].ob_height;
		__W[i].params._hsli.x	=	mytree[FWINHSI].ob_x;
		__W[i].params._hsli.y	=	mytree[FWINHSI].ob_y;
		__W[i].params._hsli.w	=	mytree[FWINHSI].ob_width;
		__W[i].params._hsli.h	=	mytree[FWINHSI].ob_height;

		rd.g_x=W[i].xwind;
		rd.g_y=W[i].ywind;
		rd.g_w=W[i].wwind;
		rd.g_h=W[i].hwind;

		wind_get(W[i].handle,WF_FIRSTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
		while (r.g_w && r.g_h)
		{
			if (_rcIntersect(&rd,&r))
			{
				objc_draw(mytree,FWINHSF,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
				_setClip(TRUE,&r);
				vql_attributes(glb.hvdi,lattr);
				vsl_color(glb.hvdi,1);
				vsl_type(glb.hvdi,SOLID);
				vsl_width(glb.hvdi,1);
				pxy[0]=__W[i].mxwork+__W[i].params.x;
				pxy[1]=__W[i].mywork+__W[i].params.y;
				pxy[2]=__W[i].mxwork+__W[i].mwwork;
				pxy[3]=pxy[1];
				v_pline(glb.hvdi,2,pxy);
				if (__W[i].params.h)
				{
					pxy[0]=__W[i].mxwork+__W[i].params.x;
					pxy[1]=__W[i].mywork+__W[i].mhwork-__W[i].params.h-1;
					pxy[2]=__W[i].mxwork+__W[i].mwwork;
					pxy[3]=pxy[1];
					v_pline(glb.hvdi,2,pxy);
				}
				vsl_type(glb.hvdi,lattr[0]);
				vsl_color(glb.hvdi,lattr[1]);
				_setClip(FALSE,&r);
			}
			wind_get(W[i].handle,WF_NEXTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
		}
	}
}


/******************************************************************************/
/*	clic on desktop: not terminated... sorry... not begun !! 8-((					*/
/******************************************************************************/
void _clicBureau(int mx,int my,int mk,int nmb)
{
	int	i=0,pop;
	int	x,y;

	if ( mk==-1 || glb.desk==-1 )
		i=1;
	else
	{
		if ( objc_find(glb.rsc.head.trindex[glb.desk],ROOT,MAX_DEPTH,mx,my)==ROOT )
			i=1;
		else if (glb.FclicB!=0)
			i=2;
	}
	if ( (i==1) && (nmb>1) )
	{
		x=mx-__rsc.head.trindex[PLIB]->ob_width/2;
		y=my-__rsc.head.trindex[PLIB]->ob_height/2;
		wind_update(BEG_MCTRL);
		pop=_popUp(__rsc.head.trindex[PLIB],x,y);
		wind_update(END_MCTRL);
		switch	(pop)
		{
				case	PLIBINF:
					_winForm(FINF|FLAGS15,_getLang(__rsc.head.frstr[WINF]),"EGlib","_INFO",-1,ICINF|FLAGS15);
					break;
				case	PLIBMEM:
					_myInitForm(FMEM,FMEMSYS);
					_myInitForm(FMEM,FMEMLEN);
					_myInitForm(FMEM,FMEMFRE);
					_winForm(FMEM|FLAGS15,_getLang(__rsc.head.frstr[WMEM]),"EGlib","_MEMORY",-1,ICMEM|FLAGS15);
					break;
				case	PLIBFNT:
					_winForm(FFNT|FLAGS15,_getLang(__rsc.head.frstr[WFNT]),"EGlib","_FONT",-1,ICFNT|FLAGS15);
					break;
				case	PLIBOPT:
					_winForm(FOPT|FLAGS15,_getLang(__rsc.head.frstr[WOPT]),"EGlib","_OPTION",-1,ICOPT|FLAGS15);
					break;
				case	PLIBSYS:
					_winForm(FSYS|FLAGS15,_getLang(__rsc.head.frstr[WSYS]),"EGlib","_SYSINFO",-1,ICSYS|FLAGS15);
					break;
				case	PLIBCNF:
					_saveConfig();
					break;
				case	PLIBHLP:
					_Aide();
					break;
		}
	}
	else if (i==2)
		(*glb.FclicB)(mx,my,mk);
}


/******************************************************************************/
/*	Handle top events																				*/
/******************************************************************************/
void _top(int i)
{
	if (i!=-1)
	{
		wind_set(W[i].handle,WF_TOP);
		if (W[i].top!=0)
			(*W[i].top)(i);
	}
}
void _untop(int i)
{
	if (i!=-1)
	{
		_maketop();
		if (W[i].untop!=0)
			(*W[i].untop)(i);
	}
}
void _ontop(int i)
{
	if (i!=-1)
	{
		_maketop();
		if (W[i].ontop!=0)
			(*W[i].ontop)(i);
	}
}


/******************************************************************************/
/*	Handle closed event																			*/
/******************************************************************************/
void _closed(int i)
{
	int	ha;

	if (i!=-1)
	{
		ha=W[i].handle;
		wind_close(ha);
		wind_delete(ha);
		W[i].handle=-1;
		if (W[i].closed!=0)
			(*W[i].closed)(i);
	}
}


/******************************************************************************/
/*	Handle fulled event																			*/
/******************************************************************************/
void _full(int i)
{
	int		dum,ha;

	if (i!=-1)
	{
		ha=W[i].handle;
		if ( W[i].wwind==W[i].wfull && W[i].hwind==W[i].hfull )
		{
			W[i].xwind=__W[i].xold;
			W[i].ywind=__W[i].yold;
			W[i].wwind=__W[i].wold;
			W[i].hwind=__W[i].hold;
		}
		else
		{
			__W[i].xold	=	W[i].xwind;
			__W[i].yold	=	W[i].ywind;
			__W[i].wold	=	W[i].wwind;
			__W[i].hold	=	W[i].hwind;
			W[i].xwind	=	W[i].xfull;
			W[i].ywind	=	W[i].yfull;
			W[i].wwind	=	W[i].wfull;
			W[i].hwind	=	W[i].hfull;
		}
		wind_calc(WC_WORK,0,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind,&__W[i].mxwork,&__W[i].mywork,&__W[i].mwwork,&__W[i].mhwork);
		if ( (__W[i].xold-W[i].xwind)%16 && W[i].gadget&wXWORK16 )
		{
			dum=16-__W[i].mxwork%16;
			W[i].xwind+=dum;
			__W[i].mxwork+=dum;
		}
		wind_set(ha,WF_CURRXYWH,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
		wind_get(ha,WF_WORKXYWH,&__W[i].mxwork,&__W[i].mywork,&__W[i].mwwork,&__W[i].mhwork);
		_setWindow(i);
		if (W[i].full!=0)
			(*W[i].full)(i);
	}
}


/******************************************************************************/
/*	Handle sized event																			*/
/******************************************************************************/
void _size(int i,int w,int h)
{
	int		ha,nW,nH;

	if (i!=-1)
	{
		ha=W[i].handle;
		nW=w;
		nH=h;
		if ( (W[i].wwind!=nW) || (W[i].hwind!=nH) )
		{
			W[i].wwind=nW;
			W[i].hwind=nH;
			wind_set(ha,WF_CURRXYWH,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			wind_get(ha,WF_WORKXYWH,&__W[i].mxwork,&__W[i].mywork,&__W[i].mwwork,&__W[i].mhwork);
			_setWindow(i);
			if (W[i].size!=0)
				(*W[i].size)(i,w,h);
		}
	}
}


/******************************************************************************/
/*	Handle moved event																			*/
/******************************************************************************/
void _move(int i,int xx,int yy)
{
	int		ha,dum,oldx,x,y,w,h;

	if (i!=-1)
	{
		ha=W[i].handle;
		wind_get(ha,WF_CURRXYWH,&x,&y,&w,&h);
		x=xx;
		y=yy;

		x=max(glb.xdesk,x);
		y=max(glb.ydesk,y);

		if (W[i].smallflag)
		{
			__W[i].xsmall=x;
			__W[i].ysmall=y;
			__W[i].wsmall=w;
			__W[i].hsmall=h;
			wind_set(ha,WF_CURRXYWH,x,y,w,h);
			wind_get(ha,WF_WORKXYWH,&__W[i].xwsmall,&__W[i].ywsmall,&__W[i].wwsmall,&__W[i].hwsmall);
		}
		else
		{
			oldx=W[i].xwind;
			W[i].xwind=x;
			W[i].ywind=y;

			wind_calc(WC_WORK,0,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind,&__W[i].mxwork,&__W[i].mywork,&__W[i].mwwork,&__W[i].mhwork);
			if ( (oldx-x)%16 && W[i].gadget&wXWORK16 )
			{
				dum=16-__W[i].mxwork%16;
				W[i].xwind+=dum;
				__W[i].mxwork+=dum;
			}
			wind_set(ha,WF_CURRXYWH,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			wind_get(ha,WF_WORKXYWH,&__W[i].mxwork,&__W[i].mywork,&__W[i].mwwork,&__W[i].mhwork);
			W[i].xwork=__W[i].mxwork+__W[i].params.x;
			W[i].ywork=__W[i].mywork+__W[i].params.y+1;
			if ( W[i].move!=0 && (oldx!=W[i].xwind || yy!=y) )
				(*W[i].move)(i,W[i].xwind,W[i].ywind);
		}
	}
}


/******************************************************************************/
/*	Handle redraw event																			*/
/******************************************************************************/
void _redraw(int i,int x,int y,int w,int h)
{
	OBJECT	*tree;
	GRECT		rd,my1,my2;
	int		ha,lattr[6],pxy[8];

	if (i!=-1)
	if (W[i].handle>0)
	{
		ha=W[i].handle;
		w=min(w,1+glb.out[0]-x);
		h=min(h,1+glb.out[1]-y);
		rd.g_x=x;
		rd.g_y=y;
		rd.g_w=w;
		rd.g_h=h;

		graf_mouse(M_OFF,0);
		wind_update(BEG_UPDATE);
		_makeform(i);

		wind_get(ha,WF_FIRSTXYWH,&__r.g_x,&__r.g_y,&__r.g_w,&__r.g_h);
		while (__r.g_w && __r.g_h)
		{
			if (_rcIntersect(&rd,&__r))
			{
				if (W[i].smallflag)
				{
					if (W[i].smallflag==1)
					{
						if (W[i].icon&FLAGS15)
							tree=__rsc.head.trindex[W[i].icon&~FLAGS15];
						else
							tree=glb.rsc.head.trindex[W[i].icon];
					}
					else
					{
						if (glb.icon&FLAGS15)
							tree=__rsc.head.trindex[glb.icon&~FLAGS15];
						else
							tree=glb.rsc.head.trindex[glb.icon];
					}
					objc_draw(tree,0,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
				}
				else
				{
					objc_draw(mytree,FWINAME,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINCLS,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINPOP,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINCYC,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINICO,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINFUL,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINVSF,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINUAR,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINDAR,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINHSF,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINLAR,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINRAR,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);
					objc_draw(mytree,FWINSIZ,MAX_DEPTH,__r.g_x,__r.g_y,__r.g_w,__r.g_h);

					_setClip(TRUE,&__r);
					vql_attributes(glb.hvdi,lattr);
					vsl_color(glb.hvdi,1);
					vsl_type(glb.hvdi,SOLID);
					vsl_width(glb.hvdi,1);

					pxy[0]=__W[i].mxwork+__W[i].params.x;
					pxy[1]=__W[i].mywork+__W[i].params.y;
					pxy[2]=__W[i].mxwork+__W[i].mwwork;
					pxy[3]=pxy[1];
					v_pline(glb.hvdi,2,pxy);
					if (__W[i].params.w)
					{
						pxy[0]=__W[i].mxwork+__W[i].mwwork-__W[i].params.w-1;
						pxy[1]=__W[i].mywork+__W[i].params.y;
						pxy[2]=pxy[0];
						pxy[3]=__W[i].mywork+__W[i].mhwork-__W[i].params.h-1;
						v_pline(glb.hvdi,2,pxy);
					}
					if (__W[i].params.h)
					{
						pxy[0]=__W[i].mxwork+__W[i].params.x;
						pxy[1]=__W[i].mywork+__W[i].mhwork-__W[i].params.h-1;
						pxy[2]=__W[i].mxwork+__W[i].mwwork;
						pxy[3]=pxy[1];
						v_pline(glb.hvdi,2,pxy);
					}
					vsl_type(glb.hvdi,lattr[0]);
					vsl_color(glb.hvdi,lattr[1]);
					_setClip(FALSE,&__r);

					my1=__r;
					my2.g_x=W[i].xwork;
					my2.g_y=W[i].ywork;
					my2.g_w=W[i].wwork;
					my2.g_h=W[i].hwork;
					if (_rcIntersect(&my1,&my2))
						if (W[i].redraw!=0)
							(*W[i].redraw)(i,my2.g_x,my2.g_y,my2.g_w,my2.g_h);
				}
			}
			wind_get(ha,WF_NEXTXYWH,&__r.g_x,&__r.g_y,&__r.g_w,&__r.g_h);
		}
		wind_update(END_UPDATE);
		graf_mouse(M_ON,0);
		__r.g_x=0;
		__r.g_y=0;
		__r.g_w=0;
		__r.g_h=0;
	}
}


/******************************************************************************/
/*	Handle clic on window																		*/
/******************************************************************************/
void _clicWin(int i,int x,int y,int k,int nmb)
{
	OBJECT	*tree;
	int		ok=0;
	int		dep,top,t,ha;
	int		n,mx=0,my=0,mk=k,sel,sel1,sel2;
	int		obx,oby,obw,obh,dum;
	int		bx,by,bw,bh;
	int		sx,sy;
	int		fx,fy;
	int		px,py;
	int		pop,rpop;
	int		dec;

	if (i!=-1)
	{
		ha=W[i].handle;
		wind_update(BEG_MCTRL);
		_makeform(i);
		wind_get(0,WF_TOP,&top);
		if (W[i].smallflag)
		{
			if (W[i].smallflag==1)
			{
				if (W[i].icon&FLAGS15)
					tree=__rsc.head.trindex[W[i].icon&~FLAGS15];
				else
					tree=glb.rsc.head.trindex[W[i].icon];
			}
			else
			{
				if (glb.icon&FLAGS15)
					tree=__rsc.head.trindex[glb.icon&~FLAGS15];
				else
					tree=glb.rsc.head.trindex[glb.icon];
			}
			n=objc_find(tree,ROOT,MAX_DEPTH,__mx,__my);
			switch (n)
			{
				case	1:
					graf_mkstate(&dum,&dum,&mk,&dum);
					if (mk)
					{
						bx=__W[i].xsmall;
						by=__W[i].ysmall;
						bw=__W[i].wsmall;
						bh=__W[i].hsmall;
						graf_mouse(FLAT_HAND,0);
						graf_dragbox(bw,bh,bx,by,glb.xdesk+1,glb.ydesk+1,glb.wdesk-2,glb.hdesk-2,&bx,&by);
						graf_mouse(ARROW,0);
						_move(i,bx,by);
					}
					else
					{
						wind_update(BEG_UPDATE);
						wind_get(0,WF_TOP,&top);
						if (top!=ha)
						{
							_top(i);
							_ontop(i);
						}
						wind_update(END_UPDATE);
					}
					ok=1;
					break;
				case	2:
					sel1=tree[n].ob_state;
					tree[n].ob_state^=SELECTED;
					sel2=tree[n].ob_state;
					_winObdraw(i,tree,ROOT,MAX_DEPTH,__W[i].xwsmall,__W[i].ywsmall+tree[1].ob_height,__W[i].wwsmall,__W[i].hwsmall-tree[1].ob_height);
					while (mk>0)
					{
						sel=tree[n].ob_state;
						graf_mkstate(&mx,&my,&mk,&dum);
						if (objc_find(tree,ROOT,MAX_DEPTH,mx,my)==n) sel=sel2; else sel=sel1;
						if (tree[n].ob_state!=sel)
						{
							tree[n].ob_state=sel;
							graf_mouse(M_OFF,0);
							_winObdraw(i,tree,0,MAX_DEPTH,__W[i].xwsmall,__W[i].ywsmall+tree[1].ob_height,__W[i].wwsmall,__W[i].hwsmall-tree[1].ob_height);
							graf_mouse(M_ON,0);
						}
					}
					__W[i].params._smstate=tree[n].ob_state;
					if (nmb==2)
					{
						if (W[i].smallflag==1)
							_unsmall(i);
						else
							_allunsmall(i);
					}
					ok=1;
					break;
			}
		}
		else
		{
			n=objc_find(mytree,ROOT,MAX_DEPTH,x,y);
			switch (n)
			{
				case FWINCLS:
					sel1=mytree[n].ob_state;
					mytree[n].ob_state^=SELECTED;
					sel2=mytree[n].ob_state;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					graf_mouse(M_OFF,0);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					graf_mouse(M_ON,0);
					while (mk>0)
					{
						sel=mytree[n].ob_state;
						graf_mkstate(&mx,&my,&mk,&dum);
						if (objc_find(mytree,ROOT,MAX_DEPTH,mx,my)==n)
							sel=sel2;
						else
							sel=sel1;
						if (mytree[n].ob_state!=sel)
						{
							mytree[n].ob_state=sel;
							graf_mouse(M_OFF,0);
							_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
							if (top!=ha)
								_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
							else
								objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
							graf_mouse(M_ON,0);
						}
					}
					if (mytree[n].ob_state&SELECTED)
					{
						mytree[n].ob_state^=SELECTED;
						_closed(i);
					}
					ok=1;
					break;
				case FWINFUL:
					sel1=mytree[n].ob_state;
					mytree[n].ob_state^=SELECTED;
					sel2=mytree[n].ob_state;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					while (mk>0)
					{
						sel=mytree[n].ob_state;
						graf_mkstate(&mx,&my,&mk,&dum);
						if (objc_find(mytree,ROOT,MAX_DEPTH,mx,my)==n)
							sel=sel2;
						else
							sel=sel1;
						if (mytree[n].ob_state!=sel)
						{
							mytree[n].ob_state=sel;
							graf_mouse(M_OFF,0);
							if (top!=ha)
								_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
							else
								objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
							graf_mouse(M_ON,0);
						}
					}
					if (mytree[n].ob_state&SELECTED)
					{
						mytree[n].ob_state^=SELECTED;
						if (top!=ha)
							_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						else
							objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						_full(i);
					}
					ok=1;
					break;
				case FWINAME:
					graf_mkstate(&dum,&dum,&mk,&dum);
					if (mk)
					{
						wind_get(ha,WF_CURRXYWH,&bx,&by,&bw,&bh);
						graf_mouse(FLAT_HAND,0);
						graf_dragbox(bw,bh,bx,by,glb.xdesk,glb.ydesk,glb.wdesk+bw,glb.hdesk+bh,&bx,&by);
						graf_mouse(ARROW,0);
						_move(i,bx,by);
					}
					else
					{
						wind_update(BEG_UPDATE);
						wind_get(0,WF_TOP,&top);
						if (top!=ha)
						{
							_top(i);
							_ontop(i);
						}
						wind_update(END_UPDATE);
					}
					ok=1;
					break;
				case FWINSIZ:
					if (W[i].gadget&wSIZE)
					{
						mytree[n].ob_state|=SELECTED;
						_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
						if (top!=ha)
							_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						else
							objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						wind_get(ha,WF_CURRXYWH,&bx,&by,&bw,&bh);
						graf_mouse(USER_DEF,&__s[FSOUSIZ]);
						graf_rubberbox(bx,by,__W[i].wmini,__W[i].hmini,&bw,&bh);
						graf_mouse(ARROW,0);
						bw=min(bw,W[i].wfull);
						bh=min(bh,W[i].hfull);
						mytree[n].ob_state&=~SELECTED;
						_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
						if (top!=ha)
							_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						else
							objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						if ( (W[i].wwind!=bw) || (W[i].hwind!=bh) ) _size(i,bw,bh);
						ok=1;
					}
					break;
				case	FWINUAR:
					mytree[n].ob_state|=SELECTED;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					do
					{
						graf_mkstate(&dum,&dum,&mk,&dum);
						if (W[i].yslidlen!=1000 && W[i].yslidpos>0 && W[i].arrow!=0)
						{
							(*W[i].arrow)(i,WA_UPLINE);
							_clearAesBuffer();
						}
					}	while (mk);
					mytree[n].ob_state&=~SELECTED;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					ok=1;
					break;
				case	FWINDAR:
					mytree[n].ob_state|=SELECTED;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					do
					{
						graf_mkstate(&dum,&dum,&mk,&dum);
						if (W[i].yslidlen!=1000 && W[i].yslidpos<1000 && W[i].arrow!=0)
						{
							(*W[i].arrow)(i,WA_DNLINE);
							_clearAesBuffer();
						}
					}	while (mk);
					mytree[n].ob_state&=~SELECTED;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					ok=1;
					break;
				case	FWINVSF:
					_coord(mytree,FWINVSP,FALSE,&obx,&oby,&obw,&obh);
					objc_offset(mytree,FWINVSP,&sx,&sy);
					graf_mouse(M_OFF,0);
					if (W[i].arrow!=0)
					{
						if (y<sy)
							(*W[i].arrow)(i,WA_UPPAGE);
						else
							(*W[i].arrow)(i,WA_DNPAGE);
					}
					graf_mouse(M_ON,0);
					ok=1;
					break;
				case	FWINVSP:
				case	FWINVSI:
					objc_offset(mytree,FWINVSP,&px,&py);
					objc_offset(mytree,FWINVSF,&fx,&fy);
					graf_mkstate(&mx,&my,&mk,&dum);
					dec=py-my;
					graf_mouse(M_OFF,0);
					do
					{
						graf_mkstate(&mx,&my,&mk,&dum);
						dum=my-fy+dec;
						dum=max(0,dum);
						dum=min(mytree[FWINVSF].ob_height-mytree[FWINVSP].ob_height,dum);
						if (dum!=mytree[FWINVSP].ob_y)
						{
							mytree[FWINVSP].ob_y=dum;
							_coord(mytree,FWINVSF,FALSE,&obx,&oby,&obw,&obh);
							obx+=1; obw-=2;
							if (top!=ha)
								_winObdraw(i,mytree,FWINVSF,MAX_DEPTH,obx,oby,obw,obh);
							else
								objc_draw(mytree,FWINVSF,MAX_DEPTH,obx,oby,obw,obh);
							W[i].yslidpos=(double)mytree[FWINVSP].ob_y*1000.0/(double)(mytree[FWINVSF].ob_height-mytree[FWINVSP].ob_height);
							if ( (k!=2) && (W[i].vslid!=0) )
								(*W[i].vslid)(i,W[i].yslidpos);
							_clearAesBuffer();
						}
					}	while (mk);
					if (k==2)
						(*W[i].vslid)(i,W[i].yslidpos);
					graf_mouse(M_ON,0);
					ok=1;
					break;
				case	FWINLAR:
					mytree[n].ob_state|=SELECTED;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					do
					{
						graf_mkstate(&dum,&dum,&mk,&dum);
						if (W[i].xslidlen!=1000 && W[i].xslidpos>0 && W[i].arrow!=0)
						{
							(*W[i].arrow)(i,WA_LFLINE);
							_clearAesBuffer();
						}
					}	while (mk);
					mytree[n].ob_state&=~SELECTED;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					ok=1;
					break;
				case	FWINRAR:
					mytree[n].ob_state|=SELECTED;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					do
					{
						graf_mkstate(&dum,&dum,&mk,&dum);
						if (W[i].xslidlen!=1000 && W[i].xslidpos<1000 && W[i].arrow!=0)
						{
							(*W[i].arrow)(i,WA_RTLINE);
							_clearAesBuffer();
						}
					}	while (mk);
					mytree[n].ob_state&=~SELECTED;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					ok=1;
					break;
				case	FWINHSF:
					objc_offset(mytree,FWINHSP,&sx,&sy);
					graf_mouse(M_OFF,0);
					if (W[i].arrow!=0)
					{
						if (x<sx)
							(*W[i].arrow)(i,WA_LFPAGE);
						else
							(*W[i].arrow)(i,WA_RTPAGE);
					}
					graf_mouse(M_ON,0);
					ok=1;
					break;
				case	FWINHSP:
				case	FWINHSI:
					objc_offset(mytree,FWINHSP,&px,&py);
					objc_offset(mytree,FWINHSF,&fx,&fy);
					graf_mkstate(&mx,&my,&mk,&dum);
					dec=px-mx;
					graf_mouse(M_OFF,0);
					do
					{
						graf_mkstate(&mx,&my,&mk,&dum);
						dum=mx-fx+dec;
						dum=max(0,dum);
						dum=min(mytree[FWINHSF].ob_width-mytree[FWINHSP].ob_width,dum);
						if (dum!=mytree[FWINHSP].ob_x)
						{
							mytree[FWINHSP].ob_x=dum;
							_coord(mytree,FWINHSF,FALSE,&obx,&oby,&obw,&obh);
							obx+=1; obw-=2;
							if (top!=ha)
								_winObdraw(i,mytree,FWINHSF,MAX_DEPTH,obx,oby,obw,obh);
							else
								objc_draw(mytree,FWINHSF,MAX_DEPTH,obx,oby,obw,obh);
							W[i].xslidpos=(double)mytree[FWINHSP].ob_x*1000.0/(double)(mytree[FWINHSF].ob_width-mytree[FWINHSP].ob_width);
							if ( (k!=2) && (W[i].hslid!=0) )
								(*W[i].hslid)(i,W[i].xslidpos);
							_clearAesBuffer();
						}
					}	while (mk);
					if (k==2)
						(*W[i].hslid)(i,W[i].xslidpos);
					graf_mouse(M_ON,0);
					ok=1;
					break;
				case	FWINCYC:
					sel1=mytree[n].ob_state;
					mytree[n].ob_state^=SELECTED;
					sel2=mytree[n].ob_state;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					while (mk>0)
					{
						sel=mytree[n].ob_state;
						graf_mkstate(&mx,&my,&mk,&dum);
						if (objc_find(mytree,ROOT,MAX_DEPTH,mx,my)==n) sel=sel2; else sel=sel1;
						if (mytree[n].ob_state!=sel)
						{
							mytree[n].ob_state=sel;
							graf_mouse(M_OFF,0);
							if (top!=ha)
								_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
							else
								objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
							graf_mouse(M_ON,0);
						}
					}
					if (mytree[n].ob_state&SELECTED)
					{
						mytree[n].ob_state^=SELECTED;
						if (top!=ha)
							_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						else
							objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						if (_winFindWin(top)!=-1) dep=_winFindWin(top); else dep=i;
						t=dep;
						do
						{
							t+=1;
							if (t>=glb.NMB_WDW) t=0;
							if (W[t].handle>0)
							{
								if (W[t].handle!=top)
								{
									_top(t);
									_ontop(t);
								}
								t=dep;
							}
						}	while (t!=dep);
					}
					ok=1;
					break;
				case	FWINICO:
					sel1=mytree[n].ob_state;
					mytree[n].ob_state^=SELECTED;
					sel2=mytree[n].ob_state;
					_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
					if (top!=ha)
						_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					else
						objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
					while (mk>0)
					{
						sel=mytree[n].ob_state;
						graf_mkstate(&mx,&my,&mk,&dum);
						if (objc_find(mytree,ROOT,MAX_DEPTH,mx,my)==n) sel=sel2; else sel=sel1;
						if (mytree[n].ob_state!=sel)
						{
							mytree[n].ob_state=sel;
							graf_mouse(M_OFF,0);
							if (top!=ha)
								_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
							else
								objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
							graf_mouse(M_ON,0);
						}
					}
					if (mytree[n].ob_state&SELECTED)
					{
						mytree[n].ob_state^=SELECTED;
						if (top!=ha)
							_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						else
							objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						if (__kst&0x04)
							_allsmall(i);
						else
							_small(i);
					}
					ok=1;
					break;
				case FWINPOP:
					pop=W[i].popup;
					if (pop!=-1)
					{
						mytree[n].ob_state|=SELECTED;
						_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
						if (top!=ha)
							_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						else
							objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						if (pop&FLAGS15)	rpop=_formMenu(mytree,n,__rsc.head.trindex[pop-FLAGS15],-1,1,0)-1;
						else					rpop=_formMenu(mytree,n,glb.rsc.head.trindex[pop],-1,1,0)-1;
						mytree[n].ob_state&=~SELECTED;
						_coord(mytree,n,FALSE,&obx,&oby,&obw,&obh);
						if (top!=ha)
							_winObdraw(i,mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						else
							objc_draw(mytree,n,MAX_DEPTH,obx,oby,obw,obh);
						if (rpop!=-2)
							if (W[i].pop!=0) (*W[i].pop)(i,rpop);
					}
					ok=1;
					break;
			}
		}
		wind_update(END_MCTRL);
		if (ok==0)
		{
			if (k==2)
			{
				do
				{
					graf_mkstate(&dum,&dum,&mk,&dum);
				}	while (mk);
				_top(i);
				_ontop(i);
			}
			else if ( (W[i].smallflag==0) && (W[i].clic!=0) && (glb.flag&MU_BUTTON) )
				(*W[i].clic)(i,x,y,k,nmb);
		}
	}
}


/******************************************************************************/
/*	Draw the 'top' bar of the windows														*/
/******************************************************************************/
void _maketop()
{
	OBJECT	*tree;
	int		i;
	int		top;
	int		obx,oby,obw,obh;

	wind_get(0,WF_TOP,&top);
	if (top!=__TOP) for (i=0;i<glb.NMB_WDW;i++)
	{
		if ( (W[i].handle>0) && ((W[i].handle==__TOP)||(W[i].handle==top)) )
		{
			if (W[i].smallflag==0)
			{
				mytree->ob_x=__W[i].mxwork;
				mytree->ob_y=__W[i].mywork;
				if ( (W[i].gadget & wNAME) )
					_obPutStr(mytree,FWINAME,W[i].name);
				else
					_obPutStr(mytree,FWINAME,"");
				if (top==W[i].handle)
					mytree[FWINAME].ob_state|=SELECTED;
				else
					mytree[FWINAME].ob_state&=~SELECTED;
				mytree->ob_width				=	__W[i].params._box.w;
				mytree->ob_height				=	__W[i].params._box.h;
				mytree[FWINAME].ob_x			=	__W[i].params._name.x;
				mytree[FWINAME].ob_y			=	__W[i].params._name.y;
				mytree[FWINAME].ob_width	=	__W[i].params._name.w;
				mytree[FWINAME].ob_height	=	__W[i].params._name.h;
				_coord(mytree,FWINAME,FALSE,&obx,&oby,&obw,&obh);
				_winRedraw(i,obx,oby,obw,obh);
			}
			else
			{
				if (W[i].smallflag==1)
				{
					if (W[i].icon&FLAGS15)
						tree=__rsc.head.trindex[W[i].icon&~FLAGS15];
					else
						tree=glb.rsc.head.trindex[W[i].icon];
					if ( (W[i].gadget & wNAME) )
						_obPutStr(tree,1,W[i].sname);
					else
						_obPutStr(tree,1,"");
				}
				else
				{
					if (glb.icon&FLAGS15)
						tree=__rsc.head.trindex[glb.icon&~FLAGS15];
					else
						tree=glb.rsc.head.trindex[glb.icon];
					if ( (W[i].gadget & wNAME) )
						_obPutStr(tree,1,glb.name);
					else
						_obPutStr(tree,1,"");
				}
				tree->ob_x=__W[i].xwsmall;
				tree->ob_y=__W[i].ywsmall;
				if (top==W[i].handle)
					tree[1].ob_state|=SELECTED;
				else
					tree[1].ob_state&=~SELECTED;
				_coord(tree,1,FALSE,&obx,&oby,&obw,&obh);
				_winRedraw(i,obx,oby,obw,obh);
			}
		}
	}
	__TOP=top;
}


/******************************************************************************/
/*	Adapts the RSC tree to the window parameters											*/
/******************************************************************************/
void _makeform(int i)
{
	int		ha;
	OBJECT	*tree;

	if (i!=-1)
	{
		ha=W[i].handle;
		_maketop();
		if (W[i].smallflag==0)
		{
			mytree->ob_x=__W[i].mxwork;
			mytree->ob_y=__W[i].mywork;
			if ( (W[i].gadget & wNAME) )
				_obPutStr(mytree,FWINAME,W[i].name);
			else
				_obPutStr(mytree,FWINAME,"");
			mytree->ob_width				=	__W[i].params._box.w;
			mytree->ob_height				=	__W[i].params._box.h;
			mytree->ob_flags				=	__W[i].params._box.flags;
			mytree[FWINAME].ob_x			=	__W[i].params._name.x;
			mytree[FWINAME].ob_y			=	__W[i].params._name.y;
			mytree[FWINAME].ob_width	=	__W[i].params._name.w;
			mytree[FWINAME].ob_height	=	__W[i].params._name.h;
			mytree[FWINAME].ob_flags	=	__W[i].params._name.flags;
			mytree[FWINCLS].ob_x			=	__W[i].params._close.x;
			mytree[FWINCLS].ob_y			=	__W[i].params._close.y;
			mytree[FWINCLS].ob_flags	=	__W[i].params._close.flags;
			mytree[FWINPOP].ob_x			=	__W[i].params._menu.x;
			mytree[FWINPOP].ob_y			=	__W[i].params._menu.y;
			mytree[FWINPOP].ob_flags	=	__W[i].params._menu.flags;
			mytree[FWINCYC].ob_x			=	__W[i].params._cycle.x;
			mytree[FWINCYC].ob_y			=	__W[i].params._cycle.y;
			mytree[FWINCYC].ob_flags	=	__W[i].params._cycle.flags;
			mytree[FWINICO].ob_x			=	__W[i].params._icon.x;
			mytree[FWINICO].ob_y			=	__W[i].params._icon.y;
			mytree[FWINICO].ob_flags	=	__W[i].params._icon.flags;
			mytree[FWINFUL].ob_x			=	__W[i].params._full.x;
			mytree[FWINFUL].ob_y			=	__W[i].params._full.y;
			mytree[FWINFUL].ob_flags	=	__W[i].params._full.flags;
			mytree[FWINVSF].ob_x			=	__W[i].params._vslf.x;
			mytree[FWINVSF].ob_y			=	__W[i].params._vslf.y;
			mytree[FWINVSF].ob_width	=	__W[i].params._vslf.w;
			mytree[FWINVSF].ob_height	=	__W[i].params._vslf.h;
			mytree[FWINVSF].ob_flags	=	__W[i].params._vslf.flags;
			mytree[FWINVSP].ob_x			=	__W[i].params._vslp.x;
			mytree[FWINVSP].ob_y			=	__W[i].params._vslp.y;
			mytree[FWINVSP].ob_width	=	__W[i].params._vslp.w;
			mytree[FWINVSP].ob_height	=	__W[i].params._vslp.h;
			mytree[FWINVSP].ob_flags	=	__W[i].params._vslp.flags;
			mytree[FWINVSI].ob_x			=	__W[i].params._vsli.x;
			mytree[FWINVSI].ob_y			=	__W[i].params._vsli.y;
			mytree[FWINVSI].ob_width	=	__W[i].params._vsli.w;
			mytree[FWINVSI].ob_height	=	__W[i].params._vsli.h;
			mytree[FWINVSI].ob_flags	=	__W[i].params._vsli.flags;
			mytree[FWINUAR].ob_x			=	__W[i].params._uarr.x;
			mytree[FWINUAR].ob_y			=	__W[i].params._uarr.y;
			mytree[FWINUAR].ob_flags	=	__W[i].params._uarr.flags;
			mytree[FWINDAR].ob_x			=	__W[i].params._darr.x;
			mytree[FWINDAR].ob_y			=	__W[i].params._darr.y;
			mytree[FWINDAR].ob_flags	=	__W[i].params._darr.flags;
			mytree[FWINSIZ].ob_x			=	__W[i].params._size.x;
			mytree[FWINSIZ].ob_y			=	__W[i].params._size.y;
			mytree[FWINSIZ].ob_flags	=	__W[i].params._size.flags;
			mytree[FWINRAR].ob_x			=	__W[i].params._rarr.x;
			mytree[FWINRAR].ob_y			=	__W[i].params._rarr.y;
			mytree[FWINRAR].ob_flags	=	__W[i].params._rarr.flags;
			mytree[FWINLAR].ob_x			=	__W[i].params._larr.x;
			mytree[FWINLAR].ob_y			=	__W[i].params._larr.y;
			mytree[FWINLAR].ob_flags	=	__W[i].params._larr.flags;
			mytree[FWINHSF].ob_x			=	__W[i].params._hslf.x;
			mytree[FWINHSF].ob_y			=	__W[i].params._hslf.y;
			mytree[FWINHSF].ob_width	=	__W[i].params._hslf.w;
			mytree[FWINHSF].ob_height	=	__W[i].params._hslf.h;
			mytree[FWINHSF].ob_flags	=	__W[i].params._hslf.flags;
			mytree[FWINHSP].ob_x			=	__W[i].params._hslp.x;
			mytree[FWINHSP].ob_y			=	__W[i].params._hslp.y;
			mytree[FWINHSP].ob_width	=	__W[i].params._hslp.w;
			mytree[FWINHSP].ob_height	=	__W[i].params._hslp.h;
			mytree[FWINHSP].ob_flags	=	__W[i].params._hslp.flags;
			mytree[FWINHSI].ob_x			=	__W[i].params._hsli.x;
			mytree[FWINHSI].ob_y			=	__W[i].params._hsli.y;
			mytree[FWINHSI].ob_width	=	__W[i].params._hsli.w;
			mytree[FWINHSI].ob_height	=	__W[i].params._hsli.h;
			mytree[FWINHSI].ob_flags	=	__W[i].params._hsli.flags;
			if (__TOP==ha)
				mytree[FWINAME].ob_state|=SELECTED;
			else
				mytree[FWINAME].ob_state&=~SELECTED;
		}
		else
		{
			if (W[i].smallflag==1)
			{
				if (W[i].icon&FLAGS15)
					tree=__rsc.head.trindex[W[i].icon&~FLAGS15];
				else
					tree=glb.rsc.head.trindex[W[i].icon];
			}
			else
			{
				if (glb.icon&FLAGS15)
					tree=__rsc.head.trindex[glb.icon&~FLAGS15];
				else
					tree=glb.rsc.head.trindex[glb.icon];
			}
			tree->ob_x=__W[i].xwsmall;
			tree->ob_y=__W[i].ywsmall;
			tree[2].ob_state=__W[i].params._smstate;
			if (W[i].smallflag==1)
			{
				if (W[i].gadget & wNAME)
					_obPutStr(tree,1,W[i].sname);
				else
					_obPutStr(tree,1,"");
			}
			else
			{
				if (W[i].gadget & wNAME)
					_obPutStr(tree,1,glb.name);
				else
					_obPutStr(tree,1,"");
			}
			if (__TOP==W[i].handle)
				tree[1].ob_state|=SELECTED;
			else
				tree[1].ob_state&=~SELECTED;
		}
	}
}


/******************************************************************************/
/*	Change window title																			*/
/******************************************************************************/
void _winName(int i,char *name,char *sname)
{
	if (i!=-1)
	{
		strncpy(W[i].name,name,wNAMEMAX);
		strncpy(W[i].sname,sname,wSNAMEMAX);
		_redrawWindow(i);
	}
}


/******************************************************************************/
/*	Change window *WORK* size																	*/
/******************************************************************************/
void _winWsize(int i,int w,int h)
{
	int		nH=0,nD=0,nB=0,isD=0,isB=0;
	int		WW,HH,dum;
	int		wwork,hwork;

	if (i!=-1)
	{
		_makeform(i);
		W[i].wwork=w;
		W[i].hwork=h;
		WW=mytree[wCLOSE].ob_width;
		HH=mytree[wCLOSE].ob_height;
		if (W[i].gadget & wCLOSE)	{	nH++;		}
		if (W[i].gadget & wMENU)	{	nH++;		}
		if (W[i].gadget & wCYCLE)	{	nH++;		}
		if (W[i].gadget & wICON)	{	nH++;		}
		if (W[i].gadget & wFULL)	{	nH++;		}
		if (W[i].gadget & wVSLIDE)	{	isD=1;	}
		if (W[i].gadget & wUARROW)	{	nD++;	isD=1;	}
		if (W[i].gadget & wDARROW)	{	nD++;	isD=1;	}
		if (W[i].gadget & wRARROW)	{	nB++;	isB=1;	}
		if (W[i].gadget & wLARROW)	{	nB++;	isB=1;	}
		if (W[i].gadget & wHSLIDE)	{	isB=1;	}
		if (W[i].gadget & wSIZE)	{	isD=1; isB=1; nD++; nB++;	}
		wwork=w+isD*(1+WW);
		hwork=h+(1+isB)*(1+HH);
		wind_calc(WC_BORDER,0,__W[i].mxwork,__W[i].mywork,wwork,hwork,&dum,&dum,&W[i].wwind,&W[i].hwind);
		wind_set(W[i].handle,WF_CURRXYWH,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
		wind_get(W[i].handle,WF_WORKXYWH,&__W[i].mxwork,&__W[i].mywork,&__W[i].mwwork,&__W[i].mhwork);
		_setWindow(i);
	}
}


/******************************************************************************/
/*	Change window size																			*/
/******************************************************************************/
void _winSize(int i,int w,int h)
{
	wind_update(BEG_MCTRL);
	_makeform(i);
	_size(i,w,h);
	wind_update(END_MCTRL);
}


/******************************************************************************/
/*	Change window position																		*/
/******************************************************************************/
void _winMove(int i,int x,int y)
{
	wind_update(BEG_MCTRL);
	_makeform(i);
	_move(i,x,y);
	wind_update(END_MCTRL);
}


/******************************************************************************/
/*	redraw the window gadgets																	*/
/******************************************************************************/
void _redrawWindow(int i)
{
	GRECT		rd,r;
	int		ha,lattr[6],pxy[4];

	if (i!=-1)
		if (!W[i].smallflag)
		{
			ha=W[i].handle;
			rd.g_x=W[i].xwind;
			rd.g_y=W[i].ywind;
			rd.g_w=W[i].wwind;
			rd.g_h=W[i].hwind;

			_makeform(i);
			wind_get(ha,WF_FIRSTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
			while (r.g_w && r.g_h)
			{
				if (_rcIntersect(&rd,&r))
				{
					objc_draw(mytree,FWINAME,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINCLS,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINPOP,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINCYC,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINICO,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINFUL,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINVSF,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINUAR,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINDAR,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINHSF,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINLAR,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINRAR,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					objc_draw(mytree,FWINSIZ,MAX_DEPTH,r.g_x,r.g_y,r.g_w,r.g_h);
					_setClip(TRUE,&r);
					vql_attributes(glb.hvdi,lattr);
					vsl_color(glb.hvdi,1);
					vsl_type(glb.hvdi,SOLID);
					vsl_width(glb.hvdi,1);
					pxy[0]=__W[i].mxwork+__W[i].params.x;
					pxy[1]=__W[i].mywork+__W[i].params.y;
					pxy[2]=__W[i].mxwork+__W[i].mwwork;
					pxy[3]=pxy[1];
					v_pline(glb.hvdi,2,pxy);
					if (__W[i].params.w)
					{
						pxy[0]=__W[i].mxwork+__W[i].mwwork-__W[i].params.w-1;
						pxy[1]=__W[i].mywork+__W[i].params.y;
						pxy[2]=pxy[0];
						pxy[3]=__W[i].mywork+__W[i].mhwork-__W[i].params.h-1;
						v_pline(glb.hvdi,2,pxy);
					}
					if (__W[i].params.h)
					{
						pxy[0]=__W[i].mxwork+__W[i].params.x;
						pxy[1]=__W[i].mywork+__W[i].mhwork-__W[i].params.h-1;
						pxy[2]=__W[i].mxwork+__W[i].mwwork;
						pxy[3]=pxy[1];
						v_pline(glb.hvdi,2,pxy);
					}
					vsl_type(glb.hvdi,lattr[0]);
					vsl_color(glb.hvdi,lattr[1]);
					_setClip(FALSE,&r);
				}
				wind_get(ha,WF_NEXTXYWH,&r.g_x,&r.g_y,&r.g_w,&r.g_h);
			}
		}
}
