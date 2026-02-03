r

/*------------------------------*/
/*      includes                */
/*------------------------------*/

#include "portab.h"                             /* portable coding conv */
#include "machine.h"                            /* machine depndnt conv */
#include "osbind.h"                             /* BDOS defintions      */
#include "gemdefs.h"

/*------------------------------*/
/*      open_file               */
/*------------------------------*/
        WORD
open_file(file_name)
        BYTE    *file_name;
        {
        LONG    dos_hndl;

        FOREVER
                {
                dos_hndl = Fopen(file_name, 0);
                if (dos_hndl >= 0)
                        return ((WORD) dos_hndl);
                if ( !dos_error((WORD) dos_hndl) )
                        return (-1);
                }

        return (-1);            /* Appease lint */
        }

/*------------------------------*/
/*      create_file             */
/*------------------------------*/
        WORD
create_file(file_name)
        BYTE    *file_name;
        {
        LONG    dos_hndl;

        FOREVER
                {
                dos_hndl = Fcreate(file_name, 0);
                if (dos_hndl >= 0)
                        return ((WORD) dos_hndl);
                if ( !dos_error((WORD) dos_hndl) )
                        return (-1);
                }

        return (-1);            /* Appease lint */
        }

/*------------------------------*/
/*      dos_error               */
/*------------------------------*/
        WORD
dos_error(tos_err)
        WORD    tos_err;
        {
        WORD    f_ret;

        graf_mouse(ARROW, 0x0L);
        if (tos_err > -50)
                {
                tos_err += 31;
                tos_err = -tos_err;
                }
        f_ret = form_error(tos_err);
        close_files();
        return (f_ret);
        }

/*------------------------------*/
/*      get_file                */
/*------------------------------*/
        WORD
get_file(extnt, got_file)
        BYTE    *extnt, *got_file;
        {
        WORD    butn, ii;
        BYTE    tmp_path[64], tmp_name[13];

        tmp_name[0] = '\0';
        tmp_path[0] = '\0';

        if (*got_file)
                parse_fname(got_file, tmp_path, tmp_name, extnt);
        if (!tmp_path[0])
                get_path(&tmp_path[0], extnt);

        fsel_input(tmp_path, tmp_name, &butn);
        if (butn)
                {
                strcpy(got_file, tmp_path);
                for (ii = 0; got_file[ii] && got_file[ii] != '*'; ii++);
                got_file[ii - 1] = '\0';
                strcat (got_file, "\\");
                strcat(got_file, tmp_name);
                return (TRUE);
                }
        else
                return (FALSE);
        }

/*------------------------------*/
/*      parse_fname             */
/*------------------------------*/
        VOID
parse_fname(full, path, name, extnt)
        BYTE    *full, *path, *name, *extnt;
        {
        WORD    i, j;
        BYTE    *s, *d;

        for (i = strlen(full); i--; )           /* scan for end of path */
                if (full[i] == '\\' || full[i] == ':')
                        break;
        if (i == -1)
                strcpy(name, full);             /* "Naked" file name */
        else
                {
                strcpy(name, &full[i+1]);
                for (s = full, d = path, j = 0; j++ < i + 1;
                        *d++ = *s++);
                strcpy(&path[i+1], "*.");
                strcat(path, extnt);
                }
        }

/*------------------------------*/
/*      get_path                */
/*------------------------------*/
        VOID
get_path(tmp_path, spec)
        BYTE    *tmp_path, *spec;
        {
        WORD    cur_drv;

        cur_drv = Dgetdrv();
        tmp_path[0] = cur_drv + 'A';
        tmp_path[1] = ':';
        Dgetpath(&tmp_path[2], 0);
        if (strlen(tmp_path) > 3)
                strcat(tmp_path, "\\");
        else
                tmp_path[2] = '\0';
        strcat(tmp_path, "*.");
        strcat(tmp_path, spec);
        }

/*------------------------------*/
/*      new_ext                 */
/*------------------------------*/
        VOID
new_ext(o_fname, n_fname, ext)
        BYTE    *o_fname, *n_fname, *ext;
        {
        WORD    ii, jj;

        strcpy(n_fname, o_fname);
        for (ii = (jj = strlen(n_fname)) - 1; ii && n_fname[ii] != '.'; ii--);
        if (!ii)
                n_fname[ii = jj] = '.';
        strcpy(&n_fname[++ii], ext);
        }



Press <CR> to continue !