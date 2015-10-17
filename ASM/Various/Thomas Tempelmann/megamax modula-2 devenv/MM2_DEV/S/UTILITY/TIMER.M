
        (*  Timer -- Ein kleines Uhraccessory, das die Uhrzeit auf  *
         *           Wunsch am rechten Rand einer jeden Menuleiste  *
         *           anzeigt.                                       *
         *                                                          *
         *  Erstellt von Manuel Chakravarty          09.08.1987     *
         *  Korrekturen Th. Tempelmann               27.11.1990     *
         *                                                          *
         *  Entwickelt mit dem Megamax Modula-2 Entwicklungspaket   *)

        (* Erzeugung des Accessory:                                 *
         *                                                          *
         *   Dieses Modul compilieren, dann in den Linker-Optionen  *
         *   'GEMError' und 'GEMIO' abschalten (nur 'M2INIT' darf   *
         *   noch aktiv sein). Programm linken (z.B. mit Ctrl-L)    *
         *   und Datei auf das Wurzelverzeichnis Ihrer Boot-Disk    *
         *   (C:\, wenn Harddisk vorhanden) kopieren.               *)


MODULE Timer;
(*$R-,S-     Keine Bereichs-, öberlauf- und StackprÅfung *)
(*$E MAC     Endung fÅr Linker: ACC erzeugen *)

FROM SYSTEM IMPORT WORD,
                   ADR;

FROM Strings IMPORT String,
                    Concat, Length, Split;

FROM TimeConvert IMPORT TextToDate, TextToTime, DateToText, TimeToText;

FROM Clock IMPORT Date, Time,
                  CurrentDate, CurrentTime, SetDateAndTime, PackTime, PackDate;

FROM PrgCtrl IMPORT Accessory;

FROM GrafBase IMPORT Point, Rectangle, black, white,
                     Pnt, Rect;

FROM GEMGlobals IMPORT NoObject, ObjType, ObjFlag, OFlagSet, ObjState,
                       OStateSet, PtrObjTree, StandardFont, SmallFont,
                       THorJust, MButtonSet, SpecialKeySet, GemChar;

FROM GEMEnv IMPORT RC, DeviceHandle,
                   InitGem;

FROM AESForms IMPORT FormDialMode,
                     FormDial, FormDo, FormAlert, FormCenter;

FROM VDIOutputs IMPORT GrafText;

FROM AESEvents IMPORT RectEnterMode, Event, EventSet, MessageBuffer, accOpen,
                      MessageEvent, MultiEvent;

FROM VDIAttributes IMPORT SetTextColor;

FROM AESObjects IMPORT DrawObject, ChangeObjState;

FROM AESWindows IMPORT UpdateWindow;

FROM AESMenus IMPORT RegisterAcc;

FROM ObjHandler IMPORT SetPtrChoice,
                       CreateObjTree, SetCurrObjTree,
                       CurrObjTree, SetObjRelatives, SetObjType, SetObjFlags,
                       SetObjState, SetObjSpace, CreateSpecification,
                       LinkTextString, AssignTextStrings, SetTextForm,
                       SetBorderThickness, SetComplexColor, ObjectState;


CONST   RightBarX               =567;   (* Die Koordinaten an der die Uhrzeit *)
        RightBarY               =15;    (* angezeigt werden soll(Monochrom)   *)
        EraseString             ='        '; (* 8 Spaces zum Uhrzeit lîschen *)

TYPE    CharSet                 =SET OF CHAR;

VAR     ShowTime                :BOOLEAN;       (* Zeit anzeigen? *)
        MenuID                  :CARDINAL;      (* Unsere Accessory ID *)
        dev                     :DeviceHandle;
        ProgramName             :ARRAY[0..40] OF CHAR; (* String, der in der *
                                                 * Menuleiste erscheinen soll*)
        TimePrintSpot           :Point;
                (* Die beiden Strings sind Teile des TimeBox Objektbaumes *
                 * sie enthalten die Zeit- bzw. die Datumsangabe der Box. *
                 * 'readyBut' ist die Objektnummer des Ready-Knopfes und  *
                 * 'showMark' die Nummer der 'ShowTime'-Box. 'start' ist  *
                 * das Objekt bei dem mit dem edieren begonnen werden soll*
                 * und 'root' ist ein Zeiger auf die Wurzel des Obj.baumes*
                 * 'frame' enthÑlt die Ausmaûe der Box.                   *)
        TimeBoxGlobals          :RECORD
                                   root                 :PtrObjTree;
                                   boxTime,boxDate      :String;
                                   readyBut,showMark,
                                   start                :CARDINAL;
                                   frame                :Rectangle;
                                 END;

        voidO                   : BOOLEAN;


