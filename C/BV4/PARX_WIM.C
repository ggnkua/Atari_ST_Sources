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

static int _ChooseWim(void);
static int _ChoosePrintWim(void);


/*******************************************************************************
	Renvoie adresse du WIM en m‚moire
*******************************************************************************/
PARX_WIM *_wimAdr(int n)
{
	long	adr;
	int	i;

	if (n>glb.parx.n_wim)
		return NULL;
	else
	{
		adr=glb.mem.adr[glb.parx.i_wim];
		for (i=0;i<n;i++)
			adr+=*(long *)adr;
	}
	return (PARX_WIM *)adr;
}

/*******************************************************************************
	Sauvegarde d'une image
*******************************************************************************/
int _wimSave(int alert,MFDB *img,int imem,int pmem,int fcol,int fsel,char *pname,char *fname,char *title)
{
	MFDB			src,dst;
	char			ext[6],*p;
	long			r,write;
	PARX_WIM		*wim;
	int			WIM=-1;
	int			ha=0,in,ret,pdst,idst;

	sprintf(glb.div.log,"WimSave\n");
	_reportLog(LOG_WIM);

	if (!glb.parx.n_wim)
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[WIMNOWIM]);
		sprintf(glb.div.log,"No WIM in memory\n");
		_reportLog(LOG_WIM);
		return WIM_NOWIM;
	}

	if (alert)
		WIM=_ChooseWim();
	else
		WIM=glb.parx.d_wim;

	if (WIM==-1)
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[WIMNOWIM]);
		sprintf(glb.div.log,"No WIM in memory\n");
		_reportLog(LOG_WIM);
		return WIM_NOWIM;
	}

	dst.fd_addr		=	(void *)glb.mem.adr[imem];				/*	Adr img source	*/
	dst.fd_w			=	img->fd_w;									/*	param sources	*/
	dst.fd_h			=	img->fd_h;
	dst.fd_wdwidth	=	img->fd_wdwidth;
	dst.fd_stand	=	img->fd_stand;
	if (fcol)
		dst.fd_nplanes	=	fcol;
	else
		dst.fd_nplanes	=	img->fd_nplanes;

	wim=(PARX_WIM *)_wimAdr(WIM);								/*	Adresse header RIM	*/
sprintf(glb.div.log,"WIM: %s\n",wim->name);
_reportLog(LOG_WIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst.fd_addr,dst.fd_w,dst.fd_h,dst.fd_wdwidth,dst.fd_stand,dst.fd_nplanes);
_reportLog(LOG_WIM);
	r=(wim->INFO_SAUVE)(&dst);									/*	Appel d'INFO_SAUVE	*/
