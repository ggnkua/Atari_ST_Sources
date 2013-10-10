/********************************************************************/
/* Include filer                                                    */
/********************************************************************/
#include <stdio.h>
#include <osbind.h>
#include <gemlib.h>
#include "..\windia\win_dia.h"
/********************************************************************/
#include "..\fire.h"
#include "fireconf\firetext.h"
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
void      check_pathwin(RESULT svar);
void      check_registerwin(RESULT svar);
/*   Mailmsg routines                                               */
int       write(char *filename);
int       write_message(char *buffer,int newmsg);
int       open_area(int areanumber);

/********************************************************************/
/********************************************************************/
#define CONFIGFILE  "firecall.cfg"
#define RESURS      "firecall.rsc"
#define RESURS2     "firecall.rsc"

#define SIZE_AREA   50
#define SIZE_NUMB   20
#define SIZE_NAME   30
#define VALIDKEY    "CsIijU0WHD6y2QTASZX398qazGxwLdvrf4VFRPO5YcBNGEbnhteuKlpo71MkmJ"

#define ENDMSG       0
#define NEXTMSG      1
#define CONTMSG      2
 
#define COM_FROM     "From: "
#define COM_TO       "To: "
#define COM_SUBJ     "Subject: "
#define COM_AREA     "Area: "
#define COM_ADRESS   "Adress: "

typedef struct
{
  short int          newmsg;
  char               text[MAXSTRING];
  char               area[ROWSIZE];
}AREADATA;

typedef struct
{
  int                num_areas,sel_area;
  int                date_com;
  int                e_space     :1,
                     newfile     :1,
                     registered  :1,
                     areasbbs    :1,
                     arg_menu    :1,
                     msg_com_end :1,
                     quiet_mess  :1,
                     conf_change :1;
  char               kludge[MAXMSGSIZE],
                     filename[MAXSTRING];
}VARIABLES;

typedef struct
{
  char               name[SIZE_NAME],
                     adr1[SIZE_NAME],
                     adr2[SIZE_NAME],
                     adr3[SIZE_NAME],
                     key[SIZE_NAME];
  char               areasbbsfile[MAXSTRING],
                     lednewfile[MAXSTRING],
                     lastpath[MAXSTRING],
                     lastfile[MAXSTRING];
}CONFIG;

typedef struct
{
  char               file[MAXSTRING],
                     area[ROWSIZE],
                     from[ROWSIZE],
                     f_adress[ROWSIZE],
                     subj[ROWSIZE],
                     to[ROWSIZE],
                     t_adress[ROWSIZE],
                     dates[MAXSTRING];
  int                override_area   :1,
                     override_from   :1,
                     override_subj   :1,
                     override_to     :1;
}TEXTCONFIG;

#include "variable.h"
