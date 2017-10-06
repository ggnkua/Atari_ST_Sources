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
/*	USERDEFS OBJECTS HANDLING																	*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	VARIABLES																						*/
/******************************************************************************/
static	int		dummy,i,state,type,tour,tHaut,tLarg;
static	int		lattr[6],fattr[6],tattr[10],extent[8];
static	int		tab_clip[4],bar[4],pxy[10];
static	int		eff,ind,pnt,vect,x,y,color,fill,htext;
static	uchar		car[2],*p,*trait;
static	UBLK		*user;
static	GRECT		my1,my2;
static	PARMBLK	pb;
static	int	col[16]	=	{	BLACK,		WHITE,		LCYAN,		LMAGENTA,
										LYELLOW,		LRED,			LBLUE,		LGREEN,
										LBLACK,		LWHITE,		CYAN,			MAGENTA,
										YELLOW,		RED,			BLUE,			GREEN			};


/******************************************************************************/
/*	USERDEF objects initialisation															*/
/******************************************************************************/

int _initUserdef(RSC *tab)
{
	OBJECT	*tree,*obj;
	CICON		*cicon;
	ICONBLK	*micon;
	int		i,j=0,k=0,n=0,in;
	int		color;
	int		child,gTitle;
	uint		type,xtype;
	int		*ip,x,y;
	char		*p;

	__xpixel=_testRez();
	_fillFarbTbl();

	/***************************************************************************/
	/*	searching number of USERDEF objects													*/
	/***************************************************************************/
	obj=__rsc.head.trindex[FUSER];
	for (i=0;i<tab->head.ntree;i++)
	{
		tree=tab->head.trindex[i];
		child=-1;
		gTitle=0;
		if ( !(tree->ob_state&STATE8) )
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
					switch	(type)
					{
						case	G_CICON:
						case	G_FTEXT:
						case	G_TEXT:
						case	G_FBOXTEXT:
						case	G_BOXTEXT:
						case	G_STRING:
						case	G_BUTTON:
						case	G_BOX:
						case	G_IBOX:
						case	G_BOXCHAR:
							n+=1;
							break;
					}
			}
		}	while ( !(tree[child].ob_flags & LASTOB) );
	}
	if (n)
	{
		in=_mAlloc((long)sizeof(UBLK)*(long)n,MB_NOMOVE,0);
		if (in!=NO_MEMORY)
		{
			tab->ublk=(UBLK *)mem.bloc[in].adr;
			for (i=0;i<n;i++)
			{
				tab->ublk[i].userl=	0L;
				tab->ublk[i].user1=	0;
				tab->ublk[i].user2=	0;
				tab->ublk[i].user3=	0;
				tab->ublk[i].user4=	0;
			}
		}
		else
			return FALSE;
	}

	if (tab->head.ncib)
	{
		in=_mAlloc(tab->head.ncib*sizeof(CICON),MB_NOMOVE,0);
		if (in!=NO_MEMORY)
			tab->cicon=(CICON *)mem.bloc[in].adr;
		else
			return FALSE;
	}
	memset(tab->cicon,0,(long)tab->head.ncib*sizeof(CICON));

	for (i=0;i<tab->head.ntree;i++)
	{
		tree=tab->head.trindex[i];
		child=-1;
		gTitle=0;
		if ( !(tree->ob_state&STATE8) )
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

				switch	(type)
				{
					case	G_USERDEF:
						switch	(xtype)
						{
							case	USD_DNARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDDAR+glb.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDDAR+glb.low].ob_spec;
								break;
							case	USD_UPARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDUAR+glb.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDUAR+glb.low].ob_spec;
								break;
							case	USD_LFARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDLAR+glb.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDLAR+glb.low].ob_spec;
								break;
							case	USD_RTARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDRAR+glb.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDRAR+glb.low].ob_spec;
								break;
							case	USD_LQARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDLQAR+glb.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDLQAR+glb.low].ob_spec;
								break;
							case	USD_RQARROW:
								tree[child].ob_type	=	xtype+(obj[FUSDRQAR+glb.low].ob_type&0xFF);
								tree[child].ob_spec	=	obj[FUSDRQAR+glb.low].ob_spec;
								break;
						}
						break;
					case	G_TEXT:
						color=tree[child].ob_spec.tedinfo->te_color;
						tree[child].ob_state&=~DRAW3D;
						if ( (tree[child].ob_state&WHITEBAK) && (color&0x80) && (glb.extnd[4]>=4) )
							tree[child].ob_state|=WHITEBAK;
						else
							tree[child].ob_state&=~WHITEBAK;		
						tab->ublk[k].spec					=	(long)tree[child].ob_spec.tedinfo;
						tab->ublk[k].blk.ub_parm		=	(long)&tab->ublk[k];
						tab->ublk[k].blk.ub_code		=	_drawText;
						tab->ublk[k].type					=	type;
						tree[child].ob_spec.userblk	=	&tab->ublk[k].blk;
						tree[child].ob_type				=	xtype+G_USERDEF;
						k+=1;
						break;
					case	G_FTEXT:
						color=tree[child].ob_spec.tedinfo->te_color;
						tree[child].ob_state&=~DRAW3D;
						if ( (tree[child].ob_state&WHITEBAK) && (color&0x80) && (glb.extnd[4]>=4) )
							tree[child].ob_state|=WHITEBAK;
						else
							tree[child].ob_state&=~WHITEBAK;		
						tab->ublk[k].spec					=	(long)tree[child].ob_spec.tedinfo;
						tab->ublk[k].blk.ub_parm		=	(long)&tab->ublk[k];
						tab->ublk[k].blk.ub_code		=	_drawFText;
						tab->ublk[k].type					=	type;
						tree[child].ob_spec.userblk	=	&tab->ublk[k].blk;
						tree[child].ob_type				=	xtype+G_USERDEF;
						k+=1;
						break;
					case	G_BOX:
					case	G_IBOX:
					case	G_BOXCHAR:
						if (tree[child].ob_state&WHITEBAK)
						{
							if (tree[child].ob_spec.obspec.fillpattern==0)	/*	Si trƒme nulle */
							{
								tree[child].ob_spec.obspec.fillpattern=7;
								if (glb.extnd[4]<4)
									tree[child].ob_spec.obspec.interiorcol=WHITE;
								else
									tree[child].ob_spec.obspec.interiorcol+=LWHITE;
							}
						}
						tab->ublk[k].spec					=	(long)tree[child].ob_spec.index;
						tab->ublk[k].blk.ub_parm		=	(long)&tab->ublk[k];
						tab->ublk[k].blk.ub_code		=	_drawBox;
						tab->ublk[k].type					=	type;
						tree[child].ob_spec.userblk	=	&tab->ublk[k].blk;
						tree[child].ob_type				=	xtype+G_USERDEF;
						k+=1;
						break;
					case	G_BOXTEXT:
						if (tree[child].ob_state&WHITEBAK)
						{
							dummy=tree[child].ob_spec.tedinfo->te_color;
							if ( ((dummy>>4)&0x7)==0 )		/*	Si trƒme nulle */
							{
								dummy&=~255;
								dummy+=(7<<4);			/*	Trƒme			*/
								if (glb.extnd[4]<4)
									dummy+=WHITE;
								else
									dummy+=LWHITE;
								tree[child].ob_spec.tedinfo->te_color=dummy;
							}
						}
						tab->ublk[k].spec					=	(long)tree[child].ob_spec.tedinfo;
						tab->ublk[k].blk.ub_parm		=	(long)&tab->ublk[k];
						tab->ublk[k].blk.ub_code		=	_drawBoxText;
						tab->ublk[k].type					=	type;
						tree[child].ob_spec.userblk	=	&tab->ublk[k].blk;
						tree[child].ob_type				=	xtype+G_USERDEF;
						k+=1;
						break;
					case	G_FBOXTEXT:
						if (tree[child].ob_state&WHITEBAK)
						{
							dummy=tree[child].ob_spec.tedinfo->te_color;
							if ( ((dummy>>4)&0x7)==0 )		/*	Si trƒme nulle */
							{
								dummy&=~255;
								dummy+=(7<<4);			/*	Trƒme			*/
								if (glb.extnd[4]<4)
									dummy+=WHITE;
								else
									dummy+=LWHITE;
								tree[child].ob_spec.tedinfo->te_color=dummy;
							}
						}
						tab->ublk[k].spec					=	(long)tree[child].ob_spec.tedinfo;
						tab->ublk[k].blk.ub_parm		=	(long)&tab->ublk[k];
						tab->ublk[k].blk.ub_code		=	_drawFBoxText;
						tab->ublk[k].type					=	type;
						tree[child].ob_spec.userblk	=	&tab->ublk[k].blk;
						tree[child].ob_type				=	xtype+G_USERDEF;
						k+=1;
						break;
					case	G_STRING:
						tree[child].ob_state&=~DRAW3D;
						if ( (tree[child].ob_state&WHITEBAK) && (glb.extnd[4]>=4) )
							tree[child].ob_state|=WHITEBAK;
						else
							tree[child].ob_state&=~WHITEBAK;
						tab->ublk[k].spec					=	(long)tree[child].ob_spec.free_string;
						tab->ublk[k].blk.ub_parm		=	(long)&tab->ublk[k];
						p=(char *)tab->ublk[k].spec;
						if ( (*p=='-') && (tree[child].ob_state&DISABLED) )
							tab->ublk[k].blk.ub_code	=	_drawNiceLine;
						else
							tab->ublk[k].blk.ub_code	=	_drawString;
						tab->ublk[k].type					=	type;
						tree[child].ob_spec.userblk	=	&tab->ublk[k].blk;
						tree[child].ob_type				=	xtype+G_USERDEF;
						k+=1;
						break;
					case	G_BUTTON:
						if ( (xtype==USD_CARRE) || (xtype==USD_ROND) )
						{
							tree[child].ob_state&=~WHITEBAK;
							tab->ublk[k].spec					=	(long)tree[child].ob_spec.free_string;
							tab->ublk[k].blk.ub_parm		=	(long)&tab->ublk[k];
							tab->ublk[k].blk.ub_code		=	_drawCroixCarre;
							tab->ublk[k].type					=	type;
							tree[child].ob_spec.userblk	=	&tab->ublk[k].blk;
							tree[child].ob_type				=	xtype+G_USERDEF;
							if (glb.extnd[4]>=4)
								tree[child].ob_state|=DRAW3D;
							else
								tree[child].ob_state&=~DRAW3D;
						}
						else if ( (xtype==USD_POPUP) || (xtype==USD_XPOPUP) )
						{
							tree[child].ob_state&=~WHITEBAK;
							tab->ublk[k].spec					=	(long)tree[child].ob_spec.free_string;
							tab->ublk[k].blk.ub_parm		=	(long)&tab->ublk[k];
							tab->ublk[k].blk.ub_code		=	_drawPopUp;
							tab->ublk[k].type					=	type;
							tree[child].ob_spec.userblk	=	&tab->ublk[k].blk;
							tree[child].ob_type				=	xtype+G_USERDEF;
							if (glb.extnd[4]>=4)
								tree[child].ob_state|=DRAW3D;
							else
								tree[child].ob_state&=~DRAW3D;
						}
						else
						{
							if (tree[child].ob_state&DRAW3D)
							{
								if (glb.extnd[4]<4)
									tree[child].ob_state&=~DRAW3D;
							}
							if (tree[child].ob_state&WHITEBAK)
							{
								if (glb.extnd[4]<4)
									tree[child].ob_state&=~WHITEBAK;
							}
							tab->ublk[k].spec					=	(long)tree[child].ob_spec.free_string;
							tab->ublk[k].blk.ub_parm		=	(long)&tab->ublk[k];
							if (tree[child].ob_state&DRAW3D)
								tab->ublk[k].blk.ub_code	=	_draw3dButton;
							else if (tree[child].ob_state&WHITEBAK)
								tab->ublk[k].blk.ub_code	=	_drawBakButton;
							else
								tab->ublk[k].blk.ub_code	=	_drawButton;
							tab->ublk[k].type					=	type;
							tree[child].ob_spec.userblk	=	&tab->ublk[k].blk;
							tree[child].ob_type				=	xtype+G_USERDEF;
						}
						k+=1;
						break;
					case	G_IMAGE:
						if ( (glb.low) && (tree[child].ob_state&STATE15) )
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
						if ( (glb.low) && (tree[child].ob_state&STATE15) )
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
						if ( (glb.low) && (tree[child].ob_state&STATE15) )
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
									for (dummy=0;dummy<cicon->num_planes;dummy++)
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
									for (dummy=0;dummy<cicon->num_planes;dummy++)
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
						color=_addCicon((CICONBLK *)tree[child].ob_spec.index,&tree[child],&tab->ublk[k],&tab->cicon[j]);
						if (color==FALSE)
							return FALSE;
						else if (color==2*TRUE)
						{
							memset(&tab->cicon[j],0,sizeof(CICON));
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


/******************************************************************************/
/*	USERDEF objects de-initialisation														*/
/******************************************************************************/

void _exitUserdef(RSC *tab)
{
	int		i;

	if (tab->cicon!=NULL)
	{
		for (i=0;i<tab->head.ncib;i++)
		{
			if (tab->cicon[i].num_planes>1)
			{
				if (tab->cicon[i].col_data!=NULL)
					_mSpecFree((long)tab->cicon[i].col_data);
				if (tab->cicon[i].sel_data!=NULL)
					_mSpecFree((long)tab->cicon[i].sel_data);
				if (tab->cicon[i].sel_data==NULL && tab->cicon[i].sel_mask!=NULL)
					_mSpecFree((long)tab->cicon[i].sel_mask);
			}
		}
		_mSpecFree((long)tab->cicon);
	}
	if (tab->ublk)
		_mSpecFree((long)tab->ublk);
}


/******************************************************************************/
/*	G_BOXTEXT																						*/
/******************************************************************************/
int cdecl _drawBoxText(PARMBLK *parm)
{
	int			my3d=0;
	TEDINFO		*ted;

	tLarg=0;
	vqt_attributes(glb.hvdi,tattr);
   vqf_attributes(glb.hvdi,fattr);
	state=parm->pb_tree[parm->pb_obj].ob_state;
	type=(parm->pb_tree[parm->pb_obj].ob_type)>>8;
	eff=TXT_NORMAL;
	if (state&STATE15) 	eff+=TXT_THICKENED;
	if (state&STATE14)	eff+=TXT_LIGHT;
	if (state&STATE13)	eff+=TXT_UNDERLINED;
	vst_effects(glb.hvdi,eff);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
   vql_attributes(glb.hvdi,lattr);
	user=(UBLK *)(parm->pb_parm);
	ted=(TEDINFO *)user->spec;
	vsf_perimeter(glb.hvdi,FALSE);
	vswr_mode(glb.hvdi,MD_REPLACE);										/*	Mode remplacement		*/

	my1.g_x=parm->pb_x;
	my1.g_y=parm->pb_y;
	my1.g_w=parm->pb_w;
	my1.g_h=parm->pb_h;
	if (state&DRAW3D)
	{
		my1.g_x-=2;
		my1.g_y-=2;
		my1.g_w+=4;
		my1.g_h+=4;
	}
	if (ted->te_thickness<0)
	{
		my1.g_x+=ted->te_thickness;
		my1.g_y+=ted->te_thickness;
		my1.g_w-=2*ted->te_thickness;
		my1.g_h-=2*ted->te_thickness;
	}
	else
	{
		my1.g_x+=1;
		my1.g_y+=1;
		my1.g_w-=2;
		my1.g_h-=2;
	}
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);

	vsl_type(glb.hvdi,SOLID);
	vsl_width(glb.hvdi,1);
	vsl_color(glb.hvdi,((ted->te_color)>>12)&0xF);		/*	Couleur Cadre	*/
	for (i=0;i<abs(ted->te_thickness);i++)
	{
		pxy[0]=my1.g_x;
		pxy[1]=my1.g_y;
		pxy[2]=my1.g_x+my1.g_w-1;
		pxy[3]=pxy[1];
		pxy[4]=pxy[2];
		pxy[5]=my1.g_y+my1.g_h-1;
		pxy[6]=pxy[0];
		pxy[7]=pxy[5];
		pxy[8]=pxy[0];
		pxy[9]=pxy[1];
		v_pline(glb.hvdi,5,pxy);
		my1.g_x+=1;
		my1.g_y+=1;
		my1.g_w-=2;
		my1.g_h-=2;
	}
	vs_clip(glb.hvdi,FALSE,tab_clip);

	if ( (state&WHITEBAK) && (state&OUTLINED) )
	{
		my3d=1;
		my1.g_x=parm->pb_x-4;
		my1.g_y=parm->pb_y-4;
		my1.g_w=parm->pb_w+8;
		my1.g_h=parm->pb_h+8;
		my2.g_x=parm->pb_xc;
		my2.g_y=parm->pb_yc;
		my2.g_w=parm->pb_wc;
		my2.g_h=parm->pb_hc;
		_rcIntersect(&my1,&my2);
		tab_clip[0]=my2.g_x;
		tab_clip[1]=my2.g_y;
		tab_clip[2]=tab_clip[0]+my2.g_w-1;
		tab_clip[3]=tab_clip[1]+my2.g_h-1;
		vs_clip(glb.hvdi,TRUE,tab_clip);
		for (i=0;i<3;i++)
		{
			my1.g_x+=1;
			my1.g_y+=1;
			my1.g_w-=2;
			my1.g_h-=2;
			pxy[0]=my1.g_x;
			pxy[1]=my1.g_y+my1.g_h-1;
			pxy[2]=pxy[0];
			pxy[3]=my1.g_y;
			pxy[4]=my1.g_x+my1.g_w-1;
			pxy[5]=pxy[3];
			if (parm->pb_currstate&SELECTED)
				vsl_color(glb.hvdi,LBLACK);
			else
				vsl_color(glb.hvdi,WHITE);
			v_pline(glb.hvdi,3,pxy);
			pxy[0]=my1.g_x;
			pxy[1]=my1.g_y+my1.g_h-1;
			pxy[2]=my1.g_x+my1.g_w-1;
			pxy[3]=pxy[1];
			pxy[4]=pxy[2];
			pxy[5]=my1.g_y;
			if (parm->pb_currstate&SELECTED)
				vsl_color(glb.hvdi,WHITE);
			else
				vsl_color(glb.hvdi,LBLACK);
			v_pline(glb.hvdi,3,pxy);
		}
		vs_clip(glb.hvdi,FALSE,tab_clip);
	}
	if (state&DRAW3D)
	{
		my3d=1;
		my1.g_x=parm->pb_x-2;
		my1.g_y=parm->pb_y-2;
		my1.g_w=parm->pb_w+4;
		my1.g_h=parm->pb_h+4;
		if (ted->te_thickness>0)
		{
			my1.g_x+=1+ted->te_thickness;
			my1.g_y+=1+ted->te_thickness;
			my1.g_w-=2+2*ted->te_thickness;
			my1.g_h-=2+2*ted->te_thickness;
		}
		my2.g_x=parm->pb_xc;
		my2.g_y=parm->pb_yc;
		my2.g_w=parm->pb_wc;
		my2.g_h=parm->pb_hc;
		_rcIntersect(&my1,&my2);
		tab_clip[0]=my2.g_x;
		tab_clip[1]=my2.g_y;
		tab_clip[2]=tab_clip[0]+my2.g_w-1;
		tab_clip[3]=tab_clip[1]+my2.g_h-1;
		vs_clip(glb.hvdi,TRUE,tab_clip);
		pxy[0]=my1.g_x;
		pxy[1]=my1.g_y+my1.g_h-1;
		pxy[2]=pxy[0];
		pxy[3]=my1.g_y;
		pxy[4]=my1.g_x+my1.g_w-1;
		pxy[5]=pxy[3];
		if (parm->pb_currstate&SELECTED)
			vsl_color(glb.hvdi,BLACK);
		else
			vsl_color(glb.hvdi,WHITE);
		v_pline(glb.hvdi,3,pxy);
		pxy[0]=my1.g_x;
		pxy[1]=my1.g_y+my1.g_h-1;
		pxy[2]=my1.g_x+my1.g_w-1;
		pxy[3]=pxy[1];
		pxy[4]=pxy[2];
		pxy[5]=my1.g_y;
		if (parm->pb_currstate&SELECTED)
			vsl_color(glb.hvdi,WHITE);
		else
			vsl_color(glb.hvdi,LBLACK);
		v_pline(glb.hvdi,3,pxy);
		vs_clip(glb.hvdi,FALSE,tab_clip);
	}

	if (state&DRAW3D)
	{
		my1.g_x=parm->pb_x-1;
		my1.g_y=parm->pb_y-1;
		my1.g_w=parm->pb_w+2;
		my1.g_h=parm->pb_h+2;
	}
	else
	{
		my1.g_x=parm->pb_x;
		my1.g_y=parm->pb_y;
		my1.g_w=parm->pb_w;
		my1.g_h=parm->pb_h;
	}
	if (ted->te_thickness>0)
	{
		my1.g_x+=1+ted->te_thickness;
		my1.g_y+=1+ted->te_thickness;
		my1.g_w-=2+2*ted->te_thickness;
		my1.g_h-=2+2*ted->te_thickness;
	}
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	if ( (parm->pb_currstate&SELECTED) && (!my3d) )
		vsf_color(glb.hvdi,col[(ted->te_color)&0xF]);	/*	Couleur de fond	*/
	else
		vsf_color(glb.hvdi,(ted->te_color)&0xF);			/*	Couleur de fond	*/
	fill=((ted->te_color)>>4)&0x7;							/*	Motif					*/
	if (fill==0)
	{
		vsf_interior(glb.hvdi,FIS_SOLID);
		vsf_style(glb.hvdi,0);
		if (parm->pb_currstate&SELECTED)
			vsf_color(glb.hvdi,col[WHITE]);					/*	Couleur BLANCHE	*/
		else
			vsf_color(glb.hvdi,WHITE);							/*	Couleur BLANCHE	*/
	}
	else if (fill==7)
	{
		vsf_interior(glb.hvdi,FIS_SOLID);
		vsf_style(glb.hvdi,0);
	}
	else
	{
		vsf_interior(glb.hvdi,FIS_PATTERN);
		vsf_style(glb.hvdi,fill);
	}
	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=my1.g_x+my1.g_w-1;
	bar[3]=my1.g_y+my1.g_h-1;
	v_bar(glb.hvdi,bar);

	if (type!=0)
		pnt=type;
	else if (ted->te_font==3)
		pnt=10-2*glb.low;
	else
		pnt=8-glb.low;
	if (state&STATE10)
		ind=glb.opt.GDfnt;
	else if (state&STATE8)
		ind=glb.opt.GIfnt;
	else if (state&STATE11)
		ind=glb.opt.HIfnt;
	else if (state&STATE9)
		ind=1;
	else
		ind=glb.opt.Gfnt;
	if (glb.gdos)
		vst_font(glb.hvdi,font[ind].index);
	vect=font[ind].name[32];
	if (vect)
		vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
	else
		vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
	if ( (parm->pb_currstate&SELECTED) && (!my3d) )
		color=col[((ted->te_color)&0xF00)>>8];
	else
		color=((ted->te_color)&0xF00)>>8;
	vst_color(glb.hvdi,color);
	if (ted->te_color&0x80)
		vswr_mode(glb.hvdi,MD_REPLACE);		/*	Mode remplacement	*/
	else
		vswr_mode(glb.hvdi,MD_TRANS);			/*	Mode transparent	*/
	p=(uchar *)ted->te_ptext;
	trait=(uchar *)strchr(ted->te_ptext,0x5B);
	if ( (trait!=NULL) && (trait!=p) )
	{
		*trait=0;
		if (vect)
			vqt_f_extent(glb.hvdi,(char *)p,extent);
		else
			vqt_extent(glb.hvdi,(char *)p,extent);
		*trait='[';
		trait++;
		tLarg=extent[2]-extent[6];
	}
	else
		trait=(uchar *)ted->te_ptext;
	if (vect)
		vqt_f_extent(glb.hvdi,(char *)trait,extent);
	else
		vqt_extent(glb.hvdi,(char *)trait,extent);
	tLarg+=extent[2]-extent[6];

	x=parm->pb_x;
	y=parm->pb_y;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2 ;
	y+=htext;

	if ( (my3d) && (parm->pb_currstate&SELECTED) )
	{
		x+=1;
		y+=1;
	}

	switch (ted->te_just)
	{
		case	1:		x+=(parm->pb_w-tLarg);		break;
		case	2:		x+=(parm->pb_w-tLarg)/2;	break;
	}

	trait=(uchar *)strchr(ted->te_ptext,0x5B);
	if (trait!=NULL)
	{
		*trait=0;
		if (vect)
		{
			vqt_f_extent(glb.hvdi,(char *)p,extent);
			v_ftext(glb.hvdi,x,y,(char *)p);
		}
		else
		{
			vqt_extent(glb.hvdi,(char *)p,extent);
			v_gtext(glb.hvdi,x,y,(char *)p);
		}
		*trait='[';
		trait++;
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			car[0]=*trait;
			car[1]=0;
			vst_color(glb.hvdi,RED);
			if (vect)
			{
				v_ftext(glb.hvdi,x,y,(char *)car);
				vqt_f_extent(glb.hvdi,(char *)car,extent);
			}
			else
			{
				v_gtext(glb.hvdi,x,y,(char *)car);
				vqt_extent(glb.hvdi,(char *)car,extent);
			}
			vst_color(glb.hvdi,color);
			trait++;
		}
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			if (vect)
				v_ftext(glb.hvdi,x,y,(char *)trait);
			else
				v_gtext(glb.hvdi,x,y,(char *)trait);
		}
	}
	else
		if (vect)
			v_ftext(glb.hvdi,x,y,ted->te_ptext);
		else
			v_gtext(glb.hvdi,x,y,ted->te_ptext);
	vs_clip(glb.hvdi,FALSE,tab_clip);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	vsl_type(glb.hvdi,lattr[0]);
	vsl_color(glb.hvdi,lattr[1]);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
	if (glb.gdos)
		vst_font(glb.hvdi,tattr[0]);
	if ( (state&WHITEBAK) && (state&OUTLINED) )
		return parm->pb_currstate&~(SELECTED|OUTLINED|WHITEBAK|DRAW3D);
	else
		return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	G_FBOXTEXT																						*/
