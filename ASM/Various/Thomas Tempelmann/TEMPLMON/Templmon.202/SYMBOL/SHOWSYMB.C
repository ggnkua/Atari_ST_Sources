/************************************************************
* Ausgabe der Symbol-Strukturen aller Programme im Speicher *
************************************************************/

#include <stdio.h>
#include "showsymb.h"

SymbolCookie	*FirstPointer = NULL;

/************************************************************************/
/* Cookie-Jar "SYMB" suchen und, falls gefunden, Zeiger initialisieren: */
/************************************************************************/
long GetSymbolHeader (void)
{
	LONG	*CookiePtr = (LONG *) 0x5a0;
	LONG	CookieName, CookieWert;

	/**********************************/
	/* Cookie-Jar-Tabelle vorhanden ? */
	/**********************************/
	if ((CookiePtr = (LONG *) *CookiePtr) == 0L)
		return (0);

	/********************************************************************/
	/* Solange die Tabelle durchsuchen, bis Treffer oder Ende erreicht: */
	/********************************************************************/
	for (;;)
	{
		/**************************************/
		/* Cookie-Name und Cookie-Wert holen: */
		/**************************************/
		CookieName = *CookiePtr++;
		CookieWert = *CookiePtr++;

		/*******************************/
		/* Ende der Tabelle erreicht ? */
		/*******************************/
		if (CookieName == 0L)
			return (0);

		/********************************/
		/* Cookie-Jar "SYMB" gefunden ? */
		/********************************/
		if (CookieName == SYMBOL_COOKIE)
		{
			/***************************/
			/* Zeiger initialisisieren */
			/***************************/
			FirstPointer = (SymbolCookie *) CookieWert;
			return (0);
		}
	}
}

/**************************************************************/
/* Beispielprogramm zur Anwendung des Resident Symbol Drivers */
/**************************************************************/
int main (void)
{
	WORD			i, *Offsets;
	Symbol			*Data;
	Symbol			*Daten, *Symb;
	SymbolHeader	*Pointer;
	LONG			Return;
	SymbolHeader	*Structure;

	/*************************************/
	/* Cookie-Wert von "SYMB" ermitteln: */
	/*************************************/
	Supexec (GetSymbolHeader);

	/******************************************************************/
	/* Wenn der Zeiger NULL ist, so ist der Treiber nicht installiert */
	/******************************************************************/
	if (FirstPointer == NULL)
	{
		printf ("\nResident Symbol Driver nicht gefunden !!\n");
		return (1);
	}

	/*****************************************/
	/* Versionsnummer des Treibers ausgeben: */
	/*****************************************/
	printf ("\nVersion des Treibers: %x.%0x\n",
		FirstPointer->Version, FirstPointer->Revision);

	/************************************/
	/* Zeiger auf erste Struktur holen: */
	/************************************/
	Pointer = FirstPointer->First;

	/******************************************/
	/* Nacheinander alle Struktur bearbeiten: */
	/******************************************/
	while (Pointer != NULL)
	{
		/************************************************/
		/* Information am Anfang der Struktur ausgeben: */
		/************************************************/
		if (Pointer->ProgramName [0] == '\0')
		{
			printf ("\nSystemtabelle:");
			printf ("\nAnzahl der Symbole:             %5u", Pointer->SymbolCount);
		}
		else
		{
			printf ("\nProgrammname: '%s'", &(Pointer->ProgramName));
			if (Pointer->SymbolCount > 0)
				printf ("\nAnzahl der Symbole:             %5u", Pointer->SymbolCount);
			printf ("\nStartadresse des Programms: $%08lx", Pointer->FirstAddress);
			printf ("\nEndadresse des Programms:   $%08lx", Pointer->LastAddress);
			printf ("\nBasepage des Programms:     $%08lx", Pointer->Basepage);
		}
		if (Pointer->Next != NULL)
			printf ("\nNachfolger der Struktur:    $%08lx\n", Pointer->Next);

		/**************************/
		/* Zeiger initialisieren: */
		/**************************/
		Offsets = Pointer->SymbolNames;
		Daten = Pointer->SymbolData;

		/**************************/
		/* Alle Symbole ausgeben: */
		/**************************/
		for (i = 0; i < (Pointer->SymbolCount); i++)
		{
			/************************************/
			/* Zeiger auf das Symbol berechnen: */
			/************************************/
			Symb = (Symbol *) ((LONG) Daten + (LONG) (Offsets [i]));

			/**************************/
			/* Symbolnamen bestimmen: */
			/**************************/
			Return = GetSymbolName (FirstPointer, Symb->Value, &Data, &Structure);

			/*************************************************************/
			/* Wenn ein Name nicht gefunden werden konnte, Fehler melden */
			/*************************************************************/
			if (Return != 0)
			{
				printf ("\nName Error: %s\n", &(Symb->Name [0]));
				return (1);
			}

			/*************************************/
			/* Symbolnamen linksbndig ausgeben: */
			/*************************************/
			printf ("%-22.22s", &(Data->Name [0]));

			/*************************/
			/* Symbolwert ermitteln: */
			/*************************/
			Return = GetSymbolValue (FirstPointer, &(Data->Name [0]),
						(char *) Structure, &Data, &Structure);

			/*******************************************************/
			/* Wenn das Symbol nicht gefunden wurde, Fehler melden */
			/*******************************************************/
			if (Return != 0)
			{
				printf ("\nValue Error\n");
				return (1);
			}

			/************************************/
			/* Parameter des Symbols auswerten: */
			/************************************/
			switch (Symb->Type & SYSTEM_MASK)
			{
				case BSS_MASK:
					printf (": BSS,  ");
					break;
				case TEXT_MASK:
					printf (": TEXT, ");
					break;
				case DATA_MASK:
					printf (": DATA, ");
					break;
				default:
					printf (": ");
			}

			/************************/
			/* Symbolwert ausgeben: */
			/************************/
			printf ("$%08lx\n", Data->Value);
		}

		/*******************************************/
		/* Zeiger auf die n„chste Struktur setzen: */
		/*******************************************/
		Pointer = Pointer->Next;
	}

	/****************/
	/* Programmende */
	/****************/
	return (0);
}
