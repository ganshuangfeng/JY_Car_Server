#encoding:utf-8

# 自动资源加载：搜索并提取需要打包的资源数据
# 作者 HEWEI
#
import sys
import re
import os
import shutil
import time
from datetime import timedelta, date, datetime

#原始资源文件夹名
autoResFolder="logs.bak"

#获取脚本文件的当前路径
def cur_File_Dir():
	#获取脚本路径
	path = sys.path[0]
	#判断为脚本文件还是py2exe编译后的文件，如果是脚本文件，则返回的是脚本的目录，如果是py2exe编译后的文件，则返回的是编译后的文件路径
	if os.path.isdir(path):
		return path
	elif os.path.isfile(path):
		return os.path.dirname(path)

global file_count

def zip_log(_floderList,_path):
	#遍历相应的目录
	for _folder in _floderList:
		_folderPath=_path+os.sep+_folder
		#如果文件或者文件夹存在
		if os.path.exists(_folderPath):
			#判断是文件还是文件夹
			if os.path.isdir(_folderPath):
				zip_log(os.listdir(_folderPath),_folderPath)
			#如果是文件
			else:
				#if len(_folder)>30 and _folder[0:30]==key_name and _folder[-3:]==file_type:
				if _folder[-4:]!=".zip":
					file="zip -r "+_folderPath+".zip"+" "+_folderPath
					#print file
					os.system(file)
					os.remove(_folderPath)
					global file_count
					file_count = file_count + 1

workPath=os.getcwd()
bakPath=cur_File_Dir() + os.sep + autoResFolder

#获取上一级目录路径 根路径
#parent_rootPath=rootPath[:rootPath.rfind(os.sep)]
#print("workPath:",workPath)
#print("rootPath:",rootPath)
#os.chdir("rootPath")
#print parent_rootPath
while True:
	time.sleep(600)
	file_count = 0

	os.chdir(bakPath)
	zip_log(os.listdir("."),".")
	os.chdir(workPath)
	print("[" + datetime.now().strftime('%Y-%m-%d %H:%M:%S') + "] " + "zip file count:",file_count)



