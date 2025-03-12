#define		MaxPoint	25


typedef enum
{
    FALSE,
    TRUE
}
boolean;


typedef struct
{
	int o[MaxPoint], u[MaxPoint];		/* untere/obere Diagonale */
	int m[MaxPoint];								/* Hauptdiagonale         */
	int l[MaxPoint];								/* InhomogenitÑt          */
} TriGlSys;

typedef struct											/* Record fÅr Splines         */
{
	unsigned int	a, b, c, d;									/* Koeffizienten des Polynoms */
	unsigned int	XStart, XEnde;							/* Definitionsbereich         */
} spline;


typedef struct
{
	int	x;
	int	y;
}point;

typedef point Points[MaxPoint];			/* Punkte */

void MakeSplines(Points pts, unsigned int NoPts,
								 spline *splA, spline *splB,
								 unsigned int ysa, unsigned int ysb);
									
void DrawSplines (int dev, 
									spline splX[], spline splY[],
									unsigned int No);
