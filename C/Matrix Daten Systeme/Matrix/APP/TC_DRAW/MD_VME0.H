/********************************************************************/
/* 				MATdigi - VMEbus Module								*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 17.08.92												*/
/*																	*/
/*  HDG - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*																	*/
/********************************************************************/

# if 0
# define I2C_REGISTER   0xFE380003L		/* i2c address default for TC1208	*/
# define I2C_VME		0xFE201003L		/* i2c address with TC1208			*/
# define VERS_VME		0xFE20041FL		/* version address VME				*/
# endif

# define I2C_ROMPORT	0x00FA0001L		/* i2c address with ROMPORT			*/
# define VERS_ROM		0x00FB7002L		/* version address ROMPORT			*/

# define ILLhardware	99

/*- functions & procedures -*/
extern	bool	chk_vme			(void);

/*- Variables -*/
extern bool	vme_found ;
extern byte	*i2c_bus ;
extern byte *MDversion ;