sprintf(glb.div.log,"Info_Sauve(%li) return: %li\n",(long)&dst,r);
_reportLog(LOG_WIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst.fd_addr,dst.fd_w,dst.fd_h,dst.fd_wdwidth,dst.fd_stand,dst.fd_nplanes);
_reportLog(LOG_WIM);
	if (dst.fd_wdwidth!=_word(dst.fd_w))
	{
sprintf(glb.div.log,"Bug in the WIM !!! bad fd_wdwidth value: %i instead %i\n",(int)dst.fd_wdwidth,(int)((dst.fd_w+15)/16));
_reportLog(LOG_WIM);
	}

	if (fcol && fcol!=dst.fd_nplanes)
	{
		if (alert)											/*	on laisse tomber			*/
			form_alert(1,glb.rsc.head.frstr[WIMNOCOL]);
		sprintf(glb.div.log,"Cannot force WIM to %i planes\n",fcol);
		_reportLog(LOG_WIM);
		return WIM_NODIM;
	}

	if (wim->fmt==WIM_SHI)
		dst.fd_stand=0;
	else if (wim->fmt==WIM_VDI)
		dst.fd_stand=1;


	src.fd_w			=	img->fd_w;						/*	MFDB source pour la		*/
	src.fd_wdwidth	=	img->fd_wdwidth;				/*	routine de trƒmage		*/
	src.fd_h			=	img->fd_h;
	src.fd_stand	=	img->fd_stand;
	src.fd_nplanes	=	img->fd_nplanes;


	if (wim->type!=WIM_GEN)
	{
		*(long *)ext=(long)dst.fd_addr;				/*	Extension du fichier		*/
		ext[4]='\0';

		p=strchr(fname,'.');
		if (p)
			*p=0;
		if (fsel)
		{
			strcpy(glb.div.pname,pname);
			strcpy(glb.div.fname,fname);
			strcat(glb.div.fname,ext);
			strcpy(glb.div.pfname,"");
			strcpy(glb.div.ext,"*");
			strcat(glb.div.ext,ext);
			ret=_fselect(glb.div.pfname,glb.div.pname,glb.div.fname,glb.div.ext,title);
			if (!ret)
			{
				sprintf(glb.div.log,"User abort on fileselect\n");
				_reportLog(LOG_WIM);
				return WIM_NOFILE;
			}
		}
		else
		{
			strcpy(glb.div.pfname,pname);
			if (glb.div.pfname[strlen(glb.div.pfname)-1L]!='\\')
				strcat(glb.div.pfname,"\\");
			strcat(glb.div.pfname,fname);
			strcat(glb.div.pfname,ext);
		}
	}

	idst=NO_MEMORY;												/*	index mem img dest	*/
	pdst=NO_MEMORY;												/*	index mem pal dest	*/

	src.fd_addr=0;
	dst.fd_addr=0;

	sprintf(glb.div.log,"Type: %s\n",wim->name);
	_reportLog(LOG_WIM);
	sprintf(glb.div.log,"W=%i WDW=%i H=%i STD=%i PLANES=%i\n",src.fd_w,src.fd_wdwidth,src.fd_h,src.fd_stand,src.fd_nplanes);
	_reportLog(LOG_WIM);

	/*	Appel de la routine de trƒmage	*/
	if (alert)
		ret=_trmConvert(alert,imem,&idst,pmem,&pdst,&src,&dst,TRM_EXPORT|TRM_SUGG_PAL|TRM_USER|TRM_FORCE,glb.parx.d_trm,1);
	else
		ret=_trmConvert(alert,imem,&idst,pmem,&pdst,&src,&dst,TRM_EXPORT|TRM_SUGG_PAL|TRM_AUTO|TRM_FORCE,glb.parx.d_trm,1);

	if (ret!=TRM_OK)			/*	Erreur de trƒmage ?	*/
	{
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		sprintf(glb.div.log,"Error while dithering\n");
		_reportLog(LOG_WIM);
		return WIM_NOTRM;
	}

	if (wim->type!=WIM_GEN)
	{
		ha=(int)Fcreate(glb.div.pfname,0);
		if (ha<0)
		{
			if (idst!=NO_MEMORY)
				_mFree(idst);
			if (pdst!=NO_MEMORY)
				_mFree(pdst);
			if (alert)
				form_alert(1,glb.rsc.head.frstr[WIMNOFILE]);
			sprintf(glb.div.log,"Error while opening file '%s'\n",glb.div.pfname);
			_reportLog(LOG_WIM);
			return WIM_FILE;
		}
	}

	dst.fd_r1=ha;							/*	Handle de fichier ouvert	*/
	dst.fd_r2=0;
	dst.fd_r3=0;
	dst.fd_addr=(void *)glb.mem.adr[idst];	/*	Adr image source (idst parce	*/
														/*	‡a sort du TRM en idst/pdst	*/
	if (alert)
	{
		_progOn();
		_prog(wim->name,glb.rsc.head.frstr[WIMWORK1]);
	}
	wim=(PARX_WIM *)_wimAdr(WIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i r1=%i r2=%i r3=%i\n",
	(long)dst.fd_addr,dst.fd_w,dst.fd_h,dst.fd_wdwidth,dst.fd_stand,dst.fd_nplanes,dst.fd_r1,dst.fd_r2,dst.fd_r3);
