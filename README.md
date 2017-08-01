# Maff

a script to save webpages in the [Mozilla Archive Format](https://en.wikipedia.org/wiki/Mozilla_Archive_Format) .maff format

#### USAGE:

```sh
maff.sh -s <output file/dir> <url>
maff.sh -m <output dir> <url1> <url2> ...
maff.sh -l <output dir> <list.txt> 
```
#### REQUIREMENTS :
- wget >= 1.17 (included for windows)
- 7z >= 9.20 (included for windows)

#### NOTES :
- running with `-s` returns `0` on succes & `1` on error
- urls that didn't get saved are printed out to stderr
- the output filename with `-l` & `-m` is the title of the page
