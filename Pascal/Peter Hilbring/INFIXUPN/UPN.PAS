{***********************************}
{   INFIX ---> UPN-Notation V 1.0   }
{                                   }
{   Peter Hilbring                  }
{   Dietrich-Ottmarstraáe 16        }
{   W-4782 Erwitte                  }
{                                   }
{ Programmiert in MAXON-PASCAL V1.5 }
{ (c) 1992 MAXON-Computer           }
{***********************************}
{                                   }
{ Listing #1 : UPN.PAS              }
{                                   }
{ Deklaration und Objektverwaltung  }
{                                   }
{***********************************}

program infix_2_upn;

uses GemDecl, GemAES, GemVDI, Dos, Bios;

{$R-,S-,I-,F-,D-,V-}
{$M 10,5,200,20}

const
    DIAG    =   0; (* Formular/Dialog *)
    CALC    =   5; (* BUTTON in Baum DIAG *)
    CLIP    =   6; (* IMAGE in Baum DIAG *)
    CLEAR   =   7; (* BUTTON in Baum DIAG *)
    OK      =   8; (* BUTTON in Baum DIAG *)
    UPN_0   =   9; (* BOX in Baum DIAG *)
    UPN_1   =  11; (* STRING in Baum DIAG *)
    UPN_2   =  12; (* STRING in Baum DIAG *)
    UPN_3   =  13; (* STRING in Baum DIAG *)
    UPN_4   =  14; (* STRING in Baum DIAG *)
    UPN_MSK =  15; (* IBOX in Baum DIAG *)
    INF_1   =  16; (* FTEXT in Baum DIAG *)
    INF_2   =  17; (* FTEXT in Baum DIAG *)
    INF_MSK =  18; (* IBOX in Baum DIAG *)
    clr_str : string = { 40 Space }
  '                                        '#0;
    operator: array[0..20] of string[10] =
                ('DIV','MOD','SQR','SQRT',
                 'TAN','SIN','COS','ATN',
                 'ASIN','ACOS','###');

type
    c_string= packed array [0..255] of char;
    string_ptr=^c_string;
    Ob_Type = G_BOX..G_TITLE;
    rtedinfo= record
                  te_ptext,
                  te_ptmplt,
                  te_pvalid : string_ptr;
                  te_font,
                  te_junk1,
                  te_just,
                  te_color,
                  te_junk2,
                  te_thickness,
                  te_txtlen,
                  te_tmplen : integer
               end;
    riconblk= record
                  ib_pmask,
                  ib_pdata,
                  ib_ptext  : pointer;
                  ib_char,
                  ib_xchar,
                  ib_ychar,
                  ib_xicon,
                  ib_yicon,
                  ib_wicon,
                  ib_hicon,
                  ib_xtext,
                  ib_ytext,
                  ib_wtext,
                  ib_htext  : integer
              end;
    rbitblk = record
                  bi_pdata  : pointer;
                  bi_wb,
                  bi_hl,
                  bi_x,
                  bi_y,
                  bi_color  : integer
              end;
    rbfobspec= record
                  character : char;
                  framesize : shortint;
                  color     : integer
              { color enth„lt folgende Daten:
                    Bit     Inhalt
                    15-12   framecol
                    11-8    textcol
                    7       textmode
                    6-4     fillpattern
                    3-0     interiorcol       }
              end;
    spec_info=record
                  case Ob_Type of
                      G_Text,
                      G_BoxText,
                      G_FText,
                      G_FBoxText: (tedinfo :
                                   ^rtedinfo);
                      G_Icon    : (iconblk :
                                   ^riconblk);
                      G_Image   : (bitblk  :
                                   ^rbitblk);
                      G_IBox,
                      G_BoxChar,
                      G_Box     : (bfobspec:
                                   ^rbfobspec);
                      G_UserDef,
                      G_Title,
                      G_Button,
                      G_String,
                      G_Title   : (str :
                                   string_ptr)
              end;
    object  = record
                  ob_next  : integer;
                  ob_head  : integer;
                  ob_tail  : integer;
                  ob_type  : integer;
                  ob_flags : integer;
                  ob_state : integer;
                  ob_spec  : spec_info;
                  ob_x     : integer;
                  ob_y     : integer;
                  ob_w     : integer;
                  ob_h     : integer
              end;
    tree    = array [0..50] of object;
    treeptr = ^tree;
    upn_rec = record
                cmd : array[0..160] of
                      string[85];
                val : array[0..160] of
                      shortint
              end;
    synt    = record
                flag   : boolean;
                p, art : shortint
              end;

var
    upn_stack : upn_rec;
    eingabe : string[85];
    upn     : string[165];
    start_pos : integer;
    stack   : integer;
    dummy   : char;
    dialog_adr : treeptr;
    vdi_handle : integer;
    aes_handle : integer;
    charboxheight : integer;
    old_sep : shortint;
    syntax  : synt;
    acc_name: string[15];
    msgbuf  : array_8;
    menu_id : integer;
    dosdata : searchrec;
    sc_rpscrap  : dirstr;
    x_res   : integer;
    y_res   : integer;
    err     : string;

{$I INIT_GEM.I}    {GEM-Routinen            }
{$I UPN_HDL.I }    {INFIX->UPN Konvertierung}
{$I SCRAP.I   }    {CLIPBRD Behandlung      }

procedure syntax_error;
var
    s : string[45];
    p : shortint;
begin
    s:='';
    for p :=1 to (syntax.p mod 40)-1 do
        s:=s+#32;
    s:=s+'^';
    for p:=(syntax.p mod 40)+1 to 40 do
        s:=s+#32;
    s:=s+#0;
    move(s[1], dialog_adr^[UPN_1].ob_spec.str^,
         length(s)-1);
    s:='        Syntax-Error in Zeile X';
    s:=s+'         '#0;
    s[31]:=chr(48+(syntax.p div 40));
    move(s[1], dialog_adr^[UPN_2].ob_spec.str^,
         length(s)-1);
    s:='';
    for p:=1 to 40 do
        s:=s+#32;
    s:=s+#0;
    move(s[1], dialog_adr^[UPN_4].ob_spec.str^,
         length(s)-1);
    if (syntax.art<0) then
        s:='        Klammer auf fehlt!';
        s:=s+'              '#0;
    if (syntax.art>0) then
        s:='        Klammer zu fehlt!';
        s:=s+'               '#0;
    move(s[1], dialog_adr^[UPN_3].ob_spec.str^,
         length(s)-1);
    objc_draw(dialog_adr, UPN_0, $7fff,
              0, 0, 0, 0)
end;

procedure make_eingabe;
var
    s    : string[45];
    p    : integer;
    space: boolean;
begin
    space:=false;
    eingabe:='';
    s[0]:=#255;
    move(dialog_adr^[INF_1].ob_spec.tedinfo^.
         te_ptext^, s[1],dialog_adr^[INF_1].
         ob_spec.tedinfo^.te_txtlen);
    s[0]:=chr(pos(#0,s));
    for p:=1 to length(s) do
        if (s[p]<>#0) and (s[p]<>'@') then
        begin
            if ((space=false) or ((s[p]<>#32)
                and (space=true))) then
                eingabe:=eingabe+s[p];
            if (s[p]=#32) then
                space:=true
            else
                space:=false
        end;
    s[0]:=#41;
    move(dialog_adr^[INF_2].ob_spec.tedinfo^.
         te_ptext^, s[1],dialog_adr^[INF_2]
         .ob_spec.tedinfo^.te_txtlen);
    for p:=1 to length(s) do
        if (s[p]<>#0) and (s[p]<>'@') then
        begin
            if ((space=false) or ((s[p]<>#32)
                and (space=true))) then
                eingabe:=eingabe+s[p];
            if (s[p]=#32) then
                space:=true
            else
                space:=false
        end;
    eingabe:=eingabe+#0;
    s:='@';
    for p:=0 to 39 do
        s:=s+#0;
    move(s[1], dialog_adr^[INF_1].ob_spec.
         tedinfo^.te_ptext^, 40);
    move(s[1], dialog_adr^[INF_2].ob_spec.
         tedinfo^.te_ptext^, 40);
    if (length(eingabe) div 42=0) then
        move(eingabe[1], dialog_adr^[INF_1].
             ob_spec.tedinfo^.te_ptext^,
             length(eingabe)-1)
    else
    begin
        s:=copy(eingabe, 1, 40)+#0;
        move(s[1], dialog_adr^[INF_1].ob_spec.
             tedinfo^.te_ptext^, 40);
        move(eingabe[41], dialog_adr^[INF_2].
             ob_spec.tedinfo^.te_ptext^,
             length(eingabe)-41)
    end;
    for p:=UPN_1 to UPN_4 do
        move(clr_str[1], dialog_adr^[p].
             ob_spec.str^, 40);
    objc_draw(dialog_adr, INF_1, $7fff,
              0, 0, 0, 0);
    objc_draw(dialog_adr, INF_2, $7fff,
              0, 0, 0, 0);
    objc_draw(dialog_adr, UPN_0, $7fff,
              0, 0, 0, 0)
end;

procedure dialog;
var
    x, y, w, h: integer;
    i, p      : integer;
    s         : string[45];
begin
    s:='@';
    for p:=0 to 39 do
        s:=s+#0;
    move(s[1], dialog_adr^[INF_1].ob_spec.
         tedinfo^.te_ptext^, length(s)-1);
    move(s[1], dialog_adr^[INF_2].ob_spec.
         tedinfo^.te_ptext^, length(s)-1);
    for p:=UPN_1 to UPN_4 do
        move(clr_str[1], dialog_adr^[p].
             ob_spec.str^, 40);
    form_center(dialog_adr, x, y, w, h);
    form_dial(fmd_start, 0, 0, 0, 0,
              x, y, w, h);
    form_dial(fmd_grow, 0, 0, 0, 0,
              x, y, w, h);
    objc_draw(dialog_adr, DIAG, $7fff,
              x, y, w, h);
    repeat
        i:=form_do(dialog_adr, INF_1);
        graf_mouse(BUSYBEE, NIL);
        case i of
            INF_msk : if not(bittest(7,
            dialog_adr^[CLIP].ob_flags)) then
                          clip_2_infix;
            UPN_msk : begin
                          if not(bittest(7,
            dialog_adr^[CLIP].ob_flags)) then
                              upn_2_clip;
                          if(check_clipbrd)then
                             dialog_adr^[CLIP].
                             ob_state:=SELECTED
                          else
                             dialog_adr^[CLIP].
                             ob_state:=NORMAL
                      end;
            CALC : begin
                       make_eingabe;
                       if check_bracket then
                       begin
                           upn:='';
                           start_pos:=1;
                           stack:=0;
                           old_sep:=-1;
                           syntax.flag:=true;
                           syntax.p:=length
                           (eingabe)-1;
                           make_upn;
                           if ((syntax.flag)and
                               (old_sep<>3) and
                              (old_sep<>6))then
                           begin
                               p:=0;
                               for p:=1 to
                          length(upn) div 40 do
                               begin
                                   s:=copy(upn,
                                   p*40-39, 40)
                                   +#0;
                                   move(s[1],
                        dialog_adr^[UPN_1+p-1]
                    .ob_spec.str^,length(s)-1);
                               end;
                               s:=copy(upn,
                p*40+1, length(upn) mod 40)+#0;
                               move(s[1],
                           dialog_adr^[UPN_1+p]
                           .ob_spec.str^,
                           length(s)-1);
                           objc_draw(dialog_adr
                           , UPN_0, $7fff,
                           0, 0, 0, 0)
                           end
                           else
                               syntax_error
                       end
                       else
                           syntax_error
                   end;
            CLEAR: begin
                       upn:='';
                       s:='@';
                       for p:=0 to 39 do
                           s:=s+#0;
                       move(s[1], dialog_adr^
                            [INF_1].ob_spec.
                            tedinfo^.te_ptext^,
                            length(s)-1);
                       objc_draw(dialog_adr,
                       INF_1,$7fff,0,0,0,0);
                       move(s[1], dialog_adr^
                            [INF_2].ob_spec.
                            tedinfo^.te_ptext^,
                            length(s)-1);
                       objc_draw(dialog_adr,
                       INF_2,$7fff,0,0,0,0);
                       for p:=UPN_1 to UPN_4 do
                           move(clr_str[1],
                           dialog_adr^[p].
                           ob_spec.str^, 40);
                       objc_draw(dialog_adr,
                       UPN_0,$7fff,0,0,0,0)
                   end
        end;
        dialog_adr^[i].ob_state:=dialog_adr^
                   [i].ob_state xor SELECTED;
        if ((i<>INF_msk) and (i<>UPN_msk)) then
          objc_draw(dialog_adr,i,$7fff,x,y,w,h)
        else
            objc_draw(dialog_adr,DIAG,$7fff,
                      x,y,w,h);
        graf_mouse(ARROW, NIL);
    until i=OK;
    form_dial(fmd_shrink,0,0,0,0,x,y,w,h);
    form_dial(fmd_finish,0,0,0,0,x,y,w,h)
end;

begin
    if (init_gem) then
    begin
        graf_mouse(ARROW, NIL);
        if (init_resource('UPN.RSC'#0)) then
        begin
            rsrc_gaddr(r_tree,DIAG,dialog_adr);
            if((x_res<dialog_adr^[DIAG].ob_w)or
               (y_res<dialog_adr^[DIAG].ob_h))
               then
            begin
               err:='Die Aufl”sung|ist fr ';
               err:=err+'dieses|Programm zu ';
               err:=err+'gering';
               fatal_error(err)
            end;
            if (init_clipbrd=false) then
                dialog_adr^[CLIP].ob_flags:=
                           HIDETREE
            else
            begin
                dialog_adr^[CLIP].ob_flags:=
                           NONE;
                if (check_clipbrd) then
                   dialog_adr^[CLIP].ob_state:=
                              SELECTED
                else
                   dialog_adr^[CLIP].ob_state:=
                              NORMAL
            end;
            upn:='';
            if (appflag) then
            begin
                dialog;
                rsrc_free;
                end_gem
            end
            else
            begin
                acc_name:='  INFIX->UPN'#0;
                menu_id:=menu_register
                (aes_handle,acc_name[1]);
                while true do
                begin
                    evnt_mesag(msgbuf);
                    if ((msgbuf[0]=ac_open) and
                       (msgbuf[4]=menu_id))then
                        dialog
                end
            end
        end
        else
        begin
            if (appflag) then
                tos_eingabe
            else
            begin
                end_gem;
                err:='|Kein Resourcefile ';
                err:=err+'gefunden';
                fatal_error(err)
            end
        end
    end
    else
    begin
        err:='Ich konnte GEM nicht | ';
        err:=err+'ordnungsgem„á ';
        err:=err+'initialisieren';
        fatal_error(err)
    end
end.
