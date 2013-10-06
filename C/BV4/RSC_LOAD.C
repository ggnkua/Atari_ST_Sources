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

/*******************************************************************************
	FONCTIONS
*******************************************************************************/
static void	_relocRSC(RSC *rsc);
static int	_initUserdef(RSC *rsc);

/*******************************************************************************
	Load a RSC file
*******************************************************************************/
int _loadRSC(RSC *rsc)
{
	int	ha;

	rsc->adr		=	0;
	rsc->ublk	=	0;
	rsc->cicon	=	0;

	_prog("@",rs_frstr[INIT09]);
	ha=(int)Fopen(rsc->name,FO_READ);
	if (ha<0)
	{
		form_alert(1,rs_frstr[ERR04]);
		return FALSE;
	}
	rsc->len=Fseek(0L,ha,2);
	Fseek(0L,ha,0);

	rsc->max=glb.mem.tfre/2L;
#ifdef FORCE_MALLOC
	rsc->in=_mAllocForce(MEM_RSC,rsc->max,0);
#else
	rsc->in=_mAlloc(rsc->max,0);
#endif
	if (rsc->in==NO_MEMORY)
	{
		Fclose(ha);
		form_alert(1,rs_frstr[ERR08]);
		return FALSE;
	}
	rsc->adr=glb.mem.adr[rsc->in];

	if (Fread(ha,rsc->len,(void *)rsc->adr)!=rsc->len)
	{
		Fclose(ha);
		_mFree(rsc->in);
		form_alert(1,rs_frstr[ERR09]);
		return FALSE;
	}
	Fclose(ha);
	_prog("@",rs_frstr[INIT10]);

sprintf(glb.div.log,"  File loaded\n");
_reportLog(LOG_INI);

	_relocRSC(rsc);

	_prog("@",rs_frstr[INIT11]);
	if (_initUserdef(rsc))
	{

sprintf(glb.div.log,"  Userdef objects installed\n");
_reportLog(LOG_INI);

		_mDim(rsc->in,rsc->len,0,-1);
		return TRUE;
	}
	_mFree(rsc->in);
	form_alert(1,rs_frstr[ERR10]);
	return FALSE;
}
void _unloadRSC(RSC *rsc)
{
	_mFree(rsc->in);
}


