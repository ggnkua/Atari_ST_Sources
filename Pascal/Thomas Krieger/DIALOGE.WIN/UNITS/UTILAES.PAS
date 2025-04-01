(************************************************)
(*                                              *)
(* Unit ...............: UTILAES                *)
(* Inhalt .............: NÅtzliche Prozeduren   *)
(*                       und Funktionen im Um-  *)
(*                       gang mit dem AES und   *)
(*                       Dialogen               *)
(* Strukturen .........: TedInfo, IconBlk,      *)
(*                       BitBlk, UserBlk,       *)
(*                       ParmBlk, Object, Tree  *)
(*                       Die Strukturen kînnen  *)
(*                       Åber den jeweiligen    *)
(*                       Zeiger in o_spec ange- *)
(*                       sprochen werden        *)
(* Funktionen .........: siehe Beschreibung im  *)
(*                       Interface              *)
(* Erstellt ...........: 22/06/92               *)
(* Entwickler .........: Thomas Krieger         *)
(* Version ............: 1.20                   *)
(*                                              *)
(************************************************)

{$F+,R-}
unit UtilAes;

interface
     (* ôffentl. Strukturen und Schnittstellen *)

USES Bios, Dos, GemDecl, GemAes, GemVdi;

CONST FMD_BACKWARD = -1;
      FMD_FORWARD  = -2;
      FMD_DEFLT    = -3;
      MAXOBJECTS   = 99;
      WM_UNTOP     = 30;
      WM_ISTOP     = 43;

TYPE Str80    = String;
     PtrToStr = ^Str80;

     
     TedInfo = record
                  te_ptext    : PtrToStr;
                  te_ptmplt   : PtrToStr;
                  te_pvalid   : PtrToStr;
                  te_font     : Integer;
                  te_resvd1   : Integer;
                  te_just     : Integer;
                  te_color    : Integer;
                  te_resvd2   : Integer;
                  te_thickness: Integer;
                  te_txtlen   : Integer;
                  te_tmplen   : Integer;
               end;

               
     IconBlk = record
                  ib_pmask: pointer;
                  ib_pdata: pointer;
                  ib_ptext: pointer;
                  ib_char : Integer;
                  ib_xchar: Integer;
                  ib_ychar: Integer;
                  ib_xicon: Integer;
                  ib_yicon: Integer;
                  ib_wicon: Integer;
                  ib_hicon: Integer;
                  ib_xtext: Integer;
                  ib_ytext: Integer;
                  ib_wtext: Integer;
                  ib_htext: Integer;
                  ib_resvd: Integer;  (* immer
                                      Null !!! *)
               end;

               
     BitBlk  = record
                  bi_pdata: pointer;
                  bi_wb   : Integer;
                  bi_hl   : Integer;
                  bi_x    : Integer;
                  bi_y    : Integer;
                  bi_color: Integer;
               end;

               
     UserBlk = record
                  up_code : pointer;
                  up_param: pointer;
               end;

               
     ParmBlk = record
                  pb_tree     : pointer;
                  pb_obj      : Integer;
                  pr_prevstate: Integer;
                  pr_currstate: Integer;
                  pb_x        : Integer;
                  pb_y        : Integer;
                  pb_w        : Integer;
                  pb_h        : Integer;
                  pb_xc       : Integer;
                  pb_yc       : Integer;
                  pb_wc       : Integer;
                  pb_hc       : Integer;
                  pb_parm     : pointer;
               end;

               
      O_Type     = G_Box..G_Title;
      TedInfoPtr = ^TedInfo;
      IconBlkPtr = ^IconBlk;
      BitBlkPtr  = ^BitBlk;
      UserBlkPtr = ^UserBlk;
      ParmBlkPtr = ^ParmBlk;


      ObSpecTyp  = record
                   case
                     o_type
                   of
                     g_boxchar,
                     g_box,
                     g_ibox   : (i: Integer);
                     g_text,
                     g_boxtext,
                     g_fboxtext,
                     g_ftext  : (t: TedInfoPtr);
                     g_string,
                     g_title,
                     g_button : (s : PtrToStr);
                     g_image  : (im: BitBlkPtr);
                     g_userdef: (u : UserBlkPtr);
                     g_icon   : (ic: IconBlkPtr);
                   end;

               
      Object = record
                  o_next,
                  o_start,
                  o_end    : Integer;
                  o_type,
                  o_flags,
                  o_status : Integer;
                  o_spec   : ObSpecTyp;
                  o_x,
                  o_y,
                  o_w,
                  o_h      : Integer;
               end;

             
     Tree     = array [0..MaxObjects] of Object;
                    { object tree }
     TreePtr  = ^Tree;

     
     controlp = Array[0..5]  of Integer;
     globalp  = Array[0..15] of Integer;
     intinp   = Array[0..16] of Integer;
     intoutp  = Array[0..7]  of Integer;
     adrinp   = Array[0..2]  of TreePtr;
     adroutp  = Array[0..5]  of LongInt;
     AESParBlk= Record
                    control: ^controlp;
                    global : ^globalp;
                    intin  : ^intinp;
                    intout : ^intoutp;
                    adrin  : ^adrinp;
                    adrout : ^adroutp;
                end;



