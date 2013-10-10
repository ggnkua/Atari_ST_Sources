Mode d'emploi du source
-----------------------

Bon alors, tu peux changer le texte a volont‚
Mais, ne met pas trop de charactŠres car je masque
le texte en temps r‚el, et j'optimise sur les vides
(de toutes fa‡ons, tu vois bien quand ‡a tourne plus
… la VBL sur un moniteur RVB, c'est flagrant)
Utilise les soulign‚s simples et doubles plutot que
de le faire avec -------, car ces soulign‚s sont plac‚s
de telle fa‡on que ca ne prene aucun temps suppl‚mentaire
lors du masquage.
(Regarde le source pour les codes ascii des soulign‚s)

Tu peux aussi changer les logos, mais le plus simple a
changer c'est celui de la distortion...c'est un fichier
.TG1 de 128*256 (j'ai mis le soft pour les creer et les
convertir, c'est rembrandt)
Le logo du bas est fait rapidos sous Apex, et l'autre
c'est un petit raytrace sous Neon.

Pour la musique, c'est du module 4 voies pour l'instant
(digital tracker dŠs que j'ai les sources [je les attend
sous peu]) mais convertis au format NTK4 (je t'ai mis
le convertisseur) ... n'oublie pas de les depacker (si
tu les packe, bien sur) avant de les convertir (sinon
y'a de jolis bugs!!). 4 modules exemples.

Le dernier truc sympa, c'est qu'au lieu d'ex‚cuter un
programme quelconque aprŠs l'intro, il est d‚j… inclus
dans le source (un bete incbin) et je le reloge, il y
voit que du feu. Evite de mettre de gros programmes
pack‚s (ca risque de poser des problŠmes au niveau de la
ram, donc met les tous decompact‚s, mˆme les petits).

Bon, aprŠs, les options et le checksum mode d'emploi...

Tu peux couper la musique (pour gagner de la place), du
coup je n'inclus plus le module et le player. Il suffit
de changer music equ 1 en music equ 0.

Tu peux virer l'ex‚cutable (exec … 0 pour quitter l'intro
et revenir au bureau, et exec a 1 pour executer le programme
sp‚cifi‚ … la fin)

checksum et test_chk sont r‚serv‚s au checksum.
Concrˆtement, lorsque l'intro sort en version d‚finitive (le
texte est bien ‚crit, zik correcte, ect ect) checksum doit
ˆtre … 1. Seulement, pour trouver la bonne valeur, il faut
mettre test_chk a 1 lui aussi, tu assemble sur disk, tu lance
le programme sous a-debug tu le lance avec control-r, il
s'arrette sur un ILLEGAL, tu note la valeur de D0 (c'est le
checksum) tu fais Control-S puis control-R puis tu quittes
a-debug, tu charge le source, hop tu met la nouvelle valeur,
tu remet test_chk … 0, et voila c'est pret!!!!

Le checksum v‚rifie le texte et le prg charg‚, … la moindre modif
‡a plante APRES l'intro. La routine de checksum est aussi v‚rifi‚e
pendant l'intro (h‚h‚, c'est utile!!!)

Bien ben je crois que je t'ai tout dis ... have fun

*****************************************************************
* N'OUBLIE SURTOUT PAS, LORSQUE TU ASSEMBLES, DE NE SURTOUT PAS *
* LAISSER LES SYMBOLES (DEBUG INFO=NONE SOUS DEVPACK 2.23)      *
* C'EST HYPER IMPORTANT!!!!!!!!!!!!!!!!!!!!!!                   *
*****************************************************************

CORPO