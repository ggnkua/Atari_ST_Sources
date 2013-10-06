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

void cdecl winit(int i);
void cdecl wredraw(int i,int x,int y,int w,int h);
void cdecl wkey(int i,int key);
int cdecl waskclose(int i);
void cdecl wclose(int i);
void cdecl wsize(int i,int x,int y);
void cdecl wfull(int i);
static void wHslider(int i);
static void wVslider(int i);
void cdecl warrow(int i,int type);
void cdecl whslid(int i,int pos);
void cdecl wvslid(int i,int pos);
void cdecl wclic(int i,int mx,int my,int mk,int nmb);

/*******************************************************************************
	VARIABLES
*******************************************************************************/
#undef NUM_BB
#undef NUM_IB
#undef NUM_CIB
#undef NUM_TI
#undef NUM_FRSTR
#undef NUM_FRIMG
#undef NUM_OBS
#undef NUM_TREE

/*******************************************************************************
	FONCTION DE CHARGEMENT IMAGE: BALAYAGE DTA, ETC...
*******************************************************************************/
void wload()
{
	char	*my_ext[10]= {	glb.opt.ext[1],glb.opt.ext[2],glb.opt.ext[3],glb.opt.ext[4],glb.opt.ext[5],glb.opt.ext[6],glb.opt.ext[7],glb.opt.ext[8],glb.opt.ext[9],glb.opt.ext[10]	};
	char	*my_pat[10]= {	glb.opt.pat[1],glb.opt.pat[2],glb.opt.pat[3],glb.opt.pat[4],glb.opt.pat[5],glb.opt.pat[6],glb.opt.pat[7],glb.opt.pat[8],glb.opt.pat[9],glb.opt.pat[10]	};

	menuOff();

	strcpy(glb.div.pfname,"");
	strcpy(glb.div.pname,glb.opt.pat[0]);
	_slctExtPath(10*glb.opt.useExt,&my_ext,10*glb.opt.usePat,&my_pat);

	_multifsel(glb.div.pfname,glb.div.pname,glb.div.fname,glb.opt.ext[0],glb.rsc.head.frstr[TFSELLOAD],wopen);
	_updatePath(glb.div.pname);

	menuOn();
}


/*******************************************************************************
	FONCTION D'OUVERTURE DE FENETRE ET DE CHARGEMENT D'IMAGE
*******************************************************************************/
int cdecl wopen(char *fname)
{
	char			name[FILENAME_MAX];
	long			flen;
	MFDB			src,dst;
	window		win;
	int			idst,pdst;
	int			pmem=NO_MEMORY,imem=NO_MEMORY;
	int			i,j,ret,r,n;
	int			mask;
	char			*p;

	glb.opt.mask=0;

	n=0;

	ret=RIM_NEXT;
	while (ret==RIM_NEXT)
	{
		ret=RIM_ERROR;

		j=-1;
		for (i=0;i<glb.opt.Win_Num;i++)
			if (!img[i].flag)
			{
				j=i;
				i=glb.opt.Win_Num;
			}

		if (j!=-1)
		{
			strcpy(name,fname);

			ret=_rimLoad(TRUE,name,&flen,(MFDB *)&img[j].mfdb,(char *)img[j].type,&imem,&pmem,n);

			if (ret!=RIM_OK && ret!=RIM_NEXT)
			{
				if (imem!=NO_MEMORY)
					_mFree(imem);
				if (pmem!=NO_MEMORY)
					_mFree(pmem);
				graf_mouse(ARROW,0);
				return 0;
			}
			n+=1;

			img[j].flen			=	flen;
			img[j].oldplanes	=	img[j].mfdb.nplanes;
			img[j].oldw			=	img[j].mfdb.w;
			img[j].oldh			=	img[j].mfdb.h;

			idst=NO_MEMORY;
			pdst=NO_MEMORY;

			src.fd_w			=	img[j].mfdb.w;
			src.fd_wdwidth	=	img[j].mfdb.wdw;
			src.fd_h			=	img[j].mfdb.h;
			src.fd_stand	=	img[j].mfdb.stand;
			src.fd_nplanes	=	img[j].mfdb.nplanes;

			dst.fd_w			=	img[j].mfdb.w;
			dst.fd_wdwidth	=	img[j].mfdb.wdw;
			dst.fd_h			=	img[j].mfdb.h;
			dst.fd_stand	=	0;
			dst.fd_nplanes	=	glb.vdi.extnd[4];

			if (glb.opt.pal)
				mask=TRM_IMPORT|TRM_PRG_PAL|TRM_USER;
			else
				mask=TRM_IMPORT|TRM_SUGG_PAL|TRM_USER;

			r=trmConvert(TRUE,imem,&idst,pmem,&pdst,&src,&dst,mask,glb.parx.d_trm,0);

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
				graf_mouse(ARROW,0);
				return 0;
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

			r=0;

			p=strrchr(name,'\\');
			if (!p)
				p=name;
			else
				p++;

			strcpy(img[j].name,p);

			strcpy(win.name,p);
			p=strrchr(win.name,'.');
			if (p!=NULL)
				*p=0;
			strncpy(win.sname,win.name,wSNAMEMAX);

			strcpy(img[j].iname,win.sname);

			img[j].mfdb.seek		=	0L;
			img[j].mfdb.w			=	dst.fd_w;
			img[j].mfdb.h			=	dst.fd_h;
			img[j].mfdb.wdw		=	dst.fd_wdwidth;
			img[j].mfdb.stand		=	dst.fd_stand;
			img[j].mfdb.nplanes	=	dst.fd_nplanes;
			img[j].flag				=	1;
			img[j].num				=	n;
			img[j].x					=	0;
			img[j].y					=	0;
			img[j].w					=	img[j].mfdb.w;
			img[j].h					=	img[j].mfdb.h;

			win.gadget=W_NAME|W_CLOSER|W_FULLER|W_MOVER|W_SIZER|W_UPARROW|W_DNARROW|W_VSLIDE
						|W_LFARROW|W_RTARROW|W_HSLIDE|W_SMALLER;
			win.xgadget=0;

			win.wmini=WMINI;
			win.hmini=HMINI;
			win.wwork=min( img[j].mfdb.w , glb.aes.desk.w );
			win.hwork=min( img[j].mfdb.h , glb.aes.desk.h );
			win.xwork=glb.aes.desk.x+(glb.aes.desk.w-win.wwork)/2;
			win.ywork=glb.aes.desk.y+(glb.aes.desk.h-win.hwork)/2;
			win.xfull=glb.aes.desk.x;
			win.yfull=glb.aes.desk.y;
			win.wfull=glb.aes.desk.w;
			win.hfull=glb.aes.desk.h;
			win.xwind=-1;

			win.icon			=	WIC_DEF;
			win.ic_tree		=	-1;
			win.type			=	TW_IMG;
			win.id			=	j;
			win.in			=	imem;
			win.ipal			=	pmem;
			win.top			=	0;
			win.askclose	=	waskclose;
			win.close		=	wclose;
			win.full			=	wfull;
			win.arrow		=	warrow;
			win.hslid		=	whslid;
			win.vslid		=	wvslid;
			win.size			=	wsize;
			win.small		=	0;
			win.nsmall		=	0;
			win.init			=	winit;
			win.redraw		=	wredraw;
			win.keybd		=	wkey;
			win.move			=	0;
			win.clic			=	wclic;
			win.untop		=	0;
			win.ontop		=	0;
			i=_winOpen(&win);
			if (W[i].handle>=0)
			{
				wind_calc(WC_BORDER,W[i].gadget,W[i].xwork,W[i].ywork,img[j].w,img[j].h,&W[i].xfull,&W[i].yfull,&W[i].wfull,&W[i].hfull);
				W[i].xfull=max(glb.aes.desk.x,W[i].xfull);
				W[i].yfull=max(glb.aes.desk.y,W[i].yfull);
				W[i].wfull=min(glb.aes.desk.w,W[i].wfull);
				W[i].hfull=min(glb.aes.desk.h,W[i].hfull);
				r=1;
				Curr=j;
				_initRSC(FLOG,FLOGNMB);
				setLog();

				if (glb.opt.zap)
					_winSmall(i);
				_clearAesBuffer();
			}
		}
	}
	graf_mouse(ARROW,0);
	return r;
}

