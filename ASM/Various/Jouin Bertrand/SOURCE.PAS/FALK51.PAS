{

                            Initiation au Turbo Pascal


    Commen‡ons par le plus simple : Afficher une phrase … l'‚cran ,
cela va nous permettre de voir la structure g‚n‚rale d'un programme
Pascal.
    Les commentaires ou remarques en Pascal sont entre { } { ou (* *). }


{ Exemple 1 : Affichage d'une phrase.
  ----------- }


Program Exemple1; { D‚finition du NOM du Programme }

Uses Crt;    { Utilisation de l'unit‚ CouRanTe du Pascal }
             (* ==> Fonctions Gestion Ecran : Curseur , Affichage .. *)

Begin        { D‚but du Programme }
  ClrScr;    { Efface l'‚cran : CLeaRSCReen }
  Writeln('Bonjour … tous les lecteurs du Falk ''Mag');

      { Fonction Write : Affiche … l'‚cran une chaine de Charact‚res }
      { Fonction Writeln : Va au d‚but de la ligne suivante apr‚s }

  Write('Appuyer sur une touche .....  ...  ..  . ');
  Readln;          { Fonction Readln ==> Attend la touche ENTREE }

      { Ici , cela nous permet de pouvoir voir ce qu''il y … l'‚cran }

  ClrScr;
  GotoXY(12,11);    { Place le curseur en X = 12 et Y = 11 }
  Write('L… j''‚cris au milieu de l''‚cran ');
  Readln;
End.               { Fin Du Programme }

{   Remarquons que chaque fonction est s‚par‚e par un ' ; ' et que le
programme commence par l'instruction BEGIN et se termine par END.

   De plus , Si dans la chaine … afficher il y a un ' il faut en
mettre deux :

Ex:
   La chaine 'Il faut m'appeller' renverra une erreur , Il Faut
Mettre : 'Il faut m''appeller' }
