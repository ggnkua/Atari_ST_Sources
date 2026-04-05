/* ***************************** */
/* *                           * */
/* * 19/06/2020 MaJ 19/06/2020 * */
/* ***************************** */




#ifndef ___Fcm_affiche_mfdb___
#define ___Fcm_affiche_mfdb___


void Fcm_affiche_mfdb( int16 x, int16 y, MFDB *mfdb );




void Fcm_affiche_mfdb( int16 x, int16 y, MFDB *mfdb )
{
	int16 txy[8];


	txy[0] = 0;
	txy[1] = 0;
	txy[2] = mfdb->fd_w - 1;
	txy[3] = mfdb->fd_h - 1;

	txy[4] = x;
	txy[5] = y;
	txy[6] = txy[4]+txy[2];
	txy[7] = txy[5]+txy[3];

	vro_cpyfm(vdihandle, S_ONLY, txy, mfdb, &Fcm_mfdb_ecran);

}



#endif /*  ___Fcm_affiche_mfdb___  */


