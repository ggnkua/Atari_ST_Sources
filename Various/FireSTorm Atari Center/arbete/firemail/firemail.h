/********************************************************************/
/* Include filer                                                    */
/********************************************************************/
#include <stdio.h>
#include <osbind.h>
#include <gemlib.h>
#include "..\windia\win_dia.h"
/********************************************************************/
#include "..\fire.h"
#include "fireconf\firemail.h"
#include "..\fido.h"

/********************************************************************/
/* Deklarationer av funktioner                                      */
/********************************************************************/
/* Initiating Routines                                              */
void      deinit(void);
int       init(void);
void      init_default(void);
int       init_appl(void);
int       init_graf(void);
int       init_rsc();
int       init_cfg(int svar);
/* File Routines                                                    */
long int  load_datafile(char *namn, char **memory,long int fsize);
int       save_datafile(int type,char *namn, char *memory,long int fsize);
int       load_areasbbs(char *memory);
/* User Interface Routines                                          */
void      check(void);
void      check_infowin(RESULT svar);
void      check_userwin(RESULT svar);
void      check_adduserwin(RESULT svar);
void      check_pathwin(RESULT svar);
void      check_routewin(RESULT svar);
void      check_registerwin(RESULT svar);
/*   Mailmsg routines                                               */
int       import(void);
int       import_message(char *buffer,int newmsg);

/********************************************************************/
/********************************************************************/
#define CONFIGFILE  "firemail.cfg"
#define USERFILE    "firemail.usr"
#define AREAFILE    "firemail.are"
#define RESURS      "firemail.rsc"
#define RESURS2     "firemail.rsc"

#define SIZE_AREA   50
#define SIZE_MAIL   30
#define MAILTO      "Internet"
#define VALIDKEY    "91qazxsw2QWTASZX3edcvrf4VCFDREbnhgt6y5YBNHG7MKkmJIijUu8lpoLPO0"
 
 
#define M_FROM       "From "
#define M_FROM2      "From: "
#define M_TO         "To: "
#define M_SUBJECT    "Subject: "
#define M_REPLY      "Reply-To: "
#define M_DATE       "Date: "
#define M_RECEIVED   "Received: "
#define M_MSGID      "Message-Id: "
#define M_MIME       "Mime-Version: "
#define M_MCONT      "Content-Type: "
#define M_MTRAN      "Content-Transfer-Encoding: "
#define M_MAILER     "X-Mailer: "
#define M_STATUS      "Status: "

#define MIME_CONT1   "TEXT/PLAIN "
#define MIME_CHAR    "CHARSET="
#define MIME_CHAR1   "US-ASCII"

#define ENDMSGS      0
#define NEXTMSG      1
#define CONTMSG      2
 
#define TYPE_MLIST   0
#define TYPE_NEWS    1
#define TYPE_KILL    2

#define TYPEM_MSUBJ  0
#define TYPEM_MFROM  1
#define TYPEM_NEWS   2
#define TYPEM_KILL   3

#define ROUTE_VIEW   0
#define ROUTE_ADD    1
#define ROUTE_EDIT   2
#define ROUTE_MAX    100

typedef struct
{
  short int          type;
  char               text[MAXSTRING];
  char               area[ROWSIZE];
}AREADATA;

typedef struct
{
  int                active_area,old_area;
  int                num_areas,num_area1,num_area2,num_user;
  int                route_num,route_area,route_type,route_action,route_offset;
  int                time;
  AREADATA           *route_pointer;
  int                e_space     :1,
                     mime        :1,
                     newfile     :1,
                     registered  :1,
                     areasbbs    :1,
                     add_user    :1,
                     route_found :1,
                     msg_com_end :1,
                     arg_help    :1,
                     arg_menu    :1,
                     arg_impo    :1,
                     arg_expo    :1,
                     conf_change :1;
  char               kludge[MAXMSGSIZE];
}VARIABLES;

typedef struct
{
  short int          zone,
                     net,
                     node,
                     point;
  char               name[NAMESIZE];
  long int           switches;
}USERDATA;

typedef struct
{
  char               name[30],
                     adr1[30],
                     adr2[30],
                     adr3[30],
                     key[30];
  int                zone,net,node,point;
  char               i_source[MAXSTRING],
                     i_destination[MAXSTRING],
                     areasbbsfile[MAXSTRING],
                     lednewfile[MAXSTRING],
                     logfile[MAXSTRING];
}CONFIG;

#include "variable.h"
