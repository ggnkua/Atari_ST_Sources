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
/*	FUNCTIONS TO HANDLE SIGNALS																*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/

#include		"EG_MAIN.H"

/******************************************************************************/
/*	Inits signals																					*/
/******************************************************************************/
void _initSIG()
{
	int		i;

	if (_cookie('MiNT')>0)
	{
		for (i=0;i<NSIG;i++)
			glb.sig[i]=(long)SIG_DFL;
		glb.sig[SIGHUP]	=	(long)_sigQUIT;
		glb.sig[SIGINT]	=	(long)_sigQUIT;
		glb.sig[SIGQUIT]	=	(long)_sigQUIT;
		glb.sig[SIGILL]	=	(long)_sigQUIT;
		glb.sig[SIGABRT]	=	(long)_sigQUIT;
		glb.sig[SIGPRIV]	=	(long)_sigQUIT;
		glb.sig[SIGBUS]	=	(long)_sigQUIT;
		glb.sig[SIGSEGV]	=	(long)_sigQUIT;
		glb.sig[SIGPIPE]	=	(long)_sigQUIT;
		glb.sig[SIGTERM]	=	(long)_sigQUIT;
		glb.sig[SIGXCPU]	=	(long)_sigQUIT;

		if (glb.FinitSig!=0)
			(*glb.FinitSig)();

		for (i=0;i<NSIG;i++)
			Psignal(i,glb.sig[i]);
	}
}


/******************************************************************************/
/*	Handles QUIT signals																			*/
/******************************************************************************/
#pragma warn -par
void _sigQUIT(long ptr)
{
	glb.Exit=3;
}
#pragma warn +par
