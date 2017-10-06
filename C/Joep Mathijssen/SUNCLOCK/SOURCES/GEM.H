#ifndef Gem_first
#define Gem_first


/*---- Defines ----*/
#define TRUE    (1==1)
#define FALSE   (1!=1)

/*---- Typedefs ----*/
typedef char bool;

/*---- Enumerations ----*/
/* resolution from GetRez() */
typedef enum { cLowRez, cMedRez, cHighRez } eGetRez;

/* index for txt_attrib */
typedef enum {  cTaSet, cTaColor, cTaRot,
                cTaHor, cTaVer, cTaMode,
                cTaLWidth, cTaLHeight, cTaBWidth,
                cTaBHeight }    eTxtAttrib;

/*---- General GEM-variables ----*/
extern int handle,
           work_out[57],
           work_in[12],
           pxyarray[10],
           txt_attrib[10];
extern char errorsound[100];

/*---- Prototyping ----*/
void GemInit( eGetRez, char* );
void GemExit( void );
void GemAbort( char* );
void GemSound( void );

#endif Gem_first 
