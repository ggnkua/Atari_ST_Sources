/* ************************************* */
/* * Conversion Long intel en Motorola * */
/* *     11/05/2002 = 11/05/2002       * */
/* ************************************* */

ULONG long_motorola( ULONG valeur )
{
	ULONG	dummy1;
	ULONG	dummy2;


	dummy1=valeur &  0xFF;
	dummy1=dummy1 <<  24;

	dummy2=valeur & 0xFF00;
	dummy2=dummy2 << 8;

	dummy1=dummy1+dummy2;

	dummy2=valeur & 0xFF0000;
	dummy2=dummy2 >> 8;

	dummy1=dummy1+dummy2;

	valeur=valeur >> 24;
	valeur=valeur+dummy1;

/*	sprintf(texte," Offset IFD : %lx  ",*pt_long );
	v_gtext(vdihandle,40*8,2*16,texte);
*/

	return( valeur );

}
