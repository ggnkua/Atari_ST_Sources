/* ***************************** */
/* *                           * */
/* * 14/11/2023 MaJ 14/11/2023 * */
/* ***************************** */


/*

a inclure dans le code
--------------------------------------

#include "../fonction/graphique/fcm_affiche_texte_ecran.c"



	{
		char mytexte[80];

		snprintf( mytexte, 80, "xxxxxxxxxxxxxxxxxxxxxxxxx %d ", xxxxxxxxxxxxxx );
		Fcm_affiche_texte_ecran(1,1,mytexte);
	}



*/






#ifndef ___Fcm_affiche_texte_ecran___
#define ___Fcm_affiche_texte_ecran___


void Fcm_affiche_texte_ecran( int16 x, int16 y, char *fate_texte );




void Fcm_affiche_texte_ecran( int16 x, int16 y, char *fate_texte )
{
	v_gtext(vdihandle,x*8,y*16,fate_texte);
}



#endif /*  ___Fcm_affiche_texte_ecran___  */


