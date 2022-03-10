#define FIRSTCHAR ' '
#define MAXCHAR 0377
#define MAXBUFF 8192
#define MAXSIZE 100
#define MAXPATS 100 /* max number of patterns */
#define PSIZEDEF 1024 /* space for patterns if they come from a tty */
#ifndef min
#define min(x,y) ((x) < (y) ? (x) : (y))
#endif
#ifndef max
#define max(x,y) ((x) > (y) ? (x) : (y))
#endif
struct PattDesc {
	unsigned short *Skip1, *Skip2; /* pointers to skip tables */
	char *Pattern;
	int PatLen; /* pattern length */
	char *Start;
	/* starting position of search (at beginning of pattern) */
	int Success; /* true when pattern found */
};
#define index(a,b) strchr(a,b)
#define cfree(a) free(a)

extern char *strchr();
