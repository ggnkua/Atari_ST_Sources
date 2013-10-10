#ifndef _DEB_DEFS_H_
#define _DEB_DEFS_H_

#define TRUE				1
#define FALSE				0

#define NUM_BREAKPOINTS		20
#define NUM_WATCHS			10

#define TM_VT52		1
#define TM_VT100	2

typedef struct context {
	unsigned long regs[15];
	unsigned long usp;
	unsigned short sr;
	unsigned long pc;
	unsigned long ssp;
	unsigned long tvec;
	char fstate[216];
	long fregs[3*8];
	long fctrl[3];
} CONTEXT;

extern short debug_handle;
extern long debug_address;
extern long debug_ctxtsize;

typedef struct {
	unsigned short *addr;
	unsigned short op_code;
} BREAKPOINT;

typedef struct {
	unsigned long line;
	unsigned long addr;
} LINE_INFO;

typedef enum {SYM_FUNCTION,SYM_VARIABLE} SYMBOL_TYPE;

typedef struct {
	unsigned long addr;
	char name[40];
	SYMBOL_TYPE t;
} SYMBOL_TABLE;

typedef struct {
	unsigned long addr;		/* Start address of module */
	char *module_name;
	char *full_path;
	short path_len;
	LINE_INFO *lines;
} DEBUG_INFO;

typedef enum { WT_WORD, WT_LONG, WT_CHAR, WT_PWORD, WT_PLONG, WT_PCHAR } WATCH_TYPE;

typedef struct {
	void *addr;
	WATCH_TYPE t;
} WATCH;

