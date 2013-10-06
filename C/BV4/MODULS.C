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
	FONCTIONS
*******************************************************************************/
static void	_setmodRim(void);
static void	_setmodWim(void);
static void	_setmodIfx(void);

/*******************************************************************************
	Initialise et ouvre la fenˆtre de configuration des modules
*******************************************************************************/
void _setModule()
{
	OBJECT	*tree=glb.rsc.head.trindex[FME];

	if (glb.parx.setmod==-1)
	{
		_initPopUp(tree,FMEMOD,PME1,0,POP_LEFT,POP_VALUE,TRUE);
		_initPopUp(tree,FMETYP,PME2,0,POP_LEFT,POP_VALUE,TRUE);
		glb.parx.setmod=0;
		_setmodparam();
	}
	tree[FMEMOD].ob_state&=~DISABLED;
	tree[FMETYP].ob_state&=~DISABLED;
	_winForm(FME,glb.rsc.head.frstr[WME],"",-1,WIC_MOD,0,W_MODAL);
}


/*******************************************************************************
	Initialise la fenˆtre de configuration des modules
*******************************************************************************/
void _setmodparam()
{
	OBJECT	*tree=glb.rsc.head.trindex[FME];

	switch (_getPopUp(tree,FMEMOD))
	{
		case	0:
			_setmodRim();
			break;
		case	1:
			_setmodWim();
			break;
		case	2:
			_setmodIfx();
			break;
	}
	_drawMod();

	tree[FMEDEL].ob_state|=DISABLED;
	tree[FMEINF].ob_state|=DISABLED;
	tree[FMESET].ob_state|=DISABLED;
}
static void _setmodRim()
{
	MODSTR	*str;
	PARX_RIM	*rim;
	OBJECT	*tree=glb.rsc.head.trindex[FME];
	int		i,n;

	if (glb.parx.strin!=NO_MEMORY)
	{
		_mFree(glb.parx.strin);
		glb.parx.strin=NO_MEMORY;
		glb.parx.strnmb=0;
	}
	for (i=0;i<glb.parx.n_rim;i++)
	{
		rim=_rimAdr(i);
		switch (1+_getPopUp(tree,FMETYP))
		{
			case	PME2TOT:
				if (rim->type==RIM_TOT)
					glb.parx.strnmb+=1;
				break;
			case	PME2PAR:
				if (rim->type==RIM_PAR)
					glb.parx.strnmb+=1;
				break;
			case	PME2GEN:
				if (rim->type==RIM_DGN || rim->type==RIM_GEN)
					glb.parx.strnmb+=1;
				break;
			case	PME2ANI:
				if (rim->type==RIM_ANI)
					glb.parx.strnmb+=1;
				break;
			case	PME2ALL:
				glb.parx.strnmb+=1;
				break;
		}
	}
	if (glb.parx.strnmb)
	{
		glb.parx.strin=_mAlloc((long)glb.parx.strnmb*sizeof(MODSTR),0);

		if (glb.parx.strin!=NO_MEMORY)
		{
			str=(MODSTR *)glb.mem.adr[glb.parx.strin];
			n=0;
			for (i=0;i<glb.parx.n_rim;i++)
			{
				rim=_rimAdr(i);
				switch (1+_getPopUp(tree,FMETYP))
				{
					case	PME2TOT:
						if (rim->type==RIM_TOT)
						{
							str[n].n=i;
							memcpy((void *)str[n].name,(void *)rim->name,32L);
							n+=1;
						}
						break;
					case	PME2PAR:
						if (rim->type==RIM_PAR)
						{
							str[n].n=i;
							memcpy((void *)str[n].name,(void *)rim->name,32L);
							n+=1;
						}
						break;
					case	PME2GEN:
						if (rim->type==RIM_DGN || rim->type==RIM_GEN)
						{
							str[n].n=i;
							memcpy((void *)str[n].name,(void *)rim->name,32L);
							n+=1;
						}
						break;
					case	PME2ANI:
						if (rim->type==RIM_ANI)
						{
							str[n].n=i;
							memcpy((void *)str[n].name,(void *)rim->name,32L);
							n+=1;
						}
						break;
					case	PME2ALL:
						str[n].n=i;
						memcpy((void *)str[n].name,(void *)rim->name,32L);
						n+=1;
						break;
				}
			}

		}
	}

	if (!glb.parx.strnmb)
	{
		for (i=0;i<10;i++)
		{
			tree[FMET+i].ob_flags&=~SELECTABLE;
			_obPutStr(tree,FMET+i,"");
		}
		tree[FMEF2].ob_height=tree[FMEF1].ob_height;
		tree[FMEF2].ob_y=0;
		tree[FMEUP].ob_flags&=~TOUCHEXIT;
		tree[FMEDN].ob_flags&=~TOUCHEXIT;
		tree[FMEF1].ob_flags&=~TOUCHEXIT;
		tree[FMEF2].ob_flags&=~TOUCHEXIT;
	}
}
static void _setmodWim()
{
	MODSTR	*str;
	PARX_WIM	*wim;
	OBJECT	*tree=glb.rsc.head.trindex[FME];
	int		i,n;

	if (glb.parx.strin!=NO_MEMORY)
	{
		_mFree(glb.parx.strin);
		glb.parx.strin=NO_MEMORY;
		glb.parx.strnmb=0;
	}

	for (i=0;i<glb.parx.n_wim;i++)
	{
		wim=_wimAdr(i);
		switch (1+_getPopUp(tree,FMETYP))
		{
			case	PME3NOR:
				if (wim->type==WIM_SAVE)
					glb.parx.strnmb+=1;
				break;
			case	PME3GEN:
				if (wim->type==WIM_GEN)
					glb.parx.strnmb+=1;
				break;
			case	PME3ANI:
				if (wim->type==WIM_ANI)
					glb.parx.strnmb+=1;
				break;
			case	PME3ALL:
				glb.parx.strnmb+=1;
				break;
		}
	}
	if (glb.parx.strnmb)
	{
		glb.parx.strin=_mAlloc((long)glb.parx.strnmb*sizeof(MODSTR),0);

		if (glb.parx.strin!=NO_MEMORY)
		{
			str=(MODSTR *)glb.mem.adr[glb.parx.strin];
			n=0;
			for (i=0;i<glb.parx.n_wim;i++)
			{
				wim=_wimAdr(i);
				switch (1+_getPopUp(tree,FMETYP))
				{
					case	PME3NOR:
						if (wim->type==WIM_SAVE)
						{
							str[n].n=i;
							memcpy((void *)str[n].name,(void *)wim->name,32L);
							n+=1;
						}
						break;
					case	PME3GEN:
						if (wim->type==WIM_GEN)
						{
							str[n].n=i;
							memcpy((void *)str[n].name,(void *)wim->name,32L);
							n+=1;
						}
						break;
					case	PME3ANI:
						if (wim->type==WIM_ANI)
						{
							str[n].n=i;
							memcpy((void *)str[n].name,(void *)wim->name,32L);
							n+=1;
						}
						break;
					case	PME3ALL:
						str[n].n=i;
						memcpy((void *)str[n].name,(void *)wim->name,32L);
						n+=1;
						break;
				}
			}

		}
	}

	if (!glb.parx.strnmb)
	{
		for (i=0;i<10;i++)
		{
			tree[FMET+i].ob_flags&=~SELECTABLE;
			_obPutStr(tree,FMET+i,"");
		}
		tree[FMEF2].ob_height=tree[FMEF1].ob_height;
		tree[FMEF2].ob_y=0;
		tree[FMEUP].ob_flags&=~TOUCHEXIT;
		tree[FMEDN].ob_flags&=~TOUCHEXIT;
		tree[FMEF1].ob_flags&=~TOUCHEXIT;
		tree[FMEF2].ob_flags&=~TOUCHEXIT;
	}
}
static void _setmodIfx()
{
	MODSTR	*str;
	PARX_IFX	*ifx;
	OBJECT	*tree=glb.rsc.head.trindex[FME];
	int		i,n;

	if (glb.parx.strin!=NO_MEMORY)
	{
		_mFree(glb.parx.strin);
		glb.parx.strin=NO_MEMORY;
		glb.parx.strnmb=0;
	}

	for (i=0;i<glb.parx.n_ifx;i++)
	{
		ifx=_ifxAdr(i);
		switch (1+_getPopUp(tree,FMETYP))
		{
			case	PME4ONE:
				if (ifx->type==IFX_ONE)
					glb.parx.strnmb+=1;
				break;
			case	PME4TWO:
				if (ifx->type==IFX_TWO)
					glb.parx.strnmb+=1;
				break;
			case	PME4ALL:
				glb.parx.strnmb+=1;
				break;
		}
	}
	if (glb.parx.strnmb)
	{
		glb.parx.strin=_mAlloc((long)glb.parx.strnmb*sizeof(MODSTR),0);

		if (glb.parx.strin!=NO_MEMORY)
		{
			str=(MODSTR *)glb.mem.adr[glb.parx.strin];
			n=0;
			for (i=0;i<glb.parx.n_ifx;i++)
			{
				ifx=_ifxAdr(i);
				switch (1+_getPopUp(tree,FMETYP))
				{
					case	PME4ONE:
						if (ifx->type==IFX_ONE)
						{
							str[n].n=i;
							memcpy((void *)str[n].name,(void *)ifx->name,32L);
							n+=1;
						}
						break;
					case	PME4TWO:
						if (ifx->type==IFX_TWO)
						{
							str[n].n=i;
							memcpy((void *)str[n].name,(void *)ifx->name,32L);
							n+=1;
						}
						break;
					case	PME4ALL:
						str[n].n=i;
						memcpy((void *)str[n].name,(void *)ifx->name,32L);
						n+=1;
						break;
				}
			}

		}
	}

	if (!glb.parx.strnmb)
	{
		for (i=0;i<10;i++)
		{
			tree[FMET+i].ob_flags&=~SELECTABLE;
			_obPutStr(tree,FMET+i,"");
		}
		tree[FMEF2].ob_height=tree[FMEF1].ob_height;
		tree[FMEF2].ob_y=0;
		tree[FMEUP].ob_flags&=~TOUCHEXIT;
		tree[FMEDN].ob_flags&=~TOUCHEXIT;
		tree[FMEF1].ob_flags&=~TOUCHEXIT;
		tree[FMEF2].ob_flags&=~TOUCHEXIT;
	}
}


