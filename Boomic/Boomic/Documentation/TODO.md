#  TODO

#  FEATURES TO IMPLEMENT

GUI
- Boomic Slider gets bigger when interacted with

BACK
- Hashing to quicken reconstruction of maps
- Investigate core data for 
    - ML based?


#  BUGS/PERFORMANCE ISSUES

Should probably remove all forced optinal unwraps
- They are pretty much excllusivly when current song != nil, but its bad practice

RAM saving ideas
- Make all albums covers attached to an album (if an album is present)
    - Currently each song stores a copy of the album cover in memory if the cover is embedded

Song List is sometimes unresponsive after dismissing current song sheet

Large Lists chug when scrolling
- Worst with embedded album art
- Still very bad with stored album art
- Doesn't lag without album art

Potential Sources:
    - ImageSource init
    - Copying of data 



