/* This file handles the EXEC system call.  It performs the work as follows:
 *    - see if the permissions allow the file to be executed
 *    - read the header and extract the sizes
 *    - fetch the initial args and environment from the user space
 *    - allocate the memory for the new process
 *    - copy the initial stack from MM to the process
 *    - read in the text and data segments and copy to the process
 *    - take care of setuid and setgid bits
 *    - fix up 'mproc' table
 *    - tell kernel about EXEC
 *    - save offset to initial argc (for ps)
 *
 * The entry points into this file are:
 *   do_exec:	 perform the EXEC system call
 *   find_share: find a process whose text segment can be shared
 */

#include "mm.h"
#include <sys/stat.h>
#include <minix/callnr.h>
#include <a.out.h>
#include <signal.h>
#include <string.h>
#include "mproc.h"
#include "param.h"

FORWARD _PROTOTYPE( void load_seg, (int fd, int seg, vir_bytes seg_bytes) );
FORWARD _PROTOTYPE( int new_mem, (struct mproc *sh_mp, vir_bytes text_bytes,
		vir_bytes data_bytes, vir_bytes bss_bytes,
		vir_bytes stk_bytes, phys_bytes tot_bytes)		);
FORWARD _PROTOTYPE( void patch_ptr, (char stack [ARG_MAX ], vir_bytes base) );
FORWARD _PROTOTYPE( int read_header, (int fd, int *ft, vir_bytes *text_bytes,
		vir_bytes *data_bytes, vir_bytes *bss_bytes,
		phys_bytes *tot_bytes, long *sym_bytes, vir_clicks sc,
		vir_bytes *pc)						);

#if (SHADOWING == 1)
FORWARD _PROTOTYPE( int relocate, (int fd, unsigned char *buf)		);
#endif

/*===========================================================================*
 *				do_exec					     *
 *===========================================================================*/
