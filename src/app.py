"""
## This is a main file for image server app with additional Functionalities.
### Structure:
 - Imports
 - Initial code
 - Functions
 - GUI app
"""
import os
import socket
import threading
import subprocess
from zeroconf import Zeroconf, ServiceInfo
import tkinter as tk
from tkinter import font as tkfont
import shutil

#############################################
#                   INIT
#############################################

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

#############################################
#                 FUNCTIONS
#############################################

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

def start_photogrammetry(options: dict, button: tk.Button):
    image_folder = UPLOAD_FOLDER
    output_folder = MODEL_FOLDER
    cache_folder = os.path.abspath("./MeshroomCache")
    if os.path.exists('./MeshroomCache'):
        shutil.rmtree(os.path.abspath("./MeshroomCache"))
    if options["Use CUDA"]:
        graph_folder = "./src/graphs/cuda_2048.mg"
    else:
        graph_folder = "./src/graphs/draft_2048.mg"
        options.pop('DepthMap:downscale', None)
    options.pop('Use CUDA', None)
    options_join = [f"{key}={value}" for key,value in options.items()]
    subprocess.run(["meshroom_batch", "--input", image_folder, "--output", output_folder, "--pipeline", graph_folder, "--cache", cache_folder, "--paramOverrides", *options_join])
    button["state"] = "normal"

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
        label.pack(side="top", fill="x", pady=5)

        main_frame = tk.Frame(self, relief="sunken", bd=2, width=100)
        main_frame.pack(side="top", fill="y", pady=10, padx=10, expand=True)

        button1 = tk.Button(main_frame, text="Image receiver page",
                            command=lambda: controller.show_frame("ImageReceiverApp"))
        button1.pack(fill="x", pady=10, padx=10)

        button2 = tk.Button(main_frame, text="Photogrammetry page",
                            command=lambda: controller.show_frame("PhotogrammetryApp"))
        button2.pack(fill="x", pady=10, padx=10)

        quit_button = tk.Button(main_frame, text="Quit",
                            command=controller.destroy)
        quit_button.pack(fill="x", pady=10, padx=10)

class ImageReceiverApp(tk.Frame):
    
    service_thread = None

    zeroconf = None

    def __init__(self, parent, controller):

        tk.Frame.__init__(self, parent)
        self.controller = controller
        
        label = tk.Label(self, text="Image receiver service page", font=controller.title_font)
        label.pack(side="top", fill="x", pady=5)

        main_frame = tk.Frame(self, relief="sunken", bd=2, width=100)
        main_frame.pack(side="top", fill="y", pady=10, padx=10, expand=True)

        start_button = tk.Button(main_frame, text="Start service", command=self.start_service)
        start_button.pack(fill="x", pady=10, padx=10)

        stop_button = tk.Button(main_frame, text="Stop service", command=self.stop_service)
        stop_button.pack(fill="x", pady=10, padx=10)

        return_button = tk.Button(main_frame, text="Return",
                            command=lambda: controller.show_frame("StartPage"))
        return_button.pack(fill="x", pady=10, padx=10)

    def start_service(self, ):
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

        # Define options for each setting
        self.options = {
            "FeatureExtraction:describerPreset": ["low", "medium", "normal", "high", "ultra"],
            "FeatureExtraction:describerQuality": ["low", "medium", "normal", "high", "ultra"],
            "DepthMap:downscale": ["1", "2", "4", "8", "16"],
            "Texturing:textureSide": ["1024", "2048", "4096", "8192", "16384"],
            "Texturing:downscale": ["1", "2", "4", "8"]
        }

        # Store selected values for each option
        self.selected_options = {key: tk.StringVar(value=values[1]) for key, values in self.options.items()}
        self.use_cuda = tk.BooleanVar(value=False)  # Variable for CUDA checkbox

        # Header label for the Photogrammetry page
        label = tk.Label(self, text="Photogrammetry Page", font=controller.title_font)
        label.pack(side="top", fill="x", pady=5)

        # Split the frame into left and right sections
        left_frame = tk.Frame(self, relief="sunken", bd=2)
        left_frame.pack(side="left", fill="y", padx=5, pady=10)

        right_frame = tk.Frame(self, relief="sunken", bd=2)
        right_frame.pack(side="right", fill="both", expand=True, padx=5, pady=10)

        option_frame = tk.LabelFrame(right_frame, text="Graph Options")
        option_frame.pack(side="left", fill="both", expand=True, padx=10, pady=10)

        # Start photogrammetry button on the left side
        photogrammetry_button = tk.Button(left_frame, text="Start",
                                          command=lambda: self.new_photogrammetry_thread(photogrammetry_button))
        photogrammetry_button.pack(padx=5, pady=5, fill='x')

        # Return button on the left side
        return_button = tk.Button(left_frame, text="Return",
                                  command=lambda: controller.show_frame("StartPage"))
        return_button.pack(padx=5, pady=5, fill='x')

        # CUDA option on the right side
        cuda_checkbox = tk.Checkbutton(option_frame, text="Use CUDA", variable=self.use_cuda, command=self.toggle_depthmap_options)
        cuda_checkbox.grid(row=0, column=0, sticky="w", pady=5)

        # Create the selection options on the right side
        row = 1  # Start row after CUDA option
        for option_name, choices in self.options.items():
            # Label for each option
            label = tk.Label(option_frame, text=option_name)
            label.grid(row=row, column=0, sticky="w", pady=2, padx=10)

            # Dropdown menu for each option
            option_menu = tk.OptionMenu(option_frame, self.selected_options[option_name], *choices)
            option_menu.grid(row=row, column=1, sticky="ew", pady=2)

            # If this is the DepthMap option, keep a reference for enabling/disabling
            if option_name == "DepthMap:downscale":
                self.depthmap_menu = option_menu
                option_menu.configure(state="disabled")  # Initially disabled

            row += 1

    def toggle_depthmap_options(self):
        # Enable or disable DepthMap option based on CUDA checkbox state
        if self.use_cuda.get():
            self.depthmap_menu.configure(state="normal")
        else:
            self.depthmap_menu.configure(state="disabled")

    def new_photogrammetry_thread(self, button: tk.Button):
        # Gather the selected options, including CUDA choice, to use in photogrammetry
        selected_values = {key: var.get() for key, var in self.selected_options.items()}
        selected_values["Use CUDA"] = self.use_cuda.get()
        print("Starting photogrammetry with options:", selected_values)
        button["state"] = "disabled"
        threading.Thread(target=start_photogrammetry,args=[selected_values, button], daemon=True).start()


        

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
