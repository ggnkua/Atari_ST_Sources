#define MAX_PATH 300      /* Laenge eines Pfades                             */
#define MAX_FILENAME 32   /* Laenge eines Filenamens                             */
#define MAX_DEEP  300      /* Maximale Suchtiefe fÅr Directorys              */
#define MAX_REQUESTER 30  /* Maximalzahl Requester pro Server               */
#define MAX_RESOURCE 30   /* Maximalzahl der Resourcen fuer jeden Requester */
#define MAX_FHAND 100     /* Anzahl verfÅgbarer Filehandles                 */
#define MAX_DIRHAND 100   /* Anzahl verfÅgbarer Dirhandles                   */
#define MAX_RESNAME 16    /* Laenge eines Resourcennames                    */
#define MAX_REQNAME 20    /* Laenge eines Requesternnames                   */
#define MAX_ACCESS 300    /* Rechteliste pro Resource                       */
#define MAX_USR  100      /* Anzahl User pro Server                         */
#define MAX_USRNAME 20    /* Laenge eines Usernames                         */
#define MAX_PASSWD  20    /* Laenge eines Passwortes                        */
#define MAX_AUTOM 20      /* Anzahl Auto Programme nach GEMDOS.PRG          */
#define MAX_BLOCK 10      /* Maximalszahl blocke pro Transfer      */

#define	PORT_ULINET_SERVER       20004 /* Port des Ulinetzes "An Server"       */
#define	PORT_ULINET_REQUESTER    20003 /* Port des Ulinetzes "An Requester"    */

#define RES_FLAGS_NONE    0
#define RES_FLAGS_HIDDEN  1
#define RES_FLAGS_AKTIV   2  /* wenn ein Drucker, oder ein Zeitnormal aktiv ist */
#define RES_FLAGS_DOS     4  /* Diese Resource verwendet DOS Dateinamenkonventionen */

#define CALL_FSFIRST 1
#define RET_FSFIRST  2
#define CALL_FSNEXT  3
#define RET_FSNEXT   4
#define CALL_FOPEN   5
#define RET_FOPEN    6
#define CALL_FREAD   7
#define RET_FREAD    8
#define CALL_FCLOSE  9
#define RET_FCLOSE   10
#define CALL_FCREATE 11
#define RET_FCREATE  12
#define CALL_FDELETE 13
#define RET_FDELETE  14
#define CALL_FWRITE  15
#define RET_FWRITE   16
#define CALL_FATTRIB 17
#define RET_FATTRIB  18
#define CALL_FRENAME 19
#define RET_FRENAME  20
#define CALL_FDCREATE 21
#define RET_FDCREATE  22
#define CALL_FDDELETE 23
#define RET_FDDELETE  24
#define CALL_FSEEK    25
#define RET_FSEEK     26
#define CALL_FCNTL    27
#define RET_FCNTL     28
#define CALL_FGETTIME 29
#define RET_FGETTIME  30
#define CALL_PATHCONF 31
#define RET_PATHCONF  32
#define CALL_OPENDIR  33
#define RET_OPENDIR   34
#define CALL_CLOSEDIR 35
#define RET_CLOSEDIR  36
#define CALL_READDIR  37
#define RET_READDIR   38
#define CALL_REWINDDIR 39
#define RET_REWINDDIR  40
#define CALL_FILEINFO 41
#define RET_FILEINFO  42
#define CALL_SENDFAX  43
#define RET_SENDFAX   44

#define CALL_QUERY    100
#define RET_QUERY     101

#define CALL_MESSAGE  102
#define RET_MESSAGE   103
#define CALL_WHO      104
#define RET_WHO       105

#define CALL_LOGOFF   106
#define RET_LOGOFF    107

#define CALL_DUMP     200
#define RET_DUMP      201

#define CALL_RESTART  204
#define RET_RESTART   205

/*-------- fsfirst -----------------------------------*/
typedef struct
  {
  char name[MAX_FILENAME];
  unsigned short  time;
  unsigned short  date;
  unsigned long   length;
  unsigned char   attrib;
  } direntry_typ;

typedef struct 
  {
  short handle;       /* Dieses Handle beschreib den Puffer, der zu verwenden ist Wert 0..MAX_DEEP */
  char  name[MAX_PATH];    /* zu suchender Filename        */
  short attr;         /* Attribut                     */
  } call_fsfirst_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  direntry_typ  direntry;   /* Name Puffer             */
  } ret_fsfirst_typ;

/*-------- fsnext ------------------------------------*/
typedef struct 
  {
  short handle;
  } call_fsnext_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  direntry_typ  direntry;   /* Name Puffer             */
  } ret_fsnext_typ;

