#define LOGGING
/********************************************************************/
/* Include filer                                                    */
/********************************************************************/
#include <stdio.h>
#include <osbind.h>
#include <gemlib.h>
#include "..\windia\win_dia.h"
#include "..\fire.h"
#include "..\list.h"
#include "fireconf\firenews.h"
/********************************************************************/
/********************************************************************/

#define TEMP_MESSAGE     "TEMP.MSG"
#define ACTIVEFILE       "active"
#define CONFIGFILE       "firenews.cfg"
#define USERFILE         "firenews.set"
#define HELPFILE         "firenews.hyp"
#define RESURS           "firenews.rsc"
#define RESURS2          "firenew2.rsc"
#define VALIDKEY         "71MkmJIhgtCsw2Qf4NTASZX39dvD8qazREe6y5YcBGijxbnrVFUuKlpoLPO0WH"
#define HEADEREXT        ".INH"
#define MESSAGEEXT       ".INM"
#define GROUPEXT         ".NGP"
#define GROUPDSCEXT      ".DSC"
#define GROUPNEWEXT      ".NEW"
#define VERSION          "0.80"
#define NEWSID           "NEWS"
#define NEWSVER          "0.50"

#define STIK_HOSTNAME    "HOSTNAME"
#define STIK_EMAIL       "EMAIL"

#define SIZE_NAME        31
#define SIZE_NUMB        21
#define SIZE_TIME        13
#define SIZE_DATE        7
#define SIZE_ID          8
#define NEWS_SUBJECTSIZE 64
#define NEWS_FROMSIZE    64
#define SIZE_FONT        32
#define MESSAGE_ALLOC    40
#define GROUP_ALLOC      10

#define ANT_PATH_NUM     15
#define ANT_OUT_PATH     "OUTGOING\\"
#define ANT_BACKUP_PATH  "BACKUP\\"

#define MAILTYPE_T_ANTMAIL "Antmail"
#define MAILTYPE_T_NEWSIE  "Newsie"
#define MAILTYPE_T_INFITRA "Infitra"
#define MAILTYPE_T_MYMAIL  "Mymail"
#define MAILTYPE_ANTMAIL   0
#define MAILTYPE_NEWSIE    1
#define MAILTYPE_INFITRA   2
#define MAILTYPE_MYMAIL    3

#define MESSAGE_LIST     "%-6s %5d %-31s %-41s"
#define MSG_HEAD_TO      "To: %s\n"              /* e_mail,(full_name?)              */
#define MSG_HEAD_PATH    "Path: "                /*                                  */
#define MSG_HEAD_FROM    "From: %s <%s>\n"       /* full_name, e_mail                */
#define MSG_HEAD_DATE    "Date: %s\n"            /* date/time                        */
#define MSG_HEAD_GROUP   "Newsgroups: %s\n"      /* group_name                       */
#define MSG_HEAD_SUBJ    "Subject: %s\n"         /* subject                          */
#define MSG_HEAD_MSGID   "Message-ID: %s\n"      /* unique-e-mail-id                 */
#define MSG_HEAD_REPLY   "Reply-To: %s <%s>\n"   /* full_name, e_mail                */
#define MSG_HEAD_SEND    "Sender: %s (%s)\n"     /* e_mail, full_name                */
#define MSG_HEAD_FOLOW   "Followup-To: %s\n"     /* group_name                       */
#define MSG_HEAD_EXPIR   "Expires: %s\n"         /* date/time                        */
#define MSG_HEAD_REF     "References: %s %s\n"   /* msg_id,old_msg_ids               */
#define MSG_HEAD_ORG     "Organization: %s\n"    /* org_name                         */
#define MSG_HEAD_LINES   "Lines: %ld\n"          /* number_of_lines                  */
#define MSG_HEAD_MAIL    "X-Mailer: %s\n"        /* Mailer Name (FireNews Vx.xx)     */
#define MSG_HEAD_READ    "X-Newsreader: FireNews V%s (Atari) %s\n"    /* News-Reader Name (Firenews...)   */
#define MSG_HEAD_XURL    "X-Url: %s\n"           /* The users Homepage-adress                             */
#define MSG_SUBJECT_RE   "Re: "
#define MSG_SIGNATURE_SEP "-- "                  /* USed to seperate Signature part from body             */
#define MSG_END          "."

