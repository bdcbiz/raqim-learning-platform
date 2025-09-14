import socket

def send_hot_restart():
    try:
        # Create a socket connection
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(('localhost', 62696))

        # Send 'R' command for hot restart (capital R)
        s.send(b'R\n')

        # Receive response
        response = s.recv(1024)
        print("Hot restart triggered")

        s.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    send_hot_restart()