static void cdecl winit(i)
{
	wHslider(i);
	wVslider(i);
}


/*******************************************************************************
	FONCTION DE REDRAW D'UNE FENETRE IMAGE
*******************************************************************************/
#pragma warn -par
void cdecl wredraw(int i,int x,int y,int w,int h)
{
	MFDB			dst;
	GRECT			p1,p2;
	int			pxy[8];
	int			j;

	if (i!=-1)
	{
		j=W[i].id;

		if (img[j].mfdb.nplanes==glb.vdi.extnd[4] && img[j].mfdb.stand==0)
		{
			if (img[j].w<W[i].wwork || img[j].h<W[i].hwork)
			{
				glb.rsc.head.trindex[DUMMY][ROOT].ob_x			=	W[i].xwork;
				glb.rsc.head.trindex[DUMMY][ROOT].ob_y			=	W[i].ywork;
				glb.rsc.head.trindex[DUMMY][ROOT].ob_width	=	W[i].wwork;
				glb.rsc.head.trindex[DUMMY][ROOT].ob_height	=	W[i].hwork;
				objc_draw(glb.rsc.head.trindex[DUMMY],ROOT,MAX_DEPTH,x,y,w,h);
			}

			p1.g_x	=	x;
			p1.g_y	=	y;
			p1.g_w	=	w;
			p1.g_h	=	h;

			if (img[j].w>W[i].wwork)
			{
				p2.g_x	=	W[i].xwork;
				p2.g_w	=	W[i].wwork;
			}
			else
			{
				p2.g_x	=	W[i].xwork+(W[i].wwork-img[j].w)/2;
				p2.g_w	=	img[j].w;
			}

			if (img[j].h>W[i].hwork)
			{
				p2.g_y	=	W[i].ywork;
				p2.g_h	=	W[i].hwork;
			}
			else
			{
				p2.g_y	=	W[i].ywork+(W[i].hwork-img[j].h)/2;
				p2.g_h	=	img[j].h;
			}

			if (_rcIntersect(&p2,&p1))
			{
				img[j].mfdb.seek=(long)glb.mem.adr[W[i].in];
				img[j].mfdb.wdw=_word(img[j].mfdb.w);

				dst.fd_addr		=	0;
				dst.fd_w			=	0;
				dst.fd_h			=	0;
				dst.fd_wdwidth	=	0;
				dst.fd_stand	=	0;
				dst.fd_nplanes	=	0;

				pxy[0]	=	img[j].x+p1.g_x-p2.g_x;	pxy[4]	=	p1.g_x;
				pxy[1]	=	img[j].y+p1.g_y-p2.g_y;	pxy[5]	=	p1.g_y;
				pxy[2]	=	pxy[0]+p1.g_w-1;			pxy[6]	=	pxy[4]+p1.g_w-1;
				pxy[3]	=	pxy[1]+p1.g_h-1;			pxy[7]	=	pxy[5]+p1.g_h-1;

				img[j].mfdb.seek=(long)glb.mem.adr[W[i].in];
				img[j].mfdb.wdw=_word(img[j].mfdb.w);

				dst.fd_addr		=	0;
				dst.fd_w			=	0;
				dst.fd_h			=	0;
				dst.fd_wdwidth	=	0;
				dst.fd_stand	=	0;
				dst.fd_nplanes	=	0;

				vro_cpyfm(glb.vdi.ha,S_ONLY,pxy,(MFDB *)&img[j].mfdb,&dst);

			}
		}
		else
		{
			glb.rsc.head.trindex[DUMMY][ROOT].ob_x			=	W[i].xwork;
			glb.rsc.head.trindex[DUMMY][ROOT].ob_y			=	W[i].ywork;
			glb.rsc.head.trindex[DUMMY][ROOT].ob_width	=	W[i].wwork;
			glb.rsc.head.trindex[DUMMY][ROOT].ob_height	=	W[i].hwork;
			objc_draw(glb.rsc.head.trindex[DUMMY],ROOT,MAX_DEPTH,x,y,w,h);
		}
		if (img[j].cflag)
		{
		}
	}
}
#pragma warn +par


