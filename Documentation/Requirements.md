## System Wide
- The app runs smoothly, without crashing or taking too much power. It will handle edge cases, such as a file not being found or network errors. 
- The app doesn't interrupt other apps, such as pausing the current playing app when it is opened.
- The app doesn't take up too much storage, both in the app itself, and in the database data.
- Changes made by users will appear to happen instantly. This includes:
	- Updates to songs, albums, artists, etc.
	- Deleting songs, albums, artists.
		- If a user in on a page of something that gets deleted, that page is closed
- User data cannot be lost due to error. For example, the library data being corrupted by an operation, and not being able to be recovered.
- Due to the large number of features, the software needs to designed with a focus on maintainability and adaptability.
- Users can share data with others:
	- Global Library
	- Sub Library
	- Listening history 
	- Taglist
	- Playlist
	- EQ
	- Annotations
	- Settings
	- Parses
	- Samples
##### Appearance
- Users can choose the accent color. Default will be purple.
- Users can choose customized app icons.
---
## Library
- Users can drag and drop Audio Files of the following codecs into a specified directory, and they will be loaded and organized based on all associated metadata, including embedded metadata, and external metadata such as file structure and file names.
- Users can edit song metadata, and those edits will affect the library as well as edit the files metadata.
- Users can choose whether, and from which sources, online metadata is automatically pulled from.
- Users can add extra, self-defined metadata to the database, such as ratings and tags.
- Users can use one song to represent more then one instances of that song, such as the same song in a single and and album. The metadata of the file will only be able to support one instance of that, however.
- Users can define TagViews: Sub-sets of their global library, based on a Taglist Ruleset.
	- Songs can either be included, excluded, or codified based on the rules
	- Codified means to apply a transformation, or hide entirely, certain aspects of songs. 
	- As subsets of the global library, anything done on a sub-library, such as updates or listening history, will apply to every library that song is included in.
- Icon menus, such as library, albums, and artists, can be viewed as lists, or through a grid of icons. Sizes can be customized. App will remember last chosen size, and default to that in future.
- Users can navigate to any linked objects from any other. For example, from any song to its album/artist.
##### Search
- Users can search local menus for local objects
- Users can to search the library globally. All Metadata should be considered. Search results are be ordered by relevance.
##### Taglists
- Taglists are a way for users to create playlists by metadata definitions instead of by individual songs. By their nature, they will be unordered and designed for shuffling.
	- They can be explicitly ordered. This can either be always maintaining order on a certain index, or a custom order, where new tracks are added to the end of the list, ordered on certain index.
	- Default behavior will be alphabetically ordered, but this can be configured both globally and on a per list basis.
- Taglists are defined by a set of Clauses, which contain one or more Rules:
	- Some rules are as follows:
		- Tags, written as `#tag`
		- Nested tags, written as `#instruments:piano`
		- Any predefined metadata, written as `@rating:5`
		- Descriptive rules, examples including:
			- `@rating:>3`
			- `count(#instruments:) <= 2`
	- Rules will have auto-fill recommendations, based on existing attributes and the users past tags, as they type them.
- The breakdown of the the Clauses is as follows:
	- A Clause satisfied if Song matches *one* of the Rules from the list.
	- Positive Clauses: If satisfied, include song
	- Negative Clauses: If satisfied, exclude song
	- Song included in Taglist if *all* positive clauses are satisfied, and *all* negative clauses are satisfied. So:
		- If one positive clause is satisfied, and one isn't, the song won't be included.
		- If one negative clause is satisfied, and one isn't, the song *won't be excluded.*
