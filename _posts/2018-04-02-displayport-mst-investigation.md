---
layout: post
title: "DisplayPort MST Investigation"
---

These are my initial findings regarding DisplayPort Multi-Stream Transport (MST) implementations in the wild. Spoiler alert: there aren't many.


## Background

DisplayPort is a video standard specified by [VESA](https://www.vesa.org/displayport-developer/about-displayport/). Unlike HDMI, impelenters of DisplayPort devices do not need to pay an annual fee or per-unit royaltees to use the technology. DisplayPort has had many versions over the years, with the most recent version at the time of writing being **1.4**. MST was not added to the spec until version **1.2**, so we'll only be investigating versions 1.2 and later.

### DisplayPort Versions

The following is a very brief summary of the [Wikipedia entry](https://en.wikipedia.org/wiki/DisplayPort#Versions) on DisplayPort Versions. We'll cover just the bits that are considered in this article.

#### Version 1.2

MST was first introuced in this version. Below lists some of the valid monitor configurations:

| Display Resolution @ 60Hz | Max Number of Monitors |
|:-------------:|:-------------:|
| 1920 x 1080 *or* 1920 x 1200 | 4 |
| 2560 x 1600 | 2 |
| 3840 x 2160 (4K UHD) | 1 |
| 4096 x 2160  (4K x 2K) | 1 |

#### Version 1.3

The overall bandwidth was increased in this version. This allows you to run a 4K UHD (3840 x 2160) at 120Hz or two 4K UHD monitors at 60Hz using MST.

#### Version 1.4

Display String Compression was added in this version. Bandwidth is the same, you can just fit more in it. It also brought HDR support.



## Hardware Support

There are a number of factors to consider on the hardware side to determine if using MST is possible. There is surprising little information about the specifics of the implementation, so we will attempt to clarify this here.

### Source Devices

A DisplayPort "source device" provides a video stream to be used by a "sink device" (usually a display of some kind). Typical source devices include desktops, laptops, or smartphones. What we would typically consider the "computer".

#### Desktops and Laptops

Most desktops and laptops (specifically x86 machines) use GPUs from the following vendors: Nvidia, AMD, and Intel. Since the use of MST is most prevalent with workstation setups, all of these vendors have broad support for MST in hardware.

#### Embeded Linux Devices (smartphones, SBCs, etc)

Typically these devices are driven by Arm SoCs. Due to the diversity of the Arm ecosystem, there are many GPU implementations, all of them with varying support for DisplayPort in general, let alone MST. From all of my research, I have yet to find an SoC that advertises support for DisplayPort MST OR find anyone who has written about using it on these devices. Most implementations focus on Embedded DisplayPort (eDP), as Arm SoCs are typically used in devices that have their own screen.

##### Embedded DisplayPort (eDP)

Embedded DisplayPort is a version of DisplayPort that is optimized for internal connections to displays. It is versioned separately from the external DisplayPort standard, but they are closely related. eDP adds support for power saving features, like refresh rate switching (which was then backported to DisplayPort as FreeSync and G-Sync) and partial-frame updates.

Like I mentioned earlier, many SoCs only provide an eDP output. This begs the question: can you use the eDP output to connect to normal DisplayPort displays? I haven't found any proof of someone doing this, but doing the opposite (DisplayPort output to an eDP display) does [appear to be possible](http://emerythacks.blogspot.com/2013/04/connecting-ipad-retina-lcd-to-pc.html).

Assuming you *could* attach an eDP output to a DisplayPort display, everything that I've read indicates that **eDP does not support MST**. While I have not found anything written *explicitly* stating this, it is pretty heavily suggested[^edp_pres].

### Sink Devices

Sink devices accept video streams provided by the source devices we discussed above. These are typically displays, but they can also be things like video capture cards. Displays that support MST (often called daisy-chaining when used in context with monitors) also function as a **branch device**.

### Branch devices

Branch devices accept an MST signal from either a source device or another branch device and transmit atleast one DisplayPort link. To be honest, my terminology is a little wonky here, so I think this is better explained by a picture:

![DisplayPort MST: source, sink, and branch devices](/assets/displayport_mst.png "DisplayPort MST: source, sink, and branch devices")
_DisplayPort topology with a single source device and multiple branch and sink devices_{:.image-caption}

There are two main branch devices that you see in the wild: MST hubs and daisy-chaining monitors.

#### MST Hubs

MST Hubs are branch devices that accept one MST DisplayPort signal and "split" it into multiple DisplayPort signals. These allow you to use a single DisplayPort output on your source device to drive multiple displays.

![Startech Mini DisplayPort to DisplayPort Multi-Monitor Splitter - 3-Port MST Hub](https://sgcdn.startech.com/005329/media/products/gallery_large/MSTMDP123DP.main.jpg "Startech Mini DisplayPort to DisplayPort Multi-Monitor Splitter - 3-Port MST Hub")
_Startech Mini DisplayPort to DisplayPort Multi-Monitor Splitter - 3-Port MST Hub_{:.image-caption}

#### Daisy-chaining Montitors

## Software Support

### Linux Support

### Android Support

Absolutely none as far as I can tell. Not a single mention in anything I've read. Though this makes sense considering the support of DisplayPort MST on GPUs prevelant in Arm SoCs (read: not much/none).

## Final Thoughts

DisplayPort MST seems to have been one of those technologies that works because there are a limited number of unique implementations in the wild. This is not necessarily a bad thing, however due to the closed nature of the DisplayPort spec, coming across technical information can take quite a bit of digging. It also means that if you want to create a device that uses MST, you can only choose from a *very* small pool of parts (in some cases, only one option exists).

[^edp_pres]: Slide 5 of [https://www.vesa.org/wp-content/uploads/2010/12/DisplayPort-DevCon-Presentation-eDP-Dec-2010-v3.pdf](https://www.vesa.org/wp-content/uploads/2010/12/DisplayPort-DevCon-Presentation-eDP-Dec-2010-v3.pdf)