/*-------- fopen -------------------------------------*/
typedef struct 
  {
  char  name[MAX_PATH];    /* zu oeffnende Datei           */
  short mode;         /* Open Modes                   */
  } call_fopen_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_fopen_typ;

/*-------- fread -------------------------------------*/
typedef struct 
  {
  short handle;       /* zu oeffnende Datei           */
  short flag;         /* =1 wenn mehrfachtransfer erlaubt  */
  long  count;        /* anzahl zu lesender Bytes     */
  } call_fread_typ;

typedef struct 
  {
  short seq;          /* Nummer des Paktetes bei Mehrfachtransfers */
  short anz;          /* anzahl der Pakete, die kommen bei Mehrfachtransfers */
  long  len;          /* Laenge der Daten inm Puffer   */
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  unsigned char  buffer[1300]; /* Puffer zum uebertragen        */
  } ret_fread_typ;

/*-------- fwrite -------------------------------------*/
typedef struct 
  {
  short handle;       /* zu oeffnende Datei           */
  short dummy;         /* auf 4 Byte Grenze zwingen   */
  long  count;        /* anzahl zu lesender Bytes     */
  unsigned char  buffer[1300]; /* Puffer zum uebertragen        */
  } call_fwrite_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_fwrite_typ;

/*-------- fclose -------------------------------------*/
typedef struct 
  {
  short	handle;
  } call_fclose_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_fclose_typ;

/*-------- fcreate -------------------------------------*/
typedef struct 
  {
  char  name[MAX_PATH];    /* zu oeffnende Datei           */
  short mode;         /* Open Modes                   */
  } call_fcreate_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_fcreate_typ;

/*-------- fdelete -------------------------------------*/
typedef struct 
  {
  char  name[MAX_PATH];    /* zu oeffnende Datei           */
  } call_fdelete_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_fdelete_typ;

/*-------- fattrib -------------------------------------*/
typedef struct 
  {
  char  name[MAX_PATH];    /* Datei zum Attributaendern          */
  short wflag;        /* Writeflag                       */
  short attrib;       /* neue Attribute                  */
  } call_fattrib_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_fattrib_typ;

/*-------- frename -------------------------------------*/
typedef struct 
  {
  char  oldname[MAX_PATH];    /* Datei zum Umbenennen          */
  char  newname[MAX_PATH];    /* Neuer Name                    */
  } call_frename_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_frename_typ;


/*-------- fdcreate -------------------------------------*/
typedef struct 
  {
  char  name[MAX_PATH];    /* zu oeffnende Datei           */
  } call_fdcreate_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_fdcreate_typ;

/*-------- fddelete -------------------------------------*/
typedef struct 
  {
  char  name[MAX_PATH];    /* zu oeffnende Datei           */
  } call_fddelete_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_fddelete_typ;

/*-------- fseek -------------------------------------*/
typedef struct 
  {
  long offset;
  short handle;
  short seekmode;
  } call_fseek_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_fseek_typ;

/*-------- fcntl -------------------------------------*/
typedef struct 
  {
  short handle;
  short code;
  short direct;       /* special selbst ist der Parameter */
  short direct_val;   /* Wert fuer special */
  char	data[100];
  } call_fcntl_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  char	data[100];
  } ret_fcntl_typ;

/*-------- fgettime ------------------------------------*/
typedef struct
  {
  short jahr;
  short monat;
  short tag;
  short stunde;
  short minute;
  short sekunde;
  } timestruct_typ;

typedef struct 
  {
  short dummy;            /* keine weiteren Parameter   */
  } call_fgettime_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  timestruct_typ timestruct;
  } ret_fgettime_typ;

/*-------- sendfax ------------------------------------*/
typedef struct 
  {
  char nummer[100];  /* Telefonnummer des Faxes        */
  } call_sendfax_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_sendfax_typ;

/*-------- pathconf-------------------------------------*/
typedef struct 
  {
  char	path[MAX_PATH];
  short code;
  } call_pathconf_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_pathconf_typ;

/*-------- opendir-------------------------------------*/
typedef struct 
  {
  char	path[MAX_PATH];
  short flag;
  } call_opendir_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_opendir_typ;

/*-------- closedir-------------------------------------*/
typedef struct 
  {
  long dhand;
  } call_closedir_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_closedir_typ;

/*-------- readdir-------------------------------------*/
typedef struct 
  {
  long dhand;
  } call_readdir_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  char  name[MAX_FILENAME];
  } ret_readdir_typ;