/*******************************************************************************
	Initialise et affiche les modules et les ascenseurs
*******************************************************************************/
void _drawMod()
{
	MODSTR	*str;
	OBJECT	*tree=glb.rsc.head.trindex[FME];
	int		i;

	str=(MODSTR *)glb.mem.adr[glb.parx.strin];
	glb.parx.setmod=max(0,min(glb.parx.setmod,glb.parx.strnmb-10));
	for (i=0;i<10;i++)
	{
		if (i+glb.parx.setmod<glb.parx.strnmb)
		{
			_obPutStr(tree,FMET+i,str[i+glb.parx.setmod].name);
			tree[FMET+i].ob_flags|=SELECTABLE;
			if (str[i+glb.parx.setmod].n==glb.parx.d_rim)
			{
				tree[FMET+i].ob_state|=SELECTED;
				glb.parx.setdef=FMET+i;
			}
		}
		else
		{
			_obPutStr(tree,FMET+i,"");
			tree[FMET+i].ob_flags&=~SELECTABLE;
		}
		if (glb.parx.strnmb>10)
		{
			tree[FMEF2].ob_height=(int)((double)10*(double)tree[FMEF1].ob_height/(double)glb.parx.strnmb);
			tree[FMEF2].ob_y=(int)((double)glb.parx.setmod*(double)(tree[FMEF1].ob_height-tree[FMEF2].ob_height)/(double)(glb.parx.strnmb-10));
			tree[FMEUP].ob_flags|=TOUCHEXIT;
			tree[FMEDN].ob_flags|=TOUCHEXIT;
			tree[FMEF1].ob_flags|=TOUCHEXIT;
			tree[FMEF2].ob_flags|=TOUCHEXIT;
		}
		else
		{
			tree[FMEF2].ob_height=tree[FMEF1].ob_height;
			tree[FMEF2].ob_y=0;
			tree[FMEUP].ob_flags&=~TOUCHEXIT;
			tree[FMEDN].ob_flags&=~TOUCHEXIT;
			tree[FMEF1].ob_flags&=~TOUCHEXIT;
			tree[FMEF2].ob_flags&=~TOUCHEXIT;
		}
	}
}


