/*
 * NEWSie - an Internet NewsReader Program with GEM Interface
 *
 * Created by: John Rojewski - 06/28/96
 *
 */

/* global variables */

FILE *log=NULL;		 /* log file pointer */
OBJECT *menu_ptr;
OBJECT *em;			/* Error_Message tree */
short screenx,screeny,screenw,screenh;
int radio;
int finished=0;
char edit[20];
/* int handle; */
int charw, charh, cellw, cellh;
int sx,sy,sh,sw;
OBJECT *sd;
int handle, phys_handle;
int	work_in[12], work_out[57];
GRECT clip;
char article_title[20];
char current_article[FMSIZE];
char current_newsgroup[FMSIZE];
char program_path[FMSIZE];
char user_password[30];
char current_url[80] = "http://www.primenet.com/~rojewski/newsie.html";
char current_mailmsg[FMSIZE];
char current_mailbox[FMSIZE];
char current_helpfile[FMSIZE];
char article_path[FMSIZE];
char ftp_server_path[FMSIZE];
char ftp_viewer_path[FMSIZE];
long STiK=0;	/* >0 means STiK exists */
time_t sort_clock,sort_number,sort_swap;

int sppos=0;
int fakemse[3]={5,6,7};
MFORM spmse[4];

#define WINDOWS_SIZE 15
struct win {
	int id;
	int type;
	int components;
	int line_no;
	int prev_line_no;
	int num_lines;
	int lines_per_page;
	int reread;
	int clear;
	int open;
	int x,y,w,h;
	size_t position;	/* available for filepos() */
	char title[80];		/* max needed should be 50 */
	char info[80];		/* max needed should be 50 */
	int full;
	int bar_index;
	OBJECT *bar_object;
	char *buffer;
	int releasebuf;
} windows[WINDOWS_SIZE];

struct newsgroups {
	long num_msgs;
	char name[50];
	long first_msg;
	long last_msg;
	char viewed;
	char posting_allowed;
};
struct newsgroups *group=NULL;		/* define newsgroups pointer */
int GROUP_SIZE=100;
int current_group=-1;
int maximum_group=-1;

struct xoverview {
	long article_number;
	char subject[40];
	char author[40];
	char author_email[40];
	char datetime[22];
	char msgid[81];	/* was 50 0.94 and before */
	char refids[300];
	long num_bytes;
	long num_lines;
	char viewed;
	char thread;
	char attachment;
};
struct xoverview *overview=NULL;	/* define overview messages pointer */
int OVERVIEW_SIZE=200;	/* was 400 0.94 and before */
int current_overview=-1;
int previous_overview=-1;
int maximum_overview=-1;

struct athread { int zero; int one; };
struct athread *threads;		/* define threads pointer */
int current_thread=-1;

struct agroup { char x[50]; };
struct agroup *newgroups;		/* define newgroups pointer */
int NEWGROUPS_SIZE=80;
long current_newgroups=-1;

struct agroup *fullgroups;		/* define fullgroups pointer */
int FULLGROUPS_SIZE=80;
long current_fullgroups=-1;

int FULLINDEX_SIZE=150;
size_t *fullgroup_index=NULL;		/* fullgroup index entries */

struct fontinfo {
	int index;
	char name[35];
};
struct fontinfo *font=NULL;		/* available font name list */
int FONT_SIZE=50;

