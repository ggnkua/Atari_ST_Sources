/******************************************************************************/
/*	"Easy Gem" library Copyright (c)1994 by		Christophe BOYANIQUE				*/
/*																29 Rue R‚publique					*/
/*																37230 FONDETTES					*/
/*																FRANCE								*/
/*						*small* mail at email adress:	cb@spia.univ-tours.fr			*/
/******************************************************************************/
/*	This program is free software; you can redistribute it and/or modify it		*/
/*	under the terms of the GNU General Public License as published by the Free	*/
/*	Software Foundation; either version 2 of the License, or any later version.*/
/*	This program is distributed in the hope that it will be useful, but WITHOUT*/
/*	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or		*/
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for	*/
/*	more details.																					*/
/*	You should have received a copy of the GNU General Public License along		*/
/*	with this program; if not, write to the Free Software Foundation, Inc.,		*/
/*	675 Mass Ave, Cambridge, MA 02139, USA.												*/
/******************************************************************************/
/*																										*/
/*	Online Help handle																			*/
/*	This modul has been developped originally by:										*/
/*					Olivier Oeuillot																*/
/*	(many thanks !)																				*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	STRUCTS																							*/
/******************************************************************************/
typedef struct
{
	char		*ad_text;
	int		*ad_taille;
	int		*ad_buf;
	int		adtext;
	int		adtaille;
	int		adfile;
	int		adbuf;
	long		taille;				/*	long du fichier			*/
	int		nb_par;				/*	nbre de paragraphes		*/
	int		nb_lig;				/*	nbre de lignes				*/
	int		start:1;				/*	premier affichage ?		*/
}	DEF_TXT;


/******************************************************************************/
/*	VARIABLES																						*/
/******************************************************************************/
static	DEF_TXT	_help;
static	char		titre[MAX_LEN_HIST+1];
static	char		File[14];


/******************************************************************************/
/*	FUNCTIONS																						*/
/******************************************************************************/
static	void	_redrawHelp	(int i,int x,int y,int w,int h);
static	void	_init			(int i);
static	void	_popHelp		(int i,int n);
static	void	_slidHelp	(int i);
static	void	_sizeHelp	(int i,int x,int y);
static	void	_fullHelp	(int i);
static	void	_vslidHelp	(int i,int pos);
static	void	_arrowHelp	(int i,int type);
static	void	_closeHelp	(int i);
static	void	_clicHelp	(int i,int mx,int my,int mk,int nmb);
static	void	_keybdHelp	(int i,int key);
static	void	_makePop		(void);


/******************************************************************************/
/******************************************************************************/
void _initAide()
{
	int	i,j;

	_help.adtext=NO_MEMORY;
	_help.adtaille=NO_MEMORY;
	_help.adfile=NO_MEMORY;
	for (i=0;i<=MAX_HIST;i++)
		for (j=0;j<=MAX_LEN_HIST;j++)
		{
			histoire[i][j]=0;
			histoire2[i][j]=0;
		}
	cu_hist=cp_hist=0;
	_makePop();
}


/******************************************************************************/
/******************************************************************************/
int _ouvreHelp(char *name)
{
	int		ok=TRUE,err;
	long		lof,read;
	int		hand,i,*ad;
	char		file[FILENAME_MAX];

	strcpy(file,glb.opt.phelp);
	strcat(file,name);
	if (glb.opt.lang==L_FRENCH)
		strcat(file,".H_F");
	else
		strcat(file,".H_E");

	if (!_fexist(file,0))
	{
		if (glb.opt.lang==L_FRENCH)
			form_alert(1,__rsc.head.frstr[_0NOHLP]);
		else
			form_alert(1,__rsc.head.frstr[_1NOHLP]);
		return FALSE;
	}
	if (_help.adtext!=NO_MEMORY)	
	{
		_mFree(_help.adtext);
		_mFree(_help.adtaille);
		_mFree(_help.adfile);
		_help.ad_text=(char *)NULL;
		_help.ad_taille=(int *)NULL;
	}
	_help.start=1;

	err=_mAlloc(PAR_MAX*sizeof(int),MB_NORM,0);

	if (err==NO_MEMORY)
		ok=FALSE;
	else
		_help.adfile=err;

	if (ok)
	{
		err=_mAlloc(PAR_MAX*sizeof(int)*4,MB_NORM,0);
		if (err==NO_MEMORY)
		{
			ok=FALSE;
			_mFree(_help.adfile);
		}
		else
			_help.adtaille=err;
	}

	if (ok)
	{
		err=(int)Fopen(file,FO_READ);
		if (err<0)
		{
			ok=FALSE;
			_mFree(_help.adtaille);
			_mFree(_help.adfile);
		}
		else
		{
			hand=err;
			lof=Fseek(0L,hand,2);
			Fseek(0L,hand,0);
		}
	}

	if (ok)
	{
		err=_mAlloc(lof,MB_NORM,0);
		if (err==NO_MEMORY)
		{
			ok=FALSE;
			_mFree(_help.adtaille);
			_mFree(_help.adfile);
			Fclose(hand);
		}
		else
		{
			_help.adtext=err;
			_help.ad_text=(char *)mem.bloc[_help.adtext].adr;
		}
	}

	if (ok)
	{
		read=Fread(hand,lof,(void *)_help.ad_text);
		Fclose(hand);
		if (read!=lof)
		{
			ok=FALSE;
			_mFree(_help.adtaille);
			_mFree(_help.adfile);
			_mFree(_help.adtext);
		}
		else
		{
			ad=_help.ad_taille=(int *)mem.bloc[_help.adtaille].adr;
			ad=_help.ad_buf=(int *)((long)ad+PAR_MAX*sizeof(int)*2);
			for(i=0;i<PAR_MAX;ad[i]=0,i+=2);
			_help.taille=lof;
			_initHelp();
			for(i=0;i<cp_hist;i++)		/*	recherche si deja existant !	*/
				if (!strcmp(name,histoire[i]))
					cu_hist=i;
			strcpy(histoire2[cu_hist],titre);
			strncpy(histoire[cu_hist],name,MAX_LEN_HIST);
			histoire[cu_hist][MAX_LEN_HIST]=0;
			if (cp_hist<MAX_HIST && cu_hist==cp_hist)
			{
				cu_hist++;
				cp_hist++;
			}
			else if (cu_hist<MAX_HIST)
				cu_hist++;
			_makePop();
		}
	}
	if (ok)
		return TRUE;
	else
	{
		i=_winFindId(TW_HELP,0,TRUE);
		if (i!=-1)
			_winClose(i);
		return FALSE;
	}
}


