typedef struct
{
	char      *in_dos;                 /* Adresse der DOS- Semaphore */
	int       *dos_time;               /* Adresse der DOS- Zeit      */
	int       *dos_date;               /* Adresse des DOS- Datums    */
	long      res1;                    /*                            */
	long      res2;                    /*                            */
	long      res3;                    /* ist 0L                     */
	void      *act_pd;                 /* Laufendes Programm         */
	long      res4;                    /*                            */
	int       res5;                    /*                            */
	void      res6;                    /*                            */
	void      res7;                    /* interne DOS- Speicherliste */
	void      (*resv_intmem)();        /* DOS- Speicher erweitern    */
	long      (*etv_critic)();         /* etv_critic des GEMDOS      */
	char*	((*err_to_str)(char e)); /* Umrechnung Code->Klartext  */
	long      res8;                    /*                            */
	long      res9;                    /*                            */
	long      res10;                   /*                            */
} DOSVARS;

typedef struct
{
	long	magic;					/* muž $87654321 sein         */
	void	*membot;					/* Ende der AES- Variablen    */
	void	*aes_start;				/* Startadresse               */
	long	magic2;					/* ist 'MAGX'                 */
	long	date;					/* Erstelldatum               */
	void	(*chgres)(int res, int txt);	/* Aufl”sung „ndern           */
	long	(**shel_vector)(void);		/* residentes Desktop         */
	char	*aes_bootdrv;				/* von hieraus wurde gebootet */
	int	*vdi_device;				/* vom AES benutzter Treiber  */

	void	**nvdi_workstation;			/* Keine offiziellen AESVARS	*/
	int	*shelw_doex;
	int	*shelw_isgr;
	int	version;
	int	release;
} AESVARS;

typedef struct
{
	long    config_status;
	DOSVARS *dosvars;
	AESVARS *aesvars;
} MAGX_COOKIE;

typedef void (*STD_PROC) (void);
typedef void cdecl (*ProcProcPtr) (STD_PROC routine);

typedef long (*GenProc) (int function, void *data);typedef int (*PrSetupProc) (int alwaysInteractively);typedef int (*ProcPtr) (void);typedef void (*VoidProcPtr) (void);typedef struct 
{	void     		**printHdl;
	PrSetupProc 	doPrintSetup;
	VoidProcPtr 	saveSetup;
	long        	reserved[7];} PrintDesc;typedef struct 
{
	char		vm;		/* first part of version number in BCD */	char		vn;		/* second and third part of version number in BCD */	char		vt;		/* development: 0x20, alpha: 0x40, beta: 0x60, release: 0x80 */	char		vd;		/* stage of prerelease version */	int	region;	/* region code */	char		str[];	/* two version strings */} MacVersion;typedef struct 
{	int		inserted;		/* true: disk is inserted and available to GEMDOS/BIOS functions */	int		highDensity;	/* true: HD disk inserted, false: none or DD disk inserted */	int	res1;		/* reserved */	long		res2;		/* reserved */} FlpDrvInfo;
typedef struct
{	int   	vers;              
	int   	size;              
	long    	flags1;            
	void    	*scrnPMPtr;        
	void    	*updatePalette;    
	ProcPtr 	modeMac;           
	ProcPtr 	modeAtari;         
	ProcPtr 	getBaseMode;       
	ProcPtr 	getIntrCount;      
	ProcPtr 	intrLock;          
	ProcPtr 	intrUnlock;        
	ProcProcPtr callMacContext;    
	void		*atariZeroPage;     
	void		*macA5;             
	ProcPtr 	macAppSwitch;      
	ProcPtr 	controlSwitch;     
	long    	hardwareAttr1;     
	long    	hardwareAttr2;     
	void		*magiC_BP;          
	void		*auxOutName;        
	void		*auxInName;         
	ProcPtr 	auxControl;        
	PrintDesc	*printDescPtr;	GenProc 	configKernel;      
	int 		*atariModePossible;
	MacVersion *versionOfMacAppl; 
	void    	*hwEmulSupport;    
	FlpDrvInfo *floppyDrvInfoPtr; 
	void 	*xcmdMgrPtr;    
	ProcPtr 	giveTimeToMac;     
	long    	minStackSize;      
	GenProc 	ext;               
	GenProc 	extMac;            
	long    	reserved[5];       
} MgMcCookie;
/* Ende von e_types.h */
