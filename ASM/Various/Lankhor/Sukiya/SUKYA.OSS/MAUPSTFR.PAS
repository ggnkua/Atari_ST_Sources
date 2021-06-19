{$U746}
program MAUPITI;
const
{$I C:\PASCAL\GEMCONST.PAS}
 ti= 60;          (* 60 en version finale *)
 dhd= 20;         (* nb demi heure debut, amenant a 10 h du mat pour ce jeu *)
 ltext1= 1742;
 llong1= 470;
 ltext2= 576;
 llong2= 160;
 ltext3= 9118;
 llong3= 966;
 ltext4= 9996;
 llong4= 204;
 ltext5= 4170;    (* fichier texte: longueur paire *)
 llong5= 206;     (* fichier longueur *)
 ltext6= 1696;
 llong6= 270;
 ltext7= 18112;
 llong7= 902;
 ldonnee= 41886;
 lechant= 52370;
 lphrase= 38798;
 lsauv= 3058;
 npmaxsd= 39;      (* nbre de phrase maxi select dialogue *)
 npmaxtd= 2;       (* nbre de phrase maxi non select dialogue *)
 nbobof= 10;       (* nbre d'objet ouvert ou ferme maxi par piece *)
 nbobj= 4;         (* nbre d'objet maxi par chaine *)
 noppo= 93;        (* nbre d'opposition maximum (table 203...) *)
 doppo= 74;        (* nbre de derniere rep possibles (table 279...) *)
 nchob= 65;        (* nbre de chaine objets/OBJET *)
 nchen= 11;        (* nbre de chaine objets/ENDROIT *)
 moblo= 4;         (* nbre max objet loupe/piece *)
 totlo= 54;        (* nbre total objet present, absent, loupe *)
 nevlo= 7;         (* nbre d'evenement loupe *)
 nevob= 10;        (* nbre d'evenement objet *)
 nevan= 32;        (* nbre d'evenement animation *)
 nmort= 7;         (* nbre de mort ou assomer possible *)
 nlieu= 29;        (* nbre de lieu correspondant a s.mlieu *)
 noval= 140;       (* nbre d'objet a valider *)
 touch= 6;         (* nbre max d'endroit a toucher sur un objet *)
 seq= 10;          (* nbre max de sequence sur objet a toucher *)
 mpp= 5;           (* maximum possibilite pourcentage sur parlee *)
 mpo= 15;          (*     "                      "    sur objet *)
 mpe= 5;           (*     "                      "    sur ecriture *)
 ladfixe= 4100;    (* longueur non definitive de la zone adfixe *)
 lsprit= 10840;    (* longueur definitive de la zone sprite *)

type
 {$I C:\PASCAL\GEMTYPE.PAS}
 thxys= array[0..npmaxsd] of integer;
 thxyt= array[0..npmaxtd] of integer;
 sa= record
      mlieu, nbdh, nbdm, ener, conf: integer;
      qui, quoi, table, poste: array[0..8] of integer;
      nivop: packed array[0..noppo] of char;
      valop: array[0..noppo] of integer;
      repop: array[0..doppo] of integer;
      chob: array[0..nchob] of array[0..nbobj] of integer;
      chen: array[0..nchen] of array[0..nbobj] of integer;
      chli: array[0..nlieu] of array[0..nbobj] of integer;
      objet: array[0..nbobj] of integer;
      dobj: integer;
      cast: array[0..8] of boolean;
      oval: array[0..noval] of boolean;
      te1auto: array[0..14] of boolean;
      te2auto: array[0..19] of boolean;
      te34auto: array[1..37] of boolean;
      mumus, sous, pourc, pmaj: integer;
      pourcp: array[0..mpp] of boolean;
      pourco: array[0..mpo] of boolean;
      pource: array[0..mpe] of boolean;
      etaob: array[0..totlo] of integer;
      evlo: array[0..nevlo] of boolean;
      evob: array[0..nevob] of boolean;
      ouvfer: array[0..nlieu] of array[0..nbobof] of boolean;
      ndep: array[0..nlieu] of integer;
      hpas: array[0..nlieu] of integer;
      cont: array[1..3] of integer;
      ben: array[1..3] of integer;
      flop, flip: integer;
      dudule: integer;
     end;
 fsauv= sa;

var
 (* pour simili Gem *)
 mtemenu, temenu, mcomenu, comenu: integer;
 mptemenu, ptemenu, mpcomenu, pcomenu: integer;
 mstemenu, stemenu: integer;
 mltemenu, ltemenu: integer;
 motemenu, otemenu, mocomenu, ocomenu: integer;

(* pour JEU *)
 efn, mjou, jou, mheu, heu, min, rmin, mx, my, mmx, mmy: integer;
 cperd, nobj, npla, mpers, memper, mempper, nuchai, mtot, typerd: integer;
 gamelle, nusou: integer;
 abmenu0, aflag1, aflag5, aflag10: long_integer;
 asauv, amempa, atexte, alongt, adonne, aecra1, aecra2, azmasq: long_integer;
 adessi, adesou, adesfe, adespr, adesab, adeslo: long_integer;
 asprit, alettr, asouris, aheure, adfixe, adtext: long_integer;
 atrava, aphrase, aechant, aloupe, amloupe, amasq: long_integer;
 anoeud, aobjet, adobj, aoblo, axoblo, ayoblo: long_integer;
 rdepo, rdepf, rdepp, rdepa, rdepl: long_integer;
 idem, arret, solu, glauque, perdu, assom: boolean;
 mdem, qdedans, cache, ptourn: boolean;
 nuobj: array[0..nbobj] of integer;
 evan: array[0..nevan] of boolean;

(* pour sauvegarde *)
 s: sa;
 fs: fsauv;

(* a inclure dans le fichier memoire, apres supression des inits, peut etre *)

(* {$I C:\INCLUD.OSS\GEMSUBS} *)

                           (*********)
(* NIVEAU *)

function adec: long_integer; external;

function adeplonb(decal, nu: long_integer): long_integer; external;

function adeplonw(decal, nu: long_integer): long_integer; external;

function adsauv: long_integer; external;

procedure afmark(aecra1, x, y, coul: long_integer); external;

procedure afmen(coul, align, xaf, yaf, nbi, anum, mode, aecr,
                atext, along, adtext, alettr, asprit: long_integer); external;

function aftext(centr, atext, along, adec, aecran, apolice,
                x, y, lligne, haut, coul, just, str,
                num: long_integer): long_integer; external;

procedure aprio(num: long_integer); external;

procedure boite(sorte, largeur, y, x, aecran, asprit: long_integer); external;

function charge(ad, long: long_integer): long_integer; external;

procedure chngani(num: long_integer); external;

procedure chngmouse(num, vit: long_integer); external;

procedure coupri; external;

procedure coupson; external;

procedure clrblk(ecran, xh, yh, xb, yb: long_integer); external;

procedure damb(nbdh: long_integer); external;

procedure decomp(aremap, addec, addes,
                 xco, yco, aecra: long_integer); external;

function depadr(ad, nu: long_integer): long_integer; external;

procedure domort(code, apal: long_integer); external;

procedure dpb(bon, mode, xd, yd, xa, ya: long_integer); external;

procedure effets(neffet, style, adessi, aecrd, aecra,
                xh, yh, xb, yb: long_integer); external;

procedure exitani; external;

procedure fric; external;

procedure gnon(buf: long_integer); external;

procedure gotoxy(x, y: long_integer); external;

procedure grossi(aspec, fact, yaff, xaff, ybn, xbn, yhn, xhn,
                 ybg, xbg, yhg, xhg, travail, ecran: long_integer); external;

function hazard(min, max: long_integer): long_integer; external;

procedure hidemouse; external;

procedure initani; external;

procedure initmouse(acharg, amasque, aecrv, aecrc, asprite,
                    arecep: long_integer); external;

procedure initdemo; external;

procedure configsys; external;  (* 520/140 SF/DF *)

(* procedure loadfic; external; *)

procedure loadass; external;    (* abso *)

function loadlieu(buf, dest, nlieu: long_integer): long_integer; external;

procedure loadobjt(buf, dest, nobj, nfic: long_integer); external;

procedure loadpers(a1dech, adphras, npers, fgnon, adcharg,
                   buf, adech: long_integer); external;

procedure loadsuiv(npers, buf, adson: long_integer); external;

function memlib: long_integer; external;

function memres: long_integer; external;

procedure mloupe(amloupe, xco, yco: long_integer); external;

procedure movblk(ecrdp, ecrarr, xh, yh, xb, yb: long_integer); external;

procedure muslire; external;

procedure paljn(nb5, nbdh, lieu: long_integer); external;

procedure paljnf(nb5, nbdh, lieu, amempa, adessi: long_integer); external;

procedure pamb; external;

procedure parole(phrase, echan, affichage, seq, anim,
                 yaff, xaff, trav, hauteur, num: long_integer); external;

function peek(ad: long_integer): long_integer; external;

function peekw(ad: long_integer): long_integer; external;

function peekl(ad: long_integer): long_integer; external;

procedure piano(num: long_integer); external;

procedure poke(ad, ct: long_integer); external;

procedure pokew(ad, ct: long_integer); external;

procedure pokel(ad, ct: long_integer); external;

procedure remapec(aremap, y2, x2, y1, x1,
                  recep, depart: long_integer); external;

procedure resetani; external;

procedure sauve(ad, long: long_integer); external;

function savmem(code, source, desti,
                xgh, ygh, xdb, ydb: long_integer): long_integer; external;

procedure showmouse; external;

procedure suri(num: long_integer); external;

function tailta(ad, nu: long_integer): long_integer; external;

procedure temprio; external;

procedure text_height(height: integer); external;

procedure traclign(aecr, xdep, ydep, xarr, yarr, coul: long_integer); external;

procedure vblsync(nbr: long_integer); external;

function verif: long_integer; external;

(* NIVEAU *)

procedure debugc(a1: integer; a2: long_integer);
var
 su: long_integer;
 cx,cy: integer;
 str: str255;
 tab: array[0..9] of char;
begin
 delete(str,1,length(str));
 if a1<> 0 then a2:= a1;
 if a2<> 0 then
 begin
  tab[0]:= '0';
  tab[1]:= '1';
  tab[2]:= '2';
  tab[3]:= '3';
  tab[4]:= '4';
  tab[5]:= '5';
  tab[6]:= '6';
  tab[7]:= '7';
  tab[8]:= '8';
  tab[9]:= '9';
  if a2< 0 then
  begin
   str:= concat(str, '-');
   a2:= a2* (-1);
  end
  else str:= concat(str, '+');
  su:= 1000000000;
  for cx:= 1 to 10 do
  begin
   cy:= 0;
   repeat
    cy:= cy+ 1;
    a2:= a2- su;
   until a2< 0;
   a2:= a2+ su;
   cy:= cy- 1;
   str:= concat(str, tab[cy]);
   su:= su div 10;
  end;
 end
 else str:= concat(str, '0');
 gotoxy(2,6);  (* (x,y) = (15,48) *)
 writeln('                ');
 gotoxy(2,6);  (* (x,y) = (15,48) *)
 writeln(str);
 for cx:= 1 to 32000 do begin end;
end;


procedure debug(text: str255);
var
 dum: integer;
begin
 gotoxy(2,5);    (* (x,y) = (15,37) *)
 writeln('                              ');
 gotoxy(2,5);    (* (x,y) = (15,37) *)
 writeln(text);
 for dum:= 1 to 32000 do begin end;
end;

(* procedure rect(x, y, w, h: integer);
begin
 hidemouse;
 paint_style(1);
 paint_color(white);
 line_style(1);
 line_color(black);
 frame_rect(x, y, w, h);
 showmouse;
end; *)

(* NIVEAU *)
procedure afmenu(fic: integer;
                 coul, align, xaf, yaf, nbi, anum, mode, aecra: long_integer);
var
 atext, along: long_integer;
begin
 along:= alongt;
 atext:= atexte;
 if fic<> -1 then
 begin
  along:= along+ llong1;
  atext:= atext+ ltext1;
 end;
 afmen(coul, align, xaf, yaf, nbi, anum, mode,
       aecra, atext, along, adtext, (alettr+ peekw(alettr)), asprit);
end;

function dpadr(nu: integer): long_integer;
begin
 dpadr:= depadr(adonne, nu);
end;

(* NIVEAU *)
procedure afmenu0(adr: long_integer);
var
 dum: long_integer;
begin
 dum:= savmem(1, abmenu0, adr, 0, 0, 319, 10);
 if s.dobj<> -1 then
  afmenu(0, 0, 0, peekw(dpadr(267)), 0, 1, adobj, 0, adr);
 if s.sous<> 0 then
  afmen(0, 0, peekw(dpadr(267)+ 2), 0, 1, 0, 0,
        adr, s.sous, -1, adtext, (alettr+ peekw(alettr)), asprit);
end;

procedure afmenu1(adr: long_integer);
var
 dum: long_integer;
 cx: integer;
begin
 dum:= savmem(1, abmenu0, adr, 0, 0, 319, 10);
 for cx:= 0 to 4 do
  afmenu(-1, 0, 0, peekw(dpadr(243)+ (cx* 4)), 0,
          1, (dpadr(260)+ (cx* 2)), 0, adr);
end;

procedure afmenu2(adr: long_integer);
var
 dum: long_integer;
 cx: integer;
begin
 dum:= savmem(1, abmenu0, adr, 0, 0, 319, 10);
 for cx:= 0 to 3 do
  afmenu(-1, 0, 0, peekw(dpadr(270)+ (cx* 4)), 0,
          1, (dpadr(271)+ (cx* 2)), 1, adr);
end;

procedure afmenu3(adr: long_integer);
var
 dum: long_integer;
 cx: integer;
begin
 dum:= savmem(1, abmenu0, adr, 0, 0, 319, 10);
 for cx:= 0 to 1 do
  afmenu(-1, 0, 0, peekw(dpadr(246)+ (cx* 4)), 0,
          1, (dpadr(272)+ (cx* 2)), 1, adr);
end;

procedure afmenu4(adr: long_integer);
var
 dum: long_integer;
 cx: integer;
begin
 dum:= savmem(1, abmenu0, adr, 0, 0, 319, 10);
 for cx:= 0 to 2 do
  afmenu(-1, 0, 0, peekw(dpadr(268)+ (cx* 4)), 0,
          1, (dpadr(269)+ (cx* 2)), 0, adr);
end;

procedure afmenu5(adr: long_integer);
var
 dum: long_integer;
 cx: integer;
begin
 dum:= savmem(1, abmenu0, adr, 0, 0, 319, 10);
 for cx:= 0 to 2 do
  afmenu(-1, 0, 0, peekw(dpadr(335)+ (cx* 4)), 0,
          1, (dpadr(336)+ (cx* 2)), 0, adr);
end;

procedure afmenuact;
var
 saxg: integer;
begin
 saxg:= int(peekw(dpadr(267)+ 4));
 afmenu(-1, 0, 0, saxg, 0, 1, (dpadr(249)+ (pred(comenu)* 2)), 0, 0);
end;

procedure cadre;
begin
 traclign(aecra1, 3, 11, 316, 11, 0);
 traclign(aecra1, 316, 11, 316, 196, 0);
 traclign(aecra1, 3, 196, 316, 196, 0);
 traclign(aecra1, 3, 11, 3, 196, 0);
end;

procedure calch;
var
 nbs, cx: integer;
begin
(* debug('calch'); *)
 heu:= s.nbdh mod 48;
 jou:= s.nbdh div 48;
 min:= ((heu mod 2)* 30)+ (s.nbdm* 5);
 heu:= heu div 2;
 nbs:= (jou* 24)+ heu- 10;
 for cx:= 1 to nbs do s.te34auto[cx]:= true;
end;

procedure confiance(co: integer);
begin
 s.conf:= s.conf+ co;
end;

procedure coordaff(per: integer; var coxaf, coyaf: long_integer);
var
 coxa, coya: array[0..8] of long_integer;
begin
 coxa[0]:= 48;
 coxa[1]:= 64;
 coxa[2]:= 64;
 coxa[3]:= 48;
 coxa[4]:= 64;
 coxa[5]:= 64;
 coxa[6]:= 48;
 coxa[7]:= 48;
 coxa[8]:= 48;
 coya[0]:= 70;
 coya[1]:= 71;
 coya[2]:= 72;
 coya[3]:= 78;
 coya[4]:= 73;
 coya[5]:= 71;
 coya[6]:= 65;
 coya[7]:= 74;
 coya[8]:= 72;
 coxaf:= coxa[per];
 coyaf:= coya[per];
end;

procedure deplonw(nu: integer; decal: long_integer;
                 var dep, long: long_integer);
var
 ad: long_integer;
begin
 ad:= adeplonw(decal, nu);
 dep:= peekl(ad);
 long:= peekl(ad+ 4);
end;

procedure deplonb(nu: integer; decal: long_integer;
                  var tot, nbr: integer);
var
 ad: long_integer;
begin
 ad:= adeplonb(decal, nu);
 tot:= int(peekw(ad));
 nbr:= int(peekw(ad+ 2));
end;

procedure e_mouse(var x, y, et: integer);
begin
 x:= int(peekw(asouris+ 2));
 y:= int(peekw(asouris+ 4));
 et:= int(peekw(asouris));
 if et<> 0 then pokew(asouris, 0);
end;

procedure moveblok(ecr1, ecr2, xg, yg, xd, yd: long_integer);
begin
 hidemouse;
 movblk(ecr1, ecr2, xg, yg, xd, yd);
 showmouse;
end;

procedure posmouse(xsou, ysou, xhc, yhc, xbc, ybc: integer);
begin
 pokew((asouris+ 2), xsou);
 pokew((asouris+ 4), ysou);
 pokew((asouris+ 12), xhc);
 pokew((asouris+ 14), yhc);
 pokew((asouris+ 16), xbc);
 pokew((asouris+ 18), ybc);
end;

function posval(lieu, obj: integer): integer;
var
 cx, tot, nbr: integer;
 trouv: boolean;
begin
(* debug('posval'); *)
 posval:= -1;
 deplonb(lieu, dpadr(429), tot, nbr);
 if nbr<> 0 then
 begin
  cx:= 0;
  trouv:= false;
  repeat
   if obj= int(peek(dpadr(430)+ tot+ cx)) then trouv:= true
    else cx:= succ(cx);
  until (trouv) or (cx> pred(nbr));
  if trouv then posval:= (cx+ tot);
 end;
end;

procedure praftext(centr, ntab, nphr: integer;
                   tstr: boolean;
                   cadr: boolean;
                   lgli, xcoo, ycoo, haut, coul: integer;
                   ecraf: long_integer);
var
 long, along, atext, icadr, itstr: long_integer;
 nouvtab: array[1..7] of integer;
begin
(* modif position de dernier instant sur les textes *)
 nouvtab[1]:= 5;
 nouvtab[2]:= 3;
 nouvtab[3]:= 1;
 nouvtab[4]:= 2;
 nouvtab[5]:= 7;
 nouvtab[6]:= 4;
 nouvtab[7]:= 6;
 ntab:= nouvtab[ntab];
(* fin de modif *)
 along:= alongt;
 atext:= atexte;
 if ntab>1 then
 begin
  along:= along+ llong1;
  atext:= atext+ ltext1;
 end;
 if ntab> 2 then
 begin
  along:= along+ llong2;
  atext:= atext+ ltext2;
 end;
 if ntab> 3 then
 begin
  along:= along+ llong3;
  atext:= atext+ ltext3;
 end;
 if ntab> 4 then
 begin
  along:= along+ llong4;
  atext:= atext+ ltext4;
 end;
 if ntab> 5 then
 begin
  along:= along+ llong5;
  atext:= atext+ ltext5;
 end;
 if ntab> 6 then
 begin
  along:= along+ llong6;
  atext:= atext+ ltext6;
 end;
 icadr:= 0;
 itstr:= 0;
 if cadr then icadr:= 1;
 if tstr then itstr:= 1;
 long:= aftext(centr, atext, along, adtext, ecraf, (alettr+ peekw(alettr)),
               xcoo, ycoo, lgli, haut, coul, icadr, itstr, nphr);
end;

procedure srvop(ncomp, tab: integer; brep: boolean; var rep, depl: integer);
var
 cx, tot, nbr: integer;
 trouv: boolean;
begin
(* debug('srvop');*)
 depl:= -1;
 if brep then rep:= int(peekw(dpadr(tab+ 2)));
 if ncomp<> -1 then
 begin
  deplonb(pred(s.mlieu), dpadr(tab), tot, nbr);
  trouv:= false;
  if nbr<> 0 then
  begin
   cx:= 0;
   repeat
    if ncomp= int(peek(dpadr(succ(tab))+ tot+ cx)) then trouv:= true
     else cx:= succ(cx);
   until (cx> pred(nbr)) or (trouv);
   if trouv then
   begin
    if brep then rep:= int(peekw(dpadr(tab+ 3)+ (tot* 2)+ (cx* 2)));
    depl:= tot+ cx;
   end;
  end;
 end;
end;

procedure svtext(tab, pos: integer);
var
 poste: integer;
begin
 poste:= int(peek(dpadr(succ(tab))+ pos));
 if int(peek(dpadr(tab)+ pos))= 1 then s.te1auto[poste]:= true
  else s.te2auto[poste]:= true;
end;

(* NIVEAU *)
procedure atclick(temps: boolean);
var
 dummy, bsta: integer;
 dtemps: long_integer;
begin
(* debug('atclick'); *)
 nusou:= 4;
 chngmouse(4, 5);
 if not temps then
 begin
  repeat
   e_mouse(dummy, dummy, bsta);
  until bsta<> 0;
 end
 else
 begin
  dtemps:= peekw(aheure);
  repeat
   e_mouse(dummy, dummy, bsta);
  until (bsta<> 0) or (peekw(aheure)- dtemps> 30);
 end;
end;

procedure depbon(bon, val: integer; prem: boolean; var nval: integer);
var
 cx: integer;
begin
 cx:= val;
 if val> 18 then cx:= pred(cx);
 if val> 23 then cx:= pred(cx);
 nval:= cx;
 cx:= pred(cx)* 2;
 if not prem then
  dpb(bon, 0, -1, -1,
      peek(dpadr(257)+ cx)+ (bon* 7),
      peek(dpadr(257)+ succ(cx))+ (bon* 2))
 else
  dpb(bon, 0,
      peek(dpadr(257)+ cx)+ (bon* 7),
      peek(dpadr(257)+ succ(cx))+ (bon* 2),
      peek(dpadr(257)+ cx)+ (bon* 7),
      peek(dpadr(257)+ succ(cx))+ (bon* 2));
end;

procedure depmouse(y: integer);
var
 px, py, et, cx, pasx, pasy: integer;
 fin: boolean;
begin
 fin:= false;
 e_mouse(px, py, et);
 if px> 245 then hidemouse;
 pasx:= 0;
(* if px> x then pasx:= -1 else pasx:= 0; *)
 pasy:= 0;
 if py> y then pasy:= -1;
 if py< y then pasy:= 1;
 posmouse(px, py, px, py, px, py);
 repeat
(* px:= px+ pasx; *)
  py:= py+ pasy;
 (* if px= x then pasx:= 0; *)
  if py= y then pasy:= 0;
  if (pasx= 0) and (pasy= 0) then fin:= true;
  for cx:= 0 to 150 do begin end;
  posmouse(px, py, px, py, px, py);
 until fin;
 if px> 245 then showmouse;
 vblsync(1);
end;

procedure dodialog(hx, hy, np: thxys; longt, npmax, meheu: integer;
                   var quoi: integer; nul: boolean);
const
 psur= 0;     (* nbre de point au dessus de la ligne d'ecriture de lettre *)
 psou= 8;     (* nbre de point au dessous   "                    "        *)
var
 bsta, cx, mx, my: integer;
 stop: boolean;
begin
 quoi:= -1;
 repeat
  bsta:= 0;
  stop:= false;
  if meheu<> 0 then
  begin
   repeat
    e_mouse(mx, my, bsta);
    if (int(peekw(aheure))- meheu)> (ti* 5) then stop:= true;
   until (bsta<> 0) or (stop);
  end
  else
  begin
   repeat
    e_mouse(mx, my, bsta);
   until bsta<> 0;
  end;
  if not stop then
  begin
   if nul then quoi:= -2;
   cx:= 0;
   repeat
    if (mx>= hx[cx]) and (mx<= (hx[cx]+ longt)) and
       (my>= (hy[cx]- psur)) and (my<= (hy[cx]+ psou)) and
       (np[cx]<> -1) then quoi:= cx
    else cx:= succ(cx);
   until (cx> npmax) or (quoi> -1);
  end;
 until (quoi> -1) or (stop) or (nul);
 if stop then quoi:= -3;
end;

procedure efchif(val, lgli, coox, cooy, haut, coul: integer;
                ecraf: long_integer);
var
 long: long_integer;
begin
 long:= aftext(-1, val, -1, adtext, ecraf, (alettr+ peekw(alettr)),
               succ(coox), succ(cooy), lgli, haut, 0, 0, 1, 0);
 long:= aftext(-1, val, -1, adtext, ecraf, (alettr+ peekw(alettr)),
               coox, succ(cooy), lgli, haut, 0, 0, 1, 0);
 long:= aftext(-1, val, -1, adtext, ecraf, (alettr+ peekw(alettr)),
               coox, cooy, lgli, haut, coul, 0, 1, 0);
end;

procedure efpoint(coox, cooy, coul: integer; ecraf: long_integer);
begin
 afmark(ecraf, succ(coox), succ(cooy), 0);
 afmark(ecraf, coox, succ(cooy), 0);
 afmark(ecraf, coox, cooy, coul);
end;

procedure eftext(ntab, nphr: integer;
                tstr: boolean;
                cadr: boolean;
                lgli, coox, cooy, haut, coul: integer;
                ecraf: long_integer);
begin
 praftext(-1, ntab, nphr, tstr, cadr, lgli,
          succ(coox), succ(cooy), haut, 0, ecraf);
 praftext(-1, ntab, nphr, tstr, cadr, lgli,
          coox, succ(cooy), haut, 0, ecraf);
 praftext(-1, ntab, nphr, tstr, cadr, lgli,
          coox, cooy, haut, coul, ecraf);
end;

procedure lecture(buf, dest, num1, num2: long_integer);
var
 dum: long_integer;
begin
 if num2= -1 then dum:= loadlieu(buf, dest, num1)
  else loadobjt(buf, dest, num1, num2);
end;

function nupo(tab, coox, cooy: integer; rval: boolean): integer;
var
 depla: long_integer;
 enc, enc4, dep, tot, som, cx, cy, num, nval: integer;
 ocoox1, ocooy1, ocoox2, ocooy2: integer;
begin
(* debug('nupo'); *)
 num:= -1;
 dep:= int(peekw(dpadr(tab)+ (pred(s.mlieu)* 2)));
 if dep<> 0 then
 begin
  tot:= int(peek(dpadr(dep)));
  depla:= dpadr(succ(dep));
  som:= 0;
  enc:= 0;
  cx:= 1;
  repeat
   enc:= enc+ som;
   enc4:= enc* 4;
   som:= int(peek(dpadr(dep)+ cx));
   cy:= 1;
   repeat
    ocoox1:= int(peek(depla+ pred(cy)+ enc4));
    ocoox2:= int(peek(depla+ cy+ enc4));
    if (coox>= ocoox1) and (coox<= ocoox2) then
    begin
     ocooy1:= int(peek(depla+ pred(cy)+ (som* 2)+ enc4));
     ocooy2:= int(peek(depla+ cy+ (som* 2)+ enc4));
     if (cooy>= ocooy1) and (cooy<= ocooy2) then
      if rval then
      begin
       nval:= posval(pred(s.mlieu), pred(cx));
       if nval<> -1 then
       begin
        if s.oval[nval] then num:= cx;
       end
       else num:= cx;
      end
      else num:= cx;
    end;
    cy:= cy+ 2;
   until (cy> (som* 2)) or (num<> -1);
   cx:= succ(cx);
  until (cx> tot) or (num<> -1);
 end;
 if num> -1 then nupo:= pred(num) else nupo:= -1;
end;

function posouv(obj: integer; chang: boolean): integer;
var
 trouv: boolean;
 cx, tot, nbr: integer;
begin
(* debug('posouv'); *)
 if chang then
 begin
  deplonb(pred(s.mlieu), dpadr(431), tot, nbr);
  if nbr<> 0 then
  begin
   trouv:= false;
   cx:= 0;
   repeat
    if obj= int(peek(dpadr(433)+ tot+ cx)) then trouv:= true
    else cx:= succ(cx);
   until (trouv) or (cx> pred(nbr));
   if trouv then obj:= int(peek(dpadr(432)+ tot+ cx));
  end;
 end;
 posouv:= -1;
 deplonb(pred(s.mlieu), dpadr(297), tot, nbr);
 if nbr<> 0 then
 begin
  trouv:= false;
  cx:= 0;
  repeat
   if obj= int(peek(dpadr(298)+ tot+ cx)) then trouv:= true
   else cx:= succ(cx);
  until (trouv) or (cx> pred(nbr));
  if trouv then posouv:= cx;
 end;
end;

procedure present(ok: boolean);
var
 cx, cy: integer;
 dum, dep, decal, long: long_integer;
begin
(* debug('present'); *)
 decal:= dpadr(236);
 if ok then clrblk(aecra1, 0, 0, 319, 199);
 afmenu0(aecra1);
 for cx:= 5 to 13 do
 begin
  deplonw(cx, decal, dep, long);
  if (long<> 0) and (cx<> 8) then
   decomp(0, atrava, (adfixe+ dep), 0, 0, aecra1);
 end;
 cx:= 0;
 cy:= 0;
 repeat
  if s.chli[pred(s.mlieu), cx]<> -1 then cy:= 1 else cx:= succ(cx);
 until (cy<> 0) or (cx> nbobj);
 if cy<> 0 then decomp(0, atrava, anoeud, 0, 0, aecra1);
end;

procedure styleff(sou: boolean; eff, style, xh, yh, xb, yb: long_integer);
var
 adessief: long_integer;
begin
(*debug('effet');*)
(* eff= 0 -> ouverture au noir
   eff= 1 -> fermeture au noir
   eff= 2 -> ouverture en carre
   eff= 3 -> fermeture en carre
             ***** carre *****
      style= 0 -> de dessin a dessin
         style= 1 -> vers le noir
         style= 2 -> part du noir
             *****************
   eff= 4 -> affichage en matrice avec palette changee
   eff= 5 -> affichage en matrice sans palette changee
         style= 6 -> pixelisation rapide pour eff 4 ou 5
   eff= 6 -> forcage palette: palette en adessi avec decalage dans style *)
 if sou then hidemouse;
 adessief:= amempa;
 if (eff= 4) or (eff= 5) then
 begin
  if style= -1 then style:= hazard(0, 5);
  if style= -2 then style:= hazard(6,11);
 end;
 effets(eff, style, adessief, aecra1, aecra2, xh, yh, xb, yb);
 if sou then showmouse;
end;

procedure svpour(max, tab, pos: integer);
var
 ok: boolean;
begin
 ok:= false;
 if max= mpp then
 begin
  if not s.pourcp[pos] then
  begin
   s.pourcp[pos]:= true;
   ok:= true;
  end;
 end
 else
  if max= mpo then
  begin
   if not s.pourco[pos] then
   begin
    s.pourco[pos]:= true;
    ok:= true;
   end;
  end
  else
   if not s.pource[pos] then
   begin
    s.pource[pos]:= true;
    ok:= true;
   end;
 if ok then s.pourc:= s.pourc+ int(peek(dpadr(tab)+ pos));
end;

procedure vpour(max, comp1, comp2, tab: integer);
var
 cx: integer;
begin
 for cx:= 0 to max do
  if comp1= int(peekw(dpadr(tab)+ (cx* 2))) then
   if comp2<> -1 then
   begin
    if comp2= int(peek(dpadr(succ(tab))+ cx)) then
     svpour(max, (tab+ 2), cx);
   end
   else svpour(max, succ(tab), cx);
end;

procedure vtext(comp1, comp2, tab: integer);
var
 cx, max, poste: integer;
begin
 max:= int(peek(dpadr(tab)));
 for cx:= 0 to max do
  if comp1= int(peekw(dpadr(succ(tab))+ (cx* 2))) then
   if comp2<> -1 then
   begin
    if comp2= int(peek(dpadr(tab+ 2)+ cx)) then svtext((tab+ 3), cx);
   end
   else svtext((tab+ 2), cx);
end;

(* NIVEAU *)
procedure ajanim(cont: boolean; apal, depla: long_integer);
var
 cx, tot, nbr: integer;
 dep, long: long_integer;
 eff: boolean;
begin
(* debug('ajanim'); *)
 deplonb(pred(s.mlieu), dpadr(284), tot, nbr);
 if nbr<> 0 then
 begin
  eff:= false;
  cx:= 0;
  repeat
   if (s.nbdh>= peek(dpadr(285)+ tot)) and
      (s.nbdh<= peek(dpadr(286)+ tot)) then
   begin
(* kpart  pour prise des partitions piano *)
    if (s.mumus<> 0) and (s.mlieu= 2) then tot:= 0;
(* fin du kpart *)
    if cont then
    begin
     if not evan[tot] then
     begin
      if not eff then hidemouse;
      lecture((atrava+ depla), adessi, peek(dpadr(287)+ tot), 2);
      decomp(apal, (atrava+ depla), adessi, 0, 0, aecra1);
      eff:= true;
     end;
    end
    else
    begin
     lecture((atrava+ depla), adessi, peek(dpadr(287)+ tot), 2);
     decomp(apal, (atrava+ depla), adessi, 0, 0, aecra1);
    end;
    evan[tot]:= true;
   end;
   cx:= succ(cx);
   tot:= succ(tot);
  until cx> pred(nbr);
  if eff then
  begin
   styleff(false, 5, 0, 4, 12, 259, 174);
   showmouse;
  end;
 end;
end;

procedure energie(ce: integer; depla: long_integer; aff, eff: boolean);
var
 dum: integer;
 dep, long: long_integer;
begin
(* debug('energie'); *)
 s.ener:= s.ener+ ce;
 if s.ener> 99 then s.ener:= 99;
 if s.ener> 0 then
 begin
  dum:= s.ener div 20;
  if aff then
  begin
   deplonw(5, dpadr(236), dep, long);
   decomp(0, (atrava+ depla), (adfixe+ dep), 0, 0, aecra1);
   eftext(3, (dum+ 37), false, true, 50,
                   265, 110, 8, 15, aecra1);
   if eff then styleff(true, 5, 0, 265, 109, 315, 118);
  end;
 end;
end;

function jumeaux(lieu, obj: integer): integer;
var
 cx, tot, nbr, pos: integer;
 trouv: boolean;
begin
 jumeaux:= obj;
 pos:= posval(lieu, obj);
 if pos<> -1 then
  if not s.oval[pos] then
  begin
   deplonb(lieu, dpadr(431), tot, nbr);
   if nbr<> 0 then
   begin
    trouv:= false;
    cx:= 0;
    repeat
     if obj= int(peek(dpadr(432)+ tot+ cx)) then trouv:= true
     else cx:= succ(cx);
    until (trouv) or (cx> pred(nbr));
    if trouv then jumeaux:= int(peek(dpadr(433)+ tot+ cx));
   end;
  end;
end;

procedure klibelle;
begin
 if s.mlieu= 11 then
 begin
  if ((s.nbdh> 19) and (s.nbdh< 26) or
      (s.nbdh> 39) and (s.nbdh< 50) or
      (s.nbdh> 63) and (s.nbdh< 74) or
      (s.nbdh> 87) and (s.nbdh< 97)) then s.ndep[10]:= 5
  else s.ndep[10]:= 6;
 end;
end;

procedure menu_pers(depla: long_integer; eff: boolean);
var
 cx, ipers: integer;
 dep, long: long_integer;
 pie: array[0..8] of integer;
begin
(* debug('menu_pers'); *)
 pie[0]:= 3;
 pie[1]:= 5;
 pie[2]:= 7;
 pie[3]:= 20;
 pie[4]:= 19;
 pie[5]:= 21;
 pie[6]:= 25;
 pie[7]:= 27;
 pie[8]:= 8;
 if (s.mlieu> 8) and (s.mlieu< 17) then cx:= 1 else
  if s.mlieu> 16 then cx:= 2 else cx:= 0;
 deplonw(cx, dpadr(236), dep, long);
 decomp(0, (atrava+ depla), (adfixe+ dep), 0, 0, aecra1);
 ipers:= 0;
 qdedans:= false;
 for cx:= 0 to 8 do
  if s.mlieu= int(peek(dpadr(0)+ ((s.nbdh- dhd)* 9)+ cx)) then
  begin
   if s.mlieu= pie[cx] then qdedans:= true;
   ipers:= ipers+ 1;
   eftext(3, (79+ cx), false, true, 35, 274, (22+ (cx* 8)), 8, 15, aecra1);
  end;
 if ipers= 0 then eftext(3, 36, false, true, 30, 276, 50, 8, 15, aecra1);
 mpers:= ipers;
 if eff then styleff(true, 5, 0, 265, 12, 315, 103);
end;

procedure message(nsou, ntab, rep: integer; eff: boolean);
begin
 if nsou<> -1 then hidemouse;
 clrblk(aecra1, 3, 179, 260, 196);

procedure praftext(centr, ntab, nphr: integer;
                   tstr: boolean;
                   cadr: boolean;
                   lgli, xcoo, ycoo, haut, coul: integer;
                   ecraf: long_integer);

 praftext(17, ntab, rep, false, true, 258, 4, 179, 8, 15, aecra1);
 if eff then styleff(true, 5, 0, 4, 180, 259, 195);
 if nsou<> -1 then
 begin
  nusou:= nsou;
  chngmouse(nsou, 5);
  showmouse;
 end;
 vtext(rep, ntab, 454);
 vpour(mpe, rep, ntab, 468);
end;

procedure netmess;
begin
 hidemouse;
 clrblk(aecra1, 3, 179, 260, 196);
 styleff(true, 5, 0, 4, 180, 259, 195);
 showmouse;
end;

function objpart(tab, obj: integer): integer;
var
 nbr, cx: integer;
 depla: long_integer;
 trouv: boolean;
begin
 nbr:= int(peekw(dpadr(tab)));
 depla:= dpadr(succ(tab));
 trouv:= false;
 cx:= 0;
 if nbr<> -1 then
  repeat
   if obj= peekw(depla+ (cx* 2)) then trouv:= true
    else cx:= succ(cx);
  until (cx> nbr) or (trouv);
 if trouv then objpart:= cx else objpart:= -1;
end;

procedure pendule(depla: long_integer; aff, afp: boolean);
const
 x= 290;
 y1= 141;
 rg= 12;
 wl= 12;
 wp= 6;
 rp= 8;
 vl= 8;
 vp= 4;
var
 y, h, m, cx, cy, yaff, dummy: integer;
 cv: array[1..2] of array[1..12] of integer;
 cw: array[1..2] of array[1..12] of integer;
 decal, dep, long: long_integer;
begin
 y:= y1;
 yaff:= 0;
 if not aff then
 begin
  y:= y1- 15;
  yaff:= yaff- 15;
 end;
 decal:= dpadr(236);
 deplonw(6, decal, dep, long);
 decomp(0, (atrava+ depla), (adfixe+ dep), 0, yaff, aecra1);
 if afp then decomp(0, (atrava+ depla), (adfixe+ dep), 0, yaff, aecra2);
 cv[1,1]:= vp;
 cv[2,1]:= -vl;
 cv[1,2]:= vl;
 cv[2,2]:= -vp;
 cv[1,3]:= rp;
 cv[2,3]:= 0;
 cv[1,4]:= vl;
 cv[2,4]:= vp;
 cv[1,5]:= vp;
 cv[2,5]:= vl;
 cv[1,6]:= 0;
 cv[2,6]:= rp;
 cv[1,7]:= -vp;
 cv[2,7]:= vl;
 cv[1,8]:= -vl;
 cv[2,8]:= vp;
 cv[1,9]:= -rp;
 cv[2,9]:= 0;
 cv[1,10]:= -vl;
 cv[2,10]:= -vp;
 cv[1,11]:= -vp;
 cv[2,11]:= -vl;
 cv[1,12]:= 0;
 cv[2,12]:= -rp;
 cw[1,1]:= wp;
 cw[2,1]:= -wl;
 cw[1,2]:= wl;
 cw[2,2]:= -wp;
 cw[1,3]:= rg;
 cw[2,3]:= 0;
 cw[1,4]:= wl;
 cw[2,4]:= wp;
 cw[1,5]:= wp;
 cw[2,5]:= wl;
 cw[1,6]:= 0;
 cw[2,6]:= rg;
 cw[1,7]:= -wp;
 cw[2,7]:= wl;
 cw[1,8]:= -wl;
 cw[2,8]:= wp;
 cw[1,9]:= -rg;
 cw[2,9]:= 0;
 cw[1,10]:= -wl;
 cw[2,10]:= -wp;
 cw[1,11]:= -wp;
 cw[2,11]:= -wl;
 cw[1,12]:= 0;
 cw[2,12]:= -rg;
 if ((mjou<> jou) or ((heu> 11) and (mheu= 1))) and (aff) then
 begin
  mheu:= 2;
  deplonw(8, decal, dep, long);
  decomp(0, (atrava+ depla), (adfixe+ dep), 0, 0, aecra1);
  if heu> 11 then dummy:= 142 else dummy:= 141;
  eftext(3, dummy, false, false, 20, 270, 164, 8, 15, aecra1);
  if afp then styleff(false, 5, 0, 264, 160, 316, 175);
  if mjou<> jou then
  begin
   mjou:= jou;
   mheu:= 1;
  end;
  if jou= 0 then dummy:= 229 else dummy:= 230;
  eftext(3, dummy, false, false, 30, 286, 164, 8, 15, aecra1);
  if afp then styleff(false, 5, 0, 264, 160, 316, 175);
 end;
 m:= min div 5;
 if m= 0 then m:= 12;
 traclign(aecra1, succ(x), succ(y),
          succ(x+ cw[1, m]), succ(y+ cw[2, m]), 0);
 if afp then
  traclign(aecra2, succ(x), succ(y),
           succ(x+ cw[1, m]), succ(y+ cw[2, m]), 0);
 h:= heu;
 if h> 12 then h:= h- 12;
 if h= 0 then h:= 12;
 if (m> 6) and (m< 12) and (h< 12) then h:= succ(h) else
  if (m> 6) and (m< 12) and (h= 12) then h:= 1;
 traclign(aecra1, succ(x), succ(y),
          succ(x+ cv[1, h]), succ(y+ cv[2, h]), 0);
 traclign(aecra1, x, y, (x+ cw[1, m]), (y+ cw[2, m]), 15);
 traclign(aecra1, x, y, (x+ cv[1, h]), (y+ cv[2, h]), 15);
 if afp then
 begin
  traclign(aecra2, succ(x), succ(y),
           succ(x+ cv[1, h]), succ(y+ cv[2, h]), 0);
  traclign(aecra2, x, y, (x+ cw[1, m]), (y+ cw[2, m]), 15);
  traclign(aecra2, x, y, (x+ cv[1, h]), (y+ cv[2, h]), 15);
 end;
end;

procedure remapobj(tab, mul, obj: integer);
var
 apal: long_integer;
 num, coox, cooy: integer;
begin
 hidemouse;
 apal:= dpadr(tab)+ (mul* 16);
 num:= int(peek(dpadr(197)+ obj));
 coox:= ((5- (num mod 6))* 51)+ 10;
 cooy:= ((3- (num mod 24) div 6)* 47)+ 8;
 lecture(atrava, adessi, num, 1);
 decomp(apal, atrava, adessi, coox, cooy, aecra1);
 showmouse;
end;

procedure setdialog(style: boolean;
                    ntab, npmaxs, longs: integer;
                    hxs, hys, nps: thxys;
                    npmaxt, longt: integer;
                    hxt, hyt, npt: thxyt;
                    coul: integer);
var
 cx: integer;
begin
 for cx:= 0 to npmaxs do
  if nps[cx]<> -1 then
   if style then
    eftext(ntab, nps[cx], false, true,
           longs, hxs[cx], hys[cx], 8, coul, aecra1)
   else
    praftext(-1, ntab, nps[cx], false, true,
             longs, hxs[cx], hys[cx], 8, 0, aecra1);
 for cx:= 0 to npmaxt do
  if npt[cx]<> -1 then
   if style then
    eftext(ntab, npt[cx], false, true,
           longt, hxt[cx], hyt[cx], 8, coul, aecra1)
   else
    praftext(-1, ntab, npt[cx], false, true,
             longt, hxt[cx], hyt[cx], 8, 0, aecra1);
end;

procedure tperd(style, nu: integer);
begin
 qdedans:= false;
 glauque:= true;
 cperd:= nu;
 typerd:= style;
 if style< 3 then perdu:= true else assom:= true;
end;

procedure tvalid(lieu, tverb, obj: integer);
var
 cx, nval, tot, nbr: integer;
begin
 if tailta(adonne, succ(tverb))<> 0 then
 begin
  deplonb(lieu, dpadr(tverb), tot, nbr);
  for cx:= 0 to pred(nbr) do
   if obj= int(peek(dpadr(succ(tverb))+ tot+ cx)) then
   begin
    nval:= posval(lieu, int(peek(dpadr(tverb+ 2)+ tot+ cx)));
    if nval<> -1 then s.oval[nval]:= true;
    nval:= posval(lieu, int(peek(dpadr(tverb+ 3)+ tot+ cx)));
    if nval<> -1 then s.oval[nval]:= false;
   end;
 end;
end;

procedure verbouv(tab, nobj: integer; var trouv: boolean);
var
 nbr, cx: integer;
begin
 nbr:= int(peek(dpadr(tab)));
 trouv:= false;
 cx:= 0;
 if nbr<> 255 then
  repeat
   if (peek(succ(dpadr(tab)+ (cx* 2)))= s.mlieu) and
      (peek(succ(dpadr(tab)+ succ((cx* 2))))= nobj) then
     trouv:= true
   else
    cx:= succ(cx);
  until (cx> nbr) or (trouv);
end;

procedure voix(rep, xaff, yaff, aaffich: long_integer; per: integer);
var
 dum: long_integer;
 haut: array[0..8] of long_integer;
 flag10, flag1: integer;
begin
 hidemouse;
 dum:= 0;
 flag10:= int(peek(aflag10));
 flag1:= int(peek(aflag1));
 if flag10= 0 then
 begin
  dum:= savmem(0, aecra1, atrava, 119, 13, 315, 195);
  eftext(5, int(rep), false, true, 195, 119, 75, 8, 15, aecra1);
  styleff(true, 5, 6, 119, 13, 315, 195);
 end;
 if (flag1= 0) or ((flag1= 255) and (flag10= 255)) then
 begin
  haut[0]:= 3;
  haut[1]:= 3;
  haut[2]:= 2;
  haut[3]:= -1;
  haut[4]:= 0;
  haut[5]:= -2;
  haut[6]:= -2;
  haut[7]:= -1;
  haut[8]:= -3;
  parole(aphrase, aechant, aaffich, hazard(0, 3), adessi,
         yaff, xaff, (atrava+ dum), haut[per], rep);
 end;
 if (flag1= 255) and (flag10= 0) then vblsync(250);
 if flag10= 0 then
 begin
  dum:= savmem(1, atrava, aecra1, 119, 13, 315, 195);
  styleff(true, 5, 6, 119, 13, 315, 195);
 end;
 showmouse;
end;

(* NIVEAU *)
procedure boitobj(sorte, meheu: integer;
                  eff: boolean; var val: integer);
const
 xboite= 148;
 yboite= 85;
 npmaxt= -1;  (* nbre de phrases non select *)
 longt= 135;
 npmaxs= 1;   (* nbre de phrases selectables *)
 longs= 60;   (* longueur du texte selectable *)
 depxs= 160;
 depys= 105;
var
 num, obj: array[0..5] of integer;
 cx, cy, choix, coox, cooy: integer;
 dum1, dum2: long_integer;
 hxs, hys, nps: thxys;
 hxt, hyt, npt: thxyt;
 trouv: boolean;
begin
 for cx:= 0 to 5 do num[cx]:= -1;
 cy:= 0;
 for cx:= 0 to 4 do
 begin
  if s.objet[cx]<> -1 then
  begin
   num[cy]:= int(peekw(aobjet+ (cx* 2)));
   obj[cy]:= s.objet[cx];
   cy:= succ(cy);
  end;
 end;
 if s.dobj<> -1 then
 begin
  num[cy]:= int(peekw(adobj));
  obj[cy]:= s.dobj;
 end;
 if num[0]<> -1 then
 begin
  hidemouse;
  choix:= 0;
  coox:= xboite;
  cooy:= yboite+ 8;
  hxs[0]:= depxs;
  hys[0]:= depys;
  nps[0]:= 235;
  hxs[1]:= depxs+ 60;
  hys[1]:= depys;
  nps[1]:= 234;
  dum1:= savmem(0, aecra1, atrava,
                pred(xboite), pred(yboite),
                (xboite+ longt), (yboite+ 40));
  boite(sorte, longt, yboite, xboite, aecra1, asprit);
  setdialog(true, 3, npmaxs, longs, hxs, hys, nps,
            npmaxt, longt, hxt, hyt, npt, 15);
  dum2:= savmem(0, aecra1, (atrava+ dum1),
                pred(coox), pred(cooy), (coox+ longt), (cooy+ 8));
  eftext(4, num[0], false, true,
         longt, coox, cooy, 8, 15, aecra1);
  styleff(false, 5, 6, pred(xboite), pred(yboite),
          (xboite+ longt), (yboite+ 40));
  showmouse;
  cx:= 0;
  repeat
   dodialog(hxs, hys, nps, longs, npmaxs, meheu, choix, true);
   if choix= 0 then
   begin
    hidemouse;
    cx:= succ(cx);
    if cx> 5 then cx:= 0;
    if num[cx]= -1 then cx:= 0;
    dum2:= savmem(1, (atrava+ dum1), 0,
                  pred(coox), pred(cooy), (coox+ longt), (cooy+ 8));
    eftext(4, num[cx], false, true, longt, coox, cooy, 8, 15, aecra1);
    eftext(4, num[cx], false, true, longt, coox, cooy, 8, 15, aecra2);
    showmouse;
   end;
  until (choix= 1) or (choix< 0);
  if choix> -1 then
  begin
   val:= obj[cx];
   if eff then
   begin
    if val= s.dobj then s.dobj:= -1 else
    begin
     trouv:= false;
     cx:= 0;
     repeat
      if val= s.objet[cx] then trouv:= true else cx:= succ(cx);
     until trouv;
     for cy:= cx to pred(nbobj) do s.objet[cy]:= s.objet[succ(cy)];
     s.objet[nbobj]:= -1;
    end;
   end;
  end
  else val:= -1;
  hidemouse;
  dum1:= savmem(1, atrava, aecra1,
                pred(xboite), pred(yboite),
                (xboite+ longt), (yboite+ 40));
  styleff(false, 5, 6, pred(xboite), pred(yboite),
          (xboite+ longt), (yboite+ 40));
  showmouse;
 end
 else val:= -1;
end;

procedure boitsous(sorte, meheu: integer; var val: integer);
const
 xboite= 148;
 yboite= 85;
 npmaxt= -1;  (* nbre de phrases non select *)
 longt= 135;
 npmaxs= 2;   (* nbre de phrases selectables *)
 longs= 40;   (* longueur du texte selectable *)
 depxs= 160;
 depys= 90;
var
 choix, coox, cooy: integer;
 dum1, dum2: long_integer;
 hxs, hys, nps: thxys;
 hxt, hyt, npt: thxyt;
begin
 hidemouse;
 choix:= 0;
 coox:= depxs+ 40;
 cooy:= depys+ 10;
 hxs[0]:= depxs;
 hys[0]:= depys;
 nps[0]:= 174;
 hxs[1]:= depxs+ 65;
 hys[1]:= depys;
 nps[1]:= 175;
 hxs[2]:= depxs+ 30;
 hys[2]:= depys+ 20;
 nps[2]:= 234;
 dum1:= savmem(0, aecra1, atrava,
               (hxs[0]- 12), (hys[0]- 5),
               (hxs[0]+ longt), (hys[0]+ 40));
 boite(sorte, longt, yboite, xboite, aecra1, asprit);
 setdialog(true, 3, npmaxs, longs, hxs, hys, nps,
           npmaxt, longt, hxt, hyt, npt, 15);
 dum2:= savmem(0, aecra1, (atrava+ dum1),
               pred(coox), pred(cooy), (coox+ 20), (cooy+ 8));
 efchif(val, longt, coox, cooy, 8, 15, aecra1);
 styleff(true, 5, 6, (hxs[0]- 12), (hys[0]- 5),
         (hxs[0]+ longt), (hys[0]+ 40));
 showmouse;
 repeat
  dodialog(hxs, hys, nps, longs, npmaxs, meheu, choix, true);
  if (choix<> 2) and (choix> -1) then
  begin
   hidemouse;
   if choix= 0 then
   begin
    val:= succ(val);
    if val> s.sous then val:= s.sous;
   end
   else
   begin
    val:= pred(val);
    if val< 0 then val:= 0;
   end;
   dum2:= savmem(1, (atrava+ dum1), 0,
                 pred(coox), pred(cooy), (coox+ 20), (cooy+ 8));
   efchif(val, longt, coox, cooy, 8, 15, aecra1);
   efchif(val, longt, coox, cooy, 8, 15, aecra2);
   showmouse;
  end;
 until (choix= 2) or (choix< 0);
 if choix< 0 then val:= choix;
 hidemouse;
 dum1:= savmem(1, atrava, aecra1,
               (hxs[0]- 12), (hys[0]- 5),
               (hxs[0]+ longt), (hys[0]+ 40));
 styleff(false, 5, 6, (hxs[0]- 12), (hys[0]- 5),
         (hxs[0]+ longt), (hys[0]+ 40));
 showmouse;
end;

procedure boitdial(sorte, npmaxs, longs, npmaxt, longt: integer;
                   point, chif: boolean; val, coox, cooy: integer;
                   hxs, hys, nps: thxys;
                   hxt, hyt, npt: thxyt;
                   var choix: integer);
var
 cx: integer;
 dummy: long_integer;
begin
 choix:= 0;
 dummy:= savmem(0, aecra1, atrava,
                 (hxt[0]- 5), (hyt[0]- 5),
                 (hxt[0]+ longt+ 20), (hyt[0]+  40));
 boite(sorte, (longt+20), (hyt[0]- 5), (hxt[0]- 10), aecra1, asprit);
 hidemouse;
 setdialog(true, 3, npmaxs, longs, hxs, hys, nps,
           npmaxt, longt, hxt, hyt, npt, 15);
 if chif then efchif(val, longt, coox, cooy, 8, 15, aecra1);
 if point then
  for cx:= 0 to 8 do
   if s.qui[cx]<> -1 then efpoint((hxs[cx]+ 3), (hys[cx]+ 9), 15, aecra1);
 styleff(true, 5, 6, (hxt[0]- 5), (hyt[0]- 5),
         (hxt[0]+ longt+ 20), (hyt[0]+ 40));
 showmouse;
 dodialog(hxs, hys, nps, longs, npmaxs, 0, choix, true);
 hidemouse;
 dummy:= savmem(1, atrava, aecra1,
                 (hxt[0]- 5), (hyt[0]- 5),
                 (hxt[0]+ longt+ 20), (hyt[0]+  40));
 styleff(false, 5, 6, (hxt[0]- 5), (hyt[0]- 5),
         (hxt[0]+ longt+ 20), (hyt[0]+ 40));
 dummy:= savmem(1, atrava, 0,
                 (hxt[0]- 5), (hyt[0]- 5),
                 (hxt[0]+ longt+ 20), (hyt[0]+  40));
 showmouse;
end;

procedure testcache;
var
 cx, cy: integer;
 dep, long: long_integer;
begin
 if cache then
 begin
  cache:= false;
  cx:= 0;
  cy:= 0;
  repeat
   if s.chli[pred(s.mlieu), cx]<> -1 then cy:= 1 else cx:= succ(cx);
  until (cy<> 0) or (cx> nbobj);
  if cy<> 0 then decomp(0, atrava, anoeud, 0, 0, aecra1)
  else
  begin
   deplonw(9, dpadr(236), dep, long);
   decomp(0, atrava, (adfixe+ dep), 0, 0, aecra1);
  end;
  styleff(true, 5, 0, 265, 180, 315, 195);
 end;
end;

procedure efnoir;
var
 val: integer;
begin
 hidemouse;
 if efn= -1 then efn:= int(hazard(0, 1));
 if efn<> 1 then
 begin
  styleff(false, 3, 1, 0, 0, 319, 199);
  styleff(false, 6, 2, 0, 0, 0, 0);
  styleff(false, 2, 2, 0, 0, 319, 199);
 end
 else
 begin
  styleff(false, 1, 0, 0, 0, 319, 199);
  movblk(aecra1, aecra2, 0, 0, 319, 199);
  styleff(false, 0, 0, 0, 0, 319, 199);
 end;
 showmouse;
end;

procedure ficmem;
var
 cx: integer;
 dummy, dep, long: long_integer;
begin
 debug('ficmem');
(***** donnees *****)
 debugc(0,atexte);
 debugc(0,atrava);
 lecture(atrava, atexte, 0, 11);
 debug('apres lecture atexte');
 lecture(atrava, alongt, 0, 10);
 debug('apres lecture alongt');
 lecture(atrava, adonne, 0, 12);
 debug('apres lecture adonne');
(***** dessin decor *****)
 lecture(atrava, adfixe, 0, 9);
(***** loupe *****)
lecture(atrava, aloupe, 7, 9);
(***** noeud *****)
lecture(atrava, anoeud, 8, 9);
(***** menu, lettre et init de la souris *****)
 lecture(atrava, adessi, 5, 9);
 debug('apres lecture adessi');
 decomp(0, atrava, adessi, 0, 0, adesou);
 debug('apres decomp adessi');
 lecture(atrava, amasq, 6, 9);
 posmouse(131, 85, 0, 0, 304, 198);
 debug('apres posmouse');
 initmouse(adesou, azmasq, aecra2, aecra1, asprit, asouris);
 debug('apres initmouse');
(***** bamboo haut *****)
 lecture(atrava, adessi, 1, 9);
 decomp(0, atrava, adessi, 0, 0, aecra1);
 dummy:= savmem(0, aecra1, abmenu0, 0, 0, 319, 10);
end;

function frvop(ncomp, tab: integer; modif: boolean): integer;
var
 dum, rep, depl: integer;
begin
(* debug('frvop'); *)
 srvop(ncomp, tab, true, rep, depl);
 if modif then
 begin
  dum:= posouv(ncomp, false);
  if  dum<> -1 then
   if s.ouvfer[pred(s.mlieu), dum] then
    rep:= int(peekw(dpadr(tab+ 2)));
 end;
 frvop:= rep;
end;

procedure louvfe(tab, dep, long: integer; var rdep, long2: long_integer);
var
 cx: integer;
begin
(* debug('louvfe'); *)
 rdep:= 0;
 for cx:= 0 to dep do
  rdep:= rdep+ peekw(dpadr(tab)+ (cx* 2));
 long2:= 0;
 dep:= succ(dep);
 for cx:= 0 to long do
  long2:= long2+ peekw(dpadr(tab)+ (dep* 2)+ (cx* 2));
end;

procedure ouval(cx, tot: integer; apal: long_integer);
var
 ok, trouv: boolean;
 avjum, pos, tot2, nbr2, jum, lieu: integer;
 rdep, dum, dep, long: long_integer;
begin
 ok:= true;
 lieu:= pred(s.mlieu);
 avjum:= int(peek(dpadr(298)+ cx+ tot));
 jum:= jumeaux(lieu, avjum);
 pos:= posval(lieu, jum);
 if pos<> -1 then
  if not s.oval[pos] then
   if avjum= jum then ok:= false;
 if ok then
 begin
  if s.ouvfer[lieu, cx] then
  begin
   deplonw((cx+ mtot), dpadr(299), dep, long);
   rdep:= dep- rdepo;
   dum:= adesou;
  end
  else
  begin
   deplonw((cx+ mtot), dpadr(300), dep, long);
   rdep:= dep- rdepf;
   dum:= adesfe;
  end;
  decomp(apal, atrava, (dum+ rdep), 0, 0, aecra1);
 end;
end;

procedure placjer(var pla: boolean);
var
 stop: boolean;
 cx: integer;
begin
 pla:= false;
 stop:= false;
 if s.dobj= -1 then pla:= true else
 begin
  cx:= 0;
  repeat
   if s.objet[cx]= -1 then stop:= true else cx:= succ(cx);
  until (cx> nbobj) or (stop);
  if stop then
  begin
   s.objet[cx]:= s.dobj;
   s.dobj:= -1;
   pla:= true;
  end;
 end;
end;

procedure premrep(ncomp, tab: integer; var trouv: boolean);
var
 cx, tot, nbr: integer;
begin
(* debug('premrep'); *)
 tot:= 0;
 for cx:= 0 to (s.mlieu- 2) do
  tot:= tot+ int(peek(dpadr(tab)+ cx));
 nbr:= int(peek(dpadr(tab)+ pred(s.mlieu)));
 if nbr<> 0 then
 begin
  cx:= 0;
  repeat
   if ncomp= int(peek(dpadr(succ(tab))+ tot+ cx)) then trouv:= true
   else cx:= succ(cx);
  until (cx> pred(nbr)) or (trouv);
  if trouv then
   message(3, 2, int(peekw(dpadr(tab+ 2)+ (tot* 2)+ (cx* 2))), true);
 end;
end;

procedure preglauque;
var
 cx: integer;
 decal, dep, long: long_integer;
begin
 present(false);
 if (s.mlieu> 8) and (s.mlieu< 17) then cx:= 1 else
  if s.mlieu> 16 then cx:= 2 else cx:= 0;
 deplonw(cx, dpadr(236), dep, long);
 decomp(0, atrava, (adfixe+ dep), 0, 0, aecra1);
 eftext(3, 36, false, true, 30, 276, 50, 8, 15, aecra1);
 mjou:= -1;
 pendule(0, true, false);
end;

procedure slire(obj: integer; ire: boolean; var trouv: boolean);
const
 yaff= 12;
 haut= 8;
var
 cx, nbr, page, bsta: integer;
 coox, colg: array[0..2] of integer;
 dum, dep, long, meheu, adtexte, adlongt: long_integer;
 menu, aff: boolean;
begin
 adtexte:= atexte+ ltext1+ ltext2+ ltext3;
 adlongt:= alongt+ llong1+ llong2+ llong3;
 vtext(obj, -1, 450);
 meheu:= peekw(aheure);
 trouv:= false;
 nbr:= objpart(311, obj);
 if nbr= -1 then
 begin
  nbr:= objpart(315, obj);
  if nbr= -1 then
  begin
   nbr:= objpart(319, obj);
   if nbr<> -1 then
   begin
    (* journal *)
    exitani;
    trouv:= true;
    lecture(atrava, adessi, 2, 3);
    hidemouse;
    dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
    decomp(0, atrava, adessi, 0, 0, aecra1);
    deplonw(nbr, dpadr(321), dep, long);
    for cx:= 0 to pred(int(long)) do
     dum:= aftext(-1, adtexte, adlongt,
                  adtext, aecra1, (alettr+ peekw(alettr)),
                  peekw(dpadr(323)+ ((dep+ cx)* 2)),
                  peekw(dpadr(324)+ ((dep+ cx)* 2)),
                  peekw(dpadr(325)+ ((dep+ cx)* 2)),
                  haut, 5, 0, 0, peekw(dpadr(322)+ ((dep+ cx)* 2)));
    if ire then remapobj(242, 1, obj);
    message(0, 2, 438, false);
    muslire;
    styleff(true, 4, -2, 4, 12, 315, 195);
    showmouse;
    atclick(false);
    coupri;
   end;
  end
  else
  begin
   (* livre *)
   exitani;
   trouv:= true;
   hidemouse;
   if ire then remapobj(242, 1, obj);
   lecture(atrava, adessi, 1, 3);
   for cx:= 0 to 2 do
   begin
    coox[cx]:= int(peekw(dpadr(335)+ (cx* 4)));
    colg[cx]:= coox[cx]+ int(peekw(dpadr(335)+ (cx* 4) + 2));
   end;
   decomp(0, atrava, adessi, 0, 0, aecra1);
   deplonw(nbr, dpadr(317), dep, long);
   dum:= aftext(-1, adtexte, adlongt,
                adtext, aecra1, (alettr+ peekw(alettr)), 30, 25, 95,
                haut, 0, 1, 0, peekw(dpadr(318)+ (dep* 2)));
   dum:= aftext(-1, adtexte, adlongt,
                adtext, aecra1, (alettr+ peekw(alettr)), 138, 25, 83,
                haut, 0, 1, 0, peekw(dpadr(318)+ (dep* 2)+ 2));
   message(0, 2, 438, false);
   muslire;
   styleff(true, 4, -2, 4, 12, 315, 195);
   afmenu5(0);
   showmouse;
   mltemenu:= -1;
   page:= 0;
   repeat
    ltemenu:= -1;
    repeat
     e_mouse(mx, my, bsta);
     if my< yaff then
     begin
      menu:= false;
      cx:= 0;
      repeat
       if (mx> coox[cx]) and (mx< colg[cx]) then menu:= true
       else cx:= succ(cx);
      until (menu) or (cx> 2);
      if menu then ltemenu:= cx;
     end;
    until bsta<> 0;
    if (bsta= 2) and (mltemenu<> -1) then ltemenu:= mltemenu;
    if ltemenu<> -1 then mltemenu:= ltemenu;
    if (ltemenu= 0) or (ltemenu= 1) then
    begin
     aff:= false;
     if (ltemenu= 0) and (page> 0) then
     begin
      aff:= true;
      page:= page- 2;
     end;
     if (ltemenu= 1) and (page< (long- 2)) then
     begin
      aff:= true;
      page:= page+ 2;
     end;
     if aff then
     begin
      hidemouse;
      decomp(0, atrava, adessi, 0, 0, aecra1);
      dum:= aftext(-1, adtexte, adlongt,
                   adtext, aecra1, (alettr+ peekw(alettr)),
                   30, 25, 95, haut, 0, 1, 0,
                   peekw(dpadr(318)+ ((dep+ page)* 2)));
      dum:= aftext(-1, adtexte, adlongt,
                   adtext, aecra1, (alettr+ peekw(alettr)),
                   138, 25, 86, haut, 0, 1, 0,
                   peekw(dpadr(318)+ ((dep+ page)* 2)+ 2));
      styleff(true, 4, -2, 4, 12, 259, 174);
      showmouse;
     end;
    end;
   until ltemenu= 2;
   coupri;
  end;
 end
 else
 begin
  (* lettre *)
  exitani;
  trouv:= true;
  lecture(atrava, adessi, 0, 3);
  hidemouse;
  dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
  decomp(0, atrava, adessi, 0, 0, aecra1);
  long:= peekw(dpadr(313)+ (nbr* 2))+ (65536* peekw(dpadr(314)+ (nbr* 2)));
  dum:= aftext(-1, adtexte, adlongt,
               adtext, aecra1, (alettr+ peekw(alettr)), 30, 30, 194,
               haut, 11, 1, 0, long);
  if ire then remapobj(242, 0, obj);
  message(0, 2, 438, false);
  muslire;
  styleff(true, 4, -2, 4, 12, 315, 195);
  showmouse;
  atclick(false);
  coupri;
 end;
 if not trouv then message(3, 2, 439, true);
 pokew(aheure, meheu);
end;

procedure tinke(val, cont, ou, afp, afte, afe, ani, afm, fmes: boolean;
                dep: long_integer);
var
 cx, cy, nm, nm1, chai, ob, comp, tot, nbr, nval: integer;
 trouv, objet: boolean;
begin
(* debug('tinke'); *)
 if s.ener< 0 then tperd(1, (52+ int(hazard(0, 1))));
 if not glauque then if s.conf< 0 then tperd(2, (62+ int(hazard(0, 1))));
 if not glauque then
 begin
  nm1:= int(peekw(aheure))+ rmin;
  nm:= nm1 div ti;
  if (nm> 0) or (val) then
  begin
   rmin:= nm1 mod ti;
   s.nbdm:= s.nbdm+ nm;
   if (s.nbdm> 5) or (val) then
   begin
    cx:= s.nbdm div 6;
    s.nbdh:= s.nbdh+ cx;
    if s.nbdm> 5 then
    begin
     mdem:= false;
     cont:= true;
    end;
    if (cont) and ((s.nbdh mod 2)= 0) then s.pmaj:= s.pourc;
    if fmes then mdem:= false;
    energie(-cx, dep, afte, afe);
    s.nbdm:= s.nbdm mod 6;
(* recherche mort ou assomme *)
    deplonb(pred(s.mlieu), dpadr(189), tot, nbr);
    trouv:= false;
    cx:= 0;
    if nbr<> 0 then
    begin
     repeat
      if s.nbdh= int(peek(dpadr(190)+ (tot* 3))) then
       trouv:= true
      else
      begin
       cx:= succ(cx);
       tot:= succ(tot);
      end;
     until (trouv) or (cx> pred(nbr));
    end;
    if trouv then
    begin
     if int(peek(dpadr(190)+ (tot* 3)+ 2))= 1 then cx:= 4 else cx:= 1;
     tperd(cx, int(peek(dpadr(190)+ (tot* 3)+ 1)));
    end;
    if cont then
    begin
     if s.nbdh> 93 then tperd(2, 61);
     if s.mumus> 0 then
     begin
      s.mumus:= pred(s.mumus);
      if s.mumus= 0 then
      begin
       trouv:= false;
       for cx:= 0 to 8 do
        if s.mlieu= int(peek(dpadr(0)+ ((s.nbdh- dhd)* 9)+ cx)) then
         trouv:= true;
       if not trouv then
       begin
        if afm then
        begin
         menu_pers(dep, true);
         tperd(1, (58+ int(hazard(0, 2))));
        end
        else s.mumus:= succ(s.mumus);
       end
       else s.mumus:= succ(s.mumus);
      end;
     end;
    end;
    if not perdu then
     if cont then
     begin
(* mouvement sur un objet en chaine *)
      deplonb((s.nbdh- dhd), dpadr(288), tot, nbr);
      for cx:= 0 to pred(nbr) do
      begin
       if (not s.evob[tot]) then
       begin
        s.evob[tot]:= true;
        if peek(dpadr(290)+ tot)= 0 then objet:= true
         else objet:= false;
        chai:= pred(int(peek(dpadr(291)+ tot)));
        ob:= int(peek(dpadr(292)+ tot));
        if peek(dpadr(289)+ tot)= 0 then
         comp:= -1 else comp:= ob;
        trouv:= false;
        cy:= 0;
        repeat
         if objet then
          if s.chob[chai, cy]= comp then trouv:= true else cy:= succ(cy)
         else
         if s.chen[chai, cy]= comp then trouv:= true else cy:= succ(cy);
        until (cy> nbobj) or (trouv);
        if comp= -1 then
        begin
         if trouv then
         begin
          if objet then s.chob[chai, cy]:= ob else s.chen[chai, cy]:= ob;
         end
         else if objet then s.chob[chai, 1]:= ob else s.chen[chai, 1]:= ob;
        end
        else
         if trouv then
         begin
          if objet then s.chob[chai, cy]:= -1 else s.chen[chai, cy]:= -1;
         end
         else tperd(1, (58+ int(hazard(0, 2))));
       end;
       tot:= succ(tot);
      end;
(* ajout d'une animation *)
      if not glauque then
       if ani then ajanim(true, 0, dep);
      if not perdu then
      begin
(* ajout du KPART libelle au lac *)
       klibelle;
(* mouvement d'une loupe *)
       deplonb(pred(s.mlieu), dpadr(293), tot, nbr);
       for cx:= 0 to pred(nbr) do
       begin
        if (s.nbdh= int(peek(dpadr(294)+ tot)))
         and (not s.evlo[tot]) then
        begin
         cy:= int(peek(dpadr(296)+ tot));
         if (peek(dpadr(295)+ tot)<> s.etaob[cy])
          and (not glauque) then tperd(3, 56);
        end;
        tot:= succ(tot);
       end;
(* validation objet dans le temps *)
       deplonb((s.nbdh- dhd), dpadr(476), tot, nbr);
       for cx:= 0 to pred(nbr) do
       begin
        cy:= pred(int(peek(dpadr(477)+ tot)));
        nval:= posval(cy, int(peek(dpadr(478)+ tot)));
        if nval<> -1 then s.oval[nval]:= true;
        nval:= posval(cy, int(peek(dpadr(479)+ tot)));
        if nval<> -1 then s.oval[nval]:= false;
        tot:= succ(tot);
       end;
      end;
    end;
    if not glauque then menu_pers(dep, afp);
   end;
   calch;
   pendule(dep, ou, afp);
   if (afp) and (not perdu) then paljn(s.nbdm, s.nbdh, s.mlieu);
   pokew(aheure, 0);
   if (afm) and (not perdu) and (not mdem) then
   begin
(* message dans le temps *)
    mdem:= true;
    deplonb((s.nbdh- dhd), dpadr(237), tot, nbr);
    for cx:= 0 to pred(nbr) do
    begin
     nm:= int(peekw(dpadr(238)+ (tot* 2)));
     deplonb(tot, dpadr(239), ob, comp);
     cy:= 0;
     trouv:= false;
     if comp<> 0 then
      repeat
       if s.mlieu= int(peek(dpadr(240)+ ob+ cy)) then trouv:= true else
        cy:= succ(cy);
      until (cy> pred(comp)) or (trouv);
     if trouv then
     begin
      aprio(61);
      message(nusou, 2, nm, true);
      if s.mlieu= 26 then vblsync(110);
      temprio;
     end;
     tot:= succ(tot);
    end;
   end;
  end;
 end;
end;

(* NIVEAU *)
procedure afdes(nu, xh, yh, numef: integer;
                pers, tout, logo: boolean);
var
 cx, cy, num, tot, nbr, numf: integer;
 dum, coxaf, coyaf, dep, long, decal, rdep, long2, adrem: long_integer;
begin
(* debug('afdes'); *)
(* chgt souris *)
 if nu< 100 then
 begin
  if numef<> -2 then
   dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10)
  else
   dum:= savmem(1, abmenu0, aecra1, 0, 0, 319, 10);
  nusou:= 5;
  chngmouse(5, 4);
  depmouse(-4);
 end;
(* affichage dessin *)
 num:= nu;
 if num< 31 then
 begin
  exitani;
  if tout then lecture(atrava, adesou, num, -1)
   else lecture(atrava, 0, num, -1);
  paljnf(s.nbdm, s.nbdh, s.mlieu, amempa, adessi);
  if num< 30 then message(5, 2, (454+ num), false);
  if logo then
  begin
   cx:= 0;
   cy:= 0;
   repeat
    if s.chli[pred(s.mlieu), cx]<> -1 then cy:= 1 else cx:= succ(cx);
   until (cy<> 0) or (cx> nbobj);
   if cy<> 0 then decomp(0, atrava, anoeud, 0, 0, aecra1)
   else
   begin
    deplonw(9, dpadr(236), dep, long);
    decomp(0, atrava, (adfixe+ dep), 0, 0, aecra1);
   end;
  end;
 end
 else
 begin
  if num< 44 then
  begin
   num:= num- 33;
   if not pers then
   begin
    if s.cast[num] then cx:= 1 else cx:= 0;
    loadpers(aechant,aphrase,num, cx, adessi, atrava, (aechant+ lechant));
(*  lecture(atrava, aechant, 0, 13);
    lecture(atrava, aphrase, 0, 14); *)
   end
   else
   begin
    loadsuiv(num, atrava, adesou);
    paljnf(s.nbdm, s.nbdh, s.mlieu, amempa, adessi);
    pamb;
   end;
  end
  else
   if num> 99 then
   begin
    adrem:= dpadr(191)+ (pred(s.mlieu)* 16);
    lecture(atrava, adessi, (num- 100), 1);
    decomp(adrem, atrava, adessi, xh, yh, aecra1);
   end;
 end;
(* ajout animations *)
 num:= nu;
 if num< 30 then
 begin
  adesfe:= adesou;
  adespr:= adesou;
  adesab:= adesou;
  adeslo:= adesou;
  (* animation ouvert ferme *)
  deplonb(num, dpadr(297), tot, nbr);
  mtot:= tot;
  if nbr<> 0 then
  begin
   louvfe(299, pred(mtot), pred(nbr), rdepo, long2);
   adesfe:= adesou+ long2;
   louvfe(300, pred(mtot), pred(nbr), rdepf, long2);
   adespr:= adesfe+ long2;
   for cx:= 0 to pred(nbr) do ouval(cx, tot, 0);
  end;
  (* animation present/absent *)
  for cx:= 0 to moblo do
  begin
   pokel((aoblo+ (cx* 4)), -1);
   pokew((axoblo+ (cx* 2)), -1);
   pokew((ayoblo+ (cx* 2)), -1);
  end;
  deplonb(num, dpadr(192), tot, nbr);
  if nbr<> 0 then
  begin
   louvfe(306, pred(tot), pred(nbr), rdepp, long2);
   adesab:= adespr+ long2;
   louvfe(307, pred(tot), pred(nbr), rdepa, long2);
   adeslo:= adesab+ long2;
   louvfe(308, pred(tot), pred(nbr), rdepl, long2);
   cx:= 0;
   repeat
    if s.etaob[tot]= 0 then
    begin
     deplonw(tot, dpadr(308), dep, long);
     if long<> 0 then
     begin
      pokel((aoblo+ (cx* 4)), (adeslo+ dep- rdepl));
      deplonw(tot, dpadr(309), dep, long);
      pokew((axoblo+ (cx* 2)), long);
      deplonw(tot, dpadr(310), dep, long);
      pokew((ayoblo+ (cx* 2)), long);
     end;
     deplonw(tot, dpadr(306), dep, long);
     rdep:= dep- rdepp;
     dum:= adespr;
    end
    else
    begin
     deplonw(tot, dpadr(307), dep, long);
     rdep:= dep- rdepa;
     dum:= adesab;
    end;
    if (long<> 0)
(* kpart: attention special grotte finale *) or (s.mlieu= 30) then
     decomp(0, atrava, (dum+ rdep), 0, 0, aecra1);
(* kpart: grotte finale *)
    if s.mlieu= 30 then
     if ((tot= 45) and (s.etaob[45]= 0))
      or ((tot= 47) and (s.etaob[47]= 0))
      or ((tot= 49) and (s.etaob[49]= 0)) then
     begin
      tot:= succ(tot);
      cx:= succ(cx);
     end;
(* fin kpart *)
    tot:= succ(tot);
    cx:= succ(cx);
   until cx> pred(nbr);
  end;
  (* animation heure *)
  ajanim(false, 0, 0);
 end;
 (* effet apparition *)
 if numef= 0 then
 begin
  if tout then pamb;
  styleff(true, 4, -1, 3, 11, 319, 199);
  if tout then
  begin
   damb(s.nbdh);
   afmenu0(0);
  end;
  nusou:= 3;
  chngmouse(3, 5);
  initani;
  if s.mlieu= 16 then suri(62);
 end;
 if numef= 1 then
 begin
  efn:= -1;
  efnoir;
  nusou:= 0;
  chngmouse(0, 5);
 end;
 if numef= 2 then
 begin
  styleff(true, 5, -1, 4, 145, 315, 195);
  nusou:= 3;
  chngmouse(3, 5);
 end;
 if numef= 3 then
 begin
  styleff(true, 5, -1, 9, 16, 52, 74);
  afmenu0(0);
  nusou:= 0;
  chngmouse(0, 5);
 end;
 if numef= 4 then
 begin
  styleff(true, 5, -1, 28, 41, 118, 172);
  afmenu0(0);
  nusou:= 0;
  chngmouse(0, 5);
 end;
 if numef<> -1 then
 begin
  if num< 99 then
   posmouse(131, 85, 0, 0, 304, 198)
  else
  begin
   e_mouse(cx, cy, num);
   posmouse(cx, cy, 0, 0, 304, 198);
  end;
 end;
end;

(* NIVEAU *)
procedure afobj(obj, eff: integer);
var
 num, coox, cooy: integer;
begin
 hidemouse;
 message(-1, 4, int(peek(dpadr(198)+ obj)), false);
 num:= int(peek(dpadr(197)+ obj));
 coox:= ((5- (num mod 6))* 51)+ 10;
 cooy:= ((3- (num mod 24) div 6)* 47)+ 8;
 afdes((num+ 100), coox, cooy, eff, false, true, true);
 showmouse;
end;

function calpo(table, poste: integer): integer;
var
 cx, cy, long: integer;
 depla: long_integer;
 trouv: boolean;
begin
 calpo:= -1;
 depla:= dpadr(278+ table);
 long:= int(peekw(depla));
 trouv:= false;
 cx:= 0;
 if long<> -1 then
  repeat
   if poste= int(peekw(depla+ 2+ (cx* 2))) then trouv:= true
   else cx:= succ(cx);
  until (cx> long) or (trouv);
 if trouv then
 begin
  for cy:= 1 to pred(table) do
  begin
   depla:= dpadr(278+ cy);
   long:= int(peekw(depla));
   if long<> -1 then cx:= cx+ succ(long);
  end;
  calpo:= cx;
 end;
end;

procedure kparto(tab, chai, nu1, nu2, obj: integer;
                 var ntouch: integer);
var
 dum: long_integer;
 cx, clong, haut, nbend, nbseq, num, cxaf, cyaf, remp, meheu: integer;
 xtouch, ytouch: array[0..touch] of integer;
 seque: array[0..seq] of integer;
begin
 if tab<> -1 then
 begin
  clong:= int(peek(dpadr(tab)));
  haut:= int(peek(dpadr(tab)+ 1));
  nbend:= int(peek(dpadr(tab)+ 2));
  nbseq:= int(peek(dpadr(tab)+ 3));
  remp:= int(peek(dpadr(tab)+ 4));
  num:= int(peek(dpadr(197)+ obj));
  cxaf:= ((5- (num mod 6))* 51)+ 10;
  cyaf:= ((3- (num mod 24) div 6)* 47)+ 8;
  for cx:= 0 to nbend do
  begin
   xtouch[cx]:= int(peekw(dpadr(succ(tab))+ (cx* 2)))+ cxaf;
   ytouch[cx]:= int(peek(dpadr(tab+ 2)+ cx))+ cyaf;
  end;
  for cx:= 0 to nbseq do
   seque[cx]:= int(peek(dpadr(tab+ 3)+ cx));
  if (mx>= xtouch[seque[ntouch]]) and
     (mx<= (xtouch[seque[ntouch]]+ clong)) and
     (my>= ytouch[seque[ntouch]]) and
     (my<= (ytouch[seque[ntouch]]+ haut)) then ntouch:= succ(ntouch)
  else
   for cx:= 0 to nbend do
   begin
    if (mx>= xtouch[cx]) and (mx<= (xtouch[cx]+ clong)) and
       (my>= ytouch[cx]) and (my<= (ytouch[cx]+ haut)) then ntouch:= 0;
   end;
  if ntouch> nbseq then
  begin
   aprio(hazard(72, 73));
   if chai= 0 then s.chob[nu1, nu2]:= remp else
    if chai= 1 then s.chen[nu1, nu2]:= remp else
     s.chli[nu1, nu2]:= remp;
   afobj(remp, 2);
   message(-1, 2, int(peekw(dpadr(tab+ 4)+ (nbseq* 2))), true);
   vpour(mpo, remp, -1, 466);
  end;
 end
 else
 begin
  if obj= 24 then cx:= 4 else cx:= 5;
  meheu:= int(peekw(aheure));
  exitani;
  hidemouse;
  remapobj(242, 1, obj);
  lecture(atrava, adessi, cx, 3);
  dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
  decomp(0, atrava, adessi, 0, 0, aecra1);
  muslire;
  styleff(false, 4, -1, 4, 12, 315, 194);
  showmouse;
  atclick(false);
  coupri;
  hidemouse;
  afobj(obj, -1);
  if (s.mlieu= 9) or (s.mlieu= 10) then
   afdes(pred(s.mlieu), 0, 0, 0, false, true, false)
  else
   afdes(pred(s.mlieu), 0, 0, 0, false, false, false);
  afmenu4(0);
  initani;
  showmouse;
  pokew(aheure, meheu);
 end;
end;

procedure remap;
var
 cx, tab: integer;
 dep, long, apal: long_integer;
begin
 apal:= dpadr(201)+ (pred(s.mlieu)* 16);
 remapec(apal, 196, 316, 11, 3, aecra1, aecra1);
 if ((s.mlieu> 8) and (s.mlieu<> 17) and (s.mlieu< 19)) or (s.mlieu= 29) then
  tab:= 199 else tab:= 200;
 for cx:= 0 to 15 do
  pokew(amempa+ (cx* 2), peekw(dpadr(tab)+ (cx* 2)));
end;

(* NIVEAU *)
procedure clef(tab: integer; var loquet: boolean);
var
 cx, nbr, outil: integer;
 trouv: boolean;
begin
(* debug('clef'); *)
 loquet:= false;
 nbr:= int(peek(dpadr(tab)));
 trouv:= false;
 cx:= 0;
 if nbr<> 255 then
  repeat
   if (s.mlieu= int(peek(dpadr(succ(tab))+ cx))) and
    (int(peek(dpadr(tab+ 2)+ cx))= jumeaux(pred(s.mlieu), nobj)) and
    (s.nbdh>= int(peek(dpadr(tab+ 3)+ cx))) and
    (s.nbdh<= int(peek(dpadr(tab+ 4)+ cx))) then trouv:= true
   else cx:= succ(cx);
  until (cx> nbr) or (trouv);
 if trouv then
 begin
  outil:= int(peek(dpadr(tab+ 5)+ cx));
  if outil= -1 then loquet:= true else
  begin
   if s.dobj<> outil then
   begin
    cx:= 0;
    trouv:= false;
    repeat
     if s.objet[cx]= outil then trouv:= true else cx:= succ(cx);
    until (cx> nbobj) or (trouv);
    if not trouv then
    begin
     loquet:= true;
     aprio(52);
    end;
   end;
  end;
 end;
end;

procedure qfin(var ok: boolean);
const
 haut= 9;
 afq= 48;
var
 dum, meheu: long_integer;
 cx, cy, npe, nbc, num, nnum, tot, nbr, mx, my, bsta, pourc: integer;
 rep: array[0..3] of integer;
 trouv: boolean;
begin
 meheu:= peekw(aheure);
 rep[0]:= 132;
 rep[1]:= 133;
 rep[2]:= 134;
 rep[3]:= 135;
 ok:= true;
 pourc:= 0;
 vblsync(250);
 hidemouse;
 exitani;
 dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
 remap;
 npe:= int(peek(dpadr(505)));
 nbc:= int(peek(dpadr(506)));
 dum:= savmem(0, aecra1, atrava, 4, 11, 259, 174);
 trouv:= false;
 cx:= 0;
 eftext(7, 125, false, true, 215, 24, 44, haut, 15, aecra1);
 styleff(false, 4, -1, 0, 0, 319, 199);
 showmouse;
 atclick(false);
 repeat
  hidemouse;
  nusou:= 0;
  chngmouse(0, 5);
  dum:= savmem(1, atrava, aecra1, 4, 11, 259, 174);
  if not trouv then num:= int(peek(dpadr(505)+ succ(cx)));
  eftext(7, num, false, true, 255, 4, 24, haut, 15, aecra1);
  deplonb(int(peek(dpadr(510)+ pred(num))), dpadr(513), tot, nbr);
  for cy:= 0 to pred(nbr) do
   eftext(7, int(peek(dpadr(514)+ tot+ cy)),
          false, true, 255, 4, afq+ (cy* haut), haut, 15, aecra1);
  styleff(false, 5, 6, 4, 12, 259, 174);
  showmouse;
  trouv:= false;
  repeat
   repeat
    e_mouse(mx, my, bsta);
   until bsta<> 0;
   my:= (my- afq) div haut;
   if (my>= 0) and (my< nbr) then trouv:= true;
  until trouv;
  trouv:= false;
  cy:= 0;
  repeat
   nnum:= int(peek(dpadr(507)+ cy));
   if num= nnum then trouv:= true else cy:= succ(cy);
  until (cy> nbc) or (trouv);
  if my= int(peek(dpadr(511)+ pred(num))) then
  begin
   nnum:= int(peek(dpadr(508)+ cy));
   pourc:= pourc+ int(peek(dpadr(512)+ pred(num)));
  end
  else
  begin
   ok:= false;
   nnum:= int(peek(dpadr(509)+ cy));
  end;
  if nnum= 255 then trouv:= false;
  if trouv then num:= nnum else cx:= succ(cx);
 until cx> npe;
 nusou:= 4;
 chngmouse(4, 5);
 depmouse(-4);
 if not ok then
 begin
  hidemouse;
  dum:= savmem(1, atrava, aecra1, 4, 11, 259, 174);
  eftext(7, 126, false, true, 215, 24, 44, haut, 15, aecra1);
  if pourc= 100 then pourc:= 99;
  pourc:= pourc div 25;
  eftext(7, rep[pourc], false, true, 215, 24, 58, haut, 15, aecra1);
  styleff(false, 5, 6, 4, 12, 259, 174);
  showmouse;
  atclick(false);
  hidemouse;
  present(true);
  afdes(pred(s.mlieu), 0, 0, -1, false, false, true);
  pokew(aheure, meheu);
  mjou:= -1;
  tinke(true, true, true, false, true, false, true, false, false, 0);
  styleff(false, 4, -1, 0, 0, 319, 199);
  nusou:= 3;
  chngmouse(3, 5);
  showmouse;
 end
 else pokew(aheure, meheu);
end;

procedure memoire(mode: integer; var choix: integer);
const
 haut= 8;     (* hauteur entre deux lignes *)
 npmaxt= 0;   (* nbre de phrases non select *)
 longt= 135;  (* longueur du texte non selectable *)
 depyt= 70;
 depxt= 142;
 numet= 193;
 npmaxs= 8;   (* nbre de phrases selectables *)
 longs= 8;    (* longueur du texte selectable *)
 depys= 82;
 depxs= 145;
 nuta= 255;   (* numero table des mess *)
var
 cx, dummy: integer;
 hxs, hys, nps: thxys;
 hxt, hyt, npt: thxyt;
begin
 for cx:= 0 to npmaxs do
 begin
  hys[cx]:= depys;
  hxs[cx]:= (depxs+ (cx* (longs+ 7)));
  nps[cx]:= int(peekw(dpadr(nuta)+ (cx* 2)));
 end;
 hyt[0]:= depyt;
 hxt[0]:= depxt;
 npt[0]:= numet;
 boitdial(mode, npmaxs, longs, npmaxt, longt, true, false, 0, 0, 0,
          hxs, hys, nps, hxt, hyt, npt, choix);
end;

procedure menuobj(chai, nu1, nu2: integer; var act: integer);
const
 yaff= 12;
var
 cx, bsta, obj, arg, ntouch, meheu: integer;
 coox, colg: array[0..2] of integer;
 cooy: array[1..5] of integer;
 dum, lgm, aitem, dep, long: long_integer;
 menu, pla, trouv: boolean;
begin
 ntouch:= 0;
 dum:= 0;
 for cx:= 0 to 2 do
 begin
  coox[cx]:= int(peekw(dpadr(268)+ (cx* 4)));
  colg[cx]:= coox[cx]+ int(peekw(dpadr(268)+ (cx* 4) + 2));
 end;
 lgm:= peek(dpadr(258)+ 10);
 aitem:= dpadr(248);
 for cx:= 1 to 5 do cooy[cx]:= yaff+ (pred(cx)* 12);
 repeat
  otemenu:= -1;
  ocomenu:= -1;
  repeat
   tinke(false, true, false, true, false, false, true, true, false, dum);
   if not glauque then
   begin
    e_mouse(mx, my, bsta);
    if my< yaff then
    begin
     menu:= false;
     cx:= 0;
     repeat
      if (mx> coox[cx]) and (mx< colg[cx]) then menu:= true
      else cx:= succ(cx);
     until (menu) or (cx> 2);
     if menu then
     begin
      if cx= 1 then
      begin
       if otemenu<> 1 then
       begin
        dum:= savmem(0, aecra1, atrava, coox[1], yaff,
                     (coox[1]+ lgm), (cooy[5]+ 12));
        afmenu(-1, 0, 0, coox[1], yaff, 5, aitem, 0, 0);
       end;
      end
      else
       if otemenu= 1 then
        dum:= savmem(1, atrava, 0, coox[1], yaff,
                     (coox[1]+ lgm), (cooy[5]+ 12));
      otemenu:= cx;
     end;
    end;
   end;
  until (bsta<> 0) or (glauque) or (qdedans);
  if otemenu= 1 then
   dum:= savmem(1, atrava, 0, coox[1], yaff, (coox[1]+ lgm), (cooy[5]+ 12));
  if (not glauque) and (not qdedans) then
  begin
   if bsta= 2 then
   begin
    if motemenu<> -1 then otemenu:= motemenu;
    if mocomenu<> -1 then ocomenu:= mocomenu;
   end;
   act:= otemenu;
   if act= 1 then
   begin
    if bsta<> 2 then
    begin
     cx:= 1;
     repeat
      if (my>= cooy[cx]) and (my<= (cooy[cx]+ 12))
       and (mx>= coox[1]) and (mx<= (coox[1]+ lgm)) then ocomenu:= cx
      else cx:= succ(cx);
     until (cx> 5) or (ocomenu<> -1);
     if ocomenu<> -1 then mocomenu:= ocomenu;
    end;
    if chai= 0 then obj:= s.chob[nu1, nu2] else
     if chai= 1 then obj:= s.chen[nu1, nu2] else
      obj:= s.chli[nu1, nu2];
    vpour(mpo, obj, -1, 466);
    if ocomenu= 1 then       (* lire *)
    begin
     slire(obj, true, trouv);
     if trouv then
     begin
      hidemouse;
      afobj(obj, -1);
      if (s.mlieu= 9) or (s.mlieu= 10) then
       afdes(pred(s.mlieu), 0, 0, 0, false, true, false)
      else
       afdes(pred(s.mlieu), 0, 0, 0, false, false, false);
      afmenu4(0);
      showmouse;
     end;
    end;
    if ocomenu= 2 then       (* prendre *)
    begin
     arg:= objpart(332, obj);
     if arg= -1 then
     begin
      placjer(pla);
      if pla then
      begin
       s.dobj:= obj;
       pokew(adobj, int(peek(dpadr(198)+ s.dobj)));
       vtext(obj, -1, 450);
       if chai= 0 then s.chob[nu1, nu2]:= -1 else
        if chai= 1 then s.chen[nu1, nu2]:= -1 else
         s.chli[nu1, nu2]:= -1;
       act:= 0;
       message(3, 2, 4, true);
      end
      else
      begin
       confiance(-2);
       message(3, 2, 317, true);
      end;
     end
     else
     begin
      fric;
      confiance(-1);
      s.sous:= s.sous+ int(peekw(dpadr(334)+ (arg* 2)));
      if chai= 0 then s.chob[nu1, nu2]:= -1 else
       s.chen[nu1, nu2]:= -1;
       act:= 0;
       message(3, 2, 4, true);
     end;
    end;
    if ocomenu= 3 then       (* regarder *)
    begin
     if (obj= 24) or (obj= 32) then
     begin
      message(3, 2, int(peekw(dpadr(503)+ (obj* 2))), false);
      kparto(-1, chai, nu1, nu2, obj, ntouch);
     end
     else message(3, 2, int(peekw(dpadr(503)+ (obj* 2))), true);
    end;
    if ocomenu= 4 then       (* sentir *)
     message(3, 2, int(peekw(dpadr(504)+ (obj* 2))), true);
    if ocomenu= 5 then       (* toucher *)
    begin
     vblsync(11);
     meheu:= int(peekw(aheure));
     nusou:= 6;
     chngmouse(6, 5);
     posmouse(275, 175, 251, 149, 301, 195);
     repeat
      e_mouse(mx, my, bsta);
     until bsta= 1;
     mx:= mx+ 14;
     hidemouse;
     if not glauque then
     begin
    (* cas particulier style kpart mais sur objet *)
      message(-1, 2, int(peekw(dpadr(502)+ (obj* 2))), true);
      if obj= 40 then kparto(480, chai, nu1, nu2, obj, ntouch)
      else
       if obj= 49 then kparto(485, chai, nu1, nu2, obj, ntouch);
     end;
     nusou:= 3;
     chngmouse(3, 5);
     posmouse(200, 100, 0, 0, 305, 199);
     showmouse;
     pokew(aheure, meheu);
    end;
   end;
   motemenu:= otemenu;
  end;
 until (act= 0) or (act= 2) or (glauque) or (qdedans);
end;

procedure opposition(table, poste, style, mtable, mposte, mquoi, vop: integer;
                     var rep: long_integer);
var
 dep: array[1..5] of integer;
 tval: array[1..5] of integer;
 cx, cy, cz, max, dnivop, vnivop, vnivmax, dtab, niv: integer;
 dtab1, val1, dum: integer;
 trouv: boolean;
begin
(* debug('opposition'); *)
 if table<> 0 then
 begin
  dep[1]:= 202;
  dep[2]:= 206;
  dep[3]:= 214;
  dep[4]:= 220;
  dep[5]:= 228;
  tval[1]:= 490;
  tval[2]:= 491;
  tval[3]:= 494;
  tval[4]:= 496;
  tval[5]:= 499;
  if dep[table]<> -1 then
  begin
   trouv:= false;
   dnivop:= 0;
   (* recherche depla en tab nivop *)
   for cx:= 1 to pred(table) do
    dnivop:= dnivop+ succ(int(peek(dpadr(dep[cx]))));
   (* maxi poste en oppo *)
   max:= int(peek(dpadr(dep[table])));
   cx:= 0;
   repeat
    (* recherche du poste en opposition *)
    if poste= int(peekw(dpadr(succ(dep[table]))+ (cx* 2))) then
    begin
     (* recherche des oppositions deja effectuees sur ce poste *)
     vnivop:= ord(s.nivop[dnivop+ cx]);
     vnivmax:= int(peek(succ(dpadr(dep[table]))+ cx));
     if vnivop< 3 then
     begin
      if vnivmax> vnivop then
      begin
       (* recherche des tables de niveau superieur totale *)
       niv:= 0;
       for cz:= 0 to max do
        if int(peek(succ(dpadr(dep[table]))+ cz))> vnivop then
         niv:= succ(niv);
       (* recherche des tables de niveau superieur precedente *)
       cy:= 0;
       for cz:= 0 to pred(cx) do
        if int(peek(succ(dpadr(dep[table]))+ cz))> vnivop then
         cy:= succ(cy);
       (* comparaison avec la table opposition possible *)
       dtab:= dep[table]+ 2+ (vnivop* 2);
       dtab1:= tval[table]+ vnivop;
       if style= 0 then
       begin
        if mtable= int(peek(dpadr(dtab)+ cy)) then
         if mtable<> 0 then
         begin
          if (mposte= int(peekw(dpadr(succ(dtab))+ (cy* 2)))) and
             (mquoi= int(peekw(dpadr(succ(dtab))+ ((niv+ cy)* 2))))
          then trouv:= true;
         end
         else trouv:= true;
       end
       else trouv:= true;
       if trouv then
       begin
        dum:= s.valop[dnivop+ cx]+ vop;               (* *)
        val1:= int(peek(dpadr(dtab1)+ cy));
        if dum>= val1 then                            (* *)
        begin
         s.valop[dnivop+ cx]:= dum;                   (* *)
         s.nivop[dnivop+ cx]:= chr(succ(vnivop));
         rep:= peekw(dpadr(succ(dtab))+ (((niv* 2)+ cy)* 2));
         cz:= calpo(table, poste);
         if cz<> -1 then s.repop[cz]:= int(rep);
        end
        else
        begin
         cx:= succ(max);
         rep:= 340;
        end;
       end;
      end;
     end;
    end;
    if not trouv then cx:= succ(cx);
   until (cx> max) or trouv;
   if not trouv then rep:= 340;
  end
  else rep:= 340;
 end
 else
 begin
  if style= 0 then rep:= 377;
  if style= 999 then rep:= 0;
  if style= 998 then rep:= 0;
  if style= 997 then rep:= 0;
 end;
end;

procedure prespend;
var
 dep, long: long_integer;
begin
 hidemouse;
 afmenu0(0);
 message(3, 2, 319, true);
 clrblk(aecra1, 264, 108, 316, 195);
 present(false);
 mjou:= -1;
 tinke(true, false, true, false, true, false, true, false, false, 0);
 styleff(true, 5, -1, 264, 108, 315, 195);
 qdedans:= false;
 showmouse;
end;

procedure presobj(rep: integer; menu: boolean; var trouv: boolean);
var
 dep, long: long_integer;
begin
 trouv:= true;
 message(-1, 2, rep, true);
 if menu then afmenu4(0);
 clrblk(aecra1, 264, 108, 316, 195);
 deplonw(12, dpadr(236), dep, long);
 decomp(0, atrava, (adfixe+ dep), 0, -31, aecra1);
 deplonw(7, dpadr(236), dep, long);
 decomp(0, atrava, (adfixe+ dep), 0, -15, aecra1);
 pendule(0, false, false);
 styleff(true, 5, -1, 264, 108, 315, 195);
 motemenu:= -1;
 mocomenu:= -1;
end;

procedure rechai(ncomp, ntab1, ntab2: integer;
                 var rep, depl: integer; var trouv: boolean);
var
 cx, tot, nbr: integer;
begin
 srvop(ncomp, ntab1, true, rep, depl);
 trouv:= false;
 if depl<> -1 then
 begin
  tot:= 0;
  for cx:= 0 to (s.mlieu- 2) do
   tot:= tot+ int(peek(dpadr(ntab2)+ cx));
  nbr:= int(peek(dpadr(ntab2)+ pred(s.mlieu)));
  if nbr<> 0 then
  begin
   cx:= 0;
   repeat
    if ncomp= int(peek(dpadr(succ(ntab2))+ tot+ cx)) then trouv:= true
    else cx:= succ(cx);
   until (cx> pred(nbr)) or (trouv);
   if trouv then nuchai:= pred(int(peek(dpadr(ntab2+ 2)+ tot+ cx)));
  end;
 end;
end;

function titext(nu, coox, cooy, val, coxe, coye: integer): integer;
var
 cy, cx: integer;
 dum: long_integer;
begin
 dum:= 0;
 if (val= 1) or (val= 3) then
  dum:= savmem(0, aecra1, atrava, coxe, coye, 259, 159);
 eftext(3, nu, false, false, 335, succ(coox), succ(cooy), 8, 15, aecra1);
 if (val= 2) or (val= 3) then
  styleff(true, 5, 0, coxe, coye, 259, 159);
 if (val> 1) and (val<> 4) then
  for cy:= 1 to 20 do
   for cx:= 1 to 32000 do begin end;
 if (val= 2) or (val= 3) then
 begin
  dum:= savmem(1, atrava, aecra1, coxe, coye, 259, 159);
  styleff(true, 5, 0, coxe, coye, 259, 159);
 end;
 titext:= int(dum);
end;

(* NIVEAU *)
procedure actouv(nobj, tval: integer);
var
 dep, long: long_integer;
 nuobj: integer;
begin
(* debug('actouv'); *)
 nuobj:= posouv(nobj, true);
 s.ouvfer[pred(s.mlieu), nuobj]:= true;
 deplonw((nuobj+ mtot), dpadr(299), dep, long);
 hidemouse;
 decomp(0, atrava, (adesou+ dep- rdepo), 0, 0, aecra1);
 movblk(aecra1, aecra2, 4, 12, 259, 174);
 showmouse;
 tvalid(pred(s.mlieu), tval, nobj);
end;

procedure doalert(ntab, nmes: integer);
var
 dum: long_integer;
begin
 hidemouse;
 dum:= savmem(0, aecra1, atrava, 76, 59, 188, 105);
 boite(0, 70, 65, 88, aecra1, asprit);
 eftext(ntab, nmes, false, true, 70, 92, 70, 8, 15, aecra1);
 styleff(true, 5, -1, 76, 59, 188, 105);
 showmouse;
 atclick(true);
 hidemouse;
 dum:= savmem(1, atrava, aecra1, 76, 59, 188, 105);
 styleff(true, 5, -1, 76, 59, 188, 105);
 showmouse;
end;

procedure skpbp(comp: integer; var ok: boolean);
var
 tot, nbr, cx: integer;
 dep, long, dep2: long_integer;
 trouv: boolean;
begin
 deplonb(pred(s.mlieu), dpadr(192), tot, nbr);
 if nbr<> 0 then
 begin
  cx:= 0;
  trouv:= false;
  repeat
   if comp= int(peek(dpadr(193)+ tot+ cx)) then trouv:= true
    else cx:= succ(cx);
  until (cx> pred(nbr)) or (trouv);
  if trouv then
  begin
   deplonw((tot+ cx), dpadr(306), dep, long);
   if long<> 0 then
   begin
    deplonw(tot, dpadr(306), dep2, long);
    hidemouse;
    decomp(0, atrava, (adespr+ dep- dep2), 0, 0, aecra1);
    moveblok(aecra1, aecra2, 4, 12, 259, 174);
    showmouse;
    ok:= false;
   end;
  end;
 end;
end;

procedure skpb(w, x, y, z: integer);
begin
 if w<> -1 then s.oval[w]:= true;
 if x<> -1 then s.oval[x]:= false;
 if y<> -1 then s.etaob[y]:= 0;
 if z<> -1 then s.etaob[z]:= 1;
end;

procedure skptransv(cx, cy: integer);
var
 max: array[1..3] of integer;
begin
 max[1]:= 5;
 max[2]:= 3;
 max[3]:= 8;
 s.cont[cx]:= s.cont[cx]+ s.cont[cy];
 if s.cont[cx]> max[cx] then
 begin
  s.cont[cy]:= s.cont[cx]- max[cx];
  s.cont[cx]:= max[cx];
 end
 else
 begin
  s.cont[cy]:= 0;
  if s.dobj= 166 then s.dobj:= 167;
  if s.dobj= 168 then s.dobj:= 169;
  if s.dobj= 170 then s.dobj:= 171;
 end;
end;

procedure skpm28(comp: integer; var ok: boolean);
var
 cx, cy, cz, cv, cw: integer;
begin
 if (comp= 10) or (comp= 11) or (comp= 28) then
 begin
  if comp= 10 then
  begin
   cv:= 1;
   cx:= 130;
   cy:= 137;
   cz:= 51;
   cw:= 29;
  end;
  if comp= 11 then
  begin
   cv:= 2;
   cx:= 132;
   cy:= 139;
   cz:= 53;
   cw:= 30;
  end;
  if comp= 28 then
  begin
   cv:= 3;
   cx:= 133;
   cy:= 140;
   cz:= 54;
   cw:= 6;
  end;
  ok:= false;
  message(3, 2, 218, true);
  skpb(cx, cy, cz, -1);
  skpbp(cw, ok);
  s.ben[cv]:= s.dobj;
  s.dobj:= -1;
 end;
end;

procedure skpm8(comp1, comp2: integer; var ok: boolean);
begin
 if comp1= 8 then
 begin
  ok:= false;
  message(3, 2, 476, true);
  if comp2= 167 then s.dobj:= 166;
  if comp2= 169 then s.dobj:= 168;
  if comp2= 171 then s.dobj:= 170;
  if (s.dobj= 166) or (s.dobj= 168) or (s.dobj= 170) then
  begin
   if s.dobj= 166 then s.cont[1]:= 5;
   if s.dobj= 168 then s.cont[2]:= 3;
   if s.dobj= 170 then s.cont[3]:= 8;
  end;
 end;
end;

procedure skpm6(comp1, comp2: integer; var ok: boolean);
var
 cx, cy, cz: integer;
begin
 if (comp1= 6) or (comp1= 29) or (comp1= 30) then
 begin
  cx:= -1;
  cy:= -1;
  cz:= -1;
  if comp1= 29 then cz:= 1;
  if comp1= 30 then cz:= 2;
  if comp1= 6 then cz:= 3;
  if (comp2> 165) or (comp2< 172) then
   if cz<> -1 then
   begin
    ok:= false;
    message(3, 2, 471, true);
    if (comp2= 166) or (comp2= 167) then cy:= 1;
    if (comp2= 168) or (comp2= 169) then cy:= 2;
    if (comp2= 170) or (comp2= 171) then cy:= 3;
    if (s.ben[cz]= 166) or (s.ben[cz]= 167) then cx:= 1;
    if (s.ben[cz]= 168) or (s.ben[cz]= 169) then cx:= 2;
    if (s.ben[cz]= 170) or (s.ben[cz]= 171) then cx:= 3;
    if (cx<> -1) and (cy<> -1) then
    begin
     skptransv(cx, cy);
     if s.cont[cx]<> 0 then
     begin
      if s.ben[cz]= 167 then s.ben[cz]:= 166;
      if s.ben[cz]= 169 then s.ben[cz]:= 168;
      if s.ben[cz]= 171 then s.ben[cz]:= 170;
     end;
    end;
   end;
 end;
end;

procedure skpmi(comp1, comp2: integer; var ok: boolean);
var
 cx, cy: integer;
begin
 cx:= -1;
 cy:= -1;
 if (comp1= 0) or (comp1= 24) then cx:= 1;
 if (comp1= 1) or (comp1= 25) then cx:= 2;
 if (comp1= 4) or (comp1= 27) then cx:= 3;
 begin
  if (comp2= 166) or (comp2= 167) then cy:= 1;
  if (comp2= 168) or (comp2= 169) then cy:= 2;
  if (comp2= 170) or (comp2= 171) then cy:= 3;
 end;
 if (cx<> -1) and (cy<> -1) then
 begin
  ok:= false;
  message(3, 2, 471, true);
  skptransv(cx, cy);
  if s.cont[cx]<> 0 then
  begin
   if comp1= 24 then
   begin
    skpb(124, 125, 46, 45);
    skpbp(0, ok);
   end;
   if comp1= 25 then
   begin
    skpb(126, 127, 48, 47);
    skpbp(1, ok);
   end;
   if comp1= 27 then
   begin
    skpb(128, 129, 50, 49);
    skpbp(4, ok);
   end;
  end;
 end;
end;

procedure apskp(par2, par3: integer; var ok: boolean);
begin
 if ok then skpm28(par2, ok);
 if ok then skpm6(par2, par3, ok);
 if ok then skpmi(par2, par3, ok);
 if ok then skpm8(par2, par3, ok);
end;

procedure skptour(par2: integer; var ok: boolean);
var
 cx, cy: integer;
begin
 cx:= -1;
 cy:= -1;
 if par2= 6 then cy:= 3;
 if par2= 29 then cy:= 1;
 if par2= 30 then cy:= 2;
 if cy<> -1 then
 begin
  if (s.ben[cy]= 166) or (s.ben[cy]= 167) then cx:= 1;
  if (s.ben[cy]= 168) or (s.ben[cy]= 169) then cx:= 2;
  if (s.ben[cy]= 170) or (s.ben[cy]= 171) then cx:= 3;
  if cx<> -1 then
  begin
   ok:= false;
   s.cont[cx]:= 0;
   if s.ben[cy]= 166 then s.ben[cy]:= 167;
   if s.ben[cy]= 168 then s.ben[cy]:= 169;
   if s.ben[cy]= 170 then s.ben[cy]:= 171;
  end;
 end;
end;

procedure skpsond(par2: integer; var ok: boolean);
var
 cx, cy: integer;
 mess: array[0.. 8] of integer;
begin
 if (par2= 24) or (par2= 25) or (par2= 27) then
 begin
  ok:= false;
  message(3, 2, 336, true);
 end
 else
 begin
  cx:= -1;
  cy:= -1;
  if par2= 0 then cx:= 1;
  if par2= 1 then cx:= 2;
  if par2= 4 then cx:= 3;
  if par2= 6 then cy:= 3;
  if par2= 29 then cy:= 1;
  if par2= 30 then cy:= 2;
  if cy<> -1 then
  begin
   if (s.ben[cy]= 166) or (s.ben[cy]= 167) then cx:= 1;
   if (s.ben[cy]= 168) or (s.ben[cy]= 169) then cx:= 2;
   if (s.ben[cy]= 170) or (s.ben[cy]= 171) then cx:= 3;
  end;
  if cx<> -1 then
  begin
   ok:= false;
   mess[0]:= 336;
   mess[1]:= 325;
   mess[2]:= 433;
   mess[3]:= 434;
   mess[4]:= 435;
   mess[5]:= 436;
   mess[6]:= 452;
   mess[7]:= 453;
   mess[8]:= 288;
   message(3, 2, mess[s.cont[cx]], true);
  end;
 end;
end;

procedure skpmet(p1, p2, p3, p4, p5, p6, p7, p8, p9, par2, par3: integer;
                                var ok: boolean);
begin
 if par3= p1 then
 begin
  if par2= p2 then
  begin
   skpb(p3, p4, p5, p6);
   skpbp(p7, ok);
   s.dobj:= -1;
   if not ok then message(3, 2, 218, true);
  end;
  if ok then
  begin
   if (par2= p8) or (par2= p9) then message(3, 2, 249, true);
   apskp(par2, par3, ok);
  end;
 end;
end;

procedure skpsort(cx: integer);
var
 ok: boolean;
begin
 if cx= 1 then skpb(137, 130, -1, 51);
 if cx= 2 then skpb(139, 132, -1, 53);
 if s.ben[cx]= 166 then skpb(124, 134, 46, -1);
 if s.ben[cx]= 167 then skpb(125, 134, 45, -1);
 if s.ben[cx]= 168 then skpb(126, 135, 48, -1);
 if s.ben[cx]= 169 then skpb(127, 135, 47, -1);
 if s.ben[cx]= 170 then skpb(128, 136, 50, -1);
 if s.ben[cx]= 171 then skpb(129, 136, 49, -1);
(* if (s.ben[cx]= 167) or (s.ben[cx]= 169) or (s.ben[cx]= 171) then
 begin
  placjer(ok);
  s.dobj:= s.ben[cx];
  pokew(adobj, int(peek(dpadr(198)+ s.dobj)));
 end; *)
 s.ben[cx]:= -1;
end;

procedure kpart(typ, par1, par2, par3: integer; var ok: boolean);
const
 haut= 8;
 npmaxs= 14;  (* selectables table 1 *)
 longs= 180;
 depx= 30;
 depy= 35;
 nut= 241;
 npmaxt= -1;  (* non selectable table 1 *)
 longt= 0;
 pia= 23;
var
 meheu, quoi, cx: integer;
 adtexte, adlongt, dum: long_integer;
 hxs, hys, nps: thxys;
 hxt, hyt, npt: thxyt;
 trouv: boolean;
 part: array[0..14] of integer;
begin
(* debug('kpart'); *)
 ok:= true;
 if typ= 1 then
 begin
 (** OUVRIR **)
 (* BOITE DANS LE PIANO *)
  if (par1= 2) and (par2= 14) and (s.etaob[1]<> 0) then ok:= false;
 (* TRAPPE CHEZ MAGUY *)
  if (par1= 3) and (par2= 21) then s.ndep[2]:= 4;
 end;
 if typ= 2 then
 begin
 (** TOURNER **)
 (* PIED PIANO *)
  if (par1= 2) and (par2= 14) then ptourn:= true;
 end;
 if typ= 3 then
 begin
 (** TOURNER **)
 (* BENITIERS *);
  if par1= 30 then
  begin
   if par2= 0 then
   begin
    s.cont[1]:= 0;
    skpb(-1, -1, 45, 46);
    skpbp(24, ok);
   end;
   if par2= 1 then
   begin
    s.cont[2]:= 0;
    skpb(-1, -1, 47, 48);
    skpbp(25, ok);
   end;
   if par2= 4 then
   begin
    s.cont[3]:= 0;
    skpb(-1, -1, 49, 50);
    skpbp(27, ok);
   end;
   if ok then skptour(par2, ok);
  end;
 (* LA FIN *)
  if (par1= 30) and (par2= 31)
   and (s.ben[1]= 166) and (s.ben[2]= 168)
    and (s.cont[1]= 2) and (s.cont[2]= 2) then
  begin
   chngani(0);
   message(3, 2, 5, true);
   qfin(ok);
   if ok then
   begin
    hidemouse;
    present(true);
    mjou:= -1;
    tinke(true, true, true, false, true, false, true, false, false, 0);
    lecture(atrava, adessi, 0, 3);
    decomp(0, atrava, adessi, 0, 0, aecra1);
    adtexte:= atexte+ ltext1+ ltext2+ ltext3;
    adlongt:= alongt+ llong1+ llong2+ llong3;
    dum:= aftext(-1, adtexte, adlongt,
                 adtext, aecra1, (alettr+ peekw(alettr)), 30, 30, 194,
                 haut, 0, 1, 0, 51);   (* 65536* 3 *)
    message(0, 2, 438, false);
    styleff(false, 4, -2, 0, 0, 319, 199);
    showmouse;
    atclick(false);
    hidemouse;
    cadre;
    afdes(30, 0, 0, -1, false, true, false);
    eftext(6, 102, false, true, 300, 10, 100, 8, 15, aecra1);
    pamb;
    movblk(aecra1, aecra2, 0, 0, 319, 199);
    styleff(false, 0, 0, 0, 0, 319, 199);
    showmouse;
    atclick(false);
    hidemouse;
    solu:= true;
    repeat
    until arret;
   end
   else
    if not glauque then
    begin
     posmouse(131, 85, 0, 0, 304, 198);
     chngani(0);
     initani;
     vblsync(250);
    end;
  end;
 (* RADIO BRUCE *)
  if (par1= 20) and (par2= 20) then chngani(0);
 (* CALE BRISBAN *)
  if (par1= 28) and (par2= 3) and (s.flip= 0) then
  begin
   s.flip:= 1;
   chngani(1);
  end;
 (* ROBINET *)
  if (par1= 12) and (par2= 5) then chngani(0);
 end;
 if typ= 4 then
 begin
 (** FERMER **)
 (* TRAPPE MAGUY *)
  if (par1= 3) and (par2= 21) then s.ndep[2]:= 3;
 (* CALLE BRISBAN *)
  if par1= 28 then
  begin
   if (par2= 0) and (s.flop= 1) then
   begin
    s.flop:= 0;
    chngani(0);
   end;
   if (par2= 3) and (s.flip= 1) then
   begin
    s.flip:= 0;
    chngani(1);
   end;
  end;
 end;
 if typ= 5 then
 begin
 (** METTRE **)
 (* CORDE AU PUITS *)
  if (par1= 10) and (par2= 17) and (par3= 66) then s.ndep[9]:= 6;
 end;
 if typ= 6 then
 begin
 (** METTRE **)
 (* JETON PIANO *)
  if (par1= 2) and (par2= 16) and (par3= 14) then
  begin
   ok:= false;
   meheu:= int(peekw(aheure));
   s.dobj:= -1;
   hidemouse;
   lecture(atrava, adessi, 0, 3);
   exitani;
   decomp(0, atrava, adessi, 0, 0, aecra1);
   quoi:= 0;
   for cx:= 0 to npmaxs do
   begin
    hys[cx]:= depy+ (cx* haut);
    hxs[cx]:= depx;
    nps[cx]:= int(peek(dpadr(nut)+ cx));
   end;
   setdialog(false, 6, npmaxs, longs, hxs, hys, nps,
             npmaxt, longt, hxt, hyt, npt, 1);
   dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
   message(-1, 2, 379, false);
   styleff(true, 4, -2, 4, 12, 315, 199);
   showmouse;
   dodialog(hxs, hys, nps, longs, npmaxs, meheu, quoi, true);
   if quoi> -1 then
   begin
    if (ptourn) and (s.mumus= 0) then
    begin
     if (s.nbdh> 23) and (s.nbdh< 35) then
     begin
      for cx:= 0 to 12 do part[cx]:= 174+ cx;
      part[13]:= 139;
      part[14]:= 187;
      s.mumus:= 29+ int(hazard(1, 2))- s.nbdh;
      s.chob[pia, nbobj]:= part[quoi];
     end;
     if s.nbdh> 61 then
     begin
      for cx:= 0 to 3 do part[cx]:= 188+ cx;
      part[4]:= 162;
      for cx:= 5 to 14 do part[cx]:= 188+ pred(cx);
      s.mumus:= -1;
      s.chob[pia, nbobj]:= part[quoi];
     end;
     ptourn:= false;
    end;
   end;
   afdes(pred(s.mlieu), 0, 0, 0, false, false, true);
   if quoi> -1 then piano(quoi);
   initani;
   pokew(aheure, meheu);
  end;
 end;
 if typ= 7 then
 begin
 (** METTRE **)
 (* LES BENITIERS *)
  if par1= 30 then
  begin
   skpmet(166, 20, 124, 134, 46, -1, 0, 21, 23, par2, par3, ok);
   if ok then skpmet(167, 20, 125, 134, 45, -1, 24, 20, 23, par2, par3, ok);
   if ok then skpmet(168, 21, 126, 135, 48, -1, 1, 20, 23, par2, par3, ok);
   if ok then skpmet(169, 21, 127, 135, 47, -1, 25, 21, 23, par2, par3, ok);
   if ok then skpmet(170, 23, 128, 136, 50, -1, 4, 21, 20, par2, par3, ok);
   if ok then skpmet(171, 23, 129, 136, 49, -1, 27, 21, 20, par2, par3, ok);
  end;
 end;
 if typ= 8 then
 begin
 (** APPUYER **)
 (* BOUTON CUISINE *)
  if (par1= 1) and (par2= 23) then chngani(0);
 (* BOUTON JEROME *)
  if (par1= 26) and (par2= 0) then chngani(0);
 (* PUITS *)
  if (par1= 16) and (par2= 6) then
  begin
   chngani(0);
   if s.oval[59] then
   begin
    chngani(1);
    if s.ndep[15]= 2 then s.ndep[15]:= 1 else s.ndep[15]:= 2;
   end;
  end;
 end;
 if typ= 9 then
 begin
 (* CALLE BRISBAN *)
  if (par1= 28) and (par2= 0) and (s.flop= 0) then
  begin
   s.flop:= 1;
   chngani(0);
  end;
 end;
 if typ= 10 then
 begin
 (** LIRE **)
 (* GROTTE MAGUY *)
  trouv:= false;
  if (par1= 17) and (par2= 1) then
  begin
   trouv:= true;
   quoi:= 6;
  end;
 (* STATUE LAC *)
  if (par1= 11) and (par2= 5) then
  begin
   trouv:= false;
   if (s.nbdh= 32) or (s.nbdh= 33) or (s.nbdh= 56)
    or (s.nbdh= 57) or (s.nbdh= 80) or (s.nbdh= 81) then
   begin
    if s.dobj= 42 then trouv:= true
    else
    begin
     cx:= 0;
     repeat
      if s.objet[cx]= 42 then trouv:= true else cx:= succ(cx);
     until (cx> nbobj) or (trouv);
    end;
    if trouv then quoi:= 7 else
    begin
     ok:= false;
     message(3, 2, 437, true);
    end;
   end;
  end;
  if trouv then
  begin
   ok:= false;
   meheu:= int(peekw(aheure));
   exitani;
   hidemouse;
   lecture(atrava, adessi, quoi, 3);
   decomp(0, atrava, adessi, 0, 0, aecra1);
   styleff(false, 4, -2, 4, 12, 259, 174);
   aprio(hazard(72, 73));
   message(3, 2, 438, true);
   showmouse;
   atclick(false);
   afdes(pred(s.mlieu), 0, 0, 0, false, false, true);
   initani;
   pokew(aheure, meheu);
  end;
 end;
 if typ= 11 then
 begin
 (** ALLER **)
 (* CHEZ MAGUY *)
  if par1= 3 then s.ndep[2]:= 3;
 end;
 if typ= 12 then
 begin
 (** ALLER **)
 (* HORS DU PUITS *)
  if (par1= 16) and (par2= 10) then
  begin
   if s.ndep[15]= 2 then
   begin
    chngani(1);
    vblsync(10);
    s.ndep[15]:= 1;
   end;
  end;
 (* DANS LE PUITS *)
  if (par1= 10) and (par2= 16) then
  begin
   if (s.nbdh<> 32) and (s.nbdh<> 33) and (s.nbdh<> 56)
    and (s.nbdh<> 57) and (s.nbdh<> 80) and (s.nbdh<> 81) then tperd(1, 64);
  end;
 (* HORS DE LA DERNIERE GROTTE *)
  if (par1= 30) and (par2= 16) then
   for cx:= 1 to 2 do
    if s.ben[cx]<> -1 then skpsort(cx);
 end;
 if typ= 13 then
 begin
 (** DEPOSER **)
 (* DANS LA DERNIERE GROTTE *)
  if par1= 30 then
  begin
   if par2= 166 then skpb(124, 134, 46, -1);
   if par2= 167 then skpb(125, 134, 45, -1);
   if par2= 168 then skpb(126, 135, 48, -1);
   if par2= 169 then skpb(127, 135, 47, -1);
   if par2= 170 then skpb(128, 136, 50, -1);
   if par2= 171 then skpb(129, 136, 49, -1);
  end;
 end;
 if typ= 14 then
 begin
 (** SONDER **)
 (* DANS LA DERNIERE GROTTE *)
  if par1= 30 then skpsond(par2, ok);
 end;
 if typ= 15 then
 begin
 (** PRENDRE **)
 (* CORDE AU PUITS *)
  if (par1= 10) and (par2= 14) then s.ndep[9]:= 5;
 (* BENITIER *)
  if (par1= 30) and (par2> 250) then
  begin
   ok:= false;
   message(3, 2, 218, true);
   cx:= par2- 250;
   s.dobj:= s.ben[cx];
   s.ben[cx]:= -1;
   pokew(adobj, int(peek(dpadr(198)+ s.dobj)));
   if cx= 1 then skpb(137, 130, -1, 51);
   if cx= 2 then skpb(139, 132, -1, 53);
   if cx= 3 then skpb(140, 133, -1, 54);
  end;
 end;
end;

procedure pchaine(ncomp, ntab1, ntab2: integer);
var
 act, cx, rep, depl: integer;
 dum: long_integer;
 trouv: boolean;
begin
(* debug('pchaine'); *)
 rechai(ncomp, ntab1, ntab2, rep, depl, trouv);
 if trouv then
 begin
  trouv:= false;
  cx:= 0;
  if cx<= nbobj then
   repeat
    if ncomp= nobj then nuobj[cx]:= s.chob[nuchai, cx]
                   else nuobj[cx]:= s.chen[nuchai, cx];
    if nuobj[cx]<> -1 then
    begin
     hidemouse;
     if not trouv then
     begin
      suri(hazard(67, 68));
      presobj(rep, true, trouv);
     end;
     afobj(nuobj[cx], 2);
     showmouse;
     if ncomp= nobj then menuobj(0, nuchai, cx, act) else
      menuobj(1, nuchai, cx, act);
     if act= 2 then cx:= succ(nbobj) else cx:= succ(cx);
    end
    else cx:= succ(cx);
   until (cx> nbobj) or (qdedans);
  if not qdedans then
   if not trouv then message(-1, 2, 2, true) else prespend;
 end
 else message(0, 2, rep, true);
end;

procedure pchaien;
var
 trouv: boolean;
 act, cx: integer;
 dum: long_integer;
begin
 (* debug('pchaien'); *)
 trouv:= false;
 cx:= 0;
 while cx<= nbobj do
  if s.chli[pred(s.mlieu), cx]<> -1 then
  begin
   hidemouse;
   if not trouv then presobj(8, true, trouv);
   afobj(s.chli[pred(s.mlieu), cx], 2);
   showmouse;
   menuobj(2, pred(s.mlieu), cx, act);
   if act= 2 then cx:= succ(nbobj) else cx:= succ(cx);
  end
  else cx:= succ(cx);
 if not trouv then message(3, 2, 2, true) else prespend;
end;

procedure premdes;
var
 cx, dummy: integer;
 decal, dep, long: long_integer;
 coox, cooy: array[0..14] of integer;
begin
(* debug('premdes'); *)
 clrblk(aecra1, 0, 0, 319, 199);
 decal:= dpadr(236);
 for cx:= 5 to 13 do
 begin
  deplonw(cx, decal, dep, long);
  if (long<> 0) and (cx<> 8) then
   decomp(0, atrava, (adfixe+ dep), 0, 0, aecra1);
 end;
end;

procedure recrep(table, poste: integer; var ok: boolean; var rep: integer);
var
 cx: integer;
begin
 ok:= false;
 cx:= calpo(table, poste);
 if cx<> -1 then
  if s.repop[cx]<> 0 then ok:= true;
 if ok then rep:= s.repop[cx];
end;

procedure recte34(ntit, npmaxs34, longs34: integer;
                  hxs34, hys34, nps34: thxys;
                  npmaxt34, longt34: integer;
                  hxt34, hyt34, npt34: thxyt;
                  per, meheu: integer;
                  var rep, quoi: integer);
const
 depx= 120;
 depy= 14;
var
 hxs, hys, nps: thxys;
 hxt, hyt, npt: thxyt;
 dum: long_integer;
begin
 if ntit= 0 then npt[0]:= 75 else npt[0]:= 76;
 hyt[0]:= depy;
 hxt[0]:= depx;
 hidemouse;
 dum:= savmem(1, atrava, aecra1, 119, 13, 315, 195);
 setdialog(true, 3, npmaxs34, longs34, hxs34, hys34, nps34,
           npmaxt34, longt34, hxt34, hyt34, npt34, 15);
 setdialog(true, 3, -1, 00, hxs, hys, nps,
           00, 200, hxt, hyt, npt, 15);
 styleff(false, 5, 6, 119, 13, 315, 195);
 showmouse;
 dodialog(hxs34, hys34, nps34, longs34, npmaxs34, meheu, quoi, true);
 if quoi> -1 then
 begin
  rep:= int(peekw((dpadr(succ(ntit)))+ ((9* quoi)+ per)* 2));
  if (rep= 0) and (ntit= 1) then rep:= 289+ int(hazard(0, 2));
 end
 else dum:= savmem(1, atrava, 0, 119, 13, 315, 195);
end;

procedure sparl(rep: long_integer;
                table, poste, per, meheu, penal, mpenal: integer;
                var act, som, blk: integer);
const
 yaff= 12;
var
 coox, colg: array[0..3] of integer;
 cooy: array[1..7] of integer;
 en: array[0..8] of integer;
 bsta, ix, cx, choix, tot, nbr: integer;
 dum, lgm, aitem, coxaf, coyaf: long_integer;
 prem, menu, nrep, trouv, prempas: boolean;
begin
(* debug('sparl'); *)
 coordaff(per, coxaf, coyaf);
 for cx:= 0 to 3 do
 begin
  coox[cx]:= int(peekw(dpadr(270)+ (cx* 4)));
  colg[cx]:= coox[cx]+ int(peekw(dpadr(270)+ (cx* 4)+ 2));
 end;
 prempas:= true;
 nrep:= true;
 prem:= true;
 for cx:= 1 to 7 do cooy[cx]:= yaff+ (pred(cx)* 12);
 lgm:= peek(dpadr(258)+ 7);
 aitem:= dpadr(254);
 afmenu2(0);
 repeat
  if nrep then
  begin
   if ((penal= 0) and (mpenal> 3) and (som< 999) and (prem)) or (blk= 1) then
   begin
    rep:= 381+ int(hazard(0, 1));
    penal:= 1;
   end
   else
   begin
    if (prempas) and (penal= 0) then
    begin
     dum:= 0;
     if gamelle<> 0 then opposition(table, poste, 997, 0, 0, 0, gamelle, dum);
     if (dum<> 340) and (dum<> 0) then rep:= dum;
     prempas:= false;
    end;
   end;
   gamelle:= pred(gamelle);
   if gamelle< 0 then gamelle:= 0;
   if rep<> 0 then
   begin
    voix(rep, coxaf, coyaf, aecra2, per);
    vtext(int(rep), -1, 446);
    vpour(mpp, int(rep), -1, 464);
   end;
   if blk= 99 then blk:= 1;
  end;
  nrep:= false;
  if act<> 5 then act:= 0;
  ptemenu:= -1;
  pcomenu:= -1;
  pokew(asouris, 0);
  repeat
   e_mouse(mx, my, bsta);
   if my< yaff then
   begin
    menu:= false;
    cx:= 0;
    repeat
     if (mx> coox[cx]) and (mx< colg[cx]) then menu:= true
     else cx:= succ(cx);
    until (menu) or (cx> 3);
    if menu then
    begin
     if cx= 2 then
     begin
      if ptemenu<> cx then
      begin
       dum:= savmem(0, aecra1, atrava,
                     coox[cx], yaff, colg[cx], (cooy[7]+ 12));
       afmenu(-1, 0, 0, coox[cx], yaff, 7, aitem, 1, 0);
      end;
     end
     else
      if ptemenu= 2 then
       dum:= savmem(1, atrava, 0,
                       coox[2], yaff, colg[2], (cooy[7]+ 12));
     ptemenu:= cx;
    end;
   end;
   if ((int(peekw(aheure))- meheu)> (ti* 5)) and (act<> 5) then
   begin
    if ptemenu= 2 then
     dum:= savmem(1, atrava, 0,
                  coox[2], yaff, colg[2], (cooy[7]+ 12));
    act:= 5;
    voix(297, coxaf, coyaf, aecra2, per);
   end;
  until (bsta<> 0) or (act= 5);
  if (bsta<> 0) and (ptemenu= 2) then
   dum:= savmem(1, atrava, 0,
                coox[2], yaff, colg[2], (cooy[7]+ 12));
  if (bsta= 2) and (act<> 5) then
   if mptemenu<> -1 then
   begin
    ptemenu:= mptemenu;
    pcomenu:= mpcomenu;
    menu:= true;
   end;
  if (act<> 5) and (menu) then
   if ptemenu<> 2 then
   begin
    if (my< yaff) or (bsta= 2) then
    begin
     if ptemenu= 0 then nrep:= true;
     mptemenu:= ptemenu;
     act:= succ(ptemenu);
    end;
   end
   else
   begin
    if bsta<> 2 then
    begin
     cx:= 1;
     repeat
      if (my>= cooy[cx]) and (my<= (cooy[cx]+ 12))
       and (mx>= coox[2]) and (mx<= colg[2]) then pcomenu:= cx
      else cx:= succ(cx);
     until (cx> 7) or (pcomenu<> -1);
     if pcomenu<> -1 then
     begin
      mpcomenu:= pcomenu;
      mptemenu:= ptemenu;
     end;
    end;
    if pcomenu= 1 then
    begin
(* debug('memoriser'); *)
     memoire(1, choix);
     if choix> -1 then
     begin
      s.qui[choix]:= per;
      s.quoi[choix]:= int(rep);
      s.table[choix]:= table;
      s.poste[choix]:= poste;
     end;
    end;
    if pcomenu= 2 then
    begin
(* debug('opposer'); *)
     memoire(1, choix);
     if choix> -1 then
      if s.qui[choix]<> -1 then
      begin
       opposition(table, poste, 0,
                  s.table[choix], s.poste[choix], s.quoi[choix], 8,
                  rep);
       nrep:= true;
      end;
    end;
    if pcomenu= 3 then
    begin
(* debug('se souvenir'); *)
     memoire(1, choix);
     if choix> -1 then
      if s.qui[choix]<> -1 then
       voix(s.quoi[choix], 288, 0, adessi, s.qui[choix]);
    end;
    if pcomenu= 4 then
    begin
     nrep:= true;
     boitobj(1, meheu, true, som);
     if som> -1 then
     begin
      deplonb(per, dpadr(304), tot, nbr);
      trouv:= false;
      cx:= 0;
      if nbr> 0 then
       repeat
        if som= int(peek(dpadr(305)+ tot+ cx)) then trouv:= true
         else cx:= succ(cx);
       until (cx> pred(nbr)) or (trouv);
      if trouv then
      begin
       som:= 999;
       rep:= 0;
       if penal= 0 then
       begin
        gamelle:= gamelle+ 4;
        opposition(table, poste, 997, 0, 0, 0, gamelle, rep);
        gamelle:= succ(gamelle);
       end;
       if rep=0 then rep:= 380;
      end
      else rep:= 356;
     end
     else rep:= 375;
    end;
    if pcomenu= 5 then
    begin
(* debug('montrer'); *)
     confiance(-2);
     nrep:= true;
     boitobj(1, meheu, false, som);
     if som> -1 then
      rep:= peekw(dpadr(135)+ (((som* 9)+ per)* 2))
     else rep:= 375;
    end;
    if pcomenu= 6 then
    begin
(* debug('soudoyer'); *)
     confiance(-1);
     nrep:= true;
     if per= 5 then rep:= 300 else  (* vous pouvez garder votre pognon *)
     begin
      som:= s.sous div 2;
      boitsous(1, meheu, som);
      if som> -1 then
      begin
       if som>= peek(dpadr(10)+ per)+ (pred(mpenal)* 3) then
       begin
        s.sous:= s.sous- som;
        som:= 999;
        if penal= 1 then rep:= 379 (* pourquoi de l'argent *)
         else rep:= 361;   (* qu'est ce que vous voulez savoir *)
        if penal= 0 then
        begin
         gamelle:= gamelle+ 2;
         opposition(table, poste, 998, 0, 0, 0, gamelle, rep);
         gamelle:= succ(gamelle);
         if rep= 0 then rep:= 375;
        end;
        penal:= 0;
       end
       else
       begin
        if penal<> 0 then rep:= 300 else rep:= 299; (* + cher *)
        prem:= false;
       end;
      end
      else rep:= 375;
     end;
    end;
    if pcomenu= 7 then
    begin
(* debug('tabasser'); *)
     nrep:= true;
     rep:= 0;
     if mpers= 1 then confiance(-10) else confiance(-40);
     en[0]:= 30;
     en[1]:= 20;
     en[2]:= 40;
     en[3]:= 60;
     en[4]:= 60;
     en[5]:= 90;
     en[6]:= 90;
     en[7]:= 80;
     en[8]:= 40;
     if s.ener>= (en[per]+ mpenal) then
     begin
      s.cast[per]:= true;
      gnon(atrava);
      som:= 999;
      gamelle:= succ(gamelle);
      energie(-10, 0, false, false);
      if penal> 1 then rep:= 361 else
      (* 361: que voulez vous savoir *)
       opposition(table, poste, 999, 0, 0, 0, gamelle, rep);
      gamelle:= succ(gamelle);
      if rep= 0 then
       if per< 3 then rep:= 358 else rep:= 359;
(* 358: vous savez parler aux femmes
   359: vous etes cingle *)
     end
     else
     begin
      som:= 0;
      blk:= 99;
      if per< 3 then rep:= 359 else rep:= 378;
      ix:= (s.ener* ((en[per]+ mpenal)- s.ener))div 100;
      if ix< 15 then ix:= 15;
      energie(-ix, 0, false, false);
     end;
     if s.ener< 0 then act:= 4;
    end;
   end;
 until (act= 2) or (act> 3);
 dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
end;

procedure stobserver(ntab: integer; var rep: integer);
var
 tot, cx: integer;
 trouv: boolean;
begin
 trouv:= false;
 tot:= int(tailta(adonne, succ(ntab)));
 cx:= 0;
 if tot> 0 then
  repeat
   if s.mlieu= int(peek(dpadr(ntab)+ cx)) then trouv:= true
   else  cx:= cx+ 3;
  until (cx> pred(tot)) or (trouv);
 if trouv then
 begin
  trouv:= false;
  repeat
   if s.nbdh= int(peek(dpadr(ntab)+ succ(cx))) then
   begin
    trouv:= true;
    rep:= int(peek(dpadr(ntab)+ (cx+ 2)));
   end
   else cx:= cx+ 3;
  until (s.mlieu<> int(peek(dpadr(ntab)+ cx))) or
        (trouv) or (cx> tot);
 end;
end;

procedure tfleche(obj, loup: boolean; var fou: integer);
const
 depx= 4;
 depy= 12;
 larg= 8;
var
 bsta, cx, coox, cooy: integer;
begin
(* debug('tfleche');*)
(* hidemouse;
 line_color(15);
 line_style(1);
 for cx:= 0 to 33 do line(((cx* larg)+ depx), depy,
                          ((cx* larg)+ depx), (depy+ 176));
 for cx:= 0 to 22 do line(depx, ((cx* larg)+ depy),
                         (depx+ 264), ((cx* larg)+ depy));
 showmouse; *)
 if loup then
 begin
  nusou:= 2;
  chngmouse(2, 50);
 end
 else
 begin
  nusou:= 1;
  chngmouse(1, 5);
 end;
 repeat
  e_mouse(mx, my, bsta);
  if (bsta= 2) and (idem) then bsta:= 0;
  tinke(false, true, true, true, true, true, true, true, false, 0);
 until (bsta<> 0) or (glauque);
 if not glauque then
 begin
  if loup then
  begin
   mx:= mx+ 6;
   my:= my+ 6;
  end;
  if bsta= 2 then
  begin
   mx:= mmx;
   my:= mmy;
  end;
  coox:= (mx- depx) div larg;
  cooy:= (my- depy) div larg;
  nobj:= -1;
  npla:= -1;
  if obj then
  begin
   nobj:= nupo(273, coox, cooy, true);
   vtext(s.mlieu, nobj, 459);
  end;
  if nobj= -1 then npla:= nupo(274, coox, cooy, false);
  if (fou= 0) and (mx> 265) and (my> 180) then fou:= 1;
  mmx:= mx;
  mmy:= my;
 end;
end;

(* NIVEAU *)
procedure taller;
var
 cx, cy, ix, iy, rep, depl, tot, nbr, jum, lieu: integer;
 obj: array[0..nbobof] of integer;
 loquet, trouv, ok: boolean;
begin
(* debug('aller');*)
 loquet:= false;
 testcache;
 if not qdedans then
 begin
  s.hpas[pred(s.mlieu)]:= s.nbdh;
  ix:= pred((6* pred(s.mlieu))+ comenu);
  cy:= int(peek(dpadr(7)+ ix));
  iy:= int(peekw(dpadr(8)+ (ix* 2)));
  cx:= (s.ener div 20)- 2;
  iy:= iy- (iy* ((cx* 25) div 100));
  rmin:= rmin+ iy;
  kpart(12, s.mlieu, cy, -1, ok);
  if cy< 100 then
  begin
   s.mlieu:= cy;
   nusou:= 5;
   chngmouse(5, 4);
  end
  else
   if cy< 255 then tperd(1, (cy- 100));
  if cy= 255 then
  begin
   vblsync(15);
   cx:= -1;
   tfleche(true, false, cx);
   if not glauque then
   begin
    clef(434, loquet);
    if not loquet then
    begin
     srvop(nobj, 275, true, rep, depl);
     if depl= -1 then message(3, 2, rep, true) else s.mlieu:= rep;
    end
    else message(3, 2, 103, true);
   end;
  end;
  lieu:= pred(s.mlieu);
  if (not glauque) and (not loquet) then
   if (cy< 254) or ((cy= 255) and (depl<> -1)) then
   begin
    hidemouse;
    netmess;
    energie(-(iy div 96), 0, true, false);
  (* apparition loupe ou objet *)
    deplonb(lieu, dpadr(293), tot, nbr);
    for cx:= 0 to pred(nbr) do
    begin
     if (s.nbdh>= int(peek(dpadr(294)+ tot)))
         and (not s.evlo[tot]) then
     begin
      s.evlo[tot]:= true;
      cy:= int(peek(dpadr(296)+ tot));
      if s.etaob[cy]= 2 then tperd(1, (58+ int(hazard(0, 2))));
      if peek(dpadr(295)+ tot)= 1 then
      begin
       if s.etaob[cy]= 0 then s.etaob[cy]:= 1;
      end
      else if s.etaob[cy]= 1 then s.etaob[cy]:= 0;
     end;
     tot:= succ(tot);
    end;
  (* fin apparition *)
    if not glauque then
    begin
     tinke(true, false, true, false, false, false, false, false, false, 0);
     klibelle;
    end;
    if not glauque then
    begin
     nusou:= 5;
     chngmouse(5, 4);
    end;
    showmouse;
    if not glauque then
    begin
  (* fermeture porte ouverte *)
 (* kpart calle: lieu<> 27 *)
     if lieu<> 27 then
     begin
      cx:= s.hpas[lieu];
      if cx<= s.nbdh then
      begin
       trouv:= false;
       repeat
        for cy:= 0 to 8 do
         if int(peek(dpadr(0)+ ((cx- dhd)* 9)+ cy))= s.mlieu then
          trouv:= true;
        cx:= succ(cx);
       until (cx> s.nbdh) or (trouv);
       if trouv then
       begin
        kpart(11, s.mlieu, -1, -1, ok);
        deplonb(lieu, dpadr(297), tot, nbr);
        if nbr <> 0 then
        begin
         for cy:= 0 to pred(nbr) do
          obj[cy]:= int(peek(dpadr(298)+ tot+ cy));
         for cy:= nbr to nbobof do
          obj[cy]:= -1;
         cx:= 0;
         repeat
          cy:= 0;
          repeat
           if obj[cy]<> -1 then
           begin
            jum:= jumeaux(lieu, obj[cy]);
            if s.ouvfer[lieu, cy] then
            begin
             confiance(-2);
             s.ouvfer[lieu, cy]:= false;
             tvalid(lieu, 393, jum);
            end;
            if jum= obj[cy] then
            begin
             cx:= succ(cx);
             obj[cy]:= -1;
            end;
           end;
           cy:= succ(cy);
          until cy> pred(nbr);
         until cx> pred(nbr);
        end;
       end;
      end;
     end;
  (* fin fermeture *)
     if not qdedans then afdes(lieu, 0, 0, 0, false, true, true)
      else afdes(lieu, 0, 0, -1, false, true, true);
    end;
   end;
 end;
end;

procedure tappuyer;
var
 trouv, loquet: boolean;
 dum, rep: integer;
begin
(* debug('appuyer'); *)
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 dum:= -1;
 tfleche(true, false, dum);
 if not glauque then
  if npla<>-1 then
  begin
   message(3, 2, frvop(npla, 140, false), true);
   kpart(8, s.mlieu, npla, -1, trouv);
  end
  else
  begin
   verbouv(301, nobj, trouv);
   loquet:= false;
   clef(440, loquet);
   if not loquet then
   begin
    rep:= frvop(nobj, 74, true);
    if trouv then
    begin
     dum:= int(hazard(73, 75));
     if dum= 73 then dum:= 72;
     aprio(dum);
     actouv(nobj, 389);
    end;
    kpart(9, s.mlieu, nobj, -1, trouv);
   end
   else rep:= 103;
   message(3, 2, rep, true);
  end;
end;

procedure tattendre;
begin
(* debug('attendre'); *)
 hidemouse;
 netmess;
 afmenuact;
 s.nbdh:= succ(s.nbdh);
 energie(-1, 0, true, false);
 tinke(true, true, true, true, true, true, true, true, true, 0);
 if not glauque then message(3, 2, 4, true);
 showmouse;
end;

procedure tdormir;
begin
(* debug('dormir'); *)
 if s.mlieu<> 26 then
 begin
  hidemouse;
  afmenuact;
  message(3, 2, 449, true);
  showmouse;
 end
 else
 begin
  hidemouse;
  netmess;
  afmenuact;
  energie(6, 0, false, false);
  s.nbdh:= succ(s.nbdh);
  tinke(true, true, true, true, true, true, true, true, true, 0);
  s.nbdh:= succ(s.nbdh);
  tinke(true, true, true, true, true, true, true, true, true, 0);
  if not glauque then message(3, 2, 4, true);
  showmouse;
 end;
end;

procedure tfermer;
var
 trouv, ok: boolean;
 dum, lieu: integer;
 dep, long: long_integer;
begin
(* debug('fermer'); *)
 lieu:= pred(s.mlieu);
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 dum:= -1;
 tfleche(true, false, dum);
 if not glauque then
 begin
  trouv:= false;
  dum:= posouv(nobj, true);
  if dum<> -1 then
  begin
   if not s.ouvfer[lieu, dum] then premrep(nobj, 118, trouv);
   if not trouv then
   begin
    s.ouvfer[lieu, dum]:= false;
    deplonw((dum+ mtot), dpadr(300), dep, long);
    hidemouse;
    decomp(0, atrava, (adesfe+ dep- rdepf), 0, 0, aecra1);
    moveblok(aecra1, aecra2, 4, 12, 259, 174);
    kpart(4, s.mlieu, nobj, -1,  ok);
    tvalid(lieu, 393, nobj);
    showmouse;
   end;
  end;
  if not trouv then message(3, 2, frvop(nobj, 78, false), true);
 end;
end;

procedure tfouiller;
var
 fou, pos: integer;
 trouv: boolean;
begin
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 fou:= 0;
 tfleche(true, false, fou);
 if not glauque then
 begin
  if not qdedans then
  begin
   if mpers<> 0 then confiance(-1);
  end
  else confiance(-3);
  if fou= 1 then pchaien else
  begin
   trouv:= false;
   if npla<> -1 then
   begin
    premrep(npla, 183, trouv);
    if not trouv then pchaine(npla, 152, 186);
   end
   else
   begin
    pos:= posouv(nobj, true);
    if pos<> -1 then
     if not s.ouvfer[pred(s.mlieu), pos] then premrep(nobj, 121, trouv);
    if not trouv then pchaine(nobj, 82, 136);
    tvalid(pred(s.mlieu), 397, nobj);
   end;
  end;
 end;
end;

procedure tlire;
var
 cx, tot, dum, meheu, text, rep: integer;
 dep, long, dum1: long_integer;
 trouv, ok: boolean;
begin
(* debug('lire'); *)
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 dum:= -1;
 tfleche(false, false, dum);
 if not glauque then
 begin
  ok:= true;
  rep:= frvop(npla, 156, false);
  if npla<> -1 then
  begin
   kpart(10, s.mlieu, npla, -1, ok);
   if ok then
   begin
    tot:= int(peek(dpadr(471)));
    trouv:= false;
    cx:= 0;
    if tot<> 255 then
     repeat
      if s.mlieu= int(peek(dpadr(472)+ cx)) then
      begin
       if npla= int(peek(dpadr(473)+ cx)) then
       begin
        meheu:= int(peekw(aheure));
        dum:= int(peek(dpadr(474)+ cx));
        lecture(atrava, adessi, dum, 3);
        hidemouse;
        exitani;
        afmenu0(0);
        decomp(0, atrava, adessi, 0, 0, aecra1);
        text:= int(peekw(dpadr(475)+ (cx* 2)));
        if text<> -1 then
         dum1:= aftext(-1, (atexte+ ltext1+ ltext2+ ltext3),
                       (alongt+ llong1+ llong2+ llong3),
                       adtext, aecra1, (alettr+ peekw(alettr)), 30, 30, 194,
                       10, 0, 1, 0, text);
        styleff(true, 4, -2, 4, 12, 315, 174);
        showmouse;
        atclick(false);
        if (s.mlieu= 9) or (s.mlieu= 10) then
         afdes(pred(s.mlieu), 0, 0, 0, false, true, true)
        else
        afdes(pred(s.mlieu), 0, 0, 0, false, false, true);
        initani;
        pokew(aheure, meheu);
        trouv:= true;
       end
       else cx:= succ(cx);
      end
      else cx:= succ(cx);
     until (cx> tot) or (trouv);
   end;
  end;
  if ok then message(3, 2, rep, true);
 end;
end;

procedure tmanger;
begin
(* debug('manger'); *)
 if s.mlieu<> 2 then
 begin
  hidemouse;
  afmenuact;
  message(3, 2, 448, true);
  showmouse;
 end
 else
 begin
  if (heu= 13) or (heu= 20) or (heu= 9) then
  begin
   hidemouse;
   netmess;
   afmenuact;
   testcache;
   if heu= 9 then
   begin
    s.nbdh:= succ(s.nbdh);
    energie(7, 0, false, false);
    tinke(true, true, true, true, true, true, true, true, true, 0);
   end
   else
   begin
    s.nbdh:= succ(s.nbdh);
    energie(14, 0, false, false);
    tinke(true, true, true, true, true, true, true, true, true, 0);
    s.nbdh:= succ(s.nbdh);
    tinke(true, true, true, true, true, true, true, true, true, 0);
   end;
   if not glauque then message(3, 2, 4, true);
   showmouse;
  end
  else message(3, 2, 450, true);
 end;
end;

procedure tmettre;
var
 trouv, ok: boolean;
 dep, dep2, long: long_integer;
 dum, cx, depl, nu, tot, nbr, rep, jum, nval, lieu: integer;
begin
(* debug('mettre'); *)
 if s.dobj<> -1 then
 begin
  lieu:= pred(s.mlieu);
  hidemouse;
  netmess;
  afmenuact;
  testcache;
  showmouse;
  dum:= -1;
  tfleche(true, false, dum);
  if not glauque then
  begin
   trouv:= false;
   if (posouv(nobj, true)<> -1) then
    if not s.ouvfer[lieu, posouv(nobj, true)] then
     premrep(nobj, 127, trouv);
   if not trouv then
   begin
    rechai(nobj, 89, 136, rep, depl, trouv);
    if trouv then
    begin
     trouv:= false;
     cx:= 0;
     repeat
      if s.chob[nuchai, cx]= -1 then trouv:= true else cx:= succ(cx);
     until (cx> nbobj) or (trouv);
     if trouv then
     begin
      s.chob[nuchai, cx]:= s.dobj;
      s.dobj:= -1;
      message(3, 2, rep, true);
     end
     else message(3, 2, 318, true);
    end
    else
     if depl<> -1 then
     begin
      dum:= int(peek(dpadr(93)+ depl));
      if dum<> 255 then
       if dum= int(peek(dpadr(196)+ s.dobj)) then
       begin
        kpart(6, s.mlieu, nobj, dum, ok);
        if ok then
        begin
         deplonb(lieu, dpadr(192), tot, nbr);
         nu:= 0;
         trouv:= false;
         if nbr<> 0 then
         begin
          repeat
           if s.dobj= int(peek(dpadr(195)+ tot+ nu)) then trouv:= true
            else nu:= succ(nu);
          until (nu> pred(nbr)) or (trouv);
          if trouv then
          begin
           jum:= jumeaux(lieu, int(peek(dpadr(193)+ tot+ nu)));
           nval:= posval(lieu, jum);
           if nval<> -1 then
            if s.oval[nval] then tvalid(pred(s.mlieu), 401, jum);
           kpart(5, s.mlieu, nobj, s.dobj, ok);
           deplonw((tot+ nu), dpadr(306), dep, long);
           if long<> 0 then
           begin
            aprio(hazard(74, 75));
            deplonw(tot, dpadr(306), dep2, long);
            hidemouse;
            decomp(0, atrava, (adespr+ dep- dep2), 0, 0, aecra1);
            moveblok(aecra1, aecra2, 4, 12, 259, 174);
            showmouse;
            message(3, 2, rep, true);
            s.dobj:= -1;
            tot:= tot+ nu;
            s.etaob[tot]:= 0;
            deplonw(tot, dpadr(308), dep, long);
            if long<> 0 then
            begin
             pokel((aoblo+ (nu* 4)), (adeslo+ dep- rdepl));
             deplonw(tot, dpadr(309), dep, long);
             pokew((axoblo+ (nu* 2)), long);
             deplonw(tot, dpadr(310), dep, long);
             pokew((ayoblo+ (nu* 2)), long);
            end;
            tvalid(pred(s.mlieu), 401, nobj);
           end
           else message(3, 2, 249, true);
          end
          else message(3, 2, 249, true);
         end;
        end;
       end
       else
       begin
        if dum= 254 then
        begin
         kpart(7, s.mlieu, nobj, s.dobj, ok);
         if ok then message(3, 2, 249, true);
        end
        else message(3, 2, 249, true);
       end;
     end
     else message(3, 2, rep, true);
   end;
  end;
  afmenu0(0);
 end
 else message(3, 2, 320, true);
end;

procedure tobserver;
var
 rep: integer;
begin
(* debug('observer'); *)
 rep:= -1;
 if cache then stobserver(12, rep);
 if rep= -1 then stobserver(11, rep);
 if rep<> -1 then message(3, 1, rep, true)
  else message(3, 1, int(hazard(98, 103)), true);
end;

procedure touvrir;
var
 trouv, ok, loquet: boolean;
 dum, cx, rep: integer;
begin
(* debug('ouvrir'); *)
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 dum:= -1;
 tfleche(true, false, dum);
 if not glauque then
 begin
  dum:= posouv(nobj, true);
  if dum<> -1 then
  begin
   trouv:= false;
   if s.ouvfer[pred(s.mlieu), dum] then premrep(nobj, 124, trouv);
   if not trouv then
   begin
    loquet:= false;
    clef(440, loquet);
    if not loquet then
    begin
     rep:= frvop(nobj, 94, false);
     cx:= 301;
     repeat
      verbouv(cx, nobj, trouv);
      cx:= succ(cx);
     until (trouv) or (cx> 303);
     if not trouv then
     begin
      kpart(1, s.mlieu, nobj, -1, ok);
      if ok then actouv(nobj, 405) else rep:= 256;
     end;
    end
    else rep:= 103;
    message(3, 2, rep, true);
   end;
  end
  else message(3, 2, frvop(nobj, 94, false), true);
 end;
end;

procedure tparler(per, col: integer);
const
 haut= 8;      (* hauteur entre deux lignes *)
 npmaxs1= 14;  (* selectables table 1 *)
 longs1= 140;
 depx1= 147;
 depy1= 40;
 nut1= 261;
 npmaxt1= -1;  (* non selectable table 1 *)
 longt1= 0;
 npmaxs2= 19;  (* selectable table 2 *)
 longs2= 197;
 depx2= 114;
 depy2= 17;
 nut2= 262;
 npmaxt2= 0;   (* non selectable table 2 *)
 longt2= 192;
 npmaxs34= 37; (* selectable table 3 et 4 *)
 longs34= 100;
 depx341= 115;
 depx342= 215;
 depy34= 13;
 nut34= 263;
 npmaxt34= 1;  (* non selectable table 3 et 4 *)
 longt34= 100;
var
 meheu, quoi, rep, haz, act, cx: integer;
 table, poste, penal, mpenal, som, blk: integer;
 pie: array[0..8] of integer;
 dum, dum1: long_integer;
 fou, ok: boolean;
 hxs1, hys1, nps1, hxs2, hys2, nps2, hxs34, hys34, nps34: thxys;
 hxt1, hyt1, npt1, hxt2, hyt2, npt2, hxt34, hyt34, npt34: thxyt;
begin
 hidemouse;
 exitani;
 if col= 1 then
 begin
  afdes(pred(s.mlieu), 0, 0, -1, false, true, true);
  posmouse(131, 85, 0, 0, 304, 198);
 end;
 dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
 testcache;
 fou:= false;
 gamelle:= 0;
 som:= 0;
 blk:= 0;
 haz:= 0;
 mptemenu:= -1;
 mpcomenu:= -1;
 remap;
 if per= -1 then
 begin
  pie[0]:= 3;
  pie[1]:= 5;
  pie[2]:= 7;
  pie[3]:= 20;
  pie[4]:= 19;
  pie[5]:= 21;
  pie[6]:= 25;
  pie[7]:= 27;
  pie[8]:= 8;
  cx:= -1;
  repeat
   cx:= succ(cx);
  until s.mlieu= pie[cx];
  per:= cx;
  if not qdedans then fou:= true;
 end;
 cadre;
 afdes((33+ per), 28, -1, 1, false, true, true);
 showmouse;
 meheu:= int(peekw(aheure));
 act:= 0;
 penal:= 0;
 if qdedans then
  if (heu> 22) or (heu< 8) then
   if per= memper then
   begin
(*debug('entrer trop tard et en plus surpris a suivre avant');*)
    confiance(-2);
    penal:= 7;
    rep:= 367;
   end
   else
   begin
(*debug('entrer trop tard'); *)
    confiance(-1);
    penal:= 5;  (* entrer *)
    rep:= 298;
  end;
 haz:= int(hazard(1, 5));
 if (haz> 2) or (col= 2) then
 begin
  if col= 1 then
  begin
(*debug('suivre pas de dial');*)
   penal:= 6;  (* suivre *)
   rep:= 296;
  end
  else
   if col = 2 then
   begin
(*debug('essaie suivre pas de dial');*)
    confiance(-2);
    penal:= 6;  (* suivre *)
    rep:= 362;
   end;
 end;
 if (haz> 2) and (fou) then
 begin
(*debug('fouiller pas de dial');*)
  confiance(-3);
  penal:= 7;  (* fouiller *)
  rep:= 363;
 end;
 if penal= 0 then
 begin
(*if qdedans then debug('entrer + dial') else
if col= 1 then debug('suivre + dial') else
if fou then debug('fouiller + dial') else
debug('dial'); *)
  if qdedans then
  begin
   if per= memper then
   begin
(*debug('entrer et en plus surpris a suivre avant'); *)
    confiance(-2);
    penal:= 4;
    rep:= 367;
   end
   else
   begin
    confiance(-1);
    penal:= 2; (* entrer ou surpris sans fouiller *)
    rep:= 360;
   end;
  end
  else
   if col= 1 then
   begin
    penal:= 3; (* suivre *)
    rep:= 364;
   end
   else
    if fou then
    begin
     confiance(-2);
     penal:= 4; (* fouiller *)
     rep:= 365;
    end
    else
    begin
     penal:= 1;
     rep:= 368+ per;
    end;
 end;
 if per= mempper then
 begin
  penal:= penal+ 2;
  if hazard(0, 1)= 1 then rep:= 367 else rep:= 362;
 end;
 mpenal:= penal;
 sparl(rep, 0, 0, per, meheu, penal, mpenal, act, som, blk);
 penal:= 0;
 if act= 2 then
 begin
  rep:= 0;
  quoi:= 0;
  repeat
   dum1:= savmem(0, aecra1, atrava, 119, 13, 315, 195);
   for cx:= 0 to npmaxs1 do
   begin
    if cx< 4 then
     hys1[cx]:= depy1+ (cx* haut)
    else
    hys1[cx]:= depy1+ (succ(cx)* haut);
    hxs1[cx]:= depx1;
    if s.te1auto[cx] then
     nps1[cx]:= int(peek(dpadr(nut1)+ cx))
    else
     nps1[cx]:= -1;
   end;
   for cx:= 0 to npmaxs2 do
   begin
    hys2[cx]:= depy2+ ((cx+ 2)* haut)- 1;
    hxs2[cx]:= depx2;
    if s.te2auto[cx] then
     nps2[cx]:= int(peek(dpadr(nut2)+ cx))
    else
     nps2[cx]:= -1;
   end;
   hyt2[0]:= depy2;
   hxt2[0]:= depx2;
   npt2[0]:= 78;
   for cx:= 0 to npmaxs34 do
   begin
    if cx< 17 then
    begin
     if cx< 2 then
      hys34[cx]:= depy34+ ((cx+ 2)* haut)
     else
     if cx< 16 then
       hys34[cx]:= depy34+ ((cx+ 4)* haut)
      else
       hys34[cx]:= depy34+ ((cx+ 6)* haut);
     hxs34[cx]:= depx341;
    end
    else
    begin
     hys34[cx]:= depy34+ (((cx+ 2)- 17)* haut);
     hxs34[cx]:= depx342;
    end;
    if cx< 2 then nps34[cx]:= int(peek(dpadr(nut34)+ cx)) else
     if s.te34auto[pred(cx)] then
      nps34[cx]:= int(peek(dpadr(nut34)+ cx))
     else
      nps34[cx]:= -1;
   end;
   if s.te34auto[1] then npt34[0]:= 137 else npt34[0]:= -1;
   hyt34[0]:= depy34+ (5* haut)- 2;
   hxt34[0]:= depx341;
   if s.te34auto[15] then npt34[1]:= 138 else npt34[1]:= -1;
   hyt34[1]:= depy34+ (21* haut)- 2;
   hxt34[1]:= depx341;
   hidemouse;
   setdialog(true, 3, npmaxs1, longs1, hxs1, hys1, nps1,
             npmaxt1, longt1, hxt1, hyt1, npt1, 15);
   styleff(true, 5, 6, 119, 13, 315, 195);
   showmouse;
   dodialog(hxs1, hys1, nps1, longs1, npmaxs1, meheu, quoi, true);
   if quoi> -1 then
   begin
    if (quoi= 0) or (quoi= 1) then
    begin
     table:= succ(quoi);
     recte34(quoi, npmaxs34, longs34, hxs34, hys34, nps34,
             npmaxt34, longt34, hxt34, hyt34, npt34,
             per, meheu, rep, quoi);
(* le calcul du poste est bidouille car les tables ont ete saisies
                          a l'envers *)
     poste:= (per* 40)+ quoi;
     recrep(table, poste, ok, rep);
    end
    else
     if quoi= 3 then
     begin
      table:= 5;
      hidemouse;
      dum:= savmem(1, atrava, aecra1, 119, 13, 315, 195);
      setdialog(true, 3, npmaxs2, longs2, hxs2, hys2, nps2,
                npmaxt2, longt2, hxt2, hyt2, npt2, 15);
      styleff(true, 5, 6, 119, 13, 315, 195);
      showmouse;
      dodialog(hxs2, hys2, nps2, longs2, npmaxs2, meheu, quoi, true);
      if quoi> -1 then
      begin
(* le calcul du poste est bidouille car les tables ont ete saisies
                          a l'envers *)
       poste:= (per* 22)+ quoi+ 2;
(* le calcul de la rep demande un rajout de 36 octets car melange des tables
                          generales et personnage *)
       recrep(table, poste, ok, rep);
       if not ok then rep:= int(peekw(dpadr(5)+ (((9* quoi)+ per)* 2)+ 36));
      end
      else dum:= savmem(1, atrava, aecra1, 119, 13, 315, 195);
     end
     else
      if quoi= 2 then
      begin
       table:= 3;
(* le calcul du poste est bidouille car les tables ont ete saisies
                          a l'envers *)
       poste:= (per* 74)+ s.nbdh- dhd;
       recrep(table, poste, ok, rep);
       if not ok then rep:= int(peekw(dpadr(3)+ ((9* (s.nbdh- dhd))+ per)* 2));
       if rep= 0 then rep:= 141+ int(hazard(0, 2));
      end
      else
      begin
(* les tables discutions sur les gens ont ete separees dans deux tables
     (perso et generale) d'ou obligation de bidouillage de tests *)
       if quoi< 13 then
       begin
        table:= 4;
        poste:= (per* 9)+ quoi- 4;
        recrep(table, poste, ok, rep);
        if not ok then rep:= int(peekw(dpadr(4)+ (poste* 2)));
       end
       else
       begin
        table:= 5;
(* le calcul du poste est bidouille car les tables ont ete saisies
                          a l'envers *)
        poste:= (per* 22)+ quoi- 13;
        recrep(table, poste, ok, rep);
        if not ok then rep:= int(peekw(dpadr(5)+ ((((quoi- 13)* 9)+ per)* 2)));
       end;
      end;
    if quoi> -1 then
    begin
     hidemouse;
     dum:= savmem(1, atrava, aecra1, 119, 13, 315, 195);
     styleff(true, 5, 6, 119, 13, 315, 195);
     showmouse;
     sparl(rep, table, poste, per, meheu, penal, mpenal, act, som, blk);
    end;
   end
   else
   begin
    hidemouse;
    dum:= savmem(1, atrava, aecra1, 119, 13, 315, 195);
    styleff(true, 5, 6, 119, 13, 315, 195);
    showmouse;
    if quoi<> -3 then
     sparl(375, 0, 0, per, meheu, penal, mpenal, act, som, blk)
    else
    begin
     act:= 5;
     sparl(297, 0, 0, per, meheu, penal, mpenal, act, som, blk)
    end;
   end;
   if act= 5 then
   begin
(*debug('fin du temps');*)
    hidemouse;
    dum:= savmem(1, atrava, aecra1, 119, 13, 315, 195);
    styleff(true, 5, 6, 119, 13, 315, 195);
    showmouse;
   end;
  until (act> 3);
 end;
 hidemouse;
 mempper:= per;
 tinke(true, false, false, false, false, false, false, false, false, 0);
 if not perdu then
 begin
  present(true);
  if qdedans then s.mlieu:= int(peek(dpadr(13)+ pred(s.mlieu)));
  qdedans:= false;
  s.hpas[pred(s.mlieu)]:= s.nbdh;
  afdes(pred(s.mlieu), 0, 0, -1, false, true, true);
  mjou:= -1;
  tinke(true, true, true, false, true, false, true, false, false, 0);
  if not assom then pamb else preglauque;
  efnoir;
  if not assom then
  begin
   damb(s.nbdh);
   initani;
  end;
 end;
 posmouse(131, 85, 0, 0, 304, 198);
 nusou:= 3;
 chngmouse(3, 5);
 showmouse;
end;

procedure tprendre;
var
 cx, cy, dum, rep, depl, obj, arg, tot, nbr: integer;
 dep: long_integer;
 pla, ok, iben: boolean;
begin
(* debug('prendre');  *)
 iben:= true;
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 dum:= -1;
 tfleche(true, false, dum);
 if not glauque then
 begin
  srvop(nobj, 131, true, rep, depl);
  if depl<> -1 then
  begin
   srvop(nobj, 192, false, dum, depl);
   if depl<> -1 then
   begin
    dum:= int(peek(dpadr(194)+ depl));
    if dum<> 255 then
     if s.etaob[depl]<> 0 then rep:= 67 else
     begin
      pla:= false;
      obj:= int(peek(dpadr(195)+ depl));
      arg:= objpart(332, obj);
      if arg= -1 then
      begin
       placjer(pla);
       if pla then
       begin
        if obj> 250 then kpart(15, s.mlieu, obj, -1, iben);
        if iben then
        begin
         suri(55);
         s.dobj:= obj;
         pokew(adobj, int(peek(dpadr(198)+ s.dobj)));
         vtext(obj, -1, 450);
         vpour(mpo, obj, -1, 466);
         tvalid(pred(s.mlieu), 409, nobj);
        end;
       end
       else rep:= 317;
      end
      else
      begin
       fric;
       s.sous:= s.sous+ int(peekw(dpadr(334)+ (arg* 2)));
      end;
      if (arg<> -1) or (pla) then
      begin
       if obj< 250 then kpart(15, s.mlieu, nobj, -1, ok);
       s.etaob[depl]:= 2;
       deplonb(pred(s.mlieu), dpadr(192), tot, nbr);
       pokel(aoblo+ ((depl- tot)* 4), -1);
       if (peekw(dpadr(307)+ (depl* 2))<> 0)
(*attention special grotte fin *) or (s.mlieu= 30) then
       begin
        dep:= 0;
        for cy:= tot to pred(depl) do dep:= dep+ peekw(dpadr(307)+ (cy* 2));
        hidemouse;
        decomp(0, atrava, (adesab+ dep), 0, 0, aecra1);
        moveblok(aecra1, aecra2, 4, 12, 259, 174);
        showmouse;
       end;
      end;
     end;
   end;
  end;
  afmenu0(0);
  if iben then message(3, 2, rep, true);
 end;
end;

procedure tregarder;
var
 rep, cx, supxh, supyh, supxb, supyb: integer;
 dum, fact, xaff, yaff, cooxh, cooyh, cooxb, cooyb: long_integer;
begin
(* debug('regarder'); *)
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 cx:= -1;
 tfleche(true, true, cx);
 if not glauque then
 begin
  if npla<>-1 then rep:= frvop(npla, 164, false)
   else rep:= frvop(nobj, 98, true);
  if (mx> 4) and (mx< 259) and (my> 12) and (my< 175) then
  begin
   hidemouse;
   message(-1, 2, rep, true);
   supxh:= 0;
   supyh:= 0;
   supxb:= 0;
   supyb:= 0;
   cooxh:= mx;
   cooxb:= mx;
   cooyh:= my;
   cooyb:= my;
   cx:= 0;
   repeat
    cooxh:= pred(cooxh);
    cx:= succ(cx);
   until (cooxh= 4) or (cx= 15);
   if (cooxh= 4) and (cx< 15) then supxb:= 15- cx;
   cx:= 0;
   repeat
    cooyh:= pred(cooyh);
    cx:= succ(cx);
   until (cooyh= 12) or (cx= 8);
   if (cooyh= 12) and (cx< 8) then supyb:= 8- cx;
   cx:= 0;
   repeat
    cooxb:= succ(cooxb);
    cx:= succ(cx);
   until (cooxb= 259) or (cx= 15);
   if (cooxb= 259) and (cx< 15) then supxh:= cx- 15;
   cx:= 0;
   repeat
    cooyb:= succ(cooyb);
    cx:= succ(cx);
   until (cooyb= 175) or (cx= 8);
   if (cooyb= 175) and (cx< 8) then supyh:= cx- 8;
   cooxh:= cooxh+ supxh;
   cooxb:= cooxb+ supxb;
   cooyh:= cooyh+ supyh;
   cooyb:= cooyb+ supyb;
   fact:= 2;
   yaff:= cooyh- 7;
   xaff:= cooxh- 15;
   if xaff< 2 then xaff:= 2;
   if xaff> 198 then xaff:= 198;
   if yaff< 12 then yaff:= 12;
   if yaff> 138 then yaff:= 138;
   dum:= savmem(0, aecra1, atrava,
                 (xaff- 2), (yaff- 2), (xaff+ 90), (yaff+ 60));
   mloupe(amloupe, (xaff- 2), (yaff- 2));
   grossi(aoblo, fact, yaff, xaff,
          yaff+ ((cooyb- cooyh)* fact), xaff+ ((cooxb- cooxh)* fact),
          yaff, xaff,
          cooyb, cooxb, cooyh, cooxh, (atrava+ dum), aecra1);
   decomp(0, (atrava+ dum), aloupe, (xaff- 2), (yaff- 2), aecra1);
   styleff(true, 5, 0, (xaff- 2), (yaff- 2), (xaff+ 90), (yaff+ 60));
   showmouse;
   atclick(true);
   hidemouse;
   dum:= savmem(1, atrava, aecra1,
                 (xaff- 2), (yaff- 2), (xaff+ 90), (yaff+ 60));
   styleff(true, 5, 0, (xaff- 2), (yaff- 2), (xaff+ 90), (yaff+ 60));
   dum:= savmem(1, atrava, 0,
                 (xaff- 2), (yaff- 2), (xaff+ 90), (yaff+ 60));
   showmouse;
  end
  else message(3, 2, rep, true);
 end;
end;

procedure tsentir;
var
 dum: integer;
begin
(* debug('sentir'); *)
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 dum:= -1;
 tfleche(true, false, dum);
 if not glauque then message(3, 2, frvop(nobj, 102, false), true);
end;

procedure tsonder;
var
 trouv: boolean;
 dum: integer;
begin
(* debug('sonder'); *)
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 dum:= -1;
 tfleche(true, false, dum);
 if not glauque then
 begin
  trouv:= false;
  if npla<>-1 then message(3, 2, frvop(npla, 168, false), true)
  else
  begin
   kpart(14, s.mlieu, nobj, -1, trouv);
   if trouv then
   begin
    message(3, 2, frvop(nobj, 106, true), true);
    tvalid(pred(s.mlieu), 413, nobj);
   end;
  end;
 end;
end;

procedure tsoulever;
var
 trouv, loquet: boolean;
 dum, rep: integer;
begin
(* debug('soulever'); *)
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 dum:= -1;
 tfleche(true, false, dum);
 if not glauque then
 begin
  if npla<>-1 then message(3, 2, frvop(npla, 172, false), true)
  else
  begin
   verbouv(302, nobj, trouv);
   loquet:= false;
   clef(440, loquet);
   if not loquet then
   begin
    rep:= frvop(nobj, 110, true);
    if trouv then
    begin
     dum:= int(hazard(73, 75));
     if dum= 73 then dum:= 72;
     aprio(dum);
     actouv(nobj, 417);
    end;
   end
   else rep:= 103;
   message(3, 2, rep, true);
  end;
 end;
end;

procedure tsuivre(per: integer; var col: integer);
var
 dum, dum1, dum2, meheu: long_integer;
 cx, tex, pie, nb, bsta, haz, memlieu: integer;
 coox, colg: array[1..2] of integer;
 perd, menu, sassom: boolean;
begin
(* debug('suivre'); *)
 sassom:= false;
 memlieu:= s.mlieu;
 if per= memper then col:= 2 else
  if ((heu> 20) or (heu< 6)) and (s.mlieu> 8) and (s.mlieu< 16) then
  begin
   suri(63);
   hidemouse;
   testcache;
   message(3, 2, 451, true);
   showmouse;
  end
  else
  begin
   hidemouse;
   e_mouse(cx, nb, bsta);
   netmess;
   testcache;
   exitani;
   s.hpas[pred(s.mlieu)]:= s.nbdh;
   meheu:= peekw(aheure);
   dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
   clrblk(aecra1, 3, 11, 260, 196);
   afdes((33+ per), 0, 0, 1, true, true, true);
   posmouse(cx, 0, 0, 0, 302, 12);
   dum1:= savmem(0, aecra1, atrava, 8, 77, 119, 100);
   dum2:= savmem(0, aecra1, (atrava+ dum1), 8, 168, 119, 190);
   showmouse;
   depbon(0, s.mlieu, true, tex);
   depbon(1, s.mlieu, true, tex);
   nb:= 0;
   mstemenu:= 0;
   perd:= false;
   repeat
    if nb= 1 then
    begin
     haz:= int(hazard(1, 6));
     if haz= 5 then perd:= true;
    end
    else
     if nb< 5 then
     begin
      haz:= int(hazard(1, 5));
      if (nb= 2) and (haz= 5) then perd:= true;
      if (nb= 3) and (haz> 3) then perd:= true;
      if (nb= 4) and (haz> 2) then perd:= true;
     end
     else
     begin
      haz:= int(hazard(1, nb));
      if haz<> nb then perd:= true;
     end;
    if (perd) and (memlieu<> -1) then perd:= false;
    s.nbdh:= succ(s.nbdh);
    tinke(true, true, false, false, false, false, false, false, false,
                                                             (dum1+ dum2));
    if not glauque then
    begin
     dum1:= savmem(1, atrava, aecra1, 8, 77, 119, 100);
     dum2:= savmem(1, (atrava+ dum1), aecra1, 8, 168, 119, 190);
     pie:= int(peek(dpadr(0)+ ((s.nbdh- dhd)* 9)+ per));
     if pie<> memlieu then memlieu:= -1;
     if ((heu> 20) or (heu< 6)) and (pie> 8) and (pie< 16) then perd:= true;
     hidemouse;
     depbon(0, pie, false, tex);
     if not perd then
     begin
      eftext(3, (tex+ 145), false, false, 110, 9, 77, 8, 15, aecra1);
      styleff(true, 5, 0, 8, 77, 119, 100);
     end;
     s.mlieu:= int(peek(dpadr(9)+ pred(pie)));
     if s.mlieu<> memlieu then memlieu:= -1;
     if ((heu> 20) or (heu< 6)) and
      (s.mlieu> 8) and (s.mlieu< 16) then perd:= true;
     depbon(1, s.mlieu, false, tex);
     eftext(3, (tex+ 145), false, false, 110, 9, 168, 8, 15, aecra1);
     styleff(true, 5, 0, 8, 168, 119, 190);
     showmouse;
     if not perd then
     begin
      tinke(true, true, true, true, true, true, false, false, false,
                                                              (dum1+ dum2));
      if glauque then
      begin
       sassom:= true;
       perd:= true;
      end;
      nb:= succ(nb);
      if nb= 1 then
      begin
       afmenu3(0);
       for cx:= 1 to 2 do
       begin
        coox[cx]:= int(peekw(dpadr(246)+ (pred(cx)* 4)));
        colg[cx]:= coox[cx]+ int(peekw(dpadr(246)+ (pred(cx)* 4)+ 2));
       end;
      end;
      stemenu:= 0;
      if not glauque then
       repeat
        repeat
         e_mouse(mx, my, bsta);
        until (bsta<> 0);
        if (bsta<> 2) or (mstemenu= 0) then
        begin
         if my< 12 then
         begin
          menu:= false;
          cx:= 1;
          repeat
           if (mx> coox[cx]) and (mx< colg[cx]) then menu:= true
           else cx:= succ(cx);
          until (menu) or (cx> 2);
          if (menu) and (bsta<> 0) then stemenu:= cx;
         end;
        end
        else stemenu:= 1;
       until (stemenu<> 0);
      mstemenu:= stemenu;
     end;
    end;
   until (perd) or (stemenu= 2) or (glauque);
 (*  if not glauque then
   begin *)
    if perd then
    begin
     dum2:= savmem(1, atrava, aecra1, 8, 77, 119, 100);
     if ((heu< 21) and (pie<> s.mlieu) and (pie> 8) and (pie< 16))
      or (sassom) then
     begin
      col:= 0;
      dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
      dpb(0, -1, 0, 0, 0, 0);
      if per< 3 then tex:= 144 else tex:= 143;
      eftext(3, tex, false, false, 110, 9, 77, 8, 15, aecra1);
      styleff(true, 5, 0, 8, 77, 119, 91);
      atclick(true);
     end
     else
     begin
      eftext(3, (145+ tex), false, false, 110, 9, 77, 8, 15, aecra1);
      styleff(true, 5, 0, 8, 77, 119, 100);
      memper:= per;
      col:= 1;
      confiance(-2);
     end;
    end;
    dpb(0, -1, 0, 0, 0, 0);
    dpb(1, -1, 0, 0, 0, 0);
    vblsync(5);
  (* end; *)
   if (col= 0) or (glauque) then
   begin
    hidemouse;
    if glauque then
    begin
     dpb(0, -1, 0, 0, 0, 0);
     dpb(1, -1, 0, 0, 0, 0);
     vblsync(5);
    end;
    present(true);
    afdes(pred(s.mlieu), 0, 0, -1, false, true, true);
    mjou:= -1;
    tinke(true, true, true, false, true, false, true, false, false, 0);
    posmouse(131, 85, 0, 0, 304, 198);
    if glauque then preglauque else pamb;
    efnoir;
    if not glauque then
    begin
     damb(s.nbdh);
     initani;
    end;
    nusou:= 3;
    chngmouse(3, 5);
    qdedans:= false;
    showmouse;
   end;
   pokew(aheure, meheu);
  end;
end;

procedure ttourner;
var
 trouv, loquet, ok: boolean;
 dum, rep, jum: integer;
begin
(* debug('tourner'); *)
 hidemouse;
 netmess;
 afmenuact;
 testcache;
 showmouse;
 dum:= -1;
 tfleche(true, false, dum);
 if not glauque then
  if npla<>-1 then
  begin
   message(3, 2, frvop(npla, 176, false), true);
   kpart(2, s.mlieu, npla, -1, ok);
  end
  else
  begin
   if s.mlieu= 30 then
   begin
    tvalid(pred(s.mlieu), 421, nobj);
    kpart(3, s.mlieu, nobj, -1, ok);
    if ok then rep:= 253 else rep:= 336;
   end
   else
   begin
    verbouv(303, nobj, trouv);
    loquet:= false;
    clef(440, loquet);
    if not loquet then
    begin
     rep:= frvop(nobj, 114, true);
     if trouv then
     begin
      dum:= int(hazard(73, 75));
      if dum= 73 then dum:= 72;
      aprio(dum);
      actouv(nobj, 421);
     end;
     kpart(3, s.mlieu, nobj, -1, ok);
    end
    else rep:= 103;
   end;
   message(3, 2, rep, true);
  end;
end;

procedure tscacher;
var
 trouv: boolean;
 dum, cx: integer;
begin
(* debug('scacher'); *)
 dum:= -1;
 hidemouse;
 netmess;
 testcache;
 showmouse;
 tfleche(false, false, dum);
 if not glauque then
 begin
  trouv:= false;
  if npla<> -1 then premrep(npla, 180, trouv);
  if not trouv then
  begin
   dum:= frvop(npla, 144, false);
   if dum<> 279 then
   begin
    trouv:= false;
    for cx:= 0 to 8 do
     if s.mlieu= int(peek(dpadr(0)+ ((s.nbdh- dhd)* 9)+ cx)) then trouv:= true;
    if not trouv then
    begin
     cache:= true;
     suri(hazard(64, 65));
     decomp(0, atrava, amasq, 0, 0, aecra1);
     styleff(true, 5, 0, 265, 180, 315, 195);
    end
    else dum:= 279;
   end;
   message(3, 2, dum, true);
  end;
 end;
end;

procedure tsdeposer;
var
 cx, nu, tot, nbr, nval, jum, lieu: integer;
 dep, dep2, long: long_integer;
 trouv, ind, ok: boolean;
begin
(* debug('sdeposer'); *)
 if s.dobj<> -1 then
 begin
  lieu:= pred(s.mlieu);
  ind:= false;
  deplonb(lieu, dpadr(192), tot, nbr);
  nu:= 0;
  trouv:= false;
  if nbr> 0 then
   repeat
    if s.dobj= int(peek(dpadr(195)+ tot+ nu)) then trouv:= true
     else nu:= succ(nu);
   until (nu> pred(nbr)) or (trouv);
  if trouv then
  begin
   cx:= int(peek(dpadr(194)+ tot+ nu));
   if (cx<> 255) and (cx<> 254) then
   begin
    jum:= jumeaux(lieu, int(peek(dpadr(193)+ tot+ nu)));
    nval:= posval(lieu, jum);
    if nval<> -1 then
     if s.oval[nval] then tvalid(pred(s.mlieu), 425, jum);
    deplonw((tot+ nu), dpadr(306), dep, long);
    if long<> 0 then
    begin
     deplonw(tot, dpadr(306), dep2, long);
     hidemouse;
     decomp(0, atrava, (adespr+ dep- dep2), 0, 0, aecra1);
     moveblok(aecra1, aecra2, 4, 12, 259, 174);
     kpart(13, s.mlieu, s.dobj, -1, ok);
     showmouse;
     message(3, 2, 218, true);
     s.dobj:= -1;
     tot:= tot+ nu;
     s.etaob[tot]:= 0;
     deplonw(tot, dpadr(308), dep, long);
     if long<> 0 then
     begin
      pokel((aoblo+ (nu* 4)), (adeslo+ dep- rdepl));
      deplonw(tot, dpadr(309), dep, long);
      pokew((axoblo+ (nu* 2)), long);
      deplonw(tot, dpadr(310), dep, long);
      pokew((ayoblo+ (nu* 2)), long);
     end;
    end
    else ind:= true;
   end
   else ind:= true;
  end
  else ind:= true;
  if ind then
  begin
   trouv:= false;
   cx:= 0;
   repeat
    if s.chli[lieu, cx]= -1 then trouv:= true else cx:= succ(cx);
   until (cx> nbobj) or (trouv);
   if trouv then
   begin
    confiance(-1);
    s.chli[lieu, cx]:= s.dobj;
    s.dobj:= -1;
    message(3, 2, 218, true);
    decomp(0, atrava, anoeud, 0, 0, aecra1);
    styleff(true, 5, -1, 264, 180, 315, 195);
   end
   else message(3, 2, 316, true);
  end;
 end
 else message(3, 2, 320, true);
 afmenu0(0);
end;

procedure tsfouiller;
var
 trouv: boolean;
begin
(* debug('sfouiller'); *)
 if s.dobj<> -1 then
 begin
  hidemouse;
  presobj(441, false, trouv);
  afobj(s.dobj, 2);
  showmouse;
  atclick(true);
  prespend;
 end
 else message(3, 2, 320, true);
end;

procedure tslire;
var
 trouv: boolean;
 dum: long_integer;
begin
(* debug('slire'); *)
 if s.dobj<> -1 then
 begin
  slire(s.dobj, false, trouv);
  if trouv then
  begin
   hidemouse;
   if (s.mlieu= 9) or (s.mlieu= 10) then
    afdes(pred(s.mlieu), 0, 0, 0, false, true, true)
   else
    afdes(pred(s.mlieu), 0, 0, 0, false, false, true);
   afmenu0(0);
   showmouse;
  end;
 end
 else message(3, 2, 320, true);
end;

procedure tsprendre;
var
 dum: integer;
begin
 dum:= s.dobj;
 s.dobj:= s.objet[pred(comenu)];
 pokew(adobj, int(peek(dpadr(198)+ s.dobj)));
 if dum<> -1 then s.objet[pred(comenu)]:= dum else
 begin
  for dum:= comenu to nbobj do s.objet[pred(dum)]:= s.objet[dum];
  s.objet[nbobj]:= -1;
 end;
 afmenu0(0);
 message(3, 2, 4, true);
end;

procedure initialisation;
var
 cx, cy: integer;
begin
(* debug('initialisation'); *)
 for cx:= 0 to nbobj do
  pokew((aobjet+ (cx* 2)), int(peek(dpadr(198)+ s.objet[cx])));
 pokew(adobj, int(peek(dpadr(198)+ s.dobj)));
 memper:= -1;
 mempper:= -1;
 mjou:= -1;
 rmin:= 0;
 pokew(aheure, 0);
 menu_pers(0, false);
 energie(0, 0, true, false);
 idem:= false;
 ptourn:= false;
 cache:= false;
 assom:= false;
 glauque:= false;
 mdem:= false;
 mmx:= 0;
 mmy:= 0;
 mtemenu:= 0;
 mcomenu:= 0;
 for cx:= 0 to nevan do evan[cx]:= false;
 efn:= -1;
end;

(* NIVEAU 3 *)
procedure tsitu;
const
 yaff= 12;
 haut= 9;      (* hauteur entre deux lignes *)
 npmaxt= 1;    (* nbre de phrases non select *)
 longt= 168;   (* longueur du texte non selectable *)
 depyt= 80;
 depxt= 45;
 npmaxs= -1;   (* nbre de phrases selectables *)
var
 hxs, hys, nps: thxys;
 hxt, hyt, npt: thxyt;
 per, saxg, saxd, lgm, col, bsta, cx, choix: integer;
 meheu, dum, dep, long: long_integer;
 trouv: boolean;
begin
 col:= 0;
 if temenu= 1 then taller else
  if temenu= 0 then
  begin
   if comenu= 10 then
   begin
    meheu:= peekw(aheure);
    for cx:= 0 to npmaxt do
    begin
     hyt[cx]:= depyt+ (haut* (cx* 2));
     hxt[cx]:= depxt;
    end;
    npt[0]:= 43;
    npt[1]:= 44;
    boitdial(0, npmaxs, 0, npmaxt, longt,
             false, true, s.pmaj, (depxt+ (longt div 2)- 5), (hyt[0]+ haut),
             hxs, hys, nps, hxt, hyt, npt, choix);
    pokew(aheure, meheu);
   end
   else
    if not qdedans then
    begin
     per:= pred(comenu);
     if s.mlieu= int(peek(dpadr(0)+ ((s.nbdh- dhd)* 9)+ per)) then
     begin
      vblsync(11);
      dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
      saxg:= int(peekw(dpadr(265)));
      afmenu(-1, 0, 0, saxg, 0, 1, (dpadr(266)+ (per* 2)), 0, 0);
      lgm:= int(peek(dpadr(258)+ 9));
      saxd:= saxg+ lgm;
      dum:= savmem(0, aecra1, atrava, saxg, yaff, saxd, (yaff+ 24));
      afmenu(-1, 0, 0, saxg, yaff, 2, (dpadr(264)), 0, 0);
      bsta:= 0;
      meheu:= peekw(aheure);
      repeat
       e_mouse(mx, my, bsta);
      until bsta<> 0;
      pokew(aheure, meheu);
      trouv:= false;
      cx:= 0;
      repeat
       if (mx>= saxg) and (mx<= saxd) and
          (my>= (yaff+ (cx* 12))) and (my<= (yaff+ (succ(cx)* 12)))
       then trouv:= true else cx:= succ(cx);
      until (cx> 1) or (trouv);
      if not trouv then afmenu0(0);
      dum:= savmem(1, atrava, 0, saxg, yaff, saxd, (yaff+ 24));
      if cx= 0 then tparler(per, 0) else
       if cx= 1 then tsuivre(per, col);
     end;
    end;
  end
  else
   if temenu= 2 then tsprendre else
    if temenu= 3 then
    begin
     if comenu= 1  then tappuyer;
     if comenu= 2  then tattendre;
     if comenu= 3  then tdormir;
     if comenu= 4  then tfermer;
     if comenu= 5  then tfouiller;
     if comenu= 6  then tlire;
     if comenu= 7  then tmanger;
     if comenu= 8  then tmettre;
     if comenu= 9  then tobserver;
     if comenu= 10 then touvrir;
     if comenu= 11 then tprendre;
     if comenu= 12 then tregarder;
     if comenu= 13 then tsentir;
     if comenu= 14 then tsonder;
     if comenu= 15 then tsoulever;
     if comenu= 16 then ttourner;
    end
    else
     if temenu= 4 then
     begin
      if comenu= 1 then tscacher;
      if comenu= 2 then tsdeposer;
      if comenu= 3 then tsfouiller;
      if comenu= 4 then tslire;
     end;
 if not glauque then
 begin
  if (qdedans) and (not cache) then tparler(-1, 0);
  if col<> 0 then tparler(per, col);
 end;
 if assom then
 begin
  hidemouse;
  assom:= false;
  glauque:= false;
  cache:= false;
  preglauque;
  styleff(true, 5, -1, 264, 108, 315, 195);
  dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
  meheu:= peekw(aheure);
  aprio(hazard(48, 51));
  temprio;
  domort(0, amempa);
  remap;
  eftext(6, cperd, false, true, 245, 10, 50, 8, 15, aecra1);
  styleff(false, 4, -1, 0, 0, 319, 199);
  present(true);
  if typerd= 3 then s.mlieu:= int(peek(dpadr(13)+ pred(s.mlieu)));
  afdes(pred(s.mlieu), 0, 0, -1, false, true, true);
  depmouse(-4);
  showmouse;
  atclick(false);
  hidemouse;
  styleff(false, 1, 0, 0, 0, 319, 199);
  s.nbdh:= succ(s.nbdh);
  energie(-(s.ener div 4), 0, true, false);
  mjou:= -1;
  pokew(aheure, meheu);
  tinke(true, true, true, false, true, false, false, true, true, 0);
  domort(1, amempa);
  posmouse(131, 85, 0, 0, 304, 198);
  nusou:= 3;
  chngmouse(3, 5);
  pamb;
  damb(s.nbdh);
  initani;
  showmouse;
 end;
 nusou:= 3;
 chngmouse(3, 5);
 for cx:= 0 to nbobj do
  pokew((aobjet+ (cx* 2)), int(peek(dpadr(198)+ s.objet[cx])));
 pokew(adobj, int(peek(dpadr(198)+ s.dobj)));
end;

procedure sauvegarde;
var
 meheu: long_integer;
begin
 meheu:= peekw(aheure);
 sauve(asauv, lsauv);
 pokew(aheure, meheu);
end;

(* NIVEAU 2 *)
procedure tecran;
const
 yaff= 12;
var
 bsta, cx, cy, cxpg, cxpd: integer;
 cypg, cypd: array[1..10] of integer;
 coox, colg, saxg, saxd: array[1..5] of integer;
 mdum, dum, com, xg, xd, yd, meheu: long_integer;
 aitem, nbi, lgm: array[1..5] of long_integer;
 deja, menu, stop: boolean;
begin
 deja:= false;
 stop:= false;
 mdum:= 0;
 meheu:= 0;
 temenu:= 0;
 comenu:= 0;
 nbi[1]:= s.ndep[pred(s.mlieu)];
 nbi[2]:= 0;
 for cx:= 0 to nbobj do
  if s.objet[cx]<> -1 then nbi[2]:= succ(nbi[2]);
 nbi[3]:= 16;
 nbi[4]:= 4;
 nbi[5]:= 1;
 for cx:= 1 to 5 do
 begin
  coox[cx]:= int(peekw(dpadr(243)+ (pred(cx)* 4)));
  colg[cx]:= (int(peekw(dpadr(243)+ (pred(cx)* 4)+ 2)))+ coox[cx];
  saxg[cx]:= coox[cx];
  lgm[cx]:= peek(dpadr(258)+ pred(cx));
  saxd[cx]:= saxg[cx]+ int(lgm[cx]);
 end;
 saxg[3]:= saxg[3]- 50;
 saxd[3]:= saxd[3]+ 50;
 saxg[5]:= saxg[5]- 20;
 saxd[5]:= saxd[5]- 20;
 aitem[1]:= dpadr(6)+ (pred(s.mlieu)* 12);
 aitem[2]:= aobjet;
 aitem[3]:= dpadr(249);
 aitem[4]:= dpadr(250);
 aitem[5]:= dpadr(251);
 cxpg:= int(peekw(dpadr(247)));
 cxpd:= cxpg+ int(peekw(dpadr(247)+ 4));
 for cx:= 1 to 9 do
 begin
  cypg[cx]:= int(peekw(dpadr(247)+ 2))+ (pred(cx)* 8);
  cypd[cx]:= cypg[cx]+ 8;
 end;
 cypg[10]:= int(peekw(dpadr(247)+ 8));
 cypd[10]:= cypg[10]+ 10;
 repeat
  if (temenu<> 4) and (temenu<> 5) then
  begin
   if meheu<> 0 then
   begin
    pokew(aheure, meheu);
    meheu:= 0;
   end;
   tinke(false, true, true, true, true, true, true, true, false, mdum);
  end;
  if not glauque then
  begin
   e_mouse(mx, my, bsta);
   if my< 12 then
   begin
    if not deja then
    begin
     afmenu1(0);
     deja:= true;
    end;
    menu:= false;
    cx:= 1;
    repeat
     if (mx> coox[cx]) and (mx< colg[cx]) then menu:= true
     else cx:= succ(cx);
    until (menu) or (cx> 5);
    if menu then
    begin
     if (temenu<> 0) and (temenu<> cx) then
      dum:= savmem(1, atrava, 0, xg, yaff, xd, yd);
     if temenu<> cx then
     begin
      temenu:= cx;
      if (temenu= 4) or (temenu= 5) then
      begin
       if meheu<> 0 then pokew(aheure, meheu);
       meheu:= peekw(aheure);
      end;
      xg:= saxg[cx];
      xd:= saxd[cx];
      if cx= 3 then yd:= ((nbi[cx] div 2) * 12)+ yaff else
       yd:= (nbi[cx]* 12)+ yaff;
      if cx= 2 then yd:= yd+ 12;
      mdum:= savmem(0, aecra1, atrava, xg, yaff, xd, yd);
      com:= saxg[cx];
      if cx= 2 then
      begin
       afmenu(0, 0, 0, com, yaff, nbi[cx], aitem[cx], 0, 0);
       if s.dobj<> -1 then afmenu(0, 15, 0, com, (yd- 12), 1, adobj, 0, 0);
      end
      else
       if cx= 3 then
        afmenu(-1, 0, 8, (com+ 78), yaff, nbi[cx], aitem[cx], 0, 0)
       else afmenu(-1, 0, 0, com, yaff, nbi[cx], aitem[cx], 0, 0);
     end;
    end;
   end;
   if bsta<> 0 then
    if bsta= 2 then
    begin
     if (mtemenu> 1) and (mtemenu< 5) then
     begin
      if temenu<> 0 then
       mdum:= savmem(1, atrava, 0, xg, yaff, xd, yd);
      idem:= true;
      comenu:= mcomenu;
      temenu:= mtemenu;
      afmenu0(0);
      if meheu<> 0 then
      begin
       pokew(aheure, meheu);
       meheu:= 0;
      end;
     end;
    end
    else
    begin
     idem:= false;
     if temenu<> 0 then
     begin
      cy:= int(nbi[temenu]);
      if temenu= 3 then cy:= cy div 2;
      cx:= 1;
      repeat
       if (my>= (yaff+ (pred(cx)* 12)))
        and (my<= (yaff+ (pred(cx)* 12)+ 12))
        and (mx> xg) and (mx< xd) then comenu:= cx;
       cx:= succ(cx);
      until (cx> cy) or (comenu<> 0);
      if temenu= 5 then
      begin
       afmenu0(0);
       dum:= savmem(1, atrava, 0, xg, yaff, xd, yd);
       if comenu= 1 then sauvegarde;
       comenu:= 99;
       temenu:= 0;
      end
      else dum:= savmem(1, atrava, 0, xg, yaff, xd, yd);
     end;
     if comenu= 0 then
     begin
      xg:= 0;
      xd:= 0;
      yd:= 0;
      temenu:= 0;
      cx:= 1;
      repeat
       if (mx> cxpg) and (mx< cxpd) and
          (my>= cypg[cx]) and (my<= cypd[cx]) then comenu:= cx;
       cx:= succ(cx);
      until (comenu<> 0) or (cx> 10);
     end;
     if comenu= 99 then comenu:= 0;
     deja:= false;
     bsta:= 0;
     if (temenu= 3) and (mx> ((xg+ xd) div 2)) then comenu:= comenu+ 8;
     if temenu<> 2 then afmenu0(0);
     if meheu<> 0 then
     begin
      pokew(aheure, meheu);
      meheu:= 0;
     end;
    end;
  end;
 until (comenu<> 0) or (glauque) or ((qdedans) and (not cache));
 if not glauque then
 begin
  if (not qdedans) or (cache) then
  begin
   mcomenu:= comenu;
   mtemenu:= temenu;
  end
  else
   if temenu<> 0 then dum:= savmem(1, atrava, 0, xg, yaff, xd, yd);
 end
 else temenu:= -1;
 tsitu;
end;

(* NIVEAU 1 *)
procedure tjouer;
var
 dum, has: long_integer;
begin
 solu:= false;
 perdu:= false;
 debug('avant lecture asauve');
 lecture(atrava, asauv, 0, 6);
 debug('apres lecture asauve');
 initialisation;
 debug('apres initialisation');
 resetani;
 debug('apres resetani');
 afdes(pred(s.mlieu), 0, 0, -2, false, true, true);
 debug('apres afdes');
 calch;
 pendule(0, true, false);
 energie(0, 0, false, false);
 posmouse(131, 85, 0, 0, 304, 198);
 nusou:= 3;
 chngmouse(3, 5);
 pamb;
 efnoir;
 debug('apres effet noir');
 damb(s.nbdh);
 debug('apres damb');
 showmouse;
 debug('apres showmouse');
 initdemo;                             (* initialise mode demo *)
 debug('apres initdemo');
 dum:= charge(asauv, lsauv);
 if dum= 1 then
 begin
  hidemouse;
  efn:= 0;
  initialisation;
  afdes(pred(s.mlieu), 0, 0, -1, false, true, true);
  calch;
  pendule(0, true, true);
  energie(0, 0, false, false);
  posmouse(131, 85, 0, 0, 304, 198);
  nusou:= 3;
  chngmouse(3, 5);
  pamb;
  efnoir;
  damb(s.nbdh);
  showmouse;
 end
 else
 begin
  lecture(atrava, asauv, 0, 6);
  resetani;
 end;
 initani;
 repeat tecran until (solu) or (perdu);
 if perdu then
 begin
  hidemouse;
  dum:= savmem(1, abmenu0, 0, 0, 0, 319, 10);
  if typerd= 1 then
  begin
   has:= hazard(48, 52);
   if has= 52 then has:= 57;
   aprio(has);
   temprio;
   domort(0, amempa);
   clrblk(aecra2, 0, 0, 319, 199);
  end
  else
  begin
   aprio(54);
   temprio;
   styleff(false, 1, 0, 0, 0, 319, 199);
  end;
  preglauque;
  cadre;
  afdes(30, 0, 0, -1, false, true, false);
  eftext(6, cperd, false, true, 300, 10, 100, 8, 15, aecra1);
  pamb;
  movblk(aecra1, aecra2, 0, 0, 319, 199);
  styleff(false, 0, 0, 0, 0, 319, 199);
  atclick(false);
  styleff(false, 1, 0, 0, 0, 319, 199);
  coupson;
  present(true);
  perdu:= false;
 end;
end;

(* NIVEAU 0 *)
begin
(* if Init_Gem >= 0 then
 begin
hide_mouse; *)
loadass;     (*  abso  *)
(*text_height(4);
text_color(black); *)
  s.nbdh:= 9320;
  s.nbdm:= 30001;
  s.ener:= -31166;
  s.conf:= 4951;
  asauv:= adsauv;
(* loadfic; *)
(*  atrava:= memlib; *)
  aecra2:= adec;
  atexte:= memres;
  atexte:= atexte+ 1000;
  alongt:= atexte+ ltext1+ ltext2+ ltext3+ ltext4+ ltext5+ ltext6+ ltext7;
  adonne:= alongt+ llong1+ llong2+ llong3+ llong4+ llong5+ llong6+ llong7;
  amempa:= adonne+ ldonnee;
  aecra1:= amempa+ 32;
  asprit:= aecra1+ 32000;
  aloupe:= asprit+ lsprit;   (* amloupe doit etre derriere aloupe *)
  amloupe:= aloupe+ 340;
  anoeud:= amloupe+ 132;
  amasq:= anoeud+ 244;
  alettr:= amasq;
  asouris:= amasq+ 294;    (* aheure doit etre derriere asouris *)
(* souris: 1 mot bouton
           1 mot coord x
           1 mot coord y
           1 mot clavier
           1 mot joystick
           1 mot invalide
           4 mot de coord de clip
           1 mot bit 0 … 1 anim en cours autre anim fini bonhomme 0
                     1            "                 "             1 *)
  aheure:= asouris+ 22;       (* 22 qd bonhomme et toujours derriere souris *)
  aflag1:= aheure+ 4;         (* serie de flag fait suite a la souris *)
  aflag5:= aflag1+ 1;
  aflag10:= aflag5+ 1;
  aobjet:= aflag10+ 2;        (* adobj doit etre derriere aobjet *)
  adobj:= aobjet+ 10;
  aoblo:= adobj+ 2;
  axoblo:= aoblo+ 20;
  ayoblo:= axoblo+ 10;
  abmenu0:= ayoblo+ 10;
  adfixe:= abmenu0+ 1760;
  adtext:= adfixe+ ladfixe;
  adessi:= adtext+ 640;
  azmasq:= adessi+ 8500;
  atrava:= azmasq+ 8040;
  adesou:= atrava+ 22000;
(*aphrase:= adesou;
  aechant:= aphrase+ lphrase; *)
  aphrase:= atrava+ 31000;
  aechant:= aphrase+ lphrase+ 4;
(*  for jou:= 0 to 16 do pokew((adessi+ (jou* 2)), 0);
  styleff(false, 6, 0, 0, 0, 0, 0);
  clrblk(aecra2, 0, 0, 319, 199);  *)
  arret:= false;
  ficmem;
  premdes;
  debug('apres premdes');
  configsys;
  debug('apres configsys');
  repeat tjouer until arret;
(*  exit_gem;
 end; *)
end.
