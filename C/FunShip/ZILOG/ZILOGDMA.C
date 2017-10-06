/*
 *
 *
 *		Programme d‚monstration DMA- Terminal entre deux machines
 *
 *		Ce programme transfŠre … 19200 Bits/Sec. en 8 Bits Parit‚ Paire
 *		1 bit de Stop.
 *
 *		Il opŠre en mode DMA l'‚mission et re‡oit sous interruptions.
 *
 *
 *		FunShip (c) 28 Avril 1995 - ATARI Falcon030
 *
 */
 
 
#include <stdio.h>
#include <tos.h>

/*
 *	Proc‚dure d'interruption
 */
 
extern	void ItSubRoutine(void);

#define	TRUE		1
#define	FALSE		0

#define	SCC_CONTROLA	0xFFFF8C81L		/* Registers Z85C30's addresses*/
#define	SCC_DATAA	0xFFFF8C83L		/* A Channel */
#define	SCC_CONTROLB	0xFFFF8C85L		/* B Channel */
#define	SCC_DATAB	0xFFFF8C87L

#define	DMAADR4		0xFFFF8C01L		/* Buffer DMA base addresse: MSB */
#define	DMAADR3		0xFFFF8C03L
#define	DMAADR2		0xFFFF8C05L
#define	DMAADR1		0xFFFF8C07L		/* Byte LSB of addresse */
#define	DMACOUNT4	0xFFFF8C09L		/* Number of bytes to transfered: MSB */
#define	DMACOUNT3	0xFFFF8C0BL
#define	DMACOUNT2	0xFFFF8C0DL
#define	DMACOUNT1	0xFFFF8C0FL		/* Byte LSB of bytes count */
#define	DMAREGISTERH	0xFFFF8C10L		/* Assembly register */
#define	DMAREGISTERL	0xFFFF8C12L
#define	DMACONTROL	0xFFFF8C14L		/* DMA Control register */

#define	IT_VECTOR	0x82			/* A free interrupt vector user */

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

void 	(*OldVector)();				/* Old It vector */
int	Echange;				/* to exchange datas with IT prg */

/*
 *		Primitives d'accŠs aux registres du ZILOG
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
 *	Primitives plus haut niveaux: Initialisation, Emission, Test et R‚ception
 */
 
void SCCInit(int Channel)
/*
	Initialize the chip in 19200 Bits/Sec, Parity Even, 1 Stop bit and 8 Bits Data
	No interrupts required.
*/
{
  SCCPut(Channel,0x00,WR3);			/* Receiver Off */
  SCCPut(Channel,0x00,WR5);			/* Transceiver Off */
  SCCPut(Channel,0xD4,WR1);			/* ITs and DMA mode */
  SCCPut(Channel,IT_VECTOR,WR2);		/* Interrupt Vector */
  SCCPut(Channel,0x47,WR4);			/* Async. 1 Stop parity Even and Clk/16 */
  SCCPut(Channel,0x08,WR9);			/* Enable interrupts */
  SCCPut(Channel,0x00,WR10);			/* NRZ Code mode -> RS232C */
  SCCPut(Channel,0x50,WR11);			/* RxClk = TxClk = BR */
  SCCPut(Channel,0x00,WR15);			/* No special interrupts */
  SCCPut(Channel,0xA3,WR14);			/* BR -> PCLK */
  SCCPut(Channel,0x0B,WR12);			/* Divide value LSB */
  SCCPut(Channel,0x00,WR13);			/* Divide value MSB => 19200 Bauds */

  OldVector = Setexc(IT_VECTOR,ItSubRoutine);  	/* Install new interrupt handler*/
  
  SCCPut(Channel,0xC1,WR3);			/* 8 Bits and enable receiver */
  SCCPut(Channel,0xE8,WR5);			/* 8 Bits and ebale transceiver */
}

