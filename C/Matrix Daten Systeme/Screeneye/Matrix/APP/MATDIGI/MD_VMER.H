/********************************************************************/
/* 				MATdigi - VMEbus Module								*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 25.08.92												*/
/*																	*/
/*  HDG - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*																	*/
/********************************************************************/


# define I2C_REGISTER   0xFE380003L		/* i2c address defualt for TC1208	*/
# define I2C_ROMPORT	0x00FA0001L		/* i2c address with ROMPORT			*/
# define VERS_VME		0xFE20041FL		/* version address VME				*/
# define VERS_ROM		0x00FB7002L		/* version address ROMPORT			*/

# define ILLhardware	99

/*- functions & procedures -*/
extern	bool	chk_vme			(void);

/*- Variables -*/
extern bool	vme_found ;
extern byte	*i2c_bus ;
extern byte *MDversion ;