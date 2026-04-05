



#ifndef ___FCMGFX_AFFICHE_MFDB___
#define ___FCMGFX_AFFICHE_MFDB___

#include "vrx_sprite_mode.h"




void Fcmgfx_affiche_mfdb_sprite_opaque( MFDB *mfdb, int16 x, int16 y );
void Fcmgfx_affiche_mfdb_sprite_mask( MFDB *mfdb, int16 x, int16 y );
void Fcmgfx_affiche_mfdb_sprite_opaque_mono( MFDB *mfdb, int16 x, int16 y );
void Fcmgfx_affiche_mfdb_sprite_mono( MFDB *mfdb, int16 x, int16 y );



void Fcmgfx_affiche_mfdb_sprite_opaque( MFDB *mfdb, int16 x, int16 y )
{

	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=mfdb->fd_w-1;
	pxy[3]=mfdb->fd_h-1;
	pxy[4]=x;
	pxy[5]=y;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	pxy[6]=MIN( pxy[6], (Fcm_screen.w_desktop-1) );
	pxy[7]=MIN( pxy[7], (Fcm_screen.h_desktop-1) );
	
	vro_cpyfm(vdihandle,VRO_COPY_MODE,pxy,  mfdb, &Fcm_mfdb_ecran);
	
	return;
}


void Fcmgfx_affiche_mfdb_sprite_mask( MFDB *mfdb, int16 x, int16 y )
{
	int16  local_couleur_mask_vrt[2];



	local_couleur_mask_vrt[0] = 0;
	local_couleur_mask_vrt[1] = 1;

	if(  Fcm_screen.nb_plan>8 /*&& global_affichage_mode==AFFICHAGE_MODE_COULEUR*/ )
	{
		local_couleur_mask_vrt[0] = 1;
		local_couleur_mask_vrt[1] = 0;
	}


	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=mfdb->fd_w-1;
	pxy[3]=mfdb->fd_h-1;
	pxy[4]=x;
	pxy[5]=y;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	pxy[6]=MIN( pxy[6], (Fcm_screen.w_desktop-1) );
	pxy[7]=MIN( pxy[7], (Fcm_screen.h_desktop-1) );

	vrt_cpyfm(vdihandle,VRT_MASQUE_MODE,pxy, mfdb, &Fcm_mfdb_ecran, local_couleur_mask_vrt);

	return;
}




void Fcmgfx_affiche_mfdb_sprite_opaque_mono( MFDB *mfdb, int16 x, int16 y )
{
	int16  local_couleur_vrt_copy[2];


	local_couleur_vrt_copy[0]=1;
	local_couleur_vrt_copy[1]=0;

	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=mfdb->fd_w-1;
	pxy[3]=mfdb->fd_h-1;
	pxy[4]=x;
	pxy[5]=y;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	pxy[6]=MIN( pxy[6], (Fcm_screen.w_desktop-1) );
	pxy[7]=MIN( pxy[7], (Fcm_screen.h_desktop-1) );

	vrt_cpyfm(vdihandle,VRT_COPY_MODE,pxy,  mfdb, &Fcm_mfdb_ecran, local_couleur_vrt_copy);
	
	return;
}


void Fcmgfx_affiche_mfdb_sprite_mono( MFDB *mfdb, int16 x, int16 y )
{
	int16  local_couleur_mask_vrt[2];


	local_couleur_mask_vrt[0] = 0;
	local_couleur_mask_vrt[1] = 1;

	if(  Fcm_screen.nb_plan>8 /*&& global_affichage_mode==AFFICHAGE_MODE_COULEUR*/ )
	{
		local_couleur_mask_vrt[0] = 1;
		local_couleur_mask_vrt[1] = 0;
	}


	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=mfdb->fd_w-1;
	pxy[3]=mfdb->fd_h-1;
	pxy[4]=x;
	pxy[5]=y;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	pxy[6]=MIN( pxy[6], (Fcm_screen.w_desktop-1) );
	pxy[7]=MIN( pxy[7], (Fcm_screen.h_desktop-1) );

	vrt_cpyfm(vdihandle,VRT_SPRITE_MODE,pxy,  mfdb, &Fcm_mfdb_ecran, local_couleur_mask_vrt);
	
	return;
}
















#endif

