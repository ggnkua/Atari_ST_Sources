/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997 - 2000
 *
 *	module: inquire.c
 *	description: fonctions interrogation du systŠme
 */

#include <stddef.h>
#include <string.h>
#include "globals.h"
#include "cookie.h"

/* Get the definition of OSHEADER for vq_tos() */
#ifdef __SOZOBONX__
	#include <osheader.h>
	#define SYSHDR	OSHEADER
#else
	#ifdef __GNUC__
		#include <sysvars.h>
		#define SYSHDR	OSHEADER
 	#endif 
#endif

/*
 * appl_getinfo () accessible avec:
 * AES 4.00 (multitos,n_aes,geneva)
 * MagiC 3, Wdialog
 * WinX 2.2
 */

int has_appl_getinfo( void) {
	INT16 ign;
	
	if( _AESversion >= 0x0400    || 	/* AES 4 */
		appl_find( "?AGI") != -1 ||		/* MagiC >= 3 ou Wdialog ou winX >= 2.3 
										 * il semble que se soit la m‚thode officielle
										 * pour tester la pr‚sence de appl_getinfo(),
										 * ATTENTION : WinX  2.3 : "?AGI    " */
		/* et pour WinX >= 2.1 */
		( wind_get( 0, 1, &ign, &ign, &ign, &ign) == 0 &&				/* on v‚rifie que wind_set() accepte les valeurs non l‚gales */
		  wind_get( 0, WF_WINX, &ign, &ign, &ign, &ign) == WF_WINX))	/* et on teste la pr‚sence de WinX */
		return 1;
	else
		return 0;
}

/********************* TOS  ***************************/

static 
long syshead( void) {
	return (long)*((SYSHDR **)0x04f2L);
}

/*
 * return TOS version
 */

int vq_tos( void) {
	SYSHDR *sys = (SYSHDR *) Supexec( syshead);
	return sys->os_version;
}

/*
 * teste si une partition (un chemin) supporte les noms longs
 */

int vq_extfs( char *path) {
	int vq_magx(void);
	long n, vers;
	
	if( vq_magx() >= 0x500 ||
		(get_cookie( MiNT_COOKIE,(LONG *)&vers) && vers>=0x90L)) {
		if( path[1] != ':') {
			/* Prendre le chemin courant */
			char newpath[255];
			
			newpath[0] = Dgetdrv() + 'A';
			newpath[1] = ':';
			Dgetpath( newpath+2, 0);
			strcat( newpath, "\\");
			strcat( newpath, path);
			n = Dpathconf( newpath, 3 /*DP_NAMEMAX*/);
		} else
			n = Dpathconf( path, 3 /*DP_NAMEMAX*/);
		if( n>=32) return 1;
	}
	return 0;
}

/********************* WinX ***************************/

/* Test la version de WinX */

int vq_winx( void) {
	if( get_cookie( WINX_COOKIE, NULL))	{
		struct winx_version {
				unsigned int beta  :4;
				unsigned int major :4;
				unsigned int minor :4;
				unsigned int intern:4;
			} vers;
		INT16 dummy;
		
		if( wind_get( 0, WF_WINX, (INT16*)&vers, &dummy, &dummy, &dummy) == WF_WINX)
			return ((vers.major << 8) | vers.minor);
		else
			/* version ant‚rieur … la 2.1 */
			return 0x0100;
	} else
		return 0;	/* WinX pas en m‚moire */
}

/********************* Naes Binding ************************/

int vq_naes( void) {
	N_AESINFO *naes;

	if( get_cookie( NAES_COOKIE,(LONG *)&naes))
		return naes->version;
	else
		return 0;
}

/********************* MagiC Binding ************************/

/*
 *	Interroge la version de MagX!
 */

int vq_magx( void) {
	MAGX_INFOS *cv;

	if( get_cookie( MAGX_COOKIE,(LONG *)&cv) && cv->aesvars)
		return cv->aesvars->version;
	else
		return 0;
}


/******** NVDI/SPEEDO BINDING ***************/

/*
 * Teste la pr‚sence de NVDI, retourne la version
 */

int vq_nvdi( void) {
	NVDI_STRUC *nvdi;
	
	if( get_cookie( NVDI_COOKIE, (long*)&nvdi))
		return nvdi->version;
	return 0;	/* pas de nvdi */
}


/*
 *	Fonction inspir‚e de la doc d‚veloppeur NVDI 4  qui
 *	intŠgre les sp‚cifit‚s de Speedo (caractŠre 33) et 
 *  celles de NVDI (caractŠre 34).
 */

/* pre   name : buffer de 33 octets 
 * post  voir vqt_ext_name 
 */

int vqt_extname( int handle, int index, char *name, 
				 int *speedo, INT16 *format, INT16 *flags ) {
	int res;

	res = vqt_ext_name ( handle, index, name, format, flags);	
	*speedo = name[32];
	name[32] = '\0';
	
  	return( res);
}

