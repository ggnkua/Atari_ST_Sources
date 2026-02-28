;---------------------------- FICHIER DE PARAMETRAGE SYNTAXIQUE ---------------------------
;                             pour EZ_EDIT par SEVIN Roland Ω 15/12/2000
; 
; ce fichier doit toujours avoir le nom: KEYWORD et                                        
; l extension determine Ö quel type de fichier il doit s appliquer, exemple si ce fichier
; porte le nom KEYWORD.C tous les fichiers d extension C utiliseront ses paramätres.
; il existe plusieurs types de definitions (entre crochets):
; L exemple suivant est le fichier utilisÇ pour coloriser la syntaxe de l'assembleur 68000
;
; CLASS_GRAP   defini une classe graphique, regroupant les attributs d affichage d un texte
;              il faut lui donner un type identificateur comme premier paramätre. C est ce
;              type qui sera utilisÇ dans les autre definitions, pour y faire reference et
;              determiner l affichage. Le parametre suivant est le nom tel qu il doit etre
;              affichÇ dans la LISTBOX de parametrage, les autres parametres sont les
;              attributs graphiques correspondant.
;              LES DEFINITIONS DES CLASSES GRAPHIQUES DOIVENT TOUJOURS ETRE EN PREMIER
;
; KEY_WORD    defini un mot clef. premier parametre est le nom du mot clef, le deuxiäme la
;             reference Ö la classe graphique permettant de coloriser ce mot clef
;             le troisiäme parametre est l indentation Ö placer Ö la suite de ce mot clef
;             apres appui sur la touche RETURN.
;
; OPERATOR    est pareil que KEY_WORD sauf que le premier parametre doit indiquer sur 1
;             caractäre le caractäre Ö considerer comme un opÇrateur.
;
;
; SECTION     defini les caractäres utilisÇs comme delimiteurs de section. Le premier parametre 
;             defini le delimiteur de debut, le deuxiäme paramätre defini le delimiteur de fin
;             en sachant que EOL comme deuxieme parametre signifie que c est la fin de ligne.
;             Le troisiäme paramätre indique la classe graphique Ö utiliser pour l affichage
;             le quatriäme paramätre est le caractäre d echapement (celui apres lequel un
;             caractäre ne doit pas etre interprete). 
;             si la classe graphique est differente de zero, alors les caractäres placÇs
;             entre les delimiteurs seront colorÇs avec.
; 
; 
; EQUIVALENT  designe le fichier qui devra etre utilisÇ comme fichier de definition Ö la place
;             de celui-ci (cela permet de ne definir qu un seul fichier pour plusieurs types)
;             exemple je definis un fichier KEYWORD.C pour la syntaxe colorÇe du C
;             le fichier KEYWORD.H   aura comme simple texte: [EQUIVALENT] KEYWORD.C
;             afin que les fichier .H se servent du fichier KEYWORD.C pour afficher leur syntaxe
; 

;..........................................................................................
; type de    | type de la       | nom de la classe | couleur | effet  | taille | police
; definition | classe graphique | qui sera affiche | carac-  | carac- | carac- | carac- 
;            |                  | dans la LISTBOX  | täre    | täre   | täre   | täre
;            |                  | de parametrage   |         |        |        |
;..........................................................................................

[CLASS_GRAP] ATT_TXT_DEFAULT,    Texte normal         ,   1,        0,        9,      Monaco Mono
[CLASS_GRAP] TYPVAR,             Typage variable      ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] MEMORYMOVE,         Mouvements memoire   ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] ROTATION  ,         Rotation             ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] BRANCHEMENT,        Branchements         ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] TEST_CLASS,         Tests                ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] ARITMETIC,          Arithmetique         ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] OPERATOR,           OpÇrateurs           ,   2,        0,        9,      Monaco Mono
[CLASS_GRAP] DELIMITEURS,        DÇlimiteurs          ,  10,        0,        9,      Monaco Mono
[CLASS_GRAP] BRANCHTRAP,         branchement trap     ,   4,        0,        9,      Monaco Mono
[CLASS_GRAP] NUMERIC,            valeur numeriques    ,  13,        0,        9,      Monaco Mono
[CLASS_GRAP] COMMENTAIRES,       Commentaires         ,  11,        0,        9,      Monaco Mono
[CLASS_GRAP] ADRESS_REG,         Registres d'adresses ,  15,        0,        9,      Monaco Mono
[CLASS_GRAP] DATA_REG,           Registres de donnÇes ,  15,        0,        9,      Monaco Mono
[CLASS_GRAP] END_OF_FUNC,        Retour de routines   ,   4,        0,        9,      Monaco Mono