#define HEAD_LINE        "%s %ld %s %s %s\n"     /* msgid,offset,flags,reply1,reply..                     */

#define MSG_FLAG_OUT       "O"                   /* Outgoing Mail                                         */
#define MSG_FLAG_REQ       "Q"                   /* Requested Mail                                        */
#define MSG_FLAG_REP       "R"                   /* Replied Mail                                          */
#define MSG_FLAG_HEAD      "H"                   /* Only the Header of the Mail                           */
#define MSG_FLAG_DEL       "D"                   /* Mail is Soft-Deleted                                  */
#define MSG_FLAG_KEEP      "K"                   /* Mail is to be Kept from maint-Delete                  */
#define MSG_FLAG_NEW       "N"                   /* Mail is New/Unread                                    */
#define MSG_FLAG_TOUCHED   "F"                   /* Has mail been "seen"                                  */
#define MSG_FLAG_EMPTY     "-"                   /* No flag at all                                        */
#define NUM_FLAG           7                     /* Total of 7 Flags                                      */

#define INFITRA_START      "<<MAIL>>\n"
#define INFITRA_FROM       "FROM    : %s <%s>\n"    /* real-name, e-mail                     */
#define INFITRA_TO         "TO      : %s <%s>\n"    /* real-name, e-mail                     */
#define INFITRA_SUBJECT    "SUBJECT : %s\n"         /* subject                               */
#define INFITRA_DATE       "DATE    : %s\n"         /* Date of message                       */
#define INFITRA_STATE_QUEU "STATE   : QUEU\n"
#define INFITRA_ATTACH     "ATTACH  : FALSE\n"
#define INFITRA_ENCODE     "ENCODE  : MOLD\n"
#define INFITRA_CHARSET    "CHARSET : US-ASCII\n"
#define INFITRA_BODY       "BODY    : %s\n"         /* filename of body                      */

#define ACTIVE_TIMEI       "time %d\n"              /* time-offset                           */
#define ACTIVE_TIMEO       "time %c%d\n"            /* sign, time-offset                     */
#define ACTIVE_NEW         "new-server %s\n"        /* servername                            */
#define ACTIVE_SERVER      "server %s %s\n"         /* servername, filename                  */
#define ACTIVE_DATE        "date %s %s %s\n"        /* date, time,zone                       */
#define ACTIVE_GROUP       "group %s %s %ld\n"      /* newsgroup, filename groupmessage      */
#define ACTIVE_DESC        "desc %s\n"              /* description                           */
#define ACTIVE_MAILTO      "mailto %s\n"            /* send mail to this adress when posting */
#define ACTIVE_DAYS        "days %ld\n"             /* days                                  */
#define ACTIVE_MDAYS       "max-days %ld\n"         /* max_days                              */
#define ACTIVE_CURRENT     "current %ld\n"          /* the current msg-number                */
#define ACTIVE_HONLY       "headers-only\n"
#define ACTIVE_RONLY       "read-only\n"
#define ACTIVE_RESCAN      "rescan\n"
#define ACTIVE_GET_GROUP   "get-new-groups\n"
#define ACTIVE_GET_DESC    "get-descriptions\n"

#define FLAGS_SET          1
#define FLAGS_DEL          2
#define FLAGS_SETDEL_LIST  3
#define FLAGS_SETDEL_READ  4

#define GROUP_SUB          0
#define GROUP_NEW          1
#define GROUP_NEWASK       2
#define GROUP_ALL          3

#define SERVER_SELECT      0
#define SERVER_ADD         1