/******************************************************************************/
int cdecl _drawFBoxText(PARMBLK *parm)
{
	int			my3d=0;
	TEDINFO		*ted;

	tLarg=0;
	vqt_attributes(glb.hvdi,tattr);
   vqf_attributes(glb.hvdi,fattr);
	state=parm->pb_tree[parm->pb_obj].ob_state;
	type=(parm->pb_tree[parm->pb_obj].ob_type)>>8;
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
   vql_attributes(glb.hvdi,lattr);
	user=(UBLK *)(parm->pb_parm);
	ted=(TEDINFO *)user->spec;
	vsf_perimeter(glb.hvdi,FALSE);
	vswr_mode(glb.hvdi,MD_REPLACE);	/*	Mode remplacement		*/

	my1.g_x=parm->pb_x;
	my1.g_y=parm->pb_y;
	my1.g_w=parm->pb_w;
	my1.g_h=parm->pb_h;
	if (state&DRAW3D)
	{
		my1.g_x-=2;
		my1.g_y-=2;
		my1.g_w+=4;
		my1.g_h+=4;
	}
	if (ted->te_thickness<0)
	{
		my1.g_x+=ted->te_thickness;
		my1.g_y+=ted->te_thickness;
		my1.g_w-=2*ted->te_thickness;
		my1.g_h-=2*ted->te_thickness;
	}
	else
	{
		my1.g_x+=1;
		my1.g_y+=1;
		my1.g_w-=2;
		my1.g_h-=2;
	}
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);

	vsl_type(glb.hvdi,SOLID);
	vsl_width(glb.hvdi,1);
	vsl_color(glb.hvdi,((ted->te_color)>>12)&0xF);	/*	Couleur Cadre	*/
	for (i=0;i<abs(ted->te_thickness);i++)
	{
		pxy[0]=my1.g_x;
		pxy[1]=my1.g_y;
		pxy[2]=my1.g_x+my1.g_w-1;
		pxy[3]=pxy[1];
		pxy[4]=pxy[2];
		pxy[5]=my1.g_y+my1.g_h-1;
		pxy[6]=pxy[0];
		pxy[7]=pxy[5];
		pxy[8]=pxy[0];
		pxy[9]=pxy[1];
		v_pline(glb.hvdi,5,pxy);
		my1.g_x+=1;
		my1.g_y+=1;
		my1.g_w-=2;
		my1.g_h-=2;
	}
	vs_clip(glb.hvdi,FALSE,tab_clip);

	if ( (state&WHITEBAK) && (state&OUTLINED) )
	{
		my3d=1;
		my1.g_x=parm->pb_x-4;
		my1.g_y=parm->pb_y-4;
		my1.g_w=parm->pb_w+8;
		my1.g_h=parm->pb_h+8;
		my2.g_x=parm->pb_xc;
		my2.g_y=parm->pb_yc;
		my2.g_w=parm->pb_wc;
		my2.g_h=parm->pb_hc;
		_rcIntersect(&my1,&my2);
		tab_clip[0]=my2.g_x;
		tab_clip[1]=my2.g_y;
		tab_clip[2]=tab_clip[0]+my2.g_w-1;
		tab_clip[3]=tab_clip[1]+my2.g_h-1;
		vs_clip(glb.hvdi,TRUE,tab_clip);
		for (i=0;i<3;i++)
		{
			my1.g_x+=1;
			my1.g_y+=1;
			my1.g_w-=2;
			my1.g_h-=2;
			pxy[0]=my1.g_x;
			pxy[1]=my1.g_y+my1.g_h-1;
			pxy[2]=pxy[0];
			pxy[3]=my1.g_y;
			pxy[4]=my1.g_x+my1.g_w-1;
			pxy[5]=pxy[3];
			if (parm->pb_currstate&SELECTED)
				vsl_color(glb.hvdi,LBLACK);
			else
				vsl_color(glb.hvdi,WHITE);
			v_pline(glb.hvdi,3,pxy);
			pxy[0]=my1.g_x;
			pxy[1]=my1.g_y+my1.g_h-1;
			pxy[2]=my1.g_x+my1.g_w-1;
			pxy[3]=pxy[1];
			pxy[4]=pxy[2];
			pxy[5]=my1.g_y;
			if (parm->pb_currstate&SELECTED)
				vsl_color(glb.hvdi,WHITE);
			else
				vsl_color(glb.hvdi,LBLACK);
			v_pline(glb.hvdi,3,pxy);
		}
		vs_clip(glb.hvdi,FALSE,tab_clip);
	}
	if (state&DRAW3D)
	{
		my3d=1;
		my1.g_x=parm->pb_x-2;
		my1.g_y=parm->pb_y-2;
		my1.g_w=parm->pb_w+4;
		my1.g_h=parm->pb_h+4;
		if (ted->te_thickness>0)
		{
			my1.g_x+=1+ted->te_thickness;
			my1.g_y+=1+ted->te_thickness;
			my1.g_w-=2+2*ted->te_thickness;
			my1.g_h-=2+2*ted->te_thickness;
		}
		my2.g_x=parm->pb_xc;
		my2.g_y=parm->pb_yc;
		my2.g_w=parm->pb_wc;
		my2.g_h=parm->pb_hc;
		_rcIntersect(&my1,&my2);
		tab_clip[0]=my2.g_x;
		tab_clip[1]=my2.g_y;
		tab_clip[2]=tab_clip[0]+my2.g_w-1;
		tab_clip[3]=tab_clip[1]+my2.g_h-1;
		vs_clip(glb.hvdi,TRUE,tab_clip);
		pxy[0]=my1.g_x;
		pxy[1]=my1.g_y+my1.g_h-1;
		pxy[2]=pxy[0];
		pxy[3]=my1.g_y;
		pxy[4]=my1.g_x+my1.g_w-1;
		pxy[5]=pxy[3];
		if (parm->pb_currstate&SELECTED)
			vsl_color(glb.hvdi,BLACK);
		else
			vsl_color(glb.hvdi,WHITE);
		v_pline(glb.hvdi,3,pxy);
		pxy[0]=my1.g_x;
		pxy[1]=my1.g_y+my1.g_h-1;
		pxy[2]=my1.g_x+my1.g_w-1;
		pxy[3]=pxy[1];
		pxy[4]=pxy[2];
		pxy[5]=my1.g_y;
		if (parm->pb_currstate&SELECTED)
			vsl_color(glb.hvdi,WHITE);
		else
			vsl_color(glb.hvdi,LBLACK);
		v_pline(glb.hvdi,3,pxy);
		vs_clip(glb.hvdi,FALSE,tab_clip);
	}

	if (state&DRAW3D)
	{
		my1.g_x=parm->pb_x-1;
		my1.g_y=parm->pb_y-1;
		my1.g_w=parm->pb_w+2;
		my1.g_h=parm->pb_h+2;
	}
	else
	{
		my1.g_x=parm->pb_x;
		my1.g_y=parm->pb_y;
		my1.g_w=parm->pb_w;
		my1.g_h=parm->pb_h;
	}
	if (ted->te_thickness>0)
	{
		my1.g_x+=1+ted->te_thickness;
		my1.g_y+=1+ted->te_thickness;
		my1.g_w-=2+2*ted->te_thickness;
		my1.g_h-=2+2*ted->te_thickness;
	}
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	if ( (parm->pb_currstate&SELECTED) && (!my3d) )
		vsf_color(glb.hvdi,col[(ted->te_color)&0xF]);	/*	Couleur de fond	*/
	else
		vsf_color(glb.hvdi,(ted->te_color)&0xF);			/*	Couleur de fond	*/
	fill=((ted->te_color)>>4)&0x7;							/*	Motif					*/
	if (fill==0)
	{
		vsf_interior(glb.hvdi,FIS_SOLID);
		vsf_style(glb.hvdi,0);
		if (parm->pb_currstate&SELECTED)
			vsf_color(glb.hvdi,col[WHITE]);					/*	Couleur BLANCHE	*/
		else
			vsf_color(glb.hvdi,WHITE);							/*	Couleur BLANCHE	*/
	}
	else if (fill==7)
	{
		vsf_interior(glb.hvdi,FIS_SOLID);
		vsf_style(glb.hvdi,0);
	}
	else
	{
		vsf_interior(glb.hvdi,FIS_PATTERN);
		vsf_style(glb.hvdi,fill);
	}
	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=my1.g_x+my1.g_w-1;
	bar[3]=my1.g_y+my1.g_h-1;
	v_bar(glb.hvdi,bar);

	if (type!=0)
		pnt=type;
	else if (ted->te_font==3)
		pnt=10-2*glb.low;
	else
		pnt=8-glb.low;
	if (state&STATE10)
		ind=glb.opt.GDfnt;
	else if (state&STATE8)
		ind=glb.opt.GIfnt;
	else if (state&STATE11)
		ind=glb.opt.HIfnt;
	else if (state&STATE9)
		ind=1;
	else
		ind=glb.opt.Gfnt;
	if (glb.gdos)
		vst_font(glb.hvdi,font[ind].index);
	vect=font[ind].name[32];
	if (vect)
		vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
	else
		vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
	if ( (parm->pb_currstate&SELECTED) && (!my3d) )
		color=col[((ted->te_color)&0xF00)>>8];
	else
		color=((ted->te_color)&0xF00)>>8;
	vst_color(glb.hvdi,color);
	if (ted->te_color&0x80)
		vswr_mode(glb.hvdi,MD_REPLACE);	/*	Mode remplacement	*/
	else
		vswr_mode(glb.hvdi,MD_TRANS);		/*	Mode transparent	*/

	vqt_extent(glb.hvdi,ted->te_ptext,extent);
	x=parm->pb_x;
	y=parm->pb_y;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2 ;
	y+=htext;

	p=(uchar *)ted->te_ptmplt;
	trait=(uchar *)ted->te_ptext;
	car[1]=0;
	while (*p!=0)
	{
		if (*p=='_')
		{
			if (*trait==0)
				car[0]='_';
			else if (*trait<=' ')
				car[0]=' ';
			else
				car[0]=*trait;
			if (*trait!=0)
				trait++;
		}
		else
			car[0]=*p;
		if (vect)
		{
			vqt_f_extent(glb.hvdi,(char *)car,extent);
			v_ftext(glb.hvdi,x,y,(char *)car);
		}
		else
		{
			vqt_extent(glb.hvdi,(char *)car,extent);
			v_gtext(glb.hvdi,x,y,(char *)car);
		}
		x+=extent[2]-extent[6];
		p++;
	}
	vs_clip(glb.hvdi,FALSE,tab_clip);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	vsl_type(glb.hvdi,lattr[0]);
	vsl_color(glb.hvdi,lattr[1]);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
	if (glb.gdos)
		vst_font(glb.hvdi,tattr[0]);
	if ( (state&WHITEBAK) && (state&OUTLINED) )
		return parm->pb_currstate&~(SELECTED|OUTLINED|WHITEBAK|DRAW3D);
	else
		return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	G_BOX, G_IBOX, G_BOXCHAR																	*/
