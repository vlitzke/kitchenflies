# Tricks and Tips 

| Basic Commands | Description |
| ----------- | ----------- |
| `ls folderName` | lists directory content (what is in your folder) |
| `cd folderName` | change directory |
| `pwd` | print working directory (the folder you are currently in) |
| `cp` | copy a file, if entire directory add `-r` |
| `mv` | move a file or folder |
| `rm` | remove a file or folder, if entire directory add `-r` |
| `mkdir` | create a new folder |
| `rmdir` | remove a folder |
| `touch fileName`  | create empty file |
| `grep`  | search for patterns in files |
| `less fileName`  | view file in terminal |
| `head fileName`  | view beginning of file |
| `tail fileName`  | view end of file |
| `wget`  | download files/programs from the internet |
| control+c  | terminate process |
| `exit`  | exit the shell |


## Compressing
Once you are all done with your data, it is probably best to compress a directory into a tarball:

```tar -czvf folderName.tar.gz *folderName```

This can take daaaays! 

You can also use zip, unzip to compress and extract files from a zip archive. 

## Visual Text Editor
To edit any text files, you can either do it manually through notepad, and then reupload them to the cluster (straightforward, but annoying when you have a lot to edit) or you can download vim to edit your text files (which will mostly be your .sh files). To get out of the vim editor use `:q` and hit enter. 

## Screens 
Useful tool, basically like running another terminal, but can be done in the background. Run this on a screen 
Screen -r (if there are any screens that are running)
Type in screen 
Paste the command 
Control + a +d 
Then it goes back 
Reaccess screen – screen -r 
Type exit to get out of it
