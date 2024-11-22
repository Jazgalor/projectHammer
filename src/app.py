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
from typing import Literal
from zeroconf import Zeroconf, ServiceInfo
import tkinter as tk
from tkinter import messagebox, font as tkfont
from PIL import Image, ImageTk
import shutil

#############################################
#                   INIT
#############################################

# Konfiguracja ścieżki do folderu z obrazami
UPLOAD_FOLDER = 'output/received_images'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

MODEL_FOLDER = 'output/meshroom'
if not os.path.exists(MODEL_FOLDER):
    os.makedirs(MODEL_FOLDER)

# Parametry serwera
SERVICE_TYPE = "_imageTransfer._tcp.local."
SERVICE_NAME = "ImageTransferService._imageTransfer._tcp.local."
SERVICE_PORT = 5000
BUFFER_SIZE = 4096
SERVICE_IS_RUNNING = False

#############################################
#                 FUNCTIONS
#############################################

def log(
    *values: object,
    sep: str | None = " ",
    end: str | None = "\n",
    flush: Literal[False] = False,
    ): threading.Thread(target=print, args=values, kwargs={'sep': sep, 'end': end, 'flush': flush}, daemon=True).start()


#############################################
#                   GUI
#############################################

class App(tk.Tk):

    def __init__(self, *args, **kwargs):
        tk.Tk.__init__(self, *args, **kwargs)

        self.title_font = tkfont.Font(family='Helvetica', size=18, weight="bold", slant="roman")
        self.geometry("480x320")

        container = tk.Frame(self)
        container.pack(side="top", fill="both", expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)

        self.frames = {}
        for F in (StartPage, ImageReceiverApp, ImageBrowserApp, PhotogrammetryApp):
            page_name = F.__name__
            frame = F(parent=container, controller=self)
            self.frames[page_name] = frame
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
        main_frame.pack(side="top", pady=10, padx=10, expand=True)

        button1 = tk.Button(main_frame, text="Image receiver page",
                            command=lambda: controller.show_frame("ImageReceiverApp"))
        button1.pack(fill="x", pady=10, padx=10)

        button2 = tk.Button(main_frame, text="Image browser page",
                            command=lambda: controller.show_frame("ImageBrowserApp"))
        button2.pack(fill="x", pady=10, padx=10)

        button3 = tk.Button(main_frame, text="Photogrammetry page",
                            command=lambda: controller.show_frame("PhotogrammetryApp"))
        button3.pack(fill="x", pady=10, padx=10)

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
        main_frame.pack(side="top", pady=10, padx=10, expand=True)

        start_button = tk.Button(main_frame, text="Start service", command=self.start_services)
        start_button.pack(fill="x", pady=10, padx=10)

        stop_button = tk.Button(main_frame, text="Stop service", command=self.stop_services)
        stop_button.pack(fill="x", pady=10, padx=10)

        return_button = tk.Button(main_frame, text="Return",
                            command=lambda: controller.show_frame("StartPage"))
        return_button.pack(fill="x", pady=10, padx=10)


    def start_services(self, ):
        global SERVICE_IS_RUNNING
        SERVICE_IS_RUNNING = True
        self.zeroconf = self.start_mdns_service()
        self.service_thread = threading.Thread(target=self.start_receive_service, daemon=True)
        self.service_thread.start()
    
    def stop_services(self):
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
            self.service_thread = None

    # Funkcja odbierająca pliki
    def start_receive_service(self):
        # Ustawienia serwera TCP
        server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server_socket.bind(('', SERVICE_PORT))
        server_socket.listen(5)
        log(f"Serwer nasłuchuje na porcie {SERVICE_PORT}...")

        while SERVICE_IS_RUNNING:
            try:      
                server_socket.settimeout(1.0)
                conn, addr = server_socket.accept()
                log(f"Odebrano połączenie z: {addr}")

                # Odbieranie nazwy pliku
                file_name = conn.recv(BUFFER_SIZE).decode().strip()
                if not file_name:
                    log("Nie udało się odebrać nazwy pliku.")
                    conn.close()
                    continue

                file_path = os.path.join(UPLOAD_FOLDER, file_name)
                with open(file_path, 'wb') as f:
                    log(f"Zapisywanie pliku: {file_path}")
                    while True:
                        data = conn.recv(BUFFER_SIZE)
                        if not data:
                            break
                        f.write(data)

                log(f"Plik {file_name} zapisany.")
                conn.close()
            except TimeoutError:
                continue
            except OSError:
                break
            except UnicodeDecodeError:
                conn.close()
                continue
        log('End of service')

    # Funkcja do rozgłaszania usługi mDNS
    def start_mdns_service(self):
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
        log("Usługa mDNS zarejestrowana.")
        return zeroconf

