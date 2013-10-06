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
	VARIABLES
*******************************************************************************/
static	int		textcol,backcol;
static	int		dummy,flags,state,tour,tLarg;
static	int		lattr[6],fattr[6],tattr[10],extent[8];
static	int		tab_clip[4],bar[4],pxy[12];
static	int		x,y,htext;
static	char		*p;
static	uchar		car[2],*trait;
static	UBLK		*user;
static	GRECT		my1,my2;
static	PARMBLK	pb;


/*******************************************************************************
	G_BUTTON
*******************************************************************************/
int cdecl _drawButton(PARMBLK *parm)
{
   vqt_attributes(glb.vdi.ha,tattr);
   vqf_attributes(glb.vdi.ha,fattr);
	flags=parm->pb_tree[parm->pb_obj].ob_flags;
	state=parm->pb_tree[parm->pb_obj].ob_state;

	vst_effects(glb.vdi.ha,TXT_NORMAL);
	vst_alignment(glb.vdi.ha,ALI_LEFT,ALI_BASE,&dummy,&dummy);
	user=(UBLK *)(parm->pb_parm);

	vst_point(glb.vdi.ha,10-glb.vdi.low,&dummy,&htext,&dummy,&dummy);

	tour=1;
	if (flags & EXIT)
		tour+=1;
	if (flags & DEFAULT)
		tour+=1;

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
	vs_clip(glb.vdi.ha,TRUE,tab_clip);

	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.vdi.ha,MD_REPLACE);
	vsf_perimeter(glb.vdi.ha,FALSE);
	vsf_interior(glb.vdi.ha,FIS_SOLID);
	vsf_style(glb.vdi.ha,0);
	vsf_color(glb.vdi.ha,BLACK);

	/****************************************************************************
		Cadre Noir (attributs EXIT/DEFAUT/SELECTABLE)
	****************************************************************************/
	v_bar(glb.vdi.ha,bar);

	if (flags&FL3DIND && flags&FL3DACT)
	{
		backcol=LWHITE;
		textcol=BLACK;
	}
	else if (flags&FL3DIND)
	{
		if (state&SELECTED)
		{
			backcol=LBLACK;
			textcol=WHITE;
		}
		else
		{
			backcol=LWHITE;
			textcol=BLACK;
		}
	}
	else
	{
		if (state&SELECTED)
		{
			backcol=BLACK;
			textcol=WHITE;
		}
		else
		{
			backcol=WHITE;
			textcol=BLACK;
		}
	}
	if (backcol==LWHITE && glb.vdi.extnd[4]<4)
		backcol=WHITE;
	if (backcol!=BLACK)
	{
		bar[0]=parm->pb_x;
		bar[1]=parm->pb_y;
		bar[2]=bar[0]+parm->pb_w-1;
		bar[3]=bar[1]+parm->pb_h-1;
		vsf_color(glb.vdi.ha,backcol);
		/*************************************************************************
			Cadre Int‚rieur Blanc/Noir/Gris suivant s‚lection
		*************************************************************************/
		v_bar(glb.vdi.ha,bar);
	}
	vst_color(glb.vdi.ha,textcol);
	vs_clip(glb.vdi.ha,FALSE,tab_clip);

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
	vs_clip(glb.vdi.ha,TRUE,tab_clip);
	vswr_mode(glb.vdi.ha,MD_TRANS);

	tLarg=0;
	trait=(uchar *)strchr((char *)user->spec,'[');
	if (trait!=NULL)
	{
		if (trait!=(uchar *)user->spec)
		{
			*trait=0;
			vst_effects(glb.vdi.ha,TXT_UNDERLINED);
			vqt_extent(glb.vdi.ha,(char *)user->spec,extent);
			vst_effects(glb.vdi.ha,TXT_NORMAL);
			*trait='[';
			tLarg=extent[2]-extent[6];
		}
		trait++;
	}
	else
		trait=(uchar *)user->spec;
	vqt_extent(glb.vdi.ha,(char *)trait,extent);
	tLarg+=extent[2]-extent[6];

	x=parm->pb_x;
	x+=(parm->pb_w-tLarg)/2;
	y=parm->pb_y;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2;
	y+=htext;
	/****************************************************************************
		Si bouton 3D alors on d‚cale le texte
	****************************************************************************/
	if (flags&FL3DIND && flags&FL3DACT && state&SELECTED)
	{
		x+=1;
		y+=1;
	}

	trait=(uchar *)strchr((char *)user->spec,'[');
	if (trait!=NULL)
	{
		if (trait!=(uchar *)user->spec)
		{
			*trait=0;
			vqt_extent(glb.vdi.ha,(char *)user->spec,extent);
			v_gtext(glb.vdi.ha,x,y,(char *)user->spec);
			*trait='[';
			x+=extent[2]-extent[0];
		}
		trait++;
		if (*trait!=0)
		{
			car[0]=*trait;
			car[1]=0;
			vst_effects(glb.vdi.ha,TXT_UNDERLINED);
			v_gtext(glb.vdi.ha,x,y,(char *)car);
			vqt_extent(glb.vdi.ha,(char *)car,extent);
			vst_effects(glb.vdi.ha,TXT_NORMAL);
			trait++;
			x+=extent[2]-extent[0];
		}
		if (*trait!=0)
			v_gtext(glb.vdi.ha,x,y,(char *)trait);
	}
	else
		v_gtext(glb.vdi.ha,x,y,(char *)user->spec);

	vs_clip(glb.vdi.ha,FALSE,tab_clip);
	vst_effects(glb.vdi.ha,TXT_NORMAL);
	vst_alignment (glb.vdi.ha,tattr[3],tattr[4],&dummy,&dummy);
	vsf_interior(glb.vdi.ha,fattr[2]);
	vsf_style(glb.vdi.ha,fattr[0]);
	vsf_perimeter(glb.vdi.ha,fattr[4]);
	/****************************************************************************
		Si le bouton est en relief alors il faut demander … l'AES de dessiner
		l'attribut SELECTED pour qu'il inverse le cadre fin gris/noir.
		Par contre si le bouton n'est pas en relief, il ne faut surtout pas
		demander … l'AES de dessiner cet attribut sinon; lorsque l'objet est
		s‚lectionn‚ (donc noir), l'AES le recouvre en blanc !!
	****************************************************************************/
	if (flags&FL3DIND && flags&FL3DACT || flags&FL3DIND)
		return parm->pb_currstate;
	else
		return parm->pb_currstate&~SELECTED;
}


