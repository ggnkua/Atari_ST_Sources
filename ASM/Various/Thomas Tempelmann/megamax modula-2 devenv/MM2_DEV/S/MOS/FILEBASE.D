DEFINITION MODULE FileBase;

(*
   5.6.88  TT  Die Treibervariablen f. InOut befinden sich nun im Modul
                'InOutBase'.
   7.8.89  TT  'ErrMsgField' nun als 'FileErrMsg' in 'MOSConfig'
   3.9.89  TT  'UDriver' erweitert/geÑndert
*)

FROM SYSTEM IMPORT LONGWORD, ADDRESS;

FROM SysTypes IMPORT ScanDesc;


TYPE    File0;


TYPE    CloseProc = PROCEDURE ( File0, (* new: *) BOOLEAN);
        ErrorProc = PROCEDURE ( VAR File0, (* errNo: *) INTEGER, ScanDesc );

VAR     CloseFile  : CloseProc;
        HandleError: ErrorProc;

VAR     InitDriver: PROC;       (* Wird aufgerufen, sobald Files init. ist *)

TYPE    Unit = (con,prn,aux,kbd,midi,ext1,ext2,ext3,ext4,ext5,ext6,ext7);
        UOpenProc  = PROCEDURE ( VAR (* handle: *) LONGWORD,
                                     (* name:   *) ARRAY OF CHAR ): INTEGER;
        UCloseProc = PROCEDURE ( (* handle: *) LONGWORD ): INTEGER;
        UFlushProc = PROCEDURE ( (* handle: *) LONGWORD ): INTEGER;
        UGChrProc  = PROCEDURE ( (* handle: *) LONGWORD ): INTEGER;
                                     (* RETURN: <0:Fehler, >0:ORD(Zeichen) *)
        UEOFProc   = PROCEDURE ( (* handle: *) LONGWORD ): BOOLEAN;
        URStrProc  = PROCEDURE (     (* handle: *) LONGWORD,
                                 VAR (* string: *) ARRAY OF CHAR ): INTEGER;
        UWStrProc  = PROCEDURE (     (* handle: *) LONGWORD,
                                 REF (* string: *) ARRAY OF CHAR ): INTEGER;
        UDataProc  = PROCEDURE (     (* handle: *) LONGWORD,
                                     (* addr:   *) ADDRESS,
                                 VAR (* len:    *) LONGCARD ): INTEGER;

        UDriver = RECORD
                    valid  : BOOLEAN;    (* TRUE: Unit installiert *)
                    name   : ARRAY [0..7] OF CHAR; (* mit ":" am Ende! *)
                    CASE console: BOOLEAN OF
                     TRUE:
                      (* InOut-Treiber verwenden *)|
                     FALSE:
                       input  : BOOLEAN;    (* TRUE: Eingabe mîglich *)
                       output : BOOLEAN;    (* TRUE: Ausgabe mîglich *)
                       initHdl: LONGWORD;   (* Hilfswert, wird bei E/A Pro-  *)
                                            (* zeduren als 'handle' Åbergeben*)
                       open   : UOpenProc;  (* ôffnungsprozedur *)
                       close  : UCloseProc; (* Schlieûprozedur *)
                       eof    : UEOFProc;   (* physik. EOF-Abfrage *)
                       flush  : UFlushProc; (* 'Flush'-Prozedur *)
                       wrData : UDataProc;  (* Ausgabe f. beliebige Daten *)
                       wrStr  : UWStrProc;  (* Ausgabe f. Strings (0-term.)*)
                       rdData : UDataProc;  (* Eingabe f. beliebige Daten *)
                       rdChr  : UGChrProc;  (* Eingabe f. einzelne CHARs *)
                    END
                  END;

VAR     (* Treiberfunktionen fÅr Modul 'Files' *)
        UnitDriver: ARRAY [con..ext7] OF UDriver;

END FileBase.
