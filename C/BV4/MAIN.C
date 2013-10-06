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

/*******************************************************************************
	INCLUDES
*******************************************************************************/
#include		"PROTO.H"

/*******************************************************************************
	VARIABLES
*******************************************************************************/
GLB			glb;
window		*W;
SLCT_STR		*slct;
IMG			*img=NULL;

/*******************************************************************************
	VARIABLES LOCALES
*******************************************************************************/
static int		_argc;
static char		**_argv;

/*******************************************************************************
	FONCTION PRINCIPALE
*******************************************************************************/
main(int argc,char *argv[])
{
	long	adr,len=0L;
	int	i,ret;

	_argc=argc;											/*	Tout ce bazar pour sauvegarder	*/
	_argv=argv;											/*	la ligne de commande					*/
	for (i=1;i<argc;i++)
		len+=strlen(argv[i])+2L;
	len+=sizeof(char **)*((long)argc+1L);
	adr=(long)Malloc(len);
	if (adr>0L)
	{
		_argv=(char **)adr;
		_argv[0]=(char *)(adr+4L*(long)_argc);
		_argv[0][0]='\0';
		for (i=1;i<_argc;i++)
		{
			_argv[i]=(char *)((long)_argv[i-1]+strlen(_argv[i-1])+1L);
			strcpy(_argv[i],argv[i]);
		}
	}

	ret=initAll();
	if (ret)
	{
		_EGlib();
		if (adr>0L)
			Mfree((void *)adr);
		return FALSE;
	}
	if (adr>0L)
		Mfree((void *)adr);
	return ret;
}

/*******************************************************************************
	GESTION DE LA LIGNE DE COMMANDE
*******************************************************************************/
void LigneDeCommande()
{
	int	i;

sprintf(glb.div.log,"CommandLine: %i parameters\n",_argc-1);
_reportLog(LOG_INI);

	menuOff();
	for (i=1;i<_argc;i++)
	{
sprintf(glb.div.log,"CommandLine: %s\n",_argv[i]);
_reportLog(LOG_INI);
		if (_fexist(_argv[i],NULL))
			wopen(_argv[i]);
	}
	menuOn();
}


/*******************************************************************************
	Fonction princpale de la librairie
*******************************************************************************/
void _EGlib()
{
	int	i;

	glb.div.Exit=-1;

	/****************************************************************************
		Init du Memory Manager
	****************************************************************************/
	if (!_initMem())
	{
		_progOff();
		_exitAes();
		return;
	}

	/****************************************************************************
		Init de la structure des fenàtres
	****************************************************************************/
	if (!_initWin())
	{
		_progOff();
		goto exitWin;
	}

	/****************************************************************************
		Init de la VDI
	****************************************************************************/
	_mousework();
	_initVdi();

	/****************************************************************************
		Init des fontes GDOS
	****************************************************************************/
	_mousework();
	_initGDOS();

	/****************************************************************************
		Initialisations diverses
	****************************************************************************/
	_mousework();
	_initDiv();

	/****************************************************************************
		Charge & init le RSC de la librairie et du programme
	****************************************************************************/
	_mousework();
	if (!_initRsc())
	{
		_progOff();
		goto exitRsc;
	}

	/****************************************************************************
		Active la fenàtre de progression
	****************************************************************************/
	_progOff();
	glb.div.win=1;
	_progOn();

	/****************************************************************************
		Init des modules de Parx
	****************************************************************************/
	_initRWI();
	_mousework();

	/****************************************************************************
		Init du bureau
	****************************************************************************/
	_initDesk();
	_mousework();

	/****************************************************************************
		Init de la barre de menu
	****************************************************************************/
	_mousework();
	_menuBar(glb.aes.tree.menu,TRUE);

	/****************************************************************************
		Init de l'ÇvÇnement boåte (palette)
	****************************************************************************/
	_mousework();
	_initBox();

	if (glb.div.Exit==-1)
		glb.div.Exit=0;

	/****************************************************************************
		Appel de la derniäre fonction d'init
	****************************************************************************/
	initLast();

	/****************************************************************************
		Lecture du fichier INI (deuxiäme passe: fenàtres+aide)
	****************************************************************************/
	_mousework();
	_loadINI(1);

	/****************************************************************************
		Exit de la barre de progression
	****************************************************************************/
	_progOff();

	/****************************************************************************
		Gäre la ligne de commande
	****************************************************************************/
	LigneDeCommande();

	/****************************************************************************
		Boucle AES principale
	****************************************************************************/
	graf_mouse(ARROW,0);
	while (!glb.div.Exit)
	{
		_gereAes();
		if (glb.div.Exit && glb.aes.type!=1 && !glb.aes.info.sys.multitask)
		{
			glb.div.Exit=0;								/*	if ACC: no exit !		*/
			for (i=0;i<glb.opt.Win_Num;i++)
				if (W[i].handle>0)
				{
					_winClose(i);
					_clearAesBuffer();
				}
			if (glb.opt.Save_Config)
				_saveINI();
		}
	}

	/****************************************************************************
		Sauvegarde du fichier INI
	****************************************************************************/
	_mousework();
	if (glb.opt.Save_Config)
		_saveINI();

	/****************************************************************************
		Appel de la premiäre fonction de sortie
	****************************************************************************/
	_mousework();
	if (glb.func.eFirst!=0)
		(*glb.func.eFirst)();

	/****************************************************************************
		Exit de la barre de menu
	****************************************************************************/
	_mousework();
	_menuBar(glb.aes.tree.menu,FALSE);

	/****************************************************************************
		Exit du bureau
	****************************************************************************/
	_mousework();
	_exitDesk();

	/****************************************************************************
		Exit des modules de Parx
	****************************************************************************/
	_mousework();
	_exitRWI();

exitRsc:
	/****************************************************************************
		Exit des fichiers RSC
	****************************************************************************/
	_mousework();
	_exitRsc();

	/****************************************************************************
		Exit de la VDI
	****************************************************************************/
	_mousework();
	_exitVdi();

exitWin:
	/****************************************************************************
		Exit du Memory Manager
	****************************************************************************/
	_mousework();
	_exitMem();
	_exitReport();

	/****************************************************************************
		Exit de l'AES
	****************************************************************************/
	graf_mouse(ARROW,0);
	_exitAes();

	return;
}

