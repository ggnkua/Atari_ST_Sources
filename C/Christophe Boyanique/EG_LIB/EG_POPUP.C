/******************************************************************************/
/*	"Easy Gem" library Copyright (c)1994 by		Christophe BOYANIQUE				*/
/*																29 Rue R‚publique					*/
/*																37230 FONDETTES					*/
/*																FRANCE								*/
/*						*small* mail at email adress:	cb@spia.freenix.fr				*/
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
/*	PopUp menu handling functions																*/
/*		Original functions by Emmanuel Thalmy												*/
/*		Adaptation by Christophe Boyanique													*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	VARIABLES																						*/
/******************************************************************************/
static	ulong	BUF,ADR,LEN;


/******************************************************************************/
/*	FUNCTIONS																						*/
/******************************************************************************/
static	int		menu_just_x	(int title_xy,int title_wh,int menu_wh,int menu_just);
static	int		menu_just_y	(int title_xy,int menu_just,int title_h);
static	int		menu_handle	(OBJECT *tree,int menu_button,int menu_x,int menu_y,int menu_w,int menu_h);
static	int		menu_change	(OBJECT *tree,int objc,int mx,int my,int *x,int *y,int *w,int *h);
static	void		menu_swap	(OBJECT *tree,int x,int y,int w,int h,int mode);
static	void		menu_normal	(OBJECT *Tree,int Object,int Mode);
static	void		_popDraw		(int sel,int x,int y,int w,int h,int wcell,int hcell,int hchar,char *txt,int len);


/******************************************************************************/
/*	MAIN POPUP FUNCTIONS																			*/
/******************************************************************************/
int _formMenu(OBJECT *tree,int obj,OBJECT *menu,int hJust,int vJust,int Video)
{
	int		menuEntry,titleX,titleY,titleW,titleH;
	int		menuX,menuY,menuW,menuH,menuButton,dum;
	int		mx,my,mk,mh;

	if (Video==1)
	{
		tree[obj].ob_state|=SELECTED;
		objc_draw(tree,obj,MAX_DEPTH,glb.xdesk,glb.ydesk,glb.wdesk,glb.hdesk);
	}

	graf_mkstate(&dum,&dum,&mk,&dum);
	if (mk)
		menuButton=0;
	else
		menuButton=1;

	objc_offset(tree,obj,&titleX,&titleY);
	titleW=tree[obj].ob_width;
	titleH=tree[obj].ob_height;
	menuW=menu->ob_width;
	menuH=menu->ob_height;
	menuX=menu_just_x(titleX,titleW,menuW,hJust);
	menuY=menu_just_y(titleY,vJust,titleH);
	menuX=max( glb.xdesk+8,menuX );
	menuX=min( glb.xdesk+glb.wdesk-menuW-8,menuX );
	menuY=max( glb.ydesk+8,menuY );
	menuY=min( glb.ydesk+glb.hdesk-menuH-8,menuY );
	menu->ob_x=menuX;
	menu->ob_y=menuY;
	menu_swap(menu,menuX,menuY,menuW,menuH,0);
	menuEntry=menu_handle(menu,menuButton,menuX,menuY,menuW,menuH);
	mk=1;
	while (mk!=0)
		evnt_button(1,0,0,&mx,&my,&mk,&mh);
	menu_swap(menu,menuX,menuY,menuW,menuH,1);
	if (Video==1)
	{
		tree[obj].ob_state&=~SELECTED;
		objc_draw(tree,obj,MAX_DEPTH,glb.xdesk,glb.ydesk,glb.wdesk,glb.hdesk);
	}
	return menuEntry;
}
int _popUp(OBJECT *menu,int x,int y)
{
	int		menuEntry,dum;
	int		menuX,menuY,menuW,menuH,menuButton;
	int		mx,my,mk,mh;

	graf_mkstate(&dum,&dum,&mk,&dum);
	if (mk)
		menuButton=0;
	else
		menuButton=1;

	menuW=menu->ob_width;
	menuH=menu->ob_height;
	menuX=x;
	menuY=y;
	menuX=max( glb.xdesk+8,menuX );
	menuX=min( glb.xdesk+glb.wdesk-menuW-8,menuX );
	menuY=max( glb.ydesk+8,menuY );
	menuY=min( glb.ydesk+glb.hdesk-menuH-8,menuY );
	menu->ob_x=menuX;
	menu->ob_y=menuY;
	menu_swap(menu,menuX,menuY,menuW,menuH,0);
	menuEntry=menu_handle(menu,menuButton,menuX,menuY,menuW,menuH);
	mk=1;
	while (mk!=0)
		evnt_button(1,0,0,&mx,&my,&mk,&mh);
	menu_swap(menu,menuX,menuY,menuW,menuH,1);

	return menuEntry;
}


