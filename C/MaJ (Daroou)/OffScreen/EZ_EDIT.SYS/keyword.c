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
; L exemple suivant est le fichier utilis‚ pour coloriser la syntaxe du C et C++
; Y sont inclus aussi les mots clefs des constantes et definitions utilis‚es par le GEM
; ainsi que ceux d EZ_GEM (si ils vous sont inutiles effacez les)
;
; Description des differentes definitions avec syntaxe et paramŠtres:
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
;                                                                                            
[Interligne] 11                         ;interligne en pixels
[VerticalAdjust] 5                      ;ajustage vertical pour fontes speedo en pixels
[LeftOfset] 1, 1                        ;0/non affich‚e 1/affich‚, taille en pixels,couleur,type ligne
[RightOfset] 1, 70                      ;0/non affich‚e 1/affich‚, taille en pixels,couleur,type ligne
[NbLinePage] 1, 80                      ;0/non affich‚e 1/affich‚, taille en pixels,couleur,type ligne
[Background] 0, 3                       ;couleur, trame
[NumLine] 0, -1, 0, 9, Monaco Mono      ;0/non affich‚e 1/affich‚, couleur
[TabSpace] 4                            ;nombre d'espaces pour expandre une tabulation
[CharTAB] 248                           ;code ASCII du caractere a employer pour visualiser les Tabubulations
[TabVisible] 1                          ;1/tabulation visible 0/tabulation non visible
[EndOfLine] 1, 10, 0, 9, Monaco Mono    ;0/non affich‚e 1/affich‚, couleur
[EndGenParam]                           ;indique la fin des paramŠtres g‚n‚raux 

;.............................. Classe graphiques .........................................
;                                                                                          
; type de    | type de la       | nom de la classe | couleur | effet  | taille | police    
; definition | classe graphique | qui sera affiche | carac-  | carac- | carac- | carac-    
;            |                  | dans la LISTBOX  | tŠre    | tŠre   | tŠre   | tŠre      
;            |                  | de parametrage   |         |        |        |           
;..........................................................................................



[CLASS_GRAPH] CLASS_DEFAULT ,Texte normal ,1 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_TYPVAR ,Typage variable ,15 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_KEYWRD ,Mots Clefs du C ,4 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_INCLUDE ,#include ,13 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_MACRO ,#define ,13 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_PRECOMP ,#Precompilation ,13 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_PRAGMA ,#Pragma ,13 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_STRING ,Chaines ,14 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_COMMENT ,Commentaires ,11 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_OPERATOR ,Op‚rateurs ,2 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_NUMERIC ,Numerique ,13 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_STRUCT ,GEM Structures ,10 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] CLASS_CONST ,GEM Constantes ,12 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] EZ_GEM_GLOB_VAR ,EZ_GEM Variables ,7 ,0 ,9 ,Monaco Mono
;[CLASS_GRAPH] CLASS_BRACE,      Accolades {}     ,   2,        0,        9,      Monaco Mono
;[CLASS_GRAPH] CLASS_PARENT,     ParenthŠses ()   ,   2,        0,        9,      Monaco Mono
;[CLASS_GRAPH] CLASS_CROCHET,    Crochets []      ,   2,        0,        9,      Monaco Mono

;...................... Section de validite de mots clefs (texte normal)...............................................................
;                                                                                                                                      
; type de    | 1er   | 2Šme   | Nom et type | liste des caracteres    | Classe graphique | Flag champ de bit:      | Classe graphique  
; definition | d‚lim | d‚lim  | de cette    | autorises pour les mots | pour afficher    | Bit 0: si 1 il est tenu | pour afficher     
;            | iteur | iteur  | section     | cles de cette section   | les delimiteurs  | compte des Majuscules   | ce qu il y a ENTRE
;            |                |             |                         |                  | Minuscules pour identi- | les delimiteurs.  
;            | DEFAUT pour fin|             |                         |                  | fier les mots cles      |                   
;            | et debut signi-|             |                         |                  | Bit 1: pareil mais pour |                   
;            | fie: texte nor-|             |                         |                  | les delimiteurs.        |                   
;            | mal            |             |                         |                  |                         |                   
;......................................................................................................................................
[KW_SECTION]  DEFAUT , DEFAUT , DEFAUT      , 0->9 a->z A->Z _        , CLASS_DEFAULT    ,0                        ,CLASS_DEFAULT