/*******************************************************************************
	Donne les informations d'un module
*******************************************************************************/
void _modInfo(int type,int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FMI];
	PARX_RIM	*rim;
	PARX_WIM	*wim;
	PARX_IFX	*ifx;
	char		txt[10];

	switch (type)
	{
		case	0:
			rim=_rimAdr(n);
			_obPutStr(tree,FMINAME,rim->name);
			sprintf(txt,"%01i.%02i",rim->ver/100,rim->ver%100);
			_obPutStr(tree,FMIVER,txt);
			sprintf(txt,"%4s",(char *)&rim->fmt);
			_obPutStr(tree,FMIFMT,txt);
			memcpy((void *)txt,(void *)rim->id,8L);	txt[8]='\0';
			_obPutStr(tree,FMIID,txt);
			sprintf(txt,"%i",rim->type);
			_obPutStr(tree,FMITYPE,txt);
			_winForm(FMI,glb.rsc.head.frstr[WMIRIM],"",-1,WIC_MOD,0,W_MODAL);
			break;
		case	1:
			wim=_wimAdr(n);
			_obPutStr(tree,FMINAME,wim->name);
			sprintf(txt,"%01i.%02i",wim->ver/100,wim->ver%100);
			_obPutStr(tree,FMIVER,txt);
			sprintf(txt,"%4s",(char *)&wim->fmt);
			_obPutStr(tree,FMIFMT,txt);
			memcpy((void *)txt,(void *)wim->id,8L);	txt[8]='\0';
			_obPutStr(tree,FMIID,txt);
			sprintf(txt,"%i",wim->type);
			_obPutStr(tree,FMITYPE,txt);
			_winForm(FMI,glb.rsc.head.frstr[WMIWIM],"",-1,WIC_MOD,0,W_MODAL);
			break;
		case	2:
			ifx=_ifxAdr(n);
			_obPutStr(tree,FMINAME,ifx->name);
			sprintf(txt,"%01i.%02i",ifx->ver/100,ifx->ver%100);
			_obPutStr(tree,FMIVER,txt);
			sprintf(txt,"%4s",(char *)&ifx->fmt);
			_obPutStr(tree,FMIFMT,txt);
			memcpy((void *)txt,(void *)ifx->id,8L);	txt[8]='\0';
			_obPutStr(tree,FMIID,txt);
			sprintf(txt,"%i",ifx->type);
			_obPutStr(tree,FMITYPE,txt);
			_winForm(FMI,glb.rsc.head.frstr[WMIIFX],"",-1,WIC_MOD,0,W_MODAL);
			break;
	}
}