(***********************************************)
(* Funktion:         OBJ_GETSTATE->Typ: INTEGER*)
(* Zweck:            Auslesen des Objek-Status *)
(* Eingabeparameter: adresse     -> Zeiger auf *)
(*                                  Objektbaum *)
(*                   item        -> Objekt im  *)
(*                                  Baum       *)
(* RÅckgabe:         Objektstatus              *)
(***********************************************)


   function obj_getstate(adresse: TreePtr;
                         item: Integer): Integer;


(***********************************************)
(* Prozedur:         OBJ_SETSTATE              *)
(* Zweck:            Setzen des Objektstatus   *)
(* Eingabeparameter: adresse     -> Zeiger auf *)
(*                                 Objektbaum  *)
(*                   item        -> Objekt im  *)
(*                                  Baum       *)
(*                   state       -> N. Status  *)
(* Ausgabeparameter: keine                     *)
(***********************************************)


   procedure obj_setstate(adresse: TreePtr;
                          item,
                          state  : Integer);


(***********************************************)
(* Funktion:         OBJ_GETFLAGS->Typ: INTEGER*)
(* Zweck:            Auslesen der Objekt-Flags *)
(* Eingabeparameter: adresse     -> Zeiger auf *)
(*                                  Objektbaum *)
(*                   item        -> Objekt im  *)
(*                                  Baum       *)
(* RÅckgabe:         Objekt-Flags              *)
(***********************************************)


   function obj_getflags(adresse: TreePtr;
                         item: Integer): Integer;


(***********************************************)
(* Prozedur:         OBJ_SETFLAGS              *)
(* Zweck:            Setzen der Objekt-Flags   *)
(* Eingabeparameter: adresse     -> Zeiger auf *)
(*                                  Objektbaum *)
(*                   item        -> Objekt im  *)
(*                                  Baum       *)
(*                   flags       -> Neue Flags *)
(* Ausgabeparameter: keine                     *)
(***********************************************)


   procedure obj_setflags(adresse: TreePtr;
                          item,
                          flags: Integer);


(***********************************************)
(* Prozedur:         GET_DEDIT   ->Typ: STRING *)
(* Zweck:            Auslesen eines editierten *)
(*                   Textes aus einem Objekt   *)
(* Eingabeparameter: adresse     -> Zeiger auf *)
(*                                  Objektbaum *)
(*                   item        -> Objekt im  *)
(*                                  Baum       *)
(* RÅckgabe:         text        -> eingegeb.  *)
(*                                  Text       *)
(***********************************************)


   function get_dedit(adresse: TreePtr;
                      item: Integer): String;


(***********************************************)
(* Prozedur:         SET_DEDIT                 *)
(* Zweck:            Bearbeiten e. Edit-Feldes *)
(* Eingabeparameter: adresse     -> Zeiger auf *)
(*                                  Objektbaum *)
(*                   item        -> Objekt im  *)
(*                                  Baum       *)
(*                   maske       -> String mit *)
(*                                  Maske fÅr  *)
(*                                  Eingabe    *)
(*                   pruefung    -> String mit *)
(*                                  gÅltigen   *)
(*                                  Eingabe-   *)
(*                                  zeichen    *)
(*                   text        -> Einzutra-  *)
(*                                  gender Text*)
(*                   font        -> Zeichensatz*)
(*                                  (3 System, *)
(*                                  5 6*6 Pxl.)*)
(*                   just        -> Ausrichtung*)
(*                                  0: linksb. *)
(*                                  1: rechtsb.*)
(*                                  2: zentr.  *)
(* Ausgabeparameter: keine                     *)
(* Besonderheiten:   Keine LÑngenprÅfung. Be-  *)
(*                   nutzer ist dafÅr verant-  *)
(*                   wortlich                  *)
(***********************************************)


   procedure set_dedit(adresse: TreePtr;
                       item: Integer;
                       maske,
                       pruefung,
                       text: String;
                       font,
                       just: Integer);


