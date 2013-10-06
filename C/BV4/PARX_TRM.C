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

static void _trmAlert(long err);
static int _trmSrcPal(int *i,int planes);
static int _trmDstPal(int isrc,int psrc,int *idst,int pdst,int mask);
static int _trmFormat(int i,int *j,MFDB *src,int newfmt,int nforce);


/*******************************************************************************
	Initialisation du TRM
*******************************************************************************/
int _trmInit(void)
{
	PARX_TRM *head;
	int		masque;

	if (glb.parx.i_trm!=NO_MEMORY)
	{
		if (glb.opt.gfx)
			masque=TRM_OTHER_CARD;
		else
			masque=TRM_ATARI_CARD;
		head=(PARX_TRM *)(glb.mem.adr[glb.parx.i_trm]);
		return (int)(head->trm_call)(TRM_INIT,masque,0L,0L,0L,0L,0L,0);
	}
	return 1;
}


/*******************************************************************************
	Sortie du TRM
*******************************************************************************/
int _trmExit(void)
{
	PARX_TRM *head;

	if (glb.parx.i_trm!=NO_MEMORY)
	{
		head=(PARX_TRM *)(glb.mem.adr[glb.parx.i_trm]);
		return (int)(head->trm_call)(TRM_END,0,0L,0L,0L,0L,0L,0);
	}
	return 1;
}


/*******************************************************************************
	Conversion

		alert	flag (0/1) form_alert en cas d'erreur
		isrc	index MEM de l'image source
		*idst	index MEM de l'image convertie (NO_MEMORY au dÇpart)
		psrc	index MEM de la palette de l'image source
		*pdst	index MEM de la palette de l'image source (NO_MEMORY)
		src	MFDB de l'image source
		dst	MFDB de l'image destination
		mask	type de carte video
		dith	Numero de tramage
*******************************************************************************/
int _trmConvert(int alert,int isrc,int *idst,int psrc,int *pdst,MFDB *msrc,MFDB *dst,int mask,int dith,int nforce)
{
	PARX_TRM		*head;
	MFDB			src;
	long			r,palsrc,paldst,tmp;
	int			src_flag,dst_flag,oldpsrc=psrc;
	long			ltmp,ltrm;
	int			itmp,itrm;
	int			dum,ioldsrc=isrc;

	if (nforce)
		mask|=TRM_FORCE;
	else
		mask&=~TRM_FORCE;

	src.fd_addr		=	msrc->fd_addr;
	src.fd_w			=	msrc->fd_w;
	src.fd_wdwidth	=	msrc->fd_wdwidth;
	src.fd_h			=	msrc->fd_h;
	src.fd_stand	=	msrc->fd_stand;
	src.fd_nplanes	=	msrc->fd_nplanes;

	sprintf(glb.div.log,"TrmConvert\n");
	_reportLog(LOG_TRM);

	if (glb.parx.i_trm==NO_MEMORY)				/*	Pas de TRM						*/
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRMNOTRM]);
		sprintf(glb.div.log,"No TRM in memory\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;
	}

	if (!_trmSrcPal(&psrc,src.fd_nplanes))	/*	Palette source					*/
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRMSRCPAL]);
		if (oldpsrc!=psrc)
			_mFree(psrc);
		sprintf(glb.div.log,"Error with source pal\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;
	}

	if (!_trmDstPal(psrc,src.fd_nplanes,pdst,dst->fd_nplanes,mask))
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRMDSTPAL]);
		if (oldpsrc!=psrc)
			_mFree(psrc);
		sprintf(glb.div.log,"Error with dest pal\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;							/*	Palette destination (temp)	*/
	}

	if (psrc==NO_MEMORY)								/*	Adresse palette source pour*/
		palsrc=0L;										/*	le TRM							*/
	else
		palsrc=glb.mem.adr[psrc];

	if (*pdst==NO_MEMORY)							/*	Adresse palette destination*/
		paldst=0L;										/*	pour le TRM						*/
	else
		paldst=glb.mem.adr[*pdst];

	src_flag=src.fd_stand;							/*	Format actuel de la source	*/
	dst_flag=dst->fd_stand;							/*	Format voule de la dest.	*/
	src.fd_addr=(void *)glb.mem.adr[isrc];	/*	Adresse image source			*/
	dst->fd_addr=0;									/*	Adresse image destination	*/

