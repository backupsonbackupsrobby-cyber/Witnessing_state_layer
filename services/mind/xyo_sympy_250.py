import json
from pathlib import Path
import time

ROOT = Path(r"C:/tron-grid/XYO_UNIVERSAL_GRID/WINDOWS_LATTICE")
LAYER = ROOT / "W_02_SYMPY_LAW"
OUT   = LAYER / "XYO_EMOJI_MATH_250_LAW.txt"

def load_json_bom_safe(path: Path):
    raw = path.read_bytes()
    # Strip UTF8 BOM if present
    if raw.startswith(b"\xef\xbb\xbf"):
        raw = raw[3:]
    return json.loads(raw.decode("utf-8"))

def emoji_math(payload):
    dialect_units = payload.get("dialect_units", 462)
    cycle_frame   = payload.get("cycle_frame", 12.5)
    cycle_units   = payload.get("cycle_units", 37)

    closed = (
        dialect_units == 462
        and abs(dialect_units / cycle_frame - 36.96) < 0.1
        and cycle_units == 37
    )

    return closed

def main():
    ts = int(time.time())
    LAYER.mkdir(parents=True, exist_ok=True)

    witness_file = Path(r"C:/tron-grid/services/mind/sympy_input.json")
    payload = load_json_bom_safe(witness_file)

    closed = emoji_math(payload)

    OUT.write_text(
        "--- XYO EMOJI-MATH 250 LAW ---\n"
        f"TIMESTAMP: {ts}\n"
        f"DIALECT_UNITS: {payload.get('dialect_units')}\n"
        f"CYCLE_FRAME: {payload.get('cycle_frame')}\n"
        f"CYCLE_UNITS: {payload.get('cycle_units')}\n"
        f"LOOP_STATE: {'CLOSED' if closed else 'OPEN'}\n"
        "STATUS: @XYO_EMOJI_MATH_250_ANCHORED\n"
    )

    print("XYO EMOJI-MATH 250 LAW written:", OUT)

if __name__ == "__main__":
    main()
