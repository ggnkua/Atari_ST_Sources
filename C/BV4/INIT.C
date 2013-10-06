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

void _exitMem(void);


/*******************************************************************************
	INITIALISATION DES PARAMETRES PAR DEFAUT
*******************************************************************************/
int initAll()
{
	long		Cook;
	int		i,ok;
	char		*p;
	VEIL		*tv;
	LEDP		*led;

	_cls((long)&glb,sizeof(GLB));

	if (Kbshift(-1)&0x4L)
	{
		glb.opt.log					=	LOG_FORCE;
		glb.opt.logmask			=	LOG_INI|LOG_MEM|LOG_TRM|LOG_RIM|LOG_WIM|LOG_IFX;
	}

	glb.opt.useExt=FALSE;
	glb.opt.usePat=FALSE;
	glb.opt.gfx=FALSE;
	glb.opt.zap=FALSE;
	glb.opt.pal=FALSE;
	glb.opt.deskfull=FALSE;
	glb.opt.win=2;
	glb.opt.trm=0;

	Dgetpath(glb.div.pfname,0);
	if (glb.div.pfname[1]!=':')
	{
		glb.opt.sl_path[0]=65+Dgetdrv();
		glb.opt.sl_path[1]=':';
		glb.opt.sl_path[2]='\0';
	}
	else
		glb.opt.sl_path[0]='\0';
	strcat(glb.opt.sl_path,glb.div.pfname);
	if (glb.opt.sl_path[strlen(glb.opt.sl_path)-1L]!='\\')
		strcat(glb.opt.sl_path,"\\");

	strcpy(glb.div.path,glb.opt.sl_path);
	strcpy(glb.div.pname,glb.opt.sl_path);

	strcpy(glb.opt.sl_name,"*.*");

	strcpy(glb.opt.sl_pfname,glb.opt.sl_path);
	strcat(glb.opt.sl_pfname,"\\");
	strcat(glb.opt.sl_pfname,glb.opt.sl_name);

	strcpy(glb.opt.cnv_path,glb.opt.sl_path);
	strcpy(glb.opt.cnv_name,glb.opt.sl_name);
	strcpy(glb.opt.cnv_pfname,glb.opt.sl_pfname);
	strcpy(glb.opt.cnv_dst,glb.opt.sl_path);

	glb.opt.sl_pause=TRUE;	
	glb.opt.sl_ptime=5;	
	glb.opt.sl_tv=FALSE;
	glb.opt.sl_led=FALSE;
	glb.opt.sl_info=FALSE;
	glb.opt.sl_loop=FALSE;
	glb.opt.sl_rec=FALSE;
	glb.opt.sl_zdec=0;
	glb.opt.sl_zinc=0;
	glb.opt.cnv_del=0;
	glb.opt.cnv_col=0;

	glb.opt.is_tv=FALSE;
	glb.opt.is_led=FALSE;

	tv=(VEIL *)_cookie('VeiL');
	if (tv)
		if (tv->ver>=0x115)
			glb.opt.is_tv=TRUE;

	led=(LEDP *)_cookie('LEDP');
	if (led)
		glb.opt.is_led=TRUE;

	strcpy(glb.opt.ext[0],"*.*");
	strcpy(glb.opt.ext[1],"*.GIF");
	strcpy(glb.opt.ext[2],"*.TG?");
	strcpy(glb.opt.ext[3],"*.JPG");
	strcpy(glb.opt.ext[4],"*.PI?");
	strcpy(glb.opt.ext[5],"*.PC?");
	strcpy(glb.opt.ext[6],"*.IMG");
	strcpy(glb.opt.ext[7],"*.*");
	strcpy(glb.opt.ext[8],"*.*");
	strcpy(glb.opt.ext[9],"*.*");
	strcpy(glb.opt.ext[10],"*.*");
	strcpy(glb.opt.pat[0],glb.div.path);
	strcpy(glb.opt.pat[1],"");
	strcpy(glb.opt.pat[2],"");
	strcpy(glb.opt.pat[3],"");
	strcpy(glb.opt.pat[4],"");
	strcpy(glb.opt.pat[5],"");
	strcpy(glb.opt.pat[6],"");
	strcpy(glb.opt.pat[7],"");
	strcpy(glb.opt.pat[8],"");
	strcpy(glb.opt.pat[9],"");
	strcpy(glb.opt.pat[10],"");

	glb.aes.tree.menu	=	-1;
	glb.aes.tree.desk	=	-1;

	glb.aes.desk.first_icon=-1;
	glb.aes.desk.trash_icon=-1;
	glb.aes.desk.scrap_icon1=-1;
	glb.aes.desk.scrap_icon2=-1;
	glb.aes.desk.color2=3;
	glb.aes.desk.color4=13;
	glb.aes.desk.trame1=4;
	glb.aes.desk.trame2=4;
	glb.aes.desk.trame4=7;

	glb.opt.Win_Num			=	50;
	glb.opt.Mem_Num			=	0;
	glb.opt.Mem_Len			=	0;
	glb.opt.Mem_Boot			=	95;
	glb.opt.Flash_PopUp		=	1;
	glb.opt.Save_Config		=	1;
	glb.opt.Mouse_Form		=	2;
	glb.opt.Auto_Icon			=	1;
	glb.opt.Rev_Horiz			=	0;
	glb.opt.Rev_Verti			=	0;

	glb.print.dev				=	21;
	glb.print.max				=	1;
	glb.print.out				=	1;
	glb.print.xcenter			=	1;
	glb.print.ycenter			=	1;

	glb.aes.tree.icon			=	-1;
	glb.aes.icon				=	WIC_DEF;
	glb.parx.i_rim				=	NO_MEMORY;
	glb.parx.p_rim				=	NO_MEMORY;
	glb.parx.i_wim				=	NO_MEMORY;
	glb.parx.p_wim				=	NO_MEMORY;
	glb.parx.i_ifx				=	NO_MEMORY;
	glb.parx.p_ifx				=	NO_MEMORY;
	glb.parx.i_trm				=	NO_MEMORY;
	glb.parx.p_trm				=	NO_MEMORY;
	glb.parx.i_bro				=	NO_MEMORY;
	glb.parx.i_mot				=	NO_MEMORY;
	glb.parx.i_pal				=	NO_MEMORY;

	glb.parx.setmod=-1;
	glb.parx.setdef=-1;
	glb.parx.strin=NO_MEMORY;
	glb.parx.strnmb=0;

	strcpy(glb.div.SWP_Path,glb.div.path);

	strcpy(glb.opt.APP_Path,glb.div.path);

	strcpy(glb.opt.LOG_File,glb.div.path);
	strcat(glb.opt.LOG_File,"BV4.LOG");

	strcpy(glb.opt.INI_File,glb.div.path);
	strcat(glb.opt.INI_File,"BV4.INI");

	glb.opt.Language	=	-1;
	glb.div.avail_fr	=	0;
	glb.div.avail_uk	=	0;
	glb.div.avail_de	=	0;

	strcpy(glb.rsc.name,glb.div.path);
	strcat(glb.rsc.name,"BV4_FR.RSC");
	if (_fexist(glb.rsc.name,NULL))
		glb.div.avail_fr=1;

	strcpy(glb.rsc.name,glb.div.path);
	strcat(glb.rsc.name,"BV4_UK.RSC");
	if (_fexist(glb.rsc.name,NULL))
		glb.div.avail_uk=1;

	strcpy(glb.rsc.name,glb.div.path);
	strcat(glb.rsc.name,"BV4_DE.RSC");
	if (_fexist(glb.rsc.name,NULL))
		glb.div.avail_de=1;

	sprintf(glb.parx.Path,"%c:\\PARX.SYS\\",65+_getBoot());
	glb.parx.Active=P_MEM;
	glb.parx.Mask=P_RIM|P_WIM|P_IFX|P_TRM|P_MEM|P_BRO|P_MOT|P_PAL;
	glb.div.mouse=FMOUWHEEL;

	Cook=_cookie('_MCH');
	glb.div.MCH	=	(int)(Cook>>16);						/*	machine type		*/
	switch (glb.div.MCH)										/*	0:	STF				*/
	{																/*	1:	STE				*/
		case	2:		glb.div.MCH=3;							/*	2:	MegaSTE			*/
						break;									/*	3:	TT					*/
		case	3:		glb.div.MCH=4;							/*	4:	Falcon030		*/
						break;									/*	5:	???				*/
		case	1:		if ((int)(Cook&0xFF)==16)
						glb.div.MCH=2;
						break;
		default:		glb.div.MCH=5;
						break;
	}

	glb.div.TOS=_vTOS();


	/****************************************************************************
	Init de l'AES
	****************************************************************************/
	_initAes();

	/****************************************************************************
	Init de la barre de progression
	****************************************************************************/
	_progOn();

	_loadINI(0);

_initReport();
sprintf(glb.div.log,"Bv4 %s\n",RELEASE);
_reportLog(LOG_INI);

	if (!_dexist(glb.parx.Path))
	{
		_progOff();
		glb.div.pname[0]=65+Dgetdrv();
		glb.div.pname[1]=':';
		glb.div.pname[2]='\0';
		Dgetpath(glb.div.pfname,1+Dgetdrv());
		strcat(glb.div.pname,glb.div.pfname);
		strcpy(glb.div.fname,"*.*");
		strcpy(glb.div.pfname,"");
		do
		{
			form_alert(1,rs_frstr[NOPARX]);
			i=_fselect(glb.div.pfname,glb.div.pname,glb.div.fname,"*.*",rs_frstr[PARXSYS]);

			if (i)
			{
sprintf(glb.div.log,"PARX.SYS dir: %s\n",glb.div.pname);
_reportLog(LOG_INI);
				ok=FALSE;
				p=strrchr(glb.div.pname,'\\');
				if (p)
				{
					ok=TRUE;
					if (strcmp(p,"\\PARX.SYS"))
						ok=FALSE;
					else
					{
						strcpy(glb.parx.Path,glb.div.pname);
						strcat(glb.parx.Path,"\\");
						strcat(glb.parx.Path,"PARX.MEM");
						if (!_fexist(glb.parx.Path,NULL))
							ok=FALSE;
					}
				}
			}

		}	while (i && !ok);
		if (!i || !ok)
			goto exit;
		strcpy(glb.parx.Path,glb.div.pname);
		strcat(glb.parx.Path,"\\");
sprintf(glb.div.log,"PARX.SYS dir: %s\n",glb.parx.Path);
_reportLog(LOG_INI);
		_progOn();
	}

	return TRUE;

exit:
	/****************************************************************************
	Exit de la barre de progression
	****************************************************************************/
	_progOff();

	/****************************************************************************
	Exit de l'AES
	****************************************************************************/
	graf_mouse(ARROW,0);
	_exitAes();

	return FALSE;

}


