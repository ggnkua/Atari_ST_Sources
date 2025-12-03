#include <stdio.h>
#include <string.h>
#include <tos.h>

void debug_str(char *str);

void pfcopy(unsigned char* dest,unsigned char* src,short anz);

#include "..\include\lan.h"
#include "..\include\wd.h"
#include "..\include\driver.h"
#include "..\include\fifo.h"

adapter_typ ds;         /* Speicher fuer Adapterparameter         */

extern PROTOCOL protos[MAXPROTOCOLS];  /* protocols to serve */
extern int protocols ;              /* number of active protocols */
extern ff_typ ff_free;  				      /* queue of free packets */
extern et_stat statistics;                   /* Statistik             */

unsigned char *wd_reg00,*wd_reg01,*wd_reg02,*wd_reg03,*wd_reg04,*wd_reg05,*wd_reg06,*wd_reg07;
unsigned char *wd_reg08,*wd_reg09,*wd_reg0a,*wd_reg0b,*wd_reg0c,*wd_reg0d,*wd_reg0e,*wd_reg0f;
unsigned char *wd_reg10,*wd_reg11,*wd_reg12,*wd_reg13,*wd_reg14,*wd_reg15,*wd_reg16,*wd_reg17;
unsigned char *wd_reg18,*wd_reg19,*wd_reg1a,*wd_reg1b,*wd_reg1c,*wd_reg1d,*wd_reg1e,*wd_reg1f;

#define REG_MSR  (*wd_reg00)
#define REG_ICR  (*wd_reg01)        /* interface configuration register */
#define REG_IAR  (*wd_reg02)        /* io address register */
#define REG_BIO  (*wd_reg03)        /* bios ROM address register */
#define REG_IRR  (*wd_reg04)        /* interrupt request register */
#define REG_GP1  (*wd_reg05)        /* general purpose register 1 */
#define REG_IOD  (*wd_reg06)        /* io data latch */
#define REG_GP2  (*wd_reg07)        /* general purpose register 2 */

#define REG_REG_0 (*wd_reg00)
#define REG_REG_1 (*wd_reg01)
#define REG_REG_2 (*wd_reg02)
#define REG_REG_3 (*wd_reg03)
#define REG_REG_4 (*wd_reg04)
#define REG_REG_5 (*wd_reg05)
#define REG_REG_6 (*wd_reg06)
#define REG_REG_7 (*wd_reg07)

#define REG_LAN_ADDR_0 (*wd_reg08)
#define REG_LAN_ADDR_1 (*wd_reg09)
#define REG_LAN_ADDR_2 (*wd_reg0a)
#define REG_LAN_ADDR_3 (*wd_reg0b)
#define REG_LAN_ADDR_4 (*wd_reg0c)
#define REG_LAN_ADDR_5 (*wd_reg0d)
#define REG_LAN_TYPE_BYTE (*wd_reg0e)
#define REG_CHCKSM_BYTE (*wd_reg0f)

#define REG_CR     (*wd_reg10)        /* Command Register    */
#define REG_CLDA0  (*wd_reg11)        /* Current Local DMA Address 0 */
#define REG_CLDA1  (*wd_reg12)        /* Current Local DMA Address 1 */
#define REG_BNRY   (*wd_reg13)        /* Boundary Pointer */
#define REG_TSR    (*wd_reg14)        /* Transmit Status Register */
#define REG_NCR    (*wd_reg15)        /* Number of Collisions Register */
#define REG_FIFO   (*wd_reg16)        /* FIFO */
#define REG_ISR    (*wd_reg17)        /* Interrupt Status Register */
#define REG_CRDA0  (*wd_reg18)        /* Current Remote DMA Address 0 */
#define REG_CRDA1  (*wd_reg19)        /* Current Remote DMA Address 1 */
/* OFF_8390+0x0A is reserved */
/* OFF_8390+0x0B is reserved */
#define REG_RSR    (*wd_reg1c)        /* Receive Status Register */
#define REG_CNTR0  (*wd_reg1d)        /* Frame Alignment Errors */
#define REG_CNTR1  (*wd_reg1e)        /* CRC Errors */
#define REG_CNTR2  (*wd_reg1f)        /* Missed Packet Errors */

