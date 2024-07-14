# Garble

Made to run commonvoice data through codec2 via ffmpeg. Requries the following:
* ffmpeg
* libcodec2
* sqlite3

## Commands
* `mix populate_table` must run first, and will generate entries in the database to track the progress of converting each file.
* `mix garble` iterates over the database and converts all the files via ffmpeg.

## Tentative plan
* Delete all non-en references and commit.
* Decompress all of the audio samples.
* Run prepare task over all of them.
  * Update prepare task to prep an output directory tree.
* Run garble, outputting to a new directory.
  * Update to accept a prepared directory.
* Once done, re-archive all the directories.
* Upload to huggingface.
* ???
* Profit.
