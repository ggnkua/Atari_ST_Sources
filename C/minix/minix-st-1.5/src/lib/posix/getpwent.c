/* get entry from password file
 *
 * By Patrick van Kleef
 *
 * James R. Stuhlmacher  Nov. 1989
 *  - Modified for POSIX conformance.
 */

#include <lib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <pwd.h>
#include <stdlib.h>
#include <string.h>

#define BUFFERSIZE 1024
#define PWBUFSIZE 256

PRIVATE char _pw_file[] = "/etc/passwd";
PRIVATE char _pwbuf[PWBUFSIZE];
PRIVATE char _buffer[BUFFERSIZE];
PRIVATE char *_pnt;
PRIVATE char *_buf;
PRIVATE int _pw = -1;
PRIVATE int _bufcnt;
PRIVATE struct passwd _pwd;

PRIVATE _PROTOTYPE( int getline, (void)		);
PRIVATE _PROTOTYPE( void skip_period, (void)	);

PUBLIC int setpwent()
{
  if (_pw >= 0)
	lseek(_pw, (off_t) 0, SEEK_SET);
  else
	_pw = open(_pw_file, O_RDONLY);

  _bufcnt = 0;
  return(_pw);
}


PUBLIC void endpwent()
{
  if (_pw >= 0) close(_pw);

  _pw = -1;
  _bufcnt = 0;
}

PRIVATE int getline()
{
  if (_pw < 0 && setpwent() < 0) return(0);
  _buf = _pwbuf;
  do {
	if (--_bufcnt <= 0) {
		if ((_bufcnt = read(_pw, _buffer, BUFFERSIZE)) <= 0)
			return(0);
		else
			_pnt = _buffer;
	}
	*_buf++ = *_pnt++;
  } while (*_pnt != '\n' && _buf < _pwbuf + PWBUFSIZE - 1);
  _pnt++;
  _bufcnt--;
  *_buf = '\0';
  _buf = _pwbuf;
  return(1);
}

PRIVATE void skip_period()
{
  while (*_buf != ':') _buf++;

  *_buf++ = '\0';
}

PUBLIC struct passwd *getpwent()
{
  if (getline() == 0) return((struct passwd *)NULL);

  _pwd.pw_name = _buf;
  skip_period();
  _pwd.pw_passwd = _buf;
  skip_period();
  _pwd.pw_uid = (uid_t) atoi(_buf);
  skip_period();
  _pwd.pw_gid = (gid_t) atoi(_buf);
  skip_period();
  _pwd.pw_gecos = _buf;
  skip_period();
  _pwd.pw_dir = _buf;
  skip_period();
  _pwd.pw_shell = _buf;

  return(&_pwd);
}

PUBLIC struct passwd *getpwnam(__name)
char *__name;
{
  struct passwd *pwd;

  setpwent();
  while ((pwd = getpwent()) != 0)
	if (!strcmp(pwd->pw_name, __name)) break;
  endpwent();
  if (pwd != 0)
	return(pwd);
  else
	return((struct passwd *)NULL);
}

PUBLIC struct passwd *getpwuid(__uid)
uid_t __uid;
{
  struct passwd *pwd;

  setpwent();
  while ((pwd = getpwent()) != 0)
	if (pwd->pw_uid == __uid) break;
  endpwent();
  if (pwd != 0)
	return(pwd);
  else
	return((struct passwd *)NULL);
}