sprintf(glb.div.log,"SRC: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)src.fd_addr,src.fd_w,src.fd_h,src.fd_wdwidth,src.fd_stand,src.fd_nplanes);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"DST: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst->fd_addr,dst->fd_w,dst->fd_h,dst->fd_wdwidth,dst->fd_stand,dst->fd_nplanes);
_reportLog(LOG_TRM);

	head=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
	r=(head->trm_call)(TRM_INQUIRE,dith,0L,&src,(long *)palsrc,dst,(long *)paldst,mask);

sprintf(glb.div.log,"Trm_Call(%li)(%i,%i,%li,%li,%li,%li,%li,%i) return: %li\n",(long)head,TRM_INQUIRE,dith,0L,(long)&src,palsrc,(long)dst,paldst,mask,r);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"SRC: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)src.fd_addr,src.fd_w,src.fd_h,src.fd_wdwidth,src.fd_stand,src.fd_nplanes);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"DST: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst->fd_addr,dst->fd_w,dst->fd_h,dst->fd_wdwidth,dst->fd_stand,dst->fd_nplanes);
_reportLog(LOG_TRM);

	if (r<0)												/*	1er appel foireux				*/
	{
		if (alert)
			_trmAlert(r);
		if (oldpsrc!=psrc)
			_mFree(psrc);
		sprintf(glb.div.log,"Error while working (1): %li\n",r);
		_reportLog(LOG_TRM);
		return TRM_MINE;
	}

	dum=src_flag;
	src_flag=src.fd_stand;
	src.fd_stand=dum;

	ioldsrc=isrc;
	if (!_trmFormat(isrc,&dum,&src,src_flag,nforce))	/*	Conversion format source	*/
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRM1STFMT]);
		if (oldpsrc!=psrc)
			_mFree(psrc);
		sprintf(glb.div.log,"Error while converting (1)\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;							/*	-> format voulue par TRM	*/
	}
	isrc=dum;

	itmp=NO_MEMORY;									/*	Index mem bloc temporaire	*/
	ltmp=0L;												/*	Longueur bloc temporaire	*/
	tmp=0L;												/*	Adresse bloc temporaire		*/
	if (r>0)
	{
		if (r==0x7FFFFFFFL)							/*	Max size - destination len	*/
			ltmp=(*manag_size)()-(long)dst->fd_wdwidth*2L*dst->fd_h*(long)dst->fd_nplanes;
		else
			ltmp=r;										/*	Taille prÇcisÇe par TRM		*/
		itmp=_mAlloc(ltmp,0);
		if (itmp==NO_MEMORY)
		{
			if (alert)
				form_alert(1,glb.rsc.head.frstr[TRMTMPMEM]);
			if (isrc!=ioldsrc)
				_mFree(isrc);
			if (oldpsrc!=psrc)
				_mFree(psrc);
			sprintf(glb.div.log,"Not enough memory\n");
			_reportLog(LOG_TRM);
			return TRM_MINE;						/*	Buffer temporaire foireux	*/
		}
/*		if (r==0x7FFFFFFFL)		*/					/*	Taille du bloc temporaire	*/
/*			*(long *)(glb.mem.adr[itmp])=ltmp;*/
	}

	if (nforce)
		dst->fd_addr=0;

	if (src.fd_addr==dst->fd_addr)				/*	On trame sur la source		*/
	{
		ltrm=(long)dst->fd_wdwidth*2L*dst->fd_h*(long)dst->fd_nplanes;
		if (ltrm>glb.mem.len[isrc])
			_mDim(isrc,ltrm,0,-1L);
		if (ltrm>glb.mem.len[isrc])				/*	Agrandissement foireux		*/
		{
			if (alert)
				form_alert(1,glb.rsc.head.frstr[TRMSRCMEM]);
			if (isrc!=ioldsrc)
				_mFree(isrc);
			if (itmp!=NO_MEMORY)
				_mFree(itmp);
			if (oldpsrc!=psrc)
				_mFree(psrc);
			sprintf(glb.div.log,"Not enough memory\n");
			_reportLog(LOG_TRM);
			return TRM_MINE;
		}
		dst->fd_addr=(void *)glb.mem.adr[isrc];
	}
	else
	{
		ltrm=(long)dst->fd_wdwidth*2L*dst->fd_h*(long)dst->fd_nplanes;
		itrm=_mAlloc(ltrm,0);
		if (itrm==NO_MEMORY)							/*	Allocation dest. foireuse	*/
		{
			if (alert)
				form_alert(1,glb.rsc.head.frstr[TRM2NDMEM]);
			if (isrc!=ioldsrc)
				_mFree(isrc);
			if (itmp!=NO_MEMORY)
				_mFree(itmp);
			if (oldpsrc!=psrc)
				_mFree(psrc);
			sprintf(glb.div.log,"Not enough memory\n");
			_reportLog(LOG_TRM);
			return TRM_MINE;
		}
		dst->fd_addr=(void *)glb.mem.adr[itrm];
	}
	src.fd_addr=(void *)glb.mem.adr[isrc];	/*	Adresse source					*/
	if (itmp!=NO_MEMORY)
		tmp=glb.mem.adr[itmp];						/*	Adresse bloc temporaire		*/
	if (psrc==NO_MEMORY)								/*	Adresse palette source pour*/
		palsrc=0L;										/*	le TRM							*/
	else
		palsrc=glb.mem.adr[psrc];

	if (*pdst==NO_MEMORY)							/*	Adresse palette destination*/
		paldst=0L;										/*	pour le TRM						*/
	else
		paldst=glb.mem.adr[*pdst];

	if (alert)
		_progOn();
	if (alert)
		_prog(glb.rsc.head.frstr[TRMINF],(char *)(glb.mem.adr[glb.parx.i_trm]+sizeof(PARX_TRM)+32L*(long)(dith-1)));


