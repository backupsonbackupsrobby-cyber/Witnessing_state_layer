import hashlib, os
from pathlib import Path

ROOT = Path(r"C:/tron-grid/XYO_UNIVERSAL_GRID/WINDOWS_LATTICE")
OUT  = ROOT / "W_07_MCP_MOUTH" / "TRON_CONTINUITY_HASH.txt"

def iter_files(root):
    for d, _, files in os.walk(root):
        for f in sorted(files):
            p = Path(d) / f
            yield p.relative_to(root), p

def main():
    if not ROOT.exists():
        print("MIND: lattice missing")
        return

    h = hashlib.sha512()
    for rel, p in iter_files(ROOT):
        h.update(str(rel).encode())
        h.update(p.read_bytes())

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(
        f"--- TRON CONTINUITY HASH ---\nROOT: {ROOT}\nHASH: {h.hexdigest()}\nSTATUS: @XYO_HASH_VERIFIED\n"
    )

if __name__ == "__main__":
    main()
