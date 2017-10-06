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
/*	SEVERAL USEFULL FUNCTIONS																	*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	FUNCTIONS																						*/
/******************************************************************************/
static	long	_PutMyId			(void);
static	long	_PutOldId		(void);


/******************************************************************************/
/*	VARIABLES																						*/
/******************************************************************************/
static	int		mousenum=0;
static	BASPAG	*__OldPid;
static	BASPAG	**__Run;
static	int		__swap=0;


/******************************************************************************/
/*	Copy a text in an object																	*/
/******************************************************************************/
void _obPutStr(OBJECT *tree,int n,const char *str)
{
	UBLK			*user;

	switch (tree[n].ob_type&0xFF)
	{
		case	G_USERDEF:
			user=(UBLK *)tree[n].ob_spec.userblk->ub_parm;
			switch	(user->type)
			{
				case	G_TITLE:
				case	G_STRING:
				case	G_BUTTON:
					strcpy((char *)user->spec,str);
					break;
				case	G_TEXT:
				case	G_BOXTEXT:
				case	G_FTEXT:
				case	G_FBOXTEXT:
					strcpy((char *)(((TEDINFO *)user->spec)->te_ptext),str);
					break;
				case	G_ICON:
				case	G_CICON:
					strcpy(	(char *)(((ICONBLK*)user->spec)->ib_ptext),str);
					break;
			}
			break;
		case	G_TITLE:
		case	G_STRING:
		case	G_BUTTON:
			strcpy(tree[n].ob_spec.free_string,str);
			break;
		case	G_TEXT:
		case	G_BOXTEXT:
		case	G_FTEXT:
		case	G_FBOXTEXT:
			if (tree[n].ob_spec.tedinfo->te_ptext!=NULL)
			strcpy(tree[n].ob_spec.tedinfo->te_ptext,str);
			break;
		case	G_CICON:
		case	G_ICON:
			strcpy(tree[n].ob_spec.iconblk->ib_ptext,str);
			break;
	}
}


/******************************************************************************/
/*	Put a size limited string																	*/
/******************************************************************************/
void _putPath(OBJECT *tree,int n,int len,char *name)
{
	char			*s,*d;
	UBLK			*user;

	d=NULL;
	s=(char *)name;
	s+=strlen(name)-len;
	if (strlen(name)<len)
		_obPutStr(tree,n,name);
	else switch (tree[n].ob_type&0xFF)
	{
		case	G_USERDEF:
			user=(UBLK *)tree[n].ob_spec.userblk->ub_parm;
			switch	(user->type)
			{
				case	G_TITLE:
				case	G_STRING:
				case	G_BUTTON:
					d=(char *)user->spec;
					break;
				case	G_TEXT:
				case	G_BOXTEXT:
				case	G_FTEXT:
				case	G_FBOXTEXT:
					d=(char *)((TEDINFO *)user->spec)->te_ptext;
					break;
			}
			break;
		case	G_TITLE:
		case	G_STRING:
		case	G_BUTTON:
			d=tree[n].ob_spec.free_string;
			break;
		case	G_TEXT:
		case	G_BOXTEXT:
		case	G_FTEXT:
		case	G_FBOXTEXT:
			d=tree[n].ob_spec.tedinfo->te_ptext;
			break;
	}
	if (d!=NULL)
	{
		strcpy(d,s);
		*d++=46;
		*d++=46;
		*d++=46;
	}
}


/******************************************************************************/
/*	Return a pointer on a string																*/
/******************************************************************************/
char *_obGetStr(OBJECT *tree,int objc)
{
	UBLK			*user;
	char			*tx;

	tx=NULL;
	switch (tree[objc].ob_type&0xFF)
	{
		case	G_USERDEF:
			user=(UBLK *)tree[objc].ob_spec.userblk->ub_parm;
			switch	(user->type)
			{
				case	G_TITLE:
				case	G_STRING:
				case	G_BUTTON:
					tx=(char *)user->spec;
					break;
				case	G_TEXT:
				case	G_BOXTEXT:
				case	G_FTEXT:
				case	G_FBOXTEXT:
					tx=(char *)(((TEDINFO *)user->spec)->te_ptext);
					break;
			}
			break;
		case	G_TITLE:
		case	G_STRING:
		case	G_BUTTON:
			tx=tree[objc].ob_spec.free_string;
			break;
		case	G_TEXT:
		case	G_BOXTEXT:
		case	G_FTEXT:
		case	G_FBOXTEXT:
			tx=tree[objc].ob_spec.tedinfo->te_ptext;
			break;
	}
	return tx;
}


/******************************************************************************/
/*	Returns the father object ot another													*/
/******************************************************************************/
int _father(OBJECT *tree,int child)
{
	int		i;

	i=child;
	do
	{
		i=tree[i].ob_next;
	} while (i>child);
	return i;
}


