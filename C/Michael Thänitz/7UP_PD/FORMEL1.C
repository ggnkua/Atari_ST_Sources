/* Auswertung von AusdrÅcken */
/* Output from p2c, the Pascal-to-C translator */
/* From input file "formel1.pas" */

#include <portab.h>
#include <stdio.h>
#include <string.h>

unsigned short var_anz = 0;

#define max_var_anz 10
#define var_anz 0   /*aktuelle Anzahl der Variablen*/

typedef struct
{
	char var_name[11] ;
	double var_wert;
}var_typ;

var_typ var_liste[max_var_anz];

char *ohne_blanks(char *s)
{ /*Alle Blanks eines Strings lîschen*/
	char *p;
	p = strchr(s, ' ');
	while (p != 0L)
	{
		strcpy(p, &p[1]);
		p = strchr(s, ' ');
	}
	return s;
}

int var_vorhanden(char *var_name, double *var_wert, char *var_nr)
{
	int vorh;
	
	vorh = FALSE;
	*var_nr = 0;
	while (!vorh && *var_nr < var_anz) 
	{
		(*var_nr)++;
		if (ohne_blanks(var_liste[*var_nr - 1].var_name) == ohne_blanks(var_name)) 
		{
			*var_wert = var_liste[*var_nr - 1].var_wert;
			vorh = TRUE;
		}
	}
	return vorh;
}

#define maxkli          30   /*Anzahl Klammerebenen*/

typedef enum 
{
	start, 
	variable, 
	variende, 
	konstante, 
	konstende, 
	operator1, 
	operator2,
	vorzeichen, 
	klauf1, 
	klauf2, 
	klzu1, 
	klzu2, 
	fehler, 
	ende
} zust_typ;

typedef struct klreg_typ 
{
	double reg1, reg2;
	char op1, op2;
	int vorz;
	char anz;
} klreg_typ;


/* Local variables for entwicklung: */
struct LOC_entwicklung 
{
	char ausdruck[256];
	double unter_grenze, ober_grenze, *ergebnis;
	int *fcode;
	zust_typ zust;
	double xreg, yreg, zreg;
	char kli, opanz;
	klreg_typ klreg[maxkli];
	char op[3];
	char konst_str[256];   /*String fÅr Konstante*/
	char var_name[11];
	double var_wert;
	char var_nr, st_index, akt_pos;
	int vorz;
	short code;
	int fertig;
} ;

static void op2_auf_op1(struct LOC_entwicklung *LINK)
{
	LINK->yreg = LINK->xreg;
	LINK->op[0] = LINK->op[1];
	LINK->opanz = 1;
}

static void berechnen(struct LOC_entwicklung *LINK)
{
	switch (LINK->opanz) 
	{

		case 1:
			LINK->yreg = LINK->xreg;
			break;

		case 2:
			switch (LINK->op[1]) 
			{

				case '*':
				case '/':
					switch (LINK->op[0]) 
					{

						case '*':
							LINK->xreg = LINK->yreg * LINK->xreg;
							op2_auf_op1(LINK);
							break;

						case '/':
							if (LINK->xreg == 0)
								*LINK->fcode = 1;
							else 
							{
								LINK->xreg = LINK->yreg / LINK->xreg;
								op2_auf_op1(LINK);
							}
							break;

						case '+':
						case '-':
							LINK->zreg = LINK->yreg;
							LINK->yreg = LINK->xreg;
							break;
					}
					break;

				case '+':
				case '-':
					switch (LINK->op[0]) 
					{

						case '*':
							LINK->xreg = LINK->yreg * LINK->xreg;
							op2_auf_op1(LINK);
							break;

						case '/':
							if (LINK->xreg == 0)
								*LINK->fcode = 1;
							else 
							{
								LINK->xreg = LINK->yreg / LINK->xreg;
								op2_auf_op1(LINK);
							}
							break;

						case '+':
							LINK->xreg = LINK->yreg + LINK->xreg;
							op2_auf_op1(LINK);
							break;

						case '-':
							LINK->xreg = LINK->yreg - LINK->xreg;
							op2_auf_op1(LINK);
							break;
					}
					break;
				}
				break;

			case 3:
				switch (LINK->op[1]) 
				{

					case '*':
						LINK->xreg = LINK->yreg * LINK->xreg;
						LINK->yreg = LINK->xreg;
						break;

					case '/':
						if (LINK->xreg == 0)
							*LINK->fcode = 1;
						else 
						{
							LINK->xreg = LINK->yreg / LINK->xreg;
							LINK->yreg = LINK->xreg;
						}
						break;
				}
				LINK->opanz = 2;
				LINK->op[1] = LINK->op[2];
				switch (LINK->op[1]) 
				{

					case '+':
					case '-':
						switch (LINK->op[0]) 
						{

							case '+':
								LINK->xreg = LINK->zreg + LINK->xreg;
								op2_auf_op1(LINK);
								break;

							case '-':
								LINK->xreg = LINK->zreg - LINK->xreg;
								op2_auf_op1(LINK);
								break;
						}
						break;
				}
				break;
			}
}  /*berechnen*/

