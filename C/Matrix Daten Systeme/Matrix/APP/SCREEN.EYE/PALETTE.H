extern void draw_pixel ( int vdi_handle, int x, int y, int color ) ;
extern void set_phys_to_vdi ( int vdi_handle, int colors, int *phys_to_vdi, int *vdi_to_phys ) ;
extern void calc_clut_grey ( void ) ;
extern void calc_clut_332 ( void ) ;
extern void calc_clut_yc224 ( void ) ;
extern void set_vdi_palette ( int fr, int to, int *pal ) ;
extern void get_vdi_palette ( int fr, int to, int *pal ) ;
extern void set_phys_palette ( int fr, int to, int *pal ) ;
extern void init_palette ( void ) ;

extern int vdi_handle, phys_handle, appl_id ;

extern int vdi_to_physix[256] ;
extern int phys_to_vdiix[256] ;

extern int save_clut[3*256] ;
extern int clut_332[3*256] ;
extern int clut_yc224[3*256] ;
extern int clut_grey[3*256] ;
# define CLUTgrey7Base	64
extern int clut_grey7[3*256] ;
