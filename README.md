# sd
Raspberry Pi sd image-file reader and writer

 - Easily read an sd card and create an image file

 - Easily write an image to an sd card

 - works entirely on a Raspberry Pi.  No Windows or Mac needed
 
 SETUP:
 
   Install Raspbery PI OS on an sd drive that is large enought to hold some images.  32GB or 64GB will do.
   
   Use a USB SD reader
   
   Get some 8GB sd cards.  Use the smallest you can use... so there is less data being copied.
   
   Startup you Raspberry Pi on the 64GB disk
   
   

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
