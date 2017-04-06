#!/bin/sh
# WARNING: REQUIRES /bin/sh
#
# - must run on /bin/sh on solaris 9
# - must run on /bin/sh on AIX 6.x
#
# Copyright:: Copyright (c) 2010-2015 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# helpers.sh
############
# This section has some helper functions to make life easier.
#
# Outputs:
# $tmp_dir: secure-ish temp directory that can be used during installation.
############

# Credits: Adapted heavily from Chef's Omnitruck curl|bash installer

PREFIX=${PREFIX-$HOME}

# helpers.sh
#
# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

# Output the instructions to report bug about this script
report_bug() {
  echo ""
  echo "Please file a Bug Report at https://github.com/cyverse/cyverse-sdk/issues"
  echo "More CyVerse support resources can be found at http://www.cyverse.org/learning-center/get-help"
  echo ""
  echo "Please include as many details about the problem as possible i.e., how to reproduce"
  echo "the problem (if possible), type of the Operating System and its version, etc.,"
  echo "and any other relevant details that might help us with troubleshooting."
  echo ""
}

unable_to_retrieve_package() {
  echo "Unable to retrieve a valid package!"
  report_bug
  if test "x$download_url" != "x"; then
    echo "Download URL: $download_url"
  fi
  if test "x$stderr_results" != "x"; then
    echo "\nDEBUG OUTPUT FOLLOWS:\n$stderr_results"
  fi
  exit 1
}

http_404_error() {
  echo "Cyverse installer package does not exist or was not accessible."
  if test "x$stderr_results" != "x"; then
    echo "\nDEBUG OUTPUT FOLLOWS:\n$stderr_results"
  fi
  exit 1
}

capture_tmp_stderr() {
  # spool up /tmp/stderr from all the commands we called
  if test -f "$tmp_dir/stderr"; then
    output=`cat $tmp_dir/stderr`
    stderr_results="${stderr_results}\nSTDERR from $1:\n\n$output\n"
    rm $tmp_dir/stderr
  fi
}

# do_wget URL FILENAME
do_wget() {
  echo "trying wget..."
  wget --user-agent="User-Agent: cyverse-sdk-install/1.0.0" -O "$2" "$1" 2>$tmp_dir/stderr
  rc=$?
  # check for 404
  grep "ERROR 404" $tmp_dir/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    http_404_error
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "wget"
    return 1
  fi

  return 0
}

# do_curl URL FILENAME
do_curl() {
  echo "trying curl..."
  curl -A "User-Agent: cyverse-sdk-install/1.0.0" --retry 5 -sL -D $tmp_dir/stderr "$1" > "$2"
  rc=$?
  # check for 404
  grep "404 Not Found" $tmp_dir/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    http_404_error
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "curl"
    return 1
  fi

  return 0
}

# do_fetch URL FILENAME
do_fetch() {
  echo "trying fetch..."
  fetch --user-agent="User-Agent: cyverse-sdk-install/1.0.0" -o "$2" "$1" 2>$tmp_dir/stderr
  # check for bad return status
  test $? -ne 0 && return 1
  return 0
}

# do_perl URL FILENAME
do_perl() {
  echo "trying perl..."
  perl -e 'use LWP::Simple; getprint($ARGV[0]);' "$1" > "$2" 2>$tmp_dir/stderr
  rc=$?
  # check for 404
  grep "404 Not Found" $tmp_dir/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    http_404_error
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "perl"
    return 1
  fi

  return 0
}

# do_python URL FILENAME
do_python() {
  echo "trying python..."
  python -c "import sys,urllib2; sys.stdout.write(urllib2.urlopen(urllib2.Request(sys.argv[1], headers={ 'User-Agent': 'cyverse-sdk-install/1.0.0' })).read())" "$1" > "$2" 2>$tmp_dir/stderr
  rc=$?
  # check for 404
  grep "HTTP Error 404" $tmp_dir/stderr 2>&1 >/dev/null
  if test $? -eq 0; then
    echo "ERROR 404"
    http_404_error
  fi

  # check for bad return status or empty output
  if test $rc -ne 0 || test ! -s "$2"; then
    capture_tmp_stderr "python"
    return 1
  fi
  return 0
}

