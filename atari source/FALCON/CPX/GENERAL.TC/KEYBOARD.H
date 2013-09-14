/* KEYBOARD.H
 *==========================================================================
 * Prototypes and external variables from KEYBOARD.C
 */
 
 
 
 /* DEFINES
  *=========================================================================
  */
/* Keyboard response and repeat rate max and min */
#define KEYMAX 50
#define KEYMIN 1


 /* PROTOTYPES
  *=========================================================================
  */
void	Set_Kbrate( void );
void	Get_Kbrate( void );
void	Kbrate_Update( void );
void	Kb_itoa( int n, char *s );
void	Kbrate_Redraw( void );

void	KRepeat( void );
void	KResponse( void );
  
 /* EXTERNS
  *=========================================================================
  */