sprintf(glb.div.log,"SRC: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)src.fd_addr,src.fd_w,src.fd_h,src.fd_wdwidth,src.fd_stand,src.fd_nplanes);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"DST: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst->fd_addr,dst->fd_w,dst->fd_h,dst->fd_wdwidth,dst->fd_stand,dst->fd_nplanes);
_reportLog(LOG_TRM);

	head=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
	r=(head->trm_call)(TRM_DO,dith,(long *)tmp,&src,(long *)palsrc,dst,(long *)paldst,mask);

sprintf(glb.div.log,"Trm_Call(%li)(%i,%i,%li,%li,%li,%li,%li,%i) return: %li\n",(long)head,TRM_DO,dith,tmp,(long)&src,palsrc,(long)dst,paldst,mask,r);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"SRC: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)src.fd_addr,src.fd_w,src.fd_h,src.fd_wdwidth,src.fd_stand,src.fd_nplanes);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"DST: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst->fd_addr,dst->fd_w,dst->fd_h,dst->fd_wdwidth,dst->fd_stand,dst->fd_nplanes);
_reportLog(LOG_TRM);


	if (alert)
		_progOff();

	if (r<0)												/*	2nd appel foireux				*/
	{
		if (alert)
			_trmAlert(r);
		if (itmp!=NO_MEMORY)
			_mFree(itmp);
		if (isrc!=ioldsrc)
			_mFree(isrc);
		if (oldpsrc!=psrc)
			_mFree(psrc);
		sprintf(glb.div.log,"Error while working (2): %li\n",r);
		_reportLog(LOG_TRM);
		return TRM_MINE;
	}

	if (src.fd_addr==dst->fd_addr)				/*	On trame sur la source		*/
	{
		if (ltrm<glb.mem.len[isrc])				/*	Diminue la source si l'img	*/
			_mDim(isrc,ltrm,0,-1L);					/*	tramÇe est plus petite		*/
		*idst=isrc;
	}
	else
	{
		if (isrc!=ioldsrc)
			_mFree(isrc);
		*idst=itrm;
	}

	if (!_trmFormat(*idst,&dum,dst,dst_flag,0))/*	Conversion format out TRM	*/
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRM2NDFMT]);
		if (itmp!=NO_MEMORY)
			_mFree(itmp);
		if (oldpsrc!=psrc)
			_mFree(psrc);
		sprintf(glb.div.log,"Error while converting (2)\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;							/*	-> format voulu				*/
	}
	if (itmp!=NO_MEMORY)
		_mFree(itmp);
	*idst=dum;

	sprintf(glb.div.log,"\n");
	_reportLog(LOG_TRM);
	if (oldpsrc!=psrc)
		_mFree(psrc);
	return TRM_OK;
}

