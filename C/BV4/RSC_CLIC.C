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

#include	"PROTO.H"

static void	_clicModules(int n,int nmb);
static void	_clicOptions(int n,int nmb);
static void	_clicInterface(int n,int nmb);
static void	_clicMemoire(int n,int nmb);
static void	_clicSMemoire(int n,int nmb);
static void	_clicPrt(int n,int nmb);
static void	_clicMe(int n,int nmb);
static void	_clicRim(int n,int nmb);
static void	_clicInfo(int n);
static void	_clicLog(int n);
static void	_clicOptionsEg(int n);
static void	_clicSel(int n);
static void	_clicSlide(int n);
static void	_clicCnv(int n);
static void	_clicTrm(int n);
static void	_clicZoom(int n);
static void	_clicDebug(int n);

/*******************************************************************************
*******************************************************************************/
#pragma warn -par
void _clicRSC(int obj,int n,int nmb)
{
	switch (obj)
	{
		case	FMOD:		_clicModules(n,nmb);		break;
		case	FOPT:		_clicOptions(n,nmb);		break;
		case	FINT:		_clicInterface(n,nmb);	break;
		case	FMEM:		_clicMemoire(n,nmb);		break;
		case	FSMEM:	_clicSMemoire(n,nmb);	break;
		case	FPRT:		_clicPrt(n,nmb);			break;
		case	FME:		_clicMe(n,nmb);			break;
		case	FRIM:		_clicRim(n,nmb);			break;
		case	FINFO:	_clicInfo(n);				break;
		case	FLOG:		_clicLog(n);				break;
		case	FSEL:		_clicSel(n);				break;
		case	FSLIDE:	_clicSlide(n);				break;
		case	FCNV:		_clicCnv(n);				break;
		case	FTRM:		_clicTrm(n);				break;
		case	FZOOM:	_clicZoom(n);				break;
		case	FDEBUG:	_clicDebug(n);				break;
	}
}
static void _clicModules(int n,int nmb)
{
	PARX_RIM	*rim;
	PARX_WIM	*wim;
	PARX_IFX	*ifx;
	OBJECT	*tree=glb.rsc.head.trindex[FMOD];
	int		obx,oby,obw,obh;

	switch (n)
	{
		case	FMODP:
			strcpy(glb.div.pname,glb.parx.Path);
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.fname,"");
			if (_fselect(glb.div.pfname,glb.div.pname,glb.div.fname,"*.*",glb.rsc.head.frstr[PARX]))
			{
				if (glb.div.pfname[1]!=':')
				{
					glb.parx.Path[0]=65+Dgetdrv();
					glb.parx.Path[1]=':';
					glb.parx.Path[2]='\0';
				}
				else
					glb.parx.Path[0]='\0';
				strcat(glb.parx.Path,glb.div.pname);
				strcat(glb.parx.Path,"\\");
				_putPath(tree,n,25,(char *)&glb.parx.Path);
			}
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMODX1:
			if (tree[n].ob_state&SELECTED)
				glb.parx.Mask|=P_RIM;
			else
				glb.parx.Mask&=~P_RIM;
			break;
		case	FMODP1:
			glb.parx.d_rim=_getPopUp(tree,n);
			rim=(PARX_RIM *)_rimAdr(glb.parx.d_rim);
			strncpy(glb.parx.def_rim,rim->id,8L);
			_initRSC(FMOD,FMODD1);
			wind_update(BEG_MCTRL);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODD1,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMODX2:
			if (tree[n].ob_state&SELECTED)
				glb.parx.Mask|=P_WIM;
			else
				glb.parx.Mask&=~P_WIM;
			break;
		case	FMODP2:
			glb.parx.d_wim=_getPopUp(tree,n);
			wim=(PARX_WIM *)_wimAdr(glb.parx.d_wim);
			strncpy(glb.parx.def_wim,wim->id,8L);
			_initRSC(FMOD,FMODD2);
			wind_update(BEG_MCTRL);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODD2,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMODX4:
			if (tree[n].ob_state&SELECTED)
				glb.parx.Mask|=P_IFX;
			else
				glb.parx.Mask&=~P_IFX;
			break;
		case	FMODP4:
			glb.parx.d_ifx=_getPopUp(tree,n);
			ifx=(PARX_IFX *)_ifxAdr(glb.parx.d_ifx);
			strncpy(glb.parx.def_ifx,ifx->id,8L);
			_initRSC(FMOD,FMODD4);
			wind_update(BEG_MCTRL);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODD4,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMODX8:
			if (tree[n].ob_state&SELECTED)
				glb.parx.Mask|=P_TRM;
			else
				glb.parx.Mask&=~P_TRM;
			break;
		case	FMODP8:
			glb.parx.d_trm=1+_getPopUp(tree,n);
			_initRSC(FMOD,FMODD8);
			wind_update(BEG_MCTRL);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODD8,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMODX10:
			if (tree[n].ob_state&SELECTED)
				glb.parx.Mask|=P_MEM;
			else
				glb.parx.Mask&=~P_MEM;
			break;
		case	FMODX20:
			if (tree[n].ob_state&SELECTED)
				glb.parx.Mask|=P_BRO;
			else
				glb.parx.Mask&=~P_BRO;
			break;
		case	FMODX40:
			if (tree[n].ob_state&SELECTED)
				glb.parx.Mask|=P_MOT;
			else
				glb.parx.Mask&=~P_MOT;
			break;
		case	FMODX80:
			if (tree[n].ob_state&SELECTED)
				glb.parx.Mask|=P_PAL;
			else
				glb.parx.Mask&=~P_PAL;
			break;
		case	FMODCNF:
			_setModule();
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMOD,TRUE),tree,FMODCNF,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
	}
}
static void _clicOptions(int n,int nmb)
{
	OBJECT	*tree=glb.rsc.head.trindex[FOPT];

	switch (n)
	{
		case	FOPTEXT:
			glb.opt.useExt=tree[n].ob_state&SELECTED;
			break;
		case	FOPTPAT:
			glb.opt.usePat=tree[n].ob_state&SELECTED;
			break;
		case	FOPTMAJ:
			glb.opt.MAJ=tree[n].ob_state&SELECTED;
			break;
		case	FOPTGFX:
			glb.opt.gfx=tree[n].ob_state&SELECTED;
			_trmExit();
			_trmInit();
			break;
		case	FOPTICN:
			glb.opt.zap=tree[n].ob_state&SELECTED;
			break;
		case	FOPTPAL:
			glb.opt.pal=tree[n].ob_state&SELECTED;
			break;
		case	FOPTTRM:
			glb.opt.trm=_getPopUp(tree,n);
			break;
		case	FOPTSAV:
			glb.opt.Save_Config=tree[n].ob_state&SELECTED;
			break;
		case	FOPTDSK:
			glb.opt.deskfull=tree[n].ob_state&SELECTED;
			break;
		case	FOPTNUM:
			glb.opt.Win_Num=_getNum(tree,n);
			break;
	}
}
static void _clicInterface(int n,int nmb)
{
	OBJECT	*tree=glb.rsc.head.trindex[FINT];
	OBJECT	*desk;
	bfobspec	*color;
	int		obx,oby,obw,obh;

	switch (n)
	{
		case	FINTPOP:
			glb.opt.Flash_PopUp=tree[n].ob_state&SELECTED;
			break;
		case	FINTCTR:
			glb.opt.Mouse_Form=_getPopUp(tree,n);
			break;
		case	FINTCLS:
			glb.opt.win=_getPopUp(tree,n);
			break;
		case	FINTLNG:
			glb.opt.Language=_getPopUp(tree,n);
			break;
		case	FINTOTO:
			glb.opt.Auto_Icon=tree[n].ob_state&SELECTED;
			_winAlign();
			break;
		case	FINTICNW:
			glb.opt.Rev_Verti=_getPopUp(tree,n);
			_winAlign();
			break;
		case	FINTICNH:
			glb.opt.Rev_Horiz=_getPopUp(tree,n);
			_winAlign();
			break;
		case	FINTSWP:
			strcpy(glb.div.pname,"");
			strcpy(glb.div.fname,"");
			strcpy(glb.div.pfname,glb.div.SWP_Path);
			strcpy(glb.div.tit,glb.rsc.head.frstr[FSELSWP]);
			if (_fselect(glb.div.pfname,glb.div.pname,glb.div.fname,glb.div.ext,glb.div.tit))
			{
				strcpy(glb.div.SWP_Path,glb.div.pname);
				strcat(glb.div.SWP_Path,"\\");
			}
			wind_update(BEG_MCTRL);
			_putPath(tree,n,29,glb.div.SWP_Path);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FINT,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FINTCOL:
			desk=glb.rsc.head.trindex[glb.aes.tree.desk];
			color=(bfobspec *)&(desk->ob_spec.obspec);
			if (glb.vdi.extnd[4]==2)
			{
				glb.aes.desk.color2=_getPopUp(tree,n);
				color->interiorcol=glb.aes.desk.color2;
			}
			else if (glb.vdi.extnd[4]>=4)
			{
				glb.aes.desk.color4=_getPopUp(tree,n);
				color->interiorcol=glb.aes.desk.color4;
			}
			form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,glb.aes.desk.h);
			break;
		case	FINTTRM:
			desk=glb.rsc.head.trindex[glb.aes.tree.desk];
			color=(bfobspec *)&(desk->ob_spec.obspec);
			if (glb.vdi.extnd[4]==1)
			{
				glb.aes.desk.trame1=_getPopUp(tree,n);
				color->fillpattern=glb.aes.desk.trame1;
			}
			else if (glb.vdi.extnd[4]==2)
			{
				glb.aes.desk.trame2=_getPopUp(tree,n);
				color->fillpattern=glb.aes.desk.trame2;
			}
			else if (glb.vdi.extnd[4]>=4)
			{
				glb.aes.desk.trame4=_getPopUp(tree,n);
				color->fillpattern=glb.aes.desk.trame4;
			}
			form_dial(FMD_FINISH,0,0,0,0,glb.aes.desk.x,glb.aes.desk.y,glb.aes.desk.w,glb.aes.desk.h);
			break;
	}
}
static void _clicMemoire(int n,int nmb)
{
	OBJECT	*tree=glb.rsc.head.trindex[FMEM];
	int		obx,oby,obw,obh;

	switch (n)
	{
		case	FMEMMOD:
			_initRSC(FSMEM,FSMEMLEN);
			_initRSC(FSMEM,FSMEMFRE);
			_initRSC(FSMEM,FSMEMSYS);
			_winForm(FSMEM,"","",-1,0,0,W_MODAL);
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FMEM,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMEMINI:
			glb.opt.Mem_Boot=_getNum(tree,n);
			break;
	}
}
static void _clicSMemoire(int n,int nmb)
{
	OBJECT	*tree=glb.rsc.head.trindex[FSMEM];
	long		len;

	switch (n)
	{
		case	FSMEMOK:
		case	FSMEMMIN:
		case	FSMEMMAX:
			if (tree[n].ob_state&SELECTED)
			{
				len=atol(_obGetStr(tree,FSMEMLEN));
				len*=1024L;
				if (n==FSMEMOK)
					_pDim(len);
				else if (n==FSMEMMIN)
					_pDim(0L);
				else
					_pDim(-1L);
			}
			break;
	}
}
static void _clicPrt(int n,int nmb)
{
	OBJECT	*tree=glb.rsc.head.trindex[FPRT];

	switch (n)
	{
		case	FPRTMAX:
			glb.print.max=tree[n].ob_state&SELECTED;
			break;
		case	FPRTOUT:
			glb.print.out=tree[n].ob_state&SELECTED;
			break;
		case	FPRTH1:
			glb.print.xcenter=0;
			break;
		case	FPRTH2:
			glb.print.xcenter=1;
			break;
		case	FPRTH3:
			glb.print.xcenter=2;
			break;
		case	FPRTV1:
			glb.print.ycenter=0;
			break;
		case	FPRTV2:
			glb.print.ycenter=1;
			break;
		case	FPRTV3:
			glb.print.ycenter=2;
			break;
		case	FPRTDRV:
			glb.print.dev=_getPopUp(tree,n)+21;
			_GdosPrintInit();
			break;
		case	FPRTAN:
			_GdosPrintCancel();
			break;
		case	FPRTOK:
			_GdosPrintContinue();
			break;
	}
}
#pragma warn +par


