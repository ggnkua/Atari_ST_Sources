/* Prototypes for functions defined in loadbind.c */

#ifndef __NOPROTO
#ifndef __PROTO
#define __PROTO(a) a
#endif
#else
#ifndef __PROTO
#define __PROTO(a) ()
#endif
#endif

int Dsp_Init __PROTO((void));
int DspFlushSubroutines __PROTO((void));
int DspLdSubroutine __PROTO((long codeptr,
                             long size,
                             int ability));
long DspLodToBinary __PROTO((char *file,
                             char *dspbuff));
int DspLdProg __PROTO((char *file,
                       int ability,
                       long codeptr));
int DspExProg __PROTO((char *codeptr,
                       long codesize,
                       int ability));
static int strcmp1 __PROTO((register char *bufstr,
                            register char *tablestr,
                            int len));
static int is_token __PROTO((void));
static int get_token __PROTO((void));
static int newline __PROTO((void));
static int make_int __PROTO((void));
static int put_dspword __PROTO((char a,
                                char b,
                                char c));
static int stuff_header __PROTO((char memtype));
static int make_dspword __PROTO((void));
static int convert_line __PROTO((void));
static int move_to_endoftoken __PROTO((int index));
static int do_convert __PROTO((void));
static int convert_file __PROTO((char *buffer));
static int read_dspcode __PROTO((char *fname));
static int free_dspcode __PROTO((void));