_reportLog(LOG_WIM);
	if (pdst!=NO_MEMORY)
	{
		r=(wim->ESTIME_TAILLE)(&dst,glb.mem.adr[pdst]);
sprintf(glb.div.log,"Estime_Taille(%li,%li) return: %li\n",(long)&dst,glb.mem.adr[pdst],r);
_reportLog(LOG_WIM);
	}
	else
	{
		r=(wim->ESTIME_TAILLE)(&dst,0L);
sprintf(glb.div.log,"Estime_Taille(%li,%li) return: %li\n",(long)&dst,0L,r);
_reportLog(LOG_WIM);
	}
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i r1=%i r2=%i r3=%i\n",
	(long)dst.fd_addr,dst.fd_w,dst.fd_h,dst.fd_wdwidth,dst.fd_stand,dst.fd_nplanes,dst.fd_r1,dst.fd_r2,dst.fd_r3);
_reportLog(LOG_WIM);
	if (alert)
		_progOff();

	if (r<0L)								/*	Appel foireux ?	*/
	{
		if (wim->type!=WIM_GEN)
			Fclose(ha);
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		sprintf(glb.div.log,"Error while working (1)\n");
		_reportLog(LOG_WIM);
		return WIM_FILE;
	}

	in=_mAlloc(r,1);						/*	Allocation buffer	*/
	if (in==NO_MEMORY)
	{
		if (wim->type!=WIM_GEN)
			Fclose(ha);
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		if (alert)
			form_alert(1,glb.rsc.head.frstr[WIMNOMEM]);
		sprintf(glb.div.log,"Not enough memory\n");
		_reportLog(LOG_WIM);
		return WIM_FILE;
	}

	dst.fd_r1=ha;							/*	Handle de fichier ouvert	*/
	dst.fd_r2=0;
	dst.fd_r3=0;
	dst.fd_addr=(void *)glb.mem.adr[idst];		/*	Image source	*/
	if (alert)
	{
		_progOn();
		_prog(wim->name,glb.rsc.head.frstr[WIMWORK2]);
	}
	wim=(PARX_WIM *)_wimAdr(WIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i r1=%i r2=%i r3=%i\n",
	(long)dst.fd_addr,dst.fd_w,dst.fd_h,dst.fd_wdwidth,dst.fd_stand,dst.fd_nplanes,dst.fd_r1,dst.fd_r2,dst.fd_r3);
_reportLog(LOG_WIM);
	if (pdst!=NO_MEMORY)
	{
		r=(wim->TRAITE_FICHIER)(&dst,glb.mem.adr[pdst],glb.mem.adr[in]);
sprintf(glb.div.log,"Traite_Fichier(%li,%li,%li) return: %li\n",(long)&dst,glb.mem.adr[pdst],glb.mem.adr[in],r);
_reportLog(LOG_WIM);
	}
	else
	{
		r=(wim->TRAITE_FICHIER)(&dst,0L,glb.mem.adr[in]);
sprintf(glb.div.log,"Traite_Fichier(%li,%li,%li) return: %li\n",(long)&dst,0L,glb.mem.adr[in],r);
_reportLog(LOG_WIM);
	}
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i r1=%i r2=%i r3=%i\n",
	(long)dst.fd_addr,dst.fd_w,dst.fd_h,dst.fd_wdwidth,dst.fd_stand,dst.fd_nplanes,dst.fd_r1,dst.fd_r2,dst.fd_r3);
