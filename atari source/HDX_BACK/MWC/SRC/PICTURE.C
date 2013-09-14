/*
 * The picture() function is designed to give C users the same
 * numeric formatting ability as COBOL and BASIC users. 
 *
 * When compiled with -DTEST picture.c builds its own test stream.
 * The various options of picture() are illustrated by the test stream
 * in main().
 * Who says self documenting programs are a myth?
 */
#include "stdio.h"
#include "math.h"
extern char *index();
static int dmod10();

/* This routine emulates the COBOL picture clause for C programs.
 * picture ( dble, format, output )
 * The dble is the number to be formated.
 * format is a COBOL style picture string
 * 	Z stands for zero suppression spaces which
 *	  either show numbers or spaces.
 *	9 stands for digit space
 *	$ is a floating dollar sign which lands before the 
 *	  first displayed digit.
 *	( is a floating left paren whic lands before the
 *	  first displayed digit if the number is minus.
 *	* signifys * fill and replaces any lead spaces.
 *	anything else within the number is displayed if
 *	the number is already signifigant.
 *	+ trailing is displayed if the number is positive
 *	  and replaced with a - if the number is minus.
 *	anything else behind the ones position is
 *	only displayed if the number is minus.
 *  output is the output string and will be exactly as long as
 *  format.
 *  picture returns a double which is the undisplayable overfolwed
 *  value. 
 *  	picture(12345, "Z,ZZZ", output );
 *		places 2,345 in output and returns a 1.
 */

/*
 * Format double precision number. Return any overflow.
 */
double
picture (dble, format, output )
double dble;	/* the number to format */
char  *format;	/* the format mask */
char  *output;	/* the output area. Must be at least as large as format */
{
	register int i, plus = 1;
	register char *outp, tmp;
	double numb = dble;
	char *sig, *j;

	if (dble < 0.0) {
		numb = -dble;
		plus = 0;
	} 

	if (outp = index(format, '.'))	/* if . in format adjust number */
		for(; *outp != '\000'; outp++)
			switch ( *outp ) {
				case '9' :
				case 'Z' :
				case 'J' :
				case 'K' :
				case 'S' :
				case 'T' :
					numb *= 10.0;
			}
	modf(numb + 0.5, &numb);	/* round number */
	 /* scan backward for slot */
	for(i = strlen(format), output[i--] = '\000'; i >= 0; i--) {
		outp = &output[i];
		switch ( tmp=format[i] ) {
			case '+' :
				*outp = plus ? '+' : '-';
				continue;
			case 'T' :
			case 'S' :
			case 'J' :
			case 'K' :
			case '9' :
			case 'Z' :
				break;
			default:
				*outp = plus ? ' ' : tmp;
				continue;
		} /* switch */
		break;
	} /* for */

	/* build output string */
	for (sig = output - 1; i >= 0; i--) {
		outp = &output[i];
		switch ( tmp=format[i] ) {
			case '9' :	/* slot for number */
				*outp = dmod10(&numb);
				sig = outp - 1;
				break;
			case 'Z' :	/* lead zero suppress */
				if (numb >= 1.0) {
					*outp = dmod10(&numb);
					sig = outp - 1;
				}
				else
					*outp = ' ';
				break;
			case 'J' :	/* lead zero shirnk */
				if (numb >= 1.0) {
					*outp = dmod10(&numb);
					sig = outp - 1;
				}
				else {
					sig--;
					strcpy(outp, (outp + 1));
				}
				break;
			case 'K' :	/* all zero shrink */
				*outp = dmod10(&numb);
				if ( *outp == '0' ) {
					sig--;
					strcpy(outp, (outp + 1));
				}
				else
					sig = outp - 1;
				break;
			case 'T' :	/* suppress trailing zeros */
				*outp = dmod10(&numb);
				if(*outp != '0' || sig >= output )
					sig = outp - 1;
				else
					*outp = ' ';
				break;
			case 'S' :	/* shrink trailing zeros */
				*outp = dmod10(&numb);
				if(*outp != '0' || sig >= output )
					sig = outp - 1;
				else
					strcpy(outp, (outp + 1));
				break;
			case '$' :	/* floating $ */
				*outp = ' ';
				if (sig >= output)
					*sig-- = '$';
				break;
			case '-' :	/* floating lead - */
			case '(' :	/* floating lead ( */
				*outp = ' ';
				if (sig >= output && !plus )
					*sig-- = tmp;
				break;
			case '+' :	/* floating lead + or - */
				*outp = ' ';
				if (sig >= output)
					*sig-- = plus ? '+' : '-';
				break;
			case '*' :	/* * fill */
				*outp = '*';
				for (j = outp+1; *j == ' ';)
					*j++ = '*';
				break;
			case '.' :	/* decimal point */
				*outp = '.';
				break;
			default :
				*outp = (numb >= 1.0) ? tmp: ' ';
		}	/* switch */
	}	/* for */
	modf(numb, &numb);
	return (numb >= 1.0) ? (plus ? numb : -numb) : 0.0;
}