(***********************************************)
(* Prozedur:         OBJC_REDRAW               *)
(* Zweck:            Neuzeichnen eines Objekt  *)
(* Eingabeparameter: adresse     -> Zeiger auf *)
(*                                  Objektbaum *)
(*                   item        -> Objekt im  *)
(*                                  Baum       *)
(* Ausgabeparameter: keine                     *)
(* Besonderheiten:   Bildschirmausschnitt fÅr  *)
(*                   Clipping wird berechnet   *)
(***********************************************)
                      

   procedure objc_redraw(adresse: TreePtr;
                         item: Integer);

(***********************************************)
(* Funktion:         FORM_BUTTON               *)
(* Zweck:            Eingaben in Dialogboxen   *)
(*                   verwalten                 *)
(* Eingabeparameter: fo_ktree      -> Zeiger a.*)
(*                                   Objektbaum*)
(*                   fo_kobject    -> Zu bear- *)
(*                                    beitendes*)
(*                                    Objekt   *)
(*                   fo_kobnext    -> NÑchstes *)
(*                                    Objekt   *)
(*                   fo_kchar      -> Zeichen  *)
(* Ausgabeparameter: fo_knextobject-> NÑchstes *)
(*                                    Objekt   *)
(*                   fo_knextchar  -> NÑchstes *)
(*                                    Zeichen  *)
(* RÅckgabe:         0, wenn OK, <> 1 sonst    *)
(***********************************************)


   function form_button(    fo_btree: TreePtr;
                            fo_bobject,
                            fo_bclicks: Integer;
                        var fo_bnxtobj: Integer)
                                      : Integer;

   
(***********************************************)
(* Funktion:         FORM_KEYBD                *)
(* Zweck:            Eingaben in Dialogboxen   *)
(*                   verwalten                 *)
(* Eingabeparameter: fo_ktree      -> Zeiger   *)
(*                                    auf Ob-  *)
(*                                    jektbaum *)
(*                   fo_kobject    -> Zu bear- *)
(*                                    beitendes*)
(*                                    Objekt   *)
(*                   fo_kobnext    -> NÑchstes *)
(*                                    Objekt   *)
(*                   fo_kchar      -> Zeichen  *)
(* Ausgabeparameter: fo_knextobject-> NÑchstes *)
(*                                    Objekt   *)
(*                   fo_knextchar  -> NÑchstes *)
(*                                    Zeichen  *)
(* RÅckgabe:         0, wenn OK, <> 1 sonst    *)
(***********************************************)


   function form_keybd(    fo_ktree: TreePtr;
                           fo_kobject,
                           fo_kobnext,
                           fo_kchar: Integer;
                       var fo_knextobject,
                           fo_knextchar: Integer)
                                       : Integer;
                       

(***********************************************)
(* Funktion:         DO_FORM                   *)
(* Zweck:            Dialogverwaltungsroutine  *)
(* Eingabeparameter: applid      -> Applika-   *)
(*                                  tationsId  *)
(*                   fenster     -> Fenster, in*)
(*                                  dem der    *)
(*                                  Dialog     *)
(*                                  lÑuft      *)
(*                   tree        -> Zeiger auf *)
(*                                  den Objekt-*)
(*                                  baum       *)
(*                   start_field -> erstes edi-*)
(*                                  tierbares  *)
(*                                  Feld       *)
(* Ausgabeparameter: keine                     *)
(* RÅckgabe:         selektiertes Exit-Objekt  *)
(* Bemerkungen:      Ist kein Default-Objekt im*)
(*                   Dialog, so wird die       *)
(*                   Return-Taste automatisch  *)
(*                   wie die Tab-Taste benutzt,*)
(*                   d.h. der Cursor sprint ins*)
(*                   nÑchste editierbare Feld. *)
(*                   Wird zur Tab-Taste die    *)
(*                   Shift-Taste gedrÅckt,     *)
(*                   springt der Cursor ins    *)
(*                   vorhergehende editierbare *)
(*                   Feld.                     *)
(***********************************************)

                       
Function FormDo(    applid, fenster: Integer; 
                 var tree: TreePtr; 
                   start_field: Integer):Integer;
   