;............................... Section de validite des mots clefs de (precompilation)..........................................................
;                                                                                                                                                
; type de    | 1er   | 2Šme d‚limiteur  | Nom et type | liste des caracteres    | Classe graphique | Flag champ de bit:      | Classe graphique  
; definition | d‚lim | (peut etre un    | de cette    | autorises pour les mots | pour afficher    | Bit 0: si 1 il est tenu | pour afficher     
;            | iteur |  mot clef car    | section     | cles de cette section   | les delimiteurs  | compte des Majuscules   | ce qu il y a entre
;            |       |  mention KEYWORD |             |                         |                  | Minuscules pour identi- | les delimiteurs   
;            |       |  ou une fin de   |             |                         |                  | fier les mots cles      |                   
;            |       |  ligne car       |             |                         |                  | Bit 1: pareil mais pour |                   
;            |       |  mention EOL)    |             |                         |                  | les delimiteurs.        |                   
;.....................................................................................................................................
[KW_SECTION]  #      ,KEYWORD EOL #     , PRECOMPIL   , acdefgilmnoprsu         , CLASS_PRECOMP    ,0                        ,CLASS_DEFAULT

;.................. tableau de mots clefs C et C++ ..................................
;             
; type de    | nom du   | Reference de la  | Indentation |Section dans laquelle     
; definition | mot clef | classe graphique | de ce mot   |le mot clef doit etre     
;            |          | … utiliser       | clef        |reconnu (si zero ou DEFAUT
;            |          | pour affichage   |             |alors le mot clef  est    
;            |          |                  |             |reconnu dans la section   
;            |          |                  |             |par defaut: texte normal) 
;....................................................................................

;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ Mots clefs de la section de Precompilation: PRECOMPIL ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    ifndef    , CLASS_PRECOMP , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    endif     , CLASS_INCLUDE , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    ifdef     , CLASS_PRECOMP , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    undef     , CLASS_PRECOMP , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    pragma    , CLASS_PRAGMA  , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    error     , CLASS_PRECOMP , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    elif      , CLASS_PRECOMP , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    if        , CLASS_PRECOMP , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    else      , CLASS_PRECOMP , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    include   , CLASS_INCLUDE , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    define    , CLASS_MACRO   , NO_INDENT           ,PRECOMPIL
[KEY_WORD]    line      , CLASS_PRECOMP , NO_INDENT           ,PRECOMPIL

;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ Mots clefs de la section par defaut (texte normal): DEFAUT ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹

[KEY_WORD]    defined   , CLASS_PRECOMP , NO_INDENT           ,DEFAUT
[KEY_WORD]    warning   , CLASS_PRECOMP , NO_INDENT           ,DEFAUT
[KEY_WORD]    once      , CLASS_PRECOMP , NO_INDENT           ,DEFAUT
[KEY_WORD]    warn      , CLASS_PRECOMP , NO_INDENT           ,DEFAUT

[KEY_WORD]    char      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]     int      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]     int8     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    uint8     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]     int16    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    uint16    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]     int32    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    uint32    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]     int64    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    uint64    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT

[KEY_WORD]    long      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    static    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    unsigned  , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    void      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    double    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    float     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    auto      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    extern    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    register  , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    volatile  , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    signed    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    short     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    cdecl     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    const     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    pascal    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    size_t    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ typages non standards ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹
[KEY_WORD]    UWORD     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    WORD      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    ULONG     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LONG      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    UBYTE     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    BYTE      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    VOID      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    FAR       , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    DWORD     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    BOOL      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    UINT      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    INT       , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    INT16     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    INT32     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    CHAR      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    UCHAR     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    WCHAR     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    TCHAR     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    SHORT     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    USHORT    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPVOID    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    PVOID     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPSTR     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPBYTE    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    WSTR      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPWSTR    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPUINT    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPINT     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPBOOL    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPWORD    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPUWORD   , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPDWORD   , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    WPARAM    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LPARAM    , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    bool      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    HWND      , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LRESULT   , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    __CDECL   , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    CDECL     , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT

