/* def's fÅr ASCIIDAT.C */

int fi_rewind(void);
void fi_close(void);
int fi_open(char *);
int fi_head(fileheader *);
int fi_row(int,int,int, double *);
void fo_close(void);
int  fo_open(char *);
int fo_head(fileheader *);
int fo_row(int,int,int, double *);
