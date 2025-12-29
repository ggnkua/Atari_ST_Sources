/* globals */
char *win     [WINSIZE];
char *mycall  [MAXMYCALLS+1];
char *month   [12];
char dum      [10][MAXGET+1];
char destnam  [MAXGET+1];
char destfile [MAXGET+1];
char extract  [MAXGET+1];
char srcfile  [MAXGET+1];
char codepath [MAXPATH];
char perspath [MAXPATH];
char genpath  [MAXPATH];
char *search  [MAXSEARCH+1];
char text     [MAXGET+1];
char mbox     [17];
int  boxtype;
int  codetype;
int  debug;
int  ignore;
int  numbers  [1001];
size_t  buflen;

struct mbhead mbhead[MAXMBTYPES+1];
struct prompt *prompt;
struct code   code[MAXCOTYPES+1];