/*=================================*/
/* Fput                            */
/* 25/10/2001 # 25/10/2002         */
/*_________________________________*/

LONG fput( LONG handle, ULONG adresse, ULONG nombre)
{
		LONG	nombre_sauver;
		LONG	reponse=0;
/*		LONG	dummy;*/
		CHAR	*pt_char;


/*	sprintf(texte,"Nom fichier = %s  ",nom_fichier);
	v_gtext(vdihandle,1*8,10*16,texte);
	sprintf(texte,"adresse = %ld  ",(LONG)adresse);
	v_gtext(vdihandle,1*8,11*16,texte);
	sprintf(texte,"saut = %ld  ",saut);
	v_gtext(vdihandle,1*8,12*16,texte);
	sprintf(texte,"nombre = %ld  ",nombre);
	v_gtext(vdihandle,1*8,13*16,texte);
*/
		pt_char=(CHAR *)adresse;

		do
		{
			nombre_sauver=Fwrite( handle, nombre, pt_char );
			if(nombre_sauver<0)
			{
				nombre=0;
				reponse=-1;
			}
			else
			{
				nombre=nombre-nombre_sauver;
				adresse=adresse+nombre_sauver;
				reponse=reponse+nombre_sauver;
			}

/*			sprintf(texte,"Nombre charger = %ld",nombre_charger);
			v_gtext(vdihandle,1*8,16*16,texte);
			sprintf(texte,"Valeur dummy   = %ld",dummy);
			v_gtext(vdihandle,1*8,17*16,texte);
*/
		} while( nombre );



/*	sprintf(texte,"** reponse = %ld",reponse);
	v_gtext(vdihandle,1*8,17*16,texte);
*/

	return(reponse);

}
