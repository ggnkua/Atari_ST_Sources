program DEMO;

(*****************************************************************************)
(*****************************************************************************)
(*                                                                           *)
(*  M A T H L I B   (c) 01. MÑrz 1987         Demonstrationsprogramm         *)
(*  =============   -----------------                                        *)
(*                                                                           *)
(*   MATHLIB  ist  eine   Bibliothek  mit   mathematischen   Funktionen  und *)
(*  Prozeduren.  Um  MATHLIB  verwenden zu kînnen,  muû sie in  compilierter *)
(*  Form vorliegen. NÑheres entnehmen Sie bitte der Anleitung.               *)
(*                                                                           *)
(*   Die compilierte Fassung von  MATHLIB  mit den  zugehîrigen  Dateien ist *)
(*  PUBLIC DOMAIN.   Die  Source-Code-Fassung   ist  nicht  frei  kopierbar. *)
(*  Sollten Sie MATHLIB  regelmÑûig verwenden,  so bitte ich Sie,  mir einen *)
(*  ausreichenden Betrag als Anerkennungshonorar zu senden.                  *)
(*                                                                           *)
(*  Auf die Verwendung von ST PASCAL PLUS und MATHLIB ist hinzuweisen.       *)
(*                                                                           *)
(*  Programmiersprache : Pascal (ST PASCAL PLUS von CCD, Eltville,           *)
(*                               Version 1.20)                               *)
(*  Autor              : Dietmar Rabich, Eschenweg 3, 4408 DÅlmen            *)
(*  Datum              : 01.03.1987                                          *)
(*  Version            : 2.1                                                 *)
(*                                                                           *)
(*  ------------------------------------------------------------------------ *)
(*  Dieses kleine Programm soll verdeutlichen,  wie Kommandos aus MATHLIB in *)
(*  Programme eingebaut werden kînnen.                                       *)
(*                                                                           *)
(*  Das DEMO-Programm ist frei kopierbar !!                                  *)
(*  ------------------------------------------------------------------------ *)
(*  ------------------------------------------------------------------------ *)
(*  !!!  Informieren Sie mich  bitte unbedingt bei auftretenden Fehlern  !!! *)
(*  ------------------------------------------------------------------------ *)
(*                                                                           *)
(*  Zum Anerkennungshonorar:                                                 *)
(*                                                                           *)
(*    MATHLIB auf Diskette, mit Anleitung im                                 *)
(*     DIN A 5 - Format, ohne Source-Code    :     mindestens 30.- DM        *)
(*    MATHLIB auf Diskette, mit Anleitung im                                 *)
(*     DIN A 5 - Format, mit Source-Code                                     *)
(*     auf Papier (DIN A 5)                  :     mindestens 50.- DM        *)
(*    MATHLIB auf Diskette, mit Anleitung im                                 *)
(*     DIN A 5 - Format, mit Source-Code                                     *)
(*     auf Diskette und auf Papier (DIN A 5) :     mindestens 80.- DM        *)
(*                                                                           *)
(*    Auf Wunsch erhalten Sie Information Åber neuere Versionen.             *)
(*                                                                           *)
(*****************************************************************************)
(*****************************************************************************)

(*****************************************************************************)
(*              Deklaration von Konstanten, Typen und Variablen              *)
(*****************************************************************************)

const {$I MATHCONS.INC }

type  {$I MATHTYPE.INC }

var antwort : char;
    a,b,c   : matrix; (* Globale Deklaration wg. Speicherplatz *)

(*****************************************************************************)
(*        Deklaration von der Funktionen und Differentialgleichungen         *)
(*****************************************************************************)

{$E+}

{$I FUNDUMMY.INC }
{$I DGLDUMMY.INC }

{$E-}


(*****************************************************************************)
(*            Deklaration der MATHLIB - Prozeduren und Funktionen            *)
(*****************************************************************************)

{$I MATHSUBS.INC }