/******************************************************************************/
/*	Calcul the intersect of two rect															*/
/******************************************************************************/
int _rcIntersect(GRECT *p1,GRECT *p2)
{
	int		tx,ty,tw,th;

	if ( (p1->g_x==0) && (p1->g_y==0) && (p1->g_w==0) && (p1->g_h==0) )
	{
		tx=p2->g_x;
		ty=p2->g_y;
		tw=p2->g_w;
		th=p2->g_h;
	}
	else if ( (p2->g_x==0) && (p2->g_y==0) && (p2->g_w==0) && (p2->g_h==0) )
	{
		tx=p1->g_x;
		ty=p1->g_y;
		tw=p1->g_w;
		th=p1->g_h;
	}
	else
	{
		tw=min(p2->g_x+p2->g_w,p1->g_x+p1->g_w);
		th=min(p2->g_y+p2->g_h,p1->g_y+p1->g_h);
		tx=max(p2->g_x,p1->g_x);
		ty=max(p2->g_y,p1->g_y);
	}
	p2->g_x=tx;
	p2->g_y=ty;
	p2->g_w=tw-tx;
	p2->g_h=th-ty;
	return ((tw>tx) && (th>ty));
}


/******************************************************************************/
/*	Clip a rect area																				*/
/******************************************************************************/
void _setClip(int flag,GRECT *area)
{
	int		pxy[4];

	pxy[0]=area->g_x;
	pxy[1]=area->g_y;
	pxy[2]=area->g_w+area->g_x-1;
	pxy[3]=area->g_h+area->g_y-1;
	vs_clip (glb.hvdi,flag,pxy);
}


/******************************************************************************/
/*	Clear the AES buffer																			*/
/******************************************************************************/
void _clearAesBuffer(void)
{
	int		buf[8];

	buf[0]=-1;
	buf[1]=glb.app_id;
	buf[2]=0;
	buf[3]=0;
	buf[4]=0;
	buf[5]=0;
	buf[6]=0;
	buf[7]=0;
	appl_write(glb.app_id,16,buf);
	do
	{
		evnt_mesag(__buf);
		if (__buf[0]!=-1)
			_traiteEvntMesag();
	} while (__buf[0]!=-1);
}


/******************************************************************************/
/*	Change the mouse form																		*/
/******************************************************************************/
void _mousework()
{
	mousenum+=1;
	if (mousenum==8)
		mousenum=0;
	graf_mouse(USER_DEF,&__s[mousenum]);
}


/******************************************************************************/
/*	Save the palette																				*/
/******************************************************************************/
void _savePal()
{
	typedef int		t_rgb[3];
	t_rgb				*col;
	long				len;
	int				i;

	if (glb.pal==TRUE)
	{
		len=(long)glb.out[13]*(long)sizeof(t_rgb);
		glb.pal=_mAlloc(len,MB_NORM,0);

		if (glb.pal!=NO_MEMORY)
		{
			col=(t_rgb *)mem.bloc[glb.pal].adr;
			for (i=0;i<glb.out[13];i++)
				vq_color(glb.hvdi,i,1,(int *)col[i]);
		}
		else
			glb.pal=FALSE;
	}		
}


/******************************************************************************/
/*	Load a palette																					*/
/******************************************************************************/
void _loadPal(int flag)
{
	typedef int		t_rgb[3];
	t_rgb				*col;
	int				i;

	if (glb.pal!=FALSE)
	{
		col=(t_rgb *)mem.bloc[glb.pal].adr;
		for (i=0;i<glb.out[13];i++)
			vs_color(glb.hvdi,i,(int *)col[i]);

		if (flag)
		{
			_mFree(glb.pal);
			glb.pal=FALSE;
		}
	}
}


/******************************************************************************/
/*	Return the number of word for val (VDI MFDB)											*/
/******************************************************************************/
int _word(int val)
{
	if (val%16==0)
		return val/16;
	else
		return 1+val/16;
}


/******************************************************************************/
/*	Inits GDOS fonts																				*/
/******************************************************************************/
void _initFont()
{
	int		i,indMem;
	long		gdos,*lp;

	_mousework();
	gdos=vq_vgdos();
	glb.vgdos=0;
	glb.gdos=0;
	if (gdos==GDOS_NONE)
		glb.gdos=0;
	else if (gdos==GDOS_FNT)
		glb.gdos=2;
	else if (gdos==GDOS_FSM)
	{
		lp=(long *)_cookie('FSMC');
		if (lp==0)
			glb.gdos=0;
		else if (*lp=='_FSM')
		{
			glb.gdos=3;
			lp++;
			glb.vgdos=(int)((*lp)>>16);
		}
		else if (*lp=='_SPD')
		{
			glb.gdos=4;
			lp++;
			glb.vgdos=(int)((*lp)>>16);
		}
		else
			glb.gdos=5;
	}
	else
		glb.gdos=1;
	glb.opt.GDfnt=1;
	glb.opt.HDfnt=1;
	glb.nfont=0;

	graf_mouse(USER_DEF,&__s[FSOUFNT]);
	if (glb.gdos)
		glb.nfont=vst_load_fonts(glb.hvdi,0);
	indMem=_mAlloc((2+glb.nfont)*sizeof(FONT),MB_NOMOVE,TRUE);
	font=(FONT *)(mem.bloc[indMem].adr);
	if (glb.gdos) for (i=1;i<=glb.nfont;i++)
	{
		_mousework();
		font[i].index=vqt_name(glb.hvdi,i,font[i].name);
		if ( (font[i].name[32]) && (!strncmp(font[i].name,"Dutch 801 Bold",14)) && (glb.opt.HDfnt==1) )
			glb.opt.HDfnt=i;
		glb.opt.font=1;
	}
	else
		glb.opt.font=0;
	glb.opt.GIfnt=glb.opt.GDfnt;
	glb.opt.HIfnt=glb.opt.HDfnt;
	glb.opt.Gfnt=glb.opt.GDfnt;
	glb.opt.Hfnt=glb.opt.HDfnt;
	graf_mouse(ARROW,0);
}