[KEY_WORD]    if        , CLASS_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    else      , CLASS_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    switch    , CLASS_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    case      , CLASS_KEYWRD  , 4                   ,DEFAUT
[KEY_WORD]    break     , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    continue  , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    default   , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    do        , CLASS_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    for       , CLASS_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    goto      , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    while     , CLASS_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    return    , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    sizeof    , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    struct    , CLASS_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    union     , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    typedef   , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    enum      , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    class     , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    virtual   , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    private   , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    public    , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    protected , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    new       , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    delete    , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    friend    , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    this      , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    template  , CLASS_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    try       , CLASS_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    catch     , CLASS_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    throw     , CLASS_KEYWRD  , 3                   ,DEFAUT

;............. tableau de mots clefs GEM ..............................
;             
; type de    | nom du   | Reference de la  | Indentation |Section dans laquelle le mot
; definition | mot clef | classe graphique | de ce mot   |clef doit etre reconnu (si zero ou DEFAUT
;            |          | … utiliser       | clef        |alors le mot clef est reconnu dans
;            |          | pour affichage   |             |la section par defaut: texte normal)
;......................................................................
[KEY_WORD]    OBJECT     , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    GRECT      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    TEDINFO    , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    RSXHDR     , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    COOKIE     , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    PARMBLK    , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    XMFDB      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    GEMPARBLK  , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    AESPB      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    MOBLK      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    EVENT      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    ORECT      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    ICONBLK    , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    CICON      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    CICONBLK   , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    BITBLK     , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    USERBLK    , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    OBSPEC     , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    MENU       , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    MN_SET     , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    MFORM      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    RSHDR      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    BFOBSPEC   , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    BFTEDCOLOR , CLASS_STRUCT  , NO_INDENT           ,DEFAUT

[KEY_WORD]    VDIPARBLK  , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    VDIPB      , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    MFDB       , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    KEYTAB     , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    FILE       , CLASS_STRUCT  , NO_INDENT           ,DEFAUT

[KEY_WORD]    TRUE              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FALSE             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    NULL              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ZERO              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    NIL               , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    MU_KEYBD          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MU_BUTTON         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MU_M1             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MU_M2             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MU_MESAG          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MU_TIMER          , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    MN_SELECTED       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_REDRAW         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_TOPPED         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_CLOSED         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_FULLED         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_ARROWED        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_HSLID          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_VSLID          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_SIZED          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_MOVED          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_NEWTOP         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_UNTOPPED       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_ONTOP          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_BOTTOM         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_ICONIFY        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_UNICONIFY      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_ALLICONIFY     , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_TOOLBAR        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    AC_OPEN           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    AC_CLOSE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CT_UPDATE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CT_MOVE           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CT_NEWTOP         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    AP_TERM           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    AP_TFAIL          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    AP_RESCHG         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SHUT_COMPLETED    , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    RESCHG_COMPLETED  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    RESCH_COMPLETED   , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SH_WDRAW          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    AP_DRAGDROP       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CH_EXIT           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    K_RSHIFT          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    K_LSHIFT          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    K_CTRL            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    K_ALT             , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    G_BOX             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_TEXT            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_BOXTEXT         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_IMAGE           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_USERDEF         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_IBOX            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_BUTTON          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_BOXCHAR         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_STRING          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_FTEXT           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_FBOXTEXT        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_ICON            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_TITLE           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    G_CICON           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    NONE              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SELECTABLE        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DEFAULT           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXIT              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDITABLE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    RBUTTON           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LASTOB            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TOUCHEXIT         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    HIDETREE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    INDIRECT          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FL3DIND           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FL3DACT           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FL3DBAK           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SUBMENU           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_NONE           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_SELECTABLE     , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_DEFAULT        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_EXIT           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_EDITABLE       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_RBUTTON        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_LASTOB         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_TOUCHEXIT      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_HIDETREE       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_INDIRECT       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_FL3DIND        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_FL3DACT        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_FL3DBAK        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OF_SUBMENU        , CLASS_CONST   , NO_INDENT           ,DEFAUT


