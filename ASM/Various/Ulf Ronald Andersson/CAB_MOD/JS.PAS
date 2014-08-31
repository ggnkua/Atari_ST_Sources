{$E .OVL}

program JS_OVL;

  const JSCRIPTDEF         = 0;  { Scriptdefinition durch <SCRIPT>...</SCRIPT>       }
        JSCRIPTTIMEOUT     = 1;  { Scriptaufruf durch SetTimeout() (Zeit abgelaufen) }
        JSCRIPTLINK        = 2;  { Scriptaufruf durch Klick auf JavaScript-Verweis:  }
                                 { <A HREF="javascript:blafasel()">..</A>            }

        JSCRIPTONCLICK     = 3;  { Scriptaufruf durch Eventhandler...                }
        JSCRIPTONBLUR      = 4;
        JSCRIPTONLOAD      = 5;
        JSCRIPTONUNLOAD    = 6;
        JSCRIPTONSUBMIT    = 7;
        JSCRIPTONSELECT    = 8;
        JSCRIPTONRESET     = 9;
        JSCRIPTONMOUSEOVER = 10;
        JSCRIPTONMOUSEOUT  = 11;
        JSCRIPTONFOCUS     = 12;
        JSCRIPTONERROR     = 13;
        JSCRIPTONCHANGE    = 14;
        JSCRIPTONABORT     = 15;

       
  type JS_calls   = record
                      RunScript    : pointer; { function(script:pchar; flags:longint; windID,docID:longint):longint;}
                      KillScript   : pointer; { procedure(handle,docID:longint); }
                      exit         : pointer; { procedure; }
                      ModulName    : pchar;
                      ModulVersion : longint;
                      ModulAuthor  : pchar;
                    end;

       CAB_calls  = record                    { ErklÑrungen: siehe unten }
                      length                : longint;  
                      NavigatorName         : function:pchar; 
                      NavigatorVersion      : function:pchar; 
                      WindOpen              : function(url,name,options:pchar):longint;
                      WindClose             : procedure(windID:longint);
                      WindSetStatus         : procedure(windID:longint;status:pchar);
                      Alert                 : procedure(msg:pchar);
                      Prompt                : function(msg,default:pchar):pchar;
                      SetTimeout            : procedure(docID:longint;script:pchar;time:longint);
                      DocumentWrite         : procedure(docID:longint;source:pchar);
                      HistoryCount          : function(docID:longint):longint; 
                      HistoryFwd            : procedure(docID,amount:longint); 
                      HistoryBack           : procedure(docID,amount:longint); 
                      HistoryGo             : procedure(docID,pos:longint); 
                      FormCount             : function(docID:longint):longint;
                      FormGetID             : function(docID:longint;name:pchar):longint;
                      FormGetAction         : function(docID,formID:longint):pchar;
                      FormGetEncoding       : function(docID,formID:longint):pchar;
                      FormGetMethod         : function(docID,formID:longint):pchar;
                      FormGetTarget         : function(docID,formID:longint):pchar;
                      FormGetName           : function(docID,formID:longint):pchar;
                      FormReset             : procedure(docID,formID:longint);
                      FormSubmit            : procedure(docID,formID:longint);
                      FormElementCount      : function(docID,formID:longint):longint;
                      FormElementGetID      : function(docID,formID:longint;name:pchar):longint;
                      FormElementGetName    : function(docID,formID,elemID:longint):pchar;
                      FormElementSetValue   : procedure(docID,formID,elemID:longint;val:pchar);
                      FormElementGetValue   : function(docID,formID,elemID:longint):pchar;
                      FormElementSetDefVal  : procedure(docID,formID,elemID:longint;val:pchar);
                      FormElementGetDefVal  : function(docID,formID,elemID:longint):pchar;
                      FormElementRadioGetID : function(docID,formID,elemID,subElemID:longint):longint;
                      FormElementSetCheck   : procedure(docID,formID,elemID:longint;check:boolean);
                      FormElementGetCheck   : function(docID,formID,elemID:longint):boolean;
                      FormElementFocus      : procedure(docID,formID,elemID:longint);
                      FormElementBlur       : procedure(docID,formID,elemID:longint);
                      FormElementClick      : procedure(docID,formID,elemID:longint);
                      ConsoleOpen           : procedure;
                      ConsoleOutput         : procedure(out:pchar);
                    end;

  var CABf    : CAB_calls;


{-------------------------------------------------------}



