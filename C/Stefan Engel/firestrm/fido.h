#define F_SIZE_FROM  36
#define F_SIZE_TO    36
#define F_SIZE_SUBJ  72
#define F_SIZE_TIME  20
typedef struct
{
  char       from[F_SIZE_FROM];
  char       to[F_SIZE_TO];
  char       subj[F_SIZE_SUBJ];
  char       time[F_SIZE_TIME];
  long int   stamp;
  long int   offset;
  short int  reserved;
  short int  reply_number;
  short int  flags;
  long int   msgidcrc;
  long int   replycrc;
  short int  mausflags;
  short int  xflags;
  short int  temp_proc;
  short int  processed;
  short int  msgsize;
  short int  readcount;
  short int  cost;
  short int  fromzone;
  short int  fromnet;
  short int  fromnode;
  short int  frompoint;
  short int  tozone;
  short int  tonet;
  short int  tonode;
  short int  topoint;
} HDRINFO;

#define F_PRIVATE               (1U <<  0)
#define F_CRASH                 (1U <<  1)
#define F_RECEIVED              (1U <<  2)
#define F_SENT                  (1U <<  3)
#define F_FILEATTACH            (1U <<  4)
#define F_INTRANSIT             (1U <<  5)
#define F_ORPHAN                (1U <<  6)
#define F_KILLSENT              (1U <<  7)
#define F_LOCAL                 (1U <<  8)
#define F_HOLD                  (1U <<  9)
#define F_RESERVED              (1U << 10)
#define F_FILEREQ               (1U << 11)
#define F_RETRECREQ             (1U << 12)
#define F_ISRETREC              (1U << 13)
#define F_AUDITREQ              (1U << 14)
#define F_DELETED               (1U << 15)

#define XF_READ                 (1U <<  0)
#define XF_ARCHIVSENT           (1U <<  1)
#define XF_TRUNCFILESENT        (1U <<  2)
#define XF_KILLFILESENT         (1U <<  3)
#define XF_DIRECT               (1U <<  4)
#define XF_ZONEGATE             (1U <<  5)
#define XF_HOSTROUTE            (1U <<  6)
#define XF_LOCK                 (1U <<  7)
#define XF_MAUSMSG              (1U <<  8)
#define XF_GATED                (1U <<  9)
#define XF_CREATEFLOWFILE       (1U << 10)
#define XF_RESERVED11           (1U << 11)
#define XF_RESERVED12           (1U << 12)
#define XF_SIGNATURE            (1U << 13)
#define XF_IMMEDIATE            (1U << 14)
#define XF_FIXEDADDRESS         (1U << 15)

#define PROC_JETMAIL            (1U << 15)
#define PROC_AU_MSGCHECK        (1U << 14)
#define PROC_AU_FILEMGR         (1U << 13)
#define PROC_CHARMODIFY         (1U << 12)
#define PROC_CONNECTR           (1U << 11)
#define PROC_MSGCOPY            (1U << 10)
#define PROC_FIREMAIL           (1U <<  9)
#define PROC_DOORMAIL           (1U <<  2)
#define PROC_ARCED              (1U <<  1)
#define PROC_FIFO               (1U <<  0)

#define MF_NICHTGELESEN         (1U <<  0)
#define MF_NOTREAD              (1U <<  0)
#define MF_ZURUECK              (1U <<  1)
#define MF_RETURN               (1U <<  1)
#define MF_BEANTWORTET          (1U <<  2)
#define MF_ANSWERED             (1U <<  2)
#define MF_GELESEN              (1U <<  3)
#define MF_READ                 (1U <<  3)
#define MF_WEITER               (1U <<  4)
#define MF_CONTINUE             (1U <<  4)
#define MF_MAUSNET              (1U <<  5)
#define MF_ANGEKOMMEN           (1U <<  6)
#define MF_RECEIVED             (1U <<  6)
#define MF_GATEWAY              (1U <<  7)
#define MF_KOPIERT              (1U <<  8)
#define MF_COPIED               (1U <<  8)
#define MF_MAUSTAUSCH           (1U <<  9)
#define MF_UNBEKANNT            (1U << 10)
#define MF_UNKNOWN              (1U << 10)
#define MF_INTERESTING1         (1U << 11)
#define MF_INTERESTING2         (1U << 12)
#define MF_VERERBEN             (1U << 13)
#define MF_HEREDITARY           (1U << 13)


#define MAXMSGSIZE  16000
#define MAXMSGSIZE2 32000
#define HEADEREXT   ".HDR"
#define MESSAGEEXT  ".MSG"
#define OLDEXT      ".OLD"
#define BACKUPEXT   ".BAK"

#define K_PID       "PID: "
#define K_REPLYTO   "REPLYTO "
#define K_REPLYADDR "REPLYADDR "
#define K_REPLY     "REPLY: "
#define K_MSGID     "MSGID: "
#define K_EID       "EID: "
#define LN_NETMAIL  "FidoNetmail"
#define FALSE       0
#define TRUE        1
#define NOLL        0

#define LF_NEW      1
#define LF_UNREAD   2
#define LF_SYSOP    4

typedef struct
{
  int              on;
  int              cont_type,
                   cont_trans,
                   cont_char_set;
}MIME;

#define MIME_CHAR_PC7     0
#define MIME_CHAR_UNKNOWN 255
#define MIME_CONT_PLAIN   0
#define MIME_CONT_UNKNOWN 255
