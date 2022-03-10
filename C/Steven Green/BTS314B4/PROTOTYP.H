#ifndef H_PROTOTYPE
#define H_PROTOTYPE
/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*               Prototype definitions used in BinkleyTerm                  */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#ifdef __TURBOC__
#ifdef __TOS__
char *mktemp( char *pat );
void putenv( char *var );
void tzset(void);
#define cprintf printf
#define cputc putchar
#define chgdsk Dsetdrv
#define dir_findfirst(name,attr,info) findfirst((name),(info),(attr))
#define dir_findnext(info) findnext((info))
#define dnext(info) findnext((struct ffblk *)(info))
#else
int _dos_read(int fd, void far *buf, unsigned nbytes, unsigned *bytes_read);
#endif
#endif

int flag_file (int function, ADDR *address, int do_stat);

void set_prior (int pclass);
int load_language (void);
void b_initvars (void);
void b_defaultvars (void);
void b_sbinit (void);
void b_exitproc (void);
int got_ESC (void);
void BBSexit (void);
long timerset( unsigned long t );
int SendBanner (char *string);
unsigned Com_ (char,...);
int timeup (long t);

void elapse_time (void);
int _dtoxtime (int, int, int, int, int, int);


int time_to_next( int skip_bbs );


/* #ifdef H_SBUF */
/* #ifndef H_VFOSSIL */
/* #include "vfossil.h" */
/* #endif */
/* #endif */

void write_sched (void);
void close_up (void);
void scr_printf( char *string );
void opening_banner (void);
void mailer_banner (void);
void UUCPexit( int n );
void come_back (void);
char *strToAscii( char *s );
char *fancy_str( char *string );
int got_error( char *string1, char *string2 );
int dfind( struct FILEINFO *dta, char *name, int times );
int n_frproc( char *request, int nfiles, int (*callback)(char *) );
void Make_Response( char *data, int failure );
int do_FLOfile( char *ext_flags, int (*callback)(char *) , ADDR *ad );
void fidouser( char *name, ADDR *faddr );
void main_help (void);
void mailer_help (void);
void time_release (void);
void do_extern( char *cmd, int prot, char *name );
int dexists( char *filename );
int do_script( char *phone_number );
void timer( int interval );
void mdm_cmd_string( char *mdm_cmd, int dospace );
void dostime( int *hour, int *min, int *sec, int *hdths );
void dosdate( int *month, int *mday, int *year, int *weekday );
void send_break( int t );
void mdm_cmd_char( int outchr );
void setModemValues( char *s );
int modem_response( int ths );
int set_baud( unsigned int baudrate, BOOLEAN log );
int list_search( void );
int try_1_connect( char *phnum );
void gong( void );
void do_ready( char *string );
int com_getc( int t );
int FTSC_receiver( int wz );
int Whack_CR( void );
void FTSC_sender( int wz );
void last_type( int n, ADDR *taddr );
void mdm_hangup( void );
void Janus( void );
void invent_pkt_name( char *string );
int send_Hello( int );
void message( char *string );
void set_xy( char *string );
char *receive_file( char *, char *, char );

void read_sched( void );
void parse_config( char *config_file );
char *ctl_string( char *source );
int parse( char *input, struct parse_list list[] );
void bottom_line( void );
void do_today( void );
void top_line( void );
void boss_mail( int );  /* nf */
int unattended( void );
int get_number( char *target );
void try_2_connect( char *phnum );
void change_prompt( void );
int do_mail( ADDR *baddr, int manual );
void ansi_map( unsigned int ScanVal );
void mdm_init( char *str );
char *zalloc (void);		/* nf */
int xfermdm7 (char *);	/* nf */
int send_file (char *, char);	/* nf */
int recvmdm7 (char *);			/* nf */
int main( int argc, char *argv[] );
int opusfind (ADDR *, int);
int QuickLookup (ADDR *, int);
int TBBSLookup (ADDR *, int);
char *skip_blanks( char *string );
int parse_event( char *e_line );
char *skip_to_blank( char *string );
void SEA_sendreq( void );
int try_sealink (void);
int SEA_recvreq( void );
void clear_filetransfer( void );
void throughput( int opt, size_t bytes );
void update_files( int t );
void send_can( void );
void receive_exit( void );
void xmit_sameplace (void);
void find_event( void );
void errl_exit( int n );

/*
 * Status passed to bad_call
 */

#define BAD_STATUS    0
#define BAD_CARRIER   1
#define BAD_NOCARRIER 2
#define BAD_STOPCALL  3
#define BAD_REMOVE    -1

int bad_call( ADDR *baddr, int rwd );

long random_time( int x );
int handle_inbound_mail( void );
void xmit_reset( void );
int xmit_next( ADDR *xaddr );
void put_up_time( void );

void adios (int);
void big_pause( int secs );
#if defined ( ATARIST ) && (__TOS__)
	unsigned long zfree( char *path );
#else
	long zfree( char *path );
