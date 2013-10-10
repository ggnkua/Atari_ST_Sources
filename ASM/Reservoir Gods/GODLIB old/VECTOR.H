/*
;*************************************
;*===================================*
;* RESERVOIR GODS C LIBRARY ROUTINES *
;*===================================*
;*         |              |          *
;*         |VECTOR LIBRARY|          *
;*         |              |          *
;*************************************
;* CODE: MR. PINK | (C): 28/08/96    *
;*************************************
;* UPDATE: 19/2/96  *
;********************
*/

/*
#include "d:\gods\library\rg_c.lib\base.h"
*/

typedef struct 
{
U32 vector_old_cacr;
U32 vector_old_vbl;
U32 vector_old_msp;
U32 vector_old_usp;
U32 vector_old_vectors[254];
U32 vector_old_mfp[12];
} VECTOR_STRUCT;


extern	rlvc_save_vectors(VECTOR_STRUCT *);
extern	rlvc_restore_vectors(VECTOR_STRUCT *);
extern	rlvc_install_vbl();
extern	rlvc_wait_vbl();
extern	rlvc_install_vbl_routine(void *);
extern	rlvc_remove_vbl_routine(void *);
extern	rlsc_set_screen_vbl();

void rlvc_open_system();
void rlvc_close_system();

VECTOR_STRUCT vector_save_space;

void rlvc_open_system()
{
	rlvc_save_vectors(&vector_save_space);
	rlvc_install_vbl();
/*	rlvc_install_vbl_routine(&rlsc_set_screen_vbl); */
}

void rlvc_close_system()
{
	rlvc_restore_vectors(&vector_save_space);
}