/*******************************************************************************
	G_LINE in popup menu
*******************************************************************************/
int cdecl _drawNiceLine(PARMBLK *parm)
{
   vqf_attributes(glb.vdi.ha,fattr);
	vql_attributes(glb.vdi.ha,lattr);
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
	vs_clip(glb.vdi.ha,TRUE,tab_clip);
	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.vdi.ha,MD_REPLACE);
	vsf_perimeter(glb.vdi.ha,FALSE);
	vsf_interior(glb.vdi.ha,FIS_SOLID);
	vsf_style(glb.vdi.ha,0);
	vsf_color(glb.vdi.ha,WHITE);
	v_bar(glb.vdi.ha,bar);

	vsl_type(glb.vdi.ha,USERLINE);
	vsl_width(glb.vdi.ha,1);
	vsl_udsty(glb.vdi.ha,(int)0x5555);
	x=parm->pb_x;
	y=parm->pb_y+parm->pb_h/2;
	bar[0]=x;
	bar[1]=y;
	bar[2]=x+parm->pb_w;
	bar[3]=y;
	v_pline(glb.vdi.ha,2,bar);
	bar[1]+=1;
	bar[3]+=1;
	vsl_udsty(glb.vdi.ha,(int)0xAAAA);
	v_pline(glb.vdi.ha,2,bar);

	vs_clip(glb.vdi.ha,FALSE,tab_clip);
	vsl_type(glb.vdi.ha,lattr[0]);
	vsl_color(glb.vdi.ha,lattr[1]);
	vsf_interior(glb.vdi.ha,fattr[2]);
	vsf_style(glb.vdi.ha,fattr[0]);
	vsf_perimeter(glb.vdi.ha,fattr[4]);
	return parm->pb_currstate&~DISABLED;
}