/******************************************************************************/
/*	X JUSTIFICATION																				*/
/******************************************************************************/
menu_just_x(int title_xy,int title_wh,int menu_wh,int menu_just)
{
	int		menu_xy;

	switch (menu_just)
	{
		case -2:		menu_xy=title_xy-menu_wh;						break;
		case -1:		menu_xy=title_xy+(title_wh-menu_wh);		break;
		case  0:		menu_xy=title_xy+((title_wh-menu_wh)/2);	break;
		case +1:		menu_xy=title_xy;									break;
		case +2:		menu_xy=title_xy+title_wh;						break;
	}
	return menu_xy;
}


/******************************************************************************/
/*	Y JUSTIFICATION																				*/
/******************************************************************************/
menu_just_y(int title_xy,int menu_just,int title_h)
{
	int		menu_xy;

	menu_xy=title_xy+title_h*menu_just;
	return menu_xy;
}


/******************************************************************************/
/*	POPUP HANDLING																					*/
/******************************************************************************/
menu_handle(OBJECT *tree,int menu_button,int menu_x,int menu_y,int menu_w,int menu_h)
{
	int		evnt,menu_evnt,menu_flag,mx,my,VoiD;
	int		menu_entry,entry_x,entry_y,entry_w,entry_h;
	int		i;

	entry_x=0;
	entry_y=0;
	entry_w=0;
	entry_h=0;
	menu_entry=-1;
	menu_evnt=MU_BUTTON+MU_M1;
	menu_flag=0;
	do
	{
		evnt=evnt_multi(menu_evnt,1,1,menu_button,menu_flag,menu_x,menu_y,menu_w,menu_h,1,entry_x,entry_y,entry_w,entry_h,0,0,0,&mx,&my,&VoiD,&VoiD,&VoiD,&VoiD);
		if ( evnt & (MU_M1+MU_M2) )
		{
			menu_entry=menu_change(tree,menu_entry,mx,my,&entry_x,&entry_y,&entry_w,&entry_h);
			if (evnt & MU_M1)
			{
				menu_flag=1-menu_flag;
				menu_evnt^=MU_M2;
			}
		}
	} while (!(evnt & MU_BUTTON));

	if (menu_entry!=-1)
		for (i=0;i<1+(4*glb.opt.popf);i++)
		{
			evnt_timer(25,0);
			menu_normal(tree,menu_entry,0);
			evnt_timer(25,0);
			menu_normal(tree,menu_entry,1);
		}

	return menu_entry;
}


/******************************************************************************/
/*	STATE INVERSION: NORMAL <-> SELECTED													*/
/******************************************************************************/
menu_change(OBJECT *tree,int objc,int mx,int my,int *x,int *y,int *w,int *h)
{
	if (objc>0)
		menu_normal(tree,objc,1);
	objc=objc_find(tree,0,1,mx,my);
	if (objc>=0)
	{
		objc_offset(tree,objc,x,y);
		if (objc>0)
		{
			*w=tree[objc].ob_width;
			*h=tree[objc].ob_height;
			if ( (tree[objc].ob_state&DISABLED) || !(tree[objc].ob_flags&SELECTABLE) )
				objc=-1;
			else
				menu_normal(tree,objc,0);
		}
		else
		{
			objc=-1;
			*x=mx;
			*y=my;
			*w=1;
			*h=1;
		}
	}
	return objc;
}