/******************************************************************************/
int cdecl _drawBox(PARMBLK *parm)
{
	int			my3d=0;
	bfobspec		*info;

   vqf_attributes(glb.hvdi,fattr);
   vql_attributes(glb.hvdi,lattr);
	state=parm->pb_tree[parm->pb_obj].ob_state;
	type=(parm->pb_tree[parm->pb_obj].ob_type)>>8;
	user=(UBLK *)(parm->pb_parm);
	info=(bfobspec *)&user->spec;
	vsf_perimeter(glb.hvdi,FALSE);
	vswr_mode(glb.hvdi,MD_REPLACE);	/*	Mode remplacement	*/
	my1.g_x=parm->pb_x;
	my1.g_y=parm->pb_y;
	my1.g_w=parm->pb_w;
	my1.g_h=parm->pb_h;
	if (state&DRAW3D)
	{
		my1.g_x-=2;
		my1.g_y-=2;
		my1.g_w+=4;
		my1.g_h+=4;
	}
	if (info->framesize<0)
	{
		my1.g_x+=info->framesize;
		my1.g_y+=info->framesize;
		my1.g_w-=2*info->framesize;
		my1.g_h-=2*info->framesize;
	}
	else
	{
		my1.g_x+=1;
		my1.g_y+=1;
		my1.g_w-=2;
		my1.g_h-=2;
	}
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);

	vsl_type(glb.hvdi,SOLID);
	vsl_width(glb.hvdi,1);
	vsl_color(glb.hvdi,BLACK);
	for (i=0;i<abs(info->framesize);i++)
	{
		pxy[0]=my1.g_x;
		pxy[1]=my1.g_y;
		pxy[2]=my1.g_x+my1.g_w-1;
		pxy[3]=pxy[1];
		pxy[4]=pxy[2];
		pxy[5]=my1.g_y+my1.g_h-1;
		pxy[6]=pxy[0];
		pxy[7]=pxy[5];
		pxy[8]=pxy[0];
		pxy[9]=pxy[1];
		v_pline(glb.hvdi,5,pxy);
		my1.g_x+=1;
		my1.g_y+=1;
		my1.g_w-=2;
		my1.g_h-=2;
	}
	vs_clip(glb.hvdi,FALSE,tab_clip);

	if ( (state&WHITEBAK) && (state&OUTLINED) )
	{
		my3d=1;
		my1.g_x=parm->pb_x-4;
		my1.g_y=parm->pb_y-4;
		my1.g_w=parm->pb_w+8;
		my1.g_h=parm->pb_h+8;
		my2.g_x=parm->pb_xc;
		my2.g_y=parm->pb_yc;
		my2.g_w=parm->pb_wc;
		my2.g_h=parm->pb_hc;
		_rcIntersect(&my1,&my2);
		tab_clip[0]=my2.g_x;
		tab_clip[1]=my2.g_y;
		tab_clip[2]=tab_clip[0]+my2.g_w-1;
		tab_clip[3]=tab_clip[1]+my2.g_h-1;
		vs_clip(glb.hvdi,TRUE,tab_clip);
		for (i=0;i<3;i++)
		{
			my1.g_x+=1;
			my1.g_y+=1;
			my1.g_w-=2;
			my1.g_h-=2;
			pxy[0]=my1.g_x;
			pxy[1]=my1.g_y+my1.g_h-1;
			pxy[2]=pxy[0];
			pxy[3]=my1.g_y;
			pxy[4]=my1.g_x+my1.g_w-1;
			pxy[5]=pxy[3];
			if (parm->pb_currstate&SELECTED)
				vsl_color(glb.hvdi,LBLACK);
			else
				vsl_color(glb.hvdi,WHITE);
			v_pline(glb.hvdi,3,pxy);
			pxy[0]=my1.g_x;
			pxy[1]=my1.g_y+my1.g_h-1;
			pxy[2]=my1.g_x+my1.g_w-1;
			pxy[3]=pxy[1];
			pxy[4]=pxy[2];
			pxy[5]=my1.g_y;
			if (parm->pb_currstate&SELECTED)
				vsl_color(glb.hvdi,WHITE);
			else
				vsl_color(glb.hvdi,LBLACK);
			v_pline(glb.hvdi,3,pxy);
		}
		vs_clip(glb.hvdi,FALSE,tab_clip);
	}
	else if (state&DRAW3D)
	{
		my3d=1;
		my1.g_x=parm->pb_x-2;
		my1.g_y=parm->pb_y-2;
		my1.g_w=parm->pb_w+4;
		my1.g_h=parm->pb_h+4;
		if (info->framesize>0)
		{
			my1.g_x+=1+info->framesize;
			my1.g_y+=1+info->framesize;
			my1.g_w-=2+2*info->framesize;
			my1.g_h-=2+2*info->framesize;
		}
		my2.g_x=parm->pb_xc;
		my2.g_y=parm->pb_yc;
		my2.g_w=parm->pb_wc;
		my2.g_h=parm->pb_hc;
		_rcIntersect(&my1,&my2);
		tab_clip[0]=my2.g_x;
		tab_clip[1]=my2.g_y;
		tab_clip[2]=tab_clip[0]+my2.g_w-1;
		tab_clip[3]=tab_clip[1]+my2.g_h-1;
		vs_clip(glb.hvdi,TRUE,tab_clip);
		pxy[0]=my1.g_x;
		pxy[1]=my1.g_y+my1.g_h-1;
		pxy[2]=pxy[0];
		pxy[3]=my1.g_y;
		pxy[4]=my1.g_x+my1.g_w-1;
		pxy[5]=pxy[3];
		if (parm->pb_currstate&SELECTED)
			vsl_color(glb.hvdi,BLACK);
		else
			vsl_color(glb.hvdi,WHITE);
		v_pline(glb.hvdi,3,pxy);
		pxy[0]=my1.g_x;
		pxy[1]=my1.g_y+my1.g_h-1;
		pxy[2]=my1.g_x+my1.g_w-1;
		pxy[3]=pxy[1];
		pxy[4]=pxy[2];
		pxy[5]=my1.g_y;
		if (parm->pb_currstate&SELECTED)
			vsl_color(glb.hvdi,WHITE);
		else
			vsl_color(glb.hvdi,LBLACK);
		v_pline(glb.hvdi,3,pxy);
		vs_clip(glb.hvdi,FALSE,tab_clip);
	}

	if (user->type!=G_IBOX)
	{
		if (state&DRAW3D)
		{
			my1.g_x=parm->pb_x-1;
			my1.g_y=parm->pb_y-1;
			my1.g_w=parm->pb_w+2;
			my1.g_h=parm->pb_h+2;
		}
		else
		{
			my1.g_x=parm->pb_x;
			my1.g_y=parm->pb_y;
			my1.g_w=parm->pb_w;
			my1.g_h=parm->pb_h;
		}
		if (info->framesize>0)
		{
			my1.g_x+=1+info->framesize;
			my1.g_y+=1+info->framesize;
			my1.g_w-=2+2*info->framesize;
			my1.g_h-=2+2*info->framesize;
		}
		my2.g_x=parm->pb_xc;
		my2.g_y=parm->pb_yc;
		my2.g_w=parm->pb_wc;
		my2.g_h=parm->pb_hc;
		_rcIntersect(&my1,&my2);
		tab_clip[0]=my2.g_x;
		tab_clip[1]=my2.g_y;
		tab_clip[2]=tab_clip[0]+my2.g_w-1;
		tab_clip[3]=tab_clip[1]+my2.g_h-1;
		vs_clip(glb.hvdi,TRUE,tab_clip);
		if ( (parm->pb_currstate&SELECTED) && (!my3d) )
			vsf_color(glb.hvdi,col[info->interiorcol]);	/*	Couleur de fond	*/
		else
			vsf_color(glb.hvdi,info->interiorcol);			/*	Couleur de fond	*/
		fill=info->fillpattern;									/*	Motif					*/
		if (fill==0)
		{
			vsf_interior(glb.hvdi,FIS_SOLID);
			vsf_style(glb.hvdi,0);
			if (parm->pb_currstate&SELECTED)
				vsf_color(glb.hvdi,col[WHITE]);				/*	Couleur BLANCHE	*/
			else
				vsf_color(glb.hvdi,WHITE);						/*	Couleur BLANCHE	*/
		}
		else if (fill==7)
		{
			vsf_interior(glb.hvdi,FIS_SOLID);
			vsf_style(glb.hvdi,0);
		}
		else
		{
			vsf_interior(glb.hvdi,FIS_PATTERN);
			vsf_style(glb.hvdi,fill);
		}
		bar[0]=my1.g_x;
		bar[1]=my1.g_y;
		bar[2]=my1.g_x+my1.g_w-1;
		bar[3]=my1.g_y+my1.g_h-1;
		v_bar(glb.hvdi,bar);

		if (user->type==G_BOXCHAR)
		{
			car[0]=info->character;
			car[1]=0;
			eff=TXT_NORMAL;
			if (state&STATE15) 	eff+=TXT_THICKENED;
			if (state&STATE14)	eff+=TXT_LIGHT;
			if (state&STATE13)	eff+=TXT_UNDERLINED;
			vst_effects(glb.hvdi,eff);
			vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);

			if (type!=0)
				pnt=type;
			else
				pnt=10-2*glb.low;
			if (state&STATE10)
				ind=glb.opt.GDfnt;
			else if (state&STATE8)
				ind=glb.opt.GIfnt;
			else if (state&STATE11)
				ind=glb.opt.HIfnt;
			else if (state&STATE9)
				ind=1;
			else
				ind=glb.opt.Gfnt;
			if (glb.gdos)
				vst_font(glb.hvdi,font[ind].index);
			vect=font[ind].name[32];
			if (vect)
				vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
			else
				vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
			if ( (parm->pb_currstate&SELECTED) && (!my3d) )
				vst_color(glb.hvdi,col[info->textcol]);
			else
				vst_color(glb.hvdi,info->textcol);
			if (info->textmode)
				vswr_mode(glb.hvdi,MD_REPLACE);	/*	Mode remplacement	*/
			else
				vswr_mode(glb.hvdi,MD_TRANS);		/*	Mode transparent	*/

			if (vect)
				vqt_f_extent(glb.hvdi,(char *)car,extent);
			else
				vqt_extent(glb.hvdi,(char *)car,extent);
			tLarg=extent[2]-extent[6];

			x=parm->pb_x;
			y=parm->pb_y;
			y+=parm->pb_h/2;
			y-=(extent[7]-extent[1])/2 ;
			y+=htext;

			if ( (my3d) && (parm->pb_currstate&SELECTED) )
			{
				x+=1;
				y+=1;
			}
			x+=(parm->pb_w-tLarg)/2;

			if (vect)
				v_ftext(glb.hvdi,x,y,(char *)car);
			else
				v_gtext(glb.hvdi,x,y,(char *)car);
		}
		vs_clip(glb.hvdi,FALSE,tab_clip);
	}
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	vsl_type(glb.hvdi,lattr[0]);
	vsl_color(glb.hvdi,lattr[1]);

	if ( (state&WHITEBAK) && (state&OUTLINED) )
		return parm->pb_tree[parm->pb_obj].ob_state&~(SELECTED|OUTLINED|WHITEBAK|DRAW3D);
	else
		return parm->pb_tree[parm->pb_obj].ob_state&~(SELECTED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	G_BUTTON (3D)																					*/
/******************************************************************************/
int cdecl _draw3dButton(PARMBLK *parm)
{
	tLarg=0;
   vqt_attributes(glb.hvdi,tattr);
   vqf_attributes(glb.hvdi,fattr);
   vql_attributes(glb.hvdi,lattr);
	state=parm->pb_tree[parm->pb_obj].ob_state;
	type=(parm->pb_tree[parm->pb_obj].ob_type)>>8;
	eff=TXT_NORMAL;
	if (state&STATE15) 	eff+=TXT_THICKENED;
	if (state&STATE14)	eff+=TXT_LIGHT;
	vst_effects(glb.hvdi,eff);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
	user=(UBLK *)(parm->pb_parm);

	if (type!=0)
		pnt=type;
	else
		pnt=10-2*glb.low;
	if (state&STATE10)
		ind=glb.opt.GDfnt;
	else if (state&STATE8)
		ind=glb.opt.GIfnt;
	else if (state&STATE11)
		ind=glb.opt.HIfnt;
	else if (state&STATE9)
		ind=1;
	else
		ind=glb.opt.Gfnt;
	if (glb.gdos)
		vst_font(glb.hvdi,font[ind].index);
	vect=font[ind].name[32];
	if (vect)
		vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
	else
	vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);

	tour=1;
	if (parm->pb_tree[parm->pb_obj].ob_flags&EXIT)		tour+=1;
	if (parm->pb_tree[parm->pb_obj].ob_flags&DEFAULT)	tour+=1;

	if (vect)
		vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
	else
		vqt_extent(glb.hvdi,(char *)user->spec,extent);
	tHaut=extent[7]-extent[1]+4-parm->pb_h;
	if (tHaut>0)
		tHaut/=2;
	else
		tHaut=0;
	parm->pb_y-=tHaut;
	parm->pb_h+=2*tHaut;

	my1.g_x=parm->pb_x-tour;
	my1.g_y=parm->pb_y-tour;
	my1.g_w=parm->pb_w+2*tour;
	my1.g_h=parm->pb_h+2*tour;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.hvdi,MD_REPLACE);			/*	Mode remplacement		*/
	vsf_perimeter(glb.hvdi,TRUE);				/*	P‚rimŠtre				*/
	vsf_interior(glb.hvdi,FIS_HOLLOW);		/*	Cadre vide				*/
	vsf_color(glb.hvdi,BLACK);					/*	Couleur: Noir			*/
	v_bar(glb.hvdi,bar);							/*	Trac‚ du cadre noir	*/
	vsf_perimeter(glb.hvdi,FALSE);			/*	Pas de p‚rimŠtre		*/
	vsf_interior(glb.hvdi,FIS_SOLID);		/*	Int‚rieur plein		*/
	vsf_style(glb.hvdi,0);						/*	Cadre plein				*/
	vsf_color(glb.hvdi,LWHITE);				/*	Couleur: Gris clair	*/
	bar[0]+=1;
	bar[1]+=1;
	bar[2]-=1;
	bar[3]-=1;
	v_bar(glb.hvdi,bar);							/*	Trac‚ du cadre	*/

	pxy[0]=bar[0];
	pxy[1]=bar[3];
	pxy[2]=bar[2];
	pxy[3]=bar[3];
	pxy[4]=bar[2];
	pxy[5]=bar[1];
	vsl_type(glb.hvdi,SOLID);
	vsl_width(glb.hvdi,1);
	if (parm->pb_currstate&SELECTED)
		vsl_color(glb.hvdi,WHITE);				/*	Couleur: Blanc	*/
	else
		vsl_color(glb.hvdi,LBLACK);			/*	Couleur: Gris fonc‚	*/
	for (i=0;i<tour;i++)
	{
		v_pline(glb.hvdi,3,pxy);				/*	Ligne	*/
		pxy[0]+=1;
		pxy[1]-=1;
		pxy[2]-=1;
		pxy[3]-=1;
		pxy[4]-=1;
		pxy[5]+=1;
	}
	pxy[0]=bar[0];
	pxy[1]=bar[3];
	pxy[2]=bar[0];
	pxy[3]=bar[1];
	pxy[4]=bar[2];
	pxy[5]=bar[1];
	if (parm->pb_currstate&SELECTED)
		vsl_color(glb.hvdi,LBLACK);	/*	Couleur: Gris fonc‚	*/
	else
		vsl_color(glb.hvdi,WHITE);		/*	Couleur: Blanc	*/
	for (i=0;i<tour;i++)
	{
		v_pline(glb.hvdi,3,pxy);		/*	Ligne	*/
		pxy[0]+=1;
		pxy[1]-=1;
		pxy[2]+=1;
		pxy[3]+=1;
		pxy[4]-=1;
		pxy[5]+=1;
	}
	vs_clip(glb.hvdi,FALSE,tab_clip);

	my1.g_x=parm->pb_x+1;
	my1.g_y=parm->pb_y+1;
	my1.g_w=parm->pb_w-2;
	my1.g_h=parm->pb_h-2;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	vswr_mode(glb.hvdi,MD_TRANS);

	trait=(uchar *)strchr((char *)user->spec,0x5B);
	if ( (trait!=NULL) && (trait!=(uchar *)user->spec) )
	{
		*trait=0;
		if (vect)
			vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
		else
			vqt_extent(glb.hvdi,(char *)user->spec,extent);
		*trait='[';
		trait++;
		tLarg=extent[2]-extent[6];
	}
	else
		trait=(uchar *)user->spec;
	if (vect)
		vqt_f_extent(glb.hvdi,(char *)trait,extent);
	else
		vqt_extent(glb.hvdi,(char *)trait,extent);
	tLarg+=extent[2]-extent[6];

	y=parm->pb_y-1;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2 ;
	y+=htext;
	if (parm->pb_currstate&SELECTED)
		y+=1;
	for (i=0;i<2;i++)
	{
		if (i)
			vst_color(glb.hvdi,BLACK);
		else
			vst_color(glb.hvdi,WHITE);
		x=parm->pb_x-1;
		x+=(parm->pb_w-tLarg)/2;
		x+=i;
		if (parm->pb_currstate&SELECTED)
			x+=1;
		y+=i;

		trait=(uchar *)strchr((char *)user->spec,0x5B);
		if (trait!=NULL)
		{
			*trait=0;
			if (vect)
			{
				vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
				v_ftext(glb.hvdi,x,y,(char *)user->spec);
			}
			else
			{
				vqt_extent(glb.hvdi,(char *)user->spec,extent);
				v_gtext(glb.hvdi,x,y,(char *)user->spec);
			}
			*trait='[';
			trait++;
			if (*trait!=0)
			{
				x+=extent[2]-extent[0];
				car[0]=*trait;
				car[1]=0;
				vst_effects(glb.hvdi,eff+TXT_UNDERLINED);
				if (vect)
				{
					v_ftext(glb.hvdi,x,y,(char *)car);
					vqt_f_extent(glb.hvdi,(char *)car,extent);
				}
				else
				{
					v_gtext(glb.hvdi,x,y,(char *)car);
					vqt_extent(glb.hvdi,(char *)car,extent);
				}
				vst_effects(glb.hvdi,eff);
				trait++;
			}
			if (*trait!=0)
			{
				x+=extent[2]-extent[0];
				if (vect)
					v_ftext(glb.hvdi,x,y,(char *)trait);
				else
					v_gtext(glb.hvdi,x,y,(char *)trait);
			}
		}
		else
			if (vect)
				v_ftext(glb.hvdi,x,y,(char *)user->spec);
			else
				v_gtext(glb.hvdi,x,y,(char *)user->spec);
	}

	vs_clip(glb.hvdi,FALSE,tab_clip);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
	if (glb.gdos)
		vst_font(glb.hvdi,tattr[0]);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	vsl_type(glb.hvdi,lattr[0]);
	vsl_color(glb.hvdi,lattr[1]);
	return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}

