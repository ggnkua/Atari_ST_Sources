/* boot.h */

#ifndef _BOOT_H
#define _BOOT_H

/* Redefine root and root image devices as variables.
 * This keeps the diffs small but may cause future confusion.
 */
#define ROOT_DEV   (boot_parameters.bp_rootdev)
#define IMAGE_DEV  (boot_parameters.bp_ramimagedev)

/* Device numbers of RAM, floppy and hard disk devices.
 * h/com.h defines RAM_DEV but only as the minor number.
 */
#define DEV_FD0   0x200
#define DEV_HD0   0x300
#define DEV_RAM   0x100
#define DEV_SCSI  0x700	/* Atari TT only */

/* Structure to hold boot parameters. */
struct bparam_s
{
  dev_t bp_rootdev;
  dev_t bp_ramimagedev;
  unsigned short bp_ramsize;
  unsigned short bp_processor;
};

extern struct bparam_s boot_parameters;
#endif /* _BOOT_H */
