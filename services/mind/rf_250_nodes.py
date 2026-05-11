from pathlib import Path
import hashlib, time

ROOT   = Path(r"C:/tron-grid/XYO_UNIVERSAL_GRID/WINDOWS_LATTICE")
LAYER  = ROOT / "W_07_RF_250_NODE_NETWORK"
MASTER = LAYER / "RF_250_NODE_MASTER.txt"

NODE_COUNT = 250

def make_node(n):
    ts = int(time.time())
    seed = f"NODE_{n}|{ts}|RF250|XYO"
    h = hashlib.sha512(seed.encode()).hexdigest()
    return {"id": n, "timestamp": ts, "seed": seed, "hash": h}

def main():
    LAYER.mkdir(parents=True, exist_ok=True)

    nodes = []
    for i in range(1, NODE_COUNT + 1):
        node = make_node(i)
        nodes.append(node)
        node_file = LAYER / f"NODE_{i:03d}.txt"
        node_file.write_text(
            f"--- RF 250 NODE ---\n"
            f"NODE: {i}\n"
            f"TIMESTAMP: {node['timestamp']}\n"
            f"SEED: {node['seed']}\n"
            f"HASH: {node['hash']}\n"
            f"STATUS: @RF250_NODE_ANCHORED\n"
        )

    master = hashlib.sha512()
    for n in nodes:
        master.update(str(n['id']).encode())
        master.update(str(n['timestamp']).encode())
        master.update(n['hash'].encode())

    MASTER.write_text(
        "--- RF 250 NODE NETWORK MASTER ---\n"
        f"NODES: {NODE_COUNT}\n"
        f"MASTER_HASH: {master.hexdigest()}\n"
        "STATUS: @RF250_NODE_NETWORK_ANCHORED\n"
    )

    print("250-node RF network written:", LAYER)

if __name__ == '__main__':
    main()