/*-- page 0, wr --*/
/*    CR    OFF_8390+0x00           Command Register    */
#define REG_PSTART (*wd_reg11)        /* Page Start Register */
#define REG_PSTOP  (*wd_reg12)        /* Page Stop Register */
/*    BNDY    OFF_8390+0x03           Boundary Pointer    */
#define REG_TPSR   (*wd_reg14)        /* Transmit Page Start Register */
#define REG_TBCR0  (*wd_reg15)        /* Transmit Byte Count Register 0*/
#define REG_TBCR1  (*wd_reg16)        /* Transmit Byte Count Register 1*/
/*    ISR    OFF_8390+0x07           Interrupt Status Register    */
#define REG_RSAR0  (*wd_reg18)        /* Remote Start Address Register 0 */
#define REG_RSAR1  (*wd_reg19)        /* Remote Start Address Register 1 */
#define REG_RBCR0  (*wd_reg1a)        /* Remote Byte Count Register 0 */
#define REG_RBCR1  (*wd_reg1b)        /* Remote Byte Count Register 1 */
#define REG_RCR    (*wd_reg1c)        /* Receive Configuration Register */
#define REG_TCR    (*wd_reg1d)        /* Transmit Configuration Register */
#define REG_DCR    (*wd_reg1e)        /* Data Configuration Register */
#define REG_IMR    (*wd_reg1f)        /* Interrupt Mask Register */

/*-- page 1, rd and wr */
/*    CR    OFF_8390+0x00           Control Register    */
#define REG_PAR0   (*wd_reg11)        /* Physical Address Register 0 */
#define REG_PAR1   (*wd_reg12)        /*                 1 */
#define REG_PAR2   (*wd_reg13)        /*                 2 */
#define REG_PAR3   (*wd_reg14)        /*                 3 */
#define REG_PAR4   (*wd_reg15)        /*                 4 */
#define REG_PAR5   (*wd_reg16)        /*                 5 */
#define REG_CURR   (*wd_reg17)        /* Current Page Register */
#define REG_MAR0   (*wd_reg18)  /* Multicast Address Register 0 NA 83C690   */
#define REG_MAR1   (*wd_reg19)        /*  NA for 83C690   1 */
#define REG_MAR2   (*wd_reg1a)        /*  NA for 83C690   2 */
#define REG_MAR3   (*wd_reg1b)        /*  NA for 83C690   3 */
#define REG_MAR4   (*wd_reg1c)        /*  NA for 83C690   4 */
#define REG_MAR5   (*wd_reg1d)        /*  NA for 83C690   5 */
#define REG_MAR6   (*wd_reg1e)        /*  NA for 83C690   6 */
#define REG_MAR7   (*wd_reg1f)        /*  NA for 83C690   7 */

#define REG_BSR    (*wd_reg01)        /*  Bus size Register */
#define REG_LAAR   (*wd_reg05)        /*  LA Adress Register */

/*-------------------------------------------------------------------*/
/* using the current baseio, this will enable the ram on the adapter */
/* to the current rambase.                                           */
/*-------------------------------------------------------------------*/
void wd_enable_ram(unsigned long rambase)
{
unsigned char   temp;
short           i;

REG_MSR = MSR_RST;
for (i = 0; i < 4000; i++);

REG_MSR = ~(MSR_RST | MENB);
for (i = 0; i < 4000; i++);

temp = (unsigned char)( (rambase & 0x7ffffL) >> 13);        /* encode the register bits */

REG_MSR = ((temp & ~MSR_RST) | MENB); /* load adrs and enable */

REG_LAAR = MEM16ENB | LAN16ENB | (unsigned char)(rambase  >>19);
}

