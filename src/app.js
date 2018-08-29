/**
 * Copyright 2018 isobar. All Rights Reserved.
 *
 */

'use strict';

const dotenv = require('dotenv').config();
const express = require('express');
const http = require('http');
const morgan = require('morgan');
const fs = require('fs');
const fse = require('fs-extra');

const HOST = process.env.HOST
const PORT = (process.env.PORT || 8080)
const APP_HOME = process.env.APP_HOME

const { spawn } = require('child_process');

const app = express();
app.use(morgan('combined'));
app.use(express.static('public'));

//
// Usage:
// initUserData('12345','1');
// setTimeout(function() {
//   initUserData('12345','2');
// },3000);
//
async function initUserData(sno,num) {
  console.log('>>>>>initUserData');
  const dir = 'public/'+sno+'/';
  const fn = sno+'-'+num+'.mp4';
  const src = '/home/ftp/upload/'+fn;
  const dst = dir+fn;
  const ckf = dir+sno+'-'+(num=='1' ? '2' : '1')+'.mp4'
  console.log(dir, src, dst, ckf);

  try {
    await fse.ensureDir(dir)
    await fse.copy(src,dst)
    const exists = await fse.pathExists(ckf)
    if (exists) {
      console.log('>>>>>success');
      console.log('>>>>>starting spawn generator.sh');
      const generator = spawn('bash', [APP_HOME+'tools/generator.sh', sno, 'pic']);
      generator.stdout.on('data', (data) => {
        console.log('stdout:'+data);
      })
      generator.stderr.on('data', (data) => {
        console.log('stderr:'+data);
      })
      generator.on('close', (code) => {
        console.log('child process exited with code '+code);
      })
    }
    else {
      console.log('>>>>>not yet');
    }
  } catch (err) {
    console.log(err);
  }
}

async function uploadVideo(email,sno) {
  console.log('>>>>>uploadVideo:',email,sno);
  const src = 'public/'+sno+'/output.mp4';
  try {
    const uploader = spawn('sh', [APP_HOME+'tools/uploader.sh', email, sno]);
    uploader.stdout.on('data', (data) => {
      console.log('stdout:'+data);
    })
    uploader.stderr.on('data', (data) => {
      console.log('stderr:'+data);
    })
    uploader.on('close', (code) => {
      console.log('child process exited with code '+code);
    })

  } catch (err) {
    console.log(err);
  }

}

/*
app.get('/in/:input/out/:output', (req, res) => {
  console.log('in:'+req.params.input+', out:'+req.params.output);
  res.send('done');
  ffmpeg.webm('public/in.mp4', function (err, out, code) {
    console.log(err,out,code);
  });
})
*/
app.get('/finish/:userId/:fileid', (req, res) => {
  const userid = req.params.userId;
  const fileid = req.params.fileid;
  res.send('finish:'+userid+"-"+fileid);
  console.log('>>>>>finish:'+userid+"-"+fileid);
  initUserData(userid, fileid);
})

app.get('/form/:email/:sno', (req, res) => {
  res.send('email:'+req.params.email+' '+req.params.sno);
  console.log('>>>email:'+req.params.email+' sno:'+req.params.sno);
  uploadVideo(req.params.email, req.params.sno);
})

app.get('/start/:userId', (req, res) => {
  const sno = req.params.userId;
  const dir = 'public/'+sno+'/';
  const ckf = dir+'output.mp4';
  if (fs.existsSync(ckf)) {
    res.send('success');
    console.log('success:'+ckf);
  }
  else {
    res.send('err');
    console.log('err:'+ckf);
  }
})

http.createServer(app).listen(PORT);
console.log('Starting ISOBAR media server:'+PORT+'\n\n');

