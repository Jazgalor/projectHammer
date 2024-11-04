import os
import socket
import threading
import subprocess
from zeroconf import Zeroconf, ServiceInfo
import tkinter as tk
from tkinter import font as tkfont
from tkinter import Label


# Konfiguracja ścieżki do folderu z obrazami
UPLOAD_FOLDER = 'output/received_images'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

MODEL_FOLDER = 'output/meshroom'

# Parametry serwera
SERVICE_TYPE = "_imageTransfer._tcp.local."
SERVICE_NAME = "ImageTransferService._imageTransfer._tcp.local."
SERVICE_PORT = 5000
BUFFER_SIZE = 4096
SERVICE_IS_RUNNING = False


# Funkcja odbierająca pliki
def start_receive_service():
    # Ustawienia serwera TCP
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('', SERVICE_PORT))
    server_socket.listen(5)
    print(f"Serwer nasłuchuje na porcie {SERVICE_PORT}...")

    while SERVICE_IS_RUNNING:
        try:      
            server_socket.settimeout(1.0)
            conn, addr = server_socket.accept()
            print(f"Odebrano połączenie z: {addr}")

            # Odbieranie nazwy pliku
            file_name = conn.recv(BUFFER_SIZE).decode().strip()
            if not file_name:
                print("Nie udało się odebrać nazwy pliku.")
                conn.close()
                continue

            file_path = os.path.join(UPLOAD_FOLDER, file_name)
            with open(file_path, 'wb') as f:
                print(f"Zapisywanie pliku: {file_path}")
                while True:
                    data = conn.recv(BUFFER_SIZE)
                    if not data:
                        break
                    f.write(data)

            print(f"Plik {file_name} zapisany.")
            conn.close()
        except TimeoutError:
            continue
        except OSError:
            break
        except UnicodeDecodeError:
            conn.close()
            continue
    print('End of service')

# Funkcja do rozgłaszania usługi mDNS
def start_mdns_service():
    host_ip = socket.gethostbyname(socket.gethostname())
    zeroconf = Zeroconf()
    service_info = ServiceInfo(
        SERVICE_TYPE,
        SERVICE_NAME,
        SERVICE_PORT,
        0,
        0,
        {},
        "ImageTransferService.local.",
        addresses=[socket.inet_aton(host_ip)],
    )

    zeroconf.register_service(service_info)
    print("Usługa mDNS zarejestrowana.")
    return zeroconf

def start_photogrammetry():
    image_folder = UPLOAD_FOLDER
    output_folder = MODEL_FOLDER
    graph_folder = "./src/graphs/draft_2048.mg"
    cache_folder = os.path.abspath("./MeshroomCache")
    subprocess.run(["meshroom_batch", "--input", image_folder, "--output", output_folder, "--pipeline", graph_folder, "--cache", cache_folder, "--paramOverrides", "FeatureExtraction:describerPreset=medium", "FeatureExtraction:describerQuality=medium"])

#############################################
#                   GUI
#############################################

class App(tk.Tk):

    def __init__(self, *args, **kwargs):
        tk.Tk.__init__(self, *args, **kwargs)

        self.title_font = tkfont.Font(family='Helvetica', size=18, weight="bold", slant="roman")
        self.geometry("480x320")

        # the container is where we'll stack a bunch of frames
        # on top of each other, then the one we want visible
        # will be raised above the others
        container = tk.Frame(self)
        container.pack(side="top", fill="both", expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)

        self.frames = {}
        for F in (StartPage, ImageReceiverApp, PhotogrammetryApp):
            page_name = F.__name__
            frame = F(parent=container, controller=self)
            self.frames[page_name] = frame

            # put all of the pages in the same location;
            # the one on the top of the stacking order
            # will be the one that is visible.
            frame.grid(row=0, column=0, sticky="nsew")

        self.show_frame("StartPage")

    def show_frame(self, page_name):
        '''Show a frame for the given page name'''
        frame = self.frames[page_name]
        frame.tkraise()

