#!/bin/sh

selected() {

}
while
  installcalendar=n
  installsync=n
  installeventsubmit=n
  installselfreg=n

  echo "1) [$installcalendar] calendar"
  echo "2)  [$installsync] sync"
  echo "3)  [$installeventsubmit] eventsubmit"
  echo "4)  [$installselfreg] selfreg"
  printf '$# '; read mnamein
  mname=
do
  case $mnamein in
    1)
      installcalendar=y
      ;;
    2)
      mname=baz
      ;;
    *) continue
      ;;
  esac
done
