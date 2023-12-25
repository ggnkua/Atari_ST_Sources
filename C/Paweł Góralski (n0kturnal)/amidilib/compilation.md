## Compilation instructions
Clone repository somewhere. Local toolchain adjustments can be made in 'buildsystem/toolchain_*.scons' files. Go into AMIDILIB 'src' folder and enter:

```
scons --sconstruct=configuration_name 
```

where 'configuration_name' is "SConstruct_*" file from 'buildconfigs' folder. Each scons configuration name contains:

processor type:
* 000 - mc68000
* 020-40 - mc68020-40
* 060 - mc68060

build type:
* debug
* release

Additionally:
`brownelf` indicates use of brownelf toolchain
`nolibc` indicates that build uses custom startup code and doesn't use standard C library dependencies. Missing dependencies are provided, but anyone can supply their own.

Fpu support is turned off by default.

So, choose prefered configuration and enter above command to initiate build.

Everything is build in 'build' folder - 'aout' or 'brownelf' depending on used toolchain type.

To clean everything enter:
```
scons --sconstruct=./buildconfigs/configuration_name -c 
```

To list all build configuration options enter:
```
scons --sconstruct=./buildconfigs/configuration_name -h 
```