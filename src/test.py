import socket
import os
from typing import cast, List
from zeroconf import Zeroconf, ServiceBrowser, ServiceInfo, ServiceStateChange
import time

# Nazwa usługi mDNS
SERVICE_TYPE = "_imageTransfer._tcp.local."

class ImageSender:
    def __init__(self, image_paths: List[str], timeout=15):
        self.image_paths = image_paths
        self.server_address = None
        self.server_port = None
        self.zeroconf = Zeroconf()
        self.timeout = timeout  # limit czasu w sekundach

    def find_service(self):
        """Wyszukaj usługę mDNS i pobierz adres IP oraz port serwera."""
        def on_service_found(zeroconf: Zeroconf, service_type, name, state_change):
            if state_change is ServiceStateChange.Added:
                start_time = time.time()
                while True:
                    info = zeroconf.get_service_info(service_type, name)
                    if info:
                        addresses = ["%s:%d" % (addr, cast(int, info.port)) for addr in info.parsed_scoped_addresses()]
                        self.server_address = addresses[0].split(':')[0]
                        self.server_port = info.port
                        print(f"Znaleziono serwer na adresie {self.server_address}:{self.server_port}")
                        zeroconf.close()  # Wyłącza zeroconf po znalezieniu usługi
                        break
                    elif time.time() - start_time > self.timeout:
                        print("Nie udało się uzyskać pełnych informacji o serwisie w wyznaczonym czasie.")
                        zeroconf.close()
                        break
                    else:
                        time.sleep(0.5)  # Krótkie opóźnienie przed kolejną próbą

        print("Wyszukiwanie serwera...")
        ServiceBrowser(self.zeroconf, SERVICE_TYPE, handlers=[on_service_found])

        # Sprawdzanie przez określony czas (timeout), czy serwer został znaleziony
        start_time = time.time()
        while (not self.server_address or not self.server_port) and (time.time() - start_time < self.timeout):
            time.sleep(0.1)

        if not self.server_address or not self.server_port:
            print("Nie znaleziono serwera w wyznaczonym czasie.")
            self.zeroconf.close()

    def send_images(self):
        """Wyślij wiele obrazów do serwera."""
        while self.image_paths:
            if not os.path.exists(self.image_paths[0]):
                print(f"Plik {self.image_paths[0]} nie istnieje.")
                continue

            # Nawiązywanie połączenia z serwerem
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                try:
                    print(f"Łączenie z serwerem {self.server_address}:{self.server_port}...")
                    sock.connect((self.server_address, self.server_port))

                    # Wyślij nazwę pliku
                    file_name = os.path.basename(self.image_paths[0])
                    sock.sendall(file_name.encode())

                    # Wyślij zawartość pliku
                    with open(self.image_paths[0], 'rb') as f:
                        while True:
                            data = f.read(4096)
                            if not data:
                                break
                            sock.sendall(data)

                    print(f"Obraz {file_name} został pomyślnie wysłany.")
                    self.image_paths.remove(self.image_paths[0])
                except ConnectionError:
                    print("Błąd połączenia z serwerem.")

    def run(self):
        """Uruchom proces wyszukiwania serwera i wysyłania obrazów."""
        self.find_service()
        if self.server_address and self.server_port:
            self.send_images()
        else:
            print("Nie znaleziono serwera.")

# Przykładowe użycie
if __name__ == "__main__":
    image_paths = [
        "images/buddha_mini6/00001_c.png",
        "images/buddha_mini6/00002_c.png",
        "images/buddha_mini6/00003_c.png",
        "images/buddha_mini6/00004_c.png",
        "images/buddha_mini6/00005_c.png",
        "images/buddha_mini6/00006_c.png"
    ]  # Lista ścieżek do zdjęć
    sender = ImageSender(image_paths)
    sender.run()
