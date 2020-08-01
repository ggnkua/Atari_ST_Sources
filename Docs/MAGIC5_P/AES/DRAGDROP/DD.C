Achtung:

args[-1] muž 0 sein!

void	do_args( BYTE *args )
{
	BYTE	*path;
	WORD	len;
		
	len = (WORD) strlen( args );
	path = args;
	
	while ( len >= 0 )
	{
		BYTE	b;
	
		b = *args++;

		if ( b == ' ' )													/* Leerzeichen */
		{
			if ( *(args - 2) == 0 )										/* mehrere Leerzeichen hintereinander? */
				path++;
			else
				b = 0;
		}
		else if ( b == '\'' && ( path == args - 1 ))				/* Hochkomma? */
		{
			path++;
			
			while (( b = *args++ ) != 0 )
			{
				len--;
				
				if ( b == '\'' )											/* Hochkomma? */
				{
					if ( *args == '\'' )									/* folgt darauf noch ein Hochkomma? */
					{
						memcpy( path + 1, path, args - path - 1 );	/* Bereich verschieben */
						path++;
						args++;
						len--;
					}
					else
					{
						b = 0;
						break;
					}
				}
			}
		}
		
		if (( b == 0 ) && ( path < ( args - 1 )))					/* String-Ende gefunden? */
		{
			*( args - 1 ) = 0;
			

			path = args;													/* Anfang des n„chsten Strings */
		}
		len--;
	}
}