/*******************************************************************************
	Copie la palette systäme si une image n'a pas de palette
*******************************************************************************/
void _trmAlert(long err)
{
	int	n=0;

	switch ((int)err)
	{
		case	TRM_ERR_RSVD19:	n=TRM19;	break;
		case	TRM_ERR_RSVD18:	n=TRM18;	break;
		case	TRM_ERR_RSVD17:	n=TRM17;	break;
		case	TRM_ERR_RSVD16:	n=TRM16;	break;
		case	TRM_ERR_RSVD15:	n=TRM15;	break;
		case	TRM_INIT:			n=TRM12;	break;
		case	TRM_ZM_PLAN:		n=TRM11;	break;
		case	TRM_DMFDB_NUL:		n=TRM10;	break;
		case	TRM_DMFDB_PLAN:	n=TRM09;	break;
		case	TRM_DMFDB_BAD:		n=TRM08;	break;
		case	TRM_DMFDB_ADR:		n=TRM07;	break;
		case	TRM_SMFDB_NUL:		n=TRM06;	break;
		case	TRM_SMFDB_PLAN:	n=TRM05;	break;
		case	TRM_SMFDB_BAD:		n=TRM04;	break;
		case	TRM_SMFDB_ADR:		n=TRM03;	break;
		case	TRM_CALL:			n=TRM01;	break;
	}
	if (n)
		form_alert(1,glb.rsc.head.frstr[n]);
}

/*******************************************************************************
	Copie la palette systäme si une image n'a pas de palette
*******************************************************************************/
static int _trmSrcPal(int *i,int planes)
{
	int		a,num,*p,*q;
	PARX_TRM *head;

sprintf(glb.div.log,"trmsrcpal|out_mem=%i planes=%i\n",*i,planes);
_reportLog(LOG_TRM);

	head=(PARX_TRM *)(glb.mem.adr[glb.parx.i_trm]);

	if (*i==NO_MEMORY && planes<15)
	{
		switch (planes)
		{
			case 1:
				p=(int *)head->pal1;
				num=3*2;
				break;
			case 2:
				p=(int *)head->pal2;
				num=3*4;
				break;
			case 4:
				p=(int *)head->pal4;
				num=3*16;
				break;
			case 8:
				p=(int *)head->pal8;
				num=3*256;
				break;
		}

		*i=_mAlloc(2L*(long)num,0);
		if (*i!=NO_MEMORY)
		{
			q=(int *)glb.mem.adr[*i];
			for (a=0;a<num;a++)
				*q++=*p++;
		}
		else
			return 0;
	}
	return 1;
}


