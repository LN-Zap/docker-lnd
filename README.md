# docker-lnd

This repo contains the Dockerfile for the `lnzap/lnd` docker image.

The image containes the latest [lnd](https://github.com/lightningnetwork/lnd) daemon and [zapconnect](https://github.com/LN-Zap/zapconnect).

## Example usage

```
docker run --name lnd -p 10009:10009 -v $(pwd)/lnd-data:/root/.lnd -d lnzap/lnd:latest lnd --bitcoin.active --bitcoin.testnet --debuglevel=info --bitcoin.node=neutrino --neutrino.connect=testnet1-btcd.zaphq.io --neutrino.connect=testnet2-btcd.zaphq.io --autopilot.active --rpclisten=0.0.0.0:10009
```

You can find a more detailed description on usage [here](https://ln-zap.github.io/zap-tutorials/iOS-remote-node-setup-docker).

Enjoy.
