Milan SCSI-Driver - free release

After I stopped supporting the driver for a long time, I finally found
copies of the sources on an old backup disk. Since there was at least one
request, I am now releasing the source code under GNU GPL v2.

I have removed the code that was used for registration (ie. binding to a
special machine serial number), and the code that deals with the HDEX cookie
- that was a private interface used by HDDriver a long time ago, which I
promised I would not publish, and which sould not be required anymore. What
is left should work just like the last release (V1.3 from 1999), but I have
no toolchain to even compile-test it.

