//-----------------------------------------
#define ACSI_ID	 1 			// this interface will respond to this ID

#define	SaveRegs()			asm("push R0\n" "push R2\n" "push R3\n" "push R24\n" "push R25\n" "push R30\n" "push R31\n")
#define	RestoreRegs()		asm("pop R31\n" "pop R30\n" "pop R25\n" "pop R24\n" "pop R3\n" "pop R2\n" "pop R0\n")
//-----------------------------------------
struct COMMAND
	   	{
//		unsigned Active:1, isICD:1, isSet:1, Proc:1; 	// bitfields	
		unsigned char Active, isICD,Proc; 		
		
		unsigned char count,					// count of bytes in command field
			          cmd[16],					// command field
					  lng;						// what lenght it should be
		};
		
typedef struct COMMAND CMND;

//-----------------------------------------

//void timer(void);
void Delay(char Time);

// this is because standart putchar puts on UART0 and we want UART1
int putchar(char c);

// this is because standart getchar gets from UART0 and we want UART1
int getchar(void);
int GetCharNoWait(void);			

// wait 1 ms
void OneMiliSecond(void);

// interupt 1 handler
//void int1_isr(void);
void int1_isr(unsigned int ACSIv);

// setup length of command and test if it's ICD command
void SetUpCmd(void);

// if we must process a command, then this will do it
void ProcessCmd(void);
//-----------------------------------------

