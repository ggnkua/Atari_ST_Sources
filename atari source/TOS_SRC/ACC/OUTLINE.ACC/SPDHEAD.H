/* Header format for SPEEDO fonts */

/* Using Font Full NAme */
typedef struct _spdhdr
{
   char  Format_Identifier[8];
   long  Font_Size;
   long	 MinFontBuffSize;
   int   MinCharBuffSize;
   int	 HeaderSize;
   int   FontID;
   int   FontVersionNumber;
   char  FontFullName[70];
   char  ManufacturingDate[10];
   char  CharSetName[66];
   char  VenderId[2];
   char	 CharSetID[2];
}SPDHDR;


#if 0
/* Using Short Font NAme */
typedef struct _spdhdr
{
   char  Format_Identifier[8];
   long  Font_Size;
   long	 MinFontBuffSize;
   int   MinCharBuffSize;
   int	 HeaderSize;
   int   FontID;
   int   FontVersionNumber;
   char  FontFullName[70];
   char  ManufacturingDate[10];
   char  CharSetName[66];
   char  VenderId[2];
   char	 CharSetID[2];
   char  CopyRightNotice[78];
   int   NumOfCharIndexInFont;
   int   TotalNumOfCharIndexInFont;
   int   IndexFirstChar;
   int   NumKernTracks;
   int   NumKernPairs;
   char  FontFlags;
   char  ClassFlags;
   char  FamilyClass;
   char  FontFormClass;
   char  ShortFontName[32];
   char  ShortFaceName[16];
   char  FontForm[14];   
}SPDHDR;
#endif