/*******************************************************************************
	Init AES
*******************************************************************************/
void _initAes()
{
	int				i,work_in[11];

	glb.aes.top		=	0;
	glb.aes.type	=	_app;
	glb.aes.id		=	appl_init();
	glb.aes.ver		=	Gem_pb.global[0];
	glb.aes.info.sys.multitask	=	(Gem_pb.global[1]==-1) ? TRUE : FALSE;
	glb.div.AccOp	=	glb.aes.type;

	if (!(glb.aes.type==1 && !glb.aes.info.sys.multitask))
		menu_register(glb.aes.id,PRG_SNAME);
	if (glb.aes.ver>=0x400)
		shel_write(9,1,0,0,0);				/*	for AES v4.0	*/

	if (glb.aes.ver>=0x340)
		glb.aes.info.sys.bevent=1;
	else
		glb.aes.info.sys.bevent=0;

	wind_get(0,WF_WORKXYWH,&glb.aes.desk.x,&glb.aes.desk.y,&glb.aes.desk.w,&glb.aes.desk.h);

	glb.vdi.ha=graf_handle(&glb.vdi.wcell,&glb.vdi.hcell,&glb.vdi.wbox,&glb.vdi.hbox);
	for(i=0;i<10;work_in[i++]=1);
	work_in[0]=Getrez()+2;
	work_in[10]=2;
	v_opnvwk(work_in,&glb.vdi.ha,glb.vdi.out);		/*	opens a virtual workstation	*/
	vq_extnd(glb.vdi.ha,1,glb.vdi.extnd);
}


