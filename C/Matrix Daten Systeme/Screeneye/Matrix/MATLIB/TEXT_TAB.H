extern FILE *open_mat_file ( char *filnam ) ;
extern bool open_text_table ( char *filnam ) ;
extern void free_text_table ( void ) ;

extern char *get_text ( int txtnum ) ;
extern void print_text ( int txtnum, const char *s, ... ) ;
extern char *date_to_string ( int d, int m, int y, char *output ) ;
extern char *get_start_message ( char *progname, int ver100, char *subver, int d, int m, int y ) ;

extern char start_message[] ;
extern char date_buffer[] ;
