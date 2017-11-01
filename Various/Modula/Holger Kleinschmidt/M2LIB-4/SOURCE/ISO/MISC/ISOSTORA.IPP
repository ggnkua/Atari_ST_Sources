IMPLEMENTATION MODULE ISOStorage;
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
(* 03-Jan-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNED;

IMPORT SYSTEM, EXCEPTIONS;

IMPORT mem;

FROM er IMPORT
(* VAR  *) errno;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  storageSource : EXCEPTIONS.ExceptionSource;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ALLOCATE ((* -- /AUS *) VAR addr   : SYSTEM.ADDRESS;
                    (* EIN/ -- *)     amount : UNSIGNED       );

BEGIN
 addr := mem.malloc(amount);
 IF addr = NULL THEN
   addr := NIL;
 END;
END ALLOCATE;

(*---------------------------------------------------------------------------*)

PROCEDURE DEALLOCATE ((* EIN/AUS *) VAR addr   : SYSTEM.ADDRESS;
                      (* EIN/ -- *)     amount : UNSIGNED       );

BEGIN
 IF addr = NIL THEN
   EXCEPTIONS.RAISE(storageSource, ORD(nilDeallocation),
                    "ISOStorage.DEALLOCATE: address = NIL");
 END;
 errno := 0;
 mem.free(addr);
 IF errno # 0 THEN
   EXCEPTIONS.RAISE(storageSource, ORD(pointerToUnallocatedStorage),
                    "ISOStorage.DEALLOCATE: wrong address");
 END;
 addr := NIL;
END DEALLOCATE;

(*---------------------------------------------------------------------------*)

PROCEDURE IsStorageException ( ): BOOLEAN;
BEGIN
 RETURN(EXCEPTIONS.IsCurrentSource(storageSource));
END IsStorageException;

(*---------------------------------------------------------------------------*)

PROCEDURE StorageException ( ): StorageExceptions;
BEGIN
 RETURN(VAL(StorageExceptions,EXCEPTIONS.CurrentNumber(storageSource)));
END StorageException;

BEGIN (* ISOStorage *)
 EXCEPTIONS.AllocateSource(storageSource);
END ISOStorage.
