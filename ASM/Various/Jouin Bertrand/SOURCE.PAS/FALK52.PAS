
{   Maintenant , On va passer … la Structure Propre du Pascal :
   => D‚finition de constantes et de variables .


Exemple 2 : Calcul de la Surface d'un cercle
----------- }


Program Exemple2;

         { On commence par d‚finir les constantes }

Const  Pi = 3.14159 ;

         { Puis les variables globales ( c.a.d utilisables tout au long du Programme ) }

Var    SurfaceDuCercle : Real ;  { Variable de Type R‚el }
       RayonDuCercle   : Real ;

                           { Var nous permet de definir une variable }
                           { Different Type existe pour la variable ( comme pour une constante ,
                             D'ailleurs ) ON va voir Cela plus Loin }
Begin
  { Initialisation des differentes variables }
  SurFaceDuCercle := 0.00 ;
  RayonDuCercle   := 0.00 ;
  { Prend le rayon du cercle au clavier }
  Write('Donner le Rayon du Cercle ( en Cm ) : ');
  { Rentre en m‚moire le rayon }
  Readln(RayonDuCercle);

  { Pour Lire une Valeur au Clavier , On utilise Toujours Readln }

  Write('La Surface du cercle est ( en Cmý) : ',Pi*RayonDuCercle*RayonDuCercle:6:2);

  { Variable:Nbre De Chiffre Total:Nombre De D‚cimales }
  { Ici Pi*RayonDuCercle*RayonDuCercle = Surface sera du Type  ABCD.EF }

  Readln;
End.