;........................... tableau de mots clefs ....................
;             
; type de    | nom du   | Reference de la  | Indentation  Ö mettre
; definition | mot clef | classe graphique | en place sous ce mot
;            |          | Ö utiliser       | clef
;            |          | pour affichage   |
;......................................................................

;ππππππππππππππππππππππππππ branchement ππππππππππππππππππππππππππ
[KEY_WORD]    BGT      , BRANCHEMENT , 0           ;/* 20 - 6  */
[KEY_WORD]    bgt      , BRANCHEMENT , 0           ;/* 21 - 8  */
[KEY_WORD]    BLE      , BRANCHEMENT , 0           ;/* 22 - 6  */
[KEY_WORD]    ble      , BRANCHEMENT , 0           ;/* 23 - 5  */
[KEY_WORD]    BNE      , BRANCHEMENT , 0           ;/* 12 - 7  */
[KEY_WORD]    bne      , BRANCHEMENT , 0           ;/* 13 - 6  */
[KEY_WORD]    BEQ      , BRANCHEMENT , 0           ;/* 14 - 5  */
[KEY_WORD]    beq      , BRANCHEMENT , 0           ;/* 15 - 5  */
[KEY_WORD]    BRA      , BRANCHEMENT , 0           ;/* 16 - 5  */
[KEY_WORD]    bra      , BRANCHEMENT , 0           ;/* 17 - 6  */
[KEY_WORD]    BPL      , BRANCHEMENT , 0           ;/* 44 - 5  */
[KEY_WORD]    bpl      , BRANCHEMENT , 0           ;/* 45 - 7  */
[KEY_WORD]    DBEQ     , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    dbeq     , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    DBRA     , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    dbra     , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    JSR      , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    jsr      , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    BLS      , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    bls      , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    BCC      , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    bcc      , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    BMI      , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    bmi      , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    BCS      , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    bcs      , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    BGE      , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    bge      , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    DBF      , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    dbf      , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    BSR      , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    bsr      , BRANCHEMENT , 0           ;/* 51 - 6  */
[KEY_WORD]    BLT      , BRANCHEMENT , 0           ;/* 50 - 6  */
[KEY_WORD]    blt      , BRANCHEMENT , 0           ;/* 51 - 6  */

;πππππππππππππππππππππππππππ fin de routine ππππππππππππππππππππππππππ
[KEY_WORD]    RTS      , END_OF_FUNC , 0           ;/* 50 - 6  */
[KEY_WORD]    rts      , END_OF_FUNC , 0           ;/* 51 - 6  */
[KEY_WORD]    RTE      , END_OF_FUNC , 0           ;/* 50 - 6  */
[KEY_WORD]    rte      , END_OF_FUNC , 0           ;/* 51 - 6  */
;πππππππππππππππππππππππππππ mots clefs ππππππππππππππππππππππππππ
[KEY_WORD]    MOVE     , MEMORYMOVE  , 0           ;/* 26 - 6  */
[KEY_WORD]    move     , MEMORYMOVE  , 0           ;/* 27 - 2  */
[KEY_WORD]    MOVEQ    , MEMORYMOVE  , 0           ;/* 28 - 4  */
[KEY_WORD]    moveq    , MEMORYMOVE  , 0           ;/* 29 - 6  */
[KEY_WORD]    MOVEM    , MEMORYMOVE  , 0           ;/* 30 - 4  */
[KEY_WORD]    movem    , MEMORYMOVE  , 0           ;/* 31 - 5  */
[KEY_WORD]    LEA      , MEMORYMOVE  , 0           ;/* 32 - 8  */
[KEY_WORD]    lea      , MEMORYMOVE  , 0           ;/* 33 - 7  */
[KEY_WORD]    MOVEA    , MEMORYMOVE  , 0           ;/* 34 - 2  */
[KEY_WORD]    movea    , MEMORYMOVE  , 0           ;/* 35 - 3  */
[KEY_WORD]    DS       , MEMORYMOVE  , 0           ;/* 34 - 2  */
[KEY_WORD]    ds       , MEMORYMOVE  , 0           ;/* 35 - 3  */
[KEY_WORD]    DC       , MEMORYMOVE  , 0           ;/* 34 - 2  */
[KEY_WORD]    dc       , MEMORYMOVE  , 0           ;/* 35 - 3  */
[KEY_WORD]    SWAP     , MEMORYMOVE  , 0           ;/* 34 - 2  */
[KEY_WORD]    swap     , MEMORYMOVE  , 0           ;/* 35 - 3  */
;πππππππππππππππππππππππππ calcul πππππππππππππππππππππππππππππππππ
[KEY_WORD]    SUBI     , ARITMETIC  , 0           ;/* 10 - 8  */
[KEY_WORD]    subi     , ARITMETIC  , 0           ;/* 10 - 8  */
[KEY_WORD]    SUB      , ARITMETIC  , 0           ;/* 10 - 8  */
[KEY_WORD]    sub      , ARITMETIC  , 0           ;/* 10 - 8  */
[KEY_WORD]    SUBQ     , ARITMETIC  , 0           ;/* 10 - 8  */
[KEY_WORD]    subq     , ARITMETIC  , 0           ;/* 10 - 8  */
[KEY_WORD]    SUBA     , ARITMETIC  , 0           ;/* 10 - 8  */
[KEY_WORD]    suba     , ARITMETIC  , 0           ;/* 10 - 8  */