/*******************************************************************************
	FONCTION DE GESTION DU CLAVIER
*******************************************************************************/
void cdecl wkey(int i,int key)
{
	int	j,k,n,buf[8];

	switch	(toupper(key&0xFF))
	{
		case	'W':
			k=-1;
			j=W[i].id;
			n=j+1;
			while (k==-1 && n!=j)
			{
				if (n==glb.opt.Win_Num)
					n=0;
				if (img[n].flag)
					k=n;
				n+=1;
			}
			if (k!=-1)
			{
				buf[0]=WM_TOPPED;
				buf[1]=glb.aes.id;
				buf[2]=0;
				buf[3]=W[_winFindId(TW_IMG,k,FALSE)].handle;
				appl_write(glb.aes.id,16,buf);
			}
			break;
		case	K_LEFT:
			if (key&KF_SHIFT)
				_winArrow(i,WA_LFPAGE);
			else
				_winArrow(i,WA_LFLINE);
			break;
		case	K_RIGHT:
			if (key&KF_SHIFT)
				_winArrow(i,WA_RTPAGE);
			else
				_winArrow(i,WA_RTLINE);
			break;
		case	K_UP:
			if (key&KF_SHIFT)
				_winArrow(i,WA_UPPAGE);
			else
				_winArrow(i,WA_UPLINE);
			break;
		case	K_DOWN:
			if (key&KF_SHIFT)
				_winArrow(i,WA_DNPAGE);
			else
				_winArrow(i,WA_DNLINE);
			break;
	}
}


/*******************************************************************************
	FONCTION DE DEMANDE DE FERMETURE D'UNE FENETRE
*******************************************************************************/
int cdecl waskclose(int i)
{
	int		out;

	if (working!=-1)
		return 0;

	out=1+glb.opt.win;
	if (glb.opt.win==2)
		out=form_alert(3,glb.rsc.head.frstr[WINCLOSE]);

	if (out==1)
		return 0;
	else if (out==2)
		_winSmall(i);
	return 1;
}


/*******************************************************************************
	FONCTION DE FERMETURE D'UNE FENETRE
*******************************************************************************/
void cdecl wclose(int i)
{
	int		top,j;

	menuOff();
	j=W[i].id;
	_mFree(W[i].in);
	W[i].in=NO_MEMORY;
	_mFree(W[i].ipal);
	W[i].ipal=NO_MEMORY;
	img[j].flag=0;
	img[j].name[0]=0;
	img[j].iname[0]=0;
	img[j].type[0]=0;
	img[j].flen=0;
	img[j].oldw=0;
	img[j].oldh=0;
	img[j].oldplanes=0;
	img[j].x=0;
	img[j].y=0;
	img[j].w=0;
	img[j].h=0;
	img[j].oldx=0;
	img[j].oldy=0;
	img[j].cx=0;
	img[j].cy=0;
	img[j].cw=0;
	img[j].ch=0;
	img[j].cflag=0;
	W[i].type=-1;
	W[i].id=-1;
	if (Curr==j)
	{
		Curr=0;
		top=j;
		do
		{
			top+=1;
			if (top==glb.opt.Win_Num)
				top=0;
			if (img[top].flag)
			{
				Curr=top;
				top=j;
			}
		}	while (top!=j);
	}
	_initRSC(FLOG,FLOGNMB);
	setLog();
	menuOn();
}


/*******************************************************************************
	TRAITEMENT DE RESIZE
*******************************************************************************/
#pragma warn -par
void cdecl wsize(int i,int x,int y)
{
	wHslider(i);
	wVslider(i);
}
#pragma warn +par


/*******************************************************************************
	TRAITEMENT DU FULLER
*******************************************************************************/
void cdecl wfull(int i)
{
	int		j;
	int		dum;

	if (i!=-1)
	{
		j=W[i].id;

		dum			=	img[j].x;
		img[j].x		=	img[j].oldx;
		img[j].oldx	=	dum;
		dum			=	img[j].y;
		img[j].y		=	img[j].oldy;
		img[j].oldy	=	dum;

		wHslider(i);
		wVslider(i);
	}
}


/*******************************************************************************
	GESTION DES ASCENSEURS
*******************************************************************************/
static void wHslider(int i)
{
	int		j;

	if (i!=-1)
	{
		j=W[i].id;

		img[j].x			=	min ( img[j].x , img[j].w-W[i].wwork );
		W[i].xslidlen	=	(int)( 1000.0 * (double)W[i].wwork / (double)img[j].w );

		if (img[j].w!=W[i].wwork)
			W[i].xslidpos	=	(int)( 1000.0 * (double)img[j].x / (double)(img[j].w-W[i].wwork) );
		else
			W[i].xslidpos	=	0;
	}
}


static void wVslider(int i)
{
	int		j;

	if (i!=-1)
	{
		j=W[i].id;

		img[j].y			=	min ( img[j].y , img[j].h-W[i].hwork );
		W[i].yslidlen	=	(int)( 1000.0 * (double)W[i].hwork / (double)img[j].h );

		if (img[j].h!=W[i].hwork)
			W[i].yslidpos	=	(int)( 1000.0 * (double)img[j].y / (double)(img[j].h-W[i].hwork) );
		else
			W[i].yslidpos	=	0;
	}
}


