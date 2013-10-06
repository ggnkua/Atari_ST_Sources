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
static int		Balaie_Path(char *directory,int wx,int wy,int ww,int wh);
static void		affiche(char *nom,int wx,int wy,int ww,int wh);


/*******************************************************************************
	VARIABLES
*******************************************************************************/
static int	num,shift;
static long	t1,t2;


/*******************************************************************************
*******************************************************************************/
void slideshow()
{
	VEIL				*tv;
	LEDP				*led;
	int				i,j,k,l;
	typedef int		t_rgb[3];
	t_rgb				*col;
	int				pal;
	long				len;
	int				wha,wx,wy,ww,wh;

	wind_update(BEG_MCTRL);
	graf_mouse(M_OFF,NULL);
	time(&t2);
	shift=(int)Kbshift(-1);

	if (glb.opt.deskfull)
	{
		wx=glb.aes.desk.x;		wy=glb.aes.desk.y;
		ww=glb.aes.desk.w;		wh=glb.aes.desk.h;
	}
	else
	{
		wx=0;							wy=0;
		ww=1+glb.vdi.wscr;		wh=1+glb.vdi.hscr;
	}
	wha=wind_create(0,0,0,1+glb.vdi.wscr,1+glb.vdi.hscr);
	if (wha<=0)
	{
		form_alert(1,glb.rsc.head.frstr[NOWIN]);
		graf_mouse(M_ON,NULL);
		graf_mouse(ARROW,NULL);
		wind_update(END_MCTRL);
		return;
	}

	_menuBar(glb.aes.tree.menu,FALSE);

	wind_open(wha,wx,wy,ww,wh);
	wind_get(wha,WF_CURRXYWH,&wx,&wy,&ww,&wh);

	if (glb.opt.is_tv && glb.opt.sl_tv)
	{
		tv=(VEIL *)_cookie('VeiL');
		j=(int)tv->stop;
		tv->stop=0xFF;
	}
	if (glb.opt.is_led && glb.opt.sl_led)
	{
		led=(LEDP *)_cookie('LEDP');
		k=led->active;
		led->active&=~1;
	}

	len=(long)glb.vdi.out[13]*(long)sizeof(t_rgb);
	pal=_mAlloc(len,FALSE);
	glb.opt.mask=0;
	if (pal!=NO_MEMORY)
	{
		col=(t_rgb *)glb.mem.adr[pal];
		for (i=0;i<glb.vdi.out[13];i++)
			vq_color(glb.vdi.ha,i,1,(int *)col[i]);
	}

	glb.div.slide=TRUE;

	l=Balaie_Path(glb.opt.sl_path,wx,wy,ww,wh);
	if (!l && glb.opt.sl_loop && num>0)
		do
		{
			l=Balaie_Path(glb.opt.sl_path,wx,wy,ww,wh);
		}	while (!l);

	glb.div.slide=FALSE;
	updFreeMem();

	if (pal!=NO_MEMORY)
	{
		col=(t_rgb *)glb.mem.adr[pal];
		for (i=0;i<glb.vdi.out[13];i++)
			vs_color(glb.vdi.ha,i,(int *)col[i]);
		_mFree(pal);
	}

	if (glb.opt.is_tv && glb.opt.sl_tv)
	{
		tv=(VEIL *)_cookie('VeiL');
		tv->stop=j;
	}
	if (glb.opt.is_led && glb.opt.sl_led)
	{
		led=(LEDP *)_cookie('LEDP');
		led->active=k;
	}

	wind_close(wha);
	wind_delete(wha);

	_menuBar(glb.aes.tree.menu,TRUE);

	graf_mouse(M_ON,NULL);
	graf_mouse(ARROW,NULL);
	wind_update(END_MCTRL);
}


