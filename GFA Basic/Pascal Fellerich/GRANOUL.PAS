{---------------------------------------------------------------------}
{-                                                                   -}
{-  GRANOULLUS -   VAX 11 version                                    -}
{-                                                                   -}
{-                                                                   -}
{-                                                                   -}
{-                                                                   -}
{-                                                                   -}
{---------------------------------------------------------------------}
PROGRAM Granoullus(input,output);

%include '[student.dia.dia2.weiland_a.library]hallib.inc'

CONST   empty=0;
        monster=1;
        caval=2;
        trap=3;
        mief=4;
        { interna }
        monster_wins=10;        {Interne 'messages' }
        caval_wins=9;
        figure_locked=8;
        illmove=7;
        ok=0;                   {Fehlermeldungen                }
        no_dn=-1;   
        no_up=-2;
        { grafik  ---  Terminal-steuerung! }
        Bs=CHR(8);
        Tab=CHR(9);
        SO=Chr(14);
        SI=Chr(15);
        ESC=CHR(27);
        CSI=ESC+'[';
        Csr_On=ESC+'e';
        Csr_Off=ESC+'f';
        Clline=ESC+'o'+ESC+'K';
        NumericKBD=ESC+'<';
        Titel=
        ' GRANOULLUS :  tapez ''*'' pour interrompre le jeu, ESC pour redessiner l''Çcran';
        { verschiedene Ausgabepositionen }
        xwarn=4;
        ywarn=27;
        xinfo=2;
        yinfo=28;
        maxwidth=38;
        maxheigth=10;

