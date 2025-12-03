/*---------------------------------------------------------------*/
/* Belegung der Bit's der einzelnen Register des WD Controllers  */
/* Leider nicht vollstÑndig, aber ausreichend..                  */
/*                                         Roe 11.09.1995        */
/*---------------------------------------------------------------*/

/*--- MSR Bitbelegungen -----------------------------------------*/
#define MSR_RST    0x80       /* 1 => reset                      */
#define MENB       0x40       /* 1 => memory enable              */
#define SA18       0x20       /* Diese Bits legen fest, wo       */
#define SA17       0x10       /* der shared Memory auf der       */
#define SA16       0x08       /* Karte liegen soll               */
#define SA15       0x04       /*                                 */
#define SA14       0x02       /*                                 */
#define SA13       0x01       /*                                 */

/*--- ICR Bitbelegungen -----------------------------------------*/
#define STR        0x80       /* EEPROM sprichern                */
#define RCL        0x40       /* IO Adresse aus EEPROM lesen     */
#define RX7        0x20       /*                                 */
#define RLA        0x10       /* LAN Addresse aus EEPROM lesen   */
#define MSZ        0x08       /* grîûe des shared mem's          */
#define DMAE       0x04       /* DMA Enable (583)                */
#define IR2        0x04       /* IRQ index MSB (584)             */
#define IOPE       0x02       /* I/O Port Enable (583)           */
#define OTHER      0x02       /* Other register access (584)     */
#define ICR_WTS    0x01       /* Word Transfer Select            */

/*--- BIO Bitbelegungen -----------------------------------------*/
#define RS1        0x80       /* BIOS size bit 1                 */
#define RS0        0x40       /* BIOS size bit 0                 */
#define BA18       0x20       /* BIOS ROM Memory Address Bits    */
#define BA17       0x10       /*                                 */
#define BA16       0x08       /*                                 */
#define BA15       0x04       /*                                 */
#define BA14       0x02       /* BIOS ROM Memory Address Bits    */
#define WINT       0x01       /* W8003 interrupt                 */

/*--- IRR Bitbelegungen -----------------------------------------*/
#define IEN        0x80       /* Interrupt Enable                */
#define IRB        0x40       /* Interrupt request bit 1         */
#define IRA        0x20       /* Interrupt request bit 0         */
#define AMD        0x10       /* Alternate mode                  */
#define AINT       0x08       /* Alternate interrupt             */
#define BW1        0x04       /* BIOS Wait State Control bit 1   */
#define BW0        0x02       /* BIOS Wait State Control bit 0   */
#define OWS        0x01       /* Zero Wait State Enable          */

/*--- CR Bitbelegungen ------------------------------------------*/
#define STP        0x01       /* stop; software reset            */
#define STA        0x02       /* start                           */
#define TXP        0x04       /* transmit packet                 */
#define ABR        0x20       /* Stop DMA                        */
#define PS0        0x00       /* register page select - 0        */
#define PS1        0x40       /* register page select - 1        */
#define PS2        0x80       /* register page select - 2        */

/*--- ISR Bitbelegungen -----------------------------------------*/
#define PRX        0x01       /* packet received no error        */
#define PTX        0x02       /* packet transmitted no error     */
#define RXE        0x04       /* receive error                   */
#define TXE        0x08       /* transmit error                  */
#define OVW        0x10       /* overwrite warning               */
#define CNT        0x20       /* counter overflow                */
#define RDC        0x40       /* remote DMA complete             */
#define ISR_RST    0x80       /* reset status                    */

/*-- IMR Bitbelegungen ------------------------------------------*/
#define PRXE       0x01       /* packet received interrupt enable  */
#define PTXE       0x02       /* packet transmitted interrupt enable*/
#define RXEE       0x04       /* receive error interrupt enable    */
#define TXEE       0x08       /* transmit error interrupt enable   */
#define OVWE       0x10       /* overwrite warning interrupt enable*/
#define CNTE       0x20       /* counter overflow interrupt enable */
#define RDCE       0x40       /* DMA complete interrupt enable     */