#pragma warn -par
static void _clicMe(int n,int nmb)
{
	MODSTR	*str=(MODSTR *)glb.mem.adr[glb.parx.strin];
	OBJECT	*tree=glb.rsc.head.trindex[FME];
	int		dum,obx,oby,obw,obh;

	switch (n)
	{
		case	FMET:
		case	FMET+1:
		case	FMET+2:
		case	FMET+3:
		case	FMET+4:
		case	FMET+5:
		case	FMET+6:
		case	FMET+7:
		case	FMET+8:
		case	FMET+9:
			glb.parx.setdef=n;
			tree[FMEDEL].ob_state&=~DISABLED;
			tree[FMEINF].ob_state&=~DISABLED;
			if (str[glb.parx.setmod+n-FMET].name[31]&0x1)
				tree[FMESET].ob_state&=~DISABLED;
			else
				tree[FMESET].ob_state|=DISABLED;
			wind_update(BEG_MCTRL);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEP,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMEUP:
			if (glb.parx.setmod>0)
			{
				glb.parx.setmod-=1;
				_drawMod();
				wind_update(BEG_MCTRL);
				_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
				if (glb.parx.setdef!=-1)
				{
					tree[glb.parx.setdef].ob_state&=~SELECTED;
					if (glb.parx.setdef<FMET+9)
					{
						glb.parx.setdef+=1;
						tree[glb.parx.setdef].ob_state|=SELECTED;
					}
					else
					{
						glb.parx.setdef=-1;
						tree[FMEDEL].ob_state|=DISABLED;
						tree[FMEINF].ob_state|=DISABLED;
						tree[FMESET].ob_state|=DISABLED;
						_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEP,MAX_DEPTH,obx,oby,obw,obh);
					}
				}
				_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF,MAX_DEPTH,obx,oby,obw,obh);
				_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF1,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_MCTRL);
			}
			break;
		case	FMEDN:
			if (glb.parx.setmod<glb.parx.strnmb-10)
			{
				glb.parx.setmod+=1;
				_drawMod();
				wind_update(BEG_MCTRL);
				_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
				if (glb.parx.setdef!=-1)
				{
					tree[glb.parx.setdef].ob_state&=~SELECTED;
					if (glb.parx.setdef>FMET)
					{
						glb.parx.setdef-=1;
						tree[glb.parx.setdef].ob_state|=SELECTED;
					}
					else
					{
						glb.parx.setdef=-1;
						tree[FMEDEL].ob_state|=DISABLED;
						tree[FMEINF].ob_state|=DISABLED;
						tree[FMESET].ob_state|=DISABLED;
						_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEP,MAX_DEPTH,obx,oby,obw,obh);
					}
				}
				_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF,MAX_DEPTH,obx,oby,obw,obh);
				_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF1,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_MCTRL);
			}
			break;
		case	FMEF1:
			wind_update(BEG_MCTRL);
			_coord(tree,FMEF2,FALSE,&obx,&oby,&obw,&obh);
			graf_mkstate(&dum,&obx,&dum,&dum);
			wind_update(END_MCTRL);
			dum=glb.parx.setmod;
			if (obx<oby)
				dum=max(glb.parx.setmod-10,0);
			else
				dum=min(glb.parx.setmod+10,glb.parx.strnmb-10);
			if (dum!=glb.parx.setmod)
			{
				wind_update(BEG_MCTRL);
				_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
				if (glb.parx.setdef!=-1)
				{
					if (abs(dum-glb.parx.setmod)<10)
					{
						tree[glb.parx.setdef].ob_state&=~SELECTED;
						glb.parx.setdef-=dum-glb.parx.setmod;
						if (glb.parx.setdef>=FMET && glb.parx.setdef<FMET+10)
							tree[glb.parx.setdef].ob_state|=SELECTED;
						else
							glb.parx.setdef=-1;
					}
					else
					{
						tree[glb.parx.setdef].ob_state&=~SELECTED;
						glb.parx.setdef=-1;
						tree[FMEDEL].ob_state|=DISABLED;
						tree[FMEINF].ob_state|=DISABLED;
						tree[FMESET].ob_state|=DISABLED;
					}
				}
				glb.parx.setmod=dum;
				_drawMod();
				_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEP,MAX_DEPTH,obx,oby,obw,obh);
				_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF,MAX_DEPTH,obx,oby,obw,obh);
				_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF1,MAX_DEPTH,obx,oby,obw,obh);
				wind_update(END_MCTRL);
			}
			break;
		case	FMEMOD:
		case	FMETYP:
			wind_update(BEG_MCTRL);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			glb.parx.setmod=0;
			if (glb.parx.setdef!=-1)
			{
				tree[glb.parx.setdef].ob_state&=~SELECTED;
				glb.parx.setdef=-1;
				tree[FMEDEL].ob_state|=DISABLED;
				tree[FMEINF].ob_state|=DISABLED;
				tree[FMESET].ob_state|=DISABLED;
				_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEP,MAX_DEPTH,obx,oby,obw,obh);
			}
			glb.parx.setmod=0;
			if (n==FMEMOD)
				switch (_getPopUp(tree,FMEMOD))
				{
					case	0:
						_initPopUp(tree,FMETYP,PME2,0,POP_LEFT,POP_VALUE,TRUE);
						break;
					case	1:
						_initPopUp(tree,FMETYP,PME3,0,POP_LEFT,POP_VALUE,TRUE);
						break;
					case	2:
						_initPopUp(tree,FMETYP,PME4,0,POP_LEFT,POP_VALUE,TRUE);
						break;
				}
			_setmodparam();
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF1,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMETYP,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMEINF:
			_modInfo(_getPopUp(tree,FMEMOD),str[glb.parx.setmod+glb.parx.setdef-FMET].n);
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMESET:
			_modConfig(_getPopUp(tree,FMEMOD),str[glb.parx.setmod+glb.parx.setdef-FMET].n);
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMEDEL:
			_modDelete(_getPopUp(tree,FMEMOD),str[glb.parx.setmod+glb.parx.setdef-FMET].n);
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			if (glb.parx.setdef!=-1)
			{
				tree[glb.parx.setdef].ob_state&=~SELECTED;
				glb.parx.setdef=-1;
			}
			_setmodparam();
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEP,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF1,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMEADD:
			_modAdd(_getPopUp(tree,FMEMOD));
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			if (glb.parx.setdef!=-1)
			{
				tree[glb.parx.setdef].ob_state&=~SELECTED;
				glb.parx.setdef=-1;
			}
			_setmodparam();
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEP,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF,MAX_DEPTH,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FME,TRUE),tree,FMEF1,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FMEOK:
			if (glb.parx.setdef!=-1)
				_modDefault(_getPopUp(tree,FMEMOD),str[glb.parx.setmod+glb.parx.setdef-FMET].n);
			break;
		case	FMEAN:
			glb.parx.setmod=0;
			if (glb.parx.setdef!=-1)
			{
				tree[glb.parx.setdef].ob_state&=~SELECTED;
				glb.parx.setdef=-1;
			}
			break;
	}
}


