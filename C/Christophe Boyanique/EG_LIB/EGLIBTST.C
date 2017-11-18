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
/*	THIS A SAMPLE EXEMPLE PROGRAM ABSOLUTELY USEFULLNESS BUT YOU CAN TEST		*/
/*	EGlib WITH IT																					*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EGLIB.H"
#include		<string.h>

#define		RSC_RELLOC
#ifdef RSC_RELLOC
	#define		statique		static
	#include		"EGLIBTST.RSH"
	#include		"EGLIBTST.RH"
#else
	#include		"EGLIBTST.H"
#endif

void	Init			(void);
void	initForm		(int Tree,int n);
void	PopForm		(int i,int n);
void	gereMenu		(int option);
void	AcOpen		(void);
void	Main			(void);
void	Info			(void);

main()
{
	_clearGLB();
	strcpy(glb.name,"  Test  ");
	strcpy(glb.help,"_MAIN");
	strcpy(glb.cnf,"EGLIBTST.CNF");
	glb.NMB_WDW		=	0;
	glb.opt.mlen	=	0;
	glb.opt.mnmb	=	0;
	glb.Finit		=	Init;

	_EGlib();
	return FALSE;
}


void	Init()
{
	#ifdef RSC_RELLOC
		int		i;
		strcpy(glb.rsc.name,"");
		glb.rsc.type			=	INT_RSC;
		glb.rsc.head.nobs		=	NUM_OBS;
		glb.rsc.head.ntree	=	NUM_TREE;
		glb.rsc.head.nted		=	NUM_TI;
		glb.rsc.head.ncib		=	NUM_CIB;
		glb.rsc.head.nib		=	NUM_IB;
		glb.rsc.head.nbb		=	NUM_BB;
		glb.rsc.head.nfstr	=	NUM_FRSTR;
		glb.rsc.head.nfimg	=	NUM_FRIMG;
		#if NUM_OBS>0
		glb.rsc.head.object	=	rs_object;
		#endif
		#if NUM_TREE>0
		glb.rsc.head.trindex	=	rs_trindex;
		#endif
		#if NUM_TI>0
		glb.rsc.head.tedinfo	=	rs_tedinfo;
		#endif
		#if NUM_IB>0
		glb.rsc.head.iconblk	=	rs_iconblk;
		#endif
		#if NUM_BB>0
		glb.rsc.head.bitblk	=	rs_bitblk;
		#endif
		#if NUM_CIB>0
		glb.rsc.head.cicon	=	rs_cicon;
		glb.rsc.head.ciconblk=	rs_ciconblk;
		#endif
		#if NUM_FRSTR>0
		glb.rsc.head.frstr	=	rs_frstr;
		#endif
		#if NUM_FRIMG>0
		glb.rsc.head.frimg	=	rs_frimg;
		#endif
		for (i=0;i<NUM_OBS;i++)
			rsrc_obfix(&glb.rsc.head.object[i],0);
	#else
		strcpy(glb.rsc.name,"EGLIBTST.RSC");
		glb.rsc.type=EXT_RSC;
	#endif

	glb.FiObRSC		=	initForm;
	glb.menu			=	MENU;
	glb.FgereMenu	=	gereMenu;
	glb.FacOpen		=	AcOpen;
	glb.flag			=	MU_MESAG+MU_BUTTON+MU_KEYBD;
}

void	gereMenu(int option)
{
	switch (option)
	{
		case	MINFO:	Info();			break;
		case	MMAIN:	Main();			break;
		case	MLIB:		_EGlibPop();	break;
		case	MQUIT:	glb.Exit=1;		break;
	}
}

void	AcOpen()
{
	Info();
}

void	PopForm(int i,int n)
{
	if (i!=-1)
	{
		switch (W[i].id)
		{
			case	FINFO:
				switch (n+1)
				{
					case	PMAIN:
						Main();
						break;
					case	PLIB:
						_EGlibPop();
						break;
					case	PQUIT:
						glb.Exit=1;
						break;
				}
				break;
		}
	}
}

void	initForm(int Tree,int n)
{
	OBJECT	*tree;

	tree=glb.rsc.head.trindex[Tree];
	switch (Tree)
	{
		case	FINFO:
			break;

		case	FMAIN:
			switch	(n)
			{
				case	FMANOM:
					_obPutStr(tree,n,"Boyanique");
					break;
				case	FMAPRE:
					_obPutStr(tree,n,"Christophe");
					break;
				case	FMAAGE:
					_obPutStr(tree,n,"21");
					break;
				case	FMAMCH:
					_initPopUp(tree,n,POPUP,0);
					break;
			}
			break;
	}
}

void	Info()
{
	_winForm(FINFO,"INFORMATIONS","INFOS","",PMAIN,-1);
}

void	Main()
{
	_winForm(FMAIN,"TEST DE LA BIBLIO","TEST","",-1,-1);
}
