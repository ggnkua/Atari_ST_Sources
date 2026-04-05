/* **[Pupul]******************** */
/* * 30/01/2013 MaJ 14/07/2017 * */
/* ***************************** */




#ifndef ___Fcm_transfert_surface_to_mfdb___
#define ___Fcm_transfert_surface_to_mfdb___

#ifndef PAS_DE_WARNING
#warning "Ne plus utiliser cette fonction, => utiliser Fcm_transfert_image_to_mfdb (juste un renommage de fonction"
#endif


void Fcm_transfert_surface_to_mfdb( s_tga_ldg *image, MFDB* mfdb  );




/* Fonction */
void Fcm_transfert_surface_to_mfdb( s_tga_ldg *image, MFDB* mfdb  )
{
	MFDB  mfdb_temp;


	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_transfert_surface_to_mfdb(%p, %p)"CRLF, image, mfdb );
	log_print(FALSE);
	#endif

	mfdb_temp.fd_addr    = (uint32 *)image->adr_decode;
	mfdb_temp.fd_w       = (int16)image->frame_width;
	mfdb_temp.fd_h       = (int16)image->frame_height;
	mfdb_temp.fd_wdwidth = (mfdb_temp.fd_w+15)/16;
	mfdb_temp.fd_stand   = 0;
	mfdb_temp.fd_nplanes = mfdb->fd_nplanes;
	mfdb_temp.fd_r1      = 0;
	mfdb_temp.fd_r2      = 0;
	mfdb_temp.fd_r3      = 0;


	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=mfdb_temp.fd_w-1;
	pxy[3]=mfdb_temp.fd_h-1;


	pxy[4]=0;
	pxy[5]=0;
	pxy[6]=pxy[2];
	pxy[7]=pxy[3];


	vro_cpyfm(vdihandle,3,pxy,&mfdb_temp, mfdb);
	/*vro_cpyfm(vdihandle,3,pxy,&mfdb_temp, &Fcm_mfdb_ecran);*/


	return;


}



#endif


