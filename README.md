# uploadHeatmaps.sh

## File Preparation

Start the import process by storing the data in an import folder.  The directory should be: _importFolder_/_LymphocyteHeatMaps_/_filename_/

Each directory "_filename_", has under it four files to import into quip.

* heatmap_filename.checksum.json - High resolution heatmap
* meta_filename.checksum.json - High resolution metadata
* heatmap_filename.checksum.low_res.json - low resolution heatmap
* heatmap_filename.checksum.low_res.json - Low resolution metadata

There is also an svs image file for that filename in each directory.  To import the images in bulk, use the instructions [here](https://github.com/SBU-BMI/quip_distro/wiki/how-to-load-image-svs-file-into-quip-application).

Here is the directory tree for several images:
![https://jbalsamo.github.io/mycdn/images/dirtree.jpeg]

## Usage
