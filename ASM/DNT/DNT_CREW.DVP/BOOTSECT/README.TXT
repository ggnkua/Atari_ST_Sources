                          GAMEBOOT et ZOOMBOOT


       Comment utiliser ces deux petits boot-sectors ?. C'est trŠs simple:

               o lancez le programme BOOTER_2.PRG
               o Choisissez l'option "Normale"
               o Un s‚lecteur de fichier s'affiche alrs; selectionnez l'un
                 des deux fichiers GAMEBOOT.PRG ou ZOOMBOOT.PRG
               o Inserez une disquette dans le lecteur A:
               o Appyez sur Return
               o Si votre disquette est d‚j… occup‚e (jeu, d‚mo, anti-virus,
                 ou... virus !), il vous est demand‚ confirmation.

       Attention de ne pas installer de boot-sector sur une disquette de jeu
ou de demo, sinon vous ne pourrez plus l'utiliser !. Attention aussi au fait
que ce n'est pas un anti-virus, donc sa seule fonction est de se signaler
pendant le boot pour vous montrer que votre disquette n'est pas infect‚e. De
plus le BOOTER_2 n'est pas un virus-killer, et un virus d‚j… r‚sident en
m‚moire peut trŠs bien empˆcher son bon fonctionnement... Souvenez vous-en.
       Si vous d‚sirez en savoir plus, procurez vous le DNT-Paper 3, il y a
un immense article sur le sujet...


       Le ZOOMBOOT est donn‚ comme exemple de manipulation des nombres
d‚cimaux en assembleur 68000. Il tient donc lieu de compl‚ment de l'article
'Divers 68000' du DNT-Paper 4. Comme d'habitude (pour ceux qui on lu le
DNT-Paper 3, bien s–r!) pour lancer le programme depuis le bureau il faut
l'assembler avec la ligne TEST equ 0, et pour obtenir un fichier ZOOMBOOT.PRG
utilisable avec le BOOTER_2 il faut l'assembler avec une ligne TEST equ 1.

       Le GAMEBOOT, comme son nom l'indique, est un petit jeu en boot-sector.
Bien entendu, c'est sans pr‚tention aucune et n'importe quel vrai jeu de
r‚flexion le bat … plates coutures. Voici les rŠgles: vous jouez sur un
damier 64*64, comportant des pions rouges et des pions blanc. Le but est de
reconstituer une figure g‚om‚trique en d‚calant les lignes ou les colonnes
de pions.
       Pour ce faire, vous d‚placez un curseur de case en case. Ce curseur
est signal‚ par un petit cadre entourant le pion. Ce d‚placement se fait
grƒce aux touches flŠch‚es. Pour d‚caler la ligne (resp. la colonne) …
laquelle appartient le pion choisi, il faut se servir des flŠches gauche
ou droite (resp. haut ou bas) tout en appuyant sur Shift. La ligne (resp.
colonne) va alors "tourner", c'est … dire que tous les pions sont d‚cal‚s
d'une case … gauche ou … droite (resp. en haut ou en bas). Ce qui sort …
une extr‚mit‚ rentre de l'autre.
       Quand vous avez reconstitu‚ la figure voulue, l'‚cran clignote un
instant, puis vous red‚marrez une autre partie. Pour s'arrˆter et sortir
(… n'importe quel moment), il suffit d'appuyer sur Esc.
       Il existe plusieurs figures pr‚d‚finies. Celle par d‚faut (utilis‚e
dans le fichier GAMEBOOT.PRG fourni et prˆt … l'emploi) est la grille:

   0000000*
   0**000**
   0**00***         *=pion rouge
   0000****         0=pion blanc
   000*****
   00***00*
   0****00*
   ********

       Au moment de l'assemblage, outre l'‚tiquette TEST qui fonctionne
comme d‚crit plus haut, vous choisissez avec l'‚tiquette LEVEL le niveau
de difficult‚ du jeu (plus LEVEL est grand, plus le damier est m‚lang‚).
L'‚tiquette Forme vous permet, quant … elle, de choisir une des formes
pr‚d‚finies. Voil…, c'est tout pour GAMEBOOT !.

                                                         Nullos//DNT-Crew 1992