/* **[Boing]******************** */
/* *                           * */
/* * 04/10/2014 MaJ 22/11/2023 * */
/* ***************************** */





#ifndef __APPLI_ERROR_CODE__
#define __APPLI_ERROR_CODE__


/* Alerte indiquant que l'appli doit s'arreter */
#define APPLI_ERROR_APPLI_STOP          (-99)

/* generale */
#define APPLI_ERROR_DATA_PATH_OVER      (-10)
#define APPLI_ERROR_RESERVE_RAM         (-11)


/* init_boing() */
#define APPLI_ERROR_OPEN_TGA_LDG        (-20)
#define APPLI_ERROR_BAD_TGA_LDG         (-21)
#define BOING_ERROR_SOUND_RAM           (-22)


/* check_fichier() */
#define BOING_ERROR_BOINGM_NOT_FOUND    (-31)
#define BOING_ERROR_BOINGS_NOT_FOUND    (-32)
#define APPLI_ERROR_DATAFILE_NOT_FOUND  (-33)


/* init_surface_xxxx() */
#define APPLI_ERROR_CREATE_SURFACE      (-41)


/* load_sound() */
#define APPLI_ERROR_AVR_SIZE            (-51)



#endif /* __APPLI_ERROR_CODE__ */

