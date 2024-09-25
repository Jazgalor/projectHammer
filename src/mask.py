import cv2
import numpy as np
import os

# Ścieżka do folderu ze zdjęciami
image_folder = "images/buddha_mini6"
output_folder = "output/buddha_mini6"

if not os.path.exists(output_folder):
    os.makedirs(output_folder)

def mask_image_with_grabcut(image_path, output_path):
    # Wczytanie obrazu
    img = cv2.imread(image_path)
    mask = np.zeros(img.shape[:2], np.uint8)
    
    # Zainicjowanie tablic dla algorytmu
    bgd_model = np.zeros((1, 65), np.float64)  # Model tła
    fgd_model = np.zeros((1, 65), np.float64)  # Model obiektu
    
    # Współrzędne prostokąta zawierającego obiekt (przykład na cały obraz)
    height, width = img.shape[:2]
    rect = (10, 10, width-10, height-10)
    
    # Zastosowanie algorytmu GrabCut
    cv2.grabCut(img, mask, rect, bgd_model, fgd_model, 5, cv2.GC_INIT_WITH_RECT)
    
    # Zmiana maski: oznaczamy obszary na pewno obiektu lub na pewno tła
    mask2 = np.where((mask == 2) | (mask == 0), 0, 1).astype('uint8')
    
    # Nakładamy maskę na obraz
    img_result = img * mask2[:, :, np.newaxis]
    
    # Zapisujemy wynikowy obraz
    cv2.imwrite(output_path, img_result)

# Przetwarzanie wszystkich zdjęć w folderze
for filename in os.listdir(image_folder):
    if filename.endswith(".jpg") or filename.endswith(".png"):
        img_path = os.path.join(image_folder, filename)
        output_path = os.path.join(output_folder, "masked_" + filename)
        mask_image_with_grabcut(img_path, output_path)
