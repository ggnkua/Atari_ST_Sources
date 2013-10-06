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

#define	RIMBUF	2048L

static int	next_rim=-1;
static int _ChooseRim(void);
static long _rimDo(int alert,int ha,long flen,int i,long ext,MFDB *img,char *txt,int *imem,int *pmem);


/*******************************************************************************
	Renvoie adresse du RIM en m‚moire
*******************************************************************************/
PARX_RIM *_rimAdr(int n)
{
	long	adr=0;
	int	i;

	if (n>=glb.parx.n_rim)
		return NULL;
	else
	{
		adr=glb.mem.adr[glb.parx.i_rim];
		for (i=0;i<n;i++)
			adr+=*(long *)adr;
	}
	return (PARX_RIM *)adr;
}

/*******************************************************************************
	Chargement d'une image
*******************************************************************************/
int _rimLoad(int alert,char *name,long *flen,MFDB *img,char *txt,int *imem,int *pmem,int n)
{
	PARX_RIM		*rim;
	long			r,ext;
	int			ret,ha,i;
	char			*p;


	if (!glb.parx.n_rim)
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[RIMNORIM]);
		sprintf(glb.div.log,"No RIM in memory\n");
		_reportLog(LOG_RIM);
		return RIM_NORIM;
	}

	if (name[0])
	{
		sprintf(glb.div.log,"RimLoad '%s'\n",name);
		_reportLog(LOG_RIM);
		ha=(int)Fopen(name,FO_READ);
		if (ha<0)
		{
			sprintf(glb.div.log,"File not found\n");
			_reportLog(LOG_RIM);
			return RIM_FILE;
		}
		*flen=Fseek(0L,ha,2);
		p=(char *)strrchr(name,'.');
		if (p)
			ext=*(long *)p;
		else
			ext=0L;

		if (alert)
			_progOn();

		if (n>0)
		{
			ext='NEXT';
			i=next_rim;
			rim=_rimAdr(i);
			if (rim->type!=RIM_DGN && rim->type!=RIM_GEN)
			{
				img->fd_w			=	1+glb.vdi.out[0];
				img->fd_h			=	1+glb.vdi.out[1];
				img->fd_wdwidth	=	_word(1+glb.vdi.out[0]);
				img->fd_stand		=	0;
				img->fd_nplanes	=	glb.vdi.extnd[4];
				r=_rimDo(alert,ha,*flen,i,ext,img,txt,imem,pmem);
			}
		}
		else
		for (i=0;i<glb.parx.n_rim;i++)
		{
			rim=_rimAdr(i);
			if (rim->type!=RIM_DGN && rim->type!=RIM_GEN)
			{
				img->fd_w			=	1+glb.vdi.out[0];
				img->fd_h			=	1+glb.vdi.out[1];
				img->fd_wdwidth	=	_word(1+glb.vdi.out[0]);
				img->fd_stand		=	0;
				img->fd_nplanes	=	glb.vdi.extnd[4];
				r=_rimDo(alert,ha,*flen,i,ext,img,txt,imem,pmem);
				if (r==3L)
					i=glb.parx.n_rim;
				else if (r==5L)
				{
					next_rim=i;
					i=glb.parx.n_rim;
				}
			}
		}
		Fclose(ha);
		if (alert)
			_progOff();
	}
	else
	{
		sprintf(glb.div.log,"RimGen\n");
		_reportLog(LOG_RIM);
		if (alert)
		{
			i=_ChooseRim();
			if (i==-1)
			{
				sprintf(glb.div.log,"User cancel\n");
				_reportLog(LOG_RIM);
				return RIM_CANCEL;
			}
		}
		else
		{
			i=glb.parx.d_rim;
			if (i==-1)
			{
				sprintf(glb.div.log,"No RIM\n");
				_reportLog(LOG_RIM);
				return RIM_NORIM;
			}
		}

		ha=0;
		*flen=0;
		ext='_RIM';

		rim=_rimAdr(i);
		img->fd_w			=	glb.vdi.wscr+1;
		img->fd_h			=	glb.vdi.hscr+1;
		img->fd_wdwidth	=	_word(img->fd_w);
		if (rim->fmt==RIM_SHI)
			img->fd_stand	=	0;
		else if (rim->fmt==RIM_VDI)
			img->fd_stand	=	1;
		img->fd_nplanes	=	glb.vdi.extnd[4];

		ret=FRIMOK;
		if (alert)
		{
			_obPutStr(glb.rsc.head.trindex[FRIM],FRIMNAME,name);

			if (rim->type==RIM_DGN)
			{
				glb.rsc.head.trindex[FRIM][FRIMPOP].ob_state&=~DISABLED;
				glb.rsc.head.trindex[FRIM][FRIMW].ob_flags|=EDITABLE;
				glb.rsc.head.trindex[FRIM][FRIMW].ob_state&=~DISABLED;
				glb.rsc.head.trindex[FRIM][FRIMH].ob_flags|=EDITABLE;
				glb.rsc.head.trindex[FRIM][FRIMH].ob_state&=~DISABLED;
			}
			else
			{
				glb.rsc.head.trindex[FRIM][FRIMPOP].ob_state|=DISABLED;
				glb.rsc.head.trindex[FRIM][FRIMW].ob_flags&=~EDITABLE;
				glb.rsc.head.trindex[FRIM][FRIMW].ob_state|=DISABLED;
				glb.rsc.head.trindex[FRIM][FRIMH].ob_flags&=~EDITABLE;
				glb.rsc.head.trindex[FRIM][FRIMH].ob_state|=DISABLED;
			}
			ret=_winForm(FRIM,glb.rsc.head.frstr[WRIM],"",-1,WIC_MOD,0,W_MODAL);
			img->fd_w			=	atoi(_obGetStr(glb.rsc.head.trindex[FRIM],FRIMW));
			img->fd_h			=	atoi(_obGetStr(glb.rsc.head.trindex[FRIM],FRIMH));
			img->fd_wdwidth	=	_word(img->fd_w);
		}

		if (ret==FRIMAN)
		{
			sprintf(glb.div.log,"User Cancel\n");
			_reportLog(LOG_RIM);
			return RIM_CANCEL;
		}
		r=_rimDo(alert,ha,*flen,i,ext,img,txt,imem,pmem);
		strcpy(name,_obGetStr(glb.rsc.head.trindex[FRIM],FRIMNAME));
	}

	if (r==3L)
	{
		sprintf(glb.div.log,"Ok\n");
		_reportLog(LOG_RIM);
		return RIM_OK;
	}
	else
	if (r==5L)
	{
		sprintf(glb.div.log,"Ok (Next)\n");
		_reportLog(LOG_RIM);
		return RIM_NEXT;
	}
	else
	{
		if (*pmem!=NO_MEMORY)
		{
			_mFree(*pmem);
			*pmem=NO_MEMORY;
		}
		if (*imem!=NO_MEMORY)
		{
			_mFree(*imem);
			*imem=NO_MEMORY;
		}
		if (alert)
			form_alert(1,glb.rsc.head.frstr[RIMERROR]);
		sprintf(glb.div.log,"Error\n");
		_reportLog(LOG_RIM);
		return RIM_ERROR;
	}
}