/*
 * return low order decimal number of argument.
 * divide argument by 10.
 */
static int
dmod10(numb)
register double *numb;
{
	return((int)((modf(*numb / 10.0, numb) * 10.0) + 48.5));
}

#ifdef TEST
static int    test_no;

/*
 * Run picture and check the results.
 */
verify(mask, number, expect, oflow, descr)
char *mask;	/* format mask for picturre */
double number;	/* number to format */
char *expect;	/* expected result of format */
double oflow;	/* expected overflow */
char *descr;	/* description */
{
	char   result[20];
	double ret;

	test_no++;
	if(descr != NULL)
		printf("\n%s\n", descr);
	printf("%10.3f passed through a mask of '%s' gives '%s'\n",
		number, mask, expect);
	if((int)oflow)
		printf("    With an overflow of %-3.1f\n", oflow);
	ret = picture(number, mask, result);
	if((int)(ret - oflow))
		printf("Expected oflow\t%e\ngot\t\t%e\ttest %d\n",
			oflow, ret, test_no);
	if(strcmp(result, expect))
		printf("Expected\t'%s'\ngot\t\t'%s'\ttest %d\n",
			expect, result, test_no);
}

main()
{
   printf("The picture() function is designed to give C users the same\n");
   printf("numeric formatting ability as COBOL and BASIC users. \n\n");
   printf("double\n");
   printf("picture (dble, format, output )\n");
   printf("double dble;    /* the number to format */\n");
   printf("char  *format;  /* the format mask */\n");
   printf("char  *output;  /* the output area. Must be at least as large as format */\n");

	verify("999 CR",	   5.0,	"005   ",	0.0,
	  "9    Provides a slot for a number.");
	verify("999 CR",	  -5.0,	"005 CR",	0.0, NULL);
   printf(" Note: C & R are not special to picture. Trailing non special\n");
   printf("       characters print only if the number is negitave\n");

	verify("ZZZ,ZZZ",	1034.0,	"  1,034",	0.0,
	  "Z    Provides a slot for a number but supresses lead zeros.");
   printf(" Note: comma is not special to picture. Imbeded non special\n");
   printf("       characters print only if preceeded by significant digits\n");
	verify("JJJ,JJJ",	1034.0,	"1,034",	0.0,
	  "J    Provides a slot for a number but shrinks out lead zeros.");

	verify("K9/K9/K9",     70884.0,	"7/8/84",	0.0,
	  "K    Provides a slot for a number but shrinks out any zeros.");

	verify("$ZZZ,ZZZ",	105.0,	"    $105",	0.0,
	   "$    Floats a dollar sign to the front of the displayed number.");

	verify("Z,ZZZ.999",	105.67,	"  105.670",	0.0,
	   ".    Separates the number between decimal and integer portions.");

	verify("Z,ZZ9.9TT",	105.67,	"  105.67 ",	0.0,
	   "T    Provides a slot for a number but supresses trailing zeros.");

	verify("Z,ZZ9.9SS",	105.67,	"  105.67",	0.0,
	   "S    Provides a slot for a number but shrinks out trailing zeros.");

	verify("-Z,ZZZ",	105.0,	"   105",	0.0,
	   "-    Floats a - infront of negitive numbers");
	verify("-Z,ZZZ",       -105.0,	"  -105",	0.0, NULL);

	verify("(ZZZ)",		105.0,	" 105 ",	0.0,
		"(    Acts like - but prints a (");
	verify("(ZZZ)",		 -5.0,	"  (5)",	0.0, NULL);

	verify("+ZZZ",		  5.0,	"  +5",		0.0,
	   "+    Floats a + or - infront of the number depending on its sign");
	verify("+ZZZ",		 -5.0,	"  -5",		0.0, NULL);

	verify("*ZZZ,ZZZ.99",	104.10,	"*****104.10",	0.0,
	   "*    Fills all lead spaces to its right");
	verify("*$ZZZ,ZZZ.99",	104.10,	"*****$104.10",	0.0, NULL);

	verify("(ZZZ)",	      -1234.0,	"(234)",       -1.0,
	   "Any overflow is returned by picture as a double precision number.");
	verify("99",		123.4,	"23",		1.0, NULL);
	verify("ZZ",	       1200.0,	"00",	       12.0, NULL);
}
#endif
