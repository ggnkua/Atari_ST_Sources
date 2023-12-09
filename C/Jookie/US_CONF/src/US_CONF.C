/*--------------------------------------------------*/
#include <stdio.h>
#include <conio.h>
#include <screen.h>
#include <string.h>
#include <stdlib.h>
#include <graphics.h>
#include <aes.h>

#include "dma.h"
#include "system.h"
/*--------------------------------------------------*/
#define BYTE  unsigned char
#define WORD  unsigned int
#define DWORD unsigned long int

/* -------------------------------------- */
 struct mfp_chip {
                  char reg[48]; /* MFP registers are on odd bytes */
                 } ;
/* -------------------------------------- */
typedef long (*func)();         /* pointer to function returning a long */

/* Logical Drive Info */
struct hd_drv {
            short dev_addr;     /* physical unit ASCI address */
            long  part_start;   /* start sector logical unit */
               } ;
/*--------------------------------------------------*/
typedef struct 
  {
    BYTE boot;
    BYTE isPresent;
    char name[64];
    
    BYTE Editing;
  } TFirmWare;
/*--------------------------------------------------*/
typedef struct 
  {
    char  name[64];
    BYTE  id;
    
    BYTE  idEditing;
  } TDevice;
/*--------------------------------------------------*/
typedef struct 
  {
    BYTE  BootFWnumber;
    BYTE  BootAlwaysBaseFW;
    BYTE  DeviceID[2];
  } TConfiguration;
/*--------------------------------------------------*/
void DisplayScreen(void);
void ListFirmwares(void);
void ListDevices(void);
BYTE GetConfig(void);
void DefaultConfig(void);
void ListHelp(void);
void SetEditedNone(void);
void SetEdited(BYTE which);
void SelectNoBoot(void);
void DrawButton(BYTE number);

void DoOnKeyUp(void);
void DoOnKeyDown(void);
void DoOnKeyLeft(void);
void DoOnKeyRight(void);

void DoOnKeyW(void);
void DoOnKeyR(void);
void DoOnKeyI(void);
void DoOnKeyU(void);
void DoOnKeySpace(void);
void DoOnNumber(BYTE number);
void UploadFirmWare(int which, char *path, char *justFile);

BYTE US_ReadRunningFW(BYTE ACSI_id, BYTE *buffer);

BYTE US_ReadInquiryName(BYTE *buffer);
BYTE US_WriteInquiryName(BYTE *buffer);

void ShowMessage(char *msg);
/*--------------------------------------------------*/
BYTE      BootBase;
TFirmWare FirmWare[5];
TDevice   Devices[2];

BYTE      Edited;

BYTE      UltraSatanID;