/***************************************************************************/
/*																									*/
/*	alert:	flag d'interactivit‚															*/
/*	ha:		handle fichier ou 0															*/
/*	flen:		taille du fichier																*/
/*	i:			num‚ro du RIM																	*/
/*	ext:		extension de l'image															*/
/*	img:		pointeur sur la mfdb de l'image											*/
/*	imem:		pointeur sur l'index memory manager des donn‚es de l'image		*/
/*	pmem:		pointeur sur l'index memory manager de la palette de l'image	*/
/*																									*/
/***************************************************************************/
long _rimDo(int alert,int ha,long flen,int i,long ext,MFDB *img,char *txt,int *imem,int *pmem)
{
	PARX_RIM		*rim;
	MF_RIM		mfdb;
	int			fmem=NO_MEMORY;
	long			adrsrc,lensrc,ncol;
	long			fadr;
	long			plen,padr;
	long			ilen,len;
	long			sk,fr,r;

	rim=_rimAdr(i);

	mfdb.w			=	img->fd_w;
	mfdb.h			=	img->fd_h;
	mfdb.wdw			=	img->fd_wdwidth;
	mfdb.stand		=	img->fd_stand;
	mfdb.nplanes	=	img->fd_nplanes;
	mfdb.seek		=	0L;
	mfdb.len			=	0L;
	mfdb.handle		=	ha;
	padr				=	0L;
	*pmem				=	NO_MEMORY;
	*imem				=	NO_MEMORY;

	if (alert)
		_prog(rim->name,glb.rsc.head.frstr[RIMTST]);

	if (ha)
	{
		fmem=_mAlloc(RIMBUF,TRUE);
		if (fmem==NO_MEMORY)
		{
			if (alert)
				form_alert(1,glb.rsc.head.frstr[RIMMEM]);
			sprintf(glb.div.log,"Not enough memory\n");
			_reportLog(LOG_RIM);
			return RIM_MEM;
		}
		sk=Fseek(0L,ha,0);
sprintf(glb.div.log,"Fseek(%li,%i,%i) return: %li\n",mfdb.seek,ha,0,sk);
_reportLog(LOG_RIM);

		fadr=glb.mem.adr[fmem];
		_cls(fadr,RIMBUF);
		len=min(flen,RIMBUF);
		if (Fread(ha,len,(void *)fadr) != len)
		{
			_mFree(fmem);
			if (alert)
				form_alert(1,glb.rsc.head.frstr[RIMFILE]);
			sprintf(glb.div.log,"Error while reading file\n");
			_reportLog(LOG_RIM);
			return RIM_FILE;
		}
		sk=Fseek(0L,ha,0);
sprintf(glb.div.log,"Fseek(%li,%i,%i) return: %li\n",mfdb.seek,ha,0,sk);
_reportLog(LOG_RIM);
	}	/* (ha) */

	mfdb.seek	=	0;
	mfdb.handle	=	ha;
	rim=_rimAdr(i);
sprintf(glb.div.log,"RIM: %s\n",rim->name);
_reportLog(LOG_RIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);
	r=(rim->TEST_FICHIER)(0,(long *)fadr,len,flen,ext,(MF_RIM *)&mfdb);
sprintf(glb.div.log,"Test_File(%i,%li,%li,%li,%4s,%li) return: %li\n",
	0,fadr,len,flen,(char *)&ext,(long)&mfdb,r);
_reportLog(LOG_RIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);

	while (r==1L)						/*	Chargement autre morceau de fichier	*/
	{
		fadr=glb.mem.adr[fmem];
		_cls(glb.mem.adr[fmem],glb.mem.len[fmem]);
		len=min(flen-Fseek(0L,ha,1),RIMBUF);
		if (Fread(ha,len,(void *)glb.mem.adr[fmem]) != len)
		{
			_mFree(fmem);
			if (alert)
				form_alert(1,glb.rsc.head.frstr[RIMFILE]);
			sprintf(glb.div.log,"Error while reading file\n");
			_reportLog(LOG_RIM);
			if (alert)
				_progOff();
			return RIM_FILE;
		}
		mfdb.seek	=	0;
		mfdb.handle	=	ha;
		rim=_rimAdr(i);
		r=(rim->TEST_FICHIER)(1,(long *)fadr,len,flen,ext,(MF_RIM *)&mfdb);
	}

	if (r==2L || r==3L)
	{

		if (mfdb.wdw!=_word(mfdb.w))
		{
sprintf(glb.div.log,"Bug in the RIM !!! bad fd_wdwidth value: %i instead %i\n",(int)mfdb.wdw,(int)((mfdb.w+15)/16));
_reportLog(LOG_RIM);
		}

		if (alert)
			_prog("@",glb.rsc.head.frstr[RIMPAL]);

		if (ha && sk!=mfdb.seek)
		{
			sk=Fseek(mfdb.seek,ha,0);
sprintf(glb.div.log,"Fseek(%li,%i,%i) return: %li\n",mfdb.seek,ha,0,sk);
_reportLog(LOG_RIM);
		}

		if (ha && mfdb.len>0 && mfdb.len<0x7FFFFFFFL && mfdb.len!=len)
		{
			if (fmem!=NO_MEMORY)
			{
				_mFree(fmem);
				fmem=NO_MEMORY;
			}
			fmem=_mAlloc(mfdb.len,TRUE);
			if (fmem==NO_MEMORY)
			{
				if (alert)
					form_alert(1,glb.rsc.head.frstr[RIMMEM]);
				sprintf(glb.div.log,"Not enough memory\n");
				_reportLog(LOG_RIM);
				if (alert)
					_progOff();
				return RIM_MEM;
			}

			fr=Fread(ha,glb.mem.len[fmem],(void *)glb.mem.adr[fmem]);
sprintf(glb.div.log,"Fread(%i,%li,%li) return: %li\n",ha,glb.mem.len[fmem],glb.mem.adr[fmem],fr);
_reportLog(LOG_RIM);
			if (fr != glb.mem.len[fmem])
			{
				_mFree(fmem);
				if (alert)
					form_alert(1,glb.rsc.head.frstr[RIMFILE]);
				sprintf(glb.div.log,"Error while reading file\n");
				_reportLog(LOG_RIM);
				if (alert)
					_progOff();
				return RIM_FILE;
			}
		}

		if (r==2L && mfdb.nplanes<=8)
		{
			ncol=1L<<mfdb.nplanes;
			plen=6L*(1L<<mfdb.nplanes);
			*pmem=_mAlloc(plen,0);
			if (*pmem!=NO_MEMORY)
				padr=glb.mem.adr[*pmem];
			else
			{
				_mFree(fmem);
				if (alert)
					form_alert(1,glb.rsc.head.frstr[RIMMEM]);
				sprintf(glb.div.log,"Not enough memory\n");
				_reportLog(LOG_RIM);
				if (alert)
					_progOff();
				return RIM_MEM;
			}
		}
		else
			ncol=padr=0L;

		if (fmem!=NO_MEMORY)
		{
			adrsrc=glb.mem.adr[fmem];
			lensrc=glb.mem.len[fmem];
		}
		else
		{
			adrsrc=0L;
			lensrc=0L;
		}

		mfdb.seek	=	Fseek(0L,ha,2);
		mfdb.handle	=	ha;
		mfdb.len		=	flen;
		rim=_rimAdr(i);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);
		r=(rim->EXTRAIT_PALETTE)(0,(long *)adrsrc,lensrc,(long *)padr,ncol,&mfdb);
sprintf(glb.div.log,"Extract_Pal(%i,%li,%li,%li,%li,%li) return: %li\n",0,adrsrc,lensrc,padr,ncol,(long)&mfdb,r);
_reportLog(LOG_RIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);

		while (r==1L)						/*	Chargement autre morceau de fichier	*/
		{
			_cls(glb.mem.adr[fmem],glb.mem.len[fmem]);
			lensrc=min(flen-Fseek(0L,ha,1),RIMBUF);
			fr=Fread(ha,lensrc,(void *)glb.mem.adr[fmem]);
sprintf(glb.div.log,"Fread(%i,%li,%li) return: %li\n",ha,lensrc,glb.mem.adr[fmem],fr);
_reportLog(LOG_RIM);
			if (fr!=lensrc)
			{
				_mFree(fmem);
				if (alert)
					form_alert(1,glb.rsc.head.frstr[RIMFILE]);
				sprintf(glb.div.log,"Error while reading file\n");
				_reportLog(LOG_RIM);
				if (alert)
					_progOff();
				return RIM_FILE;
			}
			mfdb.seek	=	Fseek(0L,ha,2);
			mfdb.handle	=	ha;
			mfdb.len		=	flen;
			rim=_rimAdr(i);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);
			r=(rim->EXTRAIT_PALETTE)(1,(long *)adrsrc,lensrc,(long *)padr,ncol,&mfdb);
sprintf(glb.div.log,"Extract_Pal(%i,%li,%li,%li,%li,%li) return: %li\n",1,adrsrc,lensrc,padr,ncol,(long)&mfdb,r);
_reportLog(LOG_RIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);
		}

		if (r!=2 && *pmem!=NO_MEMORY)
		{
			_mFree(*pmem);
			*pmem=NO_MEMORY;
		}
				
		if (fmem!=NO_MEMORY && (mfdb.len<=0 || mfdb.len>0x7FFFFFFFL || mfdb.seek!=sk || mfdb.len!=len))	/**/
		{
			_mFree(fmem);
			fmem=NO_MEMORY;
		}

		if (mfdb.wdw!=(mfdb.w+15)/16)
			ilen=2L*(long)((mfdb.w+15)/16)*(long)mfdb.h*(long)mfdb.nplanes;
		else
			ilen=2L*(long)mfdb.wdw*(long)mfdb.h*(long)mfdb.nplanes;
		*imem=_mAlloc(ilen,TRUE);			/*	Buffer pour l'image	*/

