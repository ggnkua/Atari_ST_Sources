
_splitpath(char *_src, char *_drive, char *_directory,
		char *_basename, char *_extension)
{
	char *firstslash,
	     *lastslash,
	     *cp;

	firstslash = strchr(_src, '/');
	lastslash = strrchr(_src, '/');

	if (_src[1] == ':') {
		strncpy(_drive, _src, 2);
		_drive[3] = '\0';
	}
	else _drive[0] = '\0';

	if (!firstslash || (firstslash == lastslash)) {
		_directory[0] = '\0';
		strcpy(_basename, _src);
		if (cp = strchr(_basename, '.')) {
			*cp++ = '\0';
			strcpy(_extension, cp);
		}
		else _extension[0] = '\0';
		return;
	}
	else {
		strcpy(_directory, firstslash);
		cp = strrchr(_directory, '/');
		*cp = '\0';
		strcpy(_basename, lastslash + 1);
		if (cp = strchr(_basename, '.')) {
			*cp++ = '\0';
			strcpy(_extension, cp);
		}
		else _extension[0] = '\0';
		return;
	}
}

