#ifndef H_EXTERNS
#define H_EXTERNS
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
/*            This module was originally written by Bob Hartman             */
/*                                                                          */
/*                                                                          */
/*                            BinkleyTerm Data                              */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
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

/* Version.c */
extern int init_driver(void);
extern int set_driver(void);
extern void set_new_port(int port);
extern unsigned long device_addr;

extern char ANNOUNCE[];
extern char xfer_id[];
extern char compile_date[];
extern char ver_stuff[];
extern char MAILER_VER[];
extern char MAILER_SER[];
extern char MAILER_NAME[];

/* data.c */

extern char **msgtxt;
extern char *mtext[];

extern struct baud_str btypes[];
extern struct baud_str max_baud;                 /* Maximum baud rate   */

extern struct secure DEFAULT;
extern struct secure KNOWN;
extern struct secure PROT;

extern struct req_accum freq_accum;

extern int locate_x, locate_y, port_ptr, original_port;

extern int TaskNumber;                           /* unique user-specified id   */
extern int share;                                /* if 1, don't uninit FOSSIL  */
extern int first_block;                          /* 1 = first block/Matrix
                                                  * packet */

extern int net_params;                           /* if 1, net params complete */
extern int un_attended;
extern int command_line_un;
extern int overwrite;
extern int redo_dynam;
extern int fullscreen;
extern int signalhandler;
extern int do_screen_blank;
extern int screen_blank;
extern int blank_on_key;
extern unsigned BBStimeout;
extern int gong_allowed;
extern int MAXport;
extern int poll_tries;
extern int poll_delay;

extern int com_port;
extern int reset_port;
extern unsigned int comm_bits;
extern unsigned int parity;
extern unsigned int stop_bits;
extern unsigned int carrier_mask;
extern unsigned int handshake_mask;

extern int baud;                                 /* Index to baud table */
extern unsigned cur_baud;                             /* Current baud rate   */

extern char *modem_firstinit;					 /* Used to init modem (startup sequence only) */
extern char *modem_init;                         /* Used to init modem  */
extern char *modem_reset;						 /* Used to reset modem */
extern char *term_init;                          /* Used to init modem  */
extern char *modem_busy;                         /* Take modem offhook  */
extern char *predial;                            /* Pre-dial setup      */
extern char *postdial;                           /* Post-dial cleanup   */
extern char *normprefix;
extern char *normsuffix;
extern char *dial_setup;
extern char *init_setup;

extern unsigned int matrix_mask;
extern char *system_name;
extern char *sysop;
extern char *NL_System;
extern char *NL_Phone;
extern char *NL_City;
extern char *NL_Flags;
extern char *NL_Baud;

extern char *net_info;
extern char *fax_prg;
extern char *afterfax_prg;
extern char *fax_inbound;
extern char *fax_connect;
extern char *time_zone;
extern char *hold_area;
extern char *flag_dir;
extern char *domain_area;
extern char *domain_loc;
extern ADDRESS alias[];							/* Array of our addresses, 1st is default */
extern ADKEY *adkeys;							/* Linked list of KEY structures */
extern int num_addrs;
extern int assumed;
extern int last_assumed;

extern int pvtnet;								/* Default fakenet */
extern int Zone;								/* Default Zone */
extern char *BOSSphone;
extern BOOLEAN iosmode;							/* Use 4D addressing */
extern BOOLEAN usecallslots;					/* Use CallSlots instead of Cost */
extern BOOLEAN FDBugfix;						/* Use other code for ZMODEM */

extern char *CurrentNetFiles;
extern char *CurrentOKFile;
extern char *CurrentFILES;
extern char *CurrentAbout;
extern char *CurrentReqTemplate;
extern int CurrentReqLim;
extern long CurrentByteLim;
extern short CurrentTimeLim;			/* Maximum Freq time */

extern char *domain_name[];
extern char *domain_abbrev[];
extern char *domain_nodelist[];

extern byte *Txbuf;                              /* Pointer to transmit
                                                  * buffer              */
extern byte *Secbuf;                             /* Pointer to receive buffer */

#ifdef POPBUF
  extern byte *popbuf;							/* Pointer to popup buffer   */
#endif

extern char *native_protocols;
extern char *extern_protocols;
extern char *protocols[];
extern int extern_index;
extern struct prototable protos[];

extern char *ext_mail_string[];                  /* String for UUCP, etc. */
extern int lev_ext_mail[];                       /* Errorlevel for ext mail */
extern int num_ext_mail;                         /* Number of ext mails   */
extern char *BBSopt;
extern char *BBSbanner;
extern char *BBSreader;
extern char *download_path;
extern char *BBSnote;
extern char *MAILnote;

