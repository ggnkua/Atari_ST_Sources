/*
 * door.h -- headers used for shell escapes
 *
 * shell escape information is kept in the file CTDLDOOR.SYS, which is composed
 * of lines of the following form:
 *
 * <cmd name> <access> <program name> [command tail] [#comment]
 *
 * like so:
 *
 * shell   s    a:\auto\tsh.prg  -N
 * arcp    ur   a:\bin\arc.tos p
 * popular a    a:\bin\tsh.prg a:\bin\popular.tos -m >! a:\library\popular
 * rogue   un   a:\bin\rogue.prg -tty
 *
 * permission modes for shell commands are as follows:
 *
 *  [z|s|a|u][t][n][d][r][w][c][m][x][v][p][h][i<room>][l<dir>]
 *  z == only TheSysop access
 *  s == only sysop access
 *  a == aide & sysop access
 *  u == universal access
 *  t == allow command tails
 *  n == pass username to the command as a command tail
 *  d == run in directory rooms only
 *  r == only executable in readable directories
 *  w == only executable in writable directories
 *  c == run on the console only
 *  m == run on the modem only
 *  x == flag for 'special' doors, not executable from normal command line
 *  v == 'archiver' door, for use in .RH
 *  p == file transfer protocol door (future extension)
 *  h == execute the command in the BBS' home directory (no link in dir rooms)
 *  i<room> == link the command to this room
 *  l<dir> == link the command to this directory
 *
 *  The command-line form for a shell escape is:
 *  !<name> <tail>
 *
 *  if you are not a sysop, you cannot use the characters '\' or ':' in
 *  a command tail.
 *
 */

#ifndef _DOOR_H
#define _DOOR_H

#define DOORCHARS	"zsautndrwcmxvphil"

struct doorway {
#define DOORSIZE	10
    char dr_name[DOORSIZE];
    long dr_mode;
#define	DR_USER		0x0000		/* ... + users			*/
#define	DR_AIDE		0x0001		/* ... + aides			*/
#define DR_SYSOP	0x0002		/* ... + SomeSysop()s		*/
#define DR_THESYSOP	0x0004		/* TheSysop() only		*/
#define DR_UMASK		0x0007
#define	DR_NAMED	0x0008		/* pass in username		*/
#define	DR_DIR		0x0010		/* directory rooms...		*/
#define	DR_WRITE	0x0020		/* only in writable dirs...	*/
#define	DR_READ		0x0040		/* only in readable dirs...	*/
#define DR_CONSOLE	0x0080		/* run on the console only?	*/
#define	DR_MODEM	0x0100		/* or the modem only?		*/
#define	DR_IOMASK		0x0180
#define	DR_LINKED	0x0200		/* link the program to a dir	*/
#define	DR_TAIL		0x0400		/* command tails are allowed	*/
#define DR_SPECIAL	0x0800		/* door for the system ONLY? 	*/
#define DR_PROTOCOL	0x1000		/* file transfer protocol?	*/
#define DR_ARCHIVER	0x2000		/* archiving program?		*/
#define DR_ROOM		0x4000		/* link the program to a room	*/
#define DR_HOME		0x8000		/* execute in home dir		*/
    char *dr_link;
    char *dr_cmd;			/* program...			*/
    char *dr_tail;			/* tail to pass in		*/
    char *dr_remark;			/* `what I do' comment...	*/
    struct doorway *dr_next;
} ;

#define	DR_BADROOM	((struct doorway*)(-3))	/* can't do this here        */
#define	DR_ACCESS	((struct doorway*)(-1))	/* no execute permissions    */

#endif /* _DOOR_H */
