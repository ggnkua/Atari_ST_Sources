/* ***************************** */
/* * 19/03/2015 MaJ 19/03/2015 * */
/* ***************************** */



#ifndef ___Fcm_intersection_zone___
#define ___Fcm_intersection_zone___



int16 Fcm_intersection_zone( const GRECT *r1, const GRECT *r2 );



/* Fonction */
int16 Fcm_intersection_zone( const GRECT *r1, const GRECT *r2 )
{

	if( MAX(r1->g_x, r2->g_x) < MIN(r1->g_x+r1->g_w, r2->g_x+r2->g_w) )
	{

		if( MAX(r1->g_y, r2->g_y) < MIN(r1->g_y+r1->g_h , r2->g_y+r2->g_h) )
		{
			return(TRUE);
		}
	}

	return(FALSE);

}



#endif /* ___Fcm_intersection_zone___ */


