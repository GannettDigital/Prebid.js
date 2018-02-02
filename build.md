# Gannett Build Instructions

## Install
```bash
git clone https://github.com/prebid/Prebid.js.git
cd Prebid.js
yarn install
```

## Checkout appropriate version
```bash
git checkout tags/$(<version.txt)
```

## Build
```bash
gulp build --modules=modules.json
```

## Publish to CDN
```bash
gsutil cp ./build/dist/prebid.js gs://ads-gci-www-gannett-cdn-com/vendor/pbjsandwich.min.js
```
