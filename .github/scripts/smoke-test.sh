set -e

release_tag=$(echo $1 | awk -F '/' '{print $3}')

echo "release tag   => $release_tag"
echo "lncli version => $2"

if [ $release_tag == $2 ]
then
  exit 0
else
  exit 42
fi