/******************************************************************************/
/*	Uninits GDOS fonts																			*/
/******************************************************************************/
void _exitFont()
{
	if (glb.gdos)
		vst_unload_fonts(glb.hvdi,0);
}


/******************************************************************************/
/*	Save the system configuration in a file												*/
/******************************************************************************/
void _saveSys()
{
	FILE		*f;
	long		*ptr,len;
	char		asc[20],*p;
	int		ha,i,old,drv,dum;
	DTA		*dta;

	if (Kbshift(-1)&4L)
		f=stdaux;
	else
	{
		if (_fexist(pfname,0))
		{
			if (glb.opt.lang==L_FRENCH)
				dum=form_alert(2,"[3][|Fichier existant !|Voulez-vous l'effacer ?|][ Oui | Non ]");
			else
				dum=form_alert(2,"[3][|File already exists !|Do you want to|delete it ?|][ Yes | No ]");
			if (dum==2)
				return;
		}
		f=fopen(pfname,"w");
	}
	if (f==NULL)
		return;

	_mousework();
	fprintf(f,"EGlib %s with program: %s\n\n",_obGetStr(__rsc.head.trindex[FINF],FINFVER),glb.name);
	fprintf(f,"App_id=%i - Vdi=%i - Multi=%i - Type=%li\n",glb.app_id,glb.hvdi,glb.Multi,glb.type);
	fprintf(f,"AES: %X - TOS: %X - Gemdos: %X - MiNT: %X - Gdos: %i (v%X)\n",glb.vAES,glb.vTOS,Sversion(),(int)_cookie('MiNT'),glb.gdos,glb.vgdos);
	fprintf(f,"Desk: (%i,%i,%i,%i) - Screen: (%i,%i) - Low rez: %i\n",glb.xdesk,glb.ydesk,glb.wdesk,glb.hdesk,glb.wscr,glb.hscr,glb.low);
	fprintf(f,"VdiOut: ");
	for (i=0;i<57;i++)
		fprintf(f,"%i;",glb.out[i]);
	fprintf(f,"\nVdiExt: ");
	for (i=0;i<57;i++)
		fprintf(f,"%i;",glb.extnd[i]);
	fprintf(f,"\nOpt: mnmb=%i mlen=%li popf=%i font=%i help=%i\n",glb.opt.mnmb,glb.opt.mlen,glb.opt.popf,glb.opt.font,glb.opt.help);

	_mousework();
	if (glb.nfont>1)
	{
		fprintf(f,"\nGDOS fonts (%i):\n",glb.nfont);
		for (i=0;i<glb.nfont;i++)
			if (i==0)
				fprintf(f,"%5i: %32s\n",i,"6x6 system font");
			else
				fprintf(f,"%5i: %32s\n",i,font[i].name);
	}

	_mousework();
	fprintf(f,"\n");
	for (i=0;i<glb.NMB_WDW;i++)
	{
		if ( (W[i].handle!=-1) || (W[i].xwind!=-1) )
		{
			fprintf(f,"%5i: ha=%i gadget=$%X type=%i id=%i in=%i small=%i xspos=%i xslen=%i yspos=%i yslen=%i\n",i,W[i].handle,W[i].gadget,W[i].type,W[i].id,W[i].in,W[i].smallflag,W[i].xslidpos,W[i].xslidlen,W[i].yslidpos,W[i].yslidlen);
			fprintf(f,"       All=%i;%i;%i;%i Win=%i;%i;%i;%i Full=%i;%i;%i;%i Work=%i;%i;%i;%i\n",W[i].x,W[i].y,W[i].w,W[i].h,W[i].xwind,W[i].ywind,W[i].wwind,W[i].hwind,W[i].xfull,W[i].yfull,W[i].wfull,W[i].hfull,W[i].xwork,W[i].ywork,W[i].wwork,W[i].hwork);
			fprintf(f,"       Name='%s' Sname='%s' Help='%s'\n",W[i].name,W[i].sname,W[i].help);
		}
	}

	_mousework();
	fprintf(f,"\nMemory:");
	fprintf(f,"Max=%i Free=%li Len=%li\n",mem.n,mem.tfre,mem.tlen);
	for (i=0;i<MEM_NMB;i++)
		if (mem.Blen[i]>0)
			fprintf(f,"BLOC %i: adr=%8li - len=%8li\n",i,mem.Badr[i],mem.Blen[i]);
	for (i=0;i<mem.n;i++)
		if (!(mem.bloc[i].adr==mem.bloc[i].len))
			fprintf(f,"%5i: adr=%8li - len=%8li - type=%i\n",i,mem.bloc[i].adr,mem.bloc[i].len,mem.bloc[i].type);

	_mousework();
	ptr=(long *)_cookieJar();
	if (ptr!=0)
	{
		fprintf(f,"\nCookie Jar: ");
		fprintf(f,"$%lX\n",(long)ptr);
		while (*ptr!=0)
		{
			asc[0]=max(32, (*ptr)>>24 );
			asc[1]=max(32, ((*ptr)>>16)&0xFF );
			asc[2]=max(32, ((*ptr)>>8)&0xFF );
			asc[3]=max(32, (*ptr)&0xFF );
			asc[4]=0;
			fprintf(f,"%4s $",asc);
			sprintf(asc,"%lX $",*ptr);
			for (i=0;i<8-(int)strlen(asc);i++)
				fprintf(f,"0");
			fprintf(f,asc);
			ptr++;
			sprintf(asc,"%lX: \n",*ptr);
			for (i=0;i<9-(int)strlen(asc);i++)
				fprintf(f,"0");
			fprintf(f,asc);
			ptr++;
		}
	}

	_mousework();
	drv=_getBoot();
	old=Dgetdrv();
	Dsetdrv(drv);
	Dgetpath(pname,1+drv);
	Dsetpath("");
	fprintf(f,"\nDossier AUTO:\n");
	if (Fsfirst("\\AUTO\\*.PRG",FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE)==0)
	dta=Fgetdta();
	do
	{
		fprintf(f,"%c:\\AUTO\\%s\n",(char)(65+drv),dta->d_fname);
	}	while (Fsnext()==0);

	_mousework();
	fprintf(f,"\nACCESSOIRES:\n");
	if (Fsfirst("\\*.ACC",FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE)==0)
	dta=Fgetdta();
	do
	{
		fprintf(f,"%c:\\%s\n",(char)(65+drv),dta->d_fname);
	}	while (Fsnext()==0);

	_mousework();
	pfname[0]=65+drv;
	pfname[1]=0;
	strcat(pfname,":\\CONTROL.INF");
	ha=(int)Fopen(pfname,FO_READ);
	strcpy(pfname,"");
	if (ha>=0)
	{
		len=Fseek(0L,ha,2);
		Fseek(0L,ha,0);
		i=_mAlloc(len,MB_NOMOVE,0);
		if (i!=NO_MEMORY)
		{
			Fread(ha,len,(void *)mem.bloc[i].adr);
			p=(char *)mem.bloc[i].adr;
			while ( (*p!=0xD) && (*p!=0xA) && (*p!=0) )
				strncat(pfname,p++,1L);
			_mFree(i);
		}
		Fclose(ha);
	}
	if ( (pfname[0]>0) && (pfname[1]==':') )
	{
		fprintf(f,"\nCPX Path: %s\n",pfname);
		Dsetdrv((int)pfname[0]-65);
		if (Fsfirst(pfname,FA_READONLY+FA_HIDDEN+FA_SYSTEM+FA_ARCHIVE)==0)
		dta=Fgetdta();
		do
		{
			fprintf(f,"%s\n",dta->d_fname);
		}	while (Fsnext()==0);
	}
	Dsetpath(pname);
	Dsetdrv(old);

	if (f!=stdaux)
		fclose(f);
	graf_mouse(ARROW,0);
}


