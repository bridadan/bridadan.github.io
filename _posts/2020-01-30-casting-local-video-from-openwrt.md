---
layout: post
title: "Casting local video to Chromecast from OpenWrt"
author: "Brian Daniels"
published: true
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

The supported video container formats are MP4 and WebM. This already caused a bit of inconvenience because most of my videos are in MKV containers. I personally like MKV because it is incredibly flexible. It seems to support practically every codec out there. Unlike the Chromecast <sup>_shots fired_</sup>.

### Audio codecs

The Chromecast supports quite a few audio codecs, however I'm really only interested in codecs that support surround sound. I run my Chromecast through a soundbar, so using audio passthrough is an option for me. The supported passthrough codecs are AC-3 and E-AC-3.

### Subtitles

Normally the supported subtitle formats are dictated by the video container. The WebM container does not support separate subtitle tracks. The MP4 container does support subtitle tracks, however they have to be a _text-based_ format. Many subtitle tracks ripped from discs are an _image-based_ format, which means you need to convert them with OCR. Turns out the Chromecast doesn't even support subtitle tracks supplied by the MP4 containers, so basically we're not going to get our subtitles. The Chromecast can display subtitles, but that requires writing a Chromecast app, which I specifically don't want to do.

## Converting the videos

I didn't want to reencode the video track if at all possible. Turns out I encode all my videos in H.264, so I could just copy that to the MP4 File.

I had quite a few audio tracks that were in the DTS format. This is very easily converted to AC-3, which I did.

Like I mentioned before, the Chromecast does not support any subtitle format that can be muxed into MP4 files, so I skipped the subtitles.

The wonderful ffmpeg project is perfect for this task. I ran this command to convert my videos:

{% highlight bash %}
ffmpeg -i <input video> -vcodec copy -acodec ac3 -sn <output video>.mp4
{% endhighlight %}

The breakdown of these arguments are:

- `-i <input video>` - This should be the path to your input video. For me this was my MKV file.
- `-vcodec copy` - Copy video track, don't re-encode it
- `-acodec ac3` - Re-encode the audio track to the AC-3 format
- `-sn` - Drop the subtitle track :(
- `<output video>.mp4` - Filename for the output video

## Hosting the videos

The next step is to get the videos on my home network. Normally you'd run something like a server or a Raspberry Pi to do this, but I didn't want another machine running all the time and I didn't want to use one of my Pis. Since my router is running OpenWrt, I used that to host them since the router is always on.

### Streaming

As mentioned above, the Chromecast only supports a few streaming protocols. The three common ones you see are MPEG-DASH, SmoothStreaming, and HTTP Live Streaming. These are popular among most streaming services because they support DRM. They also support adaptive switching of quality, which is totally unneeded in my case. The only other streaming protocol it supports is "progressive download without adaptive switching". That sounds great! But what is "progressive download"?

Turns out its a [server-side capability](https://en.wikipedia.org/wiki/Progressive_download). It allows the consumer of a download to start playing back the media before the download completes. It also allows you to seek throughout the media without downloading the entire file. It turns out the default webserver on OpenWrt (called [uHTTPd](https://openwrt.org/docs/guide-user/services/webserver/http.uhttpd)) does not support this, but [lighttpd](https://openwrt.org/docs/guide-user/services/webserver/lighttpd) does (at least as of version 1.4.48-3).

This has the downside of running two different web servers on my router (one for the router's web interface, the other for my videos), but it was quick to configure and I haven't noticed any issues so far. You need to bind the second web server to a separate port number since the default server uses port 80. It also has a built-in directory listing option so you can browse your files from your phone's browser without running a separate application. This allows you to select the video on your phone and use Chrome's cast action to play the movie on your Chromecast.

## Conclusion

This solution works! The cost is a bit of processing of your video files before they're ready to be streamed, but otheriwse I haven't had any issues. The downside of the required format is you lose capabilities like audio track switching and subtitles. In the future I will most likely use some kind of server to get those features, but for now this is working.
