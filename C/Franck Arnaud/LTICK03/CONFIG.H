/* lazytick config.h */

typedef struct _ticann {
	char area[BBSSTR];
	char group[BBSSTR];
	char footer[BBSSTR];
	struct _ticann *next;
} BTCKANN;

typedef struct _fixperm {
	char group[BBSSTR];
	char nodes[BBSSTR];
	struct _fixperm *next;
} BFIXPERM;

typedef struct _passw           /* structure for passwords */
{
  char passw[8];        /* the password itself */
  int zone;        /* zone number for remote */
  int net;         /* net number for remote */
  int node;        /* node number for remote */
  int point;       /* point number for remote */
  int my_aka;          /* the number in the addresslist for this sucker */
  struct _passw *next;  /* pointer to next struct */
} BPASSWORD;

typedef struct _aka
{
 int zone;
 int net;
 int node;
 int point;
 int pointnet;
} BAKA;

/* Prototypes for functions defined in D:\PROJLINN\LAZYTICK\CONFIG.C */
void close_config(void);
void debug_config(void);
int open_config(void);
void parsekey(char *);
int getint(char **,
           int *);
int getaddress(char *,
               int *,
               int *,
               int *,
               int *);
char *skip_blanks(char *);
char *skip_to_blank(char *);
void ctl_string(char *,
                char *);
void ctl_path(char *,
              char *);
void ctl_file(char *,
              char *);
BFIXPERM *get_perms(void);
BFIXPERM *get_fperms(void);
BTCKANN *get_announce(void);
int get_out_fname(char *,
                  int ,
                  int ,
                  int ,
                  int );
void put36(char *,
           unsigned int ,
           int );
void get_password(char *,
                  int ,
                  int ,
                  int ,
                  int );
void get_ouraddress(FIDONODE *,
                    int ,
                    int ,
                    int ,
                    int );
char *get_netmail(void);
char *get_inbound(void);
char *get_outbound(void);
char *get_sysop(void);
char *get_ticktemp(void);