{ function JSRunScript(script:pchar;flags,windID,docID:longint):longint }
{                                                                       }
{   script: Das JScript, so wie es in der HTML-Datei angegeben wurde.   }
{           Mit #0 abgeschlossen. Werden Teile des Puffers dauerhaft    }
{           benîtigt, mÅssen sie kopiert werden.                        }
{    flags: Gibt an, auf welche Weise das Script aufgerufen, bzw.       }
{           definiert wurde. (siehe Konstanten oben)                    }
{   windID: Die ID des Fensters, in dem sich das Dokument mit dem       }
{           Script befindet.                                            }
{    docID: Die ID des Dokuments, in dem sich das Script befindet.      }
{                                                                       }
{ RÅckgabe: Handle fuer Script (>=0), oder Fehler (-1)                  }
{           Handle =0, falls keine Resourcen dauerhaft angefordert      } 
{               wurden. JSKillScript wird spÑter dann nicht aufgerufen. }
{           Handle >0, falls Resourcen angefordert wurden, die beim     }
{               Verlassen der Seite wieder freigegeben werden sollen    }
{               Dazu ruft CAB JSKillScript auf (mit handle als Param.)  }

function JSRunScript(script:pchar;flags,windID,docID:longint):longint;
  
  { ...Hier wird das Script "script" ausgefÅhrt... }
  
  JSRunScript:=0;  { ...korrekten RÅckgabewert einsetzen... }
end;




{---------------------------------------------------------------------------}
{ JSKillScript wird aufgerufen, wenn die HTML-Seite mit der Definition des  }
{ Scripts verlassen wird. Die Resourcen/Datenstrukturen fÅr dieses Script   }
{ sollten freigegeben werden.                                               }
{ - handle ist ein Handle welches das Script eindeutig identifiziert        }
{ - docID  identifiziert das Dokument, in dem das Script definiert ist.     }
{---------------------------------------------------------------------------}

procedure JSKillScript(handle,docID:longint);
begin
  { ...Alle Resourcen fÅr Script "handle" freigeben...  }
end;




{---------------------------------------------------------------------------}
{ JSexit wird beim Beenden von CAB aufgerufen. JS.OVL muss jetzt alle       }
{ angeforderten Resourcen wieder freigeben.                                 }
{---------------------------------------------------------------------------}

procedure JSexit;
begin
  { ...Alle globalen Resourcen wieder freigeben.... }
end;



{---------------------------------------------------------------------------}
{ JSinit wird direkt nach dem Start von CAB aufgerufen. Hier muss das Modul }
{ mindestens die JS_f-Struktur ausfÅllen und sich den Inhalt der CAB_f-     }
{ Struktur sichern. Weiterhin kînnen hier alle global benîtigten Resourcen  }
{ angefordert werden.                                                       }
{ In die JS_f-Struktur werden die Funktionen/Informationen des JS.OVLs      }
{ eingetragen, die CAB benîtigt. Die CAB_f-Struktur enthÑlt Callback-       }
{ Routinen, Åber die JS.OVL Aktionen in CAB auslîsen und Åber die es auf    }
{ Datenstrukturen von CAB zugreifen kann.                                   }
{---------------------------------------------------------------------------}

function JSinit(var CAB_f:CAB_calls;var JS_f:JS_calls):longint;
begin
  JS_f.RunScript:=@JSRunScript;          { Wird aufgerufen, um ein Script zu starten  }
  JS_f.KillScript:=@JSKillScript;        { Wird aufgerufen, um ein Script freizugeben }
  JS_f.exit:=@JSexit;                    { Wird aufgerufen, wenn sich CAB beendet     }
  JS_f.ModulName:='JScript Testmodul';   { Name des Moduls                            }
  JS_f.ModulVersion:=$00001000;          { Version des Moduls: $xxxxyyyy => Vx.y      }
  JS_f.ModulAuthor:='Alexander Clauss';  { Autor des Moduls                           }
  
  move(CAB_f,CABf,min(sizeof(CABf),CAB_f.length*sizeof(pointer)+sizeof(longint)));
  
  { ...hier eventuell global benîtigte Resourcen anfordern... } 
  { ...und weitere Initialisierungen vornehmen...             } 
  
  JSinit:=0;                             { 0 wenn alles OK. [-1 bei Fehler]           }
end;




  const ovlmagic1 : longint = $48744d6c;
        ovlmagic2 : longint = $2f577757;
        ovlmagic3 : longint = $2d4a7343;
        ovlmagic4 : longint = $72497054;
        initproc  : pointer = @JSinit;             { Adresse der Init-Procedure   }

begin
  writeln(longint(@initproc)+longint(ovlmagic1)+   { Verhindert, daû der Compiler }
          longint(ovlmagic3)+longint(ovlmagic2)+   { alles wegoptimiert!          }
          longint(ovlmagic4));
end.


{================================================================================

ErklÑrungen zu den Funktionen aus "CAB_calls"


length : longint;  
-----------------
Anzahl der definierten Funktionen in der Struktur.


NavigatorName : function:pchar; 
-------------------------------
Liefert den Namen des Browsers.


NavigatorVersion : function:pchar; 
----------------------------------
Liefert die Version des Browsers.


WindOpen : function(url,name,options:pchar):longint;
----------------------------------------------------
ôffnet ein Fenster. Im Fenster wird das Dokument mit der URL "url" dargestellt.
"name" legt den Namen des Fensters fest, in "options" kînnen eine Reihe von 
Optionen fÅr das Fenster eingestellt werden (z.B. "width=400,heigth=200,
toolbar=yes"). Der RÅckgabewert ist ein Handle, Åber das das Fenster in anderen
Funktionen angesprochen werden kann.

["options" wird noch nicht ausgewertet!]


WindClose : procedure(windID:longint);
--------------------------------------
Schlieût das Fenster mit dem Handle "windID" (welches z.B. von WindOpen() 
geliefert wird).


WindSetStatus : procedure(windID:longint;status:pchar);
-------------------------------------------------------
Stellt in der Statuszeile des Fensters "windID" den Text "status" dar.


Alert : procedure(msg:pchar);
-----------------------------
ôffnet eine Dialogbox mit dem Text "msg". 


Prompt : function(msg,default:pchar):pchar;
-------------------------------------------
ôffnet eine Dialogbox mit dem Text "msg". Die Box besitzt ein Eingabefeld,
in dem der Benutzer Eingaben machen kann. In "default" kann ein Text fÅr
dieses Eingabefeld vorbelegt werden. Das Funktionsergebnis ist ein Zeiger
auf den Text, den der Benutzer eingegeben hat. Dieser Text ist bis zum
nÑchsten Aufruf dieser Funktion gÅltig.


SetTimeout : procedure(docID:longint;script:pchar;time:longint);
----------------------------------------------------------------
Mit dieser Funktion kann eine Zeit "time" (in msec) festgelegt werden, nach
deren Ablauf CAB das Script bzw. den Script-Aufruf "script" dem OVL zur
AusfÅhrung vorlegt (Åber JSRunScript()). "docID" bezeichnet dabei das Handle
des Dokuments, das das Script enthÑlt (wird an JSRunScript als Parameter
Åbergeben und kann somit i.A. einfach ohne énderung weitergereicht werden).


DocumentWrite : procedure(docID:longint;source:pchar);
------------------------------------------------------
FÅgt den Text "source" in das HTML-Dokument "docID" ein. CR (Ascii 13) oder 
LF (Ascii 10) kînnen als Zeilenendezeichen verwendet werden. 

[Funktioniert z.Z. nur bei flags=JSCRIPTDEF]


HistoryCount : function(docID:longint):longint; 
-----------------------------------------------
Liefert die Anzahl der EintrÑge der History von Dokument "docID".


HistoryFwd : procedure(docID,amount:longint); 
---------------------------------------------
Zeigt das Dokument, das "amount" Schritte weiter vorne in der History steht.


HistoryBack : procedure(docID,amount:longint); 
----------------------------------------------
Zeigt das Dokument, das "amount" Schritte weiter hinten in der History steht.


HistoryGo : procedure(docID,pos:longint); 
-----------------------------------------
Zeigt das Dokument, das an Position "pos" (0..HistoryCount(docID)-1) in der 
History steht.


FormCount : function(docID:longint):longint;
--------------------------------------------
Liefert die Anzahl der Formulare.


FormGetID : function(docID:longint;name:pchar):longint;
-------------------------------------------------------
Liefert das Handle fÅr das Formular mit dem Namen "name". Falls des Ergebnis
kleiner 0 ist, existiert das Formular nicht. Das erste Formular des Seite
bekommt das Handle 0, das zweite 1, usw.


FormGetAction : function(docID,formID:longint):pchar;
-----------------------------------------------------
Liefert die URL (Attribut ACTION des FORM-Tags) des Formulars formID zurÅck.


FormGetEncoding : function(docID,formID:longint):pchar;
-------------------------------------------------------
Liefert die Kodierung (Attribut ENCODING des FORM-Tags) zurÅck.


FormGetMethod : function(docID,formID:longint):pchar;
-----------------------------------------------------
Liefert die Methode (Attribut METHOD des FORM-Tags) zurÅck.


FormGetTarget : function(docID,formID:longint):pchar;
-----------------------------------------------------
Liefert den Framenamen zurÅck, in dem die Antwort dargestellt wird.


FormGetName : function(docID,formID:longint):pchar;
---------------------------------------------------
Liefert den Namen des Formulars mit dem Handle "formID".


FormReset : procedure(docID,formID:longint);
--------------------------------------------
Setzt das Formular "formID" zurÅck.


FormSubmit : procedure(docID,formID:longint);
---------------------------------------------
Schickt das Formular "formID" ab.


FormElementCount : function(docID,formID:longint):longint;
----------------------------------------------------------
Liefert die Anzahl der Elemente der Formulars "formID".


FormElementGetID : function(docID,formID:longint;name:pchar):longint;
---------------------------------------------------------------------
Liefert ein Handle fuer das Element mit dem Namen "name" (<0 bei Fehler).
Das erste Element bekommt Handle 0, usw.


FormElementGetName : function(docID,formID,elemID:longint):pchar;
-----------------------------------------------------------------
Liefert den Namen des Elements mit dem Handle "elemID".


FormElementSetValue : procedure(docID,formID,elemID:longint;val:pchar);
-----------------------------------------------------------------------
Setzt den Wert des Elements "elemID" des Formulars "formID" auf "val".


FormElementGetValue : function(docID,formID,elemID:longint):pchar;
------------------------------------------------------------------
Liefert den momentanen Wert des Elements "elemID".


FormElementSetDefVal : procedure(docID,formID,elemID:longint;val:pchar);
------------------------------------------------------------------------
Setzt den Default-Wert des Elements "elemID" des Formulars "formID" auf "val".
Bei "Reset" werden alle Elemente auf ihre Default-Werte gesetzt.


FormElementGetDefVal : function(docID,formID,elemID:longint):pchar;
-------------------------------------------------------------------
Liefert den Default-Wert des Elements "elemID".


FormElementRadioGetID : function(docID,formID,elemID,subElemID:longint):longint;
--------------------------------------------------------------------------------
Zusammengehîrende Radio-Buttons haben den gleichen Namen. Mit FormElementGetID()
bekommt man nur das Handle des ersten Radio-Buttons mit diesem Namen. Mit dieser
Funktion kann man die Handles aller weiteren Radio-Buttons erfragen. "subElemID"
bestimmt dabei, welchen Button man untersuchen mîchte. Ist "subElemID" gleich
0 bekommt man das Handle des ersten Buttons, mit "subElemID" gleich 1 bekommt
man das des zweiten Buttons, usw.


FormElementSetCheck : procedure(docID,formID,elemID:longint;check:boolean);
---------------------------------------------------------------------------
In ein Checkbox-Button wird ein (check=true) oder kein (check=false) Kreuz
gesetzt.


FormElementGetCheck : function(docID,formID,elemID:longint):boolean;
--------------------------------------------------------------------
Liefert den Status einer Checkbox (true=angekreuzt)


FormElementFocus : procedure(docID,formID,elemID:longint);
----------------------------------------------------------
Setzt den Eingabefokus auf das Element "elemID".


FormElementBlur : procedure(docID,formID,elemID:longint);
---------------------------------------------------------
Entfernt den Eingabefokus vom Element "elemID".


FormElementClick : procedure(docID,formID,elemID:longint);
----------------------------------------------------------
Entspricht einem Klick auf das Element "elemID".


ConsoleOpen : procedure;
------------------------
ôffnet ein Console-Fenster, in dem z.B. Fehlermeldungen ausgegeben 
werden kînnen, 


ConsoleOutput : procedure(out:pchar);
-------------------------------------
Gibt den String "out" im Console-Fenster aus. Es werden z.Z. bis zu 
250 Strings im Console-Fenster verwaltet (bei mehr als 250 werden
die ersten wieder gelîscht). Ein String darf bis zu 255 Zeichen 
lang sein. Auch wenn das Fenster geschlossen ist, werden die 
ausgegebenen Strings intern verwaltet. Sobald der Benutzer (oder
das JS.OVL) das Fenster îffnet, werden alle Ausgaben sichtbar.


to be continued....

=================================================================================}

