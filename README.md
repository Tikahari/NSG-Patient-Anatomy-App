# NSG-Patient-Anatomy-App
#### Contributors: Tikahari Khanal, Michael Gordo, Jonas Pena
#### Necessary Installs
##### Client
* VTK 7.0.0
* Xcode 11.3
##### Server
* Python3
* Django 3.0.6
* Freesurfer 6.0.0
* nibabel 3.1.0
* numpy 1.16.2


## Overview
Ineffective communication between physicians and their patients can lead to uneccessary complications and infringes on the patient's ability to consent. This potentially dangerous scenario is more common when either the condition or treatment of the patient involves spatial relationships between unseen components. One field where such conditions and treatments are common is neurosurgery.<br>
Physicians, patients, and all individual affected by healthcare of a patient would benefit from a tool that makes use of modern neuroimaging and visualization techniques in the form of a accurate, responsive, and intuitive render of patients' headscan data. Due to guideline set forth by the Department of Health and Human Services’ Office for Civil Rights in HIPAA, the application should provide secure storage, processing, and access of the data involved.<br>
Here we seek to make such a tool through an iOS application built with VTK and a pair of web servers which utilize FreeSurfer to perform segmentation, manage user data, and monitor system status.

## Architecture
![alt text](https://github.com/Tikahari/NSG-Patient-Anatomy-App/blob/master/img/Architecture.png)<br/>
The project had 3 major components: a client which provided the user interface, a server which directly communicated with the client and one database which held authentication information, and a second server which handled aspects of the neuroimaging pipeline. Submission of login credentials would be verified by the server and cross referenced with a database which contained information about access rights for each user (which scans could be viewed by which users and the state of those scans). Users are then able to view or process any of the scans to which they have access rights. A 'view' request results in the appropriate scan being downloaded and viewed in a view controller built with VTK. A 'process' request results in a request being sent from server 1/A to server 2/B which dispatches the neuroimaging pipeline to segment the appropriate raw scan. This pipeline is followed by a post-processing thread which converts the data to a format which is more friendly to the client VTK-based view controller. The scan is then downloaded and viewed as was done on the 'view' reqeust.
## Render
![alt text](https://github.com/Tikahari/NSG-Patient-Anatomy-App/blob/master/img/Full.PNG)
![alt text](https://github.com/Tikahari/NSG-Patient-Anatomy-App/blob/master/img/Left%20Hemisphere.PNG)<br/>
Here we see a responsive, color coded scan with and without an emphasized segment. The physician or patient would be presented with a table that relates numeric values to anatomical regions of the brain (in this case a 2 corresponds to the right hemisphere). The user can also control the opacity of the entire brain in the left image and the emphasized segment in the second through the slider along the bottom of the screen. Options to reset and return to the previous menu were deemed appropriate.