void SCCStop(int Channel)
/*
	Disable the Zilog in receive and transmit mode. Delete our own It also.
*/
{
  SCCPut(Channel,0x00,WR3);			/* Receiver Off */
  SCCPut(Channel,0x00,WR5);			/* Transceiver Off */
  SCCPut(Channel,0x00,WR9);			/* no more ITs */  
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

void SCCDmaInit(void *Buffer, unsigned long Count)
/*
	
*/
{
/*
  printf("DMA: debut\n");
  *(int *)DMACONTROL 	|= 0x01;			/* Datas from memory to SCC */
  printf("DMA: Mem -> SCC ok\n");
  *(char *)DMAADR4	= (char)((long)Buffer >> 24);	/* Memory addresse */
  *(char *)DMAADR3	= (char)((long)Buffer >> 16);
  *(char *)DMAADR2	= (char)((long)Buffer >> 8);
  *(char *)DMAADR1	= (char) (long)Buffer;
  printf("DMA: Addresse ok\n");
  *(char *)DMACOUNT4	= (char)((long)Count >> 24);	/* Memory addresse */
  *(char *)DMACOUNT3	= (char)((long)Count >> 16);
  *(char *)DMACOUNT2	= (char)((long)Count >> 8);
  *(char *)DMACOUNT1	= (char) (long)Count;  
  printf("DMA: Count ok\n");
*/
  printf("%X\n",*(int *)DMACONTROL);			/* Datas from memory to SCC */
  printf("DMA: Mem -> SCC ok\n");
  printf("%X\n",*(char *)DMAADR4);	/* Memory addresse */
  printf("%X\n",*(char *)DMAADR3);
  printf("%X\n",*(char *)DMAADR2);
  printf("%X\n",*(char *)DMAADR1);
  printf("DMA: Addresse ok\n");
  printf("%X\n",*(char *)DMACOUNT4);	/* Memory addresse */
  printf("%X\n",*(char *)DMACOUNT3);
  printf("%X\n",*(char *)DMACOUNT2);
  printf("%X\n",*(char *)DMACOUNT1); 
}

void SCCDmaStart(void)
/*
	This procedure send datas in DMA mode.
*/
{
  *(int *)DMACONTROL	|= 0x03;  			/* Start DMA */
}

/*
 *	Programme principal de test
 */
 
int main(void)
{
  unsigned int	Character;
  int		*OldPile;
  int		Colonne;
  char		Buffer[4];
    
  printf("\033E");
  printf("\t\tZILOG Z85C30: Reception by Interrupt program\n");
  printf("\t\tPress ESC to exit\n");
  printf("\t\t============================================\n\n");

  printf("Z85C30 programmed at 19200 bits/s, Parity even, 1 Stop bit and 8 bits data\n");
  printf("On its B Channel\n\n");
  
  OldPile	= (int *)Super(0L);		/* Go to supervisor mode */

  SCCDmaInit(Buffer,4L);  
  SCCInit('B');					/* Initialize the Zilog */
  Colonne = 1;
  Echange = 0;
  Character = (unsigned char)Crawio(0xFF);	/* Reading a character */
  while(Character != 27)
  {
    if(Character != 0)				/* a key is pressed */
    {
      if(Colonne < 80)
        Colonne++;
      else					/* Go back top line */
      {
        Colonne = 1;
        printf("\n");
      }
      printf("%c",Character);
      Buffer[0] = Character;
      Buffer[1] = Character;
      Buffer[2] = Character;
      Buffer[3] = Character;
      printf("DMA mode starting\n");
/*      SCCDmaStart(); */
      printf("DMA send ending\n"); 
/*      SCCOut('B',Character);*/			/* Sending its ASCII code */
    }
    if(Echange != 0)				/* If a character is arrived */
    {
      if(Colonne < 80)
        Colonne++;
      else					/* Go back top line */
      {
        Colonne = 1;
        printf("\n");
      }
      printf("%c",Echange);			/* Display it */
      Echange = 0;
    }
    Character = (unsigned char)Crawio(0xFF);	/* Test another key */
  }
  SCCStop('B');					/* Stop channel B */

  Setexc(IT_VECTOR,OldVector);			/* Restore old IT Vector */
  Super(OldPile);				/* Go back user mode */
  return(0);					/* Return code for the Shell */
}

