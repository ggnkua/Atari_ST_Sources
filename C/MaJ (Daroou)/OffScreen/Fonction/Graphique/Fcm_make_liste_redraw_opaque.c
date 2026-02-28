/* ***************************** */
/* *                           * */
/* * 05/11/2015 MaJ 22/11/2015 * */
/* ***************************** */




/* prototype */
void Fcm_make_liste_redraw_opaque( const GRECT *xywh_new, const GRECT *xywh_old, int16 *pxy );



/* Fonction */
void Fcm_make_liste_redraw_opaque( const GRECT *xywh_new, const GRECT *xywh_old, int16 *pxy )
{

	GRECT xywh_zone;
/*	char texte[256];*/


	/* --------------------------------------------------------- */
	/* sprite opaque, il faut restaurer la ou les parties        */
	/* non recouverte par la nouvelle position                   */
	/* --------------------------------------------------------- */


/*	sprintf( texte, "OLD : %3d, %3d, %3d, %3d      ",  xywh_old->g_x, xywh_old->g_y, xywh_old->g_w, xywh_old->g_h );
	v_gtext( vdihandle, 2*8, (16*1), texte);
	sprintf( texte, "NEW : %3d, %3d, %3d, %3d      ",  xywh_new->g_x, xywh_new->g_y, xywh_new->g_w, xywh_new->g_h );
	v_gtext( vdihandle, 2*8, (16*2), texte);


	sprintf( texte, "ECR : %3d, %3d, %3d, %3d      ",  xywh_ecran.g_x, xywh_ecran.g_y, xywh_ecran.g_w, xywh_ecran.g_h );
	v_gtext( vdihandle, 2*8, (16*3), texte);
*/

	if( xywh_old->g_x < xywh_new->g_x )
	{
		xywh_zone.g_x = xywh_old->g_x;
		xywh_zone.g_y = xywh_old->g_y;
		xywh_zone.g_w = xywh_new->g_x - xywh_old->g_x;
		xywh_zone.g_h = xywh_old->g_h;

/*	sprintf( texte, "Z1  : %3d, %3d, %3d, %3d      ",  xywh_zone.g_x, xywh_zone.g_y, xywh_zone.g_w, xywh_zone.g_h );
	v_gtext( vdihandle, 2*8, (16*4), texte);
*/
		if( rc_intersect( &xywh_ecran, &xywh_zone) )
		{
			*(&liste_restaure_fond[nb_liste_restaure_fond]) = *(&xywh_zone);
			nb_liste_restaure_fond++;
		}


		if( xywh_old->g_y < xywh_new->g_y )
		{
			xywh_zone.g_x = xywh_new->g_x;
			xywh_zone.g_y = xywh_old->g_y;
			xywh_zone.g_w = xywh_old->g_x + xywh_old->g_w - xywh_new->g_x;
			xywh_zone.g_h = xywh_new->g_y - xywh_old->g_y;

/*	sprintf( texte, "Z2  : %3d, %3d, %3d, %3d      ",  xywh_zone.g_x, xywh_zone.g_y, xywh_zone.g_w, xywh_zone.g_h );
	v_gtext( vdihandle, 2*8, (16*5), texte);
*/
			if( rc_intersect( &xywh_ecran, &xywh_zone) )
			{
				*(&liste_restaure_fond[nb_liste_restaure_fond]) = *(&xywh_zone);
				nb_liste_restaure_fond++;
			}
		}

		if( xywh_old->g_y > xywh_new->g_y )
		{
			xywh_zone.g_x = xywh_new->g_x;
			xywh_zone.g_y = xywh_new->g_y+xywh_new->g_h;
			xywh_zone.g_w = xywh_old->g_x + xywh_old->g_w - xywh_new->g_x;
			xywh_zone.g_h = (xywh_old->g_y+xywh_old->g_h) - (xywh_new->g_y+xywh_new->g_h);

/*	sprintf( texte, "Z3  : %3d, %3d, %3d, %3d      ",  xywh_zone.g_x, xywh_zone.g_y, xywh_zone.g_w, xywh_zone.g_h );
	v_gtext( vdihandle, 2*8, (16*6), texte);
*/
			if( rc_intersect( &xywh_ecran, &xywh_zone) )
			{
				*(&liste_restaure_fond[nb_liste_restaure_fond]) = *(&xywh_zone);
				nb_liste_restaure_fond++;
			}
		}
	}
















	if( xywh_old->g_x > xywh_new->g_x )
	{
		xywh_zone.g_x = xywh_new->g_x+xywh_new->g_w;
		xywh_zone.g_y = xywh_old->g_y;
		xywh_zone.g_w = (xywh_old->g_x+xywh_old->g_w) - (xywh_new->g_x+xywh_new->g_w);
		xywh_zone.g_h = xywh_old->g_h;

/*	sprintf( texte, "Z1  : %3d, %3d, %3d, %3d      ",  xywh_zone.g_x, xywh_zone.g_y, xywh_zone.g_w, xywh_zone.g_h );
	v_gtext( vdihandle, 2*8, (16*4), texte);
*/
		if( rc_intersect( &xywh_ecran, &xywh_zone) )
		{
			*(&liste_restaure_fond[nb_liste_restaure_fond]) = *(&xywh_zone);
			nb_liste_restaure_fond++;
		}


		if( xywh_old->g_y < xywh_new->g_y )
		{
			xywh_zone.g_x = xywh_old->g_x;
			xywh_zone.g_y = xywh_old->g_y;
			xywh_zone.g_w = (xywh_new->g_x+xywh_new->g_w) - xywh_old->g_x;
			xywh_zone.g_h = xywh_new->g_y - xywh_old->g_y;

/*	sprintf( texte, "Z2  : %3d, %3d, %3d, %3d      ",  xywh_zone.g_x, xywh_zone.g_y, xywh_zone.g_w, xywh_zone.g_h );
	v_gtext( vdihandle, 2*8, (16*5), texte);
*/
			if( rc_intersect( &xywh_ecran, &xywh_zone) )
			{
				*(&liste_restaure_fond[nb_liste_restaure_fond]) = *(&xywh_zone);
				nb_liste_restaure_fond++;
			}
		}

		if( xywh_old->g_y > xywh_new->g_y )
		{
			xywh_zone.g_x = xywh_old->g_x;
			xywh_zone.g_y = xywh_new->g_y+xywh_new->g_h;
			xywh_zone.g_w = (xywh_new->g_x+xywh_new->g_w) - xywh_old->g_x;
			xywh_zone.g_h = (xywh_old->g_y+xywh_old->g_h) - (xywh_new->g_y+xywh_new->g_h);

/*	sprintf( texte, "Z3  : %3d, %3d, %3d, %3d      ",  xywh_zone.g_x, xywh_zone.g_y, xywh_zone.g_w, xywh_zone.g_h );
	v_gtext( vdihandle, 2*8, (16*6), texte);
*/
			if( rc_intersect( &xywh_ecran, &xywh_zone) )
			{
				*(&liste_restaure_fond[nb_liste_restaure_fond]) = *(&xywh_zone);
				nb_liste_restaure_fond++;
			}
		}

	}








	if( xywh_old->g_x == xywh_new->g_x )
	{
		if( xywh_old->g_y < xywh_new->g_y )
		{
			xywh_zone.g_x = xywh_old->g_x;
			xywh_zone.g_y = xywh_old->g_y;
			xywh_zone.g_w = xywh_old->g_w;
			xywh_zone.g_h = xywh_new->g_y - xywh_old->g_y;

/*	sprintf( texte, "Z2  : %3d, %3d, %3d, %3d      ",  xywh_zone.g_x, xywh_zone.g_y, xywh_zone.g_w, xywh_zone.g_h );
	v_gtext( vdihandle, 2*8, (16*5), texte);
*/
			if( rc_intersect( &xywh_ecran, &xywh_zone) )
			{
				*(&liste_restaure_fond[nb_liste_restaure_fond]) = *(&xywh_zone);
				nb_liste_restaure_fond++;
			}
		}

		if( xywh_old->g_y > xywh_new->g_y )
		{
			xywh_zone.g_x = xywh_old->g_x;
			xywh_zone.g_y = xywh_new->g_y+xywh_new->g_h;
			xywh_zone.g_w = xywh_old->g_w;
			xywh_zone.g_h = (xywh_old->g_y+xywh_old->g_h) - (xywh_new->g_y+xywh_new->g_h);

/*	sprintf( texte, "Z3  : %3d, %3d, %3d, %3d      ",  xywh_zone.g_x, xywh_zone.g_y, xywh_zone.g_w, xywh_zone.g_h );
	v_gtext( vdihandle, 2*8, (16*6), texte);
*/
			if( rc_intersect( &xywh_ecran, &xywh_zone) )
			{
				*(&liste_restaure_fond[nb_liste_restaure_fond]) = *(&xywh_zone);
				nb_liste_restaure_fond++;
			}
		}

	}

















	/* --------------------------------------------------------------- */
	/* On calcul la zone d'affichage de la nouvelle position du sprite */
	/* --------------------------------------------------------------- */

	*(&xywh_zone) = *xywh_new;


/*	sprintf( texte, "ZNW  : %3d, %3d, %3d, %3d      ",  xywh_zone.g_x, xywh_zone.g_y, xywh_zone.g_w, xywh_zone.g_h );
	v_gtext( vdihandle, 2*8, (16*6), texte);

	sprintf( texte, "                                   " );
	v_gtext( vdihandle, 2*8, (16*7), texte);
*/
	if( rc_intersect( &xywh_ecran, &xywh_zone) )
	{

/*	sprintf( texte, "construction new coord sprite      " );
	v_gtext( vdihandle, 2*8, (16*7), texte);
*/
		pxy[0] = xywh_zone.g_x - xywh_new->g_x;
		pxy[1] = xywh_zone.g_y - xywh_new->g_y;
		pxy[2] = pxy[0] + xywh_zone.g_w - 1;
		pxy[3] = pxy[1] + xywh_zone.g_h - 1;

		pxy[4] = xywh_zone.g_x;
		pxy[5] = xywh_zone.g_y;
		pxy[6] = pxy[4] + xywh_zone.g_w - 1;
		pxy[7] = pxy[5] + xywh_zone.g_h - 1;

	}
	else
	{
		/* indicateur, le sprite est hors ‚cran, il ne doit pas etre affich‚ */
		pxy[0] = -1;

/*	sprintf( texte, "pas de construction...                 " );
	v_gtext( vdihandle, 2*8, (16*7), texte);
*/
	}




	/* ------------------------------------------------------------------- */
	/* Calcul de la zone ‚cran … r‚afficher                                */
	/* ------------------------------------------------------------------- */
	{
		xywh_zone.g_x = MIN(xywh_old->g_x, xywh_new->g_x );
		xywh_zone.g_y = MIN(xywh_old->g_y, xywh_new->g_y );
	
		xywh_zone.g_w = MAX( (xywh_old->g_x+xywh_old->g_w), (xywh_new->g_x+xywh_new->g_w) ) - xywh_zone.g_x;
		xywh_zone.g_h = MAX( (xywh_old->g_y+xywh_old->g_h), (xywh_new->g_y+xywh_new->g_h) ) - xywh_zone.g_y;

		if( rc_intersect( &xywh_ecran, &xywh_zone) )
		{
			/* si le sprite (ou une partie) est visible … l'‚cran */
			* (&liste_refresh_ecran[nb_liste_refresh_ecran]) = * (&xywh_zone);
			nb_liste_refresh_ecran++;
		}

	}



	return;


}

