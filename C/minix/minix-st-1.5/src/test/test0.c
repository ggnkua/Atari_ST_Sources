/* test 0 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

#define MAX_ERROR 4

extern int errno;
int errct;
int subtest;
extern off_t lseek();


#define NB          30L
main()
{
  int i;
  char let;

  printf("Test  0 ");
  fflush(stdout);
  for (i = 0; i < 4; i++) {
	test00();
	test01();
  }
  if (errct == 0)
	printf("ok\n");
  else
	printf(" %d errors\n", errct);
}






char aa[100];
char b[4] = {0, 1, 2, 3}, c[4] = {10, 20, 30, 40}, d[4] = {6, 7, 8, 9};
long t1;

test00()
{
  /* Test program for open(), close(), creat(), read(), write(), lseek(). */
  int i, n, n1, n2;
  long t, time(), abuf[4];
  struct stat s;


  subtest = 1;
  if ((n = creat("foop", 0777)) != 3) {
	printf("Creating a file returned file descriptor %d instead of 3\n", n);
	e(1);
  }
  if ((n1 = creat("foop", 0777)) != 4) e(2);
  if ((n2 = creat("/", 0777)) != -1) e(3);
  if (close(n) != 0) e(4);
  if ((n = open("foop", O_RDONLY)) != 3) e(5);
  if ((n2 = open("nofile", O_RDONLY)) != -1) e(6);
  if (close(n1) != 0) e(7);

  /* N is the only one open now. */
  for (i = 0; i < 2; i++) {
	n1 = creat("File2", 0777);
	if (n1 != 4) {
		printf("creat yielded fd=%d, expected 4\n", n1);
		e(8);
	}
	if ((n2 = open("File2", O_RDONLY)) != 5) e(9);
	if (close(n1) != 0) e(10);
	if (close(n2) != 0) e(11);
  }
  unlink("File2");
  if (close(n) != 0) e(12);

  /* All files closed now. */
  for (i = 0; i < 2; i++) {
	t = 105L;
	if ((n = creat("foop", 0777)) != 3) e(13);
	if (close(n) != 0) e(14);
	if ((n = open("foop", O_RDWR)) != 3) e(15);

	/* Read/write tests */
	if (write(n, b, 4) != 4) e(16);
	if (read(n, aa, 4) != 0) e(17);
	if (lseek(n, 0L, SEEK_SET) != 0L) e(18);
	if (read(n, aa, 4) != 4) e(19);
	if (aa[0] != 0 || aa[1] != 1 || aa[2] != 2 || aa[3] != 3) e(20);
	if (lseek(n, 0L, SEEK_SET) != 0L) e(21);
	if (lseek(n, 2L, SEEK_CUR) != 2L) e(22);
	if (read(n, aa, 4) != 2) e(23);
	if (aa[0] != 2 || aa[1] != 3 || aa[2] != 2 || aa[3] != 3) e(24);
	if (lseek(n, 2L, SEEK_SET) != 2L) e(25);
	clraa();
	if (write(n, c, 4) != 4) e(26);
	if (lseek(n, 0L, SEEK_SET) != 0L) e(27);
	if (read(n, aa, 10) != 6) e(28);
	if (aa[0] != 0 || aa[1] != 1 || aa[2] != 10 || aa[3] != 20) e(29);
	if (lseek(n, 16L, SEEK_SET) != 16L) e(30);
	if (lseek(n, 2040L, SEEK_END) != 2046L) e(31);
	if (read(n, aa, 10) != 0) e(32);
	if (lseek(n, 0L, SEEK_CUR) != 2046L) e(33);
	clraa();
	if (write(n, c, 4) != 4) e(34);
	if (lseek(n, 0L, SEEK_CUR) != 2050L) e(35);
	if (lseek(n, 2040L, SEEK_SET) != 2040L) e(36);
	clraa();
	if (read(n, aa, 20) != 10) e(37);
	if (aa[0] != 0 || aa[5] != 0 || aa[6] != 10 || aa[9] != 40) e(38);
	if (lseek(n, 10239L, SEEK_SET) != 10239L) e(39);
	if (write(n, d, 2) != 2) e(40);
	if (lseek(n, -2L, SEEK_END) != 10239L) e(41);
	if (read(n, aa, 2) != 2) e(42);
	if (aa[0] != 6 || aa[1] != 7) e(43);
	if (lseek(n, NB * 1024L - 2L, SEEK_SET) != NB * 1024L - 2L) e(44);
	if (write(n, b, 4) != 4) e(45);
	if (lseek(n, 0L, SEEK_SET) != 0L) e(46);
	if (lseek(n, -6L, SEEK_END) != 1024L * NB - 4) e(47);
	clraa();
	if (read(n, aa, 100) != 6) e(48);
	if (aa[0] != 0 || aa[1] != 0 || aa[3] != 1 || aa[4] != 2|| aa[5] != 3)
		e(49);
	if (lseek(n, 20000L, SEEK_SET) != 20000L) e(50);
	if (write(n, c, 4) != 4) e(51);
	if (lseek(n, -4L, SEEK_CUR) != 20000L) e(52);
	if (read(n, aa, 4) != 4) e(53);
	if (aa[0] != 10 || aa[1] != 20 || aa[2] != 30 || aa[3] != 40) e(54);
	if (close(n) != 0) e(55);
	if ((n1 = creat("foop", 0777)) != 3) e(56);
	if (close(n1) != 0) e(57);
	unlink("foop");

	/* Test clock. */
/*  This test messes up the clock value.  Comment it out:
  t = 20L;
  stime(&t);
  t = 0L;
  t = time(&t);
  if (t < 20L || t > 70L) e(59);
  t = 200L;
  if (stime(&t) < 0) e(60);
  t = 0L;
  if (time(&t) < 200L || time(&t) > 205L) e(61);
  n1 = creat("timefile", 0777);
  abuf[0] = 03003L;
  abuf[1] = 03003L;
  if (utime("timefile", abuf) < 0) e(62);
  if (stat("timefile", &s) < 0) e(63);
  if (s.st_atime != 03003) e(64);
  abuf[0] = 06226;
  abuf[1] = 06226;
  if (utime("timefile", abuf) < 0) e(65);
  if (stat("timefile", &s) < 0) e(66);
  if (s.st_ctime != 06226) e(67);
  if (unlink("timefile") < 0) e(68);
  if (close(n1) < 0) e(69);
  if (times(abuf) < 0) e(70);

  End of deleted code */
  }
}


