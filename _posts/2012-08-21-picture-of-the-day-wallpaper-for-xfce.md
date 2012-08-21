---
layout			: post
title			: Picture of the day wallpaper for XFCE
date			: Tue Aug 21 21:30:00 2012
comments		: true
---

# Picture of the day wallpaper for XFCE

National Geographic will send me a picture the every other day and I will
download it and set it as my wallpaper. I just automated this with a *tiny* bash
script.

The task is simple.

1. Download the [National Geographic photo of the day page](http://photography.nationalgeographic.com/photography/photo-of-the-day/)
2. Scrap the html file with grep for the picture link
3. Download the picture with wget and put it at ~/.wpoftheday
4. Use this [tiny script](http://phantomsdad.blogspot.in/2011/09/set-wallpaper-in-xfce4-from-command.html)
   to set it as the xfce wallpaper
5. Delete the downloaded web page

### Here is the shell script

{% include wp.ext %}

Or download it [here](../code/wp.sh)

Download the script and run `bash wp.sh` and you are done. You could also move
the file to your bin and call it like `wp` or set a cron job to get this done
automatically everyday.

My bash skills suck. Any way to improve this is welcome :)