/*******************************************************************************
*******************************************************************************/
static void _relocRSC(RSC *rsc)
{
	RSHDR		*head;
	RSXHDR	*xhead;
	NRSHDR	*nhead;
	CICONBLK	*table;
	CICON		*cicon,*cold;
	long		*lp,iclen,num_cicon;
	long		len;
	int		i,j,type;
	char		*p;

	head=(RSHDR *)rsc->adr;
	if (head->rsh_vrsn==NRSC_LONG)
	{
		xhead=(RSXHDR *)rsc->adr;
		/*************************************************************************
			Les nombres de structures
		*************************************************************************/
		rsc->head.nobs			=	xhead->rsh_nobs;
		rsc->head.ntree		=	xhead->rsh_ntree;
		rsc->head.nted			=	xhead->rsh_nted;
		rsc->head.nib			=	xhead->rsh_nib;
		rsc->head.ncib			=	0;
		rsc->head.nbb			=	xhead->rsh_nbb;
		rsc->head.nfstr		=	xhead->rsh_nstring;
		rsc->head.nfimg		=	xhead->rsh_nimages;
		/*************************************************************************
			Les pointeurs de structures
		*************************************************************************/
		rsc->head.trindex		=	(OBJECT **)(rsc->adr+xhead->rsh_trindex);
		rsc->head.object		=	(OBJECT *)(rsc->adr+xhead->rsh_object);
		rsc->head.tedinfo		=	(TEDINFO *)(rsc->adr+xhead->rsh_tedinfo);
		rsc->head.iconblk		=	(ICONBLK *)(rsc->adr+xhead->rsh_iconblk);
		rsc->head.bitblk		=	(BITBLK *)(rsc->adr+xhead->rsh_bitblk);
		rsc->head.frstr		=	(char **)(rsc->adr+xhead->rsh_frstr);
		rsc->head.frimg		=	(BITBLK **)(rsc->adr+xhead->rsh_frimg);
		len=xhead->rsh_rssize;
	}
	else
	{
		/*************************************************************************
			Les nombres de structures
		*************************************************************************/
		rsc->head.nobs			=	head->rsh_nobs;
		rsc->head.ntree		=	head->rsh_ntree;
		rsc->head.nted			=	head->rsh_nted;
		rsc->head.nib			=	head->rsh_nib;
		rsc->head.ncib			=	0;
		rsc->head.nbb			=	head->rsh_nbb;
		rsc->head.nfstr		=	head->rsh_nstring;
		rsc->head.nfimg		=	head->rsh_nimages;
		/*************************************************************************
			Les pointeurs de structures
		*************************************************************************/
		rsc->head.trindex		=	(OBJECT **)(rsc->adr+head->rsh_trindex);
		rsc->head.object		=	(OBJECT *)(rsc->adr+head->rsh_object);
		rsc->head.tedinfo		=	(TEDINFO *)(rsc->adr+head->rsh_tedinfo);
		rsc->head.iconblk		=	(ICONBLK *)(rsc->adr+head->rsh_iconblk);
		rsc->head.bitblk		=	(BITBLK *)(rsc->adr+head->rsh_bitblk);
		rsc->head.frstr		=	(char **)(rsc->adr+head->rsh_frstr);
		rsc->head.frimg		=	(BITBLK **)(rsc->adr+head->rsh_frimg);
		len=head->rsh_rssize;
	}

	/****************************************************************************
		rs_trindex
	****************************************************************************/
	lp=(long *)rsc->head.trindex;
	for (i=0;i<rsc->head.ntree;i++)
	{
		*lp=*lp+rsc->adr;
		lp++;
	}
	/****************************************************************************
		TEDINFO
	****************************************************************************/
	for (i=0;i<rsc->head.nted;i++)
	{
		rsc->head.tedinfo[i].te_ptext+=rsc->adr;
		rsc->head.tedinfo[i].te_ptmplt+=rsc->adr;
		rsc->head.tedinfo[i].te_pvalid+=rsc->adr;
	}
	/****************************************************************************
		ICONBLK
	****************************************************************************/
	for (i=0;i<rsc->head.nib;i++)
	{
		lp=(long *)&rsc->head.iconblk[i].ib_pmask;	*lp=*lp+rsc->adr;
		lp=(long *)&rsc->head.iconblk[i].ib_pdata;	*lp=*lp+rsc->adr;
		rsc->head.iconblk[i].ib_ptext+=rsc->adr;
	}
	/****************************************************************************
		BITBLK
	****************************************************************************/
	for (i=0;i<rsc->head.nbb;i++)
	{
		lp=(long *)&rsc->head.bitblk[i].bi_pdata;		*lp=*lp+rsc->adr;
	}
	/****************************************************************************
		free STRING
	****************************************************************************/
	for (i=0;i<rsc->head.nfstr;i++)
		rsc->head.frstr[i]+=rsc->adr;
	/****************************************************************************
		free IMAGE
	****************************************************************************/
	for (i=0;i<rsc->head.nfimg;i++)
	{
		lp=(long *)&rsc->head.frimg[i]; *lp=*lp+rsc->adr;
	}
	/****************************************************************************
		CICONBLK
	****************************************************************************/
	if (head->rsh_vrsn>1 && rsc->len>len)
	{
		if (head->rsh_vrsn==NRSC_CIBK)
			nhead=(NRSHDR *)(rsc->adr+(long)head->rsh_rssize);
		else
			nhead=(NRSHDR *)(rsc->adr+(long)xhead->rsh_rssize);
		rsc->head.ciconblk=(CICONBLK *)(rsc->adr+nhead->cicon_offset);
		lp=(long *)rsc->head.ciconblk;
		while (!lp[rsc->head.ncib])
			rsc->head.ncib+=1;

		if (lp[rsc->head.ncib]!=-1L)
			rsc->head.ncib=0;
		else
		{
			table=(CICONBLK *)&lp[rsc->head.ncib+1];
			for (i=0;i<rsc->head.ncib;i++)
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
				if ((num_cicon=(long)table->mainlist)>0)
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
		rsc->head.cicon=NULL;
		rsc->head.ciconblk=NULL;
	}

	/****************************************************************************
		OBJECT:	Il faut faire pointer l'OB_SPEC au bon endroit
	****************************************************************************/
	for (i=0;i<rsc->head.nobs;i++)
	{
		type=rsc->head.object[i].ob_type&0xFF;
		if (type==G_CICON)
			rsc->head.object[i].ob_spec.index=lp[rsc->head.object[i].ob_spec.index];
		else if (type!=G_BOX && type!=G_IBOX && type!=G_BOXCHAR)
			rsc->head.object[i].ob_spec.index+=rsc->adr;
		rsrc_obfix(&rsc->head.object[i],0);
	}
}

/*******************************************************************************
	USERDEF objects initialisation
*******************************************************************************/
static int _initUserdef(RSC *rsc)
{
	OBJECT	*tree,*obj;
	CICON		*cicon;
	ICONBLK	*micon;
	long		n=0;
	uint		type,xtype;
	int		i,j=0,k=0;
	int		color,dum;
	int		child,gTitle;
	int		*ip,x,y;
	char		*p;

	glb.icn.xpixel=_testRez();
	_fillFarbTbl();

	/****************************************************************************
		searching number n of USERDEF objects
	****************************************************************************/
	obj=glb.rsc.head.trindex[FUSER];
	for (i=0;i<rsc->head.ntree;i++)
	{
		tree=rsc->head.trindex[i];
		child=-1;
		gTitle=0;
		if (!(tree->ob_state&STATE8))
		do
		{
			child+=1;
			type=tree[child].ob_type&0xFF;
			xtype=tree[child].ob_type&0xFF00;
			if (!gTitle)
			{
				if (type==G_TITLE)
					gTitle=1;
				if (!gTitle)
					switch (type)
					{
						case	G_STRING:
							p=(char *)tree[child].ob_spec.free_string;
							if (*p=='-' && tree[child].ob_state&DISABLED)
								n+=1;
							break;
						case	G_CICON:
						case	G_BUTTON:
							n+=1;
							break;
					}
			}
		}	while ( !(tree[child].ob_flags & LASTOB) );
	}

	/****************************************************************************
		Create the UBLK array for USERDEF objects
	****************************************************************************/
	if (n)
	{
		if (rsc->max<rsc->len+n*sizeof(UBLK))
			return FALSE;
		_cls(rsc->adr+rsc->len,n*sizeof(UBLK));
		rsc->ublk=(UBLK *)(rsc->adr+rsc->len);
		rsc->len+=n*sizeof(UBLK);
	}

	if (rsc->head.ncib)
	{
		if (rsc->max<rsc->len+rsc->head.ncib*sizeof(CICON))
			return FALSE;
		_cls(rsc->adr+rsc->len,rsc->head.ncib*sizeof(CICON));
		rsc->cicon=(CICON *)(rsc->adr+rsc->len);
		rsc->len+=rsc->head.ncib*sizeof(CICON);
	}

	for (i=0;i<rsc->head.ntree;i++)
	{
		tree=rsc->head.trindex[i];
		child=-1;
		gTitle=0;
		if (!(tree->ob_state&STATE8))
		do
		{
			child+=1;
			type=tree[child].ob_type&0xFF;
			xtype=tree[child].ob_type&0xFF00;

			if (type==G_TITLE)
				gTitle=1;

			if (!gTitle)
			{
				type=tree[child].ob_type&0xFF;
				xtype=tree[child].ob_type&0xff00;

				switch (type)
				{
					case	G_STRING:
						p=(char *)tree[child].ob_spec.free_string;
						if (*p=='-' && tree[child].ob_state&DISABLED)
						{
							rsc->ublk[k].spec					=	(long)tree[child].ob_spec.free_string;
							rsc->ublk[k].blk.ub_parm		=	(long)&rsc->ublk[k];
							rsc->ublk[k].blk.ub_code		=	_drawNiceLine;
							rsc->ublk[k].type					=	type;
							tree[child].ob_spec.userblk	=	&rsc->ublk[k].blk;
							tree[child].ob_type				=	xtype+G_USERDEF;
							k+=1;
						}
						break;
					case	G_USERDEF:
						switch (xtype)
						{
							case	USD_DNARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDDAR+glb.vdi.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDDAR+glb.vdi.low].ob_spec;
								break;
							case	USD_UPARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDUAR+glb.vdi.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDUAR+glb.vdi.low].ob_spec;
								break;
							case	USD_LFARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDLAR+glb.vdi.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDLAR+glb.vdi.low].ob_spec;
								break;
							case	USD_RTARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDRAR+glb.vdi.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDRAR+glb.vdi.low].ob_spec;
								break;
							case	USD_LQARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDLQAR+glb.vdi.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDLQAR+glb.vdi.low].ob_spec;
								break;
							case	USD_RQARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDRQAR+glb.vdi.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDRQAR+glb.vdi.low].ob_spec;
								break;
						}
						break;
					case	G_BUTTON:
						if (xtype==USD_CROSS || xtype==USD_ROUND || xtype==USD_NUM)
						{
							rsc->ublk[k].spec					=	(long)tree[child].ob_spec.free_string;
							rsc->ublk[k].blk.ub_parm		=	(long)&rsc->ublk[k];
							rsc->ublk[k].blk.ub_code		=	_drawCroixCarre;
							rsc->ublk[k].type					=	type;
							tree[child].ob_spec.userblk	=	&rsc->ublk[k].blk;
							tree[child].ob_type				=	xtype+G_USERDEF;
						}
						else if (xtype==USD_POPUP || xtype==USD_XPOPUP)
						{
							rsc->ublk[k].spec					=	(long)tree[child].ob_spec.free_string;
							rsc->ublk[k].blk.ub_parm		=	(long)&rsc->ublk[k];
							rsc->ublk[k].blk.ub_code		=	_drawPopUp;
							rsc->ublk[k].type					=	type;
							tree[child].ob_spec.userblk	=	&rsc->ublk[k].blk;
							tree[child].ob_type				=	xtype+G_USERDEF;
						}
						else
						{
							rsc->ublk[k].spec					=	(long)tree[child].ob_spec.free_string;
							rsc->ublk[k].blk.ub_parm		=	(long)&rsc->ublk[k];
							rsc->ublk[k].blk.ub_code		=	_drawButton;
							rsc->ublk[k].type					=	type;
							tree[child].ob_spec.userblk	=	&rsc->ublk[k].blk;
							tree[child].ob_type				=	xtype+G_USERDEF;
						}
						k+=1;
						break;
					case	G_IMAGE:
						if (glb.vdi.low && tree[child].ob_state&STATE15)
						{
							ip=tree[child].ob_spec.bitblk->bi_pdata;
							if (ip!=0)
								for (y=0;y<tree[child].ob_spec.bitblk->bi_hl;y++)
									for (x=0;x<tree[child].ob_spec.bitblk->bi_wb/2;x++)
										if (y<tree[child].ob_spec.bitblk->bi_hl/2)
											ip[x+y*tree[child].ob_spec.bitblk->bi_wb/2]=ip[x+y*tree[child].ob_spec.bitblk->bi_wb];
										else
											ip[x+y*tree[child].ob_spec.bitblk->bi_wb/2]=0;
							tree[child].ob_spec.bitblk->bi_y/=2;
						}
						break;
					case	G_ICON:
						if (glb.vdi.low && tree[child].ob_state&STATE15)
						{
							tree[child].ob_spec.iconblk->ib_ychar/=2;
							tree[child].ob_spec.iconblk->ib_ytext/=2;
							ip=tree[child].ob_spec.iconblk->ib_pdata;
							if (ip!=0)
								for (y=0;y<tree[child].ob_spec.iconblk->ib_hicon;y++)
									for (x=0;x<tree[child].ob_spec.iconblk->ib_wicon/16;x++)
										if (y<tree[child].ob_spec.iconblk->ib_hicon/2)
											ip[x+y*tree[child].ob_spec.iconblk->ib_wicon/16]=ip[x+y*tree[child].ob_spec.iconblk->ib_wicon/8];
										else
											ip[x+y*tree[child].ob_spec.iconblk->ib_wicon/16]=0;
							ip=tree[child].ob_spec.iconblk->ib_pmask;
							if (ip!=0)
								for (y=0;y<tree[child].ob_spec.iconblk->ib_hicon;y++)
									for (x=0;x<tree[child].ob_spec.iconblk->ib_wicon/16;x++)
										if (y<tree[child].ob_spec.iconblk->ib_hicon/2)
											ip[x+y*tree[child].ob_spec.iconblk->ib_wicon/16]=ip[x+y*tree[child].ob_spec.iconblk->ib_wicon/8];
										else
											ip[x+y*tree[child].ob_spec.iconblk->ib_wicon/16]=0;
							tree[child].ob_spec.iconblk->ib_yicon/=2;
						}
						break;
					case	G_CICON:
						if (glb.vdi.low && tree[child].ob_state&STATE15)
						{
							micon=&tree[child].ob_spec.ciconblk->monoblk;
							ip=micon->ib_pdata;
							if (ip!=0)
								for (y=0;y<micon->ib_hicon;y++)
									for (x=0;x<micon->ib_wicon/16;x++)
										if (y<micon->ib_hicon/2)
											ip[x+y*micon->ib_wicon/16]=ip[x+y*micon->ib_wicon/8];
										else
											ip[x+y*micon->ib_wicon/16]=0;
							ip=micon->ib_pmask;
							if (ip!=0)
								for (y=0;y<micon->ib_hicon;y++)
									for (x=0;x<micon->ib_wicon/16;x++)
										if (y<micon->ib_hicon/2)
											ip[x+y*micon->ib_wicon/16]=ip[x+y*micon->ib_wicon/8];
										else
											ip[x+y*micon->ib_wicon/16]=0;
							cicon=tree[child].ob_spec.ciconblk->mainlist;
							while (cicon!=NULL)
							{
								ip=cicon->col_data;
								if (ip!=0)
									for (dum=0;dum<cicon->num_planes;dum++)
									{
										for (y=0;y<micon->ib_hicon;y++)
											for (x=0;x<micon->ib_wicon/16;x++)
												if (y<micon->ib_hicon/2)
													ip[x+y*micon->ib_wicon/16]=ip[x+y*micon->ib_wicon/8];
												else
													ip[x+y*micon->ib_wicon/16]=0;
										ip=&ip[micon->ib_wicon/16*micon->ib_hicon];
									}
								ip=cicon->col_mask;
								if (ip!=0)
									for (y=0;y<micon->ib_hicon;y++)
										for (x=0;x<micon->ib_wicon/16;x++)
											if (y<micon->ib_hicon/2)
												ip[x+y*micon->ib_wicon/16]=ip[x+y*micon->ib_wicon/8];
											else
												ip[x+y*micon->ib_wicon/16]=0;
								ip=cicon->sel_data;
								if (ip!=0)
									for (dum=0;dum<cicon->num_planes;dum++)
									{
										for (y=0;y<micon->ib_hicon;y++)
											for (x=0;x<micon->ib_wicon/16;x++)
												if (y<micon->ib_hicon/2)
													ip[x+y*micon->ib_wicon/16]=ip[x+y*micon->ib_wicon/8];
												else
													ip[x+y*micon->ib_wicon/16]=0;
										ip=&ip[micon->ib_wicon/16*micon->ib_hicon];
									}
								ip=cicon->sel_mask;
								if (ip!=0)
									for (y=0;y<micon->ib_hicon;y++)
										for (x=0;x<micon->ib_wicon/16;x++)
											if (y<micon->ib_hicon/2)
												ip[x+y*micon->ib_wicon/16]=ip[x+y*micon->ib_wicon/8];
											else
												ip[x+y*micon->ib_wicon/16]=0;
								cicon=cicon->next_res;
							}
							micon->ib_ychar/=2;
							micon->ib_ytext/=2;
							micon->ib_yicon/=2;
						}
						color=_addCicon(rsc,(CICONBLK *)tree[child].ob_spec.index,&tree[child],&rsc->ublk[k],&rsc->cicon[j]);
						if (color==FALSE)
							return FALSE;
						else if (color==2*TRUE)
						{
							memset(&rsc->cicon[j],0,sizeof(CICON));
							tree[child].ob_type=xtype|G_ICON;
						}
						k+=1;
						j+=1;
						break;
				}
			}
		}	while ( !(tree[child].ob_flags & LASTOB) );
	}
	return TRUE;
}