/*******************************************************************************
	DÇsactivation du menu
*******************************************************************************/
void menuOff()
{
	glb.rsc.head.trindex[MENU][MBRK].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MINFO].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MOPEN].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MSLIDE].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MCNV].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MFULL].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MMOSA].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MSAVE].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MUSAVE].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MPRTWIM].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MPRTGDOS].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MCLS].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MACLS].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MZOOM].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MQUIT].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MLOG].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MOPT].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MSEL].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MMOD].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MMEM].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MSYS].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MCNF].ob_state|=DISABLED;
	_menuBar(glb.aes.tree.menu,TRUE);
}


/*******************************************************************************
	Activation du menu
*******************************************************************************/
void menuOn()
{
	glb.rsc.head.trindex[MENU][MBRK].ob_state|=DISABLED;
	glb.rsc.head.trindex[MENU][MINFO].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MOPEN].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MSLIDE].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MCNV].ob_state&=~DISABLED;
	if ( isIMG() )
	{
		glb.rsc.head.trindex[MENU][MFULL].ob_state&=~DISABLED;
		glb.rsc.head.trindex[MENU][MMOSA].ob_state&=~DISABLED;
		glb.rsc.head.trindex[MENU][MSAVE].ob_state&=~DISABLED;
		glb.rsc.head.trindex[MENU][MUSAVE].ob_state&=~DISABLED;
		glb.rsc.head.trindex[MENU][MPRTWIM].ob_state&=~DISABLED;
		glb.rsc.head.trindex[MENU][MPRTGDOS].ob_state&=~DISABLED;
		glb.rsc.head.trindex[MENU][MCLS].ob_state&=~DISABLED;
		glb.rsc.head.trindex[MENU][MACLS].ob_state&=~DISABLED;
		glb.rsc.head.trindex[MENU][MZOOM].ob_state&=~DISABLED;
	}
	glb.rsc.head.trindex[MENU][MQUIT].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MLOG].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MOPT].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MSEL].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MMOD].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MMEM].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MSYS].ob_state&=~DISABLED;
	glb.rsc.head.trindex[MENU][MCNF].ob_state&=~DISABLED;
	_menuBar(glb.aes.tree.menu,TRUE);
}

