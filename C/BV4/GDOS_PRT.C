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

static void _searchDriverName(char *chaine,int i);


/*******************************************************************************
	Variables
*******************************************************************************/
extern VDIPARBLK	VDI_pb;
typedef struct
{
	long	control;
	long	intin;
	long	ptsin;
	long	intout;
	long	ptsout;
}	VDIPB;
static long		STATUS='NONE';
static int		hvdi=0,fpw,fph,fmw,fmh;
static int		imw,imh;
static char		_Fname[FILENAME_MAX];


/*******************************************************************************
*******************************************************************************/
void _GdosPrintImg(int isrc,int psrc,MFDB *src)
{
	long cdecl	(*INFO_SAUVE)(MFDB *mfdb);
	long cdecl	(*ESTIME_TAILLE)(MFDB *mfdb,long pal);
	long cdecl	(*TRAITE_FICHIER)(MFDB *mfdb,long pal,long buf);
	PARX_WIM		*wim;
	char			ext[14];
	MFDB			dst;
	long			r,write;
	int			iwim=-1;
	int			j,ha,in,ret;
	int			idst,pdst;

	if (STATUS!='NONE')
		return;

	if (!glb.vdi.gdos)
	{
		form_alert(1,glb.rsc.head.frstr[GDOSNO]);
		return;
	}

	for (j=0;j<glb.parx.n_wim;j++)
	{
		wim=_wimAdr(j);
		if (!strncmp(wim->id,"IMG     ",8L))
			iwim=j;
	}

	if (iwim==-1)
	{
		form_alert(1,glb.rsc.head.frstr[GDOSNOWIM]);
		return;
	}

	INFO_SAUVE		=	(void *)((long)_wimAdr(iwim)+56L);
	ESTIME_TAILLE	=	(void *)((long)_wimAdr(iwim)+60L);
	TRAITE_FICHIER	=	(void *)((long)_wimAdr(iwim)+64L);

	dst.fd_addr		=	0;
	dst.fd_w			=	src->fd_w;
	dst.fd_h			=	src->fd_h;
	dst.fd_wdwidth	=	src->fd_wdwidth;
	dst.fd_stand	=	src->fd_stand;
	dst.fd_nplanes	=	src->fd_nplanes;

	r=(*INFO_SAUVE)(&dst);

	*(long *)ext=(long)dst.fd_addr;		/*	Extension du fichier		*/
	ext[4]='\0';

	src->fd_addr	=	(void *)glb.mem.adr[isrc];
	dst.fd_addr		=	0;
	idst=NO_MEMORY;
	pdst=NO_MEMORY;
	ret=_trmConvert(1,isrc,&idst,psrc,&pdst,src,&dst,TRM_EXPORT|TRM_SUGG_PAL|TRM_USER,glb.parx.d_trm,1);

	if (ret!=TRM_OK)
		return;

	sprintf(_Fname,"%sEG_PRINT%s",glb.div.SWP_Path,ext);
	ha=(int)Fcreate(_Fname,0);
	if (ha<0)
	{
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		form_alert(1,glb.rsc.head.frstr[WIMNOFILE]);
		return;
	}

	dst.fd_r1=ha;							/*	Handle de fichier ouvert	*/
	dst.fd_r2=0;
	dst.fd_r3=0;
	dst.fd_addr=(void *)glb.mem.adr[idst];	/*	Adr image source (idst parce	*/
														/*	‡a sort du TRM en idst			*/
	if (pdst!=NO_MEMORY)							/*	mˆme remarque pour pdst			*/
		r=(*ESTIME_TAILLE)(&dst,glb.mem.adr[pdst]);
	else
		r=(*ESTIME_TAILLE)(&dst,0L);

	if (r<0L)								/*	Appel foireux ?	*/
	{
		Fclose(ha);
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		return;
	}

	in=_mAlloc(r,1);						/*	Allocation buffer	*/
	if (in==NO_MEMORY)
	{
		Fclose(ha);
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		form_alert(1,glb.rsc.head.frstr[WIMNOMEM]);
		return;
	}

	dst.fd_r1=ha;							/*	Handle de fichier ouvert	*/
	dst.fd_r2=0;
	dst.fd_r3=0;
	dst.fd_addr=(void *)glb.mem.adr[idst];		/*	Image source	*/
	if (pdst!=NO_MEMORY)
		r=(*TRAITE_FICHIER)(&dst,glb.mem.adr[pdst],glb.mem.adr[in]);
	else
		r=(*TRAITE_FICHIER)(&dst,0L,glb.mem.adr[in]);

	if (r<0)
	{
		Fclose(ha);
		if (in!=NO_MEMORY)
			_mFree(in);
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		form_alert(1,glb.rsc.head.frstr[WIMERROR]);
		return;
	}

	write=r;					/*	Ecriture du buffer sur disque	*/
	if (r>0)
		write=Fwrite(ha,r,(void *)glb.mem.adr[in]);

	if (r!=write)
	{
		Fclose(ha);
		if (in!=NO_MEMORY)
			_mFree(in);
		if (idst!=NO_MEMORY)
			_mFree(idst);
		if (pdst!=NO_MEMORY)
			_mFree(pdst);
		form_alert(1,glb.rsc.head.frstr[WIMNOFILE]);
		return;
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
		form_alert(1,glb.rsc.head.frstr[WIMNOFILE]);
		return;
	}
	
	if (in!=NO_MEMORY)
		_mFree(in);
	if (idst!=NO_MEMORY)
		_mFree(idst);
	if (pdst!=NO_MEMORY)
		_mFree(pdst);

	imw=src->fd_w;
	imh=src->fd_h;
	if (!_GdosPrintInit())
	{
		form_alert(1,glb.rsc.head.frstr[GDOSOPEN]);
		Fdelete(_Fname);
		return;
	}
	STATUS='ASK ';
	/****************************************************************************
		Fenˆtre de param‚trage
	****************************************************************************/
	_winForm(FPRT,glb.rsc.head.frstr[WPRT],"",0,0,0,W_MODAL);
}