/*******************************************************************************
	GESTION DES FLECHES
*******************************************************************************/
void cdecl warrow(int i,int type)
{
	int		j;
	uint		dum;

	if (i!=-1)
	{
		j=W[i].id;

		switch (type)
		{
			case	WA_UPPAGE:
				dum=img[j].y;
				if (img[j].y>(uint)W[i].hwork)
					img[j].y=img[j].y-(uint)W[i].hwork;
				else
					img[j].y=0;
				if (dum!=img[j].y)
					if (img[j].h!=W[i].hwork)
						W[i].yslidpos=(int)( ((double)1000*(double)img[j].y) / (double)(img[j].h-W[i].hwork) );
				break;
			case	WA_DNPAGE:
				dum=img[j].y;
				if ((ulong)img[j].y+2L*(ulong)W[i].hwork<(ulong)img[j].h)
					img[j].y=img[j].y+(uint)W[i].hwork;
				else
					img[j].y=img[j].h-(uint)W[i].hwork;
				if (dum!=img[j].y)
					if (img[j].h!=W[i].hwork)
						W[i].yslidpos=(int)( ((double)1000*(double)img[j].y) / (double)(img[j].h-W[i].hwork) );
				break;
			case	WA_UPLINE:
				dum			=	img[j].y;
				if (img[j].y>(uint)(W[i].hwork/10))
					img[j].y=img[j].y-(uint)(W[i].hwork/10);
				else
					img[j].y=0;
				if (dum!=img[j].y)
					if (img[j].h!=W[i].hwork)
						W[i].yslidpos=(int)( ((double)1000*(double)img[j].y) / (double)(img[j].h-W[i].hwork) );
				break;
			case	WA_DNLINE:
				dum			=	img[j].y;
				if ((uint)img[j].y+(uint)(W[i].hwork/10)<img[j].h-(uint)W[i].hwork)
					img[j].y=img[j].y+(uint)(W[i].hwork/10);
				else
					img[j].y=img[j].h-(uint)W[i].hwork;
				if (dum!=img[j].y)
					if (img[j].h!=W[i].hwork)
						W[i].yslidpos=(int)( ((double)1000*(double)img[j].y) / (double)(img[j].h-W[i].hwork) );
				break;
			case	WA_LFPAGE:
				dum			=	img[j].x;
				if (img[j].x>(uint)W[i].wwork)
					img[j].x=img[j].x-(uint)W[i].wwork;
				else
					img[j].x=0;
				if (dum!=img[j].x)
					if (img[j].w!=W[i].wwork)
						W[i].xslidpos=(int)( ((double)1000*(double)img[j].x) / (double)(img[j].w-W[i].wwork) );
				break;
			case	WA_RTPAGE:
				dum			=	img[j].x;
				if ((ulong)img[j].x+2L*(ulong)W[i].wwork<(ulong)img[j].w)
					img[j].x=img[j].x+(uint)W[i].wwork;
				else
					img[j].x=img[j].w-(uint)W[i].wwork;
				if (dum!=img[j].x)
					if (img[j].w!=W[i].wwork)
						W[i].xslidpos=(int)( ((double)1000*(double)img[j].x) / (double)(img[j].w-W[i].wwork) );
				break;
			case	WA_LFLINE:
				dum			=	img[j].x;
				if (img[j].x>(uint)(W[i].wwork/10))
					img[j].x=img[j].x-(uint)(W[i].wwork/10);
				else
					img[j].x=0;
				if (dum!=img[j].x)
					if (img[j].w!=W[i].wwork)
						W[i].xslidpos=(int)( ((double)1000*(double)img[j].x) / (double)(img[j].w-W[i].wwork) );
				break;
			case	WA_RTLINE:
				dum			=	img[j].x;
				if ((uint)img[j].x+(uint)(W[i].wwork/10)<img[j].w-(uint)W[i].wwork)
					img[j].x=img[j].x+(uint)(W[i].wwork/10);
				else
					img[j].x=img[j].w-(uint)W[i].wwork;
				if (dum!=img[j].x)
					if (img[j].w!=W[i].wwork)
						W[i].xslidpos=(int)( ((double)1000*(double)img[j].x) / (double)(img[j].w-W[i].wwork) );
				break;
		}
	}
}


/*******************************************************************************
	GESTION DU SLIDER HORIZONTAL
*******************************************************************************/
void cdecl whslid(int i,int pos)
{
	int		dum,j;

	if (i!=-1)
	{
		j=W[i].id;

		if (img[j].w!=W[i].wwork)
		{
			dum=(int)( (double)pos*(double)(img[j].w-W[i].wwork)/1000.0 );
			if (dum!=img[j].x)
			{
				img[j].x=dum;
				wHslider(i);
			}
		}
	}
}


/*******************************************************************************
	GESTION DU SLIDER VERTICAL
*******************************************************************************/
void cdecl wvslid(int i,int pos)
{
	int		dum,j;

	if (i!=-1)
	{
		j=W[i].id;

		if (img[j].h!=W[i].hwork)
		{
			dum=(int)( (double)pos*(double)(img[j].h-W[i].hwork)/1000.0 );
			if (dum!=img[j].y)
			{
				img[j].y=dum;
				wVslider(i);
			}
		}
	}
}


/*******************************************************************************
	GESTION DU CLIC SUR FENETRE
*******************************************************************************/
#pragma warn -par
void cdecl wclic(int i,int mx,int my,int mk,int nmb)
{
	RMOUSE	str;
	long		ofx,ofy;
	uint		x=16383,y=16383;
	int		top,j,k,dum,flag;

	j=W[i].id;
	if (mk==1)
	{
		if (nmb==2)
			fullscreen(i);
		else
		{
			wind_update(BEG_MCTRL);
			_clearAesBuffer();
			wind_get(0,WF_TOP,&top);
			top=_winFindWin(top);
			graf_mkstate(&dum,&dum,&dum,&k);
			if (img[j].w!=W[i].wwork || img[j].h!=W[i].hwork)
			{
				RMOUSE_ON(&str);
				do
				{
					if (*str.x!=x || *str.y!=y)
					{
						ofx=(long)(*str.x)-(long)x+(long)img[j].x;
						ofy=(long)(*str.y)-(long)y+(long)img[j].y;
						x=*str.x;
						y=*str.y;
						if (ofx>(long)(img[j].w-W[i].wwork))
							img[j].x=img[j].w-W[i].wwork;
						else if (ofx<0)
							img[j].x=0;
						else
							img[j].x=(uint)ofx;
						if (ofy>(long)(img[j].h-W[i].hwork))
							img[j].y=img[j].h-W[i].hwork;
						else if (ofy<0)
							img[j].y=0;
						else
							img[j].y=(uint)ofy;
						flag=FALSE;
						if (img[j].w!=W[i].wwork)
						{
							dum=W[i].xslidpos;
							W[i].xslidpos=(int)( ((double)1000*(double)img[j].x) / (double)(img[j].w-W[i].wwork) );
							if (dum!=W[i].xslidpos)
							{
								wHslider(i);
								wind_set(W[i].handle,WF_HSLIDE,W[i].xslidpos);
								flag=TRUE;
							}
						}
						if (img[j].h!=W[i].hwork)
						{
							dum=W[i].yslidpos;
							W[i].yslidpos=(int)( ((double)1000*(double)img[j].y) / (double)(img[j].h-W[i].hwork) );
							if (dum!=W[i].yslidpos)
							{
								wVslider(i);
								wind_set(W[i].handle,WF_VSLIDE,W[i].yslidpos);
								flag=TRUE;
							}
						}
						if (flag)
						{
							if (top==i)
								wredraw(i,W[i].xwork,W[i].ywork,min(img[j].w,W[i].wwork),min(img[j].h,W[i].hwork));
							else
								_winRedraw(i,W[i].xwork,W[i].ywork,min(img[j].w,W[i].wwork),min(img[j].h,W[i].hwork));
							_clearAesBuffer();
						}
					}
				}	while (*str.k&1);
				RMOUSE_OFF();
				graf_mkstate(&dum,&dum,&k,&dum);
				while (k)
					graf_mkstate(&dum,&dum,&k,&dum);
			}
			wind_update(END_MCTRL);
		}
	}
}
#pragma warn +par