/*----------------------------------------------------------------*/
/*  6 Byte Ethernetadresse lesen                                  */
/*----------------------------------------------------------------*/
void  wd_get_lan_addr(unsigned char *eth_addr)
{
eth_addr[0] = REG_LAN_ADDR_0;
eth_addr[1] = REG_LAN_ADDR_1;
eth_addr[2] = REG_LAN_ADDR_2;
eth_addr[3] = REG_LAN_ADDR_3;
eth_addr[4] = REG_LAN_ADDR_4;
eth_addr[5] = REG_LAN_ADDR_5;
}

/*----------------------------------------------------------------*/
/*  6 Byte Ethernetadresse einstellen                             */
/*----------------------------------------------------------------*/
void  wd_set_lan_addr(unsigned char *eth_addr)
{
REG_LAN_ADDR_0 = eth_addr[0];
REG_PAR0 = eth_addr[0];
REG_LAN_ADDR_1 = eth_addr[1];
REG_PAR1 = eth_addr[1];
REG_LAN_ADDR_2 = eth_addr[2];
REG_PAR2 = eth_addr[2];
REG_LAN_ADDR_3 = eth_addr[3];
REG_PAR3 = eth_addr[3];
REG_LAN_ADDR_4 = eth_addr[4];
REG_PAR4 = eth_addr[4];
REG_LAN_ADDR_5 = eth_addr[5];
REG_PAR5 = eth_addr[5];
}

/*----------------------------------------------------------------*/
/*  Initialisieren der Karte                                      */
/*----------------------------------------------------------------*/
short wd_reset(void)
{
long    count;

REG_CR = STP|ABR|PS0; /* soft reset and page 0 */
count = 0;   /* wait for reset to finish */
while ((!(REG_ISR & ISR_RST)) && (count < 20000L))
 count++;
if(count < 20000L)
  return 1;
return 0;
}

/*----------------------------------------------------------------*/
/*  Funktionen fuer den Betrieb                                   */
/*  Globals Struktur ds enthaelt die Betriebsparameter            */
/*----------------------------------------------------------------*/
void wd_init_chip(void)
{
unsigned char    temp_cr;
unsigned char    temp_rcr;

ds.tspr_hold = 0;                /* transmit page start hold */
ds.pstart_hold = 0x08;                /* receive page start hold */

REG_CR = STP|ABR|PS0;	/* soft reset and page 0 */

wd_reset();

REG_DCR = 0x40 |DCR_WTS;  /* FIFO Tiefe                  */

REG_RBCR0 = 0;                /* clear remote byte count */
REG_RBCR1 = 0;
REG_RCR = AB|AM;                /* rcv only good pkts  */
REG_TCR = LB1;                /* normal operation */
REG_PSTART = ds.pstart_hold;        /* rcv ring strts 2k into RAM */
ds.pstop_hold = ((ds.ramsize >> 8) & 0x00FF);        /* rcv page stop hold */
REG_PSTOP = ds.pstop_hold;        /* stop at last RAM loc */
REG_BNRY = ds.pstart_hold;        /* init to = PSTART */
REG_ISR = 0xFF;                /* clear all int status bits */
REG_IMR = 0;                        /* no interrupts yet */
REG_CR = STP|ABR|PS1;                /* maintain rst | sel page 1 */

REG_PAR0 = ds.eth_addr[0];
REG_MAR0 = 0;
REG_PAR1 = ds.eth_addr[1];
REG_MAR1 = 0;
REG_PAR2 = ds.eth_addr[2];
REG_MAR2 = 0;
REG_PAR3 = ds.eth_addr[3];
REG_MAR3 = 0;
REG_PAR4 = ds.eth_addr[4];
REG_MAR4 = 0;
REG_PAR5 = ds.eth_addr[5];
REG_MAR5 = 0;
REG_MAR6 = 0;                /* there are more MAR's */
REG_MAR7 = 0;                        /*   than PAR's */

temp_cr = REG_CR & ~TXP;                /* save old CR contents */
REG_CR = (temp_cr & 0x3F) | PS2;        /* select page 2 */
temp_rcr = REG_RCR;
REG_CR = temp_cr & 0x3F;                /* select page 0 */
REG_RCR = temp_rcr & ~AM;                /* disable multicast rcv */
REG_CR = (temp_cr & 0x3F) | PS1;        /* select page 1 */
REG_MAR4 = 0;                        /* reset multicast hash bit */
REG_CR = temp_cr;                        /* restore original CR */

ds.nextpacket = ds.pstart_hold + 1;        /* internal next pkt pointer */
REG_CURR = ds.nextpacket;
REG_CR = STA|PS0|ABR;                /* start NIC | select page 0 */
REG_TCR = 0;                        /* allow receiving pkts */

REG_IMR = PRXE|PTXE|RXEE|TXEE|OVWE; /* our interrupts */

REG_IRR = OWS;
REG_REG_5 = 0x80;    /* Ethecard plus braucht das so !  */
REG_REG_6 = 0x01;
}