/******************************************************************************/
/******************************************************************************/
void _Aide()
{
	char		buf[sizeof(window)];
	int		i,j;
	window	*win;

	i=_winFindWin(__TOP);
	if (i!=-1 && W[i].type==TW_HELP)
		return;
	j=_winFindId(TW_HELP,0,FALSE);
	strcpy(File,"");
	if (j!=-1)
		if (W[j].handle>0)
			_closed(j);
	if (i!=-1)
		strcpy(File,W[i].help);

	if (strlen(File)==0)
		strcpy(File,glb.help);

	win=(window *)buf;
	strcpy(win->name,_getLang(__rsc.head.frstr[WHLP]));
	strcpy(win->sname,"EGlib");
	strcpy(win->help,"");

	win->gadget=wNAME+wMOVE+wCLOSE+wMENU+wCYCLE+wICON+wFULL+wVSLIDE+wUARROW+wDARROW+wSIZE;

	win->xfull=glb.xdesk;
	win->yfull=glb.ydesk;
	win->wfull=glb.wdesk;
	win->hfull=glb.hdesk;
	win->xwork=-1;
	if (__x!=-1)
	{
		win->xwind=__x;
		win->ywind=__y;
		win->wwind=__w;
		win->hwind=__h;
	}
	else if ( (j==-1) || (Kbshift(-1)&4) )
	{
		win->xwind=win->xfull;
		win->ywind=win->yfull;
		win->wwind=win->wfull;
		win->hwind=win->hfull;
	}
	else
	{
		win->xwind=W[j].xwind;
		win->ywind=W[j].ywind;
		win->wwind=W[j].wwind;
		win->hwind=W[j].hwind;
	}

	win->popup		=	PHELP|FLAGS15;
	win->icon		=	ICHLP|FLAGS15;
	win->type		=	TW_HELP;
	win->id			=	0;

	win->pop			=	_popHelp;
	win->top			=	0;
	win->closed		=	_closeHelp;
	win->full		=	_fullHelp;
	win->arrow		=	_arrowHelp;
	win->hslid		=	0;
	win->vslid		=	_vslidHelp;
	win->size		=	_sizeHelp;
	win->untop		=	0;
	win->ontop		=	0;
	win->small		=	0;
	win->nsmall		=	0;
	win->init		=	0;
	win->redraw		=	_redrawHelp;
	win->keybd		=	_keybdHelp;
	win->move		=	0;
	win->clic		=	_clicHelp;
	i=_winOpen(win);
	if (i!=-1)
	{
		W[i].y=0;
		if ( !_ouvreHelp(File) )
			_winClose(i);
	}
}
#pragma warn -par


/******************************************************************************/
/******************************************************************************/
static void _init(int i)
{
	W[i].y=0;
	_ouvreHelp(File);
}


/******************************************************************************/
/******************************************************************************/
static void _popHelp(int i,int n)
{
	switch	(n+1)
	{
		case	PHLPIND:
			W[i].y=0;
			_ouvreHelp(glb.help);
			_winRedraw(i,0,0,0,0);
			break;
		case	PHLPDN:
			if (cu_hist>1)
			{
				cu_hist-=2;
				W[i].y=0;
				_ouvreHelp(histoire[cu_hist]);
				_winRedraw(i,0,0,0,0);
			}
			break;
		case	PHLPUP:
			if (cu_hist<cp_hist)
			{
				W[i].y=0;
				_ouvreHelp(histoire[cu_hist]);
				_winRedraw(i,0,0,0,0);
			}
			break;
		default:
			W[i].y=0;
			_ouvreHelp(histoire[n+1-PHLPHIST]);
			_winRedraw(i,0,0,0,0);
			break;
	}
}


