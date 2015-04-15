# SendStream

Simple OSX app to send an URL or stream a file to your Kodi/XBMC media centre.
Just paste an URL of a HTTP stream 


```
git clone https://github.com/albertogasparin/SendStream
```


## Building SendStreamHelper

This project was not being possible without the amazing command line tool created by Patrice Ferlet, [Idok](https://github.com/metal3d/idok). Thanks also to Vadim Shpakovski, for its [MASPreferences](https://github.com/shpakovski/MASPreferences) implementation.

```
brew update && brew install go
export GOPATH=[SENDSTREAM_FOLDER]/SendStreamHelper
cd SendStreamHelper/src/github.com/albertogasparin/SendStreamHelper
go install
```

This will create a new executable under `SendStreamHelper/bin`



