# ZX Spectrum Emulator for iOS

ZX Spectum 48k was my first computer. I still remember fondly loading and playing the games from tapes. But what really blew my mind was ability to write my own programs - it allowed me to unleash my creativity in endless ways! And more importantly - it was starting step that lead me to path of becoming software developer, a path I still find as joyfull and imaginative as I did with those first lines of code.

Today, 30+ years after (and counting :), modern computers are infinitely more powerful than those early machines and emulators allow us to relive the experience without the hassle of handling the actual hardware. But I couldn't find a good emulator for iOS. To be honest, there are commercial ones, but to my knowledge they are hampered by inability to load any game from internet. As I was reading through "The Story of the ZX Spectrum in pixels books from [Fusion Retro Books](https://fusionretrobooks.com) (highly recommended by the way) or watching [ZX Spectrum Show](https://www.youtube.com/user/BuckingTheTrend2008) on YouTube, I wanted to try some of the games presented in person. And most often it was in evening or during holidays when I wasn't behind computer, so this ultimately lead me to path of setting up an emulator on iOS.

## A story you might want to skip ;)

Ok, I can understand this section may not be of interest for anyone to read, but it's close to my heart and therefore worth telling. And heck, it's my project and my readme, so I can do whatever I want with it :D And of course, you have full freedom to skip to next section if not interested.

It's story of how that Speccy came to our house and as such a beginning of life long interest in computers, as well as a testament of times long passed. You see, I was born (and still live) in Slovenia, a small independent country since 1991. But in the eightees, we were part of Yugoslavia, a socialistic republic and as such living "behind the iron curtain". On the other hand, the place where I live is at the border of Italy so we had "luxury" of being able to get goods (to some extent) which were otherwise not available elsewhere. My dad's work also had him doing business with various Italian companies and he had many friends in Italy. One of them was the owner of an electronics and house appliance shop in Gradisca'd'Isonzo.

And so it happened, he went to buy a new TV set from that friend's shop (knowing him, he probably got a good deal on it too :) Now what remained was to bring that TV accross border - which wasn't exactly trivial in those days. Customs were really rigid and it could easily happen they decided they won't allow importing certain item leaving you with no choice but to return it to the shop. Of course what they did allow, you had to pay import fees etc - so at least something didn't change to this day :) Anyway, I digress, back to the story - he succesfully brought the TV home and there he was, bringing that big cardboard box out of the car to the staircase in our garage (remember, we're talking about those big cathode tube TVs, flat CRTs were still many years into the future). And then he started taking it out of the box, and lo and behold, to my complete surprise and joy, below it, there was the Spectrum, dutifully smuggled accross the border :D

I don't remember why he bought it, and he doesn't remember either today. As mentioned, it's possible he got one for free from his friend when purcashing TV. We had couple 16k models in our local school, so I had limited experience with computers but I never expressed a wish to have one at home. But boy was I glad he brought it! And, as they say, the rest is history... So all I can say is - thanks dad!

## About emulator

This is demo project for bringing ZX Spectrum emulator to iOS. It's meant as means for me to quickly download and try out a game or program in the comfort of my iPhone or iPad. But it's certainly not what I would consider commercial quality. It was written during the course of winter 2017 and was left unnatended since, so may even not compile on latest Xcode. But it has many features so if nothing else can be a good learning ground for folks interested in iOS developement and/or RxSwift.

Some of its features:

- Loading tape files from internet
- On screen joystick
- 48k / 128k soft keyboard
- Saving and loading state

## Ideas for improvement

Some ideas for improvement:

- Under the hood, it uses [fuse](http://fuse-emulator.sourceforge.net), though it's highly customized in order to compile on iOS. It would be nice if it could be used unaltered so it could be upgraded.

- There are several hundres compiler warnings from fuse, it would be nice to suppress those...

- As renderer, it just uses plain `UIView`. It would be much more optimized to use OpenGL or metal for rendering

- Ability to set emulation speed

- Ability to start/stop tape playback with button

- External keyboard support

- Support for pokes

- Add starring system for files

As mentioned - I am no longer actively working on this project, but will accept pull requests!

## License

The project is licensed under MIT license, see LICENSE.txt for full text!