sprintf(glb.div.log,"Buffer Image: adr=%li len=%li\n",glb.mem.adr[*imem],glb.mem.len[*imem]);
_reportLog(LOG_RIM);

		if (*imem==NO_MEMORY)
		{
			if (alert)
				form_alert(1,glb.rsc.head.frstr[RIMMEM]);
			sprintf(glb.div.log,"Not enough memory\n");
			_reportLog(LOG_RIM);
			if (alert)
				_progOff();
			return RIM_MEM;
		}

		if (!mfdb.len || mfdb.len<0 || mfdb.len>0x7FFFFFFFL)
		{
			mfdb.len=flen;
			mfdb.seek=0;
		}

		if (mfdb.len>0 && mfdb.len<0x7FFFFFFFL)
		{
			fmem=_mAlloc(mfdb.len,TRUE);
			if (fmem==NO_MEMORY)
			{
				_mFree(*imem);
				if (alert)
					form_alert(1,glb.rsc.head.frstr[RIMMEM]);
				sprintf(glb.div.log,"Not enough memory\n");
				_reportLog(LOG_RIM);
				if (alert)
					_progOff();
				return RIM_MEM;
			}
		}

		if (ha && mfdb.len>0 && mfdb.len<0x7FFFFFFFL)
		{
			sk=Fseek(mfdb.seek,ha,0);
sprintf(glb.div.log,"Fseek(%li,%i,%i) return: %li\n",mfdb.seek,ha,0,sk);
_reportLog(LOG_RIM);
			lensrc=min(glb.mem.len[fmem],flen-mfdb.seek);
			adrsrc=glb.mem.adr[fmem];
			fr=Fread(ha,lensrc,(void *)glb.mem.adr[fmem]);
sprintf(glb.div.log,"Fread(%i,%li,%li) return: %li\n",ha,lensrc,glb.mem.adr[fmem],fr);
_reportLog(LOG_RIM);
			if (fr!=lensrc)
			{
				_mFree(fmem);
				_mFree(*imem);
				if (alert)
					form_alert(1,glb.rsc.head.frstr[RIMFILE]);
				sprintf(glb.div.log,"Error while reading file\n");
				_reportLog(LOG_RIM);
				if (alert)
					_progOff();
				return RIM_FILE;
			}
		}
		else
			adrsrc=lensrc=0L;

		if (fmem!=NO_MEMORY)
		{
			adrsrc=glb.mem.adr[fmem];
			lensrc=glb.mem.len[fmem];
		}
		else
		{
			adrsrc=0L;
			lensrc=0L;
		}

		if (alert)
			_prog("@",glb.rsc.head.frstr[RIMIMG]);
		mfdb.seek=glb.mem.adr[*imem];
		mfdb.len=0L;
		mfdb.handle=ha;
		rim=_rimAdr(i);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);
		r=(int)(rim->TRAITE_FICHIER)(0,(long *)adrsrc,lensrc,(MF_RIM *)&mfdb);