/*******************************************************************************
	Init Memory Manager
*******************************************************************************/
int _initMem()
{
	char		MANAG_NAME[FILENAME_MAX];
	int		ha,i;
	long		flen,Max,sys;
	long		STRam,TTRam;

	_prog(rs_frstr[INIT01],"");

	STRam=_freeRam(ST_ONLY);
	TTRam=_freeRam(TT_ONLY);

	sprintf(glb.div.log,"Free ST-RAM: %8li\n",STRam);
	_reportLog(LOG_INI);
	sprintf(glb.div.log,"Free TT-RAM: %8li\n",TTRam);
	_reportLog(LOG_INI);

	if (TTRam>STRam)
	{
		glb.mem.type=TT_ONLY;
		sprintf(glb.div.log,"Preference:  TTRam\n");
	}
	else
	{
		glb.mem.type=ST_ONLY;
		sprintf(glb.div.log,"Preference:  STRam\n");
	}
	_reportLog(LOG_INI);

	glb.opt.Mem_Num+=100;						/*	for color icon				*/
	glb.opt.Mem_Num+=glb.opt.Win_Num*2;		/*	for windows					*/

	if (glb.parx.Mask&P_MEM)
	{
		strcpy((char *)&MANAG_NAME,glb.parx.Path);
		strcat((char *)&MANAG_NAME,"PARX.MEM");
	}
	else
	{
		strcpy((char *)&MANAG_NAME,glb.opt.APP_Path);
		strcat((char *)&MANAG_NAME,"BV4.MEM");
	}

	sprintf(glb.div.log,"Memory Manager:\n");
	_reportLog(LOG_INI);
	sprintf(glb.div.log,"  %s\n",MANAG_NAME);
	_reportLog(LOG_INI);

	i=0;
	ha=(int)Fopen(MANAG_NAME,0);
	if (ha>=0)
	{
		flen=Fseek(0L,ha,2);
		Fseek(0L,ha,0);
		glb.mem.mem=(long)_Malloc(8L*(long)glb.opt.Mem_Num+flen,glb.mem.type);
		if (glb.mem.mem>0)
		{
			if (Fread(ha,flen,(void *)glb.mem.mem)==flen)
				i=1;
			else
			{
				sprintf(glb.div.log,"  Error while reading file\n");
				_reportLog(LOG_INI);
				Mfree((void *)glb.mem.mem);
			}
		}
		Fclose(ha);
	}

	if (i)
	{
		if (strncmp((char *)glb.mem.mem,"PARX_MEM",8L))
		{
			form_alert(1,rs_frstr[ERR01]);
			Mfree((void *)glb.mem.mem);
			return FALSE;
		}

		manag_malloc	=	(void *)(glb.mem.mem+10L);
		manag_free		=	(void *)(glb.mem.mem+14L);
		manag_shrink	=	(void *)(glb.mem.mem+18L);
		manag_grow		=	(void *)(glb.mem.mem+22L);
		manag_size		=	(void *)(glb.mem.mem+26L);
		manag_version	=	(void *)(glb.mem.mem+30L);
		blk_malloc		=	(void *)(glb.mem.mem+50L);
		blk_free			=	(void *)(glb.mem.mem+54L);
		blk_shrink		=	(void *)(glb.mem.mem+58L);
		blk_grow			=	(void *)(glb.mem.mem+62L);

		i=(*manag_version)();
		if (i<500)
		{
			form_alert(1,rs_frstr[ERR02]);
			Mfree((void *)glb.mem.mem);
			return FALSE;
		}
		else if (i>599)
		{
			form_alert(1,rs_frstr[ERR03]);
			Mfree((void *)glb.mem.mem);
			return FALSE;
		}

		sys=_freeRam(glb.mem.type);
sprintf(glb.div.log,"sys= %li\n",sys);
_reportLog(LOG_INI);
		Max=(long)_Malloc(-1L,glb.mem.type);
sprintf(glb.div.log,"Max= %li\n",Max);
_reportLog(LOG_INI);
		glb.opt.Mem_Len=(long)((double)glb.opt.Mem_Boot*(double)sys/(double)100L);
sprintf(glb.div.log,"Mem_Len= %li\n",glb.opt.Mem_Len);
_reportLog(LOG_INI);

		if (Max>=100L*1024L)				/*	EGlib need at least 100 Kb !	*/
		{
			glb.opt.Mem_Len=min(Max,glb.opt.Mem_Len);
sprintf(glb.div.log,"Mem_Len= %li\n",glb.opt.Mem_Len);
_reportLog(LOG_INI);
			glb.mem.adr=(long *)(glb.mem.mem+flen);
			glb.mem.len=(long *)(glb.mem.mem+flen+4L*(long)glb.opt.Mem_Num);
			for (i=0;i<glb.opt.Mem_Num;i++)
				glb.mem.adr[i]=glb.mem.len[i]=0;
			glb.opt.Mem_Len=(*manag_malloc)(glb.mem.adr,glb.mem.len,MM_NOFILL,glb.opt.Mem_Num,glb.opt.Mem_Len);

sprintf(glb.div.log,"  v%i.%02i - len=%li - nmb=%i\n",(*manag_version)()/100,(*manag_version)()%100,glb.opt.Mem_Len,glb.opt.Mem_Num);
_reportLog(LOG_INI);

			if (glb.opt.Mem_Len)
			{
				glb.mem.tfre=(*manag_size)();
				glb.mem.tlen=glb.opt.Mem_Len;
				return TRUE;
			}
			else
			{
				sprintf(glb.div.log,"  Error with manag_malloc()\n");
				_reportLog(LOG_INI);
				Mfree((void *)glb.mem.mem);
			}
		}
		else
		{
			sprintf(glb.div.log,"  Not enough memory\n");
			_reportLog(LOG_INI);
			Mfree((void *)glb.mem.mem);
		}
	}
	form_alert(1,rs_frstr[ERR04]);
	return FALSE;
}


/*******************************************************************************
	Init windows
*******************************************************************************/
int _initWin()
{
	long		len;
	int		i;

	_prog(rs_frstr[INIT02],"");
	len=(long)glb.opt.Win_Num * (sizeof(window));
#ifdef FORCE_MALLOC
	glb.aes.win=_mAllocForce(MEM_WIN,len,0);
#else
	glb.aes.win=_mAlloc(len,0);
#endif

sprintf(glb.div.log,"Init windows:\n");
_reportLog(LOG_INI);
sprintf(glb.div.log,"  num=%i - in=%i - len=%li\n",glb.opt.Win_Num,glb.aes.win,len);
_reportLog(LOG_INI);

	if (glb.aes.win!=NO_MEMORY)
	{
		W=(window *)glb.mem.adr[glb.aes.win];

		for (i=0;i<glb.opt.Win_Num;i++)
		{
			W[i].id			=	-1;
			W[i].type		=	-1;
			W[i].handle		=	-1;
			W[i].xwind		=	-1;
			W[i].in			=	NO_MEMORY;
		}


		return TRUE;

	}
	form_alert(1,rs_frstr[ERR05]);
	return FALSE;
}