/*******************************************************************************
	FONCTION DE GESTION DU FULLSCREEN
*******************************************************************************/
void fullscreen(int i)
{
	MFDB		src,dst;
	long		craw;
	int		*p;
	int		buf[8];
	int		j=-1,k,n,key,fin=TRUE;
	int		co;
	int		mx,my,mk,dum;
	int		ximg,yimg,affximg,affyimg;
	int		xaff,yaff,wcar,hcar;
	int		pxy[8];
	int		wha,wx,wy,ww,wh;

	wind_update(BEG_MCTRL);
	graf_mouse(M_OFF,0);

	if (img[Curr].flag!=-1)
	{
		if (i==-1)
		{
			wind_get(0,WF_TOP,&k);
			if (_winFindWin(k)!=-1)
				if (W[_winFindWin(k)].type==TW_IMG)
					j=W[_winFindWin(k)].id;
		}
		else
			j=W[i].id;
	}
	for (n=0;n<glb.opt.Win_Num;n++)
		if (img[j].flag && !W[findIMG(j)].smallflag)
		{
			j=n;
			fin=FALSE;
			n=glb.opt.Win_Num;
		}

	if (!fin)
	{
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
			fin=TRUE;
		}
	}

	if (!fin)
	{
		_menuBar(glb.aes.tree.menu,FALSE);

		wind_open(wha,wx,wy,ww,wh);
		wind_get(wha,WF_CURRXYWH,&wx,&wy,&ww,&wh);

		affximg=ximg=0;
		affyimg=yimg=0;
		n=j;
		j-=1;
		while (!fin)
		{
			if (affximg!=ximg || affyimg!=yimg || j!=n)
			{
				if (j!=n)
				{
					j=n;
					i=findIMG(j);

					if (W[i].ipal!=NO_MEMORY)
					{
						p=(int *)glb.mem.adr[W[i].ipal];
						for (dum=0;dum<(int)(glb.mem.len[W[i].ipal]/6L);dum++)
						{
							vs_color(glb.vdi.ha,dum,p);
							p+=3;
						}
					}
					xaff=wx;
					yaff=wy;

					if (img[j].w<ww || img[j].h<wh)
					{
						src.fd_addr		=	0;
						src.fd_w			=	0;
						src.fd_h			=	0;
						src.fd_wdwidth	=	0;
						src.fd_stand	=	0;
						src.fd_nplanes	=	0;

						dst.fd_addr		=	0;
						dst.fd_w			=	0;
						dst.fd_h			=	0;
						dst.fd_wdwidth	=	0;
						dst.fd_stand	=	0;
						dst.fd_nplanes	=	0;

						pxy[0]	=	wx;				pxy[4]	=	wx;
						pxy[1]	=	wy;				pxy[5]	=	wy;
						pxy[2]	=	pxy[0]+ww-1;	pxy[6]	=	pxy[4]+ww-1;
						pxy[3]	=	pxy[1]+wh-1;	pxy[7]	=	pxy[5]+wh-1;

						vro_cpyfm(glb.vdi.ha,ALL_WHITE,pxy,&src,&dst);

					}

					if (img[j].w<ww)
						xaff+=(ww-img[j].w)/2;
					if (img[j].h<wh)
						yaff+=(wh-img[j].h)/2;

					wcar=min(img[j].w,ww);
					hcar=min(img[j].h,wh);

					graf_mkstate(&mx,&my,&mk,&dum);
					affximg=ximg=(int)( (double)mx * (double)(img[j].w-wcar) / (double)ww );
					affyimg=yimg=(int)( (double)my * (double)(img[j].h-hcar) / (double)wh );
				}

				affximg=ximg;
				affyimg=yimg;

				img[j].mfdb.seek=(long)glb.mem.adr[W[i].in];
				img[j].mfdb.wdw=_word(img[j].mfdb.w);

				dst.fd_addr		=	0;
				dst.fd_w			=	0;
				dst.fd_h			=	0;
				dst.fd_wdwidth	=	0;
				dst.fd_stand	=	0;
				dst.fd_nplanes	=	0;

				pxy[0]	=	affximg;			pxy[4]	=	xaff;
				pxy[1]	=	affyimg;			pxy[5]	=	yaff;
				pxy[2]	=	pxy[0]+wcar-1;	pxy[6]	=	pxy[4]+wcar-1;
				pxy[3]	=	pxy[1]+hcar-1;	pxy[7]	=	pxy[5]+hcar-1;

				vro_cpyfm(glb.vdi.ha,S_ONLY,pxy,(MFDB *)&img[j].mfdb,&dst);
			}

			graf_mkstate(&mx,&my,&mk,&dum);

			if (img[j].w>ww)
				ximg=(int)( (double)mx * (double)(img[j].w-wcar) / (double)ww );

			if (img[j].h>wh)
				yimg=(int)( (double)my * (double)(img[j].h-hcar) / (double)wh );

			if (mk==2)
			{
				k=FALSE;
				n=j;
				do
				{
					n+=1;
					if (n>=glb.opt.Win_Num)
						n=0;
					if (img[n].flag && n!=j && !W[findIMG(n)].smallflag)
						k=TRUE;
				}	while ( n!=j && !k );
			}
			else if (mk==3)
				fin=TRUE;

			if (Cconis())
			{
				key=0;
				craw=Crawcin();
				co=(int)(craw>>8)+(int)(craw&0xFFL);
				key=_StdKey((int)Kbshift(-1),co);
				switch	(key&0xFF)
				{
					case	K_ESC:
						fin=TRUE;
						break;
					case	' ':
					case	'W':
					case	'w':
						k=FALSE;
						n=j;
						do
						{
							n+=1;
							if (n>=glb.opt.Win_Num)
								n=0;
							if (img[n].flag && n!=j && !W[findIMG(n)].smallflag)
								k=TRUE;
						}	while (n!=j && !k);
						break;
					case	K_LEFT:
						if (key & KF_SHIFT)
							ximg=max(0,ximg-wcar);
						else
							ximg=max(0,ximg-wcar/10);
						break;
					case	K_RIGHT:
						if (key & KF_SHIFT)
							ximg=min(img[j].w-wcar,ximg+wcar);
						else
							ximg=min(img[j].w-wcar,ximg+wcar/10);
						break;
					case	K_UP:
						if (key & KF_SHIFT)
							yimg=max(0,yimg-hcar);
						else
							yimg=max(0,yimg-hcar/10);
						break;
					case	K_DOWN:
						if (key & KF_SHIFT)
							yimg=min(img[j].h-hcar,yimg+hcar);
						else
							yimg=min(img[j].h-hcar,yimg+hcar/10);
						break;
				}
			}
		}

		wind_close(wha);
		wind_delete(wha);

		graf_mkstate(&dum,&dum,&mk,&dum);
		while (mk)
			graf_mkstate(&dum,&dum,&mk,&dum);

		wind_get(0,WF_TOP,&k);
		i=_winFindWin(k);
		_winOntop(i);
		_menuBar(glb.aes.tree.menu,TRUE);

		if (i!=-1 || (W[i].type==TW_IMG && W[i].id!=j))
		{
			buf[0]=WM_TOPPED;
			buf[1]=glb.aes.id;
			buf[2]=0;
			buf[3]=W[_winFindId(TW_IMG,j,FALSE)].handle;
			appl_write(glb.aes.id,16,buf);
		}
	}

	graf_mouse(M_ON,0);
	wind_update(END_MCTRL);
}


