from fastapi import FastAPI
from pathlib import Path
import json
from datetime import datetime, timezone

LATTICE = Path(r"C:/tron-grid/XYO_UNIVERSAL_GRID/WINDOWS_LATTICE")
STATE_DIR = LATTICE / "W_40_TRON_TRUTH_PACKETS"
GENESIS_HASH = "e14f9a8d2c7b5e3f1a9d4c8b2e6f7a3d"

app = FastAPI(title="TRON Lattice Chat Bridge")

def read_json(path: Path) -> dict:
    """Read JSON file safely."""
    if not path.exists():
        return None
    try:
        with open(path, 'r') as f:
            return json.load(f)
    except:
        return None

def read_text(path: Path):
    if not path.exists():
        return None
    return path.read_text()

def mouth_status():
    f = LATTICE / "W_07_MCP_MOUTH" / "TRON_CONTINUITY_HASH.txt"
    raw = read_text(f)
    if raw is None:
        return {"status": "NO_HASH", "raw": ""}
    return {
        "status": "VERIFIED" if "@XYO_HASH_VERIFIED" in raw else "UNVERIFIED",
        "raw": raw,
    }

def rf_status():
    rf250   = LATTICE / "W_05_RF_250GHZ" / "RF_250GHZ_LOCK.txt"
    rf02500 = LATTICE / "W_06_RF_02500GHZ" / "RF_02500GHZ_LOCK.txt"
    nodes_m = LATTICE / "W_07_RF_250_NODE_NETWORK" / "RF_250_NODE_MASTER.txt"

    return {
        "rf_250ghz":   {"exists": rf250.exists(),   "raw": read_text(rf250)   or ""},
        "rf_0_2500ghz": {"exists": rf02500.exists(), "raw": read_text(rf02500) or ""},
        "rf_250_nodes": {"exists": nodes_m.exists(), "raw": read_text(nodes_m) or ""},
    }

def verify_continuity_chain() -> dict:
    """Verify the body → mind → mouth continuity chain."""
    body_packet = read_json(STATE_DIR / "body.json")
    mind_packet = read_json(STATE_DIR / "mind.json")
    mouth_packet = read_json(STATE_DIR / "mouth.json")
    
    chain_valid = (
        body_packet and
        mind_packet and
        mouth_packet and
        mind_packet.get("crypto", {}).get("linked_to") == body_packet.get("crypto", {}).get("continuity_hash") and
        mouth_packet.get("crypto", {}).get("linked_to") == mind_packet.get("crypto", {}).get("continuity_hash")
    )
    
    return {
        "valid": chain_valid,
        "body_exists": body_packet is not None,
        "mind_exists": mind_packet is not None,
        "mouth_exists": mouth_packet is not None,
        "body_to_mind_linked": mind_packet and body_packet and mind_packet.get("crypto", {}).get("linked_to") == body_packet.get("crypto", {}).get("continuity_hash"),
        "mind_to_mouth_linked": mouth_packet and mind_packet and mouth_packet.get("crypto", {}).get("linked_to") == mind_packet.get("crypto", {}).get("continuity_hash"),
    }

@app.get("/state")
def state():
    return {
        "exists": LATTICE.exists(),
        "mouth": mouth_status(),
        "rf": rf_status(),
    }

@app.get("/lattice/state")
def lattice_state():
    """Read-only lattice state endpoint for AI agents."""
    body_packet = read_json(STATE_DIR / "body.json")
    mind_packet = read_json(STATE_DIR / "mind.json")
    mouth_packet = read_json(STATE_DIR / "mouth.json")
    chain_verification = verify_continuity_chain()
    
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "genesis_hash": GENESIS_HASH,
        "body_state": body_packet,
        "mind_state": mind_packet,
        "mouth_state": mouth_packet,
        "continuity_chain": chain_verification,
        "truth_receipt": mouth_packet.get("truth_receipt") if mouth_packet else None,
    }

@app.post("/chat")
def chat(payload: dict):
    return {
        "echo": payload.get("message", ""),
        "state": state(),
    }
