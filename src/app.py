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


class ToolTip:
    """Klasa obsługująca tooltipy w Tkinter."""
    def __init__(self, widget, text):
        self.widget = widget
        self.text = text
        self.tooltip_window = None

        # Powiąż zdarzenia z widgetem
        self.widget.bind("<Enter>", self.show_tooltip)
        self.widget.bind("<Leave>", self.hide_tooltip)

    def show_tooltip(self, event=None):
        """Pokaż dymek z tekstem."""
        if self.tooltip_window or not self.text:
            return

        x, y, _, _ = self.widget.bbox("insert")  # Pozycja widgetu
        x += self.widget.winfo_rootx() + 25  # Dodaj przesunięcie
        y += self.widget.winfo_rooty() + 20

        # Utwórz okno dla tooltipa
        self.tooltip_window = tw = tk.Toplevel(self.widget)
        tw.wm_overrideredirect(True)  # Usuń ramkę okna
        tw.wm_geometry(f"+{x}+{y}")

        label = tk.Label(tw, text=self.text, justify="left",
                         background="#ffffe0", relief="solid", borderwidth=1,
                         font=("tahoma", "8", "normal"))
        label.pack(ipadx=5, ipady=2)

    def hide_tooltip(self, event=None):
        """Ukryj dymek."""
        if self.tooltip_window:
            self.tooltip_window.destroy()
            self.tooltip_window = None

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
        label = tk.Label(self, text="Strona startowa", font=controller.title_font)
        label.pack(side="top", fill="x", pady=5)

        main_frame = tk.Frame(self, relief="sunken", bd=2, width=100)
        main_frame.pack(side="top", pady=10, padx=10, expand=True)

        button1 = tk.Button(main_frame, text="Odbieranie zdjęć",
                            command=lambda: controller.show_frame("ImageReceiverApp"))
        button1.pack(fill="x", pady=10, padx=10)

        button2 = tk.Button(main_frame, text="Przeglądanie zdjęć",
                            command=lambda: controller.show_frame("ImageBrowserApp"))
        button2.pack(fill="x", pady=10, padx=10)

        button3 = tk.Button(main_frame, text="Fotogrametria",
                            command=lambda: controller.show_frame("PhotogrammetryApp"))
        button3.pack(fill="x", pady=10, padx=10)

        quit_button = tk.Button(main_frame, text="Wyjście",
                            command=controller.destroy)
        quit_button.pack(fill="x", pady=10, padx=10)

class ImageReceiverApp(tk.Frame):
    
    service_thread = None
    zeroconf = None

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller
        
        label = tk.Label(self, text="Odbierania zdjęć", font=controller.title_font)
        label.pack(side="top", fill="x", pady=5)

        main_frame = tk.Frame(self, relief="sunken", bd=2, width=100)
        main_frame.pack(side="top", pady=10, padx=10, expand=True)

        start_button = tk.Button(main_frame, text="Rozpocznij usługę", command=self.start_services)
        start_button.pack(fill="x", pady=10, padx=10)

        stop_button = tk.Button(main_frame, text="Zatrzymaj usługę", command=self.stop_services)
        stop_button.pack(fill="x", pady=10, padx=10)

        return_button = tk.Button(main_frame, text="Powrót",
                            command=lambda: controller.show_frame("StartPage"))
        return_button.pack(fill="x", pady=10, padx=10)

    def start_services(self):
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
            self.zeroconf = None
            self.service_thread = None

    def start_mdns_service(self):
        local_ip = socket.gethostbyname(socket.gethostname())
        zeroconf = Zeroconf()
        service_info = ServiceInfo(
            SERVICE_TYPE,
            SERVICE_NAME,
            addresses=[socket.inet_aton(local_ip)],
            port=SERVICE_PORT,
            properties={},
            server=f"PhotoScanner.local."
        )
        zeroconf.register_service(service_info)
        log(f"Zarejestrowano usługę mDNS na IP: {local_ip}")
        return zeroconf

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

                # Read number of files first
                num_files = int(conn.recv(BUFFER_SIZE).decode().strip())
                log(f"Oczekiwana liczba plików: {num_files}")

                for i in range(num_files):
                    # Read file name
                    file_name = ""
                    while True:
                        char = conn.recv(1).decode()
                        if char == '\n': break
                        file_name += char
                    
                    # Read file size
                    file_size = ""
                    while True:
                        char = conn.recv(1).decode()
                        if char == '\n': break
                        file_size += char
                    file_size = int(file_size)
                    
                    log(f"Odbieranie pliku {i+1}/{num_files}: {file_name} ({file_size} bajtów)")
                    
                    # Save file
                    file_path = os.path.join(UPLOAD_FOLDER, file_name)
                    with open(file_path, 'wb') as f:
                        bytes_received = 0
                        while bytes_received < file_size:
                            chunk = conn.recv(min(BUFFER_SIZE, file_size - bytes_received))
                            if not chunk: break
                            f.write(chunk)
                            bytes_received += len(chunk)
                    
                    log(f"Zapisano plik: {file_path}")

                conn.close()
                log("Zakończono odbieranie plików")
                
            except TimeoutError:
                continue
            except OSError:
                break
            except Exception as e:
                log(f"Błąd: {str(e)}")
                if 'conn' in locals():
                    conn.close()
                continue
        
        log('Zakończono usługę')