class StartPage(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller
        label = tk.Label(self, text="Start page", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)

        button1 = tk.Button(self, text="Image receiver page",
                            command=lambda: controller.show_frame("ImageReceiverApp"))
        button1.pack(pady=10)

        button2 = tk.Button(self, text="Photogrammetry page",
                            command=lambda: controller.show_frame("PhotogrammetryApp"))
        button2.pack(pady=10)

class ImageReceiverApp(tk.Frame):
    
    service_thread = None

    zeroconf = None

    def __init__(self, parent, controller):

        tk.Frame.__init__(self, parent)
        self.controller = controller
        
        label = tk.Label(self, text="Image receiver service page", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)

        start_button = tk.Button(self, text="Start service", command=self.start_service)
        start_button.pack(pady=10)

        start_button = tk.Button(self, text="Stop service", command=self.stop_service)
        start_button.pack(pady=10)

        return_button = tk.Button(self, text="Return",
                            command=lambda: controller.show_frame("StartPage"))
        return_button.pack(pady=10)

    def start_service(self):
        global SERVICE_IS_RUNNING
        SERVICE_IS_RUNNING = True
        self.zeroconf = start_mdns_service()
        self.SERVICE_THREAD = threading.Thread(target=start_receive_service, daemon=True)
        self.SERVICE_THREAD.start()
    
    def stop_service(self):
        global SERVICE_IS_RUNNING
        if self.zeroconf:
            SERVICE_IS_RUNNING = False
            self.zeroconf.close()
            # function for unregistering is not necessary
            # zeroconf.unregister_service(ServiceInfo(
            #     SERVICE_TYPE, SERVICE_NAME, SERVICE_PORT,
            #     0,
            #     0,
            #     {},
            #     "ImageTransferService.local.")) 
            self.zeroconf = None
            self.SERVICE_THREAD = None


class PhotogrammetryApp(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller

        self.options = {
            "FeatureExtraction:describerPreset": tk.StringVar(self, ["low", "medium", "normal", "high", "ultra"]),
            "FeatureExtraction:describerQuality": tk.StringVar(self,["low", "medium", "normal", "high", "ultra"]),
            "DepthMap:downscale": tk.StringVar(self,["1", "2", "4", "8", "16"]),
            "Texturing:textureSide": tk.StringVar(self,["1024", "2048", "4096", "8192", "16384"]),
            "Texturing:downscale": tk.StringVar(self,["1", "2", "4", "8"]),
        }

        label = tk.Label(self, text="Photogrammetry Page", font=controller.title_font)
        label.pack(side="top", fill="x", pady=5)

        # Divide the frame into left and right sections
        left_frame = tk.Frame(self, relief="raised", bd=2)
        left_frame.pack(side="left", fill="y", padx=10, pady=10)

        right_frame = tk.LabelFrame(self, text="Graph options")
        right_frame.pack(side="left", fill="both", expand=True, padx=10, pady=10)

        # Label for photogrammetry page
       

        # Start photogrammetry button
        photogrammetry_button = tk.Button(left_frame, text="Start",
                                          command=self.new_photogrammetry_thread)
        photogrammetry_button.pack(padx=5, pady=5, fill='x')

        # Return button
        return_button = tk.Button(left_frame, text="Return",
                                  command=lambda: controller.show_frame("StartPage"))
        return_button.pack(padx=5, pady=5, fill='x')

        # Multiple selection options on the rights

        # Add some example options (these could be adapted to match Meshroom's parameters)
        label1 = tk.Label(right_frame, text="Describer Density")
        label1.grid(row=0, column=0, pady=2)
        option1 = tk.Listbox(right_frame, selectmode="single", listvariable=self.options["FeatureExtraction:describerPreset"])
        option1.grid(row=1, column=0, pady=2)
        option1.activate(3)

        label2 = tk.Label(right_frame, text="Describer Quality")
        label2.grid(row=0, column=1, pady=2)
        option2 = tk.Listbox(right_frame, selectmode="single", listvariable=self.options["FeatureExtraction:describerQuality"])
        option2.grid(row=1, column=1, pady=2)
        option2.activate(3)

        # self.option2_var = tk.BooleanVar()
        # option2 = tk.Checkbutton(right_frame, text="Option 2: Depth Map Adjustment", variable=self.option2_var)
        # option2.pack(anchor="w", pady=2)

        # self.option3_var = tk.BooleanVar()
        # option3 = tk.Checkbutton(right_frame, text="Option 3: Texture Quality", variable=self.option3_var)
        # option3.pack(anchor="w", pady=2)

    def new_photogrammetry_thread(self):
        # In a real implementation, these options would adjust the subprocess call or graph configuration
        options = {
            "High Quality": self.option1_var.get(),
            "Depth Map Adjustment": self.option2_var.get(),
            "Texture Quality": self.option3_var.get()
        }
        print("Starting photogrammetry with options:", options)
        threading.Thread(target=start_photogrammetry, daemon=True).start()

        

#############################################
#                  MAIN
#############################################

if __name__ == "__main__":
    # Inicjalizacja GUI
    app = App()

    # # Rozgłaszanie usługi mDNS
    # zeroconf = start_mdns_service()
    
    # # Uruchamianie serwera w osobnym wątku
    # threading.Thread(target=start_receive_service, daemon=True).start()

    # Obsługa GUI
    try:
        app.mainloop()
    finally:
        pass
        # Wyrejestrowanie usługi mDNS
        # zeroconf.unregister_service(ServiceInfo(SERVICE_TYPE, SERVICE_NAME))
        # zeroconf.close()