/*----------------------------------------------------------------*/
/*  aktuellen Pufferzeiger holen                                  */
/*  gibt den Inhalt des CURR registers auf PAGE 1 zurueck         */
/*----------------------------------------------------------------*/
unsigned char wd_get_curr(void)
{
unsigned char              tmp_cr;
unsigned char              ret_val;

tmp_cr = REG_CR;                        /* get current CR value    */
REG_CR = tmp_cr | PS1;                  /* select page 1 registers */
ret_val = REG_CURR;                     /* read CURR value         */
REG_CR = tmp_cr;                        /* return to original value*/
return ret_val;                         /* and show CURR to caller */
}

short send_iack=1;                   /* Ruhezustand = sendebereit  */

/*----------------------------------------------------------------*/
/*  Interrupt wird von wdasm.s aufgerufen                         */
/*----------------------------------------------------------------*/
void wd_interrupt(void)
{
unsigned char isr;
unsigned short type;
lan_buffer_typ    *pkt;
short    recsize;
int      prot;
unsigned long    addr;
unsigned long    limit;
unsigned long    pos;

statistics.st_intr++;

isr = REG_ISR;                         /* Interrupt Status einlesen*/
if(isr & (PTX | TXE))                  /* senderinterrupt          */
  {
  send_iack=1;
  REG_ISR =PTX | TXE;                  /* Int loeschen durch beschreiben */
  }
if(isr & (PRX | RXE))
  {
  do
    {
    addr = (ds.rambase + (ds.nextpacket << 8));  /* Adresse des Paketes im Mem*/

    recsize = ((*(unsigned char*)(ds.vme_mem_base+addr+3)) << 8) + *((unsigned char*)(ds.vme_mem_base+addr+2)) -4;
    type = ((*(unsigned char*)(ds.vme_mem_base+addr+16)) << 8) + *(unsigned char*)(ds.vme_mem_base+addr+17);

    if(recsize < 0 || recsize > 1600)
      {
      REG_ISR = PRX | RXE;    /* Int loeschen durch beschreiben */
      statistics.st_err++;
      return;
      }

    limit = ds.rambase + (ds.pstop_hold << 8); /* erstes ungueltiges Byte */
    pos = addr+4;                                /* Start des Datenbereiches */

    statistics.st_received++;

    for(prot = 0;prot < MAXPROTOCOLS; prot++)
      {
      if(protos[prot].type == type)
        {
             /* must have one packet free */
        if((pkt = pkt_ff_get(&ff_free)) != NULL)
          {
          if( pos + recsize  > limit )         
            {
            pfcopy((unsigned char*)pkt,(unsigned char *)(ds.vme_mem_base + pos),limit-pos+1);
            pfcopy((unsigned char*)( (long)pkt+(limit-pos) ),(unsigned char *)(ds.vme_mem_base + ds.rambase + (ds.pstart_hold << 8)),recsize - (limit-pos)+1);
            }
          else
            pfcopy((unsigned char*)pkt,(unsigned char*)(ds.vme_mem_base+pos),recsize);

          if(protos[prot].handler)
            { 
            if(protos[prot].handler(recsize,pkt))
              {
              statistics.st_got++;
              protos[prot].recvd++;
              }
            }
          else
            pkt_ff_put(&ff_free,pkt);
          }
        }
      }
    
    ds.nextpacket = *(unsigned char*)(ds.vme_mem_base+addr+1);

    REG_BNRY = ds.nextpacket;   /* aktuelles Paket freigeben    */
                                /* Naechstes Paket geht dorthin           */
    } while(ds.nextpacket != wd_get_curr());
  REG_ISR = PRX | RXE;           /* Int loeschen durch beschreiben */
  }
if(isr & OVWE)
  {
  REG_CR = STP|ABR|PS0;		/* soft reset and page 0 */
  REG_RBCR0 = 0;		/* clear remote byte count */
  REG_RBCR1 = 0;
  wd_reset();
  REG_TCR = LB1;		/* keep in loopback mode */
  REG_CR = STA | ABR;		/* restart it */

  ds.nextpacket = wd_get_curr();
  REG_BNRY = ds.nextpacket;   /* aktuelles Paket freigeben    */

  REG_TCR = 0;			/* out of lpbk...buffer packets */
  send_iack = 1;
 
  REG_ISR = OVWE;               /* Overwrite Int loeschen        */
  }
}



