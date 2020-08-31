git submodule update --recursive
#git submodule foreach git pull origin master
git pull --recurse-submodules
git submodule foreach git fetch --progress --all
