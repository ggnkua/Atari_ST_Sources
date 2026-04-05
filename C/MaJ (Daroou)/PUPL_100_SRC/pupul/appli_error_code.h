/* **[Pupul]******************** */
/* *                           * */
/* * 07/11/2023 MaJ 07/11/2023 * */
/* ***************************** */





#ifndef __APPLI_ERROR_CODE__
#define __APPLI_ERROR_CODE__




/* init_APPLI() */
#define APPLI_ERROR_OPEN_TGA_LDG        (-10)
#define APPLI_ERROR_BAD_TGA_LDG         (-11)
#define APPLI_ERROR_INIT_SOUND          (-12)
#define APPLI_ERROR_OPEN_MOD_LDG        (-13)


/* init_surface() */
#define APPLI_ERROR_TGA_LOAD            (-20)
#define APPLI_ERROR_CREATE_SURFACE      (-21)


/* init_generale() */
#define APPLI_ERROR_DATA_PATH_OVER      (-31)
#define APPLI_ERROR_DATAFILE_NOT_FOUND  (-32)
#define APPLI_ERROR_CYBERNOID_NOT_FOUND (-33)


/* init_audio() */
#define APPLI_ERROR_LDG_MOD_INIT        (-40)
#define APPLI_ERROR_MOD_PATH_OVER       (-41)
#define APPLI_ERROR_MOD_SIZE            (-42)
#define APPLI_ERROR_RESERVE_RAM         (-43)
#define APPLI_ERROR_LOAD_MOD            (-44)
#define APPLI_ERROR_DMA_LOCKED          (-45)
#define APPLI_ERROR_XBIOS_FALCON        (-46)
//#define APPLI_ERROR_XBIOS_FALCON_NOT_FOUND (-45)


/* load_animation() */
#define APPLI_ERROR_ANIMATION_SIZE      (-50)
#define APPLI_ERROR_ANIMATION_RAM       (-51)
#define APPLI_ERROR_ANIMATION_LOAD      (-52)

#endif /* __APPLI_ERROR_CODE__ */