VAR     field:  ARRAY[0..maxwidth-1,0..maxheigth-1] OF INTEGER;
        xmonst,ymonst:  INTEGER;                {MONSTERPOSITION}
        xcaval,ycaval:  INTEGER;                {Cavalier}
        xmief,ymief:    INTEGER;                {Wo's stinkt}
        xpos,ypos:      INTEGER;                {allg. xy cursorpos}
        xoff,yoff:      INTEGER;                {allg. xy offsets}
        fehler:         INTEGER;                {Allgemeiner fehlerstatus}
        fwidth,fheigth: INTEGER;                {Masse Speilfeld}


{********************************** GRAFIK ************************************}

{*********************************************************************}
{* Eine Reihe Funktionen, insbesondere jene, die die Grafik          *}
{* betreffen, sind in der Version fuer VAX-11 Pascal in der          *}
{* HALLIB zu finden.                                                 *}
{*                                                                   *}
{*********************************************************************}
{
 PROCEDURE print(str:string);  >fehlerfreier WRITE => BASIC PRINT
 PROCEDURE at(x,y:INTEGER);   
 PROCEDURE cursor_on;
 PROCEDURE cursor_off;
 PROCEDURE save_cursor;
 PROCEDURE restore_cursor;
 PROCEDURE cls;
 PROCEDURE InitKeyboard;
 PROCEDURE Init_random;
 FUNCTION  RND(I:INTEGER):INTEGER;
}
{*********************************************************************}
{* cursor_at: logischen cursor zur Spielfeldposition (!) x,y bringen *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE cursor_at(x,y:INTEGER);
BEGIN
  at(xoff+1+2*x,yoff+1+2*y);
END;  {endproc}

{*********************************************************************}
{* draw_screen(x,y,w,h): Bildschirm aufbauen.                        *}
{*  Startposition x,y, mit der Spielfeldbreite/hoehe w/h             *}
{*                                                                   *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE draw_screen(x,y,w,h:INTEGER);
VAR     xl,yl:INTEGER;
BEGIN
  cls; print(Titel);
  h:=2*h; at(x,y);                      {Cursor setzen                  }
  xl:=x+1; yl:=y+1;                     {Interne Position               }
  print(SO+chr(108));                   {Grafikzeichen einschalten      }
  {Ecke oben links  ^^    }
  WHILE xl<x+w DO BEGIN
    PRINT(CHR(113)+CHR(119)); xl:=xl+1; {Obere Reihe                    }
  END;  {endwhile}
  print(CHR(113)+CHR(107));             {Abschluss mit Ecke oben rechts }
  WHILE yl<y+h-2 DO BEGIN
    xl:=x+1; at(x,yl);
    WHILE xl<x+w+1 DO BEGIN             {Zwischenreihe 1                }
      print(CHR(120)+' '); xl:=xl+1;
    END;  {endwhile}
    print(CHR(120));
    xl:=x+1; yl:=yl+1; at(x,yl);
    print(CHR(116));
    WHILE xl<x+w DO BEGIN               {Zwischenreihe 2                }
      print(CHR(113)+CHR(110)); xl:=xl+1;
    END;  {endwhile}
    print(CHR(117)); yl:=yl+1;
  END;  {endwhile}
  xl:=x+1; at(x,yl);
  WHILE xl<x+w+1 DO BEGIN               {Zwischenreihe 1 wiederholen    }
    print(CHR(120)+' '); xl:=xl+1;
  END;  {endwhile}
  print(CHR(120)); xl:=x+1; yl:=yl+1; at(x,yl);
  print(CHR(109));                      {Ecke unten links               }
  WHILE xl<x+w DO BEGIN                 {Endreihe                       }
    print(CHR(113)+CHR(118)); xl:=xl+1;
  END;  {endwhile}
  print(CHR(113)+CHR(106)+SI);          {Ecke unten rechts              }
 {Feldinhalt darstellen:---------------------------------               }
  FOR yl:=0 TO fheigth-1 DO BEGIN       {Alle Arrayelemente durchgehen  }
    FOR xl:=0 TO fwidth-1 DO BEGIN
      CASE field[xl,yl] OF 
      trap: BEGIN                       {und Symbole darstellen...      }
          cursor_at(xl,yl); print('@');
        END;
      mief: BEGIN
          cursor_at(xl,yl); print('#');
        END;
      monster: BEGIN
          cursor_at(xl,yl); print('M');
        END;
      caval: BEGIN
          cursor_at(xl,yl); print('C');
        END;
      END;  {endcase}
    END;  {endfor xl}
  END;  {endfor yl}
END;  {endproc}

{*********************************************************************}
{* put_caval: Cavalier auf x,y setzen. Dabei wird                    *}
{*    1. die globale Variable xcaval & ycaval gesetzt                *}
{*    2. die alte Position von C geloescht und eine Falle gesetzt    *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE put_caval(x,y:INTEGER);
BEGIN
  IF xcaval>=0 THEN BEGIN       {Nur wenn die alte Pos. gueltig war}
    cursor_at(xcaval,ycaval);   {alte position lîschen & Falle setzen}
    field[xcaval,ycaval]:=trap;
  END;  {endif}
  cursor_at(x,y); print('C'+Bs);     {C. an neue Position}
  field[x,y]:=caval; xcaval:=x; ycaval:=y;
END;  {endproc}

{*********************************************************************}
{* set_mief: Setzt 'Gestank' auf x,y. Dabei wird                     *}
{*   1. die alte position geloescht -> Feld wird wieder frei         *}
{*   2. die globale var. gesetzt...                                  *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE set_mief(x,y:INTEGER);
BEGIN
  IF xmief>=0 THEN BEGIN
    cursor_at(xmief,ymief);
    print(' '); field[xmief,ymief]:=empty;
  END;  {endif}
  cursor_at(x,y); print('#'+Bs);
  field[x,y]:=mief; xmief:=x; ymief:=y;
END;  {endproc}

{*********************************************************************}
{* put_monster: Monster auf x,y setzen. Dabei wird                   *}
{*    1. die globale variable xmonst,ymonst gesetzt                  *}
{*    2. ein 'Gestank' auf der alten Position hinterlassen           *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE put_monster(x,y:INTEGER);
BEGIN
  IF xmonst>=0 THEN set_mief(xmonst,ymonst);    {Gestank}
  cursor_at(x,y); print('M'+Bs);                {Monster jetzt dort}
  field[x,y]:=monster; xmonst:=x; ymonst:=y;
END;  {endproc}

{*********************************************************************}
{* VAX-Terminal: PIIEEP!;   Atari ST: BING!                          *}
{*********************************************************************}
PROCEDURE bell;
BEGIN
  PRINT(CHR(7));
END;  {endproc}

{*********************************************************************}
{* collision_at: Kollisionszeichen  (x) ausgeben                     *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE collision_at(x,y:INTEGER);
BEGIN
  cursor_at(x,y); print('X'+Bs);
END;  {endproc}

{*********************************************************************}
{* warn: Warnmeldung/Fehlermeldung an fester Position ausgeben       *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE warn(str:STRING);
BEGIN
  save_cursor;
  at(xwarn,ywarn); print(Clline+str);
  restore_cursor;
END;  {endproc}

{*********************************************************************}
{* info: Informationszeile/Fragezeile                                *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE info(str:STRING);
BEGIN
  save_cursor;
  at(xinfo,yinfo); print(Clline+str);
  restore_cursor;
END;  {endproc}

{******************************** Playroutines ********************************}

{*********************************************************************}
{* arrayfill_empty: belegt alle Eintraege im field-Array mit 'Empty' *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE arrayfill_empty;
VAR     x,y:INTEGER;
BEGIN
  FOR y:=0 to fheigth DO
    FOR x:=0 to fwidth DO
      field[x,y]:=empty;
END;

{*********************************************************************}
{* lt,rt,up,dn: prozeduren zur manipulation der feldkoordinaten      *}
{*   bei lt,rt wird ein wraparound durchgefuehrt,                    *}
{*   bei up,dn wird der globale fehlerstatus in 'fehler' veraendert  *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE lt(VAR x:INTEGER);
BEGIN
  IF x>0 THEN x:=x-1
  ELSE x:=fwidth-1;
END;  {endproc}

PROCEDURE rt(VAR x:INTEGER);
BEGIN
  IF x<fwidth-1 THEN x:=x+1
  ELSE x:=0;
END;  {endproc}

PROCEDURE up(VAR y:INTEGER);
BEGIN
  IF y>0 THEN y:=y-1
  ELSE fehler:=no_up;
END;  {endproc}

PROCEDURE dn(VAR y:INTEGER);
BEGIN
  IF y<fheigth-1 THEN y:=y+1
  ELSE fehler:=no_dn;
END;  {endproc}

{*********************************************************************}
{* display_error: zeigt den status der globalen Fehlervariable       *}
{*   als Text an.                                                    *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE display_error;
BEGIN
  CASE fehler OF
  no_up: warn('Le pìle nord ne peut àtre surpassÇ');
  no_dn: warn('Le pìle sud ne peut àtre surpassÇ');
  END;  {endcase}
END;  {endproc}

{*********************************************************************}
{* user_select: Eingaberoutine. Der Benutzer steuert mittels des     *}
{*   Zehnerblockes den Cursor                                        *}
{*   Alle nicht-steuerzeichen werden weitergegeben an den Aufrufer.  *}
{*                                                                   *}
{*********************************************************************}
FUNCTION user_select:INTEGER;
VAR     key:INTEGER;
        flag:BOOLEAN;
BEGIN
  cursor_at(xpos,ypos);       {Globale logische cursorposition}
  cursor_on; flag:=FALSE;
  REPEAT
    fehler:=ok; inkey(key);
    CASE key OF
    ORD('1'): BEGIN             {</}
      lt(xpos); dn(ypos);
      END;
    ORD('2'):                   {DOWN}
      dn(ypos);
    ORD('3'): BEGIN             {\>}
      rt(xpos); dn(ypos);
      END;
    ORD('4'):                   {LEFT}
      lt(xpos);
    ORD('6'):                   {RIGHT}
      rt(xpos);
    ORD('6'): BEGIN;            {<\}
      lt(xpos); up(ypos);
      END;
    ORD('6'):                   {UP}
      up(ypos);
    ORD('6'): BEGIN             {/>}
      rt(xpos); up(ypos);
      END;
    OTHERWISE
      flag:=TRUE;
    END;  {endcase}
    display_error;              {Fehlerstatus angeben }
    cursor_at(xpos,ypos);
  UNTIL flag;
  USER_SELECT:=key;
END;  {endfunc}

{*********************************************************************}
{* set_algo_var:                                                     *}
{*   Initialisiert die Variablen des eigentlichen Algorithmus'       *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE set_algo_var;
BEGIN
  xmonst:=-1; ymonst:=-1;       {MONSTERPOSITION ALT}
  xcaval:=-1; ycaval:=-1;
  xmief:=-1; ymief:=-1;
  fehler:=ok;                   {Allgemeiner fehlerstatus}
END;  {endproc}

{*********************************************************************}
{* enter_parameter: diverse Einstellungen vornehmen                  *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE enter_parameter;
BEGIN
  WRITELN;
  REPEAT
    PRINT(Tab+'Largeur da la planäte: (3..38)'+Tab); READLN(fwidth);
  UNTIL (fwidth>=3) AND (fwidth<=maxwidth);
  REPEAT
    PRINT(Tab+'Hauteur da la planäte: (3..10)'+Tab); READLN(fheigth);
  UNTIL (fheigth>=3) AND (fheigth<=maxheigth);
  yoff:=3; xoff:=(40-fwidth);
END;  {endproc}

{*********************************************************************}
{* answer: Liest y oder n von der tastatur ein.                      *}
{*   Liefert TRUE bei 'y' oder FALSE bei 'n'                         *}
{*   Alle anderen Tasten sind ungueltig                              *}
{*                                                                   *}
{*********************************************************************}
FUNCTION answer:BOOLEAN;
VAR     key:INTEGER;
BEGIN
  REPEAT
    inkey(key);
  {UNTIL (key=ORD('y')) OR (key=ORD('Y')) OR (key=ORD('n')) OR (key=ORD('N'));}
  UNTIL CHR(key) IN ['y','Y','n','N'];
  answer:=(key=ORD('y')) OR (key=ORD('Y'))
END;  {endfunc}

{*********************************************************************}
{* perform_menu: Zeigt Auswahlmenue an, nimmt Einstellungen vor      *}
{*   etc. Liefert FALSE wenn Spielende gewuenscht ist.               *}
{*                                                                   *}
{*********************************************************************}
FUNCTION perform_menu:BOOLEAN;
VAR     key:INTEGER;
        raus,tmp:BOOLEAN;
BEGIN
  REPEAT
    raus:=TRUE; cls; 
    at(5,3);  print('LE JEU DE LA PLANETE GRANOULLUS    ');
    at(5,4);  print('===============================    ');
    at(5,6);  print('  7 8 9                            ');
    at(5,7);  print('   \|/                             ');
    at(5,8);  print(' 4-- --6                           ');
    at(5,9);  print('   /|\                             ');
    at(5,10); print('  1 2 3                            ');
    at(5,12); print('Plat du jour:');
    at(5,13); print(' 1. Modifier les dimensions de la planäte');
    at(5,14); print(' 2. Nouvelle partie');
    at(5,15); print(' 3. Quitter');
    at(5,17); print('->');
    cursor_on;
    REPEAT
      inkey(key);
    UNTIL (key>=ORD('1')) AND (key<=ORD('3'));
    print(CHR(key)); cursor_off;
    CASE key OF
    ORD('1'): BEGIN
        enter_parameter; raus:=FALSE; tmp:=TRUE;
      END;
    ORD('2'): tmp:=TRUE;
    ORD('3'): tmp:=FALSE;
    END;  {endcase}
  UNTIL raus;
  perform_menu:=tmp;
END;  {endfunc}

{*********************************************************************}
{* init_figures: setzt Monster und Cavalier auf zufaellige pos.      *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE init_figures;
BEGIN
  put_monster(RND(fwidth),RND(fheigth));
  REPEAT
    xpos:=RND(fwidth);       {GLOBALE logische csr-pos setzen}
    ypos:=RND(fheigth);
  UNTIL (xpos<>xmonst) AND (ypos<>ymonst);
  put_caval(xpos,ypos);
END;  {endproc}

{*********************************************************************}
{* calc_distance: berechnet die kleinste distanz zwischen 2 punkten. *}
{*   Dabei wirt das left-right wraparound mit beruecksichtigt        *}
{*                                                                   *}
{*********************************************************************}
FUNCTION calc_distance(x1,y1,x2,y2:INTEGER):INTEGER;
VAR     dx,dy,d1,d2:INTEGER;
BEGIN
  dx:=ABS(x1-x2); dy:=ABS(y1-y2);
  d1:=SQR(dx)+SQR(dy);          {Quadratische distanz 1}
  d2:=SQR(fwidth-dx)+SQR(dy);   {id, #2}
  IF (d1=5) OR (d2=5) THEN      {Sonderfall: Caval in reichweite!!}
    calc_distance:=5
  ELSE BEGIN
    IF d1>d2 THEN calc_distance:=d2     {wegen der ost-west-verbindung :-)}
    ELSE calc_distance:=d1;
  END;  {endif}
END;  {endfunc}

{*********************************************************************}
{* check_monstermove: testet, ob die position x,y fuer das Monster   *}
{*   zulaessig ist.                                                  *}
{*                                                                   *}
{*********************************************************************}
FUNCTION check_monstermove(x,y:INTEGER):INTEGER;
BEGIN
  CASE field[x,y] OF
  mief,trap,monster:        {Ein solches Feld kommt aufgrund Bewertung}
    check_monstermove:=figure_locked;        {normalerweise nicht vor.}
  caval: check_monstermove:=monster_wins;
  empty: check_monstermove:=ok;
  END;  {endcase}
END;  {endfunc}

{*********************************************************************}
{* move_monster: berechnet eine position fuer das Monster            *}
{*   Je cleverer dieser Algorithmus desto groesser die Spielstaerke  *}
{*                                                                   *}
{* Das Resultat wird in x,y abgelegt ('VAR' !)                       *}
{*********************************************************************}
PROCEDURE move_monster(VAR x,y:INTEGER);
VAR     move: ARRAY[0..1,0..3] OF INTEGER;
        i,dist,value,oldval,take: INTEGER;
BEGIN
  FOR i:=0 TO 3 DO BEGIN
    move[0,i]:=xmonst; move[1,i]:=ymonst;
  END;  {endfor i}
  {-- Die 4 Positionen berechnen: }
  up(move[1,0]); dn(move[1,1]); lt(move[0,2]); rt(move[0,3]);
  {-- Bewertung starten: }
  take:=0; oldval:=-1000;       
  FOR i:=0 TO 3 DO BEGIN
    CASE field[move[0,i],move[1,i]] OF          {Feldinhalt testen!}
    monster:   value:=-5000;                    {Die Bewertung...}
    mief:      value:=-100;
    trap:      value:=50;
    empty:     value:=500;
    caval:     value:=5000;
    END;  {endcase}
    {Entfernung zum cavalier berechnen und mit einbeziehen}
    dist:=calc_distance(move[0,i],move[1,i],xcaval,ycaval);
    IF dist=5 THEN value:=value DIV 10
    ELSE           value:=value-dist;
    IF value>oldval THEN BEGIN                  {dieser Zug ist besser!}
      oldval:=value; take:=i;
    END;  {endif}
  END;  {endfor i}
  x:=move[0,take]; y:=move[1,take];
END;  {endproc}

{*********************************************************************}
{* check_cavalmove: ist die position x,y gueltig?                    *}
{*                                                                   *}
{*********************************************************************}
FUNCTION check_cavalmove(x,y:INTEGER):INTEGER;
BEGIN
  IF calc_distance(x,y,xcaval,ycaval)<>5 THEN BEGIN
    warn('Illegal move!'); check_cavalmove:=illmove;
  END ELSE BEGIN
    CASE field[x,y] OF                  {schon besetzt? }
    mief: BEGIN
        warn('Äa pue! Accäs interdit!');
        check_cavalmove:=illmove;
      END;
    trap: BEGIN
        warn('Attention, piäge!');
        check_cavalmove:=illmove;
      END;
    monster: BEGIN
        check_cavalmove:=caval_wins;
      END;
    empty: BEGIN
        warn(' ');
        check_cavalmove:=ok;
      END;
    END;  {endcase}
  END;  {endif}
END;  {endfunc}

{*********************************************************************}
{* gcmov: ist das angegebene Feld fuer Cavalier frei?                *}
{*                                                                   *}
{*********************************************************************}
FUNCTION gcmov(x,y:INTEGER):BOOLEAN;
BEGIN
  IF x<0 THEN x:=x+fwidth;
  IF x>=fwidth THEN x:=x-fwidth;
  IF (y<0) OR (y>=fheigth) THEN gcmov:=FALSE
  ELSE BEGIN
    IF (field[x,y]=empty) OR (field[x,y]=monster) THEN gcmov:=TRUE
    ELSE gcmov:=FALSE;
  END;  {endif}
END;  {endfunc}

{*********************************************************************}
{* caval_free: testet, ob der Cavalier noch einen Zug ausfÅhren kann *}
{*                                                                   *}
{*********************************************************************}
FUNCTION caval_free:BOOLEAN;
BEGIN
  caval_free:= gcmov(xcaval+2,ycaval+1)
            OR gcmov(xcaval+2,ycaval-1)
            OR gcmov(xcaval-2,ycaval+1)
            OR gcmov(xcaval-2,ycaval-1)
            OR gcmov(xcaval+1,ycaval+2)
            OR gcmov(xcaval+1,ycaval-2)
            OR gcmov(xcaval-1,ycaval+2)
            OR gcmov(xcaval-1,ycaval-2);
END;  {endfunc}

{*********************************************************************}
{* play_a_round: ein Durchlauf spielen, bestehend aus                *}
{*   1. cavalier-zug                                                 *}
{*   2. monster-zug                                                  *}
{*                                                                   *}
{*********************************************************************}
FUNCTION play_a_round:BOOLEAN;
VAR     x,y:INTEGER;
BEGIN
  CASE check_cavalmove(xpos,ypos) OF
  ok: BEGIN
      put_caval(xpos,ypos);               {Cavalier setzen}
      IF caval_free THEN BEGIN            {Test, ob cavalier sich noch bewegen kann}
        move_monster(x,y);                {Zug berechnen} 
        CASE check_monstermove(x,y) OF
        ok: BEGIN
            put_monster(x,y); play_a_round:=FALSE;
          END;
        monster_wins: BEGIN
            put_monster(x,y); collision_at(x,y);
            warn('LE MONSTRE A GAGNE car le monstre a mangÇ le cavalier');
            play_a_round:=TRUE;
          END;
        figure_locked: BEGIN
            warn('VOUS AVEZ GAGNE! - le monstre est bloquÇ.');
            play_a_round:=TRUE;
          END;
        END;  {endcase}
      END ELSE BEGIN 
        warn('LE MONSTRE A GAGNE car vous àtes immobilisÇ');
        play_a_round:=TRUE;
      END;  {endif}
    END;
  illmove: BEGIN
      bell; play_a_round:=FALSE;
    END;
  caval_wins: BEGIN
      collision_at(xpos,ypos);
      warn('VOUS AVEZ GAGNE! - vous avez ''mangÇ'' le monstre');
      play_a_round:=TRUE;
    END;
  END;  {endcase}
END;  {endfunc}

{*********************************************************************}
{* play_the_game: eine Partie spielen                                *}
{*   Abbruch durch abbruchtaste oder normales Spielende.             *}
{*                                                                   *}
{*********************************************************************}
PROCEDURE play_the_game;
VAR     key:INTEGER;
        bool:BOOLEAN;
BEGIN
  WHILE perform_menu DO BEGIN           {SOLANGE weiterspiel erwuenscht}
    arrayfill_empty; set_algo_var; init_figures;
    draw_screen(xoff,yoff,fwidth,fheigth);
    
    bool:=TRUE;
    REPEAT
      key:=user_select;
      CASE key OF
      ORD('r'), ORD('R'): BEGIN         {Redraw screen}
          draw_screen(xoff,yoff,fwidth,fheigth); bool:=FALSE;
        END;
      42: BEGIN                 {* -> raus}
          info('Abandonner le jeu? Y/n'); bool:=answer;
          info('');             {Infozeile lîschen}
        END;
      ORD('5'):
        bool:=play_a_round;     {bricht bei Partie-Ende ab}
      END;  {endcase}
    UNTIL bool;
    info('* any key continues *'); inkey(key);
  END;  {endwhile}
END;  {endproc}

{******************************************************************************}
{***** MAIN LOOP *****}
BEGIN
  Init_Random; InitKeyboard;
  print(NumericKBD);
  arrayfill_empty;
  set_algo_var;
  xpos:=0; ypos:=0;               { aktuelle logische Cursorposition }
  fwidth:=10; fheigth:=5;
  yoff:=3; xoff:=(40-fwidth);  
  cursor_off;
  play_the_game;
END.

