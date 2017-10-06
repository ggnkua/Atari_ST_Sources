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
/*	SWITCH LANGUAGE OF THE RSC IN MEMORY													*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

void _switchLang()
{
	int	i,j;

	_putSpec(__rsc.head.trindex[FINF],	FINFC1,		__rsc.head.frstr[TINFC1]);
	_putSpec(__rsc.head.trindex[FINF],	FINFC2,		__rsc.head.frstr[TINFC2]);

	_putSpec(__rsc.head.trindex[FMEM],	FMEMMOD,		__rsc.head.frstr[TMEMMOD]);

	_putSpec(__rsc.head.trindex[FOPT],	FOPTFNT,		__rsc.head.frstr[TOPTFNT]);
	_putSpec(__rsc.head.trindex[FOPT],	FOPTHLP,		__rsc.head.frstr[TOPTHLP]);
	_putSpec(__rsc.head.trindex[FOPT],	FOPTPOP,		__rsc.head.frstr[TOPTPOP]);
	_putSpec(__rsc.head.trindex[FOPT],	FOPTFUL,		__rsc.head.frstr[TOPTFUL]);
	_putSpec(__rsc.head.trindex[FOPT],	FOPTSAV,		__rsc.head.frstr[TOPTSAV]);
	_putSpec(__rsc.head.trindex[FOPT],	FOPTDIR,		__rsc.head.frstr[TOPTDIR]);
	_putSpec(__rsc.head.trindex[FOPT],	FOPTFRM,		__rsc.head.frstr[TOPTFRM]);
	_putSpec(__rsc.head.trindex[FOPT],	FOPTFRM1,	__rsc.head.frstr[TOPTFRM1]);
	_putSpec(__rsc.head.trindex[FOPT],	FOPTFRM2,	__rsc.head.frstr[TOPTFRM2]);
	_putSpec(__rsc.head.trindex[FOPT],	FOPTFRM3,	__rsc.head.frstr[TOPTFRM3]);

	_putSpec(__rsc.head.trindex[FFNT],	FFNTTTXT,	__rsc.head.frstr[TFNTCOLT]);
	_putSpec(__rsc.head.trindex[FFNT],	FFNTTFON,	__rsc.head.frstr[TFNTCOLF]);
	_putSpec(__rsc.head.trindex[FFNT],	FFNTGTIT,	__rsc.head.frstr[TFNTGTIT]);
	_putSpec(__rsc.head.trindex[FFNT],	FFNTHTIT,	__rsc.head.frstr[TFNTHTIT]);
	_putSpec(__rsc.head.trindex[FFNT],	FFNTHTXT,	__rsc.head.frstr[TFNTHTXT]);
	_putSpec(__rsc.head.trindex[FFNT],	FFNTHSET,	__rsc.head.frstr[TMEMMOD]);

	_putSpec(__rsc.head.trindex[FSYS],	FSYSFILE,	__rsc.head.frstr[TSYSFILE]);

	_putSpec(__rsc.head.trindex[PCOUL],	1,				__rsc.head.frstr[TPCOUL0]);
	_putSpec(__rsc.head.trindex[PCOUL],	2,				__rsc.head.frstr[TPCOUL1]);
	_putSpec(__rsc.head.trindex[PCOUL],	3,				__rsc.head.frstr[TPCOUL2]);
	_putSpec(__rsc.head.trindex[PCOUL],	4,				__rsc.head.frstr[TPCOUL3]);
	_putSpec(__rsc.head.trindex[PCOUL],	5,				__rsc.head.frstr[TPCOUL4]);
	_putSpec(__rsc.head.trindex[PCOUL],	6,				__rsc.head.frstr[TPCOUL5]);
	_putSpec(__rsc.head.trindex[PCOUL],	7,				__rsc.head.frstr[TPCOUL6]);
	_putSpec(__rsc.head.trindex[PCOUL],	8,				__rsc.head.frstr[TPCOUL7]);
	_putSpec(__rsc.head.trindex[PCOUL],	9,				__rsc.head.frstr[TPCOUL8]);
	_putSpec(__rsc.head.trindex[PCOUL],	10,			__rsc.head.frstr[TPCOUL9]);
	_putSpec(__rsc.head.trindex[PCOUL],	11,			__rsc.head.frstr[TPCOULA]);
	_putSpec(__rsc.head.trindex[PCOUL],	12,			__rsc.head.frstr[TPCOULB]);
	_putSpec(__rsc.head.trindex[PCOUL],	13,			__rsc.head.frstr[TPCOULC]);
	_putSpec(__rsc.head.trindex[PCOUL],	14,			__rsc.head.frstr[TPCOULD]);
	_putSpec(__rsc.head.trindex[PCOUL],	15,			__rsc.head.frstr[TPCOULE]);
	_putSpec(__rsc.head.trindex[PCOUL],	16,			__rsc.head.frstr[TPCOULF]);

	_putSpec(__rsc.head.trindex[PLIB],	PLIBINF,		__rsc.head.frstr[TPLIBINF]);
	_putSpec(__rsc.head.trindex[PLIB],	PLIBMEM,		__rsc.head.frstr[TPLIBMEM]);
	_putSpec(__rsc.head.trindex[PLIB],	PLIBFNT,		__rsc.head.frstr[TPLIBFNT]);
	_putSpec(__rsc.head.trindex[PLIB],	PLIBOPT,		__rsc.head.frstr[TPLIBOPT]);
	_putSpec(__rsc.head.trindex[PLIB],	PLIBSYS,		__rsc.head.frstr[TPLIBSYS]);
	_putSpec(__rsc.head.trindex[PLIB],	PLIBCNF,		__rsc.head.frstr[TPLIBCNF]);
	_putSpec(__rsc.head.trindex[PLIB],	PLIBHLP,		__rsc.head.frstr[TPLIBHLP]);

	_putSpec(__rsc.head.trindex[PHELP],	PHLPIND,		__rsc.head.frstr[TPHLPIND]);
	_putSpec(__rsc.head.trindex[PHELP],	PHLPDN,		__rsc.head.frstr[TPHLPDN]);
	_putSpec(__rsc.head.trindex[PHELP],	PHLPUP,		__rsc.head.frstr[TPHLPUP]);

	if ( (i=_winFindId(TW_FORM,FINF|FLAGS15,TRUE)) !=-1 )
		_winName(i,_getLang(__rsc.head.frstr[WINF]),"EGlib");

	if ( (i=_winFindId(TW_FORM,FMEM|FLAGS15,TRUE)) !=-1 )
		_winName(i,_getLang(__rsc.head.frstr[WMEM]),"EGlib");

	if ( (i=_winFindId(TW_FORM,FFNT|FLAGS15,TRUE)) !=-1 )
		_winName(i,_getLang(__rsc.head.frstr[WFNT]),"EGlib");

	if ( (i=_winFindId(TW_FORM,FOPT|FLAGS15,TRUE)) !=-1 )
		_winName(i,_getLang(__rsc.head.frstr[WOPT]),"EGlib");

	if ( (i=_winFindId(TW_FORM,FSYS|FLAGS15,TRUE)) !=-1 )
		_winName(i,_getLang(__rsc.head.frstr[WSYS]),"EGlib");

	if ( (i=_winFindId(TW_HELP,0,TRUE)) !=-1 )
		_winClose(i);
/*		_winName(i,_getLang(__rsc.head.frstr[WHLP]),"EGlib");*/
	_initAide();
	if (i!=-1)
	{
		j=__TOP;
		__TOP=0;
		_Aide();
		__TOP=j;
	}
	_myInitForm(FFNT,FFNTCTXT);
	_myInitForm(FFNT,FFNTCFON);
	_myInitForm(FMEM,FMEMSYS);
	_myInitForm(FMEM,FMEMLEN);
	_myInitForm(FMEM,FMEMFRE);
}

