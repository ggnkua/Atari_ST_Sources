(* Test-Programm zur graphischen Formeldarstellung  *)
(* von Marcus Grimm                                 *)
(*                                                  *)
(* Dieses Programm soll nur das Ergebnis des        *)
(* Formel-Interpreters veranschaulichen, die Gem-   *)
(* Programmierung ist entsprechend simpel gehalten. *)
(*                                                  *)
Program FormelTest;

USES GEMDECL,GEMAES,GEMVDI,GEM,TREE,FORMEL;

CONST {$I D:\MAXON.PAS\ARTIKEL\TESTPRG.I} (* Evtl. Anpassen... *)

Var WinHandle : Integer;
    WinTitle,RscPfad  : String;
    FormelHead : Formel_Graphik;
    AboutDia  : Dialog_Ptr; (* Info-Dialog *)
    InputDia  : Dialog_Ptr; (* Eingabe-Dialog *)
    MenueDia  : Dialog_Ptr; (* MenÅ-Baum *)
    d         : Integer;
    Message   : Array[0..15] Of Integer;
    Quit      : Boolean;

Procedure OpenWindow;(* Anzeige Fenster îffnen *)
Begin
 WinHandle:=Wind_Create(NAME,40,40,550,300);
 If WinHandle >= 0 Then (* Ok, alles klar *)
 Begin
  WinTitle:='FORMEL-AUSGABE :'+#0+#0;
  wind_set(WinHandle,WF_NAME,HiPtr(WinTitle[1]),LoPtr(WinTitle[1]),0,0);
  wind_open(WinHandle,40,40,550,300);
 End;
End;

Procedure RedrawWindow;(* Simple Redraw-Verwaltung       *)
Var Pts : Array_4;     (* Nicht zur Nachahme empfohlen ! *)
    xw,yw,bw,hw : Integer;
Begin
 Graf_Mouse(M_OFF,NIL);
 Wind_Get(WinHandle,WF_WORKXYWH,xw,yw,bw,hw);
 Pts[0]:=xw; Pts[1]:=yw;
 Pts[2]:=xw+bw-1; Pts[3]:=yw+hw-1;
 vsf_color(VDI_Handle,WHITE);
 vsf_style(VDI_Handle,SOLID);
 v_bar(VDI_Handle,Pts);
 vs_clip(VDI_Handle,1,Pts);
 If FormelHead.Formel <> NIL Then (* Formel zeichnen...  *)
 Begin
  Frame(xw+18,yw+18,FormelHead.Breite+4,FormelHead.HAbs+4);
  PlotFormelList(xw+20,yw+20,FormelHead);
 End;
 vs_clip(VDI_Handle,0,Pts);
 Graf_Mouse(M_ON,NIL);
End;

Procedure ShowAboutBox;(* Programm-Info *)
Var Btn : Integer;
Begin
 objc_draw(AboutDia,0,3,0,0,640,400);
 btn:=form_do(AboutDia,0);
 AboutDia^[Btn].Ob_State:=0;
 (* Folgendes veranlasst das Window-Redraw... *)
 Form_Dial(FMD_FINISH,0,0,0,0,AboutDia^[0].Ob_x,
                              AboutDia^[0].Ob_y,
                              AboutDia^[0].Ob_w,
                              AboutDia^[0].Ob_h);
End;

Procedure ShowError;(* Fehler Meldung *)
Var Txt : String;
    d   : Integer;
Begin
 Txt:='[3][|Die Eingabe war|fehlerhaft !][ABBRUCH]'+#0;
 d:=Form_Alert(1,Txt[1]);
End;

Procedure ShowInputBox;(* Eingabe der Formel *)
Var Btn,Err : Integer;
    FormelStr : String;
    FunktionPtr : FktPtr;
Begin
 objc_draw(InputDia,0,3,0,0,640,400);
 btn:=form_do(InputDia,FEINGAB);
 InputDia^[Btn].Ob_State:=0;
 Form_Dial(FMD_FINISH,0,0,0,0,InputDia^[0].Ob_x,
                              InputDia^[0].Ob_y,
                              InputDia^[0].Ob_w,
                              InputDia^[0].Ob_h);
 If Btn = FINOK Then(* Formel erzeugen *)
 Begin
  ReadTe_PText(InputDia,FEINGAB,FormelStr); (* String lesen *)
  FunktionPtr:=MakeTree(FormelStr,Err);     (* Baum erzeugen *)
  If Err = 0 Then (* Ok, Formel in Ordnung... *)
  Begin
   If FormelHead.Formel <> NIL Then 
    DelFormelList(FormelHead); (* Evtl. alte Liste lîschen *)
   MakeFormelList(FunktionPtr,FormelHead);(* Liste erzeugen *)
  End
  Else ShowError;
  DeleteTree(FunktionPtr);(* Baum lîschen *)
 End;
End;

Begin
 If Init_Gem Then
 Begin
  FormelHead.Formel:=NIL;
  RscPfad:='TESTPRG.RSC'+#0;
  rsrc_load(RscPfad[1]);(* Auf eine öberprÅfung wird verzichtet... *)
  rsrc_gaddr(R_TREE,MENUE,MenueDia);
  rsrc_gaddr(R_TREE,FINPUT,InputDia);
  rsrc_gaddr(R_TREE,ABOUT,AboutDia);
  form_center(InputDia,d,d,d,d);
  form_center(AboutDia,d,d,d,d);
  Menu_Bar(MenueDia,1);
  OpenWindow;
  Quit:=FALSE;
  Repeat
   evnt_mesag(Message);
   Case Message[0] Of
    MN_SELECTED : Begin
                   Case Message[4] Of
                    MQUIT : Quit:=True;
                    MABOUT : ShowAboutBox;
                    MEINGAB : ShowInputBox;
                   End;
                   Menu_TNormal(MenueDia,Message[3],1);
                  End;
    WM_REDRAW   : If Message[3] = WinHandle Then
                   RedrawWindow;
   End;
  Until Quit;
  Wind_Close(WinHandle);
  Wind_Delete(WinHandle);
  rsrc_free;
  EndGem;
 End;
End.
