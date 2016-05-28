#define IDE_b_error	(1<<0)		// error bit in status register
#define IDE_b_DRQ	(1<<3)		// DRQ bit in status register
#define IDE_b_READY	(1<<6)		// READY bit in status register
#define IDE_b_BUSY	(1<<7)		// BUSY bit in status register

#define IDE_IsInput()	{DDRF = 0x00; DDRA = 0x00; PORTF=0xff; PORTA=0xff;}	// internal pull-up
#define IDE_IsOutput()	{DDRF = 0xff; DDRA = 0xff;}

//---------------------------------
// IDE addresses of registers 
#define IDE_R_sect		0x77
#define IDE_R_Cyl_L		0x4f
#define IDE_R_Cyl_H		0x6f
#define IDE_R_Head		0x5f

#define IDE_R_LBA_L		0x77
#define IDE_R_LBA_ML	0x4f
#define IDE_R_LBA_MH	0x6f
#define IDE_R_LBA_H		0x5f

#define IDE_R_sect_cnt	0x57
#define IDE_R_command	0x7f
#define IDE_R_data		0x47

//--------------------------------------------------
struct Param
	   	{
		unsigned char Present, LBAsupport, Ready, DoFormat;				
		
		char SecPerTrack_L,
			 SecPerTrack_H,
			 
			 NumOfHeads_L,
			 NumOfHeads_H,
			 
			 NumOfCyls_L,
			 NumOfCyls_H,
			 
			 LBACapacity_L,
			 LBACapacity_ML,
			 LBACapacity_MH,
			 LBACapacity_H;

		unsigned char FrmtProg_L,
				 	  FrmtProg_H; 			 
			 
		char model[40];
		};
		
typedef struct Param DriveParams;
//DriveParams Master,Slave;

//--------------------------------------------------
void ShortPause(void);

// put one byte on IDE bus
void IDE_putB(char what); 

// put one word on IDE bus
void IDE_putW(char Hi, char Lo);

// get one byte from IDE bus
char IDE_getB(void);

// get two bytes from IDE bus
//void IDE_getW(char *where);

//---------------------------------
// THESE TWO FUNCTIONS MUST BE USED TOGETHER IN THIS ORDER!!!!
// Get IDE word, LOW byte
char IDE_getWlo(void);

// Get IDE word, HI byte
char IDE_getWHi(void);
//---------------------------------
// get the error from the IDE device
char IDE_getError(void);

// wait until the DRQ bit goes high
char IDE_waitForDRQ(void);

// wait until device gets ready 
void IDE_waitForReady(char ForMaster);

// set active drive. if mast!=0 - master, else slave
void IDE_SetActive(char mast);

// get the drive parameters in its structure
char IDE_GetDriveParams(char ForMaster);

// SET the drive parameters from its structure
char IDE_InitDriveParams(char ForMaster);

void IDE_Reset(void);
void IDE_DoReset(void);

//----------------------------------------------------------------------------- 
// Input : LBA Address of sector in adr_H, _MH, _ML, _L
// Output: CHS address of sectof in Out->SecPerTrack_L, Out->NumOfHeads_L, Out->NumOfCyls_L
void LBAtoCHS(char adr_H, char adr_MH, char adr_ML, char adr_L,
	 		  DriveParams *Out,
	 		  char ForMaster);
//----------------------------------------------------------------------------- 
// test that if the wanted sector if in range of the drive
char IDE_SectorIsInRange(char FromMaster, char adr_H, char adr_MH, char adr_ML, char adr_L);
//---------------------------------