#define HOMEPAGE           "http://firestorm.atari.org"
#define HOMEFILE           "file://localhost/%s/index.htm",system_dir
#define CAB_NAME           "CAB     "
#define CABM_CCHANGED      (unsigned short)0xCAB0  /* Recieve ...      */
#define CABM_EXIT          (unsigned short)0xCAB1  /* Recieve ...      */
#define CABM_PATH          (unsigned short)0xCAB2  /* Recieve ...      */
#define CABM_VIEW          (unsigned short)0xCAB3  /* Send ...         */
#define CABM_TERM          (unsigned short)0xCAB4  /* Send/Recieve ...?*/
#define CABM_REQUESTSTATUS (unsigned short)0xCAB5  /* Send ...         */
#define CABM_STATUS        (unsigned short)0xCAB6  /* Recieve ...      */
#define CABM_RELEASESTATUS (unsigned short)0xCAB7  /* Send ...         */
#define CABM_HELLO         (unsigned short)0xCAB8  /* Recieve          */
#define CABM_MAIL          (unsigned short)0xCAB9  /* Send ...         */
#define CABM_MAILSENT      (unsigned short)0xCABA  /* Recieve ...      */
#define CABM_SUPPORT       (unsigned short)0xCABB  /* Send ...         */
#define CAB_VIEW           (1<<0)
#define CAB_MAIL           (1<<1)
#define CAB_MAILSEND       (1<<1)
#define CAB_REQUESTSTATUS  (1<<2)
#define CAB_RELEASESTATUS  (1<<2)
#define CAB_STATUS         (1<<2)
#define CAB_EXIT           (1<<2)
#define CAB_ONLINE         (1<<16)

typedef struct
{
  char groupname[ROWSIZE+1],
       description[ROWSIZE+1];
}UNGROUPS;

typedef struct
{
  char groupname[ROWSIZE+1],
       filename[ROWSIZE+1],
       description[ROWSIZE+1],
       mailto[ROWSIZE+1];
  char date[SIZE_DATE+1],
       time[SIZE_DATE+1],
       zone[SIZE_DATE+1];
  int  days,
       max_day,
       msg_num,
       group_message;
  int  f_header :1,
       f_ronly  :1,
       f_rescan :1;
  int  serv_num;
}GROUPS;

typedef struct
{
  char         name[ROWSIZE+1],
               file[ROWSIZE+1],
               date[SIZE_DATE+1],
               time[SIZE_DATE+1],
               zone[SIZE_DATE+1],
               d_desc[ROWSIZE+1],
               d_mailto[ROWSIZE+1];
  int          d_days,
               d_max_days;
  int          d_f_header      :1,
               d_f_ronly       :1,
               d_f_rescan      :1,
               del_newgroup    :1,
               get_new_group   :1,
               get_description :1;
               
  int          group_num,num_of_groups;
}SERVERS;

typedef struct _newsheader
{            
  long       offset;   /* The Offset in the messagefile */
  long       length;   /* The size of the message Including the endterminator "." */
  
  struct i
  {
    long  parent,
          child,
          next,
          prev;
  } i;
  struct flags
  {
    int deleted     :1,
        header_only :1,
        keep        :1,
        outgoing    :1,
        requested   :1,
        undef_05    :1,
        undef_06    :1,
        undef_07    :1,
        undef_08    :1,
        undef_09    :1,
        prog_spec_0 :1,
        prog_spec_1 :1,
        prog_spec_2 :1,
        prog_spec_3 :1,
        prog_spec_4 :1,
        prog_spec_5 :1,
        prog_spec_6 :1,
        prog_spec_7 :1,
        prog_spec_8 :1,
        prog_spec_9 :1,
        undef_20    :1,
        undef_21    :1,
        undef_22    :1,
        undef_23    :1,
        undef_24    :1,
        undef_25    :1,
        undef_26    :1,
        undef_27    :1,
        undef_28    :1,
        touched     :1,
        new         :1,   
        replied     :1;
  }flags;
  char       from[NEWS_FROMSIZE];
  char       subject[NEWS_SUBJECTSIZE];
  struct datetime
  {
    int  year  : 7,
         month : 4,
         day   : 5,
         hour  : 5,
         min   : 6,
         sec   : 5;
  }datetime;
} NewsHeader;

