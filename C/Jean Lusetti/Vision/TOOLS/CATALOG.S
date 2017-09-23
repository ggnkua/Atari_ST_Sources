*
* Routines en assembleur
* Pour la gestion du catalogue
*

    .EXPORT index_record_compare

* Conversion en assembleur de la
* Routine de comparaison de deux index :
* typedef struct
* {
* char     name[8] ;      /* Nom image sans l'extension, ni de z‚ro terminal ! */
* unsigned nbplanes  :3 ; /* Nombre de plans                                   */
* unsigned format    :4 ; /* Format de l'image                                 */
* unsigned is_visible:1 ; /* Doit apparaitre dans la liste ?                   */
*          date_time :8 ; /* Encodage date et heure                            */
* unsigned category_1:5 ; /* Cat‚gorie 1 de l'image                            */ 
* unsigned category_2:5 ; /* Cat‚gorie 2 de l'image                            */ 
* unsigned category_3:5 ; /* Cat‚gorie 3 de l'image                            */ 
*          rfu_2     :1 ; /* Usage futur                                       */
* long     offset ;       /* Offset dans le fichier                            */
* }
* INDEX_RECORD ;
* Equivalences en assembleur
NAME_OFFSET      EQU   0
DATA1_OFFSET     EQU   8
NBPLANES_SIZE    EQU   3
NBPLANES_MASK    EQU   $E000
NBPLANES_RSHIFT  EQU  13
FORMAT_SIZE      EQU   4
FORMAT_MASK      EQU   $1E00
FORMAT_RSHIFT    EQU   9
ISVISIBLE_SIZE   EQU   1
ISVISIBLE_RSHIFT EQU   8
ISVISIBLE_MASK   EQU   $0100
DATETIME_SIZE    EQU   8
DATETIME_RSHIFT  EQU   0


* int index_record_compare(const void *i, const void *j)
* {
* INDEX_RECORD *one, *two ;
* int          result ;

* one = (INDEX_RECORD *) i ;
* two = (INDEX_RECORD *) j ;

* result = two->is_visible - one->is_visible ;
* if ( result != 0 ) return( result ) ;

* result = memcmp( one->name, two->name, 8 ) ;
* if ( result != 0 ) return( result ) ;

* result = one->format - two->format ;
* if ( result != 0 ) return( result ) ;

* result = one->nbplanes - two->nbplanes ;

* return( result ) ;
*}

* int index_record_compare(const void *i, const void *j)
*  D0                             A0            A1
index_record_compare:
*    MOVE.L    D2,-(SP)  ; Sauvegarde du contexte
     MOVEQ.L   #0,D0

*   is_visible
    MOVE.W    DATA1_OFFSET(A0),D1
    ANDI.W    #ISVISIBLE_MASK,D1
    MOVE.W    DATA1_OFFSET(A1),D0
    ANDI.W    #ISVISIBLE_MASK,D0
    SUB.W     D1,D0
    BNE.S     irc_rts

*   name
    CMPM.L   (A1)+,(A0)+
    BNE.S    irc_notequal
    CMPM.L   (A1)+,(A0)+
    BNE.S    irc_notequal

*   format
    MOVE.W    (A0),D1
    ANDI.W    #FORMAT_MASK,D1
    MOVE.W    (A1),D0
    ANDI.W    #FORMAT_MASK,D0
    SUB.W     D1,D0
    BNE.S     irc_rts

*   nbplanes
    MOVE.W    (A0),D1
    ANDI.W    #NBPLANES_MASK,D1
    MOVE.W    (A1),D0
    ANDI.W    #NBPLANES_MASK,D0
    SUB.W     D1,D0
    BEQ.S     irc_rts

irc_notequal:
    BHI.S     irc_set1
    MOVEQ.L   #-1,D0
*    MOVE.L    (SP)+,D2  ; Restauration du contexte
    RTS                 ; Retour au programme C

irc_set1:
    MOVEQ.L   #1,D0
irc_rts:
*    MOVE.L   (SP)+,D2  ; Restauration du contexte
    RTS                ; Retour au programme C
