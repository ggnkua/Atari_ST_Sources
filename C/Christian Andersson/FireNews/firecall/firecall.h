#define LOGGING
/********************************************************************/
/* Include filer                                                    */
/********************************************************************/
#include <stdio.h>
#include <osbind.h>
#ifndef INSTALL
  #include <gemlib.h>
  #include "..\windia\win_dia.h"
#endif
/********************************************************************/
#include "..\fire.h"
#include "..\list.h"
#ifndef INSTALL
  #include "fireconf\firecall.h"
#endif
/********************************************************************/
/* Deklarationer av funktioner                                      */
/********************************************************************/
/* Initiating Routines                                              */
#ifndef INSTALL
  void      deinit(void);
  int       init(int argc, char *argv[]);
  int       init_default(int argc, char *argv[]);
  int       init_appl(void);
  int       init_graf(void);
  int       init_rsc();
  int       init_cfg(int svar);

/* File Routines                                                    */
  long int  load_datafile(char *namn, char **memory,long int fsize);
  int       save_datafile(int type,char *namn, char *memory,long int fsize);

/* User Interface Routines                                          */
  void      check(void);
  void      check_infowin(RESULT svar);
  void      check_registerwin(RESULT svar);

/* Modem routines */
  void check_port();
  void port_interrupt();
  int  init_port();
#endif
/********************************************************************/
/********************************************************************/

#define CONFIGFILE  "firecall.cfg"
#define LOGFILE     "firecall.log"
#define BAKFILE     "firecall.bak"
#define DATAFILE    "firecall.dat"
#define NUMFILE     "firecall.num"
#define EVENTFILE   "firecall.evn"
#define RESURS      "firecall.rsc"
#define RESURS2     "firecall.rsc"
#define VALIDKEY    "D8qazxCsw2QTASZX39dvrf4VFREbnhgte6y5YcBNG71MkmJIijUuKlpoLPO0WH"
#define VERSION     "0.90"
#define VERSION_DTA "FC 0.90"
#define VERSION_CFG "FC 0.90"

#define PORT_TIME   1000
#define PORT_NUMS   200
#define MAX_UNREG   10
#define SIZE_NAME   31
#define SIZE_NUMB   21
#define SIZE_TIME   13
#define SIZE_DATE   6
#define SIZE_ID     8
#define SIZE_FILE   8
#define SIZE_ALLOC  20
#define SIZE_PATH   256
#define LOG_SIZE    20
#define LENGTH_LOG  (SIZE_TIME+SIZE_NUMB+SIZE_NAME+3)
#define PHONE_MAX   20
#define DIALWAIT    4*CLOCKS_PER_SEC

#define PC_CALLFIND 1
#define PC_LISTVIEW 2
#define PC_LOGFIND	3
#define PC_NEW      4
#define PC_LISTEDIT 5
#define PC_LOGSCAN  6

#define SORT_NAME   0
#define SORT_NUMBER 1

#define FLAG_BLACK  1

typedef struct
{
  int                type;
  char               data1[255],
                     data2[255];
}EVENT_DATA;

typedef struct
{
  char               name[SIZE_NAME],
                     info1[SIZE_NAME],
                     info2[SIZE_NAME],
                     info3[SIZE_NAME],
                     date[SIZE_TIME],
                     number[SIZE_NUMB],
                     notefile[SIZE_FILE];
  int                times,
                     flags;
  long               event_num;
}PHONE_DATA;

typedef struct RSVF_OBJECT
{
	char          *name;
    unsigned char	func,
                    niu0,
                    dev_num,
                    niu1;     
}RSVF_OBJECT;

typedef struct
{
  int                arg_menu    :1,
                     registered  :1,
                     conf_change :1,
                     list_change :1,
                     edit_num    :1,
                     accessory   :1,
                     popup_close :1,
                     new_line    :1;
  int                num_phones,num_log,num_calls;
  int                offset_list,offset_log,
                     portnum,port_counter,port_lock,
                     popup_counter;
  PHONE_DATA        *phonedata;
  RSVF_OBJECT        *port[10];
  char               lastpath[MAXSTRING],
                     lastfile[MAXSTRING],
                     message[MAXSTRING],
                     serialpop[MAXSTRING],
                     speedpop[MAXSTRING],
                     last_num[SIZE_NUMB],
                     *num_list;
  long               portfile,menu_id;
  short              dummy;                     
}VARIABLES;

typedef struct
{
  char               id[SIZE_ID],
                     name[SIZE_NAME],
                     adr1[SIZE_NAME],
                     adr2[SIZE_NAME],
                     adr3[SIZE_NAME],
                     key[SIZE_NAME],
                     messwait[SIZE_NAME],
                     portinit[SIZE_NAME],
                     dialcommand[SIZE_NAME],
                     linecommand[SIZE_NAME],
                     port[13];
  long               port_speed;
  int                log_number,
                     export_type,
                     popup_time;
  int                save_exit   :1,
                     disabled    :1;
}CONFIG_075;

typedef struct
{
  char               id[SIZE_ID],
                     name[SIZE_NAME],
                     adr1[SIZE_NAME],
                     adr2[SIZE_NAME],
                     adr3[SIZE_NAME],
                     key[SIZE_NAME],
                     messwait[SIZE_NAME],
                     portinit[SIZE_NAME],
                     dialcommand[SIZE_NAME],
                     linecommand[SIZE_NAME],
                     port[13];
  long               port_speed;
  int                log_number,
                     export_type,
                     popup_time;
  int                save_exit   :1,
                     disabled    :1;
  char               editor[SIZE_PATH];
}CONFIG;

#ifdef LOGGING
#define COMMAND_LOG     "-LOG"
#define LOG_MAXTYPES    20
#define LOG_STRINGSIZE  80
#define LOG_FILEOP      "F"
#define LOG_MEMORY      "M"
#define LOG_WINDOW      "W"
#define LOG_ERROR       "E"
#define LOG_GENERAL     " "
#define LOG_INIT        "I"
#define LOG_AESMESSAGE  "A"
#define LOG_DIALOG      "D"
typedef struct
{
	int  on  :1,
	     all :1;
	char what[LOG_MAXTYPES+1];
	char mess[LOG_STRINGSIZE+1];
}LOGG;
#endif

#ifndef INSTALL
  #include "variable.h"
#endif