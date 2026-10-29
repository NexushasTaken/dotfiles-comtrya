---@meta

---@class LuaError Do not create a LuaError manually, use the Error helper
---                function below
---@field private message string The error message
---@operator call(string):LuaError

---Creates a new Error object
---@param message string
---@return LuaError
function Error(message) end

---@class Action An action is a single sub-command for a plugin.
---              Any plugin can have any number of actions
---@field exec fun(...): LuaError? Function to execute for the action
---@field plan? fun(...): LuaError? Function to execute before exec is called

---@class Plugin Defines the return type for plugins
---@field name string | function():string The plugin name
---@field summary? string | function():string Brief description of the plugin
---@field actions table<string|1, Action> Table of available actions (if there is only
---                                       one action then key is unnecessary)
---@see Action

---Pauses execution for the specified number of milliseconds
---@param seconds number The time to sleep in milliseconds
---@return nil
function sleep(seconds) end

---@type table<string, table<string, string>>
contexts = {}
