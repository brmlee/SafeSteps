# Model

Last updated: May 19, 2023

## Overview


## Managers

Managers are specialized classes that handle specific functions.

- `FirebaseManager` handles all Firebase-related actions. All uploads, downloads, etc. will be done by calling this class.
- `LocationManager` handles all location-related actions, including checking/asking permissions, starting/ending location recording, and getting the current location of the device.
- `MetaWearManager` handles all interactions with the MetaWear hardware. 


## Loaders

Loaders are classes (that can be passed by reference) used to retrieve data from an asynchronous function.

For example, if we try to retrieve the `HelloWorld` document from Firebase in the `getHelloWorld()` function,
1. `getHelloWorld()` will request the document
2. `getHelloWorld()` will return
3. We retrieve the `HelloWorld` document
This means we can't simply use `return` because it won't return anything! That's why we use a loader class.

Most loaders conform to `ObservableObject`, so you can simply make it a `@StateObject` in your UI class so that the view refreshes once loading is complete. See `records` in `HistoryView` for an example. 

--
# Firebase

This application uses Firebase (Cloud Firestore) to store any necessary data. This part of the document describes the basic structure of the database.

## Access

Please contact one of the contacts listed on the main `README.md` for access to the Firebase. 

## Structure

There are two collections (tables): `records` and `realtime_data`. 

### `records`

Each document in `records` represent a single walking session. It includes
- `user_id` (string): UUID of the device
- `timestamp` (number): Unix (epoch) timestamp when the report was submitted (when user pressed "Submit" on a survey or indicated no hazard)
- `hazards` (dict: string, int): name of each hazard and their intensities
- `gscope_data` (array: string): array of document names in the `realtime_data` collections that correspond to this walking session. Document names are added to this array sequentially.

Note that the document name is `user_id` + `___` + time.

### `realtime_data`

Each document in `realtime_data` represent ~40 seconds of gyroscope and location data. It just contains a massive array of dictionaries, each containing gyroscope and location data, as well as their timestamps. Your web browser may lag a bit trying to load this data.

Its document name is randomly generated using Swift's UUID generation function. There is a very small chance that the UUIDs may collide (just like all UUIDs) but collisions probably won't happen during the lifecycle of this application.

### Why?

Firebase limits each document size to ~1 MiB, which can only hold around 3 minutes of realtime data. To bypass this, we had to split the realtime data into multiple documents of 2,000 data points (~40 seconds) each.

We use `RealtimeWalkingDataLoader` to load these splitted data and combine them back into one single `RealtimeWalkingData` object.
