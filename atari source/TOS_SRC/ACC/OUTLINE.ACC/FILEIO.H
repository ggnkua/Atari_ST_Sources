/* fileio.h - i/o routines for extend.sys parser
 * 900814 kbad
 */

#define LINE_MAX 128

void	xopen( char *name );
char	*xgets( char *buf );
void	xclose( void );
