/************************************************************************/
/*																		*/
/*		Gendraw.h	22 Jul 97											*/
/*																		*/
/************************************************************************/

/* Header file for GENDRAW containing #DEFINES and						*/
/* prototype definitions												*/


typedef struct custom_person* Custom_person_ptr ;
typedef struct custom_couple* Custom_couple_ptr ;

typedef struct custom_person
{
	int list_number ;
	int reference ;
	short x ;
	short y ;
	short status ;
	int attributes ;
	FONTINFO* font_ptr ;		/* NULL unless personal font specified	*/		
	GRECT box ;					/* outer limits of name and dates in mm	*/
	short* parent_line_data ;	/* pointer to list of vertices in line	*/
								/* up to horizontal of couple. Null if	*/
								/* simply straight line up to it.		*/
	int parent_number ;			/* list number of parent couple			*/
	int* coupling_list ;		/* pointer to list of couplings			*/
	short couplings ;			/* number of couplings inc this person	*/
	short couplings_drawn ;		/* number already drawn					*/
	Custom_person_ptr previous_person ;	/* linked list					*/
	Custom_person_ptr next_person ;
} Custom_person ;

													/* person status	*/
#define CUST_SELECTED 1

typedef struct custom_couple
{
	int list_number ;
	int reference ;
	short x ;					/* centre of "=" sign					*/
	short y ;
	short status ;
	short hline_x0 ;			/* position of horizontal couple line	*/
	short hline_x1 ;
	short hline_y ;
	short* vline_data ;			/* pointer to list of vertices in line	*/
								/* down to horizontal of couple. Null	*/
								/* if simply straight line down to it.	*/
	short* mline_data ;			/* pointer to list of vertices in line	*/
	short* fline_data ;			/* across to male & female partners.	*/
								/* Null if simply straight lines.		*/
	int male_number ;			/* Male number if on tree, 0 otherwise	*/
	int female_number ;			/* Female number if on tree, 0 otherwise*/
	int* child_numbers ;		/* Zero terminated list of child		*/
								/* numbers on tree, NULL if none		*/
	Custom_couple_ptr previous_couple ;	/* linked list					*/
	Custom_couple_ptr next_couple ;
} Custom_couple ;

													/* couple status	*/
#define CUST_REVERSED 2	
#define CHILDREN_HIDDEN 4

typedef struct Custom_tree
{
	Custom_person* start_person ;
	Custom_person* end_person ;
	Custom_couple* start_couple ;
	Custom_couple* end_couple ;
	
	short org_x ;		/* coordinates in mm of top left corner of tree		*/
	short org_y ;
	short lim_x ;		/* coordinates in mm of bottom right corner of tree	*/
	short lim_y ;
	
	int attributes ;
	FONTINFO fontinfo ;
} Custom_tree ;

typedef struct custom_device
{
	short handle ;
	short percent ;				/* zoom factor							*/
	short scale_index ;
	GRECT custom_box ;			/* display area used for custom tree	*/
	short pixel_width ;			/* pixel size in um						*/
	short pixel_height ;
	short cell_height ;
	short x_start, y_start ;	/* coords in mm of part of tree in top	*/
								/* left corner of display area			*/
} Custom_device ;

							/* maximum width and height 60m, could cope	*/
							/* with +-32.767m but warn before then		*/
#define MAX_CUSTOM_WIDTH 60000
#define MAX_CUSTOM_HEIGHT 60000

#define MIN_SCALE_INDEX 0
#define MAX_SCALE_INDEX 10

#define XPOS 0
#define XDIST 1
#define YPOS 2
#define YDIST 3
#define VERTICAL 0
#define HORIZONTAL 1

#define CUST_LEFT 1
#define CUST_RIGHT 2

#define MLINE 1
#define FLINE 2
#define VLINE 3
#define HLINE 4

#define NO_ADDITION 0
#define ADD_SIDE_STEP 1
#define ADD_CORNER_BEFORE 2
#define ADD_CORNER_AFTER 3

					/* attributes bits	*/
