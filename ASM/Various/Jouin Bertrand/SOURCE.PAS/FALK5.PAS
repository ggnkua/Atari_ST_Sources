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
  Write('Bonjour … tous les lecteurs du Falk ''Mag');

      { Fonction Write : Affiche … l'‚cran une chaine de Charact‚res }

  Write('Appuyer sur une touche .....  ...  ..  . ');
  Readln;          { Fonction Readln ==> Attend la touche ENTREE }

      { Ici , cela nous permet de pouvoir voir ce qu''il y … l'‚cran }

  ClrScr;
  GotoXY(12,11)    { Place le curseur en X = 12 et Y = 11 }
  Write('L… j'‚cris au milieu de l''‚cran ');
  Readln;
End.               { Fin Du Programme }

{   Remarquons que chaque fonction est s‚par‚e par un ' ; ' et que le
programme commence par l'instruction BEGIN et se termine par END.
   De plus , Si dans la chaine … afficher il y a un ' il faut en
mettre deux :

Ex:
   La chaine 'Il faut m'appeller' renverra une erreur , Il Faut
Mettre : 'Il faut m''appeller' }


{   Maintenant , on va passer … la structure propre du Pascal :
   => D‚finition de constantes et de variables .


Exemple 2 : Calcul de la Surface d'un cercle
----------- }


Program Exemple2;

         { On commence par d‚finir les constantes }

Const  Pi = 3,14159 ;

         { Apr‚s on d‚finit d'autres Type Si n‚cessaire }

Type   MonType : String[11] ;    { par exemple }


         { Puis les variables globales ( c.a.d utilisables tout au long du Programme ) }

Var    SurfaceDuCercle : Real ;  { Variable de Type R‚el }
       RayonDuCercle   : Real ;

                           { Var nous permet de definir une variable }
                           { Different Type existe pour la variable ( comme pour une constante ,
                             D'ailleurs ) ON va voir Cela plus Loin }
Begin
  ClrScr;
  { Initialisation des differentes variables }
  SurFaceDuCercle := 0.00 ;
  RayonDuCercle   := 0.00 ;
  { Prend le rayon du cercle au clavier }
  Write('Donner le Rayon du Cercle ');
  { Rentre en m‚moire le rayon }
  Read(RayonDuCercle);

  { On Utilise la fonction Read car elle ne prend que les characteres donn‚es par l'utilisateur
    tandis que Readln prend la ligne compl‚te ( avec les espaces ) }

  Write('La Surface du cercle est : ',Pi*RayonDuCercle*RayonDuCercle);
End;

{ On peut le faire d'une autre mani‚re plus g‚n‚rale : }


Program Exemple2BIS;

         { On commence par d‚finir les constantes }

Const  Pi = 3,14159 ;

         { Apr‚s d'autres Type Si cela est Utile }

Type   TypeSurface : Real ;    { par exemple }


         { Puis les variables globales ( c.a.d utilisables tout au long du Programme ) }

Var
       RayonDuCercle   : Real ;

        { … la place de Real On pourrait mettre TypeSurface }
{
Var    RayonDuCercle : Real ;    ET
Var    RayonDuCercle : TypeSurface ;   D‚finissent la mˆme chose }

       NombreDeDecimal : Integer ;  { Variable Type Entier }

                           { Var nous permet de definir une variable }
                           { Different Type existe pour la variable ( comme pour une constante ,
                             D'ailleurs ) ON va voir Cela plus Loin }

Procedure CalCulSurface ;   { D‚finition d'une nouvelle Proc‚dure }

Var Resultat : TypeSurface ; { Le resultat ( la surface ) sera du type R‚el

Begin { D‚but de la proc‚dure }
  Resultat := Pi*RayonDuCercle*RayonDuCercle ;
End;  { Fin de la proc‚dure }

Begin { D‚but du Programme }
  ClrScr;
  { Initialisation des differentes variables }
  RayonDuCercle   := 0.00 ;
  { Prend le rayon du cercle au clavier }
  Write('Donner le Rayon du Cercle ');
  { Rentre en m‚moire le rayon }
  Read(RayonDuCercle);

  { On Utilise la fonction Read car elle ne prend que les characteres donn‚es par l'utilisateur
    tandis que Readln prend la ligne compl‚te ( avec les espaces ) }

  CalCulSurface ;

  Write('La Surface du cercle est : ',Resultat);
End. { Fin Du Programme }
