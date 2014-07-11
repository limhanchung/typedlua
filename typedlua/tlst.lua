--[[
This module implements Typed Lua symbol table.
]]

local tlst = {}

-- new_env : (string, string) -> (env)
function tlst.new_env (subject, filename)
  local env = {}
  env.subject = subject
  env.filename = filename
  env.maxscope = 0
  env.scope = 0
  env.fscope = 0
  env.loop = 0
  env["function"] = {}
  return env
end

-- new_scope : () -> (senv)
local function new_scope ()
  local senv = {}
  senv["goto"] = {}
  senv.label = {}
  return senv
end

-- begin_scope : (env) -> ()
function tlst.begin_scope (env)
  env.scope = env.scope + 1
  env.maxscope = env.scope
  env[env.scope] = new_scope()
end

-- end_scope : (env) -> ()
function tlst.end_scope (env)
  env.scope = env.scope - 1
end

-- set_pending_goto : (env, stm) -> ()
function tlst.set_pending_goto (env, stm)
  table.insert(env[env.scope]["goto"], stm)
end

-- get_pending_gotos : (env, number) -> ({number:stm})
function tlst.get_pending_gotos (env, scope)
  return env[scope]["goto"]
end

-- get_maxscope : (env) -> (number)
function tlst.get_maxscope (env)
  return env.maxscope
end

-- set_label : (env, string) -> (boolean)
function tlst.set_label (env, name)
  local scope = env.scope
  local label = env[scope]["label"][name]
  if not label then
    env[scope]["label"][name] = true
    return true
  else
    return false
  end
end

-- exist_label : (env, number, string) -> (boolean)
function tlst.exist_label (env, scope, name)
  for s = scope, 1, -1 do
    if env[s]["label"][name] then return true end
  end
  return false
end

-- new_fenv : () -> (fenv)
local function new_fenv ()
  local fenv = {}
  fenv.is_vararg = false
  return fenv
end

-- begin_function : (env) -> ()
function tlst.begin_function (env)
  env.fscope = env.fscope + 1
  env["function"][env.fscope] = new_fenv()
end

-- end_function : (env) -> ()
function tlst.end_function (env)
  env.fscope = env.fscope - 1
end

-- set_vararg : (env) -> ()
function tlst.set_vararg (env)
  env["function"][env.fscope].is_vararg = true
end

-- is_vararg : (env) -> (boolean)
function tlst.is_vararg (env)
  return env["function"][env.fscope].is_vararg
end

-- begin_loop : (env) -> ()
function tlst.begin_loop (env)
  env.loop = env.loop + 1
end

-- end_loop : (env) -> ()
function tlst.end_loop (env)
  env.loop = env.loop - 1
end

-- insideloop : (env) -> (boolean)
function tlst.insideloop (env)
  return env.loop > 0
end

return tlst