/***************************************/
/*                                     */
/* OUT To LOD DSP 56001 File Converter */
/*                                     */
/*      Gabriel Sebestyen - 1993       */
/*                                     */
/***************************************/

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

#define MAXLEN 256
#define START "_START"
#define DATA  "_DATA"
#define END   "_END"
#define SPACE " "
#define ENTER "\r\n"
#define PMEM  "P"
#define XMEM  "X"
#define YMEM  "Y"
#define NAME  "TEST"
#define DSP   "DSP56001 4.1.1"
#define FOURNULL "0000"
#define MAXDATAS 8

char *String[ MAXLEN ];
int  Length;

char ReadByte ( int );
void WriteByte ( int , char );
int ReadString ( int , char * );
void WriteString ( int , char * );
int CmpStr ( char * ,char * );
int StrToNum ( char * );

void main ( argc , argv )
int argc;
char *argv[];
	{
		char *Fname ,*Fmem;
		char *From;
		int  TstLen = 0;
		int Rhandle ,Whandle;
		int ActAddr = 0;
		int NewAddr;
		char *ActMem = "x";
		int LineCounter = 0;
		char *String = "                       ";
		int Status = 0;
		if ( argc < 2 || *argv[1] == '?' )
			{
				printf ( ".OUT to .LOD Converter v01\n" );
				printf ( "Written By Gabriel Sebestyen\n" );
				printf ( "Input: .OUT DSP-ASCII file made by A56.TTP\n" );
				printf ( "Output: .LOD file ... \n" );
				getch ();
				exit ( 1 );
			}
		Fmem = Malloc ( 100 );

		Fname = Fmem;
		From = argv[1];
		while ( *From != 0x0000 )
			{
				*Fname++ = *From++ ;
				TstLen ++;
			}
		while ( *Fname != '.' || TstLen-- == 0x0000 )
				Fname--;
		
		if ( *Fname != '.' )
			{
				printf ( "Wrong filename!\n" );
				exit ( 1 );
			}
		
		Fname++;
		*Fname++ = 'L';
		*Fname++ = 'O';
		*Fname++ = 'D';
		*Fname++ = 0x00;
		Fname = Fmem;
	
		printf ( "Working ...\n" );
		
		Rhandle = Fopen ( argv[1] , 0 );
		if ( Rhandle < 0 )
			{
				printf ( "Can't open file %s !\n" ,argv[1] );
				exit ( 1 );
			}
		Whandle = Fcreate ( Fname , 0 );
		if ( Whandle < 0 )
			{
				printf ( "Can't open file %s !\n" ,Fname );
				exit ( 1 );
			}
		
		WriteString ( Whandle , START );
		WriteString ( Whandle , SPACE );
		WriteString ( Whandle , NAME );
		WriteString ( Whandle , SPACE );
		WriteString ( Whandle , FOURNULL );
		WriteString ( Whandle , SPACE );
		WriteString ( Whandle , FOURNULL );
		WriteString ( Whandle , SPACE );
		WriteString ( Whandle , FOURNULL );
		WriteString ( Whandle , SPACE );
		WriteString ( Whandle , DSP );
		WriteString ( Whandle , ENTER );

		while ( Status == 0 )
			{
				if ( ReadString ( Rhandle , String ) == -1 )
					break;
				if ( *String != *ActMem )
					{
						*ActMem = *String;
						*( ActMem +1 ) = 0;
						
						WriteString ( Whandle , ENTER );
						WriteString ( Whandle , DATA );
						WriteString ( Whandle , SPACE );
						WriteString ( Whandle , ActMem );
						WriteString ( Whandle , SPACE );
						ReadString ( Rhandle , String );
						WriteString ( Whandle , String );
						WriteString ( Whandle , ENTER );
						ActAddr = StrToNum ( String );
						LineCounter = 0;
					}
				else
					{
						ReadString ( Rhandle , String );
						NewAddr = StrToNum ( String );
						if ( ActAddr  != NewAddr )
							{
								ActAddr = NewAddr;
								WriteString ( Whandle , ENTER );
								WriteString ( Whandle , DATA );
								WriteString ( Whandle , SPACE );
								WriteString ( Whandle , ActMem );
								WriteString ( Whandle , SPACE );
								WriteString ( Whandle , String );
								WriteString ( Whandle , ENTER );
								LineCounter = 0;
							}
					}

					ReadString ( Rhandle , String );
					WriteString ( Whandle , String );
					if ( LineCounter == 7 )
						{
							WriteString ( Whandle , ENTER );
							LineCounter = 0;
						}
					else
						{
							WriteString ( Whandle , SPACE );
							LineCounter++;
						}
					ActAddr++;
			}
		
		WriteString ( Whandle , ENTER );		
		WriteString ( Whandle , END );		
		WriteString ( Whandle , SPACE );		
		WriteString ( Whandle , FOURNULL );		
		WriteString ( Whandle , ENTER );		

		Fclose ( Whandle );
		Fclose ( Rhandle );
		Mfree ( Fmem );

		
	}

char ReadByte ( Rhandle )
int Rhandle;
	{
		char Byte;
		int Erreur;
		
		Erreur = Fread ( Rhandle , 1 , &Byte );
		if ( Erreur < 1 )
			Byte = 0xFF;
		return ( Byte );
	}

void WriteByte ( Whandle , Byte )
int Whandle;
char Byte;
	{
		int Erreur;
		
		Erreur = Fwrite ( Whandle , 1 , &Byte );
		if ( Erreur < 0 )
			{
				printf ( "Write Error!\n" );
				exit ( 1 );
			}
	}

int ReadString ( Rhandle , Spointer )
int Rhandle;
char *Spointer;
	{
		int i;
		char Byte = ' ';
		
		while ( Byte <= ' ' && Byte >= 1 )
			Byte = ReadByte ( Rhandle );

		if ( Byte == 0xFF )
			return ( -1 );

		*Spointer++ = Byte;
		
		for ( i = 0 ; i < MAXLEN ; i++)
			{
				Byte = ReadByte ( Rhandle );
				if ( Byte == 0xFF )
					return ( -1 );
				
				if ( Byte > ' ' )
					*Spointer++ = Byte;
				else
					break;
			}
		*Spointer++ = 0x00;
		return ( 0 );
	}

void WriteString ( Whandle , Spointer )
int Whandle;
char *Spointer;
	{
		while ( *Spointer != 0x00 )
			WriteByte ( Whandle , *Spointer++ );
	}

int CmpStr ( String1 , String2 )
char *String1 , *String2;
	{
		int Len = 0x0000;
		
		while ( *String1++ == *String2 ++ )
			Len++;
		return ( Len );
	}

int StrToNum ( String1 )
char *String1;
	{
		int number = 0;
		unsigned int hexa = 1;
		char byte;
		int counter = 0;

		while ( *String1++ != 0x00 )
			counter++;
		
		if ( counter == 0 )
			return ( 0 );
			
		String1--;
		String1--;
		
		while ( counter-- > 0 )
			{
				byte = *String1--;
				if ( byte >= '0' && byte <= '9' )
					number += ( byte - '0' ) * hexa;
				else if ( byte >= 'A' && byte <= 'F' )
					number += ( ( byte - 'A' ) + 10 ) * hexa;
				hexa *= 16;
			}
		return ( number );
	}