/******************************************************************************/
/*	G_BUTTON (relief)																				*/
/******************************************************************************/
int cdecl _drawBakButton(PARMBLK *parm)
{
	tLarg=0;
   vqt_attributes(glb.hvdi,tattr);
   vqf_attributes(glb.hvdi,fattr);
   vql_attributes(glb.hvdi,lattr);
	state=parm->pb_tree[parm->pb_obj].ob_state;
	type=(parm->pb_tree[parm->pb_obj].ob_type)>>8;
	eff=TXT_NORMAL;
	if (state&STATE15) 	eff+=TXT_THICKENED;
	if (state&STATE14)	eff+=TXT_LIGHT;
	vst_effects(glb.hvdi,eff);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
	user=(UBLK *)(parm->pb_parm);

	if (type!=0)
		pnt=type;
	else
		pnt=10-2*glb.low;
	if (state&STATE10)
		ind=glb.opt.GDfnt;
	else if (state&STATE8)
		ind=glb.opt.GIfnt;
	else if (state&STATE11)
		ind=glb.opt.HIfnt;
	else if (state&STATE9)
		ind=1;
	else
		ind=glb.opt.Gfnt;
	if (glb.gdos)
		vst_font(glb.hvdi,font[ind].index);
	vect=font[ind].name[32];
	if (vect)
		vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
	else
	vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);

	tour=1;
	if (parm->pb_tree[parm->pb_obj].ob_flags&EXIT)		tour+=1;
	if (parm->pb_tree[parm->pb_obj].ob_flags&DEFAULT)	tour+=1;
	if (vect)
		vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
	else
		vqt_extent(glb.hvdi,(char *)user->spec,extent);
	tHaut=extent[7]-extent[1]+4-parm->pb_h;
	if (tHaut>0)
		tHaut/=2;
	else
		tHaut=0;
	parm->pb_y-=tHaut;
	parm->pb_h+=2*tHaut;

	my1.g_x=parm->pb_x-tour;
	my1.g_y=parm->pb_y-tour;
	my1.g_w=parm->pb_w+2*tour;
	my1.g_h=parm->pb_h+2*tour;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.hvdi,MD_REPLACE);		/*	Mode remplacement		*/
	vsf_perimeter(glb.hvdi,FALSE);		/*	Pas de p‚rimŠtre		*/
	vsf_interior(glb.hvdi,FIS_SOLID);	/*	Cadre plein				*/
	vsf_style(glb.hvdi,0);					/*	Cadre plein				*/
	vsf_color(glb.hvdi,BLACK);				/*	Couleur: Noir			*/
	v_bar(glb.hvdi,bar);						/*	Trac‚ du cadre noir	*/

	if (parm->pb_currstate&SELECTED)
	{
		bar[0]=parm->pb_x;
		bar[1]=parm->pb_y;
		bar[2]=bar[0]+parm->pb_w-1;
		bar[3]=bar[1]+parm->pb_h-1;
		pxy[0]=bar[0]+1;
		pxy[1]=bar[3];
		pxy[2]=bar[2];
		pxy[3]=bar[3];
		pxy[4]=bar[2];
		pxy[5]=bar[1]+1;
		vsl_type(glb.hvdi,SOLID);
		vsl_width(glb.hvdi,1);
		if (glb.extnd[4]>=4)
		{
			vsf_color(glb.hvdi,LBLACK);	/*	Couleur: Gris fonc‚	*/
			v_bar(glb.hvdi,bar);				/*	Trac‚ du cadre int.	*/
			vsl_color(glb.hvdi,LWHITE);	/*	Ligne: Gris clair		*/
			pxy[0]-=1;
			pxy[5]-=1;
		}
		else
			vsl_color(glb.hvdi,WHITE);		/*	Ligne: Blanc			*/
		v_pline(glb.hvdi,3,pxy);
		color=WHITE;							/*	Texte: Blanc			*/
	}
	else
	{
		if (glb.extnd[4]>=4)
			vsf_color(glb.hvdi,LWHITE);	/*	Couleur: Gris clair	*/
		else
			vsf_color(glb.hvdi,WHITE);		/*	Couleur: Blanc			*/
		bar[0]=parm->pb_x;
		bar[1]=parm->pb_y;
		bar[2]=bar[0]+parm->pb_w-1;
		bar[3]=bar[1]+parm->pb_h-1;
		v_bar(glb.hvdi,bar);					/*	Trac‚ du cadre int.	*/
		vsl_color(glb.hvdi,WHITE);			/*	Ligne: Blanc			*/
		pxy[0]=bar[0];
		pxy[1]=bar[3]-1;
		pxy[2]=bar[0];
		pxy[3]=bar[1];
		pxy[4]=bar[2]-1;
		pxy[5]=bar[1];
		v_pline(glb.hvdi,3,pxy);
		if (glb.extnd[4]>=4)
			vsl_color(glb.hvdi,LBLACK);	/*	Ligne: Gris fonc‚		*/
		else
			vsl_color(glb.hvdi,BLACK);		/*	Ligne: Gris fonc‚		*/
		pxy[0]=bar[0]+1;
		pxy[1]=bar[3];
		pxy[2]=bar[2];
		pxy[3]=bar[3];
		pxy[4]=bar[2];
		pxy[5]=bar[1]+1;
		v_pline(glb.hvdi,3,pxy);
		color=BLACK;							/*	Texte: Noir				*/
	}
	vst_color(glb.hvdi,color);
	vs_clip(glb.hvdi,FALSE,tab_clip);

	my1.g_x=parm->pb_x+1;
	my1.g_y=parm->pb_y+1;
	my1.g_w=parm->pb_w-2;
	my1.g_h=parm->pb_h-2;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	vswr_mode(glb.hvdi,MD_TRANS);		/*	Mode transparent	*/

	trait=(uchar *)strchr((char *)user->spec,0x5B);
	if ( (trait!=NULL) && (trait!=(uchar *)user->spec) )
	{
		*trait=0;
		if (vect)
			vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
		else
			vqt_extent(glb.hvdi,(char *)user->spec,extent);
		*trait='[';
		trait++;
		tLarg=extent[2]-extent[6];
	}
	else
		trait=(uchar *)user->spec;
	if (vect)
		vqt_f_extent(glb.hvdi,(char *)trait,extent);
	else
		vqt_extent(glb.hvdi,(char *)trait,extent);
	tLarg+=extent[2]-extent[6];

	x=parm->pb_x;
	x+=(parm->pb_w-tLarg)/2;
	y=parm->pb_y;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2 ;
	y+=htext;

	trait=(uchar *)strchr((char *)user->spec,0x5B);
	if (trait!=NULL)
	{
		*trait=0;
		if (vect)
		{
			vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
			v_ftext(glb.hvdi,x,y,(char *)user->spec);
		}
		else
		{
			vqt_extent(glb.hvdi,(char *)user->spec,extent);
			v_gtext(glb.hvdi,x,y,(char *)user->spec);
		}
		*trait='[';
		trait++;
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			car[0]=*trait;
			car[1]=0;
			vst_effects(glb.hvdi,eff+TXT_UNDERLINED);
			if (vect)
			{
				v_ftext(glb.hvdi,x,y,(char *)car);
				vqt_f_extent(glb.hvdi,(char *)car,extent);
			}
			else
			{
				v_gtext(glb.hvdi,x,y,(char *)car);
				vqt_extent(glb.hvdi,(char *)car,extent);
			}
			vst_effects(glb.hvdi,eff);
			trait++;
		}
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			if (vect)
				v_ftext(glb.hvdi,x,y,(char *)trait);
			else
				v_gtext(glb.hvdi,x,y,(char *)trait);
		}
	}
	else
		if (vect)
			v_ftext(glb.hvdi,x,y,(char *)user->spec);
		else
			v_gtext(glb.hvdi,x,y,(char *)user->spec);

	vs_clip(glb.hvdi,FALSE,tab_clip);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
	if (glb.gdos)
		vst_font(glb.hvdi,tattr[0]);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	vsl_type(glb.hvdi,lattr[0]);
	vsl_color(glb.hvdi,lattr[1]);
	return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	G_BUTTON																							*/