/*******************************************************************************
	MISE EN MOSAIQUE
*******************************************************************************/
#pragma warn -aus
void mosaique()
{
	int		i=-1;
	int		t,j;
	int		count=0,n,nmb=0;
	int		Nx,Ny,nx,ny,nw,nh,larg,haut;

	wind_update(BEG_UPDATE);
	for (j=0;j<glb.opt.Win_Num;j++)
		if (img[j].flag!=FALSE)
			nmb+=1;
	if (nmb>1)
	{
		n=(int)( sqrt((double)nmb) );
		Nx=n;
		Ny=n;
		if (Nx*Ny<nmb)
		{
			if ( (Nx)*(Ny+1) < nmb )
			{
				Nx+=1;
				Ny+=1;
			}
			else
			{
				if (glb.aes.desk.w>glb.aes.desk.h)
					Nx+=1;
				else
					Ny+=1;
			}
		}		

		larg=glb.aes.desk.w/Nx;
		haut=glb.aes.desk.h/Ny;
		for (j=0;j<glb.opt.Win_Num;j++)
		{
			i=-1;
			for (t=0;t<glb.opt.Win_Num;t++)
				if ( W[t].id==j && W[t].type==TW_IMG )
					i=t;
			if (i!=-1)
			{
				nx=count%Nx;
				ny=count/Nx;
				nx=glb.aes.desk.x+larg*nx;
				ny=glb.aes.desk.y+haut*ny;
				nw=min(W[i].wfull,larg);
				nh=min(W[i].hfull,haut);
				if ( (nw!=W[i].wwind) || (nh!=W[i].hwind) )
					_winSize(i,nw,nh);
				_clearAesBuffer();
				if ( (nx!=W[i].xwind) || (ny!=W[i].ywind) )
					_winMove(i,nx,ny);
				_clearAesBuffer();
				count+=1;
			}
		}
	}
	wind_update(END_UPDATE);
}
#pragma warn +aus


/*******************************************************************************
*******************************************************************************/
void closeImg(int i)
{
	wind_update(BEG_MCTRL);
	if (i==-1)
	{
		wind_get(0,WF_TOP,&i);
		i=_winFindWin(i);
	}
	if (i!=-1)
		if (W[i].type==TW_IMG)
			_winClose(i);
	wind_update(END_MCTRL);
}


/*******************************************************************************
*******************************************************************************/
void closeAllImg()
{
	int	i;

	menuOff();
	glb.div.Exit=TRUE;
	for (i=0;i<glb.opt.Win_Num;i++)
		if (W[i].type==TW_IMG)
			_winClose(i);
	glb.div.Exit=FALSE;
	menuOn();
}


/*******************************************************************************
*******************************************************************************/
void wsave(int i)
{
	if (i==-1)
	{
		wind_get(0,WF_TOP,&i);
		i=_winFindWin(i);
	}
	if (i!=-1)
		if (W[i].type==TW_IMG)
			_wimSave(TRUE,(MFDB *)&img[W[i].id].mfdb,W[i].in,W[i].ipal,0,FALSE,glb.opt.pat[0],img[W[i].id].name,glb.rsc.head.frstr[TFSELSAVE]);
}


/*******************************************************************************
*******************************************************************************/
void wusave(int i)
{
	if (i==-1)
	{
		wind_get(0,WF_TOP,&i);
		i=_winFindWin(i);
	}
	if (i!=-1)
		if (W[i].type==TW_IMG)
			_wimSave(TRUE,(MFDB *)&img[W[i].id].mfdb,W[i].in,W[i].ipal,0,TRUE,glb.opt.pat[0],img[W[i].id].name,glb.rsc.head.frstr[TFSELSAVE]);
}


