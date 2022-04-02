--
-- Author: lyx
-- Date: 2018/3/10
-- Time: 15:07
-- 说明：‘轻量’ 化的加载配置。即，不会有改变通知，使用者 自行查询 测试
--

local skynet = require "skynet_plus"
local cluster = require "skynet.cluster"
local base = require "base"
local nodefunc = require "nodefunc"
local basefunc = require "basefunc"
local lfs = require"lfs"

require "printfunc"

local CMD=base.CMD
local DATA=base.DATA

local LD = base.LocalData("light_config",{

	config_dir = skynet.getenv("game_config_dir"),

	-- 全局配置数据：name => {time=,file=,config=,}
	global_config_data = {},

	-- 检查中的数据 name => {time=,file=,config=,}
	checking_config = {},

})

local LF = base.LocalFunc("light_config")

function LF.load_config_base(_data,_name,_info)
	local ok,_cfgdata = xpcall(basefunc.path.reload_lua,basefunc.error_handle,_data.file)
	if ok then
		if type(_cfgdata) == "table" then
			_data.time = _info.change
			_data.config = basefunc.path.reload_lua(_data.file)
			_data.err_time = nil
			print("load config succ:",_name)
		else
			_data.err_time = _info.change
			print("load config data type error:",_name,type(_cfgdata))
		end
	else
		_data.err_time = _info.change
		print("load config version error:",_name,_cfgdata)
	end
end


-- 全局配置读取
function LF.config_reader()

	if skynet.getcfg("check_hot_config") then -- 配置为手工检查代码，则不 自动装载
		return
	end

	for _name,_data in pairs(LD.global_config_data) do

		local info = lfs.attributes(_data.file)
		if info and info.change ~= _data.time then
			if not _data.err_time or _data.err_time ~= info.change then -- 出错以来，文件已经改变 才会读取
				LF.load_config_base(_data,_name,info)
			end
		end
	end
end

function LF.init()

	-- 开始全局配置 读取器
	skynet.timer(2,function() LF.config_reader() end)
	
end

function CMD.get_checking_config(_name)

	if not skynet.getcfg("check_hot_config") then
		return nil,"not config 'check_hot_config' in center.lua!"
	end

	local _d = LD.checking_config[_name]
	if not _d then
		return nil,"config is not found!"
	end

	if not _d.config then
		return nil,"checking config data error!"
	end

	return _d.config,_d.time
end

-- 应用更新的配置，返回 新内容
function CMD.apply_checking_config(_name)

	if not skynet.getcfg("check_hot_config") then
		return nil,"not config 'check_hot_config' in center.lua!"
	end

	local _d = LD.checking_config[_name]
	if not _d then
		return nil,"config is not found!"
	end

	if not _d.config then
		return nil,"checking config data error!"
	end

	local _data = LD.global_config_data[_name]

	if _data then
		if (_data.time or 0) >= _d.time then
			print("apply_checking_config time warning:",_data.time,_d.time)
		end
	end

	-- 写入文件
	local ok,err = basefunc.path.update(_d.file,_d.text)
	if not ok then
		return nil,err
	end

	-- 修改数据
	LD.global_config_data[_name] = _d
	LD.checking_config[_name] = nil
	
	return _d.config,_d.time
end

-- 上传配置文件
function CMD.upload_light_config_file(_name,_data)

	if skynet.getcfg("check_hot_config") then

		local _d = LD.checking_config[_name] or {}
		LD.checking_config[_name] = _d
		_d.time = os.time()
		_d.file = LD.config_dir .. _name .. ".lua"

		local chunk,err = load(_data,_d.file)
		if chunk then
			local _ret = chunk()
			if type(_ret) == "table" then
				_d.config = _ret
				_d.text = _data
				return "checking",_d.time
			else
				return nil,"config file load error,type not invalid:" .. tostring(type(_ret))
			end
		else
			return nil,"config file load error:" .. tostring(err)
		end
	else

		local ok,err = basefunc.path.update(LD.config_dir .. _name .. ".lua",_data)
		if not ok then
			return nil,err
		end

		return "succ" -- 更新成功
	end
end

-- 读取全局配置
--	_name 配置项名字
--	_time 调用者当前配置修改时间，如果文件没改变，则返回 nil
-- 返回： 配置数据 + 修改时间
function CMD.get_global_config(_name,_time)
	local _data = LD.global_config_data[_name]
	if _data then

		if _data.time == _time then
			return nil,_time
		else
			return _data.config,_data.time
		end
	else
		_data = {file=LD.config_dir .. _name .. ".lua"}
		local info = lfs.attributes(_data.file)
		if not info then
			return nil
		end
		LF.load_config_base(_data,_name,info)

		LD.global_config_data[_name] = _data

		return _data.config,_data.time
	end
end


return LF