/******************************************************************************/
int cdecl _drawButton(PARMBLK *parm)
{
	tLarg=0;
   vqt_attributes(glb.hvdi,tattr);
   vqf_attributes(glb.hvdi,fattr);
	state=parm->pb_tree[parm->pb_obj].ob_state;
	type=(parm->pb_tree[parm->pb_obj].ob_type)>>8;
	eff=TXT_NORMAL;
	if (state&STATE15) 	eff+=TXT_THICKENED;
	if (state&STATE14)	eff+=TXT_LIGHT;
	if (state&STATE13)	eff+=TXT_UNDERLINED;
	vst_effects(glb.hvdi,eff);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
	user=(UBLK *)(parm->pb_parm);

	if (type!=0)
		pnt=type;
	else
		pnt=10-2*glb.low;
	if (state&STATE10)
		ind=glb.opt.GDfnt;
	else if (state&STATE8)
		ind=glb.opt.GIfnt;
	else if (state&STATE11)
		ind=glb.opt.HIfnt;
	else if (state&STATE9)
		ind=1;
	else
		ind=glb.opt.Gfnt;
	if (glb.gdos)
		vst_font(glb.hvdi,font[ind].index);
	vect=font[ind].name[32];
	if (vect)
		vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
	else
		vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);

	tour=1;
	if (parm->pb_tree[parm->pb_obj].ob_flags&EXIT)		tour+=1;
	if (parm->pb_tree[parm->pb_obj].ob_flags&DEFAULT)	tour+=1;
	if (vect)
		vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
	else
		vqt_extent(glb.hvdi,(char *)user->spec,extent);
	tHaut=extent[7]-extent[1]+4-parm->pb_h;
	if (tHaut>0)
		tHaut/=2;
	else
		tHaut=0;
	parm->pb_y-=tHaut;
	parm->pb_h+=2*tHaut;

	my1.g_x=parm->pb_x-tour;
	my1.g_y=parm->pb_y-tour;
	my1.g_w=parm->pb_w+2*tour;
	my1.g_h=parm->pb_h+2*tour;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.hvdi,MD_REPLACE);		/*	Mode remplacement		*/
	vsf_perimeter(glb.hvdi,FALSE);		/*	Pas de p‚rimŠtre		*/
	vsf_interior(glb.hvdi,FIS_SOLID);	/*	Cadre plein				*/
	vsf_style(glb.hvdi,0);					/*	Cadre plein				*/
	vsf_color(glb.hvdi,BLACK);				/*	Couleur: Noir			*/
	v_bar(glb.hvdi,bar);						/*	Trac‚ du cadre noir	*/

	if (parm->pb_currstate&SELECTED)
		color=WHITE;							/*	Texte: Blanc			*/
	else
	{
		color=BLACK;							/*	Texte: Noir				*/
		bar[0]=parm->pb_x;
		bar[1]=parm->pb_y;
		bar[2]=bar[0]+parm->pb_w-1;
		bar[3]=bar[1]+parm->pb_h-1;
		vsf_color(glb.hvdi,WHITE);			/*	Couleur: Blanc			*/
		v_bar(glb.hvdi,bar);					/*	Trac‚ du cadre int.	*/
	}
	vst_color(glb.hvdi,color);
	vs_clip(glb.hvdi,FALSE,tab_clip);

	my1.g_x=parm->pb_x+1;
	my1.g_y=parm->pb_y+1;
	my1.g_w=parm->pb_w-2;
	my1.g_h=parm->pb_h-2;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	vswr_mode(glb.hvdi,MD_TRANS);		/*	Mode transparent	*/

	trait=(uchar *)strchr((char *)user->spec,0x5B);
	if ( (trait!=NULL) && (trait!=(uchar *)user->spec) )
	{
		*trait=0;
		if (vect)
			vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
		else
			vqt_extent(glb.hvdi,(char *)user->spec,extent);
		*trait='[';
		trait++;
		tLarg=extent[2]-extent[6];
	}
	else
		trait=(uchar *)user->spec;
	if (vect)
		vqt_f_extent(glb.hvdi,(char *)trait,extent);
	else
		vqt_extent(glb.hvdi,(char *)trait,extent);
	tLarg+=extent[2]-extent[6];

	x=parm->pb_x;
	x+=(parm->pb_w-tLarg)/2;
	y=parm->pb_y;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2 ;
	y+=htext;

	trait=(uchar *)strchr((char *)user->spec,0x5B);
	if (trait!=NULL)
	{
		*trait=0;
		if (vect)
		{
			vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
			v_ftext(glb.hvdi,x,y,(char *)user->spec);
		}
		else
		{
			vqt_extent(glb.hvdi,(char *)user->spec,extent);
			v_gtext(glb.hvdi,x,y,(char *)user->spec);
		}
		*trait='[';
		trait++;
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			car[0]=*trait;
			car[1]=0;
			vst_effects(glb.hvdi,eff+TXT_UNDERLINED);
			if (vect)
			{
				v_ftext(glb.hvdi,x,y,(char *)car);
				vqt_f_extent(glb.hvdi,(char *)car,extent);
			}
			else
			{
				v_gtext(glb.hvdi,x,y,(char *)car);
				vqt_extent(glb.hvdi,(char *)car,extent);
			}
			vst_effects(glb.hvdi,eff);
			trait++;
		}
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			if (vect)
				v_ftext(glb.hvdi,x,y,(char *)trait);
			else
				v_gtext(glb.hvdi,x,y,(char *)trait);
		}
	}
	else
		if (vect)
			v_ftext(glb.hvdi,x,y,(char *)user->spec);
		else
			v_gtext(glb.hvdi,x,y,(char *)user->spec);

	vs_clip(glb.hvdi,FALSE,tab_clip);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
	if (glb.gdos)
		vst_font(glb.hvdi,tattr[0]);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	G_STRING																							*/