extern char *BINKpath;
extern char capturename[];
extern char *config_name;

extern char *scan_list[];
extern int  set_loaded;
extern byte user_exits[6];
extern char junk[];

extern PN_TRNS *pn;
extern MDM_TRNS *mm;
extern int boxtype;
extern int modemring;
extern int no_collide;
extern int cursor_col;
extern int cursor_row;
extern char *ans_str;
extern char *keys[];
extern char *shells[];

extern char *prodcode[];

extern char ctrlc_ctr;

extern FOSINFO fossil_info;

extern char no_requests;
extern int who_is_he;

extern int curmudgeon;                           /* 1 = Randy Bush            */
extern int small_window;
extern int no_overdrive;
extern int no_resync;
extern int no_sealink;
extern int immed_update;

extern unsigned janus_baud;
extern BOOLEAN slowjanus;

extern ADDR called_addr;
extern int mail_only;
extern int caller;
extern int more_mail;


extern int doing_poll;

extern char BBSwelcome[];
extern char *aftermail;

extern int slowmodem;

extern PN_TRNS *pn_head;
extern MDM_TRNS *mm_head;

extern unsigned have_mos;
extern unsigned have_dv;
extern unsigned  have_ddos;
extern unsigned have_tv;
extern unsigned have_ml;
extern unsigned int lock_baud;

extern char sending_program[];

extern char e_input[];

extern char *IDUNNO_msg;
extern char *local_CEOL;

extern char *wkday[];
extern int _days[];


extern int requests_ok;
extern int num_events;
extern int cur_event;
extern int next_event;
extern int got_sched;
extern int noforce;
extern int no_zones;
extern int max_connects;
extern int max_noconnects;
extern int server_mode;
extern char *packer;
extern char *cleanup;
extern char *answerback;

extern long etm;
extern long file_length;

extern char *script_path;                        /* Where the script files
                                                  * live */



extern byte Resume_WaZOO;                        /* Flags resumption of
                                                  * aborted WaZOO xfer  */
extern byte Resume_name[];                       /* "Real" name of file being
                                                  * received      */
extern byte Resume_info[];                       /* File size&time info for
                                                  * rx file         */
extern byte Abortlog_name[];                     /* Path of WaZOO aborted
                                                  * xfer log      */

extern COLORS colors;

extern int vfossil_installed;

extern char blanks[];

extern char *logptr;

extern MAILP mail_top;
extern MAILP next_mail;

extern J_TYPESP j_top;
extern J_TYPESP j_next;
extern int janus_OK;
extern char mdm_reliable[];

extern unsigned long cr3tab[];

extern unsigned short crctab[];
extern int leave_dtr_high;
extern char *stat_str;
extern char *script_line;
extern char *BadChars;

extern BOOLEAN no_zapzed;
extern char *BBSesc;
extern char *noBBS;
extern BOOLEAN no_pickup;
extern BOOLEAN no_WaZOO;
extern BOOLEAN no_WaZOO_Session;


extern BOOLEAN SendRSP;
extern char seperators[];

extern int niceoutbound;
extern size_t blklen;
extern int reinit_time;
extern int reinit_ctr;
extern int readhold_time;
extern int readhold_ctr;
#if 0
extern FILE *cost_log;
extern char *cost_log_name;


;
extern int ReqTimeLimit;
extern int SuckerFlag;
extern int SuckerTimeLimit;
extern int cost_unit;
extern int hstls2400c;
extern int no_wildcards;
extern int req_mins;
#endif	/* 0 */

#if defined(__PUREC__) || defined(__TURBOC__)
extern char *CLIcommand;
extern BOOLEAN useCLIcommand;
#endif

extern BOOLEAN HoldsOnUs;
extern STR_LIST *hold_list;
extern BOOLEAN no_EMSI;						/* Disable EMSI */
extern BOOLEAN no_REQUEST;
extern STR_LIST *emsi_list;
extern STR_LIST *request_list;
extern BOOLEAN no_JANUS;
extern BOOLEAN no_Janus_Session;
extern STR_LIST *janus_list;
extern BOOLEAN on_our_nickel;
extern STR_LIST *reqonus_list;
extern STR_LIST *tranx_list;

extern BOOLEAN batch_mode;					/* Running in Batch Mode */

extern void exit_port(void);

#endif	/* H_EXTERNS */
