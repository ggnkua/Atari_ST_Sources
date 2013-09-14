/* KEYBELL.H
 *==========================================================================
 * Prototypes and external variables from KEYBELL.C
 */
 
 
 
 /* DEFINES
  *=========================================================================
  */

 /* PROTOTYPES
  *=========================================================================
  */
void	Set_Keybell( void );
void	Get_Keybell( void );
void	Keybell_Update( void );
long	get_noise( void );
long	set_noise( void );
void	keybell_handle( int base, int *var );
void	Kbell_Redraw( void );


  
 /* EXTERNS
  *=========================================================================
  */