static clraa()
{
  int i;
  for (i = 0; i < 100; i++) aa[i] = 0;
}


test01()
{
/* Test link, unlink, stat, fstat, dup, umask.
 */

  int i, j, n, n1, flag;
  char a[255], b[255];
  struct stat s, s1;

  subtest = 2;
  for (i = 0; i < 2; i++) {
	umask(0);

	if ((n = creat("T3", 0702)) < 0) e(1);
	if (link("T3", "newT3") < 0) e(2);
	if ((n1 = open("newT3", O_RDWR)) < 0) e(3);
	for (j = 0; j < 255; j++) a[j] = j;
	if (write(n, a, 255) != 255) e(4);
	if (read(n1, b, 255) != 255) e(5);
	flag = 0;
	for (j = 0; j < 255; j++)
		if (a[j] != b[j]) flag++;
	if (flag) e(6);
	if (unlink("T3") < 0) e(7);
	if (close(n) < 0) e(8);
	if (close(n1) < 0) e(9);
	if ((n1 = open("newT3", O_RDONLY)) < 0) e(10);
	if (read(n1, b, 255) != 255) e(11);
	flag = 0;
	for (j = 0; j < 255; j++)
		if (a[j] != b[j]) flag++;
	if (flag) e(12);

	/* Now check out stat, fstat. */
	if (stat("newT3", &s) < 0) e(13);
	if (s.st_mode != 0100702) e(14);
	if (s.st_nlink != 1) e(15);
	if (s.st_size != 255L) e(16);
	if (fstat(n1, &s1) < 0) e(17);
	if (s.st_dev != s1.st_dev) e(18);
	if (s.st_ino != s1.st_ino) e(19);
	if (s.st_mode != s1.st_mode) e(20);
	if (s.st_nlink != s1.st_nlink) e(21);
	if (s.st_uid != s1.st_uid) e(22);
	if (s.st_gid != s1.st_gid) e(23);
	if (s.st_rdev != s1.st_rdev) e(24);
	if (s.st_size != s1.st_size) e(25);
	if (s.st_atime != s1.st_atime) e(26);
	if (close(n1) < 0) e(27);
	if (unlink("newT3") < 0) e(28);

	umask(040);
	if ((n = creat("T3a", 0777)) < 0) e(29);
	if (stat("T3a", &s) < 0) e(30);
	if (s.st_mode != 0100737) e(31);
	if (unlink("T3a") < 0) e(32);
	if (close(n1) < 0) e(33);

	/* Dup */
	if ((n = creat("T3b", 0777)) < 0) e(34);
	if (close(n) < 0) e(35);
	if ((n = open("T3b", O_RDWR)) < 0) e(36);
	if ((n1 = dup(n)) != n + 1) e(37);
	if (write(n, a, 255) != 255) e(38);
	read(n1, b, 20);
	if (lseek(n, 0L, SEEK_SET) != 0L) e(39);
	if ((j = read(n1, b, 1024)) != 255) e(40);
	if (unlink("T3b") < 0) e(41);
	if (close(n) < 0) e(42);
	if (close(n1) < 0) e(43);

  }
}


e(n)
int n;
{
  int err_num = errno;		/* save errno in case printf clobbers it */

  printf("Subtest %d,  error %d  errno=%d  ", subtest, n, errno);
  errno = err_num;		/* restore errno, just in case */
  perror("");
  if (errct++ > MAX_ERROR) {
	printf("Too many errors; test aborted\n");
	exit(1);
  }
}
