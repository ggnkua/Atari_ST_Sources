#include	<mt_mem.h>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"Text.h"

typedef struct	__line__
{
	struct __line__	*next;
	struct __line__	*prev;
	char	*String;
	int	Colour;
}	LINE;

typedef	struct
{
	LINE	*Line;
	LINE	*LastLine;
	long	nLines;
}	TEXT;

void	*TextCreate( void )
{
	TEXT	*Text = malloc( sizeof( TEXT ));
	if( !Text )
		return( NULL );
	Text->Line = NULL;
	Text->LastLine = NULL;
	Text->nLines = 0;
	return( Text );
}
void	TextDelete( void *T )
{
	TEXT	*Text = T;
	LINE	*Line = Text->Line, *Tmp;
	while( Line )
	{
		Tmp = Line->next;
		free( Line->String );
		free( Line );
		Line = Tmp;
	}
	free( Text );
}

int	TextAttachLine( void *T, char *String, int Colour )
{
	TEXT	*Text = T;
	LINE	*New;
	char	*Puf = NULL;

	New = malloc( sizeof( LINE ));
	if( !New )
		return( ENSMEM );
	New->next = 0;
	if( Text->LastLine )
		( Text->LastLine )->next = New;
	New->prev = Text->LastLine;
	Text->LastLine = New;
	if( Text->Line == NULL )
		Text->Line = New;
	Text->nLines++;

	New->Colour = Colour;
	New->String = strdup( String );
	if( !New->String )
		return( ENSMEM );
	return( E_OK );
}

char	*TextGetLine( void *T, long n, int *Colour )
{
	TEXT	*Text = T;
	LINE	*Line = Text->Line;
	long	i = 0;

	if( !Line )
		return( NULL );

	while( n > i )
	{
		Line = Line->next;
		if( !Line )
			break;
		i++;
	}
	if( Line )
	{
		*Colour = Line->Colour;
		return( Line->String );
	}
	else
		return( NULL );
}

long	TextGetnLines( void *T )
{
	TEXT	*Text = T;
	return( Text->nLines );
}

void	TextDeleteLine( void *T, long n )
{
	TEXT	*Text = T;
	LINE	*Line = Text->Line;
	long	i = 0;

	if( !Line )
		return;

	while( n > i )
	{
		Line = Line->next;
		if( !Line )
			break;
		i++;
	}
	if( !Line )
		return;

	if( Line->next )
		( Line->next )->prev = Line->prev;
	else
		Text->LastLine = Line->prev;
	if( Line->prev )
		( Line->prev )->next = Line->next;
	else
		Text->Line = Line->next;

	Text->nLines--;

	free( Line->String );
	free( Line );
}