/*-------- rewinddir-------------------------------------*/
typedef struct 
  {
  long dhand;
  } call_rewinddir_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  } ret_rewinddir_typ;

/*-------- fileinfo-------------------------------------*/

/* structure for getxattr */
typedef struct xattr {
	unsigned short mode;
/* file types */
#define NET_IFMT	0170000		/* mask to select file type */
#define NET_IFCHR	0020000		/* BIOS special file */
#define NET_IFDIR	0040000		/* directory file */
#define NET_IFREG 0100000		/* regular file */
#define NET_IFIFO 0120000		/* FIFO */
#define NET_IMEM	0140000		/* memory region or process */
#define NET_IFLNK	0160000		/* symbolic link */

/* special bits: setuid, setgid, sticky bit */
#define NET_ISUID	04000
#define NET_ISGID 02000
#define NET_ISVTX	01000

/* file access modes for user, group, and other*/
#define NET_IRUSR	0400
#define NET_IWUSR 0200
#define NET_IXUSR 0100
#define NET_IRGRP 0040
#define NET_IWGRP	0020
#define NET_IXGRP	0010
#define NET_IROTH	0004
#define NET_IWOTH	0002
#define NET_IXOTH	0001
#define NET_DEFAULT_DIRMODE (0777)
#define NET_DEFAULT_MODE	(0666)

	unsigned short  nlink;
	unsigned long	uid;
	unsigned long	gid;

	long	size;
	long	blksize, nblocks;
	long	mtime, mdate;
	long	atime, adate;
	long	ctime, cdate;
	long	attr;
} fileinfo_typ;


typedef struct 
  {
  long flag;
  char name[MAX_PATH];
  } call_fileinfo_typ;

typedef struct 
  {
  long  erg;          /* ergebnis des Funktionsaufrufes*/
  fileinfo_typ buffer;/* Puffer der obigen Struktur    */
  } ret_fileinfo_typ;

/*-------- query Resource -------------------------------------*/
typedef struct 
  {
  char	usr_name[MAX_USRNAME]; /* username      */
  char	passwd[MAX_PASSWD];   /* Passwort      */
  } call_query_typ;

typedef struct
  {
  short     typ;      /* Arte der Resource */
  short     flags;    /* Flags der Resource */
  char      name[MAX_RESNAME]; /* Name der Resource */
  } query_resource_typ;

typedef struct 
  {
  unsigned short  usr_id;                      /* ID dieses Users auf diesem Server */
  char            serv_name[30];               /* Name des Servers              */
  unsigned short  anz;                         /* Anzahl resourcen in der Liste */
  query_resource_typ res[40];  /* Array mit den Resourcennamen  */ 
  } ret_query_typ;

/*-------- logoff  --------------------------------------------*/
typedef struct 
  {
  char	usr_name[MAX_USRNAME]; /* username      */
  char	passwd[MAX_PASSWD];   /* Passwort      */
  } call_logoff_typ;

typedef struct 
  {
  long erg;
  } ret_logoff_typ;

/*-------- Net Dump ---------------------------------------*/
typedef struct 
  {
  char	buffer[100];    /* Ausgabestring */
  } call_dump_typ;

typedef struct 
  {
  long erg;
  } ret_dump_typ;

#define MAX_MESSAGE 1300

/*-------- Net Message ------------------------------------*/
/* --- Typ zum senden einer Mitteilung (net Message)----*/
typedef struct
  {
  short  valid;     /* ist der Inhalt gueltig ?             */
  short  typ;       /* Typ der Message (nach MSG_... )   */
  unsigned long in_addr;  /* Zieladresse der Meldung   */
  char   data[MAX_MESSAGE];/* Inhalt der Meldung                   */
  } message_typ;

typedef struct 
  {
  message_typ	msg_buf;    /* Ausgabestring */
  } call_message_typ;

typedef struct 
  {
  long erg;
  } ret_message_typ;

/* --- Typ zum Abfragen der Requesterliste (net Who)----*/
typedef struct
  {
  short req_id;
  char  req_name[MAX_REQNAME];
  unsigned long in_addr;
  } req_list_typ;

typedef struct 
  {
  short dummy;
  } call_who_typ;

typedef struct 
  {
  req_list_typ info;	/* liefere eigene Identifikation */
  } ret_who_typ;

/*-------- Restart Requester --------------------------------*/
typedef struct 
  {
  short dummy;
  } call_restart_typ;

typedef struct 
  {
  long erg;
  } ret_restart_typ;

