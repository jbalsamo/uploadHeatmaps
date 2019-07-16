# uploadHeatmaps.sh

## File Preparation

Start the import process by storing the data in an import folder.  The directory should be: _quip folder_/_data_/_xfer_/_input folder_/ on the quip host server.  You only need to copy the "heatmap_XXXXXXXXXXXXXXXXXX.json" files for import.

Under the input directory "_import folder_", with the heatmap files, you need to also add a manifest file that contains data about the heatmaps you are loading.

## Usage

To load the current input files with a manifest named "manifest.csv":

```bash
[ root@b93a23bb7fa1:~ ]$ uploadHeatmaps.sh -c <PathDB Collection> -u <user_name> -p <password>
```

For the full usage info type:

```bash
bash-3.2$ ~/uploadHeatmaps/uploadHeatmaps.sh --help
Usage: $ ./uploadHeatmaps.sh [options] -c <pathDB_collection> -u <username> -p <password>
  Options:
    -c <pathDB_collection>: PathDB Collection for heatmaps being loaded (this parameter required)
    -u <username>: PathDB username (this parameter required)
    -p <password>: PathDB password (this parameter required)
    -i <input_folder>: Folder where heatmaps are loaded from (default: /mnt/data/xfer/input)
    -o <output_folder>: Folder where converted heatmaps are imported from (default: /mnt/data/xfer/output)
    -q <host>: ip or hostname of PathDB Server (default: quip-pathdb)
    -h <host>: ip or hostname of database (default: ca-mongo)
    -d <database name> (default: camic)
    -P <database port> (default: 27017)

    --help Display full help usage.
  Notes: requires mongoDB client tools installed on running server
```

Depending on the number of images and their resolution it may take some time to complete.  Do not stop the process until it completes.
