double atof(nptr)
char *nptr;
{
    double result;

    if (sscanf(nptr, "%lf", &result) != 1)
		return 0;

    return result;
}
