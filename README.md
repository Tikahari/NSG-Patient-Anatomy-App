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
&nbsp;&nbsp;&nbsp;&nbsp;Ineffective communication between physicians and their patients can lead to uneccessary complications and infringes on the patient's ability to consent. This potentially dangerous scenario is more common when either the condition or treatment of the patient involves spatial relationships between unseen components. One field where such conditions and treatments are common is neurosurgery.<br>
&nbsp;&nbsp;&nbsp;&nbsp;Physicians, patients, and all individual affected by healthcare of a patient would benefit from a tool that makes use of modern neuroimaging and visualization techniques in the form of a accurate, responsive, and intuitive render of patients' headscan data. Due to guideline set forth by the Department of Health and Human Services’ Office for Civil Rights in HIPAA, the application should provide secure storage, processing, and access of the data involved.<br>
&nbsp;&nbsp;&nbsp;&nbsp;Here we seek to make such a tool through an iOS application built with VTK and a pair of web servers which utilize FreeSurfer to perform segmentation, manage user data, and monitor system status.

## Architecture
![alt text](https://github.com/Tikahari/NSG-Patient-Anatomy-App/blob/master/img/Architecture.png)

## Render
![alt text](https://github.com/Tikahari/NSG-Patient-Anatomy-App/blob/master/img/Full.PNG)
![alt text](https://github.com/Tikahari/NSG-Patient-Anatomy-App/blob/master/img/Left%20Hemisphere.PNG)
![alt text](https://github.com/Tikahari/NSG-Patient-Anatomy-App/blob/master/img/Pituitary.PNG)
