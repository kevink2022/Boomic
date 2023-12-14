#  TODO

Only three things in todo now
## TODO NOW
- playlists
- stealthmode
    - libraries

Move things up when ready
## Todo later
- persistence
- search
- likes and ratings
- picture piano
    - tap to the beat, switch between pictures


### TODO complete
- long press
- home bar



#  BUGS/PERFORMANCE ISSUES

OnSongEnd sometimes doesn't trigger
Some songs start a few seconds in, AVPlayer logs errors
- seems to be file specific 


Should probably remove all forced optinal unwraps
- They are pretty much excllusivly when current song != nil, but its bad practice


RAM saving ideas
- Make all albums covers attached to an album (if an album is present)
    - Currently each song stores a copy of the album cover in memory if the cover is embedded


Song List is sometimes unresponsive after dismissing current song sheet
- have run into this on apple music despite their custom looking sheet implentation
     - may just be a sheet style


Large Lists chug when scrolling
- Worst with embedded album art
- Still very bad with stored album art
- Doesn't lag without album art
- Potential Sources:
    - ImageSource init
    - Copying of data 
 
    
Gestured album is laggy and backward swipes have a glitch where the angle resets


Outside of app, only pause/play works



#  FEATURES TO IMPLEMENT
Check the app def for more long term stuff


GENERAL
- Playlists
- Search
- Multitrack support
    - EX. At gym, music when lifting, song during rests, one button to switch between
- Podcast support


GUI
- Boomic Slider gets bigger when interacted with
- Decouple time slider movement from binding, only access binding on user interaction 


BACKEND
- Persistence
    - Hashing to quicken reconstruction of maps
    - Investigate CORE DATA for 
        - ML based?
- Better TrackNo parsing
    

