//ICC-AVR application builder : 18.6.2005 20:00:44
// Target : M64
// Crystal: 16.000Mhz

#include <iom64v.h>
#include <macros.h>

void port_init(void)
{
 PORTA = 0x00;		// IDE_DATA_hi
 DDRA  = 0x00;
 
 PORTB = 0xC0;		// tu je reset, to musi byt vystup a k tomu aj v jednicke
 DDRB  = 0xC0;
 
 PORTC = 0x00; 		// ACSI data 
 DDRC  = 0x00;
 
 PORTD = 0xC0;		// ACSI control. PortD bits 6 & 7 (ACSI INT & DRQ) must be in H, or the FDD will not work!
 DDRD  = 0xC8;
 
 PORTE = 0x00;		// IDE control
 DDRE  = 0xFB;
 
 PORTF = 0x00; 		  // IDE_DATA_low
 DDRF  = 0x00;
 
 PORTG = 0x00;
 DDRG  = 0x00;
}

//UART1 initialize
// desired baud rate:19200
// actual baud rate:19231 (0.2%)
void uart1_init(void)
{
 UCSR1B = 0x00; //disable while setting baud rate
 UCSR1A = 0x00;
 UCSR1C = 0x06;
 UBRR1L = 0x33; //set baud rate lo
 UBRR1H = 0x00; //set baud rate hi
 UCSR1B = 0x18;
}

//TIMER2 initialize - prescale:1024
// WGM: Normal
// desired value: 1mSec
// actual value:  0.960mSec (4.0%)
void timer2_init(void)
{
 TCCR2 = 0x00; //stop
 TCNT2 = 0xF1; //setup
 OCR2  = 0x0F;
 TCCR2 = 0x05; //start
}

//call this routine to initialize all peripherals
void init_devices(void)
{
 //stop errant interrupts until set up
 CLI(); //disable all interrupts
 XDIV  = 0x00; //xtal divider
 XMCRA = 0x00; //external memory
 port_init();
 uart1_init();
 
 //timer2_init();

 MCUCR = 0x00;

// INT 1 on FALLING EDGE
// EICRA = 0x28; //extended ext ints

// INT 1 on LOW LEVEL
 EICRA = 0x00; //extended ext ints

 EICRB = 0x00; //extended ext ints
 EIMSK = 0x02;
 TIMSK = 0x40; //timer interrupt sources
 ETIMSK = 0x00; //extended timer interrupt sources
 
 ACSR |= (1<<7);		   // turn off analog comparator
 
// SEI(); //re-enable interrupts
//all peripherals are now initialized
}

