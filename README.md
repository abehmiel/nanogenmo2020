# nanogenmo2020

NaNoGenMo2020: Mario's Big Adventure

This is a procedurally-generated novel output from a lua script that watches a user play Super Mario Bros for the NES on the FCEUX emulator. 

When events in the game occur, the script will listen for changes in the RAM table and output text to a file, recording Mario's journey in a narrative style.

To use the script, you must use the FCEUX NES emulator (available on all platforms) and... "find" a copy of a super mario bros 1 rom (only tested with JUST SMB1 and not duck hunt/combo cart). The Japanese and English release are essentially identical.

## Requirements

1) FCEUX

2) Super Mario Bros. ROM which is NOT included in this repository

3) `gen.lua` in this repository

## Directions:

1) Clone the repo 

2) If desired, disable/enable options in the header of `lua/gen.lua`:

  - `start_with_100_lives`: defaults to `true` - as the name implies, start 1-1 with 100 lives

  - `log_messages_to_screen`: deaults to `true` - use the bottom of the emulated screen to display
  events written to file. Will write the story to file (`txt/story.txt`) regardless of the state of this setting

  - `write_every_damn_frame`: defaults to `false` - Will create a message for every frame, even if nothing happens.
  I don't really know why I made this option but maybe it could be useful to speedrunners if they wanted something different
  than split timing?

3) Start up FCEUX.

4) Load the game ROM, use the `File -> Loadlua script` menu option to load `lua/gen.lua` in this repository, and start playing. 
The events will be written to file: `txt/story.txt`.
The script isn't very stable right now if you load it anywhere besides the title screen.

## Sample story

A sample story, played by beating the game without warp zones, is avalable in `txt/sample_story.txt`

## References

RAM and ROM tables are included in the `maps/` dirctory.

I also really got a lot of mileage out of the [complete Super Mario Bros ROM disassembly](https://gist.github.com/1wErt3r/4048722#file-smbdis-asm-L20)

## Future work

Only 1-player is supported right now. Future work can allow for Luigi's story.