PROCEDURE BuildTimeBox(showTime:BOOLEAN);

  BEGIN
    WITH TimeBoxGlobals DO
      CreateObjTree(8, FALSE, voidO);     (* Baum mit 8 Elementen erzeugen *)
      root:=CurrObjTree();                (* Und Wurzelzeiger merken *)
          (* #0 *)
      SetObjRelatives(0, NoObject,1,7);
      SetObjType(0, boxObj);SetObjState(0, OStateSet{outlineObj});
      SetObjFlags(0, OFlagSet{});
      SetComplexColor(0, black,black,white,7,FALSE);
      SetBorderThickness(0, 2);
      SetObjSpace(0, Rect(0,0,26*8,10*16));
          (* #1 *)
      SetObjRelatives(1, 2,NoObject,NoObject);
      SetObjType(1, stringObj);SetObjState(1, OStateSet{});
      SetObjFlags(1, OFlagSet{});
      AssignTextStrings(1, create,'Uhr-Parameter',noChange,'',noChange,'');
      SetTextForm(1, StandardFont,centerJust);
      SetObjSpace(1, Rect(6*8,16,13*8,16));
          (* #2 *)
      SetObjRelatives(2, 3,NoObject,NoObject);
      SetObjType(2, textObj);SetObjState(2, OStateSet{});
      SetObjFlags(2, OFlagSet{});
      CreateSpecification(2, NIL);
      AssignTextStrings(2, create,'MCH',noChange,'',noChange,'');
      SetTextForm(2, SmallFont,centerJust);
      SetComplexColor(2, black,black,black,0,FALSE);
      SetObjSpace(2, Rect(22*8,6,3*8,8));
          (* #3 *)
      SetObjRelatives(3, 4,NoObject,NoObject);
      SetObjType(3, fBoxTextObj);SetObjState(3, OStateSet{});
      SetObjFlags(3, OFlagSet{editFlg});
      CreateSpecification(3, NIL);
      LinkTextString(3, ADR(boxTime));
      AssignTextStrings(3, setOnly,'',create,'Uhrzeit - __:__:__',create,'999999');
      SetTextForm(3, StandardFont,centerJust);
      SetBorderThickness(3, 0);
      SetComplexColor(3, black,black,black,0,TRUE);
      SetObjSpace(3, Rect(3*8,3*16,18*8,16));
      start:=3;                  (* Edieren soll bei diesem Object beginnen *)
          (* #4 *)
      SetObjRelatives(4, 5,NoObject,NoObject);
      SetObjType(4, fBoxTextObj);SetObjState(4, OStateSet{});
      SetObjFlags(4, OFlagSet{editFlg});
      CreateSpecification(4, NIL);
      LinkTextString(4, ADR(boxDate));
      AssignTextStrings(4, setOnly,'',create,'Datum   - __.__.____',
                        create,'99999999');
      SetTextForm(4, StandardFont,centerJust);
      SetBorderThickness(4, 0);
      SetComplexColor(4, black,black,black,0,TRUE);
      SetObjSpace(4, Rect(3*8,4*16,20*8,16));
          (* #5 *)
      SetObjRelatives(5, 6,NoObject,NoObject);
      SetObjType(5, boxObj);SetObjState(5, OStateSet{});
      IF showTime THEN SetObjState(5, OStateSet{checkObj}) END;
      SetObjFlags(5, OFlagSet{selectFlg,selectExitFlg});
      SetComplexColor(5, black,black,white,7,FALSE);
      SetBorderThickness(5, -1);
      SetObjSpace(5, Rect(5*8,6*16,2*8,16));
      showMark:=5;
          (* #6 *)
      SetObjRelatives(6, 7,NoObject,NoObject);
      SetObjType(6, stringObj);SetObjState(6, OStateSet{});
      SetObjFlags(6, OFlagSet{});
      AssignTextStrings(6, create,'Uhr anzeigen',noChange,'',noChange,'');
      SetTextForm(6, StandardFont,centerJust);
      SetObjSpace(6, Rect(8*8,6*16,12*8,16));
          (* #7 *)
      SetObjRelatives(7, 0,NoObject,NoObject);
      SetObjType(7, buttonObj);SetObjState(7, OStateSet{});
      SetObjFlags(7, OFlagSet{lastObjFlg,defaultFlg,selectFlg,
                              selectExitFlg});
      AssignTextStrings(7, create,'Alles klar!',noChange,'',noChange,'');
      SetTextForm(7, StandardFont,centerJust);
      SetObjSpace(7, Rect(6*8,8*16,13*8,16));
      readyBut:=7;
      frame:=FormCenter(root);
    END;
  END BuildTimeBox;

(*  DoTimeDialog -- geg.: aktuelle Zeit 'time', aktuelles Datum 'date' und *
 *                        Flag, das angibt, ob die Uhrzeit angezeigt wird  *
 *                        'showTime'.                                      *
 *                  ges.: Die Zeit, das Datum und das Flag vom User ediert *)

PROCEDURE DoTimeDialog(VAR time:Time; VAR date:Date; VAR showTime:BOOLEAN);

  VAR   exitObj                 : CARDINAL; (* Zuletzt angesprochenes Objekt *)
        term,success            : BOOLEAN;  (* Schleifenterminierungsflag *)
        str                     : String;
        smallFrame              : Rectangle;

  PROCEDURE strToTime(REF timeStr:ARRAY OF CHAR;VAR time:Time):BOOLEAN;
    VAR valid: BOOLEAN;
    BEGIN
      TextToTime (timeStr, time, valid);
      RETURN valid
    END strToTime;

  PROCEDURE strToDate(REF dateStr:ARRAY OF CHAR;VAR date:Date):BOOLEAN;
    VAR valid: BOOLEAN;
    BEGIN
      TextToDate (dateStr, 0, date, valid);
      RETURN valid
    END strToDate;

  BEGIN
    WITH TimeBoxGlobals DO
      SetCurrObjTree(root, FALSE);      (* TimeBox beim 'ObjHandler' anmelden *)
      TimeToText (time, "HHMMSS", boxTime);    (* Zeit fÅr die Box setzen *)
      DateToText (date, "DDMMYYYY", boxDate);  (* Datum fÅr die Box setzen *)

      smallFrame:=Rect(40,40,40,40);
      FormDial(reserveForm,smallFrame,frame); (* Bringe Box auf den Schirm *)
      FormDial(growForm,smallFrame,frame);
      DrawObject(root,0,3,frame);

      FormDo(root,start, exitObj);        (* Erste Dialogsitzung *)
      term:=FALSE;                        (* Initialisierung von 'term' *)
      REPEAT
               (* Stelle den alten Object.State des 'exitObj' wieder her *)
        ChangeObjState (root,exitObj,frame,
                        ObjectState (exitObj) - OStateSet{selectObj},TRUE);

        IF exitObj = showMark THEN
          showTime:=NOT showTime;  (* toggle mark *)
          IF showTime THEN
            ChangeObjState (root,exitObj,frame,
                            ObjectState (exitObj) + OStateSet{checkObj}, TRUE)
          ELSE
            ChangeObjState (root,exitObj,frame,
                            ObjectState (exitObj) - OStateSet{checkObj}, TRUE)
          END;
        ELSIF exitObj = readyBut THEN         (* Der Anwender ist fertig *)
          IF strToTime(boxTime,time) AND strToDate(boxDate,date) THEN
            term:=TRUE;    (* Ende des Dialogs, falls die Werte erlaubt sind *)
          END;
        END;

        IF NOT term THEN FormDo(root,start, exitObj) END; (* Weiterer Dialog *)
      UNTIL term;

      FormDial (shrinkForm,smallFrame,frame);  (* Entfernt Box vom Schirm *)
      FormDial (freeForm,smallFrame,frame);
    END; (* WITH *)
  END DoTimeDialog;

(*  SetClock -- Stellt die Uhr mit Hilfe einer Dialogbox. 'showTime' *
 *              gibt an, ob die Uhrzeit in der Menuleiste angezeigt  *
 *              werden soll.                                         *)

PROCEDURE SetClock(VAR showTime:BOOLEAN);

  VAR     time1, time2            : Time;
          date1, date2            : Date;
          showTimeOld             : BOOLEAN;
        
  BEGIN
    time1:=CurrentTime();date1:=CurrentDate();  (* Erfrage Datum und Uhrzeit *)
    time2:=time1;date2:=date1;  (* Merke dir die Zeit fÅr spÑteren Vergleich *)
    showTimeOld:=showTime;        (* Merke dir ob die Uhrzeit angezeigt wird *)
    DoTimeDialog(time2,date2,showTime);           (* Sprich mit dem Benutzer *)

      (* Falls die Uhrzeit nicht mehr angezeigt werden soll, so lîsche sie *)

    IF showTimeOld AND NOT showTime THEN
      SetTextColor(dev,black);
      GrafText(dev,TimePrintSpot,EraseString);
    END;

      (* Eventuell neue Datums- und Uhrzeitwerte setzen *)

    IF PackDate(date1)#PackDate(date2) THEN
      SetDateAndTime(date2,CurrentTime())
    END;
    IF PackTime(time1)#PackTime(time2) THEN
      SetDateAndTime(CurrentDate(),time2)
    END;
  END SetClock;

(*  PrintTime -- Zeige Uhrzeit in rechter Ecke der Menuleiste in *
 *               'Digitalzahlen' an.                             *)

PROCEDURE PrintTime;

  CONST   digital0        =20C;

  VAR     time            :Time;
          timeStr         :String;
          success         :BOOLEAN;
          i               :CARDINAL;

  BEGIN
    time:=CurrentTime();                    (* Ermittle die aktuelle Zeit *)
    TimeToText (time, "HH:MM:SS", timeStr); (* und mache eine String daraus *)

    FOR i:=0 TO Length(timeStr)-1 DO    (* Wandle die Ziffern in 'Digitalzif' *)
      IF timeStr[i] IN CharSet{'0'..'9'} THEN
        timeStr[i]:=CHR( ORD(timeStr[i]) -ORD('0')+ORD(digital0));
      END;
    END;

    SetTextColor(dev,black);
    GrafText(dev,TimePrintSpot,timeStr);
  END PrintTime;


(*  EventLoop -- Die Hauptschleife des Programmes, die darauf wartet das *
 *               ein Ereignis auftritt, welches das Accessory aktiviert. *)

PROCEDURE EventLoop;

  CONST   repTime = 2000L; (* Die Aussgabe der Uhrzeit erfolgt alle    *
                            * 2000ms, kleinste Einheit der GEMDOS-Zeit *)

  VAR     events          : EventSet;      (* Die aufgetrettenen Ereignisse *)
          msg             : MessageBuffer;

                  (* Variablen fÅr VAR-Parameter, die nicht benutzt werden. *)
          loc             : Point;
          buts            : MButtonSet;
          specials        : SpecialKeySet;
          key             : GemChar;
          clicks          : CARDINAL;

  BEGIN
    REPEAT
      MultiEvent (EventSet {message,timer},
                  0, MButtonSet {}, MButtonSet {},
                  lookForEntry, Rect (0,0,0,0), lookForEntry, Rect (0,0,0,0),
                  msg, repTime,
                  loc, buts, specials, key, clicks, events);
      IF message IN events THEN
        IF msg.msgType = accOpen THEN
          SetClock (ShowTime);   (* Das Acc. wurde angeklickt => Uhr stellen *)
        END;
      END;
      IF (timer IN events) AND ShowTime THEN
        (* Falls 2s vergangen sind und Zeitanzeige gewÅnscht *)
        (* ist, dann Zeit in der Menuleiste ausgeben.        *)
        UpdateWindow (TRUE);  (* Absichern wg. GEMDOS-Aufrufen *)
        PrintTime;
        UpdateWindow (FALSE);
      END;
    UNTIL FALSE;        (* Endlosschleife! Ein Acc. terminiert nie. *)
  END EventLoop;


VAR     voidC           : CARDINAL;
        ok              : BOOLEAN;
        msg             : MessageBuffer;
        
BEGIN
  ProgramName:="  Chaki's Clock ";      (* Der Name des Acc. *)
  ShowTime:=TRUE;                       (* Voreinstellung: Zeit anzeigen! *)
  TimePrintSpot:=Pnt(RightBarX,RightBarY);  (* Hier wird die Zeit hingedruckt *)
  
  InitGem (RC, dev, ok);
  IF ok THEN                           (* Anmeldung der Application beim GEM *)
    IF Accessory () THEN
      RegisterAcc(ADR(ProgramName), MenuID, ok);   (* Acc. beim GEM anmelden *)
      IF ok THEN
        UpdateWindow (TRUE);        (* Vorerst absichern gegen Prozeûwechsel *)
        (* zw. diesen UpdateWindow-Aufrufen dÅrfen nun die RSC-Datei geladen,*)
        (* Speicher angefordert und weitere AES-Funktionen aufgerufen werden *)
        BuildTimeBox(ShowTime);       (* Erstellt den Objektbaum der TimeBox *)
        IF ShowTime THEN PrintTime END;     (* Zeit anzeigen, wenn gefordert *)
        UpdateWindow (FALSE);
        EventLoop;                              (* Aufruf der Endlosschleife *)
      ELSE
        FormAlert(1,'[3][Timer-Accessory kann |nicht angemeldet werden ][ OK ]',voidC);
        (* leere Event-Schleife, weil ACCs nicht terminieren dÅrfen *)
        LOOP MessageEvent (msg); END
      END
    ELSE
      (* Wenn nicht als ACC gestartet, dann lassen wir nur Zeit/Datum
       * eingeben und beenden das Prg dann wieder *)
      BuildTimeBox(FALSE);            (* Erstellt den Objektbaum der TimeBox *)
      SetClock (ShowTime);                                    (* Uhr stellen *)
    END;
  END;
END Timer.