/******************************************************************************/
/******************************************************************************/
long	_PutMyId()
{
	SYSHDR		*hdr;

	if (glb.vTOS>0x0100)
	{
		hdr=*((SYSHDR **)0x04f2L);
		__Run=hdr->_run;
	}
	else
		__Run=(BASPAG **)0x602C;
	__swap=0;
	if (!glb.Multi)
		if (_BasPag!=*__Run)
		{
			__swap=1;
			__OldPid		=	*__Run;
			*__Run		=	_BasPag;
		}
	return 0L;
}
long	_PutOldId()
{
	if (__swap)
		*__Run=__OldPid;
	return 0L;
}
void	*_Malloc(long number)
{
	void	*ret;
	Supexec(_PutMyId);
	ret=Malloc(number);
	Supexec(_PutOldId);
	return ret;
}
int	_Mfree(void *block)
{
	int	ret;
	Supexec(_PutMyId);
	ret=Mfree(block);
	Supexec(_PutOldId);
	return ret;
}
int	_Mshrink(int zero,void *block,long newsiz)
{
	int	ret;
	Supexec(_PutMyId);
	ret=Mshrink(zero,block,newsiz);
	Supexec(_PutOldId);
	return ret;
}


/******************************************************************************/
/******************************************************************************/
int	_winFindWin(int handle)
{
	int		i,num=-1;

	for (i=0;i<glb.NMB_WDW;i++)
		if (W[i].handle==handle) num=i;
	return num;
}


/******************************************************************************/
/******************************************************************************/
int	_winFindId(int type,int id,int open)
{
	int		j;

	for (j=0;j<glb.NMB_WDW;j++)
		if ( W[j].id==id && W[j].type==type )
			if ( !open || (open && W[j].handle>0) )
				return j;
	return -1;
}


