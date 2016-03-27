/* File 	:	select.c
   Author 	:	Borland. Adapted by HDG.
   Date		:	19/08/1993
   
   Exports from SELECT.C ( provides an interface to the GEM file
   selector box - adapted from Turbo C user manual )
*/

# define CURRENT_DRIVE 0
# define STFILELEN	13
# define STPATHLEN	64

/* ------------- prototypes -------------- */
extern	int 	usage		(int m);
extern	long	GetDrives	(void);
extern	int 	GetDrive 	(void);
extern	void	SetDrive	(int drive);
extern	void	InitPath	(int drive);
extern	bool	NoPath		(int drive);
extern	FILE	*op_fbox	(char const *mode, char const *ext,
							 char *name);
extern	int 	op_fbox_name(char const *mode, char const *ext,
							 char *name, int *drive);