class ImageBrowserApp(tk.Frame):
    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller

        label = tk.Label(self, text="Image browser page", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)

        # Frame for list of images
        left_frame = tk.Frame(self, relief="sunken", bd=2)
        left_frame.pack(side="left", fill="y", padx=5, pady=10)

        right_frame = tk.Frame(self, relief="sunken", bd=2)
        right_frame.pack(side="right", fill="both", expand=True, padx=5, pady=10)

        # Listbox for images
        self.image_listbox = tk.Listbox(right_frame, selectmode=tk.SINGLE)
        self.image_listbox.pack(side="left", fill="both", expand=True)

        # Scrollbar for listbox
        self.scrollbar = tk.Scrollbar(right_frame, orient="vertical", command=self.image_listbox.yview)
        self.scrollbar.pack(side="right", fill="y")
        self.image_listbox.config(yscrollcommand=self.scrollbar.set)

        view_button = tk.Button(left_frame, text="View Selected", command=self.view_selected_image)
        view_button.pack(padx=5, pady=5, fill='x')

        delete_button = tk.Button(left_frame, text="Delete Selected", command=self.delete_selected_image)
        delete_button.pack(padx=5, pady=5, fill='x')

        delete_all_button = tk.Button(left_frame, text="Delete All", command=self.delete_all_images)
        delete_all_button.pack(padx=5, pady=5, fill='x')

        refresh_button = tk.Button(left_frame, text="Refresh", command=self.refresh_image_list)
        refresh_button.pack(padx=5, pady=5, fill='x')

        return_button = tk.Button(left_frame, text="Return", command=lambda: controller.show_frame("StartPage"))
        return_button.pack(padx=5, pady=5, fill='x')

        self.refresh_image_list()

    def refresh_image_list(self):
        """Refreshes the listbox with images in UPLOAD_FOLDER."""
        self.image_listbox.delete(0, tk.END)
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)
        images = [img for img in os.listdir(UPLOAD_FOLDER) if img.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp'))]
        for image in images:
            self.image_listbox.insert(tk.END, image)

    def delete_selected_image(self):
        """Deletes the selected image from the list and filesystem."""
        selected_image = self.image_listbox.get(tk.ACTIVE)
        if selected_image:
            confirm = messagebox.askyesno("Delete Image", f"Are you sure you want to delete '{selected_image}'?")
            if confirm:
                os.remove(os.path.join(UPLOAD_FOLDER, selected_image))
                self.refresh_image_list()
                messagebox.showinfo("Deleted", f"'{selected_image}' has been deleted.")
        else:
            messagebox.showwarning("No Selection", "Please select an image to delete.")

    def delete_all_images(self):
        """Deletes all images in the UPLOAD_FOLDER."""
        confirm = messagebox.askyesno("Delete All Images", "Are you sure you want to delete all images?")
        if confirm:
            for image in os.listdir(UPLOAD_FOLDER):
                if image.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp')):
                    os.remove(os.path.join(UPLOAD_FOLDER, image))
            self.refresh_image_list()
            messagebox.showinfo("Deleted", "All images have been deleted.")

    def view_selected_image(self):
        """Opens a new window to display the selected image."""
        selected_image = self.image_listbox.get(tk.ACTIVE)
        if selected_image:
            img_path = os.path.join(UPLOAD_FOLDER, selected_image)
            img = Image.open(img_path)
            img.thumbnail((400, 400))  # Resize for display
            img_tk = ImageTk.PhotoImage(img)

            # New window to display the image
            view_window = tk.Toplevel(self)
            view_window.title(selected_image)

            img_label = tk.Label(view_window, image=img_tk)
            img_label.image = img_tk  # Keep reference to avoid garbage collection
            img_label.pack()

            close_button = tk.Button(view_window, text="Close", command=view_window.destroy)
            close_button.pack(pady=10)
        else:
            messagebox.showwarning("No Selection", "Please select an image to view.")


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
        self.photogrammetry_button = tk.Button(left_frame, text="Start",
                                          command=lambda: self.new_photogrammetry_thread())
        self.photogrammetry_button.pack(padx=5, pady=5, fill='x')

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

    def new_photogrammetry_thread(self):
        # Gather the selected options, including CUDA choice, to use in photogrammetry
        selected_values = {key: var.get() for key, var in self.selected_options.items()}
        selected_values["Use CUDA"] = self.use_cuda.get()
        self.photogrammetry_button.configure(state="disabled")
        threading.Thread(target=self.start_photogrammetry,args=[selected_values], daemon=True).start()
    
    def start_photogrammetry(self, options: dict):
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
        self.photogrammetry_button.configure(state="normal")


        

#############################################
#                  MAIN
#############################################

if __name__ == "__main__":
    # Inicjalizacja GUI
    app = App()

    # Obsługa GUI
    try:
        app.mainloop()
    finally:
        pass
