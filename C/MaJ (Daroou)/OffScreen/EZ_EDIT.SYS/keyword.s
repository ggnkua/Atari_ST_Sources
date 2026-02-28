;---------------------------- FICHIER DE PARAMETRAGE SYNTAXIQUE ---------------------------
;                             pour EZ_EDIT par SEVIN Roland ½ 15/12/2000
; 
; Tout ce qui suit un point virgule sera consid‚r‚ comme un commentaire et non
; interpr‚t‚
; ce fichier doit toujours avoir le nom: KEYWORD et                                        
; l extension determine … quel type de fichier il doit s appliquer, exemple si ce fichier
; porte le nom KEYWORD.C tous les fichiers d extension C utiliseront ses paramŠtres.
; Les fichiers de parametrage syntaxique doivent se trouver dans le dossier systeme:
; EZ_EDIT.SYS (situe  lui meme dans le repertoire d EZ_EDIT.PRG)
; il existe plusieurs types de definitions (entre crochets) suivies par des parametres:
; L exemple suivant est le fichier utilis‚ pour coloriser la syntaxe assembleur Motorola
;
; Description des diferentes definitions avec syntaxe et paramŠtres:
;
; CLASS_GRAPH  defini une classe graphique, regroupant les attributs d'affichage d'un texte
; ¹¹¹¹¹¹¹¹¹¹¹  - 1 - Il faut lui donner un type identificateur comme premier paramŠtre. C'est ce
;              type qui sera utilis‚ dans les autre definitions, pour y faire reference et
;              determiner l'affichage. 
;              - 2 - Le parametre suivant est le nom tel qu il doit etre
;              affich‚ dans la LISTBOX de parametrage syntaxique d'EZ_EDIT.
;              - 3 - les autres parametres sont les attributs graphiques correspondant: 
;                    couleur, 
;              - 4 - Effet: 0/sans + 1/gras + 2/gris‚ + 4/italique + 8/souligne + 16/evid‚ 
;              - 5 - taille en points des caracteres, 
;              - 6 - police en clair: seuls les premiers caractŠres suffisent si significatifs
;
;              IMPORTANT: LES DEFINITIONS DES CLASSES GRAPHIQUES DOIVENT TOUJOURS ETRE EN PREMIER
;              ¹¹¹¹¹¹¹¹¹
; KW_SECTION   defini un type de section dans laquelle des mots clefs, op‚rateurs, et sections d'exclusion
; ¹¹¹¹¹¹¹¹¹¹   seront reconnus. Nous l'appelerons Section de mots clef: Cette section est delimitee
;              par une sequence de caracteres de debut et une sequence de caracteres de fin. 
;              Exemple en HTML: les TAG (mots cles du langage HTML) ne sont reconnus qu entre les caracteres: < et >.
;                                                                                                         
;              - 1 - le premier  parametre est la sequence de caracteres definissant le debut de la section
;                                                                                                          
;              - 2 - le deuxiŠme parametre est la sequence de caracteres definissant la fin de la section
;                    il est possible de placer le mot clef: KEYWORD au lieu d'une sequence de caracteres de fin
;                    alors la fin de la section sera marqu‚e par un des mots clefs li‚s … elle.
;                    Il est tout de meme possible d'indiquer en plus … la suite de KEYWORD, une sequence
;                    de caracteres de fin de section (utile si pas de mot clef rencontr‚).
;                                                                                                          
;              - 3 - le troisieme parametre est le type de section. (celui qui devra etre place en 4‚me 
;                     parametre d'un mot clef afin d'indiquer … quelle section appartient ce mot clef).
;                                                                                                          
;              - 4 - le quatriŠme parametre est une chaine indiquant les caractere autoris‚s pour les
;              mot clefs en sachant que 0->9 et a->z signifient les caractere de 0…9 et de a … z
;              cela ne fonctionne que dans l ordre croissant.
;                                                                                                         
;              - 5 - le cinquiŠme paramŠtre indique la classe graphique … utiliser pour colorer les
;              delimiteurs et UNIQUEMENT les delimiteurs de cette section.
;                                                                                                         
;              - 6 - le SixiŠme paramŠtre est un flag qui indique si il doit etre tenu compte 
;              de majuscules minuscules lors de la recherche et identification des mots clefs 
;              et des delimiteur de section:
;                                                                                                         
;              ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
;                                  Recherche  des                       Recherche des                     
;                    Flag                 MOTS CLEFS                           DELIMITEURS                
;                                  … l int‚rieur de la section          marquant la section               
;              ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
;                   0              Majuscules  Minuscules  sont         Majuscules Minuscules   sont      
;                                  diff‚renci‚es                        diff‚renci‚es                     
;                                  Exple: MOT different de: mot         Exple: MOT different de: mot      
;                                         M != m                                   M != m                 
;                                                                                                         
;                   1              Majuscules Minuscules sont           Majuscules Minuscules sont        
;                                  permises pour meme mot clef          diff‚renci‚es                     
;                                  Exple: MOT egal … mot ou Mot         Exple: MOT different de: mot      
;                                         M  = m                                   M != m                 
;                                                                                                         
;                   2              Majuscules Minuscules sont           Majuscules Minuscules sont        
;                                  diff‚renci‚es                        permises pour meme mot clef       
;                                  Exple: MOT different de: mot         Exple: MOT egal … mot ou Mot      
;                                         M != m                                   M  = m                 
;                                                                                                         
;                   3              Majuscules Minuscules sont           Majuscules Minuscules sont        
;                                  permises pour meme mot clef          permises pour meme mot clef       
;                                  Exple: MOT egal … mot ou Mot         Exple: MOT egal … mot ou Mot      
;                                         M  = m                                   M  = m                 
;              ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
;                                                                                                         
;              - 7 - le septiŠme paramŠtre indique la classe graphique … utiliser pour colorer les     
;              caractŠres … l'INTERIEUR des delimiteurs de cette section.
;                                                                                                         
;              IMPORTANT: cette definition doit obligatoirement etre situ‚e avant celle des
;              ¹¹¹¹¹¹¹¹¹¹ mots clef concern‚s.
;              IMPORTANT: la section DEFAUT, est celle du texte normal situe en dehors de tout
;              ¹¹¹¹¹¹¹¹¹¹ delimiteur et elle EST OBLIGATOIRE.
;              IMPORTANT: si vous placez le 6Šme parametre … 1 afin que les mots clefs
;              ¹¹¹¹¹¹¹¹¹¹ soient reconnus aussi bien en majuscules que minuscules, ou les deux,
;                         la liste des mots clefs du fichier de configuration doit etre
;                         saisie en minuscules sous peine de non reconnaissance des mots cles.
;
; KEY_WORD    defini un mot clef. 
;             - 1 - Le premier parametre est le texte du mot clef tel qu'il devra etre trouv‚ dans
;                   le texte. 
;             - 2 - Le deuxiŠme la reference … la classe graphique permettant de coloriser ce mot clef
;             - 3 - Le troisiŠme parametre est l indentation … placer … la suite de ce mot clef
;                   apres appui sur la touche RETURN. 
;             - 4 - Le quatriŠme paramŠtre designe la section de mots clef: KW_SECTION dans laquelle doit 
;                   etre reconnu ce mot clef, si vous placez la mention DEFAUT la section sera 
;                   celle par defaut CAD le texte normal.
;             
;             IMPORTANT: tous les mots clefs appartenant … une meme section doivent etre
;             ¹¹¹¹¹¹¹¹¹¹ plac‚s ensembles.
;             IMPORTANT: un mot clef ne doit pas comporter plus de 32 caractŠres !!
;             ¹¹¹¹¹¹¹¹¹
;             IMPORTANT: un mot clef ne peut pas comporter de caractŠres reconnus comme
;             ¹¹¹¹¹¹¹¹¹  op‚rateurs.
;
; OPERATOR    est pareil que KEY_WORD sauf que le premier parametre doit indiquer sur 1
;             caractŠre le caractŠre … considerer comme un op‚rateur.
;             - 1 - Le premier parametre est le caract‚re devant etre reconnu comme operateur.
;                   dans le texte. Il ne doit pas y avoir d'operateur dans les caracteres d'un
;                   mot clef.
;             - 2 - Le deuxiŠme la reference … la classe graphique permettant de coloriser cet operateur
;             - 3 - Le troisiŠme parametre est l indentation … placer … la suite de cet operateur
;                   apres appui sur la touche RETURN. 
;             - 4 - Le quatriŠme paramŠtre designe la section de mots clef: KW_SECTION dans laquelle doit 
;                   etre reconnu cetoperateur, si vous placez la mention DEFAUT la section sera 
;                   celle par defaut CAD le texte normal.
;
; NUMERIC     defini la fa‡on dont les valeurs num‚riques sont repr‚sent‚es.
;             une valeur numerique commence par des caractŠres d'introduction, ne pouvant etre suivis
;             que des caractŠres reconnus comme possibles pour expriner une valeur, tout espace
;             ou caractŠre non reconnu est la fin.
;             - 1 - Le premier parametre est la liste des sequences de caractŠres (separ‚es par des espaces) 
;                   introduisant une valeur numerique.
;             - 2 - Le deuxiŠme paramŠtre est la liste des caractŠres possibles pour exprimer une valeur
;                   num‚rique(tous les caractŠres doivent etre contigus).
;             - 3 - Le troisiŠme parametre est la reference … la classe graphique permettant de 
;                   coloriser les caractŠres introducteurs d'une valeur num‚rique
;             - 4 - Le quatriŠme parametre est la reference … la classe graphique permettant de 
;                   coloriser une valeur num‚rique
;             - 5 - Le cinquiŠme paramŠtre designe la section de mots clef: KW_SECTION dans laquelle doit 
;                   etre reconnu une valeur numerique , si vous placez la mention DEFAUT la section sera 
;                   celle par defaut CAD le texte normal.
;
; SECTION     appel‚e aussi section d'exclusion car tout se qui se trouve encadr‚ par les 
;             delimiteurs de cette section, ne peut etre reconu ni comme un operateur ni
;             comme un mot clef, ni comme un debut ou fin de section de mot clefs.
;             exemple: les chaines de caracteres en C ou strings plac‚es entre guillemets
;                      les commentaires entre: /*            et */            ou
;                                              //            et fin de ligne  ou 
;                                              point virgule et fin de ligne (assembleur)
;             - 1 - Le premier parametre defini les caracteres delimiteurs de debut,
;             - 2 - Le deuxiŠme paramŠtre defini les caracteres delimiteurs de fin
;                   en sachant que EOL comme deuxieme parametre signifie que c'est la fin de ligne.
;             - 3 - Le troisiŠme paramŠtre indique la classe graphique … utiliser pour l affichage
;                   des caractŠres encadres par les delimiteurs.
;             - 4 - Le quatriŠme paramŠtre est le caractŠre d echapement (celui apres lequel un
;                   caractŠre ne doit pas etre interprete). 
;             - 5 - Le cinquiŠme parametre indique si il est present la section de mots clefs:
;                   KW_SECTION pourlaquelle cette section est definie.
;             
;             IMPORTANT: Aucun mot clef ni op‚rateur ne peuvent etre reconnus dans une telle 
;             ¹¹¹¹¹¹¹¹¹  section. Si vous voulez reconnaitre des mots clefs dans une section
;                        utilisez la definition KW_SECTION.
; 
; EQUIVALENT  designe le fichier qui devra etre utilis‚ comme fichier de definition … la place
;             de celui-ci (cela permet de ne definir qu un seul fichier pour plusieurs types)
;             exemple je definis un fichier KEYWORD.C pour la syntaxe color‚e du C
;             le fichier KEYWORD.H   aura comme simple texte: [EQUIVALENT] KEYWORD.C
;             afin que les fichier .H se servent du fichier KEYWORD.C pour afficher leur syntaxe
; 
; Il existe plusieurs constantes pour definir certains attributs:
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
; NO_INDENT   en place de la valeur d'indentation d'un mot clef ou d'un operateur signifie
;             l'absence d'indentation
; POINTVIRG   en place d'un caractere signifie un point virgule
; EOL         en place d'un caractere signifie la fin d'une ligne
; DEFAUT      si plac‚ dans le type de section d'un mot clef, ce symbole signifie' que la section
;             dans laquelle ce mot clef doit etre reconnu est celle du texte normal.
; VIRG        en place d un caractere signifie une virgule
; KEYWORD     en place des caractŠres de fin de section signifie que lorsqu'un mot clef est reconnu
;             il marque la fin de la section. Apres le mot clef KEYWORD il peut etre plac‚ une
;             chaine marquant aussi la fin de la section.
;
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ Parametres generaux (comme ceux de CONFIG.INF) ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
;                      ces paramŠtres sont facultatifs et permettent                         
;                      de specifier pour les fichiers concern‚s par                          
;                      le fichier de configuration syntaxique en cours                       
;                      des paramŠtres sp‚cifiques                                            

