# robi
A Ruby utility to bundle Reddit selfposts as a Kindle-compatible `.mobi` eBook.

Robi currently depends on Amazon's official
[KindleGen](https://www.amazon.com/gp/feature.html?docId=1000765211) compiler
being in your PATH. If you're running Arch Linux, you can simply install the
[AUR package](https://aur.archlinux.org/packages/kindlegen/).

```
Usage: robi SUBREDDIT [-t TYPE] [-c COUNT]
    -t, --type TYPE                  top, new, etc. (default hot)
    -c, --count COUNT                Max number of posts (default 25)
    -h, --help                       Display this screen
```
