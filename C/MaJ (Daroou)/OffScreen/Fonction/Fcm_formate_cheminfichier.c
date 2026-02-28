/* ********************************** */
/* * Formate Chemin … xx caractŠres * */
/* * 09/04/2003 = 23/01/2013        * */
/* ********************************** */


/* Prototype */
VOID Fcm_formate_cheminfichier( CHAR *chemin, UWORD taille );


/* Fonction */
VOID Fcm_formate_cheminfichier( CHAR *chemin, UWORD taille )
{

	CHAR	*pt_char1;
	CHAR	*pt_char2;
	WORD	nb_car_coupe;


	#ifdef LOG_FILE
	sprintf( buf_log, " - formatage chemin {%s}"CRLF"   de %ld … %d caractŠre max"CRLF, chemin, strlen(chemin), taille);
	log_print( FALSE );
	#endif


/*	sprintf(texte,"Chemin: {%s} ", chemin );
	v_gtext(vdihandle,4*8,10*16,texte);*/


	/* le chemin est-il plus long ? */
	if( strlen(chemin)>taille && taille>9 )
	{
		WORD nbslash=0;


		/* Nombre caractŠre … supprimer */
		nb_car_coupe=(strlen(chemin)-taille);
		nb_car_coupe=(nb_car_coupe+1) & 0xFFFE;	/* nombre pair */
		nb_car_coupe=nb_car_coupe >> 1; /* div/2 */


		pt_char1=chemin;
		/* on compte le nombre de '\' */
		do
		{
			if(*pt_char1=='\\') nbslash++;
		} while( *pt_char1++ );

		#ifdef LOG_FILE
		sprintf( buf_log, "   %d '\\' trouv‚"CRLF, nbslash);
		log_print( FALSE );
		#endif

		if( nbslash<2 )
		{
			/* on se positionne au mileur de la chaŒne */
			pt_char1=chemin + (taille/2) - nb_car_coupe;
			pt_char2=pt_char1 + (nb_car_coupe<<1) + 3; /* x2+3 */

			/* nos 3 petits points */
			*pt_char1++='.';
			*pt_char1++='.';
			*pt_char1++='.';

			/* on copie le reste de la chaine aprŠs les 3 points */
			strcpy( pt_char1, pt_char2 );

		}
		else
		{

			/* on se place … la fin */
			pt_char2=chemin + strlen(chemin);

			/* on cherche la position du dernier '\' */
			do
			{
			} while( *pt_char2-- != '\\' );
			pt_char2++;	/* correction */


			/* on se positionne au mileur de la chaŒne */
			pt_char1=chemin + ( strlen(chemin)/2 ) + nb_car_coupe;

			if( pt_char1>pt_char2)
			{
				pt_char1=pt_char2-1;
			}

			pt_char2=pt_char1;


			/* on cherche le premier '\' vers la droite */
			do
			{
			} while( *pt_char2++ != '\\' );
			pt_char2--;



			/* tant que la taille n'est pas r‚duite... */
			do
			{
				/* on continuer … chercher un '\' … gauche ... */
				do
				{
				} while( *pt_char1-- != '\\' );


			/* est-ce suffisant ? sinon on continu au prochain '\' … gauche */
			/* 5 => '\...\' */
			} while( ((strlen(chemin)-(pt_char2-pt_char1-5)) > taille) && pt_char1>chemin);


			/* Si on est pas sorti du chemin... */
			if( pt_char1>chemin )
			{
				/* petite corection pour se mettre aprŠs le '\' */
				pt_char1 = pt_char1 + 2;

				/* nos 3 petits points */
				*pt_char1++='.';
				*pt_char1++='.';
				*pt_char1++='.';

				/* et on copie le reste du chemin */
				strcpy( pt_char1, pt_char2 );
			}
		}

	}
	else
	{
		if( strlen(chemin)>taille )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "ERREUR - taille trop petite (%d)"CRLF, taille);
			log_print( FALSE );
			#endif
		}
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "   R‚sultat={%s}"CRLF"   %ld caractŠres"CRLF, chemin, strlen(chemin) );
	log_print( FALSE );
	#endif

	if( strlen(chemin) > taille )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR - formattage ‚chou‚ !!! "CRLF);
		log_print( FALSE );
		#endif

		chemin[taille]='\0';
	}


}

