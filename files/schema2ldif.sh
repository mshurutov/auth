#!/bin/bash
# convert OpenLDAP schema file to LDIF file
# Copyright 2022 Mikhail Shurutov
# License: GPLv2
# Idea and any code import from https://gist.github.com/jaseg/8577024

BADARGS=65
BADSLAPTEST=66
BADSRCFILE=67
BADCONVERT=68

print_help() {
	error_code=$1
	error_msg=${2:-'Error'}
	echo "Error: $error_code"
	echo "Message: $error_msg"
	echo "Usage: $0 <fully-qualified schema file name> [<fully-qualified dependency schema file name> ...]"
	exit $error_code
}

# Check if count of parameters is greate then 0
if [ $# -eq 0 ]; then
	print_help $BADARGS "There is no files for convert"
fi

# Check if slaptest is available and executable
slaptest=$(which slaptest 2>/dev/null || ls /usr/sbin/slaptest 2>/dev/null || echo "")
if [ ! -x "$slaptest" ]; then
	print_help $BADSLAPTEST "Cannot find slaptest utility"
fi

schemaFile=$(readlink -f "$1")
shift
dependencies=$@
# Check if source file exist and available for current user
if [ ! -r "$schemaFile" ]; then
	print_help $BADSRCFILE "There is not exist source file or source file is not available for current user"
fi

localdir=$(pwd)
targetFile=$(basename "$schemaFile" .schema).ldif
if [ -e "$localdir/$targetFile" ] ; then
	echo "File $localdir/$targetFile exists. Create backup of it"
	mv -f $localdir/$targetFile $localdir/${targetFile}.bak
fi

echo "$0: converting $schemaFile to LDIF $localdir/$targetFile"
echo "$0: Create temp dir and config file"
tmpDir=$(mktemp -d)
cd "$tmpDir"
mkdir ldap
touch tmp.conf
for dependency in $dependencies; do
	echo "include $dependency" >> tmp.conf
done
echo "include $schemaFile" >> tmp.conf

echo "$0: convert, rename and sanitize"
$slaptest -f tmp.conf -F "$tmpDir/ldap" || print_help $BADCONVERT "convert is failed"
cd ldap/cn\=config/cn\=schema
filenametmp=$(echo cn\=*"$targetFile")

sed -r \
	-e  's/^dn: cn=\{0\}(.*)$/dn: cn=\1,cn=schema,cn=config/' \
	-e 's/cn: \{0\}(.*)$/cn: \1/' \
	-e '/^structuralObjectClass: /d' \
	-e '/^entryUUID: /d' \
	-e '/^creatorsName: /d' \
	-e '/^createTimestamp: /d' \
	-e '/^entryCSN: /d' \
	-e '/^modifiersName: /d' \
	-e '/^modifyTimestamp: /d' \
	-e '/^# AUTO-GENERATED FILE - DO NOT EDIT!! Use ldapmodify./d' \
	-e '/^# CRC32 [0-9a-f]+/d' \
	-e 's/^cn: \{[0-9]*\}(.*)$/cn: \1/' \
	-e 's/^dn: cn=\{[0-9]*\}(.*)$/dn: cn=\1,cn=schema,cn=config/' < "$filenametmp" > "$localdir/$targetFile"

rm -rf "$tmpDir"
