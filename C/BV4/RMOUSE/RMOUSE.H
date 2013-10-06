/*******************************************************************************
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or any later version.
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
	more details.
	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	675 Mass Ave, Cambridge, MA 02139, USA.
*******************************************************************************/


/*******************************************************************************
	Structure d'appel
*******************************************************************************/
typedef struct
{
	unsigned int	*x;		/*	x position		*/
	unsigned int	*y;		/*	y position		*/
	unsigned int	*k;		/*	buttons state	*/
}	RMOUSE;


/*******************************************************************************
	Prototypage des fonctions
*******************************************************************************/
void	RMOUSE_ON(RMOUSE *adr);
void	RMOUSE_OFF(void);
