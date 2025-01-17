# static-site-tiika


## artTagging JSON Structure Notes


| "key": value             | Purpose                                                                                                                                                                       |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **"prefix": number**     | Identifier of art pieces corresponding to the day of creation                                                                                                                 |
| **"stock": true**        | used to denote that an art piece used stock photography at some point                                                                                                         |
| **"special-name": name** | used to give a name that would override the auto generated name (for example if the name of the art piece uses hyphens ('-') in the name that would get removed)              |
| **"model": AImodel**     | used to show that an AI model was used at some point including the following:<br>"model": "Stable Diffusion via DiffusionBee"<br>"model": "Stable Diffusion via DiffusionBee" |
