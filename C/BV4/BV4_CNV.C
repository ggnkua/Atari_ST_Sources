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
*******************************************************************************/
static void		Balaie_Path(void);
static void		loadandsave(char *nom,char *f);


/*******************************************************************************
	VARIABLES
*******************************************************************************/


/*******************************************************************************
*******************************************************************************/
void convert()
{
	if (!_dexist(glb.opt.cnv_path))
	{
		form_alert(1,glb.rsc.head.frstr[ACNVSRC]);
		return;
	}

	if (!_dexist(glb.opt.cnv_dst))
	{
		form_alert(1,glb.rsc.head.frstr[ACNVDST]);
		return;
	}

	if (!strcmp(glb.opt.cnv_path,glb.opt.cnv_dst))
	{
		form_alert(1,glb.rsc.head.frstr[ACNVSAME]);
		return;
	}
	_progOn();
	Balaie_Path();
	_progOff();
}


/*******************************************************************************
	BALAYAGE D'UN DOSSIER
*******************************************************************************/
void static Balaie_Path()
{
	char		old_path[FILENAME_MAX];
	int		old_drv;
	char		pfn[FILENAME_MAX];
	DTA		*mydta;
	int		i,shift;

	shift=(int)Kbshift(-1);
	old_drv=Dgetdrv();
	Dgetpath(old_path,1+old_drv);
	mydta=Fgetdta();
	if (glb.opt.cnv_path[1]==':')
		Dsetdrv((int)glb.opt.cnv_path[1]-65);

	strcpy(pfn,glb.opt.cnv_path);
	strcat(pfn,"\\");
	strcat(pfn,glb.opt.cnv_name);

	i=Fsfirst(pfn,FA_READONLY|FA_ARCHIVE);
	while (!i)
	{
		if (mydta->d_fname[0]!='.')
		{
			strcpy(pfn,glb.opt.cnv_path);
			strcat(pfn,"\\");
			strcat(pfn,mydta->d_fname);
			if (!(mydta->d_attrib&FA_SUBDIR))
				loadandsave(pfn,mydta->d_fname);
		}
		if (Kbshift(-1)!=shift)
			return;
		i=Fsnext();
	}
	Dsetdrv(old_drv);
	Dsetpath(old_path);
}

/*******************************************************************************
	CHARGEMENT ET AFFICHAGE
*******************************************************************************/
void static loadandsave(char *nom,char *f)
{
	MFDB		pic,dst;
	long		flen;
	char		name[FILENAME_MAX];
	char		fname[FILENAME_MAX];
	char		type[40];
	char		*p,*q;
	int		ret,col;
	int		pmem,imem;
	int		pdst,idst;

	glb.opt.mask=0;

	if (strlen(nom)>36L)
	{
		strcpy(type,"..");
		strcat(type,&nom[strlen(nom)-34L]);
	}
	else
		strcpy(type,nom);

	_prog(glb.rsc.head.frstr[TCNVLOAD],nom);
	ret=_rimLoad(FALSE,nom,&flen,(MFDB *)&pic,type,&imem,&pmem,0);

	if (ret!=RIM_OK && ret!=RIM_NEXT)
	{
		if (imem!=NO_MEMORY)
			_mFree(imem);
		if (pmem!=NO_MEMORY)
			_mFree(pmem);
		return;
	}

	idst=NO_MEMORY;
	pdst=NO_MEMORY;

	dst.fd_w			=	pic.fd_w;
	dst.fd_wdwidth	=	pic.fd_wdwidth;
	dst.fd_h			=	pic.fd_h;
	dst.fd_stand	=	0;
	dst.fd_nplanes	=	pic.fd_nplanes;

	switch (glb.opt.cnv_col)
	{
		case	PCNVWIM:
			col=0;
			break;
		case	PCNVIMG:
			col=pic.fd_nplanes;
			dst.fd_nplanes=col;
			break;
		case	PCNV1:
			col=1;
			dst.fd_nplanes=col;
			break;
		case	PCNV2:
			col=2;
			dst.fd_nplanes=col;
			break;
		case	PCNV4:
			col=4;
			dst.fd_nplanes=col;
			break;
		case	PCNV8:
			col=8;
			dst.fd_nplanes=col;
			break;
		case	PCNV16:
			col=16;
			dst.fd_nplanes=col;
			break;
		case	PCNV24:
			col=24;
			dst.fd_nplanes=col;
			break;
	}

	_prog(glb.rsc.head.frstr[TCNVTRM],nom);

	ret=trmConvert(FALSE,imem,&idst,pmem,&pdst,&pic,&dst,TRM_IMPORT|TRM_SUGG_PAL|TRM_AUTO,glb.parx.d_trm,0);

	if (ret!=TRM_OK)
	{
		if (imem!=NO_MEMORY)
			_mFree(imem);
		if (pmem!=NO_MEMORY)
			_mFree(pmem);
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		graf_mouse(ARROW,0);
		return;
	}

	if (imem!=idst)
	{
		_mFree(imem);
		imem=idst;
	}
	if (pmem!=pdst)
	{
		_mFree(pmem);
		pmem=pdst;
	}

	strcpy(name,nom);
	p=strrchr(name,'\\');
	q=strrchr(name,'.');

	if (q>p && q)
		*q=0;

	if (!p)
		p=name;
	else
		p++;

	strcpy(fname,glb.opt.cnv_dst);
	strcat(fname,"\\");
	strcat(fname,p);

	if (strlen(fname)>36L)
	{
		strcpy(type,"..");
		strcat(type,&fname[strlen(fname)-34L]);
	}
	else
		strcpy(type,fname);

	_prog(glb.rsc.head.frstr[TCNVSAVE],type);

	strcpy(fname,f);

	ret=_wimSave(FALSE,(MFDB *)&dst,imem,pmem,col,FALSE,glb.opt.cnv_dst,f,"");

	if (ret==WIM_OK && glb.opt.cnv_del)
	{
		if (strlen(nom)>36L)
		{
			strcpy(type,"..");
			strcat(type,&nom[strlen(nom)-34L]);
		}
		else
			strcpy(type,nom);
		_prog(glb.rsc.head.frstr[TCNVDEL],type);
		Fdelete(nom);
	}

	if (imem!=NO_MEMORY)
		_mFree(imem);
	if (pmem!=NO_MEMORY)
		_mFree(pmem);
	_prog("","");
}