/******************************************************************************/
/******************************************************************************/
void _initHelp()
{
	int		taille,nlig=0,max_taille,*tab;
	char		*txt,c;
	long		len=0,long_tot;
	char		name[255],*n,mot[255];
	int		x,i,j,f_ind=glb.opt.Hfnt,l=0,npar=0,*tsel,sel=0;
	int		max_base,base,taille_c,vect;

	x=_winFindId(TW_HELP,0,TRUE);
	_mousework();
	tab	=	(int *)mem.bloc[_help.adtaille].adr;
	txt	=	(char *)mem.bloc[_help.adtext].adr;
	tsel	=	(int *)mem.bloc[_help.adfile].adr;
	long_tot=_help.taille;
	titre[0]='\0';
	_winName(x,_getLang(__rsc.head.frstr[WHLP]),"EGLIB");

	if (glb.gdos)
		vst_font(glb.hvdi,font[f_ind].index);
	vect=font[f_ind].name[32];
	taille_c=glb.opt.hsiz;
	vst_rotation(glb.hvdi,0);
	if (vect)
		vst_arbpt(glb.hvdi,taille_c,&j,&base,&j,&taille);
	else
		vst_point(glb.hvdi,taille_c,&j,&base,&j,&taille);
	vst_alignment(glb.hvdi,ALI_BASE,ALI_LEFT,&j,&j);
	max_taille=taille;
	max_base=base;

	c=*txt++;
	len++;
	while(len<long_tot)
	{
		if (c==13)
		{
			_mousework();
			tab[nlig++]=max_taille;
			tab[nlig++]=max_base;
			max_taille=taille;
			max_base=base;
			l=0;
			npar++;
		}
		else if (c=='Ý')
		{
			c=*txt++;
			len++;
			if (c=='0')		/* Titre en bas */
			{
				n=name;
				for(c=*txt++,len++;c!='Ý' && c!=13 && len<long_tot;c=*txt++,len++)
					*n++=c;
				*n='\0';
				if (*name>'\0')
				{
					_winName(x,name,"EGLIB");
					if (titre[0]==0)
						strncpy(titre,name,MAX_LEN_HIST);
				}
			}
			else if (c=='1')		/* identificateur d'aide */
			{
				n=name;
				for(c=*txt++,len++;c!='Ý' && c!=13 && len<long_tot;c=*txt++,len++)
					*n++=c;
				*n='\0';
				if (*name>'\0')
					strncpy(titre,name,MAX_LEN_HIST);
			}
			else if ( (c=='f') && (glb.gdos) && (glb.opt.help) )		/* une nouvelle fonte */
			{
				n=name;
				for(c=*txt++,len++;c!='Ý' && c!=13 && len<long_tot;c=*txt++,len++)
					*n++=c;
				*n='\0';
				if (*name==0)
					f_ind=glb.opt.Hfnt;
				else if (!strcmp(name,"System Font"))
					f_ind=1;
				else
					for(f_ind=0,j=1;font[j].name[0]!=0 && !f_ind;j++)
						if (!strncmp(name,font[j].name,strlen(name)))
							f_ind=j;
				if (f_ind) 	/* fonte trouv‚e ? */
				{
					vect=font[f_ind].name[32];
					vst_font(glb.hvdi,font[f_ind].index);
					if (vect)
						vst_arbpt(glb.hvdi,taille_c,&j,&base,&j,&taille);
					else
						vst_point(glb.hvdi,taille_c,&j,&base,&j,&taille);
					if (max_taille<taille || !l)
					{
						max_taille=taille;
						max_base=base;
						l=1;
					}
				}
				else if (!strcmp(name,"System Font"))
				{
					if (glb.gdos)
						vst_font(glb.hvdi,font[f_ind].index);
					vst_point(glb.hvdi,taille_c,&j,&base,&j,&taille);
				}
			}
			else if (c=='h')	/* une hauteur */
			{
				j=0;
				if (*txt=='Ý')
				{
					i=1;
					j=(int)'*';
					txt++;
				}
				else if ( (*txt=='*') || (*txt=='/') )
				{
					j=(int)*txt++;
					for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<long_tot;c=*txt++,len++)
						if (c>='0' && c<='9') i=i*10+c-'0';
				}
				if ( (j) && (i>0) )
				{
					if (j==(int)'*')
						taille_c=min( glb.opt.hsiz*i , 144 );
					else
						taille_c=max( glb.opt.hsiz/i , 8 );
					if (vect)
						vst_arbpt(glb.hvdi,taille_c,&j,&base,&j,&taille);
					else
						vst_point(glb.hvdi,taille_c,&j,&base,&j,&taille);
				}
				if (max_taille<taille || !l)
				{
					max_taille=taille;
					max_base=base;
					l=1;
				}
			}
			else if (c=='s')	/* selection : fichier ? */
			{
				tsel[sel]=0;
				n=name;
				for(c=*txt++,len++;c!='Ý' && c!=13 && len<long_tot;c=*txt++,len++)
					*n++=c;
				*n='\0';
				if (*name>'\0')	
				{
					strcpy(mot,glb.opt.phelp);
					strcat(mot,name);
					if (glb.opt.lang==L_FRENCH)
						strcat(mot,".H_F");
					else
						strcat(mot,".H_E");
					if (_fexist(mot,0))
						tsel[sel]=1;
				}
				sel++;
			}
			else 
				for(;c!='Ý' && c!=13 && len<long_tot;c=*txt++,len++);
		}
		c=*txt++;
		len++;
	}
	_help.nb_par=npar;
	if (Kbshift(-1)&4)
	{
		if (glb.opt.full)
		{
			_winMove(x,glb.xdesk+(int)( 0.05*(double)glb.wdesk ),glb.ydesk+(int)( 0.05*(double)glb.hdesk ));
			_winSize(x,glb.wdesk-(int)( 0.1*(double)glb.wdesk ),glb.hdesk-(int)( 0.1*(double)glb.hdesk ));
		}
		else
		{
			_winMove(x,glb.xdesk,glb.ydesk);
			_winSize(x,glb.wdesk,glb.hdesk);
		}
	}
	if (x!=-1)
		_slidHelp(x);
	graf_mouse(ARROW,0);
}


