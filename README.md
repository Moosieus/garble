# Garble

Made to run commonvoice data through codec2 via ffmpeg. Requries the following:
* ffmpeg
* libcodec2
* sqlite3

## Commands
* `mix populate_table` must run first, and will generate entries in the database to track the progress of converting each file.
* `mix garble` iterates over the database and converts all the files via ffmpeg.
