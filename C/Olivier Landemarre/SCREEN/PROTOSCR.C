/*#include "scrnldg.h" */
long __CDECL (*screen_init)(long vdihandle, videoinf *display, char *type_ecran, sortievideo *more_infos, long flag);
void __CDECL (*screen_display)(long vdihandle, videoinf *display);
long __CDECL (*virtual_display)(long vdihandle, videoinf *display, char *type_memoire, sortievideo *more_infos);
void __CDECL (*fix_palette)(sortievideo *more_infos, long mode, long vdihandle);
long __CDECL (*screen_detect)(long vdihandle, char *answer);
long __CDECL (*trnfm_to_R8V8B8)(unsigned char *src, void *destR8V8B8, unsigned char *palette,long width, long height,long nb_plans,long mode);
long  __CDECL (*trnfm_plane_to_VDI)(unsigned char *src, unsigned char *dest, long nb_plans,char *srcdef, long width, long height, long options);
void __CDECL (*trnfm_ind_pal)( char *palette, long nbplans);
void __CDECL (*screen_display_texture)(long vdihandle, videoinf *display, long startx, long starty);
void __CDECL (*restore_palette)(long vdihandle);
short __CDECL (*screen_display_from_disk)(long vdihandle, videoinf *display,long gemdos_handle);
void __CDECL (*Save_TGA)(char *file, void *buffer, long WIDTH, long HEIGHT, long mode);
void __CDECL (*direct_display)(long vdihandle,videoinf *display,long nbplans,long mode);
void __CDECL (*direct_display_texture)(long vdihandle, videoinf *display, long startx, long starty);
void __CDECL (*resize_R8V8B8)(char *dest,long dest_width,long dest_height,char *src,long src_width,long src_height);

void init_screen(LDG *ptldg)
{
	screen_init = ldg_find("screen_init",ptldg);
	screen_display = ldg_find("screen_display",ptldg);
	virtual_display = ldg_find("virtual_display",ptldg);
	fix_palette = ldg_find("fix_palette",ptldg);
	screen_detect = ldg_find("screen_detect",ptldg);
	trnfm_to_R8V8B8 = ldg_find("trnfm_to_R8V8B8",ptldg);
	trnfm_plane_to_VDI = ldg_find("trnfm_plane_to_VDI",ptldg);
	trnfm_ind_pal = ldg_find("trnfm_ind_pal",ptldg);
	screen_display_texture = ldg_find("screen_display_texture",ptldg);
	restore_palette = ldg_find("restore_palette",ptldg);
	screen_display_from_disk = ldg_find("screen_display_from_disk",ptldg);
	Save_TGA = ldg_find("Save_TGA",ptldg);
	direct_display=ldg_find("direct_display",ptldg);
	direct_display_texture=ldg_find("direct_display_texture",ptldg);
	resize_R8V8B8=ldg_find("resize_R8V8B8",ptldg);
	
}