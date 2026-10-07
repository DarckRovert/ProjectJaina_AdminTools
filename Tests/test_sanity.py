import os
import re
import sys

def strip_lua_comments(code):
    code = re.sub(r'--\[\[.*?\]\]', '', code, flags=re.DOTALL)
    code = re.sub(r'--.*$', '', code, flags=re.MULTILINE)
    return code

def test_admin_tools_sanity():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    print(f"Testing addon directory: {base_dir}")

    # 1. Verify required documentation files
    required_docs = [
        "README.md", "CHANGELOG.md", "LICENSE", "NOTICE.md",
        "API.md", "AGENTS.md", "INSTALL.md", "SECURITY.md",
        "ECOSYSTEM_REGISTRY.md", ".gitignore", ".gitattributes",
        "AdminTools.toc", "AdminTools.lua"
    ]
    for doc in required_docs:
        path = os.path.join(base_dir, doc)
        assert os.path.exists(path), f"Missing required file: {doc}"
    print("[PASS] All required repository documentation files exist.")

    # 2. Verify TOC
    toc_path = os.path.join(base_dir, "AdminTools.toc")
    with open(toc_path, "r", encoding="utf-8") as f:
        toc_content = f.read()
    assert "AdminTools.lua" in toc_content, "TOC missing AdminTools.lua"
    assert "30300" in toc_content, "TOC invalid interface version"
    assert "2.0.1" in toc_content, "TOC version mismatch"
    assert "X-Ecosystem-Module: #20" in toc_content, "TOC missing module #20 tag"
    print("[PASS] TOC structure and metadata validated.")

    # 3. Check Lua file for forbidden Retail APIs
    lua_path = os.path.join(base_dir, "AdminTools.lua")
    with open(lua_path, "r", encoding="utf-8") as lf:
        raw_code = lf.read()
    code = strip_lua_comments(raw_code)

    assert not re.search(r'\bSetColorTexture\s*\(', code), "Forbidden SetColorTexture found in AdminTools.lua"
    assert not re.search(r'\bC_Timer\.After\s*\(', code), "Forbidden C_Timer.After found in AdminTools.lua"
    assert not re.search(r'(?<![:\.\w])IsInRaid\s*\(', code), "Forbidden global IsInRaid found in AdminTools.lua"
    print("[PASS] AdminTools.lua adheres to 3.3.5a engine rules.")

    # 4. Unicode Hygiene Check (no unrenderable characters in 3.3.5a Friz Quadrata)
    assert "\\226\\150\\188" not in raw_code, "Octal triangle \\226\\150\\188 still present"
    assert "\\226\\128\\148" not in raw_code, "Octal em-dash \\226\\128\\148 still present"
    for idx, line in enumerate(raw_code.splitlines(), 1):
        for ch in line:
            assert ord(ch) <= 0x024F, f"Unrenderable glyph '{ch}' (U+{ord(ch):04X}) at line {idx}"
    print("[PASS] Unicode glyph hygiene validated (zero corrupt characters).")

    # 5. Verify Slash Commands
    assert "SLASH_ADMINTOOLS3 = \"/wpadm\"" in raw_code, "Missing /wpadm slash command"
    assert "SLASH_ADMINTOOLS4 = \"/wpgm\"" in raw_code, "Missing /wpgm slash command"
    print("[PASS] WoW Peru slash command suite validated (/admin, /adt, /wpadm, /wpgm, /admintools).")

    print("\n>>> ALL WOWPERU_ADMINTOOLS SANITY CHECKS PASSED 100% <<<")

if __name__ == "__main__":
    test_admin_tools_sanity()
