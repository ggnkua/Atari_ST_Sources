/* ************************************* */
/* * Conversion WORD intel en Motorola * */
/* *     11/05/2002 = 02/03/2013       * */
/* ************************************* */

/* Prototype */
UWORD fcm_word_intel2motorola( UWORD valeur );


/* Fonction */
UWORD fcm_word_intel2motorola( UWORD valeur )
{
	UWORD	dummy;


	/* valeur =                    LSB  MSB */
	dummy  = valeur &  0x00FF;  /* 00   MSB */
	valeur = valeur >> 8;		/* 00   LSB */
	dummy  = dummy  << 8;		/* MSB  00  */

	valeur=valeur+dummy;		/* MSB  LSB */


/*	sprintf(texte," Offset IFD : %lx  ",*pt_long );
	v_gtext(vdihandle,40*8,2*16,texte);
*/


	return( valeur );

}
