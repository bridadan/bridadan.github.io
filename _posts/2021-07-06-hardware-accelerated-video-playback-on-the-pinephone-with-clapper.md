---
layout: post
title: "Hardware Accelerated Video Decoding on the PinePhone with Clapper"
author: "Brian Daniels"
published: true
---

In my [previous post](/2021/06/27/hardware-accelerated-video-playback-on-the-pinephone.html), I showed a way to get hardware accelerated video playback working on the PinePhone. However, it required using the command line to launch the video and it was not possible to control the playback with the touchscreen.

Thanks to the efforts of [Rafostar](https://github.com/Rafostar), it is now possible to have full hardware accelerated video playback on the PinePhone within a GTK application with an adaptive UI! This capability is present on the `master` branch of [Clapper](https://github.com/Rafostar/clapper).


<iframe width="560" height="315" src="https://www.youtube.com/embed/BvmRV6IIGGo" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<!--break-->

The features needed in the GStreamer library are not currently released, so you need to build and install it from the `master` branch. This is described in my [previous post](/2021/06/27/hardware-accelerated-video-playback-on-the-pinephone.html).

Once it's installed, you need to build the `master` branch of [Clapper](https://github.com/Rafostar/clapper). You can do this with the following commands:

```
git clone https://github.com/Rafostar/clapper.git
cd clapper
meson builddir --prefix=/usr/local
sudo meson install -C builddir
```

Next, we need to add some environment variables to make sure the correct render path is enabled. How you activate the environment variables is your choice, however I've chosen to add them to the `.desktop` file so they will take effect whenever I start the program through the Phosh launcher.

To do this, first copy the installed Desktop file to your home directory:

```
cp /usr/local/share/applications/com.github.rafostar.Clapper.desktop ~/.local/share/applications/
```

Next open `~/.local/share/applications/com.github.rafostar.Clapper.desktop` and change the `Exec=` line to this:

```
Exec=env GSK_RENDERER=ngl LD_LIBRARY_PATH=/usr/local/lib GST_GL_API=gles2 GST_CLAPPER_USE_PLAYBIN3=1 com.github.rafostar.Clapper %U
```

Save and close the file, and you should be good to go! You may want to restart to make sure Phosh has reloaded the `.desktop` file properly, though I'm not sure if that's necessary.

Breaking down the added environment variables:
- `GSK_RENDERER=ngl` - Use the next generation GL renderer with GTK4. This improves the frame rate.
- `LD_LIBRARY_PATH=/usr/local/lib` - Use the compiled version of GStreamer, not the one provided by the package manager.
- `GST_GL_API=gles2`- Force using OpenGL ES 2 within GStreamer.
- `GST_CLAPPER_USE_PLAYBIN3=1`- Use GStreamer's "playbin3" within Clapper. This is required for good performance.

Have fun! And a big thank you to Rafostar for all of the hard work!