/*******************************************************************************
	Calcule l'intersection de 2 rectangles dans p2 et renvoie un flag
*******************************************************************************/
int _rcIntersect(GRECT *p1,GRECT *p2)
{
	int		tx,ty,tw,th;

	if (p1->g_x==0 && p1->g_y==0 && p1->g_w==0 && p1->g_h==0)
	{
		tx=p2->g_x;
		ty=p2->g_y;
		tw=p2->g_w;
		th=p2->g_h;
	}
	else if (p2->g_x==0 && p2->g_y==0 && p2->g_w==0 && p2->g_h==0)
	{
		tx=p1->g_x;
		ty=p1->g_y;
		tw=p1->g_w;
		th=p1->g_h;
	}
	else
	{
		tw=min(p2->g_x+p2->g_w,p1->g_x+p1->g_w);
		th=min(p2->g_y+p2->g_h,p1->g_y+p1->g_h);
		tx=max(p2->g_x,p1->g_x);
		ty=max(p2->g_y,p1->g_y);
	}
	p2->g_x=tx;
	p2->g_y=ty;
	p2->g_w=tw-tx;
	p2->g_h=th-ty;
	return ((tw>tx) && (th>ty));
}


/*******************************************************************************
	Clip ou dÇclip une zone avec la VDI
*******************************************************************************/
void _setClip(int flag,GRECT *area)
{
	int		pxy[4];

	pxy[0]=area->g_x;
	pxy[1]=area->g_y;
	pxy[2]=area->g_w+area->g_x-1;
	pxy[3]=area->g_h+area->g_y-1;
	vs_clip (glb.vdi.ha,flag,pxy);
}


/*******************************************************************************
	Charge les n premiäres couleurs de la palette systäme
*******************************************************************************/
void _loadPal(int n)
{
	typedef int		t_rgb[3];
	t_rgb				*col;
	int				i;

	if (glb.vdi.pal)
	{
		col=(t_rgb *)glb.mem.adr[glb.vdi.pal];
		for (i=0;i<min(n,glb.vdi.out[13]);i++)
			vs_color(glb.vdi.ha,i,(int *)col[i]);
	}
}


/*******************************************************************************
	Arrondit une dimension au mot supärieur (VDI MFDB)
*******************************************************************************/
int _word(int val)
{
	return (15+val)/16;
}


/*******************************************************************************
	Gestion du signal QUIT de MiNT
*******************************************************************************/
#pragma warn -par
void _sigQUIT(long ptr)
{
	glb.div.Exit=3;
}
#pragma warn +par


/*******************************************************************************
	Fonctions d'Çcriture dans le fichier LOG
*******************************************************************************/
void _reportLog(long flag)
{
	FILE			*ha;

	if (glb.opt.log && glb.opt.logmask&flag)
	{
		ha=fopen(glb.opt.LOG_File,"a+");
		if (ha)
		{
			if (flag&LOG_INI)
				fprintf(ha,"INI| ");
			else if (flag&LOG_MEM)
				fprintf(ha,"MEM| ");
			else if (flag&LOG_TRM)
				fprintf(ha,"TRM| ");
			else if (flag&LOG_RIM)
				fprintf(ha,"RIM| ");
			else if (flag&LOG_WIM)
				fprintf(ha,"WIM| ");
			else if (flag&LOG_IFX)
				fprintf(ha,"IFX| ");
			fprintf(ha,"%s",glb.div.log);
			fclose(ha);
		}
	}
}

void _initReport()
{
	time_t		now;
	struct tm	*snow;
	char			txt[20];

	if (glb.opt.log)
	{
		if (_fexist(glb.opt.LOG_File,NULL))
			Fdelete(glb.opt.LOG_File);
		time(&now);
		snow=localtime(&now);
		strftime(txt,20L,"%d/%m/%y %H:%M:%S",snow);
		sprintf(glb.div.log,"------------------- [%s] -------------------\n",txt);
		_reportLog(LOG_INI);
	}
}

void _exitReport()
{
	time_t		now;
	struct tm	*snow;
	char			txt[20];

	if (glb.opt.log)
	{
		time(&now);
		snow=localtime(&now);
		strftime(txt,20L,"%d/%m/%y %H:%M:%S",snow);
		sprintf(glb.div.log,"------------------- [%s] -------------------\n",txt);
		_reportLog(LOG_INI);
	}
}