/*******************************************************************************
	Copie la palette source sur la palette destination
*******************************************************************************/
static int _trmDstPal(int isrc,int psrc,int *idst,int pdst,int mask)
{
	long		num;
	PARX_TRM *head;

sprintf(glb.div.log,"trmdstpal|isrc=%i psrc=%i idst=%i pdst=%i mask=%i\n",
	isrc,psrc,*idst,pdst,mask);
_reportLog(LOG_TRM);

	head=(PARX_TRM *)(glb.mem.adr[glb.parx.i_trm]);

	if (*idst==NO_MEMORY && pdst<15)
	{
		if (psrc==pdst && mask&TRM_SUGG_PAL)
		{
			num=6L*(1L<<psrc);
			*idst=_mAlloc(num,0);
			if (*idst!=NO_MEMORY)
			{
				_bmove(glb.mem.adr[isrc],glb.mem.adr[*idst],num);
				return 1;
			}
		}
		else
			switch (pdst)
			{
				case 1:
					num=6L*2L;
					*idst=_mAlloc(num,0);
					if (*idst!=NO_MEMORY)
					{
						_bmove((long)head->pal1,glb.mem.adr[*idst],num);
						return 1;
					}
					break;
				case 2:
					num=6L*4L;
					*idst=_mAlloc(num,0);
					if (*idst!=NO_MEMORY)
					{
						_bmove((long)head->pal2,glb.mem.adr[*idst],num);
						return 1;
					}
					break;
				case 4:
					num=6L*16L;
					*idst=_mAlloc(num,0);
					if (*idst!=NO_MEMORY)
					{
						_bmove((long)head->pal4,glb.mem.adr[*idst],num);
						return 1;
					}
					break;
				case 8:
					num=6L*256L;
					*idst=_mAlloc(num,0);
					if (*idst!=NO_MEMORY)
					{
						_bmove((long)head->pal8,glb.mem.adr[*idst],num);
						return 1;
					}
					break;
			}
		return 0;
	}
	return 1;
}


/*******************************************************************************
	Change le format d'image
*******************************************************************************/
static int _trmFormat(int i,int *j,MFDB *src,int newfmt,int nforce)
{
	MFDB	swp;
	long	lswp;
	int	iswp;

sprintf(glb.div.log,"trmfmt|in_mem=%i out_mem=%i format=%i force=%i\n",i,*j,newfmt,nforce);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"trmfmt|MFDB: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)src->fd_addr,src->fd_w,src->fd_h,src->fd_wdwidth,src->fd_stand,src->fd_nplanes);
_reportLog(LOG_TRM);
	if (newfmt!=src->fd_stand)
	{
		swp.fd_w			=	src->fd_w;
		swp.fd_h			=	src->fd_h;
		swp.fd_wdwidth	=	src->fd_wdwidth;
		swp.fd_stand	=	newfmt;
		swp.fd_nplanes	=	src->fd_nplanes;
		lswp=(long)swp.fd_wdwidth*2L*swp.fd_h*(long)swp.fd_nplanes;
		iswp=_mAlloc(lswp,0);
		if (iswp==NO_MEMORY)
		{
sprintf(glb.div.log,"trmfmt|Error!\n");
_reportLog(LOG_TRM);
			return 0;
		}

		swp.fd_addr		=	(void *)glb.mem.adr[iswp];
		src->fd_addr	=	(void *)glb.mem.adr[i];

		vr_trnfm(glb.vdi.ha,src,(MFDB *)&swp);
		if (!nforce)
			_mFree(i);
		*j=iswp;
		src->fd_addr=	(void *)glb.mem.adr[iswp];
		src->fd_stand=newfmt;
	}
	else
		*j=i;

sprintf(glb.div.log,"trmfmt|in_mem=%i out_mem=%i\n",i,*j);
_reportLog(LOG_TRM);

	return 1;
}

