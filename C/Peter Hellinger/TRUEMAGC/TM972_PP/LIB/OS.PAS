UNIT OS;

INTERFACE

CONST FO_READ =     0;
      FO_WRITE =    1;
      FO_RW = 	    2;

CONST FA_RDONLY =      $1;
      FA_HIDDEN =      $2;
      FA_SYSTEM =      $4;
      FA_LABEL =       $8;
      FA_DIREC =      $10;
      FA_ARCH =       $20;
      FA_ATTRIB =     $17;

CONST VERTFLAG =    $0100;
      STMODES =     $0080;
      OVERSCAN =    $0040;
      PAL =         $0020;
      VGA_FALCON =  $0010;
      TV =          $0000;

CONST COL80 =         $08;
      COL40 =         $00;

CONST BPS16 =           4;
      BPS8 =            3;
      BPS4 =            2;
      BPS2 =            1;
      BPS1 =            0;

CONST NUMCOLS =         7;

(*-----------------------------------------------------------------*)
(*  BIOS                                                           *)
(*-----------------------------------------------------------------*)

TYPE  MDPtr =   ^MD;
      MD =      RECORD
                 m_link:     MDPtr;
                 m_start:    POINTER;
                 m_length:   LONGINT;
                 m_own:      PDPtr;
                END;

TYPE  MPBPtr =  ^MPB;
      MPB =     RECORD
                 mp_mfl:    MDPtr;
                 mp_mal:    MDPtr;
                 mp_rover:  MDPtr;
                END;

TYPE  BPBPtr =  ^BPB;
      BPB =     RECORD
                 recsiz:  INTEGER;
                 clsiz:   INTEGER;
                 clsizb:  INTEGER;
                 rdlen:   INTEGER;
                 fsiz:    INTEGER;
                 fatrec:  INTEGER;
                 datrec:  INTEGER;
                 numcl:   INTEGER;
                 bflags:  INTEGER;
                END;

(*-----------------------------------------------------------------*)
(* GEMDOS                                                          *)
(*-----------------------------------------------------------------*)

TYPE  DTAPtr =  ^DTA;
      DTA =     RECORD
                 d_reserved: ARRAY [1..21] OF BYTE;
                 d_attrib:   BYTE;
                 d_time:     INTEGER;
                 d_date:     INTEGER;
                 d_length:   LONGINT;
                 d_fname:    ARRAY [0..13] OF CHAR;
                END;

TYPE    DISKINFOPtr = ^DISKINFO;
        DISKINFO =    RECORD
                       b_free:   LONGINT;
                       b_total:  LONGINT;
                       b_secsiz: LONGINT;
                       b_clsiz:  LONGINT;
                      END;

TYPE    DOSTIMEPtr =  ^DOSTIME;
        DOSTIME =     RECORD
                       time: WORD;
                       date: WORD;
                      END;

TYPE    LINEPTR =     ^LINE;
        LINE =        RECORD
                       maxlen: BYTE;
                       buffer: STRING;
                      END;

TYPE    MSGTYPEPTR = ^MSGTYPE;
        MSGTYPE =    RECORD
                      msg1: LONGINT;
                      msg2: LONGINT;
                      pid:  INTEGER;
                     END;

TYPE    XATTRPTR =   ^XATTR;
        XATTR =      RECORD
                      mode:      WORD;
                      index:     LONGINT;
                      dev:       WORD;
                      reserved1: WORD;
                      nlink:     WORD;
                      uid:       WORD;
                      gid:       WORD;
                      size:      LONGINT;
                      blksize:   LONGINT;
                      nblocks:   LONGINT;
                      mtime:     INTEGER;
                      mdate:     INTEGER;
                      atime:     INTEGER;
                      adate:     INTEGER;
                      ctime:     INTEGER;
                      cdate:     INTEGER;
                      attr:      INTEGER;
                      reserved2: INTEGER;
                      reserved3: ARRAY [0..1] OF LONGINT;
                     END;

TYPE  SIGACTIONPtr = ^SIGACTION;
      SIGACTION =    RECORD
                      sa_handler: POINTER;
                      sa_mask:    LONGINT;
                      sa_flags:   INTEGER;
                     END;

(*-----------------------------------------------------------------*)
(* XBIOS                                                           *)
(*-----------------------------------------------------------------*)

TYPE  MOUSEPtr =    ^MOUSE;
      MOUSE =       RECORD
                     topmode: BYTE;
                     buttons: BYTE;
                     x_scale: BYTE;
                     y_scale: BYTE;
                     x_max:   INTEGER;
                     y_max:   INTEGER;
                     x_start: INTEGER;
                     y_start: INTEGER;
                    END;

TYPE  IORECORDPtr = ^IORECORD;
      IORECORD =    RECORD
                     ibuf:    POINTER;
                     ibufsiz: INTEGER;
                     ibufhd:  INTEGER;
                     ibuftl:  INTEGER;
                     ibuflow: INTEGER;
                     ibufhi:  INTEGER;
                    END;

TYPE  KEYTABPtr =   ^KEYTAB;
      KEYTAB =      RECORD
                     unshift:  POINTER;
                     shift:    POINTER;
                     capslock: POINTER;
                    END;

TYPE  KBDVECSPtr =  ^KBDVECS;
      KBDVECS =     RECORD
                     midivec:  POINTER;
                     vkbderr:  POINTER;
                     vmiderr:  POINTER;
                     statvec:  POINTER;
                     mousevec: POINTER;
                     clockvec: POINTER;
                     joyvec:   POINTER;
                     midisys:  POINTER;
                     ikdbsys:  POINTER;
                     drvstat:  INTEGER;
                    END;

TYPE  PBDEFPtr =    ^PBDEF;
      PBDEF =       RECORD
                     pb_scrptr: POINTER;
                     pb_OFfset: INTEGER;
                     pb_width:  INTEGER;
                     pb_height: INTEGER;
                     pb_left:   INTEGER;
                     pb_right:  INTEGER;
                     pb_screz:  INTEGER;
                     pb_prrez:  INTEGER;
                     pb_colptr: POINTER;
                     pb_prtype: INTEGER;
                     pb_prport: INTEGER;
                     pb_mask:   POINTER;
                    END;

