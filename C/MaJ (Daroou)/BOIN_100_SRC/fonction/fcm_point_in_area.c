/* **[Fonction xxxxxx]********** */
/* *                           * */
/* * 02/01/2013 MaJ 02/03/2024 * */
/* ***************************** */


/* Qui utilise cette fonction ? le Coeur non... */



/*
 * Regarde si le point R1 est pr‚sent dans R2
 * Retourne 1 si R2 contient R1, 0 sinon.
 *
 */
 
 
 
 

int16 Fcm_point_in_area ( const GRECT *r1, const GRECT *r2)
{
	int16 tx, ty, tw, th;


	FCM_LOG_PRINT("#Fcm_point_in_area()");


	/*
	 * Version modifi‚ de Fcm_rc_intersect()
	 * point r1(x,y) … regarder s'il est pr‚sent
	 * dans zone r2(x,y,w,h)
	 *
	 */

	tw = MIN(r2->g_x + r2->g_w, r1->g_x);
	th = MIN(r2->g_y + r2->g_h, r1->g_y);
	tx = MAX(r2->g_x, r1->g_x);
	ty = MAX(r2->g_y, r1->g_y);


	return ((tw==tx) && (th==ty));


}

