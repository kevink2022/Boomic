# Boomic Music
Boomic Music is a music playback app designed to provide an elegant, low-friction way to manage a High Resolution music library on iOS. 

This project was my final project for the iOS App Development class at Penn State. It was a 5-week (6-week if you include fall break) project where the majority of the development was completed. The final submission can be found in the [original repository](), along with all my other projects from the class. There are some updates from after December 2022, but not much. 

## Current Features
Boomic music currently supports the following features:
#### Library Importation
Users can drag and drop their audio files directly into the Boomic Directory in the files app, which can be accessed on the iOS device itself, or when connected to a Mac/iTunes. When the app launches, all audio files will be imported, and their metadata will be read and used to organize them into Albums and Artists, as well as display the album art (embedded or in the same directory). Currently, **FLAC** and **M4A** file formats are supported.
#### Music Playback
When a user selects a song from a list, all of the other songs from that current list will be added to the queue (for example, if on an album page, this will be all the songs in the album). This queue can be shuffled and un-shuffled. For repeat, there are the following options:
- Play until the end of the queue and pause.
- Repeat the queue. 
- Play until the end of the current song and pause. 
- Repeat the current song. 
#### GUI Options
Boomic Music currently has a few options for the current song view GUI. By default, the classic GUI looks like what most users would expect from Spotify or Apple Music. However, in the settings menu, there's the option to activate:
- Album Art Animations: Swipe back and forth on the album art to change songs
- Waveform View: Replace the time slider with a swipe-able waveform, similar to playback apps like Soundcloud and Poweramp (Android only)
- Gesture GUI: Replace the classic GUI with a gesture-based GUI, with vertical time and volume sliders for ease of use.
Note: iOS does not expose its system volume control directly to applications, only through a premade (and outdated) UIVolumeSlider. So currently, the volume adjusts from 0-100% of the current system volume. This will likely be changed a 80-100%, allowing for fine adjustments, if not scrapped entirely. (Apple, can you please allow finer volume incrementation with the volume buttons as a system setting?) 
## What is FLAC? High Resolution Music?
FLAC stands for Free Lossless Audio Codec. It is similar to MP3, in that it is designed to compress the raw files used in music production, such as WAV, so they take up less space on an end user's phone. However, MP3 compression is lossy, which means some of the information contained in the original recording is lost in the compression process. FLAC, as the name implies, is a lossless format, so none of the information contained in the original raw files is lost. Despite the fact that it is very difficult to tell a difference between modern MP3 compression and lossless FLAC, insecure audiophiles like myself can only relax when the potential bottleneck of compression is eliminated in our quest for aural nirvana (especially when we spend so much on the equipment).

There are many types of compression formats, some lossy, some lossless. Some of the most common ones are:

Lossy
- **MP3** - MPEG-1 Audio Layer III or MPEG-2 Audio Layer III
- **AAC** - Apple Audio Codec
Lossless
- **FLAC** - Free Lossless Audio Codec
- **WAV** - Waveform Audio File
- **ALAC** - Apple Lossless Audio Codec
Container (Can be either)
- **M4A** (MP4) - MPEG-4 Part 14

Apple Music does support ALAC files being added to your Apple Music. However, you cannot have locally stored music alongside an Apple Music subscription. If you wish to have downloaded audio files as part of your library, you have to upload lossy versions to iCloud (and likely pay for extra space). There is a workaround, where you disable iCloud Library (and lose all of your Apple Music library/playlists), upload the lossless ALAC files onto your device, then reactivate iCloud Library. In the past, my library information returned when I reactivated iCloud library, but it is still a pain to convert my FLAC library to ALAC, and I worry that the library information could be overwritten while it's disabled.
