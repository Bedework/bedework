
count() {
  cd "$1"
  ct=`git rev-list --count --since="Jan 1 2021"  --all`
  echo "For this year $1: $ct"
  total=$((total + ct))

  ct=`git rev-list --count  --all`
  echo "Since move to github $1: $ct"
  fulltotal=$((fulltotal + ct))
  cd ..
}

count bedework
count bw-access
count bw-cache-proxy
count bw-caldav
count bw-caldavTest
count bw-calendar-client
count bw-calendar-common
count bw-calendar-engine
count bw-calendar-xsl
count bw-calsockets
count bw-carddav
count bw-cli
count bw-cliutil
count bw-dav-tester
count bw-deploy
count bw-dotwell-known
count bw-event-registration
count bw-jsforj
count bw-logs
count bw-notifier
count bw-self-registration
count bw-sometime
count bw-synch
count bw-timezone-server
count bw-util
count bw-util-conf
count bw-util-deploy
count bw-util-hibernate
count bw-util-index
count bw-util-logging
count bw-util-network
count bw-util-security
count bw-util-tz
count bw-util2
count bw-webdav
count bw-wfmodules
count bw-xml

echo $total
echo $fulltotal
