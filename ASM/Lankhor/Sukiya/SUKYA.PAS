{$S60}
program sukyia;
const
(* dmin= 120;        nb minute/tmin pour 10 h du mat comme debut *)
 mmini= 520000; (* memoire mini *)
 lsauv= 8744;   (* longueur du fichier sauvegarde *)
 tmin= 5;       (* nb minute de jeu= 1 minute de temps reel *)
 nbdep= 029;    (* 0..nbdep: nb de deplacements differents possibles *)
 nbver= 011;    (* 0..nbver: nb de verbes actifs (sans deposer, choix) *)
 nbcha= 039;    (* 0..nbcha: 254 nbre de chaine d'objet maxi *)
 nbobj= 004;    (* 0..nbobj: nbre d'objets maxi sur soi *)
 maxob= 099;    (* 0..maxob: 254 nbre maxi d'objets prenables dans le jeu *)
 npers= 019;    (* 0..npers: 19 nbre maxi de personage dans un lieu *)
 nvalo= 003;    (* 0..nvalo: 019 nbre maxi de zones a valider sur un objet *)
 nlieu= 032;    (* 0..nlieu: 039 nbre maxi de lieux accessibles *)
 nvali= 049;    (* 0..nvali: 150 nbre maxi de zones a valider ds un lieu *)
 nindi= 099;    (* 0..nindi: nbre maxi d'indice *)
 nanim= 007;    (* 0..nanim: nbre animations maxi differentes par lieu *)
 obnul= -32767; (* objet dans aucune chaine *)
 dchob= 1000;   (* debut des chaines d'objet *)

 kf1= $3B;
 kf2= $3C;
 kf3= $3D;
 kf4= $3E;

 kup= $48;
 kdo= $50;
 kle= $4B;
 kri= $4D;

 kou= $18;
 kno= $31;

 kpg= $63;
 kpd= $64;
 ksl= $65;
 kas= $66;
 kn7= $67;
 kn8= $68;
 kn9= $69;
 kmo= $4A;
 kn4= $6A;
 kn5= $6B;
 kn6= $6C;
 kpl= $4E;
 kn1= $6D;
 kn2= $6E;
 kn3= $6F;
 ken= $72;

 khe= $62;

 vfor= 0;
 vvol= 1;
 vcon= 2;
 vsan= 3;

 wambian= 00;
 wdepdes= 01;
 wdesval= 02;
 wdecdes= 03;
 wnumdes= 04;
 wnloupe= 05;
 wdloupe= 06;
 wnbrect= 07;
 wdecoup= 08;
 winitia= 09;
 wtempm= 10;    (* boucle temps *)
 wtempd= 11;
 wtempo= 12;
 wadpal= 13;
 wremob= 14;    (* remap objet dans le lieu *)
 wremas= 15;    (* remap lieu assom *)
 wobsem= 16;    (* observer *)
 wobsed= 17;
 wobseo= 18;
 wblieu= 19;    (* boucle generale *)
 wdepla= 20;
 wverbe= 50;    (* wdepla+ 30 *)
 wchecr= 86;    (* wverbe+ (succ(nbver))* 3 *)

 gnomob= 000;
 gpdobj= 001;
 gvlobj= 002;
 gpdcha= 003;
 gvlcha= 004;
 gmesve= 005;
 gmesob= 006;
 gnbrob= 007;
 gdecob= 008;
 gobjet= 207; (* 517; *)    (* gnbrob+ (succ(maxob)* 2) *)
 gtouch= 234; (* 544; *)    (* gobjet+ (9* 3) *)
 gtemge= 534; (* 1309; *)   (* gtouch+ (succ(maxob)* 3) *)
 gtempm= 535; (* 1310; *)
 gtempd= 536; (* 1311; *)
 gtempo= 537; (* 1312; *)
 glectu= 538; (* 1313; *)
 glnute= 539; (* 1314; *)
 glcoul= 540; (* 1315; *)
 glinte= 541; (* 1316; *)
 glcara= 542; (* 1317; *)
 glcoox= 543; (* 1318; *)
 glcooy= 544; (* 1319; *)
 gllarg= 545; (* 1320; *)
 glhaut= 546; (* 1321; *)

 csipaer= 00;
 csier=   01;
 cafmess= 02;
 cdplace= 03;
 cmort=   04;
 cassom=  05;
 caugtps= 06;
 cparler= 07;
 cvalzon= 08;
 cdvalzo= 09;
 ctvalzo= 10;
 caffval= 11;
 cajobj=  12;
 cretobj= 13;
 ctesapp= 14;
 cteslie= 15;
 cvaldep= 16;
 cdvldep= 17;
 ctesdep= 18;
 calerte= 19;
 ccomadd= 20;
 ccomsub= 21;
 ccomset= 22;
 ccomequ= 23;
 ccomsup= 24;
 ccominf= 25;
 cfouill= 26;
 cindice= 27;
 clectur= 28;
 csetpal= 29;
 ctespal= 30;
 cprendr= 31;
 cmainjo= 32;
 capptjo= 33;
 cvalcac= 34;
 ctescac= 35;
 cvloupe= 36;
 codispa= 37;
 covalob= 38;
 codvlob= 39;
 cotvlob= 40;
 cmettre= 41;
 cnbobjl= 42;
 canient= 43;
 canisor= 44;
 caniexe= 45;
 canifon= 46;
 cfinjeu= 47;
 cdifvar= 48;
 ctemps=  49;
 chasard= 50;
 cchanob= 51;
 csurimp= 52;
 cbruita= 53;
 cstopan= 54;
 ctseul=  55;
 cvalper= 56;
 cdvlper= 57;

 tobse= 0;
 tgene= 1;
 tlire= 2;
 tobje= 3;
 tnomo= 5;
 tamoi= 6;
 tlieu= 7;

(* nact01= 'E:\SECTE.ESS\ACT01.SEC';*)  (* regarder *)
(* nact02= 'E:\SECTE.ESS\ACT02.SEC';*)  (* prendre *)
(* nact03= 'E:\SECTE.ESS\ACT03.SEC';*)  (* poser *)
(* nact04= 'E:\SECTE.ESS\ACT04.SEC';*)  (* soulever *)
(* nact05= 'E:\SECTE.ESS\ACT05.SEC';*)  (* appuyer *)
(* nact06= 'E:\SECTE.ESS\ACT06.SEC';*)  (* casser *)
(* nact07= 'E:\SECTE.ESS\ACT07.SEC';*)  (* ouvrir *)
(* nact08= 'E:\SECTE.ESS\ACT08.SEC';*)  (* fermer *)
(* nact09= 'E:\SECTE.ESS\ACT09.SEC';*)  (* tourner *)
(* nact10= 'E:\SECTE.ESS\ACT10.SEC';*)  (* parler *)
(* nact11= 'E:\SECTE.ESS\ACT11.SEC';*)  (* donner *)
(* nact12= 'E:\SECTE.ESS\ACT12.SEC';*)  (* utiliser *)
(* nact13= 'E:\SECTE.ESS\ACT13.SEC';*)  (* fouiller *)
(* nact14= 'E:\SECTE.ESS\ACT14.SEC';*)  (* tirer *)
(* nact15= 'E:\SECTE.ESS\ACT15.SEC';*)  (* mettre *)
(* nact16= 'E:\SECTE.ESS\ACT16.SEC';*)  (* se cacher *)
(* nact17= 'E:\SECTE.ESS\ACT17.SEC';*)  (* choix action general *)

(* ndep01= 'E:\SECTE.ESS\DEPL01.SEC';*) (* nord *)
(* ndep02= 'E:\SECTE.ESS\DEPL02.SEC';*) (* est *)
(* ndep03= 'E:\SECTE.ESS\DEPL03.SEC';*) (* sud *)
(* ndep04= 'E:\SECTE.ESS\DEPL04.SEC';*) (* ouest *)
(* ndep05= 'E:\SECTE.ESS\DEPL05.SEC';*) (* montee *)
(* ndep06= 'E:\SECTE.ESS\DEPL06.SEC';*) (* descente *)
(* ndep07= 'E:\SECTE.ESS\DEPL07.SEC';*) (* entree *)
(* ndep08= 'E:\SECTE.ESS\DEPL08.SEC';*) (* sortie *)
(* ndep09= 'E:\SECTE.ESS\DEPL09.SEC';*) (* ecran *)
(* ndep10= 'E:\SECTE.ESS\DEPL10.SEC';*) (* anim nord *)
(* ndep11= 'E:\SECTE.ESS\DEPL11.SEC';*) (*      est *)
(* ndep12= 'E:\SECTE.ESS\DEPL12.SEC';*) (*      sud *)
(* ndep13= 'E:\SECTE.ESS\DEPL13.SEC';*) (*      ouest *)
(* ndep14= 'E:\SECTE.ESS\DEPL14.SEC';*) (*      montee *)
(* ndep15= 'E:\SECTE.ESS\DEPL15.SEC';*) (*      descente *)
(* ndep16= 'E:\SECTE.ESS\DEPL16.SEC';*) (*      entree *)
(* ndep17= 'E:\SECTE.ESS\DEPL17.SEC';*) (*      sortie *)
(* ndep18= 'E:\SECTE.ESS\DEPL18.SEC';*) (*      ecran *)
(* ndep19= 'E:\SECTE.ESS\DEPL19.SEC';*) (* fond nord *)
(* ndep20= 'E:\SECTE.ESS\DEPL20.SEC';*) (*      est *)
(* ndep21= 'E:\SECTE.ESS\DEPL21.SEC';*) (*      sud *)
(* ndep22= 'E:\SECTE.ESS\DEPL22.SEC';*) (*      ouest *)
(* ndep23= 'E:\SECTE.ESS\DEPL23.SEC';*) (*      montee *)
(* ndep24= 'E:\SECTE.ESS\DEPL24.SEC';*) (*      descente *)
(* ndep25= 'E:\SECTE.ESS\DEPL25.SEC';*) (*      entree *)
(* ndep26= 'E:\SECTE.ESS\DEPL26.SEC';*) (*      sortie *)
(* ndep27= 'E:\SECTE.ESS\DEPL27.SEC';*) (*      ecran *)
(* ndep28= 'E:\SECTE.ESS\DEPL28.SEC';*) (* support fleche *)
(* ndep29= 'E:\SECTE.ESS\DEPL29.SEC';*) (*         montee *)
(* ndep30= 'E:\SECTE.ESS\DEPL30.SEC';*) (*         entree *)
(* ndep31= 'E:\SECTE.ESS\DEPL31.SEC';*) (*         ecran *)

(* ngen01= 'E:\SECTE.ESS\ERG01.SUK';*)  (* barre menu *)
(* ngen02= 'E:\SECTE.ESS\ERG02.SUK';*)  (* tour vide *)
(* ngen03= 'E:\SECTE.ESS\ERG03.SUK';*)  (* tour normal *)
(* ngen04= 'E:\SECTE.ESS\ERG04.SUK';*)  (* pour objet normal *)
(* ngen05= 'E:\SECTE.ESS\ERG05.SUK';*)  (* bamboo texte *)
(* ngen06= 'E:\SECTE.ESS\ERG06.SUK';*)  (* tour pour un objet *)
(* ngen07= 'E:\SECTE.ESS\ERG07.SUK';*) 
(* ngen08= 'E:\SECTE.ESS\ERG08.SUK';*)  (* cool...etc *)
(* ngen09= 'E:\SECTE.ESS\ERG09.SUK';*)  (* haut pendule AM/PM *)
(* ngen10= 'E:\SECTE.ESS\ERG10.SUK';*)  (* haut pendule JOUR *)
(* ngen11= 'E:\SECTE.ESS\ERG11.SUK';*)  (* pendule *)
(* ngen12= 'E:\SECTE.ESS\ERG12.SUK';*)  (* plan pour deplacement *)
(* ngen13= 'E:\SECTE.ESS\GEN13.SEC';*)  (* sauvegarde *)
(* ngen14= 'E:\SECTE.ESS\';*)  (*  *)
(* ngen15= 'E:\SECTE.ESS\GEN15.SEC';*)  (* bouee loin *)
(* ngen16= 'E:\SECTE.ESS\GEN16.SEC';*)  (* bouee tenue *)
(* ngen17= 'E:\SECTE.ESS\GEN17.SEC';*)  (* menu general: action *)
(* ngen18= 'E:\SECTE.ESS\GEN18.SEC';*)  (* black sect *)
(* ngen19= 'E:\SECTE.ESS\GEN19.SEC';*)  (* sans objet 2 *)
(* ngen20= 'E:\SECTE.ESS\GEN20.SEC';*)  (* joueur cache *)
(* ngen21= 'E:\SECTE.ESS\GEN21.SEC';*)  (* cache jour *)
(* ngen22= 'E:\SECTE.ESS\GEN22.SEC';*)  (* cache PM/AM *)
(* ngen23= 'E:\SECTE.ESS\GEN23.SEC';*)  (* menu objet: horizontal *)
(* ngen24= 'E:\SECTE.ESS\GEN24.SEC';*)  (* menu objet: suite *)
(* ngen25= 'E:\SECTE.ESS\GEN25.SEC';*)  (* menu objet: stop *)
(* ngen26= 'E:\SECTE.ESS\GEN26.SEC';*)  (* petit menu action *)
(* ngen27= 'E:\SECTE.ESS\GEN27.SEC';*)  (* petit menu action: bouton *)
(* ngen28= 'E:\SECTE.ESS\GEN28.SEC';*)  (* petit menu action: bouton select *)
(* ngen29= 'E:\SECTE.ESS\GEN29.SEC';*)  (* menu lire: horizontal *)
(* ngen30= 'E:\SECTE.ESS\GEN30.SEC';*)  (* menu lire: pr‚c‚dent *)
(* ngen31= 'E:\SECTE.ESS\GEN31.SEC';*)  (* menu lire: suivant *)
(* ngen32= 'E:\SECTE.ESS\GEN32.SEC';*)  (* menu lire: stop *)
(* ngen33= 'E:\SECTE.ESS\GEN33.SEC';*)  (* deplacement: peu de memoire *)
(* ngen34= 'E:\SECTE.ESS\GEN34.SEC';*)  (* inventaire: peu de memoire *)
(* ngen35= 'E:\SECTE.ESS\GEN35.SEC';*)  (* sauvegarde: peu de memoire *)
(* ngen36= 'E:\SECTE.ESS\GEN36.SEC';*)  (* objet suiv: peu de memoire *)
(* ngen37= 'E:\SECTE.ESS\GEN37.SEC';*)  (* objet stop: peu de memoire *)

(* ninv01= 'E:\SECTE.ESS\INV01.SEC';*)  (* presentation inventaire *)
(* ninv02= 'E:\SECTE.ESS\INV02.SEC';*)  (* inventaire objet absent *)
(* ninv03= 'E:\SECTE.ESS\INV03.SEC';*)  (* inventaire objet present *)

(* nsav00= 'E:\SECTE.ESS\SAV00.SEC';*)  (* presentation sauvegarde *)
(* nsav01= 'E:\SECTE.ESS\SAV01.SEC';*)  (* sauvegarde 1 *)
(* nsav02= 'E:\SECTE.ESS\SAV02.SEC';*)  (* sauvegarde 2 *)
(* nsav03= 'E:\SECTE.ESS\SAV03.SEC';*)  (* sauvegarde 3 *)
(* nsav04= 'E:\SECTE.ESS\SAV04.SEC';*)  (* sauvegarde 4 *)
(* nsav05= 'E:\SECTE.ESS\SAV05.SEC';*)  (* sauvegarde 5 *)
(* nsav06= 'E:\SECTE.ESS\SAV06.SEC';*)  (* charger *)
(* nsav07= 'E:\SECTE.ESS\SAV07.SEC';*)  (* charger anim *)
(* nsav08= 'E:\SECTE.ESS\SAV08.SEC';*)  (* sauver *)
(* nsav09= 'E:\SECTE.ESS\SAV09.SEC';*)  (* sauver anim *)

(* naob00= 'E:\SECTE.ESS\AOB00.SEC';*)  (* choix action general objet *)
(* naob01= 'E:\SECTE.ESS\AOB01.SEC';*)  (* voir *)
(* naob02= 'E:\SECTE.ESS\AOB02.SEC';*)  (* prendre *)
(* naob03= 'E:\SECTE.ESS\AOB03.SEC';*)  (* fouiller *)
(* naob04= 'E:\SECTE.ESS\AOB04.SEC';*)  (* lire *)
(* naob05= 'E:\SECTE.ESS\AOB05.SEC';*)  (* utiliser *)
(* naob06= 'E:\SECTE.ESS\AOB06.SEC';*)  (* sentir *)
(* naob07= 'E:\SECTE.ESS\AOB07.SEC';*)  (* toucher *)
(* naob08= 'E:\SECTE.ESS\AOB08.SEC';*)  (* poser *)
(* naob09= 'E:\SECTE.ESS\AOB09.SEC';*)  (* poser initial *)

(* nmas01= 'E:\SECTE.ESS\ACT_M.MSK';*)  (* masque: grosse action gene *)
(* nmas02= 'E:\SECTE.ESS\FIC_M.MSK';*)  (* masque: sauvegarde *)
(* nmas03= 'E:\SECTE.ESS\LOUPE_M.MSK';*)(* masque: loupe *)
(* nmas04= 'E:\SECTE.ESS\OBJ_M.MSK';*)  (* masque: action objet *)
(* nmas05= 'E:\SECTE.ESS\ACT2P_M.MSK';*)(* masque: petite action gene *)
(* nmas06= 'E:\SECTE.ESS\INV_M.MSK';*)  (* masque: inventaire *)
(* nmas07= 'E:\SECTE.ESS\DEP1_M.MSK';*) (* masque: deplacement NSEO *)
(* nmas08= 'E:\SECTE.ESS\DEP2_M.MSK';*) (* masque: deplacement ES *)
(* nmas09= 'E:\SECTE.ESS\DEP3_M.MSK';*) (* masque: deplacement MD *)
(* nmas10= 'E:\SECTE.ESS\DEP4_M.MSK';*) (* masque: deplacement Choix *)
(* nmas11= 'E:\SECTE.ESS\PERSO_M.MSK';*)(* masque: tete perso *)

(* ndlieu= 'E:\SECTE.ESS\DES';*)
(* nlofpa= 'E:\SECTE.ESS\OFPA';*)
(* ntlieu= 'E:\SECTE.ESS\LIEU';*)
(* naidel= 'E:\SECTE.ESS\AIDE';*)

(* ntext0= 'E:\SECTE.ESS\TCOMP0.O';*)
(* nlong0= 'E:\SECTE.ESS\TLONG0.O';*)
(* ntext1= 'E:\SECTE.ESS\TCOMP1.O';*)
(* nlong1= 'E:\SECTE.ESS\TLONG1.O';*)
(* ntext2= 'E:\SECTE.ESS\TCOMP2.O';*)
(* nlong2= 'E:\SECTE.ESS\TLONG2.O';*)
(* ntext3= 'E:\SECTE.ESS\TCOMP3.O';*)
(* nlong3= 'E:\SECTE.ESS\TLONG3.O';*)
(* ntext4= 'E:\SECTE.ESS\TCOMP4.O';*)
(* nlong4= 'E:\SECTE.ESS\TLONG4.O';*)
(* ntext5= 'E:\SECTE.ESS\TCOMP5.O';*)
(* nlong5= 'E:\SECTE.ESS\TLONG5.O';*)
(* ntext6= 'E:\SECTE.ESS\TCOMP6.O';*)
(* nlong6= 'E:\SECTE.ESS\TLONG6.O';*)
(* ntext7= 'E:\SECTE.ESS\TCOMP7.O';*)
(* nlong7= 'E:\SECTE.ESS\TLONG7.O';*)

(* ndgene= 'E:\SECTE.ESS\GENE.O';*)
(* nsauve= 'E:\SECTE.ESS\SAUVE.O';*)

 lsgen12= 6000;  (*5760*)

 lsprit= 10000; (* nbre de souris* 160 *)

type
 str255= string[255];
 path_chars= packed array [1..80] of char;
 sa= record
      (* dernier passage pour general, temps(x 3), lieu, pourcentage *)
      posmg, nmin, rsec, mmin, mlieu, pourc: integer;
      (* indic cache *)
      cach: boolean;
      (* compteur du joueur *)
      cmpt: array[0..51] of integer;
      (* indice *)
      indi: array[0..nindi] of integer;
      (* chaine de l'objet *)
      objet: array[0..maxob] of integer;
      (* valide / devalide sur objet *)
      valob: array[0..maxob] of array[0..nvalo] of integer;
      (* valide / devalide deplacement *)
      depla: array[0..nlieu] of array[0..nbdep] of boolean;
      (* valide / devalide sur zone *)
      valid: array[0..nlieu] of array[0..nvali] of integer;
      (* numero de la palette en cours dans un lieu *) 
      palet: array[0..nlieu] of integer;
      (* dernier passage dans un lieu *)
      posml: array[0..nlieu] of integer;
      (* dernier passage pour observer *)
      posob: array[0..nlieu] of integer;
      (* animation *)
      anim: array[0..nlieu] of array[0..nanim] of integer;
      (* validation de fond sur le lieu en cours *) 
      valfon: array[0..nvali] of integer;
      (* tableau des personnages *)
      perso: array[0..nlieu] of array[0..npers] of integer;
     end;
 fsauv= sa;

var
 aact01,aact02,aact03,aact04,aact05,aact06,aact07,aact08: long_integer;
 aact09,aact10,aact11,aact12,aact13,aact14,aact15,aact16: long_integer;
 aact17: long_integer;
 adep01,adep02,adep03,adep04,adep05,adep06,adep07,adep08: long_integer;
 adep09,adep10,adep11,adep12,adep13,adep14,adep15,adep16: long_integer;
 adep17,adep18,adep19,adep20,adep21,adep22,adep23,adep24: long_integer;
 adep25,adep26,adep27,adep28,adep29,adep30,adep31: long_integer;
 agen01,agen02,agen03,agen04,agen05,agen06,agen07,agen08: long_integer;
 agen09,agen10,agen11,agen12,agen13,agen14,agen15,agen16: long_integer;
 agen17,agen18,agen19,agen20,agen21,agen22,agen23,agen24: long_integer;
 agen25,agen26,agen27,agen28,agen29,agen30,agen31,agen32: long_integer;
 agen33,agen34,agen35,agen36,agen37: long_integer;
 asgen12: long_integer;
 ainv01,ainv02,ainv03: long_integer;
 asav00,asav01,asav02,asav03,asav04,asav05,asav06,asav07: long_integer;
 asav08,asav09: long_integer;
 aaob00,aaob01,aaob02,aaob03,aaob04,aaob05,aaob06,aaob07: long_integer;
 aaob08,aaob09: long_integer;
 amas01,amas02,amas03,amas04,amas05,amas06,amas07,amas08: long_integer;
 amas09,amas10,amas11: long_integer;
 atext0,atext1,atext2,atext3,atext4,atext5,atext6,atext7: long_integer;
 along0,along1,along2,along3,along4,along5,along6,along7: long_integer;
 aecra1, aecra2, adessi, azmasq, adesou, atrava, adtext: long_integer;
 asprit, aloupe, amempa, arempe, adanst: long_integer;
 apal, asouris, aheure, aflag1, aflag5, aflag10, adgene: long_integer;
 adanpe, adlieu, aoufer,aoblo, axoblo, ayoblo, xysouris: long_integer;
 asauv, memoire, anumt, deptra: long_integer;

 atmoux, atmouy, atbsta, atkey: integer;
 omain,nzon, nzono, moux, mouy, mflex, mfley: integer;
 act, dep, obj, mmen, mact, mdep, mobj, mtem: integer;
 acto, mmeno, macto, nufic, mpourc, gobj2: integer;
 heu, jou, min, mmin, mjou, mheu: integer;
 objso: array[0..nbobj] of integer;

 cont, arret, solu, perdu, chgtab, imess, ifouil, etani: boolean;

(* pour menu *)
 pcx: array[0..15] of integer;
 pcy: array[0..15] of integer;
 plg, nbmen: integer;
 plarg: long_integer;

(* pour debug hide et showmouse *)
 ctrhi, ctrsh: integer;

(* pour sauvegarde *)
 s: sa;
 fs: fsauv;

                           (*********)

(* NIVEAU *)

(******************)

function f_close(handle: integer): integer;
 gemdos($3e);

function f_open(var name: path_chars; mode: integer): integer;
 gemdos($3d);

function f_seek(offset: long_integer; handle, mode: integer): integer;
 gemdos($42);

(******************)

function adec: long_integer; external;
(* recherche de l'adresse d'ecran *)

function adeplonb(decal, nu: long_integer): long_integer; external;

function adeplonw(decal, nu: long_integer): long_integer; external;

function adsauv: long_integer; external;
(* SAUVE: recherche de l'adresse de sauvegarde *)

function affiche(ecran, basedes, adepdes, adesval,
                 atrava, nbdes: long_integer): long_integer; external;

function afmen(coul, align, xaf, yaf, nbi, anum, mode,
               aecr, atext, along, adtext, alettr,
               asprit: long_integer): long_integer; external;
(* MENU: affichage *)

procedure afmark(aecra1, x, y, coul: long_integer); external;

function aftext(centr, atext, along, adec, aecran,
                x, y, lligne, haut, coul, just, str,
                num: long_integer): long_integer; external;

procedure aftitre(numtext, coultext, xaf, yaf, largeur, aecr, atext,
                  along, adtext, aplanche: long_integer); external;
(* MENU: affichage...  *)

procedure anihalt; external;
(* ANIM: stoppe les anims en ecran 2 avant affichage de l'ergonomie *)

procedure anishow; external;
(* ANIM: reactive les anims en ecran 2 apres affichage de l'ergonomie *)

procedure blocani(animation, sequence, mode: long_integer); external;
(* ANIM: change etat animation d'un personnage *)

procedure bruiergo(morceau, volume: long_integer); external;
(* SON-ST: bruit en ergonomie *)

procedure brui(dat1: long_integer); external;
(* SON-ST: bruitage sonore *)

function charge(num, trav, ad, long: long_integer): long_integer; external;
(* SAUVE: charge les differentes sauvegardes *)

procedure chngani(animation, sequence, mode: long_integer); external;
(* ANIM: change etat animation non personnage *)

procedure chngmouse(num, vit: long_integer); external;
(* SOURIS: change la souris *)

procedure clrblk(ecran, xh, yh, xb, yb: long_integer); external;
(* nettoie une zone ecran par du noir *)

procedure coordmous; external;
(* SOURIS: coordonn‚es de la souris *)

procedure coupso4; external;
(* SON-ST: coupe tout son, libŠre 4 voix *)

procedure coupson; external;
(* SON-ST: coupe tout son, libŠre 3 voix *)

procedure damb(nbdh: long_integer); external;
(* SON-ST: demarrage ambiance *)

procedure decomp(aremap, addec, addes,
                 xco, yco, aecra: long_integer); external;

function depadr(ad, nu: long_integer): long_integer; external;

procedure domort(code, apal: long_integer); external;

procedure effets(neffet, style, adessi, aecrd, aecra,
                xh, yh, xb, yb: long_integer); external;

procedure exitani; external;
(* ANIM: stoppe les animations *)

procedure fini; external;
(* SON-ST: pour tout arreter *)

procedure finjeu; external;

procedure gotoxy(x, y: long_integer); external;

procedure grossi(aspec, fact, yaff, xaff,
                 ybn, xbn, yhn, xhn, ybg, xbg, yhg, xhg,
                  travail, ecran: long_integer); external;

function hazard(mini, maxi: long_integer): long_integer; external;

procedure hidemouse; external;

procedure hidemouf; external;

procedure initani; external;
(* ANIM: initialisation *)

procedure initadr(ad: long_integer); external;

procedure initmouse(acharg, amasque, aecrv, aecrc, asprite,
                    arecep: long_integer); external;

procedure inimus(atrav: long_integer); external;
(* SON-ST: initialisation *)

procedure initpal(apal: long_integer); external;

procedure lific(ad, lg, handle: long_integer); external;

procedure loadass; external;

function loadlieu(buf, dest, sty,
                  nlieu: long_integer): long_integer; external;

function loadobjt(buf, dest, nobj,
                  nfic: long_integer): long_integer; external;

(*function memlib: long_integer; external;*)

function memres: long_integer; external;

procedure mloupe(amasque, xco, yco: long_integer); external;

procedure modamb(nbdh: long_integer); external;
(* SON-ST: modification ambiance, appel: toutes les 5 minutes *)

procedure movblk(ecrdp, ecrarr, xh, yh, xb, yb: long_integer); external;

procedure musique(morceau, volume: long_integer); external;
(* SON-ST: morceau prioritaire *)

procedure paljn(nb5, nbdh, lieu: long_integer); external;

procedure paljnf(nb5, nbdh, lieu, amempa, adessi: long_integer); external;

procedure pamb(dat1: long_integer); external;
(* SON-ST: preparation ambiance et anim *)

function peek(ad: long_integer): long_integer; external;

function peekb(ad, bit: long_integer): long_integer; external;

function peekw(ad: long_integer): long_integer; external;

function peekl(ad: long_integer): long_integer; external;

procedure poke(ad, ct: long_integer); external;

procedure pokew(ad, ct: long_integer); external;

procedure pokel(ad, ct: long_integer); external;

procedure pourcent(pourc: long_integer); external;
(* SON-ST: pourcentage ressource pour le son *)

procedure remapec(aremap, y2, x2, y1, x1,
                  recep, depart: long_integer); external;

procedure sauve(num, ad, long: long_integer); external;
(* pour les differentes sauvegardes *)

function savmem(code, source, desti,
                xgh, ygh, xdb, ydb: long_integer): long_integer; external;
(* code negatif -> couleur de masque pour affichage
   code = 0 -> sauve
   code = 1 -> restore *)

procedure showmouse; external;

procedure showmouf; external;
(* apparition forcee de la souris *)

procedure stopani(anim: long_integer); external;
(* ANIM: stoppe une animation designee *)

procedure surim(dat1: long_integer); external;
(* SON-ST: musique surimpression *)

function tailta(ad, nu: long_integer): long_integer; external;

procedure temprio; external;
(* SON-ST: attente fin morceau prioritaire *)

(*function testdisk: long_integer; external; *)
(* test disque en cours *)

procedure testload(ad: long_integer); external;
(* test du nombre de sauvegarde *)

procedure traclign(aecr, xdep, ydep, xarr, yarr, coul: long_integer); external;

procedure vblsync(nbr: long_integer); external;

(******************)

procedure ordre(viobj, noobj, taille, sorte: integer;
                aordre: long_integer;
                var numobj: integer;
                iobjet: boolean); forward;

procedure tobjet(var numobj: integer;
                 var stop: boolean;
                 iobjet: boolean;
                 chai, viobj, noobj: integer); forward;

(* NIVEAU *)
procedure debug(text: str255; a1: integer; a2: long_integer);
var
 su, dtemps: long_integer;
 cx, cy: integer;
 str: str255;
 tab: array[0..9] of char;
begin
(* dtemps:= peekw(aheure);
 if peek(aflag10)= 0 then
 begin*)
  gotoxy(2,5);
  writeln('                              ');
  gotoxy(2,5);
  writeln(text);
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
  gotoxy(2,6);
  writeln('                         ');
  gotoxy(2,6);
  writeln(str);
  for cx:= 1 to 32000 do begin end;
  for cx:= 1 to 20000 do begin end;
  for cx:= 1 to 32000 do begin end;
  for cx:= 1 to 32000 do begin end;
  for cx:= 1 to 32000 do begin end;
  for cx:= 1 to 32000 do begin end;
(*  for cx:= 1 to 32000 do begin end; *)
(* end;
 pokew(aheure, dtemps);*)
end;

procedure grille(larg, depx, depy: integer);
var
 cx: integer;
begin
 for cx:= 0 to 15 do
 begin
  traclign(aecra1, ((cx* larg)+ depx), depy,
           ((cx* larg)+ depx), (depy+ 25), 0);
  traclign(aecra2, ((cx* larg)+ depx), depy,
           ((cx* larg)+ depx), (depy+ 25), 0);
 end;
 for cx:= 0 to 15 do
 begin
  traclign(aecra1, depx, ((cx* larg)+ depy),
           (depx+ 25), ((cx* larg)+ depy), 0);
  traclign(aecra2, depx, ((cx* larg)+ depy),
           (depx+ 25), ((cx* larg)+ depy), 0);
 end;
end;

procedure rect(x, y, w, h: integer);
begin
 traclign(aecra1, x, y, x, h, 15);
 traclign(aecra1, x, y, w, y, 15);
 traclign(aecra1, w, y, w, h, 15);
 traclign(aecra1, x, h, w, h, 15);
 traclign(aecra2, x, y, x, h, 15);
 traclign(aecra2, x, y, w, y, 15);
 traclign(aecra2, w, y, w, h, 15);
 traclign(aecra2, x, h, w, h, 15);
end;

procedure phidemou;
begin
end;

procedure phidem;
var
 su, a2: long_integer;
 cx, cy: integer;
 str: str255;
 tab: array[0..9] of char;
begin
 hidemouse;
(* ctrhi:= succ(ctrhi);
 if peek(aflag10)= 0 then
 begin
  gotoxy(2,7);
  writeln('                              ');
  gotoxy(2,7);
  writeln('hidemouse');
  delete(str,1,length(str));
  a2:= ctrhi; 
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
  gotoxy(2,8);
  writeln('                         ');
  gotoxy(2,8);
  writeln(str);
  for cx:= 1 to 32000 do begin end;
  for cx:= 1 to 32000 do begin end;
  for cx:= 1 to 32000 do begin end;
 end; *)
end;

procedure pshowmou;
begin
end;

procedure pshowm;
var
 su, a2: long_integer;
 cx, cy: integer;
 str: str255;
 tab: array[0..9] of char;
begin
 showmouse;
(* ctrsh:= succ(ctrsh);
 if peek(aflag10)= 0 then
 begin
  gotoxy(2,10);
  writeln('                              ');
  gotoxy(2,10);
  writeln('showmouse');
  delete(str,1,length(str));
  a2:= ctrsh;
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
  gotoxy(2,11);
  writeln('                         ');
  gotoxy(2,11);
  writeln(str);
  for cx:= 1 to 32000 do begin end;
  for cx:= 1 to 32000 do begin end;
  for cx:= 1 to 32000 do begin end;
 end; *)
end;

(* NIVEAU *)
procedure calcamb;
var
 cmin, cheu: integer;
begin
(* debug('calcamb', 0, 0); *)
 cmin:= min div 5;
 cheu:= heu* 2;
 if cmin> 5 then
 repeat
  cheu:= succ(cheu);
  cmin:= cmin- 6;
 until cmin< 6;
 damb(cheu);                (* SON-ST *)
end;

procedure calcpal(jn: boolean);
var
 cmin, cheu: integer;
begin
(* debug('calcpal', 0, 0); *)
 cmin:= min div 5;
 cheu:= heu* 2;
 if cmin> 5 then
 repeat
  cheu:= succ(cheu);
  cmin:= cmin- 6;
 until cmin< 6;
 modamb(cheu);                          (* SON-ST *)
 if jn then paljn(cmin, cheu, s.mlieu) else
  paljnf(cmin, cheu, s.mlieu, amempa, 0);
end;

procedure efchif(val, nbch, coox, cooy, lgli, intli, coul: integer;
                 aecra: long_integer);
var
 dum: long_integer;
begin
(* debug('efchif', 0, 0);*)
 dum:= aftext(-1, val, nbch, adtext, aecra,
               succ(coox), succ(cooy), lgli, intli, 0, 0, 1, 0);
 dum:= aftext(-1, val, nbch, adtext, aecra, 
               coox, succ(cooy), lgli, intli, 0, 0, 1, 0);
 dum:= aftext(-1, val, nbch, adtext, aecra,
               coox, cooy, lgli, intli, coul, 0, 1, 0);
end;

{}

procedure eftext(hauteur, coox, cooy, lgli, intli, coul: integer;
                 cadr, aecra: long_integer;
                 tstr, nphr: integer);
var
 atext, along: array[0..7] of long_integer; 
 dum: long_integer;

begin
(* debug('eftext', 0, 0); *)
 phidemou;
 atext[0]:= atext0;
 along[0]:= along0;
 atext[1]:= atext1;
 along[1]:= along1;
 atext[2]:= atext2;
 along[2]:= along2;
 atext[3]:= atext3;
 along[3]:= along3;
 atext[4]:= atext4;
 along[4]:= along4;
 atext[5]:= atext5;
 along[5]:= along5;
 atext[6]:= atext6;
 along[6]:= along6;
 atext[7]:= atext7;
 along[7]:= along7;
 dum:= aftext(hauteur, atext[nufic], along[nufic], adtext, aecra,
              succ(coox), succ(cooy), lgli, intli, 0, cadr, tstr, nphr);
 dum:= aftext(hauteur, atext[nufic], along[nufic], adtext, aecra,
              coox, succ(cooy), lgli, intli, 0, cadr, tstr, nphr);
 dum:= aftext(hauteur, atext[nufic], along[nufic], adtext, aecra,
              coox, cooy, lgli, intli, coul, cadr, tstr, nphr);
 pshowmou;
end;

{}

{}

procedure ortemps(adres: long_integer;
                  min, tempm, tempd, tempo, sorte: integer;
                  var posm: integer;
                  iobjet: boolean);
var
 taille, depla, dumi: integer;
 aordre: long_integer;

begin
(* debug('ortemps', 0, 0);*)
 taille:= int(tailta(adres, succ(tempm)));
 if (posm< taille) then
 begin
  if min= int(peekw(depadr(adres, tempm)+ posm)) then
  begin
   depla:= int(peekw(depadr(adres, tempd)+ posm));
   taille:= int(peekw(depadr(adres, tempd)+ posm+ 2))- depla;
   aordre:= depadr(adres, tempo)+ depla;
   ordre(-1, -1, taille, sorte, aordre, dumi, iobjet);
   posm:= posm+ 2;
  end;
 end;
end;

{}

procedure pexitani;
begin
 etani:= false; 
(* exitani; *)
end;

procedure pinitani;
begin
 etani:= true;
(* initani; *)
end;

function recpos(min, typ: integer): integer;
var
 taille, val, cx: integer;
 trouv: boolean;
begin
(* debug('recpos', 0, 0); *)
 trouv:= false;
 cx:= 0;
 taille:= int(tailta(adlieu, succ(typ)));
 if taille> 0 then
 repeat
  if min> int(peekw(depadr(adlieu, typ)+ cx)) then cx:= cx+ 2
   else trouv:= true;
 until (trouv) or (cx> taille);
 recpos:= cx;
end;

procedure styleff(eff, style, xh, yh, xb, yb: long_integer);
begin
(* debug('styleff', 0, 0);*)
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
   eff= 6 -> forcage palette: palette en amempa avec decalage dans style *)

 if (eff= 4) or (eff= 5) then
 begin
  if style= -1 then style:= hazard(0, 5);
  if style= -2 then style:= hazard(6, 11);
 end;
 effets(eff, style, amempa, aecra1, aecra2, xh, yh, xb, yb);
end;

(* NIVEAU *)
procedure actgene(min, sorte: integer;
                  iobjet: boolean);
var
 taille, dumi: integer;
 aordre: long_integer;
begin
(* debug('actgene', 0, 0);*)
 if (not perdu) and (not solu) then
 begin
  taille:= int(tailta(adgene, succ(gtemge)));
  aordre:= depadr(adgene, gtemge);
  ordre(-1, -1, taille, sorte, aordre, dumi, iobjet);
 end;
 if (not perdu) and (not solu) then
  ortemps(adgene, min, gtempm, gtempd, gtempo, sorte, s.posmg, iobjet);
end;

{}

procedure actlieu(min, sorte: integer;
                  iobjet: boolean);
var
 taille, posev, dumi: integer;
 aordre: long_integer;

begin
(* debug('actlieu', 0, 0);*)
 if (not perdu) and (not solu) then
 begin
  taille:= int(tailta(adlieu, succ(wblieu)));
  aordre:= depadr(adlieu, wblieu);
  ordre(-1, -1, taille, sorte, aordre, dumi, iobjet);
 end;
 if (not perdu) and (not solu) then
 begin
  posev:= recpos(min, wtempm);
  ortemps(adlieu, min, wtempm, wtempd, wtempo, sorte, posev, iobjet);
  s.posml[s.mlieu]:= min;
 end;
end;

{}

procedure affmen09;
var
 dum: long_integer;

begin
(* phidemou;
 if memoire> mmini then 
  dum:= savmem(-15, agen09, aecra1, 004, 162, 266, 199)
 else
 begin
  dum:= savmem(1, asgen08, aecra1, 004, 162, 266, 199);
  decomp(0, atrava, agen33, 0, 0, aecra1);
  decomp(0, atrava, agen34, 0, 0, aecra1);
  decomp(0, atrava, agen35, 0, 0, aecra1);
 end;
 styleff(5, 6, 004, 162, 266, 199);
 pshowmou; *)
end;

{}

procedure menuobj;
const
 nbti= 2;

var
 cx: integer;
 coox: array[0..nbti] of integer;
 nuti: array[0..nbti] of integer;

begin
 debug('menuobj', 0, 0);
 phidem;
 decomp(0, atrava, agen01, 0, 0, aecra1);
 decomp(0, atrava, agen01, 0, 0, aecra2);

 coox[0]:= 002;
 coox[1]:= 135;
 coox[2]:= 268;
 nuti[0]:= 47;
 nuti[1]:= 23;
 nuti[2]:= 50;
 for cx:= 0 to nbti do
  aftitre(nuti[cx], 0, coox[cx], 0, -1, 0,
          atext6, along6, adtext, asprit);
 pshowm;
end;

{}

procedure calch(totmin: integer);
var
 minute: integer;
begin
(* debug('calch', 0, 0);*)
 minute:= totmin* tmin;
 min:= minute mod 60;
 heu:= minute div 60;
 jou:= heu div 24;
 heu:= heu mod 24;
 jou:= succ(jou);
end;

{}

procedure e_mouse(var x, y, et, key: integer);
begin
(* debug('e_mouse', 0, 0);*)
 coordmous;                        (* pour obtenir les coord de click *)
 x:= int(peekw(asouris- 4));
 y:= int(peekw(asouris- 2));
 et:= int(peekw(asouris));
 if et<> 0 then pokew(asouris, 0);
 key:= int(peek(asouris+ 7));
 if key<> 0 then poke((asouris+ 7), 0);
 if key> 127 then key:= 0;
end;

{}

procedure mess1(nphr: integer);
var
 dum: long_integer;

begin
(* debug('mess1', 0, 0); *)
 imess:= true;
 nphr:= succ(nphr);
 phidem;
 clrblk(aecra1, 3, 179, 260, 196);
 eftext(17, 4, 179, 258, 8, 15, 1, aecra1, 0, nphr);
 styleff(5, 6, 004, 180, 259, 195);
 pshowm;
end;

{}

procedure pendule(aff: boolean;
                  typ: integer);
const
 am= 14;
 pm= 15;

 x= 290;
 y1= 156;
 rg= 12;
 wl= 12;
 wp= 6;
 rp= 8;
 vl= 8;
 vp= 4;

var
 pend: boolean;
 cst, mnufic, y, h, m: integer;
 cv: array[1..2] of array[1..12] of integer;
 cw: array[1..2] of array[1..12] of integer;
 jour: array[1..3] of integer;

begin
(* debug('pendule', 0, 0); *)
 if typ= 0 then cst:= 0 else cst:= 21; 
 pend:= false;
 if (min<> mmin) or (aff) then
 begin
  if (s.palet[s.mlieu]= 0) and (not aff) then calcpal(true);
  mmin:= min;
  pend:= true;
 end;

 if (heu<> mheu) or (aff) then
 begin
  mnufic:= nufic;
  nufic:= tamoi;
  decomp(0, (atrava+ deptra), agen09, 265, (124- cst), aecra1);
  if not aff then
  begin
   if (mheu< 12) and (heu> 11) then
    eftext(8, 271, (125- cst), 20, 8, 15, 0, aecra1, 0, pm);
   if (mheu> 11) and (heu< 12) then
    eftext(8, 271, (125- cst), 20, 8, 15, 0, aecra1, 0, am);
   movblk(aecra1, aecra2, 265, (124- cst), 315, (137- cst));
  end
  else
  begin
   if heu> 11 then
    eftext(8, 271, (125- cst), 20, 8, 15, 0, aecra1, 0, pm);
   if heu< 12 then
    eftext(8, 271, (125- cst), 20, 8, 15, 0, aecra1, 0, am);
  end;
  nufic:= mnufic;
  mheu:= heu;
  s.pourc:= s.pourc+ mpourc;
  mpourc:= 0;
  pend:= true;
 end;

 if (jou<> mjou) or (aff) then
 begin
  mjou:= jou;
  mnufic:= nufic;
  nufic:= tamoi;
  jour[1]:= 11;
  jour[2]:= 12;
  jour[3]:= 13;
  decomp(0, (atrava+ deptra), agen10, 286, (124- cst), aecra1);
  eftext(8, 294, (125- cst), 40, 8, 15, 0, aecra1, 0, jour[jou]);
  if not aff then
   movblk(aecra1, aecra2, 286, (124- cst), 315, (137- cst));
  nufic:= mnufic;
 end;

 if pend then
 begin
  decomp(0, (atrava+ deptra), agen11, 265, (138- cst), aecra1);

  y:= y1- cst;

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

  m:= min div 5;
  if m= 0 then m:= 12;
  traclign(aecra1, succ(x), succ(y),
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

  if not aff then
   movblk(aecra1, aecra2, 265, (138- cst), 315, (174- cst));
 end;
end;

{}

procedure posmouse(xsou, ysou, xhc, yhc, xbc, ybc: integer);
var
 cx, cy: integer;

begin
(* debug('posmouse', 0, 0); *)
 cx:= int(peekw(asouris+ 2));
 cy:= int(peekw(asouris+ 4));
 if (cx< xhc) or (cx> xbc) then cx:= xsou;
 if (cy< yhc) or (cy> ybc) then cy:= ysou;
 pokew((asouris+ 2), cx);
 pokew((asouris+ 4), cy);
 pokew((asouris+ 12), xhc);
 pokew((asouris+ 14), yhc);
 pokew((asouris+ 16), xbc);
 pokew((asouris+ 18), ybc);
end;

{}

procedure xacto2;
var
 deptr: long_integer;

begin
(* debug('xacto2', 0, 0); *)
(* deptr:= savmem(1, asgen08, aecra1, 004, 162, 266, 199);*)
 decomp(0, (atrava+ deptr), aaob07, -36, 20, aecra1);
 styleff(5, 6, 004, 162, 266, 199);
end;

{}

(* NIVEAU *)
procedure atclick(sou: integer; temps: boolean);
var
 dtemps: long_integer;
begin
(* debug('atclick', 0, 0); *)
 if sou<> -1 then chngmouse(sou, 5);
 showmouf;
 if not temps then
 begin
  repeat
   e_mouse(atmoux, atmouy, atbsta, atkey);
  until (atbsta<> 0) or (atkey<> 0);
 end
 else
 begin
  dtemps:= peekw(aheure);
  repeat
   e_mouse(atmoux, atmouy, atbsta, atkey);
  until (atbsta<> 0) or (peekw(aheure)- dtemps> 15) or (atkey<> 0);
 end;
 hidemouf;
end;

procedure efpoint(coox, cooy, coul: integer; ecraf: long_integer);
begin
 afmark(ecraf, succ(coox), succ(cooy), 0);
 afmark(ecraf, coox, succ(cooy), 0);
 afmark(ecraf, coox, cooy, coul);
end;

procedure loupdeb(var ok: boolean; var xaff, yaff: integer);
const
 alxmi= 8;      (* coord d'affich de la loupe min et max *)
 alxma= 198;
 alymi= 12;
 alyma= 123;
 milx= 6;       (* coord de prise en compte de la zone a grossir *)
 malx= 258;
 mily= 10;
 maly= 160;
var
 supxh, supyh, supxb, supyb: integer;
 cooxh, cooyh, cooxb, cooyb: integer;
 fact, zon, nbl, cx: integer;
 dum: long_integer;
begin
(* debug('loupdeb', 0, 0); *)
 if (mflex> milx) and (mflex< malx) and
    (mfley> mily) and (mfley< maly) then
 begin
  ok:= true;
  supxh:= 0;
  supyh:= 0;
  supxb:= 0;
  supyb:= 0;
  cooxh:= mflex;
  cooxb:= mflex;
  cooyh:= mfley;
  cooyb:= mfley;
  (* initialisation des coordonn‚es et adresses *)
  for cx:= 0 to 9 do
  begin
   pokel((aoblo+ (cx* 4)), -1);
   pokew((axoblo+ (cx* 2)), -1);
   pokew((ayoblo+ (cx* 2)), -1);
  end;
  nbl:= pred(int(peek(depadr(adlieu, wnloupe))));
  for cx:= 0 to nbl do
  begin
   zon:= int(peek(depadr(adlieu, wnloupe)+ succ(cx)));
   if s.valid[s.mlieu, zon]> 0 then
   begin
    pokel((aoblo+ (cx* 4)),
          (aoufer+ (peekw(depadr(adlieu, wdloupe)+ (cx* 6)))));
    pokew((axoblo+ (cx* 2)),
          (peekw(depadr(adlieu, wdloupe)+ (cx* 6)+ 2)));
    pokew((ayoblo+ (cx* 2)),
          (peekw(depadr(adlieu, wdloupe)+ (cx* 6)+ 4)));
   end;
  end;
  (* decalage loupe pour les bords *)
  cx:= 0;
  repeat
   cooxh:= pred(cooxh);
   cx:= succ(cx);
  until (cooxh= milx) or (cx= 15);
  if (cooxh= milx) and (cx< 15) then supxb:= 15- cx;
  cx:= 0;
  repeat
   cooyh:= pred(cooyh);
   cx:= succ(cx);
  until (cooyh= mily) or (cx= 8);
  if (cooyh= mily) and (cx< 8) then supyb:= 8- cx;
  cx:= 0;
  repeat
   cooxb:= succ(cooxb);
   cx:= succ(cx);
  until (cooxb= malx) or (cx= 15);
  if (cooxb= malx) and (cx< 15) then supxh:= cx- 15;
  cx:= 0;
  repeat
   cooyb:= succ(cooyb);
   cx:= succ(cx);
  until (cooyb= maly) or (cx= 8);
  if (cooyb= maly) and (cx< 8) then supyh:= cx- 8;
  cooxh:= cooxh+ supxh;
  cooxb:= cooxb+ supxb;
  cooyh:= cooyh+ supyh;
  cooyb:= cooyb+ supyb;
  fact:= 2;
  yaff:= cooyh- 7;
  xaff:= cooxh- 15;
  if xaff< alxmi then xaff:= alxmi;
  if xaff> alxma then xaff:= alxma;
  if yaff< alymi then yaff:= alymi;
  if yaff> alyma then yaff:= alyma;
  (* fin decalage *)
  phidemou;
  {anihalt;}
  dum:= savmem(0, aecra1, atrava,
               (xaff- 2), (yaff- 2), (xaff+ 67), (yaff+ 36));
  grossi(aoblo, fact, yaff, xaff,
         yaff+ ((cooyb- cooyh)* fact), xaff+ ((cooxb- cooxh)* fact),
         yaff, xaff,
         cooyb, cooxb, cooyh, cooxh, (atrava+ dum), aecra1);
  decomp(0, (atrava+ dum), aloupe, (xaff- 2), (yaff- 2), aecra1);
  mloupe(amas03, (xaff- 2), (yaff- 2));
  styleff(5, 0, (xaff- 2), (yaff- 2), (xaff+ 67), (yaff+ 36));
  {anishow;}
  pshowmou;
 end else ok:= false;
end;

procedure loupfin(ok: boolean; xaff, yaff: integer);
const
 milx= 7;
 malx= 260;
 mily= 12;
 maly= 159;
var
 dum: long_integer;
begin
(* debug('loupfin', 0, 0); *)
 if ok then
 begin
  phidemou;
  dum:= savmem(1, atrava, aecra1,
               (xaff- 2), (yaff- 2), (xaff+ 67), (yaff+ 36));
  styleff(5, 0, (xaff- 2), (yaff- 2), (xaff+ 67), (yaff+ 36));
  dum:= savmem(1, atrava, 0,
               (xaff- 2), (yaff- 2), (xaff+ 67), (yaff+ 36));
  pshowmou;
 end;
end;

procedure make_path(var ps: str255; var cs: path_chars);
var
 i: integer;
begin
(* debug('make_path', 0, 0);*)
 for i:= 1 to length(ps) do cs[i]:= ps[i];
 cs[succ(length(ps))]:= chr(0);
end;

{}

procedure tinke(jeux, iobjet: boolean;
                nverb, sorte: integer);
var
 cx, mnufic: integer;
 dum: long_integer;

begin
(* debug('tinke', 0, 0);*)
 cx:= int(peekw(aheure))+ s.rsec;
 pokew(aheure, 0);
 s.nmin:= s.nmin+ (cx div 60);
 s.rsec:= cx mod 60;
 if s.nmin> s.mmin then
 begin
  s.mmin:= succ(s.mmin);
  repeat
   calch(s.mmin);
   if iobjet then pendule(false, 1) else pendule(false, 0);
   imess:= false;
   mnufic:= nufic;
   nufic:= tgene;
   if not arret then
   begin
    actgene(s.mmin, sorte, iobjet);
    actlieu(s.mmin, sorte, iobjet);
    if imess then
    begin 
     if iobjet then
     begin
      if jeux then
      begin
       chngmouse(1, 6);
(*       posmouse(290, 152, 261, 140, 303, 162);
       xacto2;*)
      end
      else menuobj;
     end
     else
     begin
      if jeux then
      begin
       chngmouse(5, 6);
(*       posmouse(131, 85, 2, 10, 253, 156);
         xact2(nverb); *)
      end
      else affmen09;
     end;
    end;
   end;
   nufic:= mnufic;
   s.mmin:= succ(s.mmin);
  until s.mmin> s.nmin;
  s.mmin:= s.nmin;
 end;
end;

{}

procedure tkey(var key: integer);
begin
(* debug('tkey', 0, 0);*)
 dep:= -1;
 act:= -1;
 obj:= -1;

 if key= kf1 then obj:= 0;
 if key= kf2 then obj:= 1;
 if key= kf3 then obj:= 2;
 if key= kf4 then obj:= 3;

(* if key= kup then dep:= 0;
 if key= kri then dep:= 1;
 if key= kdo then dep:= 2;
 if key= kle then dep:= 3; *)

 if key= kpg then act:= 0;
 if key= kpd then act:= 1;
 if key= ksl then act:= 2;
 if key= kas then act:= 3;
 if key= kn7 then act:= 4;
 if key= kn8 then act:= 5;
 if key= kn9 then act:= 6;
 if key= kmo then act:= 7;
 if key= kn4 then act:= 8;
 if key= kn5 then act:= 9;
 if key= kn6 then act:= 10;
 if key= kpl then act:= 11;
 if key= kn1 then act:= 12;
 if key= kn2 then act:= 13;
 if key= kn3 then act:= 14;
 if key= ken then act:= 15;
 if key= khe then act:= 16;

 if (act= -1) and (dep= -1) and (obj= -1) then key:= 0;
end;

procedure tkeyo(var key: integer);
begin
(* debug('tkeyo', 0, 0);*)
 acto:= -1;
 obj:= -1;

 if key= kf1 then obj:= 0;
 if key= kf2 then obj:= 1;
 if key= kf3 then obj:= 2;
 if key= kf4 then obj:= 3;

 if key= kn4 then acto:= 0;
 if key= kn5 then acto:= 1;
 if key= kn6 then acto:= 2;
 if key= kpl then acto:= 3;
 if key= kn1 then acto:= 4;
 if key= kn2 then acto:= 5;
 if key= kn3 then acto:= 6;

 if key= ksl then acto:= 15;

 if key= khe then acto:= 16;

 if (acto= -1) and (obj= -1) then key:= 0;
end;

(* NIVEAU *)
procedure joueur(ttink, iobjet: boolean;
                 nverb: integer;
                 var bsta, key: integer);
var
 dum: long_integer;
begin
(* debug('joueur', 0, 0);*)
 pshowmou;
 bsta:= 0;
 dep:= -1;
 act:= -1;
 key:= 0;
 repeat
  e_mouse(moux, mouy, bsta, key);
  if key<> 0 then
   if not iobjet then tkey(key) else tkeyo(key);
  if ttink then tinke(true, iobjet, nverb, 0);
 until (bsta<> 0) or (key<> 0);
 phidemou;
end;

procedure lect(nom: str255; adr: long_integer; var long: long_integer);
var
 nomp: path_chars;
 handle, dummy: integer;
 lhandle: long_integer;
begin
(* debug('lect', 0, 0);*)
 make_path(nom,nomp);
 handle:= f_open(nomp, 0);
 long:= f_seek(0, handle, 2);
 if odd(long) then long:= succ(long);
 lhandle:= f_seek(0, handle, 0);
 lhandle:= handle;
 lific(adr, long, lhandle);
 dummy:= f_close(handle);
end;

{}

procedure sloupe(gmes, num, mess: integer);
const
 numrega= 08;

var
 xaff, yaff: integer;
 ok: boolean;

begin
(* debug('sloupe', 0, 0); *)
 if (gmes= gmesve) and (num= numrega) then
 begin
  loupdeb(ok, xaff, yaff);
  mess1(mess);
  loupfin(ok, xaff, yaff);
 end
 else mess1(mess);
end;

{}

(* NIVEAU *)
procedure actverb(viobj, noobj, gmes, num, zone, act: integer;
                  adres: long_integer;
                  var numobj: integer;
                  iobjet: boolean);

var
 cx, cy, mess, tot, taille, mnum: integer;
 depla, aordre: long_integer;
 trouv: boolean;

begin
(* debug('actverb', 0, 0);*)
 mnum:= num;
 (* pour message general de toucher objet *)
 if act= gtouch then
  mess:= int(peekw(depadr(adgene, gmes)+ (9* 2)))
 else
  mess:= int(peekw(depadr(adgene, gmes)+ (num* 2)));
 if zone= -1 then sloupe(gmes, mnum, mess) else
 begin
  num:= (num* 3)+ act;
  if tailta(adres, succ(num))<> 0 then
  begin
   tot:= int(peek(depadr(adres, num)));
(* debug('total des zones avec action', tot, 0); *)
   cx:= 1;
   trouv:= false;
   repeat
(* debug('zone compar‚e', int(peek(depadr(adres, num)+ cx)), 0);*)
    if zone= int(peek(depadr(adres, num)+ cx)) then trouv:= true
    else cx:= succ(cx);
   until (cx> tot) or (trouv);
   if trouv then
   begin
    depla:= depadr(adres, succ(num));
    tot:= 0;
    cx:= pred(cx);
    for cy:= 0 to pred(cx) do
     tot:= tot+ int(peekw(depla+ (cy* 2)));
    taille:= int(peekw(depla+ (cx* 2)));
(*debug('taille des ordres', taille, 0);*)
    aordre:= depadr(adres, (num+ 2))+ tot;
    ordre(viobj, noobj, taille, 0, aordre, numobj, iobjet);
   end
   else
   begin
    (* pour eviter le message en prendre main et enlever main si nul *)
    if ((gmes= gmesob) and (mnum<> 7) and (mnum<> 8)) or
       (gmes= gmesve) then
     sloupe(gmes, mnum, mess);
   end;
  end
  else
  begin
   (* pour eviter le message en prendre main et enlever main si nul *)
   if ((gmes= gmesob) and (mnum<> 7) and (mnum<> 8)) or
      (gmes= gmesve) then
    sloupe(gmes, mnum, mess);
  end;
 end;
end;

{}

procedure nomob(nu: integer);
var
 numess, mnufic: integer;

begin
 numess:= int(peek(depadr(adgene, gnomob)+ nu));
 mnufic:= nufic;
 nufic:= tnomo;
 mess1(numess);
 nufic:= mnufic;
end;

{}

procedure tfleche(iobjet: boolean;
                  nverb, depx, depy, larg, num, nbrec, decoup: integer;
                  adres: long_integer;
                  var zone, key: integer);
var
 depla: long_integer;
 enc, enc4, tot, som, cx, cy, cz: integer;
 ocoox1, ocooy1, ocoox2, ocooy2: integer;
 bsta, coox, cooy: integer;
 lieu: boolean;

begin
(* debug('tfleche', 0, 0);*)
 if iobjet then
 begin
  chngmouse(1, 6);
  posmouse(290, 152, 261, 140, 303, 162);
 end;
 joueur(true, iobjet, nverb, bsta, key);
 if key= 0 then
 begin
  if (bsta= 2) and (mflex<> -1) and (mfley<> -1) then
  begin
   moux:= mflex;
   mouy:= mfley;
  end;
  coox:= (moux- depx) div larg;
  cooy:= (mouy- depy) div larg;
  zone:= -1;
  if num= -1 then
  begin
   lieu:= true;
   num:= 0;
  end
  else lieu:= false;
  cz:= num* 2;
  if tailta(adres, succ(nbrec+ cz))<> 0 then
  begin
   tot:= int(peek(depadr(adres, (nbrec+ cz))));
(* debug('nbre de zone', tot, 0);*)
   depla:= depadr(adres, (decoup+ cz));
   som:= 0;
   enc:= 0;
   cx:= 1;
   repeat
    enc:= enc+ som;
    enc4:= enc* 4;
    som:= int(peek(depadr(adres, (nbrec+ cz))+ cx));
(* debug('nbre de rectangle pour chaque zone', som, 0);*)
    if som> 0 then
    begin
     cy:= 1;
     repeat
      ocoox1:= int(peek(depla+ pred(cy)+ enc4));
      ocoox2:= int(peek(depla+ cy+ enc4));
      if (coox>= ocoox1) and (coox<= ocoox2) then
      begin
       ocooy1:= int(peek(depla+ pred(cy)+ (som* 2)+ enc4));
       ocooy2:= int(peek(depla+ cy+ (som* 2)+ enc4));
       if (cooy>= ocooy1) and (cooy<= ocooy2) then
       begin
        zone:= pred(cx);
        if lieu then
         if s.valid[s.mlieu, zone]< 1 then zone:= -1;
        if not lieu then
         if s.valob[num, zone]< 1 then zone:= -1;
       end;
      end;
      cy:= cy+ 2;
     until (cy> (som* 2)) or (zone<> -1);
    end;
    cx:= succ(cx);
   until (cx> tot) or (zone<> -1);
  end;
  mflex:= moux;
  mfley:= mouy;
 end;
end;

{}

procedure tiroir;
var
 tir: boolean;
 cx: integer;

begin
(* debug('tiroir', 0, 0); *)
 tir:= false;
 cx:= 0;
 repeat
  if s.objet[cx]= s.mlieu then tir:= true else cx:= succ(cx);
 until (cx> maxob) or (tir);
(* if tir then decomp(0, atrava, agen07, 0, 0, aecra1)
  else decomp(0, atrava, agen19, 0, 0, aecra1);*)
end;

{}

procedure xload(lieu: boolean;
                dat1, dat2: long_integer;
                dat3, dat4: integer;
                var dum: long_integer);
const
 nfic= 'E:\SUKYA.ESS\CHDISQ.O';

 nphr1= 18;
 nphr2= 19;
 naze= -1000;

var
 prem: boolean;
 mnufic: integer;
 dtemps, dum2: long_integer;

begin
(* debug('xload', 0, 0);*)
 prem:= true;
 repeat
  if lieu then dum:= loadlieu(dat1, dat2, dat3, dat4)
   else dum:= loadobjt(dat1, dat2, dat3, dat4);
  if dum< 0 then
  begin
   dtemps:= peekw(aheure);
(*   if etani then exitani; *)
   mnufic:= nufic;
   nufic:= tamoi;
   if prem then
   begin
    prem:= false;
    lect(nfic, adessi, dum2);
   end;
   decomp(0, atrava, adessi, 0, 0, aecra1);
   if dum= naze then eftext(25, 34, 100, 250, 8, 15, 1, aecra1, 0, nphr2)
   else
   begin
    eftext(25, 34, 100, 250, 8, 15, 1, aecra1, 0, nphr1);
    efchif(int(-dum), -2, 152, 109, 25, 8, 15, aecra1);
   end;
   styleff(4, -1, 0, 0, 319, 199);
   repeat
    e_mouse(atmoux, atmouy, atbsta, atkey);
   until (atbsta<> 0) or (atkey<> 0);
   nufic:= mnufic;
(*   decomp(0, atrava, agen02, 0, 0, aecra1);*)
   pokew(aheure, dtemps);
  end;
 until dum> -1;
 if not prem then
 begin
(*  decomp(0, atrava, agen06, 0, 0, aecra1);
  decomp(0, atrava, agen04, 0, 0, aecra1);
  decomp(0, atrava, agen21, 0, 0, aecra1);
  decomp(0, atrava, agen22, 0, 0, aecra1);
  decomp(0, atrava, agen14, 0, 0, aecra1);
  decomp(0, atrava, agen15, 0, 0, aecra1);
  decomp(0, atrava, agen11, 0, 0, aecra1); *)
  tiroir;
  calch(s.nmin);
  pendule(true, 0);
 end;
end;

{}

(* NIVEAU *)
procedure afobj(eff, bnom: boolean; dum: long_integer;
                nu, coox, cooy, typ: integer);
var
 adres, dummy: long_integer;
 cox, coy: integer;

begin
(* debug('afobj', 0, 0);*)
 if (not perdu) and (not solu) then
 begin
  phidem;
  if nu> -1 then
  begin
   xload(false, (atrava+ dum), adessi, nu, 1, dummy);
(*   if typ= 0 then adres:= ainv03 else adres:= agen01;
   decomp(0, (atrava+ dum), adres, (coox- 2), (cooy- 2), aecra1);*)
(*   decomp(depadr(adlieu, wremob), (atrava+ dum),
                                   adessi, coox, cooy, aecra1); *)
                                   
   (* jusqu'a ce qu'il y est des remaps, apres au-dessus *)
   decomp(0, (atrava+ dum), adessi, coox, cooy, aecra1);

(*  end
  else
  begin 
   if typ= 0 then
   begin
    adres:= ainv02;
    cox:= coox- 2;
    coy:= cooy- 2;
   end
   else
   begin
    adres:= agen06;
    cox:= 0;
    coy:= 0;
   end;
   decomp(0, (atrava+ dum), adres, cox, coy, aecra1); *)
  end;
(*  if typ= 2 then gobj2:= nu;*)
  if eff then
   styleff(5, 6, (coox- 2), (cooy- 2), 319, (cooy+ 38));
  if (bnom) and (nu> -1) then nomob(nu);
  pshowm;
 end;
end;

{}

procedure main(var num: integer);
var
 trouv: boolean;
 cx: integer;
begin
(* debug('main', 0, 0); *)
 trouv:= false;
 cx:= 0;
 repeat
  if s.objet[cx]= -1 then trouv:= true else cx:= succ(cx);
 until (cx> maxob) or (trouv);
 if trouv then num:= cx else num:= -1;
end;

procedure recver(comx, lgpx, moux, mouy: integer;
                 var menu: boolean; var men, attend: integer);
const
 tmyh= 29;
 tmyb= 39;
 tmha= 11;
var
 cmys: array[0..5] of integer;
 cmyi: array[0..5] of integer;
 tmxs: array[0..3] of integer;
 tmxi: array[0..3] of integer;
 tmys: array[0..3] of integer;
 tmyi: array[0..3] of integer;
 cx: integer;
 trouv: boolean;

begin
(* debug('recver : ', 0, 0);*)
 attend:= -1;
 menu:= false;
 cmys[0]:= 001;     (* pourcentage *)
 cmys[1]:= 029;     (* attendre *)
 cmys[2]:= 055;     (* help *)
 cmys[3]:= 085;     (* objet main *)
 cmys[4]:= 113;     (* objet lieu *)
 cmys[5]:= 140;     (* Action *)

 cmyi[0]:= 027;     (* idem au dessus... *)
 cmyi[1]:= 050;
 cmyi[2]:= 081;
 cmyi[3]:= 109;
 cmyi[4]:= 137;
 cmyi[5]:= 165;

 tmxs[0]:= 279;     (* attends jour *)
 tmxs[1]:= 296;     (* attends 1/2 jour *)
 tmxs[2]:= 279;     (* attends heure *)
 tmxs[3]:= 296;     (* attends 5 mn *)

 tmxi[0]:= 292;     (* idem au dessus *)
 tmxi[1]:= 308;
 tmxi[2]:= 292;
 tmxi[3]:= 310;

 tmys[0]:= 38;      (* idem au dessus *)
 tmys[1]:= 38;
 tmys[2]:= 29;
 tmys[3]:= 29;

 tmyi[0]:= 47;      (* idem au dessus *)
 tmyi[1]:= 47;
 tmyi[2]:= 37;
 tmyi[3]:= 37;

 if (moux> comx) and (moux< (comx+ lgpx)) then
 begin
  cx:= 0;
  repeat
   if (mouy> cmys[cx]) and (mouy< cmyi[cx]) then menu:= true
   else cx:= succ(cx);
  until (menu) or (cx> 5);
  men:= cx;

  if men= 1 then
  begin
   trouv:= false;
   cx:= 0;
   repeat
    if (moux> tmxs[cx]) and (moux< tmxi[cx]) and
       (mouy> tmys[cx]) and (mouy< tmyi[cx]) then trouv:= true
    else cx:= succ(cx);
   until (trouv) or (cx> 3);
   if trouv then
   begin
    if cx= 0 then attend:= 287;
    if cx= 1 then attend:= 143;
    if cx= 2 then attend:= 11;
    if cx= 3 then attend:= 0;
   end;
  end;
 end;
end;

{}

procedure tdepo(var key: integer;
                noobj: integer;
                iobjet: boolean);
const
 xafob= 271;
 yafob= 085;
 comy= 137;
 lgpx= 048;

var
 mnufic, dumi: integer;

begin
(* debug('tdepo', 0, 0); *)
 mnufic:= nufic;
 main(key);
 if key<> -1 then
 begin
  nufic:= tgene;
  actverb(-1, key, gmesob, 8, key, gobjet, adgene, dumi, iobjet);
  s.objet[key]:= s.mlieu;
  afobj(false, false, 0, -1, xafob, yafob, 1);
  if noobj= -1 then tiroir;
  if (not perdu) and (not solu) then
   styleff(5, 6, (xafob- 2), (yafob- 2), (xafob+ lgpx), comy);
 end
 else
 begin
  nufic:= tamoi;
  mess1(7);
 end;
 nufic:= mnufic;
end;

{}

procedure tverbe(nverb: integer;
                 var key: integer;
                 iobjet: boolean);
const
 depx= 5;
 depy= 11;
 larg= 8;
 numrega= 08;

var
 ind, mnufic, dumi: integer;

begin
(* debug('tverbe', 0, 0); *)
debug('nverb', nverb, 0);
 main(ind);
 if ind= -1 then
 begin
  (* mettre et main vide *)
  if nverb= 05 then
  begin
   mnufic:= nufic;
   nufic:= tamoi;
   mess1(15);
   nufic:= mnufic;
   key:= 0;
   act:= -1;
  end
  else ind:= 0;
 end;
 if ind<> -1 then
 begin
  mnufic:= nufic;
  nufic:= tgene;
  if nverb= numrega then                            (* regarder *)
  begin
(*   posmouse(131, 85, 1, 5, 250, 150); *)
   chngmouse(4, 5);
  end
  else
  begin
(*   posmouse(131, 85, 2, 10, 253, 156);*)
   chngmouse(5, 6);
  end;
(*  if s.cach then
  begin
   phidemou;
   s.cach:= false;
   decomp(0, atrava, agen18, 0, 0, aecra1);
   decomp(0, atrava, agen18, 0, 0, aecra2);
   pshowmou;
  end;*)

  tfleche(false, nverb, depx, depy, larg, -1,
                                   wnbrect, wdecoup, adlieu, nzon, key);
  if key= 0 then actverb(-1, -1, gmesve, nverb, nzon,
                                         wverbe, adlieu, dumi, iobjet);
  posmouse(304, 199, 0, 0, 304, 199);
  nufic:= mnufic;
 end;
end;

{}

(* NIVEAU *)
procedure afpour;
const
 nphr= 1;

var
 mnufic: integer;
 dum: long_integer;

begin
 mnufic:= nufic;
 nufic:= tamoi;
(* dum:= savmem(1, asgen14, aecra1, 004, 162, 266, 199);*)
 eftext(25, 8, 165, 250, 8, 15, 1, aecra1, 0, nphr);
 efchif(s.pourc, -2, 128, 174, 25, 8, 15, aecra1);
 styleff(5, 6, 004, 162, 266, 199);
 posmouse(304, 164, 0, 0, 304, 164);
 atclick(0, true);
 posmouse(304, 199, 0, 0, 304, 199);
 nufic:= mnufic;
end;

{}

procedure barmen(comx, lgpx: integer;
                 var men: integer;
                 iobjet: boolean);
var
 menu: boolean;
 dumi: integer;

begin
(* debug('barmen', 0, 0); *)
 phidemou;
 menu:= false;
 if iobjet then
  if (atkey= khe) or (atkey= ksl) or (atkey= kpl) or
     ((atkey> kn9) and (atkey< ken)) then menu:= true;
 if not iobjet then
  if (atkey>= khe) or (atkey= kpl) or (atkey= kmo) then menu:= true;
 if atbsta= 2 then menu:= true;
 if atbsta= 1 then  recver(comx, lgpx, atmoux, atmouy, menu, men, dumi);
 (* reaffichage de la barre menu *)
 if ((atbsta= 0) and (atkey= 0)) or
    ((atbsta= 1) and (men= 1)) or
    (not menu) then
 begin
  if iobjet then menuobj else affmen09;
 end;
 chngmouse(0, 5);
 pshowmou;
end;

{}

procedure faitnom(var str: str255; lieu: integer);
var
 cx, cy, su, tot: integer;
 tab: array[0..9] of char;

begin
 tot:= lieu;
 delete(str,1,length(str));
 if tot<> 0 then
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
  su:= 10;
  for cx:= 1 to 2 do
  begin
   cy:= 0;
   repeat
    cy:= cy+ 1;
    tot:= tot- su;
   until tot< 0;
   tot:= tot+ su;
   cy:= cy- 1;
   str:= concat(str, tab[cy]);
   su:= su div 10;
  end;
 end
 else str:= concat(str, '00');
 str:= concat(str,'.O');
end;

{}

procedure meppal;
var
 cx, pal: integer;
 adres: long_integer;

begin
 adres:= peekw(depadr(adlieu, wadpal));
 if s.palet[s.mlieu]> 0 then 
 begin
  pal:= s.palet[s.mlieu]+ 3; 
  adres:= aoufer+ adres+ (pal* 32);
  for cx:= 0 to 7 do pokel((amempa+ (cx* 4)), peekl(adres+ (cx* 4)));
 end;
end;

{}

procedure mlecte(num: integer; adchar: long_integer;
                 var adsuit: long_integer);
var
 long: long_integer;

begin
(* debug('mlecte', 0, 0);*)
 xload(false, aecra1, adchar, num, 8, long); (* travail ds ecran 1 *)
 adsuit:= adchar+ long;
end;

{}

procedure mlect(num: integer; adchar: long_integer;
                var adsuit: long_integer);
var
 long: long_integer;

begin
(* debug('mlect', 0, 0);*)
 xload(false, aecra1, adchar, num, 2, long); (* travail ds ecran 1 *)
 adsuit:= adchar+ long;
end;

{}

procedure nvobjma(var nvob: integer; 
                  iobjet: boolean);
const
 objabs= -99;

var
 trouv: boolean;
 cx, mnufic, dumi: integer;

begin
 nvob:= -1;
 mnufic:= nufic;
 nufic:= tobje;
 main(cx);
 if cx<> -1 then
 begin
  s.objet[cx]:= objabs;
  actverb(-1, cx, gmesob, 8, cx, gobjet, adgene, dumi, iobjet);
 end;
 trouv:= false;
 cx:= 0;
 repeat
  if s.objet[cx]= -succ(mobj) then
  begin
   trouv:= true;
   nvob:= cx;
   s.objet[nvob]:= -1;
   actverb(-1, nvob, gmesob, 7, nvob, gobjet, adgene, dumi, iobjet);
  end
  else cx:= succ(cx);
 until (cx> maxob) or (trouv);
 trouv:= false;
 cx:= 0;
 repeat
  if s.objet[cx]= objabs then
  begin
   trouv:= true;
   s.objet[cx]:= -succ(mobj);
  end
  else cx:= succ(cx);
 until (cx> maxob) or (trouv);
 nufic:= mnufic;
end;

{}

procedure objsoi(viobj, noobj: integer;
                 iobjet: boolean);
const
 mple= 08;
 mfin= 09;
 mvid= 07;
 obx= 271;
 oby= 141;
 oby2= 113;

var
 stop, prem: boolean;
 dum: long_integer;
 cx, cy, mnufic: integer;

begin
(* debug('objsoi', 0, 0); *)
 ifouil:= true;
 mnufic:= nufic;
 nufic:= tamoi;
 for cx:= 0 to nbobj do objso[cx]:= -1;
 for cx:= 0 to maxob do
  if (s.objet[cx]< 0) and (s.objet[cx]> -6) then
  begin
   cy:= pred(-(s.objet[cx]));
   objso[cy]:= cx;
  end;
 prem:= false;
 cx:= 0;
 repeat
  if objso[cx]<> -1 then prem:= true else cx:= succ(cx);
 until (cx> nbobj) or (prem);
 if prem then
 begin
  mess1(mple);
  vblsync(11);
  nufic:= tgene;
  phidemou;
(* traitement menu  objet *)
  if gobj2> -1 then tiroir;
  afobj(false, false, 0, objso[cx], obx, oby, 4);
  styleff(5, 6, (obx- 2), (oby2- 2), (obx+ 50), (oby+ 26));
  nomob(objso[cx]);
  menuobj;
  pshowmou;
  stop:= false;
  mmeno:= 0;
  macto:= 0;
  repeat
   tobjet(cx, stop, iobjet, -1, viobj, noobj);
  until (cx> nbobj) or (stop) or (perdu) or (arret) or (solu);
  if (not perdu) and (not arret) and (not solu) then
  begin
   phidemou;
(*debug('affich viobj', viobj, 0);*)
   if viobj< 0 then (*decomp(0, atrava, agen17, 0, 0, aecra1)*)
    else afobj(false, false, 0, viobj, obx, oby, 4);
(*debug('affich gobj2', gobj2, 0);*)
   if gobj2> -1 then afobj(false, false, 0, gobj2, obx, oby2, 4);
   styleff(5, 6, (obx- 2), (oby2- 2), (obx+ 50), (oby+ 26));
   nufic:= tamoi;
   mess1(mfin);
   pshowmou;
  end;
 end
 else mess1(mvid);
 nufic:= mnufic;
 ifouil:= false;
end;

{}

procedure opv(obj: integer; var pobj, vobj: integer);
begin
 pobj:= int(peekw(depadr(adgene, gpdobj)+ (obj* 2)));
 vobj:= int(peekw(depadr(adgene, gvlobj)+ (obj* 2)));
end;

{}

procedure recdes(val, zone: integer);
var
 depla: long_integer;
 cx, tot, som, num: integer;

begin
(* debug('recdes', 0, 0); *)
 depla:= depadr(adlieu, wdecdes);
 som:= 0;
 for cx:= 0 to pred(zone) do
  som:= som+ int(peek(depla+ cx));
 tot:= pred(int(peek(depla+ zone)));
 depla:= depadr(adlieu, wnumdes);
 cx:= 0;
 for cx:= 0 to tot do
 begin
  num:= int(peek(depla+ som+ cx));
  poke((depadr(adlieu, wdesval)+ num), val);
 end;
end;

{}

procedure stopjeu(iobjet: boolean);
var
 key, mnufic, cox, coy, ets: integer;
 dum, dtemps: long_integer;

begin
(* mise en commentaire pour ST *)
 dtemps:= peekw(aheure);
 mnufic:= nufic;
 nufic:= tamoi;
 mess1(5);
 ets:= 0;
 key:= 0;
 repeat
  e_mouse(cox, coy, ets, key);
  if ets<> 0 then
  begin
   ets:= 0;
   key:= 0;
   if coy> 173 then
   begin
    if (cox> 085) and (cox< 131) then key:= kou;
    if (cox> 130) and (cox< 176) then key:= kno;
   end;
  end;
 until key<> 0;
 if key= kou then arret:= true else 
  if iobjet then menuobj else affmen09;
 pokew(aheure, dtemps);
end;

{}

procedure clicdep(cdep: integer;
                  var key: integer;
                  iobjet: boolean);
const
 nblieu= 3;       (* nb de lieu a tester sur carte -1 *)
 cxaf= 100;       (* coordonnees affichage carte de choix *)
 cyaf= 50;

var
 taille, dumi, bsta, direc: integer;
 x1s, y1s, x2s, y2s: integer;
 dtemps, dum, aordre: long_integer;
 trouv: boolean;
 cox1, cox2, coy1, coy2: array[0..nblieu] of integer;

begin
(* debug('tdepla', 0, 0); *)
 chgtab:= false;
 if cdep= 0 then tverbe(succ(nbver), key, iobjet) else
 begin
  dtemps:= peekw(aheure);
  x1s:= cxaf;
  y1s:= cyaf;
  x2s:= 088+ cxaf;
  y2s:= 120+ cyaf;
  dum:= savmem(0, aecra1, atrava, x1s, y1s, x2s, y2s);
  dum:= savmem(-1, asgen12, aecra1, x1s, y1s, x2s, y2s);
  styleff(5, 6, x1s, y1s, x2s, y2s);
  bsta:= 0;
  repeat
   e_mouse(moux, mouy, bsta, dumi);
  until bsta<> 0;
  dum:= savmem(1, atrava, aecra1, x1s, y1s, x2s, y2s);
  styleff(5, 6, x1s, y1s, x2s, y2s);
  pokew(aheure, dtemps);
  
  cox1[0]:= 032+ cxaf;
  coy1[0]:= 091+ cyaf;
  cox2[0]:= 049+ cxaf;
  coy2[0]:= 105+ cyaf;
  cox1[1]:= 019+ cxaf;
  coy1[1]:= 061+ cyaf;
  cox2[1]:= 061+ cxaf;
  coy2[1]:= 087+ cyaf;
  cox1[2]:= 000+ cxaf;
  coy1[2]:= 027+ cyaf;
  cox2[2]:= 024+ cxaf;
  coy2[2]:= 039+ cyaf;
  cox1[3]:= 066+ cxaf;
  coy1[3]:= 052+ cyaf;
  cox2[3]:= 074+ cxaf;
  coy2[3]:= 065+ cyaf;
  trouv:= false;
  direc:= 0;
  repeat
   if (moux> cox1[direc]) and (moux< cox2[direc])
    and (mouy> coy1[direc]) and (mouy< coy2[direc]) then
    trouv:= true else direc:= succ(direc);
  until (direc> nblieu) or (trouv);
  if trouv then
  begin
debug('trouv num', direc, 0);
   taille:= int(tailta(adlieu, succ(wdepla+ direc)));
   aordre:= depadr(adlieu, (wdepla+ direc));
   ordre(-1, -1, taille, 0, aordre, dumi, iobjet);
  end;
 end;
end;

{}

procedure tverbob(viobj, noobj, nverb: integer;
                  var key, numobj: integer;
                  iobjet: boolean);
const
 xafob= 271;
 yafob= 085;
 comy= 137;
 lgpx= 048;
 depx= 271;
 depy= 141;
 larg= 3;

var
 mnufic: integer;
 dum: long_integer;

begin
 debug('tverbob', 0, 0);
 viobj:= noobj;
 mnufic:= nufic;
 nufic:= tobje;
 if nverb<> 9 then
 begin
  (* deposer un objet de sur soi *)
  if nverb= 6 then
  begin
   nufic:= tgene;
   phidemou;
   if s.objet[numobj]= -1 then
   begin
    afobj(false, false, 0, -1, xafob, yafob, 1);
    actverb(-1, numobj, gmesob, 8, numobj,
                                   gobjet, adgene, numobj, iobjet);
   end;
   if (not perdu) and (not solu) then
   begin
    s.objet[numobj]:= s.mlieu;
    if noobj= -1 then tiroir;
    styleff(5, 6, (xafob- 2), (yafob- 2), (xafob+ lgpx), comy);
    menuobj;
   end;
   key:= -2;
   pshowmou;
  end
  else
  begin
   actverb(viobj, numobj, gmesob, nverb, numobj,
                                  gobjet, adgene, numobj, iobjet);
   if atkey<> 0 then
   begin
    key:= atkey;
    tkeyo(key);
   end;
  end;
 end
 else
 begin
  tfleche(true, -1, depx, depy, larg, numobj,
                                  gnbrob, gdecob, adgene, nzono, key);
  if key= 0 then
   actverb(viobj, numobj, gmesob, numobj, nzono, gtouch,
                                          adgene, numobj, iobjet);
  posmouse(304, 199, 0, 0, 304, 199);
 end;

 nufic:= mnufic;
end;

{}

procedure xacto(chai: integer; var action: boolean;
                var cx, key: integer; var dum: long_integer);
const
 cact= 32;
var
 bsta: integer;
 coax, coay: array[0..6] of integer;
 dum1: long_integer;
begin
(* debug('xacto', 0, 0); *)
 dum:= savmem(0, aecra1, atrava, 052, 102, 214, 189);

 coax[0]:= 64;
 coax[1]:= 100;
 coax[2]:= 136;
 coax[3]:= 172;
 coax[4]:= 81;
 coax[5]:= 117;
 coax[6]:= 153;
 
 coay[0]:= 111;
 coay[1]:= 111;
 coay[2]:= 111;
 coay[3]:= 111;
 coay[4]:= 147;
 coay[5]:= 147;
 coay[6]:= 147;
 {anihalt;}
 if memoire> mmini then
  dum1:= savmem(-15, aaob00, aecra1, 052, 102, 214, 189)
 else decomp(0, (atrava+ dum), aaob00, 0, 0, aecra1);
 if chai< 0 then decomp(0, (atrava+ dum), aaob09, 100, 112, aecra1);
 mloupe(amas04, 0, 0);
 styleff(5, 6, 052, 102, 214, 189);
 {anishow;}
 
 joueur(false, true, -1, bsta, key);

 if (acto<> -1) and (acto<> 16) then
 begin
  macto:= acto;
  bsta:= 2;
 end;
 if (bsta= 2) and (macto<> -1) then
 begin
  action:= true;
  cx:= macto;
 end
 else
  if bsta<> 0 then
  begin
   cx:= 0;
   repeat
    if (mouy> coay[cx]) and (mouy< (coay[cx]+ cact)) and
       (moux> coax[cx]) and (moux< (coax[cx]+ cact)) then
     action:= true
    else
     cx:= succ(cx);
   until (action) or (cx> 6);
  end;
end;

procedure xacto1(cx, chai: integer; dum: long_integer);
begin
(* debug('xacto1', 0, 0); *)
 mact:= cx;
 if cx= 00 then decomp(0, (atrava+ dum), aaob01, 0, 0, aecra2);
 if cx= 01 then
  if chai< 0 then decomp(0, (atrava+ dum), aaob08, 100, 112, aecra2)
   else decomp(0, (atrava+ dum), aaob02, 0, 0, aecra2);
 if cx= 02 then decomp(0, (atrava+ dum), aaob03, 0, 0, aecra2);
 if cx= 03 then decomp(0, (atrava+ dum), aaob04, 0, 0, aecra2);
 if cx= 04 then decomp(0, (atrava+ dum), aaob05, 0, 0, aecra2);
 if cx= 05 then decomp(0, (atrava+ dum), aaob06, 0, 0, aecra2);
 if cx= 06 then decomp(0, (atrava+ dum), aaob07, 0, 0, aecra2);
 vblsync(11);
 dum:= savmem(1, atrava, aecra1, 052, 102, 214, 189);
 styleff(5, 6, 052, 102, 214, 189);
 dum:= savmem(1, atrava, 0, 052, 102, 214, 189);
end;

{}

(* NIVEAU 4 *)
procedure aflieu(tout: boolean; lieu: integer);
const
 afx= 271;
 afy= 85;

var
 mnufic, cx, tot: integer;
 dum: long_integer;

begin
(* debug('aflieu', 0, 0);*)
 phidem;
 if tout then
 begin
  coupson; (* SON-ST *)
  (* chargt lieu + initialisation automatique + affichage ecran 1 *)
  xload(true, atrava, 0, 0, lieu, dum);
  xload(true, atrava, aoufer, 2, lieu, dum);   (* chargement ouvert-ferme *)
  adlieu:= aoufer+ dum;
  xload(true, atrava, adlieu, 1, lieu, dum);     (* chargement table-lieu *)

  initadr(adlieu);                      (* pour cumul table deplacement *)
  initpal(aoufer+peekw(depadr(adlieu, wadpal)));     (* adresse palette *)
  adanst:= adlieu+ dum;
(*  xload(true, atrava, adanst, 5, lieu, dum);*)  (* chargement anim statique *)

 end
 else xload(true, atrava, -1, 0, lieu, dum);

 tiroir;
(* if not s.cach then decomp(0, atrava, agen18, 0, 0, aecra1) else
  decomp(0, atrava, agen20, 0, 0, aecra1);*)

 main(cx);
 if cx<> -1 then afobj(false, false, 0, cx, afx, afy, 1);

 for cx:= 0 to nvali do
  if s.valid[s.mlieu, cx]> 0 then recdes(1, cx);

 tot:= pred(int(tailta(adlieu, succ(wdesval))));
 for cx:= 0 to tot do
  if peek(depadr(adlieu, wdesval)+ cx)> 0 then
   decomp(0, atrava,
    (aoufer+ peekw(depadr(adlieu, wdepdes)+ (cx* 2))), 0, 0, aecra1);

 if tout then
 begin
  if memoire> mmini then
  begin
   adanpe:= adanst+ dum;
   cx:= 0;
   dum:= 0;
   repeat
(*    xload(true, atrava, adanpe, (cx+ 6), lieu, dum);*)
                                       (* chargement anim personne *)
    adanpe:= adanpe+ dum;
    cx:= succ(cx);
   until (dum= 0) or (cx> 2);
  end;
 end;

 decomp(0, atrava, agen01, 0, 0, aecra1);
 mnufic:= nufic;
 nufic:=  tlieu;
 eftext(-1, 48, 02, 168, 8, 4, 1, aecra1, 0, succ(lieu));
 nufic:= mnufic;

 meppal;
 calch(s.nmin);
 if s.palet[lieu]= 0 then calcpal(false);
 chngmouse(0, 2);
 pshowm;
end;

{}

(*procedure aflieu(tout: boolean; lieu: integer);
const
 afx= 271;
 afy= 85;
var
 str, str1: str255;
 mnufic, cx, tot: integer;
 dum: long_integer;
begin
 faitnom(str, lieu);
 phidemou;
 tiroir;
 str1:= concat(nlofpa, str);
 mlect(str1, aoufer, adlieu);
 delete(str1, 1, length(str1));
 str1:= concat(ntlieu, str);
 mlect(str1, adlieu, dum);
 initadr(adlieu);  ( pour cumul table deplacement )
 main(cx);
 if cx<> -1 then afobj(false, false, 0, cx, afx, afy, 1);
 delete(str1, 1, length(str1));
 str1:= concat(ndlieu, str);
 lect(str1, adessi, dum);
 decomp(0, atrava, adessi, 0, 0, aecra1);
 for cx:= 0 to nvali do
  if s.valid[s.mlieu, cx]> 0 then recdes(1, cx);
 tot:= pred(int(tailta(adlieu, succ(wdesval))));
 for cx:= 0 to tot do
  if peek(depadr(adlieu, wdesval)+ cx)> 0 then
   decomp(0, atrava,
    (aoufer+ peekw(depadr(adlieu, wdepdes)+ (cx* 2))), 0, 0, aecra1);

 decomp(0, atrava, agen01, 0, 0, aecra1);
 mnufic:= nufic;
 nufic:=  tlieu;
 eftext(-1, 48, 02, 168, 8, 4, 1, aecra1, 0, succ(lieu));
 nufic:= mnufic;
 meppal;
 chngmouse(0, 2);
 pshowmou;
end; *)

procedure afzone(aff: boolean);
var
 adr: long_integer;
 xh, yh, xb, yb: long_integer; 
begin
(* debug('affichage', 0, 0);*)
 phidemou;
 adr:= affiche(aecra1, aoufer, depadr(adlieu, wdepdes),
               depadr(adlieu, wdesval), (atrava+ deptra),
               tailta(adlieu, succ(wdesval)));
 xh:= peekw(adr);
 if (xh<> 65535) and (xh<> 319) then
 begin
  yh:= peekw(adr+ 2);
  xb:= peekw(adr+ 4);
  yb:= peekw(adr+ 6);
  if aff then styleff(5, 6, xh, yh, xb, yb);
 end;
 pshowmou;
end;

procedure changanim;
var
 cx: integer;
 dum: long_integer;
begin
(* for cx:= 0 to nanim do
  if s.anim[s.mlieu, cx]> -1 then chngani(cx, s.anim[s.mlieu, cx], 0);
 xload(true, 0, 0, 9, 0, dum);*) (* init les blocs d'animation *)
end;

procedure pvoc(obj, cha: integer; var pobj, vobj, pcha, vcha: integer);
begin
 opv(obj, pobj, vobj);
 pcha:= int(peekw(depadr(adgene, gpdcha)+ (cha* 2)));
 vcha:= int(peekw(depadr(adgene, gvlcha)+ (cha* 2)));
end;

{}

procedure recplein(aecra: long_integer;
                   xd, yd, xf, yf, coul: integer);
var
 cx, nb: integer;

begin
 nb:= yf- yd;
 for cx:= 0 to nb do traclign(aecra, xd, (yd+ cx), xf, (yd+ cx), coul);
end;

{}

procedure templus(minute: integer);
var
 seconde: integer;

begin
(* debug('templus', 0, 0);*)
 seconde:= ((minute mod tmin)* 60)div tmin;
 s.rsec:= s.rsec+ seconde;
 minute:= minute div tmin;
 s.nmin:= s.nmin+ minute;
end;

{}

procedure tobjet;
const
 lgpx= 48;

 ha1y= 000;
 ha2y= 012;

 comx= 265;
 comy= 159;

 xsfin= 281;
 xifin= 305;
 ysfin= 170;
 yifin= 193;

 xafob= 271;
 yafob= 85;

var
 menu, action, enc, trouv, meme: boolean;
 men, cx, cy, bsta, key, mnufic, memob, typ, attend, lg: integer;
 adr, dum, dtemps: long_integer;
 copx: array[1..2] of integer;
 cmys: array[0..5] of integer;
 cmyi: array[0..5] of integer;

begin
(* debug('tobjet', 0, 0); *)
 chgtab:= false;
 iobjet:= true;

 mnufic:= nufic;
 nufic:= tobje;

 copx[1]:= 002;     (* suite *)
 copx[2]:= 268;     (* stop *)

 cmys[0]:= 001;     (* pourcentage *)
 cmys[1]:= 029;     (* attendre *)
 cmys[2]:= 055;     (* help *)
 cmys[3]:= 085;     (* objet main *)
 cmys[4]:= 113;     (* objet lieu *)
 cmys[5]:= 141;     (* resultat fouille *)

 cmyi[0]:= 027;     (* idem au dessus ... *)
 cmyi[1]:= 046;
 cmyi[2]:= 081;
 cmyi[3]:= 109;
 cmyi[4]:= 137;
 cmyi[5]:= 165;

 (* choix menu general *)
 bsta:= 0;
 key:= 0;
 acto:= -1;
 obj:= -1;

 if (atbsta= 0) and (atkey= 0) then e_mouse(moux, mouy, bsta, key) else
 begin
  if (atbsta<> 0) then
  begin
   moux:= atmoux;
   mouy:= atmouy;
   bsta:= atbsta;
  end;
  if atkey<> 0 then key:= atkey;
  atmoux:= 0;
  atmouy:= 0;
  atkey:= 0;
  atbsta:= 0;
 end;
 tinke(false, iobjet, -1, 0);
 if key<> 0 then tkeyo(key);

 if (not perdu) and (not solu) then
  repeat
   key:= 0;
   if acto<> -1 then
   begin
    macto:= acto;
    if acto= 16 then mmeno:= 5 else
     if acto= 15 then mmeno:= 10 else mmeno:= 8;
    bsta:= 2;
   end;
   if obj<> -1 then
   begin
    mobj:= succ(obj);
    mmeno:= 9;
    bsta:= 2;
   end;
   if bsta<> 0 then
   begin
    enc:= false;
    menu:= false;
    if (bsta= 2) and (mmeno<> -1) then
    begin
     men:= mmeno;
     enc:= true;
     menu:= true;
    end
    else
    begin
     (* menu horizontal *)
     if (mouy> ha1y) and (mouy< ha2y) then
     begin
      men:= 1;
      repeat
       if (moux> copx[men]) and (moux< (copx[men]+ lgpx)) then menu:= true
        else men:= succ(men);
      until (menu) or (men> 2);
     end;
     (* menu vertical *)
     if not menu then
     begin
      recver(comx, lgpx, moux, mouy, menu, men, attend);
      men:= men+ 3;
     end;
     (* fin *)
     if (not menu) and
        (moux> xsfin) and (moux< xifin) and
        (mouy> ysfin) and (mouy< yifin) then stopjeu(iobjet);
    end;
 
    if menu then
    begin
     (* suivant *)
     if men= 1 then
     begin
debug('suite', 0, 0);
      phidemou;
(*      barmen(comx, lgpx, men, iobjet);*)
      men:= 0;
(*      decomp(0, atrava, agen24, 0, 0, aecra1);*)
      movblk(aecra1, aecra2, copx[1], ha1y, (copx[1]+ lgpx), ha2y);
      mmeno:= 1;
      trouv:= false;
      numobj:= succ(numobj);
      if chai< 0 then dum:= nbobj else dum:= maxob;
      while (numobj<= dum) and (not trouv) do
       if chai< 0 then
       begin
        if objso[numobj]<> -1 then trouv:= true
         else numobj:= succ(numobj);
       end
       else
       begin
        if s.objet[numobj]= chai then trouv:= true
         else numobj:= succ(numobj);
       end;
      if trouv then
      begin
       if chai< 0 then
       begin
        memob:= objso[numobj];
        typ:= 4;
       end
       else
       begin
        memob:= numobj;
        typ:= 3;
       end;
       afobj(true, true, 0, memob, comx, comy, typ);
      end;
(*      barmen(comx, lgpx, men, iobjet);*)
      men:= 0;
      pshowmou;
     end;
     (* stop *)
     if men= 2 then
     begin
debug('stop', 0, 0);
      phidemou;
(*      decomp(0, atrava, agen25, 0, 0, aecra1);*)
      movblk(aecra1, aecra2, copx[2], ha1y, (copx[2]+ lgpx), ha2y);
      pshowmou;
      stop:= true;
     end;
     (* pourcentage *)
     if men= 3 then
     begin
      mmeno:= 3;
      phidemou;
      afpour;
(*      barmen(comx, lgpx, men, iobjet); *)
      men:= 0;
      pshowmou;
     end;
     (* attendre *)
     if men= 4 then
     begin
      mmeno:= 4;
      if bsta= 2 then
      begin 
       moux:= atmoux;
       mouy:= atmouy;
       recver(comx, lgpx, moux, mouy, menu, men, attend);
      end;
      if attend<> -1 then
      begin
       cx:= 0;
       phidemou;
       repeat
        templus(5);
        tinke(false, iobjet, -1, 1);
        cx:= succ(cx);
       until (cx> attend) or (perdu) or (solu);
       pshowmou;
       atmoux:= moux;
       atmouy:= mouy;
       men:= 0;
       bsta:= 0;
       atbsta:= 0;
       atkey:= 0;
       attend:= -1;
      end;
     end;
     (* help *)
     if men= 5 then
     begin
      mmeno:= 5;
      if memoire> mmini then bruiergo(6, -7);     (* SON-ST *)
      phidemou;
(*      decomp(0, atrava, agen16, 0, 0, aecra1);*)
      movblk(aecra1, aecra2, comx, cmys[2], (comx+ lgpx), cmyi[2]);
      if chai< 0 then cx:= objso[numobj] else cx:= numobj;
      (* remise a zero zone texte *)
      lg:= pred(int(azmasq- adessi));
      for cy:= 0 to lg do poke((adessi+ cy), 0);
      (* chargement texte *)
      adr:= adessi+ 2;
      xload(false, atrava, adr, cx, 1, dum);
      pokew(adessi, dum);
(*      dum:= savmem(1, asgen14, aecra1, 004, 162, 266, 199);*)
      dum:= aftext(25, adr, adessi, adtext, aecra1,
                                            9, 166, 250, 8, 0, 1, 0, 1);
      dum:= aftext(25, adr, adessi, adtext, aecra1,
                                            8, 166, 250, 8, 0, 1, 0, 1);
      dum:= aftext(25, adr, adessi, adtext, aecra1,
                                            8, 165, 250, 8, 15, 1, 0, 1);
      styleff(5, 6, 004, 162, 266, 199);
      posmouse(304, 164, 0, 0, 304, 164);
      atclick(0, true);
      posmouse(304, 199, 0, 0, 304, 199);
(*      decomp(0, atrava, agen15, 0, 0, aecra1);*)
      movblk(aecra1, aecra2, comx, cmys[2], (comx+ lgpx), cmyi[2]);
(*      barmen(comx, lgpx, men, iobjet); *)
      men:= 0;
      pshowmou;
     end;
     (* objet sur soi *)
     if men= 6 then
     begin
      mmeno:= 6;
      if not ifouil then
      begin
       objsoi(numobj, noobj, iobjet);
       if (not perdu) and (not arret) and (not solu) then
       begin
(*        barmen(comx, lgpx, men, iobjet);*)
        men:= 0;
       end;
      end
      else menuobj;
     end;
     (* action tentee sur tiroir *)
     if men= 7 then menuobj;
     (* action sur objet fouille *)
     if men= 8 then
     begin
      dtemps:= peekw(aheure);
      action:= false;
      phidemou;
      if not enc then xacto(chai, action, cx, key, dum) else
      begin
       action:= true;
       cx:= macto;
      end;
      pokew(aheure, dtemps);
      if action then
      begin
       if memoire> mmini then bruiergo(2, -7);    (* SON-ST *)
       mmeno:= 8;
       phidemou;
       if not enc then xacto1(cx, chai, dum);
       if cx= 06 then xacto2;
       macto:= cx;
       (* concordance ecran/table *)
       if cx= 0 then cy:= 2;
       if cx= 1 then
        if chai< 0 then cy:= 6 else cy:= 5;
       if cx= 2 then cy:= 0;
       if cx= 3 then cy:= 1;
       if cx= 4 then cy:= 4;
       if cx= 5 then cy:= 3;
       if cx= 6 then cy:= 9;
       pshowmou;
       repeat
        acto:= -1;
        meme:= false;
        main(omain);
        if chai< 0 then
        begin
         memob:= objso[numobj];
         tverbob(viobj, noobj, cy, key, objso[numobj], iobjet);
         if memob= objso[numobj] then meme:= true;
        end
        else
        begin
         memob:= numobj;
         tverbob(viobj, noobj, cy, key, numobj, iobjet);
         if memob= numobj then meme:= true;
        end;
        (* pour prendre ou poser dans une chaine *)
        main(cy);
        if meme then
        begin
         if (cy<> omain) or (key= -2) then
         begin
          mmeno:= 1;
          bsta:= 2;
          key:= -1;
         end;
        end;
        (* nouvelle action demandee *)
        if acto<> -1 then
        begin
         key:= -1;
         if acto< 15 then
         begin
          macto:= acto;
          cx:= acto;
          if cx= 06 then xacto2;
          (* concordance ecran/table *)
          if cx= 0 then cy:= 2;
          if cx= 1 then
           if chai< 0 then cy:= 6 else cy:= 5;
          if cx= 2 then cy:= 0;
          if cx= 3 then cy:= 1;
          if cx= 4 then cy:= 4;
          if cx= 5 then cy:= 3;
          if cx= 6 then cy:= 9;
         end;
        end;
       until (acto= -1) or (acto= 15) or (acto= 16);
(*       if (not perdu) and (not solu)
        then barmen(comx, lgpx, men, iobjet) else *) key:= 0;
      end
      else
      begin
       (* debug('fin sans action', 0, 0); *)
       dum:= savmem(1, atrava, aecra1, 052, 102, 214, 189);
       styleff(5, 6, 052, 102, 214, 189);
       dum:= savmem(1, atrava, 0, 052, 102, 214, 189);
(*       menuobj;*)
      end;
      pshowmou;
     end;
     (* nouvel objet en main *)
     if men= 9 then
     begin
      if memoire> mmini then bruiergo(3, -7);     (* SON-ST *)
      phidemou;
      nvobjma(cx, iobjet);
      if (not perdu) and (not solu) then
      begin
       afobj(true, true, 0, cx, xafob, yafob, 1);
(*       barmen(comx, lgpx, men, iobjet); *)
       main(omain);
       pshowmou;
      end;
     end;
     (* deposer objet en main *)
     if men= 10 then
     begin
      phidemou;
      if memoire> mmini then bruiergo(2, -7);     (* SON-ST *)
      tdepo(key, noobj, iobjet);
      (* si objet sur main evt passage objet suivant) *)
      if chai< 0 then
      begin
       if (key= objso[numobj]) then
       begin
        acto:= -1;
        mmeno:= 1;
        bsta:= 2;
        key:= -1;
       end
       else key:= 0;
      end
      else key:= 0;
      if (not perdu) and (not solu) then
      begin
(*       barmen(comx, lgpx, men, iobjet);*)
       men:= 0;
      end
      else menuobj;
      pshowmou;
     end;
    end;
   end;
  until key= 0;
 iobjet:= false;
 nufic:= mnufic;
end;

{}

(* NIVEAU *)
procedure actobse(min, sorte: integer;
                  iobjet:boolean);
var
 posev: integer;
 taille, depla, dumi: integer;
 aordre: long_integer;

begin
(* debug('actobse', 0, 0); *)
 if (not perdu) and (not solu) then
 begin
  nufic:= tobse;
  posev:= recpos(min, wobsem);
  
  taille:= int(tailta(adlieu, succ(wobsem)));
debug('taille1', 0, taille);

  if (posev< taille) then
  begin
   if min= int(peekw(depadr(adlieu, wobsem)+ posev)) then
   begin
    depla:= int(peekw(depadr(adlieu, wobsed)+ posev));
    taille:= int(peekw(depadr(adlieu, wobsed)+ posev+ 2))- depla;
debug('taille2', 0, taille);
    aordre:= depadr(adlieu, wobseo)+ depla;
    ordre(-1, -1, taille, sorte, aordre, dumi, iobjet);
    posev:= posev+ 2;
   end
   else
   begin
    nufic:= tamoi;
    mess1(51); 
   end;
  end
  else
  begin
   nufic:= tamoi;
   mess1(51); 
  end;

(*  ortemps(adlieu, min, wobsem, wobsed, 
                       wobseo, 0, posev, iobjet);*)

  s.posob[s.mlieu]:= min;
  nufic:= tgene;
 end;
end;

{}

procedure animat(sorte: integer;
                 entre: boolean;
                 var lg: integer;
                 aordre: long_integer);
var
 lieu, numani, zon: integer;

begin
(* debug('animat', 0, 0); *)
 lieu:= int(peek(succ(aordre+ lg)));
 numani:= int(peek(aordre+ lg+ 2));
 lg:= lg+ 3;
 zon:= int(peek(aordre+ lg));
 while zon<> 255 do
 begin
  s.valid[lieu, zon]:= succ(s.valid[lieu, zon]);
  if (s.mlieu= lieu) and (s.valid[lieu, zon]= 1) then recdes(17, zon);
  lg:= succ(lg);
  zon:= int(peek(aordre+ lg));
 end;
 lg:= succ(lg);
 zon:= int(peek(aordre+ lg));
 while zon<> 255 do
 begin
  s.valid[lieu, zon]:= pred(s.valid[lieu, zon]);
  if (s.mlieu= lieu) and (s.valid[lieu, zon]= 0) then recdes(16, zon);
  lg:= succ(lg);
  zon:= int(peek(aordre+ lg));
 end;
 if sorte< 2 then
 begin
  if memoire> mmini then
  begin
   if not entre then afzone(false);
(*   if (s.mlieu= lieu) then blocani(numani, 0, 0); *)
   if entre then afzone(false);
  end
  else afzone(true);
 end;
 lg:= succ(lg);
end;

{}

procedure btemps(tdep, tarr, bgene, blieu: integer;
                 iobjet: boolean);
var
 min: integer;

begin
(* debug('btemps', 0, 0);*)
 for min:= tdep to tarr do
  if (not arret) and (not perdu) and (not solu) then
  begin
   if bgene> -1 then actgene(min, bgene, iobjet);
   if blieu> -1 then actlieu(min, blieu, iobjet);
  end;
end;

{}

procedure chpv(chai: integer; var cpoid, cvolu: integer);
var
 cx, pobj, vobj: integer;
begin
 cpoid:= 0;
 cvolu:= 0;
 for cx:= 0 to maxob do
  if s.objet[cx]= chai then
  begin
   opv(cx, pobj, vobj);
   cpoid:= cpoid+ pobj;
   cvolu:= cvolu+ vobj;
  end;
end;

procedure diskinit(tem: boolean);
const
 lmind2= 17;
var
 dum, dtemps: long_integer;
 mes: boolean;
 val, cz0, cz1, cz2: integer;
begin
 if tem then dtemps:= peekw(aheure);
 repeat
  mes:= false;
(*  dum:= testdisk;*)
  if (s.mlieu< lmind2) and (dum<> 2) then
  begin
   val:= 2;
   mes:= true;
  end;
  if (s.mlieu> pred(lmind2)) and (dum<> 3) then
  begin
   val:= 3;
   mes:= true;
  end;
  if mes then
  begin
(*   dum:= savmem(1, asgen14, aecra1, 004, 162, 266, 199);*)
   eftext(25, 8, 165, 250, 8, 15, 1, aecra1, 0, 18);
   efchif(val, -2, 128, 174, 25, 8, 15, aecra1);
   styleff(5, 6, 004, 162, 266, 199);
   showmouf;
   cz1:= 0;
   cz2:= 0;
   repeat
    e_mouse(cz0, cz0, cz1, cz2);
   until (cz1<> 0) or (cz2<> 0);
   hidemouf;
  end;
 until not mes;
 if tem then pokew(aheure, dtemps);
end;

procedure majval;
var
 cx: integer;
begin
 for cx:= 0 to nvali do
 begin
  s.valid[s.mlieu, cx]:= s.valid[s.mlieu, cx]+ s.valfon[cx];
  s.valfon[cx]:= 0;
 end;
end;

procedure memplus(sav: boolean;
                  var adres: long_integer;
                  nufic, fond, xh, yh, xb, yb: integer);
var
 longueur: long_integer;
 coax, coay: array[0..3] of integer;
 cy, cz: integer;
begin
(* debug('memplus', 0, 0); *)
 adres:= adtext;
 xload(false, atrava, adres, nufic, 8, longueur);
 if memoire> mmini then
 begin
  sav:= true;
  recplein(aecra1, 0, 0, 319, 199, fond);
  decomp(0, atrava, adres, 0, 0, aecra1);

  (* petit menu action -> mise en place des boutons *)
  if adres= agen26 then
  begin
   coax[0]:= 091;
   coax[1]:= 109;
   coax[2]:= 127;
   coax[3]:= 145;
   coay[0]:= 107;
   coay[1]:= 125;
   coay[2]:= 143;
   coay[3]:= 161;
(*   for cy:= 0 to 3 do
    for cz:= 0 to 3 do
     decomp(0, atrava, agen27, coax[cy], coay[cz], aecra1);*)
  end;

  longueur:= savmem(0, aecra1, adres, xh, yh, xb, yb);
 end;
 if sav then
 begin
  adtext:= adtext+ longueur;
  adessi:= adessi+ longueur;
  amempa:= amempa+ longueur;
  azmasq:= azmasq+ longueur;
  atrava:= atrava+ longueur;
  adesou:= adesou+ longueur;
  aoblo:= aoblo+ longueur;
  axoblo:= axoblo+ longueur;
  ayoblo:= ayoblo+ longueur;
  aoufer:= aoufer+ longueur;
 end;
end;

{}

procedure moduobj(var iobjet, efouill: boolean;
                  chai, mvid, mple, mfin, viobj, noobj: integer);
const
 obx= 265;
 oby= 159;
 voby= 095;

var
 stop, prem: boolean;
 cx, mnufic: integer;
 dum: long_integer;

begin
 debug('moduobj', 0, 0);
 mnufic:= nufic;
 nufic:= tgene;
 prem:= false;
 cx:= 0;
 repeat
  if s.objet[cx]= chai then prem:= true else cx:= succ(cx);
 until (cx> maxob) or (prem);
 if prem then
 begin
  phidem;
  mess1(mple);
  if noobj<> -1 then afobj(false, false, 0, noobj, obx, voby, 2);
(* affichage nouvelle ergonomie sukiya pour objet *)
  decomp(0, atrava, agen06, 0, 0, aecra1);
  pendule(true, 1);

(* traitement menu  objet *)
  afobj(false, false, 0, cx, obx, oby, 3);
  styleff(5, 6, (obx- 2), (voby- 2), 320, (oby+ 38));
  nomob(cx);
  menuobj;
  pshowm;
  stop:= false;
  mmeno:= 0;
  macto:= 0;
  repeat
   tobjet(cx, stop, iobjet, chai, viobj, noobj);
  until (cx> maxob) or (stop) or (perdu) or (arret) or (solu);
  if (not perdu) and (not arret) and (not solu) then
  begin
   phidem;
(* debug('moduobj viobj', viobj, 0); *)
   if viobj<> -1 then afobj(false, false, 0, viobj, obx, voby, 2)
    else tiroir;
(* debug('moduobj noobj', noobj, 0); *)
   if noobj<> -1 then afobj(false, false, 0, noobj, obx, oby, 3)
    else (* decomp(0, atrava, agen17, 0, 0, aecra1) *);

   (* affichage nouvelle ergonomie sukiya pour objet *) 
   decomp(0, atrava, agen04, 0, 0, aecra1);
   pendule(true, 0);

   styleff(5, 6, (obx- 2), (voby- 2), 320, (oby+ 38));

   if noobj= -1 then mess1(mfin) else nomob(noobj);
   pshowm;
   gobj2:= viobj;
   efouill:= true;
  end;
 end
 else mess1(mvid);
 nufic:= mnufic;
 debug('fin moduobj', 0, 0);
end;

{}

procedure pasbondk;
var
 cz0, cz1, cz2: integer;
 dtemps: long_integer;
begin
 dtemps:= peekw(aheure);
 mess1(2);
 showmouf;
 cz1:= 0;
 cz2:= 0;
 repeat
  e_mouse(cz0, cz0, cz1, cz2);
 until (cz1<> 0) or (cz2<> 0);
 hidemouf;
 pokew(aheure, dtemps);
end;

procedure procini(sorte: integer;
                  iobjet: boolean);
var
 taille, dumi: integer;
 aordre: long_integer;
begin
(* debug('procini', 0, 0) *)
 if (not perdu) and (not solu) then
 begin
  taille:= int(tailta(adlieu, succ(winitia)));
  aordre:= depadr(adlieu, winitia);
  ordre(-1, -1, taille, sorte, aordre, dumi, iobjet);
 end;
end;

procedure slire(page, mdessin, dep: integer; afp: boolean);
var
 dessin, nphr, coul, intl, gras: integer;
 cx, nbtext, coox, cooy, larg, haut, mnufic: integer;
 dummy, prop, just, cadr: long_integer;
begin
(* debug('slire', 0, 0);*)
 mnufic:= nufic;
 nufic:= tlire;
 phidemou;
 dessin:= int(peek(depadr(adgene, glectu+ (page* 9))));
 if dessin<> mdessin then
 begin
  mdessin:= dessin;
  if afp then xload(false, atrava, adessi, dessin, 3, dummy);
 end;
 if afp then
 begin
  (* dep= 0 -> lire ou assom ou fin; autre -> mort *)
  if dep= 0 then
  begin
(*   decomp(0, atrava, agen29, 0, 0, aecra1);*)
   decomp(0, atrava, adessi, 0, 0, aecra1);
  end
  else decomp(0, (adessi+ dep), adessi, 0, 0, aecra1);
 end;
 nbtext:= int(peek(succ(depadr(adgene, glectu+ (page* 9)))));
 for cx:= 0 to nbtext do
 begin
  nphr:= int(peekw(depadr(adgene, glnute+ (page* 9))+ (cx *2)));
  nphr:= succ(nphr);
  coul:= int(peek(depadr(adgene, glcoul+ (page* 9))+ cx));
  intl:= int(peek(depadr(adgene, glinte+ (page* 9))+ cx));
  cadr:= peekb((depadr(adgene, glcara+ (page* 9))+ cx), 0);
  prop:= peekb((depadr(adgene, glcara+ (page* 9))+ cx), 2);
  prop:= prop* 65536;
  just:= peekb((depadr(adgene, glcara+ (page* 9))+ cx), 3);
  if just= 1 then cadr:= -1;
  cadr:= cadr+ prop;
  gras:= int(peekb((depadr(adgene, glcara+ (page* 9))+ cx), 4));
  coox:= int(peekw(depadr(adgene, glcoox+ (page* 9))+ (cx* 2)));
  cooy:= int(peekw(depadr(adgene, glcooy+ (page* 9))+ (cx* 2)));
  larg:= int(peekw(depadr(adgene, gllarg+ (page* 9))+ (cx* 2)));
  haut:= int(peekw(depadr(adgene, glhaut+ (page* 9))+ (cx* 2)));
  if gras= 1 then
   eftext(haut, coox, cooy, larg, intl, coul, cadr, aecra1, 0, nphr)
  else
   just:= aftext(haut, atext2, along2, adtext, aecra1,
                 coox, cooy, larg, intl, coul, cadr, 0, nphr);
 end;
 styleff(4, 6, 000, 000, 319, 199);
 pshowmou;
 nufic:= mnufic;
end;

procedure sopv(var spoid, svolu: integer);
var
 cx, pobj, vobj: integer;
begin
 spoid:= 0;
 svolu:= 0;
 for cx:= 0 to maxob do
  if (s.objet[cx]< 0) and (s.objet[cx]> -6) then
  begin
   opv(cx, pobj, vobj);
   spoid:= spoid+ pobj;
   svolu:= svolu+ vobj;
  end;
end;

(* NIVEAU 3 *)
procedure esipaer(sorte: integer;
                  var lg, numobj: integer;
                  aordre: long_integer;
                  bon, iobjet: boolean;
                  viobj, noobj: integer);                   (* 000 *)
var
 taille: integer;
begin
(* debug('si pas erreur', 0, 0);*)
 taille:= int(peekw(succ(aordre+ lg)));
 if bon then
  ordre(viobj, noobj, taille, sorte, (aordre+ lg+ 3), numobj, iobjet);
 lg:= lg+ 3+ taille;
end;

procedure esier(sorte: integer;
                var lg, numobj: integer;
                aordre: long_integer;
                bon, iobjet: boolean;
                viobj, noobj: integer);                     (* 001 *)
var
 taille: integer;
begin
(* debug('si erreur', 0, 0);*)
 taille:= int(peekw(succ(aordre+ lg)));
 if not bon then
  ordre(viobj, noobj, taille, sorte, (aordre+ lg+ 3), numobj, iobjet);
 lg:= lg+ 3+ taille;
end;

procedure eafmess(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 002 *)
var
 mess: integer;
begin
(* debug('affichage message', 0, 0);*)
 if sorte< 2 then
 begin
  mess:= int(peekw(succ(aordre+ lg)));
  mess1(mess);
 end;
 lg:= lg+ 3;
end;

{}

procedure edplace(sorte: integer;
                  var lg: integer;
                  aordre: long_integer;
                  iobjet: boolean);                         (* 003 *)
var
 tdep, tarr, minute: integer;

begin
 if sorte< 2 then
 begin
  phidem;
  pexitani;
  majval;
  s.mlieu:= int(peek(succ(aordre+ lg)));
  minute:= int(peekw(aordre+ lg+ 2));
  aflieu(true, s.mlieu);
  tdep:= succ(s.posml[s.mlieu]);
  tarr:= s.nmin;
  btemps(tdep, tarr, -1, 3, iobjet);
  tdep:= succ(s.nmin);
  templus(minute);
  tarr:= s.nmin;
  s.mmin:= s.nmin;
  btemps(tdep, tarr, 2, 3, iobjet);
  if (not perdu) and (not solu) then
  begin
   afzone(false);
   changanim;
   pamb(peekw(depadr(adlieu, wambian)));    (* SON-ST *)
   styleff(4, -1, 0, 0, 319, 199);
   calcamb;                                 (* SON-ST *)
   pinitani;
   calch(s.nmin);
   pendule(false, 0);
   procini(sorte, iobjet);
  end;
  chgtab:= true;
  pshowm;
 end;
 lg:= lg+ 4;
end;

{}

procedure emort(sorte: integer;
                var lg: integer;
                aordre: long_integer);                      (* 004 *)
var
 dtemps: long_integer;
 page, mdessin, mnufic: integer;

begin
(* debug('mort', 0, 0);*)
 if sorte< 3 then
 begin
  pexitani;
  coupson;                              (* SON-ST *) 
(*  pourcent(85); *)                        (* SON-ST *)
  if memoire> mmini then
  begin
   musique(47, -4);                     (* SON-ST *)
   temprio;
  end;
  musique(hazard(90, 93), -4);          (* SON-ST *)
  chngmouse(3, 5);
  perdu:= true;
 end;
 mnufic:= nufic;
 nufic:= tlire;
 dtemps:= peekw(aheure);
 mdessin:= -1;
 lg:= succ(lg);
 page:= int(peek(aordre+ lg));
 repeat
  if sorte< 3 then
  begin
   slire(page, mdessin, 22000, true);
   atclick(3, false);
  end;
  lg:= succ(lg);
  page:= int(peek(aordre+ lg));
 until page= 255;
 coupson;                               (* SON-ST *)
 pourcent(65);                          (* SON-ST *)
 lg:= succ(lg);
 pokew(aheure, dtemps);
 nufic:= mnufic;
end;

{}

procedure eassom(sorte: integer;
                 var lg: integer;
                 aordre: long_integer;
                 iobjet: boolean);                          (* 005 *)
var
 tout: boolean;
 dtemps, adres: long_integer;
 cx, lieu, tdep, tarr, page, mdessin, mnufic, minute: integer;
begin
(* debug('perte de conscience', 0, 0); *)
 if sorte< 2 then
 begin
  chngmouse(3, 5);
  mnufic:= nufic;
  nufic:= tlire;
  dtemps:= peekw(aheure);
  mdessin:= -1;
  pexitani;
  affmen09;
  if s.palet[s.mlieu]= 0 then
  begin
   calch(s.nmin);
   calcpal(true);
  end;
  domort(0, amempa);
  adres:= aoufer+ peekw(depadr(adlieu, wadpal));
  for cx:= 0 to 2 do pokel((amempa+ (cx* 4)), peekl(adres+ (cx* 4)));
  adres:= aoufer+ peekw(depadr(adlieu, wadpal))+ (3* 32);
  for cx:= 3 to 7 do pokel((amempa+ (cx* 4)), peekl(adres+ (cx* 4)));
  remapec(depadr(adlieu, wremas), 156, 258, 12, 8, aecra1, aecra1);
  page:= int(peek(succ(aordre+ lg)));
  slire(page, mdessin, 0, false);
  atclick(3, false);
  nufic:= mnufic;
  pokew(aheure, dtemps);
  lieu:= int(peek(aordre+ lg+ 2));
  majval;
  if lieu= s.mlieu then tout:= false else
  begin
   tout:= true;
   s.mlieu:= lieu;
  end;
  minute:= int(peekw(aordre+ lg+ 3));
  aflieu(tout, s.mlieu);
  tdep:= succ(s.posml[s.mlieu]);
  tarr:= s.nmin;
  btemps(tdep, tarr, -1, 3, iobjet);
  tdep:= succ(s.nmin);
  templus(minute);
  tarr:= s.nmin;
  s.mmin:= s.nmin;
  btemps(tdep, tarr, 2, 4, iobjet); (* 4 pour stopani *)
  if (not perdu) and (not solu) then
  begin
   afzone(false);
   changanim;
   styleff(1, 0, 0, 0, 319, 199);
   domort(1, amempa);
   pamb(peekw(depadr(adlieu, wambian)));    (* SON-ST *)
   calcamb;                                 (* SON-ST *)
   pinitani;
   calch(s.nmin);
   if iobjet then pendule(false, 1) else pendule(false, 0);
   procini(sorte, iobjet);
  end;
  if tout then chgtab:= true;
 end;
 lg:= lg+ 5;
end;

procedure eaugtps(sorte: integer;
                  var lg: integer;
                  aordre: long_integer;
                  iobjet: boolean);                         (* 006 *)
var
 tdep, tarr, minute: integer;
begin
(* debug('temps qui passe', 0, 0);*)
 if sorte< 2 then
 begin
  tdep:= succ(s.nmin);
  minute:= int(peekw(succ(aordre+ lg)));
  templus(minute);
  tarr:= s.nmin;
  s.mmin:= s.nmin;
  btemps(tdep, tarr, 2, 3, iobjet);
  afzone(true);
  if (not perdu) and (not solu) then
  begin
   calch(s.nmin);
   if iobjet then pendule(false, 1) else pendule(false, 0);
  end;
 end;
 lg:= lg+ 3;
end;

procedure eparler(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 007 *)
const
 depx= 8;
 depy= 8;
 lgx= 95;
 lgy= 84;
var
 trouv: boolean;
 num, cx, cy, mtete, tete, mess, coox, cooy: integer;
 dum, dummy, valrem, adres: long_integer;
begin
(* debug('parler', 0, 0);*)
 mtete:= -1;
 if sorte= 0 then
 begin
  phidemou;
  {anihalt;}
  coox:= int(peekw(succ(aordre+ lg)));
  cooy:= int(peekw(aordre+ lg+ 3));
  dum:= savmem(0, aecra1, atrava, coox, cooy, (coox+ lgx), (cooy+ lgy));
  (* charge le tour  *)
  xload(false, (atrava+ dum), adessi, 0, 4, dummy);
  decomp(0, (atrava+ dum), adessi, coox, cooy, aecra1);
 end;
 cx:= 5;
 tete:= int(peek(aordre+ lg+ cx));
 repeat
  if sorte= 0 then
  begin
   mess:= int(peekw(aordre+ lg+ succ(cx)));
   if tete<> mtete then
   begin
    num:= ((tete div 4)* 4)+ 4;
    adres:= adessi;
    trouv:= false;
    valrem:= 0;
    (* charge palette remap *)
    xload(false, (atrava+ dum), adres, num, 4, dummy);
    num:= int(peek(adres));
(*debug('nbre de rema: ', num, 0);*)
    adres:= succ(adres);
    if num<> 0 then
    begin
     cy:= 0;
     repeat
(*debug('num des lieux: ', 0, peek(adres+ cy));*)
      if peek(adres+ cy)= s.mlieu then trouv:= true else cy:= succ(cy);
     until (cy>= num) or (trouv);
     if trouv then
     begin
      valrem:= arempe;
      adres:= adres+ num+ (cy* 16);
(*for cy:= 0 to 15 do debug('val remap: ', 0, peek(adres+cy)); *)
      for  cy:= 0 to 15 do poke((arempe+ cy), peek(adres+ cy));
     end;
    end;
    xload(false, (atrava+ dum), adessi, succ(tete), 4, dummy);
    decomp(valrem, (atrava+ dum), adessi,
                                  (coox+ depx), (cooy+ depy), aecra1);
    mloupe(amas11, coox, cooy);
    styleff(5, 6, coox, cooy, (coox+ lgx), (cooy+ lgy));
    {anishow;}
   end;
   mess1(mess);
   mtete:= tete;
  end;
  cx:= cx+ 3;
  tete:= int(peek(aordre+ lg+ cx));
 until tete= 255;
 if sorte= 0 then
 begin
  dum:= savmem(1, atrava, aecra1, coox, cooy, (coox+ lgx), (cooy+ lgy));
  styleff(5, 6, coox, cooy, (coox+ lgx), (cooy+ lgy));
  dum:= savmem(1, atrava, 0, coox, cooy, (coox+ lgx), (cooy+ lgy));
  pshowmou;
 end;
 lg:= lg+ succ(cx);
end;

function evalzon(var lg: integer;
                 aordre: long_integer): boolean;            (* 008 *)
var
 lieu, zon: integer;
begin
(* debug('valide zone', 0, 0);*)
 evalzon:= true;
 lieu:= int(peek(succ(aordre+ lg)));
 zon:= int(peek(aordre+ lg+ 2));
 if s.valid[lieu, zon]> 0 then evalzon:= false;
 s.valid[lieu, zon]:= succ(s.valid[lieu, zon]);
 if (s.mlieu= lieu) and (s.valid[lieu, zon]= 1) then recdes(17, zon);
 lg:= lg+ 3;
end;

function edvalzo(var lg: integer;
                 aordre: long_integer): boolean;            (* 009 *)
var
 lieu, zon: integer;
begin
(* debug('devalide zone', 0, 0);*)
 edvalzo:= true;
 lieu:= int(peek(succ(aordre+ lg)));
 zon:= int(peek(aordre+ lg+ 2));
 if s.valid[lieu, zon]< 1 then edvalzo:= false;
 s.valid[lieu, zon]:= pred(s.valid[lieu, zon]);
 if (s.mlieu= lieu) and (s.valid[lieu, zon]= 0) then recdes(16, zon);
 lg:= lg+ 3;
end;

function etvalzo(var lg: integer;
                 aordre: long_integer): boolean;            (* 010 *)
var
 lieu, zon: integer;
begin
(* debug('test de validite', 0, 0);*)
 etvalzo:= true;
 lieu:= int(peek(succ(aordre+ lg)));
 zon:= int(peek(aordre+ lg+ 2));
 if s.valid[lieu, zon]= 0 then etvalzo:= false;
 lg:= lg+ 3;
end;

procedure eaffval(sorte: integer;
                  var lg: integer);                         (* 011 *)
begin
(* debug('affichage des zones', 0, 0);*)
 if sorte< 2 then afzone(true);
 lg:= succ(lg);
end;

function eajobj(sorte: integer;
                var lg: integer;
                aordre: long_integer;
                iobjet: boolean): boolean;                  (* 012 *)
var
 pobj, vobj, pcha, vcha, cha, chai: integer;
 objm, obj, cpoid, cvolu, dumi: integer;
begin
(* debug('ajoute objet ds chaine', 0, 0);*)
 if sorte< 3 then
 begin
  eajobj:= false;
  cha:= int(peekw(succ(aordre+ lg)));
  chai:= cha- dchob;
  obj:= int(peek(aordre+ lg+ 3));
  pvoc(obj, chai, pobj, vobj, pcha, vcha);
  chpv(cha, cpoid, cvolu);
  if ((pobj+ cpoid)<= pcha) and
     ((vobj+ cvolu)<= vcha) then
  begin
   if sorte< 2 then
   begin
    main(objm);
    if objm= obj then actverb(-1, obj, gmesob, 7, obj,
                                       gobjet, adgene, dumi, iobjet);
   end;
   eajobj:= true;
   s.objet[obj]:= cha;
  end;
 end;
 lg:= lg+ 4;
end;

function eretobj(sorte: integer;
                 var lg: integer;
                 aordre: long_integer): boolean;            (* 013 *)
var
 pobj, vobj, dum, cha, chai, obj: integer;
begin
(* debug('retire objet ds chaine', 0, 0);*)
 if sorte< 3 then
 begin
  eretobj:= false;
  cha:= int(peekw(succ(aordre+ lg)));
  obj:= int(peek(aordre+ lg+ 3));
  if s.objet[obj]= cha then
  begin
   eretobj:= true;
   s.objet[obj]:= obnul;
  end;
 end;
 lg:= lg+ 4;
end;

function etesapp(var lg: integer;
                 aordre: long_integer): boolean;            (* 014 *)
var
 cha, obj: integer;
begin
(* debug('test appartenance chaine', 0, 0);*)
 etesapp:= false;
 cha:= int(peekw(succ(aordre+ lg)));
 obj:= int(peek(aordre+ lg+ 3));
 if s.objet[obj]= cha then etesapp:= true;
 lg:= lg+ 4;
end;

function eteslie(var lg: integer;
                 aordre: long_integer): boolean;            (* 015 *)
var
 lieu: integer;
begin
(* debug('test lieu', 0, 0);*)
 eteslie:= false;
 lg:= succ(lg);
 lieu:= int(peek(aordre+ lg));
 repeat
  if s.mlieu= lieu then eteslie:= true;
  lg:= succ(lg);
  lieu:= int(peek(aordre+ lg));
 until lieu= 255;
 lg:= succ(lg);
end;

procedure evaldep(var lg: integer;
                  aordre: long_integer);                    (* 016 *)
var
 lieu, dep: integer;
begin
(* debug('valide depl', 0, 0);*)
 lieu:= int(peek(succ(aordre+ lg)));
 dep:= int(peek(aordre+ lg+ 2));
 s.depla[lieu, dep]:= true;
 lg:= lg+ 3;
end;

procedure edvldep(var lg: integer;
                  aordre: long_integer);                    (* 017 *)
var
 lieu, dep: integer;
begin
(* debug('devalide depl', 0, 0);*)
 lieu:= int(peek(succ(aordre+ lg)));
 dep:= int(peek(aordre+ lg+ 2));
 s.depla[lieu, dep]:= false;
 lg:= lg+ 3;
end;

function etesdep(var lg: integer;
                 aordre: long_integer): boolean;            (* 018 *)
var
 lieu, dep: integer;
begin
(* debug('test depl', 0, 0);*)
 etesdep:= false;
 lieu:= int(peek(succ(aordre+ lg)));
 dep:= int(peek(aordre+ lg+ 2));
 if s.depla[lieu, dep] then etesdep:= true;
 lg:= lg+ 3;
end;

procedure ealerte(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 019 *)
var
 mess: integer;
begin
(* debug('message present un temps', 0, 0);*)
 if sorte< 2 then
 begin
  mess:= int(peekw(succ(aordre+ lg)));
  mess1(mess);
  vblsync(110);
 end;
 lg:= lg+ 3;
end;

procedure compadd(var lg: integer;
                  aordre: long_integer);                    (* 020 *)
var
 num, val: integer;
begin
(* debug('addition dans un compteur', 0, 0);*)
 num:= int(peek(succ(aordre+ lg)));
 val:= int(peekw(aordre+ lg+ 2));
 s.cmpt[num]:= s.cmpt[num]+ val;
 lg:= lg+ 4;
end;

procedure compsub(var lg: integer;
                  aordre: long_integer);                    (* 021 *)
var
 num, val: integer;
begin
(* debug('soustraction dans un compteur', 0, 0);*)
 num:= int(peek(succ(aordre+ lg)));
 val:= int(peekw(aordre+ lg+ 2));
 s.cmpt[num]:= s.cmpt[num]- val;
 lg:= lg+ 4;
end;

procedure compset(var lg: integer;
                  aordre: long_integer);                    (* 022 *)
var
 num, val: integer;
begin
(* debug('set dans un compteur', 0, 0);*)
 num:= int(peek(succ(aordre+ lg)));
 val:= int(peekw(aordre+ lg+ 2));
 s.cmpt[num]:= val;
 lg:= lg+ 4;
end;

function compequ(var lg: integer;
                 aordre: long_integer): boolean;            (* 023 *)
var
 num, val: integer;
begin
(* debug('compteur = valeur', 0, 0);*)
 num:= int(peek(succ(aordre+ lg)));
 val:= int(peekw(aordre+ lg+ 2));
 if s.cmpt[num]= val then compequ:= true else compequ:= false;
 lg:= lg+ 4;
end;

function compsup(var lg: integer;
                 aordre: long_integer): boolean;            (* 024 *)
var
 num, val: integer;
begin
(* debug('compteur > valeur', 0, 0);*)
 num:= int(peek(succ(aordre+ lg)));
 val:= int(peekw(aordre+ lg+ 2));
 if s.cmpt[num]> val then compsup:= true else compsup:= false;
 lg:= lg+ 4;
end;

function compinf(var lg: integer;
                 aordre: long_integer): boolean;            (* 025 *)
var
 num, val: integer;
begin
(* debug('compteur < valeur', 0, 0);*)
 num:= int(peek(succ(aordre+ lg)));
 val:= int(peekw(aordre+ lg+ 2));
 if s.cmpt[num]< val then compinf:= true else compinf:= false;
 lg:= lg+ 4;
end;

function efouill(sorte: integer; 
                 var lg: integer;
                 aordre: long_integer;
                 viobj, noobj: integer;
                 iobjet: boolean): boolean;                 (* 026 *)
var
 chai, mvid, mple, mfin: integer;
 efouill: boolean;
begin
(* debug('fouille', 0, 0);*)
 if sorte= 0 then
 begin
  efouill:= false;
  chai:= int(peekw(succ(aordre+ lg)));
  mvid:= int(peekw(aordre+ lg+ 3));
  mple:= int(peekw(aordre+ lg+ 5));
  mfin:= int(peekw(aordre+ lg+ 7));
  pshowmou;
  moduobj(iobjet, efouill, chai, mvid, mple, mfin, viobj, noobj);
  phidemou;
  chngmouse(0, 5);
 end;
 lg:= lg+ 9;
end;

procedure eindice(var lg: integer;
                  aordre: long_integer);                    (* 027 *)
var
 nind: integer;
begin
(* debug('indice', 0, 0);*)
 nind:= int(peek(succ(aordre+ lg)));
 mpourc:= mpourc+ s.indi[nind];
 s.indi[nind]:= 0;
 lg:= lg+ 2;
end;

procedure electur(sorte: integer;
                  var lg: integer;
                  aordre: long_integer;
                  iobjet: boolean);                         (* 028 *)
const
 posyh= 168;
 posyb= 197;
 larg= 50;
var
 dum, dtemps: long_integer;
 cx, page, mdessin, mnufic, pos: integer;
 moux, mouy, bsta, key, mmoux, mmouy: integer;
 posx: array[0..2] of integer;
 aff, trouv, stop: boolean;
begin
(* debug('lecture', 0, 0);*)
 if sorte= 0 then
 begin
  posmouse(100, 180, 039, 168, 210, 181);
  chngmouse(2, 4);
  mnufic:= nufic;
  nufic:= tlire;
  dtemps:= peekw(aheure);
  mdessin:= -1;
  aff:= true;
  posx[0]:= 039;
  posx[1]:= 108;
  posx[2]:= 179;
 end;
 lg:= succ(lg);
 pos:= lg;
 page:= int(peek(aordre+ pos));
 repeat
  if sorte= 0 then
  begin
   pexitani;
   if aff then slire(page, mdessin, 0, true);
   aff:= true;
   showmouf;
   repeat
    e_mouse(moux, mouy, bsta, key);
   until (bsta<> 0);
   hidemouf;
   if (bsta<> 1) and (mmoux<> -1) and (mmouy<> -1) then
   begin
    moux:= mmoux;
    mouy:= mmouy;
    bsta:= 1;
   end;
   if (bsta= 1) and (mouy> posyh) and (mouy< posyb) then
   begin
    stop:= false;
    trouv:= false;
    cx:= 0;
    repeat
     if (moux> posx[cx]) and (moux< (posx[cx]+ larg)) then trouv:= true
      else cx:= succ(cx);
    until (cx> 2) or (trouv);
    if trouv then
    begin
     mmoux:= moux;
     mmouy:= mouy;
     phidemou;
     if cx= 0 then
     begin
      pos:= pred(pos);
(*      decomp(0, atrava, agen30, 0, 0, aecra1);*)
      if pos< lg then
      begin
       aff:= false;
       pos:= lg;
      end;
     end;
     if cx= 1 then
     begin
      pos:= succ(pos);
(*      decomp(0, atrava, agen31, 0, 0, aecra1);*)
     end;
     if cx= 2 then
     begin
      stop:= true;
(*      decomp(0, atrava, agen32, 0, 0, aecra1);*)
     end;
     movblk(aecra1, aecra2, posx[cx], posyh, (posx[cx]+ larg), posyb);
     vblsync(11);
     if not aff then
     begin
(*      decomp(0, atrava, agen29, 0, 0, aecra1);*)
      movblk(aecra1, aecra2, 004, 162, 266, 198);
     end;
     pshowmou;
     page:= int(peek(aordre+ pos));
    end;
   end;
  end
  else
  begin
   pos:= succ(pos);
   page:= int(peek(aordre+ pos));
  end;
 until (page= 255) or (stop);
 if page<> 255 then
 repeat
  pos:= succ(pos);
  page:= int(peek(aordre+ pos));
 until (page= 255);
 lg:= succ(pos);

 if sorte= 0 then
 begin
  phidemou;
  aflieu(false, s.mlieu);
  meppal;
  changanim;
  styleff(4, -1, 0, 0, 266, 162);
  pinitani;
  procini(sorte, iobjet);
  posmouse(304, 199, 0, 0, 304, 199);
  pshowmou;
  pokew(aheure, dtemps);
  nufic:= mnufic;
 end;
end;

procedure esetpal(var lg: integer;
                  aordre: long_integer);   (* 029 *)
var
 lieu, pal: integer;
begin
(* debug('mise en place de palette', 0, 0);*)
 lieu:= int(peek(succ(aordre+ lg)));
 pal:= int(peek(aordre+ lg+ 2));
 s.palet[lieu]:= pal;
 if lieu= s.mlieu then
 begin
  if pal<> 0 then meppal else calcpal(true);
  styleff(6, 0, 0, 0, 0, 0);
 end;
 lg:= lg+ 3;
end;

function etespal(var lg: integer;
                 aordre: long_integer): boolean;            (* 030 *)
var
 lieu, pal: integer;
begin
(* debug('test de palette', 0, 0);*)
 etespal:= false;
 lieu:= int(peek(succ(aordre+ lg)));
 pal:= int(peek(aordre+ lg+ 2));
 if s.palet[lieu]= pal then etespal:= true;
 lg:= lg+ 3;
end;

function eprendr(sorte: integer;
                 var lg: integer;
                 aordre: long_integer;
                 iobjet: boolean): boolean;                 (* 031 *)
const
 afx= 271;
 afy= 085;
var
 obj, messok, messpl, messlo, messvo: integer;
 cx, cy, mainobj, mnufic, spoid, svolu, pobj, vobj, dumi: integer;
 place: boolean;
begin
(* debug('prendre', 0, 0);*)
 if sorte= 0 then
 begin
  eprendr:= false;
  obj:= int(peek(succ(aordre+ lg)));
  messok:= int(peekw(aordre+ lg+ 2));
  messpl:= int(peekw(aordre+ lg+ 4));
  messlo:= int(peekw(aordre+ lg+ 6));
  messvo:= int(peekw(aordre+ lg+ 8));
  for cx:= 0 to nbobj do objso[cx]:= -1;
  for cx:= 0 to maxob do
   if (s.objet[cx]< 0) and (s.objet[cx]> -6) then
   begin
    cy:= pred(-(s.objet[cx]));
    objso[cy]:= cx;
   end;
  place:= false;
  cx:= 0;
  repeat
   if objso[cx]= -1 then place:= true else cx:= succ(cx);
  until (cx> nbobj) or (place);
  if not place then mess1(messpl) else
  begin
   opv(obj, pobj, vobj);
   sopv(spoid, svolu);
   if ((spoid+ pobj)> s.cmpt[vfor]) then mess1(messlo) else
    if ((svolu+ vobj)> s.cmpt[vvol]) then mess1(messvo) else
    begin
     mnufic:= nufic;
     nufic:= tobje;
     eprendr:= true;
     main(mainobj);
     if mainobj<> -1 then
     begin
      s.objet[mainobj]:= -(succ(cx));
      actverb(-1, mainobj, gmesob, 8, mainobj, gobjet, 
                                               adgene, dumi, iobjet);
     end;
     s.objet[obj]:= -1;
     if iobjet then
     begin
      atbsta:= 0;
      atkey:= 0;
      afobj(true, false, 0, obj, afx, afy, 1);
     end
     else afobj(true, true, 0, obj, afx, afy, 1);
     actverb(-1, obj, gmesob, 7, obj, gobjet, 
                                      adgene, dumi, iobjet);
     nufic:= mnufic;
    end;
  end;
 end;
 lg:= lg+ 10;
end;

function emainjo(var lg: integer;
                 aordre: long_integer): boolean;            (* 032 *)
var
 cx, obj: integer;
begin
(* debug('test main joueur', 0, 0);*)
 emainjo:= false;
 obj:= int(peek(succ(aordre+ lg)));
 if s.objet[obj]= -1 then emainjo:= true;
 lg:= lg+ 2;
end;

function eapptjo(var lg: integer;
                 aordre: long_integer): boolean;            (* 033 *)
var
 obj: integer;
begin
(* debug('test poche et main joueur', 0, 0);*)
 eapptjo:= false;
 obj:= int(peek(succ(aordre+ lg)));
 if (s.objet[obj]< 0) and (s.objet[obj]> -7) then eapptjo:= true;
 lg:= lg+ 2;
end;

procedure evalcac(var lg: integer);                         (* 034 *)
begin
(* debug('valide cacher', 0, 0);*)
 s.cach:= true;
 phidemou;
(* decomp(0, atrava, agen20, 0, 0, aecra1);
 decomp(0, atrava, agen20, 0, 0, aecra2);*)
 pshowmou;
 lg:= succ(lg);
end;

function etescac(var lg: integer): boolean;                 (* 035 *)
begin
(* debug('test cacher', 0, 0);*)
 if s.cach then etescac:= true else etescac:= false;
 lg:= succ(lg);
end;

procedure evloupe(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 036 *)
var
 yaff, xaff, mess: integer;
 ok: boolean;
begin
(* debug('ordre loupe', 0, 0);*)
 if sorte= 0 then
 begin
  mess:= int(peekw(succ(aordre+ lg)));
  loupdeb(ok, xaff, yaff);
  mess1(mess);
  loupfin(ok, xaff, yaff);
 end;
 lg:= lg+ 3;
end;

procedure odispar(var lg: integer;
                  aordre: long_integer;
                  iobjet: boolean);                         (* 037 *)
var
 obj, mainobj, dumi: integer;
begin
(* debug('objet disparait', 0, 0);*)
 obj:= int(peek(succ(aordre+ lg)));
 main(mainobj);
 if mainobj= obj then
 begin
  phidemou;
(*  decomp(0, atrava, agen06, 0, 0, aecra1);
  decomp(0, atrava, agen06, 0, 0, aecra2);*)
  actverb(-1, mainobj, gmesob, 8, mainobj, gobjet, 
                                           adgene, dumi, iobjet);
  pshowmou;
 end;
 s.objet[obj]:= obnul;
 lg:= lg+ 2;
end;

function ovalobj(var lg: integer;
                 aordre: long_integer): boolean;            (* 038 *)
var
 obj, zon: integer;
begin
(* debug('valide zone objet', 0, 0);*)
 ovalobj:= true;
 obj:= int(peek(succ(aordre+ lg)));
 zon:= int(peek(aordre+ lg+ 2));
 if s.valob[obj, zon]> 0 then ovalobj:= false else
  s.valob[obj, zon]:= succ(s.valob[obj, zon]);
 lg:= lg+ 3;
end;

function odvlobj(var lg: integer;
                 aordre: long_integer): boolean;            (* 039 *)
var
 obj, zon: integer;
begin
(* debug('devalide zone objet', 0, 0);*)
 odvlobj:= true;
 obj:= int(peek(succ(aordre+ lg)));
 zon:= int(peek(aordre+ lg+ 2));
 if s.valob[obj, zon]< 1 then odvlobj:= false else
  s.valob[obj, zon]:= pred(s.valob[obj, zon]);
 lg:= lg+ 3;
end;

function otvlobj(var lg: integer;
                 aordre: long_integer): boolean;            (* 040 *)
var
 obj, zon: integer;
begin
(* debug('test validite zone objet', 0, 0);*)
 otvlobj:= true;
 obj:= int(peek(succ(aordre+ lg)));
 zon:= int(peek(aordre+ lg+ 2));
 if s.valob[obj, zon]= 0 then otvlobj:= false;
 lg:= lg+ 3;
end;

function emettre(sorte: integer;
                 var lg: integer;
                 aordre: long_integer): boolean;            (* 041 *)
const
 afx= 271;
 afy= 085;
var
 cha, messok, messmv, messlo, messvo: integer;
 chai, obj, cpoid, cvolu: integer;
 pcha, vcha, pobj, vobj: integer;
begin
(* debug('mettre', 0, 0);*)
 if sorte< 2 then
 begin
  cha:= int(peekw(succ(aordre+ lg)));
  chai:= cha- dchob;
  messok:= int(peekw(aordre+ lg+ 3));
  messmv:= int(peekw(aordre+ lg+ 5));
  messlo:= int(peekw(aordre+ lg+ 7));
  messvo:= int(peekw(aordre+ lg+ 9));
  main(obj);
  if obj= -1 then mess1(messmv) else
  begin
   pvoc(obj, chai, pobj, vobj, pcha, vcha);
   chpv(cha, cpoid, cvolu);
   if (cpoid+ pobj)> pcha then mess1(messlo) else
    if (cvolu+ vobj)> vcha then mess1(messvo) else
    begin
     afobj(true, false, 0, -1, afx, afy, 1);
     s.objet[obj]:= cha;
     mess1(messok);
    end;
  end;
 end;
 lg:= lg+ 11;
end;

function enbobjl(var lg: integer;
                 aordre: long_integer): boolean;            (* 042 *)
var
 cx, nb, val: integer;
begin
(* debug('nbre obj ds un lieu', 0, 0);*)
 enbobjl:= false;
 val:= int(peekw(succ(aordre+ lg)));
 nb:= 0;
 for cx:= 0 to maxob do
  if s.objet[cx]= s.mlieu then nb:= succ(nb);
 if nb >= val then enbobjl:= true;
 lg:= lg+ 3;
end;

procedure eanient(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 043 *)
var
 lieu, numani, zon: integer;
begin
(* debug('animation entre', 0, 0);*)
 animat(sorte, true, lg, aordre);
end;

procedure eanisor(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 044 *)
begin
(* debug('animation sort', 0, 0);*)
 animat(sorte, false, lg, aordre);
end;

procedure eaniexe(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 045 *)
var
 lieu, ani, sequ, zon: integer;
begin
(* debug('animation exe', 0, 0);*)
 lieu:= int(peek(succ(aordre+ lg)));
 ani:= int(peek(aordre+ lg+ 2));
 sequ:= int(peek(aordre+ lg+ 3));
 s.anim[lieu, ani]:= sequ;
 lg:= lg+ 4;
 zon:= int(peek(aordre+ lg));
 while zon<> 255 do
 begin
  s.valid[lieu, zon]:= succ(s.valid[lieu, zon]);
  if (s.mlieu= lieu) and (s.valid[lieu, zon]= 1) then recdes(17, zon);
  lg:= succ(lg);
  zon:= int(peek(aordre+ lg));
 end;
 lg:= succ(lg);
 zon:= int(peek(aordre+ lg));
 while zon<> 255 do
 begin
  s.valid[lieu, zon]:= pred(s.valid[lieu, zon]);
  if (s.mlieu= lieu) and (s.valid[lieu, zon]= 0) then recdes(16, zon);
  lg:= succ(lg);
  zon:= int(peek(aordre+ lg));
 end;
 if sorte< 2 then
 begin
(*  if lieu= s.mlieu then chngani(ani, sequ, 1);*)
  afzone(true);
 end;
 lg:= succ(lg);
end;

procedure eanifon(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 46 *)
var
 lieu, ani, sequ, zon: integer;
begin
(* debug('animation fond', 0, 0);*)
 lieu:= int(peek(succ(aordre+ lg)));
 ani:= int(peek(aordre+ lg+ 2));
 sequ:= int(peek(aordre+ lg+ 3));
 s.anim[lieu, ani]:= sequ;
 lg:= lg+ 4;
 zon:= int(peek(aordre+ lg));
 while zon<> 255 do
 begin
  if (sorte< 2) and (lieu= s.mlieu) then
   s.valfon[zon]:= succ(s.valfon[zon]) else
  begin
   s.valid[lieu, zon]:= succ(s.valid[lieu, zon]);
   if (s.mlieu= lieu) and (s.valid[lieu, zon]= 1) then recdes(17, zon);
  end;
  lg:= succ(lg);
  zon:= int(peek(aordre+ lg));
 end;
 lg:= succ(lg);
 zon:= int(peek(aordre+ lg));
 while zon<> 255 do
 begin
  if (sorte< 2) and (lieu= s.mlieu) then
   s.valfon[zon]:= pred(s.valfon[zon]) else
  begin
   s.valid[lieu, zon]:= pred(s.valid[lieu, zon]);
   if (s.mlieu= lieu) and (s.valid[lieu, zon]= 0) then recdes(16, zon);
  end;
  lg:= succ(lg);
  zon:= int(peek(aordre+ lg));
 end;
 lg:= succ(lg);
end;

procedure efinjeu(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 047 *)
var
 dtemps: long_integer;
 page, mdessin, mnufic: integer;
begin
(* debug('finjeu', 0, 0);*)
 if sorte= 0 then
 begin
  chngmouse(2, 4);
  solu:= true;
  pexitani;
 end
 else perdu:= true;
 mnufic:= nufic;
 nufic:= tlire;
 dtemps:= peekw(aheure);
 mdessin:= -1;
 lg:= succ(lg);
 page:= int(peek(aordre+ lg));
 repeat
  if sorte= 0 then
  begin
   slire(page, mdessin, 0, true);
   atclick(0, false);
  end;
  lg:= succ(lg);
  page:= int(peek(aordre+ lg));
 until page= 255;
 lg:= succ(lg);
 pokew(aheure, dtemps);
 nufic:= mnufic;
end;

procedure edifvar(var lg: integer; aordre: long_integer);   (* 048 *)
var
 recep, num1, num2: integer;
begin
(* debug('diff variable', 0, 0);*)
 recep:= int(peek(succ(aordre+ lg)));
 num1:= int(peek(aordre+ lg+ 2));
 num2:= int(peek(aordre+ lg+ 3));
 s.cmpt[recep]:= s.cmpt[num1]- s.cmpt[num2];
 lg:= lg+ 4;
end;

procedure etemps(sorte: integer;
                 var lg: integer;
                 aordre: long_integer);                     (* 049 *)
var
 num1: integer;
begin
(* debug('temps dans var', 0, 0);*)
 if sorte< 2 then
 begin
  num1:= int(peek(succ(aordre+ lg)));
  s.cmpt[num1]:= s.nmin;
 end;
 lg:= lg+ 2;
end;

procedure ehasard(var lg: integer;
                  aordre: long_integer);                    (* 050 *)
var
 num1: integer;
 min, max: long_integer;
begin
(* debug('hazard dans var', 0, 0);*)
 num1:= int(peek(succ(aordre+ lg)));
 min:= peekw(aordre+ lg+ 2);
 max:= peekw(aordre+ lg+ 4);
 s.cmpt[num1]:= int(hazard(min, max));
 lg:= lg+ 6;
end;

procedure echanob(sorte: integer;
                  var lg, numobj: integer;
                  aordre: long_integer;
                  viobj, noobj: integer;
                  iobjet: boolean);                         (* 051 *)
const
 xafob= 271;
 yafob1= 085;
 yafob2= 141;
 oby= 141;
 lgpx= 048;
var
 cx, objd, obja, cha, dumi: integer;
begin
(* debug('change objet', 0, 0);*)
 if sorte< 2 then
 begin
  objd:= int(peek(succ(aordre+ lg)));
  obja:= int(peek(aordre+ lg+ 2));
  cha:= s.objet[objd];
  s.objet[objd]:= obnul;
  s.objet[obja]:= cha;
  for cx:= 0 to nbobj do
   if objso[cx]= objd then objso[cx]:= obja;
  if cha= -1 then
  begin
   (* pour deposer *)
   actverb(-1, objd, gmesob, 8, objd, gobjet, adgene, dumi, iobjet);
   afobj(true, false, 0, obja, xafob, yafob1, 1);
   (* pour prendre *)
   actverb(-1, obja, gmesob, 7, obja, gobjet, adgene, dumi, iobjet);
   main(omain);
  end
  else
  begin
   if noobj<> -1 then
   begin
    afobj(true, true, 0, obja, xafob, yafob2, 1);
    noobj:= obja;
    numobj:= obja;
   end;
  end;
 end;
 lg:= lg+ 3;
end;

procedure esurimp(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 052 *)
var
 num: long_integer;
begin
(* debug('surimp', 0, 0);*)
 if sorte= 0 then
 begin
  num:= peekw(succ(aordre+ lg));
  if memoire> mmini then surim(num);    (* SON-ST *)
 end;
 lg:= lg+ 3;
end;

procedure ebruita(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 053 *)
var
 num: long_integer;
begin
(* debug('bruitage', 0, 0);*)
 if sorte= 0 then
 begin
  num:= peekw(succ(aordre+ lg));
  if memoire> mmini then brui(num);     (* SON-ST *)
 end;
 lg:= lg+ 3;
end;

procedure estopan(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 054 *)
var
 lieu, numani, zon: integer;
begin
(* debug('estopan', 0, 0);*)
 lieu:= int(peek(succ(aordre+ lg)));
 numani:= int(peek(aordre+ lg+ 2));
 lg:= lg+ 3;
 zon:= int(peek(aordre+ lg));
 while zon<> 255 do
 begin
  s.valid[lieu, zon]:= succ(s.valid[lieu, zon]);
  if (s.mlieu= lieu) and (s.valid[lieu, zon]= 1) then recdes(17, zon);
  lg:= succ(lg);
  zon:= int(peek(aordre+ lg));
 end;
 lg:= succ(lg);
 zon:= int(peek(aordre+ lg));
 while zon<> 255 do
 begin
  s.valid[lieu, zon]:= pred(s.valid[lieu, zon]);
  if (s.mlieu= lieu) and (s.valid[lieu, zon]= 0) then recdes(16, zon);
  lg:= succ(lg);
  zon:= int(peek(aordre+ lg));
 end;
 s.anim[lieu, numani]:= -1;
 if (sorte< 2) or (sorte= 4) then
 begin
(*  if s.mlieu= lieu then stopani(numani); *)
  if sorte= 4 then afzone(false) else afzone(true);
 end;
 lg:= succ(lg);
end;

function etseul(sorte: integer;
                var lg: integer;
                aordre: long_integer): boolean;             (* 055 *)
var
 cx: integer;
begin
 etseul:= true;
 if sorte< 2 then
 begin
  for cx:= 0 to npers do
   if s.perso[s.mlieu, cx]= 1 then etseul:= false;
 end;
 lg:= succ(lg);
end;

procedure evalper(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 056 *)
var
 npers: integer;
begin
 if sorte< 2 then
 begin
   npers:= int(peek(succ(aordre+ lg)));
   s.perso[s.mlieu, npers]:= 1;
 end;
 lg:= lg+ 2;
end;

procedure edvlper(sorte: integer;
                  var lg: integer;
                  aordre: long_integer);                    (* 057 *)
var
 npers: integer;
begin
 if sorte< 2 then
 begin
  npers:= int(peek(succ(aordre+ lg)));
  s.perso[s.mlieu, npers]:= 0;
 end;
 lg:= lg+ 2;
end;

(* NIVEAU 4 *)
procedure ficmem;
var
 dum: long_integer;
begin
(* debug('ficmem', 0, 0);*)
 (***** memoire en fonction de place disponible *****)
 (* menu action grand *)
 memplus(true, aact17, 048, 14, 046, 037, 223, 192);
 (* menu action petit *)
(* memplus(true, agen26, 025, 14, 086, 103, 165, 181); *)
 (* menu inventaire *)
 memplus(true, ainv01, 049, 14, 048, 082, 218, 183);
 (* menu objet *)
 memplus(true, aaob00, 093, 14, 052, 102, 214, 189);
 (* menu action general *)
(* memplus(false, agen09, 008, 14, 004, 162, 266, 199); *)
 (* menu objet general *)
(* memplus(false, agen23, 022, 14, 004, 162, 266, 199); *)
 (***** souris *****)
 xload(false, atrava, adessi, 103, 8, dum);
 decomp(0, atrava, adessi, 0, 0, adesou);
 initmouse(adesou, azmasq, aecra2, aecra1, asprit, asouris);
 posmouse(131, 85, 0, 0, 304, 199);
 (***** loupe *****)
 xload(false, atrava, aloupe, 104, 8, dum);
 initadr(adgene);  (* pour cumul table general *)
end;

{}

procedure ordre;
var
 lg, vordre: integer;
 bon: boolean;

begin
(* debug('ordre', 0, 0);*)
 lg:= 0;
 bon:= true;
 while (lg< taille) and (not perdu) and (not arret)
                    and (not chgtab) and (not solu) do
 begin
  vordre:= int(peek(aordre+ lg));
  case vordre of
   csipaer:  esipaer(sorte, lg, numobj, aordre, bon, iobjet, viobj, noobj);
   csier:    esier(sorte, lg, numobj, aordre, bon, iobjet, viobj, noobj);
   cafmess:  eafmess(sorte, lg, aordre);
   cdplace:  edplace(sorte, lg, aordre, iobjet);
   cmort:    emort(sorte, lg, aordre);
   cassom:   eassom(sorte, lg, aordre, iobjet);
   caugtps:  eaugtps(sorte, lg, aordre, iobjet);
   cparler:  eparler(sorte, lg, aordre);
   cvalzon:  bon:= evalzon(lg, aordre);
   cdvalzo:  bon:= edvalzo(lg, aordre);
   ctvalzo:  bon:= etvalzo(lg, aordre);
   caffval:  eaffval(sorte, lg);
   cajobj:   bon:= eajobj(sorte, lg, aordre, iobjet);
   cretobj:  bon:= eretobj(sorte, lg, aordre);
   ctesapp:  bon:= etesapp(lg, aordre);
   cteslie:  bon:= eteslie(lg, aordre);
   cvaldep:  evaldep(lg, aordre);
   cdvldep:  edvldep(lg, aordre);
   ctesdep:  bon:= etesdep(lg, aordre);
   calerte:  ealerte(sorte, lg, aordre);
   ccomadd:  compadd(lg, aordre);
   ccomsub:  compsub(lg, aordre);
   ccomset:  compset(lg, aordre);
   ccomequ:  bon:= compequ(lg, aordre);
   ccomsup:  bon:= compsup(lg, aordre);
   ccominf:  bon:= compinf(lg, aordre);
   cfouill:  bon:= efouill(sorte, lg, aordre, viobj, noobj, iobjet);
   cindice:  eindice(lg, aordre);
   clectur:  electur(sorte, lg, aordre, iobjet);
   csetpal:  esetpal(lg, aordre);
   ctespal:  bon:= etespal(lg, aordre);
   cprendr:  bon:= eprendr(sorte, lg, aordre, iobjet);
   cmainjo:  bon:= emainjo(lg, aordre);
   capptjo:  bon:= eapptjo(lg, aordre);
   cvalcac:  evalcac(lg);
   ctescac:  bon:= etescac(lg);
   cvloupe:  evloupe(sorte, lg, aordre);
   codispa:  odispar(lg, aordre, iobjet);
   covalob:  bon:= ovalobj(lg, aordre);
   codvlob:  bon:= odvlobj(lg, aordre);
   cotvlob:  bon:= otvlobj(lg, aordre);
   cmettre:  bon:= emettre(sorte, lg, aordre);
   cnbobjl:  bon:= enbobjl(lg, aordre);
   canient:  eanient(sorte, lg, aordre);
   canisor:  eanisor(sorte, lg, aordre);
   caniexe:  eaniexe(sorte, lg, aordre);
   canifon:  eanifon(sorte, lg, aordre);
   cfinjeu:  efinjeu(sorte, lg, aordre);
   cdifvar:  edifvar(lg, aordre);
   ctemps:   etemps(sorte, lg, aordre);
   chasard:  ehasard(lg, aordre);
   cchanob:  echanob(sorte, lg, numobj, aordre, viobj, noobj, iobjet);
   csurimp:  esurimp(sorte, lg, aordre);
   cbruita:  ebruita(sorte, lg, aordre);
   cstopan:  estopan(sorte, lg, aordre);
   ctseul:   bon:= etseul(sorte, lg, aordre);
   cvalper:  evalper(sorte, lg, aordre);
   cdvlper:  edvlper(sorte, lg, aordre);
   otherwise: begin
(*                debug('otherwise', 0, 0); *)
                lg:= succ(lg);
              end;
  end;
 end;
end;

{}

(* NIVEAU *)
procedure clicact(choix: integer;
                  var key: integer;
                  var iobjet: boolean);
var
 numt: array[0..15] of integer;

begin
 (* debug('clicact', 0, 0); *)
 repeat
  debug('choix', choix, 0);

  numt[00]:= 28;
  numt[01]:= 46;
  numt[02]:= 31;
  numt[03]:= 32;
  numt[04]:= 33;
  numt[05]:= 34;
  numt[06]:= 36;
  numt[07]:= 37;
  numt[08]:= 38;
  numt[09]:= 39;
  numt[10]:= 40;
  numt[11]:= 41;
  numt[12]:= 42;
  numt[13]:= 43;
  decomp(0, atrava, agen01, 0, 0, aecra1);
  decomp(0, atrava, agen01, 0, 0, aecra2);
  aftitre(numt[choix], 0, 120, 0, -1, 0, atext6, along6, adtext, asprit);

(* si le verbe est deposer *)
  if choix= 1 then
  begin
   tdepo(key, -1, iobjet);
   act:= -1;
   key:= 0;
  end
  else
   if choix= 7 then
   begin
    actobse(s.nmin, 0, iobjet);
    act:= -1;
    key:= 0;
   end
   else
    begin
   (*   si le verbe est apres deposer ou apres observer *)
     if choix> 7 then choix:= pred(choix);
     if choix> 1 then choix:= pred(choix);
     tverbe(choix, key, iobjet);
    end;
  if act<> -1 then
  begin
   key:= -1;
   mact:= act;
   choix:= act;
  end;
 until act= -1;
 if dep<> -1 then key:= -1;
 chngmouse(0, 5);
 decomp(0, atrava, agen01, 0, 0, aecra1);
 decomp(0, atrava, agen01, 0, 0, aecra2);

end;

{}

procedure clictem(choix: integer;
                  var iobjet: boolean);
var
 attend, cx: integer;

begin
 if choix= 0 then attend:= 143;
 if choix= 1 then attend:= 287;
 if choix= 2 then attend:= 11;
 cx:= 0;
 phidem;
 repeat
  templus(5);
  tinke(false, iobjet, -1, 1);
  cx:= succ(cx);
 until (cx> attend) or (perdu) or (solu);
 pshowm;
end;

{}

procedure helplieu;
var
 str, str1: str255;
 cx, lg: integer;
 dum, adr: long_integer;
begin
(* debug('helplieu', 0, 0); *)

(* faitnom(str, s.mlieu);
 str1:= concat(naidel, str);
 lect(str1, adessi, dum);*)

 lg:= pred(int(azmasq- adessi));
 for cx:= 0 to lg do poke((adessi+ cx), 0);

 adr:= adessi+ 2; 
 xload(true, atrava, adr, 4, s.mlieu, dum);
 pokew(adessi, dum);

(* dum:= savmem(1, asgen14, aecra1, 004, 162, 266, 199);*)
 dum:= aftext(25, adr, adessi, adtext, aecra1, 9, 166, 250, 8, 0, 1, 0, 1);
 dum:= aftext(25, adr, adessi, adtext, aecra1, 8, 166, 250, 8, 0, 1, 0, 1);
 dum:= aftext(25, adr, adessi, adtext, aecra1, 8, 165, 250, 8, 15, 1, 0, 1);
 styleff(5, 6, 004, 162, 266, 199);
 posmouse(304, 164, 0, 0, 304, 164);
 atclick(0, true);
 posmouse(304, 198, 0, 0, 304, 199);
end;

{}

procedure menuresto;
const
 hmen= 11; 

var
 xg, yg, xd, yd: integer;

begin
 phidem;
 xg:= pcx[0];
 yg:= pcy[0];
 xd:= xg+ int(plarg);
 yd:= pcy[nbmen]+ hmen+ 24;
 deptra:= savmem(1, atrava, aecra1, xg, yg, xd, yd);
 deptra:= savmem(1, atrava, aecra2, xg, yg, xd, yd);
 deptra:= 0;
 pshowm;
end;

{}

procedure xinv(var iobjet, nouvobj: boolean;
               var numobj, key: integer);
const
 lgx= 48;
 hty= 27;
 x0= 111;
 x1= 58;
 x2= 84;
 x3= 138;
 x4= 164;
 y0= 94;
 y1= 113;
 y2= 147;
 y3= 147;
 y4= 113;
 objabs= -99;

var
 bobj: array[0..nbobj] of boolean;
 coox, cooy: array[0..nbobj] of integer;
 cx, cy, bsta, mnufic, dumi: integer;
 dum, dum1, dtemps: long_integer;

begin
(* debug('xinv', 0, 0); *)
 dtemps:= peekw(aheure);
 dum:= savmem(0, aecra1, atrava, 048, 082, 218, 183);
 coox[0]:= x0;
 coox[1]:= x1;
 coox[2]:= x2;
 coox[3]:= x3;
 coox[4]:= x4;
 cooy[0]:= y0;
 cooy[1]:= y1;
 cooy[2]:= y2;
 cooy[3]:= y3;
 cooy[4]:= y4;
 {anihalt;}
 if memoire> mmini then
  dum1:= savmem(-15, ainv01, aecra1, 048, 082, 218, 183)
 else decomp(0, (atrava+ dum), ainv01, 0, 0, aecra1);
 for cx:= 0 to nbobj do bobj[cx]:= false;
 for cx:= 0 to maxob do
  if (s.objet[cx]< 0) and (s.objet[cx]> -6) then
  begin
   cy:= pred(-(s.objet[cx]));
   afobj(false, false, dum, cx, coox[cy], cooy[cy], 0);
   bobj[cy]:= true;
  end;
 for cx:= 0 to nbobj do
  if not bobj[cx] then
   afobj(false, false, dum, -1, coox[cx], cooy[cx], 0);
 mloupe(amas06, 0, 0);
 styleff(5, 6, 048, 082, 218, 183);
 {anishow;}

 joueur(false, false, -1, bsta, key);

 if obj<> -1 then
 begin
  mobj:= succ(obj);
  bsta:= 2;
  key:= 0;
 end;
 if (bsta= 2) and (mobj<> -1) then
 begin
  nouvobj:= true;
  cx:= mobj;
 end
 else
  if bsta<> 0 then
  begin
   cx:= 1;
   repeat
    if (mouy> cooy[cx]) and (mouy< (cooy[cx]+ hty)) and
       (moux> coox[cx]) and (moux< (coox[cx]+ lgx)) then
     nouvobj:= true
    else
     cx:= succ(cx);
   until (nouvobj) or (cx> nbobj);
  end;
 dum:= savmem(1, atrava, aecra1, 048, 082, 218, 183);
 styleff(5, 6, 048, 082, 218, 183);
 dum:= savmem(1, atrava, 0, 048, 082, 218, 183);
 mnufic:= nufic;
 nufic:= tobje;
 pokew(aheure, dtemps);
 if nouvobj then
 begin
  mobj:= cx;
  if bobj[cx] then
  begin
   cx:= succ(cx);
   main(cy);
   if cy<> -1 then
   begin
    s.objet[cy]:= objabs;
    actverb(-1, cy, gmesob, 8, cy, gobjet, adgene, dumi, iobjet);
   end;
   for cy:= 0 to maxob do
    if s.objet[cy]= -cx then
    begin
     numobj:= cy;
     s.objet[cy]:= -1;
     actverb(-1, cy, gmesob, 7, cy, gobjet, adgene, dumi, iobjet);
    end;
   for cy:= 0 to maxob do
    if s.objet[cy]= objabs then s.objet[cy]:= -cx;
  end
  else
  begin
   numobj:= -1;
   cx:= succ(cx);
   main(cy);
   if cy<> -1 then
   begin
    s.objet[cy]:= -cx;
    actverb(-1, cy, gmesob, 8, cy, gobjet, adgene, dumi, iobjet);
   end;
  end;
 end;
 nufic:= mnufic;
end;

{}

procedure xcharg(var chargeme: boolean);
const
 lgx= 16;
 hty= 24;
 x0= 090;
 x1= 110;
 x2= 130;
 x3= 150;
 x4= 170;
 ys= 133;

var
 pris: array[0..4] of boolean;
 coox: array[0..4] of integer;
 indpris: boolean;
 cx, bsta, key: integer;
 retour, dum, atrav2, adres1, adres2: long_integer;

begin
(* debug('charge', 0, 0); *)
 chargeme:= false;
 pexitani;
 (* recherche du nombre de parties deja sauvegardees *)
 testload(atrava);
 retour:= peekl(atrava);

 (* c'est un disk de sauvegarde *)
 if retour> -1 then
 begin
  (* chaque bit correspond a une sauvegarde *)
  indpris:= false;
  retour:= 0;
  for cx:= 0 to 4 do
  begin
   retour:= peekb((atrava+ 3), cx);
   if retour= 1 then
   begin
    pris[cx]:= true;
    indpris:= true;
   end
   else pris[cx]:= false;
  end;
 
  if indpris then
  begin
   phidemou;
   dum:= savmem(0, aecra1, atrava, 074, 085, 201, 168);
   atrav2:= atrava+ dum;
   coox[0]:= x0;
   coox[1]:= x1;
   coox[2]:= x2;
   coox[3]:= x3;
   coox[4]:= x4;
   decomp(0, atrav2, asav00, 0, 0, aecra1);
   if pris[0] then decomp(0, atrav2, asav01, 0, 0, aecra1);
   if pris[1] then decomp(0, atrav2, asav02, 0, 0, aecra1);
   if pris[2] then decomp(0, atrav2, asav03, 0, 0, aecra1);
   if pris[3] then decomp(0, atrav2, asav04, 0, 0, aecra1);
   if pris[4] then decomp(0, atrav2, asav05, 0, 0, aecra1);
   decomp(0, atrav2, asav06, 0, 0, aecra1);
   styleff(5, 6, 074, 085, 201, 168);
   adres1:= asav06;
   adres2:= asav07;
   for cx:= 1 to 3 do
   begin
    vblsync(7);
    decomp(0, atrav2, adres2, 0, 0, aecra1);
    decomp(0, atrav2, adres2, 0, 0, aecra2);
    vblsync(7);
    decomp(0, atrav2, adres1, 0, 0, aecra1);
    decomp(0, atrav2, adres1, 0, 0, aecra2);
   end;
   pshowmou;

   pshowmou;
   bsta:= 0;
   key:= 0;
   repeat
    e_mouse(moux, mouy, bsta, key);
   until (bsta<> 0) or (key<> 0);
   phidemou;

   chargeme:= false;
   if key<> 0 then
   begin
    if (key= kn1) or (key= kn2) or (key= kn3) or
       (key= kn4) or (key= kn5) then
    begin
     if key= kn1 then cx:= 0;
     if key= kn2 then cx:= 1;
     if key= kn3 then cx:= 2;
     if key= kn4 then cx:= 3;
     if key= kn5 then cx:= 4;
     chargeme:= true;
    end;
   end
   else
   begin
    cx:= 0;
    repeat
     if (mouy> ys) and (mouy< (ys+ hty)) and
        (moux> coox[cx]) and (moux< (coox[cx]+ lgx)) and
        (pris[cx]) then chargeme:= true else
      cx:= succ(cx);
    until (chargeme) or (cx> nbobj);
   end;

   phidemou;
   if chargeme then
   begin
    efpoint((coox[cx]+ 7), (ys+ 16), 15, aecra1);
    efpoint((coox[cx]+ 7), (ys+ 16), 15, aecra2);
    dum:= charge(cx, atrav2, asauv, lsauv);
   end;
   dum:= savmem(1, atrava, aecra1, 074, 085, 201, 168);
   styleff(5, 6, 074, 085, 201, 168);
   if chargeme then
   begin
(*    diskinit(false); *)
    aflieu(true, s.mlieu);
    changanim;
    pamb(peekw(depadr(adlieu, wambian)));    (* SON-ST *)
    styleff(4, -1, 0, 0, 319, 199);
    calcamb;                                 (* SON-ST *)
    calch(s.nmin);
    pendule(false, 0);
    procini(0, false);
   end;
   pshowmou;
  end
  else
  begin
   mess1(3);
   pshowmou;
   bsta:= 0;
   key:= 0;
   repeat
    e_mouse(moux, mouy, bsta, key);
   until (bsta<> 0) or (key<> 0);
   phidemou;
  end;
 end
 else pasbondk;
 pinitani;
end;

{}

procedure xsauv;
const
 lgx= 16;
 hty= 24;
 x0= 090;
 x1= 110;
 x2= 130;
 x3= 150;
 x4= 170;
 ys= 133;

var
 sauvegar: boolean;
 pris: array[0..4] of boolean;
 coox: array[0..4] of integer;
 cx, bsta, key, ets, cox, coy, mnufic: integer;
 retour, dum, adres1, adres2, atrav2: long_integer;

begin
(* debug('sauv', 0, 0); *)
 sauvegar:= false;
 mnufic:= nufic;
 nufic:= tamoi;
 repeat
  mess1(4);
  pshowmou;
  key:= 0;
  repeat
   e_mouse(cox, coy, ets, key);
   if ets<> 0 then
   begin
    ets:= 0;
    key:= 0;
    if coy> 173 then
    begin 
     if (cox> 085) and (cox< 131) then key:= kou;
     if (cox> 130) and (cox< 176) then key:= kno;
    end;
   end;
  until key<> 0;
  phidemou;
  if key= kou then
  begin
   phidemou;
   mess1(16);
   pshowmou;
   (* recherche du nombre de parties deja sauvegardees *)
   testload(atrava);
   dum:= peekl(atrava);
   if dum> -1 then
   begin
    phidemou;
    (* chaque bit correspond a une sauvegarde *)
    for cx:= 0 to 4 do
    begin
     retour:= peekb((atrava+ 3), cx);
     if retour= 1 then pris[cx]:= true else pris[cx]:= false;
    end;
    {anihalt;}
    dum:= savmem(0, aecra1, atrava, 074, 085, 201, 168);
    atrav2:= atrava+ dum;
    coox[0]:= x0;
    coox[1]:= x1;
    coox[2]:= x2;
    coox[3]:= x3;
    coox[4]:= x4;
    decomp(0, atrav2, asav00, 0, 0, aecra1);
    decomp(0, atrav2, asav01, 0, 0, aecra1);
    decomp(0, atrav2, asav02, 0, 0, aecra1);
    decomp(0, atrav2, asav03, 0, 0, aecra1);
    decomp(0, atrav2, asav04, 0, 0, aecra1);
    decomp(0, atrav2, asav05, 0, 0, aecra1);
    decomp(0, atrav2, asav08, 0, 0, aecra1);
    for cx:= 0 to 4 do
     if pris[cx] then efpoint((coox[cx]+ 7), (ys+ 16), 15, aecra1);
    mloupe(amas02, 0, 0);
    styleff(5, 6, 074, 085, 201, 168);
    {anishow;}
    adres1:= asav08;
    adres2:= asav09;
    for cx:= 1 to 3 do
    begin
     vblsync(7);
     decomp(0, atrav2, adres2, 0, 0, aecra1);
     decomp(0, atrav2, adres2, 0, 0, aecra2);
     vblsync(7);
     decomp(0, atrav2, adres1, 0, 0, aecra1);
     decomp(0, atrav2, adres1, 0, 0, aecra2);
    end;
    pshowmou;
  
    pshowmou;
    bsta:= 0;
    key:= 0;
    repeat
     e_mouse(moux, mouy, bsta, key);
    until (bsta<> 0) or (key<> 0);
    phidemou;
  
    if key<> 0 then
    begin
     if (key= kn1) or (key= kn2) or (key= kn3) or
        (key= kn4) or (key= kn5) then
     begin
      if key= kn1 then cx:= 0;
      if key= kn2 then cx:= 1;
      if key= kn3 then cx:= 2;
      if key= kn4 then cx:= 3;
      if key= kn5 then cx:= 4;
      sauvegar:= true;
     end;
    end
    else
    begin
     cx:= 0;
     repeat
      if (mouy> ys) and (mouy< (ys+ hty)) and
         (moux> coox[cx]) and (moux< (coox[cx]+ lgx)) then
       sauvegar:= true
      else
       cx:= succ(cx);
     until (sauvegar) or (cx> nbobj);
    end;
  
    if sauvegar then
    begin
     efpoint((coox[cx]+ 7), (ys+ 16), 15, aecra1);
     efpoint((coox[cx]+ 7), (ys+ 16), 15, aecra2);
     sauve(cx, asauv, lsauv);
    end;
    phidemou;
    dum:= savmem(1, atrava, aecra1, 074, 085, 201, 168);
    styleff(5, 6, 074, 085, 201, 168);
    dum:= savmem(1, atrava, 0, 074, 085, 201, 168);
    pshowmou;
   end
   else pasbondk;
  end;
 until (sauvegar) or (key= kno);

 (* pour retour disquette initiale *)
(* diskinit(true); *)
(* if etani then initani;*)

 nufic:= mnufic;
end;

{}

(* NIVEAU 2 *)
procedure efnoir;
begin
(* debug('efnoir', 0, 0); *)
 phidemou;
 if hazard(0, 1)= 1 then
 begin
  styleff(3, 1, 0, 0, 319, 199);
  styleff(6, 0, 0, 0, 0, 0);
  styleff(2, 2, 0, 0, 319, 199);
 end
 else
 begin
  styleff(1, 0, 0, 0, 319, 199);
  movblk(aecra1, aecra2, 0, 0, 319, 199);
  styleff(0, 0, 0, 0, 319, 199);
 end;
 pshowmou;
end;

{}

procedure initialisation;
const
 cxaf= 100;       (* coordonnees affichage carte de choix *)
 cyaf= 50;

var
 fsa: file of fsauv;
 dum: long_integer;
 x1s, y1s, x2s, y2s, cx: integer;

begin
(* debug('initialisation', 0, 0); *)

(* debug('lecture fichier sauvegarde', 0, 0); *)
(* reset(fsa, NSAUVE);
 fs:= fsa^;
 s:= fs;
 close(fsa);*)

 dum:= charge(-1, atrava, asauv, lsauv);
 if perdu then styleff(1, 0, 0, 0, 319, 199);
 etani:= false;

 mmen:= -1;
 macto:= -1;
 mflex:= -1;
 mfley:= -1;

 atmoux:= 0;
 atmouy:= 0;
 atkey:= 0;
 atbsta:= 0;

 mheu:= 25;
 mmin:= -1;
 mjou:= 0;
 mpourc:= 0;
 ifouil:= false;
 gobj2:= -1;

 recplein(aecra1, 0, 0, 319, 199, 0);
 x1s:= cxaf;
 y1s:= cyaf;
 x2s:= 088+ cxaf;
 y2s:= 120+ cyaf;
 decomp(0, atrava, agen12, x1s, y1s, aecra1);
 dum:= savmem(0, aecra1, asgen12, x1s, y1s, x2s, y2s);

 decomp(0, atrava, agen02, 0, 0, aecra1);
 decomp(0, atrava, agen03, 0, 0, aecra1);
 decomp(0, atrava, agen04, 0, 0, aecra1);
 decomp(0, atrava, agen05, 0, 0, aecra1);
 decomp(0, atrava, agen08, 265, 109, aecra1);
(* decomp(0, atrava, agen21, 0, 0, aecra1);
 decomp(0, atrava, agen22, 0, 0, aecra1);
 decomp(0, atrava, agen17, 0, 0, aecra1);
 decomp(0, atrava, agen15, 0, 0, aecra1);
 decomp(0, atrava, agen14, 0, 0, aecra1);
 dum:= savmem(0, aecra1, asgen14, 004, 162, 266, 199);
 if s.cach then decomp(0, atrava, agen20, 0, 0, aecra1) else
  decomp(0, atrava, agen18, 0, 0, aecra1); *)
 s.rsec:= 0;

(* *)
 s.mlieu:= 2;
(* *)

 aflieu(true, s.mlieu);
 changanim;
 nufic:= tamoi;

(* modif special PC *)
(* if perdu then eftext(25, 8, 165, 250, 8, 15, 1, aecra1, 0, 7) else
 eftext(25, 8, 165, 250, 8, 15, 1, aecra1, 0, 2); *)

(* special hide et show-mouse *)
 ctrhi:= 0;
 ctrsh:= 0;
(* fin special *)
end;

{}

procedure pcont;
begin
end;

procedure pcont1;
const
(* nfic= 'D:\SECTE.SEK\PROT.O';*)

 mmotaff= 07;  (* 0..07 mots affichables sur ecran *)
 nu_text= 51;  (* numero du premier texte d'environnement *)
 nu_prot= 58;  (* numero du premier texte de protection *)  
 ytext= 164;
 intli= 008;
 larg= 063;

var
 dum, adres: long_integer;
 ets, key, cx, cy, numot, place, nb: integer;
 page, ligne, mot, nb_prot, nb_moin: integer;
 text1, text2, text3, text4, textp, textl, textm: integer;
 tmoaf: array[0..mmotaff] of integer;
 coox: array[0..mmotaff] of integer;
 cooy: array[0..mmotaff] of integer;
 suiv: boolean;

begin
 coox[0]:= 008;
 coox[1]:= coox[0]+ larg;
 coox[2]:= coox[1]+ larg;
 coox[3]:= coox[2]+ larg;
 coox[4]:= coox[0];
 coox[5]:= coox[1];
 coox[6]:= coox[2];
 coox[7]:= coox[3];

 cooy[0]:= ytext+ intli;
 cooy[1]:= cooy[0];
 cooy[2]:= cooy[0];
 cooy[3]:= cooy[0];
 cooy[4]:= cooy[0]+ intli;
 cooy[5]:= cooy[4];
 cooy[6]:= cooy[4];
 cooy[7]:= cooy[4];

 text1:= pred(nu_text);
 textp:= succ(nu_text);
 textl:= succ(textp);
 textm:= succ(textl);
 text2:= textm;
 text3:= succ(text2);
 text4:= succ(text3);

 cont:= true;
 nb:= 0;
 nufic:= tamoi;
 
 (* lecture fichier contenant protection *)
(* lect(nfic, atrava, dum);*)
 xload(false, (atrava+ 2000), atrava, 0, 22, dum);

 nb_prot:= int(peekw(atrava));
 nb_moin:= int(peekw(atrava+ 2));
 adres:= atrava+ 4;

 (* affichage message d'accroche *)
 mess1(text1);

 repeat
 (* affichage page, ligne et mot *)
(*  dum:= savmem(1, asgen14, aecra1, 004, 162, 266, 199);*)
  eftext(10, 008, ytext, 80, intli, 15, 1, aecra1, 0, textp);
  eftext(10, 085, ytext, 80, intli, 15, 1, aecra1, 0, textl);
  eftext(10, 155, ytext, 80, intli, 15, 1, aecra1, 0, textm);

 (* affichage des coordonnees du mot choisi *)
  numot:= int(hazard(0, nb_prot));
  page:= int(peekw(adres+ (numot* 6)));
  ligne:= int(peekw(adres+ 2+ (numot* 6)));
  mot:= int(peekw(adres+ 4+ (numot* 6)));
  efchif(page, -1, 067, (ytext+ 2), 80, intli, 15, aecra1);
  efchif(ligne, -1, 145, (ytext+ 2), 80, intli, 15, aecra1);
  efchif(mot, -1, 211, (ytext+ 2), 80, intli, 15, aecra1);

  (* recherche autres mots *)
  for cx:= 0 to mmotaff do tmoaf[cx]:= -1;
  place:= int(hazard(0, mmotaff));
  tmoaf[place]:= numot+ nu_prot;
  for cx:= 0 to mmotaff do
   if tmoaf[cx]= -1 then
   begin
    repeat
     suiv:= true;
     tmoaf[cx]:= int(hazard(succ(numot), succ(nb_prot+ nb_moin)))+ nu_prot;
     for cy:= 0 to pred(cx) do
      if tmoaf[cy]= tmoaf[cx] then suiv:= false;
    until suiv;
   end;

  (* affichage des differents mots *)
  for cx:= 0 to mmotaff do
   eftext(10, coox[cx], cooy[cx], larg, intli,
                                  15, 1, aecra1, 0, tmoaf[cx]);
  styleff(5, 6, 004, 162, 266, 199);

  showmouf;
  repeat
   ets:= 0;
   e_mouse(cx, cy, ets, key);
   key:= -1;
   if ets<> 0 then
    if (cy> cooy[0]) and (cy< (cooy[4]+ intli)) then
    begin
     if (cx> coox[0]) and (cx< coox[1]) then key:= 0;
     if (cx> coox[1]) and (cx< coox[2]) then key:= 1;
     if (cx> coox[2]) and (cx< coox[3]) then key:= 2;
     if (cx> coox[3]) and (cx< (coox[3]+ larg)) then key:= 3;
    end;
  until key<> -1;
  if (cy> cooy[4]) and (cy< (cooy[4]+ intli)) then key:= key+ 4;
  hidemouf;
  nb:= succ(nb);
  if key= place then
  begin
   nb:= 2;
   mess1(text3);
  end
  else
   if nb< 2 then mess1(text2) else
   begin
    arret:= true;
    mess1(text4);
   end;
 until nb> 1;
end;

{}

procedure tecran(var men: integer);
const
 hmen= 11;

var
 iobjet, trouv: boolean;
 key, bsta, mnufic, cx, choix, attend: integer;
 xg, yg, xd, yd, align: integer;
 dum: long_integer;
 lgmen, coox: array[0..4] of integer;
 cx1v, cy1v, cx2v, cy2v: array[0..3] of integer;
 numt: array[0..15] of integer;

begin
(* debug('tecran', 0, 0); *)
 lgmen[0]:= 45;
 lgmen[1]:= 45;
 lgmen[2]:= 45;
 lgmen[3]:= 45;
 lgmen[4]:= 35;

 coox[0]:= 00;
 coox[1]:= 70;
 coox[2]:= 135;
 coox[3]:= 215;
 coox[4]:= 279;

 iobjet:= false;
 chgtab:= false;

 key:= 0;
 bsta:= 0;
 e_mouse(moux, mouy, bsta, key);
 tinke(false, iobjet, -1, 0);

 if (not perdu) and (not solu) then
 repeat

  (* touche clavier *)
  if key<> 0 then
  begin
   tkey(key);
   if men> -1 then
   begin
    phidem;
    if nbmen> -1 then menuresto;
    decomp(0, atrava, agen01, 0, 0, aecra1);
    decomp(0, atrava, agen01, 0, 0, aecra2);
    pshowm;
   end;
   if act<> -1 then
   begin
    bsta:= 2;
    men:= 2;
    mmen:= 2;
    mact:= act;
    clicact(act, key, iobjet);
   end;
   nbmen:= -1;
   key:= 0;
   men:= -2;
  end 
  else

   (* fleche en haut d'ecran *)
   if mouy< hmen then
   begin
    if men= -2 then
    begin
     (* affichage du menu general horizontal *)
     mnufic:= nufic;
     nufic:= tamoi;
     men:= -1;
     phidem;
     for cx:= 0 to 4 do
      aftitre((21+cx), 0, coox[cx], 0, -1, 0,
              atext6, along6, adtext, asprit);
     pshowm;
     nufic:= mnufic;
    end
    else
    begin
     trouv:= false;
     cx:= 0;
     repeat
      if (moux> coox[cx]) and (moux< (coox[cx]+ lgmen[cx]))
       then trouv:= true else cx:= succ(cx);
     until (cx> 4) or (trouv);
     if (trouv) and (men<> cx) then
     begin
      if (men> -1) and (nbmen> -1) then menuresto;
      men:= cx;
      mmen:= cx;
      nbmen:= -1;
      if men= 0 then
      begin
       numt[0]:= 26;
       numt[1]:= 27;
       nbmen:= 1;
       align:= 0;
       plg:= 110;
       plarg:= plg;
       for cx:= 0 to nbmen do
       begin
        pokew((anumt+ (cx* 2)), numt[cx]);
        pcx[cx]:= 000;
        pcy[cx]:= succ(hmen)+ (cx* hmen);
       end;
      end;
      if men= 2 then
      begin
       numt[00]:= 28;
       numt[01]:= 46;
       numt[02]:= 31;
       numt[03]:= 32;
       numt[04]:= 33;
       numt[05]:= 34;
       numt[06]:= 36;
       numt[07]:= 37;
       numt[08]:= 38;
       numt[09]:= 39;
       numt[10]:= 40;
       numt[11]:= 41;
       numt[12]:= 42;
       numt[13]:= 43;
       nbmen:= 13;
       align:= (succ(nbmen) div 2);
       plg:= 70;
       plarg:= plg* 2;
       for cx:= 0 to (nbmen div 2) do
       begin
        pokew((anumt+ (cx* 2)), numt[cx]);
        pcx[cx]:= 96;
        pcy[cx]:= succ(hmen)+ (cx* hmen);
       end;
       for cx:= succ(nbmen div 2) to nbmen do
       begin
        pokew((anumt+ (cx* 2)), numt[cx]);
        pcx[cx]:= pcx[cx- (succ(nbmen) div 2)]+ plg;
        pcy[cx]:= pcy[cx- (succ(nbmen) div 2)];
       end;
      end;
      if men= 3 then
      begin
       numt[00]:= 51;
       nbmen:= 0;
       align:= 0;
       plg:= 85;
       plarg:= plg;
       for cx:= 0 to nbmen do
       begin
        pokew((anumt+ (cx* 2)), numt[cx]);
        pcx[cx]:= 215;
        pcy[cx]:= succ(hmen)+ (cx* hmen);
       end;
      end;
      if nbmen> -1 then
      begin
       phidem;
       xg:= pcx[0];
       yg:= pcy[0];
       xd:= xg+ int(plarg);
       yd:= pcy[nbmen]+ hmen+ 24;
       deptra:= savmem(0, aecra1, atrava, xg, yg, xd, yd);

       dum:= afmen(0, align, xg, yg, succ(nbmen), anumt, 0, 0,
                    atext6, along6, adtext, 0, asprit);

(*for cx:= 0 to nbmen do
begin
rect(pcx[cx], pcy[cx], (pcx[cx]+ plg), (pcy[cx]+ hmen));
end;*)

       pshowm;
      end;
     end;
    end;
   end
   else

    (* click souris gauche *)
    if bsta= 1 then
    begin
     phidem;
     trouv:= false;
     if (men> -1) and (nbmen> -1) then
     begin
      menuresto;
      choix:= -1;
      cx:= 0;
      repeat
       if (moux> pcx[cx]) and (moux< (pcx[cx]+ plg)) and
          (mouy> pcy[cx]) and (mouy< (pcy[cx]+ hmen)) then trouv:= true
       else cx:= succ(cx);
      until (cx> nbmen) or (trouv);
     end;
     decomp(0, atrava, agen01, 0, 0, aecra1);
     decomp(0, atrava, agen01, 0, 0, aecra2);
     pshowm;
     if trouv then
     begin
      (* pour le menu horizontal *)
      if men= 0 then
      begin
       mdep:= cx;
       clicdep(cx, key, iobjet);;
      end
      else
       if men= 2 then
       begin
        mact:= cx;
        clicact(cx, key, iobjet);
       end;
     end
     else
     begin
      (* pour le menu vertical *) 
      cx1v[0]:= 265;        (* Attendre 12 heu *)
      cy1v[0]:= 124;
      cx2v[0]:= 286;
      cy2v[0]:= 137;
      cx1v[1]:= 287;        (* Attendre 1 heu *)
      cy1v[1]:= 124;
      cx2v[1]:= 315;
      cy2v[1]:= 137;
      cx1v[2]:= 265;        (* Attendre 5 min *)
      cy1v[2]:= 138;
      cx2v[2]:= 315;
      cy2v[2]:= 174;
      cx1v[3]:= 281;        (* Fin *)
      cy1v[3]:= 305;
      cx2v[3]:= 170;
      cy2v[3]:= 193;

      cx:= 0;
      repeat
       if (moux> cx1v[cx]) and (moux< cx2v[cx]) and
          (mouy> cy1v[cx]) and (mouy< cy2v[cx]) then trouv:= true
       else cx:= succ(cx);
      until (cx> 3) or (trouv);
      if trouv then
      begin
       if cx< 3 then
       begin
        mmen:= 6;
        mtem:= cx;
        clictem(cx, iobjet);
       end
       else
        if cx= 3 then stopjeu(iobjet);
      end;

     end;
     men:= -2;  (* pas de barre menu *)
    end
    else

     (* click souris droit *)
     if bsta= 2 then
     begin
      if men> -1 then
      begin
       phidem;
       if nbmen> -1 then menuresto;
       decomp(0, atrava, agen01, 0, 0, aecra1);
       decomp(0, atrava, agen01, 0, 0, aecra2);
       pshowm;
      end;
      if (mmen= 0) and (mdep<> -1) then clicdep(mdep, key, iobjet)
      else
       if (mmen= 2) and (mact<> -1) then clicact(mact, key, iobjet)
       else
        if (mmen= 6) and (mtem<> -1) then clictem(mtem, iobjet);
     end;
 until key= 0;
end;

{}

(* NIVEAU 1 *)
procedure mismem;
var
 long, adres: long_integer;

begin
(* debug('mismem', 0, 0); *)
 xload(false, aecra1, adgene, 0, 5, long);  (* travail en ecran 1 *)
 aact01:= adgene+ long;
 mlecte(032, aact01, aact02);                   (* act *)
 mlecte(033, aact02, aact03);
 mlecte(034, aact03, aact04);
 mlecte(035, aact04, aact05);
 mlecte(036, aact05, aact06);
 mlecte(037, aact06, aact07);
 mlecte(038, aact07, aact08);
 mlecte(039, aact08, aact09);
 mlecte(040, aact09, aact10);
 mlecte(041, aact10, aact11);
 mlecte(042, aact11, aact12);
 mlecte(043, aact12, aact13);
 mlecte(044, aact13, aact14);
 mlecte(045, aact14, aact15);
 mlecte(046, aact15, aact16);
 mlecte(047, aact16, adep01);
 mlecte(062, adep01, adep02);                   (* depl *)
 mlecte(063, adep02, adep03);
 mlecte(064, adep03, adep04);
 mlecte(065, adep04, adep05);
 mlecte(066, adep05, adep06);
 mlecte(067, adep06, adep07);
 mlecte(068, adep07, adep08);
 mlecte(069, adep08, adep09);
 mlecte(070, adep09, adep10);
 mlecte(071, adep10, adep11);
 mlecte(072, adep11, adep12);
 mlecte(073, adep12, adep13);
 mlecte(074, adep13, adep14);
 mlecte(075, adep14, adep15);
 mlecte(076, adep15, adep16);
 mlecte(077, adep16, adep17);
 mlecte(078, adep17, adep18);
 mlecte(079, adep18, adep19);
 mlecte(080, adep19, adep20);
 mlecte(081, adep20, adep21);
 mlecte(082, adep21, adep22);
 mlecte(083, adep22, adep23);
 mlecte(084, adep23, adep24);
 mlecte(085, adep24, adep25);
 mlecte(086, adep25, adep26);
 mlecte(087, adep26, adep27);
 mlecte(088, adep27, adep28);
 mlecte(089, adep28, adep29);
 mlecte(090, adep29, adep30);
 mlecte(091, adep30, adep31);
 mlecte(092, adep31, agen01);
 mlecte(000, agen01, agen02);                   (* ngen *)
 mlecte(001, agen02, agen03);
 mlecte(002, agen03, agen04);
 mlecte(003, agen04, agen05);
 mlecte(004, agen05, agen06);
 mlecte(005, agen06, agen07);
 mlecte(006, agen07, agen08);
 mlecte(007, agen08, agen09);
 mlecte(008, agen09, agen10);
 mlecte(009, agen10, agen11);
 mlecte(010, agen11, agen12);
 mlecte(011, agen12, agen13);
 mlecte(012, agen13, agen14);
 mlecte(013, agen14, agen15);
 mlecte(014, agen15, agen16);
 mlecte(015, agen16, agen17);
 mlecte(016, agen17, agen18);
 mlecte(017, agen18, agen19);
 mlecte(018, agen19, agen20);
 mlecte(019, agen20, agen21);
 mlecte(020, agen21, agen22);
 mlecte(021, agen22, agen24);
 mlecte(023, agen24, agen25);
 mlecte(024, agen25, agen27);
 mlecte(026, agen27, agen28);
 mlecte(027, agen28, agen29);
 mlecte(028, agen29, agen30);
 mlecte(029, agen30, agen31);
 mlecte(030, agen31, agen32);
 if memoire> mmini then mlecte(031, agen32, ainv02) else
 begin
  mlecte(031, agen32, agen33);
  mlecte(105, agen33, agen34);
  mlecte(106, agen34, agen35);
  mlecte(107, agen35, agen36);
  mlecte(108, agen36, agen37);
  mlecte(109, agen37, ainv02);
 end;
 mlecte(050, ainv02, ainv03);                   (* inv *)
 mlecte(051, ainv03, asav00);
 mlecte(052, asav00, asav01);                  (* sav *)
 mlecte(053, asav01, asav02);
 mlecte(054, asav02, asav03);
 mlecte(055, asav03, asav04);
 mlecte(056, asav04, asav05);
 mlecte(057, asav05, asav06);
 mlecte(058, asav06, asav07);
 mlecte(059, asav07, asav08);
 mlecte(060, asav08, asav09);
 mlecte(061, asav09, aaob01);
 mlecte(094, aaob01, aaob02);                   (* act obj *)
 mlecte(095, aaob02, aaob03);
 mlecte(096, aaob03, aaob04); 
 mlecte(097, aaob04, aaob05);
 mlecte(098, aaob05, aaob06);
 mlecte(099, aaob06, aaob07);
 mlecte(100, aaob07, aaob08);
 mlecte(101, aaob08, aaob09);
 mlecte(102, aaob09, amas01);
 mlecte(110, amas01, amas02);                   (* masque *)
 mlecte(111, amas02, amas03);
 mlecte(112, amas03, amas04);                   
 mlecte(113, amas04, amas05);
 mlecte(114, amas05, amas06);
 mlecte(115, amas06, amas07);
 mlecte(116, amas07, amas08);
 mlecte(117, amas08, amas09);
 mlecte(118, amas09, amas10);
 mlecte(119, amas10, amas11);
 mlecte(120, amas11, atext0);
 mlect(01, atext0, along0);                      (* texte *)
 mlect(00, along0, atext1);
 mlect(03, atext1, along1);
 mlect(02, along1, atext2);
 mlect(05, atext2, along2);
 mlect(04, along2, atext3);
 mlect(07, atext3, along3);
 mlect(06, along3, atext4);
 mlect(09, atext4, along4);
 mlect(08, along4, atext5);
 mlect(11, atext5, along5);
 mlect(10, along5, atext6);
 mlect(13, atext6, along6);
 mlect(12, along6, atext7);
 mlect(15, atext7, along7);
 mlect(14, along7, asgen12);
end;

{}

procedure tjouer;
var
 chargeme: boolean;
 ets, cox, coy, key, gen: integer;
 dtemps: long_integer;

begin
(* debug('tjouer', 0, 0); *)
 gen:= -2;
 solu:= false;
 deptra:= 0;
 initialisation;
 chngmouse(0, 5);
 posmouse(131, 85, 130, 84, 132, 86);
 posmouse(131, 85, 0, 0, 304, 199);
 pamb(peekw(depadr(adlieu, wambian)));      (* SON-ST *)
 changanim;
 efnoir;
 damb(0);                                   (* SON-ST *)
 calch(s.nmin);
 pendule(false, 0);
 pinitani;
 procini(0, false);

(* if perdu then
 begin
  showmouf;
  repeat
   e_mouse(cox, coy, ets, key);
   if ets<> 0 then
   begin
    ets:= 0;
    key:= 0;
    if coy> 173 then
    begin 
     if (cox> 085) and (cox< 131) then key:= kou;
     if (cox> 130) and (cox< 176) then key:= kno;
    end;
   end;
  until (key= kou) or (key= kno);
  hidemouf;
  if key= kou then
  begin
   perdu:= false;
   nufic:= tamoi;
   mess1(1);
  end
  else arret:= true;
 end;*)

(* pour version ST *)
 perdu:= false;
(* *)

 if not perdu then
 begin
(*  key:= 0;
  repeat*)
  (* pour version ST *)  
(*   nufic:= tamoi;
   mess1(1); *)
 (* *)  
(*   showmouf;
   repeat
    e_mouse(cox, coy, ets, key);
    if ets<> 0 then
    begin
     ets:= 0;
     key:= 0;
     if coy> 173 then
     begin 
      if (cox> 085) and (cox< 131) then key:= kou;
      if (cox> 130) and (cox< 176) then key:= kno;
     end;
    end;
   until (key= kou) or (key= kno);
   hidemouf;
   if key= kou then
   begin
    nufic:= tamoi;
    mess1(16);
    xcharg(chargeme);
   end;
  until (chargeme) or (key= kno); *)
(* diskinit(false); *)
  pinitani;
  if not cont then pcont;
  nufic:= tgene;
  affmen09;
  atkey:= 0;
  mact:= -1;
  mdep:= -1;
  mobj:= -1;
  pokew(aheure, 0);
  pshowm;
  repeat tecran(gen) until (solu) or (perdu) or (arret);
 end;
 if solu then arret:= true;
end;

{}

(* POUR ST *)
procedure xfin;
begin
end;
(* *)

{}

(* NIVEAU 0 *)
begin
 loadass;   (* charg ass abso *)
(* inimus(atrava);*)  (* commentaire pour develop *)  (* SON-ST *)
 (* recherche adresse sauvegarde *)
 s.rsec:= 9320;
 s.mmin:= 30001;
 s.mlieu:= -31166;
 s.pourc:= 4951;
 asauv:= adsauv;

 (* appel routine de place *)
(* memoire:= memlib; *)
 memoire:= 700000; (* pour test *)
 (* adresse ecran *)
 aecra2:= adec;
 (* reserv memoire *)
 aecra1:= memres;
 while (aecra1 mod 256)<> 0 do aecra1:= succ(aecra1);
 anumt:= aecra1+ 48;           (* fichier numero des textes menus *)
 if memoire> mmini then adgene:= anumt+ 48000 else
  adgene:= anumt+ 32000;      (* fichier reponse gene *)

 mismem;

 asprit:= asgen12+ lsgen12;    (* fichier sprite *)
 aloupe:= asprit+ lsprit;
 xysouris:= aloupe+ 340;       (* coordonnees de click *)
 asouris:= xysouris+ 4;
(* souris: 1 mot bouton
           1 mot coord x
           1 mot coord y
           1 mot clavier 
           1 mot joystick
           1 mot invalide
           4 mot de coord de clip
           1 mot bit 0 … 1 anim en cours autre anim fini bonhomme 0
                     1            "                 "             1 *)
 aheure:= asouris+ 22;      (* 22 qd bonhomme et toujours derriere souris *)
 aflag1:= aheure+ 4;        (* serie de flag fait suite a la souris *)
 aflag5:= aflag1+ 1;
 aflag10:= aflag5+ 1;
(**)
 apal:= aflag10+ 2;
(**)
 arempe:= apal+ 32;         (* remap perso *)
 adtext:= arempe+ 16;       (* decomp text *)
 adessi:= adtext+ 640;      (* decomp et stock dessin *)
 amempa:= adessi+ 2;
 azmasq:= adessi+ 8500;     (* masque pour anim *)
 atrava:= azmasq+ 8040;     (* travail *)
 adesou:= atrava+ 22000;    (* dessins souris *)
 aoblo:= adesou+ 10000;
 axoblo:= aoblo+ 40;
 ayoblo:= axoblo+ 20;
 aoufer:= ayoblo+ 20;       (* base de chargement pour un lieu *)

 cont:= false;
 arret:= false;
 perdu:= false;
 ficmem;
(* inimus(atrava); pour ST FINAL *)             (* SON-ST *)
 repeat tjouer until arret;
 coupson;   (* SON-ST *)
 arret:= false;
(* repeat xfin until arret; pour ST FINAL *)
 finjeu;
 fini;      (* SON-ST *)
end.