[KEY_WORD]    NORMAL            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SELECTED          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CROSSED           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CHECKED           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DISABLED          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OUTLINED          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SHADOWED          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD] OS_NORMAL            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD] OS_SELECTED          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD] OS_CROSSED           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD] OS_CHECKED           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD] OS_DISABLED          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD] OS_OUTLINED          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD] OS_SHADOWED          , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    WHITE             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BLACK             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    RED               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    GREEN             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BLUE              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CYAN              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    YELLOW            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MAGENTA           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LWHITE            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LBLACK            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LRED              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LGREEN            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LBLUE             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LCYAN             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LYELLOW           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LMAGENTA          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_WHITE             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_BLACK             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_RED               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_GREEN             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_BLUE              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_CYAN              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_YELLOW            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_MAGENTA           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_LWHITE            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_LBLACK            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_LRED              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_LGREEN            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_LBLUE             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_LCYAN             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_LYELLOW           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  G_LMAGENTA          , CLASS_CONST   , NO_INDENT           ,DEFAUT


; *********************************************************************

; VDI - vs_clip()
[KEY_WORD]  CLIP_ON             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  CLIP_OFF            , CLASS_CONST   , NO_INDENT           ,DEFAUT

; GEMDOS - Fopen()
[KEY_WORD]  S_COMPAT            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  S_READ              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  S_WRITE             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  S_READWRITE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  S_DENYREADWRITE     , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  S_DENYWRITE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  S_DENYREAD          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  S_DENYNONE          , CLASS_CONST   , NO_INDENT           ,DEFAUT

; GEMDOS - Fseek()
[KEY_WORD]  SEEK_END            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  SEEK_CUR            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]  SEEK_SET            , CLASS_CONST   , NO_INDENT           ,DEFAUT


; *********************************************************************




[KEY_WORD]    ROOT              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MAX_LEN           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MAX_DEPTH         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OB_ROOT           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    GDOS_PROP         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    GDOS_MONO         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    GDOS_BITM         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IBM               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SMALL             , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    ED_START          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_INIT           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_CHAR           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_END            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_STR            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_ERASE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_BLKAFF         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_ALL_REDRAW     , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    TE_LEFT           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TE_RIGHT          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TE_CNTR           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    FMD_START         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FMD_GROW          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FMD_SHRINK        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FMD_FINISH        , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    ARROW             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TEXT_CRSR         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    HOURGLASS         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BUSYBEE           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BEE               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BUSY_BEE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    POINT_HAND        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FLAT_HAND         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    THIN_CROSS        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    THICK_CROSS       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    OUTLN_CROSS       , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    IDC_ARROW         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IDC_SIZEWE        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IDC_SIZENS        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IDC_SIZEALL       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IDC_SIZENWSE      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IDC_SIZENESW      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IDC_NO            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IDC_UPARROW       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IDC_INFO          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    IDC_INTERO        , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    USER_DEF          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    M_OFF             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    M_ON              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    M_SAVE            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    M_LAST            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    M_RESTORE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    M_FORCE           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    NAME              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CLOSER            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FULLER            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MOVER             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    INFO              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SIZER             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    UPARROW           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DNARROW           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    VSLIDE            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LFARROW           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    RTARROW           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    HSLIDE            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    HOTCLOSEBOX       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    HOTCLOSE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BORDER            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BACKDROP          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SMALLER           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    WF_KIND           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_NAME           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_INFO           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_WORKXYWH       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_CURRXYWH       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_PREVXYWH       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_FULLXYWH       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_HSLIDE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_VSLIDE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_TOP            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_FIRSTXYWH      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_NEXTXYWH       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_RESVD          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_NEWDESK        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_HSLSIZE        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_VSLSIZE        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_SCREEN         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_COLOR          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_DCOLOR         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_OWNER          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_BEVENT         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_BOTTOM         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_ICONIFY        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_UNICONIFY      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_UNICONIFYXYWH  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_TOOLBAR        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_FTOOLBAR       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_NTOOLBAR       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_WINX           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WF_WINXCFG        , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    W_BOX             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_TITLE           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_CLOSER          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_NAME            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_FULLER          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_INFO            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_DATA            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_WORK            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_SIZER           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_VBAR            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_UPARROW         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_DNARROW         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_VSLIDE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_VELEV           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_HBAR            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_LFARROW         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_RTARROW         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_HSLIDE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_HELEV           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_SMALLER         , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    WA_UPPAGE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WA_DNPAGE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WA_UPLINE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WA_DNLINE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WA_LFPAGE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WA_RTPAGE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WA_LFLINE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WA_RTLINE         , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    WC_BORDER         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WC_WORK           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    END_UPDATE        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BEG_UPDATE        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    END_MCTRL         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BEG_MCTRL         , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    R_TREE            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_OBJECT          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_TEDINFO         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_ICONBLK         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_BITBLK          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_STRING          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_IMAGEDATA       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_OBSPEC          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_TEPTEXT         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_TEPTMPLT        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_TEPVALID        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_IBPMASK         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_IBPDATA         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_IBPTEXT         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_IPBTEXT         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_BIPDATA         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_FRSTR           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    R_FRIMG           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    TXT_NORMAL        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TXT_THICKENED     , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TXT_LIGHT         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TXT_SKEWED        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TXT_UNDERLINED    , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TXT_OUTLINED      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TXT_SHADOWED      , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    ALI_LEFT          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ALI_CENTER        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ALI_RIGHT         , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    ALI_BASE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ALI_HALF          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ALI_ASCENT        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ALI_BOTTOM        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ALI_DESCENT       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ALI_TOP           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    MD_REPLACE        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MD_TRANS          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MD_XOR            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MD_ERASE          , CLASS_CONST   , NO_INDENT           ,DEFAUT