/******************************************************************************/
/******************************************************************************/
void	_winRedraw(i,x,y,w,h)
{
	int		buf[8];

	buf[0]=WM_REDRAW;
	buf[1]=glb.app_id;
	buf[2]=0;
	buf[3]=W[i].handle;
	if (x==0)
	{
		buf[4]=glb.xdesk;
		buf[5]=glb.ydesk;
		buf[6]=glb.wdesk;
		buf[7]=glb.hdesk;
	}
	else
	{
		buf[4]=x;
		buf[5]=y;
		buf[6]=w;
		buf[7]=h;
	}
	appl_write(glb.app_id,16,buf);
}


/******************************************************************************/
/******************************************************************************/
void _coord(OBJECT *tree,int obj,int larg,int *x,int *y,int *w,int *h)
{
	objc_offset(tree,obj,x,y);
	*w=tree[obj].ob_width;
	*h=tree[obj].ob_height;

	if (larg)
	{
		*x-=4;
		*y-=4;
		*w+=8;
		*h+=8;
	}
}


/******************************************************************************/
/******************************************************************************/
void	_initPopUp(OBJECT *tree,int obj,int popTree,int val)
{
	UBLK		*user;
	OBJECT	*dum;
	char		*p;

	user			=	(UBLK *)(tree[obj].ob_spec.userblk->ub_parm);
	user->user1	=	popTree;
	user->user4	=	val;
	if (val!=-1)
	{
		if (user->user1&FLAGS15)
			dum=__rsc.head.trindex[popTree-FLAGS15];
		else
			dum=glb.rsc.head.trindex[popTree];
		p=_obGetStr(dum,1+val);
		if (p!=NULL)
		{
			if (!(tree[obj].ob_state&STATE8))
				_obPutStr(tree,obj,p);
		}
	}
}
/******************************************************************************/
/*	OBJECT	*tree			Tree adr																*/
/*	int		obj			Object number														*/
/*	char		*tab			Array of structs adr							userl				*/
/*	int		nmb			Number of structs in array					user1				*/
/*	int		off			Offset between structs						user2				*/
/*	int		len			Lenght of Strings								user3				*/
/*	int		val			default val										user4				*/
/******************************************************************************/
void	_initXPopUp(OBJECT *tree,int obj,char *tab,int nmb,int off,int len,int val)
{
	UBLK		*user;
	char		*p,q;

	user			=	(UBLK *)(tree[obj].ob_spec.userblk->ub_parm);
	user->user1	=	nmb;
	user->user2	=	off;
	user->user3	=	len;
	user->user4	=	val;
	user->userl	=	(long)tab;

	p=(char *)(tab+(long)val*(long)(len+off)+len);
	q=*p;
	*p=0;
	if (!(tree[obj].ob_state&STATE8))
		_obPutStr(tree,obj,(char *)(tab+(long)val*(long)(len+off)));
	*p=q;
}


/******************************************************************************/
/******************************************************************************/
int _getPopUp(OBJECT *tree,int obj)
{
	return ((UBLK *)(tree[obj].ob_spec.userblk->ub_parm))->user4;
}