/*******************************************************************************
	Configure un module
*******************************************************************************/
void _modConfig(int type,int n)
{
	PARX_RIM	*rim;
	PARX_WIM	*wim;
	PARX_IFX	*ifx;
	char		txt[256];

	strcpy(txt,glb.parx.Path);
	switch (type)
	{
		case	0:
			rim=_rimAdr(n);
			(rim->DO_PARAM)(1,(char *)txt);
			break;
		case	1:
			wim=_wimAdr(n);
			(wim->DO_PARAM)(1,(char *)txt);
			break;
		case	2:
			ifx=_ifxAdr(n);
			(ifx->DO_PARAM)(1,(char *)txt);
			break;
	}
}


/*******************************************************************************
	Efface de la m‚moire un module
*******************************************************************************/
void _modDelete(int type,int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FMOD];
	int		obx,oby,obw,obh;

	switch (type)
	{
		case	0:
			_delRim(n);
			wind_update(BEG_MCTRL);
			_initRSC(FMOD,FMODT1);
			_initRSC(FMOD,FMODP1);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODT1,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODP1,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	1:
			_delWim(n);
			wind_update(BEG_MCTRL);
			_initRSC(FMOD,FMODT2);
			_initRSC(FMOD,FMODP2);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODT2,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODP2,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	2:
			_delIfx(n);
			wind_update(BEG_MCTRL);
			_initRSC(FMOD,FMODT4);
			_initRSC(FMOD,FMODP4);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODT4,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODP4,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
	}
}


