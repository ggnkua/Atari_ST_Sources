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
char *mktemp(char *);
void putenv(char *);
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

int flag_file (int, ADDR *, int);

void set_prior (int);
int load_language (void);
void b_initvars (void);
void b_defaultvars (void);
void b_sbinit (void);
void b_exitproc (void);
int got_ESC (void);
void BBSexit (void);
long timerset (unsigned long);
int SendBanner (char *);
unsigned Com_ (char,...);
int timeup (long);

void elapse_time (void);
int _dtoxtime (int, int, int, int, int, int);


int time_to_next (int);


/* #ifdef H_SBUF */
/* #ifndef H_VFOSSIL */
/* #include "vfossil.h" */
/* #endif */
/* #endif */

void write_sched (void);
void close_up (void);
void scr_printf (char *);
void opening_banner (void);
void mailer_banner (void);
void UUCPexit (int);
void come_back (void);
char *strToAscii(char *);
char *fancy_str (char *);
int got_error (char *, char *);
int dfind (struct FILEINFO *, char *, int);
int n_frproc (char *, int, int (*)(char *));
void Make_Response (char *, int);
int do_FLOfile (char *, int (*)(char *), ADDR *);
void fidouser (char *, ADDR *);
void main_help (void);
void mailer_help (void);
void time_release (void);
void do_extern (char *, int, char *);
int dexists (char *);
int do_script (char *);
void timer (int);
void mdm_cmd_string (char *, int);
void dostime (int *, int *, int *, int *);
void dosdate (int *, int *, int *, int *);
void send_break (int);
void mdm_cmd_char (int);
void setModemValues(char *s);
int modem_response (int);
int set_baud (unsigned int, BOOLEAN);
int list_search (void);
int try_1_connect (char *);
void gong (void);
void do_ready (char *);
int com_getc (int);
int FTSC_receiver (int);
int Whack_CR (void);
void FTSC_sender (int);
void last_type (int, ADDR *);
void mdm_hangup (void);
void Janus (void);
void invent_pkt_name (char *);
int send_Hello (int);
void message (char *);
void set_xy (char *);
char *receive_file (char *, char *, char);

void read_sched (void);
void parse_config (char *);
char *ctl_string (char *);
int parse (char *, struct parse_list *);
void bottom_line (void);
void do_today (void);
void top_line(void);
void boss_mail (int);
int unattended (void);
int get_number (char *);
void try_2_connect (char *);
void change_prompt (void);
int do_mail (ADDR *, int);
void ansi_map (unsigned int);
void mdm_init (char *);
char *zalloc (void);
int xfermdm7 (char *);
int send_file (char *, char);
int recvmdm7 (char *);
void main (int, char **);
int opusfind (ADDR *, int);
int QuickLookup (ADDR *, int);
int TBBSLookup (ADDR *, int);
char *skip_blanks (char *);
int parse_event (char *);
char *skip_to_blank (char *);
void SEA_sendreq (void);
int try_sealink (void);
int SEA_recvreq (void);
void clear_filetransfer (void);
void throughput (int, size_t);
void update_files (int);
void send_can (void);
void receive_exit (void);
void xmit_sameplace (void);
void find_event (void);
void errl_exit (int);

/*
 * Status passed to bad_call
 */

#define BAD_STATUS    0
#define BAD_CARRIER   1
#define BAD_NOCARRIER 2
#define BAD_STOPCALL  3
#define BAD_REMOVE    -1

int bad_call (ADDR *, int);



long random_time (int);
int handle_inbound_mail (void);
void xmit_reset (void);
int xmit_next (ADDR *);
void put_up_time (void);


