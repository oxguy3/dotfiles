# scripts
Misc scripts for stuff and things

You might notice that my bashrc and bash\_profile files aren't named conventially with a preceding ".", and that I don't have a script for automatically symlinking stuff. This is because, rather than symlinking these scripts directly to `~`, I just source them from `~/.bashrc` and `~/.bash_profile`. This gives me the freedom to have custom settings for the specific machine I'm using that I don't want to apply to every computer I use (i.e. mainly, this is for weird machine-specific $PATH additions).

Eventually though, I intend to rename this repo to dotfiles, and to make it so that everything _except_ bashrc and bash\_profile _does_ get symlinked, so I can have stuff like ssh configs and whatnot synced. Someday, someday...