[KEY_WORD]    DD_OK             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_NAK            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_EXT            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_LEN            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_TRASH          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_PRINTER        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_CLIPBOARD      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_TIMEOUT        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_NUMEXTS        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_EXTSIZE        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_NAMEMAX        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_HDRMAX         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_HDRMIN         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MAX_PATH          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    VA_START          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    VA_AKCNW          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_HDRMAX         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    DD_HDRMIN         , CLASS_CONST   , NO_INDENT           ,DEFAUT

;............. tableau de mots clefs EAZY_GEM ..................................................
;             
; type de    | nom du              | Reference de la  | Indentation |Section dans laquelle le mot
; definition | mot clef            | classe graphique | de ce mot   |clef doit etre reconnu (si zero ou DEFAUT
;            |                     | … utiliser       | clef        |alors le mot clef est reconnu dans
;            |                     | pour affichage   |             |la section par defaut: texte normal)
;...............................................................................................
[KEY_WORD]    VRECT                , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    MENUSERBLK           , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    XUSERBLK             , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    DLG_VAR              , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXTND_DIM            , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    WINDTAB              , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    RECT                 , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    EVNT_O               , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    EVNT_I               , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    XSCROLLBLK           , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLL_TXT_PRM       , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    TXTED_OB             , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    MACHINE_INFO         , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    MO_STACK             , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    CALLBACK             , CLASS_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    ONGLETUSERBLK        , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLLBOX_GET_AFFI   , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    ONG_LST              , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    DID_HELP             , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    ONG_DRAW_PARAM       , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    TOOL_TIPS            , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    FICSTRUCT            , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    CHPSTRUCT            , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    EZB_FIC_STRUCT       , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LIST_BOX             , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    ONG_LST              , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    MEN_CASE             , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    POINT                , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    POINTL               , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    FLYBUFF              , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    UNDO_REC             , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    UNDO_STACK           , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    CAR_ATTR             , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LGN_CTX              , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    LIST_GET_TXT         , CLASS_STRUCT  , NO_INDENT           ,DEFAUT
[KEY_WORD]    NEW_EDIT             , CLASS_STRUCT  , NO_INDENT           ,DEFAUT

