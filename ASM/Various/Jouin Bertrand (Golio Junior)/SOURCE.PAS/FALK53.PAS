
Program Exemple2BIS;

         { Besoin de fonctions du Pascal ???? }

Uses Crt ;

         { On commence par d‚finir les constantes }

Const  Pi = 3.14159 ;

         { puis de Nouveaux Types , Si on veut .. . }

Type TypeSurface = Real ;

         { Puis les variables globales ( c.a.d utilisables tout au long du Programme ) }

Var
       RayonDuCercle   : Real ;

        { … la place de Real On pourrait mettre TypeSurface }
{
Var    RayonDuCercle : Real ;    ET

Var    RayonDuCercle : TypeSurface ;   D‚finissent la mˆme chose }

       Resultat : TypeSurface ;

       NombreDeDecimal : Integer ;  { Variable Type Entier }


Procedure CalCulSurface ;   { D‚finition d'une nouvelle Proc‚dure }


Begin { D‚but de la proc‚dure }

  Resultat := Pi*RayonDuCercle*RayonDuCercle ;

End ;  { Fin de la proc‚dure }

Begin { D‚but du Programme }

  ClrScr;

  { Initialisation des differentes variables }

  RayonDuCercle   := 0.00 ;

  { Prend le rayon du cercle au clavier }

  Write('Donner le Rayon du Cercle : ');

  { Rentre en m‚moire le rayon }

  Readln(RayonDuCercle);

  CalCulSurface ;

  Write('La Surface du cercle est : ',Resultat:6:2);

  Readln;
End. { Fin Du Programme }
