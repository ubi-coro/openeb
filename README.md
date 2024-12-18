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

### Read how to compile the repo on:

<div style="width: 300px;">
  <div style="display: inline-block; width: 32%; min-width: 50px; vertical-align: top; text-align: center;">
    <a href="docs/compile-linux.md">
        <p><b>Linux</b></p>
        <img src="https://seeklogo.com/images/T/tux-logo-AA06C623EC-seeklogo.com.png" height="50" />
    </a>
  </div>
  <div style="display: inline-block; width: 32%; min-width: 50px; vertical-align: top; text-align: center;">
    <a href="docs/compile-windows.md">
        <p><b>Windows</b></p>
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Windows_logo_-_2021.svg/768px-Windows_logo_-_2021.svg.png" height="45" />
    </a>
  </div>
  <div style="display: inline-block; width: 32%; min-width: 50px; vertical-align: top; text-align: center;">
    <a href="docs/compile-mac.md">
        <p><b>MacOS</b></p>
        <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Apple_logo_grey.svg/1724px-Apple_logo_grey.svg.png" height="50" />
    </a>
  </div>
</div>

#### See here a [project overview](docs/run.md)

### Conversion Scripts

Description | Path
-|-
event file → `.csv` | `build/bin/metavision_file_to_csv`
`.raw` or `.hdf5` → `.dat` | `build/bin/metavision_file_to_dat`
event file or folder → `.hdf5` | `build/bin/metavision_file_to_hdf5`
`.raw` or `.hdf5` → `.avi` | `build/bin/metavision_file_to_video`

### Viewer

Description | Path
-|-
view and record a camera or file | `build/bin/metavision_viewer`