sprintf(glb.div.log,"Extract_File(%i,%li,%li,%li) return: %li\n",0,adrsrc,lensrc,(long)&mfdb,r);
_reportLog(LOG_RIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);

		while (r==1L)						/*	Chargement autre morceau de fichier	*/
		{
			lensrc=min(fmem,flen-Fseek(0L,ha,1));
			_cls(glb.mem.adr[fmem],glb.mem.len[fmem]);
			fr=Fread(ha,lensrc,(void *)glb.mem.adr[fmem]);
sprintf(glb.div.log,"Fread(%i,%li,%li) return: %li\n",ha,lensrc,glb.mem.adr[fmem],fr);
_reportLog(LOG_RIM);
			if (fr!=lensrc)
			{
				_mFree(fmem);
				_mFree(*imem);
				if (alert)
					form_alert(1,glb.rsc.head.frstr[RIMFILE]);
				sprintf(glb.div.log,"Error while reading file\n");
				_reportLog(LOG_RIM);
				if (alert)
					_progOff();
				return RIM_FILE;
			}
			mfdb.handle=ha;
			rim=_rimAdr(i);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);
			r=(int)(rim->TRAITE_FICHIER)(1,(long *)glb.mem.adr[fmem],lensrc,(MF_RIM *)&mfdb);
