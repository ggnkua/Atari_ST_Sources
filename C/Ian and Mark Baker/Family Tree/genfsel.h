/*************************************************************************/
/*                                                                       */
/*  GENFSEL.H    Font selector routines for family tree    22 Nov 1998	 */
/*                                                                       */
/*************************************************************************/

/* Header file for GEN containing #DEFINES and							*/
/* prototype definitions												*/

#define cdecl /* used in XUFSL.H, presumably required in PureC */
#include <xufsl.h>

											/* Routines in GENFSEL.C	*/
FONTINFO ft_font_select( short handle, FONTINFO font_info,	char *title ) ;
FONTINFO uf_font_select( short handle, xUFSL_struct* ufsl, FONTINFO font_info,	char *title ) ;
FONTINFO font_select( short handle, FONTINFO font_info,	char *title ) ;
void	use_fontinfo( int handle, FONTINFO select ) ;
int __stdargs __saveds  render_sample( PARMBLK *pb ) ;
int		fsel_move_slide( OBJECT *tree, int slider, int slide_range,
															GRECT *box ) ;
void	fsel_set_slide( int value, int range, OBJECT *tree,
								int slider, int slide_range, GRECT *box ) ;
void	set_fontsel_addrs( void ) ;
int		init_fontsel_form( short handle, GRECT *box, char *title,
												FONTINFO preselected ) ;
int		index_cmp( void *one, void *two ) ;
void	display_font_list( short vdi_handle, GRECT box ) ;
void	selectfont( short handle, short obj, int new_font, FONTINFO *info,
												GRECT box ) ;
void	selectsize( short obj, int new_size, FONTINFO *info, GRECT box ) ;
void	display_size_list( GRECT box ) ;
int		init_sizes( short handle, FONTINFO preselected, GRECT *box_ptr ) ;
