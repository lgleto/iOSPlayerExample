iOS Audio Player 
================

Summary
-------

This example shows how to implement an audio player for iOS displaying data in MPNowPlayingInfoCenter by implementing a player handler to manage audio in background. It can play local file or an audio stream.

![App example](docs/mobile-app.png "App example")

#### Usage


```kotlin
val newsApi: NewsApi by lazy { retrofit.create(NewsApi:: class.java) }
val serverArticles = newsApi.topHeadlinesGet( country, category, apiKey)
```

And on iOS:

```swift
    var playerHandler : PlayerHandler = PlayerHandler()

    playerHandler.prepareSongAndSession(
        urlString: "",
        imageUrl: "",
        title: "",
        artist: "",
        albumTitle: "",
           duration: 0)
      
    playerHandler.onIsPlayingChanged { isPlaying in
       //handle play pause buttons
    }
        
    ...

    playerHandler.onProgressChanged { progress in
       // handle time display and tickers
    }
```


License & copyright
-------------------

Copyright 2021 Lourenço Gomes

Licensed under [MIT License](LICENSE)