typedef struct
{
  long msg_num;
  int  depth;
}CommentList;

typedef struct
{
  int          time;
  SERVERS      *servers;
  NewsHeader   *tempmessage;
  GROUPS       *tempgroup;
  SERVERS      *tempserver;
  char         *msg_text,*body_text;
  UNGROUPS     *ungroups;
  long         num_of_messages,msg_num,
               num_of_unsub_groups,unsub_num,
               num_of_servers,serv_num,
               num_of_groups,group_num;
  MLIST        *mlist,*glist,*clist;
}ACTIVE;

typedef struct
{
  char *fontlist;
  int  *sizelist;
  int  subid,
       unsubid,
       msglid,
       readid,
       servid;
}FONT;

typedef struct
{
  char               tempstring[MAXSTRING+ROWSIZE+1],
                     temprow1[ROWSIZE+1],
                     temprow2[ROWSIZE+1],
                     temprow3[ROWSIZE+1];
  int                tempcounter,temp1,temp2,dummy,tempmsg,line,tempsrv;
  short              tempxy[8];
  int                arg_menu    :1,
                     registered  :1,
                     conf_change :1;
  int                area_type;
  int                server_num, group_num, msg_num;
  char               lastpath[MAXSTRING+1],
                     lastfile[MAXSTRING+1],
                     mailpath[MAXSTRING+1],
                     homepage[MAXSTRING+1];
  RESULT             svar;
  long               cab;
}VARIABLES;

