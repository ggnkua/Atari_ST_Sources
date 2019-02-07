IMPLEMENTATION MODULE GEMAES;

(*
GEMAES Implementations.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)
(*DRIVER*)

FROM PORTAB IMPORT ANYBYTE,ANYWORD,ANYLONG,SIGNEDWORD,UNSIGNEDWORD,
                   UNSIGNEDLONG,SIGNEDBYTE,UNSIGNEDBYTE,
                   BYTESET,WORDSET,ANYPOINTER,ANYTYPE;

IMPORT ApplMgr,
       EvntMgr,
       MenuMgr,
       ObjcMgr,
       FormMgr,
       GrafMgr,
       ScrpMgr,
       FSelMgr,
       WindMgr,
       RsrcMgr,
       ShelMgr,
       XGrfMgr;

(* VAR PROCEDUREs **********************************************************)

PROCEDURE ApplInit(): SIGNEDWORD;
BEGIN
  RETURN ApplMgr.ApplInit();
END ApplInit;

(* reexports ***************************************************************)

#if not ISO_proc_const
BEGIN
  ApplRead:= ApplMgr.ApplRead;
  ApplWrite:= ApplMgr.ApplWrite;
  ApplFind:= ApplMgr.ApplFind;
  (* to be continued *)
#endif
END GEMAES.
