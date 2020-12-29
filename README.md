# sd
Raspberry Pi sd image-file reader and writer

 - Easily read an sd card and create an image file

 - Easily write an image to an sd card

 - Works entirely on a Raspberry Pi.  No Windows or Mac needed.
 
 
 
 USAGE:
 
   1) Install Raspbery PI OS on an SD card that is large enought to hold some SD images.  32GB or 64GB will do.  This is your Master SD card.
   
   2) Install sd as discribed below.
   
   
 TO MAKE AN IMAGE FILE...  
   
   1) Put the SD card you want to make an image of in a USB SD reader and insert it in a PI USB port.  I have been using Sandisk Industrial 8GB cards.
   
   2) Open a terminal
   
   3) Type in the command below to see the name of the sd card.  If it is the only one in, it will be 'sda'.
   
         sd list
         
   4)  Type in the command below to start reading the card to an image file
   
        sd read
        
   5) Follow the prompts to enter the sd device name (probably sda) and the image-file-name you want to use.
   
   
   

TO INSTALL:

Open a terminal window:

Move to the Downloads folder (optional)

     cd Downloads

Download sd.sh:

     curl -O https://raw.githubusercontent.com/RichardMidnight/sd/main/sd.sh


Install to your /usr/local/bin folder

     sudo bash sd.sh install


USAGE:

List available sd devices and image files:

     sd list 
     

To copy your SD card to an image file called newimage.zip

     sd read sda newimage.zip