[KEY_WORD]    add      , ARITMETIC  , 0           ;/* 10 - 8  */
[KEY_WORD]    ADD      , ARITMETIC  , 0           ;/* 11 - 7  */
[KEY_WORD]    adda     , ARITMETIC  , 0           ;/* 10 - 8  */
[KEY_WORD]    ADDA     , ARITMETIC  , 0           ;/* 11 - 7  */
[KEY_WORD]    BCLR     , ARITMETIC  , 0           ;/* 18 - 5  */
[KEY_WORD]    bclr     , ARITMETIC  , 0           ;/* 19 - 4  */
[KEY_WORD]    ADDQ     , ARITMETIC  , 0           ;/* 24 - 5  */
[KEY_WORD]    addq     , ARITMETIC  , 0           ;/* 25 - 5  */
[KEY_WORD]    CLR      , ARITMETIC  , 0           ;/* 36 - 4  */
[KEY_WORD]    clr      , ARITMETIC  , 0           ;/* 37 - 5  */
[KEY_WORD]    NEG      , ARITMETIC  , 0           ;/* 46 - 7  */
[KEY_WORD]    neg      , ARITMETIC  , 0           ;/* 47 - 6  */
[KEY_WORD]    EXT      , ARITMETIC  , 0           ;/* 48 - 9  */
[KEY_WORD]    ext      , ARITMETIC  , 0           ;/* 49 - 3  */
[KEY_WORD]    ADDX     , ARITMETIC  , 0           ;/* 42 - 7  */
[KEY_WORD]    addx     , ARITMETIC  , 0           ;/* 43 - 4  */
[KEY_WORD]    MULU     , ARITMETIC  , 0           ;/* 54 - 3  */
[KEY_WORD]    mulu     , ARITMETIC  , 0           ;/* 55 - 5  */
[KEY_WORD]    MULS     , ARITMETIC  , 0           ;/* 54 - 3  */
[KEY_WORD]    muls     , ARITMETIC  , 0           ;/* 55 - 5  */
[KEY_WORD]    DIVUL    , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    divul    , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    DIVU     , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    divu     , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    DIVSL    , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    divsl    , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    DIVS     , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    divs     , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    AND      , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    and      , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    ANDI     , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    andi     , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    BSET     , ARITMETIC  , 0           ;/* 56 - 5  */
[KEY_WORD]    bset     , ARITMETIC  , 0           ;/* 56 - 5  */
;πππππππππππππππππππππππππ Trape πππππππππππππππππππππππππππππππππ
[KEY_WORD]    TRAP     , BRANCHTRAP  , 0           ;/* 38 - 6  */
[KEY_WORD]    trap     , BRANCHTRAP  , 0           ;/* 39 - 6  */
;πππππππππππππππππππππππππ test πππππππππππππππππππππππππππππππππ
[KEY_WORD]    TST      , TEST_CLASS  , 3           ;/* 40 - 6  */
[KEY_WORD]    tst      , TEST_CLASS  , 0           ;/* 41 - 5  */
[KEY_WORD]    CMP      , TEST_CLASS  , 0           ;/* 56 - 5  */
[KEY_WORD]    cmp      , TEST_CLASS  , 0           ;/* 56 - 5  */
[KEY_WORD]    CMPA     , TEST_CLASS  , 0           ;/* 56 - 5  */
[KEY_WORD]    cmpa     , TEST_CLASS  , 0           ;/* 56 - 5  */
[KEY_WORD]    CMPI     , TEST_CLASS  , 0           ;/* 56 - 5  */
[KEY_WORD]    cmpi     , TEST_CLASS  , 0           ;/* 56 - 5  */
[KEY_WORD]    BTST     , TEST_CLASS  , 0           ;/* 56 - 5  */
[KEY_WORD]    btst     , TEST_CLASS  , 0           ;/* 56 - 5  */