#define CONFIG_NAME      "Name          : {%s}\n"
#define CONFIG_ADRESS1   "Adress1       : {%s}\n"
#define CONFIG_ADRESS2   "Adress2       : {%s}\n"
#define CONFIG_ADRESS3   "Adress3       : {%s}\n"
#define CONFIG_KEY       "Key           : {%s}\n"
#define CONFIG_EDITOR    "Editor        : {%s}\n"
#define CONFIG_NNTPD     "NNTPD         : {%s}\n"
#define CONFIG_SIG       "Signature     : {%s}\n"
#define CONFIG_MAILTYPE  "Mailtype      : {%s}\n"
#define CONFIG_MAILFILE  "MailFile      : {%s}\n"
#define CONFIG_STRINGSRV "Stringserver  : {%s}\n"
#define CONFIG_NEWS      "NewsDir       : {%s}\n"
#define CONFIG_EMAIL     "E-mail        : {%s}\n"
#define CONFIG_REPLY     "Reply-to      : {%s}\n"
#define CONFIG_REALNAME  "Real-Name     : {%s}\n"
#define CONFIG_ORG       "Organization  : {%s}\n"
#define CONFIG_USUBFONT  "Font-1        : %d {%s}\n"
#define CONFIG_SUBFONT   "Font-2        : %d {%s}\n"
#define CONFIG_MSGLFONT  "Font-3        : %d {%s}\n"
#define CONFIG_READFONT  "Font-4        : %d {%s}\n"
#define CONFIG_SERVFONT  "Font-5        : %d {%s}\n"
#define CONFIG_USUBWIND  "Wind-1        : %d %d %d %d\n"
#define CONFIG_SUBWIND   "Wind-2        : %d %d %d %d\n"
#define CONFIG_MSGLWIND  "Wind-3        : %d %d %d %d\n"
#define CONFIG_READWIND  "Wind-4        : %d %d %d %d\n"
#define CONFIG_SERVWIND  "Wind-5        : %d %d %d %d\n"
#define CONFIG_SAVEXIT   "Save-Exit     : %d\n"
#define CONFIG_SAVEWIND  "Save-window   : %d\n"
#define CONFIG_USECOMM   "Use-Comment   : %d\n"
#define CONFIG_SHOWCOMM  "Show-Comment  : %d\n"
#define CONFIG_RESCAN    "Rescan-Subs.  : %d\n"
#define CONFIG_HIDEUUE   "Hide-UUE      : %d\n"
#define CONFIG_HIDEUEND  "Hide-UUE-End  : %d\n"
#define CONFIG_HIDEHEAD  "Hide-Header   : %d\n"
#define CONFIG_QUOTEHEAD "Quote-Header  : %d\n"
#define CONFIG_OPENGROUP "Open-Group    : %d\n"
#define CONFIG_OPENMSG   "Open-MEssages : %d\n"
#define CONFIG_FKEYVA    "Fkeys-VAmsg   : %d\n"
#define CONFIG_HOMEPAGE  "HomePage      : {%s}\n"
#define CONFIG_REPLYSTR1 "ReplyString-1 : {%s}\n"
#define CONFIG_REPLYSTR2 "ReplyString-2 : {%s}\n"
#define CONFIG_UNKNOWN   "AES-Messages  : %d\n"
typedef struct
{
  char               name[SIZE_NAME+1],
                     adr1[SIZE_NAME+1],
                     adr2[SIZE_NAME+1],
                     adr3[SIZE_NAME+1],
                     key[SIZE_NAME+1],
                     stringserver[SIZE_ID+1];
  char               editor[MAXSTRING+1],
                     nntpd[MAXSTRING+1],
                     signature[MAXSTRING+1],
                     maildata[MAXSTRING+1],
                     newsdir[MAXSTRING+1];
  char               email[ROWSIZE+1],
                     real_name[ROWSIZE+1],
                     organization[ROWSIZE+1],
                     replyto[ROWSIZE+1],
                     homepage[ROWSIZE+1],
                     replystring1[ROWSIZE+1],
                     replystring2[ROWSIZE+1];
  char               unsubfontname[SIZE_FONT+1],
                     subfontname[SIZE_FONT+1],
                     msglfontname[SIZE_FONT+1],
                     readfontname[SIZE_FONT+1],
                     servfontname[SIZE_FONT+1];
  short              unsubfontsize,
                     subfontsize,
                     msglfontsize,
                     readfontsize,
                     servfontsize;
  int                save_exit   :1,
                     save_window :1,
                     use_comment :1,
                     show_comment:1,
                     rescan_sub  :1,
                     hide_uue    :1,
                     hide_uuend  :1,
                     hide_header :1,
                     quote_header:1,
                     mail_sig    :1,
                     open_group  :1,
                     open_msg    :1,
                     fkey_va     :1,
                     unknown_aes :1;
  short              subsw_xy[XYWH],
                     readw_xy[XYWH],
                     usubw_xy[XYWH],
                     msglw_xy[XYWH],
                     servw_xy[XYWH];
  short              message_alloc,
                     group_alloc;
  short              mailtype;
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
#define LOG_FUNCTION    "P"
#define LOG_FUNCTION2   "V"
#define LOG_TEMPORARY   "T"
typedef struct
{
	int  on  :1,
	     all :1;
	char what[LOG_MAXTYPES+1];
	char mess[LOG_STRINGSIZE+1];
}LOGG;

#define Return  Log(LOG_FUNCTION,"End function\n"); Log(LOG_MEMORY,"Checking Memory\n"); freememory=(long)Malloc(-1); Log(LOG_MEMORY,"Free Mem (Largest block)=%l\n",freememory); return
#else
#define Return return
#endif

/********************************************************************/
/* Deklarationer av funktioner                                      */
/********************************************************************/
#ifdef LOGGING
void    Log(const char *logtype,char *logstring,...);
#endif
int     save_message(int msg_num);
int     load_message(void);
void    close_readwin();
void    close_unsublistwin();
void    close_sublistwin();
void    close_msglistwin();
#include "variable.h"
