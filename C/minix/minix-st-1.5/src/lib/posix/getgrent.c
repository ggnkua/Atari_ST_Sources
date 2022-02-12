/* get entry from group file
 *
 * By: Patrick van Kleef
 *
 * James R. Stuhlmacher   Nov 1989
 *  - Added group members.
 *  - Modified for POSIX conformance.
 */

#include <lib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <grp.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define GRBUFSIZE  256
#define BUFFERSIZE 1024
#define GRMEMMAX  32

PRIVATE char _gr_file[] = "/etc/group";
PRIVATE char _grbuf[GRBUFSIZE];
PRIVATE char _buffer[BUFFERSIZE];
PRIVATE char *_grmem[GRMEMMAX + 1];
PRIVATE char *_pnt;
PRIVATE char *_buf;
PRIVATE int _gfd = -1;
PRIVATE int _bufcnt;
PRIVATE struct group _grp;

PRIVATE _PROTOTYPE( int getline, (void));
PRIVATE _PROTOTYPE( void skip_period, (int c));

PUBLIC int setgrent()
{
  if (_gfd >= 0)
	lseek(_gfd, (off_t) 0, SEEK_SET);
  else
	_gfd = open(_gr_file, O_RDONLY);

  _bufcnt = 0;
  return(_gfd);
}


PUBLIC void endgrent()
{
  if (_gfd >= 0) close(_gfd);

  _gfd = -1;
  _bufcnt = 0;
}


PRIVATE int getline()
{
  if (_gfd < 0 && setgrent() < 0) return(0);

  _buf = _grbuf;
  do {
	if (--_bufcnt <= 0) {
		if ((_bufcnt = read(_gfd, _buffer, BUFFERSIZE)) <= 0)
			return(0);
		else
			_pnt = _buffer;
	}
	*_buf++ = *_pnt++;
  } while (*_pnt != '\n' && _buf < _grbuf + GRBUFSIZE - 1);
  _pnt++;
  _bufcnt--;
  *_buf = '\0';
  _buf = _grbuf;
  return(1);
}

PRIVATE void skip_period(c)
char c;
{
  while ((*_buf) && (*_buf != c)) _buf++;
  if (*_buf) *_buf++ = '\0';
}

PUBLIC struct group *getgrent()
{
  char **_grmem_ptr;

  if (getline() == 0) return((struct group *)NULL);

  _grp.gr_name = _buf;
  skip_period(':');
  skip_period(':');		/* gr_passwd is not in POSIX */
  _grp.gr_gid = (gid_t) atoi(_buf);
  skip_period(':');
  _grp.gr_mem = _grmem;
  _grmem_ptr = _grmem;
  while ((*_buf) && _grmem_ptr < _grmem + GRMEMMAX) {
	*_grmem_ptr++ = _buf;
	skip_period(',');
  }
  *_grmem_ptr = (char *)NULL;
  return(&_grp);
}

struct group *getgrnam(name)
char *name;
{
  struct group *grp;

  setgrent();
  while ((grp = getgrent()) != 0)
	if (!strcmp(grp->gr_name, name)) break;
  endgrent();
  if (grp != 0)
	return(grp);
  else
	return((struct group *)NULL);
}

struct group *getgrgid(gid)
gid_t gid;
{
  struct group *grp;

  setgrent();
  while ((grp = getgrent()) != 0)
	if (grp->gr_gid == gid) break;
  endgrent();
  if (grp != 0)
	return(grp);
  else
	return((struct group *)NULL);
}
