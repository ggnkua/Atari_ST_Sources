MODULE newmail;

(*
This  is  a  simple  newmail  accessory.  It  is  thought  to be used under
MultiAES,   since  MultiAES  allows  more than six accessories. If you like
risks, you may comment the AES.Version() inquiry at the beginning.

newmail.M2  has been written by means of crystal (m2gem???.lzh) and M2POSIX
(m2posx??.zoo).  Both libraries are to be found at atari.archive.umich.edu,
directory programming, or uni-kl.de or cs.tu-berlin.de, directory
pub/atari/Programming/Modula-2.

features:
- full configuration via resource file, for example you may configure the
  environment string for the mail check time (which is usually MAILCHECK)
  or you may change the mail path

todo:
- window with X-like mail box graphics

version 1: Kees Lemmens lemmens@dv.twi.tudelft.nl
version 2: Jereon Berger berger@tudebg.et.tudelft.nl
accessory: Ulrich Kaiser ig04@rz.uni-karlsruhe.de and Holger Kleinschmidt

v0.18 acc, UK 08/02/1995
*)

(* from crystal: *)

FROM ApplMgr    IMPORT ApplInit;
FROM MenuMgr    IMPORT MenuRegister;
FROM FormMgr    IMPORT FormAlert;
FROM EvntMgr    IMPORT EvntEvent,MEvent,Event,MessageBlock,MuMesag,MuTimer,
                       AcOpen,AcClose,
                       WMRedraw,WMTopped,WMClosed,WMMoved;
FROM RsrcMgr    IMPORT RsrcLoad;
FROM WindMgr    IMPORT WindCreate,WindOpen,WindClose,WindDelete,Wind,Close;

FROM FormTool   IMPORT Alert;
FROM WindTool   IMPORT BeginUpdate,EndUpdate;
FROM RsrcTool   IMPORT GetFreeStringPtr;

FROM PORTAB     IMPORT SIGNEDWORD,UNSIGNEDWORD,MAXUNSIGNEDLONG,ANYTYPE,
                       ANYPOINTER;
FROM INTRINSIC  IMPORT VOID,PTR,UNSIGNEDWORDOF,SIZEOF;

IMPORT AES,WindGet,WindSet;

(* from M2POSIX: *)

FROM ANSIC      IMPORT unsignedint,int,getenv,NULL,StrPtr,strcpy,strcat,
                       atoi,void,ptr;
FROM POSIX1     IMPORT creat,close,
                       FileModes, (* sIRUSR, sIWUSR *)
                       modeT,offT,getlogin,stat,StatRec;

(* resource indices created by Interface *)

CONST NEWMAIL   = 0;    (* Alert String *)
      NOMAIL    = 1;    (* Alert String *)
      NOLOGIN   = 2;    (* Alert String *)
      MAILERROR = 3;    (* Alert String *)

      NEWMAILMENU  = 4;    (* Freier String *)
      MAILWIN      = 5;    (* Freier String *)
      MAILCHECKENV = 6;    (* Freier String *)
      MAILPATH     = 7;    (* Freier String *)

TYPE PathStr = ARRAY[0..128] OF CHAR;

VAR ApplId    : SIGNEDWORD;
    MenuId    : SIGNEDWORD;
    AccName   : ARRAY[0..20] OF CHAR;
    AccNamePtr: ANYPOINTER;
    MyBlock   : MEvent;
    MyEvent   : Event;
    MyMessage : MessageBlock;
    LastMsg   : AES.TreeIndex;

    LogName   : ANYPOINTER;
    MailPath  : ANYPOINTER;
    MailFile  : PathStr;
    FileStat  : StatRec;
    CheckEnv  : ANYPOINTER;
    EnvBuf    : ARRAY[0..32] OF CHAR;
    usSleep   : unsignedint;
    fh        : int;
    LastSize  : offT;
    Exit      : BOOLEAN;

PROCEDURE DoCheck;

VAR exists: BOOLEAN;

BEGIN
  exists:= stat(MailFile,FileStat) = 0;
  IF NOT exists THEN
    fh:= creat(MailFile,modeT{sIRUSR,sIWUSR});
    IF fh >= 0 THEN
      void(close(fh));
    END;

    exists:= stat(MailFile,FileStat) = 0;
    IF NOT exists THEN
      IF NOT Exit THEN
        Alert(MAILERROR); LastMsg:= MAILERROR;
        Exit:= TRUE;
      END;
    ELSE
      LastMsg:= NOMAIL;
      Exit:= FALSE;
    END;
  END;

  IF exists AND (FileStat.stSize > LastSize) THEN
    Alert(NEWMAIL); LastMsg:= NEWMAIL;
  END;

  LastSize:= FileStat.stSize;