int _trmZoom(int alert,int isrc,int *idst,int psrc,int *pdst,MFDB *msrc,MFDB *dst,int mask,int dith,int nforce)
{
	PARX_TRM		*head;
	MFDB			src;
	long			r,palsrc,paldst,tmp;
	int			src_flag,dst_flag;
	long			ltmp,ltrm;
	int			itmp,itrm;
	int			dum,ioldsrc=isrc;

	if (nforce)
		mask|=TRM_FORCE;
	else
		mask&=~TRM_FORCE;

	src.fd_addr		=	msrc->fd_addr;
	src.fd_w			=	msrc->fd_w;
	src.fd_wdwidth	=	msrc->fd_wdwidth;
	src.fd_h			=	msrc->fd_h;
	src.fd_stand	=	msrc->fd_stand;
	src.fd_nplanes	=	msrc->fd_nplanes;

	sprintf(glb.div.log,"TrmZoom\n");
	_reportLog(LOG_TRM);
	sprintf(glb.div.log,"W=%i WDW=%i H=%i STD=%i PLANES=%i\n",src.fd_w,src.fd_wdwidth,src.fd_h,src.fd_stand,src.fd_nplanes);
	_reportLog(LOG_TRM);
	sprintf(glb.div.log,"W=%i WDW=%i H=%i STD=%i PLANES=%i\n",dst->fd_w,dst->fd_wdwidth,dst->fd_h,dst->fd_stand,dst->fd_nplanes);
	_reportLog(LOG_TRM);

	head=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
	if (head->ver<212)
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRMNOZM]);
		sprintf(glb.div.log,"TRM too old to resize image\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;
	}

	if (glb.parx.i_trm==NO_MEMORY)				/*	Pas de TRM						*/
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRMNOTRM]);
		sprintf(glb.div.log,"No TRM in memory\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;
	}

	if (!_trmSrcPal(&psrc,src.fd_nplanes))	/*	Palette source					*/
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRMSRCPAL]);
		sprintf(glb.div.log,"Error with source pal\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;
	}

	if (!_trmDstPal(psrc,src.fd_nplanes,pdst,dst->fd_nplanes,mask))
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRMDSTPAL]);
		sprintf(glb.div.log,"Error with dest pal\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;							/*	Palette destination (temp)	*/
	}

	if (psrc==NO_MEMORY)								/*	Adresse palette source pour*/
		palsrc=0L;										/*	le TRM							*/
	else
		palsrc=glb.mem.adr[psrc];

	if (*pdst==NO_MEMORY)							/*	Adresse palette destination*/
		paldst=0L;										/*	pour le TRM						*/
	else
		paldst=glb.mem.adr[*pdst];

	src_flag=src.fd_stand;							/*	Format actuel de la source	*/
	dst_flag=dst->fd_stand;							/*	Format voule de la dest.	*/
	src.fd_addr=(void *)glb.mem.adr[isrc];		/*	Adresse image source			*/
	dst->fd_addr=0;									/*	Adresse image destination	*/

sprintf(glb.div.log,"SRC: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)src.fd_addr,src.fd_w,src.fd_h,src.fd_wdwidth,src.fd_stand,src.fd_nplanes);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"DST: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst->fd_addr,dst->fd_w,dst->fd_h,dst->fd_wdwidth,dst->fd_stand,dst->fd_nplanes);
_reportLog(LOG_TRM);

	head=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
	r=(head->trm_call)(TRM_IN_ZOOM,0,0L,&src,(long *)palsrc,dst,(long *)paldst,mask);

/*
_wimSave(TRUE,&src,isrc,0,0,FALSE,glb.opt.pat[0],"ZOOM01",glb.rsc.head.frstr[TFSELSAVE]);
*/

