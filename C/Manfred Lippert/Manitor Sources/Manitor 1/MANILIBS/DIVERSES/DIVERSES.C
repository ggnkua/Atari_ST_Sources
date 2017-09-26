#include <i:\c\fremde\manitor\manilibs\diverses\diverses.h>
#include <string.h>
#include <stdlib.h>

#include <mgx_dos.h>

void beep(void) {		/* System-Beep */
	Cconout(7);
}

char slow_upper(char c) {
	if (c >= 'a' && c <= 'z')
		return c - ('a'-'A');
	else if (c == '„')
		return 'Ž';
	else if (c == '”')
		return '™';
	else if (c == '')
		return 'š';
	return c;
}

char slow_lower(char c) {
	if (c >= 'A' && c <= 'Z')
		return c + ('a'-'A');
	else if (c == 'Ž')
		return '„';
	else if (c == '™')
		return '”';
	else if (c == 'š')
		return '';
	return c;
}

char upper_tab[256];
char lower_tab[256];

void upper_init(void) {
	int i;
	for(i = 0; i < 256; i++) {
		upper_tab[i] = slow_upper((char)i);
	}
}

void lower_init(void) {
	int i;
	for(i = 0; i < 256; i++) {
		lower_tab[i] = slow_lower((char)i);
	}
}

void str_upper(char *string) {
	while ((*string = upper(*string)) != 0)
		string++;
}

void str_lower(char *string) {
	while ((*string = lower(*string)) != 0)
		string++;
}

void kill_space(char *txt) {
	char *anf;
	int len = (int)strlen(txt);
	while (len > 0 && txt[len - 1] == ' ')
		len--;
	txt[len] = '\0';
	anf = txt;
	while (*anf == ' ')
		anf++;
	if (anf != txt)
		strcpy(txt, anf);
}

void insert_space(char *txt, int spaceanz) {
	if (spaceanz > 0) {
		int len = (int)strlen(txt);
		memmove(txt + spaceanz, txt, len + 1);
		memset(txt, ' ', spaceanz);
	}
}

static boolean match_bracked(char *pat, char *file, boolean grossklein) {
	int invers = (*pat == '!');
	if (invers)
		pat++;
	while (*pat != ']') {	/* Achtung! ']' muž vorhanden sein!!! */
		if (*(pat+1) == '-') {
			char von = *pat;
			char bis = *(pat + 2);
			char tmp;
			if (bis == ']')
				return FALSE;
			if (von > bis) {
				tmp = von;
				von = bis;
				bis = tmp;
			}
			if (!grossklein) {
				if (*file >= von && *file <= bis) {
					return !invers;
				}
			} else {
				char c = upper(*file);
				if (c >= upper(von) && c <= upper(bis)) {
					return !invers;
				}
			}
			pat += 2;
		} else {
			if (!grossklein) {
				if (*file == *pat) {
					return !invers;
				}
			} else {
				if (upper(*file) == upper(*pat)) {
					return !invers;
				}
			}
		}
		pat++;
	}
	return invers;
}

boolean match_exakt(char *pat, char *file) {
	boolean invers = FALSE;
	while (*pat == '!') {
		pat++;
		invers ^= TRUE;
	}
	if (invers) {
		return !match_exakt(pat, file);
	}

match_nochmal:
	switch (*pat) {
	case '\0':
		return (*file == '\0');
	case '?':
		if (*file++ == '\0')
			return FALSE;
		pat++; goto match_nochmal;	/* Belastet Stack weniger (und ist schneller) */
	case '*':
		do {
			pat++;
		} while (*pat == '*');
		if (*pat == '\0')
			return TRUE;
		{
			int back;
			while (*file != '\0') {
				back = match_exakt(pat, file++);
				if (back)
					return TRUE;
			}
			return FALSE;
		}
	case '[':
	{
		char *end = strchr(pat, (int)']');
		if (end == 0L)
			return FALSE;
		if (match_bracked(pat + 1, file, TRUE)) {
			pat = end + 1; file++; goto match_nochmal;	/* Belastet Stack weniger (und ist schneller) */
		}
		return FALSE;
	}
	default:
		if (*pat++ != *file++)
			return FALSE;
		goto match_nochmal;	/* Belastet Stack weniger (und ist schneller) */
	}
}

