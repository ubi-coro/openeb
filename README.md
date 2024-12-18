# OpenEB

OpenEB is the open source project associated with [Metavision SDK](https://docs.prophesee.ai/stable/index.html)

It enables anyone to get a better understanding of event-based vision, directly interact with events and build their own applications or camera plugins. As a camera manufacturer, ensure your customers benefit from the most advanced event-based software suite available by building your own plugin. As a creator, scientist, academic, join and contribute to the fast-growing event-based vision community.

### Modules

OpenEB is composed of the [Open modules of Metavision SDK](https://docs.prophesee.ai/stable/modules.html#chapter-modules-and-packaging-open):

Module | Description
-|-
**HAL** | Hardware Abstraction Layer to operate any event-based vision device.
**Base** | Foundations and common definitions of event-based applications.
**Core** | Generic algorithms for visualization, event stream manipulation.
**Core ML** | Generic functions for Machine Learning, event_to_video and video_to_event pipelines.
**Stream** | High-level abstraction built on the top of HAL to easily interact with event-based cameras.
**UI** | Viewer and display controllers for event-based data.

### Supported cameras

OpenEB also contains the source code of [Prophesee camera plugins](https://docs.prophesee.ai/stable/installation/camera_plugins.html), enabling to stream data from our event-based cameras and to read recordings of event-based data.

Supported camera | Resolution
-|-
EVK2 | HD
EVK3 | VGA/320/HD
EVK4 | HD

## Content 

This document describes how to compile and install the OpenEB codebase.
For further information, refer to our [online documentation](https://docs.prophesee.ai/) where you will find
some [tutorials](https://docs.prophesee.ai/stable/tutorials/index.html) to get you started in C++ or Python,
some [samples](https://docs.prophesee.ai/stable/samples.html) to discover how to use
[our API](https://docs.prophesee.ai/stable/api.html) and a more detailed
[description of our modules and packaging](https://docs.prophesee.ai/stable/modules.html).

#### [Compiling on Linux](docs/compile-linux.md)

#### [Compiling on Windows](docs/compile-windows.md)

#### [Compiling on Mac](docs/compile-mac.md)

#### [Project overview](docs/run.md)