sprintf(glb.div.log,"Extract_File(%i,%li,%li,%li) return: %li\n",1,glb.mem.adr[fmem],lensrc,(long)&mfdb,r);
_reportLog(LOG_RIM);
sprintf(glb.div.log,"seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i len=%li ha=%i\n",
	mfdb.seek,mfdb.w,mfdb.h,mfdb.wdw,mfdb.stand,mfdb.nplanes,mfdb.len,mfdb.handle);
_reportLog(LOG_RIM);
		}

		if (r==3L || r==5L)
		{
			img->fd_w			=	mfdb.w;
			img->fd_wdwidth	=	_word(img->fd_w);
			img->fd_h			=	mfdb.h;
			img->fd_stand		=	mfdb.stand;
			img->fd_nplanes	=	mfdb.nplanes;
			strcpy(txt,rim->name);
		}
	}
	if (fmem!=NO_MEMORY)
	{
		_mFree(fmem);
		fmem=NO_MEMORY;
	}
	return r;
}


static int _ChooseRim()
{
	OBJECT	*tree=glb.rsc.head.trindex[FME];
	int		r;

	_initPopUp(tree,FMEMOD,PME1,0,POP_LEFT,POP_CENTER,TRUE);
	tree[FMEMOD].ob_state|=DISABLED;
	_initPopUp(tree,FMETYP,PME2,PME2GEN-1,POP_LEFT,POP_CENTER,TRUE);
	tree[FMETYP].ob_state|=DISABLED;
	glb.parx.setmod=0;
	glb.parx.setdef=-1;
	_setmodparam();

	r=_winForm(FME,glb.rsc.head.frstr[WME],"",-1,WIC_MOD,0,W_MODAL);

	if (r==FMEAN)
		return -1;
	else
		return glb.parx.d_rim;
}
