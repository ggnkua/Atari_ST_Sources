(*****************************************************************************)
(*****************************************************************************)
(*                                                                           *)
(*  M A T H L I B   (c) 01. MÑrz 1987   Funktions- und Prozedurdeklarationen *)
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


(* ><><><><>< Deklarationen aus MATHLIB1 ><><><><>< *)

{----- I N F O -----}
procedure mathlib_info(var str:str255; gem:boolean);
 EXTERNAL;

{----- Zahl in Wort umwandeln -----}
procedure uebersetze(n : long_integer; var worterg : string);
 EXTERNAL;

{----- Integerpotenz -----}
function int_pot(n : integer; m : integer) : long_integer;
 EXTERNAL;

{----- Realpotenz -----}
function real_pot(a : real; b : real) : real;
 EXTERNAL;

{----- pi, Ludolphsche Zahl -----}
function pi:real;
 EXTERNAL;

{----- e, Eulersche Zahl -----}
function e:real;
 EXTERNAL;

{----- Euler-Mascheronische Konstante -----}
function gamma:real;
 EXTERNAL;

{----- 10er Logarithmus -----}
function log(x : real) : real;
 EXTERNAL;

{----- Kehrwert ------}
function rec(x : real) : real;
 EXTERNAL;

{----- Signum -----}
function sign(x : real) : integer;
 EXTERNAL;

{----- sekans -----}
function sec(x : real) : real;
 EXTERNAL;

{----- cosekans -----}
function cosec(x : real) : real;
 EXTERNAL;

{----- tangens -----}
function tan(x : real) : real;
 EXTERNAL;

{----- cotangens ------}
function cotan(x : real) : real;
 EXTERNAL;

{----- arcussinus -----}
function arcsin(x : real) : real;
 EXTERNAL;

{----- arcuscosinus -----}
function arccos(x : real) : real;
 EXTERNAL;

{----- arcussekans -----}
function arcsec(x : real) : real;
 EXTERNAL;

{----- arcuscosekans -----}
function arccosec(x : real) : real;
 EXTERNAL;

{----- arcuscotangens -----}
function arccotan(x : real) : real;
 EXTERNAL;

{----- sinus hyperbolicus -----}
function sinh(x : real) : real;
 EXTERNAL;

{----- cosinus hyperbolicus -----}
function cosh(x : real) : real;
 EXTERNAL;

{----- tangens hyperbolicus -----}
function tanh(x : real) : real;
 EXTERNAL;

{----- cotangens hyperbolicus -----}
function cotanh(x : real) : real;
 EXTERNAL;

{----- sekans hyperbolicus -----}
function sech(x : real) : real;
 EXTERNAL;

{----- cosekans hyperbolicus -----}
function cosech(x : real) : real;
 EXTERNAL;

{----- areasinus hyperbolicus -----}
function arsinh(x : real) : real;
 EXTERNAL;

{----- areacosinus hyperbolicus -----}
function arcosh(x : real) : real;
 EXTERNAL;

{----- areatangens hyperbolicus -----}
function artanh(x : real) : real;
 EXTERNAL;

{----- areacotangens hyperbolicus -----}
function arcotanh(x : real) : real;
 EXTERNAL;

{----- areasekans hyperbolicus -----}
function arsech(x : real) : real;
 EXTERNAL;

{----- areacosekans hyperbolicus -----}
function arcosech(x : real) : real;
 EXTERNAL;

{----- Bogenmaû ---> Altgrad -----}
function grad(b : real) : real;
 EXTERNAL;

{----- Altgrad ---> Bogenmaû -----}
function bogen(g : real) : real;
 EXTERNAL;

{----- arithmetisches Mittel -----}
function ari_mit(a : long_vektor; n : long_dim) : real;
 EXTERNAL;

{----- geometrisches Mittel -----}
function geo_mit(a : long_vektor; n : long_dim) : real;
 EXTERNAL;

{----- harmonisches Mittel -----}
function har_mit(a : long_vektor; n : long_dim) : real;
 EXTERNAL;

{----- quadratisches Mittel -----}
function qua_mit(a : long_vektor; n : long_dim) : real;
 EXTERNAL;

