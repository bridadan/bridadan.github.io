---
layout: post
title: "Casting local video to Chromecast from OpenWrt"
author: "Brian Daniels"
published: false
---

I actually have some movies on some optical disks. Weird, I know. It can _sometimes_ be cheaper to buy a physical copy of a movie than to buy it on a streaming service. Plus, if said streaming service ever goes belly-up, you still have your movie! I like that.

What I _don't_ like is rooting around in my cabinet trying to find disks. So I rip my disks... to disk (heh). So I have a nice copy of my movies, but now I want to cast them to my Chromecast. And so I set out on my quest to wrangle the Chromecast and its idiosyncrasies.

<!--break-->

## The goal
To cast local video files to my Chromecast.

What I don't want to do:

- Run a server all of the time
- Run a server _some_ of the time
- Avoid any type of transcoding (reencoding while streaming)
- Write a custom Chromecast app (yet?...)

What I need it to do:

- Play video without any hiccups (1080p and 5.1 surround audio)
- Be able to launch a video from my phone
- Control the playback of the video from my phone
    - Including seeking without buffering the whole video

What I would _like_ it do:

- Be able to select subtitles
- Be able to change audio tracks

## Chromecast needs

The Chromecast supports [a few combinations of containers, codecs, and streaming protocols](https://developers.google.com/cast/docs/media). Let's go through them one at a time.

### Video containers

For videos the supported container formats are MP4 and WebM. This already caused a bit of inconvenience because most of my videos are in MKV containers. I personally like MKV because it is incredibly flexible. It seems to support practically every codec out there. Unlike the Chromecast <sup>_shots fired_</sup>.

### Audio codecs

The Chromecast supports quite a few audio codecs, however I'm really only interested in codecs that support surround sound. I run my Chromecast through a soundbar, so using audio passthrough is option for me. The supported passthrough codecs are AC-3 and E-AC-3.

### Subtitles

Normally the supported subtitle formats are dictated by the video container. The WebM container does not support separate subtitle tracks. The MP4 container does support subtitle tracks, however they have to be a _text-based_ format. Many subtitle tracks ripped from discs are an _image-based_ format, which means you need to do convert them (more on that later). Turns out the Chromecast doesn't even support subtitle tracks supplied by the MP4 containers, so basically we're not going to get our subtitles. The Chromecast can display subtitles, but I believe that requires writing a Chromecast app, which I specifically don't want to do.

## Converting the videos

I didn't want to reencode the video track if at all possible. Turns out I encode all my videos in H.264, so I could just copy that to the MP4 File.

I had quite a few audio tracks that were in the DTS format. This is very easily converted to AC-3, which I did.

Like I mentioned before, the Chromecast does not support any subtitle format that can be muxed into MP4 files, so I skipped the subtitles.

The wonderful ffmpeg project is perfect for this task. So I ran this command to convert my videos:

{% highlight bash %}
ffmpeg -i <input video> -vcodec copy -acodec ac3 -sn <output video>.mp4
{% endhighlight %}

Very quickly, the breakdown of these arguments are:

- `-i <input video>` - This should be the path to your input video. For me this was my MKV file.
- `-vcodec copy` - Copy video track, don't re-encode it
- `-acodec ac3` - Re-encode the audio track to the AC-3 format
- `-sn` - Drop the subtitle track :(
- `<output video>.mp4` - Filename for the output video
