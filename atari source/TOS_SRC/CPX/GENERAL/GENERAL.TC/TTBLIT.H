/* TTBLIT.H
 *==========================================================================
 * Prototypes and external variables from TTBLIT.C
 */
 
 
 
 /* DEFINES
  *=========================================================================
  */
#define NOSPEED		0
#define BLITTER		1
#define TTCACHE		2
 

 /* PROTOTYPES
  *=========================================================================
  */
void	Init_Speed( void );
void	Set_Speed( void );
void	Get_Speed( void );
void	Do_Speed( void );
void	Speed_Update( void );
void	Speed_Redraw( void );



  
 /* EXTERNS
  *=========================================================================
  */
extern char *chip1_text[];
