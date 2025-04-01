(***********************************************)
(*                                             *)
(* Programm .....: TESTFORMDO                  *)
(* Version ......: 1.00                        *)
(* Autor ........: Thomas Krieger              *)
(* Erstellt .....: 01.08.92                    *)
(* GeÑndert .....: 05.08.92                    *)
(* Zweck ........: Demonstration von Dialog-   *)
(*                 boxen in Fenstern           *)
(*                                             *)
(***********************************************)

program TestFormDo;

uses GemDecl, GemAes, GemVdi, UtilAes, FormDoR;

const ADRESSE  = 0;   (* TREE *)
      ANREDE   = 2;   (* OBJECT in TREE #0 *)
      NAME1    = 4;   (* OBJECT in TREE #0 *)
      NAME2    = 6;   (* OBJECT in TREE #0 *)
      VORNAME  = 8;   (* OBJECT in TREE #0 *)
      STRASSE  = 10;  (* OBJECT in TREE #0 *)
      POSTF    = 12;  (* OBJECT in TREE #0 *)
      PLZ      = 14;  (* OBJECT in TREE #0 *)
      ORT      = 16;  (* OBJECT in TREE #0 *)
      TELEFON  = 18;  (* OBJECT in TREE #0 *)
      FAX      = 20;  (* OBJECT in TREE #0 *)
      PARTNER  = 22;  (* OBJECT in TREE #0 *)
      AKTION   = 23;  (* OBJECT in TREE #0 *)
      ABBRUCH  = 24;  (* OBJECT in TREE #0 *)
      MENU     = 1;   (* TREE *)
      MADRESSE = 17;  (* OBJECT in TREE #1 *)
      MENDE    = 16;  (* OBJECT in TREE #1 *)
      MABOUT   = 7;   (* OBJECT in TREE #1 *)
      ABOUT    = 2;   (* TREE *)
      
var ApplId, VdiHandle, i,
    dummy: Integer;
    
    AboutAdresse,        (* Adressen der *)
    MenuAdresse,         (* Objekte *)
    BaumAdresse: TreePtr;
    
    WorkIn: Intin_Array;
    WorkOut: WorkOut_Array;

(***********************************************)
(* Prozedur DoCopyright - Darstellen der Copy- *)
(*                        rightbox mit der neu-*)
(*                        en FormDo-Routine.   *)
(***********************************************)
   
   Procedure DoCopyright;
   var auswahl, 
       fenster,
       state,
       ox, wx,
       oy, wy,
       ow, ww,
       oh, wh: Integer;
       fenstertitel,
       nachricht: String;
   begin
      (* Ermitteln der Koordinaten der Dialogbox
         aus der Objektstruktur *)

      ox:= AboutAdresse^[0].o_x;
      oy:= AboutAdresse^[0].o_y;
      ow:= AboutAdresse^[0].o_w;
      oh:= AboutAdresse^[0].o_h;

      (* Berechnen des begrenzugsrechtecks *)
      
      wind_calc(WC_BORDER, NAME + MOVER, 
                           ox, oy, ow, oh, 
                           wx, wy, ww, wh);
      
      (* Besorgen des Fenster-Handles *)

      fenster:= wind_create(NAME + MOVER, wx,
                              wy, ww, wh);
      
      if
         fenster > 0 (* Fenster verfÅgabr ? *)
      then
      begin
         (* Das Fenster braucht einen namen *)

         fenstertitel:= ' Copyright '+#00+#00;
         
         (* Bildschirmausschnitt reservieren
            und wachsendes rechteck zeichnen *)

         form_dial(0,0,0,0,0,ox,oy,ow,oh);
         form_dial(1,0,0,0,0,ox,oy,ow,oh);

         (* Fenstername eintragen *)
         
         wind_set(fenster,WF_NAME, 
                          HiPtr(FensterTitel[1]), 
                          LoPtr(FensterTitel[1]),
                          0, 0);

         (* Fenster îffnen und zeichnen der
            Dialogbox *)
         
         wind_open(fenster, wx, wy, ww, wh);         
         objc_draw(AboutAdresse, 0, 8, ox, oy,
                                    ow, oh);

         (* Verwalten der Dialogbox mit der
            neuen FormDo-Routine *)
         
         auswahl := FormDo(ApplId, fenster,
                           AboutAdresse, 0);

         (* Selektiertes Objekt zurÅcksetzen *)

         state:= obj_getstate(AboutAdresse,
                              auswahl);
         state:= state XOR SELECTED;
         obj_setstate(AboutAdresse, auswahl,
                                    state);
         
         (* Schrumpfendes Rechteck zeichnen und
            reservierten Bildschirmbereich wieder
            freigeben *)

         form_dial(2,0,0,0,0,ox,oy,ow,oh);
         form_dial(3,0,0,0,0,ox,oy,ow,oh);

         (* Fenster schlieûen und Handle
            freigeben *)
         
         wind_close(fenster);
         Wind_delete(fenster);
      end
      else  (* Es ist kein Fenster frei *)
      begin (* ==>> Fehlermeldung *)
         nachricht:='[3][Kein Fenster!| ][ OK ]';
         
         auswahl:= form_alert(1, nachricht[1]);
      end;
   end;

(***********************************************)
(* Prozedur DoAdersse - Darstellen der Adressen*)
(*                      Maske mit der neuen    *)
(*                      FormDo-Routine.        *)
(***********************************************)

   
   Procedure DoAdresse;
   var auswahl, 
       fenster,
       state,
       ox, wx,
       oy, wy,
       ow, ww,
       oh, wh: Integer;
       fenstertitel,
       nachricht,
       maske,
       pr: String;
   begin
      (* Ermitteln der Koordinaten der Dialogbox
         aus der Objektstruktur *)

      ox:= BaumAdresse^[0].o_x;
      oy:= BaumAdresse^[0].o_y;
      ow:= BaumAdresse^[0].o_w;
      oh:= BaumAdresse^[0].o_h;

      (* Berechnen des Begrenzungerechtecks
         des Fensters *)
      
      wind_calc(WC_BORDER, NAME + MOVER, 
                           ox, oy, ow, oh, 
                           wx, wy, ww, wh);

      (* Windowhandle besorgen *)
      
      fenster:= wind_create(NAME + MOVER,    
                            wx, wy, ww, wh);
      
      if
         fenster > 0 (* Alles klar, es ist ein
                        Fenster frei *)
      then
      begin
         (* Das Fenster braucht einen Titel *)

         FensterTitel:= ' Adressen verwalten ' +
                          #00 + #00;
         
         (* Bildschirmbereich reservieren und ein
            wachsendes Rechteck zeichnen *)

         form_dial(0,0,0,0,0,ox,oy,ow,oh);
         form_dial(1,0,0,0,0,ox,oy,ow,oh);

         (* Fenstertitel eintragen *)
         
         wind_set(fenster,WF_NAME, 
                          HiPtr(FensterTitel[1]), 
                          LoPtr(FensterTitel[1]),
                          0, 0);

         (* Vorbelegen der Edit-Felder *)
                           
         maske:='______________________________';
         pr   :='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
         
         Set_Dedit(BaumAdresse, NAME1  , maske,
                             pr, '', 3, TE_LEFT);
         Set_Dedit(BaumAdresse, NAME2  , maske,
                             pr, '', 3, TE_LEFT);
         Set_Dedit(BaumAdresse, VORNAME, maske,
                             pr, '', 3, TE_LEFT);
         Set_Dedit(BaumAdresse, STRASSE, maske,
                             pr, '', 3, TE_LEFT);
         Set_Dedit(BaumAdresse, ORT    , maske,
                             pr, '', 3, TE_LEFT);
         Set_Dedit(BaumAdresse, PARTNER, maske,
                             pr, '', 3, TE_LEFT);
         Set_Dedit(BaumAdresse, TELEFON, maske,
                             pr, '', 3, TE_LEFT);
         Set_Dedit(BaumAdresse, FAX    , maske,
                             pr, '', 3, TE_LEFT);
         
         maske:= '__________';
         pr   := 'XXXXXXXXXX';
         
         Set_Dedit(BaumAdresse, ANREDE, maske,
                             pr, '', 3, TE_LEFT);
         
         maske:= '________________';
         pr   := 'XXXXXXXXXXXXXXXX';
         
         Set_Dedit(BaumAdresse, POSTF, maske,
                             pr, '', 3, TE_LEFT);
         
         maske:= '________________';
         pr   := 'XXXXXXXXXXXXXXXX';
         
         Set_Dedit(BaumAdresse, PLZ, maske,
                             pr, '', 3, TE_LEFT);

         (* Fenster îffnen und zeichnen der
            Dialogbox *)
         
         wind_open(fenster, wx, wy, ww, wh);         
         objc_draw(BaumAdresse, 0, 8, ox, oy,
                                        ow, oh);

         (* Verwalten der Dialogbox mit der
            neuen FormDo-Routine *)

         auswahl := FormDo(ApplId, fenster,
                           BaumAdresse, ANREDE);

         (* Selektiertes Objekt zurÅcksetzen *)

         state:=obj_getstate(BaumAdresse,auswahl)
                                   XOR SELECTED;
         obj_setstate(BaumAdresse,auswahl,state);
         
         (* Schrunpfendes rechteck zeichnen und
            den reservierten Bildschirmbereich
            wieder freigeben *)

         form_dial(2,0,0,0,0,ox,oy,ow,oh);
         form_dial(3,0,0,0,0,ox,oy,ow,oh);

         (* Fenster schlieûen und Fensterhandle
            freigeben *)
         
         wind_close(fenster);
         Wind_delete(fenster);
      end
      else (* Kein Fenster frei *)
      begin
         nachricht:='[3][Kein Fenster!| ][ OK ]';
         
         auswahl:= form_alert(1, nachricht[1]);
      end;
   end;

(***********************************************)
(* MenuHandler zur Bearbeitung der Mitteilungen*)
(* aus MenÅ-Aktionen                           *)
(* öbergeben werden der menÅtitel und der      *)
(* MenÅeintrag                                 *)
(* TRUE wird zurÅckgegeben, wenn Ende selktiert*)
(* wurde                                       *)
(***********************************************)
    
   Function DoMenuHandler(item, 
                         entry: Integer):Boolean;
   begin
      (* MenÅtitel normal zeichnen *)

      menu_tnormal(MenuAdresse, item, 1);
      
      DoMenuHandler:= FALSE;
      
      case
         entry
      of
         mabout  : DoCopyright;
         madresse: DoAdresse;
         mende   : DoMenuhandler:= TRUE;
      end;
   end;

(***********************************************)
(* Hauptprogramm mit der Ereigniswarteschleife *)
(***********************************************)
   
   Procedure DoMainProgram;
   var event: Integer;
       Msg: Array_16;
       Ende: Boolean;
   begin
      Ende:= FALSE;
      
      while
         not Ende
      do
      begin
         (* Auf Mitteilungsereignisse warten *)

         evnt_mesag(Msg);

         (* Bearbeiten der Ereignisse. Es ist
            nur eine Auswahl angegeben. Das
            Case-Konstrukt kann nach eigenen
            WÅnschen ausgebaut werden *)
         
         case
            Msg[0]
         of
            MN_SELECTED:
            Ende:= DoMenuHandler(msg[3],msg[4]);
            WM_REDRAW: ;
            WM_MOVED : ;
            WM_SIZED : ;
         end;
      end;
   end;
   
begin
   ApplId:= appl_init; (* ApplID ermitteln *)
   
   if
      ApplId >= 0 (* Anmeldung erfolgreich ? *)
   then
   begin
      (* Virtuelle Workstation îffnen *)

      for
         i:= 0 to 9
      do
         WorkIn[i]:= 1;
         
      WorkIn[10]:= 2;
      
      VdiHandle := graf_handle(dummy, dummy,
                               dummy, dummy);
      v_opnvwk(workin, VdiHandle, workout);

      (* Adressen der Objekte ermitteln und
         mit form_center zentrieren *)
      
      BaumAdresse:= TreeAddr^[adresse];
      form_center(Baumadresse, dummy, dummy,
                               dummy, dummy);
      
      MenuAdresse:= TreeAddr^[menu];
      
      AboutAdresse:= TreeAddr^[about];
      form_center(AboutAdresse, dummy, dummy,
                                dummy, dummy);
      
      (* MenÅziele zeichnen *)

      menu_bar(MenuAdresse, 1);
      
      DoMainProgram; 
          (* Hauptprogramm ausfÅhren *)
      
      (* MenÅzeile lîschen *)

      menu_bar(MenuAdresse, 0);
      
      (* Workstation schlieûen und von GEM
         abmelden *)

      v_clsvwk(VdiHandle);
      appl_exit;
   end;
end.

