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
	Renvoie adresse du IFX en m‚moire
*******************************************************************************/
PARX_IFX *_ifxAdr(int n)
{
	long	adr;
	int	i;

	if (n>glb.parx.n_ifx)
		return NULL;
	else
	{
		adr=glb.mem.adr[glb.parx.i_ifx];
		for (i=0;i<n;i++)
			adr+=*(long *)adr;
	}
	return (PARX_IFX *)adr;
}