TYPE  METAINFOPtr = ^METAINFO;
      METAINFO =    RECORD
                     drivemap: LONGINT;
                     version:  POINTER;
                     reserved: ARRAY [1..2] OF LONGINT;
                    END;

TYPE  LONGINTFunc =FUNCTION: LONGINT;

TYPE  DSPBLOCKPtr = ^DSPBLOCK;
      DSPBLOCK =    RECORD
                     blocktype: INTEGER;
                     blocksize: LONGINT;
                     blockaddr: POINTER;
                    END;

(*-----------------------------------------------------------------*)
(* MiNT                                                            *)
(*-----------------------------------------------------------------*)

CONST NSIG =      31;       (* number of signals recognized    *)
      SIGNULL =    0;       (* not really a signal             *)
      SIGHUP =     1;       (* hangup signal                   *)
      SIGINT =     2;       (* sent by ^C                      *)
      SIGQUIT =    3;       (* quit signal                     *)
      SIGILL =     4;       (* illegal inRECORDion             *)
      SIGTRAP =    5;       (* trace trap                      *)
      SIGABRT =    6;       (* abort signal                    *)
      SIGPRIV =    7;       (* privilege violation             *)
      SIGFPE =     8;       (* divide by zero                  *)
      SIGKILL =    9;       (* cannot be ignored               *)
      SIGBUS =    10;       (* bus error                       *)
      SIGSEGV =   11;       (* illegal memory reference        *)
      SIGSYS =    12;       (* bad argument to a system call   *)
      SIGPIPE =   13;       (* broken pipe                     *)
      SIGALRM =   14;       (* alarm clock                     *)
      SIGTERM =   15;       (* software termination signal     *)
      SIGURG =    16;       (* urgent condition on I/O channel *)
      SIGSTOP =   17;       (* stop signal not from terminal   *)
      SIGTSTP =   18;       (* stop signal from terminal       *)
      SIGCONT =   19;       (* continue stopped process        *)
      SIGCHLD =   20;       (* child stopped or exited         *)
      SIGTTIN =   21;       (* read by background process      *)
      SIGTTOU =   22;       (* write by background process     *)
      SIGIO =     23;       (* I/O possible on a descriptor    *)
      SIGXCPU =   24;       (* CPU time exhausted              *)
      SIGXFSZ =   25;       (* file size limited exceeded      *)
      SIGVTALRM = 26;       (* virtual timer alarm             *)
      SIGPROF =   27;       (* profiling timer expired         *)
      SIGWINCH =  28;       (* window size changed             *)
      SIGUSR1 =   29;       (* user signal 1                   *)
      SIGUSR2 =   30;       (* user signal 2                   *)
      SIG_DFL =    0;       (* default signal handler          *)
      SIG_IGN =    1;       (* ignore the signal               *)

(* flags for open() modes *)

