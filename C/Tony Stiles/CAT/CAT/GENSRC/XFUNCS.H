#ifndef GOT_FUNCS
#define GOT_FUNCS 1

#ifndef MAIN
extern void crson();
extern void crsoff();
extern void cls();
extern void wrap();
extern void phead();
extern void encrypt();
extern void decrypt();
extern void centre();
#endif

#ifndef SHELL1
extern void upper();
extern void lower();
extern void get_input();
extern int calc_weight();
extern void calcw();
extern BOOLEAN isprepv();
extern BOOLEAN isqual();
extern BOOLEAN isqualo();
extern BOOLEAN qualified();
extern int verb_no();
extern int noun_no();
extern void clr_nouns();
extern void add_noun();
extern void get_cmd();
extern BOOLEAN ispath();
extern BOOLEAN paths();
extern BOOLEAN check();
extern BOOLEAN prc_cmd();
extern void load();
extern void save();
#endif

#ifndef SHELL2
extern int getachar();
extern int width();
extern void waitkey();
extern void prn_out();
extern void sscript();
extern void escript();
extern void newline();
extern void endchar();
extern void expand();
extern void prt_text();
extern void ftext();
extern int strfstr();
extern int strfchr();
#endif

#ifndef SHELL3
extern long get_secs();
extern long get_secs();
extern void pause();
extern BOOLEAN yesno();
extern int firstob();
extern int lastob();
extern BOOLEAN isdark();
extern int verbpath();
extern void upd_doors();
extern void pcontents();
extern void look();
extern void enter();
extern void inventory();
extern void pexits();
extern void vocab();
extern void swap();
#endif

#ifndef CLIB
extern char *strchr();
extern char *strstr();
extern char *strtok();
#endif

#endif
