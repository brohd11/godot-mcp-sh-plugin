extends SceneTree
## The host offers gdsh_lib's utils, tree and editor commands plus bridge.json's, and none of
## them when gdshLib is off.
##   godot --headless --path . --script res://addons/mcp_sh_godot/_export_ignore/test/host_test.gd
const Host = preload("res://addons/mcp_sh_godot/src/host.gd")
const BridgeConfig = preload("res://addons/_lib/mcp_sh_bridge/src/bridge_config.gd")

const EXPECTED = ["editor", "settings", "resource", "tree", "ls", "cat", "find"]


func _initialize():
	var res = run_tests()
	print("\n".join(res.output))
	quit(0 if res.result == 0 else 1)


static func run_tests() -> Dictionary:
	var out := []
	var failures := 0
	var config = BridgeConfig.new()
	var names = _names(Host.build({}, config))
	for name in EXPECTED:
		if not name in names:
			out.append("FAIL missing %s (has %s)" % [name, names])
			failures += 1
	config.gdsh_lib = false
	names = _names(Host.build({}, config))
	for name in EXPECTED:
		if name in names:
			out.append("FAIL %s offered with gdshLib off" % name)
			failures += 1
	out.append("%d failed" % failures)
	return {"result": failures, "output": out}


static func _names(host) -> Array:
	return host.host_commands().map(func(entry): return entry.name)