/******************************************************************************/
/******************************************************************************/
static void _redrawHelp(int I,int x,int y,int w,int h)
{
	GRECT		clip;
	int		work[4];
	int		f_ind=glb.opt.Hfnt,*tab,*buf,*tsel;
	char		*txt,c,*n;
	long		lof,len=0;
	char		mot[255],name[255];
	int		lca,hca,lce,hce;
	int		j,i,ofm=0,ligne=0;
	int		posx=HLP_DECPAR,posy,ext[8],ext2[3],tattr[10];
	int		ofx,espace=0,aff=0,vect,nlig=0,stop=0,sel=0;
	int		tabul=HLP_TABUL,just1=HLP_DECLINE,just2=HLP_DECPAR,eff=TXT_NORMAL,taille_c;

	clip.g_x		=	x;
	clip.g_y		=	y;
	clip.g_w		=	w;
	clip.g_h		=	h;

	work[0]		=	W[I].xwork;
	work[1]		=	W[I].ywork;
	work[2]		=	W[I].wwork;
	work[3]		=	W[I].hwork;

	ofx=work[2];	/*ofx-=4;*/
	posy=-W[I].y;
	clip.g_w+=clip.g_x-1;
	clip.g_h+=clip.g_y-1;
	vs_clip(glb.hvdi,TRUE,(int *)&clip);
	vsf_color(glb.hvdi,glb.opt.chlpf);
	vswr_mode(glb.hvdi,MD_REPLACE);
	v_bar(glb.hvdi,(int *)&clip);
	vswr_mode(glb.hvdi,MD_TRANS);
	txt=(char *)mem.bloc[_help.adtext].adr;
	lof=_help.taille;
	tab=(int *)mem.bloc[_help.adtaille].adr;
	buf=(int *)((long)tab+PAR_MAX*sizeof(int)*2);
	tsel=(int *)mem.bloc[_help.adfile].adr;
	if (glb.gdos)
		vst_font(glb.hvdi,font[f_ind].index);
	vect=font[f_ind].name[32];
	taille_c=glb.opt.hsiz;
	vst_rotation(glb.hvdi,0);
	if (vect)
		vst_arbpt(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
	else
		vst_point(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
	vst_color(glb.hvdi,glb.opt.chlpt);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment(glb.hvdi,ALI_BASE,ALI_LEFT,&i,&i);
	vqt_width(glb.hvdi,32,ext2,ext2+1,ext2+2);

	c=*txt++;
	len++;
	mot[ofm]='\0';
	for (ofm=0;ofm<255;ofm++)
		mot[ofm]=0;
	ofm=0;
	while (len<lof && !stop)
	{
		if (c=='Ý')
		{
			if (ofm>0)
			{
				mot[ofm]='\0';
				if (vect)
					vqt_f_extent(glb.hvdi,mot,ext);
				else
					vqt_extent(glb.hvdi,mot,ext);
				if (ext[2]+posx>ofx)
				{
					if (posx) 
					{
						buf[nlig++]=ligne;
						posy+=tab[ligne];
					}
					posx=just1;
				}
				if (posy<=work[3] && posy+tab[ligne]>0)
				{
					if (vect)
						v_ftext(glb.hvdi,work[0]+posx,work[1]+posy+tab[ligne+1],mot);
					else
						v_gtext(glb.hvdi,work[0]+posx,work[1]+posy+tab[ligne+1],mot);
				}
				else
					stop=(work[1]+posy>work[3]);
				posx+=ext[2];
				ofm=espace=0;
			}
			c=*txt++;
			len++;
			if ( (c=='f') && (glb.gdos) && (glb.opt.help) )
			{
				n=name;
				for(c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					*n++=c;
				*n='\0';
				if (*name==0)
					f_ind=glb.opt.Hfnt;
				else if (!strcmp(name,"System Font"))
					f_ind=1;
				else
					for(f_ind=0,j=1;font[j].name[0]!=0 && !f_ind;j++)
						if (!strncmp(name,font[j].name,strlen(name)))
							f_ind=j;
				if (f_ind)
				{
					vect=font[f_ind].name[32];
					vst_font(glb.hvdi,font[f_ind].index);
					if (vect)
						vst_arbpt(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					else
						vst_point(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					vqt_width(glb.hvdi,32,ext2,ext2+1,ext2+2); 
				}
			}
			else if (c=='h')	/* une hauteur */
			{
				j=0;
				if (*txt=='Ý')
				{
					i=1;
					j=(int)'*';
					txt++;
				}
				else if ( (*txt=='*') || (*txt=='/') )
				{
					j=(int)*txt++;
					for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
						if (c>='0' && c<='9') i=i*10+c-'0';
				}
				if ( (j) && (i>0) )
				{
					if (j==(int)'*')
						taille_c=min( glb.opt.hsiz*i , 144 );
					else
						taille_c=max( glb.opt.hsiz/i , 8 );
					if (vect)
						vst_arbpt(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					else
						vst_point(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					vqt_width(glb.hvdi,32,ext2,ext2+1,ext2+2);
				}
			}
			else if (c=='c')	/* la couleur ! */
			{
				if (*txt=='Ý')
				{
					i=glb.opt.chlpt;
					txt++;
				}
				else
					for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
						if (c>='0' && c<='9') i=i*10+c-'0';
				vst_color(glb.hvdi,i);
			}
			else if (c=='e')	/* les effets ! */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				eff=vst_effects(glb.hvdi,i);
			}
			else if (c=='j')	/* decalage en cas de passage … la ligne ! */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				just1=i;
			}
			else if (c=='k')	/* decalage en cas de premiere ligne ! */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				just2=i;
			}
			else if (c=='d')	/* definition des TABULATIONs */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				tabul=i;
			}
			else if (c=='t')	/* tabulation */
			{
				posx=((posx/tabul)+1)*tabul;
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
				aff=1;	/* permet un eventuel passage a la ligne */
			}
			else if (c=='s')	/* selectionnable */
			{
				vqt_attributes(glb.hvdi,tattr);
				vst_effects(glb.hvdi,eff+TXT_UNDERLINED);
				if (!tsel[sel++])
					tattr[0]=vst_color(glb.hvdi,COUL_FALSE);
				else
					tattr[0]=vst_color(glb.hvdi,COUL_TRUE);
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
			}
			else if (c=='u')	/* plus selectionnable ! */
			{
				vst_color(glb.hvdi,tattr[1]);
				vst_effects(glb.hvdi,eff);
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
			}
			else  
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
		}
		else if (c==' ')
		{
			if (ofm>0)
			{
				mot[ofm]='\0';
				if (vect)
					vqt_f_extent(glb.hvdi,mot,ext);
				else
					vqt_extent(glb.hvdi,mot,ext);
				if (ext[2]+posx>ofx && aff)
				{
					buf[nlig++]=ligne;
					posy+=tab[ligne];
					posx=just1;
					espace=0;
				}
				if (posy<=work[3] && posy+tab[ligne]>0)
				{
					if (vect)
						v_ftext(glb.hvdi,work[0]+posx,work[1]+posy+tab[ligne+1],mot);
					else
						v_gtext(glb.hvdi,work[0]+posx,work[1]+posy+tab[ligne+1],mot);
				}
				else
					stop=(work[1]+posy>work[3]);
				posx+=ext[2];
				ofm=espace=0;
				aff=1;
			}
			espace+=*ext2;
		}
		else if (c==13)
		{
			if (ofm>0)
			{
				mot[ofm]='\0';
				if (vect)
					vqt_f_extent(glb.hvdi,mot,ext);
				else
					vqt_extent(glb.hvdi,mot,ext);
				if (ext[2]+posx>ofx && aff)
				{
					buf[nlig++]=ligne;
					posy+=tab[ligne];
					posx=just1;
				}
				if (posy<=work[3]  && posy+tab[ligne]>0)
				{
					if (vect)
						v_ftext(glb.hvdi,work[0]+posx,work[1]+posy+tab[ligne+1],mot);
					else
						v_gtext(glb.hvdi,work[0]+posx,work[1]+posy+tab[ligne+1],mot);
				}
				else
					stop=(work[1]+posy>work[3]);
			}
			buf[nlig++]=ligne;
			posy+=tab[ligne];
			aff=espace=ofm=0;
			posx=just2;
			ligne+=2;
			if (*txt==10) 
			{
				txt++;	 /* passe le 10 ! */
				len++;
			}
		}
		else
		{
			if (espace)		/* rajoute au mot courrant */
			{
				posx+=espace;
				espace=0;
			}
			mot[ofm++]=c;
		}
		c=*txt++;
		len++;
		if (stop && _help.start)
			stop=0;
	}
	vs_clip(glb.hvdi,FALSE,(int *)&clip);
}


/******************************************************************************/
/******************************************************************************/
static void _slidHelp(int I)
{
	int		work[4];
	int		f_ind=glb.opt.Hfnt,*tab,*buf;
	char		*txt,c,*n;
	long		lof,len=0;
	char		mot[255],name[255];
	int		lca,hca,lce,hce;
	int		j,i,ofm=0,ligne=0;
	int		posx=HLP_DECPAR,posy,ext[8],ext2[3];
	int		ofx,espace=0,aff=0,vect,nlig=0,stop=0;
	int		tabul=HLP_TABUL,just1=HLP_DECLINE,just2=HLP_DECPAR,eff=TXT_NORMAL,taille_c;

	_mousework();
	_help.start=1;
	work[0]		=	W[I].xwork;
	work[1]		=	W[I].ywork;
	work[2]		=	W[I].wwork;
	work[3]		=	W[I].hwork;

	ofx=work[2];	/*ofx-=4;*/
	posy=-W[I].y;
	txt=(char *)mem.bloc[_help.adtext].adr;
	tab=(int *)mem.bloc[_help.adtaille].adr;
	buf=(int *)((long)tab+PAR_MAX*sizeof(int)*2);
	lof=_help.taille;
	if (glb.gdos)
		vst_font(glb.hvdi,font[f_ind].index);
	vect=font[f_ind].name[32];
	taille_c=glb.opt.hsiz;
	vst_rotation(glb.hvdi,0);
	if (vect)
		vst_arbpt(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
	else
		vst_point(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment(glb.hvdi,ALI_BASE,ALI_LEFT,&i,&i);
	vqt_width(glb.hvdi,32,ext2,ext2+1,ext2+2);

	c=*txt++;
	len++;
	mot[ofm]='\0';
	for (ofm=0;ofm<255;ofm++) mot[ofm]=0;
	ofm=0;
	while (len<lof && !stop)
	{
		if (c=='Ý')
		{
			if (ofm>0)
			{
				mot[ofm]='\0';
				if (vect)
					vqt_f_extent(glb.hvdi,mot,ext);
				else
					vqt_extent(glb.hvdi,mot,ext);
				if (ext[2]+posx>ofx)
				{
					if (posx)
					{
						buf[nlig++]=ligne;
						posy+=tab[ligne];
					}
					posx=just1;
				}
				if (work[1]+posy<work[3] && posy+tab[ligne]>0)
				{
				}
				else
					stop=(work[1]+posy>work[3]);
				posx+=ext[2];
				ofm=espace=0;
			}
			c=*txt++;
			len++;
			if ( (c=='f') && (glb.gdos) && (glb.opt.help) )		/* choix de la fonte */
			{
				n=name;
				for(c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					*n++=c;
				*n='\0';
				if (*name==0)
					f_ind=glb.opt.Hfnt;
				else if (!strcmp(name,"System Font"))
					f_ind=1;
				else
					for(f_ind=0,j=1;font[j].name[0]>0 && !f_ind;j++)
						if (!strncmp(name,font[j].name,strlen(name)))
							f_ind=j;
				if (f_ind) 		/* fonte trouv‚e ? */
				{
					vect=font[f_ind].name[32];
					vst_font(glb.hvdi,font[f_ind].index);
					if (vect)
						vst_arbpt(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					else
						vst_point(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					vqt_width(glb.hvdi,32,ext2,ext2+1,ext2+2); 
				}
			}
			else if (c=='h')	/* une hauteur */
			{
				j=0;
				if (*txt=='Ý')
				{
					i=1;
					j=(int)'*';
					txt++;
				}
				else if ( (*txt=='*') || (*txt=='/') )
				{
					j=(int)*txt++;
					for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
						if (c>='0' && c<='9') i=i*10+c-'0';
				}
				if ( (j) && (i>0) )
				{
					if (j==(int)'*')
						taille_c=min( glb.opt.hsiz*i , 144 );
					else
						taille_c=max( glb.opt.hsiz/i , 8 );
					if (vect)
						vst_arbpt(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					else
						vst_point(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					vqt_width(glb.hvdi,32,ext2,ext2+1,ext2+2);
				}
			}
			else if (c=='e')	/* les effets ! */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				eff=vst_effects(glb.hvdi,i);
			}
			else if (c=='j')	/* decalage en cas de passage … la ligne ! */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				just1=i;
			}
			else if (c=='k')	/* decalage en cas de premiere ligne ! */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				just2=i;
			}
			else if (c=='d')	/* definition des TABULATIONs */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				tabul=i;
			}
			else if (c=='t')	/* tabulation */
			{
				posx=((posx/tabul)+1)*tabul;
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
				aff=1;	/* permet un eventuel passage a la ligne */
			}
			else if (c=='s')	/* selectionnable */
			{
				vst_effects(glb.hvdi,eff+TXT_UNDERLINED);
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
			}
			else if (c=='u')	/* plus selectionnable ! */
			{
				vst_effects(glb.hvdi,eff);
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
			}
			else  
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
		}
		else if (c==' ')
		{
			if (ofm>0)
			{
				mot[ofm]='\0';
				if (vect)
					vqt_f_extent(glb.hvdi,mot,ext);
				else
					vqt_extent(glb.hvdi,mot,ext);
				if (ext[2]+posx>ofx && aff)
				{
					buf[nlig++]=ligne;
					posy+=tab[ligne];
					posx=just1;
					espace=0;
				}
				if (work[1]+posy<work[3] && posy+tab[ligne]>0)
				{
				}
				else
					stop=(work[1]+posy>work[3]);
				posx+=ext[2];
				ofm=espace=0;
				aff=1;
			}
			espace+=*ext2;
		}
		else if (c==13)
		{
			_mousework();
			if (ofm>0)
			{
				mot[ofm]='\0';
				if (vect)
					vqt_f_extent(glb.hvdi,mot,ext);
				else
					vqt_extent(glb.hvdi,mot,ext);
				if (ext[2]+posx>ofx && aff)
				{
					buf[nlig++]=ligne;
					posy+=tab[ligne];
					posx=just1;
				}
				if (work[1]+posy<work[3]  && posy+tab[ligne]>0)
				{
				}
				else
					stop=(work[1]+posy>work[3]);
			}
			buf[nlig++]=ligne;
			posy+=tab[ligne];
			aff=espace=ofm=0;
			posx=just2;
			ligne+=2;
			if (*txt==10) 
			{
				txt++;	 /* passe le 10 ! */
				len++;
			}
		}
		else
		{		/* rajoute au mot courrant */
			if (espace)
			{
				posx+=espace;
				espace=0;
			}
			mot[ofm++]=c;
		}
		c=*txt++;
		len++;
		if (stop && _help.start)
			stop=0;
	}
	_help.nb_lig=nlig;
	i=I;
	W[i].h=posy+W[i].y+2;
	if ( (Kbshift(-1)&4) && (W[i].h<W[i].hwork) )
		_winWsize(i,W[i].wwork,W[i].h);
	if (W[i].h>W[i].hwork)
	{
		W[i].yslidlen=(int)( (double)1000 * ((double)W[i].hwork/(double)W[i].h) );
		W[i].yslidpos=(int)( ((double)1000*(double)W[i].y) / (double)(W[i].h-W[i].hwork) );
	}
	else
	{
		W[i].yslidpos=0;
		W[i].yslidlen=1000;
	}
	_help.start=0;
	_winVslid(i);
	graf_mouse(ARROW,0);
}


/******************************************************************************/
/******************************************************************************/
static void _clicHelp(int I,int mx,int my,int mk,int nmb)
{
	int		work[4];
	int		f_ind=glb.opt.Hfnt,*tab,*buf;
	char		*txt,c,*n;
	long		lof,len=0;
	char		mot[255],name[32],name_sel[32];
	int		lca,hca,lce,hce;
	int		j,i,ofm=0,ligne=0;
	int		posx=HLP_DECPAR,posy,ext[8],ext2[3],tattr[10];
	int		ofx,espace=0,aff=0,vect,nlig=0,selec=FALSE,stop=FALSE,trouve=FALSE;
	int		tabul=HLP_TABUL,just1=HLP_DECLINE,just2=HLP_DECPAR,eff=TXT_NORMAL,taille_c;

	work[0]		=	W[I].xwork;
	work[1]		=	W[I].ywork;
	work[2]		=	W[I].wwork;
	work[3]		=	W[I].hwork;

	ofx=work[2];	/*ofx-=4;*/
	posy=-W[I].y;
	lof=_help.taille;
	tab=(int *)mem.bloc[_help.adtaille].adr;
	buf=(int *)((long)tab+PAR_MAX*sizeof(int)*2);
	txt=(char *)mem.bloc[_help.adtext].adr;
	if (glb.gdos)
		vst_font(glb.hvdi,font[f_ind].index);
	vect=font[f_ind].name[32];
	taille_c=glb.opt.hsiz;
	vst_rotation(glb.hvdi,0);
	if (vect)
		vst_arbpt(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
	else
		vst_point(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
	vst_color(glb.hvdi,glb.opt.chlpt);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment(glb.hvdi,ALI_BASE,ALI_LEFT,&i,&i);
	vqt_width(glb.hvdi,32,ext2,ext2+1,ext2+2);

	c=*txt++;
	len++;
	if (nmb==2) while (len<lof && !stop)
	{
		if (c=='Ý')
		{
			if (ofm>0)
			{
				mot[ofm]='\0';
				if (vect)
					vqt_f_extent(glb.hvdi,mot,ext);
				else
					vqt_extent(glb.hvdi,mot,ext);
				if (ext[2]+posx>ofx)
				{
					if (posx) 
					{
						buf[nlig++]=ligne;
						posy+=tab[ligne];
					}
					posx=just1;
				}
				if (posy<work[3] && posy+tab[ligne]>0)
				{
					if (selec && mx>=work[0]+posx && my>=work[1]+posy && mx<=work[0]+posx+ext[2] && my<=work[1]+posy+tab[ligne])
						trouve=stop=TRUE;
				}
				else
					stop=(work[1]+posy>work[3]);
				posx+=ext[2];
				ofm=espace=0;
			}
			c=*txt++;
			len++;
			if ( (c=='f') && (glb.gdos) && (glb.opt.help) )		/* choix de la fonte */
			{
				n=name;
				for(c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					*n++=c;
				*n='\0';
				if (*name==0)
					f_ind=glb.opt.Hfnt;
				else if (!strcmp(name,"System Font"))
					f_ind=1;
				else
					for(f_ind=0,j=1;font[j].name[0]>0 && !f_ind;j++)
						if (!strncmp(name,font[j].name,strlen(name)))
							f_ind=j;
				if (f_ind) 		/* fonte trouv‚e ? */
				{
					vect=font[f_ind].name[32];
					vst_font(glb.hvdi,font[f_ind].index);
					if (vect)
						vst_arbpt(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);	/* taille de la fonte */
					else
						vst_point(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);	/* taille de la fonte */
					vqt_width(glb.hvdi,32,ext2,ext2+1,ext2+2); 
				}
			}
			else if (c=='h')	/* une hauteur */
			{
				j=0;
				if (*txt=='Ý')
				{
					i=1;
					j=(int)'*';
					txt++;
				}
				else if ( (*txt=='*') || (*txt=='/') )
				{
					j=(int)*txt++;
					for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
						if (c>='0' && c<='9') i=i*10+c-'0';
				}
				if ( (j) && (i>0) )
				{
					if (j==(int)'*')
						taille_c=min( glb.opt.hsiz*i , 144 );
					else
						taille_c=max( glb.opt.hsiz/i , 8 );
					if (vect)
						vst_arbpt(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					else
						vst_point(glb.hvdi,taille_c,&lca,&hca,&lce,&hce);
					vqt_width(glb.hvdi,32,ext2,ext2+1,ext2+2);
				}
			}
			else if (c=='e')	/* les effets ! */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				eff=vst_effects(glb.hvdi,i);
			}
			else if (c=='j')	/* decalage en cas de passage … la ligne ! */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				just1=i;
			}
			else if (c=='k')	/* decalage en cas de premiere ligne ! */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				just2=i;
			}
			else if (c=='d')	/* definition des TABULATIONs */
			{
				for(i=0,c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					if (c>='0' && c<='9') i=i*10+c-'0';
				tabul=i;
			}
			else if (c=='t')	/* tabulation */
			{
				posx=((posx/tabul)+1)*tabul;
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
				aff=1;	/* permet un eventuel passage a la ligne */
			}
			else if (c=='s')	/* selectionnable */
			{
				vqt_attributes(glb.hvdi,tattr);
				vst_effects(glb.hvdi,eff+TXT_UNDERLINED);
				n=name_sel;
				for(c=*txt++,len++;c!='Ý' && c!=13 && len<lof;c=*txt++,len++)
					*n++=c;
				*n='\0';
				selec=TRUE;
			}
			else if (c=='u')	/* plus selectionnable ! */
			{
				vst_color(glb.hvdi,tattr[1]);
				vst_effects(glb.hvdi,eff);
				selec=FALSE;	/* permet un eventuel passage a la ligne */
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
			}
			else  
				for(;c!='Ý' && c!=13 && len<lof;c=*txt++,len++);
		}
		else if (c==' ')
		{
			if (ofm>0)
			{
				mot[ofm]='\0';
				if (vect)
					vqt_f_extent(glb.hvdi,mot,ext);
				else
					vqt_extent(glb.hvdi,mot,ext);
				if (ext[2]+posx>ofx && aff)
				{
					buf[nlig++]=ligne;
					posy+=tab[ligne];
					posx=just1;
					espace=0;
				}
				if (posy<work[3] && posy+tab[ligne]>0)
				{
					if (selec && mx>=work[0]+posx && my>=work[1]+posy && mx<=work[0]+posx+ext[2] && my<=work[1]+posy+tab[ligne])
						trouve=stop=TRUE;
				}
				else
					stop=(work[1]+posy>work[3]);
				posx+=ext[2];
				ofm=espace=0;
				aff=1;
			}
			espace+=*ext2;
		}
		else if (c==13)
		{
			if (ofm>0)
			{
				mot[ofm]='\0';
				if (vect)
					vqt_f_extent(glb.hvdi,mot,ext);
				else
					vqt_extent(glb.hvdi,mot,ext);
				if (ext[2]+posx>ofx && aff)
				{
					buf[nlig++]=ligne;
					posy+=tab[ligne];
					posx=just1;
				}
				if (posy<work[3] && posy+tab[ligne]>0)
				{
					if (selec && mx>=work[0]+posx && my>=work[1]+posy && mx<=work[0]+posx+ext[2] && my<=work[1]+posy+tab[ligne])
						trouve=stop=TRUE;
				}
				else
					stop=(work[1]+posy>work[3]);
			}
			buf[nlig++]=ligne;
			posy+=tab[ligne];
			aff=espace=ofm=0;
			posx=just2;
			ligne+=2;
			if (*txt==10)
			{
				txt++;	 /* passe le 10 ! */
				len++;
			}
		}
		else
		{
			if (espace)			/* rajoute au mot courant */
			{
				if (selec && mx>=work[0]+posx && my>=work[1]+posy && mx<=work[0]+posx+espace && my<=work[1]+posy+tab[ligne])
					trouve=stop=TRUE;
				posx+=espace;
				espace=0;
			}
			mot[ofm++]=c;
		}
		c=*txt++;
		len++;
	}
	if (stop && trouve)
	{
		if ( _ouvreHelp(name_sel) )
		{
			W[I].y=0;
			_winRedraw(I,0,0,0,0);
		}
	}
}


/******************************************************************************/
/******************************************************************************/
static void _sizeHelp(int i,int x,int y)
{
	W[i].y=0;
	_initHelp();
	_winRedraw(i,0,0,0,0);
}


/******************************************************************************/
/******************************************************************************/
static void _fullHelp(int i)
{
	W[i].y=0;
	_initHelp();
}


/******************************************************************************/
/******************************************************************************/
static void _vslidHelp(int i,int pos)
{
	int		dum;

	if (W[i].hwork!=W[i].h)
	{
		dum=(double)pos*(double)(W[i].h-W[i].hwork)/1000.0;
		if (dum!=W[i].y)
		{
			W[i].y=dum;
			_winVslid(i);
			_redraw(i,W[i].xwork,W[i].ywork,W[i].wwork,W[i].hwork);
		}
	}
}


/******************************************************************************/
/******************************************************************************/
static void _arrowHelp(int i,int type)
{
	int		dum;

	switch (type)
	{
		case	WA_UPPAGE:
			dum			=	W[i].y;
			W[i].y		=	max( 0, W[i].y-W[i].hwork );
			if ( (dum!=W[i].y) && (W[i].h!=W[i].hwork) )
			{
				W[i].yslidpos=(int)( ((double)1000*(double)W[i].y) / (double)(W[i].h-W[i].hwork) );
				_winVslid(i);
				_redraw(i,W[i].xwork,W[i].ywork,W[i].wwork,W[i].hwork);
			}
			break;
		case	WA_DNPAGE:
			dum			=	W[i].y;
			W[i].y		=	min( W[i].h-W[i].hwork , W[i].y+W[i].hwork );
			if ( (dum!=W[i].y) && (W[i].h!=W[i].hwork) )
			{
				W[i].yslidpos=(int)( ((double)1000*(double)W[i].y) / (double)(W[i].h-W[i].hwork) );
				_winVslid(i);
				_redraw(i,W[i].xwork,W[i].ywork,W[i].wwork,W[i].hwork);
			}
			break;
		case	WA_UPLINE:
			dum			=	W[i].y;
			W[i].y		=	max( 0, W[i].y-W[i].hwork/10 );
			if ( (dum!=W[i].y) && (W[i].h!=W[i].hwork) )
			{
				W[i].yslidpos=(int)( ((double)1000*(double)W[i].y) / (double)(W[i].h-W[i].hwork) );
				_winVslid(i);
				_redraw(i,W[i].xwork,W[i].ywork,W[i].wwork,W[i].hwork);
			}
			break;
		case	WA_DNLINE:
			dum			=	W[i].y;
			W[i].y		=	min( W[i].h-W[i].hwork , W[i].y+W[i].hwork/10 );
			if ( (dum!=W[i].y) && (W[i].h!=W[i].hwork) )
			{
				W[i].yslidpos=(int)( ((double)1000*(double)W[i].y) / (double)(W[i].h-W[i].hwork) );
				_winVslid(i);
				_redraw(i,W[i].xwork,W[i].ywork,W[i].wwork,W[i].hwork);
			}
			break;
	}
}


/******************************************************************************/
/******************************************************************************/
static void _closeHelp(int i)
{
	if ( _help.adtext!=NO_MEMORY )
	{
		_mFree(_help.adtext);
		_mFree(_help.adtaille);
		_mFree(_help.adfile);
		_help.ad_text		=	(char *)NULL;
		_help.ad_taille	=	(int *)NULL;
	}
}


/******************************************************************************/
/******************************************************************************/
static void _keybdHelp(int i,int key)
{
	switch	(key&0xFF)
	{
		case	K_LEFT:
			if (cu_hist>1)
			{
				cu_hist-=2;
				W[i].y=0;
				_ouvreHelp(histoire[cu_hist]);
				_winRedraw(i,0,0,0,0);
			}
			break;
		case	K_RIGHT:
			if (cu_hist<cp_hist)
			{
				W[i].y=0;
				_ouvreHelp(histoire[cu_hist]);
				_winRedraw(i,0,0,0,0);
			}
			break;
		case	K_UP:
			if (key&KF_SHIFT)
				_arrowHelp(i,WA_UPPAGE);
			else
				_arrowHelp(i,WA_UPLINE);
			break;
		case	K_DOWN:
			if (key&KF_SHIFT)
				_arrowHelp(i,WA_DNPAGE);
			else
				_arrowHelp(i,WA_DNLINE);
			break;
		case	K_UNDO:
			_closed(i);
			break;
	}
}
#pragma warn +par


/******************************************************************************/
/******************************************************************************/
static void _makePop()
{
	OBJECT	*tree;
	char		txt[MAX_LEN_HIST+4];
	int		i,j;

	tree=__rsc.head.trindex[PHELP];
	for (i=0;i<MAX_HIST;i++)
	{
		for (j=0;j<MAX_LEN_HIST+4;j++)
			txt[j]=0;
		strcpy(txt,"  ");
		if (strlen(histoire[i])>2)
		{
			if (strlen(histoire2[i])>2)
				strncat(txt,histoire2[i],MAX_LEN_HIST);
			else if (strlen(histoire[i])>2)
				strncat(txt,histoire[i],MAX_LEN_HIST);
			tree[PHLPHIST+i].ob_state&=~DISABLED;
		}
		else
			tree[PHLPHIST+i].ob_state|=DISABLED;
		if (i==cu_hist-1)
			tree[PHLPHIST+i].ob_state|=CHECKED;
		else
			tree[PHLPHIST+i].ob_state&=~CHECKED;
		_obPutStr(tree,PHLPHIST+i,txt);
	}
}
