/* 'definition'-module von calc.c */

extern boolean counted3d;  /* 3d counted or not */
extern boolean counted2d;  /* 2d counted or not */
extern boolean funcgiven;  /* function ok or not*/
extern boolean filegiven;
extern boolean funcinput;
extern boolean countedfl;  /* fl„chen counted or not */
extern boolean shadowed;
extern boolean inferior;

void release_all(void);
void draw_function(void);
int make_list(char *);
void count_shadows(char *);
int calc3d(char *);
int calc2d(char *);

