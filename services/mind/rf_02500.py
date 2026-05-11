from pathlib import Path
import hashlib, time

ROOT  = Path(r"C:/tron-grid/XYO_UNIVERSAL_GRID/WINDOWS_LATTICE")
LAYER = ROOT / "W_06_RF_02500GHZ"
OUT   = LAYER / "RF_02500GHZ_LOCK.txt"

def main():
    ts = int(time.time())
    LAYER.mkdir(parents=True, exist_ok=True)

    base = f"RF_0.2500GHz|{ts}|XYO|WINDOWS_LATTICE"
    h = hashlib.sha512(base.encode()).hexdigest()

    OUT.write_text(
        "--- RF NETWORK LAYER ---\n"
        "BAND: 0.2500GHz (250MHz)\n"
        f"TIMESTAMP: {ts}\n"
        f"BASE: {base}\n"
        f"HASH: {h}\n"
        "STATUS: @RF_02500GHZ_ANCHORED\n"
    )

    print("RF 0.2500GHz layer written:", OUT)

if __name__ == '__main__':
    main()
