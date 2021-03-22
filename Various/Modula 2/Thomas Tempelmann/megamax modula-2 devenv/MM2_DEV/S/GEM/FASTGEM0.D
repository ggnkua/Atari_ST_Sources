DEFINITION MODULE FastGEM0;


(*  System              : Megamax Modula-2 (MOS 2.0)
 *  Author & Copyright  : Manuel Chakravarty
 *  Vertrieb            : Application Systems Heidelberg
 *  Version             : 1.0           V#0004
 *)
 
(*  Dies Modul stellt eine schnelle Kopierfunktion fÅr beliebige Bildschirm-
 *  bereiche zur VerfÅgung.
 *)


FROM GrafBase   IMPORT Rectangle, BitOperation, PtrMemFormDef;

FROM GEMEnv     IMPORT DeviceHandle;


PROCEDURE CopyOpaque (dev        : DeviceHandle;
                      sourceMem,
                      destMem    : PtrMemFormDef;
                      sourceFrame,
                      destFrame  : Rectangle;
                      mode       : BitOperation);
                      
        (*  Diese Routine entspricht in ihrer Funktion der Prozedur
         *  'VDIRasters.CopyOpaque'. Allerdings zeigt sie bei nicht
         *  vorhandenem Blitter ein besseres Laufzeitverhalten.
         *  Ist ein Blitter vorhanden, so wird dies erkannt und die
         *  VDI-Routine aufgerufen.
         *
         *  Hinweis: Die aktuelle Implementation Åbernimmt das Kopieren
         *           nur in einigen SonderfÑllen und gibt die Åbrigen
         *           FÑlle an das VDI weiter. Dadurch treten aber
         *           keine Nachteile auf.
         *)


END FastGEM0.
