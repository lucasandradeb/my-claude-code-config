#!/usr/bin/env python3
import sys
import json
import subprocess
import os

data = json.load(sys.stdin)
fp = data.get("tool_input", {}).get("file_path", "")

if not fp or not os.path.exists(fp):
    sys.exit(0)

if os.path.splitext(fp)[1] not in {".ts", ".tsx", ".js", ".jsx", ".mjs", ".json", ".css", ".scss"}:
    sys.exit(0)

r = subprocess.run(
    ["git", "-C", os.path.dirname(os.path.abspath(fp)), "rev-parse", "--show-toplevel"],
    capture_output=True, text=True
)
root = r.stdout.strip()
if not root:
    sys.exit(0)

pkg_path = os.path.join(root, "package.json")
if not os.path.exists(pkg_path):
    sys.exit(0)

with open(pkg_path) as f:
    pkg = json.load(f)

all_deps = {**pkg.get("devDependencies", {}), **pkg.get("dependencies", {})}
if "prettier" not in all_deps:
    sys.exit(0)

subprocess.run(["npx", "--no", "prettier", "--write", fp], cwd=root, capture_output=True)
