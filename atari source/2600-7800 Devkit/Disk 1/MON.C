#include <osbind.h>
#include <stdio.h>

/* Multi-Function Port	*/
/* #define INT_MASK	*((char *) 0xFFFA15)	/* Interrupt Mask B	*/
/* #define INT_PENDING	*((char *) 0xFFFA0D)	/* Interrupt pending B	*/
/* #define INT_ENABLE	*((char *) 0xFFFA09)	/* Interrupt Enable B	*/

/* Parallel Port - On Programmable Sound Generator Chip			*/
#define W_PORTB		0x8F			/* Write Port B		*/
#define R_PORTB		0x0F			/* Read Port B		*/
#define W_DIR		0x87		/* Write Direction Register	*/
#define R_DIR		0x07		/* Read Direction Register	*/
#define	IN		0		/*  7800->ST			*/
#define OUT		1		/*  ST->7800			*/

extern int main1();
char *INT_MASK,*INT_PENDING,*INT_ENABLE;

main()
{
	Supexec(main1);
}

main1()
{
	int temp;

	init();
/*	while (1) {
		command=get_int();
*/
}

get_int()
{
	int sum;
	char c;

	while ((c = getchar()) != '\r')
		sum=(sum*10)+(c-'0');
	return(sum);
}

init()
{
	char temp;

	INT_MASK=    0xFFFA15;
	INT_PENDING= 0xFFFA0D;
	INT_ENABLE=  0xFFFA09;
	printf ("*INT_mask=%x\n",*INT_MASK);
	*INT_MASK = *INT_MASK & 0xFE;	/* Mask off bsy interrupt	*/
	*INT_ENABLE = *INT_ENABLE | 0x01;	/* Allow the interrupt	*/
	port_direction(OUT);
	my_write(0xF0);				/* Set force line	*/
	my_write(0xD0);				/* Drop reset low	*/
	my_write(0xF0);				/* Raise reset		*/
	my_write(0xE0);				/* Reset force line	*/
	port_direction(OUT);		/* ST->7800			*/
}

port_direction(dir)	/* Set direction for parallel port & 7800	*/
int dir;		/* interface port.  0=7800->ST; 1=ST->7800	*/
{
	if (dir) {
		Giaccess((Giaccess(0,R_DIR) | 0x80),W_DIR); /* Parallel	*/
		my_write(0xE0);		/* 7800 Port : b7=1		*/
	} else {
		Giaccess((Giaccess(0,R_DIR) & 0x7F),W_DIR); /* Parallel	*/
		my_write(0x60);		/* 7800 Port : b7=0		*/
	}
}

my_write(data)	/* Lowest-level write, does not handshake		*/
int data;
{
	Giaccess(data,W_PORTB);	/*	 Write it out to the port	*/
	Offgibit(5);		/* Latch data in by dropping strobe lo	*/
	delay(100);		/* Delay a bit to let the 6502 catch up	*/
	Ongibit(5);		/* Reset strobe hi			*/
}

readdata()
{
	int data;
	long timeout=500000;

	port_direction(IN);			/* 7800->ST		*/
	printf("*INT_pending=%x\n",*INT_PENDING);
	while ((!(*INT_PENDING & 0x01)) && (timeout))  /* Wait for data	*/
		timeout--;
	if (! timeout) {
		printf ("It's dead, Thom\n");
		data=0x80;			/* Flag it as an error	*/
	} else {
		printf("*INT_pending=%x\n",*INT_PENDING);
		*INT_PENDING = *INT_PENDING & 0xFE; /* Clr interrupt	*/
		data=Giaccess(0,0x0F) & 0x0F;	/* Get data		*/
		port_direction(OUT);		/* ST->7800		*/
		my_write(0x60);			/* Ack read by strobing	*/
	}
	return(data);
}

delay(count)	/* Very rudimentary wait routine			*/
int count;
{
	for (count=count;count--;count>=0)
		;
}
