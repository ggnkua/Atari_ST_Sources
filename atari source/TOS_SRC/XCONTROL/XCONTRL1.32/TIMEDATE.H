/* TIMEDATE.C prototypes and defines
 *==========================================================================
 */

/*  PROTOTYPES
 *==========================================================================
 */
void time_handle( void );
void update_time( void );
void init_time( void );
void time_date_stamp( int obj );
void redraw_hour( int new );
void my_itoa( char *ptr, int val, int suppress );
int  my_atoi( char *ptr );


/*  EXTERNS
 *==========================================================================
 */
extern int  hour_state;
extern char *hour_string[];
extern int TIME;


/*  DEFINES
 *==========================================================================
 */
#define HOUR12  0 
#define HOUR24	1

