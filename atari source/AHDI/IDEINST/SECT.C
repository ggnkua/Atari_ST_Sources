/* sect.c */

#include <osbind.h>


/*
 * Get physical unit's root block.
 */
getroot(dev, buf)
int dev;
char buf[];
{
    dev += 2;
    return (Rwabs(8, buf, 1, 0, dev));
}


/*
 * Write physical unit's root block.
 */
putroot(dev, buf)
int dev;
char buf[];
{
    dev += 2;
    return (Rwabs(9, buf, 1, 0, dev));
}


/*
 * Get logical drive's boot block.
 */
getboot(ldev, buf)
int ldev;
char buf[];
{
    ldev += 2;
    return (Rwabs(0, buf, 1, 0, ldev));
}


/*
 * Write physical unit's boot block.
 */
putboot(ldev, buf)
int ldev;
char buf[];
{
    ldev += 2;
    return (Rwabs(1, buf, 1, 0, ldev));
}