/*******************************************************************************
	Charge de nouveaux modules
*******************************************************************************/
void _modAdd(int type)
{
	OBJECT	*tree=glb.rsc.head.trindex[FMOD];
	int		obx,oby,obw,obh;

	switch (type)
	{
		case	0:
			if (glb.parx.Mask&P_RIM)
				strcpy(glb.div.pname,glb.parx.Path);
			else
				strcpy(glb.div.pname,glb.opt.APP_Path);
			strcat(glb.div.pname,"RIM\\");
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.fname,"");
			strcpy(glb.div.ext,"*.RI?");
			_prog(glb.rsc.head.frstr[INIT12],"");
			_progOn();
			_multifsel(glb.div.pfname,glb.div.pname,glb.div.fname,glb.div.ext,glb.rsc.head.frstr[FMERIM],_addRim);
			_progOff();
			wind_update(BEG_MCTRL);
			_initRSC(FMOD,FMODT1);
			_initRSC(FMOD,FMODP1);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODT1,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODP1,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	1:
			if (glb.parx.Mask&P_WIM)
				strcpy(glb.div.pname,glb.parx.Path);
			else
				strcpy(glb.div.pname,glb.opt.APP_Path);
			strcat(glb.div.pname,"WIM\\");
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.fname,"");
			strcpy(glb.div.ext,"*.WI?");
			_prog(glb.rsc.head.frstr[INIT13],"");
			_progOn();
			_multifsel(glb.div.pfname,glb.div.pname,glb.div.fname,glb.div.ext,glb.rsc.head.frstr[FMEWIM],_addWim);
			_progOff();
			wind_update(BEG_MCTRL);
			_initRSC(FMOD,FMODT2);
			_initRSC(FMOD,FMODP2);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODT2,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODP2,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	2:
			if (glb.parx.Mask&P_IFX)
				strcpy(glb.div.pname,glb.parx.Path);
			else
				strcpy(glb.div.pname,glb.opt.APP_Path);
			strcat(glb.div.pname,"IFX\\");
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.fname,"");
			strcpy(glb.div.ext,"*.IF?");
			_prog(glb.rsc.head.frstr[INIT14],"");
			_progOn();
			_multifsel(glb.div.pfname,glb.div.pname,glb.div.fname,glb.div.ext,glb.rsc.head.frstr[FMEIFX],_addIfx);
			_progOff();
			wind_update(BEG_MCTRL);
			_initRSC(FMOD,FMODT4);
			_initRSC(FMOD,FMODP4);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODT4,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODP4,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
	}
}


/*******************************************************************************
	Change le module par d‚faut
*******************************************************************************/
void _modDefault(int type,int n)
{
	PARX_RIM	*rim;
	PARX_WIM	*wim;
	PARX_IFX	*ifx;
	OBJECT	*tree=glb.rsc.head.trindex[FMOD];
	int		obx,oby,obw,obh;

	switch (type)
	{
		case	0:
			rim=_rimAdr(n);
			strncpy(glb.parx.def_rim,rim->id,8L);
			wind_update(BEG_MCTRL);
			_initRSC(FMOD,FMODD1);
			_initRSC(FMOD,FMODP1);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODD1,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	1:
			wim=_wimAdr(n);
			strncpy(glb.parx.def_wim,wim->id,8L);
			wind_update(BEG_MCTRL);
			_initRSC(FMOD,FMODD2);
			_initRSC(FMOD,FMODP2);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODD2,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	2:
			ifx=_ifxAdr(n);
			strncpy(glb.parx.def_ifx,ifx->id,8L);
			wind_update(BEG_MCTRL);
			_initRSC(FMOD,FMODD4);
			_initRSC(FMOD,FMODP4);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODD4,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
	}
}