(*****************************************************************************)
(*       Datei SCREEN.INC, gehîrt zum Lieferumfang von ST PASCAL PLUS        *)
(*****************************************************************************)

{$I SCREEN.INC }

(*****************************************************************************)
(*                         Warten auf SPACE - Taste                          *)
(*****************************************************************************)

procedure warte_space;

 var antwort : char;

 begin
  gotoxy(0,24);
  write ('Bitte drÅcken Sie auf die <SPACE> - Taste.  ');
  repeat
   cur_left;
   write(' ');
   cur_left;
   read(antwort);
  until antwort=' ';
 end;

(*****************************************************************************)
(*                         Information Åber MATHLIB                          *)
(*****************************************************************************)

procedure information;

 begin
  writeln('M A T H L I B  (c) 1.3.1987  V. 2.1  Das Demo ist frei kopierbar.');
  writeln('=============  ------------  ------  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  writeln(' MATHLIB  ist eine Bibliothek  mit mathematischen  Funktionen und');
  writeln('Prozeduren.   Um  MATHLIB   verwenden  zu  kînnen,   muû  sie  in');
  writeln('compilierter  Form vorliegen.  NÑheres  entnehmen  Sie  bitte der');
  writeln('Anleitung.');
  writeln(' Die compilierte Fassung von  MATHLIB mit den zugehîrigen Dateien');
  writeln('ist  PUBLIC  DOMAIN.   Die  Source-Code-Fassung  ist  nicht  frei');
  writeln('kopierbar. Sollten Sie MATHLIB regelmÑûig verwenden, so bitte ich');
  writeln('Sie,  mir einen ausreichenden  Betrag als  Anerkennungshonorar zu');
  writeln('senden. Sie erhalten dann die erforderlichen Dateien.');
  writeln(' Entwickelt  wurde MATHLIB in  ST PASCAL PLUS, CCD Eltville,  von');
  writeln('Dietmar Rabich, Eschenweg 3, 4408 DÅlmen');
  writeln(' Zum Anerkennungshonorar:');
  writeln('  MATHLIB auf Diskette, mit Anleitung im');
  writeln('   DIN A 5 - Format, ohne Source-Code    :     mindestens 30.- DM');
  writeln('  MATHLIB auf Diskette, mit Anleitung im');
  writeln('   DIN A 5 - Format, mit Source-Code');
  writeln('   auf Papier (DIN A 5)                  :     mindestens 50.- DM');
  writeln('  MATHLIB auf Diskette, mit Anleitung im');
  writeln('   DIN A 5 - Format, mit Source-Code');
  writeln('   auf Diskette und auf Papier (DIN A 5) :     mindestens 80.- DM');
  writeln('  (Auf Wunsch erhalten Sie Information Åber neuere Versionen.)');
  warte_space;
 end;

(*****************************************************************************)
(*                         Untersuchungen von Zahlen                         *)
(*****************************************************************************)

procedure zahlen;

 var liste    : liste_lint;
     i,m      : integer;
     basis    : real;
     exponent : long_integer;

 begin
  inverse_on;
  writeln ('ZAHLEN');
  inverse_off;
  writeln;
  writeln ('Untersucht werden die Zahlen 17989 und 2740.');
  writeln;
  write (17989,' ');
  if prim(17989) then writeln ('ist eine Primzahl.')
                 else writeln ('ist keine Primzahl.');
  write (2740,' ');
  if prim(2740) then writeln ('ist eine Primzahl.')
                 else writeln ('ist keine Primzahl.');
  writeln;
  primfak(17989,liste,m);
  writeln (17989,' hat folgend(e) ',m,' Primfaktor(en):');
  for i:=1 to m do write (liste[i],' ');
  writeln;
  teiler(17989,liste,m);
  writeln (17989,' hat folgende ',m,' Teiler:');
  for i:=1 to m do write (liste[i],' ');
  writeln;
  writeln;
  primfak(2740,liste,m);
  writeln (2740,' hat folgend(e) ',m,' Primfaktor(en):');
  for i:=1 to m do write (liste[i],' ');
  writeln;
  teiler(2740,liste,m);
  writeln (2740,' hat folgende ',m,' Teiler:');
  for i:=1 to m do write (liste[i],' ');
  writeln;
  writeln;
  write ('ggt(',348,',',972,')=',ggt(348,972));
  writeln (', kgv(',348,',',972,')=',kgv(348,972));
  writeln;
  write ('Einen kleinen Augenblick bitte, Berechnung von 10000! .');
  fak_n(10000,basis,exponent);
  delete_line;
  writeln (10000,'! =',basis,'E',exponent);
  writeln;
  pot_n(56,345,basis,exponent);
  writeln (56,'^',345,'=',basis,'E',exponent);
  warte_space;
 end;

(*****************************************************************************)
(*                          Zahl in Wort Åbersetzen                          *)
(*****************************************************************************)

procedure zahl_uebersetzen;

 var i,m : integer;
     zk  : string;

 begin
  inverse_on;
  writeln ('ZAHL IN WORT öBERSETZEN');
  inverse_off;
  writeln;
  for i:=1 to 15 do
   begin
    m:=trunc(i*pi*e);
    uebersetze(m,zk);
    writeln (m,' sieht ausgeschrieben so aus: ',zk);
   end;
  warte_space;
 end;

(*****************************************************************************)
(*                         Berechnungen mit Vektoren                         *)
(*****************************************************************************)

procedure vektoren;

 var v,w,x : dreiervektor;
     v2,w2 : vektor;
     i     : integer;

 begin
  inverse_on;
  writeln ('VEKTOREN');
  inverse_off;
  writeln;
  v[1]:=1; v[2]:=4; v[3]:=7;
  w[1]:=1; w[2]:=4; w[3]:=-1;
  writeln ('Betrachte: (',v[1],',',v[2],',',v[3],')');
  writeln ('       und (',w[1],',',w[2],',',w[3],')');
  writeln;
  kr_prod(v,w,x);
  writeln ('Senkrecht auf beiden steht: (',x[1]:6,',',x[2]:6,',',x[3]:6,')');
  writeln;
  for i:=1 to 3 do v2[i]:=v[i];
  for i:=1 to 3 do w2[i]:=w[i];
  writeln ('Das Skalarprodukt ist:',sk_prod(v2,w2,3));
  writeln;
  writeln ('Vom ersten Vektor sind die Normen:');
  writeln (' Norm 1:',v_no1(v2,3));
  writeln (' Norm 2:',v_no2(v2,3));
  writeln (' Norm 3:',v_no3(v2,3));
  writeln;
  writeln ('Vom zweiten Vektor sind die Normen:');
  writeln (' Norm 1:',v_no1(w2,3));
  writeln (' Norm 2:',v_no2(w2,3));
  writeln (' Norm 3:',v_no3(w2,3));
  warte_space;
 end;

(*****************************************************************************)
(*                         Berechnungen mit Matrizen                         *)
(*****************************************************************************)

procedure matrizen;

 var d : real;

 procedure ausgabe_matrix (ma : matrix; m,n : integer; px,py : integer);

  var i,j : integer;

  begin
   for i:=1 to m do
    for j:=1 to n do
     begin
      gotoxy (px+(j-1)*8,py+(i-1));
      write (ma[i,j]:7);
     end;
  end;

 begin
  inverse_on;
  writeln ('MATRIZEN');
  inverse_off;
  writeln;
  a[1,1]:=1;  a[1,2]:=1;  a[1,3]:=1;  a[1,4]:=-7;
  a[2,1]:=0;  a[2,2]:=1;  a[2,3]:=0;  a[2,4]:=1;
  a[3,1]:=0;  a[3,2]:=1;  a[3,3]:=-5; a[3,4]:=1;
  a[4,1]:=1;  a[4,2]:=-4; a[4,3]:=1;  a[4,4]:=1;
  b[1,1]:=3;  b[1,2]:=5;  b[1,3]:=-1; b[1,4]:=1;
  b[2,1]:=1;  b[2,2]:=3;  b[2,3]:=8;  b[2,4]:=1;
  b[3,1]:=6;  b[3,2]:=1;  b[3,3]:=1;  b[3,4]:=9;
  b[4,1]:=1;  b[4,2]:=4;  b[4,3]:=1;  b[4,4]:=1;
  gotoxy (0,2);
  writeln ('A:');
  ausgabe_matrix (a,4,4,0,4);
  gotoxy (40,2);
  writeln ('B:');
  ausgabe_matrix (b,4,4,40,4);
  gotoxy (0,9);
  m_inv(b,c,4,d);
  writeln ('Inverse von B:');
  ausgabe_matrix (c,4,4,0,11);
  gotoxy (40,9);
  m_mult(c,b,c,4,4,4);
  writeln ('B_inv * B:');
  ausgabe_matrix (c,4,4,40,11);
  gotoxy (0,16);
  m_mult(a,b,c,4,4,4);
  writeln ('A * B:');
  ausgabe_matrix (c,4,4,0,18);
  gotoxy (40,16);
  m_trans(a,c,4,4);
  writeln ('Transponierte von A:');
  ausgabe_matrix (c,4,4,40,18);
  warte_space;
 end;

(*****************************************************************************)
(*                   Verschiedene Vergleiche mit Vektoren                    *)
(*****************************************************************************)

procedure vergleiche;

 var v,w : vektor;

 begin
  inverse_on;
  writeln ('VERGLEICHE');
  inverse_off;
  writeln;
  v[1]:=3; v[2]:=6; v[3]:=9;
  w[1]:=7; w[2]:=3; w[3]:=8;
  writeln ('Betrachte: (',v[1],',',v[2],',',v[3],')');
  writeln ('       und (',w[1],',',w[2],',',w[3],')');
  writeln;
  if v_gl(v,w,3) then
   writeln ('Beide Vektoren haben gleiche Komponenten.');
  if v_ungl(v,w,3) then
   writeln ('Mind. eine Komponente in beiden Vektoren ist unterschiedlich.');
  if lex_gr(v,w,3) then
   writeln ('Der erste Vektor ist lexikographisch grîûer als der zweite.');
  if lex_kl(v,w,3) then
   writeln ('Der erste Vektor ist lexikographisch kleiner als der zweite.');
  if v_mw(v,3) then
   writeln ('Die Komponenten des ersten Vektors sind monoton wachsend.')
   else
   writeln ('Die Komponenten des ersten Vektors sind nicht monoton wachsend.');
  if v_mf(v,3) then
   writeln ('Die Komponenten des ersten Vektors sind monoton fallend.')
   else
   writeln ('Die Komponenten des ersten Vektors sind nicht monoton fallend.');
  if v_mw(w,3) then
   writeln ('Die Komponenten des zweiten Vektors sind monoton wachsend.')
   else
   writeln('Die Komponenten des zweiten Vektors sind nicht monoton wachsend.');
  if v_mf(w,3) then
   writeln ('Die Komponenten des zweiten Vektors sind monoton fallend.')
   else
   writeln ('Die Komponenten des zweiten Vektors sind nicht monoton fallend.');
  warte_space;
 end;

(*****************************************************************************)
(*          Berechnung der Lîsung eines linearen Gleichungssystems           *)
(*****************************************************************************)

procedure lineares_gleichsys;

 var b,x : glvektor;
     d   : real;
     i   : integer;

 procedure ausgabe_matrix (ma : matrix; m,n : integer; px,py : integer);

  var i,j : integer;

  begin
   for i:=1 to m do
    for j:=1 to n do
     begin
      gotoxy (px+(j-1)*10,py+(i-1));
      write (ma[i,j]:9);
     end;
  end;

 begin
  inverse_on;
  writeln ('LINEARES GLEICHUNGSSYSTEM');
  inverse_off;
  gotoxy (0,2);
  write ('Gegeben das Gleichungssystem:');
  a[1,1]:=1;  a[1,2]:=1;  a[1,3]:=0;  a[1,4]:=0;  a[1,5]:=-1;
  a[2,1]:=2;  a[2,2]:=4;  a[2,3]:=2;  a[2,4]:=8;  a[2,5]:=10;
  a[3,1]:=4;  a[3,2]:=-3; a[3,3]:=9;  a[3,4]:=12; a[3,5]:=15;
  a[4,1]:=3;  a[4,2]:=8;  a[4,3]:=10; a[4,4]:=6;  a[4,5]:=-2;
  a[5,1]:=5;  a[5,2]:=-1; a[5,3]:=2;  a[5,4]:=9;  a[5,5]:=12;
  gotoxy (0,4);
  ausgabe_matrix (a,5,5,2,4);
  b[1]:=2;  b[2]:=2;  b[3]:=3;  b[4]:=4;  b[5]:=8;
  for i:=1 to 5 do
   begin
    gotoxy (60,3+i);
    write (b[i]);
   end;
  lin_gl_sys(a,b,x,5,d);
  gotoxy (2,10);
  write ('Lîsung:');
  for i:=1 to 5 do
   begin
    gotoxy (5,11+i);
    write ('x(',i,')=',x[i]);
   end;
  warte_space;
 end;

(*****************************************************************************)
(*                       Berechnung einer Determinante                       *)
(*****************************************************************************)

procedure determinante;

 procedure ausgabe_matrix (ma : matrix; m,n : integer; px,py : integer);

  var i,j : integer;

  begin
   for i:=1 to m do
    for j:=1 to n do
     begin
      gotoxy (px+(j-1)*10,py+(i-1));
      write (ma[i,j]:9);
     end;
  end;

 begin
  inverse_on;
  writeln ('DETERMINANTE');
  inverse_off;
  gotoxy (0,2);
  write ('Gegeben ist die Matrix:');
  a[1,1]:=17; a[1,2]:=-1; a[1,3]:=27; a[1,4]:=10; a[1,5]:=62;
  a[2,1]:=0;  a[2,2]:=0;  a[2,3]:=10; a[2,4]:=1;  a[2,5]:=0;
  a[3,1]:=87; a[3,2]:=17; a[3,3]:=4;  a[3,4]:=80; a[3,5]:=-65;
  a[4,1]:=0;  a[4,2]:=-4; a[4,3]:=0;  a[4,4]:=-1; a[4,5]:=43;
  a[5,1]:=27; a[5,2]:=5;  a[5,3]:=63; a[5,4]:=1;  a[5,5]:=65;
  gotoxy (0,4);
  ausgabe_matrix (a,5,5,2,4);
  gotoxy (0,14);
  write ('Determinante = ',det(a,5));
  warte_space;
 end;

(*****************************************************************************)
(*                      Prozeduren mit komplexen Zahlen                      *)
(*****************************************************************************)

procedure komplexe_zahlen;

 var x,y,z : complex;

 begin
  inverse_on;
  writeln ('KOMPLEXE ZAHLEN');
  inverse_off;
  writeln;
  y.re:=1;  y.im:=4;
  z.re:=-1; z.im:=8;
  writeln ('Gegeben sind y=',y.re,'+i*',y.im);
  writeln ('         und z=',z.re,'+i*',z.im,'.');
  writeln;
  cc_add(y,z,x);
  writeln ('  y+z   : ',x.re,'+i*',x.im);
  cc_sub(y,z,x);
  writeln ('  y-z   : ',x.re,'+i*',x.im);
  cc_mult(y,z,x);
  writeln ('  y*z   : ',x.re,'+i*',x.im);
  cc_div(y,z,x);
  writeln ('  y/z   : ',x.re,'+i*',x.im);
  cc_exp(y,x);
  writeln ('  exp(y): ',x.re,'+i*',x.im);
  cc_exp(z,x);
  writeln ('  exp(z): ',x.re,'+i*',x.im);
  cc_ln(y,x);
  writeln ('  ln(y) : ',x.re,'+i*',x.im);
  cc_ln(z,x);
  writeln ('  ln(z) : ',x.re,'+i*',x.im);
  warte_space;
 end;

(*****************************************************************************)
(*                     Prozeduren mit rationalen Zahlen                      *)
(*****************************************************************************)

procedure rationale_zahlen;

 var c,a,b : rational;

 begin
  inverse_on;
  writeln ('RATIONALE ZAHLEN');
  inverse_off;
  writeln;
  a.za:=7;  a.ne:=12;
  b.za:=-3; b.ne:=22;
  writeln ('Gegeben sind a=',a.za,'/',a.ne);
  writeln ('         und b=',b.za,'/',b.ne,'.');
  writeln;
  rr_add(a,b,c);
  writeln ('  a+b   : ',c.za,'/',c.ne);
  rr_sub(a,b,c);
  writeln ('  a-b   : ',c.za,'/',c.ne);
  rr_mul(a,b,c);
  writeln ('  a*b   : ',c.za,'/',c.ne);
  rr_div(a,b,c);
  writeln ('  a/b   : ',c.za,'/',c.ne);
  warte_space;
 end;

(*****************************************************************************)
(*                                  M e n Å                                  *)
(*****************************************************************************)

procedure menue(var antwort:char);

 procedure titel;

  begin
   gotoxy(10,0);
   write ('Demonstrationsprogramm fÅr MATHLIB, 01.03.1987, Version 1.0');
   gotoxy(10,1);
   write ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   gotoxy(15,3);
   write ('(Entwickelt mit ST PASCAL PLUS von CCD, Eltville.)');
   gotoxy(5,6);
   write ('WÑhlen Sie bitte aus:');
   inverse_on;
   gotoxy(5,9);
   write ('(0) Information und Ende     ');
   gotoxy(5,11);
   write ('(1) Zahlen                   ');
   gotoxy(5,13);
   write ('(2) Zahl Åbersetzen          ');
   gotoxy(5,15);
   write ('(3) Vektoren                 ');
   gotoxy(5,17);
   write ('(4) Matrizen                 ');
   gotoxy(45,9);
   write ('(5) Vergleiche               ');
   gotoxy(45,11);
   write ('(6) Lineares Gleichungssystem');
   gotoxy(45,13);
   write ('(7) Determinante             ');
   gotoxy(45,15);
   write ('(8) Komplexe Zahlen          ');
   gotoxy(45,17);
   write ('(9) Rationale Zahlen         ');
   inverse_off;
   gotoxy(2,22);
   write ('Ihre Wahl:  ');
  end;

 begin
  clear_home;
  titel;
  repeat
   cur_left;
   write(' ');
   cur_left;
   read(antwort);
  until antwort in ['0'..'9'];
 end;

(*****************************************************************************)
(*                         H A U P T P R O G R A M M                         *)
(*****************************************************************************)

begin
 select_color(0);
 select_background(1);
 antwort:=' ';
 repeat
  menue(antwort);
  clear_home;
  case antwort of
    '0' : information;
    '1' : zahlen;
    '2' : zahl_uebersetzen;
    '3' : vektoren;
    '4' : matrizen;
    '5' : vergleiche;
    '6' : lineares_gleichsys;
    '7' : determinante;
    '8' : komplexe_zahlen;
    '9' : rationale_zahlen;
   end;
 until antwort='0';
 select_color(1);
 select_background(0);
end.

(*****************************************************************************)
(***********                P R O G R A M M E N D E                ***********)
(*****************************************************************************)
