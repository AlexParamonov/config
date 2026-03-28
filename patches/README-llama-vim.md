# llama.vim Patches

## llama-vim-instruct-popup.patch

**Purpose:** Multi-line popup for Vim instruct mode  
**Modified:** `autoload/llama.vim`  
**Requirements:** Vim 8.2+ (popup support)

---

## What This Patch Does

Replaces single-line property text with a **multi-line popup window** for Vim's instruct mode.

### Features

1. **Multi-line streaming preview** - Shows up to 10 lines as content streams
2. **Popup below selection** - Grows downward, doesn't cover code
3. **Color-coded border:**
   - 🟠 Orange: Processing/Generating
   - 🟢 Green: Ready to accept
4. **Stays open during navigation** - Popup persists on cursor move
5. **Auto-cleanup** - Closes on `<Tab>` (accept) or `<Esc>` (cancel)

### Before vs After

**Before:**
```
def foo():  ⏳ Generating (12 tokens): def foo() -> int:...
    pass
```

**After:**
```
╭─────────────────────────────────────╮
│ def foo():                          │  ← Your code
│     pass                            │
└─────────────────────────────────────┘
╭─────────────────────────────────────╮
│ ⏳ Generating (12 tokens):          │  ← Popup
│ Instruction: add type hints         │
├─────────────────────────────────────┤
│ def foo() -> int:                   │
│     return 42                       │
╰─────────────────────────────────────╯
```

---

## Workflow

### Apply Patch

```bash
# 1. Restore from backup (if needed)
cp /home/ap/config/lib/.vim/plugged/llama.vim/autoload/llama.vim.bak \
   /home/ap/config/lib/.vim/plugged/llama.vim/autoload/llama.vim

# 2. Apply patch
patch --forward /home/ap/config/lib/.vim/plugged/llama.vim/autoload/llama.vim \
      < /home/ap/config/patches/llama-vim-instruct-popup.patch

# 3. Verify
vim --cmd 'echo "Vim " . v:version' --cmd 'quit'
```

### Configuration

Add to `~/.vim/.vimrc-llama.vim`:

```vim
highlight llama_hl_inst_virt_proc  guifg=#fabd2f ctermfg=214 gui=bold
highlight llama_hl_inst_virt_gen   guifg=#fe8019 ctermfg=208 gui=bold
highlight llama_hl_inst_virt_ready guifg=#b8bb26 ctermfg=113 gui=bold
```

---

## Controls

| Key | Action |
|-----|--------|
| `<Tab>` | Accept suggestion |
| `<Esc>` | Cancel |
| `hjkl` / arrows | Navigate (popup stays) |

---

## Files Modified

- `autoload/llama.vim` - Popup implementation (lines 1456, 1601-1695, 1793-1804)

---

## Patch Creation Notes

**Backup created:** `autoload/llama.vim.bak` (March 28, 2026)

**To regenerate patch:**
```bash
diff -u /home/ap/config/lib/.vim/plugged/llama.vim/autoload/llama.vim.bak \
        /home/ap/config/lib/.vim/plugged/llama.vim/autoload/llama.vim \
        > /home/ap/config/patches/llama-vim-instruct-popup.patch
```

---

## Related Files

- `/home/ap/config/lib/.vim/.vimrc-llama.vim` - llama.vim configuration
- `/home/ap/code/ai/proxy/config.json` - Proxy agent definitions
- `/home/ap/code/ai/benchmarks/qwen3-coder-30b-a3b-llama-bench-results.md` - Performance data