void _GdosPrintCancel()
{
	STATUS='NONE';
	if (hvdi)
		v_clswk(hvdi);
	Fdelete(_Fname);
}

void _GdosPrintContinue()
{
	int	pxy[4];

	STATUS='DO  ';
	_winClose(_winFindId(TW_FORM,FPRT,TRUE));
	_progOn();
	_prog(glb.rsc.head.frstr[GDOSPRINT],"");

	v_clear_disp_list(hvdi);

	if (glb.print.max)
	{
		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=0;
		pxy[3]=0;
		v_bit_image(hvdi,_Fname,1,1,1,glb.print.xcenter,glb.print.ycenter,pxy);
	}
	else
	{
		if (imw<=fpw)
		{
			switch (glb.print.xcenter)
			{
				case	0:
					pxy[0]=0;
					break;
				case	1:
					pxy[0]=(fpw-imw+1)/2;
					break;
				case	2:
					pxy[0]=fpw-imw+1;
					break;
			}
			pxy[2]=pxy[0]+fpw;
		}
		else
		{
			pxy[0]=0;
			pxy[2]=fpw;
		}
		if (imh<=fph)
		{
			switch (glb.print.ycenter)
			{
				case	0:
					pxy[1]=0;
					break;
				case	1:
					pxy[1]=(fph-imh+1)/2;
					break;
				case	2:
					pxy[1]=fph-imh+1;
					break;
			}
			pxy[3]=pxy[1]+fph;
		}
		else
		{
			pxy[1]=0;
			pxy[3]=fph;
		}
		v_bit_image(hvdi,_Fname,1,0,0,0,0,pxy);
	}

	v_updwk(hvdi);
	if (glb.print.out)
		v_clrwk(hvdi);
	v_clswk(hvdi);
	Fdelete(_Fname);
	_progOff();
	STATUS='NONE';
}


