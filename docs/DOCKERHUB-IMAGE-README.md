# lnd + lncli + lndconnect

This is a test for the automated dockerhub readme!

Create a lnd-data volume to persist the lnd data, should exit immediately. The lnd-data container will store the lnd data when the node container is recreated (software upgrade, reboot, etc):

docker volume create --name=lnd-data
docker run -v lnd-data:/lnd --name=lnd-node -d \
    -p 9735:9735 \
    -p 10009:10009 \
    lnzap/lnd:latest \
    --bitcoin.active \
    --bitcoin.testnet \
    --debuglevel=info \
    --bitcoin.node=neutrino \
    --neutrino.connect=testnet1-btcd.zaphq.io \
    --neutrino.connect=testnet2-btcd.zaphq.io \
    --autopilot.active \
    --rpclisten=0.0.0.0:10009