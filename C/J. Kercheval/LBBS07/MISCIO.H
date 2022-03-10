/* Prototypes for functions defined in D:\PROJLINN\LAZYREAD\MISCIO.C */
int get_maxdown(void );
int get_newdown(void );
void set_maxdown(int );
clock_t get_endsession(void);
void set_endsession(int );
char *get_netarea(void);
void set_netarea(char *);
void setgod(void);
int isgod(void);
char *tempfile(void);
int today(void);
int getpasswdstring(char *);
int getstring(char *);
int isokchar(int );
void enable_watch(void);
int carrier(void);
int getkey(void);
void hangup(void);
void out_printf(char *,
                ...);
void out_string(unsigned char *);
void out_char(unsigned char );
void strspins(char *);
void addslash(char *);
char *findword(char *,
               char *);
int iscomment(char );
void strcln(char *,
            char );
char *nextstr(char *);
void strspacecpy(char *,
                 char *);
void logline(int ,
             char *,
             ...);
int open_the_log(char *,
                 int );
void close_the_log(void);
void the_end(void );