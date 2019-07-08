//convert.js
//
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

var inputFolder = './input';
var outputFolder = './output';
inputFolder = !clio.input ? './input':1;
outputFolder = !clio.output ? './output':1;

url = clio.host;

const fileTemps = {};

let remainder = 0;
fs.readdirSync(inputFolder).forEach(fileName => {
  const ext = path.extname(`${inputFolder}/${fileName}`);
  if(ext!=='.json') return;
  fileTemps[fileName] = null;
  convert(fileName)
});

function convert(filename){

  let lineno = 0;
  let data = [];
  let size = {};

  let fields = [];
  let ranges = [0,1];

  // read file
  const myInterface = readline.createInterface({
    input: fs.createReadStream(`${inputFolder}/${filename}`)
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
    var study_id = fileTemps[filename].provenance.analysis.study_id;
    var image_id = fileTemps[filename].provenance.image.case_id.substring(8);
    var subject_id = fileTemps[filename].provenance.image.subject_id;
    url = encodeURI(url);
    
    var options = {
      host: url,
      port: 80,
      path: '/idlookup/' + clio.collection + '/' + study_id + '/' + subject_id + '/' + image_id + '?_format=json',
      // authentication headers
      headers: {
        // Authorization: 'Basic YWRtaW46Ymx1ZWNoZWVzZTIwMTg=',
        Authorization: 'Basic ' + Buffer.from(clio.username + ':' + clio.passw).toString('base64')
      }   
    };
    //this is the call
    request = http.get(options, function(res){
      var body = "";
      res.on('data', function(data) {
          body += data;
      });
      res.on('end', function() {
        let result = JSON.parse(body);
        slide_id = result[0].nid[0].value;
        const content = generateDoc(data,filename);
        if(!fs.existsSync(outputFolder)) fs.mkdirSync(outputFolder);
        fs.writeFile(`${outputFolder}/NEW_${filename}`, content, function(err) {
          if (err) throw err;
          remainder--;
          console.log(`${filename} completed`);
          if(remainder == 0) console.log('finished');
          else console.log(`${remainder} Files remaining`);
        });
      });
      res.on('error', function(e) {
          console.log("Got error: " + e.message);
      });
      console.log('Get Ended');
    });

  });
}

function generateDoc(pdata,filename){
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
        "subject_id":"${fileTemps[filename].provenance.image.subject_id}",
        "case_id":"${fileTemps[filename].provenance.image.case_id.substring(8)}",
        "slide": "${slide_id}", 
        "specimen": "", 
        "study": ""
      },
      "analysis":{  
        "study_id":"TCGA-BRCA",
        "computation":"heatmap",
        "size": [${width},${height}],
        "fields":${JSON.stringify(fields)},
        "execution_id":"${fileTemps[filename].provenance.analysis.execution_id}",
        "source":"computer"
      }
    },
    "data":${JSON.stringify(pdata)}
  }`;
}
