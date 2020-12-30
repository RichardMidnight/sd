# sd - Raspberry Pi image maker

 - Easily create an image-file from an sd card.

 - Easily write an image-file to an sd card.

 - Works entirely on a Raspberry Pi in terminal.  No Windows or Mac needed. 
 
 - Creates a compressed image-file that will resize to fill the new card it is put on (thanks to PiShrink).
 
 - Supports .img .zip and .xz file formats.
 
.
 
# SETUP
 
   1) Install Raspberry PI OS on an SD card that is large enought to hold some SD image-files.  32GB or 64GB will do.  This is your Master SD-card.
   
   2) Install sd as described below.
   
   3) You will need a USB-SD reader for your source SD-card and some SD cards.  Use as small of an SD-card as you can because the entire card has to be read in before it is shrunk and compressed.  I have been using Sandisk Industrial 8GB cards.
   
.   

   
# TO MAKE AN IMAGE FILE  
   
   1) Boot your Pi to your Master SD-card as above.
   
   2) Put your source SD-card in the USB SD reader and insert it in a Pi USB port.
   
   3) Open a terminal window.
   
   4) Change to the 'Downloads' folder (optional).
   
    cd Downloads
   
   4) Type in the command below to see the name of the SD-device.  If it is the only one in, it will be 'sda'.
  
     sd list
         
   4)  Type in the command below to start reading the SD-card to an image-file
   
      sd read
        
   5) Follow the prompts to enter the SD-device name (probably 'sda') and the image-file-name you want to use.
   
   6) Watch your image-file get created!
   
 .
   

# INSTALL

Open a terminal window

Change to the Downloads folder (optional).

     cd Downloads

Download 'sd.sh'.

     wget https://raw.githubusercontent.com/RichardMidnight/sd/main/sd

Install to your /usr/local/bin folder.

     sudo bash sd.sh install

.

# EXAMPLES

List available SD-devices and image-files

     sd list 
     
To copy your SD-card to an image-file called newimage.zip

     sd read sda newimage.zip
     
To write an image-file to an SD-card in 'sda'

    sd write newimage.zip sda
    
    
