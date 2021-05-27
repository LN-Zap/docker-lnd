set -e

echo "the release tag is => $1"
echo "lncli version is   => $2"

if [ $1 == $2 ]
then
  exit 0
else
  exit 42
fi