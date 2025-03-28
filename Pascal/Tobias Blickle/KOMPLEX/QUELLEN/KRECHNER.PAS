program Komplexer_Taschenrechner;

    { Berechnet mit Hilfe der Module KPXCONST
                                     KPXTYPE
                                     KPXSUBS
      beliebige, komplexe AusdrÅcke mit bis zu 3 Variablen
      und 3 Macros in GEM-Dialog-Form
 
      (c) Tobias Blickle 1989  }                                 

    {$I KPXDEKL.PAS}     { Konstanten,Typ-Deklarationen und         }
                         { globale Variablen der KOMPLEX-Bibliothek }
const 
	{$I GEMCONST.PAS}
Type
	{$I GEMTYPE.PAS}

var
    junk,dummy,ex,quit,
    anz_fkt,anz_re,anz_im,anz_r,anz_phi,gleich:integer;
    baum    :dialog_ptr;
    anz_v_name,anz_real,anz_imag   :array[1..3] of integer;
    anz_m_name,anz_macro           :array[1..3] of integer;
    start :baumzeiger;
    funktion:str255;
    v_name:array[1..3] of var_string;
    m_name:array[1..3] of var_string;
    macro_inhalt:array[1..3] of str255;
    inhalt:str255;

    ok,alles_klar:boolean;
    re,im,r,phi:real;
    i :integer;

{$I GEMSUBS.PAS}
{$I KPXSUBS.PAS}               { Die Komplexen Funktionen }

(*---------------- Erstellt die GEM Dialog-Eingabe -----------------*)
procedure mache_dialog(var dialog:dialog_ptr);
 var i:integer;
begin
 dialog:=new_dialog(50,0,0,76,22);
 obj_setstate(dialog,0,outlined,false);
 dummy:=add_ditem(dialog,g_text,none,7,1,60,1,0,256);
 set_dtext(dialog,dummy,concat('Komplexer TASCHENRECHNER ',
           chr(189),' Tobias Blickle 89'),
           system_font,te_center);

 dummy:=add_ditem(dialog,g_box,none,2,3,72,5,-2,4096+256);
 obj_setstate(dialog,dummy,outlined,false);
 dummy:=add_ditem(dialog,g_text,none,15,3,40,1,0,256);
 set_dtext(dialog,dummy,'AUSDRUCKEINGABE',small_font,te_center);
 anz_fkt:=add_ditem(dialog,g_fboxtext,editable,3,4,66,1,-1,256);
 set_dedit(dialog,anz_fkt,
    '__________________________________________________________________',
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    '',system_font,te_center);
 obj_setstate(dialog,anz_fkt,outlined,false);
 dummy:=add_ditem(dialog,g_string,none,3,6,18,1,0,256);
 set_dtext(dialog,dummy,'Ergebnis  Real    :',system_font,te_left);
 dummy:=add_ditem(dialog,g_string,none,13,7,9,1,0,256);
 set_dtext(dialog,dummy,'ImaginÑr:',system_font,te_left);
 dummy:=add_ditem(dialog,g_string,none,41,6,7,1,0,256);
 set_dtext(dialog,dummy,'Betrag:',system_font,te_left);
 dummy:=add_ditem(dialog,g_string,none,41,7,7,1,0,256);
 set_dtext(dialog,dummy,'Phase :',system_font,te_left);
 anz_re:=add_ditem(dialog,g_string,none,22,6,18,1,0,256);
 anz_im:=add_ditem(dialog,g_string,none,22,7,18,1,0,256);
 anz_r :=add_ditem(dialog,g_string,none,48,6,18,1,0,256);
 anz_phi:=add_ditem(dialog,g_string,none,48,7,18,1,0,256);
 set_dtext(dialog,anz_re,'0',system_font,te_left); 
 set_dtext(dialog,anz_im,'0',system_font,te_left); 
 set_dtext(dialog,anz_r,'0',system_font,te_left); 
 set_dtext(dialog,anz_phi,'0',system_font,te_left); 
 gleich:=add_ditem(dialog,g_button,7,70,6,3,1,0,256); 
 set_dtext(dialog,gleich,'=',system_font,te_center);
 quit:=add_ditem(dialog,g_button,5,70,4,3,1,0,256);
 set_dtext(dialog,quit,chr(5),system_font,te_center);
  
 dummy:=add_ditem(dialog,g_box,none,2,9,72,4,2,black*256);
 obj_setstate(dialog,dummy,outlined,false);
 dummy:=add_ditem(dialog,g_text,none,15,9,40,1,0,256);
 set_dtext(dialog,dummy,'VARIABLENEINGABE',small_font,te_center);
 for i:=1 to 3 do begin
  anz_v_name[i]:=add_ditem(dialog,g_ftext,editable,4,9+i,10,1,0,128+256);
  set_dedit(dialog,anz_v_name[i],'__________','XXXXXXXXXX','',system_font,te_center);
  dummy:=add_ditem(dialog,g_string,none,16,9+i,5,1,0,256);
  set_dtext(dialog,dummy,'Real:',system_font,te_center);
  anz_real[i]:=add_ditem(dialog,g_ftext,editable,21,9+i,18,1,0,128+256);
  set_dedit(dialog,anz_real[i],'__________________',
     'XXXXXXXXXXXXXXXXXX','',system_font,te_left);
  dummy:=add_ditem(dialog,g_string,none,42,9+i,9,1,0,256);
  set_dtext(dialog,dummy,'ImaginÑr:',system_font,te_center);
  anz_imag[i]:=add_ditem(dialog,g_ftext,editable,52,9+i,18,1,0,128+256);
  set_dedit(dialog,anz_imag[i],'__________________',
     'XXXXXXXXXXXXXXXXXX','',system_font,te_left);
 end;

 dummy:=add_ditem(dialog,g_box,none,2,14,72,4,2,black*256);
 obj_setstate(dialog,dummy,outlined,false);
 dummy:=add_ditem(dialog,g_text,none,15,14,40,1,0,256);
 set_dtext(dialog,dummy,'MACROEINGABE',small_font,te_center);
 for i:=1 to 3 do begin
  anz_m_name[i]:=add_ditem(dialog,g_ftext,editable,4,14+i,10,1,0,128+256);
  set_dedit(dialog,anz_m_name[i],'__________','XXXXXXXXXX','',system_font,te_center);
  anz_macro[i]:=add_ditem(dialog,g_ftext,editable,15,14+i,55,1,0,128+256);
  set_dedit(dialog,anz_macro[i],
    '_______________________________________________________',
    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    '',system_font,te_left);
  end;

  dummy:=add_ditem(dialog,g_box,none,2,19,72,2,0,256);
  obj_setstate(dialog,dummy,outlined,false);
  dummy:=add_ditem(dialog,g_text,none,3,19,50,1,0,256);
  set_dtext(dialog,dummy,
    'Konstanten :  i  pi  - Variablen klein  -  Macros groû',
    small_font,te_left);
  dummy:=add_ditem(dialog,g_text,none,3,20,65,1,0,256);
  set_dtext(dialog,dummy,
     'Funktionen :  EXP( LN( SIN( ASIN( COS( ACOS( TAN( ATAN( SQRT( SQR( ABS( ARG( RE( IM(',
     small_font,te_left);