int cdecl _addRim(char *name)
{
	PARX_RIM	*rim;
	PARX_RIM	*tst;
	char		*p;
	long		af=0,lf,ret;
	int		ha,i,in,ok=1;

	ha=(int)Fopen(name,FO_READ);

	if (ha>0)
	{
		p=strrchr(name,'\\');
		if (!p)
			p=name;
		else
			p++;
		_prog("@",p);

		lf=Fseek(0L,ha,2);
		Fseek(0L,ha,0);
		in=_mAlloc(lf,0);
		rim=(PARX_RIM *)glb.mem.adr[in];
		if (Fread(ha,lf,(void *)glb.mem.adr[in])==lf && !strncmp(rim->head,"READ_IMG",8L))
		{	
			for (i=0;i<glb.parx.n_rim;i++)
			{
				tst=_rimAdr(i);
				if (!strncmp(rim->id,tst->id,8L))
					if (rim->ver>tst->ver)
					{
						_delRim(i);
						i=glb.parx.n_rim+1;
					}
					else
						ok=0;
			}

			if (lf&1)
				lf+=1;
			*(long *)glb.mem.adr[in]=lf;

			if (ok)
			{
				if (glb.parx.n_rim)
				{
					lf+=glb.mem.len[glb.parx.i_rim];
					ret=_mDim(glb.parx.i_rim,lf,0,-1L);
					if (ret==lf)
						af=glb.mem.adr[glb.parx.i_rim]+glb.mem.len[glb.parx.i_rim]-glb.mem.len[in];
				}
				else
				{
#ifdef FORCE_MALLOC
					glb.parx.i_rim=_mAllocForce(MEM_RIM,glb.mem.len[in],0);
#else
					glb.parx.i_rim=_mAlloc(glb.mem.len[in],0);
#endif
					if (glb.parx.i_rim!=NO_MEMORY)
						af=glb.mem.adr[glb.parx.i_rim];
				}
			}

			if (af)
			{
				memcpy((void *)af,(void *)glb.mem.adr[in],glb.mem.len[in]);
				glb.parx.n_rim+=1;

				af=0;
				if (glb.parx.p_rim!=NO_MEMORY)
				{
					lf=glb.mem.len[glb.parx.p_rim]+38L;
					ret=_mDim(glb.parx.p_rim,lf,0,-1L);
					if (ret!=lf)
						_mFree(glb.parx.p_rim);
					else
						af=glb.mem.adr[glb.parx.p_rim]+glb.mem.len[glb.parx.p_rim]-38L;
				}
				else if (glb.parx.n_rim==1)
				{
					glb.parx.p_rim=_mAlloc(38L,0);
					if (glb.parx.p_rim!=NO_MEMORY)
						af=glb.mem.adr[glb.parx.p_rim];
				}

				if (af)
				{
					p=(char *)af;
					rim=_rimAdr(glb.parx.n_rim-1);
					sprintf(p,"%+30s v%01i.%02i",rim->name,rim->ver/100,rim->ver%100);

sprintf(glb.div.log,"AddRim: %s\n",p);
_reportLog(LOG_RIM);

				}

			}
		}
		_mFree(in);
		Fclose(ha);
	}
	return 1;
}
void _delRim(int i)
{
	long		lrim,arim;

	if (i>=0 && i<glb.parx.n_rim)
	{
sprintf(glb.div.log,"DelRim: %i\n",i);
_reportLog(LOG_RIM);
		if (glb.parx.n_rim==1)
		{
			_mFree(glb.parx.i_rim);
			glb.parx.i_rim=NO_MEMORY;
			_mFree(glb.parx.p_rim);
			glb.parx.p_rim=NO_MEMORY;
			glb.parx.n_rim=0;
		}
		else
		{
			_mDim(glb.parx.p_rim,glb.mem.len[glb.parx.p_rim]-38L,0,(long)i*38L);
			arim=(long)_rimAdr(i);
			lrim=*(long *)arim;
			_mDim(glb.parx.i_rim,glb.mem.len[glb.parx.i_rim]-lrim,0,arim-glb.mem.adr[glb.parx.i_rim]);
			glb.parx.n_rim-=1;
		}
	}
}