[KEY_WORD]    MU_MOVE              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MU_UPL               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MU_DWL               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MU_UPR               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MU_DWR               , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    WM_CONSTRUCT         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_DESTRUCT          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_ABORT             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_TT_GET_TXT        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_PAINT             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_UNTOP             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_ISTOP             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_POPUP_CHANGE      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_TT_ON_OFF         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_STANDBY           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_WND_MENU          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_EXEFUNC           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_ONGLET_CHG        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_PAINTBOX          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_ACTIVEWIND        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_MODAL_END         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_PAINT_ICON        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_PARAM_SEND        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_EDIT_OPEN         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_EDIT_CLOSE        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_EDIT_UPDATE       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_SCROLL_DO         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_LIST_DO           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WM_EDIT_ON           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    IDC_LISTBOX          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TO_FILE              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TO_SCREEN            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ERR_ERASE            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ERR_APPEND           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    XSIZER               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    XMODAL               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    XBORDER              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    XFRAME               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    XMOVER               , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    RSC_PLUS             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    RSC_DIAL             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TOOL_BAR             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    NO_SCALE             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCALE                , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    K_LRSHIFT            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    K_ALT_SHIFT          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    K_CTRL_SHIFT         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    K_ALT_CTRL           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    K_ALT_SHIFT_CTRL     , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    SCROLL_TXT           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    GROUP_LITLE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    GROUP_LARGE          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    RADIO_BUTTON         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    COCHE_BUTTON         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TT_STATE_BOX         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LISTBOX              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WINDMENU             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ONGLET_MASTER        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CADRE_VIDE           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLL_GROUP0        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLL_BOX           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLL_EDIT          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ONGLET_SLAVE         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MULTI_DIAL           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TOP_DIAL             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    RIGHT_DIAL           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BOTTOM_DIAL          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    LEFT_DIAL            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLL_GROUP         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLLV_UP           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLLV_DW           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLLV_AS           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLLV_BAR          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLLH_LF           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLLH_RG           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLLH_AS           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCROLLH_BAR          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    PAINT_BOX            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ICON_WIND            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ICON_APPL            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCRIPT_LINK          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SCRIPT_TARGET        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TAB_LINK_CONT        , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    NEW_BUTTON           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    USER_SV_UP           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    USER_SV_DW           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    USER_SV_AS           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    USER_SV_BAR          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    USER_SH_LF           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    USER_SH_RG           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    USER_SH_AS           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    USER_SH_BAR          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    USER_BMPBOX          , CLASS_CONST   , NO_INDENT           ,DEFAUT


[KEY_WORD]    ATT_TXT_NORMAL       , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ATT_TXT_NUM_LGN      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ATT_TXT_EOL          , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    EXE_ED_COPY          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_COPY_ADD      , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_CUT           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_DEL           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_SCRAP_PASTE   , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_MEMORY_PASTE  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_FILE_PASTE    , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_SET_CURS_POS  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_SET_SEL_DEB   , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_SET_SEL_END   , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EXE_ED_CLEAR_SEL     , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    AID_REQUEST          , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    AID_SEND             , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    WM_USER              , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    MESG                 , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    APPL                 , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    SUPL                 , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    WHND                 , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    X_G                  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    Y_G                  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_G                  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    H_G                  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    X_B                  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    Y_B                  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    W_B                  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    H_B                  , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    HORIZONTAL           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    VERTICAL             , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    BLK_DEB              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BLK_END              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CURS_POS             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BLK_DEBXY            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BLK_ENDXY            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CURS_POSXY           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BLK_TXT_MARK         , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    XY_TO_LIGPT          , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    CURS_ERASE           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CURS_DRAW            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    CURS_FLASH           , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    EDIT_ACTIV                 , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MO_TRACK_ON                , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDIT_CHG                   , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDIT_HIDE                  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDIT_TAB                   , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDIT_TAB_VISIBLE           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDIT_BLK_NOT_AFTER_PASTE   , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDIT_SCRLV_NOT_AFTER_PASTE , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDIT_SCRLH_NOT_AFTER_PASTE , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDIT_MOFORM_POINT_HAND     , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EDIT_MOFORM_ARROW          , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    ED_NBR_LIG_CHG            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_FST_LIG_CHG            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_FST_CLN_CHG            , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_POS_CURS_CHG           , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_CLICK_OUT              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_LOSE_FOCUS             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_CLICK_IN               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_SET_FOCUS              , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_KEYB_CNTRL             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_KEYB_ALT               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_KEYB_DWN               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_TXT_CHG                , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_SIZE_CHG               , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_RETURN_DWN             , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ED_RETURN_CHG             , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    TXT_SAVE                  , CLASS_CONST   , NO_INDENT           ,DEFAUT
[KEY_WORD]    BLK_SAVE                  , CLASS_CONST   , NO_INDENT           ,DEFAUT