typedef union
  {
  call_fsfirst_typ call_fsfirst;
  ret_fsfirst_typ ret_fsfirst;
  call_fsnext_typ call_fsnext;
  ret_fsnext_typ ret_fsnext;
  call_fopen_typ call_fopen;
  ret_fopen_typ ret_fopen;
  call_fread_typ call_fread;
  ret_fread_typ ret_fread;
  call_fwrite_typ call_fwrite;
  ret_fwrite_typ ret_fwrite;
  call_fclose_typ call_fclose;
  ret_fclose_typ ret_fclose;
  call_fcreate_typ call_fcreate;
  ret_fcreate_typ ret_fcreate;
  call_fdelete_typ call_fdelete;
  ret_fdelete_typ ret_fdelete;
  call_fattrib_typ call_fattrib;
  ret_fattrib_typ ret_fattrib;
  call_frename_typ call_frename;
  ret_frename_typ ret_frename;
  call_fdcreate_typ call_fdcreate;
  ret_fdcreate_typ ret_fdcreate;
  call_fddelete_typ call_fddelete;
  ret_fddelete_typ ret_fddelete;
  call_fseek_typ call_fseek;
  ret_fseek_typ ret_fseek;
  call_fcntl_typ call_fcntl;
  ret_fcntl_typ ret_fcntl;
  call_fgettime_typ call_fgettime;
  ret_fgettime_typ ret_fgettime;
  call_sendfax_typ call_sendfax;
  ret_sendfax_typ ret_sendfax;

  call_pathconf_typ call_pathconf;
  ret_pathconf_typ ret_pathconf;
  call_opendir_typ call_opendir;
  ret_opendir_typ ret_opendir;
  call_closedir_typ call_closedir;
  ret_closedir_typ ret_closedir;
  call_readdir_typ call_readdir;
  ret_readdir_typ ret_readdir;
  call_rewinddir_typ call_rewinddir;
  ret_rewinddir_typ ret_rewinddir;
  call_fileinfo_typ call_fileinfo;
  ret_fileinfo_typ ret_fileinfo;

  call_query_typ call_query;
  ret_query_typ ret_query;
  call_logoff_typ call_logoff;
  ret_logoff_typ ret_logoff;
  call_dump_typ call_dump;
  ret_dump_typ ret_dump;
  call_message_typ call_message;
  ret_message_typ ret_message;
  call_who_typ call_who;
  ret_who_typ ret_who;
  call_restart_typ call_restart;
  ret_restart_typ ret_restart;

  char dummy[2000];
  } lan_data_typ;

typedef struct
  {
  unsigned long  in_dst;  /* Internet EmpfÑnger          */
  unsigned long  in_src;  /* Ethernet Absender           */
  unsigned short in_port; /* Port zu senden              */
  unsigned short dummy;   /* long align                  */
  unsigned short len;     /* Laenge der Daten in lan_data*/
  unsigned short code;    /* Befehlscode                 */
  unsigned long  id;      /* ID dieses Paketes           */
  short          req_id;  /* ID des eigenen Requesters   */
  short          usr_id;  /* ID des eingeloggten Users   */
  lan_data_typ   lan_data;/* eigentlicher Datenpuffer    */
  } lan_buffer_typ;

#define LAN_DATAOFFSET ( sizeof(lan_buffer_typ) - sizeof(lan_data_typ))

/* GEMDOS Liste aller Filehandles im Requester */
typedef struct
  {
  short used;             /* True, wenn Daten gueltig     */
  short real_hand;        /* Handle des Gemdos            */
  short resource_id;      /* ID der zugehoerigen Resource */
#ifndef LINUX
  BASPAG  *bas_pag;       /* Pointer auf Basepage des Prozesses, der dieses Handle belegt */
#endif
  } fhand_typ;

/* GEMDOS Liste aller Directoryhandles im Requester */
typedef struct
  {
  short used;             /* True, wenn Daten gueltig     */
  long real_hand;         /* Handle des Gemdos/UNIX       */
  short resource_id;      /* ID der zugehoerigen Resource */
  long  bas_pag;          /* Pointer auf Basepage des Prozesses, der dieses Handle belegt */
  } dirhand_typ;


/* Typ von resourcen */

#define RESOURCE_DRIVE  1  
#define LOCAL_DRIVE  10  
#define RESOURCE_PRINTER  2  
#define RESOURCE_TIME  3  
#define LOCAL_PRINTER  4
#define RESOURCE_DEVICE  5
#define RESOURCE_DUMP  6
#define RESOURCE_FAX  7

