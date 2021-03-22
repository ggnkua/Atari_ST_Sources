DEFINITION MODULE GEMBase;


(*  System              : Megamax Modula-2 (MOS 2.2)
 *  Autor & Copyright   : Manuel Chakravarty
 *  Vertrieb            : Application Systems Heidelberg
 *  Version             : 1.0 (V#0002)
 *
 *  Nach Anregungen von Michael Seyfried.
 *)

(*  Dieses Modul soll das Programmieren von VDI- und AES-Aufrufen gestatten,
 *  die die GEM-Library umgehen. Die Namen wurden soweit mîglich direkt von
 *  entsprechenden C-Bindings Åbernommen und deshalb sollte es unter
 *  Zuhilfenahme entsprechender GEM-Literatur mîglich sein dieses Modul ohne
 *  groûe ErklÑrungen, die diesen Rahmen sprengen wÅrden zu benutzen.
 *
 *  Die Prozeduren dieses Moduls lassen sich in zwei Kategorien aufteilen:
 *  Abfrageroutinen und Aufrufroutinen. Erstere sind nur nîtig, falls mit
 *  schon bestehenden Anmeldungen beim AES oder VDI weitergearbeitet werden
 *  soll (Anmeldungen, die ursprÅnglich von 'GEMEnv' durchgefÅhrt wurden).
 *  Die Aufrufroutinen dienen zum Benutzen einer VDI- bzw. AES-Funktion.
 *  Es ist zu beachten, daû die automatischen Abmeldungen, wie z.B. das
 *  Schlieûen aller noch offenen Fenster bei der Terminierung eines Prozesses
 *  bei Aufrufen, die mit diesem Modul durchgefÅhrt werden in der Eigenver-
 *  antwortung des Programmierers bleiben und nicht mehr vom System kontrol-
 *  liert werden.
 *
 *  Benutzen einer bestehenden Anmeldung beim AES (APPL_INIT):
 *
 *    i)  Ermitteln des AES-Parameterblocks mit 'GetPBs'
 *    ii) Bei jedem Aufruf wird die Adresse auf den ermittelten Parameterblock
 *        an 'CallAES' Åbergeben
 *
 *  Benutzen einer bestehenden Anmeldung beim VDI (OPEN [VIRTUAL] WORKSTATION)
 *
 *    i)   Ermitteln des VDI-Parameterblocks mit 'GetPBs'
 *    ii)  Ermitteln der GerÑtekennung mit 'VDIHandle'.
 *    iii) Bei jedem Aufruf muû 'pb.pblock^.handle' die in ii) ermittelte
 *         Kennung zugewiesen werden und dann wird die Adresse auf den er-
 *         mittelten VDI-Parameterblock an 'CallVDI' Åbergeben
 *
 *  Anwendungsbeispiele finden sich im DEMO-Ordner: AESDEMO.M und VDIDEMO.M!
 *
 *  ACHTUNG: Bei der Verwendung dieses Moduls kînnen auf einfachste Weise
 *           die herlichsten AbstÅrze erzeugt werden oder die GEM-Library
 *           in Verwirrung gebracht werden. Daher sollte es nur verwendet
 *           werden, sobald es unbedingt nîtig ist und man ausreichend mit
 *           dem GEM vertraut ist.
 *)


FROM    SYSTEM  IMPORT  ADDRESS;

FROM    GEMEnv  IMPORT  GemHandle, DeviceHandle;


