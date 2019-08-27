# uploadHeatmaps.sh

## File Preparation

Start the import process by storing the data in an import folder.  The directory should be: _quip folder_/_data_/_heatmaps_/_input folder_/ on the quip host server.  You only need to copy the "heatmap_XXXXXXXXXXXXXXXXXX.json" files for import.  The metadata file is unnecessary because the manifest contains the required data.

Under the input directory "_import folder_", with the heatmap files, you need to also add a manifest file that contains data about the heatmaps you are loading.  The heatmap files and be distributed under multiple directories in the "_import folder_" as long as the path is defined in manifest with a relative path (i.e. "./study1/heatmap01.json").

## Usage

To load the current input files with a manifest named "manifest.csv":

```bash
[ root@b93a23bb7fa1:~ ]$ uploadHeatmaps.sh -c <PathDB Collection> [option]
```

For the full usage info type:

```bash
bash-3.2$ ~/uploadHeatmaps/uploadHeatmaps.sh --help
Usage: $ uploadHeatmaps.sh [options] -c <pathDB_collection>
  Options:
    -c, --collection <pathDB_collection>: PathDB Collection for heatmaps (*this parameter required)
    -i, --input <input_folder>: Folder where heatmaps are loaded from (default: input)
    -o, --output <output_folder>: Folder where converted heatmaps are imported from (default: output)
    -q, --quip-host <host>: ip or hostname of PathDB Server (default: quip-pathdb)
    -h, --data-host <host>: ip or hostname of database (default: ca-mongo)
    -m, --manifest <manifest name> (default: manifest.csv)
    -d, --database <database name> (default: camic)
    -p, --port <database port> (default: 27017)

    --help Display full help usage.
  Notes: requires mongoDB client tools installed on running server
```

Depending on the number of images and their resolution it may take some time to complete.  Do not stop the process until it completes.  If an error occurs then no data will be uploaded.