_reportLog(LOG_WIM);
	if (alert)
		_progOff();
	if (r<0)
	{
		if (wim->type!=WIM_GEN)
			Fclose(ha);
		if (in!=NO_MEMORY)
			_mFree(in);
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		if (alert)
			form_alert(1,glb.rsc.head.frstr[WIMERROR]);
		sprintf(glb.div.log,"Error while working (2)\n");
		_reportLog(LOG_WIM);
		return WIM_FILE;
	}

	if (wim->type!=WIM_GEN)
	{
		write=r;					/*	Ecriture du buffer sur disque	*/
		if (alert)
		{
			_progOn();
			_prog(wim->name,glb.rsc.head.frstr[WIMSAVE]);
		}
		if (r>0)
			write=Fwrite(ha,r,(void *)glb.mem.adr[in]);
		if (alert)
			_progOff();

		if (r!=write)
		{
			Fclose(ha);
			if (in!=NO_MEMORY)
				_mFree(in);
			if (idst!=NO_MEMORY)
				_mFree(idst);
			if (pdst!=NO_MEMORY)
				_mFree(pdst);
			if (alert)
				form_alert(1,glb.rsc.head.frstr[WIMNOFILE]);
			sprintf(glb.div.log,"Error while writing file\n");
			_reportLog(LOG_WIM);
			return WIM_FILE;
		}

		ret=Fclose(ha);
		if (ret<0)
		{
			if (in!=NO_MEMORY)
				_mFree(in);
			if (idst!=NO_MEMORY)
				_mFree(idst);
			if (pdst!=NO_MEMORY)
				_mFree(pdst);
			if (alert)
				form_alert(1,glb.rsc.head.frstr[WIMNOFILE]);
			sprintf(glb.div.log,"Error while writing file\n");
			_reportLog(LOG_WIM);
			return WIM_FILE;
		}
	}	
	if (in!=NO_MEMORY)
		_mFree(in);
	if (idst!=NO_MEMORY)
		_mFree(idst);
	if (pdst!=NO_MEMORY)
		_mFree(pdst);
	/****************************************************************************
	****************************************************************************/

	sprintf(glb.div.log,"Ok\n");
	_reportLog(LOG_WIM);
	return WIM_OK;
}

static int _ChooseWim()
{
	OBJECT	*tree=glb.rsc.head.trindex[FME];
	int		r;

	_initPopUp(tree,FMEMOD,PME1,1,POP_LEFT,POP_CENTER,TRUE);
	tree[FMEMOD].ob_state|=DISABLED;
	_initPopUp(tree,FMETYP,PME3,0,POP_LEFT,POP_CENTER,TRUE);
	tree[FMETYP].ob_state&=~DISABLED;
	glb.parx.setmod=0;
	_setmodparam();

	r=_winForm(FME,glb.rsc.head.frstr[WME],"",-1,WIC_MOD,0,W_MODAL);

	if (r==FMEAN)
		return -1;
	else
		return glb.parx.d_wim;
}

