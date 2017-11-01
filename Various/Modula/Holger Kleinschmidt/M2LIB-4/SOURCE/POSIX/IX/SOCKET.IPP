IMPLEMENTATION MODULE Socket;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 23-Mai-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, UNSIGNEDLONG, SIGNEDLONG, SIGNEDWORD;

FROM types IMPORT
(* TYPE *) int, sizeT;

FROM er IMPORT
(* VAR  *) errno;

FROM OSCALLS IMPORT
(* PROC *) Fopen, Fclose, Fcntl;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  SOCKETCALL = 5364H; (* (('S' << 8) | 100) *)

CONST
  RDWR = 2;

VAR
  sockdev : ARRAY [0..13] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE socket ((* EIN/ -- *) af       : int;
                  (* EIN/ -- *) type     : int;
                  (* EIN/ -- *) protocol : int ): int;

VAR scmd : RECORD
      cmd      : SIGNEDWORD;
      domain   : SIGNEDWORD;
      type     : SIGNEDWORD;
      protocol : SIGNEDWORD;
    END;

    hndl : INTEGER;
    lres : SIGNEDLONG;
    void : BOOLEAN;

BEGIN
 IF ~Fopen(ADR(sockdev), RDWR, hndl) THEN
   errno := hndl;
   RETURN(-1);
 END;
 scmd.cmd      := 0;
 scmd.domain   := VAL(SIGNEDWORD,af);
 scmd.type     := VAL(SIGNEDWORD,type);
 scmd.protocol := VAL(SIGNEDWORD,protocol);
 IF ~Fcntl(hndl, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   void  := Fclose(hndl, hndl);
   RETURN(-1);
 END;
 RETURN(hndl);
END socket;

(*---------------------------------------------------------------------------*)

PROCEDURE socketpair ((* EIN/ -- *)     af       : int;
                      (* EIN/ -- *)     type     : int;
                      (* EIN/ -- *)     protocol : int;
                      (* -- /AUS *) VAR sv       : SocketBuf ): int;

VAR scmd : RECORD
      cmd      : SIGNEDWORD;
      domain   : SIGNEDWORD;
      type     : SIGNEDWORD;
      protocol : SIGNEDWORD;
    END;

    hndl : INTEGER;
    lres : SIGNEDLONG;
    void : BOOLEAN;

BEGIN
 IF ~Fopen(ADR(sockdev), RDWR, hndl) THEN
   errno := hndl;
   RETURN(-1);
 END;
 scmd.cmd      := 1;
 scmd.domain   := VAL(SIGNEDWORD,af);
 scmd.type     := VAL(SIGNEDWORD,type);
 scmd.protocol := VAL(SIGNEDWORD,protocol);
 IF ~Fcntl(hndl, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   void  := Fclose(hndl, hndl);
   RETURN(-1);
 END;
 sv[0] := hndl;
 sv[1] := INT(lres);
 RETURN(0);
END socketpair;

(*---------------------------------------------------------------------------*)

PROCEDURE bind ((* EIN/ -- *) s       : int;
                (* EIN/ -- *) addr    : ADDRESS;
                (* EIN/ -- *) addrlen : sizeT ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      addr    : ADDRESS;
      addrlen : UNSIGNEDWORD;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd     := 2;
 scmd.addr    := addr;
 scmd.addrlen := VAL(UNSIGNEDWORD,addrlen);
 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(0);
END bind;

(*---------------------------------------------------------------------------*)

PROCEDURE listen ((* EIN/ -- *) s       : int;
                  (* EIN/ -- *) backlog : int ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      backlog : SIGNEDWORD;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd     := 3;
 scmd.backlog := VAL(SIGNEDWORD,backlog);
 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(0);
END listen;

(*---------------------------------------------------------------------------*)

PROCEDURE accept ((* EIN/ -- *)     s       : int;
                  (* EIN/ -- *)     addr    : ADDRESS;
                  (* EIN/AUS *) VAR addrlen : sizeT ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      addr    : ADDRESS;
      addrlen : POINTER TO UNSIGNEDWORD;
    END;

    lres : SIGNEDLONG;
    len  : UNSIGNEDWORD;
    done : BOOLEAN;

BEGIN
 len := VAL(UNSIGNEDWORD,addrlen);

 scmd.cmd     := 4;
 scmd.addr    := addr;
 scmd.addrlen := ADR(len);

 done    := Fcntl(s, ADR(scmd), SOCKETCALL, lres);
 addrlen := VAL(UNSIGNEDLONG,len);
 IF ~done THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(INT(lres));
END accept;

(*---------------------------------------------------------------------------*)

PROCEDURE connect ((* EIN/ -- *) s       : int;
                   (* EIN/ -- *) addr    : ADDRESS;
                   (* EIN/ -- *) addrlen : sizeT ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      addr    : ADDRESS;
      addrlen : UNSIGNEDWORD;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd     := 5;
 scmd.addr    := addr;
 scmd.addrlen := VAL(UNSIGNEDWORD,addrlen);
 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(0);
END connect;

(*---------------------------------------------------------------------------*)

PROCEDURE getsockname ((* EIN/ -- *)     s       : int;
                       (* EIN/ -- *)     addr    : ADDRESS;
                       (* EIN/AUS *) VAR addrlen : sizeT ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      addr    : ADDRESS;
      addrlen : POINTER TO UNSIGNEDWORD;
    END;

    lres : SIGNEDLONG;
    len  : UNSIGNEDWORD;
    done : BOOLEAN;

BEGIN
 len := VAL(UNSIGNEDWORD,addrlen);

 scmd.cmd     := 6;
 scmd.addr    := addr;
 scmd.addrlen := ADR(len);

 done    := Fcntl(s, ADR(scmd), SOCKETCALL, lres);
 addrlen := VAL(UNSIGNEDLONG,len);
 IF ~done THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(0);
END getsockname;

(*---------------------------------------------------------------------------*)

PROCEDURE getpeername ((* EIN/ -- *)     s       : int;
                       (* EIN/ -- *)     addr    : ADDRESS;
                       (* EIN/AUS *) VAR addrlen : sizeT ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      addr    : ADDRESS;
      addrlen : POINTER TO UNSIGNEDWORD;
    END;

    lres : SIGNEDLONG;
    len  : UNSIGNEDWORD;
    done : BOOLEAN;

BEGIN
 len := VAL(UNSIGNEDWORD,addrlen);

 scmd.cmd     := 7;
 scmd.addr    := addr;
 scmd.addrlen := ADR(len);

 done    := Fcntl(s, ADR(scmd), SOCKETCALL, lres);
 addrlen := VAL(UNSIGNEDLONG,len);
 IF ~done THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(0);
END getpeername;

(*---------------------------------------------------------------------------*)

PROCEDURE send ((* EIN/ -- *) s     : int;
                (* EIN/ -- *) msg   : ADDRESS;
                (* EIN/ -- *) len   : sizeT;
                (* EIN/ -- *) flags : MsgFlags ): int;

VAR scmd : RECORD
      cmd    : SIGNEDWORD;
      buf    : ADDRESS;
      buflen : UNSIGNEDLONG;
      flags  : MsgFlags;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd    := 8;
 scmd.buf    := msg;
 scmd.buflen := len;
 scmd.flags  := flags;

 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(INT(lres));
END send;

(*---------------------------------------------------------------------------*)

PROCEDURE sendto ((* EIN/ -- *) s     : int;
                  (* EIN/ -- *) msg   : ADDRESS;
                  (* EIN/ -- *) len   : sizeT;
                  (* EIN/ -- *) flags : MsgFlags;
                  (* EIN/ -- *) to    : ADDRESS;
                  (* EIN/ -- *) tolen : sizeT ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      buf     : ADDRESS;
      buflen  : UNSIGNEDLONG;
      flags   : MsgFlags;
      addr    : ADDRESS;
      addrlen : UNSIGNEDWORD;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd     := 9;
 scmd.buf     := msg;
 scmd.buflen  := len;
 scmd.flags   := flags;
 scmd.addr    := to;
 scmd.addrlen := VAL(UNSIGNEDWORD,tolen);

 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(INT(lres));
END sendto;

(*---------------------------------------------------------------------------*)

PROCEDURE recv ((* EIN/ -- *) s     : int;
                (* EIN/ -- *) msg   : ADDRESS;
                (* EIN/ -- *) len   : sizeT;
                (* EIN/ -- *) flags : MsgFlags ): int;

VAR scmd : RECORD
      cmd    : SIGNEDWORD;
      buf    : ADDRESS;
      buflen : UNSIGNEDLONG;
      flags  : MsgFlags;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd    := 10;
 scmd.buf    := msg;
 scmd.buflen := len;
 scmd.flags  := flags;

 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(INT(lres));
END recv;

(*---------------------------------------------------------------------------*)

PROCEDURE recvfrom ((* EIN/ -- *)     s       : int;
                    (* EIN/ -- *)     msg     : ADDRESS;
                    (* EIN/ -- *)     len     : sizeT;
                    (* EIN/ -- *)     flags   : MsgFlags;
                    (* EIN/ -- *)     from    : ADDRESS;
                    (* EIN/AUS *) VAR fromlen : sizeT ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      buf     : ADDRESS;
      buflen  : UNSIGNEDLONG;
      flags   : MsgFlags;
      addr    : ADDRESS;
      addrlen : POINTER TO UNSIGNEDWORD;
    END;

    lres : SIGNEDLONG;
    slen : UNSIGNEDWORD;
    done : BOOLEAN;

BEGIN
 slen := VAL(UNSIGNEDWORD,fromlen);

 scmd.cmd     := 11;
 scmd.buf     := msg;
 scmd.buflen  := len;
 scmd.flags   := flags;
 scmd.addr    := from;
 scmd.addrlen := ADR(slen);

 done    := Fcntl(s, ADR(scmd), SOCKETCALL, lres);
 fromlen := VAL(sizeT,slen);
 IF ~done THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(INT(lres));
END recvfrom;

(*---------------------------------------------------------------------------*)

PROCEDURE setsockopt ((* EIN/ -- *) s       : int;
                      (* EIN/ -- *) level   : int;
                      (* EIN/ -- *) optname : int;
                      (* EIN/ -- *) optval  : ADDRESS;
                      (* EIN/ -- *) optlen  : sizeT ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      level   : SIGNEDWORD;
      optname : SIGNEDWORD;
      optval  : ADDRESS;
      optlen  : UNSIGNEDLONG;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd     := 12;
 scmd.level   := VAL(SIGNEDWORD,level);
 scmd.optname := VAL(SIGNEDWORD,optname);
 scmd.optval  := optval;
 scmd.optlen  := optlen;

 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(0);
END setsockopt;

(*---------------------------------------------------------------------------*)

PROCEDURE getsockopt ((* EIN/ -- *)     s       : int;
                      (* EIN/ -- *)     level   : int;
                      (* EIN/ -- *)     optname : int;
                      (* EIN/ -- *)     optval  : ADDRESS;
                      (* EIN/AUS *) VAR optlen  : sizeT ): int;

VAR scmd : RECORD
      cmd     : SIGNEDWORD;
      level   : SIGNEDWORD;
      optname : SIGNEDWORD;
      optval  : ADDRESS;
      optlen  : POINTER TO UNSIGNEDLONG;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd     := 13;
 scmd.level   := VAL(SIGNEDWORD,level);
 scmd.optname := VAL(SIGNEDWORD,optname);
 scmd.optval  := optval;
 scmd.optlen  := ADR(optlen);

 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(0);
END getsockopt;

(*---------------------------------------------------------------------------*)

PROCEDURE shutdown ((* EIN/ -- *) s   : int;
                    (* EIN/ -- *) how : int ): int;

VAR scmd : RECORD
      cmd : SIGNEDWORD;
      how : SIGNEDWORD;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd := 14;
 scmd.how := VAL(SIGNEDWORD,how);

 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(0);
END shutdown;

(*---------------------------------------------------------------------------*)

PROCEDURE sendmsg ((* EIN/ -- *)     s     : int;
                   (* EIN/ -- *) VAR msg   : MsghdrRec;
                   (* EIN/ -- *)     flags : MsgFlags ): int;

VAR scmd : RECORD
      cmd   : SIGNEDWORD;
      msg   : ADDRESS;
      flags : MsgFlags;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd    := 15;
 scmd.msg    := ADR(msg);
 scmd.flags  := flags;

 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(INT(lres));
END sendmsg;

(*---------------------------------------------------------------------------*)

PROCEDURE recvmsg ((* EIN/ -- *)     s     : int;
                   (* -- /AUS *) VAR msg   : MsghdrRec;
                   (* EIN/ -- *)     flags : MsgFlags ): int;

VAR scmd : RECORD
      cmd   : SIGNEDWORD;
      msg   : ADDRESS;
      flags : MsgFlags;
    END;

    lres : SIGNEDLONG;

BEGIN
 scmd.cmd    := 16;
 scmd.msg    := ADR(msg);
 scmd.flags  := flags;

 IF ~Fcntl(s, ADR(scmd), SOCKETCALL, lres) THEN
   errno := INT(lres);
   RETURN(-1);
 END;
 RETURN(INT(lres));
END recvmsg;

BEGIN
 sockdev := "u:\dev\socket";
END Socket.
