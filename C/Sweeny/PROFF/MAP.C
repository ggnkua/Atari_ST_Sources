#include <stdio.h>
/*
 * map map every character of s1 that is specified in s2
 * into s3 and replace in s. (source s1 remains untouched)
 */

map(s,s1,s2,s3)
register char *s;
register char *s1;
register char *s2;
register char *s3;
{
	char *t, *t1;
	if (*s1 != '\0') {
		t = s;
		t1 = s1;
		strcpy(t,t1);

		while (*s2 != '\0' && *s3 != '\0') {
			while (*t1 != '\0') {
				if (*t1 == *s2)
					*t = *s3;
				t++;
				t1++;
			}
			t = s;
			t1 = s1;
			s2++;
			s3++;
		}
	}
	else
		*s = '\0';
}

/*
 * roman - convert a numeric string into roman numerals
 *
 * icon version:
 *procedure roman(n)
 * local arabic, result
 * static equiv
 * initial equiv := ["","I","II","III","IV","V","VI","VII","VIII","IX"]
 * integer(n) > 0 | fail
 * result := ""
 * every arabic := !n do
 *    result := map(result,"IVXLCDM","XLCDM**") || equiv[arabic+1]
 * if find("*",result) then fail else return result
 * end
 *
 */
int
cvtroman(num,rom)
char *num;
char *rom;
{
	char tmp[20];

static char *equiv_U[] = { "","I","II","III","IV","V","VI","VII","VIII","IX" };

	*rom = NULL;
	while (*num != '\0') {
		map(tmp,rom,"IVXLCDM","XLCDM**");
		strcpy(rom,tmp);
		strcat(rom,equiv_U[*num - '0']);
		num++;
	}
	return(strlen(rom));
}

