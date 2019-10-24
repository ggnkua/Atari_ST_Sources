#include <vdi.h>
#include <string.h>
VDIPB vdipb = {0};

/* #[ Prototypages :																							*/
void xv_opnwk (int *handle, int width, int height);
void xv_updwk (int handle, int *buffer);
/* #] Prototypages :																							*/ 

/* #[ xv_opnwk () Ouverture station :															*/
void xv_opnwk (int *handle, int width, int height)
{
	if (vdipb.contrl == 0)	/* Pointer sur les tableaux */
	{
		vdipb.contrl = _VDIParBlk.contrl;
		vdipb.intin = _VDIParBlk.intin;
		vdipb.ptsin = _VDIParBlk.ptsin;
		vdipb.intout = _VDIParBlk.intout;
		vdipb.ptsout = _VDIParBlk.ptsout;
	}

	_VDIParBlk.contrl[0] = 1;				/* Opcode fonction */
	_VDIParBlk.contrl[1] = 1;				/* Nbre de paires de donn‚es ptsin */
	_VDIParBlk.ptsin[0] = width;		/* Largeur */
	_VDIParBlk.ptsin[1] = height;		/* Hauteur */

	_VDIParBlk.contrl[3] = 11;			/* Longueur tableau intin */
	vdi (&vdipb);										/* Appel fonction */
	*handle = _VDIParBlk.contrl[6];	/* R‚cup‚rer le handle */
}
/* #] xv_opnwk () Ouverture station :															*/ 
/* #[ xv_updwk () Ex‚cuter station :															*/
void xv_updwk (int handle, int *buffer)
{
	if (vdipb.contrl == 0)	/* Pointer sur les tableaux */
	{
		vdipb.contrl = _VDIParBlk.contrl;
		vdipb.intin = _VDIParBlk.intin;
		vdipb.ptsin = _VDIParBlk.ptsin;
		vdipb.intout = _VDIParBlk.intout;
		vdipb.ptsout = _VDIParBlk.ptsout;
	}

	_VDIParBlk.contrl[0] = 4;				/* Opcode fonction */

	_VDIParBlk.contrl[1] = 1;				/* Ne pas effacer le buffer */
	_VDIParBlk.contrl[3] = 2;				/* Nbre de coordonn‚es intin */
	_VDIParBlk.intin[0] = (int)((long)buffer >> 16);		/* Mot fort de l'adresse */
	_VDIParBlk.intin[1] = (int)((long)buffer & 0xFFFF);	/* Mot faible de l'adresse */

	_VDIParBlk.contrl[6] = handle;	/* Handle station */
	vdi (&vdipb);										/* Appel fonction */
}
/* #] xv_updwk () Ex‚cuter station :															*/ 