[Interligne] 11                         ;interligne en pixels
[Background] 0, 0                       ;couleur, trame
[NumLine] 0, 9, 0, 9, Monaco Mono       ;0/non affich‚e 1/affich‚, couleur
[EndOfLine] 1, 10, 0, 9, Monaco Mono    ;0/non affich‚e 1/affich‚, couleur
[LeftOfset] 1, 1                        ;0/non affich‚e 1/affich‚, taille en pixels,couleur,type ligne
[TabSpace] 4                            ;nombre d espaces pour expandre une tabulation
[CharTAB] 248                           ;code ASCII du caractere a employer pour visualiser les Tabubulations
[TabVisible] 1                          ;1/tabulation visible 0/tabulation non visible
[AniIndex] 1                            ;0/ index non anim‚   1/index anim‚ lorsqu'il s'ajoute une ligne
[AniFind] 0                             ;0/ animation   1/pas d'animation lors d'un chercher/remplacer
[EndGenParam]                           ;indique la fin des paramŠtres g‚n‚raux


;..........................................................................................
; type de    | type de la       | nom de la classe | couleur | effet  | taille | police
; definition | classe graphique | qui sera affiche | carac-  | carac- | carac- | carac- 
;            |                  | dans la LISTBOX  | tŠre    | tŠre   | tŠre   | tŠre
;            |                  | de parametrage   |         |        |        |
;..........................................................................................
[EndGenParam]                           ;indique la fin des paramŠtres g‚n‚raux

