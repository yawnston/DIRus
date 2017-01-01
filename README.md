# DIRus

## Current working build of my File Viewer Pascal project, for my first year Undergrad Programming class

#### Features include:

  - browsing directories, mouse and keyboard(almost) support
  - file information(name, date modified, size, file type)
  - navigating with:
    * address bar for typing known locations
    * editing address directly in the addr bar
    * clicking through folders
    * "UP" button, which takes you up one level (NOTE: this does nothing if you are in a drive directly, such as C:\)
  - file previews
    * if an image is detected, it displays a small portion of the image
      SUPPORTED IMAGE FILES: png,bmp,jpg,jpeg
    * attempts to preview other files as text (this results in interesting things when unsupported files are previewed)

#### Known problems:

  - rarely crashes because of "file not found" or "access denied", reason unknown
  - previewing images is very wonky and displays only a small part of the image
  - previewing unsupported files results in nonsensical output in the preview
  - the Enter key doesn't work when navigating directories (reason known, will fix)
  
#### Planned features:

  - more supported file types, Shell integration for running exe files instead of previewing them as text
  - more icons for different file types
  - two browsing windows
  - editing files
  - large preview window to allow preview of the whole image/file


### Made by Daniel Crha