;πππππππππππππππππππππππππ rotation ππππππππππππππππππππππππππππ
[KEY_WORD]    ROXR     , ROTATION  , 0           ;/* 52 - 4  */
[KEY_WORD]    roxr     , ROTATION  , 0           ;/* 53 - 8  */
[KEY_WORD]    ROXL     , ROTATION  , 0           ;/* 54 - 3  */
[KEY_WORD]    roxl     , ROTATION  , 0           ;/* 55 - 5  */
[KEY_WORD]    ROR      , ROTATION  , 0           ;/* 55 - 5  */
[KEY_WORD]    ror      , ROTATION  , 0           ;/* 56 - 5  */
[KEY_WORD]    ROL      , ROTATION  , 0           ;/* 51 - 6  */
[KEY_WORD]    rol      , ROTATION  , 0           ;/* 52 - 4  */
[KEY_WORD]    LSL      , ROTATION  , 0           ;/* 53 - 8  */
[KEY_WORD]    lsl      , ROTATION  , 0           ;/* 54 - 3  */
[KEY_WORD]    LSR      , ROTATION  , 0           ;/* 56 - 5  */
[KEY_WORD]    lsr      , ROTATION  , 0           ;/* 51 - 6  */
[KEY_WORD]    ASR      , ROTATION  , 0           ;/* 52 - 4  */
[KEY_WORD]    asr      , ROTATION  , 0           ;/* 53 - 8  */
;ππππππππππππππππππππππππππtype variables ππππππππππππππππππππππ
[KEY_WORD]    L      , TYPVAR  , 0           ;/* 53 - 8  */
[KEY_WORD]    l      , TYPVAR  , 0           ;/* 53 - 8  */
[KEY_WORD]    W      , TYPVAR  , 0           ;/* 53 - 8  */
[KEY_WORD]    w      , TYPVAR  , 0           ;/* 53 - 8  */
[KEY_WORD]    B      , TYPVAR  , 0           ;/* 53 - 8  */
[KEY_WORD]    b      , TYPVAR  , 0           ;/* 53 - 8  */
;ππππππππππππππππππππππππππregistres πππππππππππππππππππππππππππ
[KEY_WORD]    A0      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    A1      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    A2      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    A3      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    A4      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    A5      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    A6      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    A7      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    SP      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    a0      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    a1      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    a2      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    a3      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    a4      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    a5      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    a6      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    a7      , ADRESS_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    sp      , ADRESS_REG  , 0           ;/* 53 - 8  */

[KEY_WORD]    D0      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    D1      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    D2      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    D3      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    D4      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    D5      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    D6      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    D7      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    d0      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    d1      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    d2      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    d3      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    d4      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    d5      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    d6      , DATA_REG  , 0           ;/* 53 - 8  */
[KEY_WORD]    d7      , DATA_REG  , 0           ;/* 53 - 8  */

;.............. caractäres Ö reconnaitre comme opÇrateurs ...................
;             
; type de    | nom du   | classe         | Indentation 
; definition | mot clef | graphique      |             
;............................................................................

;ππππππππππππππππππππππππ delimiteurs πππππππππππππππππππππππππππππππππππππππ

;[OPERATOR]    [        , DELIMITEURS         , 0
;[OPERATOR]    ]        , DELIMITEURS         , 0
[OPERATOR]    (         , DELIMITEURS         , 0
[OPERATOR]    )         , DELIMITEURS         , 0

;ππππππππππππππππππππππππ operateurs ππππππππππππππππππππππππππππππππππππππππ
[OPERATOR]    -         , OPERATOR            , 0
[OPERATOR]    +         , OPERATOR            , 0
[OPERATOR]    :         , OPERATOR            , 0
[OPERATOR]    #         , OPERATOR            , 0
[OPERATOR]    $         , OPERATOR            , 0


;........... delimiteurs de debut et fin de section .........................
;            un double click marque le debut et fin
;             
; type de    | Premier    | deuxiäme   | classe           | chaine des
; definition | dÇlimiteur | dÇlimiteur | graphique        | escapes
;............................................................................
[SECTION]     POINTVIRG   ,  EOL        , COMMENTAIRES   ,0
[SECTION]     *           ,  EOL        , COMMENTAIRES   ,0
[SECTION]     '           ,'            , NUMERIC   ,