#endif
void unique_name( char *fname );
void write_sched( void );
char *add_backslash( char *str );
char *delete_backslash( char *str );
MAILP find_mail( ADDR *address );
void xmit_window( MAILP p1 );
void xmit_delete( void );
char *HoldAreaNameMunge( ADDR *maddr );
int LoadScanList( int number, int report_errors );
void swapper (char *, char *, int, char *, unsigned);
long b_spawn( char *cmd_str );
void do_dial_strings( void );
void exit_DTR( void );
void delete_old_file (char *);
void screen_clear( void );
void clear_eol( void );
void log_product( int product, int version, int subversion );
int b_term( void );
void set_up_outbound( void );
void kill_bad( void );
int next_minute( void );
void can_Janus( char *p );
int Modem7_Receive_File( char *filename );

/* */

int Modem7_Send_File( char *filename );
int Batch_Receive( char *where );
int Batch_Send ( char *filename );
int Xmodem_Send_File( char *filename, char *sendname );
int Xmodem_Receive_File( char *path, char *filename );
int SEAlink_Send_File( char *filename, char *sendname );
int Telink_Send_File( char *filename, char *sendname );
unsigned int crc_block( unsigned char *ptr, size_t count );
void Data_Check( XMDATAP xtmp, int mode );
void Get_Block( XMARGSP args );
int Xmodem_Send (int, int, long);
void Send_Block( XMARGSP args );
int calc_window( void );
int Receive_Resync( long *resync_block );
/*int Receive_Block (XMDATAP, long, int, int, long);*/
void Xmodem_Error( char *s, long block_number );
size_t Header_in_data( unsigned char *p );
void Find_Char( int c );
int Xmodem_Receive (int, char *);
void Send_Response (int, int *, int *, int *, long, int, long);
void Set_Up_Telink (XMDATAP, TLDATAP, long *);
void End_Telink (int, TLDATAP, XMDATAP, char *, int);
void Wait_Clear (int);
void Send_Resync (long, int);
int state_machine( STATEP machine, void *passed_struct, int start_state );
int Bark_Request( char *where, char *filename, char *pw, char *updtime );
void Build_Bark_Packet( BARKARGSP args );
int Receive_Bark_Packet( BARKARGSP args );
int Batch_Xmodem_Receive_File( char *path, char *filename );
long Set_Up_Restart( XMARGSP args );
void Finish_Xmodem_Receive( XMARGSP args );
void Get_Telink_Info( XMARGSP args );
int Read_Block( XMARGSP args );
void Check_ACKNAK( XMARGSP args );
void show_block( long b, char *c, XMARGSP args );
int check_failed( char *fname, char *theirname, char *info, char *ourname );
void add_abort( char *fname, char *rname, char *cname, char *cpath, char *info );
void remove_abort( char *fname, char *rname );
void Build_Header_Block( XMARGSP args, char type );
void show_sending_blocks( XMARGSP args );
void show_num( XMARGSP args, long b );
FILE *buff_fopen( char *fname, char *fmode );
size_t buff_fwrite (char *, size_t, size_t, FILE *);
int buff_fclose( FILE *fp );
int buff_fseek( FILE *fp, long a, int b );
int read_wild_ad( char *node, ADKEY *dest );
int parse_address( char *node, ADDR *addr );
int find_address( char *node, ADDR *addr );
int make_assumed(ADDR *ad);
void make4d( ADDR *destad );
char *Hex_Addr_Str( ADDR *a );
char *Full_Addr_Str( ADDR *a );
char *Pretty_Addr_Str( ADDR *a );

BOOLEAN get2daddress(char *name, ADDR *destad);
#ifdef IOS
unsigned int ztoi(char *str, int len);
void getaddress(char *str, unsigned int *net, unsigned int *node, unsigned int *point);
void put36(char *s, unsigned int n, int len);
char *Addr36(ADDR *ad);
void make_dummy_arcmail(char *s, ADDR *from, ADDR *to);
#endif

char *add_domain( char *d );
char *find_domain( char *d );
#ifdef MULTIPOINT
BOOLEAN isKnownDomain(ADDR *ad);
#endif

void MNP_Filter( void );
int term_overlay( int k );
void write_stats( void );
void list_next_event( void );

#ifndef GENERIC
#define PUTWORD(v)  (v)
#define GETWORD(v)	(v)
#define GETPWORD(v) (v)
#else
word PUTWORD( register word val );
word GETWORD( register word val );

/* #define GETPWORD(v) _getpword((byte *)&v) */
/* word _getpword(byte *) */


#define GETPWORD(v) ( ((byte *)&v)[0] + (((byte *)&v)[1] << 8) )
#endif

#ifdef NEW /* diverse */
void hang_up( void );                   /* FASTMODEM     10.09.1989 */
void exec_shell( int j );                 /* GENERALEXIT   24.09.1989 */
#endif

void add_to_strlist( STR_LIST **list, char *s );
char *find_strlist( STR_LIST *list, ADDR *ad, char **spec_field);
BOOLEAN find_ad_strlist( STR_LIST *list, ADDR *ad, char **spec_field);
BOOLEAN check_holdonus( ADDR *ad, char **spec_field);
BOOLEAN check_noemsi( ADDR *ad, char **spec_field);
BOOLEAN check_norequest( ADDR *ad, char **spec_field);
BOOLEAN check_nojanus( ADDR *ad, char **spec_field);
BOOLEAN check_reqonus( ADDR *ad, char **spec_field);
void call_fax (void);
int fax_recieve(void);
char *DirName (const char *fullname);

#endif	/* H_PROTOTYP */
