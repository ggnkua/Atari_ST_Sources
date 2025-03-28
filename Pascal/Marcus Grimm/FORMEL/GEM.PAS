UNIT GEM;(* Diverse Gem-Definitionen *)

INTERFACE

USES GEMDECL,GEMAES,GEMVDI;

TYPE (* Dialog-Definition : *)
      C_String       = PACKED Array[ 0..255 ] of Char;
      String_Ptr     = ^C_String;
      Ob_Type        = G_Box..G_Title;
      
      Text_Ed_Info = RECORD
                     te_ptext,
                     te_ptmplt,
                     te_pvalid : String_Ptr;
                     te_font,
                     te_junk1,
                     te_just,
                     te_color,
                     te_junk2,
                     te_thickness,
                     te_txtlen,
                     te_tmplen : Integer;
                   END;
        Ted_Ptr = ^Text_Ed_Info;

        Spec_Info = RECORD
                      CASE Ob_Type  OF
                       G_BOX, G_IBOX,G_BOXCHAR :
                                            ( thick,
                                              color : integer);
                       G_TEXT, G_BOXTEXT, G_FTEXT, G_FBOXTEXT :
                                            ( info : Ted_Ptr );
                       G_USERDEF : (UserPtr : Pointer);
                       G_IMAGE, G_BUTTON : ( ptr : Pointer );
                       G_ICON : (Icn : Pointer);
                       G_STRING, G_TITLE :
                                            ( str : String_Ptr )
                    END;

  (* OBJECT Structur: *)
    Object = RECORD
               ob_next,
               ob_head,
               ob_tail : Integer;
               ob_type,
               ob_flags,
               ob_state : integer;
               ob_spec  : Spec_Info;
               ob_x,
               ob_y,
               ob_w,
               ob_h     : integer;
             END;

        Trees = ARRAY [0..$FF] OF Object;
        Tree_Ptr = ^Trees;
        Menu_Ptr = Tree_Ptr;
        Dialog_Ptr = Tree_Ptr;

VAR Vdi_Handle : Integer;

Function Init_Gem:Boolean; (* Gem Initialisierung *)

Procedure EndGem;

Procedure Frame(x,y,b,h : Integer);(* Rahmen *)

Procedure Line(vonx,vony,nachx,nachy : Integer);

(* Liežt den Text aus Eingabe-Feld *)
Procedure ReadTe_PText(Dia : Dialog_Ptr;Obj : Integer;Var Strg : String);

IMPLEMENTATION

function Init_Gem:Boolean;
var
  workin  : IntIn_Array;
  workout : workout_Array;
  dummy,Aes_HAndle   : Integer;
begin
  Aes_Handle := appl_init;
  if AES_handle >= 0 then 
  begin
    VDI_handle := graf_handle(Dummy, Dummy,Dummy, dummy);
    for dummy := 0 to 9 do workin[dummy] := 1;
    workin[10] := 2;
    v_opnvwk(workin, VDI_handle, workout);
    graf_mouse(ARROW, NIL)
  end;
  Init_Gem := AES_handle >= 0;
end;

Procedure EndGem;
Begin
 v_clsvwk(VDI_handle);
 appl_exit;
End;

Procedure Frame(x,y,b,h : Integer);
Var Pts : PtsIn_Array;
Begin
 Pts[0]:=x;   Pts[1]:=y;
 Pts[2]:=x+b; Pts[3]:=y;
 Pts[4]:=x+b; Pts[5]:=y+h;
 Pts[6]:=x;   Pts[7]:=y+h;
 Pts[8]:=x;   Pts[9]:=y;
 v_pline(VDI_Handle,5,Pts);
End;

Procedure Line(vonx,vony,nachx,nachy : Integer);
Var Pts : PtsIn_Array;
Begin
 Pts[0]:=vonx;  Pts[1]:=vony;
 Pts[2]:=nachx; Pts[3]:=nachy;
 v_pline(VDI_Handle,2,Pts);
End;

Procedure ReadTe_PText(Dia : Dialog_Ptr;Obj : Integer;Var Strg : String);
Var f : Integer;
Begin
 f:=0;
 With Dia^[Obj].Ob_Spec.Info^ do
 While Te_PText^[f] <> #0 Do
 Begin
  Strg[f+1]:=Te_PText^[f];
  Inc(f);
 End;
 Strg[0]:=Chr(f);
End;

End.