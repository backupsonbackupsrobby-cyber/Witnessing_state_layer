# =============== XYO.2 STYLE TOKEN ENGINE ===============
tokens = 0
multiplier = 1  # change this to increase output per action

def show_status():
    print(f"\nTokens: {tokens}")
    print(f"Multiplier: {multiplier}\n")

def handshake():
    global tokens
    tokens += 1 * multiplier
    print(f"Handshake -> +{1 * multiplier} tokens")

def entropy():
    global tokens
    tokens += 2 * multiplier
    print(f"Entropy -> +{2 * multiplier} tokens")

def chain_add():
    global tokens
    tokens += 3 * multiplier
    print(f"Chain Add -> +{3 * multiplier} tokens")

def set_multiplier():
    global multiplier
    try:
        value = int(input("New multiplier: "))
        if value < 1:
            print("Multiplier must be >= 1")
        else:
            multiplier = value
            print(f"Multiplier set to {multiplier}")
    except ValueError:
        print("Not a valid number.")

def menu():
    while True:
        print("\n=== XYO.2 TOKEN ENGINE ===")
        print("1) Handshake")
        print("2) Entropy")
        print("3) Chain Add")
        print("4) Show Tokens")
        print("5) Set Multiplier")
        print("0) Exit")
        choice = input("Select: ").strip()

        if choice == "1":
            handshake()
        elif choice == "2":
            entropy()
        elif choice == "3":
            chain_add()
        elif choice == "4":
            show_status()
        elif choice == "5":
            set_multiplier()
        elif choice == "0":
            print("Exiting.")
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    menu()