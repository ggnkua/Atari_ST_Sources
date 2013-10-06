
BLOOD : les sources!
^^^^^^^^^^^^^^^^^^^^

AprŠs les sources de la Choice Of Gods, voici celles de notre derniŠre et
ultime d‚mo sur ST: BLOOD. (Cette fois, c'est presque sur!)

En ce qui concerne nos 2 d‚mos interm‚diaires, Rising Force et Japtro, les
sources n'ont jamais ‚t‚ regroup‚es sur 1 disk unique, faute de motivation,
mais si quelque chose vous int‚resse, vous pouvez toujours demander.

Bien.

Vous ne retrouverez pas ici TOUTES les sources de la d‚mo pour 2 raisons
simples:
- certaines feraient double emploi.
- ‡a tiendrait pas vraiment sur un disk... ex: Inverted Landscapes 2, il
  faut presque un disk entier pour les sources de ce seul ‚cran! (les datas
  non compact‚s prenant une place monstre..)

Don't panic! Avec ce qui est regroup‚ ici, vous aurez d‚j… de quoi vous
occuper un moment.



( Deux mots sur la 3D:

* pour les rotations rapides et toute la partie calcul, INIT_PTS.S devrait
  faire l'affaire.

* pour l'affichage en lui meme par contre, les sources sont plus l… … titre
  informatif qu'autre chose. Je veux dire que vous aurez sans doute un peu
  de mal … utiliser ces sources pour vos propres d‚mos. La technique que
  j'emploie est en effet un peu....particuliŠre? Sauvage plutot... mais
  aprŠs tout je suis Zappy... huhu, je n'en suis pas … une h‚r‚sie prŠs, 
  vous me connaissez.
  
  J'explique, donc:
  
  L'id‚e de base est simple: faire du temps r‚el quand on peut, et se
  d‚brouiller autrement dans le cas contraire.
  En pratique, je considŠre un objet 3D quelconque, et un mouvement
  quelconque pour cet objet. (Rotations/translations/zoom/etc)
  Pour chaque vbl, je regarde le temps machine utilis‚. Si tout tient dans
  la vbl, pas de problemes, je mets par exemple un bit … 0 dans un buffer
  de controle.
  
  Si ‡a sort de la vbl, je supprime d'abord l'effa‡age, ce qui fait gagner
  d‚j… pas mal de temps. (=>bit … 1, hop)
  
  Pour cela, on deltapacke l'effa‡age tout en jouant sur les plans: la
  palette est telle que le plan 4 masque le plan 3, qui masque le plan 2,
  qui masque le plan 1. Donc … chaque endroit de l'‚cran o— passe une face
  sur le plan 4, il est inutile d'effacer les 3 plans 'inf‚rieurs'...ok?
  Tout ‡a, ‡a prend de la ram, forc‚ment. Mais … part Keops, tout le monde
  maintenant a au moins un m‚ga de ram... il est ‚vident que scanner tout
  l'‚cran et code-g‚n‚rer le tout prend beaucoup de temps, et qu'il est
  hors de question de faire ‡a pendant la d‚mo avant chaque objet 3D.
  Le code g‚n‚r‚ de l'effa‡age est donc sauv‚ sur disk. Ennuyeux, … priori.
  En effet le code effa‡ant chaque objet de la d‚mo prend en moyenne
  200K en ram. (voire le double!) Meme en compactant ‡a au Speed Packer, 
  c'est dur! On s'en tire en se faisant un petit compacteur sp‚cial, exprŠs
  pour ‡a, qui s‚pare d'abord les opcodes et les offsets, et qui applique
  ensuite … ces derniers un bete codage diff‚rentiel. On passe ensuite
  tout ‡a au Speed ou … l'Atomik, et miracle!...les 200K du d‚but n'en
  prennent meme plus 10! Ca c'est des ratio comme je les aime!!
  
  Mais au fait, au niveau du temps machine? Eh bien c'est assez merveil-
  -leux! J'ai ‚t‚ vraiment sur le cul la premiŠre fois: l'effa‡age ne prend
  plus que 2 ou 3 lignes, une misŠre! Meme les ziks de Mad Max bouffent
  plus!! Vous imaginez les possibilit‚s, ensuite...
  
  2 inconv‚nients, en fait:
  * il faut d‚compacter et recr‚er le code avant chaque objet 3D. Ca prend
    un peu de temps mais pas ‚norm‚ment.
  * inutile d'esp‚rer faire ‡a autre part que dans une d‚mo... et encore,
    dans une d‚mo … la sauce Braindamage o— les objets 3D restent pas trop
    longtemps...

  Bref. Revenons … nos moutons. Le problŠme de l'effa‡age est r‚gl‚.
  
  Reste l'affichage. Comment faire si on n'a toujours pas assez de temps
  machine? Ma foi, l…, on peut vraiment faire tout et n'importe quoi:
  * ne pas faire les calculs des rotations/etc en temps r‚el. On gagne un
    peu mais vraiment pas beaucoup pour des objets … 12 points!!
    
  * afficher la face la plus grosse en MOVE.L sur les plans 1 et 4. C'est
    illusoire... ‡a ne marche que dans bien peu de cas, et on gagne pas
    des masses...
    
  * deltapacker l'affichage... mauvaise id‚e! C'est TRES rentable au niveau
    du temps machine, mais c'est aussi TRES gourmand en ram, et TRES dif-
    -ficile … compacter efficacement, contrairement … l'effa‡age. A n'
    utiliser que pour les quelques Vbls d‚sesp‚r‚es o— rien d'autre ne
    marche...
    
  * sauver des blocs graphiques en ram... idem que ci-dessus.
  
  * utiliser plusieurs ‚crans vid‚os, genre Aura/Equinox/Oxygene/tout le
    monde. Efficace, oui. Mais pas si l'effa‡age est deltapack‚!! C'est
    bien ‚vident... en plus, 10 ou 16 ‚crans en ram... autant utiliser
    la place en ram autrement.
    
  * pr‚calculer les tableaux droite-gauche pour le remplissage. C'est le
    plus efficace, je pense. On peut en pr‚calculer quelques uns, juste
    pour rester dans la Vbl, et calculer les autres normalement. On peut
    aussi ne pas se poser de question et tout faire comme ‡a... c'est trŠs
    efficace pour 2 raisons:
    -la cr‚ation des tableaux prend un temps non n‚gligeable!
    -‡a simplifie … l'extrŠme la routine d'affichage, qui est alors boost‚e
    … environ 520/530 lignes/Vbl...
    
  Voil… en gros les trucs les plus utiles. Je n'en utilise vraiment pas
  d'autres dans la Blood.
  Quand je vous disais que c'‚tait sauvage.... et meme stupide. Seul un
  coder de d‚mo peut perdre son temps - un comble, ah-ah - … programmer
  des horreurs pareilles. Notons enfin que la m‚thode la plus int‚ressante
  jusqu'… pr‚sent est le deltapacking en temps r‚el, comme chez Synergy.
  Ca demande au moins autant d'efforts pour mettre en place une routine
  valable, mais ‡a semble encore plus int‚ressant. Pas plus puissant, non,
  puisque finalement je n'ai pas de limite en temps machine... quand y'en
  a plus, on en cr‚e! Mais je ne peux pas laisser les objets infiniment sur
  l'‚cran, donc leur m‚thode est en fait bien meilleure. 
  Qu'ils soient f‚licit‚s!
  
  Fin de la longue parenthŠse.)
  

J'ai rajout‚ aussi 'OLD_CUBE.PRG', le 1er objet 3D que j'ai fait avec cette
nouvelle m‚thode barbare d‚crite ci-dessus. C'est une vieille routine 3D
pas pr‚cise - cf les lignes noires qui apparaissent aux intersections -
mais si mes souvenirs sont exacts ‡a tourne sur un 520, donc ‡a rabattra
le caquet de Keops! Hihi.

Ce petit programme va aussi vous permettre de mieux comprendre comment
marche le deltapacking de l'effa‡age m‚l‚ au jeu sur les plans...
Lancez le ripper (lire READ_ME2.S pour en savoir plus.) puis ex‚cutez
OLD_CUBE.PRG. Quand le cube est assez gros, pressez Reset et baladez vous
dans la Ram jusqu'… trouver l'image du cube. Si vous n'activez pas la
palette propre au cube, vous allez voir de droles de choses dans les faces
du cube...: ce qui n'a pas ‚t‚ effac‚ grace aux plans!

Bref.

Si votre assembleur pr‚f‚r‚ ne r‚siste toujours pas au reset, vous aller
devoir, comme la derniŠre fois, vous concocter une routine de sortie plus
propre que la notre...

Si vous n'avez qu'un m‚ga de ram, vous aurez peut etre du mal … utiliser
certains sources. Il ne vous reste dans ce cas qu'… assembler sur disk,
d‚sol‚!

Swappez ce disk … volont‚.

Comme d'habitude, remarques, critiques, questions et d‚clarations d'amour
sont … d‚poser en bal Zappy sur Rtel... 


Keep on coding...

                                                    Zappy/Holocaust - 1994.
                                                    
                                                  