/*******************************************************************************
	Cross & Radio G_BUTTON
*******************************************************************************/
int cdecl _drawCroixCarre(PARMBLK *parm)
{
	pb.pb_tree			=	glb.rsc.head.trindex[FUSER];
	if (((parm->pb_tree[parm->pb_obj].ob_type)&0xFF00)==USD_CROSS)
		pb.pb_obj		=	FUSDCAR+glb.vdi.low;
	else if (((parm->pb_tree[parm->pb_obj].ob_type)&0xFF00)==USD_ROUND)
		pb.pb_obj		=	FUSDCIR+glb.vdi.low;
	else
		pb.pb_obj		=	FUSDLAR+glb.vdi.low;
	pb.pb_prevstate	=	pb.pb_tree[pb.pb_obj].ob_state;
	if (((parm->pb_tree[parm->pb_obj].ob_type)&0xFF00)==USD_NUM)
		pb.pb_currstate=	pb.pb_tree[pb.pb_obj].ob_state;
	else
		pb.pb_currstate=	parm->pb_tree[parm->pb_obj].ob_state;
	pb.pb_w				=	pb.pb_tree[pb.pb_obj].ob_width;
	pb.pb_h				=	pb.pb_tree[pb.pb_obj].ob_height;
	pb.pb_x				=	parm->pb_x;
	pb.pb_y				=	parm->pb_y+(parm->pb_h-pb.pb_h)/2;
	pb.pb_xc				=	parm->pb_xc;
	pb.pb_yc				=	parm->pb_yc;
	pb.pb_wc				=	parm->pb_wc;
	pb.pb_hc				=	parm->pb_hc;
	pb.pb_parm			=	pb.pb_tree[pb.pb_obj].ob_spec.userblk->ub_parm;

   vqt_attributes(glb.vdi.ha,tattr);
   vqf_attributes(glb.vdi.ha,fattr);
	flags=parm->pb_tree[parm->pb_obj].ob_flags;
	state=parm->pb_tree[parm->pb_obj].ob_state;

	vst_effects(glb.vdi.ha,TXT_NORMAL);
	vst_alignment(glb.vdi.ha,ALI_LEFT,ALI_BASE,&dummy,&dummy);
	user=(UBLK *)(parm->pb_parm);

	vst_point(glb.vdi.ha,10-glb.vdi.low,&dummy,&htext,&dummy,&dummy);

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
	vs_clip(glb.vdi.ha,TRUE,tab_clip);

	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.vdi.ha,MD_REPLACE);
	vsf_perimeter(glb.vdi.ha,FALSE);
	vsf_interior(glb.vdi.ha,FIS_SOLID);
	vsf_style(glb.vdi.ha,0);

	if (flags&FL3DACT)
		backcol=LWHITE;
	else
		backcol=WHITE;
	textcol=BLACK;
	if (backcol==LWHITE && glb.vdi.extnd[4]<4)
		backcol=WHITE;
	bar[0]=parm->pb_x;
	bar[1]=parm->pb_y;
	bar[2]=bar[0]+parm->pb_w-1;
	bar[3]=bar[1]+parm->pb_h-1;
	vsf_color(glb.vdi.ha,backcol);
	/****************************************************************************
		Fond Blanc/Gris suivant r‚solution et 3D
	****************************************************************************/
	v_bar(glb.vdi.ha,bar);
	vst_color(glb.vdi.ha,textcol);
	vs_clip(glb.vdi.ha,FALSE,tab_clip);

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
	vs_clip(glb.vdi.ha,TRUE,tab_clip);
	vswr_mode(glb.vdi.ha,MD_TRANS);

	tLarg=0;
	trait=(uchar *)strchr((char *)user->spec,'[');
	if (trait!=NULL)
	{
		if (trait!=(uchar *)user->spec)
		{
			*trait=0;
			vst_effects(glb.vdi.ha,TXT_UNDERLINED);
			vqt_extent(glb.vdi.ha,(char *)user->spec,extent);
			vst_effects(glb.vdi.ha,TXT_NORMAL);
			*trait='[';
			tLarg=extent[2]-extent[6];
		}
		trait++;
	}
	else
		trait=(uchar *)user->spec;
	vqt_extent(glb.vdi.ha,(char *)trait,extent);
	tLarg+=extent[2]-extent[6];

	if (((parm->pb_tree[parm->pb_obj].ob_type)&0xFF00)==USD_NUM)
	{
		vst_alignment(glb.vdi.ha,ALI_CENTER,ALI_BASE,&dummy,&dummy);
		x=parm->pb_x+parm->pb_w/2;
	}
	else
	{
		vst_alignment(glb.vdi.ha,ALI_LEFT,ALI_BASE,&dummy,&dummy);
		x=parm->pb_x+1.5*pb.pb_w;
	}
	y=parm->pb_y;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2;
	y+=htext;

	trait=(uchar *)strchr((char *)user->spec,'[');
	if (trait!=NULL)
	{
		if (trait!=(uchar *)user->spec)
		{
			*trait=0;
			vqt_extent(glb.vdi.ha,(char *)user->spec,extent);
			v_gtext(glb.vdi.ha,x,y,(char *)user->spec);
			*trait='[';
			x+=extent[2]-extent[0];
		}
		trait++;
		if (*trait!=0)
		{
			car[0]=*trait;
			car[1]=0;
			vst_effects(glb.vdi.ha,TXT_UNDERLINED);
			v_gtext(glb.vdi.ha,x,y,(char *)car);
			vqt_extent(glb.vdi.ha,(char *)car,extent);
			vst_effects(glb.vdi.ha,TXT_NORMAL);
			trait++;
			x+=extent[2]-extent[0];
		}
		if (*trait!=0)
			v_gtext(glb.vdi.ha,x,y,(char *)trait);
	}
	else
		v_gtext(glb.vdi.ha,x,y,(char *)user->spec);

	vs_clip(glb.vdi.ha,FALSE,tab_clip);
	vst_effects(glb.vdi.ha,TXT_NORMAL);
	vst_alignment (glb.vdi.ha,tattr[3],tattr[4],&dummy,&dummy);
	vsf_interior(glb.vdi.ha,fattr[2]);
	vsf_style(glb.vdi.ha,fattr[0]);
	vsf_perimeter(glb.vdi.ha,fattr[4]);

	_drawCicon(&pb);
	if (((parm->pb_tree[parm->pb_obj].ob_type)&0xFF00)==USD_NUM)
	{
		pb.pb_tree		=	glb.rsc.head.trindex[FUSER];
		pb.pb_obj		=	FUSDRAR+glb.vdi.low;
		pb.pb_prevstate=	pb.pb_tree[pb.pb_obj].ob_state;
		pb.pb_currstate=	pb.pb_tree[pb.pb_obj].ob_state;
		pb.pb_w			=	pb.pb_tree[pb.pb_obj].ob_width;
		pb.pb_h			=	pb.pb_tree[pb.pb_obj].ob_height;
		pb.pb_x			=	parm->pb_x+parm->pb_w-pb.pb_w;
		pb.pb_y			=	parm->pb_y+(parm->pb_h-pb.pb_h)/2;
		pb.pb_xc			=	parm->pb_xc;
		pb.pb_yc			=	parm->pb_yc;
		pb.pb_wc			=	parm->pb_wc;
		pb.pb_hc			=	parm->pb_hc;
		pb.pb_parm		=	pb.pb_tree[pb.pb_obj].ob_spec.userblk->ub_parm;
		_drawCicon(&pb);
	}

	/****************************************************************************
		Si le bouton est en relief alors il faut demander … l'AES de dessiner
		l'attribut SELECTED pour qu'il inverse le cadre fin gris/noir.
		Par contre si le bouton n'est pas en relief, il ne faut surtout pas
		demander … l'AES de dessiner cet attribut sinon; lorsque l'objet est
		s‚lectionn‚ (donc noir), l'AES le recouvre en blanc !!
	****************************************************************************/
	return parm->pb_currstate&~SELECTED;
}