end;


(*----------- BAUM-AUFBAU mit ggf. Ausgabe der Fehlermeldung ---------*)
procedure syntax(was:string;var start:baumzeiger);
var ok:boolean;
    al_text,p_text:str255;
begin
 fehler:=false;
 baum_bau(was,start,ok);
 if not ok then begin
    start:=nil;
    writev(al_text,fehler_nr);writev(p_text,fehlerpos);
    al_text:=concat('SYNTAX-FEHLER NR ',al_text,
       '|',fehlertext[fehler_nr]);(*,'|an Position ',p_text);*)
    dummy:=do_alert(concat('[3][',al_text,'][PECH]'),1);
   end;
  fehler:=false;rte:=false;
end;
 
(*------ Berechnen des Baums mit ggf Ausgabe eines Laufzeitfehlers ----*)
procedure wert(start:baumzeiger;var re,im:real);
var n_text:string;
begin
 rte:=false;
 auswertung(start,re,im);
 if rte then begin
  writev(n_text,rte_nr);
  dummy:=do_alert(concat('[3][Laufzeitfehler Nr ',n_text,
       '|',rtetext[rte_nr],'][MURKS]'),1);
  re:=0;im:=0;
 end;
end;

begin
 if Init_Gem>=0 then
 begin
  init_mouse;     
  init_komplex;                {Komplex-Teil initialisieren}
  start:=nil;
  mache_dialog(baum);          {GEM Dialog definieren}
  Center_Dialog(baum);
  ex:=Do_Dialog(baum,0);       {... und aufrufen}
  obj_setstate(baum,ex,0,true);
  while ex<>quit do begin
   alles_klar:=true;i:=1;
     { ----- Alle Variablennamen und ggf Werte einlesen ------}
   while (alles_klar) and (i<=3) do begin
     del_variable(v_name[i]);
     get_dedit(baum,anz_v_name[i],inhalt);v_name[i]:=inhalt;
     if v_name[i]<>'' then begin
       get_dedit(baum,anz_real[i],inhalt);readv(inhalt,re);
       get_dedit(baum,anz_imag[i],inhalt);readv(inhalt,im);
       set_variable(v_name[i],re,im);
     end;
   i:=i+1;
   end;
   i:=1;
     { ------------ Dasselbe fÅr die MACROS -----------------}
   while (alles_klar) and (i<=3) do begin
     del_macro(m_name[i]);
     get_dedit(baum,anz_m_name[i],inhalt);m_name[i]:=inhalt;
     if m_name[i]<>'' then begin
       get_dedit(baum,anz_macro[i],macro_inhalt[i]);
       set_macro(m_name[i],macro_inhalt[i]);
       alles_klar:=alles_klar and (not fehler);
       if fehler then dummy:=do_alert('[1][MACRO-FEHLER][MIST]',1);
       fehler:=false;   
     end;
   i:=i+1;
   end;
 if alles_klar then begin      
    {------------ Ausdruck einlesen, berechnen, anzeigen -------}
   get_dedit(baum,anz_fkt,funktion); 
   clr_baum(start);
   syntax(funktion,start);wert(start,re,im);

   recht_polar(re,im,r,phi);phi:=phi*360/2/pi;
   writev(inhalt,re:12:6);
   set_dtext(baum,anz_re,inhalt,system_font,te_left);
   obj_redraw(baum,anz_re);
   writev(inhalt,im:12:6);
   set_dtext(baum,anz_im,inhalt,system_font,te_left);
   obj_redraw(baum,anz_im);
   writev(inhalt,r:12:6);
   set_dtext(baum,anz_r,inhalt,system_font,te_left);
   obj_redraw(baum,anz_r);
   writev(inhalt,phi:12:6);
   set_dtext(baum,anz_phi,inhalt,system_font,te_left);
   obj_redraw(baum,anz_phi);
  end;
  ex:=redo_dialog(baum,0);
  obj_setstate(baum,ex,0,true);
  end;
  End_dialog(baum);
  Exit_Gem;
 end;
end.

