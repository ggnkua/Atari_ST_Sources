#include "syslib.h"

PUBLIC int sys_copy(src_proc, src_seg, src_vir,
					dst_proc, dst_seg, dst_vir, bytes)
int src_proc;			/* source process */
int src_seg;			/* source segment: T, D, or S */
phys_bytes src_vir;		/* source virtual address (phys addr for ABS)*/
int dst_proc;			/* dest process */
int dst_seg;			/* dest segment: T, D, or S */
phys_bytes dst_vir;		/* dest virtual address (phys addr for ABS) */
phys_bytes bytes;		/* how many bytes */
{
/* Transfer a block of data.  The source and destination can each either be a
 * process (including MM) or absolute memory, indicate by setting 'src_proc'
 * or 'dst_proc' to ABS.
 */

  message copy_mess;

  if (bytes == 0L) return(OK);
  copy_mess.SRC_SPACE = src_seg;
  copy_mess.SRC_PROC_NR = src_proc;
  copy_mess.SRC_BUFFER = (long) src_vir;

  copy_mess.DST_SPACE = dst_seg;
  copy_mess.DST_PROC_NR = dst_proc;
  copy_mess.DST_BUFFER = (long) dst_vir;

  copy_mess.COPY_BYTES = (long) bytes;
  return(_taskcall(SYSTASK, SYS_COPY, &copy_mess));
}
