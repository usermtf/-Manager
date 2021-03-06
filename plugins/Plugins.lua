do

-- Returns the key (index) in the config.enabled_plugins table
local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  -- If not found
  return false
end

-- Returns true if file exists in plugins folder
local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end

  local function list_plugins(only_enabled)
    local text = ''
    local psum = 0
    for k, v in pairs(plugins_names()) do
      --  ✅ enabled, ❌ disabled
      local status = '<b>|•|❌|•|</b>'
      psum = psum+1
      pact = 0
      -- Check if is enabled
      for k2, v2 in pairs(_config.enabled_plugins) do
        if v == v2..'.lua' then
          status = '<b>|•|✅|•|</b>'
        end
        pact = pact+1
      end
      if not only_enabled or status == '<b>|•|✅|•|</b>' then
        -- get the name
        v = v:match('(.*)%.lua')
        text = text..status..'  <code>'..v..'</code>\n'
      end
    end
    local text = text..'\n<code>'..psum..'</code> <b>Installed</b>\n<code>'..pact..'</code> <b>Enabled</b>\n<code>-'..psum-pact..'</code> <b>Disabled</b>'
  return text
  end

local function reload_plugins()
    plugins = {}
    load_plugins()
    return ""
end


local function enable_plugin( plugin_name )
  print('checking if '..plugin_name..' exists')
  -- Check if plugin is enabled
  if plugin_enabled(plugin_name) then
    return 'Plugin <b>'..plugin_name..'</b> Already have Enable'
  end
  -- Checks if plugin exists
  if plugin_exists(plugin_name) then
    -- Add to the config table
    table.insert(_config.enabled_plugins, plugin_name)
    print(plugin_name..' added to _config table')
    save_config()
    -- Reload the plugins
    return 'Plugin <b>'..plugin_name..'</b> Enabled!'
  else
    return 'Plugin <b>'..plugin_name..'</b> not exist!'
  end
end

local function disable_plugin( name, chat )
  -- Check if plugins exists
  if not plugin_exists(name) then
    return 'Plugin <b>'..name..'</b> not exist!'
  end
  local k = plugin_enabled(name)
  -- Check if plugin is enabled
  if not k then
    return 'Plugin <b>'..name..'</b> not Enable!'
  end
  -- Disable and reload
  table.remove(_config.enabled_plugins, k)
  save_config( )
  return 'Plugin <b>'..name..'</b> Disabled!'   
end

local function disable_plugin_on_chat(receiver, plugin)
  if not plugin_exists(plugin) then
    return "This Plugin not exist :|"
  end

  if not _config.disabled_plugin_on_chat then
    _config.disabled_plugin_on_chat = {}
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    _config.disabled_plugin_on_chat[receiver] = {}
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = true

  save_config()
  return 'Plugin <b>'..plugin..'</b> Disabled on this Group'
end

local function reenable_plugin_on_chat(receiver, plugin)
  if not _config.disabled_plugin_on_chat then
    return 'There aren\'t any disabled plugins'
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    return 'There aren\'t any disabled plugins for this supergroup'
  end

  if not _config.disabled_plugin_on_chat[receiver][plugin] then
    return 'Not enable :D'
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = false
  save_config()
  return 'Plugin <b>'..plugin..'</b> Already have Enable'
end

local function run(msg, matches)
  -- Show the available plugins 
  if matches[1] == 'plugins' then
    return list_plugins()
  end

  -- Re-enable a plugin for this chat
  if matches[1] == '+' and matches[3] == 'gp' then
    local receiver = get_receiver(msg)
    local plugin = matches[2]
    print("Enable "..plugin..' on this Group')
    return reenable_plugin_on_chat(receiver, plugin)
  end

  -- Enable a plugin
  if matches[1] == '+' then
    local plugin_name = matches[2]
    print("enable: "..matches[2])
    return enable_plugin(plugin_name)
  end

  -- Disable a plugin on a chat
  if matches[1] == '-' and matches[3] == 'gp' then
    local plugin = matches[2]
    local receiver = get_receiver(msg)
    print("disable "..plugin..' on this chat')
    return disable_plugin_on_chat(receiver, plugin)
  end

  -- Disable a plugin
  if matches[1] == '-' then
    print("disable: "..matches[2])
    return disable_plugin(matches[2])
  end
  
end

  return {
    description = 'Plugin to manage other plugins. Enable, disable or reload.',
    usage = {
      sudo = {
        '<code>!pl + [plugin]</code>',
        'Enable plugin.',
        '',
        '<code>!pl - [plugin]</code>',
        'Disable plugin.',
        '',
        '<code>!reload</code>',
        'Reloads all plugins.'
      },
      moderator = {
        '<code>!plugins</code>',
        'List all plugins.',
        '',
        '<code>!pl + [plugin] chat</code>',
        'Re-enable plugin only this chat.',
        '',
        '<code>!pl - [plugin] chat</code>',
        'Disable plugin only this chat.'
      },
    },
  patterns = {
    "^[!/#](plugins)$",
    "^[!/#]pl (+) ([%w_%.%-]+)$",
    "^[!/#]pl (-) ([%w_%.%-]+)$",
    "^[!/#]pl (+) ([%w_%.%-]+) (gp)",
    "^[!/#]pl (-) ([%w_%.%-]+) (gp)",
	},
  run = run,
  privileged = true
}

end

-- By @MobinDev
