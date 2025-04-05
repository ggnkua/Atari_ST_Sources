/*
 * Definition of the UniTerm parameter block
 * Donated to the Public Domain by Simon Poole
 */

/* These definitions assume:
 *  - int     : 16 bits
 *  - long    : 32 bits
 *  - pointer : 32 bits
 *  - struct fields are ordered from low to high 
 *    memory, without any additional alignment
 *    bytes (PBLength is at the lowest address,
 *    PBClipAddress at the highest)
 */

typedef struct {
   long ClipLen;     /* current length of clip */
   char *ClipBuffer; /* pointer to the buffer itsself */
} ClipStruct;        /* UniTerm's clipboard */

typedef struct {
   int        PBLength;       /* size of parameter block, currently 54 */      
   long       PBFlags;        /* reserved for future expansion */
   long       PBTextScreen;   /* address of the screen in text mode */
   long       PBGraphScreen;  /* address of the graphic screen (if allocated) */
   long       PBScreenBuffer; /* address of buffer for screen operations 32'000 bytes */
   char       *PBTransBuffer; /* pointer to buffer used for file transfer */
   long       PBTransSize;    /* size of above buffer */
   long       PBTransPtrAdr;  /* current position in the buffer */
   char       *PBHistBuffer;  /* pointer to history buffer */
   long       PBHistSize;     /* size of above buffer */
   long       *PBHistBotAdr;  /* pointer to the address (NOT offset) of current hist. bottom */ 
   long       *PBHistPtrAdr;  /* pointer to the address (NOT offset) of current hist. top */
   long       PBClipSize;     /* maximum size of clipboard */
   ClipStruct *PBClipRecAdr;  /* pointer to the clipboard structure */
} UniStruct;                  /* UniTerm's parameter block */

/*
 * When a program is started, the current screen is either PBTextScreen
 * or PBGraphScreen, a copy of the contents of that screen is in 
 * PBScreenBuffer.
 * 
 * For historical reasons the addresses pointed to by PBHistBotAdr and
 * PBHistPtrAdr are not offsets from PBHistBuffer, but are absolute
 * memory addresses.
 *
 * New fields will be added at the end of the parameter block, so the
 * application only has to check PBLength to see if a field is present 
 * or not.
 */