void _initLang()
{
	_cut(__rsc.head.frstr[TINFC1]);
	_cut(__rsc.head.frstr[TINFC2]);
	_cut(__rsc.head.frstr[TMEMMOD]);
	_cut(__rsc.head.frstr[TOPTFNT]);
	_cut(__rsc.head.frstr[TOPTHLP]);
	_cut(__rsc.head.frstr[TOPTPOP]);
	_cut(__rsc.head.frstr[TOPTFUL]);
	_cut(__rsc.head.frstr[TOPTSAV]);
	_cut(__rsc.head.frstr[TOPTFRM]);
	_cut(__rsc.head.frstr[TOPTFRM1]);
	_cut(__rsc.head.frstr[TOPTFRM2]);
	_cut(__rsc.head.frstr[TOPTFRM3]);
	_cut(__rsc.head.frstr[TOPTDIR]);
	_cut(__rsc.head.frstr[TFNTCOLT]);
	_cut(__rsc.head.frstr[TFNTCOLF]);
	_cut(__rsc.head.frstr[TFNTGTIT]);
	_cut(__rsc.head.frstr[TFNTHTIT]);
	_cut(__rsc.head.frstr[TFNTHTXT]);
	_cut(__rsc.head.frstr[TSYSFILE]);
	_cut(__rsc.head.frstr[TPCOUL0]);
	_cut(__rsc.head.frstr[TPCOUL1]);
	_cut(__rsc.head.frstr[TPCOUL2]);
	_cut(__rsc.head.frstr[TPCOUL3]);
	_cut(__rsc.head.frstr[TPCOUL4]);
	_cut(__rsc.head.frstr[TPCOUL5]);
	_cut(__rsc.head.frstr[TPCOUL6]);
	_cut(__rsc.head.frstr[TPCOUL7]);
	_cut(__rsc.head.frstr[TPCOUL8]);
	_cut(__rsc.head.frstr[TPCOUL9]);
	_cut(__rsc.head.frstr[TPCOULA]);
	_cut(__rsc.head.frstr[TPCOULB]);
	_cut(__rsc.head.frstr[TPCOULC]);
	_cut(__rsc.head.frstr[TPCOULD]);
	_cut(__rsc.head.frstr[TPCOULE]);
	_cut(__rsc.head.frstr[TPCOULF]);
	_cut(__rsc.head.frstr[TPLIBINF]);
	_cut(__rsc.head.frstr[TPLIBMEM]);
	_cut(__rsc.head.frstr[TPLIBFNT]);
	_cut(__rsc.head.frstr[TPLIBOPT]);
	_cut(__rsc.head.frstr[TPLIBSYS]);
	_cut(__rsc.head.frstr[TPLIBCNF]);
	_cut(__rsc.head.frstr[TPLIBHLP]);
	_cut(__rsc.head.frstr[TPHLPIND]);
	_cut(__rsc.head.frstr[TPHLPDN]);
	_cut(__rsc.head.frstr[TPHLPUP]);
	_cut(__rsc.head.frstr[WINF]);
	_cut(__rsc.head.frstr[WMEM]);
	_cut(__rsc.head.frstr[WFNT]);
	_cut(__rsc.head.frstr[WOPT]);
	_cut(__rsc.head.frstr[WSYS]);
	_cut(__rsc.head.frstr[WHLP]);
}

