DEFINITION MODULE AESMenus;


(*  Megamax-Modula 2 GEM-Library :  Die AES MenÅfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.2     V#0007
 *)
 
 
(*      Dieses Modul stellt die Routinen zur VerfÅgung, die zum
 *      Arbeiten mit Menuzeilen nîtig sind. Darunter auch eine,
 *      die es einem Programm erlaubt, sich als Accessory anzumelden.
 *)
 
 
FROM GEMGlobals IMPORT PtrObjTree, PtrMaxStr;
 
 
                (*  Menu Manager  *)
                (*  ============  *)

PROCEDURE MenuBar (tree: PtrObjTree; show: BOOLEAN);

        
        (*  Diese Prozedur meldet eine MenÅzeile an oder ab.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'show'      -- 'TRUE': das MenÅ wird angemeldet. Das bedeutet
         *                 daû die Zeile am oberen Rand des Bildschirms
         *                 dargestellt wird und daû bei einem folgende
         *                 Aufruf einer Eventprozedur (siehe AESEvents)
         *                 vom AES darauf geachtet wird, ob der Mauszei-
         *                 ger die MenÅzeile betritt.
         *                 'FALSE': das MenÅ wird zwar nicht vom Bild-
         *                 schirm gelîscht, aber es kann vom Anwender
         *                 nicht mehr benutzt werden.
         * 'tree'       -- muû einen Zeiger auf die Definition der MenÅ-
         *                 zeile in Form eines Objektbaumes beinhalten.
         *)
        
PROCEDURE CheckItem (tree: PtrObjTree; item: CARDINAL; check: BOOLEAN);

        (*  Diese Prozedur setzt oder lîscht den Haken links neben
         *  dem MenÅeintrag.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'tree'      -- die MenÅzeile in der der Eintrag steht.
         *  'item'      -- der Eintrag
         *  'check'     -- 'TRUE' : der Haken wird gesetzt.
         *                 'FALSE': der Haken wird gelîscht.
         *)
        
PROCEDURE EnableItem (tree: PtrObjTree; item: CARDINAL; enable: BOOLEAN);

        (*  Der Eintrag einer MenÅzeile wird aktiviert oder deakti-
         *  viert. Der Schriftzug eines deativierten Eintrages wird
         *  aufgehellt dargestellt und kann vom Anwender nicht mehr
         *  angewÑhlt werden.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'item'      -- der Eintrag
         *  'tree'      -- die MenÅzeile, in der der Eintrag steht.
         *  'enable'    -- 'TRUE' : Eintrag wird aktiviert
         *                 'FALSE': Eintrag wird deaktiviert
         *)
        
PROCEDURE NormalTitle (tree  : PtrObjTree;
                       title : CARDINAL;
                       normal: BOOLEAN);

        (*  Der Titel in einer MenÅzeile wird normal oder invers
         *  dargestellt. Die inverse Darstellung bedeutet, daû der
         *  Title angwÑhlt wurde.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'title'     -- Der Titel, der normal oder invers darge-
         *                 stellt werden soll.
         *  'tree'      -- Die MenÅzeile, in der der Titel steht
         *  'normal'    -- 'TRUE' : Titel normal darstellen
         *                 'FALSE': Titel invers darstellen
         *
         *)

PROCEDURE MenuText (tree: PtrObjTree; item: CARDINAL; REF text: ARRAY OF CHAR);

        (*  Diese Routine erlaubt es, einem MenÅeintrag einen neuen
         *  Text zuzuweisen.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'item'      -- Der MenÅeintrag
         *  'text'      -- Der neue Text
         *
         *  Es ist darauf zu achten, daû die neue Zeichenkette nicht
         *  lÑnger als die Alte ist. Der Text sollte durch zwei Leer-
         *  zeichen eingeleitet werden und am Ende mit Leerzeichen
         *  aufgefÅllt werden. Am Ende sollte mindestens ein Leerzei-
         *  chen stehen.
         *)

PROCEDURE RegisterAcc (    title  : PtrMaxStr;
                       VAR id     : CARDINAL;
                       VAR success: BOOLEAN);
        
        (*  Diese Prozedur darf nur von Accessories verwendet werden.
         *  Sie trÑgt ein Accesory im MenÅ ein.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'title'     --'title^' ist die Zeichenkette des Accesory's
         *                das in das MenÅ eingetragen werden soll.
         *
         *  Ausgabeparameter
         *  ----------------
         *
         *  'success'   --'TRUE' : die Anmeldung war erfolgreich
         *                'FALSE': Anmeldung war nicht erfolgreich
         *  'id'        -- enthÑlt, falls die Anmeldung erfolgreich war
         *                 die Identifikationsnummer des Accesorry's
         *                 die bei jeder 'accOpen' und 'accClose' Nach-
         *                 richt angegeben wird. (Siehe AESEvents)
         *
         *  Es ist darauf zu achten, daû title^ eine globale Variable
         *  ist!
         *)
        

END AESMenus.