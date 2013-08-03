/********************************************************/
/*							*/
/*	Usual filename:  LGCDEF.H			*/
/*	Put ' #include "lgcdef.h" ' at head of each	*/
/*	   separately compiled module containing	*/
/*	   code added to DDT68K to give SID68K.		*/
/*	Remarks:  General purpose symbol definitions	*/
/*	   for use by C-programmers in Languages.	*/
/*	Author:  Timothy M. Benson			*/
/*	Last modified:  27 January 1983			*/
/*							*/
/********************************************************/

/*  Lower-case and mixed-case */

#define	begin		{
#define	end		}
#define	otherwise	else
#define and		&&
#define	or		||
#define If		if(		/* Note mixed case */
#define then		)

/*  Upper-case */

#define	ADDR		&
#define	AND		&
#define	ANDEQ		&=
#define	ANDWITH		&=
#define	AT		->
#define	BEGIN		{
#define	BLOCK		{
#define CASE		case
#define	COMP		~
#define	DCR		-=
#define	DECBY		-=
#define	DEFAULT		default
#define	DO		do
#define	DOFALSE		:
#define	DOTRUE		?
#define	ELSE		else
#define END		}
#define	EQ		==
#define	FALSE		0
#define	GE		>=
#define	GT		>
#define	IF		if
#define IGNORE		continue
#define	INC		+=
#define	INCBY		+=
#define	LE		<=
#define	LT		<
#define NE		!=
#define	NOT		!
#define OR		|
#define	OREQ		|=
#define	ORWITH		|=
#define	SHL		<<
#define	SHLBY		<<=
#define	SHLR		<<=
#define	SHR		>>
#define	SHRBY		>>=
#define	SHRR		>>=
#define TRUE		1
#define	UNBLOCK		}
#define	VAL		*
#define	WHILE		while
#define XOR		^
#define XORWITH		^=