/*******************************************************************************
*******************************************************************************/
void wprintGDOS(int i)
{
	if (i==-1)
	{
		wind_get(0,WF_TOP,&i);
		i=_winFindWin(i);
	}

	if (i!=-1)
		if (W[i].type==TW_IMG)
			_GdosPrintImg(W[i].in,W[i].ipal,(MFDB *)&img[W[i].id].mfdb);
}


/*******************************************************************************
*******************************************************************************/
void wprintWIM(int i)
{
	if (i==-1)
	{
		wind_get(0,WF_TOP,&i);
		i=_winFindWin(i);
	}

	if (i!=-1)
		if (W[i].type==TW_IMG)
			_wimPrint(W[i].in,W[i].ipal,(MFDB *)&img[W[i].id].mfdb);
}


/*******************************************************************************
	GENERE UNE IMAGE
*******************************************************************************/
void wgen(void)
{
	menuOff();
	wopen("");
	menuOn();
}


/*******************************************************************************
	TRAMAGE D'UNE IMAGE
*******************************************************************************/
int trmConvert(int alert,int isrc,int *idst,int psrc,int *pdst,MFDB *src,MFDB *dst,int mask,int dith,int nforce)
{
	char			*p;
	int			r;
	int			plane;

	glb.opt.d_trm=dith;
	_initRSC(FTRM,FTRMTXT);
	_initRSC(FTRM,FTRMPOP);
	if (glb.vdi.extnd[4]==src->fd_nplanes)
		plane=src->fd_nplanes;
	else if (glb.opt.trm==0)
		plane			=	glb.vdi.extnd[4];
	else if (glb.opt.trm==1)
		plane			=	src->fd_nplanes;
	else
	{
		switch (src->fd_nplanes)
		{
			case	1:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV1);
				break;
			case	2:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV2);
				break;
			case	4:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV4);
				break;
			case	8:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV8);
				break;
			case	16:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV16);
				break;
			case	24:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV24);
				break;
			case	32:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV32);
				break;
		}
		_obPutStr(glb.rsc.head.trindex[FTRM],FTRMSRC,p);
		switch (glb.vdi.extnd[4])
		{
			case	1:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV1);
				break;
			case	2:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV2);
				break;
			case	4:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV4);
				break;
			case	8:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV8);
				break;
			case	16:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV16);
				break;
			case	24:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV24);
				break;
			case	32:
				p=_obGetStr(glb.rsc.head.trindex[PCNV],PCNV32);
				break;
		}
		_obPutStr(glb.rsc.head.trindex[FTRM],FTRMDST,p);

		graf_mouse(ARROW,0);
		r=_winForm(FTRM,glb.rsc.head.frstr[WTRM],"",-1,-1,0,W_MODAL);
		if (r==FTRMAN)
			plane		=	src->fd_nplanes;
		else
			plane		=	glb.vdi.extnd[4];
	}
	dst->fd_nplanes=	plane;

	if (glb.opt.pal)
		mask|=TRM_PRG_PAL;
	else
		mask|=TRM_SUGG_PAL;

	if (glb.opt.d_trm!=dith)
		dith=glb.opt.d_trm;
	return _trmConvert(alert,isrc,idst,psrc,pdst,src,dst,mask,dith,nforce);
}


/*******************************************************************************
	Redimensionne une image
*******************************************************************************/
void wZoom(int i)
{
	MFDB	src,dst;
	int	j,k,r,idst,pdst;
	int	qual,force;

	_cls((long)&src,sizeof(MFDB));
	_cls((long)&dst,sizeof(MFDB));

	if (i==-1)
	{
		wind_get(0,WF_TOP,&i);
		i=_winFindWin(i);
	}

	if (i!=-1)
		if (W[i].type==TW_IMG)
		{
			working=i;
			j=W[i].id;
			_initRSC(FZOOM,FZMSRC);
			_initRSC(FZOOM,FZMDST);
			_initRSC(FZOOM,FZMPOP);
			_initRSC(FZOOM,FZMW);
			_initRSC(FZOOM,FZMH);
			_initRSC(FZOOM,FZMQUAL);
			_initRSC(FZOOM,FZMREP);

			r=_winForm(FZOOM,glb.rsc.head.frstr[WZOOM],"",-1,-1,0,W_MODAL);
			if (r!=FZMAN)
			{

				src.fd_addr		=	(void *)glb.mem.adr[W[i].in];
				src.fd_w			=	img[W[i].id].mfdb.w;
				src.fd_wdwidth	=	img[W[i].id].mfdb.wdw;
				src.fd_h			=	img[W[i].id].mfdb.h;
				src.fd_stand	=	img[W[i].id].mfdb.stand;
				src.fd_nplanes	=	img[W[i].id].mfdb.nplanes;

				dst.fd_addr		=	(void *)0L;
				dst.fd_w			=	atoi(_obGetStr(glb.rsc.head.trindex[FZOOM],FZMW));
				dst.fd_wdwidth	=	_word(dst.fd_w);
				dst.fd_h			=	atoi(_obGetStr(glb.rsc.head.trindex[FZOOM],FZMH));
				dst.fd_stand	=	img[W[i].id].mfdb.stand;
				dst.fd_nplanes	=	img[W[i].id].mfdb.nplanes;

				idst=NO_MEMORY;
				pdst=NO_MEMORY;

				if (glb.opt.zoom_hq)
					qual=TRM_ZOOM_HQ;
				else
					qual=TRM_ZOOM_LQ;
				if (glb.opt.zoom_rep)
					force=FALSE;
				else
					force=TRUE;

				r=_trmZoom(TRUE,W[i].in,&idst,W[i].ipal,&pdst,&src,&dst,TRM_IMPORT|TRM_SUGG_PAL,qual,force);

				if (r!=TRM_OK)
				{
					if (idst!=NO_MEMORY && idst!=W[i].in)
						_mFree(idst);
					if (pdst!=NO_MEMORY && pdst!=W[i].ipal)
						_mFree(pdst);
				}
				else
				{
					if (force)
					{
						k=-1;
						for (r=0;r<glb.opt.Win_Num;r++)
							if (!img[r].flag)
							{
								k=r;
								r=glb.opt.Win_Num;
							}
						if (k!=-1)
						{
							img[k].mfdb.seek		=	0L;
							img[k].mfdb.w			=	dst.fd_w;
							img[k].mfdb.h			=	dst.fd_h;
							img[k].mfdb.wdw		=	dst.fd_wdwidth;
							img[k].mfdb.stand		=	dst.fd_stand;
							img[k].mfdb.nplanes	=	dst.fd_nplanes;
							strcpy(img[k].name,img[j].name);
							strcpy(img[k].type,img[j].type);
							img[k].flag				=	1;
							img[k].oldx				=	0;
							img[k].oldy				=	0;
							img[k].x					=	0;
							img[k].y					=	0;
							img[k].w					=	img[k].mfdb.w;
							img[k].h					=	img[k].mfdb.h;
						}
					}
					else
					{
						if (idst!=W[i].in)
							_mFree(W[i].in);
						if (idst==W[i].in)
							W[i].in=NO_MEMORY;

						if (pdst!=W[i].ipal)
							_mFree(W[i].ipal);
						if (pdst==W[i].ipal)
							W[i].ipal=NO_MEMORY;

						_winClose(i);

						img[j].mfdb.seek		=	0L;
						img[j].mfdb.w			=	dst.fd_w;
						img[j].mfdb.h			=	dst.fd_h;
						img[j].mfdb.wdw		=	dst.fd_wdwidth;
						img[j].mfdb.stand		=	dst.fd_stand;
						img[j].mfdb.nplanes	=	dst.fd_nplanes;
						img[j].flag				=	1;
						img[j].oldx				=	0;
						img[j].oldy				=	0;
						img[j].x					=	0;
						img[j].y					=	0;
						img[j].w					=	img[j].mfdb.w;
						img[j].h					=	img[j].mfdb.h;
						k=j;
					}
					menuOff();
					wNewOpen(k,idst,pdst);
					menuOn();
				}
			}
			working=-1;
		}
}

