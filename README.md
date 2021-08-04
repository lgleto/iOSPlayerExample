iOS Audio Player 
================

Summary
-------

This example shows how to implement an audio player for iOS displaying data in MPNowPlayingInfoCenter by implementing a player handler to manage audio in background. It can play local file or an audio stream.

![App example](assets/mobile-app.png "App example")

#### Usage

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

#### Play local files or streaming

### Local file

```swift
   guard let url = URL(fileURLWithPath:  urlString ) else {
       print("Error: cannot play file")
       return
   }
```

### Stream

```swift
   guard let url = URL(string: urlString ) else {
       print("Error: cannot create stream URL")
       return
   }
```

License & copyright
-------------------

Copyright 2021 Lourenço Gomes

Licensed under [MIT License](LICENSE)
