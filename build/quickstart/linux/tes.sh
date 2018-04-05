#!/usr/bin/env bash

bw-accessVersion=123.45

echo "$bw-accessVersion"

name="bw-access"

varname=${name}Version
echo "${!varname}"

devVersions() {
  # All master
  bedeworkVersion = "master"
  bw-accessVersion = "master"
}