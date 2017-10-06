/* M.R's kludgy atof --- 881 version.		*/
/* 	uses long integer accumulators and extended precision to put them	*/
/*	together in the fpu. The conversion long to extended is done completely	*/
/*	on the 881.	*/

/* 12.7.1989, 11.10.90, 28.1.91 */
/* On overflow, only +-infinity is returned (the 68881's default),	  */

#include <ctype.h>
#include <stdio.h>
#include <math.h>
#include <errno.h>

#define	true 1
#define false 0
#define CharIsDigit ( isdigit(*Text) )
#define Digit ((*Text-'0'))

double atof( const char * );
double exp10( double );
double strtod( const char *, const char ** );
double _Float_( long, long, long, long );

#if 0
static unsigned long
	__notanumber[2] = { 0x7fffffffL, 0xffffffffL }; /* ieee NAN */
#define NAN  (*((double *)&__notanumber[0]))
#endif 0

#define ten_mul(X)	((((X) << 2) + (X)) << 1)

double strtod( const char * Save, const char ** Endptr )
{
  register int Count; int Negative = false, ExpNegative = false;

  double Value;
  register long Exponent, Exp_Temp;
  register long Value_1, Value_2;
  register char c;
  register char * Text;
  register char * Places;
  char Buffer[15];

  Text = Save;
  Places = Buffer;

  /* skip over leading whitespace */
  while (isspace(*Text)) Text++;

  if (*Text == '-') {
	Negative = true;
	Text++;
  } else
  if (*Text == '+') {
	Negative = false;
	Text++;
  } else
  if( *Text == 0 ) {
	if( Endptr != NULL ) *Endptr = Text;
	return 0.0;
  }

  /* Process the 'f'-part */
  /* ignore any digit beyond the 15th */

  Exp_Temp = 0;	/* needed later on for the exponential part	*/
  Value_1 = 0; Value_2 = 0; Count = 0; Exponent = 0;
  while( CharIsDigit ) {	/* process digits before '.' */
    if( Count < 15 ) {
      Count++;
	  *Places++ = Digit;
	}
	Text++;
  }
  if ( *Text == '.') {
	Text++;
	while( CharIsDigit ) {	/* process digits after '.' */
	  if( Count < 15 )	{
		Count++;
	        *Places++ = Digit;
		Exponent--;
	  }
	  Text++;
	}
  }
  Places = Buffer;

  /* Now, Places points to a vector of <= 15 integer numbers				*/
  /* text points to the position immediately after the end of the mantissa	*/
  /* Value_2 will contain the equiv. of the 8 least significant digits, while			*/
  /* Value_1 will contain the equiv. of the 7 most significant digits (if any)		*/
  /* and therefore has to be multiplied by 10^8						*/

  while( Count > 8 )	{
	  Value_1 = ten_mul( Value_1 );	  Value_1 += *Places++;
	  Count--;
  }
  while( Count > 0 )	{
	  Value_2 = ten_mul( Value_2 );	  Value_2 += *Places++;
	  Count--;
  }

  /* 'e'-Part */
  if ( *Text == 'e' || *Text == 'E' || *Text == 'd' || *Text == 'D' ) {

	char * Tail = Text;
	Text++;

	/* skip over whitespace since ansi allows space after e|E|d|D */
	while (isspace(*Text)) Text++;

	if ( * Text == '-' ) {
		ExpNegative = true;
		Text++;
	} else
	if( * Text == '+' ) {
		ExpNegative = false;
		Text++;
	}
	if( !CharIsDigit ) {
		*Endptr = Tail;	/* take the 'e|E|d|D' as part of the characters	*/
		goto Ende;		/* following the number */
	} else {
	/* Exponents may have at most 3 digits, everything beyond this is
	   ignored */
		Count = 0;
		while( CharIsDigit && (Count < 3) ) {
			Exp_Temp = ten_mul( Exp_Temp ); Exp_Temp += Digit;
	  		Count++;
			Text++;
		}
		if( ExpNegative ) Exp_Temp = -Exp_Temp;
		Exponent += Exp_Temp;
 	}
  }
  Value = _Float_( Value_1, Exponent+8L, Value_2, Exponent );
  if( Endptr != NULL ) *Endptr = Text;

Ende:
  if( Negative ) {
	Value = -Value;
  }
  return( Value );
#if 0
Error:
  fputs("\njunk number \"",stderr); fputs(Save,stderr);
  fputs("\" --- returning NAN\n",stderr);
  errno = ERANGE;
  if( Endptr != NULL ) *Endptr = Text;
  return(NAN);	/* == Not A Number (NAN) */
#endif
}

double atof( const char * Text )
{
	return(strtod(Text,(char **)NULL));
}
