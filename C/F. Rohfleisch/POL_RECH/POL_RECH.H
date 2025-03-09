/**************************************************************************
						    I N C L U D E F I L E
						fuer Pol_rech.C und Funktran.C          
 -------------------------------------------------------------------------
 Autor: F.Rohfleisch, 7140 Ludwigsburg                       Oktober 1989    
**************************************************************************/

/*************************************************************************/
#define    FUNK_LANG_MAX            81  /* max. Laenge des Formelstrings */
#define    BUFFER_MAX               81  /* max. Pufferanzahl             */
#define    KLAMMER_MAX              20  /* max. Klammerebenen            */
#define    STACK_MAX                20  /* max. Stackgr”sse              */
      

/*************************** KONSTANTEN **********************************/
#define    PI1                      3.141592654   /* PI   */
#define    NPI                     -3.141592654   /* -PI  */
#define    PI2                      1.570796327   /* Pi/2 */ 

/********************* Return-Werte von next_op **************************/
#define    NUMBER                  '9'
#define    FUNKTION                '8'
#define    VARIABLE                '7' 
#define    NEG_PI                  '6' 
#define    ENDE                   '\0'


/************************** FUNKTIONEN ***********************************/
#define    SIN                    234
#define    COS							 229
#define    TAN							 227
#define    SQRT						 330
#define    EXP							 237
#define    LN							 154
#define    ABS							 214
#define    PI                     153 


/************************* FEHLERCODES ***********************************/
#define    KLAMMERFEHLER            1
#define    POS_UNENDLICH 		      2
#define    NEG_UNENDLICH    		   3  
#define    NEG_WURZEL               4
#define    NEG_BASIS        		   5
#define    NEG_LOG                  6

#define    NULL_DIVISION            9
 
#define    STACK_VOLL     			   10
#define    STACK_LEER     			   11
#define    UNBEKANNTE_FUNKTION      12
#define    UNBEKANNTER_OPERATOR     13 
#define    UNBEKANNTE_VARIABLE      14 
#define    NOTAT_FEHLER             15
#define    KLAMMER_VOLL             16
#define    BUFFER_VOLL              17