[CLASS_GRAP] ATT_TXT_DEFAULT,    Texte normal          ,   1,        0,        9,      Monaco Mono
[CLASS_GRAP] TYPVAR,             Typage variable       ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] MEMORYMOVE,         Mouvements memoire    ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] ROTATION  ,         Rotation              ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] BRANCHEMENT,        Branchements          ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] TEST_CLASS,         Tests                 ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] ARITMETIC,          Arithmetique          ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] OPERATOR,           Op‚rateurs            ,   2,        0,        9,      Monaco Mono
[CLASS_GRAP] DELIMITEURS,        D‚limiteurs           ,  10,        0,        9,      Monaco Mono
[CLASS_GRAP] BRANCHTRAP,         branchement trap      ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] NUMERIC,            valeur numeriques     ,  13,        0,        9,      Monaco Mono
[CLASS_GRAP] COMMENTAIRES,       Commentaires          ,  11,        0,        9,      Monaco Mono
[CLASS_GRAP] ADRESS_REG,         Registres d adresses  ,  15,        0,        9,      Monaco Mono
[CLASS_GRAP] DATA_REG,           Registres de donn‚es  ,  15,        0,        9,      Monaco Mono
[CLASS_GRAP] END_OF_FUNC,        Retour de routines    ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] LINK_LABEL,         R‚ferences            ,  13,        0,        9,      Monaco Mono
[CLASS_GRAP] SECTION    ,        Section TEXT DATA     ,  10,        0,        9,      Monaco Mono
[CLASS_GRAP] CLASS_STRING,       Chaines de caractŠres ,  14,        0,        9,      Monaco Mono