int _wimPrint(int imem,int pmem,MFDB *img)
{
	MFDB			src,dst;
	long			r;
	PARX_WIM		*wim;
	int			WIM=-1;
	int			in,ret,pdst,idst;

	sprintf(glb.div.log,"WimPrint\n");
	_reportLog(LOG_WIM);

	if (!glb.parx.n_wim)
	{
		form_alert(1,glb.rsc.head.frstr[WIMNOWIM]);
		sprintf(glb.div.log,"No WIM in memory\n");
		_reportLog(LOG_WIM);
		return WIM_NOWIM;
	}

	WIM=_ChoosePrintWim();

	if (WIM==-1)
	{
		form_alert(1,glb.rsc.head.frstr[WIMNOWIM]);
		sprintf(glb.div.log,"No WIM in memory\n");
		_reportLog(LOG_WIM);
		return WIM_NOWIM;
	}

	dst.fd_addr		=	(void *)glb.mem.adr[imem];				/*	Adr img source	*/
	dst.fd_w			=	img->fd_w;									/*	param sources	*/
	dst.fd_h			=	img->fd_h;
	dst.fd_wdwidth	=	img->fd_wdwidth;
	dst.fd_stand	=	img->fd_stand;
	dst.fd_nplanes	=	img->fd_nplanes;

	wim=(PARX_WIM *)_wimAdr(WIM);								/*	Adresse header RIM	*/
	r=(wim->INFO_SAUVE)(&dst);									/*	Appel d'INFO_SAUVE	*/

	if (wim->fmt=='_VDI')
		dst.fd_stand=1;
	else
		dst.fd_stand=0;

	if (dst.fd_w!=img->fd_w || dst.fd_h!=img->fd_h)
	{																/*	Si dimension diff‚rente	*/

		src.fd_w			=	img->fd_w;						/*	MFDB source pour la		*/
		src.fd_wdwidth	=	img->fd_wdwidth;				/*	routine de trƒmage		*/
		src.fd_h			=	img->fd_h;
		src.fd_stand	=	img->fd_stand;
		src.fd_nplanes	=	img->fd_nplanes;

		dst.fd_nplanes	=	img->fd_nplanes;

		idst=NO_MEMORY;											/*	index mem img dest	*/
		pdst=NO_MEMORY;											/*	index mem pal dest	*/
		dst.fd_addr=0;

		/*	Appel de la routine de zoom	*/
		ret=_trmZoom(TRUE,imem,&idst,pmem,&pdst,&src,&dst,TRM_EXPORT|TRM_SUGG_PAL|TRM_AUTO,TRM_ZOOM_LQ,1);

		if (ret!=TRM_OK)			/*	Erreur de trƒmage ?	*/
		{
			if (idst!=NO_MEMORY)
				_mFree(idst);
			if (pdst!=NO_MEMORY)
				_mFree(pdst);
			sprintf(glb.div.log,"Error while zooming\n");
			_reportLog(LOG_WIM);
			return WIM_NOZOOM;
		}

		if (idst!=imem)
			imem=idst;
		if (pdst!=pmem)
			pmem=pdst;

		dst.fd_addr		=	(void *)glb.mem.adr[imem];				/*	Adr img source	*/
		dst.fd_w			=	img->fd_w;									/*	param sources	*/
		dst.fd_h			=	img->fd_h;
		dst.fd_wdwidth	=	img->fd_wdwidth;
		dst.fd_stand	=	img->fd_stand;
		dst.fd_nplanes	=	img->fd_nplanes;
		wim=(PARX_WIM *)_wimAdr(WIM);								/*	Adresse header RIM	*/
		r=(wim->INFO_SAUVE)(&dst);									/*	Appel d'INFO_SAUVE	*/

		src.fd_addr		=	(void *)glb.mem.adr[idst];				/*	Adr img source	*/
		src.fd_w			=	dst.fd_w;									/*	param sources	*/
		src.fd_h			=	dst.fd_h;
		src.fd_wdwidth	=	dst.fd_wdwidth;
		src.fd_stand	=	dst.fd_stand;
		src.fd_nplanes	=	dst.fd_nplanes;
	}

	src.fd_w			=	img->fd_w;						/*	MFDB source pour la		*/
	src.fd_wdwidth	=	img->fd_wdwidth;				/*	routine de trƒmage		*/
	src.fd_h			=	img->fd_h;
	src.fd_stand	=	img->fd_stand;
	src.fd_nplanes	=	img->fd_nplanes;

	idst=NO_MEMORY;												/*	index mem img dest	*/
	pdst=NO_MEMORY;												/*	index mem pal dest	*/
	imem=imem;													/*	index mem img source	*/
	pmem=pmem;													/*	index mem pal source	*/
	dst.fd_addr=0;

	sprintf(glb.div.log,"Type: %s\n",wim->name);
	_reportLog(LOG_WIM);
	sprintf(glb.div.log,"W=%i WDW=%i H=%i STD=%i PLANES=%i\n",src.fd_w,src.fd_wdwidth,src.fd_h,src.fd_stand,src.fd_nplanes);
	_reportLog(LOG_WIM);

	/*	Appel de la routine de trƒmage	*/
	ret=_trmConvert(TRUE,imem,&idst,pmem,&pdst,&src,&dst,TRM_EXPORT|TRM_SUGG_PAL|TRM_USER,glb.parx.d_trm,1);

	if (ret!=TRM_OK)			/*	Erreur de trƒmage ?	*/
	{
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		sprintf(glb.div.log,"Error while dithering\n");
		_reportLog(LOG_WIM);
		return WIM_NOTRM;
	}

	dst.fd_r1=0;
	dst.fd_r2=0;
	dst.fd_r3=0;
	dst.fd_addr=(void *)glb.mem.adr[idst];	/*	Adr image source (idst parce	*/
														/*	‡a sort du TRM en idst/pdst	*/
	_progOn();
	_prog(wim->name,glb.rsc.head.frstr[WIMWORK1]);

	wim=(PARX_WIM *)_wimAdr(WIM);
	if (pdst!=NO_MEMORY)
		r=(wim->ESTIME_TAILLE)(&dst,glb.mem.adr[pdst]);
	else
		r=(wim->ESTIME_TAILLE)(&dst,0L);

	_progOff();

	if (r<0L)								/*	Appel foireux ?	*/
	{
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		sprintf(glb.div.log,"Error while working (1)\n");
		_reportLog(LOG_WIM);
		return WIM_FILE;
	}

	in=_mAlloc(r,1);						/*	Allocation buffer	*/
	if (in==NO_MEMORY)
	{
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		form_alert(1,glb.rsc.head.frstr[WIMNOMEM]);
		sprintf(glb.div.log,"Not enough memory\n");
		_reportLog(LOG_WIM);
		return WIM_FILE;
	}

	dst.fd_r1=0;
	dst.fd_r2=0;
	dst.fd_r3=0;
	dst.fd_addr=(void *)glb.mem.adr[idst];		/*	Image source	*/

	_progOn();
	_prog(wim->name,glb.rsc.head.frstr[WIMWORK2]);

	wim=(PARX_WIM *)_wimAdr(WIM);
	if (pdst!=NO_MEMORY)
		r=(wim->TRAITE_FICHIER)(&dst,glb.mem.adr[pdst],glb.mem.adr[in]);
	else
		r=(wim->TRAITE_FICHIER)(&dst,0L,glb.mem.adr[in]);

	_progOff();

	if (r<0)
	{
		if (in!=NO_MEMORY)
			_mFree(in);
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		form_alert(1,glb.rsc.head.frstr[WIMERROR]);
		sprintf(glb.div.log,"Error while working (2)\n");
		_reportLog(LOG_WIM);
		return WIM_FILE;
	}

	if (in!=NO_MEMORY)
		_mFree(in);
	if (idst!=NO_MEMORY)
		_mFree(idst);
	if (pdst!=NO_MEMORY)
		_mFree(pdst);
	/****************************************************************************
	****************************************************************************/

	sprintf(glb.div.log,"\n");
	_reportLog(LOG_WIM);
	return WIM_OK;
}

static int _ChoosePrintWim()
{
	OBJECT	*tree=glb.rsc.head.trindex[FME];
	int		r;

	_initPopUp(tree,FMEMOD,PME1,1,POP_LEFT,POP_CENTER,TRUE);
	tree[FMEMOD].ob_state|=DISABLED;
	_initPopUp(tree,FMETYP,PME3,PME3GEN-1,POP_LEFT,POP_CENTER,TRUE);
	tree[FMETYP].ob_state|=DISABLED;
	glb.parx.setmod=0;
	_setmodparam();

	r=_winForm(FME,glb.rsc.head.frstr[WME],"",-1,WIC_MOD,0,W_MODAL);

	if (r==FMEAN)
		return -1;
	else
		return glb.parx.d_wim;
}
