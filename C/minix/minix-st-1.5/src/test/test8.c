/* test 8 */

#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

#define MAX_ERROR 4

extern int errno;
int subtest, errct;
extern off_t lseek();


main()
{
  int i;

  printf("Test  8 ");
  for (i = 0; i < 4; i++) {
	test80();
  }
  printf("ok\n");
}



test80()
{
/* Test mknod, chdir, chmod, chown, access.  */

  int i, j;
  struct stat s;

  subtest = 0;
  if (getuid() != 0) return;
  for (j = 0; j < 2; j++) {
	umask(0);

	if (chdir("/") < 0) e(1);
	if (mknod("dir", 040700, 0) < 0) e(2);
	if (link("/", "/dir/..") < 0) e(3);
	if (mknod("T3a", 0777, 0) < 0) e(4);
	if (mknod("/dir/T3b", 0777, 0) < 0) e(5);
	if (mknod("dir/T3c", 0777, 0) < 0) e(6);
	if ((i = open("/dir/T3b", 0)) < 0) e(7);
	if (close(i) < 0) e(8);
	if ((i = open("dir/T3c", O_RDONLY)) < 0) e(9);
	if (close(i) < 0) e(10);
	if (chdir("dir") < 0) e(11);
	if ((i = open("T3b", 0)) < 0) e(12);
	if (close(i) < 0) e(13);
	if ((i = open("../T3a", O_RDONLY)) < 0) e(14);
	if (close(i) < 0) e(15);
	if ((i = open("../dir/../dir/../dir/../dir/../dir/T3c", O_RDONLY)) < 0)
		e(16);
	if (close(i) < 0) e(17);

	if (chmod("../dir/../dir/../dir/../dir/../T3a", 0123) < 0) e(18);
	if (stat("../dir/../dir/../dir/../T3a", &s) < 0) e(19);
	if ((s.st_mode & 077777) != 0123) e(20);
	if (chmod("../dir/../dir/../T3a", 0456) < 0) e(21);
	if (stat("../T3a", &s) < 0) e(22);
	if ((s.st_mode & 077777) != 0456) e(23);
	if (chown("../dir/../dir/../T3a", 20, 30) < 0) e(24);
	if (stat("../T3a", &s) < 0) e(25);
	if (s.st_uid != 20) e(26);
	if (s.st_gid != 30) e(27);

	if ((i = open("/T3c", O_RDONLY)) >= 0) e(28);
	if ((i = open("/T3a", O_RDONLY)) < 0) e(29);
	if (close(i) < 0) e(30);

	if (access("/T3a", 4) < 0) e(31);
	if (access("/dir/T3b", 4) < 0) e(32);
	if (access("/dir/T3d", 4) >= 0) e(33);

	if (unlink("T3b") < 0) e(34);
	if (unlink("T3c") < 0) e(35);
	if (unlink("..") < 0) e(36);
	if (chdir("/") < 0) e(37);
	if (unlink("dir") < 0) e(38);
	if (unlink("/T3a") < 0) e(39);
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