/*******************************************************************************
	BALAYAGE D'UN DOSSIER
*******************************************************************************/
static int Balaie_Path(char *directory,int wx,int wy,int ww,int wh)
{
	char		old_path[FILENAME_MAX];
	int		old_drv;
	char		pfn[FILENAME_MAX];
	DTA		*mydta;
	int		i,Fin=0;
	int		cnt,pos;
/*	long		count;*/

	t2=0;
	old_drv=Dgetdrv();
	Dgetpath(old_path,1+old_drv);
	mydta=Fgetdta();
	if (directory[1]==':')
		Dsetdrv((int)directory[1]-65);

	strcpy(pfn,directory);
	strcat(pfn,"\\*.*");
	if (glb.opt.sl_rec)
		i=Fsfirst(pfn,FA_READONLY|FA_SUBDIR|FA_ARCHIVE);
	else
		i=Fsfirst(pfn,FA_READONLY|FA_ARCHIVE);
	pos=0;
loop1:
	cnt=0;
	while (!i)
	{
		cnt+=1;
		if (mydta->d_fname[0]!='.' && cnt>pos)
		{
			strcpy(pfn,directory);
			strcat(pfn,"\\");
			strcat(pfn,mydta->d_fname);
			if (mydta->d_attrib&FA_SUBDIR)
			{
				pos=cnt;
				if (Balaie_Path(pfn,wx,wy,ww,wh))
					return TRUE;
				strcpy(pfn,directory);
				strcat(pfn,"\\*.*");
				if (glb.opt.sl_rec)
					i=Fsfirst(pfn,FA_READONLY|FA_SUBDIR|FA_ARCHIVE);
				else
					i=Fsfirst(pfn,FA_READONLY|FA_ARCHIVE);
				goto loop1;
			}
		}
		if (Kbshift(-1)!=shift)
			return TRUE;
		i=Fsnext();
/*
		if (i!=0)
			{
				time(&t1);
				if(glb.opt.sl_pause)
				{
					count=1000L*max( 0 , (long)glb.opt.sl_ptime - (t1-t2) );
					evnt_timer( (int)(count&0xFFFFUL),(int)(count>>16) );
				}
				else
					count=0;
			}
*/
	}


	strcpy(pfn,directory);
	strcat(pfn,"\\");
	strcat(pfn,glb.opt.sl_name);

	if (glb.opt.sl_rec)
		i=Fsfirst(pfn,FA_READONLY|FA_SUBDIR|FA_ARCHIVE);
	else
		i=Fsfirst(pfn,FA_READONLY|FA_ARCHIVE);
	pos=0;
	cnt=0;
	while (!i)
	{
		cnt+=1;
		if (mydta->d_fname[0]!='.' && cnt>pos)
		{
			strcpy(pfn,directory);
			strcat(pfn,"\\");
			strcat(pfn,mydta->d_fname);
			if (!(mydta->d_attrib&FA_SUBDIR))
				affiche(pfn,wx,wy,ww,wh);
		}
		if (Kbshift(-1)!=shift)
			return TRUE;
		i=Fsnext();
/*
		if (i!=0)
			{
				time(&t1);
				if(glb.opt.sl_pause)
					count=1000L*max( 0 , (long)glb.opt.sl_ptime - (t1-t2) );
				else
					count=0;
				evnt_timer( (int)(count&0xFFFFUL),(int)(count>>16) );
			}
*/
	}


	Dsetdrv(old_drv);
	Dsetpath(old_path);
	return Fin;
}