/*******************************************************************************
*******************************************************************************/
int _GdosPrintInit()
{
	char		txt[32],chaine[32];
	double	w,h;
	int		work_in[11],work_out[57],extnd[57];
	int		i,j,a,vdi0,vdi1,old;
	VDIPB		*vdipb;
	int		*p;

	vdipb=(VDIPB *)&VDI_pb;
	p=(int *)vdipb->ptsout;

	old=glb.print.dev;
	glb.print.dev=-1;
	/****************************************************************************
		Fermeture VDI si une station est d‚j… ouverte
	****************************************************************************/
	if (hvdi)
		v_clswk(hvdi);

	for (i=21;i<31;i++)
	{
		for(j=0;j<10;work_in[j++]=1);
		work_in[0]=i;
		work_in[10]=2;
		hvdi=0;
		v_opnwk(work_in,&hvdi,work_out);

		if (glb.vdi.vgdos>=2)
		{
			vqt_devinfo(hvdi,i,&a,chaine);
			vdi0=p[0];
			vdi1=p[1];
		}
		else
		{
			a=1;
			vdi1=0;
			vdi0=1;
		}

		if (hvdi && a>0 && vdi1!=-1 && vdi0!=0)
		{
			if (glb.vdi.vgdos>=2)
				strncpy(chaine,(char *)&p[1],26L);
			else
				_searchDriverName(chaine,i);
			glb.rsc.head.trindex[PPRT][i-20].ob_state&=~DISABLED;
			if (glb.print.dev==-1)
				glb.print.dev=i;
			else if (i==old)
				glb.print.dev=i;
		}
		else
		{
			glb.rsc.head.trindex[PPRT][i-20].ob_state|=DISABLED;
			chaine[0]='\0';
		}
		sprintf(txt," %02i %-s",i,chaine);
		_obPutStr(glb.rsc.head.trindex[PPRT],i-20,txt);
		if (hvdi)
			v_clswk(hvdi);
	}

	if (glb.print.dev==-1)
		return 0;

	/****************************************************************************
		Ouverture station VDI
	****************************************************************************/
	for(j=0;j<10;work_in[j++]=1);
	work_in[0]=glb.print.dev;
	work_in[10]=2;
	hvdi=0;
	v_opnwk(work_in,&hvdi,work_out);
	if (!hvdi)
	{
		form_alert(1,glb.rsc.head.frstr[GDOSOPEN]);
		return 0;
	}
	vq_extnd(hvdi,1,extnd);

	/****************************************************************************
		Dimension feuille
	****************************************************************************/
	fpw=work_out[0];
	fph=work_out[1];
	fmw=work_out[3];
	fmh=work_out[4];

	w=((double)fpw+1.0)*fmw*1e-4;
	h=((double)fph+1.0)*fmh*1e-4;
	sprintf(txt,"%5lix%5li",1L+(long)fpw,1L+(long)fph);
	_obPutStr(glb.rsc.head.trindex[FPRT],FPRTFP,txt);
	sprintf(txt,"%5.2fx%5.2f",w,h);
	_obPutStr(glb.rsc.head.trindex[FPRT],FPRTFC,txt);
	w=((double)imw+1.0)*fmw*1e-4;
	h=((double)imh+1.0)*fmh*1e-4;
	sprintf(txt,"%5lix%5li",1L+(long)imw,1L+(long)imh);
	_obPutStr(glb.rsc.head.trindex[FPRT],FPRTIP,txt);
	sprintf(txt,"%5.2fx%5.2f",w,h);
	_obPutStr(glb.rsc.head.trindex[FPRT],FPRTIC,txt);

	/****************************************************************************
		Dimension feuille
	****************************************************************************/
	_initPopUp(glb.rsc.head.trindex[FPRT],FPRTDRV,PPRT,glb.print.dev-21,POP_LEFT,POP_CENTER,TRUE);

	i=_winFindId(TW_FORM,FPRT,TRUE);
	if (i!=-1)
	{
		wind_update(BEG_MCTRL);
		_winObdraw(i,glb.rsc.head.trindex[FPRT],ROOT,MAX_DEPTH,W[i].xwork,W[i].ywork,W[i].wwork,W[i].hwork);
		wind_update(END_MCTRL);
	}
	return 1;
}

static void _searchDriverName(char *chaine,int i)
{
	FILE	*ha;
	char	name[FILENAME_MAX];
	char	txt[20];
	char	id[4];
	char	*p;
	int	ok=FALSE;

	sprintf(name,"%c:\\ASSIGN.SYS",65+_getBoot());
	sprintf(id,"%02i",i);

	ha=fopen(name,"r");
	if (ha)
	{
		do
		{
			if (!fgets(txt,18,ha))
				goto fileclose;
			if (!strncmp(id,txt,2L))
			{
				chaine[0]=0;
				p=&txt[2];
				while (*p==' ')
					p++;
				while (*p!=' ' && *p!='\n' && *p!='\r' && *p!='\0')
					strncat(chaine,p++,1L);
				ok=TRUE;
			}
		}	while (!ok);
fileclose:
		fclose(ha);
	}
}