sprintf(glb.div.log,"Trm_Call(%li)(%i,%i,%li,%li,%li,%li,%li,%i) return: %li\n",(long)head,TRM_IN_ZOOM,dith,0L,(long)&src,palsrc,(long)dst,paldst,mask,r);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"SRC: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)src.fd_addr,src.fd_w,src.fd_h,src.fd_wdwidth,src.fd_stand,src.fd_nplanes);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"DST: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst->fd_addr,dst->fd_w,dst->fd_h,dst->fd_wdwidth,dst->fd_stand,dst->fd_nplanes);
_reportLog(LOG_TRM);

	if (r<0)												/*	1er appel foireux				*/
	{
		if (alert)
			_trmAlert(r);
		sprintf(glb.div.log,"Error while working (1): %li\n",r);
		_reportLog(LOG_TRM);
		return TRM_MINE;
	}

	dum=src_flag;
	src_flag=src.fd_stand;
	src.fd_stand=dum;

	dum=NO_MEMORY;
	ioldsrc=isrc;
	if (!_trmFormat(isrc,&dum,&src,src_flag,nforce))	/*	Conversion format source	*/
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRM1STFMT]);
		sprintf(glb.div.log,"Error while converting (1)\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;							/*	-> format voulue par TRM	*/
	}
	isrc=dum;

	itmp=NO_MEMORY;									/*	Index mem bloc temporaire	*/
	ltmp=0L;												/*	Longueur bloc temporaire	*/
	tmp=0L;												/*	Adresse bloc temporaire		*/
	if (r>0)
	{
		if (r==0x7FFFFFFFL)							/*	Max size - destination len	*/
			ltmp=(*manag_size)()-(long)dst->fd_wdwidth*2L*dst->fd_h*(long)dst->fd_nplanes;
		else
			ltmp=r;										/*	Taille prÇcisÇe par TRM		*/
		itmp=_mAlloc(ltmp,0);
		if (itmp==NO_MEMORY)
		{
			if (alert)
				form_alert(1,glb.rsc.head.frstr[TRMTMPMEM]);
			if (isrc!=ioldsrc)
				_mFree(isrc);
			sprintf(glb.div.log,"Not enough memory\n");
			_reportLog(LOG_TRM);
			return TRM_MINE;						/*	Buffer temporaire foireux	*/
		}
	/*	if (r==0x7FFFFFFFL)		*/					/*	Taille du bloc temporaire	*/
	/*		*(long *)(glb.mem.adr[itmp])=ltmp;*/
	}

	if (nforce)
		dst->fd_addr=0;

	if (src.fd_addr==dst->fd_addr)				/*	On trame sur la source		*/
	{
		ltrm=(long)dst->fd_wdwidth*2L*dst->fd_h*(long)dst->fd_nplanes;
		if (ltrm>glb.mem.len[isrc])
			_mDim(isrc,ltrm,0,-1L);
		if (ltrm>glb.mem.len[isrc])				/*	Agrandissement foireux		*/
		{
			if (alert)
				form_alert(1,glb.rsc.head.frstr[TRMSRCMEM]);
			if (isrc!=ioldsrc)
				_mFree(isrc);
			if (itmp!=NO_MEMORY)
				_mFree(itmp);
			sprintf(glb.div.log,"Not enough memory\n");
			_reportLog(LOG_TRM);
			return TRM_MINE;
		}
		dst->fd_addr=(void *)glb.mem.adr[isrc];
	}
	else
	{
		ltrm=(long)dst->fd_wdwidth*2L*dst->fd_h*(long)dst->fd_nplanes;
		itrm=_mAlloc(ltrm,0);
		if (itrm==NO_MEMORY)							/*	Allocation dest. foireuse	*/
		{
			if (alert)
				form_alert(1,glb.rsc.head.frstr[TRM2NDMEM]);
			if (isrc!=ioldsrc)
				_mFree(isrc);
			if (itmp!=NO_MEMORY)
				_mFree(itmp);
			sprintf(glb.div.log,"Not enough memory\n");
			_reportLog(LOG_TRM);
			return TRM_MINE;
		}
		dst->fd_addr=(void *)glb.mem.adr[itrm];
	}
	src.fd_addr=(void *)glb.mem.adr[isrc];	/*	Adresse source					*/
	if (itmp!=NO_MEMORY)
		tmp=glb.mem.adr[itmp];						/*	Adresse bloc temporaire		*/
	if (psrc==NO_MEMORY)								/*	Adresse palette source pour*/
		palsrc=0L;										/*	le TRM							*/
	else
		palsrc=glb.mem.adr[psrc];

	if (*pdst==NO_MEMORY)							/*	Adresse palette destination*/
		paldst=0L;										/*	pour le TRM						*/
	else
		paldst=glb.mem.adr[*pdst];

	if (alert)
		_progOn();
	head=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
	if (alert)
		_prog(glb.rsc.head.frstr[TRMZOOM],"");