[KEY_WORD]    Appl_id                   , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MS_NB                     , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MAX_TTIPS                 , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MAX_WIND                  , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MIN_SLIDE_W               , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    NomAppli                  , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EZ_message                , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ApplIcn                   , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MachineInfo               , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    AESversion                , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    VDIhandle                 , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    Ecran_l                   , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    Ecran_h                   , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    Nb_plan                   , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    Nb_color                  , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EZGemRun                  , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    Windtab                   , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TTswitch                  , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TT_Time_ON                , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    TT_Time_OFF               , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MenTTBack                 , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    NbFont                    , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FontTab                   , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FontName                  , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    FontID                    , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    Gdos                      , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ModalFSEL                 , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    ModalWind                 , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    Screen_MFDB               , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    MoStack                   , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT
[KEY_WORD]    EZ_VDIPB                  , EZ_GEM_GLOB_VAR   , NO_INDENT           ,DEFAUT

;.............. caractŠres … reconnaitre comme op‚rateurs ....................
;             
; type de    | caractere | classe         | Indentation   |Section dans laquelle
; definition | operateur | graphique      |               |l op‚rateur est valide
;............................................................................

[OPERATOR]    [          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    ]          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    =          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    &          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    !          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    *          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    -          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    +          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    :          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    (          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    )          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    {          , CLASS_OPERATOR  , -1          , DEFAUT
[OPERATOR]    }          , CLASS_OPERATOR  , -4          , DEFAUT
[OPERATOR]    ?          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    <          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    >          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    |          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    ^          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    %          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    ~          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    /          , CLASS_OPERATOR  , NO_INDENT   , DEFAUT

;.............. caractŠres … reconnaitre comme valeur num‚rique .............
;             
; type de    | caracteres     | caracteres         | classe         | classe graphique | Section dans laquelle
; definition | introducteurs  | reconnus apres     | graphique de   | de ce qui suit   | la definition est valide
;            |                | l introducteur     | l introducteur | l introducteur   |          
;............................................................................
[NUMERIC]      0->9           , a->f A->F 0->9 xXlL. , CLASS_NUMERIC  , CLASS_NUMERIC  , DEFAUT


;........... delimiteurs de debut et fin de section .........................
;            un double click marque le debut et fin
;             
; type de    | 1er del- | 2Šme del | classe    | chaine des | KW_Section
; definition | imiteur  | limiteur | graphique | escapes    | d appartenance
;............................................................................
[SECTION]     /*        ,  */     , CLASS_COMMENT ,         ,DEFAUT
[SECTION]     //        , EOL     , CLASS_COMMENT ,         ,DEFAUT
[SECTION]     "         ,"        , CLASS_STRING  ,\        ,DEFAUT
[SECTION]     '         ,'        , CLASS_NUMERIC ,\        ,DEFAUT

[SECTION]     /*        ,  */     , CLASS_COMMENT ,         ,PRECOMPIL
[SECTION]     //        , EOL     , CLASS_COMMENT ,         ,PRECOMPIL
[SECTION]     '         ,'        , CLASS_NUMERIC ,\        ,DEFAUT