/******************************************************************************/
/*	BUFFER TO SAVE BACKGROUND																	*/
/******************************************************************************/
void menu_swap(OBJECT *tree,int x,int y,int w,int h,int mode)
{
	int				tab[8],i;
	MFDB				S,D;
	uint				a1,a2,a3,a4;
	ulong				len,aGEM,lGEM;

	x-=4;		w+=8;
	y-=4;		h+=8;

	if (mode==0)								/*	SAVING	*/
	{
		S.fd_addr		=	0;
		S.fd_w			=	0;
		S.fd_h			=	0;
		S.fd_wdwidth	=	0;
		S.fd_stand		=	0;
		S.fd_nplanes	=	0;
		tab[0]			=	x;
		tab[1]			=	y;
		tab[2]			=	x+w-1;
		tab[3]			=	y+h-1;
		D.fd_w			=	w;
		D.fd_h			=	h;
		D.fd_wdwidth	=	_word(D.fd_w);
		D.fd_stand		=	0;
		D.fd_nplanes	=	glb.extnd[4];
		tab[4]			=	0;
		tab[5]			=	0;
		tab[6]			=	w-1;
		tab[7]			=	h-1;
		len=(ulong)D.fd_wdwidth*2L*(ulong)D.fd_h*(ulong)glb.extnd[4];
		wind_get(0,WF_SCREEN,&a1,&a2,&a3,&a4);
		aGEM=(ulong)a1;	aGEM<<=16;	aGEM+=(ulong)a2;
		lGEM=(ulong)a3;	lGEM<<=16;	lGEM+=(ulong)a4;

		if (len<=lGEM)
		{
			BUF='_GEM';
			ADR=aGEM;
			LEN=lGEM;
		}
		else
		{
			i=_mAlloc(len,MB_NOMOVE,0);
			if (i!=NO_MEMORY)
			{
				BUF='_MEM';
				ADR=mem.bloc[i].adr;
				LEN=mem.bloc[i].len;
			}
			else
			{
				BUF='_FRM';
				form_dial(FMD_START,0,0,0,0,x,y,w,h);
			}
		}
		D.fd_addr=(void *)ADR;
		graf_mouse(M_OFF,0);
		if (BUF!='_FRM')
			vro_cpyfm(glb.hvdi,S_ONLY,tab,&S,&D);
		if (tree!=NULL)
			objc_draw(tree,ROOT,MAX_DEPTH,x,y,w,h);
		graf_mouse(M_ON,0);
	}
	else											/*	LOADING	*/
	{
		tab[0]=0;
		tab[1]=0;
		tab[2]=w-1;
		tab[3]=h-1;
		tab[4]=x;
		tab[5]=y;
		tab[6]=tab[4]+w-1;
		tab[7]=tab[5]+h-1;
		D.fd_addr=0;
		D.fd_w=0;
		D.fd_h=0;
		D.fd_wdwidth=0;
		D.fd_stand=0;
		D.fd_nplanes=0;
		S.fd_addr=(void *)ADR;
		S.fd_w=w;
		S.fd_h=h;
		S.fd_wdwidth=_word(S.fd_w);
		S.fd_stand=0;
		S.fd_nplanes=glb.extnd[4];
		len=(ulong)S.fd_wdwidth*2L*(ulong)S.fd_h*(ulong)glb.extnd[4];
		graf_mouse(M_OFF,0);
		wind_get(0,WF_SCREEN,&a1,&a2,&a3,&a4);
		aGEM=(ulong)a1;	aGEM<<=16;	aGEM+=(ulong)a2;
		lGEM=(ulong)a3;	lGEM<<=16;	lGEM+=(ulong)a4;

		if (BUF=='_FRM')
			form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
		else
		{
			vro_cpyfm(glb.hvdi,S_ONLY,tab,&S,&D);
			if (BUF=='_MEM')
				_mSpecFree(ADR);
		}
		graf_mouse(M_ON,0);
	}
}