/******************************************************************************/
/******************************************************************************/
void	_relocRSC(long adr,myRSHDR *reloc)
{
	int		i,j,type;
	RSHDR		*head;
	NRSHDR	*nhead;
	CICONBLK	*table;
	CICON		*cicon,*cold;
	long		*lp,iclen,num_cicon;
	char		*p;

	head=(RSHDR *)adr;
	/***************************************************************************/
	/*	Les nombres de structures																*/
	/***************************************************************************/
	reloc->nobs			=	head->rsh_nobs;
	reloc->ntree		=	head->rsh_ntree;
	reloc->nted			=	head->rsh_nted;
	reloc->nib			=	head->rsh_nib;
	reloc->ncib			=	0;
	reloc->nbb			=	head->rsh_nbb;
	reloc->nfstr		=	head->rsh_nstring;
	reloc->nfimg		=	head->rsh_nimages;
	/***************************************************************************/
	/*	rs_trindex																					*/
	/***************************************************************************/
	reloc->trindex=(OBJECT **)(adr+head->rsh_trindex);
	lp=(long *)reloc->trindex;
	for (i=0;i<reloc->ntree;i++)
	{
		*lp=*lp+adr;
		lp++;
	}
	/***************************************************************************/
	/*	TEDINFO																						*/
	/***************************************************************************/
	reloc->tedinfo=(TEDINFO *)(adr+head->rsh_tedinfo);
	for (i=0;i<reloc->nted;i++)
	{
		reloc->tedinfo[i].te_ptext+=adr;
		reloc->tedinfo[i].te_ptmplt+=adr;
		reloc->tedinfo[i].te_pvalid+=adr;
	}
	/***************************************************************************/
	/*	ICONBLK																						*/
	/***************************************************************************/
	reloc->iconblk=(ICONBLK *)(adr+head->rsh_iconblk);
	for (i=0;i<reloc->nib;i++)
	{
		lp=(long *)&reloc->iconblk[i].ib_pmask;	*lp=*lp+adr;
		lp=(long *)&reloc->iconblk[i].ib_pdata;	*lp=*lp+adr;
		reloc->iconblk[i].ib_ptext+=adr;
	}
	/***************************************************************************/
	/*	BITBLK																						*/
	/***************************************************************************/
	reloc->bitblk=(BITBLK *)(adr+head->rsh_bitblk);
	for (i=0;i<reloc->nbb;i++)
	{
		lp=(long *)&reloc->bitblk[i].bi_pdata;		*lp=*lp+adr;
	}
	/***************************************************************************/
	/*	free STRING																					*/
	/***************************************************************************/
	reloc->frstr=(char **)(adr+head->rsh_frstr);
	for (i=0;i<reloc->nfstr;i++)
		reloc->frstr[i]+=adr;
	/***************************************************************************/
	/*	free IMAGE																					*/
	/***************************************************************************/
	reloc->frimg=(BITBLK **)(adr+head->rsh_frimg);
	for (i=0;i<reloc->nfimg;i++)
	{
		lp=(long *)&reloc->frimg[i]; *lp=*lp+adr;
	}
	/***************************************************************************/
	/*	CICONBLK																						*/
	/***************************************************************************/
	if (head->rsh_vrsn&NEW_RSC)
	{
		nhead=(NRSHDR *)(adr+(long)head->rsh_rssize);
		reloc->ciconblk=(CICONBLK *)(adr+nhead->cicon_offset);
		lp=(long *)reloc->ciconblk;
		while (!lp[reloc->ncib])
			reloc->ncib+=1;

		if (lp[reloc->ncib]!=-1L)
			reloc->ncib=0;
		else
		{
			table=(CICONBLK *)&lp[reloc->ncib+1];
			for (i=0;i<reloc->ncib;i++)
			{
				lp[i]=(long)table;
				p=(char *)&table[1];
				table->monoblk.ib_pdata=(int *)p;
				iclen=table->monoblk.ib_wicon/8*table->monoblk.ib_hicon;
				p+=iclen;
				table->monoblk.ib_pmask=(int *)p;
				p+=iclen;
				table->monoblk.ib_ptext=(char *)p;
				cicon=(CICON *)&p[12];
				p+=12L;
				cold=cicon;
				if ( (num_cicon=(long)table->mainlist) > 0 )
				{
					table->mainlist=cicon;
					for (j=0;j<num_cicon;j++)
					{
						p=(char *)&cicon[1];
						cicon->col_data=(int *)p;
						p+=iclen*cicon->num_planes;
						cicon->col_mask=(int *)p;
						p+=iclen;
						if (cicon->sel_data!=NULL)
						{
							cicon->sel_data=(int *)p;
							p+=iclen*cicon->num_planes;
							cicon->sel_mask=(int *)p;
							p+=iclen;
						}
						cicon->next_res=(CICON *)p;
						cold=cicon;
						cicon=(CICON *)p;
					}
					cold->next_res=NULL;
				}
				table=(CICONBLK *)p;
			}
		}
	}
	else
	{
		reloc->cicon=NULL;
		reloc->ciconblk=NULL;
	}

	/***************************************************************************/
	/*	OBJECT:	Il faut faire pointer l'OB_SPEC au bon endroit						*/
	/***************************************************************************/
	reloc->object=(OBJECT *)(adr+head->rsh_object);
	for (i=0;i<reloc->nobs;i++)
	{
		type=reloc->object[i].ob_type&0xFF;
		if (type==G_CICON)
			reloc->object[i].ob_spec.index=lp[reloc->object[i].ob_spec.index];
		else if ( (type!=G_BOX) && (type!=G_IBOX) && (type!=G_BOXCHAR) )
			reloc->object[i].ob_spec.index+=adr;
		rsrc_obfix(&reloc->object[i],0);
	}
}


