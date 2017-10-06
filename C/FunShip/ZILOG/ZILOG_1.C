/*
 *
 *
 *		Programme dÇmonstration 1 - Simple terminal entre deux machines
 *
 *		Ce programme transfäre Ö 19200 Bits/Sec. en 8 Bits ParitÇ Paire
 *		1 bit de Stop.
 *		Il opäre en mode simple, Çmission d'un caratäre et test si caractäre
 *		reáu avant Çventuellement sa prise en compte.
 *
 *
 *		FunShip (c) 28 Avril 1995 - ATARI Falcon030
 *
 */
 
 
#include <stdio.h>
#include <tos.h>

#define	TRUE		1
#define	FALSE		0

#define	SCC_CONTROLA	0xFFFF8C81L		/* Registers Z85C30's addresses*/
#define	SCC_DATAA	0xFFFF8C83L
#define	SCC_CONTROLB	0xFFFF8C85L
#define	SCC_DATAB	0xFFFF8C87L

#define	WR1		1
#define	WR2		2
#define	WR3		3
#define	WR4		4
#define	WR5		5
#define	WR6		6
#define	WR7		7
#define	WR8		8
#define	WR9		9
#define	WR10		10
#define	WR11		11
#define	WR12		12
#define	WR13		13
#define	WR14		14
#define	WR15		15

#define	RR1		1
#define	RR2		2
#define	RR3		3
#define	RR10		10
#define	RR12		12
#define	RR13		13
#define	RR15		15

/*
 *		Primitives d'accäs aux registres du ZILOG
 */
 
void SCCPut(int Canal,int Value,int Register)
/*
	This procedure put a value in any register of Z85C30
	
	Inputs:	Value is the byte value to store
		Register is the number of target register
	Outputs:None
*/
{
  if(Canal == 'B')
  {
    *(char *)SCC_CONTROLB	= Register;
    *(char *)SCC_CONTROLB	= Value;
  }
  else
  {
    *(char *)SCC_CONTROLA	= Register;
    *(char *)SCC_CONTROLA	= Value;
  }
}

int SCCGet(int Channel, int Register)
/*
	This function read a value from any register of Z85C30
	
	Inputs:	Register is the number of source register
	Outputs:Return the register's value
*/
{
  int	Value;
  
  if(Channel == 'B')
  {
    *(char *)SCC_CONTROLB	= Register;
    Value			= *(char *)SCC_CONTROLB;
  }
  else
  {
    *(char *)SCC_CONTROLA	= Register;
    Value			= *(char *)SCC_CONTROLA;
  }
  return(Value);
}

/*
 *	Primitives plus haut niveaux: Initialisation, Emission, Test et RÇception
 */
 
void SCCInit(int Channel)
/*
	Initialize the chip in 19200 Bits/Sec, Parity Even, 1 Stop bit and 8 Bits Data
	No interrupts required.
*/
{
  SCCPut(Channel,0x00,WR3);			/* Receiver Off */
  SCCPut(Channel,0x00,WR5);			/* Transceiver Off */
  SCCPut(Channel,0x00,WR1);			/* no ITs selected */
  SCCPut(Channel,0x82,WR2);			/* Interrupt Vector, but not used */
  SCCPut(Channel,0x47,WR4);			/* Async. 1 Stop parity Even and Clk/16 */
  SCCPut(Channel,0x00,WR9);			/* Disbale all interrupts */
  SCCPut(Channel,0x00,WR10);			/* NRZ Code mode -> RS232C */
  SCCPut(Channel,0x50,WR11);			/* RxClk = TxClk = BR */
  SCCPut(Channel,0x00,WR15);			/* No special interrupts */
  SCCPut(Channel,0xA3,WR14);			/* BR -> PCLK */
  SCCPut(Channel,0x0B,WR12);			/* Divide value LSB */
  SCCPut(Channel,0x00,WR13);			/* Divide value MSB => 19200 Bauds */
  
  SCCPut(Channel,0xC1,WR3);			/* 8 Bits and enable receiver */
  SCCPut(Channel,0xE8,WR5);			/* 8 Bits and ebale transceiver */
}

void SCCOut(int Channel, int Byte)
/*
	Send a character trough the output data register.
*/
{
  if(Channel == 'B')
    *(char *)SCC_DATAB = Byte;
  else
    *(char *)SCC_DATAA = Byte;
}

int SCCReceived(int Channel)
/*
	Return True if a character is received else false. A character is arrived if
	the bit 0 of RR0 is set.
*/
{
  int	Etat;
  
  if(Channel == 'B')
    Etat = *(char *)SCC_CONTROLB & 0x01;
  else
    Etat = *(char *)SCC_CONTROLA & 0x01; 
  return(Etat); 
}

int SCCIn(int Channel)
/*
	Get a character from the input data register.
*/
{
  if(Channel == 'B')
    return(*(char *)SCC_DATAB);
  else
    return(*(char *)SCC_DATAA);
}

/*
 *	Programme principal de test
 */
 
int main(void)
{
  unsigned int	Character;
  int		*OldPile;
  int		Colonne;
  
  printf("\033E");
  printf("\t\tZILOG Z85C30: Transmition/Reception by Registers's Read/Write\n");
  printf("\t\tPress ESC to exit\n");
  printf("\t\t=============================================================\n\n");

  printf("Z85C30 programmed at 19200 bits/s, Parity even, 1 Stop bit and 8 bits data\n");
  printf("On its B Channel\n\n");
  
  OldPile	= (int *)Super(0L);		/* Go to supervisor mode */
  
  SCCInit('B');					/* Initialize the Zilog */
  Colonne = 1;
  Character = (unsigned char)Crawio(0xFF);	/* Reading a character */
  while(Character != 27)
  {
    if(Character != 0)				/* a key is pressed */
    {
      if(Colonne < 80)
      {
        printf("%c",Character);
        Colonne++;
      }
      else					/* Go back top line */
      {
        Colonne = 1;
        printf("\n");
        printf("%c",Character);
      }
      SCCOut('B',Character);			/* Sending its ASCII code */
    }
    if(SCCReceived('B'))			/* If a character is arrived */
    {
      if(Colonne < 80)
      {
        printf("%c",SCCIn('B'));		/* Display it */
        Colonne++;
      }
      else					/* Go back top line */
      {
        Colonne = 1;
        printf("\n");
        printf("%c",SCCIn('B'));		/* Display it */
      }
    }
    Character = (unsigned char)Crawio(0xFF);	/* Test another key */
  }
  Super(OldPile);				/* Go back user mode */
  return(0);					/* Return code for the Shell */
}

