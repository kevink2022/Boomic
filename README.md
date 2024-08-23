# Boomic Music
Boomic Music is an iOS music player and library organizer for enthusiasts who find playlists to be insufficient, like myself. It is currently a work in progress, but it is in a functional state that I use it nearly every day. It is not yet robust to bad inputs (such as corrupt files), but its core functionality is well tested, and has revealed very few bugs in my use (This is not due to me being a particularly amazing engineer, but the fact that I test my code). 

## What I've learned
- Taming software complexity
	- As the first large software project that I am responsible for the architecture, I have learned a lot about taming software complexity. 
	- Some of the specific ways this was done:
		- Focusing on strong class cohesion, creating clear conceptual models. 
- Unit Testing
	- This project was also my first experience creating an automated unit testing suite, and was a large inspiration for the unit testing guide I wrote up for my team at my day job.
	- While the error rates haven't been measured, the only major error that has made it into my use of the
- Functional Programming.
	- While by no means a purely functional program, the entire database portion is entirely functional and thoroughly tested. This functional design is described below in the technical discussion.

## Current Features
A full list of requirements can be viewed in the [requirements](Documentation/Requirements.md) doc. The list below is what is currently implemented. Any caveats and prepended with a **!!!** to warn about potential oddities due to the unfinished nature of the app.

#### Importing Songs
- Automatic scanning and importation of any supported audio codec.
	- Current supported codecs: flac, mp3, m4a. Others could likely simply be included, but I don't have the test files currently.
- Embedded metadata is automatically scanned and added to the database. This includes Embedded images.
- 'External metadata' such as album covers, scans, and disc number are also automatically added to the database.

#### Library Data
- Songs are automatically organized by album and artist based on their embedded metadata.
- Users can edit metadata from within the app. 
	- **!!!** Currently, the actual file metadata is not edited.
	- When an album or artist is edited, any other effected song, album, or artist will be updated to reflect the changes as well.
- Users can select multiple songs, albums, artists, etc. and make mass edits to them.
- The app provides a history of every single change ever made in the library. The user can rollback their library to any previous state. 
- Global search combines all searchable items

#### Taglists
- Users can add tags to songs which can be used to create taglists.
- A taglist is a playlist whose songs are determined by a set of rules that determine which songs to include and which to filter out.
	- A positive tag rule requires a song to have at least one match to the rule's tags to be included.
	- A negative tag rule excludes any song that has at least one match to the rule's tags.
	- A song is only included if it is included by *all* positive tag rules and excluded by *all* negative tag rules.
	- More detail and examples can be found in the [requirements](Documentation/Requirements.md) doc.

#### TagViews
- A TagView applies the filter of a Taglist but to the users entire library. With a TagView applied, users can browse subsets of their library defined by certain tags
	- For example, tagging any jazz songs with \#jazz, users can then view all of their jazz albums and artists as if the jazz songs were the only songs in their library.
- **!!!** Currently, TagViews are static, so any changes that would suddenly exclude a song from the current TagView won't show up unless the view is removed and applied.

#### Song Playback
- Song playback works as you would expect.
- Queue is a Apple Music style queue that *doesn't* delete your queued songs like Spotify.

#### UI
- Customize the view of songs, albums, and artists. Customizations persist based on context between launches.
	- List title only
	- List title and subtitle only
	- List title, subtitle, and art, small, medium, and large
	- Grid with 2, 3, 4, or 5 columns with labels.
	- Grid with 2, 3, 4, or 5 columns with no labels.
- Tab and library grid order customizable.
- Accent color is customizable.

## Technical Discussion

#### MVVM vs VM
A very common way of architecting SwfitUI apps is the MVVM, or Model-View-ViewModel, design. The idea is storing most of the state/business logic of a view in a class that utilizes SwiftUI's observation libraries to update on the view.

When a views purpose is to create or modify a certain set of data, I can see the value. But in general, I have found creating classes based off of more general, cohesive rules to work better for this scale of app. Shown below is the current archetecture, with the observable `@Envrionment` objects in purple.

![select_memory_layout](Documentation/boomic_archh.svg)

- `Preferences`
	- This contains all of the general UI settings throughout the app, such as view customizations and accent colors. Any changes are automatically stored.
