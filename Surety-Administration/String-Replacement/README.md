<a href="https://www.crownpeak.com/" target="_blank">![Crownpeak Logo](../../images/logo/crownpeak-logo.png?raw=true "Crownpeak Logo")</a>

# String Replacement (Surety Administration)
Post Surety Import Asset Script to replace Asset Path references from the default, to the relevant import target folder
location.

## Configuration Steps
 1) Create a new **DXM Template**  called **String Replacement** and include all .aspx files from this folder
    location.
 
 2) Create an Asset in a well-known location (e.g., /System/Surety Administration/) called **String Replacement**, using 
    the Template that you just created. Do not assign a **Workflow**.
    
 3) Once a Surety import has been completed, use **Form View** to configure the relevant fields for replacement:
 
    * **Current Text** - The original Asset Path (by default, this is /Surety/).
    * **New Text** - The _new_ Asset Path.
    * **Folder List - Folder to Crawl** - The **Surety** folder where you deployed using Content Xcelerator℠.
    * **Save - Save Option** - Set to **Replace** to have the process run upon **Save** of the Asset.
    
    ![Surety String Replacement](../../images/screenshots/Crownpeak-Content-Xcelerator℠/surety-string-replace-settings.png?raw=true "Surety String Replacement")    
        
    Once saved and run, check **Preview** to ensure correct replacements.
        
    ![Surety String Replacement Complete](../../images/screenshots/Crownpeak-Content-Xcelerator℠/surety-string-replace-preview.png?raw=true "Surety String Replacement Complete")       
       
 4) Browse to your deployed Surety site and open the Asset of your choice.