class ImageBrowserApp(tk.Frame):
    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller

        label = tk.Label(self, text="Przeglądanie zdjęć", font=controller.title_font)
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

        view_button = tk.Button(left_frame, text="Wyświetl zaznaczone", command=self.view_selected_image)
        view_button.pack(padx=5, pady=5, fill='x')

        delete_button = tk.Button(left_frame, text="Usuń zaznaczone", command=self.delete_selected_image)
        delete_button.pack(padx=5, pady=5, fill='x')

        delete_all_button = tk.Button(left_frame, text="Usuń wszystko", command=self.delete_all_images)
        delete_all_button.pack(padx=5, pady=5, fill='x')

        refresh_button = tk.Button(left_frame, text="Odśwież", command=self.refresh_image_list)
        refresh_button.pack(padx=5, pady=5, fill='x')

        return_button = tk.Button(left_frame, text="Powrót", command=lambda: controller.show_frame("StartPage"))
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
            confirm = messagebox.askyesno("Usuń zdjęcie", f"Czy jesteś pewien, żeby usunąć zdjęcie '{selected_image}'?")
            if confirm:
                os.remove(os.path.join(UPLOAD_FOLDER, selected_image))
                self.refresh_image_list()
                messagebox.showinfo("Usunięto", f"'{selected_image}' zostało usunięte.")
        else:
            messagebox.showwarning("Bark zaznaczenia", "Zaznacz zdjęcie, żeby móc je usunąć.")

    def delete_all_images(self):
        """Deletes all images in the UPLOAD_FOLDER."""
        confirm = messagebox.askyesno("Usuń Wszystkie Zdjęcia", "Czy jesteś pewien, żeby usunąć wszystkie zdjęcia?")
        if confirm:
            for image in os.listdir(UPLOAD_FOLDER):
                if image.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp')):
                    os.remove(os.path.join(UPLOAD_FOLDER, image))
            self.refresh_image_list()
            messagebox.showinfo("Usunięto", "Wszystkie zdjęcie zostały usunięte.")

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

            close_button = tk.Button(view_window, text="Zamknij", command=view_window.destroy)
            close_button.pack(pady=10)
        else:
            messagebox.showwarning("Bark zaznaczenia", "Zaznacz zdjęcie, żeby móc je wyświetlić.")


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
        self.description = [
            'Ustawienie predefiniowane dla ekstrakcji cech obrazu. \nOkreśla poziom szczegółowości analizowanych cech \n(np. "low" - niski, "ultra" - bardzo wysoki). \nWpływa na szybkość i dokładność przetwarzania.',
            'Jakość wyodrębnianych cech. Wyższa jakość ("high", "ultra") \nzapewnia większą precyzję, ale wydłuża czas przetwarzania.',
            'Współczynnik zmniejszenia rozdzielczości obrazu podczas generowania mapy głębi. \nWyższe wartości (np. "8", "16") przyspieszają przetwarzanie kosztem dokładności.',
            'Rozdzielczość tekstury generowanej dla modelu 3D. \nOpcje określają długość jednego boku tekstury w pikselach (np. "2048" oznacza teksturę 2048x2048 px). \nWyższe wartości zapewniają lepsze detale.',
            'Współczynnik zmniejszenia rozdzielczości tekstury w stosunku do oryginalnej. \nMniejsze wartości (np. "1", "2") zachowują wysoką jakość, \npodczas gdy wyższe redukują szczegółowość dla szybszego renderowania.',
        ]

        # Store selected values for each option
        self.selected_options = {key: tk.StringVar(value=values[1]) for key, values in self.options.items()}
        self.use_cuda = tk.BooleanVar(value=False)  # Variable for CUDA checkbox

        # Header label for the Photogrammetry page
        label = tk.Label(self, text="Fotogrametria", font=controller.title_font)
        label.pack(side="top", fill="x", pady=5)

        # Split the frame into left and right sections
        left_frame = tk.Frame(self, relief="sunken", bd=2)
        left_frame.pack(side="left", fill="y", padx=5, pady=10)

        right_frame = tk.Frame(self, relief="sunken", bd=2)
        right_frame.pack(side="right", fill="both", expand=True, padx=5, pady=10)

        option_frame = tk.LabelFrame(right_frame, text="Opcje Grafu")
        option_frame.pack(side="left", fill="both", expand=True, padx=10, pady=10)

        # Start photogrammetry button on the left side
        self.photogrammetry_button = tk.Button(left_frame, text="Rozpocznij",
                                          command=lambda: self.new_photogrammetry_thread())
        self.photogrammetry_button.pack(padx=5, pady=5, fill='x')

        # Return button on the left side
        return_button = tk.Button(left_frame, text="Powrót",
                                  command=lambda: controller.show_frame("StartPage"))
        return_button.pack(padx=5, pady=5, fill='x')

        # CUDA option on the right side
        cuda_checkbox = tk.Checkbutton(option_frame, text="CUDA", variable=self.use_cuda, command=self.toggle_depthmap_options)
        cuda_checkbox.grid(row=0, column=0, sticky="w", pady=5)

        # Create the selection options on the right side
        row = 1  # Start row after CUDA option
        i = 0
        for option_name, choices in self.options.items():
            # Label for each option
            label = tk.Label(option_frame, text=option_name)
            label.grid(row=row, column=0, sticky="w", pady=2, padx=10)

            ToolTip(label, text=self.description[i])
            i += 1

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
        confirm = messagebox.askyesno("Usuń poprzedni folder cach", f"Czy chcesz usunąć wszystkie dane z folderu cach? (powinno się to zrobić przy nowym zestawie zdjęć)")
        if confirm:
            if os.path.exists('./MeshroomCache'):
                shutil.rmtree(os.path.abspath("./MeshroomCache"))
        if options["Use CUDA"]:
            graph_folder = "./src/graphs/cuda_2048.mg"
        else:
            graph_folder = "./src/graphs/draft_2048.mg"
            options.pop('DepthMap:downscale', None)
        options.pop('Use CUDA', None)
        options_join = [f"{key}={value}" for key,value in options.items()]
        subprocess.run(["meshroom_batch", "--input", image_folder, "--output", output_folder, "--pipeline", graph_folder, "--cache", cache_folder, "--save", graph_folder, "--forceStatus", "--paramOverrides", *options_join])
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