int cdecl _addWim(char *name)
{
	PARX_WIM	*wim;
	PARX_WIM	*tst;
	char		*p;
	long		af=0,lf,ret;
	int		ha,i,in,ok=1;

	ha=(int)Fopen(name,FO_READ);

	if (ha>0)
	{
		p=strrchr(name,'\\');
		if (!p)
			p=name;
		else
			p++;
		_prog("@",p);

		lf=Fseek(0L,ha,2);
		Fseek(0L,ha,0);
		in=_mAlloc(lf,0);

		wim=(PARX_WIM *)glb.mem.adr[in];
		if (Fread(ha,lf,(void *)glb.mem.adr[in])==lf && !strncmp(wim->head,"WRIT_IMG",8L))
		{	
			for (i=0;i<glb.parx.n_wim;i++)
			{
				tst=_wimAdr(i);
				if (!strncmp(wim->id,tst->id,8L))
					if (wim->ver>tst->ver)
					{
						_delWim(i);
						i=glb.parx.n_wim+1;
					}
					else
						ok=0;
			}

			if (lf&1)
				lf+=1;
			*(long *)glb.mem.adr[in]=lf;

			if (ok)
			{
				if (glb.parx.n_wim)
				{
					lf+=glb.mem.len[glb.parx.i_wim];
					ret=_mDim(glb.parx.i_wim,lf,0,-1L);
					if (ret==lf)
						af=glb.mem.adr[glb.parx.i_wim]+glb.mem.len[glb.parx.i_wim]-glb.mem.len[in];
				}
				else
				{
#ifdef FORCE_MALLOC
					glb.parx.i_wim=_mAllocForce(MEM_WIM,glb.mem.len[in],0);
#else
					glb.parx.i_wim=_mAlloc(glb.mem.len[in],0);
#endif
					if (glb.parx.i_wim!=NO_MEMORY)
						af=glb.mem.adr[glb.parx.i_wim];
				}
			}

			if (af)
			{
				memcpy((void *)af,(void *)glb.mem.adr[in],glb.mem.len[in]);
				glb.parx.n_wim+=1;

				af=0;
				if (glb.parx.p_wim!=NO_MEMORY)
				{
					lf=glb.mem.len[glb.parx.p_wim]+38L;
					ret=_mDim(glb.parx.p_wim,lf,0,-1L);
					if (ret!=lf)
						_mFree(glb.parx.p_wim);
					else
						af=glb.mem.adr[glb.parx.p_wim]+glb.mem.len[glb.parx.p_wim]-38L;
				}
				else if (glb.parx.n_wim==1)
				{
					glb.parx.p_wim=_mAlloc(38L,0);
					if (glb.parx.p_wim!=NO_MEMORY)
						af=glb.mem.adr[glb.parx.p_wim];
				}

				if (af)
				{
					p=(char *)af;
					wim=_wimAdr(glb.parx.n_wim-1);
					sprintf(p,"%+30s v%01i.%02i",wim->name,wim->ver/100,wim->ver%100);

sprintf(glb.div.log,"AddWim: %s\n",p);
_reportLog(LOG_WIM);

				}

			}
		}
		_mFree(in);
		Fclose(ha);
	}
	return 1;
}
void _delWim(int i)
{
	long		lwim,awim;

	if (i>=0 && i<glb.parx.n_wim)
	{
sprintf(glb.div.log,"DelWim: %i\n",i);
_reportLog(LOG_WIM);
		if (glb.parx.n_wim==1)
		{
			_mFree(glb.parx.i_wim);
			glb.parx.i_wim=NO_MEMORY;
			_mFree(glb.parx.p_wim);
			glb.parx.p_wim=NO_MEMORY;
			glb.parx.n_wim=0;
		}
		else
		{
			_mDim(glb.parx.p_wim,glb.mem.len[glb.parx.p_wim]-38L,0,(long)i*38L);
			awim=(long)_wimAdr(i);
			lwim=*(long *)awim;
			_mDim(glb.parx.i_wim,glb.mem.len[glb.parx.i_wim]-lwim,0,awim-glb.mem.adr[glb.parx.i_wim]);
			glb.parx.n_wim-=1;
		}
	}
}

