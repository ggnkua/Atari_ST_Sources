/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 07/11/2023 * */
/* ***************************** */





#ifndef __APPLI_ERROR_CODE__
#define __APPLI_ERROR_CODE__




/* init_nyancat() */
#define APPLI_ERROR_OPEN_TGA_LDG        (-10)
#define APPLI_ERROR_BAD_TGA_LDG         (-11)
#define APPLI_ERROR_INIT_SOUND          (-12)


/* init_surface() */
#define APPLI_ERROR_TGA_LOAD            (-20)
#define APPLI_ERROR_CREATE_SURFACE      (-21)


/* init_generale() */
#define APPLI_ERROR_DATA_PATH_OVER      (-31)
#define APPLI_ERROR_DATAFILE_NOT_FOUND  (-32)
#define APPLI_ERROR_AVR_NOT_FOUND       (-33)


/* audio */
#define APPLI_ERROR_AVR_PATH_OVER       (-40)
#define APPLI_ERROR_AVR_SIZE            (-41)
#define APPLI_ERROR_RESERVE_RAM         (-42)
#define APPLI_ERROR_RESERVE_RAM_SOUND   (-43)
#define APPLI_ERROR_LOAD_AVR            (-44)
#define APPLI_ERROR_DMA_LOCKED          (-45)
#define APPLI_ERROR_XBIOS_FALCON        (-46)



#endif /* __APPLI_ERROR_CODE__ */