/******************************************************************************/
int cdecl _drawString(PARMBLK *parm)
{
	tLarg=0;
   vqt_attributes(glb.hvdi,tattr);
   vqf_attributes(glb.hvdi,fattr);
	state=parm->pb_tree[parm->pb_obj].ob_state;
	type=(parm->pb_tree[parm->pb_obj].ob_type)>>8;
	eff=TXT_NORMAL;
	if (state&STATE15) 	eff+=TXT_THICKENED;
	if (state&STATE14)	eff+=TXT_LIGHT;
	if (state&STATE13)	eff+=TXT_UNDERLINED;
	vst_effects(glb.hvdi,eff);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
	user=(UBLK *)(parm->pb_parm);

	if (type!=0)
		pnt=type;
	else
		pnt=10-2*glb.low;
	if (state&STATE10)
		ind=glb.opt.GDfnt;
	else if (state&STATE8)
		ind=glb.opt.GIfnt;
	else if (state&STATE11)
		ind=glb.opt.HIfnt;
	else if (state&STATE9)
		ind=1;
	else
		ind=glb.opt.Gfnt;
	if (glb.gdos)
		vst_font(glb.hvdi,font[ind].index);
	vect=font[ind].name[32];
	if (vect)
		vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
	else
		vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);

	my1.g_x=parm->pb_x;
	my1.g_y=parm->pb_y;
	my1.g_w=parm->pb_w;
	my1.g_h=parm->pb_h;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.hvdi,MD_REPLACE);		/*	Mode remplacement		*/
	vsf_perimeter(glb.hvdi,FALSE);		/*	Pas de p‚rimŠtre		*/
	vsf_interior(glb.hvdi,FIS_SOLID);	/*	Cadre plein				*/
	vsf_style(glb.hvdi,0);					/*	Cadre plein				*/

	if (parm->pb_currstate&SELECTED)
	{
		if (parm->pb_tree[parm->pb_obj].ob_state&WHITEBAK)
			vsf_color(glb.hvdi,LBLACK);	/*	Couleur: Gris fonc‚	*/
		else
			vsf_color(glb.hvdi,BLACK);		/*	Couleur: Noir			*/
		color=WHITE;							/*	Texte: Blanc			*/
	}
	else
	{
		if (parm->pb_tree[parm->pb_obj].ob_state&WHITEBAK)
			vsf_color(glb.hvdi,LWHITE);	/*	Couleur: Gris clair	*/
		else
			vsf_color(glb.hvdi,WHITE);		/*	Couleur: Blanc			*/
		color=BLACK;							/*	Texte: Noir				*/
	}
	vst_color(glb.hvdi,color);
	v_bar(glb.hvdi,bar);						/*	Trac‚ du cadre noir	*/

	vswr_mode(glb.hvdi,MD_TRANS);			/*	Mode transparent		*/
	trait=(uchar *)strchr((char *)user->spec,0x5B);
	if ( (trait!=NULL) && (trait!=(uchar *)user->spec) )
	{
		*trait=0;
		if (vect)
			vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
		else
			vqt_extent(glb.hvdi,(char *)user->spec,extent);
		*trait='[';
		trait++;
		tLarg=extent[2]-extent[6];
	}
	else
		trait=(uchar *)user->spec;
	if (vect)
		vqt_f_extent(glb.hvdi,(char *)trait,extent);
	else
		vqt_extent(glb.hvdi,(char *)trait,extent);
	tLarg+=extent[2]-extent[6];

	x=parm->pb_x;
	y=parm->pb_y;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2 ;
	y+=htext;

	trait=(uchar *)strchr((char *)user->spec,0x5B);
	if (trait!=NULL)
	{
		*trait=0;
		if (vect)
		{
			vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
			v_ftext(glb.hvdi,x,y,(char *)user->spec);
		}
		else
		{
			vqt_extent(glb.hvdi,(char *)user->spec,extent);
			v_gtext(glb.hvdi,x,y,(char *)user->spec);
		}
		*trait='[';
		trait++;
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			car[0]=*trait;
			car[1]=0;
			vst_effects(glb.hvdi,eff+TXT_UNDERLINED);
			if (vect)
			{
				v_ftext(glb.hvdi,x,y,(char *)car);
				vqt_f_extent(glb.hvdi,(char *)car,extent);
			}
			else
			{
				v_gtext(glb.hvdi,x,y,(char *)car);
				vqt_extent(glb.hvdi,(char *)car,extent);
			}
			vst_effects(glb.hvdi,eff);
			trait++;
		}
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			if (vect)
				v_ftext(glb.hvdi,x,y,(char *)trait);
			else
				v_gtext(glb.hvdi,x,y,(char *)trait);
		}
	}
	else
		if (vect)
			v_ftext(glb.hvdi,x,y,(char *)user->spec);
		else
			v_gtext(glb.hvdi,x,y,(char *)user->spec);

	vs_clip(glb.hvdi,FALSE,tab_clip);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
	if (glb.gdos)
		vst_font(glb.hvdi,tattr[0]);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	G_LINE in menu																					*/
