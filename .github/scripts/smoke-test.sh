set -e

echo "release tag   => $1"
echo "lncli version => $2"

if [ $1 == $2 ]
then
  echo "Success: Release Tag matches app Version!"
  exit 0
else
  echo "Error: Release Tag must match app Version!"
  exit 1
fi