/*******************************************************************************
	Copy a text in an object
*******************************************************************************/
void _obPutStr(OBJECT *tree,int n,const char *str)
{
	UBLK			*user;

	switch (tree[n].ob_type&0xFF)
	{
		case	G_USERDEF:
			user=(UBLK *)tree[n].ob_spec.userblk->ub_parm;
			switch (user->type)
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


/*******************************************************************************
	Put a size limited string
*******************************************************************************/
void _putPath(OBJECT *tree,int n,int len,char *name)
{
	char			*s,*d;
	UBLK			*user;

	d=NULL;
	s=(char *)name;
	s+=strlen(name)-len;
	if (strlen(name)<len)
		_obPutStr(tree,n,name);
	else
		switch (tree[n].ob_type&0xFF)
		{
			case	G_USERDEF:
				user=(UBLK *)tree[n].ob_spec.userblk->ub_parm;
				switch (user->type)
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


/*******************************************************************************
	Return a pointer on a string
*******************************************************************************/
char *_obGetStr(OBJECT *tree,int objc)
{
	UBLK			*user;
	char			*tx;

	tx=NULL;
	switch (tree[objc].ob_type&0xFF)
	{
		case	G_USERDEF:
			user=(UBLK *)tree[objc].ob_spec.userblk->ub_parm;
			switch (user->type)
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
				case	G_ICON:
				case	G_CICON:
					tx=(char *)(((ICONBLK*)user->spec)->ib_ptext);
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


/*******************************************************************************
	Returns the father object ot another
*******************************************************************************/
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


/*******************************************************************************
*******************************************************************************/
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


/*******************************************************************************
*******************************************************************************/
void _initNum(OBJECT *tree,int obj,uint vmin,uint vmax,uint inc,uint val)
{
	UBLK		*user;

	user			=	(UBLK *)(tree[obj].ob_spec.userblk->ub_parm);
	user->user1	=	vmin;
	user->user2	=	vmax;
	user->user3	=	inc;
	user->user4	=	val;
	sprintf((char *)(user->spec),"%u",user->user4);
}


/*******************************************************************************
*******************************************************************************/
int _getNum(OBJECT *tree,int obj)
{
	UBLK		*user=(UBLK *)(tree[obj].ob_spec.userblk->ub_parm);

	return user->user4;
}