/*******************************************************************************
	Init VDI
*******************************************************************************/
void _initVdi()
{
	typedef int		t_rgb[3];
	t_rgb				*col;
	long				len;
	int				i;

	_prog(rs_frstr[INIT03],"");
	if (glb.vdi.hcell<16)									/*	inits the glb.vdi.low flag !	*/
		glb.vdi.low=1;
	else
		glb.vdi.low=0;
	glb.vdi.xscr=0;
	glb.vdi.yscr=0;
	glb.vdi.wscr=glb.vdi.out[0];
	glb.vdi.hscr=glb.vdi.out[1];

	len=(long)glb.vdi.out[13]*(long)sizeof(t_rgb);
	glb.vdi.pal=_mAlloc(len,0);
	if (glb.vdi.pal!=NO_MEMORY)
	{
		col=(t_rgb *)glb.mem.adr[glb.vdi.pal];
		for (i=0;i<glb.vdi.out[13];i++)
			vq_color(glb.vdi.ha,i,1,(int *)col[i]);
	}
}


/*******************************************************************************
	Init GDOS
*******************************************************************************/
void _initGDOS()
{
	long		gdos,*lp;

	_prog(rs_frstr[INIT04],"");
	_mousework();
	gdos=vq_vgdos();
	glb.vdi.vgdos=0;
	glb.vdi.gdos=0;
	if (gdos==GDOS_NONE)
		glb.vdi.gdos=0;
	else if (gdos==GDOS_FNT)
		glb.vdi.gdos=2;
	else if (gdos==GDOS_FSM)
	{
		lp=(long *)_cookie('FSMC');
		if (lp==0)
			glb.vdi.gdos=0;
		else if (*lp=='_FSM')
		{
			glb.vdi.gdos=3;
			lp++;
			glb.vdi.vgdos=(int)((*lp)>>16);
		}
		else if (*lp=='_SPD')
		{
			glb.vdi.gdos=4;
			lp++;
			glb.vdi.vgdos=(int)((*lp)>>16);
		}
		else
			glb.vdi.gdos=5;
	}
	else
		glb.vdi.gdos=1;

sprintf(glb.div.log,"Init GDOS:\n");
_reportLog(LOG_INI);
sprintf(glb.div.log,"  type=%i v%x.%02x\n",glb.vdi.gdos,glb.vdi.vgdos>>8,glb.vdi.vgdos&0xFF);
_reportLog(LOG_INI);

}


/*******************************************************************************
	Init divers
*******************************************************************************/
void _initDiv()
{
	int	i;
	_prog(rs_frstr[INIT05],"");

	glb.aes.tree.menu		=	MENU;				/*	MENU					*/
	glb.aes.tree.desk		=	BUREAU;			/*	Bureau				*/
	glb.aes.tree.icon		=	ICONE;			/*	Ic“ne application	*/
	glb.aes.icon			=	ICNBV4;			/*	Ic“ne application	*/
	glb.aes.desk.first_icon		=	DSKICN;
	glb.aes.desk.trash_icon		=	DSKBIN;
	glb.aes.desk.print_icon		=	DSKPRT;
	glb.aes.desk.scrap_icon1	=	DSKCLP1;
	glb.aes.desk.scrap_icon2	=	DSKCLP2;
	glb.aes.event.flag	=	MU_BUTTON|MU_TIMER;
	glb.parx.Active|=P_RIM|P_WIM|P_TRM;
#ifdef FORCE_MALLOC
	i=_mAllocForce(MEM_IMG,sizeof(IMG)*(long)glb.opt.Win_Num,1);
#else
	i=_mAlloc(sizeof(IMG)*(long)glb.opt.Win_Num,1);
#endif
	img=(IMG *)glb.mem.adr[i];
	for (i=0;i<glb.opt.Win_Num;i++)
		img[i].flag	=	FALSE;
}


/*******************************************************************************
	Load & init EGlib & program RSC
*******************************************************************************/
int _initRsc()
{
	OBJECT	*tree;
	int		i,j,child;

	_prog(rs_frstr[INIT08],"");

	if (glb.opt.Language==-1)
	{
		i=_AKP();
		if (i>=0x7F)		/*	Soft loaded table: -> _AKP cookie	*/
			i=(int)( ( _cookie('_AKP') & 0xFF00L )>>8 );
		switch (i)
		{
			case	2:
			case	7:
				if (glb.div.avail_fr)
					glb.opt.Language=L_FRENCH;
				break;
			case	1:
			case	8:
				if (glb.div.avail_de)
					glb.opt.Language=L_DEUTSCH;
				break;
			default:
				if (glb.div.avail_uk)
					glb.opt.Language=L_ENGLISH;
				break;
		}
	}
	else
	{
		if (glb.opt.Language==L_FRENCH && !glb.div.avail_fr)
			glb.opt.Language=-1;
		if (glb.opt.Language==L_ENGLISH && !glb.div.avail_uk)
			glb.opt.Language=-1;
		if (glb.opt.Language==L_DEUTSCH && !glb.div.avail_de)
			glb.opt.Language=-1;
	}
	if (glb.opt.Language==-1)
	{
		if (glb.div.avail_fr)
			glb.opt.Language=L_FRENCH;
		else
		if (glb.div.avail_uk)
			glb.opt.Language=L_ENGLISH;
		else
		if (glb.div.avail_de)
			glb.opt.Language=L_DEUTSCH;
	}

	strcpy(glb.rsc.name,glb.opt.APP_Path);
	switch (glb.opt.Language)
	{
		case	L_FRENCH:
			strcat(glb.rsc.name,"BV4_FR.RSC");
			break;
		case	L_ENGLISH:
			strcat(glb.rsc.name,"BV4_UK.RSC");
			break;
		case	L_DEUTSCH:
			strcat(glb.rsc.name,"BV4_DE.RSC");
			break;
	}

sprintf(glb.div.log,"Init RSC:\n");
_reportLog(LOG_INI);
sprintf(glb.div.log,"  %s\n",glb.rsc.name);
_reportLog(LOG_INI);

	if (!_loadRSC(&glb.rsc))
		return FALSE;

	glb.rsc.head.trindex[FMOD][FMODP1].ob_height-=4;
	glb.rsc.head.trindex[FMOD][FMODP1].ob_y+=2;
	glb.rsc.head.trindex[FMOD][FMODP2].ob_height-=4;
	glb.rsc.head.trindex[FMOD][FMODP2].ob_y+=2;
	glb.rsc.head.trindex[FMOD][FMODP4].ob_height-=4;
	glb.rsc.head.trindex[FMOD][FMODP4].ob_y+=2;
	glb.rsc.head.trindex[FMOD][FMODP8].ob_height-=4;
	glb.rsc.head.trindex[FMOD][FMODP8].ob_y+=2;

	tree=glb.rsc.head.trindex[FMOUSE];
	for (i=1;i<=FMOUDN;i++)
	{
		glb.aes.s[i].mf_xhot	=	8;
		glb.aes.s[i].mf_yhot	=	8;
		glb.aes.s[i].mf_nplanes=	1;
		glb.aes.s[i].mf_fg		=	0;
		glb.aes.s[i].mf_bg		=	1;

		for (j=0;j<16;j++)
		{
			glb.aes.s[i].mf_mask[j]	=	tree[i].ob_spec.iconblk->ib_pmask[j];
			glb.aes.s[i].mf_data[j]	=	tree[i].ob_spec.iconblk->ib_pdata[j];
		}
	}

	for (i=0;i<glb.rsc.head.ntree;i++)
	{
		tree=glb.rsc.head.trindex[i];
		child=-1;
		do
		{
			child+=1;
			_initRSC(i,child);
		}	while ( !(tree[child].ob_flags & LASTOB) );
	}

sprintf(glb.div.log,"  Objects initialized\n");
_reportLog(LOG_INI);

	return TRUE;
}


