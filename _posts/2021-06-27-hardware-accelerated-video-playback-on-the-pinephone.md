---
layout: post
title: "Hardware Accelerated Video Decoding on the PinePhone"
author: "Brian Daniels"
published: true
---

I was able to get hardware accelerated video decoding working on the PinePhone. It is not integrated into any of the usual video playback apps, but it is possible to launch the video from the command line using GStreamer. I tested it on Arch Linux with kernel version `5.12.7-1-danctnix` and the Phosh interface.

I don't see any stutters and the audio sounds great and synced. The total CPU usage was 10-11% and the `gst-play-1.0` app was using 33% of one CPU according to `top`. Here's a brief video of the playback:



<!--break-->

The necessary features in GStreamer are not currently present in any releases, so you need to download and compile it from source. The following commands should do that:

```
git clone https://gitlab.freedesktop.org/gstreamer/gst-build.git
cd gst-build
meson builddir
ninja -C builddir
```

This will get it building, which will take a good amount of time (10s of minutes, but pretty sure it was less than an hour).

Next, install it with `meson install -C builddir`.

Download a test video from [this site](https://senkorasic.com/testmedia/). I've been using ["Caminandes 2: Llamigos" in 1080p H264+AAC with the MP4 container](https://s3.amazonaws.com/senkorasic.com/test-media/video/caminandes-llamigos/caminandes_llamigos_1080p.mp4).

And finally, run this command:

```
LD_LIBRARY_PATH=/usr/local/lib GST_GL_API=gles2 gst-play-1.0 --use-playbin3 --videosink="glimagesink" ~/Videos/caminandes_llamigos_1080p.mp4
```

- `LD_LIBRARY_PATH` is necessary to point to your newly compiled and installed version of GStreamer
- `GST_GL_API=gles2` is necessary to render properly. Without it, it crashes with the following GPU errors in the journal:
```
Jun 27 16:40:27 danctnix kernel: [drm:lima_sched_timedout_job] *ERROR* lima job timeout
Jun 27 16:40:27 danctnix kernel: lima 1c40000.gpu: fail to save task state from gstglcontext pid 4283: error task list is full
Jun 27 16:40:27 danctnix kernel: lima 1c40000.gpu: pp task error 0 int_state=0 status=1
Jun 27 16:40:27 danctnix kernel: lima 1c40000.gpu: pp task error 1 int_state=0 status=1
Jun 27 16:40:27 danctnix kernel: lima 1c40000.gpu: mmu command 2 timeout
Jun 27 16:40:28 danctnix kernel: [drm:lima_sched_timedout_job] *ERROR* lima job timeout
Jun 27 16:40:28 danctnix kernel: lima 1c40000.gpu: fail to save task state from phoc pid 3454: error task list is full
Jun 27 16:40:28 danctnix kernel: lima 1c40000.gpu: pp task error 0 int_state=0 status=5
Jun 27 16:40:28 danctnix kernel: lima 1c40000.gpu: pp task error 1 int_state=0 status=0
```
