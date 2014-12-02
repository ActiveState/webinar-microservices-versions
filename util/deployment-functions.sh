
stackato_hostname=`stackato info | perl -ne 'm|Target:.*//api.(\S+)| && print $1'`

function test_app_running {
  local app_url=$1
  curl $app_url --fail >/dev/null 2>&1
  if [ "$?" = "0" ]; then
    return 1
  else
    return 0
  fi
}

function deploy {
  local type=$1
  local name=$2
  local version=$3

  local name_dir=$name
  if [ "$type" = "mutable" ]; then
    name_dir=$name-$version
  fi
  local dir=$rootdir/$type/$name_dir

  echo
  echo "==> Deploying $1 $2"
  echo

  if [ ! -d $dir ]; then
    echo "No directory : $dir"
    exit 1
  fi

  if test_app_running http://$name.$stackato_hostname/$version/$name; then
    echo "Pushing app..."
    cd $dir
    stackato push --no-prompt
  else
    echo "Not pushing app version. Already running."
  fi
  echo
}