/*----------------------------------------------------------------*/
/*  Paket senden                                                  */
/*  Wenn nicht sendebereit : return = FALSE                       */
/* to = Zeiger auf 6 Byte Ethernetadresse                         */
/* len = nutzdatenlaenge                                          */
/*----------------------------------------------------------------*/
int wd_send(unsigned char *buffer,unsigned short len)
{
long	wait;

wait = 0;
while(!send_iack && wait++ < 10000L);  			/* warte bis sendeerlaubnis       */
send_iack = 0;

if(len > 1540) len = 1540;      /* MTU fuer Ethernet              */
if(len < 64) len = 64;          /* kleinstes erlaubtes Paket      */

pfcopy((unsigned char*)(ds.vme_mem_base + (long)(ds.rambase)),buffer,len+8);
/*
memcpy((unsigned char*)(ds.vme_mem_base + (long)(ds.rambase)),buffer,len+8);
*/

REG_CR = ABR|STA;               /* select page 0     */
REG_TPSR = ds.tspr_hold;        /* xmit pg strt at 0 of RAM */
REG_TBCR1 = (unsigned char)((len >> 8)& 0xFF); /* upper byte of count */
REG_TBCR0 = (unsigned char)(len & 0xff);    /* lower byte of count */
REG_CR = TXP|ABR|STA;            /* start transmission */
statistics.st_sent++;
return len;
}

/*----------------------------------------------------------------*/
/*  Ramtest                                                       */
/*----------------------------------------------------------------*/
long ramtest(long ram,long len)
{
long	i,j;
long    error=0;
unsigned short zykl;

for(j=0;j<5;j++)
  {
  zykl = j;
  for(i=0;i<len;i++)
    {
    *(unsigned char*)(ram+i) = (zykl++ & 0xFF);
    if(zykl >= 253)
      zykl = 0;
    }
  zykl = j;
  for(i=0;i<len;i++)
    {
    if(*(unsigned char*)(ram+i) != (zykl++ & 0xFF))
      error++;
    if(zykl >= 253)
      zykl = 0;
    } 
  }
return error;
}

/*----------------------------------------------------------------*/
/* 16 bit Ramtest                                                 */
/*----------------------------------------------------------------*/
long bit16_ramtest(long ram,long len)
{
long	i,j;
long    error=0;
unsigned short zykl;

for(j=0;j<5;j++)
  {
  zykl = j;
  for(i=0;i<len/2;i++)
    *(unsigned short*)(ram+i*2) = (zykl++) *3;
  zykl = j;
  for(i=0;i<len/2;i++)
    if(*(unsigned short*)(ram+i*2) != (zykl++) *3 )
      error++;
  }
return error;
}

