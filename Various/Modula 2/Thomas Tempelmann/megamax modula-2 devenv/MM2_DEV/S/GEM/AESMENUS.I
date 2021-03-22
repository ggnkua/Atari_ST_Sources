IMPLEMENTATION MODULE AESMenus;
(*$L-, N+, Y+*)


(*  MEGAMAX MODULA 2 GEM-Library :  Die AES Menufunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.3     V#0022
 *)
 
(*  05.11.87    | šbernahme von 'GEMBase'
 *  ???????? TT | REF-Parm.
 *  02.04.90    | Anpassung auf public arrays
 *  22.05.93    | Anpassung MenuBar f. MultiTOS
 *)


FROM    SYSTEM          IMPORT ASSEMBLER;

FROM    GEMGlobals      IMPORT PtrObjTree, PtrMaxStr;

IMPORT  GEMShare;

(*$I GEMOPS.ICL *)


PROCEDURE MenuBar(tree:PtrObjTree;show:BOOLEAN);

BEGIN
  ASSEMBLER
    (* wenn wir das machen, wird die menubar nie sichtbar unter multitos:
                
                MOVE.L      our_cb,A1
                CMPI.W      #-1,cb.GLOBAL.ap_count(A1)      ; MultiTOS?
                BNE         noMulti
                
                (*
                 * Bei MultiTOS Funktion nur ausfhren, wenn Menubar sichtbar ist.
                 *)
                MOVE.L      pubs,A0
                MOVE.W      #-1,pubArrays.aINTIN(A0)
                MOVE.W      #MENU_BAR,(A3)+
                JSR         aes_if                  ; ap_id der akt. Menubar ermitteln
                MOVE.L      pubs,A0
                MOVE.W      pubArrays.aINTOUT(A0),D0
                MOVE.L      our_cb,A1
                CMP.W       cb.GLOBAL.ap_id(A1),D0  ; unsere Menubar?
                BNE         noMbar
    *)
    
  noMulti:
    MOVE.L      pubs,A0
    MOVE.W      -(A3),pubArrays.aINTIN(A0)
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.W      #MENU_BAR,(A3)+
    JSR         aes_if
    (*
      Result ignorieren, da unter MultiTOS evtl. Fehler gemeldet wird, wenn
      noch eine fremde menubar aktiv (z.B. nach Rckkehr von gestartetem
      Prg in der Shell):
                JSR         testINTOUT0
     *)
  noMbar:
  END;
END MenuBar;

PROCEDURE CheckItem(tree:PtrObjTree;item:CARDINAL;check:BOOLEAN);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.aINTIN(A0)
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.W      #MENU_ICHECK,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END CheckItem;

PROCEDURE EnableItem(tree:PtrObjTree;item:CARDINAL;enable:BOOLEAN);
        
BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.aINTIN(A0)
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.W      #MENU_IENABLE,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END EnableItem;
        
PROCEDURE NormalTitle(tree:PtrObjTree;title:CARDINAL;normal:BOOLEAN);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.aINTIN(A0)
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.W      #MENU_TNORMAL,(A3)+
    JSR         aes_if
    JSR         testINTOUT0
  END;
END NormalTitle;

PROCEDURE MenuText(tree:PtrObjTree;item:CARDINAL;REF text:ARRAY OF CHAR);

BEGIN
  ASSEMBLER
    JSR         stringIntoCFormat   ; Anf.addr des Str. auf den Stack
    MOVE.L      pubs,A0
    MOVE.W      -(A3),pubArrays.aINTIN(A0)
    MOVE.L      -(A3),pubArrays.ADDRIN(A0)
    MOVE.L      D2,pubArrays.ADDRIN+4(A0)
    MOVE.W      #MENU_TEXT,(A3)+
    JSR         aes_if
    MOVE.L      (A7),A7             ; String wieder vom Stack runterholen
    JSR         testINTOUT0
  END;
END MenuText;

PROCEDURE RegisterAcc(title:PtrMaxStr;VAR id:CARDINAL;VAR success:BOOLEAN);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        
        MOVE.L  pubs,A0
        MOVE.L  our_cb, A1
        MOVE.L  -(A3),pubArrays.ADDRIN(A0)
        MOVE.W  cb.GLOBAL.ap_id(A1),pubArrays.aINTIN(A0)
        MOVE.W  #MENU_REGISTER,(A3)+
        JSR     aes_if
        
        CLR.W   D1
        MOVE.L  pubs,A0
        MOVE.W  pubArrays.aINTOUT(A0),D0
        SMI     D1
        ADDQ.B  #1,D1
        MOVE.L  (A7)+,A1
        MOVE.W  D0,(A1)
        MOVE.L  (A7)+,A1
        MOVE.W  D1,(A1)         ;  success:=(pubs^.INTOUT[0]>=0)
  END;
END RegisterAcc;


END AESMenus.