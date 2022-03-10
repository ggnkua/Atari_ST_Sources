/* Prototypes for functions defined in D:\PROJLINN\LAZYREAD\MSG.C */
void close_areas(void);
ECHOLIST *choose_area(char *);
int get_areas(char *);
int postmsg(char *,
            char *,
            char *,
            char *,
            char *,
            char *,
            char *,
            int );
int load_msgbuf(char *,
                long ,
                unsigned int ,
                char *);
int is_newmail(char *,
               int *,
               int *);
void list_messages(FILE *,
                   char *,
                   int );
void read_messages(char *,
                   char *,
                   char *,
                   char *,
                   int ,
                   int );
