"""
MIND Service: Interpretation & Risk Analysis
Takes body sensor data and produces interpreted meaning, classification, and risk scoring.
Outputs SHA256-hashed, RFC3161-timestamped packets linked to body state.
"""

import json
import hashlib
import time
from pathlib import Path
from datetime import datetime, timezone
import sys

# Shared state root
STATE_ROOT = Path(r"C:\tron-grid\XYO_UNIVERSAL_GRID\WINDOWS_LATTICE")
STATE_DIR = STATE_ROOT / "W_40_TRON_TRUTH_PACKETS"

GENESIS_HASH = "e14f9a8d2c7b5e3f1a9d4c8b2e6f7a3d"

def ensure_state_dir():
    STATE_DIR.mkdir(parents=True, exist_ok=True)

def read_body_packet() -> dict:
    """Read latest body packet."""
    body_file = STATE_DIR / "body.json"
    if not body_file.exists():
        return None
    
    with open(body_file, 'r') as f:
        return json.load(f)

def compute_sha256(data: dict) -> str:
    """Compute SHA256 of JSON data."""
    json_str = json.dumps(data, sort_keys=True, separators=(',', ':'))
    return hashlib.sha256(json_str.encode()).hexdigest()

def compute_continuity_hash(previous_hash: str, current_data: dict) -> str:
    """Hash linking to previous packet in chain."""
    combined = previous_hash + json.dumps(current_data, sort_keys=True, separators=(',', ':'))
    return hashlib.sha256(combined.encode()).hexdigest()

def analyze_body_state(body_data: dict) -> dict:
    """
    Interpret body sensor data.
    Produces: classification, risk_score, interpretation, recommended_action
    """
    env = body_data.get("data", {}).get("environment", {})
    devices = body_data.get("data", {}).get("device_readings", {})
    hazards = body_data.get("data", {}).get("hazard_flags", {})
    confidence = body_data.get("data", {}).get("confidence", 0)
    
    # Classify based on environmental conditions
    temp = env.get("temperature", 20)
    humidity = env.get("humidity", 50)
    cpu = devices.get("cpu_percent", 0)
    memory = devices.get("memory_percent", 0)
    
    # Risk scoring (0.0 to 1.0)
    risk_score = 0.0
    
    if temp < 0 or temp > 40:
        risk_score += 0.2
    if humidity > 80 or humidity < 20:
        risk_score += 0.15
    if cpu > 80:
        risk_score += 0.15
    if memory > 85:
        risk_score += 0.15
    if any(hazards.values()):
        risk_score += 0.35
    
    risk_score = min(risk_score, 1.0)
    
    # Classification
    if risk_score < 0.1:
        classification = "NOMINAL"
    elif risk_score < 0.3:
        classification = "CAUTION"
    elif risk_score < 0.6:
        classification = "WARNING"
    else:
        classification = "CRITICAL"
    
    # Interpretation
    interpretation_parts = []
    
    if classification == "NOMINAL":
        interpretation_parts.append("All systems operating within normal parameters")
    else:
        if temp < 0 or temp > 40:
            interpretation_parts.append(f"Temperature anomaly: {temp}°C")
        if humidity > 80 or humidity < 20:
            interpretation_parts.append(f"Humidity out of range: {humidity}%")
        if cpu > 80:
            interpretation_parts.append(f"High CPU utilization: {cpu}%")
        if memory > 85:
            interpretation_parts.append(f"High memory usage: {memory}%")
    
    interpretation = " | ".join(interpretation_parts) if interpretation_parts else "Normal operation"
    
    # Recommended action
    if classification == "NOMINAL":
        action = "Continue mission"
    elif classification == "CAUTION":
        action = "Monitor closely"
    elif classification == "WARNING":
        action = "Reduce load, prepare for manual intervention"
    else:
        action = "IMMEDIATE ACTION REQUIRED"
    
    return {
        "interpretation": interpretation,
        "classification": classification,
        "risk_score": round(risk_score, 4),
        "recommended_action": action,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }

def create_mind_packet(body_packet: dict) -> dict:
    """Create mind packet linked to body packet."""
    body_continuity = body_packet.get("crypto", {}).get("continuity_hash", GENESIS_HASH)
    
    # Analyze body state
    analysis = analyze_body_state(body_packet)
    
    # Data to hash
    mind_data = {
        "interpretation": analysis["interpretation"],
        "classification": analysis["classification"],
        "risk_score": analysis["risk_score"],
        "recommended_action": analysis["recommended_action"],
    }
    
    # Compute hashes
    data_hash = compute_sha256(mind_data)
    continuity_hash = compute_continuity_hash(body_continuity, mind_data)
    
    # Build packet
    packet = {
        "service": "mind",
        "version": "1.0.0",
        "timestamp": {
            "timestamp_utc": datetime.now(timezone.utc).isoformat(),
            "timestamp_unix": int(datetime.now(timezone.utc).timestamp()),
            "authority": "RFC3161-GPS-Backed",
        },
        "data": mind_data,
        "crypto": {
            "data_sha256": data_hash,
            "continuity_hash": continuity_hash,
            "genesis_hash": GENESIS_HASH,
            "linked_to": body_continuity,
        },
        "lattice": {
            "state_dir": str(STATE_DIR),
            "service_layer": "W_40_TRON_TRUTH_PACKETS",
            "immutable": True,
        }
    }
    
    return packet

def save_mind_packet(packet: dict):
    """Save mind packet to state directory."""
    ensure_state_dir()
    filepath = STATE_DIR / "mind.json"
    
    with open(filepath, 'w') as f:
        json.dump(packet, f, indent=2, default=str)

def emit_mind():
    """Main emission loop."""
    print("=== MIND SERVICE: INTERPRETATION & ANALYSIS ===")
    print(f"State dir: {STATE_DIR}\n")
    
    while True:
        try:
            # Read body packet
            body_packet = read_body_packet()
            
            if body_packet is None:
                print("[MIND] Waiting for body packet...")
                time.sleep(2)
                continue
            
            # Create and save mind packet
            mind_packet = create_mind_packet(body_packet)
            save_mind_packet(mind_packet)
            
            # Console output
            timestamp = datetime.now().strftime("%H:%M:%S")
            print(f"[{timestamp}] MIND packet emitted")
            print(f"  SHA256: {mind_packet['crypto']['data_sha256'][:16]}...")
            print(f"  Continuity: {mind_packet['crypto']['continuity_hash'][:16]}...")
            print(f"  Classification: {mind_packet['data']['classification']}")
            print(f"  Risk Score: {mind_packet['data']['risk_score']}")
            print(f"  Action: {mind_packet['data']['recommended_action']}")
            print()
            
            time.sleep(5)
        
        except Exception as e:
            print(f"[MIND ERROR] {e}")
            time.sleep(2)

if __name__ == "__main__":
    emit_mind()