PUBLIC int do_exec()
{
/* Perform the execve(name, argv, envp) call.  The user library builds a
 * complete stack image, including pointers, args, environ, etc.  The stack
 * is copied to a buffer inside MM, and then to the new core image.
 */

  register struct mproc *rmp;
  struct mproc *sh_mp;
  int m, r, fd, ft, sn;
  static char mbuf[ARG_MAX];	/* buffer for stack and zeroes */
  static char name_buf[PATH_MAX]; /* the name of the file to exec */
  char *new_sp, *basename;
  vir_bytes src, dst, text_bytes, data_bytes, bss_bytes, stk_bytes, vsp;
  phys_bytes tot_bytes;		/* total space for program, including gap */
  long sym_bytes;
  vir_clicks sc;
  struct stat s_buf;
  vir_bytes pc;

  /* Do some validity checks. */
  rmp = mp;
  stk_bytes = (vir_bytes) stack_bytes;
  if (stk_bytes > ARG_MAX) return(ENOMEM);	/* stack too big */
  if (exec_len <= 0 || exec_len > PATH_MAX) return(EINVAL);

  /* Get the exec file name and see if the file is executable. */
  src = (vir_bytes) exec_name;
  dst = (vir_bytes) name_buf;
  r = sys_copy(who, D, (phys_bytes) src,
		MM_PROC_NR, D, (phys_bytes) dst, (phys_bytes) exec_len);
  if (r != OK) return(r);	/* file name not in user data segment */
  tell_fs(CHDIR, who, FALSE, 0);	/* switch to the user's FS environ. */
  fd = allowed(name_buf, &s_buf, X_BIT);	/* is file executable? */
  if (fd < 0) return(fd);	/* file was not executable */

  /* Read the file header and extract the segment sizes. */
  sc = (stk_bytes + CLICK_SIZE - 1) >> CLICK_SHIFT;
  m = read_header(fd, &ft, &text_bytes, &data_bytes, &bss_bytes, 
					&tot_bytes, &sym_bytes, sc, &pc);
  if (m < 0) {
	close(fd);		/* something wrong with header */
	return(ENOEXEC);
  }

  /* Fetch the stack from the user before destroying the old core image. */
  src = (vir_bytes) stack_ptr;
  dst = (vir_bytes) mbuf;
  r = sys_copy(who, D, (phys_bytes) src,
  			MM_PROC_NR, D, (phys_bytes) dst, (phys_bytes)stk_bytes);
  if (r != OK) {
	close(fd);		/* can't fetch stack (e.g. bad virtual addr) */
	return(EACCES);
  }

  /* Can the process' text be shared with that of one already running? */
  sh_mp = find_share(rmp, s_buf.st_ino, s_buf.st_dev, s_buf.st_ctime);

  /* Allocate new memory and release old memory.  Fix map and tell kernel. */
  r = new_mem(sh_mp, text_bytes, data_bytes, bss_bytes, stk_bytes, tot_bytes);
  if (r != OK) {
	close(fd);		/* insufficient core or program too big */
	return(r);
  }

  /* Save file identification to allow it to be shared. */
  rmp->mp_ino = s_buf.st_ino;
  rmp->mp_dev = s_buf.st_dev;
  rmp->mp_ctime = s_buf.st_ctime;

  /* Patch up stack and copy it from MM to new core image. */
  vsp = (vir_bytes) rmp->mp_seg[S].mem_vir << CLICK_SHIFT;
  vsp += (vir_bytes) rmp->mp_seg[S].mem_len << CLICK_SHIFT;
  vsp -= stk_bytes;
  patch_ptr(mbuf, vsp);
  src = (vir_bytes) mbuf;
  r = sys_copy(MM_PROC_NR, D, (phys_bytes) src,
  			who, D, (phys_bytes) vsp, (phys_bytes)stk_bytes);
  if (r != OK) panic("do_exec stack copy err", NO_NUM);

  /* Read in text and data segments. */
  if (sh_mp != NULL) {
	lseek(fd, (off_t) text_bytes, SEEK_CUR);  /* shared: skip text */
  } else {
	load_seg(fd, T, text_bytes);
  }
  load_seg(fd, D, data_bytes);

#if (SHADOWING == 1)
  if (lseek(fd, (off_t)sym_bytes, SEEK_CUR) == (off_t) -1) ;	/* error */
  if (relocate(fd, (unsigned char *)mbuf) < 0) 	;		/* error */
  pc += (vir_bytes) rp->mp_seg[T].mem_vir << CLICK_SHIFT;
#endif

  close(fd);			/* don't need exec file any more */

  /* Take care of setuid/setgid bits. */
  if ((rmp->mp_flags & TRACED) == 0) { /* suppress if tracing */
	if (s_buf.st_mode & I_SET_UID_BIT) {
		rmp->mp_effuid = s_buf.st_uid;
		tell_fs(SETUID,who, (int)rmp->mp_realuid, (int)rmp->mp_effuid);
	}
	if (s_buf.st_mode & I_SET_GID_BIT) {
		rmp->mp_effgid = s_buf.st_gid;
		tell_fs(SETGID,who, (int)rmp->mp_realgid, (int)rmp->mp_effgid);
	}
  }

  /* Save offset to initial argc (for ps) */
  rmp->mp_procargs = vsp;

  /* Fix 'mproc' fields, tell kernel that exec is done,  reset caught sigs. */
  for (sn = 1; sn <= _NSIG; sn++) {
	if (sigismember(&rmp->mp_catch, sn)) {
		sigdelset(&rmp->mp_catch, sn);
		rmp->mp_sigact[sn].sa_handler = SIG_DFL;
		sigemptyset(&rmp->mp_sigact[sn].sa_mask);
	}
  }

  rmp->mp_flags &= ~SEPARATE;	/* turn off SEPARATE bit */
  rmp->mp_flags |= ft;		/* turn it on for separate I & D files */
  new_sp = (char *) vsp;

  tell_fs(EXEC, who, 0, 0);	/* allow FS to handle FD_CLOEXEC files */

  /* System will save command line for debugging, ps(1) output, etc. */
  basename = strrchr(name_buf, '/');
  if (basename == NULL) basename = name_buf; else basename++;
  sys_exec(who, new_sp, rmp->mp_flags & TRACED, basename, pc);
  return(OK);
}


/*===========================================================================*
 *				read_header				     *
 *===========================================================================*/
PRIVATE int read_header(fd, ft, text_bytes, data_bytes, bss_bytes, 
						tot_bytes, sym_bytes, sc, pc)
