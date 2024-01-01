# exifdatefilenamer

Takes an offset and a list of paths to JPEG files with EXIF metadata, and
generates hard links whose names are based on the file's `DateTimeOriginal`
EXIF attribute with the offset applied.

For example :

```
2
foo.jpg
bar.jpg

-9
abc.jpg
zxc.jpg
```

Assuming that the files' `DateTimeOriginal` is, respectively, `2023:10:19
23:01:00`, `2023:12:31 23:35:23`, `2023:01:01 06:05:01` and `2023:05:05
19:34:22`, this will produce the following  :

```
2023_10_20-01_01_00.jpg -> foo.jpg
2024_01_01-01_35_23.jpg -> bar.jpg
2022_12_31-21_05_01.jpg -> abc.jpg
2023_05_05-10_34_22.jpg -> zxc.jpg
```

# Why?

It's useful if you have files from a multitude of sources whose time is not
synchronised, or some of these sources apply different timezone offset rules.

My partner's phone, for example, reverts back to the home network's timezone
when in airplane mode. This creates problems when we go abroad and one of our
phones is in airplane mode while the other isn't. Generating a series of links
like this script does allows showing the images from both sources in the
correct order.