/*******************************************************************************
	CHARGEMENT ET AFFICHAGE
*******************************************************************************/
static void affiche(char *nom,int wx,int wy,int ww,int wh)
{
/*	int		col[3];*/
	double	xratio,yratio;
	MFDB		src,dst;
	IMG		sld;
	long		count,flen;
	int		pxy[8],xy[8];
	int		xcar,ycar,wcar,hcar,xaff,yaff;
	int		idst,pdst;
	int		pmem,imem;
	int		r,ret;
	int		mask;
	int		i,n;
	int		*ps;
	char		*q;
	char		txt[FILENAME_MAX];

	ret=RIM_NEXT;
	n=0;
	while (ret==RIM_NEXT)
	{
		if (Kbshift(-1)!=shift)
			return;
		ret=_rimLoad(FALSE,nom,&flen,(MFDB *)&sld.mfdb,(char *)sld.type,&imem,&pmem,n);
		if (Kbshift(-1)!=shift)
			return;

		if (ret!=RIM_OK && ret!=RIM_NEXT)
		{
			if (imem!=NO_MEMORY)
				_mFree(imem);
			if (pmem!=NO_MEMORY)
				_mFree(pmem);
			return;
		}
		n+=1;

		idst=NO_MEMORY;
		pdst=NO_MEMORY;

		src.fd_w			=	sld.mfdb.w;
		src.fd_wdwidth	=	sld.mfdb.wdw;
		src.fd_h			=	sld.mfdb.h;
		src.fd_stand	=	sld.mfdb.stand;
		src.fd_nplanes	=	sld.mfdb.nplanes;

		if (sld.mfdb.w>ww || sld.mfdb.h>wh)			/*	Si l'image est plus	*/
		{														/*	grande que l'‚cran en W ou H	*/
			if (glb.opt.sl_zdec)							/*	Zoom diminution ?					*/
			{
				xratio=(double)ww/(double)sld.mfdb.w;
				yratio=(double)wh/(double)sld.mfdb.h;

				if (xratio>=yratio)			/*	Pleine hauteur	*/
				{
					sld.mfdb.w=(int)( (double)sld.mfdb.w * (double)wh / (double)sld.mfdb.h );
					sld.mfdb.h=wh;
					sld.mfdb.wdw=_word(sld.mfdb.w);
				}
				else								/*	Pleine largeur	*/
				{
					sld.mfdb.h=(int)( (double)sld.mfdb.h * (double)ww / (double)sld.mfdb.w );
					sld.mfdb.w=ww;
					sld.mfdb.wdw=_word(sld.mfdb.w);
				}
			}
		}
		else									/*	Alors l'image est plus petite que l'‚cran	*/
		{
			if (glb.opt.sl_zinc)							/*	Zoom Agrandissement ?			*/
			{
				xratio=(double)ww/(double)sld.mfdb.w;
				yratio=(double)wh/(double)sld.mfdb.h;

				if (xratio>=yratio)			/*	Pleine hauteur	*/
				{
					sld.mfdb.w=(int)( (double)sld.mfdb.w * (double)wh / (double)sld.mfdb.h );
					sld.mfdb.h=wh;
					sld.mfdb.wdw=_word(sld.mfdb.w);
				}
				else								/*	Pleine largeur	*/
				{
					sld.mfdb.h=(int)( (double)sld.mfdb.h * (double)ww / (double)sld.mfdb.w );
					sld.mfdb.w=ww;
					sld.mfdb.wdw=_word(sld.mfdb.w);
				}
			}
		}

		dst.fd_w			=	sld.mfdb.w;
		dst.fd_wdwidth	=	sld.mfdb.wdw;
		dst.fd_h			=	sld.mfdb.h;
		dst.fd_stand	=	0;
		dst.fd_nplanes	=	glb.vdi.extnd[4];

		if (Kbshift(-1)!=shift)
			return;
		mask=TRM_IMPORT|TRM_SUGG_PAL|TRM_AUTO;
		r=_trmConvert(FALSE,imem,&idst,pmem,&pdst,&src,&dst,mask,glb.parx.d_trm,0);
		if (Kbshift(-1)!=shift)
			return;

		if (r!=TRM_OK)
		{
			if (imem!=NO_MEMORY)
				_mFree(imem);
			if (pmem!=NO_MEMORY)
				_mFree(pmem);
			if (idst!=NO_MEMORY)
				_mFree(idst);
			if (pdst!=NO_MEMORY)
				_mFree(pdst);
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

		if (Kbshift(-1)!=shift)
			return;
		if (!r)
		{
			if (imem!=NO_MEMORY)
				_mFree(imem);
			if (pmem!=NO_MEMORY)
				_mFree(pmem);
			graf_mouse(ARROW,0);
			return;
		}

		r=-1;

		sld.mfdb.seek		=	0L;
		sld.mfdb.w			=	dst.fd_w;
		sld.mfdb.h			=	dst.fd_h;
		sld.mfdb.wdw		=	dst.fd_wdwidth;
		sld.mfdb.stand		=	dst.fd_stand;
		sld.mfdb.nplanes	=	dst.fd_nplanes;
		sld.flag				=	1;
		sld.x					=	0;
		sld.y					=	0;
		sld.w					=	sld.mfdb.w;
		sld.h					=	sld.mfdb.h;

		if (sld.w>ww || sld.h>wh)					/*	Si l'image est plus	*/
		{													/*	grande que l'‚cran en W ou H	*/
			if (sld.w>ww)								/*	Largeur plus grande				*/
			{
				xcar=(sld.w-ww)/2;
				xaff=wx;
				wcar=ww;
			}
			else
			{
				xaff=wx+(ww-sld.w)/2;
				xcar=0;
				wcar=sld.w;
			}
			if (sld.h>wh)								/*	Hauteur plus grande				*/
			{
				ycar=(sld.h-wh)/2;
				yaff=wy;
				hcar=wh;
			}
			else
			{
				yaff=wy+(wh-sld.h)/2;
				ycar=0;
				hcar=sld.h;
			}
		}
		else									/*	Alors l'image est plus petite que l'‚cran	*/
		{
			if (sld.w>ww)					/*	Largeur plus grande				*/
			{
				xcar=(sld.w-ww)/2;
				xaff=wx;
				wcar=ww;
			}
			else
			{
				xaff=wx+(ww-sld.w)/2;
				xcar=0;
				wcar=sld.w;
			}

			if (sld.h>wh)								/*	Hauteur plus grande				*/
			{
				ycar=(sld.h-wh)/2;
				yaff=wy;
				hcar=wh;
			}
			else
			{
				yaff=wy+(wh-sld.h)/2;
				ycar=0;
				hcar=sld.h;
			}
		}

		sld.mfdb.seek	=	(long)glb.mem.adr[imem];
		sld.mfdb.wdw	=	_word(sld.mfdb.w);
		dst.fd_addr		=	0;
		dst.fd_w			=	0;
		dst.fd_h			=	0;
		dst.fd_wdwidth	=	0;
		dst.fd_stand	=	0;
		dst.fd_nplanes	=	0;

		pxy[0]	=	xcar;				pxy[4]	=	xaff;
		pxy[1]	=	ycar;				pxy[5]	=	yaff;
		pxy[2]	=	xcar+wcar-1;	pxy[6]	=	xaff+wcar-1;
		pxy[3]	=	ycar+hcar-1;	pxy[7]	=	yaff+hcar-1;

		time(&t1);
		if (Kbshift(-1)!=shift)
			return;
		if(glb.opt.sl_pause)
		{
			count=1000L*max( 0 , (long)glb.opt.sl_ptime - difftime(t1,t2) );
			evnt_timer( (int)(count&0xFFFFUL) , (int)(count>>16) );
		}
		else
			count=0;
		if (Kbshift(-1)!=shift)
			return;

/*
		col[0]=0;
		col[1]=0;
		col[2]=0;
		for (i=0;i<glb.vdi.out[13];i++)
			vs_color(glb.vdi.ha,i,(int *)col);
*/
/*		if (sld.w<ww || sld.h<wh)
		{*/

			dst.fd_addr		=	0;
			dst.fd_w			=	0;
			dst.fd_h			=	0;
			dst.fd_wdwidth	=	0;
			dst.fd_stand	=	0;
			dst.fd_nplanes	=	0;

			xy[0]	=	wx;				xy[4]	=	wx;
			xy[1]	=	wy;				xy[5]	=	wy;
			xy[2]	=	xy[0]+ww-1;		xy[6]	=	xy[4]+ww-1;
			xy[3]	=	xy[1]+wh-1;		xy[7]	=	xy[5]+wh-1;

			vro_cpyfm(glb.vdi.ha,ALL_WHITE,xy,&dst,&dst);
/*		}*/

		vro_cpyfm(glb.vdi.ha,S_ONLY,pxy,(MFDB *)&sld.mfdb,&dst);

		if (glb.opt.sl_info)
		{
			q=(char *)strrchr(nom,'\\');
			if (q==NULL)
				q=(char *)nom;
			else
				q++;

			if (ret==RIM_NEXT)
				sprintf(txt,"%s (%i)",q,n);
			else
				strcpy(txt,q);

			vswr_mode(glb.vdi.ha,MD_REPLACE);
			vst_color(glb.vdi.ha,BLACK);
			vst_alignment(glb.vdi.ha,ALI_CENTER,ALI_TOP,&r,&r);
			v_gtext(glb.vdi.ha,wx+ww/2,wy,txt);
		}

		if (pmem!=NO_MEMORY)
		{
			ps=(int *)glb.mem.adr[pmem];
			mask=(int)(glb.mem.len[pmem]/6L);
		}
		else
		{
			ps=(int *)glb.mem.adr[glb.vdi.pal];
			mask=(int)(glb.mem.len[glb.vdi.pal]/6L);
		}

		for (i=0;i<mask;i++)
			vs_color(glb.vdi.ha,i,(int *)&ps[3*i]);

		_mFree(imem);
		_mFree(pmem);

		num+=1;
		time(&t2);
		if (Kbshift(-1)!=shift)
			return;
	}
}