#define LIMIT_SIZE_BITS 0x7F
#define HIDDEN_YES_BIT 0x100
#define HIDDEN_NO_BIT 0x200
#define HIDDEN_BITS ( HIDDEN_YES_BIT + HIDDEN_NO_BIT )
#define ONE_BIT 0x400
#define ALL_BIT 0x800
#define LIMIT_BIT 0x1000
#define LIMIT_BITS ( ONE_BIT + ALL_BIT + LIMIT_BIT )
#define FNAME_YES_BIT 0x2000
#define FNAME_NO_BIT 0x4000
#define FNAME_AUTO_BIT 0x8000
#define FNAME_BITS ( FNAME_YES_BIT + FNAME_NO_BIT + FNAME_AUTO_BIT )
#define DOB_YES_BIT 0x10000
#define DOB_NO_BIT 0x20000
#define DOB_BITS ( DOB_YES_BIT + DOB_NO_BIT )
#define DOD_YES_BIT 0x40000
#define DOD_NO_BIT 0x80000
#define DOD_BITS ( DOD_YES_BIT + DOD_NO_BIT )

											/* Routines in GENDRAW.C	*/
void	initialise_custom_tree( void ) ;
void	new_custom_tree( void ) ;
void	open_custom_window( int first_person ) ;
void	print_custom_tree( int ref ) ;
void	close_custom_display( void ) ;
void	close_custom_tree( void ) ;
void	close_custom( void ) ;
void	set_custom_attributes( void ) ;
void	clear_attribute_fields( OBJECT* attr_ptr ) ;
void	void  popup_scale_selector( void ) ;
void	custom_zoom( short zoom_steps ) ;
int		custom_redraw( int handle, GRECT *rect_ptr ) ;
void	draw_custom_tree( Custom_device* device, GRECT clip_rect,
					short x_start, short y_start, Str_prt_params *ps_ptr ) ;
void	draw_custom_person( Custom_device* device, GRECT clip_rect,
						Custom_person* Cp_ptr, short x_start, short y_start ) ;
void	draw_poly_line( short* line_data, short x_line_start, short y_line_start, short end, BOOLEAN horizontal,
			short x_start, short y_start, Custom_device* device, GRECT clip_rect ) ;
void	clipped_line( int handle, short*pxy_array, GRECT clip_rect ) ;
void	draw_custom_couple( Custom_device* device, GRECT clip_rect,
						Custom_couple* Cc_ptr, short x_start, short y_start ) ;
void	draw_selected_boxes( GRECT clip_rect, short x_move, short y_move ) ;
void	draw_selected_box( Custom_person* Cp_ptr, short x_move, short y_move ) ;
void	draw_custom_pages( void ) ;
void	dash_selected_line( short x_move, short y_move ) ;
short	mm2pix( short mm, short start, short operation, Custom_device* device ) ;
short	pix2mm( short pix, short start, short operation, Custom_device* device ) ;
BOOLEAN	lines_onpage(Custom_person* current_person, GRECT* page ) ;
BOOLEAN	is_onpage( Custom_person* current_person, GRECT* page ) ;
void	find_limits_of_tree( short* xl, short* xr, short* yt, short* yb ) ;
void	line_range_check( short* line_data, short x_start, short y_start, BOOLEAN horizontal,
									short* xl, short* xr, short* yt, short* yb ) ;
