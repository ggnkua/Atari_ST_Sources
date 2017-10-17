
/******************************************************************************
 *	Dmodule.h	Device Module definitions
 ******************************************************************************
 *
 */

# define	NDMODULES	8	/* Number of device modules */


/* Dmodule	Device modules currently loaded */
struct	Dmodule {
	short	nopens;			/* Number of items using it */
	struct	dev *dmaj;		/* Pointer to dev switch entry */
	short	memseg;			/* Memory segment used */
	int	ino;			/* Inode number of device driver */
};
