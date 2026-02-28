/* **[Offscreen]**************** */
/* *                           * */
/* * 31/12/2015 MaJ 31/01/2016 * */
/* ***************************** */




#include "bench_stram_ecran.c"
#include "bench_ttram_ecran.c"
#include "bench_vdi_ecran.c"

#include "bench_stram_stram.c"
#include "bench_ttram_ttram.c"
#include "bench_vdi_vdi.c"
#include "bench_vdi_vdi2.c"
#include "bench_ecran_ecran.c"

#include "bench_ct60_vram_ecran.c"
#include "bench_ct60_ct60_vram.c"





void gestion_fenetre_bench( int16 controlkey, int16 touche, int16 bouton );




void gestion_fenetre_bench( int16 controlkey, int16 touche, int16 bouton )
{

	OBJECT	*adr_formulaire;
	int16	objet;
/*	int16	valeur=0;*/
	int16	commande=0;


	/* suppression warning */
	objet=controlkey+touche;




	/* on cherche l'adresse du formulaire */
	rsrc_gaddr( R_TREE, DL_BENCH, &adr_formulaire );

	objet = objc_find(adr_formulaire,0,4,souris.g_x,souris.g_y);




/*	{
		char texte[256];


		sprintf(texte,"gestion_fenetre_bench() Timer = %ld     ", Fcm_get_timer() );
		v_gtext(vdihandle,78*8,1*16, texte);
	}*/


	if( bouton )
	{
		switch( objet )
		{
			case BC_STRAM_ECR:
				commande=1;
				break;

			case BC_TTRAM_ECR:
				commande=2;
				break;

			case BC_OFF_ECR:
				commande=3;
				break;

			case BC_CT060_ECR:
				commande=10;
				break;





			case BC_STRAM_STRAM:
				commande=4;
				break;

			case BC_TTRAM_TTRAM:
				commande=5;
				break;

			case BC_OFF_OFF:
				commande=6;
				break;

			case BC_OFF_OFF2:
				commande=7;
				break;

			case BC_ECR_ECR:
				commande=8;
				break;

			case BC_CT060_CT060:
				commande=11;
				break;

			case BC_ALL_TEST:
				commande=9;
				break;
		}
	}





	if( commande==1 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_STRAM_ECR ) == BC_STRAM_ECR )
		{
			bench_stram_ecran();
		}
	}

	if( commande==2 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_TTRAM_ECR ) == BC_TTRAM_ECR )
		{
			bench_ttram_ecran();
		}
	}
	if( commande==3 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_OFF_ECR ) == BC_OFF_ECR )
		{
			bench_vdi_ecran();
		}
	}


	if( commande==4 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_STRAM_STRAM ) == BC_STRAM_STRAM )
		{
			bench_stram_stram();
		}
	}
	if( commande==5 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_TTRAM_TTRAM ) == BC_TTRAM_TTRAM )
		{
			bench_ttram_ttram();
		}
	}
	if( commande==6 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_OFF_OFF ) == BC_OFF_OFF )
		{
			bench_vdi_vdi();
		}
	}
	if( commande==7 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_OFF_OFF2 ) == BC_OFF_OFF2 )
		{
			bench_vdi_vdi2();
		}
	}
	if( commande==8 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_ECR_ECR ) == BC_ECR_ECR )
		{
			bench_ecran_ecran();
		}
	}


	if( commande==10 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_CT060_ECR ) == BC_CT060_ECR )
		{
			bench_ct60_vram_ecran();
		}
	}


	if( commande==11 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_CT060_CT060 ) == BC_CT060_CT060 )
		{
			bench_ct60_ct60_vram();
		}
	}


	if( commande==9 )
	{
		if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_BENCH], BC_ALL_TEST ) == BC_ALL_TEST )
		{
			if( gb_mode_stram_actif == TRUE )
			{
				bench_stram_ecran();
			}

			if( gb_mode_ttram_actif == TRUE )
			{
				bench_ttram_ecran();
			}

			if( gb_mode_vdi_actif==TRUE )
			{
				bench_vdi_ecran();
			}

			if( gb_mode_ct60_vram_actif==TRUE )
			{
				bench_ct60_vram_ecran();
			}





			if( gb_mode_stram_actif == TRUE )
			{
				bench_stram_stram();
			}

			if( gb_mode_ttram_actif == TRUE )
			{
				bench_ttram_ttram();
			}

			if( gb_mode_vdi_actif == TRUE )
			{
				bench_vdi_vdi();
				bench_vdi_vdi2();
			}

			if( gb_mode_vram_actif == TRUE )
			{
				bench_ecran_ecran();
			}

			if( gb_mode_ct60_vram_actif==TRUE )
			{
				bench_ct60_ct60_vram();
			}

		}
	}




	return;


}