boolean match_grossklein(char *pat, char *file) {
	boolean invers = FALSE;
	while (*pat == '!') {
		pat++;
		invers ^= TRUE;
	}
	if (invers) {
		return !match_grossklein(pat, file);
	}

match_nochmal:
	switch (*pat) {
	case '\0':
		return (*file == '\0');
	case '?':
		if (*file++ == '\0')
			return FALSE;
		pat++; goto match_nochmal;	/* Belastet Stack weniger (und ist schneller) */
	case '*':
		do {
			pat++;
		} while (*pat == '*');
		if (*pat == '\0')
			return TRUE;
		{
			int back;
			while (*file != '\0') {
				back = match_grossklein(pat, file++);
				if (back)
					return TRUE;
			}
			return FALSE;
		}
	case '[':
		{
			char *end = strchr(pat, (int)']');
			if (end == 0L)
				return FALSE;
			if (match_bracked(pat + 1, file, TRUE)) {
				pat = end + 1; file++; goto match_nochmal;	/* Belastet Stack weniger (und ist schneller) */
			}
			return FALSE;
		}
	default:
		if (upper(*pat++) != upper(*file++))
			return FALSE;
		goto match_nochmal;	/* Belastet Stack weniger (und ist schneller) */
	}
}

boolean file_one_match(char *pat, char *file, boolean grossklein) {
/*
	size_t len = strlen(pat);
	if (len >= 3L && strcmp(pat + len - 3, "*.*") == 0)	/* Sonderfall aus DOS-Zeiten, dass *.* alles matched! (jetzt *) */
	{
		int back;
		pat[len - 2] = '\0';
		back = grossklein ? match_grossklein(pat, file) : match_exakt(pat, file);
		pat[len - 2] = '.';
		return back;
	}
*/

	/* Sonderfall * am Anfang, dahinter keine Wildcards mehr fr schnelleres Matching der *.EXT-F„lle */

	if (*pat == '*' && !strpbrk(pat + 1, "*?[]")) {
		int len1 = (int)strlen(++pat);
		int len2 = (int)strlen(file);
		return (len2 >= len1 && (grossklein ? stricmp(pat, file + len2 - len1) : strcmp(pat, file + len2 - len1)) == 0);
	}

	return (grossklein ? match_grossklein(pat, file) : match_exakt(pat, file));
}

boolean file_match(char *pat, char *file, boolean grossklein) {
/*
	char c;
	if (*pat == '*' && ((c = pat[1]) == 0 ||
								c == ',' ||
								(c == '.' && pat[2] == '*' && ((c = pat[3]) == 0 ||
																			c == ','))))
		return TRUE;
*/

	{
		int back;
		char kommamerk;
		char *komma;
		while ((komma = strpbrk(pat, ",|&")) != 0L) {	/* Komma = "oder", Kaufmannsund = "und" */
			kommamerk = *komma;
			*komma = 0;
			back = file_one_match(pat, file, grossklein);
			*komma = kommamerk;
			if (kommamerk == '&') {		/* "und" */
				if (!back) {
					return FALSE;
				}
			} else {							/* "oder" */
				if (back) {
					return TRUE;
				}
			}
			pat = komma + 1;
		}
	}
	return file_one_match(pat, file, grossklein);
}

/*
char *vorausmatchtrenner(char *pat) {
	char *komma = strchr(pat, ',');
	char *strp = strchr(pat, ';');
	char *trenn = komma;
	if (strp && (!komma || strp < komma))
		trenn = strp;
	return trenn;
}
*/

boolean file_vorausmatch(char *pat, char *file, boolean grossklein) {	/* Achtung! Ein Zeichen hinter pat wird beschrieben! (pat muž also l„nger allokiert sein!) */
	int back;
	char *trenn;
	char merk1, merk2;
	while ((trenn = strpbrk(pat, ",|;&+")) != 0L) {
		merk1 = trenn[0];
		merk2 = trenn[1];
		if (merk1 == ';' || merk1 == '+')
			trenn[0] = 0;
		else
			trenn[0] = '*';
		trenn[1] = 0;

		back = file_one_match(pat, file, grossklein);

		trenn[0] = merk1;
		trenn[1] = merk2;

		if (merk1 == '&' || merk1 == '+') {		/* "und" */
			if (!back) {
				return FALSE;
			}
		} else {											/* "oder" */
			if (back) {
				return TRUE;
			}
		}

		pat = trenn + 1;
	}
	if (pat[0]) {
		strcat(pat, "*");
		back = file_one_match(pat, file, grossklein);
		pat[strlen(pat) - 1] = 0;
		return back;
	}
	return FALSE;
}