/*******************************************************************************
	Init Moduls
*******************************************************************************/
void _initRWI()
{
	if (glb.parx.Active&P_TRM)
		_initTRM();
	if (glb.parx.Active&P_RIM)
		_initRIM();
	if (glb.parx.Active&P_WIM)
		_initWIM();
	if (glb.parx.Active&P_IFX)
		_initIFX();
	if (glb.parx.Active&P_BRO)
		_initBRO();
	if (glb.parx.Active&P_MOT)
		_initMOT();
	if (glb.parx.Active&P_PAL)
		_initPAL();
}


/*******************************************************************************
	Init RIM Moduls
*******************************************************************************/
void _initRIM()
{
	char		txt[FILENAME_MAX];
	int		obx,oby,obw,obh;
	DTA		*dta;
	int		n=0,drvold=-1;

	_prog(glb.rsc.head.frstr[INIT12],"");
	if (glb.parx.Mask&P_RIM)
		strcpy(glb.div.pname,glb.parx.Path);
	else
		strcpy(glb.div.pname,glb.opt.APP_Path);
	strcpy(txt,glb.div.pname);
	strcat(txt,"RIM\\");
	strcat(glb.div.pname,"RIM\\*.RIM");
	glb.parx.n_rim=0;
	if (glb.div.pname[1]==':')
	{
		drvold=Dgetdrv();
		Dsetdrv((int)glb.div.pname[0]-65);
	}

	if (glb.parx.n_rim>0 && glb.parx.i_rim!=NO_MEMORY)
	{
		_mFree(glb.parx.i_rim);
		glb.parx.i_rim=NO_MEMORY;
		_mFree(glb.parx.p_rim);
		glb.parx.p_rim=NO_MEMORY;
	}

sprintf(glb.div.log,"Loading RIM:\n");
_reportLog(LOG_INI);

	if (!Fsfirst(glb.div.pname,FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE))
	{
		dta=Fgetdta();
		do
		{
			strcpy(glb.div.pfname,txt);
			strcat(glb.div.pfname,dta->d_fname);
			_addRim(glb.div.pfname);
		}	while (!Fsnext());
	}

sprintf(glb.div.log,"\n");
_reportLog(LOG_INI);

	_initRSC(FMOD,FMODT1);
	_initRSC(FMOD,FMODP1);
	_initRSC(FMOD,FMODD1);
	n=_winFindId(TW_FORM,FMOD,TRUE);
	if (n!=-1)
	{
		wind_update(BEG_MCTRL);
		_coord(glb.rsc.head.trindex[FMOD],FMODT1,FALSE,&obx,&oby,&obw,&obh);
		_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODT1,MAX_DEPTH,obx,oby,obw,obh);
		_coord(glb.rsc.head.trindex[FMOD],FMODP1,FALSE,&obx,&oby,&obw,&obh);
		_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODP1,MAX_DEPTH,obx,oby,obw,obh);
		_coord(glb.rsc.head.trindex[FMOD],FMODD1,FALSE,&obx,&oby,&obw,&obh);
		_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODD1,MAX_DEPTH,obx,oby,obw,obh);
		wind_update(END_MCTRL);
	}

	if (drvold!=-1)
		Dsetdrv(drvold);
}


/*******************************************************************************
	Init WIM Moduls
*******************************************************************************/
void _initWIM()
{
	char		txt[FILENAME_MAX];
	int		obx,oby,obw,obh;
	DTA		*dta;
	int		n=0,drvold=-1;

	_prog(glb.rsc.head.frstr[INIT13],"");
	if (glb.parx.Mask&P_WIM)
		strcpy(glb.div.pname,glb.parx.Path);
	else
		strcpy(glb.div.pname,glb.opt.APP_Path);
	strcpy(txt,glb.div.pname);
	strcat(txt,"WIM\\");
	strcat(glb.div.pname,"WIM\\*.WIM");
	glb.parx.n_wim=0;
	if (glb.div.pname[1]==':')
	{
		drvold=Dgetdrv();
		Dsetdrv((int)glb.div.pname[0]-65);
	}

	if (glb.parx.n_wim>0 && glb.parx.i_wim!=NO_MEMORY)
	{
		_mFree(glb.parx.i_wim);
		glb.parx.i_wim=NO_MEMORY;
		_mFree(glb.parx.p_wim);
		glb.parx.p_wim=NO_MEMORY;
	}

sprintf(glb.div.log,"Loading WIM:\n");
_reportLog(LOG_INI);

	if (!Fsfirst(glb.div.pname,FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE))
	{
		dta=Fgetdta();
		do
		{
			strcpy(glb.div.pfname,txt);
			strcat(glb.div.pfname,dta->d_fname);
			_addWim(glb.div.pfname);
		}	while (!Fsnext());
	}

sprintf(glb.div.log,"\n");
_reportLog(LOG_INI);

	_initRSC(FMOD,FMODT2);
	_initRSC(FMOD,FMODP2);
	_initRSC(FMOD,FMODD2);
	n=_winFindId(TW_FORM,FMOD,TRUE);
	if (n!=-1)
	{
		wind_update(BEG_MCTRL);
		_coord(glb.rsc.head.trindex[FMOD],FMODT2,FALSE,&obx,&oby,&obw,&obh);
		_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODT2,MAX_DEPTH,obx,oby,obw,obh);
		_coord(glb.rsc.head.trindex[FMOD],FMODP2,FALSE,&obx,&oby,&obw,&obh);
		_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODP2,MAX_DEPTH,obx,oby,obw,obh);
		_coord(glb.rsc.head.trindex[FMOD],FMODD2,FALSE,&obx,&oby,&obw,&obh);
		_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODD2,MAX_DEPTH,obx,oby,obw,obh);
		wind_update(END_MCTRL);
	}

	if (drvold!=-1)
		Dsetdrv(drvold);
}


