#ifndef __ARCH_NF_OPS_H__
#define __ARCH_NF_OPS_H__

#ifndef	_FEATURES_H
# include <features.h>
#endif

#define __need_size_t
#define __need_NULL
#include <stddef.h>
#include <stdarg.h>

/*
 * Interface for calling native function in emulators.
 * See http://wiki.aranym.org/natfeats/proposal
 * for a complete description.
 */

struct nf_ops
{
#ifdef __NO_CDECL
	void *get_id;
	void *call;
#else
	long __CDECL (*get_id)(const char *);
	long __CDECL (*call)(long id, ...);
#endif
	long res[3];
};

#ifdef __linux__
#include <asm/io.h>
#else
#define virt_to_phys(a) a
#endif

#define NF_GET_ID(ops, feature) ((ops)->get_id((const char *)virt_to_phys(feature)))


#define NF_ID_NAME      "NF_NAME"
#define NF_ID_VERSION   "NF_VERSION"
#define NF_ID_STDERR    "NF_STDERR"
#define NF_ID_SHUTDOWN  "NF_SHUTDOWN"
#define NF_ID_EXIT      "NF_EXIT"
#define NF_ID_DEBUG     "DEBUGPRINTF"
#define NF_ID_ETHERNET  "ETHERNET"
#define NF_ID_HOSTFS    "HOSTFS"
#define NF_ID_AUDIO     "AUDIO"
#define NF_ID_BOOTSTRAP "BOOTSTRAP"
#define NF_ID_CDROM     "CDROM"
#define NF_ID_CLIPBRD   "CLIPBRD"
#define NF_ID_JPEG      "JPEG"
#define NF_ID_OSMESA    "OSMESA"
#define NF_ID_PCI       "PCI"
#define NF_ID_FVDI      "fVDI"
#define NF_ID_USBHOST   "USBHOST"
#define NF_ID_XHDI      "XHDI"
#define NF_ID_SCSI      "NF_SCSIDRV"
#define NF_ID_HOSTEXEC  "HOSTEXEC"
#define NF_ID_CONFIG    "NF_CONFIG"


__BEGIN_DECLS

/*
 * catch (and ignore) SIGSYS on MiNT.
 * Used during detection, which might need to call
 * Supexec, possibly raising a SIGSYS signal if
 * secure_mode is set.
 */
void nf_catch_sigsys(void);

/**
 * Use this function to initialize Native Features.
 *
 * return the pointer to 'struct nf_ops' or NULL when
 *         not available.
 **/
struct nf_ops *nf_init(void);

/* basic set native feature functions */

/**
 * return the NF id to use for feature_name,
 *  or zero when not available.
 **/
long nf_get_id(const char *feature_name);

/**
 * return the version of the NatFeat implementation,
 *  or zero when not available.
 **/
long nf_version(void);

/**
 * return the name of the NatFeat implementor,
 *  or NULL when not available.
 **/
const char *nf_get_name(char *buf, size_t bufsize);

/**
 * return the full name of the NatFeat implementor,
 *  or NULL when not available.
 **/
const char *nf_get_fullname(char *buf, size_t bufsize);

/**
 * Write a string to the host's terminal.
 * returns TRUE when available, FALSE otherwise.
 **/
int nf_debug(const char *msg);

/**
 * Shutdown the emulator.
 * May only be called from Supervisor.
 **/
long nf_shutdown(int mode);

/**
 * Shutdown the emulator.
 * May be called from user mode.
 **/
long nf_exit(int exitcode);

/**
 * Write a formatted string to the host's terminal.
 * Returns the number of characters printed,
 * or -1 if NatFeats are not available.
 * This implementation does NOT make use of the DEBUGPRINTF
 * NatFeat, where the format may use only a limited subset of
 * printf-like control characters (no field widths etc, no doubles),
 * and all arguments must be passed as 32-bit-integer values.
 * It uses the MiNTLibs implementation of sprintf instead,
 * and the NF_STDERR NatFeat.
 **/
int nf_debugprintf(const char *fmt, ...) __attribute__((__format__(__printf__, 1, 2)));
int nf_debugvprintf(const char *fmt, va_list args);

/*
 * execute a host command.
 */
long nf_exec(const char *cmd);
long nf_execv(long argc, const char *const *argv);

__END_DECLS

#endif /* __ARCH_NF_OPS_H__ */
