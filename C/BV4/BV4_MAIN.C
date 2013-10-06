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

long			tfre=0;
int			Curr=0;
int			Break=FALSE;
int			nW,nH,nI,nJ,wmin,hmin;
int			working=-1;


/*******************************************************************************
*******************************************************************************/
void initLast()
{
	updFreeMem();
}


/*******************************************************************************
	Routines pour sortir du programme...
*******************************************************************************/
void cdecl exitFirst()
{
	int	x,y,w,h;

	form_center(glb.rsc.head.trindex[WAIT],&x,&y,&w,&h);
	x-=4;	w+=8;
	y-=4;	h+=8;
	wind_update(BEG_MCTRL);
	graf_mouse(M_OFF,0);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	form_dial(FMD_GROW,0,0,0,0,x,y,w,h);
	_obPutStr(glb.rsc.head.trindex[WAIT],WAITNUM,"");

	form_dial(FMD_SHRINK,0,0,0,0,x,y,w,h);
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
	graf_mouse(M_ON,0);
	graf_mouse(ARROW,0);
	wind_update(END_MCTRL);
}


/*******************************************************************************
	FONCTION DE GESTION DU MENU
*******************************************************************************/
void gereMenu(int option)
{
	switch (option)
	{
		case	MINFO:		Finfo();				break;
		case	MOPEN:		wload();				break;
		case	MGEN:			wgen();				break;
		case	MSLIDE:		Fslide();			break;
		case	MCNV:			Fconvert();			break;
		case	MFULL:		fullscreen(-1);	break;
		case	MMOSA:		mosaique();			break;
		case	MSAVE:		wsave(-1);			break;
		case	MUSAVE:		wusave(-1);			break;
		case	MPRTWIM:		wprintWIM(-1);		break;
		case	MPRTGDOS:	wprintGDOS(-1);	break;
		case	MCLS:			closeImg(-1);		break;
		case	MACLS:		closeAllImg();		break;
		case	MZOOM:		wZoom(-1);			break;
		case	MQUIT:		quit();				break;
		case	MBRK:			Break=TRUE;			break;
		case	MLOG:			Flog();				break;
		case	MOPT:			Foption();			break;
		case	MINT:			Finterface();		break;
		case	MSEL:			FoptionSEL();		break;
		case	MMOD:			Fmodule();			break;
		case	MMEM:			Fmemory();			break;
		case	MSYS:			Fsystem();			break;
		case	MCNF:			_saveINI();			break;
	}
}


/*******************************************************************************
	FONCTION info() OUVRE UNE FENETRE AVEC FORMULAIRE D'INFORMATION
*******************************************************************************/
void Finfo()
{
	_winForm(FINFO,PRG_SNAME,PRG_SNAME,-1,WIC_INF,0,0);
}


/*******************************************************************************
	MISE A JOUR DU FORMULAIRE LOG
*******************************************************************************/
void setLog()
{
	OBJECT	*tree=glb.rsc.head.trindex[FLOG];
	char		txt[32];
	int		i;

	if (img[Curr].flag)
	{
		strcpy(txt,img[Curr].iname);
		_obPutStr(tree,FLOGINOM,txt);

		i=_winFindId(TW_IMG,Curr,FALSE);
		if (glb.mem.len[W[i].in]<1024L)
			sprintf(txt,"%li",glb.mem.len[W[i].in]);
		else
			sprintf(txt,"%lik",glb.mem.len[W[i].in]/1024L);
		_obPutStr(tree,FLOGIMIMG,txt);

		i=_winFindId(TW_IMG,Curr,FALSE);
		if (glb.mem.len[W[i].ipal]<1024L)
			sprintf(txt,"%li",glb.mem.len[W[i].ipal]);
		else
			sprintf(txt,"%lik",glb.mem.len[W[i].ipal]/1024L);
		_obPutStr(tree,FLOGIMPAL,txt);

		if (img[Curr].mfdb.nplanes<16)
			sprintf(txt,"%ib (%lic)",img[Curr].mfdb.nplanes,1L<<img[Curr].mfdb.nplanes);
		else
			sprintf(txt,"TC %ib",img[Curr].mfdb.nplanes);
		_obPutStr(tree,FLOGIPAL,txt);

		sprintf(txt,"%ix%i",img[Curr].w,img[Curr].h);
		_obPutStr(tree,FLOGISIZ,txt);

		if (img[Curr].num!=1)
			sprintf(txt,"%s (%i)",img[Curr].name,img[Curr].num);
		else
			strcpy(txt,img[Curr].name);
		_obPutStr(tree,FLOGFNOM,txt);

		if (img[Curr].flen<1024L)
			sprintf(txt,"%li",img[Curr].flen);
		else
			sprintf(txt,"%lik",img[Curr].flen/1024L);
		_obPutStr(tree,FLOGFLEN,txt);

		if (img[Curr].oldplanes<16)
			sprintf(txt,"%ib (%lic)",img[Curr].oldplanes,1L<<img[Curr].oldplanes);
		else
			sprintf(txt,"TC %ib",img[Curr].oldplanes);
		_obPutStr(tree,FLOGFPAL,txt);

		sprintf(txt,"%ix%i",img[Curr].oldw,img[Curr].oldh);
		_obPutStr(tree,FLOGFSIZ,txt);

		strcpy(txt,img[Curr].type);
		_obPutStr(tree,FLOGRIM,txt);
	}
	else
	{
		strcpy(txt,"");
		_obPutStr(tree,FLOGINOM,txt);
		_obPutStr(tree,FLOGIMIMG,txt);
		_obPutStr(tree,FLOGIMPAL,txt);
		_obPutStr(tree,FLOGIPAL,txt);
		_obPutStr(tree,FLOGISIZ,txt);
		_obPutStr(tree,FLOGFNOM,txt);
		_obPutStr(tree,FLOGFLEN,txt);
		_obPutStr(tree,FLOGFPAL,txt);
		_obPutStr(tree,FLOGFSIZ,txt);
		_obPutStr(tree,FLOGRIM,txt);
	}

	for (i=0;i<glb.opt.Win_Num;i++)
		if ( W[i].type==TW_FORM && W[i].id==FLOG && W[i].handle!=-1 )
		{
			_winRedraw(i,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind);
			i=glb.opt.Win_Num;
		}

}