struct preferences {
	char news_server[41];
	char mail_server[41];
	char pop_server[41];
	char connect_startup;
	char subscribe_startup;
	char to_maximum[4];
	char to_last_char[4];
	char full_name[40];
	char organization[40];
	char account_name[40];
	char email_address[46];
	char show_authors;
	char show_headers;
	char collapse_threads;
	char create_threads;
	char allow_kbd_nav;
	char offline_test;
	char show_status;
	char erase_articles;
	char use_ext_viewer;
	char max_articles[4];
	char recent_articles[5];
	char reply_via_posting;
	char reply_via_email;
	char copies_to_self;
	char append_signature;
	char quote_string[3];
	char signature_file[FMSIZE];
	char mail_path[FMSIZE];
	char work_path[FMSIZE];
	char external_viewer[FMSIZE];
	char external_editor[FMSIZE];
	char news_font[35];
	char news_font_size[3];
	char newsgroup_font[35];
	char newsgroup_font_size[3];
	char overview_font[35];
	char overview_font_size[3];
	char log_data;
	char log_commands;
	char log_responses;
	char delete_mail_from_server;
	char use_saved_password;
	char password[30];
	char last_version[8];
	char delete_queued_mail;
	char send_queued_at_check;
	char offline_path[FMSIZE];
	char log_mask_pswds;
	char auto_top;
	char ftp_send_help;
	char ftp_save_last_dir;
	char ftp_send_alloc;
	char ftp_use_port;
	char ftp_savelower;
	char show_toolbar;
	char auto_language;
	char selected_language[18];
	char window_buffers;
	char dynamic_expansion;
	char show_bubble_help;
	char registration_number[10];
	char ftp_download_path[FMSIZE];
	char browser_cache_path[FMSIZE];
	char browser_home[FMSIZE];
	char browser_hotlist[FMSIZE];
	char browser_history;
	char auto_extract;
	char use_info_status;
	char mail_directories;
	char mime_headers;
	char experimental[20];
} prefs;

struct mbox {
	char status[5];
	char author[80];
	char author_email[50];
	char subject[50];
	char datetime[22];
	char filename[FMSIZE];
	long num_lines;
	char attachment;
	long cmpdate;	/* long equivalent of date for sorting */
};
struct mbox *mailbox=NULL;		/* define mailbox pointer */
int MAILBOX_SIZE=100;
int current_mail=-1;
int previous_mail=-1;
int maximum_mail=-1;
int next_mail_number=1;

MFORM mouse[4];
int mspin;

struct mhdr {
	char subject[80];
	char from[80];
	char reply_to[80];
	char to[80];
	char datetime[30];
	char status[5];
	char mime_version[20];
	char mime_type[80];
	char mime_encoding[80];
	char mime_disposition[80];
} mail_hdr;

struct nhdr {
	char subject[80];
	char from[80];
	char reply_to[80];
	char followup_to[80];
	char datetime[30];
	char msg_id[80];
	char ref_id[300];
	char xref[300];
	int lines;
} news_hdr;

struct nick {
	int nick;
	int tag;
	char data[60];
};
struct nick *nickname=NULL;		/* define nickname pointer */
int NICKNAME_SIZE=100;
int current_nick=-1;
int maximum_nick=-1;


struct fpath {
	char directory[FMSIZE];
	char filename[FMSIZE];
};
struct fpath *ftp_cache=NULL;		/* define ftp cache pointer */
int FTP_CACHE_SIZE=30;
int current_cache=-1;

struct flist {
	char status[12];
	char date[8];
	char time[6];
	long size;
	char filename[80];
};
struct flist *filelist=NULL;		/* define ftp directory list pointer */
int FTP_FILELIST_SIZE=200;
int current_file=-1;
int previous_file=-1;
int maximum_file=-1;

struct fservers {
	char name[41];
	char user[41];
	char password[41];
	char directory[FMSIZE];
	char port[5];
};
struct fservers *server=NULL;		/* define ftp servers pointer */
int SERVER_SIZE=30;
int current_server=-1;
int maximum_server=-1;	

char current_directory[FMSIZE];

#define FKEY_SIZE 20
char fkeys[FKEY_SIZE][50];		/* 20 50-character strings */

typedef struct abk {
	char name[50];
	char email[60];
	char password[40];
} A_BOOK;

A_BOOK *Addr_Book=NULL;
int current_abook=-1;
int previous_abook=-1;
int maximum_abook=-1;	

char current_address_book[FMSIZE];

char current_browse[FMSIZE];
/*	char browse_cache[FMSIZE]; */
char current_preferences[FMSIZE];
char current_nicknames[FMSIZE];