{----- Varianz -----}
function varianz(a : long_vektor; n : long_dim) : real;
 EXTERNAL;

{----- Standardabweichung -----}
function stand_abw(a : long_vektor; n : long_dim) : real;
 EXTERNAL;

{----- 1. Ableitung stetig diffbarer Funktionen (keine Randpunkte!) -----}
function diff1_m(         x : real;
                       fktn : fktnnummer;
                 var erfolg : boolean;
                    manuell : boolean;
                       abst : real) : real;
 EXTERNAL;

{----- 2. Ableitung stetig diffbarer Funktionen (keine Randpunkte!) -----}
function diff2_m(         x : real;
                       fktn : fktnnummer;
                 var erfolg : boolean;
                    manuell : boolean;
                       abst : real) : real;
 EXTERNAL;

{----- 1. Ableitung stetig differenzierbarer Funktionen (linker Rand) -----}
function diff1_l(         x : real;
                       fktn : fktnnummer;
                 var erfolg : boolean;
                    manuell : boolean;
                       abst : real) : real;
 EXTERNAL;

{----- 2. Ableitung stetig differenzierbarer Funktionen (linker Rand) -----}
function diff2_l(         x : real;
                       fktn : fktnnummer;
                 var erfolg : boolean;
                    manuell : boolean;
                       abst : real) : real;
 EXTERNAL;

{----- 1. Ableitung stetig differenzierbarer Funktionen (rechter Rand) -----}
function diff1_r(         x : real;
                       fktn : fktnnummer;
                 var erfolg : boolean;
                    manuell : boolean;
                       abst : real) : real;
 EXTERNAL;

{----- 2. Ableitung stetig differenzierbarer Funktionen (rechter Rand) -----}
function diff2_r(         x : real;
                       fktn : fktnnummer;
                 var erfolg : boolean;
                    manuell : boolean;
                       abst : real) : real;
 EXTERNAL;

{----- Integration nach Simpson -----}
function int(a,b : real; n : integer; fktn : fktnnummer) : real;
 EXTERNAL;

{----- Nullstellensuche (nach NEWTON) -----}
procedure nullst(var x : real; var nst : boolean; fktn : fktnnummer);
 EXTERNAL;

{----- Wertetabelle -----}
procedure tabelle(var  werte : wertetabelle;
                       a,b,h : real;
                  var      n : long_dim;
                        fktn : fktnnummer;
                  var berech : boolean);
 EXTERNAL;

{----- explizite, gewîhnliche Differentialgleichung 1. Ordnung -----}
procedure gew_dgl(  x0,y0,h : real;
                          n : long_dim;
                  var werte : wertetabelle;
                     nummer : dglnummer    );
 EXTERNAL;

{----- Summe -----}
function summe(nummer : fktnnummer; n,m : integer) : real;
 EXTERNAL;

{----- Produkt -----}
function produkt(nummer : fktnnummer; n,m : integer) : real;
 EXTERNAL;

{----- Folge -----}
procedure folge(nummer : fktnnummer; n,m : long_dim; var lst : liste_real);
 EXTERNAL;


(* ><><><><>< Deklarationen aus MATHLIB2 ><><><><>< *)

{----- Primzahltest -----}
function prim(n : long_integer) : boolean;
 EXTERNAL;

{----- Teiler -----}
procedure teiler(n : long_integer; var tlr : liste_lint; var m : integer);
 EXTERNAL;

{----- Primfaktoren -----}
procedure primfak(n : long_integer; var pf : liste_lint; var m : integer);
 EXTERNAL;

{----- lineares Gleichungssystem -----}
procedure lin_gl_sys(a : matrix; b : glvektor; var x : glvektor;
                     n : dimension; var d : real);
 EXTERNAL;

{----- sortieren, INTEGER -----}
procedure sort_int(var erste,zweite : liste_int;
                                  n : long_dim;
                          aufwaerts : boolean);
 EXTERNAL;

{----- sortieren, LONG_INTEGER -----}
procedure sort_lint(var erste,zweite : liste_lint;
                                  n : long_dim;
                          aufwaerts : boolean);
 EXTERNAL;

{----- sortieren, REAL -----}
procedure sort_real(var erste,zweite : liste_real;
                                  n : long_dim;
                          aufwaerts : boolean);
 EXTERNAL;

