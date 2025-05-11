
/* stuff for reading env vars sent in by Gulam */

extern char ** environ;

char * env_value (tag)
char * tag;
/* (declare (values string-or-nil)) */
{
/* the old way...
  char * s;

  for (s = *environ ; s && (strlen(s) > 0) ; )
	if (!strncmp(s, tag, strlen(tag)))
		{
		return(s + strlen(tag) + 1);
		}
	    else
		{
		s = s + strlen(s) + 1;
		}
*/
  char ** var;
  char * name;

  for (var = environ ; name = *var ; var++)
	{
	if ((!strncmp(name, tag, strlen(tag))) 
	    && (name[strlen(tag)] == '='))
		return(name + strlen(tag) + 1);
	}
/* */
  return(0);
}

char * getenv(tag)
char * tag;
{
  return(env_value(tag));
}