int cdecl _addIfx(char *name)
{
	PARX_IFX	*ifx;
	PARX_IFX	*tst;
	char		*p;
	long		af=0,lf,ret;
	int		ha,i,in,ok=1;

	ha=(int)Fopen(name,FO_READ);

	if (ha>0)
	{
		p=strrchr(name,'\\');
		if (!p)
			p=name;
		else
			p++;
		_prog("@",p);

		lf=Fseek(0L,ha,2);
		Fseek(0L,ha,0);
		in=_mAlloc(lf,0);

		ifx=(PARX_IFX *)glb.mem.adr[in];
		if (Fread(ha,lf,(void *)glb.mem.adr[in])==lf && !strncmp(ifx->head,"IFX__IMG",8L))
		{	
			for (i=0;i<glb.parx.n_ifx;i++)
			{
				tst=_ifxAdr(i);
				if (!strncmp(ifx->id,tst->id,8L))
					if (ifx->ver>tst->ver)
					{
						_delIfx(i);
						i=glb.parx.n_ifx+1;
					}
					else
						ok=0;
			}

			if (lf&1)
				lf+=1;
			*(long *)glb.mem.adr[in]=lf;

			if (ok)
			{
				if (glb.parx.n_ifx)
				{
					lf+=glb.mem.len[glb.parx.i_ifx];
					ret=_mDim(glb.parx.i_ifx,lf,0,-1L);
					if (ret==lf)
						af=glb.mem.adr[glb.parx.i_ifx]+glb.mem.len[glb.parx.i_ifx]-glb.mem.len[in];
				}
				else
				{
#ifdef FORCE_MALLOC
					glb.parx.i_ifx=_mAllocForce(MEM_IFX,glb.mem.len[in],0);
#else
					glb.parx.i_ifx=_mAlloc(glb.mem.len[in],0);
#endif
					if (glb.parx.i_ifx!=NO_MEMORY)
						af=glb.mem.adr[glb.parx.i_ifx];
				}
			}

			if (af)
			{
				memcpy((void *)af,(void *)glb.mem.adr[in],glb.mem.len[in]);
				glb.parx.n_ifx+=1;

				af=0;
				if (glb.parx.p_ifx!=NO_MEMORY)
				{
					lf=glb.mem.len[glb.parx.p_ifx]+38L;
					ret=_mDim(glb.parx.p_ifx,lf,0,-1L);
					if (ret!=lf)
						_mFree(glb.parx.p_ifx);
					else
						af=glb.mem.adr[glb.parx.p_ifx]+glb.mem.len[glb.parx.p_ifx]-38L;
				}
				else if (glb.parx.n_ifx==1)
				{
					glb.parx.p_ifx=_mAlloc(38L,0);
					if (glb.parx.p_ifx!=NO_MEMORY)
						af=glb.mem.adr[glb.parx.p_ifx];
				}

				if (af)
				{
					p=(char *)af;
					ifx=_ifxAdr(glb.parx.n_ifx-1);
					sprintf(p,"%+30s v%01i.%02i",ifx->name,ifx->ver/100,ifx->ver%100);

sprintf(glb.div.log,"AddIfx: %s\n",p);
_reportLog(LOG_IFX);

				}

			}
		}
		_mFree(in);
		Fclose(ha);
	}
	return 1;
}
void _delIfx(int i)
{
	long		lifx,aifx;

	if (i>=0 && i<glb.parx.n_ifx)
	{
sprintf(glb.div.log,"DelIfx: %i\n",i);
_reportLog(LOG_IFX);

		if (glb.parx.n_ifx==1)
		{
			_mFree(glb.parx.i_ifx);
			glb.parx.i_ifx=NO_MEMORY;
			_mFree(glb.parx.p_ifx);
			glb.parx.p_ifx=NO_MEMORY;
			glb.parx.n_ifx=0;
		}
		else
		{
			_mDim(glb.parx.p_ifx,glb.mem.len[glb.parx.p_ifx]-38L,0,(long)i*38L);
			aifx=(long)_ifxAdr(i);
			lifx=*(long *)aifx;
			_mDim(glb.parx.i_ifx,glb.mem.len[glb.parx.i_ifx]-lifx,0,aifx-glb.mem.adr[glb.parx.i_ifx]);
			glb.parx.n_ifx-=1;
		}
	}
}
