/* **[Pupul]******************** */
/* * 30/01/2013 MaJ 05/02/2015 * */
/* ***************************** */




#ifndef ___Fcm_transfert_surface_to_mfdb___
#define ___Fcm_transfert_surface_to_mfdb___




void Fcm_transfert_surface_to_mfdb( s_tga_ldg *image, MFDB* mfdb  );




/* Fonction */
void Fcm_transfert_surface_to_mfdb( s_tga_ldg *image, MFDB* mfdb  )
{
	MFDB  mfdb_tga;
	int16 pxy[8];


	mfdb_tga.fd_addr=(uint32 *)image->adr_decode;
	mfdb_tga.fd_w=image->frame_width;
	mfdb_tga.fd_h=image->frame_height;
	mfdb_tga.fd_wdwidth=(mfdb_tga.fd_w+15)/16;
	mfdb_tga.fd_stand=0;
	mfdb_tga.fd_nplanes=mfdb->fd_nplanes;
	mfdb_tga.fd_r1=0;
	mfdb_tga.fd_r2=0;
	mfdb_tga.fd_r3=0;


	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=image->frame_width-1;
	pxy[3]=image->frame_height-1;


	pxy[4]=0;
	pxy[5]=0;
	pxy[6]=/*pxy[4]+*/pxy[2];
	pxy[7]=/*pxy[5]+*/pxy[3];


	vro_cpyfm(vdihandle,3,pxy,&mfdb_tga, mfdb);


	return;


}



#endif


