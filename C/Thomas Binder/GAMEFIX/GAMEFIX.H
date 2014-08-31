/***********************************************/
/* Modulname      : GAMEFIX.H                  */
/* Autor          : Thomas Binder              */
/* Zweck          : Headerdatei fÅr GAMEFIX.C, */
/*                  MINI1.C und MINI2.C. Ent-  */
/*                  hÑlt Konstanten und die    */
/*                  externen Variablen von     */
/*                  ASSEM.S                    */
/* Compiler       : Pure C 1.0                 */
/* Erstellt am    : 28.08.1993                 */
/* Letzte énderung: 03.09.1993                 */
/***********************************************/


/* Konstanten (Offsets fÅr settings-Feld) */

#define _DATACACHE  0
#define _INSTCACHE  1
#define _BLIT8MHZ   2
#define _CPU8MHZ    3
#define _BUSMODE    4
#define _TIMERA     5
#define _MFPI7      6
#define _SPEAKER    7
#define _SCRBASE    8
#define _VOLUME     9
#define _RAMCONFIG  10


/* Variablen aus ASSEM.S */

extern WORD mpack[];
extern WORD _gemdos[];
extern WORD settings[];
extern WORD checksum;
extern ULONG ramsizes[];
extern WORD *gdrout;
extern ULONG rootpointer[];
extern ULONG new_pmmu_tree[];

/* Modulende */