int fd;				/* file descriptor for reading exec file */
int *ft;			/* place to return ft number */
vir_bytes *text_bytes;		/* place to return text size */
vir_bytes *data_bytes;		/* place to return initialized data size */
vir_bytes *bss_bytes;		/* place to return bss size */
phys_bytes *tot_bytes;		/* place to return total size */
long *sym_bytes;		/* place to return symbol table size */
vir_clicks sc;			/* stack size in clicks */
vir_bytes *pc;			/* program entry point (initial PC) */
{
/* Read the header and extract the text, data, bss and total sizes from it. */

  int m, ct;
  vir_clicks tc, dc, s_vir, dvir;
  phys_clicks totc;
  struct exec hdr;		/* a.out header is read in here */

  /* Read the header and check the magic number.  The standard MINIX header 
   * is defined in <a.out.h>.  It consists of 8 chars followed by 6 longs.
   * Then come 4 more longs that are not used here.
   *	Byte 0: magic number 0x01
   *	Byte 1: magic number 0x03
   *	Byte 2: normal = 0x10 (not checked, 0 is OK), separate I/D = 0x20
   *	Byte 3: CPU type, Intel 16 bit = 0x04, Intel 32 bit = 0x10, 
   *            Motorola = 0x0B, Sun SPARC = 0x17
   *	Byte 4: Header length = 0x20
   *	Bytes 5-7 are not used.
   *
   *	Now come the 6 longs
   *	Bytes  8-11: size of text segments in bytes
   *	Bytes 12-15: size of initialized data segment in bytes
   *	Bytes 16-19: size of bss in bytes
   *	Bytes 20-23: program entry point
   *	Bytes 24-27: total memory allocated to program (text, data + stack)
   *	Bytes 28-31: size of symbol table in bytes
   * The longs are represented in a machine dependent order,
   * little-endian on the 8088, big-endian on the 68000.
   * The header is followed directly by the text and data segments, and the 
   * symbol table (if any). The sizes are given in the header. Only the 
   * text and data segments are copied into memory by exec. The header is 
   * used here only. The symbol table is for the benefit of a debugger and 
   * is ignored here.
   */

  if (read(fd, (char *) &hdr, A_MINHDR) != A_MINHDR) return(ENOEXEC);

  /* Check magic number, cpu type, and flags. */
  if (BADMAG(hdr)) return(ENOEXEC);
#if (CHIP == INTEL && _WORD_SIZE == 2)
  if (hdr.a_cpu != A_I8086) return(ENOEXEC);
#endif
#if (CHIP == INTEL && _WORD_SIZE == 4)
  if (hdr.a_cpu != A_I80386) return(ENOEXEC);
#endif
  if ((hdr.a_flags & ~(A_NSYM | A_EXEC | A_SEP)) != 0) return(ENOEXEC);

  *ft = ( (hdr.a_flags & A_SEP) ? SEPARATE : 0);    /* separate I & D or not */

  /* Get text and data sizes. */
  *text_bytes = (vir_bytes) hdr.a_text;	/* text size in bytes */
  *data_bytes = (vir_bytes) hdr.a_data;	/* data size in bytes */
  *bss_bytes  = (vir_bytes) hdr.a_bss;	/* bss size in bytes */
  *tot_bytes  = hdr.a_total;		/* total bytes to allocate for prog */
  *sym_bytes  = hdr.a_syms;		/* symbol table size in bytes */
  if (*tot_bytes == 0) return(ENOEXEC);

  if (*ft != SEPARATE) {

#if (SHADOWING == 0)
	/* If I & D space is not separated, it is all considered data. Text=0*/
	*data_bytes += *text_bytes;
	*text_bytes = 0;
#else
	/*
	 * Treating text as data increases the shadowing overhead.
	 * Under the assumption that programs DO NOT MODIFY TEXT
	 * we can share the text between father and child processes.
	 * This is similar to the UNIX V7 -n option of ld(1).
	 * However, for MINIX the linker did not provide alignment
	 * to click boundaries, so an incomplete text click at the end
	 * must be treated as data.
	 * Correct tot_bytes, since it excludes the text segment.
	 */
	*data_bytes += *text_bytes;
	*text_bytes = (*text_bytes >> CLICK_SHIFT) << CLICK_SHIFT;
	*data_bytes -= *text_bytes;
	*tot_bytes -= *text_bytes;
#endif

  }
  *pc = hdr.a_entry;	/* initial address to start execution */

  /* Check to see if segment sizes are feasible. */
  tc = ((unsigned long) *text_bytes + CLICK_SIZE - 1) >> CLICK_SHIFT;
  dc = (*data_bytes + *bss_bytes + CLICK_SIZE - 1) >> CLICK_SHIFT;
  totc = (*tot_bytes + CLICK_SIZE - 1) >> CLICK_SHIFT;
  if (dc >= totc) return(ENOEXEC);	/* stack must be at least 1 click */
  dvir = (*ft == SEPARATE ? 0 : tc);
  s_vir = dvir + (totc - sc);
  m = size_ok(*ft, tc, dc, sc, dvir, s_vir);
  ct = hdr.a_hdrlen & BYTE;		/* header length */
  if (ct > A_MINHDR) lseek(fd, (off_t) ct, SEEK_SET); /* skip unused hdr */
  return(m);
}