;............................... Section de validite de mots clefs...................................................................
;
; type de    | 1er   | 2Šme  | Nom et type | liste des caracteres    | Classe graphique | Flag champ de bit:      | Classe graphique
; definition | d‚lim | d‚lim | de la cette | autorises pour les mots | pour afficher    | Bit 0: si 1 il est tenu | pour afficher
;            | iteur | iteur | section     | cles de cette section   | les delimiteurs  | compte des Majuscules   | ce qu'il y a entre
;            |       |       |             |                         |                  | Minuscules pour identi- | les delimiteurs   
;            |       |       |             |                         |                  | fier les mots cles      |                   
;            |       |       |             |                         |                  | Bit 1: pareil mais pour |                   
;            |       |       |             |                         |                  | les delimiteurs.        |                   
;.....................................................................................................................................


[KW_SECTION] DEFAUT  , DEFAUT , DEFAUT     , 0->9 a->z A->Z _        , ATT_TXT_DEFAULT  ,  1                        ,ATT_TXT_DEFAULT

;........................... tableau de mots clefs ....................
;             
; type de    | nom du   | Reference de la  | Indentation  … mettre
; definition | mot clef | classe graphique | en place sous ce mot
;            |          | … utiliser       | clef
;            |          | pour affichage   |
;......................................................................
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ section TEXT DATA ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    text     , SECTION     , NO_INDENT, DEFAUT           ;/* 20 - 6  */
[KEY_WORD]    data     , SECTION     , NO_INDENT, DEFAUT           ;/* 21 - 8  */
[KEY_WORD]    even     , SECTION     , NO_INDENT, DEFAUT           ;/* 21 - 8  */
[KEY_WORD]    align    , SECTION     , NO_INDENT, DEFAUT           ;/* 21 - 8  */
[KEY_WORD]    bss      , SECTION     , NO_INDENT, DEFAUT           ;/* 21 - 8  */
[KEY_WORD]    end      , SECTION     , NO_INDENT, DEFAUT           ;/* 21 - 8  */
[KEY_WORD]    ofset    , SECTION     , NO_INDENT, DEFAUT           ;/* 21 - 8  */
[KEY_WORD]    super    , SECTION     , NO_INDENT, DEFAUT           ;/* 21 - 8  */

