#ifdef __PUREC__

/* simulate functions calls we don't have. Perhaps not always properly! */

int access( char *name, short dummy ) {
	struct stat st;
	int rc;
	rc = stat( name, &st );
	return rc;
}


#endif