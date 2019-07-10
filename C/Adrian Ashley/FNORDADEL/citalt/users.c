/************************************************************************
 * Citadel utility to make a neat Users.hlp from the output of CLOG.	*
 *   Makes a neat Users.hlp, and a file with name, password, and	*
 *   aide status.							*
 *									*
 *  Version 1: Just output containing Format Proof Users info.		*
 *             needed redirection to store the info.			*
 *									*
 *  Version 2: Added Statistics, and the use of Installation.sys	*
 *									*
 *  Version 3: If there is no password file, don't generate password	*
 *		information.						*
 ************************************************************************/

/*********************************************************************
 *                                                                   *
 *  Requires a file containing 2 lines, called Installation.sys      *
 *                                                                   *
 *  It must contain:                                                 *
 *                                                                   *
 *  Line 1:  System's name, as it is to be put in Users.hlp          *
 *  Line 2:  The file to put the Password info in.                   *
 *********************************************************************/

#include "ctdl.h"

#define maxColList 256
#define percen(count1,count2) round(((float)count1/(float)count2)*100.0)

char *program = "users";

int Cols[maxColList];

main(argc,argv)
int argc;
char *argv[];
{
    FILE *temp, *users, *pw, *fopen();  
    char c;
    int  UserCount=0, AideCount=0, ExpertCount=0, i=0, j;
    int  showAide=NO;
    char aide, expert;
    char sysnam[80], name[21], Columns[10];
    char password[20], pwfile[80];
    char line[80];
    int  Chold;    		/* Holds integer version of # of columns */


    for (j=0;j<maxColList;j++)
	Cols[j] = 0;
    fprintf(stderr, "Users V3 by Eric A. Griff, Aug 11, 1988\n");

    /* Show aide info? */
    showAide = (argc >= 2 && stricmp(argv[1],"-a") == 0);

    if (temp=fopen("Installation.sys", "r")) {
	fgets(sysnam, 80, temp);
	strtok(sysnam,"\n");
	if (fgets(pwfile, 80, temp)) 
	    strtok(pwfile,"\n");
	else pwfile[0] = 0;
	fclose(temp);
    }
    else
	crashout("Cannot find Installation.sys");

    if (users=fopen("users.hlp", "w"))
	fprintf(users,"  Users of %s\n",sysnam);
    else
	crashout("Error opening users.hlp");

    if (pwfile[0] && (pw=fopen(pwfile,"w")))
	fprintf(pw,"  Password info of %s\n",sysnam);
    else if (pwfile[0]) {
	fclose(users);
	crashout("Error opening %s for password output", pwfile);
    }
    else pw = NULL;

    while (gets(line)) {
	strtok(line,"\n");
	if (strlen(line) < 76)
	    continue;
	slice(line,  6, 25, name);
	slice(line, 27, 46, password);
	slice(line, 70, 76, Columns);
	aide   = (line[48] != 'N');
	expert = (line[58] != 'N');
	UserCount++;

	if (aide)
	    AideCount++;
	if (expert)
	    ExpertCount++;
	    
	Chold = 0xff & atoi(Columns);
	Cols[Chold]++;

	fprintf(users, " %20s ", name);
	if (showAide)
	    fprintf(users, "%8s, ", aide ? "Aide" : "Not aide");
	fprintf(users, "%10s, %3d Columns.\n",
			    expert ? "Expert" : "Not expert", Chold);

	if (pw)
	    fprintf(pw, "  %s|%s| %s\n", name, password, aide ? "Aide" : "Not aide");
    }
    /*
     * Put statistics to Users.hlp, aide if 'a' specified
     */
    fprintf(users,"\n                 Some Statistics of %s\n", sysnam);
    fprintf(users, "                    Total users: %d\n", UserCount);
    if (showAide) 
	fprintf(users, "                    Total Aides: %d (%d%%)\n",
					    AideCount,
					    percen(AideCount,UserCount));
    if (pw)
	fprintf(pw, "                    Total Aides: %d (%d%%)\n",
					    AideCount,
					    percen(AideCount,UserCount));
    fprintf(users, "                  Total Experts: %d (%d%%)\n\n",
					ExpertCount,
					percen(ExpertCount,UserCount));

/* Put the already sorted Columns and totals at the end */
    for (i=0; i<maxColList; i++)
	if (Cols[i] > 0)
	    fprintf(users, "  Total users using %3d columns: %d (%d%%)\n",
			    i, Cols[i], percen(Cols[i],UserCount));
    if (pw)
	fclose(pw);
    fclose(users);
}


slice(line, start, end, dest)
char *line, *dest;
{
    int i=0;

    if (strlen(line) >= start)
	while (start<=end)
	    dest[i++] = line[start++];
    dest[i] = 0;
}


round(val)
float val;
{
    int i = (int) val;

    if (val - (float)(i) >= 0.5)
	return i+1;
    return i;
}