{----- FakultÑt, LONG_INTEGER -----}
function fak_lint(n : integer; var ausf : boolean) : long_integer;
 EXTERNAL;

{----- FakultÑt, REAL -----}
function fak_real(n : integer; var ausf : boolean) : real;
 EXTERNAL;

{----- FakultÑtnÑherung -----}
procedure fak_n(n : integer; var basis : real; var exponent : long_integer);
 EXTERNAL;

{----- PotenznÑherung -----}
procedure pot_n(n,m : integer; var basis : real; var exponent : long_integer);
 EXTERNAL;

{----- Binomialkoeffizient -----}
function bin_koeff(n,k : integer) : long_integer;
 EXTERNAL;

{----- Matrixinversion -----}
procedure m_inv(a         : matrix;
                var a_inv : matrix;
                        n : dimension;
                var     d : real      );
 EXTERNAL;

{----- Matrizenmultiplikation -----}
procedure m_mult(a,b : matrix; var c : matrix; m,n,k : dimension);
 EXTERNAL;

{----- Matrizenaddition -----}
procedure m_add(a,b : matrix; var c : matrix; m,n : dimension);
 EXTERNAL;

{----- Matrizensubtraktion -----}
procedure m_sub(a,b : matrix; var c : matrix; m,n : dimension);
 EXTERNAL;

{----- Transponierte Matrix -----}
procedure m_trans(a : matrix; var a_trans : matrix; m,n : dimension);
 EXTERNAL;

{----- Skalarprodukt -----}
function sk_prod(a,b : vektor; n : short_dim) : real;
 EXTERNAL;

{----- Kreuzprodukt -----}
procedure kr_prod(a,b : dreiervektor; var c : dreiervektor);
 EXTERNAL;

{----- Vektorsubtraktion, a-b -----}
procedure v_sub(a,b : vektor; var c : vektor; n : short_dim);
 EXTERNAL;

{----- Vektoraddition, a+b -----}
procedure v_add(a,b : vektor; var c : vektor; n : short_dim);
 EXTERNAL;

{----- dyadisches Produkt -----}
procedure dyad_prod(a,b : glvektor; var p : matrix; m,n : dimension);
 EXTERNAL;

{----- Matrix * Vektor -----}
procedure matvek(a : matrix; b : glvektor; var c : glvektor; m,n : dimension);
 EXTERNAL;

{----- Vektor * Matrix -----}
procedure vekmat(b : glvektor; a : matrix; var c : glvektor; m,n : dimension);
 EXTERNAL;

{----- Determinante -----}
function det(a : matrix; n : dimension) : real;
 EXTERNAL;

{<<<<< 1. Teil >>>>>}
{----- komplexer Betrag -----}
function c_abs(a1,b1 : real) : real;
 EXTERNAL;

{----- komplexe Multiplikation, z0*z1 -----}
procedure c_mult(a0,b0,a1,b1 : real; var re,im : real);
 EXTERNAL;

{----- komplexe Division, z0/z1 -----}
procedure c_div(a0,b0,a1,b1 : real; var re,im : real);
 EXTERNAL;

{----- komplexe Addition, z0+z1 -----}
procedure c_add(a0,b0,a1,b1 : real; var re,im : real);
 EXTERNAL;

{----- komplexe Subtraktion, z0-z1 -----}
procedure c_sub(a0,b0,a1,b1 : real; var re,im : real);
 EXTERNAL;

{----- konjugiert Komplexes -----}
procedure c_conj(a,b : real; var re,im : real);
 EXTERNAL;

{----- komplexe Exponentialfunktion -----}
procedure c_exp(a,b : real; var re,im : real);
 EXTERNAL;

{----- komplexer Logarithmus, Hauptwert -----}
procedure c_ln(a,b : real; var re,im : real);
 EXTERNAL;

{<<<<< 2. Teil >>>>>}
{----- komplexer Betrag -----}
function cc_abs(z : complex) : real;
 EXTERNAL;

{----- komplexe Multiplikation, z0*z1 -----}
procedure cc_mult(z1,z2 : complex; var z : complex);
 EXTERNAL;

