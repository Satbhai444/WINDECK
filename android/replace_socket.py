import re

with open(r"D:\WINDECK\android\pubspec.yaml", "r", encoding="utf-8") as f:
    text = f.read()

# Replace socket_io_client with web_socket_channel
text = re.sub(r"socket_io_client:.*", "web_socket_channel: ^3.0.1", text)

with open(r"D:\WINDECK\android\pubspec.yaml", "w", encoding="utf-8") as f:
    f.write(text)