# returns 0 if checksums match
do_checksum() {
  if exists sha256sum; then
    echo "Comparing checksum with sha256sum..."
    checksum=`sha256sum $1 | awk '{ print $1 }'`
    return `test "x$checksum" = "x$2"`
  elif exists shasum; then
    echo "Comparing checksum with shasum..."
    checksum=`shasum -a 256 $1 | awk '{ print $1 }'`
    return `test "x$checksum" = "x$2"`
  else
    echo "WARNING: could not find a valid checksum program, pre-install shasum or sha256sum in your O/S image to get valdation..."
    return 0
  fi
}

# do_download URL FILENAME
do_download() {
  echo "downloading $1"
  echo "  to file $2"

  url=`echo $1`

  # we try all of these until we get success.
  # perl, in particular may be present but LWP::Simple may not be installed

  if exists wget; then
    do_wget $url $2 && return 0
  fi

  if exists curl; then
    do_curl $url $2 && return 0
  fi

  if exists fetch; then
    do_fetch $url $2 && return 0
  fi

  if exists perl; then
    do_perl $url $2 && return 0
  fi

  if exists python; then
    do_python $url $2 && return 0
  fi

  unable_to_retrieve_package
}

# install_file TYPE FILENAME
# TYPE is "rpm", "deb", "solaris", "sh", etc.
install_file() {
  echo "Installing..."
  case "$1" in
  	"tar")
		tar -C $PREFIX -x -f $2
		find $PREFIX/cyverse-cli/bin -not -name "*.sh" -exec chmod 711 {} \;
		;;
	*)
      echo "Unknown filetype: $1"
      report_bug
      exit 1
      ;;
  esac
  if test $? -ne 0; then
    echo "Installation failed"
    report_bug
    exit 1
  fi
}

if test "x$TMPDIR" = "x"; then
  tmp="/tmp"
else
  tmp=$TMPDIR
fi
# secure-ish temp dir creation without having mktemp available (DDoS-able but not expliotable)
tmp_dir="$tmp/install.sh.$$"
(umask 077 && mkdir $tmp_dir) || exit 1

### INSTALLER

channel="master"
archive="cyverse-cli.tgz"
cd $tmp_dir

do_download https://github.com/cyverse/cyverse-sdk/raw/${channel}/${archive} ${archive}
# do_download https://cyverse.github.io/cyverse-sdk/cyverse-cli.tgz cyverse-cli.tgz.md5

# INSTALL
if [ -f ${archive} ];
then
	install_file tar ${archive}
else
  report_bug
  exit 1
fi

# EXTEND BASHRC
echo "Setting up \$PATH..."
echo $PATH | grep --quiet "$PREFIX/cyverse-cli/bin"
if [ $? = 1 ]
then
  echo "Extended PATH with $PREFIX/cyverse-cli/bin"
  echo "export PATH=\$PATH:\$PREFIX/cyverse-cli/bin" >> $HOME/.bashrc
fi

# INSTALL PYTHON DEPS
echo "Installing Python dependencies..."
do_download https://github.com/cyverse/cyverse-sdk/raw/${channel}/requirements.txt requirements.txt

if exists pip
then
    if [[ -z "$VIRTUAL_ENV" ]];
  then
    pip install -q --trusted-host pypi.python.org -r requirements.txt
  else
    pip install -q --trusted-host pypi.python.org --user -r requirements.txt
  fi
  if [ $? = 1 ];
  then
    echo "Error installing Python dependencies!"
    report_bug
    exit 1
  fi
else
  echo "The pip package is not installed. Please make sure the following Python libraries are installed."
  cat requirements.txt
fi

# TEST
echo "Testing..."
if [ -f $PREFIX/cyverse-cli/bin/cyverse-sdk-info ];
then
  INFO=$($PREFIX/cyverse-cli/bin/cyverse-sdk-info)
  echo "$INFO" | grep -i --quiet "cyverse"
  if [ $? = 1 ]
  then
    echo "Attempt to validate installation failed!"
    report_bug
    exit 1
  fi
fi

