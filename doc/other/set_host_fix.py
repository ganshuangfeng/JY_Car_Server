# coding=utf-8
#-*- coding: UTF-8 -*- 
import os
import sys
import smtplib
import string

import http.client 
import json
test_data = {
	"cmd_name":"ngetcfg",
	"params":["game","test_xxxxaaa_cfg"]
}
 
requrl = "http://192.168.0.103:8002/manage/http_console_cmd"
headerdata = {"Content-type": "application/json"}
 
conn = http.client.HTTPConnection("192.168.0.103",8002)
 
conn.request('POST',requrl,json.dumps(test_data),headerdata) 
 
response = conn.getresponse()
 
res= response.read()

print(res)
