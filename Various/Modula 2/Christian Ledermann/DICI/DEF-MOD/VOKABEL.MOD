IMPLEMENTATION MODULE VOKABEL;

FROM ApplTool   IMPORT Accessory;
FROM AES        IMPORT Root,Nil,ObjectIndex,ObjectPtr,TreeIndex,
                       TreePtr,StringPtr,String,Disabled,
                       ObjectState,Selected,State15,Checked,
                       HideTree,Key,SpecialKey,KLShift,KRShift,
                       MouseButton,MBLeft;
FROM ApplMgr    IMPORT ApplInit,ApplExit,ApplWrite;
FROM EvntMgr    IMPORT EvntEvent,MEvent,MuMesag,MuKeybd,MuButton,Event,
                       MessageBlock,ApMsg,ApTerm,ApDragDrop,AcOpen,
                       WMRedraw,WMNewTop,WMTopped,WMSized,WMMoved,WMFulled,
                       WMClosed,WMOffTop,MnSelected;
FROM ObjcMgr    IMPORT ObjcDraw,MaxDepth,ObjcOffset,ObjcFind,ObjcChange;
FROM FormMgr    IMPORT FmDStart,FmDGrow,FmDShrink,FmDFinish,FormDial,
                       FormCenter,FormDo;
FROM MenuMgr    IMPORT MenuIEnable,MenuTNormal,MenuRegister;
FROM GrafMgr    IMPORT GrafHandle,GrafMKState,GrafGrowBox,GrafShrinkBox;
FROM RsrcMgr    IMPORT RsrcLoad,RsrcFree,AddRsrcLoad;
FROM RcMgr      IMPORT GRect,GPnt,RcSnap,RcIntersect,RcEqual;
FROM MenuTool   IMPORT ShowMenu,HideMenu,NewMenuAction,MenuAction;
FROM ObjcTool   IMPORT ObjectXYWH,INCLObjectState,EXCLObjectState,
                       INCLObjectFlags,EXCLObjectFlags,TreeWalk,
                       NewObjectCallback,ObjectCall,Indirect;
FROM FormTool   IMPORT OK,Alert,Mask,PopupAttach;
FROM RsrcTool   IMPORT GetTreePtr,GetFreeStringPtr;
FROM GrafTool   IMPORT ShowMouse,HideMouse,BusyMouse,MouseForm,FlatHand,
                       PointingHand,ArrowMouse,LastMouse,
                       RubberBox,HotDragBox,HotDragIcon;
FROM WindTool   IMPORT BeginUpdate,EndUpdate,
                       BeginMouseControl,EndMouseControl,
                       RedrawWindow;
FROM VDITool    IMPORT OpenVirtualWorkstation,CloseVirtualWorkstation,
                       SetClip,GRectToArray;
FROM INTRINSIC  IMPORT VOID,PTR;
FROM PORTAB     IMPORT UNSIGNEDWORD,SIGNEDWORD;
FROM pSTRING    IMPORT UPPER, APPEND, APPENDCHR, SLEN, EQUAL, ASSIGN, DELETE;
FROM ConvertStr IMPORT LongCardToStr, StrToLongCard, IntToStr, StrToInt;
FROM ScrpMgr IMPORT ScrpRead, ScrpWrite, ScrpClear, Scrap,
		    NoScrap, ScTXT, ScASC;
FROM ShelMgr IMPORT ShelRead;		    

IMPORT EvntTool,FlyingLook,SetObject,GetObject;
IMPORT TermWindow,Application,FileSystem;
IMPORT Atari2Ascii,Upper2LC, GetHelp,VokabelImport,VokabelExport;
FROM GetFile IMPORT StripExtension, GetPathAndFile;
FROM pSTORAGE IMPORT ALLOCATE,DEALLOCATE;
FROM SYSTEM IMPORT LONG,TSIZE;

FROM DruckTreiber IMPORT PrintHandle,SetLQ,ConfigPrinter,S;

FROM InOut IMPORT WriteString,WriteLn,Done,ReadLine,
                  OpenInput,OpenOutput,CloseInput,CloseOutput;

FROM BTree IMPORT Create,Start,First, Last,Next, Previous,PageType,KeyArray,
 		  SearchFirst, SearchPtr, PagePtr,Close,FileOf,PutData,GetData, Get, Put,
		  PrintTree, AddData, AddKey, KeyType, DataType,BaseType,SearchNext,
		  Delete,FileType, DataPtr, PrintDataProc,Empty,Browse;

CONST RscName   = "DICI.RSC";


VAR ApplId    : SIGNEDWORD;
    VirtScreen: UNSIGNEDWORD;

    ACC	      : BOOLEAN;
    
    Register  : ARRAY[0..20] OF CHAR;

    MyMenu    : TreePtr;

    Work      : GRect;
    CharWidth : UNSIGNEDWORD;
    CharHeight: UNSIGNEDWORD;
    BoxWidth  : UNSIGNEDWORD;
    BoxHeight : UNSIGNEDWORD;
    MinWidth  : SIGNEDWORD;
    MinHeight : SIGNEDWORD;

    PIndex , NIndex, GIndex, DataBase : FileOf;
    LastKey : KeyType;
    DataBaseOpen : BOOLEAN;
    DataBaseSelected : BOOLEAN;
    TerminalWindowOpen : BOOLEAN;

PROCEDURE DoNothing(Menu: TreePtr; Title: ObjectIndex);
BEGIN
END DoNothing;

PROCEDURE InitScrap;
VAR ScrpDir : ARRAY [0..127] OF CHAR;
    ret : Scrap;
    Tree : TreePtr;