/*===========================================================================*
 *				new_mem					     *
 *===========================================================================*/
PRIVATE int new_mem(sh_mp, text_bytes, data_bytes,bss_bytes,stk_bytes,tot_bytes)
struct mproc *sh_mp;		/* text can be shared with this process */
vir_bytes text_bytes;		/* text segment size in bytes */
vir_bytes data_bytes;		/* size of initialized data in bytes */
vir_bytes bss_bytes;		/* size of bss in bytes */
vir_bytes stk_bytes;		/* size of initial stack segment in bytes */
phys_bytes tot_bytes;		/* total memory to allocate, including gap */
{
/* Allocate new memory and release the old memory.  Change the map and report
 * the new map to the kernel.  Zero the new core image's bss, gap and stack.
 */

  register struct mproc *rmp;
  vir_clicks text_clicks, data_clicks, gap_clicks, stack_clicks, tot_clicks;
  phys_clicks new_base;

#if (SHADOWING == 1)
  phys_clicks base, size;
#else
  static char zero[1024];		/* used to zero bss */
  phys_bytes bytes, base, count, bss_offset;
#endif

  /* No need to allocate text if it can be shared. */
  if (sh_mp != NULL) text_bytes = 0;

  /* Acquire the new memory.  Each of the 4 parts: text, (data+bss), gap,
   * and stack occupies an integral number of clicks, starting at click
   * boundary.  The data and bss parts are run together with no space.
   */

  text_clicks = ((unsigned long) text_bytes + CLICK_SIZE - 1) >> CLICK_SHIFT;
  data_clicks = (data_bytes + bss_bytes + CLICK_SIZE - 1) >> CLICK_SHIFT;
  stack_clicks = (stk_bytes + CLICK_SIZE - 1) >> CLICK_SHIFT;
  tot_clicks = (tot_bytes + CLICK_SIZE - 1) >> CLICK_SHIFT;
  gap_clicks = tot_clicks - data_clicks - stack_clicks;
  if ( (int) gap_clicks < 0) return(ENOMEM);

  /* Check to see if there is a hole big enough.  If so, we can risk first
   * releasing the old core image before allocating the new one, since we
   * know it will succeed.  If there is not enough, return failure.
   */
  if (text_clicks + tot_clicks > max_hole()) return(EAGAIN);

  /* There is enough memory for the new core image.  Release the old one. */
  rmp = mp;

#if (SHADOWING == 0)
  if (find_share(rmp, rmp->mp_ino, rmp->mp_dev, rmp->mp_ctime) == NULL) {
	/* No other process shares the text segment, so free it. */
	free_mem(rmp->mp_seg[T].mem_phys, rmp->mp_seg[T].mem_len);
  }
  /* Free the data and stack segments. */
  free_mem(rmp->mp_seg[D].mem_phys,
      rmp->mp_seg[S].mem_vir + rmp->mp_seg[S].mem_len - rmp->mp_seg[D].mem_vir);
#endif

  /* We have now passed the point of no return.  The old core image has been
   * forever lost.  The call must go through now.  Set up and report new map.
   */
  new_base = alloc_mem(text_clicks + tot_clicks);	/* new core image */
  if (new_base == NO_MEM) panic("MM hole list is inconsistent", NO_NUM);

  if (sh_mp != NULL) {
	/* Share the text segment. */
	rmp->mp_seg[T] = sh_mp->mp_seg[T];
  } else {
	rmp->mp_seg[T].mem_phys = new_base;
	rmp->mp_seg[T].mem_vir = 0;
	rmp->mp_seg[T].mem_len = text_clicks;
  }
  rmp->mp_seg[D].mem_phys = new_base + text_clicks;
  rmp->mp_seg[D].mem_vir = 0;
  rmp->mp_seg[D].mem_len = data_clicks;
  rmp->mp_seg[S].mem_phys = rmp->mp_seg[D].mem_phys + data_clicks + gap_clicks;
  rmp->mp_seg[S].mem_vir = rmp->mp_seg[D].mem_vir + data_clicks + gap_clicks;
  rmp->mp_seg[S].mem_len = stack_clicks;

#if (CHIP == M68000)
#if (SHADOWING == 0)
  rmp->mp_seg[T].mem_vir = 0;
  rmp->mp_seg[D].mem_vir = rmp->mp_seg[T].mem_len;
  rmp->mp_seg[S].mem_vir = rmp->mp_seg[D].mem_vir + rmp->mp_seg[D].mem_len + gap_clicks;
#else
  rmp->mp_seg[T].mem_vir = rmp->mp_seg[T].mem_phys;
  rmp->mp_seg[D].mem_vir = rmp->mp_seg[D].mem_phys;
  rmp->mp_seg[S].mem_vir = rmp->mp_seg[S].mem_phys;
#endif
#endif

#if (SHADOWING == 0)
  sys_newmap(who, rmp->mp_seg);   /* report new map to the kernel */

  /* Zero the bss, gap, and stack segment. */
  bytes = (phys_bytes)(data_clicks + gap_clicks + stack_clicks) << CLICK_SHIFT;
  base = (phys_bytes) rmp->mp_seg[D].mem_phys << CLICK_SHIFT;
  bss_offset = (data_bytes >> CLICK_SHIFT) << CLICK_SHIFT;
  base += bss_offset;
  bytes -= bss_offset;

  while (bytes > 0) {
	count = MIN(bytes, (phys_bytes) sizeof(zero));
	if (sys_copy(MM_PROC_NR, D, (phys_bytes) zero,
						ABS, 0, base, count) != OK) {
		panic("new_mem can't zero", NO_NUM);
	}
	base += count;
	bytes -= count;
  }
#endif

#if (SHADOWING == 1)
  sys_fresh(who, rmp->mp_seg, (phys_clicks)(data_bytes >> CLICK_SHIFT),
			&base, &size);
  free_mem(base, size);
#endif

  return(OK);
}


