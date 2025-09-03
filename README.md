# static-site-tiika


## Steps for generating site
Run daily generator
Then run everydaygenerator

## artTagging JSON Structure Notes


| "key": value             | Purpose                                                                                                                                                                       |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **"prefix": number**     | Identifier of art pieces corresponding to the day of creation                                                                                                                 |
| **"stock": true**        | used to denote that an art piece used stock photography at some point                                                                                                         |
| **"special-name": name** | used to give a name that would override the auto generated name (for example if the name of the art piece uses hyphens ('-') in the name that would get removed)              |
| **"model": AImodel**     | used to show that an AI model was used at some point including the following:<br>"model": "Stable Diffusion via DiffusionBee"<br>"model": "Stable Diffusion via DiffusionBee" |

TODO: 
Need to update the following to have a special-name:
0215. Shattered Melt-Bed
0461. No More Band-Aids
0534. Part Of A Non-Generative Collection
0645. Twenty-Nine Is My Favorite Number
1111. My Self-Made Judecca
1127. Under White-Hot Atonement
1389. Eight Of Twenty-Four