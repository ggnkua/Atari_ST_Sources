/*
 * base64.c
 * John Rojewski	09/10/96
 *
 *
      Value Encoding  Value Encoding  Value Encoding  Value Encoding
           0 A            17 R            34 i            51 z
           1 B            18 S            35 j            52 0
           2 C            19 T            36 k            53 1
           3 D            20 U            37 l            54 2
           4 E            21 V            38 m            55 3
           5 F            22 W            39 n            56 4
           6 G            23 X            40 o            57 5
           7 H            24 Y            41 p            58 6
           8 I            25 Z            42 q            59 7
           9 J            26 a            43 r            60 8
          10 K            27 b            44 s            61 9
          11 L            28 c            45 t            62 +
          12 M            29 d            46 u            63 /
          13 N            30 e            47 v
          14 O            31 f            48 w         (pad) =
          15 P            32 g            49 x
          16 Q            33 h            50 y
*/
	char b64table[70] ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
void b64_outdec( FILE *fp, char *p, int num);
int  b64_fr(FILE *fp, register char *buf, int cnt);

void base64_encode( char *filein )
{
	FILE *fin,*fout;
	char fileout[FMSIZE],*p;
	char buf[50];
	int i,n,lines=0;

	fin = fopen( filein, "rb" );
	if (fin!=NULL) {
		strcpy(fileout,filein);
        if(p = rindex(fileout,'.')) { *p = '\0'; }
        strcat(fileout,".b64");

		fout = fopen( fileout, "wa" );
        for (;;) {
                n = b64_fr(fin,buf, 45);
				if (n>45) { fprintf( log, "n = %d\n", n); }
           /*     putchar(ENC(n)); */
                for (i = 0; i < n; i += 3)
                      b64_outdec(fout,&buf[i],n-i);
           /*     putchar(uue_part); */
                putc('\n',fout);
                ++lines;
                if (n <= 0) { break; }
        }
#if (0)
		in[0] = '\0';
		for (;;) {			/* while data to read */
			for (line=0;line<15;line++) {
				/* encode = get 3 characters, output 4 characters */
				if (b64_get3( fin, in )>0) {
					b64_3to4( in, out );
					out[4] = '\0';
					sprintf( fout, "%s", out );
				}
			}
			if (out[4]=='=') { break; }	/* pad found */
			fprintf( fid, "\r\n" );		/* output crlf */
		}
#endif
		fclose( fin );
		fclose( fout );
		strcpy(filein,fileout);	/* point to encoded file */
	}
}

#if (0)
void b64_3to4( long *in, char *out ) 
{
	char byte[4];
	int num,c;

	byte[0] = (in&0x00fc0000)>>18;	/* high 6 bits */
	byte[1] = (in&0x0003f000)>>12;
	byte[2] = (in&0x00000fc0)>>6;
	byte[3] = in&0x0000003f;	/* low 6 bits */
	for (c=0;c<4;c++) {
		out[c] = b64table[byte[c]];
	}
	num = (int)in[0];		/* number of input bytes */
	if (num<3) { 			/* i.e. 1 or 2 bytes */
		out[3]='=';
		if (num<2) { out[2]='='; }
	}
}
#endif

void b64_outdec( FILE *fp, char *p, int num)
{
	register int c1, c2, c3, c4;

	c1 = (*p >> 2) & 63;
	c2 = (*p << 4) & 060 | (p[1] >> 4) & 017;
	c3 = (p[1] << 2) & 074 | (p[2] >> 6) & 03;
	c4 = p[2] & 077;
/*		if (c1>63) { fprintf( log, "c1 = %d\n", c1); } */
/*		if (c2>63) { fprintf( log, "c2 = %d\n", c2); } */
	putc(b64table[c1],fp);
	putc(b64table[c2],fp);
	if (num==1) { fputs("==",fp); return; }
/*	if (c3>63) { fprintf( log, "c3 = %d\n", c3); } */
	putc(b64table[c3],fp);
	if (num==2) { putc('=',fp); return; }
/*	if (c4>63) { fprintf( log, "c4 = %d\n", c4); } */
	putc(b64table[c4],fp);
	return;
}

/*
int b64_get3( FILE *fid, char *in )
{
	int num=3;

	in[1] = fgetc( fid );
	in[2] = fgetc( fid );
	in[3] = fgetc( fid );
	in[0] = (char)num;
	return(num);
}
*/

int b64_fr(FILE *fp, register char *buf, int cnt)
{
        register int c, i;
        for (i = 0; i < cnt; i++) {
                c = fgetc(fp);
                if (feof(fp))
                        return(i);
                buf[i] = c;
        }
        return (cnt);
}

#if (0)
void base64_decode( char *filein )
{
	FILE *fin,*fout;
	char fileout[FMSIZE];
	char in[4],out[3];

	fin = fopen( filein, 'r' );
	if (fin!=NULL) {
		fout = fopen( fileout, 'w' );
		/* decode = get 4 characters, output 3 characters */
		fclose( fin );
		fclose( fout );
	}
}

int b64get4( FILE *fid, char *in )
{
	char byte[4];

	/* discard '\r', '\n'.  If character is not in b64table, indicate error */
	/* if '=', move as is */
	byte[0] = strchr( b64table, fgetc( fid ));
}
#endif