/*-- DCR Bitbelegungen ------------------------------------------*/
#define DCR_WTS    0x01       /* word transfer select            */
#define BOS        0x02       /* byte order select               */
#define LAS        0x04       /* long address select             */
#define BMS        0x08       /* burst DMA select                */
#define AINIT      0x10       /* autoinitialize remote           */

#define FTB2       0x00       /* receive FIFO threshold select - 2 bytes */
#define FTB4       0x20       /* receive FIFO threshold select - 4 bytes */
#define FTB8       0x40       /* receive FIFO threshold select - 8 bytes */
#define FTB12      0x60       /* receive FIFO threshold select - 12 bytes */

/*--- TCR Bitbelegungen -----------------------------------------*/
#define MCRC       0x01       /* manual crc generation           */
#define LB1        0x02       /* mode 1; internal loopback LPBK=0*/
#define LB2        0x04       /* mode 2; internal loopback LPBK=1*/
#define LB3        0x06       /* mode 3; internal loopback LPBK=0*/

#define ATD        0x08       /* auto transmit disable           */
#define OFST       0x10       /* collision offset enable         */

/*--- TSR Bitbelegungen -----------------------------------------*/
#define XMT        0x01       /* packet transmitted without error*/
#define COL        0x04       /* transmit collided               */
#define ABT        0x08       /* transmit aborted                */
#define CRS        0x10       /* carrier sense lost - xmit not aborted */
#define FU         0x20       /* FIFO underrun                   */
#define CDH        0x40       /* CD heartbeat                    */
#define OWC        0x80       /* out of window collision - xmit not aborted */

/*--- RCR Bitbelegungen -----------------------------------------*/
#define SEP        0x01       /* save error packets              */
#define AR         0x02       /* accept runt packet              */
#define AB         0x04       /* accept broadcast                */
#define AM         0x08       /* accept multicast                */
#define PRO        0x10       /* promiscuous physical            */
#define MON        0x20       /* monitor mode                    */

/*--- RSR Bitbelegungen -----------------------------------------*/
#define RCV        0x01       /* packet received intact          */
#define CRC        0x02       /* CRC error                       */
#define FAE        0x04       /* frame alignment error           */
#define FO         0x08       /* FIFO overrun                    */
#define MPA        0x10       /* missed packet                   */
#define PHY        0x20       /* physical/multicast address      */
#define DIS        0x40       /* receiver disable                */
#define DFR        0x80       /* deferring                       */


/*--- LAAR Bitbelegungen ----------------------------------------*/
#define MEM16ENB   0x80       /* Enables 16bit shrd RAM for host */
#define LAN16ENB   0x40       /* Enables 16bit shrd RAM for LAN  */
#define LA23       0x10       /* Adressen fÅr die Verwendung     */
#define LA22       0x08       /* von shared RAM oberhalb der 1MB */
#define LA21       0x04       /* Grenze (hier nicht verwendet)   */
#define LA20       0x02
#define LA19       0x01

typedef struct
  {
  unsigned long rambase;       /* RAM Basisadresse in PC ..       */
  unsigned long ramsize;       /* Laenge des Speichers            */
  unsigned char  eth_addr[6];  /* Boardadresse                    */
  unsigned char tspr_hold;     /* Merker fuer entspr Register     */
  unsigned char pstart_hold;   /* Merker fuer entspr Register     */
  unsigned char pstop_hold;    /* Merker fuer entspr Register     */
  unsigned char nextpacket;    /* Page des naechsten Paketes      */
  unsigned long vme_mem_base;  /* Basisadresse VME Ansteuerung    */
  unsigned short vekt;         /* Interruptvektornummer           */
  unsigned short level;        /* PriotitÑtslevel                 */
  } adapter_typ;
