/*
 *	ME.LDG
 *	compile this file to a ".o" object and link that object
 * in the final link of your application
 *
 * (c)2000 Arnaud BERCEGEAY <bercegeay@atari.org>
 *
 */
 #include <stddef.h>
#include <aes.h>
#include "ldg.h"
#include "me_ldg.h"

/* definitions des pointeurs sur fonctions */

long cdecl (*RIM_OpenImg)(MEIMG * meimg, char * filename, long mode) = NULL;
long cdecl (*RIM_CloseImg)(MEIMG * meimg) = NULL;
long cdecl (*RIM_LoadImg)(MEIMG * meimg, long mode, long no_algo, long vdi_handle, short * global) = NULL;
MELIST* cdecl (*RIM_CreateNewList)( long mode ) = NULL;
void cdecl (*RIM_DeleteList)( MELIST * melist ) = NULL;
long cdecl (*RIM_DoConfig)( char * filename ) = NULL;
MELIST* cdecl (*WIM_CreateNewList)( long mode ) = NULL;
void cdecl (*WIM_DeleteList)( MELIST * melist ) = NULL;
long cdecl (*WIM_DoConfig)( char * filename ) = NULL;
TRMLIST* cdecl (*TRM_CreateNewList)( void ) = NULL;
void cdecl (*TRM_DeleteList)( TRMLIST * trmlist ) = NULL;
void cdecl (*ME_CompressPalette)(char * palette, long size) = NULL;
void cdecl (*ME_ExplainError)( short * global) = NULL;
void cdecl (*ME_Init)( short * global, long mode) = NULL;


/* definition de la structure LDG de me.ldg */

LDG *ldg_me = NULL;


/* initialisation de ces variables */

long init_ldg_me (LDG * ldg_me) 
{
	/* Get function adresses */
	RIM_OpenImg        = ldg_find( "RIM_OpenImg"       ,ldg_me);
	RIM_CloseImg       = ldg_find( "RIM_CloseImg"      ,ldg_me);
	RIM_LoadImg        = ldg_find( "RIM_LoadImg"       ,ldg_me);
	RIM_CreateNewList  = ldg_find( "RIM_CreateNewList" ,ldg_me);
	RIM_DeleteList     = ldg_find( "RIM_DeleteList"    ,ldg_me);
	RIM_DoConfig       = ldg_find( "RIM_DoConfig"      ,ldg_me);
	WIM_CreateNewList  = ldg_find( "WIM_CreateNewList" ,ldg_me);
	WIM_DeleteList     = ldg_find( "WIM_DeleteList"    ,ldg_me);
	WIM_DoConfig       = ldg_find( "WIM_DoConfig"      ,ldg_me);
	TRM_CreateNewList  = ldg_find( "TRM_CreateNewList" ,ldg_me);
	TRM_DeleteList     = ldg_find( "TRM_DeleteList"    ,ldg_me);
	ME_CompressPalette = ldg_find( "ME_CompressPalette",ldg_me);
	ME_ExplainError    = ldg_find( "ME_ExplainError"   ,ldg_me);
	ME_Init            = ldg_find( "ME_Init"           ,ldg_me);
	
	/* If ME_Init exist, just call it now ! */
	if (ME_Init)
		(*ME_Init)((short*)ldg_global,0L);
	
	/* Check if a function is missing */
	if (   (RIM_OpenImg) && (RIM_CloseImg) && (RIM_LoadImg)
	    && (RIM_DoConfig) && (RIM_CreateNewList)
	    && (RIM_DeleteList)
	    && (ME_CompressPalette) && (ME_ExplainError) && (ME_Init)
	    && (WIM_DoConfig) && (WIM_CreateNewList)
	    && (WIM_DeleteList)
	    && (TRM_CreateNewList) && (TRM_DeleteList))
	{
		return 0L ; /* all seems to be ok */
	}
	
	return -1L; /* at least one function is missing ! */ 
}


/* eof */