void _cut(char *txt)
{
	char		*p=txt;

	while (*p!=0)
	{
		if (*p=='|')
			*p=0;
		p++;
	}
}

char *_getLang(char *txt)
{
	char		*p;
	int		i;

	p=txt;
	for (i=0;i<glb.opt.lang;i++)
	{
		while (*p!=0)
			p++;
		p++;
	}
	return p;
}

char *_putSpec(OBJECT *tree,int n,char *txt)
{
	UBLK		*user;
	char		*p=NULL;

	switch (tree[n].ob_type&0xFF)
	{
		case	G_USERDEF:
			user=(UBLK *)tree[n].ob_spec.userblk->ub_parm;
			switch	(user->type)
			{
				case	G_TITLE:
				case	G_STRING:
				case	G_BUTTON:
					p=(char *)user->spec;
					user->spec=(long)_getLang(txt);
					break;
				case	G_TEXT:
				case	G_BOXTEXT:
					p=(char *)((TEDINFO *)user->spec)->te_ptext;
					(((TEDINFO *)user->spec)->te_ptext)=_getLang(txt);
					break;
			}
			break;
		case	G_TITLE:
		case	G_STRING:
		case	G_BUTTON:
			p=(char *)tree[n].ob_spec.free_string;
			tree[n].ob_spec.free_string=_getLang(txt);
			break;

		case	G_TEXT:
		case	G_BOXTEXT:
		case	G_FTEXT:
		case	G_FBOXTEXT:
			p=(char *)tree[n].ob_spec.tedinfo->te_ptext;
			tree[n].ob_spec.tedinfo->te_ptext=_getLang(txt);
			break;
	}
	return p;
}