/******************************************************************************/
/*	Sauve la config																				*/
/******************************************************************************/
void _saveConfig()
{
	OBJECT	*tree;
	int		ha,i,n=0;
	S_WIN		wcnf;
	S_CNF		cnf;
	char		txt[FILENAME_MAX];

	strcpy(txt,glb.opt.path);
	strcat(txt,glb.cnf);
	ha=(int)Fcreate(txt,FALSE);
	if (ha>=0)
	{
		i=EGLIB_VERSION;
		if ( Fwrite(ha,sizeof(int),(void *)&i) != sizeof(int) )
			goto error;
		glb.opt.mlen=0;
		for (i=0;i<MEM_NMB;i++)
			glb.opt.mlen+=mem.Blen[i];
		strcpy(cnf.name,glb.name);
		cnf.opt=glb.opt;
		cnf.wdesk=glb.wdesk;
		cnf.hdesk=glb.hdesk;
		cnf.cu_hist=cu_hist;
		cnf.cp_hist=cp_hist;
		for (i=0;i<=MAX_HIST;i++)
		{
			strcpy(cnf.histoire[i],histoire[i]);
			strcpy(cnf.histoire2[i],histoire2[i]);
		}
		cnf.help=_winFindId(TW_HELP,0,TRUE);
		if (cnf.help!=-1)
		{
			cnf.xhelp=W[cnf.help].xwind;
			cnf.yhelp=W[cnf.help].ywind;
			cnf.whelp=W[cnf.help].wwind;
			cnf.hhelp=W[cnf.help].hwind;
			strcpy(cnf.file,histoire[cu_hist-1]);
		}
		cnf.gdos=glb.gdos;

		if ( Fwrite(ha,sizeof(cnf),(void *)&cnf) != sizeof(cnf) )
			goto error;
		for (i=0;i<glb.NMB_WDW;i++)
			if ( W[i].type==TW_FORM && W[i].handle>0 )
			{
				if (W[i].id&FLAGS15)
					tree=__rsc.head.trindex[W[i].id&~FLAGS15];
				else
					tree=glb.rsc.head.trindex[W[i].id];
				if ( !(tree->ob_state&STATE9) )
					n+=1;
			}
		if ( Fwrite(ha,sizeof(int),(void *)&n) != sizeof(int) )
			goto error;
		if (n)
			for (i=0;i<glb.NMB_WDW;i++)
				if ( (W[i].type==TW_FORM) && (W[i].handle>0) )
				{
					if (W[i].id&FLAGS15)
						tree=__rsc.head.trindex[W[i].id&~FLAGS15];
					else
						tree=glb.rsc.head.trindex[W[i].id];
					if ( !(tree->ob_state&STATE9) )
					{
						wcnf.tree=W[i].id;
						wcnf.popup=W[i].popup;
						wcnf.icon=W[i].icon;
						wcnf.xwind=W[i].xwind;
						wcnf.ywind=W[i].ywind;
						wcnf.wwind=W[i].wwind;
						wcnf.hwind=W[i].hwind;
						strcpy(wcnf.name,W[i].name);
						strcpy(wcnf.sname,W[i].sname);
						strcpy(wcnf.help,W[i].help);
						Fwrite(ha,sizeof(S_WIN),(void *)&wcnf);
					}
				}
		Fclose(ha);
	}
	return;
error:
	Fclose(ha);
	Fdelete("EG_LIB.CNF");
}

