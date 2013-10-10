/* babel - News transport agent for STiK
 *
 * babel.h - Header file with prototypes for public functions
 *
 * (c)1996 Mark Baker. Distributable under the terms of the GNU
 *                     general public licence
 *
 * $Id: babel.h,v 1.3 1996/09/17 20:44:22 mnb20 Exp $
 */
/* Definitions */
#define TRUE  1
#define FALSE 0
#define MAXLINELENGTH 2048

/* Strings structure */
#include "babelstr.h"
#include "struct.h"

/* Routines in main.c */

int main( int argc, char **argv ) ;
void parse_command_line( int argc, char **argv ) ;
void process_file( void ) ;
void new_server( char *server_name, char *groupfile ) ;
void new_groups( char *basefile, char *date ) ;
void byebye( int retstat ) ;

/* Routines in gem.c */

void initialise_gem( void ) ;
void status_line( char *message , int important , char *server , char *group );
void event_loop( void ) ;
void shutdown_gem( void ) ;
void alert( char *message ) ;

/* Routines in files.c */

void open_files( void ) ;
void close_files( void ) ;
void group_list_file( char *server_name, char *filename ) ;
void new_groups_file( char *basename ) ;
FILE *open_group_header( char *basename, char *mode ) ;
FILE *open_messages( char *basename ) ;

/* Routines in socket.c */

void initialise_stik( void ) ;
int open_server( char *hostname ) ;
void close_server( void ) ;
void write_string( char *string ) ;
void read_line( char *line, int maxlength ) ;

/* Routines in group.c */

int do_group( SERVERS *server,GROUPS *group);
long load_header( char *filename ) ;
void save_header( char *filename , int append ) ;
void free_header( void ) ;
void *chk_malloc( size_t size ) ;
void *chk_calloc( size_t n , size_t size ) ;