CONST O_RDONLY          = $0000;
      O_WRONLY          = $0001;
      O_RDWR            = $0002;
      O_EXEC            = $0003;     (* execute file; used by kernel only *)
      O_APPEND          = $0008;     (* all writes go to end of file *)
      O_SHMODE          = $0070;     (* isolates file sharing mode *)
      O_COMPAT          = $0000;     (* compatibility mode *)
      O_DENYRW          = $0010;     (* deny both read and write access *)
      O_DENYW           = $0020;     (* deny write access to others *)
      O_DENYR           = $0030;     (* deny read access to others *)
      O_DENYNONE        = $0040;     (* don't deny any access to others *)
      O_NOINHERIT       = $0080;     (* children don't get this file descriptor *)
      O_NDELAY          = $0100;     (* don't block for i/o on this file *)
      O_CREAT           = $0200;     (* create file if it doesn't exist *)
      O_TRUNC           = $0400;     (* truncate file to 0 bytes if it does exist *)
      O_EXCL            = $0800;     (* fail open if file exists *)
      O_USER            = $0fff;     (* isolates user-settable flag bits *)
      O_GLOBAL          = $1000;     (* for Fopen: opens a global file handle *)
                                     (* kernel mode bits -- the user can't set these! *)
      O_TTY             = $2000;     (* FILEPTR refers to a terminal *)
      O_HEAD            = $4000;     (* FILEPTR is the master side of a fifo *)
      O_LOCK            = $8000;     (* FILEPTR has had locking Fcntl's performed *)

                                     (* lseek() origins *)
CONST SEEK_SET          = 0;         (* from beginning of file *)
      SEEK_CUR          = 1;         (* from current location *)
      SEEK_END          = 2;         (* from end of file *)

                                     (* The requests for Dpathconf() *)
CONST DP_IOPEN          = 0;         (* internal limit on #of open files *)
      DP_MAXLINKS       = 1;         (* max number of hard links to a file *)
      DP_PATHMAX        = 2;         (* max path name length *)
      DP_NAMEMAX        = 3;         (* max length of an individual file name *)
      DP_ATOMIC         = 4;         (* #of bytes that can be written atomically *)
      DP_TRUNC          = 5;         (* file name truncation behavior *)
      DP_NOTRUNC        = 0;         (* long filenames give an error *)
      DP_AUTOTRUNC      = 1;         (* long filenames truncated *)
      DP_DOSTRUNC       = 2;         (* DOS truncation rules in effect *)
      DP_CASE           = 6;         (* file name case conversion behavior *)
      DP_CASESENS       = 0;         (* case sensitive *)
      DP_CASECONV       = 1;         (* case always converted *)
      DP_CASEINSENS     = 2;         (* case insensitive, preserved *)
      DP_MODEATTR       = 7;
      DP_ATTRBITS       = $000000ff; (* mask for valid TOS attribs *)
      DP_MODEBITS       = $000fff00; (* mask for valid Unix file modes *)
      DP_FILETYPS       = $fff00000; (* mask for valid file types *)
      DP_FT_DIR         = $00100000; (* directories (always if . is there) *)
      DP_FT_CHR         = $00200000; (* character special files *)
      DP_FT_BLK         = $00400000; (* block special files, currently unused *)
      DP_FT_REG         = $00800000; (* regular files *)
      DP_FT_LNK         = $01000000; (* symbolic links *)
      DP_FT_SOCK        = $02000000; (* sockets, currently unused *)
      DP_FT_FIFO        = $04000000; (* pipes *)
      DP_FT_MEM         = $08000000; (* shared memory or proc files *)
      DP_XATTRFIELDS    = 8;
      DP_INDEX          = $0001;
      DP_DEV            = $0002;
      DP_RDEV           = $0004;
      DP_NLINK          = $0008;
      DP_UID            = $0010;
      DP_GID            = $0020;
      DP_BLKSIZE        = $0040;
      DP_SIZE           = $0080;
      DP_NBLOCKS        = $0100;
      DP_ATIME          = $0200;
      DP_CTIME          = $0400;
      DP_MTIME          = $0800;
      DP_MAXREQ         = 8;         (* highest legal request *)

CONST UNLIMITED         = $7fffffff; (* Dpathconf and Sysconf return this
                                      * when a value is not limited (or is 
                                      * limited only by available memory) 
                                      *)

(* various character constants and defines for TTY's *)

CONST MiNTEOF           = $0000ff1a; (* 1a == ^Z *)

CONST RAW               = $00;       (* defines for tty_read *)
      COOKED            = $01;
      NOECHO            = $00; 
      ECHO              = $02;
      ESCSEQ            = $04;       (* cursor keys, etc. get escape sequences *)

                                     (* constants for various Fcntl commands*)
                                     (* constants for Fcntl calls *)
CONST F_DUPFD           = 0;         (* handled by kernel *)
      F_GETFD           = 1;         (* handled by kernel *)
      F_SETFD           = 2;         (* handled by kernel *)
      FD_CLOEXEC        = 1;         (* close on exec flag *)
      F_GETFL           = 3;         (* handled by kernel *)
      F_SETFL           = 4;         (* handled by kernel *)
      F_GETLK           = 5;
      F_SETLK           = 6;
      F_SETLKW          = 7;

CONST FSTAT             = $4600;    (* handled by kernel *)

CONST FIONREAD          = $4601;
      FIONWRITE         = $4602;

CONST TIOCGETP          = $5400;
      TIOCSETP          = $5401;
      TIOCSETN          = TIOCSETP;
      TIOCGETC          = $5402;
      TIOCSETC          = $5403;
      TIOCGLTC          = $5404;
      TIOCSLTC          = $5405;
      TIOCGPGRP         = $5406;
      TIOCSPGRP         = $5407;
      TIOCFLUSH         = $5408;
      TIOCSTOP          = $5409;
      TIOCSTART         = $540A;
      TIOCGWINSZ        = $540B;
      TIOCSWINSZ        = $540C;
      TIOCGXKEY         = $540D;
      TIOCSXKEY         = $540E;
      TIOCIBAUD         = $540F;
      TIOCOBAUD         = $5410;
      TIOCCBRK          = $5414;
      TIOCSBRK          = $5415;
      TIOCGFLAGS        = $5416;
      TIOCSFLAGS        = $5417;
      TIOCOUTQ          = $5418;
      _TIOCSETP         = $5419;
      TIOCHPCL          = $541A;
      TIOCCAR           = $541B;
      TIOCNCAR          = $541C;
      TIOCWONLINE       = $541D;
      TIOCSFLAGSB       = $541E;
      TIOCGSTATE        = $541F;
      TIOCSSTATEB       = $5420;
      TIOCGVMIN         = $5421;
      TIOCSVMIN         = $5422;

CONST TCURSOFF          = $6300;
      TCURSON           = $6301;
      TCURSBLINK        = $6302;
      TCURSSTEADY       = $6303;
      TCURSSRATE        = $6304;
      TCURSGRATE        = $6305;

CONST PPROCADDR         = $5001;
      PBASEADDR         = $5002;
      PCTXTSIZE         = $5003;
      PSETFLAGS         = $5004;
      PGETFLAGS         = $5005;
      PTRACESFLAGS      = $5006;
      PTRACEGFLAGS      = $5007;
      PTRACEGO          = $5008;
      PTRACEFLOW        = $5009;
      PTRACESTEP        = $500A;
      PTRACE11          = $500B;  (* unused, reserved *)
      PLOADINFO         = $500C;
      PFSTAT            = $500D;

CONST SHMGETBLK         = $4D00;
      SHMSETBLK         = $4D01;


CONST T_CRMOD        = $0001; (* terminal control constants (tty.sg_flags) *)
      T_CBREAK       = $0002;
      T_ECHO         = $0004;
      T_RAW          = $0010;
      T_TOS          = $0080;
      T_TOSTOP       = $0100;
      T_XKEY         = $0200; (* Fread returns escape sequences for cursor keys, etc. *)
      T_ECHOCTL      = $0400; (* echo ctl chars as ^x *)
      T_TANDEM       = $1000;
      T_RTSCTS       = $2000;
      T_EVENP        = $4000; (* EVENP and ODDP are mutually exclusive *)
      T_ODDP         = $8000;

CONST TF_FLAGS       = $F000;  (* some flags for TIOC[GS]FLAGS *)
      TF_CAR         = $800;   (* nonlocal mode, require carrier *)
      TF_NLOCAL      = TF_CAR;
      TF_BRKINT      = $0080;  (* allow breaks interrupt (like ^C) *)
      TF_STOPBITS    = $0003;
      TF_1STOP       = $0001;
      TF_15STOP      = $0002;
      TF_2STOP       = $0003;
      TF_CHARBITS    = $000C;
      TF_8BIT        = 0;
      TF_7BIT        = $4;
      TF_6BIT        = $8;
      TF_5BIT        = $C;

(* the following are terminal status flags (tty.state) *)
(* (the low byte of tty.state indicates a part of an escape sequence still
 * hasn't been read by Fread, and is an index into that escape sequence)
 *)

CONST TS_ESC         = $00ff;
      TS_HOLD        = $1000;   (* hold (e.g. ^S/^Q) *)
      TS_COOKED      = $8000;   (* interpret control chars *)


(* structures for terminals *)

TYPE  tchars =       RECORD
                      t_intrc:  CHAR;
                      t_quitc:  CHAR;
                      t_startc: CHAR;
                      t_stopc:  CHAR;
                      t_eofc:   CHAR;
                      t_brkc:   CHAR;
                     END;

TYPE  ltchars =      RECORD
                      t_suspc:  CHAR;
                      t_dsuspc: CHAR;
                      t_rprntc: CHAR;
                      t_flushc: CHAR;
                      t_werasc: CHAR;
                      t_lnextc: CHAR;
                     END;

TYPE  sgttyb =       RECORD
                      sg_ispeed: CHAR;
                      sg_ospeed: CHAR;
                      sg_erase:  CHAR;
                      sg_kill:   CHAR;
                      sg_flags:  WORD;
                     END;

TYPE  winsize =      RECORD
                      ws_row:    INTEGER;
                      ws_col:    INTEGER;
                      ws_xpixel: INTEGER;
                      ws_ypixel: INTEGER;
                     END;

TYPE  xkey =         RECORD
                      xk_num: INTEGER;
                      xk_def: ARRAY [0..7] OF CHAR;
                     END;

TYPE  tty =          RECORD
                      pgrp:       INTEGER; (* process group of terminal *)
                      state:      INTEGER; (* terminal status, e.g. stopped *)
                      use_cnt:    INTEGER; (* number of times terminal is open *)
                      res1:       INTEGER; (* reserved for future expansion *)
                      sg:         sgttyb;
                      tc:         tchars;
                      ltc:        ltchars;
                      wsiz:       winsize;
                      rsel:       LONGINT; (* selecting process for read *)
                      wsel:       LONGINT; (* selecting process for write *)
                      xkey:       POINTER; (* extended keyboard table *)
                      hup_ospeed: LONGINT; (* saved ospeed while hanging up *)
                      vmin:       WORD;    (* min chars *)
                      vtime:      WORD;    (* timeout for RAW reads *)
                      resrvd:     LONGINT; (* for future expansion *)
                     END;

(* defines and declarations for Dcntl operations *)

CONST DEV_INSTALL    = $de02;
      DEV_NEWBIOS    = $de01;
      DEV_NEWTTY     = $de00;

(*-----------------------------------------------------------------*)
(* Functions & Procedures                                          *)
(*-----------------------------------------------------------------*)

PROCEDURE Getmpb (VAR p_mpb: MPB);
 EXTERNAL;

FUNCTION  Bconstat (dev: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Bconin (dev: INTEGER): LONGINT;
 EXTERNAL;

PROCEDURE Bconout (dev, c: INTEGER);
 EXTERNAL;

FUNCTION  Rwabs (rwflag: INTEGER; buf: POINTER;
                 count, recno, dev: INTEGER;
                 lrecno: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Setexc (vecnum: INTEGER; vec: POINTER): POINTER;
 EXTERNAL;

FUNCTION  Tickcal: LONGINT;
 EXTERNAL;

FUNCTION  Getbpb (dev: INTEGER): BPBPtr;
 EXTERNAL;

FUNCTION  Bcostat (dev: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Mediach (dev: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Drvmap: LONGINT;
 EXTERNAL;

FUNCTION  Kbshift (mode: INTEGER): LONGINT;
 EXTERNAL;

PROCEDURE Pterm0;
 EXTERNAL;

FUNCTION  Cconin: LONGINT;
 EXTERNAL;

PROCEDURE Cconout (c: INTEGER);
 EXTERNAL;

FUNCTION  Cauxin: INTEGER;
 EXTERNAL;

PROCEDURE Cauxout (c: INTEGER);
 EXTERNAL;

FUNCTION  Cprnout (c: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Crawio (w: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Crawcin: LONGINT;
 EXTERNAL;

FUNCTION  Cnecin: LONGINT;
 EXTERNAL;

PROCEDURE Cconws (str: STRING);

PROCEDURE Cconrs (VAR buf: LINE);
 EXTERNAL;

FUNCTION  Cconis: INTEGER;
 EXTERNAL;

FUNCTION  Dsetdrv (drv: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Cconos: INTEGER;
 EXTERNAL;

FUNCTION  Cprnos: INTEGER;
 EXTERNAL;

FUNCTION  Cauxis: INTEGER;
 EXTERNAL;

FUNCTION  Cauxos: INTEGER;
 EXTERNAL;

FUNCTION  Maddalt (start: POINTER; size: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Dgetdrv: INTEGER;
 EXTERNAL;

PROCEDURE Fsetdta (newDta: DTAPtr);
 EXTERNAL;

FUNCTION  Super (stack: POINTER): LONGINT;
 EXTERNAL;

FUNCTION  Tgetdate: WORD;
 EXTERNAL;

FUNCTION  Tsetdate (date: WORD): WORD;
 EXTERNAL;

FUNCTION  Tgettime: WORD;
 EXTERNAL;

FUNCTION  Tsettime (time: WORD): WORD;
 EXTERNAL;

FUNCTION  Fgetdta: DTAPtr;
 EXTERNAL;

FUNCTION  Sversion: INTEGER;
 EXTERNAL;

PROCEDURE Ptermres (keep: LONGINT; ret: INTEGER);
 EXTERNAL;

FUNCTION  Dfree (VAR buf: DISKINFO; drv: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Dcreate (pathname: STRING): INTEGER;

FUNCTION  Ddelete (pathname: STRING): INTEGER;

FUNCTION  Dsetpath (path: STRING): INTEGER;

FUNCTION  Fcreate (fname: STRING; attribs: INTEGER): LONGINT;

FUNCTION  Fopen (fname: STRING; mode: INTEGER): LONGINT;

FUNCTION  Fclose (handle: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Fread (handle: INTEGER; count: LONGINT; buffer: POINTER): LONGINT;
 EXTERNAL;

FUNCTION  Fwrite (handle: INTEGER; count: LONGINT; buffer: POINTER): LONGINT;
 EXTERNAL;

FUNCTION  Fdelete (fname: STRING): INTEGER;

FUNCTION  Fseek (offset: LONGINT; handle, seekmode: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Fattrib (fname: STRING; wflag, attribs: INTEGER): INTEGER;

FUNCTION  Mxalloc (amount: LONGINT; mode: INTEGER): POINTER;
 EXTERNAL;

FUNCTION  Fdup (handle: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Fforce (stdh, nonstdh: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Dgetpath (VAR buf: STRING; driveno: INTEGER): INTEGER;

FUNCTION  Malloc (amount: LONGINT): POINTER;
 EXTERNAL;

FUNCTION  Mfree (saddr: POINTER): INTEGER;
 EXTERNAL;

FUNCTION  Mshrink (zero: INTEGER; block: POINTER; newsize: LONGINT): INTEGER;
 EXTERNAL;

FUNCTION  Pexec (mode: INTEGER; prgfile, cmdline: STRING; envptr: POINTER): LONGINT;

PROCEDURE Pterm (retcode: INTEGER);
 EXTERNAL;

FUNCTION  Fsfirst (fspec: STRING; attribs: INTEGER): INTEGER;

FUNCTION  Fsnext: INTEGER;
 EXTERNAL;

FUNCTION  Frename (oldname, newname: STRING): INTEGER;

PROCEDURE Fdatime (VAR timeptr: DOSTIME; handle, wflag: INTEGER);
 EXTERNAL;

FUNCTION  Flock (handle, mode: INTEGER; start, length: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Syield: INTEGER;
 EXTERNAL;

FUNCTION  Fpipe (VAR usrh: ARRAY OF WORD): INTEGER;
 EXTERNAL;

FUNCTION  Fcntl (f: INTEGER; arg: LONGINT; cmd: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Finstat (f: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Foutstat (f: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Fgetchar (f, mode: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Fputchar (f: INTEGER; c: LONGINT; mode: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Pwait: LONGINT;
 EXTERNAL;

FUNCTION  Pnice (delta: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Pgetpid: INTEGER;
 EXTERNAL;

FUNCTION  Pgetppid: INTEGER;
 EXTERNAL;

FUNCTION  Pgetpgrp: INTEGER;
 EXTERNAL;

FUNCTION  Psetpgrp (pid, newgrp: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Pgetuid: INTEGER;
 EXTERNAL;

FUNCTION  Psetuid (id: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Pkill (pid, sig: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Psignal (sig: INTEGER; handler: POINTER): POINTER;
 EXTERNAL;

FUNCTION  Pvfork: INTEGER;
 EXTERNAL;

FUNCTION  Pgetgid: INTEGER;
 EXTERNAL;

FUNCTION  Psetgid (id: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Psigblock (mask: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Psigsetmask (mask: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Pusrval (arg: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Pdomain (newdom: INTEGER): INTEGER;
 EXTERNAL;

PROCEDURE Psigreturn;
 EXTERNAL;

FUNCTION  Pfork: INTEGER;
 EXTERNAL;

FUNCTION  Pwait3 (flag: INTEGER; VAR rusage: ARRAY OF LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Fselect (timeout: WORD; VAR rfds, wfds: LONGINT; xfds: LONGINT): INTEGER;
 EXTERNAL;

PROCEDURE Prusage (VAR r: ARRAY OF LONGINT);
 EXTERNAL;

FUNCTION  Psetlimit (lim: INTEGER; value: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Talarm (secs: LONGINT): LONGINT;
 EXTERNAL;

PROCEDURE Salert (msg: STRING);

PROCEDURE Pause;
 EXTERNAL;

FUNCTION  Sysconf (n: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Psigpending: LONGINT;
 EXTERNAL;

FUNCTION  Dpathconf (name: STRING ; n: INTEGER): LONGINT;

FUNCTION  Pmsg (mode: INTEGER; mbox: LONGINT; VAR msg: MSGTYPE): LONGINT;
 EXTERNAL;

FUNCTION  Fmidipipe (pid, inp, outp: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Prenice (pid, delta: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Dopendir (name: STRING ; flag: INTEGER): LONGINT;

FUNCTION  Dreaddir (buflen: INTEGER; dir: LONGINT; VAR buf: STRING): LONGINT;

FUNCTION  Drewinddir (dir: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Dclosedir (dir: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION Dgetcwd (VAR buf: STRING; drv, size: INTEGER): INTEGER;

FUNCTION  Fxattr (flag: INTEGER; name: STRING; VAR buf: XATTR): LONGINT;

FUNCTION  Flink (oldname, newname: STRING): LONGINT;

FUNCTION  Fsymlink (oldname, newname: STRING): LONGINT;

FUNCTION  Freadlink (size: INTEGER; VAR buf: STRING; name: STRING): LONGINT;

FUNCTION  Dcntl (cmd: INTEGER; name: STRING; arg: LONGINT): LONGINT;

FUNCTION  Fchown (name: STRING; uid, gid: INTEGER): LONGINT;

FUNCTION  Fchmod (name: STRING; mode: INTEGER): LONGINT;

FUNCTION  Pumask (mode: WORD): LONGINT;
 EXTERNAL;

FUNCTION  Psemaphore (mode: INTEGER; id, timeout: LONGINT): LONGINT;
 EXTERNAL;

FUNCTION  Dlock (mode, drive: INTEGER): LONGINT;
 EXTERNAL;

PROCEDURE Psigpause (mask: LONGINT);
 EXTERNAL;

FUNCTION  Psigaction (sig: INTEGER; act, oact: SIGACTIONPtr): LONGINT;
 EXTERNAL;

FUNCTION  Pgeteuid: INTEGER;
 EXTERNAL;

FUNCTION  Pgetegid: INTEGER;
 EXTERNAL;

FUNCTION  Pwaitpid (pid, flag: INTEGER; VAR rusage: ARRAY OF LONGINT): LONGINT;
 EXTERNAL;

PROCEDURE Initmous (typ: INTEGER; VAR param: MOUSE; vec: POINTER);
 EXTERNAL;

FUNCTION  Ssbrk (amount: INTEGER): POINTER;
 EXTERNAL;

FUNCTION  Physbase: POINTER;
 EXTERNAL;

FUNCTION  Logbase: POINTER;
 EXTERNAL;

FUNCTION  Getrez: INTEGER;
 EXTERNAL;

PROCEDURE Setscreen (logLoc, physLoc: POINTER; res: INTEGER);
 EXTERNAL;

PROCEDURE Setpalette (VAR palettePtr: ARRAY OF INTEGER);
 EXTERNAL;

FUNCTION  Setcolor (colorNum, color: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Floprate (drive, seekrate: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Floprd (buf, filler: POINTER;
                  devno, sectno, trackno, sideno, count: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Flopwr (buf, filler: POINTER;
                  devno, sectno, trackno, sideno, count: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Flopfmt (buf, filler: POINTER;
                   devno, spt, trackno, sideno, interlv: INTEGER;
                   magic: LONGINT; virgin: WORD): INTEGER;
 EXTERNAL;

PROCEDURE Midiws (cnt: INTEGER; ptr: POINTER);
 EXTERNAL;

PROCEDURE Mfpint (interno: INTEGER; vec: POINTER);
 EXTERNAL;

FUNCTION  Iorec (devno: INTEGER): IORECORDPtr;
 EXTERNAL;

FUNCTION  Rsconf (speed, flowctl, ucr, rsr, tsr, scr: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Keytbl (unshift, shift, capslock: POINTER): KEYTABPtr;
 EXTERNAL;

FUNCTION  Random: LONGINT;
 EXTERNAL;

PROCEDURE Protobt (buf: POINTER; serialno: LONGINT;
                   disktype, execflag: INTEGER);
 EXTERNAL;

FUNCTION  Flopver (buf, filler: POINTER;
                   devno, sectno, trackno, sideno, count: INTEGER): INTEGER;
 EXTERNAL;

PROCEDURE Scrdmp;
 EXTERNAL;

FUNCTION  Cursconf (mode, operand: INTEGER): INTEGER;
 EXTERNAL;

PROCEDURE Settime (datetime: LONGINT);
 EXTERNAL;

FUNCTION  Gettime: LONGINT;
 EXTERNAL;

PROCEDURE Bioskeys;
 EXTERNAL;

PROCEDURE Ikbdws (cnt: INTEGER; ptr: POINTER);
 EXTERNAL;

PROCEDURE Jdisint (intno: INTEGER);
 EXTERNAL;

PROCEDURE Jenabint (intno: INTEGER);
 EXTERNAL;

FUNCTION  Giaccess (data: BYTE; regno: INTEGER): BYTE;
 EXTERNAL;

PROCEDURE OFfgibit (bitno: INTEGER);
 EXTERNAL;

PROCEDURE Ongibit (bitno: INTEGER);
 EXTERNAL;

PROCEDURE Xbtimer (timer, control, data: INTEGER; vec: POINTER);
 EXTERNAL;

PROCEDURE Dosound (ptr: POINTER);
 EXTERNAL;

FUNCTION  Setprt (config: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Kbdvbase: KBDVECSPtr;
 EXTERNAL;

FUNCTION  Kbrate (initial, speed: INTEGER): INTEGER;
 EXTERNAL;

PROCEDURE Prtblk (VAR defptr: PBDEF);
 EXTERNAL;

PROCEDURE Vsync;
 EXTERNAL;

FUNCTION  Supexec (codeptr: LONGINTFunc): LONGINT;
 EXTERNAL;

PROCEDURE Puntaes;
 EXTERNAL;

FUNCTION  DMAread (sector: LONGINT; count: INTEGER;
                   buffer: POINTER; devno: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  DMAwrite (sector: LONGINT; count: INTEGER;
                    buffer: POINTER; devno: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Bconmap (devno: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  Blitmode (mode: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  EsetShift (shftmode: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  EgetShift: INTEGER;
 EXTERNAL;

FUNCTION  EsetBank (bankNum: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  EsetColor (colorNum, color: INTEGER): INTEGER;
 EXTERNAL;

PROCEDURE EsetPalette (colorNum, count: INTEGER; palettePtr: POINTER);
 EXTERNAL;

PROCEDURE EgetPalette (colorNum, count: INTEGER; palettePtr: POINTER);
 EXTERNAL;

FUNCTION  EsetGray (switch: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  EsetSmear (switch: INTEGER): INTEGER;
 EXTERNAL;

PROCEDURE Metainit (VAR buffer: METAINFO);
 EXTERNAL;

FUNCTION  Dsp_LoadProg (filename: STRING; ability: INTEGER;
                        buffer: POINTER): INTEGER;

FUNCTION  Dsp_LodToBinary (filename: STRING;
                           codeptr: POINTER): LONGINT;

PROCEDURE Dsp_DoBlock (data_in: POINTER; size_in: LONGINT;
                       data_out: POINTER; size_out: LONGINT);
 EXTERNAL;

PROCEDURE Dsp_BlkHandShake (data_in: POINTER; size_in: LONGINT;
                            data_out: POINTER; size_out: LONGINT);
 EXTERNAL;

PROCEDURE Dsp_BlkUnpacked (data_in: POINTER; size_in: LONGINT;
                           data_out: POINTER; size_out: LONGINT);
 EXTERNAL;

PROCEDURE Dsp_InStream (data_in: POINTER;
                        block_size, num_blocks: LONGINT;
                        VAR blocks_done: LONGINT);
 EXTERNAL;

PROCEDURE Dsp_OutStream (data_out: POINTER;
                         block_size, num_blocks: LONGINT;
                         VAR blocks_done: LONGINT);
 EXTERNAL;

PROCEDURE Dsp_IOStream (data_in, data_out: POINTER;
                        block_insize, block_outsize, num_blocks: LONGINT;
                        VAR blocks_done: LONGINT);
 EXTERNAL;

PROCEDURE Dsp_RemoveInterrupts (mask: INTEGER);
 EXTERNAL;

FUNCTION  Dsp_GetWORDSize: INTEGER;
 EXTERNAL;

FUNCTION  Dsp_Lock: INTEGER;
 EXTERNAL;

PROCEDURE Dsp_Unlock;
 EXTERNAL;

PROCEDURE Dsp_Available (VAR xavailable, yavailable: LONGINT);
 EXTERNAL;

FUNCTION  Dsp_Reserve (xreserve, yreserve: LONGINT): INTEGER;
 EXTERNAL;

PROCEDURE Dsp_ExecProg (codeptr: POINTER;
                        codesize: LONGINT; ability: INTEGER);
 EXTERNAL;

PROCEDURE Dsp_ExecBoot (codeptr: POINTER;
                        codesize: LONGINT; ability: INTEGER);
 EXTERNAL;

PROCEDURE Dsp_TriggerHC (vector: INTEGER);
 EXTERNAL;

FUNCTION  Dsp_RequestUniqueAbility: INTEGER;
 EXTERNAL;

FUNCTION  Dsp_GetProgAbility: INTEGER;
 EXTERNAL;

PROCEDURE Dsp_FlushSubroutines;
 EXTERNAL;

FUNCTION  Dsp_LoadSubroutine (codeptr: POINTER; 
                              codesize: LONGINT; ability: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Dsp_InqSubrAbility (ability: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Dsp_RunSubroutine (handle: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Dsp_Hf0 (flag: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Dsp_Hf1 (flag: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  Dsp_Hf2: INTEGER;
 EXTERNAL;

FUNCTION  Dsp_Hf3: INTEGER;
 EXTERNAL;

PROCEDURE Dsp_BlkWords (data_in: POINTER; size_in: LONGINT;
                        data_out: POINTER; size_out: LONGINT);
 EXTERNAL;

PROCEDURE Dsp_BlkBYTEs (data_in: POINTER; size_in: LONGINT;
                        data_out: POINTER; size_out: LONGINT);
 EXTERNAL;

FUNCTION  Dsp_HStat: BYTE;
 EXTERNAL;

PROCEDURE Dsp_SetVectors (receiver, transmitter: POINTER);
 EXTERNAL;

PROCEDURE Dsp_MultBlocks (numsend, numreceive: LONGINT;
                          sendblocks, receiveblocks: DSPBLOCKPtr);
 EXTERNAL;

FUNCTION  Vsetmode (modecode: INTEGER): INTEGER;
 EXTERNAL;

FUNCTION  mon_type: INTEGER;
 EXTERNAL;

FUNCTION  VgetSize (mode: INTEGER): LONGINT;
 EXTERNAL;

PROCEDURE VsetSync (flag: INTEGER);
 EXTERNAL;

PROCEDURE VsetRGB (index, count: INTEGER; CONST xrgbarray: ARRAY OF LONGINT);
 EXTERNAL;

PROCEDURE VgetRGB (index, count: INTEGER; VAR xrgbarray: ARRAY OF LONGINT);
 EXTERNAL;

PROCEDURE VsetMask (ormask, andmask, overlay: INTEGER);
 EXTERNAL;

FUNCTION  locksnd: LONGINT;
 EXTERNAL;

FUNCTION  unlocksnd: LONGINT;
 EXTERNAL;

FUNCTION  soundcmd (mode, data: INTEGER): LONGINT;
 EXTERNAL;

FUNCTION  setbuffer (reg: INTEGER; begaddr, endaddr: POINTER): LONGINT;
 EXTERNAL;

FUNCTION  setmode (mode: INTEGER): LONGINT; EXTERNAL;
FUNCTION  settracks (playtracks, rectracks: INTEGER): LONGINT; EXTERNAL;
FUNCTION  setmontracks (montrack: INTEGER): LONGINT; EXTERNAL;
FUNCTION  setinterrupt (src_inter, cause: INTEGER): LONGINT; EXTERNAL;
FUNCTION  buffoper (mode: INTEGER): LONGINT; EXTERNAL;
FUNCTION  dsptristate (dspxmit, dsprec: INTEGER): LONGINT; EXTERNAL;
FUNCTION  gpio (mode, data: INTEGER): LONGINT;  EXTERNAL;
FUNCTION  devconnect (src, dst, srcclk, prescale, protocol: INTEGER): LONGINT;  EXTERNAL;
FUNCTION  sndstatus (res: INTEGER): LONGINT;  EXTERNAL;
FUNCTION  buffptr (bptr: POINTER): LONGINT;  EXTERNAL;
FUNCTION  NVMaccess (op, start, count: INTEGER; bptr: POINTER): INTEGER;  EXTERNAL;

IMPLEMENTATION

{$L OS.O}

PROCEDURE _Cconws          (str: POINTER);  EXTERNAL;
FUNCTION  _Dcreate         (pathname: POINTER): INTEGER;  EXTERNAL;
FUNCTION  _Ddelete         (pathname: POINTER): INTEGER;  EXTERNAL;
FUNCTION  _Dsetpath        (path: POINTER): INTEGER;  EXTERNAL;
FUNCTION  _Fcreate         (fname: POINTER; attribs: INTEGER): LONGINT;  EXTERNAL;
FUNCTION  _Fopen           (fname: POINTER; mode: INTEGER): LONGINT;  EXTERNAL;
FUNCTION  _Fdelete         (fname: POINTER): INTEGER;  EXTERNAL;
FUNCTION  _Fattrib         (fname: POINTER; wflag, attribs: INTEGER): INTEGER;  EXTERNAL;
FUNCTION  _Dgetpath        (buf: POINTER; driveno: INTEGER): INTEGER;  EXTERNAL;
FUNCTION  _Dgetcwd         (buf: POINTER; drv, size: INTEGER): INTEGER; EXTERNAL;
FUNCTION  _Pexec           (mode: INTEGER; prgfile, cmdline: POINTER; envptr: POINTER): LONGINT;  EXTERNAL;
FUNCTION  _Fsfirst         (fspec: POINTER; attribs: INTEGER): INTEGER;  EXTERNAL;
FUNCTION  _Frename         (oldname, newname: POINTER): INTEGER;  EXTERNAL;
FUNCTION  _Dpathconf       (name: POINTER; n: INTEGER): LONGINT;  EXTERNAL;
FUNCTION  _Dopendir        (name: POINTER; flag: INTEGER): LONGINT;  EXTERNAL;
FUNCTION  _Dreaddir        (buflen: INTEGER; dir: LONGINT; buf: POINTER): LONGINT;  EXTERNAL;
FUNCTION  _Fxattr          (flag: INTEGER; name: POINTER; buf: XATTR): LONGINT;  EXTERNAL;
FUNCTION  _Flink           (oldname, newname: POINTER): LONGINT;  EXTERNAL;
FUNCTION  _Fsymlink        (oldname, newname: POINTER): LONGINT;  EXTERNAL;
FUNCTION  _Freadlink       (size: INTEGER; buf: POINTER; name: POINTER): LONGINT;  EXTERNAL;
FUNCTION  _Dcntl           (cmd: INTEGER; name: POINTER; arg: LONGINT): LONGINT;  EXTERNAL;
FUNCTION  _Fchown          (name: POINTER; uid, gid: INTEGER): LONGINT;  EXTERNAL;
FUNCTION  _Fchmod          (name: POINTER; mode: INTEGER): LONGINT;  EXTERNAL;
FUNCTION  _Dsp_LoadProg    (filename: POINTER; ability: INTEGER; buffer: POINTER): INTEGER;  EXTERNAL;
FUNCTION  _Dsp_LodToBinary (filename: POINTER; codeptr: POINTER): LONGINT;  EXTERNAL;
PROCEDURE _Salert          (msg: POINTER);   EXTERNAL;

PROCEDURE Cconws (str: STRING);
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (str, @cs);
 _Cconws (@cs);
END;

PROCEDURE Salert (msg: STRING);
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (msg, @cs);
 _Salert (@cs);
END;

FUNCTION  Dcreate (pathname: STRING): INTEGER;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (pathname, @cs);
 Dcreate:= _Dcreate (@cs);
END;

FUNCTION  Ddelete (pathname: STRING): INTEGER;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (pathname, @cs);
 Ddelete:= _Ddelete (@cs);
END;

FUNCTION  Dsetpath (path: STRING): INTEGER;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (path, @cs);
 Dsetpath:= _Dsetpath (@cs);
END;

FUNCTION  Fcreate (fname: STRING; attribs: INTEGER): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (fname, @cs);
 Fcreate:= _Fcreate (@cs, attribs);
END;

FUNCTION  Fopen (fname: STRING; mode: INTEGER): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (fname, @cs);
 Fopen:= _Fopen (@cs, mode);
END;

FUNCTION  Fdelete (fname: STRING): INTEGER;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (fname, @cs);
 Fdelete:= _Fdelete (@cs);
END;

FUNCTION  Fattrib (fname: STRING; wflag, attribs: INTEGER): INTEGER;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (fname, @cs);
 Fattrib:= _Fattrib (@cs, wflag, attribs);
END;

FUNCTION  Dgetpath (VAR buf: STRING; driveno: INTEGER): INTEGER;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 Dgetpath:= _Dgetpath (@cs, driveno);
 CToPascalString (buf, @cs);
END;

FUNCTION  Dgetcwd (VAR buf: STRING; drv, size: INTEGER): INTEGER;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 Dgetcwd:= _Dgetcwd (@cs, drv, size);
 CToPascalString (buf, @cs);
END;

FUNCTION  Pexec (mode: INTEGER; prgfile, cmdline: STRING; envptr: POINTER): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 (* Achtung! cmdline ist fÅr das GEMDOS ein Pascal-String! *)
 PascalToCString (prgfile, @cs);
 Pexec:= _Pexec (mode, @cs, @cmdline, envptr);
END;

FUNCTION  Fsfirst (fspec: STRING; attribs: INTEGER): INTEGER;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (fspec, @cs);
 Fsfirst:= _Fsfirst (@cs, attribs);
END;

FUNCTION  Frename (oldname, newname: STRING): INTEGER;
VAR cs, cs2: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (oldname, @cs);
 PascalToCString (newname, @cs2);
 Frename:= _Frename (@cs, @cs2);
END;

FUNCTION  Dpathconf (name: STRING ; n: INTEGER): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (name, @cs);
 Dpathconf:= _Dpathconf (@cs, n);
END;

FUNCTION  Dopendir (name: STRING ; flag: INTEGER): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (name, @cs);
 Dopendir:= _Dopendir (@cs, flag);
END;

FUNCTION  Dreaddir (buflen: INTEGER; dir: LONGINT; VAR buf: STRING): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 Dreaddir:= _Dreaddir (buflen, dir, @cs);
 CToPascalString (buf, @cs);
END;

FUNCTION  Fxattr (flag: INTEGER; name: STRING; VAR buf: XATTR): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (name, @cs);
 Fxattr:= _Fxattr (flag, @cs, buf);
END;

FUNCTION  Flink (oldname, newname: STRING): LONGINT;
VAR cs, cs2: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (oldname, @cs);
 PascalToCString (newname, @cs2);
 Flink:= _Flink (@cs, @cs2);
END;

FUNCTION  Fsymlink (oldname, newname: STRING): LONGINT;
VAR cs, cs2: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (oldname, @cs);
 PascalToCString (newname, @cs2);
 Fsymlink:= _Fsymlink (@cs, @cs2);
END;

FUNCTION  Freadlink (size: INTEGER; VAR buf: STRING; name: STRING): LONGINT;
VAR cs, cs2: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (buf, @cs);
 PascalToCString (name, @cs2);
 Freadlink:= _Freadlink (size, @cs, @cs2);
END;

FUNCTION  Dcntl (cmd: INTEGER; name: STRING; arg: LONGINT): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (name, @cs);
 Dcntl:= _Dcntl (cmd, @cs, arg);
END;

FUNCTION  Fchown (name: STRING; uid, gid: INTEGER): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (name, @cs);
 Fchown:= _Fchown (@cs, uid, gid);
END;

FUNCTION  Fchmod (name: STRING; mode: INTEGER): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (name, @cs);
 Fchmod:= _Fchmod (@cs, mode);
END;

FUNCTION  Dsp_LoadProg (filename: STRING; ability: INTEGER; buffer: POINTER): INTEGER;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (filename, @cs);
 Dsp_LoadProg:= _Dsp_LoadProg (@cs, ability, buffer);
END;

FUNCTION  Dsp_LodToBinary (filename: STRING; codeptr: POINTER): LONGINT;
VAR cs: ARRAY [0..255] OF CHAR;
BEGIN
 PascalToCString (filename, @cs);
 Dsp_LodToBinary:= _Dsp_LodToBinary (@cs, codeptr);
END;


END (*OS*).