DEFINITION MODULE AESResources;


(*  Megamax-Modula 2 GEM-Library :  Die AES Resourcefunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.2     V#0009
 *)

(*      Dieses Modul ist zum Bearbeiten von Resourcen gedacht, die mit
 *      dem Resource Construction Set (Programm zum Erstellen von Re-
 *      sourcen) erstellt wurden.
 *      Dazu wird das Resource-File einmal von Diskette geladen und
 *      daraufhin arbeiten alle Funktionen dieses Moduls auf genau
 *      dieser Resource, bis sie freigegeben oder eine andere gela-
 *      den wird.
 *)
 

FROM    SYSTEM     IMPORT ADDRESS;

FROM    GEMGlobals IMPORT PtrObjTree;
 
 
                (*  Resource Manager  *)
                (*  ================  *)

PROCEDURE LoadResource (REF pathname: ARRAY OF CHAR);
        
        (*  Liest eine Resource.
         *
         *  'pathname'  -- Pfadname der Resource. Ist diese auf dem an-
         *                 gegebenen Pfad nicht zu finden, wird zusÑtz-
         *                 lich auf Laufwerk A: gesucht. Ist auch diese
         *                 Suche nicht erfolgreich, so kehrt die Routine
         *                 zurÅck und 'GemError' liefert den Wert 'TRUE'.
         *)
        
PROCEDURE FreeResource;

        (*  Damit wird der Speicherplatz der zuletzt geladenen Resource
         *  wieder freigegeben.
         *)
        
        
TYPE    ResourcePart  = (treeRsrc,    objectRsrc,  tEdInfo,   iconBlk, bitBlk,
                         textString,  imageData,   objSpec,   tEdTextPtr,
                         tEdTmpltPtr, tEdValidPtr, ibMaskPtr, ibDataPtr,
                         ibTextPtr,   biDataPtr,   frStrPtr,  frImgPtr);
                          
PROCEDURE ResourceAddr (typ: ResourcePart; index: CARDINAL): ADDRESS;

        (*  Es wird die Adresse eines Resource-Elementes geliefert.
         *  Dabei ist 'index' der, vom Resource Construction Set
         *  fÅr dieses Element vergebene Index. Diese Indizes werden
         *  von dem Construction Set in einem Definitionsmodul abge-
         *  legt.
         *
         *  'typ' gibt an von welchem Typ das gesuchte Element ist:
         *
         *  'treeRsrc'    -- Objektbaum             ('GEMGlobals.PtrObjTree')
         *  'objectRsrc'  -- Objekt                 ('GEMGlobals.PtrObject')
         *  'tEdInfo'     -- TedInfo-RECORD         ('GEMGlobals.PtrTedInfo')
         *  'iconBlk'     -- IconBlock-RECORD       ('GEMGlobals.PtrIconBlock')
         *  'bitBlk'      -- BitBlock-RECORD        ('GEMGlobals.PtrBitBlock')
         *  'textString'  -- Zeiger auf freie Zeichenkette
         *  'imageData'   -- Zeiger auf freie Bitmuster
         *  'objSpec'     -- ObjSpec-RECORD         ('GEMGlobals.PtrObjSpec')
         *  'tEdTextPtr'  -- Zeiger auf 'GEMGlobals.TedInfo.textPtr'
         *  'tEdTmpltPtr' -- Zeiger auf 'GEMGlobals.TedInfo.tmpltPtr'
         *  'tEdValidPtr' -- Zeiger auf 'GEMGlobals.TedInfo.validPtr'
         *  'ibMaskPtr'   -- Zeiger auf 'GEMGlobals.IconBlock.mask'
         *  'ibDataPtr'   -- Zeiger auf 'GEMGlobals.IconBlock.data'
         *  'ibTextPtr'   -- Zeiger auf 'GEMGlobals.IconBlock.text'
         *  'biDataPtr'   -- Zeiger auf 'GEMGlobals.BitBlock.data'
         *  'frStrPtr'    -- Adresse eines Zeigers auf einen String
         *  'frImgPtr'    -- Adresse eines Zeigers auf ein Bitmuster
         *)
        
PROCEDURE SetResourceAddr (typ    : ResourcePart;
                           index  : CARDINAL;
                           objAddr: ADDRESS);

        (*  Mit dieser Routine kann man Adressen in eine Resource eintragen.
         *
         *  'typ'       -- muû entweder den Wert 'frStrPtr' oder 'frImgPtr'
         *                 annehmen.
         *
         *  Siehe auch 'ResourceAddr'.
         *)

PROCEDURE ConvertCoor (tree: PtrObjTree; index: CARDINAL);

        (*  Die Koordinaten des Objektes 'index' im Baum 'tree' werden
         *  von Zeichenkoordinaten in Pixelkoordinaten umgewandelt.
         *)


END AESResources.