void _loadConfig()
{
	int		ha,i,j,n;
	S_WIN		wcnf;
	S_CNF		cnf;
	char		txt[FILENAME_MAX];

	strcpy(txt,glb.opt.path);
	strcat(txt,glb.cnf);
	ha=(int)Fopen(txt,FO_READ);
	if (ha>=0)
	{
		if ( Fread(ha,sizeof(int),(void *)&i) != sizeof(int) )
			goto error;
		if (i!=EGLIB_VERSION)
			goto error;
		if ( Fread(ha,sizeof(cnf),(void *)&cnf) != sizeof(cnf) )
			goto error;
		if ( strcmp(cnf.name,glb.name) )
			goto error;
		glb.opt.popf		=	cnf.opt.popf;
		glb.opt.font		=	cnf.opt.font;
		glb.opt.help		=	cnf.opt.help;
		glb.opt.hsiz		=	cnf.opt.hsiz;
		glb.opt.full		=	cnf.opt.full;
		glb.opt.save		=	cnf.opt.save;
		glb.opt.mfrm		=	cnf.opt.mfrm;
		glb.opt.lang		=	cnf.opt.lang;
		glb.opt.chlpt		=	cnf.opt.chlpt;
		glb.opt.chlpf		=	cnf.opt.chlpf;
		strcpy(glb.opt.phelp,cnf.opt.phelp);
		__rsc.head.trindex[FOPT][FOPTFR].ob_state&=~SELECTED;
		__rsc.head.trindex[FOPT][FOPTEN].ob_state&=~SELECTED;
		if (glb.opt.lang==L_FRENCH)
			__rsc.head.trindex[FOPT][FOPTFR].ob_state|=SELECTED;
		else
			__rsc.head.trindex[FOPT][FOPTEN].ob_state|=SELECTED;
		_switchLang();
		if (glb.FLang!=0)
			(*glb.FLang)();

		if ( (glb.gdos) && (cnf.gdos) )
		{
			glb.opt.Gfnt	=	min(	cnf.opt.Gfnt	,	glb.nfont	);
			glb.opt.GDfnt	=	min(	cnf.opt.GDfnt	,	glb.nfont	);
			glb.opt.GIfnt	=	min(	cnf.opt.GIfnt	,	glb.nfont	);
			glb.opt.Hfnt	=	min(	cnf.opt.Hfnt	,	glb.nfont	);
			glb.opt.HDfnt	=	min(	cnf.opt.HDfnt	,	glb.nfont	);
			glb.opt.HIfnt	=	min(	cnf.opt.HIfnt	,	glb.nfont	);
			if (!glb.opt.font)
				glb.opt.Gfnt=1;
			if (!glb.opt.help)
				glb.opt.Hfnt=1;
		}
		_myInitForm(FOPT|FLAGS15,FOPTFNT);
		_myInitForm(FOPT|FLAGS15,FOPTHLP);
		_myInitForm(FOPT|FLAGS15,FOPTPOP);
		_myInitForm(FOPT|FLAGS15,FOPTFUL);
		_myInitForm(FOPT|FLAGS15,FOPTSAV);
		_myInitForm(FOPT|FLAGS15,FOPTFRM1);
		_myInitForm(FOPT|FLAGS15,FOPTFRM2);
		_myInitForm(FOPT|FLAGS15,FOPTFRM3);
		_myInitForm(FOPT|FLAGS15,FOPTPHLP);
		_myInitForm(FFNT|FLAGS15,FFNTCFON);
		_myInitForm(FFNT|FLAGS15,FFNTCTXT);
		_myInitForm(FFNT|FLAGS15,FFNTGPOP);
		_myInitForm(FFNT|FLAGS15,FFNTGNOM);
		_myInitForm(FFNT|FLAGS15,FFNTGTYP);
		_myInitForm(FFNT|FLAGS15,FFNTHPOP);
		_myInitForm(FFNT|FLAGS15,FFNTHNOM);
		_myInitForm(FFNT|FLAGS15,FFNTHTYP);
		_myInitForm(FFNT|FLAGS15,FFNTHSIZ);

		cu_hist=cnf.cu_hist;
		cp_hist=cnf.cp_hist;
		for (i=0;i<=MAX_HIST;i++)
		{
			strcpy(histoire[i],cnf.histoire[i]);
			strcpy(histoire2[i],cnf.histoire2[i]);
		}
		if (cnf.help!=-1)
		{
			if (cnf.wdesk!=glb.wdesk)
				__x=max( glb.xdesk , (int)((float)cnf.xhelp*(float)glb.wdesk/(float)cnf.wdesk) );
			else
				__x=cnf.xhelp;
			if (cnf.hdesk!=glb.hdesk)
				__y=max( glb.ydesk , (int)((float)cnf.yhelp*(float)glb.hdesk/(float)cnf.hdesk) );
			else
				__y=cnf.yhelp;
			if (cnf.wdesk!=glb.wdesk)
				__w=(int)((float)cnf.whelp*(float)glb.wdesk/(float)cnf.wdesk);
			else
				__w=cnf.whelp;
			if (cnf.hdesk!=glb.hdesk)
				__h=(int)((float)cnf.hhelp*(float)glb.hdesk/(float)cnf.hdesk);
			else
				__h=cnf.hhelp;
			_Aide();
			_clearAesBuffer();
			i=_winFindId(TW_HELP,0,TRUE);
			if (i!=-1)
			{
				_ouvreHelp(cnf.file);
				_clearAesBuffer();
				W[i].y=0;
				_winRedraw(i,0,0,0,0);
				_clearAesBuffer();
			}
		}

		if ( Fread(ha,sizeof(int),(void *)&n) != sizeof(int) )
			goto error;
		for (j=0;j<n;j++)
		{
			if ( Fread(ha,sizeof(S_WIN),(void *)&wcnf) != sizeof(S_WIN) )
				goto error;
			if (cnf.wdesk!=glb.wdesk)
				__x=(int)((float)wcnf.xwind*(float)glb.wdesk/(float)cnf.wdesk);
			else
				__x=wcnf.xwind;
			if (cnf.hdesk!=glb.hdesk)
				__y=(int)((float)wcnf.ywind*(float)glb.hdesk/(float)cnf.hdesk);
			else
				__y=wcnf.ywind;
			__w=wcnf.wwind;
			__h=wcnf.hwind;
			i=_winForm(wcnf.tree,wcnf.name,wcnf.sname,wcnf.help,wcnf.popup,wcnf.icon);
			_clearAesBuffer();
		}
error:
		Fclose(ha);
	}
	__x=-1;
}

/******************************************************************************/
/*	This is to acces to the EGlib PopUp														*/
/******************************************************************************/
void _EGlibPop()
{
	int	mx,my,dum;

	graf_mkstate(&mx,&my,&dum,&dum);
	_clicBureau(mx,my,-1,2);
}

/******************************************************************************/
/*	This function returns the object number & cursor pos in EDITABLE obj			*/
/******************************************************************************/
void _whichEdit(int i,int *obj,int *pos)
{
	WFORM	*str;

	*obj=*pos=-1;
	if (i!=-1)
		if (W[i].type==TW_FORM)
		{
			str=(WFORM *)mem.bloc[W[i].in].adr;
			*pos=str->pos;
			*obj=str->obj;
		}
}

void _setEdit(int i,int obj,int pos)
{
	WFORM		*str;
	int		type;

	if (i!=-1)
		if (W[i].type==TW_FORM)
		{
			str=(WFORM *)mem.bloc[W[i].in].adr;
			type=((UBLK *)str->tree[obj].ob_spec.userblk->ub_parm)->type;
			if ( str->obj!=obj || str->pos!=pos )
				if ( (type==G_FTEXT || type==G_FBOXTEXT) && str->tree[obj].ob_flags&EDITABLE && !(str->tree[obj].ob_state&DISABLED) )
				{
					objc_draw(str->tree,str->obj,0,str->tree->ob_x,str->tree->ob_y,str->tree->ob_width,str->tree->ob_height);
					str->obj=obj;
					str->pos=min(pos,(int)strlen(((TEDINFO *)((UBLK *)str->tree[str->obj].ob_spec.userblk->ub_parm)->spec)->te_ptext));
					_objcEdit(str->tree,str->obj,0,&str->pos,ED_CLIP|ED_INIT);
				}
		}
}
