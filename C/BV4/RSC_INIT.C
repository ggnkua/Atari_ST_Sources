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

static void	_initModules(int n);
static void	_initOptions(int n);
static void	_initInterface(int n);
static void _initPint3(int n);
static void	_initMemoire(int n);
static void	_initSMemoire(int n);
static void	_initSysteme(int n);
static void	_initPrt(int n);
static void	_initRim(int n);
static void	_initInfo(int n);
static void	_initOptionsEg(int n);
static void	_initLog(int n);
static void	_initSel(int n);
static void	_initSlide(int n);
static void	_initCnv(int n);
static void	_initTrm(int n);
static void	_initZoom(int n);
static void	_initDebug(int n);

/*******************************************************************************
*******************************************************************************/
void _initRSC(int obj,int n)
{
	switch (obj)
	{
		case	FMOD:		_initModules(n);		break;
		case	FOPT:		_initOptions(n);		break;
		case	FINT:		_initInterface(n);	break;
		case	PINT3:	_initPint3(n);			break;
		case	FMEM:		_initMemoire(n);		break;
		case	FSMEM:	_initSMemoire(n);		break;
		case	FSYS:		_initSysteme(n);		break;
		case	FPRT:		_initPrt(n);			break;
		case	FRIM:		_initRim(n);			break;
		case	FINFO:	_initInfo(n);			break;
		case	FLOG:		_initLog(n);			break;
		case	FSEL:		_initSel(n);			break;
		case	FSLIDE:	_initSlide(n);			break;
		case	FCNV:		_initCnv(n);			break;
		case	FTRM:		_initTrm(n);			break;
		case	FZOOM:	_initZoom(n);			break;
		case	FDEBUG:	_initDebug(n);			break;
	}
}
static void _initModules(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FMOD];
	PARX_RIM	*rim;
	PARX_WIM	*wim;
	PARX_IFX	*ifx;
	PARX_TRM	*trm;
	PARX_BRO	*bro;
	PARX_MOT	*mot;
	PARX_PAL	*pal;
	char		txt[14];
	int		m;

	strcpy(txt,"");
	switch (n)
	{
		case	FMODP:
			_putPath(tree,n,25,glb.parx.Path);
			break;
		case	FMODX1:
			if (glb.parx.Active & P_RIM)
				tree[n].ob_state&=~DISABLED;
			else
				tree[n].ob_state|=DISABLED;
			if (glb.parx.Mask & P_RIM)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FMODX2:
			if (glb.parx.Active & P_WIM)
				tree[n].ob_state&=~DISABLED;
			else
				tree[n].ob_state|=DISABLED;
			if (glb.parx.Mask & P_WIM)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FMODX4:
			if (glb.parx.Active & P_IFX)
				tree[n].ob_state&=~DISABLED;
			else
				tree[n].ob_state|=DISABLED;
			if (glb.parx.Mask & P_IFX)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FMODX8:
			if (glb.parx.Active & P_TRM)
				tree[n].ob_state&=~DISABLED;
			else
				tree[n].ob_state|=DISABLED;
			if (glb.parx.Mask & P_TRM)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FMODX10:
			if (glb.parx.Active & P_MEM)
				tree[n].ob_state&=~DISABLED;
			else
				tree[n].ob_state|=DISABLED;
			if (glb.parx.Mask & P_MEM)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FMODX20:
			if (glb.parx.Active & P_BRO)
				tree[n].ob_state&=~DISABLED;
			else
				tree[n].ob_state|=DISABLED;
			if (glb.parx.Mask & P_BRO)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FMODX40:
			if (glb.parx.Active & P_MOT)
				tree[n].ob_state&=~DISABLED;
			else
				tree[n].ob_state|=DISABLED;
			if (glb.parx.Mask & P_MOT)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FMODX80:
			if (glb.parx.Active & P_PAL)
				tree[n].ob_state&=~DISABLED;
			else
				tree[n].ob_state|=DISABLED;
			if (glb.parx.Mask & P_PAL)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FMODT1:
			if (glb.parx.n_rim)
				sprintf(txt,"%3lik %3i",glb.mem.len[glb.parx.i_rim]/1024L,glb.parx.n_rim);
			_obPutStr(tree,n,txt);
			break;
		case	FMODD1:
			if (glb.parx.n_rim)
			{
				glb.parx.d_rim=0;
				for (m=0;m<glb.parx.n_rim;m++)
				{
					rim=(PARX_RIM *)_rimAdr(m);
					if (!strncmp(glb.parx.def_rim,rim->id,8L))
						glb.parx.d_rim=m;
				}
				rim=(PARX_RIM *)_rimAdr(glb.parx.d_rim);
				strncpy(glb.parx.def_rim,rim->id,8L);
				_obPutStr(tree,n,rim->name);
			}
			else
			{
				glb.parx.d_rim=-1;
				_obPutStr(tree,n,"");
			}
			break;
		case	FMODP1:
			if (glb.parx.n_rim && glb.parx.p_rim!=NO_MEMORY)
			{
				tree[n].ob_state&=~DISABLED;
				_initXPopUp(tree,n,(char *)(0x7FFF0000L|(long)glb.parx.p_rim),0,glb.parx.n_rim,0,2,36,glb.parx.d_rim);
			}
			else
				tree[n].ob_state|=DISABLED;
			break;
		case	FMODT2:
			if (glb.parx.n_wim)
				sprintf(txt,"%3lik %3i",glb.mem.len[glb.parx.i_wim]/1024L,glb.parx.n_wim);
			_obPutStr(tree,n,txt);
			break;
		case	FMODD2:
			if (glb.parx.n_wim)
			{
				glb.parx.d_wim=0;
				for (m=0;m<glb.parx.n_wim;m++)
				{
					wim=(PARX_WIM *)_wimAdr(m);
					if (!strncmp(glb.parx.def_wim,wim->id,8L))
						glb.parx.d_wim=m;
				}
				wim=(PARX_WIM *)_wimAdr(glb.parx.d_wim);
				strncpy(glb.parx.def_wim,wim->id,8L);
				_obPutStr(tree,n,wim->name);
			}
			else
			{
				glb.parx.d_wim=-1;
				_obPutStr(tree,n,"");
			}
			break;
		case	FMODP2:
			if (glb.parx.n_wim && glb.parx.p_wim!=NO_MEMORY)
			{
				tree[n].ob_state&=~DISABLED;
				_initXPopUp(tree,n,(char *)(0x7FFF0000L|(long)glb.parx.p_wim),0,glb.parx.n_wim,0,2,36,0);
			}
			else
				tree[n].ob_state|=DISABLED;
			break;
		case	FMODT4:
			if (glb.parx.n_ifx)
				sprintf(txt,"%3lik %3i",glb.mem.len[glb.parx.i_ifx]/1024L,glb.parx.n_ifx);
			_obPutStr(tree,n,txt);
			break;
		case	FMODD4:
			if (glb.parx.n_ifx)
			{
				glb.parx.d_ifx=0;
				for (m=0;m<glb.parx.n_ifx;m++)
				{
					ifx=(PARX_IFX *)_ifxAdr(m);
					if (!strncmp(glb.parx.def_ifx,ifx->id,8L))
						glb.parx.d_ifx=m;
				}
				ifx=(PARX_IFX *)_ifxAdr(glb.parx.d_ifx);
				strncpy(glb.parx.def_ifx,ifx->id,8L);
				_obPutStr(tree,n,ifx->name);
			}
			else
			{
				glb.parx.d_ifx=-1;
				_obPutStr(tree,n,"");
			}
			break;
		case	FMODP4:
			if (glb.parx.n_ifx && glb.parx.p_ifx!=NO_MEMORY)
			{
				tree[n].ob_state&=~DISABLED;
				_initXPopUp(tree,n,(char *)(0x7FFF0000L|(long)glb.parx.p_ifx),0,glb.parx.n_ifx,0,2,36,0);
			}
			else
				tree[n].ob_state|=DISABLED;
			break;
		case	FMODT8:
			if (glb.parx.i_trm!=NO_MEMORY)
			{
				trm=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
				sprintf(txt,"%3lik v%1i.%02i",glb.mem.len[glb.parx.i_trm]/1024L,trm->ver/100,trm->ver%100);
			}
			_obPutStr(tree,n,txt);
			break;
		case	FMODD8:
			if (glb.parx.i_trm!=NO_MEMORY)
			{
				trm=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];

				if (glb.parx.d_trm<1 || glb.parx.d_trm>trm->nmb)
					glb.parx.d_trm=min(5,trm->nmb);

				_obPutStr(tree,n,(char *)(  glb.mem.adr[glb.parx.i_trm]+sizeof(PARX_TRM)+(long)(glb.parx.d_trm-1)*32L ) );
			}
			else
				_obPutStr(tree,n,"");
			break;
		case	FMODP8:
			if (glb.parx.i_trm!=NO_MEMORY)
			{
				trm=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
				tree[n].ob_state&=~DISABLED;
				_initXPopUp(tree,n,(char *)(0x7FFF0000L|(long)glb.parx.p_trm),0L,trm->nmb,0,2,30,0);
			}
			else
				tree[n].ob_state|=DISABLED;
			break;
		case	FMODT10:
			m=(int)(*manag_version)();
			sprintf(txt,"     v%1i.%02i",m/100,m%100);
			_obPutStr(tree,n,txt);
			break;
		case	FMODT20:
			if (glb.parx.i_bro!=NO_MEMORY)
			{
				bro=(PARX_BRO *)glb.mem.adr[glb.parx.i_bro];
				sprintf(txt,"%3lik v%1i.%02i",glb.mem.len[glb.parx.i_bro]/1024L,bro->ver/100,bro->ver%100);
			}
			_obPutStr(tree,n,txt);
			break;
		case	FMODT40:
			if (glb.parx.i_mot!=NO_MEMORY)
			{
				mot=(PARX_MOT *)glb.mem.adr[glb.parx.i_mot];
				sprintf(txt,"%3lik v%1i.%02i",glb.mem.len[glb.parx.i_mot]/1024L,mot->ver/100,mot->ver%100);
			}
			_obPutStr(tree,n,txt);
			break;
		case	FMODT80:
			if (glb.parx.i_pal!=NO_MEMORY)
			{
				pal=(PARX_PAL *)glb.mem.adr[glb.parx.i_pal];
				sprintf(txt,"%3lik v%1i.%02i",glb.mem.len[glb.parx.i_pal]/1024L,pal->ver/100,pal->ver%100);
			}
			_obPutStr(tree,n,txt);
			break;
	}
}
static void _initOptions(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FOPT];

	switch (n)
	{
		case	FOPTEXT:
			if (glb.opt.useExt)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTPAT:
			if (glb.opt.usePat)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTMAJ:
			if (glb.opt.MAJ)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTGFX:
			if (glb.opt.gfx)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTICN:
			if (glb.opt.zap)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTPAL:
			if (glb.opt.pal)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTTRM:
			_initPopUp(tree,n,POPT1,glb.opt.trm,POP_LEFT,POP_VALUE,TRUE);
			break;
		case	FOPTSAV:
			if (glb.opt.Save_Config)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTDSK:
			if (glb.opt.deskfull)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FOPTNUM:
			_initNum(tree,n,5,99,1,glb.opt.Win_Num);
			break;
	}
}
static void _initInterface(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FINT];
	OBJECT	*desk;
	bfobspec	*color;

	switch (n)
	{
		case	FINTPOP:
			if (glb.opt.Flash_PopUp)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FINTCTR:
			_initPopUp(tree,n,PINT1,glb.opt.Mouse_Form,POP_LEFT,POP_VALUE,TRUE);
			break;
		case	FINTCLS:
			_initPopUp(tree,n,PINT2,glb.opt.win,POP_LEFT,POP_VALUE,TRUE);
			break;
		case	FINTLNG:
			_initPopUp(tree,n,PINT3,glb.opt.Language,POP_LEFT,POP_VALUE,TRUE);
			break;
		case	FINTOTO:
			if (glb.opt.Auto_Icon)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FINTICNW:
			_initPopUp(tree,n,PINT4,glb.opt.Rev_Verti,POP_LEFT,POP_VALUE,TRUE);
			break;
		case	FINTICNH:
			_initPopUp(tree,n,PINT5,glb.opt.Rev_Horiz,POP_LEFT,POP_VALUE,TRUE);
			break;
		case	FINTSWP:
			_putPath(tree,n,29,glb.div.SWP_Path);
			break;
		case	FINTCOL|FLAGS15:
			if (glb.aes.tree.desk!=-1)
			{
				desk=glb.rsc.head.trindex[glb.aes.tree.desk];
				if (glb.vdi.extnd[4]==1)
				{
					_obPutStr(tree,n&~FLAGS15,"");
					tree[n&~FLAGS15].ob_state|=DISABLED;
					color=(bfobspec *)&(desk->ob_spec.obspec);
					color->interiorcol=1;
					form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,glb.aes.desk.h);
				}
				else if (glb.vdi.extnd[4]==2)
				{
					_initPopUp(tree,n&~FLAGS15,PCOL2,glb.aes.desk.color2,POP_LEFT,POP_VALUE,TRUE);
					color=(bfobspec *)&(desk->ob_spec.obspec);
					color->interiorcol=glb.aes.desk.color2;
					form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,glb.aes.desk.h);
				}
				else if (glb.vdi.extnd[4]>=4)
				{
					_initPopUp(tree,n&~FLAGS15,PCOL4,glb.aes.desk.color4,POP_LEFT,POP_VALUE,TRUE);
					color=(bfobspec *)&(desk->ob_spec.obspec);
					color->interiorcol=glb.aes.desk.color4;
					form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,glb.aes.desk.h);
				}
			}
			else
			{
				_obPutStr(tree,n&~FLAGS15,"");
				tree[n&~FLAGS15].ob_state|=DISABLED;
			}
			break;
		case	FINTTRM|FLAGS15:
			if (glb.aes.tree.desk!=-1)
			{
				desk=glb.rsc.head.trindex[glb.aes.tree.desk];
				if (glb.vdi.extnd[4]==1)
				{
					_initPopUp(tree,n&~FLAGS15,PTRM,glb.aes.desk.trame1,POP_LEFT,POP_VALUE,TRUE);
					color=(bfobspec *)&(desk->ob_spec.obspec);
					color->fillpattern=glb.aes.desk.trame1;
				}
				else if (glb.vdi.extnd[4]==2)
				{
					_initPopUp(tree,n&~FLAGS15,PTRM,glb.aes.desk.trame2,POP_LEFT,POP_VALUE,TRUE);
					color=(bfobspec *)&(desk->ob_spec.obspec);
					color->fillpattern=glb.aes.desk.trame2;
				}
				else if (glb.vdi.extnd[4]>=4)
				{
					_initPopUp(tree,n&~FLAGS15,PTRM,glb.aes.desk.trame4,POP_LEFT,POP_VALUE,TRUE);
					color=(bfobspec *)&(desk->ob_spec.obspec);
					color->fillpattern=glb.aes.desk.trame4;
				}
			}
			else
			{
				_obPutStr(tree,n&~FLAGS15,"");
				tree[n&~FLAGS15].ob_state|=DISABLED;
			}
			break;
	}
}
static void _initPint3(n)
{
	OBJECT	*tree=glb.rsc.head.trindex[PINT3];

	switch (n)
	{
		case	PINT3FR:
			if (glb.div.avail_fr)
				tree[n].ob_state&=~DISABLED;
			break;
		case	PINT3UK:
			if (glb.div.avail_uk)
				tree[n].ob_state&=~DISABLED;
			break;
		case	PINT3DE:
			if (glb.div.avail_de)
				tree[n].ob_state&=~DISABLED;
			break;
	}
}
static void _initMemoire(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FMEM];
	long		m;
	char		txt[10];

	switch (n)
	{
		case	FMEMLEN:
			m=glb.mem.tlen/1024L;
			sprintf(txt,"%6li K",m);
			_obPutStr(tree,n,txt);
			break;
		case	FMEMFRE:
			m=(glb.mem.tlen-glb.mem.tfre)/1024L;
			sprintf(txt,"%6li K",m);
			_obPutStr(tree,n,txt);
			break;
		case	FMEMSYS:
			m=_freeRam(glb.mem.type)/1024L;
			sprintf(txt,"%6li K",m);
			_obPutStr(tree,n,txt);
			break;
		case	FMEMINI:
			_initNum(tree,n,5,99,1,glb.opt.Mem_Boot);
			break;
	}
}
static void _initSMemoire(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FSMEM];
	long		m;
	char		txt[10];

	switch (n)
	{
		case	FSMEMLEN:
			m=glb.mem.tlen/1024L;
			sprintf(txt,"%6li",m);
			_obPutStr(tree,n,txt);
			break;
		case	FSMEMFRE:
			m=(glb.mem.tlen-glb.mem.tfre)/1024L;
			sprintf(txt,"%6li K",m);
			_obPutStr(tree,n,txt);
			break;
		case	FSMEMSYS:
			m=_freeRam(glb.mem.type)/1024L;
			sprintf(txt,"%6li K",m);
			_obPutStr(tree,n,txt);
			break;
	}
}
static void _initSysteme(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FSYS];
	char		txt[30];
	int		dum;

	switch (n)
	{
		case	FSYSMCH:
			switch (glb.div.MCH)
			{
				case	0:		_obPutStr(tree,n,"ST");				break;
				case	1:		_obPutStr(tree,n,"STE");			break;
				case	2:		_obPutStr(tree,n,"MegaSTE");		break;
				case	3:		_obPutStr(tree,n,"TT");				break;
				case	4:		_obPutStr(tree,n,"Falcon030");	break;
				default:		_obPutStr(tree,n,"???");			break;
			}
			break;
		case	FSYSPROC:
			sprintf(txt,"%li",68000L+_cookie('_CPU'));
			switch ((int)_cookie('_FPU'))
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
			if (glb.vdi.extnd[5])
				sprintf(txt,"%lix%lix%lic",(long)(1+glb.vdi.wscr),(long)(1+glb.vdi.hscr),1L<<min(24,glb.vdi.extnd[4]));
			else
				sprintf(txt,"%lix%li TRUE COLOR",(long)(1+glb.vdi.wscr),(long)(1+glb.vdi.hscr));
			_obPutStr(tree,n,txt);
			break;
		case	FSYSTOS:
			sprintf(txt,"%x.%02x",glb.div.TOS>>8,glb.div.TOS&0xFF);
			_obPutStr(tree,n,txt);
			break;
		case	FSYSGDOS:
			switch (glb.vdi.gdos)
			{
				case	0:		strcpy(txt,glb.rsc.head.frstr[NON]);	break;
				case	1:		strcpy(txt,glb.rsc.head.frstr[OUI]);	break;
				case	2:		strcpy(txt,"Font");		break;
				case	3:		strcpy(txt,"FSM");		break;
				case	4:		strcpy(txt,"Speedo");	break;
				default:		strcpy(txt,"???");		break;
			}
			_obPutStr(tree,n,txt);
			break;
		case	FSYSAES:
			sprintf(txt,"%x.%02x",glb.aes.ver>>8,glb.aes.ver&0xFF);
			_obPutStr(tree,n,txt);
			break;
		case	FSYSMINT:
			dum=(int)_cookie('MiNT');
			if (dum==0)
				strcpy(txt,glb.rsc.head.frstr[NON]);
			else
				sprintf(txt,"%x.%02i",dum>>8,dum&0xFF);
			_obPutStr(tree,n,txt);
			break;
	}
}
static void _initPrt(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FPRT];

	switch (n)
	{
		case	FPRTMAX:
			if (glb.print.max)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FPRTOUT:
			if (glb.print.out)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FPRTH1:
			if (glb.print.xcenter==0)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FPRTH2:
			if (glb.print.xcenter==1)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FPRTH3:
			if (glb.print.xcenter==2)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FPRTV1:
			if (glb.print.ycenter==0)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FPRTV2:
			if (glb.print.ycenter==1)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FPRTV3:
			if (glb.print.ycenter==2)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
	}
}
static void _initRim(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FRIM];
	char		tx[6];
	int		x,y;

	switch (n)
	{
		case	FRIMPOP:
			_initPopUp(tree,FRIMPOP,PRIM,glb.parx.def_dim,POP_LEFT,POP_CENTER,TRUE);
			switch	(1+glb.parx.def_dim)
			{
				case	PRIMSS1:
					x	=	320;		y	=	200;		break;
				case	PRIMSS2:
					x	=	320;		y	=	240;		break;
				case	PRIMSS3:
					x	=	384;		y	=	200;		break;
				case	PRIMSS4:
					x	=	384;		y	=	240;		break;
				case	PRIMDS1:
					x	=	640;		y	=	200;		break;
				case	PRIMDS2:
					x	=	640;		y	=	240;		break;
				case	PRIMDS3:
					x	=	768;		y	=	200;		break;
				case	PRIMDS4:
					x	=	768;		y	=	240;		break;
				case	PRIMSD1:
					x	=	320;		y	=	400;		break;
				case	PRIMSD2:
					x	=	320;		y	=	480;		break;
				case	PRIMSD3:
					x	=	320;		y	=	400;		break;
				case	PRIMSD4:
					x	=	320;		y	=	480;		break;
				case	PRIMDD1:
					x	=	640;		y	=	400;		break;
				case	PRIMDD2:
					x	=	640;		y	=	480;		break;
				case	PRIMDD3:
					x	=	768;		y	=	400;		break;
				case	PRIMDD4:
					x	=	768;		y	=	480;		break;
			}
			glb.parx.def_xdim=x;
			glb.parx.def_ydim=y;
			sprintf(tx,"%i",glb.parx.def_xdim);
			_obPutStr(tree,FRIMW,tx);
			sprintf(tx,"%i",glb.parx.def_ydim);
			_obPutStr(tree,FRIMH,tx);
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _initInfo(int n)
{
	char		txt[30];
	OBJECT	*tree=glb.rsc.head.trindex[FINFO];

	switch	(n)
	{
		case	FINFDAT:
			sprintf(txt,"%s (%s)",RELEASE,__DATE__);
			_obPutStr(tree,n,txt);			/*	date de compilation	*/
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _initLog(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FLOG];

	switch (n)
	{
		case	FLOGINOM:
		case	FLOGIMIMG:
		case	FLOGIMPAL:
		case	FLOGIPAL:
		case	FLOGISIZ:
		case	FLOGFNOM:
		case	FLOGFLEN:
		case	FLOGFPAL:
		case	FLOGFSIZ:
		case	FLOGRIM:
			_obPutStr(tree,n,"");
			break;
		case	FLOGNMB:
			_initNum(tree,n,1,glb.opt.Win_Num,1,Curr+1);
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _initSel(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FSEL];

	switch	(n)
	{
		case	FSELEXTD:
			_obPutStr(tree,n,&glb.opt.ext[0][2]);
			break;
		case	FSELEXT:
		case	FSELEXT+1:
		case	FSELEXT+2:
		case	FSELEXT+3:
		case	FSELEXT+4:
		case	FSELEXT+5:
		case	FSELEXT+6:
		case	FSELEXT+7:
		case	FSELEXT+8:
		case	FSELEXT+9:
			_obPutStr(tree,n,&glb.opt.ext[1+n-FSELEXT][2]);
			break;
		case	FSELPATD:
			_putPath(tree,n,22,glb.opt.pat[0]);
			break;
		case	FSELPAT:
		case	FSELPAT+1:
		case	FSELPAT+2:
		case	FSELPAT+3:
		case	FSELPAT+4:
		case	FSELPAT+5:
		case	FSELPAT+6:
		case	FSELPAT+7:
		case	FSELPAT+8:
		case	FSELPAT+9:
			_putPath(tree,n,32,glb.opt.pat[1+n-FSELPAT]);
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _initSlide(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FSLIDE];

	switch (n)
	{
		case	FSLDPAUSE:
			if (glb.opt.sl_pause)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FSLDBT:
			_initNum(tree,n,1,99,1,glb.opt.sl_ptime);
			break;
		case	FSLDNAME:
			if (glb.opt.sl_info)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FSLDLOOP:
			if (glb.opt.sl_loop)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FSLDLED:
			if (glb.opt.sl_led)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			if (!glb.opt.is_led)
				tree[n].ob_state|=DISABLED;
			break;
		case	FSLDREC:
			if (glb.opt.sl_rec)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FSLDTV:
			if (glb.opt.sl_tv)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			if (!glb.opt.is_tv)
				tree[n].ob_state|=DISABLED;
			break;
		case	FSLDPATH:
			_putPath(tree,n,24,glb.opt.sl_pfname);
			break;
		case	FSLDINC:
			if (glb.opt.sl_zinc)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FSLDDEC:
			if (glb.opt.sl_zdec)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _initCnv(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FCNV];

	switch (n)
	{
		case	FCNVDEL:
			if (glb.opt.cnv_del)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FCNVCOL:
			_initPopUp(tree,n,PCNV,glb.opt.cnv_col-1,POP_LEFT,POP_CENTER,TRUE);
			break;
		case	FCNVSRC:
			_putPath(tree,n,32,glb.opt.cnv_pfname);
			break;
		case	FCNVDST:
			_putPath(tree,n,32,glb.opt.cnv_dst);
			break;
		}
}

/*******************************************************************************
*******************************************************************************/
static void _initTrm(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FTRM];
	PARX_TRM	*trm;

	switch	(n)
	{
		case	FTRMPOP:
			if (glb.parx.i_trm!=NO_MEMORY)
			{
				trm=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
				tree[n].ob_state&=~DISABLED;
				_initXPopUp(tree,FTRMPOP,(char *)(0x7FFF0000L|(long)glb.parx.p_trm),0L,trm->nmb,0,2,30,0);
			}
			else
				tree[n].ob_state|=DISABLED;
			break;
		case	FTRMTXT:
			if (glb.parx.i_trm!=NO_MEMORY)
			{
				trm=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
				if (glb.opt.d_trm<1 || glb.opt.d_trm>trm->nmb)
				{
					if (glb.parx.d_trm<1 || glb.parx.d_trm>trm->nmb)
						glb.opt.d_trm=min(5,trm->nmb);
					else
						glb.opt.d_trm=glb.parx.d_trm;
				}
			_obPutStr(tree,n,(char *)(  glb.mem.adr[glb.parx.i_trm]+sizeof(PARX_TRM)+(long)(glb.opt.d_trm-1)*32L ) );
			}
			else
				_obPutStr(tree,n,"");
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _initZoom(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FZOOM];
	char		txt[30];

	if (working!=-1) switch (n)
	{
		case	FZMSRC:
			sprintf(txt,"%5i x %-5i",img[W[working].id].mfdb.w,img[W[working].id].mfdb.h);
			_obPutStr(tree,n,txt);
			break;
		case	FZMDST:
			sprintf(txt,"%5i x %-5i",img[W[working].id].mfdb.w,img[W[working].id].mfdb.h);
			_obPutStr(tree,n,txt);
			break;
		case	FZMPOP:
			_initPopUp(tree,n,PZOOM,PZMWH-1,POP_LEFT,POP_CENTER,TRUE);
			break;
		case	FZMW:
			sprintf(txt,"%i",img[W[working].id].mfdb.w);
			_obPutStr(tree,n,txt);
			break;
		case	FZMH:
			sprintf(txt,"%i",img[W[working].id].mfdb.h);
			_obPutStr(tree,n,txt);
			break;
		case	FZMQUAL:
			if (glb.opt.zoom_hq)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FZMREP:
			if (glb.opt.zoom_rep)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
	}
}

static void _initDebug(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FDEBUG];

	switch (n)
	{
		case	FDBGOK:
			if (glb.opt.baklog)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FDBGINI:
			if (glb.opt.baklogmask&LOG_INI)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FDBGMEM:
			if (glb.opt.baklogmask&LOG_MEM)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FDBGTRM:
			if (glb.opt.baklogmask&LOG_TRM)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FDBGRIM:
			if (glb.opt.baklogmask&LOG_RIM)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FDBGWIM:
			if (glb.opt.baklogmask&LOG_WIM)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FDBGIFX:
			if (glb.opt.baklogmask&LOG_IFX)
				tree[n].ob_state|=SELECTED;
			else
				tree[n].ob_state&=~SELECTED;
			break;
		case	FDBGFILE:
			_putPath(tree,n,25,glb.opt.LOG_File);
			break;
	}
}
