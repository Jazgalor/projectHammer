from zeroconf import Zeroconf, ServiceBrowser, ServiceListener

class MyListener(ServiceListener):
    def add_service(self, zeroconf, service_type, name):
        print(f"Znaleziono usługę: {name}")

    def remove_service(self, zeroconf, service_type, name):
        print(f"Usługa została usunięta: {name}")

    def update_service(self, zeroconf, service_type, name):
        print(f"Zaktualizowano usługę: {name}")

zeroconf = Zeroconf()
listener = MyListener()
browser = ServiceBrowser(zeroconf, "_imageTransfer._tcp.local.", listener)

try:
    input("Naciśnij Enter, aby zakończyć...\n\n")
finally:
    zeroconf.close()