;¹¹¹¹¹¹¹¹¹¹¹¹¹¹ Instruction de linkage et compilation ¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    import   , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 21 - 8  */
[KEY_WORD]    export   , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */
[KEY_WORD]    xdef     , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */
[KEY_WORD]    xref     , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */
[KEY_WORD]    module   , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */
[KEY_WORD]    endmod   , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */
[KEY_WORD]    glob     , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */
[KEY_WORD]    equ      , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */
[KEY_WORD]    set      , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */
[KEY_WORD]    reg      , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */
[KEY_WORD]    include  , LINK_LABEL  , NO_INDENT, DEFAUT           ;/* 22 - 6  */

;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ branchement ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    bgt      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 21 - 8  */
[KEY_WORD]    ble      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 23 - 5  */
[KEY_WORD]    bne      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 13 - 6  */
[KEY_WORD]    beq      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 15 - 5  */
[KEY_WORD]    bra      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 17 - 6  */
[KEY_WORD]    bpl      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 45 - 7  */
[KEY_WORD]    dbeq     , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    dbra     , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    jsr      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    bls      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    bcc      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    bmi      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    bcs      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    bge      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    dbf      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    bsr      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    blt      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    bhi      , BRANCHEMENT , NO_INDENT, DEFAUT           ;/* 51 - 6  */

;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ fin de routine ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    rts      , END_OF_FUNC , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    rte      , END_OF_FUNC , NO_INDENT, DEFAUT           ;/* 51 - 6  */
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ mots clefs ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    move     , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 27 - 2  */
[KEY_WORD]    moveq    , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 29 - 6  */
[KEY_WORD]    moveq    , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 29 - 6  */
[KEY_WORD]    movep    , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 31 - 5  */
[KEY_WORD]    movem    , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 31 - 5  */
[KEY_WORD]    lea      , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 33 - 7  */
[KEY_WORD]    movea    , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 35 - 3  */
[KEY_WORD]    ds       , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 35 - 3  */
[KEY_WORD]    dc       , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 35 - 3  */
[KEY_WORD]    dcb      , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 35 - 3  */
[KEY_WORD]    swap     , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 35 - 3  */
[KEY_WORD]    pea      , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 35 - 3  */
[KEY_WORD]    nop      , MEMORYMOVE  , NO_INDENT, DEFAUT           ;/* 35 - 3  */
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ calcul ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    subi     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 10 - 8  */
[KEY_WORD]    sub      , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 10 - 8  */
[KEY_WORD]    subq     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 10 - 8  */
[KEY_WORD]    suba     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 10 - 8  */

[KEY_WORD]    add      , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 10 - 8  */
[KEY_WORD]    adda     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 10 - 8  */
[KEY_WORD]    bclr     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 19 - 4  */
[KEY_WORD]    addq     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 25 - 5  */
[KEY_WORD]    clr      , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 37 - 5  */
[KEY_WORD]    neg      , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 47 - 6  */
[KEY_WORD]    ext      , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 49 - 3  */
[KEY_WORD]    addx     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 43 - 4  */
[KEY_WORD]    mulu     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 55 - 5  */
[KEY_WORD]    muls     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 55 - 5  */
[KEY_WORD]    divul    , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    divu     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    divsl    , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    divs     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    and      , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    andi     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    bset     , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    or       , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    ori      , ARITMETIC  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ Trape ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    trap     , BRANCHTRAP  , NO_INDENT, DEFAUT           ;/* 39 - 6  */
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ test ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    tst      , TEST_CLASS  , NO_INDENT, DEFAUT           ;/* 41 - 5  */
[KEY_WORD]    cmp      , TEST_CLASS  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    cmpa     , TEST_CLASS  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    cmpi     , TEST_CLASS  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    btst     , TEST_CLASS  , NO_INDENT, DEFAUT           ;/* 56 - 5  */

