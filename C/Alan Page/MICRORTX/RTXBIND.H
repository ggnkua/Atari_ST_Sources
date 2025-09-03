/************************************************************************/
/*									*/
/*	RTXBIND.H							*/
/*									*/
/*	(C) Copyright 1986, Beckemeyer Development Tools		*/
/*	All Rights Reserved						*/
/*									*/
/*	C declarations for RTX interface to Alcyon C.			*/
/*									*/
/************************************************************************/

extern char *rtx_install();
extern char *p_create();
extern int p_delete();
extern int p_priority();
extern int p_slice();
extern char *q_create();
extern int q_delete();
extern int q_send();
extern int q_req();
extern int q_jam();
extern int e_signal();
extern int e_wait();
extern int p_pause();
extern char *m_alloc();
extern int m_free();
extern int m_assign();
extern char *p_lookup();
extern char *q_lookup();
extern char *p_info();
extern long p_vector();
extern int p_suspend();
extern int p_resume();
extern int d_install();
extern long d_cntrl();
extern int q_info();
extern int rtx_remove();

struct config {
	char *basepage;
	int max_proc;
	int max_msgs;
	int max_queues;
	int (*create_call)();
	int (*delete_call)();
	int (*switch_call)();
};

	
/* some helpful definitions */
#define WAIT 0
#define NO_WAIT 1
#define FOREVER 0L

/*
 * RTX GEMDOS extensions
 */
extern long gemdos();

#define	Popen(a)	gemdos(0x100,a)
#define Ftype(a)	gemdos(0x101,a)
#define Flock(a,b,c,d)	gemdos(0x102,a,b,c,d)
#define Psettpa(a)	gemdos(0x103,a)
#define Fcntrl(a,b)	gemdos(0x104,a,b)
#define Mquota(a)	gemdos(0x105,a)
/*
 * RTX TTY control extensions
 */
#define FD_NOECHO	0x0080
#define FD_RAWIO	0x0100