/*===========================================================================*
 *				patch_ptr				     *
 *===========================================================================*/
PRIVATE void patch_ptr(stack, base)
char stack[ARG_MAX];	/* pointer to stack image within MM */
vir_bytes base;			/* virtual address of stack base inside user */
{
/* When doing an exec(name, argv, envp) call, the user builds up a stack
 * image with arg and env pointers relative to the start of the stack.  Now
 * these pointers must be relocated, since the stack is not positioned at
 * address 0 in the user's address space.
 */

  char **ap, flag;
  vir_bytes v;

  flag = 0;			/* counts number of 0-pointers seen */
  ap = (char **) stack;		/* points initially to 'nargs' */
  ap++;				/* now points to argv[0] */
  while (flag < 2) {
	if (ap >= (char **) &stack[ARG_MAX]) return;	/* too bad */
	if (*ap != NIL_PTR) {
		v = (vir_bytes) *ap;	/* v is relative pointer */
		v += base;		/* relocate it */
		*ap = (char *) v;	/* put it back */
	} else {
		flag++;
	}
	ap++;
  }
}


/*===========================================================================*
 *				load_seg				     *
 *===========================================================================*/
PRIVATE void load_seg(fd, seg, seg_bytes)
int fd;				/* file descriptor to read from */
int seg;			/* T or D */
vir_bytes seg_bytes;		/* how big is the segment */
{
/* Read in text or data from the exec file and copy to the new core image.
 * This procedure is a little bit tricky.  The logical way to load a segment
 * would be to read it block by block and copy each block to the user space
 * one at a time.  This is too slow, so we do something dirty here, namely
 * send the user space and virtual address to the file system in the upper
 * 10 bits of the file descriptor, and pass it the user virtual address
 * instead of a MM address.  The file system extracts these parameters when 
 * gets a read call from the memory manager, which is the only process that
 * is permitted to use this trick.  The file system then copies the whole 
 * segment directly to user space, bypassing MM completely.
 */

  int new_fd, bytes;
  char *ubuf_ptr;

  new_fd = (who << 8) | (seg << 6) | fd;
  ubuf_ptr = (char *) ((vir_bytes)mp->mp_seg[seg].mem_vir << CLICK_SHIFT);
  while (seg_bytes != 0) {
	bytes = (INT_MAX / BLOCK_SIZE) * BLOCK_SIZE;
	if (seg_bytes < bytes)
		bytes = (int)seg_bytes;
	if (read(new_fd, ubuf_ptr, bytes) != bytes)
		break;		/* error */
	ubuf_ptr += bytes;
	seg_bytes -= bytes;
  }
}