/*******************************************************************************
	Init IFX Moduls
*******************************************************************************/
void _initIFX()
{
	char		txt[FILENAME_MAX];
	int		obx,oby,obw,obh;
	DTA		*dta;
	int		n=0,drvold=-1;

	_prog(glb.rsc.head.frstr[INIT14],"");
	if (glb.parx.Mask&P_IFX)
		strcpy(glb.div.pname,glb.parx.Path);
	else
		strcpy(glb.div.pname,glb.opt.APP_Path);
	strcpy(txt,glb.div.pname);
	strcat(txt,"IFX\\");
	strcat(glb.div.pname,"IFX\\*.IFX");
	glb.parx.n_ifx=0;
	if (glb.div.pname[1]==':')
	{
		drvold=Dgetdrv();
		Dsetdrv((int)glb.div.pname[0]-65);
	}

	if (glb.parx.n_ifx>0 && glb.parx.i_ifx!=NO_MEMORY)
	{
		_mFree(glb.parx.i_ifx);
		glb.parx.i_ifx=NO_MEMORY;
		_mFree(glb.parx.p_ifx);
		glb.parx.p_ifx=NO_MEMORY;
	}

sprintf(glb.div.log,"Loading IFX:\n");
_reportLog(LOG_INI);

	if (!Fsfirst(glb.div.pname,FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE))
	{
		dta=Fgetdta();
		do
		{
			strcpy(glb.div.pfname,txt);
			strcat(glb.div.pfname,dta->d_fname);
			_addIfx(glb.div.pfname);
		}	while (!Fsnext());
	}

sprintf(glb.div.log,"\n");
_reportLog(LOG_INI);

	_initRSC(FMOD,FMODT4);
	_initRSC(FMOD,FMODP4);
	_initRSC(FMOD,FMODD4);
	n=_winFindId(TW_FORM,FMOD,TRUE);
	if (n!=-1)
	{
		wind_update(BEG_MCTRL);
		_coord(glb.rsc.head.trindex[FMOD],FMODT4,FALSE,&obx,&oby,&obw,&obh);
		_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODT4,MAX_DEPTH,obx,oby,obw,obh);
		_coord(glb.rsc.head.trindex[FMOD],FMODP4,FALSE,&obx,&oby,&obw,&obh);
		_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODP4,MAX_DEPTH,obx,oby,obw,obh);
		_coord(glb.rsc.head.trindex[FMOD],FMODD4,FALSE,&obx,&oby,&obw,&obh);
		_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODD4,MAX_DEPTH,obx,oby,obw,obh);
		wind_update(END_MCTRL);
	}

	if (drvold!=-1)
		Dsetdrv(drvold);
}


/*******************************************************************************
	Init TRM Modul
*******************************************************************************/
void _initTRM()
{
	PARX_TRM	*trm;
	int		obx,oby,obw,obh;
	long		lf;
	int		ha,in,n;
	char		*p;

	_prog(glb.rsc.head.frstr[INIT15],"");
	if (glb.parx.Mask&P_TRM)
	{
		strcpy(glb.div.pname,glb.parx.Path);
		strcat(glb.div.pname,"PARX.TRM");
	}
	else
	{
		strcpy(glb.div.pname,glb.opt.APP_Path);
		strcat(glb.div.pname,"BV4.TRM");
	}

sprintf(glb.div.log,"Loading TRM:\n");
_reportLog(LOG_INI);
sprintf(glb.div.log,"  %s\n",glb.div.pname);
_reportLog(LOG_INI);

	if (glb.parx.i_trm!=NO_MEMORY)
	{
		_mFree(glb.parx.i_trm);
		_mFree(glb.parx.p_trm);
	}

	in=NO_MEMORY;
	ha=(int)Fopen(glb.div.pname,FO_READ);
	if (ha>0)
	{
		lf=Fseek(0L,ha,2);
		Fseek(0L,ha,0);
#ifdef FORCE_MALLOC
		in=_mAllocForce(MEM_TRM,lf,0);
#else
		in=_mAlloc(lf,0);
#endif
		if (in!=NO_MEMORY)
		{
			trm=(PARX_TRM *)glb.mem.adr[in];
			if (Fread(ha,lf,(void *)trm)==lf && !strncmp(trm->head,"PARX_TRM",8L))
			{
				glb.parx.i_trm=in;

				in=_mAlloc((long)trm->nmb*38L,0);
				if (in!=NO_MEMORY)
				{
					memcpy((void *)glb.mem.adr[in],(void *)(glb.mem.adr[glb.parx.i_trm]+sizeof(PARX_TRM)),32L*(long)trm->nmb);
					glb.parx.p_trm=in;
				}

				_initRSC(FMOD,FMODT8);
				_initRSC(FMOD,FMODP8);
				_initRSC(FMOD,FMODD8);
				n=_winFindId(TW_FORM,FMOD,TRUE);
				if (n!=-1)
				{
					wind_update(BEG_MCTRL);
					_coord(glb.rsc.head.trindex[FMOD],FMODT8,FALSE,&obx,&oby,&obw,&obh);
					_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODT8,MAX_DEPTH,obx,oby,obw,obh);
					_coord(glb.rsc.head.trindex[FMOD],FMODP8,FALSE,&obx,&oby,&obw,&obh);
					_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODP8,MAX_DEPTH,obx,oby,obw,obh);
					wind_update(END_MCTRL);
				}
			}
		}
		Fclose(ha);
	}
	if (in!=NO_MEMORY && glb.parx.i_trm==NO_MEMORY)
		_mFree(in);
	if (glb.parx.i_trm!=NO_MEMORY)
	{
		if (_trmInit())
		{
			_mFree(glb.parx.i_trm);
			glb.parx.i_trm=NO_MEMORY;
		}
		else
		{
			trm=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
			sprintf(glb.div.log,"  %3li v%1i.%02i\n",glb.mem.len[glb.parx.i_trm],trm->ver/100,trm->ver%100);
			_reportLog(LOG_INI);
			p=(char *)((long)trm+sizeof(PARX_TRM));
			for (n=0;n<trm->nmb;n++)
			{
				sprintf(glb.div.log,"  %02i: %30s\n",n,p);
				_reportLog(LOG_INI);
				p+=32L;
			}
			sprintf(glb.div.log,"\n");
			_reportLog(LOG_INI);
		}
		_clearAesBuffer();
	}
}