/******************************************************************************/
int cdecl _drawNiceLine(PARMBLK *parm)
{
   vqf_attributes(glb.hvdi,fattr);
	vql_attributes(glb.hvdi,lattr);
	my1.g_x=parm->pb_x;
	my1.g_y=parm->pb_y;
	my1.g_w=parm->pb_w;
	my1.g_h=parm->pb_h;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.hvdi,MD_REPLACE);		/*	Mode remplacement		*/
	vsf_perimeter(glb.hvdi,FALSE);		/*	Pas de p‚rimŠtre		*/
	vsf_interior(glb.hvdi,FIS_SOLID);	/*	Cadre plein				*/
	vsf_style(glb.hvdi,0);					/*	Cadre plein				*/

	if (parm->pb_currstate&SELECTED)
	{
		if (parm->pb_tree[parm->pb_obj].ob_state&WHITEBAK)
			vsf_color(glb.hvdi,LBLACK);	/*	Couleur: Gris fonc‚	*/
		else
			vsf_color(glb.hvdi,BLACK);		/*	Couleur: Noir			*/
		vsl_color(glb.hvdi,WHITE);
	}
	else
	{
		if (parm->pb_tree[parm->pb_obj].ob_state&WHITEBAK)
			vsf_color(glb.hvdi,LWHITE);	/*	Couleur: Gris clair	*/
		else
			vsf_color(glb.hvdi,WHITE);		/*	Couleur: Blanc			*/
		vsl_color(glb.hvdi,BLACK);
	}
	v_bar(glb.hvdi,bar);						/*	Trac‚ du cadre noir	*/

	vsl_type(glb.hvdi,USERLINE);
	vsl_width(glb.hvdi,1);
	vsl_udsty(glb.hvdi,(int)0x5555);
	x=parm->pb_x;
	y=parm->pb_y+parm->pb_h/2;
	bar[0]=x;
	bar[1]=y;
	bar[2]=x+parm->pb_w;
	bar[3]=y;
	v_pline(glb.hvdi,2,bar);
	bar[1]+=1;
	bar[3]+=1;
	vsl_udsty(glb.hvdi,(int)0xAAAA);
	v_pline(glb.hvdi,2,bar);

	vs_clip(glb.hvdi,FALSE,tab_clip);
	vsl_type(glb.hvdi,lattr[0]);
	vsl_color(glb.hvdi,lattr[1]);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	return parm->pb_currstate&~(SELECTED|DISABLED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	G_TEXT																							*/
/******************************************************************************/
int cdecl _drawText(PARMBLK *parm)
{
	TEDINFO		*ted;

	tLarg=0;
	my1.g_x=parm->pb_x;
	my1.g_y=parm->pb_y;
	my1.g_w=parm->pb_w;
	my1.g_h=parm->pb_h;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	if (_rcIntersect(&my1,&my2))
	{
		tab_clip[0]=my2.g_x;
		tab_clip[1]=my2.g_y;
		tab_clip[2]=tab_clip[0]+my2.g_w-1;
		tab_clip[3]=tab_clip[1]+my2.g_h-1;
		vs_clip(glb.hvdi,TRUE,tab_clip);

	   vqt_attributes(glb.hvdi,tattr);
	   vqf_attributes(glb.hvdi,fattr);
		state=parm->pb_tree[parm->pb_obj].ob_state;
		type=(parm->pb_tree[parm->pb_obj].ob_type)>>8;
		eff=TXT_NORMAL;
		if (state&STATE15) 	eff+=TXT_THICKENED;
		if (state&STATE14)	eff+=TXT_LIGHT;
		if (state&STATE13)	eff+=TXT_UNDERLINED;
		vst_effects(glb.hvdi,eff);
		vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
		user=(UBLK *)(parm->pb_parm);
		ted=(TEDINFO *)user->spec;
		if (ted!=NULL)
		{
			if (type!=0)
				pnt=type;
			else if (ted->te_font==3)
				pnt=10-2*glb.low;
			else
				pnt=8-glb.low;
			if (state&STATE10)
				ind=glb.opt.GDfnt;
			else if (state&STATE8)
				ind=glb.opt.GIfnt;
			else if (state&STATE11)
				ind=glb.opt.HIfnt;
			else if (state&STATE9)
				ind=1;
			else
				ind=glb.opt.Gfnt;
			if (glb.gdos)
				vst_font(glb.hvdi,font[ind].index);
			vect=font[ind].name[32];
			if (vect)
				vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
			else
				vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);

			vswr_mode(glb.hvdi,MD_REPLACE);
			if (ted->te_color&0x80)		/* Mode Opaque ? */
			{
				if (parm->pb_tree[parm->pb_obj].ob_state&WHITEBAK)
				{
					if (state&SELECTED)
						vsf_color(glb.hvdi,LBLACK);
					else
						vsf_color(glb.hvdi,LWHITE);
				}
				else
				{
					if (state&SELECTED)
						vsf_color(glb.hvdi,col[(ted->te_color)&0xF]);	/*	Couleur de fond		*/
					else
						vsf_color(glb.hvdi,(ted->te_color)&0xF);			/*	Couleur de fond		*/
				}
				vsf_interior(glb.hvdi,FIS_SOLID);	/*	Cadre plein				*/
				vsf_style(glb.hvdi,0);					/*	Pattern vide			*/
				vsf_perimeter(glb.hvdi,FALSE);		/*	Pas de P‚rimŠtre		*/
				bar[0]	=	parm->pb_x;
				bar[1]	=	parm->pb_y;
				bar[2]	=	parm->pb_x+parm->pb_w-1;
				bar[3]	=	parm->pb_y+parm->pb_h-1;
				v_bar(glb.hvdi,bar);						/*	Trac‚ du cadre			*/
			}

			if (state&SELECTED)
				color=col[((ted->te_color)&0xF00)>>8];
			else
				color=((ted->te_color)&0xF00)>>8;
			vst_color(glb.hvdi,color);
			vswr_mode(glb.hvdi,MD_TRANS);
			p=(uchar *)ted->te_ptext;
			trait=(uchar *)strchr(ted->te_ptext,0x5B);
			if ( (trait!=NULL) && (trait!=p) )
			{
				*trait=0;
				if (vect)
					vqt_f_extent(glb.hvdi,(char *)p,extent);
				else
					vqt_extent(glb.hvdi,(char *)p,extent);
				*trait='[';
				trait++;
				tLarg=extent[2]-extent[6];
			}
			else
				trait=(uchar *)ted->te_ptext;
			if (vect)
				vqt_f_extent(glb.hvdi,(char *)trait,extent);
			else
				vqt_extent(glb.hvdi,(char *)trait,extent);
			tLarg+=extent[2]-extent[6];

			x=parm->pb_x;
			y=parm->pb_y;
			y+=parm->pb_h/2;
			y-=(extent[7]-extent[1])/2 ;
			y+=htext;

			switch (ted->te_just)
			{
				case	1:		x+=(parm->pb_w-tLarg);		break;
				case	2:		x+=(parm->pb_w-tLarg)/2;	break;
			}

			trait=(uchar *)strchr(ted->te_ptext,0x5B);
			if (trait!=NULL)
			{
				*trait=0;
				if (vect)
				{
					vqt_f_extent(glb.hvdi,(char *)p,extent);
					v_ftext(glb.hvdi,x,y,(char *)p);
				}
				else
				{
					vqt_extent(glb.hvdi,(char *)p,extent);
					v_gtext(glb.hvdi,x,y,(char *)p);
				}
				*trait='[';
				trait++;
				if (*trait!=0)
				{
					x+=extent[2]-extent[0];
					car[0]=*trait;
					car[1]=0;
					vst_color(glb.hvdi,RED);
					if (vect)
					{
						v_ftext(glb.hvdi,x,y,(char *)car);
						vqt_f_extent(glb.hvdi,(char *)car,extent);
					}
					else
					{
						v_gtext(glb.hvdi,x,y,(char *)car);
						vqt_extent(glb.hvdi,(char *)car,extent);
					}
					vst_color(glb.hvdi,color);
					trait++;
				}
				if (*trait!=0)
				{
					x+=extent[2]-extent[0];
					if (vect)
						v_ftext(glb.hvdi,x,y,(char *)trait);
					else
						v_gtext(glb.hvdi,x,y,(char *)trait);
				}
			}
			else
			if (vect)
				v_ftext(glb.hvdi,x,y,ted->te_ptext);
			else
				v_gtext(glb.hvdi,x,y,ted->te_ptext);
		}
		vst_effects(glb.hvdi,TXT_NORMAL);
		vswr_mode(glb.hvdi,tattr[5]);
  		vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
		if (glb.gdos)
			vst_font(glb.hvdi,tattr[0]);
		vst_color(glb.hvdi,tattr[1]);
		vsf_interior(glb.hvdi,fattr[2]);
		vsf_style(glb.hvdi,fattr[0]);
		vsf_perimeter(glb.hvdi,fattr[4]);
		vs_clip(glb.hvdi,FALSE,tab_clip);
	}
	return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	G_FTEXT																							*/
/******************************************************************************/
int cdecl _drawFText(PARMBLK *parm)
{
	TEDINFO		*ted;

	tLarg=0;
	my1.g_x=parm->pb_x;
	my1.g_y=parm->pb_y;
	my1.g_w=parm->pb_w;
	my1.g_h=parm->pb_h;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	if (_rcIntersect(&my1,&my2))
	{
		tab_clip[0]=my2.g_x;
		tab_clip[1]=my2.g_y;
		tab_clip[2]=tab_clip[0]+my2.g_w-1;
		tab_clip[3]=tab_clip[1]+my2.g_h-1;
		vs_clip(glb.hvdi,TRUE,tab_clip);

	   vqt_attributes(glb.hvdi,tattr);
	   vqf_attributes(glb.hvdi,fattr);
		state=parm->pb_tree[parm->pb_obj].ob_state;
		type=(parm->pb_tree[parm->pb_obj].ob_type)>>8;
		vst_effects(glb.hvdi,TXT_NORMAL);
		vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
		user=(UBLK *)(parm->pb_parm);
		ted=(TEDINFO *)user->spec;
		if (ted!=NULL)
		{
			if (type!=0)
				pnt=type;
			else if (ted->te_font==3)
				pnt=10-2*glb.low;
			else
				pnt=8-glb.low;
			if (state&STATE10)
				ind=glb.opt.GDfnt;
			else if (state&STATE8)
				ind=glb.opt.GIfnt;
			else if (state&STATE11)
				ind=glb.opt.HIfnt;
			else if (state&STATE9)
				ind=1;
			else
				ind=glb.opt.Gfnt;
			if (glb.gdos)
				vst_font(glb.hvdi,font[ind].index);
			vect=font[ind].name[32];
			if (vect)
				vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
			else
				vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);

			vswr_mode(glb.hvdi,MD_REPLACE);
			if (parm->pb_tree[parm->pb_obj].ob_state&WHITEBAK)
			{
				if (state&SELECTED)
					vsf_color(glb.hvdi,LBLACK);
				else
					vsf_color(glb.hvdi,LWHITE);
			}
			else
			{
				if (state&SELECTED)
					vsf_color(glb.hvdi,col[(ted->te_color)&0xF]);	/*	Couleur de fond		*/
				else
					vsf_color(glb.hvdi,(ted->te_color)&0xF);			/*	Couleur de fond		*/
			}
			vsf_interior(glb.hvdi,FIS_SOLID);							/*	Cadre plein				*/
			vsf_style(glb.hvdi,0);											/*	Pattern vide			*/
			vsf_perimeter(glb.hvdi,FALSE);								/*	Pas de P‚rimŠtre		*/
			bar[0]	=	parm->pb_x;
			bar[1]	=	parm->pb_y;
			bar[2]	=	parm->pb_x+parm->pb_w-1;
			bar[3]	=	parm->pb_y+parm->pb_h-1;
			v_bar(glb.hvdi,bar);												/*	Trac‚ du cadre			*/

			if (state&SELECTED)
				color=col[((ted->te_color)&0xF00)>>8];
			else
				color=((ted->te_color)&0xF00)>>8;
			vst_color(glb.hvdi,color);
			vswr_mode(glb.hvdi,MD_TRANS);

			if (vect)
				vqt_f_extent(glb.hvdi,ted->te_ptext,extent);
			else
				vqt_extent(glb.hvdi,ted->te_ptext,extent);

			x=parm->pb_x;
			y=parm->pb_y;
			y+=parm->pb_h/2;
			y-=(extent[7]-extent[1])/2 ;
			y+=htext;

			p=(uchar *)ted->te_ptmplt;
			trait=(uchar *)ted->te_ptext;
			car[1]=0;
			while (*p!=0)
			{
				if (*p=='_')
				{
					if (*trait==0)
						car[0]='_';
					else if (*trait<=' ')
						car[0]=' ';
					else
						car[0]=*trait;
					if (*trait!=0)
						trait++;
				}
				else
					car[0]=*p;
				if (vect)
				{
					vqt_f_extent(glb.hvdi,(char *)car,extent);
					v_ftext(glb.hvdi,x,y,(char *)car);
				}
				else
				{
					vqt_extent(glb.hvdi,(char *)car,extent);
					v_gtext(glb.hvdi,x,y,(char *)car);
				}
				x+=extent[2]-extent[6];
				p++;
			}
		}
		vswr_mode(glb.hvdi,tattr[5]);
  		vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
		if (glb.gdos)
			vst_font(glb.hvdi,tattr[0]);
		vst_color(glb.hvdi,tattr[1]);
		vsf_interior(glb.hvdi,fattr[2]);
		vsf_style(glb.hvdi,fattr[0]);
		vsf_perimeter(glb.hvdi,fattr[4]);
		vs_clip(glb.hvdi,FALSE,tab_clip);
	}
	return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	Cross & Radio G_BUTTON																		*/
/******************************************************************************/
int cdecl _drawCroixCarre(PARMBLK *parm)
{
	tLarg=0;
	pb.pb_tree			=	__rsc.head.trindex[FUSER];
	if ( ((parm->pb_tree[parm->pb_obj].ob_type)&0xFF00) == USD_CARRE )
		pb.pb_obj			=	FUSDCAR+glb.low;
	else
		pb.pb_obj			=	FUSDCIR+glb.low;
	pb.pb_prevstate	=	pb.pb_tree[pb.pb_obj].ob_state;
	pb.pb_currstate	=	parm->pb_tree[parm->pb_obj].ob_state;
	pb.pb_w				=	pb.pb_tree[pb.pb_obj].ob_width;
	pb.pb_h				=	pb.pb_tree[pb.pb_obj].ob_height;
	pb.pb_x				=	parm->pb_x;
	pb.pb_y				=	parm->pb_y+(parm->pb_h-pb.pb_h)/2;
	pb.pb_xc				=	parm->pb_xc;
	pb.pb_yc				=	parm->pb_yc;
	pb.pb_wc				=	parm->pb_wc;
	pb.pb_hc				=	parm->pb_hc;
	pb.pb_parm			=	pb.pb_tree[pb.pb_obj].ob_spec.userblk->ub_parm;

   vqt_attributes(glb.hvdi,tattr);
   vqf_attributes(glb.hvdi,fattr);
	eff=TXT_NORMAL;
	vst_effects(glb.hvdi,eff);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
	user=(UBLK *)(parm->pb_parm);
	state=parm->pb_tree[parm->pb_obj].ob_state;

	pnt=10-2*glb.low;
	if (state&STATE10)
		ind=glb.opt.GDfnt;
	else if (state&STATE8)
		ind=glb.opt.GIfnt;
	else if (state&STATE11)
		ind=glb.opt.HIfnt;
	else if (state&STATE9)
		ind=1;
	else
		ind=glb.opt.Gfnt;

	if (glb.gdos)
		vst_font(glb.hvdi,font[ind].index);
	vect=font[ind].name[32];
	if (vect)
		vst_arbpt(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);
	else
		vst_point(glb.hvdi,pnt,&dummy,&htext,&dummy,&dummy);

	my1.g_x=parm->pb_x;
	my1.g_y=parm->pb_y;
	my1.g_w=parm->pb_w;
	my1.g_h=parm->pb_h;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.hvdi,MD_REPLACE);							/*	Mode remplacement		*/
	vsf_perimeter(glb.hvdi,FALSE);							/*	Pas de p‚rimŠtre		*/
	vsf_interior(glb.hvdi,FIS_SOLID);						/*	Cadre plein				*/
	vsf_style(glb.hvdi,0);										/*	Cadre plein				*/

	if (parm->pb_tree[parm->pb_obj].ob_state&DRAW3D)
		vsf_color(glb.hvdi,LWHITE);							/*	Couleur: Gris clair	*/
	else
		vsf_color(glb.hvdi,WHITE);								/*	Couleur: Blanc			*/
	color=BLACK;													/*	Texte: Noir				*/
	vst_color(glb.hvdi,color);
	v_bar(glb.hvdi,bar);											/*	Trac‚ du cadre noir	*/

	vswr_mode(glb.hvdi,MD_TRANS);								/*	Mode transparent		*/
	trait=(uchar *)strchr((char *)user->spec,0x5B);
	if ( (trait!=NULL) && (trait!=(uchar *)user->spec) )
	{
		*trait=0;
		if (vect)
			vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
		else
			vqt_extent(glb.hvdi,(char *)user->spec,extent);
		*trait='[';
		trait++;
		tLarg=extent[2]-extent[6];
	}
	else
		trait=(uchar *)user->spec;
	if (vect)
		vqt_f_extent(glb.hvdi,(char *)trait,extent);
	else
		vqt_extent(glb.hvdi,(char *)trait,extent);
	tLarg+=extent[2]-extent[6];

	x=parm->pb_x+1.5*pb.pb_w;
	y=parm->pb_y;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2 ;
	y+=htext;

	trait=(uchar *)strchr((char *)user->spec,0x5B);
	if (trait!=NULL)
	{
		*trait=0;
		if (vect)
		{
			vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
			v_ftext(glb.hvdi,x,y,(char *)user->spec);
		}
		else
		{
			vqt_extent(glb.hvdi,(char *)user->spec,extent);
			v_gtext(glb.hvdi,x,y,(char *)user->spec);
		}
		*trait='[';
		trait++;
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			car[0]=*trait;
			car[1]=0;
			vst_effects(glb.hvdi,eff+TXT_UNDERLINED);
			if (vect)
			{
				v_ftext(glb.hvdi,x,y,(char *)car);
				vqt_f_extent(glb.hvdi,(char *)car,extent);
			}
			else
			{
				v_gtext(glb.hvdi,x,y,(char *)car);
				vqt_extent(glb.hvdi,(char *)car,extent);
			}
			vst_effects(glb.hvdi,eff);
			trait++;
		}
		if (*trait!=0)
		{
			x+=extent[2]-extent[0];
			if (vect)
				v_ftext(glb.hvdi,x,y,(char *)trait);
			else
				v_gtext(glb.hvdi,x,y,(char *)trait);
		}
	}
	else
		if (vect)
			v_ftext(glb.hvdi,x,y,(char *)user->spec);
		else
			v_gtext(glb.hvdi,x,y,(char *)user->spec);

	vs_clip(glb.hvdi,FALSE,tab_clip);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
	if (glb.gdos)
		vst_font(glb.hvdi,tattr[0]);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	_drawCicon(&pb);
	return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}


