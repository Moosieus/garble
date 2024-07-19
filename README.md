# Garble
Made to run commonvoice data through codec2 via ffmpeg. Requries the following:
* ffmpeg
* libcodec2
* sqlite3
* libmp3lame

## Usage
1. Generate entries in the database to track the progress of converting each file:
`mix prepare "~/Projects/commonvoice_17_0_en_codec2/audio/en"`

2. Run the conversion, specifying the relative path:
`mix garble "~/Projects/commonvoice_17_0_en_codec2"`

Altogether:
```sh
mix prepare "~/Projects/commonvoice_17_0_en_codec2/audio/en"
mix garble "~/Projects/commonvoice_17_0_en_codec2"
```

## Other
Unpacking tar files recursively:
```sh
find . -type f -name '*.tar' -exec sh -c 'tar -xvf "$1" -C "$(dirname "$1")"' _ {} \;
```