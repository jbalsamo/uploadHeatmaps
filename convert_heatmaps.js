//--------------------------------------------------------------
// Name: convert_heatmaps.js
// Description: Given the parameters this script converts the
//              old heatmap format for loading into a 3.x or >
//              pathdb quip instance. Parameters have been error
//              checked by this point and sill be correct.
// Author(s):  Ryan Birmingham, Joseph Balsamo
//--------------------------------------------------------------


//--------------------------------------------------------------
// Constants and Variables 
//--------------------------------------------------------------

const http = require('http');
const readline = require('readline');
const path = require('path')
const fs = require('fs');

var argv = process.argv;
var url = '';
var element = '';
var clio = {};
var slide_id = "";
var dummy = argv.shift();
var dummy = argv.shift();
var inputFolder = '/mnt/data/heatmaps/input';
var outputFolder = '/mnt/data/heatmaps/output';

//--------------------------------------------------------------
// Main Program
//--------------------------------------------------------------

console.log('Beginning conversion');

// Parse command-line args
while(argv.length > 0) {
  element = argv.shift().trim();
  switch(element) {
    case '-h':
      clio.host = argv.shift().trim();
      break;
    case '-c':
      clio.collection = encodeURI(argv.shift().trim());
      break;
    case '-m':
      clio.manifest = argv.shift().trim();
      break;
    case '-u':
      clio.username = argv.shift().trim();
      break;
    case '-p':
      clio.passw = argv.shift().trim();
      break;
    case '-i':
      clio.input = argv.shift().trim();
      break;
    case '-o':
        clio.output = argv.shift().trim();
        break;
    default:
      console.error('invalid arguments');
      console.log(element);
  }
}

inputFolder = !clio.input ? '/mnt/data/heatmaps/input':'/mnt/data/heatmaps/' + clio.input;
outputFolder = !clio.output ? '/mnt/data/heatmaps/output':'/mnt/data/heatmaps/' + clio.output;

url = clio.host;

// Read and Parse the manifest.
const fileTemps = {};
var manifest = [];
const mfData = []
manifest = fs.readFileSync(inputFolder + '/' + clio.manifest).toString().split('\n');

console.log('Reading manifest file.');

// Exit with error if manifest file is empty
if (manifest.length <= 1) {
  console.error("Error: Empty manifest file");
  process.exit(50);
}
manifest.splice(0,1);
manifest.forEach((line)=>{
  if(line != '') {
    let fileInfo = line.split(',');
    mfData.push({ file: path.resolve(inputFolder + '/' +fileInfo[0]),study_id:fileInfo[1],subject_id:fileInfo[2],image_id:fileInfo[3] });
  }
});

let remainder = 0;

// For each file process the conversion.
mfData.forEach(mfItem => {
  const ext = path.extname(`${inputFolder}/${mfItem.file}`);
  if(ext!=='.json') return;
  fileTemps[mfItem.file] = null;
  convert(mfItem.file,mfItem);
});

// Exit with a normal completion.
// process.exit(0);

//--------------------------------------------------------------
// End of Main Program
//--------------------------------------------------------------

//--------------------------------------------------------------
// Function Declarations
//--------------------------------------------------------------

//--------------------------------------------------------------
// Function: convert
// Description: This reads in the data from all heatmap files of
//              a prediction run and creates a 3.x style import
//              file to be loaded by the calling script.
// Parameters: filename:string, metadata: object
// Returns: Undefined
//--------------------------------------------------------------
function convert(filename,metadata){
  let lineno = 0;
  let data = [];
  let size = {};

  let fields = [];
  let ranges = [0,1];

  // Check to verify the file exists
  try {
    fs.accessSync(filename,fs.F_OK);
  } catch(e) {
    console.error(e.message);
    process.exit(51);
  }

  // read file
  const myInterface = readline.createInterface({
    input: fs.createReadStream(filename)
  });

  remainder++;
  myInterface.on('line', function (line) {
    const record = JSON.parse(line);
    if(record.properties.metric_value == 0)return;
    ++lineno;
    if(lineno==1) {
    	fileTemps[filename] = record;
    };

    data.push([
    	record.bbox[0],
    	record.bbox[1],
    	...record.properties.multiheat_param.metric_array]);
  }).on('close',()=>{
    var study_id = metadata.study_id;
    var image_id = metadata.image_id;
    var subject_id = metadata.subject_id;

    url = encodeURI(url);
  
    var options = {
      host: url,
      port: 80,
      path: '/idlookup/' + clio.collection + '/' + study_id + '/' + subject_id + '/' + image_id + '?_format=json',
      // authentication headers
      headers: {
        // Authorization: 'Basic <calculated key>',
        Authorization: 'Basic ' + Buffer.from(clio.username + ':' + clio.passw).toString('base64')
      }   
    };

    // this is the call to retrieve the slides unique identifier from pathDB
    request = http.get(options, function(res){
      var body = "";
      res.on('data', function(data) {
          body += data;
      });
      res.on('end', function() {
        let result = JSON.parse(body);
        let basename = path.basename(filename);
        // Check if no results are returned.
        if(result == [] || !result) {
          console.error('Error: No data for ' + image_id);
          process.exit(50);
        }
        // Set slide_id for the given parameters above.
        slide_id = result[0].nid[0].value;
        // Make the new heatmap JSON Doc
        const content = generateDoc(data,filename,metadata);
        if(!fs.existsSync(outputFolder)) fs.mkdirSync(outputFolder);
        fs.writeFile(`${outputFolder}/NEW_${basename}`, content, function(err) {
          if (err) throw err;
          remainder--;
          console.log(`${filename} completed`);
          if(remainder == 0) console.log('finished');
          else console.log(`${remainder} Files remaining`);
        });
      });
      res.on('error', function(e) {
          console.error("Error: " + e.message);
      });
    });
    console.log('Conversion Completed.');
  });
}

//--------------------------------------------------------------
// Function: generateDoc
// Description: This takes the data from convert and produces a
//              json document to write out to the import file.
// Parameters: pdata:array of objects,filename:string, metadata: object
// Returns: JSON Document for heatmap
//--------------------------------------------------------------
function generateDoc(pdata,filename,metadata){
  const [x,y,x1,y1] = fileTemps[filename].bbox;
  const width = x1 - x;
  const height = y1 - y;
  const fields = fileTemps[filename].properties.multiheat_param.heatname_array.map(d =>{
    return{
      name:d,
      range:[0,1],
      value:[0.1,1]
    }
  });

  // console.time('start');


  return `{
    "provenance":{  
      "image":{  
        "subject_id":"${metadata.subject_id}",
        "case_id":"${metadata.image_id}",
        "slide": "${slide_id}", 
        "specimen": "", 
        "study": ""
      },
      "analysis":{  
        "study_id":"${metadata.study_id}",
        "computation":"heatmap",
        "size": [${width},${height}],
        "fields":${JSON.stringify(fields)},
        "execution_id":"${fileTemps[filename].provenance.analysis.execution_id}",
        "source":"computer",
        "setting" : {
          "mode" : "gradient",
          "field" : "${fields[0].name}"
        }
      }
    },
    "data":${JSON.stringify(pdata)}
  }`;
}

//--------------------------------------------------------------
// End of Function Declarations
//--------------------------------------------------------------