/*******************************************************************************
	PopUp G_BUTTON
*******************************************************************************/
int cdecl _drawPopUp(PARMBLK *parm)
{
	pb.pb_tree			=	glb.rsc.head.trindex[FUSER];
	pb.pb_obj			=	FUSDPOP+glb.vdi.low;
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

   vqt_attributes(glb.vdi.ha,tattr);
   vqf_attributes(glb.vdi.ha,fattr);
	flags=parm->pb_tree[parm->pb_obj].ob_flags;
	state=parm->pb_tree[parm->pb_obj].ob_state;

	vsl_color(glb.vdi.ha,BLACK);
	vst_effects(glb.vdi.ha,TXT_NORMAL);
	vst_alignment(glb.vdi.ha,ALI_LEFT,ALI_BASE,&dummy,&dummy);
	user=(UBLK *)(parm->pb_parm);

	vst_point(glb.vdi.ha,10-glb.vdi.low,&dummy,&htext,&dummy,&dummy);

	my1.g_x=parm->pb_x-3;
	my1.g_y=parm->pb_y-3;
	my1.g_w=parm->pb_w+6;
	my1.g_h=parm->pb_h+6;
	my2.g_x=parm->pb_xc;
	my2.g_y=parm->pb_yc;
	my2.g_w=parm->pb_wc;
	my2.g_h=parm->pb_hc;
	_rcIntersect(&my1,&my2);
	tab_clip[0]=my2.g_x;
	tab_clip[1]=my2.g_y;
	tab_clip[2]=tab_clip[0]+my2.g_w-1;
	tab_clip[3]=tab_clip[1]+my2.g_h-1;
	vs_clip(glb.vdi.ha,TRUE,tab_clip);
	pxy[0]=parm->pb_x-1;
	pxy[1]=parm->pb_y-1;
	pxy[2]=parm->pb_x+parm->pb_w;
	pxy[3]=pxy[1];
	pxy[4]=pxy[2];
	pxy[5]=parm->pb_y+parm->pb_h;
	pxy[6]=pxy[0];
	pxy[7]=pxy[5];
	pxy[8]=pxy[0];
	pxy[9]=pxy[1];
	v_pline(glb.vdi.ha,5,pxy);
	pxy[0]=parm->pb_x+parm->pb_w+1;
	pxy[1]=parm->pb_y;
	pxy[2]=pxy[0];
	pxy[3]=parm->pb_y+parm->pb_h+1;
	pxy[4]=parm->pb_x;
	pxy[5]=pxy[3];
	v_pline(glb.vdi.ha,3,pxy);
	pxy[0]=parm->pb_x+parm->pb_w+2;
	pxy[1]=parm->pb_y;
	pxy[2]=pxy[0];
	pxy[3]=parm->pb_y+parm->pb_h+2;
	pxy[4]=parm->pb_x;
	pxy[5]=pxy[3];
	v_pline(glb.vdi.ha,3,pxy);

	bar[0]=my1.g_x;
	bar[1]=my1.g_y;
	bar[2]=bar[0]+my1.g_w-1;
	bar[3]=bar[1]+my1.g_h-1;

	vswr_mode(glb.vdi.ha,MD_REPLACE);
	vsf_perimeter(glb.vdi.ha,FALSE);
	vsf_interior(glb.vdi.ha,FIS_SOLID);
	vsf_style(glb.vdi.ha,0);

	if (flags&FL3DACT)
		backcol=LWHITE;
	else
		backcol=WHITE;
	textcol=BLACK;
	if (backcol==LWHITE && glb.vdi.extnd[4]<4)
		backcol=WHITE;
	bar[0]=parm->pb_x;
	bar[1]=parm->pb_y;
	bar[2]=bar[0]+parm->pb_w-1;
	bar[3]=bar[1]+parm->pb_h-1;
	vsf_color(glb.vdi.ha,backcol);
	/****************************************************************************
		Fond Blanc/Gris suivant r‚solution et 3D
	****************************************************************************/
	v_bar(glb.vdi.ha,bar);
	vst_color(glb.vdi.ha,textcol);
	vs_clip(glb.vdi.ha,FALSE,tab_clip);

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
	vs_clip(glb.vdi.ha,TRUE,tab_clip);
	vswr_mode(glb.vdi.ha,MD_TRANS);

	p=(char *)user->spec;
	while (*p==32)
		p++;
	vqt_extent(glb.vdi.ha,p,extent);

	x=parm->pb_x+pb.pb_w/2;
	y=parm->pb_y;
	y+=parm->pb_h/2;
	y-=(extent[7]-extent[1])/2;
	y+=htext;
	/****************************************************************************
		Si bouton 3D alors on d‚cale le texte
	****************************************************************************/
	if (flags&FL3DIND && flags&FL3DACT && state&SELECTED)
	{
		x+=1;
		y+=1;
	}
	v_gtext(glb.vdi.ha,x,y,p);

	vs_clip(glb.vdi.ha,FALSE,tab_clip);
	vst_effects(glb.vdi.ha,TXT_NORMAL);
	vst_alignment (glb.vdi.ha,tattr[3],tattr[4],&dummy,&dummy);
	vsf_interior(glb.vdi.ha,fattr[2]);
	vsf_style(glb.vdi.ha,fattr[0]);
	vsf_perimeter(glb.vdi.ha,fattr[4]);
	_drawCicon(&pb);
	/****************************************************************************
		Si le bouton est en relief alors il faut demander … l'AES de dessiner
		l'attribut SELECTED pour qu'il inverse le cadre fin gris/noir.
		Par contre si le bouton n'est pas en relief, il ne faut surtout pas
		demander … l'AES de dessiner cet attribut sinon; lorsque l'objet est
		s‚lectionn‚ (donc noir), l'AES le recouvre en blanc !!
	****************************************************************************/
	if (flags&FL3DIND && flags&FL3DACT || flags&FL3DIND)
		return parm->pb_currstate;
	else
		return parm->pb_currstate&~SELECTED;
}
