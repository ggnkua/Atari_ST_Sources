#include <string.h>      /* String-Library */
#include <tos.h>

/* msg-Konstanten */
#define _ASSIGN       6000  /* Appl meldet sich an   */
#define _GOOD_BYE     6001  /* Appl meldet sich ab   */
#define _SEND_DATA    6002  /* Nutznachricht senden  */
#define _WAIT_TOKEN   6004  /* warte auf token*/
#define _FREE_TOKEN   6005  /* befreie Token  */
#define _UNITIME      6007  /* setze Zeit fÅr ganzen Ring gleich */
#define _STOP_RING    6008
#define _GET_VERW     6009  /* Ring-Karte */
#define _PRKONF       6030

#define maxappl  6
typedef struct 
{ 
    int   what;
    int   size;
    char  *ptr;
    char  *name;
    int   an;
    int   fill;
} msg_typ;

typedef struct
{
  char  *ibuf;  /* Zeiger auf den buffer */
  int   size;    /* groesse des Buffers   */
  int   nw;    /* naechste Leseposition    */
  int   nl;    /* naechste Schreibposition */
  int   blow;    /* untere Wassermarke       */
  int   bhig;    /* obere Wassermarke        */
} io_rec;

typedef struct
 {
  int	prsperr;  /* boolean  (ONLINE-énderung nicht Sinnvoll)*/
  int	ergff;    /* boolean  {true=sende FF nach timeout }   */
  int   my_num;   /* number   (interne Nummer des Rechners    */
  int   errbell;  /* Error-Kontrolle entspricht "errcontrl:" im INF-File*/
  int   time;     /* Timeout-Wert fÅr Drucker-Kontrolle = "timeoutxx:" */
  int   timeff;   /* Timeout-Wert fÅr Drucker-Kontrolle = "timeoutFF:" */
  int   mcspeed;	/* TIMER-Wert fÅr Events = "mcspeeder:" */
  int	timeout;	/* TimeOut-Wert 200 <=> 1 Sek. */
  int   prspeed;  /* Paket-Grîûe fÅr Drucker = "priblocks:"  */
  int   prconf;   /* Drucker-Suche = "setprconf:" */
  long  reciev;		/* ZÑhlvariable fÅr empfangene Datenpakete */
  long  errcnt;   /* ZÑhlvariable fÅr gestîrte Datenpakete  */
  int   TOSOFF;   /* 0=> TOS ein <>0  Keine TOS-Umlenkung */
 } sys_par;

typedef sys_par *syspar;


typedef struct   /* interne Status-Bits !! nicht éndern !! */
 {
 unsigned rest:4;
 unsigned stat:1;   /*bit 11: Statussendung bekommen  */
 unsigned trns:1;   /*bit 10: Druck file_transfer on  */
 unsigned prfree:1; /*bit 9 : 0 = Drucker frei        */
 unsigned appl:1;   /*bit 8 : habe Appl.              */
 unsigned prnt:1;   /*bit 7 : habe einen Drucker      */
 unsigned rts:1;    /*bit 6 : ready to send           */
 unsigned prf:1;    /*bit 5 : prfile in arbeit        */
 unsigned wt:1;     /*bit 4 : warte auf token         */
 unsigned token:1;  /*bit 3 : have token              */
 unsigned rtw:3;    /* ready to work                  */
} status;
      /* zu Status:  bit 0 : sync erhalten          */
      /*             bit 1 : test erhalten          */
      /*             bit 2 : ready to work          */
      /*     Bit 5 ist gesetzt, wenn kein eigener   */
      /*     Drucker vorhanden ist, und der Text    */
      /*     uebertragen werden muss                */

typedef union
 { int wert;
   status bits;
 } bit_test;

/* Die Verwaltungstruktur ist in einem Array untergebracht. Ist der Ring aktiv,
   so findet man hier die Informationen zum eigenen als auch zu den anderen 
   Rechnern. "SYS.MY_NUM" ist dabei der Index fÅr den Record des eigenen Rechners.
   Ist der Ring nicht aktiv, so hat SYS.MY_NUM den Wert 7 */

typedef struct
{
  char      my_name[maxappl][10];  /* Appl. Name  z.B.: bei MC-TALK*/
  char      r_name[10];   /* Wert der Variablen "Vrechner1:" */
  bit_test  status;   /* integer; { Status-Bits }*/
  int       disk_st;  /* integer;*/
} verwaltung;

#ifndef _COOKIE_H
#define _COOKIE_H

union clong {
	char	aschar[4];
	long	aslong;
};

struct cookie {
	union clong tag;
	long value;
};

typedef struct cookie COOKIE;

#define CJAR	((COOKIE **) 0x5a0L)

#endif /* _COOKIE_H */

typedef struct cinfo {
		char	*params;
		long	*kernel;
		int		LW;
		long	cdecl (*mygemdos)(msg_typ *pars);
}CINFO;

typedef verwaltung procs[8];
typedef procs *all_proc;

static	CINFO	*infos=0L;
static	int		MiNT=0;

/* Prototypen */
long cdecl    trap111 (msg_typ *msg);

#define MC_direct_call (*infos->mygemdos)

/*extern	long 	get_cookie(void);*/
extern	int		get_mc_sys(syspar *sys,all_proc *allprocs);
extern	long	mc_message(msg_typ *mc_msg);
extern	long	write_message(int what, int apl_num, int an, int size,char *name,void *ptr);

extern	int		anmeld_ring(char *name,int buff_size);
extern	void	abmeld_ring(void);
extern	long	transmit(int size,int an,char *name,void *dat_adr);
extern	int		lese(char *bufa1,int *esc,int *len);
extern	void	get_Karte(void);
extern	void	set_unitime(void);
extern	int		mc_busy(void);
extern	int		mc_closed(void);
extern	int		mc_neustat(void);