#pragma warn -par
static void _clicRim(int n,int nmb)
{
	OBJECT	*tree=glb.rsc.head.trindex[FRIM];
	int		x=0,y=0,obx,oby,obw,obh;
	char		txt[6];

	switch (n)
	{
		case	FRIMPOP:
			glb.parx.def_dim=_getPopUp(tree,FRIMPOP);
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
			if (x && y)
			{
				glb.parx.def_xdim=x;
				glb.parx.def_ydim=y;
				sprintf(txt,"%i",x);
				_obPutStr(tree,FRIMW,txt);
				sprintf(txt,"%i",y);
				_obPutStr(tree,FRIMH,txt);
				_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
				_winObdraw(_winFindId(TW_FORM,FRIM,TRUE),tree,ROOT,MAX_DEPTH,obx,oby,obw,obh);
			}
			break;
	}
}
/*******************************************************************************
*******************************************************************************/
static void _clicInfo(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FINFO];
	int		obx,oby,obw,obh;

	switch	(n)
	{
		case	FINFICN:
			_winForm(FDEBUG,"","",-1,WIC_INF,0,0);
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,n,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FINFO,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FINFO1:
			_winForm(FINF1,glb.rsc.head.frstr[TWINF1],"",-1,WIC_INF,0,W_MODAL);
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FINFO,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FINFO2:
			_winForm(FINF2,glb.rsc.head.frstr[TWINF2],"",-1,WIC_INF,0,W_MODAL);
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FINFO,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FINFO3:
			_winForm(FINF3,glb.rsc.head.frstr[TWINF3],"",-1,WIC_INF,0,W_MODAL);
			wind_update(BEG_MCTRL);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FINFO,TRUE),tree,n,MAX_DEPTH,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _clicLog(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FLOG];
	int		dum,buf[8];
	int		i;

	switch	(n)
	{
		case	FLOGNMB:
			if (Curr!=_getNum(tree,n)-1)
			{
				Curr=_getNum(tree,n)-1;
				setLog();
			}
			else
			{
				wind_update(BEG_UPDATE);
				wind_get(0,WF_TOP,&dum);
				wind_update(END_UPDATE);
				i=findIMG(_winFindWin(dum));
				if (i!=-1 && i!=Curr)
				{
					buf[0]=WM_TOPPED;
					buf[1]=glb.aes.id;
					buf[3]=W[findIMG(Curr)].handle;
					appl_write(glb.aes.id,16,buf);
				}
		}
		break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _clicSel(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FSEL];
	int		obx,oby,obw,obh;

	switch	(n)
	{
		case	FSELEXTD:
			strcpy(&glb.opt.ext[0][2],_obGetStr(glb.rsc.head.trindex[FSEL],n));
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
			strcpy(&glb.opt.ext[1+n-FSELEXT][2],_obGetStr(glb.rsc.head.trindex[FSEL],n));
			break;
		case	FSELPATD:
			tree[n].ob_state&=~SELECTED;
			strcpy(glb.div.pname,glb.opt.pat[0]);
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.fname,"");
			if ( _fselect(glb.div.pfname,glb.div.pname,glb.div.fname,"*.*",0) )
			{
				strcpy(glb.opt.pat[0],glb.div.pname);
				strcat(glb.opt.pat[0],"\\");
			_putPath(tree,n,22,(char *)&glb.opt.pat[0]);
			}
			wind_update(BEG_MCTRL);
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FSEL,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
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
			tree[n].ob_state&=~SELECTED;
			strcpy(glb.div.pname,glb.opt.pat[1+n-FSELPAT]);
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.fname,"");
			if ( _fselect(glb.div.pfname,glb.div.pname,glb.div.fname,"*.*",0) )
			{
				strcpy(glb.opt.pat[1+n-FSELPAT],glb.div.pname);
				strcat(glb.opt.pat[1+n-FSELPAT],"\\");
				_putPath(tree,n,32,(char *)&glb.opt.pat[1+n-FSELPAT]);
			}
			wind_update(BEG_MCTRL);
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FSEL,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _clicSlide(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FSLIDE];
	int		obx,oby,obw,obh;

	switch (n)
	{
		case	FSLDPAUSE:
			glb.opt.sl_pause=tree[n].ob_state&SELECTED;
			break;
		case	FSLDBT:
			glb.opt.sl_ptime=_getNum(tree,n);
			break;
		case	FSLDNAME:
			glb.opt.sl_info=tree[n].ob_state&SELECTED;
			break;
		case	FSLDLOOP:
			glb.opt.sl_loop=tree[n].ob_state&SELECTED;
			break;
		case	FSLDLED:
			glb.opt.sl_led=tree[n].ob_state&SELECTED;
			break;
		case	FSLDREC:
			glb.opt.sl_rec=tree[n].ob_state&SELECTED;
			break;
		case	FSLDTV:
			glb.opt.sl_tv=tree[n].ob_state&SELECTED;
			break;
		case	FSLDPATH:
			tree[n].ob_state&=~SELECTED;
			strcpy(glb.div.pname,glb.opt.sl_path);
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.fname,glb.opt.sl_name);
			if (_fselect(glb.div.pfname,glb.div.pname,glb.div.fname,"*.*",glb.rsc.head.frstr[TSSLIDE]))
			{
				if (glb.div.pfname[1]!=':')
				{
					glb.opt.sl_path[0]=65+Dgetdrv();
					glb.opt.sl_path[1]=':';
					glb.opt.sl_path[2]='\0';
				}
				else
					glb.opt.sl_path[0]='\0';
				strcat(glb.opt.sl_path,glb.div.pname);
				strcpy(glb.opt.sl_name,glb.div.fname);
				strcpy(glb.opt.sl_pfname,glb.opt.sl_path);
				strcat(glb.opt.sl_pfname,"\\");
				strcat(glb.opt.sl_pfname,glb.opt.sl_name);
				_putPath(tree,n,24,(char *)&glb.opt.sl_pfname);
			}
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			wind_update(BEG_MCTRL);
			_winObdraw(_winFindId(TW_FORM,FSLIDE,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FSLDINC:
			glb.opt.sl_zinc=tree[n].ob_state&SELECTED;
			break;
		case	FSLDDEC:
			glb.opt.sl_zdec=tree[n].ob_state&SELECTED;
			break;
		case	FSLDGO:
			slideshow();
			tree[n].ob_state&=~SELECTED;
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			wind_update(BEG_MCTRL);
			_winObdraw(_winFindId(TW_FORM,FSLIDE,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _clicCnv(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FCNV];
	int		obx,oby,obw,obh;

	switch (n)
	{
		case	FCNVDEL:
			glb.opt.cnv_del=tree[n].ob_state&SELECTED;
			break;
		case	FCNVCOL:
			glb.opt.cnv_col=1+_getPopUp(tree,n);
			break;
		case	FCNVSRC:
			tree[n].ob_state&=~SELECTED;
			strcpy(glb.div.pname,glb.opt.cnv_path);
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.fname,glb.opt.cnv_name);
			if (_fselect(glb.div.pfname,glb.div.pname,glb.div.fname,"*.*",glb.rsc.head.frstr[TCNVSRC]))
			{
				if (glb.div.pfname[1]!=':')
				{
					glb.opt.cnv_path[0]=65+Dgetdrv();
					glb.opt.cnv_path[1]=':';
					glb.opt.cnv_path[2]='\0';
				}
				else
					glb.opt.cnv_path[0]='\0';
				strcat(glb.opt.cnv_path,glb.div.pname);
				strcpy(glb.opt.cnv_name,glb.div.fname);
				strcpy(glb.opt.cnv_pfname,glb.opt.cnv_path);
				strcat(glb.opt.cnv_pfname,"\\");
				strcat(glb.opt.cnv_pfname,glb.opt.cnv_name);
				_putPath(tree,n,32,(char *)&glb.opt.cnv_pfname);
			}
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			wind_update(BEG_MCTRL);
			_winObdraw(_winFindId(TW_FORM,FCNV,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FCNVDST:
			tree[n].ob_state&=~SELECTED;
			strcpy(glb.div.pname,glb.opt.cnv_dst);
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.fname,"*.*");
			if (_fselect(glb.div.pfname,glb.div.pname,glb.div.fname,"*.*",glb.rsc.head.frstr[TCNVDST]))
			{
				if (glb.div.pfname[1]!=':')
				{
					glb.opt.cnv_dst[0]=65+Dgetdrv();
					glb.opt.cnv_dst[1]=':';
					glb.opt.cnv_dst[2]='\0';
				}
				else
					glb.opt.cnv_dst[0]='\0';
				strcat(glb.opt.cnv_dst,glb.div.pname);
				_putPath(tree,n,32,(char *)&glb.opt.cnv_dst);
			}
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			wind_update(BEG_MCTRL);
			_winObdraw(_winFindId(TW_FORM,FCNV,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FCNVGO:
			tree[n].ob_state&=~SELECTED;
			menuOff();
			convert();
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			graf_mouse(ARROW,NULL);
			wind_update(BEG_MCTRL);
			_winObdraw(_winFindId(TW_FORM,FCNV,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			menuOn();
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _clicTrm(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FTRM];
	int		obx,oby,obw,obh;

	switch (n)
	{
		case	FTRMPOP:
			glb.opt.d_trm=1+_getPopUp(tree,n);
			_initRSC(FTRM,FTRMTXT);
			wind_update(BEG_MCTRL);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FTRM,TRUE),tree,FTRMTXT,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
	}
}

/*******************************************************************************
*******************************************************************************/
static void _clicZoom(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FZOOM];
	int		obx,oby,obw,obh;
	int		w,h,nw,nh;
	char		txt[30];

	switch (n)
	{
		case	FZMPOP:
			w=img[W[working].id].mfdb.w;
			h=img[W[working].id].mfdb.h;
			nw=atoi(_obGetStr(tree,FZMW));
			nh=atoi(_obGetStr(tree,FZMH));
			switch	(1+_getPopUp(tree,n))
			{
				case	PZMSS1:
					nw=320;		nh=200;		break;
				case	PZMDS1:
					nw=640;		nh=200;		break;
				case	PZMSS2:
					nw=320;		nh=240;		break;
				case	PZMDS2:
					nw=640;		nh=240;		break;
				case	PZMSD1:
					nw=320;		nh=400;		break;
				case	PZMDD1:
					nw=640;		nh=400;		break;
				case	PZMSD2:
					nw=320;		nh=480;		break;
				case	PZMDD2:
					nw=640;		nh=480;		break;
				case	PZMO2:
					nw=w*2;		nh=h*2;		break;
				case	PZMO3:
					nw=w*3;		nh=h*3;		break;
				case	PZMO4:
					nw=w*4;		nh=h*4;		break;
				case	PZMO5:
					nw=w*5;		nh=h*5;		break;
				case	PZMO6:
					nw=w*6;		nh=h*6;		break;
				case	PZMO7:
					nw=w*7;		nh=h*7;		break;
				case	PZMO8:
					nw=w*8;		nh=h*8;		break;
				case	PZMO9:
					nw=w*9;		nh=h*9;		break;
				case	PZMI2:
					nw=w/2;		nh=h/2;		break;
				case	PZMI3:
					nw=w/3;		nh=h/3;		break;
				case	PZMI4:
					nw=w/4;		nh=h/4;		break;
				case	PZMI5:
					nw=w/5;		nh=h/5;		break;
				case	PZMI6:
					nw=w/6;		nh=h/6;		break;
				case	PZMI7:
					nw=w/7;		nh=h/7;		break;
				case	PZMI8:
					nw=w/8;		nh=h/8;		break;
				case	PZMI9:
					nw=w/9;		nh=h/9;		break;
				case	PZMW:
					nw=atoi(_obGetStr(tree,FZMW));
					nh=(int)((double)h*((double)nw/(double)w));
					break;
				case	PZMH:
					nh=atoi(_obGetStr(tree,FZMH));
					nw=(int)((double)w*((double)nh/(double)h));
					break;
				case	PZMWH:
					nw=atoi(_obGetStr(tree,FZMH));
					nh=atoi(_obGetStr(tree,FZMH));
					break;
			}
			sprintf(txt,"%i",nw);
			_obPutStr(tree,FZMW,txt);
			sprintf(txt,"%i",nh);
			_obPutStr(tree,FZMH,txt);
			sprintf(txt,"%5i x %-5i",nw,nh);
			_obPutStr(tree,FZMDST,txt);
			wind_update(BEG_MCTRL);
			_coord(tree,ROOT,FALSE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FZOOM,TRUE),tree,FZMW,0,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FZOOM,TRUE),tree,FZMH,0,obx,oby,obw,obh);
			_winObdraw(_winFindId(TW_FORM,FZOOM,TRUE),tree,FZMDST,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
		case	FZMQUAL:
			glb.opt.zoom_hq=tree[n].ob_state&SELECTED;
			break;
		case	FZMREP:
			glb.opt.zoom_rep=tree[n].ob_state&SELECTED;
			break;
	}
}

static void _clicDebug(int n)
{
	OBJECT	*tree=glb.rsc.head.trindex[FDEBUG];
	int		obx,oby,obw,obh;

	switch (n)
	{
		case	FDBGOK:
			glb.opt.baklog=tree[n].ob_state&SELECTED;
			if (glb.opt.log!=LOG_FORCE)
				glb.opt.log=glb.opt.baklog;
			break;
		case	FDBGINI:
			if (tree[n].ob_state&SELECTED)
				glb.opt.baklogmask|=LOG_INI;
			else
				glb.opt.baklogmask&=~LOG_INI;
			if (glb.opt.log!=LOG_FORCE)
				glb.opt.logmask=glb.opt.baklogmask;
			break;
		case	FDBGMEM:
			if (tree[n].ob_state&SELECTED)
				glb.opt.baklogmask|=LOG_MEM;
			else
				glb.opt.baklogmask&=~LOG_MEM;
			if (glb.opt.log!=LOG_FORCE)
				glb.opt.logmask=glb.opt.baklogmask;
			break;
		case	FDBGTRM:
			if (tree[n].ob_state&SELECTED)
				glb.opt.baklogmask|=LOG_TRM;
			else
				glb.opt.baklogmask&=~LOG_TRM;
			if (glb.opt.log!=LOG_FORCE)
				glb.opt.logmask=glb.opt.baklogmask;
			break;
		case	FDBGRIM:
			if (tree[n].ob_state&SELECTED)
				glb.opt.baklogmask|=LOG_RIM;
			else
				glb.opt.baklogmask&=~LOG_RIM;
			if (glb.opt.log!=LOG_FORCE)
				glb.opt.logmask=glb.opt.baklogmask;
			break;
		case	FDBGWIM:
			if (tree[n].ob_state&SELECTED)
				glb.opt.baklogmask|=LOG_WIM;
			else
				glb.opt.baklogmask&=~LOG_WIM;
			glb.opt.baklogmask=glb.opt.logmask;
			if (glb.opt.log!=LOG_FORCE)
				glb.opt.logmask=glb.opt.baklogmask;
			break;
		case	FDBGIFX:
			if (tree[n].ob_state&SELECTED)
				glb.opt.baklogmask|=LOG_IFX;
			else
				glb.opt.baklogmask&=~LOG_IFX;
			if (glb.opt.log!=LOG_FORCE)
				glb.opt.logmask=glb.opt.baklogmask;
			break;
		case	FDBGFILE:
			strcpy(glb.div.pname,"");
			strcpy(glb.div.fname,"");
			strcpy(glb.div.pfname,glb.opt.LOG_File);
			strcpy(glb.div.tit,glb.rsc.head.frstr[FSELLOG]);
			if (_fselect(glb.div.pfname,glb.div.pname,glb.div.fname,glb.div.ext,glb.div.tit))
				strcpy(glb.opt.LOG_File,glb.div.pfname);
			wind_update(BEG_MCTRL);
			_putPath(tree,n,25,glb.opt.LOG_File);
			tree[n].ob_state&=~SELECTED;
			_coord(tree,n,TRUE,&obx,&oby,&obw,&obh);
			_winObdraw(_winFindId(TW_FORM,FDEBUG,TRUE),tree,n,0,obx,oby,obw,obh);
			wind_update(END_MCTRL);
			break;
	}
}
