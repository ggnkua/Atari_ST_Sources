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
[NumLine] 0, -1, 0, 10, Monaco Mono     ;0/non affich‚e 1/affich‚, couleur
[TabSpace] 4                            ;nombre d'espaces pour expandre une tabulation
[CharTAB] 248                           ;code ASCII du caractere a employer pour visualiser les Tabubulations
[TabVisible] 1                          ;1/tabulation visible 0/tabulation non visible
[EndOfLine] 1, 10, 0, 10, Monaco Mono   ;0/non affich‚e 1/affich‚, couleur
[EndGenParam]                           ;indique la fin des paramŠtres g‚n‚raux 

;.............................. Classe graphiques .........................................
;                                                                                          
; type de    | type de la       | nom de la classe | couleur | effet  | taille | police    
; definition | classe graphique | qui sera affiche | carac-  | carac- | carac- | carac-    
;            |                  | dans la LISTBOX  | tŠre    | tŠre   | tŠre   | tŠre      
;            |                  | de parametrage   |         |        |        |           
;..........................................................................................



[CLASS_GRAPH] JAVA_DEFAULT ,Texte normal ,1 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] JAVA_TYPVAR ,Typage variable ,15 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] JAVA_KEYWRD ,Mots Clefs du C ,4 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] JAVA_STRING ,Chaines ,14 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] JAVA_COMMENT ,Commentaires ,11 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] JAVA_OPERATOR ,Op‚rateurs ,2 ,0 ,9 ,Monaco Mono
[CLASS_GRAPH] JAVA_NUMERIC ,Numerique ,13 ,0 ,9 ,Monaco Mono

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
[KW_SECTION]  DEFAUT , DEFAUT , DEFAUT      , 0->9 a->z A->Z _        , JAVA_DEFAULT    ,0                        ,JAVA_DEFAULT


;¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹ Mots clefs de la section par defaut (java): DEFAUT ¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹¹

[KEY_WORD]    char      , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    int       , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    long      , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    static    , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    void      , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    double    , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    float     , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    volatile  , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    short     , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    const     , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    byte      , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    boolean   , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    persistent, JAVA_TYPVAR  , NO_INDENT           ,DEFAUT
[KEY_WORD]    var       , JAVA_TYPVAR  , NO_INDENT           ,DEFAUT

[KEY_WORD]    if        , JAVA_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    else      , JAVA_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    switch    , JAVA_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    case      , JAVA_KEYWRD  , 4                   ,DEFAUT
[KEY_WORD]    break     , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    function  , JAVA_FUNC    , NO_INDENT           ,DEFAUT
[KEY_WORD]    with      , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    continue  , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    default   , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    do        , JAVA_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    for       , JAVA_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    goto      , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    while     , JAVA_KEYWRD  , 3                   ,DEFAUT
[KEY_WORD]    return    , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    class     , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    private   , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    public    , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    protected , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    new       , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    this      , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    try       , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    catch     , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    throw     , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    throws    , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    abstract  , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    extends   , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    false     , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    final     , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    finally   , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    implements, JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    import    , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    instanceof, JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    interface , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    native    , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    null      , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    package   , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    super     , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    transient , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    true      , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    privateprotected     , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    synchronous          , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    strictfp             , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT
[KEY_WORD]    synchronized         , JAVA_KEYWRD  , NO_INDENT           ,DEFAUT

;.............. caractŠres … reconnaitre comme op‚rateurs ....................
;             
; type de    | caractere | classe         | Indentation   |Section dans laquelle
; definition | operateur | graphique      |               |l op‚rateur est valide
;............................................................................

[OPERATOR]    [          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    ]          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    =          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    &          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    !          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    *          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    -          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    +          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    :          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    (          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    )          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    {          , JAVA_OPERATOR  , -1          , DEFAUT
[OPERATOR]    }          , JAVA_OPERATOR  , -4          , DEFAUT
[OPERATOR]    ?          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    <          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    >          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    |          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    ^          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    %          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    ~          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT
[OPERATOR]    /          , JAVA_OPERATOR  , NO_INDENT   , DEFAUT

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
[SECTION]     /*        ,  */     , JAVA_COMMENT ,         ,DEFAUT
[SECTION]     //        , EOL     , JAVA_COMMENT ,         ,DEFAUT
[SECTION]     "         ,"        , JAVA_STRING  ,\        ,DEFAUT
[SECTION]     '         ,'        , JAVA_NUMERIC ,\        ,DEFAUT