BYTE myBuffer[520];
BYTE *pBuffer;
/*--------------------------------------------------*/
/*
#define DEBUG_VERSION
*/
void main(void)
{
  DWORD scancode;
  BYTE key, vkey, prevEdited=0, res;
  BYTE did, i;
  DWORD toEven;
 
  /* ---------------------- */
  toEven = (DWORD) &myBuffer[0];
  
  if(toEven & 0x0001)       /* not even number? */
    toEven++;
  
  pBuffer = (BYTE *) toEven; 
  /* ---------------------- */

  Edited = 0;
  SetEdited(0);
  /* ----------------- */
  /* search for UltraSatan on the ACSI bus */
  UltraSatanID = 0;

  printf("  ");
  Clear_home();
  
#ifdef DEBUG_VERSION
  printf("WARNING!!! DEBUG VERSION!!!\nUSE NORMAL VERSION - THIS ONE\nDOES SOME SHIT.\n\n");
  printf("Press 'Q' to quit now\nor any key to continue.\n");
    
  key = Cconin();
    
  if(key == 'Q' || key=='q')
    return;
#endif
  
  printf("Looking for UltraSatan:\n");

  while(1)
  {
    for(i=0; i<8; i++)
    {
      printf("%d", i);
      
      res = US_ReadRunningFW(i, pBuffer);      /* try to read FW name */
      
      if(res == 1)                            /* if found the US */
      {
        UltraSatanID = i;                     /* store the ACSI ID of UltraSatan */
        break;
      }
    }
  
    if(res == 1)                              /* if found, break */
      break;
      
    printf(" - not found.\nPress any key to retry or 'Q' to quit.\n");
    
    key = Cconin();
    
    if(key == 'Q' || key=='q')
      return;
  }
  
  printf("\n\nUltraSatan ACSI ID: %d\nFirmWare: %s", (int) UltraSatanID, (char *)pBuffer);

  delay(5000);
  /* ----------------- */
  DefaultConfig();
  
  res = GetConfig();

  if(!res)
  {
    Clear_home();
    printf("Failed to get UltraSatan's configuration! Terminating.");
    Cconin();
    
    #ifndef DEBUG_VERSION
    return;
    #endif
  }
  /* ----------------- */

  DisplayScreen();

  while(1)
  {
    did = 0;
    prevEdited = Edited;
        
    Goto_pos(24, 24);
    scancode = Cconin();

    vkey = (scancode>>16) & 0xff;
    key = scancode & 0xff;

    Goto_pos(24, 24);
    printf(" ");
     
    if(key=='q' || key=='Q')
      break;
      
    switch(vkey)
    {
      case 72:  DoOnKeyUp();    did = 1; break;
      case 80:  DoOnKeyDown();  did = 1; break;
      case 75:  DoOnKeyLeft();  did = 1; break;
      case 77:  DoOnKeyRight(); did = 1; break;
    }
    
    switch(key)
    {
      case  32: DoOnKeySpace(); did = 1; break;
      
      case 'w':
      case 'W': DoOnKeyW();     did = 1; break;
      
      case 'r':
      case 'R': DoOnKeyR();     did = 1; break;
      
      case 'u':
      case 'U': DoOnKeyU();     did = 1; break;
      
      case 'i':
      case 'I': DoOnKeyI();     did = 1; break;
    }
    
    if(key>='0' && key<='9')
    {
      DoOnNumber(key-'0');
      did = 1; 
    }
      
    if(did != 1)
      DisplayScreen(); 
      
    DrawButton(Edited);
    DrawButton(prevEdited);
  }
}
/*--------------------------------------------------*/
BYTE US_ReadRunningFW(BYTE ACSI_id, BYTE *buffer)
{
  WORD res;
  BYTE cmd[] = {0x1f, 0x20, 'U', 'S', 'C', 'u', 'r', 'n', 't', 'F', 'W'};
  
  cmd[0] = 0x1f | (ACSI_id << 5);  
  memset(buffer, 0, 512);               /* clear the buffer */
  
  #ifdef DEBUG_VERSION
  if(ACSI_id==4)
  {
    strcpy((char *)buffer, "UltraSatan - fake present FW");
    return 1;
  }
  #endif
  
  res = LongRW(1, cmd, buffer);         /* read name and version of current FW */
    
  if(res != OK)                         /* if failed, return FALSE */
    return 0;
    
  return 1;                             /* success */
}
/*--------------------------------------------------*/
void DoOnKeyI(void)
{
  BYTE res;
  int iRes; 
  
  Clear_home();
  
  Rev_on();
  printf("Set new INQUIRY name\n");
  Rev_off();
  printf("(or just Return to quit)\n");

  res = US_ReadInquiryName(pBuffer);

  if( res != 1 )
  {    
    ShowMessage("Failed to read the INQUIRY name!");
    return;                 
  }

  printf("Current: %s\n", pBuffer);
  printf("New    : ");
  
  gets((char *)pBuffer);
  
  iRes = strlen((char *)pBuffer);
  
  if(iRes < 1)
    {
    Rev_on();
    printf("\n\nNo new name, canceling.\nPress any key.\n");
    Rev_off();
    
    Cconin();             /* wait for a key */
    DisplayScreen();
    return;
    }

  res = US_WriteInquiryName(pBuffer);

  if( res != 1 )
  {    
    ShowMessage("Failed to write the INQUIRY name!");
    return;                 
  }

  delay(200);

  res = US_ReadInquiryName(pBuffer);

  if( res != 1 )
  {    
    ShowMessage("Failed to read the INQUIRY name!");
    return;                 
  }

  printf("\n\nINQUIRY name was set to '%s'.\nPress any key.", pBuffer);
  
  Cconin();             /* wait for a key */
  DisplayScreen();
}
/*--------------------------------------------------*/
BYTE US_ReadInquiryName(BYTE *buffer)
{
  WORD res;
  BYTE cmd[] = {0x1f, 0x20, 'U', 'S', 'R', 'd', 'I', 'N', 'Q', 'R', 'N'};
  
  cmd[0] = 0x1f | (UltraSatanID << 5);  
  memset(buffer, 0, 512);               /* clear the buffer */
  
  #ifdef DEBUG_VERSION
    strcpy((char *)buffer, "UltraSatan");
    return 1;
  #endif
  
  res = LongRW(1, cmd, buffer);         /* read INQUIRY name*/
    
  if(res != OK)                         /* if failed, return FALSE */
    return 0;
    
  if(buffer[0]==0x00 || buffer[0]==0xff)  /* if no name specified */
    strcpy((char *)buffer, "UltraSatan"); /* set default name */
    
  return 1;                             /* success */
}
/*--------------------------------------------------*/
BYTE US_WriteInquiryName(BYTE *buffer)
{
  WORD res;
  BYTE cmd[] = {0x1f, 0x20, 'U', 'S', 'W', 'r', 'I', 'N', 'Q', 'R', 'N'};
  int len, i;
  
  cmd[0] = 0x1f | (UltraSatanID << 5);  
  /* --------------------------------- */
  /* fill the rest of name with spaces */
  len = strlen((char *) buffer);
  
  for(i=len; i<16; i++)
    buffer[i] = 32;
  /* --------------------------------- */
  
  res = LongRW(0, cmd, buffer);         /* write INQUIRY name */
    
  #ifndef DEBUG_VERSION
  if(res != OK)                         /* if failed, return FALSE */
    return 0;
  #endif
    
  return 1;                             /* success */
}
/*--------------------------------------------------*/
void DoOnNumber(BYTE number)
{
  if(number>7)
    return;

  if(Edited==5)
  {
    if(Devices[1].id != number)
      Devices[0].id = number;
  }  

  if(Edited==6)
  {
    if(Devices[0].id != number)
      Devices[1].id = number;
  }  
}
/*--------------------------------------------------*/
void DoOnKeyW(void)
{
  BYTE res;
  WORD i;
  BYTE cmd[] = {0x1f, 0x20, 'U', 'S', 'W', 'r', 'S', 't', 0x83, 0x03, 0x17};
  
  TConfiguration  *Config;
  /* ------------------- */
  if(Devices[0].id == Devices[1].id)
  {
    ShowMessage("Two devices have the same ID!\nFix that and try again.\nConfiguration not written.");
    return;                 
  }
  /*---------------*/
  memset(pBuffer, 0, 512);               /* clear the buffer */
  Config = (TConfiguration *) pBuffer;
    
  for(i=0; i<5; i++)                    /* find which FW # to boot */
    if(FirmWare[i].boot == 1)
    {
      Config->BootFWnumber = i;          /* write the FW # to boot*/
      break;
    }
  /* ------------------- */
  for(i=0; i<2; i++)                    /* write the device ID's */
    Config->DeviceID[i] = Devices[i].id;
  /* ------------------- */
  cmd[0] = 0x1f | (UltraSatanID << 5);  
  res = LongRW(0, cmd, pBuffer);         /* write config */

  #ifndef DEBUG_VERSION
  if(res != OK)
  {
    ShowMessage("Failed to write new configuration!");
    return;
  }
  #endif
  
  /*---------------*/
  ShowMessage("Configuration successfully written.");
  
  /* store the current device ID so this config won't stop working after write */
  UltraSatanID = Config->DeviceID[0];      
}
/*--------------------------------------------------*/
void DoOnKeyR(void)
{
  GetConfig();
  DisplayScreen();
}
/*--------------------------------------------------*/
void DoOnKeyU(void)
{
  char path[256], file[256];
  int button, len, i;  
  
  if(Edited==0 || Edited>4)           /* if the 'U' was pressed on the wrong place */
    return;

  strcpy(path, "A:\\*.*");         /* fill path with desired path */
  memset(file, 0, 256);          
  
  fsel_input(path, file, &button);    /* show file selector */
  
  if(button != 1)                     /* if OK was not pressed */
  {
    DisplayScreen();
    return;
  }
    
  len = (BYTE) strlen(path);                 /* get length of path */ 
  
  for(i=len-1; i>0; i--)              /* find the last \ of path */
    if(path[i]=='\\')
      break;
      
  strcpy(path + i + 1, file);         /* add the file name to the path */
  
  printf("\n%s\n", path);
  
  UploadFirmWare(Edited, path, file); /* now upload the firmware */
  DisplayScreen();

}
/*--------------------------------------------------*/
void UploadFirmWare(int which, char *path, char *justFile)
{
  WORD i, len, res;
  BYTE cmd[] = {0x1f, 0x20, 'U', 'S', 'W', 'r', 'F', 'W', 0, 0, 0};
  FILE *subor;
  
  cmd[0] = 0x1f | (UltraSatanID << 5);  
  cmd[8] = (BYTE) which;

  subor = fopen(path, "rb");
  
  if(!subor)
  {
    ShowMessage("Failed to open the input file!");
    return;
  }
  
  for(i=0; i<199; i++)
  {
    cmd[9]  = (BYTE) ((i >> 8) & 0xff);   /* set the new sector # */
    cmd[10] = (BYTE) ((i     ) & 0xff);
    
    memset(pBuffer, 0, 512);               /* clear the buffer */
    len = (WORD) fread(pBuffer, 1, 512, subor);   /* read one sector to buffer */
    
    res = LongRW(0, cmd, pBuffer);         /* write one sector of FW */
    
    if(res != OK)
    {
      ShowMessage("Failed to write the new FW\nto UltraSatan! Aborting...");
      break;
    }
    
    if(len != 512)                        /* if did not read whole sector, we're done */
      break;
  }

  fclose(subor);                          /* close the file */

  if(res != OK)
    return;  
  /* --------------------- */
  cmd[9]  = 0x00;                         /* sector 199 of FW */
  cmd[10] = 0xc7;

  memset(pBuffer, 0, 512);                 /* clear the buffer */
  strncpy((char *)pBuffer, justFile, 12);          /* copy in the file name */

  LongRW(0, cmd, pBuffer);                 /* write one sector of FW */
  /* --------------------- */  
  DisplayScreen();
}
/*--------------------------------------------------*/
void SelectNoBoot(void)
{
  BYTE i, was;
  
  for(i=0; i<5; i++)
  {
    was = FirmWare[i].boot;
    FirmWare[i].boot = 0;
    
    if(was != FirmWare[i].boot)
      DrawButton(i);
  }
}
/*--------------------------------------------------*/
void DoOnKeySpace(void)
{
  if(Edited<5)
    if(FirmWare[Edited].isPresent != 0)
    {
      SelectNoBoot();
      FirmWare[Edited].boot = 1;
    }
}
/*--------------------------------------------------*/
void DoOnKeyUp(void)
{
  if(Edited > 0 && Edited < 7)
  {
    Edited--;
    SetEdited(Edited);
    return;
  }
}
/*--------------------------------------------------*/
void DoOnKeyDown(void)
{
  if(Edited < 6)
  {
    Edited++;
    SetEdited(Edited);
    return;
  }
}
/*--------------------------------------------------*/
void DoOnKeyLeft(void)
{

}
/*--------------------------------------------------*/
void DoOnKeyRight(void)
{

}
/*--------------------------------------------------*/
void SetEdited(BYTE which)
{
  BYTE dev;
  
  if(which > 6)
    return;

  SetEditedNone();
  
  if(which < 5)
  {
    FirmWare[which].Editing = 1;
    return;
  }
  
  dev = which - 5;
  Devices[dev].idEditing = 1;
}
/*--------------------------------------------------*/
void SetEditedNone(void)
{
  BYTE i;
  
  for(i=0; i<5; i++)
    FirmWare[i].Editing = 0;
    
  for(i=0; i<2; i++)
    Devices[i].idEditing      = 0;
}
/*--------------------------------------------------*/
void DefaultConfig(void)
{
  WORD i;
  char *devName[] = {"SD/MMC card 1   ", "SD/MMC card 2   "};
  
  for(i=1; i<5; i++)
  {
    FirmWare[i].Editing = 0;
    FirmWare[i].boot = 0;
    
    FirmWare[i].isPresent = 0;
    sprintf(FirmWare[i].name, "( empty )");
  }
  
  FirmWare[0].Editing = 1;
  FirmWare[0].boot = 1;
  FirmWare[0].isPresent = 1;
  strcpy(FirmWare[0].name, "base firmware (read only)");
  
  BootBase = 1;
  /* ------------------ */
  for(i=0; i<2; i++)
  {
    strcpy(Devices[i].name, devName[i]);
    Devices[i].id             = i;
    Devices[i].idEditing      = 0;
  }
}
/*--------------------------------------------------*/
BYTE GetConfig(void)
{
  BYTE res;
  WORD i;
  TConfiguration *conf;
  BYTE cmd[] = {0x1f, 0x20, 'U', 'S', 'R', 'd', 'S', 't', 0, 0, 0};
  /* ------------------- */
  /* prepare the default FW names */
  strcpy(FirmWare[0].name, "base firmware (read only)");

  for(i=1; i<5; i++)            
  {
    FirmWare[i].isPresent = 0;
    strcpy(FirmWare[i].name, "( empty )");
  }
  
  FirmWare[0].isPresent = 1;
  /* ------------------- */
  memset(pBuffer, 0, 512);  
  conf = (TConfiguration *) pBuffer;
  
  cmd[0] = 0x1f | (UltraSatanID << 5);  
  res = LongRW(1, cmd, pBuffer);         /* read config */

  #ifndef DEBUG_VERSION
  if(res != OK)
    return 0;
  #endif
  /* ------------------- */
  /* now process the configuration */
  SelectNoBoot();
  
  if(conf->BootFWnumber < 5)                       /* select the firmware to boot */
    FirmWare[conf->BootFWnumber].boot = 1;
  else
    FirmWare[0].boot = 1;
  /* ------------------- */
  if(conf->BootAlwaysBaseFW == 1)
    BootBase = 1;
  else
    BootBase = 0;
  /* ------------------- */
  for(i=0; i<2; i++)
  {
    if(conf->DeviceID[i] < 8)
      Devices[i].id = conf->DeviceID[i];
    else
      Devices[i].id = i;
  }
  /* ------------------- */
  /* read the FW file names from US */
  cmd[6] = 'F';
  cmd[7] = 'W';

  cmd[9]  = 0x00;                       /* read the sector 199 of FW */
  cmd[10] = 0xc7;

  for(i=1; i<5; i++)            
  { 
    cmd[8] = i;                           /* # of FW */
    res = LongRW(1, cmd, pBuffer);         /* read sector */
    
    #ifndef DEBUG_VERSION
    if(res != OK)                         /* if command failed */
      continue;
    #endif
    
    if(pBuffer[0]==0 || pBuffer[0]==0xff)   /* if no file name present or empty sector */
      continue;
    
    memset(FirmWare[i].name, 0, 20);                  /* clear the name */
    strncpy(FirmWare[i].name, (char *)pBuffer, 12);    /* copy in the file name of FW */
    FirmWare[i].isPresent = 1;
  }
  /* ------------------- */
  return 1;
}
/*--------------------------------------------------*/
void DisplayScreen(void)
{
  Clear_home();
  
  Rev_on();
  printf(">> Configuration tool for UltraSatan <<<\n");
  printf(" By Jookie (joo@kie.sk), February 2009  ");
  Rev_off();
  
  ListFirmwares();
  ListDevices();

  ListHelp();
}
/*--------------------------------------------------*/
void DrawButton(BYTE number)
{
  BYTE boot, dev;
  
  if(number > 10)
    return;
  
  /* ---------------------- */
  if(number < 5)
  {
    Goto_pos(number + 4, 0);
    
    if(FirmWare[number].boot==1)
      boot = '*';
    else
      boot = ' ';
    
    if(FirmWare[number].Editing)
      Rev_on();
        
    printf("[ %c ]", boot);
    
    if(FirmWare[number].Editing)
      Rev_off();
      
    return;
  }
  /* ---------------------- */
  dev = number - 5;

  if(number==5 || number==6)
  {
    Goto_pos(13 + dev, 19);

    if(Devices[dev].idEditing==1)
      Rev_on();
      
    printf("[ %d ]", (int)Devices[dev].id);
      
    if(Devices[dev].idEditing==1)
      Rev_off();
      
    return;
  }
}
/*--------------------------------------------------*/
void ListHelp(void)
{
  printf("\n");
  
  Rev_on();
  printf("Little help:\n");
  Rev_off();
  
  printf("Arrows - move the cursor.\n");
  printf("Q      - quit this program\n");
  printf("R or W - read or write settings\n");
  printf("U      - upload new firmware\n");
  printf("SPACE  - change the option\n");
  printf("0 - 7  - to enter a number\n");
  printf("I      - change INQUIRY name\n");
}
/*--------------------------------------------------*/
void ListDevices(void)
{
  BYTE i;
  
  Rev_on();
  printf("\n\n Device           ACSI ID \n");
  Rev_off();
  /* ------------------ */
  
  for(i=0; i<2; i++)
  {
    printf(" %s  ", Devices[i].name);
    /* ------------------ */
    if(Devices[i].idEditing==1)
      Rev_on();
      
    printf("[ %d ]", (int)Devices[i].id);
      
    if(Devices[i].idEditing==1)
      Rev_off();

    printf("   ");
    /* ------------------ */
    printf("\n");
  }
}
/*--------------------------------------------------*/
void ListFirmwares(void)
{
  WORD i;
  char boot;
  
  printf("\n\n");
  
  Rev_on();
  printf("Firmware list (upload, select):\n");
  Rev_off();
  
  for(i=0; i<5; i++)
  {
    if(FirmWare[i].boot==1)
      boot = '*';
    else
      boot = ' ';
    
    if(FirmWare[i].Editing)
      Rev_on();
        
    printf("[ %c ]", boot);
    
    if(FirmWare[i].Editing)
      Rev_off();
      
    printf(" %s\n", FirmWare[i].name);
  }  
  /*-----------*/
  printf("\nBoot always base firmware: ");  

  Rev_on();
  
  if(BootBase==0)
    printf(" NO ");
  else
    printf(" YES ");
  
  Rev_off();
}
/*--------------------------------------------------*/
void ShowMessage(char *msg)
{
  Clear_home();
  
  Rev_on();
  printf("UltraSatan config tool:\n");
  Rev_off();

  printf("%s\n", msg);

  Rev_on();
  printf("\n\nPress any key to continue...\n");
  Rev_off();

  Cconin();             /* wait for a key */
  
  DisplayScreen();
}
/*--------------------------------------------------*/
BYTE LongRW(BYTE ReadNotWrite, BYTE *cmd, BYTE *buffer)
{
 DWORD status;
 WORD i;
 void *OldSP;

 OldSP = (void *) Super((void *)0);  			/* supervisor mode */ 

 FLOCK = -1;                            /* disable FDC operations */
 setdma((DWORD) buffer);                      /* setup DMA transfer address */

 DMA->MODE = NO_DMA | HDC;              /* write 1st byte (0) with A1 low */
 DMA->DATA = cmd[0];
 DMA->MODE = NO_DMA | HDC | A0;         /* A1 high again */

  for(i=1; i<10; i++)
  {
    if (qdone() != OK)                  /* wait for ack */
    {
      hdone();                          /* restore DMA device to normal */
      Super((void *)OldSP);  			      /* user mode */
      return ERROR;
    }
    
    DMA->DATA = cmd[i];
    DMA->MODE = NO_DMA | HDC | A0;
  }

  if (qdone() != OK)                  /* wait for ack */
  {
    hdone();                          /* restore DMA device to normal */
    Super((void *)OldSP);  			      /* user mode */
    return ERROR;
  }

  if(ReadNotWrite==1)
  {
    DMA->MODE = DMA_WR | NO_DMA | SC_REG;  /* clear FIFO = toggle R/W bit */
    DMA->MODE = NO_DMA | SC_REG;           /* and select sector count reg */ 

    DMA->SECT_CNT = 1;                     /* write sector cnt to DMA device */
    DMA->MODE = NO_DMA | HDC | A0;         /* select DMA data register again */

    DMA->DATA = cmd[10];                   
    DMA->MODE = 0;                         /* start DMA transfer */

    status = endcmd(NO_DMA | HDC | A0);    /* wait for DMA completion */
  }
  else
  {
    DMA->MODE = NO_DMA | SC_REG;           /* clear FIFO = toggle R/W bit */
    DMA->MODE = DMA_WR | NO_DMA | SC_REG;  /* and select sector count reg */

    DMA->SECT_CNT = 1;                     /* write sector cnt to DMA device */
    DMA->MODE = DMA_WR | NO_DMA | HDC | A0;/* select DMA data register again */

    DMA->DATA = cmd[10];                   
    DMA->MODE = DMA_WR;                    /* start DMA transfer */

    status = endcmd(DMA_WR | NO_DMA | HDC | A0); /* wait for DMA completion */
  }

  hdone();                                /* restore DMA device to normal */
  Super((void *)OldSP);  			            /* user mode */
  return status;
}
/****************************************************************************/
long endcmd(short mode)
{
 if (fdone() != OK)                   /* wait for operation done ack */
    return(ERRORL);

 DMA->MODE = mode;                    /* write mode word to mode register */
 return((long)(DMA->DATA & 0x00FF));  /* return completion byte */
}
/****************************************************************************/
long hdone(void)
{
 DMA->MODE = NO_DMA;        /* restore DMA mode register */
 FLOCK = 0;                 /* FDC operations may get going again */
 return((long)DMA->STATUS); /* read and return DMA status register */
}
/****************************************************************************/
void setdma(DWORD addr)
{
 DMA->ADDR[LOW]  = (BYTE)(addr);
 DMA->ADDR[MID]  = (BYTE)(addr >> 8);
 DMA->ADDR[HIGH] = (BYTE)(addr >> 16);
}
/****************************************************************************/
long qdone(void)
{
 return(wait_dma_cmpl(STIMEOUT));
}
/****************************************************************************/
long fdone(void)
{
 return(wait_dma_cmpl(LTIMEOUT));
}
/****************************************************************************/
long wait_dma_cmpl(unsigned long t_ticks)
{
 unsigned long to_count;

 to_count = t_ticks + HZ_200;   /* calc value timer must get to */

 do
 {
    if ( (MFP->GPIP & IO_DINT) == 0) /* Poll DMA IRQ interrupt */
         return(OK);                 /* got interrupt, then OK */

 }  while (HZ_200 <= to_count);      /* check timer */

 return(ERROR);                      /* no interrupt, and timer expired, */
}
/****************************************************************************/


