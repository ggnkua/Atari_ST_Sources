/*
 *	Misc header for LazyTick/LazyFix
 *	(LazyTick/LazyFix Project)
 *   
 *	Public Domain: may be copied and sold freely
 */

void close_areas(void);
ECHOLIST *get_area(char *);
int debug_areas(void);
int open_areas(char *);
int copyfile(char *,
             char *);
int postmsg(char *,
            char *,
            char *,
            char *,
            char *,
            char *,
            char *,
            int );
void the_end(int );
void strspins(char *);
char *fticgets(char *,
               size_t ,
               FILE *);
int strendcmp(char *,
              char *);
unsigned long xtol(char *);
char *nextstrtic(char *);
int strticcmp(char *,
              char *);
void addslash(char *);
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