/*===========================================================================*
 *				find_share				     *
 *===========================================================================*/
PUBLIC struct mproc *find_share(mp_ign, ino, dev, ctime)
struct mproc *mp_ign;		/* process that should not be looked at */
ino_t ino;			/* parameters that uniquely identify a file */
dev_t dev;
time_t ctime;
{
/* Look for a process that is the file <ino, dev, ctime> in execution.  Don't
 * accidentally "find" mp_ign, because it is the process on whose behalf this
 * call is made.
 */
  struct mproc *sh_mp;

  for (sh_mp = &mproc[INIT_PROC_NR]; sh_mp < &mproc[NR_PROCS]; sh_mp++) {
	if ((sh_mp->mp_flags & (IN_USE | HANGING | SEPARATE))
					!= (IN_USE | SEPARATE)) continue;
	if (sh_mp == mp_ign) continue;
	if (sh_mp->mp_ino != ino) continue;
	if (sh_mp->mp_dev != dev) continue;
	if (sh_mp->mp_ctime != ctime) continue;
	return sh_mp;
  }
  return(NULL);
}


#if (SHADOWING == 1)
/*===========================================================================*
 *				relocate				     *
 *===========================================================================*/
PRIVATE int relocate(fd, buf)
int fd;				/* file descriptor to read from */
unsigned char *buf;		/* borrowed from do_exec() */
{
  register int n;
  register unsigned char *p, c;
  register phys_bytes off;
  register phys_bytes adr;

  /* Read in relocation info from the exec file and relocate.
   * Relocation info is in GEMDOS format. Only longs can be relocated.
   *
   * The GEMDOS format starts with a long L: the offset to the
   * beginning of text for the first long to be relocated.
   * If L==0 then no relocations have to be made.
   *
   * The long is followed by zero or more bytes. Each byte B is
   * processed separately, in one of the following ways:
   *
   * B==0:
   *	end of relocation
   * B==1:
   *	no relocation, but add 254 to the current offset
   * B==0bWWWWWWW0:
   *	B is added to the current offset and the long addressed
   *	is relocated. Note that 00000010 means 1 word distance.
   * B==0bXXXXXXX1:
   *	illegal
   */
  off = (phys_bytes)mp->mp_seg[T].mem_phys << CLICK_SHIFT;
  p = buf;
  n = read(fd, (char *)p, ARG_MAX);
  if (n < sizeof(long)) return(-1);	/* error */
  if (*((long *)p) == 0) return(0);	/* ok */
  adr = off + *((long *)p);
  n -= sizeof(long);
  p += sizeof(long);
  *((long *)adr) += off;
  while (1) {			/* once per relocation byte */
	if (--n < 0) {
		p = buf;
		n = read(fd, (char *)p, ARG_MAX);
		if (--n < 0)
			return(-1);	/* error */
	}
	c = *p++;
	if (c == 1)
		adr += 254;
	else if (c == 0)
		return(0);	/* ok */
	else if (c & 1)
		return(-1);	/* error */
	else {
		adr += c;
		*((long *)adr) += off;
	}
  }
}
#endif