static void klammer_auf(struct LOC_entwicklung *LINK)
{
	if (LINK->kli >= maxkli) 
	{   /*zu viele geîffnete Klammern*/
		*LINK->fcode = 4;
		return;
	}
	switch (LINK->opanz) 
	{

		case 0:
			LINK->kli++;
			LINK->klreg[LINK->kli - 1].anz = 0;
			break;

		case 1:
			LINK->kli++;
			LINK->klreg[LINK->kli - 1].reg1 = LINK->yreg;
			LINK->klreg[LINK->kli - 1].op1 = LINK->op[0];
			LINK->klreg[LINK->kli - 1].anz = 1;
			break;
		
		case 2:
			LINK->kli++;
			LINK->klreg[LINK->kli - 1].reg1 = LINK->zreg;
			LINK->klreg[LINK->kli - 1].op1 = LINK->op[0];
			LINK->klreg[LINK->kli - 1].reg2 = LINK->yreg;
			LINK->klreg[LINK->kli - 1].op2 = LINK->op[1];
			LINK->klreg[LINK->kli - 1].anz = 2;
			break;
	}
	LINK->klreg[LINK->kli - 1].vorz = LINK->vorz;
	LINK->vorz = TRUE;
	LINK->xreg = 0.0;
	LINK->yreg = 0.0;
	LINK->opanz = 0;
}  /*klammer_auf*/

static void klammer_zu(struct LOC_entwicklung *LINK)
{
	if (LINK->kli <= 0) 
	{   /*zu viele geschlossene Klammern*/
		*LINK->fcode = 5;
		return;
	}
	LINK->opanz++;
	LINK->op[LINK->opanz - 1] = '+';
	berechnen(LINK);
	if (!LINK->klreg[LINK->kli - 1].vorz)
		LINK->xreg = -LINK->xreg;
	switch (LINK->klreg[LINK->kli - 1].anz) 
	{

		case 0:
			LINK->kli--;
			LINK->opanz = 0;
			break;
		
		case 1:
			LINK->yreg = LINK->klreg[LINK->kli - 1].reg1;
			LINK->op[0] = LINK->klreg[LINK->kli - 1].op1;
			LINK->kli--;
			LINK->opanz = 1;
			break;
			
		case 2:
			LINK->zreg = LINK->klreg[LINK->kli - 1].reg1;
			LINK->op[0] = LINK->klreg[LINK->kli - 1].op1;
			LINK->yreg = LINK->klreg[LINK->kli - 1].reg2;
			LINK->op[1] = LINK->klreg[LINK->kli - 1].op2;
			LINK->kli--;
			LINK->opanz = 2;
			break;
	}
}  /*klammer_zu*/

