/* ***************************** */
/* * 29/03/2015 MaJ 23/07/2017 * */
/* ***************************** */


#ifndef ___FCM_CREATE_SURFACE_H___
#define ___FCM_CREATE_SURFACE_H___


/* Les defines sont en concordance avec le POPUP_RAM du RSC */
/* En double, car les defines du RSC sont trop court et moins bien lisible */
#define SURFACE_RAM_TYPE_SELECT_AUTO       (POPUP_RAM_AUTO)
#define SURFACE_RAM_TYPE_SELECT_ST_RAM     (POPUP_RAM_STRAM)
#define SURFACE_RAM_TYPE_SELECT_TT_RAM     (POPUP_RAM_TTRAM)
#define SURFACE_RAM_TYPE_SELECT_CT60_VRAM  (POPUP_RAM_CT60)
#define SURFACE_RAM_TYPE_SELECT_MILAN_VRAM (POPUP_RAM_MILAN)

//#define SURFACE_OFFSCREEN_MODE_AUTO       (1) ancien nom de SURFACE_RAM_TYPE_SELECT_AUTO
//#define SURFACE_OFFSCREEN_MODE_ST_RAM     (2)
//#define SURFACE_OFFSCREEN_MODE_TT_RAM     (3)
//#define SURFACE_OFFSCREEN_MODE_CT60_VRAM  (4)
//#define SURFACE_OFFSCREEN_MODE_MILAN_VRAM (5)
//#define SURFACE_OFFSCREEN_MODE_VDI        (6) /* a supprimer ??? a voir */

#define SURFACE_RAM_TYPE_ST_RAM     (1)
#define SURFACE_RAM_TYPE_TT_RAM     (2)
#define SURFACE_RAM_TYPE_CT60_VRAM  (3)
#define SURFACE_RAM_TYPE_MILAN_VRAM (4)

#define SURFACE_OPEN_VDI_OFFSCREEN_BITMAP    (0)
#define SURFACE_NO_OPEN_VDI_OFFSCREEN_BITMAP (-1)



/* type de RAM voulu pour la surface : AUTO / STRAM / TTRAM / CT60RAM / MilanRAM / etc... */
/* si AUTO, le type de RAM est choisi selon un profil du type de machine (ST/TT/etc...)   */
/* L'application peut choisir un type de RAM en modifiant cette variable                  */
uint16 Fcmgfx_CreateSurface_ram_type_select = SURFACE_RAM_TYPE_SELECT_AUTO;


typedef struct
{
	uint32		adresse_malloc;	      /* adresse buffer RAM systeme */
	uint32		adresse_buffer;       /* adresse debut surface (aligner sur un multiple de 256) */
//	uint16		offscreen_mode;       /* AUTO / STRAM / TTRAM / CT60RAM / MilanRAM / etc...     */
	 int16		handle_VDIoffscreen;  /* 0 ou handle VDI offscreen v_opnbm() de la surface      */
	uint16		nb_plan;
	uint16		width;
	uint16		height;
	uint16      ram_type;             /* type de RAM allouer a la surface STRAM / TTRAM / CT60RAM / MilanVRAM / etc... */
} SURFACE;




#endif  /* ___FCM_CREATE_SURFACE_H___ */

