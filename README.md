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
![Directory Tree](https://jbalsamo.github.io/mycdn/images/dirtree.jpeg)

## Usage

Start by cloning this script to a directory you have access to, such as your home. As a prerequisite, install the mongodb client, if you are connecting to a different server/node.  At the bash prompt type:

```bash
bash-3.2$ git clone https://github.com/SBU-BMI/uploadHeatmaps.git
```

Assuming its is in your home directory, then type the following:

```bash
bash-3.2$ cd ~/uploadHeatmaps
bash-3.2$ chmod u+x uploadHeatmaps.sh
```

Once that is done, you are ready to import heatmap data.  To load a bulk batch of heatmaps, setup your import folder as stated above and type:

```bash
bash-3.2$ cd import_folder
bash-3.2$ ~/uploadHeatmaps/uploadHeatmaps.sh -h localhost -p 27017 -d quip -f "*"
```

To load heatmaps form a single image named filename, type:

```bash
bash-3.2$ cd import_folder
bash-3.2$ ~/uploadHeatmaps/uploadHeatmaps.sh -h localhost -p 27017 -d quip -f filename
```

For the full usage info type:

```bash
bash-3.2$ ~/uploadHeatmaps/uploadHeatmaps.sh --help
Usage: $ ./uploadHeatmaps.sh [options] -h <host> -f <filename>
  Options:
    -f <filename>: filename of the data to be loaded (this parameter required)
    -h <host>: ip or hostname of database (this parameter required)
    -d <database name> (default: quip)
    -p <database port> (default: 27017)

    --help Display full help usage.
  Notes: requires mongoDB client tools installed on running server
  Notes: If '-f' parameter is *, it must be in quotes.
```

Depending on the number of images and their resolution it may take some time to complete.  Do not stop the process until it completes.