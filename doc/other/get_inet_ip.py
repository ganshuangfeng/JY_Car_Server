# coding=utf-8
#-*- coding: UTF-8 -*- 
# 得到出口ip

from urllib2 import urlopen
from json import load
import time
import os
import sys

'''
t0 = time.time()
my_ip = urlopen('http://ip.42.pl/raw').read()
print 'ip.42.pl', my_ip, time.time() - t0

t0 = time.time()
my_ip = load(urlopen('http://jsonip.com'))['ip']
print 'jsonip.com', my_ip, time.time() - t0
 
 
t0 = time.time()
my_ip = load(urlopen('http://httpbin.org/ip'))['origin']
print 'httpbin.org', my_ip, time.time() - t0
 
t0 = time.time()
my_ip = load(urlopen('https://api.ipify.org/?format=json'))['ip']
print 'api.ipify.org', my_ip, time.time() - t0
'''

my_ip = ""
while True:
	tmp = urlopen('http://ip.42.pl/raw').read()
	if tmp != my_ip:
		my_ip =  tmp
		f = open(sys.path[0] + '/get_inet_ip.txt','a')
		f.write(time.strftime("%Y-%m-%d %H:%M:%S | ", time.localtime()) + my_ip + '\n')
		f.close()
		
	time.sleep(300)