static void task(struct LOC_entwicklung *LINK)
{
	switch (LINK->zust) 
	{

		case start:
			LINK->st_index++;
/*
			case upcase(ausdruck[st_index]) of
*/
			switch (LINK->ausdruck[LINK->st_index - 1]) 
			{

				case '+':
					LINK->vorz = TRUE;
					LINK->zust = vorzeichen;
					break;

				case '-':
					LINK->vorz = FALSE;
					LINK->zust = vorzeichen;
					break;

				case '(':
					LINK->zust = klauf1;
					break;

				case ' ':
					/* blank case */
					break;

				case '=':
				case '\0':
					LINK->zust = ende;
					break;

				default:
					if (isdigit(LINK->ausdruck[LINK->st_index - 1]) ||
/*
						LINK->ausdruck[LINK->st_index - 1] == ',' ||
*/
						LINK->ausdruck[LINK->st_index - 1] == '.') 
					{
						strcat(LINK->konst_str, " ");
						LINK->konst_str[strlen(LINK->konst_str) - 1] =
							LINK->ausdruck[LINK->st_index - 1];
						LINK->akt_pos = LINK->st_index;
						LINK->zust = konstante;
					} 
					else 
						if (isalpha(LINK->ausdruck[LINK->st_index - 1]) ||
							(LINK->ausdruck[LINK->st_index - 1] & 255) == 142 ||
							(LINK->ausdruck[LINK->st_index - 1] & 255) == 153 ||
							(LINK->ausdruck[LINK->st_index - 1] & 255) == 154) 
						{
/*
							var_name:=upcase(ausdruck[st_index]);
*/
							LINK->var_name[0] = LINK->ausdruck[LINK->st_index - 1];
							LINK->var_name[1] = 0;
							LINK->akt_pos = LINK->st_index;
							LINK->zust = variable;
						} 
						else 
						{
							*LINK->fcode = 13;
							LINK->zust = fehler;
						}
					break;
			}
			break;

		case variable:
			LINK->st_index++;
/*
			case upcase(ausdruck[st_index]) of
*/
			switch (LINK->ausdruck[LINK->st_index - 1]) 
			{

				case '+':
				case '-':
				case '*':
				case '/':
					LINK->zust = operator1;
					break;
				
				case ')':
					LINK->zust = klzu1;
					break;
				
				case ' ':
					LINK->zust = variende;
					break;
				
				case '=':
				case '\0':
					LINK->zust = ende;
					break;
				
				default:
					if (isalpha(LINK->ausdruck[LINK->st_index - 1]) ||
						(LINK->ausdruck[LINK->st_index - 1] & 255) == 142 ||
						(LINK->ausdruck[LINK->st_index - 1] & 255) == 153 ||
						(LINK->ausdruck[LINK->st_index - 1] & 255) == 154 ||
						 isdigit(LINK->ausdruck[LINK->st_index - 1])) 
					{
						strcat(LINK->var_name, " ");
						LINK->var_name[strlen(LINK->var_name) - 1] =
							LINK->ausdruck[LINK->st_index - 1];
/*
						upcase(ausdruck[st_index]);
*/
					} 
					else 
					{
						*LINK->fcode = 7;
						LINK->zust = fehler;
					}
					break;
			}
			if (LINK->zust != variable && *LINK->fcode == 0) 
			{
				if (var_vorhanden(LINK->var_name, &LINK->var_wert, &LINK->var_nr)) 
				{
					LINK->xreg = LINK->var_wert;
					if (!LINK->vorz) 
					{   /*negatives Vorzeichen ?*/
						LINK->xreg = -LINK->xreg;
						LINK->vorz = TRUE;   /*wieder auf positives Vorzeichen schalten*/
					}
				} 
				else 
				{
					*LINK->fcode = 17;
					LINK->zust = fehler;
				}
			}
			break;

		case variende:
			LINK->st_index++;
/*
			case upcase(ausdruck[st_index]) of
*/
			switch (LINK->ausdruck[LINK->st_index - 1]) 
			{

				case '+':
				case '-':
				case '*':
				case '/':
					LINK->zust = operator1;
					break;
				
				case ')':
					LINK->zust = klzu1;
					break;
				
				case ' ':
					/* blank case */
					break;
				
				case '=':
				case '\0':
					LINK->zust = ende;
					break;
				
				default:
					*LINK->fcode = 15;
					LINK->zust = fehler;
					break;
			}
			break;

		case konstante:
			LINK->st_index++;
/*
			case upcase(ausdruck[st_index]) of
*/
			switch (LINK->ausdruck[LINK->st_index - 1]) 
			{

				case '+':
				case '-':
				case '*':
				case '/':
					LINK->zust = operator1;
					break;
				
				case ')':
					LINK->zust = klzu1;
					break;
				
				case ' ':
					LINK->zust = konstende;
					break;
				
				case '=':
				case '\0':
					LINK->zust = ende;
					break;

				default:
					if (isdigit(LINK->ausdruck[LINK->st_index - 1]) ||
/*
						LINK->ausdruck[LINK->st_index - 1] == ',' ||
*/
						LINK->ausdruck[LINK->st_index - 1] == '.') 
					{
						strcat(LINK->konst_str, " ");
						LINK->konst_str[strlen(LINK->konst_str) - 1] =
							LINK->ausdruck[LINK->st_index - 1];
					} 
					else 
					{
						*LINK->fcode = 8;
						LINK->zust = fehler;
					}
					break;
			}
			if (LINK->zust != konstante && *LINK->fcode == 0) 
			{
				if (strlen(LINK->konst_str) < '\036') 
				{
					LINK->code = (sscanf(LINK->konst_str, "%lg", &LINK->xreg) == 0);
					if (LINK->code == 0) 
					{
						if (!LINK->vorz) 
						{
							LINK->xreg = -LINK->xreg;
							LINK->vorz = TRUE;
						}
						strcpy(LINK->konst_str, "0");
					} 
					else 
					{
						*LINK->fcode = 16;
						LINK->zust = fehler;
					}
				} 
				else 
				{
					*LINK->fcode = 16;
					LINK->zust = fehler;
				}
			}
			break;

		case konstende:
			LINK->st_index++;
/*
			case upcase(ausdruck[st_index]) of
*/
			switch (LINK->ausdruck[LINK->st_index - 1]) 
			{

				case '+':
				case '-':
				case '*':
				case '/':
					LINK->zust = operator1;
					break;
				
				case ')':
					LINK->zust = klzu1;
					break;
				
				case ' ':
					/* blank case */
					break;
				
				case '=':
				case '\0':
					LINK->zust = ende;
					break;
				
				default:
					*LINK->fcode = 14;
					LINK->zust = fehler;
					break;
			}
			break;

		case operator1:
			LINK->opanz++;
			LINK->op[LINK->opanz - 1] = LINK->ausdruck[LINK->st_index - 1];
			berechnen(LINK);
			if (*LINK->fcode == 0)
				LINK->zust = operator2;
			else
				LINK->zust = fehler;
			break;

		case operator2:
			LINK->st_index++;
/*
			case upcase(ausdruck[st_index]) of
*/
			switch (LINK->ausdruck[LINK->st_index - 1]) 
			{

				case '(':
					LINK->zust = klauf1;
					break;

				case '+':
					LINK->vorz = TRUE;
					LINK->zust = vorzeichen;
					break;
				
				case '-':
					LINK->vorz = FALSE;
					LINK->zust = vorzeichen;
					break;
				
				case ' ':
					/* blank case */
					break;
				
				case '=':
				case '\0':
					LINK->zust = ende;
					break;

				default:
				if (isdigit(LINK->ausdruck[LINK->st_index - 1]) ||
/*
					LINK->ausdruck[LINK->st_index - 1] == ',' ||
*/
					LINK->ausdruck[LINK->st_index - 1] == '.') 
				{
					strcat(LINK->konst_str, " ");
					LINK->konst_str[strlen(LINK->konst_str) - 1] =
						LINK->ausdruck[LINK->st_index - 1];
					LINK->akt_pos = LINK->st_index;
					LINK->zust = konstante;
				} 
				else 
					if (isalpha(LINK->ausdruck[LINK->st_index - 1]) ||
						(LINK->ausdruck[LINK->st_index - 1] & 255) == 142 ||
						(LINK->ausdruck[LINK->st_index - 1] & 255) == 153 ||
						(LINK->ausdruck[LINK->st_index - 1] & 255) == 154) 
					{
/*
						var_name:=upcase(ausdruck[st_index]);
*/
						LINK->var_name[0] = LINK->ausdruck[LINK->st_index - 1];
						LINK->var_name[1] = 0;
						LINK->akt_pos = LINK->st_index;
						LINK->zust = variable;
					} 
					else 
					{
						*LINK->fcode = 9;
						LINK->zust = fehler;
					}
					break;
			}
			break;

		case vorzeichen:
			LINK->st_index++;
/*
			case upcase(ausdruck[st_index]) of
*/
			switch (LINK->ausdruck[LINK->st_index - 1]) 
			{

				case '(':
					LINK->zust = klauf1;
					break;
				
				case ' ':
					/* blank case */
					break;
				
				case '=':
				case '\0':
					LINK->zust = ende;
					break;
				
				default:
					if (isdigit(LINK->ausdruck[LINK->st_index - 1]) ||
/*
						LINK->ausdruck[LINK->st_index - 1] == ',' ||
*/
						LINK->ausdruck[LINK->st_index - 1] == '.') 
					{
						strcat(LINK->konst_str, " ");
						LINK->konst_str[strlen(LINK->konst_str) - 1] =
							LINK->ausdruck[LINK->st_index - 1];
						LINK->akt_pos = LINK->st_index;
						LINK->zust = konstante;
					} 
					else 
					if (isalpha(LINK->ausdruck[LINK->st_index - 1]) ||
						(LINK->ausdruck[LINK->st_index - 1] & 255) == 142 ||
						(LINK->ausdruck[LINK->st_index - 1] & 255) == 153 ||
						(LINK->ausdruck[LINK->st_index - 1] & 255) == 154) 
					{
/*
						var_name:=upcase(ausdruck[st_index]);
*/
						LINK->var_name[0] = LINK->ausdruck[LINK->st_index - 1];
						LINK->var_name[1] = 0;
						LINK->akt_pos = LINK->st_index;
						LINK->zust = variable;
					} 
					else 
					{
						*LINK->fcode = 10;
						LINK->zust = fehler;
					}
					break;
			}
			break;

		case klauf1:
			klammer_auf(LINK);
			if (*LINK->fcode == 0)
				LINK->zust = klauf2;
			else
				LINK->zust = fehler;
			break;

		case klauf2:
			LINK->st_index++;
/*
			case upcase(ausdruck[st_index]) of
*/
			switch (LINK->ausdruck[LINK->st_index - 1]) 
			{
			
				case '+':
					LINK->vorz = TRUE;
					LINK->zust = vorzeichen;
					break;
					
				case '-':
					LINK->vorz = FALSE;
					LINK->zust = vorzeichen;
					break;
					
				case '(':
					LINK->zust = klauf1;
					break;
					
				case ')':
					LINK->zust = klzu1;
					break;
					
				case ' ':
					/* blank case */
					break;
					
				case '=':
				case '\0':
					LINK->zust = ende;
					break;
					
				default:
					if (isdigit(LINK->ausdruck[LINK->st_index - 1]) ||
/*
						LINK->ausdruck[LINK->st_index - 1] == ',' ||
*/
						LINK->ausdruck[LINK->st_index - 1] == '.') 
					{
						strcat(LINK->konst_str, " ");
						LINK->konst_str[strlen(LINK->konst_str) - 1] =
							LINK->ausdruck[LINK->st_index - 1];
						LINK->akt_pos = LINK->st_index;
						LINK->zust = konstante;
					} 
					else 
						if (isalpha(LINK->ausdruck[LINK->st_index - 1]) ||
							(LINK->ausdruck[LINK->st_index - 1] & 255) == 142 ||
							(LINK->ausdruck[LINK->st_index - 1] & 255) == 153 ||
							(LINK->ausdruck[LINK->st_index - 1] & 255) == 154) 
						{
/*
							var_name:=upcase(ausdruck[st_index]);
*/
							LINK->var_name[0] = LINK->ausdruck[LINK->st_index - 1];
							LINK->var_name[1] = 0;
							LINK->akt_pos = LINK->st_index;
							LINK->zust = variable;
						} 
						else 
						{
							*LINK->fcode = 11;
							LINK->zust = fehler;
						}
						break;
			}
			break;

		case klzu1:
			klammer_zu(LINK);
			if (*LINK->fcode == 0)
				LINK->zust = klzu2;
			else
				LINK->zust = fehler;
			break;

		case klzu2:
			LINK->st_index++;
			switch (LINK->ausdruck[LINK->st_index - 1]) 
			{

				case '+':
				case '-':
				case '*':
				case '/':
					LINK->zust = operator1;
					break;
				
				case ')':
					LINK->zust = klzu1;
					break;
				
				case ' ':
					/* blank case */
					break;
				
				case '=':
				case '\0':
					LINK->zust = ende;
					break;
				
				default:
					*LINK->fcode = 12;
					LINK->zust = fehler;
					break;
			}
			break;

		case fehler:
			if (*LINK->fcode == 16 || *LINK->fcode == 17)
				*LINK->ergebnis = LINK->akt_pos;
			else
				*LINK->ergebnis = LINK->st_index;
			LINK->fertig = TRUE;
			break;

		case ende:
			if (LINK->kli != 0) 
			{
				*LINK->fcode = 6;   /*Klammeranzahl falsch*/
				LINK->zust = fehler;
			} 
			else 
			{
				LINK->opanz++;
				LINK->op[LINK->opanz - 1] = '+';
				berechnen(LINK);
				if (*LINK->fcode == 0) 
				{
					if (LINK->xreg > LINK->ober_grenze || LINK->xreg < LINK->unter_grenze) 
					{
						if (LINK->xreg > LINK->ober_grenze)   /*Zahl zu klein*/
							*LINK->fcode = 2;   /*Zahl zu gro·*/
						else
							*LINK->fcode = 3;
						LINK->zust = fehler;
					} 
					else 
					{
						*LINK->ergebnis = LINK->xreg;
						LINK->fertig = TRUE;
					}
				} 
				else
					LINK->zust = fehler;
			}
			break;
	}/*case zust of*/
}  /*task*/


