import socket

def send_hot_reload():
    try:
        # Create a socket connection
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(('localhost', 57503))

        # Send 'r' command for hot reload
        s.send(b'r\n')

        # Receive response
        response = s.recv(1024)
        print("Hot reload triggered")

        s.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    send_hot_reload()