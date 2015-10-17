DEFINITION MODULE Gmemenue;

EXPORT
  Gmemenue, Deskmenu, Datemenu, Blockmen, Markmenu, Suchmenu,
  Editmenu, Programm, Golemedi, Acc1, Acc2, Acc3,
  Acc4, Acc5, Acc6, Neuertex, Laden, Bllesen,
  Sichern, Speicher, Blspeich, Textloes, Konfigea, Backupan,
  Konfigsi, Qallsave, Ende, Blcut, Blversch, Blkkopie,
  Bledit, Blanfang, Blende, Zeilmark, Allmark, Gemscrap,
  Setzema1, Setzema2, Setzema3, Zumarke1, Zumarke2, Zumarke3,
  Zeilennr, Letztepo, Fehlerme, Wortsuch, Grosskle, Suche,
  Tausche, Pickwort, Picktaus, Nochmsuc, Overwrit, Autoinde,
  Next, Help, Bleinrue, Mcompile, Datum, Compilie,
  Comprun, Qmake, Makeexec, Gmeinfo, Version;


CONST
  Gmemenue =   0;  (* Menuebaum *)
  Deskmenu =   3;  (* TITLE in Baum GMEMENUE *)
  Datemenu =   4;  (* TITLE in Baum GMEMENUE *)
  Blockmen =   5;  (* TITLE in Baum GMEMENUE *)
  Markmenu =   6;  (* TITLE in Baum GMEMENUE *)
  Suchmenu =   7;  (* TITLE in Baum GMEMENUE *)
  Editmenu =   8;  (* TITLE in Baum GMEMENUE *)
  Programm =   9;  (* TITLE in Baum GMEMENUE *)
  Golemedi =  12;  (* STRING in Baum GMEMENUE *)
  Acc1     =  14;  (* STRING in Baum GMEMENUE *)
  Acc2     =  15;  (* STRING in Baum GMEMENUE *)
  Acc3     =  16;  (* STRING in Baum GMEMENUE *)
  Acc4     =  17;  (* STRING in Baum GMEMENUE *)
  Acc5     =  18;  (* STRING in Baum GMEMENUE *)
  Acc6     =  19;  (* STRING in Baum GMEMENUE *)
  Neuertex =  22;  (* STRING in Baum GMEMENUE *)
  Laden    =  23;  (* STRING in Baum GMEMENUE *)
  Bllesen  =  24;  (* STRING in Baum GMEMENUE *)
  Sichern  =  26;  (* STRING in Baum GMEMENUE *)
  Speicher =  27;  (* STRING in Baum GMEMENUE *)
  Blspeich =  28;  (* STRING in Baum GMEMENUE *)
  Textloes =  29;  (* STRING in Baum GMEMENUE *)
  Konfigea =  31;  (* STRING in Baum GMEMENUE *)
  Backupan =  32;  (* STRING in Baum GMEMENUE *)
  Konfigsi =  34;  (* STRING in Baum GMEMENUE *)
  Qallsave =  35;  (* STRING in Baum GMEMENUE *)
  Ende     =  36;  (* STRING in Baum GMEMENUE *)
  Blcut    =  38;  (* STRING in Baum GMEMENUE *)
  Blversch =  39;  (* STRING in Baum GMEMENUE *)
  Blkkopie =  40;  (* STRING in Baum GMEMENUE *)
  Bledit   =  41;  (* STRING in Baum GMEMENUE *)
  Blanfang =  43;  (* STRING in Baum GMEMENUE *)
  Blende   =  44;  (* STRING in Baum GMEMENUE *)
  Zeilmark =  45;  (* STRING in Baum GMEMENUE *)
  Allmark  =  46;  (* STRING in Baum GMEMENUE *)
  Gemscrap =  48;  (* STRING in Baum GMEMENUE *)
  Setzema1 =  50;  (* STRING in Baum GMEMENUE *)
  Setzema2 =  51;  (* STRING in Baum GMEMENUE *)
  Setzema3 =  52;  (* STRING in Baum GMEMENUE *)
  Zumarke1 =  53;  (* STRING in Baum GMEMENUE *)
  Zumarke2 =  54;  (* STRING in Baum GMEMENUE *)
  Zumarke3 =  55;  (* STRING in Baum GMEMENUE *)
  Zeilennr =  57;  (* STRING in Baum GMEMENUE *)
  Letztepo =  58;  (* STRING in Baum GMEMENUE *)
  Fehlerme =  60;  (* STRING in Baum GMEMENUE *)
  Wortsuch =  62;  (* STRING in Baum GMEMENUE *)
  Grosskle =  63;  (* STRING in Baum GMEMENUE *)
  Suche    =  65;  (* STRING in Baum GMEMENUE *)
  Tausche  =  66;  (* STRING in Baum GMEMENUE *)
  Pickwort =  67;  (* STRING in Baum GMEMENUE *)
  Picktaus =  68;  (* STRING in Baum GMEMENUE *)
  Nochmsuc =  69;  (* STRING in Baum GMEMENUE *)
  Overwrit =  71;  (* STRING in Baum GMEMENUE *)
  Autoinde =  72;  (* STRING in Baum GMEMENUE *)
  Next     =  74;  (* STRING in Baum GMEMENUE *)
  Help     =  75;  (* STRING in Baum GMEMENUE *)
  Bleinrue =  77;  (* STRING in Baum GMEMENUE *)
  Mcompile =  79;  (* STRING in Baum GMEMENUE *)
  Datum    =  80;  (* STRING in Baum GMEMENUE *)
  Compilie =  82;  (* STRING in Baum GMEMENUE *)
  Comprun  =  83;  (* STRING in Baum GMEMENUE *)
  Qmake    =  84;  (* STRING in Baum GMEMENUE *)
  Makeexec =  85;  (* STRING in Baum GMEMENUE *)
  Gmeinfo  =   1;  (* Formular/Dialog *)
  Version  =   5;  (* STRING in Baum GMEINFO *)

END Gmemenue.