/*******************************************************************************
	FONCTION log() OUVRE UNE FENETRE AVEC FORMULAIRE
*******************************************************************************/
void Flog()
{
	int	i;

	wind_get(0,WF_TOP,&i);
	i=_winFindWin(i);
	if (i!=-1)
		if ( W[i].type==TW_IMG )
			Curr=W[i].id;
	_initRSC(FLOG,FLOGNMB);
	setLog();
	_winForm(FLOG,glb.rsc.head.frstr[TWLOG],glb.rsc.head.frstr[TSLOG],ICONE,ICNLOG,0,0);
}


/*******************************************************************************
	FONCTION option() OUVRE UNE FENETRE AVEC FORMULAIRE
*******************************************************************************/
void Foption()
{
	_winForm(FOPT,glb.rsc.head.frstr[TWOPT],glb.rsc.head.frstr[TSOPT],-1,WIC_OPT,0,0);
}


/*******************************************************************************
	FONCTION interface() OUVRE UNE FENETRE AVEC FORMULAIRE
*******************************************************************************/
void Finterface()
{
	_winForm(FINT,glb.rsc.head.frstr[TWINT],glb.rsc.head.frstr[TSINT],-1,WIC_OPT,0,0);
}


/*******************************************************************************
	FONCTION option() OUVRE UNE FENETRE AVEC FORMULAIRE
*******************************************************************************/
void FoptionSEL()
{
	_winForm(FSEL,glb.rsc.head.frstr[TWSEL],glb.rsc.head.frstr[TSSEL],-1,WIC_OPT,0,0);
}


/*******************************************************************************
	FONCTION Slide() OUVRE UNE FENETRE AVEC FORMULAIRE
*******************************************************************************/
void Fslide()
{
	_winForm(FSLIDE,glb.rsc.head.frstr[TWSLIDE],glb.rsc.head.frstr[TSSLIDE],ICONE,ICNSLD,0,0);
}


/*******************************************************************************
	FONCTION Convert() OUVRE UNE FENETRE AVEC FORMULAIRE
*******************************************************************************/
void Fconvert()
{
	_winForm(FCNV,glb.rsc.head.frstr[TWCNV],glb.rsc.head.frstr[TSCNV],ICONE,ICNCNV,0,0);
}

void Fmodule()
{
	_winForm(FMOD,glb.rsc.head.frstr[TWMOD],glb.rsc.head.frstr[TSMOD],-1,WIC_MOD,0,0);
}

void Fmemory()
{
	_initRSC(FMEM,FMEMSYS);
	_initRSC(FMEM,FMEMLEN);
	_initRSC(FMEM,FMEMFRE);
	_winForm(FMEM,glb.rsc.head.frstr[TWMEM],glb.rsc.head.frstr[TSMEM],-1,WIC_MEM,0,0);
}

void Fsystem()
{
	_winForm(FSYS,glb.rsc.head.frstr[TWSYS],glb.rsc.head.frstr[TSSYS],-1,WIC_SYS,0,0);
}


/*******************************************************************************
	FONCTION CHERCHANT L'INDEX DE TABLEAU W[] A PARTIR DE L'INDEX img[]
*******************************************************************************/
int findIMG(int index)
{
	int	j;

	for (j=0;j<glb.opt.Win_Num;j++)
		if ( W[j].type==TW_IMG && W[j].id==index )
			return j;
	return -1;
}


/*******************************************************************************
*******************************************************************************/
void updFreeMem()
{
	char	txt[10];

	if (glb.mem.tfre!=tfre && !glb.div.slide)
	{
		wind_update(BEG_UPDATE);
		sprintf(txt,"%7lik",glb.mem.tfre/1024L);
		_obPutStr(glb.rsc.head.trindex[MENU],MFRE,txt);
		tfre=glb.mem.tfre;
		_menuBar(glb.aes.tree.menu,FALSE);
		_menuBar(glb.aes.tree.menu,TRUE);
		wind_update(END_UPDATE);
	}
}


/*******************************************************************************
*******************************************************************************/
int isIMG()
{
	int	i;

	for (i=0;i<glb.opt.Win_Num;i++)
		if (img[i].flag)
			return TRUE;
	return FALSE;
}


/*******************************************************************************
*******************************************************************************/
void quit()
{
	int	i,ok=0;

	menuOff();

	for (i=0;i<glb.opt.Win_Num;i++)
		if (W[i].type==TW_IMG)
		{
			_winClose(i);
			_clearAesBuffer();
		}

	if (isIMG())
	{
		if (form_alert(2,glb.rsc.head.frstr[QUIT])==2)
			ok=1;
	}

	if (!ok)
		glb.div.Exit=1;

	menuOn();
}
