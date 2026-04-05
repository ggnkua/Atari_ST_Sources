/*******************************************************************/
/*                                                                 */
/*                     TGA_SA.LDG    version 0.13                  */
/*                     TGA_SA_LDG.H  version 0.14                  */
/*                       Daroou / Renaissance                      */
/*                                                                 */
/* --------------------------------------------------------------- */
/* Cr‚e le: 29.01.2013                                             */
/* modification le: 24.09.2023                                     */
/*******************************************************************/


#ifndef  __TGA_SA_LDG__
 #define __TGA_SA_LDG__

 #include <ldg.h>


 #define  TGA_VDI_ALIGN16   (16)


 #define  TGA_LDG_ERROR     (1L)
 #define  TGA_LDG_NO_ERROR  (0L)


 #ifndef int32
  #define int32	 long
 #endif
 #ifndef uint32
  #define uint32 unsigned long
 #endif
 #ifndef int16
  #define int16	 short
 #endif
 #ifndef uint16
  #define uint16 unsigned short
 #endif
 #ifndef int8
  #define int8	 char
 #endif
 #ifndef uint8
  #define uint8	 unsigned char
 #endif


/* format des donn‚es de la palette pour le mode 8 bits */
typedef struct
{
	uint16		red;
	uint16		green;
	uint16		blue;
} s_tga_palette;


/* structure … transmettre en parametre des fonctions de TGA.LDG */
typedef struct
{
	uint32          adr_source;		/* adresse o— a ‚t‚ charg‚ le fichier TGA */
	uint32          source_size;	/* taille en octet du fichier TGA */
	uint32          adr_decode;		/* adresse o— sera d‚cod‚ l'image */
	uint32          decode_size;	/* taille en octet de l'image d‚cod‚ */
	uint16          width;			/* largeur de l'image en pixel */
	uint16          height;			/* hauteur de l'image en pixel */
	uint16          frame_width;	/* largeur du cadre de l'image en pixel */
	uint16          frame_height;	/* hauteur du cadre de l'image en pixel */
	uint16          format_need;	/* format pixel souhait‚, au choix P8/TC15/16/24/32 Falcon/intel/Motorola */
	uint16          vdi_align16;	/* alignement sur un multiple de 16 pixels (VDI vr*() ) ou non */
	s_tga_palette   palette[256];   /* Palette pour la conversion en 8 bits */
	int8	        txt_id[256];	/* Champ d'identification de l'image (si existant) */
	uint16          tga_free_flag;  /* flag pour indiquer que la ram doit être libere par TGA_free() */
	uint16          nb_col_palette; /* nombre de couleur dans la palette 16 ou 256 */
} s_tga_ldg;


/* prototypes des fonctions de la LDG */
int32 CDECL (*TGA_getinfo               ) ( s_tga_ldg *image );
int32 CDECL (*TGA_decode                ) ( s_tga_ldg *image );
int32 CDECL (*TGA_load                  ) ( char *tga_file, s_tga_ldg *image );
int32 CDECL (*TGA_free                  ) ( s_tga_ldg *image );
int32 CDECL (*Conversion_packed_to_plan ) ( s_tga_ldg *image );
int32 CDECL (*TGA_SA_8packed_to_4plan   ) ( s_tga_ldg *image );

/* handle Global pour la LDG */
LDG	*ldg_TGA=NULL;


/* prototype fonction d'initialisation de la LDG */
int32  open_LDG_TGA( int16 *ldg_version );
void   close_LDG_TGA( void );






/* fonction d'initialisation de la LDG
 *
 * En cas d'erreur, la LDG est referm‚ et un code d'erreur
 * est retourn‚ par la fonction. Voir message d'erreur dans
 * la Documention LDG, … 'ldg_error()' et la doc de la LDG.
 *
 * Renvoi 0L (TGA_LDG_NO_ERROR) en cas de succŠs...
 *
 */
int32 open_LDG_TGA( int16 *ldg_TGA_SA_version )
{
	extern 	LDG    *ldg_TGA;
			int32   erreur=TGA_LDG_NO_ERROR;


	ldg_TGA=ldg_open( "TGA_SA.LDG", ldg_global ); /* ldg_global d‚fini dans LDG.H */
	

	if( ldg_TGA==NULL )
	{
		/* un problŠme avec le chargement de la LDG */
		return( ldg_error() );
	}



	/* version de la LDG */
	*ldg_TGA_SA_version = ldg_TGA->vers;



	/* Recherche des fonctions dans la LDG */

#undef RECHERCHE_FONCTION

#define RECHERCHE_FONCTION(fonction) \
	fonction = ldg_find(#fonction, ldg_TGA); \
	if (fonction == 0) erreur = TGA_LDG_ERROR

	
	RECHERCHE_FONCTION(TGA_getinfo);
	RECHERCHE_FONCTION(TGA_decode);
	RECHERCHE_FONCTION(TGA_load);
	RECHERCHE_FONCTION(TGA_free);
	RECHERCHE_FONCTION(Conversion_packed_to_plan);
	RECHERCHE_FONCTION(TGA_SA_8packed_to_4plan);
	
#undef RECHERCHE_FONCTION



/*	TGA_getinfo  = ldg_find( "TGA_getinfo",  ldg_TGA );
	if( !TGA_getinfo )  erreur=TGA_LDG_ERROR;

	TGA_decode   = ldg_find( "TGA_decode",   ldg_TGA );
	if( !TGA_decode )    erreur=TGA_LDG_ERROR;

	TGA_load     = ldg_find( "TGA_load",     ldg_TGA );
	if( !TGA_load )      erreur=TGA_LDG_ERROR;

	TGA_free     = ldg_find( "TGA_free",     ldg_TGA );
	if( !TGA_free )      erreur=TGA_LDG_ERROR;

	Conversion_packed_to_plan = ldg_find( "Conversion_packed_to_plan", ldg_TGA );
	if( !Conversion_packed_to_plan )      erreur=TGA_LDG_ERROR;

	TGA_SA_8packed_to_4plan = ldg_find( "TGA_SA_8packed_to_4plan", ldg_TGA );
	if( !TGA_SA_8packed_to_4plan )      erreur=TGA_LDG_ERROR;
*/

	/* Si une erreur s'est produite ... */
	if( erreur==TGA_LDG_ERROR )
	{
		ldg_close( ldg_TGA, ldg_global);
		return( LDG_NO_FUNC );
	}


	return TGA_LDG_NO_ERROR;


}





/* Fermeture de la LDG */
void close_LDG_TGA( void )
{
	/* ldg_global est d‚fini dans LDG.H */
	extern 	LDG    *ldg_TGA;


	ldg_close( ldg_TGA, ldg_global);

	return;

}



#endif	/* #ifndef __TGA_SA_LDG__ */