/******************************************************************************/
/*	OPTION DRAWING																					*/
/******************************************************************************/
void menu_normal(OBJECT *Tree,int Object,int Mode)
{
	int	obx,oby,obw,obh;

	if (Mode)
		Tree[Object].ob_state&=~SELECTED;
	else
		Tree[Object].ob_state|=SELECTED;
	_coord(Tree,Object,FALSE,&obx,&oby,&obw,&obh);
	objc_draw(Tree,Object,MAX_DEPTH,obx,oby,obw,obh);
}


/******************************************************************************/
/*	EXTENDED POPUP MENU WITH SCROLLING														*/
/******************************************************************************/
int _formXmenu	(OBJECT *tree,int obj,char *tab,int nmb,int off,int len,int val)
{
	MFDB		S,D;
	int		pxy[8];
	OBJECT	*ptree=__rsc.head.trindex[FPOP];
	int		dum,i,n,num,ob,px,py,fx,fy,dec;
	int		wchar,hchar,wcell,hcell;
	int		tattr[10],lattr[6],fattr[6];
	int		obx,oby,obw,obh;
	int		x,y,w,h,xpop,ypop,wpop,hpop;
	int		evnt,ev,mx,my,mk,k;
	int		mnf,ent,enx,eny,enw,enh;

	do
	{
		graf_mkstate(&mx,&my,&mk,&dum);
	}	while (mk);

	vqt_attributes(glb.hvdi,tattr);
	vql_attributes(glb.hvdi,lattr);
	vqf_attributes(glb.hvdi,fattr);

	vst_font(glb.hvdi,1);
	vst_point(glb.hvdi,10-2*glb.low,&wchar,&hchar,&wcell,&hcell);
	vst_effects(glb.hvdi,TXT_NORMAL);
	vst_alignment(glb.hvdi,ALI_LEFT,ALI_TOP,&dum,&dum);

	vsf_perimeter(glb.hvdi,TRUE);
	vsf_interior(glb.hvdi,FIS_SOLID);

	vsl_type(glb.hvdi,SOLID);
	vsl_width(glb.hvdi,1);
	vsl_color(glb.hvdi,BLACK);

	n=min(glb.hdesk/hcell-2,nmb);

	_coord(tree,obj,FALSE,&obx,&oby,&obw,&obh);
	if (nmb>n)
		wpop=(len+2)*wcell+2+ptree[FPOPBOX].ob_width;
	else
		wpop=(len+2)*wcell+2;
	hpop=n*hcell+2;
	xpop=obx+(obw-wpop)/2-1;
	ypop=oby+(obh-hpop)/2-1;
	xpop=max(xpop,glb.xdesk);
	xpop=min(xpop,glb.xdesk+glb.wdesk-wpop);
	ypop=max(ypop,glb.ydesk);
	ypop=min(ypop,glb.xdesk+glb.hdesk-hpop);
	x=xpop+1;
	y=ypop+1;
	if (nmb>n)
		w=wpop-2-ptree[FPOPBOX].ob_width;
	else
		w=wpop-2;
	h=hpop-2;

	if ( (mx>x) && (mx<x+w-1) && (my>y) && (my<y+h) )
	{
		ent=(my-y)/hcell;
		num=val-ent;
		num=min(num,nmb-n);
		num=max(num,0);
	}
	else
		num=0;

	ptree->ob_x=xpop;
	ptree->ob_y=ypop;
	ptree->ob_width=wpop;
	ptree->ob_height=hpop;
	if (nmb>n)
	{
		ptree[FPOPBOX].ob_x=ptree->ob_width-ptree[FPOPBOX].ob_width;
		ptree[FPOPBOX].ob_height=ptree->ob_height;
		ptree[FPOPDN].ob_y=ptree[FPOPBOX].ob_height-ptree[FPOPDN].ob_height;
		ptree[FPOPUP].ob_y=ptree[FPOPBOX].ob_height-2*ptree[FPOPDN].ob_height;
		ptree[FPOPF].ob_height=ptree[FPOPBOX].ob_height-2*ptree[FPOPDN].ob_height;
		ptree[FPOPP].ob_height=(double)ptree[FPOPF].ob_height*(double)n/(double)nmb;
		ptree[FPOPI].ob_y=(ptree[FPOPP].ob_height-ptree[FPOPI].ob_height)/2;
		ptree[FPOPP].ob_y=(double)num/(double)(nmb-n)*(double)(ptree[FPOPF].ob_height-ptree[FPOPP].ob_height);
		ptree[FPOPBOX].ob_flags&=~HIDETREE;
	}
	else
		ptree[FPOPBOX].ob_flags|=HIDETREE;

	menu_swap(NULL,xpop-1,ypop-1,wpop+2,hpop+2,FALSE);
	graf_mouse(M_OFF,0);
	objc_draw(ptree,ROOT,MAX_DEPTH,xpop-1,ypop-1,wpop+2,hpop+2);
	for (i=0;i<n;i++)
		_popDraw(FALSE,x,y+i*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+i)*(long)(len+off)),len);
	graf_mouse(M_ON,0);

	if (n==nmb)
		graf_mouse(POINT_HAND,0);
	else if (num==0)
		graf_mouse(USER_DEF,&__s[FSOUDN]);
	else if (num==nmb-n)
		graf_mouse(USER_DEF,&__s[FSOUUP]);
	else
		graf_mouse(USER_DEF,&__s[FSOUUPDN]);
	enx=0;
	eny=0;
	enw=0;
	enh=0;
	ent=-1;
	evnt=MU_BUTTON+MU_M1;
	mnf=0;
	do
	{
		ev=evnt_multi(evnt,0x102,3,0,mnf,x,y,w,h,1,enx,eny,enw,enh,0,0,0,&mx,&my,&mk,&dum,&dum,&dum);
		k=mk;
		if (ev & (MU_M1|MU_M2))
		{
			if (ent>=0)
			{
				graf_mouse(M_OFF,0);
				_popDraw(FALSE,x,y+ent*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+ent)*(long)(len+off)),len);
				graf_mouse(M_ON,0);
			}
			if ( (mx>x) && (mx<x+w-1) )
			{
				if (n==nmb)
					graf_mouse(POINT_HAND,0);
				else if (num==0)
					graf_mouse(USER_DEF,&__s[FSOUDN]);
				else if (num==nmb-n)
					graf_mouse(USER_DEF,&__s[FSOUUP]);
				else
					graf_mouse(USER_DEF,&__s[FSOUUPDN]);
				if ( (my>y) && (my<y+h) )
					ent=(my-y)/hcell;
				else
				{
					if (my<y)
					{
						if (num>0)
							ent=-2;
						else
							ent=-1;
						enx=eny=enw=enh=0;
						if (num>0 && nmb>n)
						{
							num-=1;
							S.fd_addr		=	D.fd_addr		=	0;
							S.fd_w			=	D.fd_w			=	0;
							S.fd_h			=	D.fd_h			=	0;
							S.fd_wdwidth	=	D.fd_wdwidth	=	0;
							S.fd_stand		=	D.fd_stand		=	0;
							S.fd_nplanes	=	D.fd_nplanes	=	0;
							pxy[0]	=	x;								pxy[4]	=	x;
							pxy[1]	=	y;								pxy[5]	=	y+hcell;
							pxy[2]	=	x+w-1;						pxy[6]	=	x+w-1;
							pxy[3]	=	y+(n-1)*hcell-1;			pxy[7]	=	y+hcell+(n-1)*hcell-1;
							graf_mouse(M_OFF,0);
							vro_cpyfm(glb.hvdi,S_ONLY,pxy,&S,&D);
							_popDraw(FALSE,x,y,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)num*(long)(len+off)),len);
							if (nmb>n)
							{
								ptree[FPOPP].ob_y=(double)num/(double)(nmb-n)*(double)(ptree[FPOPF].ob_height-ptree[FPOPP].ob_height);
								objc_draw(ptree,FPOPF,MAX_DEPTH,xpop-1,ypop-1,wpop+2,hpop+2);
							}
							graf_mouse(M_ON,0);

						}
					}
					if (my>=y+h)
					{
						if (num<nmb-n)
							ent=-2;
						else
							ent=-1;
						enx=eny=enw=enh=0;
						if (num<nmb-n && nmb>n)
						{
							num+=1;
							S.fd_addr		=	D.fd_addr		=	0;
							S.fd_w			=	D.fd_w			=	0;
							S.fd_h			=	D.fd_h			=	0;
							S.fd_wdwidth	=	D.fd_wdwidth	=	0;
							S.fd_stand		=	D.fd_stand		=	0;
							S.fd_nplanes	=	D.fd_nplanes	=	0;
							pxy[0]	=	x;								pxy[4]	=	x;
							pxy[1]	=	y+hcell;						pxy[5]	=	y;
							pxy[2]	=	x+w-1;						pxy[6]	=	x+w-1;
							pxy[3]	=	y+hcell+(n-1)*hcell-1;	pxy[7]	=	y+(n-1)*hcell-1;
							graf_mouse(M_OFF,0);
							vro_cpyfm(glb.hvdi,S_ONLY,pxy,&S,&D);
							_popDraw(FALSE,x,y+(n-1)*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+n-1)*(long)(len+off)),len);
							if (nmb>n)
							{
								ptree[FPOPP].ob_y=(double)num/(double)(nmb-n)*(double)(ptree[FPOPF].ob_height-ptree[FPOPP].ob_height);
								objc_draw(ptree,FPOPF,MAX_DEPTH,xpop-1,ypop-1,wpop+2,hpop+2);
							}
							graf_mouse(M_ON,0);
						}
					}
				}
			}
			else
			{
				graf_mouse(POINT_HAND,0);
				ent=-1;
			}
			if ( ent>=0 && ent<n )
			{
				enx=x;
				eny=y+ent*hcell;
				enw=w;
				enh=hcell;
				graf_mouse(M_OFF,0);
				_popDraw(TRUE,x,y+ent*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+ent)*(long)(len+off)),len);
				graf_mouse(M_ON,0);
			}
			else if (ent==-1)
			{
				enx=mx;
				eny=my;
				enw=1;
				enh=1;
			}
			if ( ev&MU_M1 && ent!=-2 )
			{
				mnf=1-mnf;
				evnt^=MU_M2;
			}
		}
		if ( ev&MU_BUTTON && nmb>n )
		{
			ob=objc_find(ptree,ROOT,MAX_DEPTH,mx,my);
			switch	(ob)
			{
				case	FPOPUP:
					ent=-1;
					ptree[ob].ob_state|=SELECTED;
					graf_mouse(M_OFF,0);
					objc_draw(ptree,ob,0,xpop,ypop,wpop,hpop);
					while (mk)
					{
						if (num>0)
						{
							ent=-2;
							num-=1;
							if (k!=2)
							{
								S.fd_addr		=	D.fd_addr		=	0;
								S.fd_w			=	D.fd_w			=	0;
								S.fd_h			=	D.fd_h			=	0;
								S.fd_wdwidth	=	D.fd_wdwidth	=	0;
								S.fd_stand		=	D.fd_stand		=	0;
								S.fd_nplanes	=	D.fd_nplanes	=	0;
								pxy[0]	=	x;								pxy[4]	=	x;
								pxy[1]	=	y;								pxy[5]	=	y+hcell;
								pxy[2]	=	x+w-1;						pxy[6]	=	x+w-1;
								pxy[3]	=	y+(n-1)*hcell-1;			pxy[7]	=	y+hcell+(n-1)*hcell-1;
								vro_cpyfm(glb.hvdi,S_ONLY,pxy,&S,&D);
								_popDraw(FALSE,x,y,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)num*(long)(len+off)),len);
							}
							ptree[FPOPP].ob_y=(double)num/(double)(nmb-n)*(double)(ptree[FPOPF].ob_height-ptree[FPOPP].ob_height);
							objc_draw(ptree,FPOPF,MAX_DEPTH,xpop-1,ypop-1,wpop+2,hpop+2);
						}
						else
							while(!mk)
								graf_mkstate(&dum,&dum,&mk,&dum);
						graf_mkstate(&dum,&dum,&mk,&dum);
					}
					if (k==2)
						for (i=0;i<n;i++)
							_popDraw(FALSE,x,y+i*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+i)*(long)(len+off)),len);
					ptree[ob].ob_state&=~SELECTED;
					objc_draw(ptree,ob,0,xpop,ypop,wpop,hpop);
					graf_mouse(M_ON,0);
					ev&=~MU_BUTTON;
					break;
				case	FPOPDN:
					ent=-1;
					ptree[ob].ob_state|=SELECTED;
					graf_mouse(M_OFF,0);
					objc_draw(ptree,ob,0,xpop,ypop,wpop,hpop);
					while (mk)
					{
						if (num<nmb-n)
						{
							ent=-2;
							num+=1;
							if (k!=2)
							{
								S.fd_addr		=	D.fd_addr		=	0;
								S.fd_w			=	D.fd_w			=	0;
								S.fd_h			=	D.fd_h			=	0;
								S.fd_wdwidth	=	D.fd_wdwidth	=	0;
								S.fd_stand		=	D.fd_stand		=	0;
								S.fd_nplanes	=	D.fd_nplanes	=	0;
								pxy[0]	=	x;								pxy[4]	=	x;
								pxy[1]	=	y+hcell;						pxy[5]	=	y;
								pxy[2]	=	x+w-1;						pxy[6]	=	x+w-1;
								pxy[3]	=	y+hcell+(n-1)*hcell-1;	pxy[7]	=	y+(n-1)*hcell-1;
								vro_cpyfm(glb.hvdi,S_ONLY,pxy,&S,&D);
								_popDraw(FALSE,x,y+(n-1)*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+n-1)*(long)(len+off)),len);
							}
							ptree[FPOPP].ob_y=(double)num/(double)(nmb-n)*(double)(ptree[FPOPF].ob_height-ptree[FPOPP].ob_height);
							objc_draw(ptree,FPOPF,MAX_DEPTH,xpop-1,ypop-1,wpop+2,hpop+2);
						}
						else
							while(!mk)
								graf_mkstate(&dum,&dum,&mk,&dum);
						graf_mkstate(&dum,&dum,&mk,&dum);
					}
					if (k==2)
						for (i=0;i<n;i++)
							_popDraw(FALSE,x,y+i*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+i)*(long)(len+off)),len);
					ptree[ob].ob_state&=~SELECTED;
					objc_draw(ptree,ob,0,xpop,ypop,wpop,hpop);
					graf_mouse(M_ON,0);
					ev&=~MU_BUTTON;
					break;
				case	FPOPF:
					graf_mouse(M_OFF,0);
					_coord(ptree,FPOPP,FALSE,&obx,&oby,&obw,&obh);
					if (my<oby)
						num=max(0,num-n);
					else
						num=min(nmb-n,num+n);
					for (i=0;i<n;i++)
						_popDraw(FALSE,x,y+i*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+i)*(long)(len+off)),len);
					ptree[FPOPP].ob_y=(double)num/(double)(nmb-n)*(double)(ptree[FPOPF].ob_height-ptree[FPOPP].ob_height);
					objc_draw(ptree,FPOPF,MAX_DEPTH,xpop-1,ypop-1,wpop+2,hpop+2);
					graf_mouse(M_ON,0);
					ev&=~MU_BUTTON;
					break;
				case	FPOPP:
				case	FPOPI:
					objc_offset(ptree,FPOPP,&px,&py);
					objc_offset(ptree,FPOPF,&fx,&fy);
					graf_mkstate(&mx,&my,&mk,&dum);
					dec=py-my;
					graf_mouse(M_OFF,0);
					do
					{
						graf_mkstate(&dum,&my,&mk,&dum);
						dum=my-fy+dec;
						dum=max(0,dum);
						dum=min(ptree[FPOPF].ob_height-ptree[FPOPP].ob_height,dum);
						if (dum!=ptree[FPOPP].ob_y)
						{
							ptree[FPOPP].ob_y=dum;
							_coord(ptree,FPOPF,FALSE,&obx,&oby,&obw,&obh);
							objc_draw(ptree,FPOPF,MAX_DEPTH,obx,oby,obw,obh);
							dum=(double)ptree[FPOPP].ob_y*(double)(nmb-n)/(double)(ptree[FPOPF].ob_height-ptree[FPOPP].ob_height);
							dum=max(0,dum);
							dum=min(nmb-n,dum);
							if (dum!=num)
							{
								num=dum;
								if (k!=2)
									for (i=0;i<n;i++)
										_popDraw(FALSE,x,y+i*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+i)*(long)(len+off)),len);
							}
						}
					}	while (mk);
					if (k==2)
						for (i=0;i<n;i++)
							_popDraw(FALSE,x,y+i*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+i)*(long)(len+off)),len);
					graf_mouse(M_ON,0);
					ev&=~MU_BUTTON;
					break;
			}
		}
	}	while (!(ev&MU_BUTTON));

	graf_mouse(M_OFF,0);
	if (ent>=0)
		for (i=0;i<1+(4*glb.opt.popf);i++)
		{
			evnt_timer(25,0);
			_popDraw(FALSE,x,y+ent*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+ent)*(long)(len+off)),len);
			evnt_timer(25,0);
			_popDraw(TRUE,x,y+ent*hcell,w,hcell,wcell,hcell,hchar,(char *)((long)tab+(long)(num+ent)*(long)(len+off)),len);
		}
	graf_mouse(M_ON,0);

	graf_mouse(ARROW,0);
	menu_swap(NULL,xpop-1,ypop-1,wpop+2,hpop+2,TRUE);
	vst_font(glb.hvdi,tattr[0]);
	vst_color(glb.hvdi,tattr[1]);
	vst_alignment(glb.hvdi,tattr[3],tattr[4],&dum,&dum);
	vsf_interior(glb.hvdi,fattr[2]);
	vsf_style(glb.hvdi,fattr[0]);
	vsf_perimeter(glb.hvdi,fattr[4]);
	vsl_type(glb.hvdi,lattr[0]);
	vsl_color(glb.hvdi,lattr[1]);

	if (ent>=0)
		val=num+ent;
	else
		val=-1;
	return val;
}
static void _popDraw(int sel,int x,int y,int w,int h,int wcell,int hcell,int hchar,char *txt,int len)
{
	int	clip[4],extent[8];
	char	*p,q;

	p=(char *)((long)txt+(long)len);
	q=*p;
	*p=0;
	clip[0]=x;
	clip[1]=y;
	clip[2]=x+w-1;
	clip[3]=y+h-1;
	vqt_extent(glb.hvdi,txt,extent);
	vs_clip(glb.hvdi,TRUE,clip);

	vswr_mode(glb.hvdi,MD_REPLACE);
	if (sel)
	{
		vsf_color(glb.hvdi,BLACK);
		vst_color(glb.hvdi,WHITE);
	}
	else
	{
		vsf_color(glb.hvdi,WHITE);
		vst_color(glb.hvdi,BLACK);
	}
	v_bar(glb.hvdi,clip);
	vswr_mode(glb.hvdi,MD_TRANS);

	x+=1+wcell;
	y+=(hcell-hchar)/2;
	v_gtext(glb.hvdi,x,y,txt);
	vs_clip(glb.hvdi,FALSE,clip);
	*p=q;
}
