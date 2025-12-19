(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*-   Name            : PlugParms                                         -*)
(*-   Version         : 1.0                                               -*)
(*-   Art             : Definition Module                                 -*)
(*-   Aufgabe         : Parametermodul fÅr PlugIns                        -*)
(*-   Autor           : Steffen Engel                       (C) 91        -*)
(*-   Letzte énderung : 00.00.0000, 00:00:00                              -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*-   Beschreibung  : Sammlung aller Aufruf-Parameter von PlugIns         -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*-   History                                                             -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-   Vers | Datum    | Beschreibung                                      -*)
(*-  ------|----------|---------------------------------------            -*)
(*-   1.0  | 12.02.94 | zusammengestellt.                                 -*)
(*-        |          |                                                   -*)
(*-        |          |                                                   -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
DEFINITION MODULE PlugParms;

IMPORT SYSTEM;

(* Magic-Lib *)
FROM MagicSys   IMPORT
                (* Const *) Nil, Null, Bit0, Bit1, Bit2, Bit3, Bit4, Bit5,
                            Bit6, Bit7, Bit8, Bit9, Bit10, Bit11, Bit12,
                            Bit13, Bit14, Bit15,
                (* Type  *) LOC, Byte, ByteSet, sWORD, sINTEGER, sCARDINAL,
                            sBITSET, lINTEGER, lCARDINAL, lWORD, lBITSET;



CONST ParmVersion = 0100H;         (* Version des Parameterblockes *)
      PathLen     = 512;

TYPE
     (* Umgebung der PlugIns, wird bei der Initialisierung Åbergeben *)
     tpPlugEnvironment = POINTER TO tPlugEnvironment;
     tPlugEnvironment
        = RECORD
            (* aktuelle Parameterversion = 0.00 = 0000H *)
            Version  : sINTEGER;                          (* Version zeigt Umfang der Parameter an   *)
            Private  : SYSTEM.ADDRESS;                    (* private Parameter fÅr Modul-Rumpf       *)
            ApplId   : sINTEGER;                          (* Applikationsid des rufenden Programmes  *)
            VDIHandle : sINTEGER;                         (* Workstation des Hauptprogrammes         *)
            PlugPath : POINTER TO ARRAY[0..PathLen-1] OF CHAR;  (* Name und Pfad des PlugIn, kann auch
                                                             relativ sein                            *)
            (*$K+*)
            Alert    : PROCEDURE(   (* def   *) sINTEGER,
                                 VAR(* msg   *) STRING) : sINTEGER;
            (*$K=*)
          END;




END PlugParms.