END DoCheck;

PROCEDURE DoAcOpen(Id: SIGNEDWORD);
BEGIN
  IF Id = MenuId THEN
    Alert(LastMsg);
  END;
END DoAcOpen;

PROCEDURE DoAcClose(Id: SIGNEDWORD);
BEGIN
  IF Id = MenuId THEN
    ;
  END;
END DoAcClose;

PROCEDURE Endless;
BEGIN
  WITH MyBlock DO
    EFlags:= Event{MuTimer};
    EHiCount:= 32767;
    ELoCount:= 0;
  END;

  LOOP
    VOID(EvntEvent(MyBlock));
  END;
END Endless;

BEGIN
  ApplId:= ApplInit();

  IF (ApplId >= 0) THEN
    IF (AES.Version() >= 0300H) THEN

      (*
      remember that the filename "NEWMAIL.RSC" could have been created
      in lower case.
      *)

      BeginUpdate; (* lock user action *)
      IF RsrcLoad("newmail.rsc") THEN
        EndUpdate;

        (* do some initialisations *)

        LastMsg:= NOMAIL;
        usSleep:= 5;
        LastSize:= 0;
        Exit:= FALSE;
        MailFile:= "/usr/dead.letter";
        MenuId:= -1;

        (* look for MAILCHECK= or mail= or something else *)

        CheckEnv:= GetFreeStringPtr(MAILCHECKENV);
        IF CheckEnv # NIL THEN
          (* because CheckEnv^ must not be word-aligned, do copy *)
          strcpy(ptr(EnvBuf),CheckEnv);
          usSleep:= atoi(getenv(EnvBuf)); (* atoi() handles NULL *)
          IF usSleep = 0 THEN (* error *)
            usSleep:= 5;
          ELSIF SIZEOF(usSleep) = 2 THEN
            IF usSleep > 32 THEN (* would cause an overflow *)
              usSleep:= 32;
            END;
          (*
          ELSIF SIZEOF(usSleep) = 4 THEN
            IF usSleep > MAXUNSIGNEDLONG DIV 1000 THEN
              usSleep:= MAXUNSIGNEDLONG DIV 1000;
            END;
          *)
          END;
        END;

        (* concat the mail filename *)

        LogName:= getlogin();
        IF LogName = NULL THEN
          Alert(NOLOGIN); LastMsg:= NOLOGIN;
          Exit:= TRUE;
        END;

        IF NOT Exit THEN
          MailPath:= GetFreeStringPtr(MAILPATH);
          IF MailPath # NIL THEN
            strcpy(ptr(MailFile),MailPath);
            strcat(ptr(MailFile),LogName);
          END;
        END;

        AccNamePtr:= GetFreeStringPtr(NEWMAILMENU);
        IF AccNamePtr # NIL THEN
          strcpy(ptr(AccName),AccNamePtr);
          MenuId:= MenuRegister(ApplId,AccName);
        END;

       (* MenuId is initialised by -1 *)

        IF MenuId >= 0 THEN

          WITH MyBlock DO
            EFlags:= Event{MuMesag,MuTimer};
            EMePBuf:= PTR(MyMessage);
            usSleep:= usSleep * 1000; (* maximum 32000 *)
            EHiCount:= UNSIGNEDWORDOF(usSleep DIV 10000H);
            ELoCount:= UNSIGNEDWORDOF(usSleep MOD 10000H);
          (*EHiCount:= 0;      *)
          (*ELoCount:= usSleep;*)
          END;

          LOOP
            MyEvent:= EvntEvent(MyBlock);

            IF MuMesag IN MyEvent THEN
              WITH MyMessage DO
                CASE Type OF
                (*
                  WMRedraw:
                    DoRedraw(Handle);
                | WMTopped:
                    DoTopped(Handle);
                | WMMoved:
                    DoMoved(Handle,Rect);
                | WMClosed:
                    DoClose(Handle);
                *)
                  AcOpen:
                    DoAcOpen(OpenId);
                | AcClose:
                    DoAcClose(CloseId);
                ELSE
                  ;
                END;
              END;
            END;

            IF (MuTimer IN MyEvent) THEN
              DoCheck;
            END;

          END; (* LOOP *)
        END;
      ELSE
        EndUpdate;
      END;
    END;
    Endless;
  END;
END newmail.