/*******************************************************************************
	Init BRO Modul
*******************************************************************************/
void _initBRO()
{
	PARX_BRO	*bro;
	char		ext[6];
	int		i,obx,oby,obw,obh;
	int		ha,in,n;
	long		lf;

	_prog(glb.rsc.head.frstr[INIT16],"");

	for (i=glb.vdi.extnd[4];i>0;i--)
	{
		if (glb.parx.Mask&P_BRO)
		{
			strcpy(glb.div.pname,glb.parx.Path);
			strcat(glb.div.pname,"PARX");
		}
		else
		{
			strcpy(glb.div.pname,glb.opt.APP_Path);
			strcat(glb.div.pname,"BV4");
		}
		sprintf(ext,".B%02i",i);
		strcat(glb.div.pname,ext);

		in=NO_MEMORY;
		ha=(int)Fopen(glb.div.pname,FO_READ);
		if (ha>0)
		{
			lf=Fseek(0L,ha,2);
			Fseek(0L,ha,0);
			in=_mAlloc(lf,0);
			if (in!=NO_MEMORY)
			{
				bro=(PARX_BRO *)glb.mem.adr[in];
				if (Fread(ha,lf,(void *)bro)==lf && !strncmp(bro->head,"PARX_BRO",8L))
				{
sprintf(glb.div.log,"Loading BRO file:\n");
_reportLog(LOG_INI);
sprintf(glb.div.log,"  %s\n",glb.div.pname);
_reportLog(LOG_INI);
					glb.parx.i_bro=in;
					i=0;
					_initRSC(FMOD,FMODT20);
					n=_winFindId(TW_FORM,FMOD,TRUE);
					if (n!=-1)
					{
						wind_update(BEG_MCTRL);
						_coord(glb.rsc.head.trindex[FMOD],FMODT20,FALSE,&obx,&oby,&obw,&obh);
						_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODT20,MAX_DEPTH,obx,oby,obw,obh);
						wind_update(END_MCTRL);
					}
				}
			}
			Fclose(ha);
		}
		if (in!=NO_MEMORY && glb.parx.i_bro==NO_MEMORY)
			_mFree(in);
	}
}


/*******************************************************************************
	Init MOT Modul
*******************************************************************************/
void _initMOT()
{
	PARX_MOT	*mot;
	char		ext[6];
	int		i,obx,oby,obw,obh;
	int		ha,in,n;
	long		lf;

	_prog(glb.rsc.head.frstr[INIT17],"");

	for (i=glb.vdi.extnd[4];i>0;i--)
	{
		if (glb.parx.Mask&P_MOT)
		{
			strcpy(glb.div.pname,glb.parx.Path);
			strcat(glb.div.pname,"PARX");
		}
		else
		{
			strcpy(glb.div.pname,glb.opt.APP_Path);
			strcat(glb.div.pname,"BV4");
		}
		sprintf(ext,".M%02i",i);
		strcat(glb.div.pname,ext);

		in=NO_MEMORY;
		ha=(int)Fopen(glb.div.pname,FO_READ);
		if (ha>0)
		{
			lf=Fseek(0L,ha,2);
			Fseek(0L,ha,0);
			in=_mAlloc(lf,0);
			if (in!=NO_MEMORY)
			{
				mot=(PARX_MOT *)glb.mem.adr[in];
				if (Fread(ha,lf,(void *)mot)==lf && !strncmp(mot->head,"PARX_MOT",8L))
				{
sprintf(glb.div.log,"Loading MOT file:\n");
_reportLog(LOG_INI);
sprintf(glb.div.log,"  %s\n",glb.div.pname);
_reportLog(LOG_INI);
					glb.parx.i_mot=in;
					i=0;
					_initRSC(FMOD,FMODT40);
					n=_winFindId(TW_FORM,FMOD,TRUE);
					if (n!=-1)
					{
						wind_update(BEG_MCTRL);
						_coord(glb.rsc.head.trindex[FMOD],FMODT40,FALSE,&obx,&oby,&obw,&obh);
						_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODT40,MAX_DEPTH,obx,oby,obw,obh);
						wind_update(END_MCTRL);
					}
				}
			}
			Fclose(ha);
		}
		if (in!=NO_MEMORY && glb.parx.i_mot==NO_MEMORY)
			_mFree(in);
	}
}