void wNewOpen(int j,int imem,int pmem)
{
	window	win;
	char		*p;
	int		i;

	strcpy(win.name,img[j].name);
	p=strrchr(win.name,'.');
	if (p!=NULL)
		*p=0;
	strncpy(win.sname,win.name,wSNAMEMAX);

sprintf(glb.div.log,"imem=%i %li %li\n",imem,glb.mem.adr[imem],glb.mem.len[imem]);
_reportLog(LOG_RIM);
sprintf(glb.div.log,"pmem=%i %li %li\n",pmem,glb.mem.adr[pmem],glb.mem.len[pmem]);
_reportLog(LOG_RIM);

	win.gadget=W_NAME|W_CLOSER|W_FULLER|W_MOVER|W_SIZER|W_UPARROW|W_DNARROW|W_VSLIDE
				|W_LFARROW|W_RTARROW|W_HSLIDE|W_SMALLER;
	win.xgadget=0;

	win.wmini=WMINI;
	win.hmini=HMINI;
	win.wwork=min( img[j].mfdb.w , glb.aes.desk.w );
	win.hwork=min( img[j].mfdb.h , glb.aes.desk.h );
	win.xwork=glb.aes.desk.x+(glb.aes.desk.w-win.wwork)/2;
	win.ywork=glb.aes.desk.y+(glb.aes.desk.h-win.hwork)/2;
	win.xfull=glb.aes.desk.x;
	win.yfull=glb.aes.desk.y;
	win.wfull=glb.aes.desk.w;
	win.hfull=glb.aes.desk.h;
	win.xwind=-1;

	win.icon			=	WIC_DEF;
	win.ic_tree		=	-1;
	win.type			=	TW_IMG;
	win.id			=	j;
	win.in			=	imem;
	win.ipal			=	pmem;
	win.top			=	0;
	win.askclose	=	waskclose;
	win.close		=	wclose;
	win.full			=	wfull;
	win.arrow		=	warrow;
	win.hslid		=	whslid;
	win.vslid		=	wvslid;
	win.size			=	wsize;
	win.small		=	0;
	win.nsmall		=	0;
	win.init			=	winit;
	win.redraw		=	wredraw;
	win.keybd		=	wkey;
	win.move			=	0;
	win.clic			=	wclic;
	win.untop		=	0;
	win.ontop		=	0;
	i=_winOpen(&win);
	if (W[i].handle>=0)
	{
		wind_calc(WC_BORDER,W[i].gadget,W[i].xwork,W[i].ywork,img[j].w,img[j].h,&W[i].xfull,&W[i].yfull,&W[i].wfull,&W[i].hfull);
		W[i].xfull=max(glb.aes.desk.x,W[i].xfull);
		W[i].yfull=max(glb.aes.desk.y,W[i].yfull);
		W[i].wfull=min(glb.aes.desk.w,W[i].wfull);
		W[i].hfull=min(glb.aes.desk.h,W[i].hfull);
		Curr=j;
		_initRSC(FLOG,FLOGNMB);
		setLog();
		if (glb.opt.zap)
			_winSmall(i);
		_clearAesBuffer();
	}
}

void _updatePath(char *pname)
{
	int	i,j,obx,oby,obw,obh;

	if (glb.opt.MAJ)
	{
		if (pname[strlen(pname)-1L]!='\\')
			strcat(pname,"\\");
		if (glb.opt.pat[0][strlen(glb.opt.pat[0])-1L]!='\\')
			strcat(glb.opt.pat[0],"\\");

		if (strcmp(pname,glb.opt.pat[0]))
		{
			for (i=10;i>0;i--)
				strcpy(glb.opt.pat[i],glb.opt.pat[i-1]);
			strcpy(glb.opt.pat[0],pname);

			wind_update(BEG_UPDATE);
			i=_winFindId(TW_FORM,FSEL,TRUE);
			if (i!=-1)
			{
				for (j=0;j<=10;j++)
				{
					_initRSC(FSEL,FSELPATD+j);
					_coord(glb.rsc.head.trindex[FSEL],FSELPATD+j,TRUE,&obx,&oby,&obw,&obh);
					_winObdraw(i,glb.rsc.head.trindex[FSEL],FSELPATD+j,MAX_DEPTH,obx,oby,obw,obh);
				}
			}
			wind_update(END_UPDATE);
		}
	}
}