BEGIN
   ret := ScrpRead(ScrpDir);
   Tree:= GetTreePtr(DIALTREE);
   IF (SLEN(ScrpDir) > 3) AND (ret # NoScrap) THEN
      EXCLObjectState(Tree,CLIP,Disabled);
      EXCLObjectState(Tree,CLIPREAD,Disabled);
      MenuIEnable(MyMenu,CLIPBRD,TRUE);
   ELSE
      INCLObjectState(Tree,CLIP,Disabled);
      INCLObjectState(Tree,CLIPREAD,Disabled);
      MenuIEnable(MyMenu,CLIPBRD,FALSE);
   END(*IF*);
END InitScrap;

PROCEDURE DoForm(Menu  : TreePtr;
                 Title : ObjectIndex;
                 TreeNo: TreeIndex;
                 Start : ObjectIndex): ObjectIndex;

VAR Tree  : TreePtr;
    From  : GRect;
    To    : GRect;
    Return: SIGNEDWORD;

BEGIN
  ObjectXYWH(Menu,Title,From);
  Tree:= GetTreePtr(TreeNo);
  FormCenter(Tree,To);
  BeginUpdate;
  FormDial(FmDStart,To,To);
  FormDial(FmDGrow,From,To);
  ObjcDraw(Tree,Root,MaxDepth,To);
  Return:= Mask(FormDo(Tree,Start));

  (* using FlyingLook you have to call FormCenter() a second time! *)

  FormCenter(Tree,To);

  ObjcChange(Tree,Return,1,To,
             GetObject.State(Tree,Return) - ObjectState{Selected},FALSE);
  FormDial(FmDShrink,From,To);
  FormDial(FmDFinish,To,To);
  EndUpdate;
  ArrowMouse;
  RETURN Return;
END DoForm;

PROCEDURE DoOpenTerminal;
BEGIN
   IF ~TerminalWindowOpen THEN
      (* Terminal Window darf nicht mehrmals geîffnet werden! *)
      TermWindow.OpenTerminal(0,0,0,0);
      (* Mit 0,0,0,0 wird die letzte Grîûe wiederhergestellt *)
      (* bzw bei erstem Aufruf maximale Fenstergrîûe gesetzt *)
      TerminalWindowOpen:= TRUE;
   ELSE
       TermWindow.ResetTerminal;(* Alten Inhalt lîschen *)
       TermWindow.Redraw; (* Neu zeichnen *)
   END(*IF*);
END DoOpenTerminal;

(* PROCEDURE Wait;
VAR Tree  : TreePtr;
    Form  : GRect;
BEGIN
  Tree:= GetTreePtr(WAIT);
  FormCenter(Tree,Form);
  BeginUpdate;
  FormDial(FmDStart,Form,Form);
  ObjcDraw(Tree,Root,MaxDepth,Form);    
  FormDial(FmDFinish,Form,Form);
  EndUpdate;  
END Wait; *)

PROCEDURE IsSelected(TreeNo : TreeIndex; Index : ObjectIndex) : BOOLEAN;
BEGIN
  RETURN Selected IN GetObject.State(GetTreePtr(TreeNo),Index)
END IsSelected;

PROCEDURE GetPopUpEntry( PopUp, Dialog : TreeIndex; PopUpParent : ObjectIndex) : ObjectPtr;
VAR First, Last : ObjectPtr;
    DialTree, PopUpTree : TreePtr;
    ParentString, PopUpString : StringPtr;
    i : ObjectPtr;
BEGIN
    DialTree:=GetTreePtr(Dialog);
    PopUpTree:=GetTreePtr(PopUp);
    First := GetObject.Head(PopUpTree,Root);
    Last := GetObject.Tail(PopUpTree,Root);
    ParentString:=GetObject.StringPtr(DialTree,PopUpParent);
    (* WriteString(ParentString^);WriteString('<<==');*)
    FOR i:= First TO Last DO
        PopUpString:=GetObject.StringPtr(PopUpTree,i);
         (*  WriteString(PopUpString^);WriteLn;*)
        IF EQUAL(PopUpString^,ParentString^) THEN
          (* WriteString('==>>');
            WriteString(PopUpString^);WriteLn;*)
            RETURN i
        END(*IF*);
    END(*FOR*);
    RETURN 0
END GetPopUpEntry;

PROCEDURE DoClose(Menu : TreePtr; Title : ObjectIndex);
BEGIN
    IF DataBaseOpen THEN
        Close(DataBase);
        DEALLOCATE(DataBase.RecordPtr,TSIZE(BaseType));
        Close(PIndex);
        DEALLOCATE(PIndex.RecordPtr1,TSIZE(PageType));
        Close(NIndex);
        DEALLOCATE(NIndex.RecordPtr1,TSIZE(PageType));
        Close(GIndex);
        DEALLOCATE(GIndex.RecordPtr1,TSIZE(PageType));
        DataBaseOpen := FALSE;
        DataBaseSelected := FALSE;
        (*MenuIEnable(Menu,EXIMPORT,FALSE);*)
    END(*IF*);
END DoClose;

PROCEDURE ReClose;
BEGIN
    IF DataBaseOpen THEN
        Close(DataBase);
        Close(PIndex);
        Close(NIndex);
        Close(GIndex);
        DataBaseOpen := FALSE;
    END(*IF*);
END ReClose;

PROCEDURE OpenDataBase(Path : ARRAY OF CHAR);
VAR Name : ARRAY [0..127] OF CHAR;
    Data : DataType;
    Keys : KeyArray;
BEGIN
    ASSIGN(Path,Name);
    IF SLEN(Path)<7 THEN (* C:\a.vbf = 8 Zeichen *)
       RETURN (* Kein gÅltiger Dateiname! *)
    END(*IF*);   
    StripExtension(Path);APPEND('.VBF',Path);
    IF ~EQUAL(Path,Name) THEN (* Kein gÅltiger Dateiname! *)
        DataBaseOpen := FALSE;
        DataBaseSelected := FALSE;
    ELSE     
        ASSIGN(Path,DataBase.Name);
        DataBase.Type := TheData;
        DataBase.RecordSize := LONG(TSIZE(BaseType));
        ALLOCATE(DataBase.RecordPtr,TSIZE(BaseType));
        Start(DataBase);

        StripExtension(Path);APPEND('.GDX',Path);
        GIndex.MultipleKeys := TRUE;
        GIndex.Type := GerIndex;
        GIndex.RecordSize := LONG(TSIZE(PageType));
        ALLOCATE(GIndex.RecordPtr1,TSIZE(PageType));
        ASSIGN(Path,GIndex.Name); Start(GIndex);

        StripExtension(Path);APPEND('.NDX',Path);
        NIndex.MultipleKeys := FALSE;
        NIndex.Type := NumIndex;
        NIndex.RecordSize := LONG(TSIZE(PageType));
        ALLOCATE(NIndex.RecordPtr1,TSIZE(PageType));
        ASSIGN(Path,NIndex.Name); Start(NIndex);

        StripExtension(Path);APPEND('.PDX',Path);
        PIndex.MultipleKeys := TRUE;
        PIndex.Type := PorIndex;
        PIndex.RecordSize := LONG(TSIZE(PageType));
        ALLOCATE(PIndex.RecordPtr1,TSIZE(PageType));
        ASSIGN(Path,PIndex.Name); Start(PIndex);

        Last(NIndex,DataBase,LastKey,Data,Keys);
        DataBaseOpen := TRUE;
        DataBaseSelected := TRUE;    
    END(*IF*);   
END OpenDataBase;

PROCEDURE DoOpen(Menu : TreePtr; Title : ObjectIndex);
VAR Path , Name : ARRAY [0..127] OF CHAR;
BEGIN
    DoClose(Menu,Title);
    Path :='';Name:='OPEN.VBF';
    IF GetPathAndFile('*.VBF','Datei îffnen: ',Path,Name) THEN
        APPEND(Name,Path);
        OpenDataBase(Path)
        (*MenuIEnable(Menu,EXIMPORT,TRUE);*)
    END(*IF*);
END DoOpen;

PROCEDURE ReOpen;
VAR Data : DataType;
    Keys : KeyArray;
BEGIN
    IF DataBaseSelected THEN
        Start(DataBase);
        Start(GIndex);
        Start(NIndex);
        Start(PIndex);
        Last(NIndex,DataBase,LastKey,Data,Keys);
        DataBaseOpen := TRUE
    ELSE 
       DoOpen(MyMenu,ABOUT);
       InitScrap; (* zur Zeit des ACC-Starts gibt es noch kein Clipboard!*)
    END(*IF*);    
END ReOpen;

PROCEDURE DoCreate(Menu : TreePtr; Title : ObjectIndex);
VAR Path , Name : ARRAY [0..127] OF CHAR;
BEGIN
    DoClose(Menu,Title);
    Path :='';
    Name:='NEWFILE.VBF';
    IF GetPathAndFile('*.VBF','Neue Datei : ',Path,Name) THEN
        APPEND(Name,Path);
        ASSIGN(Path,DataBase.Name);
        Create(DataBase);
        StripExtension(Path);APPEND('.GDX',Path);
        ASSIGN(Path,GIndex.Name); Create(GIndex);
        StripExtension(Path);APPEND('.NDX',Path);
        ASSIGN(Path,NIndex.Name); Create(NIndex);
        StripExtension(Path);APPEND('.PDX',Path);
        ASSIGN(Path,PIndex.Name); Create(PIndex);
    END(*IF*);
END DoCreate;

PROCEDURE BrowseProc(Data : DataType);
VAR i,j : CARDINAL;
BEGIN
   j:=0;
   FOR i:=0 TO 4 DO
      IF SLEN(Data.Inhalt[i])>0 THEN
          j := j + SLEN(Data.Inhalt[i]);
          IF j > 60 THEN
             TermWindow.WriteLn; j:=0;
          ELSIF i>0 THEN
             TermWindow.WriteString(' - ');
          END(*IF*);
          TermWindow.WriteString(Data.Inhalt[i]);
      END(*IF*);
   END(*FOR*);
   TermWindow.WriteLn;
END BrowseProc;

PROCEDURE BrowsePrefs(Menu : TreePtr; Title: ObjectIndex):BOOLEAN;
VAR r :INTEGER;
BEGIN
   r:=(DoForm(Menu,Title,BROWDIAL,BROWFROM));
   IF r = HELPBROW THEN
      IF ~ GetHelp.CallSTGuide(ApplId,'DICI.HYP','Browser') THEN
          Alert(NOSTGUID);
      END(*IF*);
   ELSIF r = OKBROW THEN 
      RETURN TRUE 
   END(*IF*);    
   RETURN FALSE 
END BrowsePrefs;

PROCEDURE RemoveEndBlanks(VAR String : ARRAY OF CHAR);
VAR Length : CARDINAL;
BEGIN
   Length := SLEN(String)-1;(* letztes Zeichen *)
   WHILE (String[Length]=' ') AND (Length >= 1) DO
       String[Length]:=0C;
       Length:= Length-1;
   END(*WHILE*);
END RemoveEndBlanks;

PROCEDURE MakeKey( In : ARRAY OF CHAR) : LONGCARD;
BEGIN
    Atari2Ascii.CorkConvert(In);UPPER(In);
    RETURN Upper2LC.MakeLongCard(In);
END MakeKey;

PROCEDURE Import(Data : DataType);
VAR Keys : KeyArray;
    DataReference : DataPtr;
    found, added : BOOLEAN;
    i : INTEGER;

  PROCEDURE DoQuery() : BOOLEAN;
  VAR Ret, entryNr : INTEGER;
       Str : ARRAY [0..5] OF CHAR;
      OldData : DataType;
      OldKeys : KeyArray;
      ok : BOOLEAN;

  BEGIN
    IF SearchFirst(PIndex,DataBase,Keys[PorIndex],OldData,OldKeys) THEN
      entryNr:=0;
      Str :='0';
      TermWindow.WriteString(Str);
      BrowseProc(OldData);
      WHILE SearchNext(PIndex,DataBase,OldData,OldKeys) DO
         entryNr:=entryNr+1;
         IntToStr(entryNr,2,Str,ok);
         TermWindow.WriteString(Str);
         BrowseProc(OldData);
      END(*WHILE*);
      Ret := DoForm(MyMenu,EXIMPORT,QUIMDIAL,ERSETZNR);
      CASE Ret OF
        ERSETZTE :;

      | FUEGEEIN : RETURN FALSE; (* einfÅgen *)
      | EDIERE   :;

      | VERWERFE : RETURN TRUE;
      ELSE
      ;
      END(*CASE*);
   END(*IF*);
  END DoQuery;

BEGIN
    Keys[PorIndex]:= MakeKey(Data.Inhalt[0]);
    Keys[GerIndex]:= MakeKey(Data.Inhalt[1]);
    IF IsSelected(EXIMDIAL,TODBL) THEN
       DataReference:=SearchPtr(PIndex,DataBase,0D,Keys[PorIndex],found);
       IF found THEN
           TermWindow.WriteLn;
           TermWindow.WriteString('Doppelter Eintag: ');
           TermWindow.WriteString(Data.Inhalt[0]);
           VokabelExport.StTrans(Data);
           RETURN
       END(*IF*);
    ELSIF IsSelected(EXIMDIAL,SHOWQUE) THEN
          DataReference:=SearchPtr(PIndex,DataBase,0D,Keys[PorIndex],found);
          IF found THEN
             TermWindow.WriteLn;
             TermWindow.WriteString('Doppelter Eintag: ');
             BrowseProc(Data);
             IF DoQuery() THEN
                 RETURN
             END(*IF*);
          END(*IF*);
    END(*IF*);
    LastKey := LastKey+1D;
    IF (LastKey MOD 20D)=0D THEN
         (* alle 20 EintrÑge etwas malen damit der Anwender weiû
         daû das Programm (noch) nicht abgestÅrzt ist *)
         TermWindow.WriteString('*');
    END(*IF*);
    Keys[NumIndex]:= LastKey;
    DataReference:=AddData(DataBase,Data);
    IF AddKey(NIndex,DataBase,Keys[NumIndex],DataReference) THEN
       added := AddKey(PIndex,DataBase,Keys[PorIndex],DataReference);
       added := AddKey(GIndex,DataBase,Keys[GerIndex],DataReference);
    ELSE
       DataBase.Last := DataBase.Last-1D;
       Alert(KEYALERT)
    END(*IF*);
END Import;

PROCEDURE ImportInfo(VAR Path : ARRAY OF CHAR);
BEGIN
      TermWindow.WriteString(Path);
      TermWindow.WriteString(' wird importiert in');
      TermWindow.WriteLn;
      TermWindow.WriteString(DataBase.Name);
      TermWindow.WriteLn;
      IF IsSelected(EXIMDIAL,TODBL) THEN
           StripExtension(Path);APPEND('.DBL',Path);
           OpenOutput(Path);
           IF Done THEN
                   TermWindow.WriteLn;
	           TermWindow.WriteString('Doppelte EintrÑge werden nach:');
	           TermWindow.WriteLn;
	           TermWindow.WriteString(Path);
	           TermWindow.WriteString(' geschrieben');
	           TermWindow.WriteLn;
           END(*IF*);
      END(*IF*); 
      TermWindow.WriteLn;  
END ImportInfo; 

PROCEDURE DoImportVocMan(Menu : TreePtr; Title: ObjectIndex);
VAR Path , Name : ARRAY [0..127] OF CHAR;
    DoImport : VokabelImport.ImportProc;
BEGIN
    Path:='';Name:='';
    IF DataBaseOpen THEN
       DoImport := Import;
       IF GetPathAndFile('*.VOC','VocMan Importieren: ',Path,Name) THEN
             APPEND(Name,Path);
             OpenInput(Path);
             BusyMouse;
             IF Done THEN
               DoOpenTerminal;
               ImportInfo(Path);
               VokabelImport.VocMan(DoImport);
             END(*IF*);
             ArrowMouse;
             CloseInput;CloseOutput;
       END(*IF*);
    END(*IF*);
END DoImportVocMan;

PROCEDURE DoImportStTrans(Menu : TreePtr; Title: ObjectIndex);
VAR Path , Name : ARRAY [0..127] OF CHAR;
    DoImport : VokabelImport.ImportProc;

BEGIN
   Path:='';Name:='';
   IF DataBaseOpen THEN
      DoImport := Import;
      IF GetPathAndFile('*.ASC','St-Trans Importieren: ',Path,Name) THEN
             APPEND(Name,Path);
             OpenInput(Path);
             IF Done THEN
               DoOpenTerminal;
               BusyMouse;
               ImportInfo(Path);
               VokabelImport.StTrans(DoImport);
             END(*IF*);
             CloseInput;CloseOutput;
             ArrowMouse;
       END(*IF*);
   END(*IF*);
END DoImportStTrans;


PROCEDURE TreeOut(OutProc : PrintDataProc);
VAR Index : FileOf;
    BrowseFrom,BrowseTo : String;
    BrowseFromKey,BrowseToKey : KeyType;
    done : BOOLEAN;
    Tree : TreePtr;
 
BEGIN
    (*IF IsSelected(DIALTREE,KEYPOR) THEN
       Index := PIndex;
    ELSIF IsSelected(DIALTREE,KEYNUM) THEN
       Index := NIndex;
    ELSIF IsSelected(DIALTREE,KEYGER) THEN
       Index := GIndex;*)
    Tree:= GetTreePtr(BROWDIAL);
    RemoveEndBlanks(BrowseFrom);
    RemoveEndBlanks(BrowseTo);
    GetObject.String(Tree,BROWFROM,BrowseFrom);       
    GetObject.String(Tree,BROWSETO,BrowseTo);       
    BrowseFromKey :=MakeKey(BrowseFrom);
    BrowseToKey := MakeKey(BrowseTo);
    IF IsSelected(BROWDIAL,BRKEYPOR) THEN
       Index := PIndex;
    ELSIF IsSelected(BROWDIAL,BRKEYNUM) THEN
       Index := NIndex;
       StrToLongCard(BrowseFrom,BrowseFromKey,done);
       StrToLongCard(BrowseTo,BrowseToKey,done);
    ELSIF IsSelected(BROWDIAL,BRKEYGER) THEN
       Index := GIndex;       
    ELSE
        RETURN
        (*
        Index := NIndex;(* Eigentlich nicht mîglich das kein Feld selektiert*)
         *)
    END(*IF*);
    Browse(Index,DataBase,0D,BrowseFromKey,BrowseToKey,OutProc);
    (*4Browse(Index,DataBase,0D,BrowseToKey,BrowseFromKey,OutProc);*)
END TreeOut;

PROCEDURE LaTeXExport(Data :DataType);

  PROCEDURE WriteRest;
  VAR i : INTEGER;
  BEGIN
    FOR i:=1 TO HIGH(Data.Inhalt) DO
       WriteString(Data.Inhalt[i]);WriteString(' ');
    END(*FOR*);
    IF IsSelected(EXIMDIAL,INDEX) THEN
       RemoveEndBlanks(Data.Inhalt[0]);
       WriteString(' \index{');
       WriteString(Data.Inhalt[0]);
       WriteString('}');
    END(*IF*);
  END WriteRest;

BEGIN
    IF IsSelected(EXIMDIAL,DESCRIPT) THEN
       WriteString('\item[');
       WriteString(Data.Inhalt[0]);
       WriteString('] ');
       WriteRest;
    ELSE
       WriteString('{\bf ');
       WriteString(Data.Inhalt[0]);
       WriteString('} ');
       WriteRest;
       WriteString('\\');
    END(*IF*);
    WriteLn;
END LaTeXExport;

PROCEDURE DoExportLaTeX(Menu : TreePtr; Title: ObjectIndex);
VAR Path , Name : ARRAY [0..127] OF CHAR;
BEGIN
   Path:='';Name:='';
   IF DataBaseOpen THEN
    IF BrowsePrefs(Menu, Title) THEN 
      IF GetPathAndFile('*.TEX','LaTeX - exportiern',Path,Name) THEN
             APPEND(Name,Path);
             OpenOutput(Path);
             IF Done THEN
                BusyMouse;
                TreeOut(LaTeXExport);
             END(*IF*);
             CloseOutput;
             ArrowMouse;
      END(*IF*);
    END(*IF*);  
   END(*IF*);
END DoExportLaTeX;

PROCEDURE DoExportStTrans(Menu : TreePtr; Title: ObjectIndex);
VAR Path , Name : ARRAY [0..127] OF CHAR;
BEGIN
   Path:='';Name:='';
   IF DataBaseOpen THEN
    IF BrowsePrefs(Menu, Title) THEN 
      IF GetPathAndFile('*.ASC','ST-Trans exportiern',Path,Name) THEN
             APPEND(Name,Path);
             OpenOutput(Path);
             IF Done THEN
               BusyMouse;
               (*Wait;*)
               TreeOut(VokabelExport.StTrans);
               WriteString('-----');WriteLn;
             END(*IF*);
             CloseOutput;
             ArrowMouse;
      END(*IF*);
    END(*IF*);
   END(*IF*);
END DoExportStTrans;

PROCEDURE DoExportVocMan(Menu : TreePtr; Title: ObjectIndex);
VAR Path , Name : ARRAY [0..127] OF CHAR;
BEGIN
Path:='';Name:='';
   IF DataBaseOpen THEN
    IF BrowsePrefs(Menu, Title) THEN 
      IF GetPathAndFile('*.VOC','Voc-Man exportiern',Path,Name) THEN
             APPEND(Name,Path);
             OpenOutput(Path);
             IF Done THEN
                BusyMouse;
                TreeOut(VokabelExport.VocMan);
             END(*IF*);
             CloseOutput;
             ArrowMouse;
      END(*IF*);
    END(*IF*);
   END(*IF*);
END DoExportVocMan;

PROCEDURE DoExportIdeaList(Menu : TreePtr; Title: ObjectIndex);
VAR Path , Name : ARRAY [0..127] OF CHAR;
BEGIN
Path:='';Name:='';
   IF DataBaseOpen THEN
    IF BrowsePrefs(Menu, Title) THEN 
      IF GetPathAndFile('*.TXA','IdeaList Print-File exportiern',Path,Name) THEN
             APPEND(Name,Path);
             OpenOutput(Path);
             IF Done THEN
                BusyMouse;
                TreeOut(VokabelExport.IdeaList);
             END(*IF*);
             CloseOutput;
             ArrowMouse;
      END(*IF*);
     END(*IF*);
   END(*IF*);
END DoExportIdeaList;



PROCEDURE DoSavePrefs(Menu : TreePtr; Title: ObjectIndex);
BEGIN
  IF OK(REALSAVE) THEN
  (* Not yet implemented *)
  OpenOutput('DICI.INF');
  IF IsSelected(CLIPPREF,SCRPASC) THEN  
     WriteString('SCRAP.ASC');
  ELSE    
     WriteString('SCRAP.TXT');
  END(*IF*);
  CloseOutput;
  END(*IF*);
END DoSavePrefs;

PROCEDURE DoHelp(Menu : TreePtr; Title : ObjectIndex);
BEGIN
   IF ~ GetHelp.CallSTGuide(ApplId,'DICI.HYP','Inhalt') THEN
       Alert(NOSTGUID);
   END(*IF*);
END DoHelp;



PROCEDURE DoClipboardPrefs(Menu: TreePtr; Title: ObjectIndex);
VAR r :INTEGER;
BEGIN
   r:=(DoForm(Menu,Title,CLIPPREF,0));
   IF r = SCRPHELP THEN
    IF ~ GetHelp.CallSTGuide(ApplId,'DICI.HYP','Clipboard') THEN
       Alert(NOSTGUID);
    END(*IF*);
   END(*IF*);
END DoClipboardPrefs;

PROCEDURE DoWarnings(Menu: TreePtr; Title: ObjectIndex);
VAR r :INTEGER;
BEGIN
   r:=(DoForm(Menu,Title,WARNDIAL,0));
   IF r = HELPWARN THEN
    IF ~ GetHelp.CallSTGuide(ApplId,'DICI.HYP','Warnmeldungen') THEN
       Alert(NOSTGUID);
    END(*IF*);
   END(*IF*);
END DoWarnings;

PROCEDURE DoPreferences(Menu: TreePtr; Title: ObjectIndex);
VAR r : INTEGER;
BEGIN
    r:=(DoForm(Menu,Title,PREFEREN,0));
    IF r = HELPPREF THEN
      IF ~ GetHelp.CallSTGuide(ApplId,'DICI.HYP','Edieren') THEN
         Alert(NOSTGUID);
      END(*IF*);
    END(*IF*);
END DoPreferences;

PROCEDURE DoExImPrefs(Menu :TreePtr; Title : ObjectIndex);
VAR r : INTEGER;
BEGIN
   r:= DoForm(Menu,Title,EXIMDIAL,0);
   IF r = HELPEI THEN
   IF ~ GetHelp.CallSTGuide(ApplId,'DICI.HYP','Ex- & Import') THEN
       Alert(NOSTGUID);
   END(*IF*);
   END(*IF*);
END DoExImPrefs;

PROCEDURE DoPrinterPrefs(Menu : TreePtr; Title : ObjectIndex);
VAR Path , Name : ARRAY [0..127] OF CHAR;
    PrnStr : String;
    Return : INTEGER;
BEGIN
    Path :='';Name:='PRINTER.CFG';
    Return:=DoForm(Menu,Title,PRNDIAL,0);
    CASE Return OF
         OKPRN    : ;
         |HELPPRN :  IF ~ GetHelp.CallSTGuide(ApplId,'DICI.HYP','Drucker') THEN
                           Alert(NOSTGUID);
                       END(*IF*);
         |CNCLPRN : ;
         |LOADCFG : IF GetPathAndFile('*.CFG',' Druckertreiber laden: ',Path,Name) THEN
                        APPEND(Name,Path); ASSIGN(Name,PrnStr);
                        SetObject.String(GetTreePtr(PRNDIAL),DRUCKERT,PrnStr);
			IF IsSelected(PRNDIAL,RS232) THEN
			   ConfigPrinter(2,Path,'_');
			ELSIF IsSelected(PRNDIAL,PRNPORT) THEN
			   ConfigPrinter(3,Path,'_');
			ELSIF IsSelected(PRNDIAL,PRNFILE) THEN
			   ConfigPrinter(1,Path,'_');
			END(*IF*);
		   END(*IF*);	
    ELSE
    ;
    END(*CASE*);
END DoPrinterPrefs;

PROCEDURE ClearStr(VAR String : ARRAY OF CHAR);
(* String komplett lîschen => alle zeichen als 0C setzten *)
VAR i : INTEGER;
BEGIN
   FOR i:=0 TO HIGH(String) DO
       String[i] :=0C;
   END(*FOR*);
END ClearStr;

PROCEDURE DoBrowse(Menu : TreePtr; Title : ObjectIndex);
BEGIN
 IF DataBaseOpen THEN
    IF BrowsePrefs(Menu, Title) THEN 
	DoOpenTerminal;
	BusyMouse;
	TreeOut(BrowseProc);
	ArrowMouse;
    END(*IF*);
 ELSE
   DoOpen(Menu,Title);
 END(*IF*);
END DoBrowse;

PROCEDURE DoPrint(Menu : TreePtr; Title : ObjectIndex);
VAR f : FileSystem.File;
    nlq,done : BOOLEAN;
    Style : ObjectPtr;
    PrnStyle, Lines : INTEGER;
    Tree : TreePtr;
    LineStr : String;
    Path , Name : ARRAY [0..127] OF CHAR;
BEGIN
 IF DataBaseOpen THEN
  IF S.geladen THEN
   IF BrowsePrefs(Menu, Title) THEN 
    Path :='';Name:='NONAME.PRN';

    nlq:=GetPopUpEntry(POPUPNLQ,PRNDIAL,DRAFTNLQ)=NLQ;
    Style:=GetPopUpEntry(POPUPSTY,PRNDIAL,PRNSTYLE);
    SetLQ(nlq);
    CASE Style OF
	     ITALIC   :  PrnStyle :=0AH;
	    |UNDERLIN :  PrnStyle :=1AH;
	    |PICA     :  PrnStyle :=28H;
	    |ELITE    :  PrnStyle :=2AH;
	    |CONDENSD :  PrnStyle :=2CH;
	    |EXPANDED :  PrnStyle :=2EH;
    ELSE
         PrnStyle:=28H;
    END(*CASE*);	
    Tree:= GetTreePtr(PRNDIAL);
    GetObject.String(Tree,FORMFEED,LineStr);
    StrToInt(LineStr,Lines,done);
    IF IsSelected(PRNDIAL,RS232) THEN
       PrintHandle(2);
    ELSIF IsSelected(PRNDIAL,PRNPORT) THEN
       PrintHandle(3);
    ELSIF IsSelected(PRNDIAL,PRNFILE) THEN
       IF GetPathAndFile('*.PRN',' Drucke in Datei: ',Path,Name) THEN
             APPEND(Name,Path);
             (*FileSystem.Lookup(f,Name, TRUE);*)
             FileSystem.Lookup(f,Path, TRUE);
             PrintHandle(f.fdesc);
	    (* done:=VokabelExport.InitPrinter(Lines,PrnStyle,nlq);*)
             IF f.errorno = 0 THEN
	     
	     BusyMouse;
             TreeOut(VokabelExport.PrintProc);
             FileSystem.Close(f);
             ArrowMouse;
             RETURN 
             
             ELSE 
	       Alert(PRNALERT);
               RETURN 
             END(*IF*);
       ELSE
          RETURN
       END(*IF*);
    END(*IF*);
    IF VokabelExport.InitPrinter(Lines,PrnStyle,nlq) THEN
       BusyMouse;
       TreeOut(VokabelExport.PrintProc);
       ArrowMouse;
    ELSE
       Alert(PRNALERT)
    END(*IF*);
   END(*IF*); (*BrowsePrefs*)
  ELSE
     (* Noch kein Druckertreiber geladen -> laden*)    
     DoPrinterPrefs(Menu,Title)
  END(*IF*);  
 ELSE
    DoOpen(Menu,Title);
 END(*IF*);
END DoPrint;

PROCEDURE DoRebuildIndex(Menu : TreePtr; Title : ObjectIndex);

VAR Path , Name : ARRAY [0..127] OF CHAR;
    Data : DataType;
    Keys : KeyArray;
    RecordCounter : DataPtr;

PROCEDURE ok( p : BOOLEAN);
BEGIN
   TermWindow.WriteString(Data.Inhalt[0]);
   IF p THEN
     TermWindow.WriteString(' EingefÅgt');
   ELSE
     TermWindow.WriteString(' Nicht EingefÅgt');
   END(*IF*);
   TermWindow.WriteLn;
END ok;
BEGIN
    DoClose(Menu,Title);
    Path :='';Name:='REBUILD.VBF';
    IF GetPathAndFile('*.VBF','Index wiederherstellen: ',Path,Name) THEN

        APPEND(Name,Path);
        ASSIGN(Path,DataBase.Name);
        DataBase.Type := TheData;
        DataBase.RecordSize := LONG(TSIZE(BaseType));
        ALLOCATE(DataBase.RecordPtr,TSIZE(BaseType));
        Start(DataBase); (* Datenbank îffnen *)
(*
        StripExtension(Path);APPEND('.GDX',Path);
        ASSIGN(Path,GIndex.Name);
        Create(GIndex); (* Index-Datei neu *)
        GIndex.MultipleKeys := TRUE;
        GIndex.Type := GerIndex;
        GIndex.RecordSize := LONG(TSIZE(PageType));
        ALLOCATE(GIndex.RecordPtr1,TSIZE(PageType));
        Start(GIndex); (* Indexdatei îffnen *)

        StripExtension(Path);APPEND('.NDX',Path);
        ASSIGN(Path,NIndex.Name);
        Create(NIndex); (* s.u. *)
        NIndex.MultipleKeys := FALSE;
        NIndex.Type := NumIndex;
        NIndex.RecordSize := LONG(TSIZE(PageType));
        ALLOCATE(NIndex.RecordPtr1,TSIZE(PageType));
        Start(NIndex);

        StripExtension(Path);APPEND('.PDX',Path);
        ASSIGN(Path,PIndex.Name);
        Create(PIndex); (* Datei lîschen und neu erzeugen *)
        PIndex.MultipleKeys := TRUE;
        PIndex.Type := PorIndex;
        PIndex.RecordSize := LONG(TSIZE(PageType));
        ALLOCATE(PIndex.RecordPtr1,TSIZE(PageType));
        Start(PIndex);
  *)
        LastKey := 0D;
        RecordCounter :=0D;
        DoOpenTerminal;
        BusyMouse;
        StripExtension(Path);APPEND('.ASC',Path);
        (* File fÅr den Export als ASCII-Datei îffnen *)
        OpenOutput(Path);
        IF Done THEN
             TermWindow.WriteString(' Datei wird als ');
             TermWindow.WriteString(Path);
             TermWindow.WriteString(' zum Re-Import geschrieben');
             TermWindow.WriteLn;
        ELSE
             TermWindow.WriteString(' Datei ');
             TermWindow.WriteString(Path);
             TermWindow.WriteString(' kann nicht geîffnet werden');
             CloseOutput;
             ArrowMouse;
             DoClose(Menu,Title);
             RETURN
        END(*IF*);
        (*Wait;*)
        WHILE RecordCounter <= DataBase.Last DO
            Get(DataBase,RecordCounter);
            Data := DataBase.RecordPtr^.Data;
            IF DataBase.RecordPtr^.Flag THEN
        (* Nur EintrÑge die nicht als gelîscht gekennzeichnet sind verwenden *)
            (*   IF IsSelected(PREFEREN,AUTOKEYS) THEN
                  Keys[PorIndex]:= MakeKey(Data.Inhalt[0]);
                  Keys[GerIndex]:= MakeKey(Data.Inhalt[1]);
                  LastKey:=LastKey+1D;
                  Keys[NumIndex] := LastKey;
               ELSE *)
                  Keys := DataBase.RecordPtr^.Key;
              (* END(*IF*);*)
               (* Irgendein wierd Error tritt hier auf. Anscheinend wird
                  immer nur die Wurzelseite beschrieben *)
    (*           ok(AddKey(NIndex, DataBase, Keys[NumIndex], RecordCounter));
               ok(AddKey(PIndex, DataBase, Keys[PorIndex], RecordCounter));
               ok(AddKey(GIndex, DataBase, Keys[GerIndex], RecordCounter));
      *)         (* Der Export und anschliessende Re-import funktioniert aber *)
               VokabelExport.StTrans(Data);
            ELSE
               WriteString('@');(*gelîschte EintrÑge werden mit einem @ gekennzeichnet*)
               VokabelExport.StTrans(Data); 
            END(*IF*);
            RecordCounter := RecordCounter+1D;
        END(*WHILE*);
        (*Last(NIndex,DataBase,LastKey,Data,Keys);*)
        DataBaseOpen := TRUE;
        WriteString('-----');   WriteLn;
        CloseOutput;
   (* weil die Datenbank nicht restauriert wird *)
        Close(DataBase);
        DataBaseOpen := FALSE;
   (* Datenbank wieder schlieûen  *)
        ArrowMouse;
     END(*IF*);
END DoRebuildIndex;



PROCEDURE SetPopUpEntry( PopUp, Dialog  : TreeIndex; PopUpParent, PopUpObject : ObjectPtr);
VAR First, Last : ObjectPtr;
    DialTree, PopUpTree : TreePtr;
    PopUpString,ParentString : StringPtr;
BEGIN
    DialTree:=GetTreePtr(Dialog);
    PopUpTree:=GetTreePtr(PopUp);
    First := GetObject.Head(PopUpTree,Root);
    Last := GetObject.Tail(PopUpTree,Root);
    IF (PopUpObject >= First) AND (PopUpObject <= Last)THEN
        PopUpString:=GetObject.StringPtr(PopUpTree,PopUpObject);
        ParentString:=GetObject.StringPtr(DialTree,PopUpParent);
        (* ASSIGN(PopUpString^,ParentString^); falsch !!!*)
        (* anscheinend ist es besser die POINTER umzubiegen *)
        SetObject.StringPtr(DialTree,PopUpParent,PopUpString);
    ELSE
        PopUpString:=GetObject.StringPtr(PopUpTree,First);
        SetObject.StringPtr(DialTree,PopUpParent,PopUpString);
    END(*IF*);
END SetPopUpEntry;

PROCEDURE FillDial(Data : DataType; Keys : KeyArray);
VAR KeyGer,KeyPor,KeyNum : String;
    Vokabel, Transl1, Transl2, Transl3, Transl4 : String;
    Tree : TreePtr;
    i : INTEGER;
    done : BOOLEAN;
BEGIN
   Tree := GetTreePtr(DIALTREE);
   ClearStr(KeyGer);ClearStr(KeyPor);ClearStr(KeyNum);
   LongCardToStr(Keys[NumIndex],10,KeyNum,done);
   ASSIGN(Data.Inhalt[0],Vokabel);
   ASSIGN(Data.Inhalt[1],Transl1); ASSIGN(Data.Inhalt[2],Transl2);
   ASSIGN(Data.Inhalt[3],Transl3); ASSIGN(Data.Inhalt[4],Transl4);
   Upper2LC.MakeString(Keys[PorIndex],KeyPor);
   Upper2LC.MakeString(Keys[GerIndex],KeyGer);
   SetObject.String(Tree,KEYNUM,KeyNum); (* SCHLöSSEL *)
   SetObject.String(Tree,KEYPOR,KeyPor);
   SetObject.String(Tree,KEYGER,KeyGer);
   SetObject.String(Tree,PORTUG,Vokabel); (* Vokabel *)
   SetObject.String(Tree,GERM1,Transl1); (* öbersetzungen *)
   SetObject.String(Tree,GERM2,Transl2);
   SetObject.String(Tree,GERM3,Transl3);
   SetObject.String(Tree,GERM4,Transl4);
   SetPopUpEntry(POPUPART,DIALTREE,VOKABEL,ORD(Data.Flags[0]));
   SetPopUpEntry(POPUPGEN,DIALTREE,NUMGENUS,ORD(Data.Flags[1]));
   SetPopUpEntry(POPUPSON,DIALTREE,SONSTIGS,ORD(Data.Flags[2]));
   SetPopUpEntry(POPUPMRK,DIALTREE,MARK,ORD(Data.Flags[3]));

END FillDial;

PROCEDURE AppendBlanks(VAR Str : ARRAY OF CHAR);
VAR i : INTEGER;
BEGIN
   WHILE SLEN(Str)<=6 DO
      APPENDCHR(' ',Str);
   END(*WHILE*);
END AppendBlanks;

PROCEDURE ReadDial(VAR Data : DataType; VAR KeyN,KeyP,KeyG : KeyType);
VAR KeyGer,KeyPor,KeyNum : String;
    Vokabel, Transl1, Transl2, Transl3, Transl4 : String;
    Tree : TreePtr;
    i : INTEGER;
    done : BOOLEAN;
BEGIN
    (* Erst mal alles was in den Strings steht rausschmeissen *)
    ClearStr(Vokabel); ClearStr(Transl1); ClearStr(Transl2);
    ClearStr(Transl3); ClearStr(Transl4);
    ClearStr(KeyGer);ClearStr(KeyPor);ClearStr(KeyNum);
    FOR i:=0 TO 4 DO
       ClearStr(Data.Inhalt[i]);
    END(*FOR*);
    (* Strings mit dem Inhalt aus dem Dialog fÅllen *)
    Tree:= GetTreePtr(DIALTREE);
    GetObject.String(Tree,KEYNUM,KeyNum);
    GetObject.String(Tree,KEYPOR,KeyPor);
    GetObject.String(Tree,KEYGER,KeyGer);
    GetObject.String(Tree,PORTUG,Vokabel);
    GetObject.String(Tree,GERM1,Transl1);
    GetObject.String(Tree,GERM2,Transl2);
    GetObject.String(Tree,GERM3,Transl3);
    GetObject.String(Tree,GERM4,Transl4);
    (* Blanks anhÑngen zwecks Eindeutigkeit des SchlÅssels *)
    AppendBlanks(Vokabel); AppendBlanks(Transl1);
    IF IsSelected(PREFEREN,AUTOKEYS) THEN
   (* SchlÅssel selbstÑndig aus Eintrag erechnen *)
       ASSIGN(Vokabel,KeyPor);
       ASSIGN(Transl1,KeyGer);
       Atari2Ascii.CorkConvert(KeyPor); (* Sonderzeichen ÑîÅÄ°ê.. nach aouCiE... *)
       Atari2Ascii.CorkConvert(KeyGer);
       UPPER(KeyPor); UPPER(KeyGer); (* Groûbuchstaben ! *)
   ELSE (* SchlÅssel so wie sie in der Maske stehen Åbernehmen *)
       IF IsSelected(PREFEREN,MISSINGK) THEN
       (* Fehlende SchlÅssel ergÑnzen *)
          IF SLEN(KeyPor)=0 THEN
             ASSIGN(Vokabel,KeyPor);Atari2Ascii.CorkConvert(KeyPor);UPPER(KeyPor);
          END(*IF*);
          IF SLEN(KeyGer)=0 THEN
             ASSIGN(Transl1,KeyGer);Atari2Ascii.CorkConvert(KeyGer);UPPER(KeyGer);
          END(*IF*);
          IF SLEN(KeyNum)=0 THEN
             LongCardToStr(LastKey+1D,10,KeyNum,done);
          END(*IF*);
       END(*IF*);
   END(*IF*);
   StrToLongCard(KeyNum,KeyN,done);
   (* Die RÅckgabe ist nur beim Suchen nach dem numerischen SchlÅssel relevant *)
   (* Aus dem Eintrag SchlÅssel (LONGCARD) erechnen *)
   KeyP:= Upper2LC.MakeLongCard(KeyPor);
   KeyG:= Upper2LC.MakeLongCard(KeyGer);
   ASSIGN(Vokabel,Data.Inhalt[0]);
   ASSIGN(Transl1,Data.Inhalt[1]);
   ASSIGN(Transl2,Data.Inhalt[2]);
   ASSIGN(Transl3,Data.Inhalt[3]);
   ASSIGN(Transl4,Data.Inhalt[4]);
   Data.Flags[0]:=CHR(GetPopUpEntry(POPUPART,DIALTREE,VOKABEL));
   Data.Flags[1]:=CHR(GetPopUpEntry(POPUPGEN,DIALTREE,NUMGENUS));
   Data.Flags[2]:=CHR(GetPopUpEntry(POPUPSON,DIALTREE,SONSTIGS));
   Data.Flags[3]:=CHR(GetPopUpEntry(POPUPMRK,DIALTREE,MARK));
END ReadDial;

PROCEDURE WriteScrap;
VAR ScrpDir : ARRAY [0..127] OF CHAR;
    Data : DataType;
    ret : Scrap;
    k : KeyType;
    i : INTEGER;
BEGIN
    ret := ScrpRead(ScrpDir);
    (*IF ScTXT IN ret THEN *)
    IF IsSelected(CLIPPREF,SCRPASC) THEN
        APPEND('SCRAP.ASC',ScrpDir);
    ELSE
        APPEND('SCRAP.TXT',ScrpDir);
    END(*IF*);
    ScrpClear;
    ReadDial(Data,k,k,k);
    OpenOutput(ScrpDir);
    IF Done THEN
      FOR i:=0 TO HIGH(Data.Inhalt) DO
         WriteString(Data.Inhalt[i]);
         WriteLn;
      END(*FOR*);
    END(*IF*);
    CloseOutput;
END WriteScrap;

PROCEDURE ReadScrap;
VAR ScrpDir : ARRAY [0..127] OF CHAR;
    Data : DataType;
    ret : Scrap;
    k : KeyArray;
    i : INTEGER;
BEGIN
    ret := ScrpRead(ScrpDir);
    IF ScTXT IN ret THEN
        APPEND('SCRAP.TXT',ScrpDir);
    ELSIF ScASC IN ret THEN
        APPEND('SCRAP.ASC',ScrpDir);
    ELSE
        RETURN
    END(*IF*);
    OpenInput(ScrpDir);
    FOR i:=0 TO HIGH(Data.Inhalt) DO
      ClearStr(Data.Inhalt[i]);
      IF Done THEN
         ReadLine(Data.Inhalt[i]);
      END(*IF*);
    END(*FOR*);
    CloseInput;
    IF (SLEN(Data.Inhalt[0]) > 0) AND (SLEN(Data.Inhalt[1]) = 0)  THEN
        Data.Inhalt[1]:=Data.Inhalt[0]
    END(*IF*);
    k[PorIndex]:=0D; k[GerIndex]:=0D; k[NumIndex]:=0D;
    FOR i:=0 TO HIGH(Data.Flags) DO
      Data.Flags:=0C;
    END(*FOR*);
    FillDial(Data,k);
END ReadScrap;

PROCEDURE Find;
VAR Index : FileOf;
    Keys : KeyArray;
    Key : KeyType;
    Data : DataType;
BEGIN

    ReadDial(Data,Keys[NumIndex],Keys[PorIndex],Keys[GerIndex]);
    IF IsSelected(DIALTREE,KEYPOR) THEN
       Index := PIndex;
       Key:=Keys[PorIndex];
    ELSIF IsSelected(DIALTREE,KEYNUM) THEN
       Index := NIndex;
       Key:=Keys[NumIndex];
    ELSIF IsSelected(DIALTREE,KEYGER) THEN
       Index := GIndex;
       Key:=Keys[GerIndex];
    END(*IF*);
    IF SearchFirst(Index,DataBase,Key,Data, Keys) THEN
       FillDial(Data,Keys)
    ELSE
       Alert(NOTFOUND);
       FillDial(Data,Keys)
    END(*IF*);
END Find;

PROCEDURE GetFirst;
VAR Index : FileOf;
    Keys : KeyArray;
    Key : KeyType;
    Data : DataType;
BEGIN

   IF IsSelected(DIALTREE,KEYPOR) THEN
       Index := PIndex;
       Key:=Keys[PorIndex];
    ELSIF IsSelected(DIALTREE,KEYNUM) THEN
       Index := NIndex;
       Key:=Keys[NumIndex];
    ELSIF IsSelected(DIALTREE,KEYGER) THEN
       Index := GIndex;
       Key:=Keys[GerIndex];
    END(*IF*);
    First(Index,DataBase,Key,Data,Keys);
    FillDial(Data,Keys)

END GetFirst;

PROCEDURE GetLast;
VAR Index : FileOf;
    Keys : KeyArray;
    Key : KeyType;
    Data : DataType;
BEGIN

   IF IsSelected(DIALTREE,KEYPOR) THEN
       Index := PIndex;
       Key:=Keys[PorIndex];
    ELSIF IsSelected(DIALTREE,KEYNUM) THEN
       Index := NIndex;
       Key:=Keys[NumIndex];
    ELSIF IsSelected(DIALTREE,KEYGER) THEN
       Index := GIndex;
       Key:=Keys[GerIndex];
    END(*IF*);
    Last(Index,DataBase,Key,Data,Keys);
    FillDial(Data,Keys)

END GetLast;

PROCEDURE GetNext;
VAR Index : FileOf;
    Keys : KeyArray;
    Key : KeyType;
    Data : DataType;
BEGIN
   ReadDial(Data,Keys[NumIndex],Keys[PorIndex],Keys[GerIndex]);
   IF IsSelected(DIALTREE,KEYPOR) THEN
       Index := PIndex;
       Key:=Keys[PorIndex];
    ELSIF IsSelected(DIALTREE,KEYNUM) THEN
       Index := NIndex;
       Key:=Keys[NumIndex];
    ELSIF IsSelected(DIALTREE,KEYGER) THEN
       Index := GIndex;
       Key:=Keys[GerIndex];
    END(*IF*);
    IF Next(Index,DataBase,Key,Key,Data,Keys) THEN
       FillDial(Data,Keys)
    ELSE
       GetFirst;
    END(*IF*);
END GetNext;

PROCEDURE GetPrevious;
VAR Index : FileOf;
    Keys : KeyArray;
    Key : KeyType;
    Data : DataType;
BEGIN
    ReadDial(Data,Keys[NumIndex],Keys[PorIndex],Keys[GerIndex]);
    IF IsSelected(DIALTREE,KEYPOR) THEN
       Index := PIndex;
       Key:=Keys[PorIndex];
    ELSIF IsSelected(DIALTREE,KEYNUM) THEN
       Index := NIndex;
       Key:=Keys[NumIndex];
    ELSIF IsSelected(DIALTREE,KEYGER) THEN
       Index := GIndex;
       Key:=Keys[GerIndex];
    END(*IF*);
    IF Previous(Index,DataBase,Key,Key,Data,Keys) THEN
       FillDial(Data,Keys)
    ELSE
       GetLast;
    END(*IF*);
END GetPrevious;

PROCEDURE ChangeEntry;
VAR BaseKeys, DialKeys : KeyArray;
    Data : DataType;
    Reference : DataPtr;
    done : BOOLEAN;
BEGIN
   Reference:=DataBase.Current;
   IF IsSelected(WARNDIAL,QUCHANGE) THEN
      IF ~OK(EDALERT) THEN RETURN
      END(*IF*);
   END(*IF*);
   GetData(DataBase,Data,BaseKeys,Reference);
   ReadDial(Data,DialKeys[NumIndex],DialKeys[PorIndex],DialKeys[GerIndex]);
   IF IsSelected(PREFEREN,KEYCHANG) THEN
      (* Alte SchlÅssel lîschen wenn Sie # neuen SchlÅsseln *)
      (* Neue SchlÅssel einfÅgen *)
      IF BaseKeys[NumIndex]#DialKeys[NumIndex] THEN
         done:=Delete(NIndex,DataBase,BaseKeys[NumIndex],Reference);
         done:=AddKey(NIndex,DataBase,DialKeys[NumIndex],Reference);
      END(*IF*);
      IF BaseKeys[PorIndex]#DialKeys[PorIndex] THEN
         done:=Delete(PIndex,DataBase,BaseKeys[PorIndex],Reference);
         done:=AddKey(PIndex,DataBase,DialKeys[PorIndex],Reference);
      END(*IF*);
      IF BaseKeys[GerIndex]#DialKeys[GerIndex] THEN
         done:=Delete(GIndex,DataBase,BaseKeys[GerIndex],Reference);
         done:=AddKey(GIndex,DataBase,DialKeys[GerIndex],Reference);
      END(*IF*);
   END(*IF*);
   IF IsSelected(PREFEREN,NOKEYCHG) THEN
      (* Alte SchlÅssel werden beibehalten was auch im Eintrag steht *)
      done := TRUE; (* Nichts zu tun *)
   END(*IF*);
   IF IsSelected(PREFEREN,KEYQUERY) THEN
      (*IF ~OK() THEN RETURN
      END(*IF*);*)
      (* Nachfragen ob neue SchlÅssel verwendet werden sollen *)
      done := TRUE;;; (* Not yet implemented *)
   END(*IF*);
   PutData(DataBase,Data,Reference);
END ChangeEntry;

PROCEDURE DeleteEntry;
VAR Data : DataType;
    Keys : KeyArray;
    Reference : DataPtr;
    done : BOOLEAN;
BEGIN
   IF IsSelected(WARNDIAL,QUDELETE) THEN
      IF ~OK(DELALERT) THEN RETURN (* Nachfragen ob wirklich gelîscht werden soll *)
      END(*IF*);
   END(*IF*);
   Reference := DataBase.Current;
   GetData(DataBase,Data,Keys,Reference);
   IF Delete(NIndex,DataBase,Keys[NumIndex],Reference) THEN
      done :=Delete(PIndex,DataBase,Keys[PorIndex],Reference);
      IF done THEN
         done := (done AND Delete(GIndex,DataBase,Keys[GerIndex],Reference));
      END(*IF*);
   ELSE
      done := FALSE
   END(*IF*);
   IF ~done THEN
      Alert(NOTDELET)
   END(*IF*);
END DeleteEntry;

PROCEDURE NewEntry;
VAR done : BOOLEAN;
    MyKeyN,MyKeyP,MyKeyG : KeyType;
    Data : DataType;
    DataReference : DataPtr;
BEGIN
   IF IsSelected(WARNDIAL,QUCHANGE) THEN
    (* Wenn gar nicht eingefÅgt werden soll kann ich mir den Rest auch
       sparen *)
       IF ~OK(NEWALERT) THEN
           RETURN
       END(*IF*);
   END(*IF*);

   ReadDial(Data,MyKeyN,MyKeyP,MyKeyG);
   DataReference:=AddData(DataBase,Data);
   IF IsSelected(PREFEREN,AUTONKEY) THEN
       (* Numerischer SchlÅssel automatisch *)
          LastKey :=LastKey+1D;
          MyKeyN:=LastKey;
        ELSE
        (* Numerischen SchlÅssel aus Feld *)
        (* wird zurÅckgegeben von ReadDial *)
   END(*IF*);
   IF IsSelected(PREFEREN,MISSINGK) AND (MyKeyN = 0D) THEN
       LastKey :=LastKey+1D;
       MyKeyN:=LastKey;
   END(*IF*);
   IF AddKey(NIndex,DataBase,MyKeyN,DataReference) THEN
      done := AddKey(PIndex,DataBase,MyKeyP,DataReference);
      done := AddKey(GIndex,DataBase,MyKeyG,DataReference);
   ELSE
      DataBase.Last := DataBase.Last-1D;
      Alert(KEYALERT)
   END(*IF*);
END NewEntry;

PROCEDURE DoEdit(Menu: TreePtr; Title: ObjectIndex);
VAR Tree     : TreePtr;
    From,To  : GRect;
    ToDo     : GRect;
    Return: SIGNEDWORD;
    Str1Ptr,Str2Ptr,Str3Ptr : StringPtr;
    KeyGer,KeyPor,KeyNum : String;
    Vokabel, Transl1, Transl2, Transl3, Transl4 : String;
    ch : CHAR;
    StGuiOK : BOOLEAN;
    FirstObject : ObjectIndex;
BEGIN
 IF ACC THEN
    ReOpen;
    IF ~DataBaseSelected THEN
        RETURN 
    END(*IF*);    
 END(*IF*);   
 IF DataBaseOpen THEN
  ObjectXYWH(Menu,Title,From);
  Tree:= GetTreePtr(DIALTREE);
  (* String-Pointer der PopUps retten *)
  Str1Ptr:=GetObject.StringPtr(Tree,VOKABEL);
  Str2Ptr:=GetObject.StringPtr(Tree,NUMGENUS);
  Str3Ptr:=GetObject.StringPtr(Tree,SONSTIGS);
  KeyNum:='0000000000';  KeyPor:='      ';  KeyGer:='      ';
  Vokabel:='';
  ClearStr(Transl1);(*:='';*) Transl2:=''; Transl3:=''; Transl4:='';
  SetObject.String(Tree,KEYNUM,KeyNum);
  SetObject.String(Tree,KEYPOR,KeyPor);
  SetObject.String(Tree,KEYGER,KeyGer);
  SetObject.String(Tree,PORTUG,Vokabel);
  SetObject.String(Tree,GERM1,Transl1);
  SetObject.String(Tree,GERM2,Transl2);
  SetObject.String(Tree,GERM3,Transl3);
  SetObject.String(Tree,GERM4,Transl4);
  FormCenter(Tree,To);
  BeginUpdate;
  FormDial(FmDStart,To,To);
  FormDial(FmDGrow,From,To);
  ObjcDraw(Tree,Root,MaxDepth,To);
  REPEAT
       FirstObject := PORTUG;
       IF IsSelected(DIALTREE,KEYPOR) THEN
           FirstObject := PORTUG;
       ELSIF IsSelected(DIALTREE,KEYNUM) THEN
           FirstObject := KEYNUM;
       ELSIF IsSelected(DIALTREE,KEYGER) THEN
           FirstObject := GERM1;
       END(*IF*);
       ObjectXYWH(Tree,KPARENT,ToDo); ObjcDraw(Tree,KPARENT,MaxDepth,ToDo);
       ObjectXYWH(Tree,VPARENT,ToDo); ObjcDraw(Tree,VPARENT,MaxDepth,ToDo);
       ObjectXYWH(Tree,UEPARENT,ToDo); ObjcDraw(Tree,UEPARENT,MaxDepth,ToDo);
       Return:= Mask(FormDo(Tree,FirstObject));
       CASE Return OF
             FIND   : Find;
           | NEXT   : GetNext;
           | PREV   : GetPrevious;
           | FIRST  : GetFirst;
           | LAST   : GetLast;
           | CHANGE : ChangeEntry;
           | NEW    : NewEntry;
           | DEL    : DeleteEntry;
           | CLIP   : WriteScrap;
           | CLIPREAD : ReadScrap;
           | HELP   : IF ~ ACC THEN 
                          StGuiOK:=GetHelp.CallSTGuide(ApplId,'DICI.HYP','Edieren')
                      ELSE 
                          StGuiOK:=GetHelp.CallSTGuide(ApplId,'DICI.HYP','Accessory')
                      END(*IF*); 
                      IF ~StGuiOK THEN    
                           Alert(NOSTGUID);
                      END(*IF*);
       ELSE
       ;
       END(*CASE*);
       FormCenter(Tree,To);
       ObjcChange(Tree,Return,1,To,GetObject.State(Tree,Return) - ObjectState{Selected},TRUE);
  UNTIL (Return = OKDIAL) OR (Return = HELP);
  FormDial(FmDShrink,From,To);
  FormDial(FmDFinish,To,To);
  EndUpdate;
  ArrowMouse;
  (* String Pointer fÅr die Pop-Up's wieder rÅcksetzten *)
  SetObject.StringPtr(Tree,VOKABEL,Str1Ptr);
  SetObject.StringPtr(Tree,NUMGENUS,Str2Ptr);
  SetObject.StringPtr(Tree,SONSTIGS,Str3Ptr);
 ELSE
    DoOpen(Menu,Title);
 END(*IF*);
 IF ACC THEN
    ReClose;
 END(*IF*); 
END DoEdit;

PROCEDURE DoInfo(Menu: TreePtr; Title: ObjectIndex);
VAR Ret: ObjectIndex;
BEGIN
  VOID(DoForm(Menu,Title,INFODIAL,0));
END DoInfo;


PROCEDURE DoMenu(Title: ObjectIndex; Item: ObjectIndex);
BEGIN
  ArrowMouse;
  MenuAction(MyMenu,Title,Item);
  MenuTNormal(MyMenu,Title,TRUE);
END DoMenu;

PROCEDURE EventLoop;

VAR EventBlock: MEvent;
    MyEvent   : Event;
    MyMessage : MessageBlock;
    Clicks    : UNSIGNEDWORD;
    TerminalEvent : POINTER TO Application.messagetype;
    Cmd,Tail : ARRAY [0..127] OF CHAR;

PROCEDURE AccLoop;
BEGIN
    WITH MyMessage DO
      LOOP
        MyEvent:= EvntEvent(EventBlock);
        IF MuMesag IN MyEvent THEN
          IF Type = AcOpen  THEN 
             DoEdit(MyMenu,ABOUT);
          END(*IF*);
        END(*IF*);
      END(*LOOP*);
    END(*WITH*);
END AccLoop;    


BEGIN
  WITH EventBlock DO
    EFlags:= Event{MuKeybd,MuMesag,MuButton};
    EMePBuf:= PTR(MyMessage);
    EBClk:= 2;
    EBMsk:= MouseButton{MBLeft};
    EBSt:= MouseButton{MBLeft};
    IF ACC THEN
       AccLoop; 
    ELSE 
       DoInfo(MyMenu,DESK);
       ShelRead(Cmd,Tail);
       DELETE(0,1,Tail);
       OpenDataBase(Tail);
    END(*IF*);
    WITH MyMessage DO
      LOOP
        MyEvent:= EvntEvent(EventBlock);

        IF MuMesag IN MyEvent THEN
          CASE Type OF
           WMRedraw .. WMTopped, WMFulled .. WMOffTop :
              TerminalEvent := PTR(MyMessage);
              TermWindow.ReactOnMessage(TerminalEvent^);
          | WMClosed,ApTerm:
               TerminalEvent := PTR(MyMessage);
               TermWindow.CloseTerminal;
               TerminalWindowOpen:= FALSE;
          | MnSelected:
              DoMenu(Title,Item);
          | ApDragDrop:
              ;
          ELSE
            ;
          END;
        END;

        IF MuButton IN MyEvent THEN
          ;
        END;

        IF MuKeybd IN MyEvent THEN
          (* IF Type =  THEN
             DoHelp(EXTRAS,HELPME);
          END(*IF*);*)
          
        END;
        
        IF (Type = MnSelected) AND (Item = QUIT) THEN
         IF OK(REALQUIT) THEN
            EXIT;
           ELSE
            Type:= ApMsg;
          END;
        END;

      END;
    END;
  END;
END EventLoop;

PROCEDURE RsrcAction(Dummy: ARRAY OF CHAR): BOOLEAN;
BEGIN
  (* initialize menu actions *)

  MyMenu:= GetTreePtr(MENUTREE);

  NewMenuAction(MyMenu,ABOUT,DoInfo);

  NewMenuAction(MyMenu,QUIT,DoNothing);
  NewMenuAction(MyMenu,CLOSE,DoClose);
  NewMenuAction(MyMenu,OPEN,DoOpen);
  NewMenuAction(MyMenu,BEARBEIT,DoEdit);
  NewMenuAction(MyMenu,BROWSE,DoBrowse);
  NewMenuAction(MyMenu,PRINT,DoPrint);
  NewMenuAction(MyMenu,NEWFILE,DoCreate);

  NewMenuAction(MyMenu,LATEX,DoExportLaTeX);
  NewMenuAction(MyMenu,ESTTRANS,DoExportStTrans);
  NewMenuAction(MyMenu,EVOCMAN,DoExportVocMan);
  NewMenuAction(MyMenu,ISTTRANS,DoImportStTrans);
  NewMenuAction(MyMenu,IVOCMAN,DoImportVocMan);
  NewMenuAction(MyMenu,IDEALIST,DoExportIdeaList);

  NewMenuAction(MyMenu,HELPME,DoHelp);
  NewMenuAction(MyMenu,REBUILDI,DoRebuildIndex);
  NewMenuAction(MyMenu,VOREINST,DoPreferences);
  NewMenuAction(MyMenu,EIPREFER,DoExImPrefs);
  NewMenuAction(MyMenu,PRNCONF,DoPrinterPrefs);
  NewMenuAction(MyMenu,CLIPBRD ,DoClipboardPrefs);
  NewMenuAction(MyMenu,SAVEPREF,DoSavePrefs);
  NewMenuAction(MyMenu,WARNINGS,DoWarnings);

  (* initialize other callbacks *)

  (* attch popups *)

  PopupAttach(GetTreePtr(POPUPART),GetTreePtr(DIALTREE),VOKABEL );
  PopupAttach(GetTreePtr(POPUPGEN),GetTreePtr(DIALTREE),NUMGENUS );
  PopupAttach(GetTreePtr(POPUPSON),GetTreePtr(DIALTREE),SONSTIGS);
  PopupAttach(GetTreePtr(POPUPMRK),GetTreePtr(DIALTREE),MARK);
  PopupAttach(GetTreePtr(POPUPNLQ),GetTreePtr(PRNDIAL),DRAFTNLQ);
  PopupAttach(GetTreePtr(POPUPSTY),GetTreePtr(PRNDIAL),PRNSTYLE);

  RETURN TRUE;
END RsrcAction;

PROCEDURE AccRsrcAction(Dummy: ARRAY OF CHAR): BOOLEAN;
BEGIN
  (* attch popups *)
  (* ansonsten brauch ich keine Resourcen! *)
  (* Insbesondere die NewMenuAction's wÑren fÅr ein ACC verwirrend*)
  PopupAttach(GetTreePtr(POPUPART),GetTreePtr(DIALTREE),VOKABEL );
  PopupAttach(GetTreePtr(POPUPGEN),GetTreePtr(DIALTREE),NUMGENUS );
  PopupAttach(GetTreePtr(POPUPSON),GetTreePtr(DIALTREE),SONSTIGS);
  PopupAttach(GetTreePtr(POPUPMRK),GetTreePtr(DIALTREE),MARK);

  RETURN TRUE;
END AccRsrcAction;

BEGIN
  ApplId:= ApplInit();
  DataBaseOpen := FALSE;
  DataBaseSelected := FALSE;
  IF ApplId >= 0 THEN
    BeginUpdate;
    BusyMouse;
    IF Accessory() THEN
       AddRsrcLoad(AccRsrcAction);
    ELSE 
       AddRsrcLoad(RsrcAction);
    END(*IF*);
    IF RsrcLoad(RscName) THEN
      IF OpenVirtualWorkstation(VirtScreen) THEN
        MyMenu:= GetTreePtr(MENUTREE);
        TerminalWindowOpen:= FALSE;
        VOID(GrafHandle(CharWidth,CharHeight,BoxWidth,BoxHeight));
        IF Accessory() THEN
           ACC := TRUE;
           Register:="  Dicion†rio";
           VOID(MenuRegister(ApplId,Register));
           ArrowMouse;
           EndUpdate;
           EventLoop; (* Ist ein acc => niemals zu ende!*)
        ELSE 
           ACC:=FALSE    
        END(*IF*);
        InitScrap;
        ShowMenu(MyMenu);
        MinWidth:= 2 * BoxWidth;
        MinHeight:= 2 * BoxHeight;
        ArrowMouse;
        EndUpdate;
        TermWindow.InitTerminal(FALSE);
        TermWindow.NewTitle(" Dicion†rio ");
          EventLoop;
        TermWindow.CloseTerminal;
        TermWindow.DeleteTerminal;
        IF DataBaseOpen THEN
          (* fÅr den Fall das der Anwender die Datei nicht geschlossen hat*)
           DoClose(MyMenu,FILE);
        END(*IF*);
        HideMenu(MyMenu);
        CloseVirtualWorkstation(VirtScreen);
      ELSE
         (* Es konnte keine VirtualWorkstation eingerichtet werden *)
         Alert(NOVWORK);
      END;
      RsrcFree;
    ELSE
      EndUpdate;
    END;
    ApplExit;
  END;
END VOKABEL.
