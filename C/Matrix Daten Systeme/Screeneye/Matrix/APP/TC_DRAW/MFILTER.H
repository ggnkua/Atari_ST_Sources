extern int selected_matrix ;
extern int *(filters[]) ;

# define USERdimension	3

extern UP_DOWN_VALUE updown_matrix[USERdimension*USERdimension] ;
extern UP_DOWN_VALUE updown_offset, updown_scale  ;

extern void init_filters ( void ) ;
extern void init_user_filter ( int m00, int ofsobj, int scaleobj ) ;
extern void filter_copy ( void ) ;
extern void filter_info ( void ) ;

extern void filter_rect ( int *pts, int *matrix ) ;