sprintf(glb.div.log,"SRC: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)src.fd_addr,src.fd_w,src.fd_h,src.fd_wdwidth,src.fd_stand,src.fd_nplanes);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"DST: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst->fd_addr,dst->fd_w,dst->fd_h,dst->fd_wdwidth,dst->fd_stand,dst->fd_nplanes);
_reportLog(LOG_TRM);

	head=(PARX_TRM *)glb.mem.adr[glb.parx.i_trm];
	r=(head->trm_call)(TRM_DO_ZOOM,0,(long *)tmp,&src,(long *)palsrc,dst,(long *)paldst,mask);

/*
if (src.fd_addr==dst->fd_addr)
	_wimSave(TRUE,dst,isrc,0,0,FALSE,glb.opt.pat[0],"ZOOM02",glb.rsc.head.frstr[TFSELSAVE]);
else
	_wimSave(TRUE,dst,itrm,0,0,FALSE,glb.opt.pat[0],"ZOOM02",glb.rsc.head.frstr[TFSELSAVE]);
*/

sprintf(glb.div.log,"Trm_Call(%li)(%i,%i,%li,%li,%li,%li,%li,%i) return: %li\n",(long)head,TRM_DO_ZOOM,dith,tmp,(long)&src,palsrc,(long)dst,paldst,mask,r);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"SRC: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)src.fd_addr,src.fd_w,src.fd_h,src.fd_wdwidth,src.fd_stand,src.fd_nplanes);
_reportLog(LOG_TRM);
sprintf(glb.div.log,"DST: seek=%li w=%i h=%i wdw=%i stnd=%i nplanes=%i\n",
	(long)dst->fd_addr,dst->fd_w,dst->fd_h,dst->fd_wdwidth,dst->fd_stand,dst->fd_nplanes);
_reportLog(LOG_TRM);

	if (alert)
		_progOff();

	if (r<0)												/*	2nd appel foireux				*/
	{
		if (alert)
			_trmAlert(r);
		if (itmp!=NO_MEMORY)
			_mFree(itmp);
		if (isrc!=ioldsrc)
			_mFree(isrc);
		sprintf(glb.div.log,"Error while working (2): %li\n",r);
		_reportLog(LOG_TRM);
		return TRM_MINE;
	}

	if (src.fd_addr==dst->fd_addr)				/*	On trame sur la source		*/
	{
		if (ltrm<glb.mem.len[isrc])				/*	Diminue la source si l'img	*/
			_mDim(isrc,ltrm,0,-1L);					/*	tramÇe est plus petite		*/
		*idst=isrc;
	}
	else
	{
		if (isrc!=ioldsrc)
			_mFree(isrc);
		*idst=itrm;
	}

	dum=NO_MEMORY;
	if (!_trmFormat(*idst,&dum,dst,dst_flag,0))/*	Conversion format out TRM	*/
	{
		if (alert)
			form_alert(1,glb.rsc.head.frstr[TRM2NDFMT]);
		if (itmp!=NO_MEMORY)
			_mFree(itmp);
		sprintf(glb.div.log,"Error while converting (2)\n");
		_reportLog(LOG_TRM);
		return TRM_MINE;							/*	-> format voulu				*/
	}
	if (itmp!=NO_MEMORY)
		_mFree(itmp);
	*idst=dum;

	sprintf(glb.div.log,"\n");
	_reportLog(LOG_TRM);
	return TRM_OK;
}