;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ rotation ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    roxr     , ROTATION  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    roxl     , ROTATION  , NO_INDENT, DEFAUT           ;/* 55 - 5  */
[KEY_WORD]    ror      , ROTATION  , NO_INDENT, DEFAUT           ;/* 56 - 5  */
[KEY_WORD]    rol      , ROTATION  , NO_INDENT, DEFAUT           ;/* 52 - 4  */
[KEY_WORD]    lsl      , ROTATION  , NO_INDENT, DEFAUT           ;/* 54 - 3  */
[KEY_WORD]    lsr      , ROTATION  , NO_INDENT, DEFAUT           ;/* 51 - 6  */
[KEY_WORD]    asr      , ROTATION  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    not      , ROTATION  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹type variables ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    l      , TYPVAR  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    w      , TYPVAR  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    b      , TYPVAR  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    s      , TYPVAR  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹registres ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    a0      , ADRESS_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    a1      , ADRESS_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    a2      , ADRESS_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    a3      , ADRESS_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    a4      , ADRESS_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    a5      , ADRESS_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    a6      , ADRESS_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    a7      , ADRESS_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    sp      , ADRESS_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */

[KEY_WORD]    d0      , DATA_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    d1      , DATA_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    d2      , DATA_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    d3      , DATA_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    d4      , DATA_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    d5      , DATA_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    d6      , DATA_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */
[KEY_WORD]    d7      , DATA_REG  , NO_INDENT, DEFAUT           ;/* 53 - 8  */

;.............. caractŠres … reconnaitre comme op‚rateurs ...................
;             
; type de    | caractere | classe         | Indentation   |Section dans laquelle
; definition | operateur | graphique      |               |l'op‚rateur est valide
;............................................................................

;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ delimiteurs ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹

;[OPERATOR]    [        , DELIMITEURS        , NO_INDENT   , DEFAUT
;[OPERATOR]    ]        , DELIMITEURS        , NO_INDENT   , DEFAUT
[OPERATOR]    (         , DELIMITEURS        , NO_INDENT   , DEFAUT
[OPERATOR]    )         , DELIMITEURS        , NO_INDENT   , DEFAUT

;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ operateurs ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[OPERATOR]    -         , OPERATOR           , NO_INDENT   , DEFAUT
[OPERATOR]    +         , OPERATOR           , NO_INDENT   , DEFAUT
[OPERATOR]    :         , OPERATOR           , NO_INDENT   , DEFAUT
;[OPERATOR]    #         , OPERATOR           , NO_INDENT   , DEFAUT
;[OPERATOR]    $         , OPERATOR           , NO_INDENT   , DEFAUT
[OPERATOR]    VIRG      , OPERATOR           , NO_INDENT   , DEFAUT

;.............. caractŠres … reconnaitre comme valeur num‚rique .............
;             
; type de    | caracteres     | caracteres         | classe         | classe graphique | Section dans laquelle
; definition | introducteurs  | reconnus apres     | graphique de   | de ce qui suit   | la definition est valide
;            |                | l introducteur     | l introducteur | l introducteur   |          
;............................................................................
[NUMERIC]      #$             , a->f A->F 0->9 %   ,      OPERATOR  ,    NUMERIC       , DEFAUT


;........... delimiteurs de debut et fin de section .........................
;            un double click marque le debut et fin
;             
; type de    | 1er del- | 2Šme del | classe    | chaine des | KW_Section
; definition | imiteur  | limiteur | graphique | escapes    | d'appartenance
;............................................................................
[SECTION]     POINTVIRG ,  EOL    , COMMENTAIRES   ,0       ,DEFAUT
[SECTION]     *         ,  EOL    , COMMENTAIRES   ,0       ,DEFAUT
[SECTION]     "         ,"        , CLASS_STRING   ,\       ,DEFAUT
[SECTION]     '         ,'        , NUMERIC        ,        ,DEFAUT

