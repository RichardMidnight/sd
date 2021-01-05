# sd - Raspberry Pi image maker

 - Easily make compressed images of your Raspberry Pi.
 
 - Easily restore images to an SD card.

 - Read an image-file from an sd card.

 - Write an image-file to an sd card.

 - Works entirely on a Raspberry Pi in terminal.  No Windows or Mac needed. 
 
 - Creates a compressed image-file that will resize to fill the new card it is put on (thanks to PiShrink).
 
 - Supports .img .zip and .xz file formats.
 
 - Supports all USB storage.
 
 - Supports USB boot (tries to hide the boot disk).
 
.
 
# SETUP
 
   1) Install Raspberry PI OS on an SD card that is large enought to hold some SD image-files.  32GB or 64GB will do.  This is your Master SD-card.
   
   2) Install sd as described below.
   
   3) You will need a USB-SD reader for your source SD-card.
   
   4) You will need some SD cards.  Use as small of an SD-card as you can because the entire card has to be read in before it is shrunk and compressed.  I have been using Sandisk Industrial 8GB cards.
   
.   

   
# TO MAKE AN IMAGE FILE  
   
   1) Boot your Pi to your Master SD-card as above.
   
   2) Put your source SD-card in the USB SD reader and insert it in a Pi USB port.
   
   3) Open a terminal window.
   
   4) Change to the 'Downloads' folder (optional).
   
    cd Downloads
   
   4) Type in the command below to see the name of the SD-device.  If it is the only one in, it should be 'sda'.
  
     sd list
         
   4)  Type in the command below to start reading the SD-card to an image-file
   
      sd read
        
   5) Follow the prompts to enter the SD-device name (probably 'sda') and the image-file-name you want to use.
   
   6) Watch your image-file get created!
   
 .
   

# INSTALL

In a terminal window, type in

    wget https://raw.githubusercontent.com/RichardMidnight/sd/main/sd
    chmod +x sd
    sudo mv sd /usr/local/bin
.

# EXAMPLES

List available SD-cards and image-files

     sd list 
     
To create an image-file from your SD-card in 'sda'

     sd read sda newimage.zip
     
To write an image-file to an SD-card in 'sda'

    sd write newimage.zip sda
    
    
.

# SAMPLE SESSION CREATING AN IMAGE FILE

This was all automatic except for the initial command 'sd read sda newimage' and answering 'y'.

It took 12 minutes to create an image from an 8GB SD-card on a Raspberry Pi 4. The image compressed to 1.6GB

    
    pi@RaspberryPi-Master:~/Downloads $ sd read sda newimage
    Copyright (c) 2018-2020 Richard Reed
    sd imager v1.5.10
    Checking to see if required tools are installed ...[OK]

    Read SD card
    SD card = 'sda SanDisk SDDR-B531 7.4G'
    Checking for SD card over 16GB ...          ' 7.4G' [OK]
    Checking for enough space on the drive ...  '13G' [OK]
    Adding .zip extension...
    Image file = 'newimage.zip'
    Checking for supported file extension ...   'zip' [OK]

    Create image-file 'newimage.zip' from '/dev/sda' [y,N] ?y

    Step 1 - Reading SD card to newimage.img ...
    Tue 05 Jan 2021 12:33:32 PM EST
    7.4G to read
    7948206080 bytes (7.9 GB, 7.4 GiB) copied, 291 s, 27.3 MB/s
    1895+0 records in
    1895+0 records out
    7948206080 bytes (7.9 GB, 7.4 GiB) copied, 293.14 s, 27.1 MB/s
    Done reading SD card
    7.5G newimage.img
    Step 1 took 4 min 58 sec

    Step 2 - Shrinking filesystem with PiShrink ...
    pishrink.sh v0.1.2
    pishrink.sh: Gathering data ...
    Creating new /etc/rc.local
    pishrink.sh: Checking filesystem ...
    rootfs: 110650/460288 files (0.2% non-contiguous), 894551/1873920 blocks
    resize2fs 1.44.5 (15-Dec-2018)
    pishrink.sh: Shrinking filesystem ...
    resize2fs 1.44.5 (15-Dec-2018)
    Resizing the filesystem on /dev/loop0 to 952788 (4k) blocks.
    Begin pass 2 (max = 221227)
    Relocating blocks             XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    Begin pass 3 (max = 58)
    Scanning inode table          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    Begin pass 4 (max = 9374)
    Updating inode references     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    The filesystem on /dev/loop0 is now 952788 (4k) blocks long.

    pishrink.sh: Shrinking image ...
    pishrink.sh: Shrunk newimage.img from 7.5G to 3.9G ...
    Done shrinking filesystem
    3.9G newimage.img
    Step 2 took 2 min 5 sec

    Step 3 - Compressing newimage.img to newimage.zip ...
    Compression level set to -1 out of -9
    [   0/3.8G]   adding: newimage.img ............................................................................................................................................................................................................................................................................................................................................................................................................... (deflated 59%)
    Done compressing newimage.img to newimage.zip
    1.6G newimage.zip
    Step 3 took 5 min 22 sec

    7.4G SD card compressed to 3981M in 12 min 25 sec
    You can rename newimage.zip, but it is highly recomended to leave the extension as '.zip'.
    You can remove the SD card in /dev/sda now.
    pi@RaspberryPi-Master:~/Downloads $ 





