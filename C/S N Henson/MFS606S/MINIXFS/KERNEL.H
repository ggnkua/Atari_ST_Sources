/* Macros for kernel , bios and gemdos functions */

#define CCONWS (void)(*kernel->dos_tab[0x09])
#define RWABS (*kernel->bios_tab[4])
#define GETBPB (void *)(*kernel->bios_tab[7])

#define p_exec (*kernel->dos_tab[0x4b])
#define m_shrink (*kernel->dos_tab[0x4a])
#define f_select (*kernel->dos_tab[0x11d])


#define Timestamp (*kernel->dos_tab[0x2c])
#define Datestamp (*kernel->dos_tab[0x2a])
#define Domain() (*kernel->dos_tab[0x119])(-1)
#define Getpid (*kernel->dos_tab[0x10b])
#define Getuid (*kernel->dos_tab[0x10f])
#define Getgid (*kernel->dos_tab[0x114])
#define Geteuid (kernel->maj_version || kernel->min_version >= 95 ? *kernel->dos_tab[0x138] : *kernel->dos_tab[0x10f])

#define DEBUG (*kernel->debug)
#define ALERT (*kernel->alert)
#define TRACE (*kernel->trace)
#define FATAL (*kernel->fatal)
#define Kmalloc (*kernel->kmalloc)
#define Kfree (*kernel->kfree)
#define Stricmp (*kernel->stricmp)
#define Strlwr  (*kernel->strlwr)
#define Unixtime (*kernel->unixtim)
#define Dostime (*kernel->dostim)
#define Denyshare (*kernel->denyshare)
#define Denylock (*kernel->denylock)
#define Changedrive (*kernel->drvchng)