{----- komplexe Division, z0/z1 -----}
procedure cc_div(z1,z2 : complex; var z : complex);
 EXTERNAL;

{----- komplexe Addition, z0+z1 -----}
procedure cc_add(z1,z2 : complex; var z : complex);
 EXTERNAL;

{----- komplexe Subtraktion, z0-z1 -----}
procedure cc_sub(z1,z2 : complex; var z : complex);
 EXTERNAL;

{----- konjugiert Komplexes -----}
procedure cc_conj(z0 : complex; var z : complex);
 EXTERNAL;

{----- komplexe Exponentialfunktion -----}
procedure cc_exp(z0 : complex; var z : complex);
 EXTERNAL;

{----- komplexer Logarithmus, Hauptwert -----}
procedure cc_ln(z0 : complex; var z : complex);
 EXTERNAL;

{----- Grîûter gemeinsamer Teiler -----}
function ggt(a,b : long_integer) : long_integer;
 EXTERNAL;

{----- Kleinstes gemeinsames Vielfaches -----}
function kgv(a,b : long_integer) : long_integer;
 EXTERNAL;

{<<<<< 1. Teil >>>>>}
{----- Addition von BrÅchen -----}
procedure r_add(rz0,rn0,rz1,rn1 : long_integer; var rz,rn : long_integer);
 EXTERNAL;

{----- Subtraktion von BrÅchen -----}
procedure r_sub(rz0,rn0,rz1,rn1 : long_integer; var rz,rn : long_integer);
 EXTERNAL;

{----- Multiplikation von BrÅchen -----}
procedure r_mul(rz0,rn0,rz1,rn1 : long_integer; var rz,rn : long_integer);
 EXTERNAL;

{----- Division von BrÅchen -----}
procedure r_div(rz0,rn0,rz1,rn1 : long_integer; var rz,rn : long_integer);
 EXTERNAL;

{----- KÅrzen von BrÅchen -----}
procedure r_kuerz(rz0,rn0 : long_integer; var rz,rn : long_integer);
 EXTERNAL;

{<<<<< 2. Teil >>>>>}
{----- Addition von BrÅchen -----}
procedure rr_add(r0,r1 : rational; var r : rational);
 EXTERNAL;

{----- Subtraktion von BrÅchen -----}
procedure rr_sub(r0,r1 : rational; var r : rational);
 EXTERNAL;

{----- Multiplikation von BrÅchen -----}
procedure rr_mul(r0,r1 : rational; var r : rational);
 EXTERNAL;

{----- Division von BrÅchen -----}
procedure rr_div(r0,r1 : rational; var r : rational);
 EXTERNAL;

{----- KÅrzen von BrÅchen -----}
procedure rr_kuerz(r0 : rational; var r : rational);
 EXTERNAL;


(* ><><><><>< Deklarationen aus MATHLIB3 ><><><><>< *)

{----- Maximum der Vektorelemente -----}
function v_max(v : vektor; n : short_dim; var pos : integer) : real;
 EXTERNAL;

{----- Minimum der Vektorelemente -----}
function v_min(v : vektor; n : short_dim; var pos : integer) : real;
 EXTERNAL;

{----- Summe der Vektorelemente -----}
function v_sum(v : vektor; n : short_dim) : real;
 EXTERNAL;

{----- Produkt der Vektorelemente -----}
function v_prod(v : vektor; n : short_dim) : real;
 EXTERNAL;

{----- Absolutbetrag der Vektorelemente -----}
procedure v_abs(v1 : vektor; var v2 : vektor; n : short_dim);
 EXTERNAL;

{----- Maximumnorm des Vektors -----}
function v_no1(v : vektor; n : short_dim) : real;
 EXTERNAL;

{----- euklidische Norm des Vektors -----}
function v_no2(v : vektor; n : short_dim) : real;
 EXTERNAL;

{----- L1-Norm des Vektors -----}
function v_no3(v : vektor; n : short_dim) : real;
 EXTERNAL;

{----- Gesamtnorm der Matrix -----}
function m_no1(mat : matrix; m,n : dimension) : real;
 EXTERNAL;

{----- Zeilensummennorm der Matrix -----}
function m_no2(mat : matrix; m,n : dimension) : real;
 EXTERNAL;