- An example, of two positive and one negative clause:
	- + (\#dance, \#pop, \#hip-hop)
	- + (@year(>2010))
	- - (\#japanese, \#korean)
- The example will include any song that:
	- Has a \#dance, \#pop, or \#hip-hop tag
	- *and* was made after 2010
	- *and* does not have a \#japanese or \#korean tag
- One place to take care will be having multiple negative clauses. For example, if the Japanese and Korean tags were on different clauses, it would only exclude songs with both tags, so it would include songs with only one tag. Care will be taken to explain this to the user, along with examples.
- An example with multiple negative clauses:
	- + (\#english, \#french)
	- - (\#french)
	- - (@year(<2000))
- In this example, I only want songs with the English and French Tags, but I specifically want to exclude older French music, while keeping the older English music. So:
	- An English song from 1980 satisfies all the positive clauses to be included, but not all of the negatives (1/2), so it is not excluded. End result: included.
	- A French song from 2020 satisfies all the positive clauses to be included, but not all of the negatives (1/2), so it is not excluded. End result: included.
	- A French song from 1980 satisfies all the positive clauses to be included, *but it also satisfies all the negatives (2/2), so it is excluded. End result: excluded.*
	- A Japanese song from 2020 doesn't satisfy all the positive clauses, so it is not included. End result: excluded.
- Basically, include all songs that are *included* and *not excluded.*
##### Other-lists
- Traditional, ordered, song based playlists will be available as well.
- Lists can be expanded to include the songs in the list's entire albums and/or artist libraries for more varied listening/discovery
##### Parsing
- Users can select tags that create links, such as a song's artist name, and change the links they create based on rules they define.
- This can either be done by song, or the user can view a list of candidates and select the ones they want to be be parsed. For song artists, the candidates will be as follows:
	- Basic
		- `A` feat. `B`
	- Aggressive
		- `A`, `B`
- When a user chooses to parse a specific phrase, they will have the choice of the following rules they want applied automatically in the future:
	- Always parse this specific phrase.
	- Always parse these series of artist, basically or aggressively
	- Always parse this rule with any artist

### Multi-Platform Syncing
- App supports library synced across multiple sources:
	- Full-Access, owned music
		- Local Device
		- Remote Server(s)
	- Streamed Music
		- Apple Music
		- Spotify
		- Tidal
		- Qobuz
		- Etc.
- Music playback is supported on all owned sources, and limited streaming services (Apple). 
- Streaming services will have basic and aggressive song matching, where basic only matches guarantees, and aggressive matches likely. User can override matches.
- Owned sources will have manual only, basic automated, and aggressive automated matching to both other owned sources and streaming services. Users can override matches.
- Users can sync their libraries across different sources.
	- Users can sort which sources are preferred.
		- If streaming download is available, it will be a separate sorting option
- Users can create collaborative playlists/queues from streaming services. 
	- The playback device must have valid playback sources. 
	- The playback device's matching and sorting rules will be used.
	- Any auto match misses will need to be manually resolved. This can be done by non-playback devices, but will need to use playback device playback sources.




---
## Player
- Users can view all technical metadata about the song being played, such as format, sample rate, and bit rate. Users can choose to have certain aspects of the technical metadata always present on the player screen.
- Users can view and edit all non-technical metadata.
- Users can control their media through all of the expected outside of app controls, and the UI should remain consistent with any changes. Examples include:
	- On the lock screen and context screen
	- Through external devices
	- Through the iOS timer
- Users can add a sleep timer, with the option to play until the end of a track
- Users can playback multiple tracks at a time. An example would be adding a rain sounds behind a track. Default behavior of media controls would control all tracks, but it can be set up to only control certain tracks.
- Users can control the playback speed of tracks, ranging from at least 0.25x up to 2x
##### Queue
- Users can view the queue of music, and make changes to that queue.
- Playback will be completly seamless, barring network issues.
- Users can specify 'queue lists' before listening to a queue, to record certain behaviors based on the users listening activity. 
	- For example, any songs not skipped within a set number of seconds can be recorded.
	- This could then be saved to a playlist, or a taglist could be generated based on tags that already exist on the songs.
	- This list can be formulated after the fact based on listening history, depending on if the history is set up to capture that information.
##### History
- Users can view a history of their playback activity, as well as general statistics. 
- Users can choose if, and how much, of this data is saved. 
- Users can choose the threshold for how much of a listen counts as a full listen, based on a time threshold or a percentage threshold.
##### Queue Playback Customization
- For general queues, as well as taglists and playlists, users can specify certain playback behavior, such as:
	- Ambient playback: A random amount of silence, from a predetermined range, will be added between songs. Songs can be faded in and out as well.
- Any of these playback options can be added to a general queue, or be the default behavior of a taglist/playlist.
##### Visuals
- Users can view the album art, and included scans, in full screen, with the ability to zoom in.
- Users can choose between various styles of song progress indicators, including:
	 - Pill shaped
	 - Waveform shaped
	 - Scrolling Waveform
##### Mixer
- Users can use a **Parametric EQ** to customize the sound of the music (likely not available for Apple Music integration).
- Users can choose between simple, 3-band EQ, and increasingly complex EQs, up to 12 bands.
- Users can save EQ settings:
	- Based on media device
	- Based on song
- EQ Settings can be combined, for example, a media device and song preset EQ will be combined to create the final EQ.
##### Song Annotation
- Users can label sections of songs, with labels such as :intro, outro, filler, part #, loop, etc.
	- Looplist: Replay the loops in songs for a specified range of time
- Users can define global and song specific rules for each label, such as always skipping or pausing at certain labels.
- Users can have more then on annotation per song, such as 'condensed' that cuts filler, and 'learning' that pauses and/or slows down at various points to learn to play the song.
- Users can customize playback controls to interact with labels differently.
- Users should be able to visually see which annotation is currently active, and the borders between labels on the progress indicator.
- Users can add extra visual data to these annotations, such as:
	- Lyrics
	- Guitar Chords
	- Piano Notes
##### Sampling
- Users can sample any part of any local track.
- Users can use rudimentary tools to edit these samples, such as 
	- EQ
	- Pitch
	- Playback speed
	- Reverb
- Users can combine multiple samples into one, with multiple tracks playing at the same time.
- Users can add samples as song. 
- Users can add samples (not as songs) to playlists. For example, utilizing annotations and samples, they can create a custom transition between two songs.
---
## Error Handling
- The UI will reflect any states in error. For example, if a media file is not found for a song, the player will still show the data it has, but with disabled media controls and a warning message.
- Other, backend errors will be shown to users with some kind of popup, and a small description of the error, the cause, and what the user can do. 
- If the error can be retried, it will.
---
## I/O
- Inputs:
	- Local
		- Media files
		- Scans/Albums art image files
	- Apple Music Library Data
	- User data
---
## Platforms
- iOS, iPadOS, macOS.
- Potentially other Swift supported platforms.
---
## Potential Changes
- The largest expected change will be cutting down the requirements for an initial free version. All non-free requirements will be added incrementally. A timeline will likely be required. 


---

# Shelf
- Degrading Ratings
- Loop annotation