(***********************************************)
(*                                             *)
(* Und so ist's realisiert                     *)
(*                                             *)
(***********************************************)
   
implementation       (* Internas der Unit *)

{$F+}

(* Unit-Interne Deklarationen *)

var aespb     : ^AESParBlk;
    version,
    GlobalEdit: Integer;

function obj_getstate(adresse: TreePtr;
                      item: Integer): Integer;
begin
   obj_getstate := adresse^[item].o_status;
end;

procedure obj_setstate(adresse: TreePtr;
                       item, state: Integer);
begin
   adresse^[item].o_status := state;
end;

function obj_getflags(adresse: TreePtr;
                      item: Integer): Integer;
begin
   obj_getflags := adresse^[item].o_flags;
end;

procedure obj_setflags(adresse: TreePtr;
                       item,
                       flags: Integer);
begin
   adresse^[item].o_flags := flags;
end;

function get_dedit(adresse: TreePtr;
                   item: Integer): String;
var s: PtrToStr;
    r: String;
    l,i: Integer;
    ted_info: TedInfoPtr;
begin
   ted_info := adresse^[item].o_spec.t;
   i        := 0;
   r        := '';
   s        := ted_info^.te_ptext;
   l        := ted_info^.te_txtlen;
   
   while 
      (i <= l) and (s^[i] <> #00) 
   do
   begin
      r := r + s^[i];
      i := i + 1;
   end;
   
   get_dedit := r;
end;

procedure set_dedit(adresse: TreePtr;
                    item: Integer;
                    maske,
                    pruefung,
                    text: String;
                    font,
                    just: Integer);
var i: byte;
begin
   maske   := maske    + #00;
   pruefung:= pruefung + #00;
   text    := text     + #00;
   
   for 
      i := 1 to length(maske) 
   do
      adresse^[item].o_spec.t^.
      te_ptmplt^[i-1] := maske[i];
      
   for 
      i := 1 to length(pruefung) 
   do
      adresse^[item].o_spec.t^.
      te_pvalid^[i-1] := pruefung[i];
      
   for 
      i := 1 to length(text) 
   do
      adresse^[item].o_spec.t^.
      te_ptext^[i-1] := text[i];
   
   adresse^[item].o_spec.t^.te_font  := font;
   adresse^[item].o_spec.t^.te_just  := just;
end;

procedure objc_redraw(adresse: TreePtr;
                      item: Integer);
var x,y,w,h: Integer;
begin
   objc_offset(adresse,item,x,y);
   
   w := adresse^[item].o_w;
   h := adresse^[item].o_h;

   objc_draw(adresse,0,8,x,y,w,h);
end;

procedure AesCall;ASSEMBLER;
ASM
   move.l   aespb,d1
   move.w   #200,d0
   trap     #2
end;

function form_button(    fo_btree: TreePtr;
                         fo_bobject,
                         fo_bclicks: Integer;
               var fo_bnxtobj: Integer): Integer;
begin
   aespb^.adrin^[0]  := fo_btree;
   aespb^.intin^[0]  := fo_bobject;
   aespb^.intin^[1]  := fo_bclicks;
   aespb^.control^[0]:= 56;
   aespb^.control^[1]:= 2;
   aespb^.control^[2]:= 2;
   aespb^.control^[3]:= 1;
   aespb^.control^[4]:= 0;
   
   AesCall;
   
   fo_bnxtobj := aespb^.intout^[1];
   form_button:= aespb^.intout^[0];
end;

function form_keybd(    fo_ktree: TreePtr;
                        fo_kobject,
                        fo_kobnext,
                        fo_kchar: Integer;
                    var fo_knextobject,
                        fo_knextchar: Integer)
                                    : Integer;

begin
   aespb^.adrin^[0]  := fo_ktree;
   aespb^.intin^[0]  := fo_kobject;
   aespb^.intin^[1]  := fo_kchar;
   aespb^.intin^[2]  := fo_kobnext;
   aespb^.control^[0]:= 55;
   aespb^.control^[1]:= 3;
   aespb^.control^[2]:= 3;
   aespb^.control^[3]:= 1;
   aespb^.control^[4]:= 0;
   
   AesCall;
   
   fo_knextobject := aespb^.intout^[1];
   fo_knextchar   := aespb^.intout^[2];
   form_keybd     := aespb^.intout^[0];
end;

Procedure DoRedraw(tree: TreePtr;
                   fenster,
                   x,
                   y,
                   w,
                   h: Integer);
var r1, r2: Grect;
begin
   (* Koordinaten des Bildschirmbereichs in die
      Rechtechstruktur r1 eintragen *)

   r1.x := x;
   r1.y := y;
   r1.w := w;
   r1.h := h;

   (* Bildschirm fÅr andere Applikationen fÅr 
      die Dauer des Updates sperren und Maus
      ausschalten *)
   
   wind_update(BEG_UPDATE);
   graf_mouse(M_OFF, NIL);

   (* Erstes Rechteck aus der Rechteckliste
      holen *)
   
   wind_get(fenster, WF_FIRSTXYWH, r2.x, r2.y,
                                   r2.w, r2.h);
   
   while (* Solange nicht leer *)
      (r2.w <> 0) and (r2.h <> 0)
   do
   begin
      if  (* öberlappungsbereich ermitteln *)
         Intersect(r1, r2)
      then
      begin
         (* Dialogbox im öberlappungsbereich
            neu zeichnen. Dieser Bereich 
            befindet sich in der Rechteckstruktur 
            r2 *)

         objc_draw(tree, 0, 8, r2.x, r2.y,
                               r2.w, r2.h);
      end;

      (* NÑchstes Rechteck aus der Rechteckliste
         holen *)
      
      wind_get(fenster, WF_NEXTXYWH, r2.x, r2.y,
                                     r2.w, r2.h);
   end;

   (* Das war's; Maus an, Bildschirm wieder
      freigeben *)
   
   graf_mouse(M_ON, NIL);
   wind_update(END_UPDATE);
end;

Procedure DoMove(var tree: TreePtr;
                     fenster,
                     x,
                     y,
                     applid: Integer);
var ox, oy, ow, oh, wx, wy, ww, wh: Integer;
    ScreenMaxX, ScreenMaxY, dummy: Integer;
    pipe: Array[0..7] of Integer;
begin
   (* Lage des Fensters ermitteln *)

   wind_get(fenster, WF_CURRXYWH, wx, wy,
                                  ww, wh);

   (* Maximale Bildschirmbreite und
      Bildschirmhîhe ermitteln*)

   wind_get(0,WF_WORKXYWH, dummy, dummy,
                           ScreenMaxX,
                           ScreenMaxY);

   (* Fenster soll nicht Åber den Bildschirmrand
      hinaus ragen *)

   if
      ((x + ww) > ScreenMaxX)
   then
      x := ScreenMaxX - ww;
      
   if
      ((y + wh) > ScreenMaxY)
   then
      y := ScreenMaxY - wh;

   (* Neue Fensterkoordinaten setzen und daraus
      den neuen Arbeitsbereich ermitteln *)
      
   wind_set(fenster, WF_CURRXYWH, x,  y,  ww, wh);
   wind_get(fenster, WF_WORKXYWH, ox, oy, ow, oh);

   (* Eintragen der Koordinaten in die Objekt-
      Struktur *)
   
   tree^[0].o_x := ox + 1;
   tree^[0].o_y := oy + 1;
   tree^[0].o_w := ow;
   tree^[0].o_h := oh;

   (* WM_REDRAW-Meldung generieren und
      abschicken *)
   
   pipe[0] := WM_REDRAW;
   pipe[3] := fenster;
   pipe[4] := x;
   pipe[5] := y;
   pipe[6] := ww;
   pipe[7] := wh;
   
   appl_write(applid, SizeOf(pipe), pipe);
end;

function find_object(tree: TreePtr;
                     start_object,
                     which: Integer): Integer;
var return, object, flag,
    theflag, increment: Integer;
begin
   object   := 0;
   flag     := EDITABLE;
   increment:= 1;
   
   case
      which
   of
      FMD_BACKWARD: begin
                       increment:= -1;
                       object  := start_object
                                  + increment;
                    end;
      FMD_FORWARD:  begin
                       object := start_object
                                 + increment;
                    end;
      FMD_DEFLT:    begin
                       flag := DEFAULT;
                    end;
   end;
   
   return := start_object;
   
   while
      (object >= 0)
   do
   begin
      theflag := tree^[object].o_flags;
      
      if
         theflag & flag > 0
      then
         return := object;
         
      if
         theflag & LASTOB > 0
      then
         object := -1
      else
         object := object + increment;
   end;
   
   find_object := return;
end;

function ini_field(tree: TreePtr;
                   start_field: Integer):Integer;
begin
   if
      start_field = 0
   then
      start_field :=
          find_object(tree, 0, FMD_FORWARD);
      
   ini_field := start_field;
end;

function FormDo(    applid, fenster: Integer; 
                var tree: TreePtr;
                 start_field: Integer): Integer;
var edit_object, next_object, which, cont,
    TopWindow,  default, dummy, idx, mx,
    my, mb, ks, kr, br: Integer;
    msg: Array_16;
begin
   next_object:= ini_field(tree, start_field);
   edit_object:= 0;
   GlobalEdit := 0;
   cont       := 1;
   default    := find_object(tree, 0, FMD_DEFLT);
   
   while
      cont <> 0
   do
   begin
      if
         ((next_object <> 0) and 
         (edit_object <> next_object))
      then
      begin
         edit_object:= next_object;
         GlobalEdit := edit_object;
         next_object:= 0;
         
         objc_edit(tree, edit_object, chr(0),
                         idx, EDINIT, idx);
      end;
      
      which := evnt_multi(19,1,1,1,
                          0,0,0,0,0,0,0,0,0,0,
                          msg,LoWord(0),
                          HiWord(0),
                          mx,my,mb,ks,kr,br);

      wind_get(fenster, WF_TOP, TopWindow, dummy,
                        dummy, dummy);
      
      if
         (which & MU_MESAG > 0)
      then
      begin
         case
            msg[0]
         of
            WM_UNTOP : if
                          msg[3] = fenster
                       then
                          objc_edit(tree,
                                    edit_object,
                                    chr(0),idx,
                                    EDEND, idx);
            WM_ISTOP : if
                          msg[3] = fenster
                       then
                          objc_edit(tree, 
                                    edit_object, 
                                    chr(0),idx, 
                                    EDINIT, idx);
            WM_TOPPED: wind_set(fenster, 
                                   WF_TOP,
                                   msg[3], 
                                   0, 0, 0);
            WM_REDRAW: DoRedraw(tree, msg[3], 
                                      msg[4], 
                                      msg[5], 
                                      msg[6], 
                                      msg[7]);
            WM_MOVED: DoMove(tree, msg[3],
                                   msg[4],
                                   msg[5],
                                   ApplId);
         end;
         
         objc_edit(tree, edit_object, chr(0),
                         idx, EDINIT, idx);
      end;
      
      if
         (which & MU_KEYBD > 0) and
         (TopWindow = fenster) (* Unser Fenster
                                  ist oben ? *)
      then
      begin
         if
            (kr = TAB) (* Tab-Taste gedrÅckt ? *)
         then
         begin
            if
               (ks & 1 > 0) or
               (ks & 2 > 0)
                      (* dazu Shift gedrÅckt ? *)
            then
            begin
               kr := Cur_Up;
                   (* Umsetzen in Cur_up-Taste *)
            end;
         end;
         
         if
            (default = 0) and
            ((kr = RETURN) or
            (kr = ENTER))
                    (* Return gedrÅckt und kein*)
         then       (* Default-Objekt *)
         begin
            kr := TAB; (* In Tab-Taste umsetzen*)
         end;
         
         cont := form_keybd(tree, edit_object,
                            next_object, kr,
                            next_object, kr);
         
         if
            kr <> 0
         then
         begin
            objc_edit(tree, edit_object, Chr(kr),
                            idx, EDCHAR, idx);
         end;

      end;   
         
      if
         (which & MU_BUTTON > 0) and
         (TopWindow = fenster)
      then
      begin
         next_object:= objc_find(tree, 0, 8,
                                 mx, my);
         
         if
            (next_object = -1)
         then
         begin
            next_object := 0;
         end
         else
         begin
            cont := form_button(tree, 
                                next_object,
                                br, next_object);
         end;
      end;
         
      if
         (cont = 0) or 
         ((next_object <> 0) and 
         (next_object <> edit_object))
      then
      begin
         objc_edit(tree,edit_object,chr(0),idx,
                    EDEND, idx);
      end;
   end;
   
   FormDo:= next_object;
end;

begin
   aespb := Addr(AES_pb); (* AES-Parameterblock
                             ermitteln *)
end.

