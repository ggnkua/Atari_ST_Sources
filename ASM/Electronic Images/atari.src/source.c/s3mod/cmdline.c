/***************************************************/
/* S3m/Mod player by Daniel Marks                  */
/*    GUS support by David Jeske                   */
/* (C) 1994 By Daniel Marks                        */
/* While we retain the copyright to this code,     */
/* this source code is FREE. You may NOT steal     */
/* the copyright of this code from us.             */
/* You may use it in any way you wish, in          */
/* any product you wish. We respectfully ask that  */
/* you email one of us, if possible, if you        */
/* produce something significant with this code,   */
/* or if you have any bug fixes to contribute.     */
/* We also request that you give credit where      */
/* credit is due if you include part of this code  */
/* in a program of your own.                       */
/*                                                 */
/* email: dlm40629@uxa.cso.uiuc.edu		   */
/*        jeske@intlink.net			   */
/*                                                 */
/* See the associated README file for Thanks       */
/***************************************************/

/* CMDLINE.C */

#include "cmdline.h"


char *str_parms=0;
char *flag_parms=0;
char *num_parms=0;

int               t_argc;
char            **t_argv;

char *null_string = "";

int parm_setup(int argc,char **argv,char *str_prms,char *flag_prms,
		char *num_prms)
{
  t_argc = argc;
  t_argv = argv;
  
  if (str_prms)
    str_parms = str_prms;
  else
    str_parms = null_string;
  if (flag_prms)
    flag_parms = flag_prms;
  else
    flag_parms = null_string;
  if (num_prms)
    num_parms = num_prms;
  else
    num_parms = null_string;

  return(0);
}




char *rnp_strrchr(char *in_string, char letter)
{
  if (!in_string)
    return (NULL);
  while (*in_string)
    if (*in_string == letter)
      return (in_string);
      else in_string++;
  return (NULL);
}

int rnp_get_num(char **string, long int *number)
{
  char ch;
  char neg = 0;
  long int num = 0;
  int error_code = -1;

  if (**string == '-')
  {
    (*string)++;
    neg = 1;
  }
  if (**string == '0')
  {
    (*string)++;
    ch = *(*string)++;
    if (ch > 'Z') ch -= ' ';
    if (ch == 'B')
    {
      while ((**string == '0') || (**string == '1'))
      {
        num = (num << 1) | (*(*string)++ & 0x01);
        error_code = 0;
      }
      if (neg) num = -num;
      *number = num;
      return (error_code);
    }
    if (ch == 'O')
    {
      while ((**string >= '0') && (**string <= '7'))
      {
        error_code = 0;
        num = (num << 3) | (*(*string)++ & 0x07);
      }
      if (neg) num = -num;
      *number = num;
      return (error_code);
    }
    if (ch == 'X')
    {
      while (ch = **string, ch = (ch>'Z') ? ch-(' '+48) : ch-48,
             ch = (ch>9) ? ch-7 : ch, ((ch >= 0) && (ch <= 15)))
      {
        error_code = 0;
        num = (num << 4) | ch;
        (*string)++;
      }
      if (neg) num = -num;
      *number = num;
      return (error_code);
    }
    (*string) -= 2;
  }
  while ((**string >= '0') && (**string <= '9'))
  {
    error_code = 0;
    num = (num * 10) + (*(*string)++ - 48);
  }
  if (neg) num = -num;
  *number = num;
  return (error_code);
}


/* My own favorite GETOPT substitute */
/* letter <= 32 means get non-flagged regular parameter # letter */
/* num_types  = letters that take numerical parameters */
/* str_types  = letters that take string parameters */
/* flag_types = letters that take no parameters */
/* str_value  = returned string value */
/* num_value  = returned numerical value */
/* argv/argc  = parameter list / parameter count */

int read_next_parm(char letter,
                   char *num_types, char *str_types, char *flag_types,
                   char **str_value, long int *num_value,
                   int argc, char **argv)
{
  int found = 0;
  char *cparm;
  char *str_parm;
  long int val;
  char ch;

  argc--;
  argv++;
  while (argc > 0)
  {
    argc--;
    cparm = *argv++;

    if (*cparm == '-')
    {
      cparm++;
      while (*cparm)
      {
        found = (((ch = *cparm) == letter) && (letter > 32)) ? 1 : 0;
        cparm++;
        if (rnp_strrchr(flag_types,ch))
        {
          if (found)
            return 1;
        }
        if (rnp_strrchr(str_types,ch))
        {
          if (*cparm)
             str_parm = cparm;
             else
             {
               if (argc)
               {
                 argc--;
                 str_parm = *argv;
                 if (str_parm)
                 {
                   if (*str_parm == '-')
                     str_parm = NULL;
                     else argv++;
                 }
               } else str_parm = NULL;
             }
          while (*cparm) cparm++;
          if (found)
          {
            if (!str_parm)
               return (-1);
            *str_value = str_parm;
            return (1);
          }
        }
        if (rnp_strrchr(num_types,ch))
        {
          if (*cparm)
             str_parm = cparm;
             else
             {
               if (argc)
               {
                 argc--;
                 str_parm = *argv;
                 if (str_parm)
                 {
                   if (*str_parm == '-')
                     str_parm = NULL;
                     else argv++;
                 }
               } else str_parm = NULL;
             }
          cparm++;
          rnp_get_num(&cparm,&val);
          if (found)
          {
            if (!str_parm)
              return (-1);
            if (rnp_get_num(&str_parm,num_value))
              return (-1);
            return (1);
          }
        }
      }
    } else
    {
      if (letter <= 32)
      {
        if (letter--,!(letter))
        {
          *str_value = cparm;
          return (1);
        }
      }
    }
  }
  if (letter <= 32)
  {
    *str_value = NULL;
    return (0);
  }
  if (rnp_strrchr(flag_types,letter))
    return (0);
  if (rnp_strrchr(str_types,letter))
    return (0);
  if (rnp_strrchr(num_types,letter))
    return (0);
  return (-1);
}

int read_parm(char letter, char **str_value, long int *num_value)
{
  if (read_next_parm(letter, num_parms, str_parms, flag_parms,
             str_value, num_value, t_argc, t_argv) == 1)
     return (1);
  return (read_next_parm(letter+' ', num_parms, str_parms, flag_parms,
             str_value, num_value, t_argc, t_argv) == 1);
}




