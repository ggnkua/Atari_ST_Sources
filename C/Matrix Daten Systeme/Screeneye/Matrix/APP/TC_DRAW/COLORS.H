# define R 0
# define G 1
# define B 2

# define VQcolMode 0	/* requested color */


typedef int ReGrBl[3] ;

extern ReGrBl color_levels ;
extern ReGrBl curr_line_rgb ;
extern ReGrBl curr_text_rgb ;
extern ReGrBl curr_fill_rgb ;
extern ReGrBl clut_masks ;

extern int	curr_color, last_color ;

extern struct POTIstruct rgb_poti[3] ;			/* import !	*/
extern struct POTIstruct colix_poti ;
extern struct POTIstruct clut_mask_poti[3] ;

extern void set_current_rgb ( void ) ;
extern void set_new_color ( void ) ;
extern void update_color_potis ( void ) ;

extern void update_clut_mask ( void ) ;
extern void set_clut_mask ( void ) ;
extern void set_current_rgb ( void ) ;
extern void rgb_poti_click ( int bascol, int obj, int mx ) ;
extern void set_new_color ( void ) ;
extern void change_vdi_color ( int newcol ) ;
extern void pick_rgb_color ( int boxobj, int *rgb ) ;
extern void pick_color ( void ) ;
extern int fetch_color ( unsigned char *rgb, char *info ) ;
extern int fetch_rgb_color ( int *rgb, char *info ) ;
extern void init_colors ( void ) ;
