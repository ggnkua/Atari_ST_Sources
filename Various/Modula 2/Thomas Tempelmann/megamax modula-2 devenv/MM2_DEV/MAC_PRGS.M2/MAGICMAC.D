DEFINITION MODULE MgMcCookie;

FROM SYSTEM IMPORT BYTE, ADDRESS;

TYPE Rect = RECORD
        top, left, bottom, right: CARDINAL;
END;

TYPE PixMap = RECORD
        baseAddr: ADDRESS;
        rowBytes: CARDINAL;
        bounds: Rect;
END;

TYPE PtrPixMap = POINTER TO PixMap;

TYPE MgMcCookie = RECORD
        vers: CARDINAL;
        size: CARDINAL;
        flags1: LONGCARD;
        scrnPMPtr: PtrPixMap;
        updatePalette: POINTER TO BYTE;
        modeMac: PROC;
        modeAtari: PROC;
        getBaseMode: PROC;
        getIntrCount: PROC;
        intrLock: PROC;
        intrUnlock: PROC;
        callMacContext: PROC;
        atariZeroPage: ADDRESS;
        macA5: ADDRESS;
        macAppSwitch: PROC;
        controlSwitch: PROC;
        hwAttr1: LONGCARD;
        hwAttr2: LONGCARD;
        magiC_BP: ADDRESS;
        auxOutName: ADDRESS;
        auxInName: ADDRESS;
        auxControl: PROC;
END;

END MgMcCookie.
