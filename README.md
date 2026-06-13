<div align="center">

# 🖥️ Basic Operating System

[![](https://img.shields.io/badge/Language-English-blue?style=for-the-badge&logo=google-translate)](#english-version)
&nbsp;&nbsp;&nbsp;&nbsp;
[![](https://img.shields.io/badge/Dil-T%C3%BCrk%C3%A7e-red?style=for-the-badge&logo=google-translate)](#turkish-version)

---

[![Language: Assembly](https://img.shields.io/badge/Language-Assembly%20(x86)-blue.svg?style=flat-square)](https://www.nasm.us/)
[![Platform: 8086 Real Mode](https://img.shields.io/badge/Platform-8086%20Real%20Mode-orange.svg?style=flat-square)](#)
[![Emulator: Emu8086 / QEMU](https://img.shields.io/badge/Emulator-Emu8086%20%2F%20QEMU-success.svg?style=flat-square)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

</div>

---

<a id="english-version"></a>
# English Version

A simple 16-bit real-mode operating system project written in Assembly, consisting of a custom bootloader (`micro-os_loader.asm`) and a command-line interface kernel module (`micro-os_kernel.asm`). Designed to demonstrate the low-level fundamentals of computer architecture, memory mapping, and hardware control.

## 📸 Project Preview

![Basic-Operating-System-Tanıtım](https://github.com/user-attachments/assets/4f7a55ca-95a6-411b-b78a-81f8e4cb8865)

---

## 🧠 Memory Layout

The memory addresses allocated for loading and stack management are configured as follows:

| Address Range (Hex) | Component / Unit | Description |
| :--- | :--- | :--- |
| **`07C0:0000` - `07C0:01FF`** | Bootloader (Boot Sector) | 512-byte boot sector code loaded from the 1st sector of the floppy disk. |
| **`07C0:0200` - `07C0:03FF`** | Stack | Stack memory space used by the OS (255 words). |
| **`0800:0000` - `0800:1400`** | Kernel | Kernel code loaded from the 2nd sector onwards (10 sectors / ~5 KB). |

---

## 🛠️ Supported CLI Commands

Upon boot, the system initializes a command-line interface with a clean *white text on blue background* layout. The following interactive commands are supported:

| Command | Description |
| :--- | :--- |
| `help` | Prints the list of available commands and their descriptions. |
| `cls` | Clears the screen and resets the cursor to the top-left corner. |
| `hiworld` | Prints a custom "Hello World!" greeting and waits for key input. |
| `animation` | Enters graphics mode (Mode 13h - 320x200 256 Colors) and draws geometric square patterns. |
| `reboot` | Prompts the user to eject floppy disks and performs a warm reboot. |
| `quit` / `exit` | Reboots the system to exit the OS environment. |

---

## 🚀 Compilation & Emulation Guide

### 1. Setup Emulator
You can compile and emulate the project files directly using the **Emu8086** software or QEMU.

### 2. Compilation
- Compile `micro-os_loader.asm` to binary format to obtain `loader.bin`.
- Compile `micro-os_kernel.asm` to binary format to obtain `micro-os_kernel.bin`.

### 3. Creating Bootable Floppy Image
To flash and run the files on a virtual machine (VirtualBox, VMware) or real hardware:
- Write `loader.bin` to the **1st sector** (boot sector) of an empty floppy image.
- Write `micro-os_kernel.bin` to the **2nd sector** of the floppy image.
- Load the compiled floppy image (IMG/FLPY) into your emulator/VM and boot.

---

<a id="turkish-version"></a>
# Türkçe Versiyon

Assembly diliyle yazılmış, kendi özel önyükleyicisi (bootloader - `micro-os_loader.asm`) ve komut satırı arayüzüne (CLI) sahip çekirdeğinden (kernel - `micro-os_kernel.asm`) oluşan 16-bit real-mode (gerçek mod) çalışan minimal bir işletim sistemi projesidir. Bilgisayar mimarisi ve düşük seviye programlama mantığını anlamak amacıyla geliştirilmiştir.

## 📸 Proje Görseli

![Basic-Operating-System-Tanıtım](https://github.com/user-attachments/assets/4f7a55ca-95a6-411b-b78a-81f8e4cb8865)

---

## 🧠 Bellek Haritası (Memory Layout)

Yükleme ve yığın (stack) yönetimi için belirlenen bellek adresleri şu şekildedir:

| Adres Aralığı (Hex) | Fonksiyon / Birim | Açıklama |
| :--- | :--- | :--- |
| **`07C0:0000` - `07C0:01FF`** | Önyükleyici (Boot Sector) | Disketin 1. sektöründen yüklenen 512 baytlık önyükleyici kod alanı. |
| **`07C0:0200` - `07C0:03FF`** | Stack (Yığın) | İşletim sisteminin kullandığı yığın alanı (255 word). |
| **`0800:0000` - `0800:1400`** | Kernel (Çekirdek) | Disketin 2. sektöründen itibaren yüklenen çekirdek kod alanı (10 sektör / ~5 KB). |

---

## 🛠️ Desteklenen Komutlar

Sistem başlatıldığında mavi ekran üzerine beyaz yazı stiliyle (`white on blue`) bir konsol açılır. Aşağıdaki komutlar çalıştırılabilir:

| Komut | Açıklama |
| :--- | :--- |
| `help` | Kullanılabilir tüm komutları ve açıklamalarını ekrana listeler. |
| `cls` | Ekranı temizler ve imleci sol üst köşeye taşır. |
| `hiworld` | Ekrana özelleştirilmiş "Merhaba Dünya!" mesajı yazdırır ve tuş girdisi bekler. |
| `animation` | Grafik moduna (Mode 13h - 320x200 256 Renk) geçerek ekrana geometrik kare animasyonları çizer. |
| `reboot` | Kullanıcıdan disketleri çıkarmasını ister ve sistemi yeniden başlatır (warm boot). |
| `quit` / `exit` | Sistemden çıkış yapmak için bilgisayarı yeniden başlatır. |

---

## 🚀 Nasıl Derlenir ve Çalıştırılır?

### 1. Emu8086 Kurulumu
Kodları derlemek ve emüle etmek için **Emu8086** emülatörünü veya QEMU'yu kullanabilirsiniz.

### 2. Derleme Aşaması
- `micro-os_loader.asm` dosyasını derleyerek `loader.bin` dosyasını oluşturun.
- `micro-os_kernel.asm` dosyasını derleyerek `micro-os_kernel.bin` dosyasını oluşturun.

### 3. Diske Yazma ve Test (Sanal Makine/Gerçek Donanım)
- Boş bir disket görüntüsüne (floppy image) veya diskete:
  - `loader.bin` dosyasını **1. sektöre** yazın.
  - `micro-os_kernel.bin` dosyasını **2. sektöre** yazın.
- Oluşturulan imajı VirtualBox, VMware veya QEMU üzerinde floppy disk olarak ekleyerek sistemi başlatın.
