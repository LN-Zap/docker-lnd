set -e

echo "release tag   => $1"
echo "lncli version => $2"

if [ $1 == $2 ]
then
  exit 0
else
  exit 42
fi