void adios (int);
void big_pause (int);
long zfree (char *);
void unique_name (char *);
void write_sched (void);
char *add_backslash (char *);
char *delete_backslash (char *);
MAILP find_mail (ADDR *);
void xmit_window (MAILP);
void xmit_delete (void);
char *HoldAreaNameMunge(ADDR *);
int LoadScanList (int, int);
void swapper (char *, char *, int, char *, unsigned);
long b_spawn (char *);
void do_dial_strings (void);
void exit_DTR (void);
void delete_old_file (char *);
void screen_clear (void);
void clear_eol (void);
void log_product (int, int, int);
int b_term (void);
void set_up_outbound (void);
void kill_bad(void);
int next_minute (void);
void can_Janus (char *);
int Modem7_Receive_File (char *);
int Modem7_Send_File (char *);
int Batch_Receive (char *);
int Batch_Send (char *);
int Xmodem_Send_File (char *, char *);
int Xmodem_Receive_File (char *, char *);
int SEAlink_Send_File (char *, char *);
int Telink_Send_File (char *, char *);
unsigned int crc_block(unsigned char *, size_t);
void Data_Check (XMDATAP, int);
void Get_Block (XMARGSP);
int Xmodem_Send (int, int, long);
void Send_Block (XMARGSP);
int calc_window (void);
int Receive_Resync (long *);
/*int Receive_Block (XMDATAP, long, int, int, long);*/
void Xmodem_Error (char *, long);
size_t Header_in_data (unsigned char *);
void Find_Char (int);
int Xmodem_Receive (int, char *);
void Send_Response (int, int *, int *, int *, long, int, long);
void Set_Up_Telink (XMDATAP, TLDATAP, long *);
void End_Telink (int, TLDATAP, XMDATAP, char *, int);
void Wait_Clear (int);
void Send_Resync (long, int);
int state_machine (STATEP, void *, int);
int Bark_Request (char *, char *, char *, char *);
void Build_Bark_Packet (BARKARGSP);
int Receive_Bark_Packet (BARKARGSP);
int Batch_Xmodem_Receive_File (char *, char *);
long Set_Up_Restart (XMARGSP);
void Finish_Xmodem_Receive (XMARGSP);
void Get_Telink_Info (XMARGSP);
int Read_Block (XMARGSP);
void Check_ACKNAK (XMARGSP);
void show_block (long, char *, XMARGSP);
int check_failed (char *, char *, char *, char *);
void add_abort (char *, char *, char *, char *, char *);
void remove_abort (char *, char *);
void Build_Header_Block (XMARGSP, char);
void show_sending_blocks (XMARGSP);
void show_num (XMARGSP, long);
FILE *buff_fopen (char *, char *);
size_t buff_fwrite (char *, size_t, size_t, FILE *);
int buff_fclose (FILE *);
int buff_fseek (FILE *, long, int);
int read_wild_ad(char *s, ADKEY *dest);
int parse_address (char *, ADDR *);
int find_address (char *, ADDR *);
int make_assumed(ADDR *ad);
void make4d(ADDR *destad);
char *Hex_Addr_Str (ADDR *);
char *Full_Addr_Str (ADDR *);
char *Pretty_Addr_Str (ADDR *);

BOOLEAN get2daddress(char *name, ADDR *destad);
#ifdef IOS
unsigned int ztoi(char *str, int len);
void getaddress(char *str, unsigned int *net, unsigned int *node, unsigned int *point);
void put36(char *s, unsigned int n, int len);
char *Addr36(ADDR *ad);
void make_dummy_arcmail(char *s, ADDR *from, ADDR *to);
#endif

char *add_domain (char *);
char *find_domain (char *);
#ifdef MULTIPOINT
BOOLEAN isKnownDomain(ADDR *ad);
#endif

void MNP_Filter (void);
int term_overlay (int);
void write_stats (void);
void list_next_event (void);

#ifndef GENERIC
#define PUTWORD(v)  (v)
#define GETWORD(v)	(v)
#define GETPWORD(v) (v)
#else
word PUTWORD(register word);
word GETWORD(register word);

/* #define GETPWORD(v) _getpword((byte *)&v) */
/* word _getpword(byte *) */


#define GETPWORD(v) ( ((byte *)&v)[0] + (((byte *)&v)[1] << 8) )
#endif

#ifdef NEW /* diverse */
void hang_up (void);                   /* FASTMODEM     10.09.1989 */
void exec_shell (int);                 /* GENERALEXIT   24.09.1989 */
#endif

void add_to_strlist(STR_LIST **list, char *s);
char *find_strlist(STR_LIST *list, ADDR *ad, char **spec_field);
BOOLEAN find_ad_strlist(STR_LIST *list, ADDR *ad, char **spec_field);
BOOLEAN check_holdonus(ADDR *ad, char **spec_field);
BOOLEAN check_noemsi(ADDR *ad, char **spec_field);
BOOLEAN check_norequest(ADDR *ad, char **spec_field);
BOOLEAN check_nojanus(ADDR *ad, char **spec_field);
BOOLEAN check_reqonus(ADDR *ad, char **spec_field);
void call_fax (void);
int fax_recieve(void);
char *DirName (const char *fullname);

#endif	/* H_PROTOTYP */
