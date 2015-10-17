IMPLEMENTATION MODULE ObjHandler;
(*$L-, R-, J-, Y+*)

(*      Implementation der MEGAMAX MODULA II GEM Library (ObjectHandler) *
 *                                                                       *
 *      geschrieben von Manuel Chakravarty                               *
 *                                                                       *
 *      Version 2.1     V#0233          Created 30.06.1987               *)
 
(* 30.6 - 11.08 | 'CreateObjTree', Vorversion von 'VanishObjTree', Fkt zum
 *                anwÑhlen der einzelnen Objekte und setzen bzw. erfragen
 *                des mom. Treeptrs., erste Version von 'ObjTreeError', als
 *                Nachfragefkt. und die Fkt zum Setzen und erfragen der
 *                einzelnen Objektparameter, bis  auf den 'ApplBlock' fÅr
 *                Obj. vom Typ 'progDef'.
 * 12.8         | BerÅcksichtigung der Besonderheiten von 'button', 'string
 *                und 'title' Objekten. D.h. Ñndern von 'CreateSpec..' und
 *                von 'AssignTextStrings' und 'GetTextStrings', auûerdem
 *                Verbot der Benutzung aller Operationen die eine 'TedInfo'
 *                verlangen fÅr diese Objekttypen. EinfÅhrung von 'noChange
 *                bei 'SetPtrChoice' mit entspr. énderungen bei 'setString'
 * 14.8         | Erste Def. fÅr ApplBlock Behandlung
 * 18.8-19.8    | 'ApplBlock' Routinen implementieren und testen.
 * 24.8         | ComplexColor und BorderThick-Routinen fÅr 'fText' und
 *                'text' erlaubt.
 * 25.8         | 'OStateSet' als RÅckgabeparam. von 'ProgDefProc's impl.
 * 1.9          | V 0.3 -- NamensÑnderungen und Anpassung an GEMLibrary
 *                         V 0.7
 * 25.10+26.10  | 'Cur' -> 'Curr' + 'obj' in jede Routine + Sys-Anmeldung +
 *                'DeleteTree' vollstÑndig
 * 18.12        | 'BorderThickness' liefert neg. Werte nun richtig
 * 22.01.88  TT | 'setObjFlags': A3-Behandlung korrgiert
 * 17.05.88     | 'LeftSister' korrigiert
 * 08.12.88     | 'GetTextStrings' funktioniert jetzt auch fÅr Objekte, deren
 *                spec. ein Zeiger auf einen String ist.
 * 02.08.89     | 'CreateSpecification': A3-Behandlung im Fehlerfall korrigiert
 * 11.08.89     | 'AssignTextStrings': A3-Behandlung fÅr 'textOnly' korrigiert
 * ???????? TT  | REF-Parm.
 * 15.02.90     | Anpassung an Compilerversion 4.0
 * 06.10.90     | Keine Verdrehung in SETs mehr
 * ??.11.90     | Irgendeine Korrektur f. UserDef-Objs
 * 17.04.91 TT  | MakeProgDefProc: "MOVE from SR" entfernt;
 *                CreateSpecification: Bei 'spec # 0' wurde indirectFlg verkehrt
 *                ausgewertet, was immer zu Busfehlern fÅhrte.
 * 04.09.91 !MS | Modul kommt nun mit erweiterten Objekttypen zurecht.
 *)
 

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, LONGWORD, WORD,
                   TSIZE;

FROM Storage IMPORT SysAlloc, ALLOCATE, DEALLOCATE;

FROM MOSGlobals IMPORT MemArea, StringOverflow;

FROM GrafBase IMPORT Point, Rectangle, PtrBitPattern;

FROM GEMGlobals IMPORT NoObject, Root,
                       PtrObjTree, ObjType, OStateSet, OFlagSet, PtrObjSpec,
                       THorJust, PtrMaxStr, Object, TEdInfo, BitBlock,
                       IconBlock, ApplBlock, ObjState, ObjFlag, ObjSpec;

        
CONST   G_BOX           =20;    (* Objektkonstanten a'la C *)

        noErrorTrap     =6;


VAR     sizeOfObject                    :CARDINAL;     (* TSIZE(Object) *)
        sizeOfTed,sizeOfIcon,sizeOfBit,
        sizeOfAppl                      :LONGCARD;
        
        currentObjTree                  :PtrObjTree;   (* mom. Obj.Baum *)
        currentObject,endObject         :CARDINAL;     (* mom.+letztes Obj *)
        currentObjAddr                  :ADDRESS;      (* ADR(mom.Obj)  *)
        objTreeError                    :BOOLEAN;      (* Fehlerspeicher*)
        sysTree                         :BOOLEAN;
        
        voidC           : CARDINAL;
        
        
                (* Operationen auf ObjektbÑume *)
                
FORWARD setObjFlags(flags:OFlagSet);
FORWARD objectFlags():OFlagSet;
FORWARD setCurrObject(obj:CARDINAL);
FORWARD objectType():ObjType;

(* calcLastObject -- geg.: Aktueller Objektbaum                             *
 *                   ges.: Index des letzten Objects (lastObject IN flags)  *)

PROCEDURE calcLastObject():CARDINAL;

BEGIN
  ASSEMBLER
        MOVE.W  sizeOfObject,D0         ; TSIZE(Object) -> D0
        CLR.W   D1                      ; IndexzÑhler
        MOVE.L  currentObjTree,A0
        LEA     Object.flags(A0),A0     ; Addr. der Flags des Elements
        SUBA.W  D0,A0                   ; Wegen Schleifenaufbau
loop
        ADDA.W  D0,A0                   ; NÑchstes Element
        ADDQ.W  #1,D1
        MOVE.W  (A0),D2                 ; Flags -> D2
        BTST    #lastObjFlg,D2
        BEQ     loop                    ; again, if (NOT 'lastObject' IN flags)
        SUBQ.W  #1,D1                   ; Index berichtigen
        MOVE.W  D1,(A3)+                ; und zurÅckgeben
  END;
END calcLastObject;

(*  validTree -- liefert TRUE, falls KEINE Operation auf den mom. Baum aus- *
 *               gefÅhrt werden darf(z.B.: 'currentObjTree=NIL',etc.).      *
 *               Muû nicht von allen Operationen ausgerufen werden(z.B.:    *
 *               nicht von 'CreateObjTree').                                *)

PROCEDURE validTree():BOOLEAN;

BEGIN
  ASSEMBLER
        TST.L   currentObjTree
        BEQ     notValid                ; 'curObjTree=NIL' => Fehler
        MOVE.W  currentObject,D0
        CMP.W   #NoObject,D0
        BEQ     notValid                ; 'curObject=NoObject' => Fehler
        CLR     (A3)+
        RTS
notValid
        MOVE.W  #TRUE,(A3)+
  END;
END validTree;

(*  calcSpecAddr  -- Liefert die Addresse der Specifiktion des mom. Objekts *
 *                   in A0, dabei wird das Indirect-Flag beachtet.          *
 
 *                      Nur von Assemblerteilen benutzen !!                 *)
 
PROCEDURE calcSpecAddr;

BEGIN
  ASSEMBLER
        JSR     objectFlags
        MOVE.W  -(A3), D0
        ;ROR.W   #8, D0
        MOVE.L  currentObjAddr,A0
        LEA     Object.spec(A0),A0
        BTST    #indirectFlg,D0
        BEQ     ende
        MOVE.L  (A0),A0
ende
  END;
END calcSpecAddr;

PROCEDURE ObjTreeError():BOOLEAN;

BEGIN
  ASSEMBLER
        MOVE.W  objTreeError,(A3)+
        CLR.W   objTreeError
  END;
END ObjTreeError;
         
PROCEDURE CreateObjTree (noElements:CARDINAL; sys:BOOLEAN; VAR success:BOOLEAN);

VAR     elem            :LONGCARD;

(*$L+*)
BEGIN
  sysTree:=sys;
  elem:=noElements;
  
  IF elem=0L THEN currentObjTree:=NIL
  ELSE
    IF sysTree THEN SysAlloc(currentObjTree,TSIZE(Object)*elem)
    ELSE ALLOCATE(currentObjTree,TSIZE(Object)*elem) END;
    IF currentObjTree=NIL THEN success:=FALSE; RETURN END;
  END;
  
  IF currentObjTree=NIL THEN
    currentObject:=NoObject;
    endObject:=NoObject;
  ELSE
    endObject:=noElements-1;           (* Merke dir und *)
    setCurrObject(endObject);          (* markiere letztes Objekt *)
    setObjFlags(OFlagSet{lastObjFlg});
    setCurrObject(Root);
  END;
  success:=TRUE;
END CreateObjTree;
(*$L-*)
         
PROCEDURE SetCurrObjTree(tree:PtrObjTree; sys:BOOLEAN);

BEGIN
  ASSEMBLER
        MOVE.W  -(A3),sysTree
        MOVE.L  -(A3),currentObjTree
        JSR     calcLastObject          ; neues letztes Objekt
        MOVE.W  -(A3),endObject
        MOVE.W  #Root,(A3)+             ; Wurzel -> mom. Objekt
        JSR     setCurrObject
        CLR.W   objTreeError
  END;
END SetCurrObjTree;
         
PROCEDURE CurrObjTree():PtrObjTree;
        
BEGIN
  ASSEMBLER
        MOVE.L  currentObjTree,(A3)+
        CLR.W   objTreeError
  END;
END CurrObjTree;


(* deAllocA0 -- 'DEALLOCATE(A0^,0L)', falls 'A0#NIL' *)
        
PROCEDURE deAllocA0;
    
BEGIN
  ASSEMBLER
        CMPA.L  #NIL,A0
        BEQ     ende
        MOVE.L  A0,(A3)+
        CLR.L   (A3)+
        JSR     DEALLOCATE
ende
  END;
END deAllocA0;
    
(*  delObjSpec -- Lîscht die Objectspezifikation des mom. Objektes *)
   
PROCEDURE delObjSpec;

(*$L+*)
VAR   ptrPtrSpec, ptrSpec     : ADDRESS;

BEGIN
  ASSEMBLER
        JSR     objectType
        JSR     objectFlags
        MOVE.W  -(A3), D1
        ;ROR.W   #8, D1
        MOVE.W  -(A3),D0        ; Object.Type -> D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        
        MOVE.L  currentObjAddr,A0
        LEA     Object.spec(A0),A0
        
        MOVE.L  #NIL,ptrPtrSpec(A6)
        BTST    #indirectFlg,D1
        BEQ     noInd
        MOVE.L  A0,ptrPtrSpec(A6)
        MOVE.L  (A0),A0
noInd
        MOVE.L  A0,ptrSpec(A6)
        
        CMP.W   #boxObj,D0      ; mom. 'Object.type=boxObj, iBoxObj, boxChar',
        BEQ.W   noMore          ; dann springe zu 'noMore'
        CMP.W   #iBoxObj,D0
        BEQ.W   noMore
        CMP.W   #boxCharObj,D0
        BEQ.W   noMore
        CMP.W   #textObj,D0        ; mom. 'Object.type=textObj, boxTextObj, buttonObj,
        BEQ     deAllocTed      ;       fText, fBoxText',
        CMP.W   #boxTextObj,D0     ; dann springe zu 'deAllocTed'
        BEQ     deAllocTed
        CMP.W   #buttonObj,D0
        BEQ.W   deAllocStr
        CMP.W   #stringObj,D0
        BEQ.W   deAllocStr
        CMP.W   #fTextObj,D0
        BEQ     deAllocTed
        CMP.W   #fBoxTextObj,D0
        BEQ     deAllocTed
        CMP.W   #titleObj,D0
        BEQ.W   deAllocStr
        CMP.W   #imageObj,D0       ; type=imageObj
        BEQ     deAllocBit
        CMP.W   #progDefObj,D0     ; type=progDefObj
        BEQ     deAllocAppl
        CMP.W   #iconObj,D0        ; type=iconObj
        BEQ     deAllocIcon
        
        MOVE.W  #TRUE,objTreeError
        BRA.W   ende            ; sollte nie vorkommen
        
noMore
        CMPA.L  #NIL,A0
        BEQ     noClr
        CLR.L   (A0)
noClr
        BRA     noSpec
        
deAllocTed
        CMPA.L  #NIL,A0
        BEQ     noSpec
        LEA     TEdInfo.textPtr(A0),A0
        JSR     deAllocA0
        MOVE.L  ptrSpec(A6),A0
        LEA     TEdInfo.tmpltPtr(A0),A0
        JSR     deAllocA0
        MOVE.L  ptrSpec(A6),A0
        LEA     TEdInfo.validPtr(A0),A0
        JSR     deAllocA0
        BRA     deAlloc
        
deAllocBit
        CMPA.L  #NIL,A0
        BEQ     noSpec
        LEA     BitBlock.data(A0),A0
        JSR     deAllocA0
        BRA     deAlloc
        
deAllocAppl
        BRA     deAlloc
  
deAllocIcon
        CMPA.L  #NIL,A0
        BEQ     noSpec
        LEA     IconBlock.mask(A0),A0
        JSR     deAllocA0
        MOVE.L  ptrSpec(A6),A0
        LEA     IconBlock.data(A0),A0
        JSR     deAllocA0
        BRA     deAlloc
        
deAllocStr
        JSR     deAllocA0
        BRA     noSpec
  
deAlloc
        MOVE.L  ptrSpec(A6),A0
        JSR     deAllocA0
noSpec
        MOVE.L  ptrPtrSpec(A6),A0
        JSR     deAllocA0
        
ende
  END;
END delObjSpec;
(*$L=*)
  
PROCEDURE DeleteObjTree;

BEGIN
  ASSEMBLER
        MOVE.L  D4,-(A7)
        MOVE.W  #FALSE,objTreeError
        
        MOVE.L  currentObjTree,A0
        CMPA.L  #NIL,A0
        BEQ     noDealloc
        
        MOVE.W  endObject,D4            ; dealloc. all objects
loop
        MOVE.W  D4,(A3)+
        JSR     setCurrObject
        JSR     delObjSpec
        DBF     D4,loop
        
        MOVE.L  currentObjTree,(A3)+
        CLR.L   (A3)+
        JSR     DEALLOCATE
        MOVE.L  #NIL,currentObjTree
noDealloc
        MOVE.W  #NoObject,D0
        MOVE.W  D0,currentObject
        MOVE.W  D0,endObject
        MOVE.L  #NIL,currentObjAddr
        CLR.W   objTreeError
        
        MOVE.L  (A7)+,D4
  END;
END DeleteObjTree;


PROCEDURE setCurrObject(obj:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.W  -(A3),D0
        TST.L   currentObjTree
        BEQ     err                     ; 'CurrObjTree=NIL' => Fehler
        CMP.W   endObject,D0
        BLS     cont                    ; springe falls 'obj<=endObject'
err
        MOVE.W  #TRUE,objTreeError      ; Fehler !
        RTS
cont
        MOVE.W  D0,currentObject
        MULU    sizeOfObject,D0         ; Berechne Anfangsaddresse des
        MOVE.L  currentObjTree,A0       ; momentanen Objekts
        ADDA.L  D0,A0
        MOVE.L  A0,currentObjAddr       ; -> 'currentObjAddr'
        CLR.W   objTreeError
  END;
END setCurrObject;
         
PROCEDURE currObject():CARDINAL;
        
BEGIN
  ASSEMBLER
        MOVE.W  currentObject,(A3)+
        CLR.W   objTreeError
  END;
END currObject;
        
PROCEDURE LastObject():CARDINAL;

BEGIN
  ASSEMBLER
        MOVE.W  endObject,(A3)+
        CLR.W   objTreeError
  END;
END LastObject;
         
         
PROCEDURE SetObjType(obj:CARDINAL; type:ObjType);
        
BEGIN
  ASSEMBLER
        MOVE.W  -4(A3),(A3)+
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.W  -(A3),D0
        ADD.W   #G_BOX,D0
        MOVE.W  D0,Object.type(A0)
        BRA     ende
err
        SUBQ.L  #2,A3
ende
        SUBQ.L  #2,A3
  END;
END SetObjType;
        
PROCEDURE objectType():ObjType;

BEGIN
  ASSEMBLER
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.W  Object.type(A0),D0
        SUB.W   #G_BOX,D0               ; conversion
        MOVE.W  D0,(A3)+
        BRA     ende
err
        CLR.W   (A3)+
ende
  END;
END objectType;
         
PROCEDURE ObjectType(obj:CARDINAL):ObjType;
        
BEGIN
  ASSEMBLER
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        JSR     objectType
        BRA     ende
err
        CLR.W   (A3)+
ende
  END;
END ObjectType;
         
PROCEDURE setObjFlags(flags:OFlagSet);

BEGIN
  ASSEMBLER
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.W  -(A3),D0
        ;ROR.W   #8,D0
        MOVE.W  D0,Object.flags(A0)
        RTS
err
        SUBQ.L  #2,A3
  END;
END setObjFlags;

PROCEDURE SetObjFlags(obj:CARDINAL; flags:OFlagSet);

BEGIN
  ASSEMBLER
        MOVE.W  -4(A3),(A3)+
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     setObjFlags
        BRA     ende
err
        SUBQ.L  #2,A3
ende
        SUBQ.L  #2,A3
  END;
END SetObjFlags;
        
PROCEDURE objectFlags():OFlagSet;

BEGIN
  ASSEMBLER
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.W  Object.flags(A0), D0
        ;ROR.W   #8, D0
        MOVE.W  D0, (A3)+
        RTS
err
        CLR.W   (A3)+
  END
END objectFlags;

PROCEDURE ObjectFlags(obj:CARDINAL):OFlagSet;
        
BEGIN
  ASSEMBLER
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        JMP     objectFlags
err
        CLR.W   (A3)+
  END;
END ObjectFlags;
        
PROCEDURE SetObjState(obj:CARDINAL; state:OStateSet);
        
BEGIN
  ASSEMBLER
        MOVE.W  -4(A3),(A3)+
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.W  -(A3), Object.state(A0)
        BRA     ende
err
        SUBQ.L  #2,A3
ende
        SUBQ.L  #2,A3
  END;
END SetObjState;
        
PROCEDURE objectState():OStateSet;

BEGIN
  ASSEMBLER
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.W  Object.state(A0), (A3)+
        BRA     ende
err
        CLR.W   (A3)+
ende
  END;
END objectState;

PROCEDURE ObjectState(obj:CARDINAL):OStateSet;
        
BEGIN
  ASSEMBLER
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        JSR     objectState
        BRA     ende
err
        CLR.W   (A3)+
ende
  END;
END ObjectState;
        
PROCEDURE SetObjSpace(obj:CARDINAL; space:Rectangle);

BEGIN
  ASSEMBLER
        MOVE.W  -10(A3),(A3)+
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.L  -(A3),Object.space+4(A0)        ; speichere w,h
        MOVE.L  -(A3),Object.space(A0)          ; speichere x,y
        BRA     ende
err
        SUBQ.L  #8,A3
ende
        SUBQ.L  #2,A3
  END;
END SetObjSpace;
        
PROCEDURE ObjectSpace(obj:CARDINAL):Rectangle;

BEGIN
  ASSEMBLER
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.L  Object.space(A0),(A3)+          ; hole x,y
        MOVE.L  Object.space+4(A0),(A3)+        ; hole w,h
        BRA     ende
err
        CLR.L   (A3)+
        CLR.L   (A3)+
ende
  END;
END ObjectSpace;
        
PROCEDURE SetObjRelatives(obj:CARDINAL; next,head,tail:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.W  -8(A3),(A3)+
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.L  -(A3),Object.head(A0)   ; speichere 'head' und 'tail'
        MOVE.W  -(A3),Object.next(A0)   ; speichere 'next'
        BRA     ende
err
        SUBQ.L  #6,A3                   ; Param. vom Stack schmeiûen
ende
        SUBQ.L  #2,A3
  END;
END SetObjRelatives;
         
PROCEDURE GetObjRelatives(obj:CARDINAL; VAR next,head,tail:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.W  -14(A3),(A3)+
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        MOVE.L  currentObjAddr,A0
        MOVE.L  -(A3),A1
        MOVE.W  Object.tail(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  Object.head(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  Object.next(A0),(A1)
        BRA     ende
err
        SUBA.W  #12,A3                  ; A3-Stack korrigieren
ende
        SUBQ.L  #2,A3
  END;
END GetObjRelatives;
        
PROCEDURE Parent(obj:CARDINAL):CARDINAL;

BEGIN
  ASSEMBLER
        MOVE.W  -2(A3),(A3)+            ; 'obj' verdoppeln
        JSR     setCurrObject
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        
        MOVE.W  -2(A3),D0               ; Init D0 mit 'obj'
        MOVE.L  currentObjAddr,A0       ; Init A0
loop
        MOVE.W  D0,D1
        MOVE.W  Object.next(A0),D0
        CMP.W   #NoObject,D0
        BNE     cont                    ; springe, falls 'next#NoObject'
err
        ; 'obj' ist immer noch auf dem A3-Stack
        MOVE.W  #TRUE,objTreeError
        BRA     ende
        
cont
        MOVE.W  D0,(A3)+
        MOVE.W  D0,-(A7)                ; D0 retten
        MOVE.W  D1,-(A7)                ; D1 retten
        JSR     setCurrObject           ; SetCurrObject(next)
        MOVE.W  (A7)+,D1                ; D1 wiederherstellen
        MOVE.W  (A7)+,D0                ; D0 wiederherstellen
        TST.W   objTreeError
        BNE     err                     ; springe, falls 'next' nicht im Baum
        MOVE.L  currentObjAddr,A0
        CMP.W   Object.tail(A0),D1
        BNE     loop                    ; springe, falls noch nicht parent
        
        TST.W   -(A3)                   ; A3-Stack korrigieren
        MOVE.W  D0,(A3)+
ende
  END;
END Parent;
         
PROCEDURE LeftSister(obj:CARDINAL):CARDINAL;

BEGIN
  ASSEMBLER
        MOVE.L  D3,-(A7)
        JSR     setCurrObject
        TST.W   objTreeError
        BNE.W   err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE.W   err
        
        JSR     currObject
        MOVE.W  -2(A3),D3               ; 'obj' -> D3
        JSR     Parent                  ; Suche parent
        TST.W   objTreeError
        BNE     err
        
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err                     ; jump, if parent not avaible
        
        JSR     currObject
        LEA     voidC,A0
        MOVE.L  A0,(A3)+
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        MOVE.L  A0,(A3)+
        JSR     GetObjRelatives
        MOVE.W  (A7)+,D0
        TST.W   objTreeError
        BNE     err                     ; springe, falls tail nicht vorhanden
        
        MOVE.W  D0,(A3)+
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err                     ; springe, falls tail nicht vorhanden
loop
        MOVE.L  currentObjAddr,A0
        CMP.W   Object.next(A0),D3
        BEQ     cont                    ; jump, if right of found Obj='obj'
        JSR     currObject
        JSR     RightSister             ; to right sister
        MOVE.W  -(A3),D0
        TST.W   objTreeError
        BNE     err
        MOVE.W  D0,(A3)+
        JSR     setCurrObject
        TST.W   objTreeError
        BEQ     loop                    ; jump, if no error
err
        MOVE.W  D3,(A3)+
        MOVE.W  #TRUE,objTreeError
        BRA     ende
cont
        JSR     currObject
ende
        MOVE.L  (A7)+,D3
  END;
END LeftSister;
         
PROCEDURE RightSister(obj:CARDINAL):CARDINAL;

BEGIN
  ASSEMBLER
        JSR     setCurrObject
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        
        JSR     currObject
        MOVE.W  -(A3),D0                ; mom. Objekt -> D0
        MOVE.L  currentObjAddr,A0
        MOVE.W  Object.next(A0),(A3)+
        MOVE.W  D0,-(A7)
        JSR     setCurrObject            ; SetCurrObject(next)
        MOVE.W  (A7)+,D0
        TST.W   objTreeError
        BNE     err                     ; Fehler, falls 'next' nicht im Baum
        
        MOVE.L  currentObjAddr,A0
        CMP.W   Object.tail(A0),D0
        BNE     cont                    ; springe, falls 'next'#parent
err
        MOVE.W  D0,(A3)+
        MOVE.W  #TRUE,objTreeError
        BRA     ende
cont
        JSR     currObject              ; RETURN CurrObject()
ende
  END;
END RightSister;
         
PROCEDURE CreateSpecification(obj:CARDINAL; spec:PtrObjSpec);

(*$L+*)
VAR     addr    : ADDRESS;

BEGIN
  ASSEMBLER
        ;  D3 ~ momentaner Object.type
        ;  A4 ~ 'spec'
        
        MOVEM.L D3/A4,-(A7)     ; rette D3 und A4
        MOVE.L  spec(A6),A4     ; 'spec' -> A4
        MOVE.W  obj(A6),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE.W   ende
        JSR     objectType      ; hole Type in D3
        MOVE.W  -(A3),D3
        ANDI.W  #$00FF, D3      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #titleObj,D3
        BHI.W   err
        JSR     objectFlags     ; hole Flags des mom. Obj. -> D0
        MOVE.W  -(A3), D0
        ;ROR.W   #8, D0
        MOVE.L  A4,D1
        BNE.W   setIt           ; springe, falls 'spec' einen Wert hat
        BTST    #indirectFlg,D0
        BNE     crtIndirect     ; springe, falls 'indirectFlg' gesetzt
        MOVE.L  currentObjAddr,A0       ; fÅlle direkt in mom. 'Object.spec'
        LEA     Object.spec(A0),A0
        BRA     fillSpec
crtIndirect
        LEA     addr(A6),A0
        MOVE.L  A0,(A3)+
        MOVE.L  #4,(A3)+
        
        TST.W   sysTree
        BNE     allocSys1
        JSR     ALLOCATE        ; ALLOCATE(zws,4L), alloc. ein ObjSpec
        BRA     endAlloc1
allocSys1
        JSR     SysAlloc
endAlloc1

        LEA     addr(A6),A0
        MOVE.L  (A0),D0
        BEQ.W   err             ; Kein Speicher => Fehler
        MOVE.L  D0,A0
        MOVE.L  currentObjAddr,A1
        MOVE.L  A0,Object.spec(A1)
fillSpec                ; A0 ~ Zeiger auf zu bearbeitenden ObjSpec
        CMP.W   #boxObj,D3         ; mom. 'Object.type=boxObj, iBoxObj, boxCharObj',
        BEQ.W   noMore          ; dann springe zu 'noMore'
        CMP.W   #iBoxObj,D3
        BEQ.W   noMore
        CMP.W   #boxCharObj,D3
        BEQ.W   noMore
        LEA     addr(A6),A1     ; Weil ALLOCATE VAR-Param. verlangt
        MOVE.L  A1,(A3)+
        CMP.W   #textObj,D3        ; mom. 'Object.type=textObj, boxTextObj, buttonObj,
        BEQ     allocTed        ;       stringObj, fTextObj, fBoxTextObj, titleObj',
        CMP.W   #boxTextObj,D3     ; dann springe zu 'allocTed'
        BEQ     allocTed
        CMP.W   #buttonObj,D3
        BEQ     noMore
        CMP.W   #stringObj,D3
        BEQ     noMore
        CMP.W   #fTextObj,D3
        BEQ     allocTed
        CMP.W   #fBoxTextObj,D3
        BEQ     allocTed
        CMP.W   #titleObj,D3
        BEQ     noMore
        CMP.W   #imageObj,D3       ; type=imageObj
        BEQ     allocBit
        CMP.W   #progDefObj,D3     ; type=progDefObj
        BEQ     allocAppl
        CMP.W   #iconObj,D3        ; type=iconObj
        BEQ     allocIcon
        SUBQ.L  #2, A3
        BRA     err             ; sollte nie vorkommen
allocIcon
        MOVE.L  sizeOfIcon,(A3)+
        BRA     alloc
allocAppl
        MOVE.L  sizeOfAppl,(A3)+
        BRA     alloc
allocBit
        MOVE.L  sizeOfBit,(A3)+
        BRA     alloc
allocTed                        ; allociere 'TEdInfo'
        MOVE.L  sizeOfTed,(A3)+
alloc
        MOVE.L  A0,-(A7)
        
        TST.W   sysTree
        BNE     allocSys2
        JSR     ALLOCATE        ; ALLOCATE(zws,TSIZE(...))
        BRA     endAlloc2
allocSys2
        JSR     SysAlloc
endAlloc2

        MOVE.L  (A7)+,A0
        LEA     addr(A6),A1
        MOVE.L  (A1),A1
        BEQ     err             ; Kein Speicher => Fehler
        MOVE.L  A1,(A0)         ; -> ObjSpec
        BRA     ende
noMore                          ; nichts mehr zu allocieren
        CLR.L   (A0)
        BRA     ende
setIt                           ;       Setze 'Object.spec' entspr. A1
        BTST    #indirectFlg,D0
        BEQ     noSetIndirect   ; springe, falls 'indirectFlg' gelîscht
        MOVE.L  (A4),A4         ; 'spec' dereferenzieren
noSetIndirect
        MOVE.L  currentObjAddr,A1
        MOVE.L  A4,Object.spec(A1)      ; 'spec' -> mom. 'Object.spec'
        BRA     ende
        
err
        MOVE.W  #TRUE,objTreeError
ende
        MOVEM.L (A7)+,D3/A4     ; stelle D3 und A4 wieder her
  END;
END CreateSpecification;
(*$L=*)
         
PROCEDURE SetBoxChar(obj:CARDINAL; ch:CHAR);

BEGIN
  ASSEMBLER
        MOVE.W  -(A3),-(A7)
        JSR     setCurrObject
        MOVE.W  (A7)+,(A3)+
        TST.W   objTreeError
        BNE     raiseErr
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #boxCharObj,D0
        BNE     raiseErr        ; Objecttyp#boxCharObj => Fehler
        JSR     calcSpecAddr    ; Liefert Addr. ObjSpec in A0
        TST.B   -(A3)
        MOVE.B  -(A3),ObjSpec.letter(A0)
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
        SUBQ.L  #2,A3
ende
  END;
END SetBoxChar;
         
PROCEDURE BoxChar(obj:CARDINAL):CHAR;

BEGIN
  ASSEMBLER
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #boxCharObj,D0
        BNE     raiseErr        ; Objecttyp#boxCharObj => Fehler
        JSR     calcSpecAddr    ; Liefert Addr. von ObjSpec in A0
        CLR.W   D0
        MOVE.B  ObjSpec.letter(A0),(A3)+
        ADDQ.L  #1,A3
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
        CLR.W   (A3)+
ende
  END;
END BoxChar;
        
PROCEDURE SetBorderThickness(obj:CARDINAL; thick:SignedByte);

BEGIN
  ASSEMBLER
        MOVE.L  D3,-(A7)
        
        MOVE.W  -(A3),D3                ; 'thick' -> D3
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr            ; liefert Addr. der ObjSpec in A0
        MOVE.W  -(A3),D0                ; Ergebnis von objectType
        ANDI.W  #$00FF, D0              ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #boxObj,D0
        BEQ     setBox
        CMP.W   #iBoxObj,D0
        BEQ     setBox
        CMP.W   #boxCharObj,D0
        BEQ     setBox
        CMP.W   #textObj,D0
        BEQ     setText
        CMP.W   #fTextObj,D0
        BEQ     setText
        CMP.W   #boxTextObj,D0
        BEQ     setText
        CMP.W   #fBoxTextObj,D0
        BEQ     setText
        MOVE.W  #TRUE,objTreeError      ; Unerlaubter Typ => Fehler
        BRA     ende
setBox
        MOVE.B  D3,ObjSpec.thickness(A0)
        BRA     ende
setText
        MOVE.L  (A0),A0
        AND.W   #$FF,D3
        MOVE.W  D3,TEdInfo.thickness(A0)
err
ende
        MOVE.L  (A7)+,D3
  END;
END SetBorderThickness;
         
PROCEDURE BorderThickness(obj:CARDINAL):SignedByte;

BEGIN
  ASSEMBLER
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr            ; liefert Addr. der ObjSpec in A0
        MOVE.W  -(A3),D0                ; Ergebnis von objectType
        ANDI.W  #$00FF, D0              ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #boxObj,D0
        BEQ     setBox
        CMP.W   #iBoxObj,D0
        BEQ     setBox
        CMP.W   #boxCharObj,D0
        BEQ     setBox
        CMP.W   #textObj,D0
        BEQ     setText
        CMP.W   #fTextObj,D0
        BEQ     setText
        CMP.W   #boxTextObj,D0
        BEQ     setText
        CMP.W   #fBoxTextObj,D0
        BEQ     setText
        MOVE.W  #TRUE,objTreeError      ; Unerlaubter Typ => Fehler
        BRA     err
setBox
        MOVE.B  ObjSpec.thickness(A0),D1
        EXT.W   D1                      ; Vorzeichen erweitern
        MOVE.W  D1,(A3)+
        BRA     ende
setText
        MOVE.L  (A0),A0                 ; Hole Inhalt vom ObjSpec in A0
        MOVE.B  TEdInfo.thickness+1(A0),D1 ; Nur Lowbyte verwenden
        EXT.W   D1                      ; Vorzeichen erweitern
        MOVE.W  D1,(A3)+
        BRA     ende
err
        CLR.W   (A3)+
ende
  END;
END BorderThickness;

PROCEDURE SetComplexColor(obj:CARDINAL;
                          borderCol,textCol,fillCol,fillDensity:CARDINAL;
                          opaque:BOOLEAN);
                          
BEGIN
  ASSEMBLER
        MOVE.L  D3,-(A7)
        
        MOVE.W  -(A3),D1        ; Bitstruktur: aaaabbbbcdddeeee
        AND.W   #1,D1           ;  aaaa - Randfarbe
        LSL.W   #3,D1           ;  bbbb - Textfarbe
        MOVE.W  -(A3),D2        ;  c    - Schreibmodus
        AND.W   #7,D2           ;  ddd  - FÅlldichte
        OR.W    D2,D1           ;  eeee - FÅllfarbe
        LSL.W   #4,D1
        MOVE.W  -(A3),D2
        AND.W   #$F,D2
        OR.W    D2,D1
        MOVE.W  -(A3),D2
        AND.W   #$F,D2
        LSL.W   #8,D2
        OR.W    D2,D1
        MOVE.W  -(A3),D2
        AND.W   #$F,D2
        LSL.W   #8,D2
        LSL.W   #4,D2
        OR.W    D2,D1
        MOVE.W  D1,D3           ; Farbwort -> D3
        
        JSR     setCurrObject
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        
        JSR     objectType
        JSR     calcSpecAddr
        MOVE.W  -(A3),D0        ; Object.type -> D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #boxObj,D0
        BEQ     setBox
        CMP.W   #iBoxObj,D0
        BEQ     setBox
        CMP.W   #boxCharObj,D0
        BEQ     setBox
        CMP.W   #textObj,D0
        BEQ     setText
        CMP.W   #fTextObj,D0
        BEQ     setText
        CMP.W   #boxTextObj,D0
        BEQ     setText
        CMP.W   #fBoxTextObj,D0
        BEQ     setText
        MOVE.W  #TRUE,objTreeError      ; Unerlaubter Typ => Fehler
        BRA     ende
setBox
        MOVE.W  D1,ObjSpec.color(A0)
        BRA     ende
setText
        MOVE.L  (A0),A0
        MOVE.W  D1,TEdInfo.color(A0)
err
ende
        MOVE.L  (A7)+,D3
  END;
END SetComplexColor;
         
PROCEDURE GetComplexColor(obj:CARDINAL;
                          VAR borderCol,textCol,fillCol,fillDensity:CARDINAL;
                          VAR opaque:BOOLEAN);
                          
BEGIN
  ASSEMBLER
        MOVE.W  -22(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE.W   err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE.W   err
        JSR     objectType
        JSR     calcSpecAddr            ; liefert Addr. der ObjSpec in A0
        MOVE.W  -(A3),D0                ; Ergebnis von objectType
        ANDI.W  #$00FF, D0              ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #boxObj,D0
        BEQ     setBox
        CMP.W   #iBoxObj,D0
        BEQ     setBox
        CMP.W   #boxCharObj,D0
        BEQ     setBox
        CMP.W   #textObj,D0
        BEQ     setText
        CMP.W   #fTextObj,D0
        BEQ     setText
        CMP.W   #boxTextObj,D0
        BEQ     setText
        CMP.W   #fBoxTextObj,D0
        BEQ     setText
        MOVE.W  #TRUE,objTreeError      ; Unerlaubter Typ => Fehler
        BRA     err
setBox
        MOVE.W  ObjSpec.color(A0),D1
        BRA     encrypt
setText
        MOVE.L  (A0),A0                 ; Hole Inhalt vom ObjSpec in A0
        MOVE.W  TEdInfo.color(A0),D1
encrypt
        CLR.W   D0
        BTST    #7,D1
        SEQ     D0
        ADDQ.B  #1,D0
        MOVE.L  -(A3),A0
        MOVE.W  D0,(A0)                 ; speichere 'opaque'
        MOVE.W  D1,D0
        LSR.W   #4,D0
        AND.W   #$7,D0
        MOVE.L  -(A3),A0
        MOVE.W  D0,(A0)                 ; speichere 'fillDensity'
        MOVE.W  D1,D0
        AND.W   #$F,D0
        MOVE.L  -(A3),A0
        MOVE.W  D0,(A0)                 ; speichere 'fillCol'
        LSR.W   #8,D1
        MOVE.W  D1,D0
        AND.W   #$F,D0
        MOVE.L  -(A3),A0
        MOVE.W  D0,(A0)                 ; speichere 'textCol'
        LSR.W   #4,D1
        MOVE.L  -(A3),A0
        MOVE.W  D1,(A0)                 ; speichere 'borderCol'
        BRA     ende
err
        SUBA.W  #20,A3
ende
        SUBQ.L  #2,A3
  END;
END GetComplexColor;

PROCEDURE SetIconColor(obj:CARDINAL; foreGround,backGround:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.W  -6(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #iconObj,D0
        BNE     raiseErr
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.W  -(A3),D0
        AND.B   #$F,D0
        MOVE.W  -(A3),D1
        LSL.B   #4,D1
        OR.B    D1,D0
        MOVE.L  (A0),A0         ; Hole Zeiger auf IconBlock
        MOVE.B  D0,IconBlock.color(A0)
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
        SUBQ.L  #4,A3
ende
        SUBQ.L  #2,A3
  END;
END SetIconColor;
         
PROCEDURE GetIconColor(obj:CARDINAL; VAR foreGround,backGround:CARDINAL);
        
BEGIN
  ASSEMBLER
        MOVE.W  -10(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #iconObj,D0
        BNE     raiseErr
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.L  (A0),A0         ; Hole Zeiger auf IconBlock
        MOVE.B  IconBlock.color(A0),D0
        MOVE.W  D0,D1
        AND.W   #$F,D1
        MOVE.L  -(A3),A0        ; speichere Hintergrund
        MOVE.W  D1,(A0)
        LSR.W   #4,D0
        AND.W   #$F,D0
        MOVE.L  -(A3),A0        ; speichere Vordergrund
        MOVE.W  D0,(A0)
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
        SUBQ.L  #8,A3
ende
        SUBQ.L  #2,A3
  END;
END GetIconColor;
        
PROCEDURE SetImageColor(obj:CARDINAL; color:CARDINAL);
        
BEGIN
  ASSEMBLER
        MOVE.L  D3,-(A7)
        
        MOVE.W  -(A3),D3
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #imageObj,D0
        BNE     raiseErr
        JSR     calcSpecAddr    ; Ergebnis in A0
        AND.B   #$F,D3
        MOVE.L  (A0),A0         ; Hole Zeiger auf IconBlock
        MOVE.W  D3,BitBlock.color(A0)
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
ende
        MOVE.L  (A7)+,D3
  END;
END SetImageColor;
         
PROCEDURE GetImageColor(obj:CARDINAL; VAR color:CARDINAL);
        
BEGIN
  ASSEMBLER
        MOVE.L  A4,-(A7)
        
        MOVE.L  -(A3),A4
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #imageObj,D0
        BNE     raiseErr
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.L  (A0),A0         ; Hole Zeiger auf IconBlock
        MOVE.W  BitBlock.color(A0),D0
        AND.B   #$F,D0
        MOVE.W  D0,(A4)
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
        SUBQ.L  #4,A3
ende
        MOVE.L  (A7)+,A4
  END;
END GetImageColor;
        
PROCEDURE SetTextForm(obj:CARDINAL; font:CARDINAL;just:THorJust);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        JSR     setCurrObject   ; setCurrObject(obj)
        MOVE.L  (A7)+,(A3)+
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE    -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.W  -(A3),D0        ; 'Object.type' -> D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #textObj,D0
        BEQ     typeOk
        CMP.W   #boxTextObj,D0
        BEQ     typeOk
        CMP.W   #fTextObj,D0
        BEQ     typeOk
        CMP.W   #fBoxTextObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError      ; Falscher Objecttyp => Fehler
        BRA     err
typeOk
        MOVE.W  -(A3),D1        ; 'just' -> D1
        BEQ     cont
        CMP.W   #centerJust,D1
        BNE     isRight
        MOVEQ   #2,D1
        BRA     cont
isRight
        MOVEQ   #1,D1
cont
        MOVE.W  -(A3),D2        ; 'font' -> D2
        MOVE.L  (A0),A0
        MOVE.W  D1,TEdInfo.just(A0)
        MOVE.W  D2,TEdInfo.font(A0)
        BRA     ende
err
        SUBQ.L  #4,A3
ende
  END;
END SetTextForm;
         
PROCEDURE GetTextForm(obj:CARDINAL; VAR font:CARDINAL;VAR just:THorJust);
        
BEGIN
  ASSEMBLER
        MOVE.W  -10(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE    -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.W  -(A3),D0        ; 'Object.type' -> D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #textObj,D0
        BEQ     typeOk
        CMP.W   #boxTextObj,D0
        BEQ     typeOk
        CMP.W   #fTextObj,D0
        BEQ     typeOk
        CMP.W   #fBoxTextObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError      ; Falscher Objecttyp => Fehler
        BRA     err
typeOk
        MOVE.L  (A0),A0
        MOVE.W  TEdInfo.just(A0),D1
        BEQ     cont
        CMP.W   #2,D1
        BNE     isRight
        MOVEQ   #centerJust,D1
        BRA     cont
isRight
        MOVEQ   #rightJust,D1
cont
        MOVE.L  -(A3),A1
        MOVE.W  D1,(A1)
        MOVE.W  TEdInfo.font(A0),D1
        MOVE.L  -(A3),A1
        MOVE.W  D1,(A1)
        BRA     ende
err
        SUBQ.L  #8,A3
ende
        SUBQ.L  #2,A3
  END;
END GetTextForm;
        
PROCEDURE SetIconForm(obj:CARDINAL;
                      charPos:Point;iconFrame,textFrame:Rectangle);

BEGIN
  ASSEMBLER
        MOVE.W  -22(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #iconObj,D0
        BNE     raiseErr
        JSR     calcSpecAddr
        MOVE.L  (A0),A0
        LEA     IconBlock.textFrame+8(A0),A0
        MOVEQ   #4,D0           ; kopiere (4+1)*4 Bytes
loop
        MOVE.L  -(A3),-(A0)
        DBF     D0,loop
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
        SUBA.W  #20,A3
ende
        SUBQ.L  #2,A3
  END;
END SetIconForm;
         
PROCEDURE GetIconForm(obj:CARDINAL;
                      VAR charPos:Point;VAR iconFrame,textFrame:Rectangle);
        
BEGIN
  ASSEMBLER
        MOVE.W  -14(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #iconObj,D0
        BNE     raiseErr
        JSR     calcSpecAddr
        MOVE.L  (A0),A0
        LEA     IconBlock.textFrame+8(A0),A0
        MOVE.L  -(A3),A1
        MOVE.L  -(A0),4(A1)
        MOVE.L  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.L  -(A0),4(A1)
        MOVE.L  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.L  -(A0),(A1)
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
        SUBA.W  #12,A3
ende
        SUBQ.L  #2,A3
  END;
END GetIconForm;
        
PROCEDURE SetImageForm(obj:CARDINAL; byteWidth,height,deltaX,deltaY:INTEGER);
        
BEGIN
  ASSEMBLER
        MOVE.W  -10(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #imageObj,D0
        BNE     raiseErr
        JSR     calcSpecAddr
        MOVE.L  (A0),A0
        MOVE.L  -(A3),BitBlock.x(A0)
        MOVE.L  -(A3),BitBlock.bytes(A0)
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
        SUBA.W  #8,A3
ende
        SUBQ.L  #2,A3
  END;
END SetImageForm;
         
PROCEDURE GetImageForm(obj:CARDINAL;
                       VAR byteWidth,height,deltaX,deltaY:INTEGER);
        
BEGIN
  ASSEMBLER
        MOVE.W  -18(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #imageObj,D0
        BNE     raiseErr
        JSR     calcSpecAddr
        MOVE.L  (A0),A0
        LEA     BitBlock.y+2(A0),A0
        MOVEQ   #3,D0           ; 3+1 Parameter kopieren
loop
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        DBF     D0,loop
        BRA     ende
raiseErr
        MOVE.W  #TRUE,objTreeError
err
        SUBA.W  #16,A3
ende
        SUBQ.L  #2,A3
  END;
END GetImageForm;

(*  setString -- geg.: Ein Wahlparameter 'choice', ein String 'str' und *
 *                     ein Zeiger auf einen String 'dest', 'minLen' ist *
 *                     die MindestlÑnge des zu alloc. Str. bei 'create' *
 *               ges.: Falls 'choice=create' wird 'dest' allociert und  *
 *                     zwar mit 'length(str)+1' Elementen, danach oder  *
 *                     wenn 'choice=setOnly' wird 'str' in 'dest^' ko-  *
 *                     piert, wobei eine #0 angehÑngt wird. Ist 'choice=*
 *                     reCreate', dann wird die alte Var. dealloc. und  *
 *                     danach bei 'create' weitergemacht. Ist 'choice=  *
 *                     noChange', so wird Åberhaupt nichts verÑndert.   *
 *                     ZurÅckgegeben wird die Anzahl der kopierten Zei- *
 *                     chen+1                                           *)

PROCEDURE setString(choice:SetPtrChoice;REF str:ARRAY OF CHAR;
                    minLen:CARDINAL;VAR dest:PtrMaxStr):CARDINAL;

BEGIN
  ASSEMBLER
        MOVE.W  D3,-(A7)
        
        MOVE.L  -(A3),A2        ; 'dest' -> A2
        MOVE.W  -(A3),D3        ; 'minLen' -> D3
        CLR.L   D1
        MOVE.W  -(A3),D1        ; 'HIGH(str)' -> D1
        MOVE.L  -(A3),A1        ; 'ADR(str)' ->A1
        MOVE.W  -(A3),D0        ; 'choice' -> D0
        CMP.W   #noChange,D0
        BNE     changeIt
        MOVE.W  D3,D1           ; noChange => Gib 'minLen' zurÅck und term.
        BRA.W   cont3
changeIt
        CMP.W   #setOnly,D0
        BEQ     setValue        ; setOnly => springe zu String kopieren
        CMP.W   #reCreate,D0
        BNE     noDeAlloc
        MOVE.L  A2,(A3)+        ; reCreate => mache weiter mit Dealloc.
        CLR.L   (A3)+
        MOVEM.L D1/D3/A1-A2,-(A7)  ; mom. Version von DEALLOCATE? zerstîrt D3
        JSR     DEALLOCATE      ; DEALLOCATE(dest,0)
        MOVEM.L (A7)+,D1/D3/A1-A2
noDeAlloc
        MOVE.W  D1,D0
        MOVE.L  A1,A0
loop
        TST.B   (A0)+
        DBEQ    D0,loop
        MOVE.L  D1,D2           ; lîsche auch high word
        SUB.W   D0,D2
        ADDQ.W  #1,D2           ; length(str)+1 -> D2
        CMP.W   D3,D2
        BCC     cont            ; jump, if 'minLen<length(str)+1'
        MOVE.W  D3,D2           ; mindestens 'minLen' alloc.
cont
        MOVE.W  D2,D3           ; merke dir wieviel Bytes alloc. wurden
        MOVE.L  A2,(A3)+
        MOVE.L  D2,(A3)+
        MOVEM.L D1/D3/A1-A2,-(A7)  ; mom. Version von ALLOCATE zerstîrt D3
        
        TST.W   sysTree
        BNE     allocSys1
        JSR     ALLOCATE        ; ALLOCATE(dest,length(str)+1)
        BRA     endAlloc1
allocSys1
        JSR     SysAlloc
endAlloc1

        MOVEM.L (A7)+,D1/D3/A1-A2
setValue
        MOVE.L  (A2),D0
        BEQ     err
        MOVE.L  D0,A2
        MOVE.W  D1,D0
loop2
        MOVE.B  (A1)+,(A2)+
        DBEQ    D0,loop2
        BEQ     cont2
        CLR.B   (A2)+           ; #0 anhÑngen
        SUBQ.W  #1,D0
cont2
        SUB.W   D0,D1
        CMP.W   D3,D1
        BCC     cont3           ; jump, if length(str)+1<minLen
        MOVE.W  D3,D1
        BRA     cont3
err
        MOVE.W  #TRUE,objTreeError
        CLR.W   D1
cont3
        MOVE.W  D1,(A3)+        ; Gib length(str)+1, aber min. 'minLen' zurÅck
        
        MOVE.W  (A7)+,D3
  END;
END setString;
        
PROCEDURE AssignTextStrings (obj        : CARDINAL;
                             textChoice : SetPtrChoice; REF textS: ARRAY OF CHAR;
                             tmpltChoice: SetPtrChoice; REF tmplt: ARRAY OF CHAR;
                             validChoice: SetPtrChoice; REF valid: ARRAY OF CHAR);

BEGIN
  ASSEMBLER
        MOVE.L  A4,-(A7)
        
        MOVE.W  -26(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE.W   err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE.W   err
        JSR     objectType
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.W  -(A3),D0        ; 'Object.type' -> D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #textObj,D0
        BEQ     typeOk
        CMP.W   #boxTextObj,D0
        BEQ     typeOk
        CMP.W   #buttonObj,D0
        BEQ     onlyText
        CMP.W   #stringObj,D0
        BEQ     onlyText
        CMP.W   #fTextObj,D0
        BEQ     typeOk
        CMP.W   #fBoxTextObj,D0
        BEQ     typeOk
        CMP.W   #titleObj,D0
        BEQ     onlyText
        MOVE.W  #TRUE,objTreeError
        BRA     err
onlyText
        TST.W   -(A3)           ; Teste, daû 'choiceValid=noChange'
        TST.L   -(A3)
        MOVE.W  -(A3),D0
        CMP.W   #noChange,D0
        BEQ     skipValid
        MOVE.W  #TRUE,objTreeError
skipValid
        TST.W   -(A3)           ; Teste, daû 'choiceTmplt=noChange'
        TST.L   -(A3)
        MOVE.W  -(A3),D0
        CMP.W   #noChange,D0
        BEQ     skipTmplt
        MOVE.W  #TRUE,objTreeError
skipTmplt
        CLR.W   (A3)+
        MOVE.L  A0,(A3)+
        JSR     setString       ; 'textS' verarbeiten
        SUBQ.L  #2,A3
        BRA     ende
typeOk
        MOVE.L  (A0),A4
        CLR.W   (A3)+
        LEA     TEdInfo.validPtr(A4),A0
        MOVE.L  A0,(A3)+
        JSR     setString   ; setString(0,validChoice,valid,ADR(TEdInfo.validP))
        MOVE.W  -(A3),D0
        BEQ     noChg
        LEA     TEdInfo.textLen(A4),A0
        MOVE.W  D0,(A0)  ; 'TEdInfo.textLen':=RÅckgabewert von 'setString'
noChg
        CLR.W   (A3)+
        LEA     TEdInfo.tmpltPtr(A4),A0
        MOVE.L  A0,(A3)+
        JSR     setString   ; setString(0,tmpltChoice,tmplt,ADR(TEdInfo.tmpltP))
        MOVE.W  -(A3),D0
        BEQ     noChg2
        LEA     TEdInfo.tmpltLen(A4),A0
        MOVE.W  D0,(A0)  ; 'TEdInfo.tmpltLen':=RÅckgabewert von 'setString'
noChg2
        CLR.W   (A3)+
        LEA     TEdInfo.textPtr(A4),A0
        MOVE.L  A0,(A3)+
        JSR     setString   ; setString(x,textChoice,textObj,ADR(TEdInfo.textPtr))
        TST.W   -(A3)
        BRA     ende
err
        SUBA.L  #24,A3
ende
        SUBQ.L  #2,A3

        MOVE.L  (A7)+,A4
  END;
END AssignTextStrings;
         
PROCEDURE LinkTextString(obj:CARDINAL; str:PtrMaxStr);

BEGIN
  ASSEMBLER
        MOVE.W  -6(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.W  -(A3),D0        ; 'Object.type' -> D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #textObj,D0
        BEQ     typeOk
        CMP.W   #boxTextObj,D0
        BEQ     typeOk
        CMP.W   #fTextObj,D0
        BEQ     typeOk
        CMP.W   #fBoxTextObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError
        BRA     err
typeOk
        MOVE.L  (A0),A0
        MOVE.L  -(A3),A1        ; ADR(str) -> A1
        MOVE.L  A1,TEdInfo.textPtr(A0)
        ;CMP.W   TEdInfo.textLen(A0),D0
        ;BCC     ende            ; jump, if HIGH(str)>=TEdInfo.textLen
        ;MOVE.W  D0,TEdInfo.textLen(A0)  ; textLen darf hîchstens HIGH(str) sein
        BRA     ende
err
        SUBQ.L  #4,A3
ende
        SUBQ.L  #2,A3
  END;
END LinkTextString;

(*  GetTextString -- Ist einer der Strings zu kurz, so tritt ein
 *                   Laufzeitfehler (STRING OVERFLOW) auf.
 *)
         
PROCEDURE GetTextStrings(obj:CARDINAL; VAR textS,tmplt,valid:ARRAY OF CHAR);
        
BEGIN
  ASSEMBLER
        MOVE.W  -20(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE.W   err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE.W   err
        JSR     objectType
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.W  -(A3),D0        ; 'Object.type' -> D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #textObj,D0
        BEQ     typeOk
        CMP.W   #boxTextObj,D0
        BEQ     typeOk
        CMP.W   #buttonObj,D0
        BEQ     onlyText
        CMP.W   #stringObj,D0
        BEQ     onlyText
        CMP.W   #fTextObj,D0
        BEQ     typeOk
        CMP.W   #fBoxTextObj,D0
        BEQ     typeOk
        CMP.W   #titleObj,D0
        BEQ     onlyText
        MOVE.W  #TRUE,objTreeError
        BRA     err
onlyText
        SUBA.L  #12,A3          ; 'valid' und 'tmplt' vom A3-Stack schmeiûen
        MOVE.L  (A0),A0         ; get spec. (ptr. to str.)
        MOVE.L  A0,-(A7)        ; 'textS' verarbeiten
        CLR.W   D0
        BRA     loop
typeOk
        MOVE.L  (A0),A0
        MOVE.L  TEdInfo.textPtr(A0),-(A7)
        MOVE.L  TEdInfo.tmpltPtr(A0),-(A7)
        MOVE.L  TEdInfo.validPtr(A0),-(A7)
        MOVEQ   #2,D0
loop
        MOVE.L  (A7)+,A0
        MOVE.W  -(A3),D1        ; HIGH(...) -> D1
        MOVE.L  -(A3),A1        ; ADR(...) -> A1
loop2
        MOVE.B  (A0)+,(A1)+
        DBEQ    D1,loop2
        BEQ     cont            ; letztes Zeichen 0C, so springe
        TST.B   (A0)+
        BEQ     cont            ; WÑre nÑchstes Zeichen 0C gewesen, so springe
        TRAP    #noErrorTrap
        DC.W    StringOverflow  ; Zielstring ist zu kurz !!
cont
        DBF     D0,loop
        BRA     ende
err
        SUBA.W  #18,A3
ende
        SUBQ.L  #2,A3
  END;
END GetTextStrings;

PROCEDURE SetStringLength(obj:CARDINAL; textLen,tmpltLen:CARDINAL);
        
BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        JSR     setCurrObject   ; setCurrObject(obj)
        MOVE.L  (A7)+,(A3)+
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.W  -(A3),D0        ; 'Object.type' -> D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #textObj,D0
        BEQ     typeOk
        CMP.W   #boxTextObj,D0
        BEQ     typeOk
        CMP.W   #fTextObj,D0
        BEQ     typeOk
        CMP.W   #fBoxTextObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError
        BRA     err
typeOk
        MOVE.L  (A0),A0
        MOVE.W  -(A3),TEdInfo.tmpltLen(A0)
        MOVE.W  -(A3),TEdInfo.textLen(A0)
        BRA     ende
err
        SUBQ.W  #4,A3
ende
  END;
END SetStringLength;

PROCEDURE GetStringLength(obj:CARDINAL; VAR textLen,tmpltLen:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.W  -10(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr    ; Ergebnis in A0
        MOVE.W  -(A3),D0        ; 'Object.type' -> D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #textObj,D0
        BEQ     typeOk
        CMP.W   #boxTextObj,D0
        BEQ     typeOk
        CMP.W   #fTextObj,D0
        BEQ     typeOk
        CMP.W   #fBoxTextObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError
        BRA     err
typeOk
        MOVE.L  (A0),A0
        MOVE.L  -(A3),A1
        MOVE.W  TEdInfo.tmpltLen(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  TEdInfo.textLen(A0),(A1)
        BRA     ende
err
        SUBQ.W  #8,A3
ende
        SUBQ.L  #2,A3
  END;
END GetStringLength;

PROCEDURE SetImagePattern(obj:CARDINAL; pattern:PtrBitPattern);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        JSR     setCurrObject   ; setCurrObject(obj)
        MOVE.L  (A7)+,(A3)+
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #imageObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError
        BRA     err
typeOk
        MOVE.L  (A0),A0
        MOVE.L  -(A3),BitBlock.data(A0)
        BRA     ende
err
        SUBQ.L  #4,A3
ende
  END;
END SetImagePattern;
         
PROCEDURE GetImagePattern(obj:CARDINAL; VAR pattern:PtrBitPattern);
        
BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        JSR     setCurrObject   ; setCurrObject(obj)
        MOVE.L  (A7)+,(A3)+
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #imageObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError
        BRA     err
typeOk
        MOVE.L  (A0),A0
        MOVE.L  -(A3),A1
        MOVE.L  BitBlock.data(A0),(A1)
        BRA     ende
err
        SUBQ.L  #4,A3
ende
  END;
END GetImagePattern;

PROCEDURE SetIconLook(obj:CARDINAL; data,mask:PtrBitPattern;choice:SetPtrChoice;
                      REF str:ARRAY OF CHAR;ch:CHAR);

BEGIN
  ASSEMBLER
        MOVE.W  -20(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #iconObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError
        BRA     err
typeOk
        MOVE.L  (A0),A0
        SUBQ.L  #1, A3
        MOVE.B  -(A3),IconBlock.oneChar(A0)
        CLR.W   (A3)+
        LEA     IconBlock.text(A0),A1
        MOVE.L  A1,(A3)+
        MOVE.L  A0,-(A7)
        JSR     setString       ; setString(choice,str,0,ADR(IconBlock.text))
        TST.W   -(A3)
        MOVE.L  (A7)+,A0
        MOVE.L  -(A3),IconBlock.mask(A0)
        MOVE.L  -(A3),IconBlock.data(A0)
        BRA     ende
err
        SUBA.W  #18,A3
ende
        SUBQ.L  #2,A3
  END;
END SetIconLook;
         
PROCEDURE GetIconLook(obj:CARDINAL;
                      VAR data,mask:PtrBitPattern;VAR str:ARRAY OF CHAR;
                      VAR ch:CHAR);

BEGIN
  ASSEMBLER
        MOVE.W  -20(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #iconObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError
        BRA     err
typeOk
        MOVE.L  (A0),A0
        MOVE.L  -(A3),A1
        MOVE.B  IconBlock.oneChar(A0),(A1)
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A1
        MOVE.L  IconBlock.text(A0),A2
loop
        MOVE.B  (A2)+,(A1)+
        DBEQ    D0,loop
        BEQ     noOverflow
        TST.B   (A2)+
        BEQ     noOverflow
        TRAP    #noErrorTrap
        DC.W    StringOverflow
noOverflow
        MOVE.L  -(A3),A1
        MOVE.L  IconBlock.mask(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.L  IconBlock.data(A0),(A1)
        BRA     ende
err
        SUBA.W  #18,A3
ende
        SUBQ.L  #2,A3
  END;
END GetIconLook;


CONST   carrierCodeLen          =8;  (* LÑnge von 'carrierCode' in Worten *)

TYPE    carrierData             =RECORD
                                   proc         :ProgDefProc;
                                   wsp          :MemArea;
                                   (*futureUse    :LONGWORD;*)
                                 END;
        ptrCarrierData          =POINTER TO carrierData;
        progDefCarrier          =RECORD
                                   code         :ARRAY[0..carrierCodeLen-1]
                                                      OF WORD;
                                   data         :carrierData;
                                 END;
                                 
VAR     regA0,regUSP,regSSP    :LONGWORD;
        regsRmd                :ARRAY[0..13] OF LONGWORD;
                                 
(*  progDefHandler -- Proc. die bei jedem Neuzeichnen eines 'progDefObj'-Obj. *
 *                    vom GEM aufgerufen wird, der Aufruf erfolgt indirekt *
 *                    Åber den zur 'progDefProc' gehîrenden Carrier.       *
 *                    Die Routine erwartet auf dem A7-Stack die RÅcksprung-*
 *                    addr. zum GEM und in A0 einen Zeiger auf das Data-   *
 *                    segment des zustÑndigen 'progDefCarrier''s.          *)
                                 
PROCEDURE progDefHandler;

BEGIN
  ASSEMBLER
        MOVEM.L D0-D7/A1-A6,regsRmd
        MOVE.L  USP,A1
        MOVE.L  A1,regUSP
        MOVE.L  A7, regSSP
        ;MOVE.L  (A7)+,D0        ; C-mÑûige ParameterÅbergabe
        ;MOVE.L  (A7)+,A1        ; Hole Zeiger auf ParamBlock in A1
        ;MOVE.L  D0,-(A7)
        MOVE.L  4(A7),A1        ; Hole Zeiger auf ParamBlock in A1
        MOVE.L  carrierData.wsp.bottom(A0),A3  ; Stackbereich einrichten
        MOVE.L  A3,A2
        ADDA.L  carrierData.wsp.length(A0),A2
        MOVE.L  A2,USP
        
        MOVE.L  (A1)+,(A3)+     ; Objektbaumaddr. kopieren
        MOVE.W  (A1)+,(A3)+     ; Objektindex und
        MOVEQ   #5,D0
loop
        MOVE.L  (A1)+,(A3)+     ; 6 Parameterlangwîrter kopieren
        DBF     D0,loop
        ANDI.W  #-1-$2000,SR    ; Wechsle in den Usermode
        MOVE.L  carrierData.proc(A0),A0
        JSR     (A0)            ; Zeichenprocedure aufrufen
        LEA     regsRmd,A0      ; RÅckgabewert der Proc C-mÑûig in D0
        CLR.L   (A0)            ; zurÅckgeben
        MOVE.W  -(A3),2(A0)
        
        ; ZurÅck in Supervisormode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6, A7
        
        MOVE.L  regSSP, A7
        MOVE.L  regUSP,A1
        MOVE.L  A1,USP
        MOVEM.L regsRmd,D0-D7/A1-A6
        MOVE.L  regA0,A0
  END;
END progDefHandler;

(*  carrierCode -- Das Codesegment eines jeden 'progDefCarrier' *)

PROCEDURE carrierCode;  (* Konstante 'carrierCodeLen' beachten *)

BEGIN
  ASSEMBLER
        MOVE.L  A0,regA0                ; rette A0
        LEA     dataStart(PC),A0        ; ADR(progDefCarrier.data) -> A0
        JMP     progDefHandler          ; weiter beim eigentl. Handler
dataStart
  END;
END carrierCode;

PROCEDURE MakeProgDefProc(VAR hdl:ProgDefCarrier;proc:ProgDefProc;wsp:MemArea);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),A1
        MOVE.L  -(A3),A0        ; ADR(hdl) -> A0
        MOVE.L  A1,progDefCarrier.data.proc(A0) ; proc in den Carrier schreiben
        MOVE.L  D0,progDefCarrier.data.wsp.bottom(A0) ; 'wsp' in den Carrier
        MOVE.L  D1,progDefCarrier.data.wsp.length(A0) ; kopieren
        LEA     carrierCode,A1
        LEA     progDefCarrier.code(A0),A0
        (*$? carrierCodeLen # 8: ... folgende Kopier-Zeilen korrigieren! *)
        MOVE.L  (A1)+,(A0)+     ; kopiere 'carrierCode' in 'hdl'
        MOVE.L  (A1)+,(A0)+
        MOVE.L  (A1)+,(A0)+
        MOVE.L  (A1)+,(A0)+
  END;
END MakeProgDefProc;

PROCEDURE SetProgDefSpec(obj:CARDINAL; VAR hdl:ProgDefCarrier;param:LONGWORD);

BEGIN
  ASSEMBLER
        MOVE.W  -10(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #progDefObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError
        BRA     err
typeOk
        MOVE.L  (A0),A0
        MOVE.L  -(A3),ApplBlock.parm(A0)
        MOVE.L  -(A3),ApplBlock.code(A0)
        BRA     ende
err
        SUBQ.L  #8,A3
ende
        SUBQ.L  #2,A3
  END;
END SetProgDefSpec;

PROCEDURE GetProgDefSpec(obj:CARDINAL; VAR proc:ProgDefProc;VAR param:LONGWORD);

BEGIN
  ASSEMBLER
        MOVE.W  -10(A3),(A3)+
        JSR     setCurrObject   ; setCurrObject(obj)
        TST.W   objTreeError
        BNE     err
        
        JSR     validTree
        MOVE.W  -(A3),objTreeError
        BNE     err
        JSR     objectType
        JSR     calcSpecAddr
        MOVE.W  -(A3),D0
        ANDI.W  #$00FF, D0      ; !MS high-byte bleibt unberÅcksichtigt
        CMP.W   #progDefObj,D0
        BEQ     typeOk
        MOVE.W  #TRUE,objTreeError
        BRA     err
typeOk
        MOVE.L  (A0),A0
        MOVE.L  -(A3),A1
        MOVE.L  ApplBlock.parm(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.L  ApplBlock.code(A0),A0   ; hole zugehîrige Carrieraddresse
        MOVE.L  progDefCarrier.data.proc(A0),(A1)
        BRA     ende
err
        SUBQ.L  #8,A3
ende
        SUBQ.L  #2,A3
  END;
END GetProgDefSpec;


BEGIN
  sizeOfObject:=SHORT(TSIZE(Object));  (* FÅr Assembler-Routinen *)
  sizeOfTed:=TSIZE(TEdInfo);
  sizeOfIcon:=TSIZE(IconBlock);
  sizeOfBit:=TSIZE(BitBlock);
  sizeOfAppl:=TSIZE(ApplBlock);
  
  currentObjTree:=NIL;          (* Kein aktueller Baum *)
  currentObjAddr:=NIL;          (* =sizeOfObject*currentObject+currentObjTree *)
  currentObject:=NoObject;      (* Kein aktuelles Objekt *)
  endObject:=NoObject;          (* Kein letztes Objekt *)
  objTreeError:=FALSE;          (* Kein Fehler *)
  sysTree:=FALSE;
END ObjHandler.