/*******************************************************************************
	Init PAL Modul
*******************************************************************************/
void _initPAL()
{
	PARX_PAL	*pal;
	char		ext[6];
	int		i,obx,oby,obw,obh;
	int		ha,in,n;
	long		lf;

	_prog(glb.rsc.head.frstr[INIT18],"");

	for (i=glb.vdi.extnd[4];i>0;i--)
	{
		if (glb.parx.Mask&P_PAL)
		{
			strcpy(glb.div.pname,glb.parx.Path);
			strcat(glb.div.pname,"PARX");
		}
		else
		{
			strcpy(glb.div.pname,glb.opt.APP_Path);
			strcat(glb.div.pname,"BV4");
		}
		sprintf(ext,".P%02i",i);
		strcat(glb.div.pname,ext);

		in=NO_MEMORY;
		ha=(int)Fopen(glb.div.pname,FO_READ);
		if (ha>0)
		{
			lf=Fseek(0L,ha,2);
			Fseek(0L,ha,0);
			in=_mAlloc(lf,0);
			if (in!=NO_MEMORY)
			{
				pal=(PARX_PAL *)glb.mem.adr[in];
				if (Fread(ha,lf,(void *)pal)==lf && !strncmp(pal->head,"PARX_PAL",8L))
				{
sprintf(glb.div.log,"Loading PAL file:\n");
_reportLog(LOG_INI);
sprintf(glb.div.log,"  %s\n",glb.div.pname);
_reportLog(LOG_INI);
					glb.parx.i_pal=in;
					i=0;
					_initRSC(FMOD,FMODT80);
					n=_winFindId(TW_FORM,FMOD,TRUE);
					if (n!=-1)
					{
						wind_update(BEG_MCTRL);
						_coord(glb.rsc.head.trindex[FMOD],FMODT80,FALSE,&obx,&oby,&obw,&obh);
						_winObdraw(n,glb.rsc.head.trindex[FMOD],FMODT80,MAX_DEPTH,obx,oby,obw,obh);
						wind_update(END_MCTRL);
					}
				}
			}
			Fclose(ha);
		}
		if (in!=NO_MEMORY && glb.parx.i_pal==NO_MEMORY)
			_mFree(in);
	}
}


/*******************************************************************************
	Init Desk
*******************************************************************************/
void _initDesk()
{
	OBJECT		*tree;
	int			i;

	_prog(glb.rsc.head.frstr[INIT19],"");
	if (glb.aes.type!=0 && glb.aes.tree.desk!=-1)
	{
		tree=glb.rsc.head.trindex[glb.aes.tree.desk];
		tree->ob_x			=	glb.aes.desk.x;
		tree->ob_y			=	glb.aes.desk.y;
		tree->ob_width		=	glb.aes.desk.w;
		tree->ob_height	=	glb.aes.desk.h;

		if (glb.aes.desk.trash_icon!=-1)
			tree[glb.aes.desk.trash_icon].ob_flags|=HIDETREE;
		if (glb.aes.desk.print_icon!=-1)
			tree[glb.aes.desk.print_icon].ob_flags|=HIDETREE;
		if (glb.aes.desk.scrap_icon1!=-1)
			tree[glb.aes.desk.scrap_icon1].ob_flags|=HIDETREE;
		if (glb.aes.desk.scrap_icon2!=-1)
			tree[glb.aes.desk.scrap_icon2].ob_flags|=HIDETREE;

		if (glb.aes.desk.first_icon!=-1)
		{
			for (i=0;i<glb.opt.Win_Num;i++)
			{
				tree[glb.aes.desk.first_icon+i].ob_type=glb.rsc.head.trindex[ICONE][ICNDEF].ob_type;
				tree[glb.aes.desk.first_icon+i].ob_spec=glb.rsc.head.trindex[ICONE][ICNDEF].ob_spec;
				tree[glb.aes.desk.first_icon+i].ob_width=glb.rsc.head.trindex[ICONE][ICNDEF].ob_width;
				tree[glb.aes.desk.first_icon+i].ob_height=glb.rsc.head.trindex[ICONE][ICNDEF].ob_height;
				tree[glb.aes.desk.first_icon+i].ob_flags|=HIDETREE;
			}
		}

		_initRSC(FINT,FINTCOL|FLAGS15);
		_initRSC(FINT,FINTTRM|FLAGS15);

		wind_set(0,WF_NEWDESK,tree,0);
		form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,glb.aes.desk.h);
	}
}


/*******************************************************************************
	Init Box
*******************************************************************************/
void _initBox()
{
	int		x,y,dum;

	graf_mkstate(&x,&y,&dum,&dum);
	glb.aes.event.x2=glb.aes.desk.x+1;
	glb.aes.event.y2=glb.aes.desk.y+1;
	glb.aes.event.w2=glb.aes.desk.w-2;
	glb.aes.event.h2=glb.aes.desk.h-2;

	if (x<glb.aes.desk.x || x>glb.aes.desk.x+glb.aes.desk.w-1 || y<glb.aes.desk.y || y>glb.aes.desk.y+glb.aes.desk.h)
		glb.aes.event.f2=0;
	else
		glb.aes.event.f2=1;
}


/*******************************************************************************
	Exit Desktop
*******************************************************************************/
void _exitDesk()
{
	int	i;

	for (i=0;i<glb.opt.Win_Num;i++)
		if (W[i].handle>0)
		{
			_winClose(i);
			_clearAesBuffer();
		}
	if (glb.aes.type!=0 && glb.aes.tree.desk!=-1)
	{
		wind_set (0,WF_NEWDESK,0,0,0,0);
		form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,glb.aes.desk.h);
	}
}


/*******************************************************************************
	Exit Moduls
*******************************************************************************/
void _exitRWI()
{
	_trmExit();
}


/*******************************************************************************
	Exit the EGlib & program RSC files
*******************************************************************************/
void _exitRsc()
{
	_unloadRSC(&glb.rsc);
}


/*******************************************************************************
	Exit VDI
*******************************************************************************/
void _exitVdi()
{
	_loadPal(glb.vdi.out[13]);
	v_clsvwk(glb.vdi.ha);
}


/*******************************************************************************
	Exit AES
*******************************************************************************/
void _exitAes()
{
	_clearAesBuffer();
	if (glb.div.Exit==2 && glb.aes.ver>=0x400)
		shel_write(10,SHUT_COMPLETED,0,0,0);
	appl_exit();
}


/*******************************************************************************
	Exit Memory Manager
*******************************************************************************/
void _exitMem()
{
	DTA	*dta;
	int	drvold=-1;
	char	path[FILENAME_MAX],file[FILENAME_MAX];

	sprintf(path,"%sBV4__%03i.*",glb.div.SWP_Path,glb.aes.id);
	if (path[1]==0x3A)
	{
		drvold=Dgetdrv();
		Dsetdrv((int)path[0]-65);
	}
	if (Fsfirst(path,FA_ARCHIVE)==0)
	{
		dta=Fgetdta();
		do
		{
			strcpy(file,glb.div.SWP_Path);
			strcat(file,dta->d_fname);
			Fdelete(file);
		}	while (Fsnext()==0);
	}
	if (drvold!=-1)
		Dsetdrv(drvold);
	(*manag_free)();
	Mfree((void *)glb.mem.mem);
}
