#! /usr/bin/env python 
#--------------------------------------------------------------------------------------------------
# used libs
import sys
import os.path
import re

#--------------------------------------------------------------------------------------------------

def scanFolders(rootdir,builddir,cachedir):
	
	listfile_path = os.path.join(cachedir,"buildcache.mk")
	
	if os.path.exists( listfile_path ):
		os.remove(listfile_path)
		
	depsfile_path = os.path.join(cachedir,"buildcache2.mk")
	
	if os.path.exists( depsfile_path ):
		os.remove(depsfile_path)
				
	list_file = open(listfile_path,"w")
	deps_file = open(depsfile_path,"w")

	#list_file.write("FILES:= \\\n")
	deps_file.write("BUILDFILES:= " + os.path.join(builddir,"build.conf") + " \\\n" )

	global buildtarget
	target_name = "["+buildtarget+"]"
	
	pattern1 = re.compile(	"(?:[\s]+)?" +			#strip white spaces if they exist
							"([\w/\.\-\>{}]+)" +	#accept files, like "grammar.y->grammar.c<lexical.c>"
							"(?:[\s]+)?" +			#strip white spaces if they exist
							"([\[\w\[\]]+)?" +		#accept build name, like "[FALCON060]
							"(?:[\s]+)?", re.X )	#strip white spaces if they exist

	pattern2 = re.compile(	"([\w\./\_]+)" +			#find file
							"({[\w\.]+})?", re.X )	#find dependency
	
	strip_build_target = re.compile("(\[.*?\])")
			
	def scanDir(path):
									
		buildfile_name = os.path.join(path,"buildfiles")
		#print "BUILD FILE NAME: " + buildfile_name
		
		if os.path.exists(buildfile_name) and os.path.isfile(buildfile_name):

			deps_file.write(" " + buildfile_name + " \\\n")
			buildfile = open(buildfile_name,"r")
			filelist = buildfile.readlines()			
			for raw_file_name in filelist:
				raw_file_name = raw_file_name.replace("\n","").replace("\r","")
				name_target = pattern1.match( raw_file_name )
				
				file_string = ""
				if name_target.group(1) != None:					
					file_string = name_target.group(1)
				target_string = ""
				if name_target.group(2) != None:
					target_string = name_target.group(2)
			
				files = re.split( "->", file_string )


				files[0] = os.path.join(path,files[0])
				fullfile_no_dep = files[0].split("{")[0]
	
				exclude_file = False
	
				# check if we should build this file for the target we're building
	
				targets = strip_build_target.findall(target_string)
				if targets:
					exclude_file = True
					for target in targets:
						if target == target_name:
							#print target,target_name,file_string
							exclude_file = False
					if exclude_file == True:
						continue
	
				if os.path.exists(fullfile_no_dep):
					if os.path.isfile(fullfile_no_dep):
						stem = os.path.basename(files[0]).split(".")[0]
						files.append( stem + ".o" )
						files.reverse()
						
						for i in range(len(files)-1):							
							files[i] = cachedir + "/" + files[i]
						#print files
						source_file = files.pop()
						
						while len(files) > 0:
								
							dest_file_raw = files.pop()
							dest_file = dest_file_raw.split("{")[0]								

							# now, extract name and dependancies

							
							file_dep = pattern2.match( source_file )
							
							source_file_string = ""
							if file_dep.group(1) != None:					
								source_file_string = file_dep.group(1)
							dep_string = ""
							if file_dep.group(2) != None:
								#TODO: change this hack to allow multiple deps to point to cache
								dep_string = cachedir + "/" + file_dep.group(2).replace("{","").replace("}","")
							
							#print "DEP:" + dep_string + " FILE:" + source_file_string

							#second = cachedir + "/" + os.path.basename( source_file_string )							
							
							mangled_name = os.path.basename(dest_file).replace(".","_")
							generated_dep = os.path.basename(dest_file).replace(".","_") + "_dep2"
							
							list_file.write(  generated_dep + "?="  + source_file_string +"\n")

							list_file.write( mangled_name + "_dep=" + " " + dep_string + " $(" + generated_dep + ")"+"\n" )
							
							full_dep = dest_file + ": $(" + mangled_name + "_dep)" 
							list_file.write( full_dep + "\n" )
							
							source_suf = source_file_string.split(".").pop()
							dest_suf = dest_file.split(".").pop()
							
							list_file.write( "\t" + "$(call compile_" + source_suf + "_" + dest_suf + "_template," + source_file_string + "," + generated_dep + ")" + "\n")
							source_file = dest_file_raw
							if len(files) == 0:
								list_file.write( "OBJS += " + dest_file + "\n" )
						
						#list_file.write( " " + fullfile + " \\\n")
					else:
						#print "RAW FILE: " + os.path.join(path,raw_file_name) 
						scanDir(os.path.join(path,file_string) )
				else:
					print "Error: folder or file doesn't exist:"
					print os.path.join(path,raw_file_name)
					sys.exit()
		return
		
		
	scanDir( rootdir )
	
	list_file.write("\n")
	deps_file.write("\n")

#--------------------------------------------------------------------------------------------------

rootdir = sys.argv[2]
builddir = sys.argv[3]
cachedir = sys.argv[4]
buildtarget = sys.argv[5]

if not os.path.exists(cachedir):
	os.mkdir(cachedir)

if sys.argv[1] == "-build":
	scanFolders(rootdir,builddir,cachedir)
else:
	print "FATAL ERROR! UNKNOWN TASK IN BUILD HELPER!"
	