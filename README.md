# Docker photo video organizer (and optimizer)
Is a docker image that organize photos and videos in year/month folder hierarchy
Also it convert videos into an optimized H265 codec saving a lot of space. A video of 1G can be reduced to 100-200Mb, easyly a 80%.
The date of photo/video is obtanied from the exif data, not filesystem creation or modification.

The contanier recive three volumes:
- input --> the folder contaning multimedia files
- output --> where the collection is organized (photos and optimized videos)
- videos_originales --> the original video file. You always can remove it if you are happy with the converting one or you can save in a big storage.

## Usage
Simply run

docker run --rm -v /path/local/input/:/input -v /path/local/output/:/output -v /path/to-store/videos-orignales/:/videos_originales luisfeser/photo-video-organizer