/*----------------------------------------------------------------*/
/* 32 bit Ramtest                                                 */
/*----------------------------------------------------------------*/
long bit32_ramtest(long ram,long len)
{
long	i,j,k;
long    error=0;
unsigned short zykl;

for(j=0;j<5;j++)
  {
  zykl = j;
  for(i=0;i<len/4;i++)
    *(unsigned long*)(ram+i*4) = (zykl++) *143L;

  for(k=0;k<10;k++)
    {
    zykl = j;
    for(i=0;i<len/4;i++)
      if(*(unsigned long*)(ram+i*4) != (zykl++) *143L )
        error++;
    }
  }
return error;
}

extern long install_vekt(void);
extern long deinstall_vekt(void);
extern long vekt_address;
extern long vekt_level;

/*----------------------------------------------------------------*/
/*  Initialisierung                                               */
/*----------------------------------------------------------------*/
int  wd_init(void)
{
long i;
short erg;
FILE *fil;
unsigned char	addr[10];
char	str[100];

			/* vorbelegen auf Werte fuer TT           */
ds.vme_mem_base = 0xFE000000L;
ds.rambase = 0xD0000L;
ds.vekt = 0xAA;
ds.level = 4;

wd_reg00 = (unsigned char*)0xFE200280L;wd_reg01 = (unsigned char*)0xFE300280L;
wd_reg02 = (unsigned char*)0xFE200282L;wd_reg03 = (unsigned char*)0xFE300282L;
wd_reg04 = (unsigned char*)0xFE200284L;wd_reg05 = (unsigned char*)0xFE300284L;
wd_reg06 = (unsigned char*)0xFE200286L;wd_reg07 = (unsigned char*)0xFE300286L;
wd_reg08 = (unsigned char*)0xFE200288L;wd_reg09 = (unsigned char*)0xFE300288L;
wd_reg0a = (unsigned char*)0xFE20028aL;wd_reg0b = (unsigned char*)0xFE30028aL;
wd_reg0c = (unsigned char*)0xFE20028cL;wd_reg0d = (unsigned char*)0xFE30028cL;
wd_reg0e = (unsigned char*)0xFE20028eL;wd_reg0f = (unsigned char*)0xFE30028eL;

wd_reg10 = (unsigned char*)0xFE200290L;wd_reg11 = (unsigned char*)0xFE300290L;
wd_reg12 = (unsigned char*)0xFE200292L;wd_reg13 = (unsigned char*)0xFE300292L;
wd_reg14 = (unsigned char*)0xFE200294L;wd_reg15 = (unsigned char*)0xFE300294L;
wd_reg16 = (unsigned char*)0xFE200296L;wd_reg17 = (unsigned char*)0xFE300296L;
wd_reg18 = (unsigned char*)0xFE200298L;wd_reg19 = (unsigned char*)0xFE300298L;
wd_reg1a = (unsigned char*)0xFE20029aL;wd_reg1b = (unsigned char*)0xFE30029aL;
wd_reg1c = (unsigned char*)0xFE20029cL;wd_reg1d = (unsigned char*)0xFE30029cL;
wd_reg1e = (unsigned char*)0xFE20029eL;wd_reg1f = (unsigned char*)0xFE30029eL;

if((fil = fopen("smclance.inf","r")) != NULL)
  {
  fscanf(fil,"%lx %lx %hx %lx %hx %hd\n",
         &ds.vme_mem_base,
         &ds.rambase,
         &ds.vekt,
         &ds.level );
  fscanf(fil,"%lx %lx %lx %lx %lx %lx %lx %lx\n",&wd_reg00,&wd_reg01,&wd_reg02,&wd_reg03,&wd_reg04,&wd_reg05,&wd_reg06,&wd_reg07);
  fscanf(fil,"%lx %lx %lx %lx %lx %lx %lx %lx\n",&wd_reg08,&wd_reg09,&wd_reg0a,&wd_reg0b,&wd_reg0c,&wd_reg0d,&wd_reg0e,&wd_reg0f);
  fscanf(fil,"%lx %lx %lx %lx %lx %lx %lx %lx\n",&wd_reg10,&wd_reg11,&wd_reg12,&wd_reg13,&wd_reg14,&wd_reg15,&wd_reg16,&wd_reg17);
  fscanf(fil,"%lx %lx %lx %lx %lx %lx %lx %lx\n",&wd_reg18,&wd_reg19,&wd_reg1a,&wd_reg1b,&wd_reg1c,&wd_reg1d,&wd_reg1e,&wd_reg1f);
  fclose(fil);
  }
else
  {
  sprintf(str,"kann smclance.inf nicht oeffnen -> nehme Standartwerte\n");  
  debug_str(str);
  }

debug_str("");
sprintf(str,"vme MEM Base   : %lx",ds.vme_mem_base);debug_str(str);
sprintf(str,"PC RAM address : %lx",ds.rambase);debug_str(str);
sprintf(str,"INT Vektor     : %hx",ds.vekt);debug_str(str);
sprintf(str,"INT Vektor addr: %hx",ds.vekt << 2);debug_str(str);
sprintf(str,"INT Level      : %hd",ds.level);debug_str(str);
sprintf(str,"WD Register    : %08lX, %08lX, %08lX, %08lX ... %08lX, %08lX",wd_reg00,wd_reg01,wd_reg02,wd_reg03,wd_reg1e,wd_reg1f);debug_str(str);


vekt_address = (long)ds.vekt << 2;  /* Adresse des Vektors  */
vekt_level = (long)ds.level;        /* Interruptlevel       */
Supexec(install_vekt);

ds.ramsize = 0x4000L;  /* 16 K */

wd_get_lan_addr(ds.eth_addr);   /* wird bei wd_init gesetzt in Physical adress */
wd_get_lan_addr(addr);
sprintf(str,"Adresse        : %02X %02X %02X %02X %02X %02X\n",addr[0],addr[1],addr[2],addr[3],addr[4],addr[5]);debug_str(str);

wd_enable_ram(ds.rambase); 

erg = wd_reset();
if(!erg)
  {
  debug_str("Fehler beim WD Reset");
  return -1;
  }

wd_init_chip();
debug_str("----------------------------");

				/* einige werte schreiben und lesen, um Interface zu aktivieren */
erg =  *(unsigned char*)(ds.vme_mem_base + ds.rambase);
*(unsigned char*)(ds.vme_mem_base + ds.rambase) = erg;
erg =  *(unsigned short*)(ds.vme_mem_base + ds.rambase);
*(unsigned short*)(ds.vme_mem_base + ds.rambase) = erg;

debug_str("starte Ramtest ...");
i = ramtest(ds.rambase+ds.vme_mem_base,ds.ramsize);
if(i)
  {
  sprintf(str,"           %lx Fehler",i);debug_str(str);
/*  return -1; */
  }
else
  debug_str(" OK");

debug_str("starte 16 Bit Ramtest ...");
i = bit16_ramtest(ds.rambase+ds.vme_mem_base,ds.ramsize);
if(i)
  {
  sprintf(str,"           %lx Fehler",i);debug_str(str);
/*  return -1; */
  }
else
  debug_str(" OK");

debug_str("starte long Ramtest (grndlich) ...");
i = bit32_ramtest(ds.rambase+ds.vme_mem_base,ds.ramsize);
if(i)
  {
  sprintf(str,"           %lx Fehler",i);debug_str(str);
/*  return -1; */
  }
else
  debug_str(" OK");

for(i=0;i<ds.ramsize;i++)
  *(unsigned char*)(ds.vme_mem_base + ds.rambase +i) = 0;
return 0;
}

/*----------------------------------------------------------------*/
/*  Initialisierung                                               */
/*----------------------------------------------------------------*/
void  wd_deinit(void)
{
Supexec(deinstall_vekt);
}
