
#ifndef __OLDDISK_H
#define __OLDDISK_H

#define	JK_O_RO		0
#define	JK_S_BEG	0
#define JK_S_CUR	1
#define JK_S_END	2
#define JK_C_RW		0

#define jk_open(file,s)		Fopen( file, s )
#define	jk_close(h)		Fclose(h)
#define	jk_read(h,cnt,buf)	Fread( h, cnt, buf )
#define	jk_write(h,cnt,buf)	Fwrite( h, cnt, buf )
#define	jk_create(file,mode)	Fcreate( file, mode )
#define	jk_seek(pos,h,mode)	Fseek( pos, h, mode )

#endif

