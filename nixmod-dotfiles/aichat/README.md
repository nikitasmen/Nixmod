# AIChat config

Uses local Ollama. Ensure Ollama is running and pull a model:

```bash
ollama pull llama3.2
```

**Usage:**
- `ai "list large files in current dir"` — natural language → execute
- `aichat -f ./src/ "summarize this codebase"` — read paths, analyze
- `aichat` — interactive chat REPL