- `Navigator`
	- This centralizes navigation, allowing any view to link to any other view in the app.
- `Selector`
	- This class facilitates selecting multiple songs, albums, artists, etc. and sends the IDs of the selection to other classes requesting said information.
- `Player`
	- This class coordinates song playback, including managing the queue state and communicating playback information to the iOS control center.
	- `Engine`: The interface for actually playing back songs. Abstracted so multiple engines can be used (ex. a queue with local music and Apple Music songs).
- `Repository`
	- The single data source for the UI, combining data from multiple sources.
	- `TagViewManager`: Stores TagViews.
	- `LibraryTransactor`: The `Transactor` discussed below for storing library state and history.
	- `ImageCache`: Caches images based on their hash.
	- `FileInterface`: Scans user's documents for audio/image files.

#### Embedded Album Art
There are two camps for organizing album art in song libraries: embedded and external. Embedding the album art into each song make is very convenient, but comes at a storage penalty if an album of 50 songs all has the same album cover.

As a developer, the drawbacks when your app loads all 50 of those into memory. You can't assume they're the same for the entire album, because some albums/compilations will have different art for different songs. 

This was countered by saving a hash of the image whenever it was first associated with the songs in the database. Then, loaded images are cached based on this hash to avoid repeat loads.

#### Library State, Persistence, and History
The library state which the app queues against, called the `DataBasis`, is a single immutable reference. Each time any change is made to the library, a new reference is made.  This is based on the ephocal time model as discussed in [Are We There Yet?](https://youtu.be/ScEPu1cs4l0?si=wTyvDeFtAqQHiTh2&t=2795)

The history and rollback ability is achieved through not storing the library state itself, but storing a history of `Transaction` records, which each contain a set of `Assertion` objects. To create a new state of the library, the transaction's assertions are applied to the last version of the data basis. The calculations happen in a background thread, and there is no need to block anything to queue the basis.
 
TRANSACTION FUNCTION: db<sub>n</sub> = f(t<sub>n</sub>, db<sub>n-1</sub>)

However, to generate new transaction data, we need access to that most recent state of the `DataBasis`. These are the generation functions, which contain some data the new transaction will be based on. 

GENERATION FUNCTION: t<sub>n</sub> = g(db<sub>n-1</sub>, p?)

This split is necessary to reify and save the transaction assertions, as they are what are able to be replayed later. For example, to change a song's artist, the album that contains that song needs to be updated to link to the new artist, and the new artist/old artist need to be updated or created/deleted. The generation function creates the transaction, with the set of assertions that describe each change that will be made to the library.

This process is facilitated through a generic transactor, where t<sub>n</sub> and db<sub>n</sub> can be any type, as long as the former conforms to the codable protocol so it can be stored. The single transaction function is defined on init, as this needs to be the same to rebuild to any point in the history. The transactor is also what guarantees that the transaction will be generated on the most recent data basis state. 

``` swift

// init
let transactor = Transactor<Transaction, DataBasis> { transaction in
	return BasisResolver(dataBasis).commit(transaction) // transaction function
}

// the new basis state is published through a combine queue.
transactor.publisher

// if you had the transaction data.
// this will both save the transaction as well as apply it to the bassi.
await transactor.commit(transaction)

// this generates the transaction on the most recent basis. 
// the update song function generates a transaction, then the commit() is called.
await transactor.generate { dataBasis in
	return BasisResolver(dataBasis).updateSong(songUpdate)
}
```

The process of applying each transaction is slow, as the transactor is a completely asynchronous process. That is where the last important of the process occurs, the flatten function, which takes an array of transactions and combines them into a transaction. Optionally, when initializing a transactor, this flatten function can be defined. This will greatly speed up building to a point in history.

FLATTEN FUNCTION: t<sub>all</sub> = h(t<sub>1</sub>, t<sub>2</sub>, ... t<sub>n</sub>)

``` swift
// init with flatten
let transactor = Transactor<Transaction, DataBasis> { transaction in
	return BasisResolver(dataBasis).commit(transaction) // transaction function
} flatten: { transactions in 
	return Transaction.flatten(transactions) // flatten function
}
```

![select_memory_layout](Documentation/boomic_transaction.svg)
