# Plugin System

Plugins are in-process Python files providing tools, slash commands, widgets, and lifecycle hooks.

## Discovery

| Priority | Dir | Overrides |
|----------|-----|-----------|
| 1 (higher) | `~/.lele/plugins/` | Global plugins |
| 2 (lower) | `./.lele/plugins/` | Project plugins, same name shadows global |

## Activation

In `~/.lele/config.yaml` or `./.lele/config.yaml`:

```yaml
plugins:
  <name>: active       # tools injected every turn
  <name>: available    # tools deferred, loadable via load-skill
  <name>: disabled     # hidden
```

Default (no plugins section): all discovered plugins are `active`.

## Registration

Each plugin dir has a `plugin.py` exposing:

```python
def register(api):
    api.tool(name, description, parameters, execute)
    api.command("/name", desc, handler)
    api.widget("id")  # returns a widget handle (.set/.clear)
    api.on("event", handler)  # lifecycle hooks
```

Event types: `turn_start`, `turn_end`, `session_start`, `session_end`, `llm_call_start`, `llm_call_end`, `context`, `before_compact`, `after_compact`, + more.

Tool results that match a plugin are dispatched to its `execute`; plugin fallback runs after native tools.
