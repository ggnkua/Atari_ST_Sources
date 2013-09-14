/* PORTS.H
 *==========================================================================
 * Prototypes, defines and externs for ports.c
 */
 
/* DEFINES
 *==========================================================================
 */
 
 
/* PROTOTYPES
 *==========================================================================
 */
void	Write_Port( int cur_port, BUFFER *store );
void	Read_Port( int cur_port, BUFFER *store );
void	Set_Rsconf( int cur_port );

/* EXTERNS
 *==========================================================================
 */
