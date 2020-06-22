
#define SIG_REPLACE     3
#define SIG_TRANSPARENT 7
#define SIG_LEFT        0
#define SIG_CENTER      1
#define SIG_RIGHT       2

#define SIG_BASE        0
#define SIG_MIDLE       1
#define SIG_TOP         2

#define SIG_UNDER       1
#define SIG_FETT        2
#define SIG_HELL        4
#define SIG_ITALIC      8

#define NICHT        1234

void set_sigpar(int leer,int sperr,int zeil,int wmode,
                int style,int hpos,int vpos);
                
int prt_text(int x,int y,char *s);
int load_sigFont(char *s);
void unload_sigFont(void);