TYPE    IntinArray      = ARRAY[0..127] OF INTEGER;
        IntoutArray     = ARRAY[0..127] OF INTEGER;
        PtsinArray      = ARRAY[0..511] OF INTEGER;
        PtsoutArray     = ARRAY[0..11]  OF INTEGER;
        AdrinArray      = ARRAY[0..2]   OF ADDRESS;
        AdroutArray     = ARRAY[0..1]   OF ADDRESS;
        PtrIntinArray   = POINTER TO IntinArray;
        PtrIntoutArray  = POINTER TO IntoutArray;
        PtrPtsinArray   = POINTER TO PtsinArray;
        PtrPtsoutArray  = POINTER TO PtsoutArray;
        PtrAdrinArray   = POINTER TO AdrinArray;
        PtrAdroutArray  = POINTER TO AdroutArray;

        (*  VDI-Typen *)

        VDIContrlArray  = RECORD
                            opcode      : CARDINAL;
                            sptsin      : CARDINAL;
                            sptsout     : CARDINAL;
                            sintin      : CARDINAL;
                            sintout     : CARDINAL;
                            subcmd      : CARDINAL;
                            handle      : INTEGER;
                            multi1      : INTEGER;
                            multi2      : INTEGER;
                            multi3      : INTEGER;
                            multi4      : INTEGER;
                            multi5      : INTEGER;
                          END;
        PtrVDIContrlArray= POINTER TO VDIContrlArray;

        (*  VDI-Parameterblock
         *)
        VDIPB           = RECORD
                            pblock      : PtrVDIContrlArray;
                            iioff       : PtrIntinArray;
                            pioff       : PtrPtsinArray;
                            iooff       : PtrIntoutArray;
                            pooff       : PtrPtsoutArray;
                          END;
        PtrVDIPB        = POINTER TO VDIPB;
        
        
        (*  AES-Typen  *)
        
        AESContrlArray  = RECORD
                            opcode      : CARDINAL;
                            sintin      : CARDINAL;
                            sintout     : CARDINAL;
                            sadrin      : CARDINAL;
                            sadrout     : CARDINAL;
                          END;
        PtrAESContrlArray= POINTER TO AESContrlArray;

        GlobalArray     = RECORD
                            version     : INTEGER;
                            count       : INTEGER;
                            id          : INTEGER;
                            pprivate    : ADDRESS;
                            ptree       : ADDRESS;
                            pmem        : ADDRESS;
                            lmem        : INTEGER;
                            nplanes     : INTEGER;
                            resvd11     : INTEGER;
                            resvd12     : INTEGER;
                            bvdisk      : BITSET;
                            bvhard      : BITSET;
                          END;
        PtrGlobalArray  = POINTER TO GlobalArray;
                 
        (*  AES-Parameterblock
         *)
        AESPB           = RECORD
                            pcontrl     : PtrAESContrlArray;
                            pglobal     : PtrGlobalArray;
                            pintin      : PtrIntinArray;
                            pintout     : PtrIntoutArray;
                            padrin      : PtrAdrinArray;
                            padrout     : PtrAdroutArray;
                          END;
        PtrAESPB        = POINTER TO AESPB;


                        (*  Abfrageroutinen  *)
                        (*  ===============  *)

PROCEDURE GetPBs (gemHdl: GemHandle; VAR vdipb: VDIPB; VAR aespb: AESPB);

        (*  Liefert die Parmeterblîcke zu einer GEM-Referenz.
         *
         *  Die zurÅckgelieferten Parameterblîcke sind eine Kopie der
         *  Blîcke, die von der GEM-Library beim Aufruf einer VDI- bzw.
         *  AES-Routine benutzt werden, falls 'gemHdl' die zu diesem Zeit-
         *  punkt aktuelle GEM-Referenz ist (siehe 'GEMEnv.CurrGemHandle).
         *  Ist einer der Parameterblîcke mit dem Wert 'NIL' gefÅllt, so
         *  kann die Åbergebene GEM-Referenz fÅr entsprechende Aufrufe
         *  (AES bzw. VDI) nicht benutzt werden.
         *)

PROCEDURE VDIHandle (device: DeviceHandle): INTEGER;

        (*  Liefert die zu einem GerÑt gehîrende VDI-GerÑtekennung.
         *)


                        (*  Aufrufroutinen  *)
                        (*  ==============  *)

PROCEDURE CallVDI (ptrpb: PtrVDIPB);

        (*  Ruft das VDI auf.
         *
         *  'ptrpb' spezifiziert den zu benutzenden Parameterblock.
         *)

PROCEDURE CallAES (ptrpb: PtrAESPB);

        (*  Ruft das AES auf.
         *
         *  'ptrpb' spezifiziert den zu benutzenden Parameterblock.
         *)


END GEMBase.