void entwicklung(	char *ausdruck_, 
						double unter_grenze_, 
						double ober_grenze_,
						double *ergebnis_, 
						int *fcode_)
{
	struct LOC_entwicklung V;

	strcpy(V.ausdruck, ausdruck_);
	V.unter_grenze = unter_grenze_;
	V.ober_grenze = ober_grenze_;
	V.ergebnis = ergebnis_;
	V.fcode = fcode_;
	V.zust = start;
	*V.fcode = 0;   /*bisher kein Fehler*/
	V.kli = 0;
	V.opanz = 0;
	V.xreg = 0.0;
	V.yreg = 0.0;
	V.zreg = 0.0;
	strcpy(V.konst_str, "0");
	V.st_index = 0;
	V.akt_pos = 1;
/*ausdruck:=ohne_blanks(ausdruck);*/
/*Alle Blanks des Strings lîschen*/
	strcat(V.ausdruck, " ");   /*00 als Endekennung anhÑngen*/
	V.ausdruck[strlen(V.ausdruck) - 1] = '\0';
	V.vorz = TRUE;   /*Vorzeichen als default auf plus setzen*/
	V.fertig = FALSE;
	do 
	{
		task(&V);
	} 
	while (!V.fertig);
}  /*entwicklung*/

#undef maxkli

double interpretiere(char *gleichung, int *fcode)
{
	double ergebnis;
	
	entwicklung(gleichung,-10E+4932, 10E+4932, &ergebnis, fcode);
	return ergebnis;
}