/* maxlen ohne 0-Byte! */
void match_2_vorausmatch(char *in, char *out, int maxlen) {
	char *komma;
	strncpy(out, in, maxlen);
	out[maxlen] = 0;

/* Alle Kommas durch Strichpunkt ersetzen,
   Alle & durch + ersetzen
*/

	while ((komma = strpbrk(out, ",|&")) != 0L) {
		if (*komma == '&')
			*komma = '+';
		else
			*komma = ';';
		out = komma + 1;
	}

	if (*out) {	/* letztes Komma war nicht am Ende */
		int len = (int)strlen(out);
		if (len < maxlen) {
			out[len++] = ';';	/* ganz am Ende auch Strichpunkt */
			out[len] = 0;
		}
	}
}

boolean matching_includes_matching(char *pat, char *subpat, boolean grossklein) {
	boolean ok = TRUE;
	char kommamerk, subkommamerk;
	char *komma, *subkomma;
	char *patptr;

	do {
		subkomma = strpbrk(subpat, ",|&");
		if (subkomma) {
			subkommamerk = *subkomma;
			*subkomma = 0;
		}
	
		patptr = pat;
		ok = FALSE;
		do {
			komma = strpbrk(patptr, ",|&");
			if (komma) {
				kommamerk = *komma;
				*komma = 0;
			}

			if ((grossklein ? stricmp(subpat, patptr) : strcmp(subpat, patptr)) == 0) {	/* subpat-Teil kommt in pat vor */
				ok = TRUE;
				break;
			}

			if (komma) {	
				*komma = kommamerk;
				patptr = komma + 1;
			}
		} while (komma);

		if (!ok) {
			break;
		}

		if (subkomma) {
			*subkomma = subkommamerk;
			subpat = subkomma + 1;
		}
	} while (subkomma);

	return ok;
}

int16 Zufall16(int16 bereich) {
	if (!bereich)
		return 0;
	return (int16)(Random() % (long)bereich);
}

int16 relativ(int16 wert, int16 ist, int16 soll) {
	if (wert > 0)
		return (int16)(((int32)wert * soll + (ist/2)) / ist);
	return (int16)(((int32)wert * soll - (ist/2)) / ist);
}

char hexa[] = "0123456789ABCDEF";

int16 hexwert(char c) {
	char *pos = strchr(hexa, upper(c));
	if (!pos || !c)
		return -1;
	return (int16)(pos - hexa);
}

void nullitoa(char *txt, int16 wert, int16 anz) {
	int16 len;
	itoa(wert, txt, 10);
	len = (int16)strlen(txt);
	if (len < anz) {
		int16 i;
		int16 diff = anz - len;
		char *r = txt + anz;
		*r-- = 0;
		for(i = 0; i < len; i++) {
			*r = *(r - diff);
			r--;
		}
		for(i = 0; i < diff; i++) {
			*txt++ = '0';
		}
	}
}

int32 my_atol(char *txt) {
	while (*txt == '0' || *txt == '_')	/* Damits nicht oktal interpretiert wird */
		txt++;
	return (int32)atol(txt);
}

/* Achtung: ben”tigt > 1 KB Stack! */
char *quick_search(char *big, int32 big_len, char *small, int32 small_len)
{
	if (big_len < small_len || small_len <= 0) {
		return 0L;
	}
	{
		int32 tab[256];
		int32 i;
		uint8 *end = (uint8 *)big + big_len;
		uint8 *end2 = end - small_len;
		uint8 *ptr;
		uint8 *ptr2;
		int32 tabval;
		memset(tab, 0, 256*4);
		ptr = (uint8 *)small;
		for(i = 1; i <= small_len; i++) {
			tab[*ptr++] = i;	/* letztes Vorkommen des Zeichens in Tabelle vermerken */
		}
		for(ptr = (uint8 *)big + small_len - 1; ptr < end;) {
			if ((tabval = tab[*ptr]) != 0L) {	/* Zeichen kommt in Suchstring vor? */
				ptr2 = ptr - tabval + 1;
				if (ptr2 <= end2) {
					if (memcmp(ptr2, small, small_len) == 0) {
						return ptr2;	/* gefunden */
					}
				}
				ptr++;
			} else {
				ptr += small_len;	/* Zeichen kam nicht vor, Wort kann hier nicht stehen */
			}
		}
	}
	return 0L;
}