/******************************************************************************/
/*	PopUp G_BUTTON																					*/
/******************************************************************************/
int cdecl _drawPopUp(PARMBLK *parm)
{
	tLarg=0;
	pb.pb_tree			=	__rsc.head.trindex[FUSER];
	pb.pb_obj			=	FUSDPOP+glb.low;
	pb.pb_prevstate	=	pb.pb_tree[pb.pb_obj].ob_state;
	pb.pb_currstate	=	parm->pb_tree[parm->pb_obj].ob_state;
	pb.pb_w				=	pb.pb_tree[pb.pb_obj].ob_width;
	pb.pb_h				=	pb.pb_tree[pb.pb_obj].ob_height;
	pb.pb_x				=	parm->pb_x+parm->pb_w-pb.pb_w;
	pb.pb_y				=	parm->pb_y+(parm->pb_h-pb.pb_h)/2;
	pb.pb_xc				=	parm->pb_xc;
	pb.pb_yc				=	parm->pb_yc;
	pb.pb_wc				=	parm->pb_wc;
	pb.pb_hc				=	parm->pb_hc;
	pb.pb_parm			=	pb.pb_tree[pb.pb_obj].ob_spec.userblk->ub_parm;

   vqt_attributes(glb.hvdi,tattr);
   vqf_attributes(glb.hvdi,fattr);
   vql_attributes(glb.hvdi,lattr);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_BASE,&dummy,&dummy);
	user=(UBLK *)(parm->pb_parm);
	state=parm->pb_tree[parm->pb_obj].ob_state;

	pnt=10-2*glb.low;
	if (state&STATE10)
		ind=glb.opt.GDfnt;
	else if (state&STATE8)
		ind=glb.opt.GIfnt;
	else if (state&STATE11)
		ind=glb.opt.HIfnt;
	else if (state&STATE9)
		ind=1;
	else
		ind=glb.opt.Gfnt;
	if (glb.gdos)
		vst_font(glb.hvdi,font[ind].index);
	vect=font[ind].name[32];
	if (vect)
	{
		vst_arbpt(glb.hvdi,10-2*glb.low,&dummy,&htext,&dummy,&dummy);
		vqt_f_extent(glb.hvdi,(char *)user->spec,extent);
	}
	else
	{
		vst_point(glb.hvdi,10-2*glb.low,&dummy,&htext,&dummy,&dummy);
		vqt_extent(glb.hvdi,(char *)user->spec,extent);
	}
	tHaut=extent[7]-extent[1]+4-parm->pb_h;
	if (tHaut>0)
		tHaut/=2;
	else
		tHaut=0;
	parm->pb_y-=tHaut;
	parm->pb_h+=2*tHaut;

	my1.g_x=parm->pb_x;
	my1.g_y=parm->pb_y;
	my1.g_w=parm->pb_w;
	my1.g_h=parm->pb_h;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	pxy[0]=my1.g_x;
	pxy[1]=my1.g_y;
	pxy[2]=pxy[0]+my1.g_w-1;
	pxy[3]=pxy[1]+my1.g_h-1;

	vswr_mode(glb.hvdi,MD_REPLACE);			/*	Mode remplacement		*/
	vsf_perimeter(glb.hvdi,TRUE);				/*	P‚rimŠtre				*/
	vsf_interior(glb.hvdi,FIS_SOLID);		/*	Cadre plein				*/
	if ((parm->pb_tree[parm->pb_obj].ob_state)&DRAW3D)
		vsf_color(glb.hvdi,LWHITE);			/*	Couleur: Gris			*/
	else
		vsf_color(glb.hvdi,WHITE);				/*	Couleur: Blanc			*/
	v_bar(glb.hvdi,pxy);							/*	Trac‚ du cadre			*/

	pxy[0]=my1.g_x;
	pxy[1]=my1.g_y+my1.g_h-3;
	pxy[2]=pxy[0];
	pxy[3]=my1.g_y;
	pxy[4]=my1.g_x+my1.g_w-3;
	pxy[5]=pxy[3];
	vsl_type(glb.hvdi,SOLID);
	vsl_width(glb.hvdi,1);
	if ((parm->pb_tree[parm->pb_obj].ob_state)&DRAW3D)
		vsl_color(glb.hvdi,WHITE);				/*	Couleur: Blanc			*/
	else
		vsl_color(glb.hvdi,BLACK);				/*	Couleur: Noir			*/
	v_pline(glb.hvdi,3,pxy);					/*	Ligne						*/

	pxy[0]=my1.g_x+1;
	pxy[1]=my1.g_y+my1.g_h-2;
	pxy[2]=my1.g_x+my1.g_w-2;
	pxy[3]=pxy[1];
	pxy[4]=pxy[2];
	pxy[5]=my1.g_y+1;
	if ((parm->pb_tree[parm->pb_obj].ob_state)&DRAW3D)
		vsl_color(glb.hvdi,LBLACK);			/*	Couleur: Gris fonc‚	*/
	else
		vsl_color(glb.hvdi,BLACK);				/*	Couleur: Noir			*/
	v_pline(glb.hvdi,3,pxy);					/*	Ligne						*/

	pxy[0]+=1;
	pxy[1]+=1;
	pxy[2]+=1;
	pxy[3]+=1;
	pxy[4]+=1;
	pxy[5]+=1;
	vsl_color(glb.hvdi,BLACK);					/*	Couleur: Noir			*/
	v_pline(glb.hvdi,3,pxy);					/*	Ligne						*/
	vs_clip(glb.hvdi,FALSE,tab_clip);

	my1.g_x=parm->pb_x+2;
	my1.g_y=parm->pb_y+1;
	my1.g_w=parm->pb_w-2-pb.pb_w;
	my1.g_h=parm->pb_h-3;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.hvdi,TRUE,tab_clip);
	vswr_mode(glb.hvdi,MD_TRANS);				/*	Mode transparent		*/
	p=(uchar *)user->spec;
	while (*p==32)
		p++;
	if (vect)
		vqt_f_extent(glb.hvdi,(char *)p,extent);
	else
		vqt_extent(glb.hvdi,(char *)p,extent);
	tLarg+=extent[2]-extent[6];

	y=parm->pb_y-1;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2 ;
	y+=htext;
	for (i=0;i<2;i++)
	{
		if (i)
			vst_color(glb.hvdi,BLACK);
		else
			vst_color(glb.hvdi,WHITE);
		x=parm->pb_x+pb.pb_w/2+i;
		y+=i;

		if (vect)
			v_ftext(glb.hvdi,x,y,(char *)p);
		else
			v_gtext(glb.hvdi,x,y,(char *)p);
	}
	vs_clip(glb.hvdi,FALSE,tab_clip);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment (glb.hvdi,tattr[3],tattr[4],&dummy,&dummy);
	if (glb.gdos)
		vst_font(glb.hvdi,tattr[0]);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	vsl_type(glb.hvdi,lattr[0]);
	vsl_color(glb.hvdi,lattr[1]);
	_drawCicon(&pb);
	return parm->pb_currstate&~(SELECTED|WHITEBAK|DRAW3D);
}
