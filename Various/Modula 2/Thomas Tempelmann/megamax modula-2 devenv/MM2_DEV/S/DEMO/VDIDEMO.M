MODULE VDIDemo; (*$E MOS*)

(*
 * Dies Programm zeigt die Anwendung vom Modul 'GEMBase' zum direkten
 * Zugriff auf die VDI-Funktionen/Parameter.
 * Die hier gezeigte Anwendung, der Aufruf der Line-Funktion des VDI,
 * ist sinnlos, weil sie schon in den normalen VDI-Modulen enthalten ist.
 * Sinnvoll wird dies erst bei Zugriff auf Funktionen, die vielleicht
 * in einer spÑteren GEM-Version implementiert werden und wir unsere
 * VDI-Module noch nicht adaptiert haben. SelbstverstÑndlich mÅssen Sie
 * dann selbst Åber die benîtigten Aufrufparameter informiert sein.
 *
 * Dies Demoprogramm von Michael Seyfried erstellt und durch TT von seinem
 * AESBase/VDIBase auf GEMBase angepaût.
 *)

FROM SYSTEM IMPORT ADR;

IMPORT GEMEnv;

IMPORT GEMBase;

IMPORT Terminal;


VAR dev: GEMEnv.DeviceHandle;
    gemHdl: GEMEnv.GemHandle;
    vdiHdl: INTEGER;
    ok: BOOLEAN;

PROCEDURE Line (x1, y1, x2, y2: INTEGER);
  (*
   * Implementation von Line mit Hilfe von VDIBase.
   *)
  VAR aespb: GEMBase.AESPB; vdipb: GEMBase.VDIPB;
  BEGIN
    GEMBase.GetPBs (gemHdl, vdipb, aespb);
    WITH vdipb DO
      WITH pblock^ DO
        opcode:= 6;
        sptsin:= 2;
        sptsout:= 0;
        sintin:= 0;
        sintout:= 0;
      END;
      pblock^.handle:= vdiHdl;
      pioff^[0]:= x1;
      pioff^[1]:= y1;
      pioff^[2]:= x2;
      pioff^[3]:= y2;
    END;
    GEMBase.CallVDI (ADR (vdipb));
  END Line;

BEGIN
  (* Beim GEM anmelden *)
  GEMEnv.InitGem (GEMEnv.RC, dev, ok);
  IF NOT ok THEN HALT END;
  
  (* GEM-Handle ermitteln *)
  gemHdl:= GEMEnv.CurrGemHandle ();

  (* INTEGER-Wert des VDI-Handle ermitteln *)
  vdiHdl:= GEMBase.VDIHandle (dev);

  (* Linie zeichnen *)
  Line (0, 0, 639, 399);
END VDIDemo.