typedef struct
  {
  short         typ;            /* Arte der Resource                            */
  short         id;             /* ID dieser Resource auf diesem Requester      */
  short         flags;          /* flags z.B. Hidden                            */
  short         usr_id;         /* User ID, die der Server geliefert hat        */
  char          serv_name[30];  /* Name des Servers, der diese Resource bereitstellt */
  char          name[MAX_RESNAME];  /* Name der Resource                        */
  unsigned long in_addr;        /* Internetadresse des verantwortlichen Servers */
  char          path[MAX_PATH]; /* nur fuer lokale Drives                       */
  } resource_typ;

typedef struct
  {
  short      valid;        /* TRUE, wenn DTA belegt ist                  */
  short      resource_ind; /* Index der zugehoerigen Resource            */
  short      query;        /* fortschritt der Abfrage bei Internen Listen*/
  short      level;        /* Directory Tiefe                            */
  unsigned   long used;    /* letzter gebrauch                           */
#ifndef LINUX
  DTA        dta;          /* fuer lokale Drives                         */
#endif
  } search_hand_typ;

/* Fuer Server: Buffer fuer jeden Requester */
typedef struct
  {
  short          req_id;            /* ID des zugehoerigen Requesters     */
  unsigned long  in_addr;           /* Internetadresse des Requesters     */

  short          dirres_ind[MAX_DEEP];           /* Index der Resource                 */
#ifndef LINUX
  DTA	         dta_buf[MAX_DEEP]; /* Speicher fuer die DTA's            */
#endif

#ifdef LINUX
  DIR            *dirhand[MAX_DEEP];/* Speicher fuer die DIR Handles      */
  char           dirpath[MAX_DEEP][MAX_PATH];
  char           dirmask[MAX_DEEP][MAX_PATH];
#endif
  lan_buffer_typ lan_erg[MAX_BLOCK];/* Erebnispuffer fuer jeden Requester */
  short          anz_block;         /* Anzahl Bloecke                     */
  long           last_id;           /* letzte empfangene ID               */
  } req_buffer_typ;


typedef struct
  {
  char path[MAX_PATH];
  char cmdline[130];
  } autom_typ;

typedef struct
  {
  long           drucker_zeit;      /* Zeit bis Drucker freigegeben wird  */
  unsigned short usr_id;            /* ID des Users                       */
  char           usr_name[MAX_USRNAME]; /* Name dieses Users              */
  char           passwd[MAX_USRNAME]; /* Passwot des angemeldeten Users              */
  short          csum;              /* TRUE, wenn csum gebildet werden soll */
  } para_typ;

#define MSG_ALERT	1


/* ---- Poll informationen vom Gemdos Treiber ----------*/
typedef struct
  {
  short local_printer_res_ind;        /* Resource ID des zu aktivierenden Druckers */
  short local_printer_start;         /* aktiviere Spooler */
  char  local_printer_filename[MAX_PATH];  
  long  defekt_count;                /* ZÑhlt defekte Pakete */
  short debug_flag;                  /* -> Meldung ist GÅltig */
  char  debug_msg[100];              /* Meldung zum ausgeben */
  short do_fax;                      /* Fax datei gesendet, bitte Telefonnummer mitteilen */
  } pollinfo_typ;

/*----- FILESERVER Handleverwaltung ---------------------*/

#define MAX_SFHAND 200        /* Maximal vom Server verwendbare Handle */

typedef struct
  {
  short used;                            /* ist belegt                    */
  short res_ind;                         /* index der Resource des Servers*/
  short req_id;                          /* ID des belegenden Requesters  */
  char  path[MAX_PATH];                  /* zum ansehen der offenen Files */
  } sfhand_typ;					/* Server Filehandles */


typedef struct
  {
  char *devname;
  unsigned long flags;
  } rsvf_liste_typ;

/*--- Zugriffsrechte in attrib --------------------------*/
#define		ACC_READ	0x00000001
#define		ACC_WRITE	0x00000002
#define		ACC_DELETE	0x00000004

/*--- Server Zugriffsliste ------------------------------*/
typedef struct
  {
  short usr_id;                         /* Id des Users */
  long  attrib;                         /* Zugriffsattribute */
  } access_typ;

typedef struct
  {
  access_typ *access;                   /* Zeiger auf das Array mit den Zugriffsrechten */
  short      access_anz;                /* anzahl eintr‰ge darin                        */
  } access_list_typ;

/*--- Server Userliste ----------------------------------*/
#define USR_STAT_LOGIN  1               /* User ist eingeloggt */
#define USR_STAT_LOGOFF 0               /* User ist ausgeloggt */

typedef struct
  {
  short id;
  short status;
  char  name[20];
  char  password[30];
  char  kommentar[40];
  } usr_typ;

typedef struct
  {
  char aliasname[30];
  char localname[30];
  } devices_typ;




