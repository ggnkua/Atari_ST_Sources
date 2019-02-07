/***************************************************************************/
/*                                                                         */
/*  Structured I/O in C.  Written by Harry Koons.                          */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing.    */
/*                                                                         */
/***************************************************************************/
/*                                                      */
/*      The purpose of this module is to give           */
/*      a practical demonstration of input/output       */
/*      using C structures                              */
/*                                                      */

/*----- Alcyon Include File-----------------*/

#include "osbind.h"    /* 6/26/86 MGL */

#define NAMESIZE 30
#define ADRSIZE  30
#define RMODE_RD 0      /* read a disk file */
#define RMODE_WR 1      /* write a disk file */
#define CLEAR 0         /* clear variable */
#define SET 1           /* set variable */
#define PRINT 2         /* print variable */

struct date {
        int day;
        int month;
        int year;
        int yearday;
        char mon_name[4];
};

struct person {
        char name[NAMESIZE];
        char address[ADRSIZE];
        long zipcode;
        long ss_number;
        double salary;
        struct date birthdate;
        struct date hiredate;
} employee;


/*--------------------------------------*/
/*      main()                          */
/*      test structure io in C          */
/*--------------------------------------*/
main()
{
        do_test(PRINT);         /* verify that structure is empty */
        do_test(SET);           /* put sample data in structure */
        do_test(PRINT);         /* verify that data is in the structure */
        
        printf("write\n");
        file_emp(RMODE_WR);     /* write the file */

        do_test(CLEAR);         /* set structure to zeros */
        do_test(PRINT);         /* verify that structure is empty */
        
        printf("read\n");
        file_emp(RMODE_RD);     /* read from the file */
        
        do_test(PRINT);         /* verify that data is in the structure */

        while (!Cconis());      /* wait for key to quit */
                ;
}

/*--------------------------------------*/
/*      file_emp()                      */
/*      definition of data file         */
/*--------------------------------------*/
file_emp(mode)
int mode;
{
        char *strcpy();
        long do_io();
        char file_name[15];
        int file_handle;
        long length;
        long location;
        long result;

        strcpy(file_name, "A:EMPLOYEE.DAT");

        file_handle = Fopen(file_name, mode);

        /* file not found on disk */
        if (file_handle < 0)
        {       file_handle = Fcreate(file_name, 0);
                Fclose(file_handle);
                file_handle = Fopen(file_name, mode);
        }

        length = sizeof(employee);
        location = &employee;
        result = do_io(file_handle, length, location, mode);

        Fclose(file_handle);
}

/*--------------------------------------*/
/*      do_io()                         */
/*      actual input/output routine     */
/*--------------------------------------*/
long do_io(file_handle, length, location, mode)
int file_handle, mode;
long length, location;
{
        long result;
        
        if ( mode == RMODE_WR )
                result = Fwrite(file_handle, length, location);
        else
                result = Fread(file_handle, length, location);

        return (result);
}

/*--------------------------------------*/
/*      do_test                         */
/*      trivial one variable test       */
/*--------------------------------------*/
do_test(which)
int which;
{
        switch(which)
        {
        case PRINT:
                printf("salary = %f\n", employee.salary);
                break;
        case CLEAR:
                employee.salary = 0.0;
                break;
        case SET:
                employee.salary = 50000.0;
                break;
        }
}