void	use_scaled_fontinfo( Custom_device* device, FONTINFO font ) ;
Custom_person*	get_next_selected_custom_person( Custom_person* Cp_ptr ) ;
void	graphic_mu_mesag( Wind_edit_params* form, short* fulled, const short *message, GRECT* disp_box ) ;
void	custom_mu_mesag( const short *message ) ;
void	cust_mu_button( short m_x, short m_y, short breturn ) ;
void	directly_draw_selected_box( Custom_person* Cp_ptr, short* clip_array ) ;
void	get_mouse_move_mm( short* x_move, short* y_move, short m_x, short m_y ) ;
void	custom_rubber_band( short* x_move, short* y_move, short m_x, short m_y ) ;
void	move_cust_person( Custom_person* Cp_ptr, short x_move, short y_move ) ;
void	test_move_cust_couple( Custom_couple* Cc_ptr, short x_move, short y_move ) ;
void	move_parent_segment( Custom_person* Cp_ptr, short x_move, short y_move ) ;
void	move_couple_segment( Custom_couple* Cc_ptr, short x_move, short y_move, short line_type ) ;
short	move_segment( short** line_data, short segment, short xy_move, short last_length, BOOLEAN horizontal_segment ) ;
void	add_parent_segments( Custom_person* Cp_ptr, short segment, short position ) ;
void	add_couple_segments( Custom_couple* Cc_ptr, short line_type, short segment, short position ) ;
void 	add_segment( short** ld_ptr_ptr, short segment, short position ) ;
Custom_person*	get_cust_person( short x, short y, char* selection ) ;
Custom_person*  get_cust_psegment( short xmm, short ymm, short* line, short* segment, short* position ) ;
BOOLEAN	find_segment( short xmm, short ymm, short line_start_x, short line_start_y,
						short* line_data, BOOLEAN horizontal, short end_value,
						short* segment, short* position, short* line ) ;
void	adjust_couple_lines( int list_number ) ;
Custom_couple*	get_cust_csegment( short xmm, short ymm, short* line, short* line_type, short* segment, short* position ) ;
Custom_person*	add_custom_person( int reference, short x, short y, const FONTINFO* font_ptr, int parent_number ) ;
GRECT	calculate_box( int reference, short x, short y, int attributes, FONTINFO* font_ptr, int parent_number ) ;
GRECT	get_box_size( int reference, short x, short y, int attributes, FONTINFO* font_ptr, int parent_number ) ;
Custom_couple*	add_custom_parents( Custom_person* Cp_ptr ) ;
BOOLEAN	add_children( int* child_refs, short first_child, Custom_couple* Cc_ptr,
						BOOLEAN rightwards, short upper_x, short lower_x,
						short base_position_y, short* furthest_x, short* highest_y) ;
void	update_all_couples( void ) ;
void	update_children( Custom_couple* Cc_ptr ) ;
void	add_child( Custom_couple* Cc_ptr, int ref, short* rightmost_position, short left_update_limit ) ;
void	remove_custom_person( Custom_person* Cp_ptr ) ;
Custom_couple*	add_custom_coupling( Custom_person* Cp_ptr, short side ) ;
void	reverse_selected_couples( void ) ;
void	remove_custom_coupling( Custom_couple* Cc_ptr ) ;
int		get_cust_person_by_ref( int ref, int minimum_number ) ;
Custom_couple*	new_custom_couple( void ) ;
Custom_couple*	get_Cc_ptr( int list_number ) ;
Custom_person*	get_Cp_ptr( int list_number ) ;
void	get_last_parent_vertex( Custom_person* Cp_ptr, short* end_x, short* end_y ) ;
void	adjust_couple_hline( Custom_couple* Cc_ptr ) ;
void	adjust_tree_position( void ) ;
void	custom_scrolled( const short *message ) ;
void	set_cust_sliders( void ) ;
void	select_all_custom_people( void ) ;
void	custom_menu_enables( BOOLEAN flag ) ;
void	custom_tree_names( Custom_person* Cp_ptr, char* names, char* dates ) ;
void	print_custom( void ) ;
void	save_custom_tree_as( void ) ;
void	save_custom_tree( void ) ;
void	save_custom_person( Custom_person* Cp_ptr, FILE* fp ) ;
void	save_custom_couple( Custom_couple* Cc_ptr, FILE* fp ) ;
void	save_fontinfo( FONTINFO* font_ptr, FILE* fp ) ;
BOOLEAN	load_custom_tree( void ) ;
short*	get_short_values( char* buf_ptr, short** ptr_ptr ) ;
int*	get_int_values( char* buf_ptr, int** ptr_ptr ) ;
void	load_fontinfo( char* buf_ptr, FONTINFO* font_ptr ) ;
