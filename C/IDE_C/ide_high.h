//----------------------------------------------------------------------------- 
// initialize the drives
void IDE_init(unsigned char doDiag);

char IDE_GetAndShowDriveParams(char ForMaster);
void IDE_ShowDriveParams(char ForMaster);

char IDE_ReadSector(char FromMaster, char Count, 
	 				char adr_H, char adr_MH, char adr_ML, char adr_L);

char IDE_WriteSector(char FromMaster, char Count, 
	 				 char adr_H, char adr_MH, char adr_ML, char adr_L);
	
// write all zeros to sector
char IDE_WriteZeroSector(char FromMaster, char Count, 
	 				 char adr_H, char adr_MH, char adr_ML, char adr_L);
//----------------------------------------------------------------------------- 
// this does the formating of drive, now actualy only 'zero-fill'
char IDE_FormatDisk(char FromMaster);
//----------------------------------------------------------------------------- 