{----- Spaltensummennorm der Matrix -----}
function m_no3(mat : matrix; m,n : dimension) : real;
 EXTERNAL;

{----- Frobenius-Norm der Matrix -----}
function m_no4(mat : matrix; m,n : dimension) : real;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente gleich -----}
function v_gl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente ungleich -----}
function v_ungl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente grîûer -----}
function v_gr(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente kleiner -----}
function v_kl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente grîûer oder gleich -----}
function v_grgl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente kleiner oder gleich -----}
function v_klgl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente gleich -----}
function m_gl(a,b : matrix; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente ungleich -----}
function m_ungl(a,b : matrix; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente grîûer -----}
function m_gr(a,b : matrix; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente kleiner -----}
function m_kl(a,b : matrix; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente grîûer oder gleich -----}
function m_grgl(a,b : matrix; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente kleiner oder gleich -----}
function m_klgl(a,b : matrix; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente gleich Skalar -----}
function vs_gl(v : vektor; s : real; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente ungleich Skalar -----}
function vs_ungl(v : vektor; s : real; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente grîûer Skalar -----}
function vs_gr(v : vektor; s : real; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente kleiner Skalar -----}
function vs_kl(v : vektor; s : real; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente grîûer oder gleich Skalar -----}
function vs_grgl(v : vektor; s : real; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektorenelemente kleiner oder gleich Skalar -----}
function vs_klgl(v : vektor; s : real; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente gleich Skalar -----}
function ms_gl(a : matrix; s : real; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente ungleich Skalar -----}
function ms_ungl(a : matrix; s : real; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente grîûer Skalar -----}
function ms_gr(a : matrix; s : real; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente kleiner Skalar -----}
function ms_kl(a : matrix; s : real; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente grîûer oder gleich Skalar -----}
function ms_grgl(a : matrix; s : real; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Matrixelemente kleiner oder gleich Skalar -----}
function ms_klgl(a : matrix; s : real; m,n : dimension) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektoren lexikographisch gleich -----}
function lex_gl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektoren lexikographisch ungleich -----}
function lex_ungl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektoren lexikographisch grîûer -----}
function lex_gr(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektoren lexikographisch kleiner -----}
function lex_kl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektoren lexikographisch grîûer oder gleich -----}
function lex_grgl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- PrÅfen, ob Vektoren lexikographisch kleiner oder gleich -----}
function lex_klgl(v,w : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- Vektor umdrehen -----}
procedure v_rev(v : vektor; var w : vektor; n : short_dim);
 EXTERNAL;

{----- Vektor * Skalar -----}
procedure veksk(v : vektor; s : real; var w : vektor; n : short_dim);
 EXTERNAL;

{----- Matrix * Skalar -----}
procedure matsk(a : matrix; s : real; var b : matrix; m,n : dimension);
 EXTERNAL;

{-----  Mittel aus Vektor -----}
procedure ve_mit(v : vektor; var w : vektor; n : short_dim);
 EXTERNAL;

{-----  Differenz aus Vektor -----}
procedure ve_dif(v : vektor; var w : vektor; n : short_dim);
 EXTERNAL;

{-----  Summe aus Vektor -----}
procedure ve_sum(v : vektor; var w : vektor; n : short_dim);
 EXTERNAL;

{----- Abstand Vektorelemente zu Skalar -----}
procedure ve_dist(v : vektor; s : real; var w : vektor; n : short_dim);
 EXTERNAL;

{----- Monotonie der Vektorelemente -----}
procedure ve_mon(v : vektor; var w : vektor; n : short_dim);
 EXTERNAL;

{----- Monotonie des Vektors, monoton wachsend -----}
function v_mw(v : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- Monotonie des Vektors, monoton fallend -----}
function v_mf(v : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- Monotonie des Vektors, konstant -----}
function v_ko(v : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- Monotonie des Vektors, streng monoton wachsend -----}
function v_stmw(v : vektor; n : short_dim) : boolean;
 EXTERNAL;

{----- Monotonie des Vektors, streng monoton fallend -----}
function v_stmf(v : vektor; n : short_dim) : boolean;
 EXTERNAL;


(* ENDE der Deklarationen *)
